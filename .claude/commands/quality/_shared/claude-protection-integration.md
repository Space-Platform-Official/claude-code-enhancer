---
description: Integration layer for .claude protection override mechanisms
phase: phase-003
dependencies: ["claude-protection-overrides.md"]
status: implementation
---

# .Claude Protection Integration Layer

**Integration layer connecting override mechanisms with existing quality commands**

This module provides seamless integration between the override mechanisms and existing quality commands without breaking existing functionality.

## Command Wrapper System

### Universal Command Integration

```bash
# Source the override mechanisms
source "${CLAUDE_COMMANDS_DIR:-/Users/nashgao/Desktop/claude/claude-code/instruction/.claude/commands}/quality/_shared/claude-protection-overrides.md"

# Universal wrapper for any quality command
integrate_quality_command_with_claude_protection() {
    local command_name=$1
    local original_function=$2
    shift 2
    local args=("$@")
    
    # Check if this is a quality command that needs .claude protection
    if ! is_quality_command "$command_name"; then
        # Not a quality command, execute normally
        "$original_function" "${args[@]}"
        return $?
    fi
    
    # Parse and apply override flags
    local processed_args
    if ! processed_args=$(integrate_claude_overrides "$command_name" "${args[@]}"); then
        return 1  # Override system blocked the operation
    fi
    
    # Convert processed args back to array
    local final_args=()
    if [ -n "$processed_args" ]; then
        IFS=' ' read -ra final_args <<< "$processed_args"
    fi
    
    # Check if we have any paths to process
    if [ ${#final_args[@]} -eq 0 ]; then
        echo "ℹ️  No paths to process after applying .claude protection filters"
        return 0
    fi
    
    # Execute original command with protected arguments
    "$original_function" "${final_args[@]}"
    local exit_code=$?
    
    # Log final result
    if [ $exit_code -eq 0 ]; then
        log_audit_event "$command_name" "${final_args[*]}" "COMPLETED"
    else
        log_audit_event "$command_name" "${final_args[*]}" "FAILED"
    fi
    
    return $exit_code
}

# Check if command is a quality command that needs protection
is_quality_command() {
    local command_name=$1
    
    case "$command_name" in
        format_codebase|cleanup_codebase|dedupe_codebase|verify_codebase|analyze_codebase)
            return 0
            ;;
        format|cleanup|dedupe|verify|analyze)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
```

## Individual Command Integrations

### Format Command Integration

