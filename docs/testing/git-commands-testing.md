# Git Commands Testing Framework Documentation

## Overview

The Claude Flow Git Commands Testing Framework provides comprehensive validation and testing for all git-related command templates. This three-phase testing approach ensures reliability, security, and maintainability of git command implementations.

## Testing Architecture

### Three-Phase Testing Approach

The testing framework follows a structured three-phase approach designed to catch issues early and provide confidence in production deployments:

```
Phase 1: Static Validation
    ↓
Phase 2: Mock Execution  
    ↓
Phase 3: Integration E2E Tests
```

#### Phase 1: Static Validation
- **Purpose**: Validate command structure, documentation, and references without execution
- **Speed**: Fast (< 30 seconds)
- **Coverage**: All git command templates
- **When to Use**: During development, before commits, in CI/CD pipelines

**What it validates:**
- YAML frontmatter structure and required fields
- Command documentation completeness
- Cross-references between commands
- Security considerations in command descriptions
- Markdown formatting and consistency
- Best practice compliance

#### Phase 2: Mock Execution
- **Purpose**: Test command logic with simulated git responses
- **Speed**: Medium (1-3 minutes)
- **Coverage**: Command execution paths and error handling
- **When to Use**: Before major releases, integration testing

**What it validates:**
- Command execution flow with mock git responses
- Error handling and recovery mechanisms
- User interaction patterns
- Parameter validation
- Edge case handling

#### Phase 3: Integration E2E Tests
- **Purpose**: Test complete workflows in real git repositories
- **Speed**: Slow (5-15 minutes)
- **Coverage**: End-to-end user scenarios
- **When to Use**: Release validation, regression testing

**What it validates:**
- Complete git workflows
- Real repository interactions
- Multi-command sequences
- Performance characteristics
- Cross-platform compatibility

## Quick Start Guide

### For Developers

**Basic validation during development:**
```bash
# Quick validation of current changes
cd test
./run-git-tests.sh -m quick

# Validate specific command template
./validate-git-commands.sh templates/commands/git/commit.md
```

**Full validation before commit:**
```bash
# Complete test suite
./run-git-tests.sh -m full

# With verbose output for debugging
./run-git-tests.sh -m full -v
```

### For CI/CD Integration

**GitHub Actions example:**
```yaml
name: Git Commands Testing
on: [push, pull_request]

jobs:
  test-git-commands:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Git Commands Tests
        run: |
          cd test
          chmod +x run-git-tests.sh
          ./run-git-tests.sh -m ci -r junit
      
      - name: Upload Test Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: test-results
          path: test/results/
```

## Detailed Testing Phases

### Phase 1: Static Validation

The static validation phase performs comprehensive analysis without executing any git commands.

#### Command Structure Validation

**YAML Frontmatter Requirements:**
```yaml
---
allowed-tools: "all" | "none" | "Bash,Read,Write,..."
description: "Clear description of command purpose (10-200 chars)"
category: "git" | "workflow" | "utility"
complexity: "basic" | "intermediate" | "advanced"
---
```

**Required Documentation Sections:**
- H1 heading with command name
- Usage pattern section
- At least one code example
- Summary or conclusion

**Cross-Reference Validation:**
- All relative file references must exist
- No broken links to other commands
- Consistent command naming

#### Security Validation

**Sensitive Information Detection:**
- No hardcoded passwords, tokens, or secrets
- Proper security warnings for sensitive operations
- Safe default parameter values

**Command Safety Analysis:**
- Destructive operations clearly marked
- Backup recommendations where appropriate
- Recovery instructions for dangerous operations

#### Best Practices Compliance

**Documentation Standards:**
- Consistent formatting and structure
- Appropriate emoji usage (< 10 per file)
- Clear, actionable instructions
- Proper markdown syntax

**Command Design:**
- Follows established patterns
- Includes error handling guidance
- Provides meaningful user feedback

### Phase 2: Mock Execution

The mock execution phase tests command logic using simulated git responses.

#### Mock Environment Setup

**Mock Git Responses:**
The framework provides realistic git responses for common scenarios:

```bash
# Mock responses available in test/fixtures/mock-responses/
git-status-clean.txt       # Clean working directory
git-status-dirty.txt       # Uncommitted changes
git-status-conflicts.txt   # Merge conflicts
git-commit-success.txt     # Successful commit
git-commit-hook-failure.txt # Pre-commit hook failure
git-push-success.txt       # Successful push
git-push-rejected.txt      # Push rejected
git-branch-list.txt        # Branch listing
```

#### Test Scenarios

**Happy Path Testing:**
- Standard workflow execution
- Expected user inputs
- Normal git repository states

**Error Handling:**
- Git command failures
- Network connectivity issues
- Repository permission problems
- Conflicting git states

**Edge Cases:**
- Empty repositories
- Large file handling
- Complex merge scenarios
- Concurrent operation conflicts

#### Mock Test Configuration

**Test Modes:**
```bash
# Happy path only (quick feedback)
./mock-git-test.sh -m happy

# All scenarios including edge cases
./mock-git-test.sh -m all

# Debug mode with detailed output
./mock-git-test.sh -m all -d
```

### Phase 3: Integration E2E Tests

The integration phase tests complete workflows in real git repositories.

#### Test Repository Setup

**Isolated Test Environments:**
Each test runs in a clean, isolated git repository:

```bash
test-projects/
├── feature-workflow/     # Feature branch workflow
├── hotfix-workflow/      # Hotfix process testing
├── merge-conflicts/      # Conflict resolution
├── large-repo/          # Performance testing
└── multi-user/          # Collaboration scenarios
```

#### Workflow Testing

**Complete Git Workflows:**
- Feature development lifecycle
- Hotfix deployment process
- Release preparation and tagging
- Branch management operations
- Collaborative development scenarios

**Multi-Command Sequences:**
Tests validate that commands work together correctly:

```bash
# Example: Feature development workflow
1. claude-flow-git-checkout-feature "new-feature"
2. # Make changes
3. claude-flow-git-commit "Add new feature"
4. claude-flow-git-push-feature
5. # Create pull request
6. claude-flow-git-merge-feature
```

#### Performance Benchmarking

**Performance Metrics:**
- Command execution time
- Memory usage patterns
- Repository size impact
- Network operation efficiency

**Benchmark Targets:**
- Small repositories (< 100 files): < 2 seconds
- Medium repositories (100-1000 files): < 5 seconds
- Large repositories (> 1000 files): < 15 seconds

## CI/CD Integration

### Continuous Integration Setup

**Pre-commit Hooks:**
```bash
#!/bin/bash
# .git/hooks/pre-commit
cd test
./run-git-tests.sh -m quick --no-color
exit $?
```

**Build Pipeline Integration:**
The testing framework integrates with common CI/CD platforms:

**GitHub Actions:**
```yaml
- name: Git Commands Validation
  run: ./test/run-git-tests.sh -m ci -r junit
  
- name: Upload Test Results
  uses: actions/upload-artifact@v3
  with:
    name: git-test-results
    path: test/results/junit-results.xml
```

**Jenkins Pipeline:**
```groovy
stage('Git Commands Testing') {
    steps {
        sh './test/run-git-tests.sh -m ci -r junit'
        publishTestResults 'test/results/junit-results.xml'
    }
}
```

**GitLab CI:**
```yaml
git-commands-test:
  script:
    - ./test/run-git-tests.sh -m ci -r junit
  artifacts:
    reports:
      junit: test/results/junit-results.xml
```

### Test Result Reporting

**Console Output:**
Provides immediate feedback with color-coded results:
- ✅ Green: Passed tests
- ❌ Red: Failed tests  
- ⚠️ Yellow: Warnings
- ℹ️ Blue: Information

