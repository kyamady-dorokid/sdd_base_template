#!/usr/bin/env bash
# sync_lib/merge.sh — ファイル全体 / マーカーブロック単位の3-wayマージ。
#
# 設計方針: いかなる場合もローカルファイルをサイレント上書きしない。
#   - クリーンマージ: 呼び出し元が結果を適用する（本関数自体は current を書き換えない）。
#   - コンフリクト: コンフリクトマーカー入りの内容を $out に書き出すのみ（呼び出し元が
#     `<file>.new` として保存するかを決める。既存ファイルには一切触れない）。

# sdd_merge_file <current> <base> <other> <out>
#   git merge-file -p は current/base/other を変更せず、結果を stdout に出す。
#   戻り値: 0=クリーンマージ成功 / 非0=コンフリクトあり（$out にはマーカー入り内容を書く）
sdd_merge_file(){
  local current="$1" base="$2" other="$3" out="$4"
  local tmp="${out}.merging.$$"
  local status=0
  git merge-file -p "$current" "$base" "$other" > "$tmp" 2>/dev/null || status=$?
  mv "$tmp" "$out"
  return "$status"
}

# sdd_extract_block <file> <marker>
#   "<!-- <marker>:START -->" 〜 "<!-- <marker>:END -->" の間（両端の行を含まない）を stdout に出す。
#   マーカーが見つからない場合は非0を返す。
sdd_extract_block(){
  local file="$1" marker="$2"
  awk -v m="$marker" '
    $0 ~ (m ":START") { infile=1; found=1; next }
    $0 ~ (m ":END")   { infile=0 }
    infile { print }
    END { if (!found) exit 1 }
  ' "$file"
}

# sdd_replace_block <file> <marker> <new_content_file> <out>
#   START/END の行自体はそのまま残し、その間の内容だけを new_content_file の内容に差し替える。
#   マーカー外のコンテンツ（前後）は一切変更しない。
sdd_replace_block(){
  local file="$1" marker="$2" new_content="$3" out="$4"
  awk -v m="$marker" -v ncfile="$new_content" '
    BEGIN{
      n=0
      while ((getline line < ncfile) > 0) { n++; nc[n]=line }
      close(ncfile)
    }
    $0 ~ (m ":START") {
      print
      for (i=1;i<=n;i++) print nc[i]
      skip=1
      next
    }
    $0 ~ (m ":END") { skip=0 }
    skip { next }
    { print }
  ' "$file" > "$out"
}
