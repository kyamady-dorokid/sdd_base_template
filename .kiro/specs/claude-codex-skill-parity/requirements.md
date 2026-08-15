# Requirements Document

## Introduction

本機能は、`sdd_base_template`が配布するSDDスキルをClaude CodeとCodexの双方で実際に検出・起動でき、
同じSDDフローと安全規約を利用できる状態にする。ファイルの存在数だけではなく、利用者が新規セッションから
スキルへ到達して処理を開始できること、自然言語入口が意図したスキルへ接続されること、配布後もその状態を
検証できることをパリティの成立条件とする。

原因調査では、metadata形式の差を修正方針として先に決めない。初期一覧への表示、selectorでの検出、
明示起動、自然言語による暗黙起動を別の観測点として扱い、現行Codex仕様に基づいて判定する。

## Boundary Context

- **In scope**: 配布対象`kiro-*`、`doc-export`、個人向け`sdd-init`の分類、CodexとClaude Codeでの検出・起動、自然言語入口、利用案内、意味的パリティ検証、install・init・sync後と`cyclox2_docker`での新規セッション検証
- **Out of scope**: 実行通知の実装（#31）、独立レビュー機構と既存の自動approval・同一context fallbackの廃止（#39）、sync競合解決方式（#30）、cc-sddバージョン昇格（#33以降）、cc-sdd生成物の再配布、各スキル固有機能の全面改修
- **Adjacent expectations**: #32は検出・起動・意味的パリティを所有して既存安全挙動を弱めず、#39は#32完了後に厳格な独立レビュー契約を両環境へ実装し、#30はsync処理、#31は実行通知を所有する

## Requirements

### Requirement 1: 配布スキルの正規インベントリと分類

**Objective:** As a テンプレート保守者, I want 配布するSDDスキルの対象と起動区分を一意に把握したい, so that 片側欠落や意図しない起動制限を判定できる

#### Acceptance Criteria

1. The SDD基盤 shall Claude CodeとCodexへ配布する全`kiro-*`スキル、`doc-export`、個人向け`sdd-init`について、同一の正規スキル名を識別できる一覧を持つ。
2. The SDD基盤 shall 各スキルを利用者が直接開始できるuser-facingスキル、または他のスキルからのみ利用するinternal/helperスキルとして分類する。
3. The SDD基盤 shall 各user-facingスキルについて、Claude CodeとCodexの双方で利用可能な明示起動経路と配布scopeを定義する。
4. The SDD基盤 shall 各スキルについて、自然言語からの暗黙起動を許可するかを定義する。
5. If 片方の環境にだけスキルが存在する場合, the SDD基盤 shall 意図した例外として根拠が記録されていない限りパリティ不成立として報告する。
6. If スキルの分類または起動方針が未定義である場合, the SDD基盤 shall 配布パリティを合格扱いにしない。

### Requirement 2: Codexでの検出と明示起動

**Objective:** As a Codex利用者, I want SDDスキルを確実に見つけて明示起動したい, so that 文書に書かれたSDDフローを実行できる

#### Acceptance Criteria

1. When Codexの新規セッションを対象リポジトリで開始する場合, the SDD基盤 shall 全user-facing `kiro-*`スキルへCodexの公式なスキル選択経路から到達可能にする。
2. When 利用者が正規スキル名を明示指定する場合, the Codex向けSDD環境 shall 対応するuser-facingスキルを起動する。
3. The Codex向けSDD環境 shall 少なくとも`kiro-discovery`、`kiro-spec-init`、`kiro-spec-requirements`、`kiro-spec-design`、`kiro-spec-tasks`、`kiro-impl`、`kiro-spec-status`、`kiro-validate-impl`、`doc-export`を公式な選択経路から検出可能にする。
4. When 利用者が前項の各スキルを正規名で明示指定する場合, the Codex向けSDD環境 shall 対象リポジトリ由来の対応スキルを起動する。
5. When 前項の各スキルを明示起動する場合, the Codex向けSDD環境 shall 対応する処理を開始し、対象スキルの指示を適用する。
6. If 初期の利用可能スキル一覧がcontext budgetによって一部を省略する場合, the Codex向けSDD環境 shall 省略されたuser-facingスキルへ公式な選択経路または明示指定で到達可能な状態を維持する。
7. If スキルが初期一覧に表示されない場合, the SDD基盤 shall 一覧省略だけを未検出と断定せず、選択経路、明示指定、実処理の各結果を分けて判定する。
8. If user-facingスキルを明示指定しても起動できない場合, the Codex向けSDD環境 shall 利用不能なスキル名と失敗した段階を確認できる結果を返す。
9. When リポジトリ直下またはその配下のディレクトリから新規セッションを開始する場合, the Codex向けSDD環境 shall 対象リポジトリの同じuser-facingスキル群へ到達可能にする。
10. If 同名スキルが複数scopeに存在して対象リポジトリ由来の実体を識別できない場合, the Codex向けSDD環境 shall 対象スキルの起動確認を合格扱いにしない。

