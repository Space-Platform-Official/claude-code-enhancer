# Testing Guide for Claude Flow

This guide covers the testing strategy, test structure, and how to write and run tests for Claude Flow.

## Testing Philosophy

Claude Flow uses a practical testing approach:
- **Real-world testing**: Tests use actual scripts, not mocks
- **User simulation**: Tests simulate real user interactions
- **Idempotency**: Verify scripts can run multiple times safely
- **Edge cases**: Cover error conditions and conflicts

## Test Suite Overview

### Test Structure

```
test/
├── README.md                    # Test documentation
├── run-tests.sh                # Main test runner
├── install-claude-flow-link.sh # Symlink to actual script
├── mock-templates/             # Minimal test templates
│   ├── CLAUDE.md
│   └── templates/
│       ├── languages/
│       │   └── python/
│       │       └── CLAUDE.md
│       └── frameworks/
│           └── react/
│               └── CLAUDE.md
└── test-projects/             # Created during test runs
    ├── fresh-install/
    ├── merge-test/
    ├── options-test/
    └── idempotent-test/
```

### Test Scenarios

1. **Fresh Installation** - Clean project setup
2. **Merge Conflicts** - Handling existing files
3. **All Options** - Testing user choices
4. **Idempotency** - Multiple runs safety

## Running Tests

### Quick Start

```bash
cd test
chmod +x run-tests.sh
./run-tests.sh
```

### Run Specific Tests

```bash
cd test
source run-tests.sh

# Run individual test functions
test_fresh_install
test_merge_conflicts
test_all_options
test_idempotency
```

### Debug Mode

```bash
# Run with bash debug output
cd test
bash -x ./run-tests.sh

# Or set debug flag
export CLAUDE_DEBUG=1
./run-tests.sh
```

## Writing Tests

### Test Function Structure

```bash
test_example_scenario() {
    print_test "Test: Example Scenario"
    
    # Setup
    mkdir -p test-projects/example
    cd test-projects/example
    
    # Create test conditions
    echo "existing content" > existing-file.txt
    
    # Run the script under test
    echo "y" | /bin/bash ../../install-claude-flow-link.sh
    
    # Verify results
    if [ -f "claude/CLAUDE.md" ]; then
        print_success "File created successfully"
    else
        print_error "Expected file not created"
        return 1
    fi
    
    # Cleanup (automatic via trap)
    cd ../..
}
```

### Test Utilities

```bash
# Print functions for consistent output
print_test "Test: Description"      # Blue header
print_success "Check passed"        # Green checkmark
print_info "Additional info"        # Yellow info
print_error "Check failed"          # Red error

# Automatic cleanup on exit
trap 'cleanup' EXIT
```

### Simulating User Input

```bash
# Single response
echo "y" | ./script.sh

# Multiple responses
printf "1\n2\ny\n" | ./script.sh

# Complex interaction
{
    echo "1"      # Select option 1
    echo "python" # Choose python
    echo "y"      # Confirm
} | ./script.sh
```

## Test Categories

### 1. Installation Tests

Test the core installation functionality:

```bash
test_language_detection() {
    print_test "Test: Language Detection"
    
    # Create project with Python files
    mkdir -p test-projects/python-project
    cd test-projects/python-project
    touch main.py requirements.txt
    
    # Run install and verify Python template selected
    echo "" | /bin/bash ../../install-claude-flow-link.sh
    
    if grep -q "Python" claude/CLAUDE.md; then
        print_success "Python template auto-selected"
    else
        print_error "Language detection failed"
    fi
}
```

### 2. Merge Tests

Test conflict resolution:

```bash
test_merge_strategies() {
    print_test "Test: Merge Strategies"
    
    # Test each merge option
    for option in "o" "s" "k" "m"; do
        setup_merge_test
        echo "$option" | ./smart-merge-claude.sh
        verify_merge_result "$option"
    done
}
```

### 3. Edge Case Tests

Test error conditions:

