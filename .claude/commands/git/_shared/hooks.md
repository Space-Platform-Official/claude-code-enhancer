---
description: Git hooks setup and management system
---

# Git Hooks Management System

Comprehensive utilities for setting up, managing, and maintaining Git hooks across development workflows.

## Hook Installation and Setup

```bash
# Install standard hooks from templates
install_git_hooks() {
    local template_dir=${1:-"$HOME/.git-templates/hooks"}
    local hook_types=("pre-commit" "pre-push" "commit-msg" "post-commit" "post-merge" "pre-rebase")
    
    echo "Installing Git hooks from: $template_dir"
    
    # Create hooks directory if it doesn't exist
    mkdir -p .git/hooks
    
    # Install each hook type
    for hook in "${hook_types[@]}"; do
        if [ -f "$template_dir/$hook" ]; then
            cp "$template_dir/$hook" ".git/hooks/$hook"
            chmod +x ".git/hooks/$hook"
            echo "✅ Installed: $hook"
        elif [ -f "$template_dir/$hook.sample" ]; then
            cp "$template_dir/$hook.sample" ".git/hooks/$hook"
            chmod +x ".git/hooks/$hook"
            echo "✅ Installed from sample: $hook"
        fi
    done
    
    echo "Hook installation complete"
}

# Create hook templates directory
create_hook_templates() {
    local template_dir=${1:-"$HOME/.git-templates/hooks"}
    
    mkdir -p "$template_dir"
    
    # Create pre-commit hook template
    cat > "$template_dir/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook for code quality checks

set -e

echo "Running pre-commit checks..."

# Source shared utilities if available
if [ -f ".claude/commands/git/_shared/utils.md" ]; then
    source <(sed -n '/```bash/,/```/p' .claude/commands/git/_shared/utils.md | grep -v '```')
fi

# Check for sensitive data
check_sensitive_data() {
    local patterns=(
        "password\s*[:=]\s*['\"][^'\"]*['\"]"
        "secret\s*[:=]\s*['\"][^'\"]*['\"]"
        "api_key\s*[:=]\s*['\"][^'\"]*['\"]"
        "token\s*[:=]\s*['\"][^'\"]*['\"]"
        "private_key"
        "-----BEGIN.*PRIVATE KEY-----"
        "aws_access_key_id"
        "aws_secret_access_key"
    )
    
    local found_sensitive=false
    
    for pattern in "${patterns[@]}"; do
        if git diff --cached | grep -iE "$pattern" >/dev/null 2>&1; then
            echo "❌ ERROR: Possible sensitive data detected (pattern: $pattern)"
            found_sensitive=true
        fi
    done
    
    if [ "$found_sensitive" = true ]; then
        echo "🚨 SECURITY: Remove sensitive data before committing"
        return 1
    fi
    
    return 0
}

