# Implementation Plan

- [x] 1. SSOTドキュメントを新設する
  - `payload/overlay/docs/sdd/rules/japanese-writing-style.md` を作成する（一文一義／やさしい
    言い回し／「」表記／Objective節の自然な日本語化／適用範囲の明記）
  - リンクの実際の設置場所は `payload/overlay/snippets/CLAUDE.sdd.md` /
    `payload/overlay/snippets/AGENTS.sdd.md` の「ベースルールの所在」節（`workflow.md`ではなく
    こちらが実体）に1行ずつ追加した
  - _Requirements: 1_

- [x] 2. ears-format.mdへの統合パッチを追加する
  - `payload/validation/patches/fix-ears-plain-japanese.sh` を新規作成した（`SDD-OVERLAY:EARS-PLAIN-JA`、
    `.claude`/`.agents`双方の`kiro-spec-requirements/rules/ears-format.md`が対象）
  - スクラッチファイル・実際のリポジトリ内ファイルの両方で冪等性を確認した
  - _Requirements: 2_

- [x] 3. 対象11スキルへの一般化パッチを追加する
  - `payload/validation/patches/fix-plain-japanese-output.sh` を新規作成した（`SDD-OVERLAY:PLAIN-JAPANESE-OUTPUT`、
    対象11スキル×`.claude`/`.agents`の計22ファイル）
  - 冪等性を確認した
  - _Requirements: 3_

- [x] 4. 検証項目を更新する
  - `payload/validation/checks.md` のC2節に新パッチ2本の検証項目を追記した
  - `payload/scripts/validate.sh` のpostフェーズに新マーカー2種のgrepチェックを追加した
  - _Requirements: 4_

- [x] 5. sync.shのMANAGED_BLOCKSへ登録する
  - `payload/scripts/sync.sh` の`MANAGED_BLOCKS`配列へ、ears-format.md 2件＋対象11スキル×2=22件、
    計24件のエントリを追加した
  - _Requirements: 4_

- [x] 6. 結合確認
  - 新パッチをリポジトリ実ファイルのスクラッチコピーへ適用し、`validate.sh post`の新規24チェックが
    すべてPASSすることを確認した
  - `bash tests/run.sh`（全145件）を実行し、既存の1件の失敗（pandoc関連・環境依存）が本変更前の
    `main`でも同一に発生する既存不具合であることを確認した（新規リグレッションなし）
  - `.kiro/specs/plain-japanese-writing-style/test-results.md` に結果を記録した
  - _Requirements: 1, 2, 3, 4_
