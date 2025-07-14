#!/bin/bash

# Phase 3 Integration E2E Testing Framework for Claude Flow Git Commands
# Real end-to-end testing with actual git repositories and Claude Code execution

# Enable strict error handling
set -euo pipefail

# Ensure clean exit on signals
trap 'cleanup_on_exit $?' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Colors (readonly constants)
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m'

# Global variables
readonly SCRIPT_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && builtin pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly LIB_DIR="${SCRIPT_DIR}/lib"
readonly SCENARIOS_DIR="${SCRIPT_DIR}/scenarios"
readonly INTEGRATION_TEMP="${SCRIPT_DIR}/tmp/integration-$$"
readonly MAX_RUNTIME=600  # 10 minutes max per test
readonly MAX_MEMORY_MB=1024  # 1GB memory limit

# Test environments
readonly TEST_REPOS_DIR="${INTEGRATION_TEMP}/repos"
readonly TEST_REMOTE_DIR="${INTEGRATION_TEMP}/remotes"
readonly TEST_WORK_DIR="${INTEGRATION_TEMP}/work"

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0
START_TIME=$(date +%s)

# Test configuration
TEST_MODE="all"
DEBUG_MODE=false
VERBOSE=false
DRY_RUN=false
CLAUDE_AVAILABLE=false
CI_MODE=false

# Resource monitoring
RESOURCE_PID=""

# Exit handler for cleanup
cleanup_on_exit() {
    local exit_code=${1:-$?}
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    # Stop resource monitoring
    if [[ -n "$RESOURCE_PID" ]] && kill -0 "$RESOURCE_PID" 2>/dev/null; then
        kill "$RESOURCE_PID" 2>/dev/null || true
    fi
    
    # Clean up temporary directory
    if [[ -d "$INTEGRATION_TEMP" ]]; then
        rm -rf "$INTEGRATION_TEMP"
    fi
    
    echo -e "\n${BLUE}=== Integration Test Complete ===${NC}"
    echo -e "${BLUE}Duration: ${duration}s${NC}"
    
    if [[ ${exit_code} -ne 0 ]]; then
        print_error "Tests failed with exit code ${exit_code}"
    fi
}

# Utility functions
print_header() {
    local message="${1:-}"
    [[ -n "${message}" ]] && echo -e "\n${BLUE}=== ${message} ===${NC}"
}

print_success() {
    local message="${1:-}"
    [[ -n "${message}" ]] && echo -e "${GREEN}✓ ${message}${NC}"
}

print_info() {
    local message="${1:-}"
    [[ -n "${message}" ]] && echo -e "${CYAN}ℹ ${message}${NC}"
}

print_error() {
    local message="${1:-}"
    [[ -n "${message}" ]] && echo -e "${RED}✗ ${message}${NC}" >&2
}

print_warning() {
    local message="${1:-}"
    [[ -n "${message}" ]] && echo -e "${YELLOW}⚠ ${message}${NC}" >&2
}

print_debug() {
    local message="${1:-}"
    if [[ "$DEBUG_MODE" == true ]]; then
        echo -e "${MAGENTA}[DEBUG] ${message}${NC}" >&2
    fi
}

# Check if running in CI environment
detect_ci_environment() {
    if [[ -n "${CI:-}" || -n "${CONTINUOUS_INTEGRATION:-}" || -n "${GITHUB_ACTIONS:-}" || -n "${JENKINS_URL:-}" ]]; then
        CI_MODE=true
        print_info "Detected CI environment"
    fi
}

# Check if Claude Code is available
check_claude_availability() {
    if command -v claude >/dev/null 2>&1; then
        CLAUDE_AVAILABLE=true
        print_success "Claude Code is available"
        claude --version 2>/dev/null || true
    else
        CLAUDE_AVAILABLE=false
        print_warning "Claude Code not found - will run in simulation mode"
    fi
}

