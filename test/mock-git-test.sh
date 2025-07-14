#!/bin/bash

# Phase 2 Mock Execution Testing Framework for Claude Flow Git Commands
# Simulates git command execution and validates behavior without running actual git

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
readonly FIXTURES_DIR="${SCRIPT_DIR}/fixtures/mock-responses"
readonly COMMANDS_DIR="${SCRIPT_DIR}/../templates/commands"
readonly TEMP_DIR="${SCRIPT_DIR}/tmp/mock-test-$$"

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0
START_TIME=$(date +%s)

# Test modes
TEST_MODE="all"
DEBUG_MODE=false
VERBOSE=false

# Exit handler for cleanup
cleanup_on_exit() {
    local exit_code=${1:-$?}
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    # Clean up temporary directory
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    
    echo -e "\n${BLUE}=== Test Execution Complete ===${NC}"
    echo -e "${BLUE}Duration: ${duration}s${NC}"
    
    if [[ ${exit_code} -ne 0 ]]; then
        print_error "Tests failed with exit code ${exit_code}"
    fi
}

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

# Test result tracking
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

# Validate environment and dependencies
validate_environment() {
    print_header "Environment Validation"
    
    # Check required directories
    local required_dirs=("$LIB_DIR" "$FIXTURES_DIR" "$COMMANDS_DIR")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            print_error "Required directory not found: $dir"
            return 1
        fi
    done
    
    # Check required files
    local required_files=(
        "$LIB_DIR/mock-environment.sh"
        "$LIB_DIR/command-executor.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file not found: $file"
            return 1
        fi
        
        # Make scripts executable
        chmod +x "$file"
    done
    
    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    
    # Source libraries
    if ! source "$LIB_DIR/mock-environment.sh"; then
        print_error "Failed to source mock environment library"
        return 1
    fi
    
    if ! source "$LIB_DIR/command-executor.sh"; then
        print_error "Failed to source command executor library"
        return 1
    fi
    
    print_success "Environment validation passed"
    return 0
}

# Run happy path tests
run_happy_path_tests() {
    print_header "Happy Path Tests"
    
    # Test: Normal commit workflow
    run_test "normal_commit_workflow" test_normal_commit_workflow
    
    # Test: Branch creation and switching
    run_test "branch_operations" test_branch_operations
    
    # Test: Clean push operations
    run_test "clean_push" test_clean_push_operations
    
    # Test: Status checks
    run_test "status_checks" test_status_checks
}

# Run error condition tests
run_error_condition_tests() {
    print_header "Error Condition Tests"
    
    # Test: Pre-commit hook failures
    run_test "precommit_hook_failure" test_precommit_hook_failure
    
    # Test: Merge conflicts
    run_test "merge_conflicts" test_merge_conflicts
    
    # Test: Push rejections
    run_test "push_rejection" test_push_rejection
    
    # Test: Invalid branch operations
    run_test "invalid_branch_ops" test_invalid_branch_operations
}

# Run edge case tests
run_edge_case_tests() {
    print_header "Edge Case Tests"
    
    # Test: Large file detection
    run_test "large_file_detection" test_large_file_detection
    
    # Test: Protected branch commits
    run_test "protected_branch" test_protected_branch_commit
    
    # Test: Empty commits
    run_test "empty_commits" test_empty_commits
    
    # Test: Concurrent operations
    run_test "concurrent_ops" test_concurrent_operations
}

# Run security tests
run_security_tests() {
    print_header "Security Tests"
    
    # Test: Sensitive data detection
    run_test "sensitive_data" test_sensitive_data_detection
    
    # Test: Command injection prevention
    run_test "command_injection" test_command_injection_prevention
    
    # Test: Path traversal protection
    run_test "path_traversal" test_path_traversal_protection
    
    # Test: Argument sanitization
    run_test "arg_sanitization" test_argument_sanitization
}

# Run argument substitution tests
run_argument_substitution_tests() {
    print_header "Argument Substitution Tests"
    
    # Test: Basic substitution
    run_test "basic_substitution" test_basic_argument_substitution
    
    # Test: Complex arguments
    run_test "complex_arguments" test_complex_argument_patterns
    
    # Test: Special characters
    run_test "special_chars" test_special_character_handling
    
    # Test: Empty arguments
    run_test "empty_arguments" test_empty_argument_handling
}

# Run command flow tests
run_command_flow_tests() {
    print_header "Command Flow Tests"
    
    # Test: Command sequencing
    run_test "command_sequence" test_command_sequencing
    
    # Test: Prerequisite validation
    run_test "prerequisites" test_prerequisite_validation
    
    # Test: State transitions
    run_test "state_transitions" test_state_transitions
    
    # Test: Rollback scenarios
    run_test "rollback" test_rollback_scenarios
}

# Generic test runner
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    print_debug "Running test: $test_name"
    
    # Set up test environment
    setup_test_environment "$test_name"
    
    # Run the test
    if $test_function; then
        record_test_result "$test_name" "pass"
    else
        record_test_result "$test_name" "fail" "Test function returned non-zero"
    fi
    
    # Clean up test environment
    cleanup_test_environment "$test_name"
}

# Generate test report
generate_test_report() {
    print_header "Test Report"
    
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

Phase 2 Mock Execution Testing Framework for Claude Flow Git Commands

OPTIONS:
    -h, --help              Show this help message
    -m, --mode MODE         Test mode: all, happy, error, edge, security, args, flow
    -t, --test TEST         Run specific test by name
    -d, --debug             Enable debug output
    -v, --verbose           Enable verbose output
    -l, --list              List available tests
    --no-color              Disable colored output

TEST MODES:
    all         Run all tests (default)
    happy       Run happy path tests only
    error       Run error condition tests only
    edge        Run edge case tests only
    security    Run security tests only
    args        Run argument substitution tests only
    flow        Run command flow tests only

Examples:
    $SCRIPT_NAME                          # Run all tests
    $SCRIPT_NAME -m happy                 # Run happy path tests
    $SCRIPT_NAME -t normal_commit_workflow # Run specific test
    $SCRIPT_NAME -d -m error              # Debug error tests
    $SCRIPT_NAME -l                       # List available tests

Exit Codes:
    0 - All tests passed
    1 - One or more tests failed
    2 - Environment validation failed
EOF
}

# List available tests
list_tests() {
    print_header "Available Tests"
    
    echo -e "\n${BLUE}Happy Path Tests:${NC}"
    echo "  - normal_commit_workflow"
    echo "  - branch_operations"
    echo "  - clean_push"
    echo "  - status_checks"
    
    echo -e "\n${BLUE}Error Condition Tests:${NC}"
    echo "  - precommit_hook_failure"
    echo "  - merge_conflicts"
    echo "  - push_rejection"
    echo "  - invalid_branch_ops"
    
    echo -e "\n${BLUE}Edge Case Tests:${NC}"
    echo "  - large_file_detection"
    echo "  - protected_branch"
    echo "  - empty_commits"
    echo "  - concurrent_ops"
    
    echo -e "\n${BLUE}Security Tests:${NC}"
    echo "  - sensitive_data"
    echo "  - command_injection"
    echo "  - path_traversal"
    echo "  - arg_sanitization"
    
    echo -e "\n${BLUE}Argument Substitution Tests:${NC}"
    echo "  - basic_substitution"
    echo "  - complex_arguments"
    echo "  - special_chars"
    echo "  - empty_arguments"
    
    echo -e "\n${BLUE}Command Flow Tests:${NC}"
    echo "  - command_sequence"
    echo "  - prerequisites"
    echo "  - state_transitions"
    echo "  - rollback"
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
    echo "Claude Flow Mock Execution Testing Framework"
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
    
    # Run specific test if requested
    if [[ -n "$specific_test" ]]; then
        print_header "Running Specific Test: $specific_test"
        
        # Map test name to function
        local test_function="test_${specific_test}"
        if type -t "$test_function" >/dev/null; then
            run_test "$specific_test" "$test_function"
        else
            print_error "Test not found: $specific_test"
            return 1
        fi
    else
        # Run test suites based on mode
        case "$TEST_MODE" in
            all)
                run_happy_path_tests
                run_error_condition_tests
                run_edge_case_tests
                run_security_tests
                run_argument_substitution_tests
                run_command_flow_tests
                ;;
            happy)
                run_happy_path_tests
                ;;
            error)
                run_error_condition_tests
                ;;
            edge)
                run_edge_case_tests
                ;;
            security)
                run_security_tests
                ;;
            args)
                run_argument_substitution_tests
                ;;
            flow)
                run_command_flow_tests
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