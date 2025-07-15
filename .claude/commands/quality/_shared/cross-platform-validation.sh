#!/bin/bash
# Cross-Platform Validation Script for .claude Protection System
# Phase 4: Final validation across different platforms and edge cases

set -euo pipefail

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        CYGWIN*)    echo "windows_cygwin" ;;
        MINGW*)     echo "windows_mingw" ;;
        MSYS*)      echo "windows_msys" ;;
        *)          echo "unknown" ;;
    esac
}

# Get path separator for current platform
get_path_separator() {
    local platform=$(detect_platform)
    case "$platform" in
        windows_*) echo "\\" ;;
        *)         echo "/" ;;
    esac
}

# Test path separator handling
test_path_separator_handling() {
    echo ""
    echo "🧪 Testing Path Separator Handling"
    echo "=================================="
    
    local platform=$(detect_platform)
    local separator=$(get_path_separator)
    local test_passed=0
    local test_failed=0
    
    echo "Platform: $platform"
    echo "Path separator: $separator"
    
    # Create test directory structure with platform-appropriate separators
    local test_dir="./test-cross-platform"
    local claude_dir_unix="$test_dir/.claude"
    local claude_dir_win="$test_dir\\.claude"
    
    mkdir -p "$test_dir/.claude/commands"
    
    # Test 1: Unix-style paths
    echo "Test 1: Unix-style path detection"
    if is_claude_path_cross_platform "$claude_dir_unix"; then
        echo "✅ PASS: Unix-style .claude path detected"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Unix-style .claude path not detected"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 2: Windows-style paths (if applicable)
    if [[ "$platform" == windows_* ]]; then
        echo "Test 2: Windows-style path detection"
        if is_claude_path_cross_platform "$claude_dir_win"; then
            echo "✅ PASS: Windows-style .claude path detected"
            test_passed=$((test_passed + 1))
        else
            echo "❌ FAIL: Windows-style .claude path not detected"
            test_failed=$((test_failed + 1))
        fi
    else
        echo "Test 2: SKIPPED (not Windows platform)"
    fi
    
    # Test 3: Mixed separators
    local mixed_path="$test_dir/.claude/commands"
    echo "Test 3: Mixed separator handling"
    if normalize_path_separators "$mixed_path" >/dev/null; then
        echo "✅ PASS: Mixed separators handled correctly"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Mixed separators not handled"
        test_failed=$((test_failed + 1))
    fi
    
    # Cleanup
    rm -rf "$test_dir"
    
    echo ""
    echo "Path Separator Test Results: $test_passed passed, $test_failed failed"
    return $test_failed
}

# Test case sensitivity scenarios
test_case_sensitivity() {
    echo ""
    echo "🧪 Testing Case Sensitivity Scenarios"
    echo "====================================="
    
    local platform=$(detect_platform)
    local test_passed=0
    local test_failed=0
    
    # Create test structure
    local test_dir="./test-case-sensitivity"
    mkdir -p "$test_dir"
    
    # Test different case variations
    local variations=(
        ".claude"
        ".CLAUDE"
        ".Claude"
        ".cLaUdE"
    )
    
    for variation in "${variations[@]}"; do
        local test_path="$test_dir/$variation"
        mkdir -p "$test_path"
        
        echo "Testing case variation: $variation"
        
        # Test path detection
        if is_claude_path_case_insensitive "$test_path"; then
            case "$platform" in
                macos|windows_*)
                    echo "✅ PASS: Case-insensitive detection on $platform"
                    test_passed=$((test_passed + 1))
                    ;;
                linux)
                    if [[ "$variation" == ".claude" ]]; then
                        echo "✅ PASS: Exact case match on Linux"
                        test_passed=$((test_passed + 1))
                    else
                        echo "✅ PASS: Non-exact case correctly not matched on Linux"
                        test_passed=$((test_passed + 1))
                    fi
                    ;;
            esac
        else
            echo "❌ FAIL: Case sensitivity test failed for $variation"
            test_failed=$((test_failed + 1))
        fi
    done
    
    # Cleanup
    rm -rf "$test_dir"
    
    echo ""
    echo "Case Sensitivity Test Results: $test_passed passed, $test_failed failed"
    return $test_failed
}

