# Brief: SDDハーネス軽量化

## 課題

`sdd_base_template`のSDDハーネスは、人間承認、TDD、独立レビュー、変更記録を組み合わせて
信頼性とトレーサビリティを高めている。一方で、エージェントが読む・生成するコンテキスト、
仕様化から実装までの所要時間、必須文書数、人間が承認時に読む情報量が大きい。

平易な日本語表現を採用しても、抽象語、暗黙の前提知識、文書間の重複、判断事項の埋没が残る。
品質保証を弱めるのではなく、必要な判断と証跡を少ないToken・短い時間・小さい認知負荷で扱える
ハーネスへ再設計する必要がある。

## 利用者と期待する変化

- 開発者は、タスクの規模とリスクに見合うエージェント構成とSDD工程を選択できる。
- 人間の承認者は、詳細証跡を失わず、判断に必要な具体的情報を短時間で確認できる。
- テンプレート保守者は、軽量化による品質低下をToken・時間・文書負荷・欠陥検出率で比較できる。
- Claude CodeとCodexのどちらでも同じ分類、承認境界、成果物、レビュー強度が適用される。

## 検討する設計軸

### 1. エージェント構成とToken効率

- 主agentがオーケストレーションと通常作業を兼任し、必要な実装・review工程だけsubagentを交代起動する
  流動型を基準とする。
- taskのTier・risk・役割に応じて、主agent・実装agent・独立reviewerへどの能力区分のmodelを割り当てるか、
  model routingとfallback条件を定義する。
- Tokenはagent数ではなく、agent別input・output・推論、重複context、cached input、context envelopeで制御する。
- active subagentは通常1体までとするが、累計起動数に固定上限を置かない。起動数は異常検知・計測値として扱う。
- 複数subagentの同時利用は、独立責務、非重複file、context見積もり、時間短縮、統合方法を示し、
  人間が例外承認した場合だけ認める。
- 制限context自己reviewはTier Sかつ低riskの標準reviewと、Tier L・高riskのfresh review前処理に利用する。
  fresh reviewが必須な経路では代替として扱わない。

#### 採用する独立review gate

| 経路 | fresh独立review | 内容 |
|---|---|---|
| Tier Sかつ低risk | 原則なし | 主agentが各gateで制限context自己reviewを行い、人間approvalは維持する |
| Tier Lかつ高riskでない | 2回 | 実装許可前にrequirements・design・tasks bundleをreviewし、実装完了時にdiff・test・traceabilityをreviewする |
| 高risk | 最低3回 | requirements approval前、実装許可前、実装完了時にreviewする |

- 実装途中でも、認証・data移行・公開契約・infra topology・外部副作用・AI data/permission/cost等の
  高risk境界を越え、後続taskが依存する単位には追加checkpointを置く。
- 全実装taskを一律にfresh reviewせず、risk boundaryと機能完了をreview単位とする。
- gateごとにfresh reviewerを1名起動し、そのgateの収束確認は同じreviewerを最大10巡まで再利用する。
  別gateではfresh reviewerを起動する。変更で対象hashが変われば、該当reviewと人間approvalを無効化する。
- reviewerは批判的・証拠ベースで全観点を初回に一括確認し、後発指摘は`LATE_FINDING`として扱う。
- Tier Lのbundle reviewで承認済みrequirementsまたはdesignの変更が必要になった場合は、該当gateへ戻り、
  古いapprovalを無効化して再承認する。

#### Subagent contextとupstream規則

- implementerにはtask ID、対応AC、関連design節、対象file、test subset、安全規約だけを渡す。
- reviewerにはgate、対象hash、正本path、diff、対応AC・design・task、test証拠、review観点だけを渡し、
  親の結論や会話全文を渡さない。正本とdiffはreviewerが直接確認する。
- 同じ正本を親の長い要約とfile読取の両方で重複投入しない。
- cc-sdd `kiro-impl`のtask単位subagent dispatchと本契約が衝突する場合は、overlayで既知節を明示的に
  置換・無効化する。upstream変更で安全に適用できない場合はfail-closedとし、Claude Code/Codex双方で検証する。

### 2. SDD工程と成果物

- 要件、設計、タスク、合意、テスト結果、結合試験記録の責務と重複を棚卸しする。
- タスクの規模だけでなく、公開契約、データ損失、外部連携、不可逆性などのリスクで工程を調整する。
- 人間が判断する文書と、機械が保持・検証する証跡を分ける。

#### 採用する正本文書の責務モデル

標準file構成とapproval gateは維持するが、情報の種類ごとに所有する正本文書を一つに限定する。
下流文書は上流文書の本文を再掲せず、数値requirement ID、acceptance criteria ID、design節、task IDを
参照する。すべての一次成果物が同じ情報を重複して正本化する状態を認めない。

