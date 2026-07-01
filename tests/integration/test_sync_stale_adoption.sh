DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SH="$DIR/../../payload/scripts/sync.sh"

TMP="$(mktemp -d)"
ROOT="$TMP/repo"
PAYLOAD="$TMP/payload"
mkdir -p "$ROOT" "$PAYLOAD/overlay/docs/sdd/rules" "$PAYLOAD/overlay/snippets" "$PAYLOAD/validation/patches"

( cd "$ROOT" && git init -q )

# init 済みだが sync 未導入のまま長期間放置され、payload 側だけが更新された状態を再現する。
# ローカル(ROOT)は旧内容のまま、payload は既に新内容になっている。
mkdir -p "$ROOT/docs/sdd/rules"
echo "workflow OLD (never updated locally)" > "$ROOT/docs/sdd/workflow.md"
echo "workflow NEW (payload already updated before first sync)" > "$PAYLOAD/overlay/docs/sdd/workflow.md"

# 1回目 sync（初回化）: ローカルの現状を基準点にするべき（payload の内容を基準にしてはいけない）
bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/sync1.log" 2>&1
assert_eq "workflow OLD (never updated locally)" "$(cat "$ROOT/docs/sdd/workflow.md")" \
  "初回化直後はローカルファイルを変更しない（既存動作）"

# payload はこの間さらに更新されていない（同じ新内容のまま）と仮定し、2回目 sync を実行。
# バグがあると「base(payload新内容) == other(payload新内容)」で無変更判定され、
# ローカルの古い内容が更新されないまま取り残される。
bash "$SYNC_SH" "$ROOT" "$PAYLOAD" --yes > "$TMP/sync2.log" 2>&1

assert_eq "workflow NEW (payload already updated before first sync)" "$(cat "$ROOT/docs/sdd/workflow.md")" \
  "sync導入前から存在した古いローカル内容が、2回目のsyncで新版に更新される（初回化の基準点バグの回帰テスト）"

assert_file_absent "$ROOT/docs/sdd/workflow.md.new" "コンフリクトとして扱われず、クリーンに更新される"

rm -rf "$TMP"
