# Task D handoff: doc-export・人間向け二次成果物

> 受領日: 2026-10-08
> 文書区分: Task D専用sessionからorchestratorへ返した壁打ち結果の伝達記録。
> 正本ではない。採用Decisionは`../agreement-log.md` #120〜#131を参照する。
> 受信本文SHA-256: `3984d7fb95428bf48fdd10c6f13034767d6eed20bf35b573d81921988091cbc1`。
> 現在状態: orchestrator正本化済み。2026-10-08に送信元sessionが`CANONICALIZATION_PASS`を確認。

---
TASK_D_HANDOFF_V1 | handoff-sha256=UNAVAILABLE（送信元local JS runtimeにhash APIなし。受信本文をorchestrator側でhash化してください）— Issue #41 Serial Discovery / Task D doc-export・人間向け二次成果物

状態:
- D-1〜D-7は人間との対話で順番に確認し、以下のADOPTED項目を人間が採用した。
- このhandoffは正本ではなくpending-canonicalizationの派生記録。Requirements / Design / Tasks / 実装の承認や着手許可ではない。
- repository file、GitHub Issue、approval状態、実装、template、commit、push、PR、renameは変更していない。
- source context packet: .kiro/specs/sdd-harness-lightweight/context-packets/task-d.md
- packet SHA-256: dab0818b0957d61345b7f56b6b2ca96498036a1e836d6a6ff79982dd6fb1d028
- packet記載baseline: PR #45 merge commit 2de65ff38413b338fc4f2568481e77f234838903
- live Issue #41冒頭のTask C進捗表示はpacketと不一致でstaleに見えたため、Task D Decision根拠には使用していない。

## ADOPTED — D-1 用途と承認境界

D1-01 | 主体=doc-export利用者・承認者 | PPTは人間の理解、共有、論点把握を支援する派生ビューであり、正本または正式承認対象にしない | 理由=二重権威防止 | owner=Task D
D1-02 | 正式承認はPPTから正本reviewへ明示的に遷移した後だけ成立する | pending gate、対象正本文書、version/hash、許可範囲を直前に提示する | owner=Task D + Task C contract維持
D1-03 | 人間が正本を開く、または対象を明示的に選択する操作を承認前に必須とする | PPT表示だけでは不足 | owner=Task D UX、実行方式=Task E/F
D1-04 | PPT閲覧中の「OK」「良さそう」「進めて」等の一般的肯定を正式approvalへ昇格させない | owner=Task D/E
D1-05 | 正本へアクセスできない相手はfeedback・賛同を返せるがSDD gateの正式承認者にはしない | owner=Task D
D1-06 | PPTに未掲載の条件、例外、禁止、risk、未決事項がある場合、正本遷移前にその存在を明示する | owner=Task D
D1-07 | Claude Code / Codex双方でD1-01〜06を意味的に同一とする | owner=#32 / Task E/F、製品要件=Task D

## ADOPTED — D-2 生成契機・形式・phase profile

D2-01 | human review gateではPPT生成を提案するが自動生成しない | 理由=不要なToken・renderer費用、stale生成物を防ぐ | owner=Task D
D2-02 | 生成は人間の明示依頼後に行う | owner=Task D/E
D2-03 | 形式指定がなければ、一意なpending gateに対応するphase別profileのPPTを既定とする | owner=Task D
D2-04 | pending gateまたは対象phaseが一意でなければ推定せず確認する | owner=Task D/E
D2-05 | Word、PDF、複数形式、複数phaseは明示指定時だけ生成する | owner=Task D
D2-06 | phase profile候補は requirements-review / design-review / tasks-review / status-share とする | exact schemaはDesign保留 | owner=Task D
D2-07 | PPT生成失敗だけで読める正本のreview・approvalを不可能にしない | ただし依頼されたPPTの失敗をreview可能・成功と報告しない | owner=Task D
D2-08 | 現行「manifestなし=requirements/design/tasks全文を各DOCX」は新しい既定PPT contractと不一致であり、将来実装時のmigration/compatibility対象 | owner=Design/Task F

## ADOPTED — D-3 意味変換

D3-01 | 正本の意味を維持する範囲で並べ替え、要約、言い換え、表・図への変換を許可する | owner=Task D
D3-02 | 主体、対象、条件/trigger、規範強度、観測可能な結果、例外/停止条件、否定、未決/未検証/仮定、risk/severity、固定値/閾値/version、stable IDを削除・変更しない | owner=Task D
D3-03 | 正本にない要件、設計判断、関係、依存、因果、優先度、承認結果を事実として追加しない | owner=Task D
D3-04 | 元の順序が優先順位・時系列・依存を表す場合は維持し、意味不明なら勝手に並べ替えない | owner=Task D
D3-05 | MUST/MAY/BLOCKED等の規範強度を弱めたり強めたりしない。EARS keyword、schema、code、path、log、license等の必要な原文を保持する | owner=Task D
D3-06 | 複数項目の統合は各行/セルから元IDへ追跡可能な場合だけ許可し、異なる条件・例外を丸めない | owner=Task D
D3-07 | 図は正本に明示されたcomponent、関係、状態、flowだけを描く。配置・色は変更可だが新しい箱・矢印・依存を追加しない | owner=Task D
D3-08 | 意味を維持して収められない場合はslide分割、appendix、正本参照を使い、黙って短縮しない | owner=Task D
D3-09 | 正本にない判断が必要なら生成上の推論で補わず、人間判断へ戻す | owner=Task D

## ADOPTED — D-4 出典・鮮度・網羅性

D4-01 | artifactごとにspec ID、phase/profile、source path、source file content hash、対象version/gate hash、generator version、template ID/version、生成日時を記録する | owner=Task D
D4-02 | 掲載、意図的省略、変換失敗、source不在、未確認の正本ID/見出しを区別してreportする | owner=Task D
D4-03 | 各主要slideに人が読める正本IDまたはfile#headingを示し、詳細なslide-source mappingを生成reportへ残す | owner=Task D
D4-04 | 生成時、review開始時、D-1の正本承認遷移時にsource hashを再確認する | owner=Task D/E/F
D4-05 | source fileのどれかが変われば原則PPT全体をSTALEとする。「無関係な変更」と自動推定してfresh扱いしない | 非意味変更最適化はDesign保留 | owner=Task D
D4-06 | GENERATED / PARTIAL / CURRENT / STALE / REVIEW_READYを区別し、生成済みやCURRENT単独をREVIEW_READYとしない | owner=Task D
D4-07 | 外部共有等で再確認不能なPPTは生成時hashに対する派生物と表示し、現在の承認資料とは保証しない | owner=Task D
D4-08 | 意図的省略は許可するが、条件・例外・禁止・risk・未決は詳細を省略しても存在と正本参照先が主要部分から分かるようにする | owner=Task D

## ADOPTED — D-5 template / override / license

D5-01 | SDD Rigはversion管理された既定PPT templateを提供し、利用project所有のtemplate overrideを許可する | owner=Task D
D5-02 | template選択優先順位は 実行時明示指定 > project override > SDD Rig既定template | owner=Task D
D5-03 | phase profileが管理する必須意味要素と、visual template/themeが管理する見た目を分離する | owner=Task D
D5-04 | overrideはbrand、logo、色、font、layoutを変更できるが、承認境界、source mapping、鮮度、条件・例外・risk・未決等の必須意味要素を削除できない | owner=Task D
D5-05 | 利用者所有overrideをinstall/sync/updateで上書き、削除、再生成、自動変換しない | owner=Task D + Task B contract維持
D5-06 | override非互換時は黙って既定templateへfallbackせず、差分・不足を示して人間判断へ戻す | owner=Task D
D5-07 | 既定templateは日本語/CJK、font fallback、長い表・図・risk・例外の可読性、D-1/D-4表示領域を支援する | owner=Task D
D5-08 | 外部template/font/icon/rendererは固定参照、license、商用利用・改変・再配布、attribution、supplier、再現性、更新責任、Claude/Codex parityを確認して別途採否判断する | owner=Task B contract + Design
D5-09 | 具体的な外部package/template採用やcc-sdd由来asset同梱は本合意に含まない。cc-sdd由来物を同梱する提案時はMIT LICENSE全文とCopyright (c) 2025 gotalabの保持・到達性を再確認する | owner=Task B/license gate

## ADOPTED — D-6 品質と失敗判定

D6-01 | renderer processの終了成功だけを品質合格にしない | owner=Task D
D6-02 | 毎回、artifact構造、必須XML、非0 slide、全slide render、asset/relationship/internal reference、source mapping、profile coverage、source freshness、未掲載/失敗count、placeholder、overflow、重なり、極小font、CJK glyph/文字化け、contrastを自動検査する | exact tool/thresholdはDesign保留 | owner=Task D
D6-03 | formal gateの理解にPPTを使用する場合、実際にrenderされた全slideの人間visual QAを必須とする | owner=Task D、人間
D6-04 | visual QAはoverflow、文字切れ、重なり、日本語可読性、表/図、contrast、条件・例外・risk・未決の埋没、図の確定/未決誤表示、正本案内、warning可視性を確認する | owner=人間
D6-05 | 参考共有ではAUTO_PASSかつvisual未確認を明示したartifactを渡せるがREVIEW_READY・品質保証済みとは呼ばない | owner=Task D
D6-06 | GENERATED → AUTO_PASS/AUTO_WARN/AUTO_FAIL → VISUAL_REQUIRED → VISUAL_PASS/VISUAL_FAIL → REVIEW_READYを意味上区別する | schemaはDesign保留 | owner=Task D
D6-07 | AUTO_FAIL、未解消AUTO_WARN、VISUAL_FAIL、STALE、UNVERIFIEDを成功扱いしない | owner=Task D
D6-08 | renderer未導入の対象artifactはNOT_GENERATED。他artifactは続行可だがcommand完了を全artifact成功と表現しない | owner=Task D
D6-09 | visual QAは正本の意味同等性確認や正式approvalの代替ではない | owner=Task D
D6-10 | Claude/Codexで同じartifact status、blocking条件、report項目を使い、片側で検証不能なら推測PASSにしない | owner=#32 / Task F

## ADOPTED — D-7 保存・起動・費用・owner

D7-01 | Claude Codeの明示skill、Codexの明示skill、両者の自然言語、直接CLIから同じ意味で起動可能とする | 具体syntax/discovery/E2Eは#32 | owner=Task D/#32
D7-02 | 生成は明示依頼後に行い、spec、phase、profile、format、機密区分が一意でなければ確認する | owner=Task D/E
D7-03 | 生成前に対象、artifact数、AI要約/図表化、必要renderer、visual QA、中間data再取得、Token/時間/外部処理の見積区分、保存しない場合の再現性riskを提示する | owner=Task D、閾値/agent budget=Task E
D7-04 | Token等を取得不能ならUNAVAILABLEとし、0扱いしない | owner=Task D/E
D7-05 | 二次成果物は既定で再生成可能かつgitignore対象のbuild output。外部Drive等を必須化しない | owner=Task D/#37
D7-06 | 外部upload、Git stage/commit/push、外部archive、dependency導入を生成処理から自動実行しない | owner=Task D/#37/Task B
D7-07 | PII・機密・大容量を通常の非PII出力先へ混在させず、永続reportへlocal user名を含む絶対pathを残さない | owner=Task D/#37/Task F
D7-08 | 既存artifactや利用者所有fileを黙って上書きしない | owner=Task D/Task F
D7-09 | output ownership、同一spec並行生成、atomic publish、PII隔離、worktree削除後の発見性、main worktree mutation preflightをTask Fで確定する。安全に解決不能なら黙ってfallbackせずBLOCKED | owner=Task F
D7-10 | #37のlinked worktree→main worktree outputs案は候補として維持するが、Task Fのownership/lease/preflight/recovery contract確定前には有効化しない | owner=Task F/#37
D7-11 | exact source hash/profile/template/generator versionが一致し検証済みのartifactは再利用提案可。ただしhash再確認を省略しない | caching/lifecycle=Task F
D7-12 | 大容量PDF、全slide画像、render logを会話へ無制限に投入しない。manifest、検査結果、縮小contact sheetを優先し問題slideだけ詳細確認する | owner=Task D/E
D7-13 | export中に不足rendererを黙ってinstallしない。別setupとして目的、version/pin、license、supplier、影響、更新責任を示し、人間承認後だけ実施する | owner=Task B/Design
D7-14 | 保存済み中間dataがなければ再取得費用と非再現性を通知し、人間確認後に再生成へ進む。外部storage連携は必須にしない | owner=#37
D7-15 | bash 3.2、CJK/PDF renderer既知不具合を修正済みと仮定せず、#38へ渡す | owner=#38
D7-16 | skill detection、明示/自然言語起動、fresh-session parityは#32。agent/model/context予算はTask E。workspace/output/lock/recoveryはTask F | owner=各記載先

## REJECTED / NOT ADOPTED

RD-01 | PPT単独または完全snapshot化PPTを正式approvalの新正本にする | REJECTED | 理由=Task C #98/#101と衝突、二重権威
RD-02 | gateごとに無条件でPPT自動生成 | REJECTED | 理由=費用、stale、不要artifact
RD-03 | AIの自由なpresentation生成、新規関係/判断の補完 | REJECTED | 理由=意味変化と追跡不能
RD-04 | cover pageの日時/pathだけで鮮度・網羅性を証明 | REJECTED | 理由=content change判定不能
RD-05 | 正本全文をPPTへ複製して網羅性を満たす | REJECTED | 理由=二重正本、容量、Token
RD-06 | override不具合時のsilent fallback | REJECTED | 理由=brand/必須情報の誤認
RD-07 | 外部templateを実行時に自動検索・取得 | REJECTED | 理由=license/supply-chain/reproducibility
RD-08 | renderer exit 0だけで品質PASS | REJECTED | 理由=visual/semantic欠陥を検出不能
RD-09 | 全artifactを自動検査なしで人間だけに丸投げ | REJECTED | 理由=負荷と再現性
RD-10 | main worktreeへの無条件出力、unsafe fallback | REJECTED | 理由=ownership/並行/PII/worktree lifecycle未解決
RD-11 | export中の無承認dependency/global install | REJECTED | 理由=dependency contract違反
RD-12 | 外部Drive保存、Git操作を完了条件または自動処理にする | REJECTED | 理由=#37合意と非破壊性に反する

