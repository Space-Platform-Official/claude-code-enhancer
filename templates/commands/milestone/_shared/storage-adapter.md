# Storage Abstraction Layer - Enhanced Hybrid Architecture

## Core Abstraction Interface

The storage adapter provides transparent access to milestone data across different backend storage systems, automatically optimizing for scale while maintaining backward compatibility.

### Storage Backend Types

```bash
# Backend Selection Logic
get_optimal_storage_backend() {
    local milestone_count=$(count_active_milestones)
    local concurrent_users=$(count_concurrent_users)
    local project_complexity=$(calculate_project_complexity)
    
    # File-based storage (< 25 milestones, < 5 users)
    if [ "$milestone_count" -lt 25 ] && [ "$concurrent_users" -lt 5 ]; then
        echo "file"
        return 0
    fi
    
    # Hybrid mode (25-100 milestones, 5-20 users)
    if [ "$milestone_count" -lt 100 ] && [ "$concurrent_users" -lt 20 ]; then
        echo "hybrid"
        return 0
    fi
    
    # Database mode (> 100 milestones, > 20 users)
    echo "database"
    return 0
}

# Current backend detection
get_current_storage_backend() {
    if [ -f ".milestones/config/storage-backend.txt" ]; then
        cat ".milestones/config/storage-backend.txt"
    else
        echo "file"  # Default to file-based
    fi
}
```

### Unified Storage Operations

```bash
# Create milestone (storage-agnostic)
create_milestone_record() {
    local milestone_id=$1
    local milestone_data=$2
    local backend=$(get_current_storage_backend)
    
    case "$backend" in
        "file")
            create_milestone_file "$milestone_id" "$milestone_data"
            ;;
        "hybrid")
            create_milestone_hybrid "$milestone_id" "$milestone_data"
            ;;
        "database")
            create_milestone_database "$milestone_id" "$milestone_data"
            ;;
    esac
    
    # Log storage operation
    log_storage_event "milestone_created" "$milestone_id" "$backend"
}

# Read milestone (storage-agnostic)
read_milestone_record() {
    local milestone_id=$1
    local backend=$(get_current_storage_backend)
    
    case "$backend" in
        "file")
            read_milestone_file "$milestone_id"
            ;;
        "hybrid")
            read_milestone_hybrid "$milestone_id"
            ;;
        "database")
            read_milestone_database "$milestone_id"
            ;;
    esac
}

# Update milestone (storage-agnostic with atomic operations)
update_milestone_record() {
    local milestone_id=$1
    local update_data=$2
    local backend=$(get_current_storage_backend)
    
    # Acquire lock for atomic update
    acquire_milestone_lock "$milestone_id"
    
    case "$backend" in
        "file")
            update_milestone_file "$milestone_id" "$update_data"
            ;;
        "hybrid")
            update_milestone_hybrid "$milestone_id" "$update_data"
            ;;
        "database")
            update_milestone_database "$milestone_id" "$update_data"
            ;;
    esac
    
    # Release lock
    release_milestone_lock "$milestone_id"
    
    # Log update operation
    log_storage_event "milestone_updated" "$milestone_id" "$backend"
}

# Delete milestone (storage-agnostic)
delete_milestone_record() {
    local milestone_id=$1
    local backend=$(get_current_storage_backend)
    
    case "$backend" in
        "file")
            delete_milestone_file "$milestone_id"
            ;;
        "hybrid")
            delete_milestone_hybrid "$milestone_id"
            ;;
        "database")
            delete_milestone_database "$milestone_id"
            ;;
    esac
    
    log_storage_event "milestone_deleted" "$milestone_id" "$backend"
}
```

### File-Based Storage Implementation (Existing Enhanced)

```bash
# File storage operations (enhanced from existing system)
create_milestone_file() {
    local milestone_id=$1
    local milestone_data=$2
    
    # Create milestone file with atomic operation
    local temp_file=".milestones/active/${milestone_id}.tmp"
    local final_file=".milestones/active/${milestone_id}.yaml"
    
    echo "$milestone_data" > "$temp_file"
    mv "$temp_file" "$final_file"
    
    # Create event log entry
    echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"event\":\"milestone_created\",\"milestone_id\":\"$milestone_id\",\"backend\":\"file\"}" >> ".milestones/logs/storage-events.jsonl"
}

read_milestone_file() {
    local milestone_id=$1
    local milestone_file=".milestones/active/${milestone_id}.yaml"
    
    if [ -f "$milestone_file" ]; then
        cat "$milestone_file"
    else
        return 1
    fi
}

update_milestone_file() {
    local milestone_id=$1
    local update_data=$2
    
    # Use existing atomic update pattern
    local milestone_file=".milestones/active/${milestone_id}.yaml"
    local temp_file="${milestone_file}.tmp"
    
    echo "$update_data" > "$temp_file"
    mv "$temp_file" "$milestone_file"
}

delete_milestone_file() {
    local milestone_id=$1
    
    # Move to completed directory instead of deletion
    mv ".milestones/active/${milestone_id}.yaml" ".milestones/completed/"
}
```

### Hybrid Storage Implementation (File + SQLite)

```bash
# Hybrid storage: files for data, SQLite for indexing and queries
create_milestone_hybrid() {
    local milestone_id=$1
    local milestone_data=$2
    
    # Store full data in file
    create_milestone_file "$milestone_id" "$milestone_data"
    
    # Extract metadata for database index
    local title=$(echo "$milestone_data" | yq e '.title' -)
    local status=$(echo "$milestone_data" | yq e '.status' -)
    local priority=$(echo "$milestone_data" | yq e '.priority' -)
    local created_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Insert into SQLite index
    sqlite3 ".milestones/index.db" "
        INSERT INTO milestones (id, title, status, priority, created_at, file_path) 
        VALUES ('$milestone_id', '$title', '$status', '$priority', '$created_at', '.milestones/active/${milestone_id}.yaml')
    "
}

read_milestone_hybrid() {
    local milestone_id=$1
    
    # Read from file (full data)
    read_milestone_file "$milestone_id"
}

update_milestone_hybrid() {
    local milestone_id=$1
    local update_data=$2
    
    # Update file
    update_milestone_file "$milestone_id" "$update_data"
    
    # Update database index
    local title=$(echo "$update_data" | yq e '.title' -)
    local status=$(echo "$update_data" | yq e '.status' -)
    local priority=$(echo "$update_data" | yq e '.priority' -)
    local updated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    sqlite3 ".milestones/index.db" "
        UPDATE milestones 
        SET title='$title', status='$status', priority='$priority', updated_at='$updated_at'
        WHERE id='$milestone_id'
    "
}

# Initialize hybrid storage
initialize_hybrid_storage() {
    # Create SQLite index database
    sqlite3 ".milestones/index.db" "
        CREATE TABLE IF NOT EXISTS milestones (
            id TEXT PRIMARY KEY,
            title TEXT,
            status TEXT,
            priority TEXT,
            created_at TEXT,
            updated_at TEXT,
            file_path TEXT
        );
        
        CREATE INDEX IF NOT EXISTS idx_status ON milestones(status);
        CREATE INDEX IF NOT EXISTS idx_priority ON milestones(priority);
        CREATE INDEX IF NOT EXISTS idx_created_at ON milestones(created_at);
    "
}
```

### Database Storage Implementation (PostgreSQL/SQLite)

```bash
# Full database storage for enterprise scale
create_milestone_database() {
    local milestone_id=$1
    local milestone_data=$2
    
    # Convert YAML to JSON for database storage
    local milestone_json=$(echo "$milestone_data" | yq e -o=json -)
    
    # Insert into database
    if [ "$DATABASE_TYPE" = "postgresql" ]; then
        psql "$DATABASE_URL" -c "
            INSERT INTO milestones (id, data, created_at, updated_at) 
            VALUES ('$milestone_id', '$milestone_json', NOW(), NOW())
        "
    else
        # SQLite fallback
        sqlite3 ".milestones/enterprise.db" "
            INSERT INTO milestones (id, data, created_at, updated_at) 
            VALUES ('$milestone_id', '$milestone_json', datetime('now'), datetime('now'))
        "
    fi
}

read_milestone_database() {
    local milestone_id=$1
    
    if [ "$DATABASE_TYPE" = "postgresql" ]; then
        psql "$DATABASE_URL" -t -c "SELECT data FROM milestones WHERE id='$milestone_id'"
    else
        sqlite3 ".milestones/enterprise.db" "SELECT data FROM milestones WHERE id='$milestone_id'"
    fi
}

update_milestone_database() {
    local milestone_id=$1
    local update_data=$2
    
    local milestone_json=$(echo "$update_data" | yq e -o=json -)
    
    if [ "$DATABASE_TYPE" = "postgresql" ]; then
        psql "$DATABASE_URL" -c "
            UPDATE milestones 
            SET data='$milestone_json', updated_at=NOW() 
            WHERE id='$milestone_id'
        "
    else
        sqlite3 ".milestones/enterprise.db" "
            UPDATE milestones 
            SET data='$milestone_json', updated_at=datetime('now') 
            WHERE id='$milestone_id'
        "
    fi
}

# Initialize database storage
initialize_database_storage() {
    if [ "$DATABASE_TYPE" = "postgresql" ]; then
        psql "$DATABASE_URL" -c "
            CREATE TABLE IF NOT EXISTS milestones (
                id TEXT PRIMARY KEY,
                data JSONB,
                created_at TIMESTAMP DEFAULT NOW(),
                updated_at TIMESTAMP DEFAULT NOW()
            );
            
            CREATE INDEX IF NOT EXISTS idx_milestone_status ON milestones USING GIN ((data->>'status'));
            CREATE INDEX IF NOT EXISTS idx_milestone_priority ON milestones USING GIN ((data->>'priority'));
        "
    else
        sqlite3 ".milestones/enterprise.db" "
            CREATE TABLE IF NOT EXISTS milestones (
                id TEXT PRIMARY KEY,
                data TEXT,
                created_at TEXT,
                updated_at TEXT
            );
        "
    fi
}
```

### Query Operations (Scale-Optimized)

```bash
# List milestones (optimized for different backends)
list_milestones() {
    local filter=${1:-"all"}
    local backend=$(get_current_storage_backend)
    
    case "$backend" in
        "file")
            list_milestones_file "$filter"
            ;;
        "hybrid")
            list_milestones_hybrid "$filter"
            ;;
        "database")
            list_milestones_database "$filter"
            ;;
    esac
}

list_milestones_file() {
    local filter=$1
    
    for milestone_file in .milestones/active/*.yaml; do
        if [ -f "$milestone_file" ]; then
            local milestone_id=$(basename "$milestone_file" .yaml)
            local status=$(yq e '.status' "$milestone_file")
            
            if [ "$filter" = "all" ] || [ "$status" = "$filter" ]; then
                echo "$milestone_id"
            fi
        fi
    done
}

list_milestones_hybrid() {
    local filter=$1
    
    if [ "$filter" = "all" ]; then
        sqlite3 ".milestones/index.db" "SELECT id FROM milestones ORDER BY created_at"
    else
        sqlite3 ".milestones/index.db" "SELECT id FROM milestones WHERE status='$filter' ORDER BY created_at"
    fi
}

list_milestones_database() {
    local filter=$1
    
    if [ "$DATABASE_TYPE" = "postgresql" ]; then
        if [ "$filter" = "all" ]; then
            psql "$DATABASE_URL" -t -c "SELECT id FROM milestones ORDER BY created_at"
        else
            psql "$DATABASE_URL" -t -c "SELECT id FROM milestones WHERE data->>'status'='$filter' ORDER BY created_at"
        fi
    else
        if [ "$filter" = "all" ]; then
            sqlite3 ".milestones/enterprise.db" "SELECT id FROM milestones ORDER BY created_at"
        else
            sqlite3 ".milestones/enterprise.db" "SELECT id FROM milestones WHERE json_extract(data, '$.status')='$filter' ORDER BY created_at"
        fi
    fi
}
```

### Advanced Query Operations

```bash
# Complex queries for large-scale operations
search_milestones() {
    local search_term=$1
    local backend=$(get_current_storage_backend)
    
    case "$backend" in
        "file")
            search_milestones_file "$search_term"
            ;;
        "hybrid")
            search_milestones_hybrid "$search_term"
            ;;
        "database")
            search_milestones_database "$search_term"
            ;;
    esac
}

search_milestones_hybrid() {
    local search_term=$1
    
    # Use SQLite FTS for text search
    sqlite3 ".milestones/index.db" "
        SELECT id FROM milestones 
        WHERE title LIKE '%$search_term%' 
        ORDER BY created_at DESC
    "
}

# Milestone analytics (performance optimized)
get_milestone_analytics() {
    local backend=$(get_current_storage_backend)
    
    case "$backend" in
        "file")
            get_analytics_file
            ;;
        "hybrid")
            get_analytics_hybrid
            ;;
        "database")
            get_analytics_database
            ;;
    esac
}

get_analytics_hybrid() {
    # Use SQLite for efficient aggregations
    sqlite3 ".milestones/index.db" "
        SELECT 
            status,
            COUNT(*) as count,
            MIN(created_at) as oldest,
            MAX(created_at) as newest
        FROM milestones 
        GROUP BY status
    "
}
```

### Storage Event Logging

```bash
# Unified event logging across all backends
log_storage_event() {
    local event_type=$1
    local milestone_id=$2
    local backend=$3
    local details=${4:-"{}"}
    
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local log_entry="{\"timestamp\":\"$timestamp\",\"event\":\"$event_type\",\"milestone_id\":\"$milestone_id\",\"backend\":\"$backend\",\"details\":$details}"
    
    echo "$log_entry" >> ".milestones/logs/storage-events.jsonl"
}

# Performance monitoring
monitor_storage_performance() {
    local operation=$1
    local start_time=$(date +%s%N)
    
    # Execute operation
    "$@"
    local result=$?
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
    
    # Log performance metrics
    log_storage_event "performance_metric" "system" "$(get_current_storage_backend)" "{\"operation\":\"$operation\",\"duration_ms\":$duration,\"success\":$([ $result -eq 0 ] && echo "true" || echo "false")}"
    
    return $result
}
```

### Storage Initialization and Configuration

```bash
# Initialize storage system based on configuration
initialize_storage_system() {
    local backend=$(get_optimal_storage_backend)
    
    echo "Initializing storage system with backend: $backend"
    
    # Create base directories
    mkdir -p ".milestones/active"
    mkdir -p ".milestones/completed"
    mkdir -p ".milestones/logs"
    mkdir -p ".milestones/config"
    
    case "$backend" in
        "file")
            echo "file" > ".milestones/config/storage-backend.txt"
            ;;
        "hybrid")
            initialize_hybrid_storage
            echo "hybrid" > ".milestones/config/storage-backend.txt"
            ;;
        "database")
            initialize_database_storage
            echo "database" > ".milestones/config/storage-backend.txt"
            ;;
    esac
    
    log_storage_event "storage_initialized" "system" "$backend"
}

# Configuration management
get_storage_config() {
    local config_file=".milestones/config/storage-config.yaml"
    
    if [ ! -f "$config_file" ]; then
        # Create default configuration
        cat > "$config_file" << EOF
storage:
  backend: "auto"  # auto, file, hybrid, database
  thresholds:
    milestone_count:
      file_to_hybrid: 25
      hybrid_to_database: 100
    concurrent_users:
      file_to_hybrid: 5
      hybrid_to_database: 20
  
  database:
    type: "sqlite"  # sqlite, postgresql
    url: ""
    pool_size: 10
    
  performance:
    cache_enabled: true
    cache_ttl: 300
    query_timeout: 30
    
  migration:
    auto_migrate: true
    backup_before_migration: true
    rollback_on_failure: true
EOF
    fi
    
    cat "$config_file"
}
```

### Locking and Concurrency

```bash
# Enhanced locking for concurrent access
acquire_milestone_lock() {
    local milestone_id=$1
    local lock_file=".milestones/locks/${milestone_id}.lock"
    local timeout=30
    local waited=0
    
    mkdir -p ".milestones/locks"
    
    while [ $waited -lt $timeout ]; do
        if mkdir "$lock_file" 2>/dev/null; then
            echo $$ > "$lock_file/pid"
            echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$lock_file/timestamp"
            return 0
        fi
        
        # Check if lock is stale (older than 10 minutes)
        if [ -f "$lock_file/timestamp" ]; then
            local lock_time=$(cat "$lock_file/timestamp")
            local current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
            local age_seconds=$(( $(date -d "$current_time" +%s) - $(date -d "$lock_time" +%s) ))
            
            if [ $age_seconds -gt 600 ]; then
                echo "Cleaning stale lock for $milestone_id"
                rm -rf "$lock_file"
                continue
            fi
        fi
        
        sleep 1
        ((waited++))
    done
    
    echo "Failed to acquire lock for $milestone_id after $timeout seconds"
    return 1
}

release_milestone_lock() {
    local milestone_id=$1
    local lock_file=".milestones/locks/${milestone_id}.lock"
    
    if [ -d "$lock_file" ]; then
        rm -rf "$lock_file"
    fi
}
```

This storage abstraction layer provides the foundation for seamless scaling from file-based to database-backed storage while maintaining full backward compatibility with existing milestone workflows.