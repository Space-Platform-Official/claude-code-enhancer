#!/bin/bash

# Main Edge Case Test Runner for Claude Flow Git Commands
# Orchestrates comprehensive edge case testing across all categories
# Integrates with existing test framework and provides unified reporting

# Enable strict error handling
set -euo pipefail

# Import test framework libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$(dirname "$SCRIPT_DIR")"

# Source required libraries
source "$TEST_ROOT/lib/test-reporter.sh"
source "$TEST_ROOT/lib/command-validator.sh"
source "$TEST_ROOT/lib/security-validator.sh"
source "$TEST_ROOT/lib/integration-environment.sh"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Edge case test configuration
readonly EDGE_CASE_CONFIG_FILE="${TEST_ROOT}/config/edge-case-config.yaml"
readonly EDGE_CASE_RESULTS_DIR="${TEST_ROOT}/results/edge-cases"

# Test categories and their scripts
declare -A EDGE_CASE_CATEGORIES
EDGE_CASE_CATEGORIES[git_state]="git-state-edge-cases.sh"
EDGE_CASE_CATEGORIES[input_validation]="input-validation-edge-cases.sh"
EDGE_CASE_CATEGORIES[environment]="environment-edge-cases.sh"
EDGE_CASE_CATEGORIES[security]="security-edge-cases.sh"

# Test statistics
declare -A TEST_STATS
TEST_STATS[total_tests]=0
TEST_STATS[passed_tests]=0
TEST_STATS[failed_tests]=0
TEST_STATS[skipped_tests]=0
TEST_STATS[critical_failures]=0

# Helper functions
print_header() {
    local title="$1"
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}${title}${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${BLUE}🐛 DEBUG: $1${NC}"
    fi
}

# Initialize edge case testing environment
initialize_edge_case_environment() {
    print_info "Initializing edge case testing environment"
    
    # Create results directory
    mkdir -p "$EDGE_CASE_RESULTS_DIR"
    
    # Set up test timestamp
    local timestamp=$(date +%Y%m%d-%H%M%S)
    export EDGE_CASE_RUN_ID="edge-cases-${timestamp}"
    export EDGE_CASE_LOG_FILE="${EDGE_CASE_RESULTS_DIR}/${EDGE_CASE_RUN_ID}.log"
    
    # Initialize test statistics
    TEST_STATS[start_time]=$(date +%s)
    
    # Create edge case configuration if it doesn't exist
    create_default_edge_case_config
    
    print_success "Edge case environment initialized"
}

# Create default edge case configuration
create_default_edge_case_config() {
    if [[ ! -f "$EDGE_CASE_CONFIG_FILE" ]]; then
        mkdir -p "$(dirname "$EDGE_CASE_CONFIG_FILE")"
        
        cat > "$EDGE_CASE_CONFIG_FILE" << 'EOF'
# Edge Case Test Configuration
edge_cases:
  # Git repository state edge cases
  git_state:
    enabled: true
    timeout_seconds: 300
    max_repo_size_mb: 100
    test_empty_repos: true
    test_corrupted_repos: true
    test_detached_head: true
    test_merge_conflicts: true
    
  # Input validation edge cases
  input_validation:
    enabled: true
    timeout_seconds: 120
    test_empty_arguments: true
    test_special_characters: true
    test_long_arguments: true
    test_injection_attempts: true
    
  # Environment edge cases
  environment:
    enabled: true
    timeout_seconds: 180
    test_missing_git: false  # Don't break actual git
    test_permissions: true
    test_network_issues: true
    test_platform_differences: true
    
  # Security edge cases
  security:
    enabled: true
    timeout_seconds: 240
    test_command_injection: true
    test_privilege_escalation: false  # Safety first
    test_credential_exposure: true
    test_tool_permissions: true

# Safety limits
safety:
  max_test_duration_minutes: 30
  max_file_size_mb: 50
  max_memory_mb: 512
  forbidden_commands:
    - "rm -rf /"
    - "sudo"
    - "chmod 777"
    - "format"
    - "mkfs"
EOF
        
        print_info "Created default edge case configuration"
    fi
}

# Load edge case configuration
load_edge_case_config() {
    local config_key="$1"
    local default_value="${2:-true}"
    
    # Simple YAML parsing for our configuration
    if [[ -f "$EDGE_CASE_CONFIG_FILE" ]]; then
        local value=$(grep -A 20 "^  ${config_key}:" "$EDGE_CASE_CONFIG_FILE" | 
                     grep "enabled:" | head -1 | 
                     sed 's/.*enabled: *//' | 
                     tr -d ' ')
        echo "${value:-$default_value}"
    else
        echo "$default_value"
    fi
}

# Pre-flight safety checks
run_preflight_checks() {
    print_info "Running pre-flight safety checks"
    
    local checks_passed=0
    local total_checks=5
    
    # Check 1: Verify we're in a test environment
    if [[ ! "$PWD" =~ test ]] && [[ "${FORCE_EDGE_TESTS:-false}" != "true" ]]; then
        print_error "Not in test environment (use FORCE_EDGE_TESTS=true to override)"
        return 1
    fi
    ((checks_passed++))
    
    # Check 2: Verify git is available
    if ! command -v git >/dev/null 2>&1; then
        print_error "Git is not installed or not in PATH"
        return 1
    fi
    ((checks_passed++))
    
    # Check 3: Check available disk space
    local available_space_kb=$(df . | tail -1 | awk '{print $4}')
    local required_space_kb=$((100 * 1024))  # 100MB
    
    if [[ $available_space_kb -lt $required_space_kb ]]; then
        print_error "Insufficient disk space (need 100MB, have $(($available_space_kb / 1024))MB)"
        return 1
    fi
    ((checks_passed++))
    
    # Check 4: Verify we can create test repositories
    local test_repo_dir="/tmp/claude-edge-test-$$"
    if ! mkdir -p "$test_repo_dir" 2>/dev/null; then
        print_error "Cannot create test directories"
        return 1
    fi
    rm -rf "$test_repo_dir"
    ((checks_passed++))
    
    # Check 5: Verify test framework libraries are available
    if [[ ! -f "$TEST_ROOT/lib/integration-environment.sh" ]]; then
        print_error "Test framework libraries not found"
        return 1
    fi
    ((checks_passed++))
    
    print_success "Pre-flight checks passed ($checks_passed/$total_checks)"
    return 0
}

# Execute edge case category
execute_edge_case_category() {
    local category="$1"
    local script_name="${EDGE_CASE_CATEGORIES[$category]}"
    local script_path="${SCRIPT_DIR}/${script_name}"
    
    print_info "Executing edge case category: $category"
    
    # Check if category is enabled
    local enabled=$(load_edge_case_config "$category" "true")
    if [[ "$enabled" != "true" ]]; then
        print_warning "Category '$category' is disabled, skipping"
        ((TEST_STATS[skipped_tests]++))
        return 0
    fi
    
    # Check if script exists
    if [[ ! -f "$script_path" ]]; then
        print_error "Edge case script not found: $script_path"
        ((TEST_STATS[failed_tests]++))
        return 1
    fi
    
    # Execute the edge case script
    local category_start_time=$(date +%s)
    local category_log="${EDGE_CASE_RESULTS_DIR}/${category}-${EDGE_CASE_RUN_ID}.log"
    
    print_info "Starting $category tests..."
    
    if bash "$script_path" 2>&1 | tee "$category_log"; then
        local category_end_time=$(date +%s)
        local category_duration=$((category_end_time - category_start_time))
        
        print_success "Category '$category' completed in ${category_duration}s"
        ((TEST_STATS[passed_tests]++))
        
        # Record timing
        record_test_timing "edge_case_${category}" "$category_duration"
        
        return 0
    else
        local exit_code=$?
        print_error "Category '$category' failed with exit code $exit_code"
        ((TEST_STATS[failed_tests]++))
        
        # Check for critical failures
        if [[ $exit_code -eq 2 ]]; then
            print_error "CRITICAL FAILURE detected in $category"
            ((TEST_STATS[critical_failures]++))
        fi
        
        # Record error
        record_test_error "edge_case_${category}" "Failed with exit code $exit_code"
        
        return $exit_code
    fi
}

