# Progressive Visualization System - Scale-Aware UI Enhancement

## Core Progressive UI Interface

The progressive visualization system automatically adapts the user interface complexity based on project scale, providing simple text output for small projects and rich dashboards for large-scale enterprise projects.

### UI Scale Detection and Activation

```bash
# Determine optimal UI complexity level
get_optimal_ui_level() {
    local milestone_count=$(count_active_milestones)
    local concurrent_users=$(count_concurrent_users)
    local complexity_score=$(calculate_project_complexity)
    local current_backend=$(get_current_storage_backend)
    
    # Simple UI for small projects
    if [ "$milestone_count" -lt 10 ] && [ "$concurrent_users" -lt 3 ]; then
        echo "simple"
        return 0
    fi
    
    # Rich UI for medium projects
    if [ "$milestone_count" -lt 50 ] && [ "$concurrent_users" -lt 15 ]; then
        echo "rich"
        return 0
    fi
    
    # Dashboard UI for large projects
    if [ "$milestone_count" -ge 50 ] || [ "$concurrent_users" -ge 15 ]; then
        echo "dashboard"
        return 0
    fi
    
    # Default to simple
    echo "simple"
}

# Check if enhanced UI features should be activated
should_activate_enhanced_ui() {
    local ui_level=$(get_optimal_ui_level)
    local current_backend=$(get_current_storage_backend)
    
    # Enhanced UI requires hybrid or database backend
    if [ "$current_backend" = "file" ] && [ "$ui_level" != "simple" ]; then
        echo "false"  # File backend limits UI complexity
    elif [ "$ui_level" = "dashboard" ]; then
        echo "true"   # Always activate for dashboard level
    elif [ "$ui_level" = "rich" ]; then
        echo "true"   # Activate rich features
    else
        echo "false"  # Simple UI doesn't need enhancement
    fi
}

# Get current UI configuration
get_current_ui_config() {
    local config_file=".milestones/config/ui-config.yaml"
    
    if [ ! -f "$config_file" ]; then
        # Create default UI configuration
        cat > "$config_file" << EOF
ui:
  level: "auto"  # auto, simple, rich, dashboard
  features:
    progress_bars: true
    color_output: true
    interactive_menus: false
    web_dashboard: false
    real_time_updates: false
  
  thresholds:
    simple_to_rich:
      milestones: 10
      users: 3
    rich_to_dashboard:
      milestones: 50
      users: 15
  
  customization:
    theme: "default"  # default, minimal, enterprise
    timezone: "auto"
    date_format: "relative"  # relative, iso, local
    
  dashboard:
    enabled: false
    port: 8080
    auto_refresh: 30
    charts_enabled: true
EOF
    fi
    
    cat "$config_file"
}

# Update UI configuration based on scale
update_ui_configuration() {
    local optimal_level=$(get_optimal_ui_level)
    local config_file=".milestones/config/ui-config.yaml"
    local current_level=$(yq e '.ui.level' "$config_file" 2>/dev/null || echo "auto")
    
    # Only update if in auto mode
    if [ "$current_level" = "auto" ]; then
        # Update UI level
        yq e ".ui.level = \"$optimal_level\"" -i "$config_file"
        
        # Update feature flags based on level
        case "$optimal_level" in
            "simple")
                yq e '.ui.features.interactive_menus = false' -i "$config_file"
                yq e '.ui.features.web_dashboard = false' -i "$config_file"
                yq e '.ui.features.real_time_updates = false' -i "$config_file"
                ;;
            "rich")
                yq e '.ui.features.interactive_menus = true' -i "$config_file"
                yq e '.ui.features.web_dashboard = false' -i "$config_file"
                yq e '.ui.features.real_time_updates = true' -i "$config_file"
                ;;
            "dashboard")
                yq e '.ui.features.interactive_menus = true' -i "$config_file"
                yq e '.ui.features.web_dashboard = true' -i "$config_file"
                yq e '.ui.features.real_time_updates = true' -i "$config_file"
                yq e '.ui.dashboard.enabled = true' -i "$config_file"
                ;;
        esac
        
        echo "🎨 UI configuration updated to: $optimal_level"
    fi
}
```

### Progressive Dashboard Generation

```bash
# Generate milestone status display based on UI level
generate_milestone_status() {
    local milestone_id=$1
    local ui_level=$(get_optimal_ui_level)
    local config=$(get_current_ui_config)
    local color_enabled=$(echo "$config" | yq e '.ui.features.color_output' -)
    
    case "$ui_level" in
        "simple")
            generate_simple_status "$milestone_id" "$color_enabled"
            ;;
        "rich")
            generate_rich_status "$milestone_id" "$color_enabled"
            ;;
        "dashboard")
            generate_dashboard_status "$milestone_id" "$color_enabled"
            ;;
    esac
}

# Simple status for individual developers
generate_simple_status() {
    local milestone_id=$1
    local color_enabled=$2
    
    local milestone_data=$(read_milestone_record "$milestone_id")
    local title=$(echo "$milestone_data" | yq e '.title' -)
    local status=$(echo "$milestone_data" | yq e '.status' -)
    local progress=$(calculate_milestone_progress "$milestone_id")
    
    echo "Milestone: $title"
    echo "Status: $status"
    echo "Progress: $progress%"
    
    # Simple progress bar
    local bar_length=20
    local filled=$((progress * bar_length / 100))
    local empty=$((bar_length - filled))
    
    if [ "$color_enabled" = "true" ]; then
        printf "Progress: \033[32m"
        printf "%0.s█" $(seq 1 $filled)
        printf "\033[90m"
        printf "%0.s░" $(seq 1 $empty)
        printf "\033[0m %d%%\n" "$progress"
    else
        printf "Progress: "
        printf "%0.s#" $(seq 1 $filled)
        printf "%0.s-" $(seq 1 $empty)
        printf " %d%%\n" "$progress"
    fi
}

# Rich status for team projects
generate_rich_status() {
    local milestone_id=$1
    local color_enabled=$2
    
    local milestone_data=$(read_milestone_record "$milestone_id")
    local title=$(echo "$milestone_data" | yq e '.title' -)
    local status=$(echo "$milestone_data" | yq e '.status' -)
    local priority=$(echo "$milestone_data" | yq e '.priority' -)
    local progress=$(calculate_milestone_progress "$milestone_id")
    
    # Header with styling
    if [ "$color_enabled" = "true" ]; then
        echo -e "\033[1;36m=== MILESTONE STATUS ===\033[0m"
        echo -e "\033[1m$title\033[0m"
        
        # Status with color coding
        case "$status" in
            "completed") echo -e "Status: \033[32m✅ $status\033[0m" ;;
            "in_progress") echo -e "Status: \033[33m🔄 $status\033[0m" ;;
            "blocked") echo -e "Status: \033[31m🚫 $status\033[0m" ;;
            *) echo -e "Status: \033[37m$status\033[0m" ;;
        esac
        
        # Priority with color coding
        case "$priority" in
            "high") echo -e "Priority: \033[31m🔥 $priority\033[0m" ;;
            "medium") echo -e "Priority: \033[33m⚡ $priority\033[0m" ;;
            "low") echo -e "Priority: \033[32m📝 $priority\033[0m" ;;
        esac
    else
        echo "=== MILESTONE STATUS ==="
        echo "$title"
        echo "Status: $status"
        echo "Priority: $priority"
    fi
    
    # Enhanced progress bar
    generate_enhanced_progress_bar "$progress" "$color_enabled"
    
    # Task breakdown
    echo ""
    echo "TASK BREAKDOWN:"
    generate_task_summary "$milestone_id" "$color_enabled"
    
    # Timeline information
    echo ""
    echo "TIMELINE:"
    generate_timeline_summary "$milestone_id" "$color_enabled"
    
    # Kiro workflow status if enabled
    local kiro_tasks=$(echo "$milestone_data" | yq e '.tasks[] | select(.kiro_workflow.enabled == true) | .id' -)
    if [ -n "$kiro_tasks" ]; then
        echo ""
        echo "KIRO WORKFLOW STATUS:"
        for task_id in $kiro_tasks; do
            generate_kiro_task_status "$milestone_id" "$task_id" "$color_enabled"
        done
    fi
}

# Dashboard status for enterprise projects
generate_dashboard_status() {
    local milestone_id=$1
    local color_enabled=$2
    
    # Full dashboard with multiple sections
    generate_executive_summary "$milestone_id" "$color_enabled"
    echo ""
    generate_detailed_metrics "$milestone_id" "$color_enabled"
    echo ""
    generate_risk_assessment "$milestone_id" "$color_enabled"
    echo ""
    generate_resource_utilization "$milestone_id" "$color_enabled"
    echo ""
    generate_dependency_network "$milestone_id" "$color_enabled"
}

# Enhanced progress bar with multiple indicators
generate_enhanced_progress_bar() {
    local progress=$1
    local color_enabled=$2
    local bar_length=40
    
    # Calculate segments
    local filled=$((progress * bar_length / 100))
    local empty=$((bar_length - filled))
    
    # Progress bar with percentage ranges
    local low_threshold=30
    local med_threshold=70
    
    if [ "$color_enabled" = "true" ]; then
        printf "Progress: "
        
        # Color-coded progress based on completion
        if [ "$progress" -lt $low_threshold ]; then
            printf "\033[31m"  # Red for low progress
        elif [ "$progress" -lt $med_threshold ]; then
            printf "\033[33m"  # Yellow for medium progress
        else
            printf "\033[32m"  # Green for high progress
        fi
        
        # Generate bar
        printf "%0.s█" $(seq 1 $filled)
        printf "\033[90m"
        printf "%0.s░" $(seq 1 $empty)
        printf "\033[0m %d%%\n" "$progress"
        
        # Progress indicators
        printf "Indicators: "
        [ "$progress" -ge 25 ] && printf "\033[32m✓\033[0m Planning " || printf "\033[90m○\033[0m Planning "
        [ "$progress" -ge 50 ] && printf "\033[32m✓\033[0m Development " || printf "\033[90m○\033[0m Development "
        [ "$progress" -ge 75 ] && printf "\033[32m✓\033[0m Testing " || printf "\033[90m○\033[0m Testing "
        [ "$progress" -ge 100 ] && printf "\033[32m✓\033[0m Complete" || printf "\033[90m○\033[0m Complete"
        echo ""
    else
        printf "Progress: "
        printf "%0.s#" $(seq 1 $filled)
        printf "%0.s-" $(seq 1 $empty)
        printf " %d%%\n" "$progress"
    fi
}

# Task summary with status breakdown
generate_task_summary() {
    local milestone_id=$1
    local color_enabled=$2
    local milestone_data=$(read_milestone_record "$milestone_id")
    
    local total_tasks=$(echo "$milestone_data" | yq e '.tasks | length' -)
    local completed_tasks=$(echo "$milestone_data" | yq e '.tasks[] | select(.status == "completed") | .id' - | wc -l)
    local in_progress_tasks=$(echo "$milestone_data" | yq e '.tasks[] | select(.status == "in_progress") | .id' - | wc -l)
    local pending_tasks=$(echo "$milestone_data" | yq e '.tasks[] | select(.status == "pending") | .id' - | wc -l)
    
    if [ "$color_enabled" = "true" ]; then
        echo "├── Total Tasks: $total_tasks"
        echo "├── \033[32m✅ Completed: $completed_tasks\033[0m"
        echo "├── \033[33m🔄 In Progress: $in_progress_tasks\033[0m"
        echo "└── \033[37m⏳ Pending: $pending_tasks\033[0m"
    else
        echo "├── Total Tasks: $total_tasks"
        echo "├── Completed: $completed_tasks"
        echo "├── In Progress: $in_progress_tasks"
        echo "└── Pending: $pending_tasks"
    fi
}

# Timeline summary with estimates
generate_timeline_summary() {
    local milestone_id=$1
    local color_enabled=$2
    local milestone_data=$(read_milestone_record "$milestone_id")
    
    local estimated_start=$(echo "$milestone_data" | yq e '.timeline.estimated_start' -)
    local estimated_end=$(echo "$milestone_data" | yq e '.timeline.estimated_end' -)
    local estimated_hours=$(echo "$milestone_data" | yq e '.timeline.estimated_hours' -)
    
    # Calculate relative dates
    local start_relative=$(date_to_relative "$estimated_start")
    local end_relative=$(date_to_relative "$estimated_end")
    
    if [ "$color_enabled" = "true" ]; then
        echo "├── Start: \033[36m$start_relative\033[0m ($estimated_start)"
        echo "├── End: \033[36m$end_relative\033[0m ($estimated_end)"
        echo "└── Estimated: \033[35m${estimated_hours}h\033[0m"
    else
        echo "├── Start: $start_relative ($estimated_start)"
        echo "├── End: $end_relative ($estimated_end)"
        echo "└── Estimated: ${estimated_hours}h"
    fi
}

# Kiro workflow task status
generate_kiro_task_status() {
    local milestone_id=$1
    local task_id=$2
    local color_enabled=$3
    local milestone_data=$(read_milestone_record "$milestone_id")
    
    local task_title=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .title" -)
    local current_phase=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.current_phase" -)
    
    # Get phase statuses
    local design_status=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.design.status" -)
    local spec_status=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.spec.status" -)
    local task_status=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.task.status" -)
    local execute_status=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.execute.status" -)
    
    if [ "$color_enabled" = "true" ]; then
        echo "📋 $task_title (Current: \033[33m$current_phase\033[0m)"
        echo "   Phases: $(format_phase_status "design" "$design_status" "$color_enabled") → $(format_phase_status "spec" "$spec_status" "$color_enabled") → $(format_phase_status "task" "$task_status" "$color_enabled") → $(format_phase_status "execute" "$execute_status" "$color_enabled")"
    else
        echo "📋 $task_title (Current: $current_phase)"
        echo "   Phases: design:$design_status → spec:$spec_status → task:$task_status → execute:$execute_status"
    fi
}

# Format phase status with appropriate colors
format_phase_status() {
    local phase_name=$1
    local status=$2
    local color_enabled=$3
    
    if [ "$color_enabled" = "true" ]; then
        case "$status" in
            "completed"|"approved") echo "\033[32m✅ $phase_name\033[0m" ;;
            "in_progress") echo "\033[33m🔄 $phase_name\033[0m" ;;
            "waiting_approval") echo "\033[35m⏳ $phase_name\033[0m" ;;
            "blocked") echo "\033[31m🚫 $phase_name\033[0m" ;;
            *) echo "\033[90m⚪ $phase_name\033[0m" ;;
        esac
    else
        echo "$phase_name:$status"
    fi
}

# Enhanced kiro visualization for progressive UI
display_kiro_phase_progress() {
    local task_id=$1
    local milestone_data=$2
    local ui_level=$3
    
    local task_title=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .title" -)
    local current_phase=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.current_phase" -)
    
    if [ "$ui_level" = "dashboard" ]; then
        # Rich dashboard visualization
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║ Task: $task_title"
        echo "║ Current Phase: $current_phase"
        echo "╠══════════════════════════════════════════════════════════════╣"
        
        for phase in design spec task execute; do
            local phase_status=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.status" -)
            local phase_hours=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phase_hours.$phase" -)
            local deliverables=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.deliverables[]" - 2>/dev/null | wc -l)
            
            local phase_icon=""
            case "$phase" in
                "design") phase_icon="📐" ;;
                "spec") phase_icon="📋" ;;
                "task") phase_icon="📝" ;;
                "execute") phase_icon="🚀" ;;
            esac
            
            local status_icon=""
            case "$phase_status" in
                "completed"|"approved") status_icon="✅" ;;
                "in_progress") status_icon="🔄" ;;
                "waiting_approval") status_icon="⏳" ;;
                "blocked") status_icon="🚫" ;;
                *) status_icon="⏸️" ;;
            esac
            
            echo "║ $phase_icon $(printf "%-8s" "$phase" | tr '[:lower:]' '[:upper:]') $status_icon │ ${phase_hours}h │ $deliverables deliverables"
            
            # Show approval status if waiting
            if [ "$phase_status" = "waiting_approval" ]; then
                echo "║   └─ 🔐 Awaiting approval to proceed"
            fi
        done
        
        echo "╚══════════════════════════════════════════════════════════════╝"
    elif [ "$ui_level" = "rich" ]; then
        # Compact rich visualization
        echo "📌 $task_title"
        echo -n "   "
        for phase in design spec task execute; do
            local phase_status=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.status" -)
            echo -n "$(format_phase_status "$phase" "$phase_status" "true") "
            if [ "$phase" != "execute" ]; then
                echo -n "→ "
            fi
        done
        echo ""
    else
        # Simple visualization
        echo "$task_title: $(format_kiro_simple_status "$task_id" "$milestone_data")"
    fi
}

# Format simple kiro status
format_kiro_simple_status() {
    local task_id=$1
    local milestone_data=$2
    
    local current_phase=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.current_phase" -)
    local phase_status=$(echo "$milestone_data" | yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$current_phase.status" -)
    
    echo "$current_phase:$phase_status"
}
```

