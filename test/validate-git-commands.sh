#!/bin/bash

# Phase 1 Static Validation Framework for Claude Flow Git Commands
# Comprehensive validation of command structure, security, and compliance

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
readonly NC='\033[0m'

# Global variables
readonly SCRIPT_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && builtin pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly LIB_DIR="${SCRIPT_DIR}/lib"
readonly SCHEMAS_DIR="${SCRIPT_DIR}/schemas"
readonly COMMANDS_DIR="${SCRIPT_DIR}/../templates/commands"

# Validation results
TOTAL_VALIDATION_FAILURES=0
TOTAL_SECURITY_FAILURES=0
START_TIME=$(date +%s)

# Exit handler for cleanup
cleanup_on_exit() {
    local exit_code=${1:-$?}
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    echo -e "\n${BLUE}=== Validation Complete ===${NC}"
    echo -e "${BLUE}Duration: ${duration}s${NC}"
    
    if [[ ${exit_code} -ne 0 ]]; then
        print_error "Validation failed with exit code ${exit_code}"
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
    [[ -n "${message}" ]] && echo -e "${YELLOW}ℹ ${message}${NC}"
}

print_error() {
    local message="${1:-}"
    [[ -n "${message}" ]] && echo -e "${RED}✗ ${message}${NC}" >&2
}

print_warning() {
    local message="${1:-}"
    [[ -n "${message}" ]] && echo -e "${YELLOW}⚠ ${message}${NC}" >&2
}