```bash
# Enhanced format command with .claude protection
format_codebase_with_protection() {
    # Set up command context
    local operation="format"
    local target=${1:-.}
    shift
    local args=("$@")
    
    # Add target to args for processing
    local all_args=("$target" "${args[@]}")
    
    echo "🎨 Starting format operation with .claude protection..."
    
    # Apply .claude protection and get filtered paths
    local protected_args
    if ! protected_args=$(integrate_claude_overrides "$operation" "${all_args[@]}"); then
        display_claude_error "access_denied" "format operation"
        return 1
    fi
    
    # Parse protected args back
    local protected_target
    local protected_extra_args=()
    if [ -n "$protected_args" ]; then
        IFS=' ' read -ra parsed_args <<< "$protected_args"
        protected_target="${parsed_args[0]}"
        protected_extra_args=("${parsed_args[@]:1}")
    else
        echo "ℹ️  No paths to format after applying protection filters"
        return 0
    fi
    
    # Create safety snapshot before formatting
    if is_claude_operation_enabled && ! is_claude_dry_run_mode; then
        echo "📸 Creating safety snapshot before format operation..."
        local snapshot_path
        if ! snapshot_path=$(create_safety_snapshot "$protected_target" "format_with_claude"); then
            echo "❌ Failed to create safety snapshot"
            log_audit_event "$operation" "$protected_target" "SNAPSHOT_FAILED"
            return 1
        fi
        echo "✅ Safety snapshot created: $snapshot_path"
        log_audit_event "$operation" "$protected_target" "SNAPSHOT_CREATED" "$snapshot_path"
    fi
    
    # Execute original format function
    echo "🔄 Executing format operation on protected paths..."
    if format_codebase_original "$protected_target" "${protected_extra_args[@]}"; then
        echo "✅ Format operation completed successfully"
        
        # Verify integrity if .claude paths were involved
        if is_claude_operation_enabled && ! is_claude_dry_run_mode; then
            echo "🔍 Verifying integrity after format operation..."
            if ! verify_operation_integrity "$protected_target" "format" "$snapshot_path"; then
                echo "⚠️  Integrity verification warnings detected"
                log_audit_event "$operation" "$protected_target" "INTEGRITY_WARNING"
            else
                echo "✅ Integrity verification passed"
                log_audit_event "$operation" "$protected_target" "INTEGRITY_VERIFIED"
            fi
        fi
        
        return 0
    else
        echo "❌ Format operation failed"
        log_audit_event "$operation" "$protected_target" "OPERATION_FAILED"
        
        # Offer rollback if snapshot exists
        if [ -n "$snapshot_path" ] && [ -d "$snapshot_path" ]; then
            echo ""
            echo "💡 A safety snapshot was created before the operation"
            echo "   Snapshot: $snapshot_path"
            echo ""
            read -p "🔄 Would you like to rollback to the snapshot? [y/N]: " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if rollback_to_snapshot "$snapshot_path" "$protected_target"; then
                    echo "✅ Successfully rolled back to snapshot"
                    log_audit_event "$operation" "$protected_target" "ROLLBACK_SUCCESS"
                else
                    echo "❌ Rollback failed"
                    log_audit_event "$operation" "$protected_target" "ROLLBACK_FAILED"
                fi
            fi
        fi
        
        return 1
    fi
}

# Backup original format function
if declare -f format_codebase >/dev/null 2>&1; then
    eval "$(declare -f format_codebase | sed 's/^format_codebase/format_codebase_original/')"
    
    # Replace with protected version
    format_codebase() {
        format_codebase_with_protection "$@"
    }
fi
```

### Cleanup Command Integration

