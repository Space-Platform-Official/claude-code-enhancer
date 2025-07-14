#!/bin/bash

# Smart merge wrapper with backup state integration
# Extends smart-merge-claude.sh with backup state tracking

set -e

CLAUDE_DIR="$(pwd)/.claude"
ATOMIC_OPS_SCRIPT="$CLAUDE_DIR/backup-state/coordination/atomic-operations.sh"
ORIGINAL_SMART_MERGE="$(dirname "$CLAUDE_DIR")/smart-merge-claude.sh"

# Enhanced smart merge with backup state
enhanced_smart_merge() {
    local target_dir="$1"
    
    echo "🔄 Enhanced Smart Merge with Backup State Integration"
    
    # Use atomic operations for smart merge
    if [[ -f "$ATOMIC_OPS_SCRIPT" ]]; then
        "$ATOMIC_OPS_SCRIPT" atomic-smart-merge "$target_dir"
    else
        # Fallback to original smart merge
        "$ORIGINAL_SMART_MERGE" "$target_dir"
    fi
}

main() {
    enhanced_smart_merge "$@"
}

main "$@"
