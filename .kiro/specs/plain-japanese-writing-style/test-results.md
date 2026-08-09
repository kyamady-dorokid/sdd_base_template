# Test Results

## 実行日
2026-08-09

## 全体テストスイート
`bash tests/run.sh`

- 実行結果: Total 145, Failed 1
- 失敗した1件（`未生成の docx に pandoc 導入案内が付く`）は、変更前の`main`ブランチでも同一の
  内容・件数で失敗することを確認済み（doc-export/pandoc関連、環境依存の既存不具合であり本変更とは
  無関係）。本変更による新規リグレッションはない。

## 新規パッチの単体検証（本変更固有）

### `fix-ears-plain-japanese.sh`
- 空のears-format.mdへの初回適用: マーカーブロックが1つ追記されることを確認
- 2回目適用（冪等性）: 「既存（スキップ）」となり、重複追記されないことを確認
- 実際のリポジトリ内`.claude/skills/kiro-spec-requirements/rules/ears-format.md`（既存内容あり）への
  適用: 既存コンテンツを破壊せず末尾に追記されることを確認

### `fix-plain-japanese-output.sh`
- 対象11スキル×`.claude`/`.agents`＝22ファイルへの初回適用: 全22ファイルにマーカーブロックが
  1つずつ追記されることを確認
- 2回目適用（冪等性）: 全22ファイルで「既存（スキップ）」となることを確認
- 実際のリポジトリ内SKILL.md（既存内容あり）への適用: 既存コンテンツを破壊せず末尾に追記される
  ことを確認

### `validate.sh`（postフェーズ）
- 上記2パッチを適用済みのスクラッチコピーに対して`validate.sh <root> payload post`を実行し、
  新設した24件のチェック項目（EARS-PLAIN-JA×2、PLAIN-JAPANESE-OUTPUT×22）がすべて`[OK]`に
  なることを確認

### `sync.sh`のMANAGED_BLOCKS登録
- 新規24エントリを追加。書式は既存エントリと同一（`target|marker|patch|script.sh`）
- 一般的な新規パッチ適用の回帰テストは`tests/integration/test_sync_new_patch.sh`が既存パッチで
  カバーしており、同一コードパスを通るため個別の追加テストは行っていない（構造的に同型のため）
