# 合意形成記録: sdd_base_template 安全な更新機構（sync コマンド, Part B）

| 項目 | 内容 |
|---|---|
| タスクID | `sdd-base-sync-command` |
| 作成日 | 2026-07-01 |
| 関係者 | KYamada / Claude Code |
| 由来 | Part A/B/C のうち Part B。記録先を `sdd-base-upstream-fix` から分離（ユーザー指示: 「記録先は分けて進めて」） |

---

## 壁打ち概要

Part A/C（PR #10, マージ済み）で、消失していた独自ルールを overlay へ恒久反映する対応は完了した。
残る Part B は「今後のテンプレ更新そのものを安全に反映する仕組み」の新設であり、破壊的操作
（ローカルファイル上書き）を伴いうるため、`.kiro/specs/sdd-base-upstream-fix/` とは別タスクIDとして
記録を分離した。

設計の出発点は引き継ぎ元（`cyclox2_docker`）の `.kiro/specs`... 実際には
`docs/specs/sdd-base-template-upstream-fix/agreement-log.md`（cyclox2_docker側の旧記録）§3 に
まとめられた設計ドラフト（lock + snapshot + 3-wayマージのハイブリッド方式）であり、これを
`requirements.md` として本タスクに正式に落とし込んだ。

---

## 決定事項

| # | 決定内容 | 決定理由 | 決定日 |
|---|---|---|---|
| 1 | Part B は独立タスクID `sdd-base-sync-command` として記録する（`sdd-base-upstream-fix` とは分離） | Part Bは破壊的操作を伴う大規模改修でフルフロー（requirements/design/tasks + spec.json）を要し、Part A/Cの低リスク追記とレビュー粒度・承認単位が異なるため | 2026-07-01 |
| 2 | 新コマンド名は `sync` を採用（`bin/cli.js sync`） | 既存 `update`（テンプレ開発者向け `git pull --ff-only`）と意味が異なり、名称衝突を避ける必要があるため（引き継ぎ元 §3 で既に決定済みの方針を踏襲） | 2026-07-01 |
| 3 | lock/snapshot 方式は「3-wayマージ+lock」ハイブリッドを採用（ネットワーク経由の過去コミットre-clone方式は不採用） | ネットワーク依存・履歴改変リスクを避けるため。ローカル永続スナップショットによるリポジトリ肥大化は許容トレードオフとする（引き継ぎ元 §3 の決定を踏襲） | 2026-07-01 |
| 4 | requirements.md を EARS 形式でフルに作成し、人間承認ゲートを経てから design.md に進む | Part B はコーディングを主体とする改修であり、CLAUDE.md 基本ルール1（ドキュメント完成後にいきなり実装しない）・ルール2（TDD）が適用されるため | 2026-07-01 |

---

## 却下・保留事項

| 内容 | 理由 |
|---|---|
| Part B を Part A/C と同一PR・同一タスクIDで進める | 破壊的操作の有無でレビュー・承認の性質が異なるため分離（決定1） |
| lock ファイルを JSON 形式にする | 既存実装（`init.sh`/`validate.sh`）が bash 完結スタイルであり、一貫性のため行指向フラット形式を採用（引き継ぎ元 §3 の決定を踏襲） |

---

## レビュー指摘と対応（PR #11 マージ前の修正）

### 指摘1: `payload/tests/` の配置

**指摘**: `payload/` は `install`（`bin/cli.js` の `buildSkillBundle`）で丸ごと
`~/.claude/skills/sdd-init/payload/` 等へコピーされ、`package.json` の `files` でも配布対象に
含まれる。一方 `init.sh`/`sync.sh`/`validate.sh` は `payload/tests/*` を一切参照しない。
実行時に使われない開発者専用のテスト資産を配布物に混在させてよいか、という指摘。

**水平展開調査**: `payload/` 配下の全ファイルについて実行時参照の有無を確認した結果、
問題があったのは `payload/tests/`（`run.sh`/`lib/assert.sh`/`test_*.sh` 計8ファイル）のみ。

| 対象 | 実行時参照 | 判定 |
|---|---|---|
| `payload/scripts/*.sh`（init/sync/validate/sync_lib） | `bin/cli.js` から起動、相互参照あり | 配布物として正しい |
| `payload/validation/known-parity-diffs.txt` / `KNOWN_GOOD_CCSDD_VERSION` | `validate.sh` が読み込む | 配布物として正しい |
| `payload/validation/checks.md` | プログラムからは読まれないが `validate.sh` の検証仕様書として小容量・実行リスクなし | 問題なし（現状維持） |
| `payload/validation/patches/README.md` | `init.sh` の patch glob（`*.sh`）に掛からず実行されない、小容量 | 問題なし（現状維持） |
| `payload/overlay/**` | 展開・sync 対象の中身そのもの | 配布物として正しい |
| `payload/tests/**` | **どこからも参照されない** | **誤配置。修正対象** |

**根拠となる既存の前例**: リポジトリ直下の `scripts/install.sh`（開発者向け `--link` 運用）が
`package.json` の `files`（`bin/`, `payload/`, `skills/`, `README.md`, `LICENSE`）に含まれず
配布対象外という、「`payload/` = 配布物・直下 = 開発者専用ツール」の構造が既に確立していた。

**対応**: `payload/tests/` をリポジトリ直下の `tests/`（`payload/` 外）へ移動。
内部の相対パス参照（`$DIR/../scripts/...` → `$DIR/../payload/scripts/...`）と、
`checks.md`/`tasks.md`/`test-results.md` 中のパス表記を追随修正。
`init`/`sync`/`validate` は元々 `payload/tests` を参照していないため機能的な影響はない。
`install` バンドル生成（`buildSkillBundle`）に `tests/` が含まれなくなったことをスクリプトで検証し、
移動後も `bash tests/run.sh` 全55件PASS・`init`/`sync` の回帰なしを確認した。

### 指摘2: テストのレビュー可読性・spec との紐付け、単体/結合の分離、記録の分割、恒久ルール化

**指摘**: (a) `tests/` がリポジトリ直下だとレビューしにくい。本来 spec に紐づくべきでは、
(b) `tests/` 配下は単体/結合をディレクトリで分けるべき、(c) `test-results.md` は単体/結合をセクション
分けるべき、(d) これらを開発・改修時のルールとして残すべき、という4点の指摘。妥当性と既存規約との
バッティングを検討した上で報告するよう指示された。

**検討結果**（ユーザーへ報告し判断を仰いだ）:
- (a) `.kiro/specs/<id>/tests/` への移動は**却下**。`docs/sdd/workflow.md`「タスクディレクトリ構成」が
  `.kiro/specs/<id>/` をプロセス記録専用の場所として定義しており、実行コードの置き場は想定していない。
  `payload/scripts/sync_lib/*.sh` は特定タスクに紐づかない永続的なプロダクトコードであり、将来別タスクが
  このコードを改修する際にテストの所在が spec 単位で分散し追跡困難になる懸念がある。ユーザーへ
  `AskUserQuestion` で確認し、**「直下 tests/ を維持」を選択**（決定確定）。
- (b) 単体/結合のディレクトリ分割は妥当・既存規約との衝突なし。採用。
- (c) `test-results.md` のセクション分割は妥当・衝突なし。採用。
- (d) 恒久ルールは `payload/overlay/`（downstream配布用の汎用SDDルール）ではなく、
  `sdd_base_template` 自身の開発規約である `CLAUDE.md`/`AGENTS.md`「必須ルール」に追加するのが適切と
  判断（downstream repo は言語・フレームワークが多様であり、「テストは spec 直下」という規約を
  一律に押し付けられないため）。

**対応**:
- `tests/test_hash.sh`/`test_lock.sh`/`test_merge.sh` → `tests/unit/`、
  `tests/test_sync_init.sh`/`test_sync_apply.sh`/`test_sync_report.sh` → `tests/integration/` へ移動。
  相対パス参照を1階層深く修正（`$DIR/../../payload/scripts/...`）。
- `tests/run.sh` を `unit/` → `integration/` の順に走査するよう変更。
  **この修正過程で、`run.sh` 自身の走査用変数 `DIR` が、source されたテストファイル側の
  `DIR`（自身のパス解決用）と同名で衝突し、2グループ目（integration）が誤ったパスを参照して
  0件実行になる不具合を発見**。`run.sh` 側の変数名を `RUNNER_DIR` に変更して解消し、55件全PASSを再確認。
- `test-results.md` を「単体テスト」「結合テスト」のセクションに分割（小計・合計を明記）。
- `CLAUDE.md`/`AGENTS.md`「必須ルール」に7項目目としてテスト資産の配置規約（`payload/`外・
  `.kiro/specs/`外・`tests/unit`・`tests/integration`分離）を同一内容で追加。「動作確認」節にも
  `bash tests/run.sh` の実行を追記。
