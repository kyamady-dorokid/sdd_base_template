#!/usr/bin/env bash
# doc-export/mermaid.sh — 正本内の ```mermaid ブロックを画像化して参照へ差し替える（D-1a）。
#
# sdd_mermaid_preprocess <in-md> <out-md> <asset-dir>
#   - mmdc 可用時: 各 ```mermaid ブロックを PNG（<asset-dir>/mermaid-N.png）へレンダリングし、
#     md 内を ![](<png>) 画像参照へ差し替える。
#   - mmdc 未導入 or 変換失敗時: **そのブロックを元のまま残す**（pandoc がコードブロックとして描画）。
#   - 標準出力に「未変換ブロック数」を返す（0=全変換 or 図なし）。サイレントに欠落させない。

sdd_mermaid_preprocess(){
  local in="$1" out="$2" assets="$3"
  local mmdc_ok=0
  command -v mmdc >/dev/null 2>&1 && mmdc_ok=1
  mkdir -p "$assets"

  local n=0 unconverted=0 in_block=0 block="" line
  : > "$out"
  while IFS= read -r line || [ -n "$line" ]; do
    if [ "$in_block" = 0 ]; then
      case "$line" in
        '```mermaid'*) in_block=1; block="" ;;
        *) printf '%s\n' "$line" >> "$out" ;;
      esac
    else
      case "$line" in
        '```'*)
          in_block=0; n=$((n+1))
          if [ "$mmdc_ok" = 1 ]; then
            local mmd="$assets/mermaid-$n.mmd" png="$assets/mermaid-$n.png"
            printf '%s' "$block" > "$mmd"
            if mmdc -i "$mmd" -o "$png" >/dev/null 2>&1 && [ -f "$png" ]; then
              printf '![mermaid-%s](%s)\n' "$n" "$png" >> "$out"
              rm -f "$mmd"
            else
              printf '```mermaid\n%s```\n' "$block" >> "$out"
              unconverted=$((unconverted+1))
            fi
          else
            printf '```mermaid\n%s```\n' "$block" >> "$out"
            unconverted=$((unconverted+1))
          fi
          ;;
        *) block="$block$line"$'\n' ;;
      esac
    fi
  done < "$in"

  # 閉じられていないブロックは元のまま残す（安全側）
  if [ "$in_block" = 1 ]; then
    printf '```mermaid\n%s' "$block" >> "$out"
  fi

  printf '%s' "$unconverted"
}
