# Implementation Plan: Claude Code / Codex SDDスキルパリティ

> 全taskは失敗testまたは検証fixtureを先に作り、最小実装、回帰確認の順で完了する。
> manifest、生成skill tree、lifecycle scriptを複数taskが順次更新するため、本計画はsequentialとし、
> parallel markerは付けない。下流環境が未準備または未許可なら受入taskを`UNVERIFIED`のまま未完了にする。

- [ ] 1. 正規インベントリと検証primitiveを構築する
- [ ] 1.1 正規inventory schemaと全対象分類をtest先行で実装する
  - repository 18対象とpersonal `sdd-init`について、正規名、scope、origin、role、起動方針、必須資産のschema testを先に作る。
  - 欠落、重複、未分類、片側だけのskill、根拠なしplatform差をfailureにする。
  - 完了時、全19対象が一意に分類され、未定義skillを追加するとtestが失敗する。
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 7.1, 7.2, 7.5, 7.6, 11.2, 12.5_
  - _Boundary: SkillInventoryManifest_

- [ ] 1.2 管理対象frontmatterとscalar YAML parserをtest先行で実装する
  - 正常scalar、重複key、型不一致、複数行値、未対応構文、正規名とfolder名不一致のfixtureを作る。
  - Node標準APIだけで管理対象subsetを読み、未知形式を推測せず`UNVERIFIED`または`FAILED`へ分類する。
  - 完了時、対応subsetは決定的に読め、曖昧なYAMLが成功扱いにならない。
  - _Requirements: 7.4, 7.8, 10.3, 11.1, 11.3, 11.6, 12.8_
  - _Boundary: SkillInventoryManifest_

- [ ] 1.3 パリティ状態と終了コード集約をtest先行で実装する
  - `PASS / PARTIAL / UNVERIFIED / FAILED`の全組合せと優先順位をfixture化する。
  - statusと終了コード`0 / 2 / 1`を一意に変換し、非PASSを成功へ昇格させない。
  - 完了時、複数agent・skill・stageの結果が設計優先順位どおり一つの状態へ集約される。
  - _Requirements: 7.7, 7.8, 7.9, 8.5, 8.7, 8.8, 10.3_
  - _Boundary: SemanticParityValidator_

- [ ] 1.4 安全契約assertion policy schemaをtest先行で定義する
  - frontmatter一致、anchored section、normalized hash、delegation reference、paired artifactの各assertion kindをschema化する。
  - 対象agent/skill/path、anchor、必須・禁止条件、baseline、failure code、許可delegateの参照整合を検証する。
  - skill treeに対するassertion評価は行わず、policy定義と参照の妥当性だけを所有する。
  - 完了時、欠落field、未知kind、未定義contract/delegate、重複failure codeを持つmanifestが拒否される。
  - _Requirements: 4.2, 4.3, 4.4, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 7.1, 7.5, 11.4, 11.6_
  - _Boundary: SkillInventoryManifest_

- [ ] 2. Agent別invocation metadataを決定的にmaterializeする
- [ ] 2.1 Claudeのinvocation frontmatterとhelper guardをtest先行で生成する
  - implicit-enabled、explicit-only、internal/helperのfrontmatter期待値をfixture化する。
  - helperの許可parent、構造化delegation、直接起動停止guardを管理領域だけへ生成する。
  - 完了時、非管理本文を維持しながら同じmanifestから同じClaude bytesが得られる。
  - _Requirements: 1.2, 1.3, 1.4, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.5, 4.7, 7.1, 7.2_
  - _Boundary: InvocationMetadataMaterializer_

- [ ] 2.2 Codexの公式interfaceとimplicit policyをtest先行で生成する
  - display name、25〜64文字説明、正規`$skill`を含むprompt、implicit policyの期待bytesをfixture化する。
  - top-level旧形式、prompt名不一致、policy欠落を合格にしない。
  - 完了時、全Codex対象が公式schemaの決定的metadataを持つ。
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.8, 3.1, 3.3, 3.6, 6.2, 7.1, 7.4, 7.5, 12.2_
  - _Boundary: InvocationMetadataMaterializer_

