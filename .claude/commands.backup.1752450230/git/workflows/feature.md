---
allowed-tools: all
description: Complete feature branch workflow from start to production merge
---

# Feature Branch Workflow

End-to-end feature development workflow with quality gates, collaboration support, and automated integration.

**Usage:** `/git/workflows/feature $ARGUMENTS`

## 🚀 COMPLETE FEATURE LIFECYCLE 🚀

**Feature workflow is the heart of collaborative development!**

This workflow manages the complete feature lifecycle:

1. **PLANNING** - Feature definition and branch setup
2. **DEVELOPMENT** - Iterative development with quality checks
3. **COLLABORATION** - Code review and team feedback
4. **INTEGRATION** - Safe merge to main with validation

## Workflow Overview

```
main ──○──○──○──○──○──○── (production ready)
        \              /
         ○──○──○──○──○── feature/TICKET-123-user-auth
              │     │
           review  updates
```

## Phase 1: Feature Planning & Setup

**Prerequisites:**
- Clear feature requirements
- Ticket/issue number available
- Clean working directory

**Step 1: Feature Initialization**
```bash
# Interactive feature setup
init_feature() {
    echo "🎯 Feature Planning Assistant"
    echo "============================"
    
    # Gather requirements
    read -p "📋 Ticket ID (e.g., JIRA-123): " ticket_id
    read -p "📝 Feature description (kebab-case): " description
    read -p "👤 Assigned developer(s): " assignees
    read -p "🎯 Target milestone/sprint: " milestone
    
    # Generate branch name
    branch_name="feature/${ticket_id}-${description}"
    
    # Validate branch name
    if ! validate_branch_name "$branch_name"; then
        echo "❌ Invalid branch name format"
        exit 1
    fi
    
    # Check if branch already exists
    if branch_exists "$branch_name"; then
        echo "⚠️  Branch already exists. Switching to existing branch."
        git checkout "$branch_name"
        return
    fi
    
    # Ensure we're starting from latest main
    git checkout main
    git pull origin main
    
    # Create feature branch
    git checkout -b "$branch_name"
    
    # Create feature documentation
    create_feature_docs "$ticket_id" "$description" "$assignees" "$milestone"
    
    # Initial commit
    git add .
    git commit -m "feat: initialize feature ${ticket_id} - ${description}

- Add feature documentation template
- Set up development environment
- Establish acceptance criteria

Ticket: ${ticket_id}
Assignee: ${assignees}
Milestone: ${milestone}"
    
    echo "✅ Feature branch '$branch_name' created and initialized"
    echo "📁 Next steps:"
    echo "   1. Review acceptance criteria in FEATURE.md"
    echo "   2. Start development iterations"
    echo "   3. Push branch when ready for collaboration"
}

create_feature_docs() {
    local ticket=$1
    local description=$2
    local assignees=$3
    local milestone=$4
    
    cat > FEATURE.md << EOF
# Feature: ${description^}

**Ticket:** ${ticket}
**Assignees:** ${assignees}
**Milestone:** ${milestone}
**Status:** In Development

## Overview

[Brief description of the feature and its business value]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Technical Requirements

- [ ] Database schema changes
- [ ] API endpoint modifications
- [ ] Frontend component updates
- [ ] Tests coverage >= 80%
- [ ] Documentation updates

## Dependencies

- [ ] [Dependency 1]
- [ ] [Dependency 2]

## Testing Strategy

- [ ] Unit tests
- [ ] Integration tests
- [ ] E2E tests
- [ ] Manual testing checklist

## Rollout Plan

- [ ] Feature flag implementation
- [ ] Gradual rollout strategy
- [ ] Monitoring and alerts
- [ ] Rollback procedure

## Notes

[Additional context, decisions, or considerations]
EOF
}
```

