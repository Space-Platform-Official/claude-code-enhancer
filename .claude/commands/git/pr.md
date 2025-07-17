---
allowed-tools: all
description: Comprehensive pull request management with intelligent workflow automation and quality gates
---

# Smart Pull Request Command

⚡⚡⚡ Execute comprehensive pull request operations with intelligent workflow automation, quality gates, and collaborative development support.

**Usage:** `/git/pr $ARGUMENTS`

## 🚨 MANDATORY PR WORKFLOW INTELLIGENCE 🚨

**PULL REQUESTS ARE THE GATEWAY TO PRODUCTION!**

When you run `/git/pr`, you MUST:

1. **VALIDATE** - Ensure code quality before creating PRs
2. **AUTOMATE** - Streamline PR creation with intelligent templating
3. **COLLABORATE** - Facilitate effective code review processes
4. **INTEGRATE** - Manage safe merging with comprehensive checks

## Core PR Operations

**Primary Actions:**
- `create` - Create new pull request with intelligent analysis
- `review` - Review existing pull requests with quality insights
- `merge` - Safely merge PR with validation gates
- `status` - Check PR status and next actions
- `update` - Update PR with latest changes
- `close` - Close PR with proper cleanup

## Smart PR Creation

**Intelligent PR Creation Process:**
```bash
# Create PR with comprehensive analysis
create_pull_request() {
    echo "🔄 Creating intelligent pull request..."
    
    # Pre-creation validation
    validate_pr_readiness
    
    # Branch analysis
    analyze_branch_changes
    
    # Generate PR content
    generate_pr_template
    
    # Create PR with GitHub/GitLab integration
    execute_pr_creation
    
    # Post-creation setup
    setup_pr_automation
}

validate_pr_readiness() {
    echo "🔍 Validating PR readiness..."
    
    current_branch=$(get_current_branch)
    
    # Check protected branch
    if is_protected_branch "$current_branch"; then
        echo "❌ Cannot create PR from protected branch: $current_branch"
        echo "💡 Create feature branch: git checkout -b feature/your-feature"
        exit 1
    fi
    
    # Ensure branch is pushed
    if ! git rev-parse --abbrev-ref "$current_branch"@{upstream} &>/dev/null; then
        echo "📤 Pushing branch to remote..."
        git push -u origin "$current_branch"
    fi
    
    # Sync check
    local divergence=$(get_branch_divergence)
    local behind=$(echo "$divergence" | cut -d' ' -f2 | cut -d':' -f2)
    
    if [ "$behind" -gt 0 ]; then
        echo "⚠️  Branch is $behind commits behind. Syncing recommended."
        read -p "Auto-sync with main? (y/n): " should_sync
        if [[ "$should_sync" == "y" ]]; then
            sync_with_main
        fi
    fi
    
    # Quality gates
    echo "🔍 Running quality gates..."
    
    # 1. Tests must pass
    if ! run_tests; then
        echo "❌ Tests failing - fix before creating PR"
        exit 1
    fi
    
    # 2. Linting must pass
    if ! run_linters; then
        echo "❌ Linting issues - fix before creating PR"
        exit 1
    fi
    
    # 3. No sensitive data
    if ! check_sensitive_data; then
        echo "❌ Sensitive data detected - remove before creating PR"
        exit 1
    fi
    
    # 4. Commit message validation
    validate_recent_commits
    
    echo "✅ PR readiness validation passed"
}

analyze_branch_changes() {
    echo "📊 Analyzing branch changes..."
    
    current_branch=$(get_current_branch)
    base_branch=${1:-main}
    
    # Get change statistics
    local files_changed=$(git diff --name-only "$base_branch"..."$current_branch" | wc -l)
    local additions=$(git diff --stat "$base_branch"..."$current_branch" | tail -1 | grep -oE '[0-9]+ insertion' | cut -d' ' -f1 || echo 0)
    local deletions=$(git diff --stat "$base_branch"..."$current_branch" | tail -1 | grep -oE '[0-9]+ deletion' | cut -d' ' -f1 || echo 0)
    
    echo "📈 Change Summary:"
    echo "  Files changed: $files_changed"
    echo "  Additions: $additions"
    echo "  Deletions: $deletions"
    
    # Analyze change types
    echo "📁 File Type Analysis:"
    git diff --name-only "$base_branch"..."$current_branch" | \
        grep -E '\.[a-zA-Z0-9]+$' | \
        sed 's/.*\.//' | \
        sort | uniq -c | sort -rn | head -5
    
    # Identify potential impact
    analyze_change_impact "$base_branch" "$current_branch"
    
    # Check for large changes
    if [ "$files_changed" -gt 20 ]; then
        echo "⚠️  Large PR detected ($files_changed files)"
        echo "💡 Consider breaking into smaller PRs"
    fi
}

analyze_change_impact() {
    local base_branch=$1
    local current_branch=$2
    
    echo "🎯 Impact Analysis:"
    
    # Check for breaking changes
    if git diff "$base_branch"..."$current_branch" | grep -E "^\-.*public|^\-.*export|^\-.*interface"; then
        echo "  ⚠️  Potential breaking changes detected"
    fi
    
    # Check for new dependencies
    if git diff "$base_branch"..."$current_branch" -- package.json requirements.txt Cargo.toml go.mod | grep -E "^\+.*\""; then
        echo "  📦 New dependencies added"
    fi
    
    # Check for database changes
    if git diff --name-only "$base_branch"..."$current_branch" | grep -E "(migration|schema|model)"; then
        echo "  🗃️  Database changes detected"
    fi
    
    # Check for configuration changes
    if git diff --name-only "$base_branch"..."$current_branch" | grep -E "(config|\.env|\.yml|\.yaml)"; then
        echo "  ⚙️  Configuration changes detected"
    fi
}

generate_pr_template() {
    echo "📝 Generating PR template..."
    
    current_branch=$(get_current_branch)
    base_branch=${1:-main}
    
    # Extract feature information
    local ticket=$(echo "$current_branch" | grep -oE '[A-Z]+-[0-9]+|#[0-9]+' | head -1)
    local feature_name=$(echo "$current_branch" | sed 's/feature\///; s/[A-Z]*-[0-9]*-//; s/#[0-9]*-//' | tr '-' ' ')
    
    # Generate title
    if [ -n "$ticket" ]; then
        pr_title="$ticket: ${feature_name^}"
    else
        pr_title="${feature_name^}"
    fi
    
    # Generate comprehensive body
    pr_body=$(cat << EOF
## Summary

$(generate_change_summary "$base_branch" "$current_branch")

## Changes Made

$(git log --oneline "$base_branch".."$current_branch" | sed 's/^[a-f0-9]* /- /' | head -10)

## Type of Change

$(determine_change_type "$base_branch" "$current_branch")

## Testing

$(generate_testing_checklist)

## Quality Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Tests added/updated and passing
- [ ] Documentation updated
- [ ] No new security vulnerabilities
- [ ] Performance impact assessed
- [ ] Breaking changes documented

## Deployment Notes

$(generate_deployment_notes)

## Screenshots/Demo

<!-- Add screenshots or demo links if applicable -->

## Related Issues

$(extract_related_issues "$current_branch")

---

🤖 Generated with Claude Code PR Assistant
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)
    
    # Store generated content
    echo "$pr_title" > /tmp/pr_title
    echo "$pr_body" > /tmp/pr_body
}

generate_change_summary() {
    local base_branch=$1
    local current_branch=$2
    
    # Analyze commits for summary
    local commit_messages=$(git log --format="%s" "$base_branch".."$current_branch")
    
    # Extract common themes
    if echo "$commit_messages" | grep -qi "feat"; then
        echo "This PR introduces new functionality:"
    elif echo "$commit_messages" | grep -qi "fix"; then
        echo "This PR fixes issues:"
    elif echo "$commit_messages" | grep -qi "refactor"; then
        echo "This PR refactors existing code:"
    else
        echo "This PR includes various improvements:"
    fi
    
    # List key changes
    echo "$commit_messages" | head -3 | sed 's/^/- /'
}

determine_change_type() {
    local base_branch=$1
    local current_branch=$2
    
    local changes=$(git log --format="%s" "$base_branch".."$current_branch" | tr '[:upper:]' '[:lower:]')
    
    echo "- [ ] Bug fix (non-breaking change that fixes an issue)"
    
    if echo "$changes" | grep -q "feat"; then
        echo "- [x] New feature (non-breaking change that adds functionality)"
    else
        echo "- [ ] New feature (non-breaking change that adds functionality)"
    fi
    
    if echo "$changes" | grep -q "breaking"; then
        echo "- [x] Breaking change (fix or feature that would cause existing functionality to not work as expected)"
    else
        echo "- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)"
    fi
    
    if echo "$changes" | grep -q "docs"; then
        echo "- [x] Documentation update"
    else
        echo "- [ ] Documentation update"
    fi
}

generate_testing_checklist() {
    echo "- [ ] Unit tests pass"
    echo "- [ ] Integration tests pass"
    echo "- [ ] E2E tests pass (if applicable)"
    echo "- [ ] Manual testing completed"
    echo "- [ ] Cross-browser testing (if frontend changes)"
    echo "- [ ] Performance testing (if performance-critical changes)"
}

generate_deployment_notes() {
    current_branch=$(get_current_branch)
    
    if git diff --name-only main..."$current_branch" | grep -E "(migration|schema)"; then
        echo "⚠️  Database migrations required"
    fi
    
    if git diff --name-only main..."$current_branch" | grep -E "(config|\.env)"; then
        echo "⚠️  Configuration changes required"
    fi
    
    if git diff --name-only main..."$current_branch" | grep -E "(package\.json|requirements\.txt)"; then
        echo "⚠️  Dependency updates required"
    fi
    
    echo "✅ Standard deployment process"
}

extract_related_issues() {
    local branch=$1
    
    # Extract from branch name
    local ticket=$(echo "$branch" | grep -oE '[A-Z]+-[0-9]+|#[0-9]+' | head -1)
    if [ -n "$ticket" ]; then
        echo "Closes $ticket"
    fi
    
    # Extract from commit messages
    git log --format="%s %b" main.."$branch" | grep -oE "(closes|fixes|resolves) #[0-9]+" | head -3
}

execute_pr_creation() {
    echo "🚀 Creating pull request..."
    
    local pr_title=$(cat /tmp/pr_title)
    local pr_body=$(cat /tmp/pr_body)
    local current_branch=$(get_current_branch)
    
    # GitHub CLI integration
    if command -v gh &> /dev/null; then
        echo "📱 Using GitHub CLI..."
        
        # Create PR
        if gh pr create --title "$pr_title" --body "$pr_body" --assignee @me; then
            local pr_url=$(gh pr view --json url -q .url)
            echo "✅ Pull request created: $pr_url"
            
            # Store PR info
            echo "$pr_url" > /tmp/pr_url
            
            # Set up PR automation
            setup_pr_labels
            setup_pr_reviewers
            
        else
            echo "❌ Failed to create PR with GitHub CLI"
            exit 1
        fi
        
    # GitLab CLI integration
    elif command -v glab &> /dev/null; then
        echo "📱 Using GitLab CLI..."
        
        if glab mr create --title "$pr_title" --description "$pr_body" --assignee @me; then
            echo "✅ Merge request created"
        else
            echo "❌ Failed to create MR with GitLab CLI"
            exit 1
        fi
        
    else
        echo "📝 Manual PR creation required:"
        echo "Title: $pr_title"
        echo "Body: (template generated - see /tmp/pr_body)"
        echo ""
        echo "Copy template and create PR manually in your git platform"
        cat /tmp/pr_body
    fi
}

setup_pr_labels() {
    echo "🏷️  Setting up PR labels..."
    
    current_branch=$(get_current_branch)
    
    # Auto-label based on branch type
    if echo "$current_branch" | grep -q "feature/"; then
        gh pr edit --add-label "feature"
    elif echo "$current_branch" | grep -q "bugfix/"; then
        gh pr edit --add-label "bugfix"
    elif echo "$current_branch" | grep -q "hotfix/"; then
        gh pr edit --add-label "hotfix,priority:high"
    fi
    
    # Label based on file changes
    if git diff --name-only main..."$current_branch" | grep -E "\.(js|ts|jsx|tsx)$"; then
        gh pr edit --add-label "frontend"
    fi
    
    if git diff --name-only main..."$current_branch" | grep -E "(api|server|backend)"; then
        gh pr edit --add-label "backend"
    fi
    
    if git diff --name-only main..."$current_branch" | grep -E "(test|spec)"; then
        gh pr edit --add-label "tests"
    fi
    
    if git diff --name-only main..."$current_branch" | grep -E "(docs|README|\.md)"; then
        gh pr edit --add-label "documentation"
    fi
}

setup_pr_reviewers() {
    echo "👥 Setting up PR reviewers..."
    
    # Get team members from CODEOWNERS if available
    if [ -f .github/CODEOWNERS ]; then
        local owners=$(grep -E "^\*|^/" .github/CODEOWNERS | head -3 | sed 's/.*@//' | tr '\n' ' ')
        if [ -n "$owners" ]; then
            gh pr edit --add-reviewer "$owners"
        fi
    fi
    
    # Request review from recent collaborators
    local recent_collaborators=$(git log --format="%an" --since="30 days ago" main | sort | uniq -c | sort -rn | head -3 | awk '{print $2}' | tr '\n' ' ')
    echo "💡 Consider requesting reviews from: $recent_collaborators"
}

setup_pr_automation() {
    echo "🤖 Setting up PR automation..."
    
    # Enable auto-merge if configured
    if git config --get pr.automerge &>/dev/null; then
        gh pr merge --auto --squash
        echo "✅ Auto-merge enabled"
    fi
    
    # Set up status checks
    echo "📊 Monitoring CI status..."
    
    # Enable discussions if configured
    if git config --get pr.discussions &>/dev/null; then
        echo "💬 PR discussions enabled"
    fi
}
```

## Smart PR Review

**Intelligent Review Process:**
```bash
# Review PR with comprehensive analysis
review_pull_request() {
    echo "👀 Starting intelligent PR review..."
    
    # Get PR information
    get_pr_info
    
    # Analyze PR changes
    analyze_pr_changes
    
    # Run quality checks
    run_pr_quality_checks
    
    # Generate review insights
    generate_review_insights
    
    # Interactive review process
    interactive_review_process
}

get_pr_info() {
    echo "📋 Gathering PR information..."
    
    if command -v gh &> /dev/null; then
        # Get current PR info
        local pr_info=$(gh pr view --json number,title,author,state,reviewDecision,mergeable)
        
        echo "PR Details:"
        echo "$pr_info" | jq -r '"  Number: #\(.number)"'
        echo "$pr_info" | jq -r '"  Title: \(.title)"'
        echo "$pr_info" | jq -r '"  Author: \(.author.login)"'
        echo "$pr_info" | jq -r '"  State: \(.state)"'
        echo "$pr_info" | jq -r '"  Review Status: \(.reviewDecision // "PENDING")"'
        echo "$pr_info" | jq -r '"  Mergeable: \(.mergeable)"'
        
        # Store for later use
        echo "$pr_info" > /tmp/pr_info
    else
        echo "💡 Use GitHub CLI for enhanced review features"
    fi
}

analyze_pr_changes() {
    echo "🔍 Analyzing PR changes..."
    
    # Get PR diff
    if command -v gh &> /dev/null; then
        local pr_number=$(gh pr view --json number -q .number)
        gh pr diff "$pr_number" > /tmp/pr_diff
        
        # Analyze diff
        local files_changed=$(gh pr view --json files -q '.files | length')
        local additions=$(gh pr view --json additions -q .additions)
        local deletions=$(gh pr view --json deletions -q .deletions)
        
        echo "📊 Change Statistics:"
        echo "  Files: $files_changed"
        echo "  Additions: $additions"
        echo "  Deletions: $deletions"
        
        # Complexity analysis
        if [ "$files_changed" -gt 15 ]; then
            echo "  ⚠️  High complexity (many files changed)"
        fi
        
        if [ "$additions" -gt 500 ]; then
            echo "  ⚠️  Large changes (consider breaking down)"
        fi
    fi
    
    # Identify change patterns
    identify_change_patterns
}

identify_change_patterns() {
    echo "🎯 Identifying change patterns..."
    
    if [ -f /tmp/pr_diff ]; then
        # Check for common patterns
        if grep -q "TODO\|FIXME\|XXX" /tmp/pr_diff; then
            echo "  ⚠️  TODO/FIXME comments found"
        fi
        
        if grep -q "console\.log\|print(\|println!" /tmp/pr_diff; then
            echo "  ⚠️  Debug statements detected"
        fi
        
        if grep -q "password\|secret\|key" /tmp/pr_diff; then
            echo "  🔐 Potential sensitive data"
        fi
        
        if grep -q "^\+.*test\|^\+.*spec" /tmp/pr_diff; then
            echo "  ✅ Tests added/modified"
        fi
        
        if grep -q "^\+.*doc\|^\+.*README" /tmp/pr_diff; then
            echo "  📚 Documentation updated"
        fi
    fi
}

run_pr_quality_checks() {
    echo "🔍 Running PR quality checks..."
    
    # Check CI status
    if command -v gh &> /dev/null; then
        local ci_status=$(gh pr checks --json state,name,conclusion)
        
        if [ -n "$ci_status" ]; then
            echo "🏗️  CI Status:"
            echo "$ci_status" | jq -r '.[] | "  \(.name): \(.conclusion // .state)"'
            
            # Check for failures
            local failures=$(echo "$ci_status" | jq -r '.[] | select(.conclusion == "failure") | .name')
            if [ -n "$failures" ]; then
                echo "  ❌ Failed checks: $failures"
            fi
        fi
    fi
    
    # Run local quality checks
    echo "🔍 Local Quality Checks:"
    
    # Lint changed files
    if command -v gh &> /dev/null; then
        local changed_files=$(gh pr view --json files -q '.files[].filename')
        if [ -n "$changed_files" ]; then
            echo "  🧹 Linting changed files..."
            echo "$changed_files" | while read -r file; do
                if [ -f "$file" ]; then
                    run_file_linter "$file"
                fi
            done
        fi
    fi
    
    # Security check
    echo "  🔐 Security scan..."
    check_sensitive_data
}

run_file_linter() {
    local file=$1
    local ext="${file##*.}"
    
    case "$ext" in
        js|jsx|ts|tsx)
            if command -v eslint &> /dev/null; then
                eslint "$file" --max-warnings 0
            fi
            ;;
        py)
            if command -v flake8 &> /dev/null; then
                flake8 "$file"
            fi
            ;;
        go)
            if command -v golangci-lint &> /dev/null; then
                golangci-lint run "$file"
            fi
            ;;
        rs)
            if command -v clippy &> /dev/null; then
                cargo clippy --manifest-path "$(dirname "$file")/Cargo.toml"
            fi
            ;;
    esac
}

generate_review_insights() {
    echo "💡 Generating review insights..."
    
    # Analyze code complexity
    if [ -f /tmp/pr_diff ]; then
        local cyclomatic_complexity=$(grep -c "if\|while\|for\|case\|catch" /tmp/pr_diff)
        if [ "$cyclomatic_complexity" -gt 10 ]; then
            echo "  ⚠️  High cyclomatic complexity detected"
        fi
        
        # Check for code duplication
        local duplicate_lines=$(sort /tmp/pr_diff | uniq -d | wc -l)
        if [ "$duplicate_lines" -gt 5 ]; then
            echo "  ⚠️  Potential code duplication"
        fi
    fi
    
    # Performance insights
    if [ -f /tmp/pr_diff ]; then
        if grep -q "SELECT\|INSERT\|UPDATE\|DELETE" /tmp/pr_diff; then
            echo "  🗃️  Database operations detected - review for performance"
        fi
        
        if grep -q "fetch\|axios\|request\|http" /tmp/pr_diff; then
            echo "  🌐 HTTP requests detected - review for error handling"
        fi
    fi
}

interactive_review_process() {
    echo "🎯 Interactive review process..."
    
    while true; do
        echo ""
        echo "Review Actions:"
        echo "1) View PR details"
        echo "2) View file changes"
        echo "3) Add review comment"
        echo "4) Approve PR"
        echo "5) Request changes"
        echo "6) Check CI status"
        echo "7) Exit review"
        
        read -p "Choose action (1-7): " action
        
        case $action in
            1) show_pr_details ;;
            2) show_file_changes ;;
            3) add_review_comment ;;
            4) approve_pr ;;
            5) request_changes ;;
            6) check_ci_status ;;
            7) break ;;
            *) echo "Invalid choice" ;;
        esac
    done
}

show_pr_details() {
    if command -v gh &> /dev/null; then
        gh pr view
    else
        echo "💡 Use GitHub CLI for detailed PR view"
    fi
}

show_file_changes() {
    if command -v gh &> /dev/null; then
        local files=$(gh pr view --json files -q '.files[].filename')
        echo "Changed files:"
        echo "$files" | nl
        
        read -p "Enter file number to view: " file_num
        local selected_file=$(echo "$files" | sed -n "${file_num}p")
        
        if [ -n "$selected_file" ]; then
            gh pr diff --name-only | grep -q "$selected_file" && gh pr diff "$selected_file"
        fi
    else
        echo "💡 Use GitHub CLI for file change viewing"
    fi
}

add_review_comment() {
    echo "💬 Adding review comment..."
    
    if command -v gh &> /dev/null; then
        read -p "Comment: " comment
        gh pr comment --body "$comment"
        echo "✅ Comment added"
    else
        echo "💡 Add comment manually in PR interface"
    fi
}

approve_pr() {
    echo "✅ Approving PR..."
    
    if command -v gh &> /dev/null; then
        read -p "Approval message (optional): " approval_msg
        if [ -n "$approval_msg" ]; then
            gh pr review --approve --body "$approval_msg"
        else
            gh pr review --approve
        fi
        echo "✅ PR approved"
    else
        echo "💡 Approve manually in PR interface"
    fi
}

request_changes() {
    echo "🔄 Requesting changes..."
    
    if command -v gh &> /dev/null; then
        read -p "Change request message: " change_msg
        gh pr review --request-changes --body "$change_msg"
        echo "✅ Changes requested"
    else
        echo "💡 Request changes manually in PR interface"
    fi
}

check_ci_status() {
    echo "🏗️  Checking CI status..."
    
    if command -v gh &> /dev/null; then
        gh pr checks
    else
        echo "💡 Check CI manually in PR interface"
    fi
}
```

