#!/usr/bin/env python3
"""
Main Safety Orchestrator - Comprehensive Safety System for Backup Cleanup
Integrates all safety components: verification, risk assessment, policy enforcement, and rollback coordination
"""

import os
import sys
import json
import asyncio
import argparse
from pathlib import Path
from typing import Dict, List, Optional, Any
from dataclasses import dataclass
from datetime import datetime
from enum import Enum

# Import safety components
from multi_factor_verifier import MultiFactorVerifier, VerificationResult
from risk_assessment_engine import RiskAssessmentEngine, RiskAssessment, SafetyLevel
from safety_policy_engine import SafetyPolicyEngine, PolicyEnforcementResult
from rollback_coordinator import RollbackCoordinator, RecoveryPointType


class SafetyOrchestrationResult(Enum):
    """Results of safety orchestration"""
    SUCCESS = "success"
    VERIFICATION_FAILED = "verification_failed"
    POLICY_VIOLATION = "policy_violation"
    RISK_TOO_HIGH = "risk_too_high"
    USER_CANCELLED = "user_cancelled"
    EMERGENCY_STOP = "emergency_stop"
    SYSTEM_ERROR = "system_error"


@dataclass
class SafetyOrchestrationReport:
    """Comprehensive safety orchestration report"""
    result: SafetyOrchestrationResult
    timestamp: datetime
    target_directory: Path
    verification_results: Dict[str, VerificationResult]
    risk_assessments: List[RiskAssessment]
    policy_enforcement: PolicyEnforcementResult
    recovery_point_id: Optional[str]
    cleanup_decisions: List[Dict[str, Any]]
    summary: Dict[str, Any]
    
    def to_dict(self) -> Dict:
        return {
            "result": self.result.value,
            "timestamp": self.timestamp.isoformat(),
            "target_directory": str(self.target_directory),
            "verification_results": {
                name: result.to_dict() for name, result in self.verification_results.items()
            },
            "risk_assessments": [ra.to_dict() for ra in self.risk_assessments],
            "policy_enforcement": {
                "passed": self.policy_enforcement.passed,
                "violations": [v.__dict__ for v in self.policy_enforcement.violations],
                "warnings": self.policy_enforcement.warnings,
                "blocked_operations": list(self.policy_enforcement.blocked_operations)
            },
            "recovery_point_id": self.recovery_point_id,
            "cleanup_decisions": self.cleanup_decisions,
            "summary": self.summary
        }


class SafetyOrchestrator:
    """
    Main safety orchestrator that coordinates all safety components.
    
    Provides comprehensive safety validation for backup cleanup operations
    through multi-factor verification, risk assessment, policy enforcement,
    and rollback coordination.
    """
    
    def __init__(self, config_path: Optional[Path] = None):
        self.config_path = config_path
        
        # Initialize components
        self.verifier = MultiFactorVerifier(config_path)
        self.risk_assessor = RiskAssessmentEngine()
        self.policy_engine = SafetyPolicyEngine(config_path)
        self.rollback_coordinator = RollbackCoordinator()
        
        print("🛡️ Safety Orchestrator initialized")
        print("   ✅ Multi-factor verifier ready")
        print("   ✅ Risk assessment engine ready")
        print("   ✅ Safety policy engine ready")
        print("   ✅ Rollback coordinator ready")
    
    async def orchestrate_safe_cleanup(
        self,
        target_dir: Path,
        dry_run: bool = True,
        interactive: bool = True
    ) -> SafetyOrchestrationReport:
        """
        Execute comprehensive safety orchestration for backup cleanup.
        
        Args:
            target_dir: Directory to perform cleanup in
            dry_run: If True, only analyze without executing cleanup
            interactive: If True, prompt user for confirmations
            
        Returns:
            Comprehensive safety orchestration report
        """
        print("\n" + "=" * 60)
        print("🛡️ SAFETY ORCHESTRATOR - COMPREHENSIVE BACKUP CLEANUP SAFETY")
        print("=" * 60)
        print(f"Target Directory: {target_dir}")
        print(f"Mode: {'DRY RUN' if dry_run else 'EXECUTION'}")
        print(f"Interactive: {'YES' if interactive else 'NO'}")
        print()
        
        start_time = datetime.now()
        
        try:
            # Phase 1: Multi-Factor Verification
            print("🔍 PHASE 1: Multi-Factor Verification")
            print("-" * 40)
            
            verification_results = await self.verifier.verify_all_factors(target_dir)
            overall_passed, overall_confidence, critical_issues = self.verifier.get_overall_verification_status()
            
            print(f"Verification Result: {'✅ PASSED' if overall_passed else '❌ FAILED'}")
            print(f"Overall Confidence: {overall_confidence:.2f}")
            
            if critical_issues:
                print("Critical Issues:")
                for issue in critical_issues:
                    print(f"  🚨 {issue}")
                
                return SafetyOrchestrationReport(
                    result=SafetyOrchestrationResult.VERIFICATION_FAILED,
                    timestamp=start_time,
                    target_directory=target_dir,
                    verification_results=verification_results,
                    risk_assessments=[],
                    policy_enforcement=PolicyEnforcementResult(passed=False),
                    recovery_point_id=None,
                    cleanup_decisions=[],
                    summary={"critical_issues": critical_issues}
                )
            
            # Phase 2: Create Recovery Point
            print("\n📸 PHASE 2: Recovery Point Creation")
            print("-" * 40)
            
            recovery_point_id = self.rollback_coordinator.create_recovery_point(
                f"Pre-cleanup snapshot - {start_time.isoformat()}",
                RecoveryPointType.FULL_SNAPSHOT,
                include_git_state=True
            )
            
            # Phase 3: Discover and Assess Backup Files
            print("\n📊 PHASE 3: Risk Assessment")
            print("-" * 40)
            
            backup_files = self._discover_backup_files(target_dir)
            print(f"Discovered {len(backup_files)} backup files")
            
            risk_assessments = []
            for backup_file in backup_files:
                assessment = await self.risk_assessor.assess_backup_risk(backup_file, verification_results)
                risk_assessments.append(assessment)
                
                safety_emoji = {
                    SafetyLevel.SAFE: "🟢",
                    SafetyLevel.CAUTIOUS: "🟡", 
                    SafetyLevel.RISKY: "🔴"
                }[assessment.safety_level]
                
                print(f"  {safety_emoji} {backup_file.name}: {assessment.safety_level.value} ({assessment.confidence_score:.2f})")
            
            # Phase 4: Policy Enforcement
            print("\n🛡️ PHASE 4: Policy Enforcement")
            print("-" * 40)
            
            operation_context = {
                "backup_files": [str(bf) for bf in backup_files],
                "risk_level": self._determine_overall_risk_level(risk_assessments),
                "operation_type": "cleanup",
                "target_directory": str(target_dir),
                "recovery_point_id": recovery_point_id
            }
            
            policy_result = self.policy_engine.enforce_policies(operation_context)
            
            print(f"Policy Enforcement: {'✅ PASSED' if policy_result.passed else '❌ FAILED'}")
            
            if not policy_result.passed:
                print("Policy Violations:")
                for violation in policy_result.violations:
                    if violation.violation_type.value == "critical":
                        print(f"  🚨 {violation.message}")
                
                return SafetyOrchestrationReport(
                    result=SafetyOrchestrationResult.POLICY_VIOLATION,
                    timestamp=start_time,
                    target_directory=target_dir,
                    verification_results=verification_results,
                    risk_assessments=risk_assessments,
                    policy_enforcement=policy_result,
                    recovery_point_id=recovery_point_id,
                    cleanup_decisions=[],
                    summary={"policy_violations": len(policy_result.violations)}
                )
            
            if policy_result.warnings:
                print("Policy Warnings:")
                for warning in policy_result.warnings:
                    print(f"  ⚠️  {warning}")
            
            # Phase 5: Decision Making and Execution
            print("\n⚙️ PHASE 5: Decision Making and Execution")
            print("-" * 40)
            
            cleanup_decisions = []
            
            for assessment in risk_assessments:
                decision = await self._make_cleanup_decision(
                    assessment, interactive, dry_run
                )
                cleanup_decisions.append(decision)
                
                action_emoji = {
                    "auto_cleanup": "🤖",
                    "user_approved": "👤✅",
                    "user_rejected": "👤❌",
                    "preserved": "🛡️",
                    "manual_review": "📋"
                }
                
                emoji = action_emoji.get(decision["action"], "❓")
                print(f"  {emoji} {assessment.backup_path.name}: {decision['action']}")
                
                if decision.get("reason"):
                    print(f"      Reason: {decision['reason']}")
            
            # Phase 6: Execute Cleanup (if not dry run)
            if not dry_run:
                print("\n🚀 PHASE 6: Cleanup Execution")
                print("-" * 40)
                
                execution_success = await self._execute_cleanup_decisions(
                    cleanup_decisions, recovery_point_id
                )
                
                if not execution_success:
                    return SafetyOrchestrationReport(
                        result=SafetyOrchestrationResult.SYSTEM_ERROR,
                        timestamp=start_time,
                        target_directory=target_dir,
                        verification_results=verification_results,
                        risk_assessments=risk_assessments,
                        policy_enforcement=policy_result,
                        recovery_point_id=recovery_point_id,
                        cleanup_decisions=cleanup_decisions,
                        summary={"execution_failed": True}
                    )
            
            # Generate Summary
            summary = self._generate_summary(
                verification_results, risk_assessments, cleanup_decisions, dry_run
            )
            
            print("\n" + "=" * 60)
            print("✅ SAFETY ORCHESTRATION COMPLETED SUCCESSFULLY")
            print("=" * 60)
            self._print_summary(summary)
            
            return SafetyOrchestrationReport(
                result=SafetyOrchestrationResult.SUCCESS,
                timestamp=start_time,
                target_directory=target_dir,
                verification_results=verification_results,
                risk_assessments=risk_assessments,
                policy_enforcement=policy_result,
                recovery_point_id=recovery_point_id,
                cleanup_decisions=cleanup_decisions,
                summary=summary
            )
            
        except KeyboardInterrupt:
            print("\n🚨 User cancelled operation")
            return SafetyOrchestrationReport(
                result=SafetyOrchestrationResult.USER_CANCELLED,
                timestamp=start_time,
                target_directory=target_dir,
                verification_results={},
                risk_assessments=[],
                policy_enforcement=PolicyEnforcementResult(passed=False),
                recovery_point_id=None,
                cleanup_decisions=[],
                summary={"user_cancelled": True}
            )
            
        except Exception as e:
            print(f"\n❌ System error during orchestration: {e}")
            return SafetyOrchestrationReport(
                result=SafetyOrchestrationResult.SYSTEM_ERROR,
                timestamp=start_time,
                target_directory=target_dir,
                verification_results={},
                risk_assessments=[],
                policy_enforcement=PolicyEnforcementResult(passed=False),
                recovery_point_id=None,
                cleanup_decisions=[],
                summary={"system_error": str(e)}
            )
    
    def _discover_backup_files(self, target_dir: Path) -> List[Path]:
        """Discover all backup files in the target directory"""
        backup_patterns = [
            "*.backup.*",
            "*.bak",
            "*.backup",
            "*~",
            "*.orig",
            "*.save"
        ]
        
        backup_files = []
        for pattern in backup_patterns:
            backup_files.extend(target_dir.rglob(pattern))
        
        # Remove duplicates and ensure files exist
        unique_files = []
        seen = set()
        for file_path in backup_files:
            if file_path.is_file() and str(file_path) not in seen:
                unique_files.append(file_path)
                seen.add(str(file_path))
        
        return sorted(unique_files)
    
    def _determine_overall_risk_level(self, risk_assessments: List[RiskAssessment]) -> str:
        """Determine overall risk level from individual assessments"""
        if not risk_assessments:
            return "unknown"
        
        risk_counts = {
            SafetyLevel.SAFE: 0,
            SafetyLevel.CAUTIOUS: 0,
            SafetyLevel.RISKY: 0
        }
        
        for assessment in risk_assessments:
            risk_counts[assessment.safety_level] += 1
        
        # If any risky items, overall is risky
        if risk_counts[SafetyLevel.RISKY] > 0:
            return "risky"
        elif risk_counts[SafetyLevel.CAUTIOUS] > 0:
            return "cautious"
        else:
            return "safe"
    
    async def _make_cleanup_decision(
        self,
        assessment: RiskAssessment,
        interactive: bool,
        dry_run: bool
    ) -> Dict[str, Any]:
        """Make cleanup decision for a backup file"""
        decision = {
            "backup_path": str(assessment.backup_path),
            "safety_level": assessment.safety_level.value,
            "importance_score": assessment.importance_score,
            "confidence_score": assessment.confidence_score,
            "action": "unknown",
            "reason": "",
            "user_input": None
        }
        
        if assessment.safety_level == SafetyLevel.SAFE:
            decision["action"] = "auto_cleanup" if not dry_run else "would_auto_cleanup"
            decision["reason"] = "High confidence, safe for automatic cleanup"
            
        elif assessment.safety_level == SafetyLevel.CAUTIOUS:
            if interactive:
                user_choice = await self._prompt_user_decision(assessment)
                if user_choice == "approve":
                    decision["action"] = "user_approved" if not dry_run else "would_user_approve"
                    decision["reason"] = "User approved cleanup"
                else:
                    decision["action"] = "preserved"
                    decision["reason"] = f"User chose to {user_choice}"
                decision["user_input"] = user_choice
            else:
                decision["action"] = "preserved"
                decision["reason"] = "Cautious level requires user confirmation (non-interactive mode)"
                
        else:  # RISKY
            decision["action"] = "manual_review"
            decision["reason"] = "High risk - requires manual review"
        
        return decision
    
    async def _prompt_user_decision(self, assessment: RiskAssessment) -> str:
        """Prompt user for cleanup decision"""
        print(f"\n{'='*50}")
        print(f"🤔 USER DECISION REQUIRED")
        print(f"{'='*50}")
        print(f"File: {assessment.backup_path.name}")
        print(f"Type: {assessment.backup_type.value}")
        print(f"Safety Level: {assessment.safety_level.value}")
        print(f"Importance Score: {assessment.importance_score:.2f}")
        print(f"Confidence: {assessment.confidence_score:.2f}")
        
        if assessment.concerns:
            print(f"\nConcerns:")
            for concern in assessment.concerns:
                print(f"  ⚠️  {concern}")
        
        if assessment.recommendations:
            print(f"\nRecommendations:")
            for rec in assessment.recommendations:
                print(f"  💡 {rec}")
        
        print(f"\nOptions:")
        print(f"  [A]pprove cleanup")
        print(f"  [R]eject (preserve file)")
        print(f"  [S]kip for now")
        print(f"  [I]nvestigate further")
        
        while True:
            try:
                choice = input("\nYour choice [A/R/S/I]: ").strip().upper()
                
                if choice in ['A', 'APPROVE']:
                    return "approve"
                elif choice in ['R', 'REJECT']:
                    return "reject"
                elif choice in ['S', 'SKIP']:
                    return "skip"
                elif choice in ['I', 'INVESTIGATE']:
                    return "investigate"
                else:
                    print("Invalid choice. Please enter A, R, S, or I.")
                    
            except (EOFError, KeyboardInterrupt):
                return "reject"  # Default to safe choice
    
    async def _execute_cleanup_decisions(
        self,
        cleanup_decisions: List[Dict[str, Any]],
        recovery_point_id: str
    ) -> bool:
        """Execute the cleanup decisions"""
        def cleanup_operation():
            executed_count = 0
            
            for decision in cleanup_decisions:
                if decision["action"] in ["auto_cleanup", "user_approved"]:
                    backup_path = Path(decision["backup_path"])
                    
                    try:
                        if backup_path.exists():
                            backup_path.unlink()
                            executed_count += 1
                            print(f"    ✅ Deleted: {backup_path.name}")
                        else:
                            print(f"    ⚠️  File already gone: {backup_path.name}")
                            
                    except Exception as e:
                        print(f"    ❌ Failed to delete {backup_path.name}: {e}")
                        raise
            
            return executed_count
        
        # Execute with rollback coordination
        op_id = self.rollback_coordinator.start_operation(
            "Backup cleanup execution",
            recovery_point_id
        )
        
        success = self.rollback_coordinator.execute_operation(
            op_id, cleanup_operation
        )
        
        return success
    
    def _generate_summary(
        self,
        verification_results: Dict[str, VerificationResult],
        risk_assessments: List[RiskAssessment],
        cleanup_decisions: List[Dict[str, Any]],
        dry_run: bool
    ) -> Dict[str, Any]:
        """Generate comprehensive summary"""
        # Verification summary
        verification_summary = {
            "total_factors": len(verification_results),
            "passed_factors": sum(1 for r in verification_results.values() if r.passed),
            "failed_factors": sum(1 for r in verification_results.values() if not r.passed)
        }
        
        # Risk assessment summary
        risk_summary = {
            "total_backups": len(risk_assessments),
            "safe": sum(1 for ra in risk_assessments if ra.safety_level == SafetyLevel.SAFE),
            "cautious": sum(1 for ra in risk_assessments if ra.safety_level == SafetyLevel.CAUTIOUS),
            "risky": sum(1 for ra in risk_assessments if ra.safety_level == SafetyLevel.RISKY)
        }
        
        # Cleanup decision summary
        decision_summary = {
            "total_decisions": len(cleanup_decisions),
            "auto_cleanup": sum(1 for d in cleanup_decisions if "auto" in d["action"]),
            "user_approved": sum(1 for d in cleanup_decisions if "user_approved" in d["action"]),
            "preserved": sum(1 for d in cleanup_decisions if d["action"] == "preserved"),
            "manual_review": sum(1 for d in cleanup_decisions if d["action"] == "manual_review")
        }
        
        return {
            "verification": verification_summary,
            "risk_assessment": risk_summary,
            "cleanup_decisions": decision_summary,
            "dry_run": dry_run,
            "timestamp": datetime.now().isoformat()
        }
    
    def _print_summary(self, summary: Dict[str, Any]):
        """Print formatted summary"""
        print(f"📊 SAFETY ORCHESTRATION SUMMARY")
        print()
        
        # Verification results
        v = summary["verification"]
        print(f"🔍 Verification: {v['passed_factors']}/{v['total_factors']} factors passed")
        
        # Risk assessment results
        r = summary["risk_assessment"]
        print(f"📊 Risk Assessment: {r['total_backups']} files analyzed")
        print(f"   🟢 Safe: {r['safe']}")
        print(f"   🟡 Cautious: {r['cautious']}")
        print(f"   🔴 Risky: {r['risky']}")
        
        # Cleanup decisions
        d = summary["cleanup_decisions"]
        print(f"⚙️ Cleanup Decisions: {d['total_decisions']} files processed")
        print(f"   🤖 Auto cleanup: {d['auto_cleanup']}")
        print(f"   👤 User approved: {d['user_approved']}")
        print(f"   🛡️ Preserved: {d['preserved']}")
        print(f"   📋 Manual review: {d['manual_review']}")
        
        if summary["dry_run"]:
            print(f"   💡 Note: Dry run mode - no files were actually deleted")


