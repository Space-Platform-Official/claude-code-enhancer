#!/bin/bash

# Annotation Automation Command Wrapper
# 
# This script provides a convenient wrapper for the annotation automation PHP script
# with additional shell integration and file monitoring capabilities.

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PHP_SCRIPT="${SCRIPT_DIR}/annotation-automation.php"
CONFIG_FILE="${SCRIPT_DIR}/annotation-automation.json"
LOG_FILE="${SCRIPT_DIR}/annotation-automation.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2 | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Check dependencies
check_dependencies() {
    log "Checking dependencies..."
    
    # Check PHP
    if ! command -v php &> /dev/null; then
        error "PHP is not installed or not in PATH"
        exit 1
    fi
    
    # Check PHP version
    PHP_VERSION=$(php -r "echo PHP_VERSION;")
    if [[ $(echo "$PHP_VERSION" | cut -d. -f1) -lt 8 ]]; then
        error "PHP 8.0 or higher is required. Current version: $PHP_VERSION"
        exit 1
    fi
    
    # Check if PHP script exists
    if [[ ! -f "$PHP_SCRIPT" ]]; then
        error "PHP script not found: $PHP_SCRIPT"
        exit 1
    fi
    
    # Check if composer autoloader exists
    if [[ ! -f "${SCRIPT_DIR}/../../vendor/autoload.php" ]]; then
        error "Composer autoloader not found. Please run 'composer install'"
        exit 1
    fi
    
    success "Dependencies check passed"
}

# Initialize configuration
init_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log "Creating default configuration file..."
        cat > "$CONFIG_FILE" << EOF
{
    "source_directory": "src",
    "test_directory": "test/Cases",
    "output_format": "console",
    "fix_mode": "safe",
    "scan_interval": 5,
    "auto_fix": false,
    "watch_patterns": [
        "*.php"
    ],
    "exclude_patterns": [
        "vendor/*",
        "node_modules/*",
        ".git/*"
    ],
    "notification": {
        "enabled": false,
        "methods": ["console"]
    }
}
EOF
        success "Configuration file created: $CONFIG_FILE"
    fi
}

# File monitoring with inotify (Linux/Mac)
monitor_files() {
    local source_dir="${1:-src}"
    local test_dir="${2:-test/Cases}"
    
    log "Starting file monitoring for $source_dir and $test_dir..."
    
    # Check if fswatch is available (Mac) or inotifywait (Linux)
    if command -v fswatch &> /dev/null; then
        log "Using fswatch for file monitoring"
        fswatch -o "$source_dir" "$test_dir" | while read f; do
            log "File change detected, running validation..."
            php "$PHP_SCRIPT" validate --format=console
        done
    elif command -v inotifywait &> /dev/null; then
        log "Using inotifywait for file monitoring"
        inotifywait -m -r -e modify,create,delete "$source_dir" "$test_dir" | while read path action file; do
            if [[ "$file" == *.php ]]; then
                log "PHP file change detected: $path$file"
                php "$PHP_SCRIPT" validate --format=console
            fi
        done
    else
        warning "No file monitoring tool found. Using polling method..."
        # Fallback to polling
        while true; do
            sleep 5
            php "$PHP_SCRIPT" validate --format=console
        done
    fi
}

# Main execution
main() {
    local command="${1:-scan}"
    shift || true
    
    # Check dependencies
    check_dependencies
    
    # Initialize configuration
    init_config
    
    # Handle special commands
    case "$command" in
        "watch")
            log "Starting watch mode..."
            monitor_files "$@"
            ;;
        "setup")
            log "Setting up annotation automation..."
            
            # Make PHP script executable
            chmod +x "$PHP_SCRIPT"
            
            # Create reports directory
            mkdir -p "${SCRIPT_DIR}/reports"
            
            # Run initial scan
            php "$PHP_SCRIPT" scan --format=console
            
            success "Setup completed successfully"
            ;;
        "status")
            log "Checking annotation system status..."
            
            # Run quick validation
            if php "$PHP_SCRIPT" validate --format=console; then
                success "Annotation system is healthy"
            else
                error "Annotation system has issues"
                exit 1
            fi
            ;;
        "clean")
            log "Cleaning up temporary files..."
            
            # Remove old reports
            find "${SCRIPT_DIR}/reports" -name "*.json" -mtime +7 -delete 2>/dev/null || true
            find "${SCRIPT_DIR}/reports" -name "*.html" -mtime +7 -delete 2>/dev/null || true
            
            # Truncate log file
            > "$LOG_FILE"
            
            success "Cleanup completed"
            ;;
        "install")
            log "Installing annotation automation system..."
            
            # Make scripts executable
            chmod +x "$PHP_SCRIPT"
            chmod +x "$0"
            
            # Add to PATH if desired
            if [[ "$1" == "--global" ]]; then
                if [[ -w "/usr/local/bin" ]]; then
                    ln -sf "$0" "/usr/local/bin/annotation-automation"
                    success "Annotation automation installed globally"
                else
                    warning "Cannot install globally. No write access to /usr/local/bin"
                fi
            fi
            
            # Create cron job for regular scans if desired
            if [[ "$1" == "--cron" ]]; then
                log "Setting up cron job for regular scans..."
                (crontab -l 2>/dev/null; echo "0 */6 * * * cd $(pwd) && $0 scan --format=console >> $LOG_FILE 2>&1") | crontab -
                success "Cron job added for 6-hourly annotation scans"
            fi
            
            success "Installation completed"
            ;;
        "help"|"-h"|"--help")
            cat << EOF
Annotation Automation Wrapper Script

Usage: $0 [command] [options]

Commands:
  scan                 Scan all files for annotation analysis
  validate             Validate annotation consistency
  update               Update annotations based on analysis
  report               Generate comprehensive reports
  fix                  Automatically fix annotation issues
  monitor              Continuous monitoring mode
  watch                File monitoring with automatic validation
  setup                Initial setup of annotation automation
  status               Check annotation system status
  clean                Clean up temporary files
  install [--global]   Install annotation automation system
  help                 Show this help

Examples:
  $0 scan
  $0 validate --verbose
  $0 update --dry-run
  $0 report --format=json --output=reports/
  $0 fix --fix-mode=safe
  $0 watch
  $0 setup
  $0 install --global

For PHP script options, use:
  $0 [command] --help

EOF
            ;;
        *)
            log "Executing PHP script with command: $command"
            php "$PHP_SCRIPT" "$command" "$@"
            ;;
    esac
}

# Execute main function with all arguments
main "$@"