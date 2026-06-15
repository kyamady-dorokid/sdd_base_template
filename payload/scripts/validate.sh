#!/usr/bin/env bash
# SDD base 検証スクリプト。
# 使い方: validate.sh <repo_root> <payload_dir> <phase>
#   phase = pre   … cc-sdd 取得直後（overlay 前）
#   phase = post  … overlay 適用後
# 終了コード: 0=OK / 2=要人間確認（停止推奨）
set -uo pipefail
ROOT="${1:?repo_root required}"
PAYLOAD="${2:?payload_dir required}"
PHASE="${3:-pre}"
WARN=0

say(){ printf '%s\n' "$*"; }
ng(){ printf '  [NG] %s\n' "$*"; WARN=1; }
ok(){ printf '  [OK] %s\n' "$*"; }

if [ "$PHASE" = "pre" ]; then
  say "== 検証(pre): 構造存在 =="
  for p in ".kiro/settings" ".claude/skills" ".agents/skills" "CLAUDE.md" "AGENTS.md"; do
    [ -e "$ROOT/$p" ] && ok "$p" || ng "$p が無い"
  done

  say "== 検証(pre): Claude/Codex 構造パリティ =="
  # 注: cc-sdd は Claude(/kiro)とCodex($kiro,agents/)で内容を意図的に変える。
  # よってファイル内容の一致ではなく「同じスキル群が両方に存在するか（名前集合）」を検証する。
  ALLOW="$PAYLOAD/validation/known-parity-diffs.txt"   # 片側のみ存在を許容するスキル名
  allowset="$(grep -v '^#' "$ALLOW" 2>/dev/null | sed '/^$/d')"
  cset="$(ls -1 "$ROOT/.claude/skills" 2>/dev/null | sort)"
  aset="$(ls -1 "$ROOT/.agents/skills" 2>/dev/null | sort)"
  only_claude="$(comm -23 <(printf '%s\n' "$cset") <(printf '%s\n' "$aset"))"
  only_agents="$(comm -13 <(printf '%s\n' "$cset") <(printf '%s\n' "$aset"))"
  pmis=0
  for s in $only_claude; do grep -qxF "$s" <<<"$allowset" && ok "片側許容(Claudeのみ): $s" || { ng "Claudeのみ存在: $s"; pmis=1; }; done
  for s in $only_agents; do grep -qxF "$s" <<<"$allowset" && ok "片側許容(Codexのみ): $s" || { ng "Codexのみ存在: $s"; pmis=1; }; done
  if [ "$pmis" = 0 ]; then
    n="$(printf '%s\n' "$cset" | sed '/^$/d' | wc -l | tr -d ' ')"
    ok "構造パリティOK（両エージェントに同一の $n スキルが存在）"
  fi

  say "== 検証(pre): Codex パス健全性 =="
  badpaths="$(grep -rln '\.claude/skills' "$ROOT/.agents" 2>/dev/null || true)"
  if [ -n "$badpaths" ]; then
    ng "Codex(.agents) 内に '.claude/skills' 参照あり（パス誤りの可能性）:"; printf '       %s\n' $badpaths
  else
    ok ".agents 内に '.claude/skills' 誤参照なし"
  fi

  say "== 検証(pre): cc-sdd バージョン整合 =="
  KG="$(tr -d ' \n' < "$PAYLOAD/KNOWN_GOOD_CCSDD_VERSION" 2>/dev/null)"
  CUR="$(npm view cc-sdd version 2>/dev/null || echo unknown)"
  if [ "$CUR" = "$KG" ]; then ok "cc-sdd $CUR (=KNOWN_GOOD)"; else ng "cc-sdd $CUR が KNOWN_GOOD($KG) と不一致 → 追加検査/人間確認を推奨"; fi
fi

if [ "$PHASE" = "post" ]; then
  say "== 検証(post): overlay 適用結果 =="
  for f in CLAUDE.md AGENTS.md; do
    n="$(grep -c 'SDD-BASE:START' "$ROOT/$f" 2>/dev/null || echo 0)"
    [ "$n" = 1 ] && ok "$f の SDD-BASE ブロックは1つ" || ng "$f の SDD-BASE ブロックが $n 個（重複/欠落）"
  done
  [ -f "$ROOT/docs/sdd/workflow.md" ] && ok "docs/sdd/ 展開済み" || ng "docs/sdd/ が無い"
  grep -q 'docs/specs/\*/outputs/' "$ROOT/.gitignore" 2>/dev/null && ok ".gitignore 追記済み" || ng ".gitignore 未追記"
fi

if [ "$WARN" = 0 ]; then say "==> 検証 PASS"; exit 0; else say "==> 検証で要確認あり（人間の判断を推奨）"; exit 2; fi
