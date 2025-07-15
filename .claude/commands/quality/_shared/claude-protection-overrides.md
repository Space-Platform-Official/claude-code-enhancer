---
description: User override mechanisms for .claude directory operations (Phase 3 implementation)
phase: phase-003
dependencies: ["phase-002"]
status: designed
---

# .Claude Directory Protection - User Override Mechanisms

**PHASE 3: User Override Mechanisms for .claude Operations**

This module implements explicit user controls for when users DO want to work with .claude directories, providing safe and audited override capabilities.

## Override Flag System

### Explicit Override Flags

```bash
# Override flag definitions for .claude operations
CLAUDE_OVERRIDE_FLAGS=(
    "--include-claude"     # Include .claude directories in operations
    "--claude-only"        # Operate ONLY on .claude directories
    "--force-claude"       # Force operation despite safety warnings
    "--claude-dry-run"     # Dry run mode for .claude operations
    "--claude-confirm"     # Force confirmation prompts
)

# Parse override flags
parse_claude_override_flags() {
    local args=("$@")
    local include_claude=false
    local claude_only=false
    local force_claude=false
    local claude_dry_run=false
    local claude_confirm=false
    local remaining_args=()
    
    for arg in "${args[@]}"; do
        case "$arg" in
            --include-claude)
                include_claude=true
                echo "INFO: .claude directories will be included in operation"
                ;;
            --claude-only)
                claude_only=true
                include_claude=true  # Implies include
                echo "INFO: Operation will target ONLY .claude directories"
                ;;
            --force-claude)
                force_claude=true
                include_claude=true  # Implies include
                echo "WARNING: Forcing .claude operation despite safety warnings"
                ;;
            --claude-dry-run)
                claude_dry_run=true
                echo "INFO: Dry run mode enabled for .claude operations"
                ;;
            --claude-confirm)
                claude_confirm=true
                echo "INFO: Confirmation prompts enabled for .claude operations"
                ;;
            *)
                remaining_args+=("$arg")
                ;;
        esac
    done
    
    # Validate flag combinations
    if $claude_only && $force_claude; then
        echo "ERROR: Cannot use --claude-only with --force-claude"
        return 1
    fi
    
    # Export override settings
    export CLAUDE_INCLUDE_ENABLED="$include_claude"
    export CLAUDE_ONLY_MODE="$claude_only"
    export CLAUDE_FORCE_MODE="$force_claude"
    export CLAUDE_DRY_RUN_MODE="$claude_dry_run"
    export CLAUDE_CONFIRM_MODE="$claude_confirm"
    
    echo "${remaining_args[@]}"
}

# Check if .claude operations are enabled
is_claude_operation_enabled() {
    [[ "$CLAUDE_INCLUDE_ENABLED" == "true" ]] || [[ "$CLAUDE_ONLY_MODE" == "true" ]]
}

# Check if operating in claude-only mode
is_claude_only_mode() {
    [[ "$CLAUDE_ONLY_MODE" == "true" ]]
}

# Check if force mode is enabled
is_claude_force_mode() {
    [[ "$CLAUDE_FORCE_MODE" == "true" ]]
}

# Check if dry run mode is enabled
is_claude_dry_run_mode() {
    [[ "$CLAUDE_DRY_RUN_MODE" == "true" ]]
}

# Check if confirmation mode is enabled
is_claude_confirm_mode() {
    [[ "$CLAUDE_CONFIRM_MODE" == "true" ]] || [[ "$CLAUDE_INCLUDE_ENABLED" == "true" ]]
}
```

## Confirmation Prompt System

### Enhanced Confirmation Prompts

