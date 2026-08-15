# Independent Design Review

## Review Metadata

| Field | Value |
|---|---|
| Reviewer | independent sub-agent |
| Model | `gpt-5.6-sol` |
| Environment | Codex |
| Review style | critical, evidence-based, convergence review |
| Input hash kind | `git-blob-manifest-v1` |
| Input files | `requirements.md`, `research.md`, `design.md` |

## Initial Review

| Field | Value |
|---|---|
| Input hash | `2d4779a1fa62460634009d3e5e7e91da839d109b` |
| Verdict | `REVISE` |

### Consolidated Findings

1. `D1` High — initのpre/post、syncのlockなし・新規管理対象・競合時の状態遷移が不足し、
   一回の処理でparityを成立させる実装判断が閉じていない。
2. `D2` High — canonical/legacy targetの所有判定と、link modeで`payload/`を解決できるbundle topologyが
   不足し、既存targetの破壊または実行不能を招き得る。
3. `D3` High — 安全契約ID、Claude側の明示専用制御、live source/scope証跡、否定probe、
   acceptance harnessの実ファイルが宣言止まりで検証可能性を欠く。

数値トレーサビリティは89/89、Issue境界、Codex公式contract、cc-sdd非再配布境界は適合。
3件とも#32内の局所修正で、requirementsへ戻る必要はない。

## Repair Batch 1

- init modeとsync lock/targetの状態遷移表、phase別pre/post期待集合、実適用時だけのlock更新を追加。
- canonical/legacy双方の6状態、atomic candidate、copy/linkの実体配置、未知所有者の非破壊処理を追加。
- contract assertion schema、agent別起動mapping、live evidence schema/template/fixture、source採取方法、
  duplicate/disable/wrong-source/ambiguous/explicit-only等の否定probeを追加。

## Follow-up Review

### Follow-up 1

| Field | Value |
|---|---|
| Input hash | `38d8d4b7925a2f41ddfc9ffb064d1dee3177fe6d` |
| Verdict | `REVISE` |

- `D1`: CLOSED — phase別init、sync状態遷移、適用済み資産だけのlock更新で解消。
- `D2`: CLOSED — 6-state ownership、atomic candidate、copy/link topologyで解消。
- `D3`: OPEN — Claude `user-invocable`とCodex `allow_implicit_invocation`だけではhelperをparent専用に
  できず、Claude frontmatterのmaterialize境界も不足。
- Regression / late finding / scope change: none。

### Repair Batch 2

- Claude helperへ`user-invocable: false`と`disable-model-invocation: true`を併用し、parentは既知pathの
  helper本文を参照する契約へ変更。
- Codex helperはselector非表示を保証せず、暗黙禁止、直接起動guard、構造化parent delegationで
  実処理開始を制御する契約へ変更。
- materializerをagent別frontmatter、helper guard、Codex metadataの生成・safe applyへ拡張。
- helper直接起動とparent delegationのnegative/positive probeを明記。

### Follow-up 2

| Field | Value |
|---|---|
| Input hash | `27d345bfb25df648492b0c434212bf21cae1f4db` |
| Verdict | `REVISE` |

- `D1`: CLOSED。Repair Batch 2によるregressionなし。
- `D2`: ownershipとbundle topologyは維持されたが、`L1`によりOPENへ戻る。
- `D3`: CLOSED。agent別helper制御、delegation、materialization、negative probeが公式contractと整合。
- Regression: none。Scope change: none。

### Late Finding L1

`Medium` — Personal Install Migrationの図だけが、managed legacyを新canonical targetの実行validation前に
削除できる順序になっている。状態表と本文は「canonical PASS後だけ削除」と定義しており、図と矛盾する。
unknown-owner経路も、parity検査がPASSでも集約結果を`PARTIAL`のまま維持する表現が必要。

推奨順序は、canonical候補完成・atomic配置 → canonical実行validation → 失敗時legacy保持・非0 →
PASS時だけmanaged legacy削除 → unknown-ownerがあれば`PARTIAL`集約、である。

第2修正batch後のlate findingであるため、自動の第3修正・reviewへ進まず、人間判断を要求する。

## Human Judgment After Follow-up 2

- Decision: `L1`の推奨修正を承認し、同じreviewerによる追加収束確認を許可する。
- Rationale: 本文・状態表の安全契約は確定済みで、migration flow図だけを同じ順序へ整合する局所修正のため。
- Process amendment: 独立reviewの一括修正・収束確認は最大10巡まで許可し、10巡でも収束しない場合に
  異常状態として人間判断へ戻す。この恒久ルールはIssue #39へpending amendmentとして申し送り済み。

## Repair Batch 3

- migration flowをcanonical候補配置 → canonical実行validation → PASS時のみmanaged legacy削除へ変更。
- canonical validation失敗時はlegacyを保持して非0終了する。
- unknown-owner等を保存した場合はparity PASSでも集約結果を`PARTIAL`に維持する。

## Follow-up 3

| Field | Value |
|---|---|
| Input hash | `ea77b8dcfeb78f48c8d55b9991e271b93e74190f` |
| Verdict | `REVISE` |

- `L1`: CLOSED。
- `D1`, `D3`: CLOSED、regressionなし。
- `D2`: Repair Batch 3で発生した`R1 REGRESSION`によりOPEN。
- `R1`: canonical状態を分類した後に全状態をatomic placementへ流す図が、unknown-ownerと外部symlinkの
  上書き禁止契約と矛盾する。

## Repair Batch 4

- canonical stateをabsent/managed changed、managed identical、identical-unmarked、unknown/externalへ分岐。
- unknown/externalはcanonicalとlegacyを保持し、候補または診断を残して`PARTIAL`終了。
- atomic placement失敗は既存canonicalとlegacyを保持して非0終了。
- placement成功または非置換adoption後だけcanonical実行validationへ進む。

## Follow-up 4

| Field | Value |
|---|---|
| Input hash | `6d5027624412fa2b7a300318daae5c4c6987bee8` |
| Verdict | `PASS` |

- `R1`, `L1`, `D1`, `D2`, `D3`: all CLOSED。
- 12 requirements / 89 acceptance criteria: 89/89 covered and testable。
- Boundary、official skill contracts、self-contained bundle、lifecycle、non-destructive migration、
  live evidence、fail-closed、cc-sdd non-redistribution: all covered。
- Findings、late finding、regression、scope change: none。

Design review converged after Repair Batch 4. The approved combined design/tasks route may proceed to tasks,
but no implementation approval is implied.

## Reopened From Tasks Review

Tasks review found `DL1 LATE_FINDING`: the allowed dependency named a non-existent shared shell helper.
The design now names the existing sync hash/lock/merge helpers and makes parity-specific logic self-contained in
the Node CLI. The prior PASS is stale because the design input hash changed.

### Repair Batch 5

- Removed the non-existent common shell helper dependency.
- Bound sync integration to the existing hash, lock, merge helpers and `sdd_apply_file`.
- Explicitly rejected a new implicit common helper dependency.

### Follow-up 5

| Field | Value |
|---|---|
| Input hash | `976e31b0ee0f0a9d70db4cd212749a991a5a238a` |
| Verdict | `PASS` |

- `DL1`, `D1`, `D2`, `D3`, `L1`, `R1`: all CLOSED。
- 89/89 acceptance criteria covered with no dependency mismatch。
- Findings、late finding、regression、scope change: none。

The prior tasks artifact remains stale and must be regenerated before tasks review.