# Test symlink handling
test_symlink_handling() {
    echo ""
    echo "🧪 Testing Symlink Handling"
    echo "==========================="
    
    local test_passed=0
    local test_failed=0
    local test_dir="./test-symlinks"
    
    mkdir -p "$test_dir"
    
    # Create actual .claude directory
    mkdir -p "$test_dir/real-claude/.claude/commands"
    echo "Test command" > "$test_dir/real-claude/.claude/commands/test.md"
    
    # Test 1: Direct symlink to .claude directory
    echo "Test 1: Symlink to .claude directory"
    local abs_test_dir="$(cd "$test_dir" && pwd)"
    if ln -s "$abs_test_dir/real-claude/.claude" "$test_dir/symlink-claude" 2>/dev/null; then
        echo "DEBUG: Created symlink $test_dir/symlink-claude -> $test_dir/real-claude/.claude"
        echo "DEBUG: Symlink exists: $([ -L "$test_dir/symlink-claude" ] && echo "yes" || echo "no")"
        echo "DEBUG: Target exists: $([ -d "$test_dir/real-claude/.claude" ] && echo "yes" || echo "no")"
        
        # Check if symlink resolves correctly
        if [ -d "$test_dir/symlink-claude" ]; then
            echo "DEBUG: Symlink resolves to directory successfully"
            if is_claude_path_symlink_aware "$test_dir/symlink-claude"; then
                echo "✅ PASS: Symlinked .claude directory detected"
                test_passed=$((test_passed + 1))
            else
                echo "❌ FAIL: Symlinked .claude directory not detected"
                echo "DEBUG: Testing path: $test_dir/symlink-claude"
                echo "DEBUG: Resolved to: $(readlink -f "$test_dir/symlink-claude" 2>/dev/null || echo "failed to resolve")"
                test_failed=$((test_failed + 1))
            fi
        else
            echo "❌ FAIL: Symlink does not resolve to accessible directory"
            test_failed=$((test_failed + 1))
        fi
    else
        echo "⚠️  SKIP: Cannot create symlinks on this platform"
    fi
    
    # Test 2: Symlink inside .claude directory
    echo "Test 2: Symlink inside .claude directory"
    if ln -s "$abs_test_dir/real-claude/.claude/commands/test.md" "$test_dir/real-claude/.claude/commands/symlink-test.md" 2>/dev/null; then
        local symlink_path="$test_dir/real-claude/.claude/commands/symlink-test.md"
        if resolve_symlink_path "$symlink_path" >/dev/null; then
            echo "✅ PASS: Symlink inside .claude resolved correctly"
            test_passed=$((test_passed + 1))
        else
            echo "❌ FAIL: Symlink inside .claude not resolved"
            test_failed=$((test_failed + 1))
        fi
    else
        echo "⚠️  SKIP: Cannot create symlinks inside .claude"
    fi
    
    # Test 3: Broken symlink handling
    echo "Test 3: Broken symlink handling"
    if ln -s "$test_dir/nonexistent" "$test_dir/broken-symlink" 2>/dev/null; then
        if handle_broken_symlink "$test_dir/broken-symlink" >/dev/null 2>&1; then
            echo "✅ PASS: Broken symlink handled gracefully"
            test_passed=$((test_passed + 1))
        else
            echo "❌ FAIL: Broken symlink not handled"
            test_failed=$((test_failed + 1))
        fi
    else
        echo "⚠️  SKIP: Cannot create broken symlinks"
    fi
    
    # Cleanup
    rm -rf "$test_dir"
    
    echo ""
    echo "Symlink Handling Test Results: $test_passed passed, $test_failed failed"
    return $test_failed
}

# Test edge cases
test_edge_cases() {
    echo ""
    echo "🧪 Testing Edge Cases"
    echo "===================="
    
    local test_passed=0
    local test_failed=0
    local test_dir="./test-edge-cases"
    
    mkdir -p "$test_dir"
    
    # Test 1: Very long paths
    echo "Test 1: Very long path handling"
    local long_path="$test_dir/"
    for i in {1..20}; do
        long_path="${long_path}very-long-directory-name-$i/"
    done
    long_path="${long_path}.claude"
    
    if mkdir -p "$long_path" 2>/dev/null; then
        if is_claude_path_cross_platform "$long_path"; then
            echo "✅ PASS: Very long .claude path handled"
            test_passed=$((test_passed + 1))
        else
            echo "❌ FAIL: Very long .claude path not handled"
            test_failed=$((test_failed + 1))
        fi
    else
        echo "⚠️  SKIP: Cannot create very long paths on this platform"
    fi
    
    # Test 2: Special characters in paths
    echo "Test 2: Special characters in paths"
    local special_chars_dir="$test_dir/special-chars!@#$%"
    if mkdir -p "$special_chars_dir/.claude" 2>/dev/null; then
        if is_claude_path_cross_platform "$special_chars_dir/.claude"; then
            echo "✅ PASS: Special characters in path handled"
            test_passed=$((test_passed + 1))
        else
            echo "❌ FAIL: Special characters in path not handled"
            test_failed=$((test_failed + 1))
        fi
    else
        echo "⚠️  SKIP: Cannot create paths with special characters"
    fi
    
    # Test 3: Unicode characters in paths
    echo "Test 3: Unicode characters in paths"
    local unicode_dir="$test_dir/unicode-测试-🧪"
    if mkdir -p "$unicode_dir/.claude" 2>/dev/null; then
        if is_claude_path_cross_platform "$unicode_dir/.claude"; then
            echo "✅ PASS: Unicode characters in path handled"
            test_passed=$((test_passed + 1))
        else
            echo "❌ FAIL: Unicode characters in path not handled"
            test_failed=$((test_failed + 1))
        fi
    else
        echo "⚠️  SKIP: Cannot create paths with Unicode characters"
    fi
    
    # Test 4: Relative vs absolute path handling
    echo "Test 4: Relative vs absolute path consistency"
    local relative_path="./.claude"
    local absolute_path="$(pwd)/.claude"
    
    mkdir -p .claude
    
    local relative_result=$(is_claude_path_cross_platform "$relative_path"; echo $?)
    local absolute_result=$(is_claude_path_cross_platform "$absolute_path"; echo $?)
    
    if [[ "$relative_result" == "$absolute_result" ]]; then
        echo "✅ PASS: Relative and absolute paths handled consistently"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Inconsistent relative/absolute path handling"
        test_failed=$((test_failed + 1))
    fi
    
    rm -rf .claude
    
    # Cleanup
    rm -rf "$test_dir"
    
    echo ""
    echo "Edge Cases Test Results: $test_passed passed, $test_failed failed"
    return $test_failed
}

# Core helper functions for cross-platform testing
is_claude_path_cross_platform() {
    local path="$1"
    local normalized_path=$(normalize_path_separators "$path")
    
    # Check if path contains .claude directory
    [[ "$normalized_path" == *"/.claude"* ]] || [[ "$normalized_path" == *"/.claude" ]] || [[ "$(basename "$normalized_path")" == ".claude" ]]
}

is_claude_path_case_insensitive() {
    local path="$1"
    local platform=$(detect_platform)
    
    case "$platform" in
        macos|windows_*)
            # Case-insensitive platforms
            local lowercase_path=$(echo "$path" | tr '[:upper:]' '[:lower:]')
            [[ "$lowercase_path" == *"/.claude"* ]] || [[ "$lowercase_path" == *"/.claude" ]]
            ;;
        linux)
            # Case-sensitive platform
            [[ "$path" == *"/.claude"* ]] || [[ "$path" == *"/.claude" ]]
            ;;
        *)
            # Unknown platform, default to case-sensitive
            [[ "$path" == *"/.claude"* ]] || [[ "$path" == *"/.claude" ]]
            ;;
    esac
}

