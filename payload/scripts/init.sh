#!/usr/bin/env bash
# SDD base 初期化（cc-sdd 取得 → 検証 → overlay → 再検証）。冪等。
# 使い方: init.sh <repo_root> <payload_dir> [--lang ja] [--yes] [--on-existing keep|overwrite|compare]
set -uo pipefail
ROOT="${1:?repo_root required}"; PAYLOAD="${2:?payload_dir required}"; shift 2 || true
LANG_OPT="ja"; ASSUME_YES=0; ON_EXISTING=""
while [ $# -gt 0 ]; do case "$1" in
  --lang) LANG_OPT="$2"; shift 2;;
  --yes|-y) ASSUME_YES=1; shift;;
  --on-existing) ON_EXISTING="$2"; shift 2;;
  --on-existing=*) ON_EXISTING="${1#*=}"; shift;;
  *) shift;;
esac; done
cd "$ROOT" || exit 1
say(){ printf '\n\033[1m%s\033[0m\n' "$*"; }

say "[1/6] 前提チェック"
command -v node >/dev/null || { echo "node が必要です"; exit 1; }
command -v npx  >/dev/null || { echo "npx が必要です"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "git リポジトリではありません。先に 'git init' してください。"; exit 1; }

# --- 既存エージェント環境（上書き対象）の検出と扱いの決定 ---
# 上書きされ得る再生成可能な足場のみを検出対象とする。
EXISTING=""
for p in CLAUDE.md AGENTS.md .claude/skills .agents/skills .kiro/settings; do
  [ -e "$ROOT/$p" ] && EXISTING="$EXISTING $p"
done
# 保護対象（どのモードでも初期化しない＝ユーザーの仕様・記録・プロジェクトメモリ）
PROTECTED=""
for p in .kiro/specs .kiro/steering; do
  if [ -d "$ROOT/$p" ] && [ -n "$(ls -A "$ROOT/$p" 2>/dev/null | grep -v '^\.gitkeep$' || true)" ]; then
    PROTECTED="$PROTECTED $p"
  fi
done

if [ -n "$EXISTING" ]; then
  echo "  既存のエージェント環境（上書き対象）を検出:$EXISTING"
  [ -n "$PROTECTED" ] && echo "  ※ 保護対象（初期化しません）:$PROTECTED"
  if [ -z "$ON_EXISTING" ]; then
    if [ "$ASSUME_YES" = 1 ] || [ ! -t 0 ]; then
      ON_EXISTING="keep"   # 非対話/-y は安全側（温存）
    else
      echo "  既存ファイルの扱いを選択してください:"
      echo "    [k] keep      … 既存を温存（推奨・既定）。SDDルールは追記のみ"
      echo "    [o] overwrite … cc-sdd で再生成（.sdd-backup/ にバックアップ後に上書き）"
      echo "    [c] compare   … 上書きせず、新旧の差分を表示（バックアップ保持）"
      printf "  選択 [k/o/c] (既定 k): "
      read -r ans </dev/tty || ans=""
      case "$ans" in o|O|overwrite) ON_EXISTING="overwrite";; c|C|compare) ON_EXISTING="compare";; *) ON_EXISTING="keep";; esac
    fi
  fi
else
  ON_EXISTING="keep"
fi
case "$ON_EXISTING" in keep|overwrite|compare) ;; *) echo "  不明な --on-existing='$ON_EXISTING' → keep として扱います"; ON_EXISTING="keep";; esac
echo "  既存ファイルの扱い: $ON_EXISTING"

# モード→cc-sdd フラグへ写像
#  keep    : フラグ無し＋stdin非TTY（</dev/null）＝既存温存・不足分のみ生成（cc-sdd既定の非対話挙動）
#            ※ cc-sdd の --overwrite=skip は「全ファイル skip（生成しない）」なので keep には使わない
#  overwrite: --overwrite=force --backup=DIR（バックアップ後に全上書き）
#  compare : 実ツリーは keep と同じ（非破壊）。別途 temp に生成して新旧 diff を提示
CC_FLAGS=(); BACKUP_DIR=""; MODE_LABEL="keep(既存温存・不足分のみ生成)"
if [ "$ON_EXISTING" = "overwrite" ]; then
  BACKUP_DIR=".sdd-backup/$(date +%Y%m%d-%H%M%S)"
  CC_FLAGS=(--overwrite=force --backup="$BACKUP_DIR")
  MODE_LABEL="overwrite(force+backup)"
fi

say "[2/6] cc-sdd を取得・適用（Claude Code + Codex の両方）"
echo "  - Claude Code 用 (.claude/skills, CLAUDE.md)  [$MODE_LABEL]"
npx -y cc-sdd@latest --claude-code-skills --lang "$LANG_OPT" ${CC_FLAGS[@]+"${CC_FLAGS[@]}"} </dev/null || { echo "cc-sdd(Claude) 実行に失敗しました"; exit 1; }
echo "  - Codex 用 (.agents/skills, AGENTS.md)  [$MODE_LABEL]"
npx -y cc-sdd@latest --codex-skills --lang "$LANG_OPT" ${CC_FLAGS[@]+"${CC_FLAGS[@]}"} </dev/null || { echo "cc-sdd(Codex) 実行に失敗しました"; exit 1; }
[ "$ON_EXISTING" = "overwrite" ] && [ -n "$BACKUP_DIR" ] && echo "  バックアップ: $BACKUP_DIR （上書き前の旧ファイルを保存）"

