# Implementation Plan: pages-doc-site-design

> 設定・スタイル中心のため自動テストは追加しない。検証は実確認（tests/run.sh 非影響・sync 安全性・
> 実サイトでのナビ/視認性/自動反映確認）。各ゲートで人間承認、自動コミットしない、ブランチ→PR。

- [ ] 1. サイドバーナビゲーションの実装
- [ ] 1.1 `_includes/sidebar.html` を新規作成し、`site.pages` をディレクトリ単位でグルーピングして
      ナビを生成する
  - ディレクトリ→表示ラベルの対応表（`/`＝トップ、`/docs/sdd/`、`/docs/sdd/rules/`、
    `/docs/sdd/templates/`）を実装し、対応表に無いディレクトリはディレクトリ名をそのままラベルに
    するフォールバック分岐を実装する
  - 現在表示中のページを `page.url` の一致判定で他と視覚的に区別できるクラスを付与する
  - 各ページのリンクテキストに `page.title`（H1から自動抽出）を使う
  - 観測可能な完了条件: `site.pages` を起点にした4グループ（トップ/docs/sdd/rules/templates）＋
    フォールバック分岐のロジックが1ファイルに実装されている
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.4_

- [ ] 1.2 `_layouts/page.html` を新規作成し、サイドバーとメインコンテンツの2カラム構造を提供する
  - front-matter で `layout: default` を指定し、minima標準の `default.html`（ヘッダー/フッター）を
    そのまま利用する
  - 既存の minima クラス（`post`・`post-header`・`post-title`・`post-content`）を維持したまま
    `{% include sidebar.html %}` を配置する
  - 観測可能な完了条件: サイドバーとメインコンテンツ領域が1つのコンテナ要素の中に揃い、
    `layout: default` が front-matter に明記されている
  - _Requirements: 1.1, 3.4_

- [ ] 2. 視認性向上とレイアウトスタイルの実装
- [ ] 2.1 `assets/main.scss` を新規作成し、見出し・コードブロック・表・サイドバーレイアウトの
      スタイルを追加する
  - 冒頭で `@import "minima";` を維持し、minima の変数・基本スタイルを継承する
  - 見出し（h1〜h3相当）をフォントサイズ・太さ・余白で段階的に区別するルールを追加する
  - コードブロック（フェンスドコード・インラインコード）を背景色・等幅フォントで区別するルールを追加する
  - 表（`table`/`th`/`td`）に罫線・行間・ヘッダー強調のルールを追加する
  - サイドバーとメインコンテンツの2カラムグリッド（狭幅画面では1カラムに縮退）のルールを追加する
  - 観測可能な完了条件: 見出し／コードブロック／表／サイドバーグリッドの4種のスタイルルールが
    ファイル内に揃っている
  - _Requirements: 2.1, 2.2, 2.3_

- [ ] 3. 非デグレ・sync安全性の確認（マージ前）
- [ ] 3.1 `docs/sdd/**`・`_config.yml`・`payload/**` を無改変であることを確認する
  - `git diff` の対象パスに変更が含まれないことを確認する
  - 観測可能な完了条件: `git diff -- docs/sdd _config.yml payload` の出力が空である
  - _Requirements: 3.1, 3.2, 3.3_
- [ ] 3.2 `bash tests/run.sh` が全PASSであることを確認する
  - 観測可能な完了条件: 実行結果が既存件数（145件）で Failed: 0 のまま維持されている
  - _Requirements: —（回帰）_
- [ ] 3.3 `node bin/cli.js sync --yes` 実行後、`docs/sdd/**` に差分・コンフリクトが生じないことを確認する
  - 観測可能な完了条件: sync 実行後の `git status --porcelain docs/sdd` が空である
  - _Requirements: 4.3_

- [ ] 4. コミット・PR（人間承認で実行）
- [ ] 4.1 追加ファイル（`_layouts/page.html`・`_includes/sidebar.html`・`assets/main.scss`）と
      spec 記録をコミット提案 → 承認後コミット・push・PR
  - _Requirements: —（プロセス）_

- [ ] 5. 実サイトでの検証（PRマージ後・外部公開への反映のため実行前に確認）
- [ ] 5.1 Pages ビルド状態が `built` になることを確認する
  - 観測可能な完了条件: `gh api .../pages/builds/latest` の `status` が `built`
  - _Requirements: 4.1_
- [ ] 5.2 代表ページ（README・`docs/sdd/workflow`・`docs/sdd/rules` 配下1件・
      `docs/sdd/templates` 配下1件）でサイドバー表示・現在地ハイライト・リンク遷移（404無し）を確認する
  - 観測可能な完了条件: 4ページすべてで 200 応答・サイドバー表示・代表リンクのクリック遷移を確認できる
  - _Requirements: 1.1, 1.2, 1.3, 4.2_
- [ ] 5.3 一時的なダミー md を `docs/sdd/` 配下に追加してサイドバーへの自動反映を確認し、
      確認後に削除する
  - 観測可能な完了条件: ダミーページ追加後の再ビルドでサイドバーに新規リンクが表示され、
      削除後の再ビルドで消えることを確認できる
  - _Requirements: 1.4_
- [ ] 5.4 見出し3段階・コードブロック・表を含む代表ページで視認性向上を目視確認する
  - 観測可能な完了条件: 見出し階層・コードブロック・表それぞれが本文と視覚的に区別できる
  - _Requirements: 2.1, 2.2, 2.3_
- [ ] 5.5 `test-results.md` に検証結果を記録する
  - _Requirements: 4.1, 4.2, 4.3_
