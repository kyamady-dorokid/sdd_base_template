# Independent Tasks Review

## Review Metadata

| Field | Value |
|---|---|
| Reviewer | same independent sub-agent used for requirements and design |
| Model | `gpt-5.6-sol` |
| Environment | Codex |
| Review style | critical, evidence-based, convergence review |
| Input hash kind | `git-blob-manifest-v1` |
| Input files | `requirements.md`, `design.md`, `tasks.md` |

## Initial Review

| Field | Value |
|---|---|
| Input hash | `21e06f160883877b029d7c71b169a1d8e82ec2f8` |
| Verdict | `RETURN_TO_PREVIOUS_GATE` |

### Consolidated Findings

1. `DL1` Medium / `LATE_FINDING` — designが既存dependencyとして示す
   `payload/scripts/lib/common.sh`は実在せず、taskから実装判断を閉じられない。
2. `T1` High — schema/parser/contract/status、materializer、validator、install matrix、live acceptanceが
   1〜3時間を超える過大taskになっている。
3. `T2` Medium — manifestとvalidator、materializerとpersonal ownership、harnessと実配布acceptanceの
   責任境界が重複している。
4. `T3` Medium — standalone validate、local report ignore、legacy checks/allowlistとmanifest正本の整合が
   明示的なtest-first taskになっていない。
5. `T4` Medium — `cyclox2_docker`受入の対象revision、適用方法、許可、環境未準備時の停止条件がない。

89/89 acceptance criteria mapping、15/15 observable completion、sequential宣言、Issue境界、
destructive migration、cc-sdd non-redistributionは適合。DL1はdesign dependency修正が必要なため、
tasksだけの局所修正ではなくdesign gateへ戻す。

## Next Action

1. designの非実在dependencyを修正し、design input hashを更新して同じreviewerで再reviewする。
2. design PASS後、tasksを責任境界と1〜3時間sliceで再生成する。
3. standalone validate、report ignore、legacy allowlist移行、下流acceptance setupを独立task化する。

## Repair Batch 1

- Design Follow-up 5 PASS後のdesign hashを入力に、tasksを15から36 executable slicesへ再生成。
- schema、parser、status、contract engine、agent別renderer、apply policy、validator、reportを分離。
- personal ownership、copy、link、migration/rollbackを分離。
- standalone validate、init、sync no-lock、sync managed/conflictを分離。
- guidance、strict patch、legacy checks/allowlist移行、report ignoreを独立task化。
- harness/isolated probesと実配布acceptanceを分離し、Codex/Claude/distribution別にlive taskを分割。
- `cyclox2_docker`はrevision、適用方法、許可、環境、証跡先を確定するsetup taskを先行し、
  未準備時は`UNVERIFIED`のまま停止する。

## Follow-up 1

| Field | Value |
|---|---|
| Input hash | `2154d97f1c2809ef4c19fb7197bb9107c6a15677` |
| Verdict | `REVISE` |

- `DL1`, `T1`, `T3`, `T4`: CLOSED。
- `T2`: OPEN — Task 1.4がmanifest policyとassertion evaluationを同時所有し、Task 3.2と重複。
- Late finding、regression、scope change: none。

## Repair Batch 2

- Task 1.4をassertion policy schemaと参照整合だけへ限定。
- Task 3.2をassertion evaluator、Task 3.3をagent invocation/delegation統合へ分割。
- reportとphase commandを3.4、3.5へ繰り下げ、validator executionへ一本化。

## Follow-up 2

| Field | Value |
|---|---|
| Input hash | `7456b1c63bdfc0b23820c02e44b5ff4b4e56c563` |
| Verdict | `PASS` |

- `DL1`, `T1`, `T2`, `T3`, `T4`: all CLOSED。
- 8 major tasks / 37 executable tasks、37/37 observable completion and boundary annotations。
- 89/89 acceptance criteria and all design concerns covered。
- Findings、late finding、regression、scope change: none。

Tasks review converged after Repair Batch 2. Human combined design/tasks approval is required before any
implementation authorization can be considered.
