---
description: Shared utilities and functions for git commands
---

# Git Command Shared Utilities

Common functions and utilities used across git commands.

## Branch Utilities

```bash
# Get current branch name
get_current_branch() {
    git branch --show-current || git rev-parse --abbrev-ref HEAD
}

# Check if branch exists
branch_exists() {
    git show-ref --verify --quiet refs/heads/"$1"
}

# Check if on protected branch
is_protected_branch() {
    local branch=$1
    local protected_branches=("main" "master" "develop" "production" "release")
    
    for protected in "${protected_branches[@]}"; do
        if [[ "$branch" == "$protected" ]]; then
            return 0
        fi
    done
    return 1
}

# Get branch age in days
get_branch_age() {
    local branch=$1
    local first_commit_date=$(git log --reverse --format=%ct "$branch" | head -1)
    if [ -n "$first_commit_date" ]; then
        echo $(( ($(date +%s) - first_commit_date) / 86400 ))
    else
        echo 0
    fi
}
```

## Validation Utilities

```bash
# Validate branch name format
validate_branch_name() {
    local branch=$1
    local valid_prefixes="feature|bugfix|hotfix|release|chore|experiment|refactor"
    
    if ! echo "$branch" | grep -qE "^($valid_prefixes)/"; then
        echo "ERROR: Branch name must start with one of: $valid_prefixes"
        return 1
    fi
    
    if echo "$branch" | grep -qE '[^a-zA-Z0-9/_-]'; then
        echo "ERROR: Branch name contains invalid characters"
        return 1
    fi
    
    return 0
}

# Check for sensitive data
check_sensitive_data() {
    local patterns=(
        "password"
        "secret"
        "api_key"
        "apikey"
        "token"
        "private_key"
        "aws_access_key"
        "aws_secret"
    )
    
    for pattern in "${patterns[@]}"; do
        if git diff --cached | grep -i "$pattern" | grep -vE "(test|spec|mock)" ; then
            echo "WARNING: Possible sensitive data detected (pattern: $pattern)"
            return 1
        fi
    done
    
    return 0
}

# Validate commit message format
validate_commit_message() {
    local message=$1
    local pattern="^(feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert)(\(.+\))?: .{1,50}"
    
    if ! echo "$message" | grep -qE "$pattern"; then
        echo "ERROR: Commit message doesn't follow conventional format"
        echo "Expected: <type>(<scope>): <subject>"
        return 1
    fi
    
    return 0
}
```

## Status Utilities

```bash
# Get repository status counts
get_status_counts() {
    local staged=$(git diff --cached --name-only | wc -l)
    local unstaged=$(git diff --name-only | wc -l)
    local untracked=$(git ls-files --others --exclude-standard | wc -l)
    
    echo "staged:$staged unstaged:$unstaged untracked:$untracked"
}

# Check if repository is clean
is_repo_clean() {
    [ -z "$(git status --porcelain)" ]
}

# Get ahead/behind counts
get_branch_divergence() {
    local branch=${1:-$(get_current_branch)}
    local upstream=$(git rev-parse --abbrev-ref "$branch"@{upstream} 2>/dev/null)
    
    if [ -n "$upstream" ]; then
        local ahead=$(git rev-list --count "$upstream".."$branch")
        local behind=$(git rev-list --count "$branch".."$upstream")
        echo "ahead:$ahead behind:$behind upstream:$upstream"
    else
        echo "ahead:0 behind:0 upstream:none"
    fi
}
```

## File Utilities

```bash
# Find large files
find_large_files() {
    local size_limit=${1:-10485760}  # Default 10MB
    
    git ls-files -z | xargs -0 -n1 -I{} sh -c '
        if [ -f "{}" ]; then
            size=$(stat -f%z "{}" 2>/dev/null || stat -c%s "{}" 2>/dev/null)
            if [ "$size" -gt '"$size_limit"' ]; then
                echo "{} $(($size/1048576))MB"
            fi
        fi
    '
}

# Check for binary files
is_binary_file() {
    local file=$1
    # Check if file contains null bytes
    grep -q $'\0' "$file"
}

# Get file type statistics
get_file_type_stats() {
    git ls-files | grep -E '\.[a-zA-Z0-9]+$' | sed 's/.*\.//' | sort | uniq -c | sort -rn
}
```

## Hook Utilities

```bash
# Run pre-commit hooks
run_pre_commit_hooks() {
    if [ -f .git/hooks/pre-commit ]; then
        .git/hooks/pre-commit
    else
        # Run default checks
        check_sensitive_data
        run_linters
        run_tests
    fi
}

# Run linters based on project type
run_linters() {
    if [ -f Makefile ] && grep -q "lint:" Makefile; then
        make lint
    elif [ -f package.json ]; then
        npm run lint 2>/dev/null || npx eslint .
    elif [ -f Cargo.toml ]; then
        cargo clippy
    elif [ -f go.mod ]; then
        golangci-lint run
    elif [ -f .rubocop.yml ]; then
        rubocop
    elif [ -f .flake8 ] || [ -f setup.cfg ]; then
        flake8
    else
        echo "No linter configuration found"
    fi
}

# Run tests based on project type
run_tests() {
    if [ -f Makefile ] && grep -q "test:" Makefile; then
        make test
    elif [ -f package.json ]; then
        npm test
    elif [ -f Cargo.toml ]; then
        cargo test
    elif [ -f go.mod ]; then
        go test ./...
    elif [ -f Gemfile ]; then
        bundle exec rspec
    elif [ -f requirements.txt ] && [ -d tests ]; then
        python -m pytest
    else
        echo "No test configuration found"
    fi
}
```

