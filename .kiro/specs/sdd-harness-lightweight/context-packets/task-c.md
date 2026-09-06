# Task C context packet: 正本文書・人間review・日本語・追跡可能性

> 作成日: 2026-09-06
> 親Issue: #41
> 前提Task: Task A、Task B（人間承認・DQ PR merge済み）
> 状態: 壁打ち開始前。実装、template変更、Issue再編、commit、push、PR、repository renameは行わない。

## 1. Taskの目的

Kiro互換のfile・workflow・approvalを維持したまま、SDD文書の情報所有を一意にし、文章の重複、
抽象表現、暗黙の前提、人間の反復review、agentへの重複context投入を減らす。

あわせて、長時間sessionを安全に分割するための最小handoffについて、既存の正本を複製しない情報責務を決める。
Task Cは文書・情報のcontractを決めるDiscoveryであり、具体的なschema、validator、hook、platform設定を実装しない。

## 2. Task A・Bから引き継ぐ不変条件

### Kiro互換と品質

- SDD RigはKiro/AWS/cc-sddの公式、提携、後継を名乗らない独立製品である。
- V1は定義済みの外部workflowについて構造互換と起動互換を保証する。
- 既存`.kiro/`、未完成spec、既知の`spec.json` schema・phase・approval metadata、未知field、
  `SDD-BASE:*` marker、旧lock/snapshot、旧入口を非破壊で扱う。
- 人間承認、TDD、Claude Code/Codex parityを弱めない。
- 現行の品質目的機能を根拠なく廃止しない。衝突時は影響、代替案、回帰testを示して人間判断へ戻す。

### source・所有権・license

- SDD Rigはcc-sdd `v3.0.2`、commit `3795eb4274c07dedcf56c571b5c0a826736f23c8`、
  `tools/cc-sdd`を初期固定参照元とする一方向forkである。
- release後に継続upstream baseline・同期機構を常設せず、SDD Rig sourceを運用上の正本とする。
- architectureはSDD Rig core、Claude adapter、Codex adapter、project override、legacy bridgeへ分ける。
- project overrideと所有者不明の資産は利用者所有として扱う。
- cc-sdd MIT LICENSE全文、`Copyright (c) 2025 gotalab`、固定provenance、独立・非提携説明を保持する。
- license、引用、code、identifier、schema値、path、raw log等の完全一致が必要な原文は、日本語化や平易化で変更しない。

## 3. 壁打ち済みbaseline

次は採用済みの開始baselineである。ただし、正式Requirementsへ変換する前にTask Cで反例を用いて再確認し、
不整合や過剰負荷があれば改訂案を人間へ戻す。

### 3.1 一情報一正本

標準file構成とapproval gateは維持し、下流文書は上流本文をcopyせず、stable IDまたは節を参照する。

| 文書 | 固有責務 | copyしないもの |
|---|---|---|
| `brief.md` | Discoveryの問題、背景、初期仮説、未決事項 | 承認済みrequirement本文 |
| `requirements.md` | 利用者が必要とする結果、AC、対象外、制約、risk | file、algorithm、内部実装 |
| `design.md` | 実現方式、構成、公開contract、data、障害時動作、security、rollback、test方針 | requirement・AC本文 |
| `tasks.md` | 実装順、依存、TDD単位、観測可能な完了条件 | 設計理由、詳細仕様、requirement本文 |
| `agreement-log.md` | 人間Decision、理由、却下案、保留 | 現在仕様全文、approval状態 |
| `spec.json` | Tier、risk、phase、approval、hash等の機械状態 | 長い説明 |
| `test-results.md` | command、環境、RED/GREEN、実結果、失敗証拠 | test設計、requirement本文、全log |
| `integration-test-checklist.md` | 人間・外部環境・運用上の確認手順と判定 | 自動test結果、正本全文 |

`integration-test-checklist.md`は人間判断、手動操作、外部環境、運用確認が残る場合だけ必須とし、
要否をDesign承認時に理由付きで宣言する。

### 3.2 人間review

- 個別specごとのreview要約文書は作らない。
- 全spec共通の恒久review guideと、gateごとの動的navigationを使い、人間は正本を直接確認する。
- 同じ内容の再読を要求せず、各gate固有の判断と工程間の意味変換に注意を向ける。
- navigationは対象/hash、material Decision、正本参照、意味変更、review/検証、risk/例外、承認選択肢を示す。
- 必須観点を`APPLICABLE / NOT_APPLICABLE / BLOCKED`に分類し、理由のない非該当を認めない。
- 自動reviewは人間承認を代替しない。

### 3.3 言語・具体性

- SDD、steering、review、navigationを含むagent生成・更新の人間可読文書は、明示指定がなければ日本語を既定とする。
- 他言語指定、対象読者・公開先・外部contract、既存文書の言語維持、証拠・license・引用等の原文保持を例外とする。
- 規範文は、主体、条件、対象、観測可能な結果、数値または判定方法、例外を必要に応じて明示する。
- 規範文の未定義な抽象表現は`BLOCKED`、非規範文ではwarningとする。
- requirementsはKiro互換の`The / When / While / If / Where / shall` keywordを維持し、
  条件・主体・応答を日本語で記述する。1 ACは1つの検証可能な振る舞いだけを所有する。
- schema名、system名、固有名、code、command、path、raw error、hash、version、protocol文字列は無理に翻訳しない。

### 3.4 test証跡

- ACは`requirements.md`、test方針は`design.md`、test case詳細はtest code、実行事実は`test-results.md`を正本とする。
- `test-results.md`ではunit、component、contract、integration、E2E、non-functionalと実行方式を識別する。
- 振る舞い変更taskはAC、test層、test code参照、RED/GREEN証拠を持つ。
- 通常結果はgroup集約し、失敗、skip、未検証だけを詳述する。

## 4. 追加input: コンテキスト予算・セッション継続管理

参照artifact:
`https://claude.ai/code/artifact/70567fa6-9d3b-4fc4-886c-b4e6b98f6656`

Claude Codeの単一project実測では、2か月継続したsessionが2,258 request、総input約11.1億Token、
平均context約49.3万Token、最大約93.4万Tokenに達し、auto-compactは1M上限直前で5回発生していた。
200Kでの手動compactは約70%削減とのsimulation結果だが、compact後100K等の仮定を含むため一般保証に使わない。

承認済みの対策階層は次のとおり。

1. 正本と最小handoffから再開する計画的session分割を主策とする。
2. 安全な分割点へ到達できない長期taskでは、保持対象を指定した早期compactを安全弁とする。
3. platform固有auto-compact上限は、利用可能な場合の任意の最終防波堤とする。

Task Cでは、session checkpointを新しい仕様正本にせず、正本参照型の派生manifestとして成立させる。
最低候補fieldは次のとおりだが、必要性、所有元、更新主体、保存期間を壁打ちで絞る。

- spec ID、task ID
- approval gateと対象hash
- branch、commit、worktree
- dirty/untracked状態
- 完了事項、残作業、blocker
- 次の具体的な一手
- 必要な正本path

session分割は自動commit/pushを要求しない。未承認・不完全な差分をcheckpoint名目でcommitしない。
global設定を無断変更せず、project設定も非破壊差分と人間承認を必要とする。raw transcriptをrepositoryへ保存・
外部送信せず、計測はlocal opt-inかつusage metadata中心とする。

Task Eはbudget・分割・compact判定、Task Fはplatform adapter・設定・fresh-session E2Eを所有する。
Task Cは、それらが利用する情報contractと、人間が安全に再開可能か判断するnavigationだけを決める。

## 5. この壁打ちで決める事項

### C-1. 文書ごとの正本責務とlifecycle

- baseline表の責務で不足・重複・循環参照がないか。
- Discovery Decisionを`brief.md`と`agreement-log.md`のどちらへ残し、いつ現在仕様へ昇格・履歴化するか。
- `spec.json`へ持たせる機械状態と、Markdownにだけ残す理由・説明の境界。
- optional文書の要否判定、作成時点、廃止・archive方法。
- steering、人間主導の任意文書、将来追加文書を同じ所有原則へどう含めるか。