- [ ] 2.3 fresh・keep・stageの適用policyをtest先行で実装する
  - missing、identical、differingの各targetをfresh、keep、stageで再現する。
  - keepは不一致targetを保持して完全`.new`を出し、stageは実treeを変更せず候補を返す。
  - 完了時、各policyのtarget、candidate、statusが状態表どおりになる。
  - _Requirements: 7.8, 7.9, 8.1, 8.2, 8.3, 8.4, 8.5, 8.8_
  - _Boundary: InvocationMetadataMaterializer_

- [ ] 2.4 repositoryとpersonalの生成対象をmanifestへ統合する
  - 全`kiro-*`、`doc-export`、personal `sdd-init`を同じmaterialization commandの対象にする。
  - upstream、overlay、personalのorigin別にpre/post期待集合を生成する。
  - 完了時、片側欠落や未生成metadataがstatic validation前に検出可能な候補として揃う。
  - _Requirements: 1.1, 1.3, 1.5, 1.6, 2.1, 2.3, 4.1, 7.5, 8.1, 8.6, 12.1, 12.5_
  - _Boundary: InvocationMetadataMaterializer_

- [ ] 3. 意味的パリティvalidatorとreportを構築する
- [ ] 3.1 inventory・frontmatter・asset検査をtest先行で実装する
  - agent別skill集合、正規名、folder、説明、必須assetの正常・異常fixtureを作る。
  - context一覧省略と実ファイル欠落を混同せず、staticに証明可能な範囲だけ判定する。
  - 完了時、対象agent・scope・skill・path付きで欠落理由を診断できる。
  - _Requirements: 1.1, 1.5, 1.6, 2.6, 2.7, 2.8, 7.1, 7.3, 7.4, 7.5, 8.3, 10.3, 10.4_
  - _Boundary: SemanticParityValidator_

- [ ] 3.2 安全契約assertion evaluatorをtest先行で実装する
  - Task 1.4で定義した各assertion kindをagent別skill treeへ適用する正常・異常fixtureを作る。
  - approval、TDD、review、implementation-stopの必須・禁止条件とbaseline hashを実際に評価する。
  - 完了時、自動approval、fallback、実装開始条件の回帰が対象skillとfailure code付きで失敗する。
  - _Requirements: 4.2, 4.3, 4.4, 5.1, 5.2, 5.3, 5.4, 5.6, 7.1, 7.5_
  - _Boundary: SemanticParityValidator_

- [ ] 3.3 invocation・delegation・platform差の統合検査をtest先行で実装する
  - Claude/Codexのimplicit、explicit-only、helper mappingと許可parentを検査する。
  - Task 3.2の契約結果とagent mappingを統合し、根拠なしplatform差を拒否する。
  - 完了時、同じ利用者意図・delegate・停止条件を持つagent pairだけがsemantic PASSになる。
  - _Requirements: 2.2, 2.4, 2.5, 2.10, 3.1, 3.2, 3.3, 3.5, 3.6, 4.1, 4.5, 4.6, 4.7, 7.1, 7.2, 7.5, 7.6, 11.2_
  - _Boundary: SemanticParityValidator_

- [ ] 3.4 機械可読reportと失敗taxonomyをtest先行で実装する
  - run ID、時刻、phase、agent、scope、skill、stage、source path、expected/actual、evidenceをschema化する。
  - 未配布、metadata不正、探索不能、選択不能、曖昧source、disable、明示/暗黙不能、処理開始後失敗を区別する。
  - 完了時、再実行ごとに新しい証跡が作られ、両agentの結果を同じrunで比較できる。
  - _Requirements: 2.8, 2.10, 7.7, 7.8, 8.5, 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7_
  - _Boundary: SemanticParityValidator_

- [ ] 3.5 pre・post・personal validation commandをtest先行で実装する
  - preはupstream origin、postは全manifest、personalは両canonical targetを期待するfixtureを作る。
  - commandごとにreportと終了コードを返し、検査中に自動修復しない。
  - 完了時、各phaseの正しい対象集合だけが要求され、非PASSが呼出元へ透過される。
  - _Requirements: 7.7, 7.8, 7.9, 8.3, 8.5, 8.6, 8.7, 12.5, 12.7_
  - _Boundary: SemanticParityValidator_

- [ ] 4. 個人向け`sdd-init`を標準scopeへ非破壊配布する
- [ ] 4.1 canonical・legacy ownership classifierをtest先行で実装する
  - absent、managed-current、managed-old、identical-unmarked、unknown-owner、broken/external symlinkをfixture化する。
  - marker、resolved link source、candidate内容以外の推測でmanaged判定しない。
  - 完了時、canonical/legacy各targetが6状態の一つへ一意に分類される。
  - _Requirements: 10.3, 10.7, 12.1, 12.5, 12.6, 12.7_
  - _Boundary: PersonalSkillInstaller_

- [ ] 4.2 copy candidate・marker・atomic placementをtest先行で実装する
  - 完全なcopy bundleと管理markerを一時領域で作り、検証後だけtarget単位で置換する。
  - placement failureを注入し、既存canonicalとlegacyを保持する。
  - 完了時、copy targetから実際のinit開始へ到達し、半完成targetが公開されない。
  - _Requirements: 8.6, 10.1, 12.1, 12.2, 12.3, 12.5, 12.7, 12.8_
  - _Boundary: PersonalSkillInstaller_

- [ ] 4.3 link bundle topologyと実行validationをtest先行で実装する
  - marker付きtarget内のskill本文、agent metadata、payload component linkをfixture化する。
  - source移動、欠落、repository外linkをbroken/externalとして検出する。
  - 完了時、link targetの相対payloadから実際のinit開始へ到達し、壊れたlinkを自動置換しない。
  - _Requirements: 10.1, 10.3, 12.1, 12.2, 12.3, 12.5, 12.6, 12.7, 12.8_
  - _Boundary: PersonalSkillInstaller_

- [ ] 4.4 canonical配置後のlegacy移行とrollbackをtest先行で実装する
  - canonical unknown/externalは両target保持と`PARTIAL`、identical-unmarkedは非置換adoptionとする。
  - canonical実行validation失敗ではlegacyを保持し、PASS後だけmanaged legacyを削除する。
  - 完了時、所有不明データが削除されず、移行順序と終了状態が設計flowに一致する。
  - _Requirements: 6.2, 10.3, 10.7, 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7_
  - _Boundary: PersonalSkillInstaller_

- [ ] 5. validate・init・syncへfail-closed判定を統合する
- [ ] 5.1 standalone validateのpre/post呼出しと終了コード透過をtest先行で統合する
  - pre/post各commandの正常、PARTIAL、UNVERIFIED、FAILEDをlifecycle wrapperから再現する。
  - report pathと対象phaseを表示し、非PASSをexit 0へ変換しない。
  - 完了時、standalone validateだけでstatic contractと終了コードを一貫して確認できる。
  - _Requirements: 7.7, 7.8, 7.9, 8.3, 8.5, 8.7, 10.1, 10.3_
  - _Boundary: LifecycleGateAdapter_

- [ ] 5.2 initのfresh・keep・overwrite・compareをtest先行で統合する
  - mode別のmissing、identical、differing targetとpre/post期待集合をfixture化する。
  - keepは`.new`と`PARTIAL`、compareは実tree非変更と導入未完了、overwriteは明示選択時だけbackup後置換とする。
  - post非PASS時の失敗無視と成功表示を除去する。
  - 完了時、全init modeのfile状態、report、表示、終了コードが状態表に一致する。
  - _Requirements: 5.1, 5.2, 7.8, 7.9, 8.1, 8.3, 8.4, 8.5, 8.6, 8.7, 10.1, 10.3, 11.1, 11.4, 11.6_
  - _Boundary: LifecycleGateAdapter_

