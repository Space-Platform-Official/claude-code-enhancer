---
description: Kiro-Native Workflow System - Core implementation for mandatory kiro standard integration
---

# Kiro-Native Workflow System

Comprehensive kiro workflow implementation making the 4-phase methodology (Design → Spec → Task → Execute) the native and mandatory workflow for all milestone tasks.

## Core Kiro Configuration

```bash
# Global kiro enforcement policy
KIRO_POLICY_MODE="${KIRO_POLICY_MODE:-mandatory}"  # mandatory | optional | advisory
KIRO_ENFORCEMENT_LEVEL="${KIRO_ENFORCEMENT_LEVEL:-strict}"  # strict | flexible | progressive
KIRO_VISUALIZATION_MODE="${KIRO_VISUALIZATION_MODE:-rich}"  # simple | rich | dashboard

# Phase weight defaults (percentage of total effort)
KIRO_DESIGN_WEIGHT=${KIRO_DESIGN_WEIGHT:-15}
KIRO_SPEC_WEIGHT=${KIRO_SPEC_WEIGHT:-25}
KIRO_TASK_WEIGHT=${KIRO_TASK_WEIGHT:-20}
KIRO_EXECUTE_WEIGHT=${KIRO_EXECUTE_WEIGHT:-40}

# Approval gate defaults
KIRO_DESIGN_APPROVAL=${KIRO_DESIGN_APPROVAL:-true}
KIRO_SPEC_APPROVAL=${KIRO_SPEC_APPROVAL:-true}
KIRO_TASK_APPROVAL=${KIRO_TASK_APPROVAL:-false}
KIRO_EXECUTE_APPROVAL=${KIRO_EXECUTE_APPROVAL:-false}
```

## Kiro-Native Task Creation