| 文書 | 固有責務 | 重複させない情報 |
|---|---|---|
| `brief.md` | discovery段階の問題、背景、初期仮説、未決事項 | 承認済みrequirementの再掲 |
| `requirements.md` | 利用者が必要とする結果、acceptance criteria、対象外、制約、risk | file名、algorithm、内部実装方式 |
| `design.md` | 実現方式、構成、公開契約、data、障害時動作、security、rollback、test方針 | requirement本文とacceptance criteriaのcopy |
| `tasks.md` | 実装順序、依存関係、TDD単位、observableな完了条件 | 設計理由、詳細仕様、requirement本文 |
| `agreement-log.md` | 人間の判断、その理由、却下案、保留事項 | 現在仕様の全文、approval状態の二重管理 |
| `spec.json` | Tier、risk、phase、approval状態、対象hash等の機械状態 | 長い人間向け説明 |
| `test-results.md` | 実行command、環境、RED/GREEN、実結果、失敗証拠 | 実行予定のtest設計とrequirement本文 |
| `integration-test-checklist.md` | 人間または外部環境で確認する項目と実施結果 | 自動test済み項目の再掲 |

traceabilityは本文copyではなく、`requirement/AC → design節 → task → testまたはmanual確認`の参照chainで
維持し、参照切れ、未対応、orphanを意味的に検証する。Tier S/Lで文書体系は変えず、記載の深さを変える。

#### 採用するtest証跡モデル

- `test-results.md`は常時必須とし、機械的に合否判定できるunit、component、contract、integration、
  E2E、non-functional testの実行証拠を記録する。
- test層と実行方式は別軸で記録する。実行方式はautomated、environment-assisted、manualを区別する。
- acceptance criteriaの正本は`requirements.md`、test方針・層は`design.md`、機械実行可能なtest case詳細は
  test code、実際の実行事実は`test-results.md`を正とする。
- `test-results.md`はtaskまたはtest group単位で通常結果を集約し、失敗、skip、未検証、例外だけを詳述する。
  全test case本文や全logをMarkdownへ転記しない。
- 振る舞いを追加・変更するtaskは、対応AC、test層、test code参照、RED証拠、GREEN証拠が揃わなければ
  完了扱いにしない。
- source path、stable test IDまたはselector、実行command、環境、revisionを記録し、参照切れ、ID重複・欠落、
  AC未対応、orphan、skip・未実施の非表示を意味的検証で拒否する。
- `integration-test-checklist.md`は、人間の操作・判断、外部環境、運用確認が残る場合だけ必須とする。
  要否はdesign承認時に理由付きで宣言し、判定不能なら必須とする。不要とする場合は、全ACの機械検証を
  `test-results.md`で証明する。

##### `integration-test-checklist.md`の内容とlifecycle

- file名は互換性のため維持し、人間向けには「手動・実環境受入checklist」と位置づける。
- 対象spec・task、revision、環境、実行者・日時、manual確認が必要な理由、対応AC・design節・task IDを記録する。
- 必要な環境・account・権限・test data、外部送信等の副作用、停止条件、後片付け・rollbackを事前条件として記録する。
- 各確認項目はstable ID、区分、事前条件、再現可能な操作、観測可能な期待結果、実際結果、証拠、
  `PASS / FAIL / BLOCKED / NOT_RUN`、実行者・日時を持つ。
- requirements全文、design理由、task説明、自動test結果、無関係な汎用check、長大なlog、secret・PIIを転記しない。
- manual確認が必要な場合はtasks承認前に確認項目を作り、tasks gateで実装後の確認内容を人間が把握する。
  実装後、人間だけが実際結果と判定を記録する。独立したapproval gateは追加しない。
- `FAIL / BLOCKED / NOT_RUN`が残る間は完了扱いにしない。実装後に確認対象・期待結果・riskを変える必要が
  生じた場合はdesign gateへ戻す。

### 3. 人間レビューの負荷

- 要求を、主体・条件・動作・観測可能な結果・対象外が分かる表現へ改善する。
- 抽象語と暗黙の前提を検出し、承認者が追加知識なしに判断できる情報を提示する。
- 正本の文書構成は維持し、人間は各gateでその工程固有の判断事項と工程間の整合性を確認する。
- 個別specごとのreview文書は作らず、正本を直接確認するための恒久的なreview guideを用意する。
- 承認時のagent出力は正本の代替要約ではなく、対象file・section、変更範囲、判断事項、未解決指摘を示す
  navigationとして扱う。
- 同じ文章の反復読解は求めないが、要件から設計、設計からtaskへの対応漏れ・解釈変更は確認する。

## Boundary Candidates

### In scope

- タスクの規模・リスクに応じたエージェント数、役割、起動条件、停止条件
- 実装・review等の役割、Tier、riskに応じたmodel routing、model能力要件、fallback、利用modelの記録
- Tierとリスク分類、承認ゲート、独立レビュー適用範囲の関係
- 一次成果物、恒久的な人間review guide、機械証跡の責務と最小構成
- 人間が判断可能な具体的記述基準とレビュー提示順
- requirements、design、tasks等のSDD標準出力文書とAI独立review結果の両方で、抽象語・暗黙の前提を避け、
  必要な固有名・system名・EARSトリガーキーワード等を除いて基本的に日本語で出力するための基準
- 現行方式と候補方式を比較するToken・時間・品質・人間負荷の計測方法
- Claude Code / Codex両環境への同一ルール配布と検証

### Out of scope

- Issue #32が所有するスキル検出・起動パリティ機構そのものの再実装
- Issue #30が所有するsyncの一般的なマージ・競合処理
- Issue #33が所有するcc-sddバージョン昇格ライフサイクル
- cc-sddのソースまたは生成物を`payload/`へ再配布する設計変更
- 人間承認、TDD、main直接コミット禁止を撤廃する変更

### Related contracts

- Issue #39はfresh subagent独立レビュー、fail-closed、人間承認非代替、基本1レビュアー、
  批判的な姿勢、同一レビュアーによる収束、最大10巡、推論能力またはcode review能力の高いmodelの利用を
  所有する。本specが適用範囲やmodel要件を変更する場合は、#39への影響と移行順を明示し、
  人間承認なしに上書きしない。
- Issue #32はClaude Code / Codexパリティを所有する。本specの実装は#32の配布・検証境界へ接続する。
- Issue #37は成果物分類と保存方針を所有する。本specは一次成果物、人間review guide、承認時navigationを扱うが、
  保存方針を無断で変更しない。

## 比較時に計測する項目

- 主・サブ別Token、サブエージェント起動数、会話ターン数、投入コンテキスト量
- 依頼から各承認、実装完了までの経過時間と人間待ち時間
- 必須文書数、総文字量、重複率、人間が実際に読む量
- 人間のレビュー時間、確認往復数、判断不能だった箇所
- 要件からテストへの追跡率、承認後の差し戻し、回帰、独立レビューの有効指摘率

## 初期の成功状態

信頼性とトレーサビリティを維持する不変条件が明示され、タスク分類ごとのエージェント構成、
必須工程、正本成果物、人間review guide、承認時のnavigationが比較可能な形で定義される。代表タスクを用いた
現行方式との比較方法があり、Token削減だけでなく、時間、人間負荷、欠陥検出を含めて採否を判断できる。

## 合意済みの基準

- cc-sddをSDDハーネスの基盤とする基本方針を維持し、kiro command、標準成果物名、phase順、
  approval metadata、数値requirement IDとの互換性を原則として保つ。
- 文書責務の整理と重複削減は、cc-sddの全面forkや独自文書体系への置換ではなく、overlayによる
  生成規則の追加・厳格化と意味的検証で実現する。
- cc-sdd互換境界からの例外が必要な場合は、理由、代替案、upgrade・sync・parityへの影響を提示し、
  人間の明示承認を得るまで採用しない。
- Tier Lまたは高リスク変更: fresh subagentによる独立レビューを必須とする。
- Tier Sかつ低リスク変更: 主エージェントの制限レビューと人間承認を標準とする。
- リスク判定はTierより優先し、高リスク条件が1つでもあれば独立レビュー対象へ昇格する。
- 人間承認はどちらの経路でも必須とし、自動レビューで代替しない。
- 独立レビューを実施するゲートの回数と位置は、次の壁打ちで決定する。

## 高リスクの自動昇格条件

以下のいずれかに該当する変更は、規模が小さくても高リスクとして扱う。

- データの削除、移行、上書き、復旧困難な変更
- 認証、認可、秘密情報、PII、security boundaryの変更
- 公開API、CLI、protocol、file format、schema、互換性契約の変更
- deploy、課金、通知、外部サービスなど、システム外へ副作用を発生させる変更
- 並行処理、transaction、rollback、障害復旧の変更
- 人間承認、独立レビュー、TDDなど、SDD安全規約そのものの変更
- nodeの追加・削除・置換、外部nodeとの新規接続、routing、負荷分散、failover、replicationの変更
- network、DNS、TLS、権限、security groupなど、infraの接続・trust boundaryの変更
- 性能劣化、停止、resource枯渇を起こし得るtimeout、pool、並列数、cache、autoscaling等のparameter変更
- productionへAI機能を追加・変更する場合。ただし隔離されたread-only補助機能として後述の条件を
  すべて証明できる場合だけ、自動昇格から外せる
- テストできない実環境依存、または安全性・後方互換性を証明できずリスク判定が不明な変更

AI機能を自動昇格から外すには、production外または限定利用、公開・合成データのみ、read-only、
tool実行なし、人間確認必須、Token・回数・時間・費用のhard limit、model・設定の固定、
出力schema検証と安全なfallback、送信先・保存期間・logの確認、代表evalと回帰試験をすべて満たす。

## 複数該当時の昇格材料

以下は単独では高リスクにせず、組み合わせと影響範囲で昇格を判断する。

- 外部契約と結果を維持した、既存systemを包含する性能向上・後方互換な機能追加
- 既存topology内での単純なresource増強
- 複数module・repositoryを横断する変更
- 新しい外部依存の追加
- 実装量、変更file数、利用者・teamへの影響範囲が大きい変更
- rollback手順または監視方法が未確定な変更

ただし、包含的・追加的な変更でもnode topology、trust boundary、data配置を変える場合は自動的に
高リスクとする。性能向上や後方互換を試験・計測で証明できない場合は、判定不能として高リスクへ昇格する。
