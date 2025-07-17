---
description: Safety mechanisms and risk mitigation for quality command operations
---

# Quality Command Safety Mechanisms

Comprehensive safety mechanisms to ensure secure and reliable execution of quality operations with proper validation, rollback capabilities, and risk mitigation.

## Pre-Operation Safety Checks

```bash
# Comprehensive safety validation before any operation
run_safety_checks() {
    local operation=$1
    local target=${2:-.}
    local dry_run=${3:-false}
    
    echo "Running safety checks for operation: $operation"
    
    # Check 1: Git repository status
    if ! check_git_safety "$target"; then
        echo "ERROR: Git safety check failed"
        return 1
    fi
    
    # Check 2: File permissions
    if ! check_file_permissions "$target"; then
        echo "ERROR: File permission check failed"
        return 1
    fi
    
    # Check 3: Disk space
    if ! check_disk_space "$target"; then
        echo "ERROR: Insufficient disk space"
        return 1
    fi
    
    # Check 4: Critical files protection
    if ! check_critical_files "$target"; then
        echo "ERROR: Critical files at risk"
        return 1
    fi
    
    # Check 5: Concurrent operations
    if ! check_concurrent_operations "$target"; then
        echo "ERROR: Concurrent operations detected"
        return 1
    fi
    
    echo "All safety checks passed"
    return 0
}

# Check git repository safety
check_git_safety() {
    local target=$1
    
    # Check if in git repository
    if git -C "$target" rev-parse --git-dir >/dev/null 2>&1; then
        # Check for uncommitted changes
        if ! git -C "$target" diff --quiet; then
            echo "WARNING: Uncommitted changes detected"
            read -p "Continue with uncommitted changes? [y/N]: " response
            [[ "$response" =~ ^[Yy]$ ]] || return 1
        fi
        
        # Check for untracked important files
        local untracked=$(git -C "$target" ls-files --others --exclude-standard | grep -E '\.(js|ts|py|go|rs|java|c|cpp|rb)$')
        if [ -n "$untracked" ]; then
            echo "WARNING: Untracked source files detected:"
            echo "$untracked"
            read -p "Continue with untracked files? [y/N]: " response
            [[ "$response" =~ ^[Yy]$ ]] || return 1
        fi
        
        # Check current branch
        local current_branch=$(git -C "$target" branch --show-current)
        local protected_branches="main master production release"
        for protected in $protected_branches; do
            if [[ "$current_branch" == "$protected" ]]; then
                echo "WARNING: Operating on protected branch: $current_branch"
                read -p "Continue on protected branch? [y/N]: " response
                [[ "$response" =~ ^[Yy]$ ]] || return 1
            fi
        done
    fi
    
    return 0
}

# Check file permissions and access
check_file_permissions() {
    local target=$1
    
    # Check if target is writable
    if [ ! -w "$target" ]; then
        echo "ERROR: Target directory is not writable: $target"
        return 1
    fi
    
    # Check for read-only files that might need modification
    local readonly_files=$(find "$target" -type f -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" | while read -r file; do
        if [ ! -w "$file" ]; then
            echo "$file"
        fi
    done)
    
    if [ -n "$readonly_files" ]; then
        echo "WARNING: Read-only source files detected:"
        echo "$readonly_files"
        read -p "Attempt to modify read-only files? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]] || return 1
    fi
    
    return 0
}

# Check available disk space
check_disk_space() {
    local target=$1
    local required_mb=${2:-100}  # Default 100MB minimum
    
    local available_kb=$(df "$target" | awk 'NR==2 {print $4}')
    local available_mb=$((available_kb / 1024))
    
    if [ "$available_mb" -lt "$required_mb" ]; then
        echo "ERROR: Insufficient disk space. Available: ${available_mb}MB, Required: ${required_mb}MB"
        return 1
    fi
    
    echo "Disk space check passed: ${available_mb}MB available"
    return 0
}

# Protect critical files from modification
check_critical_files() {
    local target=$1
    local critical_patterns=(
        "package-lock.json"
        "yarn.lock"
        "Cargo.lock"
        "go.sum"
        "Pipfile.lock"
        "composer.lock"
        ".env"
        ".env.production"
        "config/production.json"
        "docker-compose.yml"
        "Dockerfile"
        "LICENSE"
        "README.md"
        ".gitignore"
        ".github/workflows/*"
    )
    
    for pattern in "${critical_patterns[@]}"; do
        if find "$target" -path "*/$pattern" -type f | head -1 | grep -q .; then
            echo "WARNING: Critical files detected that should not be auto-modified:"
            find "$target" -path "*/$pattern" -type f
            read -p "Exclude critical files from operation? [Y/n]: " response
            if [[ ! "$response" =~ ^[Nn]$ ]]; then
                export EXCLUDE_CRITICAL_FILES=true
            fi
            break
        fi
    done
    
    return 0
}

# Check for concurrent operations
check_concurrent_operations() {
    local target=$1
    local lockfile="$target/.quality-lock"
    
    if [ -f "$lockfile" ]; then
        local lock_pid=$(cat "$lockfile" 2>/dev/null)
        if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
            echo "ERROR: Another quality operation is running (PID: $lock_pid)"
            return 1
        else
            echo "Removing stale lock file"
            rm -f "$lockfile"
        fi
    fi
    
    # Create lock file
    echo $$ > "$lockfile"
    return 0
}
```

## Operation Validation

```bash
# Validate operation safety based on scope and type
validate_operation_safety() {
    local operation=$1
    local files=("${@:2}")
    local risk_score=0
    
    echo "Validating operation safety: $operation"
    
    # Calculate risk score based on operation type
    case "$operation" in
        "format")
            risk_score=1  # Low risk
            ;;
        "cleanup")
            risk_score=3  # Medium risk
            ;;
        "dedupe")
            risk_score=4  # Medium-high risk
            ;;
        "verify")
            risk_score=1  # Low risk (read-only)
            ;;
        *)
            risk_score=5  # High risk for unknown operations
            ;;
    esac
    
    # Increase risk based on file count and importance
    local file_count=${#files[@]}
    if [ "$file_count" -gt 100 ]; then
        risk_score=$((risk_score + 2))
    elif [ "$file_count" -gt 20 ]; then
        risk_score=$((risk_score + 1))
    fi
    
    # Check for high-importance files
    for file in "${files[@]}"; do
        if [[ "$file" =~ (main|index|app|server|config)\.(js|ts|py|go)$ ]]; then
            risk_score=$((risk_score + 1))
            break
        fi
    done
    
    # Determine if operation requires confirmation
    if [ "$risk_score" -ge 5 ]; then
        echo "HIGH RISK operation detected (score: $risk_score)"
        echo "Files to be modified: $file_count"
        echo "Operation: $operation"
        read -p "Are you sure you want to continue? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]] || return 1
    elif [ "$risk_score" -ge 3 ]; then
        echo "MEDIUM RISK operation (score: $risk_score)"
        echo "Files to be modified: $file_count"
        read -p "Continue? [Y/n]: " response
        [[ ! "$response" =~ ^[Nn]$ ]] || return 1
    fi
    
    return 0
}

# Validate file safety before modification
validate_file_safety() {
    local file=$1
    local operation=$2
    
    # Check if file exists and is readable
    if [ ! -f "$file" ]; then
        echo "ERROR: File does not exist: $file"
        return 1
    fi
    
    if [ ! -r "$file" ]; then
        echo "ERROR: File is not readable: $file"
        return 1
    fi
    
    # Check file size limits
    local file_size=$(get_file_size "$file")
    local max_size=$((10 * 1024 * 1024))  # 10MB limit
    
    if [ "$file_size" -gt "$max_size" ]; then
        echo "WARNING: Large file detected: $file ($(format_file_size $file_size))"
        read -p "Process large file? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]] || return 1
    fi
    
    # Check if file is binary
    if is_binary_file "$file"; then
        echo "WARNING: Binary file detected: $file"
        return 1
    fi
    
    # Validate syntax before modification
    if [[ "$operation" != "verify" ]]; then
        if ! validate_syntax "$file"; then
            echo "ERROR: Syntax validation failed for: $file"
            return 1
        fi
    fi
    
    return 0
}

# Create safety snapshot before operations
create_safety_snapshot() {
    local target=${1:-.}
    local operation=$2
    
    local snapshot_dir="$target/.quality-snapshots"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local snapshot_name="${operation}_${timestamp}"
    local snapshot_path="$snapshot_dir/$snapshot_name"
    
    mkdir -p "$snapshot_path"
    
    echo "Creating safety snapshot: $snapshot_name"
    
    # Find all source files
    local source_files=$(find_files_filtered "$target" "*" | grep -E '\.(js|ts|py|go|rs|java|c|cpp|rb|php|cs|swift|kt)$')
    
    # Copy files to snapshot
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            local rel_path=${file#$target/}
            local dest_dir="$snapshot_path/$(dirname "$rel_path")"
            mkdir -p "$dest_dir"
            cp "$file" "$snapshot_path/$rel_path"
        fi
    done <<< "$source_files"
    
    # Save metadata
    cat > "$snapshot_path/metadata.json" <<EOF
{
    "timestamp": "$timestamp",
    "operation": "$operation",
    "target": "$target",
    "files_count": $(echo "$source_files" | wc -l),
    "git_commit": "$(git -C "$target" rev-parse HEAD 2>/dev/null || echo "not-in-git")",
    "git_branch": "$(git -C "$target" branch --show-current 2>/dev/null || echo "not-in-git")"
}
EOF
    
    echo "Snapshot created: $snapshot_path"
    echo "$snapshot_path"
}
```

## Rollback Mechanisms

```bash
# Rollback to safety snapshot
rollback_to_snapshot() {
    local snapshot_path=$1
    local target=${2:-.}
    
    if [ ! -d "$snapshot_path" ]; then
        echo "ERROR: Snapshot not found: $snapshot_path"
        return 1
    fi
    
    if [ ! -f "$snapshot_path/metadata.json" ]; then
        echo "ERROR: Invalid snapshot (missing metadata): $snapshot_path"
        return 1
    fi
    
    echo "Rolling back to snapshot: $(basename "$snapshot_path")"
    
    # Confirm rollback
    read -p "This will overwrite current files. Continue? [y/N]: " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Rollback cancelled"
        return 1
    fi
    
    # Create backup of current state before rollback
    local rollback_backup=$(create_safety_snapshot "$target" "pre-rollback")
    echo "Current state backed up to: $rollback_backup"
    
    # Restore files from snapshot
    local files_restored=0
    while IFS= read -r file; do
        local rel_path=${file#$snapshot_path/}
        local dest_file="$target/$rel_path"
        
        if [[ "$rel_path" != "metadata.json" ]] && [ -f "$file" ]; then
            mkdir -p "$(dirname "$dest_file")"
            cp "$file" "$dest_file"
            files_restored=$((files_restored + 1))
        fi
    done < <(find "$snapshot_path" -type f)
    
    echo "Rollback completed: $files_restored files restored"
    
    # Show metadata
    if command -v jq >/dev/null 2>&1; then
        echo "Snapshot metadata:"
        jq . "$snapshot_path/metadata.json"
    fi
    
    return 0
}

# List available snapshots
list_snapshots() {
    local target=${1:-.}
    local snapshot_dir="$target/.quality-snapshots"
    
    if [ ! -d "$snapshot_dir" ]; then
        echo "No snapshots found"
        return 0
    fi
    
    echo "Available snapshots:"
    echo "===================="
    
    for snapshot in "$snapshot_dir"/*; do
        if [ -d "$snapshot" ] && [ -f "$snapshot/metadata.json" ]; then
            local name=$(basename "$snapshot")
            local timestamp=$(jq -r '.timestamp // "unknown"' "$snapshot/metadata.json" 2>/dev/null)
            local operation=$(jq -r '.operation // "unknown"' "$snapshot/metadata.json" 2>/dev/null)
            local files_count=$(jq -r '.files_count // "unknown"' "$snapshot/metadata.json" 2>/dev/null)
            
            echo "$name"
            echo "  Timestamp: $timestamp"
            echo "  Operation: $operation"
            echo "  Files: $files_count"
            echo ""
        fi
    done
}

# Clean old snapshots
clean_old_snapshots() {
    local target=${1:-.}
    local days=${2:-7}
    local snapshot_dir="$target/.quality-snapshots"
    
    if [ ! -d "$snapshot_dir" ]; then
        return 0
    fi
    
    echo "Cleaning snapshots older than $days days..."
    
    local cleaned=0
    find "$snapshot_dir" -type d -maxdepth 1 -mtime +$days | while read -r snapshot; do
        if [[ "$(basename "$snapshot")" != ".quality-snapshots" ]]; then
            echo "Removing old snapshot: $(basename "$snapshot")"
            rm -rf "$snapshot"
            cleaned=$((cleaned + 1))
        fi
    done
    
    echo "Cleaned $cleaned old snapshots"
}
```

## Integrity Verification

```bash
# Verify operation integrity
verify_operation_integrity() {
    local target=${1:-.}
    local operation=$2
    local pre_snapshot=$3
    
    echo "Verifying operation integrity..."
    
    local errors=0
    local warnings=0
    
    # Check 1: All files still exist
    if [ -n "$pre_snapshot" ] && [ -d "$pre_snapshot" ]; then
        while IFS= read -r snapshot_file; do
            local rel_path=${snapshot_file#$pre_snapshot/}
            local current_file="$target/$rel_path"
            
            if [[ "$rel_path" != "metadata.json" ]] && [ ! -f "$current_file" ]; then
                echo "ERROR: File deleted: $current_file"
                errors=$((errors + 1))
            fi
        done < <(find "$pre_snapshot" -type f)
    fi
    
    # Check 2: Syntax validation for all modified files
    local source_files=$(find_files_filtered "$target" "*" | grep -E '\.(js|ts|py|go|rs|java|c|cpp|rb|php|cs|swift|kt)$')
    
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if ! validate_syntax "$file"; then
                echo "ERROR: Syntax error in: $file"
                errors=$((errors + 1))
            fi
        fi
    done <<< "$source_files"
    
    # Check 3: File encoding consistency
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if ! check_file_encoding "$file"; then
                echo "WARNING: Encoding issue in: $file"
                warnings=$((warnings + 1))
            fi
        fi
    done <<< "$source_files"
    
    # Check 4: Line ending consistency
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            if ! check_line_endings "$file"; then
                echo "WARNING: Line ending issue in: $file"
                warnings=$((warnings + 1))
            fi
        fi
    done <<< "$source_files"
    
    # Report results
    echo "Integrity verification complete:"
    echo "  Errors: $errors"
    echo "  Warnings: $warnings"
    
    if [ "$errors" -gt 0 ]; then
        echo "CRITICAL: Operation integrity compromised"
        return 1
    elif [ "$warnings" -gt 0 ]; then
        echo "WARNING: Minor issues detected"
        return 2
    else
        echo "SUCCESS: Operation integrity verified"
        return 0
    fi
}

# Emergency stop mechanism
emergency_stop() {
    local target=${1:-.}
    local reason=${2:-"User requested"}
    
    echo "EMERGENCY STOP: $reason"
    
    # Remove operation lock
    rm -f "$target/.quality-lock"
    
    # Kill any running quality processes
    pkill -f "quality-" 2>/dev/null || true
    
    # Create emergency log
    cat > "$target/.quality-emergency.log" <<EOF
Emergency Stop: $(date)
Reason: $reason
PID: $$
Working Directory: $(pwd)
Target: $target
EOF
    
    echo "Emergency stop completed. Lock removed."
    exit 130  # Interrupted by signal
}

# Set up emergency signal handlers
setup_emergency_handlers() {
    local target=${1:-.}
    
    trap "emergency_stop '$target' 'SIGINT received'" INT
    trap "emergency_stop '$target' 'SIGTERM received'" TERM
    trap "emergency_stop '$target' 'Script exit'" EXIT
}

# Cleanup function for safe exit
cleanup_on_exit() {
    local target=${1:-.}
    local exit_code=$?
    
    # Remove lock file
    rm -f "$target/.quality-lock"
    
    # Clean up temporary files
    rm -f /tmp/quality-* 2>/dev/null || true
    
    if [ "$exit_code" -ne 0 ]; then
        echo "Operation exited with code: $exit_code"
        
        # Create error log
        cat > "$target/.quality-error.log" <<EOF
Operation Failed: $(date)
Exit Code: $exit_code
PID: $$
Working Directory: $(pwd)
Target: $target
EOF
    fi
    
    exit $exit_code
}
```

## Risk Assessment

