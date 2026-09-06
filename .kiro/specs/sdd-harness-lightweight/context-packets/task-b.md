# Task B context packet: cc-sdd source取り込み・provenance・上流更新境界

> 作成日: 2026-09-06
> 親Issue: #41
> 関連Issue: #33、#34
> 状態: 壁打ち完了・人間承認済み。確定結果は`../handoffs/task-b.md`を正として参照する。
> このfileは開始時の調査・比較仮説を保存するものであり、実装contractとして使用しない。

## 1. Taskの目的

cc-sddを実行時に外部取得する現行方式から、SDD Rig repository内で改変可能なsource baselineとして
管理する方式へ移行するため、次の境界を決める。

- どのupstream sourceを、どの単位・方式で取り込むか
- upstream由来部分とSDD Rig独自部分をどう識別するか
- MIT LICENSE、著作権表示、NOTICE、provenanceをどう保持するか
- upstream新版をどう検出・検証・承認・昇格・rollbackするか
- source、build成果物、配布package、利用者環境の責務をどう分離するか

このTaskはarchitecture上のDecisionを作るDiscoveryである。実装方法を一案へ早期固定せず、
互換性、保守性、再現性、配布の自己完結性を比較して人間が判断できる状態にする。

## 2. Task Aから引き継ぐ承認済み制約

- SDD Rigはcc-sddをbase sourceとして開発する独立製品であり、Kiro公式・AWS提携・後継を名乗らない。
- V1は定義済みの外部workflowについて構造互換と起動互換を保証する。完全な出力一致、内部実装一致、
  未公開または将来のKiro仕様との意味一致は保証しない。
- 既存`.kiro/`、未完成を含むspec、既知の`spec.json` schema・phase・approval metadata、未知field、
  `SDD-BASE` marker、旧lock/snapshot、旧`sdd-base`入口を非破壊で扱う。
- Claude CodeとCodexの双方で、現行17個の`kiro-*` skillを検出・明示起動可能にする。
  `doc-export`はSDD Rig固有skillとして別にparityを保証する。
- repositoryの即時renameは禁止する。旧URL、package、CLI、install済みskillを含むbridgeとE2E、
  rollbackを先に設計・検証する。
- V1は旧stateをそのまま扱うin-place bridgeとし、別stateや二重管理を作らない。
- 人間承認、TDD、Claude Code / Codex parityを弱めない。

Task BのDecisionがこれらを満たせない場合、Task Aを暗黙に上書きせずorchestratorと人間判断へ戻す。

## 3. 確認済みの事実

### 3.1 upstream baseline候補

2026-09-06時点で、cc-sddのnpm `latest`と最新GitHub Releaseはいずれも`3.0.2`である。

| 項目 | 確認値 |
|---|---|
| upstream repository | `https://github.com/gotalab/cc-sdd` |
| package directory | `tools/cc-sdd` |
| release / annotated tag | `v3.0.2` |
| tagが指すcommit | `3795eb4274c07dedcf56c571b5c0a826736f23c8` |
| release公開日時 | `2026-04-13T21:25:16Z` |
| npm package | `cc-sdd@3.0.2` |
| npm tarball SHA-1 | `74589fb4d7ccb643260dc51fa8911c73702a7f29` |
| npm integrity | `sha512-7r9hyUhY35aeKVoqhViad28/JTT5SdDH3pPhGccY8nFpmT25+EP6vywetUwVL8wUCi3deJQBg/YcFU2gNnhC6w==` |
| license | MIT, `Copyright (c) 2025 gotalab` |

調査時点のupstream `main`は`v3.0.2`より先行している。再現可能な初期baseline候補は
移動する`main`ではなく、release tagとそのcommitで固定する必要がある。

### 3.2 Git sourceとnpm配布物の差

- Git tagの`tools/cc-sdd/src/`にはTypeScript sourceがあり、CLI、agent registry、manifest、plan、
  renderer、resolver等に分かれている。
- Git tagの`tools/cc-sdd/templates/`にはClaude Code、Codexを含む複数platform向けtemplateと
  shared settingがある。
- `cc-sdd@3.0.2`のnpm packageが公開対象とするのは`dist`と`templates`であり、TypeScript sourceは含まれない。
- したがってnpm tarballだけのvendorは「改変可能なsource baseline」という目的を満たさない。
  npm tarballは公開成果物との照合材料にはなるが、source取得元の代わりにはできない。
- upstream packageは実行時dependencyを持たず、build/test用にTypeScript、Vitest、Node型定義を使う。

### 3.3 現行SDD Rig前身の構造

- `payload/KNOWN_GOOD_CCSDD_VERSION`は`3.0.2`だが、`payload/scripts/init.sh`はClaude Code用とCodex用に
  `npx -y cc-sdd@latest`を実行している。記録値は実際の取得versionを固定していない。
- cc-sdd生成後、`payload/validation/patches/`と`payload/overlay/`で独自変更を適用する。
- `bin/cli.js`は`sdd-init` skillと`payload/`を自己完結bundleとしてinstallする。
- `README.md`、`AGENTS.md`、`CLAUDE.md`には「cc-sddは実行のみ・再配布しない」という現行方針がある。
  source取り込みを採用する場合、旧記述を同時に有効な方針として残せない。
- 現repositoryのMIT license（`Copyright (c) 2026 kyamady-dorokid`）は、cc-sddのlicense・著作権表示を
  代替しない。

## 4. 法的・provenance上の絶対条件

cc-sddのsourceまたはsubstantial portionsを取り込み、改変・再配布する場合、MIT条項に従い
次を保持する。

1. cc-sddのMIT LICENSE全文
2. `Copyright (c) 2025 gotalab`
3. upstream repository、tag、commit、取得対象path
4. SDD Rigが独立製品であり、upstream公式・提携・後継ではないこと
5. upstream由来部分とSDD Rigによる変更を追跡できる記録

具体的なLICENSE配置、NOTICE文言、package同梱確認、source file header要否は壁打ちで決める。
法的判断が必要な不明点が残る場合は推測で実装せず停止条件とする。

## 5. この壁打ちで決める事項

### B-1. 初回source取得・import方式

最低でも次を比較し、採用案と却下理由を示す。

| 案 | 長所 | 主な懸念 |
|---|---|---|
| release tagのsnapshotをvendorし、provenance manifestと更新toolを持つ | npm配布を自己完結でき、配置と変更境界を製品側で制御しやすい | upstream historyが直接残らず、更新差分の生成手順が必要 |
| Git subtreeとして取り込む | upstream historyと再取り込み手順をGitで追いやすい | repository history・操作が重く、monorepo内path抽出とlocal改変の衝突管理が必要 |
| Git submoduleとして参照する | upstream commitを明確に固定できる | npm配布、offline install、利用者clone、local改変、旧入口の自己完結性と相性が悪い |
| npm tarballをvendorする | published packageとの一致を検証しやすい | TypeScript sourceがなく、改変可能なsource baselineにならない |

比較軸は、baseline再現性、upstream diff、local変更の識別、npm/package配布、offline利用、
rollback、CI、保守者の操作負荷、repository sizeとする。

### B-2. 取り込み範囲

次を比較する。

- `tools/cc-sdd` package全体をtagから取り込む
- source engineと全templateを取り込むが、SDD Rigの製品保証はClaude Code/Codexに限定する
- source engineとClaude Code/Codex向けtemplateだけを抽出する
- upstreamをpristine mirrorとして保持し、build時にSDD Rig側のpolicy・adapter・templateを合成する

単純なfile数削減だけで決めない。部分抽出によりupstream更新差分が読みにくくなる可能性と、
未サポートplatform資産まで配布・検証対象に見える可能性の両方を評価する。

### B-3. upstream由来部分と独自変更の境界

最低でも次の責務を、directory、build、ownershipのどこで分けるか決める。

- 変更しないupstream baseline
- SDD Rig coreの独自policy・workflow
- Claude Code / Codex platform adapter
- Kiro互換template・schema・state処理
- projectごとのoverlayまたはoverride
- 旧`sdd-base`／`sdd-init`互換bridge

候補は、`pristine upstream + patch/overlay`、`import sourceを直接改変しdeltaを記録`、
`upstream layer + SDD Rig core/adapter`の分離である。現行overlayを残すか廃止するかも、
目的ではなく責務と更新容易性から判断する。

### B-4. provenanceとlicenseの記録方式

次をmachine-readableかつ人間監査可能にする方法を決める。

- upstream URL、release tag、annotated tag、commit、取得path
- 取得日時、source tree hash、npm tarball digestとの対応
- license全文、著作権表示、NOTICE/READMEの帰属説明
- baselineに対する除外、追加、変更の一覧または再現可能なdiff
- buildに含まれるupstream資産と、配布package内でのlicense存在確認

### B-5. upstream更新lifecycle

次の状態遷移と人間gateを決める。

1. release tagを候補として取得する。moving branchやnpm `latest`を直接昇格しない。
2. 隔離領域でsource・provenanceを検証する。
3. upstream差分とSDD Rig独自差分の衝突を提示する。
4. Kiro互換、旧資産再開、Claude/Codex parity、unit/integration/E2Eを検証する。
5. 検証証跡を提示し、人間承認後だけbaselineを昇格する。
6. source、build成果物、provenance、license、必要なadapterを同一変更単位で更新する。
7. 直前baselineへ決定的にrollbackできることを確認する。

利用者環境がcc-sdd単体versionを選ぶ設計には戻さない。利用者が受け取るのはSDD Rigの統合releaseであり、
upstream baselineの昇格はmaintainer責務とする。

### B-6. build・配布境界

- repositoryでTypeScript sourceから何をbuildし、何をcommitするか
- npm package、GitHub経由install、local skill bundleへ何を同梱するか
- 利用者環境で外部cc-sdd取得を不要にできるか
- clean checkoutから再現可能なbuildをどう検証するか
- source map、license、NOTICE、template、manifestをpackage漏れなく検査する方法
- Node.js version、package manager、lockfile、test runnerをどこまでupstreamから継承するか
- 旧CLIと新CLIが同一core・同一stateを使うことをどう保証するか

### B-7. #41・#33・#34の責務境界

現時点の整理案を批判的に確認する。

- **#41 Task B**: 製品architectureとしてsource intake、provenance、license、update/rollback境界を決める。
- **#33**: Task BのDecisionを受け、upstream lifecycleの正式requirements/design/tasksを管理する親spec候補。
- **#34**: #33配下で初回importと反復可能なupstream検証を実装する人間管理用の作業Issue候補。
- **#32**: 取り込んだcore上でClaude Code / Codexの検出・明示起動・semantic parityを検証する。
- **#30**: 利用者へはcc-sdd単体ではなく、統合済みSDD Rig releaseを安全にsyncする。

#41と#33を別specにすることでDecisionや承認を二重管理するなら統合を検討する。一方、#33が独立した
保守lifecycleを長期管理する価値があるなら、#41は上位contractだけを所有し詳細を参照する。

## 6. 壁打ち開始時の推奨仮説（履歴・不採用部分あり）

壁打ちの開始仮説は次のとおりだった。最終Decisionでは、固定参照元から一方向forkする一方、
release後にpristine baseline、vendor snapshot、継続同期toolを常設しない方針へ改訂された。
確定内容は`../handoffs/task-b.md`を参照する。

1. `v3.0.2` tagの`tools/cc-sdd`を、commitを明記したvendored source snapshotとして取り込む。
2. upstream baselineは可能な限りpristineに保ち、SDD Rig core・platform adapter・product templateを別layerに置く。
3. provenance manifest、upstream LICENSE、NOTICE、取得・diff・昇格を再現するmaintainer toolを同梱する。
4. sourceは全packageを保持する一方、製品としてbuild・配布・受入保証するplatformはClaude Code/Codexに限定する案を
   第一比較対象とする。
5. npm tarball digestはupstream published artifactとの照合に使うが、source正本にはしない。
6. baseline昇格はrelease tag候補、isolated validation、critical review、人間承認、rollback検証を必須とする。

この案の弱点は、upstream package全体を保持することで未サポートplatformも製品機能に見えること、
pristine layerと独自layerの合成がbuildを複雑化しうること、snapshot方式では履歴取込より差分tool品質への依存が
大きいことである。これらに有効な対策がない場合は別案を選ぶ。

