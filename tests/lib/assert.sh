#!/usr/bin/env bash
# assert.sh — 最小限のアサーションヘルパー。tests/run.sh が source する。
# TESTS_TOTAL / TESTS_FAILED はグローバルカウンタ（run.sh がテストファイルを source するため
# サブシェルにならず、そのまま加算できる）。

assert_eq(){
  local expected="$1" actual="$2" msg="${3:-}"
  TESTS_TOTAL=$((TESTS_TOTAL+1))
  if [ "$expected" = "$actual" ]; then
    echo "  [PASS] $msg"
  else
    echo "  [FAIL] $msg (expected='$expected' actual='$actual')"
    TESTS_FAILED=$((TESTS_FAILED+1))
  fi
}

assert_ne(){
  local a="$1" b="$2" msg="${3:-}"
  TESTS_TOTAL=$((TESTS_TOTAL+1))
  if [ "$a" != "$b" ]; then
    echo "  [PASS] $msg"
  else
    echo "  [FAIL] $msg (both='$a')"
    TESTS_FAILED=$((TESTS_FAILED+1))
  fi
}

assert_true(){
  local cond="$1" msg="${2:-}"
  TESTS_TOTAL=$((TESTS_TOTAL+1))
  if eval "$cond"; then
    echo "  [PASS] $msg"
  else
    echo "  [FAIL] $msg (condition: $cond)"
    TESTS_FAILED=$((TESTS_FAILED+1))
  fi
}

assert_file_exists(){
  local f="$1" msg="${2:-$f exists}"
  assert_true "[ -e '$f' ]" "$msg"
}

assert_file_absent(){
  local f="$1" msg="${2:-$f absent}"
  assert_true "[ ! -e '$f' ]" "$msg"
}

assert_contains(){
  local haystack_file="$1" needle="$2" msg="${3:-contains '$needle'}"
  assert_true "grep -qF -- '$needle' '$haystack_file'" "$msg"
}

assert_not_contains(){
  local haystack_file="$1" needle="$2" msg="${3:-does not contain '$needle'}"
  assert_true "! grep -qF -- '$needle' '$haystack_file'" "$msg"
}