**Step 2: Development Environment Setup**
```bash
# Set up development hooks and tools
setup_dev_environment() {
    echo "🔧 Setting up development environment..."
    
    # Install pre-commit hooks if not present
    if [ ! -f .git/hooks/pre-commit ]; then
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
source .claude/commands/git/_shared/utils.md

echo "🔍 Running pre-commit checks..."

# Check for merge conflicts
if git diff --cached | grep -E "^(\+|-)(<<<<<<<|=======|>>>>>>>)" ; then
    echo "❌ Merge conflict markers detected!"
    exit 1
fi

# Run linters
if ! run_linters; then
    echo "❌ Linting failed!"
    exit 1
fi

# Check for sensitive data
if ! check_sensitive_data; then
    echo "❌ Sensitive data detected!"
    exit 1
fi

# Run relevant tests
if ! run_tests; then
    echo "❌ Tests failed!"
    exit 1
fi

echo "✅ Pre-commit checks passed"
EOF
        chmod +x .git/hooks/pre-commit
    fi
    
    # Set up commit message template
    if [ ! -f .gitmessage ]; then
        cat > .gitmessage << 'EOF'
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>
#
# Type: feat, fix, docs, style, refactor, perf, test, chore
# Scope: component or file name
# Subject: imperative mood, no period, max 50 chars
# Body: wrap at 72 chars, explain what and why vs. how
# Footer: reference issues and breaking changes
EOF
        git config commit.template .gitmessage
    fi
    
    echo "✅ Development environment configured"
}
```

## Phase 2: Iterative Development

**Development Loop Pattern:**
```bash
# Main development iteration
dev_iteration() {
    echo "🔄 Starting development iteration"
    
    # 1. Sync with main regularly
    sync_with_main
    
    # 2. Work on specific feature component
    echo "💻 Development time!"
    echo "Remember to:"
    echo "  - Make small, focused commits"
    echo "  - Update tests as you go"
    echo "  - Update documentation"
    echo "  - Follow coding standards"
    
    # 3. Quality checkpoint
    quality_checkpoint
    
    # 4. Commit changes
    smart_commit
    
    # 5. Push if ready for collaboration
    read -p "🔄 Push changes for team visibility? (y/n): " should_push
    if [[ "$should_push" == "y" ]]; then
        safe_push
    fi
}

sync_with_main() {
    echo "🔄 Syncing with main branch..."
    
    current_branch=$(get_current_branch)
    
    # Stash any uncommitted work
    if ! is_repo_clean; then
        echo "💾 Stashing uncommitted changes..."
        git stash push -m "dev-iteration-sync-$(date +%s)"
        STASH_CREATED=true
    fi
    
    # Update main
    git fetch origin main
    
    # Check for conflicts early
    if ! git merge-tree $(git merge-base origin/main "$current_branch") origin/main "$current_branch" | grep -q "<<<<<<< "; then
        # Clean rebase
        git rebase origin/main
    else
        # Potential conflicts - warn developer
        echo "⚠️  Potential merge conflicts detected with main"
        echo "Consider interactive rebase: git rebase -i origin/main"
        echo "Or merge: git merge origin/main"
        
        read -p "Auto-merge origin/main? (y/n): " auto_merge
        if [[ "$auto_merge" == "y" ]]; then
            git merge origin/main --no-ff -m "Merge main into $current_branch"
        fi
    fi
    
    # Restore stashed work
    if [[ "$STASH_CREATED" == "true" ]]; then
        echo "🔄 Restoring stashed changes..."
        git stash pop
    fi
}

quality_checkpoint() {
    echo "🔍 Running quality checkpoint..."
    
    # Code quality checks
    if command -v make &> /dev/null; then
        make lint || echo "⚠️  Linting issues detected"
        make test || echo "⚠️  Test failures detected"
    fi
    
    # Feature completion check
    check_feature_progress
    
    # Security scan
    check_sensitive_data
    
    echo "✅ Quality checkpoint complete"
}

check_feature_progress() {
    if [ -f FEATURE.md ]; then
        total_criteria=$(grep -c '\- \[ \]' FEATURE.md)
        completed_criteria=$(grep -c '\- \[x\]' FEATURE.md)
        
        if [ "$total_criteria" -gt 0 ]; then
            completion_percent=$(( completed_criteria * 100 / total_criteria ))
            echo "📊 Feature completion: $completion_percent% ($completed_criteria/$total_criteria)"
            
            if [ "$completion_percent" -ge 80 ]; then
                echo "🎯 Feature is nearly complete! Consider preparing for review."
            fi
        fi
    fi
}

smart_commit() {
    echo "💾 Creating smart commit..."
    
    # Use the commit command with validation
    /git/commit
}

safe_push() {
    echo "📤 Pushing changes safely..."
    
    # Use the push command with safety checks
    /git/push
}
```

## Phase 3: Code Review & Collaboration

