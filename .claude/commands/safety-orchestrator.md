---
allowed-tools: all
description: Comprehensive safety orchestrator with multi-factor verification for backup cleanup operations
---

# 🛡️ Safety Orchestrator - Multi-Factor Verification System

**MISSION-CRITICAL SAFETY SYSTEM FOR BACKUP CLEANUP OPERATIONS**

When you run `/safety-orchestrator`, you activate a comprehensive safety system that validates backup cleanup decisions through multi-factor verification, risk assessment, and rollback coordination.

## 🚨 CORE SAFETY PRINCIPLES

**MANDATORY VERIFICATION FACTORS:**
- ✅ Git repository clean state validation
- ✅ No pending merge operations check
- ✅ Backup age and staleness verification
- ✅ User confirmation for critical backups
- ✅ Emergency preservation for suspicious patterns

**SAFETY POLICY ENFORCEMENT:**
- 🔒 Never delete backups during active git operations
- ⏱️ Require minimum age before cleanup eligibility
- 🔗 Preserve backups referenced in recent commits
- 🚨 Emergency stop mechanisms for cleanup operations

## 🎯 MULTI-FACTOR VERIFICATION ENGINE

### Factor 1: Git State Validation
```bash
# Verify clean repository state
git status --porcelain
git diff --name-only HEAD
git ls-files --others --exclude-standard

# Check for active operations
test -f .git/MERGE_HEAD
test -f .git/REBASE_HEAD
test -f .git/CHERRY_PICK_HEAD
```

### Factor 2: Backup Age & Staleness Assessment
```yaml
backup_age_policies:
  minimum_age_days: 7
  critical_age_days: 30
  stale_threshold_days: 90
  
  age_categories:
    fresh: 0-7 days      # NEVER delete
    stable: 7-30 days    # Require confirmation
    aging: 30-90 days    # Safe with verification
    stale: 90+ days      # Auto-cleanup eligible
```

### Factor 3: Reference Chain Analysis
```bash
# Check for backup references in recent commits
git log --since="30 days ago" --grep="backup"
git log --since="30 days ago" --all --full-history -- "*.backup.*"

# Verify no active branches reference backups
git branch -a --contains HEAD
git reflog --since="7 days ago"
```

### Factor 4: User Confirmation Matrix
```yaml
confirmation_levels:
  auto_approve:     # High confidence, no user input
    conditions:
      - confidence_score: ">= 0.95"
      - backup_age: ">= 90 days"
      - no_recent_references: true
      - git_state: "clean"
  
  request_confirmation:  # Medium confidence, user prompt
    conditions:
      - confidence_score: "0.70 - 0.94"
      - backup_age: ">= 7 days"
      - limited_references: true
  
  require_explicit_approval:  # Low confidence, detailed review
    conditions:
      - confidence_score: "< 0.70"
      - backup_age: "< 7 days"
      - has_references: true
```

## 📊 RISK ASSESSMENT ALGORITHMS

### Backup Importance Scoring
```python
class BackupImportanceCalculator:
    def calculate_importance_score(self, backup_path: Path) -> float:
        score = 0.0
        
        # File type importance
        if self.is_source_code(backup_path):
            score += 0.3
        if self.is_configuration(backup_path):
            score += 0.4
        if self.is_data_file(backup_path):
            score += 0.5
        
        # Recency factor
        age_days = self.get_backup_age_days(backup_path)
        recency_factor = max(0, (90 - age_days) / 90)
        score += recency_factor * 0.3
        
        # Reference density
        ref_count = self.count_references(backup_path)
        reference_factor = min(1.0, ref_count / 10)
        score += reference_factor * 0.4
        
        # Uniqueness factor
        if self.is_unique_backup(backup_path):
            score += 0.3
        
        return min(1.0, score)
```

### Safety Level Classification
```yaml
safety_levels:
  safe:           # 85-100% confidence
    auto_execute: true
    backup_first: false
    user_notification: summary
    
  cautious:       # 60-84% confidence
    auto_execute: false
    backup_first: true
    user_notification: detailed
    rollback_plan: required
    
  risky:          # 0-59% confidence
    auto_execute: false
    backup_first: true
    user_notification: comprehensive
    manual_review: required
    safety_officer_approval: true
```

