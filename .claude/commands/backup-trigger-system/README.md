# Multi-Trigger Coordination System for Backup State Transitions

A comprehensive trigger system that drives backup state transitions through coordinated git hooks, time-based policies, disk-space monitoring, and user commands with atomic operations and robust error handling.

## System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Git Hooks     │    │  Time Triggers  │    │ Disk Triggers   │
│                 │    │                 │    │                 │
│ • Post-commit   │    │ • Retention     │    │ • Space Monitor │
│ • Post-merge    │    │ • Age Policies  │    │ • Emergency     │
│ • Pre-push      │    │ • Schedules     │    │ • Cleanup       │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────▼─────────────┐
                    │   Central Coordinator     │
                    │                           │
                    │ • State Machine           │
                    │ • Conflict Resolution     │
                    │ • Atomic Transitions      │
                    │ • Rollback Capability     │
                    │ • Confidence Scoring      │
                    └─────────────┬─────────────┘
                                 │
          ┌──────────────────────┼──────────────────────┐
          │                      │                      │
┌─────────▼───────┐    ┌─────────▼───────┐    ┌─────────▼───────┐
│ User Commands   │    │ Configuration   │    │   Monitoring    │
│                 │    │                 │    │                 │
│ • Interactive   │    │ • Policies      │    │ • Metrics       │
│ • Force Actions │    │ • Thresholds    │    │ • Alerts        │
│ • Confirmations │    │ • Validation    │    │ • Dashboard     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Backup State Transitions

The system manages backups through a well-defined state machine:

```
CREATED ──┐
          │ (git commit)
          ▼
        PENDING ──┐
                  │ (git merge)
                  ▼
               CONFIRMED ──┐
                           │ (time/policy)
                           ▼
                        CLEANABLE ──┬─► ARCHIVED ──► DELETED
                                    │
                                    └─► DELETED
```

### State Descriptions

- **CREATED**: Initial backup created, awaiting git activity
- **PENDING**: Backup confirmed by commit, awaiting merge/integration  
- **CONFIRMED**: Backup validated by successful merge
- **CLEANABLE**: Backup eligible for cleanup based on policies
- **ARCHIVED**: Backup moved to compressed long-term storage
- **DELETED**: Backup permanently removed

## Components

### 1. Central Coordinator (`coordinator.md`)

The heart of the system that manages all state transitions with:

- **Atomic Operations**: All transitions are atomic with rollback capability
- **Conflict Resolution**: Handles concurrent trigger requests with priority system
- **Confidence Scoring**: Safety-first approach with multiple confidence factors
- **State Validation**: Enforces valid state transition rules
- **Metrics Collection**: Tracks all transitions for monitoring

**Key Features:**
- Lock-based concurrency control
- Checkpoint/rollback system for failed transitions
- Priority-based trigger coordination
- Comprehensive audit logging

### 2. Git Hook Integration (`git-hooks.md`)

Seamless integration with git workflow events:

- **Post-commit**: Transitions backups from CREATED → PENDING
- **Post-merge**: Transitions backups from PENDING → CONFIRMED  
- **Pre-push**: Evaluates backups for CLEANABLE state

**Safety Features:**
- Backup-commit relationship verification
- Merge confidence scoring
- Push success confirmation
- Orphaned backup cleanup

### 3. Time-Based Triggers (`time-triggers.md`)

Automated policy enforcement with configurable retention:

- **Age-based Transitions**: Automatic state changes based on backup age
- **Retention Policies**: Configurable timeout periods for each state
- **Emergency Timeouts**: Accelerated cleanup during disk pressure
- **Value Assessment**: Prevents deletion of valuable backups

**Daemon Features:**
- Continuous monitoring with configurable intervals
- Policy-driven decision making
- Graceful shutdown handling
- Performance metrics collection

### 4. Disk Space Triggers (`disk-triggers.md`)

Real-time space monitoring with emergency response:

- **Threshold Monitoring**: Warning, Critical, and Emergency levels
- **Priority Cleanup**: Oldest-first, largest-first, or confidence-based
- **Emergency Protocols**: Aggressive cleanup during space crises
- **Alert System**: Notifications via email, webhook, or Slack

**Cleanup Strategies:**
- Conservative: High confidence only
- Aggressive: Lower confidence, faster cleanup
- Nuclear: Emergency cleanup of almost all backups

### 5. User Command Interface (`user-triggers.md`)

Interactive control with safety checks:

- **Manual Transitions**: User-initiated state changes with confirmation
- **Batch Operations**: Force cleanup of multiple backups
- **Status Monitoring**: Detailed backup information and system dashboard
- **Emergency Interface**: Guided emergency cleanup procedures

**Safety Features:**
- Interactive confirmations for destructive operations
- Confidence score warnings
- Double confirmation for risky operations
- Comprehensive status reporting

### 6. Configuration System (`config.md`)

Centralized configuration with validation:

- **Policy Management**: Timeout periods, confidence thresholds, disk limits
- **Feature Toggles**: Enable/disable system components
- **Templates**: Conservative, aggressive, and development configurations
- **Import/Export**: Configuration backup and sharing

**Configuration Features:**
- Interactive setup wizard
- Real-time validation
- Template-based setup
- Secure storage with proper permissions

## Installation and Setup

### Quick Start

1. **Initialize the system:**
   ```bash
   source .claude/commands/backup-trigger-system/config.md
   backup-config wizard
   ```

2. **Install git hooks:**
   ```bash
   source .claude/commands/backup-trigger-system/git-hooks.md
   install_backup_git_hooks
   ```

3. **Start daemons:**
   ```bash
   # Time-based triggers
   source .claude/commands/backup-trigger-system/time-triggers.md
   start_time_trigger_daemon
   
   # Disk space monitoring
   source .claude/commands/backup-trigger-system/disk-triggers.md
   start_disk_monitor_daemon
   ```

### Advanced Setup

1. **Configure for your environment:**
   ```bash
   # Conservative setup (high safety)
   backup-config conservative
   
   # Aggressive setup (faster cleanup)
   backup-config aggressive
   
   # Development setup (testing)
   backup-config development
   ```

2. **Customize policies:**
   ```bash
   # Update timeout periods
   backup-config update PENDING_TO_CLEANUP_TIMEOUT 86400  # 1 day
   
   # Adjust confidence thresholds
   backup-config update AUTO_CLEANUP_CONFIDENCE 0.90
   
   # Set disk space limits
   backup-config update DISK_WARNING_THRESHOLD 70
   ```

## Usage Examples

### User Commands

```bash
# List backups by state
backup list cleanable size 10

# Show detailed backup status
backup status backup_20241201_143022

# Manually confirm a backup
backup confirm backup_20241201_143022

# Cleanup a specific backup
backup cleanup backup_20241201_143022

# Force cleanup multiple backups
backup force-cleanup moderate 5

# Emergency cleanup interface
backup emergency

# Monitor system status
backup monitor
```

### System Administration

```bash
# Check system status
backup-coordinator status

# Monitor disk usage
backup-disk-triggers status

# View recent transitions
tail -f ~/.claude/backup-config/metrics/transitions.log

# Emergency stop all daemons
pkill -f backup-time-trigger
pkill -f backup-disk-monitor
```

## Safety Features

### Multi-Layer Protection

1. **Confidence Scoring**: Every cleanup decision includes confidence calculation
2. **State Validation**: Invalid transitions are rejected
3. **User Confirmations**: Interactive prompts for destructive operations
4. **Atomic Operations**: All-or-nothing transitions with rollback
5. **Emergency Stops**: Immediate halt capability for all operations

### Confidence Factors

The system calculates confidence scores based on:

- **Age**: Older backups have higher cleanup confidence
- **Git Integration**: Merged backups are safer to clean
- **Size**: Larger backups get extra scrutiny
- **Access Patterns**: Recently accessed backups are preserved
- **Test Coverage**: Backups with test relationships are protected
- **Dynamic Usage**: Framework patterns and dynamic loading detection

### Rollback and Recovery

- **Transaction Checkpoints**: Before each transition
- **State Recovery**: Automatic rollback on failure
- **Configuration Backup**: Automatic config versioning
- **Archive Verification**: Integrity checks for compressed backups

## Integration with Existing Systems

### Git Hook Infrastructure

Seamlessly integrates with existing `.claude/commands/git/_shared/hooks.md`:

- Extends existing hook templates
- Preserves current hook functionality
- Adds backup transition triggers
- Maintains hook performance

### Cleanup Command Integration

Works with existing `.claude/commands/cleanup.md` patterns:

- Uses same confidence scoring methodology
- Respects framework detection patterns
- Maintains safety-first principles
- Provides enhanced cleanup capabilities

## Monitoring and Metrics

### Real-time Monitoring

- **System Dashboard**: Overall system health and activity
- **Transition Logs**: Detailed record of all state changes
- **Performance Metrics**: Operation timing and resource usage
- **Disk Usage Trends**: Historical space utilization

### Alerting

Configurable alerts for:

- Critical disk space usage
- Failed state transitions
- Emergency cleanup activations
- System component failures

### Reporting

- Daily/weekly backup reports
- Cleanup effectiveness metrics
- Disk space trends
- System performance analysis

## Troubleshooting

### Common Issues

1. **Stuck Transitions**: Check lock files and process status
2. **High Disk Usage**: Review cleanup policies and thresholds
3. **Failed Git Hooks**: Verify hook installation and permissions
4. **Configuration Errors**: Run validation and check syntax

### Debug Mode

Enable comprehensive logging:

```bash
backup-config update DEBUG_MODE true
backup-config update LOG_LEVEL DEBUG
```

### Emergency Recovery

If the system becomes unresponsive:

1. Stop all daemons: `pkill -f backup-`
2. Clear lock files: `rm -f /tmp/backup_*.lock`
3. Check disk space: `df -h`
4. Review logs: `tail -100 ~/.claude/backup-config/backup-triggers.log`
5. Restart with safe configuration

## Contributing

When extending the system:

1. Follow the confidence scoring methodology
2. Implement atomic operations with rollback
3. Add comprehensive logging
4. Include configuration validation
5. Write integration tests
6. Update documentation

The system is designed to be extensible while maintaining safety and reliability as core principles.