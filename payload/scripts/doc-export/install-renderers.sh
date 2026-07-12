#!/usr/bin/env bash
# doc-export/install-renderers.sh — 二次成果物のレンダラを opt-in で取得（案内）する。
# 使い方: install-renderers.sh [name...]
#   name を省略すると全レンダラの状態と取得手順を一覧表示する。
#
# 方針（design.md 準拠）:
#  - 重いレンダラ本体（pandoc/mermaid-cli/PDF エンジン/Excel 変換器）は**再配布しない**。
#  - 各レンダラの「PATH 上に在るか」を検出し、無い場合は公式の取得手順を案内する。
#  - 破壊的な自動インストールは行わない（案内に留め、実行は人間の判断に委ねる）。
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/renderers.sh"

# レンダラ名 → 検出コマンド | 用途 | 取得手順
renderer_info(){
  case "$1" in
    pandoc) echo "pandoc|Word/PDF/PPT 変換（コア）|https://pandoc.org/installing.html （brew install pandoc / apt-get install pandoc 等）" ;;
    mmdc)   echo "mmdc|Mermaid 図の画像化（opt-in）|npm i -g @mermaid-js/mermaid-cli" ;;
    pdf)    echo "wkhtmltopdf|PDF エンジン（pandoc の PDF 出力に利用）|https://wkhtmltopdf.org/ もしくは TeX(LaTeX) を導入" ;;
    plantuml) echo "plantuml|厳密 UML 図（opt-in・別pkg）|https://plantuml.com/starting （Java 必須）" ;;
    *) return 1 ;;
  esac
}

ALL="pandoc mmdc pdf plantuml"

show_one(){
  local name="$1" info cmd purpose howto
  info="$(renderer_info "$name")" || { echo "  未知のレンダラ: $name"; return; }
  cmd="${info%%|*}"; info="${info#*|}"; purpose="${info%%|*}"; howto="${info#*|}"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "  [導入済み] $name ($cmd) — $purpose"
  else
    echo "  [未導入]   $name ($cmd) — $purpose"
    echo "             取得: $howto"
  fi
}

echo "二次成果物レンダラの状態（本体は同梱していません。必要なものを opt-in で取得してください）:"
if [ $# -gt 0 ]; then
  for n in "$@"; do show_one "$n"; done
else
  for n in $ALL; do show_one "$n"; done
fi
echo ""
echo "※ 未導入フォーマットは doc-export 実行時に「未生成（要 install-renderers）」として明示され、他成果物の生成は継続します。"
