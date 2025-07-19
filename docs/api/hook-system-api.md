# Claude Code Enhancer Hook System API

Comprehensive reference for the Claude Code Enhancer hook system, enabling custom extensions and workflow automation.

## Table of Contents

- [Overview](#overview)
- [Hook Types](#hook-types)
- [Hook Configuration](#hook-configuration)
- [Hook Script Format](#hook-script-format)
- [Hook Context and Environment](#hook-context-and-environment)
- [Pre-Command Hooks](#pre-command-hooks)
- [Post-Command Hooks](#post-command-hooks)
- [Error Hooks](#error-hooks)
- [Edit Hooks](#edit-hooks)
- [Git Hooks Integration](#git-hooks-integration)
- [Custom Hook Development](#custom-hook-development)
- [Hook Testing](#hook-testing)
- [Performance Considerations](#performance-considerations)
- [Security Guidelines](#security-guidelines)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Overview

The Claude Code Enhancer hook system provides extension points throughout the command execution lifecycle, enabling custom automation, validation, and integration with external tools.

### Hook System Architecture

```
Command Execution Flow:
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Pre-Command    │───▶│  Command Execute │───▶│  Post-Command   │
│     Hooks       │    │                  │    │     Hooks       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Validation    │    │   Error Hooks    │    │   Cleanup       │
│   Setup         │    │   (on failure)   │    │   Notifications │
│   Preparation   │    │                  │    │   Reporting     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Hook Capabilities

| Hook Type | Purpose | Timing | Use Cases |
|-----------|---------|---------|-----------|
| **Pre-Command** | Setup and validation | Before command execution | Env setup, validation, backups |
| **Post-Command** | Cleanup and notification | After successful execution | Reporting, cleanup, deployment |
| **Error Hooks** | Error handling | On command failure | Recovery, logging, notifications |
| **Edit Hooks** | File operation hooks | Before/after file edits | Validation, formatting, backup |
| **Git Hooks** | Git integration | Git operations | Quality gates, validation, automation |

## Hook Types

### Hook Execution Order

```yaml
# Hook execution sequence
execution_order:
  1. pre_command_hooks:
     - validation
     - setup
     - backup
  
  2. command_execution:
     - main_command
     - edit_hooks (if file operations)
  
  3. post_command_hooks:
     - cleanup
     - reporting
     - notification
  
  4. error_hooks (if failures):
     - recovery
     - logging
     - alerts
```

### Hook Type Definitions

#### Pre-Command Hooks
```bash
# Executed before any command runs
.claude/hooks/pre-command/
├── 00-validate-environment.sh
├── 10-setup-workspace.sh
├── 20-backup-files.sh
└── 99-final-checks.sh
```

#### Post-Command Hooks
```bash
# Executed after successful command completion
.claude/hooks/post-command/
├── 00-generate-reports.sh
├── 10-update-metrics.sh
├── 20-send-notifications.sh
└── 99-cleanup.sh
```

#### Error Hooks
```bash
# Executed when commands fail
.claude/hooks/error/
├── 00-capture-state.sh
├── 10-attempt-recovery.sh
├── 20-log-error.sh
└── 99-notify-failure.sh
```

#### Edit Hooks
```bash
# Executed around file edit operations
.claude/hooks/edit/
├── pre-edit/
│   ├── 00-backup-file.sh
│   └── 10-validate-permissions.sh
└── post-edit/
    ├── 00-format-file.sh
    ├── 10-validate-syntax.sh
    └── 20-update-index.sh
```

## Hook Configuration

### Global Hook Configuration

```yaml
# .claude/hooks.yaml
hooks:
  version: "1.0"
  
  # Global settings
  global:
    enabled: true
    timeout: 60
    parallel_execution: false
    continue_on_error: false
    environment_isolation: true
    
  # Hook directories (priority order)
  directories:
    - path: ".claude/hooks"
      priority: 1
      enabled: true
    - path: "scripts/claude-hooks"
      priority: 2
      enabled: true
    - path: "~/.config/claude-flow/hooks"
      priority: 3
      enabled: true
      
  # Hook type configuration
  types:
    pre_command:
      enabled: true
      timeout: 30
      parallel: true
      required: false
      
    post_command:
      enabled: true
      timeout: 60
      parallel: false
      required: false
      
    error:
      enabled: true
      timeout: 30
      parallel: false
      required: true
      
    edit:
      pre_edit:
        enabled: true
        timeout: 10
        parallel: true
      post_edit:
        enabled: true
        timeout: 20
        parallel: false
        
  # Command-specific configurations
  commands:
    architect:
      pre_command:
        - script: "validate-project.sh"
          timeout: 15
          required: true
        - script: "backup-config.sh"
          timeout: 10
          
      post_command:
        - script: "update-docs.sh"
          timeout: 30
          
    "quality/*":
      pre_command:
        - script: "quality-setup.sh"
      post_command:
        - script: "quality-report.sh"
        - script: "update-metrics.sh"
        
    "git/*":
      pre_command:
        - script: "git-status-check.sh"
      post_command:
        - script: "git-cleanup.sh"
        
  # Environment variables for hooks
  environment:
    CLAUDE_HOOK_LOG_LEVEL: "info"
    CLAUDE_HOOK_TIMEOUT: "60"
    PROJECT_ROOT: "${PWD}"
    HOOK_DATA_DIR: "${CLAUDE_CACHE_DIR}/hooks"
    
  # Development and debugging
  development:
    debug_mode: false
    verbose_output: false
    dry_run: false
    trace_execution: false
```

### Per-Command Hook Configuration

```yaml
# .claude/commands/architect/hooks.yaml
architect_hooks:
  pre_command:
    - name: "validate_project_structure"
      script: "validate-project-structure.sh"
      timeout: 15
      required: true
      description: "Validate project structure before analysis"
      
    - name: "backup_configuration"
      script: "backup-config.sh"
      timeout: 10
      required: false
      description: "Backup current configuration"
      
  post_command:
    - name: "update_documentation"
      script: "update-architecture-docs.sh"
      timeout: 30
      required: false
      description: "Update architecture documentation"
      
    - name: "generate_diagrams"
      script: "generate-architecture-diagrams.sh"
      timeout: 60
      required: false
      description: "Generate architecture diagrams"
      
  error:
    - name: "recovery_cleanup"
      script: "architect-recovery.sh"
      timeout: 20
      required: true
      description: "Clean up after failed architecture analysis"
```

## Hook Script Format

### Basic Hook Script Structure

```bash
#!/bin/bash
# Hook script template

# Hook metadata (optional)
# HOOK_NAME: validate-environment
# HOOK_VERSION: 1.0
# HOOK_DESCRIPTION: Validate development environment
# HOOK_AUTHOR: Development Team
# HOOK_REQUIREMENTS: bash>=4.0, jq

set -euo pipefail

# Import hook utilities
source "${CLAUDE_HOOK_UTILS:-/usr/local/share/claude-flow/hook-utils.sh}"

# Hook configuration
HOOK_TIMEOUT="${HOOK_TIMEOUT:-30}"
HOOK_LOG_LEVEL="${HOOK_LOG_LEVEL:-info}"

# Main hook function
main() {
    hook_log "info" "Starting environment validation"
    
    # Validate required tools
    validate_tools || {
        hook_error "Required tools not available"
        return 1
    }
    
    # Check project structure
    validate_project_structure || {
        hook_error "Invalid project structure"
        return 1
    }
    
    # Validate configuration
    validate_configuration || {
        hook_error "Configuration validation failed"
        return 1
    }
    
    hook_log "info" "Environment validation completed"
    return 0
}

# Validation functions
validate_tools() {
    local required_tools=("git" "node" "npm")
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            hook_error "Required tool not found: $tool"
            return 1
        fi
        hook_log "debug" "Tool available: $tool"
    done
    
    return 0
}

validate_project_structure() {
    local required_dirs=("src" "tests" "docs")
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            hook_error "Required directory not found: $dir"
            return 1
        fi
        hook_log "debug" "Directory exists: $dir"
    done
    
    return 0
}

validate_configuration() {
    # Check for required configuration files
    local config_files=(".claude/config.yaml" "package.json" ".gitignore")
    
    for file in "${config_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            hook_error "Required configuration file not found: $file"
            return 1
        fi
        hook_log "debug" "Configuration file exists: $file"
    done
    
    # Validate package.json
    if command -v jq >/dev/null 2>&1; then
        if ! jq empty package.json 2>/dev/null; then
            hook_error "Invalid JSON in package.json"
            return 1
        fi
        hook_log "debug" "package.json is valid JSON"
    fi
    
    return 0
}

# Error handling
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        hook_error "Hook failed with exit code: $exit_code"
    fi
    exit $exit_code
}

# Set up error handling
trap cleanup EXIT

# Execute main function
main "$@"
```

### Advanced Hook Script with Context

```bash
#!/bin/bash
# Advanced hook script with full context integration

set -euo pipefail

# Import hook framework
source "${CLAUDE_HOOK_FRAMEWORK}/init.sh"

# Hook metadata
declare -r HOOK_NAME="quality-gate-enforcer"
declare -r HOOK_VERSION="2.1.0"
declare -r HOOK_DESCRIPTION="Enforce quality gates before command execution"

# Configuration
declare -r CONFIG_FILE="${CLAUDE_CONFIG_DIR}/quality-gates.yaml"
declare -r REPORT_FILE="${CLAUDE_CACHE_DIR}/quality-report.json"

main() {
    hook_init "$@"
    
    # Parse hook context
    local command="${CLAUDE_COMMAND}"
    local subcommand="${CLAUDE_SUBCOMMAND}"
    local args=("${CLAUDE_ARGS[@]}")
    
    hook_log "info" "Enforcing quality gates for: $command/$subcommand"
    
    # Load quality configuration
    local quality_config
    quality_config=$(load_quality_config) || {
        hook_error "Failed to load quality configuration"
        return 1
    }
    
    # Check if quality gates are required for this command
    if should_enforce_quality_gates "$command" "$subcommand"; then
        hook_log "info" "Quality gates required for this command"
        
        # Run quality checks
        run_quality_checks || {
            hook_error "Quality gates failed"
            return 1
        }
        
        # Generate quality report
        generate_quality_report || {
            hook_warning "Failed to generate quality report"
        }
    else
        hook_log "info" "Quality gates not required for this command"
    fi
    
    hook_log "info" "Quality gate enforcement completed"
    return 0
}

load_quality_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        yq eval '.' "$CONFIG_FILE"
    else
        hook_warning "Quality configuration not found, using defaults"
        echo "{}"
    fi
}

should_enforce_quality_gates() {
    local command="$1"
    local subcommand="$2"
    
    # Commands that always require quality gates
    case "$command" in
        "architect"|"refactor")
            return 0
            ;;
        "git")
            case "$subcommand" in
                "commit"|"pr")
                    return 0
                    ;;
            esac
            ;;
        "deploy")
            return 0
            ;;
    esac
    
    # Check configuration-based rules
    local enforce_all
    enforce_all=$(echo "$quality_config" | yq eval '.global.enforce_all // false' -)
    
    if [[ "$enforce_all" == "true" ]]; then
        return 0
    fi
    
    return 1
}

run_quality_checks() {
    local checks=()
    
    # Determine which checks to run
    if [[ -f "package.json" ]]; then
        checks+=("eslint" "prettier" "jest")
    fi
    
    if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
        checks+=("black" "flake8" "pytest")
    fi
    
    if [[ -f "go.mod" ]]; then
        checks+=("gofmt" "golint" "go test")
    fi
    
    # Run each check
    local failed_checks=()
    for check in "${checks[@]}"; do
        hook_log "debug" "Running quality check: $check"
        
        if run_quality_check "$check"; then
            hook_log "debug" "Quality check passed: $check"
        else
            hook_error "Quality check failed: $check"
            failed_checks+=("$check")
        fi
    done
    
    # Report results
    if [[ ${#failed_checks[@]} -gt 0 ]]; then
        hook_error "Failed quality checks: ${failed_checks[*]}"
        return 1
    fi
    
    hook_log "info" "All quality checks passed"
    return 0
}

run_quality_check() {
    local check="$1"
    
    case "$check" in
        "eslint")
            npx eslint . --ext .js,.jsx,.ts,.tsx
            ;;
        "prettier")
            npx prettier --check .
            ;;
        "jest")
            npm test -- --passWithNoTests
            ;;
        "black")
            black --check .
            ;;
        "flake8")
            flake8 .
            ;;
        "pytest")
            pytest --tb=short
            ;;
        "gofmt")
            test -z "$(gofmt -l .)"
            ;;
        "golint")
            golint ./...
            ;;
        "go test")
            go test ./...
            ;;
        *)
            hook_warning "Unknown quality check: $check"
            return 0
            ;;
    esac
}

generate_quality_report() {
    local report_data
    report_data=$(cat <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "command": "$CLAUDE_COMMAND",
  "subcommand": "$CLAUDE_SUBCOMMAND",
  "quality_gates": {
    "enforced": true,
    "passed": true,
    "checks_run": $(printf '%s\n' "${checks[@]}" | jq -R . | jq -s .)
  },
  "project": {
    "root": "$PROJECT_ROOT",
    "type": "$(detect_project_type)",
    "languages": $(detect_project_languages | jq -R . | jq -s .)
  }
}
EOF
    )
    
    echo "$report_data" > "$REPORT_FILE"
    hook_log "debug" "Quality report generated: $REPORT_FILE"
}

detect_project_type() {
    if [[ -f "package.json" ]]; then
        echo "nodejs"
    elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
        echo "python"
    elif [[ -f "go.mod" ]]; then
        echo "go"
    elif [[ -f "Cargo.toml" ]]; then
        echo "rust"
    else
        echo "unknown"
    fi
}

detect_project_languages() {
    local languages=()
    
    find . -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" | head -1 >/dev/null && languages+=("javascript")
    find . -name "*.py" | head -1 >/dev/null && languages+=("python")
    find . -name "*.go" | head -1 >/dev/null && languages+=("go")
    find . -name "*.rs" | head -1 >/dev/null && languages+=("rust")
    find . -name "*.java" | head -1 >/dev/null && languages+=("java")
    
    printf '%s\n' "${languages[@]}"
}

# Execute main function
main "$@"
```

## Hook Context and Environment

### Available Environment Variables

```bash
# Command context
CLAUDE_COMMAND="architect"           # Primary command
CLAUDE_SUBCOMMAND="analyze"         # Subcommand (if any)
CLAUDE_ARGS=("--depth=3" "--json")  # Command arguments
CLAUDE_FLAGS="--verbose --dry-run"  # Command flags

# Execution context
CLAUDE_HOOK_TYPE="pre_command"      # Hook type being executed
CLAUDE_HOOK_NAME="validate-env"     # Current hook name
CLAUDE_HOOK_PHASE="setup"           # Hook execution phase

# Project context
PROJECT_ROOT="/path/to/project"     # Project root directory
PROJECT_TYPE="web_application"      # Detected project type
PROJECT_LANGUAGES="javascript,typescript" # Project languages

# Claude context
CLAUDE_VERSION="1.0.0"              # Claude version
CLAUDE_CONFIG_DIR="/path/.claude"   # Configuration directory
CLAUDE_CACHE_DIR="/path/cache"      # Cache directory
CLAUDE_TEMPLATES_DIR="/path/templates" # Templates directory

# Hook system context
CLAUDE_HOOK_UTILS="/path/hook-utils.sh" # Hook utilities
CLAUDE_HOOK_FRAMEWORK="/path/framework" # Hook framework
HOOK_DATA_DIR="/path/hook-data"     # Hook data directory
HOOK_LOG_LEVEL="info"               # Hook logging level
HOOK_TIMEOUT="60"                   # Hook timeout

# Git context (if available)
GIT_BRANCH="feature/new-feature"    # Current Git branch
GIT_COMMIT="abc123..."              # Current commit hash
GIT_AUTHOR="John Doe"               # Git author
GIT_EMAIL="john@example.com"        # Git email

# File operation context (for edit hooks)
EDIT_FILE_PATH="/path/to/file.js"   # File being edited
EDIT_OPERATION="create"             # create|update|delete
EDIT_BACKUP_PATH="/path/backup"     # Backup file path
```

### Hook Utility Functions

```bash
# Hook utilities available to all hooks
source "${CLAUDE_HOOK_UTILS}"

# Logging functions
hook_log "info" "Message"           # Log informational message
hook_warning "Warning message"      # Log warning
hook_error "Error message"          # Log error
hook_debug "Debug message"          # Log debug message

# Context functions
hook_get_command()                  # Get current command
hook_get_subcommand()              # Get current subcommand
hook_get_args()                    # Get command arguments
hook_get_project_root()            # Get project root directory
hook_get_project_type()            # Get project type

# File operations
hook_backup_file "path"            # Create backup of file
hook_restore_file "path"           # Restore file from backup
hook_temp_file                     # Create temporary file
hook_cleanup_temp                  # Cleanup temporary files

# Validation functions
hook_validate_file "path"          # Validate file exists and readable
hook_validate_dir "path"           # Validate directory exists
hook_validate_command "cmd"        # Validate command is available
hook_validate_json "file"          # Validate JSON file
hook_validate_yaml "file"          # Validate YAML file

# Communication functions
hook_set_data "key" "value"        # Set data for other hooks
hook_get_data "key"                # Get data from other hooks
hook_broadcast_event "event"       # Broadcast event to other hooks
hook_wait_for_event "event"        # Wait for event

# Process management
hook_run_background "command"      # Run command in background
hook_wait_for_process "pid"        # Wait for process completion
hook_kill_process "pid"            # Kill process

# Integration functions
hook_call_claude "command"         # Call Claude command
hook_call_git "args"               # Call git command
hook_call_npm "args"               # Call npm command
hook_call_python "script"          # Call Python script
```

## Pre-Command Hooks

### Environment Setup Hook

```bash
#!/bin/bash
# .claude/hooks/pre-command/00-setup-environment.sh

source "${CLAUDE_HOOK_UTILS}"

main() {
    hook_log "info" "Setting up environment for ${CLAUDE_COMMAND}"
    
    # Create required directories
    create_required_directories || return 1
    
    # Set up temporary workspace
    setup_workspace || return 1
    
    # Validate dependencies
    validate_dependencies || return 1
    
    # Initialize logging
    setup_logging || return 1
    
    hook_log "info" "Environment setup completed"
}

create_required_directories() {
    local dirs=(
        "${CLAUDE_CACHE_DIR}/tmp"
        "${CLAUDE_CACHE_DIR}/backups"
        "${CLAUDE_CACHE_DIR}/reports"
        "${CLAUDE_CACHE_DIR}/logs"
    )
    
    for dir in "${dirs[@]}"; do
        if ! mkdir -p "$dir"; then
            hook_error "Failed to create directory: $dir"
            return 1
        fi
        hook_debug "Created directory: $dir"
    done
}

setup_workspace() {
    # Create workspace for this command execution
    local workspace="${CLAUDE_CACHE_DIR}/workspace/$$"
    
    if ! mkdir -p "$workspace"; then
        hook_error "Failed to create workspace: $workspace"
        return 1
    fi
    
    # Export workspace location
    export CLAUDE_WORKSPACE="$workspace"
    hook_set_data "workspace" "$workspace"
    
    hook_debug "Workspace created: $workspace"
}

validate_dependencies() {
    local command="${CLAUDE_COMMAND}"
    local required_tools=()
    
    # Determine required tools based on command
    case "$command" in
        "architect")
            required_tools+=("git" "find" "grep")
            ;;
        "quality/format")
            required_tools+=("git")
            [[ -f "package.json" ]] && required_tools+=("npm" "npx")
            [[ -f "requirements.txt" ]] && required_tools+=("python" "pip")
            ;;
        "git/commit")
            required_tools+=("git")
            ;;
    esac
    
    # Validate each required tool
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            hook_error "Required tool not available: $tool"
            return 1
        fi
        hook_debug "Tool available: $tool"
    done
}

setup_logging() {
    local log_dir="${CLAUDE_CACHE_DIR}/logs"
    local log_file="${log_dir}/$(date +%Y%m%d)-${CLAUDE_COMMAND}.log"
    
    # Export log file location
    export CLAUDE_COMMAND_LOG="$log_file"
    hook_set_data "log_file" "$log_file"
    
    # Initialize log file
    cat > "$log_file" <<EOF
# Claude Command Log
# Command: ${CLAUDE_COMMAND} ${CLAUDE_SUBCOMMAND}
# Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)
# Project: ${PROJECT_ROOT}
# Version: ${CLAUDE_VERSION}

EOF
    
    hook_debug "Command logging initialized: $log_file"
}

main "$@"
```

### Project Validation Hook

```bash
#!/bin/bash
# .claude/hooks/pre-command/10-validate-project.sh

source "${CLAUDE_HOOK_UTILS}"

main() {
    hook_log "info" "Validating project structure and configuration"
    
    # Validate project root
    validate_project_root || return 1
    
    # Validate project structure
    validate_project_structure || return 1
    
    # Validate configuration files
    validate_configuration_files || return 1
    
    # Validate permissions
    validate_permissions || return 1
    
    hook_log "info" "Project validation completed"
}

validate_project_root() {
    if [[ ! -d "$PROJECT_ROOT" ]]; then
        hook_error "Project root directory not found: $PROJECT_ROOT"
        return 1
    fi
    
    if [[ ! -r "$PROJECT_ROOT" ]]; then
        hook_error "Project root directory not readable: $PROJECT_ROOT"
        return 1
    fi
    
    hook_debug "Project root validated: $PROJECT_ROOT"
}

validate_project_structure() {
    local project_type
    project_type=$(hook_get_project_type)
    
    case "$project_type" in
        "nodejs")
            validate_nodejs_structure || return 1
            ;;
        "python")
            validate_python_structure || return 1
            ;;
        "web_application")
            validate_web_app_structure || return 1
            ;;
        *)
            hook_warning "Unknown project type: $project_type"
            ;;
    esac
}

validate_nodejs_structure() {
    local required_files=("package.json")
    local recommended_dirs=("src" "tests" "docs")
    
    # Check required files
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            hook_error "Required Node.js file missing: $file"
            return 1
        fi
        hook_debug "Node.js file found: $file"
    done
    
    # Check recommended directories
    for dir in "${recommended_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            hook_warning "Recommended directory missing: $dir"
        else
            hook_debug "Recommended directory found: $dir"
        fi
    done
    
    # Validate package.json
    if command -v jq >/dev/null 2>&1; then
        if ! jq empty package.json 2>/dev/null; then
            hook_error "Invalid JSON in package.json"
            return 1
        fi
        hook_debug "package.json is valid JSON"
    fi
}

