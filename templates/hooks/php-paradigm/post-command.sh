#!/bin/bash
# PHP Paradigm Post-Command Hook
# Validates results and performs cleanup after Claude Code commands

set -euo pipefail

# Configuration
PHP_PARADIGM_PATH="${PHP_PARADIGM_PATH:-/path/to/your/php-paradigm-standards}"
HOOK_NAME="post-command"
LOG_FILE=".claude/logs/hooks.log"

# Logging function
log() {
    local level="$1"
    local message="$2"
    echo "$(date -Iseconds) [$level] [$HOOK_NAME] $message" >> "$LOG_FILE" 2>/dev/null || true
    if [[ "$level" == "ERROR" || "$level" == "WARN" ]]; then
        echo "🔍 $message" >&2
    fi
}

# Initialize
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
log "INFO" "Starting post-command validation and cleanup"

# Get command details from arguments
COMMAND_NAME="${1:-unknown}"
COMMAND_EXIT_CODE="${2:-0}"
log "INFO" "Processing post-command for: $COMMAND_NAME (exit code: $COMMAND_EXIT_CODE)"

# Check if PHP paradigm standards exist
if [[ ! -d "$PHP_PARADIGM_PATH" ]]; then
    log "WARN" "PHP paradigm standards not found at: $PHP_PARADIGM_PATH"
    exit 0
fi

# Command-specific post-validations
case "$COMMAND_NAME" in
    "test"|"phpunit")
        log "INFO" "Post-validating test command"
        if [[ "$COMMAND_EXIT_CODE" -eq 0 ]]; then
            echo "✅ Tests passed - PHP paradigm compliance maintained"
            
            # Check for test coverage if available
            if [[ -f "coverage.xml" || -f "build/coverage.xml" ]]; then
                log "INFO" "Test coverage report found"
                echo "📊 Test coverage report generated"
            fi
            
            # Validate test group compliance if tests were added/modified
            find tests test -name "*.php" -newer ".claude/logs/hooks.log" 2>/dev/null | while read -r test_file; do
                if [[ -f "$test_file" ]]; then
                    if ! grep -q "#\[Group(" "$test_file"; then
                        log "WARN" "New test file missing groups: $test_file"
                        echo "⚠️  New test file may be missing group annotations: $test_file"
                    fi
                fi
            done
        else
            log "WARN" "Tests failed with exit code: $COMMAND_EXIT_CODE"
            echo "❌ Tests failed - review failures for paradigm compliance issues"
        fi
        ;;
        
    "format"|"fix"|"cs-fix")
        log "INFO" "Post-validating format command"
        if [[ "$COMMAND_EXIT_CODE" -eq 0 ]]; then
            echo "✅ Code formatting completed"
            
            # Check if any files were modified
            if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
                MODIFIED_FILES=$(git diff --name-only | grep "\.php$" || true)
                if [[ -n "$MODIFIED_FILES" ]]; then
                    log "INFO" "Files modified by formatting: $MODIFIED_FILES"
                    echo "🔧 Modified files: $(echo $MODIFIED_FILES | tr '\n' ' ')"
                fi
            fi
        else
            log "ERROR" "Formatting failed with exit code: $COMMAND_EXIT_CODE"
            echo "❌ Code formatting failed - check for syntax errors"
        fi
        ;;
        
    "analyze"|"stan"|"phpstan")
        log "INFO" "Post-validating analysis command"
        if [[ "$COMMAND_EXIT_CODE" -eq 0 ]]; then
            echo "✅ Static analysis passed - no paradigm violations detected"
        else
            log "WARN" "Static analysis failed with exit code: $COMMAND_EXIT_CODE"
            echo "❌ Static analysis found issues - review for paradigm compliance"
            
            # Check for specific paradigm violations in PHPStan output
            if [[ -f "phpstan-output.txt" ]]; then
                if grep -q "declare(strict_types=1)" "phpstan-output.txt"; then
                    echo "🚨 Missing strict types declarations detected"
                fi
                if grep -q "constant.*type" "phpstan-output.txt"; then
                    echo "🚨 Untyped constants detected"
                fi
            fi
        fi
        ;;
        
    "build"|"compile")
        log "INFO" "Post-validating build command"
        if [[ "$COMMAND_EXIT_CODE" -eq 0 ]]; then
            echo "✅ Build completed successfully"
            
            # Run final paradigm compliance check
            echo "🔍 Running final paradigm compliance check..."
            COMPLIANCE_ISSUES=0
            
            # Check for strict types in all PHP files
            while read -r php_file; do
                if [[ -f "$php_file" ]] && ! grep -q "declare(strict_types=1)" "$php_file"; then
                    log "WARN" "Missing strict types in: $php_file"
                    ((COMPLIANCE_ISSUES++))
                fi
            done < <(find . -name "*.php" -not -path "./vendor/*" 2>/dev/null)
            
            if [[ $COMPLIANCE_ISSUES -eq 0 ]]; then
                echo "✅ All PHP files comply with paradigm standards"
            else
                echo "⚠️  $COMPLIANCE_ISSUES files may need paradigm compliance updates"
            fi
        else
            log "ERROR" "Build failed with exit code: $COMMAND_EXIT_CODE"
            echo "❌ Build failed - check for paradigm compliance issues"
        fi
        ;;
esac

# Generate compliance report
REPORT_FILE=".claude/reports/paradigm-compliance.json"
mkdir -p "$(dirname "$REPORT_FILE")" 2>/dev/null || true

# Basic compliance check
TOTAL_PHP_FILES=$(find . -name "*.php" -not -path "./vendor/*" 2>/dev/null | wc -l)
STRICT_TYPES_FILES=$(find . -name "*.php" -not -path "./vendor/*" -exec grep -l "declare(strict_types=1)" {} \; 2>/dev/null | wc -l)
TOTAL_TEST_FILES=$(find tests test -name "*Test.php" 2>/dev/null | wc -l || echo 0)
GROUPED_TEST_FILES=$(find tests test -name "*Test.php" -exec grep -l "#\[Group(" {} \; 2>/dev/null | wc -l || echo 0)

# Calculate compliance percentages
if [[ $TOTAL_PHP_FILES -gt 0 ]]; then
    STRICT_TYPES_PERCENT=$((STRICT_TYPES_FILES * 100 / TOTAL_PHP_FILES))
else
    STRICT_TYPES_PERCENT=0
fi

if [[ $TOTAL_TEST_FILES -gt 0 ]]; then
    TEST_GROUPS_PERCENT=$((GROUPED_TEST_FILES * 100 / TOTAL_TEST_FILES))
else
    TEST_GROUPS_PERCENT=100
fi

# Write compliance report
cat > "$REPORT_FILE" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "command": "$COMMAND_NAME",
  "exit_code": $COMMAND_EXIT_CODE,
  "compliance": {
    "strict_types": {
      "compliant_files": $STRICT_TYPES_FILES,
      "total_files": $TOTAL_PHP_FILES,
      "percentage": $STRICT_TYPES_PERCENT
    },
    "test_groups": {
      "compliant_files": $GROUPED_TEST_FILES,
      "total_files": $TOTAL_TEST_FILES,
      "percentage": $TEST_GROUPS_PERCENT
    }
  },
  "overall_score": $(((STRICT_TYPES_PERCENT + TEST_GROUPS_PERCENT) / 2))
}
EOF

OVERALL_SCORE=$(((STRICT_TYPES_PERCENT + TEST_GROUPS_PERCENT) / 2))
log "INFO" "Paradigm compliance score: $OVERALL_SCORE%"

if [[ $OVERALL_SCORE -ge 90 ]]; then
    echo "🏆 Excellent paradigm compliance: $OVERALL_SCORE%"
elif [[ $OVERALL_SCORE -ge 75 ]]; then
    echo "✅ Good paradigm compliance: $OVERALL_SCORE%"
elif [[ $OVERALL_SCORE -ge 50 ]]; then
    echo "⚠️  Moderate paradigm compliance: $OVERALL_SCORE% - consider improvements"
else
    echo "❌ Poor paradigm compliance: $OVERALL_SCORE% - significant improvements needed"
fi

# Run PHP paradigm post-command validator if available
PHP_PARADIGM_POST_VALIDATOR="$PHP_PARADIGM_PATH/validation/post-command-validator.php"
if [[ -f "$PHP_PARADIGM_POST_VALIDATOR" ]]; then
    log "INFO" "Running PHP paradigm post-command validator"
    if ! php "$PHP_PARADIGM_POST_VALIDATOR" "$COMMAND_NAME" "$COMMAND_EXIT_CODE" 2>/dev/null; then
        log "WARN" "PHP paradigm post-command validator reported issues"
    fi
fi

# Cleanup temporary files if command was successful
if [[ "$COMMAND_EXIT_CODE" -eq 0 ]]; then
    # Clean up any temporary files created during the command
    find . -name "*.tmp" -o -name "*.bak" -not -path "./vendor/*" -delete 2>/dev/null || true
    log "INFO" "Cleaned up temporary files"
fi

log "INFO" "Post-command processing completed for: $COMMAND_NAME"
exit 0