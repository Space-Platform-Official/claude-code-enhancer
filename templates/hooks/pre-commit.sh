#!/bin/bash
# Claude Code Pre-Commit Hook
# Runs quality checks before allowing commits

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

print_status "Running pre-commit quality checks..."

# Check if CLAUDE.md exists and has mandatory sections
check_claude_md() {
    if [[ -f "CLAUDE.md" ]]; then
        if ! grep -q "Development Partnership" "CLAUDE.md"; then
            print_warning "CLAUDE.md missing 'Development Partnership' section"
        fi
        if ! grep -q "Research → Plan → Implement" "CLAUDE.md"; then
            print_warning "CLAUDE.md missing critical workflow section"
        fi
    else
        print_warning "No CLAUDE.md found - consider adding development guidelines"
    fi
}

# Run linting if command is available
run_linting() {
    if [[ -n "$LINT_COMMAND" ]] && command -v ${LINT_COMMAND%% *} >/dev/null 2>&1; then
        print_status "Running linter: $LINT_COMMAND"
        if ! $LINT_COMMAND; then
            print_error "Linting failed - fix issues before committing"
            return 1
        fi
        print_success "Linting passed"
    else
        print_status "No linter configured or available"
    fi
}

# Run formatting if command is available
run_formatting() {
    if [[ -n "$FORMAT_COMMAND" ]] && command -v ${FORMAT_COMMAND%% *} >/dev/null 2>&1; then
        print_status "Running formatter: $FORMAT_COMMAND"
        if ! $FORMAT_COMMAND; then
            print_warning "Formatting command failed"
        else
            print_success "Code formatted"
        fi
    else
        print_status "No formatter configured or available"
    fi
}

# Run tests if command is available
run_tests() {
    if [[ -n "$TEST_COMMAND" ]] && command -v ${TEST_COMMAND%% *} >/dev/null 2>&1; then
        print_status "Running tests: $TEST_COMMAND"
        if ! $TEST_COMMAND; then
            print_error "Tests failed - fix issues before committing"
            return 1
        fi
        print_success "All tests passed"
    else
        print_status "No test command configured or available"
    fi
}

# Detect and unstage backup files to prevent them from being committed
detect_and_unstage_backups() {
    local backup_files_found=false
    local staged_backups=()
    
    # Get list of staged files and check for backup patterns
    while IFS= read -r staged_file; do
        # Check if file matches backup patterns
        if [[ "$staged_file" =~ \.backup\.[0-9]+ ]] || 
           [[ "$staged_file" =~ \.pre-rollback\.[0-9]+ ]] || 
           [[ "$staged_file" == *"_ENHANCED.md" ]] || 
           [[ "$staged_file" =~ \.(bak|orig)$ ]] || 
           [[ "$staged_file" == *"~" ]] || 
           [[ "$staged_file" =~ \.backup\.[0-9]{8}-[0-9]{6} ]]; then
            staged_backups+=("$staged_file")
            backup_files_found=true
        fi
    done < <(git diff --cached --name-only)
    
    if [[ "$backup_files_found" == true ]]; then
        print_warning "Backup files detected in staging area:"
        for file in "${staged_backups[@]}"; do
            echo "  - $file"
        done
        
        # Unstage backup files
        for file in "${staged_backups[@]}"; do
            git reset HEAD -- "$file" 2>/dev/null || true
        done
        
        print_success "Backup files automatically unstaged (${#staged_backups[@]} files)"
        print_status "These files remain in your working directory but won't be committed"
        
        # Log the action for transparency
        if [[ ! -d ".claude/logs" ]]; then
            mkdir -p ".claude/logs"
        fi
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Unstaged backup files: ${staged_backups[*]}" >> ".claude/logs/backup-prevention.log"
    fi
}

# Check for secrets or sensitive data
check_secrets() {
    local files_to_check=$(git diff --cached --name-only)
    local secrets_found=false
    
    if [[ -n "$files_to_check" ]]; then
        for file in $files_to_check; do
            if [[ -f "$file" ]]; then
                # Check for common secret patterns
                if grep -q -E "(api_key|password|secret|token|private_key)" "$file" 2>/dev/null; then
                    print_warning "Potential secret detected in $file - please review"
                fi
                
                # Check for common secret file patterns
                if [[ "$file" =~ \.(env|key|pem|p12)$ ]]; then
                    print_warning "Sensitive file type detected: $file"
                fi
            fi
        done
    fi
}

# Main execution
main() {
    local exit_code=0
    
    # Detect and unstage backup files first (non-blocking)
    detect_and_unstage_backups
    
    # Always check CLAUDE.md
    check_claude_md
    
    # Check for secrets
    check_secrets
    
    # Run quality checks (these can fail the commit)
    if ! run_linting; then
        exit_code=1
    fi
    
    # Run formatting (this should not fail the commit)
    run_formatting
    
    # Run tests if enabled for pre-commit
    if [[ "${CLAUDE_HOOKS_RUN_TESTS_PRECOMMIT:-false}" == "true" ]]; then
        if ! run_tests; then
            exit_code=1
        fi
    else
        print_status "Pre-commit tests disabled (set CLAUDE_HOOKS_RUN_TESTS_PRECOMMIT=true to enable)"
    fi
    
    if [[ $exit_code -eq 0 ]]; then
        print_success "Pre-commit checks passed!"
    else
        print_error "Pre-commit checks failed!"
    fi
    
    return $exit_code
}

# Run main function
main "$@"