# Claude Flow Exit Codes Reference

This document provides a comprehensive reference for all exit codes used by Claude Flow scripts.

## Table of Contents

- [Standard Exit Codes](#standard-exit-codes)
- [Script-Specific Exit Codes](#script-specific-exit-codes)
- [Error Categories](#error-categories)
- [Signal Handling](#signal-handling)
- [Best Practices](#best-practices)

## Standard Exit Codes

All Claude Flow scripts follow these standard exit codes:

| Code | Constant | Description | Example Scenario |
|------|----------|-------------|------------------|
| `0` | SUCCESS | Command completed successfully | Installation completed, merge successful |
| `1` | ERROR | General error | File not found, permission denied, invalid argument |
| `130` | SIGINT | Script interrupted by Ctrl+C | User pressed Ctrl+C during execution |
| `143` | SIGTERM | Script terminated by SIGTERM | Process killed by system or user |

## Script-Specific Exit Codes

### install.sh

| Exit Scenario | Code | Description |
|---------------|------|-------------|
| Successful installation | `0` | All files installed correctly |
| Successful uninstallation | `0` | All files removed |
| Unknown option | `1` | Invalid command-line argument |
| Source file not found | `1` | Missing install-claude-flow.sh or smart-merge-claude.sh |
| Templates directory missing | `1` | Templates directory not found |
| Permission denied | `1` | Cannot write to installation directory |
| Help displayed | `0` | --help option used |

**Example Usage:**
```bash
./install.sh --user
if [ $? -eq 0 ]; then
    echo "Installation successful"
else
    echo "Installation failed"
fi
```

### install-claude-flow.sh

| Exit Scenario | Code | Description |
|---------------|------|-------------|
| Successful merge | `0` | All operations completed |
| npm not found | `1` | Node.js/npm not installed |
| npm install failed | `1` | Failed to install claude-flow package |
| Template directory not found | `1` | No valid templates directory |
| Source file missing | `1` | Required template files not found |
| Write permission denied | `1` | Cannot create directories or files |
| User cancelled merge | `0` | User chose to skip files |
| Shell environment error | `1` | Version manager interference |

**Signal Handling:**
```bash
# Script sets up signal handlers
trap 'exit_handler $?' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
```

### smart-merge-claude.sh

| Exit Scenario | Code | Description |
|---------------|------|-------------|
| Successful merge | `0` | CLAUDE.md merged and commands set up |
| Invalid arguments | `1` | Too many arguments provided |
| Target directory not found | `1` | Specified directory doesn't exist |
| Templates directory not found | `1` | No valid templates location |
| No CLAUDE.md found | `1` | Neither current nor template CLAUDE.md exists |
| Write permission denied | `1` | Cannot write to target directory |

## Error Categories

### File System Errors

**Exit Code: 1**

Common scenarios:
- File not found
- Directory not found
- Permission denied
- Disk full
- Read-only file system

**Examples:**
```bash
# Check for file existence
if [[ ! -f "$source_file" ]]; then
    print_error "Source file not found: $source_file"
    exit 1
fi

# Check directory permissions
if [[ ! -w "$target_dir" ]]; then
    print_error "No write permission: $target_dir"
    exit 1
fi
```

### Dependency Errors

**Exit Code: 1**

Common scenarios:
- Required command not found (npm)
- Package installation failed
- Version mismatch

**Examples:**
```bash
# Check for npm
if ! command -v npm >/dev/null 2>&1; then
    print_error "npm is not installed"
    exit 1
fi
```

### User Input Errors

**Exit Code: 1**

Common scenarios:
- Invalid command-line arguments
- Missing required parameters
- Invalid option values

**Examples:**
```bash
# Validate arguments
if [[ $# -gt 1 ]]; then
    echo "Usage: $0 [target-directory]"
    exit 1
fi
```

### Environment Errors

**Exit Code: 1**

Common scenarios:
- Shell function conflicts
- PATH issues
- Missing environment variables

**Detection:**
```bash
# Detect problematic environment
if command -v gvm >/dev/null 2>&1; then
    print_warning "Detected gvm in environment"
fi
```

## Signal Handling

### SIGINT (Ctrl+C) - Exit Code 130

Triggered when user presses Ctrl+C.

**Implementation:**
```bash
trap 'exit 130' INT
```

**Behavior:**
- Immediately stops current operation
- Performs minimal cleanup
- Returns exit code 130

### SIGTERM - Exit Code 143

Triggered by system shutdown or kill command.

**Implementation:**
```bash
trap 'exit 143' TERM
```

**Behavior:**
- Gracefully stops operation
- Performs cleanup if possible
- Returns exit code 143

### EXIT Handler

Runs on any exit (success or failure).

**Implementation:**
```bash
exit_handler() {
    local exit_code=$1
    if [[ $exit_code -ne 0 ]]; then
        print_error "Script failed with exit code $exit_code"
    fi
}
trap 'exit_handler $?' EXIT
```

## Best Practices

### Consistent Exit Code Usage

1. **Always use standard codes**
   ```bash
   # Good
   exit 1  # For errors
   exit 0  # For success
   
   # Bad
   exit 2  # Non-standard error code
   ```

2. **Exit immediately on critical errors**
   ```bash
   if [[ ! -d "$required_dir" ]]; then
       print_error "Required directory not found"
       exit 1
   fi
   ```

3. **Use exit codes in functions**
   ```bash
   validate_input() {
       if [[ -z "$1" ]]; then
           return 1  # Function failure
       fi
       return 0  # Function success
   }
   ```

### Error Propagation

1. **Check command success**
   ```bash
   if ! install_claude_flow; then
       print_error "Installation failed"
       exit 1
   fi
   ```

2. **Use set -e for automatic exits**
   ```bash
   set -e  # Exit on any command failure
   ```

3. **Handle pipeline failures**
   ```bash
   set -o pipefail  # Pipeline returns failure if any command fails
   ```

### Testing Exit Codes

1. **Direct testing**
   ```bash
   ./install.sh --user
   echo "Exit code: $?"
   ```

2. **Conditional execution**
   ```bash
   ./install.sh && echo "Success" || echo "Failed"
   ```

3. **Automated testing**
   ```bash
   #!/bin/bash
   test_exit_codes() {
       # Test successful execution
       ./install.sh --help
       [ $? -eq 0 ] || echo "FAIL: --help should return 0"
       
       # Test error conditions
       ./install.sh --invalid 2>/dev/null
       [ $? -eq 1 ] || echo "FAIL: Invalid option should return 1"
   }
   ```

### Documentation

Always document non-standard behavior:

```bash
# This function returns:
# 0 - Success
# 1 - General error
# 2 - Specific condition (document why)
custom_function() {
    # ... implementation
}
```

## Exit Code Reference Table

| Code | Name | Description | Common Use |
|------|------|-------------|------------|
| 0 | SUCCESS | Successful completion | Normal termination |
| 1 | ERROR | General errors | Catch-all for errors |
| 2 | MISUSE | Misuse of shell builtin | Incorrect usage (rare) |
| 126 | NOPERM | Command cannot execute | Permission problem |
| 127 | NOTFOUND | Command not found | Missing program |
| 128 | INVALID | Invalid argument to exit | exit 3.14159 |
| 128+n | SIGNAL | Fatal signal "n" | kill -9 $PPID (128+9=137) |
| 130 | SIGINT | Terminated by Ctrl+C | User interruption |
| 143 | SIGTERM | Terminated by SIGTERM | Process termination |
| 255 | OUTOFRANGE | Exit status out of range | exit -1 |

**Note:** Claude Flow scripts primarily use codes 0, 1, 130, and 143 for consistency.