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

## PR2（タスク6〜9: 配布・統合）

### 実装
- doc-export スキル本体 `payload/overlay/skills/doc-export/SKILL.md`（エージェント向け手順）
- `init.sh` [5/6] に overlay skills 設置ステップ（`.claude`/`.agents` 双方・sync ガード付き）
- `sync.sh` に `managed_skills()`＋`sdd_apply_file()`（whole-file 3-way・両エージェント）
- `bin/cli.js` に `doc-export` / `install-renderers` サブコマンド、`install-renderers.sh`（opt-in 案内）
- `validate.sh`(post) に二層化検証、`checks.md` に H 節

### テスト・E2E
| 項目 | 結果 |
|---|---|
| `tests/run.sh` | **110件 全PASS**（PR1 105 + `test_sync_skills.sh` 5件） |
| 空リポジトリ init → doc-export スキル設置＋パリティ | `diff -qr` 差分ゼロ |
| `validate post` 二層化項目 | 全 OK |
| `sync` 初回化→再実行 | 作業ツリー差分ゼロ（収束・outputs 系は gitignore） |
| CLI `doc-export`（レンダラ未導入） | 「未生成（要 install-renderers）」を明示・正本不変 |
| CLI `install-renderers` | レンダラ状態と取得手順を案内（本体非同梱） |

### 設計中に判明した必要追加（記録）
- ターゲットリポジトリには `payload/scripts/` が展開されないため、doc-export の実行は**CLI サブコマンド経由**が必要。
  当初 tasks では `install-renderers` のみ想定だったが、`doc-export` サブコマンドも追加した（`bin/cli.js`）。
  スキル SKILL.md は `npx ... doc-export <id>` を案内する形に修正。

### 残（PR3）
- タスク10〜11（既存方針の保全・回帰の明文検証・E2E 記録・README）

## PR-α（タスク12〜17: doc-export 壁打ち A〜D の実装）

TDD（RED→GREEN）。`bash tests/run.sh` = **141件 全PASS**（PR2 の 110 + 新規/更新 31）。

| 項目 | 決定 | テスト |
|---|---|---|
| C-2 既定生成（manifest不在→requirements/design/tasks 各1本 docx） | C | `test_doc_manifest.sh`（既定=存在する主要3成果物・記録は対象外）／`test_doc_export.sh` Part2 |
| 導入コマンドレジストリ（DRY） | 導線 | `test_doc_renderers.sh`（`sdd_renderer_install_hint`） |
| Mermaid 前処理（mmdc 画像化／未導入は元コード残し未変換件数） | D-1a | `test_doc_mermaid.sh`（未導入=元コード残し2件・可用=画像参照差替え） |
| B-1b 終了コード3分類 | B | `test_doc_export.sh`（エラー含む→非0・未生成のみ→0・spec-id不在→1） |
| 具体導入コマンド提示（欠けたレンダラ固有） | 導線 | `test_doc_export.sh`（docx=pandoc/uml=plantuml の案内） |
| 対話導入（TTY時同意実行・非対話は提示のみ・自動導入しない） | 導線 | `test_install_renderers.sh`（非対話=提示のみ／y=DRYRUN で実導入せず／n=スキップ／手動のみは実行分岐に入らない） |
| doc-export CLI 契約（A1・引数・終了コード透過・manifest値誤除去バグ修正） | A1 | CLI 実行で exit 0/1 透過・`--manifest` 値誤除去なしを確認 |

**安全**: 実装・テスト中に実際の `npm i -g`／`brew install` は実行していない（対話 y 分岐は DRYRUN で検証）。

### 残（PR-β）
- タスク10（既存方針の保全・回帰）・タスク11（E2E 通し・README）
