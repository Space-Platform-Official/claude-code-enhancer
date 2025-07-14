#!/usr/bin/env python3
"""
Rollback Coordinator for Backup Cleanup Operations
Provides comprehensive rollback and recovery coordination with atomic operations
"""

import os
import json
import shutil
import tarfile
import hashlib
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Set
from dataclasses import dataclass, field, asdict
from datetime import datetime, timedelta
from enum import Enum
import threading
import tempfile


class RecoveryPointType(Enum):
    """Types of recovery points"""
    FULL_SNAPSHOT = "full_snapshot"
    INCREMENTAL = "incremental"
    METADATA_ONLY = "metadata_only"
    GIT_STATE = "git_state"


class OperationStatus(Enum):
    """Status of rollback operations"""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"
    ROLLED_BACK = "rolled_back"


@dataclass
class RecoveryPoint:
    """A point-in-time recovery snapshot"""
    id: str
    timestamp: datetime
    type: RecoveryPointType
    description: str
    metadata_path: Path
    backup_path: Optional[Path] = None
    git_state: Optional[Dict[str, str]] = None
    file_inventory: List[str] = field(default_factory=list)
    checksum: Optional[str] = None
    size_bytes: int = 0
    is_valid: bool = True
    
    def to_dict(self) -> Dict:
        return {
            "id": self.id,
            "timestamp": self.timestamp.isoformat(),
            "type": self.type.value,
            "description": self.description,
            "metadata_path": str(self.metadata_path),
            "backup_path": str(self.backup_path) if self.backup_path else None,
            "git_state": self.git_state,
            "file_inventory": self.file_inventory,
            "checksum": self.checksum,
            "size_bytes": self.size_bytes,
            "is_valid": self.is_valid
        }
    
    @classmethod
    def from_dict(cls, data: Dict) -> 'RecoveryPoint':
        return cls(
            id=data["id"],
            timestamp=datetime.fromisoformat(data["timestamp"]),
            type=RecoveryPointType(data["type"]),
            description=data["description"],
            metadata_path=Path(data["metadata_path"]),
            backup_path=Path(data["backup_path"]) if data.get("backup_path") else None,
            git_state=data.get("git_state"),
            file_inventory=data.get("file_inventory", []),
            checksum=data.get("checksum"),
            size_bytes=data.get("size_bytes", 0),
            is_valid=data.get("is_valid", True)
        )


@dataclass
class CleanupOperation:
    """A tracked cleanup operation"""
    id: str
    timestamp: datetime
    status: OperationStatus
    files_processed: List[str] = field(default_factory=list)
    files_deleted: List[str] = field(default_factory=list)
    recovery_point_id: Optional[str] = None
    error_message: Optional[str] = None
    rollback_point_id: Optional[str] = None
    
    def to_dict(self) -> Dict:
        return {
            "id": self.id,
            "timestamp": self.timestamp.isoformat(),
            "status": self.status.value,
            "files_processed": self.files_processed,
            "files_deleted": self.files_deleted,
            "recovery_point_id": self.recovery_point_id,
            "error_message": self.error_message,
            "rollback_point_id": self.rollback_point_id
        }


class RollbackCoordinator:
    """
    Comprehensive rollback and recovery coordination system.
    
    Provides atomic operations with complete rollback capability,
    emergency stop mechanisms, and comprehensive audit trails.
    """
    
    def __init__(self, recovery_dir: Optional[Path] = None):
        self.recovery_dir = recovery_dir or Path(".claude/recovery")
        self.recovery_dir.mkdir(parents=True, exist_ok=True)
        
        self.operations_dir = self.recovery_dir / "operations"
        self.operations_dir.mkdir(exist_ok=True)
        
        self.snapshots_dir = self.recovery_dir / "snapshots"
        self.snapshots_dir.mkdir(exist_ok=True)
        
        self.metadata_file = self.recovery_dir / "recovery_metadata.json"
        
        self.recovery_points: Dict[str, RecoveryPoint] = {}
        self.operations: Dict[str, CleanupOperation] = {}
        
        self._load_metadata()
        self._cleanup_old_recovery_points()
    
    def _load_metadata(self):
        """Load existing recovery metadata"""
        if self.metadata_file.exists():
            try:
                with open(self.metadata_file, 'r') as f:
                    data = json.load(f)
                
                # Load recovery points
                for rp_data in data.get("recovery_points", []):
                    rp = RecoveryPoint.from_dict(rp_data)
                    self.recovery_points[rp.id] = rp
                
                # Load operations
                for op_data in data.get("operations", []):
                    op = CleanupOperation(
                        id=op_data["id"],
                        timestamp=datetime.fromisoformat(op_data["timestamp"]),
                        status=OperationStatus(op_data["status"]),
                        files_processed=op_data.get("files_processed", []),
                        files_deleted=op_data.get("files_deleted", []),
                        recovery_point_id=op_data.get("recovery_point_id"),
                        error_message=op_data.get("error_message"),
                        rollback_point_id=op_data.get("rollback_point_id")
                    )
                    self.operations[op.id] = op
                    
            except Exception as e:
                print(f"⚠️  Could not load recovery metadata: {e}")
    
    def _save_metadata(self):
        """Save recovery metadata to disk"""
        try:
            data = {
                "recovery_points": [rp.to_dict() for rp in self.recovery_points.values()],
                "operations": [op.to_dict() for op in self.operations.values()],
                "last_updated": datetime.now().isoformat()
            }
            
            # Atomic write
            temp_file = self.metadata_file.with_suffix('.tmp')
            with open(temp_file, 'w') as f:
                json.dump(data, f, indent=2)
            
            temp_file.replace(self.metadata_file)
            
        except Exception as e:
            print(f"❌ Could not save recovery metadata: {e}")
    
    def _cleanup_old_recovery_points(self, retention_days: int = 30):
        """Clean up old recovery points beyond retention period"""
        cutoff_date = datetime.now() - timedelta(days=retention_days)
        
        expired_points = [
            rp_id for rp_id, rp in self.recovery_points.items()
            if rp.timestamp < cutoff_date
        ]
        
        for rp_id in expired_points:
            try:
                self._remove_recovery_point(rp_id)
                print(f"🗑️  Cleaned up expired recovery point: {rp_id}")
            except Exception as e:
                print(f"⚠️  Could not clean up recovery point {rp_id}: {e}")
    
    def create_recovery_point(
        self,
        description: str,
        point_type: RecoveryPointType = RecoveryPointType.FULL_SNAPSHOT,
        include_git_state: bool = True
    ) -> str:
        """
        Create a comprehensive recovery point.
        
        Args:
            description: Description of the recovery point
            point_type: Type of recovery point to create
            include_git_state: Whether to capture git state
            
        Returns:
            Recovery point ID
        """
        timestamp = datetime.now()
        rp_id = f"rp_{timestamp.strftime('%Y%m%d_%H%M%S')}_{hash(description) % 10000:04d}"
        
        print(f"📸 Creating recovery point: {rp_id}")
        
        try:
            # Create recovery point directory
            rp_dir = self.snapshots_dir / rp_id
            rp_dir.mkdir(exist_ok=True)
            
            # Initialize recovery point
            recovery_point = RecoveryPoint(
                id=rp_id,
                timestamp=timestamp,
                type=point_type,
                description=description,
                metadata_path=rp_dir / "metadata.json"
            )
            
            # Capture git state if requested
            if include_git_state:
                recovery_point.git_state = self._capture_git_state()
            
            # Create snapshot based on type
            if point_type == RecoveryPointType.FULL_SNAPSHOT:
                recovery_point.backup_path = self._create_full_snapshot(rp_dir)
                recovery_point.file_inventory = self._create_file_inventory()
            elif point_type == RecoveryPointType.INCREMENTAL:
                recovery_point.backup_path = self._create_incremental_snapshot(rp_dir)
                recovery_point.file_inventory = self._create_file_inventory()
            elif point_type == RecoveryPointType.METADATA_ONLY:
                recovery_point.file_inventory = self._create_file_inventory()
            
            # Calculate checksum
            recovery_point.checksum = self._calculate_recovery_point_checksum(recovery_point)
            
            # Calculate size
            if recovery_point.backup_path and recovery_point.backup_path.exists():
                recovery_point.size_bytes = recovery_point.backup_path.stat().st_size
            
            # Save metadata
            with open(recovery_point.metadata_path, 'w') as f:
                json.dump(recovery_point.to_dict(), f, indent=2)
            
            # Store recovery point
            self.recovery_points[rp_id] = recovery_point
            self._save_metadata()
            
            print(f"✅ Recovery point created: {rp_id}")
            return rp_id
            
        except Exception as e:
            print(f"❌ Failed to create recovery point: {e}")
            # Clean up partial recovery point
            rp_dir = self.snapshots_dir / rp_id
            if rp_dir.exists():
                shutil.rmtree(rp_dir, ignore_errors=True)
            raise
    
    def _capture_git_state(self) -> Dict[str, str]:
        """Capture current git repository state"""
        git_state = {}
        
        try:
            # Current HEAD
            result = subprocess.run([
                "git", "rev-parse", "HEAD"
            ], capture_output=True, text=True, check=True)
            git_state["head"] = result.stdout.strip()
            
            # Current branch
            result = subprocess.run([
                "git", "branch", "--show-current"
            ], capture_output=True, text=True, check=False)
            git_state["branch"] = result.stdout.strip() if result.returncode == 0 else "HEAD"
            
            # Working tree status
            result = subprocess.run([
                "git", "status", "--porcelain"
            ], capture_output=True, text=True, check=True)
            git_state["working_tree_status"] = result.stdout
            
            # Stash list
            result = subprocess.run([
                "git", "stash", "list"
            ], capture_output=True, text=True, check=False)
            git_state["stash_list"] = result.stdout
            
        except Exception as e:
            print(f"⚠️  Could not capture complete git state: {e}")
        
        return git_state
    
    def _create_full_snapshot(self, rp_dir: Path) -> Path:
        """Create a full snapshot of backup-related files"""
        snapshot_file = rp_dir / "full_snapshot.tar.gz"
        
        # Find all backup files
        backup_patterns = ["*.backup.*", "*.bak", "*~", "*.orig", "*.save"]
        backup_files = []
        
        for pattern in backup_patterns:
            backup_files.extend(Path(".").rglob(pattern))
        
        if not backup_files:
            # Create empty archive
            with tarfile.open(snapshot_file, "w:gz") as tar:
                pass
            return snapshot_file
        
        # Create archive with all backup files
        with tarfile.open(snapshot_file, "w:gz") as tar:
            for backup_file in backup_files:
                if backup_file.exists() and backup_file.is_file():
                    try:
                        tar.add(backup_file, arcname=str(backup_file))
                    except Exception as e:
                        print(f"⚠️  Could not add {backup_file} to snapshot: {e}")
        
        return snapshot_file
    
    def _create_incremental_snapshot(self, rp_dir: Path) -> Path:
        """Create an incremental snapshot (placeholder - would implement delta logic)"""
        # For now, this is the same as full snapshot
        # In a real implementation, this would only backup changed files
        return self._create_full_snapshot(rp_dir)
    
    def _create_file_inventory(self) -> List[str]:
        """Create inventory of all relevant files"""
        inventory = []
        
        # Find all backup files
        backup_patterns = ["*.backup.*", "*.bak", "*~", "*.orig", "*.save"]
        
        for pattern in backup_patterns:
            for file_path in Path(".").rglob(pattern):
                if file_path.is_file():
                    try:
                        stat_info = file_path.stat()
                        inventory.append({
                            "path": str(file_path),
                            "size": stat_info.st_size,
                            "mtime": stat_info.st_mtime,
                            "checksum": self._calculate_file_checksum(file_path)
                        })
                    except Exception as e:
                        print(f"⚠️  Could not inventory {file_path}: {e}")
        
        return inventory
    
    def _calculate_file_checksum(self, file_path: Path) -> str:
        """Calculate SHA-256 checksum of a file"""
        sha256_hash = hashlib.sha256()
        
        try:
            with open(file_path, "rb") as f:
                for chunk in iter(lambda: f.read(4096), b""):
                    sha256_hash.update(chunk)
            return sha256_hash.hexdigest()
        except Exception:
            return ""
    
    def _calculate_recovery_point_checksum(self, recovery_point: RecoveryPoint) -> str:
        """Calculate checksum for recovery point integrity"""
        hasher = hashlib.sha256()
        
        # Include recovery point metadata
        hasher.update(recovery_point.id.encode())
        hasher.update(recovery_point.timestamp.isoformat().encode())
        hasher.update(recovery_point.description.encode())
        
        # Include backup file checksum if available
        if recovery_point.backup_path and recovery_point.backup_path.exists():
            backup_checksum = self._calculate_file_checksum(recovery_point.backup_path)
            hasher.update(backup_checksum.encode())
        
        return hasher.hexdigest()
    
    def start_operation(self, description: str, recovery_point_id: Optional[str] = None) -> str:
        """
        Start a new tracked cleanup operation.
        
        Args:
            description: Description of the operation
            recovery_point_id: Associated recovery point ID
            
        Returns:
            Operation ID
        """
        timestamp = datetime.now()
        op_id = f"op_{timestamp.strftime('%Y%m%d_%H%M%S')}_{hash(description) % 10000:04d}"
        
        operation = CleanupOperation(
            id=op_id,
            timestamp=timestamp,
            status=OperationStatus.PENDING,
            recovery_point_id=recovery_point_id
        )
        
        self.operations[op_id] = operation
        self._save_metadata()
        
        print(f"🚀 Started operation: {op_id}")
        return op_id
    
    def execute_operation(self, op_id: str, operation_func: callable, *args, **kwargs) -> bool:
        """
        Execute an operation with automatic rollback on failure.
        
        Args:
            op_id: Operation ID
            operation_func: Function to execute
            *args, **kwargs: Arguments for the operation function
            
        Returns:
            True if successful, False if failed
        """
        if op_id not in self.operations:
            print(f"❌ Operation not found: {op_id}")
            return False
        
        operation = self.operations[op_id]
        operation.status = OperationStatus.IN_PROGRESS
        self._save_metadata()
        
        try:
            print(f"⚙️  Executing operation: {op_id}")
            
            # Execute the operation
            result = operation_func(*args, **kwargs)
            
            operation.status = OperationStatus.COMPLETED
            self._save_metadata()
            
            print(f"✅ Operation completed: {op_id}")
            return True
            
        except Exception as e:
            print(f"❌ Operation failed: {op_id} - {e}")
            
            operation.status = OperationStatus.FAILED
            operation.error_message = str(e)
            self._save_metadata()
            
            # Attempt automatic rollback
            if operation.recovery_point_id:
                print(f"🔄 Attempting automatic rollback...")
                rollback_success = self.rollback_to_recovery_point(operation.recovery_point_id)
                
                if rollback_success:
                    operation.status = OperationStatus.ROLLED_BACK
                    operation.rollback_point_id = operation.recovery_point_id
                    self._save_metadata()
                    print(f"✅ Automatic rollback completed")
                else:
                    print(f"❌ Automatic rollback failed")
            
            return False
    
    def rollback_to_recovery_point(self, rp_id: str) -> bool:
        """
        Rollback to a specific recovery point.
        
        Args:
            rp_id: Recovery point ID to rollback to
            
        Returns:
            True if successful, False if failed
        """
        if rp_id not in self.recovery_points:
            print(f"❌ Recovery point not found: {rp_id}")
            return False
        
        recovery_point = self.recovery_points[rp_id]
        
        print(f"🔄 Rolling back to recovery point: {rp_id}")
        
        try:
            # Verify recovery point integrity
            if not self._verify_recovery_point_integrity(recovery_point):
                print(f"❌ Recovery point integrity check failed: {rp_id}")
                return False
            
            # Restore git state if available
            if recovery_point.git_state:
                self._restore_git_state(recovery_point.git_state)
            
            # Restore files if backup is available
            if recovery_point.backup_path and recovery_point.backup_path.exists():
                self._restore_files_from_backup(recovery_point.backup_path)
            
            print(f"✅ Rollback completed: {rp_id}")
            return True
            
        except Exception as e:
            print(f"❌ Rollback failed: {e}")
            return False
    
    def _verify_recovery_point_integrity(self, recovery_point: RecoveryPoint) -> bool:
        """Verify the integrity of a recovery point"""
        try:
            # Check if metadata file exists
            if not recovery_point.metadata_path.exists():
                print(f"❌ Recovery point metadata missing: {recovery_point.metadata_path}")
                return False
            
            # Check backup file if it should exist
            if recovery_point.backup_path:
                if not recovery_point.backup_path.exists():
                    print(f"❌ Recovery point backup missing: {recovery_point.backup_path}")
                    return False
                
                # Verify backup file integrity
                current_checksum = self._calculate_file_checksum(recovery_point.backup_path)
                # Note: In a real implementation, we'd store and verify the backup checksum
            
            # Verify checksum if available
            if recovery_point.checksum:
                current_checksum = self._calculate_recovery_point_checksum(recovery_point)
                if current_checksum != recovery_point.checksum:
                    print(f"❌ Recovery point checksum mismatch")
                    return False
            
            return True
            
        except Exception as e:
            print(f"❌ Recovery point integrity verification failed: {e}")
            return False
    
    def _restore_git_state(self, git_state: Dict[str, str]):
        """Restore git repository state"""
        try:
            # Restore HEAD if needed
            if "head" in git_state:
                current_head = subprocess.run([
                    "git", "rev-parse", "HEAD"
                ], capture_output=True, text=True, check=True).stdout.strip()
                
                if current_head != git_state["head"]:
                    print(f"🔄 Restoring git HEAD: {git_state['head']}")
                    subprocess.run([
                        "git", "reset", "--hard", git_state["head"]
                    ], check=True)
            
            # Note: Restoring working tree status and stashes would require
            # more sophisticated logic in a production implementation
            
        except Exception as e:
            print(f"⚠️  Could not fully restore git state: {e}")
    
    def _restore_files_from_backup(self, backup_path: Path):
        """Restore files from a backup archive"""
        try:
            print(f"🔄 Restoring files from backup: {backup_path}")
            
            # Extract backup archive
            with tarfile.open(backup_path, "r:gz") as tar:
                # Extract to current directory
                tar.extractall(path=".")
            
            print(f"✅ Files restored from backup")
            
        except Exception as e:
            print(f"❌ Could not restore files from backup: {e}")
            raise
    
    def list_recovery_points(self) -> List[RecoveryPoint]:
        """List all available recovery points"""
        return sorted(
            self.recovery_points.values(),
            key=lambda rp: rp.timestamp,
            reverse=True
        )
    
    def get_recovery_point(self, rp_id: str) -> Optional[RecoveryPoint]:
        """Get a specific recovery point"""
        return self.recovery_points.get(rp_id)
    
    def _remove_recovery_point(self, rp_id: str):
        """Remove a recovery point and its associated files"""
        if rp_id not in self.recovery_points:
            return
        
        recovery_point = self.recovery_points[rp_id]
        
        # Remove snapshot directory
        rp_dir = recovery_point.metadata_path.parent
        if rp_dir.exists():
            shutil.rmtree(rp_dir, ignore_errors=True)
        
        # Remove from memory
        del self.recovery_points[rp_id]
        self._save_metadata()
    
    def emergency_restore(self, target_rp_id: Optional[str] = None) -> bool:
        """
        Emergency restore to the most recent or specified recovery point.
        
        Args:
            target_rp_id: Specific recovery point ID, or None for most recent
            
        Returns:
            True if successful, False if failed
        """
        if not self.recovery_points:
            print("❌ No recovery points available for emergency restore")
            return False
        
        if target_rp_id:
            if target_rp_id not in self.recovery_points:
                print(f"❌ Specified recovery point not found: {target_rp_id}")
                return False
            target_rp = self.recovery_points[target_rp_id]
        else:
            # Use most recent recovery point
            target_rp = max(self.recovery_points.values(), key=lambda rp: rp.timestamp)
        
        print(f"🚨 EMERGENCY RESTORE to recovery point: {target_rp.id}")
        print(f"   Created: {target_rp.timestamp}")
        print(f"   Description: {target_rp.description}")
        
        return self.rollback_to_recovery_point(target_rp.id)
    
    def check_emergency_stop(self) -> bool:
        """Check if emergency stop has been triggered"""
        emergency_stop_file = Path(".claude/emergency_stop")
        return emergency_stop_file.exists()
    
    def should_rollback(self, error: Exception) -> bool:
        """Determine if an error should trigger automatic rollback"""
        # Define error types that should trigger rollback
        rollback_triggers = [
            "PermissionError",
            "FileNotFoundError", 
            "OSError",
            "subprocess.CalledProcessError"
        ]
        
        error_type = type(error).__name__
        return error_type in rollback_triggers
    
    def get_status_report(self) -> Dict:
        """Get comprehensive status report"""
        recent_operations = [
            op for op in self.operations.values()
            if op.timestamp > datetime.now() - timedelta(hours=24)
        ]
        
        return {
            "timestamp": datetime.now().isoformat(),
            "recovery_points": {
                "total": len(self.recovery_points),
                "valid": sum(1 for rp in self.recovery_points.values() if rp.is_valid),
                "total_size_mb": sum(rp.size_bytes for rp in self.recovery_points.values()) / (1024 * 1024),
                "oldest": min(rp.timestamp for rp in self.recovery_points.values()).isoformat() if self.recovery_points else None,
                "newest": max(rp.timestamp for rp in self.recovery_points.values()).isoformat() if self.recovery_points else None
            },
            "operations": {
                "total": len(self.operations),
                "recent_24h": len(recent_operations),
                "completed": sum(1 for op in self.operations.values() if op.status == OperationStatus.COMPLETED),
                "failed": sum(1 for op in self.operations.values() if op.status == OperationStatus.FAILED),
                "rolled_back": sum(1 for op in self.operations.values() if op.status == OperationStatus.ROLLED_BACK)
            },
            "emergency_stop_active": self.check_emergency_stop()
        }


def main():
    """Example usage of the rollback coordinator"""
    coordinator = RollbackCoordinator()
    
    print("🔄 Rollback Coordinator")
    print("=" * 50)
    
    # Print status report
    status = coordinator.get_status_report()
    print(f"Recovery points: {status['recovery_points']['total']}")
    print(f"Operations: {status['operations']['total']}")
    print(f"Emergency stop active: {status['emergency_stop_active']}")
    
    # Create a test recovery point
    rp_id = coordinator.create_recovery_point(
        "Test recovery point",
        RecoveryPointType.METADATA_ONLY
    )
    
    # Start a test operation
    def test_operation():
        print("Executing test operation...")
        return True
    
    op_id = coordinator.start_operation("Test operation", rp_id)
    success = coordinator.execute_operation(op_id, test_operation)
    
    print(f"Operation {'succeeded' if success else 'failed'}")
    
    # List recovery points
    print("\nAvailable recovery points:")
    for rp in coordinator.list_recovery_points():
        print(f"  {rp.id}: {rp.description} ({rp.timestamp})")


if __name__ == "__main__":
    main()