**Review Preparation:**
```bash
prepare_for_review() {
    echo "👀 Preparing feature for code review..."
    
    current_branch=$(get_current_branch)
    
    # Final sync with main
    sync_with_main
    
    # Run comprehensive quality checks
    echo "🔍 Running final quality checks..."
    
    # 1. Full test suite
    if ! run_tests; then
        echo "❌ Tests must pass before review!"
        exit 1
    fi
    
    # 2. Code coverage check
    check_code_coverage
    
    # 3. Documentation updates
    update_documentation
    
    # 4. Final lint check
    if ! run_linters; then
        echo "❌ Linting issues must be resolved!"
        exit 1
    fi
    
    # 5. Security scan
    if ! check_sensitive_data; then
        echo "❌ Security issues must be resolved!"
        exit 1
    fi
    
    # 6. Feature completion verification
    verify_feature_completion
    
    # Push latest changes
    git push -u origin "$current_branch"
    
    # Create pull request
    create_pull_request
    
    echo "✅ Feature ready for review!"
}

check_code_coverage() {
    echo "📊 Checking code coverage..."
    
    if [ -f package.json ] && npm list --depth=0 nyc &>/dev/null; then
        npm run coverage
        coverage=$(npx nyc report --reporter=text-summary | grep "Lines" | grep -o "[0-9.]*%" | head -1)
        echo "Coverage: $coverage"
    elif [ -f Cargo.toml ]; then
        cargo tarpaulin --out Stdout | grep "Coverage" || echo "Run: cargo install cargo-tarpaulin"
    elif [ -f go.mod ]; then
        go test -cover ./... || echo "Coverage check completed"
    else
        echo "ℹ️  No coverage tool configured"
    fi
}

update_documentation() {
    echo "📚 Updating documentation..."
    
    # Check if README needs updates
    if [ -f README.md ]; then
        last_readme_update=$(git log -1 --format=%ct README.md 2>/dev/null || echo 0)
        last_code_update=$(git log -1 --format=%ct --name-only | grep -E '\.(js|ts|py|go|rs|rb)$' | head -1 | xargs git log -1 --format=%ct 2>/dev/null || echo 0)
        
        if [ "$last_code_update" -gt "$last_readme_update" ]; then
            echo "⚠️  README.md may need updates (code changed after last README update)"
        fi
    fi
    
    # Update FEATURE.md with completion status
    if [ -f FEATURE.md ]; then
        sed -i.bak "s/\*\*Status:\*\* In Development/\*\*Status:\*\* Ready for Review/" FEATURE.md
        rm -f FEATURE.md.bak
    fi
}

verify_feature_completion() {
    echo "✅ Verifying feature completion..."
    
    if [ -f FEATURE.md ]; then
        remaining_tasks=$(grep -c '\- \[ \]' FEATURE.md)
        
        if [ "$remaining_tasks" -gt 0 ]; then
            echo "⚠️  Warning: $remaining_tasks acceptance criteria remain incomplete"
            grep '\- \[ \]' FEATURE.md
            
            read -p "Continue with review despite incomplete criteria? (y/n): " continue_review
            if [[ "$continue_review" != "y" ]]; then
                echo "Complete remaining tasks before submitting for review"
                exit 1
            fi
        else
            echo "🎯 All acceptance criteria completed!"
        fi
    fi
}

create_pull_request() {
    echo "🔄 Creating pull request..."
    
    current_branch=$(get_current_branch)
    
    # Extract ticket and description
    ticket=$(echo "$current_branch" | grep -oE '[A-Z]+-[0-9]+' | head -1)
    description=$(echo "$current_branch" | sed 's/feature\///; s/[A-Z]*-[0-9]*-//' | tr '-' ' ')
    
    # Generate PR title and body
    pr_title="${ticket}: ${description^}"
    
    # Create PR body from FEATURE.md if available
    if [ -f FEATURE.md ]; then
        pr_body=$(cat << EOF
## Summary

$(grep -A3 "## Overview" FEATURE.md | tail -n+2 | head -3)

## Changes Made

$(git log --oneline origin/main..HEAD | sed 's/^/- /')

## Acceptance Criteria

$(grep -A20 "## Acceptance Criteria" FEATURE.md | grep '\- \[' | head -10)

## Testing

$(grep -A10 "## Testing Strategy" FEATURE.md | grep '\- \[' | head -5)

## Review Checklist

- [ ] Code follows project standards
- [ ] Tests pass and coverage is adequate
- [ ] Documentation is updated
- [ ] No security vulnerabilities
- [ ] Performance impact is acceptable
- [ ] Breaking changes are documented

🤖 Generated with Claude Code
EOF
    else
        pr_body=$(cat << EOF
## Summary

Brief description of the changes made in this feature.

## Changes Made

$(git log --oneline origin/main..HEAD | sed 's/^/- /')

## Testing

- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Review Checklist

- [ ] Code follows project standards
- [ ] Tests pass and coverage is adequate
- [ ] Documentation is updated
- [ ] No security vulnerabilities

🤖 Generated with Claude Code
EOF
    fi
    
    # Create PR using GitHub CLI if available
    if command -v gh &> /dev/null; then
        gh pr create --title "$pr_title" --body "$pr_body" --assignee @me
        pr_url=$(gh pr view --json url -q .url)
        echo "📝 Pull request created: $pr_url"
    else
        echo "📝 Create pull request manually:"
        echo "Title: $pr_title"
        echo "Body: (see generated template above)"
    fi
}
```