validate_python_structure() {
    local python_files=("requirements.txt" "setup.py" "pyproject.toml")
    local has_python_config=false
    
    # Check for at least one Python configuration file
    for file in "${python_files[@]}"; do
        if [[ -f "$file" ]]; then
            has_python_config=true
            hook_debug "Python configuration file found: $file"
            break
        fi
    done
    
    if [[ "$has_python_config" == "false" ]]; then
        hook_warning "No Python configuration files found"
    fi
    
    # Check for Python source directory
    if [[ ! -d "src" ]] && [[ ! -f "*.py" ]]; then
        hook_warning "No Python source files or src directory found"
    fi
}

validate_web_app_structure() {
    local web_indicators=("index.html" "src/index.js" "src/index.ts" "public" "dist")
    local has_web_indicator=false
    
    for indicator in "${web_indicators[@]}"; do
        if [[ -f "$indicator" ]] || [[ -d "$indicator" ]]; then
            has_web_indicator=true
            hook_debug "Web application indicator found: $indicator"
            break
        fi
    done
    
    if [[ "$has_web_indicator" == "false" ]]; then
        hook_warning "No clear web application structure detected"
    fi
}

validate_configuration_files() {
    # Validate Claude configuration
    if [[ -f ".claude/config.yaml" ]]; then
        if ! hook_validate_yaml ".claude/config.yaml"; then
            hook_error "Invalid YAML in .claude/config.yaml"
            return 1
        fi
        hook_debug "Claude configuration is valid"
    fi
    
    # Validate other configuration files
    local config_files=(".eslintrc.js" ".prettierrc" "tsconfig.json")
    
    for file in "${config_files[@]}"; do
        if [[ -f "$file" ]]; then
            case "$file" in
                *.json)
                    if ! hook_validate_json "$file"; then
                        hook_error "Invalid JSON in $file"
                        return 1
                    fi
                    ;;
                *.yaml|*.yml)
                    if ! hook_validate_yaml "$file"; then
                        hook_error "Invalid YAML in $file"
                        return 1
                    fi
                    ;;
            esac
            hook_debug "Configuration file validated: $file"
        fi
    done
}

validate_permissions() {
    # Check write permissions for common directories
    local writable_dirs=("." "src" "tests" "docs")
    
    for dir in "${writable_dirs[@]}"; do
        if [[ -d "$dir" ]] && [[ ! -w "$dir" ]]; then
            hook_error "Directory not writable: $dir"
            return 1
        fi
    done
    
    # Check that we can create files in project root
    local test_file=".claude-test-$$"
    if ! touch "$test_file" 2>/dev/null; then
        hook_error "Cannot create files in project root"
        return 1
    fi
    rm -f "$test_file"
    
    hook_debug "Permissions validated"
}

main "$@"
```

## Post-Command Hooks

### Report Generation Hook

```bash
#!/bin/bash
# .claude/hooks/post-command/00-generate-reports.sh

source "${CLAUDE_HOOK_UTILS}"

main() {
    hook_log "info" "Generating execution reports"
    
    # Generate command execution report
    generate_execution_report || return 1
    
    # Generate metrics report
    generate_metrics_report || return 1
    
    # Update project statistics
    update_project_statistics || return 1
    
    # Archive logs
    archive_logs || return 1
    
    hook_log "info" "Report generation completed"
}

generate_execution_report() {
    local report_file="${CLAUDE_CACHE_DIR}/reports/execution-$(date +%Y%m%d-%H%M%S).json"
    local workspace
    workspace=$(hook_get_data "workspace")
    local log_file
    log_file=$(hook_get_data "log_file")
    
    local report_data
    report_data=$(cat <<EOF
{
  "execution": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "command": "$CLAUDE_COMMAND",
    "subcommand": "$CLAUDE_SUBCOMMAND",
    "args": $(printf '%s\n' "${CLAUDE_ARGS[@]}" | jq -R . | jq -s .),
    "duration": $(calculate_execution_duration),
    "status": "success",
    "exit_code": 0
  },
  "project": {
    "root": "$PROJECT_ROOT",
    "type": "$PROJECT_TYPE",
    "languages": $(echo "$PROJECT_LANGUAGES" | tr ',' '\n' | jq -R . | jq -s .),
    "git_branch": "${GIT_BRANCH:-null}",
    "git_commit": "${GIT_COMMIT:-null}"
  },
  "environment": {
    "claude_version": "$CLAUDE_VERSION",
    "hostname": "$(hostname)",
    "user": "$(whoami)",
    "pwd": "$PWD"
  },
  "files": {
    "workspace": "$workspace",
    "log_file": "$log_file",
    "changed_files": $(get_changed_files | jq -R . | jq -s .)
  }
}
EOF
    )
    
    echo "$report_data" > "$report_file"
    hook_set_data "execution_report" "$report_file"
    
    hook_log "debug" "Execution report generated: $report_file"
}

calculate_execution_duration() {
    local start_time
    start_time=$(hook_get_data "start_time")
    local end_time
    end_time=$(date +%s)
    
    if [[ -n "$start_time" ]]; then
        echo $((end_time - start_time))
    else
        echo "0"
    fi
}

get_changed_files() {
    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
        git diff --name-only HEAD~1 2>/dev/null || echo
    fi
}

generate_metrics_report() {
    local metrics_file="${CLAUDE_CACHE_DIR}/reports/metrics-$(date +%Y%m%d).json"
    
    # Calculate project metrics
    local file_count
    file_count=$(find . -type f -not -path "./.git/*" -not -path "./.claude/*" | wc -l)
    
    local line_count
    line_count=$(find . -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo 0)
    
    local directory_count
    directory_count=$(find . -type d -not -path "./.git/*" -not -path "./.claude/*" | wc -l)
    
    local metrics_data
    metrics_data=$(cat <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "project_metrics": {
    "total_files": $file_count,
    "total_lines": $line_count,
    "total_directories": $directory_count,
    "project_size": "$(du -sh . 2>/dev/null | cut -f1 || echo 'unknown')"
  },
  "command_metrics": {
    "command": "$CLAUDE_COMMAND",
    "execution_count": $(get_command_execution_count),
    "average_duration": $(get_average_duration),
    "success_rate": $(get_success_rate)
  }
}
EOF
    )
    
    echo "$metrics_data" > "$metrics_file"
    hook_set_data "metrics_report" "$metrics_file"
    
    hook_log "debug" "Metrics report generated: $metrics_file"
}

