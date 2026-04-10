# kiro-engineer-teams

# Initialize as your own private repo (run after git clone)
init:
    ./scripts/init.sh

# Install into existing project (run from target project root)
install:
    bash <(curl -fsSL https://raw.githubusercontent.com/yoshimi-I/kiro-engineer-teams/main/scripts/install.sh)

# Install prerequisites
setup:
    ./scripts/setup.sh

# Start full pipeline (INCEPTION → 8-agent, skips INCEPTION if already completed)
start:
    ./scripts/start-pipeline.sh

# Restart from INCEPTION (clear previous artifacts and start fresh)
restart:
    rm -rf aidlc-docs/inception
    ./scripts/start-pipeline.sh

# Launch 7-agent pipeline only (skip INCEPTION)
pipeline:
    zellij --layout scripts/pipeline.kdl

# Test zellij 8-pane layout
test-layout:
    ./scripts/test-layout.sh

# Switch to Japanese
ja:
    @scripts/sed-i.sh 's/Always respond to the user in English\./Always respond to the user in Japanese./' .kiro/steering/development-rules.md
    @scripts/sed-i.sh 's/Always respond in English\./Always respond in Japanese./' AGENTS.md
    @echo "✅ Switched to Japanese"

# Switch to English
en:
    @scripts/sed-i.sh 's/Always respond to the user in Japanese\./Always respond to the user in English./' .kiro/steering/development-rules.md
    @scripts/sed-i.sh 's/Always respond in Japanese\./Always respond in English./' AGENTS.md
    @echo "✅ Switched to English"
