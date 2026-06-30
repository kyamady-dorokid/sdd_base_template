# 仕様・設計: 環境越境ポリシー（Windows×WSL）

タスクID: `env-boundary-policy` / 2026-06-20 / 対象: `sdd_base_template`

## 要件（EARS）
- R1: 実行環境が Windows **かつ** 作業対象ディレクトリが WSL パス（`\\wsl.localhost\...` / `\\wsl$\...`）のとき、システムは越境警告を提示しなければならない。
- R2: 警告は、そのセッションで最初の自動操作（ファイル変更・コマンド実行等）を行う**直前に1回だけ**提示しなければならない。
- R3: 警告は (a)差分懸念の説明、(b)WSL内ターミナルから `claude` を起動し同ディレクトリで作業する回避策、(c)このまま Windows 側で続行してよいかの確認、を含まなければならない。
- R4: Windows ネイティブ（WSL越境でない）や非Windows環境では警告を提示してはならない。
- R5: 本ルールは環境非依存のベースルール層（`docs/sdd/`）として全リポジトリへ配布されなければならない。

## 設計（A方式・B反映）
1. **新規ルール文書**: `payload/overlay/docs/sdd/rules/environment-boundary-policy.md`
   - トリガー条件 / タイミング / 警告内容 / 確認 / 限界（自己追跡）を記述。警告文言ドラフトを掲載。
2. **SDD-BASE スニペット更新**（`payload/overlay/snippets/CLAUDE.sdd.md` と `AGENTS.sdd.md` を同一変更）:
   - 「ベースルールの所在」リストに `environment-boundary-policy.md` への参照を追加（B-参照）。
   - 「必ず守ること」に**発火指示1行**を追加（B-発火）: 越境時はセッション初回操作前に1回警告し続行可否を確認する旨。
3. 配布経路は既存どおり（`init` の overlay 適用で各リポジトリの `docs/sdd/` と CLAUDE/AGENTS に反映）。新規ファイルは `cp -R overlay/docs/sdd` で自動的に含まれる。

## 受け入れ基準
- [ ] `payload/overlay/docs/sdd/rules/environment-boundary-policy.md` が存在し、R1–R4 を記述。
- [ ] `CLAUDE.sdd.md` / `AGENTS.sdd.md` に参照＋発火指示が**同一**に入っている。
- [ ] 参照リンクのパス（`docs/sdd/rules/environment-boundary-policy.md`）が配布後に有効（リンク切れなし）。
- [ ] 既存の検証（構造・パリティ）に悪影響がない。

## タスク
- [ ] T1: `environment-boundary-policy.md` 作成
- [ ] T2: `CLAUDE.sdd.md` / `AGENTS.sdd.md` に参照＋発火指示を同期追加
- [ ] T3: 同期・リンク確認（`diff` でスニペット一致、配布パス検証）
- [ ] T4: コミット提案（人間承認）→ push → PR
