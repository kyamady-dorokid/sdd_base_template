# Task B handoff: cc-sdd source取り込み・provenance・外部source更新境界

> 完了日: 2026-09-06
> 状態: 人間承認済み。orchestratorによるTask A・関連Issue・法的表示・Task Fとのcross-check済み。
> 用語補正: 「一方向fork」は内部architectureを表す。製品表示では
> 「cc-sddをベースに開発した独立製品」を使う。

## 1. 初期source取り込み方針

SDD Rigは、cc-sddを初期実装時の固定参照元とする一方向forkの独立Appとする。
初期実装・比較・隔離検証では、次の固定sourceを直接参照できる。

| 項目 | 固定値 |
|---|---|
| upstream repository | `https://github.com/gotalab/cc-sdd` |
| release / tag | `v3.0.2` |
| commit | `3795eb4274c07dedcf56c571b5c0a826736f23c8` |
| 参照path | `tools/cc-sdd` |
| subtree tree SHA | `14c2cde6a674620c8db41a6cfff85215d75aa618` |

初期実装では`tools/cc-sdd`全体を比較対象にする。一方、V1で製品として保証・配布・検証するplatformは
Claude CodeとCodexに限定し、その他platformを対応済みとは表示しない。

SDD Rigのrelease後は、pristine baseline、vendor snapshot、Git subtree、Git submodule、継続同期機構を
常設しない。SDD Rig repository内のsourceを運用上の正本とし、利用者や通常の開発作業が
cc-sdd sourceを必要としない構造にする。

## 2. 一回限りの初期統合証跡

継続同期用baselineは残さないが、由来を追跡できる一回限りの初期統合証跡は残す。

- upstream URL、tag、commit、参照path、subtree tree SHA
- upstream componentからSDD Rig componentへの簡潔な対応表
- 各componentの`copied / modified / reimplemented / not adopted`分類
- 初期統合時の検証結果
- cc-sddを初期参照元としたことと、将来の外部source取り込みを記録する短い来歴

この証跡は、継続的なupstream差分生成、同期、昇格のためのworking baselineではない。

## 3. architectureと所有権

実装責務は次の5層へ分ける。

| 層 | 所有者・責務 |
|---|---|
| SDD Rig core | SDD Rig本体が所有する共通workflow・policy・state処理 |
| Claude adapter | SDD Rig本体が所有するClaude Code向け起動・配布境界 |
| Codex adapter | SDD Rig本体が所有するCodex向け起動・配布境界 |
| project override | 利用projectが所有する固有設定・追加skill・上書き |
| legacy bridge | 旧入口と新入口を同一stateへ接続する互換層 |

通常のinstall・sync・更新はproject overrideを削除、上書き、再生成しない。
legacy bridgeは、旧資産の開始・再開・完了、同一state、非破壊性、rollback、Claude Code/Codex parityを
E2Eで検証し、人間が廃止を承認するまで維持する。

## 4. license・帰属・配布

永久に保持する最小情報は次のとおりとする。

- cc-sddのMIT LICENSE全文
- `Copyright (c) 2025 gotalab`
- upstream URL、tag、commit、参照path、subtree tree SHA
- SDD Rigが独立製品で、Kiro、AWS、cc-sddの公式・提携・後継ではないこと
- 初期参照元と将来の外部source取り込みを追跡する短い来歴

SDD Rig自身のLICENSEとcc-sddのLICENSEは分離する。cc-sdd由来のcode、template、または
substantial portionsを含むnpm package、release archive、skill bundleには、cc-sddのLICENSE全文と
帰属説明へ到達できる経路を設ける。生成projectへ実際に由来部分を複製する場合も同じとする。

SDD Rigを利用しただけで利用projectのApp全体へMIT licenseが自動伝播するとは扱わない。
実際のcopyまたはsubstantial portionsに当たるか不明な場合は、保守的に帰属を含めるか、専門家判断へ戻す。
NOTICEは製品透明性のcontractとして採用するが、MIT本文がNOTICEというfile名を要求しているとは説明しない。

## 5. build・依存・利用者環境

- SDD Rig sourceを運用上の正本とし、maintainerまたはCIがbuildする。
- packageとskill bundleは、統合済み成果物と必要なLICENSE・NOTICEを含む。
- 利用者のinstall・sync・通常利用で、`npx cc-sdd`、cc-sdd source取得、cc-sdd単体version選択を要求しない。
- 通常dependencyの追加・更新では、目的、runtime/build/dev/native分類、pinとlockfile、license、security、
  supplier、E2E、更新責任を確認する別contractを適用する。
- AIによる無断dependency追加、無承認の自動audit fix、無承認のmajor updateを禁止する。

build tool、source directory、build成果物をcommitするかはDesignで決める。

## 6. 将来の外部source取り込み

cc-sddへの継続追従は行わない。将来、cc-sddその他の外部sourceからcodeやtemplateをコピー・改変して
採用する場合だけ、次の手順を使う。

1. 取り込み候補と目的を提案する。
2. URL、version、commit等の参照元を固定する。
3. 隔離領域でlicense、security、互換性、差分、回帰riskを検証する。
4. 証跡を提示し、人間が採否を判断する。
5. 承認後、SDD Rigの通常SDD工程で独自実装として統合する。
6. 統合releaseのunit、integration、E2E、Claude Code/Codex parityを検証する。
7. 問題時は直前のSDD Rig releaseへrollbackする。

AIは人間承認前に候補取得、隔離検証、報告まで実施できる。採用、製品sourceへの実装、配布は行わない。

## 7. 非破壊install・sync

install、sync、legacy bridgeは、利用者所有資産、未知設定、環境固有設定、追加skill、既存stateを
削除、上書き、再生成しない。管理対象と所有領域を明示し、所有者不明は利用者所有として扱う。

競合、所有者不明、Claude Code/Codex parity未検証の場合は、比較、差分、影響、適用候補を提示し、
人間承認後だけ適用する。承認を得ない場合は既存環境を保持して中断する。未適用、競合、未検証を
完全成功として報告しない。Task Fと#30は、このcontractに沿って`.new`と実行reportの詳細を定義する。

## 8. Issue責務と後続Taskへの制約

| 対象 | 責務・引き継ぐ制約 |
|---|---|
| #41 | Task A〜FのDiscovery Decision、横断制約、依存順の正本 |
| #33 | 必要な場合にTask Bを実装へ落とす唯一の親spec。継続upstream lifecycleではなく初期統合を扱う |
| #34 | #33配下の初期統合作業候補。継続同期toolとはしない |
| #30 / Task F | 統合済みSDD Rig release間の非破壊sync、競合、`.new`、report、rollbackを扱う |
| #32 / Task E | 外部sourceをAIが無断採用しないことと、Claude Code/Codex双方の検出・起動・parityを検証する |
| Task C | 独立・非提携、cc-sdd帰属、license非自動伝播と実コピー時の帰属を製品説明・NOTICEへ反映する |
| Task D | PDF/PPT等の外部package・CLIにもdependency導入contractを適用する |

#33・#34に残る継続cc-sdd追従、版候補の自動検出・昇格、利用者によるcc-sdd version選択の記述は
本Decisionと矛盾するため、実装前に再定義する。

## 9. 未決調査

- build tool、directory、build成果物commit方針
- templateごとのsubstantial portions該当性
- dependency risk閾値と監査tool
- #33、#34、#30、#32の最終優先順位と実装可否
- license範囲が曖昧な実装箇所の専門家確認

これらはTask BのDecisionを妨げない。該当するRequirementsまたはDesignの停止条件として扱う。