# Check file sizes
check_file_sizes() {
    local max_size=${1:-10485760}  # 10MB default
    local large_files=()
    
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            if [ "$size" -gt "$max_size" ]; then
                large_files+=("$file ($(($size/1048576))MB)")
            fi
        fi
    done < <(git diff --cached --name-only -z)
    
    if [ ${#large_files[@]} -gt 0 ]; then
        echo "❌ ERROR: Large files detected:"
        printf '%s\n' "${large_files[@]}"
        echo "Consider using Git LFS for large files"
        return 1
    fi
    
    return 0
}

# Run linters
run_project_linters() {
    if [ -f "Makefile" ] && grep -q "lint:" Makefile; then
        echo "Running make lint..."
        make lint
    elif [ -f "package.json" ] && grep -q '"lint"' package.json; then
        echo "Running npm lint..."
        npm run lint
    elif [ -f ".pre-commit-config.yaml" ]; then
        echo "Running pre-commit..."
        pre-commit run --all-files
    elif [ -f "pyproject.toml" ] && grep -q "ruff" pyproject.toml; then
        echo "Running ruff..."
        ruff check .
    elif [ -f "Cargo.toml" ]; then
        echo "Running cargo clippy..."
        cargo clippy -- -D warnings
    elif [ -f "go.mod" ]; then
        echo "Running golangci-lint..."
        golangci-lint run
    else
        echo "No linter configuration found, skipping..."
        return 0
    fi
}

# Run tests if they're fast
run_quick_tests() {
    if [ -f "Makefile" ] && grep -q "test-quick:" Makefile; then
        echo "Running quick tests..."
        make test-quick
    elif [ -f "package.json" ] && grep -q '"test:quick"' package.json; then
        echo "Running quick tests..."
        npm run test:quick
    else
        echo "No quick tests configured, skipping..."
        return 0
    fi
}

# Main execution
main() {
    echo "🔍 Checking for sensitive data..."
    check_sensitive_data || exit 1
    
    echo "📏 Checking file sizes..."
    check_file_sizes || exit 1
    
    echo "🔧 Running linters..."
    run_project_linters || exit 1
    
    echo "🧪 Running quick tests..."
    run_quick_tests || exit 1
    
    echo "✅ All pre-commit checks passed!"
}

main "$@"
EOF

    # Create commit-msg hook template
    cat > "$template_dir/commit-msg" << 'EOF'
#!/bin/bash
# Commit message validation hook

commit_regex='^(feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert)(\(.+\))?: .{1,50}'

error_msg="Invalid commit message format.
Expected: <type>(<scope>): <subject>

Types:
- feat: A new feature
- fix: A bug fix
- docs: Documentation only changes
- style: Changes that do not affect the meaning of the code
- refactor: A code change that neither fixes a bug nor adds a feature
- perf: A code change that improves performance
- test: Adding missing tests or correcting existing tests
- chore: Changes to the build process or auxiliary tools
- ci: Changes to CI configuration files and scripts
- build: Changes that affect the build system or external dependencies
- revert: Reverts a previous commit

Example: feat(auth): add OAuth2 integration"

if ! grep -qE "$commit_regex" "$1"; then
    echo "$error_msg" >&2
    exit 1
fi
EOF

    # Create pre-push hook template
    cat > "$template_dir/pre-push" << 'EOF'
#!/bin/bash
# Pre-push hook for comprehensive checks

set -e

echo "Running pre-push checks..."

# Check if we're pushing to protected branches
protected_branch() {
    local branch=$1
    local protected_branches=("main" "master" "develop" "production" "release")
    
    for protected in "${protected_branches[@]}"; do
        if [[ "$branch" == "$protected" ]]; then
            return 0
        fi
    done
    return 1
}

# Run comprehensive tests
run_full_tests() {
    if [ -f "Makefile" ] && grep -q "test:" Makefile; then
        echo "Running full test suite..."
        make test
    elif [ -f "package.json" ] && grep -q '"test"' package.json; then
        echo "Running npm test..."
        npm test
    elif [ -f "Cargo.toml" ]; then
        echo "Running cargo test..."
        cargo test
    elif [ -f "go.mod" ]; then
        echo "Running go test..."
        go test ./...
    else
        echo "No test configuration found"
        return 0
    fi
}

# Check build
check_build() {
    if [ -f "Makefile" ] && grep -q "build:" Makefile; then
        echo "Running build check..."
        make build
    elif [ -f "package.json" ] && grep -q '"build"' package.json; then
        echo "Running npm build..."
        npm run build
    elif [ -f "Cargo.toml" ]; then
        echo "Running cargo build..."
        cargo build
    elif [ -f "go.mod" ]; then
        echo "Running go build..."
        go build ./...
    else
        echo "No build configuration found"
        return 0
    fi
}

# Read push information
while read local_ref local_sha remote_ref remote_sha; do
    branch=$(echo "$remote_ref" | sed 's/refs\/heads\///')
    
    if protected_branch "$branch"; then
        echo "🔒 Pushing to protected branch: $branch"
        echo "🧪 Running comprehensive checks..."
        
        echo "📋 Running full test suite..."
        run_full_tests || exit 1
        
        echo "🔨 Checking build..."
        check_build || exit 1
        
        echo "✅ All checks passed for protected branch"
    else
        echo "📤 Pushing to: $branch (non-protected)"
    fi
done

echo "✅ Pre-push checks completed successfully!"
EOF

    # Create post-commit hook template
    cat > "$template_dir/post-commit" << 'EOF'
#!/bin/bash
# Post-commit hook for notifications and cleanup

# Get commit information
commit_hash=$(git rev-parse HEAD)
commit_message=$(git log -1 --pretty=%B)
author=$(git log -1 --pretty=%an)
branch=$(git branch --show-current)

echo "📝 Commit created: ${commit_hash:0:8} by $author"

# Notify if configured
if [ -n "$SLACK_WEBHOOK_URL" ] && command -v curl &> /dev/null; then
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"New commit on $branch by $author: ${commit_message:0:100}\"}" \
        "$SLACK_WEBHOOK_URL" &>/dev/null &
fi

# Update tags if on main branch
if [[ "$branch" == "main" || "$branch" == "master" ]]; then
    # Auto-tag if this is a version bump
    if echo "$commit_message" | grep -qE "^(feat|fix)"; then
        echo "🏷️  Consider creating a new release tag"
    fi
fi
EOF

    # Create post-merge hook template
    cat > "$template_dir/post-merge" << 'EOF'
#!/bin/bash
# Post-merge hook for dependency updates and cleanup

echo "🔄 Post-merge cleanup starting..."

# Update dependencies if lockfiles changed
if git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD | grep -qE "(package-lock\.json|yarn\.lock|Cargo\.lock|go\.sum|Pipfile\.lock)"; then
    echo "📦 Dependency files changed, updating..."
    
    if [ -f "package-lock.json" ]; then
        echo "Updating npm dependencies..."
        npm ci
    elif [ -f "yarn.lock" ]; then
        echo "Updating yarn dependencies..."
        yarn install --frozen-lockfile
    elif [ -f "Cargo.lock" ]; then
        echo "Updating Cargo dependencies..."
        cargo build
    elif [ -f "go.sum" ]; then
        echo "Updating Go dependencies..."
        go mod download
    elif [ -f "Pipfile.lock" ]; then
        echo "Updating Python dependencies..."
        pipenv install --dev
    fi
fi

# Restart development services if configuration changed
config_files=("docker-compose.yml" "Dockerfile" ".env.example" "config/")
for file in "${config_files[@]}"; do
    if git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD | grep -q "$file"; then
        echo "⚙️  Configuration changed - consider restarting services"
        break
    fi
done

echo "✅ Post-merge cleanup completed!"
EOF

    # Make all hooks executable
    chmod +x "$template_dir"/*
    
    echo "Hook templates created in: $template_dir"
}

# Initialize hooks for new repository
init_repository_hooks() {
    local hook_type=${1:-"standard"}
    
    case "$hook_type" in
        "minimal")
            install_minimal_hooks
            ;;
        "standard")
            install_standard_hooks
            ;;
        "comprehensive")
            install_comprehensive_hooks
            ;;
        "custom")
            install_custom_hooks
            ;;
        *)
            echo "Available hook types: minimal, standard, comprehensive, custom"
            return 1
            ;;
    esac
}

# Install minimal hooks (just essentials)
install_minimal_hooks() {
    echo "Installing minimal hooks..."
    
    # Basic pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Minimal pre-commit checks
if git diff --cached | grep -i "password\|secret\|api_key" >/dev/null 2>&1; then
    echo "❌ ERROR: Possible sensitive data detected"
    exit 1
fi
echo "✅ Basic checks passed"
EOF
    
    chmod +x .git/hooks/pre-commit
    echo "Minimal hooks installed"
}

# Install comprehensive hooks (all checks)
install_comprehensive_hooks() {
    echo "Installing comprehensive hooks..."
    
    create_hook_templates
    install_git_hooks
    
    # Additional comprehensive checks
    cat >> .git/hooks/pre-commit << 'EOF'

# Additional comprehensive checks
check_todos() {
    if git diff --cached | grep -E "(TODO|FIXME|XXX|HACK)" >/dev/null 2>&1; then
        echo "⚠️  WARNING: TODO/FIXME comments found in staged changes"
        echo "Consider addressing these before committing:"
        git diff --cached | grep -E "(TODO|FIXME|XXX|HACK)"
    fi
}

check_debug_statements() {
    local debug_patterns=(
        "console\.log"
        "print\("
        "debugger"
        "pdb\.set_trace"
        "binding\.pry"
        "dd\("
        "var_dump"
    )
    
    for pattern in "${debug_patterns[@]}"; do
        if git diff --cached | grep -E "$pattern" >/dev/null 2>&1; then
            echo "⚠️  WARNING: Debug statement detected (pattern: $pattern)"
            echo "Consider removing debug code before committing"
        fi
    done
}

echo "🔍 Running additional comprehensive checks..."
check_todos
check_debug_statements
EOF
    
    echo "Comprehensive hooks installed"
}
```

## Hook Management

```bash
# List all installed hooks
list_git_hooks() {
    local hooks_dir=".git/hooks"
    
    echo "=== Git Hooks Status ==="
    
    if [ ! -d "$hooks_dir" ]; then
        echo "No hooks directory found"
        return 1
    fi
    
    echo "Installed hooks:"
    for hook in "$hooks_dir"/*; do
        if [ -f "$hook" ] && [ -x "$hook" ]; then
            local hook_name=$(basename "$hook")
            local line_count=$(wc -l < "$hook")
            echo "✅ $hook_name ($line_count lines)"
        fi
    done
    
    echo ""
    echo "Available hook types:"
    echo "- pre-commit: Runs before each commit"
    echo "- pre-push: Runs before each push"
    echo "- commit-msg: Validates commit messages"
    echo "- post-commit: Runs after each commit"
    echo "- post-merge: Runs after merge operations"
    echo "- pre-rebase: Runs before rebase operations"
}

# Enable or disable specific hooks
toggle_git_hook() {
    local hook_name=$1
    local action=${2:-"toggle"}  # enable, disable, toggle
    local hook_file=".git/hooks/$hook_name"
    local disabled_file="${hook_file}.disabled"
    
    case "$action" in
        "enable")
            if [ -f "$disabled_file" ]; then
                mv "$disabled_file" "$hook_file"
                chmod +x "$hook_file"
                echo "✅ Enabled hook: $hook_name"
            else
                echo "Hook not found or already enabled: $hook_name"
            fi
            ;;
        "disable")
            if [ -f "$hook_file" ]; then
                mv "$hook_file" "$disabled_file"
                echo "❌ Disabled hook: $hook_name"
            else
                echo "Hook not found or already disabled: $hook_name"
            fi
            ;;
        "toggle")
            if [ -f "$hook_file" ]; then
                toggle_git_hook "$hook_name" "disable"
            elif [ -f "$disabled_file" ]; then
                toggle_git_hook "$hook_name" "enable"
            else
                echo "Hook not found: $hook_name"
            fi
            ;;
        *)
            echo "Invalid action: $action (use enable, disable, or toggle)"
            return 1
            ;;
    esac
}

# Update hooks from template
update_git_hooks() {
    local template_dir=${1:-"$HOME/.git-templates/hooks"}
    local force=${2:-false}
    
    echo "Updating Git hooks from: $template_dir"
    
    for template in "$template_dir"/*; do
        if [ -f "$template" ]; then
            local hook_name=$(basename "$template")
            local hook_file=".git/hooks/$hook_name"
            
            if [ -f "$hook_file" ] && [ "$force" != true ]; then
                echo "⚠️  Hook exists: $hook_name (use --force to overwrite)"
                continue
            fi
            
            cp "$template" "$hook_file"
            chmod +x "$hook_file"
            echo "✅ Updated: $hook_name"
        fi
    done
    
    echo "Hook update complete"
}

# Backup existing hooks
backup_git_hooks() {
    local backup_dir=${1:-"./git-hooks-backup"}
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$backup_dir/$timestamp"
    
    mkdir -p "$backup_path"
    
    if [ -d ".git/hooks" ]; then
        cp -r .git/hooks/* "$backup_path/" 2>/dev/null || true
        echo "Hooks backed up to: $backup_path"
        
        # Create restore script
        cat > "$backup_path/restore.sh" << EOF
#!/bin/bash
# Restore Git hooks from backup
echo "Restoring Git hooks from backup..."
cp -r "$backup_path"/* .git/hooks/
chmod +x .git/hooks/*
echo "Hooks restored"
EOF
        
        chmod +x "$backup_path/restore.sh"
        echo "Restore script created: $backup_path/restore.sh"
    else
        echo "No hooks directory found to backup"
    fi
}
```

## Hook Testing and Validation

```bash
# Test specific hook
test_git_hook() {
    local hook_name=$1
    local test_mode=${2:-"dry-run"}
    local hook_file=".git/hooks/$hook_name"
    
    if [ ! -f "$hook_file" ]; then
        echo "❌ Hook not found: $hook_name"
        return 1
    fi
    
    if [ ! -x "$hook_file" ]; then
        echo "❌ Hook not executable: $hook_name"
        return 1
    fi
    
    echo "Testing hook: $hook_name"
    
    case "$hook_name" in
        "pre-commit")
            test_pre_commit_hook "$test_mode"
            ;;
        "commit-msg")
            test_commit_msg_hook "$test_mode"
            ;;
        "pre-push")
            test_pre_push_hook "$test_mode"
            ;;
        *)
            echo "Running generic test for: $hook_name"
            if [ "$test_mode" == "dry-run" ]; then
                echo "Would execute: $hook_file"
            else
                "$hook_file"
            fi
            ;;
    esac
}

# Test pre-commit hook
test_pre_commit_hook() {
    local test_mode=$1
    
    echo "🔍 Testing pre-commit hook..."
    
    # Check if there are staged changes
    if [ -z "$(git diff --cached --name-only)" ]; then
        echo "⚠️  No staged changes found. Staging a test file..."
        
        # Create a temporary test file
        echo "# Test file for hook validation" > .hook-test-file
        git add .hook-test-file
    fi
    
    if [ "$test_mode" == "dry-run" ]; then
        echo "Would run pre-commit hook on staged files"
        git diff --cached --name-only
    else
        echo "Running pre-commit hook..."
        .git/hooks/pre-commit
        local exit_code=$?
        
        # Clean up test file if we created it
        if [ -f ".hook-test-file" ]; then
            git reset .hook-test-file
            rm .hook-test-file
        fi
        
        return $exit_code
    fi
}

# Test commit message hook
test_commit_msg_hook() {
    local test_mode=$1
    local test_messages=(
        "feat: add new feature"
        "fix(auth): resolve login issue"
        "docs: update README"
        "invalid commit message"
        "BREAKING CHANGE: remove deprecated API"
    )
    
    echo "🔍 Testing commit-msg hook..."
    
    for message in "${test_messages[@]}"; do
        echo "Testing message: '$message'"
        
        if [ "$test_mode" == "dry-run" ]; then
            echo "Would validate commit message"
        else
            # Create temporary commit message file
            local temp_msg_file=$(mktemp)
            echo "$message" > "$temp_msg_file"
            
            if .git/hooks/commit-msg "$temp_msg_file"; then
                echo "✅ Valid: $message"
            else
                echo "❌ Invalid: $message"
            fi
            
            rm "$temp_msg_file"
        fi
    done
}

# Test pre-push hook
test_pre_push_hook() {
    local test_mode=$1
    
    echo "🔍 Testing pre-push hook..."
    
    if [ "$test_mode" == "dry-run" ]; then
        echo "Would run pre-push checks"
        echo "Current branch: $(git branch --show-current)"
        echo "Remote refs would be checked"
    else
        # Simulate pre-push input
        local current_branch=$(git branch --show-current)
        local current_sha=$(git rev-parse HEAD)
        local remote_ref="refs/heads/$current_branch"
        
        echo "$remote_ref $current_sha $remote_ref $current_sha" | .git/hooks/pre-push origin
    fi
}

# Validate all hooks
validate_all_hooks() {
    local hooks_dir=".git/hooks"
    local validation_errors=0
    
    echo "=== Git Hooks Validation ==="
    
    if [ ! -d "$hooks_dir" ]; then
        echo "❌ No hooks directory found"
        return 1
    fi
    
    for hook in "$hooks_dir"/*; do
        if [ -f "$hook" ] && [ -x "$hook" ]; then
            local hook_name=$(basename "$hook")
            
            echo "Validating: $hook_name"
            
            # Check if it's a valid script
            if head -1 "$hook" | grep -q "^#!"; then
                echo "✅ Valid shebang found"
            else
                echo "⚠️  No shebang found in $hook_name"
                ((validation_errors++))
            fi
            
            # Check for syntax errors (bash scripts only)
            if head -1 "$hook" | grep -q "bash"; then
                if bash -n "$hook" 2>/dev/null; then
                    echo "✅ Syntax check passed"
                else
                    echo "❌ Syntax errors found in $hook_name"
                    ((validation_errors++))
                fi
            fi
            
            # Check permissions
            if [ -x "$hook" ]; then
                echo "✅ Executable permissions set"
            else
                echo "❌ Missing executable permissions for $hook_name"
                ((validation_errors++))
            fi
            
            echo ""
        fi
    done
    
    if [ $validation_errors -eq 0 ]; then
        echo "✅ All hooks passed validation"
    else
        echo "❌ Found $validation_errors validation issues"
    fi
    
    return $validation_errors
}
```

## Advanced Hook Features

```bash
# Create conditional hooks based on branch/environment
create_conditional_hook() {
    local hook_name=$1
    local condition=$2
    local action=$3
    
    local hook_file=".git/hooks/$hook_name"
    
    # Create base hook if it doesn't exist
    if [ ! -f "$hook_file" ]; then
        cat > "$hook_file" << 'EOF'
#!/bin/bash
# Conditional Git hook
set -e
EOF
        chmod +x "$hook_file"
    fi
    
    # Add conditional logic
    cat >> "$hook_file" << EOF

# Conditional logic: $condition
if $condition; then
    echo "Executing conditional action: $action"
    $action
fi
EOF
    
    echo "Conditional hook added to: $hook_name"
}

# Create shared hook library
create_shared_hook_library() {
    local lib_dir=${1:-".git/hooks/lib"}
    
    mkdir -p "$lib_dir"
    
    # Create shared functions library
    cat > "$lib_dir/common.sh" << 'EOF'
#!/bin/bash
# Shared hook functions library

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get project type
get_project_type() {
    if [ -f "package.json" ]; then
        echo "node"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "python"
    elif [ -f "Gemfile" ]; then
        echo "ruby"
    elif [ -f "composer.json" ]; then
        echo "php"
    else
        echo "unknown"
    fi
}

# Run command with timeout
run_with_timeout() {
    local timeout=$1
    shift
    local command="$@"
    
    if command_exists timeout; then
        timeout "$timeout" $command
    else
        # Fallback for systems without timeout command
        $command
    fi
}

# Check if running in CI
is_ci_environment() {
    [ -n "$CI" ] || [ -n "$CONTINUOUS_INTEGRATION" ] || [ -n "$GITHUB_ACTIONS" ] || [ -n "$GITLAB_CI" ]
}

# Get current branch
get_current_branch() {
    git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD
}

# Check if branch is protected
is_protected_branch() {
    local branch=${1:-$(get_current_branch)}
    local protected_branches=("main" "master" "develop" "production" "release")
    
    for protected in "${protected_branches[@]}"; do
        if [[ "$branch" == "$protected" ]]; then
            return 0
        fi
    done
    return 1
}
EOF

    # Create project-specific hook configurations
    cat > "$lib_dir/project-config.sh" << 'EOF'
#!/bin/bash
# Project-specific hook configuration

# Load project configuration
load_project_config() {
    local config_file=".git/hooks/config"
    
    if [ -f "$config_file" ]; then
        source "$config_file"
    else
        # Set defaults
        ENABLE_LINTING=${ENABLE_LINTING:-true}
        ENABLE_TESTING=${ENABLE_TESTING:-true}
        ENABLE_SECURITY_CHECKS=${ENABLE_SECURITY_CHECKS:-true}
        MAX_FILE_SIZE=${MAX_FILE_SIZE:-10485760}  # 10MB
        TIMEOUT_SECONDS=${TIMEOUT_SECONDS:-300}   # 5 minutes
    fi
}

# Create default configuration
create_default_config() {
    cat > .git/hooks/config << 'EOF'
# Git hooks configuration

# Enable/disable features
ENABLE_LINTING=true
ENABLE_TESTING=true
ENABLE_SECURITY_CHECKS=true
ENABLE_SIZE_CHECKS=true

# Limits and timeouts
MAX_FILE_SIZE=10485760  # 10MB
TIMEOUT_SECONDS=300     # 5 minutes

# Branch protection
PROTECTED_BRANCHES="main master develop production release"

# Custom commands
CUSTOM_LINT_COMMAND=""
CUSTOM_TEST_COMMAND=""
CUSTOM_BUILD_COMMAND=""
EOF
}
EOF

    echo "Shared hook library created in: $lib_dir"
}

# Install team-wide hooks via Git templates
setup_team_hooks() {
    local template_repo=$1
    local template_dir=${2:-"$HOME/.git-templates"}
    
    if [ -z "$template_repo" ]; then
        echo "ERROR: Template repository URL required"
        return 1
    fi
    
    echo "Setting up team-wide hooks from: $template_repo"
    
    # Clone or update template repository
    if [ -d "$template_dir" ]; then
        cd "$template_dir" && git pull origin main
    else
        git clone "$template_repo" "$template_dir"
    fi
    
    # Configure Git to use templates
    git config --global init.templatedir "$template_dir"
    
    # Apply to current repository if we're in one
    if [ -d ".git" ]; then
        echo "Applying team hooks to current repository..."
        install_git_hooks "$template_dir/hooks"
    fi
    
    echo "Team hooks setup complete"
    echo "New repositories will automatically use these hooks"
}

# Monitor hook performance
monitor_hook_performance() {
    local hook_name=$1
    local hook_file=".git/hooks/$hook_name"
    
    if [ ! -f "$hook_file" ]; then
        echo "Hook not found: $hook_name"
        return 1
    fi
    
    echo "Monitoring performance for: $hook_name"
    
    # Wrap hook with timing
    cp "$hook_file" "${hook_file}.original"
    
    cat > "$hook_file" << EOF
#!/bin/bash
# Performance monitoring wrapper for $hook_name

start_time=\$(date +%s.%N)

# Source original hook
source "${hook_file}.original"
exit_code=\$?

end_time=\$(date +%s.%N)
duration=\$(echo "\$end_time - \$start_time" | bc)

# Log performance
echo "Hook $hook_name completed in \${duration}s" >> .git/hooks/performance.log

exit \$exit_code
EOF
    
    chmod +x "$hook_file"
    echo "Performance monitoring enabled for: $hook_name"
    echo "Logs will be written to: .git/hooks/performance.log"
}
```

## Troubleshooting and Maintenance

```bash
# Diagnose hook issues
diagnose_hook_issues() {
    echo "=== Git Hooks Diagnosis ==="
    
    # Check if hooks directory exists
    if [ ! -d ".git/hooks" ]; then
        echo "❌ ERROR: No .git/hooks directory found"
        return 1
    fi
    
    # Check permissions
    echo "Checking permissions..."
    local permission_issues=0
    for hook in .git/hooks/*; do
        if [ -f "$hook" ] && [ ! -x "$hook" ]; then
            echo "❌ Not executable: $(basename "$hook")"
            ((permission_issues++))
        fi
    done
    
    if [ $permission_issues -eq 0 ]; then
        echo "✅ All hooks have correct permissions"
    else
        echo "❌ Found $permission_issues permission issues"
    fi
    
    # Check for syntax errors
    echo "Checking syntax..."
    local syntax_issues=0
    for hook in .git/hooks/*; do
        if [ -f "$hook" ] && head -1 "$hook" | grep -q "bash"; then
            if ! bash -n "$hook" 2>/dev/null; then
                echo "❌ Syntax error in: $(basename "$hook")"
                ((syntax_issues++))
            fi
        fi
    done
    
    if [ $syntax_issues -eq 0 ]; then
        echo "✅ No syntax errors found"
    else
        echo "❌ Found $syntax_issues syntax issues"
    fi
    
    # Check for missing dependencies
    echo "Checking dependencies..."
    local missing_deps=()
    
    # Common dependencies
    local common_commands=("make" "npm" "cargo" "go" "python" "ruby")
    for cmd in "${common_commands[@]}"; do
        if grep -r "$cmd" .git/hooks/ >/dev/null 2>&1 && ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        echo "✅ All required dependencies available"
    else
        echo "❌ Missing dependencies: ${missing_deps[*]}"
    fi
    
    echo "Diagnosis complete"
}

# Repair common hook issues
repair_hook_issues() {
    echo "Repairing common hook issues..."
    
    # Fix permissions
    echo "Fixing permissions..."
    for hook in .git/hooks/*; do
        if [ -f "$hook" ]; then
            chmod +x "$hook"
        fi
    done
    
    # Remove broken symlinks
    echo "Removing broken symlinks..."
    find .git/hooks -type l -exec test ! -e {} \; -delete 2>/dev/null || true
    
    # Fix line endings
    echo "Fixing line endings..."
    for hook in .git/hooks/*; do
        if [ -f "$hook" ] && head -1 "$hook" | grep -q "^#!"; then
            # Convert to Unix line endings
            sed -i 's/\r$//' "$hook" 2>/dev/null || true
        fi
    done
    
    echo "Hook repair complete"
}

# Clean up hook-related files
cleanup_hook_files() {
    echo "Cleaning up hook-related files..."
    
    # Remove backup files
    find .git/hooks -name "*.bak" -delete 2>/dev/null || true
    find .git/hooks -name "*.original" -delete 2>/dev/null || true
    
    # Clean up log files
    rm -f .git/hooks/performance.log
    rm -f .git/hooks/debug.log
    
    # Remove temporary files
    find .git/hooks -name "tmp.*" -delete 2>/dev/null || true
    
    echo "Cleanup complete"
}

# Generate hooks documentation
generate_hooks_documentation() {
    local output_file=${1:-"HOOKS.md"}
    
    {
        echo "# Git Hooks Documentation"
        echo "Generated: $(date)"
        echo ""
        
        echo "## Installed Hooks"
        echo ""
        
        for hook in .git/hooks/*; do
            if [ -f "$hook" ] && [ -x "$hook" ]; then
                local hook_name=$(basename "$hook")
                echo "### $hook_name"
                echo ""
                
                # Extract description from hook file
                local description=$(grep "^# " "$hook" | head -5 | sed 's/^# //')
                if [ -n "$description" ]; then
                    echo "$description"
                    echo ""
                fi
                
                echo "**File:** \`$hook\`"
                echo ""
                echo "**Executable:** Yes"
                echo ""
                echo "**Size:** $(wc -l < "$hook") lines"
                echo ""
            fi
        done
        
        echo "## Hook Configuration"
        echo ""
        if [ -f ".git/hooks/config" ]; then
            echo "\`\`\`bash"
            cat .git/hooks/config
            echo "\`\`\`"
        else
            echo "No configuration file found."
        fi
        echo ""
        
        echo "## Usage"
        echo ""
        echo "These hooks are automatically executed by Git at specific points in the workflow:"
        echo ""
        echo "- **pre-commit**: Before each commit"
        echo "- **commit-msg**: When creating commit messages"
        echo "- **pre-push**: Before pushing to remote"
        echo "- **post-commit**: After each commit"
        echo "- **post-merge**: After merge operations"
        echo ""
        
    } > "$output_file"
    
    echo "Hooks documentation generated: $output_file"
}
```

This comprehensive Git hooks management system provides everything needed to set up, maintain, and troubleshoot Git hooks across different development environments and team configurations.