- [ ] 5.3 syncのlockなし・新規管理対象をtest先行で統合する
  - lockなしと既存lockの新規targetについてabsent、identical、differingをfixture化する。
  - 初回sync中にparity資産を処理し、適用・adoption時だけlock/snapshotを作る。
  - 完了時、所有不明targetは元を保持して`.new`と`PARTIAL`になり、baseへ採用されない。
  - _Requirements: 7.8, 7.9, 8.2, 8.3, 8.4, 8.5, 8.8, 10.1, 10.3, 11.5, 11.6_
  - _Boundary: LifecycleGateAdapter_

- [ ] 5.4 syncの既存管理対象・clean merge・conflictをtest先行で統合する
  - managed unchanged、managed changed、clean merge、conflictを既存safe apply境界で再現する。
  - clean適用時だけlock/snapshotを更新し、conflictは元を保持して完全`.new`を残す。
  - semantic non-PASSを完全適用成功と区別し、#30の一般merge判断を変更しない。
  - 完了時、target、`.new`、lock、snapshot、reportが全状態で一致する。
  - _Requirements: 5.1, 5.2, 7.8, 7.9, 8.2, 8.3, 8.4, 8.5, 8.8, 10.1, 10.3, 11.4, 11.5, 11.6_
  - _Boundary: LifecycleGateAdapter_

- [ ] 6. 配布案内・旧検査・local report管理を新契約へ移行する
- [ ] 6.1 agent別の実在する起動案内をcontract test先行で配布する
  - Claude slash、Codex selectorと`$skill`、自然言語入口、同一phase対応をmanifestと照合する。
  - explicit-onlyとhelperの停止・委譲、一覧省略時の到達方法、personal canonical scopeを案内する。
  - 完了時、文書化された入口が片側だけで起動不能ならcontract testが失敗する。
  - _Requirements: 1.3, 2.6, 2.7, 2.8, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.7, 6.1, 6.2, 6.3, 6.4, 6.6, 12.1, 12.2, 12.4, 12.6_
  - _Boundary: GuidanceOverlay_

- [ ] 6.2 廃止済みCodex設定のstrict patchをtest先行で実装する
  - 既知block、適用済みblock、未知のuser変更をfixture化する。
  - 既知blockだけを現行selector・明示起動案内へ冪等置換し、未知形状は保持して`UNVERIFIED`にする。
  - 完了時、user変更を黙って書き換えず、廃止設定を配布成功として残さない。
  - _Requirements: 6.5, 6.6, 7.8, 8.1, 8.5, 10.3_
  - _Boundary: GuidanceOverlay_

- [ ] 6.3 旧checks・allowlistとmanifest正本の重複をcontract test先行で解消する
  - 旧byte-diff検査、既知差一覧、semantic manifestの矛盾fixtureを作る。
  - 旧文書はsemantic/live検査へ誘導し、許容差の正本をmanifest一つに限定する。
  - 完了時、旧allowlistだけの変更では例外を追加できず、正本間の矛盾がtestで失敗する。
  - _Requirements: 7.1, 7.2, 7.3, 7.6, 7.7, 11.2_
  - _Boundary: GuidanceOverlay, SkillInventoryManifest_

- [ ] 6.4 local parity reportのgitignore配布をtest先行で統合する
  - report pathのmissing、既存記述、重複記述をinit/sync fixtureで再現する。
  - ignore ruleを冪等配布し、report自体を一次成果物やcommit対象にしない。
  - 完了時、init/sync後にlocal reportが生成可能で、ignore entryが一件だけ存在する。
  - _Requirements: 8.1, 8.2, 8.5, 10.5, 11.6_
  - _Boundary: GuidanceOverlay, LifecycleGateAdapter_