- `design.md`「Modified Files」節に配置根拠（`.kiro/specs/<id>/` に置かない理由）を追記し、
  「Directory Structure」を unit/integration 構成に更新。

---

### 指摘3: `init` 再実行時に sync 管理を保護するガードレールの有無

**指摘**: 本タスクの核心（sync による非破壊性の保証）に関連し、既に `init` 済み（かつ `sync` で
運用中）のリポジトリに対して再度 `init` が投入された場合、それを本当に実行してよいか確認する
ガードレールは実装されているか、という確認。

**調査結果**: **未実装だった**。`init.sh` の overlay 適用ステップ（[5/6]）のうち、`CLAUDE.md`/
`AGENTS.md` へのマーカー注入と `.gitignore` 追記は元々マーカー検出でスキップする冪等設計だったが、
`docs/sdd/` 一式の `cp -R` だけは `ON_EXISTING`（keep/overwrite/compare）の値に関わらず**常に
無条件で上書き**していた。sync 導入後にこの状態で `init` を再実行すると、sync が保護しているはずの
ローカルカスタマイズがサイレントに上書きされ、かつ `.kiro/sdd-base.lock` のハッシュは更新されない
ため、次回 `sync` がこの破壊に気づけない。これは引き継ぎ元の事故（cyclox2_docker で独自ルールが
`init` の無条件上書きで消失した事象）と同じ構造の穴が、sync 導入後も塞がれていなかったことを意味する。

**対応**: `init.sh` の docs/sdd 上書きステップに `.kiro/sdd-base.lock` の存在チェックを追加。
lock が存在する（sync 管理下の）場合は `docs/sdd/` の上書きをスキップし `sync` の使用を案内する
メッセージを表示、存在しない場合は従来通り動作（回帰なし）。既存の `CLAUDE.md`/`AGENTS.md`/
`.gitignore` は元々冪等だったため変更不要。実リポジトリでの E2E 検証（ローカル追記→`sync`で
lock作成→`init --on-existing=keep`再実行→追記が保護されることを確認／修正前コードでの再現で
同シナリオが実際に破壊されることも確認）。詳細は `design.md`「init との境界」節、
`test-results.md` を参照。「`init.sh` の既存ロジックには触れない」という本 spec の当初の境界
（Out of Boundary）に対する例外として、この最小限のガードのみを追加した。

---

## フェーズゲート承認記録

> 承認状態の正本は `.kiro/specs/sdd-base-sync-command/spec.json` の
> `approvals.{requirements,design,tasks}.approved`。ここでは経緯・補足のみ。

| フェーズ | 合意メモ（理由・補足） |
|---|---|
| 要件定義（requirements.md） | 引き継ぎ元の設計ドラフトを EARS 形式の要件4本（初回lock作成／3-wayマージ／可視化・非破壊性／既存コマンド非衝突）に整理して起票。**人間承認済み**（「OK。」2026-07-01） |
| 設計（design.md） | lock+snapshotによる3-wayマージ台帳方式で確定。`sync.sh`+`sync_lib/{hash,lock,merge}.sh` の構成、コンフリクトは exit 0（想定内分岐）として扱う方針を明記。**人間承認済み**（「OK」2026-07-01） |
| タスク分解・実装前確認（tasks.md） | TDD前提で9タスクに分解（テスト基盤→hash→lock→merge→sync初回化→sync差分適用→レポート→CLI統合→E2E通し）。**人間承認済み**（「OK」2026-07-01）。**全タスク実装完了**（test-results.md参照） |

---

## マージ後の追補: 自己適用（ドッグフーディング）で発見した2件のバグと修正

**経緯**: PR #11（本spec）マージ後、「sdd_base_template 自身に改修内容を適用（ドッグフーディング）」を
実施したところ、`sync` 自体に2件のバグを発見した。本リポジトリの root（`docs/sdd/`・`CLAUDE.md`/
`AGENTS.md`・`.claude/skills`・`.agents/skills`）は PR #9（環境越境ポリシー）以降 `init` が
再実行されておらず、payload 側の変更（PR #10 Part A+C: workflow.md 非コーディング節・
security-policy.md・ensure-agreement-log パッチ）が一度も反映されていなかった。この
「作ってからしばらく経って初めて sync を導入する」という状況が、以下2件の潜在バグを顕在化させた。

### バグ1: 初回化（`initial_sync`）の基準点が payload 側の内容になっていた

