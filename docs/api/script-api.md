# Claude Flow Script API Reference

This document provides detailed API documentation for Claude Flow shell scripts.

## Table of Contents

- [install.sh](#installsh)
- [install-claude-flow.sh](#install-claude-flowsh)
- [smart-merge-claude.sh](#smart-merge-claudesh)
- [Common Functions](#common-functions)
- [Error Handling](#error-handling)

## install.sh

System installation script for Claude Flow tools.

### Functions

#### `detect_install_type()`

Detects the appropriate installation type based on user permissions.

**Returns:**
- `"system"` - If running as root or has write access to /usr/local
- `"user"` - Otherwise

**Example:**
```bash
install_type="$(detect_install_type)"
```

#### `is_in_path(dir)`

Checks if a directory is in the PATH environment variable.

**Parameters:**
- `dir` - Directory path to check

**Returns:**
- `0` - Directory is in PATH
- `1` - Directory is not in PATH

**Example:**
```bash
if is_in_path "$HOME/.local/bin"; then
    echo "Directory is in PATH"
fi
```

#### `add_to_path(dir)`

Adds a directory to PATH in the appropriate shell configuration file.

**Parameters:**
- `dir` - Directory to add to PATH

**Shell Detection:**
- Detects zsh, bash, or falls back to .profile
- Appends export statement to config file

**Example:**
```bash
add_to_path "$HOME/.local/bin"
```

#### `install_files(install_type)`

Main installation function that copies files and sets up Claude Flow.

**Parameters:**
- `install_type` - Either "user" or "system"

**Operations:**
1. Creates bin and data directories
2. Copies templates to data directory
3. Installs and renames scripts:
   - `install-claude-flow.sh` → `claude-install-flow`
   - `smart-merge-claude.sh` → `claude-merge`
4. Makes scripts executable
5. Handles PATH configuration for user installations

**Example:**
```bash
install_files "user"
```

#### `uninstall_files()`

Removes all Claude Flow installations from the system.

**Operations:**
1. Removes commands from both user and system bin directories
2. Removes data directories
3. Reports number of items removed

**Example:**
```bash
uninstall_files
```

### Global Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `USER_BIN_DIR` | `$HOME/.local/bin` | User binary directory |
| `USER_DATA_DIR` | `$HOME/.local/share/claude-flow` | User data directory |
| `SYSTEM_BIN_DIR` | `/usr/local/bin` | System binary directory |
| `SYSTEM_DATA_DIR` | `/usr/local/share/claude-flow` | System data directory |

## install-claude-flow.sh

Claude Flow npm package installer and template merger.

### Functions

#### `find_templates_dir()`

Searches for the templates directory in multiple locations.

**Search Order:**
1. `$CLAUDE_TEMPLATE_SOURCE`
2. `$CLAUDE_TEMPLATES_DIR`
3. `~/.local/share/claude-flow/templates`
4. `/usr/local/share/claude-flow/templates`
5. Script directory

**Returns:**
- Template directory path on success
- Non-zero exit code on failure

**Example:**
```bash
if source_dir="$(find_templates_dir)"; then
    echo "Found templates at: $source_dir"
fi
```

#### `check_claude_flow()`

Checks if claude-flow npm package is installed globally.

**Returns:**
- `0` - claude-flow is installed
- `1` - claude-flow is not installed

**Example:**
```bash
if check_claude_flow; then
    echo "claude-flow is already installed"
fi
```

#### `install_claude_flow()`

Installs claude-flow npm package globally.

**Prerequisites:**
- npm must be installed
- Appropriate permissions for global npm install

**Returns:**
- `0` - Installation successful
- `1` - Installation failed

**Example:**
```bash
install_claude_flow || exit 1
```

#### `merge_file(source_file, target_file, file_type)`

Merges a single file with conflict resolution.

**Parameters:**
- `source_file` - Source file path
- `target_file` - Target file path
- `file_type` - Type of file (for logging)

**Conflict Resolution Options:**
- `[k]` - Keep existing file
- `[o]` - Overwrite with new file
- `[m]` - Create .new file for manual merge
- `[s]` - Skip this file

**Example:**
```bash
merge_file "$source/CLAUDE.md" "$target/CLAUDE.md" "main"
```

#### `merge_claude_files()`

Main merge function that processes all Claude templates.

**Operations:**
1. Finds template source directory
2. Creates target claude directory
3. Copies .claude directory
4. Handles CLAUDE.md with smart merge
5. Recursively copies templates with merge
6. Creates merge report

**Output Structure:**
```
target/claude/
├── CLAUDE.md
├── MERGE_REPORT.md
├── .claude/
└── templates/
```

**Example:**
```bash
merge_claude_files
```

#### `copy_with_merge(src, dest)`

Recursively copies directory contents with merge support.

**Parameters:**
- `src` - Source directory
- `dest` - Destination directory

**Behavior:**
- Creates directories as needed
- Calls merge_file for each file
- Handles nested directory structures

**Example:**
```bash
copy_with_merge "$source/templates" "$target/templates"
```

### Error Handling

#### `exit_handler(exit_code)`

Cleanup handler that runs on script exit.

**Parameters:**
- `exit_code` - The exit code of the script

**Example:**
```bash
trap 'exit_handler $?' EXIT
```

#### `handle_environment_error()`

Provides detailed error information for shell environment issues.

**Common Causes:**
- Version managers (gvm, nvm) modifying shell functions
- Shell function overrides

**Suggested Fixes:**
1. Run with explicit bash: `/bin/bash script.sh`
2. Start fresh shell: `bash --noprofile --norc`
3. Check for function overrides: `type cd`
4. Unset problematic functions: `unset -f cd`

## smart-merge-claude.sh

Smart merge utility for CLAUDE.md files.

### Functions

#### `find_templates_dir()`

Searches for templates directory containing CLAUDE.md.

**Search Order:**
1. `$CLAUDE_TEMPLATES_DIR`
2. `~/.local/share/claude-flow/templates`
3. `/usr/local/share/claude-flow/templates`
4. `script-dir/templates`

**Validation:**
- Directory must exist
- Must contain CLAUDE.md file

**Returns:**
- Template directory path on success
- Non-zero exit code on failure

**Example:**
```bash
TEMPLATES_DIR="$(find_templates_dir)" || exit 1
```

#### `merge_claude_md(source_file, target_file)`

Intelligently merges CLAUDE.md files.

**Parameters:**
- `source_file` - Source CLAUDE.md path
- `target_file` - Target CLAUDE.md path

**Merge Strategy:**
1. If target doesn't exist, copy source
2. If target exists and differs:
   - Create merged file with both configurations
   - Skip duplicate headers
   - Preserve custom content

**Output Format:**
```markdown
# Merged CLAUDE.md Configuration

<!-- This file was automatically merged -->

## Existing Project Configuration
[existing custom content]

## Template Configuration
[template content]
```

**Example:**
```bash
merge_claude_md "$source/CLAUDE.md" "$target/CLAUDE.md"
```

#### `setup_claude_commands(target_dir)`

Sets up .claude/commands directory with command templates.

**Parameters:**
- `target_dir` - Target project directory

**Operations:**
1. Creates .claude/commands directory structure
2. Copies all command templates
3. Preserves existing commands

**Example:**
```bash
setup_claude_commands "/path/to/project"
```

## Common Functions

### Output Functions

All scripts share common output functions for consistent formatting:

#### `print_status(message)`

Prints informational message in blue.

```bash
print_status "Processing files..."
# Output: [INFO] Processing files...
```

#### `print_success(message)`

Prints success message in green.

```bash
print_success "Installation complete!"
# Output: [SUCCESS] Installation complete!
```

#### `print_warning(message)`

Prints warning message in yellow to stderr.

```bash
print_warning "Directory not in PATH"
# Output: [WARNING] Directory not in PATH
```

#### `print_error(message)`

Prints error message in red to stderr.

```bash
print_error "File not found"
# Output: [ERROR] File not found
```

### Utility Functions

#### `command_exists(command)`

Checks if a command is available in PATH.

**Parameters:**
- `command` - Command name to check

**Returns:**
- `0` - Command exists
- `1` - Command not found

**Example:**
```bash
if command_exists npm; then
    echo "npm is available"
fi
```

## Error Handling

### Shell Options

All scripts use strict error handling:

```bash
set -e              # Exit on error
set -u              # Error on undefined variables (some scripts)
set -o pipefail     # Pipeline failures are errors (some scripts)
```

### Signal Handling

Scripts implement proper signal handling:

```bash
trap 'exit_handler $?' EXIT     # Cleanup on exit
trap 'exit 130' INT            # Handle Ctrl+C
trap 'exit 143' TERM           # Handle SIGTERM
```

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | General error |
| `130` | Interrupted (SIGINT) |
| `143` | Terminated (SIGTERM) |

### Common Error Scenarios

#### Missing Dependencies

```bash
if ! command_exists npm; then
    print_error "npm is not installed"
    return 1
fi
```

#### Permission Errors

```bash
if ! mkdir -p "$dir" 2>/dev/null; then
    print_error "Permission denied: $dir"
    return 1
fi
```

#### File Not Found

```bash
if [[ ! -f "$file" ]]; then
    print_error "File not found: $file"
    return 1
fi
```

### Best Practices

1. **Always validate inputs**
   ```bash
   if [[ -z "$1" ]]; then
       print_error "Argument required"
       return 1
   fi
   ```

2. **Check command success**
   ```bash
   if ! cp "$source" "$target"; then
       print_error "Copy failed"
       return 1
   fi
   ```

3. **Use proper quoting**
   ```bash
   # Good
   if [[ -f "$file" ]]; then
   
   # Bad
   if [[ -f $file ]]; then
   ```

4. **Handle cleanup**
   ```bash
   trap 'rm -f "$temp_file"' EXIT
   ```