# Task C handoff: 正本文書・人間review・日本語・追跡可能性

> 完了日: 2026-09-21
> 状態: 人間同意済み。orchestratorによるTask A・B、関連Issue、workspace分離とのcross-check済み。
> 境界: 本文書はDiscovery Decisionであり、`requirements.md`、`design.md`、`tasks.md`の生成・承認、
> 実装許可を意味しない。

## 1. 一情報一正本と文書責務

標準file構成とapproval gateは維持し、同じ情報を複数文書で正本化しない。下流文書は上流の
stable IDまたは節を参照し、本文を再掲しない。

| 文書・成果物 | 固有責務 |
|---|---|
| `brief.md` | discovery段階の問題、背景、価値、初期仮説、現在位置 |
| `requirements.md` | 利用者が必要とする結果、acceptance criteria、対象外、制約、risk |
| `design.md` | 実現方式、構成、公開契約、data、security、障害時動作、rollback、test方針 |
| `tasks.md` | 実装順序、依存関係、TDD単位、観測可能な完了条件 |
| `agreement-log.md` | 人間の判断、理由、却下案、保留事項、旧Decisionの改訂関係 |
| `spec.json` | phase、approval、Tier等の機械状態。長文の判断理由は持たない |
| `research.md`等 | 調査方法、比較、外部根拠、候補、詳細。現在のcontractは所有しない |
| `test-results.md` | 実行command、環境、revision、RED/GREEN、実結果、失敗・skip・未検証 |
| `integration-test-checklist.md` | 人間操作・判断、外部環境、運用確認の事前計画と実施結果 |
| runbook・運用手順 | 運用時の手順、観測、停止条件、復旧。要件・設計理由は参照する |
| steering・roadmap | project全体の前提、構造、横断方針、依存順。個別spec contractは持たない |
| context packet / handoff | 次工程に必要な入力境界とDecision参照。approvalの正本にはしない |
| review navigation | 承認対象への案内。正本文書の代替要約にはしない |
| PDF / Word / PPT等 | 人間向け派生view。一次成果物から一方向に生成し、正本にしない |

現在の正本文書は、現在contractを反映するため更新できる。ただし、過去のDecision、review、approval、
test evidenceへ到達できる状態を壊さない。`FAIL`から`PASS`へ現在summaryを更新してよいが、過去の
`FAIL`実行、対象version、証拠は追跡可能に保つ。非currentな記録を自動削除・移動しない。

## 2. stable ID、version、意味変更

- 同じ判断対象の誤字修正、条件補足、見出し・section移動ではIDを維持し、versionまたは対象hashを変える。
- 一つの項目を複数の独立項目へ分割、複数項目を統合、意味の異なる項目へ置換する場合は新しいIDを付ける。
- 廃止IDは再利用せず、後継IDまたは廃止理由へ到達可能にする。
- Kiro互換の数値requirement IDを維持する。すべての段落へIDを強制しない。
- `AMENDS / SUPERSEDES / RETIRES`等の概念は採用するが、field名とschemaはDesignで決める。
- 変更影響を受ける下流参照は`UPDATE / CONFIRM_UNCHANGED / RETIRE / BLOCKED`のいずれかで閉じる。
- 現在状態への参照と、過去の特定version・hashへの固定参照を区別する。
- schema、ID重複、参照切れ、hash不一致は機械検査し、意味的一致はreviewで検査する。

対象の意味または対象hashが変わった場合、その対象に依存するreviewとapprovalはstaleとし、正しいgateへ戻って
fresh reviewと再approvalを行う。表記修正など非意味変更の判定規則はDesignで定義し、Discovery時点で
自動判定方法を固定しない。

## 3. 人間review guide、navigation、自然言語approval

個別specごとの人間向けreview文書は作らない。全spec共通の恒久review guideと、各gateで正本を直接開くための
動的navigationを組み合わせる。navigationは対象phase、spec、versionまたはhash、人間が判断する事項、
正本file・section・ID、前工程からの意味変更、review・検証状態、risk・例外、選択可能な次の操作を示す。

gateごとの人間の主な判断責務は次のとおりとする。

| gate | 人間が確認する内容 |
|---|---|
| Requirements | 問題、期待結果、対象・対象外、観測可能性、risk、制約、未決事項 |
| Design | Requirement/AC対応、意味変更、公開契約、data、security、障害時動作、rollback、test方針、manual checklist要否 |
| Tasks / 実装許可 | Design網羅、依存順、TDD単位、高risk checkpoint、manual確認、並列責務、隠れた前工程変更 |
| 実装完了 | scope、ACからtestへの追跡、RED/GREEN、revision・環境、failure・skip・未検証、manual結果、独立review、残存risk、rollback |

必須観点は`APPLICABLE / NOT_APPLICABLE / BLOCKED`へ分類し、`NOT_APPLICABLE`には理由を要求する。
blocking finding、staleまたは未実施review、risk不明、参照切れ、工程間矛盾、必須test欠落、manual未完了、
隠れたscope変更がある場合はapprovalを求めない。

