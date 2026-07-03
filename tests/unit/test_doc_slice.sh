DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../../payload/scripts/doc-export/slice.sh"

TMP="$(mktemp -d)"
SRC="$TMP/design.md"
cat > "$SRC" <<'EOS'
# Design

## Overview
概要の本文。

## API Contract
API の本文1。
API の本文2。

### Sub of API
サブ節。

## Data Models
データモデル本文。
EOS

# --- 見出しテキストで節抽出（その見出し配下・次の同レベル以上の見出しまで） ---
out="$(sdd_slice "$SRC" "API Contract")"
echo "$out" > "$TMP/out.md"
assert_contains "$TMP/out.md" "API の本文1" "指定節の本文を含む"
assert_contains "$TMP/out.md" "サブ節" "指定節配下のサブ節も含む"
assert_not_contains "$TMP/out.md" "概要の本文" "前の節（Overview）は含まない"
assert_not_contains "$TMP/out.md" "データモデル本文" "次の同レベル節（Data Models）は含まない"

# --- 見出し行自体を含む ---
assert_contains "$TMP/out.md" "## API Contract" "抽出結果は見出し行を含む"

# --- 全文指定（*） ---
full="$(sdd_slice "$SRC" '*')"
echo "$full" > "$TMP/full.md"
assert_contains "$TMP/full.md" "概要の本文" "全文(*)は全節を含む(Overview)"
assert_contains "$TMP/full.md" "データモデル本文" "全文(*)は全節を含む(Data Models)"

# --- 見出し不在はエラー（非0）＋標準出力を出さない ---
missing="$(sdd_slice "$SRC" "No Such Heading" 2>/dev/null)"
rc=$?
assert_ne "0" "$rc" "存在しない見出しは非0を返す"
assert_eq "" "$missing" "存在しない見出しは本文を出力しない（空生成防止）"

rm -rf "$TMP"
