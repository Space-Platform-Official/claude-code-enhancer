#!/bin/bash
# Claude Code Pre-Push Hook
# Runs comprehensive quality checks before pushing to remote

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[HOOK]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[HOOK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[HOOK]${NC} $1"
}

print_error() {
    echo -e "${RED}[HOOK]${NC} $1"
}

# Get project root
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"

# Load project configuration if it exists
if [[ -f ".claude/config/env.sh" ]]; then
    source ".claude/config/env.sh"
fi

print_status "Running pre-push quality gate checks..."

# Parse hook arguments
remote="$1"
url="$2"

# Read from stdin for commit ranges
while read local_ref local_sha remote_ref remote_sha; do
    if [[ "$local_sha" == "0000000000000000000000000000000000000000" ]]; then
        # Branch is being deleted
        continue
    fi
    
    if [[ "$remote_sha" == "0000000000000000000000000000000000000000" ]]; then
        # New branch, check all commits
        range="$local_sha"
    else
        # Existing branch, check new commits
        range="$remote_sha..$local_sha"
    fi
    
    # Store range for later use
    COMMIT_RANGE="$range"
done

# Comprehensive test suite
run_full_tests() {
    if [[ -n "$TEST_COMMAND" ]] && command -v ${TEST_COMMAND%% *} >/dev/null 2>&1; then
        print_status "Running full test suite: $TEST_COMMAND"
        if ! $TEST_COMMAND; then
            print_error "Test suite failed - cannot push to remote"
            return 1
        fi
        print_success "All tests passed"
    else
        print_warning "No test command configured - skipping tests"
    fi
    return 0
}

# Build verification
run_build_check() {
    if [[ -n "$BUILD_COMMAND" ]] && command -v ${BUILD_COMMAND%% *} >/dev/null 2>&1; then
        print_status "Running build verification: $BUILD_COMMAND"
        if ! $BUILD_COMMAND; then
            print_error "Build failed - cannot push to remote"
            return 1
        fi
        print_success "Build successful"
    else
        print_status "No build command configured - skipping build check"
    fi
    return 0
}

# Security check for sensitive data
run_security_check() {
    local security_issues=false
    
    print_status "Running security checks..."
    
    # Check for common secret patterns in new commits
    if [[ -n "$COMMIT_RANGE" ]]; then
        local changed_files=$(git diff-tree --no-commit-id --name-only -r $COMMIT_RANGE 2>/dev/null || true)
        
        if [[ -n "$changed_files" ]]; then
            for file in $changed_files; do
                if [[ -f "$file" ]]; then
                    # Check for API keys, passwords, etc.
                    if git log --oneline -p $COMMIT_RANGE -- "$file" | grep -q -E "(api_key|password|secret|token|private_key)" 2>/dev/null; then
                        print_error "Potential secret detected in commit history for $file"
                        security_issues=true
                    fi
                    
                    # Check for environment files
                    if [[ "$file" =~ \.(env|key|pem|p12)$ ]]; then
                        print_warning "Sensitive file type in commit: $file"
                    fi
                fi
            done
        fi
    fi
    
    # Check for large files
    local large_files=$(git diff-tree --no-commit-id --name-only -r $COMMIT_RANGE 2>/dev/null | xargs -I {} stat -f%z {} 2>/dev/null | awk '$1 > 10485760' || true)
    if [[ -n "$large_files" ]]; then
        print_warning "Large files detected in commit (>10MB) - consider using Git LFS"
    fi
    
    if [[ "$security_issues" == "true" ]]; then
        print_error "Security issues detected - cannot push to remote"
        return 1
    fi
    
    print_success "Security checks passed"
    return 0
}

# Code quality check
run_quality_check() {
    local quality_issues=false
    
    print_status "Running code quality checks..."
    
    # Run linter if available
    if [[ -n "$LINT_COMMAND" ]] && command -v ${LINT_COMMAND%% *} >/dev/null 2>&1; then
        if ! $LINT_COMMAND; then
            print_error "Linting failed - fix issues before pushing"
            quality_issues=true
        fi
    fi
    
    # Check complexity rules from CLAUDE.md
    if [[ -f "CLAUDE.md" ]]; then
        # Verify CLAUDE.md has mandatory sections
        if ! grep -q "Development Partnership" "CLAUDE.md"; then
            print_error "CLAUDE.md missing 'Development Partnership' section"
            quality_issues=true
        fi
        
        # Check for over-engineering patterns if we have new code
        if [[ -n "$COMMIT_RANGE" ]]; then
            local new_files=$(git diff-tree --no-commit-id --name-only --diff-filter=A -r $COMMIT_RANGE 2>/dev/null || true)
            local file_count=$(echo "$new_files" | wc -l | xargs)
            
            if [[ $file_count -gt 5 ]]; then
                print_warning "Many new files created ($file_count) - verify this follows complexity guidelines"
            fi
        fi
    else
        print_warning "No CLAUDE.md found - consider adding development guidelines"
    fi
    
    if [[ "$quality_issues" == "true" ]]; then
        print_error "Quality checks failed - cannot push to remote"
        return 1
    fi
    
    print_success "Code quality checks passed"
    return 0
}

# Branch protection check
check_branch_protection() {
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Check if pushing to protected branches
    if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
        if [[ "${CLAUDE_HOOKS_PROTECT_MAIN:-true}" == "true" ]]; then
            print_error "Direct push to $current_branch branch is not allowed"
            print_status "Please use a feature branch and create a pull request"
            return 1
        fi
    fi
    
    # Check for proper commit message format
    if [[ -n "$COMMIT_RANGE" ]]; then
        local invalid_commits=$(git log --oneline --pretty=format:"%s" $COMMIT_RANGE | grep -v -E "^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+" || true)
        if [[ -n "$invalid_commits" ]]; then
            print_warning "Some commits don't follow conventional commit format:"
            echo "$invalid_commits"
        fi
    fi
    
    return 0
}

# Main execution
main() {
    local exit_code=0
    
    # Skip if hooks are disabled
    if [[ "${CLAUDE_HOOKS_PRE_PUSH_DISABLED:-false}" == "true" ]]; then
        print_status "Pre-push hooks disabled"
        return 0
    fi
    
    print_status "Pushing to: $remote ($url)"
    
    # Run security checks (mandatory)
    if ! run_security_check; then
        exit_code=1
    fi
    
    # Run quality checks (mandatory)
    if ! run_quality_check; then
        exit_code=1
    fi
    
    # Run tests (can be disabled)
    if [[ "${CLAUDE_HOOKS_RUN_TESTS_PREPUSH:-true}" == "true" ]]; then
        if ! run_full_tests; then
            exit_code=1
        fi
    else
        print_status "Pre-push tests disabled"
    fi
    
    # Run build check (can be disabled)
    if [[ "${CLAUDE_HOOKS_RUN_BUILD_PREPUSH:-true}" == "true" ]]; then
        if ! run_build_check; then
            exit_code=1
        fi
    else
        print_status "Pre-push build check disabled"
    fi
    
    # Check branch protection rules
    if ! check_branch_protection; then
        exit_code=1
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        print_success "All pre-push checks passed! Ready to push."
    else
        print_error "Pre-push checks failed! Push blocked."
        print_status ""
        print_status "To bypass these checks (not recommended):"
        print_status "git push --no-verify"
        print_status ""
        print_status "To disable specific checks, set environment variables:"
        print_status "CLAUDE_HOOKS_RUN_TESTS_PREPUSH=false"
        print_status "CLAUDE_HOOKS_RUN_BUILD_PREPUSH=false"
        print_status "CLAUDE_HOOKS_PROTECT_MAIN=false"
    fi
    
    return $exit_code
}

# Run main function
main "$@"