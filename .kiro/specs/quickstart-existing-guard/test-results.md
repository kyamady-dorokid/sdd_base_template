# テスト結果記録: README再構成・既存環境ガード・進め方の入力明確化

| 項目 | 内容 |
|---|---|
| タスクID | `quickstart-existing-guard` |
| 実行日 | 2026-06-25 |
| 実行者 | Claude |
| 実行コマンド | `node bin/cli.js init [--on-existing=...]`（空dir/既存ありで実機） |
| 実行環境 | ローカル（bash 3.2.57 / cc-sdd 3.0.2） |

---

## テスト項目一覧

| # | テスト項目名 | 観点 | 期待結果 | 実際結果 | 合否 |
|---|---|---|---|---|---|
| 1 | 新規(既存なし) init | 正常系 | 検証 pre/post PASS、skills生成 | PASS×2、skills 19 | ✅ |
| 2 | keep（既存CLAUDE.md/specs有り） | 既存温存 | 既存温存・不足分生成・overlay追記・PASS×2 | CLAUDE温存/specs温存/overlay追記/PASS×2 | ✅ |
| 3 | overwrite | 上書き+backup | 上書き・`.sdd-backup`に旧保存・steering温存・PASS×2 | 全て確認・PASS×2 | ✅ |
| 4 | compare | 非破壊 | 既存不変・新旧diff提示・PASS×2 | 非破壊・diff提示・PASS×2 | ✅ |
| 5 | `.kiro/specs` `.kiro/steering` 保護 | 異常系防止 | 全モードで初期化されない | keep/overwrite で温存確認 | ✅ |
| 6 | bash 3.2 互換 | 環境制約 | `set -u` 空配列でエラーしない | `${arr[@]+...}` で解消 | ✅ |
| 7 | スクリプト構文 | 静的 | `bash -n` OK | init/validate OK | ✅ |

---

## 実行結果サマリー

| 合計 | 合格 | 失敗 | スキップ |
|---|---|---|---|
| 7 | 7 | 0 | 0 |

---

## 失敗項目の詳細（修正済み）

| # | 項目名 | 失敗内容 | 原因 | 対処 |
|---|---|---|---|---|
| a | keep 初版 | skills等が生成されず post NG | `--overwrite=skip` は「全skip(0生成)」だった | keep はフラグ無し＋`</dev/null`非対話に変更 |
| b | keep 初版 | `BACKUP_ARGS[@]: unbound variable` | bash 3.2 + `set -u` の空配列展開 | `${arr[@]+"${arr[@]}"}` イディオムへ |
| c | compare 初版 | 既存を force 上書きしていた | 「上書きせず差分提示」要件に反する | temp生成→diff の非破壊方式へ修正 |

---

## 備考

- cc-sdd の overwrite 仕様を実機確認: `skip`=全ファイル生成しない / 無印(非TTY)=既存温存・不足分生成 / `force`=全上書き。
- `--overwrite=force --backup=DIR` は上書き対象の旧ファイルのみ `DIR` に保存。`.kiro/specs`・`.kiro/steering` は force でも非対象（温存）。
