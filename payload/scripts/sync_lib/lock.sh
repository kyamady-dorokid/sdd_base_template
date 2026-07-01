#!/usr/bin/env bash
# sync_lib/lock.sh — .kiro/sdd-base.lock の読み書き（行指向・JSON非依存）。
#
# 書式:
#   template_commit=<sha>
#   template_repo=<url>
#   file:<path>:<sha256>
#   block:<file>:<marker>:<sha256>
#
# bash 3.2 には連想配列が無いため、grep/awk による素朴なテキスト操作で完結させる
# （行指向フラット形式を採用した設計理由と一貫）。

SDD_TEMPLATE_REPO_FALLBACK="https://github.com/kyamady-dorokid/sdd_base_template"

# --- meta (template_commit=..., template_repo=...) ---

sdd_lock_get_meta(){
  local lockfile="$1" key="$2"
  [ -f "$lockfile" ] || return 0
  local prefix="${key}="
  awk -v pre="$prefix" 'index($0,pre)==1{print substr($0,length(pre)+1)}' "$lockfile" | tail -n1
}

sdd_lock_set_meta(){
  local lockfile="$1" key="$2" val="$3"
  local prefix="${key}="
  local tmp="${lockfile}.tmp.$$"
  touch "$lockfile"
  awk -v pre="$prefix" 'index($0,pre)!=1' "$lockfile" > "$tmp"
  echo "${prefix}${val}" >> "$tmp"
  mv "$tmp" "$lockfile"
}

# --- file:<path>:<hash> ---

sdd_lock_get_file(){
  local lockfile="$1" path="$2"
  [ -f "$lockfile" ] || return 0
  local prefix="file:${path}:"
  awk -v pre="$prefix" 'index($0,pre)==1{print substr($0,length(pre)+1)}' "$lockfile" | tail -n1
}

sdd_lock_set_file(){
  local lockfile="$1" path="$2" hash="$3"
  local prefix="file:${path}:"
  local tmp="${lockfile}.tmp.$$"
  touch "$lockfile"
  awk -v pre="$prefix" 'index($0,pre)!=1' "$lockfile" > "$tmp"
  echo "${prefix}${hash}" >> "$tmp"
  mv "$tmp" "$lockfile"
}

# --- block:<file>:<marker>:<hash> ---

sdd_lock_get_block(){
  local lockfile="$1" file="$2" marker="$3"
  [ -f "$lockfile" ] || return 0
  local prefix="block:${file}:${marker}:"
  awk -v pre="$prefix" 'index($0,pre)==1{print substr($0,length(pre)+1)}' "$lockfile" | tail -n1
}

sdd_lock_set_block(){
  local lockfile="$1" file="$2" marker="$3" hash="$4"
  local prefix="block:${file}:${marker}:"
  local tmp="${lockfile}.tmp.$$"
  touch "$lockfile"
  awk -v pre="$prefix" 'index($0,pre)!=1' "$lockfile" > "$tmp"
  echo "${prefix}${hash}" >> "$tmp"
  mv "$tmp" "$lockfile"
}

# --- template_commit の解決（取得不可時は固定URLへフォールバック） ---

sdd_lock_resolve_commit(){
  local payload_dir="$1"
  local sha=""
  sha="$(git -C "$payload_dir" rev-parse HEAD 2>/dev/null)" || sha=""
  if [ -n "$sha" ]; then
    printf '%s' "$sha"
  else
    printf 'unknown (fallback: %s)' "$SDD_TEMPLATE_REPO_FALLBACK"
  fi
}
