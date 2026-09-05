# Task A handoff: Kiro互換・製品境界

> 完了日: 2026-09-05
> 状態: 人間承認済み。orchestratorによる現行資産・関連Issueとのcross-check済み。
> 件数補正: handoffの「18個の`kiro-*`」は、全`kiro-*`（現時点17個）と
> SDD Rig固有の`doc-export` 1個を合わせた配布SDD skill 18個として正規化した。

## 1. V1互換性

SDD Rigは、Kiro公式、AWS提携製品、Kiroの後継を名乗らない独立製品として、
定義済みの外部workflowに対する構造互換と起動互換を保証する。

- 既存`.kiro/`を認識する。
- 完成済みだけでなく、未完成・途中状態の既存specを開始・再開・完了できる。
- `spec.json`の既知schema、phase、approval metadataを扱い、未知fieldを非破壊で保持する。
- `SDD-BASE:*` marker、旧lock/snapshot、旧`sdd-base`入口を移行対象として扱う。
- Claude CodeとCodexの双方で、現行inventoryに含まれる全`kiro-*` skillを検出・明示起動できるようにする。
  2026-09-05時点では両platformに17個ずつ存在する。
- `doc-export`はKiro互換対象ではなく、SDD Rig固有skillとしてClaude Code/Codex parityを保証する。

完全な出力一致、内部実装一致、未公開または将来のKiro仕様との意味一致は保証しない。
自然言語起動はKiro互換保証ではなく、SDD Rig固有の製品要件として#32とTask Eで扱う。

## 2. 品質条件

- 既存資産の開始・再開・完了を壊さない。
- 人間承認、TDD、Claude Code/Codex parityを弱めない。
- 現行で確認できる品質目的の機能を、根拠なく廃止しない。
- 機能改修と品質維持が衝突する場合、影響、代替案、回帰試験を示し、人間判断へ戻す。

## 3. 製品表示

主見出しは次とする。

> **SDD Rig — 開発の理由が、いつでもたどれるAI開発環境。**

価値説明では、要件、設計、合意判断、テスト結果を証跡として残し、人とAIの双方が
決定理由を追跡できることを示す。

SDD Rigは「cc-sddをベースに開発した独立製品」と説明する。主表示で「cc-sddの改造版」とは呼ばず、
Kiro/AWSの公式、提携、後継とも表示しない。cc-sdd由来部分は、日本語の由来説明と
NOTICE/LICENSEでMIT帰属を示す。

## 4. 名称・状態移行contract

- repositoryを即時renameしない。
- 旧URL、package、CLI、skill、marker、stateのbridgeを先に設計・実装・検証する。
- 新`sdd-rig`は旧`.kiro/`、spec、lock、markerをそのまま認識し、別stateや二重管理を作らない。
- 旧環境は日付だけで廃止しない。新旧入口が同じrepositoryで同じspec、承認状態、進行状況を共有でき、
  非破壊性、rollback、Claude Code/Codex parity、旧資産の開始・再開・完了、新名称での配布・発見・更新を
  E2Eと人間承認で確認するまで維持する。
- 将来state形式を変更する場合は、明示的、可逆的、rollback検証済みの別Decisionを必要とする。
- 旧CLI、旧install済みskill、旧URL/packageを利用した場合だけ、新名称を短く案内する。
  新`sdd-rig`が旧projectを開いただけでは警告しない。

## 5. 後続Taskへの制約

| Task | 引き継ぐ制約 |
|---|---|
| B | source intakeとMIT帰属を実装し、Task Aの外部contractを維持する |
| C | 証跡の正本と追跡可能性を維持し、既存schemaの意味変更は人間判断へ戻す |
| D | 既存specと証跡を壊さず、doc-exportをSDD Rig固有機能として扱う |
| E | 全`kiro-*`のfresh-session検出・明示起動と、`doc-export`を含む両platform parityを検証する |
| F | in-place bridge、旧入口、rollback、旧資産の開始・再開・完了をE2Eで検証する |

## 6. 未決調査

- 全`kiro-*`のfresh-session E2E
- 旧URL/package/CLIの実配布状況と、alias、redirect、rollbackの詳細
- `spec.json`の全field棚卸しと未知field保存の受入試験

これらはTask AのDecisionを妨げないが、該当する後続Taskの完了条件に含める。
