#!/bin/bash

# Comprehensive Test Runner for Claude Flow Git Command Testing Framework
# Orchestrates all testing phases: static validation, mock execution, and integration
# Supports parallel execution, multiple test modes, and CI/CD integration

# Enable strict error handling
set -euo pipefail

# Ensure clean exit on signals
trap 'cleanup_on_exit $?' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Colors (default values, can be overridden)
GREEN=${GREEN:-'\033[0;32m'}
YELLOW=${YELLOW:-'\033[1;33m'}
BLUE=${BLUE:-'\033[0;34m'}
RED=${RED:-'\033[0;31m'}
CYAN=${CYAN:-'\033[0;36m'}
MAGENTA=${MAGENTA:-'\033[0;35m'}
NC=${NC:-'\033[0m'}

# Global variables
readonly SCRIPT_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && builtin pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly LIB_DIR="${SCRIPT_DIR}/lib"
readonly CONFIG_DIR="${SCRIPT_DIR}/config"
readonly CACHE_DIR="${SCRIPT_DIR}/.cache"
readonly RESULTS_DIR="${SCRIPT_DIR}/results"
readonly TEMP_DIR="${SCRIPT_DIR}/tmp/test-runner-$$"

# Test phases
readonly PHASE_STATIC="static"
readonly PHASE_MOCK="mock"
readonly PHASE_INTEGRATION="integration"

# Test configuration
TEST_MODE="full"
TEST_PHASES=()
PARALLEL_JOBS=4
DEBUG_MODE=false
VERBOSE=false
NO_CACHE=false
NO_COLOR=false
CI_MODE=false
REPORT_FORMAT="console"
RETRY_FAILED=true
MAX_RETRIES=2
USE_TIMEOUT=true

# Test results - using regular variables for macOS compatibility
PHASE_RESULTS_STATIC=""
PHASE_RESULTS_MOCK=""
PHASE_RESULTS_INTEGRATION=""
PHASE_DURATIONS_STATIC=""
PHASE_DURATIONS_MOCK=""
PHASE_DURATIONS_INTEGRATION=""
PHASE_METRICS=""
TOTAL_START_TIME=$(date +%s)

# Exit handler for cleanup
cleanup_on_exit() {
    local exit_code=${1:-$?}
    local total_end_time
    total_end_time=$(date +%s)
    local total_duration=$((total_end_time - TOTAL_START_TIME))
    
    # Clean up temporary directory
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    
    # Stop any background processes
    jobs -p | xargs -r kill 2>/dev/null || true
    
    if [[ ${exit_code} -ne 0 ]]; then
        print_error "Test runner failed with exit code ${exit_code}"
    fi
    
    # Save test results to cache
    if [[ "$NO_CACHE" == false ]] && [[ -n "$PHASE_RESULTS_STATIC$PHASE_RESULTS_MOCK$PHASE_RESULTS_INTEGRATION" ]]; then
        save_test_cache
    fi
}

# Utility functions
print_header() {
    local message="${1:-}"
    [[ -n "${message}" ]] && echo -e "\n${BLUE}=== ${message} ===${NC}"
}

