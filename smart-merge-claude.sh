#!/bin/bash

# Simple smart merge script for CLAUDE.md files and Claude commands setup
# Usage: ./smart-merge-claude.sh <target-directory>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Lock file for preventing concurrent execution
LOCK_FILE="/tmp/claude_merge.lock"

# Cleanup function
cleanup() {
    local exit_code=$?
    if [[ -f "$LOCK_FILE" ]]; then
        rm -f "$LOCK_FILE"
    fi
    exit $exit_code
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Function to find templates directory
find_templates_dir() {
    local candidates=(
        "$CLAUDE_TEMPLATES_DIR"
        "$HOME/.local/share/claude-flow/templates"
        "/usr/local/share/claude-flow/templates"
        "$SCRIPT_DIR/templates"
    )
    
    for dir in "${candidates[@]}"; do
        if [[ -n "$dir" && -d "$dir" && -f "$dir/CLAUDE.md" ]]; then
            echo "$dir"
            return 0
        fi
    done
    
    return 1
}

# Find templates directory
if ! TEMPLATES_DIR="$(find_templates_dir)"; then
    echo -e "${RED}[ERROR]${NC} No valid templates directory found."
    exit 1
fi

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if another instance is running
check_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            print_error "Another merge operation is already running (PID: $pid)"
            exit 1
        else
            rm -f "$LOCK_FILE"
        fi
    fi
    
    # Create lock file with current PID
    echo $$ > "$LOCK_FILE"
}

# Function to create simple backup
create_backup() {
    local target_path="$1"
    
    # Check if backups are disabled
    if [[ "${CLAUDE_MERGE_BACKUP:-true}" == "false" ]]; then
        return 0
    fi
    
    if [[ -e "$target_path" ]]; then
        local backup_path="${target_path}.backup.$(date +%s)"
        cp -r "$target_path" "$backup_path"
        echo "$backup_path"
    fi
}

# Function to clean up old backup files
cleanup_old_backups() {
    local target_dir="$1"
    local retention_hours="${CLAUDE_MERGE_BACKUP_RETENTION:-24}"
    local cleaned_count=0
    
    # Find and clean old backup files (with memory limits)
    find "$target_dir" -maxdepth 3 -name "*.backup.*" -print0 2>/dev/null | head -c 1048576 | while IFS= read -r -d '' backup_file; do
        if [[ -e "$backup_file" ]]; then
            # Extract timestamp from backup filename
            local timestamp=$(echo "$backup_file" | sed 's/.*\.backup\.//')
            if [[ "$timestamp" =~ ^[0-9]+$ ]]; then
                local current_time=$(date +%s)
                local age_hours=$(( (current_time - timestamp) / 3600 ))
                
                if [[ $age_hours -gt $retention_hours ]]; then
                    rm -rf "$backup_file"
                    ((cleaned_count++))
                    print_status "Cleaned old backup: $(basename "$backup_file")"
                fi
            fi
        fi
    done
    
    if [[ $cleaned_count -gt 0 ]]; then
        print_status "Cleaned $cleaned_count old backup files (older than ${retention_hours}h)"
    fi
}

