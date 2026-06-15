# 検証チェックリスト（cc-sdd 取得後・overlay 適用前/後）

`init` が自動実行する検証項目。`validate.sh` の根拠ドキュメント。

## A. 構造存在チェック（cc-sdd 取得直後）
- [ ] `.kiro/settings/` が存在
- [ ] `.claude/skills/` に `kiro-*` スキルが存在
- [ ] `.agents/skills/` に `kiro-*` スキルが存在
- [ ] `CLAUDE.md` が存在
- [ ] `AGENTS.md` が存在

## B. Claude / Codex 構造パリティ
- 注: cc-sdd は Claude(`/kiro`)と Codex(`$kiro`・`agents/`)で内容を意図的に変えて生成する。
  **内容のバイト一致は検証しない**。
- [ ] `.claude/skills` と `.agents/skills` に**同じスキル名集合**が存在する
- [ ] 片側のみ存在するスキルは `known-parity-diffs.txt` の許容リスト内に収まる
- [ ] 想定外の片側欠落があれば**停止して人間に報告**

## C. Codex パス健全性（既知バグ対策）
- [ ] `.agents/` 配下のファイルに `.claude/` への参照が混入していない
- [ ] `AGENTS.md` 内のパス参照が `.agents/` 系で正しい（`.claude/` 固定参照の誤りがない）
- [ ] 検出時は `patches/` の対応パッチを自動適用し、再チェック

## D. バージョン整合
- [ ] 取得した cc-sdd のバージョンを記録
- [ ] `KNOWN_GOOD_CCSDD_VERSION` と一致するか確認
- [ ] 不一致（新版）の場合は **追加検査＋人間確認**（破壊的変更の可能性を警告）

## E. overlay 適用後の再検証
- [ ] `CLAUDE.md` / `AGENTS.md` に `<!-- SDD-BASE:START -->`〜`END` ブロックが1つだけ存在（重複挿入なし）
- [ ] `docs/sdd/` 一式が存在
- [ ] `.gitignore` に SDD base スニペットが追記済み
- [ ] `docs/sdd/` 内のリンク切れがない

## F. ライセンス注意（設計変更時のゲート）
- [ ] **cc-sdd の生成物をテンプレ（payload）へ同梱する設計変更を行う場合**、MIT条項により
      ライセンス全文・著作権表示（`Copyright (c) 2025 gotalab`）の保持が必要であることを
      ユーザーに注意喚起する。（現設計は npx 実行のみで同梱しないため不要）
