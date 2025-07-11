# Claude Flow Update and Maintenance Guide

## Overview

This guide covers updating Claude Flow installations, managing version transitions, and maintaining system health over time.

## Update Strategies

### 1. Update Channels

```json
{
  "update": {
    "channel": "stable",  // stable, beta, nightly
    "check_frequency": "daily",
    "auto_update": false,
    "notify_only": true
  }
}
```

**Available Channels:**
- **stable**: Production-ready releases (recommended)
- **beta**: Pre-release versions for testing
- **nightly**: Latest development builds
- **custom**: Internal/enterprise channel

### 2. Version Naming

```
Format: MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]

Examples:
- 2.1.0         (stable release)
- 2.2.0-beta.1  (beta release)
- 2.2.0-rc.1    (release candidate)
- 2.2.0+20240115 (build metadata)
```

## Manual Updates

### 1. System-Wide Update

```bash
#!/bin/bash
# update-claude-flow.sh

CLAUDE_HOME="/opt/claude-flow"
BACKUP_DIR="/opt/backups/claude-flow"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Pre-update checks
echo "=== Claude Flow Update Process ==="
echo "Current version: $(claude-flow --version)"

# Create backup
echo "Creating backup..."
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/claude-flow-$TIMESTAMP.tar.gz" "$CLAUDE_HOME"

# Stop any running services
if systemctl is-active claude-flow-daemon &>/dev/null; then
    sudo systemctl stop claude-flow-daemon
fi

# Fetch updates
cd "$CLAUDE_HOME/core"
git fetch origin

# Check available versions
echo "Available versions:"
git tag -l "v*" | sort -V | tail -5

# Update to specific version or latest
if [ -n "$1" ]; then
    VERSION="$1"
else
    VERSION=$(git describe --tags $(git rev-list --tags --max-count=1))
fi

echo "Updating to version: $VERSION"
git checkout "$VERSION"

# Run update scripts
if [ -f "$CLAUDE_HOME/core/scripts/post-update.sh" ]; then
    bash "$CLAUDE_HOME/core/scripts/post-update.sh"
fi

# Verify update
echo "New version: $(claude-flow --version)"

# Restart services
if systemctl is-enabled claude-flow-daemon &>/dev/null; then
    sudo systemctl start claude-flow-daemon
fi

echo "Update complete!"
```

### 2. User Update

```bash
#!/bin/bash
# ~/.claude-flow/update.sh

CLAUDE_HOME="$HOME/.claude-flow"
USER_DATA="$HOME/.claude"

echo "Updating Claude Flow (User Installation)..."

# Backup user data
tar -czf "$USER_DATA/backup-$(date +%Y%m%d).tar.gz" \
    "$USER_DATA/commands" \
    "$USER_DATA/templates" \
    "$USER_DATA/config"

# Update application
cd "$CLAUDE_HOME"
git pull origin main

# Update dependencies
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt --user
fi

# Run migrations
if [ -f "scripts/migrate.sh" ]; then
    bash scripts/migrate.sh
fi

echo "Update complete!"
claude-flow --version
```

## Automatic Updates

### 1. Update Daemon

```python
#!/usr/bin/env python3
# claude-flow-updater.py

import subprocess
import json
import time
import logging
from datetime import datetime, timedelta

class ClaudeFlowUpdater:
    def __init__(self, config_path='/opt/claude-flow/config/update.json'):
        with open(config_path) as f:
            self.config = json.load(f)
        
        self.logger = logging.getLogger('claude-flow-updater')
        
    def check_for_updates(self):
        """Check if updates are available"""
        try:
            # Fetch latest tags
            subprocess.run(['git', 'fetch', '--tags'], 
                         cwd=self.config['install_path'])
            
            # Get current version
            current = subprocess.check_output(
                ['git', 'describe', '--tags'],
                cwd=self.config['install_path']
            ).decode().strip()
            
            # Get latest version
            latest = subprocess.check_output(
                ['git', 'describe', '--tags', '--abbrev=0', 'origin/main'],
                cwd=self.config['install_path']
            ).decode().strip()
            
            return current != latest, current, latest
            
        except Exception as e:
            self.logger.error(f"Update check failed: {e}")
            return False, None, None
    
    def apply_update(self, version):
        """Apply update to specified version"""
        try:
            # Create backup
            backup_path = self.create_backup()
            
            # Apply update
            subprocess.run(
                ['git', 'checkout', version],
                cwd=self.config['install_path'],
                check=True
            )
            
            # Run post-update scripts
            self.run_post_update_scripts()
            
            # Verify update
            if self.verify_update():
                self.logger.info(f"Successfully updated to {version}")
                return True
            else:
                # Rollback
                self.rollback(backup_path)
                return False
                
        except Exception as e:
            self.logger.error(f"Update failed: {e}")
            self.rollback(backup_path)
            return False
    
    def create_backup(self):
        """Create backup before update"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_path = f"{self.config['backup_dir']}/pre-update-{timestamp}.tar.gz"
        
        subprocess.run([
            'tar', '-czf', backup_path,
            self.config['install_path']
        ], check=True)
        
        return backup_path
    
    def run(self):
        """Main update loop"""
        while True:
            if self.should_check():
                has_update, current, latest = self.check_for_updates()
                
                if has_update:
                    if self.config.get('auto_update'):
                        self.apply_update(latest)
                    else:
                        self.notify_update_available(current, latest)
            
            time.sleep(3600)  # Check hourly

if __name__ == '__main__':
    updater = ClaudeFlowUpdater()
    updater.run()
```

