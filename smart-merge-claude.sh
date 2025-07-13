#!/bin/bash

# Enhanced Smart merge script for CLAUDE.md files and Claude commands setup
# Usage: ./smart-merge-claude.sh <target-directory>
# 
# Features:
# - Atomic operations with rollback capability
# - Automatic backup before destructive operations
# - Lock file protection against concurrent execution
# - Enhanced error handling and validation
# - Detailed logging for debugging

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
    print_error "No valid templates directory found. Searched:"
    print_error "  1. \$CLAUDE_TEMPLATES_DIR: ${CLAUDE_TEMPLATES_DIR:-not set}"
    print_error "  2. ~/.local/share/claude-flow/templates"
    print_error "  3. /usr/local/share/claude-flow/templates"
    print_error "  4. $SCRIPT_DIR/templates"
    exit 1
fi

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
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
            print_error "If you're sure no other merge is running, remove: $LOCK_FILE"
            exit 1
        else
            print_warning "Stale lock file found, removing..."
            rm -f "$LOCK_FILE"
        fi
    fi
    
    # Create lock file with current PID
    echo $$ > "$LOCK_FILE"
}

# Function to create backup
create_backup() {
    local target_path="$1"
    local backup_path="${target_path}.backup.$(date +%s)"
    
    if [[ -e "$target_path" ]]; then
        print_status "Creating backup: $backup_path"
        cp -r "$target_path" "$backup_path"
        echo "$backup_path"
    fi
}

# Function to validate disk space
check_disk_space() {
    local target_dir="$1"
    local templates_dir="$2"
    
    # Get required space (commands directory size + 50% buffer)
    if [[ -d "$templates_dir/commands" ]]; then
        local required_kb=$(du -sk "$templates_dir/commands" | cut -f1)
        required_kb=$((required_kb + required_kb / 2))  # Add 50% buffer
        
        # Get available space
        local available_kb=$(df "$target_dir" | awk 'NR==2 {print $4}')
        
        if [[ $available_kb -lt $required_kb ]]; then
            print_error "Insufficient disk space. Required: ${required_kb}KB, Available: ${available_kb}KB"
            return 1
        fi
    fi
    return 0
}

# Function to validate templates
validate_templates() {
    local templates_dir="$1"
    
    print_status "Validating template integrity..."
    
    # Check if commands directory exists
    if [[ ! -d "$templates_dir/commands" ]]; then
        print_error "Commands directory not found: $templates_dir/commands"
        return 1
    fi
    
    # Check for essential command files
    local essential_commands=("debug.md" "architect.md" "next.md")
    for cmd in "${essential_commands[@]}"; do
        if [[ ! -f "$templates_dir/commands/$cmd" ]]; then
            print_warning "Essential command missing: $cmd"
        fi
    done
    
    # Validate YAML frontmatter in a sample of command files
    local sample_files=$(find "$templates_dir/commands" -name "*.md" | head -5)
    for file in $sample_files; do
        if ! head -10 "$file" | grep -q "^---$"; then
            print_warning "Invalid YAML frontmatter in: $(basename "$file")"
        fi
    done
    
    print_success "Template validation completed"
    return 0
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

# Function to setup Claude commands with atomic operations
setup_claude_commands() {
    local target_dir="$1"
    local claude_dir="$target_dir/.claude"
    local commands_dir="$claude_dir/commands"
    local temp_commands_dir="$claude_dir/commands.tmp.$$"
    local backup_path=""

    # Validate templates first
    if ! validate_templates "$TEMPLATES_DIR"; then
        print_error "Template validation failed, aborting commands setup"
        return 1
    fi

    # Check disk space
    if ! check_disk_space "$target_dir" "$TEMPLATES_DIR"; then
        print_error "Insufficient disk space, aborting commands setup"
        return 1
    fi

    # Create .claude directory if it doesn't exist
    if [[ ! -d "$claude_dir" ]]; then
        print_status "Creating .claude directory"
        mkdir -p "$claude_dir"
    fi

    # Create backup of existing commands
    if [[ -d "$commands_dir" ]]; then
        backup_path=$(create_backup "$commands_dir")
        print_status "Existing commands backed up to: $backup_path"
    fi

    # Atomic operation: copy to temporary directory first
    if [[ -d "$TEMPLATES_DIR/commands" ]]; then
        print_status "Performing atomic copy of command templates..."
        
        # Create temporary commands directory
        mkdir -p "$temp_commands_dir"
        
        # Copy all templates to temporary location
        if ! cp -r "$TEMPLATES_DIR/commands/"* "$temp_commands_dir/" 2>/dev/null; then
            print_error "Failed to copy templates to temporary directory"
            rm -rf "$temp_commands_dir"
            return 1
        fi
        
        # Validate copied files
        local template_count=$(find "$TEMPLATES_DIR/commands" -name "*.md" | wc -l)
        local copied_count=$(find "$temp_commands_dir" -name "*.md" | wc -l)
        
        if [[ $template_count -ne $copied_count ]]; then
            print_error "Copy validation failed. Expected $template_count files, got $copied_count"
            rm -rf "$temp_commands_dir"
            return 1
        fi
        
        # Atomic move: replace existing commands directory
        if [[ -d "$commands_dir" ]]; then
            rm -rf "$commands_dir"
        fi
        
        if ! mv "$temp_commands_dir" "$commands_dir"; then
            print_error "Failed to move temporary directory to final location"
            # Attempt rollback if backup exists
            if [[ -n "$backup_path" && -d "$backup_path" ]]; then
                print_status "Attempting rollback from backup..."
                cp -r "$backup_path" "$commands_dir"
            fi
            return 1
        fi
        
        # Verify final state
        local final_count=$(find "$commands_dir" -name "*.md" | wc -l)
        if [[ $final_count -ne $template_count ]]; then
            print_error "Final verification failed. Expected $template_count files, got $final_count"
            return 1
        fi
        
        print_success "Claude commands setup complete ($final_count files copied)"
        print_status "Missing commands have been synchronized to .claude/commands"
        
        # Clean up old backup if operation was successful
        if [[ -n "$backup_path" && -d "$backup_path" ]]; then
            print_status "Cleaning up backup (operation successful)"
            rm -rf "$backup_path"
        fi
        
    else
        print_warning "No command templates found in $TEMPLATES_DIR/commands"
        return 1
    fi
}

# Main function
main() {
    if [[ $# -gt 1 ]]; then
        echo "Usage: $0 [target-directory]"
        echo ""
        echo "Enhanced Smart Merge Script - This script will:"
        echo "  1. Smart merge CLAUDE.md from current directory and target directory"
        echo "  2. Atomically sync Claude command templates to target/.claude/commands"
        echo "  3. Create backups and provide rollback capability"
        echo "  4. Validate templates and check disk space"
        echo "  5. Prevent concurrent execution"
        echo ""
        echo "If no target directory is specified, uses current directory."
        echo ""
        echo "Features:"
        echo "  - Atomic operations (all-or-nothing)"
        echo "  - Automatic backup and rollback"
        echo "  - Lock file protection"
        echo "  - Template validation"
        echo "  - Disk space checking"
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

    print_status "Starting enhanced smart merge for: $target_dir"

    # Check for templates directory
    if [[ ! -d "$TEMPLATES_DIR" ]]; then
        print_error "Templates directory not found: $TEMPLATES_DIR"
        exit 1
    fi

    # Find CLAUDE.md in current working directory
    local current_claude="$(pwd)/CLAUDE.md"
    local template_claude="$TEMPLATES_DIR/CLAUDE.md"
    local target_claude="$target_dir/CLAUDE.md"

    # Determine source file (prefer current directory, fallback to template)
    local source_claude=""
    if [[ -f "$current_claude" ]]; then
        source_claude="$current_claude"
        print_status "Using CLAUDE.md from current directory"
    elif [[ -f "$template_claude" ]]; then
        source_claude="$template_claude"
        print_status "Using CLAUDE.md from templates"
    else
        print_error "No CLAUDE.md found in current directory or templates"
        exit 1
    fi

    # Perform the merge
    merge_claude_md "$source_claude" "$target_claude"

    # Setup Claude commands with enhanced atomic operations
    setup_claude_commands "$target_dir"

    print_success "Enhanced smart merge completed successfully!"
    print_status "Target directory: $target_dir"
    print_status "CLAUDE.md: $target_claude"
    print_status "Commands: $target_dir/.claude/commands"
    
    # Report synchronized command counts
    local final_count=$(find "$target_dir/.claude/commands" -name "*.md" 2>/dev/null | wc -l || echo "0")
    print_status "Total commands synchronized: $final_count"
}

# Run main function with all arguments
main "$@"