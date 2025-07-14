# Phase 2 Mock Execution Testing Framework

Comprehensive mock execution testing framework for Claude Flow git commands that simulates command execution without running actual git operations.

## Overview

This framework provides:
- Mock git command execution with stateful repository simulation
- Argument substitution and validation
- Command flow tracking and validation
- Comprehensive test scenarios covering happy paths, errors, edge cases, and security

## Architecture

### Core Components

1. **mock-git-test.sh** - Main test runner
   - Orchestrates test execution
   - Manages test lifecycle
   - Generates comprehensive reports
   - Supports multiple test modes

2. **lib/mock-environment.sh** - Mock environment management
   - Simulates git repository states
   - Provides mock git command responses
   - Manages test fixtures
   - Tracks repository state transitions

3. **lib/command-executor.sh** - Command execution engine
   - Parses and validates arguments
   - Performs $ARGUMENTS substitution
   - Executes command workflows
   - Tracks execution history

4. **fixtures/mock-responses/** - Response templates
   - Realistic git command outputs
   - Error scenarios
   - Edge case responses

## Test Categories

### 1. Happy Path Tests
- Normal commit workflow
- Branch creation and switching
- Clean push operations
- Status checks

### 2. Error Condition Tests
- Pre-commit hook failures
- Merge conflicts
- Push rejections
- Invalid branch operations

### 3. Edge Case Tests
- Large file detection
- Protected branch commits
- Empty commits
- Concurrent operations

### 4. Security Tests
- Sensitive data detection
- Command injection prevention
- Path traversal protection
- Argument sanitization

### 5. Argument Substitution Tests
- Basic substitution patterns
- Complex argument handling
- Special character processing
- Empty argument handling

### 6. Command Flow Tests
- Command sequencing
- Prerequisite validation
- State transitions
- Rollback scenarios

## Usage

### Run All Tests
```bash
./mock-git-test.sh
```

### Run Specific Test Category
```bash
# Run only happy path tests
./mock-git-test.sh -m happy

# Run only security tests
./mock-git-test.sh -m security

# Run only error condition tests
./mock-git-test.sh -m error
```

### Run Individual Test
```bash
# Run specific test by name
./mock-git-test.sh -t normal_commit_workflow
./mock-git-test.sh -t command_injection
```

### Debug Mode
```bash
# Enable debug output
./mock-git-test.sh -d

# Debug specific test category
./mock-git-test.sh -d -m error
```

### List Available Tests
```bash
./mock-git-test.sh -l
```

## Mock Repository States

The framework simulates various repository states:

- **Clean** - No changes, ready for new work
- **Dirty** - Uncommitted changes present
- **Staged** - Files staged for commit
- **Conflicts** - Merge conflicts present
- **Protected Branch** - On main/master branch
- **Large Files** - Files exceeding size limits

## Argument Substitution

The framework supports Claude Flow argument patterns:

- `$ARGUMENTS` - Full argument string
- `$BRANCH` - Current branch name
- `$MESSAGE` - Commit message
- `$FILES` - File list
- `$OPTIONS` - Command options

## Security Validations

### Command Injection Prevention
```bash
# These patterns are blocked:
/git/commit -m "test; rm -rf /"
/git/commit -m "$(malicious command)"
/git/commit -m "`dangerous`"
```

### Path Traversal Protection
```bash
# These paths are rejected:
../../../etc/passwd
/etc/../etc/passwd
./../sensitive/file
```

### Sensitive Data Detection
- Passwords
- API keys
- Secrets
- Tokens

## Extending the Framework

### Adding New Tests

1. Add test function to `command-executor.sh`:
```bash
test_your_new_test() {
    print_info "Testing your scenario"
    
    # Set up test state
    setup_your_test_state
    
    # Execute commands
    if simulate_command_execution "/git/command" "args"; then
        # Verify results
        return 0
    fi
    
    return 1
}
```

2. Register test in `mock-git-test.sh`:
```bash
# Add to appropriate test category function
run_test "your_new_test" test_your_new_test
```

### Adding Mock Responses

Create new fixture files in `fixtures/mock-responses/`:
```bash
echo "Your mock response" > fixtures/mock-responses/git-command-scenario.txt
```

### Custom Repository States

Add state setup functions to `mock-environment.sh`:
```bash
setup_your_custom_state() {
    setup_clean_repo_state
    MOCK_REPO_STATE[your_property]=true
    MOCK_FILES[your/file.js]="modified"
}
```

## Test Output

### Success Output
```
✓ [PASS] normal_commit_workflow
✓ [PASS] branch_operations
✓ [PASS] clean_push
```

### Failure Output
```
✗ [FAIL] precommit_hook_failure
       └─ Hook validation failed as expected
```

### Summary Report
```
📊 Test Summary
Total Tests: 24
Passed: 22
Failed: 2
Skipped: 0

Pass Rate: 91%

🎯 Overall Status
❌ FAILURE: 2 tests failed
```

## Best Practices

1. **Isolation** - Each test runs in isolated environment
2. **Repeatability** - Tests produce consistent results
3. **Coverage** - Test both success and failure paths
4. **Validation** - Verify both output and state changes
5. **Security** - Always test security boundaries

## Troubleshooting

### Test Failures
- Run with `-d` flag for debug output
- Check mock state setup
- Verify command file exists
- Review execution history

### Environment Issues
- Ensure all scripts are executable
- Verify directory structure
- Check file permissions

### Mock State Problems
- Reset state between tests
- Verify state transitions
- Check for state leakage

## Integration with CI/CD

```yaml
# Example GitHub Actions workflow
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v2
    - name: Run Mock Tests
      run: |
        cd test
        ./mock-git-test.sh
```

## Future Enhancements

- [ ] Performance benchmarking
- [ ] Coverage reporting
- [ ] Parallel test execution
- [ ] Custom assertion library
- [ ] Mock network operations
- [ ] Time-based scenarios