#!/usr/bin/env bash
# fix-ears-plain-japanese.sh <repo_root>
#
# ears-format.md（cc-sdd生成物）は既に「トリガー英語は残し可変部分だけ現地語化する」ルールを
# 持つ。本パッチは、その可変部分・Objective節を平易な日本語にするという本リポジトリ独自の
# ルールを、既存ルールへ続く形で冪等追記する（薄い委譲ブロック）。
#
# 設計方針（ensure-agreement-log.sh / fix-impl-team-policy.sh と同一パターン）:
#  - cc-sdd の *上流ソース* は触らない。取得済みローカル生成物に marker で append するだけ。
#  - パッチ本体にルール *本文* を書かない。docs/sdd/rules/japanese-writing-style.md を唯一の正
#    として参照する。
#  - 末尾追記＝上流の内部文言が変わっても壊れない。冪等（マーカー検出でスキップ）。
set -uo pipefail
ROOT="${1:?repo_root required}"
MARKER="SDD-OVERLAY:EARS-PLAIN-JA"

apply_one(){
  local f="$1"
  [ -f "$f" ] || return 0
  if grep -q "$MARKER" "$f" 2>/dev/null; then
    echo "    $(basename "$(dirname "$(dirname "$f")")")/rules/$(basename "$f"): $MARKER 既存（スキップ）"
    return 0
  fi
  cat >> "$f" <<'EOS'

<!-- SDD-OVERLAY:EARS-PLAIN-JA:START (sdd_base_template が付加。手動編集は再 init で再付与される) -->
## Plain Japanese for localized parts (SDD overlay)

The trigger keywords rule above (keep `When`/`If`/`While`/`Where`/`shall` in English, localize
only the variable parts) stays as-is. In addition, this repository requires the localized
(Japanese) parts to be written in **plain Japanese** — see
`docs/sdd/rules/japanese-writing-style.md` for the rules (one claim per sentence, avoid stiff
kanji compounds, quote concrete examples with `「」`).

The **Objective** section of each requirement must NOT be a literal translation of
`As a X, I want Y, so that Z`. Write it as a natural two-sentence Japanese explanation instead
(e.g. 「〜したい。〜するためである。」). See the SSOT doc for a worked example.
<!-- SDD-OVERLAY:EARS-PLAIN-JA:END -->
EOS
  echo "    $(basename "$(dirname "$(dirname "$f")")")/rules/$(basename "$f"): $MARKER 追記"
}

applied=0
for f in \
  "$ROOT/.claude/skills/kiro-spec-requirements/rules/ears-format.md" \
  "$ROOT/.agents/skills/kiro-spec-requirements/rules/ears-format.md"
do
  apply_one "$f" && applied=1
done
[ "$applied" = 1 ] || echo "    (ears-format.md が見つからず、適用なし)"
