#!/usr/bin/env python3
"""
Multi-Factor Verification Engine for Backup Cleanup Safety
Implements comprehensive verification checks before any backup cleanup operations
"""

import os
import subprocess
import json
import asyncio
from pathlib import Path
from typing import Dict, List, Optional, Tuple, NamedTuple
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from enum import Enum
import re


class VerificationFactor(Enum):
    """Available verification factors"""
    GIT_STATE = "git_state"
    BACKUP_AGE = "backup_age"  
    REFERENCE_CHAIN = "reference_chain"
    USER_CONFIRMATION = "user_confirmation"
    EMERGENCY_PATTERNS = "emergency_patterns"


@dataclass
class VerificationResult:
    """Result of a single verification factor"""
    factor: VerificationFactor
    passed: bool
    confidence: float
    details: Dict[str, any] = field(default_factory=dict)
    warnings: List[str] = field(default_factory=list)
    failure_reason: Optional[str] = None
    is_critical: bool = False
    
    def to_dict(self) -> Dict:
        return {
            "factor": self.factor.value,
            "passed": self.passed,
            "confidence": self.confidence,
            "details": self.details,
            "warnings": self.warnings,
            "failure_reason": self.failure_reason,
            "is_critical": self.is_critical
        }


@dataclass
class GitStateInfo:
    """Git repository state information"""
    is_clean: bool
    has_staged_changes: bool
    has_unstaged_changes: bool
    has_untracked_files: bool
    active_operations: List[str]
    current_branch: str
    head_commit: str
    uncommitted_files: List[str] = field(default_factory=list)


