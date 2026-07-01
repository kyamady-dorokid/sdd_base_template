# 合意形成記録: sdd_base_template 上流改修（Part A/B/C）

| 項目 | 内容 |
|---|---|
| タスクID | `sdd-base-upstream-fix` |
| 作成日 | 2026-07-01 |
| 関係者 | KYamada / Claude Code |
| 由来 | `cyclox2_docker` の `docs/specs/sdd-base-template-upstream-fix/agreement-log.md`（引き継ぎ元）。本リポジトリ側の実装記録として起票 |

---

## 壁打ち概要

`cyclox2_docker` の SDD 運用中に、独自ルール「非コーディング作業のドキュメント化（重要）」が
上流テンプレート `sdd_base_template` の `init` による `docs/sdd/` 無条件上書きで消失した事象を契機に、
上流へ以下3点の改修を行う（前セッションで承認済みスコープ、引き継ぎブリーフを本タスクへ移送）。

- **Part A: ルール反映** — 独自ルールを overlay へ恒久反映し、再init/updateで消えないようにする。
- **Part B: 安全な更新機構** — 運用中リポジトリへテンプレ更新を安全反映する `sync` 機構（3-wayマージ+lock）。
- **Part C: agreement-log.md 必須化** — `/kiro-*` フルフローで agreement-log.md が自動生成されない問題を解消。

引き継ぎ元での決定（`.kiro/specs/<id>/` 一元化採用、PR #20クローズ）は確定済みとして踏襲する。

### 現状検証（2026-07-01, `sdd_base_template` `main`=`75d12e0`）

| 検証項目 | 結果 |
|---|---|
| `payload/overlay/docs/sdd/workflow.md` に「非コーディング作業のドキュメント化」節 | **なし**（A1は新規追加＝非衝突） |
| `payload/overlay/docs/sdd/rules/` | branching / commit / environment-boundary / testing の4本（A2でsecurityを**5本目**として追加） |
| `payload/validation/patches/` | `fix-impl-team-policy.sh` / `fix-design-template.sh` の2本（Cで3本目を追加） |
| `payload/KNOWN_GOOD_CCSDD_VERSION` | `3.0.2`（A3: 変更しない） |
| `kiro-spec-init/SKILL.md`（`.claude`/`.agents` 両方）が agreement-log.md を生成するか | **生成しない**（Cのバグ実在を確認） |
| snippets パリティ（`CLAUDE.sdd.md` == `AGENTS.sdd.md`） | IDENTICAL |

---

## 決定事項

| # | 決定内容 | 決定理由 | 決定日 |
|---|---|---|---|
| 1 | SDD成果物の置き場所は上流の `.kiro/specs/<id>/` 一元化を採用（引き継ぎ元決定を踏襲） | 上流 `main` が既に一元化を確定運用。逆らうより追随が長期整合的 | 2026-07-01 |
| 2 | 本タスクの実装記録は `sdd_base_template` 自身の規約に従い `.kiro/specs/sdd-base-upstream-fix/` に残す | ドッグフーディング。CLAUDE.md ルール4 | 2026-07-01 |
| 3 | Part A/B/C は複数PRに分割する（下記「実装方針」）。`main` 直コミット禁止・ブランチ→PR | Part B が大規模かつ破壊的操作を伴うため、A/C（小・追記的）と分離してレビュー粒度を保つ | 2026-07-01 |

---

## 却下・保留事項

| 内容 | 理由 |
|---|---|
| Part A/B/C を単一PRで実装 | Part B（3-wayマージ+lock+snapshot＝新規`sync`コマンド）が大規模・破壊的で、A/Cの低リスク追記とレビュー粒度が乖離するため分割 |
| `cyclox2_docker` 側の `docs/specs/`→`.kiro/specs/` 追随移行 | 本タスクのスコープ外（引き継ぎ元 §8 の将来課題として別タスク化） |
| `sdd_base_template` 自身の旧レイアウト遺構（`docs/specs/env-boundary-policy/` 等）の整理 | 本タスクスコープ外（触れる場合は別途要相談。引き継ぎ元 §5 末尾） |

