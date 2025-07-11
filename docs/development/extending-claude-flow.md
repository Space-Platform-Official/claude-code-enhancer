# Extending Claude Flow

This guide covers how to extend Claude Flow's functionality beyond templates, including new features, integrations, and tools.

## Extension Points

Claude Flow can be extended in several ways:

1. **New Scripts** - Additional automation tools
2. **Integrations** - External service connections
3. **Plugins** - Modular functionality
4. **Hooks** - Custom behavior injection
5. **Utilities** - Helper functions and tools

## Architecture Overview

```
claude-flow/
├── core/                    # Core scripts (future)
│   ├── lib/                # Shared functions
│   ├── plugins/            # Plugin system
│   └── hooks/              # Hook definitions
├── extensions/             # Third-party extensions
│   ├── integrations/       # External integrations
│   └── tools/              # Additional tools
└── scripts/                # Main executable scripts
```

## Creating New Scripts

### 1. Script Template

Start with this template for new scripts:

```bash
#!/bin/bash
# Script: YOUR-SCRIPT-NAME.sh
# Purpose: Brief description
# Usage: YOUR-SCRIPT-NAME.sh [options] [arguments]

set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly DEFAULT_CONFIG="${HOME}/.claude-flow/config"

# Help function
show_help() {
    cat << EOF
$SCRIPT_NAME - Brief description

Usage: $SCRIPT_NAME [OPTIONS] [ARGUMENTS]

Options:
    -h, --help      Show this help message
    -v, --version   Show version information
    -d, --debug     Enable debug output
    
Arguments:
    argument1       Description

Examples:
    $SCRIPT_NAME example1
    $SCRIPT_NAME --debug example2

EOF
}

# Version function
show_version() {
    echo "$SCRIPT_NAME version $SCRIPT_VERSION"
}

# Error handling
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit "${2:-1}"
}

# Main function
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -d|--debug)
                set -x
                shift
                ;;
            -*)
                error_exit "Unknown option: $1"
                ;;
            *)
                # Handle positional arguments
                break
                ;;
        esac
    done
    
    # Your script logic here
    echo "Running $SCRIPT_NAME..."
}

# Run main function
main "$@"
```

### 2. Integrating with Claude Flow

Make your script work with existing tools:

```bash
# Source shared functions
source "${SCRIPT_DIR}/lib/common.sh" 2>/dev/null || true

# Use Claude Flow configuration
load_claude_config() {
    local config_file="${CLAUDE_CONFIG:-$DEFAULT_CONFIG}"
    if [[ -f "$config_file" ]]; then
        source "$config_file"
    fi
}

# Detect Claude Flow installation
find_claude_flow() {
    local claude_dir
    for dir in \
        "$HOME/.local/share/claude-flow" \
        "/usr/local/share/claude-flow" \
        "$SCRIPT_DIR/../templates"; do
        if [[ -d "$dir" ]]; then
            claude_dir="$dir"
            break
        fi
    done
    echo "$claude_dir"
}
```

## Creating Integrations

### 1. Git Integration Example

Create `extensions/integrations/claude-git-setup.sh`:

```bash
#!/bin/bash
# Set up Git hooks for Claude Flow

install_git_hooks() {
    local repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"
    if [[ -z "$repo_root" ]]; then
        error_exit "Not in a Git repository"
    fi
    
    # Install pre-commit hook
    cat > "$repo_root/.git/hooks/pre-commit" << 'EOF'
#!/bin/bash
# Claude Flow pre-commit hook

# Check for CLAUDE.md
if [[ ! -f "CLAUDE.md" ]]; then
    echo "Warning: No CLAUDE.md found in repository"
fi

# Check for .claude directory
if [[ ! -d ".claude" ]]; then
    echo "Warning: No .claude directory found"
fi

# Run any project-specific checks
if [[ -x ".claude/hooks/pre-commit" ]]; then
    .claude/hooks/pre-commit
fi
EOF
    
    chmod +x "$repo_root/.git/hooks/pre-commit"
    echo "Git hooks installed successfully"
}
```

### 2. CI/CD Integration

Create CI/CD templates that work with Claude Flow:

```yaml
# .github/workflows/claude-flow-check.yml
name: Claude Flow Check

on: [push, pull_request]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Check Claude Flow Setup
        run: |
          # Verify CLAUDE.md exists
          if [[ ! -f "CLAUDE.md" ]]; then
            echo "::warning::No CLAUDE.md found"
          fi
          
          # Verify .claude directory
          if [[ ! -d ".claude" ]]; then
            echo "::warning::No .claude directory found"
          fi
          
      - name: Validate Templates
        run: |
          # Add validation logic
          echo "Validating Claude Flow templates..."
```

## Plugin System

### 1. Plugin Structure

Create a plugin system for extensibility:

```bash
# plugins/example-plugin.sh
# Claude Flow Plugin: Example

# Plugin metadata
PLUGIN_NAME="example"
PLUGIN_VERSION="1.0.0"
PLUGIN_DESCRIPTION="Example plugin"

# Plugin initialization
plugin_init() {
    echo "Initializing $PLUGIN_NAME plugin..."
}

# Plugin commands
plugin_command_hello() {
    echo "Hello from $PLUGIN_NAME plugin!"
}

# Register plugin
register_plugin() {
    # Add to global plugin registry
    CLAUDE_PLUGINS["$PLUGIN_NAME"]="$PLUGIN_VERSION"
}
```

### 2. Plugin Loader

Create a plugin loading system:

```bash
# lib/plugin-loader.sh

# Global plugin registry
declare -A CLAUDE_PLUGINS

# Load all plugins
load_plugins() {
    local plugin_dir="${CLAUDE_PLUGIN_DIR:-$HOME/.claude-flow/plugins}"
    
    if [[ ! -d "$plugin_dir" ]]; then
        return 0
    fi
    
    for plugin in "$plugin_dir"/*.sh; do
        if [[ -f "$plugin" ]]; then
            source "$plugin"
            if type -t plugin_init &>/dev/null; then
                plugin_init
            fi
        fi
    done
}

# Execute plugin command
run_plugin_command() {
    local plugin="$1"
    local command="$2"
    shift 2
    
    local func="plugin_${plugin}_${command}"
    if type -t "$func" &>/dev/null; then
        "$func" "$@"
    else
        error_exit "Plugin command not found: $plugin:$command"
    fi
}
```

## Hook System

### 1. Define Hooks

Create hook points in existing scripts:

```bash
# In install-claude-flow.sh

# Define available hooks
declare -a HOOKS=(
    "pre_install"
    "post_install"
    "pre_template_copy"
    "post_template_copy"
    "pre_merge"
    "post_merge"
)

# Run hook
run_hook() {
    local hook_name="$1"
    shift
    
    # User hooks
    local user_hook="$HOME/.claude-flow/hooks/${hook_name}.sh"
    if [[ -x "$user_hook" ]]; then
        "$user_hook" "$@"
    fi
    
    # Project hooks
    local project_hook=".claude/hooks/${hook_name}.sh"
    if [[ -x "$project_hook" ]]; then
        "$project_hook" "$@"
    fi
}

# Use in script
run_hook "pre_install" "$target_dir"
# ... installation logic ...
run_hook "post_install" "$target_dir"
```

### 2. Hook Examples

Create example hooks:

```bash
# ~/.claude-flow/hooks/post_install.sh
#!/bin/bash
# Run after Claude Flow installation

echo "Running post-installation tasks..."

# Create custom directories
mkdir -p .claude/custom

# Generate project-specific files
cat > .claude/custom/project-info.md << EOF
# Project Information
Installed: $(date)
User: $(whoami)
Directory: $(pwd)
EOF

# Run any project setup
if [[ -f "package.json" ]]; then
    echo "Detected Node.js project, installing dependencies..."
    npm install
fi
```

## Utility Functions

### 1. Shared Library

Create `lib/common.sh` for shared functions:

```bash
# lib/common.sh
# Common functions for Claude Flow scripts

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# File operations
safe_copy() {
    local source="$1"
    local dest="$2"
    
    if [[ -f "$dest" ]]; then
        cp "$dest" "${dest}.backup"
        log_info "Backed up existing file: ${dest}.backup"
    fi
    
    cp "$source" "$dest"
    log_success "Copied: $source -> $dest"
}

# Template operations
expand_template() {
    local template="$1"
    local output="$2"
    
    # Replace template variables
    sed -e "s/{{PROJECT_NAME}}/${PROJECT_NAME:-MyProject}/g" \
        -e "s/{{USER}}/${USER}/g" \
        -e "s/{{DATE}}/$(date +%Y-%m-%d)/g" \
        "$template" > "$output"
}

# Directory operations
ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        log_success "Created directory: $dir"
    fi
}
```

### 2. Configuration Management

Create configuration utilities:

```bash
# lib/config.sh
# Configuration management for Claude Flow

# Default configuration
declare -A CLAUDE_CONFIG=(
    [TEMPLATE_DIR]="$HOME/.local/share/claude-flow/templates"
    [PLUGIN_DIR]="$HOME/.claude-flow/plugins"
    [HOOK_DIR]="$HOME/.claude-flow/hooks"
    [AUTO_UPDATE]="true"
    [COLOR_OUTPUT]="true"
)

# Save configuration
save_config() {
    local config_file="${1:-$HOME/.claude-flow/config}"
    ensure_directory "$(dirname "$config_file")"
    
    {
        echo "# Claude Flow Configuration"
        echo "# Generated: $(date)"
        echo
        for key in "${!CLAUDE_CONFIG[@]}"; do
            echo "CLAUDE_CONFIG[$key]=\"${CLAUDE_CONFIG[$key]}\""
        done
    } > "$config_file"
}

# Load configuration
load_config() {
    local config_file="${1:-$HOME/.claude-flow/config}"
    if [[ -f "$config_file" ]]; then
        source "$config_file"
    fi
}

# Get config value
get_config() {
    local key="$1"
    echo "${CLAUDE_CONFIG[$key]:-}"
}

# Set config value
set_config() {
    local key="$1"
    local value="$2"
    CLAUDE_CONFIG[$key]="$value"
}
```

## Advanced Extensions

### 1. Template Validator

Create a template validation tool:

```bash
#!/bin/bash
# validate-templates.sh
# Validate Claude Flow templates

validate_claude_md() {
    local file="$1"
    local errors=0
    
    # Check required sections
    local required_sections=(
        "Overview"
        "Guidelines"
        "Best Practices"
    )
    
    for section in "${required_sections[@]}"; do
        if ! grep -q "^#.*$section" "$file"; then
            log_error "Missing section: $section in $file"
            ((errors++))
        fi
    done
    
    # Check for placeholder variables
    if grep -q "{{.*}}" "$file"; then
        log_warning "Unexpanded template variables in $file"
    fi
    
    return $errors
}

validate_all_templates() {
    local template_dir="${1:-templates}"
    local total_errors=0
    
    find "$template_dir" -name "CLAUDE.md" -type f | while read -r file; do
        if ! validate_claude_md "$file"; then
            ((total_errors++))
        fi
    done
    
    if [[ $total_errors -eq 0 ]]; then
        log_success "All templates validated successfully"
    else
        log_error "Found $total_errors validation errors"
        return 1
    fi
}
```

### 2. Update Checker

Create an update checking mechanism:

```bash
#!/bin/bash
# check-updates.sh
# Check for Claude Flow updates

check_for_updates() {
    local current_version="$(get_installed_version)"
    local latest_version="$(get_latest_version)"
    
    if version_gt "$latest_version" "$current_version"; then
        log_info "Update available: $current_version -> $latest_version"
        return 0
    else
        log_success "Claude Flow is up to date"
        return 1
    fi
}

get_installed_version() {
    # Read from version file or git tag
    if [[ -f "$CLAUDE_FLOW_DIR/VERSION" ]]; then
        cat "$CLAUDE_FLOW_DIR/VERSION"
    else
        echo "unknown"
    fi
}

get_latest_version() {
    # Check GitHub releases API
    curl -s https://api.github.com/repos/your-org/claude-flow/releases/latest \
        | grep '"tag_name"' \
        | cut -d'"' -f4
}

version_gt() {
    # Compare version numbers
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}
```

## Best Practices for Extensions

### 1. Maintain Compatibility

- Test with different Claude Flow versions
- Use feature detection, not version checks
- Provide graceful fallbacks

### 2. Follow Conventions

- Use consistent naming patterns
- Follow existing code style
- Document all public functions

### 3. Error Handling

```bash
# Always check dependencies
check_dependencies() {
    local deps=("git" "curl" "jq")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            error_exit "Required dependency not found: $dep"
        fi
    done
}

# Provide helpful error messages
validate_input() {
    if [[ -z "$1" ]]; then
        error_exit "Input required. Use --help for usage information."
    fi
}
```

### 4. Testing Extensions

Create tests for your extensions:

```bash
# test/test-extension.sh
test_my_extension() {
    print_test "Testing my extension"
    
    # Test basic functionality
    if ./my-extension.sh --version &>/dev/null; then
        print_success "Version check passed"
    else
        print_error "Version check failed"
    fi
    
    # Test main features
    # ...
}
```

## Publishing Extensions

### 1. Package Structure

```
my-claude-extension/
├── README.md
├── LICENSE
├── install.sh
├── src/
│   └── my-extension.sh
├── lib/
│   └── helpers.sh
└── test/
    └── test.sh
```

### 2. Installation Script

```bash
#!/bin/bash
# install.sh for extension

EXTENSION_NAME="my-extension"
INSTALL_DIR="${CLAUDE_EXTENSION_DIR:-$HOME/.claude-flow/extensions}"

install_extension() {
    ensure_directory "$INSTALL_DIR"
    
    # Copy files
    cp -r src/* "$INSTALL_DIR/"
    
    # Make executable
    chmod +x "$INSTALL_DIR"/*.sh
    
    # Register extension
    echo "$EXTENSION_NAME" >> "$HOME/.claude-flow/extensions.list"
    
    log_success "Extension installed: $EXTENSION_NAME"
}

install_extension
```

### 3. Documentation

Create comprehensive documentation:

- Installation instructions
- Configuration options
- Usage examples
- API reference
- Troubleshooting guide

## Future Extensibility

Consider these areas for future extensions:

1. **IDE Integrations** - VS Code, IntelliJ, etc.
2. **Cloud Sync** - Sync templates and settings
3. **Team Features** - Shared configurations
4. **Analytics** - Usage tracking and insights
5. **AI Enhancements** - Smart template selection