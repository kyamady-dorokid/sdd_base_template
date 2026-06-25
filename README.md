# sdd_base_template

任意のリポジトリに **SDD（Spec-Driven Development）開発ベース** をワンステップで展開するための、インストーラ兼スキル配布リポジトリです。

Claude Code / Codex の両方で同一の環境を構築します。内部で **[cc-sdd](https://github.com/gotalab/cc-sdd)** を実行し、その上に独自の運用 overlay（`docs/sdd/` のルール・テンプレート、`CLAUDE.md`/`AGENTS.md` のSDD節、specs配置）を重ねます。

<br>

## クイックスタート

> **前提:** 対象は **git リポジトリ**であること（`git init` 済み）。リモートは不要で、ローカルのみで構いません。未初期化のディレクトリでは `init` がエラーになり `git init` を促します。

<br>

### STEP 1 — リポジトリに展開する（まずはこれだけでOK）

基本はこの 1 コマンドだけです。**新規・既存どちらのリポジトリでも同じ**コマンドで展開できます。

**新規開発をはじめる場合:**

```bash
mkdir <project> && cd <project>
git init
npx -y github:kyamady-dorokid/sdd_base_template init
```

**既存リポジトリに追加する場合:**

```bash
cd <existing-repo>
npx -y github:kyamady-dorokid/sdd_base_template init
```

実行すると、**Claude Code と Codex の両環境**（`.claude/` `.agents/`、各 `CLAUDE.md`/`AGENTS.md`、`docs/sdd/`）が**まとめて自動構築**されます。利用エージェントを選ぶ対話メニューはなく、両方が同時に入ります（言語は既定 `ja`。変更時は `init --lang en`）。

> **既に CLAUDE.md / AGENTS.md などがある場合:** 勝手には進めず、展開時に必ず**扱いを確認**します（既定は **「対比して上書き」＝差分を表示し、`.sdd-backup/` にバックアップを取ってから上書き**）。「上書き / 温存（マージ）/ 差分のみ」から選べます（詳しくは末尾の[コマンド・オプション](#コマンドオプション)）。`.kiro/specs/`・`.kiro/steering/` のあなたのドキュメントは**どの選択でも初期化されません**。

<br>

### STEP 2 — スキルを個人環境に入れておく（任意・次回から便利）

やっておくと、**次回以降は npx コマンドすら不要**になります。一度だけ実行してください。

```bash
npx -y github:kyamady-dorokid/sdd_base_template install
```

`~/.claude/skills/sdd-init` と `~/.codex/skills/sdd-init` に自己完結のスキルが設置されます。

これ以降は、新しいリポジトリで各エージェントに

```
このリポジトリでSDD開発のベースを構築して
```

と指示するだけで、STEP 1 と同じ構築が発火します（npx 不要）。

<br>

### 構築後の最初の一歩

SDD ベース構築後、Claude Code（または Codex）を起動したら、まず**適用される SDD ルールと開発の進め方**を確認します。

```
このリポジトリに適用されているSDDのルールと、これからの開発の進め方を教えて
```

<br>

## 開発の進め方（2つの入口・同一パイプライン）

開発の始め方は 2 通りありますが、**どちらも同じ 1 本の SDD パイプラインを通り、適用ルール・成果物・出力先（`.kiro/specs/<id>/`）は完全に同一**です。違うのは「人間がコマンドを打つか／エージェントに任せるか」と、規模で選ぶ **Tier（S=小 / L=中〜大）** だけです。

どちらの入口でも、**人間は下のステップを上から順に入力していけば進みます。**

<br>

### 軽量（自然言語SDD）— 小〜中規模向け

スラッシュコマンドは不要。会話で進めます。

1. **着手** — そのまま指示します:
   > `<やりたいこと>。簡単な要件定義とプランニングから始めて`
2. **要件・設計・タスクの確認** — エージェントが要件／設計／タスクを提示します。内容を確認し、合意できたら:
   > `この方針でOK。実装を進めて`
   （直したい点があれば、その場で指摘 → 反映、を繰り返す）
3. **実装とテスト** — エージェントが TDD（テスト先行）で実装し、テスト結果を提示します。確認して問題なければ:
   > `結合試験チェックリストを出して`（人間が手動確認）
4. **コミット** — 区切りでエージェントがコミットを提案します。内容を確認して:
   > `この内容でコミットして`（`main` 直コミットはせず、ブランチ → PR）

<br>

### フルフロー（kiroコマンドSDD）— 中〜大規模向け

各フェーズを `/kiro-*` コマンドで明示的に進めます。

1. **把握・振り分け** — `/kiro-discovery "<やりたいこと>"`
2. **要件定義** — `/kiro-spec-requirements <id>` → 提示をレビューし、合意したら `承認` と伝える
3. **設計** — `/kiro-spec-design <id>` → レビュー → `承認`
4. **タスク分解** — `/kiro-spec-tasks <id>` → レビュー → `承認`（ここで「実装を進めて」の確認）
5. **実装（TDD）** — `/kiro-impl <id>`（独立レビュー付き。`main` 直コミットはせず提案）
6. **結合試験** — `.kiro/specs/<id>/integration-test-checklist.md` を人間が確認
7. **コミット** — エージェントの提案を確認してコミット（ブランチ → PR）

<br>

> **共通（どちらの入口でも必須）:** 人間の承認ゲート / TDD（テスト先行） / 自動コミットしない（区切りで提案・人間が実行） / `main` 直コミット禁止・ブランチ → PR / 1タスクの記録は `.kiro/specs/<id>/` に集約。
>
> 詳細フロー・Tier 定義・ディレクトリ構成は、展開先の [`docs/sdd/workflow.md`](payload/overlay/docs/sdd/workflow.md) を参照してください。

<br>

## その他の使い方

クイックスタート以外の使い方です。

<br>

### 既存環境への展開を指定する

すでに `CLAUDE.md` などがあるリポジトリに `init` すると、**勝手には進まず扱いを確認**します（端末では対話、非対話では明示が必要）。自動化やCIでは扱いを明示します。

```bash
npx -y github:kyamady-dorokid/sdd_base_template init --on-existing=overwrite   # 対比して上書き（バックアップ取得・既定）
npx -y github:kyamady-dorokid/sdd_base_template init --on-existing=keep        # 既存を温存（マージ）
npx -y github:kyamady-dorokid/sdd_base_template init --on-existing=compare     # 差分の表示のみ（インストールしない）
```

<br>

### 🛠 開発者向け機能

以下は、このテンプレート（`sdd_base_template`）自体をメンテ・改修する人向けです。通常の利用では不要です。

<br>

**展開結果を検証だけする — `validate`**

`init` を再実行せず、現在の展開状態だけを点検します。展開後に手で何かを変えてしまった時の健全性チェックに使います。

```bash
npx -y github:kyamady-dorokid/sdd_base_template validate post
```

- `validate pre` … cc-sdd 生成物の**構造・Claude/Codexパリティ・Codexパス誤り・cc-sddバージョン整合**を確認
- `validate post` … **overlay 適用結果**（SDD節の重複なし・`docs/sdd/`・`.gitignore`・独自パッチ注入・記録レイアウト）を確認

<br>

**テンプレートを編集しながら全環境へ即反映 — `install --link` / `update`**

テンプレートを clone して改修する開発者向けの運用です。スキルを **symlink** で個人環境に繋ぐと、`git pull` するだけで `~/.claude` と `~/.codex` の両方へ即反映されます（コピーし直し不要）。

```bash
git clone git@github.com:kyamady-dorokid/sdd_base_template.git
cd sdd_base_template
./scripts/install.sh --link    # ~/.claude/skills/sdd-init, ~/.codex/skills/sdd-init を clone元へ symlink

# …テンプレートを編集 / リモート更新を取り込む…
npx github:kyamady-dorokid/sdd_base_template update   # clone元で git pull --ff-only（symlink経由で全環境へ反映）
```

- 通常の `install`（既定 `--copy`）はスキルの中身を**コピー**するため、更新には `install` の再実行が必要です。
- `install --link` は**symlink**なので clone元の変更が即反映され、`update`（=`git pull`）と組み合わせて使います。

<br>

## コマンド・オプション

| コマンド | オプション | 既定 | 説明 |
|---|---|---|---|
| `init` | `--lang <ja\|en>` | `ja` | 生成ドキュメントの言語 |
| | `--on-existing <overwrite\|keep\|compare>` | `overwrite` | 既存 `CLAUDE.md`/`AGENTS.md` 等がある場合の扱い。`overwrite`=対比して上書き（バックアップ取得）／`keep`=温存（マージ）／`compare`=差分のみ（インストールしない） |
| | `--yes`, `-y` | off | 確認注記を抑止（非対話）。**既存環境がある場合は `--on-existing` の明示が必須**（無ければ安全のため停止） |
| `install` | `--copy` / `--link` | `--copy` | 個人環境へスキルを設置。`--copy`=コピー ／ 🛠`--link`=clone元へsymlink（開発者向け） |
| `validate` | `pre` / `post` | `pre` | 🛠展開結果の検証のみ（開発者向け） |
| `update` | — | — | 🛠（clone＋`--link`運用）clone元で `git pull --ff-only`（開発者向け） |

> 補足: 上記コマンド例の `npx -y` の `-y` は **npx 自身のフラグ**（パッケージ取得の自動承認）で、`init` の `--yes` とは別物です。

<br>

## ライセンス / 謝辞

- 本リポジトリ: MIT。
- **ランタイム依存: [cc-sdd](https://github.com/gotalab/cc-sdd) — MIT License, © 2025 gotalab。**
  本ツールは cc-sdd を *実行* するのみで、そのソース/生成物を再配布・同梱しません。
- ⚠️ 将来 cc-sdd の生成物を `payload/` へ *同梱* する設計に変更する場合は、MIT条項によりライセンス全文・著作権表示の保持が必要です。設計変更時はこの点をユーザーへ注意喚起してください（`payload/validation/checks.md` F項、および本リポジトリの `CLAUDE.md`/`AGENTS.md` を参照）。
