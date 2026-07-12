DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORT_SH="$DIR/../../payload/scripts/doc-export/export.sh"
source "$DIR/../../payload/scripts/sync_lib/hash.sh"

TMP="$(mktemp -d)"
ROOT="$TMP/repo"
SPEC="$ROOT/.kiro/specs/demo"
mkdir -p "$SPEC"
cat > "$SPEC/design.md" <<'EOS'
# Design

## API Contract
API 本文。

## Data Models
データモデル本文。
EOS

# ============ Part 1: 明示マニフェスト（混在＋エラー含む） ============
cat > "$SPEC/deliverables.manifest" <<'EOS'
design.md#API Contract -> uml
design.md#API Contract -> docx
design.md#Data Models -> pdf @pii
design.md#No Such Heading -> docx
EOS
src_hash_before="$(sdd_hash_file "$SPEC/design.md")"

bash "$EXPORT_SH" "$ROOT" "demo" > "$TMP/export.log" 2>&1
rc=$?
REPORT="$ROOT/outputs/demo/export-report.md"

assert_file_exists "$REPORT" "レポートが outputs/<id>/ に出力される"
# B-1b: 見出し不在エラーを含む → 非0
assert_ne "0" "$rc" "エラー（見出し不在）を含む実行は非0終了（B-1b）"
assert_contains "$REPORT" "見つかりません" "存在しない見出しはエラー報告される"
assert_file_absent "$ROOT/outputs/demo/design-No Such Heading.docx" "見出し不在で空の出力ファイルを作らない"
# 具体導入コマンド（DRY レジストリ由来）: docx=pandoc / uml=plantuml
assert_contains "$REPORT" "pandoc" "未生成の docx に pandoc 導入案内が付く"
assert_contains "$REPORT" "plantuml" "未生成の uml に plantuml 導入案内が付く"
# 出力先の明示（PII/非PII）
assert_contains "$REPORT" "outputs/demo/" "非PIIの出力先が明示される"
assert_contains "$REPORT" ".kiro/specs/demo/outputs/" "PIIの出力先が明示される"
assert_contains "$REPORT" "PII" "PII 隔離である旨が明示される"
# 正本不変
assert_eq "$src_hash_before" "$(sdd_hash_file "$SPEC/design.md")" "正本 md は書き換えられない"

# ============ Part 2: C-2 既定（マニフェスト無 → requirements/design/tasks） ============
SPEC2="$ROOT/.kiro/specs/c2"
mkdir -p "$SPEC2"
: > "$SPEC2/requirements.md"; : > "$SPEC2/design.md"; : > "$SPEC2/tasks.md"; : > "$SPEC2/agreement-log.md"
bash "$EXPORT_SH" "$ROOT" "c2" > "$TMP/c2.log" 2>&1
rc2=$?
REPORT2="$ROOT/outputs/c2/export-report.md"
assert_contains "$REPORT2" "requirements.md" "C-2 既定は requirements.md を対象にする"
assert_contains "$REPORT2" "design.md" "C-2 既定は design.md を対象にする"
assert_contains "$REPORT2" "tasks.md" "C-2 既定は tasks.md を対象にする"
assert_not_contains "$REPORT2" "agreement-log" "C-2 既定はプロセス記録を対象にしない"
# 未生成のみ（レンダラ未導入）でエラーなし → exit 0（B-1b）
assert_eq "0" "$rc2" "未生成のみ（エラーなし）は exit 0（B-1b）"

# ============ Part 3: spec-id 不在 → exit 1（B-3a） ============
bash "$EXPORT_SH" "$ROOT" "no_such_spec" > "$TMP/ne.log" 2>&1
assert_ne "0" "$?" "spec-id 不在は非0（exit 1）"

# ============ Part 4: Mermaid 未変換の明示（pandoc スタブ・mmdc 不在） ============
if ! command -v mmdc >/dev/null 2>&1; then
  SPEC3="$ROOT/.kiro/specs/mmd"
  mkdir -p "$SPEC3"
  cat > "$SPEC3/design.md" <<'EOS'
# D

## Fig
```mermaid
flowchart TD
  A --> B
```
EOS
  echo 'design.md#Fig -> docx' > "$SPEC3/deliverables.manifest"
  STUB="$TMP/stub"; mkdir -p "$STUB"
  cat > "$STUB/pandoc" <<'EOS'
#!/usr/bin/env bash
out=""; prev=""
for a in "$@"; do [ "$prev" = "-o" ] && out="$a"; prev="$a"; done
[ -n "$out" ] && : > "$out"; exit 0
EOS
  chmod +x "$STUB/pandoc"
  PATH="$STUB:$PATH" bash "$EXPORT_SH" "$ROOT" "mmd" > "$TMP/mmd.log" 2>&1
  REPORT3="$ROOT/outputs/mmd/export-report.md"
  assert_contains "$REPORT3" "未変換" "mmdc 不在時に Mermaid 未変換が明示される"
  assert_contains "$REPORT3" "mermaid-cli" "Mermaid 未変換に mmdc 導入コマンドが付く"
fi

rm -rf "$TMP"