```bash
# Comprehensive confirmation system for .claude operations
confirm_claude_operation() {
    local operation=$1
    local target_paths=("${@:2}")
    local claude_paths=()
    local non_claude_paths=()
    
    # Categorize paths
    for path in "${target_paths[@]}"; do
        if [[ "$path" == *"/.claude/"* ]] || [[ "$path" == *".claude"* ]]; then
            claude_paths+=("$path")
        else
            non_claude_paths+=("$path")
        fi
    done
    
    local claude_count=${#claude_paths[@]}
    local total_count=${#target_paths[@]}
    
    echo ""
    echo "🔒 CLAUDE DIRECTORY OPERATION CONFIRMATION"
    echo "=========================================="
    echo "Operation: $operation"
    echo "Total files/directories: $total_count"
    echo "Claude-related items: $claude_count"
    echo ""
    
    if [ $claude_count -gt 0 ]; then
        echo "🚨 .claude directories will be affected:"
        for path in "${claude_paths[@]}"; do
            echo "  - $(highlight_claude_path "$path")"
        done
        echo ""
    fi
    
    if is_claude_only_mode; then
        echo "📋 CLAUDE-ONLY MODE: Only .claude directories will be processed"
    elif [ ${#non_claude_paths[@]} -gt 0 ]; then
        echo "📂 Regular files/directories to be processed: ${#non_claude_paths[@]}"
    fi
    
    echo ""
    echo "🔍 SAFETY INFORMATION:"
    echo "- .claude directories contain project configuration"
    echo "- Modifications may affect Claude Code behavior"
    echo "- A backup snapshot will be created automatically"
    echo "- You can rollback changes if needed"
    echo ""
    
    # Risk assessment
    local risk_level=$(assess_claude_operation_risk "$operation" "${claude_paths[@]}")
    display_risk_assessment "$risk_level" "$operation"
    
    echo ""
    if is_claude_dry_run_mode; then
        echo "🧪 DRY RUN MODE: No actual changes will be made"
        echo "Continue with dry run? [Y/n]: "
    else
        echo "⚠️  Proceed with .claude directory operation? [y/N]: "
    fi
    
    read -r response
    
    if is_claude_dry_run_mode; then
        [[ ! "$response" =~ ^[Nn]$ ]]
    else
        [[ "$response" =~ ^[Yy]$ ]]
    fi
}

# Highlight .claude paths in output
highlight_claude_path() {
    local path=$1
    echo "$path" | sed 's/\.claude/[.claude]/g'
}

# Assess risk level for .claude operations
assess_claude_operation_risk() {
    local operation=$1
    local paths=("${@:2}")
    local risk_score=0
    
    # Base risk by operation type
    case "$operation" in
        "format"|"verify")
            risk_score=1  # Low risk
            ;;
        "cleanup"|"dedupe")
            risk_score=3  # Medium risk
            ;;
        "delete"|"remove")
            risk_score=5  # High risk
            ;;
        *)
            risk_score=2  # Unknown operation
            ;;
    esac
    
    # Increase risk based on critical files
    for path in "${paths[@]}"; do
        case "$path" in
            *"/commands/"*)
                risk_score=$((risk_score + 1))
                ;;
            *"/CLAUDE.md"*)
                risk_score=$((risk_score + 2))
                ;;
            *"/.claude"*)
                risk_score=$((risk_score + 1))
                ;;
        esac
    done
    
    # Determine risk level
    if [ $risk_score -ge 6 ]; then
        echo "CRITICAL"
    elif [ $risk_score -ge 4 ]; then
        echo "HIGH"
    elif [ $risk_score -ge 2 ]; then
        echo "MEDIUM"
    else
        echo "LOW"
    fi
}

# Display risk assessment information
display_risk_assessment() {
    local risk_level=$1
    local operation=$2
    
    case "$risk_level" in
        "CRITICAL")
            echo "🔴 CRITICAL RISK LEVEL"
            echo "   This operation may severely impact Claude Code functionality"
            echo "   Consider using --claude-dry-run first to preview changes"
            ;;
        "HIGH")
            echo "🟠 HIGH RISK LEVEL"
            echo "   This operation may significantly affect Claude Code behavior"
            echo "   Ensure you have recent backups"
            ;;
        "MEDIUM")
            echo "🟡 MEDIUM RISK LEVEL"
            echo "   This operation may modify Claude Code configuration"
            echo "   Changes can be rolled back if needed"
            ;;
        "LOW")
            echo "🟢 LOW RISK LEVEL"
            echo "   This operation has minimal impact on Claude Code"
            ;;
    esac
}

# Confirm individual file operations
confirm_claude_file_operation() {
    local operation=$1
    local file_path=$2
    
    if ! is_claude_confirm_mode && ! is_claude_force_mode; then
        return 0  # No confirmation needed
    fi
    
    if is_claude_force_mode; then
        echo "FORCE MODE: Proceeding with $operation on $file_path"
        return 0
    fi
    
    echo ""
    echo "📄 File Operation Confirmation"
    echo "File: $(highlight_claude_path "$file_path")"
    echo "Operation: $operation"
    echo ""
    
    # Show file info
    if [ -f "$file_path" ]; then
        echo "Current file size: $(get_file_size "$file_path" | format_file_size)"
        echo "Last modified: $(stat -f%Sm "$file_path" 2>/dev/null || stat -c%y "$file_path" 2>/dev/null)"
    fi
    
    echo ""
    echo "Proceed with this file operation? [y/N]: "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}
```

## Dry Run Mode Implementation

### Comprehensive Dry Run System

