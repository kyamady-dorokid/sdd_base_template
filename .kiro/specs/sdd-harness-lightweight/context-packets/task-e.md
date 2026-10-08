# Task E 開始資料: agent・review・model・context予算

> 状態: 開始資料作成済み・人間確認待ち。壁打ち未開始。
> 基準: PR #46 merge commit `2fd72c0ccb09175723d50fbb3d4c311bc1948e9f`。
> Issue #41の専用壁打ちへ渡す派生入力。標準SDD文書・仕様・承認の正本ではない。
> 採用済み判断は `../agreement-log.md`、承認状態は `../spec.json` を参照する。

## 目的と権限

Task Eは、SDD Rigがどの作業で、どのreview強度・agent構成・model能力・context予算を使うかを
一つの実行policyとして具体化する。目的は、通常作業へ過大なfresh reviewとcontext再投入を課さず、
高risk・高不確実性・高難度の作業では必要な独立性と能力を落とさないことにある。

人間との壁打ちは一度に一論点とし、推奨案、代替案、反例、費用と安全性のtrade-offを示す。
人間の希望へ無根拠に迎合せず、risk・検証可能性・情報漏洩・Token再投入・approval誤認を批判的に評価する。

専用sessionは調査・対話・handoff・正本化確認だけを行う。repository file、GitHub Issue、approval状態、
実装、skill、template、Requirements/Design/Tasks、commit/push/PR、renameは変更しない。
正本への反映はorchestratorが所有する。既存Decisionとの衝突、新しい公開contract、owner変更は人間へ戻す。

## 維持する合意

### 三軸と人間承認

- #77〜#83: `Spec Tier / Review Mode / Model Class`は別軸とし、machine-readable namespaceも分ける。
- Spec Tierは仕様化・調整の複雑性と文書の深さを扱い、risk、review要否、model能力を直接決めない。
- Review Mode候補は`STANDARD / DEEP_RECOMMENDED / DEEP_REQUIRED`。risk、不確実性、検証可能性、
  rollback、外部副作用、暗黙契約から判定する。
- `DEEP`実行前に理由、agent数、Model Class、context範囲、最大巡回数、Token・時間見積区分、
  拒否時の扱いを提示し、人間承認を得る。`DEEP_REQUIRED`拒否時は暗黙に`STANDARD`へ降格しない。
- Model Classはroleの判断量、制約統合、曖昧性、反例探索、domain知識、機械検証可能性から決める。
  高riskはreviewer能力、実装難度はimplementer能力へ別々に反映する。
- 上記は採用済みbaselineだが、評価順、閾値、複数該当、名称、旧Decisionとの改訂関係をTask Eで再確認する。

### agent・独立review

- #24〜#29の目的は維持するが、Tier Lへ固定回数を割り当てる旧方式はTask Eで適応型判定へ改訂する。
- 主agentがorchestrationと通常作業を兼任し、active subagentは通常1体まで。累計起動数には固定上限を置かない。
- Tokenはagent数ではなく、agent別context量・重複率・retry・手戻りを中心に評価する。
- subagentにはrole別の最小context envelopeだけを渡し、同じ正本と親要約を重複投入しない。
- 複数subagent同時利用は、独立責務、非重複file/context、時間短縮、統合方法、Token影響を示し、
  人間が例外承認した場合だけ認める。並列化をToken削減とはみなさない。
- 制限context自己reviewは前処理に使えても、fresh独立reviewの代替にしない。
- gateごとのfresh reviewerは原則1名。同一gateの収束は同じreviewerを再利用し、最大10巡候補を維持する。
  2名目は大規模で分担が明確な場合に限り、理由とToken影響を示して人間承認後に起動する。
- reviewerは証拠ベースの批判的立場で、反例、欠落、境界違反、未証明の前提を探す。
- 適格reviewer不在、input hash変更、必須review未完了を同一context fallbackや推測PASSで埋めない。
- `kiro-impl`の既定dispatchと本contractが衝突する場合は、coreまたはadapterで明示的に置換し、
  適用不能ならfail-closedとする。具体的dispatch契約はTask Eで判断する。

### model routing

- #30〜#39のprovider中立な`Standard / Critical / Mechanical`をbaselineとする。
- `Standard`は主agent・仕様作成・通常実装、`Critical`はfresh独立review・高難度設計・debug、
  `Mechanical`は機械検証可能な抽出・変換・集計に限定する。
- `Mechanical`へrisk、仕様、設計、test充足性、finding重大度、情報省略の判断をさせない。
- classは最低能力。上位classの代行は認めるが、`Critical`からの無承認降格は禁止する。
- 対応表外、能力不明、provider越え代替は人間判断まで停止する。review収束中のmodel・推論設定変更は
  reviewer交代としてfresh reviewをやり直す。
