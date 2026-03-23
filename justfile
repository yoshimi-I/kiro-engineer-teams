# Kiro Engineer Teams - タスクランナー

# GitHub CLI → GitLab CLI に一括変換
to-gitlab:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Converting gh CLI → glab CLI in .kiro/skills/..."

    find .kiro/skills -name "*.md" | while read -r file; do
        sed -i '' \
            -e 's/`gh issue list/`glab issue list/g' \
            -e 's/`gh issue view/`glab issue view/g' \
            -e 's/`gh issue create/`glab issue create/g' \
            -e 's/`gh pr list/`glab mr list/g' \
            -e 's/`gh pr view/`glab mr view/g' \
            -e 's/`gh pr create/`glab mr create/g' \
            -e 's/`gh pr merge/`glab mr merge/g' \
            -e 's/`gh pr diff/`glab mr diff/g' \
            -e 's/`gh pr review/`glab mr approve/g' \
            -e 's/`gh pr checks/`glab ci status/g' \
            -e 's/`gh run list/`glab ci list/g' \
            -e 's/`gh run view/`glab ci view/g' \
            -e 's/`gh run rerun/`glab ci retry/g' \
            -e 's/gh issue list/glab issue list/g' \
            -e 's/gh issue view/glab issue view/g' \
            -e 's/gh issue create/glab issue create/g' \
            -e 's/gh pr list/glab mr list/g' \
            -e 's/gh pr view/glab mr view/g' \
            -e 's/gh pr create/glab mr create/g' \
            -e 's/gh pr merge/glab mr merge/g' \
            -e 's/gh pr diff/glab mr diff/g' \
            -e 's/gh pr review/glab mr approve/g' \
            -e 's/gh pr checks/glab ci status/g' \
            -e 's/gh pr comment/glab mr note/g' \
            -e 's/gh run list/glab ci list/g' \
            -e 's/gh run view/glab ci view/g' \
            -e 's/gh run rerun/glab ci retry/g' \
            -e 's/PR/MR/g' \
            -e 's/Pull Request/Merge Request/g' \
            -e 's/pull request/merge request/g' \
            -e 's/GitHub/GitLab/g' \
            "$file"
    done

    echo "Done. Review changes with: git diff .kiro/skills/"

# GitLab CLI → GitHub CLI に一括変換（戻す）
to-github:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Converting glab CLI → gh CLI in .kiro/skills/..."

    find .kiro/skills -name "*.md" | while read -r file; do
        sed -i '' \
            -e 's/`glab issue list/`gh issue list/g' \
            -e 's/`glab issue view/`gh issue view/g' \
            -e 's/`glab issue create/`gh issue create/g' \
            -e 's/`glab mr list/`gh pr list/g' \
            -e 's/`glab mr view/`gh pr view/g' \
            -e 's/`glab mr create/`gh pr create/g' \
            -e 's/`glab mr merge/`gh pr merge/g' \
            -e 's/`glab mr diff/`gh pr diff/g' \
            -e 's/`glab mr approve/`gh pr review/g' \
            -e 's/`glab ci status/`gh pr checks/g' \
            -e 's/`glab ci list/`gh run list/g' \
            -e 's/`glab ci view/`gh run view/g' \
            -e 's/`glab ci retry/`gh run rerun/g' \
            -e 's/glab issue list/gh issue list/g' \
            -e 's/glab issue view/gh issue view/g' \
            -e 's/glab issue create/gh issue create/g' \
            -e 's/glab mr list/gh pr list/g' \
            -e 's/glab mr view/gh pr view/g' \
            -e 's/glab mr create/gh pr create/g' \
            -e 's/glab mr merge/gh pr merge/g' \
            -e 's/glab mr diff/gh pr diff/g' \
            -e 's/glab mr approve/gh pr review/g' \
            -e 's/glab ci status/gh pr checks/g' \
            -e 's/glab mr note/gh pr comment/g' \
            -e 's/glab ci list/gh run list/g' \
            -e 's/glab ci view/gh run view/g' \
            -e 's/glab ci retry/gh run rerun/g' \
            -e 's/MR/PR/g' \
            -e 's/Merge Request/Pull Request/g' \
            -e 's/merge request/pull request/g' \
            -e 's/GitLab/GitHub/g' \
            "$file"
    done

    echo "Done. Review changes with: git diff .kiro/skills/"
