# Command Development Guide

Comprehensive guide for building new commands and extending existing command workflows in the Claude Code Enhancer system.

## Command System Architecture

### Command Hierarchy

The Claude Code Enhancer uses a sophisticated hierarchical command system with folder-first detection:

```
.claude/commands/
├── git/                         # Git integration commands
│   ├── _shared/                 # Shared utilities for git commands
│   │   ├── config.md
│   │   ├── hooks.md
│   │   ├── security.md
│   │   └── utils.md
│   ├── branch.md                # Branch management
│   ├── commit.md                # Commit operations
│   ├── pr.md                    # Pull request management
│   └── workflows/               # Git workflow commands
│       ├── feature.md
│       ├── hotfix.md
│       └── release.md
├── quality/                     # Quality assurance suite
│   ├── _shared/
│   │   ├── orchestration.md
│   │   ├── safety.md
│   │   └── utils.md
│   ├── cleanup.md               # Code cleanup
│   ├── dedupe.md                # Duplicate detection
│   ├── format.md                # Code formatting
│   └── verify.md                # Quality verification
├── milestone/                   # Milestone management
│   ├── _shared/
│   │   ├── context.md
│   │   ├── git-integration.md
│   │   ├── state.md
│   │   └── utils.md
│   ├── execute.md               # Milestone execution
│   ├── plan.md                  # Milestone planning
│   └── status.md                # Status tracking
└── test/                        # Testing commands
    ├── _shared/
    │   ├── coverage.md
    │   ├── fixtures.md
    │   ├── runners.md
    │   └── utils.md
    ├── unit.md                  # Unit testing
    ├── integration.md           # Integration testing
    └── e2e.md                   # End-to-end testing
```

### Command Detection and Resolution

The system uses **folder-first detection** for command resolution:

```bash
# Command resolution logic
resolve_command() {
    local command_path="$1"
    local full_path=".claude/commands/$command_path"
    
    # 1. Check for folder-based command
    if [[ -d "$full_path" ]]; then
        # Look for main command file
        if [[ -f "$full_path/main.md" ]]; then
            echo "$full_path/main.md"
            return 0
        fi
        
        # Look for index file
        if [[ -f "$full_path/index.md" ]]; then
            echo "$full_path/index.md"
            return 0
        fi
        
        # Look for command with same name as folder
        local folder_name=$(basename "$full_path")
        if [[ -f "$full_path/$folder_name.md" ]]; then
            echo "$full_path/$folder_name.md"
            return 0
        fi
        
        # List available subcommands
        list_subcommands "$full_path"
        return 0
    fi
    
    # 2. Check for file-based command
    if [[ -f "$full_path.md" ]]; then
        echo "$full_path.md"
        return 0
    fi
    
    # 3. Command not found
    echo "Command not found: $command_path" >&2
    return 1
}
```

### Shared Utilities Framework

Each command category has a `_shared/` directory containing common utilities:

#### Utilities Architecture

```bash
# _shared/utils.md - Common utility functions

# File and directory operations
file_exists() { [[ -f "$1" ]]; }
directory_exists() { [[ -d "$1" ]]; }
create_directory() { mkdir -p "$1"; }

# Progress tracking
track_progress() {
    local current="$1"
    local total="$2"
    local message="$3"
    
    local percentage=$((current * 100 / total))
    echo "[$percentage%] $message"
}

# Error handling
handle_error() {
    local error_code="$1"
    local error_message="$2"
    local recovery_function="${3:-}"
    
    echo "Error [$error_code]: $error_message" >&2
    
    if [[ -n "$recovery_function" ]] && command -v "$recovery_function" >/dev/null; then
        echo "Attempting recovery with $recovery_function..."
        "$recovery_function" "$error_code" "$error_message"
    fi
    
    return "$error_code"
}

# Configuration management
load_command_config() {
    local command_name="$1"
    local config_file=".claude/config/$command_name.json"
    
    if [[ -f "$config_file" ]]; then
        source_json_config "$config_file"
    fi
}
```

#### Safety Framework

```bash
# _shared/safety.md - Safety mechanisms

# Pre-operation validation
validate_operation_safety() {
    local operation="$1"
    
    # Git status check
    if ! validate_git_status; then
        return 1
    fi
    
    # File permissions check
    if ! validate_file_permissions "$operation"; then
        return 1
    fi
    
    # Disk space check
    if ! validate_disk_space "$operation"; then
        return 1
    fi
    
    return 0
}

# Backup creation
create_operation_backup() {
    local operation="$1"
    local backup_id="backup-$(date +%s)-$operation"
    local backup_dir=".claude/backups/$backup_id"
    
    mkdir -p "$backup_dir"
    
    # Create git snapshot
    if git rev-parse --git-dir >/dev/null 2>&1; then
        git stash push -u -m "Claude backup: $operation" 2>/dev/null || true
        echo "$(git rev-parse HEAD)" > "$backup_dir/git-commit"
    fi
    
    # Backup critical files
    backup_critical_files "$backup_dir"
    
    echo "$backup_id"
}

# Rollback mechanism
execute_rollback() {
    local backup_id="$1"
    local backup_dir=".claude/backups/$backup_id"
    
    if [[ ! -d "$backup_dir" ]]; then
        echo "Backup not found: $backup_id" >&2
        return 1
    fi
    
    # Restore git state
    if [[ -f "$backup_dir/git-commit" ]]; then
        local commit=$(cat "$backup_dir/git-commit")
        git reset --hard "$commit"
        git stash pop 2>/dev/null || true
    fi
    
    # Restore files
    restore_critical_files "$backup_dir"
    
    echo "Rollback completed: $backup_id"
}
```

## Command Development Process

### Research Phase

Before developing any command, follow the **Research → Plan → Implement** workflow:

1. **Analyze Existing Commands**
   ```bash
   # Study similar commands
   find .claude/commands -name "*.md" | xargs grep -l "similar_functionality"
   
   # Review shared utilities
   ls -la .claude/commands/*/\_shared/
   
   # Understand command patterns
   analyze_command_patterns
   ```

2. **Assess Complexity Level**
   - 🟢 **Simple**: Single operation, existing patterns, minimal dependencies
   - 🟡 **Medium**: Multiple operations, new patterns, moderate integration
   - 🔴 **Complex**: System-wide changes, new architecture, extensive integration

3. **Plan Command Architecture**
   ```markdown
   # Command Planning Document
   
   ## Command Overview
   - Name: `claude example-command`
   - Category: `utilities`
   - Complexity: Simple/Medium/Complex
   - Dependencies: List of required tools/commands
   
   ## Functionality
   - Primary purpose and use cases
   - Input parameters and options
   - Expected outputs and side effects
   
   ## Integration Points
   - Shared utilities to use
   - Other commands to coordinate with
   - External tools to integrate
   
   ## Safety Considerations
   - Risk assessment
   - Backup requirements
   - Rollback procedures
   ```

### Implementation Phase

#### Step 1: Create Command Structure

```bash
# For simple commands (single file)
touch .claude/commands/example-command.md

# For complex commands (folder-based)
mkdir -p .claude/commands/example-category
touch .claude/commands/example-category/main.md
touch .claude/commands/example-category/subcommand.md

# Create shared utilities if needed
mkdir -p .claude/commands/example-category/_shared
touch .claude/commands/example-category/_shared/utils.md
touch .claude/commands/example-category/_shared/safety.md
```

#### Step 2: Implement Command Header

```markdown
---
description: Brief description of the command purpose
allowed-tools: [list, of, allowed, tools, and, commands]
complexity: simple|medium|complex
category: command_category
version: 1.0.0
requires: [dependencies, external_tools]
author: "Developer Name"
created: "2023-12-07"
updated: "2023-12-07"
---

# Command Name

Detailed description of what this command does and when to use it.

## Purpose

Clear explanation of the command's primary purpose, target use cases, and benefits.

## Prerequisites

- Required tools (e.g., git, node, python)
- Environment setup requirements
- Permission requirements
- File/directory structure expectations

## Usage

```bash
claude command-name [options] [arguments]
```

### Options

- `--option1 <value>`: Description of option 1
- `--option2`: Boolean flag description
- `--help, -h`: Show help information
- `--verbose, -v`: Enable verbose output
- `--dry-run`: Show what would be done without executing

### Arguments

- `argument1`: Description of required argument
- `[optional-arg]`: Description of optional argument

### Examples

#### Basic Usage
```bash
claude command-name
```

#### Advanced Usage
```bash
claude command-name --option1 value --option2 argument1
```

#### Complex Workflow
```bash
# Multi-step workflow example
claude command-name --prepare
claude command-name --execute --option1 value
claude command-name --verify
```
```

#### Step 3: Implement Core Logic

```markdown
## Implementation

### Pre-execution Validation

```bash
# Source shared utilities
source .claude/commands/_shared/utils.md
source .claude/commands/category/_shared/safety.md

# Validate prerequisites
validate_prerequisites() {
    # Check required tools
    local required_tools=("git" "node" "npm")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            handle_error 1 "Required tool not found: $tool" "suggest_tool_installation"
            return 1
        fi
    done
    
    # Check environment
    if ! validate_environment; then
        handle_error 2 "Environment validation failed" "setup_environment_guide"
        return 1
    fi
    
    # Check permissions
    if ! validate_permissions; then
        handle_error 3 "Insufficient permissions" "permission_guide"
        return 1
    fi
    
    return 0
}

# Environment validation
validate_environment() {
    # Check if we're in a valid project directory
    if [[ ! -f "package.json" && ! -f "pyproject.toml" && ! -f "Cargo.toml" ]]; then
        echo "Error: Not in a recognized project directory" >&2
        return 1
    fi
    
    # Check git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi
    
    return 0
}

# Permission validation
validate_permissions() {
    # Check write permissions for target directories
    local target_dirs=("src" "tests" "docs")
    for dir in "${target_dirs[@]}"; do
        if [[ -d "$dir" && ! -w "$dir" ]]; then
            echo "Error: No write permission for directory: $dir" >&2
            return 1
        fi
    done
    
    return 0
}
```

### Main Command Logic

```bash
# Main execution function
execute_command() {
    local option1="$1"
    local option2="$2"
    local target_arg="$3"
    
    # Progress tracking
    local total_steps=5
    local current_step=0
    
    # Step 1: Safety checks and backup
    ((current_step++))
    track_progress "$current_step" "$total_steps" "Performing safety checks..."
    
    if ! validate_operation_safety "command-name"; then
        handle_error 10 "Safety validation failed" "safety_recovery"
        return 1
    fi
    
    local backup_id=$(create_operation_backup "command-name")
    
    # Step 2: Parse and validate inputs
    ((current_step++))
    track_progress "$current_step" "$total_steps" "Validating inputs..."
    
    if ! validate_inputs "$option1" "$option2" "$target_arg"; then
        execute_rollback "$backup_id"
        return 1
    fi
    
    # Step 3: Core operation
    ((current_step++))
    track_progress "$current_step" "$total_steps" "Executing main operation..."
    
    if ! perform_main_operation "$option1" "$option2" "$target_arg"; then
        handle_error 20 "Main operation failed" "operation_recovery"
        execute_rollback "$backup_id"
        return 1
    fi
    
    # Step 4: Verification
    ((current_step++))
    track_progress "$current_step" "$total_steps" "Verifying results..."
    
    if ! verify_operation_results; then
        handle_error 30 "Verification failed" "verification_recovery"
        execute_rollback "$backup_id"
        return 1
    fi
    
    # Step 5: Cleanup and finalization
    ((current_step++))
    track_progress "$current_step" "$total_steps" "Finalizing..."
    
    cleanup_operation
    cleanup_backup "$backup_id"  # Remove backup on success
    
    echo "Command completed successfully!"
    return 0
}

# Input validation
validate_inputs() {
    local option1="$1"
    local option2="$2"
    local target_arg="$3"
    
    # Validate option1
    if [[ -n "$option1" && ! "$option1" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Error: Invalid option1 format: $option1" >&2
        return 1
    fi
    
    # Validate target argument
    if [[ -n "$target_arg" && ! -e "$target_arg" ]]; then
        echo "Error: Target does not exist: $target_arg" >&2
        return 1
    fi
    
    return 0
}

# Core operation implementation
perform_main_operation() {
    local option1="$1"
    local option2="$2"
    local target_arg="$3"
    
    # Implementation depends on command purpose
    case "$option1" in
        "format")
            perform_formatting_operation "$target_arg"
            ;;
        "analyze")
            perform_analysis_operation "$target_arg"
            ;;
        "transform")
            perform_transformation_operation "$option2" "$target_arg"
            ;;
        *)
            echo "Error: Unknown operation: $option1" >&2
            return 1
            ;;
    esac
}

# Result verification
verify_operation_results() {
    # Verify file integrity
    if ! verify_file_integrity; then
        echo "Error: File integrity check failed" >&2
        return 1
    fi
    
    # Verify functionality preservation
    if ! verify_functionality_preservation; then
        echo "Error: Functionality verification failed" >&2
        return 1
    fi
    
    # Verify expected outputs
    if ! verify_expected_outputs; then
        echo "Error: Expected outputs not found" >&2
        return 1
    fi
    
    return 0
}
```

### Error Recovery

```bash
# Error recovery functions
safety_recovery() {
    local error_code="$1"
    local error_message="$2"
    
    echo "Safety recovery initiated for: $error_message"
    
    case "$error_code" in
        "10")
            echo "Suggestion: Ensure git working directory is clean"
            echo "Run: git status"
            ;;
        "11")
            echo "Suggestion: Check file permissions"
            echo "Run: ls -la"
            ;;
        *)
            echo "General safety recovery suggestions:"
            echo "- Check git status"
            echo "- Verify file permissions"
            echo "- Ensure sufficient disk space"
            ;;
    esac
}

operation_recovery() {
    local error_code="$1"
    local error_message="$2"
    
    echo "Operation recovery initiated for: $error_message"
    
    # Attempt automatic recovery based on error type
    case "$error_code" in
        "20")
            echo "Attempting to recover from operation failure..."
            attempt_operation_retry
            ;;
        "21")
            echo "Attempting to resolve dependency issues..."
            resolve_dependencies
            ;;
        *)
            echo "Manual intervention may be required"
            ;;
    esac
}

verification_recovery() {
    local error_code="$1"
    local error_message="$2"
    
    echo "Verification recovery initiated for: $error_message"
    
    # Provide specific guidance based on verification failure
    case "$error_code" in
        "30")
            echo "File integrity check failed"
            echo "Suggestion: Review file modifications"
            ;;
        "31")
            echo "Functionality verification failed"
            echo "Suggestion: Run tests to identify issues"
            ;;
        *)
            echo "General verification recovery:"
            echo "- Review command output"
            echo "- Check log files"
            echo "- Verify expected changes"
            ;;
    esac
}
```
```

#### Step 4: Add Integration Support

```markdown
## Integration

### Shared Utilities Integration

```bash
# Source required shared utilities
source .claude/commands/_shared/utils.md
source .claude/commands/category/_shared/safety.md
source .claude/commands/category/_shared/orchestration.md

# Use shared functions
use_shared_progress_tracking
use_shared_error_handling
use_shared_file_operations
```

### Agent Coordination

```bash
# Spawn agents for complex operations
if [[ "$COMPLEXITY" == "complex" ]]; then
    # Spawn progress monitoring agent
    spawn_agent "progress_monitor" "{
        'operation': 'command-name',
        'total_steps': $total_steps,
        'update_interval': 1
    }"
    
    # Spawn integrity validation agent
    spawn_agent "integrity_validator" "{
        'validation_interval': 5,
        'critical_files': ['src/', 'tests/', 'package.json']
    }"
    
    # Spawn dependency tracking agent
    spawn_agent "dependency_tracker" "{
        'track_external_deps': true,
        'monitor_network': true
    }"
fi

# Coordinate with other commands
coordinate_with_quality_suite() {
    # Ensure quality checks pass before proceeding
    if ! claude quality verify --quick; then
        echo "Error: Quality checks failed" >&2
        return 1
    fi
}

coordinate_with_git_commands() {
    # Integrate with git workflow
    if [[ "$GIT_INTEGRATION" == "true" ]]; then
        claude git status
        
        if [[ "$AUTO_COMMIT" == "true" ]]; then
            claude git commit "Automated commit from command-name"
        fi
    fi
}
```

### External Tool Integration

```bash
# Integrate with external tools
integrate_external_tools() {
    # Node.js/npm integration
    if [[ -f "package.json" ]]; then
        echo "Detected Node.js project"
        
        # Run npm scripts if available
        if npm run --silent 2>/dev/null | grep -q "build"; then
            npm run build
        fi
        
        if npm run --silent 2>/dev/null | grep -q "test"; then
            npm test
        fi
    fi
    
    # Python integration
    if [[ -f "pyproject.toml" || -f "requirements.txt" ]]; then
        echo "Detected Python project"
        
        # Activate virtual environment if available
        if [[ -d "venv" ]]; then
            source venv/bin/activate
        fi
        
        # Run pytest if available
        if command -v pytest >/dev/null 2>&1; then
            pytest
        fi
    fi
    
    # Go integration
    if [[ -f "go.mod" ]]; then
        echo "Detected Go project"
        
        # Run go commands
        go fmt ./...
        go test ./...
        go build
    fi
}
```
```

#### Step 5: Add Testing Support

```markdown
## Testing

### Unit Tests

```bash
# Test individual functions
test_validate_inputs() {
    # Test valid inputs
    if validate_inputs "format" "true" "src/main.js"; then
        echo "✓ Valid inputs accepted"
    else
        echo "✗ Valid inputs rejected"
        return 1
    fi
    
    # Test invalid inputs
    if validate_inputs "invalid@option" "" "/nonexistent/file"; then
        echo "✗ Invalid inputs accepted"
        return 1
    else
        echo "✓ Invalid inputs rejected"
    fi
}

test_main_operation() {
    # Create test environment
    mkdir -p test-env
    cd test-env
    
    # Set up test files
    echo "test content" > test-file.txt
    
    # Test operation
    if perform_main_operation "test" "true" "test-file.txt"; then
        echo "✓ Main operation succeeded"
    else
        echo "✗ Main operation failed"
        cd ..
        rm -rf test-env
        return 1
    fi
    
    # Cleanup
    cd ..
    rm -rf test-env
}

test_error_recovery() {
    # Test recovery mechanisms
    local test_backup=$(create_operation_backup "test")
    
    # Simulate error condition
    echo "corrupted" > important-file.txt
    
    # Test recovery
    if execute_rollback "$test_backup"; then
        echo "✓ Error recovery succeeded"
    else
        echo "✗ Error recovery failed"
        return 1
    fi
}
```

### Integration Tests

```bash
# Test command integration with system
test_command_integration() {
    # Test full command workflow
    local test_project="test-integration-$(date +%s)"
    mkdir -p "$test_project"
    cd "$test_project"
    
    # Initialize test project
    git init
    echo "# Test Project" > README.md
    git add README.md
    git commit -m "Initial commit"
    
    # Test command execution
    if claude command-name --option1 test --option2; then
        echo "✓ Command integration successful"
    else
        echo "✗ Command integration failed"
        cd ..
        rm -rf "$test_project"
        return 1
    fi
    
    # Verify results
    verify_integration_results
    
    # Cleanup
    cd ..
    rm -rf "$test_project"
}

test_agent_coordination() {
    # Test multi-agent coordination
    export CLAUDE_AGENT_DEBUG=1
    
    # Execute command with agents
    if claude command-name --complex-operation; then
        echo "✓ Agent coordination successful"
    else
        echo "✗ Agent coordination failed"
        return 1
    fi
    
    # Verify agent states
    verify_agent_coordination
}
```

### Performance Tests

```bash
# Test command performance
test_command_performance() {
    local start_time=$(date +%s.%N)
    
    # Execute command
    claude command-name --performance-test
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    # Check performance threshold
    local max_duration=30  # 30 seconds
    if (( $(echo "$duration < $max_duration" | bc -l) )); then
        echo "✓ Performance test passed: ${duration}s"
    else
        echo "✗ Performance test failed: ${duration}s (limit: ${max_duration}s)"
        return 1
    fi
}
```
```

## Advanced Command Features

### Multi-Agent Command Coordination

Commands can leverage the multi-agent system for complex operations:

```bash
# Advanced agent coordination
coordinate_complex_operation() {
    local operation_id="$(generate_operation_id)"
    
    # Spawn specialized agents
    local executor_agent=$(spawn_agent "task_executor" "{
        'operation_id': '$operation_id',
        'task_queue': ['analyze', 'transform', 'verify'],
        'parallel_tasks': 3
    }")
    
    local monitor_agent=$(spawn_agent "progress_monitor" "{
        'operation_id': '$operation_id',
        'update_interval': 2,
        'progress_callback': 'update_progress_display'
    }")
    
    local validator_agent=$(spawn_agent "integrity_validator" "{
        'operation_id': '$operation_id',
        'validation_rules': ['syntax', 'semantics', 'performance'],
        'continuous_monitoring': true
    }")
    
    # Set up agent communication
    setup_agent_communication "$operation_id" "$executor_agent" "$monitor_agent" "$validator_agent"
    
    # Execute coordinated workflow
    coordinate_agent_execution "$operation_id"
    
    # Wait for completion
    wait_for_agent_completion "$operation_id"
    
    # Aggregate results
    aggregate_agent_results "$operation_id"
}
```

### Progressive Complexity Implementation

Commands should implement progressive complexity based on the system's triage:

```bash
# Progressive complexity implementation
execute_with_complexity_awareness() {
    local complexity="$1"
    local operation="$2"
    
    case "$complexity" in
        "simple")
            # Simple execution path
            execute_simple_operation "$operation"
            ;;
        "medium")
            # Medium complexity with user justification
            echo "This operation requires medium complexity changes."
            echo "Justification: Multiple file coordination needed."
            echo "Alternative: Use --simple flag for basic operation."
            
            if [[ "$USER_OVERRIDE" != "true" ]]; then
                read -p "Continue with medium complexity? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo "Operation cancelled. Use --simple for basic operation."
                    return 1
                fi
            fi
            
            execute_medium_operation "$operation"
            ;;
        "complex")
            # Complex execution requiring explicit approval
            echo "WARNING: This operation requires complex changes."
            echo "Impact: System-wide modifications affecting multiple components."
            echo "Time estimate: >2 hours"
            echo "Simple alternative: Use --basic flag for minimal changes."
            
            if [[ "$USER_OVERRIDE" != "complex" ]]; then
                read -p "Proceed with complex operation? (yes/NO): " -r
                if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
                    echo "Complex operation cancelled."
                    echo "Consider using simpler alternatives or contact support."
                    return 1
                fi
            fi
            
            execute_complex_operation "$operation"
            ;;
    esac
}
```

### Command Orchestration

Commands can orchestrate complex workflows involving multiple sub-commands:

```bash
# Command orchestration pattern
orchestrate_workflow() {
    local workflow_spec="$1"
    local workflow_id="$(generate_workflow_id)"
    
    # Parse workflow specification
    local commands=($(parse_workflow_commands "$workflow_spec"))
    local dependencies=($(parse_workflow_dependencies "$workflow_spec"))
    
    # Build execution plan
    local execution_plan=($(build_execution_plan "${commands[@]}" "${dependencies[@]}"))
    
    # Execute workflow
    for phase in "${execution_plan[@]}"; do
        echo "Executing workflow phase: $phase"
        
        # Parse phase commands
        local phase_commands=($(parse_phase_commands "$phase"))
        
        # Execute phase
        if [[ "${#phase_commands[@]}" -gt 1 ]]; then
            # Parallel execution
            execute_commands_parallel "${phase_commands[@]}"
        else
            # Sequential execution
            execute_command "${phase_commands[0]}"
        fi
        
        # Verify phase completion
        if ! verify_phase_completion "$phase"; then
            echo "Error: Workflow phase failed: $phase"
            rollback_workflow "$workflow_id"
            return 1
        fi
    done
    
    echo "Workflow completed successfully: $workflow_id"
}
```

## Command Documentation Standards

### Documentation Structure

Every command must include comprehensive documentation:

```markdown
## Documentation

### Synopsis

Brief one-line description of the command.

### Description

Detailed explanation of the command's purpose, functionality, and use cases.

### Options

Complete list of all command options with descriptions, defaults, and examples.

### Examples

Practical examples covering common use cases:

#### Basic Usage
```bash
claude command-name
```

#### Advanced Usage
```bash
claude command-name --advanced-option value
```

#### Integration Examples
```bash
# Use with other commands
claude quality format && claude command-name

# Use in scripts
if claude command-name --check; then
    echo "Ready to proceed"
fi
```

### Exit Codes

- 0: Success
- 1: General error
- 2: Invalid arguments
- 3: Prerequisites not met
- 10: Safety validation failed
- 20: Operation failed
- 30: Verification failed

### Files

List of files and directories the command interacts with:

- `.claude/config/command-name.json`: Configuration file
- `.claude/state/command-name/`: State directory
- `.claude/backups/`: Backup storage

### Environment Variables

- `CLAUDE_COMMAND_NAME_CONFIG`: Override default configuration
- `CLAUDE_COMMAND_NAME_VERBOSE`: Enable verbose output
- `CLAUDE_COMMAND_NAME_DRY_RUN`: Enable dry-run mode

### See Also

- Related commands
- External tool documentation
- Development guides
```