### 2. SystemD Service

```ini
# /etc/systemd/system/claude-flow-updater.service
[Unit]
Description=Claude Flow Auto-Updater
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/claude-flow/scripts/updater.py
Restart=always
RestartSec=3600
User=claude-flow
Group=claude-flow

[Install]
WantedBy=multi-user.target
```

## Version Management

### 1. Version Pinning

```json
{
  "version_policy": {
    "pin_version": "2.1.0",
    "allow_patch_updates": true,
    "allow_minor_updates": false,
    "allow_major_updates": false
  }
}
```

### 2. Gradual Rollout

```yaml
# rollout-config.yml
rollout:
  version: "2.2.0"
  strategy: "canary"
  stages:
    - name: "canary"
      percentage: 5
      duration: "24h"
      criteria:
        error_rate: "< 1%"
        performance: "no degradation"
    
    - name: "pilot"
      percentage: 20
      duration: "48h"
      
    - name: "production"
      percentage: 100
```

### 3. Version Compatibility Matrix

```json
{
  "compatibility": {
    "2.2.0": {
      "min_config_version": "1.0",
      "max_config_version": "2.0",
      "breaking_changes": [],
      "deprecations": ["old_command_format"]
    },
    "2.1.0": {
      "min_config_version": "1.0",
      "max_config_version": "1.5",
      "breaking_changes": ["api_v1_removed"],
      "migrations_required": true
    }
  }
}
```

## Migration Procedures

### 1. Pre-Update Validation

```bash
#!/bin/bash
# pre-update-check.sh

echo "=== Pre-Update Validation ==="

# Check disk space
REQUIRED_SPACE_MB=500
AVAILABLE_SPACE_MB=$(df -m /opt/claude-flow | awk 'NR==2 {print $4}')

if [ "$AVAILABLE_SPACE_MB" -lt "$REQUIRED_SPACE_MB" ]; then
    echo "ERROR: Insufficient disk space"
    exit 1
fi

# Check dependencies
echo "Checking dependencies..."
command -v git >/dev/null 2>&1 || { echo "ERROR: git required"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 required"; exit 1; }

# Verify backup location
if [ ! -d "/opt/backups/claude-flow" ]; then
    echo "Creating backup directory..."
    mkdir -p /opt/backups/claude-flow
fi

# Check for running processes
if pgrep -f "claude-flow" > /dev/null; then
    echo "WARNING: Claude Flow processes are running"
    echo "These will be stopped during update"
fi

echo "Pre-update validation passed!"
```

### 2. Data Migration

```python
#!/usr/bin/env python3
# migrate.py

import json
import os
import shutil
from pathlib import Path

class DataMigrator:
    def __init__(self, version_from, version_to):
        self.version_from = version_from
        self.version_to = version_to
        self.migrations = self.load_migrations()
    
    def load_migrations(self):
        """Load migration definitions"""
        migrations_path = Path(__file__).parent / 'migrations.json'
        with open(migrations_path) as f:
            return json.load(f)
    
    def migrate(self):
        """Run all necessary migrations"""
        migrations_to_run = self.get_migrations_to_run()
        
        for migration in migrations_to_run:
            print(f"Running migration: {migration['name']}")
            getattr(self, migration['method'])()
    
    def migrate_config_v1_to_v2(self):
        """Migrate configuration from v1 to v2 format"""
        old_config = Path.home() / '.claude' / 'config.json'
        new_config = Path.home() / '.claude' / 'config' / 'settings.json'
        
        if old_config.exists():
            # Create new config directory
            new_config.parent.mkdir(exist_ok=True)
            
            # Load old config
            with open(old_config) as f:
                data = json.load(f)
            
            # Transform to new format
            new_data = {
                'version': '2.0',
                'user': data.get('user', {}),
                'preferences': data.get('settings', {}),
                'features': {
                    'enabled': data.get('features', [])
                }
            }
            
            # Save new config
            with open(new_config, 'w') as f:
                json.dump(new_data, f, indent=2)
            
            # Archive old config
            shutil.move(old_config, old_config.with_suffix('.json.v1'))
    
    def migrate_commands_structure(self):
        """Migrate command structure to new format"""
        commands_dir = Path.home() / '.claude' / 'commands'
        
        for cmd_file in commands_dir.glob('*.sh'):
            # Read old format
            with open(cmd_file) as f:
                content = f.read()
            
            # Convert to new format
            new_content = self.convert_command_format(content)
            
            # Save with new extension
            new_path = cmd_file.with_suffix('.claude')
            with open(new_path, 'w') as f:
                f.write(new_content)
            
            # Archive old file
            shutil.move(cmd_file, cmd_file.with_suffix('.sh.old'))

if __name__ == '__main__':
    migrator = DataMigrator('2.1.0', '2.2.0')
    migrator.migrate()
```

### 3. Post-Update Validation

```bash
#!/bin/bash
# post-update-check.sh

echo "=== Post-Update Validation ==="

# Verify installation
if ! claude-flow --version &>/dev/null; then
    echo "ERROR: Claude Flow command not working"
    exit 1
fi

# Check configuration
if ! claude-flow config validate &>/dev/null; then
    echo "ERROR: Configuration validation failed"
    exit 1
fi

# Test basic functionality
echo "Testing basic commands..."
claude-flow list &>/dev/null || { echo "ERROR: List command failed"; exit 1; }

# Verify file permissions
find /opt/claude-flow -type f -name "*.sh" -exec chmod +x {} \;
find /opt/claude-flow -type d -exec chmod 755 {} \;

# Check service status
if systemctl is-enabled claude-flow-daemon &>/dev/null; then
    systemctl status claude-flow-daemon
fi

echo "Post-update validation passed!"
```

## Rollback Procedures

### 1. Automatic Rollback

```bash
#!/bin/bash
# rollback.sh

BACKUP_PATH="$1"
INSTALL_PATH="/opt/claude-flow"

if [ -z "$BACKUP_PATH" ]; then
    # Find latest backup
    BACKUP_PATH=$(ls -t /opt/backups/claude-flow/*.tar.gz | head -1)
fi

echo "Rolling back to: $BACKUP_PATH"

# Stop services
systemctl stop claude-flow-daemon 2>/dev/null

# Remove current installation
rm -rf "$INSTALL_PATH.rollback"
mv "$INSTALL_PATH" "$INSTALL_PATH.rollback"

# Restore from backup
tar -xzf "$BACKUP_PATH" -C /

# Restart services
systemctl start claude-flow-daemon 2>/dev/null

echo "Rollback complete!"
claude-flow --version
```

### 2. Rollback Triggers

```python
# health_monitor.py
class HealthMonitor:
    def __init__(self):
        self.thresholds = {
            'error_rate': 0.05,  # 5%
            'response_time': 2.0,  # seconds
            'memory_usage': 0.8   # 80%
        }
    
    def should_rollback(self):
        """Determine if rollback is needed"""
        metrics = self.collect_metrics()
        
        if metrics['error_rate'] > self.thresholds['error_rate']:
            return True, "High error rate"
        
        if metrics['response_time'] > self.thresholds['response_time']:
            return True, "Performance degradation"
        
        if metrics['memory_usage'] > self.thresholds['memory_usage']:
            return True, "High memory usage"
        
        return False, None
```

## Update Notifications

### 1. Email Notifications

