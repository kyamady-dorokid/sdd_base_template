---
name: sdd-init
description: Set up the SDD (Spec-Driven Development) base environment in the current repository. Use when the user asks to "build/initialize the SDD base", "SDD開発のベースを構築", "SDDベースを入れて", "set up spec-driven development", or to scaffold cc-sdd + the team's overlay (docs/sdd rules, CLAUDE.md/AGENTS.md SDD section, specs layout). Works for both Claude Code and Codex.
---

# sdd-init — SDD開発ベースの構築

現在のリポジトリに、**cc-sdd（Kiro風 Spec-Driven Development, MIT © 2025 gotalab）＋独自overlay**を展開する。
Claude Code / Codex のどちらでも同一の環境（`.claude/skills` と `.agents/skills`、`CLAUDE.md` と `AGENTS.md`）を生成する。

## 使うタイミング
- 「このリポジトリでSDD開発のベースを構築して」等の依頼。
- 新規/既存リポジトリにSDD運用（仕様→設計→タスク→TDD実装、合意記録、ブランチ/PR運用）を導入したいとき。

## 前提
- カレントが git リポジトリであること（無ければ `git init` を提案）。
- `node` / `npx` が利用可能であること（cc-sdd を取得するため）。

## 手順（エージェントはこの通り実行する）

1. **ペイロードの場所を解決する。**
   - このスキルディレクトリ直下の `payload/` を使う（インストール時に同梱される）。
     スキルディレクトリは通常 `~/.claude/skills/sdd-init` または `~/.codex/skills/sdd-init`。
   - `payload/scripts/init.sh` が存在すればそれを使用。
   - 見つからない場合のフォールバック: `npx -y github:kyamady-dorokid/sdd_base_template init --lang ja` を実行（同等処理）。

2. **init を実行する**（リポジトリのルートで）:
   ```bash
   bash "<このスキルのpayload>/scripts/init.sh" "$(git rev-parse --show-toplevel)" "<このスキルのpayload>" --lang ja
   ```
   init は内部で次を行う: `npx cc-sdd@latest` 取得 → **検証(pre)** → 既知パッチ適用 → **overlay適用** → **検証(post)**。

3. **検証結果を人間に必ず共有する。**
   - 検証(pre/post)で「要確認(NG)」が出た場合は、内容（特に Claude/Codex パリティの想定外差分、Codexパス誤り、cc-sddバージョン不一致）を要約して報告する。
   - **未知の不整合は自動で押し切らず、人間に確認を求める。**

4. **完了後の案内**:
   - `CLAUDE.md` / `AGENTS.md` の「## プロジェクト概要（要記入）」を埋めるよう促す。
   - 次アクション `/kiro-discovery "<やりたいこと>"` を案内。
   - コミットは自動で行わず、ブランチ→PR（main直コミット禁止）を案内。
   - 整合確認コマンド `diff -qr .claude/skills .agents/skills` を案内。

## 重要な注意
- **コミットはこのスキルでは行わない。** 生成後、人間がレビューしてコミットする。
- **パリティ厳守**: `.claude/skills` ⇄ `.agents/skills`、`CLAUDE.md` ⇄ `AGENTS.md` を常に同一に保つ。
- **ライセンス**: 本スキルは cc-sdd を *実行* するのみで再配布しない（MIT準拠）。
  将来 cc-sdd の生成物を payload に *同梱* する設計変更を行う場合は、MIT条項により
  ライセンス全文・著作権表示（© 2025 gotalab）の保持が必要になる旨を**ユーザーに必ず注意喚起する**。
