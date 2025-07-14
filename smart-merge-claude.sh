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
    
    # Find and clean old backup files
    while IFS= read -r -d '' backup_file; do
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
    done < <(find "$target_dir" -name "*.backup.*" -print0 2>/dev/null)
    
    if [[ $cleaned_count -gt 0 ]]; then
        print_status "Cleaned $cleaned_count old backup files (older than ${retention_hours}h)"
    fi
}

# Function to merge CLAUDE.md files intelligently
merge_claude_md() {
    local source_file="$1"
    local target_file="$2"
    local temp_file="/tmp/claude_merge_$$"

    if [[ ! -f "$source_file" ]]; then
        print_error "Source CLAUDE.md not found: $source_file"
        return 1
    fi

    if [[ ! -f "$target_file" ]]; then
        print_status "No existing CLAUDE.md in target, copying template"
        cp "$source_file" "$target_file"
        return 0
    fi

    print_status "Merging CLAUDE.md files..."

    # Create merged content
    {
        # Add existing content (skip if it's just the template)
        if ! diff -q "$source_file" "$target_file" > /dev/null 2>&1; then
            echo "## Existing Project Configuration"
            echo ""
            # Skip common template headers to avoid duplication
            grep -v "^# Development Partnership" "$target_file" | \
            grep -v "^We're building production-quality code" | \
            grep -v "^When you seem stuck" | \
            sed '/^## 🚨 AUTOMATED CHECKS ARE MANDATORY/,$d'
            echo ""
        fi

        # Add template content
        cat "$source_file"
    } > "$temp_file"

    # Replace target with merged content
    mv "$temp_file" "$target_file"
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
        
        # Remove existing commands and copy new ones
        rm -rf "$commands_dir"
        cp -r "$TEMPLATES_DIR/commands" "$commands_dir"
        
        # Verify copy succeeded
        if [[ -d "$commands_dir" ]]; then
            local final_count=$(find "$commands_dir" -name "*.md" | wc -l)
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

    # Determine source file (prefer current directory, fallback to template)
    local source_claude=""
    if [[ -f "$current_claude" ]]; then
        source_claude="$current_claude"
    elif [[ -f "$template_claude" ]]; then
        source_claude="$template_claude"
    else
        print_error "No CLAUDE.md found in current directory or templates"
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