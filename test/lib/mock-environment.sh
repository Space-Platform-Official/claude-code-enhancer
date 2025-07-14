#!/bin/bash

# Mock Environment Setup for Claude Flow Git Command Testing
# Provides functions to create and manage mock git environments and responses

# Enable strict error handling
set -euo pipefail

# Mock repository states
declare -A MOCK_REPO_STATE
MOCK_REPO_STATE[initialized]=false
MOCK_REPO_STATE[branch]="main"
MOCK_REPO_STATE[has_changes]=false
MOCK_REPO_STATE[has_staged]=false
MOCK_REPO_STATE[has_conflicts]=false
MOCK_REPO_STATE[has_untracked]=false
MOCK_REPO_STATE[last_commit]=""
MOCK_REPO_STATE[remote_exists]=true
MOCK_REPO_STATE[hooks_enabled]=true
MOCK_REPO_STATE[hook_result]="pass"

# Mock file system
declare -A MOCK_FILES
declare -A MOCK_FILE_SIZES
declare -A MOCK_FILE_CONTENT

# Mock git configuration
declare -A MOCK_GIT_CONFIG
MOCK_GIT_CONFIG[user.name]="Test User"
MOCK_GIT_CONFIG[user.email]="test@example.com"
MOCK_GIT_CONFIG[core.editor]="vim"

# Mock command history
declare -a MOCK_COMMAND_HISTORY

# Setup test environment for a specific test
setup_test_environment() {
    local test_name="$1"
    
    print_debug "Setting up environment for test: $test_name"
    
    # Reset mock state
    reset_mock_state
    
    # Create test-specific mock directory
    local test_dir="${TEMP_DIR}/${test_name}"
    mkdir -p "$test_dir"
    
    # Set up test-specific fixtures
    case "$test_name" in
        normal_commit_workflow)
            setup_normal_repo_state
            ;;
        precommit_hook_failure)
            setup_hook_failure_state
            ;;
        merge_conflicts)
            setup_conflict_state
            ;;
        protected_branch)
            setup_protected_branch_state
            ;;
        large_file_detection)
            setup_large_file_state
            ;;
        *)
            # Default setup
            setup_clean_repo_state
            ;;
    esac
    
    return 0
}

# Clean up test environment
cleanup_test_environment() {
    local test_name="$1"
    
    print_debug "Cleaning up environment for test: $test_name"
    
    # Clear command history for this test
    MOCK_COMMAND_HISTORY=()
    
    # Reset state
    reset_mock_state
    
    return 0
}

# Reset all mock state
reset_mock_state() {
    # Reset repository state
    MOCK_REPO_STATE[initialized]=true
    MOCK_REPO_STATE[branch]="main"
    MOCK_REPO_STATE[has_changes]=false
    MOCK_REPO_STATE[has_staged]=false
    MOCK_REPO_STATE[has_conflicts]=false
    MOCK_REPO_STATE[has_untracked]=false
    MOCK_REPO_STATE[last_commit]=""
    MOCK_REPO_STATE[remote_exists]=true
    MOCK_REPO_STATE[hooks_enabled]=true
    MOCK_REPO_STATE[hook_result]="pass"
    
    # Clear mock files
    MOCK_FILES=()
    MOCK_FILE_SIZES=()
    MOCK_FILE_CONTENT=()
    
    # Clear command history
    MOCK_COMMAND_HISTORY=()
}

# Setup states for different scenarios
setup_clean_repo_state() {
    MOCK_REPO_STATE[initialized]=true
    MOCK_REPO_STATE[branch]="main"
    MOCK_REPO_STATE[has_changes]=false
    MOCK_REPO_STATE[has_staged]=false
    MOCK_REPO_STATE[has_conflicts]=false
    MOCK_REPO_STATE[has_untracked]=false
    MOCK_REPO_STATE[last_commit]="abc123 Initial commit"
}

