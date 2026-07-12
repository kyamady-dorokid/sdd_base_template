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
source "$SCRIPT_DIR/mermaid.sh"

# 欠けたレンダラ固有の導入コマンドを提示する文字列（DRY レジストリ由来）
install_hint_line(){
  local cmd="$1" hint steps
  hint="$(sdd_renderer_install_hint "$cmd")"; steps="${hint#*|}"; steps="${steps%%|*}"
  [ -n "$steps" ] && printf '導入: %s' "$steps" || printf 'install-renderers を参照'
}
# 対話端末なら install-renderers 経由で導入を試み、再判定して 0/非0 を返す
try_interactive_install(){
  local cmd="$1"
  [ -t 0 ] || return 1               # 非対話ではその場実行しない
  bash "$SCRIPT_DIR/install-renderers.sh" "$cmd" || true
  sdd_renderer_available_cmd "$cmd"
}

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
  # C-2: マニフェスト不在時は spec 内の主要成果物（requirements/design/tasks）を各1本 docx 全文
  while IFS= read -r r; do [ -n "$r" ] && records+=("$r"); done < <(sdd_manifest_default "$SPEC_DIR")
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

  # レンダラ可用性（不可用なら固有の導入コマンドを提示。対話端末では導入を試みて再判定）
  cmd="$(sdd_renderer_for "$fmt")"
  if [ -z "$cmd" ] || ! sdd_renderer_available_cmd "$cmd"; then
    if [ -n "$cmd" ] && try_interactive_install "$cmd"; then
      : # 導入成功 → 続行
    else
      emit "未生成（要 install-renderers）: $label → $fmt（レンダラ '${cmd:-未定義}' 未導入。$(install_hint_line "${cmd:-}")）／予定出力先: $desttag"
      rm -f "$sliced"; SKIP=$((SKIP+1)); continue
    fi
  fi

  # Mermaid 前処理（mmdc 可用時は画像化、未導入時は元コードを残し未変換件数を得る）
  assetdir="$(mktemp -d)"
  processed="$(mktemp)"
  unconv="$(sdd_mermaid_preprocess "$sliced" "$processed" "$assetdir")"
  if [ "${unconv:-0}" -gt 0 ]; then
    emit "注記: $label に Mermaid 図 ${unconv} 件（mmdc 未導入のため未変換・コードのまま）。$(install_hint_line mmdc)"
  fi

  # 生成
  mkdir -p "$destdir"
  if "$cmd" "$processed" -o "$destdir/$fname" >/dev/null 2>&1; then
    emit "生成済み: $label → $destdir/$fname ／ 出力先: $desttag"
    GEN=$((GEN+1))
  else
    emit "失敗: $label → $fmt のレンダリングに失敗（レンダラ実行時エラー）／予定出力先: $desttag"
    ERR=$((ERR+1))
  fi
  rm -f "$sliced" "$processed"; rm -rf "$assetdir"
done

{
  echo ""
  echo "## サマリ"
  echo "- 生成済み: $GEN / 未生成(要install): $SKIP / エラー: $ERR"
  echo ""
  echo "> 未生成は \`npx -y github:kyamady-dorokid/sdd_base_template install-renderers\` で対応レンダラを取得してください。"
} >> "$REPORT"

echo "doc-export 完了: 生成 $GEN / 未生成 $SKIP / エラー $ERR （レポート: $REPORT）"
# B-1b: エラーを含む → 非0。未生成(想定内)のみ or 成功 → 0。
[ "$ERR" -gt 0 ] && exit 1
exit 0
