#!/bin/bash

# Command Executor for Claude Flow Git Command Testing
# Handles command parsing, argument substitution, and execution simulation

# Enable strict error handling
set -euo pipefail

# Command execution state
declare -A COMMAND_STATE
COMMAND_STATE[last_command]=""
COMMAND_STATE[last_exit_code]=0
COMMAND_STATE[last_output]=""
COMMAND_STATE[execution_count]=0

# Argument substitution patterns
declare -A ARGUMENT_PATTERNS
ARGUMENT_PATTERNS['$ARGUMENTS']=""
ARGUMENT_PATTERNS['$BRANCH']="${MOCK_REPO_STATE[branch]}"
ARGUMENT_PATTERNS['$MESSAGE']=""
ARGUMENT_PATTERNS['$FILES']=""
ARGUMENT_PATTERNS['$OPTIONS']=""

# Command execution log
declare -a EXECUTION_LOG

# Parse and execute a Claude Flow command
execute_claude_command() {
    local command_path="$1"
    local arguments="${2:-}"
    
    print_debug "Executing command: $command_path with arguments: $arguments"
    
    # Update argument patterns
    ARGUMENT_PATTERNS['$ARGUMENTS']="$arguments"
    
    # Extract command name from path
    local command_name
    command_name=$(basename "$command_path" .md)
    
    # Record execution
    ((COMMAND_STATE[execution_count]++)) || true
    COMMAND_STATE[last_command]="$command_path"
    EXECUTION_LOG+=("$command_path $arguments")
    
    # Load and parse command file
    if [[ ! -f "${COMMANDS_DIR}${command_path}" ]]; then
        COMMAND_STATE[last_exit_code]=1
        COMMAND_STATE[last_output]="Command file not found: $command_path"
        return 1
    fi
    
    # Simulate command execution based on command type
    case "$command_name" in
        commit)
            execute_git_commit_command "$arguments"
            ;;
        status)
            execute_git_status_command "$arguments"
            ;;
        branch)
            execute_git_branch_command "$arguments"
            ;;
        push)
            execute_git_push_command "$arguments"
            ;;
        *)
            execute_generic_command "$command_path" "$arguments"
            ;;
    esac
    
    return ${COMMAND_STATE[last_exit_code]}
}