```bash
test_missing_templates() {
    print_test "Test: Missing Templates"
    
    # Temporarily move templates
    mv templates templates.backup
    
    # Should fail gracefully
    if ./install-claude-flow.sh 2>&1 | grep -q "Templates directory not found"; then
        print_success "Handles missing templates correctly"
    else
        print_error "Should fail when templates missing"
    fi
    
    # Restore
    mv templates.backup templates
}
```

### 4. Integration Tests

Test complete workflows:

```bash
test_full_workflow() {
    print_test "Test: Complete Installation Workflow"
    
    # Install system-wide (test mode)
    ./install.sh --user
    
    # Use installed commands
    ~/.local/bin/claude-install-flow test-projects/integration
    
    # Verify full setup
    check_installation_complete "test-projects/integration"
}
```

## Test Data

### Mock Templates

Keep mock templates minimal but representative:

```bash
# mock-templates/CLAUDE.md
cat << 'EOF'
# Mock Main CLAUDE.md
This is a test template.
EOF

# mock-templates/templates/languages/python/CLAUDE.md
cat << 'EOF'
# Mock Python CLAUDE.md
Python-specific test content.
EOF
```

### Test Fixtures

Create consistent test environments:

```bash
create_test_project() {
    local name=$1
    mkdir -p "test-projects/$name"
    cd "test-projects/$name"
    
    # Add standard test files
    echo "# Test Project" > README.md
    echo "test content" > test.txt
}
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Run Tests
        run: |
          cd test
          chmod +x run-tests.sh
          ./run-tests.sh
      
      - name: Test Installation
        run: |
          ./install.sh --user
          ~/.local/bin/claude-install-flow --help
```

## Test Coverage

### Current Coverage

- ✅ Basic installation flows
- ✅ Merge conflict handling  
- ✅ User input simulation
- ✅ Idempotency verification
- ✅ Error handling

### Areas for Improvement

- [ ] Performance benchmarks
- [ ] Cross-platform testing
- [ ] Template validation
- [ ] Command execution tests
- [ ] Permission edge cases

## Debugging Test Failures

### Common Issues

1. **Path Issues**
   ```bash
   # Ensure correct working directory
   pwd
   ls -la
   ```

2. **Permission Errors**
   ```bash
   # Check file permissions
   ls -la *.sh
   chmod +x *.sh
   ```

3. **Environment Variables**
   ```bash
   # Check test environment
   env | grep CLAUDE
   ```

### Test Isolation

Ensure tests don't interfere with each other:

```bash
test_isolated() {
    # Save current state
    local original_dir=$(pwd)
    
    # Run test in isolation
    (
        cd test-projects/isolated
        # Test code here
    )
    
    # Restore state
    cd "$original_dir"
}
```

## Best Practices

### Do's

- ✅ Clean up after tests
- ✅ Use descriptive test names
- ✅ Test both success and failure cases
- ✅ Simulate real user behavior
- ✅ Make tests independent

### Don'ts

- ❌ Don't modify production files
- ❌ Don't assume test order
- ❌ Don't skip error checking
- ❌ Don't use hardcoded paths
- ❌ Don't leave test artifacts

## Adding New Tests

1. **Identify what to test**
   - New features
   - Bug fixes
   - Edge cases

2. **Write the test**
   ```bash
   test_new_feature() {
       print_test "Test: New Feature"
       # Implementation
   }
   ```

3. **Add to test runner**
   - Add function call in `run-tests.sh`
   - Update test count

4. **Document the test**
   - Add description in test README
   - Explain what it verifies

## Test Maintenance

### Regular Tasks

- Review and update mock templates
- Remove obsolete tests
- Improve test performance
- Add missing coverage

### Version Compatibility

Ensure tests work across different environments:

```bash
# Check bash version
if [[ "${BASH_VERSION%%.*}" -lt 4 ]]; then
    echo "Warning: Tests require Bash 4+"
fi

# Check OS compatibility
case "$(uname -s)" in
    Darwin*) echo "Running on macOS" ;;
    Linux*)  echo "Running on Linux" ;;
    *)       echo "Unknown OS" ;;
esac
```