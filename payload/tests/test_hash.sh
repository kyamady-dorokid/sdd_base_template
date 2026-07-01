DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../scripts/sync_lib/hash.sh"

TMP="$(mktemp -d)"

echo "hello" > "$TMP/a.txt"
echo "hello" > "$TMP/b.txt"
echo "world" > "$TMP/c.txt"

h1="$(sdd_hash_file "$TMP/a.txt")"
h2="$(sdd_hash_file "$TMP/b.txt")"
h3="$(sdd_hash_file "$TMP/c.txt")"

assert_eq "$h1" "$h2" "同一内容のファイルは同一ハッシュ"
assert_ne "$h1" "$h3" "異なる内容のファイルは異なるハッシュ"
assert_true "[ \${#h1} -eq 64 ]" "sha256 相当（64桁hex）"

s1="$(sdd_hash_string "hello")"
s2="$(sdd_hash_string "hello")"
s3="$(sdd_hash_string "world")"
assert_eq "$s1" "$s2" "同一文字列は同一ハッシュ（sdd_hash_string）"
assert_ne "$s1" "$s3" "異なる文字列は異なるハッシュ（sdd_hash_string）"

if ! command -v sha256sum >/dev/null 2>&1; then
  echo "  [INFO] sha256sum 不在環境（shasum フォールバック経路を自然に検証）"
  assert_true "command -v shasum >/dev/null 2>&1" "shasum が利用可能（フォールバック先）"
fi

rm -rf "$TMP"
