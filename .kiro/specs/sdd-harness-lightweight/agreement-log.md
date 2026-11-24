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
| 67 | SDD Rig V1はKiro/AWSの公式・提携・後継を名乗らない独立製品として、公開・観測可能な外部workflowの構造互換と起動互換を保証し、完全な出力・内部実装・未公開または将来Kiro仕様との意味一致は保証しない | 既存利用者の移行可能性を保ちつつ、検証不能な完全互換や公式性を表示しないため | 2026-09-05 |
| 68 | 既存`.kiro/`、未完成を含む既存spec、`spec.json`の既知schema・phase・approval metadata、未知field、`SDD-BASE:*` marker、旧lock/snapshot、旧`sdd-base`入口を非破壊で扱う | V1移行によって既存projectの開始・再開・完了や承認状態を壊さないため | 2026-09-05 |
| 69 | Claude CodeとCodexの双方で現行inventoryの全`kiro-*`（2026-09-05時点17個）を検出・明示起動可能にし、`doc-export`はKiro互換対象ではないSDD Rig固有skillとして別途parityを保証する | 固定件数の陳腐化と、Kiro互換contractへ独自機能を混在させることを避けるため | 2026-09-05 |
| 70 | 自然言語起動はKiro互換保証ではなくSDD Rig固有の製品要件として#32とTask Eで扱い、全`kiro-*`の明示起動保証と両立させる | 外部互換性と独自UXを分離し、#32の既存要件をTask Aで暗黙に弱めないため | 2026-09-05 |
| 71 | 既存資産の開始・再開・完了、人間承認、TDD、Claude Code/Codex parityを不変条件とし、現行の品質目的機能を根拠なく廃止しない | source取り込みや独自改良を品質低下の理由に使わせないため | 2026-09-05 |
| 72 | 主見出しを「SDD Rig — 開発の理由が、いつでもたどれるAI開発環境。」とし、要件・設計・合意判断・テスト結果から人とAIが決定理由を追跡できる価値を説明する | 製品価値を特定upstreamとの関係ではなく、利用者が得る追跡可能性で示すため | 2026-09-05 |
| 73 | SDD Rigは「cc-sddをベースに開発した独立製品」と説明し、主表示で「cc-sddの改造版」またはKiro/AWSの公式・提携・後継と呼ばず、cc-sdd由来部分は日本語説明とNOTICE/LICENSEでMIT帰属を示す | 独立製品としての位置づけ、非提携表示、upstreamへの法的・技術的帰属を混同しないため | 2026-09-05 |
| 74 | repositoryを即時renameせず、旧URL/package/CLI/skill/marker/stateのbridgeを先に検証し、新旧入口が同一stateを共有して旧資産を開始・再開・完了できること、非破壊性、rollback、両platform parity、新名称での配布・更新をE2Eと人間承認で確認するまで旧入口を維持する | 日付による一律廃止や名称変更先行で既存利用者を切り捨てないため | 2026-09-05 |
| 75 | V1はin-place bridgeとし、新`sdd-rig`が旧`.kiro/`、spec、lock、markerをそのまま認識して二重stateを作らない。state形式変更は明示的・可逆的・rollback検証済みの別Decisionとする | state分岐による承認・進捗の不一致とrollback不能を防ぐため | 2026-09-05 |
| 76 | 旧CLI、旧install済みskill、旧URL/packageの利用時だけ新名称を短く案内し、新`sdd-rig`が旧projectを開くだけでは警告しない | 移行案内を必要な入口へ限定し、通常作業で警告疲れを起こさないため | 2026-09-05 |
| 77 | Spec Tier、Review Mode、Model Classを別軸として評価し、machine-readable値は`SPEC_TIER_*`、`REVIEW_*`、`MODEL_*`へnamespace分離する | 文書規模、品質保証強度、model能力を混同し、小規模変更を自動的に低risk・低能力へ誤分類することを防ぐため | 2026-09-06 |
| 78 | Spec Tierは独立AC、責務境界、依存、設計選択、移行、人間判断、task分解等の仕様化・調整複雑性を評価し、同一file体系内の記載深度だけを決める | Tierをrisk、review要否、model選択から分離し、小規模でも高risk、大規模でも検証可能な変更を表現するため | 2026-09-06 |
| 79 | Review Modeを`STANDARD / DEEP_RECOMMENDED / DEEP_REQUIRED`として、影響risk、不確実性、検証可能性、rollback、外部副作用、暗黙契約から判定する | fresh reviewのToken費用を全taskへ一律適用せず、見逃し費用が高い変更には独立性と深度を維持するため | 2026-09-06 |
| 80 | `DEEP`実行前に理由、agent数、model class、context範囲、最大巡回数、Token・時間見積区分、拒否時の扱いを提示して人間承認を得る。`DEEP_REQUIRED`拒否時は暗黙降格せず停止またはscope縮小とする | 高コスト処理を人間に無断で開始せず、費用承認を安全性reviewの任意化へ変質させないため | 2026-09-06 |
| 81 | Model Classはroleの判断量、制約統合、曖昧性、反例探索、domain知識、機械検証可能性から決め、高riskはreviewer能力、実装難度はimplementer能力へ別々に反映する | riskと難度を分離したまま、各roleへ必要な最低能力だけをprovider中立に割り当てるため | 2026-09-06 |
| 82 | 三軸baselineをTask C/E、Task A〜F統合、Requirements Critical review、Design、Task F・段階導入で段階的に再検証し、反例時は人間へ改訂案を戻す | 現時点の分類を無批判に固定せず、過剰review、過少review、判定逃れ、model過不足を実証的に修正するため | 2026-09-06 |
| 83 | `cyclox2_docker`の`docs/catracer-cleanup-2026-27-task2-2`をTask Eの実例に用い、変更量ではなくdata risk・不確実性が深いreviewを正当化したか検証する | 深いreviewが破壊的FIX／no-op FIXを発見した実例を残しつつ、通常taskへの一律適用と混同しないため | 2026-09-06 |
| 84 | SDD Rigをcc-sdd `v3.0.2`、commit `3795eb4274c07dedcf56c571b5c0a826736f23c8`、`tools/cc-sdd`を初期固定参照元とする一方向forkの独立Appとし、release後にpristine baseline、vendor snapshot、subtree、submodule、継続同期機構を常設しない | 外部sourceへ恒常的に依存せず、SDD Rig sourceを運用上の正本とする一方、初期実装の再現可能性を固定値で確保するため | 2026-09-06 |
| 85 | 初期実装時は`tools/cc-sdd`全体を比較対象にするが、V1の製品保証・配布・検証はClaude CodeとCodexだけに限定する | 部分抽出による初期比較漏れを防ぎつつ、未検証platformを対応済みと誤表示しないため | 2026-09-06 |
| 86 | architectureをSDD Rig core、Claude adapter、Codex adapter、project override、legacy bridgeへ分け、project overrideは利用project所有、bridgeはE2Eと人間承認まで維持する | 本体、platform差、利用者資産、旧入口を別責務として管理し、更新による利用者資産の破壊と二重stateを防ぐため | 2026-09-06 |
| 87 | cc-sddのMIT LICENSE全文、`Copyright (c) 2025 gotalab`、URL、tag、commit、path、subtree tree SHA `14c2cde6a674620c8db41a6cfff85215d75aa618`、独立・非提携説明、初期統合来歴を保持し、component対応、`copied / modified / reimplemented / not adopted`分類、初期検証を一回限りの証跡に残す | 継続同期用baselineを置かなくても、由来、法的帰属、初期統合の判断を監査可能にするため | 2026-09-06 |
| 88 | SDD Rig自身とcc-sddのLICENSEを分離し、cc-sdd由来code、template、substantial portionsを実際に含む配布物からLICENSE全文と帰属へ到達可能にする。ハーネス利用だけで利用project App全体へMITが自動伝播するとは扱わない | MITのnotice保持と、実コピーを伴わない利用projectへの過剰なlicense伝播説明を避けるため | 2026-09-06 |
| 89 | 将来の外部source採用は、提案、固定参照、隔離検証、人間判断、通常SDD実装、統合release検証、直前SDD Rig releaseへのrollbackを一件ごとに行い、AIは承認前に候補取得・検証・報告までとする | 継続upstream追従を廃止しても、有用な変更を安全かつ人間の採否判断付きで取り込めるようにするため | 2026-09-06 |
| 90 | 利用者のinstall・sync・通常利用で`npx cc-sdd`、cc-sdd source取得、cc-sdd単体version選択を要求せず、dependency追加・更新は目的、分類、pin/lock、license、security、supplier、E2E、更新責任を確認する | 配布を自己完結させ、外部取得による非再現性とAIの無断dependency変更を防ぐため | 2026-09-06 |
| 91 | install、sync、bridgeでは管理対象と所有領域を分類し、所有者不明を利用者所有として非破壊で扱う。競合・不明・parity未検証は差分と候補を示して人間承認後に適用するか、既存環境を保持して中断する | 未適用や競合を完全成功と誤報せず、利用者資産と未知fieldを保護するため | 2026-09-06 |
| 92 | #41をDiscovery Decision・横断制約・依存順の正本、#33を必要時の初期統合実装spec、#34をその子作業候補とし、既存#33/#34の継続cc-sdd追従記述は実装前に再定義する。Discovery中は人間向けACTIVEを一件に限定する | Decisionとapprovalの二重正本を避け、古いupstream lifecycle案をTask B合意より優先して実装しないため | 2026-09-06 |
| 93 | 「コンテキスト予算・セッション継続管理」をSDD Rigの基本機能とし、計画的session分割を主策、早期compactを安全弁、platform固有auto-compact上限を任意の最終防波堤とする | 長時間sessionで同じcontextをrequestごとに再投入する費用と、上限直前の非可逆compactによる情報劣化を同時に抑えるため | 2026-09-06 |
| 94 | Claude 1M contextの200K警告・500K上限は初期検証候補とし、全platform・modelへ共通の固定値や削減保証として適用しない。active context、累積input/cached input、turn、compact、大容量出力、checkpoint readinessを分離して測る | 単一projectと仮定を含むsimulation値を一般化せず、model windowと観測能力の違いを扱うため | 2026-09-06 |
| 95 | session checkpointを正本参照型の派生manifestとし、会話要約や仕様本文のcopyを正本化しない。分割を自動commit/pushと同義にせず、未承認・不完全な差分をcheckpoint名目でcommitしない | 正本の二重化、要約劣化、既存commit policyの迂回、再開不能な作業状態を防ぐため | 2026-09-06 |
| 96 | Claude/Codex parityは同じ設定キーではなく、肥大検知、checkpoint、正本からのfresh-session再開、重要Decision保持という観測可能な結果で判定する。global設定を無断変更せず、project設定も非破壊差分と人間承認を必須とする | platform固有機能の差を隠さず、Task Bの利用者所有・未知field保護contractを維持するため | 2026-09-06 |
| 97 | session transcript計測はlocal opt-inとし、raw transcriptをrepositoryへ保存・外部送信せず、usage metadataを優先する。情報責務をTask C、budget・判定をTask E、adapter・E2EをTask F、大容量二次成果物出力をTask Dへ割り当てる | prompt・file本文・秘密情報の漏洩を防ぎ、横断機能を新しいDiscovery Taskや二重正本へ分裂させないため | 2026-09-06 |
| 98 | 標準file構成を維持し、brief、requirements、design、tasks、agreement-log、spec.json、research、test証跡、runbook、steering、二次成果物の固有責務を一情報一正本で分離する。context packetとhandoffはIssue #41のSerial Discovery専用の派生資料であり、標準SDD文書、通常specの必須成果物、Decision・approvalの正本にしない | 正本の重複、陳腐化、review Tokenを減らしながら、標準workflowと追跡可能性を維持するため | 2026-09-21 |
| 99 | 現在文書は現在contractへ更新できるが、過去のDecision、review、approval、test evidenceへの到達性を保つ。意味または対象hashが変われば依存review・approvalをstaleにし、正しいgateへ戻す | 最新状態の可読性と、過去判断・失敗証拠の監査可能性を両立するため | 2026-09-21 |
| 100 | stable IDは同一判断対象の修正では維持し、分割・統合・意味変更では新IDを付ける。影響先は`UPDATE / CONFIRM_UNCHANGED / RETIRE / BLOCKED`で閉じる | IDの乱造と意味のすり替えを同時に防ぎ、本文copyなしで影響を追跡するため | 2026-09-21 |
| 101 | 人間reviewは恒久guideとgate別navigationで正本を直接確認する。自然言語の「進めて」は、一つのpending gate、対象文書、version/hash、許可範囲が直前に明示され、他の質問等が混在しない場合だけapprovalとする | 固定commandを強制せず、一般的な続行指示や説明理解を正式approvalへ誤認しないため | 2026-09-21 |
| 102 | 意図・scope、architecture、隠れたfailure、権限・data・副作用、境界・並行・負荷、外部前提、test integrity、文書・state残骸の8観点を、人間review、主agent review、fresh独立reviewの共通最低観点とする | 独立reviewだけに品質観点を閉じ込めず、人間承認と軽量経路でも同じ欠陥分類を確認するため | 2026-09-21 |
| 103 | 日本語化は承認対象を一意にすることを最優先とし、主体・対象・条件・結果・例外を具体化する。EARS keyword、schema、code、path、log、license等は必要な原文を保持し、1 ACは1つの検証可能な振る舞いを持つ | 読みやすさの名目で機械互換・法的原文を壊さず、抽象表現による判断不能を減らすため | 2026-09-21 |
| 104 | session checkpointは正本参照と未固定の最小差分を持つ派生manifestとし、未固定合意を`provisional / pending-canonicalization`として扱う。正本固定または人間再確認まで後続gateとmutable作業を許可しない | 会話消失から作業を再開可能にしつつ、checkpointを仕様・approvalへ昇格させないため | 2026-09-21 |
| 105 | session、platform conversation、workspace metadataを分離し、古い・競合・未取得・未検証のworkspace情報は`UNVERIFIED`または`BLOCKED`とする。checkpoint成功をworkspace isolationの証明にしない | pathやworktree存在だけを安全性・所有権の根拠にする誤りを防ぐため | 2026-09-21 |
| 106 | checkpointはraw transcript、raw log、secret、PIIを既定保存せず、必要な証拠は参照とsensitivityを記録する。runtime storage・retention・暗号化等はTask F/securityが所有し、#37は中間・二次成果物に限定する | 再開性のために機密情報をrepositoryへ複製せず、Issue間の保存責務を混同しないため | 2026-09-21 |
| 107 | README等はSDD Rigの利用価値と独立製品表示を主とし、NOTICE等からcc-sdd由来、非提携、MIT帰属へ到達可能にする。利用だけで利用project全体へMITが自動伝播するとは説明しない | Task A・Bの製品境界とlicense contractを人間向け文書へ一貫して反映するため | 2026-09-21 |
| 108 | Spec Tierで文書体系を変えず、scope・AC・責務・依存・選択・移行・判断の複雑性に応じて深度だけを変える。軽微変更でも文書影響を確認する | 小規模変更の証跡欠落と、大規模変更での重複文書増加を避けるため | 2026-09-21 |
| 109 | Task Cの採用Decisionは#98〜#108を正とする。`handoffs/task-c.md`は却下案、Requirements候補、Design保留、後続制約、既知差分を含む当時の伝達記録として保持するが、現在contractやapprovalの参照先にしない | Decisionの正本を一つに保ちつつ、壁打ち時の理由と未採用案を監査可能にするため | 2026-09-21 |
| 110 | #102の8観点は、役割ごとに確認方法と深さを調整してよいが、人間、主agent、fresh独立reviewerのいずれからも該当観点を黙って除外しない。使用した観点versionと`APPLICABLE / NOT_APPLICABLE / BLOCKED`の判定へ到達可能にする | Task Cの承認済みhandoffにあった「人間・AIセルフレビュー・独立freshレビューへ適用」という役割指定が、正本化時に人間だけ脱落したため | 2026-09-21 |
| 111 | Task Aの品質条件を具体化し、機能改修と現行品質の維持が衝突する場合は、影響、代替案、回帰試験を提示して人間判断へ戻す。品質目的を理由なく廃止せず、衝突を実装者だけで解消しない | #71では不変条件だけが残り、衝突時の停止・説明・判断手順がDecision本文から脱落していたため | 2026-09-21 |
| 112 | Task Aの後続制約を、Task B=source intake・MIT帰属と外部contract維持、Task C=証跡の正本・追跡可能性とschema意味変更時の人間判断、Task D=既存spec・証跡の非破壊、Task E/#32=全`kiro-*`のfresh-session検出・明示起動・parity、Task F=旧入口・in-place bridge・rollback・旧資産再開E2Eとする。旧URL/package/CLIの実配布状況とalias・redirect、`spec.json`全field棚卸しと未知field保持の受入試験も該当ownerの必須確認へ戻す | 非正本のhandoffにだけ残すと、後続Taskが制約と未決調査を完了条件として認識できないため | 2026-09-21 |
| 113 | Task Bの帰属contractでは、初期参照元に加えて将来採用した外部sourceの短い来歴も保持する。生成projectへcc-sdd由来code・template・substantial portionsを実際に複製する場合はLICENSE全文と帰属への到達性を伝播し、該当性が曖昧なら保守的に含めるか専門家判断へ戻す。NOTICEは製品透明性のcontractとして使うが、MIT本文が`NOTICE`というfile名を要求すると説明しない | #87・#88の要約では、将来sourceの来歴、生成projectへの例外伝播、曖昧時の停止条件、NOTICEの法的説明境界が明示されなかったため | 2026-09-21 |
| 114 | SDD Rig sourceを正本とし、maintainerまたはCIがbuildする。package・release archive・skill bundleには統合済み成果物と必要なLICENSE/NOTICEを含める。dependencyは目的、分類、pin/lock、license、security、supplier、E2E、更新責任を確認し、AIの無断追加、無承認の自動audit fix、無承認のmajor updateを禁止する。build tool、directory、build成果物のcommit方針はDesignで決める | #90の圧縮でbuild/packageの責任主体、明示的な禁止事項、Design保留事項が正本Decisionから脱落していたため | 2026-09-21 |
| 115 | install、sync、legacy bridgeは、利用者所有資産、未知設定、環境固有設定、追加skill、既存stateを削除・上書き・再生成しない。競合、所有者不明、parity未検証では比較・差分・影響・候補を示し、人間承認後に適用するか既存環境を保持して中断する。未適用・競合・未検証を完全成功と報告しない | #91の「非破壊」という要約だけでは、保護対象、禁止操作、成功判定を同じ意味で再現できないため | 2026-09-21 |
| 116 | Task Bの後続責務を、#30/Task F=非破壊sync・`.new`・report・rollback、#32/Task E=外部source無断採用防止と両platform検出・起動・parity、Task C=製品説明・NOTICE、Task D=外部package/CLIのdependency contractとする。Discovery中は人間向けACTIVEを1件に限定し、完了後に既存Issueを`実装対象 / 後回し候補 / 不要・置換済み`へ分類する。未Decision・実装要否未判断のIssueはACTIVEまたは並列実装候補にしない。build方針、template別substantial portions、dependency risk閾値・監査tool、Issue優先順位・実装可否、曖昧なlicense範囲は各ownerの未決事項として保持する | #92では#41/#33/#34とACTIVE件数だけが残り、他の後続owner、Discovery後の分類規則、Task Bの未決調査が正本から脱落していたため | 2026-09-21 |
| 117 | Serial Discoveryのhandoff正本化では、handoffを原子的な項目IDへ分解し、各項目を`ADOPTED:<Decision ID> / DEFERRED:<owner・gate> / REJECTED:<理由> / BLOCKED:<原因>`のいずれかへ一対一で対応付ける。主体、規範強度、条件、例外、否定、固定値、後続owner、未決状態を照合し、100%対応、逆向き再構成、未対応0件を確認するまで次Taskへ進まない | 要約の存在確認だけでは、Task Cの「人間」のような役割限定や、Task A/Bの例外・停止条件・未決事項が静かに脱落することを防げなかったため | 2026-09-21 |
| 118 | 壁打ち専用sessionはhandoff送信後も正本化確認が完了するまで存続する。orchestratorは正本反映後、handoff IDごとの反映先Decision、正本文、統合・言換え・保留・未反映を同sessionへ返す。壁打ちsessionは元の承認済みhandoffと照合して`CANONICALIZATION_PASS`または`CANONICALIZATION_REVISE`を返し、`PASS`前にTask完了、session終了・archive、次Task開始を行わない。意味変更・Task間衝突は人間判断へ戻し、この確認をfresh独立reviewの代替にしない | handoff作成者が元の判断を保持している間に、orchestratorの丸め込みを送信元確認できるようにし、後日の高コストなcontext復元と意味欠落を防ぐため | 2026-09-21 |
| 119 | #117〜#118をIssue #41固有の注意事項に留めず、SDD Rigの「転記完全性確認」機能としてRequirements化する。承認済み情報をsession・agent境界を越えて正本化する場合、handoff ID・source hash・正本対応・canonical hash・確認状態を追跡し、`CANONICALIZATION_PASS`までfail-closedとする。単一sessionが正本を直接更新する通常作業には一律適用しない。情報contractはTask C、agent workflow・停止条件はTask E、session呼戻し・存続・復旧・Claude Code/Codex E2EはTask Fが所有する | 実際に発生した転記欠落を再現可能な製品機能で防ぎつつ、全作業への過剰な確認とToken消費を避けるため | 2026-09-21 |
| 120 | `doc-export`のPPTは人間の理解・共有・論点把握を支援する派生viewであり、正本または正式approval対象にしない。正式approvalは、利用者が正本を開くか対象を明示選択し、PPTから正本reviewへ明示遷移した後、単一pending gate、対象正本文書、version/hash、許可範囲を直前に提示した場合だけ成立する。PPT閲覧中の一般的肯定はapprovalにせず、正本へアクセスできない相手はfeedback・賛同はできても正式承認者にしない。PPTで条件・例外・禁止・risk・未決を省略した場合は正本遷移前にその存在を明示する | 二重権威と、読みやすい要約だけを見た誤承認を防ぎつつ、人間向け派生viewの価値を残すため | 2026-10-08 |
| 121 | #120の承認境界をClaude CodeとCodexで意味的に同一とし、`doc-export`は両platformの明示skill・自然言語と直接CLIから同じ意味で起動可能にする。具体的なskill検出・起動・fresh-session E2Eは#32、agent workflowはTask E、adapter・session実行はTask Fが所有する | platformごとに承認成立条件や利用可能な入口が変わることを防ぎ、実装責務の二重正本を避けるため | 2026-10-08 |
| 122 | human review gateではPPT生成を提案するが自動生成せず、人間の明示依頼後だけ生成する。形式指定がなければ、一意なpending gateに対応するphase別profileのPPTを既定とし、gateまたはphaseが一意でなければ推定せず確認する。Word、PDF、複数形式、複数phaseは明示指定時だけ生成する。profile候補は`requirements-review / design-review / tasks-review / status-share`とし、schemaはDesignへ保留する。PPT生成失敗だけで読める正本のreview・approvalを不可能にしないが、依頼されたPPTの失敗をreview可能・成功と報告しない。現行のmanifestなしで3正本全文を各DOCXへ出す既定はmigration・compatibility対象とする | 不要なToken・renderer費用とstale成果物を増やさず、派生物の失敗を正本の承認不能または偽の成功へ変換しないため | 2026-10-08 |
| 123 | `doc-export`は正本の意味を維持する範囲で並べ替え、要約、言換え、表・図への変換を行える。ただし主体、対象、条件・trigger、規範強度、観測可能な結果、例外・停止条件、否定、未決・未検証・仮定、risk・severity、固定値・閾値・version、stable IDを削除・変更せず、正本にない要件・設計判断・関係・依存・因果・優先度・approvalを事実として追加しない。意味を持つ順序と必要な原文を保持し、複数項目の統合は各行・cellから元IDへ追跡でき、異なる条件・例外を丸めない場合だけ許可する。図は正本にあるcomponent・関係・state・flowだけを描き、収まらなければslide分割・appendix・正本参照を使う。正本にない判断が必要なら補完せず人間へ戻す | presentation変換による意味欠落、規範強度の変化、もっともらしい新規判断の混入を防ぐため | 2026-10-08 |
| 124 | artifactごとにspec ID、phase/profile、source path、source file content hash、対象version/gate hash、generator version、template ID/version、生成日時を記録する。掲載・意図的省略・変換失敗・source不在・未確認の正本ID/見出しを区別し、主要slideへ人が読める正本IDまたは`file#heading`、生成reportへ詳細なslide-source mappingを残す。生成時、review開始時、正本approvalへの遷移時にsource hashを再確認し、source fileが一つでも変われば原則PPT全体を`STALE`とする。非意味変更の最適化はDesignへ保留する。`GENERATED / PARTIAL / CURRENT / STALE / REVIEW_READY`を区別し、生成済みまたは`CURRENT`だけで`REVIEW_READY`にしない。再確認不能な外部共有物は生成時hashへの派生物と表示し、現在の承認資料とは保証しない。意図的省略時も条件・例外・禁止・risk・未決の存在と正本参照先は主要部分から分かるようにする | 派生viewの鮮度・網羅性・出典を人間が再構成でき、部分成功や古い資料を承認可能と誤認しないため | 2026-10-08 |
| 125 | SDD Rigはversion管理された既定PPT templateを提供し、利用project所有のtemplate overrideを許可する。選択優先順位は実行時明示指定、project override、SDD Rig既定templateの順とする。phase profileが必須の意味要素、visual template/themeがbrand・logo・色・font・layoutを所有し、overrideは承認境界、source mapping、鮮度、条件・例外・risk・未決を削除できない。利用者所有overrideをinstall/sync/updateで上書き・削除・再生成・自動変換せず、非互換時はsilent fallbackせず差分・不足を示して人間へ戻す。既定templateは日本語/CJK、font fallback、長い表・図・risk・例外、#120・#124の表示領域を支援する | project固有の見た目を許容しながら、承認と意味保持のcontractをtemplate変更で回避させず、利用者資産を非破壊に保つため | 2026-10-08 |
| 126 | 外部template、font、icon、rendererは固定参照、license、商用利用・改変・再配布、attribution、supplier、再現性、更新責任、Claude/Codex parityを確認して別途採否判断する。具体的な外部package/template採用やcc-sdd由来asset同梱はTask Dの合意に含めない。cc-sdd由来物を同梱する提案時はMIT LICENSE全文と`Copyright (c) 2025 gotalab`の保持・到達性を再確認する。export中に不足rendererを黙ってinstallせず、別setupとして目的、version/pin、license、supplier、影響、更新責任を示し、人間承認後だけ導入する | Task Bのdependency・provenance contractを二次成果物機能でも維持し、供給網・license・再現性を暗黙の実装詳細にしないため | 2026-10-08 |
| 127 | artifact品質はrenderer processの終了成功だけで合格にしない。毎回、artifact構造、必須XML、非0 slide、全slide render、asset・relationship・internal reference、source mapping、profile coverage、source freshness、未掲載・失敗count、placeholder、overflow、重なり、極小font、CJK glyph・文字化け、contrastを自動検査する。formal gateの理解にPPTを使う場合は実際にrenderされた全slideの人間visual QAを必須とし、overflow、文字切れ、重なり、日本語可読性、表・図、contrast、条件・例外・risk・未決の埋没、図の確定・未決誤表示、正本案内、warning可視性を確認する。参考共有では`AUTO_PASS`かつvisual未確認を明示したartifactを渡せるが`REVIEW_READY`または品質保証済みと呼ばない。`GENERATED → AUTO_PASS/AUTO_WARN/AUTO_FAIL → VISUAL_REQUIRED → VISUAL_PASS/VISUAL_FAIL → REVIEW_READY`を意味上区別し、`AUTO_FAIL`、未解消`AUTO_WARN`、`VISUAL_FAIL`、`STALE`、`UNVERIFIED`を成功扱いしない。renderer未導入の対象は`NOT_GENERATED`とし、他形式を続行しても全artifact成功と表現しない。visual QAは意味同等性確認や正式approvalの代替にせず、両platformで同じstatus・blocking・reportを使い、片側で検証不能なら推測PASSにしない | 壊れた表示、意味欠落、部分生成を機械的成功へ丸めず、自動検査と人間の視覚判断を重複させずに組み合わせるため | 2026-10-08 |
| 128 | 生成前にspec、phase、profile、format、機密区分を一意にし、不明なら確認する。対象、artifact数、AI要約・図表化、必要renderer、visual QA、中間data再取得、Token・時間・外部処理の見積区分、保存しない場合の再現性riskを提示し、取得不能な値は`UNAVAILABLE`として0扱いしない。大容量PDF、全slide画像、render logを会話へ無制限に投入せず、manifest、検査結果、縮小contact sheetを優先し問題slideだけ詳細確認する。閾値とagent budgetはTask Eが所有する | 明示依頼後の費用・情報量・再現性を人間が判断できるようにし、二次成果物自身がcontext肥大を再発させることを防ぐため | 2026-10-08 |
| 129 | 二次成果物は既定で再生成可能かつgitignore対象のbuild outputとし、外部Drive等を必須化しない。外部upload、Git stage/commit/push、外部archive、dependency導入を生成処理から自動実行しない。PII・機密・大容量を通常の非PII出力先へ混在させず、永続reportへlocal user名を含む絶対pathを残さない。既存artifactと利用者所有fileを黙って上書きしない。exact source hash、profile、template、generator versionが一致し検証済みのartifactは再利用を提案できるが、hash再確認を省略しない | 派生成果物を安全に再生成可能なbuild outputとして保ち、秘密情報、利用者資産、外部副作用を暗黙に扱わないため | 2026-10-08 |
| 130 | output ownership、同一specの並行生成、atomic publish、PII隔離、worktree削除後の発見性、main worktree mutation preflight、cache lifecycleはTask Fで確定し、安全に解決できなければsilent fallbackせず`BLOCKED`とする。#37のlinked worktreeからmain worktreeのoutputsへ出す案は候補として維持するが、Task Fのownership・lease・preflight・recovery contract確定前には有効化しない。保存済み中間dataがなければ再取得費用と非再現性を通知し、人間確認後に再生成し、外部storage連携は必須にしない。bash 3.2、CJK/PDF rendererの既知不具合を修正済みと仮定せず#38へ渡す。skill discovery・起動・fresh-session parityは#32、agent/model/context予算はTask E、workspace/output/lock/recoveryはTask Fが所有する | main worktree出力という利便性を並行sessionの破壊的変更へ変えず、既存Issue間の責務と未解決riskを保持するため | 2026-10-08 |
| 131 | Task Dで合意したRequirements候補、Design保留、未決調査は後段の各gateへ明示的に渡すが、現時点で`requirements.md`、`design.md`、`tasks.md`の承認または実装許可へ昇格させない。Task A〜CのDecisionは改訂せず、衝突が後から見つかった場合は自動上書きせず人間判断へ戻す | Discoveryの採用方針、設計方式、調査事実、実装許可を混同しないため | 2026-10-08 |
| 132 | `Spec Tier`、`Review Mode`、`Model Class`を別軸かつ別namespaceとする。Spec Tierは仕様化・調整の複雑性から同一文書体系内の記載深度・分解粒度を決め、Review Modeは影響risk、不確実性、検証可能性、rollback、外部副作用、暗黙契約から必要な独立検証を決める。Model Classはrole別の判断量、制約統合、曖昧性、反例探索、domain知識、機械検証可能性から最低能力を決め、高riskはreviewer能力、実装難度はimplementer能力へ別々に反映する。Tierをrisk・review・modelの直接判定根拠にしない | 文書深度、検証強度、必要能力を同じ「難易度」へ丸めず、各軸の目的と権限を分離するため | 2026-10-09 |
| 133 | 主agentは共通の観測事実からTierとReview Modeを互いの分類値に依存せず判定する。Review Modeから必要roleとreview対象を定めた後、主agentまたはorchestratorがrole別Model Classを判定し、実model mappingの実行可能性を確認する。複雑性だけで`DEEP`にせず、それが生む不確実性・検証困難・暗黙契約等の観測事実で判定する。強いmodelの使用、適格model不在、予算、期限を必要reviewの省略または必要能力の降格理由にせず、実行不能時は停止、scope縮小、必要な人間判断へ戻す | Tierへのanchoring、能力と独立性の混同、利用都合による安全水準の引下げを防ぐため | 2026-10-09 |
| 134 | 主agentはscope把握後にSpec Tierを提案し、人間はscope確認または既存approval gateで確認・異議提示する。Tier専用gateは増やさない。Review Modeは初期scope把握時と各対象gate直前にpolicyで判定する。人間は`DEEP_RECOMMENDED`を受諾・拒否でき、`DEEP_REQUIRED`では実行・scope縮小・停止を選ぶが`STANDARD`へ上書きしない。`DEEP`実行前には理由、agent数、class、context、巡回、Token・時間見積、拒否時の扱いを提示して承認を得る。roleと対象の確定後に必要classを判定し、dispatch直前にmappingを検証する。対応表外、能力不明、provider越え代替は人間判断まで停止し、追加費用等の確認条件はE-5で具体化する | 既存gateを不必要に増やさず、人間の費用判断と必須安全水準を両立し、能力不明の代替を防ぐため | 2026-10-09 |
| 135 | Spec Tierはspec単位を基本とする。Review Modeはgate・review対象・review対象hash単位とする。Model Classはrole・作業単位・入力hash単位とする | 文書深度の全体一貫性を保ちつつ、一部の高riskを平均化せず、同一spec内の異なる能力需要を表現するため | 2026-10-09 |
| 136 | scope、AC、責務境界、依存、移行段階の増減時はTierを再判定するが、その変更だけで他二軸を自動変更しない。対象hash、risk、不確実性、rollback、外部副作用、検証可能性の変更時はReview Modeを再判定し、上方変更時は必要review完了まで停止する。下方変更には危険条件が消えた証拠を要求し、予算不足だけでは認めない。role、作業内容、判断量、入力hash、能力mapping変更時はModel Classを再判定する。review収束中のmodel IDまたは推論設定変更はreviewer交代としてfresh reviewをやり直す | 古い分類の流用、便宜的な降格、review主体の実質変更の隠蔽を防ぐため | 2026-10-09 |
| 137 | 各軸の分類値と判定状態`RESOLVED / UNRESOLVED / BLOCKED / STALE`を分離する。scope、対象、入力hash等の必須事実が未取得なら推測分類せず`UNRESOLVED`とし、証拠収集以外を停止する。証拠が矛盾して優先関係を決められない場合は`BLOCKED`として人間へ戻す。合理的な調査後も残る対象固有の不確実性は未取得情報と区別してReview Modeの正規入力とし、`DEEP`境界はE-2へ保留する。必要classに適格なmodelまたはmappingがなければ実行解決を`BLOCKED`とし、classを下げない。未判定をTier L、`DEEP`、`Critical`等の最大値で埋めない。具体schemaはDesignへ保留する | 未調査、残存不確実性、実行不能を同じ安全分類へ丸めず、対象不明の高費用処理を安全と誤認しないため | 2026-10-09 |
| 138 | 能力水準は軽量・標準・高度の三段階を維持するが、`Lightweight`名称は暫定候補とする。旧`Mechanical`相当は軽量routingとして残し、通常の仕様・risk判断へ利用範囲を広げない。`Mechanical`の判断禁止は能力classそのものではなく実行制約`MECHANICAL_ONLY`として分離し、機械検証可能な抽出・変換・集計だけを許可する。risk、仕様、設計、test充足性、finding重大度、情報省略を判断させない。上位能力modelが代行しても制約を緩和せず、`MECHANICAL_ONLY`指定だけで任意modelを適格とみなさない | 軽量routingを維持しながら、能力水準と判断権限を分離し、上位model代行による権限拡張を防ぐため | 2026-10-09 |
| 139 | 各分類は観測事実とその軸への影響理由を追跡可能にし、同じ事実を複数軸で使う場合も各軸への理由を示す。Tierでは独立AC、責務境界、依存、設計選択、移行、人間判断を証拠とし、行数・file数・時間は調査の手掛かりに限り単独分類に使わない。Review Modeでは影響対象、失敗結果、不確実性、検証範囲、rollback、副作用、暗黙契約を証拠とし、Tier、期限、予算、強いmodel、test PASSだけを安全分類の根拠にしない。Model Classではroleの判断、制約統合、曖昧性、反例探索、domain知識、機械検証可能性を証拠とし、model名、価格、世代、context長だけで判定しない。期限・予算は実行計画またはscope縮小に使うが、必要review強度・能力水準を下げる証拠にしない | 入力量の重複禁止ではなく判定理由の独立性を守り、量・製品名・費用都合による誤分類を防ぐため | 2026-10-09 |
| 140 | 旧Decisionとの関係を次のとおり固定する。#77・#78は三軸・namespace分離と同一文書体系内のTier別深度を維持する。#79〜#81は目的・安全条件を維持し、#132〜#139の判定順、権限、粒度、未判定状態、証拠、実行制約分離で改訂する。#82・#83は段階的再検証と実例検証を維持し、#83の実例はrevisionと証拠を確認してE-2/E-8で扱う。#24はTier連動の固定review回数を適応型判定へ置換し、高risk検証と人間承認の目的を維持したまま適用条件・回数をE-2/E-3で決める。#25〜#29は現行の改訂関係込みで維持し、review収束はE-3、agent構成・dispatchはE-4へ渡す。#29のoverlay固定撤回とcore/adapterによる明示置換・fail-closedを維持する。#30・#34・#35は三段階の必要能力を維持し、`Mechanical`の禁止判断を実行制約へ分離し、上位代行でも制約を変えないよう改訂する。#31の旧model対応は履歴・候補として保持し、現在の適格性保証へ流用せず両providerの更新可能なmappingへ接続する。#32・#33・#36〜#39はrole別最低能力、Critical適格性、未知mapping時停止、reviewer変更、証跡、#41のpolicy所有、総費用評価を維持し、E-3/E-4/E-5/E-8で具体化する。#93〜#97はE-1で変更せずE-6で具体化する。Decision全体をretireする対象はなく、置換部分、維持目的、後続保留を分ける | 旧Decisionを一括廃止または暗黙維持せず、E-1で変わる契約と後続論点を追跡可能にするため | 2026-10-09 |
| 141 | E-5ではOpenAI・Anthropic双方についてmodel ID、世代、推論設定、対象roleを含むmapping、適格性、更新・代替条件を人間と判断する。現時点で具体modelを適格認定しない。代表作業によるmapping評価方針は採用するが、候補作成・評価・正式適用の工程、代表作業の選定、入力、期待結果、合否、実施者、証跡、再評価条件をE-5で決め、通常実装1件の成功だけでsecurity review等へ適格性を拡張しない。更新頻度と契機は、定期、人間の更新依頼、model追加・更新・廃止、推論設定変更、評価失敗・品質低下・retry・手戻り増、利用開始・gate前の鮮度確認、併用、その他を事前に排除せず、情報確認頻度、再評価頻度、正式適用時点、旧mapping継続条件、再評価範囲、費用、人間判断条件を含めてE-5で決める | 具体modelの未検証な固定を避け、provider更新とrole適格性を再現可能な評価へ接続するため | 2026-10-09 |
| 142 | E-1のRequirements候補は三軸分離、証拠追跡、判定責務・時点・粒度、未判定停止、再分類、最低能力と実行制約分離とし、Discovery統合後のRequirements工程へ渡す。具体field/schema、hash構成、状態遷移実装、証拠参照format、`Lightweight`正式名称は、E-1の意味contractを弱めず、人間承認後のDesign工程で扱う。`STANDARD / DEEP`境界、review範囲・依存、昇降格、巡回、stale、前gate復帰はE-2/E-3へ、agent topologyはE-4、model mappingはE-5、contextはE-6、通知・approval navigation・転記workflowはE-7、計測・既存Issue移行はE-8へ渡す。#39は#41 policyに従う独立review実装・状態・証跡・validation、#32はskill/helper検出・明示/自然言語起動・semantic parity・fresh-session E2E、#31はuser-facing通知UXを所有する。#31の通知境界はE-7で決め、最終順序はDiscovery統合で判断する。各Issueの旧承認・旧順序を新契約の実装許可へ流用せず、#32の停止中local commit/worktreeを変更しない。通知はapprovalを代替しない。Task A〜Dは本Decisionから暗黙改訂せず、衝突、owner変更、新公開contractが判明した場合は人間判断へ戻す | E-1の意味contractを将来工程へ漏れなく渡しながら、未決方式、既存Issue、先行Taskの権限を混同しないため | 2026-10-09 |
| 143 | **C1: reviewの強さは変更の影響と証拠で決める。** 主agentは現gateに必要な基本事実の不足・矛盾を先に処理し、必須条件、具体的な独立review推奨理由、通常reviewで扱える根拠の順に判定する。未取得は`UNRESOLVED`、解消不能な矛盾は`BLOCKED`とし、Modeを推測せず必須条件を相殺しない。領域名ではなく、data・利用者資産、security・権限・PII、公開契約、外部副作用、並行・復旧、SDD安全規約、infra、停止・枯渇・性能に関わる運用parameter、production AIについて、保護対象・振る舞い・境界・安全保証への実際の変更で自動昇格を判定する。対策、backup、test PASS、未検証の自己申告だけでは該当を消さない。公開契約への追加を一律昇格から外せるのは、保証対象consumerと契約範囲が明示され、既存動作・出力・error・既定値・解釈を変えず、他の必須条件に非該当で、停止・撤回後も既存契約とdataを維持できる証拠がすべてある場合だけとする。この例外でもSTANDARDを自動確定せず、新公開contractの人間承認gateを省略しない。合理的調査は変更・保護対象、確認した仕様・code・契約・test、確認済み・未確認、残疑問の検証方法または解消不能理由を含むagentの説明責務とし、時間・file数や人間への定型入力で代用しない。調査後も具体的な安全上の失敗経路を通常検証で否定または影響限定できなければ`DEEP_REQUIRED`、必須非該当で影響が人間と合意したscope・AC・運用条件・回復条件に収まる根拠と独立確認論点があれば`DEEP_RECOMMENDED`、現gateの事項を通常review・検証で確認でき独立review追加理由がなければ`STANDARD`とする。許容条件をagentが捏造せず、不明なら人間へ確認する。必要test・証拠不足・未達ACをMode選択で合格にせず、DEEP reviewerが必要情報へアクセスできなければ検証不能を停止・未解決として残す。判定はtaskの分け方に左右されず、変更同士の相互作用を含む失敗経路に基づき、独立した追加承認手続きや点数表は設けない | 未調査、単語、対策実施、task分割を安全判定へ転用せず、実際の影響・残存不確実性・検証能力から必要reviewを決めるため | 2026-11-25 |
| 144 | **C2: 人間は必要水準を保ったまま実行方法を選ぶ。** `DEEP_RECOMMENDED`は人間が拒否して`STANDARD`実施を選べるが、判定自体を書き換えず、推奨理由、拒否事実、残論点を追跡し、通常の必須検証を維持する。`DEEP_REQUIRED`の拒否または予算・環境による実行不能時は必要水準を維持し、必要reviewに依存するgate通過と後続対象作業を停止して延期、scope縮小、中止へ戻す。強いmodelや同一context自己reviewで代替せず、独立性の未検証な自己申告で迂回しない。一方、必要reviewへ依存しない承認済み作業までは一律停止しない。無応答、時間経過、一般的な好意的反応を承認にせず、scope縮小時も変更後の対象・hash・副作用を再評価して必要な人間承認を維持する | 費用・実施方法の人間選択と、安全水準の解除・暗黙承認を分離するため | 2026-11-25 |
| 145 | **C3: 承認範囲内の通常調整は自律進行し、実質的拡張・前提崩れだけ影響部分を見直す。** DEEP実行前に、推奨・必須の根拠と確認論点、spec・gate・対象成果物・基準version/hash、role・agent数・必要class、context・機密情報・外部送信、最大巡回数・Token/時間見積区分・実行上限、上限到達・不能・拒否時動作を持つ計画を提示して人間承認を得る。取得不能値は`UNAVAILABLE`とし0または無制限にしない。作成前成果物では基準hashを持つ実行計画を承認対象とし、実入力hashを実行前に確定・記録して計画内か検証する。既存phase承認へreview計画を明示的に含めることはできるが、将来成果物の内容承認やreview後の人間承認を代替しない。計画内の通常指摘修正・再確認では費用承認を繰り返さない一方、input freshnessと再分類を確認し、費用承認の継続を古いreview結果の有効性と混同しない。対象scope、agent数、context、外部送信先、承認済み費用・時間等の実質的拡張は実行前に再承認し、上限到達時は未解決事項と追加見積を示して継続・scope縮小・停止を人間へ戻し、黙って巡回を追加しない。`STANDARD`から`DEEP_RECOMMENDED`への変更は理由・計画を示し、人間が拒否した場合は#144の推奨拒否規則へ戻す。`STANDARD`または推奨から必須への変更では依存gateと後続対象作業を停止して必要review完了後に再開する。Modeを下げる場合は危険条件または推奨理由が消えた証拠と他の必須条件を再確認し、test PASS、review実施済み、予算不足、納期だけを根拠にしない。途中変更時は変更前後Mode・対象hash、新事実または解消条件、影響するgate・作業・review結果・承認、再開条件をagentが追跡するが、人間へ細則ごとの採否を要求しない。承認済みrequirements・designの前提崩れはDEEP追加だけで続行せず該当前段gateへ戻し、review鮮度等の詳細は統合実行方針で具体化する | 費用・情報処理の承認範囲を守りながら、通常の修正往復を過剰な再承認にせず、stale結果や前段承認の迂回を防ぐため | 2026-11-25 |
| 146 | **壁打ちは重要なdecision package単位で行う。** 人間には、守る安全境界、費用・権限のtrade-off、既存合意を変える重要差分をまとまった案として示し、通常詳細はagentが案と具体例・反例を整理して実質差分がなければ質問を増やさない。採用済み意味を共通原則へ統合しつつ細則自体の必要性を点検し、単に表示を短くして全細則を恒久必須化しない。不要詳細は意味統合、後段保留、改訂候補に分け、安全条件を変える場合だけ明示して人間へ戻す。原子的handoff IDは転記完全性の内部表現であり、人間への原子的承認義務にしない。人間は統合案の重要差分を判断し、agent・orchestrator・source sessionがID分解、正本対応、逆照合を行い、新しいtrade-offまたは意味変更が見つかった場合だけ人間へ戻す | 追跡可能性を維持したまま、壁打ちを細則ごとの承認会にせず、人間負担とproduct policyの過剰設計を抑えるため | 2026-11-25 |
| 147 | E-2による旧Decisionとの関係を次のとおり固定する。#6・#8は必須条件1件で昇格する安全目的を維持し、実影響判定と公開契約追加の条件付き例外を#143で具体化する。#9のproduction AI原則高riskと証明付き隔離read-only例外は維持し、新例外・具体modelを追加しない。#10は後方互換追加等を単独自動昇格にしない目的を維持し、公開契約例外の証拠条件と相互作用評価へ接続し、件数だけで昇格しない。#11は基本事実未取得の`UNRESOLVED`と合理的調査後の安全上の残存不確実性を区別するよう改訂する。#79・#80および#134・#136・#137の三Mode、人間承認、粒度、再分類、状態分離を維持して#143〜#145で具体化し、#132〜#142を弱めない。#24・#25・#30〜#39・#93〜#97は既存改訂込みで維持し、具体review回数、agent数、Token閾値、model IDを新規固定しない。#117〜#119の原子的対応、hash、source確認、`CANONICALIZATION_PASS`までのfail-closedを維持し、人間の壁打ち粒度とは分離する | E-2の統合が既存安全目的を黙って廃止したり、原子的監査を原子的な人間承認へ誤変換したりすることを防ぐため | 2026-11-25 |
| 148 | 後続は独立した細則承認列ではなく二つの統合packageとして扱う。E-3〜E-7では独立review・収束、agent構成、Model Class/provider mapping、context/session分割、通知・approval navigation・転記workflowを一体の実行方針案として検討する。E-1〜E-8はcoverageを示すもので各項目の独立承認gate数を意味せず、新しい固定承認回数を設けない。OpenAI・Anthropic双方のmapping、role別代表作業の評価内容・実施段階・正式適用、更新頻度・契機を含め、人間の更新依頼等の候補を事前排除しないが、具体model適格性を未検証で認定しない。E-8ではhard safety、効率目標、#39/#32/#31の再利用・stale・実装owner、代表case・段階導入の証明内容を検証・移行方針として整理し、計測field・fixture詳細ごとの人間採否を求めない。三統合方針と人間負担削減をRequirements候補とし、schema、UI、event、context field、具体計測方法、fixture等は重要Decisionに不可欠でなければ人間承認後のDesignへ保留し、Discovery統合DQ PR merge前にRequirementsを生成しない。局所修正、途中scope変更、data移行の仮想例は机上確認に留まり、実運用の時間・Token・過剰DEEP率は未計測とする。`cyclox2_docker`指定branch実例はsource sessionの前回local調査でref不在と報告された未検証事項としてE-8へ渡し、実証済みまたは確認済み事実として引用しない | coverageと承認gate数を混同せず、未検証の詳細や具体modelを固定しないまま、実行policyと検証・移行policyへ責務を収束させるため | 2026-11-25 |
| 149 | **Task Eのreview・agent実行方針を統合する。** `STANDARD`は主agent、`DEEP`は必要能力を満たすfresh独立reviewerが担当し、既存の独立性、原則1 reviewer、同一reviewerによる収束、最大10巡の上限を維持する。計画内の通常修正では承認を繰り返さない。主agentはorchestrationと通常作業を兼任し、必要なroleだけを追加する。active subagentは通常1体とし、累計起動数へ固定上限を置かない。並列化はToken節約とみなさず、独立責務、非重複範囲、context・費用、統合方法、時間短縮効果を示して人間が例外承認した場合だけ行う。利用者向けのskill開始・完了・判断要求は親agentへ集約し、helper内部通知を乱発しない。通知、review完了、source確認待ちを人間承認または全体完了へ読み替えない | 必要な独立性と人間承認を維持しながら、重複context、並列統合、通知、再承認の負荷を抑えるため | 2026-11-25 |
| 150 | **Model Classはprovider中立に運用し、更新方式Bを採用する。** OpenAI・Anthropic双方についてrole別に評価し、model名、価格、世代だけでclassを決めず、登録済みの適格構成から選ぶ。軽量・標準・高度の能力水準、`MECHANICAL_ONLY`制約、Critical能力下限、無断降格禁止、未知mapping時の停止を維持する。初回登録または未評価構成への変更は正式適用前に、roleを代表する抽出・変換、AC付き通常作業、欠陥埋込みreview等で評価するが、具体fixture・合否基準はDesign・検証で確定する。毎taskで評価一式を繰り返さず、利用時は取得可能な構成情報・利用条件と登録済み適格構成の整合を確認する。人間の更新依頼を常に受け付け、観測可能な構成変更・品質変化等から再評価を提案する一方、定期再評価を当初の常時既定にはしない。観測不能を変更なしとみなさず、未評価model、provider越え代替、review中のmodel・推論設定変更を自動承認しない。model・provider変更を理由に別Workspaceを黙って作成したり、外部送信先・送信範囲を無断変更したりせず、既存の停止、人間承認、機密情報保護を維持する。定期再評価の選択肢は排除せず、必要性が判明した時点で費用とともに人間が判断する。今回、具体周期、schedule、model ID、実評価合格は確定しない | provider更新へ追従できる能力保証と、常時評価・毎task評価による費用増大の両方を避けるため | 2026-11-25 |
| 151 | **Context・session・通知は正本参照と最小情報を基準にする。** 主agentとsubagentは正本参照とrole別の最小情報を優先し、工程の区切りで引き継ぎ、早期compactを安全弁として使う。全platform共通の固定Token閾値は設けず、#93〜#97および#104〜#106の未固定差分、workspace参照、機密情報除外、設定非破壊、semantic parityを維持する。schema、通知event一覧、具体設定・model ID、context計測API・閾値はDiscovery判断に不可欠でなければ人間承認後のDesignへ保留する。Task Eの方針採用を、mapping登録、model評価合格、storage・lifecycle実装、通知実装の成功へ読み替えない | Context再投入と情報欠落を減らしつつ、未検証の実装詳細や固定閾値をpolicyへ持ち込まないため | 2026-11-25 |
| 152 | **E-8の安全性検証は`B0 / B1 / C`を分離する。** `B0`を現行実装との互換性、`B1`を全gate独立review比較方式、`C`を今回の候補として扱い、`B1`は比較fixtureであって旧#39の全gate方式をcurrent policyへ復活させない。局所低risk、調整複雑な通常変更、小規模でも高riskな合成変更を、期待分類、判断、trace、埋込みblockerを持つgolden manifest付き代表caseで検証する。Tier Lだけを理由にDEEPや固定review回数を割り当てず、task分割による判定逃れと過剰reviewの両方を検査する。#58のapproval bypass、必要review欠落、stale review、seeded blocker見逃し、根拠のないblocking、trace・TDD・navigation・parity欠落、Critical downgradeを独立したhard safety条件として維持し、効率改善で相殺しない。仮想例・fixture合格を実環境全体の無欠陥保証にしない | 安全条件を削っただけの軽量化や、少数fixtureによる過剰な一般化を防ぐため | 2026-11-25 |
| 153 | **効率は同一platform内の`B1`対`C`で多面的に測り、段階的に両platformを検証する。** Token・context、時間、人間負荷、文書・context重複、品質、retry、手戻りを区別し、取得不能値は`UNAVAILABLE`として0扱いせず、provider間の生Token比較だけで改善を宣言しない。まずCodexでhard safetyを確認し、次にClaude Codeで同条件を測るが、片側だけでparity成功としない。#59の削減率は初期目標として保持するが、#60の閾値、`B1`再現性、fixture偏りを正式reviewする前に保証値または安全性を相殺する合否基準へ昇格しない。閾値近辺は最大3回再計測し、安全上必要な高risk費用例外は人間判断を維持する | 未取得値、provider差、一回の非決定的計測、暫定目標を改善証明へ誤用しないため | 2026-11-25 |
| 154 | **既存Issueと新contractの移行を段階管理する。** #39は#41 policyに従う独立review実装、#32は全user-facing skill/helperの検出、明示・自然言語起動、semantic parity、fresh-session E2E、#31は通知UXを所有する。旧全gate必須承認、停止中の#32資産、#31の旧着手順を新contractの実装許可へ流用しない。Task A〜Fと最終統合後に依存、競合、受入条件から実装順を確定し、共通policy version/hashとClaude/Codex両adapterのsemantic parityが揃うまで新contractをactiveにしない。完了済みspecへ遡及せず、active specはgate境界で意味差・staleを評価し、導入不備時に旧policyへ黙ってfallbackしない。未Decision Issueを並列実装候補として起動せず、Discovery後に実装対象、後回し、不要・置換済みへ分類する。今回の採用からIssue更新、実装、commit、push、PRを推定しない | staleな承認や片側実装を流用せず、既存Issueの責務を保った移行とactivationを行うため | 2026-11-25 |
| 155 | **Task EのDiscovery方針と後続ownerを固定する。** Workspace ownership/isolation、lease・operation lock、resume・close・recovery、adapter・discovery・E2E、state・output保存とlock方式はTask F、#32、#39、Designが所有する。Task Eの実行意味contractをcore・adapterへ実装し、`kiro-impl`等のdispatchと衝突して適用不能ならfail-closedとする。role別評価の具体基準・fixture・実model対応、context計測API・閾値、通知schema、受入試験code・測定環境は人間承認後のRequirements・Design・検証へ渡す。Task A〜D、E-1/E-2、#25〜#39、#93〜#97、#101〜#119、#121、#128、#130、#141、#148の既存改訂込みの安全目的・ownerを維持し、並列承認、上限、Critical非降格、人間approval、非破壊、転記完全性を黙って緩和しない | Task Eを完了可能な方針へ収束させながら、Task Fと後続工程の責務を奪わず、未確定事項を成功扱いしないため | 2026-11-25 |
| 156 | **Task Fは変更可能なWorkspaceの所有と分離を保証する。** 各mutable Workspaceには識別可能な所有sessionを一つだけ割り当て、同じWorkspaceまたは管理stateを複数sessionが同時変更しない。worktree、checkpoint、read-only参照の存在だけでは所有・分離・変更権限を証明しない。開始・再開時にsession、Workspace、repository、revision、未commit変更、承認・正本化状態の整合を確認し、所有者不明、stale、矛盾、未検証なら読み取り診断以外の変更を`UNVERIFIED`または`BLOCKED`として止める。main worktree、共有outputs、共有stateへ書き込む場合は、所有者、出力先resolver、衝突preflight、復旧原則を満たすまで有効化せず、自動fallbackしない | worktree分離やcheckpointを実際の所有権と誤認し、session間で利用者資産・state・outputsを競合させないため | 2026-11-25 |
| 157 | **Workspace LeaseとOperation Lockを別責務とする。** LeaseはsessionによるWorkspaceの所有・生存状態を表し、Operation Lockはinstall、sync、publish、state移行等、共有資源を変更する短時間のcritical operationを直列化する。worktreeまたはLeaseだけでGit共通領域、設定、state、outputsへの操作排他を代替せず、Operation Lockだけで継続的なWorkspace所有を代替しない。取得失敗、所有競合、staleか判断不能な状態では操作を停止し、無断で奪取しない。期限、更新、回収、保存先、lock粒度、順序、deadlock対策、process・OS間方式はDesign・実機検証で決める | 長期所有と短時間の共有資源操作を混同せず、競合時に黙ったlock奪取や破壊的復旧を行わないため | 2026-11-25 |
| 158 | **Session lifecycleは非破壊のresume・close・recoveryを保証する。** Resumeはcanonical source、checkpoint参照、未固定の最小差分から復元し、会話要約・raw transcriptを正本とせず、自動commitまたは未確認変更の吸収を行わない。正常closeでは実行中operationを安全に完了または停止し、LockとLeaseを解放し、未完了変更、成果物、blocker、pending-canonicalization、再開に必要な参照を発見可能な状態で残す。必要なsource確認前にagentが正常完了・archiveした扱いにしないが、人間によるアプリ終了自体を禁止せず、中断可能な状態を保持する。異常終了時は孤立Lease・途中operationを検出して変更を止め、read-only診断の上で再接続、再開、現状保持、rollback等の候補を示す。未commit・所有者不明の資産を自動削除せず、復旧中・未検証を成功へ丸めない。具体schema、保存、retention、暗号化、crash検出、cleanup UIはDesignへ渡す | セッション切断やcompactをデータ喪失・二重実行・転記欠落へ変えず、安全な中断と復旧を両立するため | 2026-11-25 |
| 159 | **Legacy Bridgeとrollbackは同一state・非破壊・可逆を保証する。** 新旧入口は同じ`.kiro`、spec、approval、test、進行stateを使用し、二重stateを作らない。未知field、project override、追加skill、環境固有設定、利用者所有fileを保持し、競合・所有不明・parity未検証時は差分、影響、候補を示して人間判断へ戻すか既存環境を保持して中断する。rollbackは無関係なGit履歴・未commit変更・利用者資産・証跡を破壊せず、管理対象の入口、設定、配布差分を検証済み手順で直前の稼働可能な状態へ戻せることを要求する。「管理対象を一切戻さない」という禁止には拡張しない。未知field、承認履歴、test証跡を保持し、state形式の意味変更は明示的・可逆的・rollback検証済みの別Decisionと人間判断を必要とする。旧入口は旧資産の開始・再開・完了、同一state、rollback、parity、新名称での配布・発見・更新をE2Eで確認し人間が承認するまで廃止しない。部分適用・未検証を移行成功と報告しない | 利用者資産と証跡を守りながら、旧入口を無期限に惰性維持せず検証可能なbridge・rollbackへするため | 2026-11-25 |
| 160 | **Claude Code / Codex parityは観測可能な意味の一致で受け入れる。** 共通policy version/hash、同じcanonical state、approval・review、checkpoint・resume、Workspace競合時停止、critical operation排他、Legacy Bridge、rollback、未知field・利用者資産保持、異常終了recovery、成功・未検証・停止状態の報告を両platformで保証する。platform固有adapterの機械的実装差は認めるが、既存規約が同一内容を要求する`AGENTS.md`・`CLAUDE.md`、共通snippet、`.claude`・`.agents`の共通`kiro-*`変更、両install先の同一bundle等の同一性契約は維持する。全user-facing skill/helperについて、明示起動だけでなく自然言語起動、直接skill・subagent経由の意味一致、fresh-session検出・起動E2Eを含め、`doc-export`の直接CLI contractも維持する。release受入ではclean環境、未完了の旧project、利用者override・未知field、同時mutable session競合、critical operation中断・recovery、rollbackを両platformで検証する。各利用projectで未使用platformの毎回実行は求めないが、release受入の片側未検証・失敗を全体成功と報告しない | platform固有差と共通配布物の同一性契約を混同せず、利用者が観測する起動・安全・復旧の同等性を片側成功で偽装しないため | 2026-11-25 |
| 161 | **Task Fで確定するのは保証境界・責務・停止/復旧原則であり、実装成功の宣言ではない。** Discoveryでは#156〜#160の所有、fail-closed、二種の排他、lifecycle、bridge・rollback、semantic parity、受入scenarioをRequirements候補として確定する。Leaseのidentity・TTL・更新・回収、Lock backend・path・粒度・順序・deadlock、Workspace構成、output resolver、atomic publish、checkpoint schema、backup、暗号化・retention、CLI・UI、cleanup、adapter実装は人間承認後のDesignへ保留する。実機ではClaude Code/CodexのWorkspace挙動、process・OS・filesystemを跨ぐlock、crash injection、並行E2E、旧URL・package・CLIの配布実態、`spec.json` field、rollback、Token・時間・負荷改善を検証する。「ハーネス仕様が固まった」は保証境界と方針の確定を意味し、実装、parity、migration、効率改善の達成・証明を意味しない。新contractはDesign・実装・検証・人間承認前にactiveにしない | Discoveryの仕様確定を未実装・未検証の成功宣言へ拡大せず、後続工程の判断対象を明確にするため | 2026-11-25 |

---

## Task A〜F handoff正本化カバレッジ監査

> 2026-09-21以降、各専用sessionのstructured handoffと正本Decisionを項目単位で再照合している。
> `CONFIRMED`は意味、主体、条件、例外、未決状態まで正本で再現できた項目、`RESTORED`は
> 本監査で不足を訂正Decisionへ復帰した項目を示す。handoff本文に存在するだけでは正本化完了とみなさない。

### Task A

| handoff項目 | 正本Decision | 結果 | 確認内容 |
|---|---|---|---|
| A-1 V1互換性 | #67〜#70 | `CONFIRMED` | 構造・起動互換、既存state、未知field、全`kiro-*`、保証外を保持 |
| A-2 品質条件 | #71、#111 | `RESTORED` | 不変条件に加え、品質衝突時の影響・代替案・回帰試験・人間判断を復帰 |
| A-3 製品表示 | #72〜#73 | `CONFIRMED` | 主見出し、価値、独立・非提携、MIT帰属を保持 |
| A-4 名称移行 | #74 | `CONFIRMED` | 即時rename禁止、条件ベースの旧入口維持、E2Eと人間承認を保持 |
| A-5 状態互換・案内 | #75〜#76 | `CONFIRMED` | in-place bridge、二重state禁止、旧入口利用時だけの案内を保持 |
| A-6 後続制約・未決調査 | #112 | `RESTORED` | Task B〜Fの拘束、fresh-session E2E、旧配布経路、alias/redirect/rollback、`spec.json`棚卸しのownerを復帰 |