```bash
# Enhanced cleanup command with .claude protection
cleanup_codebase_with_protection() {
    local operation="cleanup"
    local target=${1:-.}
    shift
    local args=("$@")
    
    echo "🧹 Starting cleanup operation with .claude protection..."
    
    # Special handling for .claude cleanup - show what would be cleaned
    local all_args=("$target" "${args[@]}")
    local claude_paths=()
    
    # Identify .claude paths
    for arg in "${all_args[@]}"; do
        if [[ "$arg" == *"/.claude/"* ]] || [[ "$arg" == *"/.claude" ]]; then
            claude_paths+=("$arg")
        fi
    done
    
    # Show .claude cleanup preview if any .claude paths detected
    if [ ${#claude_paths[@]} -gt 0 ]; then
        echo ""
        echo "🔍 .claude cleanup preview:"
        for claude_path in "${claude_paths[@]}"; do
            echo "  Analyzing: $claude_path"
            if [ -d "$claude_path" ]; then
                local cleanup_candidates=$(find "$claude_path" -name "*.bak" -o -name "*.tmp" -o -name "*~" 2>/dev/null)
                if [ -n "$cleanup_candidates" ]; then
                    echo "    Would clean:"
                    echo "$cleanup_candidates" | sed 's/^/      /'
                else
                    echo "    No temporary files found"
                fi
            fi
        done
        echo ""
    fi
    
    # Apply .claude protection
    local protected_args
    if ! protected_args=$(integrate_claude_overrides "$operation" "${all_args[@]}"); then
        display_claude_error "access_denied" "cleanup operation"
        return 1
    fi
    
    # Parse protected args
    local protected_target
    local protected_extra_args=()
    if [ -n "$protected_args" ]; then
        IFS=' ' read -ra parsed_args <<< "$protected_args"
        protected_target="${parsed_args[0]}"
        protected_extra_args=("${parsed_args[@]:1}")
    else
        echo "ℹ️  No paths to clean after applying protection filters"
        return 0
    fi
    
    # Create enhanced safety snapshot for cleanup operations
    if is_claude_operation_enabled && ! is_claude_dry_run_mode; then
        echo "📸 Creating comprehensive safety snapshot before cleanup..."
        local snapshot_path
        if ! snapshot_path=$(create_safety_snapshot "$protected_target" "cleanup_with_claude"); then
            echo "❌ Failed to create safety snapshot"
            log_audit_event "$operation" "$protected_target" "SNAPSHOT_FAILED"
            return 1
        fi
        echo "✅ Safety snapshot created: $snapshot_path"
        
        # Additional .claude-specific backup
        if [ ${#claude_paths[@]} -gt 0 ]; then
            local claude_backup_path="$snapshot_path/.claude-specific"
            mkdir -p "$claude_backup_path"
            for claude_path in "${claude_paths[@]}"; do
                if [ -d "$claude_path" ]; then
                    local rel_path=${claude_path#$protected_target/}
                    mkdir -p "$claude_backup_path/$(dirname "$rel_path")"
                    cp -r "$claude_path" "$claude_backup_path/$(dirname "$rel_path")/"
                fi
            done
            echo "✅ Additional .claude backup created in snapshot"
        fi
        
        log_audit_event "$operation" "$protected_target" "SNAPSHOT_CREATED" "$snapshot_path"
    fi
    
    # Execute original cleanup function
    echo "🔄 Executing cleanup operation on protected paths..."
    if cleanup_codebase_original "$protected_target" "${protected_extra_args[@]}"; then
        echo "✅ Cleanup operation completed successfully"
        
        # Enhanced verification for cleanup operations
        if is_claude_operation_enabled && ! is_claude_dry_run_mode; then
            echo "🔍 Verifying cleanup operation integrity..."
            
            # Check that important .claude files weren't accidentally removed
            local critical_claude_files=(
                ".claude/commands"
                ".claude/CLAUDE.md"
                ".claude/templates"
            )
            
            local missing_files=()
            for critical_file in "${critical_claude_files[@]}"; do
                local full_path="$protected_target/$critical_file"
                if [ ! -e "$full_path" ] && [ -e "$snapshot_path/$critical_file" ]; then
                    missing_files+=("$critical_file")
                fi
            done
            
            if [ ${#missing_files[@]} -gt 0 ]; then
                echo "⚠️  CRITICAL: Important .claude files were removed!"
                echo "Missing files:"
                for missing in "${missing_files[@]}"; do
                    echo "  - $missing"
                done
                
                echo ""
                echo "🚨 This may break Claude Code functionality!"
                read -p "🔄 Restore missing .claude files from snapshot? [Y/n]: " -r
                if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                    for missing in "${missing_files[@]}"; do
                        local src_path="$snapshot_path/$missing"
                        local dest_path="$protected_target/$missing"
                        if [ -e "$src_path" ]; then
                            mkdir -p "$(dirname "$dest_path")"
                            cp -r "$src_path" "$dest_path"
                            echo "✅ Restored: $missing"
                        fi
                    done
                    log_audit_event "$operation" "$protected_target" "CRITICAL_FILES_RESTORED"
                fi
            else
                echo "✅ All critical .claude files preserved"
            fi
            
            # Standard integrity check
            if ! verify_operation_integrity "$protected_target" "cleanup" "$snapshot_path"; then
                echo "⚠️  Integrity verification warnings detected"
                log_audit_event "$operation" "$protected_target" "INTEGRITY_WARNING"
            else
                echo "✅ Integrity verification passed"
                log_audit_event "$operation" "$protected_target" "INTEGRITY_VERIFIED"
            fi
        fi
        
        return 0
    else
        echo "❌ Cleanup operation failed"
        log_audit_event "$operation" "$protected_target" "OPERATION_FAILED"
        
        # Offer rollback
        if [ -n "$snapshot_path" ] && [ -d "$snapshot_path" ]; then
            echo ""
            echo "💡 A safety snapshot was created before the operation"
            read -p "🔄 Would you like to rollback to the snapshot? [y/N]: " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if rollback_to_snapshot "$snapshot_path" "$protected_target"; then
                    echo "✅ Successfully rolled back to snapshot"
                    log_audit_event "$operation" "$protected_target" "ROLLBACK_SUCCESS"
                else
                    echo "❌ Rollback failed"
                    log_audit_event "$operation" "$protected_target" "ROLLBACK_FAILED"
                fi
            fi
        fi
        
        return 1
    fi
}

# Backup original cleanup function
if declare -f cleanup_codebase >/dev/null 2>&1; then
    eval "$(declare -f cleanup_codebase | sed 's/^cleanup_codebase/cleanup_codebase_original/')"
    
    # Replace with protected version
    cleanup_codebase() {
        cleanup_codebase_with_protection "$@"
    }
fi
```

