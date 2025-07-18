# Annotation Automation System

A comprehensive bidirectional annotation orchestration tool for ongoing annotation management, scanning, validation, and automated updating.

## Overview

The Annotation Automation System provides automated tools for managing PHP annotations in your codebase, specifically focusing on bidirectional test linkage between source classes and test classes through `@Verified` and `@TestedBy` annotations.

## Features

- **Comprehensive Scanning**: Scan all source and test files for annotation analysis
- **Bidirectional Validation**: Validate linkage between source and test classes
- **Automated Updates**: Automatically update annotations based on analysis
- **Continuous Monitoring**: Watch for file changes and validate automatically
- **Multiple Output Formats**: Console, JSON, HTML reporting
- **CI/CD Integration**: Export validation results in JUnit, SARIF, and Checkstyle formats
- **Flexible Configuration**: Customizable validation rules and automation settings

## Installation

1. **Prerequisites**:
   - PHP 8.0 or higher
   - Composer dependencies installed
   - Access to the existing annotation infrastructure

2. **Setup**:
   ```bash
   # Make scripts executable
   chmod +x annotation-automation.sh
   chmod +x annotation-automation.php
   
   # Run initial setup
   ./annotation-automation.sh setup
   ```

3. **Global Installation** (optional):
   ```bash
   ./annotation-automation.sh install --global
   ```

## Usage

### Basic Commands

#### 1. Scan Files for Annotation Analysis
```bash
# Basic scan
./annotation-automation.sh scan

# Scan with specific directories
./annotation-automation.sh scan --source-dir=src --test-dir=test/Cases

# Scan with JSON output
./annotation-automation.sh scan --format=json --output=reports/scan-report.json
```

#### 2. Validate Annotation Consistency
```bash
# Basic validation
./annotation-automation.sh validate

# Verbose validation
./annotation-automation.sh validate --verbose

# Quick validation (subset of checks)
php annotation-automation.php validate --quick
```

#### 3. Update Annotations
```bash
# Dry run (show what would be updated)
./annotation-automation.sh update --dry-run

# Safe update mode
./annotation-automation.sh update --fix-mode=safe

# Aggressive update mode
./annotation-automation.sh update --fix-mode=aggressive
```

#### 4. Generate Reports
```bash
# Console report
./annotation-automation.sh report

# JSON report
./annotation-automation.sh report --format=json --output=reports/

# HTML report
./annotation-automation.sh report --format=html --output=reports/annotation-report.html
```

#### 5. Fix Annotation Issues
```bash
# Safe automatic fixes
./annotation-automation.sh fix --fix-mode=safe

# Dry run fixes
./annotation-automation.sh fix --dry-run

# Aggressive fixes (use with caution)
./annotation-automation.sh fix --fix-mode=aggressive
```

#### 6. Continuous Monitoring
```bash
# File monitoring with automatic validation
./annotation-automation.sh watch

# Full monitoring mode
./annotation-automation.sh monitor --watch

# Monitoring with auto-fix
./annotation-automation.sh monitor --watch --auto-fix
```

### Advanced Usage

#### CI/CD Integration

1. **Basic CI validation**:
   ```bash
   php annotation-validator.php --ci
   ```

2. **Validate specific files** (for git hooks):
   ```bash
   php annotation-validator.php --files="src/Entity/Entity.php,test/Cases/Entity/EntityTest.php"
   ```

3. **Generate CI reports**:
   ```bash
   # JUnit format
   php annotation-validator.php --format=junit > reports/annotation-junit.xml
   
   # SARIF format
   php annotation-validator.php --format=sarif > reports/annotation-sarif.json
   
   # Checkstyle format
   php annotation-validator.php --format=checkstyle > reports/annotation-checkstyle.xml
   ```

#### Git Hooks Integration

1. **Pre-commit hook**:
   ```bash
   #!/bin/bash
   # .git/hooks/pre-commit
   
   # Get changed PHP files
   CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.php$' | tr '\n' ',')
   
   if [ -n "$CHANGED_FILES" ]; then
       echo "Validating annotations for changed files..."
       php .claude/test/annotation-validator.php --files="$CHANGED_FILES"
       
       if [ $? -ne 0 ]; then
           echo "Annotation validation failed. Commit aborted."
           exit 1
       fi
   fi
   ```

2. **Pre-push hook**:
   ```bash
   #!/bin/bash
   # .git/hooks/pre-push
   
   echo "Running full annotation validation..."
   php .claude/test/annotation-validator.php --ci
   
   if [ $? -ne 0 ]; then
       echo "Annotation validation failed. Push aborted."
       exit 1
   fi
   ```

## Configuration

### Configuration File: `annotation-automation.json`

```json
{
    "source_directory": "src",
    "test_directory": "test/Cases",
    "output_format": "console",
    "fix_mode": "safe",
    "scan_interval": 5,
    "auto_fix": false,
    "watch_patterns": ["*.php"],
    "exclude_patterns": ["vendor/*", "node_modules/*", ".git/*"],
    "validation": {
        "required_annotations": ["TestedBy", "Verified"],
        "annotation_consistency": true,
        "bidirectional_linkage": true,
        "coverage_gaps": true,
        "strict_mode": false
    },
    "reporting": {
        "generate_html": true,
        "generate_json": true,
        "output_directory": "reports",
        "retention_days": 30
    },
    "automation": {
        "auto_add_annotations": true,
        "auto_fix_linkage": true,
        "auto_update_descriptions": false,
        "backup_before_changes": true
    }
}
```

### Configuration Options

- **source_directory**: Directory containing source files
- **test_directory**: Directory containing test files
- **output_format**: Default output format (console|json|html)
- **fix_mode**: Default fix mode (safe|aggressive)
- **scan_interval**: Interval in seconds for monitoring mode
- **auto_fix**: Enable automatic fixing in monitoring mode
- **watch_patterns**: File patterns to watch for changes
- **exclude_patterns**: Patterns to exclude from scanning

## Validation Rules

### 1. Bidirectional Linkage
- Source classes should have `@Verified` annotations linking to test methods
- Test classes should have `@TestedBy` annotations linking to source methods
- Annotations should reference existing classes and methods

### 2. Annotation Consistency
- Annotation parameters should be valid
- Referenced classes and methods should exist
- Annotation syntax should be correct

### 3. Coverage Gaps
- All public methods should have test coverage
- Test methods should have corresponding source methods
- Annotation descriptions should be meaningful

## Output Formats

### 1. Console Format
```
================================================================================
ANNOTATION REPORT: SCAN_REPORT
Generated: 2024-01-15 10:30:45
================================================================================

SUMMARY:
----------------------------------------
Source files                  : 150
Test files                    : 145
Source classes               : 150
Test classes                 : 145
Valid links                  : 142
Invalid links                : 3
Orphaned tests              : 5
Orphaned sources            : 8

RECOMMENDATIONS:
----------------------------------------
[HIGH] Fix 3 invalid annotation linkages
[MEDIUM] Fix 5 orphaned test(s) by adding @Verified annotations
[MEDIUM] Fix 8 orphaned source(s) by adding @TestedBy annotations
```

### 2. JSON Format
```json
{
    "timestamp": "2024-01-15T10:30:45+00:00",
    "summary": {
        "source_files": 150,
        "test_files": 145,
        "valid_links": 142,
        "invalid_links": 3
    },
    "linkage_analysis": {
        "summary": {
            "totalLinks": 145,
            "validLinks": 142,
            "invalidLinks": 3
        },
        "recommendations": [
            {
                "priority": "high",
                "message": "Fix 3 invalid annotation linkages"
            }
        ]
    }
}
```

### 3. HTML Format
Generated HTML reports include:
- Interactive summary dashboard
- Detailed validation results
- Clickable recommendations
- File-by-file analysis

## Maintenance Commands

### 1. System Status
```bash
./annotation-automation.sh status
```

### 2. Cleanup
```bash
./annotation-automation.sh clean
```

### 3. Get Metrics
```bash
php annotation-validator.php --metrics
```

## Integration Examples

### 1. Makefile Integration
```makefile
.PHONY: annotation-scan annotation-validate annotation-fix

annotation-scan:
	@echo "Running annotation scan..."
	@.claude/test/annotation-automation.sh scan --format=console

annotation-validate:
	@echo "Validating annotations..."
	@php .claude/test/annotation-validator.php --ci

annotation-fix:
	@echo "Fixing annotation issues..."
	@.claude/test/annotation-automation.sh fix --fix-mode=safe

test: annotation-validate
	@echo "Running tests after annotation validation..."
	@composer test
```

### 2. GitHub Actions Integration
```yaml
name: Annotation Validation

on: [push, pull_request]

jobs:
  annotation-validation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.1'
      - name: Install dependencies
        run: composer install
      - name: Run annotation validation
        run: php .claude/test/annotation-validator.php --ci
      - name: Generate annotation report
        run: php .claude/test/annotation-validator.php --format=junit > annotation-report.xml
      - name: Upload test results
        uses: actions/upload-artifact@v2
        with:
          name: annotation-results
          path: annotation-report.xml
```

### 3. Docker Integration
```dockerfile
FROM php:8.1-cli

COPY . /app
WORKDIR /app

RUN composer install --no-dev --optimize-autoloader

# Run annotation validation
RUN php .claude/test/annotation-validator.php --ci

# Set up monitoring
CMD ["php", ".claude/test/annotation-automation.php", "monitor", "--watch"]
```

## Troubleshooting

### Common Issues

1. **Missing Dependencies**:
   ```bash
   composer install
   ```

2. **Permission Issues**:
   ```bash
   chmod +x .claude/test/annotation-automation.sh
   chmod +x .claude/test/annotation-automation.php
   ```

3. **Configuration Issues**:
   ```bash
   # Reset to default configuration
   rm .claude/test/annotation-automation.json
   ./annotation-automation.sh setup
   ```

4. **File Monitoring Issues**:
   ```bash
   # Install file monitoring tools
   # On Mac:
   brew install fswatch
   
   # On Linux:
   sudo apt-get install inotify-tools
   ```

### Debug Mode
```bash
# Enable verbose output
./annotation-automation.sh scan --verbose

# Run with debugging
php annotation-automation.php scan --verbose --debug
```

## Best Practices

1. **Run Regular Scans**: Schedule regular annotation scans to catch issues early
2. **Use Safe Mode**: Always use safe mode for automatic fixes unless you're sure
3. **Review Before Committing**: Always review annotation changes before committing
4. **Monitor Coverage**: Keep track of annotation coverage metrics
5. **Use Dry Run**: Use dry run mode to preview changes before applying them

## Contributing

1. Test your changes with the existing annotation infrastructure
2. Update configuration examples if adding new options
3. Add appropriate error handling and logging
4. Follow the existing code style and patterns
5. Document any new features or options

## License

This tool is part of the Space Platform utilities library and follows the same licensing terms.