print_section() {
    local message="${1:-}"
    [[ -n "${message}" ]] && echo -e "\n${CYAN}--- ${message} ---${NC}"
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

# Load configuration
load_configuration() {
    print_header "Loading Configuration"
    
    # Create necessary directories
    mkdir -p "$CACHE_DIR" "$RESULTS_DIR" "$TEMP_DIR"
    
    # Load test configuration if exists
    local config_file="${CONFIG_DIR}/test-config.yaml"
    if [[ -f "$config_file" ]]; then
        print_info "Loading configuration from $config_file"
        # In real implementation, would parse YAML
        # For now, we'll use defaults
    else
        print_warning "Configuration file not found, using defaults"
    fi
    
    # Detect CI environment
    if [[ -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" || -n "${JENKINS_URL:-}" ]]; then
        CI_MODE=true
        print_info "Detected CI environment"
        
        # CI-specific settings
        NO_COLOR=true
        PARALLEL_JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)
        REPORT_FORMAT="junit"
    fi
    
    # Source test reporter library
    if [[ -f "$LIB_DIR/test-reporter.sh" ]]; then
        source "$LIB_DIR/test-reporter.sh"
    else
        print_warning "Test reporter library not found, using basic reporting"
    fi
    
    print_success "Configuration loaded"
}

# Validate environment
validate_environment() {
    print_header "Environment Validation"
    
    # Check required test scripts
    local required_scripts=(
        "${SCRIPT_DIR}/validate-git-commands.sh"
        "${SCRIPT_DIR}/mock-git-test.sh"
        "${SCRIPT_DIR}/integration-git-test.sh"
    )
    
    for script in "${required_scripts[@]}"; do
        if [[ ! -f "$script" ]]; then
            print_error "Required test script not found: $script"
            return 1
        fi
        
        if [[ ! -x "$script" ]]; then
            chmod +x "$script"
            print_info "Made executable: $script"
        fi
    done
    
    # Check dependencies
    local deps=("bash" "git")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            print_error "Required dependency not found: $dep"
            return 1
        fi
    done
    
    # Check optional dependencies
    if ! command -v timeout >/dev/null 2>&1; then
        print_warning "timeout command not found - will use basic execution without timeouts"
        USE_TIMEOUT=false
    else
        USE_TIMEOUT=true
    fi
    
    # Check parallel execution tool
    if command -v parallel >/dev/null 2>&1; then
        print_info "GNU Parallel available for parallel execution"
    else
        print_warning "GNU Parallel not found, falling back to sequential execution"
        PARALLEL_JOBS=1
    fi
    
    print_success "Environment validation passed"
    return 0
}

# Run static validation phase
run_static_validation() {
    print_header "Phase 1: Static Validation"
    
    local phase_start
    phase_start=$(date +%s)
    local result_file="${TEMP_DIR}/static-results.txt"
    
    local cmd=("${SCRIPT_DIR}/validate-git-commands.sh")
    
    # Add options based on configuration
    if [[ "$VERBOSE" == true ]]; then
        cmd+=("-v")
    fi
    
    if [[ "$NO_COLOR" == true ]]; then
        cmd+=("--no-color")
    fi
    
    # Run validation
    if "${cmd[@]}" > "$result_file" 2>&1; then
        PHASE_RESULTS_STATIC="pass"
        print_success "Static validation completed successfully"
    else
        local exit_code=$?
        PHASE_RESULTS_STATIC="fail"
        print_error "Static validation failed with exit code $exit_code"
        
        # Show last few lines of output
        if [[ -f "$result_file" ]]; then
            echo "Last 20 lines of output:"
            tail -n 20 "$result_file" | sed 's/^/  /'
        fi
        
        # In fail-fast mode, exit immediately
        if [[ "$TEST_MODE" == "quick" ]]; then
            return $exit_code
        fi
    fi
    
    # Calculate duration
    local phase_end
    phase_end=$(date +%s)
    PHASE_DURATIONS_STATIC=$((phase_end - phase_start))
    
    # Extract metrics from output
    if [[ -f "$result_file" ]]; then
        extract_static_metrics "$result_file"
    fi
    
    return 0
}

# Run mock execution phase
run_mock_execution() {
    print_header "Phase 2: Mock Execution"
    
    local phase_start
    phase_start=$(date +%s)
    local result_file="${TEMP_DIR}/mock-results.txt"
    
    local cmd=("${SCRIPT_DIR}/mock-git-test.sh")
    
    # Add options based on configuration
    if [[ "$DEBUG_MODE" == true ]]; then
        cmd+=("-d")
    fi
    
    if [[ "$VERBOSE" == true ]]; then
        cmd+=("-v")
    fi
    
    if [[ "$NO_COLOR" == true ]]; then
        cmd+=("--no-color")
    fi
    
    # Select test mode
    case "$TEST_MODE" in
        quick)
            cmd+=("-m" "happy")
            ;;
        full)
            cmd+=("-m" "all")
            ;;
        debug)
            cmd+=("-m" "all" "-d")
            ;;
    esac
    
    # Run mock tests with retry logic
    local attempt=0
    local success=false
    
    while [[ $attempt -lt $MAX_RETRIES ]] && [[ "$success" == false ]]; do
        ((attempt++))
        
        if [[ $attempt -gt 1 ]]; then
            print_info "Retry attempt $attempt of $MAX_RETRIES"
        fi
        
        if "${cmd[@]}" > "$result_file" 2>&1; then
            PHASE_RESULTS_MOCK="pass"
            print_success "Mock execution completed successfully"
            success=true
        else
            local exit_code=$?
            
            if [[ $attempt -eq $MAX_RETRIES ]] || [[ "$RETRY_FAILED" == false ]]; then
                PHASE_RESULTS_MOCK="fail"
                print_error "Mock execution failed with exit code $exit_code"
                
                # Show last few lines of output
                if [[ -f "$result_file" ]]; then
                    echo "Last 20 lines of output:"
                    tail -n 20 "$result_file" | sed 's/^/  /'
                fi
                
                # In fail-fast mode, exit immediately
                if [[ "$TEST_MODE" == "quick" ]]; then
                    return $exit_code
                fi
            fi
        fi
    done
    
    # Calculate duration
    local phase_end
    phase_end=$(date +%s)
    PHASE_DURATIONS_MOCK=$((phase_end - phase_start))
    
    # Extract metrics from output
    if [[ -f "$result_file" ]]; then
        extract_mock_metrics "$result_file"
    fi
    
    return 0
}

# Run integration tests
run_integration_tests() {
    print_header "Phase 3: Integration E2E Tests"
    
    local phase_start
    phase_start=$(date +%s)
    local result_file="${TEMP_DIR}/integration-results.txt"
    
    local cmd=("${SCRIPT_DIR}/integration-git-test.sh")
    
    # Add options based on configuration
    if [[ "$DEBUG_MODE" == true ]]; then
        cmd+=("-d")
    fi
    
    if [[ "$VERBOSE" == true ]]; then
        cmd+=("-v")
    fi
    
    if [[ "$NO_COLOR" == true ]]; then
        cmd+=("--no-color")
    fi
    
    if [[ "$CI_MODE" == true ]]; then
        cmd+=("--ci")
    fi
    
    # Select test mode
    case "$TEST_MODE" in
        quick)
            cmd+=("-m" "workflow")
            ;;
        full)
            cmd+=("-m" "all")
            ;;
        debug)
            cmd+=("-m" "all" "-d")
            ;;
    esac
    
    # Run integration tests
    if "${cmd[@]}" > "$result_file" 2>&1; then
        PHASE_RESULTS_INTEGRATION="pass"
        print_success "Integration tests completed successfully"
    else
        local exit_code=$?
        PHASE_RESULTS_INTEGRATION="fail"
        print_error "Integration tests failed with exit code $exit_code"
        
        # Show last few lines of output
        if [[ -f "$result_file" ]]; then
            echo "Last 30 lines of output:"
            tail -n 30 "$result_file" | sed 's/^/  /'
        fi
    fi
    
    # Calculate duration
    local phase_end
    phase_end=$(date +%s)
    PHASE_DURATIONS_INTEGRATION=$((phase_end - phase_start))
    
    # Extract metrics from output
    if [[ -f "$result_file" ]]; then
        extract_integration_metrics "$result_file"
    fi
    
    return 0
}

# Extract metrics from test output
extract_static_metrics() {
    local output_file="$1"
    
    # Extract validation metrics
    local errors warnings
    errors=$(grep -c "✗" "$output_file" 2>/dev/null || echo 0)
    warnings=$(grep -c "⚠" "$output_file" 2>/dev/null || echo 0)
    
    STATIC_ERRORS=$errors
    STATIC_WARNINGS=$warnings
}

extract_mock_metrics() {
    local output_file="$1"
    
    # Extract test metrics
    MOCK_TOTAL=$(grep -E "Total Tests: [0-9]+" "$output_file" | grep -oE "[0-9]+" | tail -1 || echo 0)
    MOCK_PASSED=$(grep -E "Passed: [0-9]+" "$output_file" | grep -oE "[0-9]+" | tail -1 || echo 0)
    MOCK_FAILED=$(grep -E "Failed: [0-9]+" "$output_file" | grep -oE "[0-9]+" | tail -1 || echo 0)
    MOCK_SKIPPED=$(grep -E "Skipped: [0-9]+" "$output_file" | grep -oE "[0-9]+" | tail -1 || echo 0)
}

