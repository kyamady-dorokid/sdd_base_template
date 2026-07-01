# 合意形成記録: sdd_base_template 安全な更新機構（sync コマンド, Part B）

| 項目 | 内容 |
|---|---|
| タスクID | `sdd-base-sync-command` |
| 作成日 | 2026-07-01 |
| 関係者 | KYamada / Claude Code |
| 由来 | Part A/B/C のうち Part B。記録先を `sdd-base-upstream-fix` から分離（ユーザー指示: 「記録先は分けて進めて」） |

---

## 壁打ち概要

Part A/C（PR #10, マージ済み）で、消失していた独自ルールを overlay へ恒久反映する対応は完了した。
残る Part B は「今後のテンプレ更新そのものを安全に反映する仕組み」の新設であり、破壊的操作
（ローカルファイル上書き）を伴いうるため、`.kiro/specs/sdd-base-upstream-fix/` とは別タスクIDとして
記録を分離した。

設計の出発点は引き継ぎ元（`cyclox2_docker`）の `.kiro/specs`... 実際には
`docs/specs/sdd-base-template-upstream-fix/agreement-log.md`（cyclox2_docker側の旧記録）§3 に
まとめられた設計ドラフト（lock + snapshot + 3-wayマージのハイブリッド方式）であり、これを
`requirements.md` として本タスクに正式に落とし込んだ。

---

## 決定事項

| # | 決定内容 | 決定理由 | 決定日 |
|---|---|---|---|
| 1 | Part B は独立タスクID `sdd-base-sync-command` として記録する（`sdd-base-upstream-fix` とは分離） | Part Bは破壊的操作を伴う大規模改修でフルフロー（requirements/design/tasks + spec.json）を要し、Part A/Cの低リスク追記とレビュー粒度・承認単位が異なるため | 2026-07-01 |
| 2 | 新コマンド名は `sync` を採用（`bin/cli.js sync`） | 既存 `update`（テンプレ開発者向け `git pull --ff-only`）と意味が異なり、名称衝突を避ける必要があるため（引き継ぎ元 §3 で既に決定済みの方針を踏襲） | 2026-07-01 |
| 3 | lock/snapshot 方式は「3-wayマージ+lock」ハイブリッドを採用（ネットワーク経由の過去コミットre-clone方式は不採用） | ネットワーク依存・履歴改変リスクを避けるため。ローカル永続スナップショットによるリポジトリ肥大化は許容トレードオフとする（引き継ぎ元 §3 の決定を踏襲） | 2026-07-01 |
| 4 | requirements.md を EARS 形式でフルに作成し、人間承認ゲートを経てから design.md に進む | Part B はコーディングを主体とする改修であり、CLAUDE.md 基本ルール1（ドキュメント完成後にいきなり実装しない）・ルール2（TDD）が適用されるため | 2026-07-01 |

---

## 却下・保留事項

| 内容 | 理由 |
|---|---|
| Part B を Part A/C と同一PR・同一タスクIDで進める | 破壊的操作の有無でレビュー・承認の性質が異なるため分離（決定1） |
| lock ファイルを JSON 形式にする | 既存実装（`init.sh`/`validate.sh`）が bash 完結スタイルであり、一貫性のため行指向フラット形式を採用（引き継ぎ元 §3 の決定を踏襲） |

---

## フェーズゲート承認記録

> 承認状態の正本は `.kiro/specs/sdd-base-sync-command/spec.json` の
> `approvals.{requirements,design,tasks}.approved`。ここでは経緯・補足のみ。

| フェーズ | 合意メモ（理由・補足） |
|---|---|
| 要件定義（requirements.md） | 引き継ぎ元の設計ドラフトを EARS 形式の要件4本（初回lock作成／3-wayマージ／可視化・非破壊性／既存コマンド非衝突）に整理して起票。**人間承認済み**（「OK。」2026-07-01） |
| 設計（design.md） | lock+snapshotによる3-wayマージ台帳方式で確定。`sync.sh`+`sync_lib/{hash,lock,merge}.sh` の構成、コンフリクトは exit 0（想定内分岐）として扱う方針を明記。**人間承認済み**（「OK」2026-07-01） |
| タスク分解・実装前確認（tasks.md） | TDD前提で9タスクに分解（テスト基盤→hash→lock→merge→sync初回化→sync差分適用→レポート→CLI統合→E2E通し）。**人間承認済み**（「OK」2026-07-01）。**全タスク実装完了**（test-results.md参照） |

---

## 変更履歴

| 日付 | 変更内容 | 変更者 |
|---|---|---|
| 2026-07-01 | 初版作成。記録先をPart A/Cから分離し、requirements.md を起票 | Claude Code |
| 2026-07-01 | requirements.md 人間承認。design.md 起票（lock+snapshot+3-wayマージの詳細設計を確定） | Claude Code |
| 2026-07-01 | design.md 人間承認。tasks.md 起票（TDD前提の9タスク分解） | Claude Code |
| 2026-07-01 | tasks.md 人間承認。全タスク実装完了（`hash.sh`/`lock.sh`/`merge.sh`/`sync.sh`/CLI統合/README/checks.md）。単体・結合テスト55件PASS、実リポジトリでのE2E確認完了 | Claude Code |
