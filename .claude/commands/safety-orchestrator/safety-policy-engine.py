#!/usr/bin/env python3
"""
Safety Policy Enforcement Engine for Backup Cleanup Operations
Enforces comprehensive safety policies with violation detection and prevention
"""

import os
import json
import time
import signal
import threading
from pathlib import Path
from typing import Dict, List, Optional, Set, Callable, Any
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from enum import Enum
import subprocess


class PolicyViolationType(Enum):
    """Types of safety policy violations"""
    CRITICAL = "critical"        # Blocks all operations
    WARNING = "warning"          # Allows with confirmation
    ADVISORY = "advisory"        # Informational only


class PolicyCategory(Enum):
    """Categories of safety policies"""
    GIT_OPERATIONS = "git_operations"
    BACKUP_AGE = "backup_age"
    REFERENCE_PRESERVATION = "reference_preservation"
    EMERGENCY_PATTERNS = "emergency_patterns"
    USER_CONFIRMATION = "user_confirmation"
    ROLLBACK_SAFETY = "rollback_safety"


@dataclass
class PolicyViolation:
    """A safety policy violation"""
    policy_id: str
    category: PolicyCategory
    violation_type: PolicyViolationType
    message: str
    details: Dict[str, Any] = field(default_factory=dict)
    remediation: Optional[str] = None
    detected_at: datetime = field(default_factory=datetime.now)


@dataclass
class SafetyPolicy:
    """Definition of a safety policy"""
    id: str
    category: PolicyCategory
    name: str
    description: str
    violation_type: PolicyViolationType
    check_function: Callable
    remediation_function: Optional[Callable] = None
    enabled: bool = True
    parameters: Dict[str, Any] = field(default_factory=dict)


@dataclass
class PolicyEnforcementResult:
    """Result of policy enforcement check"""
    passed: bool
    violations: List[PolicyViolation] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    blocked_operations: Set[str] = field(default_factory=set)
    allowed_operations: Set[str] = field(default_factory=set)