```bash
# Assess operation risk level
assess_operation_risk() {
    local operation=$1
    local target=${2:-.}
    local files=("${@:3}")
    
    local risk_factors=()
    local risk_score=0
    
    # Factor 1: Operation type risk
    case "$operation" in
        "verify")
            risk_score=0
            ;;
        "format")
            risk_score=1
            risk_factors+=("Low-risk formatting operation")
            ;;
        "cleanup")
            risk_score=3
            risk_factors+=("Medium-risk cleanup operation")
            ;;
        "dedupe")
            risk_score=4
            risk_factors+=("High-risk deduplication operation")
            ;;
        *)
            risk_score=5
            risk_factors+=("Unknown operation type")
            ;;
    esac
    
    # Factor 2: Repository status
    if git -C "$target" status --porcelain | grep -q .; then
        risk_score=$((risk_score + 1))
        risk_factors+=("Uncommitted changes present")
    fi
    
    # Factor 3: File count
    local file_count=${#files[@]}
    if [ "$file_count" -gt 100 ]; then
        risk_score=$((risk_score + 2))
        risk_factors+=("Large number of files ($file_count)")
    elif [ "$file_count" -gt 50 ]; then
        risk_score=$((risk_score + 1))
        risk_factors+=("Moderate number of files ($file_count)")
    fi
    
    # Factor 4: Critical files
    local critical_count=0
    for file in "${files[@]}"; do
        if [[ "$file" =~ (main|index|app|server|config)\.(js|ts|py|go)$ ]]; then
            critical_count=$((critical_count + 1))
        fi
    done
    
    if [ "$critical_count" -gt 0 ]; then
        risk_score=$((risk_score + 2))
        risk_factors+=("Critical files affected ($critical_count)")
    fi
    
    # Factor 5: No tests detected
    if ! find "$target" -name "*test*" -o -name "*spec*" | head -1 | grep -q .; then
        risk_score=$((risk_score + 1))
        risk_factors+=("No test files detected")
    fi
    
    # Determine risk level
    local risk_level="LOW"
    if [ "$risk_score" -ge 7 ]; then
        risk_level="CRITICAL"
    elif [ "$risk_score" -ge 5 ]; then
        risk_level="HIGH"
    elif [ "$risk_score" -ge 3 ]; then
        risk_level="MEDIUM"
    fi
    
    echo "Risk Assessment: $risk_level (Score: $risk_score)"
    echo "Risk Factors:"
    for factor in "${risk_factors[@]}"; do
        echo "  - $factor"
    done
    
    echo "$risk_score"
}
```

## Advanced Rollback Mechanisms

```bash
# Advanced rollback with selective file restoration
selective_rollback() {
    local snapshot_path=$1
    local target=${2:-.}
    local file_patterns=("${@:3}")
    
    if [ ! -d "$snapshot_path" ]; then
        echo "ERROR: Snapshot not found: $snapshot_path"
        return 1
    fi
    
    echo "Performing selective rollback from: $(basename "$snapshot_path")"
    
    local files_restored=0
    local files_skipped=0
    
    if [ ${#file_patterns[@]} -eq 0 ]; then
        # No patterns specified, restore all files
        file_patterns=("*")
    fi
    
    for pattern in "${file_patterns[@]}"; do
        while IFS= read -r snapshot_file; do
            local rel_path=${snapshot_file#$snapshot_path/}
            local dest_file="$target/$rel_path"
            
            if [[ "$rel_path" != "metadata.json" ]] && [ -f "$snapshot_file" ]; then
                # Check if file should be restored
                if should_restore_file "$snapshot_file" "$dest_file"; then
                    mkdir -p "$(dirname "$dest_file")"
                    
                    # Create backup of current version before restoring
                    if [ -f "$dest_file" ]; then
                        local backup_file="$dest_file.pre-rollback.$(date +%s)"
                        cp "$dest_file" "$backup_file"
                        echo "Current version backed up: $backup_file"
                    fi
                    
                    cp "$snapshot_file" "$dest_file"
                    echo "Restored: $rel_path"
                    files_restored=$((files_restored + 1))
                else
                    echo "Skipped: $rel_path (would overwrite newer changes)"
                    files_skipped=$((files_skipped + 1))
                fi
            fi
        done < <(find "$snapshot_path" -name "$pattern" -type f)
    done
    
    echo "Selective rollback completed:"
    echo "  Files restored: $files_restored"
    echo "  Files skipped: $files_skipped"
    
    return 0
}

# Check if file should be restored during rollback
should_restore_file() {
    local snapshot_file=$1
    local current_file=$2
    local force_restore=${3:-false}
    
    if $force_restore; then
        return 0
    fi
    
    if [ ! -f "$current_file" ]; then
        # File doesn't exist, safe to restore
        return 0
    fi
    
    # Compare modification times
    local snapshot_mtime=$(stat -f%m "$snapshot_file" 2>/dev/null || stat -c%Y "$snapshot_file" 2>/dev/null)
    local current_mtime=$(stat -f%m "$current_file" 2>/dev/null || stat -c%Y "$current_file" 2>/dev/null)
    
    if [ "$current_mtime" -gt "$snapshot_mtime" ]; then
        # Current file is newer, ask user
        echo "WARNING: Current file is newer than snapshot"
        echo "  Current: $(date -r "$current_file" 2>/dev/null || date -d "@$current_mtime" 2>/dev/null)"
        echo "  Snapshot: $(date -r "$snapshot_file" 2>/dev/null || date -d "@$snapshot_mtime" 2>/dev/null)"
        read -p "Restore anyway? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]]
    else
        return 0
    fi
}

# Create differential backup (only changed files)
create_differential_backup() {
    local target=${1:-.}
    local operation=$2
    local base_snapshot=${3:-}
    
    local snapshot_dir="$target/.quality-snapshots"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local snapshot_name="${operation}_diff_${timestamp}"
    local snapshot_path="$snapshot_dir/$snapshot_name"
    
    mkdir -p "$snapshot_path"
    
    echo "Creating differential backup: $snapshot_name"
    
    local files_backed_up=0
    local total_size=0
    
    # Find files that have changed since base snapshot
    local base_time=""
    if [ -n "$base_snapshot" ] && [ -d "$base_snapshot" ]; then
        base_time=$(stat -f%m "$base_snapshot/metadata.json" 2>/dev/null || stat -c%Y "$base_snapshot/metadata.json" 2>/dev/null)
    fi
    
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file"; then
            local should_backup=false
            
            if [ -n "$base_time" ]; then
                local file_mtime=$(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null)
                if [ "$file_mtime" -gt "$base_time" ]; then
                    should_backup=true
                fi
            else
                should_backup=true
            fi
            
            if $should_backup; then
                local rel_path=${file#$target/}
                local dest_dir="$snapshot_path/$(dirname "$rel_path")"
                mkdir -p "$dest_dir"
                cp "$file" "$snapshot_path/$rel_path"
                
                files_backed_up=$((files_backed_up + 1))
                total_size=$((total_size + $(get_file_size "$file")))
            fi
        fi
    done
    
    # Save differential metadata
    cat > "$snapshot_path/metadata.json" <<EOF
{
    "timestamp": "$timestamp",
    "operation": "$operation",
    "target": "$target",
    "backup_type": "differential",
    "base_snapshot": "$base_snapshot",
    "files_count": $files_backed_up,
    "total_size": $total_size,
    "git_commit": "$(git -C "$target" rev-parse HEAD 2>/dev/null || echo "not-in-git")",
    "git_branch": "$(git -C "$target" branch --show-current 2>/dev/null || echo "not-in-git")"
}
EOF
    
    echo "Differential backup created: $snapshot_path"
    echo "  Files backed up: $files_backed_up"
    echo "  Total size: $(format_file_size $total_size)"
    echo "$snapshot_path"
}

# Incremental backup chain management
manage_backup_chain() {
    local target=${1:-.}
    local action=${2:-"list"}  # list, prune, verify
    local max_chain_length=${3:-10}
    
    local snapshot_dir="$target/.quality-snapshots"
    
    case "$action" in
        "list")
            list_backup_chain "$snapshot_dir"
            ;;
        "prune")
            prune_backup_chain "$snapshot_dir" "$max_chain_length"
            ;;
        "verify")
            verify_backup_chain "$snapshot_dir"
            ;;
        *)
            echo "ERROR: Unknown action: $action"
            return 1
            ;;
    esac
}

# List backup chain with relationships
list_backup_chain() {
    local snapshot_dir=$1
    
    echo "Backup Chain Analysis"
    echo "===================="
    
    if [ ! -d "$snapshot_dir" ]; then
        echo "No backup directory found"
        return 0
    fi
    
    local full_backups=()
    local diff_backups=()
    
    for snapshot in "$snapshot_dir"/*; do
        if [ -d "$snapshot" ] && [ -f "$snapshot/metadata.json" ]; then
            local backup_type=$(jq -r '.backup_type // "full"' "$snapshot/metadata.json" 2>/dev/null)
            local name=$(basename "$snapshot")
            
            if [ "$backup_type" = "differential" ]; then
                diff_backups+=("$name")
            else
                full_backups+=("$name")
            fi
        fi
    done
    
    echo "Full Backups:"
    for backup in "${full_backups[@]}"; do
        local metadata_file="$snapshot_dir/$backup/metadata.json"
        local timestamp=$(jq -r '.timestamp' "$metadata_file" 2>/dev/null)
        local operation=$(jq -r '.operation' "$metadata_file" 2>/dev/null)
        local files_count=$(jq -r '.files_count' "$metadata_file" 2>/dev/null)
        
        echo "  $backup - $timestamp ($operation, $files_count files)"
    done
    
    echo ""
    echo "Differential Backups:"
    for backup in "${diff_backups[@]}"; do
        local metadata_file="$snapshot_dir/$backup/metadata.json"
        local timestamp=$(jq -r '.timestamp' "$metadata_file" 2>/dev/null)
        local operation=$(jq -r '.operation' "$metadata_file" 2>/dev/null)
        local base_snapshot=$(jq -r '.base_snapshot // "none"' "$metadata_file" 2>/dev/null)
        local files_count=$(jq -r '.files_count' "$metadata_file" 2>/dev/null)
        
        echo "  $backup - $timestamp ($operation, $files_count files, base: $(basename "$base_snapshot"))"
    done
}

# Prune old backups maintaining chain integrity
prune_backup_chain() {
    local snapshot_dir=$1
    local max_length=$2
    
    echo "Pruning backup chain (max length: $max_length)"
    
    # Get sorted list of backups by timestamp
    local backups=()
    while IFS= read -r backup; do
        backups+=("$backup")
    done < <(ls -t "$snapshot_dir" 2>/dev/null | head -"$max_length")
    
    # Remove backups not in the preserved list
    for snapshot in "$snapshot_dir"/*; do
        local name=$(basename "$snapshot")
        local preserve=false
        
        for preserved in "${backups[@]}"; do
            if [ "$name" = "$preserved" ]; then
                preserve=true
                break
            fi
        done
        
        if ! $preserve && [ -d "$snapshot" ]; then
            echo "Removing old backup: $name"
            rm -rf "$snapshot"
        fi
    done
    
    echo "Backup chain pruning completed"
}
```

## Enhanced Configuration Safety

```bash
# Validate tool configurations before operations
validate_tool_configurations() {
    local target=${1:-.}
    local languages=("${@:2}")
    
    echo "Validating tool configurations..."
    
    local validation_errors=0
    local validation_warnings=0
    
    for language in "${languages[@]}"; do
        echo "Checking $language configurations..."
        
        # Find configuration files for the language
        local config_files=$(find_config_files "$target" "$language")
        
        while IFS= read -r config_file; do
            if [ -f "$config_file" ]; then
                if ! validate_language_config "$config_file" "$language"; then
                    validation_errors=$((validation_errors + 1))
                    echo "ERROR: Invalid configuration: $config_file"
                else
                    echo "VALID: $config_file"
                fi
            fi
        done <<< "$config_files"
        
        # Check for tool availability
        local formatters=$(detect_formatters "$language")
        local linters=$(detect_linters "$language")
        
        if [ -z "$formatters" ]; then
            echo "WARNING: No formatters available for $language"
            validation_warnings=$((validation_warnings + 1))
        fi
        
        if [ -z "$linters" ]; then
            echo "WARNING: No linters available for $language"
            validation_warnings=$((validation_warnings + 1))
        fi
    done
    
    echo "Configuration validation completed:"
    echo "  Errors: $validation_errors"
    echo "  Warnings: $validation_warnings"
    
    if [ $validation_errors -gt 0 ]; then
        echo "CRITICAL: Configuration errors must be fixed before proceeding"
        return 1
    elif [ $validation_warnings -gt 0 ]; then
        echo "WARNING: Some tools may not be available"
        read -p "Continue despite warnings? [Y/n]: " response
        [[ ! "$response" =~ ^[Nn]$ ]]
    else
        echo "All configurations are valid"
        return 0
    fi
}

# Validate specific language configuration file
validate_language_config() {
    local config_file=$1
    local language=$2
    
    case "$language" in
        "javascript"|"typescript")
            case "$(basename "$config_file")" in
                ".eslintrc"*|"eslint.config."*)
                    if command -v eslint >/dev/null 2>&1; then
                        eslint --print-config "$config_file" >/dev/null 2>&1
                    else
                        # Basic JSON/YAML validation
                        validate_config_syntax "$config_file"
                    fi
                    ;;
                ".prettierrc"*|"prettier.config."*)
                    validate_config_syntax "$config_file"
                    ;;
                *)
                    return 0
                    ;;
            esac
            ;;
        "python")
            case "$(basename "$config_file")" in
                "pyproject.toml"|"setup.cfg"|".flake8"|"tox.ini")
                    # Basic TOML/INI validation
                    validate_config_syntax "$config_file"
                    ;;
                "mypy.ini")
                    validate_config_syntax "$config_file"
                    ;;
                *)
                    return 0
                    ;;
            esac
            ;;
        "go")
            case "$(basename "$config_file")" in
                ".golangci.yml"|"golangci.yaml")
                    if command -v yamllint >/dev/null 2>&1; then
                        yamllint "$config_file" >/dev/null 2>&1
                    else
                        validate_config_syntax "$config_file"
                    fi
                    ;;
                *)
                    return 0
                    ;;
            esac
            ;;
        *)
            # Generic validation
            validate_config_syntax "$config_file"
            ;;
    esac
}

# Validate configuration file syntax
validate_config_syntax() {
    local config_file=$1
    local extension="${config_file##*.}"
    
    case "$extension" in
        "json")
            if command -v jq >/dev/null 2>&1; then
                jq empty "$config_file" >/dev/null 2>&1
            else
                # Fallback: try to parse with python
                python -c "import json; json.load(open('$config_file'))" 2>/dev/null
            fi
            ;;
        "yaml"|"yml")
            if command -v yamllint >/dev/null 2>&1; then
                yamllint "$config_file" >/dev/null 2>&1
            elif command -v yq >/dev/null 2>&1; then
                yq eval . "$config_file" >/dev/null 2>&1
            else
                # Basic YAML validation with python
                python -c "import yaml; yaml.safe_load(open('$config_file'))" 2>/dev/null
            fi
            ;;
        "toml")
            # Basic TOML validation
            if command -v python3 >/dev/null 2>&1; then
                python3 -c "import tomllib; tomllib.load(open('$config_file', 'rb'))" 2>/dev/null
            else
                # Fallback: basic syntax check
                grep -q "^\[.*\]" "$config_file" && ! grep -q "^\[.*\[.*\]" "$config_file"
            fi
            ;;
        "ini"|"cfg")
            # Basic INI validation
            python -c "import configparser; c=configparser.ConfigParser(); c.read('$config_file')" 2>/dev/null
            ;;
        *)
            # Unknown format, assume valid
            return 0
            ;;
    esac
}

# Safe configuration modification
safely_modify_config() {
    local config_file=$1
    local modification_script=$2
    local backup_suffix=${3:-".safety-backup"}
    
    echo "Safely modifying configuration: $config_file"
    
    # Create backup
    local backup_file="$config_file$backup_suffix"
    cp "$config_file" "$backup_file"
    echo "Configuration backed up to: $backup_file"
    
    # Apply modification
    if eval "$modification_script"; then
        # Validate modified configuration
        if validate_language_config "$config_file" "$(detect_config_language "$config_file")"; then
            echo "Configuration modification successful"
            rm -f "$backup_file"  # Remove backup if successful
            return 0
        else
            echo "ERROR: Modified configuration is invalid, restoring backup"
            mv "$backup_file" "$config_file"
            return 1
        fi
    else
        echo "ERROR: Configuration modification failed, restoring backup"
        mv "$backup_file" "$config_file"
        return 1
    fi
}

# Detect configuration file language/type
detect_config_language() {
    local config_file=$1
    local basename_file=$(basename "$config_file")
    
    case "$basename_file" in
        ".eslintrc"*|"eslint.config."*|".prettierrc"*|"prettier.config."*)
            echo "javascript"
            ;;
        "pyproject.toml"|"setup.cfg"|".flake8"|"tox.ini"|"mypy.ini")
            echo "python"
            ;;
        ".golangci.yml"|"golangci.yaml"|"go.mod")
            echo "go"
            ;;
        "Cargo.toml"|"rustfmt.toml"|".rustfmt.toml")
            echo "rust"
            ;;
        ".rubocop.yml"|"Gemfile")
            echo "ruby"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}
```

## Enhanced Integrity Verification

```bash
# Comprehensive integrity verification with detailed reporting
verify_comprehensive_integrity() {
    local target=${1:-.}
    local operation=$2
    local pre_snapshot=${3:-}
    local verification_level=${4:-"standard"}  # basic, standard, comprehensive
    
    echo "Performing comprehensive integrity verification..."
    echo "Level: $verification_level"
    
    local verification_results=()
    local critical_errors=0
    local major_warnings=0
    local minor_warnings=0
    
    # Level 1: Basic integrity checks
    echo "Level 1: Basic integrity checks"
    if ! verify_basic_integrity "$target" "$pre_snapshot"; then
        verification_results+=("CRITICAL: Basic integrity check failed")
        critical_errors=$((critical_errors + 1))
    else
        verification_results+=("PASS: Basic integrity check")
    fi
    
    # Level 2: Syntax and compilation checks
    if [[ "$verification_level" != "basic" ]]; then
        echo "Level 2: Syntax and compilation verification"
        local syntax_result=$(verify_syntax_integrity "$target")
        verification_results+=("$syntax_result")
        
        if [[ "$syntax_result" == CRITICAL:* ]]; then
            critical_errors=$((critical_errors + 1))
        elif [[ "$syntax_result" == WARNING:* ]]; then
            major_warnings=$((major_warnings + 1))
        fi
    fi
    
    # Level 3: Semantic and functional checks
    if [[ "$verification_level" == "comprehensive" ]]; then
        echo "Level 3: Semantic and functional verification"
        local semantic_result=$(verify_semantic_integrity "$target" "$operation")
        verification_results+=("$semantic_result")
        
        if [[ "$semantic_result" == CRITICAL:* ]]; then
            critical_errors=$((critical_errors + 1))
        elif [[ "$semantic_result" == WARNING:* ]]; then
            major_warnings=$((major_warnings + 1))
        fi
        
        # Advanced checks
        echo "Level 3b: Advanced integrity checks"
        local advanced_result=$(verify_advanced_integrity "$target")
        verification_results+=("$advanced_result")
        
        if [[ "$advanced_result" == WARNING:* ]]; then
            minor_warnings=$((minor_warnings + 1))
        fi
    fi
    
    # Generate comprehensive report
    generate_integrity_report "$target" "$operation" "${verification_results[@]}"
    
    echo ""
    echo "Integrity Verification Summary:"
    echo "=============================="
    echo "Critical Errors: $critical_errors"
    echo "Major Warnings: $major_warnings"
    echo "Minor Warnings: $minor_warnings"
    
    if [ $critical_errors -gt 0 ]; then
        echo "RESULT: FAILED - Critical integrity issues detected"
        return 1
    elif [ $major_warnings -gt 0 ]; then
        echo "RESULT: WARNING - Major issues detected, manual review recommended"
        return 2
    elif [ $minor_warnings -gt 0 ]; then
        echo "RESULT: CAUTION - Minor issues detected, monitoring recommended"
        return 3
    else
        echo "RESULT: PASSED - All integrity checks successful"
        return 0
    fi
}

# Verify basic integrity (file existence, permissions, etc.)
verify_basic_integrity() {
    local target=$1
    local pre_snapshot=$2
    
    local errors=0
    
    # Check 1: All expected files exist
    if [ -n "$pre_snapshot" ] && [ -d "$pre_snapshot" ]; then
        while IFS= read -r snapshot_file; do
            local rel_path=${snapshot_file#$pre_snapshot/}
            local current_file="$target/$rel_path"
            
            if [[ "$rel_path" != "metadata.json" ]] && [ ! -f "$current_file" ]; then
                echo "ERROR: File missing after operation: $current_file"
                errors=$((errors + 1))
            fi
        done < <(find "$pre_snapshot" -type f -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.rs")
    fi
    
    # Check 2: File permissions preserved
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file" && [ ! -r "$file" ]; then
            echo "ERROR: File became unreadable: $file"
            errors=$((errors + 1))
        fi
    done
    
    return $errors
}

# Verify syntax integrity across all files
verify_syntax_integrity() {
    local target=$1
    
    local syntax_errors=0
    local total_files=0
    
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file"; then
            total_files=$((total_files + 1))
            
            if ! validate_syntax "$file"; then
                echo "SYNTAX ERROR: $file"
                syntax_errors=$((syntax_errors + 1))
            fi
        fi
    done
    
    if [ $syntax_errors -gt 0 ]; then
        echo "CRITICAL: $syntax_errors syntax errors in $total_files files"
    else
        echo "PASS: All $total_files files have valid syntax"
    fi
}

# Verify semantic integrity (imports, references, etc.)
verify_semantic_integrity() {
    local target=$1
    local operation=$2
    
    local semantic_issues=0
    
    # Check for broken imports
    echo "Checking import integrity..."
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file"; then
            local broken_imports=$(check_file_imports "$file")
            if [ -n "$broken_imports" ]; then
                echo "WARNING: Broken imports in $file:"
                echo "$broken_imports" | sed 's/^/  /'
                semantic_issues=$((semantic_issues + 1))
            fi
        fi
    done
    
    # Check for undefined references (basic)
    echo "Checking reference integrity..."
    local undefined_refs=$(check_undefined_references "$target")
    if [ -n "$undefined_refs" ]; then
        echo "WARNING: Potential undefined references detected:"
        echo "$undefined_refs" | sed 's/^/  /'
        semantic_issues=$((semantic_issues + 1))
    fi
    
    if [ $semantic_issues -gt 0 ]; then
        echo "WARNING: $semantic_issues semantic issues detected"
    else
        echo "PASS: Semantic integrity verified"
    fi
}

# Check file imports for validity
check_file_imports() {
    local file=$1
    local language=$(detect_file_language "$file")
    local broken_imports=""
    
    case "$language" in
        "javascript"|"typescript")
            # Check ES6 imports and require statements
            while IFS= read -r import_line; do
                local import_path=$(echo "$import_line" | sed -E 's/.*from\s+['\''"]([^'\''"]*)['\''"]/\1/')
                if [[ "$import_path" =~ ^\. ]] && [[ "$import_path" != "$import_line" ]]; then
                    # Relative import, check if file exists
                    local full_path=$(resolve_import_path "$file" "$import_path")
                    if [ ! -f "$full_path" ]; then
                        broken_imports="$broken_imports\n  $import_line -> $full_path (missing)"
                    fi
                fi
            done < <(extract_imports "$file")
            ;;
        "python")
            # Check Python imports
            while IFS= read -r import_line; do
                local module_name=$(echo "$import_line" | sed -E 's/^(from\s+)?([a-zA-Z0-9_.]+).*/\2/')
                if [[ "$import_line" =~ ^from.*\. ]] && [ -n "$module_name" ]; then
                    # Relative import, basic check
                    local potential_file=$(dirname "$file")/"$module_name".py
                    if [ ! -f "$potential_file" ]; then
                        broken_imports="$broken_imports\n  $import_line -> potential issue"
                    fi
                fi
            done < <(extract_imports "$file")
            ;;
    esac
    
    echo -e "$broken_imports"
}

# Resolve import path to actual file path
resolve_import_path() {
    local base_file=$1
    local import_path=$2
    local base_dir=$(dirname "$base_file")
    
    # Handle different import patterns
    case "$import_path" in
        "./"*)
            echo "$base_dir/${import_path#./}"
            ;;
        "../"*)
            echo "$(cd "$base_dir" && cd "$import_path" && pwd 2>/dev/null || echo "$base_dir/$import_path")"
            ;;
        "./"*)
            echo "$base_dir/$import_path"
            ;;
        *)
            echo "$import_path"
            ;;
    esac
}

# Advanced integrity verification
verify_advanced_integrity() {
    local target=$1
    
    local advanced_issues=0
    
    # Check for code quality regressions
    echo "Checking code quality metrics..."
    local quality_issues=$(analyze_quality_regressions "$target")
    if [ -n "$quality_issues" ]; then
        echo "WARNING: Code quality regressions detected:"
        echo "$quality_issues" | sed 's/^/  /'
        advanced_issues=$((advanced_issues + 1))
    fi
    
    # Check for security vulnerabilities
    echo "Checking security integrity..."
    local security_issues=$(check_security_integrity "$target")
    if [ -n "$security_issues" ]; then
        echo "WARNING: Security integrity issues detected:"
        echo "$security_issues" | sed 's/^/  /'
        advanced_issues=$((advanced_issues + 1))
    fi
    
    # Check for performance regressions
    echo "Checking performance indicators..."
    local perf_issues=$(check_performance_indicators "$target")
    if [ -n "$perf_issues" ]; then
        echo "INFO: Performance indicators to monitor:"
        echo "$perf_issues" | sed 's/^/  /'
    fi
    
    if [ $advanced_issues -gt 0 ]; then
        echo "WARNING: $advanced_issues advanced integrity issues detected"
    else
        echo "PASS: Advanced integrity checks completed"
    fi
}

# Generate comprehensive integrity report
generate_integrity_report() {
    local target=$1
    local operation=$2
    shift 2
    local results=("$@")
    
    local report_dir="$target/.quality-reports"
    mkdir -p "$report_dir"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local report_file="$report_dir/integrity_report_${operation}_${timestamp}.txt"
    
    cat > "$report_file" <<EOF
Integrity Verification Report
============================
Target: $target
Operation: $operation
Generated: $(date)
Verification Level: comprehensive

Results:
--------
EOF
    
    for result in "${results[@]}"; do
        echo "$result" >> "$report_file"
    done
    
    cat >> "$report_file" <<EOF

System Information:
------------------
Git Status: $(git -C "$target" status --porcelain 2>/dev/null | wc -l) modified files
Git Commit: $(git -C "$target" rev-parse HEAD 2>/dev/null || echo "not-in-git")
Working Directory: $target
User: $(whoami)
Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
    
    echo "Integrity report generated: $report_file"
}

# Analyze quality regressions
analyze_quality_regressions() {
    local target=$1
    local regressions=""
    
    # Check for increased complexity
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file"; then
            local complexity=$(calculate_complexity "$file")
            if [ "$complexity" -gt 15 ]; then
                regressions="$regressions\nHigh complexity in $file: $complexity"
            fi
        fi
    done
    
    # Check for very long files
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file"; then
            local lines=$(wc -l < "$file")
            if [ "$lines" -gt 1000 ]; then
                regressions="$regressions\nVery long file: $file ($lines lines)"
            fi
        fi
    done
    
    echo -e "$regressions"
}

# Check security integrity
check_security_integrity() {
    local target=$1
    local security_issues=""
    
    # Check for common security issues
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file"; then
            # Check for hardcoded secrets
            if grep -q -E "(password|secret|token|key)\s*=\s*['\"][^'\"]{8,}" "$file"; then
                security_issues="$security_issues\nPotential hardcoded secrets in $file"
            fi
            
            # Check for eval usage
            if grep -q -E "(eval|exec)\s*\(" "$file"; then
                security_issues="$security_issues\nDangerous eval/exec usage in $file"
            fi
        fi
    done
    
    echo -e "$security_issues"
}

# Check performance indicators
check_performance_indicators() {
    local target=$1
    local indicators=""
    
    # Check for nested loops
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file"; then
            local nested_loops=$(grep -c -E "(for|while).*{[^}]*(for|while)" "$file" 2>/dev/null || echo "0")
            if [ "$nested_loops" -gt 0 ]; then
                indicators="$indicators\nNested loops detected in $file: $nested_loops"
            fi
        fi
    done
    
    echo -e "$indicators"
}
```

## .claude Directory Protection Hooks

```bash
# .claude directory protection and safety mechanisms
protect_claude_directory() {
    local target=${1:-.}
    local operation=$2
    local dry_run=${3:-false}
    
    echo "Activating .claude directory protection..."
    
    # Check if .claude directory exists
    local claude_dir="$target/.claude"
    if [ ! -d "$claude_dir" ]; then
        echo "No .claude directory found, skipping protection"
        return 0
    fi
    
    # Validate .claude directory access
    if ! validate_claude_access "$claude_dir" "$operation"; then
        echo "ERROR: .claude directory access validation failed"
        return 1
    fi
    
    # Check for .claude-specific risks
    local claude_risk_score=$(assess_claude_operation_risk "$claude_dir" "$operation")
    if [ "$claude_risk_score" -ge 8 ]; then
        echo "CRITICAL: High risk operation on .claude directory (score: $claude_risk_score)"
        return 1
    fi
    
    # Create .claude-specific safety snapshot
    if [ "$claude_risk_score" -ge 3 ]; then
        local claude_snapshot=$(create_claude_safety_snapshot "$claude_dir" "$operation")
        echo "Claude safety snapshot created: $claude_snapshot"
        export CLAUDE_SAFETY_SNAPSHOT="$claude_snapshot"
    fi
    
    # Set up .claude monitoring
    setup_claude_monitoring "$claude_dir" "$operation"
    
    echo ".claude directory protection activated"
    return 0
}

# Validate access to .claude directory
validate_claude_access() {
    local claude_dir=$1
    local operation=$2
    
    echo "Validating .claude directory access for operation: $operation"
    
    # Check if .claude directory is writable
    if [ ! -w "$claude_dir" ]; then
        echo "ERROR: .claude directory is not writable"
        return 1
    fi
    
    # Check for concurrent .claude operations
    local claude_lockfile="$claude_dir/.claude-operation.lock"
    if [ -f "$claude_lockfile" ]; then
        local lock_pid=$(cat "$claude_lockfile" 2>/dev/null)
        if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
            echo "ERROR: Another .claude operation is running (PID: $lock_pid)"
            return 1
        else
            echo "Removing stale .claude lock file"
            rm -f "$claude_lockfile"
        fi
    fi
    
    # Create operation lock
    echo $$ > "$claude_lockfile"
    
    # Check for critical .claude files
    local critical_claude_files=(
        "settings.local.json"
        "commands"
        "templates"
    )
    
    for critical_file in "${critical_claude_files[@]}"; do
        local full_path="$claude_dir/$critical_file"
        if [ -e "$full_path" ]; then
            echo "PROTECTED: Critical .claude file detected: $critical_file"
            
            # Ask for user confirmation for modifications
            if [[ "$operation" == "cleanup" ]] || [[ "$operation" == "dedupe" ]] || [[ "$operation" == "format" ]]; then
                read -p "Operation '$operation' may affect .claude/$critical_file. Continue? [y/N]: " response
                if [[ ! "$response" =~ ^[Yy]$ ]]; then
                    echo "Operation cancelled to protect .claude directory"
                    rm -f "$claude_lockfile"
                    return 1
                fi
            fi
        fi
    done
    
    return 0
}

# Assess risk level for .claude operations
assess_claude_operation_risk() {
    local claude_dir=$1
    local operation=$2
    
    local risk_score=0
    local risk_factors=()
    
    echo "Assessing .claude operation risk..."
    
    # Factor 1: Operation type risk for .claude
    case "$operation" in
        "verify")
            risk_score=0
            ;;
        "format")
            risk_score=2
            risk_factors+=("Format operation on .claude files")
            ;;
        "cleanup")
            risk_score=6
            risk_factors+=("HIGH RISK: Cleanup operation on .claude directory")
            ;;
        "dedupe")
            risk_score=7
            risk_factors+=("CRITICAL RISK: Deduplication on .claude directory")
            ;;
        *)
            risk_score=5
            risk_factors+=("Unknown operation on .claude directory")
            ;;
    esac
    
    # Factor 2: .claude content complexity
    local claude_file_count=$(find "$claude_dir" -type f | wc -l)
    if [ "$claude_file_count" -gt 50 ]; then
        risk_score=$((risk_score + 2))
        risk_factors+=("Large .claude directory ($claude_file_count files)")
    elif [ "$claude_file_count" -gt 20 ]; then
        risk_score=$((risk_score + 1))
        risk_factors+=("Medium .claude directory ($claude_file_count files)")
    fi
    
    # Factor 3: Check for custom command files
    local custom_commands=$(find "$claude_dir/commands" -name "*.md" 2>/dev/null | wc -l)
    if [ "$custom_commands" -gt 10 ]; then
        risk_score=$((risk_score + 2))
        risk_factors+=("Many custom commands ($custom_commands)")
    fi
    
    # Factor 4: Check for settings modifications
    if [ -f "$claude_dir/settings.local.json" ]; then
        local settings_size=$(get_file_size "$claude_dir/settings.local.json")
        if [ "$settings_size" -gt 1024 ]; then
            risk_score=$((risk_score + 1))
            risk_factors+=("Complex settings configuration")
        fi
    fi
    
    # Factor 5: Check for template customizations
    if [ -d "$claude_dir/templates" ]; then
        local template_count=$(find "$claude_dir/templates" -name "*.md" 2>/dev/null | wc -l)
        if [ "$template_count" -gt 5 ]; then
            risk_score=$((risk_score + 1))
            risk_factors+=("Custom templates present ($template_count)")
        fi
    fi
    
    # Factor 6: Check for git integration
    if [ -d "$(dirname "$claude_dir")/.git" ]; then
        # Check if .claude is tracked in git
        if git -C "$(dirname "$claude_dir")" ls-files "$claude_dir" | head -1 | grep -q .; then
            risk_score=$((risk_score + 1))
            risk_factors+=(".claude directory is tracked in git")
        fi
    fi
    
    echo "Claude operation risk assessment: Score $risk_score"
    echo "Risk factors:"
    for factor in "${risk_factors[@]}"; do
        echo "  - $factor"
    done
    
    echo "$risk_score"
}

# Create .claude-specific safety snapshot
create_claude_safety_snapshot() {
    local claude_dir=$1
    local operation=$2
    
    local target_dir=$(dirname "$claude_dir")
    local snapshot_dir="$target_dir/.quality-snapshots"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local snapshot_name="claude_${operation}_${timestamp}"
    local snapshot_path="$snapshot_dir/$snapshot_name"
    
    mkdir -p "$snapshot_path"
    
    echo "Creating .claude safety snapshot: $snapshot_name"
    
    # Copy entire .claude directory
    cp -r "$claude_dir" "$snapshot_path/"
    
    # Save .claude-specific metadata
    cat > "$snapshot_path/claude_metadata.json" <<EOF
{
    "timestamp": "$timestamp",
    "operation": "$operation",
    "claude_dir": "$claude_dir",
    "file_count": $(find "$claude_dir" -type f | wc -l),
    "directory_size": $(du -sb "$claude_dir" | cut -f1),
    "git_commit": "$(git -C "$(dirname "$claude_dir")" rev-parse HEAD 2>/dev/null || echo "not-in-git")",
    "protection_level": "high",
    "snapshot_type": "claude_protection"
}
EOF
    
    echo "Claude safety snapshot created: $snapshot_path"
    echo "$snapshot_path"
}

# Pre-command hook to detect .claude access attempts
pre_command_claude_hook() {
    local target=${1:-.}
    local command=$2
    local args=("${@:3}")
    
    echo "Pre-command .claude protection hook activated"
    
    # Check if operation affects .claude directory
    local claude_dir="$target/.claude"
    if [ ! -d "$claude_dir" ]; then
        return 0
    fi
    
    # Detect if command will access .claude directory
    local affects_claude=false
    
    # Check if target directory contains .claude
    if [[ "$target" == *".claude"* ]] || [[ "$target" -ef "$(dirname "$claude_dir")" ]]; then
        affects_claude=true
    fi
    
    # Check command arguments for .claude references
    for arg in "${args[@]}"; do
        if [[ "$arg" == *".claude"* ]]; then
            affects_claude=true
            break
        fi
    done
    
    if $affects_claude; then
        echo "CLAUDE ACCESS DETECTED: Command '$command' will access .claude directory"
        
        # Perform enhanced validation for .claude access
        if ! validate_claude_command_safety "$command" "$target" "${args[@]}"; then
            echo "BLOCKED: Unsafe .claude access attempt"
            return 1
        fi
        
        # Create pre-operation snapshot for high-risk commands
        if is_high_risk_claude_command "$command"; then
            echo "High-risk .claude command detected, creating snapshot..."
            local pre_snapshot=$(create_claude_safety_snapshot "$claude_dir" "pre_${command}")
            export CLAUDE_PRE_SNAPSHOT="$pre_snapshot"
        fi
        
        # Set up .claude-specific monitoring
        setup_claude_command_monitoring "$claude_dir" "$command"
    fi
    
    return 0
}

# Validate command safety for .claude operations
validate_claude_command_safety() {
    local command=$1
    local target=$2
    shift 2
    local args=("$@")
    
    echo "Validating .claude command safety: $command"
    
    # Define dangerous command patterns for .claude
    local dangerous_patterns=(
        "rm.*\.claude"
        "mv.*\.claude.*trash"
        "find.*\.claude.*-delete"
        "sed.*-i.*\.claude"
        "awk.*\.claude.*>"
    )
    
    # Check for dangerous patterns
    local full_command="$command ${args[*]}"
    for pattern in "${dangerous_patterns[@]}"; do
        if [[ "$full_command" =~ $pattern ]]; then
            echo "DANGER: Detected dangerous pattern for .claude: $pattern"
            read -p "This command may damage .claude configuration. Proceed anyway? [y/N]: " response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                return 1
            fi
        fi
    done
    
    # Command-specific safety checks
    case "$command" in
        "cleanup"|"clean")
            echo "WARNING: Cleanup command detected for .claude directory"
            read -p "Cleanup may remove .claude files. Create backup first? [Y/n]: " response
            if [[ ! "$response" =~ ^[Nn]$ ]]; then
                local backup_path=$(create_claude_safety_snapshot "$target/.claude" "pre_cleanup")
                echo "Backup created: $backup_path"
            fi
            ;;
        "dedupe"|"dedup")
            echo "CRITICAL: Deduplication on .claude directory is extremely risky"
            read -p "Deduplication may break .claude configuration. Are you absolutely sure? [y/N]: " response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                return 1
            fi
            ;;
        "format"|"fmt")
            echo "INFO: Format command will modify .claude files"
            ;;
    esac
    
    return 0
}

# Check if command is high-risk for .claude
is_high_risk_claude_command() {
    local command=$1
    
    local high_risk_commands=(
        "cleanup"
        "clean"
        "dedupe"
        "dedup" 
        "rm"
        "mv"
        "delete"
        "remove"
    )
    
    for risk_cmd in "${high_risk_commands[@]}"; do
        if [[ "$command" == *"$risk_cmd"* ]]; then
            return 0
        fi
    done
    
    return 1
}

# Setup monitoring for .claude commands
setup_claude_command_monitoring() {
    local claude_dir=$1
    local command=$2
    
    echo "Setting up .claude command monitoring for: $command"
    
    # Create monitoring log
    local monitor_log="$claude_dir/.claude-monitor.log"
    cat > "$monitor_log" <<EOF
Claude Command Monitoring
========================
Command: $command
Started: $(date)
PID: $$
Monitoring Active: true

EOF
    
    # Set up file change monitoring if available
    if command -v inotifywait >/dev/null 2>&1; then
        # Linux - use inotify
        nohup inotifywait -m -r -e modify,create,delete "$claude_dir" --format '%T %e %w%f' --timefmt '%Y-%m-%d %H:%M:%S' >> "$monitor_log" 2>&1 &
        echo $! > "$claude_dir/.claude-monitor.pid"
    elif command -v fswatch >/dev/null 2>&1; then
        # macOS - use fswatch
        nohup fswatch -r "$claude_dir" | while read file; do
            echo "$(date '+%Y-%m-%d %H:%M:%S') MODIFY $file" >> "$monitor_log"
        done &
        echo $! > "$claude_dir/.claude-monitor.pid"
    else
        echo "No file monitoring available, using polling method"
        nohup bash -c "
            while [ -f '$monitor_log' ]; do
                find '$claude_dir' -newer '$monitor_log' -type f >> '$monitor_log.changes' 2>/dev/null
                sleep 2
            done
        " &
        echo $! > "$claude_dir/.claude-monitor.pid"
    fi
    
    echo "Claude monitoring active (PID: $(cat "$claude_dir/.claude-monitor.pid" 2>/dev/null))"
}

# User confirmation mechanisms for .claude changes
confirm_claude_operation() {
    local operation=$1
    local claude_dir=$2
    local affected_files=("${@:3}")
    
    echo "Claude Operation Confirmation Required"
    echo "======================================"
    echo "Operation: $operation"
    echo "Target: $claude_dir"
    echo "Affected files: ${#affected_files[@]}"
    
    if [ ${#affected_files[@]} -gt 0 ] && [ ${#affected_files[@]} -le 10 ]; then
        echo "Files to be affected:"
        for file in "${affected_files[@]}"; do
            echo "  - $(basename "$file")"
        done
    elif [ ${#affected_files[@]} -gt 10 ]; then
        echo "Files to be affected: (showing first 10)"
        for i in {0..9}; do
            if [ -n "${affected_files[$i]}" ]; then
                echo "  - $(basename "${affected_files[$i]}")"
            fi
        done
        echo "  ... and $((${#affected_files[@]} - 10)) more files"
    fi
    
    echo ""
    
    # Risk-based confirmation
    local risk_score=$(assess_claude_operation_risk "$claude_dir" "$operation")
    
    if [ "$risk_score" -ge 7 ]; then
        echo "⚠️  CRITICAL RISK OPERATION"
        echo "This operation has a high risk of damaging your .claude configuration."
        echo "Consider creating a backup before proceeding."
        echo ""
        read -p "Type 'YES' to confirm this critical operation: " response
        if [[ "$response" != "YES" ]]; then
            echo "Operation cancelled for safety"
            return 1
        fi
    elif [ "$risk_score" -ge 4 ]; then
        echo "⚠️  MEDIUM RISK OPERATION"
        echo "This operation may modify important .claude files."
        echo ""
        read -p "Do you want to proceed? [y/N]: " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Operation cancelled"
            return 1
        fi
    else
        echo "ℹ️  LOW RISK OPERATION"
        read -p "Proceed with .claude operation? [Y/n]: " response
        if [[ "$response" =~ ^[Nn]$ ]]; then
            echo "Operation cancelled"
            return 1
        fi
    fi
    
    return 0
}

# Rollback .claude directory to snapshot
rollback_claude_to_snapshot() {
    local snapshot_path=$1
    local claude_dir=${2:-".claude"}
    
    if [ ! -d "$snapshot_path" ]; then
        echo "ERROR: Claude snapshot not found: $snapshot_path"
        return 1
    fi
    
    if [ ! -f "$snapshot_path/claude_metadata.json" ]; then
        echo "ERROR: Invalid Claude snapshot (missing metadata): $snapshot_path"
        return 1
    fi
    
    echo "Rolling back .claude directory to snapshot: $(basename "$snapshot_path")"
    
    # Show snapshot metadata
    if command -v jq >/dev/null 2>&1; then
        echo "Snapshot information:"
        jq . "$snapshot_path/claude_metadata.json"
        echo ""
    fi
    
    # Confirm rollback
    read -p "This will overwrite current .claude directory. Continue? [y/N]: " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Claude rollback cancelled"
        return 1
    fi
    
    # Create backup of current .claude before rollback
    local current_backup=$(create_claude_safety_snapshot "$claude_dir" "pre-rollback")
    echo "Current .claude backed up to: $current_backup"
    
    # Remove current .claude directory
    if [ -d "$claude_dir" ]; then
        rm -rf "$claude_dir"
    fi
    
    # Restore from snapshot
    if [ -d "$snapshot_path/.claude" ]; then
        cp -r "$snapshot_path/.claude" "$(dirname "$claude_dir")/"
        echo "Claude directory restored from snapshot"
    else
        echo "ERROR: No .claude directory found in snapshot"
        return 1
    fi
    
    # Clean up monitoring
    cleanup_claude_monitoring "$claude_dir"
    
    echo "Claude rollback completed successfully"
    return 0
}

# Cleanup .claude monitoring processes
cleanup_claude_monitoring() {
    local claude_dir=$1
    
    local monitor_pid_file="$claude_dir/.claude-monitor.pid"
    local monitor_log="$claude_dir/.claude-monitor.log"
    
    if [ -f "$monitor_pid_file" ]; then
        local monitor_pid=$(cat "$monitor_pid_file")
        if [ -n "$monitor_pid" ] && kill -0 "$monitor_pid" 2>/dev/null; then
            echo "Stopping .claude monitoring process (PID: $monitor_pid)"
            kill "$monitor_pid" 2>/dev/null || true
        fi
        rm -f "$monitor_pid_file"
    fi
    
    # Archive monitoring log
    if [ -f "$monitor_log" ]; then
        local archive_name="claude-monitor-$(date +%Y%m%d_%H%M%S).log"
        mv "$monitor_log" "$claude_dir/$archive_name"
        echo "Monitoring log archived as: $archive_name"
    fi
}

# Enhanced .claude integrity verification
verify_claude_integrity() {
    local claude_dir=${1:-.claude}
    local verification_level=${2:-"standard"}
    
    echo "Verifying .claude directory integrity (level: $verification_level)..."
    
    local errors=0
    local warnings=0
    
    # Check 1: Essential structure
    if [ ! -d "$claude_dir" ]; then
        echo "ERROR: .claude directory not found"
        return 1
    fi
    
    # Check 2: Critical files
    local essential_files=(
        "commands"
        "settings.local.json"
    )
    
    for file in "${essential_files[@]}"; do
        local full_path="$claude_dir/$file"
        if [ ! -e "$full_path" ]; then
            echo "WARNING: Essential .claude file/directory missing: $file"
            warnings=$((warnings + 1))
        fi
    done
    
    # Check 3: Settings file validity
    if [ -f "$claude_dir/settings.local.json" ]; then
        if ! validate_claude_settings "$claude_dir/settings.local.json"; then
            echo "ERROR: Invalid .claude settings file"
            errors=$((errors + 1))
        fi
    fi
    
    # Check 4: Command files integrity
    if [ -d "$claude_dir/commands" ]; then
        local invalid_commands=$(check_claude_commands_integrity "$claude_dir/commands")
        if [ -n "$invalid_commands" ]; then
            echo "WARNING: Invalid command files detected:"
            echo "$invalid_commands" | sed 's/^/  /'
            warnings=$((warnings + 1))
        fi
    fi
    
    # Enhanced checks for comprehensive level
    if [[ "$verification_level" == "comprehensive" ]]; then
        # Check 5: Template integrity
        if [ -d "$claude_dir/templates" ]; then
            local template_issues=$(check_claude_templates_integrity "$claude_dir/templates")
            if [ -n "$template_issues" ]; then
                echo "WARNING: Template issues detected:"
                echo "$template_issues" | sed 's/^/  /'
                warnings=$((warnings + 1))
            fi
        fi
        
        # Check 6: File permissions
        local permission_issues=$(check_claude_permissions "$claude_dir")
        if [ -n "$permission_issues" ]; then
            echo "WARNING: Permission issues detected:"
            echo "$permission_issues" | sed 's/^/  /'
            warnings=$((warnings + 1))
        fi
    fi
    
    # Report results
    echo ".claude integrity verification complete:"
    echo "  Errors: $errors"
    echo "  Warnings: $warnings"
    
    if [ $errors -gt 0 ]; then
        echo "CRITICAL: .claude directory integrity compromised"
        return 1
    elif [ $warnings -gt 0 ]; then
        echo "WARNING: .claude directory has minor issues"
        return 2
    else
        echo "SUCCESS: .claude directory integrity verified"
        return 0
    fi
}

# Validate .claude settings file
validate_claude_settings() {
    local settings_file=$1
    
    if [ ! -f "$settings_file" ]; then
        return 1
    fi
    
    # Check JSON validity
    if ! jq empty "$settings_file" >/dev/null 2>&1; then
        echo "Invalid JSON in settings file"
        return 1
    fi
    
    # Check for required fields (basic validation)
    local required_fields=("version")
    for field in "${required_fields[@]}"; do
        if ! jq -e ".$field" "$settings_file" >/dev/null 2>&1; then
            echo "Missing required field in settings: $field"
            return 1
        fi
    done
    
    return 0
}

# Check .claude commands integrity
check_claude_commands_integrity() {
    local commands_dir=$1
    local issues=""
    
    if [ ! -d "$commands_dir" ]; then
        echo "Commands directory not found"
        return
    fi
    
    # Check all .md files in commands
    find "$commands_dir" -name "*.md" -type f | while read -r cmd_file; do
        # Basic markdown validation
        if [ ! -s "$cmd_file" ]; then
            issues="$issues\nEmpty command file: $(basename "$cmd_file")"
        fi
        
        # Check for basic command structure
        if ! grep -q "^#" "$cmd_file"; then
            issues="$issues\nMissing header in: $(basename "$cmd_file")"
        fi
    done
    
    echo -e "$issues"
}

# Setup .claude directory monitoring
setup_claude_monitoring() {
    local claude_dir=$1
    local operation=$2
    
    echo "Setting up comprehensive .claude monitoring..."
    
    # Create monitoring directory
    local monitor_dir="$claude_dir/.monitoring"
    mkdir -p "$monitor_dir"
    
    # Record monitoring start
    cat > "$monitor_dir/session.json" <<EOF
{
    "session_id": "$(date +%s)_$$",
    "operation": "$operation",
    "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "monitoring_active": true,
    "baseline_file_count": $(find "$claude_dir" -type f | wc -l),
    "baseline_dir_size": $(du -sb "$claude_dir" | cut -f1)
}
EOF
    
    # Set up cleanup trap
    trap "cleanup_claude_monitoring '$claude_dir'" EXIT
    
    echo "Claude monitoring session established"
}

# Generate .claude protection report
generate_claude_protection_report() {
    local claude_dir=${1:-.claude}
    local operation=${2:-"unknown"}
    local report_dir="$claude_dir/.reports"
    
    mkdir -p "$report_dir"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local report_file="$report_dir/protection_report_${operation}_${timestamp}.txt"
    
    cat > "$report_file" <<EOF
Claude Directory Protection Report
==================================
Generated: $(date)
Operation: $operation
Claude Directory: $claude_dir

Protection Status:
-----------------
Directory Exists: $([ -d "$claude_dir" ] && echo "✓ Yes" || echo "✗ No")
Lock File Present: $([ -f "$claude_dir/.claude-operation.lock" ] && echo "✓ Yes" || echo "✗ No")
Monitoring Active: $([ -f "$claude_dir/.monitoring/session.json" ] && echo "✓ Yes" || echo "✗ No")

File Inventory:
--------------
Total Files: $(find "$claude_dir" -type f 2>/dev/null | wc -l)
Command Files: $(find "$claude_dir/commands" -name "*.md" 2>/dev/null | wc -l)
Template Files: $(find "$claude_dir/templates" -name "*.md" 2>/dev/null | wc -l)
Settings Files: $(find "$claude_dir" -name "*.json" 2>/dev/null | wc -l)

Directory Size: $(du -sh "$claude_dir" 2>/dev/null | cut -f1)

Risk Assessment:
---------------
Current Risk Score: $(assess_claude_operation_risk "$claude_dir" "$operation")

Integrity Status:
----------------
$(verify_claude_integrity "$claude_dir" "standard" 2>&1 | tail -1)

Snapshots Available:
-------------------
$(ls -la "$(dirname "$claude_dir")/.quality-snapshots" 2>/dev/null | grep claude_ | wc -l) .claude snapshots available

Last Protection Activity:
------------------------
$(tail -5 "$claude_dir/.monitoring/session.json" 2>/dev/null || echo "No monitoring data available")
EOF
    
    echo "Claude protection report generated: $report_file"
    echo "$report_file"
}
```

These safety mechanisms provide comprehensive protection for quality operations with proper validation, backup creation, rollback capabilities, and risk assessment to ensure safe and reliable code quality improvements. The enhancements include advanced rollback mechanisms with selective restoration, enhanced configuration safety with validation, comprehensive integrity verification with detailed reporting and analysis, and specialized .claude directory protection hooks with pre-command validation, risk assessment, user confirmation mechanisms, and dedicated monitoring for .claude operations.