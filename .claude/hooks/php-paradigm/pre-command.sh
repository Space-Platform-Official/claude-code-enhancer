#!/bin/bash
# PHP Paradigm Pre-Command Hook
# Validates environment and setup before Claude Code commands

set -euo pipefail

# Configuration
PHP_PARADIGM_PATH="${PHP_PARADIGM_PATH:-/path/to/your/php-paradigm-standards}"
HOOK_NAME="pre-command"
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
log "INFO" "Starting pre-command validation"

# Get command being executed from arguments
COMMAND_NAME="${1:-unknown}"
log "INFO" "Validating environment for command: $COMMAND_NAME"

# Check if PHP paradigm standards exist
if [[ ! -d "$PHP_PARADIGM_PATH" ]]; then
    log "WARN" "PHP paradigm standards not found at: $PHP_PARADIGM_PATH"
    # Don't exit - allow command to proceed
fi

# Check PHP environment
if ! command -v php >/dev/null 2>&1; then
    log "WARN" "PHP not found in PATH - some validations may be skipped"
else
    PHP_VERSION=$(php -r "echo PHP_VERSION;" 2>/dev/null || echo "unknown")
    log "INFO" "PHP version detected: $PHP_VERSION"
    
    # Check if PHP version supports required features (PHP 8.0+)
    if [[ "$PHP_VERSION" =~ ^[7]\. ]]; then
        log "WARN" "PHP version $PHP_VERSION may not support all paradigm features (recommend PHP 8.0+)"
        echo "⚠️  PHP version $PHP_VERSION detected - some paradigm features require PHP 8.0+"
    fi
fi

# Check for composer if it's a PHP project
if [[ -f "composer.json" ]]; then
    log "INFO" "Composer project detected"
    
    if ! command -v composer >/dev/null 2>&1; then
        log "WARN" "Composer not found but composer.json exists"
        echo "⚠️  Composer project detected but composer command not available"
    else
        # Check if vendor directory exists
        if [[ ! -d "vendor" ]]; then
            log "WARN" "Vendor directory missing - dependencies may not be installed"
            echo "⚠️  Vendor directory missing - run 'composer install' first"
        fi
    fi
fi

# Check for PHP quality tools
TOOLS_AVAILABLE=()
TOOLS_MISSING=()

if command -v phpstan >/dev/null 2>&1; then
    TOOLS_AVAILABLE+=("phpstan")
else
    TOOLS_MISSING+=("phpstan")
fi

if command -v php-cs-fixer >/dev/null 2>&1; then
    TOOLS_AVAILABLE+=("php-cs-fixer")
else
    TOOLS_MISSING+=("php-cs-fixer")
fi

if command -v phpunit >/dev/null 2>&1; then
    TOOLS_AVAILABLE+=("phpunit")
else
    TOOLS_MISSING+=("phpunit")
fi

if [[ ${#TOOLS_AVAILABLE[@]} -gt 0 ]]; then
    log "INFO" "Quality tools available: ${TOOLS_AVAILABLE[*]}"
fi

if [[ ${#TOOLS_MISSING[@]} -gt 0 ]]; then
    log "INFO" "Quality tools missing: ${TOOLS_MISSING[*]}"
fi

# Command-specific pre-validations
case "$COMMAND_NAME" in
    "test"|"phpunit")
        log "INFO" "Pre-validating test command"
        if [[ ! -d "tests" && ! -d "test" ]]; then
            log "WARN" "No test directory found"
            echo "⚠️  No test directory found - tests may not be available"
        fi
        ;;
        
    "format"|"fix"|"cs-fix")
        log "INFO" "Pre-validating format command"
        if [[ ! -f ".php-cs-fixer.php" && ! -f ".php_cs" ]]; then
            log "INFO" "No PHP-CS-Fixer config found - will use defaults"
        fi
        ;;
        
    "analyze"|"stan"|"phpstan")
        log "INFO" "Pre-validating analysis command"
        if [[ ! -f "phpstan.neon" && ! -f "phpstan.neon.dist" ]]; then
            log "INFO" "No PHPStan config found - will use defaults"
        fi
        ;;
esac

# Run PHP paradigm pre-command validator if available
PHP_PARADIGM_PRE_VALIDATOR="$PHP_PARADIGM_PATH/validation/pre-command-validator.php"
if [[ -f "$PHP_PARADIGM_PRE_VALIDATOR" ]]; then
    log "INFO" "Running PHP paradigm pre-command validator"
    if ! php "$PHP_PARADIGM_PRE_VALIDATOR" "$COMMAND_NAME" 2>/dev/null; then
        log "WARN" "PHP paradigm pre-command validator reported issues"
    fi
fi

# Check git status for uncommitted changes (warning only)
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        log "INFO" "Uncommitted changes detected"
        echo "ℹ️  Uncommitted changes detected - consider committing before major operations"
    fi
fi

log "INFO" "Pre-command validation completed for: $COMMAND_NAME"
exit 0