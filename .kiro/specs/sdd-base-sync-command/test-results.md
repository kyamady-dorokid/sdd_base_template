# 実行テスト記録: sdd-base-sync-command（Part B）

## 単体テスト（`tests/unit/`）

TDD（RED→GREEN）で実装した各コンポーネントのテスト結果。`sync_lib/*.sh` を直接 source し、
外部への副作用（ファイルシステム上の一時ディレクトリ以外）を持たない純粋なロジックを検証する。

| テストファイル | 内容 | 件数 | 結果 |
|---|---|---|---|
| `test_hash.sh` | `hash.sh`（sha256計算・ファイル/文字列） | 5 | PASS |
| `test_lock.sh` | `lock.sh`（lock読み書き・冪等上書き・commit解決フォールバック） | 11 | PASS |
| `test_merge.sh` | `merge.sh`（ファイル全体3-wayマージ・コンフリクト非破壊・マーカーブロック抽出/置換） | 14 | PASS |
| **小計** | | **30** | **PASS** |

## 結合テスト（`tests/integration/`）

`sync.sh` を実際に起動し、複数コンポーネント（hash/lock/merge）を組み合わせた
エンドツーエンドの挙動を検証する。

| テストファイル | 内容 | 件数 | 結果 |
|---|---|---|---|
| `test_sync_init.sh` | `sync.sh` 初回化ルート | 8 | PASS |
| `test_sync_apply.sh` | `sync.sh` 差分適用ルート（未変更更新/クリーンマージ/コンフリクト非破壊/保護領域不可侵/上流削除検出） | 11 | PASS |
| `test_sync_report.sh` | 実行結果レポート・自動コミットなし | 6 | PASS |
| **小計** | | **25** | **PASS** |

## 合計

**55件 PASS**（`bash tests/run.sh` exit 0。unit → integration の順に実行）。

> レビュー指摘により `tests/unit/` `tests/integration/` への分割を行った際、
> `run.sh` の走査変数 `DIR` が sourced されたテストファイル側の `DIR`（自身のパス解決用）と
> 同名で衝突し、2グループ目（integration）が誤ったパスを参照して 0 件実行になる不具合を発見・修正した
> （`run.sh` 側の変数名を `RUNNER_DIR` に変更して解消）。修正後、55件すべて PASS を再確認済み。

## E2E 通し確認（実リポジトリ・実 CLI 経由）

空リポジトリで `node bin/cli.js init --lang ja --yes` → `sync` を通しで実行し、以下を確認。

| シナリオ | コマンド | 確認結果 |
|---|---|---|
| 初回 `sync`（lock不在） | `node bin/cli.js sync --yes` | `.kiro/sdd-base.lock`・`.kiro/sdd-base-snapshot/` を生成。lock の `file:` 行がsha256（64桁hex）で記録される。既存ファイルは無変更 |
| 2回目 `sync`（ローカル未変更） | 同上（再実行） | `lock 検出 → 差分適用` ルートに入り、正常終了。既存ファイルへの再上書きなし（内容同一） |
| コンフリクトシナリオ | ローカル `docs/sdd/workflow.md` に追記 ＋ `payload/overlay/docs/sdd/workflow.md`（本体）にも別途追記 → `sync --yes` | 「コンフリクトが1件あります」を表示。`docs/sdd/workflow.md` は**ローカル追記のまま無変更**、`docs/sdd/workflow.md.new` が生成されコンフリクトマーカー入り。**payload本体は sync 実行後も `git status --short` でクリーン**（誤って書き換えていないことを確認） |
| 自動コミット無し | 全シナリオ共通 | `git status --porcelain` でステージ済み変更（`M`/`A`等）が発生しないことを確認（未追跡ファイルの `??` のみ） |
| **`init` の sync 管理下ガード**（レビュー指摘） | `init` → `sync --yes`（lock作成）→ `docs/sdd/workflow.md` にローカル追記 → `init --yes --on-existing=keep` で再実行 | `init` は「sync 管理下（.kiro/sdd-base.lock 検出）のため上書きしません」と表示し、`docs/sdd/workflow.md` のローカル追記が**保護される**（修正前のコードで同シナリオを再現すると無条件 `cp -R` により追記が消えることを確認済み） |
| 上記ガードの回帰確認 | lock が存在しない新規リポジトリで `init` のみ実行 | 従来通り `docs/sdd/` が展開される（lock 未作成時は影響なし） |

## 結論

TDDで実装した5コンポーネント（hash/lock/merge/sync初回化/sync差分適用+レポート）は
単体テスト30件・結合テスト25件、合計55件すべてPASS。
実リポジトリでの通し実行でも、非破壊性（コンフリクト時のサイレント上書き禁止）・保護領域不可侵
（`.kiro/specs`・`.kiro/steering`）・自動コミット無しの3点を実地で確認。

tasks.md の全タスク（1〜9）完了。