### Task B

| handoff項目 | 正本Decision | 結果 | 確認内容 |
|---|---|---|---|
| B-1 固定source・一方向fork | #84 | `CONFIRMED` | 固定tag/commit/path/tree SHA、継続baselineを持たない境界を保持 |
| B-2 全体比較・保証platform | #85 | `CONFIRMED` | `tools/cc-sdd`全体比較とClaude Code/Codex限定保証を保持 |
| B-3 五層architecture | #86 | `CONFIRMED` | core、両adapter、project override、legacy bridgeの所有を保持 |
| B-4 license・帰属・配布 | #87〜#88、#113 | `RESTORED` | 将来source来歴、生成projectへの例外伝播、曖昧時の判断を復帰 |
| B-5 将来の外部source | #89 | `CONFIRMED` | 提案からrollbackまでのgateとAIの実行限界を保持 |
| B-6 build・dependency・install | #90、#114 | `RESTORED` | build/package責任、明示的禁止事項、Design保留を復帰 |
| B-7 非破壊install・sync | #91、#115 | `RESTORED` | 保護対象、禁止操作、中断、完全成功としない条件を復帰 |
| B-8 Issue・後続Task責務 | #92、#116 | `RESTORED` | #30/#32とTask C/D/E/Fのownerを復帰 |
| B-9 ACTIVE・分類規則 | #92、#116 | `RESTORED` | 1件ACTIVE、Discovery後の全Issue分類、未Decision Issueの並列化禁止を復帰 |
| B-10 未決調査 | #116 | `RESTORED` | build、substantial portions、dependency監査、優先順位、専門家判断を復帰 |