class SafetyPolicyEngine:
    """
    Comprehensive safety policy enforcement engine.
    
    Implements and enforces safety policies for backup cleanup operations
    with violation detection, prevention, and automatic remediation.
    """
    
    def __init__(self, config_path: Optional[Path] = None):
        self.config = self._load_config(config_path)
        self.policies: Dict[str, SafetyPolicy] = {}
        self.violation_history: List[PolicyViolation] = []
        self.emergency_stop_triggered = False
        self.monitoring_thread: Optional[threading.Thread] = None
        
        # Initialize built-in policies
        self._initialize_policies()
        
        # Start monitoring
        self._start_monitoring()
    
    def _load_config(self, config_path: Optional[Path]) -> Dict:
        """Load safety policy configuration"""
        default_config = {
            "safety_policies": {
                "git_operations": {
                    "block_during_merge": True,
                    "block_during_rebase": True,
                    "block_during_cherry_pick": True,
                    "require_clean_working_tree": False,
                    "check_interval_seconds": 5
                },
                "backup_age": {
                    "minimum_age_hours": 168,  # 7 days
                    "critical_age_hours": 24,  # 1 day
                    "warn_on_recent_backups": True
                },
                "reference_preservation": {
                    "preserve_recent_references": True,
                    "reference_lookback_days": 30,
                    "check_commit_messages": True,
                    "check_branch_names": True
                },
                "emergency_patterns": {
                    "check_failure_indicators": True,
                    "check_critical_patterns": True,
                    "check_active_processes": True,
                    "emergency_stop_file": ".claude/emergency_stop"
                },
                "user_confirmation": {
                    "require_for_risky_operations": True,
                    "timeout_seconds": 300,  # 5 minutes
                    "default_response": "deny"
                },
                "rollback_safety": {
                    "require_recovery_points": True,
                    "verify_rollback_capability": True,
                    "test_rollback_mechanisms": False
                }
            }
        }
        
        if config_path and config_path.exists():
            try:
                with open(config_path, 'r') as f:
                    user_config = json.load(f)
                return {**default_config, **user_config}
            except Exception as e:
                print(f"⚠️  Warning: Could not load policy config from {config_path}: {e}")
        
        return default_config
    
    def _initialize_policies(self):
        """Initialize all built-in safety policies"""
        # Git operations policies
        self._register_policy(SafetyPolicy(
            id="no_cleanup_during_git_operations",
            category=PolicyCategory.GIT_OPERATIONS,
            name="No Cleanup During Git Operations",
            description="Prevent backup cleanup during active git operations",
            violation_type=PolicyViolationType.CRITICAL,
            check_function=self._check_git_operations_policy,
            parameters=self.config["safety_policies"]["git_operations"]
        ))
        
        # Backup age policies
        self._register_policy(SafetyPolicy(
            id="minimum_backup_age",
            category=PolicyCategory.BACKUP_AGE,
            name="Minimum Backup Age",
            description="Ensure backups meet minimum age before cleanup",
            violation_type=PolicyViolationType.WARNING,
            check_function=self._check_backup_age_policy,
            parameters=self.config["safety_policies"]["backup_age"]
        ))
        
        # Reference preservation policies
        self._register_policy(SafetyPolicy(
            id="preserve_referenced_backups",
            category=PolicyCategory.REFERENCE_PRESERVATION,
            name="Preserve Referenced Backups",
            description="Preserve backups that are referenced in recent commits",
            violation_type=PolicyViolationType.WARNING,
            check_function=self._check_reference_preservation_policy,
            parameters=self.config["safety_policies"]["reference_preservation"]
        ))
        
        # Emergency pattern policies
        self._register_policy(SafetyPolicy(
            id="emergency_pattern_detection",
            category=PolicyCategory.EMERGENCY_PATTERNS,
            name="Emergency Pattern Detection",
            description="Detect emergency patterns that should prevent cleanup",
            violation_type=PolicyViolationType.CRITICAL,
            check_function=self._check_emergency_patterns_policy,
            parameters=self.config["safety_policies"]["emergency_patterns"]
        ))
        
        # User confirmation policies
        self._register_policy(SafetyPolicy(
            id="user_confirmation_required",
            category=PolicyCategory.USER_CONFIRMATION,
            name="User Confirmation Required",
            description="Require user confirmation for risky operations",
            violation_type=PolicyViolationType.WARNING,
            check_function=self._check_user_confirmation_policy,
            parameters=self.config["safety_policies"]["user_confirmation"]
        ))
        
        # Rollback safety policies
        self._register_policy(SafetyPolicy(
            id="rollback_safety_check",
            category=PolicyCategory.ROLLBACK_SAFETY,
            name="Rollback Safety Check",
            description="Ensure rollback mechanisms are available",
            violation_type=PolicyViolationType.WARNING,
            check_function=self._check_rollback_safety_policy,
            parameters=self.config["safety_policies"]["rollback_safety"]
        ))
    
    def _register_policy(self, policy: SafetyPolicy):
        """Register a safety policy"""
        self.policies[policy.id] = policy
    
    def _start_monitoring(self):
        """Start background monitoring for policy violations"""
        if self.monitoring_thread and self.monitoring_thread.is_alive():
            return
        
        self.monitoring_thread = threading.Thread(
            target=self._monitoring_loop,
            daemon=True
        )
        self.monitoring_thread.start()
    
    def _monitoring_loop(self):
        """Background monitoring loop"""
        check_interval = self.config["safety_policies"]["git_operations"]["check_interval_seconds"]
        
        while not self.emergency_stop_triggered:
            try:
                # Check for emergency stop conditions
                emergency_stop_file = Path(
                    self.config["safety_policies"]["emergency_patterns"]["emergency_stop_file"]
                )
                
                if emergency_stop_file.exists():
                    self._trigger_emergency_stop("Emergency stop file detected")
                    break
                
                time.sleep(check_interval)
                
            except Exception as e:
                print(f"⚠️  Monitoring loop error: {e}")
                time.sleep(check_interval)
    
    def _trigger_emergency_stop(self, reason: str):
        """Trigger emergency stop"""
        self.emergency_stop_triggered = True
        
        violation = PolicyViolation(
            policy_id="emergency_stop",
            category=PolicyCategory.EMERGENCY_PATTERNS,
            violation_type=PolicyViolationType.CRITICAL,
            message=f"Emergency stop triggered: {reason}"
        )
        
        self.violation_history.append(violation)
        print(f"🚨 EMERGENCY STOP: {reason}")
    
    def enforce_policies(self, operation_context: Dict[str, Any]) -> PolicyEnforcementResult:
        """
        Enforce all safety policies for a given operation context.
        
        Args:
            operation_context: Context information about the operation
            
        Returns:
            PolicyEnforcementResult with violations and recommendations
        """
        print("🛡️ Enforcing safety policies...")
        
        result = PolicyEnforcementResult(passed=True)
        
        # Check emergency stop first
        if self.emergency_stop_triggered:
            violation = PolicyViolation(
                policy_id="emergency_stop",
                category=PolicyCategory.EMERGENCY_PATTERNS,
                violation_type=PolicyViolationType.CRITICAL,
                message="Emergency stop is active - all operations blocked"
            )
            result.violations.append(violation)
            result.passed = False
            result.blocked_operations.add("all")
            return result
        
        # Check each enabled policy
        for policy_id, policy in self.policies.items():
            if not policy.enabled:
                continue
            
            try:
                violations = policy.check_function(operation_context, policy.parameters)
                
                for violation in violations:
                    self.violation_history.append(violation)
                    result.violations.append(violation)
                    
                    if violation.violation_type == PolicyViolationType.CRITICAL:
                        result.passed = False
                        result.blocked_operations.add(violation.policy_id)
                    elif violation.violation_type == PolicyViolationType.WARNING:
                        result.warnings.append(violation.message)
                    
            except Exception as e:
                print(f"⚠️  Error checking policy {policy_id}: {e}")
                # Treat policy check errors as warnings
                violation = PolicyViolation(
                    policy_id=policy_id,
                    category=policy.category,
                    violation_type=PolicyViolationType.WARNING,
                    message=f"Policy check failed: {e}"
                )
                result.violations.append(violation)
                result.warnings.append(f"Could not verify policy: {policy.name}")
        
        return result
    
    def _check_git_operations_policy(self, context: Dict[str, Any], params: Dict[str, Any]) -> List[PolicyViolation]:
        """Check git operations safety policy"""
        violations = []
        
        try:
            # Check for active git operations
            git_dir = Path(".git")
            if not git_dir.exists():
                return violations  # Not a git repository
            
            active_operations = []
            
            operation_files = {
                "MERGE_HEAD": "merge",
                "REBASE_HEAD": "rebase",
                "CHERRY_PICK_HEAD": "cherry-pick",
                "REVERT_HEAD": "revert",
                "BISECT_LOG": "bisect"
            }
            
            for file, operation in operation_files.items():
                if (git_dir / file).exists():
                    active_operations.append(operation)
            
            # Block cleanup during active operations
            if active_operations:
                violation = PolicyViolation(
                    policy_id="no_cleanup_during_git_operations",
                    category=PolicyCategory.GIT_OPERATIONS,
                    violation_type=PolicyViolationType.CRITICAL,
                    message=f"Active git operations detected: {', '.join(active_operations)}",
                    details={"active_operations": active_operations},
                    remediation="Complete or abort git operations before cleanup"
                )
                violations.append(violation)
            
            # Check working tree if required
            if params.get("require_clean_working_tree", False):
                result = subprocess.run([
                    "git", "status", "--porcelain"
                ], capture_output=True, text=True, check=False)
                
                if result.returncode == 0 and result.stdout.strip():
                    violation = PolicyViolation(
                        policy_id="no_cleanup_during_git_operations",
                        category=PolicyCategory.GIT_OPERATIONS,
                        violation_type=PolicyViolationType.WARNING,
                        message="Working tree has uncommitted changes",
                        details={"uncommitted_changes": result.stdout.strip().split('\n')},
                        remediation="Commit or stash changes before cleanup"
                    )
                    violations.append(violation)
            
        except Exception as e:
            # Create violation for check failure
            violation = PolicyViolation(
                policy_id="no_cleanup_during_git_operations",
                category=PolicyCategory.GIT_OPERATIONS,
                violation_type=PolicyViolationType.WARNING,
                message=f"Could not check git operations: {e}"
            )
            violations.append(violation)
        
        return violations
    
    def _check_backup_age_policy(self, context: Dict[str, Any], params: Dict[str, Any]) -> List[PolicyViolation]:
        """Check backup age safety policy"""
        violations = []
        
        backup_files = context.get("backup_files", [])
        minimum_age_hours = params.get("minimum_age_hours", 168)
        critical_age_hours = params.get("critical_age_hours", 24)
        
        for backup_file in backup_files:
            try:
                backup_path = Path(backup_file)
                if not backup_path.exists():
                    continue
                
                stat_info = backup_path.stat()
                mod_time = datetime.fromtimestamp(stat_info.st_mtime)
                age_hours = (datetime.now() - mod_time).total_seconds() / 3600
                
                # Critical violation for very recent backups
                if age_hours < critical_age_hours:
                    violation = PolicyViolation(
                        policy_id="minimum_backup_age",
                        category=PolicyCategory.BACKUP_AGE,
                        violation_type=PolicyViolationType.CRITICAL,
                        message=f"Backup too recent for cleanup: {backup_path.name} ({age_hours:.1f}h old)",
                        details={
                            "backup_file": str(backup_path),
                            "age_hours": age_hours,
                            "minimum_required": critical_age_hours
                        },
                        remediation=f"Wait at least {critical_age_hours - age_hours:.1f} hours before cleanup"
                    )
                    violations.append(violation)
                
                # Warning for backups under minimum age
                elif age_hours < minimum_age_hours:
                    violation = PolicyViolation(
                        policy_id="minimum_backup_age",
                        category=PolicyCategory.BACKUP_AGE,
                        violation_type=PolicyViolationType.WARNING,
                        message=f"Backup below minimum age: {backup_path.name} ({age_hours:.1f}h old)",
                        details={
                            "backup_file": str(backup_path),
                            "age_hours": age_hours,
                            "minimum_recommended": minimum_age_hours
                        },
                        remediation="Consider waiting longer or confirm cleanup intent"
                    )
                    violations.append(violation)
                
            except Exception as e:
                violation = PolicyViolation(
                    policy_id="minimum_backup_age",
                    category=PolicyCategory.BACKUP_AGE,
                    violation_type=PolicyViolationType.WARNING,
                    message=f"Could not check age of backup {backup_file}: {e}"
                )
                violations.append(violation)
        
        return violations
    
    def _check_reference_preservation_policy(self, context: Dict[str, Any], params: Dict[str, Any]) -> List[PolicyViolation]:
        """Check reference preservation safety policy"""
        violations = []
        
        if not params.get("preserve_recent_references", True):
            return violations
        
        backup_files = context.get("backup_files", [])
        lookback_days = params.get("reference_lookback_days", 30)
        since_date = (datetime.now() - timedelta(days=lookback_days)).strftime("%Y-%m-%d")
        
        try:
            # Get recent commit messages if enabled
            if params.get("check_commit_messages", True):
                result = subprocess.run([
                    "git", "log", f"--since={since_date}", "--oneline", "--all"
                ], capture_output=True, text=True, check=False)
                
                if result.returncode == 0:
                    recent_commits = result.stdout.lower()
                    
                    for backup_file in backup_files:
                        backup_name = Path(backup_file).name
                        backup_stem = Path(backup_file).stem
                        
                        if (backup_name.lower() in recent_commits or 
                            backup_stem.lower() in recent_commits):
                            
                            violation = PolicyViolation(
                                policy_id="preserve_referenced_backups",
                                category=PolicyCategory.REFERENCE_PRESERVATION,
                                violation_type=PolicyViolationType.WARNING,
                                message=f"Backup referenced in recent commits: {backup_name}",
                                details={
                                    "backup_file": backup_file,
                                    "reference_type": "commit_message",
                                    "lookback_days": lookback_days
                                },
                                remediation="Verify references before cleanup or preserve backup"
                            )
                            violations.append(violation)
            
            # Check branch names if enabled
            if params.get("check_branch_names", True):
                result = subprocess.run([
                    "git", "branch", "-a"
                ], capture_output=True, text=True, check=False)
                
                if result.returncode == 0:
                    branch_names = result.stdout.lower()
                    
                    for backup_file in backup_files:
                        backup_name = Path(backup_file).name
                        
                        if backup_name.lower() in branch_names:
                            violation = PolicyViolation(
                                policy_id="preserve_referenced_backups",
                                category=PolicyCategory.REFERENCE_PRESERVATION,
                                violation_type=PolicyViolationType.WARNING,
                                message=f"Backup name appears in branch names: {backup_name}",
                                details={
                                    "backup_file": backup_file,
                                    "reference_type": "branch_name"
                                },
                                remediation="Verify branch references before cleanup"
                            )
                            violations.append(violation)
            
        except Exception as e:
            violation = PolicyViolation(
                policy_id="preserve_referenced_backups",
                category=PolicyCategory.REFERENCE_PRESERVATION,
                violation_type=PolicyViolationType.WARNING,
                message=f"Could not check references: {e}"
            )
            violations.append(violation)
        
        return violations
    
    def _check_emergency_patterns_policy(self, context: Dict[str, Any], params: Dict[str, Any]) -> List[PolicyViolation]:
        """Check emergency patterns safety policy"""
        violations = []
        
        # Check for emergency stop file
        emergency_stop_file = Path(params.get("emergency_stop_file", ".claude/emergency_stop"))
        if emergency_stop_file.exists():
            violation = PolicyViolation(
                policy_id="emergency_pattern_detection",
                category=PolicyCategory.EMERGENCY_PATTERNS,
                violation_type=PolicyViolationType.CRITICAL,
                message="Emergency stop file detected",
                details={"emergency_file": str(emergency_stop_file)},
                remediation="Remove emergency stop file or investigate emergency condition"
            )
            violations.append(violation)
        
        # Check for failure indicators
        if params.get("check_failure_indicators", True):
            failure_patterns = [
                ".git/index.lock",
                "*.crash",
                "core.*",
                "*.emergency"
            ]
            
            for pattern in failure_patterns:
                matches = list(Path(".").rglob(pattern))
                if matches:
                    violation = PolicyViolation(
                        policy_id="emergency_pattern_detection",
                        category=PolicyCategory.EMERGENCY_PATTERNS,
                        violation_type=PolicyViolationType.CRITICAL,
                        message=f"Failure indicators found: {pattern}",
                        details={
                            "pattern": pattern,
                            "matches": [str(m) for m in matches]
                        },
                        remediation="Investigate failure indicators before cleanup"
                    )
                    violations.append(violation)
        
        # Check for critical backup patterns
        if params.get("check_critical_patterns", True):
            critical_patterns = [
                "*.critical.backup.*",
                "*.emergency.backup.*",
                "*.production.backup.*"
            ]
            
            for pattern in critical_patterns:
                matches = list(Path(".").rglob(pattern))
                if matches:
                    violation = PolicyViolation(
                        policy_id="emergency_pattern_detection",
                        category=PolicyCategory.EMERGENCY_PATTERNS,
                        violation_type=PolicyViolationType.WARNING,
                        message=f"Critical backup pattern found: {pattern}",
                        details={
                            "pattern": pattern,
                            "matches": [str(m) for m in matches]
                        },
                        remediation="Exercise extra caution with critical backups"
                    )
                    violations.append(violation)
        
        return violations
    
    def _check_user_confirmation_policy(self, context: Dict[str, Any], params: Dict[str, Any]) -> List[PolicyViolation]:
        """Check user confirmation safety policy"""
        violations = []
        
        if not params.get("require_for_risky_operations", True):
            return violations
        
        # Check if operation requires user confirmation
        operation_risk_level = context.get("risk_level", "unknown")
        
        if operation_risk_level in ["risky", "cautious", "unknown"]:
            violation = PolicyViolation(
                policy_id="user_confirmation_required",
                category=PolicyCategory.USER_CONFIRMATION,
                violation_type=PolicyViolationType.WARNING,
                message=f"User confirmation required for {operation_risk_level} operation",
                details={
                    "risk_level": operation_risk_level,
                    "timeout_seconds": params.get("timeout_seconds", 300)
                },
                remediation="Obtain explicit user confirmation before proceeding"
            )
            violations.append(violation)
        
        return violations
    
    def _check_rollback_safety_policy(self, context: Dict[str, Any], params: Dict[str, Any]) -> List[PolicyViolation]:
        """Check rollback safety policy"""
        violations = []
        
        # Check if recovery points are required and available
        if params.get("require_recovery_points", True):
            recovery_points_dir = Path(".claude/recovery")
            
            if not recovery_points_dir.exists():
                violation = PolicyViolation(
                    policy_id="rollback_safety_check",
                    category=PolicyCategory.ROLLBACK_SAFETY,
                    violation_type=PolicyViolationType.WARNING,
                    message="No recovery points directory found",
                    details={"expected_dir": str(recovery_points_dir)},
                    remediation="Create recovery point before cleanup"
                )
                violations.append(violation)
        
        # Check rollback capability verification
        if params.get("verify_rollback_capability", True):
            # This is a placeholder for rollback capability verification
            # In a real implementation, this would test rollback mechanisms
            pass
        
        return violations
    
    def get_policy_status(self) -> Dict[str, Any]:
        """Get comprehensive policy status report"""
        return {
            "timestamp": datetime.now().isoformat(),
            "emergency_stop_active": self.emergency_stop_triggered,
            "total_policies": len(self.policies),
            "enabled_policies": sum(1 for p in self.policies.values() if p.enabled),
            "recent_violations": len([
                v for v in self.violation_history 
                if v.detected_at > datetime.now() - timedelta(hours=1)
            ]),
            "policies": {
                policy_id: {
                    "name": policy.name,
                    "category": policy.category.value,
                    "enabled": policy.enabled,
                    "violation_type": policy.violation_type.value
                }
                for policy_id, policy in self.policies.items()
            },
            "violation_summary": self._get_violation_summary()
        }
    
    def _get_violation_summary(self) -> Dict[str, int]:
        """Get summary of violations by type and category"""
        summary = {
            "critical": 0,
            "warning": 0,
            "advisory": 0
        }
        
        for violation in self.violation_history:
            summary[violation.violation_type.value] += 1
        
        return summary
    
    def enable_policy(self, policy_id: str):
        """Enable a specific policy"""
        if policy_id in self.policies:
            self.policies[policy_id].enabled = True
    
    def disable_policy(self, policy_id: str):
        """Disable a specific policy"""
        if policy_id in self.policies:
            self.policies[policy_id].enabled = False
    
    def clear_violation_history(self):
        """Clear violation history"""
        self.violation_history.clear()
    
    def reset_emergency_stop(self):
        """Reset emergency stop state"""
        self.emergency_stop_triggered = False
        
        # Remove emergency stop file if it exists
        emergency_stop_file = Path(
            self.config["safety_policies"]["emergency_patterns"]["emergency_stop_file"]
        )
        if emergency_stop_file.exists():
            emergency_stop_file.unlink()