### Executive Dashboard Components

```bash
# Executive summary for enterprise dashboards
generate_executive_summary() {
    local milestone_id=$1
    local color_enabled=$2
    
    if [ "$color_enabled" = "true" ]; then
        echo -e "\033[1;44m                    EXECUTIVE DASHBOARD                    \033[0m"
    else
        echo "==================== EXECUTIVE DASHBOARD ===================="
    fi
    
    local milestone_data=$(read_milestone_record "$milestone_id")
    local title=$(echo "$milestone_data" | yq e '.title' -)
    local progress=$(calculate_milestone_progress "$milestone_id")
    local status=$(echo "$milestone_data" | yq e '.status' -)
    
    # Key metrics summary
    echo ""
    echo "PROJECT: $title"
    echo "OVERALL PROGRESS: $progress%"
    echo "STATUS: $status"
    
    # Key performance indicators
    local estimated_hours=$(echo "$milestone_data" | yq e '.timeline.estimated_hours' -)
    local actual_hours=$(calculate_actual_hours "$milestone_id")
    local efficiency_ratio=$(echo "scale=2; $actual_hours / $estimated_hours" | bc -l 2>/dev/null || echo "N/A")
    
    echo ""
    echo "KEY METRICS:"
    echo "├── Estimated Effort: ${estimated_hours}h"
    echo "├── Actual Effort: ${actual_hours}h"
    echo "├── Efficiency Ratio: $efficiency_ratio"
    echo "└── On-Track Status: $(calculate_on_track_status "$milestone_id")"
}

# Detailed metrics for enterprise monitoring
generate_detailed_metrics() {
    local milestone_id=$1
    local color_enabled=$2
    
    echo "DETAILED METRICS:"
    
    # Resource utilization
    local milestone_data=$(read_milestone_record "$milestone_id")
    local team_members=$(echo "$milestone_data" | yq e '.resources.team_members[]' - | wc -l)
    local active_tasks=$(echo "$milestone_data" | yq e '.tasks[] | select(.status == "in_progress") | .id' - | wc -l)
    
    echo "├── Team Size: $team_members members"
    echo "├── Active Tasks: $active_tasks"
    echo "├── Completion Rate: $(calculate_completion_rate "$milestone_id")%"
    echo "└── Velocity: $(calculate_velocity "$milestone_id") tasks/week"
    
    # Quality metrics
    echo ""
    echo "QUALITY INDICATORS:"
    local kiro_tasks=$(echo "$milestone_data" | yq e '.tasks[] | select(.kiro_workflow.enabled == true) | .id' - | wc -l)
    local total_tasks=$(echo "$milestone_data" | yq e '.tasks | length' -)
    local quality_score=$(echo "scale=0; $kiro_tasks * 100 / $total_tasks" | bc -l 2>/dev/null || echo "0")
    
    echo "├── Kiro Workflow Coverage: $quality_score%"
    echo "├── Approval Gates Passed: $(count_passed_approvals "$milestone_id")"
    echo "└── Quality Score: $(calculate_quality_score "$milestone_id")/100"
}

# Risk assessment dashboard
generate_risk_assessment() {
    local milestone_id=$1
    local color_enabled=$2
    
    echo "RISK ASSESSMENT:"
    
    local milestone_data=$(read_milestone_record "$milestone_id")
    local high_risks=$(echo "$milestone_data" | yq e '.risks[] | select(.impact == "high") | .description' - | wc -l)
    local medium_risks=$(echo "$milestone_data" | yq e '.risks[] | select(.impact == "medium") | .description' - | wc -l)
    local low_risks=$(echo "$milestone_data" | yq e '.risks[] | select(.impact == "low") | .description' - | wc -l)
    
    if [ "$color_enabled" = "true" ]; then
        echo "├── \033[31m🔴 High Risk: $high_risks items\033[0m"
        echo "├── \033[33m🟡 Medium Risk: $medium_risks items\033[0m"
        echo "└── \033[32m🟢 Low Risk: $low_risks items\033[0m"
    else
        echo "├── High Risk: $high_risks items"
        echo "├── Medium Risk: $medium_risks items"
        echo "└── Low Risk: $low_risks items"
    fi
    
    # Show top risks
    if [ "$high_risks" -gt 0 ]; then
        echo ""
        echo "TOP RISKS:"
        echo "$milestone_data" | yq e '.risks[] | select(.impact == "high") | "├── " + .description + " (Probability: " + (.probability * 100 | floor | tostring) + "%)"' -
    fi
}

# Resource utilization tracking
generate_resource_utilization() {
    local milestone_id=$1
    local color_enabled=$2
    
    echo "RESOURCE UTILIZATION:"
    
    local milestone_data=$(read_milestone_record "$milestone_id")
    
    # Team member allocation
    echo "TEAM ALLOCATION:"
    local team_members=$(echo "$milestone_data" | yq e '.resources.team_members[]' -)
    for member in $team_members; do
        local assigned_tasks=$(echo "$milestone_data" | yq e ".tasks[] | select(.assigned_to == \"$member\") | .id" - | wc -l)
        local completed_tasks=$(echo "$milestone_data" | yq e ".tasks[] | select(.assigned_to == \"$member\" and .status == \"completed\") | .id" - | wc -l)
        local utilization=$(echo "scale=0; $completed_tasks * 100 / $assigned_tasks" | bc -l 2>/dev/null || echo "0")
        
        echo "├── $member: $assigned_tasks tasks ($utilization% complete)"
    done
    
    # Skill distribution
    echo ""
    echo "SKILL REQUIREMENTS:"
    local skills=$(echo "$milestone_data" | yq e '.resources.skills_required[]' -)
    for skill in $skills; do
        local skill_demand=$(echo "$milestone_data" | yq e ".tasks[] | select(.skills_required[]? == \"$skill\") | .id" - | wc -l)
        echo "├── $skill: $skill_demand tasks"
    done
}

# Dependency network visualization
generate_dependency_network() {
    local milestone_id=$1
    local color_enabled=$2
    
    echo "DEPENDENCY NETWORK:"
    
    local milestone_data=$(read_milestone_record "$milestone_id")
    
    # External dependencies
    local external_deps=$(echo "$milestone_data" | yq e '.dependencies.external[]' - 2>/dev/null)
    if [ -n "$external_deps" ]; then
        echo "EXTERNAL DEPENDENCIES:"
        for dep in $external_deps; do
            echo "├── $dep"
        done
        echo ""
    fi
    
    # Internal task dependencies
    echo "TASK DEPENDENCIES:"
    echo "$milestone_data" | yq e '.tasks[] | select(.dependencies | length > 0) | "├── " + .title + " depends on: " + (.dependencies | join(", "))' -
    
    # Critical path
    echo ""
    echo "CRITICAL PATH:"
    local critical_tasks=$(identify_critical_path "$milestone_id")
    echo "├── Path: $critical_tasks"
    echo "└── Duration: $(calculate_critical_path_duration "$milestone_id") hours"
}
```

### Progressive Web Dashboard

```bash
# Web dashboard activation based on scale
activate_web_dashboard() {
    local ui_level=$(get_optimal_ui_level)
    local config=$(get_current_ui_config)
    local dashboard_enabled=$(echo "$config" | yq e '.ui.dashboard.enabled' -)
    
    if [ "$ui_level" = "dashboard" ] && [ "$dashboard_enabled" = "true" ]; then
        echo "🌐 Activating web dashboard for enterprise-scale project..."
        start_milestone_web_server
    fi
}

# Start web server for dashboard
start_milestone_web_server() {
    local config=$(get_current_ui_config)
    local port=$(echo "$config" | yq e '.ui.dashboard.port' -)
    local auto_refresh=$(echo "$config" | yq e '.ui.dashboard.auto_refresh' -)
    
    # Create simple web dashboard
    local dashboard_dir=".milestones/web-dashboard"
    mkdir -p "$dashboard_dir"
    
    # Generate HTML dashboard
    generate_html_dashboard > "$dashboard_dir/index.html"
    
    # Start simple HTTP server (if Python available)
    if command -v python3 >/dev/null 2>&1; then
        echo "🚀 Starting web dashboard on http://localhost:$port"
        cd "$dashboard_dir"
        python3 -m http.server "$port" >/dev/null 2>&1 &
        echo $! > ".milestones/web-dashboard.pid"
        cd - >/dev/null
        
        echo "📊 Dashboard URL: http://localhost:$port"
        echo "🔄 Auto-refresh: ${auto_refresh}s"
    else
        echo "⚠️ Python3 not available for web dashboard. Install Python3 to enable web interface."
    fi
}

# Generate HTML dashboard
generate_html_dashboard() {
    cat << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Milestone Dashboard</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .dashboard { max-width: 1200px; margin: 0 auto; }
        .header { background: #2563eb; color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .metrics { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 20px; }
        .metric-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .metric-title { font-size: 14px; color: #666; margin-bottom: 5px; }
        .metric-value { font-size: 32px; font-weight: bold; color: #2563eb; }
        .progress-bar { width: 100%; height: 20px; background: #e5e7eb; border-radius: 10px; overflow: hidden; }
        .progress-fill { height: 100%; background: linear-gradient(90deg, #10b981, #3b82f6); transition: width 0.3s; }
        .milestone-list { background: white; border-radius: 8px; padding: 20px; }
        .milestone-item { border-bottom: 1px solid #e5e7eb; padding: 15px 0; }
        .milestone-item:last-child { border-bottom: none; }
        .status-badge { padding: 4px 8px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .status-completed { background: #dcfce7; color: #166534; }
        .status-in-progress { background: #fef3c7; color: #92400e; }
        .status-pending { background: #f1f5f9; color: #475569; }
    </style>
    <script>
        function updateDashboard() {
            // Auto-refresh functionality
            setTimeout(() => location.reload(), 30000);
        }
        document.addEventListener('DOMContentLoaded', updateDashboard);
    </script>
</head>
<body>
    <div class="dashboard">
        <div class="header">
            <h1>📊 Milestone Dashboard</h1>
            <p>Real-time project tracking and analytics</p>
        </div>
        
        <div class="metrics">
            <div class="metric-card">
                <div class="metric-title">Total Milestones</div>
                <div class="metric-value" id="total-milestones">-</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">Completion Rate</div>
                <div class="metric-value" id="completion-rate">-%</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">Active Team Members</div>
                <div class="metric-value" id="team-size">-</div>
            </div>
            <div class="metric-card">
                <div class="metric-title">Overall Progress</div>
                <div class="metric-value" id="overall-progress">-%</div>
                <div class="progress-bar">
                    <div class="progress-fill" id="progress-fill" style="width: 0%"></div>
                </div>
            </div>
        </div>
        
        <div class="milestone-list">
            <h2>📋 Active Milestones</h2>
            <div id="milestone-items">
                <div class="milestone-item">
                    <strong>Loading milestones...</strong>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // Dashboard data loading would be implemented here
        // This would call backend APIs to get real milestone data
        console.log('Dashboard loaded - implement data loading');
    </script>
</body>
</html>
EOF
}

# Stop web dashboard
stop_web_dashboard() {
    if [ -f ".milestones/web-dashboard.pid" ]; then
        local pid=$(cat ".milestones/web-dashboard.pid")
        kill "$pid" 2>/dev/null
        rm -f ".milestones/web-dashboard.pid"
        echo "🛑 Web dashboard stopped"
    fi
}
```