# Generate comprehensive edge case report
generate_edge_case_report() {
    local end_time=$(date +%s)
    local total_duration=$((end_time - TEST_STATS[start_time]))
    
    print_header "Edge Case Test Results Summary"
    
    # Basic statistics
    echo -e "${CYAN}Test Execution Summary${NC}"
    echo -e "├─ Total Categories: ${#EDGE_CASE_CATEGORIES[@]}"
    echo -e "├─ ${GREEN}Passed: ${TEST_STATS[passed_tests]}${NC}"
    echo -e "├─ ${RED}Failed: ${TEST_STATS[failed_tests]}${NC}"
    echo -e "├─ ${YELLOW}Skipped: ${TEST_STATS[skipped_tests]}${NC}"
    echo -e "├─ ${RED}Critical Failures: ${TEST_STATS[critical_failures]}${NC}"
    echo -e "└─ Total Duration: $(format_duration $total_duration)"
    
    # Set global variables for test reporter
    export TOTAL_TESTS=${#EDGE_CASE_CATEGORIES[@]}
    export PASSED_TESTS=${TEST_STATS[passed_tests]}
    export FAILED_TESTS=${TEST_STATS[failed_tests]}
    export SKIPPED_TESTS=${TEST_STATS[skipped_tests]}
    export TOTAL_DURATION=$total_duration
    
    # Generate various report formats
    print_info "Generating detailed reports..."
    
    generate_console_report "Claude Flow Edge Case Test Report"
    generate_json_report "${EDGE_CASE_RESULTS_DIR}/${EDGE_CASE_RUN_ID}.json"
    generate_junit_xml_report "${EDGE_CASE_RESULTS_DIR}/${EDGE_CASE_RUN_ID}.xml"
    generate_markdown_report "${EDGE_CASE_RESULTS_DIR}/${EDGE_CASE_RUN_ID}.md"
    
    # Edge case specific analysis
    generate_edge_case_analysis
    
    # Return appropriate exit code
    if [[ ${TEST_STATS[critical_failures]} -gt 0 ]]; then
        print_error "CRITICAL FAILURES detected - immediate attention required"
        return 2
    elif [[ ${TEST_STATS[failed_tests]} -gt 0 ]]; then
        print_error "Some edge case tests failed - review required"
        return 1
    else
        print_success "All edge case tests completed successfully"
        return 0
    fi
}

# Generate edge case specific analysis
generate_edge_case_analysis() {
    local analysis_file="${EDGE_CASE_RESULTS_DIR}/${EDGE_CASE_RUN_ID}-analysis.md"
    
    {
        echo "# Edge Case Test Analysis"
        echo ""
        echo "Generated: $(date)"
        echo "Run ID: $EDGE_CASE_RUN_ID"
        echo ""
        
        echo "## Critical Findings"
        if [[ ${TEST_STATS[critical_failures]} -gt 0 ]]; then
            echo "⚠️ **${TEST_STATS[critical_failures]} critical failures detected**"
            echo ""
            echo "These failures indicate potential security vulnerabilities or system instability."
            echo "Immediate investigation and remediation required."
        else
            echo "✅ No critical failures detected"
        fi
        echo ""
        
        echo "## Category Results"
        for category in "${!EDGE_CASE_CATEGORIES[@]}"; do
            local script_name="${EDGE_CASE_CATEGORIES[$category]}"
            local category_log="${EDGE_CASE_RESULTS_DIR}/${category}-${EDGE_CASE_RUN_ID}.log"
            
            echo "### $category"
            if [[ -f "$category_log" ]]; then
                echo "- Status: $(grep -q "ERROR\|CRITICAL" "$category_log" && echo "❌ Failed" || echo "✅ Passed")"
                echo "- Log: [${category}-${EDGE_CASE_RUN_ID}.log](${category}-${EDGE_CASE_RUN_ID}.log)"
                
                # Extract key findings
                local error_count=$(grep -c "ERROR" "$category_log" 2>/dev/null || echo "0")
                local warning_count=$(grep -c "WARNING" "$category_log" 2>/dev/null || echo "0")
                
                echo "- Errors: $error_count"
                echo "- Warnings: $warning_count"
            else
                echo "- Status: ⏭️ Skipped"
            fi
            echo ""
        done
        
        echo "## Recommendations"
        echo ""
        
        if [[ ${TEST_STATS[failed_tests]} -gt 0 ]]; then
            echo "1. **Review Failed Tests**: Examine logs for failed categories"
            echo "2. **Address Root Causes**: Fix underlying issues before deployment"
            echo "3. **Update Edge Case Coverage**: Add tests for any new edge cases discovered"
        fi
        
        if [[ ${TEST_STATS[critical_failures]} -gt 0 ]]; then
            echo "4. **URGENT**: Address critical failures immediately"
            echo "5. **Security Review**: Conduct thorough security assessment"
        fi
        
        echo ""
        echo "## Test Environment"
        echo "- Platform: $(uname -s) $(uname -r)"
        echo "- Git Version: $(git --version 2>/dev/null || echo 'Not available')"
        echo "- Test Framework: Claude Flow Edge Case Testing"
        echo "- Configuration: [edge-case-config.yaml](../config/edge-case-config.yaml)"
        
    } > "$analysis_file"
    
    print_info "Edge case analysis saved to: $analysis_file"
}

# Main execution function
main() {
    local categories_to_run=("${!EDGE_CASE_CATEGORIES[@]}")
    local force_run=false
    local verbose=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --category|-c)
                if [[ -n "${2:-}" && "${EDGE_CASE_CATEGORIES[$2]:-}" ]]; then
                    categories_to_run=("$2")
                    shift 2
                else
                    print_error "Invalid category: ${2:-}. Available: ${!EDGE_CASE_CATEGORIES[*]}"
                    exit 1
                fi
                ;;
            --force|-f)
                force_run=true
                export FORCE_EDGE_TESTS=true
                shift
                ;;
            --verbose|-v)
                verbose=true
                export DEBUG=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Show startup information
    print_header "Claude Flow Edge Case Testing Framework"
    print_info "Categories to test: ${categories_to_run[*]}"
    print_info "Run ID: ${EDGE_CASE_RUN_ID:-not-set}"
    
    # Initialize environment
    initialize_edge_case_environment
    
    # Run pre-flight checks
    if ! run_preflight_checks; then
        print_error "Pre-flight checks failed"
        exit 1
    fi
    
    # Execute edge case categories
    local overall_success=true
    
    for category in "${categories_to_run[@]}"; do
        print_info "Processing category: $category"
        
        if ! execute_edge_case_category "$category"; then
            overall_success=false
            
            # Stop on critical failures unless forced
            if [[ ${TEST_STATS[critical_failures]} -gt 0 && "$force_run" != "true" ]]; then
                print_error "Critical failure detected, stopping execution"
                break
            fi
        fi
        
        # Brief pause between categories
        sleep 1
    done
    
    # Generate final report
    if ! generate_edge_case_report; then
        overall_success=false
    fi
    
    # Exit with appropriate code
    if [[ "$overall_success" == "true" ]]; then
        print_success "Edge case testing completed successfully"
        exit 0
    else
        print_error "Edge case testing completed with failures"
        exit 1
    fi
}

# Show usage information
show_usage() {
    cat << EOF
Claude Flow Edge Case Testing Framework

Usage: $0 [OPTIONS]

OPTIONS:
    -c, --category CATEGORY    Run specific category only
                              Available: ${!EDGE_CASE_CATEGORIES[*]}
    -f, --force               Force execution even if checks fail
    -v, --verbose             Enable verbose debug output
    -h, --help                Show this help message

EXAMPLES:
    $0                        # Run all edge case categories
    $0 -c git_state          # Run only git state edge cases
    $0 -f -v                 # Force run with verbose output

CATEGORIES:
$(for cat in "${!EDGE_CASE_CATEGORIES[@]}"; do echo "    $cat: ${EDGE_CASE_CATEGORIES[$cat]}"; done)

EOF
}

# Export functions for use by edge case scripts
export -f print_header print_success print_error print_warning print_info print_debug
export -f record_test_timing record_test_error record_test_warning

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi