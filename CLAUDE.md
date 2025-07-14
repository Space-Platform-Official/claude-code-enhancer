# Development Partnership

We're building production-quality code together. Your role is to create maintainable, efficient solutions while catching potential issues early.

When you seem stuck or overly complex, I'll redirect you - my guidance helps you stay on track.

## 🚨 MANDATORY FILE CREATION CONSTRAINTS

**ZERO TOLERANCE FOR UNNECESSARY FILE PROLIFERATION!**

### Core File Creation Principles
- **NEVER create new files unless absolutely critical for core functionality**
- **ALWAYS consolidate related content into existing files**
- **MAXIMUM 5 new files per feature implementation**
- **MANDATORY justification required for any new file creation**

### Enforced File Creation Hierarchy
1. **FIRST**: Edit existing files to add functionality
2. **SECOND**: Consolidate multiple related concepts into single files
3. **THIRD**: Use progressive disclosure within existing files
4. **LAST RESORT**: Create new files only if impossible to avoid

### File Creation Quality Gates
Before creating ANY new file, you MUST:
- [ ] Verify no existing file can be extended
- [ ] Confirm consolidation is impossible
- [ ] Document why existing patterns don't work
- [ ] Get explicit user approval for new files

## 📚 DOCUMENTATION MINIMALISM MANDATE

### Single Source of Truth Principle
**ELIMINATE DOCUMENTATION DUPLICATION AND PROLIFERATION**

- **ONE comprehensive file per major topic maximum**
- **Embed examples within primary documentation**
- **Use progressive disclosure sections, not separate files**
- **Maximum documentation hierarchy: 3 levels deep**

### Forbidden Documentation Patterns
❌ **NEVER create**: Multiple README files
❌ **NEVER create**: Separate example files
❌ **NEVER create**: Topic-specific sub-documentation
❌ **NEVER create**: Tutorial series as separate files

## 🚨 AUTOMATED CHECKS ARE MANDATORY

**ALL hook issues are BLOCKING - EVERYTHING must be ✅ GREEN!**
No errors. No formatting issues. No linting problems. Zero tolerance.
These are not suggestions. Fix ALL issues before continuing.

## CRITICAL WORKFLOW - ALWAYS FOLLOW THIS!

### Research → Plan → Implement

**NEVER JUMP STRAIGHT TO CODING!** Always follow this sequence:

1. **Research**: Explore the codebase, understand existing patterns
2. **Plan**: Create a detailed implementation plan and verify it with me
3. **Implement**: Execute the plan with validation checkpoints

When asked to implement any feature, you'll first say: "Let me research the codebase and create a plan before implementing."

For complex architectural decisions or challenging problems, use **"ultrathink"** to engage maximum reasoning capacity. Say: "Let me ultrathink about this architecture before proposing a solution."

### USE MULTIPLE AGENTS!

*Leverage subagents aggressively* for better results:

- Spawn agents to explore different parts of the codebase in parallel
- Use one agent to write tests while another implements features
- Delegate research tasks: "I'll have an agent investigate the database schema while I analyze the API structure"
- For complex refactors: One agent identifies changes, another implements them

Say: "I'll spawn agents to tackle different aspects of this problem" whenever a task has multiple independent parts.

### 🎛️ USER-CONTROLLED VERBOSITY SYSTEM

**Let users choose their complexity level:**

```yaml
# User verbosity preferences (configurable)
claude_config:
  verbosity_level: "minimal"  # minimal | standard | comprehensive
  file_generation: "conservative"  # conservative | balanced | permissive
  documentation_style: "consolidated"  # consolidated | detailed | extensive
```

#### Verbosity Level Behaviors

**Minimal Mode (Default)**:
- Single files for major topics
- Essential functionality only
- No separate example files (embed examples)
- Maximum 10 total new files per project

**Standard Mode**:
- Moderate file organization
- Core + some advanced functionality
- Limited separate files when justified
- Maximum 25 total new files per project

**Comprehensive Mode**:
- Full file organization when explicitly requested
- All functionality exposed
- Separate files allowed with user approval
- Maximum 50 total new files per project

### Reality Checkpoints

**Stop and validate** at these moments:

- After implementing a complete feature
- Before starting a new major component
- When something feels wrong
- Before declaring "done"
- **WHEN HOOKS FAIL WITH ERRORS** ❌

Run: `make fmt && make test && make lint`

> Why: You can lose track of what's actually working. These checkpoints prevent cascading failures.

## 🔧 TEMPLATE CONSOLIDATION MANDATE

### Template Inheritance System
**ELIMINATE TEMPLATE DUPLICATION THROUGH SMART INHERITANCE**

- **Base templates only**: Maximum 3 base templates per language
- **Composition over creation**: Combine templates, don't duplicate
- **Parameterized templates**: Use variables instead of separate files
- **Conditional sections**: Use templating logic, not file variants

### Template File Limits
- **Languages**: 1 base template + 1 enhanced template maximum
- **Frameworks**: Inherit from language base, add minimal extensions
- **Workflows**: Single configurable template with parameters
- **Commands**: Consolidate related commands into single template

## 🔍 PROGRESSIVE DISCLOSURE BY DEFAULT

### On-Demand Content Generation
**GENERATE CONTENT WHEN NEEDED, NOT UPFRONT**

- **Default behavior**: Show minimal interface, expand on request
- **Contextual revelation**: Present details based on user actions
- **Just-in-time documentation**: Generate specific help when requested
- **Usage-driven expansion**: Create content based on actual need

### Progressive Interface Rules
- **Initial view**: Core functionality only (80/20 rule)
- **Expansion triggers**: User-initiated or context-driven
- **Content layering**: Basic → Intermediate → Advanced on demand
- **Memory optimization**: Cache frequently accessed, purge unused

## 🛡️ MANDATORY FILE PROLIFERATION QUALITY GATES

### Pre-Creation Validation Pipeline
**EVERY FILE CREATION MUST PASS ALL GATES**

#### Gate 1: Necessity Validation
- [ ] Functionality impossible without new file
- [ ] No existing file can accommodate content
- [ ] Consolidation approaches exhausted
- [ ] User explicitly requests separate file

#### Gate 2: Maintenance Impact Assessment
- [ ] File adds <10% to total project complexity
- [ ] Clear ownership and update responsibility
- [ ] Integration with existing files validated
- [ ] Removal/consolidation path documented

#### Gate 3: User Experience Impact
- [ ] Navigation complexity not increased
- [ ] Cognitive load impact measured as acceptable
- [ ] File discovery mechanisms sufficient
- [ ] User workflow improvement demonstrated

### Automatic Rejection Criteria
❌ **Auto-reject if**:
- File count exceeds verbosity level limits
- Similar content exists elsewhere
- Can be achieved through editing existing files
- No clear maintenance plan exists
- Increases navigation depth unnecessarily

## 🔄 FUNCTIONALITY PRESERVATION REQUIREMENTS

### Backward Compatibility Guarantees
**ZERO FUNCTIONALITY LOSS DURING FILE CONSOLIDATION**

- **All existing commands**: Must work with consolidated structure
- **Template functionality**: Preserved through inheritance/composition
- **User workflows**: Maintained through intelligent redirects
- **Integration points**: Updated automatically during consolidation

## 📂 INTELLIGENT FOLDER ORGANIZATION

### Mild Organization Principles
**BALANCED CATEGORIZATION - NOT TOO AGGRESSIVE**

- **Maximum 3 folder levels** (respecting cognitive load limits)
- **Minimum 3 similar files** before creating folders
- **Framework-aware organization** respecting ecosystem conventions
- **User override capability** for all organization decisions

### Semantic Categorization Rules

#### Automatic Folder Creation Triggers
- **Tests**: Files ending in .test, .spec, or in __tests__ → tests/
- **Configuration**: Config files, .env, settings → config/
- **Utilities**: Helper functions, shared code → utils/
- **Documentation**: .md files (except README) → docs/

#### Content-Based Grouping (Mild)
- **Similar imports**: Files importing same dependencies → consider grouping
- **Naming patterns**: Shared prefixes (use*, *Config, *Helper) → semantic folders
- **Framework detection**: React components → components/, API routes → routes/

#### Folder Creation Limits
- **Maximum 7 items** per folder before suggesting subdivision
- **Respect file creation limits**: Folders count toward 5-file maximum
- **User approval required** for new folder creation
- **Rollback capability** for all organization changes

### Organization Quality Gates
Before creating ANY folder, you MUST:
- [ ] Verify 3+ files would benefit from grouping
- [ ] Confirm folder depth stays ≤3 levels
- [ ] Check framework conventions allow organization
- [ ] Get explicit user approval for folder creation

### Forbidden Organization Patterns
❌ **NEVER create**: Folders deeper than 3 levels
❌ **NEVER organize**: Single files (exception: framework requirements)
❌ **NEVER separate**: Tightly coupled files
❌ **NEVER override**: Framework-mandated structures

### Similarity Detection Rules
**Reasonable Similarity Thresholds for Grouping:**

#### High Similarity (75-90%) → Same Folder
- Files with shared function signatures
- Similar import patterns and dependencies
- Matching naming conventions (prefixes/suffixes)
- Related business domain terminology

#### Medium Similarity (50-75%) → Suggest Grouping
- Related functionality but different implementation
- Shared framework patterns (components, hooks, services)
- Similar file types with related purposes
- Common configuration or utility patterns

#### Low Similarity (<50%) → Keep Separate
- Different domains or purposes
- Unrelated functionality
- Different architectural layers
- Independent utility functions

### Framework-Aware Organization
**Respect Established Ecosystem Patterns:**

- **React/Next.js**: components/, pages/, hooks/, utils/
- **Vue.js**: components/, views/, composables/, utils/
- **Angular**: components/, services/, modules/, pipes/
- **Express/Node.js**: routes/, middleware/, controllers/, models/
- **Django**: models/, views/, templates/, static/
- **FastAPI/Flask**: routes/, models/, schemas/, utils/

### 🚨 CRITICAL: Hook Failures Are BLOCKING