```bash
# Create task with mandatory kiro workflow
create_kiro_native_task() {
    local milestone_id=$1
    local task_title=$2
    local task_type=${3:-"feature"}
    local estimated_hours=${4:-8}
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    if [ ! -f "$milestone_file" ]; then
        echo "❌ ERROR: Milestone $milestone_id not found"
        return 1
    fi
    
    # Generate task ID
    local task_id="task-$(date +%s)-$(echo "$task_title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | head -c 20)"
    
    # Calculate phase hours based on weights
    local design_hours=$(echo "$estimated_hours * $KIRO_DESIGN_WEIGHT / 100" | bc -l | xargs printf "%.1f")
    local spec_hours=$(echo "$estimated_hours * $KIRO_SPEC_WEIGHT / 100" | bc -l | xargs printf "%.1f")
    local task_hours=$(echo "$estimated_hours * $KIRO_TASK_WEIGHT / 100" | bc -l | xargs printf "%.1f")
    local execute_hours=$(echo "$estimated_hours * $KIRO_EXECUTE_WEIGHT / 100" | bc -l | xargs printf "%.1f")
    
    # Create deliverables based on task type
    local design_deliverables=$(generate_design_deliverables "$task_type")
    local spec_deliverables=$(generate_spec_deliverables "$task_type")
    local task_deliverables=$(generate_task_deliverables "$task_type")
    local execute_deliverables=$(generate_execute_deliverables "$task_type")
    
    # Create kiro-native task structure
    cat <<EOF | yq e '.tasks += [.]' -i "$milestone_file"
id: "$task_id"
title: "$task_title"
type: "kiro_workflow"
estimated_hours: $estimated_hours
status: "pending"
created_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
assigned_to: "${USER:-claude}"
dependencies: []

# Kiro workflow is MANDATORY
kiro_workflow:
  enabled: true
  policy: "mandatory"
  current_phase: "design"
  phase_hours:
    design: $design_hours
    spec: $spec_hours
    task: $task_hours
    execute: $execute_hours
  
  phases:
    design:
      status: "pending"
      description: "Architecture design and system planning"
      estimated_hours: $design_hours
      actual_hours: 0
      started_at: null
      completed_at: null
      approved_at: null
      approval_required: $KIRO_DESIGN_APPROVAL
      deliverables: $design_deliverables
      acceptance_criteria:
        - "Architecture documented and reviewed"
        - "API contracts defined"
        - "System boundaries established"
      
    spec:
      status: "pending"
      description: "Detailed technical specification"
      estimated_hours: $spec_hours
      actual_hours: 0
      started_at: null
      completed_at: null
      approved_at: null
      approval_required: $KIRO_SPEC_APPROVAL
      deliverables: $spec_deliverables
      acceptance_criteria:
        - "Technical specifications complete"
        - "Test plans documented"
        - "Acceptance criteria defined"
      
    task:
      status: "pending"
      description: "Task breakdown and planning"
      estimated_hours: $task_hours
      actual_hours: 0
      started_at: null
      completed_at: null
      approved_at: null
      approval_required: $KIRO_TASK_APPROVAL
      deliverables: $task_deliverables
      acceptance_criteria:
        - "Implementation tasks defined"
        - "Story points estimated"
        - "Dependencies mapped"
      
    execute:
      status: "pending"
      description: "Implementation and testing"
      estimated_hours: $execute_hours
      actual_hours: 0
      started_at: null
      completed_at: null
      approved_at: null
      approval_required: $KIRO_EXECUTE_APPROVAL
      deliverables: $execute_deliverables
      acceptance_criteria:
        - "Code implemented and tested"
        - "Documentation updated"
        - "Deployment ready"

quality_metrics:
  phase_completion: 0
  deliverable_completion: 0
  approval_status: "pending"
  compliance_score: 100
EOF
    
    echo "✅ Created kiro-native task: $task_id"
    echo "📊 Phase allocation: Design($design_hours h) → Spec($spec_hours h) → Task($task_hours h) → Execute($execute_hours h)"
    
    # Create deliverable directories
    create_deliverable_directories "$milestone_id" "$task_id"
    
    # Initialize phase tracking
    initialize_phase_tracking "$milestone_id" "$task_id"
    
    return 0
}

# Generate deliverables based on task type
generate_design_deliverables() {
    local task_type=$1
    
    case "$task_type" in
        "feature")
            echo '["architecture_diagram.md", "api_specification.yaml", "data_model.md", "security_design.md"]'
            ;;
        "bugfix")
            echo '["root_cause_analysis.md", "fix_approach.md", "regression_prevention.md"]'
            ;;
        "api")
            echo '["api_design.yaml", "endpoint_specification.md", "authentication_flow.md", "rate_limiting.md"]'
            ;;
        "frontend")
            echo '["ui_mockups.md", "component_hierarchy.md", "state_management.md", "accessibility_plan.md"]'
            ;;
        *)
            echo '["design_document.md", "technical_approach.md", "integration_plan.md"]'
            ;;
    esac
}

generate_spec_deliverables() {
    local task_type=$1
    
    case "$task_type" in
        "feature")
            echo '["technical_specification.md", "test_plan.md", "acceptance_criteria.md", "rollout_plan.md"]'
            ;;
        "bugfix")
            echo '["fix_specification.md", "test_scenarios.md", "validation_plan.md"]'
            ;;
        "api")
            echo '["openapi_spec.yaml", "integration_tests.md", "performance_criteria.md", "monitoring_plan.md"]'
            ;;
        "frontend")
            echo '["component_specs.md", "interaction_flows.md", "responsive_design.md", "browser_support.md"]'
            ;;
        *)
            echo '["technical_spec.md", "test_strategy.md", "success_metrics.md"]'
            ;;
    esac
}

generate_task_deliverables() {
    local task_type=$1
    echo '["implementation_tasks.md", "story_breakdown.md", "dependency_map.md", "risk_assessment.md"]'
}

generate_execute_deliverables() {
    local task_type=$1
    
    case "$task_type" in
        "feature")
            echo '["implementation_code", "unit_tests", "integration_tests", "documentation", "deployment_config"]'
            ;;
        "bugfix")
            echo '["fix_implementation", "regression_tests", "validation_results", "monitoring_updates"]'
            ;;
        "api")
            echo '["api_implementation", "api_tests", "api_documentation", "postman_collection", "performance_results"]'
            ;;
        "frontend")
            echo '["component_implementation", "ui_tests", "accessibility_tests", "storybook_stories", "performance_metrics"]'
            ;;
        *)
            echo '["implementation", "tests", "documentation", "deployment_ready"]'
            ;;
    esac
}
```

## Kiro Phase Management

```bash
# Start kiro phase with validation
start_kiro_phase() {
    local milestone_id=$1
    local task_id=$2
    local phase_name=$3
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Validate phase can be started
    if ! validate_phase_prerequisites "$milestone_id" "$task_id" "$phase_name"; then
        echo "❌ Cannot start phase $phase_name - prerequisites not met"
        return 1
    fi
    
    # Update phase status
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.status) = \"in_progress\"" -i "$milestone_file"
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.started_at) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" -i "$milestone_file"
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.current_phase) = \"$phase_name\"" -i "$milestone_file"
    
    # Create phase workspace
    create_phase_workspace "$milestone_id" "$task_id" "$phase_name"
    
    # Generate phase templates
    generate_phase_templates "$milestone_id" "$task_id" "$phase_name"
    
    echo "✅ Started $phase_name phase for task $task_id"
    echo "📝 Templates created in .milestones/deliverables/$task_id/$phase_name/"
    
    # Show phase guidance
    show_phase_guidance "$phase_name"
    
    return 0
}

# Validate phase prerequisites
validate_phase_prerequisites() {
    local milestone_id=$1
    local task_id=$2
    local phase_name=$3
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Check if previous phase is complete
    case "$phase_name" in
        "design")
            # Design can always start
            return 0
            ;;
        "spec")
            local design_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.design.status" "$milestone_file")
            if [ "$design_status" != "completed" ] && [ "$design_status" != "approved" ]; then
                echo "⚠️  Design phase must be completed first (current: $design_status)"
                return 1
            fi
            ;;
        "task")
            local spec_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.spec.status" "$milestone_file")
            if [ "$spec_status" != "completed" ] && [ "$spec_status" != "approved" ]; then
                echo "⚠️  Spec phase must be completed first (current: $spec_status)"
                return 1
            fi
            ;;
        "execute")
            local task_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.task.status" "$milestone_file")
            if [ "$task_status" != "completed" ] && [ "$task_status" != "approved" ]; then
                echo "⚠️  Task phase must be completed first (current: $task_status)"
                return 1
            fi
            ;;
    esac
    
    # Check for approval requirements
    if [ "$phase_name" != "design" ]; then
        local prev_phase=$(get_previous_phase "$phase_name")
        local approval_required=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$prev_phase.approval_required" "$milestone_file")
        
        if [ "$approval_required" = "true" ]; then
            local approved_at=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$prev_phase.approved_at" "$milestone_file")
            if [ "$approved_at" = "null" ] || [ -z "$approved_at" ]; then
                echo "⚠️  Previous phase ($prev_phase) requires approval before proceeding"
                echo "💡 Request approval with: /milestone/approve $milestone_id $task_id $prev_phase"
                return 1
            fi
        fi
    fi
    
    return 0
}

# Get previous phase name
get_previous_phase() {
    case "$1" in
        "spec") echo "design" ;;
        "task") echo "spec" ;;
        "execute") echo "task" ;;
        *) echo "" ;;
    esac
}

# Complete kiro phase with deliverable validation
complete_kiro_phase() {
    local milestone_id=$1
    local task_id=$2
    local phase_name=$3
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Validate deliverables
    if ! validate_phase_deliverables "$milestone_id" "$task_id" "$phase_name"; then
        echo "❌ Cannot complete phase - deliverables not ready"
        return 1
    fi
    
    # Update phase status
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.status) = \"completed\"" -i "$milestone_file"
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.completed_at) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" -i "$milestone_file"
    
    # Calculate actual hours (simplified - in production would track actual time)
    local started_at=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.started_at" "$milestone_file")
    local estimated_hours=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.estimated_hours" "$milestone_file")
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.actual_hours) = $estimated_hours" -i "$milestone_file"
    
    echo "✅ Completed $phase_name phase for task $task_id"
    
    # Check if approval is required
    local approval_required=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.approval_required" "$milestone_file")
    if [ "$approval_required" = "true" ]; then
        echo "🔐 This phase requires approval before proceeding to the next phase"
        echo "💡 Request approval with: /milestone/approve $milestone_id $task_id $phase_name"
        
        # Update status to waiting for approval
        yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.status) = \"waiting_approval\"" -i "$milestone_file"
    else
        # Auto-transition to next phase if no approval needed
        local next_phase=$(get_next_phase "$phase_name")
        if [ -n "$next_phase" ]; then
            echo "🔄 Auto-transitioning to $next_phase phase..."
            start_kiro_phase "$milestone_id" "$task_id" "$next_phase"
        else
            # Task is complete
            echo "🎉 All phases complete! Task is ready for deployment."
            yq e "(.tasks[] | select(.id == \"$task_id\") | .status) = \"completed\"" -i "$milestone_file"
        fi
    fi
    
    return 0
}

# Get next phase name
get_next_phase() {
    case "$1" in
        "design") echo "spec" ;;
        "spec") echo "task" ;;
        "task") echo "execute" ;;
        "execute") echo "" ;;
        *) echo "" ;;
    esac
}
```

## Deliverable Management

```bash
# Create deliverable directories
create_deliverable_directories() {
    local milestone_id=$1
    local task_id=$2
    
    local base_dir=".milestones/deliverables/$task_id"
    
    # Create phase directories
    mkdir -p "$base_dir/design"
    mkdir -p "$base_dir/spec"
    mkdir -p "$base_dir/task"
    mkdir -p "$base_dir/execute"
    
    # Create README for each phase
    for phase in design spec task execute; do
        cat > "$base_dir/$phase/README.md" <<EOF
# $phase Phase Deliverables

Task: $task_id
Phase: $phase
Created: $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Required Deliverables

$(list_phase_deliverables "$milestone_id" "$task_id" "$phase")

## Instructions

1. Create each deliverable file in this directory
2. Use the provided templates as starting points
3. Mark deliverables as complete when ready
4. Request approval if required for this phase

## Status

Use \`/milestone/visualize $milestone_id $task_id\` to see current status.
EOF
    done
}

# Validate phase deliverables
validate_phase_deliverables() {
    local milestone_id=$1
    local task_id=$2
    local phase_name=$3
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local deliverable_dir=".milestones/deliverables/$task_id/$phase_name"
    
    # Get required deliverables
    local deliverables=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.deliverables[]" "$milestone_file")
    
    local missing_deliverables=""
    local all_present=true
    
    echo "🔍 Validating $phase_name deliverables..."
    
    while IFS= read -r deliverable; do
        local file_path="$deliverable_dir/$deliverable"
        
        # Check if deliverable exists (handle both files and directories)
        if [ -f "$file_path" ] || [ -d "$file_path" ]; then
            echo "  ✅ $deliverable"
        else
            echo "  ❌ $deliverable (missing)"
            missing_deliverables="$missing_deliverables\n  - $deliverable"
            all_present=false
        fi
    done <<< "$deliverables"
    
    if [ "$all_present" = true ]; then
        echo "✅ All deliverables validated"
        return 0
    else
        echo -e "\n❌ Missing deliverables:$missing_deliverables"
        echo -e "\n💡 Create missing deliverables in: $deliverable_dir/"
        return 1
    fi
}

# Generate phase templates
generate_phase_templates() {
    local milestone_id=$1
    local task_id=$2
    local phase_name=$3
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local template_dir=".milestones/deliverables/$task_id/$phase_name"
    
    # Get task details
    local task_title=$(yq e ".tasks[] | select(.id == \"$task_id\") | .title" "$milestone_file")
    local task_type=$(yq e ".tasks[] | select(.id == \"$task_id\") | .type" "$milestone_file")
    
    case "$phase_name" in
        "design")
            generate_design_templates "$template_dir" "$task_title" "$task_type"
            ;;
        "spec")
            generate_spec_templates "$template_dir" "$task_title" "$task_type"
            ;;
        "task")
            generate_task_templates "$template_dir" "$task_title" "$task_type"
            ;;
        "execute")
            generate_execute_templates "$template_dir" "$task_title" "$task_type"
            ;;
    esac
}

# Generate design phase templates
generate_design_templates() {
    local dir=$1
    local title=$2
    local type=$3
    
    # Architecture diagram template
    cat > "$dir/architecture_diagram.md" <<EOF
# Architecture Design: $title

## System Overview
[Describe the high-level system architecture]

## Components
- Component 1: [Description]
- Component 2: [Description]

## Data Flow
\`\`\`mermaid
graph TD
    A[Input] --> B[Process]
    B --> C[Output]
\`\`\`

## Integration Points
[List external systems and APIs]

## Security Considerations
[Security design decisions]
EOF

    # API specification template
    cat > "$dir/api_specification.yaml" <<EOF
openapi: 3.0.0
info:
  title: $title API
  version: 1.0.0
  description: API specification for $title

paths:
  /endpoint:
    get:
      summary: Example endpoint
      responses:
        '200':
          description: Success
EOF
}
```

## Phase Transition Management

```bash
# Approve phase and transition
approve_kiro_phase() {
    local milestone_id=$1
    local task_id=$2
    local phase_name=$3
    local approver=${4:-"$USER"}
    local approval_notes=${5:-"Approved"}
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Validate phase is waiting for approval
    local phase_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.status" "$milestone_file")
    if [ "$phase_status" != "waiting_approval" ] && [ "$phase_status" != "completed" ]; then
        echo "❌ Phase $phase_name is not ready for approval (status: $phase_status)"
        return 1
    fi
    
    # Record approval
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.status) = \"approved\"" -i "$milestone_file"
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.approved_at) = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" -i "$milestone_file"
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.approved_by) = \"$approver\"" -i "$milestone_file"
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase_name.approval_notes) = \"$approval_notes\"" -i "$milestone_file"
    
    echo "✅ Phase $phase_name approved by $approver"
    
    # Auto-transition to next phase
    local next_phase=$(get_next_phase "$phase_name")
    if [ -n "$next_phase" ]; then
        echo "🔄 Transitioning to $next_phase phase..."
        start_kiro_phase "$milestone_id" "$task_id" "$next_phase"
    else
        echo "🎉 All phases complete and approved!"
        yq e "(.tasks[] | select(.id == \"$task_id\") | .status) = \"completed\"" -i "$milestone_file"
    fi
    
    return 0
}

# Show phase guidance
show_phase_guidance() {
    local phase_name=$1
    
    case "$phase_name" in
        "design")
            cat <<EOF

📐 DESIGN PHASE GUIDANCE
========================
Focus on high-level architecture and system design:
1. Create architecture diagrams showing component relationships
2. Define API contracts and data models
3. Document security boundaries and considerations
4. Establish integration points with external systems

Key deliverables:
- architecture_diagram.md - System architecture with components
- api_specification.yaml - OpenAPI spec for all endpoints
- data_model.md - Database schema and relationships
- security_design.md - Security controls and threat model

Tips:
- Think about scalability from the start
- Consider both happy path and error scenarios
- Document assumptions and constraints
- Get stakeholder feedback early
EOF
            ;;
            
        "spec")
            cat <<EOF

📋 SPECIFICATION PHASE GUIDANCE
===============================
Create detailed technical specifications:
1. Write comprehensive technical documentation
2. Define all acceptance criteria
3. Create detailed test plans
4. Document rollout and rollback procedures

Key deliverables:
- technical_specification.md - Detailed implementation spec
- test_plan.md - Test scenarios and coverage goals
- acceptance_criteria.md - Clear success metrics
- rollout_plan.md - Deployment strategy

Tips:
- Be specific about edge cases
- Include performance requirements
- Define monitoring and alerting needs
- Consider backward compatibility
EOF
            ;;
            
        "task")
            cat <<EOF

📝 TASK BREAKDOWN PHASE GUIDANCE
================================
Break down work into manageable tasks:
1. Create implementation stories/tasks
2. Estimate effort for each task
3. Identify dependencies between tasks
4. Assess and document risks

Key deliverables:
- implementation_tasks.md - Detailed task list
- story_breakdown.md - User stories with points
- dependency_map.md - Task dependencies
- risk_assessment.md - Risks and mitigations

Tips:
- Keep tasks small (< 1 day of work)
- Identify parallel work opportunities
- Flag external dependencies early
- Include testing in estimates
EOF
            ;;
            
        "execute")
            cat <<EOF

🚀 EXECUTION PHASE GUIDANCE
===========================
Implement, test, and deploy:
1. Write clean, tested code
2. Implement comprehensive tests
3. Update documentation
4. Prepare for deployment

Key deliverables:
- Implementation code with tests
- Documentation updates
- Deployment configuration
- Performance validation

Tips:
- Follow coding standards
- Write tests first (TDD)
- Document as you code
- Get code reviews early and often
EOF
            ;;
    esac
}
```

## Kiro Compliance Enforcement

```bash
# Enforce kiro compliance for milestone
enforce_kiro_compliance() {
    local milestone_id=$1
    local enforcement_level=${2:-"$KIRO_ENFORCEMENT_LEVEL"}
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    echo "🔒 Enforcing kiro compliance (level: $enforcement_level)..."
    
    # Check all tasks have kiro enabled
    local non_kiro_tasks=$(yq e '.tasks[] | select(.kiro_workflow.enabled != true) | .id' "$milestone_file" 2>/dev/null)
    
    if [ -n "$non_kiro_tasks" ]; then
        echo "⚠️  Found non-kiro tasks:"
        echo "$non_kiro_tasks"
        
        case "$enforcement_level" in
            "strict")
                echo "❌ ERROR: All tasks must use kiro workflow in strict mode"
                echo "🔧 Auto-migrating tasks to kiro workflow..."
                
                while IFS= read -r task_id; do
                    migrate_task_to_kiro "$milestone_id" "$task_id"
                done <<< "$non_kiro_tasks"
                ;;
                
            "flexible")
                echo "⚠️  WARNING: Non-kiro tasks detected. Consider migrating for better tracking."
                echo "💡 Run: /milestone/migrate $milestone_id --to-kiro"
                ;;
                
            "progressive")
                echo "📊 Analyzing task complexity for auto-migration..."
                
                while IFS= read -r task_id; do
                    local estimated_hours=$(yq e ".tasks[] | select(.id == \"$task_id\") | .estimated_hours" "$milestone_file")
                    
                    if [ "${estimated_hours:-0}" -gt 4 ]; then
                        echo "  🔄 Task $task_id (${estimated_hours}h) requires kiro workflow"
                        migrate_task_to_kiro "$milestone_id" "$task_id"
                    else
                        echo "  ✓ Task $task_id (${estimated_hours}h) can remain simple"
                    fi
                done <<< "$non_kiro_tasks"
                ;;
        esac
    else
        echo "✅ All tasks are kiro-compliant"
    fi
    
    # Validate kiro configuration
    validate_kiro_configuration "$milestone_id"
    
    # Update compliance score
    calculate_kiro_compliance_score "$milestone_id"
}

# Migrate existing task to kiro workflow
migrate_task_to_kiro() {
    local milestone_id=$1
    local task_id=$2
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    echo "  🔄 Migrating task $task_id to kiro workflow..."
    
    # Get current task details
    local task_title=$(yq e ".tasks[] | select(.id == \"$task_id\") | .title" "$milestone_file")
    local task_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .status" "$milestone_file")
    local estimated_hours=$(yq e ".tasks[] | select(.id == \"$task_id\") | .estimated_hours // 8" "$milestone_file")
    
    # Calculate phase hours
    local design_hours=$(echo "$estimated_hours * $KIRO_DESIGN_WEIGHT / 100" | bc -l | xargs printf "%.1f")
    local spec_hours=$(echo "$estimated_hours * $KIRO_SPEC_WEIGHT / 100" | bc -l | xargs printf "%.1f")
    local task_hours=$(echo "$estimated_hours * $KIRO_TASK_WEIGHT / 100" | bc -l | xargs printf "%.1f")
    local execute_hours=$(echo "$estimated_hours * $KIRO_EXECUTE_WEIGHT / 100" | bc -l | xargs printf "%.1f")
    
    # Determine current phase based on task status
    local current_phase="design"
    local design_status="pending"
    local spec_status="pending"
    local task_phase_status="pending"
    local execute_status="pending"
    
    case "$task_status" in
        "in_progress")
            current_phase="execute"
            design_status="completed"
            spec_status="completed"
            task_phase_status="completed"
            execute_status="in_progress"
            ;;
        "completed")
            current_phase="execute"
            design_status="completed"
            spec_status="completed"
            task_phase_status="completed"
            execute_status="completed"
            ;;
    esac
    
    # Add kiro workflow structure
    yq e "(.tasks[] | select(.id == \"$task_id\") | .type) = \"kiro_workflow\"" -i "$milestone_file"
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.enabled) = true" -i "$milestone_file"
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.policy) = \"mandatory\"" -i "$milestone_file"
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.current_phase) = \"$current_phase\"" -i "$milestone_file"
    
    # Add phase hours
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phase_hours.design) = $design_hours" -i "$milestone_file"
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phase_hours.spec) = $spec_hours" -i "$milestone_file"
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phase_hours.task) = $task_hours" -i "$milestone_file"
    yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phase_hours.execute) = $execute_hours" -i "$milestone_file"
    
    # Add phase structures
    for phase in design spec task execute; do
        local phase_status_var="${phase}_status"
        if [ "$phase" = "task" ]; then
            phase_status_var="task_phase_status"
        fi
        
        yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.status) = \"${!phase_status_var}\"" -i "$milestone_file"
        yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.description) = \"$(get_phase_description $phase)\"" -i "$milestone_file"
        yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.approval_required) = $(get_phase_approval_default $phase)" -i "$milestone_file"
        
        # Add default deliverables
        local deliverables=$(generate_${phase}_deliverables "feature")
        yq e "(.tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.deliverables) = $deliverables" -i "$milestone_file"
    done
    
    # Create deliverable directories
    create_deliverable_directories "$milestone_id" "$task_id"
    
    echo "  ✅ Task $task_id migrated to kiro workflow"
}

# Get phase description
get_phase_description() {
    case "$1" in
        "design") echo "Architecture design and system planning" ;;
        "spec") echo "Detailed technical specification" ;;
        "task") echo "Task breakdown and planning" ;;
        "execute") echo "Implementation and testing" ;;
    esac
}

# Get phase approval default
get_phase_approval_default() {
    case "$1" in
        "design") echo "$KIRO_DESIGN_APPROVAL" ;;
        "spec") echo "$KIRO_SPEC_APPROVAL" ;;
        "task") echo "$KIRO_TASK_APPROVAL" ;;
        "execute") echo "$KIRO_EXECUTE_APPROVAL" ;;
    esac
}

# Calculate kiro compliance score
calculate_kiro_compliance_score() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    local total_tasks=$(yq e '.tasks | length' "$milestone_file")
    local kiro_tasks=$(yq e '.tasks[] | select(.kiro_workflow.enabled == true) | .id' "$milestone_file" | wc -l)
    
    local compliance_score=0
    if [ "$total_tasks" -gt 0 ]; then
        compliance_score=$((kiro_tasks * 100 / total_tasks))
    fi
    
    # Update milestone compliance score
    yq e ".kiro_compliance_score = $compliance_score" -i "$milestone_file"
    
    echo "📊 Kiro Compliance Score: $compliance_score%"
    
    if [ "$compliance_score" -eq 100 ]; then
        echo "🏆 Perfect kiro compliance achieved!"
    elif [ "$compliance_score" -ge 80 ]; then
        echo "✅ Good kiro adoption ($compliance_score%)"
    elif [ "$compliance_score" -ge 50 ]; then
        echo "⚠️  Moderate kiro adoption ($compliance_score%) - consider migrating more tasks"
    else
        echo "❌ Low kiro adoption ($compliance_score%) - migration recommended"
    fi
    
    return 0
}

# Initialize kiro-native system
initialize_kiro_native() {
    echo "🚀 Initializing Kiro-Native Workflow System..."
    
    # Create necessary directories
    mkdir -p .milestones/deliverables
    mkdir -p .milestones/approvals
    mkdir -p .milestones/kiro-metrics
    
    # Set default configuration
    echo "$KIRO_POLICY_MODE" > .milestones/config/kiro-policy.txt
    echo "$KIRO_ENFORCEMENT_LEVEL" > .milestones/config/kiro-enforcement.txt
    
    # Create kiro configuration file
    cat > .milestones/config/kiro-config.yaml <<EOF
# Kiro-Native Configuration
policy:
  mode: $KIRO_POLICY_MODE
  enforcement: $KIRO_ENFORCEMENT_LEVEL
  visualization: $KIRO_VISUALIZATION_MODE

phase_weights:
  design: $KIRO_DESIGN_WEIGHT
  spec: $KIRO_SPEC_WEIGHT
  task: $KIRO_TASK_WEIGHT
  execute: $KIRO_EXECUTE_WEIGHT

approval_gates:
  design_approval: $KIRO_DESIGN_APPROVAL
  spec_approval: $KIRO_SPEC_APPROVAL
  task_approval: $KIRO_TASK_APPROVAL
  execute_approval: $KIRO_EXECUTE_APPROVAL

features:
  auto_migration: true
  deliverable_validation: true
  phase_templates: true
  approval_workflow: true
  visualization_dashboard: true

created_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
    
    echo "✅ Kiro-Native System initialized successfully"
    echo "📊 Policy: $KIRO_POLICY_MODE | Enforcement: $KIRO_ENFORCEMENT_LEVEL"
}
```

## Export Functions

```bash
# Export all kiro-native functions
export -f create_kiro_native_task
export -f start_kiro_phase
export -f complete_kiro_phase
export -f approve_kiro_phase
export -f validate_phase_prerequisites
export -f validate_phase_deliverables
export -f enforce_kiro_compliance
export -f migrate_task_to_kiro
export -f calculate_kiro_compliance_score
export -f initialize_kiro_native
```