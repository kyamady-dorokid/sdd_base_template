#!/usr/bin/env node
/*
 * sdd-base CLI — SDDベース構築の配布・実行ツール。
 * サブコマンド:
 *   install [--link|--copy]  個人スキルdir(~/.claude/skills, ~/.codex/skills)へ sdd-init を設置
 *   init [--lang ja] [--yes] [--on-existing keep|overwrite|compare]
 *                            現在のリポジトリに SDD ベースを展開（cc-sdd取得→検証→overlay→再検証）
 *   validate [pre|post]      検証のみ実行
 *   update                   clone元なら git pull（symlink運用の更新）
 *   help
 */
"use strict";
const { spawnSync } = require("child_process");
const fs = require("fs");
const path = require("path");
const os = require("os");

const PKG_ROOT = path.resolve(__dirname, "..");
const PAYLOAD = path.join(PKG_ROOT, "payload");
const SKILL_SRC = path.join(PKG_ROOT, "skills", "sdd-init");
const HOME = os.homedir();
const SKILL_TARGETS = [
  path.join(HOME, ".claude", "skills", "sdd-init"),
  path.join(HOME, ".codex", "skills", "sdd-init"),
];

function sh(cmd, args, opts = {}) {
  return spawnSync(cmd, args, { stdio: "inherit", ...opts });
}
function rmrf(p) { fs.rmSync(p, { recursive: true, force: true }); }
function copyDir(src, dst) { fs.cpSync(src, dst, { recursive: true }); }

// インストール用の自己完結スキルdirを組み立てる（SKILL.md + payload同梱）
function buildSkillBundle(stageDir) {
  rmrf(stageDir);
  fs.mkdirSync(stageDir, { recursive: true });
  copyDir(SKILL_SRC, stageDir);                 // SKILL.md など
  copyDir(PAYLOAD, path.join(stageDir, "payload")); // overlay/validation/scripts/KNOWN_GOOD...
}

function install(mode) {
  const link = mode === "--link";
  if (link) {
    // symlink運用: clone元の skills/sdd-init を指す（payloadはスキル内から ../../payload を解決）
    // 自己完結のため payload も clone元を参照させる: スキルdir自体をsymlink
    for (const t of SKILL_TARGETS) {
      fs.mkdirSync(path.dirname(t), { recursive: true });
      rmrf(t);
      // SKILL.md は clone を指し、payload も clone の payload を symlink
      fs.symlinkSync(SKILL_SRC, t, "dir");
      console.log(`[link] ${t} -> ${SKILL_SRC}`);
    }
    console.log("symlink設置完了。'git pull' で全環境に即反映されます。");
    console.log("注意: --link は clone したリポジトリから実行してください（npx一時キャッシュ不可）。");
    return;
  }
  // copy運用（npxワンライナー既定）: 自己完結バンドルを各dirへコピー
  const stage = path.join(os.tmpdir(), "sdd-init-bundle-" + process.pid);
  buildSkillBundle(stage);
  for (const t of SKILL_TARGETS) {
    fs.mkdirSync(path.dirname(t), { recursive: true });
    rmrf(t);
    copyDir(stage, t);
    console.log(`[copy] ${t}`);
  }
  rmrf(stage);
  console.log("コピー設置完了。更新は 'npx github:<org>/sdd_base_template install' を再実行してください。");
}

function init(args) {
  const root = process.cwd();
  const r = sh("bash", [path.join(PAYLOAD, "scripts", "init.sh"), root, PAYLOAD, ...args]);
  process.exit(r.status || 0);
}
function validate(args) {
  const root = process.cwd();
  const phase = args[0] || "pre";
  const r = sh("bash", [path.join(PAYLOAD, "scripts", "validate.sh"), root, PAYLOAD, phase]);
  process.exit(r.status || 0);
}
function update() {
  // clone元（PKG_ROOT が git 管理下）なら pull
  const g = sh("git", ["-C", PKG_ROOT, "pull", "--ff-only"]);
  process.exit(g.status || 0);
}
function help() {
  console.log(`sdd-base — SDDベース構築ツール (内部で cc-sdd[MIT, (c)2025 gotalab] を利用)

使い方:
  npx github:<org>/sdd_base_template install [--copy|--link]   個人環境へ sdd-init スキルを設置
  npx github:<org>/sdd_base_template init [--lang ja] [--yes] [--on-existing keep|overwrite|compare]
                                                              現リポジトリに SDD ベースを展開
                                                              （既存 CLAUDE.md/AGENTS.md 等があれば扱いを選択。既定 overwrite=対比して上書き・バックアップ取得）
  npx github:<org>/sdd_base_template validate [pre|post]       検証のみ
  npx github:<org>/sdd_base_template update                    （clone運用）git pull
`);
}

const [cmd, ...rest] = process.argv.slice(2);
switch (cmd) {
  case "install": install(rest.find(a => a === "--link") || "--copy"); break;
  case "init": init(rest); break;
  case "validate": validate(rest); break;
  case "update": update(); break;
  case undefined:
  case "help":
  case "-h":
  case "--help": help(); break;
  default: console.error("unknown command: " + cmd); help(); process.exit(1);
}
