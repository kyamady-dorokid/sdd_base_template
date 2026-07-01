#!/usr/bin/env bash
# sync.sh — 運用中リポジトリへ上流テンプレートの更新を安全に反映する（3-wayマージ+lock）。
# 使い方: sync.sh <repo_root> <payload_dir> [--yes]
#
# 設計方針（.kiro/specs/sdd-base-sync-command/design.md 準拠）:
#  - いかなる場合もローカルファイルをサイレント上書きしない。
#  - コンフリクトは「エラー」ではなく「想定内の分岐」として扱い、<file>.new を出力するのみ。
#  - .kiro/specs/ 等の保護領域は管理対象リストに含めないことで、構造的に不可侵とする。
#  - 自動コミットは一切行わない。
set -uo pipefail
ROOT="${1:?repo_root required}"; PAYLOAD="${2:?payload_dir required}"; shift 2 || true
ASSUME_YES=0
for a in "$@"; do [ "$a" = "--yes" ] && ASSUME_YES=1; done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/sync_lib/hash.sh"
source "$SCRIPT_DIR/sync_lib/lock.sh"
source "$SCRIPT_DIR/sync_lib/merge.sh"

say(){ printf '\n\033[1m%s\033[0m\n' "$*"; }

LOCKDIR="$ROOT/.kiro"
LOCK="$LOCKDIR/sdd-base.lock"
SNAPSHOT="$LOCKDIR/sdd-base-snapshot"
REPORT="$ROOT/.kiro/sdd-base-update-report.md"

TMPWORK="$(mktemp -d)"
trap 'rm -rf "$TMPWORK"' EXIT

mkdir -p "$LOCKDIR"

# --- 管理対象の定義 ---

managed_docs(){
  [ -d "$PAYLOAD/overlay/docs/sdd" ] || return 0
  ( cd "$PAYLOAD/overlay/docs/sdd" && find . -type f | sed 's#^\./##' )
}

# "target_relpath|marker|source_type|source_arg"
#   source_type=snippet: source_arg は payload 相対パス（ブロック自体が SDD-BASE:START/END を内包）
#   source_type=patch  : source_arg は payload/validation/patches/ 配下のパッチ名
#                         （ブロック内容はパッチのheredocに埋め込まれているため、白紙ファイルへ
#                          パッチを適用した結果からブロックを抽出して "新版" を得る）
MANAGED_BLOCKS=(
  "CLAUDE.md|SDD-BASE|snippet|overlay/snippets/CLAUDE.sdd.md"
  "AGENTS.md|SDD-BASE|snippet|overlay/snippets/AGENTS.sdd.md"
  ".claude/skills/kiro-impl/SKILL.md|SDD-OVERLAY:IMPL-POLICY|patch|fix-impl-team-policy.sh"
  ".agents/skills/kiro-impl/SKILL.md|SDD-OVERLAY:IMPL-POLICY|patch|fix-impl-team-policy.sh"
  ".kiro/settings/templates/specs/design.md|SDD-OVERLAY:DESIGN-TECHREQ|patch|fix-design-template.sh"
  ".claude/skills/kiro-spec-init/SKILL.md|SDD-OVERLAY:ENSURE-AGREEMENT-LOG|patch|ensure-agreement-log.sh"
  ".agents/skills/kiro-spec-init/SKILL.md|SDD-OVERLAY:ENSURE-AGREEMENT-LOG|patch|ensure-agreement-log.sh"
)

sdd_sync_get_new_block(){
  local entry_file="$1" marker="$2" stype="$3" sarg="$4"
  case "$stype" in
    snippet)
      sdd_extract_block "$PAYLOAD/$sarg" "$marker" 2>/dev/null
      ;;
    patch)
      local scratch; scratch="$(mktemp -d)"
      mkdir -p "$scratch/$(dirname "$entry_file")"
      : > "$scratch/$entry_file"
      bash "$PAYLOAD/validation/patches/$sarg" "$scratch" >/dev/null 2>&1 || true
      sdd_extract_block "$scratch/$entry_file" "$marker" 2>/dev/null
      rm -rf "$scratch"
      ;;
  esac
}

# --- レポート集計用リスト ---
NEW_LIST=()
UPDATED_LIST=()
MERGED_LIST=()
CONFLICT_LIST=()
DELETED_LIST=()

write_report(){
  local commit; commit="$(sdd_lock_get_meta "$LOCK" template_commit)"
  {
    echo "# sync 実行結果レポート"
    echo ""
    echo "- template_commit: ${commit:-unknown}"
    echo ""
    echo "## 新規適用したファイル"
    if [ "${#NEW_LIST[@]}" -gt 0 ]; then for x in "${NEW_LIST[@]}"; do echo "- $x"; done; else echo "(なし)"; fi
    echo ""
    echo "## そのまま更新したファイル（ローカル未変更）"
    if [ "${#UPDATED_LIST[@]}" -gt 0 ]; then for x in "${UPDATED_LIST[@]}"; do echo "- $x"; done; else echo "(なし)"; fi
    echo ""
    echo "## クリーンマージしたファイル"
    if [ "${#MERGED_LIST[@]}" -gt 0 ]; then for x in "${MERGED_LIST[@]}"; do echo "- $x"; done; else echo "(なし)"; fi
    echo ""
    echo "## コンフリクトしたファイル"
    if [ "${#CONFLICT_LIST[@]}" -gt 0 ]; then
      for x in "${CONFLICT_LIST[@]}"; do echo "- $x （\`<file>.new\` を確認し、手動で解消してください。既存ファイルは無変更です）"; done
    else
      echo "(なし)"
    fi
    echo ""
    echo "## 上流で削除されたファイル（ローカルからは削除していません）"
    if [ "${#DELETED_LIST[@]}" -gt 0 ]; then for x in "${DELETED_LIST[@]}"; do echo "- $x"; done; else echo "(なし)"; fi
  } > "$REPORT"
}

# --- 初回化ルート ---

initial_sync(){
  mkdir -p "$SNAPSHOT/docs/sdd" "$SNAPSHOT/blocks"
  cp -R "$PAYLOAD/overlay/docs/sdd/." "$SNAPSHOT/docs/sdd/" 2>/dev/null || true

  local commit; commit="$(sdd_lock_resolve_commit "$PAYLOAD")"
  : > "$LOCK"
  sdd_lock_set_meta "$LOCK" template_commit "$commit"
  sdd_lock_set_meta "$LOCK" template_repo "$SDD_TEMPLATE_REPO_FALLBACK"

  local rel h
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    h="$(sdd_hash_file "$PAYLOAD/overlay/docs/sdd/$rel")"
    sdd_lock_set_file "$LOCK" "docs/sdd/$rel" "$h"
    NEW_LIST+=("docs/sdd/$rel")
  done < <(managed_docs)

  local entry f m stype sarg tf content bh safe
  for entry in "${MANAGED_BLOCKS[@]}"; do
    IFS='|' read -r f m stype sarg <<< "$entry"
    tf="$ROOT/$f"
    [ -f "$tf" ] || continue
    content="$(sdd_extract_block "$tf" "$m" 2>/dev/null)" || continue
    bh="$(sdd_hash_string "$content")"
    sdd_lock_set_block "$LOCK" "$f" "$m" "$bh"
    safe="$(printf '%s__%s' "$f" "$m" | tr '/:' '__')"
    printf '%s\n' "$content" > "$SNAPSHOT/blocks/$safe"
    NEW_LIST+=("$f (block:$m)")
  done

  write_report
  echo "sync: 初回化完了（lock/snapshot 作成）。既存ファイルは変更していません。$REPORT を確認してください。"
}

# --- 差分適用ルート: docs/sdd 一式 ---

apply_docs(){
  local rel relpath target newsrc base cur_hash lock_hash out
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    relpath="docs/sdd/$rel"
    target="$ROOT/$relpath"
    newsrc="$PAYLOAD/overlay/docs/sdd/$rel"
    base="$SNAPSHOT/docs/sdd/$rel"

    if [ ! -f "$target" ]; then
      mkdir -p "$(dirname "$target")"
      cp "$newsrc" "$target"
      NEW_LIST+=("$relpath")
      sdd_lock_set_file "$LOCK" "$relpath" "$(sdd_hash_file "$newsrc")"
      mkdir -p "$(dirname "$base")"; cp "$newsrc" "$base"
      continue
    fi

    cur_hash="$(sdd_hash_file "$target")"
    lock_hash="$(sdd_lock_get_file "$LOCK" "$relpath")"

    if [ -z "$lock_hash" ]; then
      # 後から管理対象に加わったファイル: 現状を基準として記録するのみ（上書きしない）
      sdd_lock_set_file "$LOCK" "$relpath" "$cur_hash"
      mkdir -p "$(dirname "$base")"; cp "$newsrc" "$base"
      continue
    fi

    if [ "$cur_hash" = "$lock_hash" ]; then
      cp "$newsrc" "$target"
      UPDATED_LIST+=("$relpath")
      sdd_lock_set_file "$LOCK" "$relpath" "$(sdd_hash_file "$target")"
      mkdir -p "$(dirname "$base")"; cp "$newsrc" "$base"
    else
      out="$TMPWORK/merged.$$"
      if [ -f "$base" ] && sdd_merge_file "$target" "$base" "$newsrc" "$out"; then
        mv "$out" "$target"
        MERGED_LIST+=("$relpath")
        sdd_lock_set_file "$LOCK" "$relpath" "$(sdd_hash_file "$target")"
        cp "$newsrc" "$base"
      else
        [ -f "$out" ] && mv "$out" "${target}.new"
        CONFLICT_LIST+=("$relpath")
        # lock/base は更新しない（次回 sync で再度この基準からマージを試みる）
      fi
    fi
  done < <(managed_docs)

  # 上流で削除されたファイル検出（スナップショット基準）
  local srel
  if [ -d "$SNAPSHOT/docs/sdd" ]; then
    while IFS= read -r srel; do
      [ -n "$srel" ] || continue
      [ -f "$PAYLOAD/overlay/docs/sdd/$srel" ] && continue
      DELETED_LIST+=("docs/sdd/$srel")
    done < <( cd "$SNAPSHOT/docs/sdd" && find . -type f | sed 's#^\./##' )
  fi
}

