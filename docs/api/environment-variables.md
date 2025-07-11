# Claude Flow Environment Variables Reference

This document details all environment variables used by Claude Flow scripts and tools.

## Table of Contents

- [Template Configuration](#template-configuration)
- [Installation Settings](#installation-settings)
- [Shell Environment](#shell-environment)
- [Script Behavior](#script-behavior)
- [Usage Examples](#usage-examples)

## Template Configuration

### CLAUDE_TEMPLATE_SOURCE

**Description:** Primary source directory for Claude templates. Takes precedence over all other template locations.

**Used By:** 
- `install-claude-flow.sh`

**Default:** Not set

**Example:**
```bash
export CLAUDE_TEMPLATE_SOURCE="/custom/path/to/templates"
claude-install-flow
```

### CLAUDE_TEMPLATES_DIR

**Description:** Alternative templates directory location. Used when CLAUDE_TEMPLATE_SOURCE is not set.

**Used By:**
- `install-claude-flow.sh`
- `smart-merge-claude.sh`

**Default:** Not set

**Example:**
```bash
export CLAUDE_TEMPLATES_DIR="$HOME/my-claude-templates"
claude-merge /path/to/project
```

## Installation Settings

### Template Search Order

When scripts search for templates, they check locations in this order:

1. `$CLAUDE_TEMPLATE_SOURCE` (install-claude-flow.sh only)
2. `$CLAUDE_TEMPLATES_DIR`
3. `$HOME/.local/share/claude-flow/templates`
4. `/usr/local/share/claude-flow/templates`
5. Script's directory

The first valid directory containing templates is used.

## Shell Environment

### PATH

**Description:** System PATH variable. Scripts check and modify this for user installations.

**Modified By:**
- `install.sh` (when installing for user)

**Modifications:**
- Adds `$HOME/.local/bin` if not present
- Updates shell configuration files (.bashrc, .zshrc, or .profile)

**Example:**
```bash
# After user installation
export PATH="$HOME/.local/bin:$PATH"
```

### HOME

**Description:** User's home directory. Used to determine user-specific installation paths.

**Used For:**
- User installation directory: `$HOME/.local/bin`
- User data directory: `$HOME/.local/share/claude-flow`
- Shell configuration files: `$HOME/.bashrc`, etc.

### SHELL

**Description:** User's default shell. Used to determine which configuration file to update.

**Detection Logic:**
1. Checks `$ZSH_VERSION` or `$SHELL` contains "zsh" → `.zshrc`
2. Checks `$BASH_VERSION` or `$SHELL` contains "bash" → `.bashrc`
3. Otherwise → `.profile`

### EUID

**Description:** Effective user ID. Used to detect if running as root.

**Used By:**
- `install.sh` - Determines system vs user installation

**Example:**
```bash
if [[ $EUID -eq 0 ]]; then
    echo "Running as root"
fi
```

## Script Behavior

### Standard Shell Variables

These variables affect script execution:

| Variable | Description | Impact |
|----------|-------------|---------|
| `BASH_SOURCE` | Array containing source filenames | Used to find script directory |
| `IFS` | Internal Field Separator | Not modified by scripts |
| `PWD` | Present working directory | Used for relative paths |

### Signal Handling Variables

Scripts use these for proper cleanup:

| Variable | Value | Description |
|----------|-------|-------------|
| `?` | Exit code | Captured for exit handlers |
| `$` | Process ID | Used for temporary files |

## Usage Examples

### Custom Template Location

```bash
# Set custom template source
export CLAUDE_TEMPLATE_SOURCE="/company/claude-templates"

# Install with custom templates
claude-install-flow /path/to/project
```

### Alternative Templates Directory

```bash
# Use different templates directory
export CLAUDE_TEMPLATES_DIR="$HOME/work/claude-templates"

# Merge with alternative templates
claude-merge
```

### Debugging Template Search

```bash
# Show template search process
CLAUDE_TEMPLATE_SOURCE="/path1" \
CLAUDE_TEMPLATES_DIR="/path2" \
bash -x claude-install-flow
```

### User Installation with Custom PATH

```bash
# Install for user with specific PATH handling
PATH="$HOME/.local/bin:$PATH" ./install.sh --user
```

### Clean Environment Execution

```bash
# Run in clean environment (useful for debugging)
env -i HOME="$HOME" PATH="/usr/bin:/bin" \
    bash claude-install-flow
```

## Environment Variable Priority

When multiple environment variables could affect the same setting, this priority is used:

1. **Command-line arguments** (highest priority)
2. **Specific environment variables** (e.g., CLAUDE_TEMPLATE_SOURCE)
3. **General environment variables** (e.g., CLAUDE_TEMPLATES_DIR)
4. **System defaults** (lowest priority)

## Best Practices

### Setting Variables

1. **Temporary Usage**
   ```bash
   # Set for single command
   CLAUDE_TEMPLATES_DIR="/tmp/templates" claude-merge
   ```

2. **Session Usage**
   ```bash
   # Set for current session
   export CLAUDE_TEMPLATES_DIR="/my/templates"
   claude-merge project1
   claude-merge project2
   ```

3. **Permanent Usage**
   ```bash
   # Add to shell configuration
   echo 'export CLAUDE_TEMPLATES_DIR="/my/templates"' >> ~/.bashrc
   ```

### Security Considerations

1. **Validate Paths**
   - Scripts validate that template directories exist
   - Scripts check file existence before operations

2. **Avoid Sensitive Data**
   - Don't include passwords or tokens in environment variables
   - Use appropriate file permissions for custom template directories

3. **Path Injection**
   - Scripts use proper quoting to prevent path injection
   - Always use absolute paths when possible

## Troubleshooting

### Template Not Found

```bash
# Debug template search
echo "CLAUDE_TEMPLATE_SOURCE: ${CLAUDE_TEMPLATE_SOURCE:-not set}"
echo "CLAUDE_TEMPLATES_DIR: ${CLAUDE_TEMPLATES_DIR:-not set}"
ls -la ~/.local/share/claude-flow/templates 2>/dev/null || echo "User templates not found"
ls -la /usr/local/share/claude-flow/templates 2>/dev/null || echo "System templates not found"
```

### PATH Issues

```bash
# Check if claude commands are in PATH
which claude-install-flow || echo "claude-install-flow not in PATH"
which claude-merge || echo "claude-merge not in PATH"

# Show current PATH
echo $PATH | tr ':' '\n'
```

### Shell Detection Issues

```bash
# Check shell variables
echo "SHELL: $SHELL"
echo "BASH_VERSION: ${BASH_VERSION:-not set}"
echo "ZSH_VERSION: ${ZSH_VERSION:-not set}"
```

### Permission Problems

```bash
# Check directory permissions
ls -ld ~/.local/bin
ls -ld ~/.local/share/claude-flow
ls -ld /usr/local/bin
ls -ld /usr/local/share/claude-flow
```