- [ ] 7. 新規セッション受入harnessと隔離probeを完成する
- [ ] 7.1 evidence schemaとacceptance checklistをtest先行で実装する
  - agent、distribution、開始位置、scope load、stage、flow、source/path/enabled、run IDを必須化する。
  - 既存session、未実施manual項目、証跡不足、古いrun IDを`UNVERIFIED`にする。
  - 完了時、正常証跡だけがschemaを通り、agent pairを同じrunで比較できる。
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.9, 9.10, 10.1, 10.2, 10.5, 10.6_
  - _Boundary: SessionAcceptanceHarness_

- [ ] 7.2 minimal homeと同名canaryの隔離fixtureを実装する
  - repo/user scopeで異なるcanary IDを返すharmless skillと一時homeを作る。
  - repo root/subdirectory、minimal/normal scopeの開始条件とconfig hash採取を自動化する。
  - 完了時、外部通信・git write・approval変更なしでselected sourceを判別できる。
  - _Requirements: 2.9, 2.10, 9.2, 9.3, 10.1, 10.3, 10.4, 10.7_
  - _Boundary: SessionAcceptanceHarness_

- [ ] 7.3 duplicate・disable・wrong-sourceの否定probeを実装する
  - 同名複数scope、Codex disable、wrong canary、source不明を個別fixtureで実行する。
  - selector表示だけで合格せず、source/path/enabledを確定できない場合は非PASSにする。
  - 完了時、各否定probeが期待する`UNVERIFIED`または`FAILED`とfailure codeを返す。
  - _Requirements: 2.6, 2.7, 2.8, 2.10, 7.8, 9.3, 10.1, 10.2, 10.3, 10.4, 10.7_
  - _Boundary: SessionAcceptanceHarness_

- [ ] 7.4 implicit・explicit-only・helper・approval停止probeを実装する
  - 曖昧な自然言語、explicit-only直接依頼、helper直接起動、正規parent delegationを両agent用fixtureで再現する。
  - 未承認implementation fixtureは実装を開始せず、人間承認停止することを成功条件にする。
  - 完了時、許可入口だけが処理を始め、禁止入口は成果物・approval・実装状態を変更しない。
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.3, 4.4, 5.2, 5.3, 9.5, 10.2, 10.3_
  - _Boundary: SessionAcceptanceHarness_

- [ ] 8. 自動回帰と実配布状態のlive acceptanceを完了する
- [ ] 8.1 unit・integration・空repository init・personal installの自動suiteを完了する
  - unitからintegrationの順で全testを実行し、空repository init、copy/link install、初回/更新syncを通す。
  - 全対象数、両agent、全static検査区分をreportで確認する。
  - 完了時、自動suiteが全PASSし、失敗時はlifecycle・agent・skill・stageを診断できる。
  - _Requirements: 7.7, 7.8, 7.9, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 10.1, 10.3, 12.1, 12.5, 12.7_
  - _Boundary: LifecycleGateAdapter, SemanticParityValidator_

- [ ] 8.2 Codexの代表9スキルをrepo rootとsubdirectoryから検出する
  - minimal scopeの新規sessionでselector到達性を9スキルすべて記録する。
  - initial list省略とselector未検出を区別し、selected source/pathを確認する。
  - 完了時、2開始位置×9スキルの検出証跡が揃い、別scopeだけの検出をPASSにしていない。
  - _Requirements: 2.1, 2.3, 2.6, 2.7, 2.9, 2.10, 9.1, 9.2, 9.6, 9.9, 9.10, 10.1, 10.4, 10.7_
  - _Boundary: SessionAcceptanceHarness_