get_command_execution_count() {
    local count_file="${CLAUDE_CACHE_DIR}/metrics/command-counts.json"
    
    if [[ -f "$count_file" ]]; then
        jq -r ".\"$CLAUDE_COMMAND\" // 0" "$count_file" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

get_average_duration() {
    local duration_file="${CLAUDE_CACHE_DIR}/metrics/command-durations.json"
    
    if [[ -f "$duration_file" ]]; then
        jq -r ".\"$CLAUDE_COMMAND\".average // 0" "$duration_file" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

get_success_rate() {
    local success_file="${CLAUDE_CACHE_DIR}/metrics/command-success.json"
    
    if [[ -f "$success_file" ]]; then
        jq -r ".\"$CLAUDE_COMMAND\".rate // 100" "$success_file" 2>/dev/null || echo 100
    else
        echo 100
    fi
}

update_project_statistics() {
    local stats_file="${CLAUDE_CACHE_DIR}/project-stats.json"
    local current_stats="{}"
    
    if [[ -f "$stats_file" ]]; then
        current_stats=$(cat "$stats_file")
    fi
    
    # Update command execution count
    local updated_stats
    updated_stats=$(echo "$current_stats" | jq --arg cmd "$CLAUDE_COMMAND" '
        .commands[$cmd] = (.commands[$cmd] // 0) + 1 |
        .last_execution = now |
        .total_executions = (.total_executions // 0) + 1
    ')
    
    echo "$updated_stats" > "$stats_file"
    hook_log "debug" "Project statistics updated"
}

archive_logs() {
    local log_archive_dir="${CLAUDE_CACHE_DIR}/logs/archive"
    local log_file
    log_file=$(hook_get_data "log_file")
    
    if [[ -n "$log_file" ]] && [[ -f "$log_file" ]]; then
        mkdir -p "$log_archive_dir"
        
        # Compress and archive the log file
        local archive_name="$(basename "$log_file" .log)-$(date +%H%M%S).log.gz"
        gzip -c "$log_file" > "$log_archive_dir/$archive_name"
        
        hook_log "debug" "Log archived: $log_archive_dir/$archive_name"
        
        # Clean up old archives (keep last 30 days)
        find "$log_archive_dir" -name "*.log.gz" -mtime +30 -delete 2>/dev/null || true
    fi
}

main "$@"
```

### Cleanup Hook

```bash
#!/bin/bash
# .claude/hooks/post-command/99-cleanup.sh

source "${CLAUDE_HOOK_UTILS}"

main() {
    hook_log "info" "Performing post-command cleanup"
    
    # Clean temporary files
    cleanup_temporary_files || return 1
    
    # Clean workspace
    cleanup_workspace || return 1
    
    # Optimize cache
    optimize_cache || return 1
    
    # Update indexes
    update_indexes || return 1
    
    hook_log "info" "Cleanup completed"
}

cleanup_temporary_files() {
    local temp_dir="${CLAUDE_CACHE_DIR}/tmp"
    
    if [[ -d "$temp_dir" ]]; then
        # Remove files older than 1 hour
        find "$temp_dir" -type f -mmin +60 -delete 2>/dev/null || true
        
        # Remove empty directories
        find "$temp_dir" -type d -empty -delete 2>/dev/null || true
        
        hook_log "debug" "Temporary files cleaned"
    fi
    
    # Clean up hook-specific temporary files
    hook_cleanup_temp
}

cleanup_workspace() {
    local workspace
    workspace=$(hook_get_data "workspace")
    
    if [[ -n "$workspace" ]] && [[ -d "$workspace" ]]; then
        # Archive important files first
        local archive_dir="${CLAUDE_CACHE_DIR}/workspace-archive"
        mkdir -p "$archive_dir"
        
        if [[ -n "$(ls -A "$workspace" 2>/dev/null)" ]]; then
            local archive_name="workspace-$(date +%Y%m%d-%H%M%S).tar.gz"
            tar -czf "$archive_dir/$archive_name" -C "$workspace" . 2>/dev/null || true
            hook_log "debug" "Workspace archived: $archive_dir/$archive_name"
        fi
        
        # Remove workspace
        rm -rf "$workspace"
        hook_log "debug" "Workspace cleaned: $workspace"
    fi
}

optimize_cache() {
    local cache_dir="$CLAUDE_CACHE_DIR"
    local max_cache_size="${CLAUDE_DISK_CACHE_SIZE:-100M}"
    
    # Check cache size
    local current_size
    current_size=$(du -sm "$cache_dir" 2>/dev/null | cut -f1 || echo 0)
    local max_size_mb
    max_size_mb=$(echo "$max_cache_size" | sed 's/[^0-9]//g')
    
    if [[ $current_size -gt $max_size_mb ]]; then
        hook_log "info" "Cache size ($current_size MB) exceeds limit ($max_size_mb MB), optimizing"
        
        # Remove oldest files first
        find "$cache_dir" -type f -name "*.cache" -printf '%T@ %p\n' | \
            sort -n | \
            head -n -100 | \
            cut -d' ' -f2- | \
            xargs rm -f 2>/dev/null || true
        
        hook_log "debug" "Cache optimized"
    fi
}

update_indexes() {
    # Update command index
    update_command_index
    
    # Update template index
    update_template_index
    
    # Update file index
    update_file_index
}

update_command_index() {
    local index_file="${CLAUDE_CACHE_DIR}/indexes/commands.json"
    mkdir -p "$(dirname "$index_file")"
    
    local command_data
    command_data=$(cat <<EOF
{
  "command": "$CLAUDE_COMMAND",
  "subcommand": "$CLAUDE_SUBCOMMAND",
  "last_executed": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "execution_count": $(get_command_execution_count),
  "project_type": "$PROJECT_TYPE"
}
EOF
    )
    
    # Update or create index entry
    if [[ -f "$index_file" ]]; then
        local updated_index
        updated_index=$(jq --argjson cmd "$command_data" \
            '.[$cmd.command] = $cmd' "$index_file")
        echo "$updated_index" > "$index_file"
    else
        echo "{\"$CLAUDE_COMMAND\": $command_data}" > "$index_file"
    fi
    
    hook_log "debug" "Command index updated"
}

update_template_index() {
    local template_index="${CLAUDE_CACHE_DIR}/indexes/templates.json"
    
    # Scan for available templates
    if [[ -d "$CLAUDE_TEMPLATES_DIR" ]]; then
        find "$CLAUDE_TEMPLATES_DIR" -name "*.md" -type f | \
            jq -R -s 'split("\n") | map(select(length > 0))' > "$template_index"
        
        hook_log "debug" "Template index updated"
    fi
}

update_file_index() {
    local file_index="${CLAUDE_CACHE_DIR}/indexes/files.json"
    
    # Index project files for quick lookup
    local file_data
    file_data=$(find . -type f \
        -not -path "./.git/*" \
        -not -path "./.claude/*" \
        -not -path "./node_modules/*" \
        -printf '%p %T@ %s\n' | \
        head -1000 | \
        jq -R -s 'split("\n") | map(select(length > 0) | split(" ") | {path: .[0], mtime: .[1], size: .[2]})')
    
    echo "$file_data" > "$file_index"
    hook_log "debug" "File index updated"
}

main "$@"
```

## Error Hooks

### Error Recovery Hook

```bash
#!/bin/bash
# .claude/hooks/error/00-error-recovery.sh

source "${CLAUDE_HOOK_UTILS}"

main() {
    local exit_code="${1:-1}"
    
    hook_log "error" "Command failed with exit code: $exit_code"
    hook_log "info" "Attempting error recovery"
    
    # Capture current state
    capture_error_state "$exit_code" || true
    
    # Attempt recovery based on error type
    attempt_recovery "$exit_code" || true
    
    # Clean up after failure
    cleanup_after_failure || true
    
    # Generate error report
    generate_error_report "$exit_code" || true
    
    hook_log "info" "Error recovery completed"
}

capture_error_state() {
    local exit_code="$1"
    local error_dir="${CLAUDE_CACHE_DIR}/errors/$(date +%Y%m%d-%H%M%S)"
    
    mkdir -p "$error_dir"
    
    # Capture environment
    env > "$error_dir/environment.txt"
    
    # Capture command context
    cat > "$error_dir/context.json" <<EOF
{
  "command": "$CLAUDE_COMMAND",
  "subcommand": "$CLAUDE_SUBCOMMAND", 
  "args": $(printf '%s\n' "${CLAUDE_ARGS[@]}" | jq -R . | jq -s .),
  "exit_code": $exit_code,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "project_root": "$PROJECT_ROOT",
  "working_directory": "$PWD"
}
EOF
    
    # Capture process information
    ps aux > "$error_dir/processes.txt" 2>/dev/null || true
    
    # Capture system information
    cat > "$error_dir/system.txt" <<EOF
Hostname: $(hostname)
Uptime: $(uptime)
Memory: $(free -h 2>/dev/null || echo 'N/A')
Disk: $(df -h . 2>/dev/null || echo 'N/A')
EOF
    
    # Capture log files
    local log_file
    log_file=$(hook_get_data "log_file")
    if [[ -n "$log_file" ]] && [[ -f "$log_file" ]]; then
        cp "$log_file" "$error_dir/command.log"
    fi
    
    # Capture Git state if available
    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
        git status --porcelain > "$error_dir/git-status.txt" 2>/dev/null || true
        git log --oneline -10 > "$error_dir/git-log.txt" 2>/dev/null || true
    fi
    
    hook_set_data "error_state_dir" "$error_dir"
    hook_log "debug" "Error state captured: $error_dir"
}

attempt_recovery() {
    local exit_code="$1"
    
    case "$exit_code" in
        1)
            # General error - try basic recovery
            attempt_basic_recovery
            ;;
        2)
            # Permission error - try permission fixes
            attempt_permission_recovery
            ;;
        126)
            # Command not executable
            attempt_executable_recovery
            ;;
        127)
            # Command not found
            attempt_dependency_recovery
            ;;
        130)
            # Interrupted by user
            attempt_cleanup_recovery
            ;;
        *)
            hook_log "warning" "Unknown exit code: $exit_code, attempting basic recovery"
            attempt_basic_recovery
            ;;
    esac
}

attempt_basic_recovery() {
    hook_log "info" "Attempting basic recovery"
    
    # Restore from backup if available
    local backup_dir
    backup_dir=$(hook_get_data "backup_dir")
    if [[ -n "$backup_dir" ]] && [[ -d "$backup_dir" ]]; then
        hook_log "info" "Restoring from backup: $backup_dir"
        # Implementation would restore backed up files
    fi
    
    # Clean temporary files
    hook_cleanup_temp
    
    # Reset workspace
    local workspace
    workspace=$(hook_get_data "workspace")
    if [[ -n "$workspace" ]] && [[ -d "$workspace" ]]; then
        rm -rf "$workspace"
        mkdir -p "$workspace"
    fi
}

attempt_permission_recovery() {
    hook_log "info" "Attempting permission recovery"
    
    # Check and fix common permission issues
    local dirs_to_fix=("." ".claude" "src" "tests")
    
    for dir in "${dirs_to_fix[@]}"; do
        if [[ -d "$dir" ]] && [[ ! -w "$dir" ]]; then
            hook_log "warning" "Directory not writable: $dir"
            # In a real implementation, might attempt to fix permissions
            # chmod u+w "$dir" 2>/dev/null || true
        fi
    done
}

attempt_executable_recovery() {
    hook_log "info" "Attempting executable recovery"
    
    # Check if required executables exist but aren't executable
    local required_commands=("git" "node" "npm" "python")
    
    for cmd in "${required_commands[@]}"; do
        local cmd_path
        cmd_path=$(which "$cmd" 2>/dev/null)
        if [[ -n "$cmd_path" ]] && [[ ! -x "$cmd_path" ]]; then
            hook_log "warning" "Command exists but not executable: $cmd_path"
        fi
    done
}

attempt_dependency_recovery() {
    hook_log "info" "Attempting dependency recovery"
    
    # Suggest missing dependencies based on project type
    case "$PROJECT_TYPE" in
        "nodejs")
            hook_log "warning" "For Node.js projects, ensure node and npm are installed"
            ;;
        "python")
            hook_log "warning" "For Python projects, ensure python and pip are installed"
            ;;
        *)
            hook_log "warning" "Ensure required dependencies are installed and in PATH"
            ;;
    esac
}

attempt_cleanup_recovery() {
    hook_log "info" "Performing cleanup after interruption"
    
    # Kill any background processes started by hooks
    local hook_pids
    hook_pids=$(hook_get_data "background_pids")
    if [[ -n "$hook_pids" ]]; then
        for pid in $hook_pids; do
            if kill -0 "$pid" 2>/dev/null; then
                hook_log "debug" "Killing background process: $pid"
                kill "$pid" 2>/dev/null || true
            fi
        done
    fi
    
    # Clean up temporary files
    hook_cleanup_temp
}

cleanup_after_failure() {
    hook_log "info" "Cleaning up after failure"
    
    # Remove incomplete outputs
    local output_files
    output_files=$(hook_get_data "output_files")
    if [[ -n "$output_files" ]]; then
        for file in $output_files; do
            if [[ -f "$file" ]]; then
                hook_log "debug" "Removing incomplete output: $file"
                rm -f "$file"
            fi
        done
    fi
    
    # Reset Git state if needed
    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
        # Check for uncommitted changes that might be from a failed operation
        if git diff --quiet --exit-code; then
            hook_log "debug" "No uncommitted changes to clean up"
        else
            hook_log "warning" "Uncommitted changes detected - manual review recommended"
        fi
    fi
}

generate_error_report() {
    local exit_code="$1"
    local error_report="${CLAUDE_CACHE_DIR}/reports/error-$(date +%Y%m%d-%H%M%S).json"
    local error_state_dir
    error_state_dir=$(hook_get_data "error_state_dir")
    
    local report_data
    report_data=$(cat <<EOF
{
  "error": {
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "command": "$CLAUDE_COMMAND",
    "subcommand": "$CLAUDE_SUBCOMMAND",
    "exit_code": $exit_code,
    "error_type": "$(classify_error "$exit_code")",
    "recovery_attempted": true
  },
  "context": {
    "project_root": "$PROJECT_ROOT",
    "project_type": "$PROJECT_TYPE",
    "working_directory": "$PWD",
    "user": "$(whoami)",
    "hostname": "$(hostname)"
  },
  "state": {
    "error_state_dir": "$error_state_dir",
    "log_file": "$(hook_get_data "log_file")",
    "workspace": "$(hook_get_data "workspace")"
  }
}
EOF
    )
    
    echo "$report_data" > "$error_report"
    hook_set_data "error_report" "$error_report"
    
    hook_log "debug" "Error report generated: $error_report"
}

classify_error() {
    local exit_code="$1"
    
    case "$exit_code" in
        1) echo "general_error" ;;
        2) echo "permission_error" ;;
        126) echo "not_executable" ;;
        127) echo "command_not_found" ;;
        128) echo "invalid_argument" ;;
        130) echo "user_interrupt" ;;
        *) echo "unknown_error" ;;
    esac
}

main "$@"
```

## Edit Hooks

### Pre-Edit Validation Hook

```bash
#!/bin/bash
# .claude/hooks/edit/pre-edit/00-validate-edit.sh

source "${CLAUDE_HOOK_UTILS}"

main() {
    hook_log "info" "Validating file edit operation"
    
    # Validate file path
    validate_file_path || return 1
    
    # Check permissions
    check_edit_permissions || return 1
    
    # Create backup
    create_file_backup || return 1
    
    # Validate syntax (if applicable)
    validate_file_syntax || return 1
    
    hook_log "info" "Edit validation completed"
}

validate_file_path() {
    if [[ -z "$EDIT_FILE_PATH" ]]; then
        hook_error "Edit file path not provided"
        return 1
    fi
    
    # Check if path is within project
    local canonical_project
    canonical_project=$(realpath "$PROJECT_ROOT")
    local canonical_file
    canonical_file=$(realpath "$(dirname "$EDIT_FILE_PATH")")
    
    if [[ "$canonical_file" != "$canonical_project"* ]]; then
        hook_error "File path outside project directory: $EDIT_FILE_PATH"
        return 1
    fi
    
    # Check for sensitive files
    local sensitive_patterns=(".env" "*.key" "*.pem" "config/secrets*")
    
    for pattern in "${sensitive_patterns[@]}"; do
        if [[ "$EDIT_FILE_PATH" == $pattern ]]; then
            hook_warning "Editing sensitive file: $EDIT_FILE_PATH"
            break
        fi
    done
    
    hook_log "debug" "File path validated: $EDIT_FILE_PATH"
}

check_edit_permissions() {
    local file_dir
    file_dir=$(dirname "$EDIT_FILE_PATH")
    
    # Check directory permissions
    if [[ ! -d "$file_dir" ]]; then
        if ! mkdir -p "$file_dir"; then
            hook_error "Cannot create directory: $file_dir"
            return 1
        fi
        hook_log "debug" "Created directory: $file_dir"
    fi
    
    if [[ ! -w "$file_dir" ]]; then
        hook_error "Directory not writable: $file_dir"
        return 1
    fi
    
    # Check file permissions (if file exists)
    if [[ -f "$EDIT_FILE_PATH" ]]; then
        if [[ ! -w "$EDIT_FILE_PATH" ]]; then
            hook_error "File not writable: $EDIT_FILE_PATH"
            return 1
        fi
        
        # Check if file is under version control and clean
        if command -v git >/dev/null 2>&1 && git ls-files --error-unmatch "$EDIT_FILE_PATH" >/dev/null 2>&1; then
            if ! git diff --quiet "$EDIT_FILE_PATH"; then
                hook_warning "File has uncommitted changes: $EDIT_FILE_PATH"
            fi
        fi
    fi
    
    hook_log "debug" "Edit permissions validated"
}

create_file_backup() {
    if [[ "$EDIT_OPERATION" == "create" ]]; then
        hook_log "debug" "No backup needed for new file creation"
        return 0
    fi
    
    if [[ ! -f "$EDIT_FILE_PATH" ]]; then
        hook_log "debug" "File does not exist, no backup needed"
        return 0
    fi
    
    local backup_dir="${CLAUDE_CACHE_DIR}/backups/$(date +%Y%m%d)"
    mkdir -p "$backup_dir"
    
    local backup_name
    backup_name="$(basename "$EDIT_FILE_PATH")-$(date +%H%M%S)-$$.bak"
    local backup_path="$backup_dir/$backup_name"
    
    if ! cp "$EDIT_FILE_PATH" "$backup_path"; then
        hook_error "Failed to create backup: $backup_path"
        return 1
    fi
    
    export EDIT_BACKUP_PATH="$backup_path"
    hook_set_data "edit_backup_path" "$backup_path"
    
    hook_log "debug" "File backup created: $backup_path"
}

validate_file_syntax() {
    if [[ ! -f "$EDIT_FILE_PATH" ]]; then
        hook_log "debug" "File does not exist, syntax validation skipped"
        return 0
    fi
    
    local file_ext="${EDIT_FILE_PATH##*.}"
    
    case "$file_ext" in
        "js"|"jsx")
            validate_javascript_syntax
            ;;
        "ts"|"tsx")
            validate_typescript_syntax
            ;;
        "py")
            validate_python_syntax
            ;;
        "json")
            validate_json_syntax
            ;;
        "yaml"|"yml")
            validate_yaml_syntax
            ;;
        *)
            hook_log "debug" "No syntax validation available for: $file_ext"
            ;;
    esac
}

validate_javascript_syntax() {
    if command -v node >/dev/null 2>&1; then
        if ! node -c "$EDIT_FILE_PATH" 2>/dev/null; then
            hook_warning "JavaScript syntax error in: $EDIT_FILE_PATH"
        else
            hook_log "debug" "JavaScript syntax valid"
        fi
    fi
}

validate_typescript_syntax() {
    if command -v tsc >/dev/null 2>&1; then
        if ! tsc --noEmit "$EDIT_FILE_PATH" 2>/dev/null; then
            hook_warning "TypeScript syntax error in: $EDIT_FILE_PATH"
        else
            hook_log "debug" "TypeScript syntax valid"
        fi
    fi
}

validate_python_syntax() {
    if command -v python >/dev/null 2>&1; then
        if ! python -m py_compile "$EDIT_FILE_PATH" 2>/dev/null; then
            hook_warning "Python syntax error in: $EDIT_FILE_PATH"
        else
            hook_log "debug" "Python syntax valid"
        fi
    fi
}

validate_json_syntax() {
    if ! hook_validate_json "$EDIT_FILE_PATH"; then
        hook_warning "JSON syntax error in: $EDIT_FILE_PATH"
    else
        hook_log "debug" "JSON syntax valid"
    fi
}

validate_yaml_syntax() {
    if ! hook_validate_yaml "$EDIT_FILE_PATH"; then
        hook_warning "YAML syntax error in: $EDIT_FILE_PATH"
    else
        hook_log "debug" "YAML syntax valid"
    fi
}

main "$@"
```

### Post-Edit Processing Hook

```bash
#!/bin/bash
# .claude/hooks/edit/post-edit/00-process-edit.sh

source "${CLAUDE_HOOK_UTILS}"

main() {
    hook_log "info" "Processing file edit: $EDIT_FILE_PATH"
    
    # Validate edit result
    validate_edit_result || return 1
    
    # Format file if needed
    format_file || return 1
    
    # Update file index
    update_file_index || return 1
    
    # Run post-edit checks
    run_post_edit_checks || return 1
    
    hook_log "info" "Edit processing completed"
}

validate_edit_result() {
    if [[ ! -f "$EDIT_FILE_PATH" ]]; then
        if [[ "$EDIT_OPERATION" == "delete" ]]; then
            hook_log "debug" "File successfully deleted: $EDIT_FILE_PATH"
            return 0
        else
            hook_error "Expected file not found after edit: $EDIT_FILE_PATH"
            return 1
        fi
    fi
    
    # Check file size sanity
    local file_size
    file_size=$(stat -c%s "$EDIT_FILE_PATH" 2>/dev/null || echo 0)
    
    if [[ $file_size -eq 0 ]] && [[ "$EDIT_OPERATION" != "create" ]]; then
        hook_warning "File is empty after edit: $EDIT_FILE_PATH"
    fi
    
    if [[ $file_size -gt 10485760 ]]; then  # 10MB
        hook_warning "File is very large after edit: $EDIT_FILE_PATH ($file_size bytes)"
    fi
    
    hook_log "debug" "Edit result validated"
}

format_file() {
    local file_ext="${EDIT_FILE_PATH##*.}"
    
    case "$file_ext" in
        "js"|"jsx"|"ts"|"tsx")
            format_javascript_file
            ;;
        "py")
            format_python_file
            ;;
        "json")
            format_json_file
            ;;
        "yaml"|"yml")
            format_yaml_file
            ;;
        *)
            hook_log "debug" "No formatting available for: $file_ext"
            ;;
    esac
}

format_javascript_file() {
    if command -v npx >/dev/null 2>&1 && [[ -f "package.json" ]]; then
        if npx prettier --check "$EDIT_FILE_PATH" >/dev/null 2>&1; then
            hook_log "debug" "File already formatted: $EDIT_FILE_PATH"
        else
            hook_log "info" "Formatting JavaScript file: $EDIT_FILE_PATH"
            npx prettier --write "$EDIT_FILE_PATH" >/dev/null 2>&1 || \
                hook_warning "Failed to format file: $EDIT_FILE_PATH"
        fi
    fi
}

format_python_file() {
    if command -v black >/dev/null 2>&1; then
        hook_log "info" "Formatting Python file: $EDIT_FILE_PATH"
        black "$EDIT_FILE_PATH" >/dev/null 2>&1 || \
            hook_warning "Failed to format file: $EDIT_FILE_PATH"
    fi
}

format_json_file() {
    if command -v jq >/dev/null 2>&1; then
        hook_log "info" "Formatting JSON file: $EDIT_FILE_PATH"
        local temp_file
        temp_file=$(mktemp)
        if jq . "$EDIT_FILE_PATH" > "$temp_file" 2>/dev/null; then
            mv "$temp_file" "$EDIT_FILE_PATH"
        else
            rm -f "$temp_file"
            hook_warning "Failed to format JSON file: $EDIT_FILE_PATH"
        fi
    fi
}

