# Requirements Document

## Introduction

本 spec は、SDD テンプレート（`sdd_base_template`）に **成果物の二層化** を導入する。一次成果物（AI が生成・読込・更新する `.md`）を唯一の正本（Source of Truth）に保ちつつ、人間の検証・共有用の二次成果物（PDF / Word / PowerPoint、および opt-in で Excel・高品質作図）を **一次から一方向で再生成** できるようにする。正本（`design.md`）の物理分割は行わず、監査対象別の人間向け文書は二次生成で満たす。あわせて、横断規約と機能別設計の置き場を整理するルールを明文化する。

要件は WHAT（利用者・運用者から観測できる振る舞い／運用ルール）を規定し、内部実装の詳細は design フェーズに委ねる。

## Boundary Context

- **In scope**:
  - 二層化の概念・運用ルールの明文化（`docs/sdd/`、`CLAUDE.md`/`AGENTS.md`）
  - 二次成果物の出力先（ビルド成果物=リポジトリ直下 `outputs/<spec-id>/`、PII含有=`.kiro/specs/<spec-id>/outputs/`）と gitignore・保管ルール
  - 成果物 × フォーマットのマッピング（基盤標準ライン）
  - 生成粒度（全文変換／節スライス）の両対応
  - 二次成果物生成機能（doc-export）の配布と opt-in レンダラ取得、未導入時の明示
  - 横断規約（steering-custom）と機能別（design.md 節）の振り分けルール
- **Out of scope**:
  - 正本（`design.md`）の物理分割、および Tier L 限定コンパニオン primary 例外（いずれも不採用）
  - 二次 → 一次への逆変換（往復変換）
  - 重いレンダラ本体（LaTeX / Java 等）のリポジトリ同梱・再配布
  - 成果物二層化の業界標準そのものの策定
- **Adjacent expectations**:
  - cc-sdd は「実行のみ・非同梱」を維持し、その生成物への改変は最小パッチに留める（本 spec はこの前提に依存する）。
  - Claude/Codex パリティ（`CLAUDE.md`⇄`AGENTS.md`、`.claude/skills`⇄`.agents/skills`、overlay snippets）は本 spec の全変更で維持されることを前提とする。
  - 承認状態の正本は `spec.json`（`approvals.{requirements,design,tasks}.approved`）とし、本リポジトリのドッグフーディングも spec.json に一元化する（決定#7）。

## Requirements

### Requirement 1: 二層化の概念・運用ルールの明文化
**Objective:** SDD テンプレート利用者として、一次(md)と二次(派生ビュー)の役割・権威・変換方向が明文化されていてほしい。そうすれば正本と派生を取り違えず、ドリフトを防げる。

#### Acceptance Criteria
1. The SDD ルールドキュメント（`docs/sdd/workflow.md`）shall 一次成果物(md)を唯一の正本(Source of Truth)、二次成果物を一次から再生成される派生ビューと定義する記述を含む。
2. The SDD ルールドキュメント shall 二次成果物を手編集禁止・再生成可能なビルド成果物として扱い、承認および差分レビューは常に一次(md)側で行う旨を明記する。
3. Where 二次成果物を生成する場合, the 二次成果物生成プロセス shall 一次(md)→二次の一方向でのみ変換し、二次→一次の逆変換手段を提供しない。
4. The `CLAUDE.md` と `AGENTS.md` shall 二層化ルールを同一内容で含む。

### Requirement 2: 二次成果物の出力先と管理ルール
**Objective:** 開発者・レビュー担当として、人間向け二次成果物が分かりやすい場所に出力され、再生成物として適切に管理されてほしい。そうすれば非開発者への共有と履歴管理が両立する。

#### Acceptance Criteria
1. When ビルド成果物としての二次成果物を出力する場合, the 二次成果物生成プロセス shall リポジトリ直下 `outputs/<spec-id>/` に出力する。
2. The overlay 配布物 shall リポジトリ直下 `outputs/` を既定で `.gitignore` 対象に含める。
3. The SDD ルールドキュメント shall 保管が必要な二次成果物は別途アーカイブ（外部ストレージまたは明示コミット）する運用を明記する。
4. The `CLAUDE.md` の記録集約ルール shall 「一次記録=`.kiro/specs/<id>/`、二次ビルド成果物=リポジトリ直下 `outputs/<id>/`、PII 含有成果物=`.kiro/specs/<id>/outputs/`」に改訂され、`AGENTS.md` と同一内容である。
5. When 生成する二次成果物が PII を含むと判定される場合, the 生成プロセス shall それを `.kiro/specs/<id>/outputs/`（既存の PII 隔離先・git 管理外）へ出力し、リポジトリ直下 `outputs/<id>/` へは出力しない。
6. When 二次成果物を出力する場合, the 生成プロセス shall 各成果物の出力先（ビルド成果物は `outputs/<id>/`、PII 含有は `.kiro/specs/<id>/outputs/`）を明示するメッセージを出力し、特に PII 隔離先へ出力した場合はその旨を明示する。