### Task Cで確認した先行欠落

| handoff項目 | 正本Decision | 結果 | 確認内容 |
|---|---|---|---|
| C-11 review観点の適用主体 | #102、#110 | `RESTORED` | 8観点の対象を主agent・fresh reviewerだけでなく人間reviewへも復帰 |

### Task D

> source handoff: `TASK_D_HANDOFF_V1`。受信本文SHA-256
> `3984d7fb95428bf48fdd10c6f13034767d6eed20bf35b573d81921988091cbc1`。
> source packet SHA-256 `dab0818b0957d61345b7f56b6b2ca96498036a1e836d6a6ff79982dd6fb1d028`。
> 2026-10-08に送信元sessionが対象hashと全111 IDを再照合し、`CANONICALIZATION_PASS`を返した。

#### ADOPTED項目

| handoff ID | 正本対応 | 状態 | 保持した意味 |
|---|---|---|---|
| D1-01 | #120 | `ADOPTED` | PPTは理解・共有用の派生viewで、正本・正式approval対象ではない |
| D1-02 | #120 | `ADOPTED` | 正本reviewへの明示遷移後だけapprovalが成立する |
| D1-03 | #120 | `ADOPTED` | 正本を開くか対象を明示選択する操作をapproval前に必須とする |
| D1-04 | #120 | `ADOPTED` | PPT閲覧中の一般的肯定をapprovalへ昇格させない |
| D1-05 | #120 | `ADOPTED` | 正本へアクセスできない相手はfeedback可能だが正式承認者にしない |
| D1-06 | #120 | `ADOPTED` | 未掲載の条件・例外・禁止・risk・未決の存在を正本遷移前に示す |
| D1-07 | #121 | `ADOPTED` | 承認境界をClaude Code/Codexで意味的に同一にする |
| D2-01 | #122 | `ADOPTED` | gateでPPT生成を提案するが自動生成しない |
| D2-02 | #122 | `ADOPTED` | 人間の明示依頼後だけ生成する |
| D2-03 | #122 | `ADOPTED` | 形式未指定時は一意なpending gate用phase profile PPTを既定とする |
| D2-04 | #122 | `ADOPTED` | gate・phaseが一意でなければ推定せず確認する |
| D2-05 | #122 | `ADOPTED` | Word・PDF・複数形式・複数phaseは明示指定時だけ生成する |
| D2-06 | #122 | `ADOPTED` | 4つのprofile候補を保持し、exact schemaはDesignへ保留する |
| D2-07 | #122 | `ADOPTED` | PPT失敗だけで正本reviewを禁止しないが、依頼失敗を成功と報告しない |
| D2-08 | #122 | `ADOPTED` | 現行DOCX既定をmigration・compatibility対象にする |
| D3-01 | #123 | `ADOPTED` | 意味維持範囲で並べ替え・要約・言換え・表図化を許可する |
| D3-02 | #123 | `ADOPTED` | 主体からstable IDまでの意味要素を削除・変更しない |
| D3-03 | #123 | `ADOPTED` | 正本にない判断・関係・approval等を事実として追加しない |
| D3-04 | #123 | `ADOPTED` | 意味を持つ順序を維持し、不明なら勝手に並べ替えない |
| D3-05 | #123 | `ADOPTED` | 規範強度を変えず、必要な原文を保持する |
| D3-06 | #123 | `ADOPTED` | 統合は元ID追跡可能かつ異なる条件・例外を丸めない場合だけ許可する |
| D3-07 | #123 | `ADOPTED` | 図へ新しい箱・矢印・依存を追加しない |
| D3-08 | #123 | `ADOPTED` | 収まらない場合は分割・appendix・正本参照を使い黙って短縮しない |
| D3-09 | #123 | `ADOPTED` | 正本にない判断を推論補完せず人間へ戻す |
| D4-01 | #124 | `ADOPTED` | artifactごとのsource・generator・template・日時metadataを記録する |
| D4-02 | #124 | `ADOPTED` | 掲載・意図的省略・失敗・不在・未確認を区別する |
| D4-03 | #124 | `ADOPTED` | 主要slideに読める参照、reportに詳細mappingを残す |
| D4-04 | #124 | `ADOPTED` | 生成・review開始・正本approval遷移時にsource hashを再確認する |
| D4-05 | #124 | `ADOPTED` | source file変更で原則全体STALE、非意味変更最適化はDesign保留 |
| D4-06 | #124 | `ADOPTED` | 5つのartifact状態を区別し、CURRENTだけでREVIEW_READYにしない |
| D4-07 | #124 | `ADOPTED` | 再確認不能な外部共有物を現在の承認資料と保証しない |
| D4-08 | #124 | `ADOPTED` | 省略時も重要事項の存在と正本参照先を主要部分から分かるようにする |
| D5-01 | #125 | `ADOPTED` | version管理された既定PPT templateとproject overrideを提供する |
| D5-02 | #125 | `ADOPTED` | 明示指定、project override、既定templateの優先順を保持する |
| D5-03 | #125 | `ADOPTED` | profileの意味要素とvisual themeの見た目を分離する |
| D5-04 | #125 | `ADOPTED` | overrideで必須の承認・意味要素を削除できない |
| D5-05 | #125 | `ADOPTED` | 利用者所有overrideを更新処理で破壊・再生成しない |
| D5-06 | #125 | `ADOPTED` | override非互換時はsilent fallbackせず人間へ戻す |
| D5-07 | #125 | `ADOPTED` | 既定templateのCJK・font・長文・重要表示領域を支援する |
| D5-08 | #126 | `ADOPTED` | 外部asset・rendererをdependency contractで別途採否判断する |
| D5-09 | #126 | `ADOPTED` | 具体採用を含めず、cc-sdd由来同梱時のMIT帰属を再確認する |
| D6-01 | #127 | `ADOPTED` | renderer exit成功だけを品質合格にしない |
| D6-02 | #127 | `ADOPTED` | 構造・render・参照・mapping・coverage・visual defect等を毎回自動検査する |
| D6-03 | #127 | `ADOPTED` | formal gateでPPTを使う場合は全rendered slideの人間visual QAを必須とする |
| D6-04 | #127 | `ADOPTED` | visual QAの具体的な可読性・埋没・案内・warning観点を保持する |
| D6-05 | #127 | `ADOPTED` | 参考共有のvisual未確認artifactをREVIEW_READYと呼ばない |
| D6-06 | #127 | `ADOPTED` | 自動検査からREVIEW_READYまでの状態を意味上区別する |
| D6-07 | #127 | `ADOPTED` | fail・未解消warn・visual fail・stale・unverifiedを成功扱いしない |
| D6-08 | #127 | `ADOPTED` | renderer未導入はNOT_GENERATEDで、部分続行を全体成功にしない |
| D6-09 | #127 | `ADOPTED` | visual QAを意味同等性確認・正式approvalの代替にしない |
| D6-10 | #127 | `ADOPTED` | 両platformで同じ状態・block・reportを使い、検証不能を推測PASSにしない |
| D7-01 | #121 | `ADOPTED` | 両platformのskill・自然言語・直接CLIで意味的に同じ入口を持つ |
| D7-02 | #128 | `ADOPTED` | 対象属性を一意にし、不明なら確認する |
| D7-03 | #128 | `ADOPTED` | 生成前に対象・費用・QA・再取得・再現性riskを提示する |
| D7-04 | #128 | `ADOPTED` | 取得不能なToken等をUNAVAILABLEとし0扱いしない |
| D7-05 | #129 | `ADOPTED` | 二次成果物は既定gitignoreのbuild outputで、外部Driveを必須にしない |
| D7-06 | #129 | `ADOPTED` | upload・Git操作・archive・dependency導入を自動実行しない |
| D7-07 | #129 | `ADOPTED` | PII等を通常出力と混在させず、永続reportへlocal絶対pathを残さない |
| D7-08 | #129 | `ADOPTED` | 既存artifact・利用者所有fileを黙って上書きしない |
| D7-09 | #130 | `ADOPTED` | Task Fがownership等を確定し、安全不能ならBLOCKEDにする |
| D7-10 | #130 | `ADOPTED` | main worktree outputs案をTask F contract確定前に有効化しない |
| D7-11 | #129、#130 | `ADOPTED` | 一致・検証済みartifactの再利用提案とhash再確認を保持し、lifecycleはTask Fへ渡す |
| D7-12 | #128 | `ADOPTED` | 大容量artifactを会話へ無制限投入せず縮小・問題箇所優先にする |
| D7-13 | #126 | `ADOPTED` | 不足rendererは別setup・人間承認後にだけ導入する |
| D7-14 | #130 | `ADOPTED` | 中間data再取得の費用・非再現性を通知し、外部storageを必須にしない |
| D7-15 | #130 | `ADOPTED` | bash 3.2・CJK/PDF既知不具合を未修正前提で#38へ渡す |
| D7-16 | #121、#128、#130 | `ADOPTED` | #32、Task E、Task Fの後続owner境界を保持する |

#### REJECTED項目

| handoff ID | 状態 | 理由 |
|---|---|---|
| RD-01 | `REJECTED` | PPTを新正本にすると#98・#101と衝突し二重権威になる |
| RD-02 | `REJECTED` | 無条件自動生成は費用・stale・不要artifactを増やす |
| RD-03 | `REJECTED` | 自由生成・判断補完は意味変化と追跡不能を生む |
| RD-04 | `REJECTED` | coverの日時・pathだけではcontentの鮮度・網羅性を証明できない |
| RD-05 | `REJECTED` | 正本全文複製は二重正本・容量・Token問題を生む |
| RD-06 | `REJECTED` | override不具合時のsilent fallbackはbrand・必須情報を誤認させる |
| RD-07 | `REJECTED` | 実行時の外部template自動取得はlicense・供給網・再現性を壊す |
| RD-08 | `REJECTED` | renderer exit 0だけではvisual・semantic欠陥を検出できない |
| RD-09 | `REJECTED` | 自動検査なしの人間丸投げは負荷と再現性を悪化させる |
| RD-10 | `REJECTED` | main worktreeへの無条件出力はownership・並行・PII・lifecycle未解決 |
| RD-11 | `REJECTED` | export中の無承認installはdependency contract違反 |
| RD-12 | `REJECTED` | Drive保存・Git操作の必須化または自動化は#37と非破壊性に反する |

#### Requirements候補・Design保留・未決調査

以下は#131により後続gateへ渡すが、現在のRequirements・Design・実装承認ではない。

| ID | 状態 | owner・反映先 | 内容 |
|---|---|---|---|
| RQ-D-01 | `DEFERRED` | Requirements | 正本・PPT・approvalの権威境界と二段階遷移 |
| RQ-D-02 | `DEFERRED` | Requirements | 明示依頼、既定PPT、phase profile、ambiguity fail-closed |
| RQ-D-03 | `DEFERRED` | Requirements | 制約付き意味変換と禁止された推論 |
| RQ-D-04 | `DEFERRED` | Requirements | source manifest、slide mapping、coverage、freshness/status |
| RQ-D-05 | `DEFERRED` | Requirements | versioned default template、非破壊override、license gate |
| RQ-D-06 | `DEFERRED` | Requirements | 自動品質検査、人間visual QA、fail-closed status |
| RQ-D-07 | `DEFERRED` | Requirements | 複数入口parity、費用preflight、安全な保存境界 |
| RQ-D-08 | `DEFERRED` | Requirements・#32 | 両platformのfresh-session検出・起動・意味parity |
| RQ-D-09 | `DEFERRED` | Requirements・#37 | PII、任意storage、大容量context制約 |
| RQ-D-10 | `DEFERRED` | Requirements・Task E/F | canonicalization確認完了までTask Dを完了扱いしない |
| DD-01 | `DEFERRED` | Design | profile schemaと必須slot・slide構成 |
| DD-02 | `DEFERRED` | Design | manifest・mapping・status schema、hash algorithm、保存形式 |
| DD-03 | `DEFERRED` | Design | template形式・path・override指定・compatibility range |
| DD-04 | `DEFERRED` | Design・Task B | renderer/package/template、pin/lock、license、build・配布方式 |
| DD-05 | `DEFERRED` | Design | visual・semantic検査toolと閾値 |
| DD-06 | `DEFERRED` | Design | visual QA UI、記録schema、warning override範囲 |
| DD-07 | `DEFERRED` | Design・Task F | naming/versioning、atomic publish、cache、retention |
| DD-08 | `DEFERRED` | Design・Task E | 費用見積区分とDEEP・agent budget接続 |
| DD-09 | `DEFERRED` | Design・#32 | platform adapterと自然言語dispatch |
| DD-10 | `DEFERRED` | Design・Task F | output resolver、workspace lease・lock・recovery |
| INV-D-01 | `DEFERRED` | Design・Task F | 現行3 DOCX既定からPPT/profileへのmigration互換性 |
| INV-D-02 | `DEFERRED` | Design | 現行配布物に既定PPTX/POTXがない差分 |
| INV-D-03 | `DEFERRED` | Design | 現行reportにhash・mapping・stale・coverage・REVIEW_READYがない差分 |
| INV-D-04 | `DEFERRED` | Design | 現行品質検査にvisual QAがない差分 |
| INV-D-05 | `DEFERRED` | Design・Task B | 現行の対話中renderer導入経路から無承認dependency変更を排除する調査 |
| INV-D-06 | `DEFERRED` | #38 | bash 3.2、CJK/PDF engine・font問題のOPEN確認 |
| INV-D-07 | `DEFERRED` | Task F・#37 | main worktree output案とsession workspace isolationの整合 |
| INV-D-08 | `DEFERRED` | #37・Task F | #37の旧path/designを未承認・stale前提で再評価 |
| INV-D-09 | `DEFERRED` | Issue #41進捗管理 | Issue本文のstaleなTask C表示をTask D正本化後に更新 |
| INV-D-10 | `DEFERRED` | Task B・Design | 外部asset・rendererのlicense・再配布・supplier・offline再現性 |
| INV-D-11 | `DEFERRED` | Design | 非意味変更時だけ部分freshを許す可否。現状はfile hash変更で全体STALE |
| INV-D-12 | `DEFERRED` | 計測・Requirements review | formal gate visual QA負荷と軽量化目標の実測 |

集計は`ADOPTED 67 / REJECTED 12 / DEFERRED 32 / BLOCKED 0 / 未対応 0`。
送信元照合は`CANONICALIZATION_PASS`。この確認は転記完全性だけを対象とし、fresh独立reviewや
Requirements・Design・Tasksの人間approvalを代替しない。

### Task E — E-1 三つの評価軸の責務確定

> source handoff: `TASK_E_E1_HANDOFF_V1`、handoff ID
> `ISSUE41-TASKE-E1-20261009-01`。受信本文SHA-256
> `3367217a94ead6357f6096f56cbec3849d051acbdcea97f91f781e335eccf7a2`。
> source packet SHA-256
> `bdc7d22bdd92c46365bc1ffc8a6e4fa6a3124c0efd2510119b609a6962d81d9e`。
> E-1だけを対象とし、Task E全体、E-2以降、Requirements、Design、Tasks、実装の完了・承認を意味しない。

#### ADOPTED項目

| handoff ID | 正本対応 | 状態 | 主体・owner | 保持した意味 |
|---|---|---|---|---|
| E1-A01 | #132 | `ADOPTED` | 主agent/orchestrator・Task E | 三軸を別軸・別namespaceとし、文書深度・検証強度・最低能力を混同しない |
| E1-A02 | #132 | `ADOPTED` | 主agent・Task E/Task C | Spec Tierは仕様化・調整複雑性から文書深度・分解粒度を決め、risk・review・modelの直接根拠にしない |
| E1-A03 | #132 | `ADOPTED` | 主agent・Task E | Review Modeはrisk・不確実性・検証可能性・rollback・外部副作用・暗黙契約から独立検証を決める |
| E1-A04 | #132 | `ADOPTED` | 主agent/orchestrator・Task E | Model Classはrole別の必要能力を決め、高riskはreviewer、実装難度はimplementerへ別々に反映する |
| E1-A05 | #133 | `ADOPTED` | 主agent・Task E | 共通証拠からTierとReview Modeを互いの分類値に依存せず判定する |
| E1-A06 | #133 | `ADOPTED` | 主agent/orchestrator・Task E | Review Modeからrole・対象を定めた後にrole別classと実model mappingを確認する |
| E1-A07 | #133 | `ADOPTED` | 主agent/orchestrator・人間・Task E | model不在・予算・期限で必要水準を下げず、実行不能時は停止・scope縮小・人間判断へ戻す |
| E1-A08 | #133 | `ADOPTED` | 主agent・Task E/E-2 | 複雑性自体ではなく、それが生む不確実性・検証困難・暗黙契約等で`DEEP`を判定する |
| E1-A09 | #133 | `ADOPTED` | 主agent/orchestrator・Task E | 強いmodelの使用で必要な独立reviewを省略しない |
| E1-A10 | #134 | `ADOPTED` | 主agent・人間・Task E | 主agentがscope把握後にTierを提案し、人間は既存gate等で確認する。Tier専用gateは作らない |
| E1-A11 | #134 | `ADOPTED` | 主agent・Task E | Review Modeは初期scope把握時と各対象gate直前に判定する |
| E1-A12 | #134 | `ADOPTED` | 人間・Task E/E-2 | 人間は推奨DEEPを拒否できるが必須DEEPをSTANDARDへ上書きせず、実行前の費用・拒否時動作提示を維持する |
| E1-A13 | #134 | `ADOPTED` | 主agent/orchestrator・人間・Task E/E-5 | role・対象確定後にclassを判定しdispatch直前にmappingを検証する。未知代替は人間判断まで停止する |
| E1-A14 | #135 | `ADOPTED` | 主agent・Task E/Task C | Spec Tierはspec単位を基本とする |
| E1-A15 | #135 | `ADOPTED` | 主agent・Task E/E-2/E-3 | Review Modeはgate・review対象・入力hash単位とする |
| E1-A16 | #135 | `ADOPTED` | 主agent/orchestrator・Task E/E-5 | Model Classはrole・作業単位・入力hash単位とする |
| E1-A17 | #136 | `ADOPTED` | 主agent・Task E | scope等の増減でTierを再判定するが、Tier変更だけで他二軸を自動変更しない |
| E1-A18 | #136 | `ADOPTED` | 主agent・Task E/E-2/E-3 | risk等の変更でReview Modeを再判定し、上方変更はreview完了まで停止、下方変更には危険消滅の証拠を求める |
| E1-A19 | #136 | `ADOPTED` | 主agent/orchestrator・Task E/E-5 | role・作業内容・判断量・hash・mapping変更時にclassを再判定する |
| E1-A20 | #136 | `ADOPTED` | 主agent/orchestrator・Task E/E-3/E-5 | review収束中のmodel ID・推論設定変更はreviewer交代としてfresh reviewをやり直す |
| E1-A21 | #137 | `ADOPTED` | 主agent・Task E | 必須事実が未取得なら推測せず`UNRESOLVED`とし、証拠収集以外を停止する |
| E1-A22 | #137 | `ADOPTED` | 主agent・人間・Task E | 証拠が矛盾し優先関係不明なら`BLOCKED`として人間へ戻す |
| E1-A23 | #137 | `ADOPTED` | 主agent・Task E/E-2 | 合理的調査後の対象固有不確実性を未取得情報と区別してReview Mode入力とし、境界はE-2へ渡す |
| E1-A24 | #137 | `ADOPTED` | 主agent/orchestrator・Task E/E-5 | 適格model・mapping不在は実行解決を`BLOCKED`とし必要classを下げない |
| E1-A25 | #137 | `ADOPTED` | 主agent・Task E/Design | 分類値と`RESOLVED / UNRESOLVED / BLOCKED / STALE`を分け、未判定を最大値で埋めない。schemaはDesignへ保留する |
| E1-A26 | #138 | `ADOPTED` | 主agent/orchestrator・Task E/E-5 | 軽量・標準・高度の三段階を維持し、軽量classの名称は暫定、通常判断へ利用範囲を広げない |
| E1-A27 | #138 | `ADOPTED` | task実行者・Task E/E-5 | 旧Mechanicalの判断禁止を`MECHANICAL_ONLY`実行制約へ分離し、機械作業以外の判断を禁止する |
| E1-A28 | #138 | `ADOPTED` | 主agent/orchestrator・task実行者・Task E/E-5 | 上位model代行でも制約を緩めず、制約指定だけで任意modelを適格扱いしない |
| E1-A29 | #139 | `ADOPTED` | 主agent/orchestrator・Task E | 観測事実と軸ごとの影響理由を追跡し、同じ事実を複数軸で使う場合も理由を分ける |
| E1-A30 | #139 | `ADOPTED` | 主agent・Task E | TierはAC・責務・依存・選択・移行・人間判断を証拠とし、量的指標単独で分類しない |
| E1-A31 | #139 | `ADOPTED` | 主agent・Task E/E-2 | Review Modeは影響・失敗・不確実性・検証・rollback・副作用・暗黙契約を証拠とし、Tierや費用等だけで安全判定しない |
| E1-A32 | #139 | `ADOPTED` | 主agent/orchestrator・Task E/E-5 | classはroleの判断・制約統合・曖昧性・反例探索・domain知識・機械検証可能性で判定し、model名等だけで決めない |
| E1-A33 | #139 | `ADOPTED` | 主agent/orchestrator・人間・Task E | 期限・予算は実行計画・scope縮小に使うが、review強度・能力水準を下げる証拠にしない |
| E1-M01 | #140 | `ADOPTED` | Task E/Task C | #77・#78の三軸・namespace分離と同一文書体系内のTier別深度を維持する |
| E1-M02 | #140 | `ADOPTED` | Task E | #79〜#81の目的・安全条件を維持し、E-1の判定順・権限・粒度・状態・証拠・制約分離で改訂する |
| E1-M03 | #140 | `ADOPTED` | Task E/E-2/E-8 | #82・#83の段階的再検証・実例検証を維持し、実例はrevision・証拠確認後にE-2/E-8で扱う |
| E1-M04 | #140 | `ADOPTED` | Task E/E-2/E-3 | #24のTier連動固定reviewを適応型へ改訂し、高risk検証・人間承認を維持、条件・回数はE-2/E-3へ渡す |
| E1-M05 | #140 | `ADOPTED` | Task E/E-3/E-4 | #25〜#29を現行改訂込みで維持し、収束はE-3、agent・dispatchはE-4へ渡し、core/adapter置換・fail-closedを維持する |
| E1-M06 | #140 | `ADOPTED` | Task E/E-5 | #30・#34・#35の三能力水準を維持し、Mechanical禁止判断を実行制約へ分離、上位代行でも制約不変とする |
| E1-M07 | #140 | `ADOPTED` | Task E/E-5 | #31の旧model対応を履歴・候補に留め、現行保証へ流用せず更新可能な両provider mappingへ接続する |
| E1-M08 | #140 | `ADOPTED` | Task E/E-3/E-4/E-5/E-8 | #32・#33・#36〜#39の最低能力・Critical適格性・未知時停止・reviewer変更・証跡・policy所有・総費用評価を維持する |
| E1-M09 | #140 | `ADOPTED` | Task E/E-6 | #93〜#97のcontext予算契約をE-1では変えずE-6で具体化する |
| E1-M10 | #140 | `ADOPTED` | orchestrator/Task E | Decision全体をretireせず、置換部分・維持目的・後続保留を区別する |

#### DEFERRED項目

| handoff ID | 正本対応 | 状態 | 保持した保留内容 |
|---|---|---|---|
| E5-DEFER-01 | #141 | `DEFERRED:E-5` | 両providerのmodel ID・世代・推論設定・role mapping、適格性、更新・代替条件を人間と判断し、現時点で具体modelを認定しない |
| E5-DEFER-02 | #141 | `DEFERRED:E-5` | 代表作業評価は採用するが、工程・fixture・期待結果・合否・実施者・証跡・再評価条件を決め、1件成功を他roleへ外挿しない |
| E5-DEFER-03 | #141 | `DEFERRED:E-5` | 更新契機候補を排除せず、確認・再評価頻度、適用時点、旧mapping条件、範囲、費用、人間判断を決める |
| E1-D01 | #142 | `DEFERRED:Requirements` | 三軸分離、証拠追跡、判定責務・時点・粒度、未判定停止、再分類、最低能力と実行制約分離をRequirements候補にする |
| E1-D02 | #142 | `DEFERRED:人間承認後のDesign` | E-1の意味contractを弱めず、field/schema、hash構成、状態遷移実装、証拠format、軽量class正式名称を人間承認後のDesign工程で扱う |
| E1-D03 | #142 | `DEFERRED:E-2/E-3` | STANDARD/DEEP境界、review範囲・依存、昇降格、巡回・stale・前gate復帰を決める |
| E1-D04 | #142 | `DEFERRED:E-4/E-6/E-7/E-8` | agent topology、context、通知・approval・転記workflow、計測・Issue移行を各論点へ渡す |
| E1-D05 | #142 | `DEFERRED:#39` | #39を独立review実装・状態・証跡・validationへ限定し、旧全gate必須・stale approvalを実装許可にしない |
| E1-D06 | #142 | `DEFERRED:#32/Task F` | skill/helper起動・parity・fresh-session E2Eを所有し、停止中資産を変更せず旧承認を実装許可にしない |
| E1-D07 | #142 | `DEFERRED:#31/E-7/Discovery統合` | #31が通知UXを所有し、通知境界はE-7、最終順序はDiscovery統合で判断する。通知はapprovalを代替せず、旧順序を現行契約へ優先させない |
| E1-D08 | #142 | `DEFERRED:orchestrator/Task E` | Task A〜Dを暗黙改訂せず、衝突・owner変更・新公開contractは人間判断へ戻す |

集計は`ADOPTED 43 / DEFERRED 11 / REJECTED 0 / BLOCKED 0 / 未対応 0`。
送信元sessionは正本SHA-256
`7b739baf433450adbed10d7b7a5a70e48bc722a4616a505a781b6a13700b4c2b`を全54 IDについて逆照合し、
2026-10-09に`CANONICALIZATION_PASS`を返した。このPASSはE-1の転記完全性確認だけを表し、
Task E全体完了、E-2開始、人間approval、fresh独立review、実装許可を代替しない。

### Task E — E-2 Review Modeと壁打ち粒度見直し

> source handoff: `TASK_E_E2_HANDOFF_V1`、handoff ID
> `ISSUE41-TASKE-E2-20261125-01`。受信本文SHA-256
> `f86c0a621d6dc4ee025e101763776477d662d192fc620ccb056a506186123f99`。
> 基準正本SHA-256
> `0f4e0e25f20e8ca790c4d648ada36a953b311427828eeaa320cdd58161da792c`。
> 35 IDは転記完全性の内部表現であり、人間への35回の採否質問または35個の利用者手順ではない。
> E-2と壁打ち方法だけを対象とし、Task E全体、Requirements、Design、Tasks、実装の完了・承認を意味しない。

#### ADOPTED項目

| handoff ID | 正本対応 | 状態・owner | 保持した意味 |
|---|---|---|---|
| E2-A01 | #143 | `ADOPTED:Task E` | 主agentは基本事実の不足・矛盾を先に処理し、必須・推奨・STANDARDの順で判定する。未取得はUNRESOLVED、解消不能な矛盾はBLOCKEDとし、推測・相殺を禁止する |
| E2-A02 | #143 | `ADOPTED:Task E` | 領域名ではなく列挙した対象領域の保護対象・振る舞い・境界・安全保証への実変更で昇格判定する |
| E2-A03 | #143 | `ADOPTED:Task E` | 対策・backup・test PASSだけで該当を消さず、影響確認と検証済み根拠で非該当を判断する |
| E2-A04 | #143 | `ADOPTED:Task E` | 公開契約追加の例外はconsumer/範囲、既存意味不変、他必須条件非該当、撤回後の契約/data維持の全証拠を要求し、STANDARD自動確定・新contract承認gate省略を認めない |
| E2-A05 | #143 | `ADOPTED:Task E` | 合理的調査の説明項目をagent責務として保持し、時間・file数や人間への定型入力で代用しない |
| E2-A06 | #143 | `ADOPTED:Task E` | 調査後も具体的な安全上の失敗経路を通常検証で否定・影響限定できなければDEEP_REQUIREDとし、想像だけで必須化しない |
| E2-A07 | #143 | `ADOPTED:Task E` | 必須非該当で影響限定根拠と独立確認論点があれば推奨、通常確認可能で追加理由がなければSTANDARDとし、許容条件をagentが捏造しない |
| E2-A08 | #143 | `ADOPTED:Task E/E-3` | test・証拠不足・未達ACをModeで合格にせず、reviewerが必要情報へアクセス不能なら停止・未解決を維持する |
| E2-A09 | #143 | `ADOPTED:Task E` | task分割ではなく変更間相互作用を含む失敗経路で判定し、旧Q8詳細全体や追加点数表・承認手続きは採用しない |
| E2-A10 | #144 | `ADOPTED:Task E` | 人間は推奨DEEPを拒否してSTANDARDを選べるが、判定を書き換えず理由・拒否・残論点を記録し必須検証を維持する |
| E2-A11 | #144 | `ADOPTED:Task E` | 必須DEEP拒否・不能時は必要水準を維持して依存gate・対象作業を停止し、延期・scope縮小・中止へ戻す。同一context等で代替せず非依存作業まで一律停止しない |
| E2-A12 | #144 | `ADOPTED:Task E` | 無応答・時間経過・一般的肯定を承認にせず、scope縮小後も対象・hash・副作用と必要承認を再評価する |
| E2-A13 | #145 | `ADOPTED:Task E、具体値=E-3/E-6` | DEEP前に根拠、対象/hash、role/agent/class、context/機密/送信、巡回・Token・時間上限、不能・拒否時動作を含む計画を承認対象とし、取得不能値をUNAVAILABLEとする |
| E2-A14 | #145 | `ADOPTED:Task E` | 作成前成果物では基準hash付き実行計画を承認し、実入力hashを実行前検証する。既存phase承認へ明示包含できるが、将来内容・review後成果物の承認を代替しない |
| E2-A15 | #145 | `ADOPTED:Task E/E-3` | 計画内の通常修正・再確認で費用承認を繰り返さず、input freshness・再分類とreview結果の有効性は別に確認する |
| E2-A16 | #145 | `ADOPTED:Task E` | scope、agent数、context、外部送信、費用・時間等の実質拡張は実行前再承認とし、上限到達時は未解決事項・追加見積を示して人間へ戻し黙って巡回しない |
| E2-A17 | #145 | `ADOPTED:Task E` | STANDARDから推奨への変更は理由・計画を示し、拒否時は推奨拒否規則へ戻す。必須への変更では依存gate・対象作業を停止してreview完了後に再開する |
| E2-A18 | #145 | `ADOPTED:Task E` | Mode下方変更には危険条件または推奨理由の消滅証拠と他必須条件確認を要求し、test PASS・review済み・費用・納期だけを根拠にしない |
| E2-A19 | #145 | `ADOPTED:Task E` | Mode・hash・新事実・影響・再開条件をagentが追跡し、人間へ細則ごとの採否を要求しない |
| E2-A20 | #145 | `ADOPTED:Task E/E-3` | requirements/design前提崩れはDEEP追加だけで続けず該当前段gateへ戻し、鮮度・再review詳細は統合実行方針へ渡す |
| E2-P01 | #146 | `ADOPTED:Task E/Discovery運用` | 細則質問をやめ、安全境界・費用/権限trade-off・既存合意変更をdecision packageで示し、通常詳細はagentが例・反例とともに整理する |
| E2-P02 | #146 | `ADOPTED:Task E` | 採用済み意味を維持しつつ共通原則へ統合し、細則自体の必要性を点検して意味統合・後段保留・改訂候補を分ける |
| E2-P03 | #146 | `ADOPTED:Task E/Task C` | 原子的handoff IDを内部の転記完全性表現とし、人間の原子的承認義務にせず、新trade-off・意味変更だけ人間へ戻す |
| E2-M01 | #147 | `ADOPTED:Task E` | #6・#8の安全目的を維持し、実影響判定と公開契約追加の条件付き例外で改訂する |
| E2-M02 | #147 | `ADOPTED:Task E` | #9のproduction AI原則高riskと既存隔離read-only例外を維持し、新例外・具体modelを採用しない |
| E2-M03 | #147 | `ADOPTED:Task E` | #10の目的を維持し公開契約例外の証拠条件と相互作用評価へ接続し、件数だけで昇格しない |
| E2-M04 | #147 | `ADOPTED:Task E` | #11を未取得UNRESOLVEDと調査後の残存不確実性へ分けるよう改訂する |
| E2-M05 | #147 | `ADOPTED:Task E` | #79・#80・#134・#136・#137を維持して三方針で具体化し、E-1 #132〜#142を弱めない |
| E2-M06 | #147 | `ADOPTED:Task E、具体化=統合実行方針` | #24・#25・#30〜#39・#93〜#97を既存改訂込みで維持し、回数・agent数・Token閾値・model IDを新規固定しない |
| E2-M07 | #147 | `ADOPTED:Task C/E/F` | #117〜#119の原子的対応・hash・source確認・PASSまでfail-closedを維持し、人間の壁打ち粒度と分離する |

#### DEFERRED項目

| handoff ID | 正本対応 | 状態・owner | 保持した保留内容 |
|---|---|---|---|
| E2-D01 | #148 | `DEFERRED:E-3〜E-7` | review・agent・model・context・通知等を一体の実行方針案にし、coverageを独立承認gate数にせず固定承認回数を増やさない |
| E2-D02 | #148 | `DEFERRED:E-8` | hard safety、効率、Issue再利用・stale・owner、代表case・段階導入を検証・移行方針にし、計測field・fixtureごとの人間採否を求めない |
| E2-D03 | #148 | `DEFERRED:E-5/統合実行方針` | 両provider mapping、role別代表作業評価、正式適用、更新頻度・契機を扱い、人間の更新依頼等を事前排除せず、具体modelを未検証認定しない |
| E2-D04 | #148 | `DEFERRED:Requirements/人間承認後のDesign` | 三方針と負担削減をRequirements候補とし、schema/UI/event/context/計測/fixture詳細をDesignへ送り、DQ PR前にRequirements生成しない |
| E2-D05 | #148 | `DEFERRED:E-8` | 仮想例は机上確認のみで実運用指標は未計測。cyclox2指定branchは前回local調査でref不在と報告された未検証事項として保持し、確認済み事実として引用しない |

集計は`ADOPTED 30 / DEFERRED 5 / REJECTED 0 / BLOCKED 0 / 未対応 0`。
送信元sessionは正本SHA-256
`a7d6f67bd547a69cb0ad0856f875975dd7160d44f0da77b4c9bbdaf65512d3d3`を全35 IDについて逆照合し、
2026-11-25に`CANONICALIZATION_PASS`を返した。このPASSはE-2と壁打ち方法の転記完全性確認だけを表し、
Task E全体完了、統合実行方針の採用、Requirements・Design・Tasks、人間approval、実装許可を代替しない。

### Task E — E-3〜E-8統合実行・検証・移行方針

> source handoff: `TASK_E_FINAL_POLICY_HANDOFF_V1`、handoff ID
> `ISSUE41-TASKE-FINAL-20261125-01`。受信本文SHA-256
> `758739fa8e4618a417b86d62650bd0a53ba90adaea7a2b63442e1031f16c7d23`。
> 基準正本SHA-256
> `1d778bd8dfc5c762b6a180b5f32516780d96d6c1b46a56d132f1401bbef6502f`。
> TE-A01〜TE-A11は統合実行方針・更新方式Bへの人間の個別採用、TE-R01〜TE-R08は
> 「ここから先は基本的に推奨案を採用する」という包括方針に基づくE-8推奨採用である。
> 包括採用を実装、外部依存導入、未評価model適用、Issue更新、commit、push、PR、
> Requirements・Design・Tasks生成の許可へ広げない。

#### ADOPTED項目

| handoff ID | 正本対応 | 状態・owner | 保持した意味 |
|---|---|---|---|
| TE-A01 | #149 | `ADOPTED:Task E/#39` | STANDARDは主agent、DEEPは適格なfresh独立reviewerとし、独立性・人数・収束上限、計画内修正で承認を繰り返さない条件を維持 |
| TE-A02 | #149 | `ADOPTED:Task E` | 主agentが調整と通常作業を兼任し、通常1 active subagent、累計上限なし、並列例外は費用・分担を示した人間承認とする |
| TE-A03 | #150 | `ADOPTED:Task E/E-5` | 両providerをrole別に評価し、model名等でclassを決めず、三能力水準・MECHANICAL_ONLY・Critical下限・未知時停止を維持 |
| TE-A04 | #150 | `ADOPTED:Task E、具体化=Design/検証` | 初回・未評価構成の正式適用前にrole代表作業で評価し、例を固定fixture一覧にせず詳細を後段化 |
| TE-A05 | #150 | `ADOPTED:Task E/Task F adapter` | 毎taskで評価を繰り返さず利用条件と登録済み適格構成を確認し、未確認を既評価扱いしない |
| TE-A06 | #150 | `ADOPTED:Task E/E-5` | 更新方式Bとして人間依頼を受け付け、観測可能な変更・品質変化から再評価を提案し、定期評価を常時既定にしない |
| TE-A07 | #150 | `ADOPTED:Task E/Task F` | 観測不能を変更なしにせず、未評価model・provider越え代替・review中変更を自動承認しない |
| TE-A08 | #150 | `ADOPTED:Task E/将来運用` | 定期再評価を排除せず、必要性と費用が判明した時点で判断し、周期・schedule・model IDを未確定に保つ |
| TE-A09 | #151 | `ADOPTED:Task E、storage/lifecycle=Task F` | 正本参照・role別最小情報・工程区切りの引継ぎ・早期compactを使い、固定Token閾値を設けず既存context契約を維持 |
| TE-A10 | #149 | `ADOPTED:#31/Task E、起動parity=#32/Task F` | 利用者向け通知を親agentへ集約し、通知・review完了・正本化待ちをapprovalや完了へ丸めない |
| TE-A11 | #151 | `ADOPTED:人間承認後のDesign` | schema・event・具体設定/model IDを後段へ保留し、方針採用をmapping登録・評価合格・実装成功にしない |
| TE-R01 | #152 | `ADOPTED:Task E/E-8` | B0互換、B1比較方式、C候補を分け、B1をcurrent policyへ復活させない |
| TE-R02 | #152 | `ADOPTED:Task E/E-8` | 三代表caseをgolden manifest付きで検証し、Tier理由の固定reviewと仮想例の実証扱いを禁止 |
| TE-R03 | #152 | `ADOPTED:Task E/正式受入` | #58 hard safetyを独立条件として維持し、効率・fixture合格で欠陥を相殺・一般化しない |
| TE-R04 | #153 | `ADOPTED:Task E/E-8` | 同一platformのB1対Cで複数指標を測り、取得不能をUNAVAILABLE、provider間生Tokenだけの改善宣言を禁止 |
| TE-R05 | #153 | `ADOPTED:Task E/E-8/正式review` | Codex先行hard safety後にClaude同条件を検証し、片側成功をparityにせず、削減率を再検証前の保証値にしない |
| TE-R06 | #154 | `ADOPTED:Discovery統合/#39/#32/#31` | #39、#32、#31のownerを維持し、旧承認・停止資産・旧順序を新contract実装許可へ流用しない |
| TE-R07 | #154 | `ADOPTED:Discovery統合/Task F/移行` | A〜F統合後に順序を確定し、共通policyと両adapterが揃うまでactive化せず、gate境界評価・無断fallback禁止を維持 |
| TE-R08 | #154 | `ADOPTED:Discovery統合` | 未Decision Issueを並列起動せずDiscovery後に分類し、今回の採用から実装・GitHub操作を推定しない |

#### DEFERRED項目

| handoff ID | 正本対応 | 状態・owner | 保持した保留内容 |
|---|---|---|---|
| TE-D01 | #155、#156〜#161 | `DEFERRED:Task F/#32/#39/Design` | ownership、二種lock、lifecycle、adapter/E2E、state/output保存・具体方式を該当ownerへ渡し、Task E意味contractをcore/adapterで実装、不能時fail-closed |
| TE-D02 | #155、#161 | `DEFERRED:Requirements/Design/検証` | role評価・実model・context API/閾値・通知schema・試験code/環境を後段化し、正式適用前評価という方針は維持 |
| TE-D03 | #155 | `DEFERRED:Discovery統合/Task F` | 先行Task・旧Decisionの安全目的とownerを維持し、並列承認・上限・能力下限・人間approval・非破壊・転記完全性を緩和しない |

