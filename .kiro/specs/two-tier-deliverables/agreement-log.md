# 合意形成記録: two-tier-deliverables（SDD成果物の二層化）

| 項目 | 内容 |
|---|---|
| タスクID | `two-tier-deliverables` |
| 作成日 | 2026-07-02 |
| 関係者 | KYamada / Claude Code |
| 由来 | 別環境（開発中止）からの引き継ぎドキュメントを本リポジトリで再作成。要件定義生成済み・承認待ちの状態を継続 |

---

## 壁打ち概要

SDD テンプレート（`sdd_base_template`）を適用して開発したユーザーからのフィードバックへの対応。

### 受領フィードバック
- **A: 成果物の二層化** — AI目線（開発用）の各 md と、人目線（検証用）の Excel/Word/PowerPoint 設計書の両方が必要。正本は AI が読める md とし、「md → 説明用ドキュメントを AI が生成」する方式が良い。
- **B: design.md の分割** — design.md が肥大化（例987行）しレビューしづらい。詳細を個別ファイル（table-design / api-spec / class-diagram 等）へ分離すべき。

### 評価
- **フィードバックB は現実装と直接衝突**する。本リポジトリは既に「設計を独立ファイルに割らず `design.md` に集約」を確定し、`validate.sh`(post) が `tech-requirements.md` の残存を NG 判定、design.md テンプレも self-contained を要求。かつて `tech-requirements.md` を廃止・統合済み。Bをそのまま採ると確定済み意思決定の撤回・Tier S との齟齬・cc-sdd 乖離コストが生じる。
- **フィードバックA は低衝突・妥当**。既存 `outputs/` 概念と md=SoT 思想の自然な延長。
- **核心の結論**: Bの正当な目的（監査対象別の人間向け文書）は、Bの手段（正本を割る）ではなく Aの機構（正本から二次成果物を生成）で満たす。正本を割ると同期問題を生み既存ルールに反するが、自己完結の正本から監査対象別ビューを生成すれば SoT は1つのまま担当別文書を出せる。

### 現環境での再検証（引き継ぎ受領時）
引き継ぎが依拠する現実装の事実（CLAUDE.md #5・`validate.sh` の tech-requirements NG・design.md self-contained・steering-custom 7テンプレ・cc-sdd 3.0.2・kiro スキル実在）は本リポジトリ `main` で全て正確であることを独立検証済み。破壊的衝突なし。

---

## 決定事項

| # | 決定 | 理由 | 決定日 |
|---|---|---|---|
| 1 | 二層化を導入（一次=md 正本 / 二次=派生ビュー）。承認・レビューは一次側、二次は再生成・手編集禁止、方向は md→二次の一方向 | Kiro の SoT 思想と整合。ドリフト防止 | 2026-07-02 |
| 2 | 二次成果物は任意 opt-in。基盤標準は PDF/Word（コア）＋PPT（限定）。Excel・高品質作図は別 pkg（opt-in） | md→docx/pdf は pandoc で現実的。xlsx や図中心 PPT は非現実的。基盤に重い依存を同梱しない | 2026-07-02 |
| 3 | 二次成果物の出力先はリポジトリ直下 `outputs/<id>/`。既定 `.gitignore` | 再生成可能なビルド出力（dist 相当）。人間向けで発見性が高い | 2026-07-02 |
| 4 | 生成粒度は (a) 全文変換 と (b) 節スライスの両対応 | (a)は常時保証のフォールバック、(b)は監査対象別文書という本来目的を満たす | 2026-07-02 |
| 5 | 別 pkg 方策 = レンダラ・レジストリ ＋ opt-in install ＋ doc-export スキル配布 ＋ マニフェスト駆動（未導入は明示・サイレント欠落なし） | cc-sdd「実行のみ・非同梱」、sync.sh「サイレント上書き/欠落しない」思想と一致。パリティ維持 | 2026-07-02 |
| 6 | 層の整理: 横断規約 → `steering-custom`（既存活用）／機能別 → `design.md` 節（→二次ビュー） | DRY・design.md 肥大化防止・既存テンプレの受け皿活用 | 2026-07-02 |
| 7 | 承認記録は `spec.json` に一元化する（本リポジトリのドッグフーディングも含む）。agreement-log は経緯・理由のみでブール値を二重管理しない | 既存ルール（workflow.md「承認状態の正は spec.json」）を実運用でも徹底。整合の齟齬・自動検証不能を解消。※本 spec がリポジトリ初の spec.json 運用実例となる | 2026-07-03 |
| 8 | outputs 使い分け: ビルド成果物=リポジトリ直下 `outputs/<id>/`、PII 含有成果物=`.kiro/specs/<id>/outputs/`（既存の隔離先）。出力時に出力先を明示するメッセージを出す | 決定#3（発見性）と既存の PII 隔離ルール（security-policy.md）を両立。利用者が置き場を誤認しないよう明示 | 2026-07-03 |

