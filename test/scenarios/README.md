# Claude Flow Edge Case Testing Framework

This comprehensive edge case testing framework validates the robustness and security of Claude Flow git commands under various unusual and challenging conditions.

## Overview

The edge case testing framework consists of 5 specialized test suites that systematically test different categories of edge cases:

1. **Git State Edge Cases** - Repository state anomalies
2. **Input Validation Edge Cases** - Malformed and malicious inputs  
3. **Environment Edge Cases** - Platform and environment variations
4. **Security Edge Cases** - Security vulnerabilities and attack vectors
5. **Main Test Runner** - Orchestrates all test categories

## Test Files

### Core Files

- **`edge-cases.sh`** - Main test runner and orchestrator
- **`git-state-edge-cases.sh`** - Git repository state testing
- **`input-validation-edge-cases.sh`** - Input validation and sanitization
- **`environment-edge-cases.sh`** - Environmental condition testing
- **`security-edge-cases.sh`** - Security vulnerability assessment

### Configuration

- **`../config/edge-case-config.yaml`** - Comprehensive configuration file

## Test Categories

### 1. Git State Edge Cases (`git-state-edge-cases.sh`)

Tests various unusual git repository states:

- **Empty repositories** (freshly initialized, no commits)
- **Detached HEAD state** and orphaned commits
- **Merge conflicts** and unresolved states
- **Corrupted repositories** (damaged HEAD, missing objects, corrupted index)
- **Large repositories** with performance implications
- **Permission issues** (read-only files, restricted directories)
- **Submodule edge cases** (missing submodules, broken references)

### 2. Input Validation Edge Cases (`input-validation-edge-cases.sh`)

Tests input handling and sanitization:

- **Empty and null inputs** (empty strings, null bytes, whitespace-only)
- **Special characters** (Unicode, emojis, control characters)
- **Command injection attempts** (shell metacharacters, environment variables)
- **Boundary conditions** (extremely long inputs, numeric limits)
- **Path manipulation** (directory traversal, symlink attacks)
- **Argument parsing** (malformed arguments, environment injection)
- **Unicode handling** (normalization issues, encoding problems)

### 3. Environment Edge Cases (`environment-edge-cases.sh`)

Tests environmental conditions and platform differences:

- **Missing dependencies** (git installation, version compatibility)
- **Permission issues** (file/directory permissions, read-only systems)
- **Network connectivity** (DNS resolution, timeouts, proxy issues)
- **Platform differences** (case sensitivity, path separators, line endings)
- **Environment variables** (locale settings, PATH manipulation)
- **Resource limitations** (memory, disk space, file descriptors)
- **Clock and timezone** (timestamp handling, timezone changes)

### 4. Security Edge Cases (`security-edge-cases.sh`)

Tests security vulnerabilities and attack vectors:

- **Command injection prevention** (shell command execution)
- **Credential exposure detection** (API keys, passwords, secrets)
- **Tool permission auditing** (unrestricted access, dangerous capabilities)
- **Privilege escalation prevention** (SUID, sudo, environment manipulation)
- **Data exfiltration prevention** (network connections, large files)
- **Input sanitization bypass** (encoding attacks, Unicode normalization)

### 5. Main Test Runner (`edge-cases.sh`)

Orchestrates the complete test suite:

- **Pre-flight safety checks** (environment validation, disk space)
- **Test category execution** (parallel/sequential execution)
- **Comprehensive reporting** (JSON, XML, Markdown, TAP formats)
- **Safety enforcement** (timeouts, resource limits, forbidden commands)
- **Integration** with existing test framework

## Usage

### Run All Edge Case Tests

```bash
./edge-cases.sh
```

### Run Specific Category

```bash
./edge-cases.sh --category git_state
./edge-cases.sh --category input_validation
./edge-cases.sh --category environment
./edge-cases.sh --category security
```

### Force Execution (Override Safety Checks)

```bash
./edge-cases.sh --force
```

### Verbose Output

```bash
./edge-cases.sh --verbose
```

### Help

```bash
./edge-cases.sh --help
```

## Safety Features

The framework includes multiple safety mechanisms:

### 1. Pre-flight Checks
- Environment validation
- Disk space verification
- Tool availability
- Permission validation

### 2. Resource Limits
- Maximum test duration (30 minutes default)
- File size limits (50MB default)
- Memory usage limits (512MB default)
- Network request limits

### 3. Forbidden Operations
- Dangerous commands (`rm -rf /`, `sudo`, `format`)
- System file access (`/etc`, `/boot`, `/sys`)
- Privilege escalation attempts
- Actual network attacks

### 4. Sandboxing
- Isolated test directories
- Temporary file cleanup
- Permission restoration
- Process monitoring

## Reporting

The framework generates comprehensive reports in multiple formats:

### Report Types
- **Console** - Real-time output with color coding
- **JSON** - Machine-readable structured data
- **XML (JUnit)** - CI/CD integration format
- **Markdown** - Human-readable detailed reports
- **TAP** - Test Anything Protocol format

### Report Content
- Test execution summary
- Performance metrics
- Security vulnerability analysis
- Platform-specific issues
- Detailed error logs
- Recommendations for fixes

## Integration

### With Existing Test Framework

The edge case tests integrate seamlessly with the existing Claude Flow test framework:

- Uses existing test libraries (`test-reporter.sh`, `security-validator.sh`)
- Follows established patterns and conventions
- Integrates with CI/CD pipelines
- Supports parallel execution

### Configuration

Comprehensive configuration via `edge-case-config.yaml`:

- Test enablement/disablement
- Safety limits and thresholds
- Platform-specific settings
- Reporting preferences
- Security testing parameters

## Exit Codes

- **0** - All tests passed successfully
- **1** - Some tests failed (review required)
- **2** - Critical security vulnerabilities detected (immediate action required)

## Critical Edge Cases Identified

Based on the ultrathink analysis, these are the most critical edge cases tested:

### Git State Issues
- Empty repositories causing command failures
- Detached HEAD states breaking workflows
- Merge conflicts preventing operations
- Repository corruption causing data loss
- Large repositories causing performance issues

### Input Validation Vulnerabilities
- Command injection through $ARGUMENTS
- Path traversal attacks via file inputs
- Unicode normalization bypass attempts
- Buffer overflow via long inputs
- Environment variable injection

### Environment Problems
- Missing git causing command failures
- Permission issues preventing operations
- Network connectivity problems
- Platform differences causing inconsistencies
- Resource exhaustion causing failures

### Security Vulnerabilities
- Unrestricted tool access
- Credential exposure in git history
- Privilege escalation opportunities
- Data exfiltration vectors
- Input sanitization bypasses

## Maintenance

### Adding New Edge Cases

1. Identify new edge case category or specific test
2. Add test function to appropriate script
3. Update configuration if needed
4. Update this documentation
5. Run full test suite to validate

### Configuration Updates

- Modify `edge-case-config.yaml` for test parameters
- Update safety limits as needed
- Add new forbidden patterns
- Adjust platform-specific settings

## Best Practices

1. **Always run pre-flight checks** before test execution
2. **Monitor resource usage** during test runs
3. **Review security findings** immediately
4. **Update edge cases** as new vulnerabilities are discovered
5. **Run tests regularly** as part of CI/CD pipeline

## Troubleshooting

### Common Issues

1. **Permission Denied** - Check file permissions and user rights
2. **Network Timeouts** - Verify network connectivity and proxy settings
3. **Disk Space** - Ensure adequate free space (100MB minimum)
4. **Tool Missing** - Install required tools (git, bash, etc.)

### Debug Mode

Enable debug output for troubleshooting:

```bash
DEBUG=true ./edge-cases.sh --verbose
```

This comprehensive edge case testing framework ensures that Claude Flow commands handle unusual, malformed, and malicious inputs safely and robustly across different platforms and environments.