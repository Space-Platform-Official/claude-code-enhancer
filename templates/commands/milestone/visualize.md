---
allowed-tools: all
description: Visualize kiro workflow phases, deliverables, and progress with rich interactive dashboards
---

# 📊 Kiro Workflow Visualization Command

**Comprehensive visualization of milestone tasks with kiro workflow standard tracking**

## Command Usage

```bash
/milestone/visualize [milestone_id] [task_id] [mode]
```

### Parameters
- `milestone_id`: The milestone to visualize (required)
- `task_id`: Specific task ID or "all" for all tasks (optional, default: "all")
- `mode`: Visualization mode - simple|rich|dashboard|web (optional, default: "rich")

## Core Visualization Logic

```bash
# Source required components
source "templates/commands/milestone/_shared/kiro-native.md"
source "templates/commands/milestone/_shared/kiro-visualizer.md"
source "templates/commands/milestone/_shared/state.md"
source "templates/commands/milestone/_shared/utils.md"

# Parse arguments
MILESTONE_ID="${1:-$(get_current_milestone)}"
TASK_ID="${2:-all}"
VIZ_MODE="${3:-rich}"

# Validate milestone exists
if [ -z "$MILESTONE_ID" ]; then
    echo "❌ ERROR: No milestone specified and no active milestone found"
    echo "💡 Usage: /milestone/visualize <milestone_id> [task_id] [mode]"
    echo ""
    echo "Available milestones:"
    list_all_milestones
    exit 1
fi

# Check if milestone exists
MILESTONE_FILE=".milestones/active/$MILESTONE_ID.yaml"
if [ ! -f "$MILESTONE_FILE" ]; then
    echo "❌ ERROR: Milestone '$MILESTONE_ID' not found"
    echo ""
    echo "Available milestones:"
    list_all_milestones
    exit 1
fi

# Main visualization execution
echo "🔍 Loading milestone data..."

case "$VIZ_MODE" in
    "simple")
        echo "📊 Simple Kiro Visualization"
        echo "════════════════════════════════════════════"
        if [ "$TASK_ID" = "all" ]; then
            # Show all tasks in simple mode
            TASK_IDS=$(yq e '.tasks[].id' "$MILESTONE_FILE")
            while IFS= read -r tid; do
                echo ""
                visualize_kiro_simple "$MILESTONE_ID" "$tid"
            done <<< "$TASK_IDS"
        else
            visualize_kiro_simple "$MILESTONE_ID" "$TASK_ID"
        fi
        ;;
        
    "rich")
        if [ "$TASK_ID" = "all" ]; then
            # Show milestone dashboard with all tasks
            visualize_kiro_dashboard "$MILESTONE_ID" "all"
        else
            # Show specific task in rich mode
            visualize_kiro_rich "$MILESTONE_ID" "$TASK_ID"
        fi
        ;;
        
    "dashboard")
        # Full dashboard view
        visualize_kiro_dashboard "$MILESTONE_ID" "$TASK_ID"
        ;;
        
    "web")
        # Generate and open web dashboard
        echo "🌐 Generating interactive web dashboard..."
        generate_kiro_web_dashboard "$MILESTONE_ID" "$TASK_ID"
        
        # Offer to start web server
        echo ""
        echo "📊 Web dashboard generated successfully!"
        echo ""
        echo "Options to view:"
        echo "1. Open directly: file://$(pwd)/.milestones/web-dashboard/index.html"
        echo "2. Start local server (recommended for auto-refresh):"
        echo "   cd .milestones/web-dashboard && python3 -m http.server 8080"
        echo "   Then open: http://localhost:8080"
        ;;
        
    *)
        echo "❌ ERROR: Unknown visualization mode: $VIZ_MODE"
        echo "💡 Valid modes: simple, rich, dashboard, web"
        exit 1
        ;;
esac

# Show additional commands based on current state
echo ""
echo "────────────────────────────────────────────────────────────────────"
show_contextual_commands "$MILESTONE_ID" "$TASK_ID"
```

## Helper Functions

```bash
# Get current active milestone
get_current_milestone() {
    # Check for milestone in current session
    if [ -f ".milestones/config/current-milestone.txt" ]; then
        cat ".milestones/config/current-milestone.txt"
        return
    fi
    
    # Find most recently updated milestone
    local latest_milestone=$(ls -t .milestones/active/*.yaml 2>/dev/null | head -1 | xargs basename 2>/dev/null | sed 's/.yaml$//')
    echo "$latest_milestone"
}

# List all available milestones
list_all_milestones() {
    echo "Active milestones:"
    for milestone_file in .milestones/active/*.yaml; do
        if [ -f "$milestone_file" ]; then
            local milestone_id=$(basename "$milestone_file" .yaml)
            local title=$(yq e '.title' "$milestone_file")
            local status=$(yq e '.status' "$milestone_file")
            local progress=$(yq e '.progress.percentage // 0' "$milestone_file")
            echo "  • $milestone_id: $title [$status, $progress%]"
        fi
    done
    
    if [ -d ".milestones/completed" ]; then
        echo ""
        echo "Completed milestones:"
        for milestone_file in .milestones/completed/*.yaml; do
            if [ -f "$milestone_file" ]; then
                local milestone_id=$(basename "$milestone_file" .yaml)
                local title=$(yq e '.title' "$milestone_file")
                echo "  • $milestone_id: $title [completed]"
            fi
        done
    fi
}

# Show contextual commands based on current state
show_contextual_commands() {
    local milestone_id=$1
    local task_id=$2
    
    echo "📝 Available Commands:"
    echo ""
    
    if [ "$task_id" != "all" ]; then
        # Get task's current phase and status
        local current_phase=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.current_phase" "$MILESTONE_FILE")
        local phase_status=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$current_phase.status" "$MILESTONE_FILE")
        
        case "$phase_status" in
            "pending")
                echo "  ▶️  Start phase:     /milestone/start $milestone_id $task_id $current_phase"
                ;;
            "in_progress")
                echo "  ✅ Complete phase:  /milestone/complete $milestone_id $task_id $current_phase"
                ;;
            "waiting_approval")
                echo "  🔐 Approve phase:   /milestone/approve $milestone_id $task_id $current_phase"
                ;;
            "completed")
                local approval_required=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$current_phase.approval_required" "$MILESTONE_FILE")
                if [ "$approval_required" = "true" ]; then
                    echo "  🔐 Approve phase:   /milestone/approve $milestone_id $task_id $current_phase"
                else
                    local next_phase=$(get_next_phase "$current_phase")
                    if [ -n "$next_phase" ]; then
                        echo "  ▶️  Start next:      /milestone/start $milestone_id $task_id $next_phase"
                    fi
                fi
                ;;
        esac
        
        echo "  📊 View all tasks:  /milestone/visualize $milestone_id all"
        echo "  🌐 Web dashboard:   /milestone/visualize $milestone_id all web"
    else
        echo "  📊 Focus on task:   /milestone/visualize $milestone_id <task_id>"
        echo "  🌐 Web dashboard:   /milestone/visualize $milestone_id all web"
        echo "  ➕ Create task:     /milestone/task $milestone_id \"Task Title\""
    fi
    
    echo ""
    echo "  ℹ️  Milestone info:  /milestone/status $milestone_id"
    echo "  📈 Progress update: /milestone/update $milestone_id"
}

# Get next phase
get_next_phase() {
    case "$1" in
        "design") echo "spec" ;;
        "spec") echo "task" ;;
        "task") echo "execute" ;;
        "execute") echo "" ;;
    esac
}
```

## Interactive Features

```bash
# Watch mode for continuous updates
if [ "${WATCH_MODE:-false}" = "true" ]; then
    echo "👀 Watch mode enabled - refreshing every 5 seconds"
    echo "Press Ctrl+C to exit"
    
    while true; do
        clear
        /milestone/visualize "$MILESTONE_ID" "$TASK_ID" "$VIZ_MODE"
        sleep 5
    done
fi

# Export visualization to file
if [ -n "${EXPORT_FILE:-}" ]; then
    echo "📄 Exporting visualization to: $EXPORT_FILE"
    
    case "${EXPORT_FORMAT:-txt}" in
        "html")
            generate_kiro_web_dashboard "$MILESTONE_ID" "$TASK_ID"
            cp .milestones/web-dashboard/index.html "$EXPORT_FILE"
            ;;
        "json")
            yq e -o=json '.' "$MILESTONE_FILE" > "$EXPORT_FILE"
            ;;
        *)
            /milestone/visualize "$MILESTONE_ID" "$TASK_ID" "$VIZ_MODE" > "$EXPORT_FILE"
            ;;
    esac
    
    echo "✅ Export complete: $EXPORT_FILE"
fi
```

## Examples

### View all tasks in a milestone
```bash
/milestone/visualize my-project all
```

### Focus on specific task with rich visualization
```bash
/milestone/visualize my-project task-001 rich
```

### Generate interactive web dashboard
```bash
/milestone/visualize my-project all web
```

### Simple text view for terminal
```bash
/milestone/visualize my-project task-001 simple
```

### Watch mode for live updates
```bash
WATCH_MODE=true /milestone/visualize my-project all dashboard
```

### Export visualization
```bash
EXPORT_FILE=report.html EXPORT_FORMAT=html /milestone/visualize my-project all
```

## Visualization Features

### 📊 Rich Mode Features
- Phase timeline with progress indicators
- Deliverable completion matrix
- Approval workflow status
- Time tracking and estimates
- Color-coded status indicators

### 🌐 Web Dashboard Features
- Interactive task cards
- Real-time progress updates
- Statistics overview
- Responsive design
- Auto-refresh capability

### 📈 Dashboard Mode Features  
- Milestone overview
- All tasks summary
- Phase distribution statistics
- Velocity metrics
- Action recommendations

### 📝 Simple Mode Features
- Minimal text output
- Quick status check
- Terminal-friendly
- Scriptable output

## Integration with Kiro Workflow

The visualization command fully integrates with the kiro-native workflow system:

1. **Automatic Detection**: Identifies kiro-enabled tasks
2. **Phase Tracking**: Shows current phase and progress
3. **Deliverable Status**: Validates and displays deliverables
4. **Approval Workflow**: Highlights approval requirements
5. **Action Guidance**: Suggests next steps based on current state

## Customization

### Environment Variables
```bash
# Set default visualization mode
export KIRO_VIZ_MODE=dashboard

# Enable colors
export KIRO_VIZ_COLORS=true

# Set refresh interval for watch mode
export KIRO_VIZ_REFRESH=10

# Default export format
export KIRO_VIZ_EXPORT_FORMAT=html
```

### Configuration File
Create `.milestones/config/visualization.yaml`:
```yaml
defaults:
  mode: rich
  colors: true
  icons: true
  refresh_interval: 5
  
web_dashboard:
  auto_open: true
  port: 8080
  theme: default
  
export:
  default_format: html
  include_metadata: true
```

---

**Remember**: The visualization command is your window into the kiro workflow system. Use it frequently to track progress, identify bottlenecks, and maintain visibility across all phases of your milestone tasks.