# Function to clean up old merge-specific backups (keep last 5)
cleanup_old_merge_backups() {
    local target_dir="$1"
    local max_backups=5
    local cleaned_count=0
    
    # Find CLAUDE.md backup files, sorted by timestamp (newest first) with memory limits
    local backup_files=()
    find "$target_dir" -maxdepth 2 -name "CLAUDE.md.backup.*" -print0 2>/dev/null | head -c 65536 | while IFS= read -r -d '' backup_file; do
        if [[ -f "$backup_file" && "$(basename "$backup_file")" =~ ^CLAUDE\.md\.backup\.[0-9]+$ ]]; then
            backup_files+=("$backup_file")
        fi
    done
    
    # Sort by timestamp (newest first)
    if [[ ${#backup_files[@]} -gt 0 ]]; then
        IFS=$'\n' backup_files=($(printf '%s\n' "${backup_files[@]}" | sort -t. -k4 -nr))
        
        # Keep only the newest ones, remove the rest
        if [[ ${#backup_files[@]} -gt $max_backups ]]; then
            for ((i=$max_backups; i<${#backup_files[@]}; i++)); do
                rm -f "${backup_files[$i]}"
                ((cleaned_count++))
                print_status "Cleaned old merge backup: $(basename "${backup_files[$i]}")"
            done
        fi
    fi
    
    if [[ $cleaned_count -gt 0 ]]; then
        print_status "Cleaned $cleaned_count old merge backup files (keeping last $max_backups)"
    fi
}

# Function to detect if source contains merged content (recursive merge detection)
detect_recursive_merge() {
    local source_file="$1"
    local marker="# ========== CLAUDE FLOW TEMPLATE =========="
    
    if [[ ! -f "$source_file" ]]; then
        return 1
    fi
    
    # Check if source file contains merge markers
    if grep -q "$marker" "$source_file"; then
        return 0  # Recursive merge detected
    fi
    
    return 1  # No recursive merge
}

# Function to generate content fingerprint for deduplication
generate_content_fingerprint() {
    local file="$1"
    local marker="# ========== CLAUDE FLOW TEMPLATE =========="
    
    if [[ ! -f "$file" ]]; then
        echo ""
        return
    fi
    
    # Extract template section content only (after marker)
    local content=$(awk -v marker="$marker" '
        BEGIN { found_marker = 0 }
        $0 ~ marker { found_marker = 1; next }
        found_marker == 1 { print }
    ' "$file" | grep -v "^# Auto-updated:" | grep -v "^$")
    
    if [[ -n "$content" ]]; then
        echo "$content" | sha256sum | cut -d' ' -f1
    else
        echo ""
    fi
}

# Function to validate marker integrity
validate_marker_integrity() {
    local file="$1"
    local marker="# ========== CLAUDE FLOW TEMPLATE =========="
    
    if [[ ! -f "$file" ]]; then
        return 0  # No file to validate
    fi
    
    # Count complete markers
    local marker_count=$(grep -c "^${marker}$" "$file")
    
    # Count partial markers (corrupted)
    local partial_count=$(grep -c "# ========== CLAUDE FLOW" "$file")
    
    # Check for corrupted markers
    if [[ $partial_count -gt $marker_count ]]; then
        print_error "Corrupted markers detected in $file"
        return 1
    fi
    
    # Check for multiple markers (recursive merge evidence)
    if [[ $marker_count -gt 1 ]]; then
        print_error "Multiple markers detected in $file (recursive merge evidence)"
        return 1
    fi
    
    return 0
}

# Function to clean template content from source to prevent recursion
clean_template_from_source() {
    local source_file="$1"
    local temp_file="${source_file}.clean.$$"
    local marker="# ========== CLAUDE FLOW TEMPLATE =========="
    
    # Extract only content before the first marker
    awk -v marker="$marker" '
        $0 ~ marker { exit }
        { print }
    ' "$source_file" > "$temp_file"
    
    # Return path to cleaned file
    echo "$temp_file"
}

# Function to merge CLAUDE.md files using marker-based approach
merge_claude_md() {
    local source_file="$1"
    local target_file="$2"
    local marker="# ========== CLAUDE FLOW TEMPLATE =========="
    local backup_file="${target_file}.backup.$(date +%s)"

    if [[ ! -f "$source_file" ]]; then
        print_error "Source CLAUDE.md not found: $source_file"
        return 1
    fi

    # Validate marker integrity in both files
    if ! validate_marker_integrity "$source_file"; then
        print_error "Source file has corrupted markers"
        return 1
    fi
    
    if ! validate_marker_integrity "$target_file"; then
        print_error "Target file has corrupted markers"
        return 1
    fi

    # Check for self-merge (same absolute path)
    local source_abs=$(cd "$(dirname "$source_file")" && pwd)/$(basename "$source_file")
    local target_abs=$(cd "$(dirname "$target_file")" && pwd)/$(basename "$target_file")
    
    if [[ "$source_abs" == "$target_abs" ]]; then
        print_error "Self-merge detected: source and target are the same file"
        print_error "Source: $source_abs"
        print_error "Target: $target_abs"
        return 1
    fi

    # If target doesn't exist, copy template
    if [[ ! -f "$target_file" ]]; then
        print_status "No existing CLAUDE.md in target, copying template"
        # Clean source of any template content before copying
        if detect_recursive_merge "$source_file"; then
            print_status "Cleaning template content from source before copy"
            local cleaned_source=$(clean_template_from_source "$source_file")
            cp "$cleaned_source" "$target_file"
            rm -f "$cleaned_source"
        else
            cp "$source_file" "$target_file"
        fi
        return 0
    fi

    # Detect recursive merge in source
    if detect_recursive_merge "$source_file"; then
        print_status "Recursive merge detected in source, using cleaned content"
        local cleaned_source=$(clean_template_from_source "$source_file")
        source_file="$cleaned_source"
    fi

    print_status "Merging CLAUDE.md files using marker-based approach..."

    # Create backup for safety
    if ! cp "$target_file" "$backup_file"; then
        print_error "Failed to create backup: $backup_file"
        return 1
    fi
    print_status "Backup created: $(basename "$backup_file")"

    # Generate content fingerprints for deduplication
    local existing_fingerprint=$(generate_content_fingerprint "$target_file")
    local new_fingerprint=$(generate_content_fingerprint "$source_file")
    
    # Check if content is already identical (no merge needed)
    if [[ -n "$existing_fingerprint" && -n "$new_fingerprint" && "$existing_fingerprint" == "$new_fingerprint" ]]; then
        print_status "Template content is already up-to-date (fingerprints match)"
        print_status "Existing: $existing_fingerprint"
        print_status "New: $new_fingerprint"
        
        # Clean up temporary files and backup
        if [[ "$source_file" == *".clean.$$" ]]; then
            rm -f "$source_file"
        fi
        if [[ -f "$backup_file" ]]; then
            rm -f "$backup_file"
            print_status "Backup file removed (no changes needed)"
        fi
        return 0
    fi

    # Atomic merge operation using temporary file
    local temp_merged="${target_file}.merged.$$"
    
    # Build merged content in temporary file
    {
        # Extract custom content (everything before marker)
        if grep -q "$marker" "$target_file"; then
            awk -v marker="$marker" '
                $0 ~ marker { exit }
                { print }
            ' "$target_file"
        else
            cat "$target_file"
        fi
        
        # Add template section
        echo ""
        echo "$marker"
        echo "# Auto-updated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        cat "$source_file"
    } > "$temp_merged"

    # Validate merged file before replacing
    if [[ ! -f "$temp_merged" || ! -s "$temp_merged" ]]; then
        print_error "Failed to create merged file, restoring from backup"
        rm -f "$temp_merged"
        if [[ -f "$backup_file" ]]; then
            cp "$backup_file" "$target_file"
            print_status "Restored from backup: $(basename "$backup_file")"
        fi
        return 1
    fi

    # Verify marker was added correctly in merged file
    if ! grep -q "$marker" "$temp_merged"; then
        print_error "Merge marker not found in merged file, restoring from backup"
        rm -f "$temp_merged"
        if [[ -f "$backup_file" ]]; then
            cp "$backup_file" "$target_file"
            print_status "Restored from backup: $(basename "$backup_file")"
        fi
        return 1
    fi

    # Atomic replace: move temporary file to target
    if mv "$temp_merged" "$target_file"; then
        print_success "Atomic merge completed successfully"
        print_status "Content fingerprint: $(generate_content_fingerprint "$target_file")"
    else
        print_error "Failed to complete atomic merge, restoring from backup"
        rm -f "$temp_merged"
        if [[ -f "$backup_file" ]]; then
            cp "$backup_file" "$target_file"
            print_status "Restored from backup: $(basename "$backup_file")"
        fi
        return 1
    fi

    # Clean up temporary files
    if [[ "$source_file" == *".clean.$$" ]]; then
        rm -f "$source_file"
    fi

    # Remove the backup file on successful merge
    if [[ -f "$backup_file" ]]; then
        rm -f "$backup_file"
        print_status "Backup file removed after successful merge"
    fi

    # Cleanup old backups (keep last 5)
    cleanup_old_merge_backups "$(dirname "$target_file")"

    print_success "CLAUDE.md files merged successfully"
}

# Function to setup Claude commands with simple backup
setup_claude_commands() {
    local target_dir="$1"
    local claude_dir="$target_dir/.claude"
    local commands_dir="$claude_dir/commands"
    local backup_path=""

    # Create .claude directory if it doesn't exist
    if [[ ! -d "$claude_dir" ]]; then
        mkdir -p "$claude_dir"
    fi

    # Simple backup of existing commands
    if [[ -d "$commands_dir" ]]; then
        backup_path=$(create_backup "$commands_dir")
        print_status "Backup created: $backup_path"
    fi

    # Copy templates to commands directory
    if [[ -d "$TEMPLATES_DIR/commands" ]]; then
        print_status "Copying command templates..."
        
        # Remove existing commands and copy new ones (with size check)
        local templates_size=$(du -s "$TEMPLATES_DIR/commands" 2>/dev/null | cut -f1)
        if [[ $templates_size -gt 10240 ]]; then  # 10MB limit
            print_error "Templates directory too large: ${templates_size}KB"
            return 1
        fi
        
        rm -rf "$commands_dir"
        cp -r "$TEMPLATES_DIR/commands" "$commands_dir"
        
        # Verify copy succeeded (with limited find)
        if [[ -d "$commands_dir" ]]; then
            local final_count=$(find "$commands_dir" -maxdepth 3 -name "*.md" 2>/dev/null | head -1000 | wc -l)
            print_success "Commands copied successfully ($final_count files)"
            
            # Clean up backup on success (allow grace period for verification)
            if [[ -n "$backup_path" && -d "$backup_path" ]]; then
                local grace_period="${CLAUDE_MERGE_BACKUP_GRACE:-0}"
                if [[ "$grace_period" -eq 0 ]]; then
                    rm -rf "$backup_path"
                else
                    print_status "Backup preserved for ${grace_period}h grace period: $(basename "$backup_path")"
                fi
            fi
        else
            print_error "Failed to copy commands"
            # Restore from backup if it exists
            if [[ -n "$backup_path" && -d "$backup_path" ]]; then
                cp -r "$backup_path" "$commands_dir"
                print_status "Restored from backup"
            fi
            return 1
        fi
    else
        print_error "No command templates found in $TEMPLATES_DIR/commands"
        return 1
    fi
}

# Main function
main() {
    if [[ $# -gt 1 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        echo "Usage: $0 [target-directory]"
        echo "Simple smart merge for CLAUDE.md and command templates"
        echo ""
        echo "Environment Variables:"
        echo "  CLAUDE_MERGE_BACKUP=false         Disable backup creation"
        echo "  CLAUDE_MERGE_BACKUP_RETENTION=24  Backup retention hours (default: 24)"
        echo "  CLAUDE_MERGE_BACKUP_GRACE=0       Grace period for successful backups (default: 0)"
        echo ""
        echo "Examples:"
        echo "  $0                                 # Merge in current directory"
        echo "  CLAUDE_MERGE_BACKUP=false $0      # Merge without backups"
        echo "  CLAUDE_MERGE_BACKUP_RETENTION=48 $0  # Keep backups for 48 hours"
        exit 1
    fi

    # Check for concurrent execution
    check_lock

    local target_dir="${1:-$(pwd)}"

    # Validate target directory
    if [[ ! -d "$target_dir" ]]; then
        print_error "Target directory does not exist: $target_dir"
        exit 1
    fi

    # Convert to absolute path
    target_dir="$(cd "$target_dir" && pwd)"

    print_status "Starting smart merge for: $target_dir"

    # Clean up old backup files first
    cleanup_old_backups "$target_dir"

    # Find source CLAUDE.md
    local current_claude="$(pwd)/CLAUDE.md"
    local template_claude="$TEMPLATES_DIR/CLAUDE.md"
    local target_claude="$target_dir/CLAUDE.md"

    # Determine source file - always use template when available
    # Exception: if target is different from current directory, use current as source
    local source_claude=""
    local current_abs=$(cd "$(dirname "$current_claude")" && pwd)/$(basename "$current_claude")
    local target_abs=$(cd "$(dirname "$target_claude")" && pwd)/$(basename "$target_claude")
    
    if [[ "$current_abs" != "$target_abs" && -f "$current_claude" ]]; then
        # Target is different directory, use current CLAUDE.md as source
        source_claude="$current_claude"
        print_status "Using current directory CLAUDE.md as source"
    elif [[ -f "$template_claude" ]]; then
        # Use template as source (normal case)
        source_claude="$template_claude"
        print_status "Using template CLAUDE.md as source"
    else
        print_error "No template CLAUDE.md found in templates directory"
        exit 1
    fi

    # Perform the merge
    merge_claude_md "$source_claude" "$target_claude"

    # Setup Claude commands
    setup_claude_commands "$target_dir"

    print_success "Smart merge completed successfully!"
    print_status "Target directory: $target_dir"
    print_status "CLAUDE.md: $target_claude"
    print_status "Commands: $target_dir/.claude/commands"
}

# Run main function with all arguments
main "$@"