## Smart PR Merge

**Safe Merge Process:**
```bash
# Merge PR with comprehensive safety checks
merge_pull_request() {
    echo "🎯 Starting safe PR merge process..."
    
    # Pre-merge validation
    pre_merge_validation
    
    # Choose merge strategy
    select_merge_strategy
    
    # Execute merge
    execute_merge
    
    # Post-merge cleanup
    post_merge_cleanup
}

pre_merge_validation() {
    echo "🔍 Pre-merge validation..."
    
    if command -v gh &> /dev/null; then
        # Check PR status
        local pr_info=$(gh pr view --json mergeable,reviewDecision,state)
        local mergeable=$(echo "$pr_info" | jq -r .mergeable)
        local review_decision=$(echo "$pr_info" | jq -r .reviewDecision)
        local state=$(echo "$pr_info" | jq -r .state)
        
        echo "🔍 PR Status Check:"
        echo "  Mergeable: $mergeable"
        echo "  Review Decision: $review_decision"
        echo "  State: $state"
        
        # Validation checks
        if [ "$mergeable" != "MERGEABLE" ]; then
            echo "❌ PR is not mergeable"
            echo "Common issues: conflicts, failed checks, missing reviews"
            exit 1
        fi
        
        if [ "$review_decision" != "APPROVED" ]; then
            echo "⚠️  PR not approved yet"
            read -p "Continue anyway? (y/n): " force_merge
            if [[ "$force_merge" != "y" ]]; then
                exit 1
            fi
        fi
        
        if [ "$state" != "OPEN" ]; then
            echo "❌ PR is not open"
            exit 1
        fi
    fi
    
    # Check CI status
    echo "🏗️  Checking CI status..."
    if command -v gh &> /dev/null; then
        local failed_checks=$(gh pr checks --json state,conclusion | jq -r '.[] | select(.conclusion == "failure") | .name')
        if [ -n "$failed_checks" ]; then
            echo "❌ CI checks failed: $failed_checks"
            read -p "Continue despite failures? (y/n): " force_ci
            if [[ "$force_ci" != "y" ]]; then
                exit 1
            fi
        fi
    fi
    
    # Branch protection check
    check_branch_protection
    
    echo "✅ Pre-merge validation passed"
}

check_branch_protection() {
    echo "🛡️  Checking branch protection..."
    
    if command -v gh &> /dev/null; then
        local protection=$(gh api repos/:owner/:repo/branches/main/protection 2>/dev/null)
        if [ -n "$protection" ]; then
            echo "  🛡️  Branch protection enabled"
            
            # Check required checks
            local required_checks=$(echo "$protection" | jq -r '.required_status_checks.contexts[]? // empty')
            if [ -n "$required_checks" ]; then
                echo "  ✅ Required checks: $required_checks"
            fi
            
            # Check review requirements
            local required_reviews=$(echo "$protection" | jq -r '.required_pull_request_reviews.required_approving_review_count // 0')
            if [ "$required_reviews" -gt 0 ]; then
                echo "  👥 Required reviews: $required_reviews"
            fi
        fi
    fi
}

select_merge_strategy() {
    echo "🔄 Selecting merge strategy..."
    
    echo "Available merge strategies:"
    echo "1) Squash and merge (recommended for features)"
    echo "2) Create a merge commit (preserve history)"
    echo "3) Rebase and merge (linear history)"
    
    read -p "Choose strategy (1-3): " strategy
    
    case $strategy in
        1) MERGE_STRATEGY="squash" ;;
        2) MERGE_STRATEGY="merge" ;;
        3) MERGE_STRATEGY="rebase" ;;
        *) echo "Invalid choice, defaulting to squash"; MERGE_STRATEGY="squash" ;;
    esac
    
    echo "✅ Selected strategy: $MERGE_STRATEGY"
}

execute_merge() {
    echo "🚀 Executing merge..."
    
    if command -v gh &> /dev/null; then
        case $MERGE_STRATEGY in
            squash)
                gh pr merge --squash --delete-branch
                ;;
            merge)
                gh pr merge --merge --delete-branch
                ;;
            rebase)
                gh pr merge --rebase --delete-branch
                ;;
        esac
        
        if [ $? -eq 0 ]; then
            echo "✅ PR merged successfully"
        else
            echo "❌ Merge failed"
            exit 1
        fi
    else
        echo "💡 Manual merge required in PR interface"
        echo "Strategy: $MERGE_STRATEGY"
    fi
}

post_merge_cleanup() {
    echo "🧹 Post-merge cleanup..."
    
    # Update local main branch
    git checkout main
    git pull origin main
    
    # Delete local feature branch if exists
    local feature_branch=$(git branch --list | grep -E "feature/|bugfix/|hotfix/" | head -1 | xargs)
    if [ -n "$feature_branch" ]; then
        git branch -d "$feature_branch" 2>/dev/null || git branch -D "$feature_branch"
        echo "✅ Local branch deleted: $feature_branch"
    fi
    
    # Clean up remote tracking branches
    git remote prune origin
    
    # Update dependencies if needed
    if [ -f package.json ]; then
        npm install
    elif [ -f requirements.txt ]; then
        pip install -r requirements.txt
    elif [ -f Cargo.toml ]; then
        cargo build
    fi
    
    echo "✅ Post-merge cleanup completed"
}
```

## PR Status Intelligence

**Comprehensive Status Monitoring:**
```bash
# Get intelligent PR status
get_pr_status() {
    echo "📊 PR Status Intelligence Dashboard"
    echo "=================================="
    
    # Current PR context
    get_current_pr_context
    
    # All open PRs
    list_open_prs
    
    # PR health metrics
    analyze_pr_health
    
    # Team PR activity
    show_team_activity
    
    # Recommendations
    provide_pr_recommendations
}

get_current_pr_context() {
    echo "🎯 Current Branch PR Context:"
    echo "----------------------------"
    
    local current_branch=$(get_current_branch)
    echo "Current branch: $current_branch"
    
    if command -v gh &> /dev/null; then
        local pr_info=$(gh pr view --json number,title,state,reviewDecision,mergeable,checks 2>/dev/null)
        
        if [ -n "$pr_info" ]; then
            echo "PR Details:"
            echo "$pr_info" | jq -r '"  #\(.number): \(.title)"'
            echo "$pr_info" | jq -r '"  State: \(.state)"'
            echo "$pr_info" | jq -r '"  Review: \(.reviewDecision // "PENDING")"'
            echo "$pr_info" | jq -r '"  Mergeable: \(.mergeable)"'
            
            # Check status
            local checks=$(echo "$pr_info" | jq -r '.checks[]? // empty')
            if [ -n "$checks" ]; then
                echo "  Checks: $checks"
            fi
        else
            echo "  No PR found for current branch"
        fi
    fi
}

list_open_prs() {
    echo -e "\n📋 Open Pull Requests:"
    echo "---------------------"
    
    if command -v gh &> /dev/null; then
        local prs=$(gh pr list --state open --json number,title,author,reviewDecision,updatedAt)
        
        if [ -n "$prs" ]; then
            echo "$prs" | jq -r '.[] | "#\(.number) \(.title) by \(.author.login) - \(.reviewDecision // "PENDING")"'
        else
            echo "No open PRs"
        fi
    else
        echo "💡 Use GitHub CLI for PR listing"
    fi
}

analyze_pr_health() {
    echo -e "\n🏥 PR Health Analysis:"
    echo "---------------------"
    
    if command -v gh &> /dev/null; then
        local prs=$(gh pr list --state open --json number,createdAt,reviewDecision,mergeable,checks)
        
        if [ -n "$prs" ]; then
            local total_prs=$(echo "$prs" | jq length)
            local approved_prs=$(echo "$prs" | jq '[.[] | select(.reviewDecision == "APPROVED")] | length')
            local mergeable_prs=$(echo "$prs" | jq '[.[] | select(.mergeable == "MERGEABLE")] | length')
            local stale_prs=$(echo "$prs" | jq '[.[] | select((now - (.createdAt | fromdateiso8601)) > 604800)] | length')
            
            echo "Total PRs: $total_prs"
            echo "Approved: $approved_prs"
            echo "Mergeable: $mergeable_prs"
            echo "Stale (>1 week): $stale_prs"
            
            # Health score
            local health_score=$(( (approved_prs + mergeable_prs - stale_prs) * 100 / total_prs ))
            echo "Health Score: $health_score%"
            
            if [ "$health_score" -lt 70 ]; then
                echo "⚠️  PR health needs attention"
            fi
        fi
    fi
}

show_team_activity() {
    echo -e "\n👥 Team PR Activity:"
    echo "-------------------"
    
    if command -v gh &> /dev/null; then
        echo "Recent PR activity:"
        gh pr list --state all --limit 10 --json number,title,author,state,updatedAt | \
            jq -r '.[] | "\(.updatedAt | fromdateiso8601 | strftime("%m-%d")) #\(.number) \(.title) by \(.author.login) (\(.state))"' | \
            sort -r | head -5
    fi
}

provide_pr_recommendations() {
    echo -e "\n💡 PR Recommendations:"
    echo "---------------------"
    
    local current_branch=$(get_current_branch)
    
    # Check if current branch has PR
    if command -v gh &> /dev/null; then
        if gh pr view --json number &>/dev/null; then
            echo "1. Current branch has open PR"
            
            # Check PR status
            local pr_info=$(gh pr view --json reviewDecision,mergeable,checks)
            local review_decision=$(echo "$pr_info" | jq -r .reviewDecision)
            local mergeable=$(echo "$pr_info" | jq -r .mergeable)
            
            if [ "$review_decision" = "APPROVED" ] && [ "$mergeable" = "MERGEABLE" ]; then
                echo "   ✅ Ready to merge!"
            elif [ "$review_decision" = "CHANGES_REQUESTED" ]; then
                echo "   🔄 Address review feedback"
            elif [ "$review_decision" = "null" ]; then
                echo "   ⏳ Awaiting review"
            fi
            
            if [ "$mergeable" = "CONFLICTING" ]; then
                echo "   🔧 Resolve merge conflicts"
            fi
        else
            echo "1. Create PR for current branch"
            echo "   Command: /git/pr create"
        fi
    fi
    
    # Check for stale PRs
    if command -v gh &> /dev/null; then
        local stale_prs=$(gh pr list --state open --json number,title,updatedAt | \
            jq -r '.[] | select((now - (.updatedAt | fromdateiso8601)) > 604800) | "#\(.number) \(.title)"')
        
        if [ -n "$stale_prs" ]; then
            echo "2. Review stale PRs:"
            echo "$stale_prs" | head -3
        fi
    fi
    
    # Check for draft PRs
    if command -v gh &> /dev/null; then
        local draft_prs=$(gh pr list --state open --json number,title,isDraft | \
            jq -r '.[] | select(.isDraft == true) | "#\(.number) \(.title)"')
        
        if [ -n "$draft_prs" ]; then
            echo "3. Convert draft PRs to ready:"
            echo "$draft_prs" | head -3
        fi
    fi
}
```

## Advanced PR Operations

**PR Update and Maintenance:**
```bash
# Update PR with latest changes
update_pull_request() {
    echo "🔄 Updating pull request..."
    
    local current_branch=$(get_current_branch)
    
    # Sync with base branch
    sync_with_base
    
    # Update PR description if needed
    update_pr_description
    
    # Push updates
    push_pr_updates
    
    # Notify reviewers
    notify_reviewers_of_update
}

sync_with_base() {
    echo "🔄 Syncing with base branch..."
    
    local base_branch=${1:-main}
    local current_branch=$(get_current_branch)
    
    # Fetch latest
    git fetch origin "$base_branch"
    
    # Check for conflicts
    local conflicts=$(git merge-tree $(git merge-base "origin/$base_branch" "$current_branch") "origin/$base_branch" "$current_branch" | grep -c "<<<<<<< " || echo 0)
    
    if [ "$conflicts" -gt 0 ]; then
        echo "⚠️  Potential conflicts detected"
        echo "Choose sync strategy:"
        echo "1) Merge (creates merge commit)"
        echo "2) Rebase (linear history)"
        echo "3) Manual resolution"
        
        read -p "Choice (1-3): " sync_strategy
        
        case $sync_strategy in
            1) git merge "origin/$base_branch" ;;
            2) git rebase "origin/$base_branch" ;;
            3) echo "Resolve conflicts manually"; return ;;
        esac
    else
        # Clean rebase
        git rebase "origin/$base_branch"
    fi
    
    echo "✅ Sync completed"
}

update_pr_description() {
    echo "📝 Updating PR description..."
    
    if command -v gh &> /dev/null; then
        local current_body=$(gh pr view --json body -q .body)
        
        # Check if description needs updating
        if echo "$current_body" | grep -q "🤖 Generated with Claude Code"; then
            echo "🔄 Regenerating PR description..."
            
            # Regenerate description
            generate_pr_template
            local new_body=$(cat /tmp/pr_body)
            
            # Update PR
            gh pr edit --body "$new_body"
            echo "✅ PR description updated"
        else
            echo "ℹ️  PR description appears to be manually maintained"
        fi
    fi
}

push_pr_updates() {
    echo "📤 Pushing PR updates..."
    
    local current_branch=$(get_current_branch)
    
    # Push with force-with-lease for safety
    git push --force-with-lease origin "$current_branch"
    
    echo "✅ Updates pushed"
}

notify_reviewers_of_update() {
    echo "📢 Notifying reviewers..."
    
    if command -v gh &> /dev/null; then
        local reviewers=$(gh pr view --json reviewRequests -q '.reviewRequests[].login')
        
        if [ -n "$reviewers" ]; then
            gh pr comment --body "📝 PR updated with latest changes. Please review when ready.

Changes in this update:
$(git log --oneline @{u}..HEAD | head -5 | sed 's/^/- /')

🤖 Auto-notification from Claude Code"
            
            echo "✅ Reviewers notified"
        fi
    fi
}

# Close PR with cleanup
close_pull_request() {
    echo "🔒 Closing pull request..."
    
    if command -v gh &> /dev/null; then
        read -p "Reason for closing: " close_reason
        
        # Add closing comment
        gh pr comment --body "🔒 Closing PR: $close_reason

🤖 Closed with Claude Code"
        
        # Close PR
        gh pr close
        
        echo "✅ PR closed"
    else
        echo "💡 Close PR manually in interface"
    fi
    
    # Clean up local branch
    local current_branch=$(get_current_branch)
    if [[ "$current_branch" != "main" ]]; then
        git checkout main
        git branch -D "$current_branch"
        echo "✅ Local branch cleaned up"
    fi
}
```

