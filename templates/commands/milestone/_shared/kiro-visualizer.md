---
description: Kiro Workflow Visualization System - Rich visual representations of phase progression and deliverables
---

# Kiro Workflow Visualization System

Comprehensive visualization capabilities for the kiro workflow standard, providing rich visual feedback on phase progression, deliverables, approvals, and dependencies.

## Core Visualization Components

```bash
# Visualization mode configuration
KIRO_VIZ_MODE="${KIRO_VIZ_MODE:-rich}"  # simple | rich | dashboard | web
KIRO_VIZ_COLORS="${KIRO_VIZ_COLORS:-true}"
KIRO_VIZ_ICONS="${KIRO_VIZ_ICONS:-true}"
KIRO_VIZ_PROGRESS="${KIRO_VIZ_PROGRESS:-detailed}"
```

## Phase Visualization

```bash
# Visualize kiro workflow for a task
visualize_kiro_workflow() {
    local milestone_id=$1
    local task_id=$2
    local viz_mode=${3:-"$KIRO_VIZ_MODE"}
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    if [ ! -f "$milestone_file" ]; then
        echo "❌ Milestone $milestone_id not found"
        return 1
    fi
    
    # Get task details
    local task_data=$(yq e ".tasks[] | select(.id == \"$task_id\")" "$milestone_file")
    
    if [ -z "$task_data" ]; then
        echo "❌ Task $task_id not found in milestone"
        return 1
    fi
    
    case "$viz_mode" in
        "simple")
            visualize_kiro_simple "$milestone_id" "$task_id"
            ;;
        "rich")
            visualize_kiro_rich "$milestone_id" "$task_id"
            ;;
        "dashboard")
            visualize_kiro_dashboard "$milestone_id" "$task_id"
            ;;
        "web")
            generate_kiro_web_dashboard "$milestone_id" "$task_id"
            ;;
        *)
            visualize_kiro_rich "$milestone_id" "$task_id"
            ;;
    esac
}

# Simple text-based visualization
visualize_kiro_simple() {
    local milestone_id=$1
    local task_id=$2
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    echo "Task: $task_id"
    echo "Phases:"
    
    for phase in design spec task execute; do
        local status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.status" "$milestone_file")
        local icon="[ ]"
        
        case "$status" in
            "completed"|"approved") icon="[✓]" ;;
            "in_progress") icon="[>]" ;;
            "waiting_approval") icon="[?]" ;;
            "blocked") icon="[X]" ;;
        esac
        
        echo "  $icon $phase: $status"
    done
}

# Rich visualization with progress bars and details
visualize_kiro_rich() {
    local milestone_id=$1
    local task_id=$2
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Get task details
    local task_title=$(yq e ".tasks[] | select(.id == \"$task_id\") | .title" "$milestone_file")
    local current_phase=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.current_phase" "$milestone_file")
    
    # Calculate overall progress
    local overall_progress=$(calculate_kiro_progress "$milestone_id" "$task_id")
    
    # Create visualization
    cat <<EOF

╔══════════════════════════════════════════════════════════════════╗
║                 📊 KIRO WORKFLOW VISUALIZATION                    ║
╠══════════════════════════════════════════════════════════════════╣
║ Task: $task_title
║ ID: $task_id
║ Current Phase: $(format_phase_name "$current_phase")
║ Overall Progress: $(draw_progress_bar $overall_progress 30) $overall_progress%
╚══════════════════════════════════════════════════════════════════╝

$(visualize_phase_timeline "$milestone_id" "$task_id")

$(visualize_phase_details "$milestone_id" "$task_id")

$(visualize_deliverables_matrix "$milestone_id" "$task_id")

$(visualize_approval_status "$milestone_id" "$task_id")

EOF
}

# Visualize phase timeline
visualize_phase_timeline() {
    local milestone_id=$1
    local task_id=$2
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│                        PHASE TIMELINE                           │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    
    # Design phase
    local design_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.design.status" "$milestone_file")
    local design_hours=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phase_hours.design" "$milestone_file")
    local design_progress=$(get_phase_progress "$design_status")
    
    echo "│ 📐 DESIGN    $(format_phase_status_icon "$design_status") $(draw_progress_bar $design_progress 15) ${design_hours}h │"
    
    # Connection line
    echo "│       ↓                                                         │"
    
    # Spec phase
    local spec_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.spec.status" "$milestone_file")
    local spec_hours=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phase_hours.spec" "$milestone_file")
    local spec_progress=$(get_phase_progress "$spec_status")
    
    echo "│ 📋 SPEC      $(format_phase_status_icon "$spec_status") $(draw_progress_bar $spec_progress 15) ${spec_hours}h │"
    
    # Connection line
    echo "│       ↓                                                         │"
    
    # Task phase
    local task_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.task.status" "$milestone_file")
    local task_hours=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phase_hours.task" "$milestone_file")
    local task_progress=$(get_phase_progress "$task_status")
    
    echo "│ 📝 TASK      $(format_phase_status_icon "$task_status") $(draw_progress_bar $task_progress 15) ${task_hours}h │"
    
    # Connection line
    echo "│       ↓                                                         │"
    
    # Execute phase
    local execute_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.execute.status" "$milestone_file")
    local execute_hours=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phase_hours.execute" "$milestone_file")
    local execute_progress=$(get_phase_progress "$execute_status")
    
    echo "│ 🚀 EXECUTE   $(format_phase_status_icon "$execute_status") $(draw_progress_bar $execute_progress 15) ${execute_hours}h │"
    
    echo "└─────────────────────────────────────────────────────────────────┘"
}

# Visualize phase details
visualize_phase_details() {
    local milestone_id=$1
    local task_id=$2
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local current_phase=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.current_phase" "$milestone_file")
    
    echo ""
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│                    CURRENT PHASE DETAILS                        │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    
    if [ -n "$current_phase" ] && [ "$current_phase" != "null" ]; then
        local phase_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$current_phase.status" "$milestone_file")
        local phase_desc=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$current_phase.description" "$milestone_file")
        local started_at=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$current_phase.started_at" "$milestone_file")
        local estimated_hours=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phase_hours.$current_phase" "$milestone_file")
        
        echo "│ Phase: $(format_phase_name "$current_phase")                                          │"
        echo "│ Status: $(format_phase_status "$phase_status")                                      │"
        echo "│ Description: $(echo "$phase_desc" | head -c 40)...              │"
        
        if [ "$started_at" != "null" ] && [ -n "$started_at" ]; then
            echo "│ Started: $started_at                         │"
            echo "│ Duration: $(calculate_duration "$started_at") / ${estimated_hours}h estimated    │"
        else
            echo "│ Not started yet | Estimated: ${estimated_hours}h                    │"
        fi
    else
        echo "│ No active phase                                                 │"
    fi
    
    echo "└─────────────────────────────────────────────────────────────────┘"
}

# Visualize deliverables matrix
visualize_deliverables_matrix() {
    local milestone_id=$1
    local task_id=$2
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    echo ""
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│                      DELIVERABLES MATRIX                        │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    
    for phase in design spec task execute; do
        local deliverables=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.deliverables[]" "$milestone_file" 2>/dev/null)
        local phase_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.status" "$milestone_file")
        
        echo "│ $(format_phase_name_short "$phase"): "
        
        if [ -n "$deliverables" ]; then
            while IFS= read -r deliverable; do
                local deliverable_status=$(check_deliverable_status "$milestone_id" "$task_id" "$phase" "$deliverable")
                echo "│   $deliverable_status $deliverable"
            done <<< "$deliverables"
        else
            echo "│   (no deliverables defined)"
        fi
        
        if [ "$phase" != "execute" ]; then
            echo "│                                                                 │"
        fi
    done
    
    echo "└─────────────────────────────────────────────────────────────────┘"
}

# Visualize approval status
visualize_approval_status() {
    local milestone_id=$1
    local task_id=$2
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    echo ""
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│                      APPROVAL WORKFLOW                          │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    
    for phase in design spec task execute; do
        local approval_required=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.approval_required" "$milestone_file")
        local approved_at=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.approved_at" "$milestone_file")
        local approved_by=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.approved_by" "$milestone_file")
        local phase_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.status" "$milestone_file")
        
        if [ "$approval_required" = "true" ]; then
            if [ "$approved_at" != "null" ] && [ -n "$approved_at" ]; then
                echo "│ $(format_phase_name_short "$phase"): ✅ Approved by $approved_by              │"
                echo "│      at $approved_at                      │"
            elif [ "$phase_status" = "waiting_approval" ]; then
                echo "│ $(format_phase_name_short "$phase"): ⏳ Awaiting approval                      │"
            elif [ "$phase_status" = "completed" ]; then
                echo "│ $(format_phase_name_short "$phase"): 🔐 Ready for approval                    │"
            else
                echo "│ $(format_phase_name_short "$phase"): ⏸️  Approval required (not ready)        │"
            fi
        else
            echo "│ $(format_phase_name_short "$phase"): ➖ No approval required                   │"
        fi
    done
    
    echo "└─────────────────────────────────────────────────────────────────┘"
}
```

## Dashboard Visualization

```bash
# Generate comprehensive dashboard view
visualize_kiro_dashboard() {
    local milestone_id=$1
    local task_id=${2:-"all"}
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Clear screen for dashboard
    clear
    
    # Dashboard header
    echo "════════════════════════════════════════════════════════════════════════════"
    echo "                    🎯 KIRO WORKFLOW DASHBOARD                              "
    echo "════════════════════════════════════════════════════════════════════════════"
    echo ""
    
    # Milestone overview
    local milestone_title=$(yq e '.title' "$milestone_file")
    local milestone_status=$(yq e '.status' "$milestone_file")
    local milestone_progress=$(yq e '.progress.percentage // 0' "$milestone_file")
    
    echo "📦 Milestone: $milestone_title"
    echo "📊 Status: $milestone_status | Progress: $milestone_progress%"
    echo "────────────────────────────────────────────────────────────────────────────"
    echo ""
    
    if [ "$task_id" = "all" ]; then
        # Show all tasks
        visualize_all_tasks_kiro "$milestone_id"
    else
        # Show specific task
        visualize_kiro_rich "$milestone_id" "$task_id"
    fi
    
    # Summary statistics
    echo ""
    echo "────────────────────────────────────────────────────────────────────────────"
    visualize_kiro_statistics "$milestone_id"
    
    # Legend
    echo ""
    echo "────────────────────────────────────────────────────────────────────────────"
    echo "Legend: ✅ Complete | 🔄 In Progress | ⏳ Waiting | 🚫 Blocked | ⏸️ Pending"
    echo "Commands: visualize [task_id] | approve [task_id] [phase] | start [task_id] [phase]"
}

# Visualize all tasks with kiro status
visualize_all_tasks_kiro() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    echo "📋 TASKS OVERVIEW"
    echo ""
    
    # Get all task IDs
    local task_ids=$(yq e '.tasks[].id' "$milestone_file")
    
    while IFS= read -r task_id; do
        local task_title=$(yq e ".tasks[] | select(.id == \"$task_id\") | .title" "$milestone_file")
        local kiro_enabled=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.enabled" "$milestone_file")
        
        if [ "$kiro_enabled" = "true" ]; then
            visualize_task_kiro_summary "$milestone_id" "$task_id"
        else
            echo "⚠️  $task_id: $task_title (Non-kiro task)"
        fi
        echo ""
    done <<< "$task_ids"
}

# Visualize task kiro summary
visualize_task_kiro_summary() {
    local milestone_id=$1
    local task_id=$2
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    local task_title=$(yq e ".tasks[] | select(.id == \"$task_id\") | .title" "$milestone_file")
    local current_phase=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.current_phase" "$milestone_file")
    
    echo "📌 $task_id: $task_title"
    echo -n "   "
    
    for phase in design spec task execute; do
        local status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.status" "$milestone_file")
        
        case "$status" in
            "completed"|"approved")
                echo -n "[✅ $(echo $phase | cut -c1-3 | tr '[:lower:]' '[:upper:]')] "
                ;;
            "in_progress")
                echo -n "[🔄 $(echo $phase | cut -c1-3 | tr '[:lower:]' '[:upper:]')] "
                ;;
            "waiting_approval")
                echo -n "[⏳ $(echo $phase | cut -c1-3 | tr '[:lower:]' '[:upper:]')] "
                ;;
            "blocked")
                echo -n "[🚫 $(echo $phase | cut -c1-3 | tr '[:lower:]' '[:upper:]')] "
                ;;
            *)
                echo -n "[⏸️ $(echo $phase | cut -c1-3 | tr '[:lower:]' '[:upper:]')] "
                ;;
        esac
        
        if [ "$phase" != "execute" ]; then
            echo -n "→ "
        fi
    done
    
    echo ""
    
    # Show current action needed
    local phase_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$current_phase.status" "$milestone_file")
    
    case "$phase_status" in
        "waiting_approval")
            echo "   🔐 Action: Approve $current_phase phase"
            ;;
        "pending")
            echo "   ▶️ Action: Start $current_phase phase"
            ;;
        "in_progress")
            echo "   ⚡ Action: Complete $current_phase phase"
            ;;
    esac
}

# Visualize kiro statistics
visualize_kiro_statistics() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    echo "📊 KIRO STATISTICS"
    echo ""
    
    # Count tasks by phase
    local design_count=0
    local spec_count=0
    local task_count=0
    local execute_count=0
    local completed_count=0
    
    local task_ids=$(yq e '.tasks[].id' "$milestone_file")
    local total_kiro_tasks=0
    
    while IFS= read -r task_id; do
        local kiro_enabled=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.enabled" "$milestone_file")
        
        if [ "$kiro_enabled" = "true" ]; then
            ((total_kiro_tasks++))
            
            local current_phase=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.current_phase" "$milestone_file")
            local task_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .status" "$milestone_file")
            
            if [ "$task_status" = "completed" ]; then
                ((completed_count++))
            else
                case "$current_phase" in
                    "design") ((design_count++)) ;;
                    "spec") ((spec_count++)) ;;
                    "task") ((task_count++)) ;;
                    "execute") ((execute_count++)) ;;
                esac
            fi
        fi
    done <<< "$task_ids"
    
    echo "Total Kiro Tasks: $total_kiro_tasks"
    echo "├─ In Design: $design_count"
    echo "├─ In Specification: $spec_count"
    echo "├─ In Task Breakdown: $task_count"
    echo "├─ In Execution: $execute_count"
    echo "└─ Completed: $completed_count"
    
    # Calculate phase velocity
    echo ""
    echo "Phase Velocity:"
    local avg_design_time=$(calculate_average_phase_time "$milestone_id" "design")
    local avg_spec_time=$(calculate_average_phase_time "$milestone_id" "spec")
    local avg_task_time=$(calculate_average_phase_time "$milestone_id" "task")
    local avg_execute_time=$(calculate_average_phase_time "$milestone_id" "execute")
    
    echo "├─ Design: ~${avg_design_time}h avg"
    echo "├─ Spec: ~${avg_spec_time}h avg"
    echo "├─ Task: ~${avg_task_time}h avg"
    echo "└─ Execute: ~${avg_execute_time}h avg"
}
```

## Helper Functions

```bash
# Draw progress bar
draw_progress_bar() {
    local progress=$1
    local width=${2:-20}
    
    local filled=$((progress * width / 100))
    local empty=$((width - filled))
    
    echo -n "["
    
    for ((i=0; i<filled; i++)); do
        echo -n "█"
    done
    
    for ((i=0; i<empty; i++)); do
        echo -n "░"
    done
    
    echo -n "]"
}

# Get phase progress percentage
get_phase_progress() {
    local status=$1
    
    case "$status" in
        "completed"|"approved") echo "100" ;;
        "in_progress") echo "50" ;;
        "waiting_approval") echo "75" ;;
        "blocked") echo "25" ;;
        *) echo "0" ;;
    esac
}

# Format phase status icon
format_phase_status_icon() {
    local status=$1
    
    case "$status" in
        "completed") echo "✅" ;;
        "approved") echo "✅" ;;
        "in_progress") echo "🔄" ;;
        "waiting_approval") echo "⏳" ;;
        "blocked") echo "🚫" ;;
        *) echo "⏸️" ;;
    esac
}

# Format phase name
format_phase_name() {
    local phase=$1
    
    case "$phase" in
        "design") echo "📐 Design" ;;
        "spec") echo "📋 Specification" ;;
        "task") echo "📝 Task Breakdown" ;;
        "execute") echo "🚀 Execution" ;;
        *) echo "$phase" ;;
    esac
}

# Format phase name short
format_phase_name_short() {
    local phase=$1
    
    case "$phase" in
        "design") echo "DES" ;;
        "spec") echo "SPC" ;;
        "task") echo "TSK" ;;
        "execute") echo "EXE" ;;
        *) echo "$(echo $phase | cut -c1-3 | tr '[:lower:]' '[:upper:]')" ;;
    esac
}

# Format phase status
format_phase_status() {
    local status=$1
    
    case "$status" in
        "completed") echo "✅ Completed" ;;
        "approved") echo "✅ Approved" ;;
        "in_progress") echo "🔄 In Progress" ;;
        "waiting_approval") echo "⏳ Awaiting Approval" ;;
        "blocked") echo "🚫 Blocked" ;;
        "pending") echo "⏸️ Pending" ;;
        *) echo "$status" ;;
    esac
}

# Check deliverable status
check_deliverable_status() {
    local milestone_id=$1
    local task_id=$2
    local phase=$3
    local deliverable=$4
    
    local deliverable_path=".milestones/deliverables/$task_id/$phase/$deliverable"
    
    if [ -f "$deliverable_path" ] || [ -d "$deliverable_path" ]; then
        echo "✅"
    else
        echo "⭕"
    fi
}

# Calculate duration from start time
calculate_duration() {
    local start_time=$1
    
    if [ "$start_time" = "null" ] || [ -z "$start_time" ]; then
        echo "0h"
        return
    fi
    
    # Convert to seconds (simplified - in production would use proper date math)
    local start_seconds=$(date -d "$start_time" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$start_time" +%s 2>/dev/null || echo "0")
    local current_seconds=$(date +%s)
    
    if [ "$start_seconds" -eq 0 ]; then
        echo "0h"
        return
    fi
    
    local duration_seconds=$((current_seconds - start_seconds))
    local duration_hours=$((duration_seconds / 3600))
    
    echo "${duration_hours}h"
}

# Calculate kiro progress
calculate_kiro_progress() {
    local milestone_id=$1
    local task_id=$2
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    local total_weight=0
    local completed_weight=0
    
    for phase in design spec task execute; do
        local phase_weight=$(yq e ".kiro_configuration.phase_weights.$phase // 25" "$milestone_file")
        local phase_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.status" "$milestone_file")
        
        total_weight=$((total_weight + phase_weight))
        
        case "$phase_status" in
            "completed"|"approved")
                completed_weight=$((completed_weight + phase_weight))
                ;;
            "in_progress")
                completed_weight=$((completed_weight + phase_weight / 2))
                ;;
            "waiting_approval")
                completed_weight=$((completed_weight + phase_weight * 3 / 4))
                ;;
        esac
    done
    
    if [ "$total_weight" -gt 0 ]; then
        echo $((completed_weight * 100 / total_weight))
    else
        echo "0"
    fi
}

# Calculate average phase time
calculate_average_phase_time() {
    local milestone_id=$1
    local phase_name=$2
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Get estimated hours for the phase (simplified)
    local avg_hours=$(yq e ".kiro_configuration.phase_weights.$phase_name // 25" "$milestone_file")
    
    # In production, would calculate actual average from completed phases
    echo "$avg_hours"
}
```

## Web Dashboard Generation

```bash
# Generate interactive web dashboard
generate_kiro_web_dashboard() {
    local milestone_id=$1
    local task_id=${2:-"all"}
    
    local dashboard_dir=".milestones/web-dashboard"
    mkdir -p "$dashboard_dir"
    
    echo "🌐 Generating web dashboard..."
    
    # Generate HTML dashboard
    cat > "$dashboard_dir/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kiro Workflow Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        .header {
            background: white;
            border-radius: 12px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }
        .header h1 {
            color: #333;
            margin-bottom: 10px;
        }
        .header .subtitle {
            color: #666;
            font-size: 18px;
        }
        .task-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            gap: 20px;
        }
        .task-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }
        .task-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
        }
        .task-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin-bottom: 15px;
        }
        .phase-timeline {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
            position: relative;
        }
        .phase-timeline::before {
            content: '';
            position: absolute;
            top: 20px;
            left: 0;
            right: 0;
            height: 2px;
            background: #e0e0e0;
            z-index: 0;
        }
        .phase {
            position: relative;
            z-index: 1;
            text-align: center;
            flex: 1;
        }
        .phase-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            margin-bottom: 5px;
            background: white;
            border: 3px solid #e0e0e0;
        }
        .phase.completed .phase-icon {
            background: #4CAF50;
            border-color: #4CAF50;
            color: white;
        }
        .phase.in-progress .phase-icon {
            background: #2196F3;
            border-color: #2196F3;
            color: white;
            animation: pulse 2s infinite;
        }
        .phase.waiting .phase-icon {
            background: #FFC107;
            border-color: #FFC107;
            color: white;
        }
        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(33, 150, 243, 0.7); }
            70% { box-shadow: 0 0 0 10px rgba(33, 150, 243, 0); }
            100% { box-shadow: 0 0 0 0 rgba(33, 150, 243, 0); }
        }
        .phase-name {
            font-size: 12px;
            color: #666;
        }
        .progress-bar {
            background: #f0f0f0;
            border-radius: 20px;
            height: 10px;
            overflow: hidden;
            margin-bottom: 10px;
        }
        .progress-fill {
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            height: 100%;
            border-radius: 20px;
            transition: width 0.5s ease;
        }
        .deliverables {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #e0e0e0;
        }
        .deliverable-item {
            display: flex;
            align-items: center;
            margin-bottom: 8px;
            font-size: 14px;
            color: #555;
        }
        .deliverable-icon {
            margin-right: 8px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 30px;
        }
        .stat-card {
            background: white;
            border-radius: 8px;
            padding: 15px;
            text-align: center;
        }
        .stat-value {
            font-size: 32px;
            font-weight: bold;
            color: #667eea;
        }
        .stat-label {
            font-size: 14px;
            color: #666;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎯 Kiro Workflow Dashboard</h1>
            <div class="subtitle">Real-time milestone and task tracking with phase progression</div>
        </div>
        
        <div class="task-grid" id="taskGrid">
            <!-- Tasks will be inserted here by JavaScript -->
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-value" id="totalTasks">0</div>
                <div class="stat-label">Total Tasks</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="inProgress">0</div>
                <div class="stat-label">In Progress</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="awaitingApproval">0</div>
                <div class="stat-label">Awaiting Approval</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="completed">0</div>
                <div class="stat-label">Completed</div>
            </div>
        </div>
    </div>
    
    <script>
        // Load milestone data (in production, would fetch from API)
        const milestoneData = MILESTONE_DATA_PLACEHOLDER;
        
        // Render tasks
        function renderTasks() {
            const taskGrid = document.getElementById('taskGrid');
            taskGrid.innerHTML = '';
            
            milestoneData.tasks.forEach(task => {
                if (task.kiro_workflow && task.kiro_workflow.enabled) {
                    const taskCard = createTaskCard(task);
                    taskGrid.appendChild(taskCard);
                }
            });
            
            updateStats();
        }
        
        function createTaskCard(task) {
            const card = document.createElement('div');
            card.className = 'task-card';
            
            const phases = ['design', 'spec', 'task', 'execute'];
            const phaseIcons = {
                design: '📐',
                spec: '📋',
                task: '📝',
                execute: '🚀'
            };
            
            let phaseTimelineHTML = '<div class="phase-timeline">';
            phases.forEach(phase => {
                const phaseData = task.kiro_workflow.phases[phase];
                const status = phaseData.status;
                let statusClass = '';
                
                if (status === 'completed' || status === 'approved') statusClass = 'completed';
                else if (status === 'in_progress') statusClass = 'in-progress';
                else if (status === 'waiting_approval') statusClass = 'waiting';
                
                phaseTimelineHTML += `
                    <div class="phase ${statusClass}">
                        <div class="phase-icon">${phaseIcons[phase]}</div>
                        <div class="phase-name">${phase.toUpperCase()}</div>
                    </div>
                `;
            });
            phaseTimelineHTML += '</div>';
            
            const progress = calculateTaskProgress(task);
            
            card.innerHTML = `
                <div class="task-title">${task.title}</div>
                ${phaseTimelineHTML}
                <div class="progress-bar">
                    <div class="progress-fill" style="width: ${progress}%"></div>
                </div>
                <div style="text-align: center; color: #666; font-size: 14px;">
                    ${progress}% Complete
                </div>
            `;
            
            return card;
        }
        
        function calculateTaskProgress(task) {
            const phases = ['design', 'spec', 'task', 'execute'];
            const weights = { design: 15, spec: 25, task: 20, execute: 40 };
            let totalProgress = 0;
            
            phases.forEach(phase => {
                const status = task.kiro_workflow.phases[phase].status;
                const weight = weights[phase];
                
                if (status === 'completed' || status === 'approved') {
                    totalProgress += weight;
                } else if (status === 'in_progress') {
                    totalProgress += weight * 0.5;
                } else if (status === 'waiting_approval') {
                    totalProgress += weight * 0.75;
                }
            });
            
            return Math.round(totalProgress);
        }
        
        function updateStats() {
            let total = 0, inProgress = 0, awaiting = 0, completed = 0;
            
            milestoneData.tasks.forEach(task => {
                if (task.kiro_workflow && task.kiro_workflow.enabled) {
                    total++;
                    
                    if (task.status === 'completed') {
                        completed++;
                    } else {
                        const currentPhase = task.kiro_workflow.current_phase;
                        const phaseStatus = task.kiro_workflow.phases[currentPhase].status;
                        
                        if (phaseStatus === 'in_progress') inProgress++;
                        else if (phaseStatus === 'waiting_approval') awaiting++;
                    }
                }
            });
            
            document.getElementById('totalTasks').textContent = total;
            document.getElementById('inProgress').textContent = inProgress;
            document.getElementById('awaitingApproval').textContent = awaiting;
            document.getElementById('completed').textContent = completed;
        }
        
        // Initial render
        renderTasks();
        
        // Auto-refresh every 5 seconds
        setInterval(renderTasks, 5000);
    </script>
</body>
</html>
EOF
    
    # Generate data file
    generate_dashboard_data "$milestone_id" "$dashboard_dir"
    
    echo "✅ Web dashboard generated at: $dashboard_dir/index.html"
    echo "🌐 Open in browser: file://$(pwd)/$dashboard_dir/index.html"
    
    # Optionally start a simple HTTP server
    if command -v python3 &> /dev/null; then
        echo ""
        echo "💡 To view with live updates, run:"
        echo "   cd $dashboard_dir && python3 -m http.server 8080"
        echo "   Then open: http://localhost:8080"
    fi
}

# Generate dashboard data
generate_dashboard_data() {
    local milestone_id=$1
    local dashboard_dir=$2
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Convert YAML to JSON for web dashboard
    local milestone_json=$(yq e -o=json '.' "$milestone_file")
    
    # Update HTML with actual data
    sed -i.bak "s/MILESTONE_DATA_PLACEHOLDER/${milestone_json//\//\\/}/g" "$dashboard_dir/index.html"
    rm "$dashboard_dir/index.html.bak"
}

# Export visualization functions
export -f visualize_kiro_workflow
export -f visualize_kiro_simple
export -f visualize_kiro_rich
export -f visualize_kiro_dashboard
export -f generate_kiro_web_dashboard
```