### Dedupe Command Integration

```bash
# Enhanced dedupe command with .claude protection
dedupe_codebase_with_protection() {
    local operation="dedupe"
    local target=${1:-.}
    shift
    local args=("$@")
    
    echo "🔄 Starting deduplication operation with .claude protection..."
    
    # Dedupe operations are high-risk for .claude directories
    # Show detailed analysis first
    local all_args=("$target" "${args[@]}")
    local claude_paths=()
    
    for arg in "${all_args[@]}"; do
        if [[ "$arg" == *"/.claude/"* ]] || [[ "$arg" == *"/.claude" ]]; then
            claude_paths+=("$arg")
        fi
    done
    
    if [ ${#claude_paths[@]} -gt 0 ]; then
        echo ""
        echo "🔍 .claude deduplication analysis:"
        for claude_path in "${claude_paths[@]}"; do
            echo "  Analyzing: $claude_path"
            if [ -d "$claude_path" ]; then
                # Analyze duplicate commands
                local duplicate_commands=$(find "$claude_path" -name "*.md" -type f | while read -r file; do
                    local basename_file=$(basename "$file")
                    echo "$basename_file"
                done | sort | uniq -d)
                
                if [ -n "$duplicate_commands" ]; then
                    echo "    Potential duplicate commands:"
                    echo "$duplicate_commands" | sed 's/^/      /'
                else
                    echo "    No duplicate commands found"
                fi
                
                # Analyze duplicate content within files
                find "$claude_path" -name "*.md" -type f | while read -r file; do
                    local duplicate_sections=$(grep -n "^#" "$file" | cut -d: -f2 | sort | uniq -d | wc -l)
                    if [ "$duplicate_sections" -gt 0 ]; then
                        echo "    $(basename "$file"): $duplicate_sections duplicate sections"
                    fi
                done
            fi
        done
        echo ""
        
        # Extra warning for .claude dedupe
        echo "⚠️  WARNING: Deduplication in .claude directories is HIGH RISK"
        echo "   - Command templates may have intentional variations"
        echo "   - Configuration files may have environment-specific differences"
        echo "   - Template inheritance patterns may be broken"
        echo ""
        
        # Force confirmation for .claude dedupe operations
        if ! is_claude_force_mode && ! is_claude_dry_run_mode; then
            echo "🚨 ENHANCED CONFIRMATION REQUIRED"
            echo ""
            read -p "I understand the risks and want to deduplicate .claude directories [type 'YES']: " -r
            if [[ $REPLY != "YES" ]]; then
                echo "❌ Deduplication cancelled for safety"
                log_audit_event "$operation" "${claude_paths[*]}" "CANCELLED_BY_USER"
                return 1
            fi
        fi
    fi
    
    # Apply .claude protection
    local protected_args
    if ! protected_args=$(integrate_claude_overrides "$operation" "${all_args[@]}"); then
        display_claude_error "access_denied" "deduplication operation"
        return 1
    fi
    
    # Parse protected args
    local protected_target
    local protected_extra_args=()
    if [ -n "$protected_args" ]; then
        IFS=' ' read -ra parsed_args <<< "$protected_args"
        protected_target="${parsed_args[0]}"
        protected_extra_args=("${parsed_args[@]:1}")
    else
        echo "ℹ️  No paths to deduplicate after applying protection filters"
        return 0
    fi
    
    # Create comprehensive safety snapshot for dedupe operations
    if is_claude_operation_enabled && ! is_claude_dry_run_mode; then
        echo "📸 Creating comprehensive safety snapshot before deduplication..."
        local snapshot_path
        if ! snapshot_path=$(create_safety_snapshot "$protected_target" "dedupe_with_claude"); then
            echo "❌ Failed to create safety snapshot"
            log_audit_event "$operation" "$protected_target" "SNAPSHOT_FAILED"
            return 1
        fi
        
        # Create additional detailed backup for .claude dedupe
        if [ ${#claude_paths[@]} -gt 0 ]; then
            local detailed_backup_path="$snapshot_path/.claude-dedupe-backup"
            mkdir -p "$detailed_backup_path"
            
            for claude_path in "${claude_paths[@]}"; do
                if [ -d "$claude_path" ]; then
                    local rel_path=${claude_path#$protected_target/}
                    mkdir -p "$detailed_backup_path/$(dirname "$rel_path")"
                    
                    # Create file-by-file backup with checksums
                    find "$claude_path" -type f | while read -r file; do
                        local file_rel_path=${file#$protected_target/}
                        local backup_file="$detailed_backup_path/$file_rel_path"
                        mkdir -p "$(dirname "$backup_file")"
                        cp "$file" "$backup_file"
                        
                        # Create checksum for verification
                        if command -v sha256sum >/dev/null 2>&1; then
                            sha256sum "$file" > "$backup_file.sha256"
                        elif command -v shasum >/dev/null 2>&1; then
                            shasum -a 256 "$file" > "$backup_file.sha256"
                        fi
                    done
                fi
            done
            echo "✅ Detailed .claude backup created with checksums"
        fi
        
        echo "✅ Comprehensive safety snapshot created: $snapshot_path"
        log_audit_event "$operation" "$protected_target" "SNAPSHOT_CREATED" "$snapshot_path"
    fi
    
    # Execute original dedupe function
    echo "🔄 Executing deduplication operation on protected paths..."
    if dedupe_codebase_original "$protected_target" "${protected_extra_args[@]}"; then
        echo "✅ Deduplication operation completed successfully"
        
        # Enhanced verification for dedupe operations
        if is_claude_operation_enabled && ! is_claude_dry_run_mode; then
            echo "🔍 Performing enhanced verification after deduplication..."
            
            # Verify all .claude commands still function
            if [ ${#claude_paths[@]} -gt 0 ]; then
                echo "🧪 Testing .claude command functionality..."
                local broken_commands=()
                
                for claude_path in "${claude_paths[@]}"; do
                    if [ -d "$claude_path/commands" ]; then
                        find "$claude_path/commands" -name "*.md" -type f | while read -r cmd_file; do
                            # Basic syntax validation
                            if ! validate_command_file_syntax "$cmd_file"; then
                                broken_commands+=("$(basename "$cmd_file")")
                            fi
                        done
                    fi
                done
                
                if [ ${#broken_commands[@]} -gt 0 ]; then
                    echo "🚨 CRITICAL: Some .claude commands may be broken after deduplication!"
                    echo "Potentially broken commands:"
                    for broken_cmd in "${broken_commands[@]}"; do
                        echo "  - $broken_cmd"
                    done
                    
                    read -p "🔄 Restore .claude directories from detailed backup? [Y/n]: " -r
                    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                        local detailed_backup="$snapshot_path/.claude-dedupe-backup"
                        if [ -d "$detailed_backup" ]; then
                            echo "🔄 Restoring .claude directories from detailed backup..."
                            cp -r "$detailed_backup"/* "$protected_target/"
                            echo "✅ .claude directories restored"
                            log_audit_event "$operation" "$protected_target" "CLAUDE_RESTORED_FROM_BACKUP"
                        fi
                    fi
                else
                    echo "✅ All .claude commands appear functional after deduplication"
                fi
            fi
            
            # Standard integrity check
            if ! verify_operation_integrity "$protected_target" "dedupe" "$snapshot_path"; then
                echo "⚠️  Integrity verification warnings detected"
                log_audit_event "$operation" "$protected_target" "INTEGRITY_WARNING"
            else
                echo "✅ Integrity verification passed"
                log_audit_event "$operation" "$protected_target" "INTEGRITY_VERIFIED"
            fi
        fi
        
        return 0
    else
        echo "❌ Deduplication operation failed"
        log_audit_event "$operation" "$protected_target" "OPERATION_FAILED"
        
        # Offer rollback with detailed options
        if [ -n "$snapshot_path" ] && [ -d "$snapshot_path" ]; then
            echo ""
            echo "💡 Recovery options available:"
            echo "  1. Full rollback to snapshot"
            echo "  2. Restore only .claude directories"
            echo "  3. Manual recovery"
            echo ""
            read -p "Choose recovery option [1-3, or N for none]: " -r
            
            case $REPLY in
                1)
                    if rollback_to_snapshot "$snapshot_path" "$protected_target"; then
                        echo "✅ Full rollback successful"
                        log_audit_event "$operation" "$protected_target" "ROLLBACK_SUCCESS"
                    else
                        echo "❌ Full rollback failed"
                        log_audit_event "$operation" "$protected_target" "ROLLBACK_FAILED"
                    fi
                    ;;
                2)
                    local detailed_backup="$snapshot_path/.claude-dedupe-backup"
                    if [ -d "$detailed_backup" ]; then
                        cp -r "$detailed_backup"/* "$protected_target/"
                        echo "✅ .claude directories restored"
                        log_audit_event "$operation" "$protected_target" "CLAUDE_PARTIAL_RESTORE"
                    else
                        echo "❌ .claude backup not found"
                    fi
                    ;;
                3)
                    echo "📂 Snapshot location: $snapshot_path"
                    echo "📂 Detailed .claude backup: $snapshot_path/.claude-dedupe-backup"
                    echo "💡 Use these paths for manual recovery"
                    ;;
            esac
        fi
        
        return 1
    fi
}

# Backup original dedupe function
if declare -f dedupe_codebase >/dev/null 2>&1; then
    eval "$(declare -f dedupe_codebase | sed 's/^dedupe_codebase/dedupe_codebase_original/')"
    
    # Replace with protected version
    dedupe_codebase() {
        dedupe_codebase_with_protection "$@"
    }
fi

# Validate command file syntax
validate_command_file_syntax() {
    local cmd_file=$1
    
    # Check for required YAML front matter
    if ! head -10 "$cmd_file" | grep -q "^---$"; then
        return 1
    fi
    
    # Check for description field
    if ! grep -q "^description:" "$cmd_file"; then
        return 1
    fi
    
    # Basic markdown structure check
    if ! grep -q "^#" "$cmd_file"; then
        return 1
    fi
    
    return 0
}
```

