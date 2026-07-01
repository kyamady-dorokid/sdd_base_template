DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../scripts/sync_lib/hash.sh"
source "$DIR/../scripts/sync_lib/merge.sh"

TMP="$(mktemp -d)"

# --- ファイル全体3-wayマージ: クリーンケース ---
printf 'line1\nline2\nline3\n' > "$TMP/base.txt"
printf 'line1-local\nline2\nline3\n' > "$TMP/current.txt"
printf 'line1\nline2\nline3-upstream\n' > "$TMP/other.txt"

out="$TMP/out.txt"
sdd_merge_file "$TMP/current.txt" "$TMP/base.txt" "$TMP/other.txt" "$out"
rc=$?
assert_eq "0" "$rc" "非競合の3-wayマージは成功する(exit 0)"
assert_contains "$out" "line1-local" "ローカル変更が保持される"
assert_contains "$out" "line3-upstream" "上流変更が取り込まれる"

# 元ファイルは変更されない（sdd_merge_file は current を直接書き換えない）
assert_true "! grep -qF 'line3-upstream' '$TMP/current.txt'" "current.txt 自体は変更されない"

# --- ファイル全体3-wayマージ: コンフリクトケース ---
printf 'line1\n' > "$TMP/base2.txt"
printf 'line1-local\n' > "$TMP/current2.txt"
printf 'line1-upstream\n' > "$TMP/other2.txt"
out2="$TMP/current2.txt.new"
sdd_merge_file "$TMP/current2.txt" "$TMP/base2.txt" "$TMP/other2.txt" "$out2"
rc2=$?
assert_true "[ $rc2 -ne 0 ]" "競合時は非0を返す"
assert_file_exists "$out2" "競合時は <file>.new が生成される"
assert_contains "$out2" "<<<<<<<" "生成物にコンフリクトマーカーが含まれる"
assert_eq "line1-local" "$(cat "$TMP/current2.txt")" "競合時に元ファイルは無変更のまま"

# --- マーカーブロック抽出 ---
cat > "$TMP/marker_file.md" <<'EOS'
before
<!-- MYMARKER:START -->
block content line1
block content line2
<!-- MYMARKER:END -->
after
EOS

extracted="$(sdd_extract_block "$TMP/marker_file.md" "MYMARKER")"
assert_eq "$(printf 'block content line1\nblock content line2')" "$extracted" "マーカーブロックの抽出内容が一致"

# マーカーが無いファイルは失敗する
printf 'no marker here\n' > "$TMP/no_marker.md"
sdd_extract_block "$TMP/no_marker.md" "MYMARKER" > /dev/null 2>&1
assert_true "[ $? -ne 0 ]" "マーカー不在ファイルの抽出は失敗する"

# --- マーカーブロック置換（周囲コンテンツは変更しない） ---
printf 'new block content\n' > "$TMP/newblock.txt"
replaced="$TMP/replaced.md"
sdd_replace_block "$TMP/marker_file.md" "MYMARKER" "$TMP/newblock.txt" "$replaced"
assert_contains "$replaced" "before" "ブロック外の前方コンテンツは維持される"
assert_contains "$replaced" "after" "ブロック外の後方コンテンツは維持される"
assert_contains "$replaced" "new block content" "ブロック内容が新しい内容に置き換わる"
assert_not_contains "$replaced" "block content line1" "旧ブロック内容は残らない"

rm -rf "$TMP"
