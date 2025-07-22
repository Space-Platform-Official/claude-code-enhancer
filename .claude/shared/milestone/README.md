---
description: Comprehensive documentation for the milestone command shared utilities framework
---

# Milestone Shared Utilities Framework

This directory contains the shared utilities framework that provides the foundation for all milestone commands. The framework ensures consistency, reliability, and maintainability across the milestone command suite.

## Overview

The shared utilities framework consists of four core components:

- **[state.md](./state.md)** - State management with atomic operations and event logging
- **[validation.md](./validation.md)** - Cross-command validation and integrity checking
- **[utils.md](./utils.md)** - Common utility functions and helpers
- **[context.md](./context.md)** - Context management and session persistence
- **[git-integration.md](./git-integration.md)** - Git repository integration utilities

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Milestone Commands                        │
│  (create, update, complete, list, report, etc.)            │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                 Shared Utilities Framework                  │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │    State    │  │ Validation  │  │   Utils     │         │
│  │ Management  │  │ Framework   │  │ Functions   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐                          │
│  │   Context   │  │     Git     │                          │
│  │ Management  │  │ Integration │                          │
│  └─────────────┘  └─────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

## Component Integration

### State Management Layer
- **Atomic Operations**: All state changes use file locking and atomic writes
- **Event Logging**: Comprehensive JSONL event logs for audit and recovery
- **Session Management**: Multi-session support with state isolation
- **Backup & Recovery**: Automatic backups with rollback capabilities

### Validation Layer
- **Milestone Integrity**: Structure and dependency validation
- **Context Validation**: Environment and git state checking
- **Input Sanitization**: Secure parameter validation and sanitization
- **Dependency Graph**: Circular dependency detection and resolution

### Utility Layer
- **File Operations**: Safe atomic file operations and directory management
- **Date/Time Functions**: Timeline calculations and duration formatting
- **Progress Tracking**: Percentage calculations and velocity metrics
- **Reporting**: Flexible output formatting (text, JSON, markdown)

## Usage Patterns

### Basic Integration

To use the shared utilities in a milestone command:

```bash
#!/bin/bash

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_shared/state.md"
source "$SCRIPT_DIR/_shared/validation.md"
source "$SCRIPT_DIR/_shared/utils.md"
source "$SCRIPT_DIR/_shared/context.md"
source "$SCRIPT_DIR/_shared/git-integration.md"

# Example usage
main() {
    local milestone_id=$1
    
    # 1. Validate input
    local sanitized_id=$(sanitize_milestone_id "$milestone_id")
    if [ $? -ne 0 ]; then
        echo "$sanitized_id"
        exit 1
    fi
    
    # 2. Initialize state management
    init_milestone_state "$sanitized_id"
    
    # 3. Run comprehensive validation
    if ! run_comprehensive_validation "$sanitized_id"; then
        echo "Validation failed"
        exit 1
    fi
    
    # 4. Create session
    local session_id=$(create_milestone_session "$sanitized_id")
    
    # 5. Perform operations with state management
    acquire_state_lock "$sanitized_id"
    # ... your command logic here ...
    release_state_lock "$sanitized_id"
    
    # 6. End session
    end_milestone_session "$session_id"
}
```

### State Management Pattern

```bash
# Safe state modification pattern
modify_milestone_state() {
    local milestone_id=$1
    local new_data=$2
    
    # Acquire lock
    if ! acquire_state_lock "$milestone_id"; then
        return 1
    fi
    
    # Load current state
    local current_state=$(load_milestone_state "$milestone_id")
    
    # Modify state (your logic here)
    local modified_state=$(echo "$current_state" | jq ". + $new_data")
    
    # Save with automatic backup
    save_milestone_state "$milestone_id" "$modified_state"
    
    # Log the change
    log_milestone_event "$milestone_id" "state_modified" "$new_data"
    
    # Release lock
    release_state_lock "$milestone_id"
}
```

### Validation Pattern

