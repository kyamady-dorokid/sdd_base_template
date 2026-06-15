# 既知問題パッチ

cc-sdd の生成物に含まれる**既知の不具合**を `init` 時に自動修正するためのパッチ置き場。

## 背景
cc-sdd は最新版でも、Codex 向け生成物にパス記載の誤り等が混入することがある
（例: `.agents/` 配下のファイルが `.claude/...` を参照してしまう等）。
`validate.sh` がこれらを検出し、ここのパッチを適用する。

## パッチ形式
`*.sh` を置く。各スクリプトは**リポジトリのルートを第1引数**で受け取り、冪等に修正する。
`init` は検出した問題に対応するパッチのみを実行する。

```sh
# 例: fix-codex-claude-paths.sh <repo_root>
# .agents/ 配下の誤った ".claude/" 参照を ".agents/" に置換する
root="$1"
grep -rl '\.claude/' "$root/.agents" 2>/dev/null | while read -r f; do
  # 必要に応じて対象を限定して置換（誤検知を避ける）
  sed -i '' 's#\.claude/skills#.agents/skills#g' "$f"
done
```

## 方針
- パッチは**最小限・限定的**に。誤検知で正常な記述を壊さないこと。
- 新しい cc-sdd バージョンで問題が解消されたら、該当パッチと `KNOWN_GOOD_CCSDD_VERSION` を更新する。
- 未知の不整合（パッチで対応できないもの）は**自動修正せず人間に報告**する。
