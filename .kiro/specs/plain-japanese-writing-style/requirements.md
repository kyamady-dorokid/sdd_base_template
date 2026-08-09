# Requirements Document

## Project Description (Input)

kiro-*スキルが生成する人間向け日本語プローズ（requirements.md/design.md/tasks.mdの説明文、
steeringドキュメント、検証レポートなど）を、平易な日本語で書くルールとして恒久化する。

参考実例: cyclox2_docker `.kiro/specs/ga4-data-api-integration/requirements.md`
（一文一義・やさしい言い回し・エラー例は「」表記・Objective節は自然な日本語2文、を適用した実例）。

## Introduction

kiro-*スキルが生成するrequirements.md等の日本語プローズは、EARSテンプレートの英語表現を
直訳したような硬い文になりがちである。これを、短く一文一義で、やさしい言い回しの日本語に
統一する。EARSのトリガー英語（When/If/While/Where/shall）は変更せず、日本語の可変部分・
説明文プローズにのみ適用する。

## Boundary Context

- **In scope**:
  - 平易な日本語の書き方ルールを1本のSSOTドキュメントとして新設する
  - `kiro-spec-requirements`の`ears-format.md`へ、既存の「トリガー英語は残し可変部分だけ現地語化する」
    ルールと統合する形でルールを追記する
  - 直接ドキュメントを生成する11スキル（kiro-spec-requirements, kiro-spec-design, kiro-spec-tasks,
    kiro-spec-init, kiro-validate-design, kiro-validate-gap, kiro-validate-impl, kiro-discovery,
    kiro-steering, kiro-steering-custom, kiro-impl）へ、既存パターン（`fix-impl-team-policy.sh`等）
    と同じ「薄い委譲ブロックをSKILL.md末尾へ冪等追記するパッチ」でルールを適用する
  - `payload/validation/checks.md` / `payload/scripts/validate.sh` に新パッチの検証項目を追加する
  - `payload/scripts/sync.sh` の `MANAGED_BLOCKS` に新規対象ファイルを登録する
- **Out of scope**:
  - EARS構文自体、spec.jsonのスキーマ、承認ゲートのフローなど既存の構造的ルールの変更
  - `sync.sh`の自動マージ機能の追加（判断不要な場合の自動マージ等）。これは別スペックとして
    後日起票する
  - `kiro-review`・`kiro-debug`・`kiro-verify-completion`・`kiro-spec-batch`・`kiro-spec-quick`・
    `kiro-spec-status`への適用（これらは独立した文書を作らず他スキルへ委譲、または会話内出力のみ
    のため対象外）
- **Adjacent expectations**:
  - ルール本文はSSOTドキュメント1箇所にのみ書き、各パッチは参照のみで本文を重複させない
    （既存パッチと同一の設計方針）
  - 既存の`.claude/skills/kiro-*/SKILL.md`は cc-sdd の生成物であり、上流ソースは直接編集しない

## Requirements

### Requirement 1: 平易な日本語ルールのSSOTドキュメント化

**Objective:** kiro-*が生成する日本語プローズの書き方ルールを、1つの正となるドキュメントに
まとめたい。ルールの重複や食い違いを防ぐためである。

#### Acceptance Criteria
1. The `japanese-writing-style.md` shall 一文一義（読点で2つ以上の主張をつながない）のルールを含む
2. The `japanese-writing-style.md` shall かたい漢語よりやさしい言い回しを使う方針と、参考例
   （識別可能な→とわかる、既定値→デフォルト・何も指定しなければ、疎通→接続確認、担保する→守る）を含む
3. The `japanese-writing-style.md` shall エラーメッセージ等の具体例を「」で示すルールを含む
4. The `japanese-writing-style.md` shall requirements.mdのObjective節を、EARSの直訳ではなく
   自然な日本語2文（「〜したい。〜するためである。」）にするルールを含む
5. The `japanese-writing-style.md` shall このルールがEARSトリガー英語（When/If/While/Where/shall）
   には適用されず、日本語の可変部分・説明文プローズにのみ適用されることを明記する

### Requirement 2: ears-format.mdとの統合

**Objective:** requirements.mdのEARS記述について、既存の「トリガー英語は残し可変部分だけ
現地語化する」ルールと、新しい平易な日本語ルールを矛盾なく1箇所にまとめたい。

#### Acceptance Criteria
1. When `kiro-spec-requirements`スキルがrequirements.mdを生成するとき, ears-format.md shall
   平易な日本語ルールへの参照を含む
2. The ears-format.md shall 既存のトリガー英語保持ルールの記述を変更しない（新ルールは追記のみ）

### Requirement 3: 対象スキルへの適用

**Objective:** 直接ドキュメントを生成する11個のkiro-*スキルすべてで、同じ平易な日本語ルールが
使われるようにしたい。スキルによってルールが適用されたりされなかったりする不整合を防ぐためである。

#### Acceptance Criteria
1. The 対象11スキルのSKILL.md（`.claude`・`.agents`双方） shall 平易な日本語ルールドキュメントへの
   参照を含む
2. If 対象スキルのSKILL.mdに既に同じマーカーのブロックが存在する場合, パッチ shall 重複追記せず
   スキップする

### Requirement 4: 検証・同期の整合

**Objective:** 新しいルールが正しく適用されているかを、既存の検証・同期の仕組みでチェックできる
ようにしたい。

#### Acceptance Criteria
1. The `validate.sh`（postフェーズ） shall 新しいマーカーの存在を検証項目に含める
2. The `checks.md` shall 新パッチの検証項目を記載する
3. The `sync.sh`の`MANAGED_BLOCKS` shall 新規対象ファイルをすべて登録する
