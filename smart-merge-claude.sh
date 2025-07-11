#!/bin/bash

# Smart merge script for CLAUDE.md files and Claude commands setup
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
        echo "# Merged CLAUDE.md Configuration"
        echo ""
        echo "<!-- This file was automatically merged from template and existing configurations -->"
        echo ""

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
        echo "## Template Configuration"
        echo ""
        cat "$source_file"

    } > "$temp_file"

    # Replace target with merged content
    mv "$temp_file" "$target_file"
    print_success "CLAUDE.md files merged successfully"
}

# Function to setup Claude commands
setup_claude_commands() {
    local target_dir="$1"
    local claude_dir="$target_dir/.claude"
    local commands_dir="$claude_dir/commands"

    # Create .claude directory if it doesn't exist
    if [[ ! -d "$claude_dir" ]]; then
        print_status "Creating .claude directory"
        mkdir -p "$claude_dir"
    fi

    # Create commands directory
    if [[ ! -d "$commands_dir" ]]; then
        print_status "Creating .claude/commands directory"
        mkdir -p "$commands_dir"
    fi

    # Copy command templates
    if [[ -d "$TEMPLATES_DIR/commands" ]]; then
        print_status "Copying Claude command templates"
        cp -r "$TEMPLATES_DIR/commands/"* "$commands_dir/"
        print_success "Claude commands setup complete"
    else
        print_warning "No command templates found in $TEMPLATES_DIR/commands"
    fi
}

# Main function
main() {
    if [[ $# -gt 1 ]]; then
        echo "Usage: $0 [target-directory]"
        echo ""
        echo "This script will:"
        echo "  1. Smart merge CLAUDE.md from current directory and target directory"
        echo "  2. Copy Claude command templates to target/.claude/commands"
        echo ""
        echo "If no target directory is specified, uses current directory."
        exit 1
    fi

    local target_dir="${1:-$(pwd)}"

    # Validate target directory
    if [[ ! -d "$target_dir" ]]; then
        print_error "Target directory does not exist: $target_dir"
        exit 1
    fi

    # Convert to absolute path
    target_dir="$(cd "$target_dir" && pwd)"

    print_status "Starting smart merge for: $target_dir"

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

    # Setup Claude commands
    setup_claude_commands "$target_dir"

    print_success "Smart merge completed successfully!"
    print_status "Target directory: $target_dir"
    print_status "CLAUDE.md: $target_claude"
    print_status "Commands: $target_dir/.claude/commands"
}

# Run main function with all arguments
main "$@"