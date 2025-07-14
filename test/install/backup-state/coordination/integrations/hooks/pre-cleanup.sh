#!/bin/bash
# Pre-cleanup hook for backup state validation

BACKUP_STATE_SCRIPT="$(pwd)/.claude/backup-state/coordination/command-integration.sh"

if [[ -f "$BACKUP_STATE_SCRIPT" ]]; then
    # Validate backup states
    "$BACKUP_STATE_SCRIPT" validate-for-cleanup || exit 1
    
    # Create cleanup checkpoint
    "$BACKUP_STATE_SCRIPT" create-cleanup-checkpoint || {
        echo "Warning: Failed to create cleanup checkpoint"
    }
fi