## Verify Command Integration

```bash
# Enhanced verify command with .claude protection
verify_codebase_with_protection() {
    local operation="verify"
    local target=${1:-.}
    shift
    local args=("$@")
    
    echo "🔍 Starting verification operation with .claude protection..."
    
    # Verify is generally safe, but we still want to log .claude access
    local all_args=("$target" "${args[@]}")
    
    # Apply .claude protection (verify is read-only so should be safer)
    local protected_args
    if ! protected_args=$(integrate_claude_overrides "$operation" "${all_args[@]}"); then
        display_claude_error "access_denied" "verification operation"
        return 1
    fi
    
    # Parse protected args
    local protected_target
    local protected_extra_args=()
    if [ -n "$protected_args" ]; then
        IFS=' ' read -ra parsed_args <<< "$protected_args"
        protected_target="${parsed_args[0]}"
        protected_extra_args=("${parsed_args[@]:1}")
    else
        echo "ℹ️  No paths to verify after applying protection filters"
        return 0
    fi
    
    # Execute original verify function
    echo "🔄 Executing verification operation on protected paths..."
    if verify_codebase_original "$protected_target" "${protected_extra_args[@]}"; then
        echo "✅ Verification operation completed successfully"
        log_audit_event "$operation" "$protected_target" "VERIFICATION_SUCCESS"
        return 0
    else
        echo "❌ Verification operation detected issues"
        log_audit_event "$operation" "$protected_target" "VERIFICATION_ISSUES"
        return 1
    fi
}

# Backup original verify function
if declare -f verify_codebase >/dev/null 2>&1; then
    eval "$(declare -f verify_codebase | sed 's/^verify_codebase/verify_codebase_original/')"
    
    # Replace with protected version
    verify_codebase() {
        verify_codebase_with_protection "$@"
    }
fi
```

## Automatic Integration Setup

```bash
# Automatic setup when this file is sourced
setup_claude_protection_integration() {
    echo "🔒 Setting up .claude protection integration..."
    
    # Check if override mechanisms are available
    if ! declare -f parse_claude_override_flags >/dev/null 2>&1; then
        echo "⚠️  Override mechanisms not loaded, sourcing..."
        local override_file="${CLAUDE_COMMANDS_DIR:-/Users/nashgao/Desktop/claude/claude-code/instruction/.claude/commands}/quality/_shared/claude-protection-overrides.md"
        if [ -f "$override_file" ]; then
            source "$override_file"
        else
            echo "❌ Cannot find override mechanisms file: $override_file"
            return 1
        fi
    fi
    
    # Initialize default protection state
    export CLAUDE_INCLUDE_ENABLED="${CLAUDE_INCLUDE_ENABLED:-false}"
    export CLAUDE_ONLY_MODE="${CLAUDE_ONLY_MODE:-false}"
    export CLAUDE_FORCE_MODE="${CLAUDE_FORCE_MODE:-false}"
    export CLAUDE_DRY_RUN_MODE="${CLAUDE_DRY_RUN_MODE:-false}"
    export CLAUDE_CONFIRM_MODE="${CLAUDE_CONFIRM_MODE:-false}"
    
    echo "✅ .claude protection integration ready"
    echo ""
    echo "💡 Available override flags:"
    echo "   --include-claude    Include .claude directories in operations"
    echo "   --claude-only       Operate only on .claude directories"
    echo "   --claude-dry-run    Preview .claude operations safely"
    echo "   --claude-confirm    Force confirmation prompts"
    echo "   --force-claude      Bypass safety warnings (advanced)"
    echo ""
}

# Auto-setup when file is sourced
setup_claude_protection_integration

# Export key functions for external use
export -f integrate_quality_command_with_claude_protection
export -f format_codebase_with_protection
export -f cleanup_codebase_with_protection
export -f dedupe_codebase_with_protection
export -f verify_codebase_with_protection
```

This integration layer provides:

1. **Universal Command Integration** - Seamless integration for any quality command
2. **Individual Command Wrappers** - Specialized handling for each command type
3. **Enhanced Safety Features** - Comprehensive snapshots and verification
4. **Risk-Appropriate Handling** - Different safety levels based on operation risk
5. **Recovery Mechanisms** - Multiple recovery options for failed operations
6. **Automatic Setup** - Self-configuring integration when sourced

The system maintains full backward compatibility while adding robust .claude protection.