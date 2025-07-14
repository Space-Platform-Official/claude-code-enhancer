#!/bin/bash
# Post-cleanup hook for backup state updates

BACKUP_STATE_SCRIPT="$(pwd)/.claude/backup-state/coordination/command-integration.sh"

if [[ -f "$BACKUP_STATE_SCRIPT" ]]; then
    # Update backup states after cleanup
    "$BACKUP_STATE_SCRIPT" post-cleanup-update || {
        echo "Warning: Post-cleanup backup state update failed"
    }
    
    # Validate state consistency
    "$BACKUP_STATE_SCRIPT" validate-state-consistency || {
        echo "Warning: Backup state consistency check failed"
    }
fi
