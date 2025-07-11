#!/bin/bash

# Claude-flow installation and file merge script
# This script installs claude-flow globally if not installed and merges Claude-related files

# Enable strict error handling
set -euo pipefail

# Ensure clean exit on signals
trap 'exit_handler $?' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Colors for output (readonly constants)
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

# Global variables
readonly SCRIPT_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && builtin pwd)"

# Function to find templates directory
find_templates_dir() {
    local candidates=(
        "$CLAUDE_TEMPLATE_SOURCE"
        "$CLAUDE_TEMPLATES_DIR"
        "$HOME/.local/share/claude-flow/templates"
        "/usr/local/share/claude-flow/templates"
        "$SCRIPT_DIR"
    )
    
    for dir in "${candidates[@]}"; do
        if [[ -n "$dir" && -d "$dir" && -d "$dir/templates" ]]; then
            echo "$dir"
            return 0
        fi
    done
    
    return 1
}
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Exit handler for cleanup
exit_handler() {
    local exit_code=$1
    if [[ $exit_code -ne 0 ]]; then
        print_error "Script failed with exit code $exit_code"
    fi
}

# Function to print colored messages
print_message() {
    local message="${1:-}"
    [[ -n "$message" ]] && echo -e "${GREEN}[CLAUDE-FLOW]${NC} $message" >&1
}

print_warning() {
    local message="${1:-}"
    [[ -n "$message" ]] && echo -e "${YELLOW}[WARNING]${NC} $message" >&2
}

print_error() {
    local message="${1:-}"
    [[ -n "$message" ]] && echo -e "${RED}[ERROR]${NC} $message" >&2
}

# Enhanced error handler for shell environment issues
handle_environment_error() {
    print_error "Shell environment issue detected"
    print_error "This is often caused by version managers (gvm, nvm, etc.) modifying shell functions"
    echo >&2
    echo "Troubleshooting steps:" >&2
    echo "1. Try running with explicit bash: /bin/bash $0" >&2
    echo "2. Or start a fresh shell session: bash --noprofile --norc" >&2
    echo "3. Check if gvm functions are interfering: type cd" >&2
    echo "4. If using gvm, try: unset -f cd" >&2
    return 1
}

# Check if claude-flow is installed globally
check_claude_flow() {
    if command -v claude-flow >/dev/null 2>&1; then
        print_message "claude-flow is already installed globally"
        return 0
    else
        print_warning "claude-flow is not installed globally"
        return 1
    fi
}

# Install claude-flow globally
install_claude_flow() {
    print_message "Installing claude-flow globally..."

    # Check if npm is available
    if ! command -v npm >/dev/null 2>&1; then
        print_error "npm is not installed. Please install Node.js and npm first."
        return 1
    fi

    # Check if we have write permissions for global npm directory
    local npm_prefix
    npm_prefix="$(npm config get prefix 2>/dev/null)" || {
        print_error "Failed to get npm prefix"
        return 1
    }

    # Install claude-flow globally
    if npm install -g claude-flow; then
        print_message "claude-flow installed successfully"
        return 0
    else
        print_error "Failed to install claude-flow. You may need to run with sudo or fix npm permissions."
        return 1
    fi
}

# Function to merge files with conflict resolution
merge_file() {
    local source_file="${1:-}"
    local target_file="${2:-}"
    local file_type="${3:-unknown}"

    # Validate input parameters
    if [[ -z "$source_file" || -z "$target_file" ]]; then
        print_error "merge_file requires source and target file parameters"
        return 1
    fi

    # Validate source file exists
    if [[ ! -f "$source_file" ]]; then
        print_error "Source file does not exist: $source_file"
        return 1
    fi

    if [[ -f "$target_file" ]]; then
        # File exists, check if it's different
        if ! cmp -s "$source_file" "$target_file"; then
            print_warning "Conflict detected for: $target_file"
            echo "Options:"
            echo "  [k] Keep existing file"
            echo "  [o] Overwrite with new file"
            echo "  [m] Merge manually later (create .new file)"
            echo "  [s] Skip this file"

            local choice
            read -r -p "Choose option [k/o/m/s]: " choice

            case "$choice" in
                o)
                    if cp "$source_file" "$target_file"; then
                        print_message "Overwritten: $target_file"
                    else
                        print_error "Failed to overwrite: $target_file"
                        return 1
                    fi
                    ;;
                m)
                    if cp "$source_file" "${target_file}.new"; then
                        print_message "Created new file for manual merge: ${target_file}.new"
                    else
                        print_error "Failed to create .new file: ${target_file}.new"
                        return 1
                    fi
                    ;;
                k)
                    print_message "Kept existing: $target_file"
                    ;;
                s)
                    print_message "Skipped: $target_file"
                    ;;
                *)
                    print_warning "Invalid choice '$choice'. Keeping existing file."
                    ;;
            esac
        else
            print_message "No changes needed for: $target_file"
        fi
    else
        # File doesn't exist, just copy
        local target_dir
        target_dir="$(dirname "$target_file")"

        if ! mkdir -p "$target_dir"; then
            print_error "Failed to create directory: $target_dir"
            return 1
        fi

        if cp "$source_file" "$target_file"; then
            print_message "Created: $target_file"
        else
            print_error "Failed to copy file: $source_file -> $target_file"
            return 1
        fi
    fi
}

# Main merge function
merge_claude_files() {
    local source_dir
    if ! source_dir="$(find_templates_dir)"; then
        error "No valid templates directory found. Searched:"
        error "  1. \$CLAUDE_TEMPLATE_SOURCE: ${CLAUDE_TEMPLATE_SOURCE:-not set}"
        error "  2. \$CLAUDE_TEMPLATES_DIR: ${CLAUDE_TEMPLATES_DIR:-not set}"
        error "  3. ~/.local/share/claude-flow/templates"
        error "  4. /usr/local/share/claude-flow/templates"
        error "  5. $SCRIPT_DIR"
        return 1
    fi
    local target_dir="./claude"

    # Validate source directory exists
    if [[ ! -d "$source_dir" ]]; then
        print_error "Source directory does not exist: $source_dir"
        return 1
    fi

    print_message "Starting merge from $source_dir to $target_dir"

    # Create target directory if it doesn't exist
    if ! mkdir -p "$target_dir"; then
        print_error "Failed to create target directory: $target_dir"
        return 1
    fi

    # Copy .claude directory (if it has contents)
    if [[ -d "$source_dir/.claude" ]] && [[ -n "$(ls -A "$source_dir/.claude" 2>/dev/null)" ]]; then
        print_message "Copying .claude directory..."
        if ! cp -r "$source_dir/.claude" "$target_dir/"; then
            print_warning "Failed to copy .claude directory"
        fi
    fi

    # Handle CLAUDE.md files
    print_message "Processing CLAUDE.md files..."

    # Check if main CLAUDE.md template exists
    if [[ -f "$source_dir/CLAUDE.md" ]]; then
        # Check if target already has a CLAUDE.md
        if [[ -f "$target_dir/CLAUDE.md" ]]; then
            print_warning "CLAUDE.md already exists in target directory"
            merge_file "$source_dir/CLAUDE.md" "$target_dir/CLAUDE.md" "main"
        else
            # No existing CLAUDE.md, copy the main template
            if cp "$source_dir/CLAUDE.md" "$target_dir/CLAUDE.md"; then
                print_message "Created main CLAUDE.md"
            else
                print_error "Failed to create main CLAUDE.md"
            fi
        fi
    elif [[ -f "$source_dir/templates/CLAUDE.md" ]]; then
        # Fallback to templates/CLAUDE.md
        if [[ -f "$target_dir/CLAUDE.md" ]]; then
            print_warning "CLAUDE.md already exists in target directory"
            merge_file "$source_dir/templates/CLAUDE.md" "$target_dir/CLAUDE.md" "main"
        else
            if cp "$source_dir/templates/CLAUDE.md" "$target_dir/CLAUDE.md"; then
                print_message "Created main CLAUDE.md"
            else
                print_error "Failed to create main CLAUDE.md"
            fi
        fi
    else
        print_warning "No main CLAUDE.md template found"
    fi

    # Copy entire templates directory
    print_message "Copying templates directory..."

    # Create templates directory structure
    if ! mkdir -p "$target_dir/templates"; then
        print_error "Failed to create templates directory"
        return 1
    fi

    # Function to recursively copy with merge
    copy_with_merge() {
        local src="${1:-}"
        local dest="${2:-}"

        # Validate parameters
        if [[ -z "$src" || -z "$dest" ]]; then
            print_error "copy_with_merge requires source and destination parameters"
            return 1
        fi

        # Check if source directory exists
        if [[ ! -d "$src" ]]; then
            print_warning "Source directory does not exist: $src"
            return 0
        fi

        for item in "$src"/*; do
            # Handle case where glob doesn't match anything
            [[ -e "$item" ]] || continue

            local basename
            basename="$(basename "$item")"
            local dest_item="$dest/$basename"

            if [[ -d "$item" ]]; then
                if mkdir -p "$dest_item"; then
                    copy_with_merge "$item" "$dest_item"
                else
                    print_error "Failed to create directory: $dest_item"
                fi
            else
                merge_file "$item" "$dest_item" "template"
            fi
        done
    }

    # Copy templates with merge - check if templates directory exists
    if [[ -d "$source_dir/templates" ]]; then
        copy_with_merge "$source_dir/templates" "$target_dir/templates"
    else
        print_warning "Templates directory not found at $source_dir/templates"
    fi

    # Create a merge report
    if ! cat > "$target_dir/MERGE_REPORT.md" << EOF
# Claude-Flow Merge Report

Date: $(date)

## Summary
This report summarizes the merge operation performed by the install-claude-flow.sh script.

### Source Directory
$source_dir

### Target Directory
$target_dir

### Files Processed
- Main CLAUDE.md template
- Language-specific templates (Go, JavaScript, TypeScript, Python, Rust, PHP)
- Framework-specific templates (React, Next.js)
- Command templates (check.md, next.md, prompt.md)
- Workflow templates (CI/CD, documentation, testing)

### Manual Actions Required
Check for any .new files created during the merge process. These indicate conflicts that need manual resolution.

\`\`\`bash
find "$target_dir" -name "*.new" -type f
\`\`\`

### Next Steps
1. Review any .new files and manually merge changes
2. Select appropriate language/framework templates for your project
3. Customize CLAUDE.md based on your project needs
4. Run \`claude-flow init\` to initialize your project

EOF
then
        print_error "Failed to create merge report"
        return 1
    fi

    print_message "Merge report created: $target_dir/MERGE_REPORT.md"
}

# Main execution
main() {
    print_message "Claude-Flow Installation and Merge Script"
    echo "========================================"

    # Detect and warn about shell environment modifications
    local env_warnings=0
    if command -v gvm >/dev/null 2>&1; then
        print_warning "Detected gvm (Go Version Manager) in shell environment"
        env_warnings=$((env_warnings + 1))
    fi
    if command -v nvm >/dev/null 2>&1; then
        print_warning "Detected nvm (Node Version Manager) in shell environment"
        env_warnings=$((env_warnings + 1))
    fi
    if [[ $env_warnings -gt 0 ]]; then
        print_warning "Version managers can sometimes interfere with shell scripts"
        print_warning "If you encounter issues, try running with: /bin/bash $0"
        echo ""
    fi

    # Check and install claude-flow if needed
    if ! check_claude_flow; then
        if ! install_claude_flow; then
            print_error "Failed to install claude-flow. Cannot proceed."
            return 1
        fi
    fi

    # Perform the merge
    if ! merge_claude_files; then
        print_error "Failed to merge Claude files"
        return 1
    fi

    print_message "Process completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Review the merge report at ./claude/MERGE_REPORT.md"
    echo "2. Check for any .new files that need manual merging"
    echo "3. Customize ./claude/CLAUDE.md for your project"
    echo "4. Run 'claude-flow init' in your project directory"
}

# Run main function only if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi