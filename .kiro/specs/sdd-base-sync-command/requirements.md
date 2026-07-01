# Requirements Document

## Introduction

`sdd_base_template` を適用済み（`init` 済み）のリポジトリに対し、上流テンプレートの更新内容を
安全に反映するコマンド（`sync`）を新設する。現行の `init` は無条件上書き（`--overwrite=force`）
しか持たず、運用中リポジトリで独自にカスタマイズしたファイル（`docs/sdd/**` のローカル追記、
`CLAUDE.md`/`AGENTS.md` のマーカーブロック等）を安全に更新する手段がない。実際に
`cyclox2_docker` で `docs/sdd/workflow.md` の独自ルール節が `init` の無条件上書きにより
消失する事故が発生している（引き継ぎ元: `.kiro/specs/sdd-base-upstream-fix/agreement-log.md`）。

Part A/C（PR #10, マージ済み）で「消えたルールを恒久的に overlay へ反映する」対応は完了した。
本タスク（Part B）は「今後のテンプレ更新そのものを安全に反映する仕組み」を新設する。

## Boundary Context

- **In scope**: 新規 `sync` コマンド（lockファイル・スナップショット・3-wayマージ・コンフリクト時の
  `<file>.new` 出力・差分レポート）。既存 `init`/`validate`/`install`/`update`（テンプレ開発者向け
  `git pull`）は変更しない。
- **Out of scope**: `init` コマンド自体の上書き挙動の変更（既存の `--on-existing keep|overwrite|compare`
  はそのまま）。`cyclox2_docker` 側の `docs/specs/` → `.kiro/specs/` 追随移行（別タスク）。
- **Adjacent expectations**: 既存の overlay 適用ロジック（`payload/scripts/init.sh` [5/6]）や
  パッチ機構（`payload/validation/patches/*.sh`）とマーカー規約（`SDD-BASE:START`/`SDD-OVERLAY:*`）を
  再利用する。新規ファイルフォーマットは既存の bash 完結スタイルと一貫させる。

## Requirements

### Requirement 1: 初回 sync 時の lock・スナップショット作成
**Objective:** As a テンプレ利用者, I want 初回 `sync` 実行時に現在の適用状態を記録してほしい, so that 以降の
差分判定・3-wayマージの基準点（base）を持てる

#### Acceptance Criteria
1. When 対象リポジトリに `.kiro/sdd-base.lock` が存在しない状態で `sync` を実行した場合, the システム shall
   現在の overlay 適用内容から lock ファイルと `.kiro/sdd-base-snapshot/` を新規作成する。
2. The lock ファイル shall 行指向のフラット形式（`key=value` / `file:<path>:<sha256>` /
   `block:<file>:<marker>:<sha256>`）で記述され、JSON パーサに依存しない。
3. The lock ファイル shall `template_commit`（上流テンプレートのコミットSHA）と `template_repo`
   （git remote URL）を記録する。commit SHA が取得できない場合、the システム shall 固定リポジトリURL
   定数へフォールバックし、その旨を人間向けレポートに記載する。
4. When lock・スナップショットを新規作成した場合, the システム shall 自動コミットせず、作成したファイルを
   人間に提示する。

### Requirement 2: 2回目以降の sync（3-wayマージ）
**Objective:** As a テンプレ利用者, I want 上流テンプレートの更新分だけを安全に取り込みたい, so that
自分がカスタマイズしたローカル変更を失わずにテンプレ更新の恩恵を受けられる

#### Acceptance Criteria
1. When lock が存在する状態で `sync` を実行した場合, the システム shall 各管理対象ファイルについて
   ローカルの現在ハッシュと lock 記録時のハッシュを比較する。
2. If ローカルハッシュが lock 記録時のハッシュと一致する（ローカル未変更）, then the システム shall
   新テンプレート版でそのファイルを更新する。
3. If ローカルハッシュが lock 記録時のハッシュと異なる（ローカルで変更されている）, then the システム
   shall `git merge-file`（current=ローカル, base=スナップショット, other=新テンプレート版）による
   3-wayマージを試行する。
4. When 3-wayマージがコンフリクトなく完了した場合, the システム shall マージ結果をそのファイルへ適用し、
   適用した旨を差分レポートに記載する。
5. When 3-wayマージがコンフリクトした場合, the システム shall 既存のローカルファイルを一切変更せず、
   マージ結果（コンフリクトマーカー入り）を `<file>.new` として出力し、コンフリクトレポートに記載する。
6. The システム shall `CLAUDE.md`/`AGENTS.md` の `SDD-BASE:START`〜`END` ブロックと、
   `payload/validation/patches/*.sh` が注入する `SDD-OVERLAY:*` マーカーブロックについて、
   ブロック内容のみを抽出して3-wayマージし、周囲のプロジェクト固有内容には触れない。
7. The システム shall `.gitignore` のテンプレ由来スニペットについて、欠けている行のみを追記する
   （コンフリクト概念を持たない）。
8. While 対象ファイルがテンプレートに存在しないローカル専用ファイル
   （`.kiro/specs/`, `.kiro/steering/`, `docs/architecture/` 等）である場合, the システム shall
   一切変更しない（管理対象外・完全不可侵）。
9. When 上流で削除されたファイルを検出した場合, the システム shall そのファイルを自動削除せず、
   「上流で削除された」旨のみをレポートに記載する。

### Requirement 3: 実行結果の可視化と非破壊性の保証
**Objective:** As a テンプレ利用者, I want sync の実行結果を必ず確認できるようにしたい, so that
意図しない上書きに気づかず進んでしまうことを防げる

#### Acceptance Criteria
1. When `sync` の実行が完了した場合, the システム shall 差分・変更サマリを
   `.kiro/sdd-base-update-report.md` に出力する。
2. The レポート shall 少なくとも「新規適用したファイル」「クリーンマージしたファイル」
   「コンフリクトしたファイル（`<file>.new` の場所）」「上流で削除されたファイル」の4カテゴリを含む。
3. The システム shall いかなるケースにおいても自動コミットしない。
4. The システム shall いかなるケースにおいてもコンフリクト時にローカルファイルをサイレント上書きしない。

### Requirement 4: 既存コマンドとの非衝突・検証統合
**Objective:** As a テンプレ開発者, I want 新コマンドが既存の `update`（テンプレ開発者向け `git pull`）と
混同されないようにしたい, so that 利用者が誤ったコマンドを実行するリスクを減らせる

#### Acceptance Criteria
1. The 新規コマンド shall `sync`（`bin/cli.js sync`, スクリプト実体 `payload/scripts/sync.sh`）という、
   既存の `update` と異なる名称を持つ。
2. When `sync` を実行した場合, the システム shall lock整合性・ローカル変更保持の検証を
   `payload/validation/checks.md` に定義された項目に沿って実施する。
3. The README shall 「その他の使い方」節に `sync` コマンドの説明（用途・実行例・非破壊性の説明）を含む。
4. When `sync` 完了後, the システム shall ローカルスキルミラー（`~/.claude/skills/sdd-init` 等）の
   再同期が必要な場合、その旨を人間に案内する（`install` の再実行を促す）。