**Review Response Handling:**
```bash
handle_review_feedback() {
    echo "📝 Processing review feedback..."
    
    current_branch=$(get_current_branch)
    
    echo "Review feedback workflow:"
    echo "1. Address feedback in separate commits"
    echo "2. Respond to comments"
    echo "3. Request re-review"
    
    # Address feedback loop
    while true; do
        echo ""
        echo "What would you like to do?"
        echo "1) Address specific feedback"
        echo "2) Push updates"
        echo "3) Request re-review"
        echo "4) Exit"
        
        read -p "Choice (1-4): " choice
        
        case $choice in
            1) address_feedback ;;
            2) push_updates ;;
            3) request_rereview ;;
            4) break ;;
            *) echo "Invalid choice" ;;
        esac
    done
}

address_feedback() {
    echo "💻 Address feedback in your editor, then return here"
    echo "Make focused commits for each piece of feedback"
    
    read -p "Press Enter when ready to commit feedback changes..."
    
    # Create focused commit for feedback
    git add -p
    read -p "Commit message for feedback response: " commit_msg
    git commit -m "review: $commit_msg

Addresses review feedback

Co-authored-by: [Reviewer Name] <[reviewer@email.com]>"
}

push_updates() {
    echo "📤 Pushing review updates..."
    
    # Run quick quality check
    run_linters
    
    # Push updates
    git push origin "$(get_current_branch)"
    
    echo "✅ Updates pushed to PR"
}

request_rereview() {
    echo "🔄 Requesting re-review..."
    
    if command -v gh &> /dev/null; then
        gh pr review --request-changes || gh pr review --approve
        echo "✅ Re-review requested"
    else
        echo "ℹ️  Manually request re-review in PR interface"
    fi
}
```

## Phase 4: Integration & Deployment

**Pre-Merge Validation:**
```bash
pre_merge_validation() {
    echo "🔍 Final pre-merge validation..."
    
    current_branch=$(get_current_branch)
    
    # 1. Ensure branch is up to date
    git fetch origin main
    behind_count=$(git rev-list --count "$current_branch"..origin/main)
    
    if [ "$behind_count" -gt 0 ]; then
        echo "⚠️  Branch is $behind_count commits behind main"
        echo "Update required before merge"
        
        sync_with_main
    fi
    
    # 2. Final test run
    echo "🧪 Running final test suite..."
    if ! run_tests; then
        echo "❌ Tests must pass before merge!"
        exit 1
    fi
    
    # 3. Check for merge conflicts
    merge_base=$(git merge-base origin/main "$current_branch")
    if git merge-tree "$merge_base" origin/main "$current_branch" | grep -q "<<<<<<< "; then
        echo "❌ Merge conflicts detected! Resolve before merge."
        exit 1
    fi
    
    # 4. Verify CI status
    if command -v gh &> /dev/null; then
        ci_status=$(gh pr checks --json state -q '.[].state' | grep -v success | wc -l)
        if [ "$ci_status" -gt 0 ]; then
            echo "❌ CI checks must pass before merge!"
            gh pr checks
            exit 1
        fi
    fi
    
    echo "✅ Pre-merge validation passed"
}

merge_feature() {
    echo "🎯 Merging feature to main..."
    
    current_branch=$(get_current_branch)
    
    # Final validation
    pre_merge_validation
    
    # Merge strategy selection
    echo "Select merge strategy:"
    echo "1) Squash merge (recommended for features)"
    echo "2) Merge commit (preserve history)"
    echo "3) Rebase merge (linear history)"
    
    read -p "Choice (1-3): " merge_strategy
    
    case $merge_strategy in
        1) squash_merge ;;
        2) merge_commit ;;
        3) rebase_merge ;;
        *) echo "Invalid choice, defaulting to squash merge"; squash_merge ;;
    esac
    
    # Post-merge cleanup
    post_merge_cleanup
}

squash_merge() {
    current_branch=$(get_current_branch)
    
    # Generate squash commit message
    ticket=$(echo "$current_branch" | grep -oE '[A-Z]+-[0-9]+' | head -1)
    description=$(echo "$current_branch" | sed 's/feature\///; s/[A-Z]*-[0-9]*-//' | tr '-' ' ')
    
    squash_message="feat: ${description}

$(git log --oneline origin/main..HEAD | sed 's/^[a-f0-9]* /- /')

Closes: $ticket
$(if [ -f FEATURE.md ]; then echo "Feature documentation: FEATURE.md"; fi)"
    
    # Perform squash merge
    git checkout main
    git pull origin main
    git merge --squash "$current_branch"
    git commit -m "$squash_message"
    
    echo "✅ Squash merge completed"
}

merge_commit() {
    current_branch=$(get_current_branch)
    
    git checkout main
    git pull origin main
    git merge --no-ff "$current_branch" -m "Merge $current_branch

Feature: $(echo "$current_branch" | sed 's/feature\///; s/-/ /g')
$(if [ -f FEATURE.md ]; then echo "Documentation: FEATURE.md"; fi)"
    
    echo "✅ Merge commit completed"
}

rebase_merge() {
    current_branch=$(get_current_branch)
    
    # Rebase onto main
    git rebase origin/main
    
    # Fast-forward merge
    git checkout main
    git pull origin main
    git merge --ff-only "$current_branch"
    
    echo "✅ Rebase merge completed"
}

post_merge_cleanup() {
    current_branch=$(get_current_branch)
    feature_branch="$current_branch"
    
    # Switch to main if not already there
    if [[ "$current_branch" != "main" ]]; then
        git checkout main
    fi
    
    # Push main
    git push origin main
    
    # Delete local feature branch
    git branch -d "$feature_branch"
    
    # Delete remote feature branch
    git push origin --delete "$feature_branch"
    
    # Close PR if using GitHub CLI
    if command -v gh &> /dev/null; then
        gh pr close "$feature_branch" || echo "PR may already be closed"
    fi
    
    # Clean up feature documentation
    if [ -f FEATURE.md ]; then
        rm FEATURE.md
        git add FEATURE.md
        git commit -m "chore: remove feature documentation after merge"
        git push origin main
    fi
    
    echo "✅ Post-merge cleanup completed"
    echo "🎉 Feature successfully integrated!"
}
```

## Error Recovery Procedures

**Common Issues & Solutions:**

1. **Merge Conflicts**
   ```bash
   resolve_merge_conflicts() {
       echo "🔧 Resolving merge conflicts..."
       
       # Show conflicted files
       git status --porcelain | grep "^UU" | cut -c4-
       
       echo "Resolve conflicts in your editor, then:"
       echo "1. git add <resolved-files>"
       echo "2. git commit (or git rebase --continue)"
       
       read -p "Press Enter when conflicts are resolved..."
       
       # Verify resolution
       if git status --porcelain | grep -q "^UU"; then
           echo "❌ Conflicts still exist!"
           exit 1
       fi
       
       echo "✅ Conflicts resolved"
   }
   ```

2. **Failed CI Checks**
   ```bash
   fix_ci_failures() {
       echo "🔧 Addressing CI failures..."
       
       if command -v gh &> /dev/null; then
           gh run view --log-failed
       fi
       
       echo "Common CI issues:"
       echo "- Test failures"
       echo "- Linting errors"
       echo "- Build failures"
       echo "- Security vulnerabilities"
       
       read -p "Fix issues and press Enter to continue..."
       
       # Re-run validation
       quality_checkpoint
   }
   ```

