---
description: Centralized configuration system for backup trigger coordination
---

# Backup Trigger System Configuration

Centralized configuration management for all backup trigger types with policy definitions, threshold settings, and integration with existing cleanup confidence patterns.

## Configuration Management System

```bash
# Configuration loader and manager
load_backup_config() {
    local config_dir=${BACKUP_CONFIG_DIR:-"$HOME/.claude/backup-config"}
    local main_config="$config_dir/config.sh"
    
    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"
    
    # Load main configuration
    if [[ -f "$main_config" ]]; then
        source "$main_config"
    else
        create_default_config "$main_config"
        source "$main_config"
    fi
    
    # Load component-specific configurations
    load_component_configs "$config_dir"
    
    # Validate configuration
    validate_configuration
    
    log_debug "Backup configuration loaded from: $config_dir"
}

# Create default configuration
create_default_config() {
    local config_file=$1
    
    cat > "$config_file" << 'EOF'
#!/bin/bash
# Backup Trigger System - Main Configuration
# Version: 1.0

# =============================================================================
# DIRECTORY CONFIGURATION
# =============================================================================

# Primary backup storage directory
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.claude/backups}"

# Archive storage directory (for compressed backups)
ARCHIVE_ROOT="${ARCHIVE_ROOT:-$HOME/.claude/archives}"

# Configuration directory
BACKUP_CONFIG_DIR="${BACKUP_CONFIG_DIR:-$HOME/.claude/backup-config}"

# Temporary directory for operations
BACKUP_TEMP_DIR="${BACKUP_TEMP_DIR:-/tmp/claude-backups}"

# =============================================================================
# STATE TRANSITION TIMEOUTS (seconds)
# =============================================================================

# Time limits for automatic state transitions
CREATED_TO_PENDING_TIMEOUT=1800        # 30 minutes - backup created but no commit
PENDING_TO_CLEANUP_TIMEOUT=259200      # 3 days - commit made but no merge
CONFIRMED_TO_CLEANUP_TIMEOUT=604800    # 7 days - merge confirmed
CLEANABLE_TO_ARCHIVED_TIMEOUT=86400    # 1 day - eligible for cleanup
ARCHIVED_TO_DELETED_TIMEOUT=2592000    # 30 days - archived backups

# Emergency timeouts (when disk space is critical)
EMERGENCY_CREATED_TIMEOUT=600          # 10 minutes
EMERGENCY_PENDING_TIMEOUT=3600         # 1 hour  
EMERGENCY_CONFIRMED_TIMEOUT=86400      # 1 day

# =============================================================================
# CONFIDENCE THRESHOLDS
# =============================================================================

# Confidence levels for automatic actions (0.0 to 1.0)
AUTO_CLEANUP_CONFIDENCE=0.85           # Automatic cleanup threshold
AUTO_ARCHIVE_CONFIDENCE=0.90           # Automatic archiving threshold
AUTO_DELETE_CONFIDENCE=0.95            # Automatic deletion threshold

# Manual action thresholds
MANUAL_REVIEW_CONFIDENCE=0.60          # Below this requires manual review
WARNING_CONFIDENCE=0.70                # Show warnings below this

# Emergency confidence overrides
EMERGENCY_CONFIDENCE_OVERRIDE=0.50     # Emergency cleanup confidence
DISK_PRESSURE_CONFIDENCE_BOOST=0.20    # Boost confidence when disk full

# =============================================================================
# DISK SPACE MONITORING
# =============================================================================

# Disk usage thresholds (percentage)
DISK_WARNING_THRESHOLD=75              # Start warning cleanup
DISK_CRITICAL_THRESHOLD=85             # Start aggressive cleanup
DISK_EMERGENCY_THRESHOLD=95            # Emergency cleanup mode

# Target free space after cleanup
MIN_FREE_SPACE_TARGET=20               # Target 20% free space

# =============================================================================
# CLEANUP POLICIES
# =============================================================================

# Cleanup strategy options: oldest_first, largest_first, confidence_based
CLEANUP_STRATEGY="confidence_based"

# Emergency cleanup strategy: conservative, aggressive, nuclear
EMERGENCY_CLEANUP_STRATEGY="aggressive"

# Safety limits
MAX_CLEANUP_PER_CYCLE=10               # Maximum backups per cleanup cycle
EMERGENCY_CLEANUP_LIMIT=50             # Maximum backups in emergency
LARGE_BACKUP_THRESHOLD=100             # MB - considered "large"
HUGE_BACKUP_THRESHOLD=500              # MB - considered "huge"

# =============================================================================
# DAEMON INTERVALS
# =============================================================================

# Check intervals (seconds)
TIME_CHECK_INTERVAL=300                # Time trigger daemon - 5 minutes
DISK_CHECK_INTERVAL=60                 # Disk monitor daemon - 1 minute  
POLICY_EVALUATION_INTERVAL=900         # Policy evaluation - 15 minutes
EMERGENCY_CHECK_INTERVAL=10            # Emergency monitoring - 10 seconds

# =============================================================================
# GIT INTEGRATION
# =============================================================================

# Git hook integration settings
GIT_HOOK_INTEGRATION=true              # Enable git hook triggers
GIT_HOOK_TIMEOUT=30                    # Timeout for git hook operations
POST_COMMIT_WINDOW=300                 # 5 minutes to find related backups
POST_MERGE_CONFIDENCE_BOOST=0.15       # Boost confidence after merge
PUSH_CLEANUP_THRESHOLD=0.80            # Confidence needed for push cleanup

# =============================================================================
# ARCHIVING AND COMPRESSION
# =============================================================================

# Archive settings
ARCHIVE_ENABLED=true                   # Enable archiving feature
COMPRESS_BEFORE_DELETE=true            # Compress before deletion
COMPRESSION_RATIO_ESTIMATE=0.30        # Estimate 30% compression ratio
ARCHIVE_VERIFICATION=true              # Verify archives after creation

# Archive organization
ARCHIVE_BY_DATE=true                   # Organize archives by date
ARCHIVE_DATE_FORMAT="%Y/%m"            # YYYY/MM directory structure

# =============================================================================
# LOGGING AND MONITORING
# =============================================================================

# Logging configuration
LOG_LEVEL="INFO"                       # DEBUG, INFO, WARNING, ERROR
LOG_TO_FILE=true                      # Enable file logging
LOG_FILE="$BACKUP_CONFIG_DIR/backup-triggers.log"
LOG_ROTATION=true                     # Enable log rotation
LOG_MAX_SIZE="10M"                    # Maximum log file size
LOG_MAX_FILES=5                       # Number of rotated logs to keep

# Metrics collection
ENABLE_METRICS=true                   # Collect performance metrics
METRICS_RETENTION_DAYS=30             # Keep metrics for 30 days

# =============================================================================
# ALERTING AND NOTIFICATIONS
# =============================================================================

# Alert settings
ENABLE_ALERTS=true                    # Enable alerting system
ALERT_EMAIL=""                        # Email for alerts (optional)
ALERT_WEBHOOK_URL=""                  # Webhook URL for alerts (optional)
SLACK_WEBHOOK_URL=""                  # Slack webhook (optional)

# Alert thresholds
ALERT_ON_DISK_WARNING=true            # Alert when disk usage reaches warning
ALERT_ON_FAILED_TRANSITIONS=true     # Alert on transition failures
ALERT_ON_EMERGENCY_CLEANUP=true      # Alert on emergency cleanups

# =============================================================================
# SAFETY AND SECURITY
# =============================================================================

# Safety features
REQUIRE_USER_CONFIRMATION=true        # Require confirmation for manual actions
BACKUP_STATE_VALIDATION=true         # Validate state transitions
ATOMIC_OPERATIONS=true               # Use atomic operations with rollback
CREATE_TRANSITION_LOGS=true          # Log all state transitions

# Security settings
SECURE_DELETION=true                 # Use secure deletion for sensitive files
BACKUP_PERMISSIONS=700               # Default backup directory permissions
LOCK_FILE_TIMEOUT=300                # Lock file timeout (5 minutes)

# =============================================================================
# PERFORMANCE TUNING
# =============================================================================

# Performance settings
PARALLEL_OPERATIONS=true             # Enable parallel processing
MAX_CONCURRENT_OPERATIONS=4          # Maximum concurrent backup operations
OPERATION_TIMEOUT=1800               # 30 minutes timeout for operations
BATCH_SIZE=10                        # Default batch size for operations

# Resource limits
MAX_MEMORY_USAGE="1G"                # Maximum memory usage
NICE_LEVEL=10                        # Process priority (0-19, higher = lower priority)

# =============================================================================
# INTEGRATION SETTINGS
# =============================================================================

# Claude integration
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
INTEGRATE_WITH_CLEANUP=true          # Integrate with cleanup command
INTEGRATE_WITH_GIT_HOOKS=true        # Integrate with git hooks

# External tool integration
USE_EXTERNAL_COMPRESSION=true        # Use external compression tools
PREFERRED_COMPRESSION="gzip"         # gzip, bzip2, xz
EXTERNAL_NOTIFICATION_COMMAND=""     # Custom notification command

# =============================================================================
# DEVELOPMENT AND DEBUGGING
# =============================================================================

# Development settings
DEBUG_MODE=false                     # Enable debug mode
VERBOSE_OUTPUT=false                 # Enable verbose output
DRY_RUN_MODE=false                   # Enable dry-run mode (no actual changes)
TRACE_OPERATIONS=false               # Trace all operations

# Testing settings
MOCK_GIT_OPERATIONS=false            # Mock git operations for testing
SIMULATE_DISK_PRESSURE=false        # Simulate disk pressure for testing
TEST_MODE=false                      # Enable test mode

# =============================================================================
# CUSTOM POLICIES
# =============================================================================

# Custom retention policies (can be overridden per backup type)
CUSTOM_RETENTION_POLICIES=""         # Path to custom policy definitions

# Hook scripts (executed at various points)
PRE_TRANSITION_HOOK=""              # Script to run before state transitions
POST_TRANSITION_HOOK=""             # Script to run after state transitions
PRE_CLEANUP_HOOK=""                 # Script to run before cleanup
POST_CLEANUP_HOOK=""                # Script to run after cleanup

# Export all configuration variables
set -a
EOF

    chmod 600 "$config_file"  # Secure permissions for config file
    log_info "Created default configuration: $config_file"
}

# Load component-specific configurations
load_component_configs() {
    local config_dir=$1
    
    # Load time-based trigger policies
    if [[ -f "$config_dir/time-policies.conf" ]]; then
        source "$config_dir/time-policies.conf"
    fi
    
    # Load disk monitoring policies  
    if [[ -f "$config_dir/disk-policies.conf" ]]; then
        source "$config_dir/disk-policies.conf"
    fi
    
    # Load user interface preferences
    if [[ -f "$config_dir/user-preferences.conf" ]]; then
        source "$config_dir/user-preferences.conf"
    fi
    
    # Load git integration settings
    if [[ -f "$config_dir/git-integration.conf" ]]; then
        source "$config_dir/git-integration.conf"
    fi
}

# Validate configuration values
validate_configuration() {
    local validation_errors=0
    
    # Validate directory paths
    validate_directory_config "$BACKUP_ROOT" "BACKUP_ROOT" || ((validation_errors++))
    validate_directory_config "$ARCHIVE_ROOT" "ARCHIVE_ROOT" || ((validation_errors++))
    validate_directory_config "$BACKUP_CONFIG_DIR" "BACKUP_CONFIG_DIR" || ((validation_errors++))
    
    # Validate timeouts (must be positive integers)
    validate_positive_integer "$CREATED_TO_PENDING_TIMEOUT" "CREATED_TO_PENDING_TIMEOUT" || ((validation_errors++))
    validate_positive_integer "$PENDING_TO_CLEANUP_TIMEOUT" "PENDING_TO_CLEANUP_TIMEOUT" || ((validation_errors++))
    validate_positive_integer "$CONFIRMED_TO_CLEANUP_TIMEOUT" "CONFIRMED_TO_CLEANUP_TIMEOUT" || ((validation_errors++))
    
    # Validate confidence thresholds (must be between 0.0 and 1.0)
    validate_confidence_value "$AUTO_CLEANUP_CONFIDENCE" "AUTO_CLEANUP_CONFIDENCE" || ((validation_errors++))
    validate_confidence_value "$AUTO_ARCHIVE_CONFIDENCE" "AUTO_ARCHIVE_CONFIDENCE" || ((validation_errors++))
    validate_confidence_value "$AUTO_DELETE_CONFIDENCE" "AUTO_DELETE_CONFIDENCE" || ((validation_errors++))
    
    # Validate disk thresholds (must be between 0 and 100)
    validate_percentage "$DISK_WARNING_THRESHOLD" "DISK_WARNING_THRESHOLD" || ((validation_errors++))
    validate_percentage "$DISK_CRITICAL_THRESHOLD" "DISK_CRITICAL_THRESHOLD" || ((validation_errors++))
    validate_percentage "$DISK_EMERGENCY_THRESHOLD" "DISK_EMERGENCY_THRESHOLD" || ((validation_errors++))
    
    # Validate threshold ordering
    if (( $(echo "$DISK_WARNING_THRESHOLD >= $DISK_CRITICAL_THRESHOLD" | bc -l) )); then
        log_error "DISK_WARNING_THRESHOLD must be less than DISK_CRITICAL_THRESHOLD"
        ((validation_errors++))
    fi
    
    if (( $(echo "$DISK_CRITICAL_THRESHOLD >= $DISK_EMERGENCY_THRESHOLD" | bc -l) )); then
        log_error "DISK_CRITICAL_THRESHOLD must be less than DISK_EMERGENCY_THRESHOLD"
        ((validation_errors++))
    fi
    
    # Validate strategy options
    validate_cleanup_strategy "$CLEANUP_STRATEGY" || ((validation_errors++))
    validate_emergency_strategy "$EMERGENCY_CLEANUP_STRATEGY" || ((validation_errors++))
    
    if (( validation_errors > 0 )); then
        log_error "Configuration validation failed with $validation_errors errors"
        return 1
    else
        log_debug "Configuration validation passed"
        return 0
    fi
}

# Configuration validation helpers
validate_directory_config() {
    local path=$1
    local var_name=$2
    
    if [[ -z "$path" ]]; then
        log_error "$var_name cannot be empty"
        return 1
    fi
    
    # Create directory if it doesn't exist
    if [[ ! -d "$path" ]]; then
        if mkdir -p "$path" 2>/dev/null; then
            log_debug "Created directory: $path"
        else
            log_error "Cannot create directory: $path"
            return 1
        fi
    fi
    
    # Check if directory is writable
    if [[ ! -w "$path" ]]; then
        log_error "Directory not writable: $path"
        return 1
    fi
    
    return 0
}

validate_positive_integer() {
    local value=$1
    local var_name=$2
    
    if [[ ! "$value" =~ ^[0-9]+$ ]] || (( value <= 0 )); then
        log_error "$var_name must be a positive integer (got: $value)"
        return 1
    fi
    
    return 0
}

validate_confidence_value() {
    local value=$1
    local var_name=$2
    
    if ! [[ "$value" =~ ^[0-9]*\.?[0-9]+$ ]] || (( $(echo "$value < 0.0 || $value > 1.0" | bc -l) )); then
        log_error "$var_name must be between 0.0 and 1.0 (got: $value)"
        return 1
    fi
    
    return 0
}

validate_percentage() {
    local value=$1
    local var_name=$2
    
    if [[ ! "$value" =~ ^[0-9]+$ ]] || (( value < 0 || value > 100 )); then
        log_error "$var_name must be between 0 and 100 (got: $value)"
        return 1
    fi
    
    return 0
}

validate_cleanup_strategy() {
    local strategy=$1
    local valid_strategies=("oldest_first" "largest_first" "confidence_based")
    
    for valid in "${valid_strategies[@]}"; do
        if [[ "$strategy" == "$valid" ]]; then
            return 0
        fi
    done
    
    log_error "Invalid cleanup strategy: $strategy (valid: ${valid_strategies[*]})"
    return 1
}

validate_emergency_strategy() {
    local strategy=$1
    local valid_strategies=("conservative" "aggressive" "nuclear")
    
    for valid in "${valid_strategies[@]}"; do
        if [[ "$strategy" == "$valid" ]]; then
            return 0
        fi
    done
    
    log_error "Invalid emergency strategy: $strategy (valid: ${valid_strategies[*]})"
    return 1
}

# Configuration update functions
update_config_value() {
    local setting=$1
    local value=$2
    local config_file=${3:-"$BACKUP_CONFIG_DIR/config.sh"}
    
    # Validate setting name
    if [[ ! "$setting" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
        log_error "Invalid setting name: $setting"
        return 1
    fi
    
    # Create backup of config file
    if [[ -f "$config_file" ]]; then
        cp "$config_file" "${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Update or add setting
    if grep -q "^${setting}=" "$config_file" 2>/dev/null; then
        # Update existing setting
        sed -i "s/^${setting}=.*/${setting}=\"${value}\"/" "$config_file"
        log_info "Updated configuration: $setting = $value"
    else
        # Add new setting
        echo "${setting}=\"${value}\"" >> "$config_file"
        log_info "Added configuration: $setting = $value"
    fi
    
    # Re-validate configuration
    if validate_configuration; then
        log_success "Configuration update completed successfully"
        return 0
    else
        log_error "Configuration validation failed after update"
        # Restore backup
        if [[ -f "${config_file}.backup.$(date +%Y%m%d_%H%M%S)" ]]; then
            mv "${config_file}.backup.$(date +%Y%m%d_%H%M%S)" "$config_file"
            log_info "Configuration restored from backup"
        fi
        return 1
    fi
}

# Configuration templates for different use cases
create_conservative_config() {
    local config_file=$1
    
    # Copy default config and modify for conservative settings
    create_default_config "$config_file"
    
    # Override with conservative values
    cat >> "$config_file" << 'EOF'

# Conservative configuration overrides
AUTO_CLEANUP_CONFIDENCE=0.95           # Very high confidence required
AUTO_ARCHIVE_CONFIDENCE=0.98           # Very high confidence for archiving
MANUAL_REVIEW_CONFIDENCE=0.80          # Lower threshold for manual review
EMERGENCY_CLEANUP_STRATEGY="conservative"
MAX_CLEANUP_PER_CYCLE=5                # Smaller cleanup batches
REQUIRE_USER_CONFIRMATION=true         # Always require confirmation
EOF

    log_info "Created conservative configuration: $config_file"
}

create_aggressive_config() {
    local config_file=$1
    
    # Copy default config and modify for aggressive settings
    create_default_config "$config_file"
    
    # Override with aggressive values
    cat >> "$config_file" << 'EOF'

# Aggressive configuration overrides
AUTO_CLEANUP_CONFIDENCE=0.70           # Lower confidence required
AUTO_ARCHIVE_CONFIDENCE=0.75           # Lower confidence for archiving
EMERGENCY_CLEANUP_STRATEGY="aggressive"
MAX_CLEANUP_PER_CYCLE=20               # Larger cleanup batches
DISK_WARNING_THRESHOLD=60              # Earlier disk warnings
DISK_CRITICAL_THRESHOLD=75             # Earlier critical alerts
CREATED_TO_PENDING_TIMEOUT=900         # 15 minutes instead of 30
PENDING_TO_CLEANUP_TIMEOUT=86400       # 1 day instead of 3
EOF

    log_info "Created aggressive configuration: $config_file"
}

create_development_config() {
    local config_file=$1
    
    # Copy default config and modify for development
    create_default_config "$config_file"
    
    # Override with development values
    cat >> "$config_file" << 'EOF'

# Development configuration overrides
DEBUG_MODE=true                        # Enable debug output
VERBOSE_OUTPUT=true                    # Enable verbose logging
LOG_LEVEL="DEBUG"                      # Debug level logging
DRY_RUN_MODE=true                      # No actual changes
TEST_MODE=true                         # Enable test mode
TIME_CHECK_INTERVAL=60                 # More frequent checks
DISK_CHECK_INTERVAL=30                 # More frequent disk checks
BACKUP_ROOT="/tmp/claude-backups-dev"  # Development backup directory
ARCHIVE_ROOT="/tmp/claude-archives-dev" # Development archive directory
EOF

    log_info "Created development configuration: $config_file"
}

# Configuration export and import
export_configuration() {
    local export_file=$1
    local config_dir=${BACKUP_CONFIG_DIR:-"$HOME/.claude/backup-config"}
    
    if [[ -z "$export_file" ]]; then
        export_file="backup-config-export-$(date +%Y%m%d_%H%M%S).tar.gz"
    fi
    
    log_info "Exporting configuration to: $export_file"
    
    # Create archive of configuration directory
    if tar -czf "$export_file" -C "$(dirname "$config_dir")" "$(basename "$config_dir")"; then
        log_success "Configuration exported successfully"
        echo "Export file: $export_file"
        echo "Size: $(du -sh "$export_file" | cut -f1)"
        return 0
    else
        log_error "Failed to export configuration"
        return 1
    fi
}

import_configuration() {
    local import_file=$1
    local config_dir=${BACKUP_CONFIG_DIR:-"$HOME/.claude/backup-config"}
    
    if [[ -z "$import_file" ]] || [[ ! -f "$import_file" ]]; then
        log_error "Import file not found: $import_file"
        return 1
    fi
    
    log_info "Importing configuration from: $import_file"
    
    # Create backup of current configuration
    if [[ -d "$config_dir" ]]; then
        local backup_file="backup-config-backup-$(date +%Y%m%d_%H%M%S).tar.gz"
        tar -czf "$backup_file" -C "$(dirname "$config_dir")" "$(basename "$config_dir")"
        log_info "Current configuration backed up to: $backup_file"
    fi
    
    # Extract imported configuration
    if tar -xzf "$import_file" -C "$(dirname "$config_dir")"; then
        log_success "Configuration imported successfully"
        
        # Validate imported configuration
        if validate_configuration; then
            log_success "Imported configuration is valid"
            return 0
        else
            log_error "Imported configuration failed validation"
            return 1
        fi
    else
        log_error "Failed to import configuration"
        return 1
    fi
}

# Configuration status and reporting
show_configuration_status() {
    echo "=== Backup Trigger System Configuration Status ==="
    echo ""
    
    # Basic information
    echo "Configuration Directory: $BACKUP_CONFIG_DIR"
    echo "Backup Directory: $BACKUP_ROOT"
    echo "Archive Directory: $ARCHIVE_ROOT"
    echo ""
    
    # Key settings
    echo "=== Key Settings ==="
    echo "Cleanup Strategy: $CLEANUP_STRATEGY"
    echo "Emergency Strategy: $EMERGENCY_CLEANUP_STRATEGY"
    echo "Auto Cleanup Confidence: $AUTO_CLEANUP_CONFIDENCE"
    echo "Auto Archive Confidence: $AUTO_ARCHIVE_CONFIDENCE"
    echo "Disk Warning Threshold: ${DISK_WARNING_THRESHOLD}%"
    echo "Disk Critical Threshold: ${DISK_CRITICAL_THRESHOLD}%"
    echo "Disk Emergency Threshold: ${DISK_EMERGENCY_THRESHOLD}%"
    echo ""
    
    # Timeouts
    echo "=== Timeout Settings ==="
    echo "Created→Pending: ${CREATED_TO_PENDING_TIMEOUT}s ($(( CREATED_TO_PENDING_TIMEOUT / 60 ))m)"
    echo "Pending→Cleanup: ${PENDING_TO_CLEANUP_TIMEOUT}s ($(( PENDING_TO_CLEANUP_TIMEOUT / 86400 ))d)"
    echo "Confirmed→Cleanup: ${CONFIRMED_TO_CLEANUP_TIMEOUT}s ($(( CONFIRMED_TO_CLEANUP_TIMEOUT / 86400 ))d)"
    echo ""
    
    # Daemon intervals
    echo "=== Daemon Intervals ==="
    echo "Time Check: ${TIME_CHECK_INTERVAL}s"
    echo "Disk Check: ${DISK_CHECK_INTERVAL}s"
    echo "Policy Evaluation: ${POLICY_EVALUATION_INTERVAL}s"
    echo ""
    
    # Feature flags
    echo "=== Feature Flags ==="
    echo "Git Integration: $GIT_HOOK_INTEGRATION"
    echo "Archive Enabled: $ARCHIVE_ENABLED"
    echo "Metrics Enabled: $ENABLE_METRICS"
    echo "Alerts Enabled: $ENABLE_ALERTS"
    echo "Debug Mode: $DEBUG_MODE"
    echo "Dry Run Mode: $DRY_RUN_MODE"
    echo ""
    
    # Configuration file status
    echo "=== Configuration Files ==="
    local main_config="$BACKUP_CONFIG_DIR/config.sh"
    if [[ -f "$main_config" ]]; then
        echo "Main Config: ✓ ($(wc -l < "$main_config") lines, modified $(date -r "$main_config" 2>/dev/null))"
    else
        echo "Main Config: ✗ Missing"
    fi
    
    for config_file in time-policies.conf disk-policies.conf user-preferences.conf git-integration.conf; do
        local config_path="$BACKUP_CONFIG_DIR/$config_file"
        if [[ -f "$config_path" ]]; then
            echo "$config_file: ✓"
        else
            echo "$config_file: ✗ Using defaults"
        fi
    done
}

# Configuration wizard for initial setup
run_configuration_wizard() {
    echo "=== Backup Trigger System Configuration Wizard ==="
    echo ""
    echo "This wizard will help you configure the backup trigger system."
    echo "Press Enter to use default values."
    echo ""
    
    # Basic setup
    echo "=== Basic Setup ==="
    
    local backup_root
    read -p "Backup directory [$BACKUP_ROOT]: " backup_root
    backup_root=${backup_root:-$BACKUP_ROOT}
    
    local archive_root
    read -p "Archive directory [$ARCHIVE_ROOT]: " archive_root
    archive_root=${archive_root:-$ARCHIVE_ROOT}
    
    # Cleanup strategy
    echo ""
    echo "=== Cleanup Strategy ==="
    echo "1. Conservative (high confidence required)"
    echo "2. Moderate (balanced approach)"
    echo "3. Aggressive (lower confidence, faster cleanup)"
    
    local strategy_choice
    read -p "Choose strategy (1-3) [2]: " strategy_choice
    strategy_choice=${strategy_choice:-2}
    
    local cleanup_confidence
    local emergency_strategy
    case "$strategy_choice" in
        1)
            cleanup_confidence=0.95
            emergency_strategy="conservative"
            ;;
        3)
            cleanup_confidence=0.70
            emergency_strategy="aggressive"
            ;;
        *)
            cleanup_confidence=0.85
            emergency_strategy="moderate"
            ;;
    esac
    
    # Disk thresholds
    echo ""
    echo "=== Disk Space Thresholds ==="
    
    local disk_warning
    read -p "Warning threshold % [$DISK_WARNING_THRESHOLD]: " disk_warning
    disk_warning=${disk_warning:-$DISK_WARNING_THRESHOLD}
    
    local disk_critical
    read -p "Critical threshold % [$DISK_CRITICAL_THRESHOLD]: " disk_critical
    disk_critical=${disk_critical:-$DISK_CRITICAL_THRESHOLD}
    
    # Git integration
    echo ""
    echo "=== Git Integration ==="
    
    local git_integration
    read -p "Enable git hook integration? (y/N): " git_integration
    if [[ "$git_integration" =~ ^[Yy]$ ]]; then
        git_integration="true"
    else
        git_integration="false"
    fi
    
    # Generate configuration
    echo ""
    echo "=== Generating Configuration ==="
    
    local config_file="$BACKUP_CONFIG_DIR/config.sh"
    
    # Update configuration values
    update_config_value "BACKUP_ROOT" "$backup_root" "$config_file"
    update_config_value "ARCHIVE_ROOT" "$archive_root" "$config_file"
    update_config_value "AUTO_CLEANUP_CONFIDENCE" "$cleanup_confidence" "$config_file"
    update_config_value "EMERGENCY_CLEANUP_STRATEGY" "$emergency_strategy" "$config_file"
    update_config_value "DISK_WARNING_THRESHOLD" "$disk_warning" "$config_file"
    update_config_value "DISK_CRITICAL_THRESHOLD" "$disk_critical" "$config_file"
    update_config_value "GIT_HOOK_INTEGRATION" "$git_integration" "$config_file"
    
    echo ""
    log_success "Configuration wizard completed!"
    echo ""
    echo "Next steps:"
    echo "1. Review configuration: backup config status"
    echo "2. Start daemons: backup start-all"
    echo "3. Install git hooks: backup git-hooks install"
}

# Main configuration management interface
main() {
    local action=${1:-"status"}
    
    case "$action" in
        "init"|"initialize")
            create_default_config "$BACKUP_CONFIG_DIR/config.sh"
            ;;
        "validate")
            load_backup_config && validate_configuration
            ;;
        "status")
            load_backup_config && show_configuration_status
            ;;
        "wizard")
            run_configuration_wizard
            ;;
        "update")
            update_config_value "$2" "$3"
            ;;
        "export")
            export_configuration "$2"
            ;;
        "import")
            import_configuration "$2"
            ;;
        "conservative")
            create_conservative_config "$BACKUP_CONFIG_DIR/config.sh"
            ;;
        "aggressive")
            create_aggressive_config "$BACKUP_CONFIG_DIR/config.sh"
            ;;
        "development")
            create_development_config "$BACKUP_CONFIG_DIR/config.sh"
            ;;
        *)
            echo "Usage: $0 {init|validate|status|wizard|update|export|import|conservative|aggressive|development}"
            echo ""
            echo "Configuration Management Commands:"
            echo "  init                    - Create default configuration"
            echo "  validate               - Validate current configuration"
            echo "  status                 - Show configuration status"
            echo "  wizard                 - Run configuration wizard"
            echo "  update <setting> <value> - Update configuration setting"
            echo "  export [file]          - Export configuration"
            echo "  import <file>          - Import configuration"
            echo ""
            echo "Configuration Templates:"
            echo "  conservative           - Create conservative configuration"
            echo "  aggressive             - Create aggressive configuration"
            echo "  development            - Create development configuration"
            exit 1
            ;;
    esac
}

# Export functions for use by other components
export -f load_backup_config
export -f validate_configuration
export -f update_config_value
export -f show_configuration_status

# Load configuration automatically when sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    load_backup_config
fi

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi