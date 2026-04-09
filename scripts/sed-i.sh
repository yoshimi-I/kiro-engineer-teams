#!/usr/bin/env bash
# Cross-platform sed -i wrapper (macOS + Linux)
if sed --version 2>/dev/null | grep -q GNU; then
  sed -i "$@"
else
  sed -i '' "$@"
fi
