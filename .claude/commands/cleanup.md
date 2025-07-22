---
allowed-tools: all
description: Intelligent code cleanup with safety-first approach and confidence-based decisions
---

# 🧹 Intelligent Cleanup System - Phase 1: Safety-First Implementation

**THIS IS A PRECISION CLEANUP TASK - NOT A SLEDGEHAMMER!**

When you run `/cleanup`, you will:

1. **ANALYZE** code with context awareness and confidence scoring
2. **PRESERVE** valuable patterns, framework code, and dynamic usage
3. **VERIFY** all changes with comprehensive testing
4. **USE MULTIPLE AGENTS** for parallel analysis with safety checks
5. **LEARN** from decisions to improve future cleanup operations

## 🛡️ SAFETY-FIRST PRINCIPLES

**MANDATORY PRESERVATION PATTERNS:**
- ✅ Dynamically loaded modules and plugins
- ✅ Framework-specific patterns (decorators, dependency injection)
- ✅ Test fixtures and utilities
- ✅ Performance-optimized code variants
- ✅ Recent changes (< 30 days)
- ✅ Code with active TODOs linked to issues

**CONFIDENCE-BASED ACTIONS:**
- 🟢 **High Confidence (>85%)**: Safe to clean automatically
- 🟡 **Medium Confidence (60-85%)**: Require user confirmation
- 🔴 **Low Confidence (<60%)**: Flag for manual review only

## 📋 MANDATORY WORKFLOW

### Step 1: Pre-Cleanup Analysis
```
1. Run full test suite to establish baseline
2. Generate dependency graph
3. Analyze git history and code age
4. Identify framework patterns
5. Map dynamic loading points
```

### Step 2: Intelligent Detection

**SAFE CLEANUP TARGETS:**
```yaml
high_confidence_removals:
  - commented_code:
      exclude: ["TODO", "FIXME", "HACK", "NOTE"]
      age_minimum: 90_days
      confidence: 0.95
      
  - empty_files:
      exclude: ["__init__", "index"]
      confidence: 0.90
      
  - console_logs:
      exclude: ["error", "warn"]
      in_production_code: true
      confidence: 0.85

medium_confidence_analysis:
  - unused_functions:
      check_dynamic_usage: true
      check_test_coverage: true
      confidence: 0.70
      
  - duplicate_code:
      similarity_threshold: 0.95
      verify_behavior: true
      confidence: 0.75
```

### Step 3: Context-Aware Analysis

**For EACH cleanup candidate, analyze:**

1. **Git Context**:
   - Last modified date
   - Number of contributors
   - Commit frequency
   - Related issues/PRs

2. **Code Context**:
   - Test coverage
   - Dynamic references
   - Framework patterns
   - Performance implications

3. **Dependency Context**:
   - Import/export chains
   - Circular dependencies
   - External references
   - Configuration usage

### Step 4: Multi-Agent Safe Execution

**SPAWN AGENTS WITH SAFETY CONSTRAINTS:**
```
"I'll spawn multiple agents to analyze the codebase safely:
- Agent 1: Identify high-confidence dead code with preservation checks
- Agent 2: Analyze potential duplicates with behavior verification
- Agent 3: Check for dynamic usage patterns and framework magic
- Agent 4: Validate all changes against test suite

Each agent will report confidence scores before any action."
```

## 🔍 EDGE CASE DETECTION

**ALWAYS CHECK FOR:**

```javascript
// Dynamic imports - PRESERVE
const module = await import(`./plugins/${name}`);
const handler = require(`./${type}-handler`);

// Event handlers - PRESERVE
emitter.on('data', processData);
bus.subscribe('user:login', handleLogin);

// Reflection patterns - PRESERVE
const method = obj[methodName];
const Component = components[props.type];

// Framework magic - PRESERVE
@Injectable()
@Component({ selector: 'app-root' })
export default connect(mapState)(MyComponent);

// Test utilities - PRESERVE
export const mockUser = () => ({ id: 1 });
export function createTestServer() { }
```

## 📊 CONFIDENCE SCORING

**Calculate confidence based on:**

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

## 🚦 SAFE CLEANUP EXECUTION