## 既存Decisionとの関係

- MAINTAIN: #69 doc-exportをSDD Rig固有skillとしてClaude/Codex parity保証
- MAINTAIN: #71/#111 既存品質維持、品質衝突時は影響・代替・回帰testを示して人間判断
- MAINTAIN: #84〜#92/#113〜#116 dependency、license、利用者所有override、無断dependency禁止
- MAINTAIN: #93〜#97 大容量出力をcontextへ無制限投入しない、取得不能値を0扱いしない
- MAINTAIN: #98〜#100 一情報一正本、stable ID、意味/hash変更時stale
- MAINTAIN: #101 正本直接確認と自然言語approval成立条件
- MAINTAIN: #103 日本語でも主体・条件・例外・原文・検証可能性を保持
- MAINTAIN: #117〜#119 原子的handoff、転記完全性確認、CANONICALIZATION_PASSまでfail-closed
- NO REVISION: Task A〜C Decisionを改訂しない。衝突が見つかった場合は自動上書きせず人間へ戻す。

## Requirements候補

RQ-D-01 正本/PPT/approvalの権威境界と二段階遷移
RQ-D-02 明示依頼、既定PPT、phase profile選択、ambiguity fail-closed
RQ-D-03 制約付き意味変換と禁止された推論
RQ-D-04 source manifest、slide mapping、coverage、freshness/status contract
RQ-D-05 versioned default template、non-destructive project override、license gate
RQ-D-06 automated quality + formal-review human visual QA + fail-closed status
RQ-D-07 multi-entrypoint semantic parity、preflight cost、safe output/storage boundary
RQ-D-08 Claude/Codex fresh-session detection/launch/meaning parity
RQ-D-09 PII、optional storage、large-context制約
RQ-D-10 canonicalization verificationが完了するまでTask Dを完了扱いしない

## Design保留

DD-01 profile schemaと各profileの必須slot/slide構成
DD-02 manifest/mapping/status schema、hash algorithm、保存形式
DD-03 template file形式、配置path、override指定方式、compatibility range
DD-04 具体的なrenderer/package/template、pin/lock、license、build/配布方式
DD-05 overflow/font/CJK/contrast/semantic coverage検査toolと閾値
DD-06 visual QAのUI、記録schema、警告override可能範囲
DD-07 artifact naming/versioning、atomic publish、cache、retention
DD-08 cost見積区分とDEEP/agent budget接続
DD-09 platform adapterと自然言語dispatch
DD-10 Task F output resolver、workspace lease/lock/recovery

## 未決調査・既知差分

INV-D-01 現行はmanifest不在時にrequirements/design/tasks全文を各DOCXへ生成。新既定PPT/profileへのmigrationと互換性を調査
INV-D-02 現行配布物にPPTX/POTX既定templateなし
INV-D-03 現行reportにsource hash、slide mapping、stale/coverage/REVIEW_READY判定なし
INV-D-04 現行品質検査はrenderer availability/exit、source/heading、Mermaid未変換数中心でvisual QAなし
INV-D-05 現行exportには対話時にinstall-renderersを試す経路があり、無承認dependency変更を排除する必要
INV-D-06 #38 bash 3.2変数展開、CJK/PDF engine/font問題はOPENで未修正前提
INV-D-07 #37 main worktree output案とTask F session workspace ownership/isolationの整合
INV-D-08 #37 Issue内の旧path/designは未承認またはstale部分があり、そのまま実装入力にしない
INV-D-09 Issue #41冒頭進捗表示とTask D packet baselineの不一致を正本化時に解消
INV-D-10 外部template/font/icon/rendererのlicense、再配布、supplier、offline再現性
INV-D-11 sourceの「非意味変更」時だけ部分freshを許せるか。現段階はfile hash変更で全体STALE
INV-D-12 formal gateでの人間visual QA負荷と軽量化目標の実測

## canonicalization返信の必須内容

正本反映後、このTask D sessionへ以下を返してください。
1. 対象version/hash
2. handoff IDごとの ADOPTED:<Decision ID> / DEFERRED:<owner・gate> / REJECTED:<理由> / BLOCKED:<原因>
3. 反映した正本文または差分
4. 統合・言換え・保留・未反映一覧
5. Requirements候補、Design保留、未決調査の反映先
6. 主体、規範強度、条件、例外、否定、固定値、owner、未決状態が保持されたことを再構成できる情報

このsessionは返信を元handoffと項目別に照合し、CANONICALIZATION_PASSまたはCANONICALIZATION_REVISEを返すまで存続します。これは転記完全性確認であり、fresh独立reviewや人間approvalの代替ではありません。
