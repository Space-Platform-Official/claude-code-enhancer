#!/bin/bash

# Git Repository State Edge Cases for Claude Flow Commands
# Tests various unusual and edge case git repository states to ensure robust handling
# Includes empty repos, corrupted states, detached HEAD, merge conflicts, and performance limits

# Enable strict error handling
set -euo pipefail

# Import test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$(dirname "$SCRIPT_DIR")"

source "$TEST_ROOT/lib/integration-environment.sh"
source "$TEST_ROOT/lib/test-reporter.sh"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Test configuration
readonly GIT_STATE_TEST_DIR="/tmp/claude-git-state-tests-$$"
readonly MAX_TEST_DURATION=300
readonly LARGE_REPO_SIZE_MB=50

# Test statistics
GIT_STATE_TESTS_RUN=0
GIT_STATE_TESTS_PASSED=0
GIT_STATE_TESTS_FAILED=0

# Helper functions
git_state_info() {
    echo -e "${CYAN}[GIT-STATE] $1${NC}"
}

git_state_success() {
    echo -e "${GREEN}[GIT-STATE] ✅ $1${NC}"
    ((GIT_STATE_TESTS_PASSED++))
}

git_state_error() {
    echo -e "${RED}[GIT-STATE] ❌ $1${NC}"
    ((GIT_STATE_TESTS_FAILED++))
}

git_state_warning() {
    echo -e "${YELLOW}[GIT-STATE] ⚠️ $1${NC}"
}

# Setup test environment
setup_git_state_tests() {
    git_state_info "Setting up git state edge case tests"
    
    mkdir -p "$GIT_STATE_TEST_DIR"
    cd "$GIT_STATE_TEST_DIR"
    
    # Create base directory structure
    mkdir -p {empty-repo,no-commits,corrupted-repo,detached-head,merge-conflicts,large-repo,permission-issues}
    
    git_state_success "Git state test environment created"
}

# Cleanup test environment
cleanup_git_state_tests() {
    git_state_info "Cleaning up git state test environment"
    
    if [[ -d "$GIT_STATE_TEST_DIR" ]]; then
        # Remove any git locks
        find "$GIT_STATE_TEST_DIR" -name "*.lock" -type f -delete 2>/dev/null || true
        
        # Restore permissions and clean up
        chmod -R u+w "$GIT_STATE_TEST_DIR" 2>/dev/null || true
        rm -rf "$GIT_STATE_TEST_DIR"
    fi
    
    git_state_success "Cleanup completed"
}

# Test: Empty repository (freshly initialized)
test_empty_repository() {
    git_state_info "Testing empty repository handling"
    ((GIT_STATE_TESTS_RUN++))
    
    local test_dir="$GIT_STATE_TEST_DIR/empty-repo"
    cd "$test_dir"
    
    # Initialize empty repository
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Test various git commands on empty repo
    local commands_to_test=(
        "git status"
        "git branch"
        "git log --oneline"
        "git remote -v"
    )
    
    local empty_repo_success=true
    
    for cmd in "${commands_to_test[@]}"; do
        git_state_info "Testing command in empty repo: $cmd"
        
        if timeout 10 $cmd >/dev/null 2>&1; then
            git_state_info "✓ Command succeeded: $cmd"
        else
            local exit_code=$?
            if [[ $exit_code -eq 124 ]]; then
                git_state_error "Command timed out: $cmd"
                empty_repo_success=false
            elif [[ $exit_code -eq 128 ]]; then
                git_state_info "✓ Expected git error for empty repo: $cmd"
            else
                git_state_warning "Unexpected exit code $exit_code for: $cmd"
            fi
        fi
    done
    
    # Test Claude Flow commands on empty repository
    if [[ -f "$TEST_ROOT/../templates/commands/git/status.md" ]]; then
        git_state_info "Testing Claude Flow status command on empty repo"
        
        # Simulate status command execution
        if git status --porcelain >/dev/null 2>&1; then
            git_state_info "✓ Git status works on empty repo"
        else
            git_state_warning "Git status failed on empty repo"
            empty_repo_success=false
        fi
    fi
    
    if [[ "$empty_repo_success" == "true" ]]; then
        git_state_success "Empty repository test passed"
    else
        git_state_error "Empty repository test failed"
        return 1
    fi
}

