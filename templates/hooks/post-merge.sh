#!/bin/bash
# Claude Code Post-Merge Hook
# Handles cleanup and updates after merge operations

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

# Hook argument: 1 if merge was a squash merge, 0 otherwise
SQUASH_MERGE="$1"

print_status "Running post-merge cleanup and updates..."

# Update dependencies if package files changed
update_dependencies() {
    local files_changed=$(git diff-tree --no-commit-id --name-only -r HEAD^1 HEAD 2>/dev/null || true)
    local deps_updated=false
    
    if echo "$files_changed" | grep -q "package\.json"; then
        if command -v npm >/dev/null 2>&1; then
            print_status "package.json changed, updating npm dependencies..."
            if npm install >/dev/null 2>&1; then
                print_success "npm dependencies updated"
                deps_updated=true
            else
                print_warning "npm install failed"
            fi
        fi
    fi
    
    if echo "$files_changed" | grep -q "requirements\.txt"; then
        if command -v pip >/dev/null 2>&1; then
            print_status "requirements.txt changed, updating pip dependencies..."
            if pip install -r requirements.txt >/dev/null 2>&1; then
                print_success "pip dependencies updated"
                deps_updated=true
            else
                print_warning "pip install failed"
            fi
        fi
    fi
    
    if echo "$files_changed" | grep -q "Cargo\.toml"; then
        if command -v cargo >/dev/null 2>&1; then
            print_status "Cargo.toml changed, updating Rust dependencies..."
            if cargo check >/dev/null 2>&1; then
                print_success "Rust dependencies updated"
                deps_updated=true
            else
                print_warning "cargo check failed"
            fi
        fi
    fi
    
    if echo "$files_changed" | grep -q "go\.mod"; then
        if command -v go >/dev/null 2>&1; then
            print_status "go.mod changed, updating Go dependencies..."
            if go mod tidy >/dev/null 2>&1; then
                print_success "Go dependencies updated"
                deps_updated=true
            else
                print_warning "go mod tidy failed"
            fi
        fi
    fi
    
    if echo "$files_changed" | grep -q "composer\.json"; then
        if command -v composer >/dev/null 2>&1; then
            print_status "composer.json changed, updating PHP dependencies..."
            if composer install >/dev/null 2>&1; then
                print_success "PHP dependencies updated"
                deps_updated=true
            else
                print_warning "composer install failed"
            fi
        fi
    fi
    
    return 0
}

# Check if CLAUDE.md needs merge resolution
check_claude_md_conflicts() {
    if [[ -f "CLAUDE.md" ]]; then
        # Check for merge conflict markers
        if grep -q "<<<<<<< \|======= \|>>>>>>> " "CLAUDE.md"; then
            print_error "CLAUDE.md has unresolved merge conflicts!"
            print_status "Please resolve conflicts and commit again"
            return 1
        fi
        
        # Check if template section marker is present
        if ! grep -q "# ========== CLAUDE FLOW TEMPLATE ==========" "CLAUDE.md"; then
            print_warning "CLAUDE.md missing template section marker"
            print_status "Consider running 'claude-merge' to update template section"
        fi
    fi
    
    return 0
}

# Run post-merge tests if configured
run_post_merge_tests() {
    if [[ "${CLAUDE_HOOKS_RUN_TESTS_POSTMERGE:-false}" == "true" ]]; then
        if [[ -n "$TEST_COMMAND" ]] && command -v ${TEST_COMMAND%% *} >/dev/null 2>&1; then
            print_status "Running post-merge tests: $TEST_COMMAND"
            if ! $TEST_COMMAND; then
                print_error "Post-merge tests failed!"
                print_status "The merge was completed but tests are now failing"
                return 1
            fi
            print_success "Post-merge tests passed"
        fi
    else
        print_status "Post-merge tests disabled"
    fi
    
    return 0
}

