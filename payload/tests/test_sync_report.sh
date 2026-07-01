DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SH="$DIR/../scripts/sync.sh"

TMP="$(mktemp -d)"
ROOT="$TMP/repo"
PAYLOAD="$TMP/payload"
mkdir -p "$ROOT" "$PAYLOAD/overlay/docs/sdd/rules" "$PAYLOAD/overlay/snippets" "$PAYLOAD/validation/patches"
( cd "$ROOT" && git init -q )
echo "v1" > "$PAYLOAD/overlay/docs/sdd/workflow.md"

bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/sync.log" 2>&1

REPORT="$ROOT/.kiro/sdd-base-update-report.md"
assert_file_exists "$REPORT" "レポートファイルが生成される"
assert_contains "$REPORT" "新規適用" "レポートに「新規適用」カテゴリの見出しがある"
assert_contains "$REPORT" "クリーンマージ" "レポートに「クリーンマージ」カテゴリの見出しがある"
assert_contains "$REPORT" "コンフリクト" "レポートに「コンフリクト」カテゴリの見出しがある"
assert_contains "$REPORT" "上流で削除" "レポートに「上流で削除」カテゴリの見出しがある"

( cd "$ROOT" && git status --porcelain ) > "$TMP/gitstatus.txt"
assert_true "! grep -qE '^[MADRC]' '$TMP/gitstatus.txt'" "sync 実行後も自動コミット（ステージ）は発生しない"

rm -rf "$TMP"
