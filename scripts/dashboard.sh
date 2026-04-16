#!/usr/bin/env bash
# Real-time agent dashboard for zellij Status tab
set -euo pipefail

STATUS_DIR=".agent-status"
REFRESH=3

# Agent display config: id → emoji + role
declare -A ICONS=(
  [Dev-Server]="🖥️  Dev-Server"
  [Impl-1]="🔨 Impl-1"
  [Impl-2]="🔨 Impl-2"
  [Review-1]="🔍 Review-1"
  [Review-2]="🔍 Review-2"
  [Fix-Review-1]="🔧 Fix-Review-1"
  [Fix-Review-2]="🔧 Fix-Review-2"
  [Watch-Main]="👀 Watch-Main"
  [E2E-Hunt]="🧪 E2E-Hunt"
  [Improve]="💡 Improve"
)

ORDER=(Dev-Server Impl-1 Impl-2 Review-1 Review-2 Fix-Review-1 Fix-Review-2 Watch-Main E2E-Hunt Improve)

# Colors
R='\033[0m'
DIM='\033[2m'
BOLD='\033[1m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
MAGENTA='\033[35m'
BLUE='\033[34m'
WHITE='\033[97m'
BG_DARK='\033[48;5;236m'

state_color() {
  case "$1" in
    *running*)  echo -e "${CYAN}" ;;
    *done*)     echo -e "${GREEN}" ;;
    *error*)    echo -e "${RED}" ;;
    *dead*)     echo -e "${RED}${BOLD}" ;;
    *waiting*)  echo -e "${YELLOW}" ;;
    *ready*)    echo -e "${GREEN}" ;;
    *sleeping*) echo -e "${MAGENTA}" ;;
    *)          echo -e "${DIM}" ;;
  esac
}

progress_bar() {
  local state="$1" width=20
  local filled empty char
  case "$state" in
    *running*)  filled=20; char="▓" ;;
    *done*)     filled=20; char="█" ;;
    *error*)    filled=20; char="░" ;;
    *dead*)     filled=20; char="✕" ;;
    *waiting*)  filled=$(( (SECONDS / 2) % (width + 1) )); char="▒" ;;
    *ready*)    filled=20; char="█" ;;
    *sleeping*) filled=$(( (SECONDS / 2) % (width + 1) )); char="·" ;;
    *)          filled=0;  char="·" ;;
  esac
  empty=$((width - filled))
  printf '%s' "$(printf "%${filled}s" | tr ' ' "$char")$(printf "%${empty}s" | tr ' ' '·')"
}

while true; do
  clear

  # Header
  echo -e "${BOLD}${CYAN}"
  echo "  ╔══════════════════════════════════════════════════════════════╗"
  echo "  ║           🤖  K I R O   P I P E L I N E   🤖              ║"
  echo "  ╚══════════════════════════════════════════════════════════════╝${R}"
  echo ""

  # Stats summary
  local_time=$(date '+%H:%M:%S')
  total=0; running=0; errors=0; sleeping=0
  for id in "${ORDER[@]}"; do
    f="${STATUS_DIR}/${id}.json"
    [[ -f "$f" ]] || continue
    total=$((total + 1))
    state=$(jq -r '.state // ""' "$f" 2>/dev/null || true)
    case "$state" in
      *running*) running=$((running + 1)) ;;
      *error*|*dead*) errors=$((errors + 1)) ;;
      *sleeping*) sleeping=$((sleeping + 1)) ;;
    esac
  done
  echo -e "  ${DIM}${local_time}${R}  ${WHITE}Agents: ${total}${R}  ${CYAN}▶ ${running}${R}  ${RED}✕ ${errors}${R}  ${MAGENTA}◆ ${sleeping}${R}"
  echo ""

  # Agent rows
  echo -e "  ${DIM}┌──────────────────┬──────────────┬──────────────────────┬────────┐${R}"
  printf "  ${DIM}│${R} ${BOLD}%-16s${R} ${DIM}│${R} ${BOLD}%-12s${R} ${DIM}│${R} ${BOLD}%-20s${R} ${DIM}│${R} ${BOLD}%-6s${R} ${DIM}│${R}\n" "Agent" "State" "Progress" "Cycle"
  echo -e "  ${DIM}├──────────────────┼──────────────┼──────────────────────┼────────┤${R}"

  for id in "${ORDER[@]}"; do
    f="${STATUS_DIR}/${id}.json"
    icon="${ICONS[$id]:-$id}"

    if [[ ! -f "$f" ]]; then
      printf "  ${DIM}│${R} %-17s ${DIM}│${R} ${DIM}%-16s${R} ${DIM}│${R} ${DIM}%-20s${R} ${DIM}│${R} ${DIM}%-6s${R} ${DIM}│${R}\n" \
        "$icon" "  ○ offline" "····················" "  -"
      continue
    fi

    state=$(jq -r '.state // "?"' "$f" 2>/dev/null || echo "?")
    detail=$(jq -r '.detail // ""' "$f" 2>/dev/null || echo "")
    cycle=$(jq -r '.cycle // 0' "$f" 2>/dev/null || echo "0")
    ts=$(jq -r '.ts // ""' "$f" 2>/dev/null || echo "")

    sc=$(state_color "$state")
    bar=$(progress_bar "$state")

    # Truncate detail
    [[ ${#detail} -gt 12 ]] && detail="${detail:0:11}…"

    printf "  ${DIM}│${R} %-17s ${DIM}│${R} ${sc}%-14s${R} ${DIM}│${R} ${sc}%-20s${R} ${DIM}│${R} %6s ${DIM}│${R}\n" \
      "$icon" "  $state" "$bar" "#${cycle}"
  done

  echo -e "  ${DIM}└──────────────────┴──────────────┴──────────────────────┴────────┘${R}"
  echo ""

  # Detail section
  echo -e "  ${BOLD}📋 Details${R}"
  echo -e "  ${DIM}─────────────────────────────────────────────────────────────────${R}"
  for id in "${ORDER[@]}"; do
    f="${STATUS_DIR}/${id}.json"
    [[ -f "$f" ]] || continue
    state=$(jq -r '.state // ""' "$f" 2>/dev/null || true)
    detail=$(jq -r '.detail // ""' "$f" 2>/dev/null || true)
    ts=$(jq -r '.ts // ""' "$f" 2>/dev/null || true)
    [[ -z "$detail" && "$state" != *running* ]] && continue
    sc=$(state_color "$state")
    echo -e "  ${sc}${ICONS[$id]:-$id}${R} ${DIM}${ts}${R} ${detail}"
  done

  echo ""
  echo -e "  ${DIM}Refresh: ${REFRESH}s │ Ctrl+C to exit${R}"

  sleep "$REFRESH"
done
