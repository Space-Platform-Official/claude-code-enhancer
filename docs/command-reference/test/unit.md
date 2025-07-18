# Unit Test Command Reference

**Command**: `/test/unit`  
**Category**: Testing  
**Description**: Unit test execution with comprehensive coverage analysis and parallel agent coordination

## Overview

The `/test/unit` command provides comprehensive unit test execution with framework-specific optimizations, parallel agent coordination, and extensive coverage analysis. This command ensures code quality through thorough unit testing with intelligent failure analysis and performance optimization.

## Usage Patterns

```bash
# Comprehensive unit test execution
/test/unit

# Execute tests for specific directory
/test/unit src/components/

# Execute with specific test files
/test/unit tests/unit/auth.test.js

# Parallel execution with custom agent count
/test/unit --parallel --agents=8

# Coverage-focused execution
/test/unit --coverage --threshold=80

# Watch mode for continuous testing
/test/unit --watch

# Performance-optimized execution
/test/unit --fast --skip-slow
```

## Command Syntax

```bash
/test/unit [target] [options]
```

### Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| `target` | Test target (files/directories) | `src/`, `tests/unit/auth.test.js` |

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--parallel` | Enable parallel agent execution | true |
| `--agents=N` | Number of parallel agents | 4 |
| `--coverage` | Generate coverage reports | true |
| `--threshold=N` | Coverage threshold percentage | 80 |
| `--watch` | Continuous test execution | false |
| `--fast` | Skip slow tests | false |
| `--skip-slow` | Exclude tests marked as slow | false |
| `--framework=<name>` | Force specific test framework | auto-detect |
| `--verbose` | Detailed output | false |
| `--dry-run` | Preview without execution | false |
| `--no-php` | Skip PHP-specific behaviors | false |
| `--skip-php-structure-check` | Skip PHP structure validation | false |

## PHP Structure Control

The command includes comprehensive PHP structure control mechanisms:

### Control Methods

1. **Environment Variable**:
   ```bash
   export CLAUDE_PHP_TESTS=false
   ```

2. **Project Files**:
   ```bash
   touch .claude/no-php-tests
   # OR
   touch .no-php-structure
   ```

3. **Command Flags**:
   ```bash
   /test/unit --no-php                     # Skip all PHP features
   /test/unit --skip-php-structure-check   # Skip structure validation only
   ```

### PHP Framework Support

When PHP projects are detected, the command validates comprehensive test structure:

- **Laravel**: `tests/Unit/`, `tests/Feature/`, framework-specific optimizations
- **Symfony**: Symfony test bundle integration and configuration
- **Pure PHP**: PHPUnit configuration and test organization

## Multi-Agent Coordination

The command leverages advanced multi-agent spawning for optimal performance:

### Agent Spawning Strategy

```bash
"I'll spawn multiple agents to execute unit tests comprehensively:
- Fast Test Agent: Execute quick unit tests for immediate feedback
- Slow Test Agent: Execute complex unit tests with detailed analysis
- Coverage Agent: Analyze test coverage and identify gaps
- Quality Agent: Validate test quality and suggest improvements
- Reporting Agent: Generate comprehensive test reports and metrics"
```

### Agent Coordination Patterns

1. **Parallel Test Execution**
   - Agent 1: Core module unit tests
   - Agent 2: Utility and helper function tests
   - Agent 3: Service layer tests
   - Agent 4: Integration boundary tests

2. **Coverage Analysis Coordination**
   - Agent 1: Statement coverage analysis
   - Agent 2: Branch coverage analysis
   - Agent 3: Function coverage analysis
   - Agent 4: Gap identification and reporting

3. **Quality Validation Coordination**
   - Agent 1: Test structure validation
   - Agent 2: Assertion quality checks
   - Agent 3: Mock usage analysis
   - Agent 4: Performance impact assessment

## Framework Detection and Support

### Supported Frameworks

| Framework | Detection | Command | Configuration |
|-----------|-----------|---------|---------------|
| **Jest** | `package.json` + jest config | `npx jest` | `jest.config.js` |
| **pytest** | `pytest.ini` or Python files | `python -m pytest` | `pytest.ini` |
| **Go test** | `*_test.go` files | `go test` | `go.mod` |
| **RSpec** | `spec/` directory + Gemfile | `bundle exec rspec` | `.rspec` |
| **PHPUnit** | `phpunit.xml` + composer | `./vendor/bin/phpunit` | `phpunit.xml` |
| **Mocha** | `test/` + package.json | `npx mocha` | `mocha.opts` |
| **JUnit** | `pom.xml` + Java files | `mvn test` | `pom.xml` |

### Framework-Specific Optimizations

**Jest Optimizations**:
```bash
# Parallel execution with optimal worker count
npx jest --coverage --maxWorkers=4 --verbose --testPathPattern="test|spec"