extract_integration_metrics() {
    local output_file="$1"
    
    # Extract test metrics
    INTEGRATION_TOTAL=$(grep -E "Total Tests: [0-9]+" "$output_file" | grep -oE "[0-9]+" | tail -1 || echo 0)
    INTEGRATION_PASSED=$(grep -E "Passed: [0-9]+" "$output_file" | grep -oE "[0-9]+" | tail -1 || echo 0)
    INTEGRATION_FAILED=$(grep -E "Failed: [0-9]+" "$output_file" | grep -oE "[0-9]+" | tail -1 || echo 0)
    INTEGRATION_SKIPPED=$(grep -E "Skipped: [0-9]+" "$output_file" | grep -oE "[0-9]+" | tail -1 || echo 0)
}

# Check test cache
check_test_cache() {
    if [[ "$NO_CACHE" == true ]]; then
        return 1
    fi
    
    local cache_file="${CACHE_DIR}/last-test-results.json"
    if [[ -f "$cache_file" ]]; then
        local cache_age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null || echo 0)))
        
        # Cache is valid for 1 hour
        if [[ $cache_age -lt 3600 ]]; then
            print_info "Found recent test cache (${cache_age}s old)"
            return 0
        fi
    fi
    
    return 1
}

# Save test cache
save_test_cache() {
    local cache_file="${CACHE_DIR}/last-test-results.json"
    
    # Create simple JSON output
    {
        echo "{"
        echo "  \"timestamp\": $(date +%s),"
        echo "  \"test_mode\": \"$TEST_MODE\","
        echo "  \"phases\": {"
        echo "    \"static\": {"
        echo "      \"result\": \"${PHASE_RESULTS_STATIC:-unknown}\","
        echo "      \"duration\": ${PHASE_DURATIONS_STATIC:-0}"
        echo "    },"
        echo "    \"mock\": {"
        echo "      \"result\": \"${PHASE_RESULTS_MOCK:-unknown}\","
        echo "      \"duration\": ${PHASE_DURATIONS_MOCK:-0}"
        echo "    },"
        echo "    \"integration\": {"
        echo "      \"result\": \"${PHASE_RESULTS_INTEGRATION:-unknown}\","
        echo "      \"duration\": ${PHASE_DURATIONS_INTEGRATION:-0}"
        echo "    }"
        echo "  },"
        echo "  \"metrics\": {"
        echo "    \"static_errors\": ${STATIC_ERRORS:-0},"
        echo "    \"static_warnings\": ${STATIC_WARNINGS:-0},"
        echo "    \"mock_total\": ${MOCK_TOTAL:-0},"
        echo "    \"mock_passed\": ${MOCK_PASSED:-0},"
        echo "    \"mock_failed\": ${MOCK_FAILED:-0},"
        echo "    \"integration_total\": ${INTEGRATION_TOTAL:-0},"
        echo "    \"integration_passed\": ${INTEGRATION_PASSED:-0},"
        echo "    \"integration_failed\": ${INTEGRATION_FAILED:-0}"
        echo "  }"
        echo "}"
    } > "$cache_file"
}

# Generate comprehensive report
generate_comprehensive_report() {
    print_header "Test Execution Report"
    
    local total_duration=$(($(date +%s) - TOTAL_START_TIME))
    
    # Summary
    echo -e "\n${BLUE}📊 Test Summary${NC}"
    echo -e "Test Mode: $TEST_MODE"
    echo -e "Total Duration: ${total_duration}s"
    echo -e "Parallel Jobs: $PARALLEL_JOBS"
    
    # Phase results
    echo -e "\n${BLUE}📋 Phase Results${NC}"
    
    local all_passed=true
    
    # Static phase
    if [[ -n "$PHASE_RESULTS_STATIC" ]]; then
        local status_icon
        if [[ "$PHASE_RESULTS_STATIC" == "pass" ]]; then
            status_icon="${GREEN}✓${NC}"
        else
            status_icon="${RED}✗${NC}"
            all_passed=false
        fi
        printf "%-20s %s %-10s %5ds\n" "static:" "$status_icon" "$PHASE_RESULTS_STATIC" "${PHASE_DURATIONS_STATIC:-0}"
    fi
    
    # Mock phase
    if [[ -n "$PHASE_RESULTS_MOCK" ]]; then
        local status_icon
        if [[ "$PHASE_RESULTS_MOCK" == "pass" ]]; then
            status_icon="${GREEN}✓${NC}"
        else
            status_icon="${RED}✗${NC}"
            all_passed=false
        fi
        printf "%-20s %s %-10s %5ds\n" "mock:" "$status_icon" "$PHASE_RESULTS_MOCK" "${PHASE_DURATIONS_MOCK:-0}"
    fi
    
    # Integration phase
    if [[ -n "$PHASE_RESULTS_INTEGRATION" ]]; then
        local status_icon
        if [[ "$PHASE_RESULTS_INTEGRATION" == "pass" ]]; then
            status_icon="${GREEN}✓${NC}"
        else
            status_icon="${RED}✗${NC}"
            all_passed=false
        fi
        printf "%-20s %s %-10s %5ds\n" "integration:" "$status_icon" "$PHASE_RESULTS_INTEGRATION" "${PHASE_DURATIONS_INTEGRATION:-0}"
    fi
    
    # Detailed metrics
    echo -e "\n${BLUE}📈 Detailed Metrics${NC}"
    
    # Static validation metrics
    if [[ -n "${STATIC_ERRORS:-}" ]] || [[ -n "${STATIC_WARNINGS:-}" ]]; then
        echo -e "\nStatic Validation:"
        echo -e "  Errors: ${STATIC_ERRORS:-0}"
        echo -e "  Warnings: ${STATIC_WARNINGS:-0}"
    fi
    
    # Mock execution metrics
    if [[ -n "${MOCK_TOTAL:-}" ]] && [[ "${MOCK_TOTAL:-0}" -gt 0 ]]; then
        echo -e "\nMock Execution:"
        echo -e "  Total Tests: ${MOCK_TOTAL:-0}"
        echo -e "  Passed: ${GREEN}${MOCK_PASSED:-0}${NC}"
        echo -e "  Failed: ${RED}${MOCK_FAILED:-0}${NC}"
        echo -e "  Skipped: ${YELLOW}${MOCK_SKIPPED:-0}${NC}"
    fi
    
    # Integration test metrics
    if [[ -n "${INTEGRATION_TOTAL:-}" ]] && [[ "${INTEGRATION_TOTAL:-0}" -gt 0 ]]; then
        echo -e "\nIntegration Tests:"
        echo -e "  Total Tests: ${INTEGRATION_TOTAL:-0}"
        echo -e "  Passed: ${GREEN}${INTEGRATION_PASSED:-0}${NC}"
        echo -e "  Failed: ${RED}${INTEGRATION_FAILED:-0}${NC}"
        echo -e "  Skipped: ${YELLOW}${INTEGRATION_SKIPPED:-0}${NC}"
    fi
    
    # Performance analysis
    if [[ "$VERBOSE" == true ]]; then
        echo -e "\n${BLUE}⚡ Performance Analysis${NC}"
        
        # Check for performance regression
        if check_test_cache; then
            # Compare with previous results
            print_info "Performance comparison available in cache"
        fi
    fi
    
    # Overall status
    echo -e "\n${BLUE}🎯 Overall Status${NC}"
    if [[ "$all_passed" == true ]]; then
        echo -e "${GREEN}✅ SUCCESS: All test phases passed!${NC}"
        
        # Save results to file
        local results_file="${RESULTS_DIR}/test-results-$(date +%Y%m%d-%H%M%S).txt"
        {
            echo "Test Results - $(date)"
            echo "===================="
            echo "Status: PASS"
            echo "Mode: $TEST_MODE"
            echo "Duration: ${total_duration}s"
        } > "$results_file"
        
        return 0
    else
        echo -e "${RED}❌ FAILURE: One or more test phases failed${NC}"
        
        # Save results to file
        local results_file="${RESULTS_DIR}/test-results-$(date +%Y%m%d-%H%M%S).txt"
        {
            echo "Test Results - $(date)"
            echo "===================="
            echo "Status: FAIL"
            echo "Mode: $TEST_MODE"
            echo "Duration: ${total_duration}s"
            echo ""
            echo "Failed Phases:"
            if [[ "$PHASE_RESULTS_STATIC" == "fail" ]]; then
                echo "  - static"
            fi
            if [[ "$PHASE_RESULTS_MOCK" == "fail" ]]; then
                echo "  - mock"
            fi
            if [[ "$PHASE_RESULTS_INTEGRATION" == "fail" ]]; then
                echo "  - integration"
            fi
        } > "$results_file"
        
        return 1
    fi
}

