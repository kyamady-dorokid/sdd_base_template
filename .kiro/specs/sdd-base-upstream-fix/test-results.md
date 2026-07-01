# 実行テスト記録: sdd-base-upstream-fix

## PR-1（Part A + Part C）動作確認

対象コミット: ブランチ `feat/sdd-upstream-fix-part-ac`
検証方法: 空の git リポジトリで `node bin/cli.js init --lang ja --yes` を実行し、pre/post 検証を確認。

### 実装内容と検証結果

| 項目 | 実装 | 検証 |
|---|---|---|
| A1: workflow.md「非コーディング作業のドキュメント化」節 | `payload/overlay/docs/sdd/workflow.md` に追加（`.kiro/specs/<id>/` 一元化前提に統合、二重レイアウト文言除去） | post検証 `[OK] workflow.md に非コーディング節あり` |
| A2: security-policy.md（汎用化） | `payload/overlay/docs/sdd/rules/security-policy.md` を新規追加（`MYSQL_*`/`cyclox2_mysql` → `DB_PASSWORD`/`<db_container>` 等に汎用化） | post検証 `[OK] security-policy.md 展開済み`／展開物に `cyclox`/`MYSQL_ROOT_PASSWORD`/`MYSQL_PWD` **残存なし** |
| A2: snippet リンク（パリティ） | `CLAUDE.sdd.md`/`AGENTS.sdd.md` の「ベースルールの所在」に同一リンク追加 | `diff -q CLAUDE.sdd.md AGENTS.sdd.md` = IDENTICAL |
| A3: cc-sdd バージョン | `KNOWN_GOOD_CCSDD_VERSION` = `3.0.2`（変更なし） | pre検証 `[OK] cc-sdd 3.0.2 (=KNOWN_GOOD)` |
| C-Layer1: agreement-log 実在の補強 | 同 workflow 節に「`agreement-log.md` はファイルとして実在させる」旨を明記 | 上記 workflow 節チェックに包含 |
| C-Layer2: ensure-agreement-log.sh パッチ | `payload/validation/patches/ensure-agreement-log.sh` 新規。`kiro-spec-init/SKILL.md`（`.claude`/`.agents` 両方）に `SDD-OVERLAY:ENSURE-AGREEMENT-LOG` を冪等注入 | post検証 両系 `[OK] ... ENSURE-AGREEMENT-LOG 注入済み` |
| 検証拡張 | `checks.md` C2/E に項目追加、`validate.sh` post に自動チェック追加 | 下記 PASS に反映 |

### 検証ログ要点

- **pre 検証**: `==> 検証 PASS`（構造パリティ 17スキル一致 / Codexパス健全 / cc-sdd 3.0.2）
- **パッチ適用**: `ensure-agreement-log.sh` → 両 `kiro-spec-init/SKILL.md` に追記。既存2パッチも適用。
- **post 検証**: `==> 検証 PASS`（新規項目 security-policy / 非コーディング節 / ENSURE-AGREEMENT-LOG×2 すべて `[OK]`）
- **冪等性**: 同一ディレクトリで再 `init` 実行 → マーカー重複注入なし（`SDD-OVERLAY:ENSURE-AGREEMENT-LOG:START` の出現数 = 各1）
- **パリティ**: 展開先の `.claude/skills` と `.agents/skills` のスキル名集合が一致

### 結論

PR-1 の Part A / Part C は空リポジトリでの init で pre/post 検証 PASS・冪等・汎用化を満たすことを確認。
Part B（`sync` 機構）は本PRのスコープ外（別PRで requirements/design/tasks フルフロー）。