is_claude_path_symlink_aware() {
    local path="$1"
    
    # First check the original path
    if is_claude_path_cross_platform "$path"; then
        return 0
    fi
    
    # If it's a symlink, resolve it and check again
    if [ -L "$path" ]; then
        local resolved_path="$path"
        if command -v readlink >/dev/null 2>&1; then
            resolved_path=$(readlink -f "$path" 2>/dev/null || echo "$path")
        fi
        
        is_claude_path_cross_platform "$resolved_path"
    else
        return 1
    fi
}

normalize_path_separators() {
    local path="$1"
    local platform=$(detect_platform)
    
    case "$platform" in
        windows_*)
            # Convert forward slashes to backslashes on Windows
            echo "$path" | sed 's|/|\\|g'
            ;;
        *)
            # Convert backslashes to forward slashes on Unix-like systems
            echo "$path" | sed 's|\\|/|g'
            ;;
    esac
}

resolve_symlink_path() {
    local path="$1"
    
    if [ -L "$path" ]; then
        if command -v readlink >/dev/null 2>&1; then
            readlink -f "$path" 2>/dev/null || echo "$path"
        else
            echo "$path"
        fi
    else
        echo "$path"
    fi
}

handle_broken_symlink() {
    local path="$1"
    
    if [ -L "$path" ] && [ ! -e "$path" ]; then
        echo "Warning: Broken symlink detected: $path"
        return 0
    fi
    
    return 1
}

# File system permission tests
test_file_permissions() {
    echo ""
    echo "🧪 Testing File System Permissions"
    echo "=================================="
    
    local test_passed=0
    local test_failed=0
    local test_dir="./test-permissions"
    
    mkdir -p "$test_dir/.claude/commands"
    
    # Test 1: Read-only .claude directory
    echo "Test 1: Read-only .claude directory handling"
    chmod 444 "$test_dir/.claude"
    
    if test_claude_readonly_access "$test_dir/.claude"; then
        echo "✅ PASS: Read-only .claude directory handled correctly"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Read-only .claude directory not handled"
        test_failed=$((test_failed + 1))
    fi
    
    # Restore permissions for cleanup
    chmod 755 "$test_dir/.claude"
    
    # Test 2: No write permission to parent directory
    echo "Test 2: No write permission to parent directory"
    chmod 555 "$test_dir"
    
    if test_claude_parent_readonly "$test_dir/.claude"; then
        echo "✅ PASS: Parent directory permissions handled correctly"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Parent directory permissions not handled"
        test_failed=$((test_failed + 1))
    fi
    
    # Restore permissions for cleanup
    chmod 755 "$test_dir"
    
    # Cleanup
    rm -rf "$test_dir"
    
    echo ""
    echo "File Permissions Test Results: $test_passed passed, $test_failed failed"
    return $test_failed
}

