# Independent Gate Review: requirements

## Initial Convergence Audit

- Reviewer: `requirements_review_32`
- Reviewer model: `gpt-5.6-sol` (`Sol`, Codex)
- Model selection: 承認済み方針に基づく、実行環境で利用可能な最新Sol class
- Reviewed at: 2026-08-15T17:58:09+09:00
- Input hash kind: `sha256-git-blob-manifest-v1`
- Input hash: `d40f45f4cb0db63f7ac92de8fcbf6d00b92d625da74c81030b4660e1b0cdf773`
- Verdict: `RETURN_TO_PREVIOUS_GATE`
- Review mode: read-only（reviewerによる対象編集なし）

## Consolidated Findings

### 1. High / INITIAL_DEFECT: Issue #39との責任境界と実装順が両立しない

本specはIssue #39の独立レビュー実装を対象外とし、#32を#39実装より先行させる。一方、
Requirements 4、5、9は独立レビューを含む安全契約が両環境で成立することを#32の受入条件にする。
現行スキルには自動approvalや同一context reviewへのfallbackが残るため、#39を実装せずに#32を
完了できない循環がある。Issue #39と#32の記載にも先行順の不一致がある。

人間判断候補:

1. #39を先に実装し、#32は確定した安全契約をパリティ検証する。
2. #32へ必要な#39実装を移管し、#39の責任範囲を縮小する。
3. #32を純粋なdiscovery/invocation parityへ縮小し、安全契約のE2E受入を#39へ委ねる。

### 2. High / INITIAL_DEFECT: 正規インベントリと個人向けinstallの範囲が未確定

Boundary Contextは`kiro-*`を対象にするが、「配布する各SDDスキル」という表現は非`kiro-*`の
`doc-export`と、個人環境へ配る`sdd-init`まで含み得る。さらに現行のCodex向け`sdd-init`設置先と、
OpenAI公式が公開するuser skill探索位置の対応も受入確認されていない。

人間判断候補:

1. `kiro-*`だけを#32の正規インベントリにし、`doc-export`と`sdd-init`は別Issueへ分ける。
2. `kiro-*`と`doc-export`をリポジトリ配布スキルとして#32へ含め、個人向け`sdd-init`は別Issueへ分ける。
3. `kiro-*`、`doc-export`、`sdd-init`をすべて#32へ含め、install後の新規セッション検証も受入対象にする。

### 3. High / INITIAL_DEFECT: 意味的パリティ検証のfail-closed結果契約がない

検証不合格、未検証、証跡欠落時に、init、sync、validate、release判定のどれが非成功またはpartialとなり、
どこで成功宣言を禁止するかが不足している。現行initのpost validationは失敗を握りつぶせるため、
NGを表示しながら全体を成功終了する解釈が残る。

推奨修正: failure、partial、unverifiedを成功から区別し、init/sync完了・リリース・E2E parityの成功宣言を
禁止する条件をoperator-observableな要件として追加する。

### 4. Medium / INITIAL_DEFECT: 自然言語起動と暗黙起動禁止方針が矛盾する

Requirement 3.1は自然言語依頼で無条件にskill起動を要求するが、Requirements 1.4と3.3は
スキル単位で暗黙起動を禁止できる。暗黙起動を許可する場合の起動と、許可しない場合の確認・明示案内を
別の契約にする必要がある。

### 5. Medium / INITIAL_DEFECT: 同名スキル・disable設定・起動元provenanceを識別できない

通常環境ではrepo、user、system、plugin由来の同名スキルが共存し得るが、現行証跡はスキル名だけで、
どの実体を起動したかを判定できない。source/scope、実ファイル、enabled状態を証跡へ含め、
duplicate-name ambiguity、wrong-source selection、config-disabledを診断区分へ追加する必要がある。

### 6. Low / INITIAL_DEFECT: 観測段階を結合した受入条件がある

Requirement 2 AC3とRequirement 9 AC6は、検出、明示起動、実処理開始を単一ACへ結合している。
各段階の失敗を独立検証できるよう分割する必要がある。

## Coverage Matrix

| 観点 | 初回判定 | 根拠・対応 |
|---|---|---|
| 問題・利用者・期待変化 | COVERED | briefと各Objectiveで明確 |
| スコープ・隣接Issue境界 | GAP | Finding 1、2 |
| 原因未確定の前提 | COVERED | 公式仕様と整合し、metadata形式を主因と断定していない |
| discovery/selector/explicit/implicit/実処理 | GAP | Finding 4〜6 |
| Claude/Codex E2E parity | GAP | Finding 1、2 |
| 人間承認/TDD/独立review安全契約 | GAP | Finding 1 |
| semantic parityとfail-closed | GAP | Finding 3 |
| init/sync/downstream/new-session | GAP | install経路と失敗結果契約が不足 |
| 診断証跡 | GAP | Finding 5 |
| cc-sdd非再配布・ライセンス境界 | COVERED | Requirement 11とリポジトリ規約に整合 |
| EARS・数値ID・単一挙動 | GAP | 機械形式は合格、複合AC 2件 |
| 成果物間整合 | GAP | Finding 1 |
| 過剰仕様・実装詳細・重大な抜け | GAP | Finding 1〜3、5 |
| Codex/Claude現行仕様 | GAP | Finding 2、5 |

