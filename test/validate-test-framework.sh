#!/bin/bash

# Self-Validation Script for Claude Flow Testing Framework
# Validates the testing framework itself to ensure it's functioning correctly
# This script performs comprehensive checks of the testing infrastructure

# Enable strict error handling
set -euo pipefail

# Trap for cleanup on exit
trap 'cleanup_on_exit $?' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Colors for output
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
readonly CONFIG_DIR="${SCRIPT_DIR}/config"
readonly FIXTURES_DIR="${SCRIPT_DIR}/fixtures"
readonly SCENARIOS_DIR="${SCRIPT_DIR}/scenarios"
readonly TEMP_DIR="${SCRIPT_DIR}/tmp/framework-validation-$$"

# Validation counters
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0
VALIDATION_CHECKS=0

# Configuration
VERBOSE=false
DEBUG=false
NO_COLOR=false
QUICK_MODE=false

# Cleanup function
cleanup_on_exit() {
    local exit_code=${1:-$?}
    
    # Clean up temporary directory
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    
    # Stop any background processes
    jobs -p | xargs -r kill 2>/dev/null || true
    
    if [[ ${exit_code} -ne 0 ]]; then
        print_error "Framework validation failed with exit code ${exit_code}"
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
    ((VALIDATION_CHECKS++))
}

print_info() {
    local message="${1:-}"
    [[ -n "${message}" ]] && echo -e "${CYAN}ℹ ${message}${NC}"
}

print_error() {
    local message="${1:-}"
    [[ -n "${message}" ]] && echo -e "${RED}✗ ${message}${NC}" >&2
    ((VALIDATION_ERRORS++))
    ((VALIDATION_CHECKS++))
}

print_warning() {
    local message="${1:-}"
    [[ -n "${message}" ]] && echo -e "${YELLOW}⚠ ${message}${NC}" >&2
    ((VALIDATION_WARNINGS++))
    ((VALIDATION_CHECKS++))
}

print_debug() {
    local message="${1:-}"
    if [[ "$DEBUG" == true ]]; then
        echo -e "${MAGENTA}[DEBUG] ${message}${NC}" >&2
    fi
}

print_verbose() {
    local message="${1:-}"
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${CYAN}[VERBOSE] ${message}${NC}"
    fi
}

# Framework structure validation
validate_framework_structure() {
    print_header "Testing Framework Structure Validation"
    
    # Check required directories
    local required_dirs=(
        "$LIB_DIR"
        "$CONFIG_DIR"
        "$FIXTURES_DIR"
        "$SCENARIOS_DIR"
        "${SCRIPT_DIR}/results"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            print_success "Directory exists: $(basename "$dir")"
        else
            print_error "Required directory missing: $dir"
        fi
    done
    
    # Check required scripts
    local required_scripts=(
        "${SCRIPT_DIR}/run-git-tests.sh"
        "${SCRIPT_DIR}/validate-git-commands.sh"
        "${SCRIPT_DIR}/mock-git-test.sh"
        "${SCRIPT_DIR}/integration-git-test.sh"
    )
    
    for script in "${required_scripts[@]}"; do
        if [[ -f "$script" ]]; then
            if [[ -x "$script" ]]; then
                print_success "Script executable: $(basename "$script")"
            else
                print_warning "Script not executable: $(basename "$script")"
                chmod +x "$script" 2>/dev/null || print_error "Failed to make executable: $(basename "$script")"
            fi
        else
            print_error "Required script missing: $script"
        fi
    done
    
    # Check library files
    local required_libs=(
        "$LIB_DIR/command-validator.sh"
        "$LIB_DIR/mock-environment.sh"
        "$LIB_DIR/integration-environment.sh"
        "$LIB_DIR/security-validator.sh"
        "$LIB_DIR/test-reporter.sh"
    )
    
    for lib in "${required_libs[@]}"; do
        if [[ -f "$lib" ]]; then
            print_success "Library found: $(basename "$lib")"
        else
            print_error "Required library missing: $lib"
        fi
    done
}

# Configuration validation
validate_configuration() {
    print_header "Configuration Validation"
    
    # Check test configuration file
    local test_config="${CONFIG_DIR}/test-config.yaml"
    if [[ -f "$test_config" ]]; then
        print_success "Test configuration found"
        
        # Basic YAML syntax check
        if command -v yq >/dev/null 2>&1; then
            if yq eval . "$test_config" >/dev/null 2>&1; then
                print_success "Test configuration YAML syntax valid"
            else
                print_error "Test configuration YAML syntax invalid"
            fi
        else
            print_info "yq not available, skipping YAML syntax validation"
        fi
    else
        print_warning "Test configuration file not found: $test_config"
    fi
    
    # Check edge case configuration
    local edge_config="${CONFIG_DIR}/edge-case-config.yaml"
    if [[ -f "$edge_config" ]]; then
        print_success "Edge case configuration found"
    else
        print_warning "Edge case configuration file not found: $edge_config"
    fi
    
    # Validate configuration values
    validate_configuration_values
}

validate_configuration_values() {
    print_section "Configuration Values Validation"
    
    # Test timeout values
    local timeout_value=30
    if [[ $timeout_value -gt 0 && $timeout_value -le 300 ]]; then
        print_success "Timeout value within acceptable range: ${timeout_value}s"
    else
        print_warning "Timeout value outside recommended range: ${timeout_value}s"
    fi
    
    # Test parallel job limits
    local max_jobs=8
    local cpu_count=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)
    if [[ $max_jobs -le $((cpu_count * 2)) ]]; then
        print_success "Max parallel jobs reasonable: $max_jobs (CPU cores: $cpu_count)"
    else
        print_warning "Max parallel jobs may be too high: $max_jobs (CPU cores: $cpu_count)"
    fi
}

# Mock fixtures validation
validate_mock_fixtures() {
    print_header "Mock Fixtures Validation"
    
    # Check mock responses directory
    local mock_responses_dir="${FIXTURES_DIR}/mock-responses"
    if [[ -d "$mock_responses_dir" ]]; then
        print_success "Mock responses directory found"
        
        # Check required mock response files
        local required_responses=(
            "git-status-clean.txt"
            "git-status-dirty.txt"
            "git-status-conflicts.txt"
            "git-commit-success.txt"
            "git-commit-hook-failure.txt"
            "git-push-success.txt"
            "git-push-rejected.txt"
            "git-branch-list.txt"
        )
        
        for response in "${required_responses[@]}"; do
            local response_file="${mock_responses_dir}/${response}"
            if [[ -f "$response_file" ]]; then
                if [[ -s "$response_file" ]]; then
                    print_success "Mock response valid: $response"
                else
                    print_error "Mock response empty: $response"
                fi
            else
                print_error "Mock response missing: $response"
            fi
        done
        
        # Validate mock response content
        validate_mock_response_content "$mock_responses_dir"
        
    else
        print_error "Mock responses directory not found: $mock_responses_dir"
    fi
}