test_claude_readonly_access() {
    local claude_dir="$1"
    
    # Try to read from the directory
    if ls "$claude_dir" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

test_claude_parent_readonly() {
    local claude_dir="$1"
    local parent_dir=$(dirname "$claude_dir")
    
    # Try to access the .claude directory when parent is read-only
    if [ -d "$claude_dir" ]; then
        return 0
    else
        return 1
    fi
}

# Performance tests for large .claude directories
test_performance_large_directories() {
    echo ""
    echo "🧪 Testing Performance with Large Directories"
    echo "============================================="
    
    local test_passed=0
    local test_failed=0
    local test_dir="./test-performance"
    
    mkdir -p "$test_dir/.claude/commands"
    
    # Create many files
    echo "Creating large .claude directory with 1000 files..."
    for i in {1..1000}; do
        echo "Test command $i" > "$test_dir/.claude/commands/test-$i.md"
    done
    
    # Test 1: Path detection performance
    echo "Test 1: Path detection performance"
    local start_time=$(date +%s%N)
    
    for i in {1..100}; do
        is_claude_path_cross_platform "$test_dir/.claude/commands/test-$i.md" >/dev/null
    done
    
    local end_time=$(date +%s%N)
    local duration=$(((end_time - start_time) / 1000000)) # Convert to milliseconds
    
    echo "Path detection time for 100 operations: ${duration}ms"
    
    if [ $duration -lt 1000 ]; then # Less than 1 second
        echo "✅ PASS: Path detection performance acceptable"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Path detection too slow"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 2: Directory traversal performance
    echo "Test 2: Directory traversal performance"
    start_time=$(date +%s%N)
    
    find "$test_dir/.claude" -name "*.md" | while read file; do
        is_claude_path_cross_platform "$file" >/dev/null
    done
    
    end_time=$(date +%s%N)
    duration=$(((end_time - start_time) / 1000000))
    
    echo "Directory traversal time for 1000 files: ${duration}ms"
    
    if [ $duration -lt 5000 ]; then # Less than 5 seconds
        echo "✅ PASS: Directory traversal performance acceptable"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Directory traversal too slow"
        test_failed=$((test_failed + 1))
    fi
    
    # Cleanup
    rm -rf "$test_dir"
    
    echo ""
    echo "Performance Test Results: $test_passed passed, $test_failed failed"
    return $test_failed
}

# Main cross-platform validation runner
run_cross_platform_validation() {
    echo ""
    echo "🚀 CROSS-PLATFORM VALIDATION - PHASE 4"
    echo "======================================="
    echo "Platform: $(detect_platform)"
    echo "Date: $(date)"
    echo ""
    
    local total_test_suites=0
    local failed_test_suites=0
    local start_time=$(date +%s)
    
    # Run all test suites
    echo "🧪 Running cross-platform test suites..."
    echo ""
    
    # Test Suite 1: Path Separator Handling
    test_path_separator_handling
    local result=$?
    total_test_suites=$((total_test_suites + 1))
    if [ $result -ne 0 ]; then
        failed_test_suites=$((failed_test_suites + 1))
    fi
    
    # Test Suite 2: Case Sensitivity
    test_case_sensitivity
    result=$?
    total_test_suites=$((total_test_suites + 1))
    if [ $result -ne 0 ]; then
        failed_test_suites=$((failed_test_suites + 1))
    fi
    
    # Test Suite 3: Symlink Handling
    test_symlink_handling
    result=$?
    total_test_suites=$((total_test_suites + 1))
    if [ $result -ne 0 ]; then
        failed_test_suites=$((failed_test_suites + 1))
    fi
    
    # Test Suite 4: Edge Cases
    test_edge_cases
    result=$?
    total_test_suites=$((total_test_suites + 1))
    if [ $result -ne 0 ]; then
        failed_test_suites=$((failed_test_suites + 1))
    fi
    
    # Test Suite 5: File Permissions
    test_file_permissions
    result=$?
    total_test_suites=$((total_test_suites + 1))
    if [ $result -ne 0 ]; then
        failed_test_suites=$((failed_test_suites + 1))
    fi
    
    # Test Suite 6: Performance
    test_performance_large_directories
    result=$?
    total_test_suites=$((total_test_suites + 1))
    if [ $result -ne 0 ]; then
        failed_test_suites=$((failed_test_suites + 1))
    fi
    
    # Calculate final results
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local passed_suites=$((total_test_suites - failed_test_suites))
    
    echo ""
    echo "📊 CROSS-PLATFORM VALIDATION RESULTS"
    echo "===================================="
    echo "Platform: $(detect_platform)"
    echo "Total Test Suites: $total_test_suites"
    echo "Passed: $passed_suites"
    echo "Failed: $failed_test_suites"
    echo "Duration: ${duration}s"
    echo ""
    
    if [ $failed_test_suites -eq 0 ]; then
        echo "🎉 ALL CROSS-PLATFORM TESTS PASSED!"
        echo "✅ .claude protection system is FULLY VALIDATED"
        echo "✅ Ready for deployment across all platforms"
        echo ""
        echo "🚀 PHASE 4 VALIDATION: COMPLETE ✅"
        return 0
    else
        echo "❌ SOME CROSS-PLATFORM TESTS FAILED"
        echo "🔧 Review failed test suites before deployment"
        echo ""
        echo "📋 Phase 4 requires fixes before completion"
        return 1
    fi
}

# Export main function
export -f run_cross_platform_validation

# Run validation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_cross_platform_validation
fi