### High Confidence Actions (Auto-execute):
- Remove commented code (90+ days old, no TODOs)
- Delete empty files (not framework-required)
- Remove console.logs in production code
- Delete unused imports with no side effects

### Medium Confidence Actions (User Prompt):
```
Found potentially unused function: calculateDiscount
Confidence: 72%

Reasons to remove:
- No direct calls found
- Not covered by tests
- Last modified 180 days ago

Reasons to keep:
- Similar to other calculation functions
- May be called dynamically
- Contains business logic

[Remove] [Keep] [Add TODO] [Investigate Further]
```

### Low Confidence Actions (Report Only):
```
Cleanup Analysis Report:
- Possible unused exports (12 items) - manual review needed
- Complex duplicates (5 groups) - behavior verification required  
- Framework patterns (8 items) - preserved automatically
```

## ✅ VERIFICATION PROTOCOL

**After EACH change:**
1. Run affected tests immediately
2. Verify no runtime errors
3. Check import/export integrity
4. Validate framework functionality
5. Ensure performance unchanged

**Rollback Criteria:**
- Any test failure → Rollback immediately
- Runtime error → Restore and investigate
- Performance regression → Revert and document

## 📈 CLEANUP METRICS

**Track and Report:**
```
Cleanup Summary:
├── Analyzed: 1,234 potential items
├── High Confidence: 156 items (auto-cleaned)
├── Medium Confidence: 89 items (45 cleaned after review)
├── Low Confidence: 989 items (flagged for manual review)
├── Preserved: 234 edge cases detected
└── Result: 15% code reduction, 0 functionality lost

Safety Metrics:
├── Tests: 100% passing
├── Coverage: Maintained at 87%
├── Performance: No regression
└── Rollbacks: 0 required
```

## 🎯 CLEANUP CONFIGURATION

**Default Configuration (Conservative):**
```yaml
# .cleanup-config.yaml
version: 1.0
mode: conservative

confidence:
  auto_threshold: 0.85
  prompt_threshold: 0.60
  
preserve_patterns:
  - "test_*"
  - "*_test"
  - "mock*"
  - "@*" # decorators
  - "use*" # React hooks
  
age_thresholds:
  commented_code: 90
  unused_functions: 180
  todo_comments: 365
  
safety:
  dry_run: true
  backup: true
  atomic_commits: true
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ Delete without understanding purpose
- ❌ Remove code just because it "looks unused"
- ❌ Ignore framework conventions
- ❌ Skip test verification
- ❌ Cleanup without confidence scoring
- ❌ Merge duplicates without behavior verification

**ALWAYS:**
- ✅ Check for dynamic usage patterns
- ✅ Preserve framework requirements
- ✅ Verify with comprehensive tests
- ✅ Document why code was kept/removed
- ✅ Maintain rollback capability
- ✅ Report confidence scores

## 💡 INTELLIGENT DECISION EXAMPLES

**Example 1: Seemingly Unused Function**
```javascript
// PRESERVE - May be dynamically called
export function handleUserAction() { }

// Config file:
handlers: ['handleUserAction']
```

**Example 2: Duplicate-Looking Code**
```javascript
// PRESERVE BOTH - Different performance characteristics
function fastSearch(arr) { /* O(log n) */ }
function simpleSearch(arr) { /* O(n) but cache-friendly */ }
```

**Example 3: Framework Pattern**
```typescript
// PRESERVE - Angular DI pattern
@Injectable({ providedIn: 'root' })
export class DataService { }
```

## 🎬 FINAL EXECUTION

**Begin intelligent cleanup with:**

1. **ANALYZE** comprehensively with context
2. **SCORE** confidence for each item
3. **PRESERVE** all edge cases and patterns
4. **PROMPT** for medium confidence items
5. **VERIFY** every change with tests
6. **REPORT** detailed metrics

**Success Criteria:**
- ✅ Zero broken functionality
- ✅ All tests passing
- ✅ No performance regression
- ✅ Clear audit trail
- ✅ Improved code quality
- ✅ Team confidence maintained

Remember: **Good cleanup preserves intent while removing redundancy**

Executing intelligent cleanup for: $ARGUMENTS