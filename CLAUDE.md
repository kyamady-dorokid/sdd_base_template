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

## 動作確認
- 変更後は空ディレクトリで `node bin/cli.js init` を実行し、検証(pre/post)が通ることを確認。
- `install` 後に `diff -qr ~/.claude/skills/sdd-init ~/.codex/skills/sdd-init` で設置物の同一性を確認。