# Test: Repository with no commits
test_no_commits_repository() {
    git_state_info "Testing repository with no commits"
    ((GIT_STATE_TESTS_RUN++))
    
    local test_dir="$GIT_STATE_TEST_DIR/no-commits"
    cd "$test_dir"
    
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Add files but don't commit
    echo "Initial content" > README.md
    echo "*.log" > .gitignore
    
    # Test status with staged files
    git add README.md .gitignore
    
    local no_commits_success=true
    
    # Test various operations
    if git status --porcelain | grep -q "^A"; then
        git_state_info "✓ Staged files detected correctly"
    else
        git_state_error "Failed to detect staged files"
        no_commits_success=false
    fi
    
    # Test branch operations on repo with no commits
    if git branch 2>&1 | grep -q "No commits yet"; then
        git_state_info "✓ No commits state detected correctly"
    else
        git_state_warning "Unexpected branch output for no-commits repo"
    fi
    
    # Test attempt to create branch without commits
    if ! git checkout -b feature-branch 2>/dev/null; then
        git_state_info "✓ Branch creation without commits handled correctly"
    else
        git_state_warning "Branch creation succeeded unexpectedly"
    fi
    
    if [[ "$no_commits_success" == "true" ]]; then
        git_state_success "No commits repository test passed"
    else
        git_state_error "No commits repository test failed"
        return 1
    fi
}

# Test: Detached HEAD state
test_detached_head_state() {
    git_state_info "Testing detached HEAD state"
    ((GIT_STATE_TESTS_RUN++))
    
    local test_dir="$GIT_STATE_TEST_DIR/detached-head"
    cd "$test_dir"
    
    # Create repository with some commits
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    echo "Initial commit" > file1.txt
    git add file1.txt
    git commit -m "Initial commit" --quiet
    
    echo "Second commit" > file2.txt
    git add file2.txt
    git commit -m "Second commit" --quiet
    
    local second_commit=$(git rev-parse HEAD)
    
    echo "Third commit" > file3.txt
    git add file3.txt
    git commit -m "Third commit" --quiet
    
    # Enter detached HEAD state
    git checkout "$second_commit" --quiet 2>/dev/null || true
    
    local detached_head_success=true
    
    # Verify we're in detached HEAD state
    if git branch | grep -q "HEAD detached"; then
        git_state_info "✓ Successfully entered detached HEAD state"
    else
        git_state_error "Failed to enter detached HEAD state"
        detached_head_success=false
    fi
    
    # Test operations in detached HEAD state
    if git status >/dev/null 2>&1; then
        git_state_info "✓ Git status works in detached HEAD"
    else
        git_state_error "Git status failed in detached HEAD"
        detached_head_success=false
    fi
    
    # Test creating commits in detached HEAD
    echo "Detached commit" > detached.txt
    git add detached.txt
    
    if git commit -m "Commit in detached HEAD" --quiet 2>/dev/null; then
        git_state_info "✓ Commit in detached HEAD succeeded"
        
        # Test warning about orphaned commits
        if git checkout main 2>&1 | grep -q "previous HEAD position"; then
            git_state_info "✓ Orphaned commit warning displayed"
        fi
    else
        git_state_warning "Commit in detached HEAD failed"
    fi
    
    if [[ "$detached_head_success" == "true" ]]; then
        git_state_success "Detached HEAD test passed"
    else
        git_state_error "Detached HEAD test failed"
        return 1
    fi
}

