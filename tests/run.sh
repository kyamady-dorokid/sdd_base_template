#!/usr/bin/env bash
# run.sh — tests/{unit,integration}/test_*.sh を実行する最小限のテストランナー。
# 各テストファイルは source され、同一プロセス内で assert.sh のグローバルカウンタを共有する。
set -uo pipefail
# 注意: RUNNER_DIR は各 test_*.sh が自身の DIR を再代入しても壊れないよう、
# run.sh 専用の変数名にする（DIR という名前は sourced テスト側と衝突する）。
RUNNER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$RUNNER_DIR/lib/assert.sh"

TESTS_TOTAL=0
TESTS_FAILED=0

shopt -s nullglob 2>/dev/null || true

run_group(){
  local label="$1" dir="$2" f
  [ -d "$dir" ] || return 0
  for f in "$dir"/test_*.sh; do
    [ -e "$f" ] || continue
    echo "== [$label] $(basename "$f") =="
    source "$f"
  done
}

run_group "unit" "$RUNNER_DIR/unit"
run_group "integration" "$RUNNER_DIR/integration"

echo ""
echo "Total: $TESTS_TOTAL, Failed: $TESTS_FAILED"
[ "$TESTS_FAILED" -eq 0 ]
