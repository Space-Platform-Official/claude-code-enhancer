# Debugging Guide - Claude Flow

This comprehensive guide provides debugging techniques and tools for troubleshooting Claude Flow issues.

## Table of Contents

1. [Debug Mode and Logging](#debug-mode-and-logging)
2. [Diagnostic Scripts](#diagnostic-scripts)
3. [Common Debugging Scenarios](#common-debugging-scenarios)
4. [System Analysis Tools](#system-analysis-tools)
5. [Script Debugging Techniques](#script-debugging-techniques)
6. [Network and Permission Issues](#network-and-permission-issues)
7. [Creating Debug Reports](#creating-debug-reports)

## Debug Mode and Logging

### Enabling Debug Mode

```bash
# Method 1: Environment variables
export CLAUDE_DEBUG=1
export CLAUDE_VERBOSE=1
export CLAUDE_LOG_LEVEL=debug

# Method 2: Script flags
bash -x ./install.sh --user  # Shell debug mode
bash -v ./install.sh --user  # Verbose mode

# Method 3: Combined debugging
CLAUDE_DEBUG=1 bash -x ./install.sh --user 2>&1 | tee debug.log
```

### Debug Output Levels

```bash
# Create debug wrapper script
cat << 'EOF' > debug-claude.sh
#!/bin/bash

# Set debug levels
export CLAUDE_DEBUG="${CLAUDE_DEBUG:-1}"
export CLAUDE_LOG_FILE="${CLAUDE_LOG_FILE:-claude-debug.log}"

# Function to log with timestamps
log_debug() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] DEBUG: $*" | tee -a "$CLAUDE_LOG_FILE"
}

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*" | tee -a "$CLAUDE_LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$CLAUDE_LOG_FILE" >&2
}

# Wrap the actual command
log_info "Starting Claude Flow with debug mode"
log_debug "Environment: $(env | grep CLAUDE)"
log_debug "Arguments: $*"

# Execute with full debugging
set -x
"$@"
exit_code=$?
set +x

log_info "Completed with exit code: $exit_code"
exit $exit_code
EOF

chmod +x debug-claude.sh

# Use it
./debug-claude.sh claude-install-flow
```

### Logging Configuration

```bash
# Create logging configuration
cat << 'EOF' > .claude-debug.conf
# Claude Flow Debug Configuration
CLAUDE_DEBUG=1
CLAUDE_VERBOSE=1
CLAUDE_LOG_LEVEL=debug
CLAUDE_LOG_FILE="/tmp/claude-flow-debug.log"
CLAUDE_TRACE_FUNCTIONS=1
CLAUDE_SHOW_TIMESTAMPS=1
CLAUDE_COLOR_OUTPUT=1
EOF

# Source before running
source .claude-debug.conf
claude-install-flow
```

## Diagnostic Scripts

### Comprehensive System Check

```bash
cat << 'EOF' > claude-diagnostics.sh
#!/bin/bash

echo "=== Claude Flow Diagnostics ==="
echo "Date: $(date)"
echo "User: $USER"
echo "Shell: $SHELL"
echo "PWD: $PWD"
echo

# System Information
echo "=== System Information ==="
uname -a
echo "Bash version: $BASH_VERSION"
echo

# Environment Check
echo "=== Environment Variables ==="
env | grep -i claude | sort
echo

# Path Analysis
echo "=== PATH Analysis ==="
echo "Full PATH: $PATH"
echo
echo "Claude commands in PATH:"
which claude-install-flow 2>/dev/null || echo "  claude-install-flow: NOT FOUND"
which claude-merge 2>/dev/null || echo "  claude-merge: NOT FOUND"
echo

# Installation Check
echo "=== Installation Locations ==="
for loc in ~/.local/bin /usr/local/bin; do
    echo "Checking $loc:"
    ls -la "$loc"/claude-* 2>/dev/null || echo "  No Claude commands found"
done
echo

# Template Locations
echo "=== Template Locations ==="
for loc in ~/.local/share/claude-flow /usr/local/share/claude-flow; do
    if [ -d "$loc" ]; then
        echo "Found: $loc"
        find "$loc" -type f -name "*.md" | wc -l | xargs echo "  Total .md files:"
        du -sh "$loc" 2>/dev/null | awk '{print "  Total size: " $1}'
    else
        echo "Not found: $loc"
    fi
done
echo

# Permission Check
echo "=== Permission Check ==="
for file in ~/.local/bin/claude-* /usr/local/bin/claude-*; do
    if [ -f "$file" ]; then
        ls -l "$file" | awk '{print $1, $9}'
        file "$file" | sed 's/^/  /'
    fi
done
echo

# Dependency Check
echo "=== Dependencies ==="
for cmd in git npm node bash; do
    if command -v $cmd >/dev/null 2>&1; then
        echo "✓ $cmd: $(command -v $cmd) ($(${cmd} --version 2>&1 | head -1))"
    else
        echo "✗ $cmd: NOT FOUND"
    fi
done
echo

# Recent Errors
echo "=== Recent Errors (if any) ==="
if [ -f "$CLAUDE_LOG_FILE" ]; then
    grep -i error "$CLAUDE_LOG_FILE" | tail -10
else
    echo "No log file found"
fi
EOF

chmod +x claude-diagnostics.sh
./claude-diagnostics.sh > diagnostics-report.txt
```

### Installation Verification

```bash
cat << 'EOF' > verify-install.sh
#!/bin/bash

ERRORS=0
WARNINGS=0

check_pass() {
    echo "✓ $1"
}

check_fail() {
    echo "✗ $1"
    ((ERRORS++))
}

check_warn() {
    echo "⚠ $1"
    ((WARNINGS++))
}

echo "=== Claude Flow Installation Verification ==="
echo

# Check commands
echo "Checking commands..."
for cmd in claude-install-flow claude-merge; do
    if command -v "$cmd" >/dev/null 2>&1; then
        check_pass "$cmd installed at $(which $cmd)"
        
        # Check if executable
        if [ -x "$(which $cmd)" ]; then
            check_pass "$cmd is executable"
        else
            check_fail "$cmd is not executable"
        fi
        
        # Check if it's a valid script
        if head -1 "$(which $cmd)" | grep -q '^#!/'; then
            check_pass "$cmd has valid shebang"
        else
            check_warn "$cmd might not have proper shebang"
        fi
    else
        check_fail "$cmd not found in PATH"
    fi
done
echo

# Check templates
echo "Checking templates..."
TEMPLATE_DIR=""
for dir in ~/.local/share/claude-flow/templates /usr/local/share/claude-flow/templates; do
    if [ -d "$dir" ]; then
        TEMPLATE_DIR="$dir"
        check_pass "Template directory found: $dir"
        break
    fi
done

if [ -z "$TEMPLATE_DIR" ]; then
    check_fail "No template directory found"
else
    # Check essential template files
    essential_files=(
        "CLAUDE.md"
        "commands/architect.md"
        "commands/debug.md"
    )
    
    for file in "${essential_files[@]}"; do
        if [ -f "$TEMPLATE_DIR/$file" ]; then
            check_pass "Essential template: $file"
        else
            check_fail "Missing essential template: $file"
        fi
    done
fi
echo

# Summary
echo "=== Summary ==="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"

if [ $ERRORS -eq 0 ]; then
    echo "✓ Installation appears to be working correctly"
    exit 0
else
    echo "✗ Installation has issues that need to be fixed"
    exit 1
fi
EOF

chmod +x verify-install.sh
./verify-install.sh
```

## Common Debugging Scenarios

### Scenario 1: Script Hangs or Doesn't Respond

```bash
# Debug hanging script
timeout 30 bash -x ./install.sh --user 2>&1 | tee hang-debug.log

# Find where it hangs
tail -20 hang-debug.log

# Common causes and fixes:
# 1. Waiting for user input
echo "y" | ./install.sh --user

# 2. Network issues
export NO_NETWORK_CHECK=1
./install.sh --user

# 3. File system issues
strace -f ./install.sh --user 2>&1 | grep -E "open|read|write"
```

### Scenario 2: Unexpected Behavior

```bash
# Trace function calls
cat << 'EOF' > trace-functions.sh
#!/bin/bash

# Enable function tracing
set -o functrace
trap 'echo "[TRACE] ${BASH_SOURCE[1]}:${BASH_LINENO[0]}:${FUNCNAME[1]}()"' DEBUG

# Source and run the script
source ./install-claude-flow.sh
# Script will now trace all function calls
EOF

chmod +x trace-functions.sh
```

### Scenario 3: Variable Issues

```bash
# Debug variable values
cat << 'EOF' > debug-vars.sh
#!/bin/bash

# Function to print all variables
debug_vars() {
    echo "=== Variable Dump ==="
    echo "SCRIPT_DIR: ${SCRIPT_DIR:-unset}"
    echo "CLAUDE_TEMPLATES_DIR: ${CLAUDE_TEMPLATES_DIR:-unset}"
    echo "PATH: $PATH"
    echo "HOME: $HOME"
    echo "USER: $USER"
    echo "PWD: $PWD"
    echo "BASH_VERSION: $BASH_VERSION"
    echo "===================="
}

# Inject into script
sed -i.bak '1a source debug-vars.sh' install-claude-flow.sh
sed -i '20a debug_vars' install-claude-flow.sh

# Run modified script
./install-claude-flow.sh

# Restore original
mv install-claude-flow.sh.bak install-claude-flow.sh
EOF
```

## System Analysis Tools

### File System Analysis

```bash
# Check file system issues
cat << 'EOF' > fs-check.sh
#!/bin/bash

echo "=== File System Check ==="

# Check disk space
echo "Disk space:"
df -h ~ | grep -v Filesystem

# Check inodes
echo -e "\nInode usage:"
df -i ~ | grep -v Filesystem

# Check permissions on key directories
echo -e "\nDirectory permissions:"
for dir in ~ ~/.local ~/.local/bin ~/.local/share; do
    if [ -e "$dir" ]; then
        stat -c "%n: %a %U:%G" "$dir" 2>/dev/null || \
        stat -f "%N: %Mp%Lp %Su:%Sg" "$dir" 2>/dev/null
    else
        echo "$dir: DOES NOT EXIST"
    fi
done

# Check for symbolic links
echo -e "\nSymbolic links:"
for file in ~/.local/bin/claude-*; do
    if [ -L "$file" ]; then
        echo "$file -> $(readlink "$file")"
    fi
done

# Check for file locks
echo -e "\nFile locks:"
lsof | grep claude 2>/dev/null || echo "No file locks found"
EOF

chmod +x fs-check.sh
./fs-check.sh
```

### Process Analysis

```bash
# Monitor script execution
cat << 'EOF' > monitor-execution.sh
#!/bin/bash

SCRIPT_TO_MONITOR="$1"
if [ -z "$SCRIPT_TO_MONITOR" ]; then
    echo "Usage: $0 <script-to-monitor>"
    exit 1
fi

# Start monitoring in background
(
    while true; do
        ps aux | grep -v grep | grep "$SCRIPT_TO_MONITOR" > /tmp/claude-ps.log
        sleep 1
    done
) &
MONITOR_PID=$!

# Run the script
bash -x "$SCRIPT_TO_MONITOR" "${@:2}"
EXIT_CODE=$?

# Stop monitoring
kill $MONITOR_PID 2>/dev/null

echo "Script exited with code: $EXIT_CODE"
echo "Process log saved to: /tmp/claude-ps.log"
EOF

chmod +x monitor-execution.sh
./monitor-execution.sh ./install.sh --user
```

## Script Debugging Techniques

### Break Points

```bash
# Add breakpoints to scripts
cat << 'EOF' > add-breakpoints.sh
#!/bin/bash

# Function to add as breakpoint
breakpoint() {
    echo "[BREAKPOINT] $1"
    echo "Press Enter to continue, or Ctrl+C to exit"
    read -r
}

# Example usage in your script:
# breakpoint "Before installing files"
# install_files

# Add to specific line numbers
sed -i '50i breakpoint "At line 50"' install-claude-flow.sh
sed -i '100i breakpoint "At line 100"' install-claude-flow.sh
EOF
```

### Conditional Debugging

```bash
# Add conditional debug output
cat << 'EOF' >> ~/.bashrc
claude_debug() {
    if [[ "${CLAUDE_DEBUG}" == "1" ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

claude_trace() {
    if [[ "${CLAUDE_TRACE}" == "1" ]]; then
        set -x
        "$@"
        set +x
    else
        "$@"
    fi
}
EOF

# Usage in scripts:
# claude_debug "Variable X = $X"
# claude_trace complex_function
```

## Network and Permission Issues

### Network Debugging

```bash
# Test network connectivity
cat << 'EOF' > test-network.sh
#!/bin/bash

echo "=== Network Connectivity Test ==="

# Test DNS
echo "Testing DNS resolution..."
for host in github.com npmjs.com google.com; do
    if host "$host" >/dev/null 2>&1; then
        echo "✓ Can resolve $host"
    else
        echo "✗ Cannot resolve $host"
    fi
done

# Test HTTPS
echo -e "\nTesting HTTPS connectivity..."
for url in https://github.com https://npmjs.com; do
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200\|301\|302"; then
        echo "✓ Can reach $url"
    else
        echo "✗ Cannot reach $url"
    fi
done

# Test proxy settings
echo -e "\nProxy settings:"
env | grep -i proxy || echo "No proxy configured"
EOF

chmod +x test-network.sh
./test-network.sh
```

### Permission Debugging

```bash
# Comprehensive permission check
cat << 'EOF' > check-permissions.sh
#!/bin/bash

echo "=== Permission Debugging ==="

# Current user info
echo "User info:"
id
echo

# Check sudo access
echo "Sudo access:"
sudo -n true 2>/dev/null && echo "✓ Has passwordless sudo" || echo "✗ No passwordless sudo"
echo

# Directory permissions
echo "Directory permissions:"
for dir in ~/.local ~/.local/bin ~/.local/share /usr/local /usr/local/bin; do
    if [ -d "$dir" ]; then
        echo -n "$dir: "
        [ -r "$dir" ] && echo -n "R" || echo -n "-"
        [ -w "$dir" ] && echo -n "W" || echo -n "-"
        [ -x "$dir" ] && echo -n "X" || echo -n "-"
        echo " ($(stat -c %a "$dir" 2>/dev/null || stat -f %A "$dir"))"
    else
        echo "$dir: DOES NOT EXIST"
    fi
done
echo

# SELinux/AppArmor check
echo "Security modules:"
if command -v getenforce >/dev/null 2>&1; then
    echo "SELinux: $(getenforce)"
elif [ -f /sys/kernel/security/apparmor/profiles ]; then
    echo "AppArmor: enabled"
else
    echo "No security modules detected"
fi
EOF

chmod +x check-permissions.sh
./check-permissions.sh
```

## Creating Debug Reports

### Automated Debug Report Generator

```bash
cat << 'EOF' > generate-debug-report.sh
#!/bin/bash

REPORT_FILE="claude-flow-debug-$(date +%Y%m%d-%H%M%S).txt"

echo "Generating debug report: $REPORT_FILE"

{
    echo "=== Claude Flow Debug Report ==="
    echo "Generated: $(date)"
    echo "Version: $(git describe --tags 2>/dev/null || echo "unknown")"
    echo
    
    echo "=== System Information ==="
    uname -a
    echo "Shell: $SHELL ($BASH_VERSION)"
    echo
    
    echo "=== Environment ==="
    env | grep -i claude | sort
    echo
    
    echo "=== Installation Status ==="
    ./verify-install.sh 2>&1
    echo
    
    echo "=== File System ==="
    ./fs-check.sh 2>&1
    echo
    
    echo "=== Recent Errors ==="
    find /tmp -name "*claude*.log" -mtime -1 -exec echo "Log file: {}" \; -exec tail -20 {} \; 2>/dev/null
    echo
    
    echo "=== Diagnostic Output ==="
    ./claude-diagnostics.sh 2>&1
    
} > "$REPORT_FILE"

echo "Debug report generated: $REPORT_FILE"
echo "Share this file when reporting issues"

# Create compressed version
tar -czf "${REPORT_FILE%.txt}.tar.gz" "$REPORT_FILE" *.log 2>/dev/null

echo "Compressed report: ${REPORT_FILE%.txt}.tar.gz"
EOF

chmod +x generate-debug-report.sh
./generate-debug-report.sh
```

### Manual Debug Checklist

When debugging manually, collect:

1. **System Information**
   ```bash
   uname -a > debug-info.txt
   echo $SHELL >> debug-info.txt
   bash --version >> debug-info.txt
   ```

2. **Error Messages**
   ```bash
   # Capture full error output
   script -c "./install.sh --user" install-output.log
   ```

3. **Environment State**
   ```bash
   env | sort > environment.txt
   set > shell-vars.txt
   ```

4. **File States**
   ```bash
   find ~/.local -name "*claude*" -ls > claude-files.txt
   ```

5. **Process State**
   ```bash
   ps aux > processes.txt
   lsof > open-files.txt
   ```

## Debug Mode Best Practices

1. **Always use version control** before debugging
   ```bash
   git init
   git add .
   git commit -m "Before debugging"
   ```

2. **Isolate the problem**
   ```bash
   # Test minimal case
   CLAUDE_MINIMAL=1 ./install.sh --user
   ```

3. **Use systematic approach**
   - Reproduce consistently
   - Isolate variables
   - Test hypotheses
   - Document findings

4. **Clean up after debugging**
   ```bash
   # Remove debug files
   rm -f *.log *.bak debug-*.txt
   unset CLAUDE_DEBUG CLAUDE_VERBOSE
   ```

## Getting Support

When reporting issues, include:

1. Output of `./generate-debug-report.sh`
2. Steps to reproduce
3. Expected vs actual behavior
4. Any workarounds attempted
5. System-specific details

Debug report should be attached to GitHub issues or support requests.