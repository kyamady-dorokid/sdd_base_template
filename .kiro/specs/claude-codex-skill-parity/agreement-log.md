# 合意形成記録: Claude Code / Codex SDDスキルパリティ

| 項目 | 内容 |
|---|---|
| タスクID | `claude-codex-skill-parity` |
| GitHub Issue | `#32` |
| 作成日 | 2026-08-15 |
| 関係者 | KYamada / Codex |
| Tier | L（スキル検出・起動、配布検証、文書、Claude/Codexを横断） |

---

## 壁打ち概要

`cyclox2_docker`でClaude Code側のSDDスキルは利用できる一方、Codexの利用可能スキル一覧には
`kiro-spec-batch`以外の`kiro-*`が現れず、文書規約だけが有効で実行スキル層が実質利用不能になる
事象が確認された。既存Issue #32を親specとして拡張し、新規Issueへ細分化せずtasksで管理する。

## 決定事項

| # | 決定内容 | 決定理由 | 決定日 |
|---|---|---|---|
| 1 | 既存Issue #32へ今回のインシデントと改修を統合し、Tier Lの単一specとして扱う | 全機能のClaude/Codexパリティと今回の障害が同じ受入責任を持つため | 2026-08-15 |
| 2 | `openai.yaml`の形式差を原因と断定せず、一覧・selector・明示起動・暗黙起動・実処理を分離して調査する | 現行公式仕様では`interface`形式が正式で、暗黙起動禁止も明示起動を禁止しないため | 2026-08-15 |
| 3 | 初期一覧への表示だけで合否を決めず、公式選択経路と明示起動を含めて判定する | context budgetによる表示省略と本当の未検出を区別するため | 2026-08-15 |
| 4 | 全user-facingスキルの明示起動を必須とし、暗黙起動はスキル分類ごとに定義する | 利用可能性を保証しつつ、誤起動しやすいhelperまで一律に暗黙起動しないため | 2026-08-15 |
| 5 | バイト単位一致ではなく、スキル名・起動方針・必須資産・安全契約の意味的パリティを検証する | Claude/Codex間には意図したプラットフォーム変換差があるため | 2026-08-15 |
| 6 | init、sync、`cyclox2_docker`反映後の新規セッションを受入対象にする | テンプレート内の静的検査だけでは配布先の利用不能を防げないため | 2026-08-15 |
| 7 | Issue #39で承認した1名基本の収束型独立レビューを#39実装前も手動適用する | #32自身の要件品質と後続実装の前提を同じ規約で保護するため | 2026-08-15 |
| 8 | #32を#30のhard dependencyから外し、#39のrequirements承認後に先行着手する | スキル検出修復はsync自動マージ改善なしでも進められ、後続IssueのCodex実行基盤になるため | 2026-08-15 |
| 9 | #32は検出・起動・意味的パリティを所有し、#39は#32完了後に厳格な独立レビュー契約を両環境へ実装する | #39の安全契約を#32の完了条件にして循環依存させないため | 2026-08-15 |
| 10 | 正規インベントリへ全`kiro-*`、`doc-export`、個人向け`sdd-init`を含める | Claude/Codex対応を全機能の必須条件とし、導入入口だけをパリティ対象外にしないため | 2026-08-15 |
| 11 | 意味的パリティの不合格・未実施・実行不能・証跡不足をfail-closedに扱う | NGを表示しながらinit・sync・releaseを成功扱いする抜け道を防ぐため | 2026-08-15 |
| 12 | 起動証跡へsource/scope、実ファイル、enabled状態を含める | 同名スキルやdisable設定下で別実体の起動を誤合格にしないため | 2026-08-15 |
| 13 | 今回に限りdesign承認で停止せず、designとtasksを生成・独立レビューした後に一括して人間承認を求める | ユーザーが#32に限ったゲート集約を明示承認したため。実装承認は含まない | 2026-08-15 |
| 14 | design第2修正後の`LATE_FINDING` L1を修正し、同一reviewerで追加収束確認する | 人間が安全なmigration順序を理解したうえで明示承認したため | 2026-08-15 |

## 却下・保留事項

| 内容 | 理由 |
|---|---|
| `kiro-spec-batch`のトップレベル形式を正解として他のmetadataへ複製する | 公式仕様と矛盾する可能性があり、原因が未確定のため却下 |
| 初期available skills一覧への全件表示を唯一の合格条件にする | context budgetによる省略があり、公式選択経路と明示起動を評価できないため却下 |
| 全スキルの暗黙起動を一律に有効化する | internal/helperの誤起動と安全境界を考慮できないため却下 |
| #31、#39、#30、#33の実装を本specへ同梱する | 独立した責任と承認単位を維持するため対象外 |

## フェーズゲート承認記録

> 承認状態の正本は`spec.json`。ここでは経緯だけを記録する。

| フェーズ | 合意メモ（理由・補足） |
|---|---|
| 要件定義（requirements.md） | 1名の`gpt-5.6-sol` reviewerによる収束確認が`PASS`。12要件・89受入条件、全14観点COVERED、未解消指摘なし。人間承認済み（「承認するよ」2026-08-15） |
| 設計（design.md） | 独立review `PASS`。今回限りtasksと一括して人間承認済み（「承認するよ」2026-08-15、hash `976e31b0ee0f0a9d70db4cd212749a991a5a238a`） |
| タスク分解・実装前確認（tasks.md） | 独立review `PASS`。designと一括して人間承認済み（「承認するよ」2026-08-15、hash `7456b1c63bdfc0b23820c02e44b5ff4b4e56c563`）。実装開始は別途明示承認待ち |

