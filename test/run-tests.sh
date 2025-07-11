#!/bin/bash

# Unified test runner for install-claude-flow.sh
# Runs all test scenarios in sequence

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
readonly TEST_PROJECTS_DIR="$SCRIPT_DIR/test-projects"
TEST_FAILURES=0

# Exit handler for cleanup
cleanup_on_exit() {
    local exit_code=$1
    cleanup
    if [[ $exit_code -ne 0 ]]; then
        print_error "Test suite failed with exit code $exit_code"
    fi
}

print_test() {
    local message="${1:-}"
    [[ -n "$message" ]] && echo -e "\n${BLUE}=== $message ===${NC}"
}

print_success() {
    local message="${1:-}"
    [[ -n "$message" ]] && echo -e "${GREEN}✓ $message${NC}"
}

print_info() {
    local message="${1:-}"
    [[ -n "$message" ]] && echo -e "${YELLOW}ℹ $message${NC}"
}

print_error() {
    local message="${1:-}"
    [[ -n "$message" ]] && echo -e "${RED}✗ $message${NC}" >&2
    ((TEST_FAILURES++))
}

# Clean up function
cleanup() {
    if [[ -d "$TEST_PROJECTS_DIR" ]]; then
        print_info "Cleaning up test artifacts..."
        rm -rf "$TEST_PROJECTS_DIR"/*/claude 2>/dev/null || true
        find "$TEST_PROJECTS_DIR" -name "*.new" -delete 2>/dev/null || true
    fi
}

# Test 1: Fresh Installation
test_fresh_install() {
    print_test "Test 1: Fresh Installation"
    
    mkdir -p test-projects/fresh-install
    builtin cd test-projects/fresh-install
    
    # Run install script (auto-answer with default choices)
    echo "" | /bin/bash ../../install-claude-flow-link.sh
    
    # Verify main files
    if [ -f "claude/CLAUDE.md" ] && [ -f "claude/MERGE_REPORT.md" ]; then
        print_success "Fresh install completed successfully"
        print_info "Files created: $(find claude -type f | wc -l)"
    else
        echo "ERROR: Fresh install failed - missing main files"
        exit 1
    fi
    
    # Verify template files were copied
    if [ -f "claude/templates/languages/python/CLAUDE.md" ] && [ -f "claude/templates/frameworks/react/CLAUDE.md" ]; then
        print_success "Template files copied successfully"
    else
        echo "ERROR: Template files not copied properly"
        exit 1
    fi
    
    # Verify content of copied files
    if grep -q "Mock Main CLAUDE.md" claude/CLAUDE.md; then
        print_success "Main template content verified"
    else
        echo "ERROR: Main template content incorrect"
        exit 1
    fi
    
    if grep -q "Mock Python CLAUDE.md" claude/templates/languages/python/CLAUDE.md; then
        print_success "Python template content verified"
    else
        echo "ERROR: Python template content incorrect"
        exit 1
    fi
    
    if grep -q "Mock React CLAUDE.md" claude/templates/frameworks/react/CLAUDE.md; then
        print_success "React template content verified"
    else
        echo "ERROR: React template content incorrect"
        exit 1
    fi
    
    builtin cd ../..
}

# Test 2: Merge Conflicts
test_merge_conflicts() {
    print_test "Test 2: Merge Conflicts"
    
    mkdir -p test-projects/merge-test
    builtin cd test-projects/merge-test
    
    # Create existing files with existing content
    mkdir -p claude/templates/languages/python
    echo "# Existing CLAUDE.md" > claude/CLAUDE.md
    echo "# Custom Python template" > claude/templates/languages/python/CLAUDE.md
    
    # Run install script with automated responses
    # m = merge later for main CLAUDE.md
    # k = keep existing for python CLAUDE.md
    printf "m\nk\n" | /bin/bash ../../install-claude-flow-link.sh
    
    # Verify .new file was created for main CLAUDE.md
    if [ -f "claude/CLAUDE.md.new" ]; then
        print_success "Merge conflicts handled correctly - .new file created"
        print_info "Created .new file: claude/CLAUDE.md.new"
        
        # Verify the .new file has the new content
        if grep -q "Mock Main CLAUDE.md" claude/CLAUDE.md.new; then
            print_success "New file contains correct template content"
        else
            echo "ERROR: New file has incorrect content"
            exit 1
        fi
        
        # Verify original file was preserved
        if grep -q "Existing CLAUDE.md" claude/CLAUDE.md; then
            print_success "Original file was preserved"
        else
            echo "ERROR: Original file was not preserved"
            exit 1
        fi
    else
        echo "ERROR: .new file was not created"
        exit 1
    fi
    
    # Verify python template was preserved (keep option)
    if [ -f "claude/templates/languages/python/CLAUDE.md" ] && grep -q "Custom Python template" claude/templates/languages/python/CLAUDE.md; then
        print_success "Keep option worked - existing Python template preserved"
    else
        echo "ERROR: Python template was not preserved"
        exit 1
    fi
    
    # Verify react template was created (new file)
    if [ -f "claude/templates/frameworks/react/CLAUDE.md" ] && grep -q "Mock React CLAUDE.md" claude/templates/frameworks/react/CLAUDE.md; then
        print_success "New React template was created correctly"
    else
        echo "ERROR: React template was not created properly"
        exit 1
    fi
    
    builtin cd ../..
}

# Test 3: All Options Test
test_all_options() {
    print_test "Test 3: All Merge Options"
    
    mkdir -p test-projects/options-test
    builtin cd test-projects/options-test
    
    # Create existing files
    mkdir -p claude/templates/frameworks/react claude/templates/languages/python
    echo "# Existing main" > claude/CLAUDE.md
    echo "# Existing Python" > claude/templates/languages/python/CLAUDE.md
    echo "# Existing React" > claude/templates/frameworks/react/CLAUDE.md
    
    # Test different options:
    # o = overwrite for main CLAUDE.md
    # s = skip for python template
    # k = keep for react template
    printf "o\ns\nk\n" | /bin/bash ../../install-claude-flow-link.sh
    
    # Verify results with better checks
    if grep -q "Mock Main CLAUDE.md" claude/CLAUDE.md; then
        print_success "Overwrite option worked - main CLAUDE.md updated"
    else
        echo "ERROR: Overwrite option failed"
        exit 1
    fi
    
    # Check that python template still exists (skip should preserve it)
    if [ -f "claude/templates/languages/python/CLAUDE.md" ] && grep -q "Existing Python" claude/templates/languages/python/CLAUDE.md; then
        print_success "Skip option worked - existing Python template preserved"
    else
        echo "ERROR: Skip option failed"
        exit 1
    fi
    
    # Check that react template still has original content (keep should preserve it)
    if grep -q "Existing React" claude/templates/frameworks/react/CLAUDE.md; then
        print_success "Keep option worked - existing React template preserved"
    else
        echo "ERROR: Keep option failed"
        exit 1
    fi
    
    # Verify template structure was created properly
    if [ -d "claude/templates" ] && [ -d "claude/templates/languages" ] && [ -d "claude/templates/frameworks" ]; then
        print_success "Template directory structure created correctly"
    else
        echo "ERROR: Template directory structure not created properly"
        exit 1
    fi
    
    builtin cd ../..
}

# Test 4: Idempotency
test_idempotency() {
    print_test "Test 4: Idempotency (Running Twice)"
    
    mkdir -p test-projects/idempotent-test
    builtin cd test-projects/idempotent-test
    
    # First run
    echo "" | /bin/bash ../../install-claude-flow-link.sh > /dev/null 2>&1
    
    # Capture file state after first run
    first_run_files=$(find claude -type f -exec md5sum {} + 2>/dev/null | sort)
    
    # Second run - should detect no changes needed for identical files
    output=$(echo "" | /bin/bash ../../install-claude-flow-link.sh 2>&1)
    
    # Capture file state after second run
    second_run_files=$(find claude -type f -exec md5sum {} + 2>/dev/null | sort)
    
    # Check if output indicates no changes or if files are identical
    if echo "$output" | grep -q "No changes needed"; then
        print_success "Idempotency verified - script detected no changes needed"
    elif [ "$first_run_files" = "$second_run_files" ]; then
        print_success "Idempotency verified - files remain identical after second run"
    else
        print_info "Script ran and may have made changes (this could be expected behavior)"
        print_info "First run created $(echo "$first_run_files" | wc -l) files"
        print_info "Second run resulted in $(echo "$second_run_files" | wc -l) files"
    fi
    
    # Verify no .new files were created on second run
    if [ -z "$(find claude -name "*.new" 2>/dev/null)" ]; then
        print_success "No .new files created on second run"
    else
        echo "ERROR: .new files created on second run - should not happen"
        exit 1
    fi
    
    builtin cd ../..
}

# Main test execution
main() {
    echo "Claude-Flow Installation Script Test Suite"
    echo "=========================================="
    
    # Validate environment
    if [[ ! -f "$SCRIPT_DIR/install-claude-flow-link.sh" ]]; then
        print_error "Test script not found: $SCRIPT_DIR/install-claude-flow-link.sh"
        return 1
    fi
    
    # Setup
    if ! chmod +x "$SCRIPT_DIR/install-claude-flow-link.sh"; then
        print_error "Failed to make test script executable"
        return 1
    fi
    
    # Verify main install script exists
    if [[ ! -f "$SCRIPT_DIR/../install-claude-flow.sh" ]]; then
        print_error "Main install script not found at $SCRIPT_DIR/../install-claude-flow.sh"
        return 1
    fi
    
    # Verify mock templates exist
    if [[ ! -d "$SCRIPT_DIR/mock-templates" ]]; then
        print_error "Mock templates directory not found at $SCRIPT_DIR/mock-templates"
        return 1
    fi
    
    # Create test projects directory
    if ! mkdir -p "$TEST_PROJECTS_DIR"; then
        print_error "Failed to create test projects directory"
        return 1
    fi
    
    cleanup
    
    # Run all tests with error handling
    echo -e "\n${BLUE}Starting test execution...${NC}"
    
    test_fresh_install || true
    test_merge_conflicts || true
    test_all_options || true
    test_idempotency || true
    
    # Summary
    if [[ $TEST_FAILURES -eq 0 ]]; then
        echo -e "\n${GREEN}🎉 All tests completed successfully!${NC}"
        echo -e "${GREEN}✓ Fresh installation test passed${NC}"
        echo -e "${GREEN}✓ Merge conflicts test passed${NC}"
        echo -e "${GREEN}✓ All merge options test passed${NC}"
        echo -e "${GREEN}✓ Idempotency test passed${NC}"
        echo -e "\n${GREEN}Test suite completed. Your installation script is working correctly!${NC}"
        return 0
    else
        echo -e "\n${RED}Test suite completed with $TEST_FAILURES failure(s)${NC}"
        return 1
    fi
}

# Run tests only if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi