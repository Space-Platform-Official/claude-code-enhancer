---
description: Safety mechanisms and risk mitigation for code text quality operations
---

# Code Text Quality Safety Mechanisms

Comprehensive safety mechanisms to ensure secure and reliable execution of text quality operations with proper validation, rollback capabilities, and code functionality preservation.

## Pre-Operation Text Safety Checks

```bash
# Comprehensive text safety validation before any operation
run_text_safety_checks() {
    local operation=$1
    local target=${2:-.}
    local dry_run=${3:-false}
    
    echo "Running text safety checks for operation: $operation"
    
    # Check 1: Code functionality preservation
    if ! check_code_functionality_safety "$target"; then
        echo "ERROR: Code functionality safety check failed"
        return 1
    fi
    
    # Check 2: Text modification permissions
    if ! check_text_modification_permissions "$target"; then
        echo "ERROR: Text modification permission check failed"
        return 1
    fi
    
    # Check 3: Syntax preservation validation
    if ! check_syntax_preservation_safety "$target"; then
        echo "ERROR: Syntax preservation check failed"
        return 1
    fi
    
    # Check 4: Critical text content protection
    if ! check_critical_text_protection "$target"; then
        echo "ERROR: Critical text content at risk"
        return 1
    fi
    
    # Check 5: Concurrent text operations
    if ! check_concurrent_text_operations "$target"; then
        echo "ERROR: Concurrent text operations detected"
        return 1
    fi
    
    echo "All text safety checks passed"
    return 0
}

# Check code functionality safety for text modifications
check_code_functionality_safety() {
    local target=$1
    
    echo "Checking code functionality safety for text modifications..."
    
    # Check if we're in a git repository for rollback capability
    if git -C "$target" rev-parse --git-dir >/dev/null 2>&1; then
        # Check for uncommitted changes that could be lost
        if ! git -C "$target" diff --quiet; then
            echo "WARNING: Uncommitted changes detected"
            echo "Text modifications may interfere with pending changes"
            read -p "Continue with uncommitted changes? [y/N]: " response
            [[ "$response" =~ ^[Yy]$ ]] || return 1
        fi
        
        # Check for critical files with pending changes
        local critical_files=$(git -C "$target" diff --name-only | grep -E '\.(js|ts|py|go|rs|java|c|cpp|rb|php|cs|swift|kt)$')
        if [ -n "$critical_files" ]; then
            echo "WARNING: Critical source files have uncommitted changes:"
            echo "$critical_files"
            read -p "Text modifications may conflict with these changes. Continue? [y/N]: " response
            [[ "$response" =~ ^[Yy]$ ]] || return 1
        fi
    else
        echo "WARNING: Not in git repository - limited rollback options available"
        read -p "Continue without git rollback protection? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]] || return 1
    fi
    
    # Check for running development servers or processes
    local dev_processes=$(ps aux | grep -E "(webpack|vite|nodemon|pytest|go run|cargo run)" | grep -v grep)
    if [ -n "$dev_processes" ]; then
        echo "WARNING: Development processes are running"
        echo "Text modifications may cause reloads or compilation errors"
        echo "Running processes:"
        echo "$dev_processes" | sed 's/^/  /'
        read -p "Continue with running development processes? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]] || return 1
    fi
    
    return 0
}

# Check text modification permissions and access rights
check_text_modification_permissions() {
    local target=$1
    
    echo "Checking text modification permissions..."
    
    # Check if target directory is writable
    if [ ! -w "$target" ]; then
        echo "ERROR: Target directory is not writable: $target"
        return 1
    fi
    
    # Check for read-only files that contain text to modify
    local readonly_text_files=()
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            if [ ! -w "$file" ]; then
                readonly_text_files+=("$file")
            fi
        fi
    done
    
    if [ ${#readonly_text_files[@]} -gt 0 ]; then
        echo "WARNING: Read-only files with text content detected:"
        for file in "${readonly_text_files[@]}"; do
            echo "  $file"
        done
        read -p "Attempt to modify read-only text files? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]] || return 1
    fi
    
    # Check for locked files (if lsof is available)
    if command -v lsof >/dev/null 2>&1; then
        local locked_files=$(find_files_filtered "$target" "*" | while read -r file; do
            if is_source_file "$file" && lsof "$file" >/dev/null 2>&1; then
                echo "$file"
            fi
        done)
        
        if [ -n "$locked_files" ]; then
            echo "WARNING: Files currently in use detected:"
            echo "$locked_files"
            read -p "Files may be locked by other processes. Continue? [y/N]: " response
            [[ "$response" =~ ^[Yy]$ ]] || return 1
        fi
    fi
    
    return 0
}

# Check syntax preservation safety for text modifications
check_syntax_preservation_safety() {
    local target=$1
    
    echo "Checking syntax preservation safety..."
    
    # Pre-validate all source files to ensure they're currently valid
    local syntax_errors=0
    local total_files=0
    
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file"; then
            total_files=$((total_files + 1))
            if ! validate_syntax "$file"; then
                echo "WARNING: Pre-existing syntax error in: $file"
                syntax_errors=$((syntax_errors + 1))
            fi
        fi
    done
    
    if [ $syntax_errors -gt 0 ]; then
        echo "WARNING: $syntax_errors files have pre-existing syntax errors"
        echo "Text modifications may mask or complicate these issues"
        read -p "Continue with pre-existing syntax errors? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]] || return 1
    fi
    
    # Check for files with complex syntax that could be fragile
    local fragile_files=()
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file"; then
            local complexity=$(calculate_complexity "$file")
            if [ "$complexity" -gt 20 ]; then
                fragile_files+=("$file (complexity: $complexity)")
            fi
        fi
    done
    
    if [ ${#fragile_files[@]} -gt 0 ]; then
        echo "WARNING: High-complexity files detected (fragile syntax):"
        for file in "${fragile_files[@]}"; do
            echo "  $file"
        done
        read -p "Text modifications in complex files are riskier. Continue? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]] || return 1
    fi
    
    return 0
}

# Protect critical text content from unintended modification
check_critical_text_protection() {
    local target=$1
    
    echo "Checking critical text content protection..."
    
    # Define critical text patterns that should not be modified
    local critical_text_patterns=(
        "API_KEY.*="
        "SECRET.*="
        "PASSWORD.*="
        "TOKEN.*="
        "DATABASE_URL.*="
        "CONNECTION_STRING.*="
        "LICENSE.*"
        "COPYRIGHT.*"
        "TODO.*SECURITY"
        "FIXME.*CRITICAL"
        "XXX.*DANGER"
        "@deprecated"
        "@internal"
        "@private"
        "// DO NOT MODIFY"
        "# DO NOT CHANGE"
        "/* CRITICAL:"
    )
    
    local critical_matches=()
    for pattern in "${critical_text_patterns[@]}"; do
        local matches=$(find_files_filtered "$target" "*" | xargs grep -l "$pattern" 2>/dev/null)
        if [ -n "$matches" ]; then
            critical_matches+=("Pattern '$pattern' in: $matches")
        fi
    done
    
    if [ ${#critical_matches[@]} -gt 0 ]; then
        echo "WARNING: Critical text patterns detected:"
        for match in "${critical_matches[@]}"; do
            echo "  $match"
        done
        echo "These patterns should be protected from text modifications"
        read -p "Exclude files with critical patterns from text operations? [Y/n]: " response
        if [[ ! "$response" =~ ^[Nn]$ ]]; then
            export EXCLUDE_CRITICAL_TEXT=true
        fi
    fi
    
    # Check for API documentation and external interfaces
    local api_files=$(find_files_filtered "$target" "*" | grep -E "(api|interface|contract|schema)\.(js|ts|py|go|rs|java|md)$")
    if [ -n "$api_files" ]; then
        echo "WARNING: API/Interface files detected:"
        echo "$api_files"
        echo "Text changes to these files may break external contracts"
        read -p "Include API files in text modifications? [y/N]: " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            export EXCLUDE_API_FILES=true
        fi
    fi
    
    return 0
}

# Check for concurrent text operations
check_concurrent_text_operations() {
    local target=$1
    local lockfile="$target/.text-quality-lock"
    
    echo "Checking for concurrent text operations..."
    
    if [ -f "$lockfile" ]; then
        local lock_pid=$(cat "$lockfile" 2>/dev/null)
        if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
            echo "ERROR: Another text quality operation is running (PID: $lock_pid)"
            return 1
        else
            echo "Removing stale text quality lock file"
            rm -f "$lockfile"
        fi
    fi
    
    # Check for other tools that might be modifying text
    local competing_processes=$(ps aux | grep -E "(prettier|eslint|black|gofmt|rustfmt)" | grep -v grep)
    if [ -n "$competing_processes" ]; then
        echo "WARNING: Other formatting tools are running:"
        echo "$competing_processes" | sed 's/^/  /'
        read -p "Continue with other formatters running? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]] || return 1
    fi
    
    # Create text quality lock file
    echo $$ > "$lockfile"
    return 0
}
```

## Text Operation Validation

```bash
# Validate text operation safety based on scope and impact
validate_text_operation_safety() {
    local operation=$1
    local files=("${@:2}")
    local risk_score=0
    
    echo "Validating text operation safety: $operation"
    
    # Calculate risk score based on operation type
    case "$operation" in
        "scan")
            risk_score=0  # No risk - read-only operation
            ;;
        "proofread")
            risk_score=2  # Low risk - controlled modifications
            ;;
        "review")
            risk_score=1  # Very low risk - user-guided changes
            ;;
        "polish")
            risk_score=4  # Medium-high risk - comprehensive changes
            ;;
        *)
            risk_score=5  # High risk for unknown operations
            ;;
    esac
    
    # Increase risk based on file count and types
    local file_count=${#files[@]}
    if [ "$file_count" -gt 100 ]; then
        risk_score=$((risk_score + 3))
    elif [ "$file_count" -gt 50 ]; then
        risk_score=$((risk_score + 2))
    elif [ "$file_count" -gt 20 ]; then
        risk_score=$((risk_score + 1))
    fi
    
    # Check for high-importance files
    local critical_files=0
    local api_files=0
    local config_files=0
    
    for file in "${files[@]}"; do
        if [[ "$file" =~ (main|index|app|server|core)\.(js|ts|py|go|rs)$ ]]; then
            critical_files=$((critical_files + 1))
        elif [[ "$file" =~ (api|interface|contract|schema)\.(js|ts|py|go|rs|md)$ ]]; then
            api_files=$((api_files + 1))
        elif [[ "$file" =~ (config|settings|env)\.(js|ts|py|go|rs|json|yaml|toml)$ ]]; then
            config_files=$((config_files + 1))
        fi
    done
    
    if [ $critical_files -gt 0 ]; then
        risk_score=$((risk_score + 2))
    fi
    if [ $api_files -gt 0 ]; then
        risk_score=$((risk_score + 3))
    fi
    if [ $config_files -gt 0 ]; then
        risk_score=$((risk_score + 1))
    fi
    
    # Determine if operation requires confirmation
    if [ "$risk_score" -ge 6 ]; then
        echo "HIGH RISK text operation detected (score: $risk_score)"
        echo "Files to be modified: $file_count"
        echo "Critical files: $critical_files, API files: $api_files, Config files: $config_files"
        echo "Operation: $operation"
        read -p "Are you sure you want to continue? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]] || return 1
    elif [ "$risk_score" -ge 3 ]; then
        echo "MEDIUM RISK text operation (score: $risk_score)"
        echo "Files to be modified: $file_count"
        read -p "Continue? [Y/n]: " response
        [[ ! "$response" =~ ^[Nn]$ ]] || return 1
    fi
    
    return 0
}

# Validate text file safety before modification
validate_text_file_safety() {
    local file=$1
    local operation=$2
    local modification_type=${3:-"mixed"}
    
    echo "Validating text file safety: $file"
    
    # Check if file exists and is readable
    if [ ! -f "$file" ]; then
        echo "ERROR: File does not exist: $file"
        return 1
    fi
    
    if [ ! -r "$file" ]; then
        echo "ERROR: File is not readable: $file"
        return 1
    fi
    
    # Check file size limits for text operations
    local file_size=$(get_file_size "$file")
    local max_size=$((5 * 1024 * 1024))  # 5MB limit for text operations
    
    if [ "$file_size" -gt "$max_size" ]; then
        echo "WARNING: Large file detected for text modification: $file ($(format_file_size $file_size))"
        read -p "Process large file for text modifications? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]] || return 1
    fi
    
    # Check if file is binary
    if is_binary_file "$file"; then
        echo "WARNING: Binary file detected: $file"
        echo "Text operations should not be performed on binary files"
        return 1
    fi
    
    # Validate current syntax before text modification
    if [[ "$operation" != "scan" ]]; then
        if ! validate_syntax "$file"; then
            echo "ERROR: Syntax validation failed for: $file"
            echo "Text modifications may worsen syntax issues"
            read -p "Attempt text modifications despite syntax errors? [y/N]: " response
            [[ "$response" =~ ^[Yy]$ ]] || return 1
        fi
    fi
    
    # Check modification type safety
    case "$modification_type" in
        "comments_only")
            echo "INFO: Safe modification type - comments only"
            ;;
        "strings_only")
            echo "WARNING: String modifications may affect functionality"
            ;;
        "identifiers")
            echo "DANGER: Identifier modifications will affect code functionality"
            read -p "Continue with identifier modifications? [y/N]: " response
            [[ "$response" =~ ^[Yy]$ ]] || return 1
            ;;
        "mixed")
            echo "CAUTION: Mixed modifications require careful validation"
            ;;
    esac
    
    return 0
}

# Create comprehensive text safety snapshot
create_text_safety_snapshot() {
    local target=${1:-.}
    local operation=$2
    
    local snapshot_dir="$target/.text-quality-snapshots"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local snapshot_name="text_${operation}_${timestamp}"
    local snapshot_path="$snapshot_dir/$snapshot_name"
    
    mkdir -p "$snapshot_path"
    
    echo "Creating text safety snapshot: $snapshot_name"
    
    # Find all text-containing files
    local text_files=$(find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            echo "$file"
        fi
    done)
    
    # Copy files to snapshot with text extraction metadata
    local files_count=0
    echo "$text_files" | while IFS= read -r file; do
        if [ -f "$file" ]; then
            local rel_path=${file#$target/}
            local dest_dir="$snapshot_path/$(dirname "$rel_path")"
            mkdir -p "$dest_dir"
            cp "$file" "$snapshot_path/$rel_path"
            
            # Extract text content for comparison
            local text_extract_file="$snapshot_path/$rel_path.text-extract"
            extract_text_from_source "$file" > "$text_extract_file"
            
            files_count=$((files_count + 1))
        fi
    done
    
    # Save text-specific metadata
    cat > "$snapshot_path/text_metadata.json" <<EOF
{
    "timestamp": "$timestamp",
    "operation": "$operation",
    "target": "$target",
    "snapshot_type": "text_safety",
    "files_count": $files_count,
    "text_extraction_included": true,
    "git_commit": "$(git -C "$target" rev-parse HEAD 2>/dev/null || echo "not-in-git")",
    "git_branch": "$(git -C "$target" branch --show-current 2>/dev/null || echo "not-in-git")",
    "syntax_validation": "pre_operation"
}
EOF
    
    echo "Text safety snapshot created: $snapshot_path"
    echo "Files preserved: $files_count"
    echo "$snapshot_path"
}
```

## Text-Specific Rollback Mechanisms

```bash
# Rollback to text safety snapshot with validation
rollback_to_text_snapshot() {
    local snapshot_path=$1
    local target=${2:-.}
    local validation_level=${3:-"full"}
    
    echo "Rolling back to text safety snapshot: $(basename "$snapshot_path")"
    
    if [ ! -d "$snapshot_path" ]; then
        echo "ERROR: Text snapshot not found: $snapshot_path"
        return 1
    fi
    
    if [ ! -f "$snapshot_path/text_metadata.json" ]; then
        echo "ERROR: Invalid text snapshot (missing metadata): $snapshot_path"
        return 1
    fi
    
    # Show snapshot information
    if command -v jq >/dev/null 2>&1; then
        echo "Snapshot information:"
        jq . "$snapshot_path/text_metadata.json"
        echo ""
    fi
    
    # Confirm rollback
    read -p "This will overwrite current text modifications. Continue? [y/N]: " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Text rollback cancelled"
        return 1
    fi
    
    # Create backup of current state before rollback
    local rollback_backup=$(create_text_safety_snapshot "$target" "pre-rollback")
    echo "Current state backed up to: $rollback_backup"
    
    # Restore files from snapshot with validation
    local files_restored=0
    local validation_errors=0
    
    while IFS= read -r snapshot_file; do
        local rel_path=${snapshot_file#$snapshot_path/}
        local dest_file="$target/$rel_path"
        
        # Skip metadata and text extraction files
        if [[ "$rel_path" == "text_metadata.json" ]] || [[ "$rel_path" == *.text-extract ]]; then
            continue
        fi
        
        if [ -f "$snapshot_file" ]; then
            mkdir -p "$(dirname "$dest_file")"
            cp "$snapshot_file" "$dest_file"
            
            # Validate restored file if required
            if [[ "$validation_level" == "full" ]] && is_source_file "$dest_file"; then
                if ! validate_syntax "$dest_file"; then
                    echo "WARNING: Validation failed for restored file: $dest_file"
                    validation_errors=$((validation_errors + 1))
                fi
            fi
            
            files_restored=$((files_restored + 1))
        fi
    done < <(find "$snapshot_path" -type f)
    
    # Report rollback results
    echo "Text rollback completed:"
    echo "  Files restored: $files_restored"
    echo "  Validation errors: $validation_errors"
    
    if [ $validation_errors -gt 0 ]; then
        echo "WARNING: Some restored files have validation issues"
        echo "Manual review may be required"
        return 2
    fi
    
    return 0
}

# Selective text rollback for specific file types or patterns
selective_text_rollback() {
    local snapshot_path=$1
    local target=${2:-.}
    local file_patterns=("${@:3}")
    
    echo "Performing selective text rollback..."
    
    if [ ! -d "$snapshot_path" ]; then
        echo "ERROR: Text snapshot not found: $snapshot_path"
        return 1
    fi
    
    local files_restored=0
    local files_skipped=0
    
    if [ ${#file_patterns[@]} -eq 0 ]; then
        # Default to common text patterns
        file_patterns=("*.md" "*.txt" "*.rst" "*.adoc")
    fi
    
    for pattern in "${file_patterns[@]}"; do
        while IFS= read -r snapshot_file; do
            local rel_path=${snapshot_file#$snapshot_path/}
            local dest_file="$target/$rel_path"
            
            if [[ "$rel_path" == "text_metadata.json" ]] || [[ "$rel_path" == *.text-extract ]]; then
                continue
            fi
            
            if [ -f "$snapshot_file" ]; then
                # Check if file should be restored based on text content changes
                if should_restore_text_file "$snapshot_file" "$dest_file"; then
                    mkdir -p "$(dirname "$dest_file")"
                    
                    # Create backup of current version
                    if [ -f "$dest_file" ]; then
                        local backup_file="$dest_file.pre-text-rollback.$(date +%s)"
                        cp "$dest_file" "$backup_file"
                        echo "Current version backed up: $backup_file"
                    fi
                    
                    cp "$snapshot_file" "$dest_file"
                    echo "Restored text in: $rel_path"
                    files_restored=$((files_restored + 1))
                else
                    echo "Skipped: $rel_path (no significant text changes)"
                    files_skipped=$((files_skipped + 1))
                fi
            fi
        done < <(find "$snapshot_path" -name "$pattern" -type f)
    done
    
    echo "Selective text rollback completed:"
    echo "  Files restored: $files_restored"
    echo "  Files skipped: $files_skipped"
    
    return 0
}

# Check if text file should be restored during rollback
should_restore_text_file() {
    local snapshot_file=$1
    local current_file=$2
    
    if [ ! -f "$current_file" ]; then
        # File doesn't exist, safe to restore
        return 0
    fi
    
    # Compare text content rather than just modification times
    local snapshot_extract="${snapshot_file}.text-extract"
    local current_extract="/tmp/current-text-extract-$$"
    
    if [ -f "$snapshot_extract" ]; then
        # Extract current text and compare
        extract_text_from_source "$current_file" > "$current_extract"
        
        # Compare extracted text content
        if diff -q "$snapshot_extract" "$current_extract" >/dev/null 2>&1; then
            rm -f "$current_extract"
            return 1  # Text content is the same, no need to restore
        fi
        
        rm -f "$current_extract"
        
        # Text content differs, ask user
        echo "WARNING: Text content has changed since snapshot"
        echo "File: $(basename "$current_file")"
        read -p "Restore original text content? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]]
    else
        # No text extract available, fall back to timestamp comparison
        local snapshot_mtime=$(stat -f%m "$snapshot_file" 2>/dev/null || stat -c%Y "$snapshot_file" 2>/dev/null)
        local current_mtime=$(stat -f%m "$current_file" 2>/dev/null || stat -c%Y "$current_file" 2>/dev/null)
        
        if [ "$current_mtime" -gt "$snapshot_mtime" ]; then
            echo "WARNING: Current file is newer than snapshot"
            read -p "Restore anyway? [y/N]: " response
            [[ "$response" =~ ^[Yy]$ ]]
        else
            return 0
        fi
    fi
}
```

