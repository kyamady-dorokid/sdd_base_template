# Discovery再開時の保全・現状棚卸し

> 調査日: 2026-09-04
> 対象Issue: #41
> 状態: Phase 0の調査証跡。承認済み要件・設計ではない。

## 1. 調査目的

`sdd_base_template`を、Kiro互換の外部契約を維持した独立製品`SDD Rig`へ再構成する前に、
既存作業を失わず、PR #42時点の合意と現在の製品方針の差を特定する。

## 2. worktreeと未完了資産

| 場所 | branch / HEAD | 2026-09-04時点の状態 | 保全方針 |
|---|---|---|---|
| `/Users/kyamady/workspace/sdd_base_template` | `docs/plain-japanese-writing-style` | `origin/main`より7 commit遅れ。`AGENTS.md`変更、`cc-sdd-issue-handoff.md`、`issue-drafts/`、`software_strategy.txt`が未追跡または未commit | #41では編集・commitしない |
| `.../issue-32` | `codex/issue-32-skill-parity-impl` | `origin/main`より2 commit進み4 commit遅れ。worktreeはclean | `eacc51e`、`73e3946`を破棄せず、新core確定まで停止 |
| `.../issue-37` | `codex/issue-37-intermediate-artifacts` | `origin/main`より6 commit遅れ。spec一式が未追跡 | 未追跡の`.kiro/specs/intermediate-data-artifacts/`を保全 |
| `.../issue-39` | `codex/issue-39-independent-gate-review` | `origin/main`より6 commit遅れ。旧spec一式が未追跡 | 証跡として保全するが、旧requirementsでdesignへ進めない |
| `.../issue-41` | `codex/issue-41-sdd-rig-discovery` | 最新`origin/main`から作成、clean | #41 Discovery改訂の専用作業場所 |
| `.claude/worktrees/auto-branch-types-8614f6` | detached HEAD | `origin/main`より8 commit遅れ、clean | 棚卸し対象として保持し、#41では使用しない |

### #32の未マージcommit

- `eacc51e feat: スキルパリティ検証基盤を追加`
- `73e3946 feat: スキルメタデータ生成を実装`

### #37の未追跡spec

- `agreement-log.md`
- `brief.md`
- `design.md`
- `requirements.md`
- `research.md`
- `spec.json`

### #39の未追跡spec

- `agreement-log.md`
- `amendments/2026-08-15-review-loop-limit.md`
- `brief.md`
- `requirements.md`
- `reviews/requirements.md`
- `spec.json`

## 3. PR #42と#41正本の状態

PR #42「docs(sdd): Issue #41のDiscovery方針を確定」は2026-08-16に`main`へmerge済み。
次のファイルが履歴上の正本として存在する。

- `brief.md`: Token効率、文書責務、review、model routing、計測基準等の旧Discovery結果
- `agreement-log.md`: 旧Discoveryで人間が承認したDecision
- `requirements.md`: 入力説明だけのplaceholder。requirementsは未生成
- `spec.json`: `phase: initialized`、全approvalが`generated: false / approved: false`

したがって、実装だけでなくrequirements生成にもまだ進まない。戦略変更をDiscoveryへ統合し、
DQ PRを人間が確認・mergeした後にrequirementsへ進む。

## 4. 現行製品の取得・変更・配布構造

