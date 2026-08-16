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

#### 採用するmodel routing

- model名ではなく、最低能力要件として`Standard / Critical / Mechanical`の3 classを定義する。
  実modelはprovider別の更新可能な対応表で解決し、特定versionをpolicy本文へ永久固定しない。
- 想定対応はClaude Codeで`Standard = Sonnet 5`、`Critical = Opus 5または適格な特化model`、
  `Mechanical = Haiku`、Codexで`Standard = 5.6-terra`、`Critical = 5.6-solまたは適格な特化model`、
  `Mechanical = 5.6-luna`とする。利用できないmodelは将来候補として扱う。
- `Standard`は主agent、仕様作成、通常実装、制限context自reviewの基準とする。`Critical`はfresh独立reviewと
  高難度の設計・debugに必須とする。高riskはreviewを強化し、実装者の`Critical`昇格は難度で判定する。
- `Critical`はmodel familyだけでなく、high相当以上の推論設定と、`spec-review / code-review / security-review`等の
  対象に適した能力を満たす。一般のcode review特化modelをすべての文書reviewへ無条件に使用しない。
- `Mechanical`はID抽出、format変換、hash、schema・参照検査、test結果集計等の非判断作業だけに使う。
  risk、requirement、design、test充足性、finding重大度、省略可否を判断させない。
- classは最低能力とし、上位classによる代行と、管理済み対応表内の同等modelへの解決を認める。
  `Critical`からの降格は禁止し、対応表外・能力不明は人間判断まで停止する。provider越えの代替も人間承認を要する。
- review収束中のmodel IDまたは推論設定の変更はreviewer交代とみなし、そのgateのfresh reviewを最初からやり直す。
- role、required class、解決model・推論profile・能力tag、provider/環境、選定理由、fallback、input hash、
  取得可能なToken、retry、実行日時を簡潔な証跡として残す。
- model routingは単価・品質・手戻りの最適化であり、model変更だけでToken数削減とはみなさない。
  input/output/reasoning/cached Token、retry、費用、時間を合わせて評価する。

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

#### 採用する人間review guideとnavigation

- 全specで共用する恒久review guideを1つ配布し、各spec用のreview文書は作らない。guideは
  gateごとの人間の判断責務、確認する正本、再読不要の範囲、前工程へ戻す条件、承認不能状態だけを定義する。
- requirements gateでは問題・期待結果・対象/対象外・観測可能性・risk・制約・未決事項を確認し、
  file構成・algorithm・内部APIを人間の承認対象に混ぜない。
- design gateではrequirement/AC対応、意味変更、公開契約、data、security、障害時動作、rollback、test方針、
  manual checklist要否を確認し、requirements本文を再掲しない。
- tasks/実装許可gateではdesignの網羅、依存順、TDD単位、高risk checkpoint、manual確認項目、並列作業の
  責務分離、前工程の変更をtaskへ隠していないことを確認する。
- 実装完了gateではscope、ACからtestへの参照、RED/GREEN・revision・環境、failure/skip/未検証、
  manual結果、必須独立review、残存risk、rollbackを確認し、全diff・全logの読解を標準にしない。
- 承認時のagentは、対象phase/spec/hash/revision、人間が決めるmaterial decision、正本file・section・ID、
  前工程からの意味変更、review/検証状態、risk/例外、承認・局所修正・前工程戻し・説明要求の選択肢の順で
  navigationを提示する。3〜7件は見やすさの目安であり、重要判断を隠す上限にしない。
- 必須観点は内部的に`APPLICABLE / NOT_APPLICABLE / BLOCKED`のいずれかへ分類し、`NOT_APPLICABLE`には理由を要求する。
  blocking finding、stale/未実施review、risk不明、参照切れ、工程間矛盾、必須test欠落、manual未完了、隠れたscope変更が
  ある場合は承認依頼を出さず、承認不能の理由を報告する。
- 自然言語の承認は、直前のgateと対象が明確で、「承認する」「この内容で進めてよい」「OK、次へ進めて」等の
  明確な意思がある場合に限る。「よさそう」「概ね問題ない」「たぶんOK」、一部同意、質問への回答はapprovalとして記録しない。
- 本基準は人間が採用した仮説であり、requirements化後のCritical fresh独立reviewで、省略・見逃し、
  承認表現の曖昧性、cc-sdd互換性、人間負荷とtraceabilityの均衡を反例ベースで再検証する。

#### 文書出力基準の適用対象

- 固定file名ではなく、SDDハーネス、`kiro-*` skill、またはその指示を受けたagentが生成・更新する、
  人間が読むことを目的としたすべての文書・説明出力を対象とする。
- `.kiro/specs/`、`.kiro/steering/`、custom steering、roadmap、research、review、validation、debug、status、
  将来のcc-sddが追加する文書、人間主導で生成するREADME・運用手順・設計補足等をfile名に依存せず含める。
  一次成果物から生成するPDF/Word/PowerPoint等の二次成果物にも源泉の基準を引き継ぐ。
- 適用判定は拡張子ではなく内容単位で行う。JSON/YAML等の人間向け説明には適用するが、
  schema key・enum・status、code/identifier/API field、command/option/path、raw log/error、hash/version、
  外部仕様の引用、license原文、vendored/upstream文書、完全一致が必要なprotocol文字列は変更しない。
- 主体・条件・動作・結果・例外の具体化、抽象語と暗黙前提の排除、正本重複の防止、事実・推論・未確認の区別は
  言語に関係なくすべての対象文書へ適用する。
- SDD標準文書、steering、review/validation/debug報告、承認navigation、出力言語未指定の人間向け文書は
  日本語を既定とする。人間の明示言語指定、対象読者・公開先・外部契約の言語要求、既存文書の言語維持、
  証拠・互換性・licenseの原文保持が必要な場合だけ他言語を認める。他言語でも具体的記述基準は免除しない。
- 明示要求がない日本語・英語の全文併記は、Tokenと人間の読解量を増やすため行わない。

#### 具体的記述とreview finding

- 要件、契約、指示、承認済み判断等の規範文で、判定基準・数値・責任主体・例外のない抽象表現は
  `BLOCKED`とする。背景・仮説・説明の非規範文ではwarningとするが、判断根拠に用いる場合は具体化を要求する。
- 「適切に」「必要に応じて」「十分な」「安全に」「効率的に」「柔軟に」「可能な限り」「原則として」「等」「最新」
  「容易に」「高性能」等は禁止語とせず、対象者が同じ判定を再現できる条件が付いているかで判定する。
- requirementsはcc-sdd互換性のため`The / When / While / If / Where / shall`のEARS構文keywordを維持し、
  条件・主体・応答を日本語で記述する。1 acceptance criterionは1つの検証可能な振る舞いだけを所有する。
- 一文1判断、明示的な主語、対象ID・名称による参照、二重否定の回避、閾値・期限・失敗時動作の明示を基準とする。
  「これ」「それ」で正本対象を曖昧にしない。未決事項は確定事項と分離する。
- 独立review findingはID、`CRITICAL / HIGH / MEDIUM / LOW`の重大度、`BLOCKING / ADVISORY`の承認影響、
  対象、違反契約、証拠、証拠からの推論、具体的な失敗例、必要修正の結果、観測可能な完了条件を持つ。
- 重大度と承認影響は別軸とし、`BLOCKING`が1件でもあれば`PASS`を禁止する。判定に影響する未確認は`UNVERIFIED`として隠さない。
  初回reviewで全findingを一括提示し、収束中の新規指摘は`LATE_FINDING`とする。
- findingの必要修正は満たすべき結果を示し、承認済みdesignの範囲を超えて実装方法を過剰指定しない。
  findingがない場合は網羅観点と「findingなし」だけを示し、称賛・一般論・長い要約を追加しない。
- 本記述・finding基準もrequirements化後のCritical fresh独立reviewで、抽象語判定の過剰/不足、EARS互換性、
  finding構造の欠落、人間が判断できる具体性、Token・読解負荷を反例ベースで再検証する。

## Boundary Candidates

### In scope

- タスクの規模・リスクに応じたエージェント数、役割、起動条件、停止条件
- 実装・review等の役割、Tier、riskに応じたmodel routing、model能力要件、fallback、利用modelの記録
- Tierとリスク分類、承認ゲート、独立レビュー適用範囲の関係
- 一次成果物、恒久的な人間review guide、機械証跡の責務と最小構成
- 人間が判断可能な具体的記述基準とレビュー提示順
- SDD/`kiro-*`/agentが生成・更新するすべての人間可読文書・説明出力に具体的記述基準を適用し、
  明示的な言語要件や原文保持の例外を除いて日本語で出力するための基準
- 現行方式と候補方式を比較するToken・時間・品質・人間負荷の計測方法
- Claude Code / Codex両環境への同一ルール配布と検証

### Out of scope

- Issue #32が所有するスキル検出・起動パリティ機構そのものの再実装
- Issue #30が所有するsyncの一般的なマージ・競合処理
- Issue #33が所有するcc-sddバージョン昇格ライフサイクル
- cc-sddのソースまたは生成物を`payload/`へ再配布する設計変更
- 人間承認、TDD、main直接コミット禁止を撤廃する変更

### Related contracts

- Issue #41がTier・risk別のreview gate配置、model routing、agent構成のpolicy正本となる。Issue #39は
  独立したpolicy specではなく、#41配下でfresh reviewerの独立性、共通判定、hash鮮度、fail-closed、
  全入口適用、証跡、移行、validationを実装する子Issueへ再編する。#39の既存requirementsは適用gateの
  前提が変わるためstaleとし、#41確定前にdesignへ進めない。
- Issue #32はClaude Code / Codexパリティを所有する。本specの実装は#32の配布・検証境界へ接続する。
- Issue #37は成果物分類と保存方針を所有する。本specは一次成果物、人間review guide、承認時navigationを扱うが、
  保存方針を無断で変更しない。

## 移行・Issue調停方針

### 全open Issueを含む導入順

2026-08-17時点のopen Issue `#30 / #31 / #32 / #33 / #34 / #35 / #37 / #38 / #39 / #41`を
対象に、次の順を基準とする。`#34`と`#35`は独立specではなく、`#33`配下の人間管理用work taskである。

1. 本spec `#41`のrequirements、design、tasksを承認可能な状態まで確定する。
2. `#32`のClaude Code / Codex検出・materialize・semantic parity基盤を完了する。
3. `#38`のbash 3.2 / CJK PDF生成不具合を再現し、`#37`より先に修正する。
4. `#30`のsyncにおける確認、clean apply、conflict、report契約を確定する。
5. `#41`の共通policyを実装し、`#39`をそのpolicyに従う独立review機構として協調導入する。
6. `#33`のcc-sdd version lifecycleを、`#34`、`#35`の順で実装する。
7. `#31`の実行通知を、`#41`のToken・人間負荷基準と`#39`のreview境界に合わせて実装する。
8. `#37`を新policyへ移行し、`#38`修正済みのdoc-exportを前提に再開する。

`#33`、`#31`、`#37`間の順は原則としてroadmap上の順序であり、相互のhard dependencyではない。
依存をGitHub Issue全体へ設定するとrequirements等の先行検討まで不必要に止める場合は、実装phaseの依存として
Issue本文とspecに記録する。共有する`payload/overlay/`、skill、sync、doc-exportの同時実装は避ける。

### policyの優先順位と衝突時の停止

- SDDハーネス全体のagent構成、review gate、model routing、文書責務、記述基準、計測、移行については、
  `#41`を横断policyの正本として既定で優先する。
- 他Issueが所有する機能要件や成果物を`#41`へ吸収しない。衝突しない範囲では各Issueの責務と承認済み判断を維持する。
- 他Issueの契約がdata integrity、security、privacy、法的義務、公開互換性、復旧可能性、または人間承認の
  不変条件を保護しており、`#41`を優先するとその保護を弱める場合は、自動的に上書きしない。
- criticalな対抗契約、どちらが優先すべきか判定不能な衝突、または両立に承認済みscopeの変更が必要な場合は、
  該当gateを`BLOCKED`とし、衝突するIssue・契約・失敗例・選択肢・影響を人間へ提示して壁打ちへ戻す。
- 衝突検出は事前のIssue棚卸しだけで完了扱いにしない。requirements、design、tasks、実装、review、sync、
  acceptanceのいずれで発見しても、その時点で同じ停止規則を適用する。
- 承認後に意味上の衝突が判明した場合、影響するinput hashとapprovalをstaleにし、必要な前工程へ戻す。
  表記差または意味を変えないadapter差だけを理由に承認を破棄しない。

### 既存specの移行境界

- 完了済みspecは遡及修正・一括再reviewせず、使用したcontract versionを追跡可能にする。
- requirements未承認のspecは新policyを全面適用する。
- requirements承認済みでdesign未承認のspecは移行評価を行い、意味を維持できる本文は再利用する。
  新しいhigh-risk判定、必須情報、traceabilityが不足する場合はrequirementsへ戻す。
- designまたはtasks承認済みで実装前のspecは、書式変更だけでapprovalを破棄しない。安全条件、公開契約、
  scopeの意味が変わる場合だけ該当gateへ戻す。
- 実装中のspecは現在のatomic taskを承認済みcontractで完了し、次のtaskまたは機能完了gateで移行する。
  high-riskの保護欠落を検出した場合はatomic taskの完了を待たず停止する。
- 新policyへ移行済みのspecは、policy asset欠落やClaude Code / Codex parity失敗時に旧policyへ黙ってfallbackせず、
  fail-closedで停止する。rollbackは既存成果物、Git履歴、review・approval証跡を削除・書換えしない。

### Claude Code / Codex activation

- canonical policyのversionとhashは共通とし、invocation記法、model mapping等のplatform固有差だけをadapterへ分離する。
- byte一致ではなく`#32`のsemantic parity contractで同等性を検証する。
- 必須asset、共通policy hash、両adapter、validationが揃うまでrepositoryで新contractをactiveにしない。
- 各利用repositoryでは静的parityを確認し、両agentのlive E2Eはrelease acceptance環境で実施する。
  一方のagentしか利用しない全repositoryに、未使用providerのlive起動まで要求しない。
- 片側だけの配布・起動・policy適用を成功として報告しない。

## 比較時に計測する項目

- 主・サブ別Token、サブエージェント起動数、会話ターン数、投入コンテキスト量
- 依頼から各承認、実装完了までの経過時間と人間待ち時間
- 必須文書数、総文字量、重複率、人間が実際に読む量
- 人間のレビュー時間、確認往復数、判断不能だった箇所
- 要件からテストへの追跡率、承認後の差し戻し、回帰、独立レビューの有効指摘率

### 比較対象

比較は次の3方式を区別する。

- `B0`: 比較実施時点の現行実装。既存command、成果物、Claude Code / Codex parityの互換性回帰を検出する基準。
- `B1`: Issue #39で想定していた全gate fresh独立review方式。品質と安全性を維持したまま、どの費用を削減できたかを
  評価する基準。未実装の場合は、承認済みpolicyを固定fixture上で再現して計測する。
- `C`: Issue #41の候補方式。`B0`に対して互換性を劣化させず、`B1`が狙った安全性を維持しながら、
  `B1`よりToken・時間・人間負荷を減らすことを求める。

`B0`だけを比較対象にすると、Issue #39で予定していた安全性向上を削った結果を「軽量化」と誤判定するため、
効率比較の主対象は`B1`対`C`とする。

### 代表caseと実行順

同一のgolden manifestを持つ次の3 caseを用いる。manifestには期待risk分類、material decision、
requirementからtestまでのtrace、意図的に埋め込むblocking defectを記録する。

- `Case S`: Tier Sかつ低riskの局所変更。
- `Case L`: Tier Lの通常変更。複数module、TDD、実装許可前と完了時のreviewを含む。
- `Case H`: 認証・data・公開contract・infra・AIのいずれかを含む合成高risk変更。実環境へ副作用を出さず、
  検出すべきblocking defectを意図的に含める。

Claude CodeとCodexの双方で`B1`と`C`を比較する。provider間の生Token絶対値ではなく、同一platform内の
`B1`から`C`への変化を評価する。まずCodexで3 case x 2方式の6実行を行い、hard failureがあれば停止する。
通過後にClaude Codeでも同じ6実行を行う。結果が閾値近辺または実行揺らぎで判定不能なcaseだけを最大3回まで
再実行し、中央値を用いる。

### 計測値の定義

- Token・context: 主agent・subagent別のinput、output、reasoning、cached Token、正本の読込量、重複投入量、
  retryを記録する。providerが返さない値は`UNAVAILABLE`とし、取得できる本文量だけを同一tokenizerで補助推定する。
  未取得値を0として扱わず、実Token削減を確認済みとは宣言しない。
- 時間: agent処理、tool実行、人間待ちを分離する。人間review負荷は、同じ開始・終了条件を用いたactive review時間と、
  確認往復数、判断不能箇所で測る。
- 文書: file数だけを削減目標にせず、総token、正規化した重複率、正本情報の重複、人間が承認のために読む量、
  壊れた参照、参照元のないIDを測る。
- 品質: traceability、RED/GREEN証跡、seeded blocking defectの検出、根拠のないblocking finding、
  stale review拒否、approval bypass、手戻り、回帰、material decisionへのnavigation、Claude Code / Codex parityを測る。

### 安全性の受入条件

以下は平均や中央値で相殺せず、1件でも違反すれば候補方式を不採用または要件・設計へ差し戻す。

- 人間承認の省略または自動承認が0件。
- policy上必要なfresh独立reviewの欠落が0件。
- input hash変更後のstale review再利用が0件。
- golden manifestに埋め込んだblocking defectの見逃しが0件。
- 根拠を再現できない`BLOCKING` findingが0件。
- requirement / ACからdesign、task、testまたはmanual確認へのtraceabilityが100%。
- 振る舞い変更taskのRED/GREEN証跡が100%。
- 承認判断に必要なmaterial decisionへのnavigation欠落が0件。
- Claude CodeまたはCodexの片側でしか通らない実行経路が0件。
- `Critical`が下位classへ暗黙fallbackする事象が0件。

### 効率目標と採否

同一platform内の`B1`に対し、`C`は次を目標とする。

- end-to-endのcontextまたはToken中央値を20%以上削減する。
- 人間のactive review時間中央値を25%以上削減する。
- 正規化した文書重複量を30%以上削減する。
- agent処理時間中央値を15%以上削減する。
- 人間との確認往復数を増加させない。
- 各caseのToken増加を原則10%以内に抑える。

`Case H`で10%を超えるToken増加があっても、追加の安全証拠または欠陥検出による必要性を示し、人間が明示承認した
場合だけ例外とする。hard safetyを満たし効率目標を満たせば採用する。効率目標との差が相対10%以内なら該当caseを
最大3回まで再実行し、中央値で判定する。Tokenだけ改善して人間負荷が未達ならnavigationを、
人間負荷だけ改善してTokenが未達ならcontext envelopeまたはmodel routingを再設計する。

これらの数値閾値、`B1`再現手順、fixtureの代表性とseeded defectによる偏りは、requirements承認前の
`Critical` fresh独立reviewで反例を用いて再検証する。reviewで根拠不足または判定不能とされた基準は、
人間へ説明して再合意するまで受入条件として確定しない。

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
