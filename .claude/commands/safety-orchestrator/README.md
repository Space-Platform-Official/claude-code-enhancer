# Safety Orchestrator - Comprehensive Backup Cleanup Safety System

A comprehensive safety system that validates backup cleanup decisions through multi-factor verification, risk assessment, policy enforcement, and rollback coordination.

## 🛡️ Core Components

### 1. Multi-Factor Verification Engine (`multi_factor_verifier.py`)
- **Git State Validation**: Ensures repository is in safe state
- **Backup Age Verification**: Checks minimum age requirements  
- **Reference Chain Analysis**: Detects references in git history
- **Emergency Pattern Detection**: Identifies suspicious patterns

### 2. Risk Assessment Engine (`risk_assessment_engine.py`)
- **Backup Importance Scoring**: Calculates importance based on multiple factors
- **Safety Level Classification**: Categorizes as safe/cautious/risky
- **Confidence Scoring**: Provides confidence in assessment
- **Recommendation Generation**: Suggests appropriate actions

### 3. Safety Policy Engine (`safety_policy_engine.py`) 
- **Policy Definition & Enforcement**: Configurable safety policies
- **Violation Detection**: Identifies policy violations
- **Automatic Remediation**: Suggests fixes for violations
- **Emergency Stop Monitoring**: Background monitoring for stop conditions

### 4. Rollback Coordinator (`rollback_coordinator.py`)
- **Recovery Point Creation**: Creates snapshots before operations
- **Atomic Operations**: All-or-nothing execution
- **Automatic Rollback**: Rollback on failure
- **Emergency Restore**: Quick restoration capabilities

### 5. Main Orchestrator (`safety_orchestrator_main.py`)
- **Component Integration**: Coordinates all safety components
- **Workflow Management**: Manages the complete safety workflow
- **User Interaction**: Handles user confirmations and decisions
- **Comprehensive Reporting**: Generates detailed safety reports

## 🚀 Quick Start

### Basic Usage
```bash
# Analyze backup cleanup safety (dry run)
python safety-orchestrator-main.py /path/to/project

# Execute actual cleanup with safety checks
python safety-orchestrator-main.py /path/to/project --execute

# Non-interactive mode with report
python safety-orchestrator-main.py /path/to/project --non-interactive --report-file safety-report.json
```

### Python API Usage
```python
from safety_orchestrator import SafetyOrchestrator
import asyncio

async def safe_cleanup():
    orchestrator = SafetyOrchestrator()
    
    # Execute comprehensive safety orchestration
    report = await orchestrator.orchestrate_safe_cleanup(
        target_dir=Path("/path/to/project"),
        dry_run=False,
        interactive=True
    )
    
    print(f"Result: {report.result}")
    print(f"Files processed: {len(report.cleanup_decisions)}")

asyncio.run(safe_cleanup())
```

## 🔧 Configuration

### Safety Configuration File (`.claude/safety-config.yaml`)
```yaml
version: 2.0
safety_mode: maximum

multi_factor_verification:
  git_state_check:
    enabled: true
    require_clean_working_tree: true
    check_pending_operations: true
    
  backup_age_verification:
    enabled: true
    minimum_age_hours: 168  # 7 days
    stale_threshold_days: 90
    
  reference_chain_analysis:
    enabled: true
    reference_lookback_days: 30
    
safety_policies:
  git_operations:
    block_during_merge: true
    block_during_rebase: true
    
  backup_age:
    minimum_age_hours: 168
    critical_age_hours: 24
    
risk_assessment:
  importance_factors:
    file_type_weight: 0.25
    recency_weight: 0.25
    reference_density_weight: 0.30
    uniqueness_weight: 0.20
    
  safety_thresholds:
    safe_level: 0.85
    cautious_level: 0.60
```

## 🛡️ Safety Workflow

### Phase 1: Multi-Factor Verification
1. **Git State Check**: Verify repository is clean and no active operations
2. **Backup Age Analysis**: Check backup file ages against policies
3. **Reference Chain Analysis**: Search for references in git history
4. **Emergency Pattern Detection**: Look for failure indicators

### Phase 2: Recovery Point Creation
1. **Pre-Operation Snapshot**: Create comprehensive recovery point
2. **Git State Capture**: Save current repository state
3. **File Inventory**: Catalog all backup files
4. **Integrity Verification**: Ensure recovery point is valid

### Phase 3: Risk Assessment
1. **File Type Classification**: Categorize backup file types
2. **Importance Scoring**: Calculate importance based on multiple factors
3. **Safety Level Determination**: Classify as safe/cautious/risky
4. **Recommendation Generation**: Provide specific recommendations

### Phase 4: Policy Enforcement
1. **Policy Evaluation**: Check all active safety policies
2. **Violation Detection**: Identify any policy violations
3. **Blocking Assessment**: Determine if violations block operations
4. **Remediation Suggestions**: Provide fix recommendations

