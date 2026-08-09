#!/usr/bin/env bash
# fix-plain-japanese-output.sh <repo_root>
#
# 直接ドキュメント（requirements.md/design.md/tasks.md、steeringドキュメント、検証レポート等）
# を生成するkiro-*スキルに対し、日本語プローズを平易に書くという本リポジトリ独自のルールを、
# SKILL.md末尾へ冪等追記する（薄い委譲ブロック）。
#
# 対象外: kiro-review / kiro-debug / kiro-verify-completion / kiro-spec-batch / kiro-spec-quick /
# kiro-spec-status は独立した文書を作らず、他スキルへの委譲または会話内出力のみのため対象外。
# kiro-spec-requirements の Objective 節固有ルールは fix-ears-plain-japanese.sh 側で扱う。
#
# 設計方針（ensure-agreement-log.sh / fix-impl-team-policy.sh と同一パターン）:
#  - cc-sdd の *上流ソース* は触らない。取得済みローカル生成物に marker で append するだけ。
#  - パッチ本体にルール *本文* を書かない。docs/sdd/rules/japanese-writing-style.md を唯一の正
#    として参照する。
#  - 末尾追記＝上流の内部文言が変わっても壊れない。冪等（マーカー検出でスキップ）。
set -uo pipefail
ROOT="${1:?repo_root required}"
MARKER="SDD-OVERLAY:PLAIN-JAPANESE-OUTPUT"

TARGET_SKILLS=(
  kiro-spec-requirements
  kiro-spec-design
  kiro-spec-tasks
  kiro-spec-init
  kiro-validate-design
  kiro-validate-gap
  kiro-validate-impl
  kiro-discovery
  kiro-steering
  kiro-steering-custom
  kiro-impl
)

apply_one(){
  local f="$1"
  [ -f "$f" ] || return 0
  if grep -q "$MARKER" "$f" 2>/dev/null; then
    echo "    $(basename "$(dirname "$f")")/$(basename "$f"): $MARKER 既存（スキップ）"
    return 0
  fi
  cat >> "$f" <<'EOS'

<!-- SDD-OVERLAY:PLAIN-JAPANESE-OUTPUT:START (sdd_base_template が付加。手動編集は再 init で再付与される) -->
## Plain Japanese output (SDD overlay)

**When this skill generates Japanese prose for a human** (explanatory text, Introduction,
summaries, reports — not the fixed EARS trigger keywords), write it in **plain Japanese**: one
claim per sentence, avoid stiff kanji compounds in favor of easier phrasing, and quote concrete
examples (error messages, sample output) with `「」`. The rules and examples live in
`docs/sdd/rules/japanese-writing-style.md` — read it before writing prose, do not restate it here.
<!-- SDD-OVERLAY:PLAIN-JAPANESE-OUTPUT:END -->
EOS
  echo "    $(basename "$(dirname "$f")")/$(basename "$f"): $MARKER 追記"
}

applied=0
for skill in "${TARGET_SKILLS[@]}"; do
  for agent_dir in .claude .agents; do
    apply_one "$ROOT/$agent_dir/skills/$skill/SKILL.md" && applied=1
  done
done
[ "$applied" = 1 ] || echo "    (対象スキルのSKILL.mdが見つからず、適用なし)"
