# Claude Flow Backup and Recovery Guide

## Overview

This guide provides comprehensive procedures for backing up Claude Flow installations, data recovery, and disaster recovery planning.

## Backup Strategy

### 1. What to Backup

```yaml
backup_components:
  critical:
    - /opt/claude-flow/config/        # System configuration
    - /home/*/.claude/                # User data
    - Database (if applicable)         # Shared state
    - API keys and credentials         # Encrypted secrets
    
  important:
    - /opt/claude-flow/shared/         # Shared resources
    - /var/log/claude-flow/            # Audit logs
    - Custom scripts and integrations
    
  optional:
    - /opt/claude-flow/cache/          # Can be regenerated
    - Temporary files
    - Old log files
```

### 2. Backup Types

```bash
# Full Backup - Complete system state
# Incremental - Changes since last backup
# Differential - Changes since last full backup
# Snapshot - Point-in-time copy

BACKUP_TYPE="full"  # full, incremental, differential, snapshot
```

## Automated Backup

### 1. Backup Script

```bash
#!/bin/bash
# claude-flow-backup.sh

# Configuration
BACKUP_ROOT="/backup/claude-flow"
RETENTION_DAYS=30
ENCRYPTION_KEY="/etc/claude-flow/backup.key"
LOG_FILE="/var/log/claude-flow/backup.log"

# Backup type based on day
if [ "$(date +%w)" -eq 0 ]; then
    BACKUP_TYPE="full"
else
    BACKUP_TYPE="incremental"
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$BACKUP_TYPE-$TIMESTAMP"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to backup component
backup_component() {
    local name=$1
    local source=$2
    local exclude=$3
    
    log "Backing up $name from $source"
    
    if [ "$BACKUP_TYPE" = "incremental" ]; then
        # Find last full backup
        LAST_FULL=$(find "$BACKUP_ROOT" -name "full-*" -type d | sort -r | head -1)
        
        # Create incremental backup
        tar -czf "$BACKUP_DIR/${name}.tar.gz" \
            --newer-mtime="$(stat -c %y "$LAST_FULL")" \
            --exclude="$exclude" \
            "$source" 2>/dev/null || true
    else
        # Create full backup
        tar -czf "$BACKUP_DIR/${name}.tar.gz" \
            --exclude="$exclude" \
            "$source" 2>/dev/null || true
    fi
    
    # Encrypt if key exists
    if [ -f "$ENCRYPTION_KEY" ]; then
        openssl enc -aes-256-cbc -salt \
            -in "$BACKUP_DIR/${name}.tar.gz" \
            -out "$BACKUP_DIR/${name}.tar.gz.enc" \
            -pass file:"$ENCRYPTION_KEY"
        rm "$BACKUP_DIR/${name}.tar.gz"
    fi
}

# Start backup
log "Starting $BACKUP_TYPE backup"

# System configuration
backup_component "system-config" "/opt/claude-flow/config" "*.tmp"

# User data
backup_component "user-data" "/home" "*/.claude/cache/*"

# Shared resources
backup_component "shared" "/opt/claude-flow/shared" "*.log"

# Database backup (if exists)
if command -v pg_dump &> /dev/null; then
    log "Backing up database"
    pg_dump -h localhost -U claude_flow claude_flow > "$BACKUP_DIR/database.sql"
    gzip "$BACKUP_DIR/database.sql"
fi

# Create manifest
cat > "$BACKUP_DIR/manifest.json" << EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "type": "$BACKUP_TYPE",
    "hostname": "$(hostname)",
    "version": "$(claude-flow --version)",
    "components": [
        "system-config",
        "user-data",
        "shared",
        "database"
    ]
}
EOF

# Verify backup
log "Verifying backup integrity"
find "$BACKUP_DIR" -name "*.tar.gz*" -exec sha256sum {} \; > "$BACKUP_DIR/checksums.sha256"

# Clean old backups
log "Cleaning old backups"
find "$BACKUP_ROOT" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null || true

# Create latest symlink
ln -sfn "$BACKUP_DIR" "$BACKUP_ROOT/latest"

log "Backup completed successfully"

# Send notification
if [ -n "$BACKUP_NOTIFICATION_EMAIL" ]; then
    echo "Claude Flow backup completed: $BACKUP_DIR" | \
        mail -s "Backup Success: $(hostname)" "$BACKUP_NOTIFICATION_EMAIL"
fi
```

### 2. Backup Configuration

```json
{
  "backup": {
    "enabled": true,
    "schedule": {
      "full": "0 2 * * 0",      // Weekly full backup
      "incremental": "0 2 * * 1-6", // Daily incremental
      "retention": {
        "full": 30,             // Keep full backups for 30 days
        "incremental": 7        // Keep incremental for 7 days
      }
    },
    "destinations": [
      {
        "type": "local",
        "path": "/backup/claude-flow"
      },
      {
        "type": "s3",
        "bucket": "company-backups",
        "prefix": "claude-flow/",
        "region": "us-east-1"
      },
      {
        "type": "nfs",
        "server": "backup.company.com",
        "path": "/mnt/backups/claude-flow"
      }
    ],
    "encryption": {
      "enabled": true,
      "algorithm": "aes-256-cbc",
      "key_file": "/etc/claude-flow/backup.key"
    },
    "compression": {
      "enabled": true,
      "algorithm": "gzip",
      "level": 6
    }
  }
}
```

### 3. Cloud Backup Integration

```python
#!/usr/bin/env python3
# cloud_backup.py

import boto3
import os
import json
from datetime import datetime
from pathlib import Path

class CloudBackupManager:
    def __init__(self, config_path='/opt/claude-flow/config/backup.json'):
        with open(config_path) as f:
            self.config = json.load(f)
        
        # Initialize cloud clients
        self.s3 = boto3.client('s3') if self.has_s3() else None
        self.azure = self.init_azure() if self.has_azure() else None
        self.gcs = self.init_gcs() if self.has_gcs() else None
    
    def backup_to_s3(self, local_path, s3_key):
        """Backup file to S3"""
        bucket = self.config['destinations']['s3']['bucket']
        
        # Multipart upload for large files
        file_size = os.path.getsize(local_path)
        if file_size > 100 * 1024 * 1024:  # 100MB
            self.multipart_upload_s3(local_path, bucket, s3_key)
        else:
            self.s3.upload_file(local_path, bucket, s3_key)
        
        # Set lifecycle policy
        self.s3.put_object_lifecycle_configuration(
            Bucket=bucket,
            LifecycleConfiguration={
                'Rules': [{
                    'ID': 'claude-flow-retention',
                    'Status': 'Enabled',
                    'Expiration': {
                        'Days': self.config['retention_days']
                    }
                }]
            }
        )
    
    def backup_to_azure(self, local_path, blob_name):
        """Backup file to Azure Blob Storage"""
        container = self.config['destinations']['azure']['container']
        blob_client = self.azure.get_blob_client(
            container=container,
            blob=blob_name
        )
        
        with open(local_path, 'rb') as data:
            blob_client.upload_blob(data, overwrite=True)
    
    def backup_to_gcs(self, local_path, gcs_path):
        """Backup file to Google Cloud Storage"""
        bucket = self.gcs.bucket(self.config['destinations']['gcs']['bucket'])
        blob = bucket.blob(gcs_path)
        
        blob.upload_from_filename(local_path)
        
        # Set retention
        blob.lifecycle_rules = [{
            'action': {'type': 'Delete'},
            'condition': {'age': self.config['retention_days']}
        }]
    
    def sync_backups(self):
        """Sync local backups to cloud"""
        local_backup_dir = Path(self.config['local_backup_path'])
        
        for backup_file in local_backup_dir.glob('**/*.tar.gz*'):
            relative_path = backup_file.relative_to(local_backup_dir)
            
            # Upload to configured destinations
            for dest in self.config['destinations']:
                if dest['type'] == 's3' and self.s3:
                    s3_key = f"{dest['prefix']}{relative_path}"
                    self.backup_to_s3(backup_file, s3_key)
                
                elif dest['type'] == 'azure' and self.azure:
                    blob_name = f"{dest['prefix']}{relative_path}"
                    self.backup_to_azure(backup_file, blob_name)
                
                elif dest['type'] == 'gcs' and self.gcs:
                    gcs_path = f"{dest['prefix']}{relative_path}"
                    self.backup_to_gcs(backup_file, gcs_path)

if __name__ == '__main__':
    manager = CloudBackupManager()
    manager.sync_backups()
```

## Recovery Procedures

### 1. Recovery Script

```bash
#!/bin/bash
# claude-flow-restore.sh

# Configuration
BACKUP_ROOT="/backup/claude-flow"
RESTORE_POINT=""
RESTORE_COMPONENTS=""
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --backup-dir)
            RESTORE_POINT="$2"
            shift 2
            ;;
        --components)
            RESTORE_COMPONENTS="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# If no backup specified, use latest
if [ -z "$RESTORE_POINT" ]; then
    RESTORE_POINT="$BACKUP_ROOT/latest"
fi

# Validation
if [ ! -d "$RESTORE_POINT" ]; then
    echo "ERROR: Backup directory not found: $RESTORE_POINT"
    exit 1
fi

# Read manifest
MANIFEST="$RESTORE_POINT/manifest.json"
if [ ! -f "$MANIFEST" ]; then
    echo "ERROR: Backup manifest not found"
    exit 1
fi

echo "=== Claude Flow Recovery ==="
echo "Backup: $RESTORE_POINT"
echo "Date: $(jq -r .timestamp "$MANIFEST")"
echo "Type: $(jq -r .type "$MANIFEST")"
echo ""

# Function to restore component
restore_component() {
    local component=$1
    local destination=$2
    local backup_file="$RESTORE_POINT/${component}.tar.gz"
    
    # Check if encrypted
    if [ -f "$backup_file.enc" ]; then
        echo "Decrypting $component..."
        openssl enc -d -aes-256-cbc \
            -in "$backup_file.enc" \
            -out "$backup_file" \
            -pass file:"$ENCRYPTION_KEY"
    fi
    
    if [ ! -f "$backup_file" ]; then
        echo "WARNING: Backup file not found for $component"
        return 1
    fi
    
    # Verify checksum
    if [ -f "$RESTORE_POINT/checksums.sha256" ]; then
        if ! grep "$backup_file" "$RESTORE_POINT/checksums.sha256" | sha256sum -c -; then
            echo "ERROR: Checksum verification failed for $component"
            return 1
        fi
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would restore $component to $destination"
        tar -tzf "$backup_file" | head -10
    else
        echo "Restoring $component to $destination..."
        
        # Create backup of current state
        if [ -d "$destination" ]; then
            mv "$destination" "${destination}.pre-restore-$(date +%Y%m%d_%H%M%S)"
        fi
        
        # Extract backup
        tar -xzf "$backup_file" -C /
    fi
    
    # Clean up decrypted file
    if [ -f "$backup_file.enc" ]; then
        rm -f "$backup_file"
    fi
}

# Stop services
if [ "$DRY_RUN" = false ]; then
    echo "Stopping Claude Flow services..."
    systemctl stop claude-flow-daemon 2>/dev/null || true
fi

# Restore components
if [ -z "$RESTORE_COMPONENTS" ]; then
    # Restore all components
    restore_component "system-config" "/opt/claude-flow/config"
    restore_component "user-data" "/home"
    restore_component "shared" "/opt/claude-flow/shared"
    
    # Restore database if exists
    if [ -f "$RESTORE_POINT/database.sql.gz" ]; then
        echo "Restoring database..."
        if [ "$DRY_RUN" = false ]; then
            gunzip -c "$RESTORE_POINT/database.sql.gz" | \
                psql -h localhost -U claude_flow claude_flow
        else
            echo "[DRY RUN] Would restore database"
        fi
    fi
else
    # Restore specific components
    for component in $(echo "$RESTORE_COMPONENTS" | tr ',' ' '); do
        case $component in
            config)
                restore_component "system-config" "/opt/claude-flow/config"
                ;;
            users)
                restore_component "user-data" "/home"
                ;;
            shared)
                restore_component "shared" "/opt/claude-flow/shared"
                ;;
            database)
                if [ -f "$RESTORE_POINT/database.sql.gz" ]; then
                    gunzip -c "$RESTORE_POINT/database.sql.gz" | \
                        psql -h localhost -U claude_flow claude_flow
                fi
                ;;
        esac
    done
fi

# Post-restore tasks
if [ "$DRY_RUN" = false ]; then
    echo "Running post-restore tasks..."
    
    # Fix permissions
    chown -R root:root /opt/claude-flow
    find /opt/claude-flow -type d -exec chmod 755 {} \;
    find /opt/claude-flow -type f -exec chmod 644 {} \;
    find /opt/claude-flow/bin -type f -exec chmod 755 {} \;
    
    # Rebuild caches
    claude-flow cache rebuild
    
    # Start services
    echo "Starting Claude Flow services..."
    systemctl start claude-flow-daemon
fi

echo "Recovery completed successfully!"
```

### 2. Point-in-Time Recovery

```python
#!/usr/bin/env python3
# point_in_time_recovery.py

import os
import json
import tarfile
from datetime import datetime, timedelta
from pathlib import Path

class PointInTimeRecovery:
    def __init__(self, backup_root='/backup/claude-flow'):
        self.backup_root = Path(backup_root)
        self.backups = self.scan_backups()
    
    def scan_backups(self):
        """Scan and index all available backups"""
        backups = []
        
        for backup_dir in self.backup_root.glob('*-*'):
            manifest_path = backup_dir / 'manifest.json'
            if manifest_path.exists():
                with open(manifest_path) as f:
                    manifest = json.load(f)
                
                backups.append({
                    'path': backup_dir,
                    'timestamp': datetime.fromisoformat(
                        manifest['timestamp'].replace('Z', '+00:00')
                    ),
                    'type': manifest['type'],
                    'components': manifest['components']
                })
        
        return sorted(backups, key=lambda x: x['timestamp'])
    
    def find_recovery_point(self, target_time):
        """Find backups needed for point-in-time recovery"""
        # Find last full backup before target time
        full_backup = None
        for backup in reversed(self.backups):
            if backup['type'] == 'full' and backup['timestamp'] <= target_time:
                full_backup = backup
                break
        
        if not full_backup:
            raise ValueError("No full backup found before target time")
        
        # Find incremental backups between full and target
        incrementals = []
        for backup in self.backups:
            if (backup['type'] == 'incremental' and 
                full_backup['timestamp'] < backup['timestamp'] <= target_time):
                incrementals.append(backup)
        
        return full_backup, incrementals
    
    def restore_to_point(self, target_time, destination='/tmp/restore'):
        """Restore to specific point in time"""
        full_backup, incrementals = self.find_recovery_point(target_time)
        
        print(f"Recovery plan:")
        print(f"- Full backup: {full_backup['timestamp']}")
        for inc in incrementals:
            print(f"- Incremental: {inc['timestamp']}")
        
        # Create destination
        dest_path = Path(destination)
        dest_path.mkdir(exist_ok=True)
        
        # Restore full backup
        self.extract_backup(full_backup['path'], dest_path)
        
        # Apply incrementals in order
        for incremental in incrementals:
            self.apply_incremental(incremental['path'], dest_path)
        
        return dest_path
    
    def extract_backup(self, backup_path, destination):
        """Extract backup to destination"""
        for component_file in backup_path.glob('*.tar.gz'):
            with tarfile.open(component_file, 'r:gz') as tar:
                tar.extractall(destination)
    
    def apply_incremental(self, backup_path, destination):
        """Apply incremental backup over existing files"""
        for component_file in backup_path.glob('*.tar.gz'):
            with tarfile.open(component_file, 'r:gz') as tar:
                # Extract only newer files
                for member in tar.getmembers():
                    dest_file = destination / member.name
                    if not dest_file.exists() or \
                       member.mtime > dest_file.stat().st_mtime:
                        tar.extract(member, destination)

# Usage example
if __name__ == '__main__':
    import sys
    
    if len(sys.argv) != 2:
        print("Usage: point_in_time_recovery.py 'YYYY-MM-DD HH:MM:SS'")
        sys.exit(1)
    
    target_time = datetime.fromisoformat(sys.argv[1])
    recovery = PointInTimeRecovery()
    
    restore_path = recovery.restore_to_point(target_time)
    print(f"\nRestored to: {restore_path}")
```

### 3. Selective Recovery

```bash
#!/bin/bash
# selective_restore.sh

# Function to list files in backup
list_backup_contents() {
    local backup_file=$1
    
    echo "Contents of $backup_file:"
    tar -tzf "$backup_file" | head -20
    echo "... (showing first 20 files)"
}

# Function to extract specific files
extract_files() {
    local backup_file=$1
    local file_pattern=$2
    local destination=$3
    
    echo "Extracting files matching: $file_pattern"
    tar -xzf "$backup_file" -C "$destination" --wildcards "$file_pattern"
}

# Interactive file recovery
interactive_recovery() {
    local backup_dir=$1
    
    echo "Available backups:"
    ls -la "$backup_dir"/*.tar.gz*
    
    read -p "Select backup file: " backup_file
    
    if [ ! -f "$backup_file" ]; then
        echo "File not found"
        return 1
    fi
    
    list_backup_contents "$backup_file"
    
    read -p "Enter file pattern to restore (e.g., '*.conf'): " pattern
    read -p "Restore to directory: " dest_dir
    
    mkdir -p "$dest_dir"
    extract_files "$backup_file" "$pattern" "$dest_dir"
    
    echo "Files restored to: $dest_dir"
}

# User file recovery
recover_user_files() {
    local username=$1
    local backup_dir="/backup/claude-flow/latest"
    
    echo "Recovering files for user: $username"
    
    # Create temporary directory
    TEMP_DIR="/tmp/claude-recovery-$$"
    mkdir -p "$TEMP_DIR"
    
    # Extract user data
    tar -xzf "$backup_dir/user-data.tar.gz" \
        -C "$TEMP_DIR" \
        --wildcards "*/${username}/.claude/*"
    
    # Show recovered files
    echo "Recovered files:"
    find "$TEMP_DIR" -type f -name "*" | grep "$username"
    
    read -p "Restore to user's home directory? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
        cp -r "$TEMP_DIR/home/$username/.claude" "/home/$username/"
        chown -R "$username:$username" "/home/$username/.claude"
        echo "Files restored successfully"
    fi
    
    # Cleanup
    rm -rf "$TEMP_DIR"
}

# Main menu
case "$1" in
    list)
        list_backup_contents "$2"
        ;;
    extract)
        extract_files "$2" "$3" "$4"
        ;;
    interactive)
        interactive_recovery "$2"
        ;;
    user)
        recover_user_files "$2"
        ;;
    *)
        echo "Usage: $0 {list|extract|interactive|user} [args...]"
        echo "  list <backup_file> - List contents of backup"
        echo "  extract <backup_file> <pattern> <destination> - Extract specific files"
        echo "  interactive <backup_dir> - Interactive recovery"
        echo "  user <username> - Recover user files"
        exit 1
        ;;
esac
```

## Disaster Recovery

### 1. DR Plan Template

```markdown
# Claude Flow Disaster Recovery Plan

## Contact Information
- Primary Contact: DevOps Team (devops@company.com)
- Secondary Contact: IT Manager (it-manager@company.com)
- Vendor Support: support@claude-flow.com

## Recovery Objectives
- **RTO (Recovery Time Objective)**: 4 hours
- **RPO (Recovery Point Objective)**: 24 hours
- **Service Level**: 99.9% availability

## Disaster Scenarios

### 1. Server Failure
**Impact**: Complete service outage
**Recovery Steps**:
1. Activate standby server
2. Restore from latest backup
3. Update DNS/load balancer
4. Verify service functionality

### 2. Data Corruption
**Impact**: Invalid configuration or user data
**Recovery Steps**:
1. Identify corruption scope
2. Restore affected components from backup
3. Verify data integrity
4. Run consistency checks

### 3. Ransomware Attack
**Impact**: Encrypted files, service unavailable
**Recovery Steps**:
1. Isolate affected systems
2. Restore from offline backup
3. Apply security patches
4. Reset all credentials

## Recovery Procedures

### Phase 1: Assessment (0-30 minutes)
- [ ] Identify disaster type and scope
- [ ] Notify stakeholders
- [ ] Activate DR team
- [ ] Document timeline

### Phase 2: Recovery (30 minutes - 3 hours)
- [ ] Execute recovery procedures
- [ ] Restore from backups
- [ ] Verify system integrity
- [ ] Test core functionality

### Phase 3: Validation (3-4 hours)
- [ ] Run comprehensive tests
- [ ] Verify user access
- [ ] Check data consistency
- [ ] Monitor performance

### Phase 4: Communication
- [ ] Update status page
- [ ] Notify users of restoration
- [ ] Document lessons learned
- [ ] Update DR procedures
```

### 2. DR Automation

```python
#!/usr/bin/env python3
# disaster_recovery.py

import subprocess
import json
import time
from enum import Enum
from datetime import datetime

class DisasterType(Enum):
    SERVER_FAILURE = "server_failure"
    DATA_CORRUPTION = "data_corruption"
    RANSOMWARE = "ransomware"
    NETWORK_OUTAGE = "network_outage"

class DisasterRecoveryOrchestrator:
    def __init__(self):
        self.config = self.load_config()
        self.start_time = datetime.now()
        self.recovery_log = []
    
    def load_config(self):
        with open('/opt/claude-flow/config/dr.json') as f:
            return json.load(f)
    
    def log(self, message, level='INFO'):
        entry = {
            'timestamp': datetime.now().isoformat(),
            'level': level,
            'message': message
        }
        self.recovery_log.append(entry)
        print(f"[{entry['timestamp']}] {level}: {message}")
    
    def assess_disaster(self):
        """Automatic disaster assessment"""
        checks = {
            'server_responsive': self.check_server_health(),
            'data_integrity': self.check_data_integrity(),
            'file_accessible': self.check_file_access(),
            'network_connectivity': self.check_network()
        }
        
        # Determine disaster type
        if not checks['server_responsive']:
            return DisasterType.SERVER_FAILURE
        elif not checks['data_integrity']:
            return DisasterType.DATA_CORRUPTION
        elif not checks['file_accessible']:
            return DisasterType.RANSOMWARE
        elif not checks['network_connectivity']:
            return DisasterType.NETWORK_OUTAGE
        
        return None
    
    def execute_recovery(self, disaster_type):
        """Execute recovery based on disaster type"""
        self.log(f"Initiating recovery for: {disaster_type.value}", 'CRITICAL')
        
        # Notify stakeholders
        self.send_notifications(disaster_type)
        
        # Execute recovery procedures
        recovery_map = {
            DisasterType.SERVER_FAILURE: self.recover_server_failure,
            DisasterType.DATA_CORRUPTION: self.recover_data_corruption,
            DisasterType.RANSOMWARE: self.recover_ransomware,
            DisasterType.NETWORK_OUTAGE: self.recover_network_outage
        }
        
        recovery_function = recovery_map.get(disaster_type)
        if recovery_function:
            success = recovery_function()
            
            if success:
                self.log("Recovery completed successfully")
                self.post_recovery_validation()
            else:
                self.log("Recovery failed - escalating", 'ERROR')
                self.escalate_to_manual()
    
    def recover_server_failure(self):
        """Recover from server failure"""
        self.log("Starting server failure recovery")
        
        # 1. Activate standby server
        if not self.activate_standby():
            return False
        
        # 2. Restore latest backup
        backup_path = self.get_latest_backup()
        if not self.restore_backup(backup_path):
            return False
        
        # 3. Update load balancer
        if not self.update_load_balancer():
            return False
        
        # 4. Verify services
        return self.verify_services()
    
    def recover_data_corruption(self):
        """Recover from data corruption"""
        self.log("Starting data corruption recovery")
        
        # 1. Identify corrupted components
        corrupted = self.identify_corruption()
        
        # 2. Stop affected services
        self.stop_services()
        
        # 3. Restore corrupted components
        for component in corrupted:
            if not self.restore_component(component):
                return False
        
        # 4. Run integrity checks
        if not self.verify_data_integrity():
            return False
        
        # 5. Restart services
        return self.start_services()
    
    def post_recovery_validation(self):
        """Validate recovery success"""
        self.log("Running post-recovery validation")
        
        tests = [
            ('Service Health', self.test_service_health),
            ('User Access', self.test_user_access),
            ('Data Integrity', self.test_data_integrity),
            ('Performance', self.test_performance)
        ]
        
        results = {}
        for test_name, test_func in tests:
            self.log(f"Running test: {test_name}")
            results[test_name] = test_func()
        
        # Generate report
        self.generate_recovery_report(results)
        
        return all(results.values())
    
    def generate_recovery_report(self, test_results):
        """Generate comprehensive recovery report"""
        report = {
            'disaster_start': self.start_time.isoformat(),
            'recovery_end': datetime.now().isoformat(),
            'duration_minutes': (datetime.now() - self.start_time).seconds / 60,
            'test_results': test_results,
            'recovery_log': self.recovery_log,
            'recommendations': self.generate_recommendations()
        }
        
        # Save report
        report_path = f"/var/log/claude-flow/dr-report-{self.start_time.strftime('%Y%m%d-%H%M%S')}.json"
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        self.log(f"Recovery report saved: {report_path}")

# Command-line interface
if __name__ == '__main__':
    import sys
    
    orchestrator = DisasterRecoveryOrchestrator()
    
    if len(sys.argv) > 1 and sys.argv[1] == '--auto':
        # Automatic disaster detection and recovery
        disaster_type = orchestrator.assess_disaster()
        if disaster_type:
            orchestrator.execute_recovery(disaster_type)
        else:
            print("No disaster detected")
    else:
        # Manual disaster recovery
        print("Select disaster type:")
        for i, dt in enumerate(DisasterType):
            print(f"{i+1}. {dt.value}")
        
        choice = int(input("Enter choice: ")) - 1
        disaster_type = list(DisasterType)[choice]
        
        orchestrator.execute_recovery(disaster_type)
```

### 3. DR Testing

```bash
#!/bin/bash
# dr_test.sh

# DR Test Scenarios
run_dr_test() {
    local test_type=$1
    local test_env="/tmp/claude-dr-test"
    
    echo "=== Claude Flow DR Test: $test_type ==="
    echo "Test started: $(date)"
    
    # Create test environment
    mkdir -p "$test_env"
    
    case $test_type in
        "backup-restore")
            test_backup_restore
            ;;
        "failover")
            test_failover
            ;;
        "corruption")
            test_corruption_recovery
            ;;
        "performance")
            test_recovery_performance
            ;;
        "full")
            test_backup_restore
            test_failover
            test_corruption_recovery
            test_recovery_performance
            ;;
    esac
    
    echo "Test completed: $(date)"
}

test_backup_restore() {
    echo "Testing backup and restore process..."
    
    # Create test data
    mkdir -p "$test_env/data"
    echo "test data" > "$test_env/data/test.txt"
    
    # Perform backup
    ./claude-flow-backup.sh --source "$test_env/data" --dest "$test_env/backup"
    
    # Simulate data loss
    rm -rf "$test_env/data"
    
    # Restore
    ./claude-flow-restore.sh --backup "$test_env/backup/latest" --dest "$test_env/data"
    
    # Verify
    if [ -f "$test_env/data/test.txt" ]; then
        echo "✓ Backup/restore test passed"
        return 0
    else
        echo "✗ Backup/restore test failed"
        return 1
    fi
}

test_failover() {
    echo "Testing failover process..."
    
    # Simulate primary failure
    echo "Simulating primary server failure..."
    
    # Activate standby
    ./activate-standby.sh --test-mode
    
    # Verify standby is active
    if curl -s http://standby.company.com/health | grep -q "ok"; then
        echo "✓ Failover test passed"
        return 0
    else
        echo "✗ Failover test failed"
        return 1
    fi
}

test_corruption_recovery() {
    echo "Testing corruption recovery..."
    
    # Create test file
    echo "good data" > "$test_env/config.json"
    
    # Backup
    cp "$test_env/config.json" "$test_env/config.json.backup"
    
    # Corrupt file
    echo "corrupted" > "$test_env/config.json"
    
    # Detect and recover
    if ! json_verify "$test_env/config.json" 2>/dev/null; then
        echo "Corruption detected, recovering..."
        cp "$test_env/config.json.backup" "$test_env/config.json"
    fi
    
    # Verify recovery
    if grep -q "good data" "$test_env/config.json"; then
        echo "✓ Corruption recovery test passed"
        return 0
    else
        echo "✗ Corruption recovery test failed"
        return 1
    fi
}

test_recovery_performance() {
    echo "Testing recovery performance..."
    
    # Measure recovery time
    START_TIME=$(date +%s)
    
    # Simulate recovery
    ./claude-flow-restore.sh --backup "$test_env/backup/latest" --dest "$test_env/restore" --dry-run
    
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    echo "Recovery time: ${DURATION}s"
    
    # Check against RTO
    RTO_SECONDS=$((4 * 3600))  # 4 hours
    if [ $DURATION -lt $RTO_SECONDS ]; then
        echo "✓ Recovery performance test passed"
        return 0
    else
        echo "✗ Recovery performance test failed (exceeds RTO)"
        return 1
    fi
}

# Schedule regular DR tests
schedule_dr_tests() {
    cat > /etc/cron.d/claude-dr-tests << EOF
# Monthly full DR test
0 2 1 * * root /opt/claude-flow/scripts/dr_test.sh full >> /var/log/claude-flow/dr-tests.log 2>&1

# Weekly backup test
0 3 * * 0 root /opt/claude-flow/scripts/dr_test.sh backup-restore >> /var/log/claude-flow/dr-tests.log 2>&1

# Quarterly failover test
0 4 1 */3 * root /opt/claude-flow/scripts/dr_test.sh failover >> /var/log/claude-flow/dr-tests.log 2>&1
EOF
}

# Main execution
if [ $# -eq 0 ]; then
    echo "Usage: $0 {backup-restore|failover|corruption|performance|full|schedule}"
    exit 1
fi

case "$1" in
    schedule)
        schedule_dr_tests
        echo "DR tests scheduled"
        ;;
    *)
        run_dr_test "$1"
        ;;
esac
```

## Backup Verification

### 1. Integrity Checking

```python
#!/usr/bin/env python3
# backup_verify.py

import hashlib
import json
import tarfile
from pathlib import Path
from datetime import datetime

class BackupVerifier:
    def __init__(self, backup_path):
        self.backup_path = Path(backup_path)
        self.verification_log = []
    
    def verify_backup(self):
        """Comprehensive backup verification"""
        print(f"Verifying backup: {self.backup_path}")
        
        checks = {
            'manifest': self.verify_manifest(),
            'checksums': self.verify_checksums(),
            'completeness': self.verify_completeness(),
            'integrity': self.verify_integrity(),
            'restoration': self.verify_restoration()
        }
        
        # Generate report
        self.generate_verification_report(checks)
        
        return all(checks.values())
    
    def verify_manifest(self):
        """Verify backup manifest exists and is valid"""
        manifest_path = self.backup_path / 'manifest.json'
        
        if not manifest_path.exists():
            self.log("Manifest file missing", "ERROR")
            return False
        
        try:
            with open(manifest_path) as f:
                manifest = json.load(f)
            
            required_fields = ['timestamp', 'type', 'components']
            for field in required_fields:
                if field not in manifest:
                    self.log(f"Manifest missing field: {field}", "ERROR")
                    return False
            
            self.log("Manifest verified", "OK")
            return True
            
        except json.JSONDecodeError as e:
            self.log(f"Invalid manifest JSON: {e}", "ERROR")
            return False
    
    def verify_checksums(self):
        """Verify file checksums"""
        checksum_file = self.backup_path / 'checksums.sha256'
        
        if not checksum_file.exists():
            self.log("Checksum file missing", "WARNING")
            return True  # Non-critical
        
        errors = 0
        with open(checksum_file) as f:
            for line in f:
                if not line.strip():
                    continue
                
                checksum, filename = line.strip().split('  ')
                file_path = self.backup_path / Path(filename).name
                
                if not file_path.exists():
                    self.log(f"File missing: {filename}", "ERROR")
                    errors += 1
                    continue
                
                # Calculate actual checksum
                actual = self.calculate_checksum(file_path)
                if actual != checksum:
                    self.log(f"Checksum mismatch: {filename}", "ERROR")
                    errors += 1
        
        if errors == 0:
            self.log("All checksums verified", "OK")
            return True
        else:
            self.log(f"Checksum errors: {errors}", "ERROR")
            return False
    
    def verify_integrity(self):
        """Verify archive integrity"""
        archives = list(self.backup_path.glob('*.tar.gz'))
        
        for archive in archives:
            try:
                with tarfile.open(archive, 'r:gz') as tar:
                    # Test archive can be read
                    tar.getmembers()
                self.log(f"Archive integrity OK: {archive.name}", "OK")
            except Exception as e:
                self.log(f"Archive corrupted: {archive.name} - {e}", "ERROR")
                return False
        
        return True
    
    def verify_restoration(self):
        """Test restoration in sandbox"""
        test_dir = Path('/tmp/backup-verify-test')
        test_dir.mkdir(exist_ok=True)
        
        try:
            # Test extracting each component
            for archive in self.backup_path.glob('*.tar.gz'):
                with tarfile.open(archive, 'r:gz') as tar:
                    # Extract first few files as test
                    members = tar.getmembers()[:5]
                    for member in members:
                        tar.extract(member, test_dir)
            
            self.log("Restoration test passed", "OK")
            return True
            
        except Exception as e:
            self.log(f"Restoration test failed: {e}", "ERROR")
            return False
        finally:
            # Cleanup
            import shutil
            shutil.rmtree(test_dir, ignore_errors=True)
    
    def calculate_checksum(self, file_path):
        """Calculate SHA256 checksum of file"""
        sha256 = hashlib.sha256()
        with open(file_path, 'rb') as f:
            for chunk in iter(lambda: f.read(4096), b''):
                sha256.update(chunk)
        return sha256.hexdigest()
    
    def log(self, message, level):
        """Add entry to verification log"""
        entry = {
            'timestamp': datetime.now().isoformat(),
            'level': level,
            'message': message
        }
        self.verification_log.append(entry)
        print(f"[{level}] {message}")
    
    def generate_verification_report(self, checks):
        """Generate verification report"""
        report = {
            'backup_path': str(self.backup_path),
            'verification_date': datetime.now().isoformat(),
            'checks': checks,
            'passed': all(checks.values()),
            'log': self.verification_log
        }
        
        report_path = self.backup_path / 'verification-report.json'
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\nVerification report: {report_path}")
        print(f"Overall result: {'PASSED' if report['passed'] else 'FAILED'}")

if __name__ == '__main__':
    import sys
    
    if len(sys.argv) != 2:
        print("Usage: backup_verify.py <backup_directory>")
        sys.exit(1)
    
    verifier = BackupVerifier(sys.argv[1])
    success = verifier.verify_backup()
    sys.exit(0 if success else 1)
```

## Monitoring & Alerts

### 1. Backup Monitoring

```yaml
# prometheus-backup-alerts.yml
groups:
  - name: backup_alerts
    rules:
      - alert: BackupFailed
        expr: claude_flow_backup_last_success_timestamp < time() - 86400
        for: 1h
        labels:
          severity: critical
        annotations:
          summary: "Claude Flow backup has not succeeded in 24 hours"
          
      - alert: BackupSizeTooSmall
        expr: claude_flow_backup_size_bytes < 1000000
        for: 30m
        labels:
          severity: warning
        annotations:
          summary: "Backup size unexpectedly small"
          
      - alert: BackupDurationHigh
        expr: claude_flow_backup_duration_seconds > 3600
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Backup taking longer than expected"
```

### 2. Recovery Metrics

```sql
-- Backup and recovery metrics table
CREATE TABLE backup_metrics (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operation VARCHAR(50),  -- backup, restore, verify
    status VARCHAR(20),     -- success, failure, partial
    duration_seconds INTEGER,
    size_bytes BIGINT,
    components TEXT[],
    error_message TEXT
);

-- Recovery performance view
CREATE VIEW recovery_performance AS
SELECT 
    DATE_TRUNC('month', timestamp) as month,
    AVG(CASE WHEN operation = 'backup' THEN duration_seconds END) as avg_backup_time,
    AVG(CASE WHEN operation = 'restore' THEN duration_seconds END) as avg_restore_time,
    COUNT(CASE WHEN status = 'failure' THEN 1 END) as failures,
    COUNT(*) as total_operations
FROM backup_metrics
GROUP BY DATE_TRUNC('month', timestamp);
```

## Best Practices

### 1. Backup Best Practices

```markdown
## Claude Flow Backup Best Practices

### Frequency
- **Full Backups**: Weekly (Sunday 2 AM)
- **Incremental**: Daily (2 AM)
- **Critical Data**: Hourly snapshots

### Retention Policy
- **Daily Backups**: 7 days
- **Weekly Backups**: 4 weeks
- **Monthly Backups**: 12 months
- **Yearly Backups**: 7 years (compliance)

### Storage
- **3-2-1 Rule**: 3 copies, 2 different media, 1 offsite
- **Encryption**: Always encrypt sensitive backups
- **Compression**: Use for non-database files
- **Deduplication**: Enable for storage efficiency

### Testing
- **Monthly**: Restore random files
- **Quarterly**: Full restoration test
- **Annually**: Complete DR simulation

### Documentation
- Keep recovery procedures updated
- Document all passwords/keys separately
- Maintain contact lists current
- Review and update quarterly
```

### 2. Recovery Checklist

```markdown
## Recovery Checklist

### Pre-Recovery
- [ ] Identify failure scope
- [ ] Notify stakeholders
- [ ] Locate appropriate backup
- [ ] Prepare recovery environment
- [ ] Review recovery procedures

### During Recovery
- [ ] Stop affected services
- [ ] Create current state backup
- [ ] Execute recovery procedure
- [ ] Monitor progress
- [ ] Document any deviations

### Post-Recovery
- [ ] Verify data integrity
- [ ] Test functionality
- [ ] Update documentation
- [ ] Conduct post-mortem
- [ ] Implement improvements
```

## Next Steps

- Review DR plan quarterly
- Schedule regular backup tests
- Update recovery procedures
- Train team on procedures
- Automate where possible