`sync.sh` の `initial_sync()` は、docs/sdd 系ファイルの lock ハッシュ・スナップショットを
**payload（新版）の内容**を基にして記録していた。ローカルが既に payload と同一内容（＝
`init` 直後に `sync` を導入する通常ケース）なら問題ないが、本リポジトリのようにローカルが
**古いまま長期間 sync 未導入だった**場合、2回目の `sync` 実行時に `base（=1回目に記録した
payload内容）` と `other（=今回の payload 内容、変化なし）` が完全一致するため「上流に変更なし」
と誤判定され、ローカルの古い内容が更新されないまま取り残される。

**修正**: `initial_sync()` を、対象ファイルが `$ROOT` に既に存在する場合は**ローカルの現状**を
基準点（lock hash・snapshot）として記録するよう変更（存在しない新規ファイルは従来通り payload
基準）。回帰テスト `tests/integration/test_sync_stale_adoption.sh` を追加（修正前でREDを確認
→ 修正後にGREenを確認）。

### バグ2: `init` 後に新設されたパッチが `sync` では一度も適用されない

`apply_blocks()` は、対象ファイルにマーカーブロックが**存在しない場合は無条件で `continue`**
しており、「まだ一度もそのパッチが適用されていないファイル」に対して何もしない実装だった。
本リポジトリの `.claude/skills/kiro-spec-init/SKILL.md` は `ensure-agreement-log.sh`
パッチ追加（PR #10）後に一度も `init`/`sync` を経ておらず、`sync` を何度実行してもこのパッチが
永遠に適用されないことが判明した。

**修正**: `apply_blocks()` で、`stype=patch` のエントリについてマーカーが見つからない場合、
`init.sh` と同じパッチスクリプトをそのまま `$ROOT` に対して実行（冪等・末尾追記のみ）してから
再抽出し、新規適用として lock・snapshot に記録・レポートに `新規適用` として明記するよう変更。
回帰テスト `tests/integration/test_sync_new_patch.sh` を追加（実際の `ensure-agreement-log.sh`
パッチと `sync.sh` を通しで実行して検証）。

### 副次対応: `sdd-base-update-report.md` の gitignore 化

自己適用中に、実行のたびに上書きされる `.kiro/sdd-base-update-report.md` が誤ってコミット対象に
入りそうになった（design.md では「実行結果の唯一のログ」と位置づけており、`.sdd-backup/` 等と
同様に履歴として残す性質のものではない）。`payload/overlay/gitignore.snippet` と本リポジトリ自身の
`.gitignore` の両方に除外パターンを追加した（`.kiro/sdd-base.lock`・`.kiro/sdd-base-snapshot/` は
3-wayマージの基準点としてコミットが必須のため、引き続きコミット対象）。

### 結果
- `tests/run.sh` は 55件 → **63件**（新規8件）に増加、全PASS。
- 本リポジトリ自身に `sync` を実行し、`docs/sdd/`・`CLAUDE.md`/`AGENTS.md` の SDD-BASE ブロック・
  3パッチすべて（IMPL-POLICY / DESIGN-TECHREQ / ENSURE-AGREEMENT-LOG）が最新化されたことを
  `node bin/cli.js validate post` で確認（`.kiro/sdd-base.lock`・`.kiro/sdd-base-snapshot/` を
  新規にコミットし、以降はこのリポジトリ自身も `sync` で運用する）。
- 既知の残存事項（本修正のスコープ外）: `docs/specs/env-boundary-policy/`（`.kiro/specs/` 統合前の
  旧レイアウトの遺構）は post 検証で `NG` のまま。これは PR #9 由来の既知の別課題であり
  （引き継ぎ元 `.kiro/specs/sdd-base-upstream-fix/agreement-log.md` §5 に記載済み）、
  本タスクでは対応しない。

---

## 変更履歴

| 日付 | 変更内容 | 変更者 |
|---|---|---|
| 2026-07-01 | 初版作成。記録先をPart A/Cから分離し、requirements.md を起票 | Claude Code |
| 2026-07-01 | requirements.md 人間承認。design.md 起票（lock+snapshot+3-wayマージの詳細設計を確定） | Claude Code |
| 2026-07-01 | design.md 人間承認。tasks.md 起票（TDD前提の9タスク分解） | Claude Code |
| 2026-07-01 | tasks.md 人間承認。全タスク実装完了（`hash.sh`/`lock.sh`/`merge.sh`/`sync.sh`/CLI統合/README/checks.md）。単体・結合テスト55件PASS、実リポジトリでのE2E確認完了 | Claude Code |