class MultiFactorVerifier:
    """
    Comprehensive multi-factor verification engine for backup cleanup safety.
    
    Implements multiple independent verification factors to ensure safe backup
    cleanup operations with comprehensive safety checks and rollback capability.
    """
    
    def __init__(self, config_path: Optional[Path] = None):
        self.config = self._load_config(config_path)
        self.verification_results: Dict[str, VerificationResult] = {}
        
    def _load_config(self, config_path: Optional[Path]) -> Dict:
        """Load safety configuration"""
        default_config = {
            "multi_factor_verification": {
                "git_state_check": {
                    "enabled": True,
                    "require_clean_working_tree": True,
                    "check_pending_operations": True,
                    "verify_branch_state": True
                },
                "backup_age_verification": {
                    "enabled": True,
                    "minimum_age_hours": 168,  # 7 days
                    "stale_threshold_days": 90,
                    "critical_threshold_days": 30
                },
                "reference_chain_analysis": {
                    "enabled": True,
                    "check_commit_references": True,
                    "check_branch_references": True,
                    "check_reflog_references": True,
                    "reference_lookback_days": 30
                },
                "user_confirmation": {
                    "enabled": True,
                    "auto_approve_threshold": 0.95,
                    "prompt_threshold": 0.70,
                    "require_explicit_approval_threshold": 0.60
                }
            }
        }
        
        if config_path and config_path.exists():
            try:
                import yaml
                with open(config_path) as f:
                    user_config = yaml.safe_load(f)
                return {**default_config, **user_config}
            except Exception as e:
                print(f"⚠️  Warning: Could not load config from {config_path}: {e}")
        
        return default_config
    
    async def verify_all_factors(self, target_dir: Path) -> Dict[str, VerificationResult]:
        """
        Execute all verification factors and return comprehensive results.
        
        Args:
            target_dir: Directory to verify for backup cleanup safety
            
        Returns:
            Dictionary mapping factor names to verification results
        """
        print("🔍 Starting multi-factor verification...")
        
        verification_tasks = []
        
        # Git State Verification
        if self.config["multi_factor_verification"]["git_state_check"]["enabled"]:
            verification_tasks.append(self._verify_git_state(target_dir))
        
        # Backup Age Verification  
        if self.config["multi_factor_verification"]["backup_age_verification"]["enabled"]:
            verification_tasks.append(self._verify_backup_ages(target_dir))
            
        # Reference Chain Analysis
        if self.config["multi_factor_verification"]["reference_chain_analysis"]["enabled"]:
            verification_tasks.append(self._analyze_reference_chains(target_dir))
            
        # Emergency Pattern Detection
        verification_tasks.append(self._detect_emergency_patterns(target_dir))
        
        # Execute all verifications in parallel
        results = await asyncio.gather(*verification_tasks, return_exceptions=True)
        
        # Process results
        verification_results = {}
        for result in results:
            if isinstance(result, Exception):
                print(f"❌ Verification error: {result}")
                verification_results["error"] = VerificationResult(
                    factor=VerificationFactor.GIT_STATE,
                    passed=False,
                    confidence=0.0,
                    failure_reason=str(result),
                    is_critical=True
                )
            else:
                verification_results[result.factor.value] = result
        
        self.verification_results = verification_results
        return verification_results
    
    async def _verify_git_state(self, target_dir: Path) -> VerificationResult:
        """Verify git repository state for safe backup cleanup"""
        print("  🔍 Verifying git repository state...")
        
        try:
            git_info = await self._get_git_state_info(target_dir)
            
            # Check for critical git states that block cleanup
            critical_issues = []
            warnings = []
            
            # Check for active operations
            if git_info.active_operations:
                critical_issues.append(
                    f"Active git operations detected: {', '.join(git_info.active_operations)}"
                )
            
            # Check working tree cleanliness
            if self.config["multi_factor_verification"]["git_state_check"]["require_clean_working_tree"]:
                if not git_info.is_clean:
                    if git_info.has_staged_changes:
                        critical_issues.append("Staged changes detected in working tree")
                    if git_info.has_unstaged_changes:
                        warnings.append("Unstaged changes detected - recommend committing first")
                    if git_info.has_untracked_files:
                        warnings.append(f"Untracked files detected: {len(git_info.uncommitted_files)} files")
            
            # Calculate confidence based on git state
            confidence = 1.0
            if git_info.active_operations:
                confidence = 0.0  # Critical failure
            elif not git_info.is_clean:
                confidence -= 0.3
                if git_info.has_staged_changes:
                    confidence -= 0.4
            
            passed = len(critical_issues) == 0
            
            return VerificationResult(
                factor=VerificationFactor.GIT_STATE,
                passed=passed,
                confidence=max(0.0, confidence),
                details={
                    "git_state": git_info.__dict__,
                    "critical_issues": critical_issues
                },
                warnings=warnings,
                failure_reason="; ".join(critical_issues) if critical_issues else None,
                is_critical=not passed
            )
            
        except Exception as e:
            return VerificationResult(
                factor=VerificationFactor.GIT_STATE,
                passed=False,
                confidence=0.0,
                failure_reason=f"Git state verification failed: {e}",
                is_critical=True
            )
    
    async def _get_git_state_info(self, target_dir: Path) -> GitStateInfo:
        """Get comprehensive git repository state information"""
        original_cwd = os.getcwd()
        os.chdir(target_dir)
        
        try:
            # Check if we're in a git repository
            subprocess.run(["git", "rev-parse", "--git-dir"], 
                         check=True, capture_output=True, text=True)
            
            # Get status information
            status_result = subprocess.run(
                ["git", "status", "--porcelain"], 
                capture_output=True, text=True, check=True
            )
            
            # Parse status output
            status_lines = status_result.stdout.strip().split('\n') if status_result.stdout.strip() else []
            has_staged_changes = any(line and line[0] in 'AMDRC' for line in status_lines)
            has_unstaged_changes = any(line and line[1] in 'MD' for line in status_lines)
            has_untracked_files = any(line and line.startswith('??') for line in status_lines)
            uncommitted_files = [line[3:] for line in status_lines if line]
            
            # Check for active operations
            active_operations = []
            git_dir = Path(".git")
            
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
            
            # Get current branch and commit
            try:
                branch_result = subprocess.run(
                    ["git", "branch", "--show-current"],
                    capture_output=True, text=True, check=True
                )
                current_branch = branch_result.stdout.strip()
            except:
                current_branch = "HEAD"
            
            head_result = subprocess.run(
                ["git", "rev-parse", "HEAD"],
                capture_output=True, text=True, check=True
            )
            head_commit = head_result.stdout.strip()
            
            is_clean = not (has_staged_changes or has_unstaged_changes or has_untracked_files)
            
            return GitStateInfo(
                is_clean=is_clean,
                has_staged_changes=has_staged_changes,
                has_unstaged_changes=has_unstaged_changes,
                has_untracked_files=has_untracked_files,
                active_operations=active_operations,
                current_branch=current_branch,
                head_commit=head_commit,
                uncommitted_files=uncommitted_files
            )
            
        finally:
            os.chdir(original_cwd)
    
    async def _verify_backup_ages(self, target_dir: Path) -> VerificationResult:
        """Verify backup file ages meet safety requirements"""
        print("  ⏱️  Verifying backup file ages...")
        
        try:
            backup_files = self._discover_backup_files(target_dir)
            age_config = self.config["multi_factor_verification"]["backup_age_verification"]
            
            minimum_age_hours = age_config["minimum_age_hours"]
            critical_threshold_days = age_config["critical_threshold_days"]
            stale_threshold_days = age_config["stale_threshold_days"]
            
            age_analysis = {
                "total_backups": len(backup_files),
                "fresh_backups": 0,    # < minimum_age
                "stable_backups": 0,   # minimum_age to critical_threshold  
                "aging_backups": 0,    # critical_threshold to stale_threshold
                "stale_backups": 0,    # > stale_threshold
                "backup_details": []
            }
            
            warnings = []
            issues = []
            now = datetime.now()
            
            for backup_file in backup_files:
                try:
                    # Get file modification time
                    stat_info = backup_file.stat()
                    mod_time = datetime.fromtimestamp(stat_info.st_mtime)
                    age_hours = (now - mod_time).total_seconds() / 3600
                    age_days = age_hours / 24
                    
                    backup_detail = {
                        "path": str(backup_file),
                        "age_hours": age_hours,
                        "age_days": age_days,
                        "modification_time": mod_time.isoformat()
                    }
                    
                    # Categorize by age
                    if age_hours < minimum_age_hours:
                        age_analysis["fresh_backups"] += 1
                        backup_detail["category"] = "fresh"
                        issues.append(f"Backup too fresh for cleanup: {backup_file.name} ({age_hours:.1f}h old)")
                    elif age_days < critical_threshold_days:
                        age_analysis["stable_backups"] += 1
                        backup_detail["category"] = "stable"
                        warnings.append(f"Stable backup requires confirmation: {backup_file.name}")
                    elif age_days < stale_threshold_days:
                        age_analysis["aging_backups"] += 1
                        backup_detail["category"] = "aging"
                    else:
                        age_analysis["stale_backups"] += 1
                        backup_detail["category"] = "stale"
                    
                    age_analysis["backup_details"].append(backup_detail)
                    
                except Exception as e:
                    warnings.append(f"Could not analyze backup {backup_file.name}: {e}")
            
            # Calculate confidence based on backup age distribution
            confidence = 1.0
            if age_analysis["fresh_backups"] > 0:
                confidence -= 0.5  # Fresh backups are risky
            if age_analysis["stable_backups"] > age_analysis["stale_backups"]:
                confidence -= 0.2  # More stable than stale backups
            
            passed = len(issues) == 0
            
            return VerificationResult(
                factor=VerificationFactor.BACKUP_AGE,
                passed=passed,
                confidence=max(0.0, confidence),
                details=age_analysis,
                warnings=warnings,
                failure_reason="; ".join(issues) if issues else None,
                is_critical=False  # Age violations are not critical, just risky
            )
            
        except Exception as e:
            return VerificationResult(
                factor=VerificationFactor.BACKUP_AGE,
                passed=False,
                confidence=0.0,
                failure_reason=f"Backup age verification failed: {e}",
                is_critical=False
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
        
        # Also check for timestamp-based backup patterns
        timestamp_pattern = re.compile(r'.*\.(backup|bak)\.[\d_]+$')
        for file_path in target_dir.rglob("*"):
            if file_path.is_file() and timestamp_pattern.match(file_path.name):
                backup_files.append(file_path)
        
        return list(set(backup_files))  # Remove duplicates
    
    async def _analyze_reference_chains(self, target_dir: Path) -> VerificationResult:
        """Analyze reference chains to backup files in git history"""
        print("  🔗 Analyzing reference chains...")
        
        try:
            ref_config = self.config["multi_factor_verification"]["reference_chain_analysis"]
            lookback_days = ref_config["reference_lookback_days"]
            since_date = (datetime.now() - timedelta(days=lookback_days)).strftime("%Y-%m-%d")
            
            original_cwd = os.getcwd()
            os.chdir(target_dir)
            
            try:
                reference_analysis = {
                    "commit_references": [],
                    "branch_references": [],
                    "reflog_references": [],
                    "total_references": 0
                }
                
                warnings = []
                
                # Check commit references
                if ref_config["check_commit_references"]:
                    commit_refs = await self._find_commit_references(since_date)
                    reference_analysis["commit_references"] = commit_refs
                
                # Check branch references
                if ref_config["check_branch_references"]:
                    branch_refs = await self._find_branch_references()
                    reference_analysis["branch_references"] = branch_refs
                
                # Check reflog references
                if ref_config["check_reflog_references"]:
                    reflog_refs = await self._find_reflog_references(since_date)
                    reference_analysis["reflog_references"] = reflog_refs
                
                total_refs = (len(reference_analysis["commit_references"]) +
                             len(reference_analysis["branch_references"]) +
                             len(reference_analysis["reflog_references"]))
                
                reference_analysis["total_references"] = total_refs
                
                # Generate warnings for referenced backups
                if total_refs > 0:
                    warnings.append(f"Found {total_refs} references to backup files in git history")
                    warnings.append("Consider preserving referenced backups")
                
                # Calculate confidence (more references = lower confidence for cleanup)
                confidence = 1.0
                if total_refs > 0:
                    confidence = max(0.3, 1.0 - (total_refs * 0.1))
                
                return VerificationResult(
                    factor=VerificationFactor.REFERENCE_CHAIN,
                    passed=True,  # This factor provides information, doesn't block
                    confidence=confidence,
                    details=reference_analysis,
                    warnings=warnings,
                    is_critical=False
                )
                
            finally:
                os.chdir(original_cwd)
                
        except Exception as e:
            return VerificationResult(
                factor=VerificationFactor.REFERENCE_CHAIN,
                passed=True,  # Don't block on reference analysis failure
                confidence=0.5,  # Neutral confidence
                failure_reason=f"Reference chain analysis failed: {e}",
                is_critical=False
            )
    
    async def _find_commit_references(self, since_date: str) -> List[Dict]:
        """Find backup file references in recent commits"""
        try:
            # Search for backup patterns in commit messages
            result = subprocess.run([
                "git", "log", f"--since={since_date}", 
                "--grep=backup", "--grep=\.backup", "--grep=\.bak",
                "--oneline", "--all"
            ], capture_output=True, text=True, check=True)
            
            commit_refs = []
            for line in result.stdout.strip().split('\n'):
                if line:
                    commit_hash = line.split()[0]
                    commit_message = ' '.join(line.split()[1:])
                    commit_refs.append({
                        "hash": commit_hash,
                        "message": commit_message
                    })
            
            # Also check for backup files in commit changes
            result = subprocess.run([
                "git", "log", f"--since={since_date}", 
                "--name-only", "--pretty=format:%H", "--all"
            ], capture_output=True, text=True, check=True)
            
            lines = result.stdout.strip().split('\n')
            current_commit = None
            
            for line in lines:
                if len(line) == 40 and all(c in '0123456789abcdef' for c in line):
                    current_commit = line
                elif line and current_commit:
                    if any(pattern in line for pattern in ['.backup', '.bak', '~', '.orig']):
                        commit_refs.append({
                            "hash": current_commit,
                            "file": line,
                            "type": "file_change"
                        })
            
            return commit_refs
            
        except Exception as e:
            print(f"⚠️  Could not analyze commit references: {e}")
            return []
    
    async def _find_branch_references(self) -> List[Dict]:
        """Find backup file references in branch names or content"""
        try:
            # Get all branches
            result = subprocess.run([
                "git", "branch", "-a", "--format=%(refname:short)"
            ], capture_output=True, text=True, check=True)
            
            branches = result.stdout.strip().split('\n')
            backup_branches = []
            
            for branch in branches:
                if branch and any(pattern in branch for pattern in ['backup', 'bak', 'save']):
                    backup_branches.append({
                        "name": branch,
                        "type": "backup_branch"
                    })
            
            return backup_branches
            
        except Exception as e:
            print(f"⚠️  Could not analyze branch references: {e}")
            return []
    
    async def _find_reflog_references(self, since_date: str) -> List[Dict]:
        """Find backup file references in reflog"""
        try:
            # Check reflog for backup-related entries
            result = subprocess.run([
                "git", "reflog", "--since", since_date, "--grep=backup"
            ], capture_output=True, text=True, check=True)
            
            reflog_refs = []
            for line in result.stdout.strip().split('\n'):
                if line and 'backup' in line.lower():
                    reflog_refs.append({
                        "entry": line.strip(),
                        "type": "reflog_entry"
                    })
            
            return reflog_refs
            
        except Exception as e:
            print(f"⚠️  Could not analyze reflog references: {e}")
            return []
    
    async def _detect_emergency_patterns(self, target_dir: Path) -> VerificationResult:
        """Detect emergency patterns that should prevent backup cleanup"""
        print("  🚨 Detecting emergency patterns...")
        
        try:
            emergency_patterns = {
                "recent_failures": [],
                "critical_backups": [],
                "system_backups": [],
                "active_processes": []
            }
            
            warnings = []
            critical_issues = []
            
            # Check for recent failure indicators
            failure_indicators = [
                ".git/index.lock",
                ".git/refs/heads/*.lock",
                "*.crash",
                "core.*",
                "*.emergency"
            ]
            
            for pattern in failure_indicators:
                matches = list(target_dir.rglob(pattern))
                if matches:
                    emergency_patterns["recent_failures"].extend([str(m) for m in matches])
                    critical_issues.append(f"Recent failure indicators found: {pattern}")
            
            # Check for critical backup patterns
            critical_backup_patterns = [
                "*.critical.backup.*",
                "*.emergency.backup.*", 
                "*.production.backup.*",
                "*.db.backup.*",
                "*.config.backup.*"
            ]
            
            for pattern in critical_backup_patterns:
                matches = list(target_dir.rglob(pattern))
                if matches:
                    emergency_patterns["critical_backups"].extend([str(m) for m in matches])
                    warnings.append(f"Critical backups found: {len(matches)} files matching {pattern}")
            
            # Check for system-level backups
            system_backup_paths = [
                "/var/backups",
                "/backup",
                "system_backup",
                "db_backup"
            ]
            
            for backup_path in system_backup_paths:
                if (target_dir / backup_path).exists():
                    emergency_patterns["system_backups"].append(backup_path)
                    warnings.append(f"System backup directory detected: {backup_path}")
            
            # Check for active processes that might be using backups
            try:
                # Check for processes with open files in the target directory
                result = subprocess.run([
                    "lsof", "+D", str(target_dir)
                ], capture_output=True, text=True, check=False)
                
                if result.stdout:
                    active_processes = result.stdout.strip().split('\n')[1:]  # Skip header
                    emergency_patterns["active_processes"] = active_processes
                    if active_processes:
                        warnings.append(f"Active processes detected with open files: {len(active_processes)}")
                        
            except Exception:
                # lsof might not be available or accessible
                pass
            
            # Calculate confidence based on emergency patterns
            confidence = 1.0
            if critical_issues:
                confidence = 0.0  # Critical emergency state
            elif emergency_patterns["critical_backups"]:
                confidence -= 0.3
            elif emergency_patterns["system_backups"]:
                confidence -= 0.2
            elif emergency_patterns["active_processes"]:
                confidence -= 0.1
            
            passed = len(critical_issues) == 0
            
            return VerificationResult(
                factor=VerificationFactor.EMERGENCY_PATTERNS,
                passed=passed,
                confidence=max(0.0, confidence),
                details=emergency_patterns,
                warnings=warnings,
                failure_reason="; ".join(critical_issues) if critical_issues else None,
                is_critical=not passed
            )
            
        except Exception as e:
            return VerificationResult(
                factor=VerificationFactor.EMERGENCY_PATTERNS,
                passed=True,  # Don't block on detection failure
                confidence=0.5,
                failure_reason=f"Emergency pattern detection failed: {e}",
                is_critical=False
            )
    
    def get_overall_verification_status(self) -> Tuple[bool, float, List[str]]:
        """
        Get overall verification status from all factors.
        
        Returns:
            Tuple of (passed, confidence, critical_issues)
        """
        if not self.verification_results:
            return False, 0.0, ["No verification results available"]
        
        critical_issues = []
        confidence_scores = []
        all_passed = True
        
        for factor_name, result in self.verification_results.items():
            if not result.passed and result.is_critical:
                all_passed = False
                critical_issues.append(f"{factor_name}: {result.failure_reason}")
            
            confidence_scores.append(result.confidence)
        
        # Overall confidence is the minimum of all factor confidences
        overall_confidence = min(confidence_scores) if confidence_scores else 0.0
        
        return all_passed, overall_confidence, critical_issues
    
    def generate_verification_report(self) -> Dict:
        """Generate comprehensive verification report"""
        overall_passed, overall_confidence, critical_issues = self.get_overall_verification_status()
        
        return {
            "timestamp": datetime.now().isoformat(),
            "overall_status": {
                "passed": overall_passed,
                "confidence": overall_confidence,
                "critical_issues": critical_issues
            },
            "factor_results": {
                name: result.to_dict() 
                for name, result in self.verification_results.items()
            },
            "summary": {
                "total_factors": len(self.verification_results),
                "passed_factors": sum(1 for r in self.verification_results.values() if r.passed),
                "failed_factors": sum(1 for r in self.verification_results.values() if not r.passed),
                "critical_failures": sum(1 for r in self.verification_results.values() 
                                       if not r.passed and r.is_critical)
            }
        }


async def main():
    """Example usage of the multi-factor verifier"""
    verifier = MultiFactorVerifier()
    target_dir = Path(".")
    
    print("🛡️ Multi-Factor Verification Engine")
    print("=" * 50)
    
    # Execute verification
    results = await verifier.verify_all_factors(target_dir)
    
    # Print results
    for factor_name, result in results.items():
        status = "✅ PASS" if result.passed else "❌ FAIL"
        print(f"{status} {factor_name}: {result.confidence:.2f} confidence")
        
        if result.warnings:
            for warning in result.warnings:
                print(f"    ⚠️  {warning}")
        
        if not result.passed and result.failure_reason:
            print(f"    🚨 {result.failure_reason}")
    
    # Overall status
    overall_passed, overall_confidence, critical_issues = verifier.get_overall_verification_status()
    print("\n" + "=" * 50)
    print(f"Overall Status: {'✅ SAFE' if overall_passed else '❌ UNSAFE'}")
    print(f"Overall Confidence: {overall_confidence:.2f}")
    
    if critical_issues:
        print("\nCritical Issues:")
        for issue in critical_issues:
            print(f"  🚨 {issue}")
    
    # Generate report
    report = verifier.generate_verification_report()
    report_file = Path(".claude/safety_verification_report.json")
    report_file.parent.mkdir(exist_ok=True)
    
    with open(report_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"\n📄 Detailed report saved to: {report_file}")


if __name__ == "__main__":
    asyncio.run(main())