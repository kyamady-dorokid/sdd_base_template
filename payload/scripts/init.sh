#!/usr/bin/env bash
# SDD base 初期化（cc-sdd 取得 → 検証 → overlay → 再検証）。冪等。
# 使い方: init.sh <repo_root> <payload_dir> [--lang ja] [--yes] [--on-existing keep|overwrite|compare]
set -uo pipefail
ROOT="${1:?repo_root required}"; PAYLOAD="${2:?payload_dir required}"; shift 2 || true
LANG_OPT="ja"; ASSUME_YES=0; ON_EXISTING=""
while [ $# -gt 0 ]; do case "$1" in
  --lang) LANG_OPT="$2"; shift 2;;
  --yes|-y) ASSUME_YES=1; shift;;
  --on-existing) ON_EXISTING="$2"; shift 2;;
  --on-existing=*) ON_EXISTING="${1#*=}"; shift;;
  *) shift;;
esac; done
cd "$ROOT" || exit 1
say(){ printf '\n\033[1m%s\033[0m\n' "$*"; }

say "[1/6] 前提チェック"
command -v node >/dev/null || { echo "node が必要です"; exit 1; }
command -v npx  >/dev/null || { echo "npx が必要です"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "git リポジトリではありません。先に 'git init' してください。"; exit 1; }

# --- 既存エージェント環境（上書き対象）の検出と扱いの決定 ---
# 上書きされ得る再生成可能な足場のみを検出対象とする。
EXISTING=""
for p in CLAUDE.md AGENTS.md .claude/skills .agents/skills .kiro/settings; do
  [ -e "$ROOT/$p" ] && EXISTING="$EXISTING $p"
done
# 保護対象（どのモードでも初期化しない＝ユーザーの仕様・記録・プロジェクトメモリ）
PROTECTED=""
for p in .kiro/specs .kiro/steering; do
  if [ -d "$ROOT/$p" ] && [ -n "$(ls -A "$ROOT/$p" 2>/dev/null | grep -v '^\.gitkeep$' || true)" ]; then
    PROTECTED="$PROTECTED $p"
  fi
done

if [ -n "$EXISTING" ]; then
  echo "  既存のエージェント環境（上書き対象）を検出:$EXISTING"
  [ -n "$PROTECTED" ] && echo "  ※ 保護対象（初期化しません）:$PROTECTED"
  # 既存が見つかった場合は、明示指定が無ければ「黙って進めない」。
  #  - 端末（/dev/tty）が使えるなら必ず選択肢を提示（既定=overwrite）。
  #  - 端末が無い非対話（CI/エージェント/-y）で未指定なら、停止して明示を促す。
  if [ -z "$ON_EXISTING" ]; then
    # 対話可否は /dev/tty を実際に open できるかで判定（モードビットの -r だけでは CI 等で誤判定するため）。
    TTY_OK=0
    if [ "$ASSUME_YES" = 0 ] && { exec 3</dev/tty; } 2>/dev/null; then TTY_OK=1; fi
    if [ "$TTY_OK" = 1 ]; then
      echo "  既存設定と新規設定が衝突する可能性があります。扱いを選択してください:"
      echo "    [o] overwrite … バックアップ後に上書きし、差分を表示（既定・推奨）"
      echo "    [k] keep      … 既存を温存（マージ）。衝突に注意"
      echo "    [c] compare   … 差分の表示のみ（インストールしない）"
      printf "  選択 [O/k/c] (既定 O): "
      read -r ans <&3 || ans=""
      exec 3<&- 2>/dev/null || true
      case "$ans" in k|K|keep) ON_EXISTING="keep";; c|C|compare) ON_EXISTING="compare";; *) ON_EXISTING="overwrite";; esac
    else
      echo "  [停止] 既存のエージェント環境を検出しましたが、非対話で扱いが未指定です。"
      echo "         自動では進めません。次のいずれかで扱いを明示して再実行してください:"
      echo "           --on-existing=overwrite  （対比して上書き・バックアップ取得）"
      echo "           --on-existing=keep       （既存を温存・マージ）"
      echo "           --on-existing=compare    （差分の表示のみ・インストールしない）"
      echo "         または端末（対話可能なシェル）で実行してください。"
      exit 3
    fi
  fi
else
  # 既存なし＝上書き対象が無い。生成のみ（バックアップ不要）。内部的には keep 相当で扱う。
  ON_EXISTING="keep"
fi
case "$ON_EXISTING" in
  keep|overwrite|compare) ;;
  *) echo "  [停止] 不明な --on-existing='$ON_EXISTING'。keep|overwrite|compare のいずれかを指定してください。"; exit 3;;
