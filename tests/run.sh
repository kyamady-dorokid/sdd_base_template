#!/usr/bin/env bash
# run.sh — tests/test_*.sh を実行する最小限のテストランナー。
# 各テストファイルは source され、同一プロセス内で assert.sh のグローバルカウンタを共有する。
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/assert.sh"

TESTS_TOTAL=0
TESTS_FAILED=0

shopt -s nullglob 2>/dev/null || true
for f in "$DIR"/test_*.sh; do
  [ -e "$f" ] || continue
  echo "== $(basename "$f") =="
  source "$f"
done

echo ""
echo "Total: $TESTS_TOTAL, Failed: $TESTS_FAILED"
[ "$TESTS_FAILED" -eq 0 ]
