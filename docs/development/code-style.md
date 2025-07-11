# Code Style Guide for Claude Flow

This guide defines coding standards and conventions for contributing to Claude Flow. Following these guidelines ensures consistency and maintainability across the project.

## Shell Script Standards

### File Structure

```bash
#!/bin/bash
# Script: script-name.sh
# Purpose: Brief description of what the script does
# Usage: script-name.sh [options] [arguments]
# Author: Your Name
# Date: YYYY-MM-DD

# 1. Shebang and header
# 2. Shell options
# 3. Global variables and constants
# 4. Function definitions
# 5. Main logic
# 6. Script execution
```

### Shell Options

Always use strict error handling:

```bash
set -euo pipefail

# Explanation:
# -e: Exit on error
# -u: Exit on undefined variable
# -o pipefail: Exit on pipe failure
```

### Naming Conventions

#### Files
```bash
# Use lowercase with hyphens
install-claude-flow.sh      # ✓ Good
InstallClaudeFlow.sh       # ✗ Bad
install_claude_flow.sh     # ✗ Bad
```

#### Variables
```bash
# Constants: UPPERCASE with underscores
readonly SCRIPT_VERSION="1.0.0"
readonly DEFAULT_TIMEOUT=30

# Local variables: lowercase with underscores
local file_path="/tmp/test"
local user_input=""

# Global variables: lowercase with underscores, prefixed if needed
claude_template_dir=""
claude_config_file=""
```

#### Functions
```bash
# Use lowercase with underscores
# Be descriptive and use verb_noun pattern

print_error() {
    # Good: Clear purpose
}

validate_input() {
    # Good: Action-oriented
}

process_templates() {
    # Good: Descriptive
}

# Avoid abbreviations
proc_tpl() {
    # Bad: Unclear
}
```

### Indentation and Spacing

Use 4 spaces for indentation (no tabs):

```bash
# Good
if [[ -f "$file" ]]; then
    echo "File exists"
    if [[ -r "$file" ]]; then
        echo "File is readable"
    fi
fi

# Bad (using tabs or inconsistent spacing)
if [[ -f "$file" ]]; then
	echo "File exists"
  if [[ -r "$file" ]]; then
        echo "File is readable"
  fi
fi
```

### Line Length

Keep lines under 80-100 characters:

```bash
# Good: Break long lines
echo "This is a very long message that would exceed our line limit" \
     "so we break it into multiple lines for better readability"

# Good: Use variables for long strings
local error_message="The specified template directory does not exist. " \
                   "Please check your CLAUDE_TEMPLATES_DIR environment variable."

# Bad: Too long
echo "This is a very long message that exceeds our line limit and makes the code harder to read and maintain in standard terminal windows"
```

## Bash Best Practices

### Quoting

Always quote variables to prevent word splitting:

```bash
# Good
echo "Path: $file_path"
rm -f "$temp_file"
if [[ -n "$variable" ]]; then

# Bad
echo Path: $file_path
rm -f $temp_file
if [[ -n $variable ]]; then
```

### Command Substitution

Use `$()` instead of backticks:

```bash
# Good
current_dir="$(pwd)"
file_count=$(find . -type f | wc -l)

# Bad
current_dir=`pwd`
file_count=`find . -type f | wc -l`
```

### Conditionals

Use `[[` instead of `[` for conditionals:

```bash
# Good
if [[ -f "$file" ]]; then
if [[ "$var1" == "$var2" ]]; then
if [[ -z "$string" ]]; then

# Bad
if [ -f "$file" ]; then
if [ "$var1" = "$var2" ]; then
if test -z "$string"; then
```

### Functions

Define functions before use:

```bash
# Good: Function definition
print_usage() {
    cat << EOF
Usage: $0 [OPTIONS]
Options:
    -h, --help     Show this help message
    -v, --version  Show version
EOF
}

# Good: Local variables
process_file() {
    local file="$1"
    local output="$2"
    
    # Function logic here
}

# Good: Return values
validate_path() {
    local path="$1"
    
    if [[ ! -d "$path" ]]; then
        return 1
    fi
    
    return 0
}
```

### Error Handling

Always handle errors gracefully:

```bash
# Good: Check command success
if ! command -v git &>/dev/null; then
    error_exit "Git is not installed"
fi

# Good: Trap for cleanup
cleanup() {
    rm -f "$temp_file"
    echo "Cleanup completed"
}
trap cleanup EXIT

# Good: Explicit error messages
error_exit() {
    echo "Error: $1" >&2
    exit "${2:-1}"
}
```

## Documentation Standards

### Inline Comments

```bash
# Good: Explain why, not what
# Use a temporary file to avoid partial writes corrupting the target
temp_file=$(mktemp)

# Bad: Obvious comment
# Set x to 5
x=5

# Good: Complex logic explanation
# We need to check both conditions because the file might exist
# but be empty, which would cause issues later in processing
if [[ -f "$config" ]] && [[ -s "$config" ]]; then
```

### Function Documentation

```bash
# Good: Document complex functions
# Merges two CLAUDE.md files intelligently
# Arguments:
#   $1 - Source file path
#   $2 - Target file path
#   $3 - Output file path (optional, defaults to stdout)
# Returns:
#   0 - Success
#   1 - Source file not found
#   2 - Target file not found
#   3 - Write permission denied
merge_claude_files() {
    local source="$1"
    local target="$2"
    local output="${3:-/dev/stdout}"
    
    # Implementation
}
```

## Code Organization

### Script Structure

