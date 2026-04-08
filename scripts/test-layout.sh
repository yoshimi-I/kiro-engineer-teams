#!/usr/bin/env bash
# Test that zellij 8-pane layout works correctly
# Each pane just prints its name — no kiro-cli or gh needed
# Exit with Ctrl+q

set -euo pipefail

if ! command -v zellij &>/dev/null; then
  echo "❌ zellij not installed"
  exit 1
fi

LAYOUT=$(mktemp /tmp/test-layout-XXXX.kdl)
cat > "$LAYOUT" << 'EOF'
layout {
    pane split_direction="vertical" {
        pane split_direction="horizontal" {
            pane command="bash" name="Impl-1" {
                args "-c" "echo '🔨 Impl-1 ready' && sleep 999"
            }
            pane command="bash" name="Impl-2" {
                args "-c" "echo '🔨 Impl-2 ready' && sleep 999"
            }
            pane command="bash" name="Review" {
                args "-c" "echo '🔍 Review ready' && sleep 999"
            }
            pane command="bash" name="Fix-Review" {
                args "-c" "echo '🔧 Fix-Review ready' && sleep 999"
            }
        }
        pane split_direction="horizontal" {
            pane command="bash" name="Fix-CI" {
                args "-c" "echo '🚦 Fix-CI ready' && sleep 999"
            }
            pane command="bash" name="Watch-Main" {
                args "-c" "echo '👀 Watch-Main ready' && sleep 999"
            }
            pane command="bash" name="E2E-Hunt" {
                args "-c" "echo '🧪 E2E-Hunt ready' && sleep 999"
            }
            pane command="bash" name="Dependabot" {
                args "-c" "echo '📦 Dependabot ready' && sleep 999"
            }
        }
    }
}
EOF

echo "🧪 Testing 8-pane layout..."
echo "   All panes should show 'ready'"
echo "   Press Ctrl+q to exit"
echo ""

zellij --layout "$LAYOUT"
rm -f "$LAYOUT"
