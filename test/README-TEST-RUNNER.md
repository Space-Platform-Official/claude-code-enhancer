# Claude Flow Git Command Test Runner Framework

A comprehensive testing framework for Claude Flow git commands supporting static validation, mock execution, and integration testing with CI/CD integration.

## Overview

The test runner orchestrates three phases of testing:

1. **Static Validation** - Analyzes command structure, syntax, and security
2. **Mock Execution** - Simulates git operations with controlled responses  
3. **Integration Testing** - Real end-to-end testing with actual git repositories

## Quick Start

```bash
# Run complete test suite
./run-git-tests.sh

# Quick validation for development
./run-git-tests.sh -m quick

# Run specific phase
./run-git-tests.sh -p static

# Debug mode with verbose output
./run-git-tests.sh -m debug -d
```

## Test Framework Components

### Core Files

- **`run-git-tests.sh`** - Main test orchestrator
- **`lib/test-reporter.sh`** - Test result reporting and metrics
- **`config/test-config.yaml`** - Test configuration and settings
- **`.github/workflows/git-commands-test.yml`** - GitHub Actions CI workflow

### Test Scripts

- **`validate-git-commands.sh`** - Phase 1: Static validation
- **`mock-git-test.sh`** - Phase 2: Mock execution testing  
- **`integration-git-test.sh`** - Phase 3: Integration E2E testing

## Test Modes

### Quick Mode (`-m quick`)
- **Duration**: ~30 seconds
- **Phases**: Static validation + Essential mock tests
- **Use Case**: Fast feedback during development

### Full Mode (`-m full`) - Default
- **Duration**: ~5-10 minutes
- **Phases**: All three phases with comprehensive coverage
- **Use Case**: Pre-commit validation, PR checks

### Debug Mode (`-m debug`)  
- **Duration**: ~15-20 minutes
- **Phases**: All phases with verbose output and extended timeouts
- **Use Case**: Troubleshooting test failures

### CI Mode (`-m ci`)
- **Duration**: ~8-12 minutes
- **Phases**: Optimized for CI/CD environments
- **Use Case**: Automated testing in pipelines

## Test Phases

### Phase 1: Static Validation

**Purpose**: Validate command structure, security, and compliance

**What it tests**:
- Command frontmatter and schema compliance
- Security patterns and command injection prevention
- Cross-reference validation and circular dependencies
- Git-specific command requirements

**Example**:
```bash
# Run only static validation
./run-git-tests.sh -p static

# Run with security focus
./validate-git-commands.sh -s
```

### Phase 2: Mock Execution

**Purpose**: Test command behavior without real git operations

**What it tests**:
- Happy path workflows (normal operations)
- Error conditions and failure handling
- Edge cases and boundary conditions
- Argument substitution and validation
- Command flow and state transitions

**Example**:
```bash
# Run only mock tests
./run-git-tests.sh -p mock

# Run specific test categories
./mock-git-test.sh -m happy
./mock-git-test.sh -m error
```

### Phase 3: Integration Testing

**Purpose**: End-to-end testing with real git repositories

**What it tests**:
- Feature development workflows
- Conflict resolution scenarios
- Team collaboration patterns
- Performance with large repositories
- Cross-platform compatibility

**Example**:
```bash
# Run only integration tests
./run-git-tests.sh -p integration

# Run specific workflow tests
./integration-git-test.sh -m workflow
```

## Configuration

### Test Configuration (`test/config/test-config.yaml`)

```yaml
# Test execution profiles
profiles:
  quick:
    phases: [static, mock]
    timeout_minutes: 10
  full:
    phases: [static, mock, integration]
    timeout_minutes: 30
    
# Resource limits
resources:
  cpu:
    max_cores: 4
  memory:
    max_mb: 2048
    
# Performance baselines
performance:
  regression_threshold_percent: 20
```

## Reporting

### Console Output (Default)

```bash
=== Test Execution Report ===
Test Mode: full
Total Duration: 287s
Parallel Jobs: 4

📋 Phase Results
static:              ✓ pass           12s
mock:                ✓ pass           45s  
integration:         ✓ pass          230s

📈 Detailed Metrics
Static Validation:
  Errors: 0
  Warnings: 2

Mock Execution:
  Total Tests: 24
  Passed: 24
  Failed: 0
  Skipped: 0

Integration Tests:
  Total Tests: 12
  Passed: 11
  Failed: 0
  Skipped: 1
```

### JUnit XML (For CI)

```bash
# Generate JUnit XML report
./run-git-tests.sh -r junit

# Output: test/results/junit-results.xml
```

### JSON Report

```bash
# Generate JSON report
./run-git-tests.sh -r json

# Output: test/results/test-results-{timestamp}.json
```

## CI/CD Integration

### GitHub Actions

The framework includes a comprehensive GitHub Actions workflow:

