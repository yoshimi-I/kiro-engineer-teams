#!/usr/bin/env bash
# Usage: ./scripts/start-server.sh
# Starts dev servers in background, waits for them to be ready, then exits.
# Kiro's shell tool can run this without blocking.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel)"

# Kill existing dev servers
kill_servers() {
  for port in 8000 5173 3000 3001; do
    lsof -ti:"$port" 2>/dev/null | xargs -r kill -9 2>/dev/null || true
  done
}

kill_servers
sleep 1

# Detect and start backend
if [[ -f "$PROJECT_ROOT/backend/pyproject.toml" ]]; then
  cd "$PROJECT_ROOT/backend"
  nohup uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 > /tmp/dev-backend.log 2>&1 &
  echo "Backend PID: $!"
elif [[ -f "$PROJECT_ROOT/server/package.json" ]]; then
  cd "$PROJECT_ROOT/server"
  nohup npm run dev > /tmp/dev-backend.log 2>&1 &
  echo "Backend PID: $!"
fi

# Detect and start frontend
if [[ -f "$PROJECT_ROOT/frontend/package.json" ]]; then
  cd "$PROJECT_ROOT/frontend"
  if grep -q '"dev"' package.json; then
    nohup npm run dev > /tmp/dev-frontend.log 2>&1 &
    echo "Frontend PID: $!"
  fi
fi

# Wait for servers to be ready
echo "Waiting for servers..."
for i in $(seq 1 30); do
  READY=true
  for port in 8000 5173; do
    if lsof -ti:"$port" > /dev/null 2>&1; then
      :
    else
      READY=false
    fi
  done
  if $READY; then
    echo "✅ All servers ready"
    exit 0
  fi
  sleep 2
done

echo "⚠️ Timeout waiting for servers. Check /tmp/dev-backend.log and /tmp/dev-frontend.log"
exit 1
