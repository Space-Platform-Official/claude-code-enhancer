# 🎯 Core Commands Documentation

> Essential Claude Code commands for architecture, implementation, and project management

---

## 📐 `/architect` - System Architecture & Design

### Overview
The architect command prioritizes **design before code**, performing comprehensive architecture analysis with ADR (Architecture Decision Records) generation and implementation roadmaps.

### Key Features
- **5-agent parallel analysis** using Task tool
- **Multiple solution evaluation** with trade-off analysis
- **ADR generation** for all significant decisions
- **Implementation roadmap** creation
- **Risk assessment** and mitigation strategies

### Usage
```bash
claude architect
# Triggers comprehensive architecture analysis
# Spawns 5 specialized agents in parallel
# Generates ADRs and implementation plans
```

### Agent Architecture
The command deploys 5 parallel agents:
1. **Domain Analysis Agent** - Business requirements and constraints
2. **Dependency Mapping Agent** - System dependencies and integrations
3. **Pattern Research Agent** - Architectural patterns and best practices
4. **Risk Assessment Agent** - Technical risks and mitigations
5. **Documentation Agent** - ADR generation and roadmap creation

### Examples
```bash
# Design a user authentication system
claude architect "user authentication with OAuth and JWT"

# Plan microservices migration
claude architect "migrate monolith to microservices"

# Design real-time data pipeline
claude architect "real-time analytics pipeline with Kafka"
```

### Output Structure
```markdown
## Architecture Analysis
- Current state assessment
- Multiple solution options
- Trade-off matrix
- Risk analysis

## Architecture Decision Records
- ADR-001: [Decision Title]
  - Status: Accepted
  - Context: [Problem description]
  - Decision: [Chosen solution]
  - Consequences: [Impact analysis]

## Implementation Roadmap
- Phase 1: Foundation (Week 1-2)
- Phase 2: Core Features (Week 3-6)
- Phase 3: Integration (Week 7-8)
```

---

## 🚀 `/next` - Production Implementation

### Overview
Enforces **production-quality implementation** with strict standards, mandatory validation checkpoints, and a research → plan → implement workflow.

### Key Features
- **Mandatory research phase** before coding
- **Hook-based validation** with zero tolerance
- **Multiple agent coordination** for complex tasks
- **Reality checkpoints** throughout implementation
- **Complete feature delivery** with no shortcuts

### Usage
```bash
claude next
# Follows strict implementation workflow
# Enforces all quality standards
# Validates with hooks before completion
```

### Workflow Stages
1. **Research Phase**
   - Explore codebase patterns
   - Understand dependencies
   - Identify integration points

2. **Planning Phase**
   - Create implementation plan
   - Define validation criteria
   - Set up test strategy

3. **Implementation Phase**
   - Follow established patterns
   - Maintain quality gates
   - Validate continuously

4. **Validation Phase**
   - Run all quality checks
   - Fix any issues
   - Confirm production readiness

### Configuration
```yaml
# Verbosity levels
verbosity_level: "minimal"  # minimal | standard | comprehensive

# Quality enforcement
quality_gates:
  linting: required
  testing: required
  formatting: required
  security: required
```

### Examples
```bash
# Implement user authentication
claude next "implement JWT authentication"

# Add payment processing
claude next "integrate Stripe payment processing"

# Create admin dashboard
claude next "build admin dashboard with React"
```

---

## 📊 `/milestone` - Comprehensive Milestone Management

### Overview
Plans, tracks, and executes project milestones with **hybrid architecture** supporting scale-adaptive storage and progressive UI enhancement.

### Key Features
- **Hybrid tracking system** (file + event log)
- **KIRO workflow integration** (Design → Spec → Task → Execute)
- **Multi-agent decomposition** for planning
- **Scale-adaptive storage** (file → hybrid → database)
- **Resume capability** with `--resume`

### Usage
```bash
# Start new milestone
claude milestone

# Resume from last session
claude milestone --resume

# Quick start mode
claude milestone quickstart

# Check status
claude milestone status
```

### KIRO Workflow Phases
| Phase | Weight | Focus |
|-------|--------|-------|
| **Design** | 15% | Architecture and approach |
| **Spec** | 25% | Detailed specifications |
| **Task** | 20% | Task breakdown and planning |
| **Execute** | 40% | Implementation and delivery |

### Scale-Adaptive Architecture
```yaml
# Automatic scaling based on project size
storage_modes:
  small: "file"        # 1-25 milestones
  medium: "hybrid"     # 25-100 milestones
  large: "database"    # 100+ milestones

ui_modes:
  small: "cli"         # Simple text interface
  medium: "rich_cli"   # Tables and progress bars
  large: "dashboard"   # Web monitoring interface
```

### Sub-Commands

#### `/milestone/plan`
Strategic milestone decomposition with timeline estimation:
```bash
claude milestone plan "Q1 product roadmap"
# Generates comprehensive plan with dependencies
```

#### `/milestone/execute`
5-agent parallel execution with progress tracking:
```bash
claude milestone execute "authentication-feature"
# Executes with real-time progress updates
```

#### `/milestone/status`
6-agent status analysis with visual dashboards:
```bash
claude milestone status --filter active
# Shows comprehensive status report
```

### Session Management
```bash
# Session files in project root
scaffold/plan.md      # Milestone plan
scaffold/state.json   # Progress tracking
.milestone/           # Event logs and state
```

---

## ✅ `/check` - Code Quality Verification

### Overview
Orchestrates **comprehensive quality workflows** using 5 parallel agents for format, cleanup, dedupe, and verify operations.

### Key Features
- **5-agent parallel execution** for quality operations
- **Comprehensive workflow** orchestration
- **Zero tolerance** for quality issues
- **Automatic error fixing** in parallel
- **Complete pipeline validation**

### Usage
```bash
# Run all quality checks
claude check

# Auto-fix detected issues
claude check --fix

# Fast fail mode
claude check --fail-fast
```

### Quality Pipeline Agents
1. **Format Quality Agent** - Code formatting across languages
2. **Cleanup Quality Agent** - Dead code removal
3. **Dedupe Quality Agent** - Duplicate code consolidation
4. **Verify Quality Agent** - Final validation
5. **Quality Coordinator Agent** - Pipeline orchestration

### Quality Operations
```bash
# Format → Cleanup → Dedupe → Verify
Format:  Prettier, Black, gofmt, rustfmt
Cleanup: Remove unused imports, dead code
Dedupe:  Identify and consolidate duplicates
Verify:  Linting, type checking, security
```

### Output Example
```
🔍 Quality Check Results
━━━━━━━━━━━━━━━━━━━━━
✅ Format:  15 files formatted
✅ Cleanup: 8 unused imports removed
✅ Dedupe:  3 duplicate functions consolidated
✅ Verify:  All checks passed

Overall: SUCCESS ✅
```

---

## 🏗️ `/scaffold` - Intelligent Code Generation

### Overview
Creates **complete feature structures** based on project patterns with session intelligence and resume capability.

### Key Features
- **Pattern discovery** from existing codebase
- **Smart file generation** matching conventions
- **Session intelligence** with resume capability
- **Incremental creation** with progress tracking
- **Integration verification**

### Usage
```bash
# Create new feature
claude scaffold "UserProfile"

# Resume previous scaffolding
claude scaffold resume

# Check scaffolding status
claude scaffold status

# Start fresh scaffolding
claude scaffold new
```

### Session Management
```bash
# Session files in project root
scaffold/plan.md      # Scaffolding plan
scaffold/state.json   # Created files tracking
```

### Pattern Detection
The command analyzes:
- Naming conventions
- File structure patterns
- Import patterns
- Testing patterns
- Documentation patterns

### Examples
```bash
# Scaffold a React component
claude scaffold "PaymentForm component"
# Creates: component, styles, tests, stories

# Scaffold an API service
claude scaffold "UserService"
# Creates: service, controller, routes, tests

# Scaffold a full feature
claude scaffold "shopping-cart feature"
# Creates: complete feature structure
```

---

## 🔍 `/understand` - Project Analysis

### Overview
Provides **comprehensive project analysis** to understand architecture, patterns, and component interactions.

### Key Features
- **4-phase discovery process**
- **Native tool integration** (Glob, Read, Grep)
- **Architecture diagram generation**
- **Pattern recognition**
- **Integration point mapping**

### Usage
```bash
claude understand
# Performs complete project analysis
```

### Analysis Phases
1. **Project Discovery**
   - Technology stack identification
   - Project structure mapping
   - Configuration analysis

2. **Architecture Analysis**
   - Entry points identification
   - Module organization
   - Component relationships

3. **Pattern Recognition**
   - Naming conventions
   - Design patterns
   - Code style patterns

4. **Dependency Mapping**
   - Internal dependencies
   - External dependencies
   - Integration points

### Output Structure
```markdown
## Project Overview
- Technology: TypeScript, React, Node.js
- Structure: Monorepo with 3 packages
- Testing: Jest, React Testing Library

## Architecture
- Entry: src/index.tsx
- Modules: auth, dashboard, api
- Patterns: MVC, Repository, Observer

## Key Insights
- Heavy use of dependency injection
- Event-driven architecture
- Comprehensive test coverage
```

---

## 👨‍💻 `/explain-like-senior` - Senior Developer Insights

### Overview
Provides **experienced developer explanations** focusing on the why behind code decisions, trade-offs, and architectural choices.

### Key Features
- **Technical and business context** analysis
- **Experience-driven insights**
- **Mentoring approach**
- **Code evolution perspective**

### Usage
```bash
claude explain-like-senior "auth/jwt-middleware.ts"
# Provides senior-level explanation
```

### Analysis Dimensions
- **Why this approach** over alternatives
- **Performance implications** and bottlenecks
- **Maintenance considerations** over time
- **Business impact** of technical decisions
- **Future evolution** possibilities

### Example Output
```markdown
## Senior Developer Perspective

### Why JWT Instead of Sessions?
This implementation chose JWT for stateless authentication because:
- Horizontal scaling without session store
- Reduced database load (no session lookups)
- Trade-off: Token size vs. database queries

### Performance Considerations
The middleware caches decoded tokens for 5 minutes:
- Prevents redundant JWT verification (expensive)
- Trade-off: Memory usage vs. CPU cycles
- At scale, consider Redis for shared cache

### Maintenance Warning
The refresh token rotation here will cause issues:
- Race conditions under high concurrency
- Consider implementing grace period
- Future: Move to sliding window approach
```

---

## 🔮 `/predict-issues` - Predictive Analysis

### Overview
Performs **predictive code analysis** to identify potential problems before they impact the project.

### Key Features
- **Risk assessment framework** (likelihood × impact)
- **Pattern recognition** for common problems
- **Comprehensive analysis** using native tools
- **Actionable recommendations** with priorities

### Usage
```bash
claude predict-issues
# Analyzes codebase for potential problems
```

### Analysis Categories
| Category | Examples | Risk Level |
|----------|----------|------------|
| **Performance** | O(n²) algorithms, memory leaks | High |
| **Maintainability** | High complexity, tight coupling | Medium |
| **Security** | Validation gaps, weak auth | Critical |
| **Scalability** | Hardcoded limits, bottlenecks | High |

### Risk Assessment Formula
```
Risk Score = Likelihood × Impact × Timeline
- Likelihood: 1-5 (rare to certain)
- Impact: 1-5 (minimal to severe)
- Timeline: 1-5 (years to immediate)
```

### Example Output
```markdown
## Predicted Issues

### 🔴 CRITICAL: SQL Injection Risk
- Location: api/users/search.ts:45
- Likelihood: High (4/5)
- Impact: Severe (5/5)
- Timeline: Immediate
- Fix: Use parameterized queries

### 🟡 HIGH: Performance Bottleneck
- Location: services/report-generator.ts
- Issue: Nested loops creating O(n³) complexity
- Timeline: 3-6 months (as data grows)
- Fix: Implement caching or pagination

### 🟢 MEDIUM: Maintenance Debt
- Location: Multiple files
- Issue: 15 functions > 100 lines
- Timeline: 6-12 months
- Fix: Refactor into smaller functions
```

---

## 🔄 Common Workflows

### Complete Feature Development
```bash
# 1. Design the architecture
claude architect "new feature"

# 2. Plan the milestone
claude milestone

# 3. Generate structure
claude scaffold "feature-name"

# 4. Implement with quality
claude next

# 5. Verify everything
claude check
```

### Codebase Understanding
```bash
# 1. Analyze the project
claude understand

# 2. Get senior insights
claude explain-like-senior "complex-module"

# 3. Predict potential issues
claude predict-issues
```

### Quality Enforcement
```bash
# 1. Run comprehensive checks
claude check

# 2. Fix any issues
claude check --fix

# 3. Verify again
claude check --fail-fast
```

---

## 💡 Best Practices

### Architecture First
Always use `/architect` before implementing complex features to ensure proper design and avoid costly refactoring.

### Milestone Tracking
Use `/milestone` for any feature taking more than a day to implement - the tracking overhead pays off in organization.

### Quality Gates
Run `/check` before every commit to maintain consistent code quality and prevent accumulation of technical debt.

### Pattern Consistency
Use `/scaffold` to maintain consistent patterns across the codebase rather than creating files manually.

### Regular Analysis
Run `/understand` and `/predict-issues` periodically to maintain awareness of codebase health and emerging problems.

---

*Documentation generated from templates/commands/*