3. **Large Feature Breakdown**
   ```bash
   break_down_feature() {
       echo "🔧 Breaking down large feature..."
       
       current_branch=$(get_current_branch)
       
       echo "Create sub-features:"
       echo "1. Identify logical components"
       echo "2. Create separate branches for each"
       echo "3. Merge components incrementally"
       
       read -p "Enter number of sub-features: " num_subfeatures
       
       for i in $(seq 1 "$num_subfeatures"); do
           read -p "Sub-feature $i name: " subfeature_name
           git checkout -b "feature/$(echo $current_branch | cut -d'-' -f2-)-part$i-$subfeature_name" "$current_branch"
           echo "Created: feature/$(echo $current_branch | cut -d'-' -f2-)-part$i-$subfeature_name"
       done
   }
   ```

## Team Collaboration Patterns

**Multi-Developer Features:**
```bash
setup_collaborative_feature() {
    echo "👥 Setting up collaborative feature development..."
    
    current_branch=$(get_current_branch)
    
    # Create shared development branch
    git push -u origin "$current_branch"
    
    # Set up branch protection (if admin)
    if command -v gh &> /dev/null; then
        gh api repos/:owner/:repo/branches/"$current_branch"/protection \
            --method PUT \
            --field required_status_checks='{"strict":true,"contexts":[]}' \
            --field enforce_admins=false \
            --field required_pull_request_reviews='{"required_approving_review_count":1}' \
            --field restrictions=null
    fi
    
    # Document collaboration guidelines
    cat >> FEATURE.md << 'EOF'

## Collaboration Guidelines

### Development Process
1. Create sub-branches from this feature branch: `feature/TICKET-123-component-name`
2. Make small, focused PRs to this feature branch
3. Keep feature branch synced with main regularly
4. Communicate changes in team chat

### Branch Naming
- `feature/TICKET-123-backend-api` - Backend components
- `feature/TICKET-123-frontend-ui` - Frontend components  
- `feature/TICKET-123-tests` - Test additions
- `feature/TICKET-123-docs` - Documentation

### Code Review
- All changes require at least one approval
- Original author merges approved PRs
- Run full test suite before final integration
EOF
    
    echo "✅ Collaborative feature setup complete"
}
```

## Integration with CI/CD

**Automated Quality Gates:**
```bash
setup_feature_automation() {
    echo "🤖 Setting up feature automation..."
    
    # GitHub Actions integration
    if [ -d .github/workflows ]; then
        cat > .github/workflows/feature-validation.yml << 'EOF'
name: Feature Validation

on:
  push:
    branches: [ 'feature/**' ]
  pull_request:
    branches: [ main ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup environment
      run: |
        # Setup language environment
    - name: Install dependencies
      run: |
        # Install dependencies
    - name: Run linters
      run: |
        # Run linting
    - name: Run tests
      run: |
        # Run test suite
    - name: Check coverage
      run: |
        # Check code coverage
    - name: Security scan
      run: |
        # Run security checks
EOF
    fi
    
    echo "✅ Feature automation configured"
}
```

**Feature Flags Integration:**
```bash
setup_feature_flags() {
    echo "🚩 Setting up feature flags..."
    
    read -p "Feature flag name: " flag_name
    
    # Add feature flag configuration
    echo "Feature flag: $flag_name"
    echo "- Enables gradual rollout"
    echo "- Allows quick rollback"
    echo "- Supports A/B testing"
    
    # Document feature flag usage
    cat >> FEATURE.md << EOF

## Feature Flag

**Flag Name:** \`$flag_name\`

### Usage
\`\`\`javascript
if (featureFlags.isEnabled('$flag_name')) {
    // New feature code
} else {
    // Fallback/existing code
}
\`\`\`

### Rollout Strategy
1. Enable for internal users (5%)
2. Enable for beta users (25%)
3. Full rollout (100%)

### Monitoring
- Track user engagement metrics
- Monitor error rates
- Measure performance impact
EOF
    
    echo "✅ Feature flag documentation added"
}
```

## Best Practices Summary

1. **Planning Phase**
   - Clear acceptance criteria
   - Proper branch naming
   - Documentation setup

2. **Development Phase**
   - Regular main syncing
   - Small, focused commits
   - Continuous testing

3. **Review Phase**
   - Comprehensive quality checks
   - Responsive feedback handling
   - Documentation updates

4. **Integration Phase**
   - Final validation
   - Strategic merge approach
   - Complete cleanup

## Workflow Summary

The feature workflow ensures:
- ✅ Structured feature development lifecycle
- ✅ Quality gates at every phase
- ✅ Collaborative development support
- ✅ Automated integration with CI/CD
- ✅ Comprehensive error recovery
- ✅ Team communication and documentation

Remember: **Great features are built through disciplined process, not just good code!**