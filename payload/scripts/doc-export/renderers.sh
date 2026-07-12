#!/usr/bin/env bash
# doc-export/renderers.sh — レンダラ・レジストリ。
#
# 設計方針（design.md 準拠）:
#  - フォーマット→レンダラの対応と、PATH 上の可用性検出のみを行う。
#  - 重いレンダラ本体（pandoc/mmdc/PDF エンジン/Excel 変換器）は同梱しない（検出のみ）。
#  - bash 3.2 互換（連想配列を使わず case で対応表を持つ）。

# フォーマット → レンダラ実行体名
sdd_renderer_for(){
  case "$1" in
    docx|pdf|pptx) echo "pandoc" ;;
    mermaid)       echo "mmdc" ;;
    xlsx)          echo "" ;;   # 別pkg（外部変換器）。基盤標準の実行体を持たない
    uml)           echo "plantuml" ;;
    *)             echo "" ;;
  esac
}

# フォーマット → 分類（core / limited / optional / external）
sdd_renderer_class(){
  case "$1" in
    docx|pdf) echo "core" ;;
    pptx)     echo "limited" ;;
    mermaid|uml) echo "optional" ;;
    xlsx)     echo "external" ;;
    *)        echo "" ;;
  esac
}

# レンダラ実行体名 → "用途|導入手順(表示用)|自動実行コマンド(空=手動のみ)"。
# 導入コマンドの単一ソース＝DRY。export.sh / install-renderers.sh がともにここを参照する。
# 自動実行コマンドは、環境非依存で安全に実行できるもの（npm グローバル導入等）のみ設定する。
# 環境依存（brew/apt 等）や手動手順のものは空（＝提示のみ・自動実行しない）。
sdd_renderer_install_hint(){
  case "$1" in
    pandoc)   echo "Word/PDF/PPT 変換（コア）|brew install pandoc（macOS）/ apt-get install pandoc（Debian系）/ https://pandoc.org/installing.html|" ;;
    mmdc)     echo "Mermaid 図の画像化（opt-in）|npm i -g @mermaid-js/mermaid-cli|npm i -g @mermaid-js/mermaid-cli" ;;
    wkhtmltopdf) echo "PDF エンジン（pandoc の PDF 出力に利用）|https://wkhtmltopdf.org/ もしくは TeX(LaTeX) を導入|" ;;
    plantuml) echo "厳密 UML 図（opt-in・別pkg）|https://plantuml.com/starting （Java 必須）|" ;;
    *)        echo "" ;;
  esac
}

# 実行体名が PATH にあれば 0、無ければ非0
sdd_renderer_available_cmd(){
  command -v "$1" >/dev/null 2>&1
}

# フォーマットが生成可能か（対応レンダラが PATH にあるか）。0=可, 非0=不可
sdd_renderer_available(){
  local cmd; cmd="$(sdd_renderer_for "$1")"
  [ -n "$cmd" ] || return 2   # そもそも対応レンダラが定義されていない
  sdd_renderer_available_cmd "$cmd"
}