### C-2. stable ID・参照・意味的整合

- requirement、AC、design節、task、test、Decision、findingのID contract。
- rename、節移動、分割・統合時に参照をどう維持するか。
- 本文copyではなく参照で意味が追跡できる最低情報。
- dangling reference、重複ownership、approval hash不一致を何で検出するか。
- 既存Kiro互換ID・未知fieldを壊さず追加できるか。schema変更が必要なら人間判断へ戻す。

### C-3. 人間review guideとapproval navigation

- guideに常設する共通観点と、gateごとに動的生成する項目の境界。
- requirements、design、tasks、実装完了で人間が確認する内容と再読不要な内容。
- `APPLICABLE / NOT_APPLICABLE / BLOCKED`の判定者、理由、停止条件。
- 正本の代替要約を作らず、変更箇所とmaterial Decisionへ到達させる方法。
- 自然言語approvalを誤認しない対象/hash/revisionの提示方法。

### C-4. 日本語・具体性・例外

- 「具体的で人間が判断可能」を機械検証・AI review・人間判断へどう分けるか。
- 必要な概念語まで禁止しない抽象表現の判定方法。
- EARS keywordと日本語本文の混在format、1 AC 1振る舞いの境界例。
- steering、運用手順、review finding、test証跡、任意文書への適用差。
- license、引用、外部contract、raw証拠、既存言語を変更しない例外と、その明示方法。

### C-5. session checkpointの情報責務

- checkpointを既存file内の節、単一の派生manifest、一時生成物のどれにするか。
- どのfieldを正本から参照し、どのsession固有deltaだけを保持するか。
- clean checkpointとdirty worktree checkpointの違い、同一worktreeを引き継げない場合の停止条件。
- compact、新session、別agentへのhandoffで共通利用できる最小format。
- checkpointの更新、stale判定、archive、git管理、PII・秘密情報の扱い。
- 人間が「この状態から安全に再開できる」と判断するnavigation。

### C-6. Task Bの製品説明・NOTICEへの反映

- 「cc-sddをベースに開発した独立製品」と、Kiro/AWS/cc-sdd非公式・非提携の表示位置。
- cc-sdd MIT LICENSE、著作権、provenanceへ到達させる文書責務。
- ハーネス利用だけで利用project App全体へlicenseが自動伝播しないことと、実コピー時の帰属を誤解なく説明する。
- 日本語説明と変更してはいけないlicense原文を混同しない。

### C-7. Tier別の記載深度

- Tier S/Lでfile体系を変えず、どの情報の深さだけを変えるか。
- 高riskを文書量増加と直結させず、追加すべきDecision・証拠だけを特定する方法。
- 下流参照のために省略できない最低field。
- Token削減、人間review時間、traceability、不整合検出をどう比較するか。

## 6. 比較する候補

### session checkpoint配置

| 候補 | 長所 | 主なrisk |
|---|---|---|
| `agreement-log.md`の一節 | file追加がない | Decision履歴と一時session状態が混ざる |
| `spec.json`の機械field | stale検出しやすい | schema互換、未知field、長い説明に不向き |
| `.kiro/specs/<id>/session-handoff.md`等の単一派生manifest | 人間・agentが発見しやすい | 第三の正本化、更新忘れ、git差分増加 |
| git管理外のlocal state | 頻繁に更新できる | 別環境・別worktreeから再開できない |
| 既存正本＋実行時生成navigationのみ | 重複が最小 | session固有のdirty状態・次の一手を失う |

単独案へ早期固定せず、clean/dirty、同一worktree/別worktree、Claude/Codex、新session/compactのcaseで評価する。

### review navigation

- 正本fileと変更節へのlinkだけを提示する。
- machine-readableな変更manifestから動的navigationを生成する。
- git diffとID graphから対象を導出する。

