# Design Document

## 概要

既存の `fix-impl-team-policy.sh` / `ensure-agreement-log.sh` / `fix-design-template.sh` と同一の
「SSOTドキュメント＋薄い委譲パッチ（冪等追記）」パターンをそのまま踏襲する。新しい仕組みは作らない。

## 1. SSOTドキュメント

`payload/overlay/docs/sdd/rules/japanese-writing-style.md` を新設する。

構成:
- 目的・適用範囲（EARSトリガー英語は対象外、可変部分・説明文プローズのみ）
- ルール1: 一文一義
- ルール2: やさしい言い回し（参考例テーブル。網羅リストではなく方針として明記し、将来の追加を妨げない）
- ルール3: 具体例は「」で示す
- ルール4: requirements.mdのObjective節は自然な日本語2文にする（EARS直訳をやめる）

`docs/sdd/workflow.md`の「ベースルールの所在」一覧に1行リンクを追加する。

## 2. ears-format.mdへの統合パッチ

新規: `payload/validation/patches/fix-ears-plain-japanese.sh`
- マーカー: `SDD-OVERLAY:EARS-PLAIN-JA`
- 対象: `.claude/skills/kiro-spec-requirements/rules/ears-format.md`,
  `.agents/skills/kiro-spec-requirements/rules/ears-format.md`
- 内容: 既存の「トリガー英語は残し可変部分だけ現地語化する」文へ続く形で、
  「日本語部分は平易な表現にする（`docs/sdd/rules/japanese-writing-style.md`参照）。
  Objective節はEARSの直訳ではなく自然な日本語2文にする」という薄い委譲ブロックを末尾追記する。
  本文は書かず、SSOTを参照させる（既存パッチと同一方針）。

## 3. 対象スキルへの一般化パッチ

新規: `payload/validation/patches/fix-plain-japanese-output.sh`
- マーカー: `SDD-OVERLAY:PLAIN-JAPANESE-OUTPUT`
- 対象（`.claude`・`.agents`双方、計22ファイル）:
  - kiro-spec-requirements, kiro-spec-design, kiro-spec-tasks, kiro-spec-init
  - kiro-validate-design, kiro-validate-gap, kiro-validate-impl
  - kiro-discovery, kiro-steering, kiro-steering-custom, kiro-impl
- 内容: 「本スキルが生成する日本語プローズ（説明文・レポート等）は平易な日本語で書く。
  ルールは`docs/sdd/rules/japanese-writing-style.md`参照」という薄い委譲ブロックをSKILL.md末尾へ
  冪等追記する。
- kiro-implは既に`SDD-OVERLAY:IMPL-POLICY`ブロックを持つが、別マーカーのブロックとして追加する
  （既存ブロックは変更しない）。

## 4. 検証の更新

`payload/validation/checks.md` のC2節に以下を追記:
- `fix-ears-plain-japanese.sh`: ears-format.md（`.claude`/`.agents`双方）へ`SDD-OVERLAY:EARS-PLAIN-JA`
  が1つ注入されている
- `fix-plain-japanese-output.sh`: 対象11スキルのSKILL.md（`.claude`/`.agents`双方）へ
  `SDD-OVERLAY:PLAIN-JAPANESE-OUTPUT`が1つ注入されている

`payload/scripts/validate.sh` のpostフェーズに、上記2マーカーの存在をgrepするチェックを追加する
（既存の`SDD-OVERLAY:IMPL-POLICY`チェックと同じ書き方）。

## 5. sync.shへの登録

`payload/scripts/sync.sh` の `MANAGED_BLOCKS` 配列へ、対象ファイル×マーカー×パッチ名のエントリを
追加する（ears-format.md 2件 + 対象11スキル×2 = 22件、計24件）。既存エントリの書式
（`"target|marker|patch|script.sh"`）をそのまま使う。

## 技術要件・制約チェック

| 制約 | 内容 |
|---|---|
| 上流ソース不変更 | cc-sdd生成物（`.claude/skills/kiro-*`, `.agents/skills/kiro-*`）を直接書き換えず、
  取得済みローカル生成物へ追記パッチを当てる既存方針を踏襲する |
| 冪等性 | 既存パッチと同様、マーカー検出で再適用時にスキップする |
| Claude/Codexパリティ | `.claude`・`.agents`両方に同一内容のブロックを追記する |
| ライセンス | cc-sdd生成物のpayload同梱には該当しない（パッチによる追記のみのため対象外） |

### 初回実装前の確認
- [ ] 既存パッチ3本（fix-impl-team-policy.sh / ensure-agreement-log.sh / fix-design-template.sh）
      の設計方針を確認した
- [ ] `sync.sh`の`MANAGED_BLOCKS`書式を確認した
- [ ] `validate.sh`のpostフェーズ既存チェックの書式を確認した