```python
#!/usr/bin/env python3
# notify_updates.py

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_update_notification(version, changelog, recipients):
    """Send update notification email"""
    
    msg = MIMEMultipart()
    msg['Subject'] = f'Claude Flow Update Available: {version}'
    msg['From'] = 'claude-flow@company.com'
    msg['To'] = ', '.join(recipients)
    
    body = f"""
    A new version of Claude Flow is available: {version}
    
    Changelog:
    {changelog}
    
    To update:
    - System administrators: Run 'sudo claude-flow-update'
    - Individual users: Run 'claude-flow update'
    
    For more information, visit: https://docs.company.com/claude-flow/updates
    """
    
    msg.attach(MIMEText(body, 'plain'))
    
    with smtplib.SMTP('smtp.company.com') as server:
        server.send_message(msg)
```

### 2. Desktop Notifications

```bash
#!/bin/bash
# desktop-notify.sh

VERSION="$1"
CHANGELOG="$2"

# macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e "display notification \"Version $VERSION available\" with title \"Claude Flow Update\""
fi

# Linux (notify-send)
if command -v notify-send &>/dev/null; then
    notify-send "Claude Flow Update" "Version $VERSION available"
fi

# Windows (PowerShell)
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    powershell -Command "
    Add-Type -AssemblyName System.Windows.Forms
    \$notify = New-Object System.Windows.Forms.NotifyIcon
    \$notify.Icon = [System.Drawing.SystemIcons]::Information
    \$notify.Visible = \$true
    \$notify.ShowBalloonTip(10000, 'Claude Flow Update', 'Version $VERSION available', 'Info')
    "
fi
```

## Change Management

### 1. Change Log Generation

```python
#!/usr/bin/env python3
# generate_changelog.py

import subprocess
import re
from datetime import datetime

def generate_changelog(from_version, to_version):
    """Generate changelog between versions"""
    
    # Get commits between versions
    commits = subprocess.check_output([
        'git', 'log', f'{from_version}..{to_version}',
        '--pretty=format:%h %s (%an)',
        '--no-merges'
    ]).decode().strip().split('\n')
    
    # Categorize commits
    features = []
    fixes = []
    breaking = []
    other = []
    
    for commit in commits:
        if 'feat:' in commit or 'feature:' in commit:
            features.append(commit)
        elif 'fix:' in commit:
            fixes.append(commit)
        elif 'breaking:' in commit or 'BREAKING' in commit:
            breaking.append(commit)
        else:
            other.append(commit)
    
    # Generate changelog
    changelog = f"""
# Claude Flow {to_version}
Released: {datetime.now().strftime('%Y-%m-%d')}

## Breaking Changes
{format_commits(breaking)}

## New Features
{format_commits(features)}

## Bug Fixes
{format_commits(fixes)}

## Other Changes
{format_commits(other)}

## Upgrade Instructions
1. Backup your configuration: `claude-flow backup`
2. Update: `claude-flow update {to_version}`
3. Run migrations: `claude-flow migrate`
"""
    
    return changelog

def format_commits(commits):
    if not commits:
        return "- None"
    return '\n'.join(f"- {commit}" for commit in commits)
```

### 2. Version Documentation

```markdown
# Version History

## v2.2.0 (2024-01-15)
### Major Features
- New plugin architecture
- Enhanced performance monitoring
- Multi-language support

### Breaking Changes
- API v1 removed (use v2)
- Config format changed (auto-migration available)

### Migration Guide
```bash
# Before updating
claude-flow backup create pre-2.2.0

# Update
claude-flow update 2.2.0

# Run migrations
claude-flow migrate --from 2.1.0 --to 2.2.0

# Verify
claude-flow verify
```

## v2.1.0 (2023-12-01)
### Features
- Command templates
- Improved error handling
- New dashboard UI

### Fixes
- Memory leak in long-running processes
- Unicode handling in commands
```

## Testing Updates

### 1. Update Test Suite

```bash
#!/bin/bash
# test-update.sh

echo "=== Update Test Suite ==="

# Test environment setup
TEST_ENV="/tmp/claude-flow-test"
rm -rf "$TEST_ENV"
mkdir -p "$TEST_ENV"

# Clone test installation
cp -r /opt/claude-flow "$TEST_ENV/"

# Run update in test environment
cd "$TEST_ENV/claude-flow"
./update.sh "$1"

# Run test suite
echo "Running tests..."
pytest tests/ -v

# Performance tests
echo "Running performance tests..."
./tests/performance/benchmark.sh

# Integration tests
echo "Running integration tests..."
./tests/integration/run-all.sh

# Clean up
rm -rf "$TEST_ENV"
```

### 2. Canary Testing

```python
# canary_test.py
class CanaryTester:
    def __init__(self, version):
        self.version = version
        self.test_users = self.select_canary_users()
    
    def run_canary_test(self):
        """Run canary test with selected users"""
        results = {
            'success': 0,
            'failure': 0,
            'errors': []
        }
        
        for user in self.test_users:
            try:
                # Update user to new version
                self.update_user(user, self.version)
                
                # Run test workload
                if self.test_user_workload(user):
                    results['success'] += 1
                else:
                    results['failure'] += 1
                    
            except Exception as e:
                results['errors'].append({
                    'user': user,
                    'error': str(e)
                })
        
        return results
```

## Monitoring Updates

### 1. Update Metrics

```sql
-- Update tracking table
CREATE TABLE update_history (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    from_version VARCHAR(20),
    to_version VARCHAR(20),
    status VARCHAR(20),
    duration_seconds INTEGER,
    error_message TEXT,
    rollback BOOLEAN DEFAULT FALSE,
    user_count INTEGER,
    hostname VARCHAR(255)
);

-- Update success rate
SELECT 
    to_version,
    COUNT(*) as total_updates,
    SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as successful,
    AVG(duration_seconds) as avg_duration,
    SUM(CASE WHEN rollback THEN 1 ELSE 0 END) as rollbacks
FROM update_history
WHERE timestamp > NOW() - INTERVAL '30 days'
GROUP BY to_version
ORDER BY to_version DESC;
```

### 2. Update Dashboard

```html
<!DOCTYPE html>
<html>
<head>
    <title>Claude Flow Update Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <h1>Update Status</h1>
    <div id="current-version"></div>
    <div id="available-updates"></div>
    <canvas id="update-chart"></canvas>
    
    <script>
    // Fetch and display update metrics
    fetch('/api/updates/metrics')
        .then(res => res.json())
        .then(data => {
            document.getElementById('current-version').textContent = 
                `Current Version: ${data.current_version}`;
            
            // Display update chart
            new Chart(document.getElementById('update-chart'), {
                type: 'line',
                data: {
                    labels: data.dates,
                    datasets: [{
                        label: 'Update Success Rate',
                        data: data.success_rates
                    }]
                }
            });
        });
    </script>
</body>
</html>
```

## Best Practices

### 1. Update Checklist

```markdown
## Pre-Update Checklist
- [ ] Review changelog and breaking changes
- [ ] Backup current installation
- [ ] Test update in staging environment
- [ ] Notify users of maintenance window
- [ ] Verify rollback procedure
- [ ] Check disk space (500MB minimum)
- [ ] Ensure network connectivity

## During Update
- [ ] Monitor system resources
- [ ] Check for errors in logs
- [ ] Verify services are stopped
- [ ] Watch for migration issues

## Post-Update Checklist
- [ ] Verify new version is running
- [ ] Test core functionality
- [ ] Check service health
- [ ] Monitor error rates
- [ ] Verify user access
- [ ] Update documentation
- [ ] Notify users of completion
```

### 2. Update Frequency

```yaml
update_policy:
  production:
    major_versions: quarterly
    minor_versions: monthly
    patches: as_needed
    security: immediate
    
  staging:
    all_updates: weekly
    
  development:
    all_updates: daily
```

## Emergency Procedures

### 1. Emergency Patch

```bash
#!/bin/bash
# emergency-patch.sh

PATCH_URL="$1"
ISSUE_ID="$2"

echo "Applying emergency patch for issue: $ISSUE_ID"

# Download patch
curl -O "$PATCH_URL/claude-flow-patch-$ISSUE_ID.tar.gz"

# Verify signature
gpg --verify claude-flow-patch-$ISSUE_ID.tar.gz.sig

# Apply patch
tar -xzf claude-flow-patch-$ISSUE_ID.tar.gz -C /opt/claude-flow/

# Restart services
systemctl restart claude-flow-daemon

# Log patch application
echo "$(date): Applied patch $ISSUE_ID" >> /var/log/claude-flow/patches.log
```

### 2. Hotfix Process

```yaml
hotfix_process:
  steps:
    - identify: "Identify critical issue"
    - develop: "Develop fix on hotfix branch"
    - test: "Fast-track testing"
    - approve: "Emergency CAB approval"
    - deploy: "Deploy to production"
    - monitor: "24-hour monitoring"
    - backport: "Backport to main branch"
```

## Next Steps

- See backup-recovery.md for backup procedures
- Review security.md for secure update practices
- Consult system-deployment.md for system-wide updates
- Check monitoring guides for update tracking