# Performance options
--onlyChanged    # Run only changed files
--bail          # Stop on first failure
--cache         # Use test cache
```

**pytest Optimizations**:
```bash
# Parallel execution with pytest-xdist
python -m pytest -v --cov=. --cov-report=html --cov-report=term -n 4

# Performance options  
--lf            # Run last failed tests first
--durations=10  # Show slowest tests
--tb=short      # Shorter traceback format
```

**Go Test Optimizations**:
```bash
# Race detection and coverage
go test -v -race -coverprofile=coverage.out ./...

# Performance options
-parallel N     # Parallel test execution
-short         # Skip long-running tests
-count=1       # Disable test caching
```

## Test Discovery and Categorization

### Test File Discovery

The command automatically discovers test files based on framework patterns:

```bash
# Jest/Mocha patterns
*.test.js, *.spec.js, *.test.ts, *.spec.ts

# pytest patterns  
test_*.py, *_test.py

# Go test patterns
*_test.go

# RSpec patterns
*_spec.rb

# PHPUnit patterns
*Test.php, *test.php
```

### Test Categorization

Tests are automatically categorized for optimal execution:

```bash
# Speed-based categorization
Fast Tests: < 5KB file size, simple assertions
Slow Tests: > 5KB file size, complex logic

# Complexity-based categorization  
Simple: Basic unit tests with minimal dependencies
Complex: Tests with mocks, external dependencies
Integration: Tests that cross module boundaries
```

## Coverage Analysis

### Comprehensive Coverage Reports

The command generates multi-format coverage reports:

```bash
# Coverage report formats
📊 HTML Report: Detailed visual coverage analysis
📈 Terminal Report: Command-line coverage summary  
📋 JSON Report: Machine-readable coverage data
📄 XML Report: CI/CD integration format
```

### Coverage Metrics

Tracks multiple coverage dimensions:

```bash
# Coverage dimensions
📝 Statement Coverage: Lines of code executed
🌿 Branch Coverage: Decision branches taken
🔧 Function Coverage: Functions called
📂 File Coverage: Files with any coverage
```

### Gap Identification

Automatically identifies coverage gaps:

```bash
# Gap analysis includes
🎯 Uncovered lines with context
🔍 Missing branch coverage
❌ Untested functions
📁 Files without any tests
💡 Suggestions for improvement
```

## Quality Validation

### Test Quality Metrics

Validates test quality against best practices:

```bash
# Quality validation areas
✅ Test structure (describe/it blocks)
✅ Assertion presence and quality
✅ Mock usage patterns
✅ Test isolation validation
✅ Performance impact assessment
✅ Documentation coverage
```

### Best Practice Enforcement

```bash
# Enforced best practices
🏗️ AAA Pattern: Arrange, Act, Assert
🔒 Test Isolation: No shared state between tests
📝 Descriptive Names: Clear test descriptions
🎯 Single Responsibility: One assertion per test
🚫 No Logic: Tests should be simple and clear
```

## Failure Analysis

### Intelligent Failure Detection

Comprehensive failure analysis with actionable insights:

```bash
# Failure analysis components
❌ Failed test identification
🔍 Root cause analysis
📊 Failure pattern recognition
💡 Fix suggestions
🔄 Retry recommendations
```

### Framework-Specific Failure Parsing

Each framework gets specialized failure analysis:

```bash
# Jest failure analysis
- Parse Jest error output
- Extract assertion failures
- Identify async/await issues
- Highlight mock problems

# pytest failure analysis  
- Parse pytest traceback
- Extract assertion errors
- Identify fixture issues
- Highlight parametrized test failures
```

## Performance Optimization

### Execution Performance

Optimized for speed and efficiency:

```bash
# Performance optimizations
⚡ Parallel agent coordination
🔄 Incremental test execution
💾 Test result caching
🎯 Smart test selection
📊 Resource usage monitoring
```

### Framework Performance Tips

Context-aware performance recommendations:

```bash
# Jest performance tips
--maxWorkers=N     # Optimize worker count
--onlyChanged      # Test only changed files
--bail            # Stop on first failure

# pytest performance tips
-n auto           # Optimal parallel execution
--lf              # Run last failed first
--durations=10    # Identify slow tests
```

## Workflow Examples

### Basic Unit Test Execution

```bash
# Comprehensive unit testing
/test/unit

# Process flow:
# 1. Framework detection and validation
# 2. Test structure validation (respecting PHP opt-out)
# 3. Multi-agent spawning for parallel execution
# 4. Test discovery and categorization  
# 5. Parallel test execution with coverage
# 6. Quality validation and reporting
# 7. Failure analysis and recommendations
```

### Coverage-Focused Testing

```bash
# High-coverage testing
/test/unit --coverage --threshold=90

# Enhanced coverage process:
# 1. Execute all tests with coverage tracking
# 2. Generate comprehensive coverage reports
# 3. Identify coverage gaps with line-level detail
# 4. Provide specific recommendations
# 5. Validate against coverage thresholds
```

### Performance-Optimized Testing

```bash
# Fast feedback loop
/test/unit --fast --agents=8

# Performance optimization:
# 1. Skip slow tests for quick feedback
# 2. Maximize parallel execution
# 3. Use test caching when available
# 4. Focus on changed code areas
# 5. Provide performance metrics
```

## Error Handling

### Common Error Scenarios

1. **Framework Not Found**
   ```bash
   ❌ No test framework detected
   
   # Resolution
   → Install framework: npm install --save-dev jest
   → Create config: jest.config.js
   → Add test scripts to package.json
   ```

2. **Test Structure Issues**
   ```bash
   ❌ Missing test directory structure
   
   # Resolution for PHP projects
   → Run: /test/structure
   → Or disable: --skip-php-structure-check
   → Or use: --no-php for non-PHP projects
   ```

3. **Coverage Threshold Failures**
   ```bash
   ❌ Coverage below threshold (75% < 80%)
   
   # Resolution
   → Identify uncovered areas
   → Add missing tests
   → Review coverage gaps report
   ```

### Recovery Procedures

Automated recovery suggestions for common issues:

```bash
# Test failure recovery
1. Analyze failure patterns
2. Suggest specific fixes
3. Provide debugging commands
4. Offer re-run strategies
5. Recommend testing improvements
```

## Integration Features

### CI/CD Integration

Optimized for continuous integration environments:

```bash
# CI-friendly options
--no-watch        # Disable watch mode
--coverage        # Generate coverage reports
--junit-xml       # Generate JUnit XML reports
--parallel        # Maximize CI resources
```

### IDE Integration

Support for development environment integration:

```bash
# IDE support features  
📍 Test result linking to source files
🔍 Coverage highlighting in editors
⚡ Quick test execution from IDE
📊 Real-time coverage feedback
```

## Related Commands

- **[/test/integration](integration.md)** - Integration testing with service orchestration
- **[/test/e2e](e2e.md)** - End-to-end testing workflows
- **[/test/coverage](coverage.md)** - Comprehensive coverage analysis
- **[/test/performance](performance.md)** - Performance testing and benchmarking
- **[/quality/verify](../quality/verify.md)** - Quality verification

## Best Practices

### Unit Testing Excellence

1. **Comprehensive Coverage**: Aim for high coverage with meaningful tests
2. **Test Quality**: Focus on test clarity and maintainability  
3. **Parallel Execution**: Leverage multi-agent coordination
4. **Continuous Feedback**: Use watch mode during development
5. **Framework Optimization**: Use framework-specific optimizations

### Performance Best Practices

1. **Smart Execution**: Use parallel agents effectively
2. **Incremental Testing**: Test only what changed when possible
3. **Resource Management**: Monitor and optimize resource usage
4. **Caching**: Leverage test result caching
5. **Profiling**: Regular performance analysis

### Quality Assurance

1. **Validate Structure**: Ensure proper test organization
2. **Check Coverage**: Maintain coverage thresholds
3. **Analyze Failures**: Always investigate test failures
4. **Review Quality**: Regular test quality assessment
5. **Continuous Improvement**: Act on recommendations

---

*The `/test/unit` command provides comprehensive unit testing with framework-specific optimizations, multi-agent coordination, and extensive quality validation for reliable code quality assurance.*