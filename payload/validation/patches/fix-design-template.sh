#!/usr/bin/env bash
# fix-design-template.sh <repo_root>
#
# 技術要件確認(tech-requirements)を design.md に一本化するため、cc-sdd の設計テンプレ
# (.kiro/settings/templates/specs/design.md) 末尾に「技術要件・制約チェック」節を冪等追記する。
#
# design.md は既に Technology Stack / Testing Strategy / Existing Architecture / Modified Files を
# 持ち tech-requirements の大半を内包する。本パッチは欠けている「環境固有制約」と「初回実装時の
# 人間確認フック（承認は spec.json の design ゲートに集約）」だけを補い、独立 tech-requirements.md を不要にする。
#
# 設計方針: 上流ソースは触らず取得済みテンプレに append/marker。手書き/NL 経路は workflow.md の
# 規約で同じ節を要求するため、両入口で design.md の内容が一致する。
set -uo pipefail
ROOT="${1:?repo_root required}"
MARKER="SDD-OVERLAY:DESIGN-TECHREQ"
f="$ROOT/.kiro/settings/templates/specs/design.md"

[ -f "$f" ] || { echo "    (design テンプレが無く、適用なし: $f)"; exit 0; }
if grep -q "$MARKER" "$f" 2>/dev/null; then
  echo "    design.md template: $MARKER 既存（スキップ）"; exit 0
fi

cat >> "$f" <<'EOS'

<!-- SDD-OVERLAY:DESIGN-TECHREQ:START (sdd_base_template が付加。手動編集は再 init で再付与される) -->
## 技術要件・制約チェック（SDD overlay / 初回実装時）

> 旧 `tech-requirements.md` はこの節に統合済み。独立ファイルは作らない。
> 言語/FW/ライブラリは **Technology Stack**、テスト方針は **Testing Strategy**、既存コード結合は
> **Existing Architecture Analysis / Modified Files** に記載する。本節はそれらに収まらない
> 「環境固有の制約」と「初回実装前の確認」だけを補う。

### 環境固有の制約
| 制約 | 内容 |
|---|---|
| 言語ランタイムのバージョン制約 | |
| データストアのバージョン制約 | |
| Docker / 実行環境での考慮事項 | |
| その他 | |

### 初回実装前の確認
- [ ] 上記スタック・テスト方針・既存結合・環境制約を確認した
- [ ] 人間が技術要件を確認した（**承認の記録は `spec.json` の design ゲートに集約。本チェックは二重管理しない**）
<!-- SDD-OVERLAY:DESIGN-TECHREQ:END -->
EOS
echo "    design.md template: $MARKER 追記"
