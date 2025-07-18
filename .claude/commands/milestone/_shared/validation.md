---
description: Cross-command validation framework for milestone integrity, dependency checking, and context validation
---

# Milestone Validation Framework

Comprehensive validation framework ensuring milestone integrity, dependency consistency, context validation, and secure input handling across all milestone operations.

## Milestone Integrity Validation

```bash
# Validate milestone structure and integrity
validate_milestone_integrity() {
    local milestone_id=$1
    local validation_mode=${2:-"strict"}
    local errors=0
    local warnings=0
    
    echo "=== Milestone Integrity Validation: $milestone_id ==="
    
    # Check milestone file exists
    local milestone_file=".milestones/active/$milestone_id.yaml"
    if [ ! -f "$milestone_file" ]; then
        echo "❌ ERROR: Milestone file not found: $milestone_file"
        ((errors++))
        return $errors
    fi
    
    # Validate YAML syntax
    if ! yq e '.' "$milestone_file" >/dev/null 2>&1; then
        echo "❌ ERROR: Invalid YAML syntax in milestone file"
        ((errors++))
        return $errors
    fi
    
    # Validate required fields
    local required_fields=("id" "title" "description" "status" "created_at")
    for field in "${required_fields[@]}"; do
        local value=$(yq e ".$field" "$milestone_file" 2>/dev/null)
        if [ "$value" = "null" ] || [ -z "$value" ]; then
            echo "❌ ERROR: Missing required field: $field"
            ((errors++))
        fi
    done
    
    # Validate milestone ID consistency
    local file_milestone_id=$(yq e '.id' "$milestone_file")
    if [ "$file_milestone_id" != "$milestone_id" ]; then
        echo "❌ ERROR: Milestone ID mismatch. File: $file_milestone_id, Expected: $milestone_id"
        ((errors++))
    fi
    
    # Validate status values
    local status=$(yq e '.status' "$milestone_file")
    local valid_statuses=("planning" "in_progress" "blocked" "completed" "cancelled")
    local status_valid=false
    for valid_status in "${valid_statuses[@]}"; do
        if [ "$status" = "$valid_status" ]; then
            status_valid=true
            break
        fi
    done
    
    if [ "$status_valid" = false ]; then
        echo "❌ ERROR: Invalid status: $status. Valid values: ${valid_statuses[*]}"
        ((errors++))
    fi
    
    # Validate date formats
    local created_at=$(yq e '.created_at' "$milestone_file")
    if ! date -d "$created_at" >/dev/null 2>&1 && ! date -j -f "%Y-%m-%dT%H:%M:%SZ" "$created_at" >/dev/null 2>&1; then
        echo "❌ ERROR: Invalid created_at date format: $created_at"
        ((errors++))
    fi
    
    # Validate progress percentage
    local progress=$(yq e '.progress.percentage // 0' "$milestone_file")
    if ! [[ "$progress" =~ ^[0-9]+$ ]] || [ "$progress" -lt 0 ] || [ "$progress" -gt 100 ]; then
        echo "❌ ERROR: Invalid progress percentage: $progress (must be 0-100)"
        ((errors++))
    fi
    
    # Validate task structure if tasks exist
    local task_count=$(yq e '.tasks | length' "$milestone_file" 2>/dev/null || echo "0")
    if [ "$task_count" -gt 0 ]; then
        local task_errors=$(validate_milestone_tasks "$milestone_id")
        ((errors+=task_errors))
    fi
    
    # Additional strict mode validations
    if [ "$validation_mode" = "strict" ]; then
        # Check for duplicate task IDs
        local duplicate_tasks=$(yq e '.tasks[].id' "$milestone_file" 2>/dev/null | sort | uniq -d)
        if [ -n "$duplicate_tasks" ]; then
            echo "❌ ERROR: Duplicate task IDs found: $duplicate_tasks"
            ((errors++))
        fi
        
        # Validate estimation fields
        local estimation=$(yq e '.estimation.hours // null' "$milestone_file")
        if [ "$estimation" != "null" ] && ! [[ "$estimation" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
            echo "⚠️  WARNING: Invalid estimation hours format: $estimation"
            ((warnings++))
        fi
    fi
    
    # Summary
    if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
        echo "✅ Milestone integrity validation passed"
    elif [ $errors -eq 0 ]; then
        echo "⚠️  Milestone validation completed with $warnings warnings"
    else
        echo "❌ Milestone validation failed with $errors errors and $warnings warnings"
    fi
    
    return $errors
}

# Validate milestone tasks
validate_milestone_tasks() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local errors=0
    
    # Required task fields
    local required_task_fields=("id" "title" "status")
    
    # Get task count
    local task_count=$(yq e '.tasks | length' "$milestone_file" 2>/dev/null || echo "0")
    
    for ((i=0; i<task_count; i++)); do
        local task_prefix=".tasks[$i]"
        
        # Validate required fields
        for field in "${required_task_fields[@]}"; do
            local value=$(yq e "${task_prefix}.$field" "$milestone_file" 2>/dev/null)
            if [ "$value" = "null" ] || [ -z "$value" ]; then
                echo "❌ ERROR: Task $i missing required field: $field"
                ((errors++))
            fi
        done
        
        # Validate task status
        local task_status=$(yq e "${task_prefix}.status" "$milestone_file")
        local valid_task_statuses=("pending" "in_progress" "completed" "blocked" "cancelled")
        local task_status_valid=false
        
        for valid_status in "${valid_task_statuses[@]}"; do
            if [ "$task_status" = "$valid_status" ]; then
                task_status_valid=true
                break
            fi
        done
        
        if [ "$task_status_valid" = false ]; then
            echo "❌ ERROR: Task $i has invalid status: $task_status"
            ((errors++))
        fi
        
        # Validate task dependencies exist
        local task_deps=$(yq e "${task_prefix}.depends_on[]? // empty" "$milestone_file" 2>/dev/null)
        for dep in $task_deps; do
            if ! yq e ".tasks[] | select(.id == \"$dep\")" "$milestone_file" >/dev/null 2>&1; then
                echo "❌ ERROR: Task $i depends on non-existent task: $dep"
                ((errors++))
            fi
        done
    done
    
    return $errors
}
```

