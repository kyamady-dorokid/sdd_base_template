# 合意形成記録: GitHub Pages でのドキュメント公開（github-pages-docs）

| 項目 | 内容 |
|---|---|
| タスクID | `github-pages-docs` |
| 作成日 | 2026-07-13 |
| 関係者 | KYamada / Claude Code |
| Tier | S（設定追加中心・低リスク） |

---

## 壁打ち概要

README と docs/sdd を GitHub Pages で公開したい、という要望。壁打ちで方式を確定した。

### 発見した重要制約
`docs/sdd/**` は overlay 配布物（`payload/overlay/docs/sdd/`）の sync コピー。Pages 化のために
これらの md 本文に front-matter 等を加えると、payload 側なら全ターゲットへ混入、ルート側だけなら
sync コンフリクトになる。→ **md 本文は非改変**とし、`_config.yml` の `defaults` でレイアウト適用する。

## 決定事項（壁打ちで確定）

| # | 決定 | 理由 | 決定日 |
|---|---|---|---|
| 1 | 公開内容は (B) ドキュメントサイト（README トップ＋docs/sdd 章立て） | SDD ルールの参照ハブ。テンプレートの性質に最適 | 2026-07-13 |
| 2 | 生成方式は Jekyll（Pages 標準）＋minima＋`_config.yml` の `defaults`＋`jekyll-relative-links` | CI・重い依存なし。docs/sdd 本文を無改変でサイト化でき sync 安全 | 2026-07-13 |
| 3 | トップページは README を index にする | 重複を避ける | 2026-07-13 |
| 4 | Pages 有効化は Claude が `gh api` で実施 | ユーザー指示 | 2026-07-13 |

### 却下・保留
| 内容 | 理由 |
|---|---|
| just-the-docs テーマ | ナビ順に front-matter を推奨し、md 非改変の制約と相性が悪い |
| MkDocs/Docusaurus＋Actions | 依存とCIが増え「重い依存を持ち込まない」思想に逆行 |
| docs/sdd の md への front-matter 追加 | sync 安全性を破壊するため禁止 |

---

## フェーズゲート承認記録

> 承認状態の正本は `spec.json`。ここでは経緯のみ。

| フェーズ | 合意メモ |
|---|---|
| 要件定義（requirements.md） | 壁打ち決定1〜4を反映して起票。**承認待ち** |
| 設計（design.md） | 未着手。要件承認後に着手 |
| タスク分解（tasks.md） | 未着手 |

---

## 変更履歴

| 日付 | 変更内容 | 変更者 |
|---|---|---|
| 2026-07-13 | 初版作成。壁打ちで方式（Jekyll+minima+defaults・md非改変・README index・gh api有効化）を確定し requirements 起票 | Claude Code |
