# Shared Storage System Internals

## Overview

The shared storage system provides a unified abstraction layer for data persistence across all Claude Code commands. It automatically scales from simple file-based storage to enterprise database solutions based on project complexity and team size.

## Storage Architecture

### **Three-Tier Storage Strategy**

```
File Backend (Simple) → Hybrid Backend (Teams) → Database Backend (Enterprise)
        ↓                       ↓                        ↓
     1-25 items            25-100 items             100+ items
     <5 users              5-20 users               20+ users
     YAML files            YAML + SQLite            Full SQLite
```

### **Storage Abstraction Layer**

```bash
# Universal storage interface
storage_interface() {
    create_record()      # Create new record
    read_record()        # Read existing record
    update_record()      # Update existing record
    delete_record()      # Delete record
    list_records()       # List all records
    search_records()     # Search records
    backup_records()     # Create backup
    restore_records()    # Restore from backup
}
```

## Backend Implementations

### **File Backend**

**Best for**: Personal projects, learning, quick prototypes
**Storage**: YAML files with JSONL event logs
**Performance**: O(1) for single records, O(n) for searches

```bash
# File backend implementation
file_backend_create() {
    local record_type=$1
    local record_id=$2
    local record_data=$3
    
    local storage_dir=".claude/storage/$record_type"
    mkdir -p "$storage_dir"
    
    echo "$record_data" > "$storage_dir/$record_id.yaml"
    log_storage_event "create" "$record_type" "$record_id"
}

file_backend_read() {
    local record_type=$1
    local record_id=$2
    
    local file_path=".claude/storage/$record_type/$record_id.yaml"
    if [ -f "$file_path" ]; then
        cat "$file_path"
    else
        return 1
    fi
}
```

**File Structure:**
```
.claude/storage/
├── milestones/
│   ├── milestone-001.yaml
│   └── milestone-002.yaml
├── tasks/
│   ├── task-001.yaml
│   └── task-002.yaml
├── logs/
│   ├── storage-events.jsonl
│   └── performance-metrics.jsonl
└── config/
    └── backend-config.yaml
```

### **Hybrid Backend**

**Best for**: Team projects, moderate complexity, coordination needs
**Storage**: YAML files + SQLite index for performance
**Performance**: O(1) for indexed queries, O(log n) for complex searches

```bash
# Hybrid backend with SQLite index
hybrid_backend_create() {
    local record_type=$1
    local record_id=$2
    local record_data=$3
    
    # Store in file backend
    file_backend_create "$record_type" "$record_id" "$record_data"
    
    # Update SQLite index
    update_search_index "$record_type" "$record_id" "$record_data"
}

update_search_index() {
    local record_type=$1
    local record_id=$2
    local record_data=$3
    
    sqlite3 ".claude/storage/index.db" <<EOF
INSERT OR REPLACE INTO ${record_type}_index 
(id, title, status, created_at, updated_at, searchable_text)
VALUES (
    '$record_id',
    '$(echo "$record_data" | yq e '.title' -)',
    '$(echo "$record_data" | yq e '.status' -)',
    '$(date -u +%Y-%m-%dT%H:%M:%SZ)',
    '$(date -u +%Y-%m-%dT%H:%M:%SZ)',
    '$(echo "$record_data" | yq e 'to_entries | map(.value) | join(" ")' -)'
);
EOF
}
```

**Hybrid Structure:**
```
.claude/storage/
├── [File Backend Structure]    # All file backend files
├── database/
│   ├── index.db               # SQLite search index
│   ├── cache.db               # Query result cache
│   └── schema.sql             # Database schema
├── performance/
│   ├── query-metrics.jsonl    # Query performance data
│   └── cache-stats.jsonl      # Cache hit/miss statistics
└── migration/
    ├── migration-log.jsonl     # Migration history
    └── rollback-data/          # Rollback snapshots
```

### **Database Backend**

**Best for**: Enterprise projects, large teams, advanced analytics
**Storage**: Full SQLite database with normalized schema
**Performance**: O(log n) for all operations, optimized for complex queries

```bash
# Full database backend
database_backend_create() {
    local record_type=$1
    local record_id=$2
    local record_data=$3
    
    sqlite3 ".claude/storage/primary.db" <<EOF
INSERT INTO $record_type (
    id, data, created_at, updated_at
) VALUES (
    '$record_id',
    '$record_data',
    '$(date -u +%Y-%m-%dT%H:%M:%SZ)',
    '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
);
EOF
    
    # Update analytics
    update_analytics_tables "$record_type" "$record_id" "$record_data"
}

update_analytics_tables() {
    local record_type=$1
    local record_id=$2
    local record_data=$3
    
    # Extract analytics data and update reporting tables
    sqlite3 ".claude/storage/analytics.db" <<EOF
INSERT INTO ${record_type}_analytics 
SELECT 
    '$record_id' as record_id,
    COUNT(*) as total_records,
    AVG(completion_time) as avg_completion,
    datetime('now') as updated_at
FROM $record_type;
EOF
}
```

**Database Structure:**
```
.claude/storage/
├── config/
│   └── database-config.yaml   # Database configuration
├── database/
│   ├── primary.db            # Main application data
│   ├── analytics.db          # Analytics and reporting
│   ├── audit.db              # Audit trail and compliance
│   └── backups/              # Automated backup storage
├── web-interface/
│   ├── dashboard.html        # Web dashboard
│   ├── api/                  # REST API endpoints
│   └── assets/               # Static web assets
└── logs/
    ├── query-performance.jsonl
    ├── security-events.jsonl
    └── system-health.jsonl
```

## Auto-Scaling and Migration

### **Scale Detection Logic**

```bash
# Determine optimal storage backend
get_optimal_storage_backend() {
    local record_count=$(count_total_records)
    local user_count=$(get_active_user_count)
    local query_complexity=$(analyze_query_patterns)
    
    # Decision matrix
    if [ "$record_count" -lt 25 ] && [ "$user_count" -lt 5 ]; then
        echo "file"
    elif [ "$record_count" -lt 100 ] && [ "$user_count" -lt 20 ]; then
        echo "hybrid"
    else
        echo "database"
    fi
}

# Trigger automatic migration
trigger_auto_migration() {
    local current_backend=$(get_current_backend)
    local optimal_backend=$(get_optimal_storage_backend)
    
    if [ "$current_backend" != "$optimal_backend" ]; then
        echo "🔄 Auto-migration triggered: $current_backend → $optimal_backend"
        
        # Create backup before migration
        create_migration_backup "$current_backend"
        
        # Perform migration
        migrate_storage_backend "$current_backend" "$optimal_backend"
        
        # Validate migration success
        validate_migration_integrity "$optimal_backend"
    fi
}
```

### **Zero-Downtime Migration Process**

```bash
# Safe migration with rollback capability
migrate_storage_backend() {
    local from_backend=$1
    local to_backend=$2
    local backup_id="migration-$(date +%Y%m%d-%H%M%S)"
    
    echo "🚀 Starting migration: $from_backend → $to_backend"
    
    # Phase 1: Validation and backup
    validate_current_data "$from_backend"
    create_full_backup "$backup_id"
    
    # Phase 2: Initialize target backend
    initialize_backend "$to_backend"
    
    # Phase 3: Data migration
    migrate_data "$from_backend" "$to_backend"
    
    # Phase 4: Validation
    if validate_migrated_data "$to_backend"; then
        # Phase 5: Switch active backend
        switch_active_backend "$to_backend"
        
        # Phase 6: Cleanup (optional)
        schedule_cleanup "$from_backend" "$backup_id"
        
        echo "✅ Migration completed successfully"
    else
        # Rollback on failure
        echo "❌ Migration failed, rolling back..."
        rollback_migration "$from_backend" "$backup_id"
    fi
}
```

### **Rollback Capability**

```bash
# Safe rollback to previous backend
rollback_migration() {
    local original_backend=$1
    local backup_id=$2
    
    echo "🔄 Rolling back to $original_backend (backup: $backup_id)"
    
    # Stop current backend
    stop_backend_services
    
    # Restore from backup
    restore_from_backup "$backup_id"
    
    # Switch back to original backend
    switch_active_backend "$original_backend"
    
    # Validate rollback
    validate_rollback_integrity "$original_backend"
    
    echo "✅ Rollback completed"
}
```

## Performance Optimization

### **Caching Strategy**

```bash
# Multi-level cache implementation
cache_strategy() {
    # L1: Memory cache (hot data, <1s TTL)
    memory_cache_get() { ... }
    memory_cache_set() { ... }
    
    # L2: File cache (warm data, <10s TTL)
    file_cache_get() { ... }
    file_cache_set() { ... }
    
    # L3: Database cache (cold data, <60s TTL)
    db_cache_get() { ... }
    db_cache_set() { ... }
}

# Intelligent cache with automatic invalidation
get_record_with_cache() {
    local record_type=$1
    local record_id=$2
    
    # Try L1 cache first
    local cached_data=$(memory_cache_get "$record_type:$record_id")
    if [ -n "$cached_data" ]; then
        echo "$cached_data"
        return 0
    fi
    
    # Try L2 cache
    cached_data=$(file_cache_get "$record_type:$record_id")
    if [ -n "$cached_data" ]; then
        memory_cache_set "$record_type:$record_id" "$cached_data"
        echo "$cached_data"
        return 0
    fi
    
    # Fetch from storage and cache
    local fresh_data=$(read_record "$record_type" "$record_id")
    file_cache_set "$record_type:$record_id" "$fresh_data"
    memory_cache_set "$record_type:$record_id" "$fresh_data"
    echo "$fresh_data"
}
```

### **Query Optimization**

```sql
-- Hybrid backend index optimization
CREATE INDEX idx_records_status ON records(status, priority);
CREATE INDEX idx_records_timeline ON records(created_at, updated_at);
CREATE INDEX idx_records_search ON records(searchable_text);
CREATE INDEX idx_records_relationships ON record_relationships(parent_id, child_id);

-- Database backend advanced indexes
CREATE INDEX idx_records_composite ON records(status, priority, created_at);
CREATE INDEX idx_records_full_text ON records USING gin(to_tsvector('english', searchable_text));
```

### **Connection Pooling**

```bash
# SQLite connection pool for concurrent access
connection_pool_init() {
    local pool_size=10
    local db_path=$1
    
    for i in $(seq 1 "$pool_size"); do
        sqlite3 "$db_path" "PRAGMA journal_mode=WAL; PRAGMA synchronous=NORMAL;" &
        echo $! > ".claude/storage/pool/connection-$i.pid"
    done
}

get_pooled_connection() {
    local available_connection=$(find ".claude/storage/pool/" -name "*.pid" | head -1)
    if [ -n "$available_connection" ]; then
        echo "$available_connection"
    else
        # Create temporary connection if pool exhausted
        create_temp_connection
    fi
}
```

## Data Integrity and Validation

### **ACID Compliance**

```bash
# Transaction management for data integrity
storage_transaction() {
    local operation=$1
    shift
    local transaction_id="tx-$(date +%s)-$$"
    
    # Begin transaction
    begin_transaction "$transaction_id"
    
    # Execute operation with error handling
    if "$operation" "$@"; then
        commit_transaction "$transaction_id"
        return 0
    else
        rollback_transaction "$transaction_id"
        return 1
    fi
}

begin_transaction() {
    local transaction_id=$1
    echo "BEGIN TRANSACTION;" > ".claude/storage/transactions/$transaction_id.sql"
}

commit_transaction() {
    local transaction_id=$1
    echo "COMMIT;" >> ".claude/storage/transactions/$transaction_id.sql"
    sqlite3 ".claude/storage/primary.db" < ".claude/storage/transactions/$transaction_id.sql"
    rm ".claude/storage/transactions/$transaction_id.sql"
}
```

### **Data Validation**

```bash
# Comprehensive data validation
validate_record_integrity() {
    local record_type=$1
    local record_data=$2
    
    # Schema validation
    validate_schema "$record_type" "$record_data"
    
    # Business logic validation
    validate_business_rules "$record_type" "$record_data"
    
    # Relationship validation
    validate_relationships "$record_type" "$record_data"
    
    # Data consistency validation
    validate_data_consistency "$record_type" "$record_data"
}

validate_schema() {
    local record_type=$1
    local record_data=$2
    local schema_file=".claude/storage/schemas/$record_type.yaml"
    
    # Use yq to validate against schema
    echo "$record_data" | yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' "$schema_file" -
}
```

## Security and Access Control

### **Data Encryption**

```bash
# Transparent data encryption
encrypt_at_rest() {
    local data=$1
    local encryption_key=$(get_encryption_key)
    
    if [ -n "$encryption_key" ]; then
        echo "$data" | openssl enc -aes-256-gcm -pbkdf2 -k "$encryption_key"
    else
        echo "$data"  # No encryption if no key configured
    fi
}

decrypt_at_rest() {
    local encrypted_data=$1
    local encryption_key=$(get_encryption_key)
    
    if [ -n "$encryption_key" ]; then
        echo "$encrypted_data" | openssl dec -aes-256-gcm -pbkdf2 -k "$encryption_key"
    else
        echo "$encrypted_data"  # Return as-is if no encryption
    fi
}
```

### **Access Control Lists**

```bash
# Role-based access control
check_storage_access() {
    local user_id=$1
    local record_type=$2
    local record_id=$3
    local operation=$4
    
    local user_role=$(get_user_role "$user_id")
    local record_acl=$(get_record_acl "$record_type" "$record_id")
    
    case "$user_role" in
        "admin") return 0 ;;  # Full access
        "owner")
            if [ "$(echo "$record_acl" | jq -r ".owner")" = "$user_id" ]; then
                return 0
            fi ;;
        "contributor")
            if [ "$operation" != "delete" ] && echo "$record_acl" | jq -r ".contributors[]" | grep -q "$user_id"; then
                return 0
            fi ;;
        "viewer")
            if [ "$operation" = "read" ] && echo "$record_acl" | jq -r ".viewers[]" | grep -q "$user_id"; then
                return 0
            fi ;;
    esac
    
    return 1  # Access denied
}
```

## Monitoring and Observability

### **Performance Monitoring**

```bash
# Storage performance metrics collection
collect_storage_metrics() {
    local operation=$1
    local record_type=$2
    local start_time=$(date +%s.%N)
    
    # Execute operation and measure performance
    "$@"
    local exit_code=$?
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    # Log metrics
    log_performance_metric "$operation" "$record_type" "$duration" "$exit_code"
    
    return $exit_code
}

log_performance_metric() {
    local operation=$1
    local record_type=$2
    local duration=$3
    local exit_code=$4
    
    echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"operation\":\"$operation\",\"record_type\":\"$record_type\",\"duration\":$duration,\"success\":$([ $exit_code -eq 0 ] && echo true || echo false)}" \
         >> ".claude/storage/logs/performance-metrics.jsonl"
}
```

### **Health Checks**

```bash
# Comprehensive storage health validation
storage_health_check() {
    local health_status="healthy"
    local issues=()
    
    # Check backend availability
    if ! validate_backend_connectivity; then
        health_status="unhealthy"
        issues+=("backend_connectivity")
    fi
    
    # Check data integrity
    if ! validate_data_integrity_sample; then
        health_status="degraded"
        issues+=("data_integrity")
    fi
    
    # Check performance metrics
    if ! validate_performance_thresholds; then
        health_status="degraded"
        issues+=("performance")
    fi
    
    # Check disk space
    if ! validate_disk_space; then
        health_status="warning"
        issues+=("disk_space")
    fi
    
    # Generate health report
    generate_health_report "$health_status" "${issues[@]}"
}
```

## Backup and Recovery

### **Automated Backup Strategy**

```bash
# Comprehensive backup system
automated_backup() {
    local backup_type=$1  # full, incremental, differential
    local backup_id="backup-$(date +%Y%m%d-%H%M%S)"
    
    case "$backup_type" in
        "full")
            create_full_backup "$backup_id"
            ;;
        "incremental")
            create_incremental_backup "$backup_id"
            ;;
        "differential")
            create_differential_backup "$backup_id"
            ;;
    esac
    
    # Validate backup integrity
    validate_backup_integrity "$backup_id"
    
    # Update backup catalog
    update_backup_catalog "$backup_id" "$backup_type"
    
    # Cleanup old backups based on retention policy
    cleanup_old_backups
}

create_full_backup() {
    local backup_id=$1
    local backup_dir=".claude/storage/backups/$backup_id"
    
    mkdir -p "$backup_dir"
    
    # Backup all storage data
    cp -r ".claude/storage"/* "$backup_dir/"
    
    # Create backup manifest
    create_backup_manifest "$backup_id" "full"
    
    # Compress backup
    tar -czf "$backup_dir.tar.gz" -C ".claude/storage/backups" "$backup_id"
    rm -rf "$backup_dir"
}
```

### **Point-in-Time Recovery**

```bash
# Restore system to specific point in time
point_in_time_recovery() {
    local target_timestamp=$1
    local recovery_mode=${2:-"full"}  # full, partial, validation
    
    echo "🔄 Starting point-in-time recovery to: $target_timestamp"
    
    # Find appropriate backup
    local backup_id=$(find_backup_for_timestamp "$target_timestamp")
    
    # Restore from backup
    restore_from_backup "$backup_id"
    
    # Apply transaction logs up to target timestamp
    replay_transaction_logs "$backup_id" "$target_timestamp"
    
    # Validate recovery
    validate_recovery_integrity "$target_timestamp"
    
    echo "✅ Point-in-time recovery completed"
}
```

## Testing and Quality Assurance

### **Storage Testing Framework**

```bash
# Comprehensive storage testing
test_storage_backend() {
    local backend=$1
    
    echo "🧪 Testing storage backend: $backend"
    
    # Unit tests
    test_crud_operations "$backend"
    test_transaction_integrity "$backend"
    test_concurrent_access "$backend"
    
    # Performance tests
    test_single_record_performance "$backend"
    test_bulk_operation_performance "$backend"
    test_search_performance "$backend"
    
    # Stress tests
    test_high_concurrency "$backend"
    test_large_dataset "$backend"
    test_memory_pressure "$backend"
    
    # Generate test report
    generate_test_report "$backend"
}
```

---

*Shared storage system documentation current as of July 21, 2025*  
*Generated with Claude Code storage system documentation*