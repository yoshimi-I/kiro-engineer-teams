#!/usr/bin/env bash
# Usage: ./scripts/start-server.sh
# Wrapper that calls `just dev` to start all dev servers in background.
# The actual startup commands are defined in justfile (generated during INCEPTION).

set -euo pipefail

if ! command -v just &> /dev/null; then
  echo "❌ just is not installed. Run: brew install just"
  exit 1
fi

if ! grep -q '^dev:' justfile 2>/dev/null; then
  echo "❌ 'dev' recipe not found in justfile. Run INCEPTION first to generate it."
  exit 1
fi

just dev
