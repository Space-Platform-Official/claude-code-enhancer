# Claude Code Enhancer - Command Reference

Comprehensive command reference for the Claude Code Enhancer project's multi-agent development system. This reference covers all available commands organized by category, with detailed usage examples, parameters, and workflow guidance.

## Quick Navigation

| Category | Commands | Purpose |
|----------|----------|---------|
| [Git Operations](#git-operations) | pr, commit, branch, status, push | Version control and collaboration |
| [Quality Assurance](#quality-assurance) | format, cleanup, dedupe, verify | Code quality and standards |
| [Testing](#testing) | unit, integration, e2e, coverage, performance | Comprehensive testing workflows |
| [Milestone Management](#milestone-management) | plan, execute, status, archive | Project milestone coordination |
| [Core Development](#core-development) | architect, debug, optimize, refactor, review | Core development workflows |
| [File Operations](#file-operations) | consolidate, on-demand, service-split | File optimization and organization |
| [Orchestration](#orchestration) | orchestrate, spawn agents | Multi-agent coordination |
| [Quickstart](#quickstart) | gc, gf, gp, gs | Rapid development shortcuts |

## Command Categories

### Git Operations
Advanced Git workflows with intelligent automation and quality gates.

- **[pr](git/pr.md)** - Comprehensive pull request management with workflow automation
- **[commit](git/commit.md)** - Smart commit creation with quality validation
- **[branch](git/branch.md)** - Intelligent branch management and workflows
- **[status](git/status.md)** - Enhanced Git status with actionable insights
- **[push](git/push.md)** - Safe push operations with validation gates
- **[workflows/](git/workflows/)** - Specialized Git workflow patterns
  - **[feature](git/workflows/feature.md)** - Feature development workflow
  - **[hotfix](git/workflows/hotfix.md)** - Emergency hotfix workflow
  - **[release](git/workflows/release.md)** - Release management workflow
  - **[sync](git/workflows/sync.md)** - Branch synchronization workflow

### Quality Assurance
Comprehensive code quality management with multi-language support.

- **[format](quality/format.md)** - Code formatting and style enforcement
- **[cleanup](quality/cleanup.md)** - Codebase cleanup and optimization
- **[dedupe](quality/dedupe.md)** - Duplicate code detection and removal
- **[verify](quality/verify.md)** - Quality verification and validation

### Testing
Multi-framework testing with parallel execution and comprehensive coverage.

- **[unit](test/unit.md)** - Unit test execution with parallel agent coordination
- **[integration](test/integration.md)** - Integration testing with service orchestration
- **[e2e](test/e2e.md)** - End-to-end testing with browser automation
- **[coverage](test/coverage.md)** - Comprehensive code coverage analysis
- **[performance](test/performance.md)** - Performance testing and benchmarking
- **[fix](test/fix.md)** - Automated test fixing and maintenance
- **[watch](test/watch.md)** - Continuous test watching and execution
- **[workflows/](test/workflows/)** - Specialized testing workflows
  - **[ci](test/workflows/ci.md)** - Continuous integration testing
  - **[debug](test/workflows/debug.md)** - Test debugging workflow
  - **[tdd](test/workflows/tdd.md)** - Test-driven development workflow

### Milestone Management
Project milestone coordination with intelligent planning and execution.

- **[plan](milestone/plan.md)** - Milestone planning with comprehensive analysis
- **[execute](milestone/execute.md)** - Milestone execution with progress tracking
- **[status](milestone/status.md)** - Milestone status monitoring and reporting
- **[archive](milestone/archive.md)** - Milestone archival and documentation
- **[update](milestone/update.md)** - Milestone updates and adjustments

### Core Development
Essential development workflows with multi-agent coordination.

- **[architect](core/architect.md)** - Architecture design and planning
- **[debug](core/debug.md)** - Intelligent debugging with multi-agent analysis
- **[optimize](core/optimize.md)** - Performance optimization workflows
- **[refactor](core/refactor.md)** - Safe refactoring with validation
- **[review](core/review.md)** - Comprehensive code review processes
- **[api-design](core/api-design.md)** - API design and documentation
- **[security-audit](core/security-audit.md)** - Security analysis and auditing

### File Operations
Intelligent file management and optimization.

- **[consolidate](file-optimization/consolidate.md)** - File consolidation and organization
- **[on-demand](file-optimization/on-demand.md)** - On-demand file generation
- **[service-split](file-optimization/service-split.md)** - Service extraction and splitting

### Orchestration
Multi-agent coordination and parallel processing.

- **[orchestrate](orchestration/orchestrate.md)** - General orchestration commands
- **[plan](orchestration/plan.md)** - Orchestration planning
- **[execute](orchestration/execute.md)** - Orchestration execution

### Quickstart
Rapid development shortcuts for common operations.

- **[gc](quickstart/gc.md)** - Quick Git commit
- **[gf](quickstart/gf.md)** - Quick Git format and commit
- **[gp](quickstart/gp.md)** - Quick Git push
- **[gs](quickstart/gs.md)** - Quick Git status

## Multi-Agent Capabilities

The Claude Code Enhancer leverages advanced multi-agent spawning for parallel processing:

### Agent Coordination Patterns

1. **Parallel Execution**: Multiple agents work on independent tasks simultaneously
2. **Hierarchical Coordination**: Master agents coordinate sub-agents for complex operations
3. **Specialized Agents**: Domain-specific agents for testing, quality, security, etc.
4. **Dynamic Spawning**: Agents spawned based on workload and complexity

### Common Agent Patterns

```bash
# Spawn agents for parallel operations
echo "I'll spawn multiple agents to tackle different aspects of this problem"

# Example: Testing with parallel agents
Agent 1: Unit test execution
Agent 2: Integration test orchestration  
Agent 3: Coverage analysis
Agent 4: Performance testing

# Example: Quality assurance with specialized agents
Agent 1: Code formatting and style
Agent 2: Security scanning
Agent 3: Performance analysis
Agent 4: Documentation validation
```

## Command Dependencies and Workflows

### Common Workflow Patterns

1. **Development Workflow**
   ```
   architect → refactor → format → test/unit → test/integration → commit → pr
   ```

2. **Quality Workflow**
   ```
   format → cleanup → dedupe → verify → test/coverage
   ```

3. **Milestone Workflow**
   ```
   milestone/plan → milestone/execute → test/comprehensive → milestone/status
   ```

4. **Release Workflow**
   ```
   verify → test/e2e → git/workflows/release → milestone/archive
   ```

## Command Syntax and Conventions

All commands follow consistent patterns:

```bash
# Basic command execution
/category/command [arguments] [options]

# With multi-agent spawning
/category/command --parallel --agents=4

# With specific targeting
/category/command path/to/target --recursive

# With quality gates
/category/command --strict --verify
```

### Common Parameters

- `--dry-run` - Preview changes without executing
- `--verbose` - Detailed output and logging
- `--parallel` - Enable parallel agent execution
- `--agents=N` - Specify number of agents to spawn
- `--strict` - Enable strict quality validation
- `--force` - Override safety checks (use with caution)

## Error Handling and Recovery

All commands include comprehensive error handling:

1. **Validation Gates**: Pre-execution validation prevents common errors
2. **Safety Snapshots**: Automatic snapshots before destructive operations
3. **Rollback Capabilities**: Safe rollback for failed operations
4. **Agent Coordination**: Intelligent error propagation across agents

## Best Practices

1. **Always validate before execution**: Use `--dry-run` for preview
2. **Leverage multi-agent capabilities**: Enable `--parallel` for performance
3. **Follow workflow patterns**: Use established command sequences
4. **Monitor agent coordination**: Check agent status and coordination
5. **Validate quality gates**: Ensure all quality checks pass

## Getting Help

For detailed help on any command:

```bash
# Command-specific help
/category/command --help

# Category overview
/category/README.md

# Interactive exploration
/help command-explorer
```

## Integration with Development Tools

The command system integrates with:

- **Version Control**: Git, GitHub CLI, GitLab CLI
- **Testing Frameworks**: Jest, pytest, PHPUnit, Go test, RSpec
- **Quality Tools**: ESLint, Prettier, Black, gofmt, PHP-CS-Fixer
- **CI/CD Systems**: GitHub Actions, GitLab CI, Jenkins
- **Development Environments**: VS Code, JetBrains IDEs, Vim/Neovim

---

*This reference covers the complete command system for the Claude Code Enhancer. Each command includes detailed documentation, usage examples, and multi-agent coordination patterns.*