async def main():
    """Main entry point for the safety orchestrator"""
    parser = argparse.ArgumentParser(
        description="Safety Orchestrator - Comprehensive Backup Cleanup Safety System"
    )
    
    parser.add_argument(
        "target_dir",
        nargs="?",
        default=".",
        help="Target directory for backup cleanup (default: current directory)"
    )
    
    parser.add_argument(
        "--config",
        type=Path,
        help="Path to safety configuration file"
    )
    
    parser.add_argument(
        "--dry-run",
        action="store_true",
        default=True,
        help="Analyze only, don't execute cleanup (default: True)"
    )
    
    parser.add_argument(
        "--execute",
        action="store_true",
        help="Actually execute cleanup (overrides --dry-run)"
    )
    
    parser.add_argument(
        "--non-interactive",
        action="store_true",
        help="Run in non-interactive mode"
    )
    
    parser.add_argument(
        "--report-file",
        type=Path,
        help="Save detailed report to file"
    )
    
    args = parser.parse_args()
    
    # Determine execution mode
    dry_run = not args.execute
    interactive = not args.non_interactive
    target_dir = Path(args.target_dir).resolve()
    
    if not target_dir.exists():
        print(f"❌ Target directory does not exist: {target_dir}")
        sys.exit(1)
    
    # Initialize safety orchestrator
    orchestrator = SafetyOrchestrator(args.config)
    
    # Execute safety orchestration
    report = await orchestrator.orchestrate_safe_cleanup(
        target_dir, dry_run, interactive
    )
    
    # Save report if requested
    if args.report_file:
        try:
            args.report_file.parent.mkdir(parents=True, exist_ok=True)
            with open(args.report_file, 'w') as f:
                json.dump(report.to_dict(), f, indent=2)
            print(f"\n📄 Detailed report saved to: {args.report_file}")
        except Exception as e:
            print(f"⚠️  Could not save report: {e}")
    
    # Exit with appropriate code
    exit_codes = {
        SafetyOrchestrationResult.SUCCESS: 0,
        SafetyOrchestrationResult.VERIFICATION_FAILED: 1,
        SafetyOrchestrationResult.POLICY_VIOLATION: 2,
        SafetyOrchestrationResult.RISK_TOO_HIGH: 3,
        SafetyOrchestrationResult.USER_CANCELLED: 4,
        SafetyOrchestrationResult.EMERGENCY_STOP: 5,
        SafetyOrchestrationResult.SYSTEM_ERROR: 6
    }
    
    sys.exit(exit_codes.get(report.result, 6))


if __name__ == "__main__":
    asyncio.run(main())