**JUnit XML:**
Standard format for CI/CD integration:
```xml
<testsuites>
  <testsuite name="static" tests="15" failures="0" time="12.3">
    <testcase name="validate_commit_cmd" time="1.2"/>
    <!-- ... -->
  </testsuite>
</testsuites>
```

**JSON Reports:**
Machine-readable format for analysis:
```json
{
  "timestamp": 1677123456,
  "test_mode": "full",
  "phases": {
    "static": {"result": "pass", "duration": 12},
    "mock": {"result": "pass", "duration": 45},
    "integration": {"result": "pass", "duration": 180}
  },
  "metrics": {
    "total_tests": 42,
    "passed": 42,
    "failed": 0
  }
}
```

## Edge Case Testing Methodology

### Systematic Edge Case Coverage

**Repository States:**
- Empty repositories (no commits)
- Repositories with conflicts
- Repositories with uncommitted changes
- Repositories with untracked files
- Repositories with submodules
- Bare repositories
- Corrupted repositories

**Git Operations:**
- Operations on non-existent branches
- Operations with network failures
- Operations with insufficient permissions
- Operations with large files
- Operations with binary files
- Concurrent operations

**User Input Scenarios:**
- Invalid command parameters
- Missing required parameters
- Extremely long inputs
- Special characters in inputs
- Multi-byte character inputs

### Edge Case Test Implementation

**Configuration-Driven Testing:**
Edge cases are defined in `test/config/edge-case-config.yaml`:

```yaml
edge_cases:
  repository_states:
    - name: "empty_repo"
      setup: "git init"
      description: "Repository with no commits"
    
    - name: "dirty_repo"
      setup: ["git init", "echo 'test' > file.txt"]
      description: "Repository with uncommitted changes"
  
  user_inputs:
    - category: "invalid_parameters"
      tests:
        - input: ""
          expected: "error"
        - input: "very_long_string_over_limit..."
          expected: "error"
```

**Automated Edge Case Generation:**
The framework automatically generates edge cases for:
- Parameter boundary values
- Invalid input combinations
- Resource exhaustion scenarios
- Timing-related edge cases

## Security Considerations

### Security Testing Framework

**Static Security Analysis:**
- Scan for hardcoded secrets
- Validate input sanitization
- Check for command injection vulnerabilities
- Verify proper error handling

**Runtime Security Testing:**
- Test with malicious inputs
- Validate file permission handling
- Check network security measures
- Test authentication mechanisms

### Security Best Practices

**Input Validation:**
All user inputs must be validated before processing:

```bash
# Example validation function
validate_branch_name() {
    local branch_name="$1"
    
    # Check for valid characters
    if [[ ! "$branch_name" =~ ^[a-zA-Z0-9._/-]+$ ]]; then
        echo "Error: Invalid branch name characters"
        return 1
    fi
    
    # Check length limits
    if [[ ${#branch_name} -gt 255 ]]; then
        echo "Error: Branch name too long"
        return 1
    fi
    
    return 0
}
```

**Command Injection Prevention:**
- Always quote variables in commands
- Use parameter arrays instead of string concatenation
- Validate all external inputs

**Permission Handling:**
- Check file permissions before operations
- Fail gracefully on permission errors
- Provide clear error messages

## Performance Benchmarking Guidelines

### Performance Testing Strategy

**Benchmark Categories:**
1. **Command Execution Speed**: Time from invocation to completion
2. **Memory Usage**: Peak memory consumption during execution
3. **I/O Performance**: File system and network operation efficiency
4. **Scalability**: Performance with increasing repository size

### Benchmark Implementation

**Performance Test Setup:**
```bash
# Generate test repositories of varying sizes
./test/lib/generate-test-repos.sh --sizes "small,medium,large"

# Run performance benchmarks
./test/run-git-tests.sh -m performance --benchmark
```

**Performance Metrics Collection:**
```bash
# Time measurement with nanosecond precision
start_time=$(date +%s%N)
# ... command execution ...
end_time=$(date +%s%N)
duration_ns=$((end_time - start_time))
duration_ms=$((duration_ns / 1000000))
```

**Memory Usage Monitoring:**
```bash
# Memory usage tracking
/usr/bin/time -v command_to_test 2>&1 | grep "Maximum resident set size"
```

### Performance Baselines

**Target Performance Metrics:**

| Repository Size | Command Execution | Memory Usage | Disk I/O |
|----------------|------------------|-------------|----------|
| Small (< 100 files) | < 2 seconds | < 50MB | < 10MB |
| Medium (100-1K files) | < 5 seconds | < 100MB | < 50MB |
| Large (> 1K files) | < 15 seconds | < 200MB | < 100MB |

**Performance Regression Detection:**
- Automatic comparison with previous benchmarks
- Alert on performance degradation > 20%
- Trend analysis for gradual performance decline

## Troubleshooting Guide

### Common Issues and Solutions

#### Test Execution Failures

**Problem: Static validation fails with "File not found" errors**
```
✗ ERROR [commit.md]: Referenced file does not exist: ../shared/hooks.md
```

**Solution:**
1. Check file paths in documentation
2. Verify relative path calculations
3. Ensure all referenced files exist

```bash
# Debug file references
./validate-git-commands.sh -v templates/commands/git/commit.md
```

**Problem: Mock tests fail with "Mock response not found"**
```
✗ ERROR: Mock response file git-status-clean.txt not found
```

**Solution:**
1. Check mock response files in `test/fixtures/mock-responses/`
2. Verify mock environment setup
3. Regenerate mock responses if needed

```bash
# Regenerate mock responses
./test/lib/generate-mock-responses.sh
```

#### Environment Issues

**Problem: Tests fail in CI environment**
```
Environment validation failed: timeout command not found
```

**Solution:**
1. Install required dependencies in CI
2. Use CI-specific test mode
3. Check environment variable configuration

```bash
# CI-optimized test execution
./run-git-tests.sh -m ci --no-timeout
```

**Problem: Permission errors during testing**
```
✗ ERROR: Permission denied accessing test directory
```

**Solution:**
1. Check directory permissions
2. Ensure test user has appropriate access
3. Run with appropriate user context

```bash
# Fix test directory permissions
chmod -R 755 test/
chmod +x test/*.sh
```

#### Performance Issues

**Problem: Tests are running slowly**
```
Integration tests taking > 30 minutes
```

**Solution:**
1. Use quick test mode for development
2. Enable parallel execution
3. Check system resources

```bash
# Quick test mode
./run-git-tests.sh -m quick

# Parallel execution
./run-git-tests.sh -j 8
```

### Debug Mode Usage

**Enable comprehensive debugging:**
```bash
# Full debug output
./run-git-tests.sh -d -v

# Debug specific phase
./run-git-tests.sh -p mock -d

# Debug with bash tracing
bash -x ./run-git-tests.sh -m full
```

**Debug output interpretation:**
- `[DEBUG]` lines show internal framework operations
- `[TRACE]` lines show command execution details
- `[MOCK]` lines show mock environment interactions

### Log Analysis

**Test log locations:**
```
test/results/          # Test execution results
test/tmp/             # Temporary files and debug logs
test/.cache/          # Cached test results
```

**Log file analysis:**
```bash
# Find failed tests
grep "✗\|ERROR" test/results/test-results-*.txt

# Analyze performance trends
grep "duration:" test/results/test-results-*.txt

# Check for specific errors
grep -i "permission\|timeout\|network" test/results/*.txt
```

## Best Practices for Adding New Tests

### Test Development Workflow

1. **Identify Testing Needs**
   - New command templates
   - Bug fixes requiring test coverage
   - Edge cases discovered in production

2. **Choose Appropriate Test Phase**
   - Static validation for documentation/structure
   - Mock testing for command logic
   - Integration testing for workflows

3. **Write the Test**
   - Follow existing test patterns
   - Include both positive and negative cases
   - Add comprehensive error handling

4. **Validate Test Quality**
   - Test passes consistently
   - Test fails appropriately for wrong inputs
   - Test provides clear failure messages

### Test Implementation Guidelines

**Static Validation Tests:**
```bash
# Add new validation rule
validate_new_rule() {
    local file="$1"
    
    # Check for specific pattern
    if ! grep -q "required_pattern" "$file"; then
        validation_error "Required pattern missing" "$file"
        return 1
    fi
    
    validation_success "Required pattern found"
    return 0
}
```

**Mock Execution Tests:**
```bash
# Add new mock scenario
test_new_scenario() {
    local test_name="new_scenario"
    print_test "Testing: $test_name"
    
    # Setup mock environment
    setup_mock_git_env
    
    # Configure mock responses
    set_mock_response "git status" "$(cat fixtures/mock-responses/git-status-clean.txt)"
    
    # Execute command
    if execute_mock_command "git-status"; then
        print_success "$test_name passed"
        return 0
    else
        print_error "$test_name failed"
        return 1
    fi
}
```

**Integration Tests:**
```bash
# Add new workflow test
test_new_workflow() {
    local test_name="new_workflow"
    print_test "Testing workflow: $test_name"
    
    # Create test repository
    local test_repo="test-projects/$test_name"
    create_test_repo "$test_repo"
    cd "$test_repo"
    
    # Execute workflow steps
    git init
    echo "test" > file.txt
    git add file.txt
    
    # Test the command
    if claude-flow-git-commit "Initial commit"; then
        print_success "$test_name workflow completed"
        return 0
    else
        print_error "$test_name workflow failed"
        return 1
    fi
}
```

### Test Maintenance

**Regular Review Tasks:**
- Update mock responses for new git versions
- Review and update performance baselines
- Remove obsolete tests
- Improve test coverage for edge cases

**Test Quality Metrics:**
- Test execution time should remain stable
- Test failure rate should be < 1% for stable code
- All tests should have clear documentation
- Test maintenance overhead should be minimal

**Automated Test Maintenance:**
```bash
# Automated test health check
./test/maintenance/health-check.sh

# Update performance baselines
./test/maintenance/update-baselines.sh

# Clean up obsolete test data
./test/maintenance/cleanup.sh
```

## Framework Architecture Details

### Test Runner Architecture

The test runner orchestrates all testing phases:

```
run-git-tests.sh (Main Controller)
├── Phase 1: validate-git-commands.sh
├── Phase 2: mock-git-test.sh
└── Phase 3: integration-git-test.sh

Supporting Libraries:
├── lib/command-validator.sh    # Static validation logic
├── lib/mock-environment.sh     # Mock testing framework
├── lib/integration-environment.sh # E2E test setup
└── lib/test-reporter.sh        # Result reporting
```

### Extensibility Points

**Adding New Validation Rules:**
Extend `lib/command-validator.sh` with new validation functions:

```bash
# Add to validation pipeline
validate_command_file() {
    # ... existing validations ...
    validate_new_custom_rule "$file"
}
```

**Adding New Mock Scenarios:**
Extend `mock-git-test.sh` with new test scenarios:

```bash
# Add to test suite
run_mock_tests() {
    # ... existing tests ...
    test_new_custom_scenario
}
```

**Adding New Integration Workflows:**
Extend `integration-git-test.sh` with new workflows:

```bash
# Add to integration suite
run_integration_tests() {
    # ... existing tests ...
    test_new_custom_workflow
}
```

This comprehensive testing framework ensures the reliability, security, and performance of Claude Flow git command templates while providing clear feedback to developers and maintainers.