### Help System Integration

Commands should integrate with the built-in help system:

```bash
# Help function implementation
show_command_help() {
    local command_name="$1"
    
    cat << EOF
Usage: claude $command_name [options] [arguments]

Description:
$(extract_description_from_command "$command_name")

Options:
$(extract_options_from_command "$command_name")

Examples:
$(extract_examples_from_command "$command_name")

For more information, see: claude help $command_name
EOF
}

# Auto-completion support
generate_completion_script() {
    local command_name="$1"
    
    # Extract options for bash completion
    local options=($(extract_options_list "$command_name"))
    
    # Generate completion script
    cat << EOF
_claude_${command_name}_completion() {
    local cur=\${COMP_WORDS[COMP_CWORD]}
    local opts="${options[*]}"
    
    COMPREPLY=(\$(compgen -W "\$opts" -- \$cur))
}

complete -F _claude_${command_name}_completion claude
EOF
}
```

## Command Testing and Quality Assurance

### Automated Testing

All commands must include comprehensive test suites:

```bash
# Command test suite
test_command_comprehensive() {
    local command_name="$1"
    
    echo "Testing command: $command_name"
    
    # Unit tests
    test_command_validation "$command_name"
    test_command_execution "$command_name"
    test_command_error_handling "$command_name"
    
    # Integration tests
    test_command_integration "$command_name"
    test_command_coordination "$command_name"
    
    # Performance tests
    test_command_performance "$command_name"
    
    # Security tests
    test_command_security "$command_name"
    
    echo "All tests passed for: $command_name"
}
```

### Quality Gates

Commands must pass quality gates before deployment:

1. **Syntax Validation**: Shell script syntax checking
2. **Functionality Testing**: Unit and integration tests
3. **Performance Validation**: Performance benchmarks
4. **Security Review**: Security vulnerability scanning
5. **Documentation Review**: Documentation completeness check
6. **Integration Testing**: Integration with existing commands

### Continuous Integration

```yaml
# .github/workflows/command-validation.yml
name: Command Validation

on:
  push:
    paths:
      - '.claude/commands/**'
  pull_request:
    paths:
      - '.claude/commands/**'

jobs:
  validate-commands:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Validate Command Syntax
        run: |
          find .claude/commands -name "*.md" -exec shellcheck {} \;
      
      - name: Test Commands
        run: |
          ./test/test-commands.sh
      
      - name: Performance Test
        run: |
          ./test/performance-test-commands.sh
      
      - name: Security Scan
        run: |
          ./test/security-scan-commands.sh
```

## Best Practices for Command Development

### Design Principles

1. **Single Responsibility**: Each command should have one clear purpose
2. **Composability**: Commands should work well together
3. **Safety First**: Always include safety mechanisms and rollback
4. **Progressive Enhancement**: Support different complexity levels
5. **Clear Interface**: Intuitive options and clear documentation
6. **Error Handling**: Comprehensive error handling with recovery guidance
7. **Performance Awareness**: Optimize for common use cases

### Implementation Guidelines

1. **Use Shared Utilities**: Leverage existing shared utilities
2. **Follow Patterns**: Maintain consistency with existing commands
3. **Validate Inputs**: Thoroughly validate all inputs and parameters
4. **Provide Feedback**: Give clear progress indication and status updates
5. **Support Dry Run**: Allow users to preview changes
6. **Enable Verbose Mode**: Provide detailed output when requested
7. **Test Thoroughly**: Include comprehensive tests

### Maintenance Standards

1. **Regular Updates**: Keep commands current with ecosystem changes
2. **User Feedback**: Incorporate user feedback and suggestions
3. **Performance Monitoring**: Monitor and optimize performance
4. **Security Updates**: Address security issues promptly
5. **Documentation**: Keep documentation in sync with implementation
6. **Backward Compatibility**: Maintain compatibility when possible

---

**Next**: [Agent System Development](./agent-system-development.md) - Multi-agent coordination patterns

**See Also**:
- [Template Development](./template-development.md) - Creating templates
- [Architecture Overview](./architecture-overview.md) - System design
- [Testing Guidelines](./testing-guidelines.md) - Testing strategies