setup_normal_repo_state() {
    setup_clean_repo_state
    MOCK_REPO_STATE[branch]="feature/test-feature"
    MOCK_REPO_STATE[has_changes]=true
    MOCK_REPO_STATE[has_untracked]=true
    
    # Add mock files
    MOCK_FILES[src/main.js]="modified"
    MOCK_FILES[test/main.test.js]="new"
    MOCK_FILE_SIZES[src/main.js]=1024
    MOCK_FILE_SIZES[test/main.test.js]=512
    MOCK_FILE_CONTENT[src/main.js]="console.log('Hello World');"
}

setup_hook_failure_state() {
    setup_normal_repo_state
    MOCK_REPO_STATE[hooks_enabled]=true
    MOCK_REPO_STATE[hook_result]="fail"
    
    # Add file with linting error
    MOCK_FILES[src/error.js]="modified"
    MOCK_FILE_CONTENT[src/error.js]="console.log('Missing semicolon')"
}

setup_conflict_state() {
    setup_clean_repo_state
    MOCK_REPO_STATE[has_conflicts]=true
    MOCK_REPO_STATE[branch]="feature/merge-test"
    
    # Add conflicted file
    MOCK_FILES[src/conflict.js]="conflict"
    MOCK_FILE_CONTENT[src/conflict.js]="<<<<<<< HEAD
function test() {
    return 'main';
}
=======
function test() {
    return 'feature';
}
>>>>>>> feature/merge-test"
}

setup_protected_branch_state() {
    setup_clean_repo_state
    MOCK_REPO_STATE[branch]="main"  # On protected branch
    MOCK_REPO_STATE[has_changes]=true
    
    MOCK_FILES[src/main.js]="modified"
}

setup_large_file_state() {
    setup_normal_repo_state
    
    # Add large file
    MOCK_FILES[assets/large-video.mp4]="new"
    MOCK_FILE_SIZES[assets/large-video.mp4]=157286400  # 150MB
}

# Mock git command responses
mock_git_command() {
    local command="$1"
    shift
    local args=("$@")
    
    # Record command in history
    MOCK_COMMAND_HISTORY+=("git $command ${args[*]}")
    
    print_debug "Mock git command: git $command ${args[*]}"
    
    case "$command" in
        status)
            mock_git_status "${args[@]}"
            ;;
        add)
            mock_git_add "${args[@]}"
            ;;
        commit)
            mock_git_commit "${args[@]}"
            ;;
        branch)
            mock_git_branch "${args[@]}"
            ;;
        checkout)
            mock_git_checkout "${args[@]}"
            ;;
        push)
            mock_git_push "${args[@]}"
            ;;
        diff)
            mock_git_diff "${args[@]}"
            ;;
        log)
            mock_git_log "${args[@]}"
            ;;
        config)
            mock_git_config "${args[@]}"
            ;;
        *)
            echo "error: '$command' is not a git command."
            return 1
            ;;
    esac
}