## 変更履歴

| 日付 | 変更内容 | 変更者 |
|---|---|---|
| 2026-08-15 | 既存Issue #32へCodexスキル未検出インシデント、調査境界、依存順を統合 | KYamada / Codex |
| 2026-08-15 | `/kiro-spec-init`・`/kiro-spec-requirements`相当の手順でbrief、requirements、spec状態、合意記録を作成 | Codex |
| 2026-08-15 | 独立requirements reviewで境界問題2件、局所欠陥4件を一括検出。`RETURN_TO_PREVIOUS_GATE`として停止 | Codex reviewer |
| 2026-08-15 | 人間判断により#32/#39責任分担の推奨案と全配布スキルを含む正規インベントリ案を採用 | KYamada / Codex |
| 2026-08-15 | 人間判断2件と局所欠陥4件をrequirements・briefへ一括反映し、同じreviewerへの収束確認準備を完了 | Codex |
| 2026-08-15 | 同一reviewerのFollow-up 1が`PASS`。初回6指摘CLOSED、regression・late finding・scope changeなし | Codex reviewer |
| 2026-08-15 | 人間がIssue #32のrequirementsを明示承認。PASS reviewのinput hashに紐付けて`spec.json`へ記録 | KYamada / Codex |
| 2026-08-15 | 人間が#32に限りdesignとtasks生成後の一括承認を許可。各独立reviewは省略せず、実装前に停止する条件で記録 | KYamada / Codex |
| 2026-08-15 | 独立design reviewが`REVISE`。lifecycle状態遷移、install所有判定、検査可能な安全・live契約の3件を一括検出 | Codex reviewer |
| 2026-08-15 | 3件を#32内の局所修正として設計へ一括反映し、同一reviewerの収束確認用hashを更新 | Codex |
| 2026-08-15 | design Follow-up 1はD1・D2をCLOSED、D3のhelper起動契約だけをOPENとして`REVISE` | Codex reviewer |
| 2026-08-15 | 公式仕様上保証できないhelper非表示を撤回し、両agentの直接起動停止とparent委譲を第2修正batchで具体化 | Codex |
| 2026-08-15 | design Follow-up 2でD3はCLOSED。移行図のlegacy削除順序矛盾が`LATE_FINDING`として1件残り、2修正batch上限により人間判断で停止 | Codex reviewer / Codex |
| 2026-08-15 | 人間承認によりL1を修正。canonical実行validation PASS後だけmanaged legacyを削除し、unknown-ownerはPARTIALを維持する図へ統一 | KYamada / Codex |
| 2026-08-15 | design Follow-up 3はL1をCLOSED。修正図がcanonical unknown-ownerも配置へ流す`REGRESSION` R1を検出 | Codex reviewer |
| 2026-08-15 | R1を第4修正batchで反映。canonical所有状態を配置可否より前に分岐し、unknown/externalを非破壊PARTIALへ固定 | Codex |
| 2026-08-15 | design Follow-up 4が`PASS`。全89条件、D1-D3、L1、R1がCLOSEDで未解消findingなし | Codex reviewer |
| 2026-08-15 | PASS済みdesignからTDD順序・component境界・lifecycle依存を持つtasksを生成。89/89 AC mappingと全taskのobservable completionを機械確認 | Codex |
| 2026-08-15 | tasks初回reviewは`RETURN_TO_PREVIOUS_GATE`。非実在design dependency 1件とtask粒度・境界・integration不足4件を一括検出 | Codex reviewer |
| 2026-08-15 | designを実在する`sync_lib`と自己完結Node CLIのdependencyへ修正し、tasksをstaleとしてdesign再reviewへ戻した | Codex |
| 2026-08-15 | design Follow-up 5が`PASS`。DL1を含む全findingがCLOSEDし、stale tasksの再生成へ移行 | Codex reviewer |
| 2026-08-15 | tasksを36個のTDD sliceへ再生成。T1-T4に対応し、責任境界、standalone validate、旧正本移行、下流受入setupを分離 | Codex |
| 2026-08-15 | tasks Follow-up 1はDL1・T1・T3・T4をCLOSED、manifest policyとvalidator executionの責任重複T2だけを`REVISE` | Codex reviewer |
| 2026-08-15 | T2を第2修正batchで反映。assertion schema、evaluator、agent統合を別taskへ分離 | Codex |
| 2026-08-15 | tasks Follow-up 2が`PASS`。37/37 task、89/89 AC、全design concernがCOVEREDで未解消findingなし | Codex reviewer |
| 2026-08-15 | 今回限りのcombined modeに従い、design/tasks一括人間承認待ちで停止。実装開始承認は含めない | Codex |
| 2026-08-15 | 人間がdesign/tasksを一括承認。各PASS review hashへ承認を結び付け、実装開始は未承認のまま停止 | KYamada / Codex |
