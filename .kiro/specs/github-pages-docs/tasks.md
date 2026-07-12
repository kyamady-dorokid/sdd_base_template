# Implementation Plan: github-pages-docs（Tier S）

> 設定中心のため自動テストは追加しない。検証は実確認（tests/run.sh 非影響・sync 安全・Pages ビルド/URL）。
> 各ゲートで人間承認、自動コミットしない、ブランチ→PR。Pages 有効化は外部公開操作のため実行直前に確認。

- [x] 1. サイト設定ファイルの追加
- [x] 1.1 リポジトリ root に `_config.yml` を作成（theme: minima、plugins: jekyll-relative-links / jekyll-readme-index、
      defaults で layout 適用、exclude で payload/.kiro/tests/bin/scripts/skills/.agents/.claude/.codex/node_modules/
      package.json/AGENTS.md/CLAUDE.md を除外）
  - 観測可能な完了条件: `_config.yml` が YAML として妥当（`ruby -ryaml -e` 等でパース可）
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 3.2_

- [x] 2. README に公開サイトリンクを追加
- [x] 2.1 README 先頭付近に公開サイト（`https://kyamady-dorokid.github.io/sdd_base_template/`）への1行リンク/バッジを追記
  - _Requirements: 4.3_

- [x] 3. 非影響・sync 安全性の確認（マージ前）
- [x] 3.1 `docs/sdd/**` を無改変であることを確認（`git diff` に docs/sdd の変更が無い）
  - _Requirements: 2.1, 2.2, 2.3_
- [x] 3.2 `bash tests/run.sh` が全 PASS（145件維持・bash ロジック非変更）
  - _Requirements: —（回帰）_
- [x] 3.3 `node bin/cli.js sync --yes` 後に docs/sdd の差分・コンフリクトが生じないこと（`_config.yml` は sync 非対象）
  - _Requirements: 2.2_

- [ ] 4. コミット・PR（人間承認で実行）
- [ ] 4.1 `_config.yml`・README 変更・spec 記録をコミット提案 → 承認後コミット・push・PR

- [ ] 5. Pages 有効化と検証（PR マージ後・外部公開操作は直前確認）
- [ ] 5.1 `gh api` で Pages 有効化（source=main / path=/）
  - _Requirements: 4.1_
- [ ] 5.2 ビルド状態 `built` を確認し、公開 URL でトップ(README)・`docs/sdd` 代表ページ・相対リンク解決を検証
  - _Requirements: 1.1, 1.2, 1.3, 3.1, 3.3, 4.2_
- [ ] 5.3 `test-results.md` に検証結果を記録。README が index にならない等の問題時はフォールバック（最小 `index.md`）を検討
  - _Requirements: 4.2_
