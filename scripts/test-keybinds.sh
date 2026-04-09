#!/usr/bin/env bash
set -euo pipefail

if ! command -v zellij &>/dev/null; then
  echo "❌ zellij not installed"
  exit 1
fi

LAYOUT=$(mktemp /tmp/test-keybinds-XXXXXXXX.kdl)
cat > "$LAYOUT" << 'EOF'
mouse_mode true

keybinds {
    normal {
        bind "Ctrl h" { MoveFocus "Left"; }
        bind "Ctrl j" { MoveFocus "Down"; }
        bind "Ctrl k" { MoveFocus "Up"; }
        bind "Ctrl l" { MoveFocus "Right"; }
    }
}

layout {
    tab name="Pipeline" {
        pane split_direction="horizontal" {
            pane split_direction="vertical" {
                pane name="Top-Left" command="bash" {
                    args "-c" "echo '┌─────────────────────────┐'; echo '│  Top-Left               │'; echo '│  Ctrl+l → Right         │'; echo '│  Ctrl+j → Down          │'; echo '└─────────────────────────┘'; sleep 999"
                }
                pane name="Top-Right" command="bash" {
                    args "-c" "echo '┌─────────────────────────┐'; echo '│  Top-Right              │'; echo '│  Ctrl+h → Left          │'; echo '│  Ctrl+j → Down          │'; echo '└─────────────────────────┘'; sleep 999"
                }
            }
            pane split_direction="vertical" {
                pane name="Bottom-Left" command="bash" {
                    args "-c" "echo '┌─────────────────────────┐'; echo '│  Bottom-Left            │'; echo '│  Ctrl+l → Right         │'; echo '│  Ctrl+k → Up            │'; echo '└─────────────────────────┘'; sleep 999"
                }
                pane name="Bottom-Right" command="bash" {
                    args "-c" "echo '┌─────────────────────────┐'; echo '│  Bottom-Right           │'; echo '│  Ctrl+h → Left          │'; echo '│  Ctrl+k → Up            │'; echo '└─────────────────────────┘'; sleep 999"
                }
            }
        }
    }
    tab name="Status" {
        pane command="bash" name="Status" {
            args "-c" "echo 'Alt+1 → Pipeline tab / Alt+2 → this tab'; sleep 999"
        }
    }
}
EOF

echo "🧪 Testing keybinds + layout"
echo ""
echo "   Ctrl+h/j/k/l  Move between panes"
echo "   Alt+1 / Alt+2  Switch tabs"
echo "   Mouse click     Focus pane"
echo ""
echo "   Ctrl+q to exit"
echo ""
zellij --layout "$LAYOUT"
rm -f "$LAYOUT"
