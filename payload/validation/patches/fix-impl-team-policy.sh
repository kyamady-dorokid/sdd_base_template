#!/usr/bin/env bash
# fix-impl-team-policy.sh <repo_root>
#
# kiro-impl（cc-sdd生成物）の commit/branch 既定挙動を、本リポジトリの overlay ポリシーへ
# 委譲させる「薄い上書きブロック」を SKILL.md 末尾に冪等追記する。
#
# 設計方針（CLAUDE.md ルール準拠）:
#  - cc-sdd の *上流ソース* は触らない。取得済みローカル生成物に append/marker で当てるだけ。
#  - パッチ本体にポリシー *本文* を書かない。docs/sdd/{commit,branching}-policy.md / workflow.md を
#    唯一の正(SSOT)として参照させる。ポリシー変更は overlay 側で完結する。
#  - 末尾追記＝上流の内部文言が変わっても壊れない。
set -uo pipefail
ROOT="${1:?repo_root required}"
MARKER="SDD-OVERLAY:IMPL-POLICY"

apply_one(){
  local f="$1"
  [ -f "$f" ] || return 0
  if grep -q "$MARKER" "$f" 2>/dev/null; then
    echo "    $(basename "$(dirname "$f")")/$(basename "$f"): $MARKER 既存（スキップ）"
    return 0
  fi
  cat >> "$f" <<'EOS'

<!-- SDD-OVERLAY:IMPL-POLICY:START (sdd_base_template が付加。手動編集は再 init で再付与される) -->
## Team Policy Override (SDD overlay)

**This repository overlays team rules ON TOP of this cc-sdd skill. Where they conflict, the
overlay wins.** The authoritative policy lives in the overlay docs — read and obey them:
- `docs/sdd/workflow.md` (development flow, the two entry doors, Tier S/L)
- `docs/sdd/rules/commit-policy.md`
- `docs/sdd/rules/branching-policy.md`

Concretely, this OVERRIDES the commit/branch behavior described above in this skill:
1. **Autonomous auto-commit is DISABLED by default.** Do NOT `git commit` after each task.
   Instead, mark the task `[x]` in tasks.md, and at phase breakpoints PROPOSE a commit
   (target files + suggested message) for the human to execute. Auto-commit runs only when the
   human explicitly opts in ("このタスクはコミットまで自動で進めて") — see commit-policy.md.
2. **Never commit to `main`/`master`.** Work on a feature branch; integrate via push → PR.
   If the current branch is `main`/`master`, STOP and ask the human to create a branch first.
3. **No destructive history ops** (`--amend`, `reset --hard`, force push) inside the loop.
4. **Records go to `.kiro/specs/<id>/`** (test-results.md, integration-test-checklist.md,
   agreement-log.md). Do not create a separate `docs/specs/` tree.

Everything else in this skill (TDD, independent review, bounded debug, validate-impl gate)
still applies. After the validate-impl GO, a human integration-test gate remains
(`.kiro/specs/<id>/integration-test-checklist.md`) before the feature is "done".
<!-- SDD-OVERLAY:IMPL-POLICY:END -->
EOS
  echo "    $(basename "$(dirname "$f")")/$(basename "$f"): $MARKER 追記"
}

applied=0
for f in "$ROOT/.claude/skills/kiro-impl/SKILL.md" "$ROOT/.agents/skills/kiro-impl/SKILL.md"; do
  apply_one "$f" && applied=1
done
[ "$applied" = 1 ] || echo "    (kiro-impl/SKILL.md が見つからず、適用なし)"