### Risk-Based Approval Workflows
```python
class RiskBasedApprovalEngine:
    def determine_approval_workflow(self, risk_assessment: RiskAssessment) -> WorkflowPlan:
        if risk_assessment.safety_level == SafetyLevel.SAFE:
            return WorkflowPlan(
                steps=[AutoExecuteStep()],
                notifications=[SummaryNotification()],
                rollback_enabled=True
            )
        
        elif risk_assessment.safety_level == SafetyLevel.CAUTIOUS:
            return WorkflowPlan(
                steps=[
                    BackupCreationStep(),
                    UserConfirmationStep(details=risk_assessment.concerns),
                    ConditionalExecuteStep()
                ],
                notifications=[DetailedNotification()],
                rollback_enabled=True,
                rollback_auto_trigger=True
            )
        
        else:  # RISKY
            return WorkflowPlan(
                steps=[
                    BackupCreationStep(),
                    ManualReviewStep(),
                    SafetyOfficerApprovalStep(),
                    SupervisedExecuteStep()
                ],
                notifications=[ComprehensiveNotification()],
                rollback_enabled=True,
                rollback_immediate=True
            )
```

## 🔄 ROLLBACK COORDINATOR SYSTEM

### Backup Recovery Capabilities
```bash
#!/bin/bash
# backup-recovery-engine.sh

create_recovery_point() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local recovery_dir=".claude/recovery/${timestamp}"
    
    mkdir -p "$recovery_dir"
    
    # Snapshot current state
    find . -name "*.backup.*" -type f > "$recovery_dir/backup_inventory.txt"
    git status --porcelain > "$recovery_dir/git_status.txt"
    git rev-parse HEAD > "$recovery_dir/git_head.txt"
    
    # Create metadata
    cat > "$recovery_dir/recovery_metadata.json" <<EOF
{
    "timestamp": "$timestamp",
    "operation": "backup_cleanup",
    "git_state": "$(git rev-parse HEAD)",
    "backup_count": $(find . -name "*.backup.*" -type f | wc -l),
    "safety_level": "$SAFETY_LEVEL",
    "confidence_score": "$CONFIDENCE_SCORE"
}
EOF
    
    echo "$recovery_dir"
}

restore_from_recovery_point() {
    local recovery_dir="$1"
    
    if [[ ! -d "$recovery_dir" ]]; then
        echo "❌ Recovery point not found: $recovery_dir"
        return 1
    fi
    
    echo "🔄 Restoring from recovery point: $(basename "$recovery_dir")"
    
    # Restore git state if needed
    local original_head=$(cat "$recovery_dir/git_head.txt")
    local current_head=$(git rev-parse HEAD)
    
    if [[ "$original_head" != "$current_head" ]]; then
        echo "⚠️  Git HEAD has changed since recovery point"
        echo "   Original: $original_head"
        echo "   Current:  $current_head"
        read -p "Reset to original HEAD? [y/N]: " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git reset --hard "$original_head"
        fi
    fi
    
    # Restore deleted backups if possible
    if [[ -f "$recovery_dir/deleted_backups.tar.gz" ]]; then
        echo "🔄 Restoring deleted backup files..."
        tar -xzf "$recovery_dir/deleted_backups.tar.gz" -C .
    fi
    
    echo "✅ Recovery completed"
}
```

### Emergency Stop Mechanisms
```python
class EmergencyStopCoordinator:
    def __init__(self):
        self.stop_file = Path(".claude/emergency_stop")
        self.monitoring_active = False
    
    def start_monitoring(self):
        """Start emergency stop monitoring"""
        self.monitoring_active = True
        
        # Create stop file handler
        signal.signal(signal.SIGTERM, self._emergency_stop_handler)
        signal.signal(signal.SIGINT, self._emergency_stop_handler)
        
        # Monitor for manual stop file
        threading.Thread(target=self._monitor_stop_file, daemon=True).start()
    
    def check_emergency_stop(self) -> bool:
        """Check if emergency stop has been triggered"""
        return self.stop_file.exists() or not self.monitoring_active
    
    def trigger_emergency_stop(self, reason: str):
        """Trigger emergency stop with reason"""
        stop_data = {
            "timestamp": datetime.now().isoformat(),
            "reason": reason,
            "pid": os.getpid(),
            "operation": "backup_cleanup"
        }
        
        with open(self.stop_file, 'w') as f:
            json.dump(stop_data, f, indent=2)
        
        self.monitoring_active = False
        
        print(f"🚨 EMERGENCY STOP TRIGGERED: {reason}")
        print(f"🛑 Stop file created: {self.stop_file}")
```