## Dependency Graph Validation

```bash
# Validate milestone dependency graph
validate_dependency_graph() {
    local milestone_id=$1
    local check_circular=${2:-true}
    local errors=0
    
    echo "=== Dependency Graph Validation ==="
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Check milestone-level dependencies
    local milestone_deps=$(yq e '.dependencies.requires[]? // empty' "$milestone_file" 2>/dev/null)
    
    for dep in $milestone_deps; do
        # Check if dependency milestone exists and is completed
        if [ ! -f ".milestones/completed/$dep.yaml" ] && [ ! -f ".milestones/active/$dep.yaml" ]; then
            echo "❌ ERROR: Dependency milestone not found: $dep"
            ((errors++))
        elif [ -f ".milestones/active/$dep.yaml" ]; then
            local dep_status=$(yq e '.status' ".milestones/active/$dep.yaml")
            if [ "$dep_status" != "completed" ]; then
                echo "⚠️  WARNING: Dependency milestone not completed: $dep (status: $dep_status)"
            fi
        fi
    done
    
    # Check for circular dependencies
    if [ "$check_circular" = true ]; then
        local circular_deps=$(detect_circular_dependencies "$milestone_id")
        if [ -n "$circular_deps" ]; then
            echo "❌ ERROR: Circular dependency detected: $circular_deps"
            ((errors++))
        fi
    fi
    
    # Validate task-level dependencies within milestone
    local task_errors=$(validate_task_dependencies "$milestone_id")
    ((errors+=task_errors))
    
    if [ $errors -eq 0 ]; then
        echo "✅ Dependency graph validation passed"
    else
        echo "❌ Dependency graph validation failed with $errors errors"
    fi
    
    return $errors
}

# Detect circular dependencies
detect_circular_dependencies() {
    local milestone_id=$1
    local visited_file="/tmp/milestone_visited_$$"
    local recursion_file="/tmp/milestone_recursion_$$"
    
    > "$visited_file"
    > "$recursion_file"
    
    # Recursive function to detect cycles
    check_cycle() {
        local current=$1
        
        # Mark as in recursion stack
        echo "$current" >> "$recursion_file"
        
        # Check dependencies
        local deps=""
        if [ -f ".milestones/active/$current.yaml" ]; then
            deps=$(yq e '.dependencies.requires[]? // empty' ".milestones/active/$current.yaml" 2>/dev/null)
        elif [ -f ".milestones/completed/$current.yaml" ]; then
            deps=$(yq e '.dependencies.requires[]? // empty' ".milestones/completed/$current.yaml" 2>/dev/null)
        fi
        
        for dep in $deps; do
            # If dependency is in recursion stack, we have a cycle
            if grep -q "^$dep$" "$recursion_file"; then
                echo "$current -> $dep"
                rm -f "$visited_file" "$recursion_file"
                return 0
            fi
            
            # If not visited, recursively check
            if ! grep -q "^$dep$" "$visited_file"; then
                echo "$dep" >> "$visited_file"
                local cycle_result=$(check_cycle "$dep")
                if [ -n "$cycle_result" ]; then
                    echo "$current -> $cycle_result"
                    rm -f "$visited_file" "$recursion_file"
                    return 0
                fi
            fi
        done
        
        # Remove from recursion stack
        grep -v "^$current$" "$recursion_file" > "${recursion_file}.tmp" && mv "${recursion_file}.tmp" "$recursion_file"
    }
    
    echo "$milestone_id" >> "$visited_file"
    local result=$(check_cycle "$milestone_id")
    
    rm -f "$visited_file" "$recursion_file"
    echo "$result"
}

# Validate task dependencies within milestone
validate_task_dependencies() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local errors=0
    
    # Create temporary files for task dependency analysis
    local task_ids_file="/tmp/task_ids_$$"
    local task_deps_file="/tmp/task_deps_$$"
    
    yq e '.tasks[].id' "$milestone_file" 2>/dev/null > "$task_ids_file"
    
    # Check each task's dependencies
    local task_count=$(yq e '.tasks | length' "$milestone_file" 2>/dev/null || echo "0")
    
    for ((i=0; i<task_count; i++)); do
        local task_id=$(yq e ".tasks[$i].id" "$milestone_file")
        local task_deps=$(yq e ".tasks[$i].depends_on[]? // empty" "$milestone_file" 2>/dev/null)
        
        for dep in $task_deps; do
            # Check if dependency task exists
            if ! grep -q "^$dep$" "$task_ids_file"; then
                echo "❌ ERROR: Task '$task_id' depends on non-existent task: $dep"
                ((errors++))
            fi
            
            # Check for self-dependency
            if [ "$task_id" = "$dep" ]; then
                echo "❌ ERROR: Task '$task_id' cannot depend on itself"
                ((errors++))
            fi
        done
    done
    
    rm -f "$task_ids_file" "$task_deps_file"
    return $errors
}
```

## Context Validation

```bash
# Validate milestone execution context
validate_milestone_context() {
    local milestone_id=$1
    local context_type=${2:-"execution"}
    local errors=0
    local warnings=0
    
    echo "=== Context Validation: $context_type ==="
    
    # Validate working directory
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local expected_dir=$(yq e '.context.working_directory // null' "$milestone_file" 2>/dev/null)
    
    if [ "$expected_dir" != "null" ] && [ "$expected_dir" != "$(pwd)" ]; then
        echo "⚠️  WARNING: Working directory mismatch"
        echo "    Expected: $expected_dir"
        echo "    Current:  $(pwd)"
        ((warnings++))
    fi
    
    # Validate git repository state
    if [ "$context_type" = "execution" ] || [ "$context_type" = "git" ]; then
        local git_errors=$(validate_git_context "$milestone_id")
        ((errors+=git_errors))
    fi
    
    # Validate environment requirements
    local env_errors=$(validate_environment_requirements "$milestone_id")
    ((errors+=env_errors))
    
    # Validate file system permissions
    local perm_errors=$(validate_filesystem_permissions "$milestone_id")
    ((errors+=perm_errors))
    
    # Summary
    if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
        echo "✅ Context validation passed"
    elif [ $errors -eq 0 ]; then
        echo "⚠️  Context validation completed with $warnings warnings"
    else
        echo "❌ Context validation failed with $errors errors and $warnings warnings"
    fi
    
    return $errors
}

# Validate git context
validate_git_context() {
    local milestone_id=$1
    local errors=0
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "❌ ERROR: Not in a git repository"
        ((errors++))
        return $errors
    fi
    
    # Check git status
    local git_status=$(git status --porcelain)
    if [ -n "$git_status" ]; then
        echo "⚠️  WARNING: Uncommitted changes detected"
        echo "$git_status" | head -5
        if [ $(echo "$git_status" | wc -l) -gt 5 ]; then
            echo "    ... and $(($(echo "$git_status" | wc -l) - 5)) more files"
        fi
    fi
    
    # Validate milestone branch
    local expected_branch="milestone/$milestone_id"
    local current_branch=$(git branch --show-current)
    
    if [ "$current_branch" != "$expected_branch" ]; then
        echo "⚠️  WARNING: Not on expected milestone branch"
        echo "    Expected: $expected_branch"
        echo "    Current:  $current_branch"
    fi
    
    # Check for remote tracking
    local tracking_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "none")
    if [ "$tracking_branch" = "none" ]; then
        echo "⚠️  WARNING: Current branch is not tracking a remote branch"
    fi
    
    return $errors
}

# Validate environment requirements
validate_environment_requirements() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local errors=0
    
    # Check required tools
    local required_tools=$(yq e '.requirements.tools[]? // empty' "$milestone_file" 2>/dev/null)
    for tool in $required_tools; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "❌ ERROR: Required tool not found: $tool"
            ((errors++))
        fi
    done
    
    # Check MCP server availability
    local mcp_errors=$(check_mcp_server_availability "$milestone_id")
    ((errors+=mcp_errors))
    
    # Check environment variables
    local required_env_vars=$(yq e '.requirements.environment[]? // empty' "$milestone_file" 2>/dev/null)
    for env_var in $required_env_vars; do
        if [ -z "${!env_var}" ]; then
            echo "❌ ERROR: Required environment variable not set: $env_var"
            ((errors++))
        fi
    done
    
    # Check disk space requirements
    local min_disk_space=$(yq e '.requirements.disk_space_mb // 100' "$milestone_file" 2>/dev/null)
    local available_space=$(df . | tail -1 | awk '{print int($4/1024)}')
    
    if [ "$available_space" -lt "$min_disk_space" ]; then
        echo "❌ ERROR: Insufficient disk space. Required: ${min_disk_space}MB, Available: ${available_space}MB"
        ((errors++))
    fi
    
    return $errors
}

# Check MCP server availability
check_mcp_server_availability() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local errors=0
    
    # Check if MCP servers are configured
    local mcp_servers=$(yq e '.requirements.mcp_servers[]? // empty' "$milestone_file" 2>/dev/null)
    
    if [ -z "$mcp_servers" ]; then
        echo "ℹ️  No MCP servers configured for milestone"
        return 0
    fi
    
    echo "=== MCP Server Availability Check ==="
    
    for server in $mcp_servers; do
        case "$server" in
            "github")
                if check_github_mcp_server; then
                    echo "✅ GitHub MCP server available"
                else
                    echo "❌ ERROR: GitHub MCP server not available"
                    ((errors++))
                fi
                ;;
            "git")
                if check_git_mcp_server; then
                    echo "✅ Git MCP server available"
                else
                    echo "❌ ERROR: Git MCP server not available"
                    ((errors++))
                fi
                ;;
            "docker")
                if check_docker_mcp_server; then
                    echo "✅ Docker MCP server available"
                else
                    echo "❌ ERROR: Docker MCP server not available"
                    ((errors++))
                fi
                ;;
            *)
                echo "⚠️  WARNING: Unknown MCP server type: $server"
                ;;
        esac
    done
    
    return $errors
}

# Check GitHub MCP server availability
check_github_mcp_server() {
    # Check if GitHub CLI is available
    if ! command -v gh >/dev/null 2>&1; then
        echo "    GitHub CLI (gh) not found"
        return 1
    fi
    
    # Check if authenticated
    if ! gh auth status >/dev/null 2>&1; then
        echo "    GitHub CLI not authenticated"
        return 1
    fi
    
    return 0
}

# Check Git MCP server availability
check_git_mcp_server() {
    # Check if git is available
    if ! command -v git >/dev/null 2>&1; then
        echo "    Git not found"
        return 1
    fi
    
    # Check if in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "    Not in a git repository"
        return 1
    fi
    
    return 0
}

# Check Docker MCP server availability
check_docker_mcp_server() {
    # Check if docker is available
    if ! command -v docker >/dev/null 2>&1; then
        echo "    Docker not found"
        return 1
    fi
    
    # Check if docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        echo "    Docker daemon not running"
        return 1
    fi
    
    return 0
}

# Validate filesystem permissions
validate_filesystem_permissions() {
    local milestone_id=$1
    local errors=0
    
    # Check write permissions for milestone directories
    local milestone_dirs=(".milestones" ".milestones/active" ".milestones/state" ".milestones/logs")
    
    for dir in "${milestone_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            if ! mkdir -p "$dir" 2>/dev/null; then
                echo "❌ ERROR: Cannot create directory: $dir"
                ((errors++))
            fi
        elif [ ! -w "$dir" ]; then
            echo "❌ ERROR: No write permission for directory: $dir"
            ((errors++))
        fi
    done
    
    # Check read/write permissions for milestone file
    local milestone_file=".milestones/active/$milestone_id.yaml"
    if [ -f "$milestone_file" ]; then
        if [ ! -r "$milestone_file" ]; then
            echo "❌ ERROR: No read permission for milestone file: $milestone_file"
            ((errors++))
        fi
        if [ ! -w "$milestone_file" ]; then
            echo "❌ ERROR: No write permission for milestone file: $milestone_file"
            ((errors++))
        fi
    fi
    
    return $errors
}
```

## Input Sanitization and Validation

```bash
# Sanitize milestone ID
sanitize_milestone_id() {
    local input=$1
    
    # Remove any path traversal attempts
    local sanitized=$(echo "$input" | sed 's/\.\.//g' | sed 's|/||g')
    
    # Ensure it only contains alphanumeric, hyphens, and underscores
    sanitized=$(echo "$sanitized" | sed 's/[^a-zA-Z0-9_-]//g')
    
    # Ensure it's not empty and starts with alphanumeric
    if [ -z "$sanitized" ] || ! [[ "$sanitized" =~ ^[a-zA-Z0-9] ]]; then
        echo "ERROR: Invalid milestone ID format"
        return 1
    fi
    
    # Limit length
    if [ ${#sanitized} -gt 50 ]; then
        sanitized="${sanitized:0:50}"
    fi
    
    echo "$sanitized"
}

# Validate and sanitize input parameters
validate_input_parameters() {
    local param_type=$1
    local param_value=$2
    local max_length=${3:-100}
    
    case "$param_type" in
        "milestone_id")
            sanitize_milestone_id "$param_value"
            ;;
        "title")
            # Remove potentially dangerous characters, limit length
            local sanitized=$(echo "$param_value" | sed 's/[<>&"'\''`]//g' | head -c "$max_length")
            if [ -z "$sanitized" ]; then
                echo "ERROR: Title cannot be empty"
                return 1
            fi
            echo "$sanitized"
            ;;
        "description")
            # Basic sanitization for description
            local sanitized=$(echo "$param_value" | sed 's/[<>&`]//g' | head -c 1000)
            echo "$sanitized"
            ;;
        "status")
            # Validate against allowed status values
            local valid_statuses=("planning" "in_progress" "blocked" "completed" "cancelled")
            for valid_status in "${valid_statuses[@]}"; do
                if [ "$param_value" = "$valid_status" ]; then
                    echo "$param_value"
                    return 0
                fi
            done
            echo "ERROR: Invalid status value"
            return 1
            ;;
        "percentage")
            # Validate percentage (0-100)
            if [[ "$param_value" =~ ^[0-9]+$ ]] && [ "$param_value" -ge 0 ] && [ "$param_value" -le 100 ]; then
                echo "$param_value"
            else
                echo "ERROR: Invalid percentage value"
                return 1
            fi
            ;;
        "date")
            # Validate ISO date format
            if date -d "$param_value" >/dev/null 2>&1 || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$param_value" >/dev/null 2>&1; then
                echo "$param_value"
            else
                echo "ERROR: Invalid date format"
                return 1
            fi
            ;;
        *)
            echo "ERROR: Unknown parameter type: $param_type"
            return 1
            ;;
    esac
}

