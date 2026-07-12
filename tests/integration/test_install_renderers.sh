DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INS="$DIR/../../payload/scripts/doc-export/install-renderers.sh"

TMP="$(mktemp -d)"

# 前提: この環境で mmdc は未導入（未導入時の挙動を検証）
if command -v mmdc >/dev/null 2>&1; then
  echo "  [INFO] mmdc が導入済みのためスキップ" ; rm -rf "$TMP"; return 0 2>/dev/null || true
fi

# --- 非対話: 提示のみ・自動実行しない ---
SDD_INSTALL_NONINTERACTIVE=1 bash "$INS" mmdc > "$TMP/o1" 2>&1
assert_contains "$TMP/o1" "npm i -g @mermaid-js/mermaid-cli" "レジストリ由来の導入コマンドを表示する"
assert_not_contains "$TMP/o1" "今すぐ導入" "非対話ではプロンプトを出さない"
assert_not_contains "$TMP/o1" "実行:" "非対話では自動実行しない"

# --- y 分岐（DRYRUN・実導入しない） ---
printf 'y\n' | SDD_INSTALL_DRYRUN=1 bash "$INS" mmdc > "$TMP/o2" 2>&1
assert_contains "$TMP/o2" "DRYRUN: npm i -g @mermaid-js/mermaid-cli" "y でも DRYRUN で実導入せずコマンドを示す"
assert_true "! command -v mmdc >/dev/null 2>&1" "テスト後も mmdc は実導入されていない"

# --- n 分岐: スキップ ---
printf 'n\n' | bash "$INS" mmdc > "$TMP/o3" 2>&1
assert_contains "$TMP/o3" "スキップ" "n で導入をスキップする"

# --- 手動のみ（pandoc: 自動実行コマンド無し）は y でも実行分岐に入らない ---
printf 'y\n' | SDD_INSTALL_DRYRUN=1 bash "$INS" pandoc > "$TMP/o4" 2>&1
assert_not_contains "$TMP/o4" "DRYRUN:" "自動実行コマンドが無い pandoc は実行分岐に入らない（提示のみ）"

rm -rf "$TMP"
