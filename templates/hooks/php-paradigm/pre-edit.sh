#!/bin/bash
# PHP Paradigm Pre-Edit Hook
# Validates coding standards before Claude Code makes changes

set -euo pipefail

# Configuration
PHP_PARADIGM_PATH="${PHP_PARADIGM_PATH:-/path/to/your/php-paradigm-standards}"
HOOK_NAME="pre-edit"
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
log "INFO" "Starting pre-edit validation"

# Get file being edited from arguments
FILE_PATH="${1:-}"
if [[ -z "$FILE_PATH" ]]; then
    log "WARN" "No file path provided"
    exit 0
fi

log "INFO" "Validating file: $FILE_PATH"

# Check if PHP paradigm standards exist
if [[ ! -d "$PHP_PARADIGM_PATH" ]]; then
    log "WARN" "PHP paradigm standards not found at: $PHP_PARADIGM_PATH"
    exit 0
fi

# PHP file validation
if [[ "$FILE_PATH" == *.php ]]; then
    log "INFO" "Running PHP validation for: $FILE_PATH"
    
    # Check for strict types declaration
    if [[ -f "$FILE_PATH" ]]; then
        if ! grep -q "declare(strict_types=1)" "$FILE_PATH"; then
            log "ERROR" "Missing declare(strict_types=1) in: $FILE_PATH"
            echo "❌ PHP PARADIGM VIOLATION: Missing declare(strict_types=1) in $FILE_PATH"
            echo "   Required by PHP paradigm type safety standards"
            # Don't exit - let Claude Code proceed with warning
        fi
        
        # Check for untyped constants (basic check)
        if grep -q "const [A-Z_]* =" "$FILE_PATH" && ! grep -q "const [A-Z_]*: " "$FILE_PATH"; then
            log "WARN" "Potential untyped constants in: $FILE_PATH"
            echo "⚠️  PHP PARADIGM WARNING: Potential untyped constants in $FILE_PATH"
            echo "   All constants should have explicit type declarations"
        fi
    fi
fi

# Test file validation
if [[ "$FILE_PATH" == *Test.php || "$FILE_PATH" == *test.php || "$FILE_PATH" == test/* || "$FILE_PATH" == tests/* ]]; then
    log "INFO" "Running test validation for: $FILE_PATH"
    
    if [[ -f "$FILE_PATH" ]]; then
        # Check for test group hierarchy
        if ! grep -q "#\[Group(" "$FILE_PATH"; then
            log "ERROR" "Missing test groups in: $FILE_PATH"
            echo "❌ PHP PARADIGM VIOLATION: Missing test groups in $FILE_PATH"
            echo "   Required by PHP paradigm testing standards"
            echo "   Example: #[Group('unit-test')] #[Group('entity-test')]"
        fi
    fi
fi

# ConfigProvider validation
if [[ "$FILE_PATH" == *ConfigProvider.php ]]; then
    log "INFO" "Running ConfigProvider validation for: $FILE_PATH"
    
    if [[ -f "$FILE_PATH" ]]; then
        if ! grep -q "class.*ConfigProvider" "$FILE_PATH"; then
            log "WARN" "File named ConfigProvider but no ConfigProvider class found: $FILE_PATH"
        fi
    fi
fi

# Run PHP paradigm validation script if available
PHP_PARADIGM_VALIDATOR="$PHP_PARADIGM_PATH/validation/pre-edit-validator.php"
if [[ -f "$PHP_PARADIGM_VALIDATOR" ]]; then
    log "INFO" "Running PHP paradigm validator: $PHP_PARADIGM_VALIDATOR"
    if ! php "$PHP_PARADIGM_VALIDATOR" "$FILE_PATH" 2>/dev/null; then
        log "WARN" "PHP paradigm validator reported issues for: $FILE_PATH"
    fi
fi

log "INFO" "Pre-edit validation completed for: $FILE_PATH"
exit 0