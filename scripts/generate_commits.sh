#!/usr/bin/env bash
# ==============================================================================
# 🌿 My Green Graph - Activity & Streak Commit Generator
# ==============================================================================
# Description: Generates realistic conventional commits and updates activity logs.
# Usage:
#   bash scripts/generate_commits.sh [--count N] [--dry-run] [--author-name "Name"] [--author-email "email"]
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Default Variables & Configurations
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_FILE="${ROOT_DIR}/config/messages.json"
LOG_FILE="${ROOT_DIR}/logs/streak.log"

COMMIT_COUNT=""
DRY_RUN=false
AUTHOR_NAME="${GIT_NAME:-${GIT_USER_NAME:-Mahmoud Al-Esawi}}"
AUTHOR_EMAIL="${GIT_EMAIL:-${GIT_USER_EMAIL:-esawi@ieee.org}}"

# ------------------------------------------------------------------------------
# Parse Command Line Arguments
# ------------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--count)
      COMMIT_COUNT="$2"
      shift 2
      ;;
    -d|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -n|--author-name)
      AUTHOR_NAME="$2"
      shift 2
      ;;
    -e|--author-email)
      AUTHOR_EMAIL="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  -c, --count <num>       Set exact number of commits to generate (default: random 2-6)"
      echo "  -d, --dry-run           Simulate commit generation without pushing or modifying git history"
      echo "  -n, --author-name <str> Git author name"
      echo "  -e, --author-email <str> Git author email"
      echo "  -h, --help              Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Ensure logs directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# ------------------------------------------------------------------------------
# Load Commit Messages Pool
# ------------------------------------------------------------------------------
DEFAULT_MESSAGES=(
  "fix(ui): responsive layout adjustments for navbar"
  "refactor(core): optimize state management logic"
  "docs: update setup instructions in README.md"
  "feat(api): add error handling middleware"
  "style: format code according to prettier guidelines"
  "test: write unit test coverage for helper functions"
  "chore: update package dependencies"
  "fix(auth): handle expired token error gracefully"
  "perf: improve rendering performance for large lists"
  "build: update build configuration"
  "ci: update workflow triggers"
  "refactor: cleanup unused variables and imports"
  "feat(components): add modal confirmation dialog"
  "fix(utils): resolve timezone parsing issue"
  "docs: clarify API endpoint parameter descriptions"
  "chore(deps): bump library versions"
  "style: clean up css utility classes"
  "feat(db): optimize query indexes"
  "test(api): add integration test suite"
  "fix(forms): validate input fields before submit"
  "perf(db): optimize relational queries and joins"
  "feat(auth): add rate limiting for sensitive routes"
  "refactor(hooks): decouple reactive event listeners"
  "docs: update architecture diagrams and workflow docs"
  "style: enforce uniform spacing in stylesheets"
)

# If jq is available and messages.json exists, read from JSON file
MESSAGES=("${DEFAULT_MESSAGES[@]}")
if command -v jq >/dev/null 2>&1 && [[ -f "$CONFIG_FILE" ]]; then
  PARSED_MESSAGES=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && PARSED_MESSAGES+=("$line")
  done < <(jq -r '.messages[]' "$CONFIG_FILE" 2>/dev/null || true)
  if [[ ${#PARSED_MESSAGES[@]} -gt 0 ]]; then
    MESSAGES=("${PARSED_MESSAGES[@]}")
  fi
fi

# ------------------------------------------------------------------------------
# Determine Number of Commits
# ------------------------------------------------------------------------------
if [[ -z "$COMMIT_COUNT" || "$COMMIT_COUNT" -le 0 ]]; then
  # Random integer between 2 and 6
  COMMIT_COUNT=$((2 + RANDOM % 5))
fi

echo "===================================================="
echo "🌿 My Green Graph - Streak Engine"
echo "===================================================="
echo "• Author: $AUTHOR_NAME <$AUTHOR_EMAIL>"
echo "• Total Commits Planned: $COMMIT_COUNT"
echo "• Dry Run Mode: $DRY_RUN"
echo "• Target Log: $LOG_FILE"
echo "===================================================="

# Configure Git if not in dry-run mode
if [[ "$DRY_RUN" = false ]]; then
  git config --local user.name "$AUTHOR_NAME"
  git config --local user.email "$AUTHOR_EMAIL"
fi

# Prepare GitHub Actions Step Summary if running in CI
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "### 📈 Contribution Streak Generator Summary"
    echo "- **Author:** \`$AUTHOR_NAME <$AUTHOR_EMAIL>\`"
    echo "- **Generated Commits:** \`$COMMIT_COUNT\`"
    echo "- **Execution Time:** \`$(date -u)\`"
    echo ""
    echo "| # | Commit Message | Status |"
    echo "|---|----------------|--------|"
  } >> "$GITHUB_STEP_SUMMARY"
fi

# ------------------------------------------------------------------------------
# Commit Generation Loop
# ------------------------------------------------------------------------------
for (( c=1; c<=COMMIT_COUNT; c++ )); do
  RAND_INDEX=$((RANDOM % ${#MESSAGES[@]}))
  MSG="${MESSAGES[$RAND_INDEX]}"
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  echo "[#$c/$COMMIT_COUNT] $MSG"

  if [[ "$DRY_RUN" = false ]]; then
    echo "[$TIMESTAMP] Streak update #$c: $MSG" >> "$LOG_FILE"
    git add "$LOG_FILE"
    git commit -m "$MSG"
  else
    echo "  [DRY-RUN] Would append: [$TIMESTAMP] Streak update #$c: $MSG"
  fi

  if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
    echo "| $c | \`$MSG\` | ✅ Committed |" >> "$GITHUB_STEP_SUMMARY"
  fi
done

# ------------------------------------------------------------------------------
# Push to Remote (if in GitHub Actions CI and not Dry Run)
# ------------------------------------------------------------------------------
if [[ "$DRY_RUN" = false && -n "${GITHUB_ACTIONS:-}" ]]; then
  echo ""
  echo "Syncing and pushing to origin main..."
  git pull --rebase origin main || true
  git push origin main
  echo "✅ Push completed successfully!"
fi

echo ""
echo "🎉 Finished generating $COMMIT_COUNT commits successfully!"