# Update project metadata
update_project_metadata() {
    local merge_info_file=".claude/stats/last_merge.json"
    
    if [[ ! -d ".claude/stats" ]]; then
        mkdir -p ".claude/stats"
    fi
    
    local merge_commit=$(git rev-parse HEAD)
    local merge_date=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local merged_branch=$(git log --merges -n 1 --pretty=format:"%s" | sed 's/Merge branch //' | sed "s/'//g" | awk '{print $1}' || echo "unknown")
    
    cat > "$merge_info_file" << EOF
{
    "merge_commit": "$merge_commit",
    "merge_date": "$merge_date",
    "merged_branch": "$merged_branch",
    "squash_merge": $([[ "$SQUASH_MERGE" == "1" ]] && echo "true" || echo "false"),
    "project": "$(basename "$PROJECT_ROOT")"
}
EOF
    
    print_status "Merge metadata updated"
}

# Clean up temporary files and caches
cleanup_after_merge() {
    # Clean up common temporary files
    local temp_patterns=(
        "*.tmp"
        "*.temp"
        ".DS_Store"
        "Thumbs.db"
        "*.orig"
        "*.rej"
    )
    
    for pattern in "${temp_patterns[@]}"; do
        find . -name "$pattern" -type f -delete 2>/dev/null || true
    done
    
    # Clean up node_modules/.cache if it exists
    if [[ -d "node_modules/.cache" ]]; then
        rm -rf "node_modules/.cache" 2>/dev/null || true
    fi
    
    # Clean up Python cache
    find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
    find . -name "*.pyc" -type f -delete 2>/dev/null || true
    
    print_status "Temporary files cleaned up"
}

# Send merge notifications
send_merge_notifications() {
    if [[ "${CLAUDE_HOOKS_NOTIFICATIONS:-false}" == "true" ]]; then
        local merge_commit=$(git rev-parse --short HEAD)
        local merged_branch=$(git log --merges -n 1 --pretty=format:"%s" | sed 's/Merge branch //' | sed "s/'//g" | awk '{print $1}' || echo "unknown")
        
        # Webhook notification
        if [[ -n "$CLAUDE_HOOKS_WEBHOOK_URL" ]]; then
            local payload=$(cat <<EOF
{
    "event": "merge",
    "project": "$(basename "$PROJECT_ROOT")",
    "commit": "$merge_commit",
    "merged_branch": "$merged_branch",
    "squash_merge": $([[ "$SQUASH_MERGE" == "1" ]] && echo "true" || echo "false"),
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
)
            
            if command -v curl >/dev/null 2>&1; then
                curl -X POST "$CLAUDE_HOOKS_WEBHOOK_URL" \
                    -H "Content-Type: application/json" \
                    -d "$payload" \
                    >/dev/null 2>&1 || true
                print_status "Merge notification sent"
            fi
        fi
    fi
}

# Main execution
main() {
    # Skip if hooks are disabled
    if [[ "${CLAUDE_HOOKS_POST_MERGE_DISABLED:-false}" == "true" ]]; then
        print_status "Post-merge hooks disabled"
        return 0
    fi
    
    local exit_code=0
    
    print_status "Merge type: $([[ "$SQUASH_MERGE" == "1" ]] && echo "squash" || echo "regular")"
    
    # Check for CLAUDE.md conflicts (this can fail)
    if ! check_claude_md_conflicts; then
        exit_code=1
    fi
    
    # Update dependencies (this should not fail the hook)
    update_dependencies
    
    # Run post-merge tests if enabled (this can fail)
    if ! run_post_merge_tests; then
        exit_code=1
    fi
    
    # Update metadata (this should not fail)
    update_project_metadata
    
    # Clean up temporary files (this should not fail)
    cleanup_after_merge
    
    # Send notifications (this should not fail)
    send_merge_notifications
    
    if [[ $exit_code -eq 0 ]]; then
        print_success "Post-merge processing completed successfully"
    else
        print_error "Post-merge processing completed with issues"
        print_status "The merge was successful but some post-merge checks failed"
    fi
    
    # Show helpful information
    print_status "Current branch: $(git rev-parse --abbrev-ref HEAD)"
    print_status "Last commit: $(git rev-parse --short HEAD)"
    
    return $exit_code
}

# Run main function
main "$@"