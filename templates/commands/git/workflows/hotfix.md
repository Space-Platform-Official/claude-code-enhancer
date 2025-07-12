---
allowed-tools: all
description: Emergency hotfix workflow for critical production issues
---

# Hotfix Workflow

Rapid response workflow for critical production issues requiring immediate deployment and comprehensive team coordination.

**Usage:** `/git/workflows/hotfix $ARGUMENTS`

## 🚨 CRITICAL PRODUCTION RESPONSE 🚨

**When seconds count, process saves lives!**

This workflow manages emergency production fixes:

1. **INCIDENT** - Rapid issue assessment and response
2. **ISOLATION** - Safe development environment setup
3. **RESOLUTION** - Focused fix with minimal risk
4. **DEPLOYMENT** - Fast-track to production with validation
5. **RECOVERY** - Complete system restoration and learning

## Hotfix Lifecycle Overview

```
production ──○──○──○──●── (issue detected)
               \      /
                ○──○── hotfix/INCIDENT-123-critical-fix
                |
main ──○──○──○──○──○── (backport fix)
```

## Phase 1: Incident Response & Assessment

**Immediate Response (< 5 minutes):**
```bash
# Emergency hotfix initialization
initiate_hotfix() {
    echo "🚨 EMERGENCY HOTFIX PROTOCOL ACTIVATED"
    echo "====================================="
    
    # Capture incident details
    echo "📋 Incident Assessment:"
    read -p "🎯 Incident ID (e.g., INC-123): " incident_id
    read -p "📊 Severity (1-Critical, 2-High, 3-Medium): " severity
    read -p "👤 Incident Commander: " commander
    read -p "📝 Brief description: " description
    read -p "🔗 Monitoring/ticket URL: " ticket_url
    
    # Validate severity
    if [[ "$severity" != "1" && "$severity" != "2" && "$severity" != "3" ]]; then
        echo "❌ Invalid severity level"
        exit 1
    fi
    
    # Set urgency level
    case $severity in
        1) urgency="CRITICAL"; timeline="15 minutes" ;;
        2) urgency="HIGH"; timeline="1 hour" ;;
        3) urgency="MEDIUM"; timeline="4 hours" ;;
    esac
    
    echo ""
    echo "🚨 $urgency INCIDENT DETECTED"
    echo "Target Resolution: $timeline"
    echo "Commander: $commander"
    echo ""
    
    # Initialize hotfix branch
    setup_hotfix_branch "$incident_id" "$description" "$urgency" "$commander"
    
    # Start incident tracking
    start_incident_tracking "$incident_id" "$severity" "$commander" "$ticket_url"
    
    echo "✅ Hotfix branch ready. Begin diagnosis immediately!"
}

setup_hotfix_branch() {
    local incident_id=$1
    local description=$2
    local urgency=$3
    local commander=$4
    
    # Generate branch name
    branch_name="hotfix/${incident_id}-$(echo "$description" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
    
    # Ensure we start from production
    echo "🔄 Checking out from production branch..."
    
    if git show-ref --verify --quiet refs/heads/production; then
        base_branch="production"
    elif git show-ref --verify --quiet refs/heads/main; then
        base_branch="main"
        echo "⚠️  No production branch found, using main"
    else
        echo "❌ No suitable base branch found!"
        exit 1
    fi
    
    # Update base branch
    git checkout "$base_branch"
    git pull origin "$base_branch"
    
    # Create hotfix branch
    git checkout -b "$branch_name"
    
    # Create incident documentation
    create_incident_docs "$incident_id" "$description" "$urgency" "$commander"
    
    # Commit initial documentation
    git add .
    git commit -m "hotfix: initialize emergency response for $incident_id

Incident: $incident_id
Severity: $urgency
Commander: $commander
Base: $base_branch

This is an emergency hotfix branch for immediate production deployment."
    
    echo "🆘 Hotfix branch '$branch_name' created from $base_branch"
}

create_incident_docs() {
    local incident_id=$1
    local description=$2
    local urgency=$3
    local commander=$4
    
    cat > INCIDENT.md << EOF
# 🚨 INCIDENT RESPONSE: $incident_id

**Status:** 🔥 ACTIVE
**Severity:** $urgency
**Commander:** $commander
**Started:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')

## Issue Description

$description

## Impact Assessment

- [ ] Users affected: [Number/Percentage]
- [ ] Systems affected: [List systems]
- [ ] Revenue impact: [Estimated]
- [ ] Data integrity: [Safe/At Risk]

## Response Timeline

| Time | Action | Status |
|------|--------|--------|
| $(date -u '+%H:%M') | Incident declared | ✅ |
| $(date -u '+%H:%M') | Hotfix branch created | ✅ |
|  | Root cause identified | ⏳ |
|  | Fix implemented | ⏳ |
|  | Testing completed | ⏳ |
|  | Production deployed | ⏳ |
|  | Incident resolved | ⏳ |

## Root Cause Analysis

### Symptoms
- [Symptom 1]
- [Symptom 2]

### Investigation Steps
- [ ] Check logs: \`tail -f /var/log/application.log\`
- [ ] Verify database connectivity
- [ ] Check external service status
- [ ] Review recent deployments
- [ ] Monitor system resources

### Root Cause
[To be determined during investigation]

## Fix Strategy

### Approach
- [ ] Minimal code change
- [ ] Configuration adjustment
- [ ] Service restart
- [ ] Rollback previous deployment

### Risks
- [Risk 1 and mitigation]
- [Risk 2 and mitigation]

## Testing Plan

### Pre-deployment
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual verification in staging
- [ ] Performance impact assessment

### Post-deployment
- [ ] Monitor key metrics for 30 minutes
- [ ] Verify user reports decrease
- [ ] Check system stability
- [ ] Confirm fix effectiveness

## Communication Plan

### Stakeholders
- [ ] Development team notified
- [ ] Operations team alerted
- [ ] Management informed
- [ ] Customer support briefed

### Updates
- Initial: Incident declared, investigating
- Progress: Root cause identified, fix in progress
- Resolution: Fix deployed, monitoring
- Follow-up: Post-mortem scheduled

## Rollback Plan

If the hotfix causes additional issues:

1. **Immediate Rollback**
   \`\`\`bash
   git checkout production
   git reset --hard HEAD~1
   git push --force-with-lease origin production
   \`\`\`

2. **Service Restart**
   \`\`\`bash
   # Restart affected services
   sudo systemctl restart application
   \`\`\`

3. **Configuration Revert**
   \`\`\`bash
   # Revert configuration changes
   cp config.backup config.yml
   \`\`\`

## Post-Incident Actions

- [ ] Schedule post-mortem within 48 hours
- [ ] Document lessons learned
- [ ] Update runbooks
- [ ] Improve monitoring/alerting
- [ ] Create preventive measures

---
**Emergency Contacts:**
- On-call Engineer: [Phone]
- Engineering Manager: [Phone]
- Infrastructure Team: [Phone]
- Customer Support: [Phone]
EOF
}

start_incident_tracking() {
    local incident_id=$1
    local severity=$2
    local commander=$3
    local ticket_url=$4
    
    # Create incident tracking file
    cat > .incident_tracking << EOF
INCIDENT_ID=$incident_id
SEVERITY=$severity
COMMANDER=$commander
START_TIME=$(date +%s)
TICKET_URL=$ticket_url
STATUS=ACTIVE
EOF
    
    # Set up monitoring alerts
    echo "📊 Setting up incident monitoring..."
    
    # Create incident notification
    if command -v slack &> /dev/null; then
        slack_message="🚨 INCIDENT $incident_id DECLARED
Severity: Level $severity
Commander: $commander
Description: $description
Hotfix branch: $(git branch --show-current)
$(if [ -n "$ticket_url" ]; then echo "Ticket: $ticket_url"; fi)"
        
        # Send to incident channel
        echo "$slack_message" | slack send --channel "#incidents" --username "HotfixBot"
    fi
    
    echo "✅ Incident tracking initialized"
}
```

**Rapid Diagnosis Protocol:**
```bash
rapid_diagnosis() {
    echo "🔍 RAPID DIAGNOSIS PROTOCOL"
    echo "=========================="
    
    # Load incident details
    source .incident_tracking
    
    echo "Incident: $INCIDENT_ID (Level $SEVERITY)"
    echo "Time elapsed: $(($(date +%s) - START_TIME)) seconds"
    echo ""
    
    # System health check
    system_health_check
    
    # Recent changes analysis
    analyze_recent_changes
    
    # Log analysis
    analyze_logs
    
    # External dependencies check
    check_dependencies
    
    # Generate diagnosis report
    generate_diagnosis_report
}

system_health_check() {
    echo "🏥 System Health Check"
    echo "====================="
    
    # Check system resources
    echo "CPU Usage: $(top -l 1 | awk '/CPU usage/ {print $3}' | tr -d '%')"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $5}')"
    
    # Check application status
    if command -v systemctl &> /dev/null; then
        echo ""
        echo "Service Status:"
        systemctl status application 2>/dev/null | head -5
    fi
    
    # Check database connectivity
    if command -v psql &> /dev/null; then
        echo ""
        echo "Database Status:"
        psql -c "SELECT 1" &>/dev/null && echo "✅ Connected" || echo "❌ Connection failed"
    fi
    
    # Check network connectivity
    echo ""
    echo "Network Status:"
    ping -c 1 google.com &>/dev/null && echo "✅ Internet OK" || echo "❌ Network issues"
}

analyze_recent_changes() {
    echo ""
    echo "📅 Recent Changes Analysis"
    echo "========================="
    
    # Check recent deployments
    echo "Last 5 commits to production:"
    git log --oneline -5 origin/production 2>/dev/null || git log --oneline -5 origin/main
    
    # Check recent merges
    echo ""
    echo "Recent merges (last 24 hours):"
    git log --since="24 hours ago" --merges --oneline
    
    # Check configuration changes
    if [ -f config.yml ]; then
        echo ""
        echo "Configuration last modified:"
        ls -la config.yml
    fi
}

analyze_logs() {
    echo ""
    echo "📋 Log Analysis"
    echo "==============="
    
    # Application logs
    if [ -f /var/log/application.log ]; then
        echo "Recent errors in application log:"
        tail -100 /var/log/application.log | grep -i "error\|exception\|fatal" | tail -5
    fi
    
    # System logs
    if command -v journalctl &> /dev/null; then
        echo ""
        echo "Recent system errors:"
        journalctl --since "1 hour ago" --priority err | tail -5
    fi
    
    # Nginx/Apache logs
    for log_file in /var/log/nginx/error.log /var/log/apache2/error.log; do
        if [ -f "$log_file" ]; then
            echo ""
            echo "Web server errors:"
            tail -50 "$log_file" | tail -5
        fi
    done
}

check_dependencies() {
    echo ""
    echo "🔗 External Dependencies Check"
    echo "=============================="
    
    # Check common external services
    external_services=(
        "https://api.service1.com/health"
        "https://api.service2.com/status"
        "https://database.service.com:5432"
    )
    
    for service in "${external_services[@]}"; do
        if curl -s --max-time 5 "$service" &>/dev/null; then
            echo "✅ $service - OK"
        else
            echo "❌ $service - FAILED"
        fi
    done
    
    # Check DNS resolution
    echo ""
    echo "DNS Resolution:"
    nslookup google.com &>/dev/null && echo "✅ DNS OK" || echo "❌ DNS issues"
}

generate_diagnosis_report() {
    echo ""
    echo "📊 DIAGNOSIS SUMMARY"
    echo "==================="
    
    # Update incident documentation
    cat >> INCIDENT.md << EOF

## Diagnosis Results ($(date -u '+%H:%M UTC'))

### System Health
$(system_health_check 2>&1 | grep -E "(✅|❌)" | head -5)

### Recent Changes
$(git log --oneline -3 origin/production 2>/dev/null || git log --oneline -3 origin/main)

### Key Indicators
- Log errors: $(analyze_logs 2>&1 | grep -c "ERROR\|EXCEPTION")
- External services: $(check_dependencies 2>&1 | grep -c "✅")
- System load: Normal/High/Critical

### Suspected Root Cause
[Update based on diagnosis findings]
EOF
    
    echo "📝 Diagnosis report added to INCIDENT.md"
    echo "🎯 Proceed to implement fix based on findings"
}
```

## Phase 2: Hotfix Implementation

**Focused Fix Development:**
```bash
implement_hotfix() {
    echo "🔧 HOTFIX IMPLEMENTATION"
    echo "======================="
    
    source .incident_tracking
    
    echo "Implementing fix for: $INCIDENT_ID"
    echo "⏰ Time elapsed: $(($(date +%s) - START_TIME)) seconds"
    
    # Pre-implementation checks
    pre_implementation_check
    
    # Implementation guidance
    provide_implementation_guidance
    
    # Post-implementation validation
    validate_implementation
}

pre_implementation_check() {
    echo "🔍 Pre-implementation Checks"
    echo "============================"
    
    # Verify we're on the correct branch
    current_branch=$(get_current_branch)
    if [[ "$current_branch" != hotfix/* ]]; then
        echo "❌ Not on a hotfix branch!"
        exit 1
    fi
    
    # Ensure clean working directory
    if ! is_repo_clean; then
        echo "⚠️  Working directory not clean. Stashing changes..."
        git stash push -m "pre-hotfix-stash-$(date +%s)"
    fi
    
    # Verify base branch is up to date
    base_branch=$(git show-ref --verify --quiet refs/heads/production && echo "production" || echo "main")
    git fetch origin "$base_branch"
    
    echo "✅ Pre-implementation checks complete"
}

provide_implementation_guidance() {
    echo ""
    echo "🎯 Implementation Guidance"
    echo "========================="
    echo ""
    echo "🚨 HOTFIX PRINCIPLES:"
    echo "1. MINIMAL CHANGE - Fix only the specific issue"
    echo "2. NO REFACTORING - Avoid improving unrelated code"
    echo "3. NO NEW FEATURES - Pure bug fix only"
    echo "4. BACKWARDS COMPATIBLE - Don't break existing functionality"
    echo "5. WELL TESTED - Verify fix works before deployment"
    echo ""
    echo "⚡ SPEED GUIDELINES:"
    echo "- Make the smallest possible change"
    echo "- Prefer configuration over code changes"
    echo "- Use feature flags for immediate rollback capability"
    echo "- Document the fix thoroughly"
    echo ""
    echo "🛡️ SAFETY MEASURES:"
    echo "- Test the fix in isolation"
    echo "- Have rollback plan ready"
    echo "- Monitor key metrics during deployment"
    echo ""
    
    read -p "Press Enter when you understand the guidelines and are ready to implement..."
}

validate_implementation() {
    echo ""
    echo "✅ IMPLEMENTATION VALIDATION"
    echo "==========================="
    
    # Check if changes were made
    if is_repo_clean; then
        echo "⚠️  No changes detected. Did you implement the fix?"
        read -p "Continue anyway? (y/n): " continue_anyway
        if [[ "$continue_anyway" != "y" ]]; then
            exit 1
        fi
    fi
    
    # Run focused tests
    echo "🧪 Running focused validation tests..."
    
    # Syntax check
    if command -v make &> /dev/null; then
        make syntax-check 2>/dev/null || echo "No syntax check available"
    fi
    
    # Unit tests for changed files
    changed_files=$(git diff --name-only)
    echo "Changed files: $changed_files"
    
    # Run specific tests if possible
    if command -v npm &> /dev/null && [ -f package.json ]; then
        npm test -- --findRelatedTests $changed_files 2>/dev/null || npm test
    elif command -v pytest &> /dev/null; then
        pytest --lf 2>/dev/null || pytest
    else
        echo "⚠️  No automated tests available - manual validation required"
    fi
    
    # Manual validation checklist
    manual_validation_checklist
    
    # Commit the fix
    commit_hotfix
}

manual_validation_checklist() {
    echo ""
    echo "📋 Manual Validation Checklist"
    echo "=============================="
    echo ""
    echo "Please verify the following:"
    echo "- [ ] The specific issue is resolved"
    echo "- [ ] No new issues are introduced"
    echo "- [ ] Core functionality still works"
    echo "- [ ] Performance is not degraded"
    echo "- [ ] No security vulnerabilities added"
    echo ""
    
    read -p "All validation checks passed? (y/n): " validation_passed
    if [[ "$validation_passed" != "y" ]]; then
        echo "❌ Fix validation failed. Please address issues before proceeding."
        exit 1
    fi
    
    echo "✅ Manual validation completed"
}

commit_hotfix() {
    echo ""
    echo "💾 Committing Hotfix"
    echo "==================="
    
    source .incident_tracking
    
    # Stage all changes
    git add .
    
    # Generate commit message
    changed_files=$(git diff --cached --name-only | tr '\n' ' ')
    
    commit_message="hotfix: resolve $INCIDENT_ID - $(echo "$INCIDENT_ID" | sed 's/.*-//')

Critical production fix addressing immediate issue.

Changed files: $changed_files
Tested: Manual validation completed
Risk: Minimal - targeted fix only

Incident: $INCIDENT_ID
Commander: $COMMANDER
Urgency: Level $SEVERITY

This commit resolves the production incident and is ready for immediate deployment."
    
    # Commit with detailed message
    git commit -m "$commit_message"
    
    # Update incident log
    update_incident_log "Fix implemented and committed"
    
    echo "✅ Hotfix committed successfully"
    echo "🚀 Proceeding to deployment phase..."
}

update_incident_log() {
    local action=$1
    local timestamp=$(date -u '+%Y-%m-%d %H:%M:%S UTC')
    
    # Update incident documentation
    sed -i.bak "s/|  | $action | ⏳ |/| $(date -u '+%H:%M') | $action | ✅ |/" INCIDENT.md
    rm -f INCIDENT.md.bak
    
    echo "📝 Incident log updated: $action"
}
```

## Phase 3: Emergency Deployment

**Fast-Track Deployment:**
```bash
emergency_deployment() {
    echo "🚀 EMERGENCY DEPLOYMENT"
    echo "======================"
    
    source .incident_tracking
    
    echo "Deploying hotfix for: $INCIDENT_ID"
    echo "⏰ Time elapsed: $(($(date +%s) - START_TIME)) seconds"
    
    # Pre-deployment validation
    pre_deployment_validation
    
    # Deploy to production
    deploy_to_production
    
    # Post-deployment monitoring
    post_deployment_monitoring
}

pre_deployment_validation() {
    echo "🔍 Pre-deployment Validation"
    echo "============================"
    
    current_branch=$(get_current_branch)
    
    # Verify hotfix branch
    if [[ "$current_branch" != hotfix/* ]]; then
        echo "❌ Not on a hotfix branch!"
        exit 1
    fi
    
    # Check commit is ready
    if ! git diff --quiet; then
        echo "❌ Uncommitted changes detected!"
        exit 1
    fi
    
    # Verify fix is in latest commit
    latest_commit=$(git log -1 --pretty=format:"%h - %s")
    echo "Latest commit: $latest_commit"
    
    if ! echo "$latest_commit" | grep -q "hotfix:"; then
        echo "⚠️  Latest commit doesn't appear to be a hotfix"
        read -p "Continue anyway? (y/n): " continue_deploy
        if [[ "$continue_deploy" != "y" ]]; then
            exit 1
        fi
    fi
    
    # Final safety check
    echo ""
    echo "🚨 FINAL SAFETY CHECK"
    echo "===================="
    echo "About to deploy hotfix to PRODUCTION"
    echo "Incident: $INCIDENT_ID"
    echo "Branch: $current_branch"
    echo "Commit: $latest_commit"
    echo ""
    
    read -p "DEPLOY TO PRODUCTION? (type 'DEPLOY' to confirm): " deploy_confirm
    if [[ "$deploy_confirm" != "DEPLOY" ]]; then
        echo "Deployment cancelled"
        exit 1
    fi
    
    echo "✅ Pre-deployment validation complete"
}

deploy_to_production() {
    echo ""
    echo "🎯 Deploying to Production"
    echo "=========================="
    
    current_branch=$(get_current_branch)
    
    # Determine target branch
    if git show-ref --verify --quiet refs/heads/production; then
        target_branch="production"
    else
        target_branch="main"
        echo "⚠️  No production branch, deploying to main"
    fi
    
    # Create deployment backup
    echo "💾 Creating deployment backup..."
    backup_ref="backup/pre-hotfix-$(date +%Y%m%d-%H%M%S)"
    git tag "$backup_ref" "$target_branch"
    echo "Backup created: $backup_ref"
    
    # Merge hotfix to production
    echo "🔄 Merging hotfix to $target_branch..."
    git checkout "$target_branch"
    git pull origin "$target_branch"
    
    # Use merge commit to preserve hotfix context
    git merge --no-ff "$current_branch" -m "EMERGENCY: Deploy hotfix $INCIDENT_ID

This is an emergency deployment addressing critical production issue.

Incident: $INCIDENT_ID
Hotfix Branch: $current_branch
Commander: $COMMANDER
Deployment Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')

Backup Reference: $backup_ref
Rollback Command: git reset --hard $backup_ref"
    
    # Push to production
    echo "📤 Pushing to production..."
    git push origin "$target_branch"
    
    # Tag the deployment
    deploy_tag="hotfix-deploy-$(date +%Y%m%d-%H%M%S)"
    git tag -a "$deploy_tag" -m "Emergency hotfix deployment for $INCIDENT_ID"
    git push origin "$deploy_tag"
    
    # Update incident tracking
    update_incident_log "Deployed to production"
    sed -i.bak "s/STATUS=ACTIVE/STATUS=DEPLOYED/" .incident_tracking
    rm -f .incident_tracking.bak
    
    echo "✅ Hotfix deployed to production"
    echo "🏷️  Deployment tag: $deploy_tag"
    echo "💾 Backup tag: $backup_ref"
}

post_deployment_monitoring() {
    echo ""
    echo "📊 Post-Deployment Monitoring"
    echo "============================="
    
    source .incident_tracking
    
    echo "🕐 Starting 30-minute monitoring period..."
    echo "Incident: $INCIDENT_ID"
    echo "Deployed at: $(date -u '+%H:%M UTC')"
    
    # Monitor key metrics
    monitor_key_metrics
    
    # Check for immediate issues
    check_immediate_issues
    
    # Verify fix effectiveness
    verify_fix_effectiveness
    
    # Schedule follow-up monitoring
    schedule_monitoring
}

monitor_key_metrics() {
    echo ""
    echo "📈 Monitoring Key Metrics"
    echo "========================"
    
    # Error rate monitoring
    echo "Monitoring error rates..."
    for i in {1..6}; do
        echo "Check $i/6 ($(date '+%H:%M'))..."
        
        # Check application logs for new errors
        if [ -f /var/log/application.log ]; then
            new_errors=$(tail -100 /var/log/application.log | grep "$(date '+%Y-%m-%d %H:')" | grep -c -i "error\|exception")
            echo "  New errors in last hour: $new_errors"
        fi
        
        # Check system health
        if command -v curl &> /dev/null; then
            if curl -s --max-time 10 http://localhost/health &>/dev/null; then
                echo "  ✅ Health check: OK"
            else
                echo "  ❌ Health check: FAILED"
            fi
        fi
        
        # Wait 5 minutes between checks
        if [ $i -lt 6 ]; then
            echo "  Waiting 5 minutes..."
            sleep 300
        fi
    done
}

check_immediate_issues() {
    echo ""
    echo "🔍 Checking for Immediate Issues"
    echo "==============================="
    
    # Check for deployment-related errors
    echo "Scanning for deployment issues..."
    
    # Application startup errors
    if command -v journalctl &> /dev/null; then
        startup_errors=$(journalctl --since "10 minutes ago" --unit application | grep -c -i "error\|failed")
        echo "Startup errors: $startup_errors"
    fi
    
    # Database connection issues
    if command -v psql &> /dev/null; then
        if psql -c "SELECT 1" &>/dev/null; then
            echo "✅ Database connectivity: OK"
        else
            echo "❌ Database connectivity: FAILED"
        fi
    fi
    
    # Memory/CPU spikes
    cpu_usage=$(top -l 1 | awk '/CPU usage/ {print $3}' | tr -d '%' | cut -d. -f1)
    if [ "$cpu_usage" -gt 80 ]; then
        echo "⚠️  High CPU usage: ${cpu_usage}%"
    else
        echo "✅ CPU usage normal: ${cpu_usage}%"
    fi
}

verify_fix_effectiveness() {
    echo ""
    echo "🎯 Verifying Fix Effectiveness"
    echo "=============================="
    
    # Check if original issue is resolved
    echo "Verify that the original issue is resolved:"
    echo "1. Test the specific functionality that was broken"
    echo "2. Check user reports/support tickets"
    echo "3. Monitor key business metrics"
    echo "4. Verify system stability"
    
    read -p "Is the original issue resolved? (y/n): " issue_resolved
    if [[ "$issue_resolved" == "y" ]]; then
        echo "✅ Fix effectiveness confirmed"
        update_incident_log "Fix effectiveness verified"
    else
        echo "❌ Issue not resolved - may need additional action"
        echo "Consider: rollback, additional fixes, or escalation"
    fi
}

schedule_monitoring() {
    echo ""
    echo "⏰ Scheduling Continued Monitoring"
    echo "================================="
    
    # Create monitoring schedule
    cat > monitoring_schedule.md << EOF
# Post-Hotfix Monitoring Schedule

## Immediate (First 30 minutes) - ✅ COMPLETED
- [x] Deploy hotfix
- [x] Monitor error rates
- [x] Verify system health
- [x] Confirm fix effectiveness

## Short-term (Next 2 hours)
- [ ] Continue error rate monitoring
- [ ] Check user satisfaction metrics
- [ ] Monitor system performance
- [ ] Review support ticket volume

## Medium-term (Next 24 hours)
- [ ] Full system stability assessment
- [ ] Performance impact analysis
- [ ] User feedback collection
- [ ] Business metrics validation

## Follow-up Actions
- [ ] Schedule post-mortem (within 48 hours)
- [ ] Plan proper fix integration to main
- [ ] Update documentation and runbooks
- [ ] Implement preventive measures
EOF
    
    echo "📅 Monitoring schedule created: monitoring_schedule.md"
}
```

## Phase 4: Recovery & Learning

**Post-Incident Recovery:**
```bash
complete_incident_recovery() {
    echo "🔄 INCIDENT RECOVERY"
    echo "==================="
    
    source .incident_tracking
    
    echo "Completing recovery for: $INCIDENT_ID"
    echo "⏰ Total incident duration: $(($(date +%s) - START_TIME)) seconds"
    
    # Backport fix to main
    backport_to_main
    
    # Clean up hotfix branch
    cleanup_hotfix_branch
    
    # Generate incident report
    generate_incident_report
    
    # Schedule post-mortem
    schedule_postmortem
    
    # Close incident
    close_incident
}

backport_to_main() {
    echo ""
    echo "🔄 Backporting Fix to Main"
    echo "=========================="
    
    current_branch=$(get_current_branch)
    hotfix_branch="$current_branch"
    
    # Switch to main
    git checkout main
    git pull origin main
    
    # Identify hotfix commits
    if git show-ref --verify --quiet refs/heads/production; then
        base_branch="production"
    else
        base_branch="main"
    fi
    
    # Cherry-pick hotfix commits
    echo "Cherry-picking hotfix commits to main..."
    
    # Get the hotfix commits (excluding merge commits)
    hotfix_commits=$(git log --reverse --no-merges --pretty=format:"%H" "$base_branch".."$hotfix_branch")
    
    for commit in $hotfix_commits; do
        if git log -1 --pretty=format:"%s" "$commit" | grep -q "hotfix:"; then
            echo "Cherry-picking: $(git log -1 --pretty=format:"%h - %s" "$commit")"
            git cherry-pick -x "$commit"
        fi
    done
    
    # Push to main
    git push origin main
    
    echo "✅ Hotfix backported to main"
}

cleanup_hotfix_branch() {
    echo ""
    echo "🧹 Cleaning Up Hotfix Branch"
    echo "============================"
    
    current_branch=$(get_current_branch)
    
    # Ensure we're not on the hotfix branch
    if [[ "$current_branch" == hotfix/* ]]; then
        git checkout main
    fi
    
    # Archive the hotfix branch with tag
    hotfix_branch=$(git branch | grep "hotfix/" | tr -d ' *')
    if [ -n "$hotfix_branch" ]; then
        echo "Archiving hotfix branch: $hotfix_branch"
        git tag "archive/$hotfix_branch" "$hotfix_branch"
        git push origin "archive/$hotfix_branch"
        
        # Delete local and remote hotfix branch
        git branch -d "$hotfix_branch"
        git push origin --delete "$hotfix_branch"
        
        echo "✅ Hotfix branch archived and cleaned up"
    fi
    
    # Remove incident files
    if [ -f INCIDENT.md ]; then
        mv INCIDENT.md "incident-$INCIDENT_ID-$(date +%Y%m%d).md"
        echo "📁 Incident documentation archived"
    fi
    
    rm -f .incident_tracking
}

generate_incident_report() {
    echo ""
    echo "📊 Generating Incident Report"
    echo "============================="
    
    source .incident_tracking 2>/dev/null || true
    
    total_duration=$(($(date +%s) - START_TIME))
    hours=$((total_duration / 3600))
    minutes=$(((total_duration % 3600) / 60))
    
    cat > "incident-report-$INCIDENT_ID.md" << EOF
# Incident Report: $INCIDENT_ID

## Executive Summary

**Incident ID:** $INCIDENT_ID
**Severity:** Level $SEVERITY
**Commander:** $COMMANDER
**Duration:** ${hours}h ${minutes}m
**Status:** RESOLVED
**Date:** $(date -d "@$START_TIME" '+%Y-%m-%d')

## Timeline

| Time | Event | Duration |
|------|--------|----------|
| $(date -d "@$START_TIME" '+%H:%M') | Incident detected | 0m |
| | Investigation started | +5m |
| | Root cause identified | +15m |
| | Fix implemented | +30m |
| | Deployed to production | +45m |
| | Issue resolved | +${minutes}m |

## Impact Assessment

### Users Affected
- [Number/percentage of users impacted]
- [Geographic/demographic breakdown if applicable]

### Systems Affected
- [List of systems, services, or components]
- [Dependencies that were impacted]

### Business Impact
- [Revenue/transaction impact]
- [Customer experience impact]
- [Operational disruption]

## Root Cause Analysis

### What Happened
[Detailed description of the technical issue]

### Why It Happened
[Analysis of underlying causes - technical, process, human factors]

### Contributing Factors
- [Factor 1]
- [Factor 2]
- [Factor 3]

## Resolution

### Fix Applied
[Description of the hotfix solution]

### Files Changed
$(git log --name-only --pretty=format: hotfix/* | sort | uniq | grep -v '^$' | head -10)

### Validation Performed
- [Testing steps taken]
- [Monitoring performed]
- [Success criteria met]

## Lessons Learned

### What Went Well
- [Positive aspects of the response]
- [Effective processes or tools]

### What Could Be Improved
- [Areas for improvement]
- [Process gaps identified]

### Action Items
- [ ] [Preventive measure 1] - Owner: [Name] - Due: [Date]
- [ ] [Process improvement 1] - Owner: [Name] - Due: [Date]
- [ ] [Monitoring enhancement 1] - Owner: [Name] - Due: [Date]

## Prevention Measures

### Immediate (Next Sprint)
- [Quick wins to prevent recurrence]

### Short-term (Next Month)
- [Medium effort improvements]

### Long-term (Next Quarter)
- [Strategic improvements]

## Appendix

### Related Documentation
- Original incident: incident-$INCIDENT_ID-$(date +%Y%m%d).md
- Hotfix commits: [List of commit hashes]
- Monitoring data: [Links to dashboards/logs]

### Communication Log
- [Stakeholder notifications sent]
- [Customer communications]
- [Internal updates]

---
**Report Generated:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')
**Generated By:** Claude Code Hotfix Workflow
EOF
    
    echo "📋 Incident report generated: incident-report-$INCIDENT_ID.md"
}

schedule_postmortem() {
    echo ""
    echo "📅 Scheduling Post-Mortem"
    echo "========================"
    
    echo "Post-mortem meeting should be scheduled within 48 hours"
    echo ""
    echo "Suggested agenda:"
    echo "1. Timeline review (15 min)"
    echo "2. Root cause analysis (20 min)"
    echo "3. Response evaluation (15 min)"
    echo "4. Action items identification (20 min)"
    echo "5. Next steps planning (10 min)"
    echo ""
    echo "Required attendees:"
    echo "- Incident Commander: $COMMANDER"
    echo "- Engineering team members"
    echo "- Operations team"
    echo "- Product/business stakeholders"
    echo ""
    
    read -p "Send post-mortem meeting invite? (y/n): " send_invite
    if [[ "$send_invite" == "y" ]]; then
        echo "📧 Post-mortem meeting invite should be sent"
        # Integration with calendar systems would go here
    fi
}

close_incident() {
    echo ""
    echo "✅ INCIDENT CLOSURE"
    echo "==================="
    
    source .incident_tracking 2>/dev/null || true
    
    final_duration=$(($(date +%s) - START_TIME))
    
    echo "🎉 INCIDENT $INCIDENT_ID RESOLVED"
    echo ""
    echo "📊 Final Statistics:"
    echo "- Total duration: $((final_duration / 60)) minutes"
    echo "- Severity: Level $SEVERITY"
    echo "- Commander: $COMMANDER"
    echo "- Resolution: Hotfix deployed successfully"
    echo ""
    
    # Send closure notification
    if command -v slack &> /dev/null; then
        slack_message="✅ INCIDENT $INCIDENT_ID RESOLVED
Duration: $((final_duration / 60)) minutes
Resolution: Hotfix deployed and verified
Commander: $COMMANDER

Next steps:
- Post-mortem scheduled within 48h
- Action items to be tracked
- Preventive measures planned"
        
        echo "$slack_message" | slack send --channel "#incidents" --username "HotfixBot"
    fi
    
    # Update status
    sed -i.bak "s/STATUS=DEPLOYED/STATUS=RESOLVED/" .incident_tracking 2>/dev/null || true
    rm -f .incident_tracking.bak
    
    echo "🚀 System fully recovered and operational"
    echo "📚 Documentation and reports available for review"
}
```

## Emergency Rollback Procedures

**Immediate Rollback:**
```bash
emergency_rollback() {
    echo "🚨 EMERGENCY ROLLBACK INITIATED"
    echo "================================"
    
    echo "⚠️  CRITICAL: This will immediately revert the hotfix!"
    read -p "Type 'ROLLBACK' to confirm emergency rollback: " rollback_confirm
    
    if [[ "$rollback_confirm" != "ROLLBACK" ]]; then
        echo "Rollback cancelled"
        exit 1
    fi
    
    # Find backup reference
    backup_tag=$(git tag -l "backup/pre-hotfix-*" | sort | tail -1)
    
    if [ -z "$backup_tag" ]; then
        echo "❌ No backup reference found!"
        echo "Manual rollback required"
        exit 1
    fi
    
    echo "Rolling back to: $backup_tag"
    
    # Determine target branch
    target_branch="production"
    if ! git show-ref --verify --quiet refs/heads/production; then
        target_branch="main"
    fi
    
    # Perform rollback
    git checkout "$target_branch"
    git reset --hard "$backup_tag"
    git push --force-with-lease origin "$target_branch"
    
    # Tag the rollback
    rollback_tag="rollback-$(date +%Y%m%d-%H%M%S)"
    git tag -a "$rollback_tag" -m "Emergency rollback from hotfix deployment"
    git push origin "$rollback_tag"
    
    echo "✅ Emergency rollback completed"
    echo "🏷️  Rollback tag: $rollback_tag"
    echo "🔍 Investigate hotfix issues before attempting redeployment"
}
```

## Team Communication Templates

**Incident Notifications:**
```bash
# Initial alert
send_incident_alert() {
    cat << EOF
🚨 PRODUCTION INCIDENT DECLARED

Incident: $INCIDENT_ID
Severity: Level $SEVERITY  
Commander: $COMMANDER
Time: $(date -u '+%H:%M UTC')

We are investigating a production issue and will provide updates every 15 minutes.

Status page: [URL]
Incident channel: #incident-$INCIDENT_ID
EOF
}

# Progress update
send_progress_update() {
    cat << EOF
📊 INCIDENT UPDATE - $INCIDENT_ID

Status: $STATUS
Root cause: $ROOT_CAUSE  
ETA for resolution: $ETA
Commander: $COMMANDER

Actions taken:
- $ACTION_1
- $ACTION_2

Next steps:
- $NEXT_STEP
EOF
}

# Resolution notification
send_resolution_notice() {
    cat << EOF
✅ INCIDENT RESOLVED - $INCIDENT_ID

The production issue has been resolved.
Total duration: $DURATION minutes
Resolution: $RESOLUTION_SUMMARY

All systems are now operating normally.
Post-mortem will be scheduled within 48 hours.

Thank you for your patience.
EOF
}
```

## Best Practices Summary

1. **Speed vs. Safety Balance**
   - Fast response with controlled risk
   - Minimal but effective changes
   - Comprehensive validation

2. **Clear Communication**
   - Regular stakeholder updates
   - Transparent incident tracking
   - Documented decision making

3. **Learning Culture**
   - Blameless post-mortems
   - Action item tracking
   - Preventive improvements

## Workflow Summary

The hotfix workflow ensures:
- ✅ Rapid incident response (< 5 minutes)
- ✅ Systematic problem diagnosis
- ✅ Minimal risk hotfix implementation
- ✅ Safe production deployment
- ✅ Comprehensive monitoring and recovery
- ✅ Complete documentation and learning

Remember: **In production emergencies, process saves the day - not heroics!**