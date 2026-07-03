DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../../payload/scripts/doc-export/manifest.sh"

TMP="$(mktemp -d)"

# --- 宣言行のパース ---
# 形式: <source-md>#<section|*> -> <format> [@pii]
cat > "$TMP/deliverables.manifest" <<'EOS'
# コメント行は無視
design.md#api-contract -> docx
design.md -> pdf
requirements.md#* -> pptx @pii

EOS

# パース結果を1行1レコード "source|section|format|pii" で取得
# （bash 3.2 互換のため mapfile は使わず while-read で配列化）
recs=()
while IFS= read -r _line; do recs+=("$_line"); done < <(sdd_manifest_parse "$TMP/deliverables.manifest")

assert_eq "3" "${#recs[@]}" "空行・コメントを除き3レコード"
assert_eq "design.md|api-contract|docx|" "${recs[0]}" "節指定つき docx をパース"
assert_eq "design.md|*|pdf|" "${recs[1]}" "節省略は全文(*)扱いでパース"
assert_eq "requirements.md|*|pptx|pii" "${recs[2]}" "@pii フラグをパース"

# --- 個別フィールド抽出ヘルパ ---
assert_eq "design.md" "$(sdd_manifest_field "${recs[0]}" source)" "source 抽出"
assert_eq "api-contract" "$(sdd_manifest_field "${recs[0]}" section)" "section 抽出"
assert_eq "docx" "$(sdd_manifest_field "${recs[0]}" format)" "format 抽出"
assert_eq "pii" "$(sdd_manifest_field "${recs[2]}" pii)" "pii 抽出"
assert_eq "" "$(sdd_manifest_field "${recs[0]}" pii)" "pii なしは空"

# --- manifest 不在時の既定フォールバック ---
# 既定は「<primary-md> -> docx」（primary が指定される）。
defrecs=()
while IFS= read -r _line; do defrecs+=("$_line"); done < <(sdd_manifest_default "design.md")
assert_eq "1" "${#defrecs[@]}" "既定は1レコード"
assert_eq "design.md|*|docx|" "${defrecs[0]}" "既定は全文 docx"

rm -rf "$TMP"
