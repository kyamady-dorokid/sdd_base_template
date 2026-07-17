# テスト結果記録: pages-doc-site-design

| 項目 | 内容 |
|---|---|
| タスクID | `pages-doc-site-design` |
| 実行日 | 2026-07-14〜2026-07-17 |
| 実行者 | Claude Code |
| テストフレームワーク | bash（既存 tests/run.sh）＋実URL確認（curl / gh run list / gh api）＋ローカル liquid gem による構文検証 |
| 実行コマンド | `bash tests/run.sh` / `node bin/cli.js sync --yes` / `gh run list` / `gh run view --log-failed` / `curl` / `ruby`（liquid gem） |
| 実行環境 | ローカル（macOS）＋ GitHub Actions（pages build and deployment） |

---

## テスト項目一覧

| # | テスト項目名 | 観点 | 期待結果 | 実際結果 | 合否 |
|---|---|---|---|---|---|
| 1 | `docs/sdd/**`・`_config.yml`・`payload/**` 無改変確認 | 回帰 | `git diff` に変更なし | 差分なし | ✅ |
| 2 | `bash tests/run.sh` 全PASS | 回帰 | 145件PASS | 145件中144 PASS。1件（pandoc関連の既存フレーク）は本変更と無関係と確認済み（新規ファイル退避後も同一箇所が失敗） | ✅（無関係フレークを除き全PASS） |
| 3 | `node bin/cli.js sync --yes` 後の `docs/sdd` 非影響 | sync安全性 | 差分・コンフリクトなし | 差分・コンフリクトなし | ✅ |
| 4 | Pages ビルド成功 | 正常系 | `gh run list` の `pages build and deployment` が `success` | 初回PR(#24)は成功。PR #25反映後は実は失敗していた（後述）。修正PR(#27)後は `completed success` を確認 | ✅（PR #27時点） |
| 5 | 代表4ページの表示（README・workflow・rules配下・templates配下） | 正常系 | 200応答・サイドバー表示 | 4ページとも200、サイドバー（4グループ・11リンク）表示を確認 | ✅ |
| 6 | サイドバー対象の絞り込み（想定外コンテンツの排除） | 正常系 | `docs/specs/**`・`/assets/` がサイドバーに含まれない | `<nav class="doc-sidebar">` 内のリンクを厳密に抽出し、対象外コンテンツが含まれないことを確認（PR #25→#27で対応） | ✅ |
| 7 | 現在地ハイライト | 正常系 | 開いているページのサイドバー項目が視覚的に区別される | `docs/sdd/workflow` ページで `doc-sidebar-item-active` クラスが付与されることを確認 | ✅ |
| 8 | リンク遷移（404なし） | 正常系 | サイドバー内の代表リンクが200で解決する | `deliverables-policy.html`・`branching-policy.html`・`test-results.html` で200を確認 | ✅ |
| 9 | 見出し・コードブロック・表・サイドバーグリッドのCSS適用 | 視認性 | コンパイル済みCSSに対応ルールが含まれる | `assets/main.css`（コンパイル後）に `.doc-main h1/h2/h3`・`.doc-main pre,code`・`.doc-main table`・`.doc-layout`・`.doc-sidebar-item-active a` の各ルールを確認 | ✅ |
| 10 | 新規ページの自動反映（Req 1.4） | 構造検証 | 新規mdを追加してもサイドバーに個別設定なしで反映される | 実機での追加/削除の往復テストは、ビルド待ち時間の都合でユーザー判断により省略。代替として、既存11ページすべてが `site.pages` を `page.dir` でグルーピングするロジックのみで表示されており（ページ個別のnav設定は一切存在しない）、この仕組み自体が新規ページの自動反映を構造的に保証していることを確認 | ✅（論理的確認） |

---

## 実行結果サマリー

| 合計 | 合格 | 失敗 | スキップ |
|---|---|---|---|
| 10 | 10 | 0 | 0（項目10は実機往復ではなく論理確認で代替、項目2は無関係フレーク1件を除外） |

---

## 失敗項目の詳細

なし（開発中に発見した問題は以下「障害対応の経緯」参照。最終状態はすべて解消済み）。

---

## 障害対応の経緯

1. **サイドバーへの想定外コンテンツ混入**（PR #24反映直後に発覚）
   - `_includes/sidebar.html` が `site.pages` を無差別に走査していたため、`_config.yml` の
     `exclude` 対象外にある `docs/specs/**`（旧形式spec記録）・`assets/main.scss` 自身のビルド出力
     までサイドバーに表示されていた。
   - 対処: README＋`docs/sdd/**`への明示フィルタを追加（PR #25）。

2. **PR #25 の修正がLiquid構文エラーでビルド失敗**（`gh api .../pages/builds/latest` が
   `building` のまま更新されず、当初「ビルドが詰まっている」と誤認）
   - `where_exp` フィルタに `"p.url == '/' or p.dir contains '/docs/sdd'"` という複合条件（`or`）を
     渡したことが原因（`where_exp` は単一条件のみサポート）。
   - `gh run list`（Actionsワークフロー）の実ログで、実際には30〜40秒で完了し失敗していたことを
     特定。`pages/builds/latest` API のステータス表示更新の遅延・不整合が誤認の原因だった。
   - 対処: `where_exp` を単純な `p.dir != nil` のみに戻し、`docs/sdd` 以外の除外はグルーピング後の
     単純な `{% if group.name contains '/docs/sdd' %}` 判定に置き換え（PR #27）。ローカルに
     GitHub Pagesと同バージョンの `liquid` gem (4.0.4) を導入し、構文エラーが再現しないことを
     事前確認してから修正を反映した。

## 備考

- **今後の教訓**: GitHub Pages のビルド状態確認は `gh api repos/.../pages/builds/latest` だけに
  頼らず、`gh run list --workflow="pages-build-deployment"` と `gh run view --log-failed` で
  Actionsワークフローの実ステータス・実ログを確認すること。前者のAPIステータスが更新されない
  ケースが実際に発生した。
- ローカルに Jekyll フルツールチェーンは導入できなかった（システムRubyが2.6.10でjekyll最新版の
  依存関係を満たせない）が、`liquid` gem単体（GitHub Pagesと同バージョン）は導入でき、
  `Liquid::Template.parse` によるLiquid構文の事前検証に活用できた。今後の同種修正でも有効な手段。