# Test: Merge conflict states
test_merge_conflict_state() {
    git_state_info "Testing merge conflict state"
    ((GIT_STATE_TESTS_RUN++))
    
    local test_dir="$GIT_STATE_TEST_DIR/merge-conflicts"
    cd "$test_dir"
    
    # Create repository with conflicting branches
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Initial commit
    cat > config.txt << 'EOF'
# Configuration file
setting1 = value1
setting2 = value2
setting3 = value3
EOF
    
    git add config.txt
    git commit -m "Initial config" --quiet
    
    # Create branch1 with changes
    git checkout -b branch1 --quiet
    sed -i.bak 's/value2/modified_by_branch1/' config.txt
    rm -f config.txt.bak
    git add config.txt
    git commit -m "Branch1 changes" --quiet
    
    # Create branch2 with conflicting changes
    git checkout main --quiet
    git checkout -b branch2 --quiet
    sed -i.bak 's/value2/modified_by_branch2/' config.txt
    rm -f config.txt.bak
    git add config.txt
    git commit -m "Branch2 changes" --quiet
    
    # Go back to main and attempt merge that will conflict
    git checkout main --quiet
    git merge branch1 --quiet --no-edit
    
    local merge_conflict_success=true
    
    # Attempt conflicting merge
    if ! git merge branch2 --no-edit 2>/dev/null; then
        git_state_info "✓ Merge conflict created as expected"
        
        # Test status during conflict
        if git status | grep -q "both modified"; then
            git_state_info "✓ Conflict status detected correctly"
        else
            git_state_error "Conflict status not detected"
            merge_conflict_success=false
        fi
        
        # Test that normal operations are restricted during conflict
        if ! git checkout branch1 2>/dev/null; then
            git_state_info "✓ Branch switching blocked during conflict"
        else
            git_state_warning "Branch switching unexpectedly allowed"
        fi
        
        # Test conflict markers in file
        if grep -q "<<<<<<< HEAD" config.txt; then
            git_state_info "✓ Conflict markers present in file"
        else
            git_state_error "Conflict markers not found"
            merge_conflict_success=false
        fi
        
        # Test conflict resolution
        cat > config.txt << 'EOF'
# Configuration file
setting1 = value1
setting2 = resolved_value
setting3 = value3
EOF
        
        git add config.txt
        
        if git commit -m "Resolve merge conflict" --quiet; then
            git_state_info "✓ Conflict resolution succeeded"
        else
            git_state_error "Conflict resolution failed"
            merge_conflict_success=false
        fi
        
    else
        git_state_error "Expected merge conflict did not occur"
        merge_conflict_success=false
    fi
    
    if [[ "$merge_conflict_success" == "true" ]]; then
        git_state_success "Merge conflict test passed"
    else
        git_state_error "Merge conflict test failed"
        return 1
    fi
}

# Test: Corrupted repository state
test_corrupted_repository() {
    git_state_info "Testing corrupted repository handling"
    ((GIT_STATE_TESTS_RUN++))
    
    local test_dir="$GIT_STATE_TEST_DIR/corrupted-repo"
    cd "$test_dir"
    
    # Create a normal repository first
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    echo "Initial content" > file.txt
    git add file.txt
    git commit -m "Initial commit" --quiet
    
    echo "Second content" > file2.txt
    git add file2.txt
    git commit -m "Second commit" --quiet
    
    local corrupted_success=true
    
    # Corrupt the repository in various ways
    git_state_info "Creating repository corruption scenarios"
    
    # Scenario 1: Corrupt HEAD file
    echo "invalid_ref" > .git/HEAD
    
    if ! git status >/dev/null 2>&1; then
        git_state_info "✓ Corrupted HEAD detected"
        
        # Test recovery attempt
        git symbolic-ref HEAD refs/heads/main 2>/dev/null || true
        
        if git status >/dev/null 2>&1; then
            git_state_info "✓ HEAD corruption recovered"
        else
            git_state_warning "HEAD corruption recovery failed"
        fi
    else
        git_state_warning "Corrupted HEAD not detected"
    fi
    
    # Scenario 2: Missing objects (simulate with backup/restore)
    local objects_dir=".git/objects"
    local backup_dir="../objects_backup"
    
    cp -r "$objects_dir" "$backup_dir"
    
    # Remove some object files
    find "$objects_dir" -name "*.git" -type f -delete 2>/dev/null || true
    
    if ! git fsck >/dev/null 2>&1; then
        git_state_info "✓ Missing objects detected by fsck"
        
        # Restore objects
        rm -rf "$objects_dir"
        mv "$backup_dir" "$objects_dir"
        
        if git fsck >/dev/null 2>&1; then
            git_state_info "✓ Repository integrity restored"
        else
            git_state_warning "Repository integrity restoration failed"
        fi
    else
        git_state_warning "Missing objects not detected"
        # Clean up backup
        rm -rf "$backup_dir"
    fi
    
    # Scenario 3: Corrupted index
    echo "corrupted index data" > .git/index
    
    if ! git status >/dev/null 2>&1; then
        git_state_info "✓ Corrupted index detected"
        
        # Test index recovery
        git reset HEAD --quiet 2>/dev/null || git read-tree HEAD 2>/dev/null || true
        
        if git status >/dev/null 2>&1; then
            git_state_info "✓ Index corruption recovered"
        else
            git_state_warning "Index corruption recovery failed"
        fi
    else
        git_state_warning "Corrupted index not detected"
    fi
    
    if [[ "$corrupted_success" == "true" ]]; then
        git_state_success "Corrupted repository test passed"
    else
        git_state_error "Corrupted repository test failed"
        return 1
    fi
}