## Agent Spawning Strategies

**Multi-Agent PR Operations:**
```bash
# Spawn agents for parallel PR operations
spawn_pr_agents() {
    echo "🤖 Spawning PR agents for parallel operations..."
    
    local operation=${1:-"comprehensive"}
    
    case $operation in
        "comprehensive")
            spawn_comprehensive_agents
            ;;
        "review")
            spawn_review_agents
            ;;
        "quality")
            spawn_quality_agents
            ;;
        "analysis")
            spawn_analysis_agents
            ;;
        *)
            echo "Unknown operation: $operation"
            ;;
    esac
}

spawn_comprehensive_agents() {
    echo "🔄 Spawning comprehensive PR agents..."
    
    echo "Agent 1: PR Analysis & Quality Checks"
    echo "Agent 2: CI/CD Integration & Status Monitoring"
    echo "Agent 3: Review Management & Collaboration"
    echo "Agent 4: Documentation & Template Generation"
    
    # Simulate agent coordination
    {
        echo "🤖 Agent 1: Analyzing PR changes and running quality checks..."
        analyze_pr_changes
        run_pr_quality_checks
    } &
    
    {
        echo "🤖 Agent 2: Monitoring CI/CD and integration status..."
        check_ci_status
        check_integration_status
    } &
    
    {
        echo "🤖 Agent 3: Managing review process..."
        setup_pr_reviewers
        monitor_review_status
    } &
    
    {
        echo "🤖 Agent 4: Generating documentation..."
        generate_pr_template
        update_pr_documentation
    } &
    
    wait
    echo "✅ All agents completed"
}

spawn_review_agents() {
    echo "👥 Spawning review-focused agents..."
    
    echo "Agent 1: Code Quality Review"
    echo "Agent 2: Security Review"
    echo "Agent 3: Performance Review"
    echo "Agent 4: Documentation Review"
    
    # Coordinate review agents
    coordinate_review_agents
}

spawn_quality_agents() {
    echo "🔍 Spawning quality-focused agents..."
    
    echo "Agent 1: Linting & Code Style"
    echo "Agent 2: Test Coverage & Validation"
    echo "Agent 3: Security & Vulnerability Scanning"
    echo "Agent 4: Performance & Complexity Analysis"
    
    # Coordinate quality agents
    coordinate_quality_agents
}

spawn_analysis_agents() {
    echo "📊 Spawning analysis-focused agents..."
    
    echo "Agent 1: Change Impact Analysis"
    echo "Agent 2: Dependency Analysis"
    echo "Agent 3: Architecture Impact"
    echo "Agent 4: Risk Assessment"
    
    # Coordinate analysis agents
    coordinate_analysis_agents
}
```

