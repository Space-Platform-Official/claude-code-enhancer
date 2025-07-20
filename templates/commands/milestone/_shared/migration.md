# Migration Orchestrator - Zero-Downtime Backend Transitions

## Core Migration Interface

The migration orchestrator handles seamless transitions between storage backends, ensuring zero data loss and minimal downtime during scale-driven backend changes.

### Migration Types

```bash
# Available migration paths
get_available_migrations() {
    local current_backend=$(get_current_storage_backend)
    
    case "$current_backend" in
        "file")
            echo "hybrid database"
            ;;
        "hybrid")
            echo "file database"
            ;;
        "database")
            echo "hybrid"  # Database can downgrade to hybrid, but not to file
            ;;
    esac
}

# Check migration compatibility
check_migration_compatibility() {
    local from_backend=$1
    local to_backend=$2
    
    # Validate migration path
    case "$from_backend" in
        "file")
            if [ "$to_backend" = "hybrid" ] || [ "$to_backend" = "database" ]; then
                echo "compatible"
                return 0
            fi
            ;;
        "hybrid")
            if [ "$to_backend" = "file" ] || [ "$to_backend" = "database" ]; then
                echo "compatible"
                return 0
            fi
            ;;
        "database")
            if [ "$to_backend" = "hybrid" ]; then
                echo "compatible"
                return 0
            fi
            ;;
    esac
    
    echo "incompatible"
    return 1
}

# Estimate migration duration
estimate_migration_duration() {
    local from_backend=$1
    local to_backend=$2
    local milestone_count=$(count_active_milestones)
    
    # Base duration calculations
    local base_minutes=5
    local per_milestone_seconds=2
    
    # Adjust for complexity
    case "$from_backend-$to_backend" in
        "file-hybrid")
            per_milestone_seconds=3  # Need to create database index
            ;;
        "file-database")
            per_milestone_seconds=5  # Full database setup
            ;;
        "hybrid-database")
            per_milestone_seconds=2  # Already have index
            ;;
        "hybrid-file")
            per_milestone_seconds=1  # Just remove index
            ;;
        "database-hybrid")
            per_milestone_seconds=3  # Convert to hybrid model
            ;;
    esac
    
    local total_seconds=$((base_minutes * 60 + milestone_count * per_milestone_seconds))
    local total_minutes=$((total_seconds / 60))
    
    echo "$total_minutes"
}
```

### Pre-Migration Validation

```bash
# Comprehensive pre-migration checks
validate_migration_prerequisites() {
    local from_backend=$1
    local to_backend=$2
    local validation_errors=()
    
    echo "🔍 Validating migration prerequisites: $from_backend → $to_backend"
    
    # Check compatibility
    if [ "$(check_migration_compatibility "$from_backend" "$to_backend")" = "incompatible" ]; then
        validation_errors+=("Migration path $from_backend → $to_backend is not supported")
    fi
    
    # Check current system state
    if [ "$(count_active_sessions)" -gt 0 ]; then
        validation_errors+=("Active milestone sessions detected. Complete or pause sessions before migration.")
    fi
    
    # Check storage system health
    if ! validate_storage_integrity "$from_backend"; then
        validation_errors+=("Current storage backend has integrity issues")
    fi
    
    # Check system resources
    local available_disk=$(get_available_disk_space)
    local required_disk=$(calculate_migration_disk_requirements "$from_backend" "$to_backend")
    
    if [ "$available_disk" -lt "$required_disk" ]; then
        validation_errors+=("Insufficient disk space: ${available_disk}MB available, ${required_disk}MB required")
    fi
    
    # Check dependencies
    case "$to_backend" in
        "hybrid"|"database")
            if ! command -v sqlite3 >/dev/null 2>&1; then
                validation_errors+=("SQLite3 is required for $to_backend backend")
            fi
            ;;
        "database")
            if [ "$DATABASE_TYPE" = "postgresql" ] && [ -z "$DATABASE_URL" ]; then
                validation_errors+=("DATABASE_URL must be set for PostgreSQL backend")
            fi
            ;;
    esac
    
    # Return validation results
    if [ ${#validation_errors[@]} -eq 0 ]; then
        echo "✅ All prerequisites validated"
        return 0
    else
        echo "❌ Validation failed:"
        for error in "${validation_errors[@]}"; do
            echo "  - $error"
        done
        return 1
    fi
}

# Check for active sessions
count_active_sessions() {
    if [ -f ".milestones/sessions/current.txt" ]; then
        echo "1"
    else
        echo "0"
    fi
}

# Validate storage integrity
validate_storage_integrity() {
    local backend=$1
    
    case "$backend" in
        "file")
            validate_file_storage_integrity
            ;;
        "hybrid")
            validate_hybrid_storage_integrity
            ;;
        "database")
            validate_database_storage_integrity
            ;;
    esac
}

validate_file_storage_integrity() {
    local error_count=0
    
    # Check for corrupted YAML files
    for milestone_file in .milestones/active/*.yaml; do
        if [ -f "$milestone_file" ]; then
            if ! yq e '.' "$milestone_file" >/dev/null 2>&1; then
                echo "❌ Corrupted milestone file: $milestone_file"
                ((error_count++))
            fi
        fi
    done
    
    # Check event log integrity
    if [ -f ".milestones/logs/storage-events.jsonl" ]; then
        if ! jq -s '.' ".milestones/logs/storage-events.jsonl" >/dev/null 2>&1; then
            echo "❌ Corrupted storage events log"
            ((error_count++))
        fi
    fi
    
    return $error_count
}

validate_hybrid_storage_integrity() {
    local error_count=0
    
    # Validate file storage
    validate_file_storage_integrity
    error_count=$?
    
    # Validate SQLite index
    if [ -f ".milestones/index.db" ]; then
        if ! sqlite3 ".milestones/index.db" "SELECT COUNT(*) FROM milestones" >/dev/null 2>&1; then
            echo "❌ Corrupted SQLite index database"
            ((error_count++))
        fi
    else
        echo "❌ Missing SQLite index database"
        ((error_count++))
    fi
    
    return $error_count
}

validate_database_storage_integrity() {
    local error_count=0
    
    if [ "$DATABASE_TYPE" = "postgresql" ]; then
        if ! psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM milestones" >/dev/null 2>&1; then
            echo "❌ Cannot connect to PostgreSQL database"
            ((error_count++))
        fi
    elif [ -f ".milestones/enterprise.db" ]; then
        if ! sqlite3 ".milestones/enterprise.db" "SELECT COUNT(*) FROM milestones" >/dev/null 2>&1; then
            echo "❌ Corrupted enterprise SQLite database"
            ((error_count++))
        fi
    else
        echo "❌ Missing enterprise database"
        ((error_count++))
    fi
    
    return $error_count
}
```

### Backup and Rollback System

```bash
# Create comprehensive backup before migration
create_migration_backup() {
    local from_backend=$1
    local to_backend=$2
    local backup_id="migration-$(date +%Y%m%d-%H%M%S)-${from_backend}-to-${to_backend}"
    local backup_dir=".milestones/backups/$backup_id"
    
    echo "🔄 Creating migration backup: $backup_id"
    
    mkdir -p "$backup_dir"
    
    # Backup current configuration
    cp ".milestones/config/storage-backend.txt" "$backup_dir/" 2>/dev/null || true
    cp ".milestones/config/storage-config.yaml" "$backup_dir/" 2>/dev/null || true
    
    # Backup based on current backend
    case "$from_backend" in
        "file")
            backup_file_storage "$backup_dir"
            ;;
        "hybrid")
            backup_hybrid_storage "$backup_dir"
            ;;
        "database")
            backup_database_storage "$backup_dir"
            ;;
    esac
    
    # Create backup metadata
    cat > "$backup_dir/backup-metadata.yaml" << EOF
backup:
  id: "$backup_id"
  timestamp: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  from_backend: "$from_backend"
  to_backend: "$to_backend"
  milestone_count: $(count_active_milestones)
  
validation:
  integrity_check: $(validate_storage_integrity "$from_backend" && echo "passed" || echo "failed")
  backup_size: $(du -sm "$backup_dir" | cut -f1)MB
  
restore:
  command: "/milestone/restore $backup_id"
  estimated_duration: "$(estimate_migration_duration "$to_backend" "$from_backend") minutes"
EOF
    
    echo "✅ Backup created: $backup_dir"
    echo "$backup_id"
}

backup_file_storage() {
    local backup_dir=$1
    
    # Copy all milestone files
    cp -r .milestones/active "$backup_dir/" 2>/dev/null || true
    cp -r .milestones/completed "$backup_dir/" 2>/dev/null || true
    cp -r .milestones/logs "$backup_dir/" 2>/dev/null || true
}

backup_hybrid_storage() {
    local backup_dir=$1
    
    # Copy file storage
    backup_file_storage "$backup_dir"
    
    # Export SQLite index
    if [ -f ".milestones/index.db" ]; then
        sqlite3 ".milestones/index.db" ".dump" > "$backup_dir/index-dump.sql"
        cp ".milestones/index.db" "$backup_dir/"
    fi
}

backup_database_storage() {
    local backup_dir=$1
    
    if [ "$DATABASE_TYPE" = "postgresql" ]; then
        # PostgreSQL backup
        pg_dump "$DATABASE_URL" > "$backup_dir/postgresql-dump.sql"
    elif [ -f ".milestones/enterprise.db" ]; then
        # SQLite backup
        sqlite3 ".milestones/enterprise.db" ".dump" > "$backup_dir/enterprise-dump.sql"
        cp ".milestones/enterprise.db" "$backup_dir/"
    fi
    
    # Backup any local files
    cp -r .milestones/logs "$backup_dir/" 2>/dev/null || true
}

# Restore from backup
restore_from_backup() {
    local backup_id=$1
    local backup_dir=".milestones/backups/$backup_id"
    
    if [ ! -d "$backup_dir" ]; then
        echo "❌ Backup not found: $backup_id"
        return 1
    fi
    
    echo "🔄 Restoring from backup: $backup_id"
    
    # Load backup metadata
    local from_backend=$(yq e '.backup.from_backend' "$backup_dir/backup-metadata.yaml")
    local to_backend=$(yq e '.backup.to_backend' "$backup_dir/backup-metadata.yaml")
    
    # Pause any active sessions
    pause_active_sessions
    
    # Restore based on original backend
    case "$from_backend" in
        "file")
            restore_file_storage "$backup_dir"
            ;;
        "hybrid")
            restore_hybrid_storage "$backup_dir"
            ;;
        "database")
            restore_database_storage "$backup_dir"
            ;;
    esac
    
    # Restore configuration
    cp "$backup_dir/storage-backend.txt" ".milestones/config/" 2>/dev/null || true
    cp "$backup_dir/storage-config.yaml" ".milestones/config/" 2>/dev/null || true
    
    # Validate restoration
    if validate_storage_integrity "$from_backend"; then
        echo "✅ Backup restored successfully"
        log_storage_event "backup_restored" "system" "$from_backend" "{\"backup_id\":\"$backup_id\"}"
        return 0
    else
        echo "❌ Backup restoration failed integrity check"
        return 1
    fi
}

restore_file_storage() {
    local backup_dir=$1
    
    # Restore milestone files
    rm -rf .milestones/active .milestones/completed .milestones/logs
    cp -r "$backup_dir/active" .milestones/ 2>/dev/null || true
    cp -r "$backup_dir/completed" .milestones/ 2>/dev/null || true
    cp -r "$backup_dir/logs" .milestones/ 2>/dev/null || true
}

restore_hybrid_storage() {
    local backup_dir=$1
    
    # Restore file storage
    restore_file_storage "$backup_dir"
    
    # Restore SQLite index
    if [ -f "$backup_dir/index-dump.sql" ]; then
        rm -f .milestones/index.db
        sqlite3 .milestones/index.db < "$backup_dir/index-dump.sql"
    fi
}

restore_database_storage() {
    local backup_dir=$1
    
    if [ "$DATABASE_TYPE" = "postgresql" ] && [ -f "$backup_dir/postgresql-dump.sql" ]; then
        # Restore PostgreSQL
        psql "$DATABASE_URL" < "$backup_dir/postgresql-dump.sql"
    elif [ -f "$backup_dir/enterprise-dump.sql" ]; then
        # Restore SQLite
        rm -f .milestones/enterprise.db
        sqlite3 .milestones/enterprise.db < "$backup_dir/enterprise-dump.sql"
    fi
    
    # Restore logs
    cp -r "$backup_dir/logs" .milestones/ 2>/dev/null || true
}
```

### Migration Execution Engine

```bash
# Main migration orchestration function
initiate_storage_migration() {
    local from_backend=$1
    local to_backend=$2
    local migration_id="migration-$(date +%Y%m%d-%H%M%S)"
    
    echo "🚀 Initiating storage migration: $from_backend → $to_backend"
    echo "Migration ID: $migration_id"
    
    # Pre-migration validation
    if ! validate_migration_prerequisites "$from_backend" "$to_backend"; then
        echo "❌ Migration prerequisites not met"
        return 1
    fi
    
    # Create backup
    local backup_id=$(create_migration_backup "$from_backend" "$to_backend")
    if [ $? -ne 0 ]; then
        echo "❌ Failed to create backup"
        return 1
    fi
    
    # Pause active sessions
    pause_active_sessions
    
    # Execute migration with rollback on failure
    if execute_migration_steps "$from_backend" "$to_backend" "$migration_id"; then
        echo "✅ Migration completed successfully"
        cleanup_migration "$migration_id" "$backup_id"
        return 0
    else
        echo "❌ Migration failed, initiating rollback"
        restore_from_backup "$backup_id"
        return 1
    fi
}

# Execute migration steps with atomic operations
execute_migration_steps() {
    local from_backend=$1
    local to_backend=$2
    local migration_id=$3
    
    echo "⚡ Executing migration steps..."
    
    # Step 1: Initialize target backend
    if ! initialize_target_backend "$to_backend"; then
        echo "❌ Failed to initialize target backend"
        return 1
    fi
    
    # Step 2: Migrate data
    if ! migrate_data "$from_backend" "$to_backend"; then
        echo "❌ Failed to migrate data"
        return 1
    fi
    
    # Step 3: Validate migration
    if ! validate_migration_integrity "$from_backend" "$to_backend"; then
        echo "❌ Migration integrity validation failed"
        return 1
    fi
    
    # Step 4: Switch backend
    if ! switch_active_backend "$to_backend"; then
        echo "❌ Failed to switch active backend"
        return 1
    fi
    
    # Step 5: Cleanup source backend (optional)
    cleanup_source_backend "$from_backend" "$to_backend"
    
    # Log successful migration
    log_storage_event "migration_completed" "system" "$to_backend" "{\"migration_id\":\"$migration_id\",\"from\":\"$from_backend\"}"
    
    return 0
}

# Initialize target backend storage
initialize_target_backend() {
    local to_backend=$1
    
    echo "🔧 Initializing target backend: $to_backend"
    
    case "$to_backend" in
        "file")
            # File backend needs minimal initialization
            mkdir -p .milestones/active .milestones/completed .milestones/logs
            ;;
        "hybrid")
            # Initialize hybrid storage
            mkdir -p .milestones/active .milestones/completed .milestones/logs
            initialize_hybrid_storage
            ;;
        "database")
            # Initialize database storage
            initialize_database_storage
            ;;
    esac
    
    return $?
}

# Migrate data between backends
migrate_data() {
    local from_backend=$1
    local to_backend=$2
    
    echo "📦 Migrating data: $from_backend → $to_backend"
    
    case "$from_backend-$to_backend" in
        "file-hybrid")
            migrate_file_to_hybrid
            ;;
        "file-database")
            migrate_file_to_database
            ;;
        "hybrid-file")
            migrate_hybrid_to_file
            ;;
        "hybrid-database")
            migrate_hybrid_to_database
            ;;
        "database-hybrid")
            migrate_database_to_hybrid
            ;;
        *)
            echo "❌ Unsupported migration path: $from_backend → $to_backend"
            return 1
            ;;
    esac
}

migrate_file_to_hybrid() {
    echo "📁 Migrating file storage to hybrid..."
    
    # Files stay in place, build SQLite index
    for milestone_file in .milestones/active/*.yaml; do
        if [ -f "$milestone_file" ]; then
            local milestone_id=$(basename "$milestone_file" .yaml)
            local title=$(yq e '.title' "$milestone_file")
            local status=$(yq e '.status' "$milestone_file")
            local priority=$(yq e '.priority // "medium"' "$milestone_file")
            local created_at=$(yq e '.timeline.estimated_start // "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' "$milestone_file")
            
            # Insert into SQLite index
            sqlite3 ".milestones/index.db" "
                INSERT OR REPLACE INTO milestones (id, title, status, priority, created_at, file_path) 
                VALUES ('$milestone_id', '$title', '$status', '$priority', '$created_at', '$milestone_file')
            "
        fi
    done
    
    return 0
}

migrate_file_to_database() {
    echo "🗄️ Migrating file storage to database..."
    
    for milestone_file in .milestones/active/*.yaml; do
        if [ -f "$milestone_file" ]; then
            local milestone_id=$(basename "$milestone_file" .yaml)
            local milestone_data=$(cat "$milestone_file")
            
            # Create milestone in database
            create_milestone_database "$milestone_id" "$milestone_data"
        fi
    done
    
    return 0
}

migrate_hybrid_to_file() {
    echo "📁 Migrating hybrid storage to file-only..."
    
    # Files already exist, just remove SQLite index
    rm -f .milestones/index.db
    
    return 0
}

migrate_hybrid_to_database() {
    echo "🗄️ Migrating hybrid storage to database..."
    
    # Read milestones from SQLite index and files
    for milestone_id in $(sqlite3 ".milestones/index.db" "SELECT id FROM milestones"); do
        local milestone_file=".milestones/active/${milestone_id}.yaml"
        if [ -f "$milestone_file" ]; then
            local milestone_data=$(cat "$milestone_file")
            create_milestone_database "$milestone_id" "$milestone_data"
        fi
    done
    
    return 0
}

migrate_database_to_hybrid() {
    echo "📁 Migrating database to hybrid storage..."
    
    # Export from database to files and create SQLite index
    if [ "$DATABASE_TYPE" = "postgresql" ]; then
        psql "$DATABASE_URL" -t -c "SELECT id, data FROM milestones" | while IFS='|' read -r id data; do
            local milestone_file=".milestones/active/${id}.yaml"
            echo "$data" | jq -r '.' | yq e -P '.' > "$milestone_file"
            
            # Add to hybrid index
            local title=$(echo "$data" | jq -r '.title')
            local status=$(echo "$data" | jq -r '.status')
            local priority=$(echo "$data" | jq -r '.priority // "medium"')
            local created_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
            
            sqlite3 ".milestones/index.db" "
                INSERT OR REPLACE INTO milestones (id, title, status, priority, created_at, file_path) 
                VALUES ('$id', '$title', '$status', '$priority', '$created_at', '$milestone_file')
            "
        done
    else
        sqlite3 ".milestones/enterprise.db" "SELECT id, data FROM milestones" | while IFS='|' read -r id data; do
            local milestone_file=".milestones/active/${id}.yaml"
            echo "$data" | jq -r '.' | yq e -P '.' > "$milestone_file"
            
            # Add to hybrid index (similar logic as above)
        done
    fi
    
    return 0
}

# Validate migration integrity
validate_migration_integrity() {
    local from_backend=$1
    local to_backend=$2
    
    echo "🔍 Validating migration integrity..."
    
    # Count milestones in source vs target
    local source_count
    case "$from_backend" in
        "file")
            source_count=$(find .milestones/active -name "*.yaml" -type f | wc -l)
            ;;
        "hybrid")
            source_count=$(sqlite3 ".milestones/index.db" "SELECT COUNT(*) FROM milestones" 2>/dev/null || echo "0")
            ;;
        "database")
            if [ "$DATABASE_TYPE" = "postgresql" ]; then
                source_count=$(psql "$DATABASE_URL" -t -c "SELECT COUNT(*) FROM milestones" 2>/dev/null || echo "0")
            else
                source_count=$(sqlite3 ".milestones/enterprise.db" "SELECT COUNT(*) FROM milestones" 2>/dev/null || echo "0")
            fi
            ;;
    esac
    
    # Set temp backend for validation
    echo "$to_backend" > ".milestones/config/storage-backend.txt.tmp"
    local temp_backend_file=".milestones/config/storage-backend.txt"
    mv "$temp_backend_file" "${temp_backend_file}.bak"
    mv "${temp_backend_file}.tmp" "$temp_backend_file"
    
    local target_count=$(count_active_milestones)
    
    # Restore original backend file
    mv "${temp_backend_file}.bak" "$temp_backend_file"
    
    if [ "$source_count" -eq "$target_count" ]; then
        echo "✅ Migration integrity validated: $source_count milestones migrated"
        return 0
    else
        echo "❌ Migration integrity failed: $source_count → $target_count milestones"
        return 1
    fi
}

# Switch active backend
switch_active_backend() {
    local to_backend=$1
    
    echo "🔄 Switching to backend: $to_backend"
    
    # Update backend configuration
    echo "$to_backend" > ".milestones/config/storage-backend.txt"
    
    # Validate switch
    if [ "$(get_current_storage_backend)" = "$to_backend" ]; then
        echo "✅ Backend switched successfully"
        return 0
    else
        echo "❌ Failed to switch backend"
        return 1
    fi
}

# Cleanup source backend after successful migration
cleanup_source_backend() {
    local from_backend=$1
    local to_backend=$2
    
    echo "🧹 Cleaning up source backend: $from_backend"
    
    # Conservative cleanup - only remove what's safe
    case "$from_backend" in
        "hybrid")
            if [ "$to_backend" = "database" ]; then
                # Keep files, remove SQLite index
                rm -f .milestones/index.db
            fi
            ;;
        "database")
            if [ "$to_backend" = "hybrid" ]; then
                # Keep enterprise DB as backup for now
                echo "Database kept as backup"
            fi
            ;;
    esac
}

# Pause active sessions during migration
pause_active_sessions() {
    if [ -f ".milestones/sessions/current.txt" ]; then
        echo "⏸️ Pausing active sessions for migration"
        mv ".milestones/sessions/current.txt" ".milestones/sessions/paused-for-migration.txt"
    fi
}

# Resume sessions after migration
resume_paused_sessions() {
    if [ -f ".milestones/sessions/paused-for-migration.txt" ]; then
        echo "▶️ Resuming paused sessions"
        mv ".milestones/sessions/paused-for-migration.txt" ".milestones/sessions/current.txt"
    fi
}

# Migration cleanup
cleanup_migration() {
    local migration_id=$1
    local backup_id=$2
    
    echo "🧹 Cleaning up migration: $migration_id"
    
    # Resume any paused sessions
    resume_paused_sessions
    
    # Mark backup with retention policy
    local backup_dir=".milestones/backups/$backup_id"
    if [ -d "$backup_dir" ]; then
        echo "retention_days: 30" >> "$backup_dir/backup-metadata.yaml"
        echo "auto_cleanup: true" >> "$backup_dir/backup-metadata.yaml"
    fi
    
    # Initialize scale detection for new backend
    initialize_scale_detection
}
```

### Migration CLI Interface

```bash
# User-friendly migration interface
migrate_storage_backend() {
    local target_backend=$1
    local force_mode=${2:-false}
    local current_backend=$(get_current_storage_backend)
    
    if [ -z "$target_backend" ]; then
        echo "Usage: /milestone/migrate [file|hybrid|database] [--force]"
        echo ""
        echo "Current backend: $current_backend"
        echo "Available targets: $(get_available_migrations)"
        return 1
    fi
    
    if [ "$current_backend" = "$target_backend" ]; then
        echo "✅ Already using $target_backend backend"
        return 0
    fi
    
    # Show migration plan
    show_migration_plan "$current_backend" "$target_backend"
    
    # Ask for confirmation unless force mode
    if [ "$force_mode" != "true" ]; then
        echo ""
        read -p "Proceed with migration? (y/N): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            echo "Migration cancelled"
            return 0
        fi
    fi
    
    # Execute migration
    initiate_storage_migration "$current_backend" "$target_backend"
}

# Show detailed migration plan
show_migration_plan() {
    local from_backend=$1
    local to_backend=$2
    
    echo "=== MIGRATION PLAN ==="
    echo "From: $from_backend"
    echo "To: $to_backend"
    echo ""
    echo "Steps:"
    echo "1. Validate prerequisites"
    echo "2. Create backup"
    echo "3. Pause active sessions"
    echo "4. Initialize target backend"
    echo "5. Migrate $(count_active_milestones) milestones"
    echo "6. Validate integrity"
    echo "7. Switch backend"
    echo "8. Cleanup and resume"
    echo ""
    echo "Estimated duration: $(estimate_migration_duration "$from_backend" "$to_backend") minutes"
    echo "Downtime: Minimal (sessions paused briefly)"
    echo "Rollback: Available via backup"
}

# List available backups
list_migration_backups() {
    echo "=== AVAILABLE BACKUPS ==="
    
    if [ ! -d ".milestones/backups" ]; then
        echo "No backups found"
        return
    fi
    
    for backup_dir in .milestones/backups/migration-*; do
        if [ -d "$backup_dir" ] && [ -f "$backup_dir/backup-metadata.yaml" ]; then
            local backup_id=$(basename "$backup_dir")
            local timestamp=$(yq e '.backup.timestamp' "$backup_dir/backup-metadata.yaml")
            local from_backend=$(yq e '.backup.from_backend' "$backup_dir/backup-metadata.yaml")
            local to_backend=$(yq e '.backup.to_backend' "$backup_dir/backup-metadata.yaml")
            local milestone_count=$(yq e '.backup.milestone_count' "$backup_dir/backup-metadata.yaml")
            
            echo "📦 $backup_id"
            echo "   Created: $timestamp"
            echo "   Migration: $from_backend → $to_backend"
            echo "   Milestones: $milestone_count"
            echo ""
        fi
    done
}

# Show migration status
show_migration_status() {
    local current_backend=$(get_current_storage_backend)
    local optimal_backend=$(detect_optimal_scale)
    
    echo "=== MIGRATION STATUS ==="
    echo "Current Backend: $current_backend"
    echo "Optimal Backend: $optimal_backend"
    echo ""
    
    if [ "$current_backend" != "$optimal_backend" ]; then
        echo "🔄 Migration recommended: $current_backend → $optimal_backend"
        echo "Confidence: $(calculate_migration_confidence "$current_backend" "$optimal_backend")%"
        echo "Command: /milestone/migrate $optimal_backend"
    else
        echo "✅ Current backend is optimal"
    fi
    
    echo ""
    echo "Scale Metrics:"
    echo "├── Milestones: $(count_active_milestones)"
    echo "├── Users: $(count_concurrent_users)"
    echo "└── Complexity: $(calculate_project_complexity)"
}
```

### Auto-Migration Integration

```bash
# Automatic migration trigger (called by scale detector)
trigger_automatic_migration() {
    local current_backend=$(get_current_storage_backend)
    local optimal_backend=$(detect_optimal_scale)
    
    # Check if auto-migration is enabled
    local config=$(get_storage_config)
    local auto_migrate=$(echo "$config" | yq e '.storage.migration.auto_migrate' -)
    
    if [ "$auto_migrate" = "true" ] && [ "$current_backend" != "$optimal_backend" ]; then
        local confidence=$(calculate_migration_confidence "$current_backend" "$optimal_backend")
        
        if [ "$confidence" -ge 90 ]; then
            echo "🤖 Triggering automatic migration: $current_backend → $optimal_backend"
            migrate_storage_backend "$optimal_backend" "true"
        fi
    fi
}

# Migration health monitoring
monitor_migration_health() {
    # Check for failed migrations
    if [ -f ".milestones/sessions/paused-for-migration.txt" ]; then
        echo "⚠️ Sessions still paused from previous migration"
        echo "Run: /milestone/migration/resume to recover"
    fi
    
    # Check backup retention
    cleanup_old_backups
}

# Cleanup old backups based on retention policy
cleanup_old_backups() {
    local retention_days=30
    local cutoff_date=$(date -d "$retention_days days ago" +%Y%m%d)
    
    for backup_dir in .milestones/backups/migration-*; do
        if [ -d "$backup_dir" ]; then
            local backup_date=$(basename "$backup_dir" | cut -d'-' -f2)
            if [ "$backup_date" -lt "$cutoff_date" ]; then
                echo "🗑️ Cleaning up old backup: $(basename "$backup_dir")"
                rm -rf "$backup_dir"
            fi
        fi
    done
}
```

This migration orchestrator provides comprehensive zero-downtime backend transitions with full backup and rollback capabilities, seamlessly integrating with the storage abstraction layer and scale detection engine.