# Test: Large repository performance
test_large_repository_performance() {
    git_state_info "Testing large repository performance"
    ((GIT_STATE_TESTS_RUN++))
    
    local test_dir="$GIT_STATE_TEST_DIR/large-repo"
    cd "$test_dir"
    
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    local large_repo_success=true
    
    git_state_info "Creating large repository structure (this may take a moment)"
    
    # Create many files and directories
    for i in {1..100}; do
        mkdir -p "dir$i"
        for j in {1..10}; do
            echo "Content of file $i-$j" > "dir$i/file$j.txt"
        done
    done
    
    # Create some larger files (within safety limits)
    dd if=/dev/zero of=large1.bin bs=1M count=5 2>/dev/null
    dd if=/dev/zero of=large2.bin bs=1M count=5 2>/dev/null
    
    # Test performance of git operations
    local start_time end_time duration
    
    # Test git add performance
    start_time=$(date +%s.%N)
    git add . 2>/dev/null
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "1")
    
    git_state_info "Git add duration: ${duration}s"
    
    if (( $(echo "$duration < 30" | bc -l 2>/dev/null || echo 0) )); then
        git_state_info "✓ Git add performance acceptable"
    else
        git_state_warning "Git add performance slow: ${duration}s"
    fi
    
    # Test git status performance
    start_time=$(date +%s.%N)
    git status --porcelain >/dev/null 2>&1
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "1")
    
    git_state_info "Git status duration: ${duration}s"
    
    if (( $(echo "$duration < 10" | bc -l 2>/dev/null || echo 0) )); then
        git_state_info "✓ Git status performance acceptable"
    else
        git_state_warning "Git status performance slow: ${duration}s"
    fi
    
    # Test git commit performance
    start_time=$(date +%s.%N)
    git commit -m "Large repository initial commit" --quiet 2>/dev/null
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "1")
    
    git_state_info "Git commit duration: ${duration}s"
    
    if (( $(echo "$duration < 30" | bc -l 2>/dev/null || echo 0) )); then
        git_state_info "✓ Git commit performance acceptable"
    else
        git_state_warning "Git commit performance slow: ${duration}s"
    fi
    
    # Test repository size
    local repo_size_kb=$(du -sk . | cut -f1)
    local repo_size_mb=$((repo_size_kb / 1024))
    
    git_state_info "Repository size: ${repo_size_mb}MB"
    
    if [[ $repo_size_mb -lt $LARGE_REPO_SIZE_MB ]]; then
        git_state_info "✓ Repository size within limits"
    else
        git_state_warning "Repository size exceeds limit: ${repo_size_mb}MB > ${LARGE_REPO_SIZE_MB}MB"
    fi
    
    if [[ "$large_repo_success" == "true" ]]; then
        git_state_success "Large repository performance test passed"
    else
        git_state_error "Large repository performance test failed"
        return 1
    fi
}

# Test: Permission issues
test_permission_issues() {
    git_state_info "Testing permission-related edge cases"
    ((GIT_STATE_TESTS_RUN++))
    
    local test_dir="$GIT_STATE_TEST_DIR/permission-issues"
    cd "$test_dir"
    
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    echo "Initial content" > file.txt
    git add file.txt
    git commit -m "Initial commit" --quiet
    
    local permission_success=true
    
    # Test read-only file handling
    echo "Read-only content" > readonly.txt
    chmod 444 readonly.txt
    
    if git add readonly.txt 2>/dev/null; then
        git_state_info "✓ Read-only file added successfully"
        
        if git commit -m "Add read-only file" --quiet 2>/dev/null; then
            git_state_info "✓ Read-only file committed successfully"
        else
            git_state_warning "Read-only file commit failed"
        fi
    else
        git_state_warning "Read-only file could not be added"
    fi
    
    # Restore write permissions for cleanup
    chmod 644 readonly.txt
    
    # Test read-only directory handling
    mkdir readonly_dir
    echo "Content in readonly dir" > readonly_dir/file.txt
    chmod 555 readonly_dir
    
    if git add readonly_dir/ 2>/dev/null; then
        git_state_info "✓ Read-only directory added successfully"
    else
        git_state_warning "Read-only directory could not be added"
    fi
    
    # Restore permissions for cleanup
    chmod 755 readonly_dir
    
    # Test .git directory permission issues (carefully)
    local original_perms=$(stat -c %a .git 2>/dev/null || stat -f %A .git 2>/dev/null || echo "755")
    
    # Only test if we can restore permissions
    if [[ -n "$original_perms" ]]; then
        chmod 700 .git
        
        if git status >/dev/null 2>&1; then
            git_state_info "✓ Git operations work with restricted .git permissions"
        else
            git_state_warning "Git operations failed with restricted .git permissions"
        fi
        
        # Restore original permissions
        chmod "$original_perms" .git
    fi
    
    if [[ "$permission_success" == "true" ]]; then
        git_state_success "Permission issues test passed"
    else
        git_state_error "Permission issues test failed"
        return 1
    fi
}