# compare モード: 既存を上書きせず、cc-sdd が書くであろう新版を temp に生成して新旧 diff を提示
if [ "$ON_EXISTING" = "compare" ]; then
  say "[2.5] compare: 既存（温存）と cc-sdd 新版の差分を提示（上書きはしません）"
  TMPC="$(mktemp -d)"
  ( cd "$TMPC" && git init -q \
    && npx -y cc-sdd@latest --claude-code-skills --lang "$LANG_OPT" --overwrite=force </dev/null >/dev/null 2>&1 \
    && npx -y cc-sdd@latest --codex-skills --lang "$LANG_OPT" --overwrite=force </dev/null >/dev/null 2>&1 ) || true
  for f in CLAUDE.md AGENTS.md; do
    if [ -f "$ROOT/$f" ] && [ -f "$TMPC/$f" ]; then
      if diff -q "$ROOT/$f" "$TMPC/$f" >/dev/null 2>&1; then
        echo "  $f: 既存と新版に差分なし"
      else
        echo "  --- diff: $f （< 既存 / > cc-sdd新版） ---"
        diff "$ROOT/$f" "$TMPC/$f" || true
      fi
    fi
  done
  rm -rf "$TMPC"
  echo "  ※ 既存ファイルは変更していません。必要箇所のみ手動で取り込んでください。"
fi

say "[3/6] 検証(pre): 構造・パリティ・Codexパス・バージョン"
bash "$PAYLOAD/scripts/validate.sh" "$ROOT" "$PAYLOAD" pre
PRE=$?

say "[4/6] 既知パッチ適用（あれば）"
shopt -s nullglob 2>/dev/null || true
applied=0
for p in "$PAYLOAD"/validation/patches/*.sh; do
  [ -e "$p" ] || continue
  echo "  patch: $(basename "$p")"; bash "$p" "$ROOT" && applied=1
done
[ "$applied" = 0 ] && echo "  (適用パッチなし)"
if [ "$PRE" -ne 0 ] && [ "$ASSUME_YES" = 0 ]; then
  echo "  ※ 検証(pre)で要確認あり。未知の不整合は人間が確認してください（処理は続行）。"
fi

say "[5/6] overlay 適用（冪等）"
# 5-1: docs/sdd 一式
mkdir -p "$ROOT/docs/sdd"
cp -R "$PAYLOAD/overlay/docs/sdd/." "$ROOT/docs/sdd/"
echo "  docs/sdd/ 展開"
# 5-2: specs 置き場（記録は .kiro/specs/<id>/ に集約。docs/specs は使わない）
mkdir -p "$ROOT/.kiro/specs"
[ -f "$ROOT/.kiro/specs/.gitkeep" ] || touch "$ROOT/.kiro/specs/.gitkeep"
# 5-3: CLAUDE.md / AGENTS.md にマーカー挿入（重複回避）
inject(){ # <target> <snippet> <marker>
  local tgt="$1" snip="$2" marker="$3"
  [ -f "$tgt" ] || : > "$tgt"
  if grep -q "$marker" "$tgt"; then echo "  $(basename "$tgt"): $marker は既存（スキップ）"; return; fi
  { printf '\n'; cat "$snip"; } >> "$tgt"; echo "  $(basename "$tgt"): $marker を追記"
}
inject "$ROOT/CLAUDE.md" "$PAYLOAD/overlay/snippets/CLAUDE.sdd.md"       "SDD-BASE:START"
inject "$ROOT/CLAUDE.md" "$PAYLOAD/overlay/snippets/project-overview.md" "SDD-BASE:PROJECT-OVERVIEW:START"
inject "$ROOT/AGENTS.md" "$PAYLOAD/overlay/snippets/AGENTS.sdd.md"       "SDD-BASE:START"
inject "$ROOT/AGENTS.md" "$PAYLOAD/overlay/snippets/project-overview.md" "SDD-BASE:PROJECT-OVERVIEW:START"
# 5-4: .gitignore 追記
if ! grep -q '\.kiro/specs/\*/outputs/' "$ROOT/.gitignore" 2>/dev/null; then
  { printf '\n'; cat "$PAYLOAD/overlay/gitignore.snippet"; } >> "$ROOT/.gitignore"; echo "  .gitignore 追記"
else echo "  .gitignore は既存（スキップ）"; fi

say "[6/6] 検証(post)"
bash "$PAYLOAD/scripts/validate.sh" "$ROOT" "$PAYLOAD" post || true

say "完了：SDD ベースを展開しました。"
cat <<'EOS'
次の一歩:
  0. Claude Code / Codex を起動し、まず適用ルールと進め方を確認:
       「このリポジトリに適用されているSDDのルールと、これからの開発の進め方を教えて」
  1. CLAUDE.md / AGENTS.md の「## プロジェクト概要（要記入）」を埋める
  2. 開発を始める（2つの入口。どちらでもルール・成果物・出力先は同一）:
       ・軽量（自然言語SDD） … 「<やりたいこと>。簡単な要件定義とプランニングから始めて」と指示
       ・フルフロー（kiroコマンド） … /kiro-discovery "<やりたいこと>" から仕様化を開始
     規模で Tier S/L を選ぶ。詳細は docs/sdd/workflow.md
  3. 区切りでコミット（main直コミット禁止・ブランチ→PR）
  整合確認: diff -qr .claude/skills .agents/skills
EOS
