# sdd_base_template — メンテナンス規約（このリポジトリ独自ルール）

このリポジトリは「SDDベースを他リポジトリへ展開するインストーラ/スキル」を管理する。
編集時は以下を守ること（`AGENTS.md` と本ファイルは常に同一内容に保つ）。

## 必須ルール

1. **Claude / Codex パリティを壊さない。**
   - 配布スキルは `~/.claude/skills/sdd-init` と `~/.codex/skills/sdd-init` の両方へ同一設置される前提。
   - overlay の `snippets/CLAUDE.sdd.md` と `snippets/AGENTS.sdd.md` は同一内容に保つ。
   - この規約ファイル `CLAUDE.md` と `AGENTS.md` も同一に保つ。

2. **cc-sdd は実行のみ・再配布しない（現設計）。**
   - `init` は `npx cc-sdd@latest` で取得する。cc-sdd のソース/生成物を `payload/` に置かない。

3. **⚠️ ライセンス注意喚起ルール（重要）。**
   - **将来 cc-sdd の生成物（`.kiro`/`.claude`/`.agents` の kiro スキル等）を `payload/` に同梱する設計案が出た場合**、
     MIT ライセンス条項により **ライセンス全文と著作権表示（`Copyright (c) 2025 gotalab`）の保持が必要**になる。
   - その設計変更を検討・実装する際は、**必ずユーザーにこの点を注意喚起**してから進めること。
   - 同梱する場合は `payload/` に cc-sdd の `LICENSE` を含め、`README` / `NOTICE` に出典を明記する。

4. **cc-sdd バージョン管理。**
   - 検証済みバージョンは `payload/KNOWN_GOOD_CCSDD_VERSION` にピン。
   - cc-sdd 新版で検証が通ったら、`validation/`（特に `patches/`・`known-parity-diffs.txt`）と
     `KNOWN_GOOD_CCSDD_VERSION` を更新する。

5. **謝辞・出典の明記を維持する。**
   - `README.md` の cc-sdd 謝辞（MIT, © 2025 gotalab）を削除しない。

6. **`main` への直接コミット禁止。** ブランチ→PR で反映する。

7. **`payload/scripts/` のテスト資産はリポジトリ直下 `tests/` に置き、単体/結合で分ける。**
   - `payload/` は `install`（`buildSkillBundle`）と `package.json` の `files` により丸ごと配布されるため、
     `init.sh`/`sync.sh`/`validate.sh` が実行時に参照しないテストコードを `payload/` 配下に置かない
     （`scripts/install.sh` と同じく、開発者専用資産は `payload/` の外＝リポジトリ直下に置く）。
   - `.kiro/specs/<id>/` は `docs/sdd/workflow.md` が定めるプロセス記録専用の場所（`agreement-log.md`等）
     であり、実行コードの置き場ではない。`payload/scripts/` のコードは特定タスクに紐づかない永続的な
     プロダクトコードのため、そのテストも特定の spec フォルダではなく `tests/` に置く。
   - `tests/unit/`（外部副作用を持たない純粋ロジック）と `tests/integration/`（`sync.sh` 等を実際に
     起動するエンドツーエンドのテスト）にディレクトリを分ける。
   - テストランナー: `bash tests/run.sh`（`tests/unit/` → `tests/integration/` の順に実行、集計）。

## 動作確認
- 変更後は空ディレクトリで `node bin/cli.js init` を実行し、検証(pre/post)が通ることを確認。
- `install` 後に `diff -qr ~/.claude/skills/sdd-init ~/.codex/skills/sdd-init` で設置物の同一性を確認。
- `payload/scripts/` を変更した場合は `bash tests/run.sh` で単体・結合テストが全て PASS することを確認。

<!-- SDD-BASE:START (このブロックは sdd_base_template が管理。手動編集は再生成で上書きされる可能性あり) -->
## SDD 開発の進め方（このリポジトリの基本ルール）

本リポジトリは **cc-sdd（Kiro 風 Spec-Driven Development）** をベースに、独自の運用ルールを重ねて開発する。
始め方は **自然言語SDD（軽量）** と **kiroコマンドSDD（フルフロー）** の2入口があり、**どちらでも適用ルール・
成果物・出力先は同一**（変わるのは規模で選ぶ Tier だけ）。詳細フロー・Tierは [docs/sdd/workflow.md](docs/sdd/workflow.md) を参照。

### 必ず守ること（入口に依らず共通）
1. ドキュメント完成後、いきなり実装しない。**人間の承認**を得てから実装を開始する。
2. 単体テストは実装とセット。**TDD（テスト先行）** で進める。
3. **コミットは自動で行わない。** 区切りで推奨提示し、人間が判断・実行する（希望時は自動コミットへ切替可）。
4. 1タスクの記録は **`.kiro/specs/<id>/` に集約**する（`docs/specs/` は使わない）。合意は `agreement-log.md`、承認状態の正本は `spec.json`。
5. 技術要件は独立ファイルにせず `design.md` の「技術要件・制約チェック」節で確認する。
6. 実行テスト結果は `.kiro/specs/<id>/test-results.md` に記録する。
7. 結合試験項目は `.kiro/specs/<id>/integration-test-checklist.md` に残す。
8. **`main` への直接コミット禁止。** ブランチ→push→PR。詳細は [docs/sdd/rules/branching-policy.md](docs/sdd/rules/branching-policy.md)。

### ベースルールの所在
- ワークフロー: [docs/sdd/workflow.md](docs/sdd/workflow.md)
- テスト方針: [docs/sdd/rules/testing-policy.md](docs/sdd/rules/testing-policy.md)
- コミット方針: [docs/sdd/rules/commit-policy.md](docs/sdd/rules/commit-policy.md)
- ブランチ方針: [docs/sdd/rules/branching-policy.md](docs/sdd/rules/branching-policy.md)
- 各テンプレート: [docs/sdd/templates/](docs/sdd/templates/)

### エージェント整合
- `kiro-*` スキルや運用ルールを更新する場合、`.claude/skills/` と `.agents/skills/` を同一変更で揃える。
- 開発ルールを変える場合、`CLAUDE.md` と `AGENTS.md` を同一変更で揃える。
- 整合確認: `diff -qr .claude/skills .agents/skills`

### このSDD基盤について
- 基盤は `sdd_base_template`（npx インストーラ）で展開され、内部で `cc-sdd`（MIT, © 2025 gotalab）を利用している。
<!-- SDD-BASE:END -->

<!-- SDD-BASE:PROJECT-OVERVIEW:START (要記入。このプレースホルダを各リポジトリの実情に合わせて埋めること) -->
## プロジェクト概要（要記入）

> このセクションは `sdd_base_template` が用意したプレースホルダです。リポジトリ固有の情報に置き換えてください。

- **このリポジトリは何か**: {{プロダクト/システムの概要}}
- **技術スタック**: {{言語 / フレームワーク / データストア / インフラ}}
- **主要コンポーネント**: {{コンポーネント構成}}
- **ローカル開発環境の起動**: {{セットアップ・起動手順、または docs/architecture/ への参照}}
- **アクセス先 / ポート**: {{開発環境のURL・ポート等}}

> 把握情報は `docs/architecture/`（任意作成）にまとめ、ここから参照する運用を推奨。
<!-- SDD-BASE:PROJECT-OVERVIEW:END -->
