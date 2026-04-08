# kiro-engineer-teams

# Initialize as your own private repo (run after git clone)
init repo:
    ./scripts/init.sh {{repo}}

# Install prerequisites
setup:
    ./scripts/setup.sh

# Start full pipeline (INCEPTION → 8-agent)
start:
    ./scripts/start-pipeline.sh

# Test zellij 8-pane layout
test-layout:
    ./scripts/test-layout.sh

# Switch to Japanese
ja:
    @sed -i '' 's/Always respond to the user in English\./Always respond to the user in Japanese./' .kiro/steering/development-rules.md
    @sed -i '' 's/Always respond in English\./Always respond in Japanese./' AGENTS.md
    @echo "✅ Switched to Japanese"

# Switch to English
en:
    @sed -i '' 's/Always respond to the user in Japanese\./Always respond to the user in English./' .kiro/steering/development-rules.md
    @sed -i '' 's/Always respond in Japanese\./Always respond in English./' AGENTS.md
    @echo "✅ Switched to English"
