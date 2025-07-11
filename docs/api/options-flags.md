# Claude Flow Options and Flags Reference

This document provides a complete reference for all command-line options and flags available in Claude Flow scripts.

## Table of Contents

- [install.sh Options](#installsh-options)
- [claude-install-flow Options](#claude-install-flow-options)
- [claude-merge Options](#claude-merge-options)
- [Common Patterns](#common-patterns)
- [Option Parsing](#option-parsing)

## install.sh Options

### Synopsis

```bash
./install.sh [OPTIONS]
```

### Options Table

| Option | Short | Description | Default Behavior |
|--------|-------|-------------|------------------|
| `--user` | - | Install for current user only | Auto-detect based on permissions |
| `--system` | - | Install system-wide | Auto-detect based on permissions |
| `--uninstall` | - | Remove Claude Flow tools | - |
| `--help` | - | Show help message and exit | - |

### Option Details

#### --user

Installs Claude Flow tools in user-specific directories.

**Installation Paths:**
- Binaries: `~/.local/bin/`
- Templates: `~/.local/share/claude-flow/templates/`

**Features:**
- No sudo required
- Automatic PATH configuration
- User-specific installation

**Example:**
```bash
./install.sh --user
```

**Output:**
```
[INFO] Installing for user to /home/user/.local/bin and /home/user/.local/share/claude-flow
[SUCCESS] Files installed successfully
[WARNING] /home/user/.local/bin is not in your PATH
Would you like to add it automatically? (y/n):
```

#### --system

Installs Claude Flow tools system-wide for all users.

**Installation Paths:**
- Binaries: `/usr/local/bin/`
- Templates: `/usr/local/share/claude-flow/templates/`

**Features:**
- Available to all users
- May require sudo
- No PATH modification needed

**Example:**
```bash
./install.sh --system
# Or if not root:
sudo ./install.sh --system
```

**Output:**
```
[INFO] Installing system-wide to /usr/local/bin and /usr/local/share/claude-flow
[SUCCESS] Files installed successfully
```

#### --uninstall

Removes all Claude Flow installations from the system.

**Removal Targets:**
- User binaries: `~/.local/bin/claude-*`
- System binaries: `/usr/local/bin/claude-*`
- User data: `~/.local/share/claude-flow/`
- System data: `/usr/local/share/claude-flow/`

**Example:**
```bash
./install.sh --uninstall
```

**Output:**
```
[INFO] Uninstalling Claude Flow tools...
[INFO] Removed /home/user/.local/bin/claude-install-flow
[INFO] Removed /home/user/.local/bin/claude-merge
[INFO] Removed /home/user/.local/share/claude-flow
[SUCCESS] Uninstallation completed (3 items removed)
```

#### --help

Displays usage information and exits.

**Example:**
```bash
./install.sh --help
```

**Output:**
```
Claude Flow Installation Script

Usage: ./install.sh [OPTIONS]

Options:
  --user      Install for current user only (~/.local/)
  --system    Install system-wide (/usr/local/)
  --uninstall Remove Claude Flow tools
  --help      Show this help message

If no option is specified, installation type is auto-detected.
```

### Auto-Detection Logic

When no option is specified:

1. **Root User:** Installs system-wide
2. **Write Access to /usr/local:** Installs system-wide
3. **Otherwise:** Installs for current user

```bash
# Auto-detection function
detect_install_type() {
    if [[ $EUID -eq 0 ]]; then
        echo "system"
    elif [[ -w "/usr/local/bin" && -w "/usr/local/share" ]]; then
        echo "system"
    else
        echo "user"
    fi
}
```

## claude-install-flow Options

### Synopsis

```bash
claude-install-flow [target-directory]
```

### Arguments

| Argument | Required | Description | Default |
|----------|----------|-------------|---------|
| `target-directory` | No | Directory to install templates | Current directory (.) |

### Usage Examples

#### Default Installation

```bash
# Install in current directory
claude-install-flow
```

Creates:
```
./claude/
├── CLAUDE.md
├── MERGE_REPORT.md
├── .claude/
└── templates/
```

#### Specific Directory

```bash
# Install in specific project
claude-install-flow /path/to/my-project
```

Creates:
```
/path/to/my-project/claude/
├── CLAUDE.md
├── MERGE_REPORT.md
├── .claude/
└── templates/
```

#### With Environment Variables

```bash
# Use custom template source
CLAUDE_TEMPLATE_SOURCE=/custom/templates claude-install-flow

# Use alternative templates directory
CLAUDE_TEMPLATES_DIR=$HOME/templates claude-install-flow project/
```

### Merge Options

When files already exist, interactive options are presented:

| Option | Key | Action |
|--------|-----|---------|
| Keep existing | `k` | Preserves current file |
| Overwrite | `o` | Replaces with template |
| Manual merge | `m` | Creates .new file |
| Skip | `s` | Skips this file |

**Example Interaction:**
```
[WARNING] Conflict detected for: ./claude/CLAUDE.md
Options:
  [k] Keep existing file
  [o] Overwrite with new file
  [m] Merge manually later (create .new file)
  [s] Skip this file
Choose option [k/o/m/s]: m
[INFO] Created new file for manual merge: ./claude/CLAUDE.md.new
```

## claude-merge Options

### Synopsis

```bash
claude-merge [target-directory]
```

### Arguments

| Argument | Required | Description | Default |
|----------|----------|-------------|---------|
| `target-directory` | No | Directory to merge into | Current directory (.) |

### Usage Examples

#### Default Merge

```bash
# Merge into current directory
claude-merge
```

**Operations:**
1. Finds CLAUDE.md in current directory or templates
2. Merges with target directory's CLAUDE.md
3. Sets up .claude/commands/

#### Specific Directory

```bash
# Merge into specific project
claude-merge /path/to/project
```

#### With Custom Templates

```bash
# Use custom templates directory
CLAUDE_TEMPLATES_DIR=/my/templates claude-merge
```

### Merge Behavior

The script performs intelligent merging:

1. **No Existing CLAUDE.md:** Copies template
2. **Existing CLAUDE.md:** Creates merged version preserving customizations
3. **Commands Directory:** Copies all command templates

**Output Example:**
```
[INFO] Starting smart merge for: /path/to/project
[INFO] Using CLAUDE.md from current directory
[INFO] Merging CLAUDE.md files...
[SUCCESS] CLAUDE.md files merged successfully
[INFO] Creating .claude/commands directory
[INFO] Copying Claude command templates
[SUCCESS] Claude commands setup complete
[SUCCESS] Smart merge completed successfully!
```

## Common Patterns

### Option Parsing Pattern

All scripts use similar option parsing:

```bash
# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --option1)
            # Handle option1
            shift
            ;;
        --option2)
            # Handle option2
            shift
            ;;
        *)
            # Handle unknown option
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done
```

### Help Option Pattern

Standard help option implementation:

```bash
--help)
    show_usage
    exit 0
    ;;
```

### Validation Pattern

Input validation for options:

```bash
# Validate mutually exclusive options
if [[ "$option1" == "true" && "$option2" == "true" ]]; then
    print_error "Cannot use --option1 and --option2 together"
    exit 1
fi
```

## Option Parsing

### Strict Mode

Scripts use strict error handling:

```bash
set -e  # Exit on error
set -u  # Error on undefined variables (some scripts)
set -o pipefail  # Pipeline failures are errors
```

### Argument Handling

#### Positional Arguments

```bash
# Get first positional argument with default
target_dir="${1:-$(pwd)}"

# Validate argument count
if [[ $# -gt 1 ]]; then
    echo "Too many arguments"
    exit 1
fi
```

#### Optional Arguments

```bash
# Handle optional directory argument
if [[ $# -eq 1 ]]; then
    target_dir="$1"
else
    target_dir="."
fi
```

### Error Messages

Consistent error messaging for invalid options:

```bash
# Unknown option
print_error "Unknown option: $1"
show_usage
exit 1

# Missing argument
print_error "Option --foo requires an argument"
exit 1

# Invalid value
print_error "Invalid value for --type: $value"
exit 1
```

## Best Practices

### Option Design

1. **Use Long Options**
   - More readable: `--install` vs `-i`
   - Self-documenting
   - Prevents conflicts

2. **Provide Defaults**
   ```bash
   target_dir="${1:-$(pwd)}"
   ```

3. **Validate Early**
   ```bash
   # Validate options before processing
   if [[ ! -d "$target_dir" ]]; then
       print_error "Directory not found: $target_dir"
       exit 1
   fi
   ```

### User Experience

1. **Clear Help Text**
   - Show usage examples
   - Explain each option
   - Include defaults

2. **Interactive Prompts**
   ```bash
   read -p "Continue? (y/n): " -n 1 -r
   echo
   if [[ ! $REPLY =~ ^[Yy]$ ]]; then
       exit 0
   fi
   ```

3. **Progress Feedback**
   ```bash
   print_status "Installing files..."
   # ... operation ...
   print_success "Installation complete!"
   ```

### Safety Features

1. **Confirmation for Destructive Actions**
   ```bash
   if [[ "$action" == "uninstall" ]]; then
       echo "This will remove all Claude Flow tools."
       read -p "Are you sure? (y/n): " -n 1 -r
   fi
   ```

2. **Dry Run Support** (future enhancement)
   ```bash
   if [[ "$dry_run" == "true" ]]; then
       echo "[DRY RUN] Would install to: $target_dir"
       exit 0
   fi
   ```

3. **Rollback Information**
   ```bash
   print_info "To uninstall, run: $0 --uninstall"
   ```