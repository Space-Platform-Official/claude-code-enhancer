# Simple Progress Tracking for Quick-Start Templates

## Simplified Progress System

Quick-start templates use streamlined progress tracking focused on motivation and clarity.

### Core Principles

- **Visual clarity**: Easy to understand progress indicators
- **Motivation-focused**: Celebrate small wins and maintain momentum
- **No complexity overload**: Hide detailed metrics unless requested
- **Daily focus**: Clear daily goals to maintain productivity

### Simple Progress Schema

```yaml
# Minimal progress tracking structure
simple_progress:
  overall:
    percentage: 0-100
    current_phase: "foundation|core|polish|launch"
    days_elapsed: 0
    days_remaining: 7
    
  phases:
    foundation: {percentage: 0, status: "pending|active|complete"}
    core: {percentage: 0, status: "pending|active|complete"}
    polish: {percentage: 0, status: "pending|active|complete"}
    launch: {percentage: 0, status: "pending|active|complete"}
    
  daily:
    current_day: 1
    today_focus: "Clear daily goal"
    today_tasks: ["task1", "task2", "task3"]
    completed_today: 0
    
  motivation:
    streak_days: 0
    total_completed_tasks: 0
    celebration_ready: false
```

### Progress Display Functions

```bash
# Simple progress display
show_simple_progress() {
    local milestone_path="$1"
    
    # Load progress data
    local progress_file="$milestone_path/progress.yaml"
    local overall_percentage=$(yaml_get "$progress_file" "progress.overall_percentage")
    local current_phase=$(yaml_get "$progress_file" "progress.current_phase")
    local day=$(yaml_get "$progress_file" "progress.daily.current_day")
    local total_days=$(yaml_get "$progress_file" "milestone.duration_days")
    
    # Create visual progress bar
    local progress_bar=$(create_progress_bar "$overall_percentage")
    
    echo "=== MILESTONE PROGRESS ==="
    echo "$(yaml_get "$progress_file" "milestone.title")"
    echo "Progress: $progress_bar $overall_percentage% (Day $day of $total_days)"
    echo ""
    
    # Show phase status
    show_phase_progress "$progress_file"
    echo ""
    
    # Show today's focus
    show_daily_focus "$progress_file"
}

# Visual progress bar creation
create_progress_bar() {
    local percentage="$1"
    local bar_length=10
    local filled=$((percentage * bar_length / 100))
    local empty=$((bar_length - filled))
    
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done
    
    echo "[$bar]"
}

# Phase progress display
show_phase_progress() {
    local progress_file="$1"
    
    echo "PHASE STATUS:"
    
    # Foundation
    local foundation_status=$(yaml_get "$progress_file" "progress.phases.foundation.status")
    local foundation_icon=$(get_status_icon "$foundation_status")
    echo "$foundation_icon Foundation    ($(get_phase_description "foundation"))"
    
    # Core Features
    local core_status=$(yaml_get "$progress_file" "progress.phases.core.status")
    local core_icon=$(get_status_icon "$core_status")
    echo "$core_icon Core Features ($(get_phase_description "core"))"
    
    # Polish
    local polish_status=$(yaml_get "$progress_file" "progress.phases.polish.status")
    local polish_icon=$(get_status_icon "$polish_status")
    echo "$polish_icon Polish        ($(get_phase_description "polish"))"
    
    # Launch
    local launch_status=$(yaml_get "$progress_file" "progress.phases.launch.status")
    local launch_icon=$(get_status_icon "$launch_status")
    echo "$launch_icon Launch        ($(get_phase_description "launch"))"
}

# Status icons for phases
get_status_icon() {
    local status="$1"
    case "$status" in
        "complete") echo "✅" ;;
        "active")   echo "🔄" ;;
        "pending")  echo "⏳" ;;
        *)          echo "⏳" ;;
    esac
}

# Phase descriptions
get_phase_description() {
    local phase="$1"
    case "$phase" in
        "foundation") echo "Project setup and structure" ;;
        "core")       echo "Main functionality implementation" ;;
        "polish")     echo "Testing and refinement" ;;
        "launch")     echo "Deployment and documentation" ;;
        *)            echo "Phase in progress" ;;
    esac
}

# Daily focus display
show_daily_focus() {
    local progress_file="$1"
    
    local today_focus=$(yaml_get "$progress_file" "progress.daily.today_focus")
    local completed_today=$(yaml_get "$progress_file" "progress.daily.completed_today")
    local total_tasks=$(yaml_get "$progress_file" "progress.daily.total_tasks_today")
    
    echo "TODAY'S FOCUS: $today_focus"
    echo "Tasks Today: $completed_today/$total_tasks completed"
    
    # Show next steps
    show_next_steps "$progress_file"
}

# Next steps guidance
show_next_steps() {
    local progress_file="$1"
    local current_phase=$(yaml_get "$progress_file" "progress.current_phase")
    
    case "$current_phase" in
        "foundation")
            echo "Next Up: Set up your development environment"
            ;;
        "core")
            echo "Next Up: Implement your main feature"
            ;;
        "polish")
            echo "Next Up: Test and refine your work"
            ;;
        "launch")
            echo "Next Up: Deploy and share your project"
            ;;
    esac
}
```

