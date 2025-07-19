# Claude Code Enhancer CLI Reference

Comprehensive technical reference for all Claude Code Enhancer command-line tools, utilities, and APIs.

## Table of Contents

- [Core CLI Tools](#core-cli-tools)
- [Command System](#command-system)
- [Agent Coordination](#agent-coordination)
- [Template Management](#template-management)
- [Quality Gates](#quality-gates)
- [Git Integration](#git-integration)
- [Hook System](#hook-system)
- [Configuration Management](#configuration-management)
- [Error Handling](#error-handling)
- [Advanced Usage](#advanced-usage)


## Core CLI Tools

### install.sh

The main system installation script for Claude Flow tools.

#### Synopsis

```bash
./install.sh [OPTIONS]
```

#### Description

Installs Claude Flow tools system-wide or for the current user. This script:
- Installs `claude-install-flow` and `claude-merge` commands
- Copies templates to the appropriate location
- Configures PATH if needed

#### Options

| Option | Description |
|--------|-------------|
| `--user` | Install for current user only (~/.local/) |
| `--system` | Install system-wide (/usr/local/) |
| `--uninstall` | Remove Claude Flow tools |
| `--help` | Show help message |

#### Installation Locations

**User Installation:**
- Binaries: `~/.local/bin/`
- Templates: `~/.local/share/claude-flow/templates/`

**System Installation:**
- Binaries: `/usr/local/bin/`
- Templates: `/usr/local/share/claude-flow/templates/`

#### Examples

```bash
# Auto-detect installation type
./install.sh

# Install for current user only
./install.sh --user

# Install system-wide (may require sudo)
./install.sh --system

# Uninstall Claude Flow tools
./install.sh --uninstall
```

#### Exit Codes

- `0` - Success
- `1` - General error (missing files, permissions, etc.)

### claude-install-flow

Installs claude-flow npm package globally and merges Claude templates into a project.

#### Synopsis

```bash
claude-install-flow [target-directory]
```

#### Description

This command:
1. Checks if claude-flow npm package is installed globally
2. Installs it if not present
3. Merges Claude templates into the target directory
4. Creates a merge report

#### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `target-directory` | Directory to install templates into | Current directory |

#### Environment Variables

| Variable | Description |
|----------|-------------|
| `CLAUDE_TEMPLATE_SOURCE` | Override default template source directory |
| `CLAUDE_TEMPLATES_DIR` | Alternative templates directory location |

#### Template Search Order

1. `$CLAUDE_TEMPLATE_SOURCE`
2. `$CLAUDE_TEMPLATES_DIR`
3. `~/.local/share/claude-flow/templates`
4. `/usr/local/share/claude-flow/templates`
5. Script directory

#### Merge Behavior

When merging files, the script offers these options:
- **[k]** Keep existing file
- **[o]** Overwrite with new file
- **[m]** Create .new file for manual merge
- **[s]** Skip this file

#### Output Files

- `claude/CLAUDE.md` - Main Claude configuration
- `claude/templates/` - Language and framework templates
- `claude/.claude/` - Claude commands directory
- `claude/MERGE_REPORT.md` - Detailed merge report

#### Examples

```bash
# Install in current directory
claude-install-flow

# Install in specific project
claude-install-flow /path/to/my-project

# Use custom template source
CLAUDE_TEMPLATE_SOURCE=/my/templates claude-install-flow
```

#### Exit Codes

- `0` - Success
- `1` - Error (npm not found, installation failed, etc.)
- `130` - Interrupted (Ctrl+C)
- `143` - Terminated

### claude-merge (smart-merge-claude.sh)

Smart merge utility for CLAUDE.md files and command setup.

#### Synopsis

```bash
claude-merge [target-directory]
```

#### Description

Intelligently merges CLAUDE.md files and sets up Claude commands:
1. Merges existing CLAUDE.md with template
2. Preserves custom configurations
3. Sets up .claude/commands directory

#### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `target-directory` | Directory to merge into | Current directory |

#### Environment Variables

| Variable | Description |
|----------|-------------|
| `CLAUDE_TEMPLATES_DIR` | Templates directory location |

#### Template Search Order

1. `$CLAUDE_TEMPLATES_DIR`
2. `~/.local/share/claude-flow/templates`
3. `/usr/local/share/claude-flow/templates`
4. `script-dir/templates`

#### Merge Strategy

The merge process:
1. Checks for existing CLAUDE.md in target
2. If exists, creates intelligent merge preserving customizations
3. If not exists, copies template
4. Sets up .claude/commands with all available commands

#### Output Structure

```
target-directory/
├── CLAUDE.md           # Merged configuration
└── .claude/
    └── commands/       # Claude command templates
        ├── api-design.md
        ├── architect.md
        ├── check.md
        └── ...
```

#### Examples

```bash
# Merge into current directory
claude-merge

# Merge into specific project
claude-merge /path/to/project

# Use custom templates directory
CLAUDE_TEMPLATES_DIR=/my/templates claude-merge
```

#### Exit Codes

- `0` - Success
- `1` - Error (directory not found, merge failed, etc.)

## Claude Commands

Once installed, Claude commands are available in the `.claude/commands/` directory of your project. These are markdown templates that Claude can use to perform specific tasks.

### Available Commands

| Command | Description |
|---------|-------------|
| `api-design.md` | API design and documentation |
| `architect.md` | Architecture planning and design |
| `check.md` | Legacy monolithic quality checks |
| `create-command.md` | Create new Claude commands |
| `debug.md` | Debugging assistance |
| `docs.md` | Documentation generation |
| `migrate.md` | Code migration assistance |
| `monitor.md` | Performance monitoring setup |
| `next.md` | Next steps and task planning |
| `optimize.md` | Performance optimization |
| `orchestrate.md` | Multi-component orchestration |
| `prompt.md` | Prompt engineering assistance |
| **Quality Suite** | **Orchestrated quality commands** |
| `quality/format.md` | Code formatting and style enforcement |
| `quality/cleanup.md` | Dead code and import cleanup |
| `quality/dedupe.md` | Duplicate detection and merging |
| `quality/verify.md` | Quality validation and compliance |
| `refactor.md` | Code refactoring |
| `review.md` | Code review |
| `rollback.md` | Rollback procedures |
| `security-audit.md` | Security auditing |
| `test-coverage.md` | Test coverage analysis |
| `upgrade.md` | Dependency upgrades |

### Using Commands

Commands are markdown files that Claude reads to understand specific tasks. To use a command:

1. Reference the command file in your conversation
2. Claude will read and execute the instructions
3. Commands can be customized for your project

### Quality Suite Usage

The new orchestrated quality suite provides specialized commands for different aspects of code quality:

```bash
# Individual quality commands
claude format              # Code formatting and style
claude cleanup             # Dead code and import cleanup
claude dedupe              # Duplicate detection and merging
claude verify              # Quality validation and compliance

# Orchestrated workflows
claude quality             # Complete quality workflow
claude quality --workflow=development  # Development-focused workflow
claude quality --workflow=ci-cd       # CI/CD optimized workflow
claude quality --selective            # Interactive command selection

# Advanced usage
claude format --comprehensive         # Multi-pass formatting
claude cleanup --conservative         # Safe cleanup only
claude dedupe --interactive          # Guided duplicate resolution
claude verify --security-only        # Security-focused verification
```

For detailed usage examples and best practices, see the [Quality Usage Guide](../commands/quality-usage-guide.md) and [Quality System Architecture](../commands/quality-system-architecture.md).

## Exit Codes

### Standard Exit Codes

All Claude Flow scripts follow these standard exit codes:

| Code | Description |
|------|-------------|
| `0` | Success |
| `1` | General error |
| `130` | Script terminated by Ctrl+C (SIGINT) |
| `143` | Script terminated by SIGTERM |

### Error Scenarios

Common error scenarios and their exit codes:

| Scenario | Exit Code | Script |
|----------|-----------|---------|
| Missing source files | `1` | All scripts |
| Permission denied | `1` | install.sh |
| npm not found | `1` | claude-install-flow |
| Target directory not found | `1` | claude-merge |
| Template directory not found | `1` | All scripts |
| Shell environment error | `1` | claude-install-flow |

## Troubleshooting

### Common Issues

**1. Shell Environment Conflicts**

Some version managers (gvm, nvm) can interfere with scripts:

```bash
# Run with explicit bash
/bin/bash claude-install-flow

# Or in clean shell
bash --noprofile --norc
```

**2. PATH Not Updated**

After user installation, you may need to:

```bash
# Add to PATH manually
export PATH="$HOME/.local/bin:$PATH"

# Or source your shell config
source ~/.bashrc  # or ~/.zshrc
```

**3. Permission Errors**

For system installation:

```bash
# Use sudo for system-wide installation
sudo ./install.sh --system
```

**4. Template Not Found**

Check template locations:

```bash
# List possible template locations
echo $CLAUDE_TEMPLATES_DIR
ls ~/.local/share/claude-flow/templates
ls /usr/local/share/claude-flow/templates

## Command System

The Claude Code Enhancer uses a hierarchical command system where commands are markdown files that define specific workflows and behaviors.

### Command Structure

All commands follow a standardized structure:

```yaml
---
allowed-tools: all | specific-tools
description: Command purpose and functionality
---
```

### Command Categories

#### Core Commands
- `architect.md` - Architecture planning and design
- `debug.md` - Debugging assistance and troubleshooting
- `docs.md` - Documentation generation and maintenance
- `migrate.md` - Code migration and refactoring assistance
- `next.md` - Next steps and task planning
- `optimize.md` - Performance optimization
- `prompt.md` - Prompt engineering assistance
- `refactor.md` - Code refactoring workflows
- `review.md` - Code review assistance
- `security-audit.md` - Security auditing and analysis
- `upgrade.md` - Dependency and framework upgrades

#### Git Integration Commands
- `git/branch.md` - Branch management workflows
- `git/commit.md` - Intelligent commit creation
- `git/pr.md` - Pull request generation and management
- `git/push.md` - Safe push operations
- `git/status.md` - Enhanced git status reporting

#### Quality Commands
- `quality/format.md` - Code formatting and style enforcement
- `quality/cleanup.md` - Dead code and import cleanup
- `quality/dedupe.md` - Duplicate detection and merging
- `quality/verify.md` - Quality validation and compliance

#### Test Commands
- `test/unit.md` - Unit test generation and execution
- `test/integration.md` - Integration testing workflows
- `test/e2e.md` - End-to-end testing
- `test/coverage.md` - Test coverage analysis
- `test/performance.md` - Performance testing
- `test/watch.md` - Test watching and continuous execution

#### Milestone Commands
- `milestone/plan.md` - Milestone planning and breakdown
- `milestone/execute.md` - Milestone execution workflows
- `milestone/status.md` - Progress tracking and reporting
- `milestone/archive.md` - Milestone completion and archival

### Command Execution API

Commands can be executed in multiple ways:

#### Direct File Reference
```bash
# Reference command file directly
claude /path/to/.claude/commands/architect.md
```

#### Command Name Resolution
```bash
# Use command name (resolved automatically)
claude architect
claude quality/format
claude test/unit
```

#### Agent Spawning Pattern
Commands support spawning multiple agents for parallel execution:

```markdown
**USE MULTIPLE AGENTS** for comprehensive analysis:
- Spawn one agent to analyze database schema
- Use another agent to examine API endpoints
- Deploy additional agents for testing workflows
```

## Agent Coordination

### Agent Spawning Syntax

The system supports sophisticated agent coordination patterns:

#### Parallel Agent Execution
```markdown
I'll spawn multiple agents to tackle different aspects:
- Agent 1: Database schema analysis
- Agent 2: API endpoint documentation  
- Agent 3: Frontend component mapping
- Agent 4: Test coverage evaluation
```

#### Sequential Agent Workflows
```markdown
Agent coordination sequence:
1. Research agent: Analyze existing patterns
2. Planning agent: Create implementation strategy
3. Implementation agent: Execute changes
4. Validation agent: Verify results
```

#### Specialized Agent Types
- **Research Agents**: Codebase exploration and pattern analysis
- **Implementation Agents**: Code generation and modification
- **Validation Agents**: Quality assurance and testing
- **Integration Agents**: Cross-system coordination

### Agent Communication Protocols

Agents communicate through:
- **Shared State Files**: `.claude/state/`
- **Progress Markers**: Status checkpoints
- **Result Aggregation**: Combined outputs
- **Error Propagation**: Failure handling

## Template Management

### Template Hierarchy

Templates are organized in a hierarchical structure:

```
templates/
├── base/
│   └── CLAUDE.md                    # Base configuration
├── languages/
│   ├── javascript/CLAUDE.md         # JavaScript-specific
│   ├── python/CLAUDE.md             # Python-specific
│   ├── go/CLAUDE.md                 # Go-specific
│   ├── rust/CLAUDE.md               # Rust-specific
│   ├── php/CLAUDE.md                # PHP-specific
│   └── typescript/CLAUDE.md         # TypeScript-specific
├── frameworks/
│   ├── react/CLAUDE.md              # React framework
│   ├── nextjs/CLAUDE.md             # Next.js framework
│   ├── django/                      # Django framework
│   └── express/                     # Express.js framework
└── commands/
    ├── core/                        # Core command templates
    ├── git/                         # Git-related commands
    ├── quality/                     # Quality assurance
    └── test/                        # Testing commands
```

### Template Selection Algorithm

1. **Language Detection**: Analyze project files for language patterns
2. **Framework Detection**: Identify framework-specific patterns
3. **Template Merging**: Combine base + language + framework templates
4. **Customization**: Apply project-specific overrides

### Template Customization API

Templates support parameterization and customization:

#### Variable Substitution
```yaml
# Template variables
project_name: "${PROJECT_NAME}"
main_language: "${DETECTED_LANGUAGE}"
framework: "${DETECTED_FRAMEWORK}"
```

#### Conditional Sections
```markdown
<!-- IF: framework === 'react' -->
React-specific configuration here
<!-- END IF -->

<!-- IF: language === 'typescript' -->
TypeScript-specific setup
<!-- END IF -->
```

## Quality Gates

### Automated Quality Checks

The system enforces quality through multiple gates:

#### Pre-execution Gates
- Template validation
- Configuration verification
- Dependency checking
- Permission validation

#### Execution Gates
- Code formatting (prettier, eslint, etc.)
- Linting rules enforcement
- Test execution requirements
- Security scanning

#### Post-execution Gates
- Result validation
- Integration testing
- Performance benchmarks
- Documentation updates

### Quality Command Integration

Quality gates integrate with the command system:

```bash
# Format code before commit
claude quality/format --pre-commit

# Comprehensive quality check
claude quality/verify --comprehensive

# Cleanup dead code
claude quality/cleanup --aggressive

# Deduplicate code patterns
claude quality/dedupe --interactive
```

### Quality Configuration

Quality standards are configurable through:

```yaml
# .claude/quality.yaml
formatting:
  enabled: true
  tools: [prettier, eslint, black]
  
linting:
  enabled: true
  strict_mode: true
  
testing:
  required_coverage: 80
  enforce_tests: true
  
security:
  scan_dependencies: true
  check_secrets: true
```

## Git Integration

### Git Hook Integration

The system integrates with Git through hooks:

#### Pre-commit Hooks
```bash
#!/bin/sh
# .git/hooks/pre-commit
claude quality/verify --pre-commit
```

#### Post-commit Hooks
```bash
#!/bin/sh
# .git/hooks/post-commit
claude milestone/status --update
```

#### Pre-push Hooks
```bash
#!/bin/sh
# .git/hooks/pre-push
claude test/coverage --enforce
```

### Git Command API

Git integration provides enhanced commands:

#### Intelligent Commits
```bash
# Analyze changes and create contextual commit
claude git/commit

# Create commit with specific template
claude git/commit --template=feature

# Interactive commit with agent assistance
claude git/commit --interactive
```

#### Pull Request Generation
```bash
# Generate PR from current branch
claude git/pr

# Create PR with specific template
claude git/pr --template=feature

# Generate PR with testing checklist
claude git/pr --include-tests
```

#### Branch Management
```bash
# Create feature branch with setup
claude git/branch --type=feature --name=user-auth

# Switch branches with environment sync
claude git/branch --switch=develop --sync-env
```

## Hook System

### Hook Types

The system supports multiple hook types:

#### Command Hooks
- `pre-command`: Execute before command runs
- `post-command`: Execute after command completes
- `error-command`: Execute on command failure

#### File Hooks
- `pre-edit`: Execute before file modifications
- `post-edit`: Execute after file changes
- `pre-create`: Execute before file creation

#### System Hooks
- `pre-install`: Execute before system installation
- `post-install`: Execute after installation
- `pre-upgrade`: Execute before upgrades

### Hook Configuration

Hooks are configured in `.claude/hooks/`:

```yaml
# .claude/hooks/config.yaml
pre-command:
  - script: "./scripts/pre-validate.sh"
    commands: ["architect", "refactor"]
  
post-command:
  - script: "./scripts/update-docs.sh"
    commands: ["git/commit"]
  
pre-edit:
  - script: "./scripts/backup.sh"
    patterns: ["*.md", "*.json"]
```

### Hook Development API

Custom hooks can be developed using:

```bash
#!/bin/bash
# Hook script template

# Environment variables available:
# CLAUDE_COMMAND - Current command being executed
# CLAUDE_TARGET_DIR - Target directory
# CLAUDE_HOOK_TYPE - Type of hook (pre/post/error)

# Hook implementation
case "$CLAUDE_HOOK_TYPE" in
    "pre-command")
        echo "Preparing for $CLAUDE_COMMAND"
        ;;
    "post-command")
        echo "Completed $CLAUDE_COMMAND"
        ;;
    "error-command")
        echo "Error in $CLAUDE_COMMAND"
        exit 1
        ;;
esac
```

## Configuration Management

### Configuration Hierarchy

Configuration is managed through multiple levels:

1. **System Configuration**: `/etc/claude-flow/`
2. **User Configuration**: `~/.config/claude-flow/`
3. **Project Configuration**: `.claude/config/`
4. **Command Configuration**: `.claude/commands/*/config.yaml`

### CLAUDE.md Configuration Format

The main configuration file follows this structure:

```markdown
# Project Configuration

## Development Partnership
Project-specific development guidelines and preferences.

## Complexity Triage System
Complexity classification and management rules.

## File Creation Constraints
File creation policies and limitations.

## Quality Gates Configuration
Quality standards and enforcement rules.

# ========== CLAUDE FLOW TEMPLATE ==========
# Auto-updated: YYYY-MM-DD HH:MM:SS

# Template content from system templates
```

### Environment Variables

The system recognizes these environment variables:

#### Core Configuration
- `CLAUDE_TEMPLATES_DIR` - Template directory location
- `CLAUDE_CONFIG_DIR` - Configuration directory
- `CLAUDE_CACHE_DIR` - Cache directory location
- `CLAUDE_LOG_LEVEL` - Logging verbosity (debug|info|warn|error)

#### Behavior Control
- `CLAUDE_AGENT_LIMIT` - Maximum concurrent agents (default: 5)
- `CLAUDE_TIMEOUT` - Command timeout in seconds (default: 600)
- `CLAUDE_RETRY_COUNT` - Number of retries for failed operations (default: 3)

#### Integration Settings
- `CLAUDE_GIT_INTEGRATION` - Enable/disable Git integration (true|false)
- `CLAUDE_QUALITY_GATES` - Enable/disable quality gates (true|false)
- `CLAUDE_HOOK_SYSTEM` - Enable/disable hook system (true|false)

#### Development Mode
- `CLAUDE_DEV_MODE` - Enable development mode features (true|false)
- `CLAUDE_DEBUG_AGENTS` - Enable agent debugging (true|false)
- `CLAUDE_VERBOSE_OUTPUT` - Enable verbose output (true|false)

## Error Handling

### Exit Code Reference

The system uses standardized exit codes:

#### Success Codes
- `0` - Success (operation completed successfully)

#### General Error Codes  
- `1` - General error (catch-all for general errors)
- `2` - Misuse of shell builtins
- `126` - Command invoked cannot execute
- `127` - Command not found
- `128` - Invalid argument to exit
- `130` - Script terminated by Ctrl+C (SIGINT)
- `143` - Script terminated by SIGTERM

#### Claude-Specific Error Codes
- `10` - Configuration error (invalid CLAUDE.md, missing config)
- `11` - Template error (template not found, invalid template)
- `12` - Command error (command not found, invalid command syntax)
- `13` - Agent coordination error (agent spawn failure, communication failure)
- `14` - Quality gate failure (linting, formatting, test failures)
- `15` - Git integration error (git command failure, merge conflicts)
- `16` - Hook execution error (pre/post hook failures)
- `17` - File operation error (permission denied, disk full)
- `18` - Network error (npm install failure, remote access issues)
- `19` - Timeout error (operation exceeded time limit)

#### Command-Specific Error Codes
- `20-29` - Architecture/Planning errors
- `30-39` - Quality/Testing errors  
- `40-49` - Git/Version control errors
- `50-59` - Template/Configuration errors
- `60-69` - Integration/External tool errors

### Error Handling Strategies

#### Retry Logic
```bash
# Automatic retry for transient failures
claude --retry=3 --retry-delay=5 architect

# Exponential backoff for network operations
claude --retry-strategy=exponential git/pr
```

#### Graceful Degradation
```bash
# Continue on non-critical failures
claude quality/verify --continue-on-error

# Skip unavailable optional features
claude --skip-unavailable test/coverage
```

#### Error Recovery
```bash
# Rollback on failure
claude refactor --rollback-on-error

# Partial completion mode
claude milestone/execute --partial-ok
```

## Advanced Usage

### Batch Operations

Execute multiple commands in sequence:

```bash
# Command chaining
claude architect && claude quality/format && claude test/unit

# Parallel execution
claude architect & claude docs & wait

# Conditional execution
claude quality/verify && claude git/commit || claude debug
```

### Configuration Profiles

Use different configuration profiles:

```bash
# Development profile
claude --profile=dev architect

# Production profile  
claude --profile=prod quality/verify

# Custom profile
claude --profile=./my-profile.yaml refactor
```

### Remote Execution

Execute commands on remote systems:

```bash
# Remote execution via SSH
claude --remote=user@host architect

# Containerized execution
claude --container=node:18 test/unit

# Cloud execution
claude --cloud=aws-lambda quality/verify
```

### Integration APIs

#### CI/CD Integration

```yaml
# .github/workflows/claude.yml
name: Claude Quality Gates
on: [push, pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Claude Quality Gates
        run: |
          claude quality/verify --ci-mode
          claude test/coverage --enforce
```

#### IDE Integration

```json
// .vscode/tasks.json
{
  "tasks": [
    {
      "label": "Claude Architect",
      "type": "shell",
      "command": "claude",
      "args": ["architect"],
      "group": "build"
    },
    {
      "label": "Claude Quality Check",
      "type": "shell", 
      "command": "claude",
      "args": ["quality/verify"],
      "group": "test"
    }
  ]
}
```

#### Build Tool Integration

```json
// package.json
{
  "scripts": {
    "claude:format": "claude quality/format",
    "claude:test": "claude test/unit",
    "claude:docs": "claude docs",
    "precommit": "claude quality/verify --pre-commit"
  }
}
```

### Performance Optimization

#### Caching Strategies
```bash
# Enable aggressive caching
export CLAUDE_CACHE_STRATEGY=aggressive

# Cache-aware execution
claude --use-cache architect

# Cache invalidation
claude --invalidate-cache quality/verify
```

#### Resource Management
```bash
# Limit concurrent agents
export CLAUDE_AGENT_LIMIT=3

# Memory-conscious mode
claude --low-memory test/coverage

# Background execution
claude --background docs &
```

### Security Considerations

#### Secure Mode
```bash
# Restricted permissions mode
claude --secure-mode architect

# Sandbox execution
claude --sandbox refactor

# No network mode
claude --offline quality/format
```

#### Audit Trail
```bash
# Enable audit logging
export CLAUDE_AUDIT_LOG=true

# Audit log location
export CLAUDE_AUDIT_DIR=~/.claude/audit

# View audit trail
claude --show-audit
```