esac
[ -n "$EXISTING" ] && echo "  既存ファイルの扱い: $ON_EXISTING"

# モード→cc-sdd フラグへ写像
#  keep    : フラグ無し＋stdin非TTY（</dev/null）＝既存温存・不足分のみ生成（cc-sdd既定の非対話挙動）
#            ※ cc-sdd の --overwrite=skip は「全ファイル skip（生成しない）」なので keep には使わない
#  overwrite: --overwrite=force --backup=DIR（バックアップ後に全上書き）
#  compare : 実ツリーは keep と同じ（非破壊）。別途 temp に生成して新旧 diff を提示
CC_FLAGS=(); BACKUP_DIR=""; MODE_LABEL="keep(既存温存・不足分のみ生成)"
if [ "$ON_EXISTING" = "overwrite" ]; then
  BACKUP_DIR=".sdd-backup/$(date +%Y%m%d-%H%M%S)"
  CC_FLAGS=(--overwrite=force --backup="$BACKUP_DIR")
  MODE_LABEL="overwrite(force+backup)"
fi

say "[2/6] cc-sdd を取得・適用（Claude Code + Codex の両方）"
echo "  - Claude Code 用 (.claude/skills, CLAUDE.md)  [$MODE_LABEL]"
npx -y cc-sdd@latest --claude-code-skills --lang "$LANG_OPT" ${CC_FLAGS[@]+"${CC_FLAGS[@]}"} </dev/null || { echo "cc-sdd(Claude) 実行に失敗しました"; exit 1; }
echo "  - Codex 用 (.agents/skills, AGENTS.md)  [$MODE_LABEL]"
npx -y cc-sdd@latest --codex-skills --lang "$LANG_OPT" ${CC_FLAGS[@]+"${CC_FLAGS[@]}"} </dev/null || { echo "cc-sdd(Codex) 実行に失敗しました"; exit 1; }

# overwrite モード: 「対比して上書き」。バックアップ(旧)と上書き後(新)の差分を提示。
if [ "$ON_EXISTING" = "overwrite" ] && [ -n "$BACKUP_DIR" ] && [ -d "$ROOT/$BACKUP_DIR" ]; then
  echo "  バックアップ: $BACKUP_DIR （上書き前の旧ファイルを保存）"
  say "[2.5] overwrite: 上書き前(旧) ↔ 上書き後(新) の差分（対比）"
  for f in CLAUDE.md AGENTS.md; do
    if [ -f "$ROOT/$BACKUP_DIR/$f" ] && [ -f "$ROOT/$f" ]; then
      echo "  --- diff: $f （< 旧 / > 新） ---"
      diff "$ROOT/$BACKUP_DIR/$f" "$ROOT/$f" || true
    fi
  done
  echo "  ※ 旧ファイルは $BACKUP_DIR に保持。固有の追記があれば手動で取り込んでください。"
fi

# compare モード: 既存を上書きせず、cc-sdd が書くであろう新版を temp に生成して新旧 diff を提示
if [ "$ON_EXISTING" = "compare" ]; then
  say "[2.5] compare: 既存（温存）と cc-sdd 新版の差分を提示（上書きはしません）"
  TMPC="$(mktemp -d)"
  ( cd "$TMPC" && git init -q \
    && npx -y cc-sdd@latest --claude-code-skills --lang "$LANG_OPT" --overwrite=force </dev/null >/dev/null 2>&1 \
    && npx -y cc-sdd@latest --codex-skills --lang "$LANG_OPT" --overwrite=force </dev/null >/dev/null 2>&1 ) || true
  for f in CLAUDE.md AGENTS.md; do
    if [ -f "$ROOT/$f" ] && [ -f "$TMPC/$f" ]; then
      if diff -q "$ROOT/$f" "$TMPC/$f" >/dev/null 2>&1; then
        echo "  $f: 既存と新版に差分なし"
      else
        echo "  --- diff: $f （< 既存 / > cc-sdd新版） ---"
        diff "$ROOT/$f" "$TMPC/$f" || true
      fi
    fi
  done
  rm -rf "$TMPC"
  echo "  ※ 既存ファイルは変更していません。必要箇所のみ手動で取り込んでください。"
fi

say "[3/6] 検証(pre): 構造・パリティ・Codexパス・バージョン"
bash "$PAYLOAD/scripts/validate.sh" "$ROOT" "$PAYLOAD" pre
PRE=$?