- 証跡はrole、required class、実model、推論profile、能力tag、環境、fallback理由、input hash、
  取得可能なToken、retry、日時に限定し、raw会話を重複保存しない。
- Claude Codeの`Sonnet / Opus / Haiku`、Codexの`terra / sol / luna`等の名称は当時の候補であり、
  現在利用可能な固定modelとして扱わない。能力classと更新可能なprovider mappingを分離する。

### context予算・session継続

- #93〜#97: 計画的session分割を主策、早期compactを安全弁、platform固有auto-compact上限を
  任意の最終防波堤とする。
- Claude 1M contextの200K警告・500K上限は初期検証候補であり、全platform/modelの固定値ではない。
- active context、累積input・cached input、turn、compact、大容量出力、checkpoint readinessを分離して測る。
- checkpointは正本参照と未固定の最小差分を持つ派生manifestであり、会話要約や仕様copyを正本にしない。
- session分割を自動commit/pushと同義にせず、未承認・不完全な差分をcheckpoint名目でcommitしない。
- raw transcriptはlocal opt-in。repository保存・外部送信を既定にせず、usage metadataを優先する。
- 情報責務はTask C、budget・判定・agent workflowはTask E、adapter・workspace lifecycle・E2EはTask F、
  大容量二次成果物の抑制はTask Dが所有する。

### review観点・approval・転記完全性

- #101〜#103・#110: 自然言語approvalは一意なpending gate、対象、version/hash、許可範囲が
  直前に明示された場合だけ成立する。人間・主agent・fresh reviewerは共通8観点を黙って除外しない。
- findingはID、severity、`BLOCKING / ADVISORY`、対象、違反contract、証拠、推論、失敗例、
  必要修正の結果、完了条件を持つ。severityとapproval影響を混同しない。
- #117〜#119: session・agent境界を越える正本化はhandoff ID、source hash、正本対応、canonical hash、
  確認状態を追跡し、`CANONICALIZATION_PASS`までfail-closedとする。
- Task Eは転記完全性確認のagent workflow・停止条件を扱う。session呼戻し・存続・復旧・両platform E2EはTask F。
- Task D #128: 二次成果物生成前のToken・時間・外部処理見積区分とagent budgetの接続をTask Eで決める。

## 既存Issueの現在地と拘束

### Issue #39

- 機能は存続するが、独立policy/specではなく#41に従う独立review実装・状態・証跡・validationの子Issue。
- 旧「全gateでfresh review必須」requirementsと既存approvalは、risk-based方針との不一致によりstale。
  そのapprovalでDesignへ進めない。
- 維持候補は、人間approval非代替、同一context自己reviewを独立review扱いしない、通常1 reviewer、
  同一reviewer収束、2名目の人間承認、最大10巡、hash鮮度、fail-closed、批判的review。
- Task Eはこれらの適用単位、判定、巡回、証跡を再確認し、#39を実装責務へ絞る。

### Issue #32

- 全user-facing skill/helperのClaude Code・Codex検出、明示起動、自然言語起動、意味的parity、
  fresh-session E2Eを所有する。
- 旧core前提のrequirements/design/tasksは承認済みだが、Task 2.4までのlocal 2 commitを保全して停止中。
  Task Eはこのworktreeを編集・rebase・pushせず、再利用・stale判定の入力だけを返す。
- Task Eは起動policyとagent workflowの意味contractを決め、platform探索・adapter・E2E方式は#32/Task Fへ渡す。

### Issue #31

- user-facing skillの事前・完了通知を所有する。直接skill、自然言語、subagent経由で意味を揃える。
- 通知はapprovalではなく、通知だけで次phaseへ進めない。helper内部処理を逐一通知しない。
- Issue本文の旧「#30完了後」順序は現行#41 roadmapより古い。Task Eで通知対象、agentから親への集約、
  DEEP事前承認やreview完了表示との境界を決め、最終順序はDiscovery統合時に判断する。

## 今回決めないこと

- 具体的なprovider/model IDを永久固定すること。
- Claude/Codex固有setting、skill discovery path、adapter、worktree/session lifecycle、lock、resume/recoveryの実装。
- Requirements / Design / Tasksの生成・承認、#39/#32/#31の実装開始。
- reviewer、主agent、subagentによる人間approvalの代替。
- 取得不能なToken・費用を0とみなすこと、目標値だけで安全欠陥を相殺すること。
- 外部source・dependency・modelをAIが無断採用すること。

## 壁打ちの順番