| 責務 | 現行実装 | SDD Rig方針との関係 |
|---|---|---|
| cc-sdd取得 | `payload/scripts/init.sh`が`npx -y cc-sdd@latest`をClaude Code用とCodex用に各1回実行 | 実行時外部取得から、repository内source baselineへ変更予定 |
| version確認 | `payload/KNOWN_GOOD_CCSDD_VERSION`と`npm view cc-sdd version`を`validate.sh`で比較 | source baselineのtag/commit、provenance、上流追従へ再設計が必要 |
| 独自変更 | cc-sdd生成後に`payload/validation/patches/*.sh`と`payload/overlay/`を適用 | overlayだけでなく、core・adapter・policyの責務境界を再定義する必要がある |
| Claude/Codex配布 | cc-sdd生成物とoverlay skillを`.claude/skills/`、`.agents/skills/`へ展開 | platform差をadapterへ分離し、意味的parityを維持する |
| CLI | package名は`sdd-base-template`、CLIは`sdd-base` | canonical名を`sdd-rig`へ移し、旧CLIを互換aliasとして残す |
| 個人環境install | `bin/cli.js`が`SKILL.md`と`payload/`を自己完結bundleとしてコピーまたはlink | 旧install済みskillからの移行contractが必要 |
| sync | `payload/overlay/`とmarker blockをlock/snapshot付きで3-way反映 | 統合release、旧識別子、source baseline更新を含む移行設計はTask Fで決める |
| 検証 | shell unit/integration test、pre/post validate、既知parity差、patch検査 | compatibility matrixをmachine-checkableな受入条件へ接続する必要がある |

## 5. 旧Decisionの暫定分類

以下はPhase 0の分類案であり、Task A〜Fの壁打ちと人間確認で確定する。

### 維持候補

- Kiro系command、`.kiro/`構造、標準file名、主要phase順の外部互換性を維持する。
- 人間承認、TDD、main直接commit禁止を維持する。
- Claude Code / Codexの意味的parityを必須とする。
- riskをTierより優先し、高riskではfresh独立reviewを必須とする。
- 文書責務を一つに限定し、本文copyではなくID参照でtraceabilityを維持する。
- 一次成果物を正本とし、二次成果物を一方向生成する。
- model class、context budget、最大10巡の収束review、fail-closedを維持する。

### 改訂候補

- 「cc-sddを基盤とする」は維持するが、`npx`実行時依存からrepository内source baselineへ変更する。
- 「overlayで独自規則を追加する」は、取り込んだcore、共通policy、platform adapter、project overrideの
  責務分離へ変更する。overlayを全面廃止するかはTask Bで決める。
- cc-sddのversion管理は、`latest`との比較から、取り込み元tag/commit、差分検証、昇格、rollbackへ変更する。
- Issue #33/#34の責務は、外部package更新ではなく、取り込んだupstream baselineの更新workflowへ読み替える。
- doc-exportはformat変換器から、人間が判断できる二次成果物を生成するpresentation層へ改訂する。
- 旧Issue順は、Task A〜Fで契約を確定してから実装waveを決める方式へ改訂する。

### 撤回候補

- `brief.md`の「cc-sddのsourceまたは生成物をpayloadへ再配布する設計変更は対象外」。
- `brief.md`の「独自文書規則はoverlayだけで実現する」という実現方式の固定。
- `npx cc-sdd@latest`を本番の標準取得経路として継続する前提。
- PR #42後すぐrequirementsへ進む旧再開点。戦略変更を取り込むDiscovery改訂を先に行う。

### 新規候補

- 表示名、repository、package、CLIのcanonical nameを`SDD Rig` / `sdd-rig`とする。
- 旧repository URL、`sdd-base`、`sdd-init`、`SDD-BASE:*` marker、lock/stateを破壊しない移行期間を設ける。
- Kiro互換範囲をcompatibility matrixで定義し、非公式・非提携を明示する。
- cc-sddのLICENSE、著作権表示、provenance、変更表示、upstream更新、rollbackを製品契約に含める。
- Discoveryの壁打ちはTask A〜Fを1件ずつ実行し、context packetとstructured handoffを固定する。

## 6. Phase 0で判明した停止条件

- 旧方針の「cc-sddを再配布しない」と新方針のsource取り込みを、同時に有効な要件として扱わない。
- `Kiro互換`を無限定な完全互換として表示しない。Task Aで互換対象と保証水準を定義する。
- 互換ブリッジを実装・検証する前にGitHub repositoryをrenameしない。
- #32の未マージ実装を新coreへ無条件にrebase・mergeしない。
- #37/#39の未追跡specを削除せず、かつ旧前提のまま承認済み正本として扱わない。