```yaml
# .github/workflows/git-commands-test.yml
name: Git Commands Test Suite

on:
  push:
    branches: [main, develop]
    paths: ['templates/commands/git/**', 'test/**']
  pull_request:
    branches: [main, develop]
```

**Features**:
- Matrix testing across multiple OS versions
- Parallel execution of test phases
- Automatic retry on transient failures
- Performance regression detection
- Test result aggregation and reporting
- PR comment integration

### Integration with Other CI Systems

```bash
# Jenkins
./run-git-tests.sh -m ci -r junit

# GitLab CI
./run-git-tests.sh -m ci --no-color -r junit

# Custom CI
CI=true ./run-git-tests.sh -m ci
```

## Development Workflow

### Pre-commit Testing

```bash
# Quick validation before commit
./run-git-tests.sh -m quick

# Full validation for important changes
./run-git-tests.sh -m full
```

### Debugging Test Failures

```bash
# Run in debug mode
./run-git-tests.sh -m debug -d

# Test specific component
./run-git-tests.sh -p static -d
./validate-git-commands.sh -f templates/commands/git/commit.md

# Check specific test
./mock-git-test.sh -t normal_commit_workflow -d
```

### Adding New Tests

1. **Static Tests**: Add validation rules in `lib/command-validator.sh`
2. **Mock Tests**: Add test functions in `mock-git-test.sh`
3. **Integration Tests**: Add scenarios in `scenarios/git-workflows.sh`

## Performance Optimization

### Parallel Execution

```bash
# Use more parallel jobs
./run-git-tests.sh -j 8

# Disable parallelization for debugging
./run-git-tests.sh -j 1
```

### Test Caching

```bash
# Enable caching (default)
./run-git-tests.sh

# Disable caching for fresh run
./run-git-tests.sh --no-cache

# Clear cache
rm -rf test/.cache
```

### Performance Monitoring

The framework tracks performance metrics and detects regressions:

- Test execution times
- Memory usage patterns
- Comparison with historical baselines
- Automatic alerts for significant slowdowns

## Troubleshooting

### Common Issues

**1. Static Validation Failures**
```bash
# Check specific command file
./validate-git-commands.sh -f templates/commands/git/commit.md

# Run security-only validation
./validate-git-commands.sh -s
```

**2. Mock Test Failures**
```bash
# Run specific test category
./mock-git-test.sh -m error -d

# List available tests
./mock-git-test.sh -l
```

**3. Integration Test Issues**
```bash
# Run with clean environment
./integration-git-test.sh --ci

# Check Claude Code availability
./integration-git-test.sh -n  # dry run
```

**4. Environment Issues**
```bash
# Check dependencies
./run-git-tests.sh --help

# Verify test environment
./run-git-tests.sh -p static --no-cache
```

### Debug Modes

- `-d, --debug`: Enable debug output
- `-v, --verbose`: Enable verbose output  
- `--no-color`: Disable colored output
- `--no-cache`: Disable result caching
- `--no-retry`: Disable automatic retries

## Advanced Features

### Test Selection

```bash
# Run specific phases
./run-git-tests.sh -p static -p mock

# Run with custom jobs
./run-git-tests.sh -j 8 -m full

# Run with specific report format
./run-git-tests.sh -r json -m full
```

### Performance Profiling

```bash
# Enable performance monitoring
VERBOSE=true ./run-git-tests.sh -m full

# Check performance regression  
./run-git-tests.sh --check-performance
```

### Integration with Development Tools

```bash
# Git hooks integration
echo "./run-git-tests.sh -m quick" > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# IDE integration (VS Code tasks.json)
{
  "label": "Run Git Command Tests",
  "type": "shell",
  "command": "./run-git-tests.sh",
  "args": ["-m", "quick"]
}
```

## Contributing

### Adding New Test Scenarios

1. **Static Validation**: Extend `lib/command-validator.sh`
2. **Mock Testing**: Add functions to `mock-git-test.sh`
3. **Integration Testing**: Create scenarios in `scenarios/`
4. **Configuration**: Update `config/test-config.yaml`

### Best Practices

- Keep tests fast and focused
- Use meaningful test names
- Include both positive and negative test cases
- Document test scenarios and expected outcomes
- Use appropriate test isolation
- Follow existing patterns and conventions

## Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed  
- `2` - Configuration or environment error

## Environment Variables

- `CI` - Enables CI mode automatically
- `GITHUB_ACTIONS` - Detected automatically
- `TEST_CACHE_DIR` - Override cache directory
- `TEST_RESULTS_DIR` - Override results directory

## Version Compatibility

- **Bash**: 4.0+ (macOS compatible)
- **Git**: 2.25.0+
- **Optional**: GNU Parallel, timeout, jq

---

For more information, see the individual test script documentation:
- [`validate-git-commands.sh`](README.md) - Static validation
- [`mock-git-test.sh`](README-MOCK-TESTING.md) - Mock execution testing
- [Integration testing scenarios](scenarios/README.md) - E2E workflows