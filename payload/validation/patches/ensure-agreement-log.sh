#!/usr/bin/env bash
# ensure-agreement-log.sh <repo_root>
#
# cc-sdd の kiro-spec-init は spec.json / requirements.md のみを生成し、
# agreement-log.md を作らない。本リポジトリの overlay は「合意は agreement-log.md に必ず残す」
# ことを必須としているため、spec 初期化時に agreement-log.md を実在させるステップを
# SKILL.md 末尾へ冪等追記する（薄い委譲ブロック）。
#
# 設計方針（fix-impl-team-policy.sh と同一パターン）:
#  - cc-sdd の *上流ソース* は触らない。取得済みローカル生成物に marker で append するだけ。
#  - パッチ本体に雛形 *本文* を書かない。docs/sdd/templates/agreement-log.md を唯一の正として参照。
#  - 末尾追記＝上流の内部文言が変わっても壊れない。冪等（マーカー検出でスキップ）。
set -uo pipefail
ROOT="${1:?repo_root required}"
MARKER="SDD-OVERLAY:ENSURE-AGREEMENT-LOG"

apply_one(){
  local f="$1"
  [ -f "$f" ] || return 0
  if grep -q "$MARKER" "$f" 2>/dev/null; then
    echo "    $(basename "$(dirname "$f")")/$(basename "$f"): $MARKER 既存（スキップ）"
    return 0
  fi
  cat >> "$f" <<'EOS'

<!-- SDD-OVERLAY:ENSURE-AGREEMENT-LOG:START (sdd_base_template が付加。手動編集は再 init で再付与される) -->
## Ensure agreement-log.md exists (SDD overlay)

**This repository requires every spec to have a real `agreement-log.md` file.** cc-sdd's
spec-init does not create one, so as part of initializing a spec you MUST also create it if
missing:

1. After `spec.json` / `requirements.md` are generated, check for
   `.kiro/specs/<id>/agreement-log.md`.
2. If it does not exist, create it from the template
   `docs/sdd/templates/agreement-log.md`, filling in タスクID / 作成日 / 関係者 and the
   壁打ち概要 from the spec description. Do NOT leave the agreement as conversation-only.
3. Keep it updated at each approval gate (decisions, rationale, dates). The authoritative
   approval booleans still live in `spec.json`; agreement-log records the "why".

See `docs/sdd/workflow.md` (「非コーディング作業のドキュメント化」/「承認ゲートの原則」) for the rule.
<!-- SDD-OVERLAY:ENSURE-AGREEMENT-LOG:END -->
EOS
  echo "    $(basename "$(dirname "$f")")/$(basename "$f"): $MARKER 追記"
}

applied=0
for f in "$ROOT/.claude/skills/kiro-spec-init/SKILL.md" "$ROOT/.agents/skills/kiro-spec-init/SKILL.md"; do
  apply_one "$f" && applied=1
done
[ "$applied" = 1 ] || echo "    (kiro-spec-init/SKILL.md が見つからず、適用なし)"
