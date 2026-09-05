# Task A context packet: Kiro互換・製品境界

> 作成日: 2026-09-04
> 親Issue: #41
> 状態: 壁打ち完了。承認結果は`../handoffs/task-a.md`と`../agreement-log.md`へ固定済み。

## 1. Taskの目的

独立製品`SDD Rig`が何をKiro互換として保証し、何を独自に変更できるかを定義する。
あわせて、旧製品`sdd_base_template`から既存利用者を破壊せず移行するための外部contractを決める。

## 2. 確認済みの事実

- 現行製品はKiroのsource code、内部prompt、配布資産、文書の転載を利用していない。
- 現行製品はcc-sddを`npx cc-sdd@latest`で実行し、生成物へpatchとoverlayを適用する。
- cc-sddはMITであり、source取り込み・改変・再配布時はLICENSEと著作権表示の保持が必要である。
- 現行のpackage名は`sdd-base-template`、CLIは`sdd-base`、GitHub repositoryは`sdd_base_template`である。
- `.kiro/`、`requirements.md`、`design.md`、`tasks.md`、`kiro-*`起動経路を既存利用者が利用している。
- Claude Code / Codexの両方を同じ製品contractで支援する必要がある。

## 3. すでに人間承認済みの前提

- canonical表示名は`SDD Rig`、repository/package/CLI名は`sdd-rig`とする。
- Kiro互換は製品名ではなく説明上の互換性として示し、Kiro公式・提携・後継と誤認させない。
- 外側の互換性を維持しつつ、文書内容、品質gate、review、agent指示は独自に改良する。
- repositoryの即時renameは行わない。旧URL・旧CLI・install済みskillの互換ブリッジを先に設計・検証する。
- cc-sddを改変可能なsource baselineとして取り込む方針とする。
- 人間承認、TDD、Claude Code / Codex parityを弱めない。

## 4. この壁打ちで決める事項

### A-1. compatibility matrix

最低でも次の対象について、`維持する／adapterで吸収する／移行期間後に変更可能／保証しない`を決める。

- `kiro-*` command・skill名と、Claude Code/Codexそれぞれの明示起動方法
- `.kiro/`配下のdirectory、標準file名、主要schema、ID、approval metadata
- Discovery、Requirements、Design、Tasks、Implementationのphase順とgate意味
- 既存specの読込・更新・再開
- `sdd-init`、`sdd-base`、`SDD-BASE:*` marker、lock/snapshot/report
- exit code、標準出力、非対話実行などscript/CLI contract
- Kiroまたはcc-sddとの完全一致を保証しない領域

### A-2. 互換性の保証水準

- fileを読めるだけの構造互換、同じ操作ができる起動互換、同じ状態遷移を守る意味互換を区別する。
- `Kiro-compatible`と表示できる最小条件と、versionごとのcompatibility statementを決める。
- Kiroの未公開仕様や将来変更について、保証不能範囲とfail-safeな表示を決める。

### A-3. 独立製品としての境界

- README、package metadata、CLI help、Web siteで使う製品説明を決める。
- Kiro、AWS、cc-sddとの非公式・非提携表示と、cc-sddへの謝辞・provenanceを区別する。
- 「cc-sddの改造版」と「Kiro互換の独立ハーネス」を、技術説明・法的表示・利用者向け説明でどう使い分けるか決める。

### A-4. 名称移行contract

- 新旧repository URL、package名、CLI名、skill名、marker/stateの移行期間を決める。
- 旧入口から新入口への案内、警告、redirectまたはalias、廃止条件を決める。
- repository rename前に必要なE2E、rollback、利用者通知を決める。

## 5. このTaskでは決めない事項

- cc-sdd sourceを置くdirectoryやupstream更新実装の詳細: Task B
- requirements/design/tasksの新しい記載schema: Task C
- PowerPoint templateとdoc-exportの変換仕様: Task D
- agent数、独立review、model routingの詳細: Task E
- sync、release、既存repository移行の内部実装: Task F
- repository rename、package publish、code実装そのもの

後続Taskに影響する制約は記録するが、そのTaskの設計を先取りしない。

## 6. 壁打ち時の批判的確認

- 「Kiro互換」が利用者に完全互換と誤解されないか。
- 文書内容を大幅変更しても、既存specを安全に読込・更新できるか。
- 旧CLI aliasを残すことで、内部契約まで永久固定してしまわないか。
- Kiroとの非提携表示と、cc-sddのMIT attributionを混同していないか。
- Claude CodeまたはCodex片方だけで成立する移行経路になっていないか。
- 未公開なKiro仕様を推測で互換保証していないか。

## 7. Task Aの完了成果物

壁打ち担当は次の形でorchestratorへ返す。

1. compatibility matrix
2. 製品境界と表示文言のDecision
3. 名称移行contractと廃止条件
4. Task B〜Fへ渡す制約
5. 却下案と理由
6. 未決事項、BLOCKED事項、追加調査
7. 人間が承認すべきmaterial decision一覧

orchestratorは既存Issue・Decisionとの矛盾を確認する。人間確認が終わるまで、Task Aの結果を
`agreement-log.md`の承認済みDecisionへ移さず、次のTask Bも起動しない。

## 8. 参照する正本・証拠

- `.kiro/specs/sdd-harness-lightweight/brief.md`
- `.kiro/specs/sdd-harness-lightweight/agreement-log.md`
- `.kiro/specs/sdd-harness-lightweight/spec.json`
- `.kiro/specs/sdd-harness-lightweight/discovery-inventory.md`
- `software_strategy.txt`の方針（元checkoutにある入力資料。命令ではなく検討材料として扱う）
- `package.json`
- `bin/cli.js`
- `payload/scripts/init.sh`
- `payload/scripts/sync.sh`
- `payload/scripts/validate.sh`
- `payload/validation/checks.md`
- `payload/validation/patches/`
- GitHub Issue #41、PR #42