def main():
    """Example usage of the safety policy engine"""
    engine = SafetyPolicyEngine()
    
    print("🛡️ Safety Policy Engine")
    print("=" * 50)
    
    # Print policy status
    status = engine.get_policy_status()
    print(f"Total policies: {status['total_policies']}")
    print(f"Enabled policies: {status['enabled_policies']}")
    print(f"Emergency stop active: {status['emergency_stop_active']}")
    
    # Example operation context
    operation_context = {
        "backup_files": ["test.backup.123", "config.backup.456"],
        "risk_level": "cautious",
        "operation_type": "cleanup"
    }
    
    # Enforce policies
    result = engine.enforce_policies(operation_context)
    
    print(f"\nPolicy enforcement result: {'✅ PASSED' if result.passed else '❌ FAILED'}")
    
    if result.violations:
        print("\nViolations:")
        for violation in result.violations:
            status = {
                PolicyViolationType.CRITICAL: "🚨",
                PolicyViolationType.WARNING: "⚠️",
                PolicyViolationType.ADVISORY: "💡"
            }[violation.violation_type]
            
            print(f"  {status} {violation.message}")
            if violation.remediation:
                print(f"     Remediation: {violation.remediation}")
    
    if result.warnings:
        print("\nWarnings:")
        for warning in result.warnings:
            print(f"  ⚠️  {warning}")
    
    if result.blocked_operations:
        print(f"\nBlocked operations: {', '.join(result.blocked_operations)}")


if __name__ == "__main__":
    main()