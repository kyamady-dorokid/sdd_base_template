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

---

## 却下・保留事項

| 内容 | 理由 |
|---|---|
| 3設計軸を開始時点で別Issueへ分割する | 責務境界と依存順が未確定のため保留 |
| 制限コンテキスト自己レビューをfresh独立レビューの代替にする | 独立性を技術的に証明できないため、現時点では採用しない |
| Issue #39の独立レビュー契約を本specから暗黙に変更する | 既存の承認事項であり、影響と移行順を明示して別途人間承認が必要 |
| Tier Sという理由だけで高リスク変更の独立レビューを省略する | 作業量と障害影響は一致しないため却下 |
| subagent累計起動数をToken上限として固定する | agent数よりcontext量・重複率の影響が大きく、必要なfresh reviewやdebugを不合理に妨げるため却下 |
| SDD標準出力文書とAI独立review結果の具体的記述基準・日本語化範囲 | 後続の壁打ちで、requirements・design・tasks等を含む対象文書、抽象語・暗黙の前提の排除、必要な固有名・system名・EARSトリガーキーワード等の例外を決定する |
| Issue #39を独立したpolicy specのまま維持する | #41とreview適用gate、model、agent構成、Token方針が重複・矛盾するため、#41配下の子実装Issueへ再編する |

---

## 未決事項と検討順

| 順番 | 検討事項 | 決める内容 |
|---|---|---|
| 1 | 正本文書の責務と最小構成 | 合意済み。具体的なformat、ID表現、意味的validatorはrequirements承認後のdesignで決める |
| 2 | agent構成と独立review gate | 合意済み。context envelopeの具体field、gate hash、kiro-impl patch方式はrequirements承認後のdesignで決める |
| 3 | model routing | 合意済み。具体的な対応表、能力tag、推論profile、実行時検証のformatはrequirements承認後のdesignで決める |
| 4 | 人間review guideと出力表現 | gate別確認観点、正本へのnavigation、差分・影響範囲、前工程へ戻す条件を決める。SDD標準出力文書とAI独立review結果は、抽象語・暗黙の前提を避け、例外を除いて日本語で具体的に記述する基準を決める |
| 5 | 計測・比較と受入判定 | 代表taskを選び、Token、時間、文書量、重複率、人間review時間、traceability、欠陥検出率を現行方式と比較する方法を決める |
| 6 | 移行・parity・Issue依存 | Claude Code/Codex双方への同一反映、既存specの扱い、Issue #39・#32・#37との変更順と受入条件を決める |

### 次回の再開点

順番4「人間review guideと出力表現」から開始する。gate別に人間が確認する正本・判断事項・整合性、
navigationの提示順、前工程へ戻す条件、SDD標準文書とAI独立review結果の日本語・具体的記述基準を決定する。

---

## フェーズゲート承認記録

> 承認状態の正本は`.kiro/specs/sdd-harness-lightweight/spec.json`。
> 現在は初期化済み・全フェーズ未承認。

| フェーズ | 合意メモ（理由・補足） |
|---|---|
| 要件定義（requirements.md） | 未生成・未承認。まず不変条件、リスク分類、比較案を壁打ちする。 |
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
