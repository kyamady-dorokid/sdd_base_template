#!/usr/bin/env bash
# doc-export/install-renderers.sh — 二次成果物のレンダラを opt-in で取得する。
# 使い方: install-renderers.sh [cmd...]（省略時は全レンダラ）
#
# 方針（design.md 準拠）:
#  - 重いレンダラ本体は再配布しない。導入コマンドは renderers.sh のレジストリに一元化（DRY）。
#  - 対話端末で human が同意した場合にのみ導入コマンドを実行する。
#  - 非対話（`SDD_INSTALL_NONINTERACTIVE=1` または stdin から入力なし=EOF）では実行せず提示に留める。
#  - `SDD_INSTALL_DRYRUN=1` で実行の代わりにコマンドを表示（テスト用）。
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/renderers.sh"

ALL="pandoc mmdc wkhtmltopdf plantuml"

process_one(){
  local cmd="$1" hint purpose steps autorun ans
  hint="$(sdd_renderer_install_hint "$cmd")"
  [ -n "$hint" ] || { echo "  未知のレンダラ: $cmd"; return; }
  purpose="${hint%%|*}"; hint="${hint#*|}"; steps="${hint%%|*}"; autorun="${hint#*|}"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "  [導入済み] $cmd — $purpose"; return
  fi
  echo "  [未導入]   $cmd — $purpose"
  echo "             導入コマンド: $steps"
  # 自動実行コマンドが無い（手動導入のみ）なら提示で終わり
  [ -n "$autorun" ] || return
  # 非対話は提示のみ（自動実行しない）
  [ "${SDD_INSTALL_NONINTERACTIVE:-0}" = 1 ] && return
  printf "  今すぐ導入しますか? [y/N] (既定 N): "
  if ! read -r ans; then ans=""; fi     # EOF（非対話）は空＝既定N
  case "$ans" in
    y|Y|yes)
      if [ "${SDD_INSTALL_DRYRUN:-0}" = 1 ]; then
        echo "  DRYRUN: $autorun"
      else
        echo "  実行: $autorun"
        eval "$autorun"
      fi
      ;;
    *) echo "  スキップ（後で手動で導入してください）" ;;
  esac
}

echo "二次成果物レンダラの状態（本体は同梱していません。opt-in で取得してください）:"
if [ $# -gt 0 ]; then
  for n in "$@"; do process_one "$n"; done
else
  for n in $ALL; do process_one "$n"; done
fi
echo ""
echo "※ 未導入フォーマット/図は doc-export 実行時に「未生成（要 install-renderers）」として明示され、他成果物の生成は継続します。"
