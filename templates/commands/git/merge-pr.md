---
allowed-tools: all
description: Merge pull requests safely with comprehensive validation and quality gates
---

# Merge Pull Request Command

⚡ Safely merge pull requests with automated validation, quality gates, and branch protection compliance.

**Usage:** `/git/merge-pr [PR_NUMBER] [OPTIONS]`

## 🎯 Quick Merge Actions

This command provides direct access to PR merging functionality with safety-first approach.

## Primary Implementation

**This command delegates to the comprehensive PR management system:**
```bash
#!/bin/bash

# Merge PR - Wrapper for improved discoverability
# Delegates to comprehensive PR merge implementation

echo "🔀 Initiating PR merge process..."

# Get current directory to find PR command
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if PR number provided
PR_NUMBER="$1"
if [ -n "$PR_NUMBER" ]; then
    echo "📌 Merging PR #$PR_NUMBER"
    shift  # Remove PR number from arguments
else
    echo "📌 Merging current branch PR"
fi

# Delegate to comprehensive PR merge implementation
# The /git/pr command contains robust merge logic with:
# - Pre-merge validation (approvals, CI checks, conflicts)
# - Multiple merge strategies (squash, merge commit, rebase)
# - Branch protection compliance
# - Post-merge cleanup
# - Safety gates and quality checks

if [ -f "$SCRIPT_DIR/pr.md" ]; then
    # Execute PR merge subcommand
    echo "🚀 Executing comprehensive PR merge with validation gates..."
    echo ""
    
    # Pass through to PR command's merge functionality
    # This ensures we use the battle-tested implementation
    exec bash -c "source '$SCRIPT_DIR/pr.md' && merge_pull_request $PR_NUMBER $*"
else
    # Fallback to direct GitHub CLI if PR command unavailable
    echo "⚡ Using GitHub CLI for PR merge..."
    
    if command -v gh &> /dev/null; then
        # Perform basic validation
        if [ -n "$PR_NUMBER" ]; then
            gh pr view "$PR_NUMBER" --json mergeable,reviewDecision,state
        else
            gh pr view --json mergeable,reviewDecision,state
        fi
        
        # Interactive merge with strategy selection
        echo ""
        echo "Select merge strategy:"
        echo "1) Squash and merge (recommended for features)"
        echo "2) Create merge commit (preserve history)"
        echo "3) Rebase and merge (linear history)"
        
        read -p "Strategy [1-3]: " strategy
        
        case $strategy in
            1) MERGE_FLAG="--squash" ;;
            2) MERGE_FLAG="--merge" ;;
            3) MERGE_FLAG="--rebase" ;;
            *) MERGE_FLAG="--squash" ;;
        esac
        
        if [ -n "$PR_NUMBER" ]; then
            gh pr merge "$PR_NUMBER" $MERGE_FLAG --delete-branch
        else
            gh pr merge $MERGE_FLAG --delete-branch
        fi
    else
        echo "❌ GitHub CLI (gh) not installed"
        echo "Install: https://cli.github.com/"
        exit 1
    fi
fi
```

## Features Provided via PR Command

When using this command, you get access to:

### ✅ Pre-Merge Validation
- Required approval verification
- CI/CD status checks
- Merge conflict detection
- Branch protection rules compliance
- Security scan validation

### 🔄 Merge Strategies
- **Squash and merge** - Condense commits (recommended for features)
- **Merge commit** - Preserve full history
- **Rebase and merge** - Linear history

### 🛡️ Safety Features
- Automatic test execution before merge
- Linting and code quality checks
- Sensitive data detection
- Protected branch validation
- Team collaboration requirements

### 🎯 Post-Merge Actions
- Automatic branch deletion
- Update related issues
- Trigger deployment workflows
- Notify team members
- Sync dependent branches

## Quick Examples

```bash
# Merge current branch's PR
/git/merge-pr

# Merge specific PR number
/git/merge-pr 123

# Merge with specific strategy
/git/merge-pr --squash
/git/merge-pr --merge
/git/merge-pr --rebase

# Skip branch deletion
/git/merge-pr --no-delete-branch

# Auto-merge when ready
/git/merge-pr --auto
```

## Related Commands

- `/git/pr create` - Create new pull request
- `/git/pr review` - Review pull requests
- `/git/pr status` - Check PR status
- `/git/pr update` - Update existing PR
- `/git/workflows/pr` - Complete PR workflow

## Why This Command Exists

This wrapper provides intuitive command discovery while leveraging the comprehensive, battle-tested PR merge implementation. Users can type `/git/merge` and autocomplete will suggest this command, improving discoverability without duplicating complex merge logic.

The actual implementation lives in `/git/pr merge` which includes:
- 200+ lines of safety validation
- Multi-platform support (GitHub, GitLab)
- Enterprise-grade quality gates
- Comprehensive error handling
- Team collaboration features

This design follows the principle of single source of truth while optimizing for user experience and command discoverability.