say "[4/6] 既知パッチ適用（あれば）"
shopt -s nullglob 2>/dev/null || true
applied=0
for p in "$PAYLOAD"/validation/patches/*.sh; do
  [ -e "$p" ] || continue
  echo "  patch: $(basename "$p")"; bash "$p" "$ROOT" && applied=1
done
[ "$applied" = 0 ] && echo "  (適用パッチなし)"
if [ "$PRE" -ne 0 ] && [ "$ASSUME_YES" = 0 ]; then
  echo "  ※ 検証(pre)で要確認あり。未知の不整合は人間が確認してください（処理は続行）。"
fi

say "[5/6] overlay 適用（冪等）"
# 5-1: docs/sdd 一式
#   ガードレール: このリポジトリが sync 管理下（.kiro/sdd-base.lock 検出）の場合、
#   init による無条件上書きはローカルカスタマイズを破壊し、かつ lock のハッシュ記録を
#   更新しないため次回 sync が破壊に気づけない。sync 管理下では docs/sdd の上書きをスキップし、
#   更新は sync に委ねる（サイレント上書き厳禁の原則を init 側にも適用）。
if [ -f "$ROOT/.kiro/sdd-base.lock" ]; then
  echo "  docs/sdd/: sync 管理下（.kiro/sdd-base.lock 検出）のため init では上書きしません。"
  echo "    ローカルの変更を保護したまま更新を反映するには 'sync' を使ってください:"
  echo "      npx -y github:kyamady-dorokid/sdd_base_template sync --yes"
else
  mkdir -p "$ROOT/docs/sdd"
  cp -R "$PAYLOAD/overlay/docs/sdd/." "$ROOT/docs/sdd/"
  echo "  docs/sdd/ 展開"
fi
# 5-2: specs 置き場（記録は .kiro/specs/<id>/ に集約。docs/specs は使わない）
mkdir -p "$ROOT/.kiro/specs"
[ -f "$ROOT/.kiro/specs/.gitkeep" ] || touch "$ROOT/.kiro/specs/.gitkeep"
# 5-3: CLAUDE.md / AGENTS.md にマーカー挿入（重複回避）
inject(){ # <target> <snippet> <marker>
  local tgt="$1" snip="$2" marker="$3"
  [ -f "$tgt" ] || : > "$tgt"
  if grep -q "$marker" "$tgt"; then echo "  $(basename "$tgt"): $marker は既存（スキップ）"; return; fi
  { printf '\n'; cat "$snip"; } >> "$tgt"; echo "  $(basename "$tgt"): $marker を追記"
}
inject "$ROOT/CLAUDE.md" "$PAYLOAD/overlay/snippets/CLAUDE.sdd.md"       "SDD-BASE:START"
inject "$ROOT/CLAUDE.md" "$PAYLOAD/overlay/snippets/project-overview.md" "SDD-BASE:PROJECT-OVERVIEW:START"
inject "$ROOT/AGENTS.md" "$PAYLOAD/overlay/snippets/AGENTS.sdd.md"       "SDD-BASE:START"
inject "$ROOT/AGENTS.md" "$PAYLOAD/overlay/snippets/project-overview.md" "SDD-BASE:PROJECT-OVERVIEW:START"
# 5-4: .gitignore 追記
if ! grep -q '\.kiro/specs/\*/outputs/' "$ROOT/.gitignore" 2>/dev/null; then
  { printf '\n'; cat "$PAYLOAD/overlay/gitignore.snippet"; } >> "$ROOT/.gitignore"; echo "  .gitignore 追記"
else echo "  .gitignore は既存（スキップ）"; fi

say "[6/6] 検証(post)"
bash "$PAYLOAD/scripts/validate.sh" "$ROOT" "$PAYLOAD" post || true

say "完了：SDD ベースを展開しました。"
cat <<'EOS'
次の一歩:
  1. Claude Code / Codex を起動し、まず適用ルールと進め方を確認:
       「このリポジトリに適用されているSDDのルールと、これからの開発の進め方を教えて」
  2. CLAUDE.md / AGENTS.md の「## プロジェクト概要（要記入）」を埋める
  3. 開発を始める（2つの入口。どちらでもルール・成果物・出力先は同一。規模で Tier S/L）:
       ・軽量（自然言語SDD）   「<やりたいこと>。簡単な要件定義とプランニングから始めて」
       ・フルフロー（kiroコマンド） /kiro-discovery "<やりたいこと>"
     コミットは区切りで提案（自動コミットしない・main 直禁止・ブランチ→PR）。

  次回から楽にするなら（任意）: 個人環境にスキルを設置しておくと npx 不要になります。
       npx -y github:kyamady-dorokid/sdd_base_template install

  詳しい進め方は docs/sdd/workflow.md を参照。
EOS
