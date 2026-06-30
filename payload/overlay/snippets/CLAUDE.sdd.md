<!-- SDD-BASE:START (このブロックは sdd_base_template が管理。手動編集は再生成で上書きされる可能性あり) -->
## SDD 開発の進め方（このリポジトリの基本ルール）

本リポジトリは **cc-sdd（Kiro 風 Spec-Driven Development）** をベースに、独自の運用ルールを重ねて開発する。
詳細フローは [docs/sdd/workflow.md](docs/sdd/workflow.md) を参照。

### 必ず守ること
1. ドキュメント完成後、いきなり実装しない。**人間の承認**を得てから実装を開始する。
2. 単体テストは実装とセット。**TDD（テスト先行）** で進める。
3. **コミットは自動で行わない。** 区切りで推奨提示し、人間が判断・実行する（希望時は自動コミットへ切替可）。
4. 合意内容は `docs/specs/<task-id>/agreement-log.md` に必ず記録する。
5. 初回実装時は `docs/specs/<task-id>/tech-requirements.md` で技術要件を確認する。
6. 実行テスト結果は `docs/specs/<task-id>/test-results.md` に記録する。
7. 結合試験項目は `docs/specs/<task-id>/integration-test-checklist.md` に残す。
8. **`main` への直接コミット禁止。** ブランチ→push→PR。詳細は [docs/sdd/rules/branching-policy.md](docs/sdd/rules/branching-policy.md)。
9. **環境越境（Windows × WSL）の確認。** 実行環境が Windows で、かつ作業対象が WSL パス（`\\wsl.localhost\...` / `\\wsl$\...`）の場合は、**そのセッションで最初の自動操作を行う直前に1回だけ**、差分懸念の警告と「WSL内ターミナルから `claude` を起動して作業する」回避策を提示し、このまま続行してよいか確認する。詳細は [docs/sdd/rules/environment-boundary-policy.md](docs/sdd/rules/environment-boundary-policy.md)。（越境でない／非Windowsでは何もしない）

### ベースルールの所在
- ワークフロー: [docs/sdd/workflow.md](docs/sdd/workflow.md)
- テスト方針: [docs/sdd/rules/testing-policy.md](docs/sdd/rules/testing-policy.md)
- コミット方針: [docs/sdd/rules/commit-policy.md](docs/sdd/rules/commit-policy.md)
- ブランチ方針: [docs/sdd/rules/branching-policy.md](docs/sdd/rules/branching-policy.md)
- 環境越境ポリシー（Windows×WSL）: [docs/sdd/rules/environment-boundary-policy.md](docs/sdd/rules/environment-boundary-policy.md)
- 各テンプレート: [docs/sdd/templates/](docs/sdd/templates/)

### エージェント整合
- `kiro-*` スキルや運用ルールを更新する場合、`.claude/skills/` と `.agents/skills/` を同一変更で揃える。
- 開発ルールを変える場合、`CLAUDE.md` と `AGENTS.md` を同一変更で揃える。
- 整合確認: `diff -qr .claude/skills .agents/skills`

### このSDD基盤について
- 基盤は `sdd_base_template`（npx インストーラ）で展開され、内部で `cc-sdd`（MIT, © 2025 gotalab）を利用している。
<!-- SDD-BASE:END -->
