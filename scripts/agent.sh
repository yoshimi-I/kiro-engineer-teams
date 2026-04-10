#!/usr/bin/env bash
# Usage: ./scripts/agent.sh <prompt-name>
# Runs a kiro-cli agent in a loop, feeding it the specified prompt.
# Agents that depend on issues/PRs will wait until work is available.

set -euo pipefail

PROMPT_NAME="${1:?Usage: agent.sh <prompt-name>}"
PROMPT_FILE=".kiro/prompts/${PROMPT_NAME}.md"
INTERVAL="${AGENT_INTERVAL:-120}"
MAX_ERRORS=5

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "❌ Prompt not found: $PROMPT_FILE"
  exit 1
fi

error_count=0
cycle=0

# Wait condition per agent type
wait_for_work() {
  case "$PROMPT_NAME" in
    dev-server)
      # No wait — start immediately
      return 0
      ;;
    implement|watch-issues)
      echo "⏳ Waiting for open issues..."
      while true; do
        count=$(gh issue list --state open --json number --jq 'length' 2>/dev/null || echo "0")
        [[ "$count" -gt 0 ]] && return 0
        sleep 30
      done
      ;;
    review|watch-review)
      echo "⏳ Waiting for open PRs..."
      while true; do
        count=$(gh pr list --json number --jq 'length' 2>/dev/null || echo "0")
        [[ "$count" -gt 0 ]] && return 0
        sleep 30
      done
      ;;
    fix-review-issues)
      echo "⏳ Waiting for PRs with review comments..."
      while true; do
        count=$(gh pr list --json number --jq 'length' 2>/dev/null || echo "0")
        [[ "$count" -gt 0 ]] && return 0
        sleep 30
      done
      ;;
    watch-main|e2e-bug-hunt)
      echo "⏳ Waiting for first merge to main..."
      while true; do
        count=$(gh pr list --state merged --json number --jq 'length' --limit 1 2>/dev/null || echo "0")
        [[ "$count" -gt 0 ]] && return 0
        sleep 30
      done
      ;;
    improve)
      echo "⏳ Waiting for first merge to main..."
      while true; do
        count=$(gh pr list --state merged --json number --jq 'length' --limit 1 2>/dev/null || echo "0")
        [[ "$count" -gt 0 ]] && return 0
        sleep 60
      done
      ;;
    *)
      return 0
      ;;
  esac
}

echo "🚀 Agent [${PROMPT_NAME}] initialized"
echo "   Prompt: ${PROMPT_FILE}"
echo "   Interval: ${INTERVAL}s"
echo ""

# Phase 1: Wait for work
wait_for_work
echo "✅ Work detected. Starting agent loop."
echo ""

# Phase 2: Run loop
while true; do
  cycle=$((cycle + 1))
  echo "━━━ Cycle #${cycle} [$(date '+%H:%M:%S')] ━━━"

  if kiro-cli chat \
    --no-interactive \
    --trust-all-tools \
    "$(cat "$PROMPT_FILE")" 2>&1; then
    error_count=0
    echo "✅ Cycle #${cycle} complete"
  else
    error_count=$((error_count + 1))
    echo "⚠️  Cycle #${cycle} failed (${error_count}/${MAX_ERRORS})"
    [[ $error_count -ge $MAX_ERRORS ]] && echo "❌ Too many errors. Stopping." && exit 1
  fi

  # Single-run agents (none currently)

  echo "⏳ Next cycle in ${INTERVAL}s..."
  sleep "$INTERVAL"
done