```bash
# Dry run mode for .claude operations
execute_claude_dry_run() {
    local operation=$1
    local target_paths=("${@:2}")
    
    echo ""
    echo "🧪 CLAUDE DRY RUN MODE ACTIVE"
    echo "============================="
    echo "Operation: $operation"
    echo "Target paths: ${#target_paths[@]}"
    echo ""
    
    local claude_paths=()
    local changes_summary=()
    
    # Filter and analyze .claude paths
    for path in "${target_paths[@]}"; do
        if should_include_claude_path "$path"; then
            claude_paths+=("$path")
        fi
    done
    
    if [ ${#claude_paths[@]} -eq 0 ]; then
        echo "ℹ️  No .claude paths would be affected by this operation"
        return 0
    fi
    
    echo "📁 .claude paths that would be affected:"
    for path in "${claude_paths[@]}"; do
        echo "  $(highlight_claude_path "$path")"
    done
    echo ""
    
    # Simulate operations
    echo "🔍 Simulating $operation operation..."
    for path in "${claude_paths[@]}"; do
        local simulation_result=$(simulate_claude_operation "$operation" "$path")
        if [ -n "$simulation_result" ]; then
            changes_summary+=("$simulation_result")
            echo "  $simulation_result"
        fi
    done
    
    echo ""
    echo "📊 DRY RUN SUMMARY"
    echo "=================="
    echo "Total .claude items analyzed: ${#claude_paths[@]}"
    echo "Potential changes: ${#changes_summary[@]}"
    
    if [ ${#changes_summary[@]} -gt 0 ]; then
        echo ""
        echo "🔄 Potential changes:"
        for change in "${changes_summary[@]}"; do
            echo "  - $change"
        done
    fi
    
    echo ""
    echo "✅ Dry run completed. No actual changes were made."
    echo "💡 To execute actual changes, run without --claude-dry-run flag"
    
    return 0
}

# Simulate specific operation on .claude path
simulate_claude_operation() {
    local operation=$1
    local path=$2
    
    case "$operation" in
        "format")
            simulate_format_operation "$path"
            ;;
        "cleanup")
            simulate_cleanup_operation "$path"
            ;;
        "dedupe")
            simulate_dedupe_operation "$path"
            ;;
        "verify")
            simulate_verify_operation "$path"
            ;;
        *)
            echo "Unknown operation simulation: $operation on $path"
            ;;
    esac
}

# Simulate format operation
simulate_format_operation() {
    local path=$1
    
    if [ -f "$path" ]; then
        local file_type=$(detect_file_type "$path")
        case "$file_type" in
            "markdown")
                echo "Would format Markdown file: $(basename "$path")"
                ;;
            "yaml"|"json")
                echo "Would format config file: $(basename "$path")"
                ;;
            *)
                echo "Would process file: $(basename "$path")"
                ;;
        esac
    elif [ -d "$path" ]; then
        local file_count=$(find "$path" -type f | wc -l)
        echo "Would format $file_count files in directory: $(basename "$path")"
    fi
}

# Simulate cleanup operation
simulate_cleanup_operation() {
    local path=$1
    
    if [ -f "$path" ]; then
        # Check for potential cleanup targets
        local cleanup_items=$(analyze_cleanup_potential "$path")
        if [ -n "$cleanup_items" ]; then
            echo "Would clean up items in: $(basename "$path") ($cleanup_items)"
        else
            echo "No cleanup needed: $(basename "$path")"
        fi
    elif [ -d "$path" ]; then
        local cleanup_count=$(find "$path" -name "*.bak" -o -name "*.tmp" -o -name "*~" | wc -l)
        if [ $cleanup_count -gt 0 ]; then
            echo "Would clean up $cleanup_count temporary files in: $(basename "$path")"
        else
            echo "No temporary files to clean in: $(basename "$path")"
        fi
    fi
}

# Simulate dedupe operation
simulate_dedupe_operation() {
    local path=$1
    
    if [ -f "$path" ]; then
        local duplicate_lines=$(find_duplicate_content "$path")
        if [ $duplicate_lines -gt 0 ]; then
            echo "Would deduplicate $duplicate_lines duplicate lines in: $(basename "$path")"
        else
            echo "No duplicates found: $(basename "$path")"
        fi
    elif [ -d "$path" ]; then
        local duplicate_files=$(find_duplicate_files "$path")
        if [ $duplicate_files -gt 0 ]; then
            echo "Would deduplicate $duplicate_files duplicate files in: $(basename "$path")"
        else
            echo "No duplicate files found: $(basename "$path")"
        fi
    fi
}

# Simulate verify operation
simulate_verify_operation() {
    local path=$1
    
    if [ -f "$path" ]; then
        echo "Would verify syntax and structure of: $(basename "$path")"
    elif [ -d "$path" ]; then
        local file_count=$(find "$path" -type f | wc -l)
        echo "Would verify $file_count files in: $(basename "$path")"
    fi
}

# Check if path should be included in .claude operations
should_include_claude_path() {
    local path=$1
    
    if is_claude_only_mode; then
        # Only include .claude paths
        [[ "$path" == *"/.claude/"* ]] || [[ "$path" == *"/.claude" ]] || [[ "$(basename "$path")" == ".claude" ]]
    elif is_claude_operation_enabled; then
        # Include all paths (normal behavior when .claude is explicitly enabled)
        true
    else
        # Exclude .claude paths (default behavior)
        ! [[ "$path" == *"/.claude/"* ]] && ! [[ "$path" == *"/.claude" ]] && ! [[ "$(basename "$path")" == ".claude" ]]
    fi
}
```

