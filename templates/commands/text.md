---
allowed-tools: all
description: Unified text processing system with multiple modes for review, polish, proofread, and comprehensive text improvement
---

# 📝 Unified Text Processing System

**COMPREHENSIVE TEXT IMPROVEMENT WITH MODE-BASED OPERATION**

When you run `/text`, you will:

1. **DETECT** the text processing mode from arguments or context
2. **ANALYZE** text for improvement opportunities
3. **PRESERVE** code functionality and syntax integrity
4. **APPLY** improvements based on selected mode
5. **REPORT** detailed changes and quality metrics

## 📋 TEXT PROCESSING MODES

### Available Modes

```bash
# Interactive review with user approval (default)
/text
/text --mode=review

# Comprehensive text transformation
/text --mode=polish

# Safe automatic corrections
/text --mode=proofread

# AI-powered enhancement
/text --mode=enhance

# Combined all modes sequentially
/text --mode=comprehensive
```

## 🎯 MODE SPECIFICATIONS

### Mode: Review (Default)
**Interactive user-guided text improvement**

```yaml
review_mode:
  workflow:
    - present_issues_with_context
    - get_user_approval
    - apply_approved_changes
    - track_progress
  
  features:
    - prioritized_issue_presentation
    - contextual_suggestions
    - batch_approval_options
    - session_state_tracking
  
  control:
    - user_approval_required: always
    - auto_apply: never
    - skip_option: available
```

### Mode: Polish
**Comprehensive multi-pass text transformation**

```yaml
polish_mode:
  passes:
    1. grammar_and_clarity
    2. terminology_standardization
    3. style_consistency
    4. professional_enhancement
  
  quality_levels:
    - production_ready
    - documentation_grade
    - publication_quality
  
  features:
    - multi_agent_processing
    - progressive_enhancement
    - consistency_analysis
    - comprehensive_reporting
```

### Mode: Proofread
**Safe automatic text corrections**

```yaml
proofread_mode:
  corrections:
    - spelling_errors
    - grammar_issues
    - punctuation_fixes
    - formatting_consistency
  
  safety:
    - syntax_preservation: guaranteed
    - incremental_validation
    - rollback_capability
    - comprehensive_backups
  
  validation:
    - pre_correction_check
    - post_correction_verification
    - functionality_testing
```

### Mode: Enhance
**AI-powered text enhancement**

```yaml
enhance_mode:
  improvements:
    - clarity_optimization
    - conciseness_improvement
    - tone_adjustment
    - readability_enhancement
  
  targets:
    - comments_and_docs
    - error_messages
    - user_facing_text
    - api_documentation
  
  intelligence:
    - context_awareness
    - domain_adaptation
    - style_learning
```

### Mode: Comprehensive
**All modes applied sequentially**

```yaml
comprehensive_mode:
  sequence:
    1. proofread  # Fix basic errors
    2. polish     # Transform quality
    3. enhance    # AI improvements
    4. review     # Final user approval
  
  coordination:
    - shared_analysis
    - cumulative_improvements
    - unified_reporting
```

## 🛡️ UNIVERSAL SAFETY FEATURES

### Code Integrity Protection
```typescript
interface SafetyChecks {
  syntaxValidation: boolean;      // Before and after changes
  functionalityPreserved: boolean; // No logic modifications
  backupCreated: boolean;         // Rollback capability
  testsPass: boolean;             // Validation suite
}
```

### Text Analysis Categories
```yaml
analysis_categories:
  errors:
    - spelling_mistakes
    - grammar_errors
    - punctuation_issues
    
  clarity:
    - ambiguous_phrasing
    - complex_sentences
    - unclear_references
    
  consistency:
    - terminology_variations
    - style_inconsistencies
    - formatting_differences
    
  quality:
    - readability_score
    - professional_tone
    - technical_accuracy
```

### Preservation Patterns
**ALWAYS PRESERVED across all modes:**
- Code syntax and functionality
- Variable and function names
- URLs and external references
- Technical specifications
- Intentional formatting
- Domain-specific terminology

## 📊 EXECUTION WORKFLOW

### Step 1: Mode Detection
```javascript
function detectTextMode(args) {
  // Explicit mode selection
  if (args.mode) return args.mode;
  
  // Context-based detection
  if (args.includes('interactive')) return 'review';
  if (args.includes('transform') || args.includes('quality')) return 'polish';
  if (args.includes('correct') || args.includes('fix')) return 'proofread';
  if (args.includes('improve') || args.includes('enhance')) return 'enhance';
  
  // Default to interactive review
  return 'review';
}
```

### Step 2: Multi-Agent Processing
```
"I'll spawn specialized text processing agents:
- Analysis Agent: Identify improvement opportunities
- Mode Agent: Execute mode-specific logic
- Safety Agent: Ensure code integrity
- Report Agent: Generate improvement metrics

Agents coordinate for comprehensive text processing."
```

### Step 3: Mode-Specific Execution

#### Review Mode Interface
```
📝 Text Review Session

Issue #1: Spelling Error
File: src/utils.js:45
Current: "Recieve data from the server"
Suggested: "Receive data from the server"

[Apply] [Skip] [Apply All Similar] [View Context]
```

#### Polish Mode Transformation
```
Pass 1/4: Grammar and Clarity
- Fixed 23 grammar issues
- Improved 15 sentence structures
- Clarified 8 ambiguous phrases

Pass 2/4: Terminology Standardization
- Unified 12 term variations
- Applied consistent naming
...
```

#### Proofread Mode Safety
```
Creating safety backup...
Validating syntax before corrections...
Applying corrections incrementally:
  ✓ Fixed 45 spelling errors
  ✓ Corrected 12 grammar issues
  ✓ Syntax validation: PASSED
  ✓ Tests running: ALL GREEN
```

### Step 4: Results Reporting
```
Text Processing Complete - Mode: polish

Summary:
├── Files Processed: 45
├── Improvements Applied: 234
├── Quality Metrics:
│   ├── Readability: 72 → 89 (+17)
│   ├── Consistency: 65% → 94% (+29%)
│   └── Error Rate: 2.3% → 0.1% (-2.2%)
├── Categories:
│   ├── Grammar: 67 fixes
│   ├── Spelling: 45 corrections
│   ├── Clarity: 89 improvements
│   └── Style: 33 standardizations
└── Code Integrity: ✅ Preserved

Safety Report:
├── Syntax Checks: All passed
├── Functionality: Unchanged
├── Tests: 100% passing
└── Rollback Available: Yes
```

## 🔧 CONFIGURATION

### Default Settings
```yaml
# .text-config.yaml
version: 2.0
default_mode: review

modes:
  review:
    batch_size: 10
    context_lines: 3
    auto_skip_minor: false
    
  polish:
    passes: 4
    quality_target: production
    preserve_style: true
    
  proofread:
    auto_correct: true
    validation_level: strict
    backup_always: true
    
  enhance:
    ai_model: advanced
    tone: professional
    domain: technical

safety:
  syntax_check: always
  test_after: true
  rollback_enabled: true
  max_changes_per_file: 100
```

### Command Options
```bash
# Mode selection
--mode=<review|polish|proofread|enhance|comprehensive>

# Target selection
--path=<path>          # Specific directory
--files=<pattern>      # File pattern
--type=<code|docs|all> # Content type

# Processing options
--interactive         # Force interactive mode
--auto-approve       # Skip confirmations
--dry-run           # Preview changes

# Quality settings
--quality=<basic|standard|premium>
--preserve-style    # Maintain existing style
--strict           # Strict validation

# Safety options
--backup          # Force backup creation
--validate       # Extra validation
--test          # Run tests after

# Output options
--verbose      # Detailed output
--quiet       # Minimal output
--report      # Generate report
```

## 🚨 MODE-SPECIFIC BEHAVIORS

### Review Mode Specifics
- User controls every change
- Contextual issue presentation
- Batch operations available
- Progress saved between sessions

### Polish Mode Specifics
- Multi-pass transformation
- Production-quality output
- Consistency enforcement
- Style standardization

### Proofread Mode Specifics
- Automatic safe corrections
- Incremental application
- Continuous validation
- Instant rollback capability

### Enhance Mode Specifics
- AI-powered improvements
- Context-aware suggestions
- Domain adaptation
- Learning from feedback

## 💡 USAGE EXAMPLES

### Example 1: Interactive Code Review
```bash
# Review and fix text issues interactively
/text --mode=review --path=src/
```

### Example 2: Polish Documentation
```bash
# Transform documentation to production quality
/text --mode=polish --type=docs
```

### Example 3: Quick Proofreading
```bash
# Automatically fix common errors
/text --mode=proofread --auto-approve
```

### Example 4: Comprehensive Improvement
```bash
# Apply all text improvements
/text --mode=comprehensive --quality=premium
```

### Example 5: Targeted Enhancement
```bash
# Enhance error messages
/text --mode=enhance --files="**/errors.js"
```

## ✅ SUCCESS CRITERIA

**Text processing is successful when:**
- ✅ All target improvements applied correctly
- ✅ Code functionality completely preserved
- ✅ Syntax validation passes 100%
- ✅ Quality metrics show improvement
- ✅ User satisfaction with changes
- ✅ Complete audit trail maintained

## 🎬 EXECUTION

Begin text processing with selected mode:

1. **DETECT** appropriate processing mode
2. **ANALYZE** text for improvements
3. **VALIDATE** safety and integrity
4. **APPLY** mode-specific processing
5. **VERIFY** results and quality
6. **REPORT** comprehensive metrics

Remember: **Quality text enhances code value while preserving functionality**

Executing text processing with mode: $ARGUMENTS