# Validate environment and dependencies
validate_environment() {
    print_header "Environment Validation"
    
    # Check required directories
    local required_dirs=("$LIB_DIR" "$SCHEMAS_DIR" "$COMMANDS_DIR")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            print_error "Required directory not found: $dir"
            return 1
        fi
    done
    
    # Check required files
    local required_files=(
        "$LIB_DIR/command-validator.sh"
        "$LIB_DIR/security-validator.sh"
        "$SCHEMAS_DIR/command-schema.yaml"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file not found: $file"
            return 1
        fi
        
        # Make scripts executable
        if [[ "$file" == *.sh ]]; then
            chmod +x "$file"
        fi
    done
    
    # Source validation libraries
    if ! source "$LIB_DIR/command-validator.sh"; then
        print_error "Failed to source command validator library"
        return 1
    fi
    
    if ! source "$LIB_DIR/security-validator.sh"; then
        print_error "Failed to source security validator library"
        return 1
    fi
    
    print_success "Environment validation passed"
    return 0
}

# Validate schema file
validate_schema_file() {
    print_header "Schema Validation"
    
    local schema_file="$SCHEMAS_DIR/command-schema.yaml"
    
    if [[ ! -f "$schema_file" ]]; then
        print_error "Schema file not found: $schema_file"
        return 1
    fi
    
    # Basic YAML syntax check
    if command -v python3 >/dev/null 2>&1; then
        if python3 -c "import yaml; yaml.safe_load(open('$schema_file'))" 2>/dev/null; then
            print_success "Schema file has valid YAML syntax"
        else
            print_warning "Schema file may have syntax issues (Python YAML validation failed)"
        fi
    else
        print_warning "Python3 or YAML library not available - skipping schema syntax validation"
    fi
    
    # Check required schema fields
    if grep -q 'required:' "$schema_file" && grep -q 'properties:' "$schema_file"; then
        print_success "Schema file has required structure"
    else
        print_error "Schema file missing required structure"
        return 1
    fi
    
    return 0
}

# Discover and count command files
discover_command_files() {
    local commands_dir="$1"
    local -a git_commands=()
    local -a all_commands=()
    
    print_header "Command Discovery"
    
    # Find git-specific commands
    if [[ -d "$commands_dir/git" ]]; then
        while IFS= read -r -d '' file; do
            git_commands+=("$file")
        done < <(find "$commands_dir/git" -name "*.md" -print0)
    fi
    
    # Find all commands
    while IFS= read -r -d '' file; do
        all_commands+=("$file")
    done < <(find "$commands_dir" -name "*.md" -print0)
    
    print_info "Found ${#git_commands[@]} git-specific commands"
    print_info "Found ${#all_commands[@]} total commands"
    
    # Export for use by validation functions
    export DISCOVERED_GIT_COMMANDS="${git_commands[*]}"
    export DISCOVERED_ALL_COMMANDS="${all_commands[*]}"
    
    return 0
}

# Run core structural validation
run_structural_validation() {
    print_header "Structural Validation"
    
    local commands_dir="$1"
    local validation_result=0
    
    # Validate all commands using the imported function
    if ! validate_all_commands "$commands_dir"; then
        validation_result=1
        ((TOTAL_VALIDATION_FAILURES++)) || true
    fi
    
    return $validation_result
}

# Run security validation
run_security_validation() {
    print_header "Security Validation"
    
    local commands_dir="$1"
    local security_result=0
    
    # Run security validation using the imported function
    if ! validate_all_command_security "$commands_dir"; then
        security_result=$?
        ((TOTAL_SECURITY_FAILURES++)) || true
    fi
    
    return $security_result
}

# Run git-specific validation
run_git_specific_validation() {
    print_header "Git-Specific Validation"
    
    local commands_dir="$1"
    local git_dir="$commands_dir/git"
    
    if [[ ! -d "$git_dir" ]]; then
        print_warning "Git commands directory not found: $git_dir"
        return 0
    fi
    
    # Check for required git commands
    local required_git_commands=("commit.md" "branch.md" "push.md" "status.md")
    local missing_commands=()
    
    for cmd in "${required_git_commands[@]}"; do
        if [[ ! -f "$git_dir/$cmd" ]]; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        print_error "Missing required git commands: ${missing_commands[*]}"
        return 1
    fi
    
    # Check for _shared directory
    if [[ -d "$git_dir/_shared" ]]; then
        print_success "Git shared resources directory found"
        
        # Validate shared resources
        while IFS= read -r -d '' shared_file; do
            validate_command_file "$shared_file" "$commands_dir"
        done < <(find "$git_dir/_shared" -name "*.md" -print0)
    else
        print_warning "Git shared resources directory not found"
    fi
    
    # Check for workflow commands
    if [[ -d "$git_dir/workflows" ]]; then
        print_success "Git workflows directory found"
    else
        print_warning "Git workflows directory not found"
    fi
    
    return 0
}

# Run cross-reference validation
run_cross_reference_validation() {
    print_header "Cross-Reference Validation"
    
    local commands_dir="$1"
    
    print_info "Validating command cross-references..."
    
    # This is handled by the detect_circular_dependencies function
    # which is already called in validate_all_commands
    
    print_success "Cross-reference validation completed"
    return 0
}

# Generate comprehensive report
generate_validation_report() {
    local commands_dir="$1"
    local total_commands
    total_commands=$(find "$commands_dir" -name "*.md" | wc -l)
    
    print_header "Validation Report"
    
    echo -e "${BLUE}📊 Summary Statistics${NC}"
    echo -e "Total Commands Analyzed: $total_commands"
    echo -e "Structural Validation Failures: $TOTAL_VALIDATION_FAILURES"
    echo -e "Security Validation Failures: $TOTAL_SECURITY_FAILURES"
    
    # Get validation results from the imported functions
    echo -e "\n${BLUE}📋 Detailed Results${NC}"
    echo -e "Validation Errors: ${VALIDATION_ERRORS:-0}"
    echo -e "Validation Warnings: ${VALIDATION_WARNINGS:-0}"
    echo -e "Security Critical: ${SECURITY_CRITICAL_COUNT:-0}"
    echo -e "Security High: ${SECURITY_HIGH_COUNT:-0}"
    echo -e "Security Medium: ${SECURITY_MEDIUM_COUNT:-0}"
    echo -e "Security Low: ${SECURITY_LOW_COUNT:-0}"
    
    # Overall status
    local total_issues=$((TOTAL_VALIDATION_FAILURES + TOTAL_SECURITY_FAILURES))
    local critical_security=$((${SECURITY_CRITICAL_COUNT:-0}))
    
    echo -e "\n${BLUE}🎯 Overall Status${NC}"
    if [[ $critical_security -gt 0 ]]; then
        echo -e "${RED}🚨 CRITICAL: $critical_security critical security issues found${NC}"
        return 2
    elif [[ $total_issues -gt 0 ]]; then
        echo -e "${YELLOW}⚠ WARNING: $total_issues validation issues found${NC}"
        return 1
    else
        echo -e "${GREEN}✅ SUCCESS: All validations passed${NC}"
        return 0
    fi
}

# Test mode for individual files
test_single_file() {
    local file="$1"
    local commands_dir="$2"
    
    print_header "Testing Single File: $(basename "$file")"
    
    if [[ ! -f "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi
    
    # Run all validations on single file
    validate_command_file "$file" "$commands_dir"
    validate_file_security "$file" "$commands_dir"
    
    return 0
}

# Performance benchmark mode
run_performance_benchmark() {
    local commands_dir="$1"
    
    print_header "Performance Benchmark"
    
    local start_time
    start_time=$(date +%s%N)
    
    # Run lightweight validation for benchmarking
    local file_count=0
    while IFS= read -r -d '' file; do
        ((file_count++)) || true
        # Just check if frontmatter exists
        extract_frontmatter "$file" >/dev/null
    done < <(find "$commands_dir" -name "*.md" -print0)
    
    local end_time
    end_time=$(date +%s%N)
    local duration=$(((end_time - start_time) / 1000000)) # Convert to milliseconds
    
    print_info "Processed $file_count files in ${duration}ms"
    print_info "Average: $((duration / file_count))ms per file"
    
    return 0
}

# Help function
show_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] [COMMAND_DIR]

Phase 1 Static Validation Framework for Claude Flow Git Commands

OPTIONS:
    -h, --help              Show this help message
    -f, --file FILE         Validate single file
    -s, --security-only     Run only security validation
    -c, --structural-only   Run only structural validation
    -g, --git-only          Run only git-specific validation
    -p, --performance       Run performance benchmark
    -v, --verbose           Enable verbose output
    --no-color              Disable colored output

COMMAND_DIR:
    Path to commands directory (default: ../templates/commands)

Examples:
    $SCRIPT_NAME                                    # Full validation
    $SCRIPT_NAME -f commit.md                       # Test single file
    $SCRIPT_NAME -s                                 # Security only
    $SCRIPT_NAME -p                                 # Performance test
    $SCRIPT_NAME /path/to/commands                  # Custom directory

Exit Codes:
    0 - All validations passed
    1 - Validation warnings/errors found
    2 - Critical security issues found
EOF
}

# Main execution function
main() {
    local commands_dir="$COMMANDS_DIR"
    local single_file=""
    local security_only=false
    local structural_only=false
    local git_only=false
    local performance_mode=false
    local verbose=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                return 0
                ;;
            -f|--file)
                single_file="$2"
                shift 2
                ;;
            -s|--security-only)
                security_only=true
                shift
                ;;
            -c|--structural-only)
                structural_only=true
                shift
                ;;
            -g|--git-only)
                git_only=true
                shift
                ;;
            -p|--performance)
                performance_mode=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --no-color)
                # Disable colors by unsetting color variables
                GREEN=''
                YELLOW=''
                BLUE=''
                RED=''
                NC=''
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                show_help
                return 1
                ;;
            *)
                commands_dir="$1"
                shift
                ;;
        esac
    done
    
    # Banner
    echo "Claude Flow Command Validation Framework"
    echo "========================================"
    
    # Validate environment first
    if ! validate_environment; then
        print_error "Environment validation failed"
        return 1
    fi
    
    # Validate schema (warnings don't fail the validation)
    validate_schema_file
    
    # Performance mode
    if [[ "$performance_mode" == true ]]; then
        run_performance_benchmark "$commands_dir"
        return $?
    fi
    
    # Single file mode
    if [[ -n "$single_file" ]]; then
        test_single_file "$single_file" "$commands_dir"
        return $?
    fi
    
    # Discover commands
    discover_command_files "$commands_dir"
    
    local overall_result=0
    
    # Run selected validations
    if [[ "$security_only" == true ]]; then
        run_security_validation "$commands_dir"
        overall_result=$?
    elif [[ "$structural_only" == true ]]; then
        run_structural_validation "$commands_dir"
        overall_result=$?
    elif [[ "$git_only" == true ]]; then
        run_git_specific_validation "$commands_dir"
        overall_result=$?
    else
        # Full validation suite
        if ! run_structural_validation "$commands_dir"; then
            overall_result=1
        fi
        
        if ! run_security_validation "$commands_dir"; then
            local security_exit=$?
            if [[ $security_exit -gt $overall_result ]]; then
                overall_result=$security_exit
            fi
        fi
        
        if ! run_git_specific_validation "$commands_dir"; then
            overall_result=1
        fi
        
        run_cross_reference_validation "$commands_dir"
    fi
    
    # Generate report
    generate_validation_report "$commands_dir"
    local report_result=$?
    
    if [[ $report_result -gt $overall_result ]]; then
        overall_result=$report_result
    fi
    
    return $overall_result
}

# Run main function only if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi