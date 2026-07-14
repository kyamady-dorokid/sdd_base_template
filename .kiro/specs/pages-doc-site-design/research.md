# Research & Design Decisions: pages-doc-site-design

## Summary
- **Feature**: `pages-doc-site-design`
- **Discovery Scope**: Extension（既存の `github-pages-docs` spec で有効化済みの GitHub Pages / Jekyll 標準ビルドへの拡張）
- **Key Findings**:
  - `docs/sdd/**` の md は front-matter が無くても、GitHub Pages の既定プラグイン（`jekyll-optional-front-matter` /
    `jekyll-default-layout` / `jekyll-titles-from-headings`）により Jekyll の Page オブジェクトとして
    処理され、`_config.yml` の `defaults` で `layout: page` が適用されている（実サイトの class 名で確認済み）。
  - 同じ仕組みにより `page.title` は各 md の先頭 `# 見出し` から自動抽出される（front-matter に `title:` を
    書く必要がない）。全 `docs/sdd/**` md が先頭 H1 を持つことを確認済み。
  - Jekyll の Page オブジェクトは `page.dir`（そのページの URL ディレクトリ）を自動的に持つため、
    `site.pages` を `page.dir` でグルーピングすれば、ディレクトリ構成をそのままナビ構造として使える
    （個別ページへの front-matter 追記は不要）。
  - 実サイトの HTML には `post`, `post-header`, `post-title`, `post-content`, `page-content`,
    `site-header` 等 minima 標準のクラスが出力されている＝ README・`docs/sdd/**` とも minima の
    `page.html`（→ `default.html`）レイアウトを経由している。

## Research Log

### site.pages を使ったナビ生成の実現可能性
- **Context**: `docs/sdd/**` の md を無改変のまま、サイドバーナビをどう構築するか。
- **Sources Consulted**: 実サイト（https://kyamady-dorokid.github.io/sdd_base_template/ ）の
  HTML 出力（`curl` で取得・確認）、`_config.yml`（既存 `defaults`/`exclude` 設定）。
- **Findings**:
  - `site.pages`（Jekyll のビルトイン変数）には、front-matter defaults 経由でページ化された
    `docs/sdd/**` の md も含まれる（`exclude` 済みディレクトリは除く）。
  - `page.dir` でグルーピングすれば、`docs/sdd/`・`docs/sdd/rules/`・`docs/sdd/templates/` と
    ルート（README）を自然に分離できる。
- **Implications**: Liquid テンプレート（`_includes/sidebar.html`）から `site.pages` を
  走査するだけでナビが構築でき、`docs/sdd/**` の個別ファイルには一切手を加えない設計が成立する。

### レイアウトのオーバーライド方式
- **Context**: サイドバー付きのページ構造をどこに実装するか。minima の `default.html` を丸ごと
  複製すると、ヘッダー/フッター/ソーシャルリンク等の再現漏れで既存表示が壊れるリスクがある。
- **Findings**: Jekyll はプロジェクト直下に同一相対パスのファイルを置くと、テーマ gem 側のファイルを
  上書きする（レイアウト単位で選択的に上書き可能）。`page.html` 自身の front-matter で
  `layout: default` を維持すれば、`default.html`（ヘッダー・フッター・`<head>`等）はテーマの
  ものをそのまま使い続けられる。
- **Implications**: 上書き対象を `_layouts/page.html` のみに限定し、`default.html` は一切
  複製・変更しない。既存のヘッダー/フッター/SEO関連出力への影響を最小化できる。

### minima の CSS カスタマイズ方式
- **Context**: 見出し・コードブロック・表の視認性を、md 本文を変えずに強化する方法。
- **Findings**: minima は `assets/main.scss`（`---\n---\n@import "minima";` のみを持つ薄いエントリ
  ポイント）を提供しており、プロジェクト直下に同名ファイルを置くとテーマ側を上書きできる、という
  標準的な拡張ポイントである。`@import "minima";` の後に追加の SCSS ルールを書けば、minima の
  変数・基本スタイルを維持したまま見た目を拡張できる。
- **Implications**: 新規ファイル `assets/main.scss` を追加し、サイドバーレイアウト用のグリッド
  CSS と、見出し／コードブロック／表の視認性向上ルールをここに集約する。

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| `site.pages` 走査でナビ自動生成（採用） | `_includes/sidebar.html` が `site.pages` を `page.dir` でグルーピングして描画 | md 本文・front-matter 変更ゼロ。新規ページも自動反映（Req 1.4） | 想定外のディレクトリが増えた場合のグループ表示ラベルはフォールバックが必要 | 採用。フォールバックラベルを設計に含める |
| 手動ナビ定義（`_data/nav.yml` に手書きリスト） | ナビ項目を YAML で明示管理 | 表示順を完全制御できる | ページ追加のたびに YAML 更新が必要＝ Req 1.4（自動反映）を満たさない | 却下 |
| just-the-docs 等ナビ内蔵テーマへの切替 | テーマ機能でサイドバーを自動生成 | 実装量が少ない | 各ページの front-matter（`nav_order` 等）が前提＝ `docs/sdd/**` 無改変の制約と衝突 | 却下（`github-pages-docs` spec で既に却下済み） |

## Design Decisions

### Decision: サイドバーナビは `site.pages` 走査＋`page.dir` グルーピングで生成する
- **Context**: Req 1（サイドバーナビ）と Req 3.1/3.4（`docs/sdd/**` 無改変・front-matter 不要でも適用）
  を両立する必要がある。
- **Alternatives Considered**:
  1. `_data/nav.yml` に手書きリスト — ページ追加のたびに手動更新が必要
  2. front-matter に `nav_order` 等を書くテーマ機能 — `docs/sdd/**` 無改変の制約と衝突
- **Selected Approach**: `_includes/sidebar.html` から `site.pages` を走査し、`page.dir` でグループ化。
  ディレクトリパス → 表示ラベルの対応表（README＝トップ、`docs/sdd/`・`docs/sdd/rules/`・
  `docs/sdd/templates/`）を持たせ、未知のディレクトリはディレクトリ名をそのままラベルにフォールバックする。
- **Rationale**: 個別 md への変更が一切不要で、`docs/sdd/**` への新規ファイル追加が自動的にナビへ反映される。
- **Trade-offs**: グループの表示順・ラベルの美しさは手動定義より劣るが、保守コストと制約遵守を優先。
- **Follow-up**: 実装後、実サイトで新規ダミーページを一時的に置いて自動反映を目視確認する（テスト戦略参照）。

### Decision: レイアウト拡張は `_layouts/page.html` のみを上書きし、`default.html` は複製しない
- **Context**: サイドバー用の DOM 構造を追加しつつ、既存のヘッダー/フッター/SEO出力を壊さないようにしたい。
- **Alternatives Considered**:
  1. `_layouts/default.html` を丸ごと複製してサイドバーを追加 — テーマの将来更新に追従できず、
     ヘッダー/フッターの再現漏れリスクがある
- **Selected Approach**: `_layouts/page.html` を新規追加（テーマ側を上書き）。front-matter で
  `layout: default` を維持し、`default.html`（ヘッダー・フッター）はテーマ標準のものを使い続ける。
  `page.html` の中身にサイドバー（`{% include sidebar.html %}`）とメインコンテンツ領域を追加する。
- **Rationale**: 変更範囲を最小化し、テーマ標準機能（ヘッダー検索・ソーシャルリンク等）への影響を避ける。
- **Trade-offs**: サイドバーは `page` レイアウトを使うページのみに表示される
  （`post`/`home` レイアウトは対象外だが、本サイトに投稿記事は存在しないため実質全ページに適用される）。
- **Follow-up**: 実装後、README（トップ）が引き続き `page` レイアウトで描画されることを実サイトで確認する
  （`github-pages-docs` spec の検証時点で確認済みだが、レイアウト上書き後も回帰確認する）。

## Risks & Mitigations
- サイドバー生成 Liquid ロジックの記述ミスでビルドが失敗する — 実装後に必ず実際の Pages ビルド
  （`gh api .../pages/builds/latest`）で `status: built` を確認する（ローカルに Jekyll ツールチェーンが
  無い環境のため、実ビルドでの検証を主とする）。
- `_layouts/page.html` 上書きにより、将来 minima のバージョンアップで `default.html` 側の構造が変わった際に
  `page.html` との整合が崩れる可能性 — `default.html` は複製しないため影響範囲は限定的。将来的な
  非互換は `github-pages-docs` / 本 spec の revalidation trigger として記録する。

## References
- [GitHub Pages: Dependency versions](https://pages.github.com/versions/) — GitHub Pages で有効化される
  既定プラグイン（`jekyll-optional-front-matter` / `jekyll-default-layout` / `jekyll-titles-from-headings` /
  `jekyll-readme-index` / `jekyll-relative-links` 等）の一覧。
- [Jekyll Docs: Overriding theme defaults](https://jekyllrb.com/docs/themes/#overriding-theme-defaults) —
  プロジェクト直下の同一相対パスファイルでテーマの `_layouts`/`_includes`/`assets` を上書きできる仕組み。