## Forbidden Behaviors

**PR-Specific Constraints:**
```bash
# Enforce PR-specific forbidden behaviors
enforce_pr_constraints() {
    echo "🚨 Enforcing PR constraints..."
    
    # 1. Never merge without approval
    if check_merge_attempt_without_approval; then
        echo "❌ FORBIDDEN: Merging without required approvals"
        exit 1
    fi
    
    # 2. Never force push to PR branch with reviews
    if check_force_push_with_reviews; then
        echo "❌ FORBIDDEN: Force pushing with pending reviews"
        exit 1
    fi
    
    # 3. Never create PRs with failing tests
    if check_pr_creation_with_failing_tests; then
        echo "❌ FORBIDDEN: Creating PR with failing tests"
        exit 1
    fi
    
    # 4. Never merge conflicting PRs
    if check_merge_with_conflicts; then
        echo "❌ FORBIDDEN: Merging PR with unresolved conflicts"
        exit 1
    fi
    
    # 5. Never skip security checks
    if check_security_bypass_attempt; then
        echo "❌ FORBIDDEN: Bypassing security checks"
        exit 1
    fi
    
    echo "✅ All PR constraints validated"
}

check_merge_attempt_without_approval() {
    if command -v gh &> /dev/null; then
        local review_decision=$(gh pr view --json reviewDecision -q .reviewDecision 2>/dev/null)
        if [ "$review_decision" != "APPROVED" ] && [ -n "$MERGE_ATTEMPT" ]; then
            return 0
        fi
    fi
    return 1
}

check_force_push_with_reviews() {
    if command -v gh &> /dev/null; then
        local reviews=$(gh pr view --json reviews -q '.reviews | length' 2>/dev/null)
        if [ "$reviews" -gt 0 ] && [ -n "$FORCE_PUSH_ATTEMPT" ]; then
            return 0
        fi
    fi
    return 1
}

check_pr_creation_with_failing_tests() {
    if [ -n "$PR_CREATE_ATTEMPT" ]; then
        if ! run_tests; then
            return 0
        fi
    fi
    return 1
}

check_merge_with_conflicts() {
    if command -v gh &> /dev/null; then
        local mergeable=$(gh pr view --json mergeable -q .mergeable 2>/dev/null)
        if [ "$mergeable" = "CONFLICTING" ] && [ -n "$MERGE_ATTEMPT" ]; then
            return 0
        fi
    fi
    return 1
}

check_security_bypass_attempt() {
    if [ -n "$SECURITY_BYPASS_ATTEMPT" ]; then
        return 0
    fi
    return 1
}
```

