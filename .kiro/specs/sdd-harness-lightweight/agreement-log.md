# 合意形成記録: SDDハーネス軽量化

| 項目 | 内容 |
|---|---|
| タスクID | `sdd-harness-lightweight` |
| GitHub Issue | `#41` |
| 作成日 | 2026-08-16 |
| 関係者 | KYamada / Codex |
| Tier | L（SDD工程、配布スキル、承認・レビュー契約を横断） |

---

## 壁打ち概要

現行SDDハーネスのToken消費、所要時間、文書数・重複、人間レビュー負荷を見直す。
信頼性とトレーサビリティを弱めず、エージェント構成、SDD工程・成果物、人間向けレビュー体験の
3設計軸を一体として比較する。Issue #32実装とは分離し、Issue #41を1つの親specとして開始する。

---

## 決定事項

| # | 決定内容 | 決定理由 | 決定日 |
|---|---|---|---|
| 1 | Issue #41を独立した親Issue・単一specとして開始する | 3設計軸は相互依存し、初期段階で分割すると整合しない決定を生むため | 2026-08-16 |
| 2 | 発見段階で独立実装可能な責務境界が確認できた場合だけ子Issueへ分割する | 人間向け管理単位を保ちつつ、細かすぎるIssue分割を避けるため | 2026-08-16 |
| 3 | 実装・要件確定へ進まず、自然言語SDDの壁打ちから開始する | 不変条件と#39への影響を先に人間と合意する必要があるため | 2026-08-16 |
| 4 | Claude Code / Codexパリティを全変更の必須条件とする | 片側だけ異なる運用を再発させないため | 2026-08-16 |
| 5 | Tier Lまたは高リスクではfresh独立レビューを必須、Tier Sかつ低リスクでは主エージェントの制限レビュー＋人間承認を基準とする | 全タスクへ一律のサブエージェント費用を課さず、重大変更の独立性は維持するため | 2026-08-16 |
| 6 | リスク判定をTierより優先し、高リスク条件が1つでもあれば独立レビュー対象へ昇格する | 小規模に見える認証・削除・公開契約変更などを軽量経路へ誤分類しないため | 2026-08-16 |
| 7 | 人間承認は軽量経路でも維持し、自動レビューで代替しない | Token削減と意思決定権の移譲を混同しないため | 2026-08-16 |
| 8 | データ、security、公開契約、外部副作用、並行・復旧、安全規約、infra topology、性能劣化parameterを高リスクの自動昇格条件とする | 小規模でも障害影響や復旧費用が大きくなり得るため | 2026-08-16 |
| 9 | productionのAI機能追加・変更を原則高リスクとし、隔離されたread-only補助機能だけを証明付きで降格可能にする | 情報漏洩、Token費用、非決定性、prompt injection、tool abuse、model drift等を同時に評価する必要があるため | 2026-08-16 |
| 10 | 既存systemを包含する性能向上、単純resource増強、後方互換追加は単独の自動昇格とせず、複数該当時の昇格材料とする | 外部契約・topology・trust boundaryを維持し、回帰とrollbackを証明できる変更まで一律に重くしないため | 2026-08-16 |
| 11 | リスクを試験・計測で証明できない変更は判定不能として高リスクへ昇格する | 変更目的の自己申告だけで軽量経路へ分類する抜け道を防ぐため | 2026-08-16 |
| 12 | 個別specごとの人間向けreview文書は作らず、正本を直接確認する恒久的なreview guideと、承認時のnavigationを用いる | 第三の正本、転記漏れ、陳腐化を避けながら、同一文章の反復読解を減らすため | 2026-08-16 |
| 13 | 人間は各gate固有の判断事項と工程間の整合性を確認し、変更されていない同一内容の再読を原則求めない | 重複読解は欠陥検出力をほぼ増やさない一方、要件から設計、設計からtaskへの変換確認は必要なため | 2026-08-16 |
| 14 | cc-sddを基盤とする方針を維持し、command・標準成果物名・phase順・approval metadata・数値requirement IDとの互換性を原則として保つ | 今回の責務分離はcc-sdd 3.0.2のWHAT/HOW分離・数値ID追跡・任意節省略の思想と整合し、独自forkによるupgrade負荷を負う必要がないため | 2026-08-16 |
| 15 | 重複削減はoverlayによる生成規則の追加・厳格化と意味的検証で実現し、互換境界からの例外は影響評価と人間承認を必須とする | 局所的な効率化がkiro flow・sync・新版追従・Claude Code/Codex parityを壊すことを防ぐため | 2026-08-16 |
| 16 | 標準file構成を維持したまま、brief・requirements・design・tasks・agreement-log・spec.json・test-results・integration-test-checklistの情報所有責務を一意にし、下流文書は上流IDまたは節を参照する | 重複文章による生成・review Token、陳腐化、不整合を減らしながら、cc-sdd互換性とtraceabilityを維持するため | 2026-08-16 |
| 17 | Tier S/Lで文書体系は変えず、記載の深さを変える | Tier別の独自file構成によるcommand・template・approval flowの分岐を避けるため | 2026-08-16 |
| 18 | `test-results.md`を常時必須とし、unit・component・contract・integration・E2E・non-functionalのtest層と実行方式を区別して、機械判定可能な実行証拠を記録する | 全件PASSの集約だけでは検証層と不足範囲を判断できず、test層と自動・環境依存・手動の区分は直交するため | 2026-08-16 |
| 19 | acceptance criteria、test方針、test case詳細、実行事実の正本をそれぞれrequirements、design、test code、test-resultsへ分ける | 詳細testをMarkdownへ転記せず、実行可能性と結果証拠を維持するため | 2026-08-16 |
| 20 | 振る舞い変更taskはAC・test層・test code参照・RED/GREEN証拠を必須とし、通常結果はgroup集約、失敗・skip・未検証だけを詳述する | TDDの自己申告化を防ぎながら、全case・全logの転記によるToken増加を避けるため | 2026-08-16 |
| 21 | `integration-test-checklist.md`は人間判断・手動操作・外部環境・運用確認が残る場合だけ必須とし、要否をdesign承認時に理由付きで宣言する | 自動testとの重複を除きつつ、都合のよい省略をfail-closedで防ぐため | 2026-08-16 |
| 22 | manual確認が必要な場合はtasks承認前にchecklistを作り、対象ID・revision・環境・事前条件・副作用・停止・rollback・操作・観測可能な期待結果を記載し、実装後は人間だけが結果・証拠・判定を記録する | 人間が実装承認時に後続確認を把握でき、事後的な受入条件の捏造とagentによる自己承認を防ぐため | 2026-08-16 |
| 23 | checklistに自動test結果や正本全文を転記せず、`FAIL / BLOCKED / NOT_RUN`が残る間は完了扱いにしない | 重複・Token・review負荷を減らしながら未確認を成功へ昇格させないため | 2026-08-16 |
| 24 | Tier S・低riskは主agentの制限context review、Tier L通常は実装許可前bundle＋実装完了時の2 fresh review、高riskはrequirements前＋実装許可前＋完了時の最低3 fresh reviewを基準とする | 全文書・全taskの一律reviewをrisk boundaryへ集約し、信頼性を維持しながらreviewer起動と重複contextを減らすため | 2026-08-16 |
| 25 | 高risk境界を越え後続taskが依存する実装単位だけ追加checkpointを置き、gateごとにfresh reviewer 1名、同一gateの収束は同じreviewerを最大10巡まで再利用する | 後戻り費用の大きい変更は早期に止めつつ、五月雨指摘とreviewer再初期化を避けるため | 2026-08-16 |
| 26 | 主agentがorchestrationと通常作業を兼任し、active subagentは通常1体までとするが、累計起動数には固定上限を置かない | 累計agent数はToken量の代替指標にならず、同時稼働制限は競合・重複作業・統合負荷の防止に意味があるため | 2026-08-16 |
| 27 | Tokenはagent別context量・重複率を主指標とし、subagentには役割別の最小context envelopeだけを渡す | agent数より投入context量が消費を左右し、同じ正本と親要約の二重投入が浪費になるため | 2026-08-16 |
| 28 | 複数subagentの同時利用は独立責務・非重複file・context見積もり・時間短縮・統合方法を提示し、人間が例外承認した場合だけ認める | 並列化は主に時間短縮であり、Token節約を保証せず、競合と不要作業のriskを伴うため | 2026-08-16 |
| 29 | cc-sdd `kiro-impl`のtask単位dispatchと本契約が衝突する場合はoverlayで既知節を明示的に置換し、適用不能時はfail-closedとする | 曖昧な追記による矛盾を残さず、cc-sddをforkせずにlocal harness契約を優先するため | 2026-08-16 |
| 30 | model routingは`Standard / Critical / Mechanical`の3能力classを正本とし、実modelはprovider別の更新可能な対応表で解決する | model名・versionの変更でpolicy本文とapprovalを無駄に更新せず、Claude Code / Codexで同じ能力契約を強制するため | 2026-08-16 |
| 31 | 想定対応をClaude CodeはSonnet 5 / Opus 5または適格特化model / Haiku、Codexは5.6-terra / 5.6-solまたは適格特化model / 5.6-lunaとし、未提供modelは将来候補とする | 現在の利用可否と目標とする対応を混同せず、能力classと実装mappingを分離するため | 2026-08-16 |
| 32 | `Standard`を主agent・仕様作成・通常実装の最低要件、`Critical`をfresh独立review・高難度設計・debugの要件とする | 変更riskと作業難度を分離し、高riskはreview強化、高難度は実装model昇格で対処するため | 2026-08-16 |
| 33 | `Critical`はhigh相当以上の推論設定とreview対象に適した能力tagを必須とする | model family名または一般的な「review特化」表示だけで仕様・code・securityの異なるreview能力を証明できないため | 2026-08-16 |
| 34 | `Mechanical`は機械検証可能な抽出・変換・集計だけに限定し、risk・仕様・設計・test充足性・finding重大度・省略可否を判断させない | 軽量modelの判断誤りが正本やapprovalへ入り込む境界を防ぐため | 2026-08-16 |
| 35 | classを最低能力とし、上位classの代行と管理済み同等modelへの解決は認めるが、`Critical`からの降格は禁止する | 不要なsubagent切替とcontext再投入を避けつつ、独立reviewの品質下限を守るため | 2026-08-16 |
| 36 | 対応表外・能力不明・provider越えの代替は人間判断まで停止し、review収束中のmodel IDまたは推論設定変更はreviewer交代としてfresh reviewをやり直す | 能力不明の代替とreviewerの実質的変更を黙認しないため | 2026-08-16 |
| 37 | model証跡はrole、required class、実model・推論profile・能力tag、環境、選定・fallback理由、input hash、取得可能なToken、retry、日時に限定する | ルーティングの再現性を保ちつつ、会話全文の保存と重複を避けるため | 2026-08-16 |
| 38 | Issue #41をreview gate配置・model routing・agent構成のpolicy正本とし、Issue #39はそれに従う独立review実行・状態・証跡・validationの子実装Issueへ再編する | 両Issueのpolicy重複と「全gate必須」対「risk別適用」の矛盾を解消し、正本を1つにするため | 2026-08-16 |
| 39 | model routingの効果はmodel名ではなく、input/output/reasoning/cached Token、retry、費用、時間、手戻りで評価する | 軽量modelの利用がToken数削減を保証せず、再試行を含む総量で比較する必要があるため | 2026-08-16 |
| 40 | 全spec共通の恒久review guideと承認時の動的navigationを併用し、個別specのreview文書を作らない | 必須観点の漏れ防止と、第三の正本・文章転記・反復読解の回避を両立するため | 2026-08-16 |
| 41 | requirements、design、tasks/実装許可、実装完了のgateごとに人間の判断責務と再読不要の範囲を分離する | 同一内容の繰り返しではなく、工程固有の判断と工程間の解釈変更に人間の注意を使うため | 2026-08-16 |
| 42 | 承認navigationは対象/hash/revision、material decision、正本参照、意味変更、review/検証、risk/例外、承認等の選択肢をこの順で示す | 正本の代替要約を作らず、人間が判断する情報へ最短で到達できるようにするため | 2026-08-16 |
| 43 | 必須観点を`APPLICABLE / NOT_APPLICABLE / BLOCKED`に分類し、理由のない非該当とblocking状態のままの承認依頼を認めない | 動的navigationの「該当なし」を利用した重要観点の省略を防ぐため | 2026-08-16 |
| 44 | gateと対象が明確な文脈での明示的な自然言語同意だけをapprovalとし、曖昧な好意的反応・一部同意・質問回答はapprovalとしない | 固定コマンドの負荷を避けつつ、承認の誤認を防ぐため | 2026-08-16 |
| 45 | 本review guide基準はrequirements化後のCritical fresh独立reviewで、省略risk、承認の曖昧性、cc-sdd互換性、人間負荷とtraceabilityを反例ベースで再検証する | 壁打ちで合意した基準自体を無批判に承認せず、正式要件化の欠陥を承認前に検出するため | 2026-08-16 |
| 46 | 文書出力基準はfile名一覧ではなく、SDD/`kiro-*`/agentが生成・更新するすべての人間可読文書・説明出力へ適用する | steering、custom文書、人間主導の任意文書、将来のcc-sdd追加文書を漏らさないため | 2026-08-16 |
| 47 | 具体的記述基準はすべての対象言語へ適用し、日本語をSDD/steering/review/navigationと言語未指定文書の既定とする | 「平易な日本語」を翻訳問題に限定せず、他言語の例外文書でも抽象表現と暗黙前提を認めないため | 2026-08-16 |
| 48 | 明示言語指定、対象読者・公開先・外部契約、既存文書の言語維持、証拠・互換性・licenseの原文保持だけを日本語化の例外とする | 外部提出文書や英語文書の一部だけを意図せず日本語化し、読者要求・契約・原文性を壊すことを防ぐため | 2026-08-16 |
| 49 | schema値、code/identifier/API field、command/path、raw log/error、hash/version、引用、license、vendored/upstream、protocol文字列は文書内でも変更しない | 人間向け文章への適用と、機械互換性・証拠・法的原文の保持を両立するため | 2026-08-16 |
| 50 | 規範文の未定義な抽象表現は`BLOCKED`、非規範文はwarningとし、定型の禁止語ではなく判定基準・数値・主体・例外の有無で判定する | 必要な概念語まで禁止せず、人間が同じ判定を再現できない文だけを承認前に止めるため | 2026-08-16 |
| 51 | requirementsはcc-sddの`The / When / While / If / Where / shall`を維持し、条件・主体・応答を日本語で記述し、1 ACは1つの検証可能な振る舞いだけを所有する | 平易な日本語とcc-sdd/EARS互換性を両立し、ACの一部だけがPASSする曖昧性を防ぐため | 2026-08-16 |
| 52 | 独立review findingはID、重大度、`BLOCKING / ADVISORY`、対象、違反契約、証拠、推論、失敗例、必要修正の結果、完了条件を持つ | 抽象的な指摘と実装方法の過剰指定を避け、人間と修正者が同じ終了条件を判断できるようにするため | 2026-08-16 |
| 53 | 重大度と承認影響を別軸とし、`BLOCKING`1件でも`PASS`を禁止し、未確認は`UNVERIFIED`、収束中の新規指摘は`LATE_FINDING`とする | 技術的影響とgate判定を混同せず、未検証と五月雨指摘を隠さないため | 2026-08-16 |
| 54 | 具体的記述・EARS・finding基準もrequirements承認前のCritical fresh独立reviewで反例ベースに再検証する | 記述ルール自体が過剰なToken・人間負荷、EARS非互換、必要情報欠落を生まないことを承認前に確認するため | 2026-08-16 |
| 55 | 比較対象を現行実装`B0`、Issue #39想定の全gate独立review方式`B1`、Issue #41候補`C`に分け、互換性は`B0`、安全性と効率は`B1`対`C`で評価する | 未実装の安全性向上を削っただけの結果を軽量化と誤判定せず、既存互換性も別軸で保護するため | 2026-08-17 |
| 56 | Tier S低risk、Tier L通常、高risk合成の3 caseをgolden manifest付きで用い、Codexでhard safetyを確認後にClaude Codeで同条件を計測する | risk別経路とparityを少数の代表caseで検証し、明白な不合格後の不要なToken消費を止めるため | 2026-08-17 |
| 57 | Token・context、時間、文書重複、人間review負荷、品質を分離して測り、取得不能なToken値は`UNAVAILABLE`として0扱いしない | agent数やfile数などの代替指標だけで改善を宣言せず、取得できない実測値を捏造しないため | 2026-08-17 |
| 58 | approval bypass、必要review欠落、stale review、seeded blocker見逃し、根拠のないblocking、trace欠落、TDD証跡欠落、navigation欠落、parity欠落、Critical downgradeを1件も許容しないhard safetyとする | Token・時間の改善で信頼性とtraceabilityの欠陥を平均化しないため | 2026-08-17 |
| 59 | `B1`比でToken/context 20%、人間active review時間25%、文書重複30%、agent時間15%の中央値削減を目標とし、確認往復を増やさず、case別Token増加を原則10%以内とする | 明確な判定基準なしに「軽量化」を主観評価することを避けるため | 2026-08-17 |
| 60 | 閾値近辺だけ最大3回再計測し、高riskのToken例外は安全上の必要性と人間承認を求め、数値閾値・`B1`再現性・fixture偏りをCritical fresh独立reviewで再検証する | 非決定的な1回の測定と、根拠の弱い暫定閾値を無条件の正式要件にしないため | 2026-08-17 |
| 61 | 全open Issue `#30 / #31 / #32 / #33 / #34 / #35 / #37 / #38 / #39 / #41`を移行計画の対象とし、`#41 spec確定 → #32 → #38 → #30 → #41/#39 → #33/#34/#35 → #31 → #37`を基準順とする | #38の見落とし、共有fileの競合、旧Issue本文だけに基づく不完全な依存計画を防ぐため | 2026-08-17 |
| 62 | `#34 / #35`は`#33`配下のwork taskとし、`#33 / #31 / #37`間の順はhard dependencyではなくroadmap順として扱う | spec単位と人間管理用taskを混同せず、Issue全体のblocked-byで先行検討まで止めないため | 2026-08-17 |
| 63 | agent・review・model・文書・計測・移行の衝突では`#41`を横断policy正本として既定優先するが、他Issueのcriticalな安全・互換・法的契約を弱める場合は自動上書きしない | policy重複を解消しつつ、横断方針の名目でdata integrity、security、privacy、公開互換性、復旧可能性を破壊しないため | 2026-08-17 |
| 64 | criticalな対抗契約、優先判定不能、scope変更が必要な衝突は`BLOCKED`として壁打ちへ戻し、工程中に発見した場合も同じ停止規則を適用する | 事前棚卸しで全衝突を予見できると仮定せず、黙った優先付けと事後承認を防ぐため | 2026-08-17 |
| 65 | 完了済みspecは遡及せず、active specはgate境界で意味差を評価して移行し、承認後に意味上の衝突が判明した場合はhashとapprovalをstaleにして必要な前工程へ戻す | 一律やり直しの費用と、旧policyを無期限に温存するriskを避けるため | 2026-08-17 |
| 66 | repository単位で共通policy version/hashと両adapterのsemantic parityが揃った後だけ新contractをactiveにし、移行後の欠落・parity失敗では旧policyへ黙ってfallbackしない | Claude Code / Codex片側だけの導入と、安全性downgradeを成功扱いしないため | 2026-08-17 |

---

## 却下・保留事項

| 内容 | 理由 |
|---|---|
| 3設計軸を開始時点で別Issueへ分割する | 責務境界と依存順が未確定のため保留 |
| 制限コンテキスト自己レビューをfresh独立レビューの代替にする | 独立性を技術的に証明できないため、現時点では採用しない |
| Issue #39の独立レビュー契約を本specから暗黙に変更する | 既存の承認事項であり、影響と移行順を明示して別途人間承認が必要 |
| Tier Sという理由だけで高リスク変更の独立レビューを省略する | 作業量と障害影響は一致しないため却下 |
| subagent累計起動数をToken上限として固定する | agent数よりcontext量・重複率の影響が大きく、必要なfresh reviewやdebugを不合理に妨げるため却下 |
| 出力表現基準の独立reviewによる再検証 | 適用範囲、日本語既定・例外、抽象語、EARS、文体、finding formatは合意済み。requirements化後にCritical reviewerが基準自体を再検証する |
| Issue #39を独立したpolicy specのまま維持する | #41とreview適用gate、model、agent構成、Token方針が重複・矛盾するため、#41配下の子実装Issueへ再編する |

---

## 未決事項と検討順

| 順番 | 検討事項 | 決める内容 |
|---|---|---|
| 1 | 正本文書の責務と最小構成 | 合意済み。具体的なformat、ID表現、意味的validatorはrequirements承認後のdesignで決める |
| 2 | agent構成と独立review gate | 合意済み。context envelopeの具体field、gate hash、kiro-impl patch方式はrequirements承認後のdesignで決める |
| 3 | model routing | 合意済み。具体的な対応表、能力tag、推論profile、実行時検証のformatはrequirements承認後のdesignで決める |
| 4 | 人間review guideと出力表現 | 合意済み。適用範囲、日本語既定・例外、抽象語判定、EARS、文体、finding formatをrequirementsと独立reviewの対象にする |
| 5 | 計測・比較と受入判定 | 合意済み。`B0 / B1 / C`、3代表case、hard safety、効率目標、再計測と例外条件をrequirementsと独立reviewの対象にする |
| 6 | 移行・parity・Issue依存 | 合意済み。全open Issue、gate境界移行、`#41`の既定優先とcritical衝突時の壁打ち、両agent同時activationをrequirementsへ反映する |

### 次回の再開点

6項目の壁打ちは完了した。次は合意事項を重複なくEARS形式の`requirements.md`へ整理し、
`Critical` fresh独立reviewでrisk分類、review gate、model routing、文書責務、計測閾値、移行・Issue調停を
反例ベースに再検証する。reviewが`PASS`になるまで人間へrequirements承認を求めない。

---

## フェーズゲート承認記録

> 承認状態の正本は`.kiro/specs/sdd-harness-lightweight/spec.json`。
> 現在は初期化済み・全フェーズ未承認。

| フェーズ | 合意メモ（理由・補足） |
|---|---|
| 要件定義（requirements.md） | 壁打ち完了・未生成・未承認。次に生成し、Critical fresh独立reviewを実施する。 |
| 設計（design.md） | 未生成・未承認。 |
| タスク分解・実装前確認（tasks.md） | 未生成・未承認。 |

---

## 変更履歴

| 日付 | 変更内容 | 変更者 |
|---|---|---|
| 2026-08-16 | Issue #41作成、専用ブランチとspec初期文書を作成 | KYamada / Codex |
| 2026-08-16 | 流動型の基準構成と、Tierよりリスクを優先する独立レビュー方針を合意 | KYamada / Codex |
| 2026-08-16 | infra・AIを含む高リスク自動昇格条件と、複数該当時の昇格材料を合意 | KYamada / Codex |
| 2026-08-16 | 正本を直接確認する恒久review guideと、工程固有の観点に絞る人間review方針を合意 | KYamada / Codex |
| 2026-08-16 | 未決事項を6段階に棚卸しし、次回の再開点を正本文書の責務・最小構成に固定 | KYamada / Codex |
| 2026-08-16 | cc-sdd互換境界の維持と、overlay中心で責務分離を実現する方針を合意 | KYamada / Codex |
| 2026-08-16 | 正本文書ごとの情報所有責務、ID参照によるtraceability、Tier別の記載深度を合意 | KYamada / Codex |
| 2026-08-16 | test層・実行方式・正本の分離、簡潔なTDD証跡、安全な参照検証、条件付きmanual checklistを合意 | KYamada / Codex |
| 2026-08-16 | manual checklistの記載項目、tasks承認前の作成、人間による実施、未完了時の停止条件を合意 | KYamada / Codex |
| 2026-08-16 | risk別の独立review gate、通常1 active subagent、context量中心のToken制御、並列例外条件を合意 | KYamada / Codex |
| 2026-08-16 | 3能力class、役割別routing、推論・能力要件、fallback、証跡、Token評価を合意 | KYamada / Codex |
| 2026-08-16 | #41をreview policyの正本とし、#39を独立review機構の子実装Issueへ再編する方針を合意 | KYamada / Codex |
| 2026-08-16 | 恒久review guide、gate別の人間判断責務、承認navigation、承認不能・自然言語承認の条件を合意 | KYamada / Codex |
| 2026-08-16 | review guide基準をrequirements承認前のCritical fresh独立reviewで再検証することを合意 | KYamada / Codex |
| 2026-08-16 | すべてのagent生成・更新の人間可読文書への適用、日本語既定、他言語・原文保持の例外を合意 | KYamada / Codex |
| 2026-08-16 | 規範文の抽象語判定、EARS構文、文体、独立review findingの構造と独立再reviewを合意 | KYamada / Codex |
| 2026-08-17 | `B0 / B1 / C`比較、3代表case、hard safety、効率目標、再計測・例外条件と独立reviewによる基準再検証を合意 | KYamada / Codex |
| 2026-08-17 | 全open Issueの移行順、gate境界移行、`#41`の既定優先、critical衝突時の壁打ち、両agent同時activationを合意 | KYamada / Codex |
