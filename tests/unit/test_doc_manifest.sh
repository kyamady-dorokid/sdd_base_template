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

# --- manifest 不在時の既定（C-2: 存在する requirements/design/tasks を各1本 docx 全文） ---
SPECD="$TMP/spec"
mkdir -p "$SPECD"
: > "$SPECD/requirements.md"
: > "$SPECD/design.md"
: > "$SPECD/agreement-log.md"   # プロセス記録 → 既定対象外
# tasks.md は存在しない → 含まれないはず
defrecs=()
while IFS= read -r _line; do defrecs+=("$_line"); done < <(sdd_manifest_default "$SPECD")
assert_eq "2" "${#defrecs[@]}" "既定は存在する主要成果物のみ（requirements/design の2件）"
assert_eq "requirements.md|*|docx|" "${defrecs[0]}" "requirements.md を全文 docx"
assert_eq "design.md|*|docx|" "${defrecs[1]}" "design.md を全文 docx"
# tasks.md を作ると3件になり、プロセス記録(agreement-log)は含まれない
: > "$SPECD/tasks.md"
defrecs2=()
while IFS= read -r _line; do defrecs2+=("$_line"); done < <(sdd_manifest_default "$SPECD")
assert_eq "3" "${#defrecs2[@]}" "tasks.md 追加で3件（プロセス記録は対象外）"
assert_eq "tasks.md|*|docx|" "${defrecs2[2]}" "tasks.md を全文 docx"

rm -rf "$TMP"