### Utility Functions

```bash
# Convert date to relative format
date_to_relative() {
    local target_date=$1
    local current_date=$(date +%Y-%m-%d)
    local target_epoch=$(date -d "$target_date" +%s 2>/dev/null || echo "0")
    local current_epoch=$(date -d "$current_date" +%s)
    local diff_days=$(( (target_epoch - current_epoch) / 86400 ))
    
    if [ "$diff_days" -eq 0 ]; then
        echo "Today"
    elif [ "$diff_days" -eq 1 ]; then
        echo "Tomorrow"
    elif [ "$diff_days" -eq -1 ]; then
        echo "Yesterday"
    elif [ "$diff_days" -gt 0 ]; then
        echo "In $diff_days days"
    else
        echo "$((- diff_days)) days ago"
    fi
}

# Calculate various metrics
calculate_actual_hours() {
    local milestone_id=$1
    # This would integrate with time tracking if available
    echo "0"  # Placeholder
}

calculate_on_track_status() {
    local milestone_id=$1
    local progress=$(calculate_milestone_progress "$milestone_id")
    
    # Simple on-track calculation based on time vs progress
    if [ "$progress" -ge 80 ]; then
        echo "On Track"
    elif [ "$progress" -ge 50 ]; then
        echo "At Risk"
    else
        echo "Behind Schedule"
    fi
}

calculate_completion_rate() {
    local milestone_id=$1
    local milestone_data=$(read_milestone_record "$milestone_id")
    local total_tasks=$(echo "$milestone_data" | yq e '.tasks | length' -)
    local completed_tasks=$(echo "$milestone_data" | yq e '.tasks[] | select(.status == "completed") | .id' - | wc -l)
    
    if [ "$total_tasks" -gt 0 ]; then
        echo "scale=0; $completed_tasks * 100 / $total_tasks" | bc -l
    else
        echo "0"
    fi
}

calculate_velocity() {
    local milestone_id=$1
    # Placeholder for velocity calculation
    echo "2.5"
}

count_passed_approvals() {
    local milestone_id=$1
    # Placeholder for approval counting
    echo "3"
}

calculate_quality_score() {
    local milestone_id=$1
    # Placeholder for quality score calculation
    echo "85"
}

identify_critical_path() {
    local milestone_id=$1
    # Placeholder for critical path identification
    echo "Task A → Task B → Task C"
}

calculate_critical_path_duration() {
    local milestone_id=$1
    # Placeholder for critical path duration
    echo "45"
}

# Initialize progressive UI system
initialize_progressive_ui() {
    echo "🎨 Initializing progressive UI system..."
    
    # Create UI configuration
    get_current_ui_config >/dev/null
    
    # Update UI based on current scale
    update_ui_configuration
    
    # Activate web dashboard if needed
    if [ "$(should_activate_enhanced_ui)" = "true" ]; then
        activate_web_dashboard
    fi
    
    echo "✅ Progressive UI system initialized"
}

# Clean up UI resources
cleanup_progressive_ui() {
    stop_web_dashboard
    
    # Clean up temporary files
    rm -rf ".milestones/web-dashboard" 2>/dev/null
}
```

This progressive visualization system automatically adapts the UI complexity based on project scale, providing simple text for individual developers and rich enterprise dashboards for large teams, seamlessly integrating with the hybrid storage architecture.