# Claude Flow Testing Framework

A comprehensive testing suite for validating Claude Flow command templates, installation scripts, and git workflows.

## Quick Start

```bash
# Run complete test suite
cd test
./run-git-tests.sh

# Quick validation (< 2 minutes)
./run-git-tests.sh -m quick

# Validate specific git commands
./validate-git-commands.sh
```

## Testing Framework Overview

The Claude Flow Testing Framework provides three complementary testing approaches:

### 🔍 Three-Phase Testing Strategy

1. **Phase 1: Static Validation** (< 30 seconds)
   - Command structure and documentation validation
   - YAML frontmatter compliance
   - Cross-reference integrity
   - Security considerations

2. **Phase 2: Mock Execution** (1-3 minutes)
   - Command logic testing with simulated responses
   - Error handling validation
   - User interaction patterns
   - Edge case coverage

3. **Phase 3: Integration E2E** (5-15 minutes)
   - Complete workflow testing in real repositories
   - Multi-command sequences
   - Performance benchmarking
   - Cross-platform compatibility

## Directory Structure

```
test/
├── README.md                     # This overview (framework guide)
├── TESTING-CHECKLIST.md         # Pre-deployment validation checklist
├── run-git-tests.sh             # Main test orchestrator
├── validate-test-framework.sh   # Self-validation script
│
├── config/                      # Test configuration
│   ├── test-config.yaml        # Main test configuration
│   └── edge-case-config.yaml   # Edge case definitions
│
├── lib/                         # Core testing libraries
│   ├── command-validator.sh     # Static validation engine
│   ├── mock-environment.sh      # Mock execution framework
│   ├── integration-environment.sh # E2E test environment
│   ├── security-validator.sh    # Security testing
│   └── test-reporter.sh         # Result reporting
│
├── fixtures/                    # Test data and mock responses
│   └── mock-responses/          # Git command mock outputs
│
├── scenarios/                   # Test scenario definitions
│   ├── git-workflows.sh        # Git workflow tests
│   ├── edge-cases.sh           # Edge case scenarios
│   └── security-edge-cases.sh  # Security-focused tests
│
├── results/                     # Test execution results
└── tmp/                        # Temporary test data
```

## Test Execution Modes

### Development Mode
For active development and debugging:

```bash
# Quick feedback during development
./run-git-tests.sh -m quick -v

# Debug specific issues
./run-git-tests.sh -m debug -p static

# Test single command template
./validate-git-commands.sh templates/commands/git/commit.md
```

### CI/CD Mode
Optimized for continuous integration:

```bash
# CI-optimized execution
./run-git-tests.sh -m ci -r junit

# Parallel execution for speed
./run-git-tests.sh -m full -j 8

# No-cache mode for clean results
./run-git-tests.sh --no-cache
```

### Production Validation
Comprehensive testing before release:

```bash
# Full test suite with all validations
./run-git-tests.sh -m full -v

# Performance benchmarking included
./run-git-tests.sh -m full --benchmark

# Generate comprehensive reports
./run-git-tests.sh -m full -r json
```

## Command Reference

### Main Test Runner

```bash
./run-git-tests.sh [OPTIONS]

Options:
  -m, --mode MODE       Test mode: quick|full|debug|ci (default: full)
  -p, --phase PHASE     Run specific phase: static|mock|integration
  -j, --jobs N          Number of parallel jobs (default: 4)
  -v, --verbose         Enable verbose output
  -d, --debug           Enable debug mode
  -r, --report FORMAT   Report format: console|junit|json
  --no-cache           Disable result caching
  --no-retry           Disable automatic retry on failures
  --no-color           Disable colored output
```

### Static Validation

```bash
./validate-git-commands.sh [FILE]

# Validate all git commands
./validate-git-commands.sh

# Validate specific command
./validate-git-commands.sh templates/commands/git/commit.md

# Verbose validation with details
./validate-git-commands.sh -v

# Check for circular dependencies
./validate-git-commands.sh --check-deps
```

### Mock Testing

```bash
./mock-git-test.sh [OPTIONS]

Options:
  -m, --mode MODE       Test mode: happy|all|stress
  -d, --debug           Enable debug output
  -s, --scenario NAME   Run specific scenario
  --list-scenarios     List available test scenarios
```

### Integration Testing

```bash
./integration-git-test.sh [OPTIONS]

Options:
  -m, --mode MODE       Test mode: workflow|all|performance
  -w, --workflow NAME   Run specific workflow
  --list-workflows     List available workflows
  --benchmark          Include performance benchmarks
```

## Writing Tests

### Adding Static Validation Rules

Extend `lib/command-validator.sh`:

```bash
# Add new validation function
validate_custom_rule() {
    local file="$1"
    
    validation_info "Validating custom rule: $(basename "$file")"
    
    # Your validation logic here
    if ! grep -q "required_pattern" "$file"; then
        validation_error "Custom rule violation" "$file"
        return 1
    fi
    
    validation_success "Custom rule passed"
    return 0
}

# Add to main validation pipeline
validate_command_file() {
    # ... existing validations ...
    validate_custom_rule "$file"
}
```

### Adding Mock Test Scenarios

Extend `scenarios/git-workflows.sh`:

```bash
test_custom_scenario() {
    local scenario_name="custom_git_operation"
    print_test "Testing: $scenario_name"
    
    # Setup mock environment
    setup_mock_environment
    
    # Configure expected responses
    set_mock_response "git status" "$(cat fixtures/mock-responses/git-status-clean.txt)"
    set_mock_response "git commit" "$(cat fixtures/mock-responses/git-commit-success.txt)"
    
    # Execute test
    if execute_mock_command "custom-git-operation"; then
        print_success "$scenario_name passed"
        return 0
    else
        print_error "$scenario_name failed"
        return 1
    fi
}
```

