# 実行テスト記録: sync-gitignore-wholeline

## 単体・結合テスト
- `tests/integration/test_sync_gitignore.sh`（新規）: 部分一致衝突（`.kiro/specs/*/outputs/` 先在時に `outputs/`）で
  `outputs/` が独立行として追記されること、既存行は重複しないこと、再sync で冪等であることを検証。
- 修正前 RED（`outputs/` 誤スキップ＝0件）→ 修正後 GREEN。
- `bash tests/run.sh` = **145件 全PASS**（従来141 + 新規4）。

## E2E（実 CLI）
- 空リポジトリで `init`（新規）→ `.gitignore` にスニペット全体が入り `outputs/` を含む（init 側は回帰なし）。
- init 済みリポジトリで `sync` → 既存 `.kiro/specs/*/outputs/` があっても `outputs/` が独立行で追記される。