### Comprehensive Audit Trail
```python
class SafetyAuditLogger:
    def __init__(self, audit_dir: Path = Path(".claude/safety_audit")):
        self.audit_dir = audit_dir
        self.audit_dir.mkdir(exist_ok=True)
        self.session_id = self._generate_session_id()
        
    def log_verification_result(self, factor: str, result: VerificationResult):
        """Log multi-factor verification results"""
        entry = {
            "session_id": self.session_id,
            "timestamp": datetime.now().isoformat(),
            "verification_factor": factor,
            "result": result.passed,
            "confidence": result.confidence,
            "details": result.details,
            "warnings": result.warnings
        }
        
        self._write_audit_entry("verification", entry)
    
    def log_risk_assessment(self, backup_path: Path, assessment: RiskAssessment):
        """Log risk assessment for specific backup"""
        entry = {
            "session_id": self.session_id,
            "timestamp": datetime.now().isoformat(),
            "backup_path": str(backup_path),
            "importance_score": assessment.importance_score,
            "safety_level": assessment.safety_level.name,
            "confidence_score": assessment.confidence_score,
            "risk_factors": assessment.risk_factors,
            "recommended_action": assessment.recommended_action
        }
        
        self._write_audit_entry("risk_assessment", entry)
    
    def log_cleanup_decision(self, decision: CleanupDecision):
        """Log final cleanup decision and execution"""
        entry = {
            "session_id": self.session_id,
            "timestamp": datetime.now().isoformat(),
            "backup_path": str(decision.backup_path),
            "action_taken": decision.action,
            "approval_method": decision.approval_method,
            "user_input": decision.user_input,
            "execution_result": decision.execution_result,
            "rollback_point": decision.rollback_point
        }
        
        self._write_audit_entry("cleanup_decision", entry)
```

## 🚀 EXECUTION WORKFLOW

### Phase 1: Multi-Factor Verification
```python
async def execute_safety_orchestrator(target_dir: Path) -> SafetyReport:
    """Execute comprehensive safety orchestrator workflow"""
    
    print("🛡️ Starting Safety Orchestrator - Multi-Factor Verification")
    
    # Initialize components
    verifier = MultiFactorVerifier()
    risk_assessor = RiskAssessmentEngine()
    rollback_coordinator = RollbackCoordinator()
    audit_logger = SafetyAuditLogger()
    
    # Create recovery point
    recovery_point = rollback_coordinator.create_recovery_point()
    print(f"📸 Recovery point created: {recovery_point}")
    
    # Phase 1: Multi-factor verification
    verification_results = await verifier.verify_all_factors(target_dir)
    
    for factor, result in verification_results.items():
        audit_logger.log_verification_result(factor, result)
        
        if not result.passed and result.is_critical:
            print(f"❌ Critical verification failed: {factor}")
            print(f"   Reason: {result.failure_reason}")
            return SafetyReport(
                status="FAILED_VERIFICATION",
                failed_factor=factor,
                recovery_point=recovery_point
            )
    
    print("✅ Multi-factor verification completed")
    return await execute_risk_assessment_phase(
        target_dir, verification_results, risk_assessor, 
        rollback_coordinator, audit_logger, recovery_point
    )
```

### Phase 2: Risk Assessment & Decision Making
```python
async def execute_risk_assessment_phase(
    target_dir: Path,
    verification_results: Dict[str, VerificationResult],
    risk_assessor: RiskAssessmentEngine,
    rollback_coordinator: RollbackCoordinator,
    audit_logger: SafetyAuditLogger,
    recovery_point: Path
) -> SafetyReport:
    """Execute risk assessment and decision-making phase"""
    
    print("📊 Phase 2: Risk Assessment & Decision Making")
    
    # Discover all backup files
    backup_files = discover_backup_files(target_dir)
    print(f"🔍 Discovered {len(backup_files)} backup files")
    
    cleanup_decisions = []
    
    for backup_file in backup_files:
        # Assess risk for each backup
        risk_assessment = await risk_assessor.assess_backup_risk(
            backup_file, verification_results
        )
        
        audit_logger.log_risk_assessment(backup_file, risk_assessment)
        
        # Determine approval workflow
        workflow = determine_approval_workflow(risk_assessment)
        
        # Execute workflow and get decision
        decision = await execute_approval_workflow(
            backup_file, risk_assessment, workflow, rollback_coordinator
        )
        
        audit_logger.log_cleanup_decision(decision)
        cleanup_decisions.append(decision)
        
        # Check for emergency stop
        if rollback_coordinator.check_emergency_stop():
            print("🚨 Emergency stop detected - halting operations")
            break
    
    # Generate comprehensive report
    return generate_safety_report(
        cleanup_decisions, verification_results, recovery_point
    )
```

### Phase 3: Supervised Execution & Monitoring
```python
async def execute_approval_workflow(
    backup_file: Path,
    risk_assessment: RiskAssessment,
    workflow: WorkflowPlan,
    rollback_coordinator: RollbackCoordinator
) -> CleanupDecision:
    """Execute the determined approval workflow for a backup file"""
    
    decision = CleanupDecision(
        backup_path=backup_file,
        risk_assessment=risk_assessment
    )
    
    try:
        for step in workflow.steps:
            if isinstance(step, AutoExecuteStep):
                print(f"🤖 Auto-executing cleanup for {backup_file.name}")
                result = await step.execute(backup_file)
                decision.action = "auto_deleted"
                decision.execution_result = result
                
            elif isinstance(step, UserConfirmationStep):
                user_choice = await prompt_user_confirmation(
                    backup_file, risk_assessment
                )
                
                if user_choice == "approve":
                    result = await execute_cleanup(backup_file)
                    decision.action = "user_approved_deleted"
                    decision.execution_result = result
                else:
                    decision.action = "user_rejected_preserved"
                    decision.user_input = user_choice
                    break
                    
            elif isinstance(step, ManualReviewStep):
                print(f"👥 Manual review required for {backup_file.name}")
                review_result = await request_manual_review(backup_file, risk_assessment)
                decision.action = "manual_review_required"
                decision.execution_result = review_result
                break
                
    except Exception as e:
        print(f"❌ Error during workflow execution: {e}")
        decision.action = "error_preserved"
        decision.execution_result = str(e)
        
        # Trigger rollback if needed
        if rollback_coordinator.should_rollback(e):
            await rollback_coordinator.rollback_last_operation()
    
    return decision
```

## 📋 SAFETY CONFIGURATION

### Multi-Factor Verification Settings
```yaml
# .claude/safety-config.yaml
version: 2.0
safety_mode: maximum

multi_factor_verification:
  git_state_check:
    enabled: true
    require_clean_working_tree: true
    check_pending_operations: true
    verify_branch_state: true
    
  backup_age_verification:
    enabled: true
    minimum_age_hours: 168  # 7 days
    stale_threshold_days: 90
    critical_threshold_days: 30
    
  reference_chain_analysis:
    enabled: true
    check_commit_references: true
    check_branch_references: true
    check_reflog_references: true
    reference_lookback_days: 30
    
  user_confirmation:
    enabled: true
    auto_approve_threshold: 0.95
    prompt_threshold: 0.70
    require_explicit_approval_threshold: 0.60

risk_assessment:
  importance_factors:
    file_type_weight: 0.3
    recency_weight: 0.3
    reference_density_weight: 0.4
    uniqueness_weight: 0.3
  
  safety_thresholds:
    safe_level: 0.85
    cautious_level: 0.60
    risky_level: 0.00

rollback_coordination:
  auto_create_recovery_points: true
  recovery_point_retention_days: 30
  auto_rollback_on_failure: true
  emergency_stop_monitoring: true

audit_trail:
  enabled: true
  log_all_decisions: true
  retain_audit_days: 365
  export_format: ["json", "csv"]
```

## 🎯 SUCCESS CRITERIA

**Multi-Factor Verification:**
- ✅ 100% detection of unsafe git states
- ✅ Zero cleanup during active operations
- ✅ Accurate backup age classification
- ✅ Comprehensive reference chain analysis

**Risk Assessment:**
- ✅ >95% accuracy in importance scoring
- ✅ Appropriate safety level classification
- ✅ Risk-based workflow assignment
- ✅ Confidence correlation with outcomes

**Rollback Coordination:**
- ✅ 100% recovery point creation success
- ✅ Complete rollback capability
- ✅ Emergency stop <2 second response
- ✅ Comprehensive audit trail coverage

**User Experience:**
- ✅ Clear safety status communication
- ✅ Appropriate confirmation levels
- ✅ Transparent decision reasoning
- ✅ Efficient workflow execution

## 🚨 EMERGENCY PROCEDURES

### Manual Emergency Stop
```bash
# Create emergency stop file
touch .claude/emergency_stop

# Or send signal to process
kill -TERM <safety_orchestrator_pid>
```

### Recovery from Failed Operation
```bash
# List available recovery points
safety-orchestrator --list-recovery-points

# Restore from specific recovery point
safety-orchestrator --restore 20250114_143022

# Complete system restoration
safety-orchestrator --emergency-restore
```

### Safety Officer Override
```bash
# Override safety restrictions (requires elevated privileges)
safety-orchestrator --safety-override --reason "Emergency maintenance"

# Force approval for risky operations
safety-orchestrator --force-approve --backup-file critical.backup.123
```

## 🎬 EXECUTION COMMAND

Executing comprehensive safety orchestrator for backup cleanup operations:

**Multi-factor verification → Risk assessment → Supervised execution → Audit trail**

Success metrics: Zero data loss, complete traceability, maximum safety assurance

$ARGUMENTS