format_yaml_file() {
    if command -v yq >/dev/null 2>&1; then
        hook_log "info" "Formatting YAML file: $EDIT_FILE_PATH"
        local temp_file
        temp_file=$(mktemp)
        if yq eval '.' "$EDIT_FILE_PATH" > "$temp_file" 2>/dev/null; then
            mv "$temp_file" "$EDIT_FILE_PATH"
        else
            rm -f "$temp_file"
            hook_warning "Failed to format YAML file: $EDIT_FILE_PATH"
        fi
    fi
}

update_file_index() {
    local index_file="${CLAUDE_CACHE_DIR}/indexes/edited-files.json"
    mkdir -p "$(dirname "$index_file")"
    
    local file_info
    file_info=$(cat <<EOF
{
  "path": "$EDIT_FILE_PATH",
  "operation": "$EDIT_OPERATION",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "size": $(stat -c%s "$EDIT_FILE_PATH" 2>/dev/null || echo 0),
  "command": "$CLAUDE_COMMAND",
  "backup": "$(hook_get_data "edit_backup_path")"
}
EOF
    )
    
    # Add to index
    if [[ -f "$index_file" ]]; then
        local updated_index
        updated_index=$(jq --argjson info "$file_info" '. + [$info]' "$index_file")
        echo "$updated_index" > "$index_file"
    else
        echo "[$file_info]" > "$index_file"
    fi
    
    hook_log "debug" "File index updated"
}

run_post_edit_checks() {
    # Run syntax validation
    validate_file_syntax_post_edit
    
    # Check for common issues
    check_for_common_issues
    
    # Update Git index if needed
    update_git_index
}

validate_file_syntax_post_edit() {
    local file_ext="${EDIT_FILE_PATH##*.}"
    
    case "$file_ext" in
        "js"|"jsx")
            if command -v node >/dev/null 2>&1; then
                if ! node -c "$EDIT_FILE_PATH" 2>/dev/null; then
                    hook_error "JavaScript syntax error after edit: $EDIT_FILE_PATH"
                    return 1
                fi
            fi
            ;;
        "py")
            if command -v python >/dev/null 2>&1; then
                if ! python -m py_compile "$EDIT_FILE_PATH" 2>/dev/null; then
                    hook_error "Python syntax error after edit: $EDIT_FILE_PATH"
                    return 1
                fi
            fi
            ;;
        "json")
            if ! hook_validate_json "$EDIT_FILE_PATH"; then
                hook_error "JSON syntax error after edit: $EDIT_FILE_PATH"
                return 1
            fi
            ;;
    esac
    
    hook_log "debug" "Post-edit syntax validation passed"
}

check_for_common_issues() {
    # Check for TODO comments
    if grep -i "todo\|fixme\|hack" "$EDIT_FILE_PATH" >/dev/null 2>&1; then
        hook_warning "TODO/FIXME comments found in: $EDIT_FILE_PATH"
    fi
    
    # Check for debugging statements
    if grep -E "console\.log\|print\(|debugger" "$EDIT_FILE_PATH" >/dev/null 2>&1; then
        hook_warning "Debugging statements found in: $EDIT_FILE_PATH"
    fi
    
    # Check for long lines
    local long_lines
    long_lines=$(awk 'length > 120 {print NR}' "$EDIT_FILE_PATH" | head -5)
    if [[ -n "$long_lines" ]]; then
        hook_warning "Long lines (>120 chars) found at lines: $long_lines"
    fi
}

update_git_index() {
    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
        # Check if file is tracked
        if git ls-files --error-unmatch "$EDIT_FILE_PATH" >/dev/null 2>&1; then
            # File is tracked, update index
            git add "$EDIT_FILE_PATH" 2>/dev/null || \
                hook_warning "Failed to update Git index for: $EDIT_FILE_PATH"
            hook_log "debug" "Git index updated for: $EDIT_FILE_PATH"
        else
            hook_log "debug" "File not tracked by Git: $EDIT_FILE_PATH"
        fi
    fi
}

main "$@"
```

## Best Practices

### Hook Development Guidelines

1. **Fail Fast Principle**
   ```bash
   # Always use strict error handling
   set -euo pipefail
   
   # Validate inputs early
   if [[ -z "$REQUIRED_VAR" ]]; then
       hook_error "Required variable not set: REQUIRED_VAR"
       exit 1
   fi
   ```

2. **Idempotent Operations**
   ```bash
   # Make hooks safe to run multiple times
   create_directory() {
       local dir="$1"
       if [[ ! -d "$dir" ]]; then
           mkdir -p "$dir" || return 1
       fi
   }
   ```

3. **Proper Cleanup**
   ```bash
   # Always clean up temporary resources
   cleanup() {
       local exit_code=$?
       rm -f "$temp_file"
       return $exit_code
   }
   trap cleanup EXIT
   ```

4. **Error Context**
   ```bash
   # Provide meaningful error messages
   validate_config() {
       if [[ ! -f "$config_file" ]]; then
           hook_error "Configuration file not found: $config_file"
           hook_error "Expected location: $(dirname "$config_file")"
           hook_error "Working directory: $PWD"
           return 1
       fi
   }
   ```

### Performance Optimization

1. **Minimize External Commands**
   ```bash
   # Avoid unnecessary command invocations
   # Good: Use shell built-ins
   if [[ -f "$file" ]]; then
       # ... 
   fi
   
   # Avoid: External test command
   if test -f "$file"; then
       # ...
   fi
   ```

2. **Parallel Execution**
   ```bash
   # Run independent operations in parallel
   validate_files() {
       local files=("$@")
       local pids=()
       
       for file in "${files[@]}"; do
           validate_single_file "$file" &
           pids+=($!)
       done
       
       # Wait for all validations
       for pid in "${pids[@]}"; do
           wait "$pid" || return 1
       done
   }
   ```

3. **Caching Results**
   ```bash
   # Cache expensive operations
   get_project_info() {
       local cache_file="${CLAUDE_CACHE_DIR}/project-info.json"
       local cache_ttl=3600  # 1 hour
       
       if [[ -f "$cache_file" ]]; then
           local age
           age=$(($(date +%s) - $(stat -c%Y "$cache_file")))
           if [[ $age -lt $cache_ttl ]]; then
               cat "$cache_file"
               return 0
           fi
       fi
       
       # Generate new project info
       generate_project_info > "$cache_file"
       cat "$cache_file"
   }
   ```

### Security Considerations

1. **Input Validation**
   ```bash
   # Validate all inputs
   validate_file_path() {
       local path="$1"
       
       # Check for path traversal
       if [[ "$path" == *..* ]]; then
           hook_error "Invalid path (contains ..): $path"
           return 1
       fi
       
       # Ensure path is within project
       local canonical_path
       canonical_path=$(realpath "$path")
       if [[ "$canonical_path" != "$PROJECT_ROOT"* ]]; then
           hook_error "Path outside project: $path"
           return 1
       fi
   }
   ```

2. **Safe File Operations**
   ```bash
   # Use safe file operations
   safe_write_file() {
       local file="$1"
       local content="$2"
       local temp_file
       
       temp_file=$(mktemp) || return 1
       
       # Write to temporary file first
       printf '%s' "$content" > "$temp_file" || {
           rm -f "$temp_file"
           return 1
       }
       
       # Atomic move
       mv "$temp_file" "$file" || {
           rm -f "$temp_file"
           return 1
       }
   }
   ```

3. **Environment Isolation**
   ```bash
   # Isolate hook environment
   run_isolated_hook() {
       local hook_script="$1"
       
       # Create clean environment
       env -i \
           HOME="$HOME" \
           PATH="$PATH" \
           CLAUDE_HOOK_UTILS="$CLAUDE_HOOK_UTILS" \
           PROJECT_ROOT="$PROJECT_ROOT" \
           bash "$hook_script"
   }
   ```

This comprehensive Hook System API documentation provides developers with everything needed to create powerful, safe, and efficient hooks for extending Claude Code Enhancer functionality.