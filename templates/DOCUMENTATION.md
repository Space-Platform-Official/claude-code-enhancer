# 📚 Claude Code Templates Documentation

> Comprehensive guide to all templates, commands, agents, and workflows available through `claude-merge`

---

## 🚀 Quick Start

### Installation
```bash
# Install templates to your project
claude-merge

# Templates are copied to .claude/ directory in your project
ls .claude/
```

### Basic Usage
```bash
# Use a command
claude architect        # System design and architecture analysis
claude milestone       # Milestone planning and tracking
claude test           # Run and manage tests

# Spawn an agent
# Use the Task tool with subagent_type parameter
```

---

## 📋 Commands Reference

### Core Development Commands

#### `/architect` - System Architecture & Design
**Purpose**: Design before code - comprehensive architecture analysis with ADR generation
**Key Features**:
- 5 parallel agents for analysis (Domain, Dependencies, Patterns, Risk, Documentation)
- Architecture Decision Records (ADRs) generation
- Multiple solution evaluation with trade-offs
- Implementation roadmaps

**Usage**:
```bash
claude architect
# Triggers comprehensive architecture analysis
# Spawns 5 specialized agents in parallel
# Generates ADRs and implementation plans
```

#### `/next` - Production Implementation
**Purpose**: High-quality implementation with strict standards
**Workflow**: Research → Plan → Implement → Validate
**Key Features**:
- Mandatory quality gates
- Zero-tolerance for errors
- Comprehensive testing
- Hook integration

**Usage**:
```bash
claude next
# Follows strict implementation workflow
# Enforces all quality standards
# Validates with hooks before completion
```

#### `/milestone` - Comprehensive Milestone Management
**Purpose**: Plan, track, and execute project milestones with hybrid architecture
**Key Features**:
- Scale-adaptive storage (File → Hybrid → Database)
- Progressive UI (Simple → Rich → Dashboard)
- Resume capability with `--resume`
- Git integration for persistence
- Kiro workflow integration

**Usage**:
```bash
claude milestone                    # Start new milestone
claude milestone --resume           # Resume from last session
claude milestone quickstart         # Simplified milestone workflow
```

#### `/check` - Code Quality Verification
**Purpose**: Comprehensive quality verification and error fixing
**Features**:
- Linting and formatting
- Type checking
- Test execution
- Automatic fix application

**Usage**:
```bash
claude check              # Run all checks
claude check --fix        # Auto-fix issues
```

#### `/scaffold` - Intelligent Code Generation
**Purpose**: Generate code following existing patterns
**Features**:
- Pattern detection
- Consistency enforcement
- Framework-aware generation

**Usage**:
```bash
claude scaffold component UserProfile    # Generate component
claude scaffold service AuthService      # Generate service
```

### Git Commands

#### `/git/commit` - Smart Commit Creation
**Purpose**: Create well-structured commits with automatic staging
**Features**:
- Automatic file staging
- Commit message generation
- Pre-commit hook integration

**Usage**:
```bash
claude git commit              # Interactive commit
claude git commit -m "fix: resolve auth issue"  # Direct commit
```

#### `/git/pr` - Pull Request Management
**Purpose**: Create and manage pull requests
**Features**:
- PR description generation
- Automatic branch creation
- GitHub CLI integration

**Usage**:
```bash
claude git pr                  # Create PR from current branch
claude git pr --draft          # Create draft PR
```

#### `/git/workflows/*` - Git Workflow Automation
Available workflows:
- `feature` - Feature branch workflow
- `hotfix` - Emergency fix workflow
- `release` - Release management
- `sync` - Branch synchronization

**Usage**:
```bash
claude git workflows feature "new-login"
claude git workflows hotfix "critical-bug"
claude git workflows release "v2.0.0"
```

### Test Commands

#### `/test/unit` - Unit Testing
**Purpose**: Comprehensive unit test management
**Features**:
- Test generation
- Coverage analysis
- Parallel execution

