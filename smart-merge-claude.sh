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

# Function to check if script self-update is needed
check_script_updates() {
    local template_script="$TEMPLATES_DIR/../smart-merge-claude.sh"
    local current_script="$0"
    
    # Skip self-update if template script doesn't exist or is the same file
    if [[ ! -f "$template_script" ]]; then
        return 0
    fi
    
    # Get absolute paths for comparison
    local template_abs=$(cd "$(dirname "$template_script")" && pwd)/$(basename "$template_script")
    local current_abs=$(cd "$(dirname "$current_script")" && pwd)/$(basename "$current_script")
    
    if [[ "$template_abs" == "$current_abs" ]]; then
        return 0  # Same file, no update needed
    fi
    
    # Check if template script is newer
    if [[ "$template_script" -nt "$current_script" ]]; then
        print_status "Template script is newer than current script"
        
        # Check if auto-update is enabled
        if [[ "${CLAUDE_MERGE_AUTO_UPDATE:-true}" == "true" ]]; then
            print_status "Auto-updating merge script..."
            
            # Create backup of current script
            local backup_script="${current_script}.backup.$(date +%s)"
            cp "$current_script" "$backup_script"
            print_status "Script backup created: $(basename "$backup_script")"
            
            # Update script
            if cp "$template_script" "$current_script"; then
                print_success "Merge script updated successfully"
                print_status "Restarting with updated script..."
                exec "$current_script" "$@"
            else
                print_error "Failed to update script, continuing with current version"
                return 1
            fi
        else
            print_warning "Script update available but auto-update is disabled"
            print_status "Run: cp \"$template_script\" \"$current_script\" to update manually"
        fi
    fi
    
    return 0
}

# Function to update installed merge script in system paths
update_system_script() {
    local template_script="$TEMPLATES_DIR/../smart-merge-claude.sh"
    local updated_any=false
    
    # Skip if no template script available
    if [[ ! -f "$template_script" ]]; then
        return 0
    fi
    
    # Check common system installation paths
    local system_paths=(
        "$HOME/.local/bin/claude-merge"
        "/usr/local/bin/claude-merge"
    )
    
    for system_script in "${system_paths[@]}"; do
        if [[ -f "$system_script" && "$template_script" -nt "$system_script" ]]; then
            print_status "Updating system script: $system_script"
            
            # Create backup
            local backup_path="${system_script}.backup.$(date +%s)"
            cp "$system_script" "$backup_path" 2>/dev/null || continue
            
            # Update script
            if cp "$template_script" "$system_script" 2>/dev/null; then
                chmod +x "$system_script"
                print_success "Updated: $(basename "$system_script")"
                updated_any=true
                
                # Clean up backup
                rm -f "$backup_path"
            else
                print_warning "Failed to update: $system_script"
                # Restore backup if update failed
                mv "$backup_path" "$system_script" 2>/dev/null || true
            fi
        fi
    done
    
    if [[ "$updated_any" == "true" ]]; then
        print_success "System scripts updated successfully"
    fi
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

# Function to setup Claude hooks with simple backup
setup_claude_hooks() {
    local target_dir="$1"
    local claude_dir="$target_dir/.claude"
    local hooks_dir="$claude_dir/hooks"
    local git_hooks_dir="$target_dir/.git/hooks"
    local backup_path=""

    # Create .claude/hooks directory if it doesn't exist
    if [[ ! -d "$hooks_dir" ]]; then
        mkdir -p "$hooks_dir"
    fi

    # Simple backup of existing hooks
    if [[ -d "$hooks_dir" ]]; then
        backup_path=$(create_backup "$hooks_dir")
        if [[ -n "$backup_path" ]]; then
            print_status "Hooks backup created: $(basename "$backup_path")"
        fi
    fi

    # Copy hooks from templates
    if [[ -d "$TEMPLATES_DIR/hooks" ]]; then
        print_status "Installing Claude hooks..."
        
        # Remove existing hooks and copy new ones (with size check)
        local hooks_size=$(du -s "$TEMPLATES_DIR/hooks" 2>/dev/null | cut -f1)
        if [[ $hooks_size -gt 5120 ]]; then  # 5MB limit for hooks
            print_error "Hooks directory too large: ${hooks_size}KB"
            return 1
        fi
        
        rm -rf "$hooks_dir"
        cp -r "$TEMPLATES_DIR/hooks" "$hooks_dir"
        
        # Make hook scripts executable
        find "$hooks_dir" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
        
        # Verify copy succeeded
        if [[ -d "$hooks_dir" ]]; then
            local hook_count=$(find "$hooks_dir" -name "*.sh" 2>/dev/null | wc -l)
            print_success "Hooks installed successfully ($hook_count scripts)"
            
            # Install git hooks if .git directory exists
            if [[ -d "$git_hooks_dir" ]]; then
                install_git_hooks "$target_dir"
            fi
            
            # Clean up backup on success
            if [[ -n "$backup_path" && -d "$backup_path" ]]; then
                local grace_period="${CLAUDE_MERGE_BACKUP_GRACE:-0}"
                if [[ "$grace_period" -eq 0 ]]; then
                    rm -rf "$backup_path"
                else
                    print_status "Hooks backup preserved for ${grace_period}h grace period: $(basename "$backup_path")"
                fi
            fi
        else
            print_error "Failed to install hooks"
            # Restore from backup if it exists
            if [[ -n "$backup_path" && -d "$backup_path" ]]; then
                cp -r "$backup_path" "$hooks_dir"
                print_status "Restored hooks from backup"
            fi
            return 1
        fi
    else
        print_status "No hooks templates found in $TEMPLATES_DIR/hooks - skipping hook installation"
        return 0
    fi
}

# Function to install git hooks integration
install_git_hooks() {
    local target_dir="$1"
    local git_hooks_dir="$target_dir/.git/hooks"
    local claude_hooks_dir="$target_dir/.claude/hooks"
    
    if [[ ! -d "$git_hooks_dir" ]]; then
        print_status "No .git directory found - skipping git hooks integration"
        return 0
    fi
    
    print_status "Setting up git hooks integration..."
    
    # Common git hooks to integrate
    local git_hook_types=("pre-commit" "post-commit" "pre-push" "post-merge")
    
    for hook_type in "${git_hook_types[@]}"; do
        local git_hook_file="$git_hooks_dir/$hook_type"
        local claude_hook_file="$claude_hooks_dir/$hook_type.sh"
        
        # Check if Claude hook exists
        if [[ -f "$claude_hook_file" ]]; then
            # Create or update git hook to call Claude hook
            cat > "$git_hook_file" << EOF
#!/bin/bash
# Auto-generated git hook for Claude integration
# Calls corresponding Claude hook if it exists

CLAUDE_HOOK="\$(dirname "\$0")/../../.claude/hooks/$hook_type.sh"

if [[ -f "\$CLAUDE_HOOK" && -x "\$CLAUDE_HOOK" ]]; then
    exec "\$CLAUDE_HOOK" "\$@"
fi
EOF
            chmod +x "$git_hook_file"
            print_status "Git $hook_type hook installed"
        fi
    done
    
    print_success "Git hooks integration completed"
}

# Function to setup Claude commands with simple backup and _shared relocation
setup_claude_commands() {
    local target_dir="$1"
    local claude_dir="$target_dir/.claude"
    local commands_dir="$claude_dir/commands"
    local shared_dir="$claude_dir/shared"
    local backup_path=""

    # Create .claude directory if it doesn't exist
    if [[ ! -d "$claude_dir" ]]; then
        mkdir -p "$claude_dir"
    fi

    # Simple backup of existing commands
    if [[ -d "$commands_dir" ]]; then
        backup_path=$(create_backup "$commands_dir")
        if [[ -n "$backup_path" ]]; then
            print_status "Commands backup created: $(basename "$backup_path")"
        fi
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
        rm -rf "$shared_dir"
        cp -r "$TEMPLATES_DIR/commands" "$commands_dir"
        
        # Create shared directory structure and move _shared directories
        print_status "Relocating _shared directories to .claude/shared/"
        mkdir -p "$shared_dir"
        
        # Find and move all _shared directories
        local moved_count=0
        find "$commands_dir" -type d -name "_shared" | while read -r shared_path; do
            if [[ -d "$shared_path" ]]; then
                # Get the parent directory name (git, test, quality, etc.)
                local parent_dir=$(basename "$(dirname "$shared_path")")
                local target_shared_dir="$shared_dir/$parent_dir"
                
                # Create parent directory in shared
                mkdir -p "$target_shared_dir"
                
                # Move _shared contents to shared/parent/
                if mv "$shared_path"/* "$target_shared_dir/" 2>/dev/null; then
                    # Remove empty _shared directory
                    rmdir "$shared_path" 2>/dev/null || true
                    print_status "Moved _shared from $parent_dir/ to shared/$parent_dir/"
                    ((moved_count++))
                fi
            fi
        done
        
        # Update references in command files to point to new shared location
        print_status "Updating references to shared utilities..."
        local updated_refs=0
        find "$commands_dir" -name "*.md" -type f | while read -r cmd_file; do
            if [[ -f "$cmd_file" ]]; then
                # Update relative paths from _shared/ to ../../shared/
                if sed -i.tmp 's|_shared/|../../shared/|g' "$cmd_file" 2>/dev/null; then
                    rm -f "$cmd_file.tmp"
                    ((updated_refs++))
                fi
            fi
        done
        
        # Verify copy succeeded (with limited find)
        if [[ -d "$commands_dir" ]]; then
            local final_count=$(find "$commands_dir" -maxdepth 3 -name "*.md" 2>/dev/null | head -1000 | wc -l)
            local shared_count=$(find "$shared_dir" -name "*.md" 2>/dev/null | wc -l)
            print_success "Commands copied successfully ($final_count files)"
            print_success "Shared utilities relocated ($shared_count files in shared/)"
            
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
        echo "Smart merge for CLAUDE.md, command templates, and hooks with auto-update"
        echo ""
        echo "Features:"
        echo "  - Merges CLAUDE.md files using marker-based approach"
        echo "  - Installs command templates to .claude/commands"
        echo "  - Installs and integrates git hooks from templates"
        echo "  - Auto-updates script when template version is newer"
        echo "  - Creates backups and handles cleanup automatically"
        echo ""
        echo "Environment Variables:"
        echo "  CLAUDE_MERGE_BACKUP=false         Disable backup creation"
        echo "  CLAUDE_MERGE_BACKUP_RETENTION=24  Backup retention hours (default: 24)"
        echo "  CLAUDE_MERGE_BACKUP_GRACE=0       Grace period for successful backups (default: 0)"
        echo "  CLAUDE_MERGE_AUTO_UPDATE=false    Disable script auto-update (default: true)"
        echo ""
        echo "Examples:"
        echo "  $0                                 # Merge in current directory"
        echo "  $0 /path/to/project               # Merge in specific directory"
        echo "  CLAUDE_MERGE_BACKUP=false $0      # Merge without backups"
        echo "  CLAUDE_MERGE_AUTO_UPDATE=false $0 # Disable auto-update"
        echo ""
        echo "Files installed/updated:"
        echo "  - target-dir/CLAUDE.md            # Development guidelines"
        echo "  - target-dir/.claude/commands/    # Command templates (user commands only)"
        echo "  - target-dir/.claude/shared/      # Shared utilities (moved from _shared)"
        echo "  - target-dir/.claude/hooks/       # Hook scripts"
        echo "  - target-dir/.git/hooks/          # Git hook integration"
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

    # Check for script updates first (before doing any work)
    check_script_updates "$@"
    
    # Update system scripts if needed
    update_system_script

    # Perform the merge
    merge_claude_md "$source_claude" "$target_claude"

    # Setup Claude commands
    setup_claude_commands "$target_dir"
    
    # Setup Claude hooks
    setup_claude_hooks "$target_dir"

    print_success "Smart merge completed successfully!"
    print_status "Target directory: $target_dir"
    print_status "CLAUDE.md: $target_claude"
    print_status "Commands: $target_dir/.claude/commands (user commands only)"
    print_status "Shared: $target_dir/.claude/shared (utilities moved from _shared)"
    print_status "Hooks: $target_dir/.claude/hooks"
    
    # Show git integration status
    if [[ -d "$target_dir/.git" ]]; then
        print_status "Git hooks integration: Active"
    else
        print_status "Git hooks integration: Not available (no .git directory)"
    fi
}

# Run main function with all arguments
main "$@"