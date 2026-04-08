# kiro-engineer-teams

# Install prerequisites
setup:
    ./scripts/setup.sh

# Start full pipeline (INCEPTION → 8-agent)
start:
    ./scripts/start-pipeline.sh

# Test zellij 8-pane layout (no kiro-cli needed)
test-layout:
    ./scripts/test-layout.sh

# Switch prompts/steering to Japanese
to-japanese:
    kiro-cli chat --no-interactive --trust-all-tools "/to-japanese"

# Switch prompts/steering to English
to-english:
    kiro-cli chat --no-interactive --trust-all-tools "/to-english"
