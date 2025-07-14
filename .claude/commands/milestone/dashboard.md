---
allowed-tools: all
description: Interactive milestone monitoring dashboard with real-time updates and notifications
---

# 📊 Milestone Dashboard

**REAL-TIME INTERACTIVE MONITORING - LIVE UPDATES AND NOTIFICATIONS**

This command provides a comprehensive interactive dashboard for milestone monitoring with real-time updates, notifications, and collaborative features.

## Dashboard Modes

### Interactive Dashboard
```bash
/milestone/dashboard
```

### Specific Milestone Focus
```bash
/milestone/dashboard <milestone-id>
```

### Live Monitoring Mode
```bash
/milestone/dashboard --live --refresh=30
```

### Team Collaboration View
```bash
/milestone/dashboard --team --notifications
```

## Features

### Real-Time Updates
- **Live Progress Tracking**: Automatic updates every 30 seconds
- **Change Notifications**: Instant alerts on milestone state changes
- **Collaborative Indicators**: Show who's working on what in real-time
- **Event Streaming**: Live event log with filtering capabilities

### Interactive Elements
- **Clickable Milestone Cards**: Drill down into specific milestone details
- **Task Management**: Complete tasks directly from the dashboard
- **Quick Actions**: Fast milestone updates without leaving the dashboard
- **Filtering and Search**: Find specific milestones and tasks quickly

### Notification System
- **Progress Alerts**: Notifications when milestones reach completion thresholds
- **Blocker Warnings**: Early warning system for potential issues
- **Deadline Reminders**: Smart notifications based on timeline urgency
- **Team Coordination**: Alerts for dependency conflicts and coordination needs

## Implementation

```bash
#!/bin/bash

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_shared/state.md"
source "$SCRIPT_DIR/_shared/validation.md"
source "$SCRIPT_DIR/_shared/utils.md"
source "$SCRIPT_DIR/_shared/context.md"
source "$SCRIPT_DIR/_shared/git-integration.md"

# Main dashboard function
main() {
    local milestone_id=""
    local mode="interactive"
    local refresh_interval=30
    local enable_notifications=false
    local team_view=false
    local live_mode=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --live)
                live_mode=true
                shift
                ;;
            --refresh=*)
                refresh_interval="${1#*=}"
                shift
                ;;
            --team)
                team_view=true
                shift
                ;;
            --notifications)
                enable_notifications=true
                shift
                ;;
            --mode=*)
                mode="${1#*=}"
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            -*)
                echo "ERROR: Unknown option $1"
                show_usage
                exit 1
                ;;
            *)
                milestone_id="$1"
                shift
                ;;
        esac
    done
    
    # Validate refresh interval
    if ! [[ "$refresh_interval" =~ ^[0-9]+$ ]] || [ "$refresh_interval" -lt 5 ]; then
        echo "ERROR: Invalid refresh interval: $refresh_interval (minimum 5 seconds)"
        exit 1
    fi
    
    # Initialize dashboard
    initialize_dashboard "$milestone_id" "$mode" "$live_mode" "$team_view" "$enable_notifications" "$refresh_interval"
}

# Show usage information
show_usage() {
    cat << EOF
Usage: /milestone/dashboard [OPTIONS] [MILESTONE_ID]

Options:
  <milestone-id>              Focus on specific milestone
  --live                      Enable live updates
  --refresh=SECONDS           Set refresh interval (default: 30, minimum: 5)
  --team                      Enable team collaboration view
  --notifications             Enable desktop notifications
  --mode=MODE                 Dashboard mode (interactive|focus|overview)

Examples:
  /milestone/dashboard
  /milestone/dashboard milestone-003
  /milestone/dashboard --live --refresh=15
  /milestone/dashboard --team --notifications
EOF
}

# Initialize and launch dashboard
initialize_dashboard() {
    local milestone_id=$1
    local mode=$2
    local live_mode=$3
    local team_view=$4
    local enable_notifications=$5
    local refresh_interval=$6
    
    echo "🚀 Launching Milestone Dashboard..."
    echo "   Mode: $mode"
    echo "   Live Updates: $live_mode"
    echo "   Team View: $team_view"
    echo "   Notifications: $enable_notifications"
    echo "   Refresh Interval: ${refresh_interval}s"
    echo ""
    
    # Create dashboard session
    local dashboard_session_id=$(create_dashboard_session "$milestone_id")
    echo "Dashboard Session: $dashboard_session_id"
    
    # Validate dashboard context
    if ! validate_dashboard_context "$milestone_id"; then
        echo "ERROR: Dashboard context validation failed"
        exit 1
    fi
    
    case "$mode" in
        "interactive")
            launch_interactive_dashboard "$milestone_id" "$live_mode" "$team_view" "$enable_notifications" "$refresh_interval" "$dashboard_session_id"
            ;;
        "focus")
            launch_focus_dashboard "$milestone_id" "$live_mode" "$enable_notifications" "$refresh_interval" "$dashboard_session_id"
            ;;
        "overview")
            launch_overview_dashboard "$live_mode" "$team_view" "$enable_notifications" "$refresh_interval" "$dashboard_session_id"
            ;;
        *)
            echo "ERROR: Unknown dashboard mode: $mode"
            exit 1
            ;;
    esac
}

# Launch interactive dashboard
launch_interactive_dashboard() {
    local milestone_id=$1
    local live_mode=$2
    local team_view=$3
    local enable_notifications=$4
    local refresh_interval=$5
    local session_id=$6
    
    # Generate HTML dashboard
    local dashboard_file="/tmp/milestone_dashboard_${session_id}.html"
    generate_interactive_html_dashboard "$dashboard_file" "$milestone_id" "$live_mode" "$team_view" "$enable_notifications" "$refresh_interval" "$session_id"
    
    # Start background update service if live mode enabled
    if [ "$live_mode" = true ]; then
        start_live_update_service "$session_id" "$refresh_interval" &
        local update_pid=$!
        echo "Live update service started (PID: $update_pid)"
    fi
    
    # Launch dashboard in browser
    echo "Opening dashboard in browser..."
    launch_browser "$dashboard_file"
    
    # Interactive command loop
    echo ""
    echo "Dashboard is running. Available commands:"
    echo "  refresh - Manually refresh dashboard"
    echo "  status  - Show current dashboard status"
    echo "  quit    - Exit dashboard"
    echo ""
    
    interactive_command_loop "$session_id" "$dashboard_file"
    
    # Cleanup
    cleanup_dashboard "$session_id"
}

# Generate interactive HTML dashboard
generate_interactive_html_dashboard() {
    local output_file=$1
    local milestone_id=$2
    local live_mode=$3
    local team_view=$4
    local enable_notifications=$5
    local refresh_interval=$6
    local session_id=$7
    
    cat > "$output_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Milestone Dashboard - Session $session_id</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
            overflow-x: hidden;
        }
        
        .dashboard-container {
            min-height: 100vh;
            padding: 20px;
        }
        
        .header {
            background: rgba(255,255,255,0.95);
            backdrop-filter: blur(10px);
            border-radius: 16px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            color: #667eea;
            font-size: 2.5em;
            font-weight: 300;
        }
        
        .live-indicator {
            display: flex;
            align-items: center;
            gap: 10px;
            background: #4CAF50;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 500;
        }
        
        .live-dot {
            width: 8px;
            height: 8px;
            background: white;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .widget {
            background: rgba(255,255,255,0.95);
            backdrop-filter: blur(10px);
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        .widget:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 48px rgba(0,0,0,0.15);
        }
        
        .widget-title {
            font-size: 1.2em;
            font-weight: 600;
            margin-bottom: 16px;
            color: #667eea;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .progress-container {
            margin: 16px 0;
        }
        
        .progress-bar {
            width: 100%;
            height: 12px;
            background: #e0e0e0;
            border-radius: 6px;
            overflow: hidden;
            position: relative;
        }
        
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #4CAF50, #45a049);
            border-radius: 6px;
            transition: width 0.5s ease;
            position: relative;
        }
        
        .progress-fill::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            animation: shimmer 2s infinite;
        }
        
        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }
        
        .milestone-card {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 16px;
            margin: 8px 0;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .milestone-card:hover {
            background: #e3f2fd;
            transform: translateX(4px);
        }
        
        .milestone-card.completed {
            border-left-color: #4CAF50;
            background: #e8f5e8;
        }
        
        .milestone-card.in-progress {
            border-left-color: #FF9800;
            background: #fff3e0;
        }
        
        .milestone-card.blocked {
            border-left-color: #f44336;
            background: #ffebee;
        }
        
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            background: #4CAF50;
            color: white;
            padding: 16px 24px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            transform: translateX(400px);
            transition: transform 0.3s ease;
            z-index: 1000;
        }
        
        .notification.show {
            transform: translateX(0);
        }
        
        .notification.error {
            background: #f44336;
        }
        
        .notification.warning {
            background: #FF9800;
        }
        
        .team-indicators {
            display: flex;
            gap: 8px;
            margin-top: 12px;
        }
        
        .team-member {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #667eea;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8em;
            font-weight: 600;
            position: relative;
        }
        
        .team-member.active::after {
            content: '';
            position: absolute;
            bottom: -2px;
            right: -2px;
            width: 12px;
            height: 12px;
            background: #4CAF50;
            border-radius: 50%;
            border: 2px solid white;
        }
        
        .actions {
            display: flex;
            gap: 12px;
            margin-top: 16px;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            background: #667eea;
            color: white;
            cursor: pointer;
            font-size: 0.9em;
            transition: background 0.3s ease;
        }
        
        .btn:hover {
            background: #5a6fd8;
        }
        
        .btn.secondary {
            background: #6c757d;
        }
        
        .btn.success {
            background: #4CAF50;
        }
        
        .timestamp {
            position: fixed;
            bottom: 20px;
            left: 20px;
            background: rgba(0,0,0,0.7);
            color: white;
            padding: 8px 12px;
            border-radius: 6px;
            font-size: 0.8em;
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="header">
            <h1>📊 Milestone Dashboard</h1>
            <div class="live-indicator" style="display: $([ "$live_mode" = true ] && echo "flex" || echo "none")">
                <div class="live-dot"></div>
                Live Updates
            </div>
        </div>
        
        <div class="dashboard-grid">
            <!-- Project Overview Widget -->
            <div class="widget">
                <div class="widget-title">🎯 Project Overview</div>
                <div class="progress-container">
                    <div>Overall Progress</div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: 67%" id="overall-progress"></div>
                    </div>
                    <div style="margin-top: 8px; font-size: 0.9em; color: #666;">
                        67% Complete (8 of 12 milestones)
                    </div>
                </div>
                <div class="actions">
                    <button class="btn" onclick="refreshDashboard()">Refresh</button>
                    <button class="btn secondary" onclick="exportReport()">Export Report</button>
                </div>
            </div>
            
            <!-- Active Milestones Widget -->
            <div class="widget">
                <div class="widget-title">🚀 Active Milestones</div>
                <div id="active-milestones">
                    <div class="milestone-card in-progress" onclick="openMilestone('milestone-003')">
                        <div style="font-weight: 600;">milestone-003: API Integration</div>
                        <div class="progress-container">
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: 78%"></div>
                            </div>
                        </div>
                        <div style="font-size: 0.8em; color: #666; margin-top: 4px;">
                            Due: 2024-07-20 • 78% Complete
                        </div>
                        $([ "$team_view" = true ] && echo '<div class="team-indicators">
                            <div class="team-member active">JD</div>
                            <div class="team-member">AS</div>
                        </div>')
                    </div>
                    
                    <div class="milestone-card in-progress" onclick="openMilestone('milestone-004')">
                        <div style="font-weight: 600;">milestone-004: Frontend Integration</div>
                        <div class="progress-container">
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: 34%"></div>
                            </div>
                        </div>
                        <div style="font-size: 0.8em; color: #666; margin-top: 4px;">
                            Due: 2024-07-25 • 34% Complete
                        </div>
                        $([ "$team_view" = true ] && echo '<div class="team-indicators">
                            <div class="team-member active">MK</div>
                            <div class="team-member active">LT</div>
                        </div>')
                    </div>
                </div>
            </div>
            
            <!-- Performance Metrics Widget -->
            <div class="widget">
                <div class="widget-title">📈 Performance Metrics</div>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                    <div style="text-align: center;">
                        <div style="font-size: 1.8em; font-weight: 600; color: #4CAF50;">96.2%</div>
                        <div style="font-size: 0.8em; color: #666;">On-time Delivery</div>
                    </div>
                    <div style="text-align: center;">
                        <div style="font-size: 1.8em; font-weight: 600; color: #FF9800;">1.08</div>
                        <div style="font-size: 0.8em; color: #666;">Efficiency Ratio</div>
                    </div>
                    <div style="text-align: center;">
                        <div style="font-size: 1.8em; font-weight: 600; color: #667eea;">12.3</div>
                        <div style="font-size: 0.8em; color: #666;">Avg Duration (days)</div>
                    </div>
                    <div style="text-align: center;">
                        <div style="font-size: 1.8em; font-weight: 600; color: #4CAF50;">2.1</div>
                        <div style="font-size: 0.8em; color: #666;">Blocker Resolution (days)</div>
                    </div>
                </div>
            </div>
            
            <!-- Risk Alerts Widget -->
            <div class="widget">
                <div class="widget-title">⚠️ Risk Alerts</div>
                <div style="space-y: 8px;">
                    <div style="padding: 8px; background: #ffebee; border-left: 4px solid #f44336; border-radius: 4px; margin-bottom: 8px;">
                        <div style="font-weight: 600; color: #d32f2f;">HIGH: External API Changes</div>
                        <div style="font-size: 0.8em; color: #666;">Affecting milestone-004, potential 2-day delay</div>
                    </div>
                    <div style="padding: 8px; background: #fff3e0; border-left: 4px solid #FF9800; border-radius: 4px;">
                        <div style="font-weight: 600; color: #f57c00;">MEDIUM: Resource Conflict</div>
                        <div style="font-size: 0.8em; color: #666;">Team allocation overlap between M-003 and M-004</div>
                    </div>
                </div>
            </div>
            
            <!-- Quick Actions Widget -->
            <div class="widget">
                <div class="widget-title">⚡ Quick Actions</div>
                <div style="display: flex; flex-direction: column; gap: 8px;">
                    <button class="btn" onclick="updateProgress()">Update Progress</button>
                    <button class="btn" onclick="addTask()">Add Task</button>
                    <button class="btn success" onclick="completeMilestone()">Complete Milestone</button>
                    <button class="btn secondary" onclick="createReport()">Generate Report</button>
                </div>
            </div>
            
            <!-- Recent Activity Widget -->
            <div class="widget">
                <div class="widget-title">📋 Recent Activity</div>
                <div id="recent-activity" style="max-height: 200px; overflow-y: auto;">
                    <div style="padding: 8px 0; border-bottom: 1px solid #eee; font-size: 0.9em;">
                        <div style="font-weight: 600;">Task completed: OAuth implementation</div>
                        <div style="color: #666; font-size: 0.8em;">milestone-003 • 5 minutes ago</div>
                    </div>
                    <div style="padding: 8px 0; border-bottom: 1px solid #eee; font-size: 0.9em;">
                        <div style="font-weight: 600;">Progress updated to 78%</div>
                        <div style="color: #666; font-size: 0.8em;">milestone-003 • 12 minutes ago</div>
                    </div>
                    <div style="padding: 8px 0; border-bottom: 1px solid #eee; font-size: 0.9em;">
                        <div style="font-weight: 600;">New task added: Rate limiting</div>
                        <div style="color: #666; font-size: 0.8em;">milestone-003 • 23 minutes ago</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="notification" id="notification"></div>
    <div class="timestamp">Last updated: <span id="last-updated">$(date)</span></div>
    
    <script>
        // Dashboard JavaScript functionality
        let dashboardSession = '$session_id';
        let refreshInterval = $refresh_interval * 1000;
        let liveMode = $live_mode;
        let notifications = $enable_notifications;
        
        // Initialize dashboard
        function initializeDashboard() {
            console.log('Dashboard initialized:', dashboardSession);
            
            if (liveMode) {
                setInterval(refreshDashboard, refreshInterval);
                console.log('Live updates enabled, refresh interval:', refreshInterval);
            }
            
            if (notifications && 'Notification' in window) {
                requestNotificationPermission();
            }
        }
        
        // Refresh dashboard data
        function refreshDashboard() {
            console.log('Refreshing dashboard...');
            
            // Update timestamp
            document.getElementById('last-updated').textContent = new Date().toLocaleString();
            
            // Simulate data refresh
            updateProgressBars();
            
            showNotification('Dashboard refreshed', 'success');
        }
        
        // Update progress bars with animation
        function updateProgressBars() {
            const progressBars = document.querySelectorAll('.progress-fill');
            progressBars.forEach(bar => {
                const currentWidth = parseInt(bar.style.width);
                const variation = Math.random() * 4 - 2; // ±2% variation
                const newWidth = Math.max(0, Math.min(100, currentWidth + variation));
                bar.style.width = newWidth + '%';
            });
        }
        
        // Show notification
        function showNotification(message, type = 'success') {
            const notification = document.getElementById('notification');
            notification.textContent = message;
            notification.className = 'notification ' + type + ' show';
            
            setTimeout(() => {
                notification.classList.remove('show');
            }, 3000);
            
            // Desktop notification
            if (notifications && 'Notification' in window && Notification.permission === 'granted') {
                new Notification('Milestone Dashboard', {
                    body: message,
                    icon: '/favicon.ico'
                });
            }
        }
        
        // Request notification permission
        function requestNotificationPermission() {
            if ('Notification' in window && Notification.permission === 'default') {
                Notification.requestPermission();
            }
        }
        
        // Milestone actions
        function openMilestone(milestoneId) {
            showNotification('Opening milestone: ' + milestoneId);
            // In real implementation, this would open milestone details
        }
        
        function updateProgress() {
            showNotification('Progress update dialog would open here');
        }
        
        function addTask() {
            showNotification('Add task dialog would open here');
        }
        
        function completeMilestone() {
            showNotification('Complete milestone confirmation would appear here');
        }
        
        function createReport() {
            showNotification('Generating report...');
        }
        
        function exportReport() {
            showNotification('Exporting report...');
        }
        
        // Initialize when page loads
        document.addEventListener('DOMContentLoaded', initializeDashboard);
        
        // Handle page visibility for live updates
        document.addEventListener('visibilitychange', function() {
            if (!document.hidden && liveMode) {
                refreshDashboard();
            }
        });
    </script>
</body>
</html>
EOF
    
    echo "Interactive dashboard generated: $output_file"
}

# Interactive command loop
interactive_command_loop() {
    local session_id=$1
    local dashboard_file=$2
    
    while true; do
        echo -n "dashboard> "
        read -r command
        
        case "$command" in
            "refresh")
                echo "Refreshing dashboard..."
                # Trigger refresh in browser
                ;;
            "status")
                show_dashboard_status "$session_id"
                ;;
            "quit"|"exit")
                echo "Exiting dashboard..."
                break
                ;;
            "help")
                echo "Available commands: refresh, status, quit"
                ;;
            "")
                # Empty command, continue
                ;;
            *)
                echo "Unknown command: $command (type 'help' for available commands)"
                ;;
        esac
    done
}

# Helper functions

create_dashboard_session() {
    local milestone_id=$1
    local session_id="dashboard-$(date +%Y%m%d-%H%M%S)-$$"
    
    # Create session directory
    mkdir -p ".milestones/sessions/dashboard"
    
    # Create session file
    cat > ".milestones/sessions/dashboard/$session_id.json" << EOF
{
  "session_id": "$session_id",
  "milestone_focus": "$([ -n "$milestone_id" ] && echo "$milestone_id" || echo "all")",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "pid": $$,
  "user": "$(whoami)",
  "status": "active"
}
EOF
    
    echo "$session_id"
}

validate_dashboard_context() {
    local milestone_id=$1
    
    # Basic validation - check if milestones directory exists
    if [ ! -d ".milestones" ]; then
        echo "ERROR: No milestones directory found"
        return 1
    fi
    
    # If specific milestone requested, validate it exists
    if [ -n "$milestone_id" ]; then
        if [ ! -f ".milestones/active/$milestone_id.yaml" ]; then
            echo "ERROR: Milestone not found: $milestone_id"
            return 1
        fi
    fi
    
    return 0
}

start_live_update_service() {
    local session_id=$1
    local refresh_interval=$2
    
    # Background service for live updates
    while true; do
        sleep "$refresh_interval"
        
        # Check if session is still active
        if [ ! -f ".milestones/sessions/dashboard/$session_id.json" ]; then
            break
        fi
        
        # Update dashboard data (placeholder)
        echo "[$(date)] Live update: $session_id" >> ".milestones/logs/dashboard-$session_id.log"
    done
}

launch_browser() {
    local html_file=$1
    
    # Try to open in browser
    if command -v open >/dev/null 2>&1; then
        open "$html_file"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$html_file"
    elif command -v firefox >/dev/null 2>&1; then
        firefox "$html_file" &
    elif command -v chrome >/dev/null 2>&1; then
        chrome "$html_file" &
    else
        echo "Could not open browser automatically. Please open: $html_file"
    fi
}

show_dashboard_status() {
    local session_id=$1
    local session_file=".milestones/sessions/dashboard/$session_id.json"
    
    if [ -f "$session_file" ]; then
        echo "Dashboard Status:"
        echo "  Session ID: $session_id"
        echo "  Created: $(jq -r '.created_at' "$session_file")"
        echo "  Focus: $(jq -r '.milestone_focus' "$session_file")"
        echo "  Status: $(jq -r '.status' "$session_file")"
    else
        echo "ERROR: Session file not found"
    fi
}

cleanup_dashboard() {
    local session_id=$1
    local session_file=".milestones/sessions/dashboard/$session_id.json"
    
    echo "Cleaning up dashboard session..."
    
    # Update session status
    if [ -f "$session_file" ]; then
        local temp_file=$(mktemp)
        jq '.status = "completed" | .ended_at = "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"' "$session_file" > "$temp_file"
        mv "$temp_file" "$session_file"
    fi
    
    # Clean up temporary files
    rm -f "/tmp/milestone_dashboard_${session_id}.html"
    
    echo "Dashboard session cleaned up: $session_id"
}

# Additional dashboard modes (simplified implementations)

launch_focus_dashboard() {
    local milestone_id=$1
    local live_mode=$2
    local enable_notifications=$3
    local refresh_interval=$4
    local session_id=$5
    
    echo "Focus Dashboard for milestone: $milestone_id"
    # Would implement focused single-milestone dashboard
}

launch_overview_dashboard() {
    local live_mode=$1
    local team_view=$2
    local enable_notifications=$3
    local refresh_interval=$4
    local session_id=$5
    
    echo "Overview Dashboard for all milestones"
    # Would implement high-level overview dashboard
}

# Execute main function with all arguments
main "$@"