## Text Integrity Verification

```bash
# Verify text operation integrity with syntax validation
verify_text_operation_integrity() {
    local target=${1:-.}
    local operation=$2
    local pre_snapshot=$3
    local validation_level=${4:-"standard"}
    
    echo "Verifying text operation integrity..."
    echo "Validation level: $validation_level"
    
    local errors=0
    local warnings=0
    local text_issues=0
    
    # Level 1: Basic integrity checks
    echo "Level 1: File existence and accessibility checks"
    if [ -n "$pre_snapshot" ] && [ -d "$pre_snapshot" ]; then
        while IFS= read -r snapshot_file; do
            local rel_path=${snapshot_file#$pre_snapshot/}
            local current_file="$target/$rel_path"
            
            if [[ "$rel_path" != "text_metadata.json" ]] && [[ "$rel_path" != *.text-extract ]] && [ ! -f "$current_file" ]; then
                echo "ERROR: File deleted during text operation: $current_file"
                errors=$((errors + 1))
            fi
        done < <(find "$pre_snapshot" -type f)
    fi
    
    # Level 2: Syntax preservation validation
    echo "Level 2: Syntax preservation validation"
    local syntax_errors=0
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file"; then
            if ! validate_syntax "$file"; then
                echo "ERROR: Syntax error introduced in: $file"
                syntax_errors=$((syntax_errors + 1))
                errors=$((errors + 1))
            fi
        fi
    done
    
    # Level 3: Text quality validation
    echo "Level 3: Text quality validation"
    if [[ "$validation_level" != "basic" ]]; then
        local text_quality_issues=$(validate_text_quality_integrity "$target" "$operation")
        if [ -n "$text_quality_issues" ]; then
            echo "WARNING: Text quality issues detected:"
            echo "$text_quality_issues" | sed 's/^/  /'
            warnings=$((warnings + 1))
        fi
    fi
    
    # Level 4: Functional integrity checks
    if [[ "$validation_level" == "comprehensive" ]]; then
        echo "Level 4: Functional integrity validation"
        local functional_issues=$(validate_functional_integrity "$target")
        if [ -n "$functional_issues" ]; then
            echo "WARNING: Potential functional issues detected:"
            echo "$functional_issues" | sed 's/^/  /'
            warnings=$((warnings + 1))
        fi
    fi
    
    # Report results
    echo ""
    echo "Text operation integrity verification complete:"
    echo "  Critical errors: $errors"
    echo "  Warnings: $warnings"
    echo "  Text issues: $text_issues"
    
    if [ $errors -gt 0 ]; then
        echo "CRITICAL: Text operation integrity compromised"
        echo "Rollback recommended"
        return 1
    elif [ $warnings -gt 2 ]; then
        echo "WARNING: Multiple integrity issues detected"
        echo "Manual review recommended"
        return 2
    else
        echo "SUCCESS: Text operation integrity verified"
        return 0
    fi
}

# Validate text quality integrity after operations
validate_text_quality_integrity() {
    local target=$1
    local operation=$2
    local issues=""
    
    # Check for introduced grammar/spelling issues
    local grammar_issues=0
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            local text_file=$(extract_text_from_source "$file")
            local quality_result=$(check_text_quality "$(cat "$text_file")")
            local issue_count="${quality_result##*:}"
            
            if [ "$issue_count" -gt 0 ]; then
                grammar_issues=$((grammar_issues + issue_count))
                issues="$issues\nText quality issues in $file: $issue_count"
            fi
            
            rm -f "$text_file"
        fi
    done
    
    # Check for consistency issues
    local consistency_file=$(check_terminology_consistency "$target")
    if [ -f "$consistency_file" ] && [ -s "$consistency_file" ]; then
        local consistency_issues=$(wc -l < "$consistency_file")
        if [ "$consistency_issues" -gt 0 ]; then
            issues="$issues\nTerminology inconsistencies detected: $consistency_issues"
        fi
        rm -f "$consistency_file"
    fi
    
    # Check for readability regressions
    local readability_warnings=0
    find_files_filtered "$target" "*" | while read -r file; do
        if [ "$(detect_text_content_type "$file")" = "documentation" ]; then
            local text_content=$(cat "$file")
            local readability=$(calculate_readability "$text_content")
            local ease_score=$(echo "$readability" | grep -o 'ease:[0-9.]*' | cut -d: -f2)
            
            if [ -n "$ease_score" ] && [ "$(echo "$ease_score < 30" | bc 2>/dev/null || echo "0")" = "1" ]; then
                readability_warnings=$((readability_warnings + 1))
                issues="$issues\nPoor readability in $file: $ease_score"
            fi
        fi
    done
    
    echo -e "$issues"
}

# Validate functional integrity after text modifications
validate_functional_integrity() {
    local target=$1
    local issues=""
    
    # Check for broken imports/references due to text changes
    local import_issues=0
    find_files_filtered "$target" "*" | while read -r file; do
        if is_source_file "$file"; then
            local broken_imports=$(check_file_imports "$file")
            if [ -n "$broken_imports" ]; then
                import_issues=$((import_issues + 1))
                issues="$issues\nBroken imports in $file"
            fi
        fi
    done
    
    # Check for missing documentation for public APIs
    local doc_issues=0
    find_files_filtered "$target" "*" | while read -r file; do
        if [[ "$file" =~ (api|interface|public)\.(js|ts|py|go|rs|java)$ ]]; then
            # Simple check for missing documentation
            if ! grep -q -E "(\/\*\*|\"\"\"|\#\#\#)" "$file"; then
                doc_issues=$((doc_issues + 1))
                issues="$issues\nPossible missing documentation in API file: $file"
            fi
        fi
    done
    
    # Check for test description consistency
    local test_issues=0
    find_files_filtered "$target" "*" | while read -r file; do
        if [[ "$file" =~ (test|spec)\.(js|ts|py|go|rs|java)$ ]]; then
            # Check for tests without descriptions
            local test_functions=$(grep -c -E "(test_|it\(|describe\(|Test)" "$file" 2>/dev/null || echo "0")
            local test_descriptions=$(grep -c -E "(\".*\"|'.*')" "$file" 2>/dev/null || echo "0")
            
            if [ "$test_functions" -gt 0 ] && [ "$test_descriptions" -lt "$test_functions" ]; then
                test_issues=$((test_issues + 1))
                issues="$issues\nTest descriptions may be missing in $file"
            fi
        fi
    done
    
    echo -e "$issues"
}
```

## Emergency Text Recovery

```bash
# Emergency text recovery system
emergency_text_recovery() {
    local target=${1:-.}
    local reason=${2:-"User requested"}
    local recovery_mode=${3:-"full"}
    
    echo "EMERGENCY TEXT RECOVERY: $reason"
    echo "Recovery mode: $recovery_mode"
    
    # Stop all text operations immediately
    pkill -f "text-quality-" 2>/dev/null || true
    
    # Remove text operation locks
    rm -f "$target/.text-quality-lock"
    
    # Find the most recent text snapshot
    local snapshot_dir="$target/.text-quality-snapshots"
    local latest_snapshot=""
    
    if [ -d "$snapshot_dir" ]; then
        latest_snapshot=$(ls -t "$snapshot_dir" | head -1)
        if [ -n "$latest_snapshot" ]; then
            echo "Latest text snapshot found: $latest_snapshot"
            
            case "$recovery_mode" in
                "full")
                    echo "Performing full text recovery..."
                    rollback_to_text_snapshot "$snapshot_dir/$latest_snapshot" "$target" "basic"
                    ;;
                "selective")
                    echo "Performing selective text recovery..."
                    selective_text_rollback "$snapshot_dir/$latest_snapshot" "$target" "*.md" "*.txt" "*.rst"
                    ;;
                "validate")
                    echo "Validating current state against snapshot..."
                    compare_text_state "$target" "$snapshot_dir/$latest_snapshot"
                    ;;
            esac
        else
            echo "No text snapshots available for recovery"
        fi
    fi
    
    # Create emergency recovery log
    cat > "$target/.text-emergency-recovery.log" <<EOF
Emergency Text Recovery: $(date)
Reason: $reason
Recovery Mode: $recovery_mode
Latest Snapshot: $latest_snapshot
PID: $$
Working Directory: $(pwd)
Target: $target
Git Status: $(git -C "$target" status --porcelain 2>/dev/null | wc -l) modified files
EOF
    
    echo "Emergency text recovery completed"
    echo "Recovery log: $target/.text-emergency-recovery.log"
}

# Compare current text state with snapshot
compare_text_state() {
    local target=$1
    local snapshot_path=$2
    
    echo "Comparing current text state with snapshot..."
    
    local differences=0
    local snapshot_files=$(find "$snapshot_path" -name "*.text-extract" -type f)
    
    echo "$snapshot_files" | while IFS= read -r extract_file; do
        local rel_path=${extract_file#$snapshot_path/}
        rel_path=${rel_path%.text-extract}
        local current_file="$target/$rel_path"
        
        if [ -f "$current_file" ]; then
            local current_extract="/tmp/current-compare-$$"
            extract_text_from_source "$current_file" > "$current_extract"
            
            if ! diff -q "$extract_file" "$current_extract" >/dev/null 2>&1; then
                echo "TEXT DIFFERENCE: $rel_path"
                differences=$((differences + 1))
                
                # Show brief diff if requested
                if [[ "$SHOW_TEXT_DIFF" == "true" ]]; then
                    echo "  Changes:"
                    diff "$extract_file" "$current_extract" | head -10 | sed 's/^/    /'
                fi
            fi
            
            rm -f "$current_extract"
        else
            echo "FILE MISSING: $rel_path"
            differences=$((differences + 1))
        fi
    done
    
    echo "Text comparison completed: $differences differences found"
    return $differences
}

# Set up emergency text recovery handlers
setup_text_emergency_handlers() {
    local target=${1:-.}
    
    trap "emergency_text_recovery '$target' 'SIGINT received' 'validate'" INT
    trap "emergency_text_recovery '$target' 'SIGTERM received' 'selective'" TERM
    trap "cleanup_text_operations '$target'" EXIT
}

# Cleanup text operations on exit
cleanup_text_operations() {
    local target=${1:-.}
    local exit_code=$?
    
    echo "Cleaning up text operations..."
    
    # Remove lock files
    rm -f "$target/.text-quality-lock"
    
    # Clean up temporary text files
    rm -f /tmp/text-* /tmp/*-text-extract-* 2>/dev/null || true
    
    # Archive operation logs
    if [ -f "$target/.text-operation.log" ]; then
        local archive_name="text-operation-$(date +%Y%m%d_%H%M%S).log"
        mv "$target/.text-operation.log" "$target/$archive_name"
    fi
    
    if [ "$exit_code" -ne 0 ]; then
        echo "Text operation exited with errors (code: $exit_code)"
        
        # Create error log
        cat > "$target/.text-operation-error.log" <<EOF
Text Operation Failed: $(date)
Exit Code: $exit_code
PID: $$
Working Directory: $(pwd)
Target: $target
Last Operation: ${LAST_TEXT_OPERATION:-"unknown"}
EOF
    fi
    
    exit $exit_code
}
```

## Text Quality Monitoring

```bash
# Real-time text quality monitoring during operations
monitor_text_quality() {
    local target=${1:-.}
    local operation=$2
    local monitor_interval=${3:-5}
    
    echo "Starting text quality monitoring..."
    
    local monitor_file="$target/.text-quality-monitor"
    cat > "$monitor_file" <<EOF
Text Quality Monitoring Session
===============================
Started: $(date)
Operation: $operation
Target: $target
PID: $$
Monitoring Interval: ${monitor_interval}s

EOF
    
    # Monitor in background
    (
        while [ -f "$monitor_file" ]; do
            local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            
            # Count current text issues
            local total_issues=0
            find_files_filtered "$target" "*" | while read -r file; do
                if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
                    local text_file=$(extract_text_from_source "$file")
                    local quality_result=$(check_text_quality "$(cat "$text_file")")
                    local issue_count="${quality_result##*:}"
                    total_issues=$((total_issues + issue_count))
                    rm -f "$text_file"
                fi
            done
            
            # Log current status
            echo "[$timestamp] Text issues: $total_issues" >> "$monitor_file"
            
            # Check for critical thresholds
            if [ "$total_issues" -gt 100 ]; then
                echo "[$timestamp] WARNING: High issue count detected ($total_issues)" >> "$monitor_file"
            fi
            
            sleep "$monitor_interval"
        done
    ) &
    
    local monitor_pid=$!
    echo "$monitor_pid" > "$target/.text-monitor.pid"
    echo "Text quality monitoring active (PID: $monitor_pid)"
}

# Stop text quality monitoring
stop_text_quality_monitoring() {
    local target=${1:-.}
    
    local monitor_file="$target/.text-quality-monitor"
    local pid_file="$target/.text-monitor.pid"
    
    if [ -f "$pid_file" ]; then
        local monitor_pid=$(cat "$pid_file")
        if [ -n "$monitor_pid" ] && kill -0 "$monitor_pid" 2>/dev/null; then
            echo "Stopping text quality monitoring (PID: $monitor_pid)"
            kill "$monitor_pid" 2>/dev/null || true
        fi
        rm -f "$pid_file"
    fi
    
    if [ -f "$monitor_file" ]; then
        echo "Text quality monitoring stopped: $(date)" >> "$monitor_file"
        local archive_name="text-monitor-$(date +%Y%m%d_%H%M%S).log"
        mv "$monitor_file" "$target/$archive_name"
        echo "Monitor log archived as: $archive_name"
    fi
}
```

These text safety mechanisms provide comprehensive protection for text quality operations, ensuring that text modifications preserve code functionality while improving text quality through proper validation, backup creation, rollback capabilities, and integrity verification specifically designed for text operations in code projects.