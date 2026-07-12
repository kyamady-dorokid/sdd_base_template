DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SH="$DIR/../../payload/scripts/sync.sh"

TMP="$(mktemp -d)"
ROOT="$TMP/repo"
PAYLOAD="$TMP/payload"
mkdir -p "$ROOT" "$PAYLOAD/overlay/docs/sdd" "$PAYLOAD/overlay/skills" "$PAYLOAD/validation/patches"
( cd "$ROOT" && git init -q )
echo "workflow" > "$PAYLOAD/overlay/docs/sdd/workflow.md"

# snippet に「部分一致で衝突する2行」を入れる:
#   .kiro/specs/*/outputs/ は outputs/ を部分文字列として含む
cat > "$PAYLOAD/overlay/gitignore.snippet" <<'EOS'
.kiro/specs/*/outputs/
outputs/
tmp/
EOS

# 既存 .gitignore に「先に .kiro/specs/*/outputs/ だけ」がある状態を作る
printf '.kiro/specs/*/outputs/\n' > "$ROOT/.gitignore"

# 初回化 → 差分適用（apply_gitignore は差分適用ルートで走る）
bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/s1.log" 2>&1
bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/s2.log" 2>&1

# 完全一致で outputs/ 行が独立して存在するはず（部分一致による誤スキップが無いこと）
assert_true "grep -qxF 'outputs/' '$ROOT/.gitignore'" "outputs/ が独立行として追記される（部分一致で誤スキップしない）"
assert_true "grep -qxF 'tmp/' '$ROOT/.gitignore'" "tmp/ も追記される"
# .kiro/specs/*/outputs/ は元々あるので重複しない
cnt="$(grep -cxF '.kiro/specs/*/outputs/' "$ROOT/.gitignore")"
assert_eq "1" "$cnt" "既存行は重複追記されない"
# outputs/ も重複しない（再sync しても1つ）
bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/s3.log" 2>&1
cnt2="$(grep -cxF 'outputs/' "$ROOT/.gitignore")"
assert_eq "1" "$cnt2" "再sync で outputs/ が重複しない（冪等）"

rm -rf "$TMP"
