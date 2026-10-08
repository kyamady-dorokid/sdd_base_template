# Task D 開始資料: doc-export・人間向け二次成果物

> 状態: 開始資料作成済み・人間確認待ち。壁打ち未開始。
> 基準: PR #45 merge commit `2de65ff38413b338fc4f2568481e77f234838903`。
> Issue #41の専用壁打ちへ渡す派生入力。標準SDD文書・仕様・承認の正本ではない。
> 採用済み判断は `../agreement-log.md`、承認状態は `../spec.json` を参照する。

## 目的と権限

doc-exportを、正本Markdownから人間が理解・判断しやすい二次成果物を構成する機能として具体化する。
人間との壁打ちは一度に一論点とし、推奨案、代替案、具体的な失敗例を提示する。
専用sessionは調査・対話・handoff・正本化確認だけを行う。ファイル編集、Issue更新、実装、
template作成、Requirements/Design/Tasks生成、commit/push/PR、renameは行わない。
正本への反映はorchestratorが所有する。矛盾・追加判断は人間へ戻す。

## 維持する合意

- Task A / #67〜#76・#111〜#112: 既存spec・証跡を壊さない。doc-exportはSDD Rig固有機能で、Claude Code/Codex双方を支援する。
- Task B / #84〜#92・#113〜#116: 外部package、CLI、templateの採用は依存導入・帰属の契約に従う。
  利用project所有のoverrideや未知設定を通常更新で書き換えない。具体packageの採用は今回決めない。
- Task C / #98〜#110: Markdownが正本。二次成果物は一方向生成で手編集しない。
  人間承認は正本とspec.jsonに残し、恒久guideとnavigationから判断対象へ到達する。
  日本語の具体性、未決・未検証の明示、根拠と過去証跡の追跡を維持する。
- #93〜#97: 大容量のPDF、画像、render logを会話へ無制限に再投入しない。
- #117〜#119: handoffの項目別照合と、元sessionによる正本反映後の確認を必須とする。
- 中間成果物の保存は任意という合意を維持し、外部Drive保存を必須に戻さない。
- main worktreeのoutputs案は既存の検討入力として保持する。workspace隔離との整合はTask Fと確認し、
  共有先への無条件書込み、衝突、PII保存、worktree削除後の発見性を未決のまま成功扱いしない。

## 現行と目標の差

現行の `docs/sdd/deliverables-policy.md` と `payload/overlay/skills/doc-export/SKILL.md` は、
Word中心・manifestによる全文または節抽出・未導入rendererの未生成報告を規定している。
CLIはpackage経由で実行し、生成報告を出す。現行契約と実際の実装の一致は必要箇所を調査して確認する。

Issue #41の合意方向は、指定がなければ既定PPT templateと成果物profileを使うpresentation機能。
この方向性から、自動生成の頻度、要約の許容範囲、renderer同梱方式まで決定済みとは解釈しない。

## 壁打ちの順番

| ID | 判断すること | 具体的に確認する例 |
|---|---|---|
| D-1 | 二次成果物の用途と承認境界 | PPTだけを読んだ人が未掲載の例外条件を承認してしまわないか。正本への案内をどう示すか |
| D-2 | 生成の契機・形式・phase別profile | 明示依頼時の既定PPTか、gateごとの自動生成か。requirements/design/tasks/statusとWord/PDFの役割 |
| D-3 | 並べ替え・要約・言換え・図表化の許容範囲 | 否定、例外、条件、未決、riskを削らない。新しい判断を図に混入させない |
| D-4 | 出典対応と鮮度・網羅性 | 正本ID/節/hashとslide対応、未収録情報、source変更後のstale、部分成功を追跡する |
| D-5 | 既定templateとproject override | 共通themeとphase別構成、日本語、長い表・図、利用者指定、帰属と更新互換性 |
| D-6 | 品質と失敗の判定 | 文字化け、overflow、図欠落、参照切れ、意味欠落、renderer未導入。自動検査とvisual QAの分担 |
| D-7 | 保存・起動・費用と後続責務 | 出力先の提示、PII、任意中間保存、並行生成、再生成、自然言語/明示起動、Token負荷 |

最初はD-1だけを扱う。「理解・共有と正本への案内を担うPPT」を推奨候補として提示し、
PPTの生成成功・見た目の確認・正本の承認をそれぞれどの行為とするか、人間と具体例で確認する。
Task Cの正本直接確認と衝突する案は、採用済みとして処理せずorchestratorへ戻す。

## 責務の境界

- Task D: presentation機能、意味変換、出典対応、既定template/profile、品質・出力体験。
- Task E: agent起動、model、review強度、context予算、転記完全性確認の実行手順。
- Task F: workspace所有・排他、実際の保存先解決、session復旧、移行・E2E。
- #37: 中間成果物の任意保存、PII、worktree出力運用。既存承認と今回案の差を明示する。
- #38: bash 3.2・CJK/PDF等の既知変換不具合。修正済みと仮定せず状態を確認する。
- #32: Claude Code/Codex双方での検出・明示/自然言語起動と意味的同等性。

## 必要な参照

最初にagreement-logの上記ID、Issue #41のdoc-export再定義節を読む。必要に応じて
`docs/sdd/deliverables-policy.md`、`payload/overlay/skills/doc-export/SKILL.md`、
`payload/scripts/doc-export/`、`bin/cli.js`、Issue #37/#38/#32を調べる。
会話全文や他Taskの全資料を一括投入しない。事実・承認済み方針・提案・未確認を区別する。

## handoffと正本化確認の完了条件

1. 各合意を原子的なIDで返す。採用/却下/保留、主体、条件、例外、禁止、理由、後続ownerを区別する。
2. 既存Decisionとの維持・改訂関係、Requirements候補、Design保留、未決調査を示す。
3. orchestratorが人間確認を経て正本へ反映した後も、この壁打ちsessionを存続させる。
4. orchestratorから正本の対象version/hash、反映先ID、本文/差分、統合・言換え・保留・未反映一覧を受け取る。
5. 元handoffと正本を項目別に照合する。主体・規範強度・条件・例外・否定・固定値・owner・未決状態を確認する。
6. 確認対象を特定して `CANONICALIZATION_PASS` または `CANONICALIZATION_REVISE` と指摘を返す。
   根拠を確認できなければBLOCKEDとし、人間へ戻す。元session利用不能時の復旧方式はTask Fの未決事項。
7. 確認後に対象が変われば該当部分を再確認する。PASS前にTask完了・archive・次Task開始へ進まない。

これは転記の完全性確認であり、fresh独立reviewと人間承認の代替ではない。
転記完全性確認機能そのもののschema・transport・自動化をTask Dで先行実装しない。