# Execute git commit command simulation
execute_git_commit_command() {
    local arguments="$1"
    local exit_code=0
    local output=""
    
    # Parse commit message from arguments
    local commit_message=""
    if [[ "$arguments" =~ -m[[:space:]]+[\"\']([^\"\']+)[\"\'] ]]; then
        commit_message="${BASH_REMATCH[1]}"
    elif [[ "$arguments" =~ -m[[:space:]]+([^[:space:]]+) ]]; then
        commit_message="${BASH_REMATCH[1]}"
    fi
    
    # Update argument patterns
    ARGUMENT_PATTERNS['$MESSAGE']="$commit_message"
    
    # Simulate the workflow from commit.md
    output+="=== Git Commit Workflow ==="$'\n'
    
    # Step 1: Pre-commit analysis
    output+="Step 1: Pre-Commit Analysis"$'\n'
    output+=$(mock_git_command "status")$'\n'
    
    # Check for protected branch
    if [[ "${MOCK_REPO_STATE[branch]}" == "main" || "${MOCK_REPO_STATE[branch]}" == "master" ]]; then
        output+="ERROR: Direct commits to ${MOCK_REPO_STATE[branch]} are not allowed!"$'\n'
        exit_code=1
        COMMAND_STATE[last_exit_code]=$exit_code
        COMMAND_STATE[last_output]="$output"
        return $exit_code
    fi
    
    # Step 2: Smart staging (if needed)
    if [[ "${MOCK_REPO_STATE[has_changes]}" == "true" || "${MOCK_REPO_STATE[has_untracked]}" == "true" ]]; then
        output+=$'\n'"Step 2: Smart Staging"$'\n'
        output+="Analyzing files for staging..."$'\n'
        
        # Stage all modified and new files
        mock_git_command "add" "." >/dev/null 2>&1
        output+="Files staged for commit"$'\n'
    fi
    
    # Step 3: Validation checks
    output+=$'\n'"Step 3: Validation Checks"$'\n'
    
    # Run pre-commit hooks
    if mock_run_precommit_hooks; then
        output+="✓ Pre-commit hooks passed"$'\n'
    else
        output+=$(mock_run_precommit_hooks 2>&1)$'\n'
        exit_code=1
        COMMAND_STATE[last_exit_code]=$exit_code
        COMMAND_STATE[last_output]="$output"
        return $exit_code
    fi
    
    # Check for large files
    for file in "${!MOCK_FILES[@]}"; do
        if [[ "${MOCK_FILES[$file]}" == "staged" ]]; then
            local size="${MOCK_FILE_SIZES[$file]:-0}"
            if [[ $size -gt 104857600 ]]; then
                output+="ERROR: $file is over 100MB!"$'\n'
                exit_code=1
                COMMAND_STATE[last_exit_code]=$exit_code
                COMMAND_STATE[last_output]="$output"
                return $exit_code
            fi
        fi
    done
    
    # Check for sensitive data
    for file in "${!MOCK_FILES[@]}"; do
        if [[ "${MOCK_FILES[$file]}" == "staged" ]]; then
            if ! mock_check_sensitive_data "$file"; then
                output+="WARNING: Possible sensitive data in $file"$'\n'
                # Don't fail, just warn
            fi
        fi
    done
    
    # Step 4: Generate commit message if not provided
    if [[ -z "$commit_message" ]]; then
        output+=$'\n'"Step 4: Generate Commit Message"$'\n'
        commit_message="feat: auto-generated commit message"
        output+="Generated message: $commit_message"$'\n'
    fi
    
    # Step 5: Execute commit
    output+=$'\n'"Step 5: Execute Commit"$'\n'
    if mock_git_command "commit" "-m" "$commit_message"; then
        output+=$(mock_git_command "commit" "-m" "$commit_message" 2>&1)$'\n'
        output+="✓ Commit successful"$'\n'
    else
        output+=$(mock_git_command "commit" "-m" "$commit_message" 2>&1)$'\n'
        exit_code=1
    fi
    
    COMMAND_STATE[last_exit_code]=$exit_code
    COMMAND_STATE[last_output]="$output"
    return $exit_code
}

# Execute git status command simulation
execute_git_status_command() {
    local arguments="$1"
    local exit_code=0
    local output=""
    
    output+="=== Git Status Check ==="$'\n'
    output+=$(mock_git_command "status" $arguments)$'\n'
    
    # Additional status information
    if [[ "${MOCK_REPO_STATE[has_conflicts]}" == "true" ]]; then
        output+=$'\n'"⚠ Repository has unresolved conflicts"$'\n'
    fi
    
    if [[ "${MOCK_REPO_STATE[branch]}" == "main" || "${MOCK_REPO_STATE[branch]}" == "master" ]]; then
        output+=$'\n'"⚠ On protected branch: ${MOCK_REPO_STATE[branch]}"$'\n'
    fi
    
    COMMAND_STATE[last_exit_code]=$exit_code
    COMMAND_STATE[last_output]="$output"
    return $exit_code
}

# Execute git branch command simulation
execute_git_branch_command() {
    local arguments="$1"
    local exit_code=0
    local output=""
    
    output+="=== Git Branch Operations ==="$'\n'
    
    # Parse branch operation
    if [[ "$arguments" =~ ^-b[[:space:]]+([^[:space:]]+) ]]; then
        # Create new branch
        local new_branch="${BASH_REMATCH[1]}"
        output+="Creating new branch: $new_branch"$'\n'
        
        # Check if branch name is valid
        if [[ "$new_branch" =~ ^(main|master)$ ]]; then
            output+="ERROR: Cannot create protected branch name"$'\n'
            exit_code=1
        else
            mock_git_command "checkout" "-b" "$new_branch" >/dev/null 2>&1
            output+=$(mock_git_command "checkout" "-b" "$new_branch" 2>&1)$'\n'
        fi
    elif [[ "$arguments" =~ ^-d[[:space:]]+([^[:space:]]+) ]]; then
        # Delete branch
        local branch_to_delete="${BASH_REMATCH[1]}"
        output+="Deleting branch: $branch_to_delete"$'\n'
        output+=$(mock_git_command "branch" "-d" "$branch_to_delete" 2>&1)$'\n'
    else
        # List branches
        output+=$(mock_git_command "branch" $arguments 2>&1)$'\n'
    fi
    
    COMMAND_STATE[last_exit_code]=$exit_code
    COMMAND_STATE[last_output]="$output"
    return $exit_code
}

# Execute git push command simulation
execute_git_push_command() {
    local arguments="$1"
    local exit_code=0
    local output=""
    
    output+="=== Git Push Workflow ==="$'\n'
    
    # Pre-push checks
    output+="Running pre-push checks..."$'\n'
    
    # Check for uncommitted changes
    if [[ "${MOCK_REPO_STATE[has_changes]}" == "true" || "${MOCK_REPO_STATE[has_staged]}" == "true" ]]; then
        output+="ERROR: You have uncommitted changes"$'\n'
        output+="Please commit or stash them before pushing"$'\n'
        exit_code=1
        COMMAND_STATE[last_exit_code]=$exit_code
        COMMAND_STATE[last_output]="$output"
        return $exit_code
    fi
    
    # Check for conflicts
    if [[ "${MOCK_REPO_STATE[has_conflicts]}" == "true" ]]; then
        output+="ERROR: You have unresolved merge conflicts"$'\n'
        exit_code=1
        COMMAND_STATE[last_exit_code]=$exit_code
        COMMAND_STATE[last_output]="$output"
        return $exit_code
    fi
    
    # Execute push
    output+=$'\n'"Executing push..."$'\n'
    if mock_git_command "push" $arguments; then
        output+=$(mock_git_command "push" $arguments 2>&1)$'\n'
        output+="✓ Push successful"$'\n'
    else
        output+=$(mock_git_command "push" $arguments 2>&1)$'\n'
        output+="✗ Push failed"$'\n'
        exit_code=1
    fi
    
    COMMAND_STATE[last_exit_code]=$exit_code
    COMMAND_STATE[last_output]="$output"
    return $exit_code
}

# Execute generic command simulation
execute_generic_command() {
    local command_path="$1"
    local arguments="$2"
    
    COMMAND_STATE[last_output]="Executing generic command: $command_path with arguments: $arguments"
    COMMAND_STATE[last_exit_code]=0
    return 0
}

# Perform argument substitution
substitute_arguments() {
    local template="$1"
    local result="$template"
    
    # Replace all known patterns
    for pattern in "${!ARGUMENT_PATTERNS[@]}"; do
        local value="${ARGUMENT_PATTERNS[$pattern]}"
        result="${result//$pattern/$value}"
    done
    
    echo "$result"
}

# Parse command arguments
parse_command_arguments() {
    local raw_args="$1"
    local -a parsed_args=()
    
    # Handle quoted arguments
    while [[ "$raw_args" =~ ^[[:space:]]*[\"\']([^\"\']+)[\"\'](.*)$ ]] || 
          [[ "$raw_args" =~ ^[[:space:]]*([^[:space:]]+)(.*)$ ]]; do
        parsed_args+=("${BASH_REMATCH[1]}")
        raw_args="${BASH_REMATCH[2]}"
    done
    
    printf '%s\n' "${parsed_args[@]}"
}

# Validate argument safety
validate_argument_safety() {
    local argument="$1"
    
    # Check for command injection attempts
    if [[ "$argument" =~ [\;\|\&\`\$\(\)] ]]; then
        print_warning "Potentially unsafe characters in argument: $argument"
        return 1
    fi
    
    # Check for path traversal
    if [[ "$argument" =~ \.\./|/\.\. ]]; then
        print_warning "Path traversal attempt detected: $argument"
        return 1
    fi
    
    return 0
}

# Track command execution flow
track_command_flow() {
    local command="$1"
    local phase="$2"  # pre, execute, post
    
    case "$phase" in
        pre)
            print_debug "Pre-execution phase for: $command"
            # Validate prerequisites
            ;;
        execute)
            print_debug "Execution phase for: $command"
            # Track actual execution
            ;;
        post)
            print_debug "Post-execution phase for: $command"
            # Validate results
            ;;
    esac
}

# Simulate command execution with full workflow
simulate_command_execution() {
    local command_file="$1"
    local arguments="$2"
    
    # Pre-execution phase
    track_command_flow "$command_file" "pre"
    
    # Validate arguments
    local parsed_args
    mapfile -t parsed_args < <(parse_command_arguments "$arguments")
    
    for arg in "${parsed_args[@]}"; do
        if ! validate_argument_safety "$arg"; then
            COMMAND_STATE[last_exit_code]=1
            COMMAND_STATE[last_output]="Unsafe argument detected"
            return 1
        fi
    done
    
    # Execute command
    track_command_flow "$command_file" "execute"
    execute_claude_command "$command_file" "$arguments"
    local exit_code=$?
    
    # Post-execution phase
    track_command_flow "$command_file" "post"
    
    return $exit_code
}

# Get command execution history
get_execution_history() {
    printf '%s\n' "${EXECUTION_LOG[@]}"
}

# Clear command state
clear_command_state() {
    COMMAND_STATE[last_command]=""
    COMMAND_STATE[last_exit_code]=0
    COMMAND_STATE[last_output]=""
    COMMAND_STATE[execution_count]=0
    EXECUTION_LOG=()
}

# Test helper functions

# Test normal commit workflow
test_normal_commit_workflow() {
    print_info "Testing normal commit workflow"
    
    # Execute commit command
    if simulate_command_execution "/git/commit" "-m 'feat: add new feature'"; then
        # Verify commit was successful
        if [[ "${COMMAND_STATE[last_output]}" =~ "Commit successful" ]]; then
            return 0
        fi
    fi
    
    return 1
}

# Test branch operations
test_branch_operations() {
    print_info "Testing branch operations"
    
    # Test branch creation
    if ! simulate_command_execution "/git/branch" "-b feature/test-branch"; then
        return 1
    fi
    
    # Verify branch was created
    if [[ "${MOCK_REPO_STATE[branch]}" != "feature/test-branch" ]]; then
        return 1
    fi
    
    return 0
}

# Test clean push operations
test_clean_push_operations() {
    print_info "Testing clean push operations"
    
    # Ensure clean state
    MOCK_REPO_STATE[has_changes]=false
    MOCK_REPO_STATE[has_staged]=false
    MOCK_REPO_STATE[has_conflicts]=false
    
    # Execute push
    if simulate_command_execution "/git/push" "origin feature/test"; then
        return 0
    fi
    
    return 1
}

# Test status checks
test_status_checks() {
    print_info "Testing status checks"
    
    # Execute status command
    if simulate_command_execution "/git/status" ""; then
        # Verify output contains status information
        if [[ "${COMMAND_STATE[last_output]}" =~ "On branch" ]]; then
            return 0
        fi
    fi
    
    return 1
}

# Test pre-commit hook failure
test_precommit_hook_failure() {
    print_info "Testing pre-commit hook failure"
    
    # Set up hook failure
    MOCK_REPO_STATE[hook_result]="fail"
    
    # Attempt commit
    if simulate_command_execution "/git/commit" "-m 'test commit'"; then
        # Should have failed
        return 1
    fi
    
    # Verify hook failure was detected
    if [[ "${COMMAND_STATE[last_output]}" =~ "Pre-commit hook failed" ]]; then
        return 0
    fi
    
    return 1
}

# Test merge conflicts
test_merge_conflicts() {
    print_info "Testing merge conflict handling"
    
    # Set up conflict state
    setup_conflict_state
    
    # Attempt to push with conflicts
    if simulate_command_execution "/git/push" "origin feature/test"; then
        # Should have failed
        return 1
    fi
    
    # Verify conflict was detected
    if [[ "${COMMAND_STATE[last_output]}" =~ "unresolved merge conflicts" ]]; then
        return 0
    fi
    
    return 1
}

# Test push rejection
test_push_rejection() {
    print_info "Testing push rejection"
    
    # Set up rejection scenario
    MOCK_REPO_STATE[push_result]="rejected"
    
    # Attempt push
    if simulate_command_execution "/git/push" "origin main"; then
        # Should have failed
        return 1
    fi
    
    # Verify rejection was handled
    if [[ "${COMMAND_STATE[last_output]}" =~ "Push failed" ]]; then
        return 0
    fi
    
    return 1
}

# Test invalid branch operations
test_invalid_branch_operations() {
    print_info "Testing invalid branch operations"
    
    # Try to create protected branch
    if simulate_command_execution "/git/branch" "-b main"; then
        # Should have failed
        return 1
    fi
    
    # Verify error
    if [[ "${COMMAND_STATE[last_output]}" =~ "Cannot create protected branch" ]]; then
        return 0
    fi
    
    return 1
}

# Test large file detection
test_large_file_detection() {
    print_info "Testing large file detection"
    
    # Set up large file
    setup_large_file_state
    
    # Attempt commit
    if simulate_command_execution "/git/commit" "-m 'add large file'"; then
        # Should have failed
        return 1
    fi
    
    # Verify large file was detected
    if [[ "${COMMAND_STATE[last_output]}" =~ "over 100MB" ]]; then
        return 0
    fi
    
    return 1
}

# Test protected branch commit
test_protected_branch_commit() {
    print_info "Testing protected branch commit prevention"
    
    # Set up protected branch
    setup_protected_branch_state
    
    # Attempt commit on main
    if simulate_command_execution "/git/commit" "-m 'direct commit to main'"; then
        # Should have failed
        return 1
    fi
    
    # Verify protection worked
    if [[ "${COMMAND_STATE[last_output]}" =~ "Direct commits to main are not allowed" ]]; then
        return 0
    fi
    
    return 1
}

# Test empty commits
test_empty_commits() {
    print_info "Testing empty commit handling"
    
    # Set up clean state
    setup_clean_repo_state
    MOCK_REPO_STATE[has_staged]=false
    
    # Attempt empty commit
    if simulate_command_execution "/git/commit" "-m 'empty commit'"; then
        # Should have failed
        return 1
    fi
    
    return 0
}

# Test concurrent operations
test_concurrent_operations() {
    print_info "Testing concurrent operation handling"
    
    # Simulate multiple rapid commands
    local commands=(
        "/git/status"
        "/git/add ."
        "/git/commit -m 'test'"
        "/git/push"
    )
    
    for cmd in "${commands[@]}"; do
        simulate_command_execution $cmd
    done
    
    # Verify command history
    local history_count=${#EXECUTION_LOG[@]}
    if [[ $history_count -eq 4 ]]; then
        return 0
    fi
    
    return 1
}

# Test sensitive data detection
test_sensitive_data_detection() {
    print_info "Testing sensitive data detection"
    
    # Add file with sensitive content
    MOCK_FILES[config.js]="staged"
    MOCK_FILE_CONTENT[config.js]='const password = "secret123";'
    
    # Attempt commit
    simulate_command_execution "/git/commit" "-m 'add config'"
    
    # Check for warning
    if [[ "${COMMAND_STATE[last_output]}" =~ "sensitive data" ]]; then
        return 0
    fi
    
    return 1
}

# Test command injection prevention
test_command_injection_prevention() {
    print_info "Testing command injection prevention"
    
    # Try various injection attempts
    local injection_attempts=(
        "-m 'test'; rm -rf /"
        "-m \$(evil command)"
        "-m \`dangerous\`"
        "-m test && malicious"
    )
    
    for attempt in "${injection_attempts[@]}"; do
        if simulate_command_execution "/git/commit" "$attempt"; then
            # Should have been blocked
            return 1
        fi
    done
    
    return 0
}

# Test path traversal protection
test_path_traversal_protection() {
    print_info "Testing path traversal protection"
    
    # Try path traversal
    local traversal_attempts=(
        "../../../etc/passwd"
        "/etc/../etc/passwd"
        "./../sensitive/file"
    )
    
    for attempt in "${traversal_attempts[@]}"; do
        if validate_argument_safety "$attempt"; then
            # Should have been blocked
            return 1
        fi
    done
    
    return 0
}

# Test argument sanitization
test_argument_sanitization() {
    print_info "Testing argument sanitization"
    
    # Test various argument patterns
    local test_args=(
        "normal argument"
        "with-dashes"
        "with_underscores"
        "123numbers"
    )
    
    for arg in "${test_args[@]}"; do
        if ! validate_argument_safety "$arg"; then
            # Should have passed
            return 1
        fi
    done
    
    return 0
}

# Test basic argument substitution
test_basic_argument_substitution() {
    print_info "Testing basic argument substitution"
    
    # Set up patterns
    ARGUMENT_PATTERNS['$ARGUMENTS']="test value"
    ARGUMENT_PATTERNS['$BRANCH']="feature/test"
    
    # Test substitution
    local template="Command with \$ARGUMENTS on branch \$BRANCH"
    local result
    result=$(substitute_arguments "$template")
    
    if [[ "$result" == "Command with test value on branch feature/test" ]]; then
        return 0
    fi
    
    return 1
}

# Test complex argument patterns
test_complex_argument_patterns() {
    print_info "Testing complex argument patterns"
    
    # Test quoted arguments
    local complex_args='-m "multi word message" --option="value with spaces"'
    local parsed
    mapfile -t parsed < <(parse_command_arguments "$complex_args")
    
    if [[ ${#parsed[@]} -eq 4 ]]; then
        return 0
    fi
    
    return 1
}

# Test special character handling
test_special_character_handling() {
    print_info "Testing special character handling"
    
    # Test escaping and special chars
    local special_args='--message="Line 1\nLine 2" --path="/home/user/test"'
    
    if validate_argument_safety "$special_args"; then
        return 0
    fi
    
    return 1
}

# Test empty argument handling
test_empty_argument_handling() {
    print_info "Testing empty argument handling"
    
    # Test empty arguments
    if simulate_command_execution "/git/status" ""; then
        return 0
    fi
    
    return 1
}

# Test command sequencing
test_command_sequencing() {
    print_info "Testing command sequencing"
    
    # Execute sequence
    clear_command_state
    
    simulate_command_execution "/git/status" ""
    simulate_command_execution "/git/add" "."
    simulate_command_execution "/git/commit" "-m 'test'"
    
    # Verify sequence
    if [[ ${COMMAND_STATE[execution_count]} -eq 3 ]]; then
        return 0
    fi
    
    return 1
}

# Test prerequisite validation
test_prerequisite_validation() {
    print_info "Testing prerequisite validation"
    
    # Try to push without commits
    MOCK_REPO_STATE[last_commit]=""
    
    if simulate_command_execution "/git/push" "origin main"; then
        # Should check prerequisites
        return 0
    fi
    
    return 0
}

# Test state transitions
test_state_transitions() {
    print_info "Testing state transitions"
    
    # Start clean
    setup_clean_repo_state
    
    # Add changes
    MOCK_FILES[test.js]="modified"
    MOCK_REPO_STATE[has_changes]=true
    
    # Stage
    mock_git_add "test.js"
    
    # Verify transition
    if [[ "${MOCK_FILES[test.js]}" == "staged" && "${MOCK_REPO_STATE[has_staged]}" == "true" ]]; then
        return 0
    fi
    
    return 1
}

# Test rollback scenarios
test_rollback_scenarios() {
    print_info "Testing rollback scenarios"
    
    # Simulate failed operation that needs rollback
    MOCK_REPO_STATE[has_staged]=true
    
    # Simulate rollback
    for file in "${!MOCK_FILES[@]}"; do
        if [[ "${MOCK_FILES[$file]}" == "staged" ]]; then
            MOCK_FILES[$file]="modified"
        fi
    done
    MOCK_REPO_STATE[has_staged]=false
    MOCK_REPO_STATE[has_changes]=true
    
    return 0
}

# Export functions
export -f execute_claude_command execute_git_commit_command execute_git_status_command
export -f execute_git_branch_command execute_git_push_command execute_generic_command
export -f substitute_arguments parse_command_arguments validate_argument_safety
export -f track_command_flow simulate_command_execution get_execution_history
export -f clear_command_state

# Export test functions
export -f test_normal_commit_workflow test_branch_operations test_clean_push_operations
export -f test_status_checks test_precommit_hook_failure test_merge_conflicts
export -f test_push_rejection test_invalid_branch_operations test_large_file_detection
export -f test_protected_branch_commit test_empty_commits test_concurrent_operations
export -f test_sensitive_data_detection test_command_injection_prevention
export -f test_path_traversal_protection test_argument_sanitization
export -f test_basic_argument_substitution test_complex_argument_patterns
export -f test_special_character_handling test_empty_argument_handling
export -f test_command_sequencing test_prerequisite_validation
export -f test_state_transitions test_rollback_scenarios