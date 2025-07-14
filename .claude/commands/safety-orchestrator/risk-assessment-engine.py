#!/usr/bin/env python3
"""
Risk Assessment Engine for Backup Cleanup Operations
Calculates backup importance scores and assesses cleanup safety levels
"""

import os
import re
import json
import hashlib
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Set
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from enum import Enum
import mimetypes


class SafetyLevel(Enum):
    """Safety levels for backup cleanup operations"""
    SAFE = "safe"           # 85-100% confidence - auto-execute
    CAUTIOUS = "cautious"   # 60-84% confidence - user confirmation
    RISKY = "risky"         # 0-59% confidence - manual review


class BackupType(Enum):
    """Types of backup files"""
    SOURCE_CODE = "source_code"
    CONFIGURATION = "configuration" 
    DATA_FILE = "data_file"
    BINARY = "binary"
    DOCUMENTATION = "documentation"
    TEMPORARY = "temporary"
    UNKNOWN = "unknown"


@dataclass
class RiskFactor:
    """Individual risk factor for backup assessment"""
    name: str
    weight: float
    score: float
    description: str
    evidence: List[str] = field(default_factory=list)


@dataclass
class RiskAssessment:
    """Comprehensive risk assessment for a backup file"""
    backup_path: Path
    backup_type: BackupType
    importance_score: float
    safety_level: SafetyLevel
    confidence_score: float
    risk_factors: List[RiskFactor] = field(default_factory=list)
    concerns: List[str] = field(default_factory=list)
    recommendations: List[str] = field(default_factory=list)
    recommended_action: str = ""
    
    def to_dict(self) -> Dict:
        return {
            "backup_path": str(self.backup_path),
            "backup_type": self.backup_type.value,
            "importance_score": self.importance_score,
            "safety_level": self.safety_level.value,
            "confidence_score": self.confidence_score,
            "risk_factors": [
                {
                    "name": rf.name,
                    "weight": rf.weight,
                    "score": rf.score,
                    "description": rf.description,
                    "evidence": rf.evidence
                }
                for rf in self.risk_factors
            ],
            "concerns": self.concerns,
            "recommendations": self.recommendations,
            "recommended_action": self.recommended_action
        }


