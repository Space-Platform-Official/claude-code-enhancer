# Pull Request Utilities

Shared utilities for pull request operations across GitHub, GitLab, and other platforms.

## GitHub Integration Functions

### PR Creation Utilities
```bash
# Create GitHub PR with comprehensive validation
create_github_pr() {
    local title="$1"
    local body="$2"
    local base_branch="${3:-main}"
    
    # Validate GitHub CLI availability
    if ! command -v gh &> /dev/null; then
        echo "❌ GitHub CLI not found. Install: brew install gh"
        return 1
    fi
    
    # Validate authentication
    if ! gh auth status &>/dev/null; then
        echo "🔐 GitHub authentication required"
        gh auth login
    fi
    
    # Create PR with enhanced options
    gh pr create \
        --title "$title" \
        --body "$body" \
        --base "$base_branch" \
        --assignee @me \
        --draft=false
    
    # Get PR URL for reference
    local pr_url=$(gh pr view --json url -q .url)
    echo "✅ GitHub PR created: $pr_url"
    
    return 0
}

# Check PR status and merge readiness
check_pr_status() {
    if ! command -v gh &> /dev/null; then
        echo "💡 GitHub CLI required for status checking"
        return 1
    fi
    
    local pr_info=$(gh pr view --json number,state,reviewDecision,mergeable,checks)
    
    if [ -n "$pr_info" ]; then
        echo "📊 PR Status:"
        echo "$pr_info" | jq -r '"  #\(.number) - \(.state)"'
        echo "$pr_info" | jq -r '"  Review: \(.reviewDecision // "PENDING")"'
        echo "$pr_info" | jq -r '"  Mergeable: \(.mergeable)"'
        
        # Check CI status
        local failed_checks=$(echo "$pr_info" | jq -r '.checks[]? | select(.conclusion == "failure") | .name' 2>/dev/null)
        if [ -n "$failed_checks" ]; then
            echo "  ❌ Failed checks: $failed_checks"
            return 1
        fi
        
        return 0
    else
        echo "❌ No PR found for current branch"
        return 1
    fi
}

# Universal PR creation wrapper
create_pr_universal() {
    local title="$1"
    local body="$2"
    local platform=$(detect_git_platform)
    
    case "$platform" in
        "github")
            create_github_pr "$title" "$body"
            ;;
        "gitlab")
            create_gitlab_mr "$title" "$body"
            ;;
        *)
            echo "❌ Unknown platform: $platform"
            echo "Create PR manually with title: $title"
            ;;
    esac
}

# Detect git platform from remote URL
detect_git_platform() {
    local remote_url=$(git remote get-url origin 2>/dev/null)
    
    if [[ "$remote_url" =~ github\.com ]]; then
        echo "github"
    elif [[ "$remote_url" =~ gitlab\.com ]]; then
        echo "gitlab"
    elif [[ "$remote_url" =~ bitbucket\.org ]]; then
        echo "bitbucket"
    else
        echo "unknown"
    fi
}

# Generate comprehensive PR description
generate_pr_description() {
    local base_branch="${1:-main}"
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Extract ticket/issue number
    local ticket=$(echo "$current_branch" | grep -oE '[A-Z]+-[0-9]+|#[0-9]+' | head -1)
    
    # Generate change summary
    local changes=$(git log --oneline "$base_branch".."$current_branch" | head -10)
    local files_changed=$(git diff --name-only "$base_branch".."$current_branch" | wc -l)
    
    # Create comprehensive description
    cat << EOF
## Summary

This PR introduces changes from the \`$current_branch\` branch.

## Changes Made

$changes

## Files Modified

$files_changed files changed in this PR.

## Type of Change

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing

- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Quality Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review of code completed
- [ ] Tests added and passing
- [ ] Documentation updated

$(if [ -n "$ticket" ]; then echo "## Related Issues"; echo "Closes $ticket"; fi)

---

🤖 Generated with Claude Code PR Assistant
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
}
```