```bash
#!/bin/bash
# Header and metadata

# 1. Shell options and error handling
set -euo pipefail
trap 'cleanup' EXIT

# 2. Constants and configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 3. Global variables
template_dir=""
verbose=false

# 4. Utility functions
error_exit() {
    echo "Error: $1" >&2
    exit "${2:-1}"
}

# 5. Core functions
process_templates() {
    # Main logic
}

# 6. Argument parsing
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                verbose=true
                shift
                ;;
            *)
                error_exit "Unknown option: $1"
                ;;
        esac
    done
}

# 7. Main function
main() {
    parse_arguments "$@"
    process_templates
}

# 8. Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Modular Design

Split large scripts into modules:

```bash
# lib/common.sh - Shared functions
source_lib() {
    local lib_file="$1"
    local lib_path="${SCRIPT_DIR}/lib/${lib_file}"
    
    if [[ -f "$lib_path" ]]; then
        source "$lib_path"
    else
        error_exit "Library not found: $lib_file"
    fi
}

# Main script
source_lib "common.sh"
source_lib "template-utils.sh"
```

## Testing Conventions

### Test Function Names

```bash
# Good: Descriptive test names
test_fresh_installation() {
    # Test implementation
}

test_merge_conflict_resolution() {
    # Test implementation
}

test_error_handling_missing_file() {
    # Test implementation
}

# Bad: Unclear names
test1() {
    # What does this test?
}
```

### Test Structure

```bash
# Setup
setup_test_environment() {
    test_dir=$(mktemp -d)
    cd "$test_dir"
}

# Test execution
run_test() {
    local test_name="$1"
    print_test "Running: $test_name"
    
    if "$test_name"; then
        print_success "$test_name passed"
    else
        print_error "$test_name failed"
        ((failures++))
    fi
}

# Cleanup
cleanup_test_environment() {
    cd "$original_dir"
    rm -rf "$test_dir"
}
```

## Security Considerations

### Input Validation

Always validate user input:

```bash
# Good: Validate before use
validate_directory() {
    local dir="$1"
    
    # Check if path is absolute
    if [[ "$dir" != /* ]]; then
        error_exit "Path must be absolute: $dir"
    fi
    
    # Check for path traversal
    if [[ "$dir" == *".."* ]]; then
        error_exit "Path traversal not allowed: $dir"
    fi
    
    # Check existence and permissions
    if [[ ! -d "$dir" ]]; then
        error_exit "Directory not found: $dir"
    fi
    
    if [[ ! -r "$dir" ]]; then
        error_exit "No read permission: $dir"
    fi
}
```

### Safe File Operations

```bash
# Good: Use mktemp for temporary files
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

# Good: Check permissions before writing
if [[ -w "$(dirname "$output_file")" ]]; then
    echo "$content" > "$output_file"
else
    error_exit "Cannot write to: $output_file"
fi

# Good: Avoid eval
# Bad
eval "$user_command"

# Good
case "$user_command" in
    start|stop|restart)
        "$user_command"_service
        ;;
    *)
        error_exit "Invalid command"
        ;;
esac
```

## Performance Guidelines

### Efficient Commands

```bash
# Good: Use built-in commands when possible
if [[ -f "$file" ]]; then
    # Faster than calling external 'test'
fi

# Good: Avoid useless cats
# Bad
cat file.txt | grep pattern

# Good
grep pattern file.txt

# Good: Use appropriate tools
# For simple operations
while IFS= read -r line; do
    echo "Processing: $line"
done < input.txt

# For complex operations, consider awk/sed
awk '{print $1}' input.txt
```

### Process Substitution

```bash
# Good: Avoid temporary files
diff <(sort file1.txt) <(sort file2.txt)

# Instead of
sort file1.txt > temp1.txt
sort file2.txt > temp2.txt
diff temp1.txt temp2.txt
rm temp1.txt temp2.txt
```

## Common Patterns

### Configuration Files

```bash
# Default configuration with overrides
load_config() {
    # System defaults
    source /etc/claude-flow/config 2>/dev/null || true
    
    # User overrides
    source ~/.claude-flow/config 2>/dev/null || true
    
    # Environment overrides
    [[ -n "${CLAUDE_TEMPLATE_DIR:-}" ]] && template_dir="$CLAUDE_TEMPLATE_DIR"
}
```

### User Interaction

```bash
# Good: Clear prompts
prompt_user() {
    local prompt="$1"
    local default="$2"
    local response
    
    if [[ -n "$default" ]]; then
        read -r -p "$prompt [$default]: " response
        echo "${response:-$default}"
    else
        read -r -p "$prompt: " response
        echo "$response"
    fi
}

# Good: Confirmation prompts
confirm() {
    local prompt="${1:-Are you sure?}"
    local response
    
    read -r -p "$prompt [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
```

## Code Review Checklist

Before submitting code, verify:

- [ ] Scripts pass shellcheck without warnings
- [ ] Variables are properly quoted
- [ ] Error handling is comprehensive
- [ ] Functions have clear names and documentation
- [ ] Code follows indentation standards
- [ ] No hardcoded paths (use variables)
- [ ] Temporary files are cleaned up
- [ ] User input is validated
- [ ] Comments explain why, not what
- [ ] Tests cover new functionality

## Tools and Linters

### ShellCheck

Install and use ShellCheck:

```bash
# Install
brew install shellcheck  # macOS
apt-get install shellcheck  # Debian/Ubuntu

# Run on scripts
shellcheck *.sh

# Add to editor
# VS Code: Install ShellCheck extension
# Vim: Use ALE or syntastic
```

### Formatting Tools

```bash
# shfmt for consistent formatting
shfmt -i 4 -w script.sh  # 4-space indent, write in place

# EditorConfig for cross-editor consistency
# .editorconfig
[*.sh]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
```

## Conclusion

Following these style guidelines ensures that Claude Flow remains maintainable, reliable, and accessible to contributors. When in doubt, prioritize readability and safety over cleverness or brevity.