# 合意形成記録: sync の apply_gitignore 部分一致バグ修正（sync-gitignore-wholeline）

| 項目 | 内容 |
|---|---|
| タスクID | `sync-gitignore-wholeline` |
| 作成日 | 2026-07-13 |
| 関係者 | KYamada / Claude Code |
| Tier | S（明白なバグ修正・小・回帰テスト付き） |
| 契機 | two-tier-deliverables マージ後の dogfood（`sync` 実行）で `.gitignore` に `outputs/` が追加されず、孤立コメントが残る事象を発見 |

---

## 壁打ち概要

two-tier で追加した `outputs/`（二次成果物のビルド出力）を dogfood で自リポジトリへ反映するため
`sync` を実行したところ、`.gitignore` に `outputs/` パターンが**追加されず**、コメント行だけが孤立して残った。

### 根本原因
`sync.sh` の `apply_gitignore` が `grep -qF`（**部分一致**）で既存判定していた。新規行 `outputs/` が
既存の `.kiro/specs/*/outputs/` に**部分一致**するため「既に存在」と誤判定し、`outputs/` 行をスキップ。
一方コメント行は一意なので追加され、孤立コメントが残った。

### 影響
- **`sync` を使う全リポジトリ**で、`.kiro/specs/*/outputs/` を先に持つため `outputs/` が必ず誤スキップ。
- リポジトリ直下 `outputs/`（二次成果物）が gitignore されず、誤コミットされうる実害。
- two-tier の Requirement 2.2（`outputs/` を gitignore）が sync 経由で未達だった。

---

## 決定事項

| # | 決定 | 理由 | 決定日 |
|---|---|---|---|
| 1 | `apply_gitignore` の既存判定を `grep -qF`（部分一致）→ `grep -qxF`（**行完全一致**）に修正 | 部分一致による誤スキップ・孤立コメントを解消。`outputs/` を独立行として正しく追記する | 2026-07-13 |
| 2 | 回帰テスト `tests/integration/test_sync_gitignore.sh` を追加（部分一致衝突の再現＋冪等性） | 同種のデグレを防止 | 2026-07-13 |
| 3 | `init.sh` の gitignore 追記は変更しない | 別ロジック（マーカー1行の有無でスニペット全体を一括追記）で、新規 repo には `outputs/` 含む全体が入るため本バグの対象外 | 2026-07-13 |

### 却下・保留
| 内容 | 理由 |
|---|---|
| 既に壊れた `.gitignore`（孤立コメント・`outputs/` 欠落）を持つリポジトリの自動修復 | スコープ外。本修正後に `sync` を再実行すれば `outputs/` は追記される（孤立コメントの除去は必要なら手動 or 別対応） |

---

## フェーズゲート承認記録

> 承認状態の正本は `spec.json`。ここでは経緯のみ。ユーザー指示により Tier S・即修正案で進行。

| フェーズ | 合意メモ |
|---|---|
| 要件/設計/タスク | Tier S。要件=「sync の gitignore 追記が部分一致で誤スキップするのを修正」。設計=`-qF`→`-qxF`。実装=下記。人間承認は本 PR のレビュー・マージで得る |
| 実装 | 完了。RED（`outputs/` 誤スキップ 0件）→ GREEN（独立行追記・冪等）。全145件 PASS |

---

## 変更履歴

| 日付 | 変更内容 | 変更者 |
|---|---|---|
| 2026-07-13 | dogfood で発見した apply_gitignore 部分一致バグを修正（`-qF`→`-qxF`）。回帰テスト追加 | Claude Code |
