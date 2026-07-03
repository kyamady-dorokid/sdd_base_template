# Implementation Plan: two-tier-deliverables（SDD成果物の二層化）

> TDD（テスト先行）で進める。`payload/scripts/doc-export/*.sh` は純ロジック=`tests/unit/`、
> `export.sh`・配布統合=`tests/integration/`。ランナー: `bash tests/run.sh`。
> 各ゲートで人間承認、自動コミットしない、ブランチ→PR。bash 3.2 互換。

- [x] 1. ルール文書とマッピング表（正本非分割の明文化）
- [x] 1.1 `payload/overlay/docs/sdd/deliverables-policy.md` を新規作成
  - 二層化の定義（一次=正本／二次=派生ビュー・手編集禁止・一方向）、フォーマット現実ライン表、
    フェーズ×フォーマット対応表（決定#2「役割分担の指針」から再構築）、
    層の整理（横断規約=steering-custom／機能別=design.md 節）の判定基準、outputs 使い分け
  - 観測可能な完了条件: workflow.md から参照リンクが張られ、リンク切れがない
  - _Requirements: 1.1, 1.2, 3.1, 3.2, 3.3, 7.1, 7.2, 7.3_
- [x] 1.2 `payload/overlay/docs/sdd/workflow.md` に二層化節と `deliverables-policy.md` への参照を追記
  - _Requirements: 1.1, 2.3_
- [x] 1.3 snippets（`CLAUDE.sdd.md`/`AGENTS.sdd.md`）へ二層化リンク＋記録集約ルール改訂を**同一内容**で追記
  - 記録集約: 一次=`.kiro/specs/<id>/`、二次ビルド=`outputs/<id>/`、PII=`.kiro/specs/<id>/outputs/`
  - 観測可能な完了条件: `diff -q CLAUDE.sdd.md AGENTS.sdd.md` が一致
  - _Requirements: 1.4, 2.4_

- [x] 2. `renderers.sh`（レンダラ・レジストリ）
- [x] 2.1 テスト作成（RED）`tests/unit/test_doc_renderers.sh`
  - フォーマット→レンダラ対応の参照、実行体が PATH にある/ない場合で `sdd_renderer_available` が
    0/非0 に切替わること、重い本体を同梱していないこと（レジストリは検出のみ）を assert
  - _Requirements: 5.1, 5.3, 3.4_
- [x] 2.2 実装（GREEN）`payload/scripts/doc-export/renderers.sh`
  - `sdd_renderer_available <format>` と対応表（docx/pdf/pptx=pandoc、mermaid=mmdc、xlsx/uml=external）
  - _Requirements: 5.1, 5.3, 3.4_

- [x] 3. `manifest.sh`（宣言パース＋既定値）
- [x] 3.1 テスト作成（RED）`tests/unit/test_doc_manifest.sh`
  - `<source-md>#<section|*> -> <format> [@pii]` のパース、`@pii` フラグ抽出、
    manifest 不在時の既定フォールバック（Word→無ければ PDF）を assert
  - _Requirements: 5.4, 5.5_
- [x] 3.2 実装（GREEN）`payload/scripts/doc-export/manifest.sh`
  - _Requirements: 5.4, 5.5_

- [x] 4. `slice.sh`（節スライス）
- [x] 4.1 テスト作成（RED）`tests/unit/test_doc_slice.sh`
  - 見出し/アンカーに対応する節のみ抽出、`*`/省略で全文、見出し不在で非0＋空生成しないこと
  - _Requirements: 4.2, 4.3, 4.4_
- [x] 4.2 実装（GREEN）`payload/scripts/doc-export/slice.sh`
  - _Requirements: 4.2, 4.3, 4.4_

- [x] 5. `export.sh`（統括: スライス→図画像化→レンダラ→出力先分岐→レポート）
- [x] 5.1 テスト作成（RED）`tests/integration/test_doc_export.sh`
  - レンダラ不在環境で「未生成（要 install）」がレポートされ他成果物の処理が継続すること、
    `@pii` 宣言が `.kiro/specs/<id>/outputs/`・通常宣言が `outputs/<id>/` を宛先とし、
    出力先を明示するメッセージ（PII 隔離は特に明示）が出ること、正本 md が不変であること、
    見出し不在の宣言はエラー報告され空ファイルを作らないこと
  - _Requirements: 2.1, 2.5, 2.6, 4.1, 4.3, 5.3_
- [x] 5.2 実装（GREEN）`payload/scripts/doc-export/export.sh`
  - manifest 解釈→slice→Mermaid 画像化（mmdc 可用時）→renderer 判定→出力先分岐→生成レポート
  - _Requirements: 2.1, 2.5, 2.6, 3.4, 4.1, 4.4, 5.3_

- [ ] 6. doc-export スキルの新規配布機構（init 設置）
- [ ] 6.1 `payload/overlay/skills/doc-export/SKILL.md` を新規作成（エージェント向け手順・export.sh 呼出）
  - _Requirements: 6.1_
- [ ] 6.2 `payload/scripts/init.sh` [5/6] に doc-export スキル設置ステップを追加
  - `.claude/skills/doc-export/` と `.agents/skills/doc-export/` へ**バイト同一**設置。
    sync 管理下（`.kiro/sdd-base.lock` 検出）では docs/sdd 同様に上書きスキップし sync に委ねる
  - 観測可能な完了条件: 空リポジトリ init 後 `diff -qr .claude/skills/doc-export .agents/skills/doc-export` 差分ゼロ
  - _Requirements: 6.1, 6.2, 6.3, 9.3_
- [ ] 6.3 `gitignore.snippet` に `outputs/` を追記（既存 `.kiro/specs/*/outputs/` に加算）
  - _Requirements: 2.2_

- [ ] 7. sync への配布統合（`managed_skills`）
- [ ] 7.1 テスト作成（RED）`tests/integration/test_sync_skills.sh`
  - doc-export スキルツリーが sync で `.claude`/`.agents` 双方へ配布・3-way され、ローカル変更の
    サイレント上書きが起きず（コンフリクトは `<file>.new`）、未変更は新版反映、初回化は基準点記録のみ
  - _Requirements: 9.2_
- [ ] 7.2 実装（GREEN）`payload/scripts/sync.sh` に `managed_skills()` を追加
  - `managed_docs` と同型（whole-file 3-way）。overlay の doc-export ツリーを両エージェントへ。
    初回化ルート・差分適用ルート・レポート集計に組み込む
  - _Requirements: 9.2_

- [ ] 8. CLI（`install-renderers`）
- [ ] 8.1 `bin/cli.js` に `install-renderers` サブコマンドを追加
  - レンダラ opt-in 取得手順の案内/実行（本体は再配布しない）。help 更新
  - 観測可能な完了条件: `node bin/cli.js install-renderers` が動作し help に表示
  - _Requirements: 5.2_

- [ ] 9. validate（post）への二層化検証
- [ ] 9.1 `payload/scripts/validate.sh`(post) に検証を追加
  - `outputs/` の gitignore 追記、`deliverables-policy.md` の存在、workflow の二層化節、
    doc-export スキルが `.claude`/`.agents` 双方に存在し差分ゼロ、snippets 記録集約ルールのパリティ
  - _Requirements: 9.1_
- [ ] 9.2 `payload/validation/checks.md` に二層化検証項目（H 節）を追加
  - _Requirements: 9.1_

- [ ] 10. 既存方針の保全（不採用事項の担保・回帰）
- [ ] 10.1 既存回帰の確認
  - `design.md` テンプレを変更していないこと、`validate.sh` の `tech-requirements.md` NG 判定が
    維持されていること、`payload/` に cc-sdd 生成物・重いレンダラ本体を同梱していないこと
  - `bash tests/run.sh` 既存テスト（63件）＋新規テストが全 PASS
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [ ] 11. E2E 通し確認・ドキュメント・記録
- [ ] 11.1 空リポジトリで `init` → doc-export 設置・パリティ・`validate post` OK、`sync` 再実行で差分ゼロ（収束）
  - manifest あり/なし、`@pii` あり/なし、レンダラ不在時の未生成明示を通しで確認し `test-results.md` に記録
  - _Requirements: 全要件_
  - _Boundary: doc-export/*, init.sh, sync.sh, validate.sh_
- [ ] 11.2 README「その他の使い方」に doc-export と `install-renderers` の説明を追加
  - _Requirements: 5.2_
