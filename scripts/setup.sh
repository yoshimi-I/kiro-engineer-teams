#!/usr/bin/env bash
# Install all prerequisites for kiro-engineer-teams
# Usage: ./scripts/setup.sh

set -euo pipefail

OS="$(uname -s)"

info()  { echo "✅ $1"; }
warn()  { echo "⚠️  $1"; }
install_msg() { echo "📦 Installing $1..."; }

# Detect package manager
if command -v brew &>/dev/null; then
  PKG="brew"
elif command -v apt-get &>/dev/null; then
  PKG="apt"
elif command -v dnf &>/dev/null; then
  PKG="dnf"
else
  PKG="unknown"
fi

# --- Kiro CLI ---
if command -v kiro-cli &>/dev/null; then
  info "kiro-cli already installed"
else
  warn "kiro-cli not found. Install from https://kiro.dev/downloads/"
fi

# --- zellij ---
if command -v zellij &>/dev/null; then
  info "zellij already installed"
else
  install_msg "zellij"
  case "$PKG" in
    brew) brew install zellij ;;
    apt)  sudo apt-get install -y zellij 2>/dev/null || cargo install --locked zellij ;;
    *)    cargo install --locked zellij 2>/dev/null || warn "Install zellij manually: https://zellij.dev/" ;;
  esac
fi

# --- GitHub CLI ---
if command -v gh &>/dev/null; then
  info "gh already installed"
else
  install_msg "gh"
  case "$PKG" in
    brew) brew install gh ;;
    apt)  sudo apt-get install -y gh 2>/dev/null || warn "Install gh manually: https://cli.github.com/" ;;
    dnf)  sudo dnf install -y gh 2>/dev/null || warn "Install gh manually: https://cli.github.com/" ;;
    *)    warn "Install gh manually: https://cli.github.com/" ;;
  esac
fi

# --- gh auth ---
if gh auth status &>/dev/null; then
  info "gh authenticated"
else
  warn "gh not authenticated. Running: gh auth login"
  gh auth login
fi

# --- just (optional) ---
if command -v just &>/dev/null; then
  info "just already installed"
else
  install_msg "just (optional)"
  case "$PKG" in
    brew) brew install just ;;
    *)    warn "Install just manually: https://just.systems/" ;;
  esac
fi

echo ""
echo "🎉 Setup complete. Run: kiro-cli chat"
