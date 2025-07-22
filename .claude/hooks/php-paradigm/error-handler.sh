#!/bin/bash
# PHP Paradigm Error Handler Hook
# Handles errors and provides recovery suggestions

set -euo pipefail

# Configuration
PHP_PARADIGM_PATH="${PHP_PARADIGM_PATH:-/path/to/your/php-paradigm-standards}"
HOOK_NAME="error-handler"
LOG_FILE=".claude/logs/hooks.log"

# Logging function
log() {
    local level="$1"
    local message="$2"
    echo "$(date -Iseconds) [$level] [$HOOK_NAME] $message" >> "$LOG_FILE" 2>/dev/null || true
    if [[ "$level" == "ERROR" || "$level" == "WARN" ]]; then
        echo "🚨 $message" >&2
    fi
}

# Initialize
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
log "INFO" "Starting error handling and recovery"

# Get error details from arguments
COMMAND_NAME="${1:-unknown}"
ERROR_CODE="${2:-1}"
ERROR_MESSAGE="${3:-No error message provided}"

log "ERROR" "Error in command '$COMMAND_NAME' (code: $ERROR_CODE): $ERROR_MESSAGE"

echo "🚨 PHP Paradigm Error Handler"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Command: $COMMAND_NAME"
echo "Error Code: $ERROR_CODE"
echo "Error: $ERROR_MESSAGE"
echo ""

# Check if PHP paradigm standards exist
if [[ ! -d "$PHP_PARADIGM_PATH" ]]; then
    log "WARN" "PHP paradigm standards not found at: $PHP_PARADIGM_PATH"
    echo "⚠️  PHP paradigm standards not found - some recovery suggestions may be limited"
    echo ""
fi

# Analyze error and provide specific recovery suggestions
case "$ERROR_CODE" in
    1)
        echo "🔍 General Error Analysis:"
        echo "• This is a general error (exit code 1)"
        echo "• Check the command output above for specific error details"
        ;;
    2)
        echo "🔍 Syntax Error Analysis:"
        echo "• This may be a PHP syntax error"
        echo "• Check for missing semicolons, brackets, or quotes"
        echo "• Verify declare(strict_types=1) is properly placed"
        ;;
    126)
        echo "🔍 Permission Error Analysis:"
        echo "• Command cannot be executed (permission denied)"
        echo "• Check if hook scripts are executable: chmod +x .php-paradigm/hooks/*.sh"
        ;;
    127)
        echo "🔍 Command Not Found Analysis:"
        echo "• The command was not found in PATH"
        echo "• Check if required tools (php, composer, phpstan, etc.) are installed"
        ;;
    *)
        echo "🔍 Error Code $ERROR_CODE Analysis:"
        echo "• This is a specific error code from the command"
        echo "• Check the command documentation for details"
        ;;
esac

echo ""

# Command-specific error handling and recovery
case "$COMMAND_NAME" in
    "test"|"phpunit")
        echo "🧪 Test Command Error Recovery:"
        echo ""
        echo "Common PHP paradigm test issues:"
        echo "• Missing test group annotations: #[Group('unit-test')]"
        echo "• Test classes not extending proper base class"
        echo "• Missing or incorrect namespace declarations"
        echo ""
        echo "Recovery steps:"
        echo "1. Check test file structure and naming"
        echo "2. Verify test groups are properly defined"
        echo "3. Ensure strict types are declared in test files"
        echo "4. Run individual test files to isolate issues"
        ;;
        
    "format"|"fix"|"cs-fix")
        echo "🔧 Format Command Error Recovery:"
        echo ""
        echo "Common formatting issues:"
        echo "• Syntax errors preventing formatting"
        echo "• Missing or corrupted .php-cs-fixer.php config"
        echo "• File permission issues"
        echo ""
        echo "Recovery steps:"
        echo "1. Fix syntax errors first: php -l filename.php"
        echo "2. Check PHP-CS-Fixer config exists and is valid"
        echo "3. Verify file permissions are correct"
        echo "4. Try formatting individual files to isolate issues"
        ;;
        
    "analyze"|"stan"|"phpstan")
        echo "📊 Analysis Command Error Recovery:"
        echo ""
        echo "Common analysis issues:"
        echo "• Missing declare(strict_types=1) declarations"
        echo "• Untyped constants or properties"
        echo "• PHPStan configuration issues"
        echo ""
        echo "Recovery steps:"
        echo "1. Add declare(strict_types=1) to all PHP files"
        echo "2. Add type declarations to constants: const NAME: string = 'value'"
        echo "3. Check phpstan.neon configuration"
        echo "4. Run with lower level first: phpstan analyse --level=1"
        ;;
        
    "build"|"compile")
        echo "🏗️  Build Command Error Recovery:"
        echo ""
        echo "Common build issues:"
        echo "• Missing dependencies (run composer install)"
        echo "• PHP version compatibility issues"
        echo "• Paradigm compliance violations"
        echo ""
        echo "Recovery steps:"
        echo "1. Update dependencies: composer install"
        echo "2. Check PHP version compatibility"
        echo "3. Fix paradigm compliance issues first"
        echo "4. Run tests before building"
        ;;
        
    *)
        echo "🔍 General Command Error Recovery:"
        echo ""
        echo "Generic recovery steps:"
        echo "1. Check command syntax and arguments"
        echo "2. Verify required tools are installed"
        echo "3. Check file permissions and paths"
        echo "4. Review recent changes that might have caused the error"
        ;;
esac

echo ""

# Paradigm-specific diagnostics
echo "🔬 PHP Paradigm Diagnostics:"
echo ""

# Check for common paradigm issues
DIAGNOSTIC_ISSUES=0

# Check PHP files for strict types
echo "Checking strict types compliance..."
MISSING_STRICT_TYPES=$(find . -name "*.php" -not -path "./vendor/*" -exec grep -L "declare(strict_types=1)" {} \; 2>/dev/null | head -5)
if [[ -n "$MISSING_STRICT_TYPES" ]]; then
    echo "❌ Files missing declare(strict_types=1):"
    echo "$MISSING_STRICT_TYPES" | while read -r file; do
        echo "  • $file"
    done
    ((DIAGNOSTIC_ISSUES++))
else
    echo "✅ All PHP files have strict types declared"
fi

# Check test files for groups
echo ""
echo "Checking test group compliance..."
MISSING_TEST_GROUPS=$(find tests test -name "*Test.php" -exec grep -L "#\[Group(" {} \; 2>/dev/null | head -5)
if [[ -n "$MISSING_TEST_GROUPS" ]]; then
    echo "❌ Test files missing group annotations:"
    echo "$MISSING_TEST_GROUPS" | while read -r file; do
        echo "  • $file"
    done
    ((DIAGNOSTIC_ISSUES++))
else
    echo "✅ All test files have proper group annotations"
fi

# Check for untyped constants
echo ""
echo "Checking constant type compliance..."
UNTYPED_CONSTANTS=$(find . -name "*.php" -not -path "./vendor/*" -exec grep -l "const [A-Z_]* =" {} \; | xargs grep -L "const [A-Z_]*: " 2>/dev/null | head -3)
if [[ -n "$UNTYPED_CONSTANTS" ]]; then
    echo "❌ Files with potentially untyped constants:"
    echo "$UNTYPED_CONSTANTS" | while read -r file; do
        echo "  • $file"
    done
    ((DIAGNOSTIC_ISSUES++))
else
    echo "✅ Constants appear to be properly typed"
fi

echo ""

if [[ $DIAGNOSTIC_ISSUES -eq 0 ]]; then
    echo "🎉 No paradigm compliance issues detected"
    echo "   The error may be unrelated to paradigm standards"
else
    echo "⚠️  $DIAGNOSTIC_ISSUES paradigm compliance issue(s) detected"
    echo "   Fix these issues and try the command again"
fi

# Generate error report
ERROR_REPORT_FILE=".claude/reports/error-report-$(date +%Y%m%d-%H%M%S).json"
mkdir -p "$(dirname "$ERROR_REPORT_FILE")" 2>/dev/null || true

cat > "$ERROR_REPORT_FILE" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "command": "$COMMAND_NAME",
  "error_code": $ERROR_CODE,
  "error_message": "$ERROR_MESSAGE",
  "diagnostics": {
    "issues_found": $DIAGNOSTIC_ISSUES,
    "missing_strict_types": $(echo "$MISSING_STRICT_TYPES" | wc -l),
    "missing_test_groups": $(echo "$MISSING_TEST_GROUPS" | wc -l),
    "untyped_constants": $(echo "$UNTYPED_CONSTANTS" | wc -l)
  },
  "recovery_attempted": true
}
EOF

echo ""
echo "📋 Error report saved to: $ERROR_REPORT_FILE"

# Run PHP paradigm error handler if available
PHP_PARADIGM_ERROR_HANDLER="$PHP_PARADIGM_PATH/tools/error-handler.php"
if [[ -f "$PHP_PARADIGM_ERROR_HANDLER" ]]; then
    echo ""
    echo "🔧 Running PHP paradigm error handler..."
    if php "$PHP_PARADIGM_ERROR_HANDLER" "$COMMAND_NAME" "$ERROR_CODE" "$ERROR_MESSAGE" 2>/dev/null; then
        echo "✅ PHP paradigm error handler completed"
    else
        echo "⚠️  PHP paradigm error handler encountered issues"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Next Steps:"
echo "1. Review the specific error message and recovery suggestions above"
echo "2. Fix any paradigm compliance issues detected"
echo "3. Test the fix with a smaller scope if possible"
echo "4. Re-run the original command"
echo "5. Check logs at: $LOG_FILE"

log "INFO" "Error handling completed for: $COMMAND_NAME"
exit 0