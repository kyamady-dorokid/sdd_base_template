#!/usr/bin/env bash
# doc-export/manifest.sh — deliverables.manifest のパースと既定値。
#
# マニフェスト形式（行指向・`#` コメント可・空行無視）:
#   <source-md>#<section-anchor|*> -> <format> [@pii]
#   例: design.md#api-contract -> docx
#       design.md -> pdf
#       requirements.md#* -> pptx @pii
#
# パース結果は 1 行 1 レコード "source|section|format|pii" で出力する
# （section 省略時は "*"、@pii 付与時は pii フィールドに "pii"）。

sdd_manifest_parse(){
  local file="$1" line src section fmt pii rest
  [ -f "$file" ] || return 0
  while IFS= read -r line || [ -n "$line" ]; do
    # コメント・空行を除去
    case "$line" in
      '#'*) continue ;;
    esac
    [ -n "${line// /}" ] || continue
    # "<left> -> <right>" に分割
    case "$line" in
      *"->"*) ;;
      *) continue ;;
    esac
    local left right
    left="${line%%->*}"
    right="${line#*->}"
    # 前後空白を除去
    left="$(printf '%s' "$left" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    right="$(printf '%s' "$right" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    # left = source[#section]
    case "$left" in
      *'#'*) src="${left%%#*}"; section="${left#*#}" ;;
      *)     src="$left"; section="*" ;;
    esac
    [ -n "$section" ] || section="*"
    # right = format [@pii]
    pii=""
    case "$right" in
      *"@pii"*) pii="pii"; right="${right%%@pii*}" ;;
    esac
    fmt="$(printf '%s' "$right" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    printf '%s|%s|%s|%s\n' "$src" "$section" "$fmt" "$pii"
  done < "$file"
}

# レコード "source|section|format|pii" から個別フィールドを取り出す
sdd_manifest_field(){
  local rec="$1" field="$2"
  local src section fmt pii
  IFS='|' read -r src section fmt pii <<< "$rec"
  case "$field" in
    source) printf '%s' "$src" ;;
    section) printf '%s' "$section" ;;
    format) printf '%s' "$fmt" ;;
    pii) printf '%s' "$pii" ;;
  esac
}

# manifest 不在時の既定（C-2）: 対象 spec に存在する主要成果物 md
#   （requirements.md / design.md / tasks.md）を各1行、全文 → docx で返す。
#   agreement-log.md / test-results.md 等のプロセス記録は既定対象外。
sdd_manifest_default(){
  local spec_dir="${1:?spec-dir required}" f
  for f in requirements.md design.md tasks.md; do
    [ -f "$spec_dir/$f" ] && printf '%s|*|docx|\n' "$f"
  done
}