### Requirement 3: 自然言語からの起動方針

**Objective:** As a SDD利用者, I want 自然言語でも必要なSDDスキルへ接続したい, so that コマンド構文を覚えなくても同じパイプラインを利用できる

#### Acceptance Criteria

1. When 利用者が自然言語でSDDの開始または次フェーズの実行を依頼し、対象スキルの暗黙起動が許可されている場合, the SDD基盤 shall 依頼内容に対応するuser-facingスキルを起動する。
2. When user-facingスキルの暗黙起動を許可する場合, the SDD基盤 shall Claude CodeとCodexの双方で同じ利用者意図から同等のSDDフェーズを開始する。
3. Where 安全性または誤起動防止のため暗黙起動を許可しないスキルがある場合, the SDD基盤 shall 未承認の処理を開始せず、その理由と利用可能な明示起動方法を利用者へ示す。
4. If 自然言語の依頼から対象フェーズを一意に決められない場合, the SDD基盤 shall 未承認のフェーズを推測して進めず、必要な確認または明示起動方法を提示する。
5. The SDD基盤 shall 自然言語入口と明示入口で、成果物、承認状態、出力先、停止条件を同じにする。
6. The SDD基盤 shall 暗黙起動の可否と、初期一覧への表示可否を別の性質として扱う。

### Requirement 4: Claude CodeとCodexのフロー同等性

**Objective:** As a SDD利用者, I want 利用エージェントを替えても同じ開発手順を利用したい, so that エージェント固有の抜け道や作業不能が発生しない

#### Acceptance Criteria

1. The SDD基盤 shall Claude CodeとCodexの双方でdiscovery、requirements、design、tasks、implementation、validationの各SDDフェーズを開始可能にする。
2. The SDD基盤 shall 両環境で同じ一次成果物、承認状態、テスト記録、完了判定を使用する。
3. The SDD基盤 shall 両環境で現行の人間承認ゲート、TDD、実装前停止の運用契約を同じにする。
4. Where 現行スキルが独立レビューを実行する場合, the SDD基盤 shall その起動可否と既存挙動を両環境で同等にする。
5. If プラットフォーム固有のコマンド構文、metadata、補助ファイルまたは起動方法に差が必要な場合, the SDD基盤 shall 差の理由と対応する同等動作を記録する。
6. If 一方の環境だけでSDDフェーズを開始または完了できる場合, the SDD基盤 shall end-to-endパリティを不合格として報告する。
7. The SDD基盤 shall プラットフォーム固有の表記差を、利用者が同じ意図を実行できる対応関係として案内する。

### Requirement 5: 承認ゲートと安全規約の維持

**Objective:** As a 承認者, I want スキルの検出・起動を修復しても既存の安全挙動を弱めないでほしい, so that #39の責任を先取りせず新たな迂回経路を作らない

#### Acceptance Criteria

1. The SDD基盤 shall #32によるmetadata、配置、起動経路、文書、検証の変更によって現行のapproval、TDD、review、実装前停止の意味を弱めない。
2. The SDD基盤 shall スキルの検出または起動に失敗した場合に、管理されていない代替処理で現行の承認ゲートを迂回しない。
3. When 同じuser-facingスキルを明示入口または自然言語入口から起動する場合, the SDD基盤 shall 入口によって現行の停止条件と成果物契約を変えない。
4. If #32の変更前後で自動approval、review fallbackまたは実装開始条件が変化する場合, the SDD基盤 shall #32の安全回帰として検証を不合格にする。
5. The SDD基盤 shall Issue #39が所有する厳格な独立レビュー、自動approval廃止、同一context fallback廃止を#32の完了条件として扱わない。
6. The SDD基盤 shall Issue #39が後続で更新する安全契約をClaude CodeとCodexの双方へ適用・検証できる意味的パリティ境界を提供する。

### Requirement 6: 利用者向け起動案内

**Objective:** As a SDD利用者, I want 使用中のエージェントに合った実行方法を確認したい, so that 存在しないコマンドや廃止済み設定に誘導されない

#### Acceptance Criteria

1. The SDD基盤 shall READMEにClaude Code、Codex、自然言語の各入口を並べて示す。
2. The SDD基盤 shall 各環境の明示起動構文と、同じSDDフェーズに対応するコマンドの関係を示す。
3. The SDD基盤 shall 初期一覧に表示されないスキルを公式な選択経路または明示指定から利用する手順を示す。
4. The SDD基盤 shall 暗黙起動を許可しないuser-facingスキルについて利用可能な明示起動方法を示す。
5. If Codexで廃止済みまたは無効な設定案内が存在する場合, the SDD基盤 shall 現行の利用可能な方法へ更新するか、不要な案内を削除する。
6. If 文書で案内する入口が対象環境で起動不能である場合, the SDD基盤 shall 文書検証または受入検証を不合格にする。

### Requirement 7: 意味的パリティ検証

**Objective:** As a テンプレート保守者, I want プラットフォーム固有差を許容しながら同等性を検証したい, so that 全差分を異常扱いせず実害のある不整合を検出できる

#### Acceptance Criteria

1. The SDD基盤 shall Claude Code向けとCodex向けのスキル名、必須説明、分類、起動方針、必須補助資産、主要ワークフロー契約を意味的パリティの検査対象にする。
2. The SDD基盤 shall プラットフォーム変換によって意図された本文またはmetadataの差を、理由が定義された許容差として扱う。
3. The SDD基盤 shall バイト単位のディレクトリ一致だけを全スキルのパリティ成立条件にしない。
4. If `SKILL.md`の必須metadataが欠落、不正、重複または正規名と不一致である場合, the SDD基盤 shall 対象スキルと理由を示して検証を不合格にする。
5. If user-facingスキルの必須資産、明示起動経路または安全契約が片側で欠落する場合, the SDD基盤 shall 対象環境と差分を示して検証を不合格にする。
6. If 許容差が根拠なしに追加される場合, the SDD基盤 shall その差をパリティ成立の例外として受け入れない。
7. When 意味的パリティ検証が成功する場合, the SDD基盤 shall 検証したスキル数、環境、検査区分を確認できる結果を出す。
8. If 意味的パリティ検証が不合格、未実施、実行不能または証跡不足である場合, the SDD基盤 shall 対象の検証結果をfailed、partialまたはunverifiedとして成功と区別する。
9. If 意味的パリティ検証が成功でない場合, the SDD基盤 shall init、sync、releaseまたはE2Eパリティの成功宣言にその結果を使用しない。

### Requirement 8: 配布経路での維持と検証

**Objective:** As a テンプレート保守者, I want 初期導入と同期後にも起動可能性を維持したい, so that テンプレート内だけ直って利用先で再発することを防げる

#### Acceptance Criteria

1. When SDD基盤を新規リポジトリへ初期導入する場合, the SDD基盤 shall Claude CodeとCodexの双方へ検証対象のスキルと利用案内を配布する。
2. When SDD基盤を既存リポジトリへ同期する場合, the SDD基盤 shall sync処理の責任範囲内で更新されたスキルに対して意味的パリティを検証する。
3. When initまたはsync後検証を実行する場合, the SDD基盤 shall ファイル存在だけでなく、検出・起動に必要なmetadataと利用契約を検査する。
4. If syncの競合によって必要なスキル資産が適用されていない場合, the SDD基盤 shall Codex対応済みと報告しない。
5. If initまたはsync後の意味的パリティ検証が失敗する場合, the SDD基盤 shall 利用者が対象環境、スキル、失敗区分を確認できる結果を返す。
6. The SDD基盤 shall initまたはsyncの配布方法を理由に、Claude CodeまたはCodexの一方だけを検証対象から除外しない。
7. If init後の必須意味的パリティ検証が成功しない場合, the SDD基盤 shall initを正常完了として報告しない。
8. If sync後に必須スキルが競合、未適用または未検証である場合, the SDD基盤 shall syncの結果を完全適用成功と区別し、未検証対象を報告する。

### Requirement 9: 新規セッションによるend-to-end受入確認

**Objective:** As a リリース判定者, I want 実際の新規セッションでSDDフローを確認したい, so that 静的ファイル検査だけでは見つからない利用不能を防げる

#### Acceptance Criteria

1. When 本機能の受入確認を行う場合, the SDD基盤 shall Claude CodeとCodexの新規セッションをそれぞれ使用する確認手順と期待結果を提供する。
2. The SDD基盤 shall リポジトリ直下と配下ディレクトリから開始したCodexセッションで、代表user-facingスキルの検出と明示起動を確認する。
3. The SDD基盤 shall 利用可能スキルを最小化した環境と、user・system・pluginスキルを含む通常環境のCodexセッションで到達性を確認する。
4. The SDD基盤 shall init直後、sync直後、`cyclox2_docker`反映後の新規セッションで検出・起動結果を確認する。
5. The SDD基盤 shall Claude CodeとCodexの双方で標準入口からrequirements、design、tasks、implementation、validationへ進む代表フローと現行の人間承認停止を確認する。
6. The SDD基盤 shall Requirement 2で列挙したリポジトリスキルについて公式な選択経路からの検出を確認する。
7. The SDD基盤 shall Requirement 2で列挙したリポジトリスキルについて正規名による明示起動を確認する。
8. The SDD基盤 shall Requirement 2で列挙したリポジトリスキルについて対象処理の開始を確認する。
9. If 新規セッションを再起動せず既存セッションだけで確認した場合, the SDD基盤 shall skill discovery変更の受入確認を完了扱いにしない。
10. If 手動確認を含む受入項目が未実施である場合, the SDD基盤 shall end-to-endパリティを完了扱いにしない。

### Requirement 10: 証跡と失敗診断

**Objective:** As a テンプレート保守者, I want パリティ検証の証跡と失敗箇所を残したい, so that 再発時に表示省略と本当の利用不能を区別できる

#### Acceptance Criteria

1. When パリティ検証または受入確認を実行する場合, the SDD基盤 shall 対象バージョン、対象環境、開始位置、スキル名、source/scope、実ファイル、enabled状態、検証経路、結果を記録する。
2. The SDD基盤 shall 初期一覧、公式選択経路、明示起動、暗黙起動、実処理開始の結果を区別して記録する。
3. If スキルを利用できない場合, the SDD基盤 shall 少なくとも未配布、metadata不正、探索不能、選択不能、同名曖昧性、誤source選択、設定によるdisable、明示起動不能、暗黙起動不能、処理開始後失敗を区別して報告する。
4. If context budgetによる初期一覧省略が疑われる場合, the SDD基盤 shall 公式選択経路と明示起動の結果を確認するまで未配布と断定しない。
5. When 検証を再実行する場合, the SDD基盤 shall 前回結果と混同しない新しいセッションまたは実行単位の証跡を残す。
6. The SDD基盤 shall Claude CodeとCodexの結果を対応付けて比較できる形式で記録する。
7. If 同名スキルのうち対象scopeと異なる実体だけが起動した場合, the SDD基盤 shall 対象スキルの起動確認を合格扱いにしない。

### Requirement 11: 上流境界と互換性

**Objective:** As a テンプレート保守者, I want 上流との責任境界を維持してパリティを修復したい, so that 不要な再配布や隣接Issueの混入を避けられる

#### Acceptance Criteria

1. The SDD基盤 shall cc-sddを実行して得る現行の配布境界を維持し、cc-sddのソースまたは生成物を本機能のために`payload/`へ同梱しない。
2. The SDD基盤 shall 上流が生成するプラットフォーム差を、意味的同等性を満たす限り一律のバイト一致へ変換しない。
3. If 修復にcc-sdd生成物の再配布が必要になる場合, the SDD基盤 shall 本specの承認済み境界を越える変更として停止し、人間の再承認を要求する。
4. The SDD基盤 shall Issue #30のsync競合解決方式、Issue #31の実行通知、Issue #39の独立レビュー・自動approval・fallback改修、Issue #33以降のバージョン昇格を本機能の実装へ混在させない。
5. If 隣接Issueの未実装機能が受入確認に必要である場合, the SDD基盤 shall 依存する確認項目と代替可能な手動確認を明示し、未実装機能を暗黙に追加しない。
6. The SDD基盤 shall 既存の正本配置、TDD、承認状態、ブランチ運用を本機能の導入前後で維持する。

### Requirement 12: 個人向け`sdd-init`の配布と起動

**Objective:** As a SDD導入者, I want Claude CodeとCodexのどちらからも`sdd-init`を起動したい, so that リポジトリへSDD基盤を導入する入口自体も片側だけ利用不能にならない

#### Acceptance Criteria

1. When 個人向けinstallを実行する場合, the SDD基盤 shall Claude CodeとCodexのそれぞれが文書化された探索位置から検出できる`sdd-init`を配布する。
2. When install後にClaude CodeまたはCodexの新規セッションを開始する場合, the SDD基盤 shall 公式な選択経路または正規名から`sdd-init`を検出可能にする。
3. When 利用者が`sdd-init`を明示指定する場合, the SDD基盤 shall 対応する導入処理を開始する。
4. When 利用者が自然言語でSDD基盤の導入を依頼する場合, the SDD基盤 shall 対象環境の起動方針に従って`sdd-init`を起動するか、必要な明示起動方法を提示する。
5. The SDD基盤 shall Claude Code向けとCodex向けの`sdd-init`について、必須手順、配布内容、安全条件の意味的パリティを検証する。
6. If 現行のCodex向けinstall先が現行Codexの文書化された探索位置と一致しない場合, the SDD基盤 shall 検出可能な配置へ更新するか、公式に保証された互換経路を証跡付きで確認する。
7. If install後の新規セッションで`sdd-init`を検出または明示起動できない場合, the SDD基盤 shall 個人向けinstallのCodexパリティを不合格にする。
8. The SDD基盤 shall `sdd-init`の修復を理由にcc-sddのソースまたは生成物を`payload/`へ同梱しない。
