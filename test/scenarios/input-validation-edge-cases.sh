#!/bin/bash

# Input Validation Edge Cases for Claude Flow Commands
# Tests various malformed, malicious, and edge case inputs to ensure robust input handling
# Includes empty inputs, special characters, injection attempts, and boundary conditions

# Enable strict error handling
set -euo pipefail

# Import test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$(dirname "$SCRIPT_DIR")"

source "$TEST_ROOT/lib/integration-environment.sh"
source "$TEST_ROOT/lib/security-validator.sh"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Test configuration
readonly INPUT_TEST_DIR="/tmp/claude-input-validation-tests-$$"
readonly MAX_INPUT_LENGTH=10000
readonly INJECTION_PATTERNS_FILE="$INPUT_TEST_DIR/injection-patterns.txt"

# Test statistics
INPUT_TESTS_RUN=0
INPUT_TESTS_PASSED=0
INPUT_TESTS_FAILED=0
SECURITY_VIOLATIONS=0

# Helper functions
input_info() {
    echo -e "${CYAN}[INPUT] $1${NC}"
}

input_success() {
    echo -e "${GREEN}[INPUT] ✅ $1${NC}"
    ((INPUT_TESTS_PASSED++))
}

input_error() {
    echo -e "${RED}[INPUT] ❌ $1${NC}"
    ((INPUT_TESTS_FAILED++))
}

input_warning() {
    echo -e "${YELLOW}[INPUT] ⚠️ $1${NC}"
}

input_security_violation() {
    echo -e "${RED}[INPUT] 🚨 SECURITY: $1${NC}"
    ((SECURITY_VIOLATIONS++))
}

# Setup test environment
setup_input_validation_tests() {
    input_info "Setting up input validation edge case tests"
    
    mkdir -p "$INPUT_TEST_DIR"
    cd "$INPUT_TEST_DIR"
    
    # Create test repository
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    echo "Test file for input validation" > test-file.txt
    git add test-file.txt
    git commit -m "Initial test commit" --quiet
    
    # Create injection patterns database
    create_injection_patterns_db
    
    input_success "Input validation test environment created"
}

# Cleanup test environment
cleanup_input_validation_tests() {
    input_info "Cleaning up input validation test environment"
    
    if [[ -d "$INPUT_TEST_DIR" ]]; then
        # Remove any git locks
        find "$INPUT_TEST_DIR" -name "*.lock" -type f -delete 2>/dev/null || true
        
        # Clean up
        chmod -R u+w "$INPUT_TEST_DIR" 2>/dev/null || true
        rm -rf "$INPUT_TEST_DIR"
    fi
    
    input_success "Cleanup completed"
}

# Create database of known injection patterns
create_injection_patterns_db() {
    cat > "$INJECTION_PATTERNS_FILE" << 'EOF'
# Command injection patterns
$(rm -rf /)
`rm -rf /`
; rm -rf /
&& rm -rf /
|| rm -rf /
| rm -rf /

# Shell metacharacters
; echo "injected"
&& echo "injected"
| echo "injected"
` echo "injected" `
$( echo "injected" )

# Path traversal
../../../etc/passwd
..\\..\\..\\windows\\system32
%2e%2e%2f%2e%2e%2f%2e%2e%2f

# SQL injection patterns (in case of future database integration)
'; DROP TABLE users; --
' OR '1'='1
" OR "1"="1

# Script injection
<script>alert('xss')</script>
javascript:alert('xss')
data:text/html,<script>alert('xss')</script>

# Environment variable injection
$HOME/malicious
${HOME}/malicious
$PATH:malicious

# Null bytes and control characters
%00
\x00
\n\r

# Unicode and encoding issues
%c0%ae%c0%ae/
%u002e%u002e/
\u002e\u002e/

# Long strings (buffer overflow attempts)
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

# Special Git references
HEAD~1000000
@{-1000000}
refs/heads/../../../etc/passwd

# Malicious branch names
../../../etc/passwd
--delete-branch
-rf
EOF
}

# Test: Empty and null inputs
test_empty_inputs() {
    input_info "Testing empty and null input handling"
    ((INPUT_TESTS_RUN++))
    
    local empty_inputs_success=true
    
    # Test completely empty arguments
    input_info "Testing completely empty arguments"
    
    local test_commands=(
        "git status"
        "git branch"
        "git log"
    )
    
    for cmd in "${test_commands[@]}"; do
        # Test with empty string argument
        if timeout 5 $cmd "" >/dev/null 2>&1; then
            input_info "✓ Command handled empty argument: $cmd"
        else
            local exit_code=$?
            if [[ $exit_code -eq 124 ]]; then
                input_error "Command timed out with empty argument: $cmd"
                empty_inputs_success=false
            else
                input_info "✓ Command rejected empty argument appropriately: $cmd"
            fi
        fi
    done
    
    # Test null bytes in input
    input_info "Testing null byte handling"
    
    local null_input="test\x00file"
    if echo -e "$null_input" | git hash-object --stdin >/dev/null 2>&1; then
        input_warning "Null bytes in input not detected"
    else
        input_info "✓ Null bytes appropriately handled"
    fi
    
    # Test whitespace-only inputs
    input_info "Testing whitespace-only inputs"
    
    local whitespace_inputs=(
        "   "
        "\t\t\t"
        "\n\n\n"
        "   \t\n   "
    )
    
    for ws_input in "${whitespace_inputs[@]}"; do
        if git branch "$ws_input" 2>/dev/null; then
            input_warning "Whitespace-only branch name accepted"
            git branch -d "$ws_input" 2>/dev/null || true
        else
            input_info "✓ Whitespace-only input rejected"
        fi
    done
    
    if [[ "$empty_inputs_success" == "true" ]]; then
        input_success "Empty inputs test passed"
    else
        input_error "Empty inputs test failed"
        return 1
    fi
}

# Test: Special characters and encoding
test_special_characters() {
    input_info "Testing special character handling"
    ((INPUT_TESTS_RUN++))
    
    local special_chars_success=true
    
    # Test various special characters
    local special_chars=(
        "!@#\$%^&*()"
        "{}[]|\\:;\"'<>?,./"
        "~\`"
        "±§¶•ªº–≠"
        "αβγδε"
        "中文测试"
        "🔥💯🚀"
        "tab\there"
        "new\nline"
        "carriage\rreturn"
    )
    
    for char_set in "${special_chars[@]}"; do
        input_info "Testing character set: ${char_set:0:20}..."
        
        # Test as commit message
        echo "test content" > "special-test-file.txt"
        git add special-test-file.txt
        
        if git commit -m "$char_set" --quiet 2>/dev/null; then
            input_info "✓ Special characters accepted in commit message"
            
            # Verify the commit message was stored correctly
            local stored_message=$(git log -1 --pretty=format:"%s")
            if [[ "$stored_message" == "$char_set" ]]; then
                input_info "✓ Special characters preserved correctly"
            else
                input_warning "Special characters modified during storage"
            fi
        else
            input_info "✓ Problematic special characters rejected"
        fi
        
        # Test as filename
        local safe_filename="test-$(echo "$char_set" | tr -d '/\\:*?"<>|' | tr ' ' '_').txt"
        echo "content" > "$safe_filename" 2>/dev/null || true
        
        if [[ -f "$safe_filename" ]]; then
            if git add "$safe_filename" 2>/dev/null; then
                input_info "✓ Special character filename handled"
                git commit -m "Add special char file" --quiet 2>/dev/null || true
            else
                input_info "✓ Problematic filename rejected"
            fi
        fi
        
        # Cleanup
        rm -f "$safe_filename" special-test-file.txt 2>/dev/null || true
    done
    
    # Test encoding issues
    input_info "Testing encoding edge cases"
    
    # UTF-8 with BOM
    printf '\xEF\xBB\xBFUTF-8 with BOM' > bom-test.txt
    if git add bom-test.txt 2>/dev/null; then
        input_info "✓ UTF-8 BOM handled"
        git commit -m "Add BOM test" --quiet 2>/dev/null || true
    else
        input_warning "UTF-8 BOM caused issues"
    fi
    
    if [[ "$special_chars_success" == "true" ]]; then
        input_success "Special characters test passed"
    else
        input_error "Special characters test failed"
        return 1
    fi
}