## Formatting Utilities

```bash
# Format commit message
format_commit_message() {
    local type=$1
    local scope=$2
    local subject=$3
    local body=$4
    local footer=$5
    
    local message="${type}"
    [ -n "$scope" ] && message="${message}(${scope})"
    message="${message}: ${subject}"
    
    [ -n "$body" ] && message="${message}\n\n${body}"
    [ -n "$footer" ] && message="${message}\n\n${footer}"
    
    echo -e "$message"
}

# Generate commit message from diff
suggest_commit_message() {
    local files_changed=$(git diff --cached --name-only)
    local files_count=$(echo "$files_changed" | wc -l)
    
    # Determine type
    local type="chore"
    if echo "$files_changed" | grep -q "^src/"; then
        type="feat"
    elif echo "$files_changed" | grep -q "^test/"; then
        type="test"
    elif echo "$files_changed" | grep -q "^docs/"; then
        type="docs"
    elif echo "$files_changed" | grep -q "fix"; then
        type="fix"
    fi
    
    # Determine scope
    local scope=""
    if [ "$files_count" -eq 1 ]; then
        scope=$(dirname "$files_changed" | sed 's|^src/||' | sed 's|/.*||')
    fi
    
    echo "${type}${scope:+(${scope})}: "
}
```

## Interactive Utilities

```bash
# Confirm action
confirm() {
    local prompt=${1:-"Continue?"}
    local default=${2:-"n"}
    
    if [[ "$default" == "y" ]]; then
        read -p "$prompt [Y/n]: " response
        response=${response:-y}
    else
        read -p "$prompt [y/N]: " response
        response=${response:-n}
    fi
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Select from options
select_option() {
    local prompt=$1
    shift
    local options=("$@")
    
    echo "$prompt"
    for i in "${!options[@]}"; do
        echo "$((i+1))) ${options[$i]}"
    done
    
    local choice
    read -p "Select (1-${#options[@]}): " choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
        echo "${options[$((choice-1))]}"
    else
        echo ""
        return 1
    fi
}
```

## CI/CD Utilities

```bash
# Check CI status
check_ci_status() {
    if command -v gh &> /dev/null; then
        gh run list --limit 1 --branch $(get_current_branch) --json status -q '.[0].status'
    elif [ -f .github/workflows ]; then
        echo "GitHub Actions configured but gh CLI not available"
    else
        echo "No CI configuration detected"
    fi
}

# Trigger CI build
trigger_ci_build() {
    local message=$1
    
    if [[ "$message" =~ \[skip\ ci\] ]]; then
        echo "CI skip requested"
        return 0
    fi
    
    if [[ "$message" =~ \[urgent\] ]] && command -v gh &> /dev/null; then
        gh workflow run urgent-build.yml
    fi
}
```

## Reporting Utilities

```bash
# Generate activity report
generate_activity_report() {
    local days=${1:-7}
    
    echo "=== Git Activity Report (Last $days days) ==="
    echo ""
    echo "Commits by author:"
    git shortlog -sn --since="$days days ago"
    echo ""
    echo "Files changed:"
    git log --since="$days days ago" --name-only --pretty=format: | sort | uniq -c | sort -rn | head -10
    echo ""
    echo "Activity by day:"
    git log --since="$days days ago" --format=%cd --date=format:%Y-%m-%d | sort | uniq -c
}

# Check repository metrics
get_repo_metrics() {
    local total_commits=$(git rev-list --all --count)
    local contributors=$(git shortlog -sn | wc -l)
    local branches=$(git branch -a | wc -l)
    local tags=$(git tag | wc -l)
    
    echo "commits:$total_commits contributors:$contributors branches:$branches tags:$tags"
}
```

## Error Handling

```bash
# Safe command execution
safe_execute() {
    local command=$1
    shift
    
    if ! output=$("$command" "$@" 2>&1); then
        echo "ERROR: Command failed: $command $*"
        echo "$output"
        return 1
    fi
    
    echo "$output"
    return 0
}

# Cleanup on exit
cleanup_on_exit() {
    local exit_code=$?
    
    # Remove temporary files
    rm -f /tmp/git-tmp-*
    
    # Restore stashed changes if any
    if [ -n "$STASH_REF" ]; then
        git stash pop "$STASH_REF" >/dev/null 2>&1
    fi
    
    exit $exit_code
}

# Set trap for cleanup
trap cleanup_on_exit EXIT
```

These utilities provide a comprehensive foundation for the git commands, ensuring consistency and reusability across all git operations.