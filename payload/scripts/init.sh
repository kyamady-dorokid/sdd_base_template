#!/usr/bin/env bash
# SDD base 初期化（cc-sdd 取得 → 検証 → overlay → 再検証）。冪等。
# 使い方: init.sh <repo_root> <payload_dir> [--lang ja] [--yes]
set -uo pipefail
ROOT="${1:?repo_root required}"; PAYLOAD="${2:?payload_dir required}"; shift 2 || true
LANG_OPT="ja"; ASSUME_YES=0
while [ $# -gt 0 ]; do case "$1" in --lang) LANG_OPT="$2"; shift 2;; --yes|-y) ASSUME_YES=1; shift;; *) shift;; esac; done
cd "$ROOT" || exit 1
say(){ printf '\n\033[1m%s\033[0m\n' "$*"; }

say "[1/6] 前提チェック"
command -v node >/dev/null || { echo "node が必要です"; exit 1; }
command -v npx  >/dev/null || { echo "npx が必要です"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "git リポジトリではありません。先に 'git init' してください。"; exit 1; }
if [ -d "$ROOT/.kiro/settings" ] && [ "$ASSUME_YES" = 0 ]; then
  echo "既存の .kiro/settings を検出。cc-sdd の再適用は既存ファイルを保持します（cc-sdd既定）。続行します。"
fi

say "[2/6] cc-sdd を取得・適用（Claude Code + Codex の両方）"
echo "  - Claude Code 用 (.claude/skills, CLAUDE.md)"
npx -y cc-sdd@latest --claude-code-skills --lang "$LANG_OPT" || { echo "cc-sdd(Claude) 実行に失敗しました"; exit 1; }
echo "  - Codex 用 (.agents/skills, AGENTS.md)"
npx -y cc-sdd@latest --codex-skills --lang "$LANG_OPT" || { echo "cc-sdd(Codex) 実行に失敗しました"; exit 1; }

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
# 5-2: specs 置き場
mkdir -p "$ROOT/docs/specs" "$ROOT/.kiro/specs"
[ -f "$ROOT/docs/specs/.gitkeep" ] || touch "$ROOT/docs/specs/.gitkeep"
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
if ! grep -q 'docs/specs/\*/outputs/' "$ROOT/.gitignore" 2>/dev/null; then
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
  2. /kiro-discovery "<やりたいこと>" から仕様化を開始
  3. 区切りでコミット（main直コミット禁止・ブランチ→PR）
  整合確認: diff -qr .claude/skills .agents/skills
EOS
