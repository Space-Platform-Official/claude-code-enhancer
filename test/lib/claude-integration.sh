#!/bin/bash

# Claude Code Integration Utilities for E2E Testing
# Handles Claude Code command execution and validation

# Enable strict error handling
set -euo pipefail

# Claude execution configuration
declare -A CLAUDE_CONFIG
CLAUDE_CONFIG[available]=false
CLAUDE_CONFIG[command]="claude"
CLAUDE_CONFIG[timeout]=300  # 5 minutes default timeout
CLAUDE_CONFIG[retry_count]=3
CLAUDE_CONFIG[mock_mode]=false

# Claude command templates
declare -A CLAUDE_COMMANDS
CLAUDE_COMMANDS[commit]='claude --repo="$1" --command="git/commit" --args="$2"'
CLAUDE_COMMANDS[branch]='claude --repo="$1" --command="git/branch" --args="$2"'
CLAUDE_COMMANDS[push]='claude --repo="$1" --command="git/push" --args="$2"'
CLAUDE_COMMANDS[status]='claude --repo="$1" --command="git/status" --args="$2"'
CLAUDE_COMMANDS[flow]='claude --repo="$1" --flow="$2"'

# Claude execution history
declare -a CLAUDE_EXECUTION_LOG
declare -A CLAUDE_EXECUTION_STATS
CLAUDE_EXECUTION_STATS[total]=0
CLAUDE_EXECUTION_STATS[success]=0
CLAUDE_EXECUTION_STATS[failed]=0
CLAUDE_EXECUTION_STATS[mocked]=0

# Initialize Claude integration
initialize_claude_integration() {
    print_debug "Initializing Claude integration"
    
    # Check if Claude is available
    if command -v claude >/dev/null 2>&1; then
        CLAUDE_CONFIG[available]=true
        CLAUDE_CONFIG[command]=$(command -v claude)
        print_success "Claude Code found at: ${CLAUDE_CONFIG[command]}"
        
        # Get Claude version
        local version
        version=$(claude --version 2>/dev/null || echo "unknown")
        print_info "Claude version: $version"
    else
        CLAUDE_CONFIG[available]=false
        CLAUDE_CONFIG[mock_mode]=true
        print_warning "Claude Code not found - running in mock mode"
    fi
    
    # Set up Claude test environment
    export CLAUDE_TEST_MODE=true
    export CLAUDE_NO_TELEMETRY=true
    export CLAUDE_LOG_LEVEL="${DEBUG_MODE:-false}" && echo "debug" || echo "info"
    
    return 0
}

# Execute Claude command with safety checks
execute_claude_command() {
    local command_type="$1"
    local repo_path="$2"
    local arguments="${3:-}"
    local options="${4:-}"
    
    ((CLAUDE_EXECUTION_STATS[total]++)) || true
    
    # Validate inputs
    if [[ ! -d "$repo_path" ]]; then
        print_error "Repository path not found: $repo_path"
        ((CLAUDE_EXECUTION_STATS[failed]++)) || true
        return 1
    fi
    
    # Log execution
    local log_entry="[$(date -Iseconds)] $command_type: $repo_path $arguments"
    CLAUDE_EXECUTION_LOG+=("$log_entry")
    
    # Execute based on mode
    if [[ "${CLAUDE_CONFIG[mock_mode]}" == "true" ]]; then
        execute_claude_mock "$command_type" "$repo_path" "$arguments" "$options"
    else
        execute_claude_real "$command_type" "$repo_path" "$arguments" "$options"
    fi
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        ((CLAUDE_EXECUTION_STATS[success]++)) || true
    else
        ((CLAUDE_EXECUTION_STATS[failed]++)) || true
    fi
    
    return $exit_code
}

# Execute real Claude command
execute_claude_real() {
    local command_type="$1"
    local repo_path="$2"
    local arguments="$3"
    local options="$4"
    
    print_debug "Executing real Claude command: $command_type"
    
    # Build command based on type
    local claude_cmd=""
    case "$command_type" in
        commit|branch|push|status)
            claude_cmd="${CLAUDE_CONFIG[command]} --repo=\"$repo_path\" --command=\"git/$command_type\""
            [[ -n "$arguments" ]] && claude_cmd+=" --args=\"$arguments\""
            ;;
        flow)
            claude_cmd="${CLAUDE_CONFIG[command]} --repo=\"$repo_path\" --flow=\"$arguments\""
            ;;
        custom)
            claude_cmd="${CLAUDE_CONFIG[command]} $arguments"
            ;;
        *)
            print_error "Unknown command type: $command_type"
            return 1
            ;;
    esac
    
    # Add options if provided
    [[ -n "$options" ]] && claude_cmd+=" $options"
    
    # Execute with timeout and retry
    local attempt=1
    local max_attempts="${CLAUDE_CONFIG[retry_count]}"
    
    while [[ $attempt -le $max_attempts ]]; do
        print_debug "Attempt $attempt/$max_attempts: $claude_cmd"
        
        # Create output file for this execution
        local output_file="${INTEGRATION_ENV[test_dir]}/claude-output-$$-$attempt.log"
        
        # Execute command with timeout
        if timeout "${CLAUDE_CONFIG[timeout]}" bash -c "cd '$repo_path' && $claude_cmd" > "$output_file" 2>&1; then
            # Success
            cat "$output_file"
            rm -f "$output_file"
            return 0
        else
            local exit_code=$?
            print_warning "Claude command failed (attempt $attempt/$max_attempts, exit code: $exit_code)"
            
            # Show output on failure
            if [[ -f "$output_file" ]]; then
                print_debug "Command output:"
                cat "$output_file" | sed 's/^/  /' >&2
            fi
            
            # Check if we should retry
            if [[ $exit_code -eq 124 ]]; then
                print_error "Command timed out after ${CLAUDE_CONFIG[timeout]}s"
            elif [[ $attempt -lt $max_attempts ]]; then
                print_info "Retrying in 2 seconds..."
                sleep 2
            fi
            
            rm -f "$output_file"
        fi
        
        ((attempt++))
    done
    
    return 1
}

# Execute mock Claude command for testing
execute_claude_mock() {
    local command_type="$1"
    local repo_path="$2"
    local arguments="$3"
    local options="$4"
    
    ((CLAUDE_EXECUTION_STATS[mocked]++)) || true
    
    print_debug "Executing mock Claude command: $command_type"
    
    # Simulate Claude behavior based on command type
    case "$command_type" in
        commit)
            mock_claude_commit "$repo_path" "$arguments"
            ;;
        branch)
            mock_claude_branch "$repo_path" "$arguments"
            ;;
        push)
            mock_claude_push "$repo_path" "$arguments"
            ;;
        status)
            mock_claude_status "$repo_path" "$arguments"
            ;;
        flow)
            mock_claude_flow "$repo_path" "$arguments"
            ;;
        *)
            print_error "Unknown mock command: $command_type"
            return 1
            ;;
    esac
}

# Mock Claude commit command
mock_claude_commit() {
    local repo_path="$1"
    local arguments="$2"
    
    echo "=== Claude Git Commit Workflow ==="
    echo "Repository: $repo_path"
    echo "Arguments: $arguments"
    echo ""
    
    (
        cd "$repo_path"
        
        # Simulate Claude's commit workflow
        echo "Step 1: Analyzing repository state..."
        git status
        
        echo -e "\nStep 2: Smart staging..."
        if [[ -n "$(git status --porcelain)" ]]; then
            git add -A
            echo "✓ Files staged for commit"
        else
            echo "ℹ No changes to stage"
        fi
        
        echo -e "\nStep 3: Generating commit message..."
        local message="feat: automated commit via Claude"
        if [[ "$arguments" =~ -m[[:space:]]+[\"\']([^\"\']+)[\"\'] ]]; then
            message="${BASH_REMATCH[1]}"
        fi
        
        echo -e "\nStep 4: Creating commit..."
        if git commit -m "$message" 2>&1; then
            echo "✓ Commit created successfully"
            git log -1 --oneline
        else
            echo "✗ Commit failed"
            return 1
        fi
    )
}

# Mock Claude branch command
mock_claude_branch() {
    local repo_path="$1"
    local arguments="$2"
    
    echo "=== Claude Git Branch Management ==="
    echo "Repository: $repo_path"
    echo "Arguments: $arguments"
    echo ""
    
    (
        cd "$repo_path"
        
        if [[ "$arguments" =~ -b[[:space:]]+([^[:space:]]+) ]]; then
            # Create new branch
            local branch_name="${BASH_REMATCH[1]}"
            echo "Creating new branch: $branch_name"
            
            if git checkout -b "$branch_name" 2>&1; then
                echo "✓ Branch created and checked out"
            else
                echo "✗ Failed to create branch"
                return 1
            fi
        else
            # List branches
            echo "Current branches:"
            git branch -a
        fi
    )
}

# Mock Claude push command
mock_claude_push() {
    local repo_path="$1"
    local arguments="$2"
    
    echo "=== Claude Git Push Workflow ==="
    echo "Repository: $repo_path"
    echo "Arguments: $arguments"
    echo ""
    
    (
        cd "$repo_path"
        
        echo "Step 1: Pre-push validation..."
        
        # Check for uncommitted changes
        if [[ -n "$(git status --porcelain)" ]]; then
            echo "✗ Error: Uncommitted changes detected"
            git status --short
            return 1
        fi
        
        echo "✓ Working directory clean"
        
        echo -e "\nStep 2: Pushing to remote..."
        if git push $arguments 2>&1; then
            echo "✓ Push successful"
        else
            echo "✗ Push failed"
            return 1
        fi
    )
}

# Mock Claude status command
mock_claude_status() {
    local repo_path="$1"
    local arguments="$2"
    
    echo "=== Claude Git Status Analysis ==="
    echo "Repository: $repo_path"
    echo ""
    
    (
        cd "$repo_path"
        
        # Enhanced status output
        echo "Branch: $(git branch --show-current)"
        echo "Remote: $(git remote -v | head -1 | awk '{print $2}')"
        echo ""
        
        git status
        
        # Additional analysis
        local changes=$(git status --porcelain | wc -l)
        if [[ $changes -gt 0 ]]; then
            echo -e "\n📊 Summary: $changes file(s) with changes"
        else
            echo -e "\n✅ Working directory clean"
        fi
    )
}

# Mock Claude flow command
mock_claude_flow() {
    local repo_path="$1"
    local flow_name="$2"
    
    echo "=== Claude Flow: $flow_name ==="
    echo "Repository: $repo_path"
    echo ""
    
    case "$flow_name" in
        feature-start)
            echo "Starting new feature development flow..."
            (cd "$repo_path" && git checkout -b "feature/claude-test-$(date +%s)")
            ;;
        feature-complete)
            echo "Completing feature development flow..."
            echo "1. Running tests..."
            echo "2. Creating commit..."
            echo "3. Pushing to remote..."
            ;;
        hotfix)
            echo "Executing hotfix flow..."
            echo "1. Creating hotfix branch from main..."
            echo "2. Applying fix..."
            echo "3. Creating PR..."
            ;;
        *)
            echo "Unknown flow: $flow_name"
            return 1
            ;;
    esac
}

# Validate Claude command output
validate_claude_output() {
    local output="$1"
    local expected_pattern="$2"
    
    if [[ "$output" =~ $expected_pattern ]]; then
        print_success "Output validation passed"
        return 0
    else
        print_error "Output validation failed"
        print_debug "Expected pattern: $expected_pattern"
        print_debug "Actual output: $output"
        return 1
    fi
}

# Test Claude availability and functionality
test_claude_availability() {
    print_info "Testing Claude availability"
    
    if [[ "${CLAUDE_CONFIG[available]}" != "true" ]]; then
        print_warning "Claude not available - skipping availability test"
        return 0
    fi
    
    # Test basic command
    local test_output
    if test_output=$(timeout 10 ${CLAUDE_CONFIG[command]} --version 2>&1); then
        print_success "Claude responds to commands"
        return 0
    else
        print_error "Claude not responding properly"
        return 1
    fi
}

