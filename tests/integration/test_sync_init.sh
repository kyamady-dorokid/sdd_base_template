DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SH="$DIR/../../payload/scripts/sync.sh"

TMP="$(mktemp -d)"
ROOT="$TMP/repo"
PAYLOAD="$TMP/payload"
mkdir -p "$ROOT" "$PAYLOAD/overlay/docs/sdd/rules" "$PAYLOAD/overlay/snippets" "$PAYLOAD/validation/patches"

( cd "$ROOT" && git init -q )
echo "workflow content v1" > "$PAYLOAD/overlay/docs/sdd/workflow.md"
echo "rule content v1" > "$PAYLOAD/overlay/docs/sdd/rules/testing-policy.md"

# 既存ファイル（init 済み想定。sync 初回化では一切変更されないはず）
mkdir -p "$ROOT/docs/sdd/rules"
echo "workflow content v1" > "$ROOT/docs/sdd/workflow.md"
echo "rule content v1" > "$ROOT/docs/sdd/rules/testing-policy.md"

bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/sync.log" 2>&1
rc=$?

assert_eq "0" "$rc" "初回 sync は正常終了する"
assert_file_exists "$ROOT/.kiro/sdd-base.lock" "lock ファイルが生成される"
assert_file_exists "$ROOT/.kiro/sdd-base-snapshot" "スナップショットディレクトリが生成される"
assert_file_exists "$ROOT/.kiro/sdd-base-snapshot/docs/sdd/workflow.md" "スナップショットに workflow.md が複製される"
assert_eq "workflow content v1" "$(cat "$ROOT/docs/sdd/workflow.md")" "初回化では既存ファイルが変更されない"
assert_file_exists "$ROOT/.kiro/sdd-base-update-report.md" "初回 sync でもレポートが出力される"

# 冪等性: lock 済みの状態で管理対象ファイルのハッシュが記録されている
source "$DIR/../../payload/scripts/sync_lib/lock.sh"
h="$(sdd_lock_get_file "$ROOT/.kiro/sdd-base.lock" "docs/sdd/workflow.md")"
assert_ne "" "$h" "lock に workflow.md のハッシュが記録される"

# 自動コミットしないこと
( cd "$ROOT" && git status --porcelain ) > "$TMP/gitstatus.txt"
assert_true "! grep -qE '^[MADRC]' '$TMP/gitstatus.txt'" "初回 sync はステージ済みの変更を作らない（自動コミットしない）"

rm -rf "$TMP"