### Progress Update Functions

```bash
# Update progress when task is completed
update_task_progress() {
    local milestone_path="$1"
    local task_name="$2"
    local progress_file="$milestone_path/progress.yaml"
    
    # Mark task as complete
    yaml_set "$progress_file" "progress.tasks.$task_name.status" "complete"
    yaml_set "$progress_file" "progress.tasks.$task_name.completed_at" "$(date -Iseconds)"
    
    # Update daily progress
    local completed_today=$(yaml_get "$progress_file" "progress.daily.completed_today")
    yaml_set "$progress_file" "progress.daily.completed_today" $((completed_today + 1))
    
    # Update overall progress
    recalculate_overall_progress "$progress_file"
    
    # Check for celebrations
    check_celebration_triggers "$progress_file"
    
    echo "✅ Task completed: $task_name"
}

# Recalculate overall progress
recalculate_overall_progress() {
    local progress_file="$1"
    
    # Count completed tasks
    local total_tasks=$(yaml_count "$progress_file" "progress.tasks")
    local completed_tasks=$(yaml_count_where "$progress_file" "progress.tasks" "status" "complete")
    
    # Calculate percentage
    local percentage=0
    if [ "$total_tasks" -gt 0 ]; then
        percentage=$((completed_tasks * 100 / total_tasks))
    fi
    
    # Update progress
    yaml_set "$progress_file" "progress.overall_percentage" "$percentage"
    
    # Update phase status
    update_phase_status "$progress_file"
}

# Update phase status based on progress
update_phase_status() {
    local progress_file="$1"
    local overall_percentage=$(yaml_get "$progress_file" "progress.overall_percentage")
    
    # Update phase statuses based on percentage
    if [ "$overall_percentage" -ge 25 ]; then
        yaml_set "$progress_file" "progress.phases.foundation.status" "complete"
    fi
    if [ "$overall_percentage" -ge 75 ]; then
        yaml_set "$progress_file" "progress.phases.core.status" "complete"
    fi
    if [ "$overall_percentage" -ge 90 ]; then
        yaml_set "$progress_file" "progress.phases.polish.status" "complete"
    fi
    if [ "$overall_percentage" -ge 100 ]; then
        yaml_set "$progress_file" "progress.phases.launch.status" "complete"
    fi
    
    # Set current active phase
    if [ "$overall_percentage" -lt 25 ]; then
        yaml_set "$progress_file" "progress.current_phase" "foundation"
    elif [ "$overall_percentage" -lt 75 ]; then
        yaml_set "$progress_file" "progress.current_phase" "core"
    elif [ "$overall_percentage" -lt 90 ]; then
        yaml_set "$progress_file" "progress.current_phase" "polish"
    elif [ "$overall_percentage" -lt 100 ]; then
        yaml_set "$progress_file" "progress.current_phase" "launch"
    else
        yaml_set "$progress_file" "progress.current_phase" "complete"
    fi
}
```

### Celebration and Motivation

```bash
# Check for celebration triggers
check_celebration_triggers() {
    local progress_file="$1"
    local overall_percentage=$(yaml_get "$progress_file" "progress.overall_percentage")
    
    # Celebrate phase completions
    case "$overall_percentage" in
        25) celebrate_phase_completion "foundation" ;;
        50) celebrate_phase_completion "core" ;;
        75) celebrate_phase_completion "polish" ;;
        100) celebrate_milestone_completion ;;
    esac
    
    # Daily streak celebration
    check_daily_streak "$progress_file"
}

# Celebrate phase completion
celebrate_phase_completion() {
    local phase="$1"
    
    echo ""
    echo "🎉 PHASE COMPLETE! 🎉"
    echo ""
    case "$phase" in
        "foundation")
            echo "Great job setting up your project foundation!"
            echo "You're ready to build the core features."
            ;;
        "core")
            echo "Awesome! Your core functionality is working!"
            echo "Time to polish and perfect your work."
            ;;
        "polish")
            echo "Excellent! Your project is looking great!"
            echo "Ready for the final launch phase."
            ;;
    esac
    echo ""
}

# Celebrate milestone completion
celebrate_milestone_completion() {
    echo ""
    echo "🎉🎉🎉 MILESTONE COMPLETE! 🎉🎉🎉"
    echo ""
    echo "Congratulations! You've successfully completed your milestone!"
    echo ""
    
    # Show upgrade options
    show_upgrade_options
}

# Show upgrade options after completion
show_upgrade_options() {
    echo "🌟 WHAT'S NEXT?"
    echo "  a) Start another quick-start milestone"
    echo "  b) Try advanced milestone features"
    echo "  c) Learn about team collaboration"
    echo ""
    echo "Your choice: _"
}

# Daily streak tracking
check_daily_streak() {
    local progress_file="$1"
    local completed_today=$(yaml_get "$progress_file" "progress.daily.completed_today")
    local streak_days=$(yaml_get "$progress_file" "progress.motivation.streak_days")
    
    if [ "$completed_today" -gt 0 ]; then
        # Update streak
        yaml_set "$progress_file" "progress.motivation.streak_days" $((streak_days + 1))
        
        # Celebrate streaks
        if [ $((streak_days + 1)) -eq 3 ]; then
            echo "🔥 3-day streak! You're building great momentum!"
        elif [ $((streak_days + 1)) -eq 7 ]; then
            echo "🔥🔥 7-day streak! You're unstoppable!"
        fi
    fi
}
```

### Daily Focus Management

```bash
# Set daily focus and tasks
set_daily_focus() {
    local milestone_path="$1"
    local focus_description="$2"
    local progress_file="$milestone_path/progress.yaml"
    
    # Update daily focus
    yaml_set "$progress_file" "progress.daily.today_focus" "$focus_description"
    yaml_set "$progress_file" "progress.daily.date" "$(date +%Y-%m-%d)"
    
    # Reset daily counters
    yaml_set "$progress_file" "progress.daily.completed_today" "0"
    
    # Increment day counter
    local current_day=$(yaml_get "$progress_file" "progress.daily.current_day")
    yaml_set "$progress_file" "progress.daily.current_day" $((current_day + 1))
    
    echo "🎯 Today's focus set: $focus_description"
}

# Get daily recommendations
get_daily_recommendations() {
    local milestone_path="$1"
    local progress_file="$milestone_path/progress.yaml"
    local current_phase=$(yaml_get "$progress_file" "progress.current_phase")
    local overall_percentage=$(yaml_get "$progress_file" "progress.overall_percentage")
    
    case "$current_phase" in
        "foundation")
            echo "🏗️ Focus on setting up your project structure"
            echo "⏰ Estimated time: 2-3 hours"
            echo "🎯 Goal: Get a working development environment"
            ;;
        "core")
            echo "⚙️ Focus on implementing your main features"
            echo "⏰ Estimated time: 4-6 hours"
            echo "🎯 Goal: Core functionality working end-to-end"
            ;;
        "polish")
            echo "✨ Focus on testing and improving your work"
            echo "⏰ Estimated time: 2-3 hours"
            echo "🎯 Goal: Professional quality and reliability"
            ;;
        "launch")
            echo "🚀 Focus on deployment and documentation"
            echo "⏰ Estimated time: 1-2 hours"
            echo "🎯 Goal: Live project with documentation"
            ;;
    esac
}
```

This simple progress tracking system maintains user motivation through clear visual feedback, celebrates achievements, and provides daily focus without overwhelming complexity.