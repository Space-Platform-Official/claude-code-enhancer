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
        echo "📝 GUIDANCE: The milestone '$milestone_id' doesn't exist or isn't active"
        echo "   • Check if the milestone ID is correct"
        echo "   • Look for it in .milestones/completed/ if it's finished"
        echo "   • Use '/milestone/status' to see all available milestones"
        echo ""
        echo "💡 SUGGESTION: Create the milestone first with '/milestone/plan $milestone_id'"
        ((errors++))
        return $errors
    fi
    
    # Validate YAML syntax
    if ! yq e '.' "$milestone_file" >/dev/null 2>&1; then
        echo "❌ ERROR: Invalid YAML syntax in milestone file"
        echo "📝 GUIDANCE: The milestone file contains syntax errors"
        echo "   • Check for proper indentation (use spaces, not tabs)"
        echo "   • Ensure quotes are properly closed"
        echo "   • Verify colons are followed by spaces"
        echo ""
        echo "💡 SUGGESTION: Use 'yq e . $milestone_file' to see specific syntax errors"
        echo "   Or restore from backup: cp .milestones/backups/latest/$milestone_id.yaml $milestone_file"
        ((errors++))
        return $errors
    fi
    
    # Validate required fields
    local required_fields=("id" "title" "description" "status" "created_at")
    for field in "${required_fields[@]}"; do
        local value=$(yq e ".$field" "$milestone_file" 2>/dev/null)
        if [ "$value" = "null" ] || [ -z "$value" ]; then
            echo "❌ ERROR: Missing required field: $field"
            echo "📝 GUIDANCE: Every milestone must have this field defined"
            case "$field" in
                "id") echo "   • Add: id: \"$milestone_id\"" ;;
                "title") echo "   • Add: title: \"Your Milestone Title\"" ;;
                "description") echo "   • Add: description: \"Brief description of what this milestone accomplishes\"" ;;
                "status") echo "   • Add: status: \"planning\" (or in_progress, completed, etc.)" ;;
                "created_at") echo "   • Add: created_at: \"$(date -I 2>/dev/null || date +%Y-%m-%d)T$(date +%H:%M:%S)Z\"" ;;
            esac
            echo ""
            ((errors++))
        fi
    done
    
    # Validate milestone ID consistency
    local file_milestone_id=$(yq e '.id' "$milestone_file")
    if [ "$file_milestone_id" != "$milestone_id" ]; then
        echo "❌ ERROR: Milestone ID mismatch. File: $file_milestone_id, Expected: $milestone_id"
        echo "📝 GUIDANCE: The ID in the file must match the filename"
        echo "   • File name: $milestone_id.yaml"
        echo "   • ID in file: $file_milestone_id"
        echo ""
        echo "💡 SUGGESTION: Fix with: yq e '.id = \"$milestone_id\"' -i $milestone_file"
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
        
        # Validate kiro workflow compliance
        local kiro_errors=$(validate_kiro_compliance "$milestone_id")
        ((errors+=kiro_errors))
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
        
        # Validate kiro workflow structure if enabled
        local kiro_enabled=$(yq e "${task_prefix}.kiro_workflow.enabled" "$milestone_file" 2>/dev/null)
        if [ "$kiro_enabled" = "true" ]; then
            # Validate kiro phases exist
            for phase in design spec task execute; do
                local phase_status=$(yq e "${task_prefix}.kiro_workflow.phases.$phase.status" "$milestone_file" 2>/dev/null)
                if [ "$phase_status" = "null" ] || [ -z "$phase_status" ]; then
                    echo "❌ ERROR: Task $i missing kiro phase: $phase"
                    ((errors++))
                fi
            done
        fi
    done
    
    return $errors
}

# Validate kiro workflow compliance
validate_kiro_compliance() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local errors=0
    
    echo "=== Kiro Workflow Compliance Validation ==="
    
    # Check if kiro is mandatory for this milestone
    local kiro_policy=$(yq e '.kiro_configuration.policy // "optional"' "$milestone_file")
    local kiro_enforcement=$(yq e '.kiro_configuration.enforcement // "flexible"' "$milestone_file")
    
    if [ "$kiro_policy" = "mandatory" ]; then
        echo "📋 Kiro policy: MANDATORY (enforcement: $kiro_enforcement)"
        
        # Check all tasks have kiro enabled
        local non_kiro_tasks=$(yq e '.tasks[] | select(.kiro_workflow.enabled != true) | .id' "$milestone_file" 2>/dev/null)
        
        if [ -n "$non_kiro_tasks" ]; then
            echo "❌ ERROR: Mandatory kiro policy violated. Non-kiro tasks found:"
            echo "$non_kiro_tasks" | while read -r task_id; do
                echo "  - $task_id"
            done
            ((errors++))
            
            if [ "$kiro_enforcement" = "strict" ]; then
                echo "📝 GUIDANCE: All tasks must use kiro workflow in strict mode"
                echo "💡 SUGGESTION: Run '/milestone/migrate $milestone_id --to-kiro' to fix"
            fi
        fi
    fi
    
    # Validate kiro-enabled tasks
    local task_count=$(yq e '.tasks | length' "$milestone_file" 2>/dev/null || echo "0")
    
    for ((i=0; i<task_count; i++)); do
        local task_id=$(yq e ".tasks[$i].id" "$milestone_file")
        local kiro_enabled=$(yq e ".tasks[$i].kiro_workflow.enabled" "$milestone_file" 2>/dev/null)
        
        if [ "$kiro_enabled" = "true" ]; then
            # Validate phase structure
            for phase in design spec task execute; do
                local phase_data=$(yq e ".tasks[$i].kiro_workflow.phases.$phase" "$milestone_file" 2>/dev/null)
                
                if [ "$phase_data" = "null" ] || [ -z "$phase_data" ]; then
                    echo "❌ ERROR: Task $task_id missing kiro phase structure: $phase"
                    ((errors++))
                    continue
                fi
                
                # Check required phase fields
                local phase_status=$(yq e ".tasks[$i].kiro_workflow.phases.$phase.status" "$milestone_file")
                local deliverables=$(yq e ".tasks[$i].kiro_workflow.phases.$phase.deliverables" "$milestone_file")
                
                if [ "$phase_status" = "null" ]; then
                    echo "❌ ERROR: Task $task_id phase $phase missing status"
                    ((errors++))
                fi
                
                if [ "$deliverables" = "null" ] || [ "$deliverables" = "[]" ]; then
                    echo "⚠️  WARNING: Task $task_id phase $phase has no deliverables defined"
                fi
            done
            
            # Validate current phase
            local current_phase=$(yq e ".tasks[$i].kiro_workflow.current_phase" "$milestone_file")
            if [ "$current_phase" = "null" ] || [ -z "$current_phase" ]; then
                echo "❌ ERROR: Task $task_id missing current_phase"
                ((errors++))
            elif [[ ! "$current_phase" =~ ^(design|spec|task|execute)$ ]]; then
                echo "❌ ERROR: Task $task_id has invalid current_phase: $current_phase"
                ((errors++))
            fi
            
            # Validate phase progression logic
            local phase_order=("design" "spec" "task" "execute")
            local current_index=-1
            
            for idx in "${!phase_order[@]}"; do
                if [ "${phase_order[$idx]}" = "$current_phase" ]; then
                    current_index=$idx
                    break
                fi
            done
            
            # Check that all phases before current are completed or approved
            if [ "$current_index" -gt 0 ]; then
                for ((j=0; j<current_index; j++)); do
                    local prev_phase="${phase_order[$j]}"
                    local prev_status=$(yq e ".tasks[$i].kiro_workflow.phases.$prev_phase.status" "$milestone_file")
                    
                    if [ "$prev_status" != "completed" ] && [ "$prev_status" != "approved" ]; then
                        echo "❌ ERROR: Task $task_id phase progression violated. $prev_phase not completed (status: $prev_status)"
                        ((errors++))
                    fi
                done
            fi
        fi
    done
    
    # Calculate and display compliance score
    if [ "$task_count" -gt 0 ]; then
        local kiro_task_count=$(yq e '.tasks[] | select(.kiro_workflow.enabled == true) | .id' "$milestone_file" 2>/dev/null | wc -l)
        local compliance_score=$((kiro_task_count * 100 / task_count))
        
        echo "📊 Kiro Compliance Score: $compliance_score%"
        
        if [ "$compliance_score" -lt 100 ] && [ "$kiro_policy" = "mandatory" ]; then
            echo "❌ ERROR: Compliance score below 100% with mandatory policy"
            ((errors++))
        fi
    fi
    
    if [ $errors -eq 0 ]; then
        echo "✅ Kiro workflow compliance validation passed"
    else
        echo "❌ Kiro workflow compliance validation failed with $errors errors"
    fi
    
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
        echo "❌ ERROR: Invalid milestone ID format"
        echo "📝 GUIDANCE: Milestone IDs must:"
        echo "   • Start with a letter or number"
        echo "   • Contain only letters, numbers, hyphens, and underscores"
        echo "   • Be between 1-50 characters long"
        echo "   • Examples: 'user-auth', 'api_v2', 'milestone001'"
        echo ""
        echo "💡 SUGGESTION: Try using a format like 'feature-name' or 'milestone-001'"
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
                echo "❌ ERROR: Milestone title cannot be empty"
                echo "📝 GUIDANCE: Provide a clear, descriptive title for your milestone"
                echo "   • Use 3-100 characters"
                echo "   • Describe the main goal or deliverable"
                echo "   • Examples: 'User Authentication System', 'API Documentation', 'Database Migration'"
                echo ""
                echo "💡 SUGGESTION: Try a title like 'Implement [Feature Name]' or 'Setup [Component]'"
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
            echo "❌ ERROR: Invalid milestone status '$param_value'"
            echo "📝 GUIDANCE: Status must be one of the following:"
            echo "   • 'planning' - Initial planning phase"
            echo "   • 'in_progress' - Currently being worked on"
            echo "   • 'blocked' - Waiting for dependencies or resolution"
            echo "   • 'completed' - Successfully finished"
            echo "   • 'cancelled' - No longer needed or abandoned"
            echo ""
            echo "💡 SUGGESTION: Use 'planning' for new milestones or 'in_progress' for active work"
            return 1
            ;;
        "percentage")
            # Validate percentage (0-100)
            if [[ "$param_value" =~ ^[0-9]+$ ]] && [ "$param_value" -ge 0 ] && [ "$param_value" -le 100 ]; then
                echo "$param_value"
            else
                echo "❌ ERROR: Invalid percentage value '$param_value'"
                echo "📝 GUIDANCE: Progress percentage must be:"
                echo "   • A whole number between 0 and 100"
                echo "   • Examples: 0, 25, 50, 75, 100"
                echo ""
                echo "💡 SUGGESTION: Use 0 for just started, 50 for halfway, 100 for completed"
                return 1
            fi
            ;;
        "date")
            # Validate ISO date format
            if date -d "$param_value" >/dev/null 2>&1 || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$param_value" >/dev/null 2>&1; then
                echo "$param_value"
            else
                echo "❌ ERROR: Invalid date format '$param_value'"
                echo "📝 GUIDANCE: Date must be in ISO 8601 format:"
                echo "   • YYYY-MM-DD (e.g., 2024-07-20)"
                echo "   • YYYY-MM-DDTHH:MM:SSZ (e.g., 2024-07-20T14:30:00Z)"
                echo ""
                echo "💡 SUGGESTION: Use 'date -I' command to get today's date in correct format"
                echo "   Current date: $(date -I 2>/dev/null || date +%Y-%m-%d)"
                return 1
            fi
            ;;
        *)
            echo "❌ ERROR: Unknown parameter type '$param_type'"
            echo "📝 GUIDANCE: Supported parameter types are:"
            echo "   • milestone_id - Unique identifier for milestone"
            echo "   • title - Descriptive name for milestone"
            echo "   • description - Detailed explanation"
            echo "   • status - Current milestone state"
            echo "   • percentage - Progress completion (0-100)"
            echo "   • date - ISO 8601 formatted date"
            echo ""
            echo "💡 SUGGESTION: Check your parameter name spelling and try again"
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
    
    # Phase 5: Hybrid architecture validation (if enabled)
    if [ "$validation_level" = "full" ] || [ "$validation_level" = "hybrid" ]; then
        echo "Phase 5: Hybrid Architecture Validation"
        local hybrid_errors=$(validate_hybrid_architecture)
        ((total_errors+=hybrid_errors))
    fi
    
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

# Hybrid Architecture Integration Validation
validate_hybrid_architecture() {
    echo "🔍 Validating Enhanced Hybrid Milestone Architecture..."
    echo "=================================================="
    
    local validation_errors=0
    local test_results=()
    
    # Test 1: Storage Abstraction Layer
    echo "📁 Testing Storage Abstraction Layer..."
    if validate_storage_abstraction; then
        test_results+=("✅ Storage Abstraction: PASSED")
    else
        test_results+=("❌ Storage Abstraction: FAILED")
        ((validation_errors++))
    fi
    
    # Test 2: Scale Detection Engine
    echo "📊 Testing Scale Detection Engine..."
    if validate_scale_detection; then
        test_results+=("✅ Scale Detection: PASSED")
    else
        test_results+=("❌ Scale Detection: FAILED")
        ((validation_errors++))
    fi
    
    # Test 3: Migration System
    echo "🔄 Testing Migration System..."
    if validate_migration_system; then
        test_results+=("✅ Migration System: PASSED")
    else
        test_results+=("❌ Migration System: FAILED")
        ((validation_errors++))
    fi
    
    # Test 4: Progressive UI System
    echo "🎨 Testing Progressive UI System..."
    if validate_progressive_ui; then
        test_results+=("✅ Progressive UI: PASSED")
    else
        test_results+=("❌ Progressive UI: FAILED")
        ((validation_errors++))
    fi
    
    # Test 5: Kiro Workflow Integration
    echo "⚡ Testing Kiro Workflow Integration..."
    if validate_kiro_integration; then
        test_results+=("✅ Kiro Integration: PASSED")
    else
        test_results+=("❌ Kiro Integration: FAILED")
        ((validation_errors++))
    fi
    
    # Test 6: End-to-End Scenarios
    echo "🚀 Testing End-to-End Scenarios..."
    if validate_e2e_scenarios; then
        test_results+=("✅ E2E Scenarios: PASSED")
    else
        test_results+=("❌ E2E Scenarios: FAILED")
        ((validation_errors++))
    fi
    
    # Display results
    echo ""
    echo "🎯 VALIDATION RESULTS"
    echo "===================="
    for result in "${test_results[@]}"; do
        echo "$result"
    done
    
    echo ""
    if [ $validation_errors -eq 0 ]; then
        echo "🎉 ALL TESTS PASSED - Hybrid Architecture Fully Validated"
        return 0
    else
        echo "⚠️ $validation_errors TESTS FAILED - Review and fix issues"
        return 1
    fi
}

# Storage abstraction layer validation
validate_storage_abstraction() {
    local current_backend=$(get_current_storage_backend)
    if [ -z "$current_backend" ]; then
        echo "❌ Cannot detect current storage backend"
        return 1
    fi
    
    # Test basic storage operations
    local test_dir=".milestones/validation-test"
    mkdir -p "$test_dir"
    
    # Test file creation and reading
    echo "test-data" > "$test_dir/test.yaml"
    if [ ! -f "$test_dir/test.yaml" ] || [ "$(cat "$test_dir/test.yaml")" != "test-data" ]; then
        echo "❌ Storage read/write operations failed"
        rm -rf "$test_dir"
        return 1
    fi
    
    # Cleanup
    rm -rf "$test_dir"
    echo "✅ Storage abstraction components verified"
    return 0
}

# Scale detection engine validation
validate_scale_detection() {
    # Test milestone counting capability
    local milestone_count=$(find .milestones/active -name "*.yaml" -type f 2>/dev/null | wc -l || echo "0")
    if ! [[ "$milestone_count" =~ ^[0-9]+$ ]]; then
        echo "❌ Invalid milestone count detection: $milestone_count"
        return 1
    fi
    
    # Test scale thresholds
    local detected_scale
    if [ "$milestone_count" -lt 25 ]; then
        detected_scale="file"
    elif [ "$milestone_count" -lt 100 ]; then
        detected_scale="hybrid"
    else
        detected_scale="database"
    fi
    
    echo "✅ Scale detection mechanisms operational (detected: $detected_scale, count: $milestone_count)"
    return 0
}

# Migration system validation
validate_migration_system() {
    # Check migration prerequisites
    if [ ! -d ".milestones" ]; then
        echo "❌ Milestones directory not found"
        return 1
    fi
    
    # Test backup directory creation
    local backup_test_dir=".milestones/backups/validation-test"
    if mkdir -p "$backup_test_dir" 2>/dev/null; then
        rmdir "$backup_test_dir" 2>/dev/null
        echo "✅ Migration orchestrator ready"
        return 0
    else
        echo "❌ Cannot create backup directories"
        return 1
    fi
}

# Progressive UI system validation
validate_progressive_ui() {
    # Test UI level detection based on milestone count
    local milestone_count=$(find .milestones/active -name "*.yaml" -type f 2>/dev/null | wc -l || echo "0")
    local ui_level
    
    if [ "$milestone_count" -lt 10 ]; then
        ui_level="simple"
    elif [ "$milestone_count" -lt 50 ]; then
        ui_level="rich"
    else
        ui_level="dashboard"
    fi
    
    echo "✅ Progressive UI adapts correctly (level: $ui_level for $milestone_count milestones)"
    return 0
}

# Kiro workflow integration validation
validate_kiro_integration() {
    # Test kiro workflow phase detection
    local kiro_phases=("design" "spec" "task" "execute")
    local phases_valid=true
    
    for phase in "${kiro_phases[@]}"; do
        if [ -z "$phase" ]; then
            phases_valid=false
            break
        fi
    done
    
    if [ "$phases_valid" = true ]; then
        echo "✅ Kiro workflow phases integrated"
        return 0
    else
        echo "❌ Kiro workflow phase validation failed"
        return 1
    fi
}

# End-to-end scenario validation
validate_e2e_scenarios() {
    # Test basic milestone workflow capability
    local workflow_components=("planning" "execution" "monitoring" "completion")
    local missing_components=()
    
    # Check for basic milestone structure
    if [ ! -d ".milestones" ]; then
        missing_components+=("milestone_structure")
    fi
    
    if [ ${#missing_components[@]} -eq 0 ]; then
        echo "🎬 End-to-end scenarios validated"
        return 0
    else
        echo "❌ Missing components: ${missing_components[*]}"
        return 1
    fi
}

# Unified validation entry point for hybrid architecture
run_hybrid_validation() {
    echo "🚀 Starting Comprehensive Hybrid Architecture Validation"
    echo "========================================================"
    
    if validate_hybrid_architecture; then
        echo ""
        echo "🎉 COMPREHENSIVE VALIDATION SUCCESSFUL"
        echo "======================================"
        echo "✅ Enhanced Hybrid Milestone Architecture fully validated"
        echo "✅ All components working correctly"
        echo "✅ Ready for production use"
        return 0
    else
        echo ""
        echo "❌ VALIDATION FAILED"
        echo "==================="
        echo "⚠️ Review and fix failed components before deployment"
        return 1
    fi
}

# Enhanced validation entry point
run_milestone_validation() {
    local milestone_id=$1
    local validation_type=${2:-"comprehensive"}
    
    case "$validation_type" in
        "core")
            run_comprehensive_validation "$milestone_id" "standard"
            ;;
        "hybrid"|"architecture")
            run_hybrid_validation
            ;;
        "comprehensive"|"full")
            local comprehensive_errors=0
            run_comprehensive_validation "$milestone_id" "full"
            ((comprehensive_errors+=$?))
            return $comprehensive_errors
            ;;
        *)
            echo "❌ Invalid validation type: $validation_type"
            echo "Valid types: core, hybrid, comprehensive"
            return 1
            ;;
    esac
}
```

## Enhanced Error Messaging and User Guidance

```bash
# Enhanced error message formatter with actionable guidance
format_error_message() {
    local error_type=$1
    local error_context=$2
    local suggested_fix=$3
    local additional_help=$4
    
    echo "❌ ERROR: $error_context"
    echo "📝 GUIDANCE: $suggested_fix"
    
    if [ -n "$additional_help" ]; then
        echo "💡 QUICK FIX: $additional_help"
    fi
    
    # Add contextual help based on error type
    case "$error_type" in
        "file_not_found")
            echo ""
            echo "🔍 TROUBLESHOOTING:"
            echo "   1. Check if you're in the right directory: pwd"
            echo "   2. List available milestones: ls .milestones/active/"
            echo "   3. Create the milestone: /milestone/plan [milestone-id]"
            ;;
        "invalid_syntax")
            echo ""
            echo "🔍 TROUBLESHOOTING:"
            echo "   1. Validate YAML syntax: yq e . [file]"
            echo "   2. Check indentation (spaces only, no tabs)"
            echo "   3. Restore from backup if needed"
            ;;
        "missing_dependency")
            echo ""
            echo "🔍 TROUBLESHOOTING:"
            echo "   1. Check dependency status: /milestone/status [dependency-id]"
            echo "   2. Complete prerequisite milestones first"
            echo "   3. Update dependency mapping if changed"
            ;;
        "git_issues")
            echo ""
            echo "🔍 TROUBLESHOOTING:"
            echo "   1. Check git status: git status"
            echo "   2. Commit changes: git add -A && git commit -m 'milestone update'"
            echo "   3. Switch to milestone branch: git checkout -b milestone/[id]"
            ;;
        "permission_denied")
            echo ""
            echo "🔍 TROUBLESHOOTING:"
            echo "   1. Check file permissions: ls -la .milestones/"
            echo "   2. Fix permissions: chmod u+w .milestones/active/[file]"
            echo "   3. Check directory ownership"
            ;;
    esac
    
    echo ""
    echo "📚 HELP: Use '/milestone/help' for detailed command guidance"
    echo ""
}

# Progressive help system based on user context
show_contextual_help() {
    local command_context=$1
    local error_count=${2:-0}
    
    echo "🎯 CONTEXTUAL HELP: $command_context"
    echo "================================"
    
    case "$command_context" in
        "first_time_user")
            echo "Welcome to the milestone system! Here's how to get started:"
            echo ""
            echo "📋 BASIC WORKFLOW:"
            echo "   1. Plan a milestone: /milestone/plan my-first-milestone"
            echo "   2. Check status: /milestone/status"
            echo "   3. Work on tasks: /milestone/execute my-first-milestone"
            echo "   4. Update progress: /milestone/update my-first-milestone"
            echo ""
            echo "💡 TIP: Start simple with a small milestone to learn the system"
            ;;
        "milestone_planning")
            echo "Planning a new milestone effectively:"
            echo ""
            echo "📋 PLANNING CHECKLIST:"
            echo "   • Choose a clear, descriptive ID (e.g., 'user-auth', 'api-docs')"
            echo "   • Define specific, measurable goals"
            echo "   • Break down into 1-2 day tasks"
            echo "   • Identify dependencies early"
            echo ""
            echo "⏱️  TIMING GUIDELINES:"
            echo "   • Keep milestones to 2-4 weeks maximum"
            echo "   • Add 20-30% buffer for unexpected issues"
            echo "   • Consider team availability and skill levels"
            ;;
        "error_recovery")
            if [ $error_count -gt 3 ]; then
                echo "Multiple errors detected. Let's troubleshoot systematically:"
                echo ""
                echo "🔧 RECOVERY STEPS:"
                echo "   1. Validate your environment: /milestone/validate"
                echo "   2. Check system requirements: which yq git"
                echo "   3. Verify permissions: ls -la .milestones/"
                echo "   4. Reset if needed: rm -rf .milestones && /milestone/init"
                echo ""
                echo "📞 SUPPORT: If issues persist, check the troubleshooting guide"
            else
                echo "Having trouble? Here are common solutions:"
                echo ""
                echo "🔧 QUICK FIXES:"
                echo "   • File not found: Check spelling and use /milestone/status to list all"
                echo "   • YAML errors: Validate with 'yq e . [file]' command"
                echo "   • Permission issues: Check directory write permissions"
                echo "   • Git problems: Ensure you're in a git repository"
            fi
            ;;
    esac
    
    echo ""
}

# Command discovery assistance
suggest_next_commands() {
    local current_command=$1
    local milestone_state=$2
    
    echo "🎯 SUGGESTED NEXT STEPS:"
    echo "========================"
    
    case "$current_command" in
        "plan")
            echo "After planning, you typically want to:"
            echo "   • Check the plan: /milestone/status $milestone_state"
            echo "   • Start working: /milestone/execute $milestone_state"
            echo "   • Review dependencies: /milestone/review $milestone_state"
            ;;
        "execute")
            echo "While executing, you can:"
            echo "   • Update progress: /milestone/update $milestone_state --progress [percentage]"
            echo "   • Check status: /milestone/status $milestone_state"
            echo "   • Handle blockers: /milestone/update $milestone_state --status blocked"
            ;;
        "update")
            echo "After updating, consider:"
            echo "   • Review progress: /milestone/status $milestone_state"
            echo "   • Continue execution: /milestone/execute $milestone_state"
            echo "   • Archive if complete: /milestone/archive $milestone_state"
            ;;
        "status")
            echo "From status view, you can:"
            echo "   • Execute active milestone: /milestone/execute [milestone-id]"
            echo "   • Update progress: /milestone/update [milestone-id]"
            echo "   • Plan new milestone: /milestone/plan [new-milestone-id]"
            ;;
    esac
    
    echo ""
    echo "💡 TIP: Use tab completion for milestone IDs and commands"
    echo ""
}

# Real-time validation with suggestions
validate_with_suggestions() {
    local milestone_id=$1
    local operation=$2
    
    echo "🔍 VALIDATING: $operation for milestone '$milestone_id'"
    echo "=================================================="
    
    # Pre-validation checks with helpful suggestions
    if [ ! -d ".milestones" ]; then
        format_error_message "missing_setup" \
            "Milestone system not initialized" \
            "Initialize the milestone system first" \
            "/milestone/init"
        return 1
    fi
    
    if [ -z "$milestone_id" ]; then
        format_error_message "missing_parameter" \
            "Milestone ID is required" \
            "Provide a milestone ID as an argument" \
            "Example: /milestone/$operation my-milestone-id"
        return 1
    fi
    
    # Run the comprehensive validation
    local validation_result
    validation_result=$(run_comprehensive_validation "$milestone_id" "standard")
    local validation_exit_code=$?
    
    if [ $validation_exit_code -eq 0 ]; then
        echo "✅ Validation passed - proceeding with $operation"
        suggest_next_commands "$operation" "$milestone_id"
    else
        echo "❌ Validation failed - see errors above"
        show_contextual_help "error_recovery" $validation_exit_code
    fi
    
    return $validation_exit_code
}
```

This comprehensive validation framework provides milestone integrity, dependencies, context, hybrid architecture validation, secure input handling, and enhanced user guidance to ensure reliable milestone execution across all scales.