### Requirement 3: 成果物 × フォーマットのマッピング（現実ライン）
**Objective:** 利用者として、どの成果物をどのフォーマットで出せるか（基盤標準か opt-in か）が明示されていてほしい。そうすれば実現可能性を誤解しない。

#### Acceptance Criteria
1. The SDD ルールドキュメント shall 基盤標準フォーマットとして PDF・Word をコア、PowerPoint を限定対応と定義する。
2. The SDD ルールドキュメント shall Excel および高品質作図（PlantUML 等）を opt-in（別 pkg）対応と定義する。
3. The SDD ルールドキュメント shall 各フェーズの論理成果物（要件・基本設計・詳細設計の各節）から推奨フォーマットへの対応表を含む。
4. Where 図（ER・クラス・シーケンス・構成）を二次成果物に含める場合, the 生成プロセス shall 正本内の Mermaid 記法を画像（SVG または PNG）へレンダリングして二次成果物に埋め込む。
5. If Mermaid 画像化レンダラ（mmdc）が未導入の場合, then the 生成プロセス shall 正本内の Mermaid ブロックを元のまま残して文書生成を継続し、当該図が未変換である旨と導入方法をレポート・出力に明示する（サイレントに欠落させない）。

### Requirement 4: 生成粒度（全文変換 / 節スライス）
**Objective:** 利用者として、正本を分割せずに監査対象別の文書を得たい。そうすれば単一の正本を保ちつつ担当別に配布できる。

#### Acceptance Criteria
1. When 全文変換を指定した場合, the 生成ステップ shall 正本 md 全体を単一の二次ファイルへ変換する。
2. When 節スライスを指定した場合, the 生成ステップ shall 指定された見出しまたはアンカーに対応する節のみを抽出して監査対象別の二次ファイルを生成する。
3. If 節スライスで指定した見出しまたはアンカーが正本に存在しない場合, then the 生成ステップ shall エラーを報告し、当該二次成果物を空のまま生成しない。
4. The 生成ステップ shall 全文変換を、節スライス指定が無い場合のフォールバックとして常に提供する。

### Requirement 5: 二次成果物生成基盤（拡張可能・opt-in・欠落の明示）
**Objective:** メンテナとして、生成基盤が重い依存を同梱せず、対応フォーマットを後付けでき、未対応を黙って握り潰さないでほしい。そうすれば配布は軽量なまま、必要な環境だけ機能を足せる。

#### Acceptance Criteria
1. The 二次成果物生成基盤 shall フォーマットとレンダラの対応を登録・切替できる仕組みを持ち、重い依存（Excel 変換器・PlantUML・mermaid-cli・PDF エンジン等）の本体を同梱しない。
2. When 利用者がレンダラ取得（`install-renderers`）を実行した場合, the `sdd-base` ツール shall 各レンダラの導入状態と**具体的な導入コマンド**を案内する（重いバイナリ本体は再配布しない）。レンダラ→導入コマンドの対応は単一のレジストリで一元管理する。
3. Where 生成に必要なレンダラ依存が未導入の場合, the 生成ステップ shall 当該フォーマット/図を「未生成（要 install）」としてレポート・出力に明記し、**欠けているレンダラ固有の導入コマンド**を提示し、かつ生成可能な他の成果物の処理を継続する。
4. Where レンダラ未導入を検出し、かつ**対話端末が利用可能**な場合, the 生成/取得プロセス shall 「今すぐ導入するか」を人間に確認し（既定は「導入しない」）、**人間が同意した場合にのみ**導入コマンドを実行する。非対話（CI 等）ではその場実行せず導入コマンドの提示に留める。
5. The spec shall 希望する二次成果物を「論理成果物 → フォーマット」のマニフェストとして宣言でき、the 生成ステップ shall そのマニフェストの宣言に従って生成対象を決定する。
6. If マニフェストが存在しない場合, then the 生成ステップ shall 対象 spec に存在する主要成果物 md（`requirements.md` / `design.md` / `tasks.md`）を各1本、既定フォーマット（既定 Word）で全文生成する（プロセス記録 md は既定対象外）。

### Requirement 6: doc-export 機能の配布と Claude/Codex パリティ
**Objective:** 両エージェント利用者として、二次成果物生成機能が Claude・Codex の両方で同一に使えてほしい。そうすればどちらの環境でも運用が揃う。

#### Acceptance Criteria
1. The 二次成果物生成機能（doc-export）shall `.claude/skills` と `.agents/skills` の両方へ同一内容で設置される。
2. The 配布物（`payload/`）shall doc-export 関連資産を Claude・Codex の両環境へ配布する。
3. When `diff -qr .claude/skills .agents/skills` を実行した場合, the doc-export スキル shall 許容差分リスト（`known-parity-diffs.txt`）に登録されたものを除き差分を生じない。