# Mock git status
mock_git_status() {
    if [[ "${MOCK_REPO_STATE[initialized]}" != "true" ]]; then
        echo "fatal: not a git repository (or any of the parent directories): .git"
        return 128
    fi
    
    echo "On branch ${MOCK_REPO_STATE[branch]}"
    
    if [[ "${MOCK_REPO_STATE[has_conflicts]}" == "true" ]]; then
        echo "You have unmerged paths."
        echo "  (fix conflicts and run \"git commit\")"
        echo "  (use \"git merge --abort\" to abort the merge)"
        echo ""
        echo "Unmerged paths:"
        echo "  (use \"git add <file>...\" to mark resolution)"
        echo ""
        for file in "${!MOCK_FILES[@]}"; do
            if [[ "${MOCK_FILES[$file]}" == "conflict" ]]; then
                echo "        both modified:   $file"
            fi
        done
        echo ""
        return 0
    fi
    
    if [[ "${MOCK_REPO_STATE[has_staged]}" == "true" ]]; then
        echo "Changes to be committed:"
        echo "  (use \"git restore --staged <file>...\" to unstage)"
        echo ""
        for file in "${!MOCK_FILES[@]}"; do
            if [[ "${MOCK_FILES[$file]}" == "staged" ]]; then
                echo "        modified:   $file"
            fi
        done
        echo ""
    fi
    
    if [[ "${MOCK_REPO_STATE[has_changes]}" == "true" ]]; then
        echo "Changes not staged for commit:"
        echo "  (use \"git add <file>...\" to update what will be committed)"
        echo "  (use \"git restore <file>...\" to discard changes in working directory)"
        echo ""
        for file in "${!MOCK_FILES[@]}"; do
            if [[ "${MOCK_FILES[$file]}" == "modified" ]]; then
                echo "        modified:   $file"
            fi
        done
        echo ""
    fi
    
    if [[ "${MOCK_REPO_STATE[has_untracked]}" == "true" ]]; then
        echo "Untracked files:"
        echo "  (use \"git add <file>...\" to include in what will be committed)"
        echo ""
        for file in "${!MOCK_FILES[@]}"; do
            if [[ "${MOCK_FILES[$file]}" == "new" ]]; then
                echo "        $file"
            fi
        done
        echo ""
    fi
    
    if [[ "${MOCK_REPO_STATE[has_changes]}" == "false" && "${MOCK_REPO_STATE[has_staged]}" == "false" && "${MOCK_REPO_STATE[has_untracked]}" == "false" ]]; then
        echo "nothing to commit, working tree clean"
    fi
    
    return 0
}

# Mock git add
mock_git_add() {
    local files=("$@")
    
    if [[ "${#files[@]}" -eq 0 ]]; then
        echo "Nothing specified, nothing added."
        return 0
    fi
    
    for file in "${files[@]}"; do
        if [[ "$file" == "." || "$file" == "-A" || "$file" == "--all" ]]; then
            # Stage all files
            for f in "${!MOCK_FILES[@]}"; do
                if [[ "${MOCK_FILES[$f]}" == "modified" || "${MOCK_FILES[$f]}" == "new" ]]; then
                    MOCK_FILES[$f]="staged"
                fi
            done
            MOCK_REPO_STATE[has_staged]=true
            MOCK_REPO_STATE[has_changes]=false
            MOCK_REPO_STATE[has_untracked]=false
        elif [[ -n "${MOCK_FILES[$file]}" ]]; then
            # Stage specific file
            MOCK_FILES[$file]="staged"
            MOCK_REPO_STATE[has_staged]=true
            
            # Update other states
            local has_unstaged=false
            local has_untracked=false
            for f in "${!MOCK_FILES[@]}"; do
                if [[ "${MOCK_FILES[$f]}" == "modified" ]]; then
                    has_unstaged=true
                fi
                if [[ "${MOCK_FILES[$f]}" == "new" ]]; then
                    has_untracked=true
                fi
            done
            MOCK_REPO_STATE[has_changes]=$has_unstaged
            MOCK_REPO_STATE[has_untracked]=$has_untracked
        else
            echo "fatal: pathspec '$file' did not match any files"
            return 1
        fi
    done
    
    return 0
}

# Mock git commit
mock_git_commit() {
    local message=""
    local amend=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -m|--message)
                message="$2"
                shift 2
                ;;
            --amend)
                amend=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    if [[ "${MOCK_REPO_STATE[has_staged]}" != "true" && "$amend" != "true" ]]; then
        echo "On branch ${MOCK_REPO_STATE[branch]}"
        echo "nothing to commit, working tree clean"
        return 1
    fi
    
    # Check if on protected branch
    if [[ "${MOCK_REPO_STATE[branch]}" == "main" || "${MOCK_REPO_STATE[branch]}" == "master" ]]; then
        echo "ERROR: Direct commits to ${MOCK_REPO_STATE[branch]} are not allowed!"
        echo "Create a feature branch first: git checkout -b feature/your-feature"
        return 1
    fi
    
    # Run pre-commit hooks
    if [[ "${MOCK_REPO_STATE[hooks_enabled]}" == "true" ]]; then
        echo "Running pre-commit hooks..."
        if [[ "${MOCK_REPO_STATE[hook_result]}" == "fail" ]]; then
            echo "Pre-commit hook failed:"
            echo "  ✗ Linting errors found"
            echo "  src/error.js:1:28 error: Missing semicolon"
            return 1
        fi
    fi
    
    # Check for large files
    for file in "${!MOCK_FILES[@]}"; do
        if [[ "${MOCK_FILES[$file]}" == "staged" ]]; then
            local size="${MOCK_FILE_SIZES[$file]:-0}"
            if [[ $size -gt 104857600 ]]; then
                echo "ERROR: $file is over 100MB!"
                echo "Consider using Git LFS or excluding this file"
                return 1
            fi
        fi
    done
    
    # Simulate successful commit
    local commit_hash=$(generate_mock_commit_hash)
    MOCK_REPO_STATE[last_commit]="$commit_hash $message"
    
    # Reset file states
    for file in "${!MOCK_FILES[@]}"; do
        if [[ "${MOCK_FILES[$file]}" == "staged" ]]; then
            unset MOCK_FILES[$file]
        fi
    done
    
    MOCK_REPO_STATE[has_staged]=false
    
    echo "[${MOCK_REPO_STATE[branch]} $commit_hash] $message"
    echo " 3 files changed, 42 insertions(+), 7 deletions(-)"
    
    return 0
}

# Mock git branch
mock_git_branch() {
    local args=("$@")
    
    if [[ ${#args[@]} -eq 0 || "${args[0]}" == "--list" ]]; then
        # List branches
        if [[ "${MOCK_REPO_STATE[branch]}" == "main" ]]; then
            echo "* main"
        else
            echo "  main"
            echo "* ${MOCK_REPO_STATE[branch]}"
        fi
        echo "  develop"
        echo "  feature/old-feature"
    elif [[ "${args[0]}" == "--show-current" ]]; then
        echo "${MOCK_REPO_STATE[branch]}"
    elif [[ "${args[0]}" == "-d" || "${args[0]}" == "--delete" ]]; then
        local branch_to_delete="${args[1]}"
        if [[ "$branch_to_delete" == "${MOCK_REPO_STATE[branch]}" ]]; then
            echo "error: Cannot delete branch '$branch_to_delete' checked out at '/mock/repo'"
            return 1
        fi
        echo "Deleted branch $branch_to_delete (was abc1234)."
    else
        # Create new branch
        local new_branch="${args[0]}"
        echo "Branch '$new_branch' created."
    fi
    
    return 0
}

# Mock git checkout
mock_git_checkout() {
    local args=("$@")
    
    if [[ "${args[0]}" == "-b" ]]; then
        # Create and checkout new branch
        local new_branch="${args[1]}"
        MOCK_REPO_STATE[branch]="$new_branch"
        echo "Switched to a new branch '$new_branch'"
    else
        # Checkout existing branch
        local target_branch="${args[0]}"
        if [[ "$target_branch" == "main" || "$target_branch" == "develop" || "$target_branch" =~ ^feature/ ]]; then
            MOCK_REPO_STATE[branch]="$target_branch"
            echo "Switched to branch '$target_branch'"
        else
            echo "error: pathspec '$target_branch' did not match any file(s) known to git"
            return 1
        fi
    fi
    
    return 0
}

# Mock git push
mock_git_push() {
    local args=("$@")
    
    if [[ "${MOCK_REPO_STATE[remote_exists]}" != "true" ]]; then
        echo "fatal: No configured push destination."
        return 128
    fi
    
    # Check for conflicts
    if [[ "${MOCK_REPO_STATE[has_conflicts]}" == "true" ]]; then
        echo "error: you need to resolve your current index first"
        return 1
    fi
    
    # Simulate various push scenarios
    local push_result="${MOCK_REPO_STATE[push_result]:-success}"
    
    case "$push_result" in
        success)
            echo "Enumerating objects: 5, done."
            echo "Counting objects: 100% (5/5), done."
            echo "Delta compression using up to 8 threads"
            echo "Compressing objects: 100% (3/3), done."
            echo "Writing objects: 100% (3/3), 328 bytes | 328.00 KiB/s, done."
            echo "Total 3 (delta 2), reused 0 (delta 0)"
            echo "To https://github.com/user/repo.git"
            echo "   abc1234..def5678  ${MOCK_REPO_STATE[branch]} -> ${MOCK_REPO_STATE[branch]}"
            ;;
        rejected)
            echo "To https://github.com/user/repo.git"
            echo " ! [rejected]        ${MOCK_REPO_STATE[branch]} -> ${MOCK_REPO_STATE[branch]} (fetch first)"
            echo "error: failed to push some refs to 'https://github.com/user/repo.git'"
            echo "hint: Updates were rejected because the remote contains work that you do"
            echo "hint: not have locally. This is usually caused by another repository pushing"
            echo "hint: to the same ref. You may want to first integrate the remote changes"
            echo "hint: (e.g., 'git pull ...') before pushing again."
            return 1
            ;;
        non-fast-forward)
            echo "To https://github.com/user/repo.git"
            echo " ! [rejected]        ${MOCK_REPO_STATE[branch]} -> ${MOCK_REPO_STATE[branch]} (non-fast-forward)"
            echo "error: failed to push some refs to 'https://github.com/user/repo.git'"
            return 1
            ;;
    esac
    
    return 0
}