## Mechanical Results

- Numeric Requirement headings: 11 / 11
- Requirements with Acceptance Criteria: 11 / 11
- Total Acceptance Criteria: 70
- EARS-prefix conforming: 70 / 70
- Non-EARS criteria: 0
- Compound behaviors requiring split: 2

## Gate Result

Finding 3〜6は承認済み境界内の局所修正として一括対応できる。しかしFinding 1はIssue #39との
実装責任・依存順、Finding 2は正規インベントリと個人向けinstallの公開契約について人間による境界再決定を
必要とする。requirementsを修正せず、前段ゲートへ戻して停止する。

## Human Decision After Initial Audit

- Decided at: 2026-08-15
- Decision:
  1. #32はスキルの検出・起動・意味的パリティを所有し、既存の安全挙動を弱めない。#39は#32完了後に、厳格な独立レビュー、自動approval廃止、同一context fallback廃止を両環境へ実装する。
  2. #32の正規インベントリへ、全`kiro-*`、`doc-export`、個人向け`sdd-init`を含める。
- Batch disposition:
  - Finding 1、2を上記決定でbrief、requirements、agreement-logへ反映。
  - Finding 3のfail-closed結果契約をRequirements 7、8へ追加。
  - Finding 4の自然言語入口を、暗黙起動許可時の起動と禁止時の停止・明示案内へ分離。
  - Finding 5のsource/scope、実ファイル、enabled状態、同名・誤source・disable診断を追加。
  - Finding 6の検出、明示起動、実処理開始を独立ACへ分割。
- Next action: 同じreviewerで全14観点を再走査し、original finding closure、regression、late finding、scope changeを確認する。

## Follow-up 1 - Final Convergence

- Reviewer: `requirements_review_32`（初回監査と同一reviewer）
- Reviewer model: `gpt-5.6-sol` (`Sol`, Codex)
- Reviewed at: 2026-08-15T20:00:33+09:00
- Input hash kind: `git-blob-manifest-v1`
- Input hash: `e324353449e9ddd686273eb264c0e7467d2b0168`
- Verdict: `PASS`

### Original Findings Closure

| Finding | 状態 | 収束根拠 |
|---|---|---|
| F1 #39との責任・依存境界 | CLOSED | #32を検出・起動・意味的パリティと安全回帰防止、#39を厳格review・自動approval/fallback廃止へ分離し、両Issueも同じ順序へ更新 |
| F2 インベントリ/install範囲 | CLOSED | 全`kiro-*`、`doc-export`、個人向け`sdd-init`を明示し、Requirement 12でinstall後の探索・起動を規定 |
| F3 fail-closed結果契約 | CLOSED | Requirements 7.8〜7.9、8.7〜8.8でfailed/partial/unverifiedと成功宣言禁止を規定 |
| F4 自然言語/implicit矛盾 | CLOSED | Requirements 3.1〜3.4で暗黙起動許可時と禁止・曖昧時を分離 |
| F5 provenance/同名/disable | CLOSED | Requirements 2.10、10.1、10.3、10.7でsource/scope、実ファイル、enabled、同名、wrong source、disableを規定 |
| F6 複合観測段階 | CLOSED | Requirements 2.3〜2.5、9.6〜9.8でselector検出、明示起動、実処理開始を分離 |

### Coverage Matrix

| 観点 | 最終判定 |
|---|---|
| 問題・利用者・期待変化 | COVERED |
| スコープ・隣接Issue境界 | COVERED |
| 原因未確定の妥当性 | COVERED |
| discovery/selector/explicit/implicit/実処理 | COVERED |
| Claude/Codex E2E parity | COVERED |
| 人間承認/TDD/独立review安全契約 | COVERED |
| semantic parity/fail-closed | COVERED |
| install/init/sync/downstream/new-session | COVERED |
| 診断証跡 | COVERED |
| cc-sdd非再配布・ライセンス境界 | COVERED |
| EARS・数値ID・単一挙動 | COVERED |
| brief/requirements/agreement/spec/review整合 | COVERED |
| 過剰仕様・実装詳細・重大な抜け | COVERED |
| Codex/Claude現行仕様 | COVERED |

### Regression / Late Finding / Scope Change

- Regression: None
- `LATE_FINDING`: None
- 未承認の`SCOPE_CHANGE`: None

### Mechanical Results

- Numeric Requirement headings: 12 / 12
- Requirements with Acceptance Criteria: 12 / 12
- Total Acceptance Criteria: 89
- EARS-prefix conforming: 89 / 89
- Atomicity: 89 / 89
- Non-EARS criteria: 0

### Hash Verification

Ordered manifest:

```text
brief.md:c3d05bbd8f35fce1ab926bb1d25abd89c8a74fcd
requirements.md:92be4ea6f132cb05a21942f6d06c835db26656ce
```

`git hash-object --stdin`の結果は`e324353449e9ddd686273eb264c0e7467d2b0168`で、記録値と一致する。

全初回指摘が閉じ、完全再走査で新しい問題を検出しなかった。requirementsは人間レビュー・承認依頼へ進める。
