# sdd_base_template

任意のリポジトリに **SDD（Spec-Driven Development）開発ベース**をワンステップで展開するための
インストーラ兼スキル配布リポジトリ。Claude Code / Codex の両方で同一の環境を構築する。

内部で **[cc-sdd](https://github.com/gotalab/cc-sdd)** を実行し、その上に独自の運用 overlay
（`docs/sdd/` のルール・テンプレート、`CLAUDE.md`/`AGENTS.md` のSDD節、specs配置）を重ねる。

## クイックスタート

### 1) 個人環境にスキルを設置（初回ワンライナー）
```bash
npx -y github:kyamady-dorokid/sdd_base_template install
```
`~/.claude/skills/sdd-init` と `~/.codex/skills/sdd-init` に自己完結のスキルを設置する。
以後は各エージェントで「**このリポジトリでSDD開発のベースを構築して**」と依頼すれば発火する。

### 2) 単発でリポジトリに展開（スキル登録なし）
```bash
cd <target-repo>
npx -y github:kyamady-dorokid/sdd_base_template init --lang ja
```

### 3) clone 運用（symlinkで自動更新したい場合）
```bash
git clone git@github.com:kyamady-dorokid/sdd_base_template.git
cd sdd_base_template && ./scripts/install.sh --link   # git pull で全環境に即反映
```

## サブコマンド
| コマンド | 内容 |
|---|---|
| `install [--copy\|--link]` | スキルを個人環境へ設置（既定=copy） |
| `init [--lang ja] [--yes]` | 現リポジトリに SDD ベースを展開 |
| `validate [pre\|post]` | 検証のみ |
| `update` | （clone運用）`git pull` |

## init の流れ
`npx cc-sdd@latest` 取得 → **検証(pre)**（構造・Claude/Codexパリティ・Codexパス誤り・version照合）
→ 既知パッチ適用 → **overlay適用**（冪等・マーカー方式）→ **検証(post)** → レポート。

## ディレクトリ
```
payload/        target へ展開する本体（overlay / validation / scripts / KNOWN_GOOD_CCSDD_VERSION）
skills/sdd-init/ スキル定義（install で個人環境へ、payload同梱で自己完結）
bin/cli.js      npx エントリ（install/init/validate/update）
scripts/        clone運用向けラッパ
```

## ライセンス / 謝辞
- 本リポジトリ: MIT。
- **ランタイム依存: [cc-sdd](https://github.com/gotalab/cc-sdd) — MIT License, © 2025 gotalab。**
  本ツールは cc-sdd を *実行* するのみで、そのソース/生成物を再配布・同梱しない。
- ⚠️ 将来 cc-sdd の生成物を `payload/` へ *同梱* する設計に変更する場合は、MIT条項により
  ライセンス全文・著作権表示の保持が必要。設計変更時はこの点をユーザーへ注意喚起すること
  （`payload/validation/checks.md` F項、および本リポジトリの `CLAUDE.md`/`AGENTS.md` を参照）。