# Mock git diff
mock_git_diff() {
    local args=("$@")
    local cached=false
    
    for arg in "${args[@]}"; do
        if [[ "$arg" == "--cached" || "$arg" == "--staged" ]]; then
            cached=true
            break
        fi
    done
    
    if [[ "$cached" == "true" ]]; then
        # Show staged changes
        if [[ "${MOCK_REPO_STATE[has_staged]}" == "true" ]]; then
            echo "diff --git a/src/main.js b/src/main.js"
            echo "index abc123..def456 100644"
            echo "--- a/src/main.js"
            echo "+++ b/src/main.js"
            echo "@@ -1,3 +1,4 @@"
            echo " function main() {"
            echo "+    console.log('Hello World');"
            echo "     return 0;"
            echo " }"
        fi
    else
        # Show unstaged changes
        if [[ "${MOCK_REPO_STATE[has_changes]}" == "true" ]]; then
            echo "diff --git a/src/main.js b/src/main.js"
            echo "index abc123..def456 100644"
            echo "--- a/src/main.js"
            echo "+++ b/src/main.js"
            echo "@@ -1,3 +1,4 @@"
            echo " function main() {"
            echo "+    console.log('Modified');"
            echo "     return 0;"
            echo " }"
        fi
    fi
    
    return 0
}

# Mock git log
mock_git_log() {
    local args=("$@")
    local oneline=false
    local limit=5
    
    for i in "${!args[@]}"; do
        case "${args[$i]}" in
            --oneline)
                oneline=true
                ;;
            -n|-[0-9]*)
                if [[ "${args[$i]}" =~ ^-([0-9]+)$ ]]; then
                    limit="${BASH_REMATCH[1]}"
                elif [[ "${args[$i]}" == "-n" && -n "${args[$((i+1))]}" ]]; then
                    limit="${args[$((i+1))]}"
                fi
                ;;
        esac
    done
    
    # Generate mock commit history
    local commits=(
        "def5678:feat(api): add user authentication"
        "abc1234:fix(core): resolve memory leak issue"
        "789abcd:docs: update README with examples"
        "456defg:refactor: simplify error handling"
        "123456a:test: add unit tests for auth module"
    )
    
    local count=0
    for commit in "${commits[@]}"; do
        if [[ $count -ge $limit ]]; then
            break
        fi
        
        IFS=':' read -r hash message <<< "$commit"
        
        if [[ "$oneline" == "true" ]]; then
            echo "$hash $message"
        else
            echo "commit $hash"
            echo "Author: ${MOCK_GIT_CONFIG[user.name]} <${MOCK_GIT_CONFIG[user.email]}>"
            echo "Date:   $(date -R)"
            echo ""
            echo "    $message"
            echo ""
        fi
        
        ((count++))
    done
    
    return 0
}