### Adding Integration Workflows

Extend `scenarios/git-workflows.sh`:

```bash
test_custom_workflow() {
    local workflow_name="custom_development_flow"
    print_test "Testing workflow: $workflow_name"
    
    # Create isolated test repository
    local test_repo="test-projects/$workflow_name"
    create_test_repository "$test_repo"
    cd "$test_repo"
    
    # Setup initial state
    git init
    echo "# Custom Project" > README.md
    git add README.md
    git commit -m "Initial commit"
    
    # Execute workflow steps
    if ! claude-flow-git-create-branch "feature/custom"; then
        print_error "Failed to create feature branch"
        return 1
    fi
    
    # Add workflow validation
    echo "New feature code" > feature.txt
    git add feature.txt
    
    if ! claude-flow-git-commit "Add custom feature"; then
        print_error "Failed to commit changes"
        return 1
    fi
    
    print_success "$workflow_name completed successfully"
    return 0
}
```

## Integration with Development Workflow

### Pre-commit Hooks

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Validate git commands before commit
cd test
if ! ./run-git-tests.sh -m quick --no-color; then
    echo "❌ Git command validation failed!"
    echo "Run './test/run-git-tests.sh -v' for details"
    exit 1
fi
echo "✅ Git command validation passed"
```

### IDE Integration

**VS Code Tasks** (`.vscode/tasks.json`):

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Validate Git Commands",
            "type": "shell",
            "command": "./test/run-git-tests.sh",
            "args": ["-m", "quick", "-v"],
            "group": "test",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "panel": "new"
            }
        }
    ]
}
```

### GitHub Actions Integration

**`.github/workflows/test-git-commands.yml`**:

```yaml
name: Git Commands Testing
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test-git-commands:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Test Environment
      run: |
        chmod +x test/*.sh
        chmod +x test/lib/*.sh
    
    - name: Run Static Validation
      run: ./test/run-git-tests.sh -p static -r junit
    
    - name: Run Mock Tests
      run: ./test/run-git-tests.sh -p mock -r junit
    
    - name: Run Integration Tests
      run: ./test/run-git-tests.sh -p integration -r junit
    
    - name: Upload Test Results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results
        path: test/results/
    
    - name: Publish Test Results
      uses: dorny/test-reporter@v1
      if: always()
      with:
        name: Git Commands Tests
        path: test/results/junit-results.xml
        reporter: java-junit
```

## Performance Monitoring

### Benchmark Execution

```bash
# Run performance benchmarks
./run-git-tests.sh -m full --benchmark

# Monitor performance trends
./test/lib/performance-monitor.sh --analyze

# Generate performance report
./test/lib/performance-monitor.sh --report
```

### Performance Baselines

| Repository Size | Target Time | Memory Limit | 
|-----------------|-------------|--------------|
| Small (< 100 files) | < 2s | < 50MB |
| Medium (100-1K files) | < 5s | < 100MB |
| Large (> 1K files) | < 15s | < 200MB |

## Troubleshooting

### Common Issues

**Tests failing in CI but passing locally:**
```bash
# Use CI mode to replicate environment
./run-git-tests.sh -m ci --no-color

# Check for timing issues
./run-git-tests.sh --no-retry -v
```

**Mock tests not finding responses:**
```bash
# Verify mock response files
ls -la test/fixtures/mock-responses/

# Regenerate mock responses
./test/lib/generate-mock-responses.sh
```

**Integration tests taking too long:**
```bash
# Use quick mode for development
./run-git-tests.sh -m quick

# Enable parallel execution
./run-git-tests.sh -j 8
```

### Debug Mode

```bash
# Enable comprehensive debugging
./run-git-tests.sh -d -v

# Debug specific phase
./run-git-tests.sh -p mock -d

# Bash trace debugging
bash -x ./run-git-tests.sh
```

## Contributing to Tests

### Test Quality Guidelines

1. **Clear Test Names**: Use descriptive names that explain what is being tested
2. **Isolated Tests**: Each test should be independent and not rely on others
3. **Comprehensive Coverage**: Include both positive and negative test cases
4. **Performance Aware**: Keep test execution time reasonable
5. **Documentation**: Document complex test scenarios and edge cases

### Test Review Checklist

- [ ] Test passes consistently (run 5+ times)
- [ ] Test fails appropriately for invalid inputs
- [ ] Test provides clear error messages
- [ ] Test follows established patterns
- [ ] Test includes proper cleanup
- [ ] Test documentation is complete

### Adding New Test Categories

1. **Identify Gap**: Determine what aspect needs testing coverage
2. **Design Tests**: Plan test scenarios and expected outcomes
3. **Implement**: Write tests following framework patterns
4. **Validate**: Ensure tests work correctly and provide value
5. **Document**: Add to appropriate documentation and checklists

## Framework Maintenance

### Regular Maintenance Tasks

**Weekly:**
- Review test execution performance
- Check for flaky tests
- Update mock responses if needed

**Monthly:**
- Review and update performance baselines
- Clean up obsolete test data
- Analyze test coverage gaps

**Quarterly:**
- Comprehensive framework review
- Update documentation
- Evaluate new testing requirements

### Framework Health Monitoring

```bash
# Framework self-validation
./validate-test-framework.sh

# Performance trend analysis
./test/lib/analyze-performance-trends.sh

# Test coverage analysis
./test/lib/coverage-analysis.sh
```

This testing framework ensures the reliability and quality of Claude Flow while providing developers with fast feedback and confidence in their changes.