**Usage**:
```bash
claude test unit              # Run unit tests
claude test unit --coverage   # With coverage report
claude test unit --watch      # Watch mode
```

#### `/test/integration` - Integration Testing
**Purpose**: Service and API integration testing
**Features**:
- Service orchestration
- Mock management
- Contract testing

**Usage**:
```bash
claude test integration       # Run integration tests
claude test integration --services db,redis  # Specific services
```

#### `/test/e2e` - End-to-End Testing
**Purpose**: Full application flow testing
**Features**:
- Browser automation
- User journey testing
- Visual regression

**Usage**:
```bash
claude test e2e              # Run E2E tests
claude test e2e --headless   # Headless mode
```

#### `/test/workflows/tdd` - Test-Driven Development
**Purpose**: TDD workflow automation
**Features**:
- Red-Green-Refactor cycle
- Test generation first
- Continuous validation

**Usage**:
```bash
claude test workflows tdd "new-feature"
# Generates failing tests → Implementation → Refactor
```

### Quality Commands

#### `/quality/format` - Code Formatting
**Purpose**: Apply consistent code formatting
**Features**:
- Language-specific formatters
- Import organization
- Whitespace normalization

**Usage**:
```bash
claude quality format         # Format all files
claude quality format --check # Check without modifying
```

#### `/quality/dedupe` - Code Deduplication
**Purpose**: Identify and remove duplicate code
**Features**:
- Pattern detection
- Refactoring suggestions
- DRY principle enforcement

**Usage**:
```bash
claude quality dedupe        # Find duplicates
claude quality dedupe --fix  # Auto-refactor duplicates
```

#### `/quality/verify` - Comprehensive Verification
**Purpose**: Full quality gate verification
**Features**:
- All quality checks
- CI/CD integration
- Report generation

**Usage**:
```bash
claude quality verify        # Run all verifications
claude quality verify --fail-fast  # Stop on first error
```

### Advanced Commands

#### `/ultrathink` - Deep Analysis Mode
**Purpose**: Maximum reasoning for complex problems
**Features**:
- Multiple solution exploration
- Trade-off analysis
- No implementation, pure analysis

**Usage**:
```bash
claude ultrathink
# Triggers deep analysis mode
# Explores multiple approaches
# Provides comprehensive trade-offs
```

#### `/optimize` - Performance Optimization
**Purpose**: Identify and fix performance issues
**Features**:
- Profiling integration
- Bottleneck identification
- Optimization suggestions

**Usage**:
```bash
claude optimize              # Analyze performance
claude optimize --profile    # With profiling data
```

#### `/refactor` - Code Refactoring
**Purpose**: Systematic code improvement
**Features**:
- Pattern application
- Safe transformations
- Test preservation

**Usage**:
```bash
claude refactor              # Interactive refactoring
claude refactor --pattern singleton-to-di  # Specific pattern
```

#### `/security-audit` - Security Analysis
**Purpose**: Comprehensive security vulnerability scanning
**Features**:
- OWASP compliance
- Dependency scanning
- Secret detection

**Usage**:
```bash
claude security-audit        # Full security scan
claude security-audit --fix  # Apply security fixes
```

---

## 🤖 Agents Reference

### Testing Agents

#### `test-orchestrator`
**Purpose**: Adaptive test orchestration with 100% success requirement
**Model**: Claude Sonnet
**Key Capabilities**:
- Parallel test execution
- Failure analysis and retry
- Test suite optimization
- Coverage maximization

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "test-orchestrator"
- prompt: "Achieve 100% test pass rate for the authentication module"
```

#### `unit-test-master`
**Purpose**: Unit test specialist with maximum parallelization
**Model**: Claude Sonnet
**Key Capabilities**:
- Test generation from code
- Mock creation
- Edge case identification
- Fast execution optimization

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "unit-test-master"
- prompt: "Generate comprehensive unit tests for UserService class"
```

#### `integration-test-master`
**Purpose**: Integration testing with service orchestration
**Model**: Claude Sonnet
**Key Capabilities**:
- Service dependency management
- Contract testing
- API testing
- Database integration

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "integration-test-master"
- prompt: "Test payment service integration with external APIs"
```

#### `test-fixer`
**Purpose**: Fix failing tests to achieve 100% pass rate
**Model**: Claude Sonnet
**Key Capabilities**:
- Failure root cause analysis
- Flaky test elimination
- Test refactoring
- Assertion correction

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "test-fixer"
- prompt: "Fix all failing tests in the test suite"
```

### Milestone Agents

#### `milestone-coordinator`
**Purpose**: Workflow orchestration and milestone coordination
**Model**: Claude Sonnet
**Key Capabilities**:
- Multi-agent coordination
- Progress tracking
- Dependency management
- Result aggregation

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "milestone-coordinator"
- prompt: "Coordinate the authentication feature milestone"
```

#### `milestone-planner`
**Purpose**: Strategic planning and milestone decomposition
**Model**: Claude Sonnet
**Key Capabilities**:
- Task breakdown
- Timeline estimation
- Resource allocation
- Risk assessment

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "milestone-planner"
- prompt: "Plan the Q1 product roadmap milestones"
```

#### `milestone-executor`
**Purpose**: Execute milestone tasks with progress tracking
**Model**: Claude Sonnet
**Key Capabilities**:
- Task execution
- Progress reporting
- Blocker identification
- Completion validation

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "milestone-executor"
- prompt: "Execute the database migration milestone tasks"
```

### Code Quality Agents

#### `code-analyzer`
**Purpose**: Comprehensive code analysis and metrics
**Model**: Claude Sonnet
**Key Capabilities**:
- Pattern detection
- Complexity analysis
- Code smell identification
- Metrics generation

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "code-analyzer"
- prompt: "Analyze the codebase for refactoring opportunities"
```

#### `code-quality-enforcer`
**Purpose**: Enforce coding standards and consistency
**Model**: Claude Sonnet
**Key Capabilities**:
- Style enforcement
- Convention checking
- Documentation validation
- Consistency verification

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "code-quality-enforcer"
- prompt: "Enforce TypeScript strict mode across the codebase"
```

#### `quality-enforcer`
**Purpose**: Comprehensive quality gate enforcement
**Model**: Claude Sonnet
**Key Capabilities**:
- Multi-tool quality checks
- Zero-tolerance enforcement
- Report generation
- CI/CD integration

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "quality-enforcer"
- prompt: "Ensure all quality gates pass before deployment"
```

### Infrastructure Agents

#### `orchestrator`
**Purpose**: Master coordination for multi-agent workflows
**Model**: Claude Opus
**Key Capabilities**:
- Agent spawning and coordination
- Result aggregation
- Workflow optimization
- Resource management

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "orchestrator"
- prompt: "Orchestrate a complete feature implementation"
```

#### `git-operator`
**Purpose**: Git operations and conflict resolution
**Model**: Claude Sonnet
**Key Capabilities**:
- Branch management
- Merge conflict resolution
- Commit optimization
- History cleanup

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "git-operator"
- prompt: "Resolve merge conflicts and clean up git history"
```

#### `dependency-manager`
**Purpose**: Dependency updates and security patches
**Model**: Claude Sonnet
**Key Capabilities**:
- Version management
- Security updates
- Compatibility checking
- Lock file management

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "dependency-manager"
- prompt: "Update all dependencies to latest secure versions"
```

#### `api-integration-tester`
**Purpose**: API testing and integration validation
**Model**: Claude Sonnet
**Key Capabilities**:
- Endpoint testing
- Contract validation
- Performance testing
- Mock server management

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "api-integration-tester"
- prompt: "Test all REST API endpoints for the user service"
```

#### `file-processor`
**Purpose**: Bulk file operations and transformations
**Model**: Claude Sonnet
**Key Capabilities**:
- Batch processing
- Format conversion
- Content transformation
- Pattern application

**Spawning Example**:
```markdown
Use Task tool with:
- subagent_type: "file-processor"
- prompt: "Convert all JavaScript files to TypeScript"
```

---

## 🔧 Hooks Integration

### Pre-Commit Hook
**Location**: `templates/hooks/pre-commit.sh`
**Purpose**: Prevent problematic commits
**Checks**:
- Linting validation
- Format verification
- Secret detection
- File size limits

**Installation**:
```bash
# Installed automatically via claude-merge
# Manual installation:
cp .claude/hooks/pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Pre-Push Hook
**Location**: `templates/hooks/pre-push.sh`
**Purpose**: Comprehensive quality gate before sharing
**Checks**:
- All tests pass
- No linting errors
- Security scan clean
- Documentation updated

**Installation**:
```bash
# Installed automatically via claude-merge
# Manual installation:
cp .claude/hooks/pre-push.sh .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

### Claude Edit Hooks
**Purpose**: Enforce standards on Claude Code operations

#### Pre-Edit Hook
**Location**: `templates/hooks/claude-pre-edit-adapter.sh`
**Function**: Validate before Edit/Write operations
**Checks**:
- File permissions
- Content validation
- Pattern compliance

#### Post-Edit Hook
**Location**: `templates/hooks/claude-post-edit-adapter.sh`
**Function**: Auto-apply standards after edits
**Actions**:
- Format code
- Organize imports
- Update documentation

**Configuration**:
```json
{
  "hooks": {
    "pre-edit": ".claude/hooks/claude-pre-edit-adapter.sh",
    "post-edit": ".claude/hooks/claude-post-edit-adapter.sh"
  }
}
```

---

## 🌐 Language & Framework Support

### Language Templates

#### TypeScript
**Location**: `templates/languages/typescript/CLAUDE.md`
**Features**:
- Strict type safety
- Error boundary patterns
- Performance optimizations
- Testing patterns

#### Python
**Location**: `templates/languages/python/CLAUDE.md`
**Features**:
- PEP compliance
- Type hints
- Virtual environment management
- Testing with pytest

#### Go
**Location**: `templates/languages/go/CLAUDE.md`
**Features**:
- Idiomatic patterns
- Concurrency patterns
- Error handling
- Module management

#### Rust
**Location**: `templates/languages/rust/CLAUDE.md`
**Features**:
- Memory safety patterns
- Ownership principles
- Zero-cost abstractions
- Cargo integration

#### JavaScript
**Location**: `templates/languages/javascript/CLAUDE.md`
**Features**:
- Modern ES6+ patterns
- Async/await patterns
- Module systems
- Testing patterns

### Framework Templates

#### React
**Location**: `templates/frameworks/react/CLAUDE.md`
**Features**:
- Component patterns
- Hook usage
- Performance optimization
- Testing strategies

#### Next.js
**Location**: `templates/frameworks/nextjs/CLAUDE.md`
**Features**:
- SSR/SSG patterns
- API routes
- Image optimization
- Deployment strategies

---

## 🚀 Advanced Patterns

### Multi-Agent Coordination

#### 5-Agent Parallel Pattern (Architect Command)
```markdown
Spawning 5 agents simultaneously:
1. Domain Analysis Agent - Business requirements
2. Dependency Mapping Agent - System dependencies
3. Pattern Research Agent - Architectural patterns
4. Risk Assessment Agent - Risk identification
5. Documentation Agent - ADR generation

Coordination through shared state files in /tmp/
```

#### Test Suite Parallelization
```markdown
Parallel test execution pattern:
- Unit Test Agent: Fast, isolated tests
- Integration Test Agent: Service tests
- E2E Test Agent: User journey tests
- Performance Test Agent: Load testing

Results aggregated by Test Orchestrator
```

### Hybrid Architecture Patterns

#### Scale-Adaptive Storage
```markdown
Automatic scaling based on project size:
1. File-based (< 100 items): Simple JSON storage
2. Hybrid (100-1000 items): File + index optimization
3. Database (> 1000 items): Full database migration

Zero-downtime migration between modes
```

#### Progressive UI Enhancement
```markdown
UI complexity scales with project:
1. CLI-only: Simple text interface
2. Rich CLI: Tables and progress bars
3. Web Dashboard: Full monitoring interface

Automatic activation based on scale
```

### Workflow Automation

#### CI/CD Integration
```yaml
# GitHub Actions integration
- uses: anthropics/claude-code-action@v1
  with:
    command: 'quality verify'
    fail-on-error: true
```

#### Git Workflow Automation
```bash
# Feature development workflow
claude git workflows feature "new-feature"
# Automatically:
# - Creates feature branch
# - Sets up PR template
# - Configures CI checks
# - Links to issue tracker
```

---

## 📦 Installation & Distribution

### Using claude-merge

```bash
# Basic installation
claude-merge

# Install specific category
claude-merge --only commands

# Install with configuration
claude-merge --config production

# Update existing templates
claude-merge --update
```

### Template Structure
```
your-project/
├── .claude/
│   ├── commands/      # Installed commands
│   ├── agents/        # Installed agents
│   ├── hooks/         # Active hooks
│   └── CLAUDE.md      # Project configuration
```

### Configuration

#### Project Settings
```json
{
  "templates": {
    "commands": ["architect", "milestone", "test"],
    "agents": ["test-orchestrator", "code-analyzer"],
    "hooks": ["pre-commit", "pre-push"],
    "languages": ["typescript", "python"]
  },
  "workflow": {
    "default": "next",
    "quality": "strict",
    "testing": "comprehensive"
  }
}
```

---

## 🎯 Common Workflows

### Feature Development
```bash
# 1. Architecture design
claude architect

# 2. Milestone planning
claude milestone

# 3. Implementation
claude next

# 4. Testing
claude test unit
claude test integration

# 5. Quality check
claude quality verify

# 6. Commit
claude git commit

# 7. Pull request
claude git pr
```

### Bug Fixing
```bash
# 1. Understand the issue
claude understand

# 2. Predict related issues
claude predict-issues

# 3. Fix with tests
claude test workflows tdd

# 4. Verify fix
claude check --fix

# 5. Commit fix
claude git workflows hotfix
```

### Refactoring
```bash
# 1. Analyze code
claude code scan

# 2. Plan refactor
claude refactor

# 3. Remove duplicates
claude quality dedupe

# 4. Optimize
claude optimize

# 5. Verify
claude quality verify
```

### Documentation
```bash
# 1. Generate docs
claude docs

# 2. Auto-document code
claude workflows documentation auto-docs

# 3. Explain complex code
claude explain-like-senior
```

---

## 🔍 Troubleshooting

### Common Issues

#### Command Not Found
```bash
# Verify installation
ls .claude/commands/

# Reinstall templates
claude-merge --update
```

#### Hook Failures
```bash
# Check hook permissions
ls -la .git/hooks/

# Bypass hook temporarily
SKIP_HOOKS=1 git commit
```

#### Agent Spawn Failures
```markdown
Ensure using Task tool with correct parameters:
- subagent_type: must match agent name
- prompt: clear instructions
- description: brief task summary
```

### Getting Help
```bash
# Command help
claude [command] --help

# View command source
cat .claude/commands/[command].md

# Check logs
cat .claude/logs/claude.log
```

---

## 📚 Additional Resources

### Template Development
- Create new commands in `templates/commands/`
- Add agents in `templates/agents/`
- Follow YAML front matter format
- Test with `claude-merge` locally

### Contributing
- Templates are version controlled
- Follow existing patterns
- Include examples and documentation
- Test across multiple scenarios

### Best Practices
1. **Use appropriate complexity** - Simple tasks shouldn't spawn multiple agents
2. **Follow workflows** - Research → Plan → Implement → Validate
3. **Leverage parallelism** - Spawn multiple agents for independent tasks
4. **Maintain quality** - All checks must pass
5. **Document decisions** - Use ADRs for architectural choices

---

*Last Updated: Auto-generated from templates/*
*Version: Synchronized with claude-merge distribution*