### Requirement 7: 層の整理（横断規約 ↔ 機能別）
**Objective:** 設計者として、規約と機能別設計の置き場が明確であってほしい。そうすれば標準の重複記載や design.md の肥大化を防げる。

#### Acceptance Criteria
1. The SDD ルールドキュメント shall 各設計要素を「横断規約（どう作るか）→ `.kiro/steering/steering-custom/`」と「機能別（この機能で何を作るか）→ `design.md` の節」へ振り分ける判定基準を明記する。
2. The SDD ルールドキュメント shall 既存の steering-custom テンプレ（`api-standards` / `error-handling` / `security` / `authentication` / `database` / `testing`）を横断規約の受け皿として案内する。
3. The SDD ルールドキュメント shall 横断規約を各機能の `design.md` に重複記載しない（DRY）旨を明記する。

### Requirement 8: 既存方針の保全（不採用事項の担保）
**Objective:** メンテナとして、二層化の導入が既存の確定ルールを壊さないでほしい。そうすれば方針の一貫性と検証の整合が保たれる。

#### Acceptance Criteria
1. The 設計フェーズ運用 shall 正本 `design.md` を物理分割せず、コンパニオン primary ファイル例外を導入しない。
2. The `validate.sh`（post フェーズ）shall `tech-requirements.md` の残存を「要確認（NG）」と判定する既存挙動を維持する。
3. The 二次成果物生成基盤 shall cc-sdd を「実行のみ・非同梱」とする方針を崩さず、cc-sdd 生成物への改変を最小パッチに留める。
4. Where 二次成果物生成のためのプロダクトコードを `payload/scripts/` に追加する場合, the そのテスト shall リポジトリ直下 `tests/`（`unit/` / `integration/`）に配置される。

### Requirement 9: 検証と配布整合の担保
**Objective:** メンテナとして、二層化 overlay が正しく適用され、更新が sync で安全に配布されてほしい。そうすれば展開先での健全性が保たれる。

#### Acceptance Criteria
1. The `validate.sh`（post フェーズ）shall 二層化 overlay の適用結果（`outputs/` の gitignore 追記、二層化ルール記述の存在、二次成果物ルールのパリティ）を検証する。
2. The `sync` プロセス shall 本 spec で追加・変更した overlay 資産（`docs/sdd/`・snippets・doc-export スキル）を管理対象として扱い、ローカル変更をサイレント上書きせずに更新を反映する。
3. When 展開先が sync 管理下（`.kiro/sdd-base.lock` 検出）の場合, the `init` shall 二層化 overlay を無条件上書きせず、更新を sync に委ねる既存ガードレールを維持する。

### Requirement 10: 承認記録の spec.json 一元化
**Objective:** メンテナとして、承認状態が単一の機械可読な正本で管理されてほしい。そうすれば二重管理による齟齬を防ぎ、フェーズゲートを自動検証できる。

#### Acceptance Criteria
1. The 本 spec の承認状態 shall `spec.json` の `approvals.{requirements,design,tasks}.{generated,approved}` を唯一の正本として管理する。
2. The `agreement-log.md` shall 承認ブール値を再掲せず、合意の経緯・理由のみを記録する。
3. Where 本リポジトリのドッグフーディングで新規 spec を作成する場合, the 運用 shall `spec.json` を作成し承認状態の正本とする（決定#7）。

### Requirement 11: doc-export コマンドの契約（CLI 正式化）
**Objective:** 利用者として、二次成果物生成をどの環境でも同じコマンドで実行でき、結果の成否が明確であってほしい。そうすれば運用と自動化（CI）に組み込める。

#### Acceptance Criteria
1. The `sdd-base` ツール shall `doc-export <spec-id> [--manifest <path>]` を CLI サブコマンドとして提供する（スキルはこのコマンドの実行を案内する）。生成ロジック本体はパッケージ側に置き、ターゲットリポジトリへ複製しない。
2. When 生成が完了した場合, the `doc-export` shall 終了コードを次の3分類で返す: すべて生成成功または未生成（レンダラ未導入＝想定内）のみ → 0／見出し不在・レンダリング失敗等の**エラーを含む** → 非0。
3. When `doc-export` を実行した場合, the 生成プロセス shall 実行結果レポートを `outputs/<spec-id>/export-report.md`（`.gitignore` 対象・再生成可能）に出力し、あわせて標準出力へサマリを表示する。
4. If 指定した `<spec-id>` に対応する `.kiro/specs/<spec-id>/` が存在しない場合, then the `doc-export` shall エラーメッセージを表示して非0で終了する。
5. The `doc-export` shall いかなる場合も自動コミットせず、正本 md を書き換えない。