# Mock git config
mock_git_config() {
    local args=("$@")
    
    if [[ ${#args[@]} -eq 1 ]]; then
        # Get config value
        local key="${args[0]}"
        if [[ -n "${MOCK_GIT_CONFIG[$key]}" ]]; then
            echo "${MOCK_GIT_CONFIG[$key]}"
        else
            return 1
        fi
    elif [[ ${#args[@]} -eq 2 ]]; then
        # Set config value
        local key="${args[0]}"
        local value="${args[1]}"
        MOCK_GIT_CONFIG[$key]="$value"
    fi
    
    return 0
}

# Generate mock commit hash
generate_mock_commit_hash() {
    # Generate a realistic-looking short hash
    local hash=""
    local chars="0123456789abcdef"
    for i in {1..7}; do
        hash+="${chars:$((RANDOM % 16)):1}"
    done
    echo "$hash"
}

# Mock pre-commit hook execution
mock_run_precommit_hooks() {
    if [[ "${MOCK_REPO_STATE[hooks_enabled]}" != "true" ]]; then
        return 0
    fi
    
    echo "Running pre-commit hooks..."
    
    case "${MOCK_REPO_STATE[hook_result]}" in
        pass)
            echo "✓ Linting passed"
            echo "✓ Tests passed"
            echo "✓ Security scan passed"
            return 0
            ;;
        fail)
            echo "✗ Linting failed"
            echo "  src/error.js:1:28 error: Missing semicolon"
            echo "  src/error.js:5:10 error: Undefined variable 'foo'"
            return 1
            ;;
        security)
            echo "✓ Linting passed"
            echo "✗ Security scan failed"
            echo "  Found hardcoded password in src/config.js:15"
            return 1
            ;;
    esac
}

# Check if file contains sensitive data
mock_check_sensitive_data() {
    local file="$1"
    local content="${MOCK_FILE_CONTENT[$file]:-}"
    
    if [[ "$content" =~ (password|secret|api_key|token).*=.*[\"\'].+[\"\'] ]]; then
        echo "WARNING: Possible sensitive data in $file"
        return 1
    fi
    
    return 0
}

# Validate command execution permissions
mock_validate_command_permissions() {
    local command="$1"
    
    # Check if command is allowed based on current state
    case "$command" in
        commit)
            if [[ "${MOCK_REPO_STATE[branch]}" == "main" || "${MOCK_REPO_STATE[branch]}" == "master" ]]; then
                echo "ERROR: Direct commits to protected branch not allowed"
                return 1
            fi
            ;;
        push)
            if [[ "${MOCK_REPO_STATE[has_conflicts]}" == "true" ]]; then
                echo "ERROR: Cannot push with unresolved conflicts"
                return 1
            fi
            ;;
    esac
    
    return 0
}

# Export functions for use in tests
export -f setup_test_environment cleanup_test_environment reset_mock_state
export -f setup_clean_repo_state setup_normal_repo_state setup_hook_failure_state
export -f setup_conflict_state setup_protected_branch_state setup_large_file_state
export -f mock_git_command mock_git_status mock_git_add mock_git_commit
export -f mock_git_branch mock_git_checkout mock_git_push mock_git_diff
export -f mock_git_log mock_git_config generate_mock_commit_hash
export -f mock_run_precommit_hooks mock_check_sensitive_data
export -f mock_validate_command_permissions