---

## 実装方針（PR分割案・**PR-1 承認済み／実装済み**）

> PR-1（Part A + C）は人間承認済み（「これでOK」2026-07-01）。実装・検証完了（test-results.md 参照）。
> PR-2（Part B）は未着手（PR-1 マージ後に設計フェーズから開始）。

### PR-1: Part A + Part C（ルール反映 + agreement-log 必須化）— 低リスク・追記的

- **A1**: `payload/overlay/docs/sdd/workflow.md` に「非コーディング作業のドキュメント化（重要）」節を
  `.kiro/specs/<id>/` 一元化前提で統合追加（引き継ぎ元 §1-2 原文の二重レイアウト文言を除去して反映）。
- **A2**: `cyclox2_docker/docs/sdd/rules/security-policy.md` を汎用化し
  `payload/overlay/docs/sdd/rules/security-policy.md` として追加（`MYSQL_*`/`cyclox2_mysql` → 汎用名）。
  snippets（`CLAUDE.sdd.md`/`AGENTS.sdd.md`）の「ベースルールの所在」に**同一変更で**リンク追加。
- **A3**: `KNOWN_GOOD_CCSDD_VERSION` は `3.0.2` のまま（変更なし）。
- **C-Layer1**: snippets / workflow.md に「agreement-log.md をファイルとして実在させる」旨を補強（過剰な書換不可）。
- **C-Layer2**: `payload/validation/patches/ensure-agreement-log.sh` を新規作成
  （`fix-impl-team-policy.sh` の冪等マーカー追記パターンを踏襲）。`kiro-spec-init/SKILL.md`
  （`.claude`/`.agents` 両方）に、無ければ `docs/sdd/templates/agreement-log.md` から生成するステップを注入。
- **検証**: `payload/validation/checks.md` の C2 にパッチ追加、A系のルールファイル存在チェック追記。
  空ディレクトリで `node bin/cli.js init` → pre/post 検証 PASS を確認。

### PR-2: Part B（安全な更新機構 `sync`）— 大規模・破壊的操作を含む

- 破壊的操作（ローカル上書き）を伴うため、**requirements/design/tasks + spec.json でフルフロー**を踏む。
- 設計要点（引き継ぎ元 §3 の設計ドラフトを再検証の上、design.md に確定）:
  lock（`.kiro/sdd-base.lock`）/ snapshot（`.kiro/sdd-base-snapshot/`）/ 3-wayマージ（`git merge-file`）/
  マーカーブロック単位マージ / コンフリクトは `<file>.new`+レポート（サイレント上書き厳禁）/
  新コマンド名は `update` と衝突するため `sync` を採用 / 実行後は必ず人間へ差分提示・自動コミットなし。
- **TDD**（テスト先行）。`payload/validation/checks.md` に lock整合性・ローカル変更保持のチェック追加。
  README「その他の使い方」に `sync` の説明追加。

---

## フェーズゲート承認記録

> 承認状態の正本は `.kiro/specs/sdd-base-upstream-fix/spec.json`（Part B着手時に作成）の
> `approvals.{requirements,design,tasks}.approved`。ここでは経緯・補足のみ。

| フェーズ | 合意メモ（理由・補足） |
|---|---|
| 要件定義（requirements.md） | Part A/C は引き継ぎ元で承認済みスコープを踏襲。Part B は着手時に要件定義を明文化 |
| 設計（design.md） | Part B の3-wayマージ設計は引き継ぎ元 §3 ドラフトを再検証して確定させる |
| タスク分解・実装前確認（tasks.md） | PR分割案（PR-1: A+C / PR-2: B）の人間承認を待って着手 |

---

## 変更履歴

| 日付 | 変更内容 | 変更者 |
|---|---|---|
| 2026-07-01 | 初版作成。引き継ぎ元（cyclox2_docker）の決定を移送し、現状検証・PR分割案を記録 | Claude Code |
| 2026-07-01 | PR分割案を人間承認。PR-1（Part A+C）実装・検証完了（test-results.md 追加） | Claude Code |
