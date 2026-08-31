# 🏗️ System Architecture & Design

This document details the architectural design, execution flow, directory structure, and failure recovery mechanisms for **`my-green-graph`**.

---

## 🧭 Architectural Overview

`my-green-graph` operates as an event-driven, autonomous Git activity pipeline built on top of GitHub Actions and modular POSIX-compliant shell scripts.

```
┌─────────────────────────────────────────────────────────────┐
│                    Trigger Sources                          │
│  ┌─────────────────────────┐   ┌─────────────────────────┐  │
│  │ Cron Schedule (Daily)   │   │ Manual Workflow Dispatch│  │
│  └───────────┬─────────────┘   └───────────┬─────────────┘  │
└──────────────┼─────────────────────────────┼────────────────┘
               ▼                             ▼
┌─────────────────────────────────────────────────────────────┐
│           GitHub Actions Runner (Ubuntu Latest)             │
│                                                             │
│  1. Checkout Workspace (fetch-depth: 0)                     │
│  2. Identity Resolution (Secrets -> Env -> Defaults)        │
│  3. Execution of scripts/generate_commits.sh                │
│     ├── Message Pool Extraction (config/messages.json)      │
│     ├── Stochastic Commit Quantifier (2..6 commits)         │
│     ├── Append Log Audit Entry (logs/streak.log)            │
│     ├── Git Stage & Commit (Conventional Commits standard)  │
│     └── GitHub Actions Summary Generation ($GITHUB_STEP_SUMMARY)
│  4. Network Sync & Push (git pull --rebase -> git push)    │
└──────────────────────────────┬──────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      GitHub Platform                        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ User Contribution Graph (Active Heatmap Square)       │  │
│  │ Unbroken Streak Counter Preserved                     │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📂 Directory Layout

```text
my-green-graph/
├── .github/
│   ├── ISSUE_TEMPLATE/          # Structured issue intake forms
│   │   ├── bug_report.yml
│   │   ├── feature_request.yml
│   │   └── config.yml
│   ├── workflows/               # CI/CD pipelines
│   │   ├── streak.yml           # Daily scheduled commit generator
│   │   └── ci.yml               # Automated CI linter and validation
│   ├── labels.yml               # Repository labels specification
│   ├── PULL_REQUEST_TEMPLATE.md # Standard PR checklist
│   └── dependabot.yml           # Automated action dependency management
├── config/
│   └── messages.json            # Semantic conventional commit message dictionary
├── docs/
│   ├── ARCHITECTURE.md          # Architecture specification (this file)
│   └── SETUP.md                 # Local setup and workflow debugging
├── logs/
│   ├── streak.log               # Live activity audit log
│   ├── activity.log             # Archived history
│   └── .gitkeep
├── scripts/
│   └── generate_commits.sh      # Core modular streak generator engine
├── .editorconfig                # Universal IDE code formatting rules
├── .gitignore                   # Version control exclusions
├── CODE_OF_CONDUCT.md           # Community guidelines (Contributor Covenant 2.1)
├── CONTRIBUTING.md              # Open source contribution guide
├── LICENSE                      # MIT Open Source License
├── README.md                    # Main repository presentation & documentation
└── SECURITY.md                  # Security vulnerability reporting policy
```

---

## 🧩 Core Components

### 1. The Generator Engine (`scripts/generate_commits.sh`)
- **Language**: POSIX-compliant Bash shell.
- **Portability**: Compatible with Bash 3.2+ (macOS default), Bash 4, and Bash 5 (Ubuntu/Linux).
- **Functions**:
  - Validates and parses CLI arguments (`--count`, `--dry-run`, `--author-name`, `--author-email`).
  - Reads semantic commit phrases from `config/messages.json` (falls back gracefully to built-in arrays if `jq` is absent).
  - Generates ISO 8601 UTC timestamped logs into `logs/streak.log`.
  - Stages and creates authentic Git commits.
  - Automatically pipes Markdown formatted tables to `$GITHUB_STEP_SUMMARY` when running inside GitHub Actions.

### 2. Message Configuration (`config/messages.json`)
- Clean JSON format categorizing commit scopes (`feat`, `fix`, `docs`, `refactor`, `perf`, `style`, `test`, `chore`, `ci`, `build`).
- Enables users and contributors to easily customize or add industry-specific commit message pools.

### 3. Orchestration Workflow (`.github/workflows/streak.yml`)
- Triggers on daily cron at `0 10 * * *` (10:00 UTC).
- Supports manual override via `workflow_dispatch` with custom commit counts.
- Concurrency group `streak-updater` to prevent duplicate concurrent runs.
- Executes with scoped `contents: write` token permissions.

---

## 🛡️ Fault Tolerance & Concurrency

- **Push Race Conditions**: Uses `git pull --rebase origin main || true` immediately prior to pushing to ensure fast-forward consistency.
- **Concurrency Locks**: `concurrency.cancel-in-progress: false` ensures in-flight commits are not aborted midway.
- **Graceful Fallbacks**: If `config/messages.json` or `jq` is missing or corrupted, the script falls back to internal safe default messages without failing the workflow.