# Create Claude test session
create_claude_session() {
    local session_name="$1"
    local repo_path="$2"
    
    local session_file="${INTEGRATION_ENV[claude_config]}/session-$session_name.json"
    
    cat > "$session_file" << EOF
{
  "session_id": "test-$session_name-$$",
  "repository": "$repo_path",
  "created_at": "$(date -Iseconds)",
  "config": {
    "auto_commit": false,
    "verbose": true,
    "safe_mode": true
  }
}
EOF
    
    export CLAUDE_SESSION_FILE="$session_file"
    return 0
}

# Clean up Claude session
cleanup_claude_session() {
    local session_name="$1"
    
    unset CLAUDE_SESSION_FILE
    
    local session_file="${INTEGRATION_ENV[claude_config]}/session-$session_name.json"
    rm -f "$session_file"
    
    return 0
}

# Monitor Claude execution performance
monitor_claude_performance() {
    local command="$1"
    local start_time=$(date +%s.%N)
    
    # Execute command
    eval "$command"
    local exit_code=$?
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    print_debug "Command execution time: ${duration}s"
    
    # Log performance data
    local perf_log="${INTEGRATION_ENV[test_dir]}/claude-performance.log"
    echo "$(date -Iseconds),$command,$duration,$exit_code" >> "$perf_log"
    
    return $exit_code
}

# Generate Claude execution report
generate_claude_report() {
    local report_file="${INTEGRATION_ENV[test_dir]}/claude-report.txt"
    
    cat > "$report_file" << EOF
Claude Integration Test Report
==============================

Test: ${INTEGRATION_ENV[test_name]}
Date: $(date)

Execution Statistics:
- Total Commands: ${CLAUDE_EXECUTION_STATS[total]}
- Successful: ${CLAUDE_EXECUTION_STATS[success]}
- Failed: ${CLAUDE_EXECUTION_STATS[failed]}
- Mocked: ${CLAUDE_EXECUTION_STATS[mocked]}

Mode: $([ "${CLAUDE_CONFIG[mock_mode]}" == "true" ] && echo "Mock" || echo "Real")
Claude Available: $([ "${CLAUDE_CONFIG[available]}" == "true" ] && echo "Yes" || echo "No")

Execution Log:
EOF
    
    # Add execution history
    for entry in "${CLAUDE_EXECUTION_LOG[@]}"; do
        echo "$entry" >> "$report_file"
    done
    
    print_info "Claude report generated: $report_file"
}

# Test helper: Execute Claude workflow
execute_claude_workflow() {
    local workflow_name="$1"
    local repo_path="$2"
    local expected_outcome="${3:-success}"
    
    print_info "Executing Claude workflow: $workflow_name"
    
    case "$workflow_name" in
        feature_development)
            # Feature development workflow
            execute_claude_command "flow" "$repo_path" "feature-start" || return 1
            
            # Make changes
            echo "// New feature" >> "$repo_path/src/index.js"
            
            execute_claude_command "commit" "$repo_path" "-m 'feat: add new feature'" || return 1
            execute_claude_command "push" "$repo_path" "origin HEAD" || return 1
            ;;
            
        hotfix_emergency)
            # Hotfix workflow
            execute_claude_command "branch" "$repo_path" "-b hotfix/critical-fix" || return 1
            
            # Apply fix
            echo "// Critical fix" >> "$repo_path/src/index.js"
            
            execute_claude_command "commit" "$repo_path" "-m 'fix: critical issue resolved'" || return 1
            execute_claude_command "push" "$repo_path" "origin HEAD" || return 1
            ;;
            
        *)
            print_error "Unknown workflow: $workflow_name"
            return 1
            ;;
    esac
    
    # Validate outcome
    if [[ "$expected_outcome" == "success" ]]; then
        print_success "Workflow completed successfully"
        return 0
    else
        print_info "Workflow completed with expected outcome: $expected_outcome"
        return 0
    fi
}

# Export functions
export -f initialize_claude_integration execute_claude_command
export -f execute_claude_real execute_claude_mock
export -f mock_claude_commit mock_claude_branch mock_claude_push
export -f mock_claude_status mock_claude_flow
export -f validate_claude_output test_claude_availability
export -f create_claude_session cleanup_claude_session
export -f monitor_claude_performance generate_claude_report
export -f execute_claude_workflow