```bash
# Comprehensive validation before operations
validate_before_operation() {
    local milestone_id=$1
    
    # Input validation
    local sanitized_id=$(sanitize_milestone_id "$milestone_id")
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Context validation
    if ! validate_milestone_context "$milestone_id" "execution"; then
        return 1
    fi
    
    # Dependency validation
    if ! validate_dependency_graph "$milestone_id"; then
        return 1
    fi
    
    # Milestone integrity
    if ! validate_milestone_integrity "$milestone_id" "strict"; then
        return 1
    fi
    
    return 0
}
```

### Error Handling Pattern

```bash
# Robust error handling with cleanup
execute_with_cleanup() {
    local milestone_id=$1
    local session_id=""
    local lock_acquired=false
    
    # Set up error trap
    trap 'cleanup_on_error "$milestone_id" "$session_id" "$lock_acquired"' ERR EXIT
    
    # Initialize
    session_id=$(create_milestone_session "$milestone_id")
    
    if acquire_state_lock "$milestone_id"; then
        lock_acquired=true
        
        # Your operation here
        perform_milestone_operation "$milestone_id"
        
        # Clean up on success
        release_state_lock "$milestone_id"
        lock_acquired=false
        end_milestone_session "$session_id"
    fi
    
    trap - ERR EXIT
}

cleanup_on_error() {
    local milestone_id=$1
    local session_id=$2
    local lock_acquired=$3
    
    [ "$lock_acquired" = true ] && release_state_lock "$milestone_id" "force"
    [ -n "$session_id" ] && end_milestone_session "$session_id"
    log_milestone_event "$milestone_id" "operation_failed" "{\"error\": \"Cleanup performed\"}"
}
```

## Integration Examples

### Creating a New Milestone Command

```bash
#!/bin/bash
# new-milestone-command.md

source "$(dirname "${BASH_SOURCE[0]}")/_shared/state.md"
source "$(dirname "${BASH_SOURCE[0]}")/_shared/validation.md"
source "$(dirname "${BASH_SOURCE[0]}")/_shared/utils.md"

main() {
    local milestone_id=$1
    local operation=$2
    
    # Validate and sanitize input
    milestone_id=$(validate_input_parameters "milestone_id" "$milestone_id")
    if [ $? -ne 0 ]; then
        echo "$milestone_id"
        exit 1
    fi
    
    # Initialize environment
    ensure_milestone_directory ".milestones/active"
    init_milestone_state "$milestone_id"
    
    # Run comprehensive validation
    if ! run_comprehensive_validation "$milestone_id"; then
        exit 1
    fi
    
    # Create session and acquire lock
    local session_id=$(create_milestone_session "$milestone_id")
    
    case "$operation" in
        "update")
            update_milestone_operation "$milestone_id"
            ;;
        "status")
            show_milestone_status "$milestone_id"
            ;;
        *)
            echo "ERROR: Unknown operation: $operation"
            exit 1
            ;;
    esac
    
    # Cleanup
    end_milestone_session "$session_id"
}

# Your specific operations
update_milestone_operation() {
    local milestone_id=$1
    
    if ! acquire_state_lock "$milestone_id"; then
        exit 1
    fi
    
    # Load current state
    local current_state=$(load_milestone_state "$milestone_id")
    
    # Perform your updates
    # ...
    
    # Save updated state
    save_milestone_state "$milestone_id" "$updated_state"
    
    # Log the operation
    log_milestone_event "$milestone_id" "milestone_updated" "{\"operation\": \"update\"}"
    
    release_state_lock "$milestone_id"
}

main "$@"
```

### Report Generation Integration

```bash
# Enhanced reporting with shared utilities
generate_enhanced_report() {
    local milestone_id=$1
    local format=${2:-"text"}
    
    # Validate milestone exists
    if ! validate_milestone_integrity "$milestone_id" "basic"; then
        return 1
    fi
    
    # Generate base report
    local report=$(generate_status_report "$milestone_id" "$format")
    
    # Add calculated metrics
    local progress=$(calculate_milestone_progress "$milestone_id")
    local velocity=$(calculate_milestone_velocity "$milestone_id")
    local estimated_completion=$(estimate_completion_date "$milestone_id" "$progress" "$velocity")
    
    case "$format" in
        "text")
            echo "$report"
            echo ""
            echo "Metrics:"
            echo "  Progress: $(format_progress_bar "$progress")"
            echo "  Velocity: $velocity tasks/day"
            echo "  Estimated completion: $estimated_completion"
            ;;
        "json")
            echo "$report" | jq ". + {\"metrics\": {\"progress_bar\": \"$(format_progress_bar "$progress")\", \"velocity\": $velocity, \"estimated_completion\": \"$estimated_completion\"}}"
            ;;
    esac
}
```

## Best Practices for Extension

### Adding New Utility Functions

1. **Follow Naming Conventions**:
   - Use descriptive function names with prefixes: `validate_`, `calculate_`, `format_`, `generate_`
   - Use snake_case for function names
   - Include parameter validation in all functions

2. **Error Handling**:
   - Always return meaningful exit codes
   - Use consistent error message format: "ERROR: description"
   - Implement proper cleanup in error conditions

3. **Documentation**:
   - Include function documentation with parameter descriptions
   - Provide usage examples for complex functions
   - Document return values and exit codes

### Function Template

```bash
# Function description
# Parameters:
#   $1 - parameter_name: description
#   $2 - optional_param: description (optional, default: value)
# Returns:
#   0 - success
#   1 - validation error
#   2 - operation error
# Example:
#   result=$(your_function "param1" "param2")
your_function() {
    local param1=$1
    local param2=${2:-"default_value"}
    
    # Input validation
    if [ -z "$param1" ]; then
        echo "ERROR: param1 is required"
        return 1
    fi
    
    # Function logic
    # ...
    
    # Return result
    echo "result"
    return 0
}
```

### Security Considerations

1. **Input Sanitization**: Always sanitize user inputs using `validate_input_parameters`
2. **File Operations**: Use atomic operations for all file writes
3. **Path Validation**: Prevent path traversal attacks in file operations
4. **Lock Management**: Always use proper locking for concurrent operations
5. **Temp File Cleanup**: Clean up temporary files in error conditions

### Performance Guidelines

1. **Caching**: Cache expensive operations like progress calculations
2. **Batching**: Batch multiple state changes into single operations
3. **Cleanup**: Regular cleanup of old logs and backup files
4. **Validation Levels**: Use appropriate validation levels (basic vs strict)

## Testing Integration

The shared utilities support testing through:

- **Dry-run modes**: Most functions support dry-run parameters
- **Mock data**: Test data generators for milestone structures
- **Validation hooks**: Automated validation in CI/CD pipelines
- **Event inspection**: Query event logs for operation verification

## Troubleshooting

### Common Issues

1. **Lock Acquisition Timeouts**:
   - Check for stale locks: `.milestones/state/.locks/`
   - Verify file permissions
   - Check for competing processes

2. **State Corruption**:
   - Use `recover_milestone_state` function
   - Check backup files in `.milestones/state/backups/`
   - Verify JSON syntax with validation functions

3. **Validation Failures**:
   - Run `run_comprehensive_validation` with verbose output
   - Check dependency graph for circular references
   - Verify milestone file structure

### Debug Mode

Enable debug mode by setting environment variables:

```bash
export MILESTONE_DEBUG=1
export MILESTONE_VERBOSE=1
```

This enables detailed logging and validation output for troubleshooting.

## Migration and Upgrades

When upgrading the shared utilities framework:

1. **Backup Current State**: Use `archive_milestone_files` before upgrades
2. **Test Compatibility**: Run validation suite against existing milestones
3. **Gradual Migration**: Update one command at a time
4. **Version Tracking**: Maintain version compatibility in state files

---

This shared utilities framework provides a robust foundation for milestone command development with comprehensive state management, validation, and utility functions. Follow the established patterns and best practices to ensure consistency and reliability across all milestone operations.