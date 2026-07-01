# Implementation Plan: sdd_base_template 安全な更新機構（sync コマンド, Part B）

> TDD（テスト先行）で進める。各コンポーネントはテスト作成（RED）→実装（GREEN）の順。
> bash スクリプトのテストは `payload/scripts/sync_lib/*.sh` を直接 source し、シェル関数として
> assert するシンプルなテストランナー（`tests/` 新設）で行う。

- [x] 1. テスト基盤の新設
  - `tests/run.sh`（最小限のテストランナー: 各 `test_*.sh` を実行し pass/fail 集計）
  - `tests/test_hash.sh` の雛形のみ作成（中身は 2.1 で書く）
  - 観測可能な完了条件: `bash tests/run.sh` が実行でき、テストなしで exit 0 する
  - _Requirements: 4.2_

- [x] 2. `sync_lib/hash.sh`（ハッシュ計算ラッパー）
- [x] 2.1 テスト作成（RED）
  - `tests/test_hash.sh`: 同一内容ファイルから同一ハッシュ、異なる内容から異なるハッシュを
    返すことを assert
  - `sha256sum` 不在環境を模擬し `shasum -a 256` へフォールバックすることを assert
    （`PATH` 操作 or 関数モックで環境分岐をテスト）
  - _Requirements: 1.2_
- [x] 2.2 実装（GREEN）
  - `payload/scripts/sync_lib/hash.sh`: `sdd_hash_file(path)` 関数を実装
  - 観測可能な完了条件: 2.1 のテストが全て pass する
  - _Requirements: 1.2_

- [x] 3. `sync_lib/lock.sh`（lock ファイルの読み書き）
- [x] 3.1 テスト作成（RED）
  - `tests/test_lock.sh`: `template_commit`/`template_repo`/`file:`/`block:` 各行の
    書き込み→読み込みが往復一致することを assert
  - `git rev-parse HEAD` 失敗時に固定リポジトリURL定数へフォールバックすることを assert
  - _Requirements: 1.2, 1.3, 2.1_
- [x] 3.2 実装（GREEN）
  - `payload/scripts/sync_lib/lock.sh`: `sdd_lock_write(...)` / `sdd_lock_read_hash(file_or_block_key)`
    を実装。フォーマットは design.md の Logical Data Model 節に準拠
  - 観測可能な完了条件: 3.1 のテストが全て pass する
  - _Requirements: 1.2, 1.3, 2.1_

- [x] 4. `sync_lib/merge.sh`（3-wayマージ）
- [x] 4.1 テスト作成（RED）
  - `tests/test_merge.sh`: ファイル全体3-wayマージのクリーンケース（current/base/other が
    非重複の変更）で正しくマージされることを assert
  - コンフリクトケースで `<file>.new` が生成され、元ファイルが無変更のままであることを assert
  - マーカーブロック抽出3-wayマージで、ブロック外の周囲コンテンツが変更されないことを assert
  - _Requirements: 2.3, 2.4, 2.5, 2.6_
- [x] 4.2 実装（GREEN）
  - `payload/scripts/sync_lib/merge.sh`: `sdd_merge_file(current, base, other, out)` と
    `sdd_merge_marker_block(file, marker, base_content, other_content)` を実装
  - 観測可能な完了条件: 4.1 のテストが全て pass する
  - _Requirements: 2.3, 2.4, 2.5, 2.6_

- [x] 5. `sync.sh`（オーケストレーション: 初回化ルート）
- [x] 5.1 テスト作成（RED）
  - `tests/test_sync_init.sh`: lock 不在の空リポジトリで `sync.sh` を実行し、
    `.kiro/sdd-base.lock` と `.kiro/sdd-base-snapshot/` が生成されること、既存ファイルが
    無変更であることを assert
  - _Requirements: 1.1, 1.4_
- [x] 5.2 実装（GREEN）
  - `payload/scripts/sync.sh` の初回化分岐（lock不在判定→スナップショット複製→lock生成→
    自動コミットしない）を実装
  - 観測可能な完了条件: 5.1 のテストが全て pass する
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 6. `sync.sh`（オーケストレーション: 差分適用ルート）
- [x] 6.1 テスト作成（RED）
  - `tests/test_sync_apply.sh`: lock 有り状態で以下4ケースを assert
    - ローカル未変更ファイル → 新版でそのまま更新
    - ローカル変更・非コンフリクト → クリーンマージが適用されレポートに記載
    - ローカル変更・コンフリクト → `<file>.new` 生成、既存ファイルは無変更
    - テンプレ非存在のローカル専用ファイル（`.kiro/specs/` 等）→ 一切変更されない
  - 上流で削除されたファイルの検出でレポートにのみ記載され、削除は実行されないことを assert
  - `.gitignore` スニペットが欠けている行のみ追記されることを assert
  - _Requirements: 2.1, 2.2, 2.7, 2.8, 2.9_
- [x] 6.2 実装（GREEN）
  - `payload/scripts/sync.sh` の差分適用分岐（ハッシュ比較→未変更/変更判定→`merge.sh`呼出→
    保護対象スキップ→削除検出）を実装
  - 観測可能な完了条件: 6.1 のテストが全て pass する
  - _Requirements: 2.1, 2.2, 2.7, 2.8, 2.9_

- [x] 7. 実行結果レポート出力
- [x] 7.1 テスト作成（RED）
  - `tests/test_sync_report.sh`: `.kiro/sdd-base-update-report.md` に4カテゴリ
    （新規適用/クリーンマージ/コンフリクト/上流削除）の見出しが含まれることを assert
  - 自動コミットが一切発生しないことを assert（`git status` の差分がステージされていないことを確認）
  - _Requirements: 3.1, 3.2, 3.3, 3.4_
- [x] 7.2 実装（GREEN）
  - `sync.sh` にレポート生成処理を追加（5, 6 の各分岐結果を集約）
  - 観測可能な完了条件: 7.1 のテストが全て pass する
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 8. CLI統合・検証・ドキュメント
- [x] 8.1 `bin/cli.js` に `sync` サブコマンドを追加
  - 既存 `init`/`validate` と同じ `sh()` ヘルパー経由で `payload/scripts/sync.sh` を呼ぶ
  - 観測可能な完了条件: `node bin/cli.js sync` が動作し、help 表示にも追加される
  - _Requirements: 4.1_
- [x] 8.2 `payload/validation/checks.md` に lock整合性・ローカル変更保持のチェック項目を追加
  - _Requirements: 4.2_
- [x] 8.3 README「その他の使い方」に `sync` の説明（用途・実行例・非破壊性）を追加
  - _Requirements: 4.3_
- [x] 8.4 sync 完了後にローカルスキルミラー（`~/.claude/skills/sdd-init` 等）の再同期案内を出力
  - _Requirements: 4.4_

- [x] 9. E2E 通し確認（人間による結合試験の前段）
  - 空リポジトリで `init` → 独自変更を加える → `sync`（初回化）→ 上流相当の変更を加えた
    payload で再度 `sync`（差分適用: 未変更/クリーンマージ/コンフリクトの3パターン）を通しで実行し、
    `test-results.md` に記録
  - 観測可能な完了条件: 全パターンで既存ローカルファイルのサイレント上書きが発生しないことを確認
  - _Requirements: 全要件_
  - _Boundary: sync.sh, sync_lib/*_