| ID | 判断すること | 主な反例・確認点 |
|---|---|---|
| E-1 | 三軸の目的・評価順・相互作用 | Tier、Review Mode、Model Classが同じ「難易度」の別名になっていないか。riskと実装難度を誰がどの順で判定するか |
| E-2 | Review Modeの判定と人間承認 | `STANDARD / DEEP_RECOMMENDED / DEEP_REQUIRED`の境界、複数該当、推奨拒否、必須拒否、途中昇格・降格 |
| E-3 | 独立reviewの実行・収束 | fresh独立性、1 reviewer、最大10巡、late finding、hash変更、RETURN_TO_PREVIOUS_GATE、#39のstale契約 |
| E-4 | agent topologyとcontext envelope | 主agent兼orchestrator、通常1 active subagent、並列例外、`kiro-impl` dispatch、渡す情報と重複率 |
| E-5 | Model Classとprovider mapping | role別最低能力、Critical非降格、Mechanical禁止判断、model不在・変更、review特化能力の証明 |
| E-6 | context budget・session分割・compact | 何を計測し、いつ警告・checkpoint・分割するか。未固定差分、raw transcript、費用見積の扱い |
| E-7 | 起動通知・approval navigation・転記完全性 | #31/#32、subagent通知集約、DEEP事前承認、skill完了表示、handoff停止条件をどう一貫させるか |
| E-8 | 計測・受入・既存Issue移行 | `B0 / B1 / C`、hard safety、暫定効率目標、#39/#31/#32の再利用・改訂・実装順 |

最初はE-1だけを扱う。三軸それぞれについて、少なくとも次を人間が判断できる形で比較する。

1. その軸が存在する目的。
2. 入力となる観測可能な事実と、判定してはいけない代替指標。
3. 誰がいつ判定し、何を変更できるか。
4. 他の二軸へ影響する場合の順序と、影響しない事項。
5. 誤分類時の失敗例、途中で前提が変わった場合の再判定。
6. #77〜#83、#24〜#39のうち維持・改訂・廃止する範囲。

E-1で「三軸を独立させたまま実行時に一意に判定できない」場合は、名称や順序を既定案として固定せず、
代替案と影響をorchestrator・人間へ戻す。

## 責務の境界

- Task E: 三軸判定、review強度、agent topology、model routing、context budget、転記完全性workflow、通知境界。
- Task F: session workspace ownership/isolation、lease/lock、resume/close/recovery、adapter、設定、移行、fresh-session E2E。
- #39: #41 policyに従う独立reviewの実装・状態・証跡・validation。
- #32: skill/helper inventory、検出、明示・自然言語起動、Claude/Codex semantic parity。
- #31: user-facing skillの事前・完了通知UX。
- Task D: 二次成果物生成時の対象・費用・品質・大容量context境界。agent予算判定はTask E。

## 必要な参照

最初に`agreement-log.md` #24〜#39、#52〜#60、#70、#77〜#83、#93〜#106、#110、
#112、#116〜#119、#121、#128、#130と、旧Decision改訂関係を読む。
Issue #39/#32/#31は現在地・stale範囲・後続owner確認に使い、旧本文をcurrent contractとして上書きしない。
必要に応じて`handoffs/task-c.md`と`handoffs/task-d.md`の後続制約だけを参照する。
会話全文や全handoffを一括投入せず、事実、採用済みDecision、候補、stale、未確認を分離する。

`cyclox2_docker`の`docs/catracer-cleanup-2026-27-task2-2`はE-2/E-8の実例候補であり、
アクセス可能性とrevisionを確認せずに事実として引用しない。

## structured handoffの必須形式

1. 採用・却下・保留・blockerを原子的なIDで返す。各IDに主体、条件、例外、禁止、理由、後続ownerを含める。
2. #24〜#39、#77〜#83、#93〜#97と#39/#32/#31の`MAINTAIN / AMEND / SUPERSEDE / RETIRE`を示す。
3. Requirements候補、Design保留、実装owner、未決調査を分離する。
4. model名・Token閾値・agent数等の暫定候補を採用Decisionと混同しない。
5. Task A〜DのDecisionを改訂する場合は、対象ID、衝突、代替案を示して人間判断へ戻す。
6. orchestratorが正本へ反映した後もsessionを存続し、対象version/hash、全handoff IDの対応、
   正本文、統合・言換え・保留・未反映を受け取って項目別に再照合する。
7. `CANONICALIZATION_PASS`または`CANONICALIZATION_REVISE`を返すまでTask Eを完了扱いにしない。

転記完全性確認はfresh独立reviewや人間approvalの代替ではない。Task Eの壁打ち中にRequirements、
Design、Tasks、実装を開始せず、Discovery統合DQ PRがmergeされるまでRequirements生成へ進まない。