### Phase 5: Decision Making & Execution
1. **Automated Decisions**: Handle safe operations automatically
2. **User Confirmations**: Prompt for cautious operations
3. **Manual Review**: Flag risky operations for review
4. **Atomic Execution**: Execute with rollback capability

## 📊 Safety Levels

### 🟢 Safe (85-100% confidence)
- **Auto-execute**: Operations proceed automatically
- **Backup creation**: Optional
- **User notification**: Summary only

### 🟡 Cautious (60-84% confidence)  
- **User confirmation**: Required before execution
- **Backup creation**: Mandatory
- **User notification**: Detailed reasoning
- **Rollback plan**: Prepared and tested

### 🔴 Risky (0-59% confidence)
- **Manual review**: Required before any action
- **Backup creation**: Mandatory with verification
- **User notification**: Comprehensive analysis
- **Safety officer approval**: May be required

## 🚨 Emergency Procedures

### Emergency Stop
```bash
# Create emergency stop file
touch .claude/emergency_stop

# Or send signal to process
kill -TERM <safety_orchestrator_pid>
```

### Emergency Recovery
```bash
# List available recovery points
python safety-orchestrator-main.py --list-recovery-points

# Emergency restore to latest recovery point
python safety-orchestrator-main.py --emergency-restore

# Restore to specific recovery point
python safety-orchestrator-main.py --restore rp_20250114_143022_1234
```

## 📋 Component Details

### Multi-Factor Verification Factors
- **Git State**: Repository cleanliness, active operations
- **Backup Age**: File modification times, staleness thresholds
- **Reference Chain**: Git history, branch names, commit messages
- **Emergency Patterns**: Failure indicators, critical backups

### Risk Assessment Factors
- **File Type Importance**: Source code > config > data > docs > temp
- **Recency Risk**: Recent files are riskier to delete
- **Reference Density**: More references = higher risk
- **Uniqueness Risk**: Unique files are riskier than duplicates
- **Git Context**: Tracked files have higher risk
- **Content Analysis**: Important patterns increase risk

### Safety Policies
- **Git Operations**: No cleanup during merge/rebase/cherry-pick
- **Backup Age**: Minimum age requirements before cleanup
- **Reference Preservation**: Preserve referenced backups
- **Emergency Patterns**: Block on failure indicators
- **User Confirmation**: Required for risky operations
- **Rollback Safety**: Ensure rollback capability exists

### Recovery Mechanisms
- **Full Snapshots**: Complete backup of all relevant files
- **Incremental Snapshots**: Only changed files (future enhancement)
- **Metadata Snapshots**: File inventory without content
- **Git State Snapshots**: Repository state preservation

## 🎯 Success Criteria

### Multi-Factor Verification
- ✅ 100% detection of unsafe git states
- ✅ Zero cleanup during active operations  
- ✅ Accurate backup age classification
- ✅ Comprehensive reference chain analysis

### Risk Assessment
- ✅ >95% accuracy in importance scoring
- ✅ Appropriate safety level classification
- ✅ Risk-based workflow assignment
- ✅ Confidence correlation with outcomes

### Policy Enforcement
- ✅ 100% policy compliance verification
- ✅ Automatic violation detection
- ✅ Effective remediation suggestions
- ✅ Emergency stop response <2 seconds

### Rollback Coordination
- ✅ 100% recovery point creation success
- ✅ Complete rollback capability
- ✅ Emergency restore functionality
- ✅ Comprehensive audit trail

## 🔍 Troubleshooting

### Common Issues

**Verification Failures**
- Check git repository status
- Ensure no active git operations
- Verify backup file permissions

**Policy Violations**
- Review safety configuration
- Check emergency stop conditions
- Verify minimum age requirements

**Risk Assessment Issues**
- Update file type classifications
- Adjust confidence thresholds
- Review reference chain analysis

**Rollback Problems**
- Verify recovery point integrity
- Check available disk space
- Ensure proper permissions

### Debug Mode
```bash
# Enable verbose logging
export SAFETY_ORCHESTRATOR_DEBUG=1
python safety-orchestrator-main.py /path/to/project
```

### Logs and Reports
- Verification logs: `.claude/safety_verification_report.json`
- Operation logs: `.claude/recovery/operations/`
- Recovery points: `.claude/recovery/snapshots/`
- Audit trail: `.claude/safety_audit/`

## 🤝 Contributing

The Safety Orchestrator follows a modular architecture where each component can be enhanced independently:

1. **Multi-Factor Verifier**: Add new verification factors
2. **Risk Assessor**: Enhance scoring algorithms
3. **Policy Engine**: Add new safety policies  
4. **Rollback Coordinator**: Improve recovery mechanisms

## 📄 License

Part of the Claude Command System - See main project license.

---

**Remember**: The Safety Orchestrator prioritizes data preservation over aggressive cleanup. When in doubt, it errs on the side of caution to prevent accidental data loss.