# Comprehensive validation pipeline
run_comprehensive_validation() {
    local milestone_id=$1
    local validation_level=${2:-"standard"}
    local total_errors=0
    
    echo "=== Comprehensive Milestone Validation ==="
    echo "Milestone: $milestone_id"
    echo "Level: $validation_level"
    echo ""
    
    # Phase 1: Input validation
    echo "Phase 1: Input Validation"
    local sanitized_id=$(sanitize_milestone_id "$milestone_id")
    if [ $? -ne 0 ]; then
        echo "$sanitized_id"
        return 1
    fi
    
    # Phase 2: Milestone integrity
    echo "Phase 2: Milestone Integrity"
    local integrity_errors=$(validate_milestone_integrity "$milestone_id" "$validation_level")
    ((total_errors+=integrity_errors))
    
    # Phase 3: Dependency validation
    echo "Phase 3: Dependency Validation"
    local dependency_errors=$(validate_dependency_graph "$milestone_id")
    ((total_errors+=dependency_errors))
    
    # Phase 4: Context validation
    echo "Phase 4: Context Validation"
    local context_errors=$(validate_milestone_context "$milestone_id")
    ((total_errors+=context_errors))
    
    # Summary
    echo ""
    echo "=== Validation Summary ==="
    if [ $total_errors -eq 0 ]; then
        echo "✅ All validations passed successfully"
    else
        echo "❌ Validation failed with $total_errors total errors"
    fi
    
    return $total_errors
}
```

This validation framework provides comprehensive checks for milestone integrity, dependencies, context, and secure input handling to ensure reliable milestone execution.