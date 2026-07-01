#!/usr/bin/env bash
# sync_lib/hash.sh — sha256 計算ラッパー（Linux sha256sum / macOS shasum -a 256 を吸収）

sdd_hash_file(){
  local f="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$f" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" | awk '{print $1}'
  else
    echo "sdd_hash_file: sha256sum/shasum が見つかりません" >&2
    return 1
  fi
}

sdd_hash_string(){
  local s="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    printf '%s' "$s" | sha256sum | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    printf '%s' "$s" | shasum -a 256 | awk '{print $1}'
  else
    echo "sdd_hash_string: sha256sum/shasum が見つかりません" >&2
    return 1
  fi
}