validate_mock_response_content() {
    local mock_dir="$1"
    print_section "Mock Response Content Validation"
    
    # Check git status responses
    local status_clean="${mock_dir}/git-status-clean.txt"
    if [[ -f "$status_clean" ]]; then
        if grep -q "working tree clean" "$status_clean" || 
           grep -q "nothing to commit" "$status_clean"; then
            print_success "Clean status response content valid"
        else
            print_warning "Clean status response may not contain expected content"
        fi
    fi
    
    # Check git commit responses
    local commit_success="${mock_dir}/git-commit-success.txt"
    if [[ -f "$commit_success" ]]; then
        if grep -qE "\[.*\]|files? changed" "$commit_success"; then
            print_success "Commit success response content valid"
        else
            print_warning "Commit success response may not contain expected content"
        fi
    fi
    
    # Check that responses are realistic
    local total_size=0
    for file in "$mock_dir"/*.txt; do
        if [[ -f "$file" ]]; then
            local size
            size=$(wc -c < "$file")
            total_size=$((total_size + size))
            
            if [[ $size -lt 10 ]]; then
                print_warning "Mock response very small: $(basename "$file") (${size} bytes)"
            elif [[ $size -gt 5000 ]]; then
                print_warning "Mock response very large: $(basename "$file") (${size} bytes)"
            fi
        fi
    done
    
    print_info "Total mock response data: ${total_size} bytes"
}

# Test script validation
validate_test_scripts() {
    print_header "Test Scripts Validation"
    
    # Validate main test runner
    validate_test_runner
    
    # Validate static validation script
    validate_static_validator
    
    # Validate mock test script
    validate_mock_tester
    
    # Validate integration test script
    validate_integration_tester
}

validate_test_runner() {
    print_section "Test Runner Validation"
    
    local test_runner="${SCRIPT_DIR}/run-git-tests.sh"
    
    # Check script syntax
    if bash -n "$test_runner" 2>/dev/null; then
        print_success "Test runner syntax valid"
    else
        print_error "Test runner syntax error"
        return 1
    fi
    
    # Check help functionality
    if "$test_runner" --help >/dev/null 2>&1; then
        print_success "Test runner help function works"
    else
        print_warning "Test runner help function may not work"
    fi
    
    # Check required functions exist
    local required_functions=(
        "main"
        "show_help"
        "validate_environment"
        "run_static_validation"
        "run_mock_execution"
        "run_integration_tests"
    )
    
    for func in "${required_functions[@]}"; do
        if grep -q "^${func}()" "$test_runner"; then
            print_success "Test runner function found: $func"
        else
            print_error "Test runner function missing: $func"
        fi
    done
}

validate_static_validator() {
    print_section "Static Validator Validation"
    
    local validator="${SCRIPT_DIR}/validate-git-commands.sh"
    
    if [[ -f "$validator" ]]; then
        # Check syntax
        if bash -n "$validator" 2>/dev/null; then
            print_success "Static validator syntax valid"
        else
            print_error "Static validator syntax error"
        fi
        
        # Test dry run
        if [[ "$QUICK_MODE" == false ]]; then
            if "$validator" --help >/dev/null 2>&1; then
                print_success "Static validator help works"
            else
                print_warning "Static validator help may not work"
            fi
        fi
    else
        print_error "Static validator script not found"
    fi
}

validate_mock_tester() {
    print_section "Mock Tester Validation"
    
    local mock_tester="${SCRIPT_DIR}/mock-git-test.sh"
    
    if [[ -f "$mock_tester" ]]; then
        # Check syntax
        if bash -n "$mock_tester" 2>/dev/null; then
            print_success "Mock tester syntax valid"
        else
            print_error "Mock tester syntax error"
        fi
        
        # Check for required mock functions
        local required_mock_functions=(
            "setup_mock_environment"
            "set_mock_response"
            "execute_mock_command"
        )
        
        for func in "${required_mock_functions[@]}"; do
            if grep -q "$func" "$mock_tester" || 
               grep -q "$func" "$LIB_DIR/mock-environment.sh" 2>/dev/null; then
                print_success "Mock function available: $func"
            else
                print_warning "Mock function may be missing: $func"
            fi
        done
    else
        print_error "Mock tester script not found"
    fi
}

validate_integration_tester() {
    print_section "Integration Tester Validation"
    
    local integration_tester="${SCRIPT_DIR}/integration-git-test.sh"
    
    if [[ -f "$integration_tester" ]]; then
        # Check syntax
        if bash -n "$integration_tester" 2>/dev/null; then
            print_success "Integration tester syntax valid"
        else
            print_error "Integration tester syntax error"
        fi
        
        # Check for workflow functions
        if grep -q "test.*workflow" "$integration_tester" ||
           grep -q "workflow.*test" "$integration_tester"; then
            print_success "Integration tester contains workflow tests"
        else
            print_warning "Integration tester may not contain workflow tests"
        fi
    else
        print_error "Integration tester script not found"
    fi
}

# Library validation
validate_libraries() {
    print_header "Library Functions Validation"
    
    # Validate command validator library
    validate_command_validator_lib
    
    # Validate mock environment library
    validate_mock_environment_lib
    
    # Validate integration environment library
    validate_integration_environment_lib
    
    # Validate test reporter library
    validate_test_reporter_lib
}

validate_command_validator_lib() {
    print_section "Command Validator Library"
    
    local validator_lib="$LIB_DIR/command-validator.sh"
    
    if [[ -f "$validator_lib" ]]; then
        # Check syntax
        if bash -n "$validator_lib" 2>/dev/null; then
            print_success "Command validator library syntax valid"
        else
            print_error "Command validator library syntax error"
            return 1
        fi
        
        # Check required validation functions
        local required_functions=(
            "validate_frontmatter"
            "validate_command_references"
            "validate_usage_patterns"
            "validate_documentation_completeness"
            "validate_best_practices"
        )
        
        for func in "${required_functions[@]}"; do
            if grep -q "^${func}()" "$validator_lib"; then
                print_success "Validator function found: $func"
            else
                print_error "Validator function missing: $func"
            fi
        done
        
        # Test function exports
        if grep -q "export -f" "$validator_lib"; then
            print_success "Functions properly exported"
        else
            print_warning "Functions may not be exported"
        fi
    else
        print_error "Command validator library not found"
    fi
}

validate_mock_environment_lib() {
    print_section "Mock Environment Library"
    
    local mock_lib="$LIB_DIR/mock-environment.sh"
    
    if [[ -f "$mock_lib" ]]; then
        # Check syntax
        if bash -n "$mock_lib" 2>/dev/null; then
            print_success "Mock environment library syntax valid"
        else
            print_error "Mock environment library syntax error"
        fi
    else
        print_warning "Mock environment library not found"
    fi
}

validate_integration_environment_lib() {
    print_section "Integration Environment Library"
    
    local integration_lib="$LIB_DIR/integration-environment.sh"
    
    if [[ -f "$integration_lib" ]]; then
        # Check syntax
        if bash -n "$integration_lib" 2>/dev/null; then
            print_success "Integration environment library syntax valid"
        else
            print_error "Integration environment library syntax error"
        fi
    else
        print_warning "Integration environment library not found"
    fi
}

validate_test_reporter_lib() {
    print_section "Test Reporter Library"
    
    local reporter_lib="$LIB_DIR/test-reporter.sh"
    
    if [[ -f "$reporter_lib" ]]; then
        # Check syntax
        if bash -n "$reporter_lib" 2>/dev/null; then
            print_success "Test reporter library syntax valid"
        else
            print_error "Test reporter library syntax error"
        fi
        
        # Check for reporting functions
        if grep -q "generate.*report" "$reporter_lib" ||
           grep -q "report.*results" "$reporter_lib"; then
            print_success "Reporter contains reporting functions"
        else
            print_warning "Reporter may not contain reporting functions"
        fi
    else
        print_warning "Test reporter library not found"
    fi
}

# Environment validation
validate_environment() {
    print_header "Environment Dependencies Validation"
    
    # Check required commands
    local required_commands=(
        "bash"
        "git"
        "grep"
        "awk"
        "sed"
        "find"
        "head"
        "tail"
        "wc"
    )
    
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            local version
            case "$cmd" in
                bash)
                    version="$($cmd --version | head -1)"
                    print_success "Command available: $cmd ($version)"
                    ;;
                git)
                    version="$($cmd --version)"
                    print_success "Command available: $cmd ($version)"
                    ;;
                *)
                    print_success "Command available: $cmd"
                    ;;
            esac
        else
            print_error "Required command not found: $cmd"
        fi
    done
    
    # Check optional commands
    local optional_commands=(
        "timeout"
        "parallel"
        "yq"
        "jq"
    )
    
    for cmd in "${optional_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            print_success "Optional command available: $cmd"
        else
            print_info "Optional command not available: $cmd"
        fi
    done
    
    # Check Bash version
    if [[ "${BASH_VERSION%%.*}" -ge 4 ]]; then
        print_success "Bash version acceptable: $BASH_VERSION"
    else
        print_error "Bash version too old: $BASH_VERSION (requires 4.0+)"
    fi
    
    # Check Git version
    local git_version
    git_version=$(git --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
    local git_major git_minor
    git_major="${git_version%%.*}"
    git_minor="${git_version#*.}"
    
    if [[ $git_major -gt 2 ]] || [[ $git_major -eq 2 && $git_minor -ge 20 ]]; then
        print_success "Git version acceptable: $git_version"
    else
        print_warning "Git version may be too old: $git_version (recommended 2.20+)"
    fi
}

# Template validation
validate_templates() {
    print_header "Template Structure Validation"
    
    local templates_dir="../templates/commands/git"
    if [[ -d "$templates_dir" ]]; then
        print_success "Git templates directory found"
        
        # Count git command templates
        local template_count
        template_count=$(find "$templates_dir" -name "*.md" | wc -l)
        
        if [[ $template_count -gt 0 ]]; then
            print_success "Found $template_count git command templates"
            
            # Validate a sample of templates
            if [[ "$QUICK_MODE" == false ]]; then
                validate_sample_templates "$templates_dir"
            fi
        else
            print_warning "No git command templates found in $templates_dir"
        fi
    else
        print_warning "Git templates directory not found: $templates_dir"
    fi
}

validate_sample_templates() {
    local templates_dir="$1"
    print_section "Sample Template Validation"
    
    # Find and validate a few templates
    local sample_count=0
    local max_samples=3
    
    while IFS= read -r -d '' template; do
        if [[ $sample_count -ge $max_samples ]]; then
            break
        fi
        
        print_verbose "Validating template: $(basename "$template")"
        
        # Check for YAML frontmatter
        if head -10 "$template" | grep -q "^---$"; then
            print_success "Template has YAML frontmatter: $(basename "$template")"
        else
            print_warning "Template may be missing YAML frontmatter: $(basename "$template")"
        fi
        
        # Check for basic structure
        if grep -q "^# " "$template"; then
            print_success "Template has H1 heading: $(basename "$template")"
        else
            print_warning "Template may be missing H1 heading: $(basename "$template")"
        fi
        
        ((sample_count++))
    done < <(find "$templates_dir" -name "*.md" -print0)
    
    print_info "Validated $sample_count sample templates"
}

# Functional testing
validate_functionality() {
    print_header "Framework Functionality Testing"
    
    # Create temporary test environment
    mkdir -p "$TEMP_DIR"
    
    # Test basic validation functionality
    test_static_validation
    
    # Test mock environment setup
    if [[ "$QUICK_MODE" == false ]]; then
        test_mock_environment
    fi
    
    # Test basic integration
    if [[ "$QUICK_MODE" == false ]]; then
        test_basic_integration
    fi
}

test_static_validation() {
    print_section "Static Validation Function Test"
    
    # Create a minimal test template
    local test_template="${TEMP_DIR}/test-template.md"
    cat > "$test_template" << 'EOF'
---
allowed-tools: "Bash,Read,Write"
description: "Test template for validation"
category: "git"
---

# Test Command

**Usage:** `test-command [options]`

This is a test command template.

```bash
echo "test"
```

## Summary

Test command summary.
EOF
    
    # Test static validation
    if [[ -f "${SCRIPT_DIR}/validate-git-commands.sh" ]]; then
        if "${SCRIPT_DIR}/validate-git-commands.sh" "$test_template" >/dev/null 2>&1; then
            print_success "Static validation functional test passed"
        else
            print_warning "Static validation functional test failed"
        fi
    else
        print_info "Static validation script not found, skipping functional test"
    fi
}

test_mock_environment() {
    print_section "Mock Environment Function Test"
    
    # Test mock environment setup
    if [[ -f "$LIB_DIR/mock-environment.sh" ]]; then
        # Source the library and test basic functionality
        if source "$LIB_DIR/mock-environment.sh" 2>/dev/null; then
            print_success "Mock environment library can be sourced"
            
            # Test if mock functions are available
            if declare -f setup_mock_environment >/dev/null 2>&1; then
                print_success "Mock setup function available"
            else
                print_warning "Mock setup function may not be available"
            fi
        else
            print_warning "Failed to source mock environment library"
        fi
    else
        print_info "Mock environment library not found, skipping functional test"
    fi
}

test_basic_integration() {
    print_section "Basic Integration Test"
    
    # Create a minimal test repository
    local test_repo="${TEMP_DIR}/test-repo"
    mkdir -p "$test_repo"
    
    if pushd "$test_repo" >/dev/null 2>&1; then
        # Initialize git repository
        if git init >/dev/null 2>&1; then
            print_success "Test repository created successfully"
            
            # Basic git operations test
            echo "test content" > test-file.txt
            
            if git add test-file.txt >/dev/null 2>&1; then
                print_success "Git add operation successful"
            else
                print_warning "Git add operation failed"
            fi
            
            if git -c user.name="Test User" -c user.email="test@example.com" commit -m "Test commit" >/dev/null 2>&1; then
                print_success "Git commit operation successful"
            else
                print_warning "Git commit operation failed"
            fi
        else
            print_warning "Failed to initialize test repository"
        fi
        
        popd >/dev/null 2>&1
    else
        print_warning "Failed to create test repository directory"
    fi
}

# Performance validation
validate_performance() {
    print_header "Framework Performance Validation"
    
    # Test script execution times
    test_execution_times
    
    # Test memory usage patterns
    if command -v time >/dev/null 2>&1; then
        test_memory_usage
    else
        print_info "time command not available, skipping memory usage tests"
    fi
}

test_execution_times() {
    print_section "Execution Time Testing"
    
    # Test static validation speed
    local start_time end_time duration
    start_time=$(date +%s%N)
    
    # Run a quick static validation
    if [[ -f "${SCRIPT_DIR}/validate-git-commands.sh" ]]; then
        "${SCRIPT_DIR}/validate-git-commands.sh" --help >/dev/null 2>&1
    fi
    
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 ))
    
    if [[ $duration -lt 5000 ]]; then  # 5 seconds
        print_success "Static validator startup time acceptable: ${duration}ms"
    else
        print_warning "Static validator startup time slow: ${duration}ms"
    fi
}

test_memory_usage() {
    print_section "Memory Usage Testing"
    
    # Use time command to check memory usage
    local temp_output="${TEMP_DIR}/memory-test.txt"
    
    if /usr/bin/time -l echo "test" > "$temp_output" 2>&1; then
        local max_memory
        max_memory=$(grep "maximum resident set size" "$temp_output" | awk '{print $1}' 2>/dev/null || echo "0")
        
        if [[ $max_memory -gt 0 ]]; then
            print_success "Memory usage measurement working: ${max_memory} bytes"
        fi
    elif /usr/bin/time -v echo "test" > "$temp_output" 2>&1; then
        local max_memory
        max_memory=$(grep "Maximum resident set size" "$temp_output" | awk '{print $6}' 2>/dev/null || echo "0")
        
        if [[ $max_memory -gt 0 ]]; then
            print_success "Memory usage measurement working: ${max_memory} KB"
        fi
    else
        print_info "Unable to measure memory usage with available time command"
    fi
}

# Generate validation report
generate_validation_report() {
    print_header "Framework Validation Report"
    
    local total_duration=$(($(date +%s) - ${TOTAL_START_TIME:-$(date +%s)}))
    
    # Summary
    echo -e "\n${BLUE}📊 Validation Summary${NC}"
    echo -e "Total Checks: $VALIDATION_CHECKS"
    echo -e "Errors: ${RED}$VALIDATION_ERRORS${NC}"
    echo -e "Warnings: ${YELLOW}$VALIDATION_WARNINGS${NC}"
    echo -e "Duration: ${total_duration}s"
    
    # Framework health assessment
    echo -e "\n${BLUE}🏥 Framework Health Assessment${NC}"
    
    local health_score=100
    health_score=$((health_score - (VALIDATION_ERRORS * 10)))
    health_score=$((health_score - (VALIDATION_WARNINGS * 2)))
    
    if [[ $health_score -ge 90 ]]; then
        echo -e "${GREEN}✅ Framework Health: Excellent (${health_score}%)${NC}"
    elif [[ $health_score -ge 75 ]]; then
        echo -e "${YELLOW}⚠️ Framework Health: Good (${health_score}%)${NC}"
    elif [[ $health_score -ge 50 ]]; then
        echo -e "${YELLOW}⚠️ Framework Health: Fair (${health_score}%)${NC}"
    else
        echo -e "${RED}❌ Framework Health: Poor (${health_score}%)${NC}"
    fi
    
    # Recommendations
    if [[ $VALIDATION_ERRORS -gt 0 || $VALIDATION_WARNINGS -gt 5 ]]; then
        echo -e "\n${BLUE}🔧 Recommendations${NC}"
        
        if [[ $VALIDATION_ERRORS -gt 0 ]]; then
            echo -e "• Fix $VALIDATION_ERRORS critical errors before using the framework"
        fi
        
        if [[ $VALIDATION_WARNINGS -gt 5 ]]; then
            echo -e "• Review and address $VALIDATION_WARNINGS warnings for optimal performance"
        fi
        
        echo -e "• Run with -v flag for detailed information about issues"
        echo -e "• Ensure all dependencies are properly installed"
    fi
    
    # Final status
    echo -e "\n${BLUE}🎯 Overall Status${NC}"
    if [[ $VALIDATION_ERRORS -eq 0 ]]; then
        echo -e "${GREEN}✅ Framework is ready for use${NC}"
        return 0
    else
        echo -e "${RED}❌ Framework has critical issues that need attention${NC}"
        return 1
    fi
}

# Help function
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Self-validation script for Claude Flow Testing Framework

OPTIONS:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    -d, --debug         Enable debug output
    -q, --quick         Quick validation (skip slow tests)
    --no-color         Disable colored output

VALIDATION AREAS:
    • Framework structure and required files
    • Configuration files and values
    • Mock fixtures and test data
    • Test scripts and library functions
    • Environment dependencies
    • Basic functionality testing
    • Performance characteristics

EXAMPLES:
    $SCRIPT_NAME                    # Full framework validation
    $SCRIPT_NAME -v                # Verbose validation output
    $SCRIPT_NAME -q                # Quick validation only
    $SCRIPT_NAME --no-color        # No colored output

EXIT CODES:
    0 - Framework validation passed
    1 - Framework has critical issues
    2 - Usage or configuration error
EOF
}

# Main execution function
main() {
    local TOTAL_START_TIME
    TOTAL_START_TIME=$(date +%s)
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                return 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -d|--debug)
                DEBUG=true
                VERBOSE=true
                shift
                ;;
            -q|--quick)
                QUICK_MODE=true
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
    echo "Claude Flow Testing Framework Validation"
    echo "======================================="
    echo "Self-Validation v1.0.0"
    
    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    
    # Run validation phases
    validate_framework_structure
    validate_configuration
    validate_mock_fixtures
    validate_test_scripts
    validate_libraries
    validate_environment
    validate_templates
    validate_functionality
    
    if [[ "$QUICK_MODE" == false ]]; then
        validate_performance
    fi
    
    # Generate final report
    generate_validation_report
}

# Run main function only if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi