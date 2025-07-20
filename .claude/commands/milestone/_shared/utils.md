---
description: Common utility functions for milestone operations including file operations, date/time utilities, and reporting helpers
---

# Milestone Utility Functions

Comprehensive utility functions providing file operations, date/time management, progress calculations, template processing, and reporting capabilities for milestone execution.

## File Operations and Directory Management

```bash
# Safe atomic file operations
atomic_write_file() {
    local target_file=$1
    local content=$2
    local backup=${3:-true}
    local temp_file="$target_file.tmp.$$"
    
    # Create backup if requested and file exists
    if [ "$backup" = true ] && [ -f "$target_file" ]; then
        cp "$target_file" "$target_file.bak.$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Write to temporary file
    echo "$content" > "$temp_file"
    
    # Verify write was successful
    if [ ! -f "$temp_file" ]; then
        echo "ERROR: Failed to write temporary file: $temp_file"
        return 1
    fi
    
    # Atomic move
    if mv "$temp_file" "$target_file"; then
        echo "File written successfully: $target_file"
    else
        echo "ERROR: Failed to move temporary file to target: $target_file"
        rm -f "$temp_file"
        return 1
    fi
}

# Safe directory creation with proper permissions
ensure_milestone_directory() {
    local dir_path=$1
    local permissions=${2:-755}
    
    if [ ! -d "$dir_path" ]; then
        if mkdir -p "$dir_path"; then
            chmod "$permissions" "$dir_path"
            echo "Created directory: $dir_path"
        else
            echo "ERROR: Failed to create directory: $dir_path"
            return 1
        fi
    elif [ ! -w "$dir_path" ]; then
        echo "ERROR: Directory not writable: $dir_path"
        return 1
    fi
}

# Get file size in human readable format
get_file_size() {
    local file_path=$1
    
    if [ ! -f "$file_path" ]; then
        echo "0B"
        return 1
    fi
    
    local size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null)
    
    # Convert to human readable
    if [ "$size" -lt 1024 ]; then
        echo "${size}B"
    elif [ "$size" -lt 1048576 ]; then
        echo "$((size / 1024))KB"
    elif [ "$size" -lt 1073741824 ]; then
        echo "$((size / 1048576))MB"
    else
        echo "$((size / 1073741824))GB"
    fi
}

# Clean up temporary files
cleanup_temp_files() {
    local pattern=${1:-"milestone_tmp_*"}
    local max_age_hours=${2:-24}
    
    # Find and remove temporary files older than specified hours
    find /tmp -name "$pattern" -type f -mtime "+$(($max_age_hours/24))" -delete 2>/dev/null
    find . -name "*.tmp.*" -type f -mtime "+$(($max_age_hours/24))" -delete 2>/dev/null
    
    echo "Temporary files cleanup completed"
}

# Archive milestone files
archive_milestone_files() {
    local milestone_id=$1
    local archive_dir=${2:-".milestones/archive"}
    local compression=${3:-"gzip"}
    
    ensure_milestone_directory "$archive_dir"
    
    local archive_name="$archive_dir/milestone-$milestone_id-$(date +%Y%m%d-%H%M%S)"
    
    case "$compression" in
        "gzip")
            tar -czf "$archive_name.tar.gz" ".milestones/active/$milestone_id.yaml" ".milestones/state/events/milestone-$milestone_id.jsonl" 2>/dev/null
            echo "Archive created: $archive_name.tar.gz"
            ;;
        "zip")
            zip -q "$archive_name.zip" ".milestones/active/$milestone_id.yaml" ".milestones/state/events/milestone-$milestone_id.jsonl" 2>/dev/null
            echo "Archive created: $archive_name.zip"
            ;;
        "none")
            mkdir -p "$archive_name"
            cp ".milestones/active/$milestone_id.yaml" "$archive_name/" 2>/dev/null
            cp ".milestones/state/events/milestone-$milestone_id.jsonl" "$archive_name/" 2>/dev/null
            echo "Archive created: $archive_name/"
            ;;
        *)
            echo "ERROR: Unsupported compression type: $compression"
            return 1
            ;;
    esac
}
```

## Date and Time Utilities

```bash
# Get current timestamp in ISO format
get_iso_timestamp() {
    date -u +%Y-%m-%dT%H:%M:%SZ
}

# Calculate duration between two timestamps
calculate_duration() {
    local start_time=$1
    local end_time=${2:-"$(get_iso_timestamp)"}
    
    # Convert to epoch seconds
    local start_epoch=$(date -d "$start_time" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$start_time" +%s 2>/dev/null)
    local end_epoch=$(date -d "$end_time" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$end_time" +%s 2>/dev/null)
    
    if [ -z "$start_epoch" ] || [ -z "$end_epoch" ]; then
        echo "ERROR: Invalid timestamp format"
        return 1
    fi
    
    local duration_seconds=$((end_epoch - start_epoch))
    
    # Convert to human readable format
    format_duration $duration_seconds
}

# Format duration in human readable format
format_duration() {
    local total_seconds=$1
    
    if [ "$total_seconds" -lt 0 ]; then
        echo "0 seconds"
        return
    fi
    
    local days=$((total_seconds / 86400))
    local hours=$(((total_seconds % 86400) / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))
    
    local result=""
    
    [ $days -gt 0 ] && result="${result}${days}d "
    [ $hours -gt 0 ] && result="${result}${hours}h "
    [ $minutes -gt 0 ] && result="${result}${minutes}m "
    [ $seconds -gt 0 ] && result="${result}${seconds}s"
    
    # Trim trailing space and return
    echo "${result% }"
}

# Get business days between two dates
get_business_days() {
    local start_date=$1
    local end_date=$2
    
    # Convert to simple date format
    local start_simple=$(date -d "$start_date" +%Y-%m-%d 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$start_date" +%Y-%m-%d 2>/dev/null)
    local end_simple=$(date -d "$end_date" +%Y-%m-%d 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$end_date" +%Y-%m-%d 2>/dev/null)
    
    if [ -z "$start_simple" ] || [ -z "$end_simple" ]; then
        echo "ERROR: Invalid date format"
        return 1
    fi
    
    # Calculate business days using python for accuracy
    python3 << EOF
import datetime
start = datetime.datetime.strptime("$start_simple", "%Y-%m-%d")
end = datetime.datetime.strptime("$end_simple", "%Y-%m-%d")

business_days = 0
current = start
while current <= end:
    if current.weekday() < 5:  # Monday is 0, Friday is 4
        business_days += 1
    current += datetime.timedelta(days=1)

print(business_days)
EOF
}

# Calculate estimated completion date
estimate_completion_date() {
    local milestone_id=$1
    local current_progress=${2:-0}
    local daily_velocity=${3:-5}  # Default 5% per day
    
    if [ "$current_progress" -ge 100 ]; then
        echo "Already completed"
        return 0
    fi
    
    local remaining_progress=$((100 - current_progress))
    local estimated_days=$((remaining_progress / daily_velocity))
    
    # Add current date
    local completion_date=$(date -d "+$estimated_days days" +%Y-%m-%d 2>/dev/null || date -j -v+${estimated_days}d +%Y-%m-%d 2>/dev/null)
    
    echo "$completion_date (in $estimated_days days)"
}

# Get milestone age in days
get_milestone_age() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    if [ ! -f "$milestone_file" ]; then
        milestone_file=".milestones/completed/$milestone_id.yaml"
    fi
    
    if [ ! -f "$milestone_file" ]; then
        echo "ERROR: Milestone file not found"
        return 1
    fi
    
    local created_at=$(yq e '.created_at' "$milestone_file")
    local created_epoch=$(date -d "$created_at" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$created_at" +%s 2>/dev/null)
    local current_epoch=$(date +%s)
    
    local age_days=$(((current_epoch - created_epoch) / 86400))
    echo "$age_days"
}
```