## Audit Logging System

### Comprehensive Audit Trail

```bash
# Audit logging for .claude operations
setup_claude_audit_logging() {
    local target_dir=${1:-.}
    local audit_dir="$target_dir/.claude-audit"
    
    mkdir -p "$audit_dir"
    
    export CLAUDE_AUDIT_DIR="$audit_dir"
    export CLAUDE_AUDIT_ENABLED="true"
    export CLAUDE_AUDIT_SESSION_ID="claude_$(date +%Y%m%d_%H%M%S)_$$"
    
    # Initialize audit log
    local audit_file="$audit_dir/access.log"
    if [ ! -f "$audit_file" ]; then
        cat > "$audit_file" <<EOF
# Claude Directory Access Audit Log
# Generated automatically - do not edit manually
# Format: timestamp|session_id|operation|path|result|flags|user|pid
EOF
    fi
    
    log_audit_event "session_start" "audit_system" "SUCCESS" "$target_dir"
    echo "Audit logging enabled: $audit_file"
}

# Log audit events
log_audit_event() {
    local operation=$1
    local path=$2
    local result=$3
    local details=${4:-""}
    
    if [[ "$CLAUDE_AUDIT_ENABLED" != "true" ]]; then
        return 0
    fi
    
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local session_id="$CLAUDE_AUDIT_SESSION_ID"
    local user=$(whoami)
    local pid=$$
    local flags=""
    
    # Collect active flags
    local flag_parts=()
    is_claude_operation_enabled && flag_parts+=("include-claude")
    is_claude_only_mode && flag_parts+=("claude-only")
    is_claude_force_mode && flag_parts+=("force-claude")
    is_claude_dry_run_mode && flag_parts+=("dry-run")
    is_claude_confirm_mode && flag_parts+=("confirm")
    
    flags=$(IFS=,; echo "${flag_parts[*]}")
    
    local audit_file="$CLAUDE_AUDIT_DIR/access.log"
    echo "$timestamp|$session_id|$operation|$path|$result|$flags|$user|$pid|$details" >> "$audit_file"
    
    # Also log to daily audit file
    local daily_audit="$CLAUDE_AUDIT_DIR/audit_$(date +%Y%m%d).log"
    echo "$timestamp|$session_id|$operation|$path|$result|$flags|$user|$pid|$details" >> "$daily_audit"
}

# Log .claude directory access attempt
log_claude_access() {
    local operation=$1
    local path=$2
    local allowed=${3:-false}
    
    local result="DENIED"
    $allowed && result="ALLOWED"
    
    log_audit_event "$operation" "$path" "$result"
    
    if ! $allowed; then
        echo "🚫 AUDIT: .claude access denied - $operation on $path"
        echo "💡 Use --include-claude flag to enable .claude operations"
    else
        echo "✅ AUDIT: .claude access granted - $operation on $path"
    fi
}

# Generate audit report
generate_claude_audit_report() {
    local target_dir=${1:-.}
    local report_type=${2:-"summary"}  # summary, detailed, security
    local time_range=${3:-"24h"}       # 1h, 24h, 7d, 30d, all
    
    local audit_dir="$target_dir/.claude-audit"
    if [ ! -d "$audit_dir" ]; then
        echo "No audit logs found"
        return 1
    fi
    
    echo ""
    echo "📊 CLAUDE DIRECTORY AUDIT REPORT"
    echo "================================="
    echo "Report Type: $report_type"
    echo "Time Range: $time_range"
    echo "Generated: $(date)"
    echo ""
    
    case "$report_type" in
        "summary")
            generate_audit_summary "$audit_dir" "$time_range"
            ;;
        "detailed")
            generate_detailed_audit_report "$audit_dir" "$time_range"
            ;;
        "security")
            generate_security_audit_report "$audit_dir" "$time_range"
            ;;
        *)
            echo "Unknown report type: $report_type"
            return 1
            ;;
    esac
}

# Generate audit summary
generate_audit_summary() {
    local audit_dir=$1
    local time_range=$2
    
    local log_files=$(find_audit_logs "$audit_dir" "$time_range")
    
    if [ -z "$log_files" ]; then
        echo "No audit data found for time range: $time_range"
        return 0
    fi
    
    echo "📈 SUMMARY STATISTICS"
    echo "===================="
    
    # Count total operations
    local total_ops=$(cat $log_files | grep -v "^#" | wc -l)
    echo "Total operations: $total_ops"
    
    # Count by operation type
    echo ""
    echo "Operations by type:"
    cat $log_files | grep -v "^#" | cut -d'|' -f3 | sort | uniq -c | sort -nr | while read count op; do
        echo "  $op: $count"
    done
    
    # Count by result
    echo ""
    echo "Operations by result:"
    cat $log_files | grep -v "^#" | cut -d'|' -f5 | sort | uniq -c | sort -nr | while read count result; do
        echo "  $result: $count"
    done
    
    # Count denied operations
    local denied_count=$(cat $log_files | grep -v "^#" | grep "|DENIED|" | wc -l)
    local allowed_count=$(cat $log_files | grep -v "^#" | grep "|ALLOWED|" | wc -l)
    
    echo ""
    echo "🔒 ACCESS CONTROL"
    echo "================="
    echo "Allowed operations: $allowed_count"
    echo "Denied operations: $denied_count"
    
    if [ $denied_count -gt 0 ]; then
        echo ""
        echo "🚫 Recent denied operations:"
        cat $log_files | grep -v "^#" | grep "|DENIED|" | tail -5 | while IFS='|' read timestamp session op path result flags user pid details; do
            echo "  $(date -d "$timestamp" 2>/dev/null || echo "$timestamp"): $op on $path"
        done
    fi
}

# Generate detailed audit report
generate_detailed_audit_report() {
    local audit_dir=$1
    local time_range=$2
    
    local log_files=$(find_audit_logs "$audit_dir" "$time_range")
    
    echo "📋 DETAILED AUDIT LOG"
    echo "===================="
    
    cat $log_files | grep -v "^#" | while IFS='|' read timestamp session op path result flags user pid details; do
        echo ""
        echo "Timestamp: $(date -d "$timestamp" 2>/dev/null || echo "$timestamp")"
        echo "Session: $session"
        echo "Operation: $op"
        echo "Path: $path"
        echo "Result: $result"
        echo "Flags: $flags"
        echo "User: $user"
        echo "PID: $pid"
        [ -n "$details" ] && echo "Details: $details"
        echo "---"
    done
}

# Generate security audit report
generate_security_audit_report() {
    local audit_dir=$1
    local time_range=$2
    
    echo "🔐 SECURITY AUDIT ANALYSIS"
    echo "========================="
    
    local log_files=$(find_audit_logs "$audit_dir" "$time_range")
    
    # Analyze denied operations
    local denied_ops=$(cat $log_files | grep -v "^#" | grep "|DENIED|")
    if [ -n "$denied_ops" ]; then
        echo ""
        echo "🚫 DENIED OPERATIONS ANALYSIS"
        echo "============================="
        
        echo "Denied operations by user:"
        echo "$denied_ops" | cut -d'|' -f7 | sort | uniq -c | sort -nr
        
        echo ""
        echo "Denied operations by path:"
        echo "$denied_ops" | cut -d'|' -f4 | sort | uniq -c | sort -nr | head -10
    fi
    
    # Analyze force mode usage
    local force_ops=$(cat $log_files | grep -v "^#" | grep "force-claude")
    if [ -n "$force_ops" ]; then
        echo ""
        echo "⚡ FORCE MODE USAGE"
        echo "=================="
        
        echo "Force mode operations by user:"
        echo "$force_ops" | cut -d'|' -f7 | sort | uniq -c | sort -nr
    fi
    
    # Analyze high-risk operations
    local high_risk_ops=$(cat $log_files | grep -v "^#" | grep -E "(delete|remove|cleanup)")
    if [ -n "$high_risk_ops" ]; then
        echo ""
        echo "⚠️  HIGH-RISK OPERATIONS"
        echo "======================"
        
        echo "$high_risk_ops" | while IFS='|' read timestamp session op path result flags user pid details; do
            echo "$(date -d "$timestamp" 2>/dev/null || echo "$timestamp"): $op on $path by $user ($result)"
        done
    fi
}

# Find audit log files for time range
find_audit_logs() {
    local audit_dir=$1
    local time_range=$2
    
    case "$time_range" in
        "1h")
            find "$audit_dir" -name "*.log" -mmin -60
            ;;
        "24h")
            find "$audit_dir" -name "*.log" -mtime -1
            ;;
        "7d")
            find "$audit_dir" -name "*.log" -mtime -7
            ;;
        "30d")
            find "$audit_dir" -name "*.log" -mtime -30
            ;;
        "all")
            find "$audit_dir" -name "*.log"
            ;;
        *)
            echo "Invalid time range: $time_range" >&2
            return 1
            ;;
    esac
}

# Clean old audit logs
cleanup_claude_audit_logs() {
    local target_dir=${1:-.}
    local retention_days=${2:-30}
    
    local audit_dir="$target_dir/.claude-audit"
    if [ ! -d "$audit_dir" ]; then
        return 0
    fi
    
    echo "Cleaning audit logs older than $retention_days days..."
    
    local cleaned_count=0
    find "$audit_dir" -name "audit_*.log" -mtime +$retention_days | while read log_file; do
        echo "Removing old audit log: $(basename "$log_file")"
        rm -f "$log_file"
        cleaned_count=$((cleaned_count + 1))
    done
    
    echo "Cleaned $cleaned_count old audit log files"
    log_audit_event "cleanup_audit_logs" "$audit_dir" "SUCCESS" "removed $cleaned_count files"
}
```

## Error Messages and Guidance

### User-Friendly Error Messages

```bash
# Display helpful error messages for .claude operations
display_claude_error() {
    local error_type=$1
    local context=${2:-""}
    
    echo ""
    echo "🚫 CLAUDE OPERATION ERROR"
    echo "========================"
    
    case "$error_type" in
        "access_denied")
            cat <<EOF
❌ Access to .claude directories is restricted by default

🔒 PROTECTION ACTIVE: .claude directories contain project configuration
   that controls Claude Code behavior. Modifications can break functionality.

💡 TO PROCEED SAFELY:

   Option 1: Preview changes first
   ✓ Add --claude-dry-run to see what would be changed

   Option 2: Include .claude directories explicitly  
   ✓ Add --include-claude to enable .claude operations
   
   Option 3: Target only .claude directories
   ✓ Add --claude-only to work exclusively with .claude

   Option 4: Force operation (advanced users)
   ✓ Add --force-claude to bypass safety checks

📚 EXAMPLES:
   Safe preview:    command --claude-dry-run
   Include .claude: command --include-claude  
   Claude only:     command --claude-only
   Force mode:      command --force-claude

⚠️  Always backup your .claude directory before modifications!
EOF
            ;;
        "invalid_flags")
            cat <<EOF
❌ Invalid flag combination: $context

🔧 VALID COMBINATIONS:
   ✓ --include-claude (include .claude in operation)
   ✓ --claude-only (operate only on .claude)
   ✓ --claude-dry-run (preview changes)
   ✓ --claude-confirm (extra confirmation)
   ✓ --force-claude (bypass warnings)

❌ INVALID COMBINATIONS:
   ✗ --claude-only + --force-claude
   ✗ Multiple conflicting modes

💡 TIP: Use --claude-dry-run first to preview changes safely
EOF
            ;;
        "operation_failed")
            cat <<EOF
❌ .claude operation failed: $context

🔧 TROUBLESHOOTING STEPS:

   1. Check file permissions
      ls -la .claude/
      
   2. Verify file integrity  
      Check for syntax errors in .claude files
      
   3. Review audit logs
      Use: generate_claude_audit_report
      
   4. Restore from backup
      Check .claude-snapshots/ directory

📞 GETTING HELP:
   - Review audit logs for detailed error information
   - Check .claude-error.log for technical details
   - Restore from recent snapshot if needed
EOF
            ;;
        "permission_error")
            cat <<EOF
❌ Permission denied for .claude operation

🔐 PERMISSION REQUIREMENTS:
   - Write access to .claude directory
   - Ability to create backup snapshots
   - File modification permissions

🔧 SOLUTIONS:
   1. Check file ownership:
      ls -la .claude/
      
   2. Fix permissions if needed:
      chmod u+w .claude/
      chmod u+w .claude/*
      
   3. Use sudo if necessary (advanced):
      sudo command --force-claude

⚠️  BE CAREFUL: Only use sudo if you understand the implications
EOF
            ;;
        "backup_failed")
            cat <<EOF
❌ Failed to create backup before .claude operation

🛡️  BACKUP REQUIREMENT:
   Safety backups are mandatory for .claude operations
   
🔧 TROUBLESHOOTING:
   1. Check disk space:
      df -h .
      
   2. Check .claude-snapshots/ permissions:
      ls -la .claude-snapshots/
      
   3. Manually create snapshot directory:
      mkdir -p .claude-snapshots/
      
   4. Clean old snapshots:
      clean_old_snapshots

💡 TIP: Free up disk space or clean old snapshots
EOF
            ;;
        *)
            cat <<EOF
❌ Unknown .claude operation error: $error_type

🔧 GENERAL TROUBLESHOOTING:
   1. Check audit logs: generate_claude_audit_report
   2. Verify file permissions: ls -la .claude/
   3. Review recent operations: tail .claude-audit/access.log
   4. Restore from backup if needed: list_snapshots

📞 SUPPORT:
   - Check documentation for $error_type
   - Review safety mechanisms documentation
   - Examine .claude-error.log for details
EOF
            ;;
    esac
    
    echo ""
}

# Display helpful guidance for .claude operations
display_claude_guidance() {
    local operation=${1:-"general"}
    
    echo ""
    echo "💡 CLAUDE OPERATION GUIDANCE"
    echo "============================"
    
    case "$operation" in
        "format")
            cat <<EOF
📝 FORMATTING .claude DIRECTORIES

✅ SAFE OPERATIONS:
   - Markdown formatting in documentation
   - YAML/JSON formatting in config files
   - Whitespace cleanup

⚠️  CAUTIONS:
   - Preserve YAML front matter structure
   - Don't modify command metadata
   - Keep file encoding consistent

🚀 RECOMMENDED WORKFLOW:
   1. Preview: command --claude-dry-run
   2. Backup: create_safety_snapshot
   3. Execute: command --include-claude
   4. Verify: verify integrity
EOF
            ;;
        "cleanup")
            cat <<EOF
🧹 CLEANING UP .claude DIRECTORIES

✅ SAFE TO REMOVE:
   - .bak files
   - .tmp files
   - Editor swap files (~)
   - Empty directories

❌ NEVER REMOVE:
   - Command templates (.md files)
   - Configuration files
   - CLAUDE.md
   - Active workflows

🚀 RECOMMENDED WORKFLOW:
   1. Preview: command --claude-dry-run
   2. Review: what will be cleaned
   3. Execute: command --include-claude
   4. Verify: check functionality
EOF
            ;;
        "dedupe")
            cat <<EOF
🔄 DEDUPLICATING .claude DIRECTORIES

✅ SAFE DEDUPLICATION:
   - Duplicate command templates
   - Repeated documentation sections
   - Identical configuration blocks

⚠️  BE CAREFUL WITH:
   - Command variations
   - Template inheritance
   - Configuration overrides

🚀 RECOMMENDED WORKFLOW:
   1. Analyze: command --claude-dry-run
   2. Review: dedupe candidates
   3. Backup: create_safety_snapshot
   4. Execute: command --include-claude --claude-confirm
EOF
            ;;
        *)
            cat <<EOF
🎯 GENERAL .claude OPERATION BEST PRACTICES

🛡️  SAFETY FIRST:
   1. Always use --claude-dry-run first
   2. Create manual backups of critical files
   3. Test in development environment
   4. Review audit logs regularly

📋 BEFORE OPERATIONS:
   ✓ Ensure git working directory is clean
   ✓ Backup critical .claude files
   ✓ Check disk space for snapshots
   ✓ Review recent audit events

📊 AFTER OPERATIONS:
   ✓ Verify Claude Code functionality  
   ✓ Test critical commands
   ✓ Review audit logs
   ✓ Clean up old snapshots

🆘 IN CASE OF ISSUES:
   1. Check audit logs: generate_claude_audit_report
   2. Restore from snapshot: rollback_to_snapshot
   3. Review error logs: cat .claude-error.log
   4. Seek help with detailed error information
EOF
            ;;
    esac
    
    echo ""
}

# Quick help for .claude operations
show_claude_quick_help() {
    cat <<EOF

🔒 CLAUDE DIRECTORY PROTECTION HELP
==================================

🚫 PROBLEM: Operation blocked on .claude directory?

💡 QUICK SOLUTIONS:
   
   Preview first:    Add --claude-dry-run
   Include .claude:  Add --include-claude
   Claude only:      Add --claude-only
   Force operation:  Add --force-claude
   
🔍 EXAMPLES:
   format --claude-dry-run          # Preview format changes
   cleanup --include-claude         # Include .claude in cleanup
   verify --claude-only            # Verify only .claude files
   dedupe --force-claude           # Force deduplication

📚 MORE HELP:
   display_claude_guidance [operation]    # Detailed guidance
   generate_claude_audit_report          # View access history
   list_snapshots                        # See available backups

⚠️  REMEMBER: .claude directories control Claude Code behavior!

EOF
}
```

## Integration Functions

### Integration with Existing Systems

```bash
# Integrate override system with existing quality commands
integrate_claude_overrides() {
    local command_name=$1
    local original_args=("${@:2}")
    
    # Parse override flags and get remaining args
    local processed_args=$(parse_claude_override_flags "${original_args[@]}")
    
    # Setup audit logging if .claude operations are enabled
    if is_claude_operation_enabled; then
        setup_claude_audit_logging
    fi
    
    # Filter paths based on override settings
    local filtered_args=()
    for arg in $processed_args; do
        if should_process_path_with_overrides "$arg"; then
            filtered_args+=("$arg")
        fi
    done
    
    # Log operation attempt
    log_audit_event "$command_name" "${filtered_args[*]}" "ATTEMPTED"
    
    # Check for .claude paths and handle accordingly
    local claude_paths=()
    for arg in "${filtered_args[@]}"; do
        if [[ "$arg" == *"/.claude/"* ]] || [[ "$arg" == *"/.claude" ]]; then
            claude_paths+=("$arg")
        fi
    done
    
    # Handle .claude paths based on override settings
    if [ ${#claude_paths[@]} -gt 0 ]; then
        if ! is_claude_operation_enabled; then
            display_claude_error "access_denied"
            log_claude_access "$command_name" "${claude_paths[*]}" false
            return 1
        fi
        
        # Confirmation required for .claude operations
        if is_claude_confirm_mode; then
            if ! confirm_claude_operation "$command_name" "${claude_paths[@]}"; then
                echo "Operation cancelled by user"
                log_audit_event "$command_name" "${claude_paths[*]}" "CANCELLED"
                return 1
            fi
        fi
        
        # Dry run mode
        if is_claude_dry_run_mode; then
            execute_claude_dry_run "$command_name" "${claude_paths[@]}"
            log_audit_event "$command_name" "${claude_paths[*]}" "DRY_RUN_COMPLETED"
            return 0
        fi
        
        log_claude_access "$command_name" "${claude_paths[*]}" true
    fi
    
    # Return filtered arguments for actual command execution
    echo "${filtered_args[@]}"
}

# Check if path should be processed based on override settings
should_process_path_with_overrides() {
    local path=$1
    
    # Check if it's a .claude path
    local is_claude_path=false
    if [[ "$path" == *"/.claude/"* ]] || [[ "$path" == *"/.claude" ]] || [[ "$(basename "$path")" == ".claude" ]]; then
        is_claude_path=true
    fi
    
    if $is_claude_path; then
        # It's a .claude path - only include if enabled
        is_claude_operation_enabled
    elif is_claude_only_mode; then
        # Claude-only mode - exclude non-.claude paths
        false
    else
        # Normal path - include if not in claude-only mode
        true
    fi
}

# Wrapper for existing commands to integrate overrides
wrap_command_with_claude_overrides() {
    local original_command=$1
    shift
    local args=("$@")
    
    # Integrate override system
    local processed_args=$(integrate_claude_overrides "$original_command" "${args[@]}")
    
    if [ $? -ne 0 ]; then
        return 1  # Override system blocked the operation
    fi
    
    # Execute original command with processed arguments
    if [ -n "$processed_args" ]; then
        eval "$original_command $processed_args"
    else
        echo "No paths to process after applying .claude overrides"
        return 0
    fi
}

# Example integration with format command
format_with_claude_protection() {
    wrap_command_with_claude_overrides "format_codebase" "$@"
}

# Example integration with cleanup command  
cleanup_with_claude_protection() {
    wrap_command_with_claude_overrides "cleanup_codebase" "$@"
}

# Example integration with dedupe command
dedupe_with_claude_protection() {
    wrap_command_with_claude_overrides "dedupe_codebase" "$@"
}
```

This Phase 3 implementation provides comprehensive user override mechanisms for .claude operations, including:

1. **Explicit Override Flags** - Clear flags for users to control .claude operations
2. **Confirmation Prompts** - Risk-assessed prompts with detailed information
3. **Dry Run Mode** - Safe preview capability with detailed simulation
4. **Audit Logging** - Comprehensive tracking of all .claude access attempts
5. **Error Messages** - Helpful, actionable error messages with clear guidance
6. **Integration** - Seamless integration with existing quality commands

The system maintains backwards compatibility while providing explicit user control when working with .claude directories is intentional and necessary.