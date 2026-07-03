DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_SH="$DIR/../../payload/scripts/doc-export/export.sh"
source "$DIR/../../payload/scripts/sync_lib/hash.sh"

TMP="$(mktemp -d)"
ROOT="$TMP/repo"
SPEC="$ROOT/.kiro/specs/demo"
mkdir -p "$SPEC"

cat > "$SPEC/design.md" <<'EOS'
# Design

## API Contract
API 本文。

## Data Models
データモデル本文。
EOS

# マニフェスト:
#  - uml は plantuml（テスト環境に存在しない前提）→ 未生成（要install）になるはず
#  - docx（通常・非PII）→ 予定出力先は直下 outputs/demo/
#  - pdf @pii → 予定出力先は .kiro/specs/demo/outputs/
#  - 存在しない見出し → エラー（空生成しない）
cat > "$SPEC/deliverables.manifest" <<'EOS'
design.md#API Contract -> uml
design.md#API Contract -> docx
design.md#Data Models -> pdf @pii
design.md#No Such Heading -> docx
EOS

src_hash_before="$(sdd_hash_file "$SPEC/design.md")"

bash "$EXPORT_SH" "$ROOT" "demo" > "$TMP/export.log" 2>&1

REPORT="$ROOT/outputs/demo/export-report.md"
assert_file_exists "$REPORT" "レポートが outputs/<id>/ に出力される"

# レンダラ未導入（plantuml）は「未生成（要 install）」として明示され、後続処理は継続する
assert_contains "$REPORT" "未生成" "未導入レンダラは未生成として明示される"
assert_contains "$REPORT" "install-renderers" "未生成には install-renderers の案内が付く"

# 出力先の明示（非PII=直下 outputs/、PII=spec 直下）
assert_contains "$REPORT" "outputs/demo/" "非PIIの出力先（直下 outputs/）が明示される"
assert_contains "$REPORT" ".kiro/specs/demo/outputs/" "PIIの出力先（spec直下）が明示される"
assert_contains "$REPORT" "PII" "PII 隔離である旨が明示される"

# 見出し不在はエラーとして報告され、空ファイルを作らない
assert_contains "$REPORT" "見つかりません" "存在しない見出しはエラー報告される"
assert_file_absent "$ROOT/outputs/demo/design-No Such Heading.docx" "見出し不在で空の出力ファイルを作らない"

# 正本(md)は不変
assert_eq "$src_hash_before" "$(sdd_hash_file "$SPEC/design.md")" "正本 md は書き換えられない"

# 全4レコードが処理され、後続が打ち切られていない（uml失敗後もdocx/pdf/エラーが出る）
assert_contains "$REPORT" "uml" "レコード1(uml)が処理される"
assert_contains "$REPORT" "pdf" "レコード3(pdf@pii)が処理される"

rm -rf "$TMP"