## Integration Support

**GitHub/GitLab Integration:**
```bash
# Platform-specific integrations
setup_platform_integration() {
    echo "🔌 Setting up platform integration..."
    
    if command -v gh &> /dev/null; then
        setup_github_integration
    elif command -v glab &> /dev/null; then
        setup_gitlab_integration
    else
        echo "💡 Install GitHub CLI (gh) or GitLab CLI (glab) for enhanced features"
    fi
}

setup_github_integration() {
    echo "🐙 Setting up GitHub integration..."
    
    # Verify authentication
    if ! gh auth status &>/dev/null; then
        echo "🔐 GitHub authentication required"
        gh auth login
    fi
    
    # Configure PR settings
    gh config set pr.automerge false
    gh config set pr.discussions true
    
    echo "✅ GitHub integration configured"
}

setup_gitlab_integration() {
    echo "🦊 Setting up GitLab integration..."
    
    # Verify authentication
    if ! glab auth status &>/dev/null; then
        echo "🔐 GitLab authentication required"
        glab auth login
    fi
    
    echo "✅ GitLab integration configured"
}
```

## Best Practices Summary

**PR Excellence Guidelines:**

1. **Creation Phase**
   - Comprehensive quality checks before PR creation
   - Intelligent template generation
   - Automated labeling and reviewer assignment

2. **Review Phase**
   - Multi-agent review coordination
   - Quality-focused analysis
   - Interactive review process

3. **Merge Phase**
   - Safety-first merge validation
   - Strategic merge approach selection
   - Comprehensive post-merge cleanup

4. **Monitoring Phase**
   - Real-time status intelligence
   - Team collaboration insights
   - Proactive recommendations

## Summary

The smart PR command provides:
- ✅ Intelligent PR creation with quality gates
- ✅ Comprehensive review management
- ✅ Safe merge operations with validation
- ✅ Real-time status monitoring
- ✅ Multi-agent coordination
- ✅ Platform integration (GitHub/GitLab)
- ✅ Forbidden behavior enforcement
- ✅ Automated workflow optimization

Remember: **Pull requests are conversations, not just code changes. Make them meaningful!**