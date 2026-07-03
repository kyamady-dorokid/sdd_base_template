# 実行テスト記録: two-tier-deliverables

## PR1（タスク1〜5: ルール文書＋生成エンジン中核）

TDD（RED→GREEN）で実装。`bash tests/run.sh` で単体・結合を一括実行。

### 単体テスト（`tests/unit/`）
| テストファイル | 対象 | 件数 | 結果 |
|---|---|---|---|
| `test_doc_renderers.sh` | `renderers.sh`（フォーマット→レンダラ対応・PATH 可用性検出・本体非同梱） | 11 | PASS |
| `test_doc_manifest.sh` | `manifest.sh`（宣言パース・`@pii`・既定フォールバック） | 11 | PASS |
| `test_doc_slice.sh` | `slice.sh`（見出し節抽出・全文`*`・見出し不在で非0＋空生成しない） | 9 | PASS |

### 結合テスト（`tests/integration/`）
| テストファイル | 対象 | 件数 | 結果 |
|---|---|---|---|
| `test_doc_export.sh` | `export.sh`（未導入レンダラの明示スキップ＋後続継続、出力先分岐 PII/非PII の明示、見出し不在エラー、正本 md 不変） | 11 | PASS |

### 合計
- 新規 **42 件**、既存 63 件と合わせ **105 件 全 PASS**（`bash tests/run.sh` exit 0）。
- snippets パリティ（`CLAUDE.sdd.md` == `AGENTS.sdd.md`）IDENTICAL。

### 主な検証観点（決定事項との対応）
- **決定#1（一次=正本／二次=派生ビュー・一方向）**: export.sh は正本 md を読むのみ・書き換えないことを assert。
- **決定#2（outputs 使い分け＋明示メッセージ）**: `@pii` 宣言→`.kiro/specs/<id>/outputs/`、通常→直下 `outputs/<id>/`。
  レポートに出力先と PII 隔離の旨を明示。
- **決定#5（opt-in・欠落の明示）**: 未導入レンダラ（plantuml 等）を「未生成（要 install-renderers）」と明記し、
  他成果物の処理を継続。レンダラ本体は payload に同梱していないことを assert。
- **bash 3.2 互換**: `mapfile` 不使用（while-read で配列化）等を徹底。

### 残（PR2 以降）
- タスク6〜9（doc-export スキル配布・init/sync/validate 統合・CLI `install-renderers`）
- タスク10〜11（既存方針の保全・回帰・E2E・README）