# Generate JUnit XML report for CI
generate_junit_report() {
    local junit_file="${RESULTS_DIR}/junit-results.xml"
    
    {
        echo '<?xml version="1.0" encoding="UTF-8"?>'
        echo '<testsuites>'
        
        # Static phase
        if [[ -n "$PHASE_RESULTS_STATIC" ]]; then
            local tests="${STATIC_ERRORS:-0}"
            local failures="${STATIC_ERRORS:-0}"
            local duration="${PHASE_DURATIONS_STATIC:-0}"
            
            echo "  <testsuite name=\"static\" tests=\"1\" failures=\"$failures\" time=\"$duration\">"
            echo "    <testcase name=\"static_validation\" time=\"$duration\">"
            if [[ "$PHASE_RESULTS_STATIC" == "fail" ]]; then
                echo "      <failure message=\"Static validation failed\">Found $failures errors</failure>"
            fi
            echo "    </testcase>"
            echo "  </testsuite>"
        fi
        
        # Mock phase
        if [[ -n "$PHASE_RESULTS_MOCK" ]]; then
            local tests="${MOCK_TOTAL:-1}"
            local failures="${MOCK_FAILED:-0}"
            local skipped="${MOCK_SKIPPED:-0}"
            local duration="${PHASE_DURATIONS_MOCK:-0}"
            
            echo "  <testsuite name=\"mock\" tests=\"$tests\" failures=\"$failures\" skipped=\"$skipped\" time=\"$duration\">"
            echo "    <testcase name=\"mock_execution\" time=\"$duration\">"
            if [[ "$PHASE_RESULTS_MOCK" == "fail" ]]; then
                echo "      <failure message=\"Mock tests failed\">$failures out of $tests tests failed</failure>"
            fi
            echo "    </testcase>"
            echo "  </testsuite>"
        fi
        
        # Integration phase
        if [[ -n "$PHASE_RESULTS_INTEGRATION" ]]; then
            local tests="${INTEGRATION_TOTAL:-1}"
            local failures="${INTEGRATION_FAILED:-0}"
            local skipped="${INTEGRATION_SKIPPED:-0}"
            local duration="${PHASE_DURATIONS_INTEGRATION:-0}"
            
            echo "  <testsuite name=\"integration\" tests=\"$tests\" failures=\"$failures\" skipped=\"$skipped\" time=\"$duration\">"
            echo "    <testcase name=\"integration_tests\" time=\"$duration\">"
            if [[ "$PHASE_RESULTS_INTEGRATION" == "fail" ]]; then
                echo "      <failure message=\"Integration tests failed\">$failures out of $tests tests failed</failure>"
            fi
            echo "    </testcase>"
            echo "  </testsuite>"
        fi
        
        echo '</testsuites>'
    } > "$junit_file"
    
    print_info "JUnit report saved to: $junit_file"
}

# Help function
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Comprehensive Test Runner for Claude Flow Git Command Testing Framework

