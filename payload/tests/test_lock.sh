DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/../scripts/sync_lib/hash.sh"
source "$DIR/../scripts/sync_lib/lock.sh"

TMP="$(mktemp -d)"
LOCK="$TMP/sdd-base.lock"

sdd_lock_set_meta "$LOCK" template_commit "abc123"
sdd_lock_set_meta "$LOCK" template_repo "git@github.com:org/repo.git"
sdd_lock_set_file "$LOCK" "docs/sdd/workflow.md" "hash1"
sdd_lock_set_block "$LOCK" "CLAUDE.md" "SDD-BASE" "hash2"

assert_eq "abc123" "$(sdd_lock_get_meta "$LOCK" template_commit)" "meta template_commit 往復一致"
assert_eq "git@github.com:org/repo.git" "$(sdd_lock_get_meta "$LOCK" template_repo)" "meta template_repo 往復一致"
assert_eq "hash1" "$(sdd_lock_get_file "$LOCK" "docs/sdd/workflow.md")" "file ハッシュ往復一致"
assert_eq "hash2" "$(sdd_lock_get_block "$LOCK" "CLAUDE.md" "SDD-BASE")" "block ハッシュ往復一致"

# 冪等上書き（重複行にならない）
sdd_lock_set_file "$LOCK" "docs/sdd/workflow.md" "hash1-updated"
assert_eq "hash1-updated" "$(sdd_lock_get_file "$LOCK" "docs/sdd/workflow.md")" "file ハッシュが上書きされる"
cnt="$(grep -cF "file:docs/sdd/workflow.md:" "$LOCK")"
assert_eq "1" "$cnt" "上書き後も file: 行が重複しない"

sdd_lock_set_block "$LOCK" "CLAUDE.md" "SDD-BASE" "hash2-updated"
assert_eq "hash2-updated" "$(sdd_lock_get_block "$LOCK" "CLAUDE.md" "SDD-BASE")" "block ハッシュが上書きされる"
cnt2="$(grep -cF "block:CLAUDE.md:SDD-BASE:" "$LOCK")"
assert_eq "1" "$cnt2" "上書き後も block: 行が重複しない"

# 存在しない key/file/block は空を返す
assert_eq "" "$(sdd_lock_get_meta "$LOCK" no_such_key)" "未設定のmetaは空"
assert_eq "" "$(sdd_lock_get_file "$LOCK" "no/such/file.md")" "未設定のfileは空"

# git リポジトリでない場所での commit 解決（フォールバック）
NOTGIT="$(mktemp -d)"
commit="$(sdd_lock_resolve_commit "$NOTGIT")"
assert_true "[ -n \"$commit\" ]" "git不在でも commit 解決結果は非空（フォールバック）"
rm -rf "$NOTGIT"

rm -rf "$TMP"