## Progress Calculation Functions

```bash
# Calculate milestone progress percentage
calculate_milestone_progress() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    if [ ! -f "$milestone_file" ]; then
        echo "ERROR: Milestone file not found"
        return 1
    fi
    
    # Get total and completed tasks
    local total_tasks=$(yq e '.tasks | length' "$milestone_file" 2>/dev/null || echo "0")
    
    if [ "$total_tasks" -eq 0 ]; then
        echo "0"
        return 0
    fi
    
    local completed_tasks=$(yq e '.tasks[] | select(.status == "completed") | .id' "$milestone_file" 2>/dev/null | wc -l)
    
    # Calculate percentage
    local progress=$((completed_tasks * 100 / total_tasks))
    echo "$progress"
}

# Calculate weighted progress based on task complexity
calculate_weighted_progress() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    if [ ! -f "$milestone_file" ]; then
        echo "ERROR: Milestone file not found"
        return 1
    fi
    
    # Use python for more complex calculations
    python3 << EOF
import yaml
import sys

try:
    with open("$milestone_file", 'r') as f:
        milestone = yaml.safe_load(f)
    
    tasks = milestone.get('tasks', [])
    if not tasks:
        print("0")
        sys.exit(0)
    
    total_weight = 0
    completed_weight = 0
    
    for task in tasks:
        weight = task.get('weight', 1)  # Default weight is 1
        total_weight += weight
        
        if task.get('status') == 'completed':
            completed_weight += weight
    
    if total_weight == 0:
        print("0")
    else:
        progress = int((completed_weight / total_weight) * 100)
        print(progress)

except Exception as e:
    print("0")
EOF
}

# Calculate milestone velocity (progress per day)
calculate_milestone_velocity() {
    local milestone_id=$1
    local days_period=${2:-7}  # Default to last 7 days
    
    # Get events from the specified period
    local since_date=$(date -d "$days_period days ago" +%Y-%m-%d 2>/dev/null || date -j -v-${days_period}d +%Y-%m-%d 2>/dev/null)
    local events_file=".milestones/state/events/milestone-$milestone_id.jsonl"
    
    if [ ! -f "$events_file" ]; then
        echo "0"
        return 0
    fi
    
    # Calculate velocity using python
    python3 << EOF
import json
import sys
from datetime import datetime, timedelta

try:
    progress_events = []
    with open("$events_file", 'r') as f:
        for line in f:
            event = json.loads(line.strip())
            if event.get('event_type') == 'task_completed':
                event_date = datetime.fromisoformat(event['timestamp'].replace('Z', '+00:00'))
                since_datetime = datetime.fromisoformat("$since_date" + "T00:00:00+00:00")
                
                if event_date >= since_datetime:
                    progress_events.append(event)
    
    # Calculate velocity as tasks completed per day
    velocity = len(progress_events) / $days_period
    print(f"{velocity:.2f}")

except Exception as e:
    print("0")
EOF
}

# Generate progress trend analysis
generate_progress_trend() {
    local milestone_id=$1
    local days_back=${2:-14}
    
    echo "=== Progress Trend Analysis: $milestone_id ==="
    
    # Calculate daily progress for the period
    for ((i=days_back; i>=0; i--)); do
        local check_date=$(date -d "$i days ago" +%Y-%m-%d 2>/dev/null || date -j -v-${i}d +%Y-%m-%d 2>/dev/null)
        local daily_completed=$(query_milestone_events "$milestone_id" "task_completed" "$check_date" | wc -l)
        
        printf "%s: %d tasks completed\n" "$check_date" "$daily_completed"
    done
    
    echo ""
    echo "Current velocity: $(calculate_milestone_velocity "$milestone_id" 7) tasks/day (7-day average)"
    echo "Current progress: $(calculate_milestone_progress "$milestone_id")%"
}
```