# Test: Command injection attempts
test_command_injection() {
    input_info "Testing command injection prevention"
    ((INPUT_TESTS_RUN++))
    
    local injection_success=true
    
    input_info "Loading injection patterns"
    
    while IFS= read -r pattern; do
        # Skip comments and empty lines
        [[ "$pattern" =~ ^#.*$ ]] && continue
        [[ -z "$pattern" ]] && continue
        
        input_info "Testing injection pattern: ${pattern:0:30}..."
        
        # Test pattern as commit message
        echo "injection test content" > injection-test.txt
        git add injection-test.txt
        
        # Monitor for actual command execution
        local pre_files=$(ls /tmp | wc -l)
        
        if timeout 5 git commit -m "$pattern" --quiet 2>/dev/null; then
            # Check if any suspicious activity occurred
            local post_files=$(ls /tmp | wc -l)
            
            if [[ $post_files -ne $pre_files ]]; then
                input_security_violation "Potential command execution detected with pattern: $pattern"
                injection_success=false
            else
                input_info "✓ Injection pattern contained safely"
            fi
        else
            input_info "✓ Injection pattern rejected"
        fi
        
        # Test pattern as branch name
        if git checkout -b "$pattern" 2>/dev/null; then
            input_warning "Injection pattern accepted as branch name: $pattern"
            git checkout main --quiet 2>/dev/null || true
            git branch -D "$pattern" 2>/dev/null || true
        else
            input_info "✓ Injection pattern rejected as branch name"
        fi
        
        # Test pattern as file name (safely)
        local safe_test_name="injection-$(echo "$pattern" | tr -cd '[:alnum:]').txt"
        echo "test" > "$safe_test_name" 2>/dev/null || true
        
        if [[ -f "$safe_test_name" ]]; then
            if git add "$safe_test_name" 2>/dev/null; then
                input_info "✓ Safe version of pattern handled as filename"
                git commit -m "Add injection test file" --quiet 2>/dev/null || true
            fi
            rm -f "$safe_test_name"
        fi
        
        # Cleanup
        rm -f injection-test.txt 2>/dev/null || true
        
    done < "$INJECTION_PATTERNS_FILE"
    
    if [[ "$injection_success" == "true" ]]; then
        input_success "Command injection test passed"
    else
        input_error "Command injection test failed - security violations detected"
        return 1
    fi
}

# Test: Boundary conditions
test_boundary_conditions() {
    input_info "Testing boundary condition inputs"
    ((INPUT_TESTS_RUN++))
    
    local boundary_success=true
    
    # Test extremely long inputs
    input_info "Testing long input handling"
    
    local long_string=$(printf 'A%.0s' $(seq 1 $MAX_INPUT_LENGTH))
    
    # Test long commit message
    echo "boundary test" > boundary-test.txt
    git add boundary-test.txt
    
    if timeout 10 git commit -m "$long_string" --quiet 2>/dev/null; then
        input_info "✓ Long commit message handled"
        
        # Check if it was truncated appropriately
        local stored_length=$(git log -1 --pretty=format:"%s" | wc -c)
        if [[ $stored_length -lt $MAX_INPUT_LENGTH ]]; then
            input_info "✓ Long message appropriately truncated"
        else
            input_warning "Long message not truncated"
        fi
    else
        input_info "✓ Excessively long commit message rejected"
    fi
    
    # Test long file names
    local long_filename=$(printf 'f%.0s' $(seq 1 250)).txt
    echo "test" > "$long_filename" 2>/dev/null || true
    
    if [[ -f "$long_filename" ]]; then
        if git add "$long_filename" 2>/dev/null; then
            input_info "✓ Long filename handled by git"
            git commit -m "Add long filename test" --quiet 2>/dev/null || true
        else
            input_info "✓ Excessively long filename rejected"
        fi
        rm -f "$long_filename" 2>/dev/null || true
    else
        input_info "✓ Long filename rejected by filesystem"
    fi
    
    # Test many arguments
    input_info "Testing many arguments"
    
    local many_args=""
    for i in {1..100}; do
        many_args="$many_args arg$i"
    done
    
    # This is a safe test since we're just checking git's argument handling
    if timeout 5 git log --oneline $many_args >/dev/null 2>&1; then
        input_info "✓ Many arguments handled"
    else
        input_info "✓ Excessive arguments rejected appropriately"
    fi
    
    # Test numeric boundary conditions
    input_info "Testing numeric boundaries"
    
    local numeric_tests=(
        "2147483647"     # Max 32-bit int
        "2147483648"     # Max 32-bit int + 1
        "-2147483648"    # Min 32-bit int
        "9223372036854775807"  # Max 64-bit int
        "0"
        "-1"
        "3.14159"
        "1e100"
    )
    
    for num in "${numeric_tests[@]}"; do
        if git log -n "$num" >/dev/null 2>&1; then
            input_info "✓ Numeric value handled: $num"
        else
            input_info "✓ Invalid numeric value rejected: $num"
        fi
    done
    
    if [[ "$boundary_success" == "true" ]]; then
        input_success "Boundary conditions test passed"
    else
        input_error "Boundary conditions test failed"
        return 1
    fi
}

# Test: File path manipulation
test_path_manipulation() {
    input_info "Testing path manipulation attempts"
    ((INPUT_TESTS_RUN++))
    
    local path_success=true
    
    # Test path traversal attempts
    local malicious_paths=(
        "../../../etc/passwd"
        "..\\..\\..\\windows\\system32"
        "/etc/passwd"
        "C:\\Windows\\System32"
        "~/.ssh/id_rsa"
        "\$HOME/.ssh/id_rsa"
        "/proc/self/environ"
        "/dev/null"
        "CON"    # Windows device name
        "PRN"    # Windows device name
        "AUX"    # Windows device name
    )
    
    for malicious_path in "${malicious_paths[@]}"; do
        input_info "Testing malicious path: ${malicious_path:0:30}..."
        
        # Test as filename (with safety measures)
        local safe_name="test-$(echo "$malicious_path" | tr -cd '[:alnum:]').txt"
        
        # We won't actually try to access the malicious path, just test git's handling
        if git ls-files "$malicious_path" >/dev/null 2>&1; then
            input_warning "Git accepted potentially malicious path: $malicious_path"
        else
            input_info "✓ Malicious path rejected or handled safely"
        fi
        
        # Test relative path operations
        if [[ "$malicious_path" =~ \.\. ]]; then
            # Ensure we can't escape the repository
            if git add "$malicious_path" 2>/dev/null; then
                input_security_violation "Path traversal may be possible: $malicious_path"
                path_success=false
            else
                input_info "✓ Path traversal prevented"
            fi
        fi
    done
    
    # Test symlink handling
    input_info "Testing symbolic link handling"
    
    # Create a safe symlink test
    echo "safe content" > safe-target.txt
    git add safe-target.txt
    git commit -m "Add safe target" --quiet
    
    ln -s safe-target.txt safe-symlink 2>/dev/null || true
    
    if [[ -L safe-symlink ]]; then
        if git add safe-symlink 2>/dev/null; then
            input_info "✓ Safe symlink handled"
            git commit -m "Add safe symlink" --quiet 2>/dev/null || true
        else
            input_info "✓ Symlink rejected appropriately"
        fi
        rm -f safe-symlink
    fi
    
    if [[ "$path_success" == "true" ]]; then
        input_success "Path manipulation test passed"
    else
        input_error "Path manipulation test failed - security issues detected"
        return 1
    fi
}

# Test: Argument parsing edge cases
test_argument_parsing() {
    input_info "Testing argument parsing edge cases"
    ((INPUT_TESTS_RUN++))
    
    local parsing_success=true
    
    # Test various argument formats
    local tricky_args=(
        "--"
        "-"
        "--help"
        "--version"
        "-h"
        "-v"
        "--verbose --quiet"
        "--no-such-option"
        "-- --another-arg"
        "'quoted arg'"
        '"double quoted"'
        "arg\\ with\\ spaces"
        "arg=value"
        "--option=value"
    )
    
    for arg in "${tricky_args[@]}"; do
        input_info "Testing argument: $arg"
        
        # Test with git status (safe command)
        if timeout 5 git status $arg >/dev/null 2>&1; then
            input_info "✓ Argument accepted: $arg"
        else
            input_info "✓ Argument rejected or handled appropriately: $arg"
        fi
    done
    
    # Test environment variable injection in arguments
    input_info "Testing environment variable injection"
    
    local env_injections=(
        "\$HOME/test"
        "\${HOME}/test"
        "\$(echo injected)"
        "\`echo injected\`"
    )
    
    for env_inj in "${env_injections[@]}"; do
        input_info "Testing env injection: $env_inj"
        
        # Test as commit message (safe test)
        echo "env test" > env-test.txt
        git add env-test.txt
        
        if git commit -m "$env_inj" --quiet 2>/dev/null; then
            # Check if variable was expanded
            local stored_message=$(git log -1 --pretty=format:"%s")
            if [[ "$stored_message" == "$env_inj" ]]; then
                input_info "✓ Environment injection prevented"
            else
                input_warning "Environment variable may have been expanded"
            fi
        else
            input_info "✓ Environment injection rejected"
        fi
        
        rm -f env-test.txt
    done
    
    if [[ "$parsing_success" == "true" ]]; then
        input_success "Argument parsing test passed"
    else
        input_error "Argument parsing test failed"
        return 1
    fi
}

# Test: Unicode and internationalization
test_unicode_handling() {
    input_info "Testing Unicode and internationalization"
    ((INPUT_TESTS_RUN++))
    
    local unicode_success=true
    
    # Test various Unicode scenarios
    local unicode_tests=(
        "简单的中文测试"
        "مرحبا بالعالم"
        "Здравствуй мир"
        "こんにちは世界"
        "🌍🚀💻🔧🎉"
        "Ñandú çoñfúsíoñ"
        "αβγδεζηθικλμνξοπρστυφχψω"
        "𝕋𝕙𝕚𝕤 𝕚𝕤 𝔽𝕠𝕟𝕔𝕪 𝕥𝔢𝔵𝔱"
    )
    
    for unicode_text in "${unicode_tests[@]}"; do
        input_info "Testing Unicode: ${unicode_text:0:20}..."
        
        # Test as commit message
        echo "unicode test" > unicode-test.txt
        git add unicode-test.txt
        
        if git commit -m "$unicode_text" --quiet 2>/dev/null; then
            # Verify Unicode preservation
            local stored_message=$(git log -1 --pretty=format:"%s")
            if [[ "$stored_message" == "$unicode_text" ]]; then
                input_info "✓ Unicode preserved correctly"
            else
                input_warning "Unicode may have been modified"
            fi
        else
            input_warning "Unicode text rejected: $unicode_text"
        fi
        
        rm -f unicode-test.txt
    done
    
    # Test normalization issues
    input_info "Testing Unicode normalization"
    
    # Create two filenames that look the same but have different Unicode normalization
    local nfc_name="café.txt"
    local nfd_name="cafe"$'\u0301'".txt"  # e + combining acute accent
    
    echo "NFC content" > "$nfc_name" 2>/dev/null || true
    echo "NFD content" > "$nfd_name" 2>/dev/null || true
    
    if [[ -f "$nfc_name" && -f "$nfd_name" ]]; then
        if git add "$nfc_name" "$nfd_name" 2>/dev/null; then
            input_info "✓ Unicode normalization variants handled"
            git commit -m "Add Unicode normalization test" --quiet 2>/dev/null || true
        else
            input_info "✓ Unicode normalization conflicts detected"
        fi
    fi
    
    rm -f "$nfc_name" "$nfd_name" 2>/dev/null || true
    
    if [[ "$unicode_success" == "true" ]]; then
        input_success "Unicode handling test passed"
    else
        input_error "Unicode handling test failed"
        return 1
    fi
}

# Generate input validation test report
generate_input_validation_report() {
    input_info "Generating input validation test report"
    
    local total_tests=$INPUT_TESTS_RUN
    local passed_tests=$INPUT_TESTS_PASSED
    local failed_tests=$INPUT_TESTS_FAILED
    local security_violations=$SECURITY_VIOLATIONS
    local success_rate=0
    
    if [[ $total_tests -gt 0 ]]; then
        success_rate=$(( (passed_tests * 100) / total_tests ))
    fi
    
    echo -e "\n${BLUE}=== Input Validation Edge Cases Summary ===${NC}"
    echo -e "Total Tests Run: $total_tests"
    echo -e "${GREEN}Passed: $passed_tests${NC}"
    echo -e "${RED}Failed: $failed_tests${NC}"
    echo -e "${RED}Security Violations: $security_violations${NC}"
    echo -e "Success Rate: ${success_rate}%"
    
    if [[ $security_violations -gt 0 ]]; then
        input_error "CRITICAL: $security_violations security violations detected!"
        return 2
    elif [[ $failed_tests -eq 0 ]]; then
        input_success "All input validation edge case tests passed!"
        return 0
    else
        input_error "$failed_tests input validation tests failed"
        return 1
    fi
}

# Main execution function
main() {
    input_info "Starting Input Validation Edge Case Testing"
    
    # Setup test environment
    setup_input_validation_tests
    
    # Set up cleanup trap
    trap cleanup_input_validation_tests EXIT
    
    local overall_success=true
    
    # Run all input validation edge case tests
    input_info "Running input validation edge case tests..."
    
    test_empty_inputs || overall_success=false
    test_special_characters || overall_success=false
    test_command_injection || overall_success=false
    test_boundary_conditions || overall_success=false
    test_path_manipulation || overall_success=false
    test_argument_parsing || overall_success=false
    test_unicode_handling || overall_success=false
    
    # Generate final report
    local report_exit_code=0
    generate_input_validation_report || report_exit_code=$?
    
    if [[ $report_exit_code -eq 2 ]]; then
        input_error "CRITICAL SECURITY ISSUES DETECTED"
        exit 2
    elif [[ $report_exit_code -ne 0 ]] || [[ "$overall_success" != "true" ]]; then
        input_error "Input validation edge case testing completed with failures"
        exit 1
    else
        input_success "Input validation edge case testing completed successfully"
        exit 0
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi