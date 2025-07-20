# Enhanced Milestone System: Troubleshooting Guide and FAQ

## Table of Contents

1. [Installation and Setup Issues](#installation-and-setup-issues)
2. [Scale Detection and Backend Issues](#scale-detection-and-backend-issues)
3. [Multi-Agent Coordination Problems](#multi-agent-coordination-problems)
4. [Session Management and Recovery](#session-management-and-recovery)
5. [Kiro Workflow Issues](#kiro-workflow-issues)
6. [Performance and Optimization](#performance-and-optimization)
7. [Git Integration Problems](#git-integration-problems)
8. [Database and Migration Issues](#database-and-migration-issues)
9. [Configuration and Customization](#configuration-and-customization)
10. [Advanced Features and Enterprise](#advanced-features-and-enterprise)

## Installation and Setup Issues

### Q: Enhanced system won't install or upgrade from legacy version

**Symptoms:**
- Installation script fails with errors
- System reports "incompatible version"
- Migration process stops midway

**Solutions:**

1. **Check system requirements:**
```bash
# Verify Node.js version
node --version  # Should be 16+ (18+ recommended)

# Check Git availability
git --version   # Required for repository integration

# Verify disk space
df -h .        # Need at least 500MB available
```

2. **Clean installation approach:**
```bash
# Backup existing data
cp -r .milestones .milestones.backup.$(date +%Y%m%d_%H%M%S)

# Remove any corrupted installation files
rm -rf node_modules/.milestone-cache
rm -f .milestones/config/.migration-lock

# Reinstall with clean slate
curl -L https://releases.github.com/enhanced-milestone-system/latest/install.sh | bash
```

3. **Manual migration for complex cases:**
```bash
# Step-by-step migration
./scripts/migrate-legacy-data.sh --debug --step-by-step

# If specific step fails, resume from that point
./scripts/migrate-legacy-data.sh --resume-from-step 3
```

### Q: System doesn't recognize existing milestone data

**Symptoms:**
- `/milestone/update` shows no milestones
- "No milestone data found" message
- System creates new `.milestones` directory

**Solutions:**

1. **Check data location:**
```bash
# Verify milestone data exists
ls -la .milestones/

# Check if data is in different location
find . -name "*.yaml" -path "*milestone*" -type f

# Set correct data path if needed
export MILESTONE_DATA_PATH="/path/to/your/milestones"
```

2. **Validate data format:**
```bash
# Check milestone file format
head -20 .milestones/active/milestone-001.yaml

# Validate YAML syntax
yq validate .milestones/active/*.yaml

# Fix common format issues
./scripts/fix-milestone-format.sh
```

3. **Import existing data:**
```bash
# Import from different format
/milestone/import --from-format legacy --path .old-milestones/

# Force data refresh
/milestone/update --refresh-all-data
```

## Scale Detection and Backend Issues

### Q: System not scaling to appropriate backend (stuck on file mode)

**Symptoms:**
- Many milestones but still using file backend
- Slow performance with complex queries
- Scale detection shows incorrect metrics

**Solutions:**

1. **Check scale detection status:**
```bash
# View current scale metrics
/milestone/update --scale-detection-status

# Force scale recalculation
/milestone/update --recalculate-scale

# View detailed metrics
./scripts/analyze-scale-metrics.sh
```

2. **Manual scale configuration:**
```bash
# Force specific backend
cat >> .milestones/config/milestone-config.yaml << EOF
backend_override: sqlite  # or postgresql
auto_scale: false
EOF

# Apply changes
/milestone/update --reload-config
```

3. **Investigate scale detection issues:**
```bash
# Debug scale detection logic
./scripts/debug-scale-detection.sh

# Check common issues
ls -la .milestones/active/ | wc -l  # Count milestones
du -sh .milestones/                 # Check data size
ps aux | grep milestone             # Check running processes
```

### Q: Database backend fails to initialize

**Symptoms:**
- "Database connection failed" errors
- System reverts to file backend unexpectedly
- SQLite/PostgreSQL errors in logs

**Solutions:**

1. **SQLite backend issues:**
```bash
# Check SQLite installation
sqlite3 --version

# Test database creation
sqlite3 .milestones/data/test.db "CREATE TABLE test (id INTEGER); DROP TABLE test;"

# Fix permissions
chmod 755 .milestones/data/
chmod 644 .milestones/data/*.db

# Reset database
rm .milestones/data/milestones.db
/milestone/update --reset-database
```

2. **PostgreSQL backend issues:**
```bash
# Check PostgreSQL connection
psql -h localhost -U milestone_user -d milestone_db -c "SELECT 1;"

# Verify connection string
echo $DATABASE_URL

# Test with minimal connection
psql $DATABASE_URL -c "SELECT version();"

# Reset connection pool
/milestone/update --reset-connection-pool
```

3. **Database permissions and configuration:**
```bash
# Check database configuration
cat .milestones/config/database-config.yaml

# Verify user permissions
psql $DATABASE_URL -c "SELECT current_user, session_user;"

# Reset database schema
./scripts/reset-database-schema.sh
```

## Multi-Agent Coordination Problems

### Q: Agents not deploying or failing to coordinate

**Symptoms:**
- "No agents deployed" message
- Agents crash or become unresponsive
- Poor coordination between agents

**Solutions:**

1. **Check agent system status:**
```bash
# View agent status
/milestone/update --agent-system-status

# Check agent logs
tail -f .milestones/logs/agent-*.log

# Verify agent processes
ps aux | grep "milestone-agent"
```

2. **Restart agent system:**
```bash
# Stop all agents
./scripts/stop-all-agents.sh

# Clean agent state
rm -rf .milestones/sessions/agents/

# Restart with fresh configuration
/milestone/execute milestone-id --restart-agents
```

3. **Reduce agent complexity:**
```bash
# Use fewer agents if resource constrained
/milestone/execute milestone-id --agents 2 --coordination simple

# Disable specific agent types
cat >> .milestones/config/milestone-config.yaml << EOF
agents:
  task_executor: true
  progress_monitor: true
  git_integration: false    # Disable if causing issues
  dependency_validator: false
  blocker_detector: false
EOF
```

### Q: Agent coordination causing conflicts or poor performance

**Symptoms:**
- Multiple agents modifying same files
- High CPU usage from agent processes
- Conflicting Git operations

**Solutions:**

1. **Adjust coordination strategy:**
```bash
# Use sequential coordination instead of parallel
/milestone/execute milestone-id --coordination sequential

# Reduce coordination frequency
cat >> .milestones/config/milestone-config.yaml << EOF
coordination:
  update_frequency: 60s    # Increase from default 30s
  conflict_resolution: "conservative"
  resource_limits:
    max_cpu_percent: 50
    max_memory_mb: 1024
EOF
```

2. **Debug coordination issues:**
```bash
# Monitor agent communication
./scripts/monitor-agent-coordination.sh

# Check for resource conflicts
./scripts/check-agent-conflicts.sh

# Analyze coordination performance
./scripts/analyze-coordination-performance.sh
```

3. **Implement coordination fixes:**
```bash
# Enable file locking
echo "file_locking: true" >> .milestones/config/milestone-config.yaml

# Adjust agent priority
./scripts/set-agent-priorities.sh

# Monitor system resources
top -p $(pgrep -d, milestone-agent)
```

## Session Management and Recovery

### Q: Sessions not saving or resume failing

**Symptoms:**
- "No saved session found" when trying to resume
- Session data appears corrupted
- Resume starts from beginning instead of checkpoint

**Solutions:**

1. **Check session management status:**
```bash
# View session status
/milestone/update --session-status

# List available sessions
ls -la .milestones/sessions/

# Validate session data
./scripts/validate-session-data.sh
```

2. **Fix session management:**
```bash
# Reset session management
rm -rf .milestones/sessions/corrupted-*
./scripts/reset-session-management.sh

# Adjust session settings
cat >> .milestones/config/milestone-config.yaml << EOF
session_management:
  checkpoint_frequency: 10m  # Increase if having frequent issues
  max_retry_attempts: 3
  backup_sessions: true
  auto_cleanup: false        # Disable cleanup to debug
EOF
```

3. **Manual session recovery:**
```bash
# Find latest valid session
./scripts/find-latest-session.sh milestone-id

# Manually restore from session
./scripts/restore-from-session.sh session-20240713-001

# Resume with specific session
/milestone/execute milestone-id --resume-session session-20240713-001
```

### Q: Session conflicts with multiple users or processes

**Symptoms:**
- "Session already active" errors
- Multiple conflicting sessions
- Lost work due to session conflicts

**Solutions:**

1. **Resolve session conflicts:**
```bash
# Check active sessions
./scripts/list-active-sessions.sh

# Force cleanup of stale sessions
./scripts/cleanup-stale-sessions.sh

# Set session ownership
./scripts/set-session-owner.sh milestone-id $USER
```

2. **Configure multi-user sessions:**
```bash
# Enable collaborative sessions
cat >> .milestones/config/milestone-config.yaml << EOF
session_management:
  multi_user: true
  conflict_resolution: "merge"  # or "last_writer_wins"
  user_isolation: false
  shared_sessions: true
EOF
```

3. **Implement session locking:**
```bash
# Use file locking for sessions
echo "session_locking: true" >> .milestones/config/milestone-config.yaml

# Set session timeout
echo "session_timeout: 3600" >> .milestones/config/milestone-config.yaml  # 1 hour
```

## Kiro Workflow Issues

### Q: Kiro phases not transitioning properly

**Symptoms:**
- Stuck in design phase despite completion
- Approval workflow not triggering
- Phase deliverables not generated

**Solutions:**

1. **Check Kiro workflow status:**
```bash
# View workflow status
/milestone/update milestone-id --kiro-status

# Check phase deliverables
ls -la .milestones/deliverables/task-id/

# Validate phase completion
./scripts/validate-kiro-phases.sh milestone-id task-id
```

2. **Force phase transitions:**
```bash
# Manually complete current phase
./scripts/complete-kiro-phase.sh milestone-id task-id design

# Force transition to next phase
./scripts/transition-kiro-phase.sh milestone-id task-id design spec

# Reset phase if stuck
./scripts/reset-kiro-phase.sh milestone-id task-id
```

3. **Fix Kiro configuration:**
```bash
# Disable approvals temporarily
cat >> .milestones/config/milestone-config.yaml << EOF
kiro_workflow:
  approval_required: false
  auto_transition: true
  phase_timeout: 24h
EOF

# Regenerate phase deliverables
./scripts/regenerate-kiro-deliverables.sh milestone-id task-id
```

### Q: Kiro approval workflow not working

**Symptoms:**
- Approvals not being requested
- Approved phases not proceeding
- Missing approval notifications

**Solutions:**

1. **Configure approval workflow:**
```bash
# Check approval configuration
cat .milestones/config/milestone-config.yaml | grep -A 10 approval

# Set up approvers
cat >> .milestones/config/milestone-config.yaml << EOF
approval_workflow:
  design_approvers: ["tech-lead", "architect"]
  spec_approvers: ["tech-lead", "product-manager"]
  auto_approve_after: 48h
  notification_channels: ["slack", "email"]
EOF
```

2. **Manual approval management:**
```bash
# List pending approvals
./scripts/list-pending-approvals.sh

# Manually approve phase
./scripts/approve-phase.sh milestone-id task-id design tech-lead

# Bypass approval for testing
./scripts/bypass-approval.sh milestone-id task-id design
```

3. **Debug approval notifications:**
```bash
# Test notification system
./scripts/test-notifications.sh

# Check notification logs
tail -f .milestones/logs/notifications.log

# Reset notification system
./scripts/reset-notifications.sh
```

## Performance and Optimization

### Q: System running slowly with large number of milestones

**Symptoms:**
- Slow response times for commands
- High memory usage
- Long startup times

**Solutions:**

1. **Performance analysis:**
```bash
# Benchmark current performance
./scripts/benchmark-system.sh

# Analyze performance bottlenecks
./scripts/analyze-performance.sh

# Check resource usage
./scripts/check-resource-usage.sh
```

2. **Optimize database performance:**
```bash
# For SQLite backend
./scripts/optimize-sqlite.sh

# For PostgreSQL backend
./scripts/optimize-postgresql.sh

# Rebuild indexes
./scripts/rebuild-indexes.sh

# Clean up old data
./scripts/cleanup-old-data.sh
```

3. **System optimization:**
```bash
# Enable caching
cat >> .milestones/config/milestone-config.yaml << EOF
cache:
  enabled: true
  type: memory
  ttl: 300
  max_size: 100MB
EOF

# Adjust system limits
cat >> .milestones/config/milestone-config.yaml << EOF
performance:
  max_concurrent_operations: 10
  batch_size: 50
  lazy_loading: true
EOF
```

### Q: High memory usage or memory leaks

**Symptoms:**
- Memory usage continuously growing
- System becomes unresponsive
- Out of memory errors

**Solutions:**

1. **Monitor memory usage:**
```bash
# Monitor milestone system memory
ps aux | grep milestone | awk '{print $6}' | paste -sd+ - | bc

# Check for memory leaks
./scripts/check-memory-leaks.sh

# Monitor agent memory usage
./scripts/monitor-agent-memory.sh
```

2. **Reduce memory footprint:**
```bash
# Limit agent memory
cat >> .milestones/config/milestone-config.yaml << EOF
agents:
  memory_limit: 256MB
  enable_gc: true
  gc_frequency: 30s
EOF

# Disable memory-intensive features
echo "features.advanced_analytics: false" >> .milestones/config/milestone-config.yaml
```

3. **Fix memory leaks:**
```bash
# Restart agents periodically
echo "agents.restart_interval: 1h" >> .milestones/config/milestone-config.yaml

# Enable memory debugging
echo "debug.memory_profiling: true" >> .milestones/config/milestone-config.yaml

# Clear caches regularly
./scripts/clear-caches.sh
```

## Git Integration Problems

### Q: Git integration not working or creating conflicts

**Symptoms:**
- Milestone branches not created
- Git conflicts during milestone execution
- Commit messages malformed

**Solutions:**

1. **Check Git integration status:**
```bash
# Verify Git integration
/milestone/update --git-status

# Check Git configuration
git config -l | grep milestone

# Test Git operations
./scripts/test-git-integration.sh
```

2. **Fix Git configuration:**
```bash
# Configure Git for milestones
git config milestone.auto-branch true
git config milestone.commit-format "feat(milestone-{id}): {description}"
git config milestone.branch-prefix "milestone/"

# Reset Git integration
./scripts/reset-git-integration.sh
```

3. **Resolve Git conflicts:**
```bash
# Check for conflicts
git status --porcelain | grep "^UU"

# Resolve merge conflicts
./scripts/resolve-milestone-conflicts.sh

# Clean up problematic branches
git branch -D milestone/milestone-problematic
./scripts/cleanup-milestone-branches.sh
```

### Q: Milestone branches cluttering repository

**Symptoms:**
- Too many milestone branches
- Old branches not being cleaned up
- Confusion about active branches

**Solutions:**

1. **Configure branch management:**
```bash
# Enable automatic cleanup
cat >> .milestones/config/milestone-config.yaml << EOF
git_integration:
  auto_cleanup_branches: true
  cleanup_after_days: 30
  preserve_completed: false
  merge_strategy: "squash"
EOF
```

2. **Manual branch cleanup:**
```bash
# List milestone branches
git branch | grep "milestone/"

# Clean up completed milestone branches
./scripts/cleanup-completed-branches.sh

# Archive old branches
./scripts/archive-old-branches.sh
```

3. **Optimize branch strategy:**
```bash
# Use single branch for small projects
echo "git_integration.single_branch_mode: true" >> .milestones/config/milestone-config.yaml

# Configure branch naming
cat >> .milestones/config/milestone-config.yaml << EOF
git_integration:
  branch_naming: "ms-{id}"    # Shorter names
  branch_cleanup: "aggressive"
  auto_merge: true
EOF
```

## Database and Migration Issues

### Q: Database migration failures or data corruption

**Symptoms:**
- Migration stops with errors
- Data missing after migration
- Database integrity issues

**Solutions:**

1. **Validate database integrity:**
```bash
# Check database health
./scripts/check-database-health.sh

# Validate data integrity
./scripts/validate-data-integrity.sh

# Check for corruption
sqlite3 .milestones/data/milestones.db "PRAGMA integrity_check;"
```

2. **Fix migration issues:**
```bash
# Rollback failed migration
./scripts/rollback-migration.sh

# Resume migration from checkpoint
./scripts/resume-migration.sh --from-checkpoint latest

# Force migration with data repair
./scripts/migrate-with-repair.sh
```

3. **Repair database corruption:**
```bash
# Backup current database
cp .milestones/data/milestones.db .milestones/data/milestones.db.backup

# Repair SQLite database
sqlite3 .milestones/data/milestones.db ".recover" > recovered.sql
sqlite3 .milestones/data/milestones_new.db < recovered.sql

# Verify repaired database
./scripts/verify-database-repair.sh
```

### Q: Backend switching causing data loss

**Symptoms:**
- Milestones missing after backend change
- Inconsistent data between backends
- Performance degradation after switch

**Solutions:**

1. **Prevent data loss during switching:**
```bash
# Create backup before any backend change
./scripts/backup-before-switch.sh

# Use conservative switching
echo "backend_switching.conservative_mode: true" >> .milestones/config/milestone-config.yaml

# Verify data after switch
./scripts/verify-data-after-switch.sh
```

2. **Fix data inconsistencies:**
```bash
# Compare data between backends
./scripts/compare-backends.sh

# Sync missing data
./scripts/sync-backend-data.sh

# Rebuild indexes and cache
./scripts/rebuild-backend-structures.sh
```

3. **Optimize backend performance:**
```bash
# Tune database settings
./scripts/tune-database-performance.sh

# Optimize queries
./scripts/optimize-database-queries.sh

# Enable query caching
echo "database.query_cache: true" >> .milestones/config/milestone-config.yaml
```

## Configuration and Customization

### Q: Configuration changes not taking effect

**Symptoms:**
- System behavior unchanged after config updates
- Config validation errors
- Features not enabling/disabling as expected

**Solutions:**

1. **Validate configuration:**
```bash
# Validate config syntax
./scripts/validate-config.sh

# Check config loading
/milestone/update --show-config

# Test config changes
./scripts/test-config-changes.sh
```

2. **Force configuration reload:**
```bash
# Reload configuration
/milestone/update --reload-config

# Restart system with new config
./scripts/restart-milestone-system.sh

# Clear config cache
rm .milestones/config/.config-cache
```

3. **Debug configuration issues:**
```bash
# Show effective configuration
./scripts/show-effective-config.sh

# Check config precedence
./scripts/check-config-precedence.sh

# Reset to default configuration
./scripts/reset-to-default-config.sh
```

### Q: Custom workflows or templates not working

**Symptoms:**
- Custom templates not loading
- Workflow steps not executing
- Template variables not substituting

**Solutions:**

1. **Validate custom templates:**
```bash
# Check template syntax
./scripts/validate-templates.sh

# Test template rendering
./scripts/test-template-rendering.sh

# Debug template variables
./scripts/debug-template-variables.sh
```

2. **Fix template issues:**
```bash
# Reset template cache
rm -rf .milestones/templates/.cache/

# Reload custom templates
./scripts/reload-custom-templates.sh

# Use default templates temporarily
echo "templates.use_defaults: true" >> .milestones/config/milestone-config.yaml
```

3. **Configure custom workflows:**
```bash
# Validate workflow definition
./scripts/validate-workflow.sh custom-workflow

# Test workflow execution
./scripts/test-workflow.sh custom-workflow

# Debug workflow steps
./scripts/debug-workflow-steps.sh custom-workflow
```

## Advanced Features and Enterprise

### Q: Enterprise features not available or not working

**Symptoms:**
- Advanced analytics not showing
- Compliance features disabled
- Portfolio management unavailable

**Solutions:**

1. **Check enterprise feature enablement:**
```bash
# Verify enterprise mode
/milestone/update --enterprise-status

# Check feature licenses
./scripts/check-feature-licenses.sh

# Enable enterprise features
echo "enterprise_mode: true" >> .milestones/config/milestone-config.yaml
```

2. **Configure enterprise settings:**
```bash
# Set up enterprise database
./scripts/setup-enterprise-database.sh

# Enable advanced features
cat >> .milestones/config/milestone-config.yaml << EOF
enterprise:
  advanced_analytics: true
  compliance_tracking: true
  portfolio_management: true
  resource_optimization: true
EOF
```

3. **Troubleshoot enterprise issues:**
```bash
# Check enterprise dependencies
./scripts/check-enterprise-dependencies.sh

# Validate enterprise configuration
./scripts/validate-enterprise-config.sh

# Test enterprise features
./scripts/test-enterprise-features.sh
```

### Q: Integration with external systems failing

**Symptoms:**
- Slack/Teams notifications not working
- JIRA integration broken
- CI/CD integration failing

**Solutions:**

1. **Test external integrations:**
```bash
# Test Slack integration
./scripts/test-slack-integration.sh

# Test JIRA connection
./scripts/test-jira-connection.sh

# Test CI/CD webhooks
./scripts/test-cicd-webhooks.sh
```

2. **Fix integration configurations:**
```bash
# Update integration credentials
./scripts/update-integration-credentials.sh

# Reset integration state
./scripts/reset-integration-state.sh

# Validate integration settings
./scripts/validate-integrations.sh
```

3. **Debug integration issues:**
```bash
# Check integration logs
tail -f .milestones/logs/integrations.log

# Monitor webhook delivery
./scripts/monitor-webhooks.sh

# Test integration endpoints
./scripts/test-integration-endpoints.sh
```

## General Troubleshooting Tips

### Emergency Recovery Procedures

1. **System completely broken:**
```bash
# Emergency reset (preserves data)
./scripts/emergency-reset.sh

# Restore from backup
./scripts/restore-from-backup.sh latest

# Minimal working configuration
./scripts/minimal-config.sh
```

2. **Data corruption suspected:**
```bash
# Comprehensive data validation
./scripts/comprehensive-data-validation.sh

# Repair data corruption
./scripts/repair-data-corruption.sh

# Rebuild from Git history
./scripts/rebuild-from-git.sh
```

3. **Performance emergency:**
```bash
# Emergency performance mode
echo "performance.emergency_mode: true" >> .milestones/config/milestone-config.yaml

# Stop all non-essential agents
./scripts/stop-non-essential-agents.sh

# Clear all caches
./scripts/emergency-cache-clear.sh
```

### Best Practices for Prevention

1. **Regular maintenance:**
```bash
# Weekly health check
./scripts/weekly-health-check.sh

# Monthly optimization
./scripts/monthly-optimization.sh

# Backup automation
./scripts/setup-automatic-backups.sh
```

2. **Monitoring setup:**
```bash
# Enable comprehensive monitoring
cat >> .milestones/config/milestone-config.yaml << EOF
monitoring:
  health_checks: true
  performance_alerts: true
  error_tracking: true
  usage_analytics: true
EOF
```

3. **Documentation and logging:**
```bash
# Enable debug logging
echo "debug.level: verbose" >> .milestones/config/milestone-config.yaml

# Document customizations
./scripts/document-customizations.sh

# Create troubleshooting runbook
./scripts/create-runbook.sh
```

## Getting Additional Help

### Support Resources

**Documentation:**
- User Guide: `/docs/user-guide/enhanced-milestone-system.md`
- Architecture Guide: `/docs/architecture/enhanced-hybrid-architecture.md`
- Migration Guide: `/docs/migration/upgrade-to-enhanced-system.md`

**Diagnostic Tools:**
```bash
# Generate comprehensive diagnostic report
./scripts/generate-diagnostics.sh > system-diagnostics.txt

# System health summary
/milestone/update --health-summary

# Performance analysis report
./scripts/performance-report.sh > performance-analysis.txt
```

**Community Support:**
- GitHub Issues: Report bugs and get community help
- Documentation Wiki: Community-maintained troubleshooting tips
- Discussion Forum: Ask questions and share solutions

### Professional Support Options

**For Enterprise Users:**
- Priority support with guaranteed response times
- Custom troubleshooting and optimization
- Migration assistance and training
- Custom development for specific requirements

**Support Channels:**
- Email: support@milestone-system.com
- Slack: #milestone-support
- Video calls: Available for enterprise customers

Remember: Most issues can be resolved with the built-in diagnostic and repair tools. Always create backups before making significant changes, and don't hesitate to use the emergency recovery procedures if needed.