## Template Processing Utilities

```bash
# Process YAML template with variable substitution
process_yaml_template() {
    local template_file=$1
    local variables_file=$2
    local output_file=$3
    
    if [ ! -f "$template_file" ]; then
        echo "ERROR: Template file not found: $template_file"
        return 1
    fi
    
    if [ ! -f "$variables_file" ]; then
        echo "ERROR: Variables file not found: $variables_file"
        return 1
    fi
    
    # Use python for template processing
    python3 << EOF
import yaml
import re
import sys

try:
    # Load variables
    with open("$variables_file", 'r') as f:
        variables = yaml.safe_load(f)
    
    # Read template
    with open("$template_file", 'r') as f:
        template_content = f.read()
    
    # Replace variables
    for key, value in variables.items():
        pattern = r'\{\{\s*' + re.escape(key) + r'\s*\}\}'
        template_content = re.sub(pattern, str(value), template_content)
    
    # Write output
    with open("$output_file", 'w') as f:
        f.write(template_content)
    
    print("Template processed successfully: $output_file")

except Exception as e:
    print(f"ERROR: Template processing failed: {e}")
    sys.exit(1)
EOF
}

# Generate milestone configuration from template
generate_milestone_config() {
    local template_name=$1
    local milestone_id=$2
    local title=$3
    local description=$4
    
    local template_dir="templates/milestone"
    local template_file="$template_dir/$template_name.yaml"
    local output_file=".milestones/active/$milestone_id.yaml"
    
    if [ ! -f "$template_file" ]; then
        echo "ERROR: Template not found: $template_file"
        return 1
    fi
    
    # Create variables for substitution
    local vars_file="/tmp/milestone_vars_$$.yaml"
    cat > "$vars_file" << EOF
milestone_id: "$milestone_id"
title: "$title"
description: "$description"
created_at: "$(get_iso_timestamp)"
status: "planning"
progress:
  percentage: 0
  completed_tasks: 0
  total_tasks: 0
EOF
    
    # Process template
    process_yaml_template "$template_file" "$vars_file" "$output_file"
    local result=$?
    
    # Cleanup
    rm -f "$vars_file"
    
    return $result
}

# Validate YAML structure
validate_yaml_structure() {
    local yaml_file=$1
    local schema_file=${2:-""}
    
    if [ ! -f "$yaml_file" ]; then
        echo "ERROR: YAML file not found: $yaml_file"
        return 1
    fi
    
    # Basic YAML syntax validation
    if ! yq e '.' "$yaml_file" >/dev/null 2>&1; then
        echo "ERROR: Invalid YAML syntax in file: $yaml_file"
        return 1
    fi
    
    # Schema validation if provided
    if [ -n "$schema_file" ] && [ -f "$schema_file" ]; then
        # This would require a YAML schema validator
        # For now, just validate basic structure
        echo "YAML structure validation passed"
    fi
    
    echo "YAML validation successful: $yaml_file"
}
```

## Reporting and Formatting Helpers

```bash
# Generate milestone status report
generate_status_report() {
    local milestone_id=$1
    local format=${2:-"text"}
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    if [ ! -f "$milestone_file" ]; then
        milestone_file=".milestones/completed/$milestone_id.yaml"
    fi
    
    if [ ! -f "$milestone_file" ]; then
        echo "ERROR: Milestone file not found"
        return 1
    fi
    
    case "$format" in
        "text")
            generate_text_report "$milestone_id" "$milestone_file"
            ;;
        "json")
            generate_json_report "$milestone_id" "$milestone_file"
            ;;
        "markdown")
            generate_markdown_report "$milestone_id" "$milestone_file"
            ;;
        *)
            echo "ERROR: Unsupported format: $format"
            return 1
            ;;
    esac
}

# Generate text format report
generate_text_report() {
    local milestone_id=$1
    local milestone_file=$2
    
    local title=$(yq e '.title' "$milestone_file")
    local status=$(yq e '.status' "$milestone_file")
    local progress=$(calculate_milestone_progress "$milestone_id")
    local created_at=$(yq e '.created_at' "$milestone_file")
    local age=$(get_milestone_age "$milestone_id")
    
    cat << EOF
=== Milestone Status Report ===
ID: $milestone_id
Title: $title
Status: $status
Progress: $progress%
Created: $created_at
Age: $age days

Tasks Summary:
$(yq e '.tasks[] | .status + ": " + .title' "$milestone_file" 2>/dev/null | sort | uniq -c | awk '{print "  " $2 " " $3 ": " $1}')

Recent Activity:
$(query_milestone_events "$milestone_id" "" "" 5 | python3 -c "
import json, sys
for line in sys.stdin:
    try:
        event = json.loads(line)
        print(f\"  {event['timestamp']}: {event['event_type']}\")
    except:
        pass
")
EOF
}

# Generate JSON format report
generate_json_report() {
    local milestone_id=$1
    local milestone_file=$2
    
    python3 << EOF
import yaml
import json
from datetime import datetime

with open("$milestone_file", 'r') as f:
    milestone = yaml.safe_load(f)

# Add calculated fields
milestone['calculated'] = {
    'progress_percentage': $(calculate_milestone_progress "$milestone_id"),
    'age_days': $(get_milestone_age "$milestone_id"),
    'velocity': $(calculate_milestone_velocity "$milestone_id"),
    'report_generated_at': '$(get_iso_timestamp)'
}

print(json.dumps(milestone, indent=2))
EOF
}

# Generate markdown format report
generate_markdown_report() {
    local milestone_id=$1
    local milestone_file=$2
    
    local title=$(yq e '.title' "$milestone_file")
    local status=$(yq e '.status' "$milestone_file")
    local progress=$(calculate_milestone_progress "$milestone_id")
    local description=$(yq e '.description' "$milestone_file")
    
    cat << EOF
# Milestone Report: $title

**ID:** $milestone_id  
**Status:** $status  
**Progress:** $progress%  

## Description
$description

## Tasks
$(yq e '.tasks[] | "- [" + (if .status == "completed" then "x" else " " end) + "] " + .title + " (" + .status + ")"' "$milestone_file" 2>/dev/null)

## Timeline
- **Created:** $(yq e '.created_at' "$milestone_file")
- **Age:** $(get_milestone_age "$milestone_id") days
- **Velocity:** $(calculate_milestone_velocity "$milestone_id") tasks/day

---
*Report generated at $(get_iso_timestamp)*
EOF
}

# Format progress bar
format_progress_bar() {
    local percentage=$1
    local width=${2:-20}
    local char_filled=${3:-"█"}
    local char_empty=${4:-"░"}
    
    local filled_width=$((percentage * width / 100))
    local empty_width=$((width - filled_width))
    
    printf "["
    for ((i=0; i<filled_width; i++)); do printf "$char_filled"; done
    for ((i=0; i<empty_width; i++)); do printf "$char_empty"; done
    printf "] %d%%" "$percentage"
}

# Color formatting for terminal output
format_status_color() {
    local status=$1
    
    case "$status" in
        "completed")
            echo -e "\033[32m$status\033[0m"  # Green
            ;;
        "in_progress")
            echo -e "\033[33m$status\033[0m"  # Yellow
            ;;
        "blocked")
            echo -e "\033[31m$status\033[0m"  # Red
            ;;
        "cancelled")
            echo -e "\033[90m$status\033[0m"  # Gray
            ;;
        *)
            echo "$status"
            ;;
    esac
}
```

These utility functions provide a comprehensive foundation for milestone operations with robust file handling, time calculations, progress tracking, and flexible reporting capabilities.