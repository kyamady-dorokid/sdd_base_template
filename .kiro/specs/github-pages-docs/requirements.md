# Requirements Document

## Introduction

`sdd_base_template` のドキュメント（`README.md` と `docs/sdd/**`）を **GitHub Pages** で公開し、
ブラウザから章立てで参照できるドキュメントサイトにする。生成方式は GitHub Pages 標準の Jekyll
（CI・重い依存を追加しない）とし、`_config.yml` の `defaults` により **既存 md 本文を一切改変せず**
サイト化する。

**重要な制約**: `docs/sdd/**` は overlay 配布物（`payload/overlay/docs/sdd/`）の sync コピーである。
Pages 化のために `docs/sdd/**` の md 本文（front-matter 追加等）を改変してはならない（payload を変えると
全ターゲットへ front-matter が混入し、ルートだけ変えると sync がコンフリクトするため）。

要件は WHAT（利用者から観測できる公開結果・運用制約）を規定し、内部実装は design に委ねる。

## Boundary Context

- **In scope**:
  - `README.md`（トップ）＋ `docs/sdd/**` を GitHub Pages で公開（Jekyll 標準ビルド）。
  - サイト構成用ファイル（`_config.yml` 等）の追加と、Pages の有効化。
  - サイトから不要ディレクトリ（`payload/`・`.kiro/`・`tests/`・`bin/` 等）を除外。
- **Out of scope**:
  - `docs/sdd/**` の md 本文の改変（sync 安全性のため禁止）。
  - MkDocs/Docusaurus 等の別ジェネレータ・GitHub Actions ビルドパイプラインの導入。
  - 独自ドメイン設定。
  - doc-export（Word/PDF）による HTML サイト生成（doc-export は範囲外）。
- **Adjacent expectations**:
  - 本テンプレートの「重い依存を持ち込まない」思想を維持する。
  - Claude/Codex パリティや既存 CLI（init/sync/validate/doc-export 等）に影響を与えない。

## Requirements

### Requirement 1: GitHub Pages でのドキュメント公開
**Objective:** 利用者・導入検討者として、ブラウザで README と SDD ルールを読めるようにしたい。そうすれば
リポジトリを clone せずに仕様・運用を把握できる。

#### Acceptance Criteria
1. The リポジトリ shall GitHub Pages（Jekyll 標準ビルド）で公開され、公開 URL でトップページが表示される。
2. The トップページ shall `README.md` の内容とする。
3. The サイト shall `docs/sdd/**`（workflow / deliverables-policy / rules / templates）を HTML として閲覧できる。
4. The サイト構築 shall GitHub Actions のカスタムビルドを追加せず、GitHub Pages 標準の Jekyll ビルドで完結する。

### Requirement 2: 既存 md の非改変（sync 安全性）
**Objective:** メンテナとして、Pages 化が overlay 配布物や sync 運用を壊さないでほしい。そうすれば
ドキュメントの二層（配布 payload と展開先）を安全に保てる。

#### Acceptance Criteria
1. The Pages 化 shall `docs/sdd/**` の md 本文に front-matter 等を追加せず、`_config.yml` の `defaults` 等で
   レイアウトを適用する。
2. When `docs/sdd/**` を対象に `sync` を実行した場合, the サイト設定 shall コンフリクトや差分を生じさせない
   （md 本文が payload と一致し続ける）。
3. The Pages 化 shall `payload/overlay/**` を変更しない（配布物に影響を与えない）。

### Requirement 3: サイトの健全性（リンク・除外）
**Objective:** 利用者として、リンク切れや無関係ファイルの混入なくサイトを閲覧したい。

#### Acceptance Criteria
1. The サイト shall md 内の相対リンク（例 `[...](docs/sdd/workflow.md)`）を、公開ページ間で辿れるよう解決する
   （GitHub Pages 標準サポートのプラグイン等で `.md`→`.html` を解決）。
2. The サイト shall `payload/`・`.kiro/`・`tests/`・`bin/`・`node_modules/` 等の非ドキュメントを公開対象から除外する。
3. The Pages ビルド shall エラーなく成功する（公開 URL が 200 応答し、主要ページが表示される）。

### Requirement 4: 有効化と検証
**Objective:** メンテナとして、公開が確実に有効化され、動作確認されていてほしい。

#### Acceptance Criteria
1. The 作業 shall GitHub Pages を有効化する（source の設定を含む）。
2. When Pages ビルドが完了した場合, the 検証 shall 公開 URL でトップ（README）と `docs/sdd/` の代表ページが
   表示されることを確認する。
3. The README shall 公開サイトへのリンク（バッジまたは URL）を含む。
