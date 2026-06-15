#!/usr/bin/env bash
# clone 運用向けインストーラ。個人環境(~/.claude/skills, ~/.codex/skills)へ sdd-init を設置。
#   ./scripts/install.sh            # コピー設置（既定）
#   ./scripts/install.sh --link     # symlink設置（git pull で自動更新）
set -euo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
node "$DIR/bin/cli.js" install "${1:-}"
