"""
Safety Orchestrator Package - Comprehensive Safety System for Backup Cleanup Operations

This package provides a complete safety system for backup cleanup operations with:
- Multi-factor verification
- Risk assessment algorithms
- Safety policy enforcement
- Rollback and recovery coordination

Usage:
    from safety_orchestrator import SafetyOrchestrator
    
    orchestrator = SafetyOrchestrator()
    report = await orchestrator.orchestrate_safe_cleanup(target_dir)
"""

from .multi_factor_verifier import MultiFactorVerifier, VerificationResult, VerificationFactor
from .risk_assessment_engine import RiskAssessmentEngine, RiskAssessment, SafetyLevel, BackupType
from .safety_policy_engine import SafetyPolicyEngine, PolicyEnforcementResult, PolicyViolation
from .rollback_coordinator import RollbackCoordinator, RecoveryPoint, RecoveryPointType
from .safety_orchestrator_main import SafetyOrchestrator, SafetyOrchestrationReport, SafetyOrchestrationResult

__version__ = "1.0.0"
__author__ = "Claude Safety Team"

__all__ = [
    # Main orchestrator
    "SafetyOrchestrator",
    "SafetyOrchestrationReport", 
    "SafetyOrchestrationResult",
    
    # Multi-factor verification
    "MultiFactorVerifier",
    "VerificationResult",
    "VerificationFactor",
    
    # Risk assessment
    "RiskAssessmentEngine",
    "RiskAssessment", 
    "SafetyLevel",
    "BackupType",
    
    # Policy enforcement
    "SafetyPolicyEngine",
    "PolicyEnforcementResult",
    "PolicyViolation",
    
    # Rollback coordination
    "RollbackCoordinator",
    "RecoveryPoint",
    "RecoveryPointType"
]