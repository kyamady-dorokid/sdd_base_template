DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SH="$DIR/../../payload/scripts/sync.sh"
REAL_PAYLOAD="$DIR/../../payload"

TMP="$(mktemp -d)"
ROOT="$TMP/repo"
PAYLOAD="$TMP/payload"
mkdir -p "$ROOT" "$PAYLOAD/overlay/docs/sdd" "$PAYLOAD/overlay/snippets"
cp -R "$REAL_PAYLOAD/validation" "$PAYLOAD/validation"

( cd "$ROOT" && git init -q )
echo "workflow v1" > "$PAYLOAD/overlay/docs/sdd/workflow.md"

# init 済みだが、init.sh 側に ensure-agreement-log.sh のような新設パッチが
# 追加された「後」に一度も init/sync を再実行していない状態を再現する
# （マーカー未挿入の既存 SKILL.md）。
mkdir -p "$ROOT/.claude/skills/kiro-spec-init" "$ROOT/.agents/skills/kiro-spec-init"
cat > "$ROOT/.claude/skills/kiro-spec-init/SKILL.md" <<'EOS'
# kiro-spec-init（既存本文。新設パッチはまだ未適用）
EOS
cp "$ROOT/.claude/skills/kiro-spec-init/SKILL.md" "$ROOT/.agents/skills/kiro-spec-init/SKILL.md"

MARKER="SDD-OVERLAY:ENSURE-AGREEMENT-LOG"
TARGET="$ROOT/.claude/skills/kiro-spec-init/SKILL.md"

assert_true "! grep -q '$MARKER' '$TARGET'" "適用前はマーカーが存在しない（未適用パッチの前提）"

# 1回目 sync（初回化）: マーカーが無いブロックは記録されず、既存ファイルも変更されない。
bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/sync1.log" 2>&1
assert_true "! grep -q '$MARKER' '$TARGET'" "初回化ではまだパッチが適用されない（既存動作を壊さない）"

# 2回目 sync（差分適用）: 本修正により、未適用の patch 型ブロックは
# 対応するパッチスクリプトがそのまま実行され、新規適用される。
bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/sync2.log" 2>&1

assert_true "grep -q '$MARKER' '$TARGET'" "2回目の sync で未適用パッチが新規適用される（回帰テスト）"
assert_contains "$TARGET" "既存本文" "パッチ適用前の既存本文は維持される（冪等追記のみ）"
assert_contains "$ROOT/.kiro/sdd-base-update-report.md" "未適用パッチを新規適用" "レポートに新規パッチ適用の旨が記載される"

rm -rf "$TMP"
