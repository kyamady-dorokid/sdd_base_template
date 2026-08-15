# Research & Design Decisions

## 調査目的

Issue #32の設計に先立ち、Codexでスキルが見つかる条件、Claude Codeとの配布差、現行の
`sdd_base_template`のinstall・init・sync・validate経路を確認した。調査では
`agents/openai.yaml`の見た目の差を単独原因と決めつけず、探索、選択、明示起動、暗黙起動、
実処理開始を分離した。

## 公式契約の確認

### Codex Skills

一次情報: [Codex Skills](https://developers.openai.com/codex/skills/)

- スキルの発見に使われる正本は各ディレクトリの`SKILL.md`であり、frontmatterの`name`と
  `description`が選択判断に使われる。
- リポジトリスコープでは、現在位置からリポジトリルートまでの各`.agents/skills`が探索される。
- user scopeの標準配置は`$HOME/.agents/skills`である。
- 同名スキルは自動統合されず、複数scopeに存在すれば別候補として扱われる。
- `agents/openai.yaml`はUI、暗黙起動方針、ツール依存等を記述する任意metadataである。
- `policy.allow_implicit_invocation: false`は暗黙起動を禁止するが、`$skill-name`による明示起動は
  禁止しない。
- user scopeのスキルは`~/.codex/config.toml`の`[[skills.config]]`で無効化できる。

以上から、現在の初期一覧に表示されない事実だけで未配布と断定できない。一方で、
`.agents/skills`の探索、`SKILL.md`の正規名、selector、明示起動、選ばれたsource/scopeまで
分けて検証しなければ、別scopeの同名スキルを誤って合格にする。

### `agents/openai.yaml`

Codexのskill creatorが示す現行schemaでは、利用者向けmetadataは次の形を取る。

```yaml
interface:
  display_name: "表示名"
  short_description: "25文字以上64文字以下の短い説明"
  default_prompt: "Use $skill-name to ..."
policy:
  allow_implicit_invocation: true
```

`kiro-spec-batch`だけにあるトップレベル`name` / `description`形式を他スキルへ展開する根拠はない。
むしろ、全スキルを公式schemaへ正規化し、`SKILL.md`の発見契約と`openai.yaml`の起動方針を
別項目として検査する必要がある。

### Claude Code Skills

一次情報: [Claude Code Skills](https://code.claude.com/docs/en/skills)

- `disable-model-invocation: true`はClaudeによる自動起動を止め、利用者の`/skill-name`による
  明示起動専用にする。
- `user-invocable: false`は利用者の直接起動を隠す一方、Claudeからの利用を許すため、
  internal/helperに対応する。

したがって、暗黙起動方針はCodex側の`openai.yaml`だけに記録してはならない。Claude側は
`SKILL.md` frontmatter、Codex側は`policy.allow_implicit_invocation`で同じ分類を表現し、
platform別assertionで検査する。

## 現行実装の調査

### スキル資産

- `.claude/skills`と`.agents/skills`にはそれぞれ18本の`SKILL.md`がある。
- Codex側の17本に`agents/openai.yaml`があるが、`doc-export`にはない。
- `kiro-spec-batch`だけがトップレベル`name` / `description`形式で、他は`interface`形式かつ
  `allow_implicit_invocation: false`である。
- 現行`validate.sh`は主として名前集合と一部のバイト差を確認し、frontmatter、metadata schema、
  明示／暗黙起動方針、source/scope、主要ワークフロー契約を検証しない。

### 配布経路

- `init.sh`はcc-sddをClaude Code用とCodex用に実行し、patchとoverlayを適用する。
- `init.sh`のpost validationは失敗を`|| true`で無視し、その後も完了表示を行う。
- `sync.sh`には既存の安全なファイル適用関数`sdd_apply_file`があり、競合時は対象を変更せず
  `.new`候補を作る。Issue #32はこの統合点を利用するが、競合解決方式自体は変更しない。
- `bin/cli.js`の個人install先はClaudeが`~/.claude/skills/sdd-init`、Codexが
  `~/.codex/skills/sdd-init`である。後者は現行Codexの文書化されたuser scopeと一致しない。
- install bundleは`skills/sdd-init`と`payload`をコピーする自己完結構造で、実行時の
  `node_modules`を配布しない。

### 利用案内

- READMEはClaude Codeの`/kiro-*`案内が中心で、Codexの`$kiro-*`、selector、自然言語入口の
  対応関係が不足している。
- 配布snippetは`diff -qr .claude/skills .agents/skills`を整合確認として案内するが、意図した
  プラットフォーム差まで異常として扱う。
- cc-sdd由来のCodex案内には、現行CLIで廃止済みの`collaboration_modes`設定が残る場合がある。

## Design Decisions

### Decision 1: 正規インベントリをrepo-owned manifestに集約する

`payload/validation/skill-parity.json`を、配布対象、分類、暗黙起動方針、Codex metadata、
必須資産、主要契約、許容差の正本とする。上流へ新規スキルが追加されてもmanifestに分類がなければ
検証を通さない。

このmanifestはcc-sdd生成物のコピーではなく、`sdd_base_template`が所有する配布ポリシーである。
cc-sddのソースや生成物を`payload/`へ同梱しないため、現行のライセンス境界を維持する。

### Decision 2: metadataはmanifestから決定的に生成する

Codex側の`agents/openai.yaml`を手作業で17種類管理せず、manifestから公式schemaで生成する。
`default_prompt`は必ず正規`$skill-name`を含める。Claude側は同じ`SKILL.md`とワークフロー契約を
使い、Codex固有metadataだけを理由付きプラットフォーム差として扱う。

### Decision 3: 暗黙起動は安全性で分類する

| 区分 | スキル | 方針 |
|---|---|---|
| 通常のuser-facing | `doc-export`, `kiro-discovery`, `kiro-spec-init`, `kiro-spec-requirements`, `kiro-spec-design`, `kiro-spec-tasks`, `kiro-spec-status`, `kiro-steering`, `kiro-steering-custom`, `kiro-validate-design`, `kiro-validate-gap`, `kiro-validate-impl`, 個人向け`sdd-init` | 暗黙起動可 |
| 状態変更・複数フェーズ | `kiro-impl`, `kiro-spec-quick`, `kiro-spec-batch` | 明示起動専用 |
| internal/helper | `kiro-debug`, `kiro-review`, `kiro-verify-completion` | 直接入口では処理を開始せず、親スキルの委譲からだけ実処理 |

暗黙起動可は承認ゲートの自動通過を意味しない。どの入口でも各`SKILL.md`の成果物、停止条件、
承認状態を変えない。Issue #39が所有する厳格な独立レビュー契約も先取りしない。

Claudeでは状態変更・複数フェーズskillに`disable-model-invocation: true`を設定する。helperには
`user-invocable: false`と`disable-model-invocation: true`の双方を設定し、親skillが既知pathの本文を
読み込んで委譲する。Codexでは状態変更・複数フェーズskillとhelperを
`allow_implicit_invocation: false`にする。Codexの現行metadataにはselector非表示を保証する契約が
ないため、helper本文の冒頭guardが直接利用者起動を停止し、親skillの構造化委譲だけを受け付ける。

### Decision 4: validatorは依存なしNode.jsで実装する

汎用YAMLライブラリの採用も検討したが、install bundleが`node_modules`を含まないため、配布後に
validatorが動かなくなる。Node.js 18標準機能だけで、対象を限定したfrontmatterと
`agents/openai.yaml`のscalar pathを読み、manifestと照合する。

パーサは未知の複雑構文を推測せず、必須項目の重複、複数行値、型不一致、未対応構文を
`UNVERIFIED`または`FAILED`として扱う。生成側はJSON quotingと等価な安全な引用を用い、
決定的なYAMLだけを出力する。

### Decision 5: 静的検証と新規セッション受入を分離する

静的validatorはファイル、metadata、分類、必須資産、主要契約までを判定できるが、Codex/Claudeの
実selectorやモデルの起動判断を証明できない。したがって、releaseのE2E判定は新規セッションで
一覧、selector、明示起動、暗黙起動、処理開始、source/scopeを記録する手動受入を必須とする。

### Decision 6: fail-closed状態を4値で表す

- `PASS`: 必須検査がすべて成功した。
- `PARTIAL`: 一部適用、競合、既知の手動対応待ちがある。
- `UNVERIFIED`: 実行不能、証跡不足、未知形式等で判定できない。
- `FAILED`: 契約違反または実行エラーが確認された。

終了コードは`PASS=0`、`PARTIAL/UNVERIFIED=2`、`FAILED/内部エラー=1`とする。initはpost検証の
非PASSを無視せず完了宣言しない。syncはIssue #30の競合方式を変えず、パリティ非PASSだけを
完全適用成功と区別する。

### Decision 7: 個人向けCodex installを標準scopeへ移行する

新しい正規配置はClaude Codeが`~/.claude/skills/sdd-init`、Codexが
`~/.agents/skills/sdd-init`である。`~/.codex/skills/sdd-init`への新規installは停止する。
同名重複を避けるため、旧配置はツール管理と証明できるsymlinkまたは管理marker付きの場合だけ
除去する。所有不明の実体は変更せず、`PARTIAL`と移行案内を返す。

copy modeでは`.sdd-base-managed.json`を配置し、link modeでは解決先を確認する。削除対象を
広いパスや名前一致だけで決めない。

### Decision 8: 廃止設定のpatchは厳密一致だけ自動修正する

既知の`collaboration_modes`案内だけを冪等patchで置換する。利用者が変更した未知形状は
黙って書き換えず`UNVERIFIED`として報告する。置換後はCodexの`/skills`、`$skill-name`、
`.agents/skills`を案内する管理marker blockとする。

## Rejected Alternatives

| 案 | 却下理由 |
|---|---|
| `kiro-spec-batch`のトップレベルmetadata形式を全件へ複製 | 現行の公式`openai.yaml` schemaではない |
| 全スキルの暗黙起動を有効化 | 実装・複数フェーズ・helperの誤起動リスクがある |
| `.claude`と`.agents`の全バイト一致を維持 | Codex固有metadata等の正当な差を表現できない |
| YAMLライブラリを通常dependencyとして追加 | 個人install bundleに`node_modules`がなく自己完結性を失う |
| 旧`~/.codex/skills/sdd-init`を無条件削除 | user-ownedデータを破壊し得る |
| 静的validatorだけでE2E合格にする | selector、source/scope、実処理開始を証明できない |
| cc-sdd生成済みスキルを`payload/`へ保存 | 現行の実行のみ・非再配布境界を破る |

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Codexの発見仕様が更新される | 公式仕様、manifest schema version、新規セッション受入をreleaseごとに確認する |
| 独自scalar parserが未知YAMLを誤解釈する | 生成可能なsubsetを限定し、未知形式はfail-closedにする |
| 同名スキルを別scopeから起動して誤合格する | source/scope、実ファイル、enabledを証跡必須にする |
| init/syncの一部失敗が完了表示に埋もれる | 4値状態と非0終了コードをライフサイクルへ伝播する |
| #39の責任を#32へ混入する | 既存安全契約の非回帰だけ検査し、新しいreview機構は実装しない |
| 上流差分のpatchがuser変更を壊す | 厳密一致または管理marker内だけ更新し、未知形状は未検証にする |

## Implementation Evidence Needed

- unit test: manifest schema、frontmatter、Codex metadata生成・検証、状態集約、旧配置所有判定
- integration test: install copy/link、init post validation、sync安全適用、deprecated guidance patch
- static report: 全スキルのagent別意味的パリティと失敗区分
- new-session evidence: Claude Code/Codex、repo root/subdirectory、minimal/normal scope、init/sync/
  `cyclox2_docker`、明示／暗黙起動、処理開始、source/scope/path/enabled
- regression: 現行approval、TDD、review、実装前停止の契約差分なし