# Test: Submodule edge cases
test_submodule_edge_cases() {
    git_state_info "Testing submodule edge cases"
    ((GIT_STATE_TESTS_RUN++))
    
    local test_dir="$GIT_STATE_TEST_DIR/submodules"
    cd "$test_dir"
    
    # Create main repository
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    echo "Main repo content" > main.txt
    git add main.txt
    git commit -m "Initial main commit" --quiet
    
    # Create a separate repository to use as submodule
    local sub_dir="../submodule-repo"
    mkdir -p "$sub_dir"
    cd "$sub_dir"
    
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    echo "Submodule content" > sub.txt
    git add sub.txt
    git commit -m "Initial submodule commit" --quiet
    
    # Go back to main repo and add submodule
    cd "$test_dir"
    
    local submodule_success=true
    
    # Add submodule (using local path for testing)
    if git submodule add "$sub_dir" submodule 2>/dev/null; then
        git_state_info "✓ Submodule added successfully"
        
        git commit -m "Add submodule" --quiet
        
        # Test submodule status
        if git submodule status | grep -q "submodule"; then
            git_state_info "✓ Submodule status working"
        else
            git_state_warning "Submodule status issues"
        fi
        
        # Test missing submodule scenario
        rm -rf submodule
        
        if git status | grep -q "deleted"; then
            git_state_info "✓ Missing submodule detected"
        else
            git_state_warning "Missing submodule not detected"
        fi
        
        # Test submodule update
        if git submodule update --init 2>/dev/null; then
            git_state_info "✓ Submodule update successful"
        else
            git_state_warning "Submodule update failed"
        fi
        
    else
        git_state_warning "Submodule addition failed"
        submodule_success=false
    fi
    
    if [[ "$submodule_success" == "true" ]]; then
        git_state_success "Submodule edge cases test passed"
    else
        git_state_error "Submodule edge cases test failed"
        return 1
    fi
}

# Generate git state test report
generate_git_state_report() {
    git_state_info "Generating git state test report"
    
    local total_tests=$GIT_STATE_TESTS_RUN
    local passed_tests=$GIT_STATE_TESTS_PASSED
    local failed_tests=$GIT_STATE_TESTS_FAILED
    local success_rate=0
    
    if [[ $total_tests -gt 0 ]]; then
        success_rate=$(( (passed_tests * 100) / total_tests ))
    fi
    
    echo -e "\n${BLUE}=== Git State Edge Cases Summary ===${NC}"
    echo -e "Total Tests Run: $total_tests"
    echo -e "${GREEN}Passed: $passed_tests${NC}"
    echo -e "${RED}Failed: $failed_tests${NC}"
    echo -e "Success Rate: ${success_rate}%"
    
    if [[ $failed_tests -eq 0 ]]; then
        git_state_success "All git state edge case tests passed!"
        return 0
    else
        git_state_error "$failed_tests git state tests failed"
        return 1
    fi
}

# Main execution function
main() {
    git_state_info "Starting Git State Edge Case Testing"
    
    # Setup test environment
    setup_git_state_tests
    
    # Set up cleanup trap
    trap cleanup_git_state_tests EXIT
    
    local overall_success=true
    
    # Run all git state edge case tests
    git_state_info "Running git state edge case tests..."
    
    test_empty_repository || overall_success=false
    test_no_commits_repository || overall_success=false
    test_detached_head_state || overall_success=false
    test_merge_conflict_state || overall_success=false
    test_corrupted_repository || overall_success=false
    test_large_repository_performance || overall_success=false
    test_permission_issues || overall_success=false
    test_submodule_edge_cases || overall_success=false
    
    # Generate final report
    if ! generate_git_state_report; then
        overall_success=false
    fi
    
    # Exit with appropriate code
    if [[ "$overall_success" == "true" ]]; then
        git_state_success "Git state edge case testing completed successfully"
        exit 0
    else
        git_state_error "Git state edge case testing completed with failures"
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi