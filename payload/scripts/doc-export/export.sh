#!/usr/bin/env bash
# doc-export/export.sh — 二次成果物生成の統括。
# 使い方: export.sh <repo_root> <spec-id> [--manifest <path>]
#
# 設計方針（design.md 準拠）:
#  - 正本(md)は読むのみ・書き換えない。二次成果物は outputs 系にのみ書く。
#  - レンダラ未導入は想定内スキップ（他成果物は継続）。見出し不在はエラー（空生成しない）。
#  - 出力先を必ず明示（PII は .kiro/specs/<id>/outputs/、それ以外は直下 outputs/<id>/）。
#  - 自動コミットしない。
set -uo pipefail
ROOT="${1:?repo_root required}"; SPEC_ID="${2:?spec-id required}"; shift 2 || true
MANIFEST_OVERRIDE=""
while [ $# -gt 0 ]; do case "$1" in
  --manifest) MANIFEST_OVERRIDE="$2"; shift 2;;
  --manifest=*) MANIFEST_OVERRIDE="${1#*=}"; shift;;
  *) shift;;
esac; done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/renderers.sh"
source "$SCRIPT_DIR/manifest.sh"
source "$SCRIPT_DIR/slice.sh"

SPEC_DIR="$ROOT/.kiro/specs/$SPEC_ID"
BUILD_OUT="$ROOT/outputs/$SPEC_ID"                 # ビルド成果物
PII_OUT="$SPEC_DIR/outputs"                        # PII 隔離
[ -d "$SPEC_DIR" ] || { echo "spec が見つかりません: $SPEC_DIR" >&2; exit 1; }
mkdir -p "$BUILD_OUT"
REPORT="$BUILD_OUT/export-report.md"

fmt_ext(){ case "$1" in docx) echo docx;; pdf) echo pdf;; pptx) echo pptx;; xlsx) echo xlsx;; uml|mermaid) echo png;; *) echo "$1";; esac; }

# マニフェスト決定（override > spec 内 > 既定）
MANIFEST="$MANIFEST_OVERRIDE"
[ -z "$MANIFEST" ] && [ -f "$SPEC_DIR/deliverables.manifest" ] && MANIFEST="$SPEC_DIR/deliverables.manifest"

records=()
if [ -n "$MANIFEST" ] && [ -f "$MANIFEST" ]; then
  while IFS= read -r r; do [ -n "$r" ] && records+=("$r"); done < <(sdd_manifest_parse "$MANIFEST")
else
  primary="design.md"
  [ -f "$SPEC_DIR/design.md" ] || primary="requirements.md"
  while IFS= read -r r; do [ -n "$r" ] && records+=("$r"); done < <(sdd_manifest_default "$primary")
fi

# レポート初期化
{
  echo "# doc-export 実行レポート: $SPEC_ID"
  echo ""
  echo "- 正本(md)は読み取りのみ。二次成果物は再生成可能なビルド出力です（手編集禁止）。"
  echo ""
  echo "## 成果物ごとの結果"
} > "$REPORT"

emit(){ echo "$1"; echo "- $1" >> "$REPORT"; }

GEN=0; SKIP=0; ERR=0
for rec in ${records[@]+"${records[@]}"}; do
  src="$(sdd_manifest_field "$rec" source)"
  section="$(sdd_manifest_field "$rec" section)"
  fmt="$(sdd_manifest_field "$rec" format)"
  pii="$(sdd_manifest_field "$rec" pii)"
  srcpath="$SPEC_DIR/$src"
  ext="$(fmt_ext "$fmt")"
  base="${src%.md}"
  if [ "$section" = "*" ]; then label="$src (全文)"; fname="${base}.${ext}"; else label="$src#${section}"; fname="${base}-${section}.${ext}"; fi

  # 出力先の決定と明示
  if [ "$pii" = "pii" ]; then destdir="$PII_OUT"; desttag=".kiro/specs/$SPEC_ID/outputs/ （PII 隔離）"; else destdir="$BUILD_OUT"; desttag="outputs/$SPEC_ID/"; fi

  # 正本・見出しの存在確認（スライス）
  if [ ! -f "$srcpath" ]; then emit "エラー: $label → 正本 '$src' が見つかりません（生成スキップ）"; ERR=$((ERR+1)); continue; fi
  sliced="$(mktemp)"
  if ! sdd_slice "$srcpath" "$section" > "$sliced" 2>/dev/null; then
    emit "エラー: $label → 見出し '$section' が見つかりません（空生成せずスキップ）"
    rm -f "$sliced"; ERR=$((ERR+1)); continue
  fi

  # レンダラ可用性
  cmd="$(sdd_renderer_for "$fmt")"
  if [ -z "$cmd" ] || ! sdd_renderer_available_cmd "$cmd"; then
    emit "未生成（要 install-renderers）: $label → $fmt（レンダラ '${cmd:-未定義}' が見つかりません）／予定出力先: $desttag"
    rm -f "$sliced"; SKIP=$((SKIP+1)); continue
  fi

  # 生成
  mkdir -p "$destdir"
  if "$cmd" "$sliced" -o "$destdir/$fname" >/dev/null 2>&1; then
    emit "生成済み: $label → $destdir/$fname ／ 出力先: $desttag"
    GEN=$((GEN+1))
  else
    emit "失敗: $label → $fmt のレンダリングに失敗（レンダラ実行時エラー）／予定出力先: $desttag"
    ERR=$((ERR+1))
  fi
  rm -f "$sliced"
done

{
  echo ""
  echo "## サマリ"
  echo "- 生成済み: $GEN / 未生成(要install): $SKIP / エラー: $ERR"
  echo ""
  echo "> 未生成は \`npx -y github:kyamady-dorokid/sdd_base_template install-renderers\` で対応レンダラを取得してください。"
} >> "$REPORT"

echo "doc-export 完了: 生成 $GEN / 未生成 $SKIP / エラー $ERR （レポート: $REPORT）"
exit 0