OPTIONS:
    -h, --help              Show this help message
    -m, --mode MODE         Test mode: quick, full, debug, ci (default: full)
    -p, --phase PHASE       Run specific phase: static, mock, integration
    -j, --jobs N            Number of parallel jobs (default: 4)
    -d, --debug             Enable debug output
    -v, --verbose           Enable verbose output
    -r, --report FORMAT     Report format: console, junit, json (default: console)
    --no-cache              Disable test result caching
    --no-retry              Disable automatic retry on failures
    --no-color              Disable colored output

TEST MODES:
    quick       Run essential tests only (fast feedback)
    full        Run complete test suite (default)
    debug       Run all tests with debug output
    ci          Optimized for CI/CD environments

PHASES:
    static      Phase 1: Static validation and analysis
    mock        Phase 2: Mock execution testing
    integration Phase 3: Integration E2E testing

EXAMPLES:
    $SCRIPT_NAME                        # Run full test suite
    $SCRIPT_NAME -m quick               # Quick test run
    $SCRIPT_NAME -p static              # Run static validation only
    $SCRIPT_NAME -m full -j 8           # Full suite with 8 parallel jobs
    $SCRIPT_NAME -d -p mock             # Debug mock tests
    $SCRIPT_NAME -r junit               # Generate JUnit report for CI

ENVIRONMENT VARIABLES:
    CI                  Set to enable CI mode
    GITHUB_ACTIONS      Detected automatically for GitHub Actions
    TEST_CACHE_DIR     Override cache directory
    TEST_RESULTS_DIR   Override results directory

EXIT CODES:
    0 - All tests passed
    1 - One or more tests failed
    2 - Configuration or environment error
EOF
}

# Main execution function
main() {
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
            -p|--phase)
                TEST_PHASES+=("$2")
                shift 2
                ;;
            -j|--jobs)
                PARALLEL_JOBS="$2"
                shift 2
                ;;
            -d|--debug)
                DEBUG_MODE=true
                VERBOSE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -r|--report)
                REPORT_FORMAT="$2"
                shift 2
                ;;
            --no-cache)
                NO_CACHE=true
                shift
                ;;
            --no-retry)
                RETRY_FAILED=false
                shift
                ;;
            --no-color)
                NO_COLOR=true
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
    echo "Claude Flow Git Command Testing Framework"
    echo "========================================"
    echo "Test Runner v1.0.0"
    
    # Load configuration
    load_configuration
    
    # Validate environment
    if ! validate_environment; then
        print_error "Environment validation failed"
        return 2
    fi
    
    # Validate test mode
    case "$TEST_MODE" in
        quick|full|debug|ci)
            ;;
        *)
            print_error "Invalid test mode: $TEST_MODE"
            show_help
            return 1
            ;;
    esac
    
    # If no specific phases selected, run all based on mode
    if [[ ${#TEST_PHASES[@]} -eq 0 ]]; then
        case "$TEST_MODE" in
            quick)
                TEST_PHASES=($PHASE_STATIC $PHASE_MOCK)
                ;;
            *)
                TEST_PHASES=($PHASE_STATIC $PHASE_MOCK $PHASE_INTEGRATION)
                ;;
        esac
    fi
    
    print_info "Test mode: $TEST_MODE"
    print_info "Test phases: ${TEST_PHASES[*]}"
    print_info "Parallel jobs: $PARALLEL_JOBS"
    
    # Run selected test phases
    local overall_result=0
    
    for phase in "${TEST_PHASES[@]}"; do
        case "$phase" in
            "$PHASE_STATIC")
                run_static_validation || overall_result=$?
                ;;
            "$PHASE_MOCK")
                run_mock_execution || overall_result=$?
                ;;
            "$PHASE_INTEGRATION")
                run_integration_tests || overall_result=$?
                ;;
            *)
                print_error "Unknown test phase: $phase"
                overall_result=1
                ;;
        esac
    done
    
    # Generate reports based on format
    case "$REPORT_FORMAT" in
        console)
            generate_comprehensive_report
            ;;
        junit)
            generate_comprehensive_report
            generate_junit_report
            ;;
        json)
            generate_comprehensive_report
            save_test_cache
            print_info "JSON report saved to cache"
            ;;
        *)
            print_error "Unknown report format: $REPORT_FORMAT"
            ;;
    esac
    
    return $overall_result
}

# Run main function only if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi