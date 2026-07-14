# 合意形成記録: GitHub Pagesサイトのデザイン強化（pages-doc-site-design）

| 項目 | 内容 |
|---|---|
| タスクID | `pages-doc-site-design` |
| 作成日 | 2026-07-13 |
| 関係者 | KYamada / Claude Code |

---

## 壁打ち概要

`github-pages-docs` spec で公開したPagesサイト（minimaテーマの素の状態）について、
「もっとデザイン性高くできるか」という相談を受けた。front-matterの説明を挟みつつ、
方向性を選んでもらった。

## 決定事項

| # | 決定内容 | 決定理由 | 決定日 |
|---|---|---|---|
| 1 | 方向性は「ドキュメントサイト風に整える」（サイドバーナビ・見出しの視認性重視） | ユーザー選択。just-the-docs風の見た目を目指すが、front-matter依存は避ける | 2026-07-13 |
| 2 | 実現方式は minimaベースのCSS/layoutカスタマイズ、または front-matter不要な代替手段を検討する（要件定義で具体化） | `docs/sdd/**` 無改変・重い依存を持ち込まない、という `github-pages-docs` spec の制約を継承 | 2026-07-13 |

## 却下・保留事項

| 内容 | 理由 |
|---|---|
| just-the-docs等front-matter依存テーマへの丸ごと差し替え | `github-pages-docs` specのagreement-logで既に却下済み（`docs/sdd/**`無改変の制約と衝突） |

---

## フェーズゲート承認記録

> 承認状態の正本は `spec.json`。ここでは経緯のみ。

| フェーズ | 合意メモ |
|---|---|
| 要件定義（requirements.md） | 生成済み（Req1: ナビゲーション / Req2: 視認性 / Req3: 既存制約遵守 / Req4: 非デグレ検証）。**承認済み**（2026-07-13、ユーザー「すすめて」） |
| 設計（design.md） | 生成済み（`_layouts/page.html`／`_includes/sidebar.html`／`assets/main.scss` の新規追加のみ、`docs/sdd/**`・`_config.yml`・`payload/**`は無変更）。**承認済み**（2026-07-13、ユーザー「承認」） |
| タスク分解（tasks.md） | 生成済み（5メジャータスク・独立サニティレビュー PASS）。**承認済み**（2026-07-13、ユーザー「よい」） |

---

## 変更履歴

| 日付 | 変更内容 | 変更者 |
|---|---|---|
| 2026-07-13 | 初版作成。壁打ちで方向性（ドキュメントサイト風・front-matter不使用）を確定し requirements 起票 | Claude Code |
