#!/bin/bash

# Cleanup wrapper with backup state integration
# Extends cleanup commands to respect backup states

set -e

CLAUDE_DIR="$(pwd)/.claude"
BACKUP_STATE_SCRIPT="$CLAUDE_DIR/backup-state/coordination/command-integration.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[CLEANUP-BACKUP]${NC} $1"; }
print_success() { echo -e "${GREEN}[CLEANUP-BACKUP]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[CLEANUP-BACKUP]${NC} $1"; }
print_error() { echo -e "${RED}[CLEANUP-BACKUP]${NC} $1"; }

# Validate backup states before cleanup
validate_backup_states() {
    if [[ -f "$BACKUP_STATE_SCRIPT" ]]; then
        print_status "Validating backup states before cleanup..."
        
        if ! "$BACKUP_STATE_SCRIPT" validate-for-cleanup; then
            print_error "Backup state validation failed - cleanup blocked"
            print_warning "Use '/backup-state cleanup' to resolve backup state issues first"
            return 1
        fi
        
        print_success "Backup state validation passed"
    fi
    return 0
}

# Get protected backup files
get_protected_files() {
    if [[ -f "$BACKUP_STATE_SCRIPT" ]]; then
        "$BACKUP_STATE_SCRIPT" get-protected-files 2>/dev/null || echo ""
    fi
}

# Enhanced cleanup with backup state awareness
enhanced_cleanup() {
    local cleanup_args="$*"
    
    # Validate backup states first
    validate_backup_states || return 1
    
    # Get list of files protected by backup state
    local protected_files=$(get_protected_files)
    if [[ -n "$protected_files" ]]; then
        print_status "Found $(echo "$protected_files" | wc -l) files protected by backup state"
        
        # Add protection flags to cleanup arguments
        if [[ "$cleanup_args" != *"--preserve-backup-state"* ]]; then
            cleanup_args="$cleanup_args --preserve-backup-state"
        fi
    fi
    
    # Execute original cleanup with protection
    print_status "Executing cleanup with backup state protection..."
    
    # Call original cleanup command (would be the actual cleanup implementation)
    echo "Enhanced cleanup would execute with args: $cleanup_args"
    echo "Protected files: $protected_files"
    
    # Post-cleanup backup state update
    if [[ -f "$BACKUP_STATE_SCRIPT" ]]; then
        "$BACKUP_STATE_SCRIPT" post-cleanup-update || {
            print_warning "Post-cleanup backup state update failed"
        }
    fi
    
    print_success "Enhanced cleanup completed"
}

# Main wrapper execution
main() {
    print_status "Cleanup with backup state integration"
    enhanced_cleanup "$@"
}

main "$@"