集計は`ADOPTED 19 / DEFERRED 3 / REJECTED 0 / BLOCKED 0 / 未対応 0`。
送信元sessionは正本SHA-256
`db2b728d8a853f50543ef57d110833f30e9e89f9d8dee6d0bd792cbcd20cc449`を全22 IDについて逆照合し、
2026-11-25に`CANONICALIZATION_PASS`を返した。これによりTask E Discovery方針とsource転記確認は完了した。
このPASSはTask F本体、A〜F全体統合の独立review、正式phase承認、実装、parity実証を代替しない。

### Task F — Workspace・lifecycle・migration・parityの統合方針

Task F本体の#156〜#161はorchestratorが単一sessionで作成した推奨方針であり、#119を無条件に
適用して別session確認を必須化しない。一方、次の5項目はTask E source sessionから渡された
E/F境界のhandoffであるため、項目単位の転記確認対象とする。

> source handoff: `TASK_F_BOUNDARY_RECOMMENDATIONS_V1`、handoff ID
> `ISSUE41-TASKF-BOUNDARY-20261125-01`。受信本文SHA-256
> `d1fa58d154cd6c82750870a53f7889b180b3758b1e573748afd5a66c5f157e92`。

| handoff ID | 正本対応 | 状態・owner | 保持した意味 |
|---|---|---|---|
| F-X01 | #156、#158 | `ADOPTED:Task E/#39/Task F` | review agentも所有・operation lockを迂回せず、resume時に入力hash・Workspace・revision・dirty状態を照合し、read-onlyを変更許可やstale review有効化へ使わない |
| F-X02 | #150、#156 | `ADOPTED:Task E/Task F` | model/provider変更による別Workspace、外部送信先・範囲の無断変更を禁止し、未知代替停止、人間承認、機密保護を維持 |
| F-X03 | #158 | `ADOPTED:#31/Task E/Task F` | 停止・未検証・復旧中・pending-canonicalizationを完了へ丸めず、source確認前のagent正常closeを禁止するが、人間の物理終了を禁止せず再開参照を保持 |
| F-X04 | #160 | `ADOPTED:#32/Task F、policy=Task E` | 明示起動だけでなく自然言語、直接skill・subagent経由、fresh-session E2E、doc-export直接CLIをparity範囲に戻し、releaseで両platformを検証 |
| F-X05 | #159 | `ADOPTED:Task F/#30` | 無関係なGit・dirty変更・利用者資産・証跡を破壊せず管理対象差分を安全に戻せるrollbackとし、全管理対象の復帰禁止へ拡張しない |

集計は`ADOPTED 5 / DEFERRED 0 / REJECTED 0 / BLOCKED 0 / 未対応 0`。
送信元sessionは正本SHA-256
`db2b728d8a853f50543ef57d110833f30e9e89f9d8dee6d0bd792cbcd20cc449`をF-X01〜F-X05について逆照合し、
2026-11-25に`CANONICALIZATION_PASS`を返した。Task F本体は保証境界・責務・停止/復旧原則を
#156〜#161へ統合したが、具体Design、実装、実機E2E、parity、migration、効率改善は未完了である。
送信元sessionの役割はTask EとE/F境界の照合完了をもって終了し、今後の参加・再起動をTask F本体または
A〜F全体統合の完了条件にしない。Task F本体およびTask A〜F全体の統合はorchestratorが所有する。
既存Decisionと#149〜#161の横断確認では未解消の意味衝突・owner欠落を認めなかったが、
この確認は後続のfresh独立reviewや人間承認を代替しない。

### 次回からの確認手順

1. 専用sessionはhandoffを原子的なID付き項目として返す。複数の主体・条件・例外を一項目へ隠さない。
2. orchestratorは文章を要約する前に、各IDへDecision、後続owner、却下理由、またはblockerを割り当てる。
3. 次の意味要素を別々に照合する: `主体 / MUST・禁止等の規範強度 / 条件 / 例外 / 否定 / 固定値 / 後続owner / 未決状態`。
4. 正本だけを読んでhandoffの判断を逆向きに再構成し、元handoffとの差を確認する。履歴資料への参照だけでは合格にしない。
5. handoff ID総数、対応済み数、未対応数を示し、未対応が0件になるまでTask完了・次Task開始・PR承認依頼を行わない。
6. Requirements化前のCritical fresh reviewでは、この表とTask D〜Fの同形式表を入力に含め、丸め込みによる意味欠落を反例ベースで再確認する。
7. orchestratorは正本反映後、handoff IDごとの反映先、正本文、統合・言換え・保留・未反映を壁打ちsessionへ返す。
8. 壁打ちsessionは元handoffと照合し、欠落・意味変更がなければ`CANONICALIZATION_PASS`、あれば`CANONICALIZATION_REVISE`と修正対象を返す。
9. `CANONICALIZATION_PASS`前に壁打ちsessionを終了・archiveせず、Task完了、次Task開始、PR承認依頼を行わない。
10. この送信元確認は転記の完全性を検査するものであり、設計妥当性を評価するfresh独立reviewや人間承認を置き換えない。

この表は、正本と同じ文章をもう一つ作るためのものではない。handoffの各判断が正本または明示的な
保留先へ到達したことを検査する、Issue #41 Serial Discovery用の監査索引である。#119の製品機能は、
この原則をsession・agent境界を越える正本化へ一般化するが、通常specへ同じ監査表fileの作成を強制しない。

---

### 旧Decisionの改訂関係

| 旧Decision | 現在の扱い |
|---|---|
| #14 | command・標準成果物・phase・approval metadataを外部互換contractとして維持する部分は継続する。「独自forkによるupgrade負荷を避ける」という旧理由は#84で撤回し、継続同期を持たない一方向forkへ改訂する |
| #15 | 影響評価と人間承認を必要とする安全条件は維持する。独自変更をoverlayだけで実現する方式の固定は撤回し、#86の5層へ改訂する |
| #16 | 正本文書の一意な責務とID参照は維持し、#98でresearch、runbook、steering、二次成果物まで責務境界を拡張する。context packetとhandoffは標準文書へ追加せず、Issue #41の派生資料として分離する |
| #21・#22 | manual checklistの条件付き必須と人間実施は維持する。Design承認時に要否を決め、必要ならTasks承認前に計画し、実装後に人間が結果を記録するlifecycleをTask Cで確定した。現行workflow/templateとの差は未解消として後続へ渡す |
| #29 | fail-closedとlocal harness contract優先は維持する。`kiro-impl`の衝突をoverlayでのみ置換する方式は撤回し、#149・#155の実行意味contractをcoreまたはadapterで明示的に置換する。具体実装はDesignへ渡す |
| #61〜#66 | 旧Issue順は履歴として保持する。#154によりTask A〜F統合後の依存・競合・受入条件から実装対象・順序を再分類し、critical衝突は自動上書きしない |
| #24 | Tier Lへ固定的にfresh review回数を割り当てる方式を#143〜#145の適応型Review Modeへ改訂し、高risk reviewと人間承認を弱めない目的を維持する |
| #25 | risk boundary checkpoint、gateごと1 reviewer、同一reviewer最大10巡を#149で維持し、DEEP事前承認、計画内修正の自律進行、実質拡張時の再承認を#145で具体化する |
| #30〜#39・#141 | provider中立の能力水準、Critical非降格、未知時停止、role別証跡、総Token・費用・手戻り評価を維持し、具体modelの旧候補を現行保証へ使わず、#150の更新方式Bへ改訂する |
| #42・#44 | navigationの構成は維持し、#101で自然言語approvalの成立条件を一つのpending gate、対象文書、version/hash、許可範囲の明示へ具体化する |
| #50・#51 | 日本語既定、EARS互換、検証可能性は維持する。#103で対象の一意性を最優先とし、禁止語やID反復を具体性の代用にしないよう補正する |
| #65 | 意味上の衝突に加え、対象hashの変更でも依存review・approvalをstaleにする。非意味変更の具体判定はDesignへ保留する |
| #95 | 正本参照型を維持し、#104〜#106で未固定の最小差分、pending-canonicalization、workspace参照、機密情報除外を追加する。storage・lifecycleの保証境界は#156〜#161、具体方式はDesignへ渡す |
| #55〜#60 | B0/B1/C、三代表case、hard safety、効率の多面的計測、段階的両platform検証を#152・#153へ統合する。削減率は再検証前の保証値にしない |
| #74・#75・#86・#91・#112・#115 | in-place bridge、同一state、五層architecture、利用者所有資産の非破壊、旧入口維持条件を#156〜#161でWorkspace所有、lifecycle、rollback、parityの観測可能な保証へ具体化する |
| #104〜#106 | checkpointの正本参照、未固定差分、Workspace参照、機密除外を維持し、#156〜#158で所有・resume・close・recoveryを追加する。checkpointだけで分離済みとはみなさない |
| #119 | session・agent境界を越えるhandoffはsource逆照合を維持する。orchestrator単一sessionが直接作成するTask F本文へ無条件に拡張せず、今回境界を越えたF-X01〜F-X05だけを項目確認する |
| #130 | main worktree側outputsは所有者、resolver、Lease、operation lock、preflight、recoveryがDesign・実装・検証されるまで有効化しない |

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

## 後続工程へ渡す事項

| 順番 | 検討事項 | 決める内容 |
|---|---|---|
| 1 | 正本文書の責務と最小構成 | 合意済み。具体的なformat、ID表現、意味的validatorはrequirements承認後のdesignで決める |
| 2 | agent構成と独立review gate | 合意済み。context envelopeの具体field、gate hash、kiro-impl patch方式はrequirements承認後のdesignで決める |
| 3 | model routing | 合意済み。具体的な対応表、能力tag、推論profile、実行時検証のformatはrequirements承認後のdesignで決める |
| 4 | 人間review guideと出力表現 | 合意済み。適用範囲、日本語既定・例外、抽象語判定、EARS、文体、finding formatをrequirementsと独立reviewの対象にする |
| 5 | 計測・比較と受入判定 | 合意済み。`B0 / B1 / C`、3代表case、hard safety、効率目標、再計測と例外条件をrequirementsと独立reviewの対象にする |
| 6 | 移行・parity・Issue依存 | 方針合意済み。全open Issue、gate境界移行、`#41`の既定優先、critical衝突時の停止、共通policyと両adapterが揃った後のactivationをrequirementsへ反映する |
| 7 | Workspace・session lifecycle | 方針合意済み。単一owner、LeaseとOperation Lock、resume・close・recovery、Legacy Bridge、rollback、Claude/Codex E2Eをrequirementsへ反映し、方式はdesign、達成可否は実機検証で決める |

### 次回の再開点

PR #46はmerge済み。Discovery改訂Task A「Kiro互換・製品境界」、Task B「cc-sdd source取り込み・
provenance・外部source更新境界」、Task C「正本・文書責務・日本語・追跡可能性」、
Task D「doc-export・二次成果物」は完了済み。Task EはE-1を#132〜#142、E-2を#143〜#148、
統合実行・検証・移行方針を#149〜#155へ正本化した。Task FのWorkspace ownership、Lease・Operation Lock、
resume・close・recovery、Legacy Bridge・rollback、Claude/Codex parityは#156〜#161へ正本化した。
送信元sessionはTask E最終22 IDとTask F境界5 IDへ`CANONICALIZATION_PASS`を返し、役割を終了した。
次はorchestratorがDiscovery方針全体の人間向け仕様を提示し、必要な修正がなければcommit・DQ PRの区切りを提案する。
これは保証境界と方針の確定であり、具体Design・実装・実測の完了ではない。
Task A〜Fを統合したDiscovery DQ PRがmergeされるまで`requirements.md`生成へ進まない。

---

## フェーズゲート承認記録

> 承認状態の正本は`.kiro/specs/sdd-harness-lightweight/spec.json`。
> 現在は初期化済み・全フェーズ未承認。

| フェーズ | 合意メモ（理由・補足） |
|---|---|
| 要件定義（requirements.md） | Discovery改訂Task A〜Fの方針を#67〜#161へ正本化し、Task E最終handoff・Task F境界はsource逆照合PASS。A〜F統合はorchestrator所有で、具体Design・実装・実測は未着手。Requirementsは未生成・未承認。 |
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
| 2026-09-05 | Task AでKiro互換保証、独立製品表示、名称・状態のin-place移行contractを合意。skill件数を全`kiro-*`17個とSDD Rig固有`doc-export`へ補正 | KYamada / Codex |
| 2026-09-06 | Spec Tier・Review Mode・Model Classの三軸分離、適応型`DEEP`判定、実行前人間承認、段階的再検証をTask Eへの採用済みbaselineとして合意 | KYamada / Codex |
| 2026-09-06 | Task Bで一方向fork、初期source・provenance、5層architecture、license・配布、将来の外部source採用gate、非破壊sync、Issue責務を合意 | KYamada / Codex |
| 2026-09-06 | Claude Code実測artifactを基に、計画的session分割・早期compact・任意上限、正本参照型checkpoint、semantic parity、local telemetryをTask C/E/F共通baselineとして合意 | KYamada / Codex |
| 2026-09-21 | Task Cで一情報一正本、stable ID・stale判定、人間review navigation、自然言語approval、共通8観点、日本語・EARS、session checkpoint・workspace参照、製品表示、Tier別深度を合意 | KYamada / Codex |
| 2026-09-21 | Task A〜Cのhandoff正本化を水平監査し、丸め込みで弱まった役割・例外・停止条件・後続owner・未決事項を#110〜#116へ復帰。#117の項目別カバレッジ確認を後続Taskへ導入 | KYamada / Codex |
| 2026-09-21 | #118として、正本反映後に壁打ちsessionが元handoffとの一致を確認し、`CANONICALIZATION_PASS`まで存続する二段階の正本化確認を採用 | KYamada / Codex |
| 2026-09-21 | #119として、二段階確認をSDD Rigの転記完全性確認機能へ昇格し、Task C/E/Fを横断するRequirements候補として採用 | KYamada / Codex |
| 2026-10-08 | Task DでPPTの非正本境界、明示生成、意味変換、出典・鮮度、template override、品質検査、保存・費用・後続ownerを合意。#120〜#131と全111 IDを正本化し、送信元sessionが`CANONICALIZATION_PASS`を確認 | KYamada / Codex |
| 2026-10-09 | Task E E-1でSpec Tier・Review Mode・Model Classの責務、判定順、適用単位、再分類、状態、能力制約、証拠、旧Decision関係、後続ownerを合意。#132〜#142と全54 IDを正本化し、送信元sessionが`CANONICALIZATION_PASS`を確認 | KYamada / Codex |
| 2026-11-25 | Task E E-2でReview Modeを影響と証拠、人間選択、承認範囲の三方針へ統合し、task分割による判定逃れ防止とdecision package単位の壁打ちへ見直した。#143〜#148と全35 IDを正本化し、送信元sessionが`CANONICALIZATION_PASS`を確認 | KYamada / Codex |
| 2026-11-25 | Task Eのreview・agent・model・context・通知とE-8検証移行を#149〜#155、Task FのWorkspace所有・排他・lifecycle・bridge・rollback・parityを#156〜#161へ統合。A〜F統合はorchestrator所有とし、Task E最終22 IDとTask F境界5 IDだけを送信元sessionの逆照合対象とした | KYamada / Codex |
| 2026-11-25 | 送信元sessionがTask E最終22 IDとTask F境界5 IDを27/27・未対応0で逆照合し、`CANONICALIZATION_PASS`を返却。Task E専用sessionの役割を終了し、Task F本体とA〜F全体統合をorchestratorへ戻した | KYamada / Codex |