# Validate environment and dependencies
validate_environment() {
    print_header "Environment Validation"
    
    # Detect CI environment
    detect_ci_environment
    
    # Check Claude availability
    check_claude_availability
    
    # Check required directories
    local required_dirs=("$LIB_DIR" "$SCENARIOS_DIR")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            print_error "Required directory not found: $dir"
            return 1
        fi
    done
    
    # Check required files
    local required_files=(
        "$LIB_DIR/integration-environment.sh"
        "$LIB_DIR/claude-integration.sh"
        "$SCENARIOS_DIR/git-workflows.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file not found: $file"
            return 1
        fi
        
        # Make scripts executable
        chmod +x "$file"
    done
    
    # Check git availability
    if ! command -v git >/dev/null 2>&1; then
        print_error "Git is not installed"
        return 1
    fi
    
    # Create temporary directories
    mkdir -p "$TEST_REPOS_DIR" "$TEST_REMOTE_DIR" "$TEST_WORK_DIR"
    
    # Source libraries
    if ! source "$LIB_DIR/integration-environment.sh"; then
        print_error "Failed to source integration environment library"
        return 1
    fi
    
    if ! source "$LIB_DIR/claude-integration.sh"; then
        print_error "Failed to source Claude integration library"
        return 1
    fi
    
    if ! source "$SCENARIOS_DIR/git-workflows.sh"; then
        print_error "Failed to source git workflows scenarios"
        return 1
    fi
    
    # Check resource limits
    if [[ "$CI_MODE" == false ]]; then
        # Set ulimits for local testing
        ulimit -t "$MAX_RUNTIME" 2>/dev/null || true  # CPU time
        ulimit -v $((MAX_MEMORY_MB * 1024)) 2>/dev/null || true  # Virtual memory
    fi
    
    print_success "Environment validation passed"
    return 0
}

# Start resource monitoring
start_resource_monitoring() {
    if [[ "$VERBOSE" == true ]]; then
        (
            while true; do
                # Get memory usage
                local mem_usage
                if command -v vm_stat >/dev/null 2>&1; then
                    # macOS
                    mem_usage=$(vm_stat | awk '/Pages free/ {free=$3} /Pages active/ {active=$3} END {print int((active/(free+active))*100)}')
                elif [[ -f /proc/meminfo ]]; then
                    # Linux
                    mem_usage=$(awk '/MemTotal/ {total=$2} /MemAvailable/ {avail=$2} END {print int(((total-avail)/total)*100)}' /proc/meminfo)
                else
                    mem_usage="N/A"
                fi
                
                # Get CPU usage
                local cpu_usage
                cpu_usage=$(ps aux | awk -v pid=$$ '$2==pid {print $3}')
                
                print_debug "Resource usage - CPU: ${cpu_usage}%, Memory: ${mem_usage}%"
                sleep 5
            done
        ) &
        RESOURCE_PID=$!
    fi
}

# Run integration test suite
run_integration_test() {
    local test_name="$1"
    local test_function="$2"
    
    print_header "Running: $test_name"
    
    # Create test-specific directory
    local test_dir="${TEST_WORK_DIR}/${test_name}"
    mkdir -p "$test_dir"
    
    # Set up test environment
    if ! setup_integration_environment "$test_name" "$test_dir"; then
        record_test_result "$test_name" "skip" "Failed to set up environment"
        return
    fi
    
    # Run test with timeout
    local test_output="${test_dir}/output.log"
    local test_start
    test_start=$(date +%s)
    
    if [[ "$DRY_RUN" == true ]]; then
        print_info "DRY RUN: Would execute $test_function"
        record_test_result "$test_name" "skip" "Dry run mode"
    else
        # Execute test with timeout
        if timeout "$MAX_RUNTIME" bash -c "cd '$test_dir' && $test_function" > "$test_output" 2>&1; then
            local test_end
            test_end=$(date +%s)
            local test_duration=$((test_end - test_start))
            record_test_result "$test_name" "pass" "Completed in ${test_duration}s"
            
            if [[ "$VERBOSE" == true ]]; then
                echo "Test output:"
                cat "$test_output" | sed 's/^/  /'
            fi
        else
            local exit_code=$?
            if [[ $exit_code -eq 124 ]]; then
                record_test_result "$test_name" "fail" "Test timed out after ${MAX_RUNTIME}s"
            else
                record_test_result "$test_name" "fail" "Test failed with exit code $exit_code"
            fi
            
            # Show output on failure
            echo "Test output:"
            tail -n 50 "$test_output" | sed 's/^/  /'
        fi
    fi
    
    # Clean up test environment
    cleanup_integration_environment "$test_name" "$test_dir"
}

# Record test results
record_test_result() {
    local test_name="$1"
    local status="$2"  # pass, fail, skip
    local message="${3:-}"
    
    ((TOTAL_TESTS++)) || true
    
    case "$status" in
        pass)
            ((PASSED_TESTS++)) || true
            print_success "[PASS] $test_name"
            ;;
        fail)
            ((FAILED_TESTS++)) || true
            print_error "[FAIL] $test_name"
            [[ -n "$message" ]] && echo "       └─ $message" >&2
            ;;
        skip)
            ((SKIPPED_TESTS++)) || true
            print_warning "[SKIP] $test_name"
            [[ -n "$message" ]] && echo "       └─ $message"
            ;;
    esac
}

# Run workflow tests
run_workflow_tests() {
    print_header "Git Workflow Integration Tests"
    
    # Feature development workflow
    run_integration_test "feature_development_workflow" test_feature_development_workflow
    
    # Hotfix emergency workflow
    run_integration_test "hotfix_emergency_workflow" test_hotfix_emergency_workflow
    
    # Release preparation workflow
    run_integration_test "release_preparation_workflow" test_release_preparation_workflow
    
    # Repository sync workflow
    run_integration_test "repository_sync_workflow" test_repository_sync_workflow
    
    # Team collaboration workflow
    run_integration_test "team_collaboration_workflow" test_team_collaboration_workflow
}

# Run error recovery tests
run_error_recovery_tests() {
    print_header "Error Recovery Integration Tests"
    
    # Conflict resolution
    run_integration_test "conflict_resolution" test_conflict_resolution_workflow
    
    # Failed push recovery
    run_integration_test "failed_push_recovery" test_failed_push_recovery
    
    # Rollback procedures
    run_integration_test "rollback_procedures" test_rollback_procedures
    
    # Hook failure recovery
    run_integration_test "hook_failure_recovery" test_hook_failure_recovery
}

# Run performance tests
run_performance_tests() {
    print_header "Performance Integration Tests"
    
    # Large repository handling
    run_integration_test "large_repo_performance" test_large_repository_performance
    
    # Multiple concurrent operations
    run_integration_test "concurrent_operations" test_concurrent_git_operations
    
    # Network latency simulation
    if [[ "$CI_MODE" == false ]]; then
        run_integration_test "network_latency" test_network_latency_handling
    fi
}

# Run cross-platform tests
run_cross_platform_tests() {
    print_header "Cross-Platform Integration Tests"
    
    # Platform-specific paths
    run_integration_test "platform_paths" test_platform_specific_paths
    
    # Line ending handling
    run_integration_test "line_endings" test_line_ending_handling
    
    # Permission handling
    run_integration_test "permissions" test_permission_handling
}

# Generate test report
generate_test_report() {
    print_header "Integration Test Report"
    
    echo -e "${BLUE}📊 Test Summary${NC}"
    echo -e "Total Tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    echo -e "${YELLOW}Skipped: $SKIPPED_TESTS${NC}"
    
    # Calculate pass rate
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        local pass_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
        echo -e "\n${BLUE}Pass Rate: ${pass_rate}%${NC}"
    fi
    
    # Environment info
    echo -e "\n${BLUE}🔧 Environment${NC}"
    echo -e "Claude Available: $([ "$CLAUDE_AVAILABLE" == true ] && echo "Yes" || echo "No")"
    echo -e "CI Mode: $([ "$CI_MODE" == true ] && echo "Yes" || echo "No")"
    echo -e "Platform: $(uname -s)"
    
    # Overall status
    echo -e "\n${BLUE}🎯 Overall Status${NC}"
    if [[ $FAILED_TESTS -eq 0 && $TOTAL_TESTS -gt 0 ]]; then
        echo -e "${GREEN}✅ SUCCESS: All tests passed!${NC}"
        return 0
    elif [[ $FAILED_TESTS -gt 0 ]]; then
        echo -e "${RED}❌ FAILURE: $FAILED_TESTS tests failed${NC}"
        return 1
    else
        echo -e "${YELLOW}⚠ WARNING: No tests were run${NC}"
        return 1
    fi
}

# Help function
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Phase 3 Integration E2E Testing Framework for Claude Flow Git Commands

OPTIONS:
    -h, --help              Show this help message
    -m, --mode MODE         Test mode: all, workflow, error, performance, platform
    -t, --test TEST         Run specific test by name
    -d, --debug             Enable debug output
    -v, --verbose           Enable verbose output
    -n, --dry-run           Show what would be tested without running
    -l, --list              List available tests
    --no-color              Disable colored output
    --ci                    Force CI mode

TEST MODES:
    all         Run all integration tests (default)
    workflow    Run workflow integration tests
    error       Run error recovery tests
    performance Run performance tests
    platform    Run cross-platform tests

EXAMPLES:
    $SCRIPT_NAME                              # Run all tests
    $SCRIPT_NAME -m workflow                  # Run workflow tests
    $SCRIPT_NAME -t feature_development_workflow  # Run specific test
    $SCRIPT_NAME -d -m error                  # Debug error tests
    $SCRIPT_NAME -n                           # Dry run

EXIT CODES:
    0 - All tests passed
    1 - One or more tests failed
    2 - Environment validation failed
EOF
}

# List available tests
list_tests() {
    print_header "Available Integration Tests"
    
    echo -e "\n${BLUE}Workflow Tests:${NC}"
    echo "  - feature_development_workflow"
    echo "  - hotfix_emergency_workflow"
    echo "  - release_preparation_workflow"
    echo "  - repository_sync_workflow"
    echo "  - team_collaboration_workflow"
    
    echo -e "\n${BLUE}Error Recovery Tests:${NC}"
    echo "  - conflict_resolution"
    echo "  - failed_push_recovery"
    echo "  - rollback_procedures"
    echo "  - hook_failure_recovery"
    
    echo -e "\n${BLUE}Performance Tests:${NC}"
    echo "  - large_repo_performance"
    echo "  - concurrent_operations"
    echo "  - network_latency"
    
    echo -e "\n${BLUE}Cross-Platform Tests:${NC}"
    echo "  - platform_paths"
    echo "  - line_endings"
    echo "  - permissions"
}

# Main execution function
main() {
    local specific_test=""
    local list_only=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                return 0
                ;;
            -m|--mode)
                TEST_MODE="$2"
                shift 2
                ;;
            -t|--test)
                specific_test="$2"
                shift 2
                ;;
            -d|--debug)
                DEBUG_MODE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -l|--list)
                list_only=true
                shift
                ;;
            --no-color)
                # Disable colors
                GREEN=''
                YELLOW=''
                BLUE=''
                RED=''
                CYAN=''
                MAGENTA=''
                NC=''
                shift
                ;;
            --ci)
                CI_MODE=true
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                show_help
                return 1
                ;;
            *)
                print_error "Unexpected argument: $1"
                show_help
                return 1
                ;;
        esac
    done
    
    # Banner
    echo "Claude Flow Integration E2E Testing Framework"
    echo "==========================================="
    
    # List tests if requested
    if [[ "$list_only" == true ]]; then
        list_tests
        return 0
    fi
    
    # Validate environment
    if ! validate_environment; then
        print_error "Environment validation failed"
        return 2
    fi
    
    # Start resource monitoring
    start_resource_monitoring
    
    # Run specific test if requested
    if [[ -n "$specific_test" ]]; then
        print_header "Running Specific Test: $specific_test"
        
        # Map test name to function
        local test_function="test_${specific_test}"
        if type -t "$test_function" >/dev/null; then
            run_integration_test "$specific_test" "$test_function"
        else
            print_error "Test not found: $specific_test"
            return 1
        fi
    else
        # Run test suites based on mode
        case "$TEST_MODE" in
            all)
                run_workflow_tests
                run_error_recovery_tests
                run_performance_tests
                run_cross_platform_tests
                ;;
            workflow)
                run_workflow_tests
                ;;
            error)
                run_error_recovery_tests
                ;;
            performance)
                run_performance_tests
                ;;
            platform)
                run_cross_platform_tests
                ;;
            *)
                print_error "Invalid test mode: $TEST_MODE"
                show_help
                return 1
                ;;
        esac
    fi
    
    # Generate report
    generate_test_report
    return $?
}

# Run main function only if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi