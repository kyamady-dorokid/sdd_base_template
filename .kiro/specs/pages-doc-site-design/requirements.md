# Requirements Document

## Introduction

`github-pages-docs` spec で有効化した GitHub Pages 公開サイト
（https://kyamady-dorokid.github.io/sdd_base_template/ 、現状は minima テーマの素の状態）の
デザインを、ドキュメントサイト風（サイドバーナビ・見出しの視認性重視）に強化する。

`docs/sdd/**` は overlay 配布物の sync コピーであり、md 本文の改変（front-matter 追加等）は
`github-pages-docs` spec の合意で既に禁止されている。本 spec もこの制約を継承し、md 本文を
一切改変せずに `_config.yml`・レイアウト・スタイルシート等のサイト側資産のみでデザインを実現する。

## Boundary Context

- **In scope**:
  - サイト全体（README トップ＋ `docs/sdd/**` の全ページ）に適用されるサイドバーナビゲーションの追加。
  - 見出し・本文・コードブロック等の視認性向上（スタイル調整）。
  - これらを実現するためのサイト側資産（`_config.yml`・`_layouts/`・`_includes/`・`assets/` 等、
    いずれもリポジトリ root 直下の非 md ファイル）の追加・変更。
- **Out of scope**:
  - `docs/sdd/**` の md 本文の改変（front-matter 追加・見出し構造の変更等）。
  - `payload/overlay/**`（配布物）の変更。
  - GitHub Actions 等 CI パイプラインの追加、MkDocs/Docusaurus 等別ジェネレータへの切り替え。
  - サイトの掲載内容そのものの変更・追加（`github-pages-docs` spec の範囲）。
- **Adjacent expectations**:
  - 本 spec は `github-pages-docs` spec が有効化済みの Pages 公開・`_config.yml` の基本設定
    （exclude・README index 化・相対リンク解決）を前提とし、それらを壊さないこと。
  - 本テンプレートの「重い依存を持ち込まない」思想を維持する。

## Requirements

### Requirement 1: サイト全体のナビゲーション
**Objective:** サイト訪問者として、公開サイト内でどのページを見ているか把握し、他のドキュメント
（README・`docs/sdd/**` の各ページ）へ迷わず移動したい。そうすればリポジトリを clone せずに
ドキュメント全体を効率よく参照できる。

#### Acceptance Criteria
1. When 訪問者が公開サイトの任意のページを表示した場合, the サイト shall README（トップ）と
   `docs/sdd/**` の全ページ（workflow・deliverables-policy・rules 配下・templates 配下を含む）
   へのリンクを含むサイドバーナビゲーションを表示する。
2. The サイドバーナビゲーション shall 現在表示中のページを視覚的に区別して示す。
3. When 訪問者がサイドバーナビゲーションのリンクをクリックした場合, the サイト shall 対応する
   ページへ遷移し、404 を発生させない。
4. Where 新しいページが `docs/sdd/**` に追加された場合, the サイドバーナビゲーション shall
   （個別 md への追記作業なしに）そのページを一覧に反映する。

### Requirement 2: 見出し・本文の視認性
**Objective:** サイト訪問者として、長い運用ドキュメントでも見出し階層や本文・コードブロックを
すぐに見分けたい。そうすれば必要な情報を素早く見つけられる。

#### Acceptance Criteria
1. The サイト shall 見出しレベル（h1〜h3 相当）を、フォントサイズ・余白・太さ等で視覚的に区別して表示する。
2. The サイト shall コードブロック（フェンスドコード・インラインコード）を本文と視覚的に区別して表示する。
3. The サイト shall 表（テーブル）を罫線・行間等で読みやすく表示する。

### Requirement 3: 既存制約の遵守
**Objective:** メンテナとして、デザイン強化が `docs/sdd/**` の sync 安全性や「重い依存を持ち込まない」
方針を壊さないでほしい。

#### Acceptance Criteria
1. The デザイン強化 shall `docs/sdd/**` の md 本文（front-matter を含む）を一切変更しない。
2. The デザイン強化 shall GitHub Pages 標準の Jekyll ビルドで完結し、GitHub Actions 等の
   カスタムビルドパイプラインを追加しない。
3. The デザイン強化 shall `payload/overlay/**`（配布物）を変更しない。
4. Where `docs/sdd/**` の md に front-matter が存在しない場合でも, the サイト shall
   Requirement 1・2 のナビゲーション・視認性向上を適用する。

### Requirement 4: 非デグレ検証
**Objective:** メンテナとして、デザイン強化後も公開サイトが問題なくビルド・表示され、既存の
sync 運用が壊れていないことを確認したい。

#### Acceptance Criteria
1. When デザイン強化後のサイトがビルドされた場合, the Pages ビルド shall エラーなく成功する。
2. After デザイン強化を適用した場合, the サイト shall README（トップ）・`docs/sdd/workflow` を含む
   既存の代表ページへ引き続き 200 応答でアクセスできる。
3. When `docs/sdd/**` を対象に `sync` を実行した場合, the サイト設定変更 shall コンフリクトや
   差分を生じさせない（md 本文が payload と一致し続ける）。
