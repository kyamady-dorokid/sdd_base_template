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

## C2. 独自ポリシーパッチの注入（薄い委譲パッチ）
- 設計: cc-sdd の *上流ソース* は触らず、取得済みローカル生成物に append/marker で当てる。
  ポリシー本文は overlay 文書（SSOT）に置き、パッチは参照のみ。
- [ ] `fix-impl-team-policy.sh`: `.claude/` と `.agents/` 両方の `kiro-impl/SKILL.md` に
      `SDD-OVERLAY:IMPL-POLICY` ブロックが1つ注入されている（自動commit無効・main直禁止・branch→PR・記録は.kiro/specs）
- [ ] `fix-design-template.sh`: `.kiro/settings/templates/specs/design.md` に
      `SDD-OVERLAY:DESIGN-TECHREQ` 節が注入されている（技術要件を design.md へ一本化）
- [ ] `ensure-agreement-log.sh`: `.claude/` と `.agents/` 両方の `kiro-spec-init/SKILL.md` に
      `SDD-OVERLAY:ENSURE-AGREEMENT-LOG` ブロックが1つ注入されている（spec初期化時に agreement-log.md を実在させる）
- [ ] 冪等性: 再 init で重複注入されない（マーカー検出でスキップ）

## D. バージョン整合
- [ ] 取得した cc-sdd のバージョンを記録
- [ ] `KNOWN_GOOD_CCSDD_VERSION` と一致するか確認
- [ ] 不一致（新版）の場合は **追加検査＋人間確認**（破壊的変更の可能性を警告）

## E. overlay 適用後の再検証
- [ ] `CLAUDE.md` / `AGENTS.md` に `<!-- SDD-BASE:START -->`〜`END` ブロックが1つだけ存在（重複挿入なし）
- [ ] `docs/sdd/` 一式が存在
- [ ] `docs/sdd/rules/security-policy.md` が存在（秘密情報ハードコード禁止ポリシー）
- [ ] `docs/sdd/workflow.md` に「非コーディング作業のドキュメント化」節が存在
- [ ] `.gitignore` に SDD base スニペット（`.kiro/specs/*/outputs/`）が追記済み
- [ ] `docs/sdd/` 内のリンク切れがない

## E2. 記録レイアウト統一（差分排除）
- [ ] 1タスクの記録は `.kiro/specs/<id>/` に集約される（`docs/specs/` は作らない）
- [ ] `docs/specs/` が残存していない
- [ ] `docs/sdd/templates/tech-requirements.md` が存在しない（design.md へ統合済み）
- [ ] 承認状態は `spec.json` を正本とし、agreement-log に承認ブール値を二重管理していない

## G. sync コマンド（安全な更新機構）
- 設計: `.kiro/specs/sdd-base-sync-command/design.md`。lock（`.kiro/sdd-base.lock`）+
  スナップショット（`.kiro/sdd-base-snapshot/`）による3-wayマージ台帳。いかなる場合も
  ローカルファイルをサイレント上書きしない。
- [ ] 初回 `sync` 実行で `.kiro/sdd-base.lock` / `.kiro/sdd-base-snapshot/` が生成され、
      既存ファイルは無変更のまま
- [ ] ローカル未変更ファイル（lockのhashと現在のhashが一致）は新版でそのまま更新される
- [ ] ローカル変更ファイルは `git merge-file` による3-wayマージを試行し、クリーンマージは適用される
- [ ] コンフリクト時は `<file>.new` を出力し、既存ローカルファイルは一切変更しない
- [ ] `.kiro/specs/`・`.kiro/steering/` 等の保護領域は管理対象に含まれず、`sync` 実行後も無変更
- [ ] 上流で削除されたファイルはローカルから自動削除されず、レポートにのみ記載される
- [ ] `sync` 実行後、`.kiro/sdd-base-update-report.md` に「新規適用/そのまま更新/クリーンマージ/
      コンフリクト/上流削除」の各カテゴリが出力される
- [ ] `sync` 実行はいかなる場合も自動コミット（git add/commit）を行わない
- [ ] `tests/run.sh` の全テストが PASS する（`tests/unit/` の単体テスト、`tests/integration/` の結合テスト）

## F. ライセンス注意（設計変更時のゲート）
- [ ] **cc-sdd の生成物をテンプレ（payload）へ同梱する設計変更を行う場合**、MIT条項により
      ライセンス全文・著作権表示（`Copyright (c) 2025 gotalab`）の保持が必要であることを
      ユーザーに注意喚起する。（現設計は npx 実行のみで同梱しないため不要）
