---
allowed-tools: all
description: Unified cleanup system with multiple modes for intelligent code, artifact, backup, and dead code removal
---

# 🧹 Unified Cleanup System

**COMPREHENSIVE CLEANUP WITH MODE-BASED OPERATION**

When you run `/cleanup`, you will:

1. **DETECT** the cleanup mode from arguments or context
2. **ANALYZE** targets with appropriate safety checks
3. **PRESERVE** valuable patterns and framework code
4. **VERIFY** all changes with comprehensive testing
5. **REPORT** detailed metrics for each cleanup operation

## 📋 CLEANUP MODES

### Available Modes

```bash
# Intelligent code cleanup (default)
/cleanup
/cleanup --mode=intelligent

# Development artifacts cleanup
/cleanup --mode=artifacts

# Claude backup files cleanup  
/cleanup --mode=backups

# Dead code and imports cleanup
/cleanup --mode=code

# Comprehensive cleanup (all modes)
/cleanup --mode=all
```

## 🎯 MODE SPECIFICATIONS

### Mode: Intelligent (Default)
**Safety-first cleanup with confidence scoring**

```yaml
intelligent_cleanup:
  targets:
    - commented_code: # 90+ days old, no TODOs
    - console_logs: # Production code only
    - empty_files: # Not framework-required
    - unused_imports: # No side effects
  
  confidence_levels:
    high: # >85% - Auto-execute
    medium: # 60-85% - User prompt
    low: # <60% - Report only
  
  preserves:
    - dynamic_patterns
    - framework_magic
    - test_utilities
    - recent_changes
```

### Mode: Artifacts
**Clean development artifacts and temporary files**

```yaml
artifacts_cleanup:
  targets:
    - "*.log"
    - "*.tmp"
    - "*~"
    - "*.bak"
    - ".DS_Store"
    - "debug_*"
    - "test_output_*"
  
  protected:
    - ".env*"
    - ".git/"
    - ".claude/"
    - "node_modules/"
    - "vendor/"
  
  strategy:
    - check_file_age
    - verify_git_status
    - create_checkpoint
```

### Mode: Backups
**Remove Claude Code backup files**

```yaml
backups_cleanup:
  patterns:
    - "*.backup.*"
    - "*.claude-backup"
    - "*_backup_*"
  
  retention:
    default: 24_hours
    configurable: true
  
  features:
    - preview_before_delete
    - size_reporting
    - batch_operations
```

### Mode: Code
**Dead code and import optimization**

```yaml
code_cleanup:
  targets:
    - unused_functions
    - unreachable_code
    - unused_imports
    - duplicate_code
    - orphaned_exports
  
  analysis:
    - dependency_graph
    - test_coverage
    - dynamic_usage
  
  safety:
    - ast_analysis
    - test_validation
    - incremental_cleanup
```

### Mode: All
**Comprehensive cleanup - runs all modes sequentially**

```yaml
all_cleanup:
  sequence:
    1. artifacts # Remove temp files first
    2. backups  # Clean old backups
    3. code     # Optimize code structure
    4. intelligent # Final smart cleanup
  
  coordination:
    - shared_safety_checks
    - unified_reporting
    - single_checkpoint
```

## 🛡️ UNIVERSAL SAFETY FEATURES

### Pre-Cleanup Validation
```bash
# Always performed regardless of mode
1. Create git checkpoint
2. Run test suite baseline
3. Analyze project structure
4. Map dependencies
5. Identify framework patterns
```

### Confidence Scoring System
```typescript
interface ConfidenceFactors {
  hasDirectReferences: boolean;      // -0.5 if false
  hasTestCoverage: boolean;          // -0.3 if false
  isDynamicallyLoadable: boolean;    // -0.8 if true
  isFrameworkPattern: boolean;       // -0.9 if true
  daysSinceLastModified: number;     // +0.1 per 30 days
  hasDocumentation: boolean;         // -0.2 if true
  isInPublicAPI: boolean;           // -0.7 if true
}
```

### Protection Patterns
**ALWAYS PRESERVED across all modes:**
- Dynamic imports and requires
- Event handlers and listeners
- Framework decorators and magic
- Test fixtures and utilities
- Recent changes (< 30 days)
- Active TODOs and FIXMEs

## 📊 EXECUTION WORKFLOW

### Step 1: Mode Detection
```javascript
function detectCleanupMode(args) {
  // Explicit mode selection
  if (args.mode) return args.mode;
  
  // Context-based detection
  if (args.includes('backup')) return 'backups';
  if (args.includes('artifact')) return 'artifacts';
  if (args.includes('import') || args.includes('dead')) return 'code';
  
  // Default to intelligent mode
  return 'intelligent';
}
```

### Step 2: Multi-Agent Execution
```
"I'll spawn specialized cleanup agents based on mode:
- Mode Agent: Execute mode-specific cleanup logic
- Safety Agent: Verify preservation patterns
- Test Agent: Validate changes don't break functionality
- Report Agent: Generate comprehensive metrics

All agents coordinate through shared safety checks."
```

### Step 3: Interactive Decision Points
```
# Medium confidence items prompt
Found potentially unused function: calculateDiscount
Confidence: 72% | Mode: code

Analysis:
✓ No direct calls found
✓ Not covered by tests
✗ May be called dynamically
✗ Contains business logic

[Remove] [Keep] [Add TODO] [Skip All Similar]
```

### Step 4: Verification & Reporting
```
Cleanup Complete - Mode: intelligent

Summary:
├── Files Analyzed: 234
├── Items Cleaned: 45
├── Space Saved: 1.2MB
├── Confidence Breakdown:
│   ├── High (auto): 32 items
│   ├── Medium (reviewed): 13 items
│   └── Low (skipped): 156 items
└── Tests: All passing ✅

Safety Metrics:
├── Patterns Preserved: 78
├── Framework Code: Protected
├── Dynamic Usage: Detected & kept
└── Rollbacks Required: 0
```

## 🔧 CONFIGURATION

### Default Settings
```yaml
# .cleanup-config.yaml
version: 2.0
default_mode: intelligent

modes:
  intelligent:
    auto_threshold: 0.85
    prompt_threshold: 0.60
    
  artifacts:
    age_threshold: 7_days
    size_limit: 10MB
    
  backups:
    retention_hours: 24
    batch_size: 100
    
  code:
    unused_threshold: 0
    coverage_required: false

safety:
  dry_run: false
  backup: true
  atomic_commits: true
  test_on_change: true
```

### Command Options
```bash
# Mode selection
--mode=<intelligent|artifacts|backups|code|all>

# Safety options
--dry-run         # Preview without changes
--no-backup      # Skip checkpoint creation
--force          # Skip confirmations

# Filtering
--path=<path>    # Target specific directory
--pattern=<glob> # Target specific files
--exclude=<glob> # Exclude patterns

# Thresholds
--confidence=<0-100>  # Minimum confidence
--age=<days>          # Minimum file age
--retention=<hours>   # Backup retention

# Output
--verbose        # Detailed output
--quiet         # Minimal output
--json          # JSON report format
```

## 🚨 MODE-SPECIFIC BEHAVIORS

### Intelligent Mode Specifics
- Uses AST analysis for code understanding
- Applies machine learning confidence scoring
- Preserves all edge cases automatically
- Learns from user decisions

### Artifacts Mode Specifics
- Focuses on filesystem cleanup
- Respects .gitignore patterns
- Creates restore checkpoint
- Reports space savings

### Backups Mode Specifics
- Targets Claude-specific backup patterns
- Configurable retention policy
- Batch deletion for performance
- Size and count reporting

### Code Mode Specifics
- Language-specific analyzers
- Import graph analysis
- Test coverage integration
- Incremental cleanup approach

## 💡 USAGE EXAMPLES

### Example 1: Quick Project Cleanup
```bash
# Remove all development artifacts
/cleanup --mode=artifacts --dry-run
/cleanup --mode=artifacts  # If preview looks good
```

### Example 2: Code Optimization
```bash
# Clean dead code with high confidence
/cleanup --mode=code --confidence=85
```

### Example 3: Comprehensive Cleanup
```bash
# Full cleanup with all modes
/cleanup --mode=all --verbose
```

### Example 4: Targeted Cleanup
```bash
# Clean specific directory
/cleanup --mode=intelligent --path=src/components
```

## ✅ SUCCESS CRITERIA

**Cleanup is successful when:**
- ✅ All tests remain passing
- ✅ No functionality lost
- ✅ Performance unchanged or improved
- ✅ Clear audit trail maintained
- ✅ User confidence preserved
- ✅ Measurable improvement achieved

## 🎬 EXECUTION

Begin unified cleanup with selected mode:

1. **DETECT** appropriate cleanup mode
2. **ANALYZE** with mode-specific logic
3. **SCORE** confidence for each item
4. **PRESERVE** all protected patterns
5. **EXECUTE** with safety verification
6. **REPORT** comprehensive results

Remember: **Effective cleanup preserves value while removing redundancy**

Executing cleanup with mode: $ARGUMENTS