### 引き継ぎ時の整理事項の解決
- **整理事項1（spec.json 運用の不一致）**: 既存 spec 6件は spec.json 未使用で agreement-log 表に承認を記載していた。→ **決定#7 で spec.json に一元化**して解決。既存完了 spec への遡及・ルール文言の恒久強化は任意 follow-up（本 spec のスコープ外）。
- **整理事項2（outputs の二重概念）**: 既存 `.kiro/specs/<id>/outputs/`（PII 隔離）と新設 `outputs/<id>/`（ビルド成果物）の併存。→ **決定#8 で使い分けと明示メッセージを規定**して解決。

---

## 却下・保留事項

| 内容 | 理由 |
|---|---|
| 正本 `design.md` の物理分割（フィードバックB の手段そのもの） | 既存ルール・`validate.sh` に直接衝突。肥大化は「複数 spec 分解」で対処 |
| Tier L 限定「コンパニオン primary ファイル」例外 | 「正本は割らない」決定により不要・破棄 |
| 二次 → 一次の往復変換 | 正本を一意に保つため一方向のみ |
| 重いレンダラ本体（LaTeX/Java 等）の同梱・再配布 | 非同梱・opt-in 取得 |
| 業界標準そのものの策定 | 社内先行標準の位置づけに留める |
| 既存完了 spec 6件への spec.json 遡及・ルール文言の恒久強化 | 決定#7の範囲外。必要なら別チョアで対応（本 spec は two-tier に集中） |

---

## フェーズゲート承認記録

> 承認状態の正本は `spec.json` の `approvals.{requirements,design,tasks}.approved`（決定#7）。
> ここではブール値を二重管理せず、合意の経緯・補足のみを残す。

| フェーズ | 合意メモ（理由・補足） |
|---|---|
| 要件定義（requirements.md） | 引き継ぎの EARS 9件に、決定#7（Requirement 10）・決定#8（Requirement 2 の AC5/6）を追記して再生成。**承認待ち** |
| 設計（design.md） | **生成済み・承認待ち**。要件承認（「承認。」2026-07-03）後に作成。ギャップ分析の結論を反映: doc-export は新規スキル配布機構（`payload/overlay/skills/` 新設＋init 設置＋sync `managed_skills`）／レンダラは PATH 検出のみ・非同梱／outputs は `@pii` フラグで分岐＋明示メッセージ／フェーズ×フォーマット表は `deliverables-policy.md` に再構築。正本(design.md)は非分割維持 |
| タスク分解・実装前確認（tasks.md） | **生成済み・承認待ち**。設計承認（「承認。」2026-07-03）後に作成。TDD前提11タスク（ルール文書→renderers→manifest→slice→export→スキル配布→sync統合→CLI→validate→回帰→E2E）。各コンポーネントは RED→GREEN |

---

## 設計フェーズで詰める論点（メモ）

- 節スライスの対応づけ方式（見出し名マッピング or アンカーマーカー）。
- マニフェストの形式（spec 内のどこに `論理成果物→フォーマット` を宣言するか）。
- `install-renderers`（仮）サブコマンドの CLI 仕様と、未導入検出・レポート出力の形。
- **doc-export スキル配布の新規性**: 既存パッチは cc-sdd 生成スキルへの「追記」のみで、「新規スキルを作って配布」した前例がない（`skills/` にあるのは `sdd-init` インストーラのみ）。ターゲット repo の `.claude/skills`/`.agents/skills` へ doc-export を置く仕組みは新規設計。`known-parity-diffs.txt` の扱いも含む。
- `outputs/` の `.gitignore` 追記を overlay（`gitignore.snippet`）と sync 管理対象へ反映（既存 `.kiro/specs/*/outputs/` に加えて直下 `outputs/`）。
- `CLAUDE.md`/`AGENTS.md` の記録集約ルール改訂（一次=`.kiro/specs/<id>/`、二次ビルド=`outputs/<id>/`、PII=`.kiro/specs/<id>/outputs/`）と snippets のパリティ。
- **フェーズ×フォーマット対応表の再構築**: 元ネタ（別環境の `tmp/*.png`・`ai_driven_dev_guide.docx`）は失われており取得不可。決定#2 の「フォーマット別の現実ライン」「役割分担の指針」から design で再構築する。

---

## 変更履歴

| 日付 | 変更内容 | 変更者 |
|---|---|---|
| 2026-07-02 | 別環境で初版作成（要件 EARS 9件・決定#1〜6）。要件生成済み・承認待ち | Claude Code |
| 2026-07-03 | 本リポジトリへ引き継ぎ再作成。現環境で事実を再検証（衝突なし）。決定#7（spec.json 一元化）・#8（outputs 使い分け＋明示メッセージ）を追加し、Requirement 10 と Requirement 2 の AC5/6 を追記 | Claude Code |
| 2026-07-03 | 要件承認。ギャップ分析（doc-export 配布の新規性・init/sync/validate 統合点）を経て design.md 生成。`spec.json` design.generated=true | Claude Code |
| 2026-07-03 | 設計承認。tasks.md 生成（TDD前提11タスク）。`spec.json` design.approved=true / tasks.generated=true | Claude Code |
