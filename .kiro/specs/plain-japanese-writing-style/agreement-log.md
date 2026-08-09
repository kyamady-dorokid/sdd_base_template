# 合意形成記録: kiro-*生成物の平易な日本語化（plain-japanese-writing-style）

| 項目 | 内容 |
|---|---|
| タスクID | `plain-japanese-writing-style` |
| 作成日 | 2026-08-09 |
| 関係者 | KYamada / Claude Code |
| Tier | S寄り（新規ロジックなし・既存パターンの横展開だが、対象ファイル数は多い） |
| 契機 | cyclox2_docker側で `.kiro/specs/ga4-data-api-integration/requirements.md` を平易な日本語で
  書き直した実例ができ、これを恒久ルールとしてkiro-*スキル群へ一般化したいという依頼 |

---

## 壁打ち概要

cyclox2_docker側のセッションで、GA4連携specのrequirements.mdを「一文一義・やさしい言い回し・
エラー例は「」表記・Objective節を自然な日本語2文にする」方針で書き直した実例ができた。この
スタイルを、`kiro-spec-requirements`をはじめとするkiro-*スキル全般の出力に恒久ルールとして
組み込みたいという依頼を受けた。

cyclox2_docker側の`.claude/skills/kiro-*`はsdd_base_templateのインストーラ生成物であり、
再init/syncで上書きされるため、恒久化はsdd_base_template側の`payload/overlay/`に実装する必要が
ある。そのため作業をsdd_base_templateリポジトリ（ローカル: `/Users/kyamady/workspace/sdd_base_template`）
へ移し、既存overlayの仕組み（`payload/validation/patches/*.sh`による冪等追記パッチ、
`docs/sdd/`配下のSSOTドキュメント、`sync.sh`の`MANAGED_BLOCKS`登録、`validate.sh`/`checks.md`の
検証項目）を調査したうえで設計を提示し、合意を得た。

---

## 決定事項

| # | 決定内容 | 決定理由 | 決定日 |
|---|---|---|---|
| 1 | ルール本文は`payload/overlay/docs/sdd/rules/japanese-writing-style.md`1本にSSOT化する | ルールの重複・食い違いを防ぐ。既存の`commit-policy.md`等と同じ設計方針 | 2026-08-09 |
| 2 | ears-format.mdへは既存の「トリガー英語は残し可変部分だけ現地語化する」ルールに統合する形で
  薄い委譲パッチ（`fix-ears-plain-japanese.sh`）を追加する | Objective節の書き方はEARS固有の話であり、
  既存ルールとの矛盾を避けるため一体化させる | 2026-08-09 |
| 3 | 対象スキルを、直接ドキュメントを生成する11スキル
  （kiro-spec-requirements/design/tasks/init, kiro-validate-design/gap/impl, kiro-discovery,
  kiro-steering, kiro-steering-custom, kiro-impl）に拡大する | ユーザー指示。当初案の7スキルに
  加え、kiro-discovery/kiro-steering/kiro-steering-custom/kiro-implも直接文書を生成するため対象に含めるべきと判断 | 2026-08-09 |
| 4 | kiro-review/kiro-debug/kiro-verify-completion/kiro-spec-batch/kiro-spec-quick/kiro-spec-status
  は対象外とする | 独立した文書を作らず、他スキルへの委譲または会話内出力のみのため | 2026-08-09 |
| 5 | sync.shの自動マージ機能追加は本スペックのスコープ外とし、別スペックとして後日起票する | 既存spec
  `sdd-base-sync-command`のマージロジック本体に踏み込む規模の異なる別機能であり、無関係な変更を
  1つのPRに混在させないため。ユーザーも「別スペックとして後で起票」を選択 | 2026-08-09 |
| 6 | 作業はcyclox2_dockerセッションを継続し、絶対パス指定でsdd_base_template側のファイルを編集する | セッションの
  Primary working directoryはハーネス側でcyclox2_dockerに固定されているが、Write/Editは絶対パス
  指定で動作するため機能的な制約にならない。ユーザーが「このセッションのまま進める」を選択 | 2026-08-09 |

### 却下・保留
| 内容 | 理由 |
|---|---|
| sync.shの自動マージ機能（判断不要な場合の自動適用） | 決定事項5の通り、別スペックへ切り出し |
| かたい漢語のNGワード網羅リスト化 | 参考例として明記するに留め、将来ケースの追加を妨げないようにする |

---

## フェーズゲート承認記録

> 承認状態の正本は `spec.json`。ここでは経緯のみ。

| フェーズ | 合意メモ |
|---|---|
| 要件/設計 | cyclox2_docker側での対話（設計提示→`AskUserQuestion`2回）で合意形成。対象スキル拡大・
  sync自動マージの切り出し・作業環境の3点を確認し、requirements.md/design.mdへ反映した |
| タスク分解・実装前確認 | tasks.md作成後、実装着手前に人間の最終承認（「進めて」）を得る |

---

## 変更履歴

| 日付 | 変更内容 | 変更者 |
|---|---|---|
| 2026-08-09 | 初版作成（cyclox2_docker側セッションでの壁打ちを反映） | Claude Code |