- [ ] 8.3 Codexの代表9スキルを明示起動して処理開始を確認する
  - 8.2と別の新規sessionで正規`$skill`起動と安全な処理開始を9スキルすべて記録する。
  - explicit-only、helper delegation、implementation承認停止を実skillで確認する。
  - 完了時、9スキル×明示起動・処理開始の証跡が揃い、起動後失敗をPASSにしていない。
  - _Requirements: 2.2, 2.4, 2.5, 2.8, 3.3, 4.1, 4.3, 4.4, 5.2, 5.3, 9.5, 9.7, 9.8, 9.9, 9.10, 10.2, 10.3_
  - _Boundary: SessionAcceptanceHarness_

- [ ] 8.4 Codex通常scopeとClaude Codeの同等フローを確認する
  - user/system/pluginを含むCodex通常scopeでduplicate・disable・wrong-source判定を実行する。
  - Claude Code新規sessionでrequirements、design、tasks、implementation停止、validationの代表フローを実行する。
  - 完了時、両agentが同じ一次成果物・approval・test記録・停止条件へ接続する証跡が揃う。
  - _Requirements: 3.1, 3.2, 3.5, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 5.1, 5.3, 5.4, 9.3, 9.5, 9.9, 9.10, 10.1, 10.2, 10.6_
  - _Boundary: SessionAcceptanceHarness_

- [ ] 8.5 init直後とsync直後の新規session acceptanceを実行する
  - version/hashを固定したtemp targetへinitし、両agentの検出・明示・代表flowを記録する。
  - 同targetへsyncした後は必ずsessionを新規作成し、同じmatrixを再実行する。
  - 完了時、init/syncの各distributionでstatic reportとlive evidenceがともにPASSする。
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 9.1, 9.4, 9.9, 9.10, 10.1, 10.5_
  - _Boundary: LifecycleGateAdapter, SessionAcceptanceHarness_

- [ ] 8.6 `cyclox2_docker`受入のtechnical setupと実行許可を確定する
  - 対象revision、適用する#32 template revision、init/sync方法、branch policy、実行環境、証跡保存先を記録する。
  - 下流変更の明示的な利用許可を確認し、未準備・未許可なら`UNVERIFIED`としてtaskを未完了に保つ。
  - 完了時、実装者が下流製品変更を推測せず、再現可能な一つの受入条件で8.7を開始できる。
  - _Requirements: 9.1, 9.4, 9.9, 9.10, 10.1, 10.5, 11.4, 11.5, 11.6_
  - _Boundary: SessionAcceptanceHarness_

- [ ] 8.7 許可済み`cyclox2_docker`反映後のlive acceptanceを実行する
  - 8.6で固定した方法だけで#32成果物を反映し、製品固有変更や隣接Issue機能を追加しない。
  - 両agentの新規sessionで代表9スキルとpersonal入口のsource/scope/path/enabled、明示起動、処理開始を記録する。
  - 完了時、配布先でも同じSDDフローがPASSするか、具体的な非PASS証跡を残して未完了になる。
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 4.1, 4.2, 4.3, 4.4, 4.6, 6.6, 9.1, 9.4, 9.5, 9.6, 9.7, 9.8, 9.9, 9.10, 10.1, 10.2, 10.3, 10.7, 11.4, 11.5, 12.2, 12.3, 12.4, 12.7_
  - _Boundary: SessionAcceptanceHarness_

- [ ] 8.8 最終安全回帰と実装証跡を確定する
  - approval、TDD、review、implementation-stopが変更前後で弱まっていないことをbaseline assertionとlive evidenceで確認する。
  - cc-sddのソース・生成物がpayloadへ増えておらず、#30/#31/#39/#33の実装が混入していないことを確認する。
  - test結果と結合試験checklistへrun IDを記録し、static/liveのどちらか非PASSなら完了扱いにしない。
  - 完了時、全受入証跡が現行input hashへ結び付き、実装完了承認へ提示できる。
  - _Requirements: 4.2, 4.3, 4.4, 4.6, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 7.7, 7.8, 7.9, 10.1, 10.2, 10.5, 10.6, 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 12.8_
  - _Boundary: SemanticParityValidator, SessionAcceptanceHarness_