# --- 差分適用ルート: マーカーブロック ---

apply_blocks(){
  local entry f m stype sarg target cur_block cur_hash lock_hash safe base_file new_block
  local curblockfile otherfile mergedfile outfile
  for entry in "${MANAGED_BLOCKS[@]}"; do
    IFS='|' read -r f m stype sarg <<< "$entry"
    target="$ROOT/$f"
    [ -f "$target" ] || continue
    cur_block="$(sdd_extract_block "$target" "$m" 2>/dev/null)" || continue
    cur_hash="$(sdd_hash_string "$cur_block")"
    lock_hash="$(sdd_lock_get_block "$LOCK" "$f" "$m")"
    safe="$(printf '%s__%s' "$f" "$m" | tr '/:' '__')"
    base_file="$SNAPSHOT/blocks/$safe"
    new_block="$(sdd_sync_get_new_block "$f" "$m" "$stype" "$sarg")"

    if [ -z "$lock_hash" ]; then
      sdd_lock_set_block "$LOCK" "$f" "$m" "$cur_hash"
      printf '%s\n' "$cur_block" > "$base_file"
      continue
    fi

    if [ "$cur_hash" = "$lock_hash" ]; then
      [ -n "$new_block" ] || continue
      outfile="$TMPWORK/blockout.$$"
      printf '%s\n' "$new_block" > "$TMPWORK/newblock.$$"
      sdd_replace_block "$target" "$m" "$TMPWORK/newblock.$$" "$outfile"
      mv "$outfile" "$target"
      UPDATED_LIST+=("$f (block:$m)")
      sdd_lock_set_block "$LOCK" "$f" "$m" "$(sdd_hash_string "$new_block")"
      printf '%s\n' "$new_block" > "$base_file"
      rm -f "$TMPWORK/newblock.$$"
    else
      curblockfile="$TMPWORK/curblock.$$"; otherfile="$TMPWORK/otherblock.$$"; mergedfile="$TMPWORK/mergedblock.$$"
      printf '%s\n' "$cur_block" > "$curblockfile"
      printf '%s\n' "$new_block" > "$otherfile"
      if [ -f "$base_file" ] && sdd_merge_file "$curblockfile" "$base_file" "$otherfile" "$mergedfile"; then
        outfile="$TMPWORK/blockout.$$"
        sdd_replace_block "$target" "$m" "$mergedfile" "$outfile"
        mv "$outfile" "$target"
        MERGED_LIST+=("$f (block:$m)")
        sdd_lock_set_block "$LOCK" "$f" "$m" "$(sdd_hash_file "$mergedfile")"
        cp "$mergedfile" "$base_file"
      else
        outfile="${target}.new"
        sdd_replace_block "$target" "$m" "${mergedfile:-$curblockfile}" "$outfile"
        CONFLICT_LIST+=("$f (block:$m)")
        # lock/base は更新しない
      fi
      rm -f "$curblockfile" "$otherfile" "$mergedfile"
    fi
  done
}

# --- .gitignore スニペット（欠落分のみ追記） ---

apply_gitignore(){
  local snippet="$PAYLOAD/overlay/gitignore.snippet"
  [ -f "$snippet" ] || return 0
  local line added=0
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    grep -qF -- "$line" "$ROOT/.gitignore" 2>/dev/null && continue
    printf '%s\n' "$line" >> "$ROOT/.gitignore"
    added=1
  done < "$snippet"
  [ "$added" = 1 ] && UPDATED_LIST+=(".gitignore（欠落分を追記）")
}

# --- メイン ---

if [ ! -f "$LOCK" ]; then
  say "sync: lock 不在 → 初回化"
  initial_sync
else
  say "sync: lock 検出 → 差分適用"
  apply_docs
  apply_blocks
  apply_gitignore
  write_report
  echo "sync: 差分適用完了。$REPORT を確認してください。"
  if [ "${#CONFLICT_LIST[@]}" -gt 0 ]; then
    echo "  ※ コンフリクトが ${#CONFLICT_LIST[@]} 件あります。<file>.new を確認し、手動で解消してください（既存ファイルは無変更）。"
  fi
fi

echo "  次回から楽にするなら: ~/.claude/skills/sdd-init などローカルスキルミラーの再同期（install の再実行）を検討してください。"
exit 0
