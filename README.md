# sdd_base_template

任意のリポジトリに **SDD（Spec-Driven Development）開発ベース**をワンステップで展開するための
インストーラ兼スキル配布リポジトリ。Claude Code / Codex の両方で同一の環境を構築する。

内部で **[cc-sdd](https://github.com/gotalab/cc-sdd)** を実行し、その上に独自の運用 overlay
（`docs/sdd/` のルール・テンプレート、`CLAUDE.md`/`AGENTS.md` のSDD節、specs配置）を重ねる。

## クイックスタート

> **前提:** 対象は **git リポジトリ**であること（`git init` 済み）。リモートは不要・ローカルのみで可。
> 未初期化のディレクトリでは `init` がエラーになり `git init` を促す。

### 1) 単発でリポジトリに展開（スキル登録なし）

**新規開発をはじめる場合** — ディレクトリ作成 → `git init` → 展開:
```bash
mkdir <project> && cd <project>
git init
npx -y github:kyamady-dorokid/sdd_base_template init
```

**既存リポジトリに追加する場合** — リポジトリ内で展開コマンドのみ:
```bash
cd <existing-repo>
npx -y github:kyamady-dorokid/sdd_base_template init
```

実行すると **Claude Code と Codex の両環境**（`.claude/` `.agents/`、各 `CLAUDE.md`/`AGENTS.md`、`docs/sdd/`）が
**まとめて自動構築**される。利用エージェントを選ぶ対話メニューはなく、両方が同時に入る
（言語は既定 `ja`。変更時は `init --lang en` のように指定）。

### 2) 個人環境にスキルを設置（初回ワンライナー）
```bash
npx -y github:kyamady-dorokid/sdd_base_template install
```
`~/.claude/skills/sdd-init` と `~/.codex/skills/sdd-init` に自己完結のスキルを設置する。

**1) との違い:** 1) は展開のたびに npx コマンドが必要。こちらは**一度設置すれば、次回以降は各エージェントに
「このリポジトリでSDD開発のベースを構築して」と指示するだけで構築が発火する**（npx 不要）。

### 3) clone 運用（symlinkで自動更新したい場合）
```bash
git clone git@github.com:kyamady-dorokid/sdd_base_template.git
cd sdd_base_template && ./scripts/install.sh --link   # git pull で全環境に即反映
```

### 構築後の最初の一歩
SDD ベース構築後、Claude Code（または Codex）を起動したら、まず**適用される SDD ルールと開発の進め方**を確認する:
```
このリポジトリに適用されているSDDのルールと、これからの開発の進め方を教えて
```

## 開発の進め方（2つの入口・同一パイプライン）

開発の始め方は2通りありますが、**どちらも同じ1本のSDDパイプラインを通り、適用ルール・成果物・
出力先（`.kiro/specs/<id>/`）は完全に同一**です。違うのは「人間がコマンドを打つか／エージェントに任せるか」だけ。

| 入口 | 始め方 | 向き |
|---|---|---|
| **軽量（自然言語SDD）** | `<やりたいこと>。簡単な要件定義とプランニングから始めて` と会話で指示。スラッシュコマンド不要 | 小〜中規模 |
| **フルフロー（kiroコマンドSDD）** | `/kiro-discovery "<やりたいこと>"` → `/kiro-spec-*` → `/kiro-impl` を明示実行 | 中〜大規模 |

- **どちらの入口でも共通必須**: 人間の承認ゲート / TDD（テスト先行） / 自動コミットしない（区切りで提案） /
  `main` 直コミット禁止・ブランチ→PR / 1タスクの記録は `.kiro/specs/<id>/` に集約。
- 入口で振る舞いは変えない。変えてよいのは**規模で選ぶ Tier（S=小 / L=中〜大）**だけ。
- 詳細フロー・Tier 定義・ディレクトリ構成は、展開先の [`docs/sdd/workflow.md`](payload/overlay/docs/sdd/workflow.md) を参照。

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
