#!/usr/bin/env bash
# doc-export/slice.sh — 正本 md から見出し節を抽出（節スライス）。
#
# sdd_slice <md> <heading-or-*>
#   - "*" または空: 全文をそのまま出力（全文変換のフォールバック）。
#   - 見出しテキスト: その見出し行から、次の「同レベル以下（同じか浅い #）」の見出しの直前までを出力。
#     配下のより深い小見出しは含む。見出し行自体を含む。
#   - 指定見出しが存在しない場合: 何も出力せず非0 を返す（空ファイルを作らせない）。

sdd_slice(){
  local md="$1" heading="$2"
  [ -f "$md" ] || return 2

  if [ -z "$heading" ] || [ "$heading" = "*" ]; then
    cat "$md"
    return 0
  fi

  awk -v h="$heading" '
    function heading_level(line,   n) {
      n = 0
      while (substr(line, n+1, 1) == "#") n++
      return n
    }
    BEGIN { found = 0; capturing = 0; level = 0 }
    {
      # 見出し行か？
      if ($0 ~ /^#+[ \t]/) {
        # 見出しテキスト（先頭 # と空白を除去）を取り出す
        text = $0
        sub(/^#+[ \t]+/, "", text)
        sub(/[ \t]+$/, "", text)
        lvl = heading_level($0)
        if (!capturing) {
          if (text == h) {
            found = 1
            capturing = 1
            level = lvl
            print
            next
          }
        } else {
          # キャプチャ中に同レベル以下（浅いか同じ）の見出しが来たら終了
          if (lvl <= level) {
            capturing = 0
            exit
          }
          print
          next
        }
      }
      if (capturing) print
    }
    END { if (!found) exit 3 }
  ' "$md"
}
