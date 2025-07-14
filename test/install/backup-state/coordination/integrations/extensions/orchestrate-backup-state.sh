#!/bin/bash

# Orchestrate extension for backup state coordination
# Enables orchestrated backup state management workflows

set -e

CLAUDE_DIR="$(pwd)/.claude"
BACKUP_STATE_SCRIPT="$CLAUDE_DIR/backup-state/coordination/command-integration.sh"

# Orchestrated backup state management
orchestrate_backup_workflow() {
    local workflow_type="$1"
    local target_path="$2"
    
    case "$workflow_type" in
        "cleanup-validation")
            orchestrate_cleanup_validation "$target_path"
            ;;
        "multi-repo-sync")
            orchestrate_multi_repo_sync "$target_path"
            ;;
        "state-migration")
            orchestrate_state_migration "$target_path"
            ;;
        "recovery")
            orchestrate_recovery_workflow "$target_path"
            ;;
        *)
            echo "Unknown backup state workflow: $workflow_type"
            return 1
            ;;
    esac
}

orchestrate_cleanup_validation() {
    local target_path="$1"
    
    echo "🔄 Orchestrating backup state cleanup validation workflow..."
    
    # Spawn agents for parallel validation
    echo "Agent 1: Validating backup state consistency"
    "$BACKUP_STATE_SCRIPT" validate-state-consistency &
    local agent1_pid=$!
    
    echo "Agent 2: Checking for protected files"
    "$BACKUP_STATE_SCRIPT" get-protected-files > /tmp/protected_files_$$ &
    local agent2_pid=$!
    
    echo "Agent 3: Analyzing cleanup impact"
    "$BACKUP_STATE_SCRIPT" analyze-cleanup-impact "$target_path" &
    local agent3_pid=$!
    
    # Wait for all agents to complete
    wait $agent1_pid $agent2_pid $agent3_pid
    
    echo "✅ Backup state cleanup validation workflow completed"
}

orchestrate_multi_repo_sync() {
    local target_path="$1"
    
    echo "🔄 Orchestrating multi-repository backup state synchronization..."
    
    # Find related repositories
    local repos=$(find "$target_path" -name ".git" -type d | head -10)
    
    for repo in $repos; do
        local repo_dir=$(dirname "$repo")
        echo "Agent: Syncing backup state for $repo_dir"
        
        (
            cd "$repo_dir"
            if [[ -f ".claude/backup-state/coordination/command-integration.sh" ]]; then
                ".claude/backup-state/coordination/command-integration.sh" sync-state
            fi
        ) &
    done
    
    # Wait for all sync operations
    wait
    
    echo "✅ Multi-repository backup state synchronization completed"
}

orchestrate_state_migration() {
    local target_path="$1"
    
    echo "🔄 Orchestrating backup state migration workflow..."
    
    # Create migration plan
    "$BACKUP_STATE_SCRIPT" create-migration-plan "$target_path"
    
    # Execute migration phases
    echo "Phase 1: Pre-migration validation"
    "$BACKUP_STATE_SCRIPT" pre-migration-validation
    
    echo "Phase 2: State data migration"
    "$BACKUP_STATE_SCRIPT" migrate-state-data
    
    echo "Phase 3: Post-migration verification"
    "$BACKUP_STATE_SCRIPT" post-migration-verification
    
    echo "✅ Backup state migration workflow completed"
}

orchestrate_recovery_workflow() {
    local target_path="$1"
    
    echo "🔄 Orchestrating backup state recovery workflow..."
    
    # Recovery assessment
    echo "Agent 1: Assessing state corruption"
    "$BACKUP_STATE_SCRIPT" assess-corruption &
    local assess_pid=$!
    
    echo "Agent 2: Identifying recovery points"
    "$BACKUP_STATE_SCRIPT" identify-recovery-points &
    local recovery_pid=$!
    
    wait $assess_pid $recovery_pid
    
    # Execute recovery
    echo "Executing recovery plan..."
    "$BACKUP_STATE_SCRIPT" execute-recovery-plan
    
    echo "✅ Backup state recovery workflow completed"
}

# Main orchestration dispatcher
main() {
    local command="$1"
    shift
    
    case "$command" in
        "backup-workflow")
            orchestrate_backup_workflow "$@"
            ;;
        *)
            echo "Usage: $0 backup-workflow <workflow_type> <target_path>"
            echo ""
            echo "Available workflows:"
            echo "  cleanup-validation  - Orchestrated cleanup validation"
            echo "  multi-repo-sync    - Multi-repository state synchronization"
            echo "  state-migration    - Backup state migration"
            echo "  recovery          - Recovery workflow orchestration"
            exit 1
            ;;
    esac
}

main "$@"
