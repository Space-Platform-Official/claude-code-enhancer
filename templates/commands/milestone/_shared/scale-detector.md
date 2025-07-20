# Scale Detection Engine - Automatic Backend Optimization

## Core Scale Detection Interface

The scale detection engine continuously monitors milestone usage patterns and automatically recommends optimal storage backend configurations for maximum performance.

### Usage Pattern Monitoring

```bash
# Count active milestones across all storage backends
count_active_milestones() {
    local backend=$(get_current_storage_backend)
    
    case "$backend" in
        "file")
            find .milestones/active -name "*.yaml" -type f | wc -l
            ;;
        "hybrid")
            sqlite3 ".milestones/index.db" "SELECT COUNT(*) FROM milestones WHERE file_path LIKE '%active%'"
            ;;
        "database")
            if [ "$DATABASE_TYPE" = "postgresql" ]; then
                psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM milestones WHERE data->>'status' != 'archived'"
            else
                sqlite3 ".milestones/enterprise.db" "SELECT COUNT(*) FROM milestones WHERE json_extract(data, '$.status') != 'archived'"
            fi
            ;;
    esac
}

# Count concurrent users (based on recent activity in event logs)
count_concurrent_users() {
    local since_minutes=${1:-60}  # Look back 60 minutes by default
    local since_timestamp=$(date -d "$since_minutes minutes ago" -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Parse unique users from storage events in the last hour
    if [ -f ".milestones/logs/storage-events.jsonl" ]; then
        awk -v since="$since_timestamp" '
            BEGIN { users_count = 0; }
            {
                if ($0 ~ /"timestamp":"[^"]*"/) {
                    match($0, /"timestamp":"([^"]*)"/, timestamp_array);
                    if (timestamp_array[1] >= since) {
                        if ($0 ~ /"user":"[^"]*"/) {
                            match($0, /"user":"([^"]*)"/, user_array);
                            users[user_array[1]] = 1;
                        }
                    }
                }
            }
            END { 
                for (user in users) users_count++;
                print users_count;
            }
        ' ".milestones/logs/storage-events.jsonl"
    else
        echo "1"  # Default to single user if no logs exist
    fi
}

# Calculate project complexity score
calculate_project_complexity() {
    local complexity_score=0
    local milestone_count=$(count_active_milestones)
    
    # Base complexity from milestone count
    complexity_score=$((complexity_score + milestone_count))
    
    # Additional complexity from kiro workflows
    local kiro_milestones=$(count_kiro_enabled_milestones)
    complexity_score=$((complexity_score + kiro_milestones * 2))
    
    # Additional complexity from dependencies
    local dependency_count=$(count_milestone_dependencies)
    complexity_score=$((complexity_score + dependency_count))
    
    # Additional complexity from team size
    local team_size=$(count_concurrent_users 1440)  # 24 hours
    complexity_score=$((complexity_score + team_size * 3))
    
    echo "$complexity_score"
}

# Count milestones with kiro workflows enabled
count_kiro_enabled_milestones() {
    local backend=$(get_current_storage_backend)
    local count=0
    
    case "$backend" in
        "file")
            for milestone_file in .milestones/active/*.yaml; do
                if [ -f "$milestone_file" ]; then
                    local kiro_enabled=$(yq e '.tasks[].kiro_workflow.enabled // false' "$milestone_file" | grep -c "true")
                    count=$((count + kiro_enabled))
                fi
            done
            ;;
        "hybrid")
            # Query files for kiro workflow detection
            for milestone_id in $(sqlite3 ".milestones/index.db" "SELECT id FROM milestones"); do
                local milestone_file=".milestones/active/${milestone_id}.yaml"
                if [ -f "$milestone_file" ]; then
                    local kiro_enabled=$(yq e '.tasks[].kiro_workflow.enabled // false' "$milestone_file" | grep -c "true")
                    count=$((count + kiro_enabled))
                fi
            done
            ;;
        "database")
            # Complex JSON query for kiro workflow detection
            if [ "$DATABASE_TYPE" = "postgresql" ]; then
                count=$(psql "$DATABASE_URL" -t -c "
                    SELECT COUNT(*) FROM milestones 
                    WHERE jsonb_path_exists(data, '$.tasks[*].kiro_workflow.enabled ? (@ == true)')
                ")
            else
                # SQLite JSON query (simplified)
                count=$(sqlite3 ".milestones/enterprise.db" "
                    SELECT COUNT(*) FROM milestones 
                    WHERE json_extract(data, '$.tasks') IS NOT NULL
                ")
            fi
            ;;
    esac
    
    echo "$count"
}

# Count total dependencies across all milestones
count_milestone_dependencies() {
    local backend=$(get_current_storage_backend)
    local count=0
    
    case "$backend" in
        "file")
            for milestone_file in .milestones/active/*.yaml; do
                if [ -f "$milestone_file" ]; then
                    local deps=$(yq e '.dependencies.requires[] // empty' "$milestone_file" | wc -l)
                    count=$((count + deps))
                fi
            done
            ;;
        "hybrid")
            for milestone_id in $(sqlite3 ".milestones/index.db" "SELECT id FROM milestones"); do
                local milestone_file=".milestones/active/${milestone_id}.yaml"
                if [ -f "$milestone_file" ]; then
                    local deps=$(yq e '.dependencies.requires[] // empty' "$milestone_file" | wc -l)
                    count=$((count + deps))
                fi
            done
            ;;
        "database")
            if [ "$DATABASE_TYPE" = "postgresql" ]; then
                count=$(psql "$DATABASE_URL" -t -c "
                    SELECT COALESCE(SUM(jsonb_array_length(data->'dependencies'->'requires')), 0) 
                    FROM milestones 
                    WHERE data->'dependencies'->'requires' IS NOT NULL
                ")
            else
                count=$(sqlite3 ".milestones/enterprise.db" "
                    SELECT COUNT(*) FROM milestones 
                    WHERE json_extract(data, '$.dependencies.requires') IS NOT NULL
                ")
            fi
            ;;
    esac
    
    echo "$count"
}
```

### Performance Metrics Collection

```bash
# Collect performance metrics for scale detection
collect_performance_metrics() {
    local metrics_file=".milestones/logs/performance-metrics.jsonl"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Storage operation metrics
    local avg_read_time=$(get_average_operation_time "read" 100)
    local avg_write_time=$(get_average_operation_time "write" 100)
    local avg_query_time=$(get_average_operation_time "query" 100)
    
    # System resource metrics
    local cpu_usage=$(get_cpu_usage)
    local memory_usage=$(get_memory_usage)
    local disk_io=$(get_disk_io_usage)
    
    # Milestone-specific metrics
    local milestone_count=$(count_active_milestones)
    local concurrent_users=$(count_concurrent_users)
    local complexity_score=$(calculate_project_complexity)
    
    # Current backend performance
    local current_backend=$(get_current_storage_backend)
    
    # Create metrics entry
    local metrics_entry=$(cat << EOF
{
  "timestamp": "$timestamp",
  "backend": "$current_backend",
  "performance": {
    "avg_read_time_ms": $avg_read_time,
    "avg_write_time_ms": $avg_write_time,
    "avg_query_time_ms": $avg_query_time
  },
  "system": {
    "cpu_usage_percent": $cpu_usage,
    "memory_usage_percent": $memory_usage,
    "disk_io_percent": $disk_io
  },
  "scale": {
    "milestone_count": $milestone_count,
    "concurrent_users": $concurrent_users,
    "complexity_score": $complexity_score
  }
}
EOF
)
    
    echo "$metrics_entry" >> "$metrics_file"
}

# Get average operation time from storage events
get_average_operation_time() {
    local operation_type=$1
    local sample_size=${2:-50}
    
    if [ -f ".milestones/logs/storage-events.jsonl" ]; then
        grep "\"operation\":\"$operation_type\"" ".milestones/logs/storage-events.jsonl" | \
        tail -n "$sample_size" | \
        jq -r '.details.duration_ms // 0' | \
        awk '{ sum += $1; count++ } END { if (count > 0) print int(sum/count); else print 0 }'
    else
        echo "0"
    fi
}

# System resource monitoring
get_cpu_usage() {
    # Get CPU usage percentage (average over 1 second)
    top -l 1 -s 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//' | cut -d. -f1
}

get_memory_usage() {
    # Get memory usage percentage
    vm_stat | awk '
        /Pages free/ { free = $3 }
        /Pages active/ { active = $3 }
        /Pages inactive/ { inactive = $3 }
        /Pages wired/ { wired = $3 }
        END {
            total = free + active + inactive + wired
            used = active + inactive + wired
            if (total > 0) print int((used / total) * 100)
            else print 0
        }
    '
}

get_disk_io_usage() {
    # Simple disk I/O metric (placeholder - would need iostat or similar)
    echo "0"  # Default to 0 for now
}
```

### Scale Detection Logic

```bash
# Main scale detection function
detect_optimal_scale() {
    local current_backend=$(get_current_storage_backend)
    local milestone_count=$(count_active_milestones)
    local concurrent_users=$(count_concurrent_users)
    local complexity_score=$(calculate_project_complexity)
    
    # Get configuration thresholds
    local config=$(get_storage_config)
    local file_to_hybrid_milestones=$(echo "$config" | yq e '.storage.thresholds.milestone_count.file_to_hybrid' -)
    local hybrid_to_database_milestones=$(echo "$config" | yq e '.storage.thresholds.milestone_count.hybrid_to_database' -)
    local file_to_hybrid_users=$(echo "$config" | yq e '.storage.thresholds.concurrent_users.file_to_hybrid' -)
    local hybrid_to_database_users=$(echo "$config" | yq e '.storage.thresholds.concurrent_users.hybrid_to_database' -)
    
    # Determine optimal backend
    local optimal_backend="file"
    
    # Check for database scale requirements
    if [ "$milestone_count" -ge "$hybrid_to_database_milestones" ] || [ "$concurrent_users" -ge "$hybrid_to_database_users" ]; then
        optimal_backend="database"
    # Check for hybrid scale requirements  
    elif [ "$milestone_count" -ge "$file_to_hybrid_milestones" ] || [ "$concurrent_users" -ge "$file_to_hybrid_users" ]; then
        optimal_backend="hybrid"
    fi
    
    # Performance-based overrides
    local avg_query_time=$(get_average_operation_time "query" 10)
    if [ "$avg_query_time" -gt 1000 ] && [ "$current_backend" != "database" ]; then
        optimal_backend="database"  # Force database for slow queries
    elif [ "$avg_query_time" -gt 500 ] && [ "$current_backend" = "file" ]; then
        optimal_backend="hybrid"   # Force hybrid for moderately slow queries
    fi
    
    echo "$optimal_backend"
}

# Check if scale migration is recommended
check_scale_migration_needed() {
    local current_backend=$(get_current_storage_backend)
    local optimal_backend=$(detect_optimal_scale)
    
    if [ "$current_backend" != "$optimal_backend" ]; then
        # Additional validation to prevent unnecessary migrations
        local migration_confidence=$(calculate_migration_confidence "$current_backend" "$optimal_backend")
        
        if [ "$migration_confidence" -ge 80 ]; then
            echo "recommended"
            return 0
        else
            echo "monitoring"
            return 1
        fi
    else
        echo "optimal"
        return 2
    fi
}

# Calculate confidence score for migration recommendation
calculate_migration_confidence() {
    local current_backend=$1
    local optimal_backend=$2
    local confidence=0
    
    # Time-based confidence (longer in current state = higher confidence)
    local backend_age_hours=$(get_backend_age_hours "$current_backend")
    if [ "$backend_age_hours" -gt 24 ]; then
        confidence=$((confidence + 30))
    elif [ "$backend_age_hours" -gt 2 ]; then
        confidence=$((confidence + 15))
    fi
    
    # Threshold confidence (further over threshold = higher confidence)
    local milestone_count=$(count_active_milestones)
    local config=$(get_storage_config)
    
    case "$optimal_backend" in
        "hybrid")
            local threshold=$(echo "$config" | yq e '.storage.thresholds.milestone_count.file_to_hybrid' -)
            local overage=$((milestone_count - threshold))
            if [ "$overage" -gt 10 ]; then
                confidence=$((confidence + 40))
            elif [ "$overage" -gt 5 ]; then
                confidence=$((confidence + 25))
            elif [ "$overage" -gt 0 ]; then
                confidence=$((confidence + 15))
            fi
            ;;
        "database")
            local threshold=$(echo "$config" | yq e '.storage.thresholds.milestone_count.hybrid_to_database' -)
            local overage=$((milestone_count - threshold))
            if [ "$overage" -gt 25 ]; then
                confidence=$((confidence + 40))
            elif [ "$overage" -gt 10 ]; then
                confidence=$((confidence + 25))
            elif [ "$overage" -gt 0 ]; then
                confidence=$((confidence + 15))
            fi
            ;;
    esac
    
    # Performance confidence (consistent slow performance = higher confidence)
    local performance_trend=$(get_performance_trend)
    case "$performance_trend" in
        "degrading")
            confidence=$((confidence + 30))
            ;;
        "stable_slow")
            confidence=$((confidence + 20))
            ;;
        "stable_fast")
            confidence=$((confidence - 10))
            ;;
    esac
    
    echo "$confidence"
}

# Get how long current backend has been in use
get_backend_age_hours() {
    local backend=$1
    local backend_file=".milestones/config/storage-backend.txt"
    
    if [ -f "$backend_file" ]; then
        local backend_age_seconds=$(( $(date +%s) - $(stat -f %m "$backend_file") ))
        echo $((backend_age_seconds / 3600))
    else
        echo "0"
    fi
}

# Analyze performance trends
get_performance_trend() {
    local metrics_file=".milestones/logs/performance-metrics.jsonl"
    
    if [ ! -f "$metrics_file" ]; then
        echo "unknown"
        return
    fi
    
    # Get last 10 metrics entries
    local recent_metrics=$(tail -n 10 "$metrics_file")
    
    # Calculate average query time for first half vs second half
    local first_half_avg=$(echo "$recent_metrics" | head -n 5 | jq -r '.performance.avg_query_time_ms' | awk '{sum += $1; count++} END {if (count > 0) print sum/count; else print 0}')
    local second_half_avg=$(echo "$recent_metrics" | tail -n 5 | jq -r '.performance.avg_query_time_ms' | awk '{sum += $1; count++} END {if (count > 0) print sum/count; else print 0}')
    
    # Determine trend
    if [ "$(echo "$second_half_avg > $first_half_avg * 1.2" | bc -l)" = "1" ]; then
        echo "degrading"
    elif [ "$(echo "$second_half_avg > 500" | bc -l)" = "1" ]; then
        echo "stable_slow"
    elif [ "$(echo "$second_half_avg < 100" | bc -l)" = "1" ]; then
        echo "stable_fast"
    else
        echo "stable_normal"
    fi
}
```

### Migration Triggering and Coordination

```bash
# Trigger scale migration if needed
trigger_scale_migration() {
    local migration_status=$(check_scale_migration_needed)
    local current_backend=$(get_current_storage_backend)
    local optimal_backend=$(detect_optimal_scale)
    
    case "$migration_status" in
        "recommended")
            echo "🔄 Scale migration recommended: $current_backend → $optimal_backend"
            
            # Check if auto-migration is enabled
            local auto_migrate=$(get_storage_config | yq e '.storage.migration.auto_migrate' -)
            
            if [ "$auto_migrate" = "true" ]; then
                echo "⚡ Initiating automatic scale migration..."
                initiate_storage_migration "$current_backend" "$optimal_backend"
            else
                echo "📋 Manual migration required. Run: /milestone/migrate $optimal_backend"
                create_migration_notification "$current_backend" "$optimal_backend"
            fi
            ;;
        "monitoring")
            echo "👀 Monitoring scale patterns. Migration may be needed soon."
            log_scale_event "migration_monitoring" "$current_backend" "$optimal_backend"
            ;;
        "optimal")
            echo "✅ Current scale configuration is optimal"
            ;;
    esac
}

# Create migration notification for manual review
create_migration_notification() {
    local current_backend=$1
    local optimal_backend=$2
    local notification_file=".milestones/config/migration-notification.yaml"
    
    cat > "$notification_file" << EOF
migration_recommendation:
  timestamp: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  current_backend: "$current_backend"
  recommended_backend: "$optimal_backend"
  reason: "Scale thresholds exceeded"
  confidence: $(calculate_migration_confidence "$current_backend" "$optimal_backend")
  
metrics:
  milestone_count: $(count_active_milestones)
  concurrent_users: $(count_concurrent_users)
  complexity_score: $(calculate_project_complexity)
  avg_query_time_ms: $(get_average_operation_time "query" 10)
  
actions:
  manual_command: "/milestone/migrate $optimal_backend"
  auto_enable: "Update storage-config.yaml: migration.auto_migrate = true"
  
risk_assessment:
  migration_time_estimate: "5-15 minutes"
  downtime_required: false
  rollback_available: true
EOF

    echo "📄 Migration notification created: $notification_file"
}

# Periodic scale monitoring (called by monitoring agents)
monitor_scale_continuously() {
    local monitoring_interval=${1:-300}  # Default 5 minutes
    
    while true; do
        echo "🔍 Performing scale detection analysis..."
        
        # Collect current metrics
        collect_performance_metrics
        
        # Check if migration is needed
        trigger_scale_migration
        
        # Log scale status
        log_scale_status
        
        # Wait for next monitoring cycle
        sleep "$monitoring_interval"
    done
}

# Scale event logging
log_scale_event() {
    local event_type=$1
    local current_backend=$2
    local optimal_backend=${3:-""}
    local details=${4:-"{}"}
    
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local log_entry="{\"timestamp\":\"$timestamp\",\"event\":\"$event_type\",\"current_backend\":\"$current_backend\",\"optimal_backend\":\"$optimal_backend\",\"details\":$details}"
    
    echo "$log_entry" >> ".milestones/logs/scale-events.jsonl"
}

# Comprehensive scale status logging
log_scale_status() {
    local current_backend=$(get_current_storage_backend)
    local optimal_backend=$(detect_optimal_scale)
    local milestone_count=$(count_active_milestones)
    local concurrent_users=$(count_concurrent_users)
    local complexity_score=$(calculate_project_complexity)
    local avg_query_time=$(get_average_operation_time "query" 10)
    
    local status_details=$(cat << EOF
{
  "milestone_count": $milestone_count,
  "concurrent_users": $concurrent_users,
  "complexity_score": $complexity_score,
  "avg_query_time_ms": $avg_query_time,
  "migration_confidence": $(calculate_migration_confidence "$current_backend" "$optimal_backend")
}
EOF
)
    
    log_scale_event "scale_status" "$current_backend" "$optimal_backend" "$status_details"
}
```

### Scale Detection Dashboard

```bash
# Display scale detection dashboard
show_scale_dashboard() {
    local current_backend=$(get_current_storage_backend)
    local optimal_backend=$(detect_optimal_scale)
    local milestone_count=$(count_active_milestones)
    local concurrent_users=$(count_concurrent_users)
    local complexity_score=$(calculate_project_complexity)
    
    echo "=== MILESTONE SCALE DETECTION DASHBOARD ==="
    echo ""
    echo "Current Storage Backend: $current_backend"
    echo "Optimal Backend: $optimal_backend"
    
    if [ "$current_backend" != "$optimal_backend" ]; then
        echo "🔄 Migration Status: RECOMMENDED ($current_backend → $optimal_backend)"
        local confidence=$(calculate_migration_confidence "$current_backend" "$optimal_backend")
        echo "Migration Confidence: $confidence%"
    else
        echo "✅ Migration Status: OPTIMAL"
    fi
    
    echo ""
    echo "SCALE METRICS:"
    echo "├── Active Milestones: $milestone_count"
    echo "├── Concurrent Users: $concurrent_users (last hour)"
    echo "├── Complexity Score: $complexity_score"
    echo "└── Kiro Workflows: $(count_kiro_enabled_milestones)"
    
    echo ""
    echo "PERFORMANCE METRICS:"
    local avg_read=$(get_average_operation_time "read" 10)
    local avg_write=$(get_average_operation_time "write" 10)
    local avg_query=$(get_average_operation_time "query" 10)
    echo "├── Avg Read Time: ${avg_read}ms"
    echo "├── Avg Write Time: ${avg_write}ms"
    echo "└── Avg Query Time: ${avg_query}ms"
    
    echo ""
    echo "SCALE THRESHOLDS:"
    local config=$(get_storage_config)
    local file_to_hybrid=$(echo "$config" | yq e '.storage.thresholds.milestone_count.file_to_hybrid' -)
    local hybrid_to_database=$(echo "$config" | yq e '.storage.thresholds.milestone_count.hybrid_to_database' -)
    echo "├── File → Hybrid: $file_to_hybrid milestones"
    echo "└── Hybrid → Database: $hybrid_to_database milestones"
    
    echo ""
    echo "RECENT SCALE EVENTS:"
    if [ -f ".milestones/logs/scale-events.jsonl" ]; then
        tail -3 ".milestones/logs/scale-events.jsonl" | jq -r '.timestamp + " " + .event + ": " + .current_backend + " → " + .optimal_backend'
    else
        echo "No scale events recorded"
    fi
    
    echo "================================="
}

# Quick scale status check
get_scale_status() {
    local current_backend=$(get_current_storage_backend)
    local optimal_backend=$(detect_optimal_scale)
    local milestone_count=$(count_active_milestones)
    
    if [ "$current_backend" = "$optimal_backend" ]; then
        echo "optimal"
    else
        local confidence=$(calculate_migration_confidence "$current_backend" "$optimal_backend")
        if [ "$confidence" -ge 80 ]; then
            echo "migration_recommended"
        else
            echo "monitoring"
        fi
    fi
}
```

### Integration with Storage Adapter

```bash
# Enhanced helper functions for storage adapter
count_active_milestones() {
    # This function is called by storage adapter's get_optimal_storage_backend()
    local backend=$(get_current_storage_backend)
    
    case "$backend" in
        "file")
            find .milestones/active -name "*.yaml" -type f 2>/dev/null | wc -l
            ;;
        "hybrid")
            if [ -f ".milestones/index.db" ]; then
                sqlite3 ".milestones/index.db" "SELECT COUNT(*) FROM milestones WHERE file_path LIKE '%active%'" 2>/dev/null || echo "0"
            else
                find .milestones/active -name "*.yaml" -type f 2>/dev/null | wc -l
            fi
            ;;
        "database")
            if [ "$DATABASE_TYPE" = "postgresql" ] && [ -n "$DATABASE_URL" ]; then
                psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM milestones WHERE data->>'status' != 'archived'" 2>/dev/null || echo "0"
            elif [ -f ".milestones/enterprise.db" ]; then
                sqlite3 ".milestones/enterprise.db" "SELECT COUNT(*) FROM milestones WHERE json_extract(data, '$.status') != 'archived'" 2>/dev/null || echo "0"
            else
                echo "0"
            fi
            ;;
        *)
            echo "0"
            ;;
    esac
}

# Initialize scale detection on storage system initialization
initialize_scale_detection() {
    echo "🔍 Initializing scale detection system..."
    
    # Create scale detection directories
    mkdir -p ".milestones/logs"
    mkdir -p ".milestones/config"
    
    # Create initial performance baseline
    collect_performance_metrics
    
    # Log initialization
    log_scale_event "scale_detection_initialized" "$(get_current_storage_backend)"
    
    echo "✅ Scale detection system initialized"
}
```

This scale detection engine works seamlessly with the storage abstraction layer to provide intelligent, automatic backend optimization based on real usage patterns and performance metrics.