## 7. このTaskでは決めない事項

- requirements/design/tasksの新schema、重複排除、日本語基準: Task C
- 既定PPT template、doc-export presentation仕様: Task D
- agent数、独立review、model routingの詳細: Task E
- user-facing syncの3-way mergeやworktree output: Task Fおよび#30/#37
- repository renameの実施、package publish、source import、code変更
- 特定directory名やbuild toolの最終設計: Requirements/Design gate

## 8. 壁打ち時の批判的確認

- sourceを取り込むこと自体が目的化し、現行の外部contractを壊していないか。
- upstream sourceを残しただけで、実際の配布物と同じbaselineを再現できると誤認していないか。
- local変更をupstreamへ追従しやすい形で分離できているか。patch地獄を別名で再作成していないか。
- 全upstream template保持と製品サポート範囲を混同していないか。
- packageからlicenseやNOTICEが漏れる経路がないか。
- update失敗時に中途半端なsource、build、provenanceの組合せが残らないか。
- Claude Codeだけ、またはCodexだけで成立する取込・build・validationになっていないか。
- #41と#33に同じrequirements・approval状態を重複させていないか。
- 利用者環境へnpm network accessやcc-sdd単体version選択を再び要求していないか。

## 9. 停止条件

次のいずれかが解消できない場合、推測で先へ進まずorchestratorと人間判断へ戻す。

- cc-sddのLICENSE全文と著作権表示を配布物まで確実に保持できない
- tag/commitから同一baselineを再現できない
- upstream由来部分とSDD Rig変更の境界・差分を監査できない
- Task AのKiro互換、旧資産非破壊、in-place state、旧入口bridgeを壊す
- Claude Code / Codex parityが成立しない
- baseline更新を人間承認前に利用者へ配布しうる
- rollback後にsource、build、provenance、stateの整合を戻せない
- #41と#33/#34の正本・承認責務が二重化する

## 10. Task Bの完了成果物

壁打ち担当は次の形でorchestratorへ返す。

1. source intake方式の比較表とDecision
2. 取り込み範囲と非サポート資産の扱い
3. upstream / SDD Rig / platform adapter / project overrideの責務境界
4. provenance、LICENSE、NOTICE、配布検証contract
5. upstream候補取得→検証→承認→昇格→rollbackの状態遷移
6. build・package・install境界
7. #41・#33・#34および関連Issueの責務整理
8. Task C〜Fへ渡す制約
9. 却下案と理由
10. 未決事項、BLOCKED事項、追加調査
11. 人間が承認すべきmaterial decision一覧

orchestratorはTask Aとの整合、Issue間の二重正本、法的表示、後続migrationへの影響を確認する。
人間確認が終わるまでTask Bの結果を`agreement-log.md`の承認済みDecisionへ移さず、Task Cも起動しない。

## 11. 参照する正本・一次情報

### repository内

- `../brief.md`
- `../agreement-log.md`
- `../spec.json`
- `../discovery-inventory.md`
- `../handoffs/task-a.md`
- `payload/KNOWN_GOOD_CCSDD_VERSION`
- `payload/scripts/init.sh`
- `payload/scripts/validate.sh`
- `payload/validation/patches/`
- `payload/overlay/`
- `bin/cli.js`
- `package.json`
- `README.md`
- `LICENSE`
- `AGENTS.md` / `CLAUDE.md`

### upstream

- cc-sdd repository: `https://github.com/gotalab/cc-sdd`
- release `v3.0.2`: `https://github.com/gotalab/cc-sdd/releases/tag/v3.0.2`
- baseline commit: `https://github.com/gotalab/cc-sdd/commit/3795eb4274c07dedcf56c571b5c0a826736f23c8`
- upstream LICENSE: `https://github.com/gotalab/cc-sdd/blob/v3.0.2/LICENSE`
- package source: `https://github.com/gotalab/cc-sdd/tree/v3.0.2/tools/cc-sdd`
- npm package: `https://www.npmjs.com/package/cc-sdd/v/3.0.2`

upstreamのmoving `main`や検索結果の要約より、release tag、commit、repository source、npm registry metadataを
一次情報として優先する。
