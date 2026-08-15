# Brief: Claude Code / Codex SDDスキルパリティ

## 課題

`sdd_base_template`を適用したリポジトリでは、Claude Code向けとCodex向けに同数のSDDスキルを
配布している。しかし`cyclox2_docker`のCodex新規セッションでは、`kiro-spec-batch`以外の
`kiro-*`スキルが利用可能スキルとして提示されず、Claude Codeでは使えるSDDフローがCodexでは
実質的に開始できない事象が発生した。

文書ルールの`AGENTS.md`はCodexに読まれているため、規約層は有効だが、スキルの検出・起動層が
部分的にしか機能していない。ファイルが両側に存在するだけでは、利用者が実行できることを保証できない。

## 利用者と期待する変化

- SDDを利用する開発者は、Claude CodeとCodexのどちらを選んでも同じSDDフェーズと補助スキルを開始・継続できる。
- テンプレート保守者は、片側だけでスキルが利用不能になる不整合を配布前後に検出できる。
- 利用者は、各環境で有効な明示起動方法と自然言語入口をREADMEおよび配布ルールから確認できる。

## 観測済み事実

- `.claude/skills/`と`.agents/skills/`は、それぞれ18個の`SKILL.md`を保持している。
- `.agents/skills/`の17スキルに`agents/openai.yaml`がある。
- `kiro-spec-batch`のmetadata形式だけが他の16スキルと異なる。
- 他の16スキルは正式な`interface`形式で、`allow_implicit_invocation: false`を指定している。
- 全18個の`SKILL.md`には`name`と`description`のfrontmatterが存在する。
- 現行の構造パリティ検証はスキル名の集合を比較するが、Codexによるparse・検出・起動は確認しない。
- 現行READMEはClaude Codeの`/kiro-*`を中心に説明し、Codexはコード上対応・動作未検証としている。
- このCodexセッションでも、プロジェクト由来の`kiro-*`として公開されたのは`kiro-spec-batch`だけだった。

## 原因に関する評価

原因は未確定である。OpenAI公式仕様では、スキル検出の必須metadataは`SKILL.md`の`name`と
`description`であり、`agents/openai.yaml`の`interface`形式は正式な任意metadataである。
また`allow_implicit_invocation: false`は自然言語による暗黙起動を止めるが、明示起動まで禁止しない。

したがって、metadata形式差を主因と断定して他スキルへ複製することはしない。初期一覧の表示省略、
selectorからの検出、明示起動、暗黙起動、探索開始位置、同名スキル、設定、スキル数によるcontext budget、
新規セッションへの反映を分離して調査する。

## Boundary Candidates

### In scope

- 配布対象`kiro-*`スキルと`doc-export`、個人環境へ配る`sdd-init`の分類、Codexでの検出、明示起動、自然言語起動
- Claude CodeとCodexの利用者向けSDDフローの意味的同等性
- 実際に利用できる起動方法を示すREADME・配布ルール
- リポジトリ配布前後と個人向けinstall後の意味的パリティ検証、および新規セッションを用いたE2E受入確認
- init、sync、`cyclox2_docker`までの配布経路における再現確認

### Out of scope

- Kiroスキル実行前後の通知文面と通知処理（Issue #31）
- 独立レビュー方式そのものの実装と既存の自動approval・同一context fallbackの廃止（Issue #39）
- syncの安全な自動マージと競合処理（Issue #30）
- cc-sddの検証済みバージョン昇格（Issue #33以降）
- cc-sddのソースまたは生成物を`payload/`へ再配布する設計変更
- 各`kiro-*`スキル固有の業務機能の全面改修

### Adjacent expectations

- Issue #32は検出・起動・意味的パリティを所有し、既存の承認・TDD・レビュー挙動を弱めない。Issue #39は、
  #32完了後に独立レビュー・人間承認の厳格な契約を両環境へ実装する。
- Issue #30は配布時のマージ方式を所有する。本specはsync後のスキル利用可否を受入対象にするが、
  syncの競合解決方式自体は変更しない。
- Issue #31は、本specで利用可能になったスキルの実行通知を後続で追加する。

## 成功状態

CodexとClaude Codeの新規セッションで、`kiro-*`、`doc-export`、`sdd-init`をそれぞれの用途に応じた
明示起動および自然言語入口から利用できる。#32による起動経路の変更は既存の承認・TDD・レビュー挙動を
弱めず、後続の#39が両環境へ新しい安全契約を適用できる。片側欠落、metadata不正、誤った起動元、
文書だけに存在する利用不能な入口は、配布検証またはE2E受入確認でfail-closedに特定できる。
