DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SH="$DIR/../payload/scripts/sync.sh"
source "$DIR/../payload/scripts/sync_lib/hash.sh"
source "$DIR/../payload/scripts/sync_lib/lock.sh"

TMP="$(mktemp -d)"
ROOT="$TMP/repo"
PAYLOAD="$TMP/payload"
mkdir -p "$ROOT" "$PAYLOAD/overlay/docs/sdd/rules" "$PAYLOAD/overlay/snippets" "$PAYLOAD/validation/patches"

( cd "$ROOT" && git init -q )

# v1 payload
echo "workflow v1" > "$PAYLOAD/overlay/docs/sdd/workflow.md"
echo "unchanged v1" > "$PAYLOAD/overlay/docs/sdd/rules/testing-policy.md"
echo "conflict v1" > "$PAYLOAD/overlay/docs/sdd/rules/branching-policy.md"

mkdir -p "$ROOT/docs/sdd/rules" "$ROOT/.kiro/specs/my-task" "$ROOT/.kiro/steering"
echo "workflow v1" > "$ROOT/docs/sdd/workflow.md"
echo "unchanged v1" > "$ROOT/docs/sdd/rules/testing-policy.md"
echo "conflict v1" > "$ROOT/docs/sdd/rules/branching-policy.md"
echo "my protected spec" > "$ROOT/.kiro/specs/my-task/agreement-log.md"
echo "my steering memo" > "$ROOT/.kiro/steering/product.md"

# 初回 sync（lock/snapshot 作成のみ）
bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/sync1.log" 2>&1

# --- ここからローカル変更 + 上流更新 ---
# workflow.md: ローカル未変更のまま → 上流のみ更新（そのまま更新されるはず）
echo "workflow v2 upstream" > "$PAYLOAD/overlay/docs/sdd/workflow.md"

# testing-policy.md: ローカルは無変更、上流も無変更 → 何も起きない
# (そのまま。何もしない)

# branching-policy.md: ローカル・上流の両方が同じ行を別内容に変更 → コンフリクト
echo "conflict LOCAL" > "$ROOT/docs/sdd/rules/branching-policy.md"
echo "conflict UPSTREAM" > "$PAYLOAD/overlay/docs/sdd/rules/branching-policy.md"

# 2回目 sync（差分適用ルート）
bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/sync2.log" 2>&1
rc=$?
assert_eq "0" "$rc" "2回目 sync も正常終了する（コンフリクトはエラー扱いしない）"

assert_eq "workflow v2 upstream" "$(cat "$ROOT/docs/sdd/workflow.md")" "ローカル未変更ファイルは新版でそのまま更新される"

assert_eq "conflict LOCAL" "$(cat "$ROOT/docs/sdd/rules/branching-policy.md")" "コンフリクト時、既存ローカルファイルは無変更のまま"
assert_file_exists "$ROOT/docs/sdd/rules/branching-policy.md.new" "コンフリクト時は <file>.new が出力される"
assert_contains "$ROOT/docs/sdd/rules/branching-policy.md.new" "<<<<<<<" "<file>.new にコンフリクトマーカーが含まれる"

assert_eq "my protected spec" "$(cat "$ROOT/.kiro/specs/my-task/agreement-log.md")" ".kiro/specs 配下は一切変更されない"
assert_eq "my steering memo" "$(cat "$ROOT/.kiro/steering/product.md")" ".kiro/steering 配下は一切変更されない"

assert_contains "$ROOT/.kiro/sdd-base-update-report.md" "workflow.md" "レポートに更新ファイルが記載される"
assert_contains "$ROOT/.kiro/sdd-base-update-report.md" "branching-policy.md" "レポートにコンフリクトファイルが記載される"

# --- 上流で削除されたファイル ---
rm "$PAYLOAD/overlay/docs/sdd/rules/testing-policy.md"
bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/sync3.log" 2>&1
assert_file_exists "$ROOT/docs/sdd/rules/testing-policy.md" "上流で削除されたファイルはローカルから自動削除されない"
assert_contains "$ROOT/.kiro/sdd-base-update-report.md" "testing-policy.md" "上流削除の旨がレポートに記載される"

rm -rf "$TMP"