class RiskAssessmentEngine:
    """
    Advanced risk assessment engine for backup cleanup operations.
    
    Calculates backup importance scores, assesses cleanup safety levels,
    and generates cleanup recommendations with confidence levels.
    """
    
    def __init__(self, config: Optional[Dict] = None):
        self.config = config or self._get_default_config()
        self.git_repo_root = self._find_git_repo_root()
        
    def _get_default_config(self) -> Dict:
        """Get default risk assessment configuration"""
        return {
            "risk_assessment": {
                "importance_factors": {
                    "file_type_weight": 0.25,
                    "recency_weight": 0.25,
                    "reference_density_weight": 0.30,
                    "uniqueness_weight": 0.20
                },
                "safety_thresholds": {
                    "safe_level": 0.85,
                    "cautious_level": 0.60,
                    "risky_level": 0.00
                },
                "backup_age_thresholds": {
                    "fresh_hours": 24,
                    "recent_days": 7,
                    "stable_days": 30,
                    "stale_days": 90
                }
            }
        }
    
    def _find_git_repo_root(self) -> Optional[Path]:
        """Find the root of the git repository"""
        try:
            result = subprocess.run([
                "git", "rev-parse", "--show-toplevel"
            ], capture_output=True, text=True, check=True)
            return Path(result.stdout.strip())
        except:
            return None
    
    async def assess_backup_risk(self, backup_path: Path, verification_results: Dict) -> RiskAssessment:
        """
        Perform comprehensive risk assessment for a backup file.
        
        Args:
            backup_path: Path to the backup file to assess
            verification_results: Results from multi-factor verification
            
        Returns:
            Complete risk assessment with safety recommendations
        """
        print(f"  📊 Assessing risk for: {backup_path.name}")
        
        # Determine backup type
        backup_type = self._classify_backup_type(backup_path)
        
        # Calculate individual risk factors
        risk_factors = []
        
        # File type importance
        file_type_factor = self._assess_file_type_importance(backup_path, backup_type)
        risk_factors.append(file_type_factor)
        
        # Recency factor
        recency_factor = self._assess_recency_risk(backup_path)
        risk_factors.append(recency_factor)
        
        # Reference density
        reference_factor = self._assess_reference_density(backup_path, verification_results)
        risk_factors.append(reference_factor)
        
        # Uniqueness factor
        uniqueness_factor = self._assess_uniqueness_risk(backup_path)
        risk_factors.append(uniqueness_factor)
        
        # Git context factor
        git_factor = self._assess_git_context_risk(backup_path)
        risk_factors.append(git_factor)
        
        # Content analysis factor
        content_factor = self._assess_content_risk(backup_path)
        risk_factors.append(content_factor)
        
        # Calculate overall importance score
        importance_score = self._calculate_importance_score(risk_factors)
        
        # Calculate confidence score
        confidence_score = self._calculate_confidence_score(risk_factors, verification_results)
        
        # Determine safety level
        safety_level = self._determine_safety_level(importance_score, confidence_score)
        
        # Generate concerns and recommendations
        concerns = self._generate_concerns(risk_factors, safety_level)
        recommendations = self._generate_recommendations(risk_factors, safety_level)
        recommended_action = self._recommend_action(safety_level, importance_score)
        
        return RiskAssessment(
            backup_path=backup_path,
            backup_type=backup_type,
            importance_score=importance_score,
            safety_level=safety_level,
            confidence_score=confidence_score,
            risk_factors=risk_factors,
            concerns=concerns,
            recommendations=recommendations,
            recommended_action=recommended_action
        )
    
    def _classify_backup_type(self, backup_path: Path) -> BackupType:
        """Classify the type of backup file"""
        name = backup_path.name.lower()
        suffix = backup_path.suffix.lower()
        
        # Source code patterns
        source_extensions = {'.py', '.js', '.ts', '.java', '.cpp', '.c', '.h', '.rb', '.go', '.rs'}
        if any(ext in name for ext in source_extensions):
            return BackupType.SOURCE_CODE
        
        # Configuration patterns
        config_patterns = ['config', 'settings', 'env', '.conf', '.ini', '.yaml', '.yml', '.json', '.toml']
        if any(pattern in name for pattern in config_patterns):
            return BackupType.CONFIGURATION
        
        # Data file patterns
        data_extensions = {'.db', '.sql', '.csv', '.json', '.xml', '.log'}
        if suffix in data_extensions or 'database' in name or 'data' in name:
            return BackupType.DATA_FILE
        
        # Binary patterns
        binary_extensions = {'.exe', '.dll', '.so', '.dylib', '.bin', '.img', '.iso'}
        if suffix in binary_extensions:
            return BackupType.BINARY
        
        # Documentation patterns
        doc_extensions = {'.md', '.txt', '.rst', '.pdf', '.doc', '.docx'}
        if suffix in doc_extensions or 'readme' in name or 'doc' in name:
            return BackupType.DOCUMENTATION
        
        # Temporary patterns
        temp_patterns = ['tmp', 'temp', 'cache', '.swp', '.tmp']
        if any(pattern in name for pattern in temp_patterns):
            return BackupType.TEMPORARY
        
        return BackupType.UNKNOWN
    
    def _assess_file_type_importance(self, backup_path: Path, backup_type: BackupType) -> RiskFactor:
        """Assess importance based on file type"""
        type_importance = {
            BackupType.SOURCE_CODE: 0.9,
            BackupType.CONFIGURATION: 0.8,
            BackupType.DATA_FILE: 0.85,
            BackupType.BINARY: 0.6,
            BackupType.DOCUMENTATION: 0.4,
            BackupType.TEMPORARY: 0.1,
            BackupType.UNKNOWN: 0.5
        }
        
        base_score = type_importance[backup_type]
        evidence = [f"File type classified as: {backup_type.value}"]
        
        # Adjust based on specific patterns
        name = backup_path.name.lower()
        
        if 'critical' in name or 'important' in name:
            base_score += 0.1
            evidence.append("Contains 'critical' or 'important' in name")
        
        if 'test' in name or 'spec' in name:
            base_score += 0.05
            evidence.append("Test-related file")
        
        if 'production' in name or 'prod' in name:
            base_score += 0.15
            evidence.append("Production-related file")
        
        return RiskFactor(
            name="file_type_importance",
            weight=self.config["risk_assessment"]["importance_factors"]["file_type_weight"],
            score=min(1.0, base_score),
            description=f"Importance based on file type ({backup_type.value})",
            evidence=evidence
        )
    
    def _assess_recency_risk(self, backup_path: Path) -> RiskFactor:
        """Assess risk based on how recent the backup is"""
        try:
            stat_info = backup_path.stat()
            mod_time = datetime.fromtimestamp(stat_info.st_mtime)
            age = datetime.now() - mod_time
            age_hours = age.total_seconds() / 3600
            age_days = age_hours / 24
            
            thresholds = self.config["risk_assessment"]["backup_age_thresholds"]
            
            evidence = [f"Backup age: {age_days:.1f} days"]
            
            if age_hours < thresholds["fresh_hours"]:
                score = 1.0  # Very recent - high risk to delete
                evidence.append("Very fresh backup (< 24 hours)")
            elif age_days < thresholds["recent_days"]:
                score = 0.8  # Recent - moderate risk
                evidence.append("Recent backup (< 7 days)")
            elif age_days < thresholds["stable_days"]:
                score = 0.5  # Stable - low risk
                evidence.append("Stable backup (< 30 days)")
            elif age_days < thresholds["stale_days"]:
                score = 0.2  # Aging - very low risk
                evidence.append("Aging backup (< 90 days)")
            else:
                score = 0.1  # Stale - minimal risk
                evidence.append("Stale backup (> 90 days)")
            
            return RiskFactor(
                name="recency_risk",
                weight=self.config["risk_assessment"]["importance_factors"]["recency_weight"],
                score=score,
                description=f"Risk based on backup age ({age_days:.1f} days)",
                evidence=evidence
            )
            
        except Exception as e:
            return RiskFactor(
                name="recency_risk",
                weight=self.config["risk_assessment"]["importance_factors"]["recency_weight"],
                score=0.5,  # Neutral score on error
                description="Could not determine backup age",
                evidence=[f"Error accessing file stats: {e}"]
            )
    
    def _assess_reference_density(self, backup_path: Path, verification_results: Dict) -> RiskFactor:
        """Assess risk based on how often the backup is referenced"""
        reference_count = 0
        evidence = []
        
        # Check verification results for references
        if "reference_chain" in verification_results:
            ref_data = verification_results["reference_chain"].details
            
            # Count references to this specific backup
            backup_name = backup_path.name
            backup_stem = backup_path.stem
            
            for commit_ref in ref_data.get("commit_references", []):
                if isinstance(commit_ref, dict):
                    if "file" in commit_ref and backup_name in commit_ref["file"]:
                        reference_count += 1
                        evidence.append(f"Referenced in commit: {commit_ref.get('hash', 'unknown')}")
                    elif "message" in commit_ref and (backup_name in commit_ref["message"] or backup_stem in commit_ref["message"]):
                        reference_count += 1
                        evidence.append(f"Mentioned in commit message: {commit_ref.get('hash', 'unknown')}")
            
            for branch_ref in ref_data.get("branch_references", []):
                if isinstance(branch_ref, dict) and "name" in branch_ref:
                    if backup_name in branch_ref["name"] or backup_stem in branch_ref["name"]:
                        reference_count += 1
                        evidence.append(f"Referenced in branch: {branch_ref['name']}")
        
        # Check for direct file references in codebase
        if self.git_repo_root:
            try:
                # Search for references to the backup file
                result = subprocess.run([
                    "grep", "-r", "--include=*.py", "--include=*.js", "--include=*.ts",
                    "--include=*.md", "--include=*.txt", backup_path.name, str(self.git_repo_root)
                ], capture_output=True, text=True, check=False)
                
                if result.stdout:
                    file_references = len(result.stdout.strip().split('\n'))
                    reference_count += file_references
                    evidence.append(f"Found {file_references} direct file references")
                    
            except Exception as e:
                evidence.append(f"Could not search for file references: {e}")
        
        # Calculate score based on reference density
        if reference_count == 0:
            score = 0.1  # No references - very low risk to delete
            evidence.append("No references found")
        elif reference_count <= 2:
            score = 0.3  # Few references - low risk
            evidence.append(f"Low reference count: {reference_count}")
        elif reference_count <= 5:
            score = 0.6  # Moderate references - moderate risk
            evidence.append(f"Moderate reference count: {reference_count}")
        else:
            score = 0.9  # Many references - high risk to delete
            evidence.append(f"High reference count: {reference_count}")
        
        return RiskFactor(
            name="reference_density",
            weight=self.config["risk_assessment"]["importance_factors"]["reference_density_weight"],
            score=score,
            description=f"Risk based on reference density ({reference_count} references)",
            evidence=evidence
        )
    
    def _assess_uniqueness_risk(self, backup_path: Path) -> RiskFactor:
        """Assess risk based on whether this backup is unique or has duplicates"""
        evidence = []
        
        try:
            # Find similar backup files
            parent_dir = backup_path.parent
            backup_stem = backup_path.stem.split('.backup')[0]  # Remove backup suffix
            
            similar_files = []
            for file_path in parent_dir.rglob("*"):
                if file_path != backup_path and file_path.is_file():
                    if backup_stem in file_path.name or file_path.stem.split('.backup')[0] == backup_stem:
                        similar_files.append(file_path)
            
            evidence.append(f"Found {len(similar_files)} similar files")
            
            # Check for exact duplicates by content
            exact_duplicates = 0
            if backup_path.exists() and backup_path.is_file():
                try:
                    backup_hash = self._calculate_file_hash(backup_path)
                    
                    for similar_file in similar_files:
                        if similar_file.is_file():
                            similar_hash = self._calculate_file_hash(similar_file)
                            if backup_hash == similar_hash:
                                exact_duplicates += 1
                                evidence.append(f"Exact duplicate: {similar_file.name}")
                except Exception as e:
                    evidence.append(f"Could not calculate content hashes: {e}")
            
            # Calculate uniqueness score
            if exact_duplicates > 0:
                score = 0.2  # Has exact duplicates - low risk to delete
                evidence.append(f"Has {exact_duplicates} exact duplicates")
            elif len(similar_files) > 2:
                score = 0.4  # Has many similar files - moderate-low risk
                evidence.append("Multiple similar files exist")
            elif len(similar_files) > 0:
                score = 0.6  # Has some similar files - moderate risk
                evidence.append("Some similar files exist")
            else:
                score = 0.9  # Unique file - high risk to delete
                evidence.append("Appears to be unique")
            
            return RiskFactor(
                name="uniqueness_risk",
                weight=self.config["risk_assessment"]["importance_factors"]["uniqueness_weight"],
                score=score,
                description=f"Risk based on uniqueness ({exact_duplicates} duplicates, {len(similar_files)} similar)",
                evidence=evidence
            )
            
        except Exception as e:
            return RiskFactor(
                name="uniqueness_risk",
                weight=self.config["risk_assessment"]["importance_factors"]["uniqueness_weight"],
                score=0.5,  # Neutral score on error
                description="Could not assess uniqueness",
                evidence=[f"Error during uniqueness analysis: {e}"]
            )
    
    def _calculate_file_hash(self, file_path: Path) -> str:
        """Calculate SHA-256 hash of file content"""
        hash_sha256 = hashlib.sha256()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_sha256.update(chunk)
        return hash_sha256.hexdigest()
    
    def _assess_git_context_risk(self, backup_path: Path) -> RiskFactor:
        """Assess risk based on git context of the backup file"""
        evidence = []
        score = 0.5  # Default neutral score
        
        if not self.git_repo_root:
            evidence.append("Not in a git repository")
            return RiskFactor(
                name="git_context_risk",
                weight=0.1,  # Low weight if no git context
                score=score,
                description="No git context available",
                evidence=evidence
            )
        
        try:
            # Check if backup file is tracked by git
            relative_path = backup_path.relative_to(self.git_repo_root)
            
            # Check git status
            result = subprocess.run([
                "git", "ls-files", "--error-unmatch", str(relative_path)
            ], capture_output=True, text=True, check=False, cwd=self.git_repo_root)
            
            if result.returncode == 0:
                score += 0.3  # Tracked by git - higher risk
                evidence.append("File is tracked by git")
                
                # Check if file has modifications
                result = subprocess.run([
                    "git", "status", "--porcelain", str(relative_path)
                ], capture_output=True, text=True, check=False, cwd=self.git_repo_root)
                
                if result.stdout.strip():
                    score += 0.2  # Has modifications - even higher risk
                    evidence.append("File has git modifications")
            else:
                score -= 0.1  # Not tracked - lower risk
                evidence.append("File is not tracked by git")
            
            # Check git history
            result = subprocess.run([
                "git", "log", "--oneline", "-n", "5", "--", str(relative_path)
            ], capture_output=True, text=True, check=False, cwd=self.git_repo_root)
            
            if result.stdout.strip():
                commit_count = len(result.stdout.strip().split('\n'))
                score += min(0.3, commit_count * 0.05)  # More history = higher risk
                evidence.append(f"Has {commit_count} recent commits")
            else:
                evidence.append("No git history found")
            
        except Exception as e:
            evidence.append(f"Could not assess git context: {e}")
        
        return RiskFactor(
            name="git_context_risk",
            weight=0.15,
            score=min(1.0, max(0.0, score)),
            description="Risk based on git repository context",
            evidence=evidence
        )
    
    def _assess_content_risk(self, backup_path: Path) -> RiskFactor:
        """Assess risk based on backup file content analysis"""
        evidence = []
        score = 0.5  # Default neutral score
        
        try:
            if not backup_path.exists() or not backup_path.is_file():
                evidence.append("File does not exist or is not a regular file")
                return RiskFactor(
                    name="content_risk",
                    weight=0.1,
                    score=0.0,
                    description="Cannot analyze content",
                    evidence=evidence
                )
            
            file_size = backup_path.stat().st_size
            evidence.append(f"File size: {file_size} bytes")
            
            # Empty files are low risk
            if file_size == 0:
                score = 0.1
                evidence.append("Empty file")
                return RiskFactor(
                    name="content_risk",
                    weight=0.1,
                    score=score,
                    description="Empty backup file",
                    evidence=evidence
                )
            
            # Very large files might be important
            if file_size > 10 * 1024 * 1024:  # 10MB
                score += 0.2
                evidence.append("Large file (>10MB)")
            
            # Try to analyze content for text files
            try:
                mime_type, _ = mimetypes.guess_type(str(backup_path))
                if mime_type and mime_type.startswith('text'):
                    with open(backup_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content_sample = f.read(1024)  # Read first 1KB
                    
                    # Look for important patterns
                    important_patterns = [
                        r'password|secret|key|token',
                        r'config|setting|environment',
                        r'database|connection|url',
                        r'api|endpoint|service',
                        r'class|function|def|import'
                    ]
                    
                    for pattern in important_patterns:
                        if re.search(pattern, content_sample, re.IGNORECASE):
                            score += 0.1
                            evidence.append(f"Contains {pattern.split('|')[0]}-related content")
                    
                    # Check for code patterns
                    code_patterns = ['{', '}', '(', ')', ';', '=', 'import', 'function', 'class']
                    code_indicators = sum(1 for pattern in code_patterns if pattern in content_sample)
                    
                    if code_indicators > 3:
                        score += 0.15
                        evidence.append("Contains code-like patterns")
                    
            except Exception as e:
                evidence.append(f"Could not analyze text content: {e}")
            
        except Exception as e:
            evidence.append(f"Content analysis error: {e}")
        
        return RiskFactor(
            name="content_risk",
            weight=0.15,
            score=min(1.0, max(0.0, score)),
            description="Risk based on file content analysis",
            evidence=evidence
        )
    
    def _calculate_importance_score(self, risk_factors: List[RiskFactor]) -> float:
        """Calculate overall importance score from risk factors"""
        weighted_sum = 0.0
        total_weight = 0.0
        
        for factor in risk_factors:
            weighted_sum += factor.score * factor.weight
            total_weight += factor.weight
        
        if total_weight == 0:
            return 0.5  # Neutral score
        
        return weighted_sum / total_weight
    
    def _calculate_confidence_score(self, risk_factors: List[RiskFactor], verification_results: Dict) -> float:
        """Calculate confidence score for the assessment"""
        base_confidence = 0.8
        
        # Reduce confidence if we have limited information
        evidence_count = sum(len(factor.evidence) for factor in risk_factors)
        if evidence_count < 5:
            base_confidence -= 0.2
        
        # Adjust based on verification results
        if verification_results:
            for result in verification_results.values():
                if hasattr(result, 'confidence'):
                    base_confidence = min(base_confidence, result.confidence)
        
        # Reduce confidence for unknown backup types
        backup_type_factor = next((f for f in risk_factors if f.name == "file_type_importance"), None)
        if backup_type_factor and "unknown" in backup_type_factor.description.lower():
            base_confidence -= 0.1
        
        return max(0.1, min(1.0, base_confidence))
    
    def _determine_safety_level(self, importance_score: float, confidence_score: float) -> SafetyLevel:
        """Determine safety level based on importance and confidence scores"""
        thresholds = self.config["risk_assessment"]["safety_thresholds"]
        
        # Combine importance and confidence to get effective risk score
        # High importance or low confidence both increase risk
        risk_score = importance_score + (1.0 - confidence_score) * 0.3
        
        if risk_score >= thresholds["safe_level"]:
            return SafetyLevel.RISKY
        elif risk_score >= thresholds["cautious_level"]:
            return SafetyLevel.CAUTIOUS
        else:
            return SafetyLevel.SAFE
    
    def _generate_concerns(self, risk_factors: List[RiskFactor], safety_level: SafetyLevel) -> List[str]:
        """Generate list of concerns based on risk assessment"""
        concerns = []
        
        for factor in risk_factors:
            if factor.score > 0.7:
                concerns.append(f"High {factor.name}: {factor.description}")
        
        if safety_level == SafetyLevel.RISKY:
            concerns.append("Overall assessment indicates high risk for cleanup")
        elif safety_level == SafetyLevel.CAUTIOUS:
            concerns.append("Moderate risk factors present - user confirmation recommended")
        
        return concerns
    
    def _generate_recommendations(self, risk_factors: List[RiskFactor], safety_level: SafetyLevel) -> List[str]:
        """Generate recommendations based on risk assessment"""
        recommendations = []
        
        if safety_level == SafetyLevel.SAFE:
            recommendations.append("Safe for automatic cleanup")
            recommendations.append("Create backup before deletion as precaution")
        
        elif safety_level == SafetyLevel.CAUTIOUS:
            recommendations.append("Request user confirmation before cleanup")
            recommendations.append("Provide detailed reasoning for cleanup decision")
            recommendations.append("Create recovery point before proceeding")
        
        else:  # RISKY
            recommendations.append("Manual review required before any action")
            recommendations.append("Consider preserving this backup")
            recommendations.append("If cleanup necessary, require explicit approval")
            recommendations.append("Ensure complete backup of original content")
        
        # Specific recommendations based on risk factors
        for factor in risk_factors:
            if factor.name == "recency_risk" and factor.score > 0.8:
                recommendations.append("Consider waiting longer before cleanup (file is very recent)")
            
            elif factor.name == "reference_density" and factor.score > 0.7:
                recommendations.append("Verify all references before cleanup")
            
            elif factor.name == "uniqueness_risk" and factor.score > 0.8:
                recommendations.append("Backup appears unique - extra caution advised")
        
        return recommendations
    
    def _recommend_action(self, safety_level: SafetyLevel, importance_score: float) -> str:
        """Recommend specific action based on assessment"""
        if safety_level == SafetyLevel.SAFE:
            return "auto_cleanup"
        elif safety_level == SafetyLevel.CAUTIOUS:
            if importance_score > 0.7:
                return "user_confirmation_detailed"
            else:
                return "user_confirmation_standard"
        else:  # RISKY
            return "manual_review_required"


async def main():
    """Example usage of the risk assessment engine"""
    from pathlib import Path
    
    engine = RiskAssessmentEngine()
    
    print("📊 Risk Assessment Engine")
    print("=" * 50)
    
    # Find some backup files to assess
    backup_files = []
    for pattern in ["*.backup.*", "*.bak", "*~"]:
        backup_files.extend(Path(".").rglob(pattern))
    
    if not backup_files:
        print("No backup files found for assessment")
        return
    
    # Mock verification results
    mock_verification = {
        "git_state": type('obj', (object,), {"confidence": 0.9}),
        "reference_chain": type('obj', (object,), {
            "confidence": 0.8,
            "details": {
                "commit_references": [],
                "branch_references": [],
                "reflog_references": []
            }
        })
    }
    
    for backup_file in backup_files[:3]:  # Assess first 3 files
        assessment = await engine.assess_backup_risk(backup_file, mock_verification)
        
        print(f"\n📁 {assessment.backup_path.name}")
        print(f"   Type: {assessment.backup_type.value}")
        print(f"   Importance: {assessment.importance_score:.2f}")
        print(f"   Confidence: {assessment.confidence_score:.2f}")
        print(f"   Safety Level: {assessment.safety_level.value.upper()}")
        print(f"   Action: {assessment.recommended_action}")
        
        if assessment.concerns:
            print("   Concerns:")
            for concern in assessment.concerns:
                print(f"     ⚠️  {concern}")
        
        if assessment.recommendations:
            print("   Recommendations:")
            for rec in assessment.recommendations:
                print(f"     💡 {rec}")


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())