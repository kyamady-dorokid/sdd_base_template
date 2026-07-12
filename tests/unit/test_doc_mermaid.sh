DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../../payload/scripts/doc-export/mermaid.sh"

TMP="$(mktemp -d)"
IN="$TMP/in.md"
cat > "$IN" <<'EOS'
# Doc

前段。

```mermaid
flowchart TD
  A --> B
```

中段。

```mermaid
sequenceDiagram
  A->>B: hi
```

後段。
EOS

# --- mmdc 未導入時: ブロックは元のまま残り、未変換件数=2 ---
OUT="$TMP/out_nommdc.md"
# mmdc を確実に不在にするため PATH を最小化して実行
count="$(PATH=/usr/bin:/bin sdd_mermaid_preprocess "$IN" "$OUT" "$TMP/assets_a")"
assert_eq "2" "$count" "mmdc 未導入時は未変換件数を返す（2件）"
assert_contains "$OUT" '```mermaid' "mmdc 未導入時は mermaid フェンスを元のまま残す"
assert_contains "$OUT" "flowchart TD" "図の元コードが保全される"
assert_contains "$OUT" "前段。" "本文（前段）は維持"
assert_contains "$OUT" "後段。" "本文（後段）は維持"

# --- mmdc 可用時（スタブ）: 画像参照に差し替わり、未変換件数=0 ---
STUBBIN="$TMP/stubbin"; mkdir -p "$STUBBIN"
cat > "$STUBBIN/mmdc" <<'EOS'
#!/usr/bin/env bash
# 引数 -i <in> -o <out> を受け、out に空PNG相当を書く簡易スタブ
out=""
while [ $# -gt 0 ]; do case "$1" in -o) out="$2"; shift 2;; *) shift;; esac; done
: > "$out"
EOS
chmod +x "$STUBBIN/mmdc"
OUT2="$TMP/out_mmdc.md"
count2="$(PATH="$STUBBIN:/usr/bin:/bin" sdd_mermaid_preprocess "$IN" "$OUT2" "$TMP/assets_b")"
assert_eq "0" "$count2" "mmdc 可用時は未変換件数0"
assert_not_contains "$OUT2" '```mermaid' "mmdc 可用時は mermaid フェンスが残らない"
assert_contains "$OUT2" "![" "画像参照(![...])へ差し替わる"
assert_true "ls '$TMP/assets_b'/mermaid-*.png >/dev/null 2>&1" "画像アセットが生成される"
assert_contains "$OUT2" "前段。" "本文は維持（mmdc可用時）"

rm -rf "$TMP"