自然言語の「進めて」は、直前にagentが一つだけのpending gateについて、次の4点を明示してapprovalを求め、
ほかの質問、選択肢、説明理解の確認が混在していない場合だけapprovalとして扱う。

1. 対象gate
2. 対象文書
3. 対象versionまたはhash
4. approvalによって許可される作業範囲

説明への返答、複数対象、対象version不明、一般的な続行指示、称賛、理解確認としての「進めて」はapprovalにしない。
固定commandは要求しない。壁打ちでの同意は後段gateへの申し送りであり、生成された正本文書と対象versionへの
正式approvalには流用しない。

## 4. 共通review観点

主agentの制限context reviewとfresh独立reviewは、少なくとも次の8観点を確認する。

1. 利用者意図、scope、対象外の置換・逸脱がないか。
2. architectureと複雑性が問題に対して過剰または不足していないか。
3. failure、skip、no-op、部分成功、誤った成功表示が隠れていないか。
4. 権限、data、security、外部副作用、rollbackが明示されているか。
5. 境界値、並行実行、再実行、負荷、順序依存を扱っているか。
6. API、dependency、外部接続、version、利用可能性の前提が事実に基づくか。
7. testが対象挙動を実際に検証し、mockや自己参照だけでPASSしていないか。
8. 文書、code、state、証跡、移行後の残骸に矛盾がないか。

この8観点は独立性を置き換えない。fresh reviewerの起動条件、Review Mode、model、最大巡回、収束、証跡は
Task Eと#39が定義する。観点自体はversion管理し、実測と反例に基づいて人間承認で変更できる。

## 5. 日本語と具体的記述

日本語化の最優先目的は、用語を翻訳することではなく、承認対象を一意に特定できることとする。
主体、対象、条件、動作、比較基準、変更前後、結果、例外、参照先を、読者が追加の前提知識なしに判断できる形で書く。

- SDD標準文書、steering、review、navigation、言語未指定の人間可読文書は日本語を既定とする。
- 平易な動詞と短い文を使うが、すべての文でIDや正式名称を反復しない。直前の対象が一意なら代名詞を許容する。
- `The / When / While / If / Where / shall`等のEARS keyword、schema、code、identifier、API field、command、
  path、raw log、error、hash、version、引用、license、vendored source、protocol文字列は必要に応じて原文を保持する。
- 1 acceptance criterionは一つの独立して検証可能な振る舞いだけを所有する。
- 禁止語listや全項目への数値強制ではなく、異なる読者が同じ合否を判断できるかで評価する。
- 規範文の曖昧さが挙動、scope、PASS/FAIL、approval可否を変え得る場合は`BLOCKED`とする。

## 6. session checkpointの情報境界

session checkpointはsession固有の派生manifestであり、新しい仕様正本、approval記録、backupではない。
未commit・Git未追跡の作業状態を含むsession再開が主な対象である。

checkpointは、正本path・ID・version・hashへの参照に加え、まだ正本へ固定されていない最小限の差分を持てる。
壁打ち中の未解決・未固定の合意は`provisional / pending-canonicalization`として記録し、仕様Decisionまたは
gate approvalとして扱わない。`agreement-log.md`または`spec.json`へ固定されるか、人間が再確認するまで、
後続gateやmutable作業を許可しない。checkpointが失われた場合、合意を推測で復元しない。

checkpointには少なくとも次を参照または記録できる。

- spec、task、phase、approval対象version・hash
- branch、commit、workspace、dirty・untracked状態
- 完了、残作業、blocker、次の一手、正本path
- session workspaceの識別情報と検証状態
- pending-canonicalization項目

checkpointはraw transcript、raw log、secret、token、PIIを既定で保存しない。必要な証拠は保存場所への参照と
sensitivityを記録する。secret・PIIを避けられない場合のlocal保存、暗号化、権限、retention、absolute pathの
privacyはTask Fとsecurity policyが決める。#37は中間・二次成果物の分類と保存方針だけを扱い、checkpoint runtime
storageの所有者にはしない。

sessionまたはworkspaceを閉じる・削除する前にpending-canonicalization項目を列挙し、正本固定、明示的な破棄、
または人間再確認のいずれが必要か示す。具体的なlifecycleと自動化はTask Fへ渡す。

## 7. session workspace参照と安全境界

checkpointでは、SDD Rig session ID、platform conversation ID、workspace metadataを別fieldとして扱う。
workspace path、Git common-dir、Git dir、branch、base、commit、dirty状態、lease検証状態は参照情報であり、
所有権、安全性、approvalの権威にはしない。

情報が古い、競合する、取得不能、または検証していない場合は`UNVERIFIED`または`BLOCKED`とし、safeやzeroへ
読み替えない。checkpointが作れたことをworkspace isolationの成功とはみなさない。

session workspaceの作成、所有権・lease、mutation preflight、runtime operation lock、lifecycle、recovery、
Claude Code/Codex adapter、fresh-session E2EはTask Fの必須inputとする。linked worktree、clone、directory、
lock実装などの具体方式はTask Cでは決めない。

## 8. 製品説明、NOTICE、帰属

- README等の主表示はSDD Rigの利用価値と独立製品であることを説明する。
- cc-sddをベースに開発したこと、独立・非提携、MIT帰属は、利用者が到達できるNOTICEまたは同等の場所へ置く。
- cc-sddのLICENSE全文、`Copyright (c) 2025 gotalab`、固定参照元はTask Bのcontractを維持する。
- SDD Rigの利用だけで利用project App全体へMITが自動伝播するとは説明しない。
- cc-sdd由来code、template、substantial portionsを実際に配布する場合は帰属を伝播する。

具体的なREADME・NOTICEの配置とpackage同梱はRequirementsとDesignで決める。

## 9. Tierと文書深度

Spec Tier `S / L`で文書体系を変えず、同じ責務とtraceabilityを維持したまま記載深度を変える。
Tier Sでも文書影響を確認し、変更がない場合は理由を記録する。Tier Lだから同じ内容を複数文書へ増やさない。

記載深度はscope、独立AC、責務境界、依存段数、設計選択、移行段階、人間判断、task分解の複雑性で決める。
riskとReview Mode、role別Model Classは別軸である。具体的閾値、相互作用、事前承認、計測はTask Eで再確認する。

## 10. 却下または補正した案

- `agreement-log.md`へ現在仕様全文を集約しない。
- `brief.md`へ承認済みDecisionと現在contractを混在させない。
- Git履歴だけを過去Decision・review・test evidenceへの唯一の到達手段にしない。
- 利用者資産保護を「すべて上書き禁止」という一律規則へ単純化しない。
- 既存の影響先一覧だけで意味変更の追跡完了とはみなさない。
- IDだけを並べたnavigationを人間review支援とみなさない。
- 禁止語list、全文への数値・ID反復を具体性の代用にしない。
- checkpointを正本参照だけにして未固定の作業差分を失わせない。
- checkpointをbackupまたはworkspace isolationの証明とみなさない。
- Tier S、軽微変更、文書変更なしの自己申告だけで文書影響確認を省略しない。
- 対象が明確でない一般的な「進めて」をapprovalにしない。
- 共通8観点をfresh reviewerだけの責務に限定しない。

## 11. Requirements候補とDesign保留

Requirementsでは少なくとも、次の観測可能な結果を定義する。

1. 情報種類ごとに一つの正本があり、下流参照から追跡できる。
2. 意味変更時に影響するreview・approval・参照がstaleまたは未解決として検出される。
3. 人間が各gateで読む対象、判断事項、承認不能理由へ短く到達できる。
4. 対象文書が日本語既定と具体性基準に従い、機械・法的原文を壊さない。
5. checkpointからfresh sessionを再開でき、未固定情報をapprovalへ昇格させない。
6. workspace情報が不明または競合する場合にfail-closedとなる。
7. 過去のDecision、review、approval、test evidenceへ到達できる。
8. Claude CodeとCodexで同じ観測可能な結果が得られる。

Designへ保留する項目は、ID・version・hashのschema、非意味変更判定、参照検証器、review guideとnavigationのformat、
checkpoint format・storage・retention・transport、workspace manager・lease・preflight・lock・recovery、
README・NOTICE配置、Task EのReview Mode・model・巡回・計測、Claude Code/Codex adapterである。

## 12. 後続Task・Issueへの引き継ぎ

| 対象 | 引き継ぐ内容 |
|---|---|
| Task D | 人間向け二次成果物は正本から一方向生成し、正本を置換しない。大容量出力をsessionへ再投入しない |
| Task E / #39 | 8観点、stale判定、独立性、Review Mode、model、収束、最大巡回、証跡、自然言語approvalを実装契約へ落とす |
| Task F | session workspace、lease、preflight、operation lock、checkpoint storage・lifecycle・recovery、fresh-session E2E |
| #32 | 全文書・skill・checkpoint・approval flowのClaude Code/Codex semantic parity |
| #37 | 中間・二次成果物の分類と保存。checkpoint runtime storageは所有しない |
| #30 | 非破壊sync、競合、`.new`、report。利用者所有資産と未知fieldを保持する |

## 13. 既知差分と停止条件

- 現行`workflow.md`は`integration-test-checklist.md`を実装後に作る記述だが、本DecisionはDesign承認時に要否を決め、
  必要ならTasks承認前に計画し、実装後に人間が結果を記録する。Requirements・Designで解消するまで既知差分とする。
- 現行checklist templateは実結果、証拠、status、副作用、rollbackの欄が不足する。実装時に更新対象とする。
- 現行`spec.json`には対象hashがない。Task Cではschemaを変更せず、Designで互換性と未知field保持を検討する。
- #39の既存requirementsはTask Eでreview配置が変わるためstaleであり、旧approvalをDesignへ流用しない。
- #37のmain worktree `outputs/`案はTask Fのsession workspace isolationと衝突し得る。Task D/Fで再評価する。

上記差分を未解決のまま完全実装、parity達成、migration完了として報告しない。
