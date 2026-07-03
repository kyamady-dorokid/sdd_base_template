DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../../payload/scripts/doc-export/renderers.sh"

# フォーマット→レンダラ対応の参照
assert_eq "pandoc" "$(sdd_renderer_for docx)" "docx のレンダラは pandoc"
assert_eq "pandoc" "$(sdd_renderer_for pdf)" "pdf のレンダラは pandoc"
assert_eq "pandoc" "$(sdd_renderer_for pptx)" "pptx のレンダラは pandoc"
assert_eq "mmdc" "$(sdd_renderer_for mermaid)" "mermaid のレンダラは mmdc"

# 対応表にないフォーマットは空
assert_eq "" "$(sdd_renderer_for unknownfmt)" "未登録フォーマットは空を返す"

# 分類（core/limited/optional/external）
assert_eq "core" "$(sdd_renderer_class docx)" "docx は core"
assert_eq "external" "$(sdd_renderer_class xlsx)" "xlsx は external（別pkg）"

# 可用性検出: PATH に実行体があれば 0、無ければ非0。
# ダミーレンダラを PATH 先頭に置いて available、消して unavailable を検証する。
TMPBIN="$(mktemp -d)"
cat > "$TMPBIN/dummyrenderer" <<'EOS'
#!/usr/bin/env bash
exit 0
EOS
chmod +x "$TMPBIN/dummyrenderer"

# renderers.sh の可用性判定は "レンダラ実行体名" を command -v で見る。
# テスト用に汎用関数 sdd_renderer_available_cmd <cmd> を叩く。
PATH="$TMPBIN:$PATH" bash -c "source '$DIR/../../payload/scripts/doc-export/renderers.sh'; sdd_renderer_available_cmd dummyrenderer"
assert_eq "0" "$?" "PATH にある実行体は available（0）"

sdd_renderer_available_cmd definitely_not_a_real_binary_xyz
assert_ne "0" "$?" "PATH に無い実行体は unavailable（非0）"

# 重い本体を同梱していないこと（レジストリは検出のみ・payload にバイナリを置かない）
assert_true "! find '$DIR/../../payload' -type f -name 'pandoc' | grep -q ." "payload に pandoc 本体を同梱していない"
assert_true "! find '$DIR/../../payload' -type f -name 'mmdc' | grep -q ." "payload に mmdc 本体を同梱していない"

rm -rf "$TMPBIN"