navigation自体が新しい正本や長い要約にならないことを必須条件とする。

## 7. 対象外

- requirements/design/tasksの実file生成とapproval
- template、skill、validator、hook、CLI、platform設定の実装
- 200K/500K等の最終閾値と通知UI: Task E/F
- Claude/Codexのcompact機能を同一setting keyにすること: Task E/F
- 既定PPT、phase profile、意味変換、visual QA: Task D
- source directory、build tool、initial cc-sdd import: #33/#34とDesign
- repository/package/CLI renameの実施
- raw transcriptの収集・repository保存・外部送信

## 8. 必ず行う批判的確認

- 「重複削減」を理由に、下流で判断に必要なcontextまで消していないか。
- stable IDだけで意味が分かると過信し、参照先を大量に往復させて人間負荷を増やしていないか。
- review navigationやsession handoffが第三・第四の仕様正本になっていないか。
- 日本語化がlicense、引用、API、schema、protocol、raw証拠を改変していないか。
- 抽象語検査が単語blacklistになり、必要な概念語や簡潔な文を不合理に拒否していないか。
- Tier Sを理由に、公開contract、data、security、rollback情報を省略していないか。
- checkpointのために未承認変更をcommit/pushさせていないか。
- dirty worktreeを別sessionから安全に再開できないのに、handoff作成だけで成功扱いしていないか。
- platform固有のcontext値が取得不能なのに0または安全として扱っていないか。
- transcript解析が秘密情報・prompt・file本文を過剰に読み取り、保存・外部送信していないか。

## 9. 参照先

### repository

- `.kiro/specs/sdd-harness-lightweight/brief.md`
- `.kiro/specs/sdd-harness-lightweight/agreement-log.md`
- `.kiro/specs/sdd-harness-lightweight/spec.json`
- `.kiro/specs/sdd-harness-lightweight/handoffs/task-a.md`
- `.kiro/specs/sdd-harness-lightweight/handoffs/task-b.md`
- `payload/overlay/docs/sdd/workflow.md`
- `payload/overlay/docs/sdd/rules/japanese-writing-style.md`
- `payload/overlay/docs/sdd/rules/testing-policy.md`
- `payload/overlay/docs/sdd/rules/commit-policy.md`
- `payload/overlay/docs/sdd/templates/`
- `payload/overlay/snippets/CLAUDE.sdd.md`
- `payload/overlay/snippets/AGENTS.sdd.md`

### external evidence

- Claude Code context artifact: `https://claude.ai/code/artifact/70567fa6-9d3b-4fc4-886c-b4e6b98f6656`
- Claude Code context window: `https://code.claude.com/docs/en/context-window`
- Claude Code settings: `https://code.claude.com/docs/en/settings`
- Claude Code environment variables: `https://code.claude.com/docs/en/env-vars`
- Claude Code hooks: `https://code.claude.com/docs/en/hooks`
- OpenAI compaction guidance: `https://developers.openai.com/api/docs/guides/latest-model?model=gpt-5.2`

外部仕様は壁打ち開始時に再確認し、provider固有機能を共通contractとして断定しない。

## 10. 期待するstructured handoff

Task C完了時は、次をorchestratorへ返す。

1. 採用する文書責務表とlifecycle
2. stable ID・参照・意味的整合contract
3. 人間review guideとgate別navigation
4. 日本語・具体性・原文保持の規則
5. session checkpointの配置、field、正本との境界、stale・dirty状態の扱い
6. Task Bの製品説明・NOTICEへの反映条件
7. Tier別の最小情報と省略条件
8. 却下案と理由
9. 未決事項、Requirements/Designへ送る項目
10. Task D/E/F、#32/#37/#39への影響

Task Cはrepository file、GitHub Issue、approval状態を変更しない。orchestratorがhandoffをcross-checkし、
人間が承認した後だけagreement-logとIssueへ固定する。criticalな互換性、license、security、正本二重化、
Claude/Codex parityの衝突は自動解決せず、壁打ちを止めてorchestratorと人間判断へ戻す。
