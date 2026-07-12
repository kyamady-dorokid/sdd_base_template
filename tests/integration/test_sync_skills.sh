DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SH="$DIR/../../payload/scripts/sync.sh"

TMP="$(mktemp -d)"
ROOT="$TMP/repo"
PAYLOAD="$TMP/payload"
mkdir -p "$ROOT" "$PAYLOAD/overlay/docs/sdd" "$PAYLOAD/overlay/skills/doc-export" "$PAYLOAD/validation/patches"
( cd "$ROOT" && git init -q )
echo "workflow v1" > "$PAYLOAD/overlay/docs/sdd/workflow.md"
echo "doc-export skill v1" > "$PAYLOAD/overlay/skills/doc-export/SKILL.md"

# init 済み想定: 両エージェントに doc-export スキルが v1 で設置済み
for a in .claude .agents; do
  mkdir -p "$ROOT/$a/skills/doc-export"
  echo "doc-export skill v1" > "$ROOT/$a/skills/doc-export/SKILL.md"
done

# 1回目 sync（初回化）: 基準点記録のみ・既存無変更
bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/s1.log" 2>&1
assert_eq "doc-export skill v1" "$(cat "$ROOT/.claude/skills/doc-export/SKILL.md")" "初回化ではスキルを変更しない"

# 上流スキルを更新 → 2回目 sync（ローカル未変更なので新版がそのまま反映）
echo "doc-export skill v2" > "$PAYLOAD/overlay/skills/doc-export/SKILL.md"
bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/s2.log" 2>&1
assert_eq "doc-export skill v2" "$(cat "$ROOT/.claude/skills/doc-export/SKILL.md")" ".claude 側が新版に更新される"
assert_eq "doc-export skill v2" "$(cat "$ROOT/.agents/skills/doc-export/SKILL.md")" ".agents 側が新版に更新される"

# ローカル変更 + 上流変更（コンフリクト）→ サイレント上書きせず <file>.new
echo "doc-export LOCAL edit" > "$ROOT/.claude/skills/doc-export/SKILL.md"
echo "doc-export skill v3 UPSTREAM" > "$PAYLOAD/overlay/skills/doc-export/SKILL.md"
bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/s3.log" 2>&1
assert_eq "doc-export LOCAL edit" "$(cat "$ROOT/.claude/skills/doc-export/SKILL.md")" "コンフリクト時にローカルを無変更のまま保つ"
assert_file_exists "$ROOT/.claude/skills/doc-export/SKILL.md.new" "コンフリクト時は <file>.new を出力"

rm -rf "$TMP"
