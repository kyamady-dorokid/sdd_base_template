# テスト結果記録: github-pages-docs

| 項目 | 内容 |
|---|---|
| タスクID | `github-pages-docs` |
| 実行日 | 2026-07-13 |
| 実行者 | Claude Code |
| テストフレームワーク | bash（既存 tests/run.sh）＋実URL確認（curl / gh api） |
| 実行コマンド | `bash tests/run.sh` / `node bin/cli.js sync --yes` / `gh api .../pages` / `curl` |
| 実行環境 | ローカル（macOS） |

---

## テスト項目一覧

| # | テスト項目名 | 観点 | 期待結果 | 実際結果 | 合否 |
|---|---|---|---|---|---|
| 1 | `_config.yml` の YAML 妥当性 | 正常系 | パース可能 | `ruby -ryaml` でパース成功 | ✅ |
| 2 | `docs/sdd/**` 無改変確認 | 回帰 | `git diff` に docs/sdd の変更なし | 差分なし | ✅ |
| 3 | `bash tests/run.sh` 全PASS | 回帰 | 145件 PASS・失敗0 | Total: 145, Failed: 0 | ✅ |
| 4 | `node bin/cli.js sync --yes` 後の docs/sdd 非影響 | sync安全性 | 差分・コンフリクトなし | 差分・コンフリクトなし（レポートに「そのまま更新」のみ） | ✅ |
| 5 | GitHub Pages 有効化 | 正常系 | `gh api` で有効化成功（source=main, path=/, legacy build） | `html_url: https://kyamady-dorokid.github.io/sdd_base_template/` を確認 | ✅ |
| 6 | Pages ビルド状態 | 正常系 | `status: built` | 5回目のポーリングで `built` | ✅ |
| 7 | トップページ表示（README） | 正常系 | 200・README内容表示 | HTTP 200、title に repo description、README本文を含むことを確認 | ✅ |
| 8 | `docs/sdd/workflow` 代表ページ表示 | 正常系 | 200 | HTTP 200、title「SDD ワークフロー定義」 | ✅ |
| 9 | 相対リンク解決（README → docs/sdd/workflow） | 正常系 | `.md` → `.html` に解決 | `href="/sdd_base_template/docs/sdd/workflow.html"` を確認 | ✅ |

---

## 実行結果サマリー

| 合計 | 合格 | 失敗 | スキップ |
|---|---|---|---|
| 9 | 9 | 0 | 0 |

---

## 失敗項目の詳細

なし。

---

## 備考

- README 内に本 spec のスコープ外の既存リンク `payload/overlay/docs/sdd/workflow.md` があり、`payload/` はサイトから除外しているため公開サイト上では 404 になる。design.md が対象とした「公開サイトへの1行リンク」とは別記述であり、本 spec のスコープ外（out of scope: docs/sdd 本文以外の既存README記述の修正）のため今回は修正していない。ユーザーへ報告済み・対応要否は未確認（フォローアップ候補）。
- `index.md` フォールバックは不要だった（`jekyll-readme-index` により README が正しく index 化された）。
