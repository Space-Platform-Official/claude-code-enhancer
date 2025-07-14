# Claude Flow CLI Reference

This document provides a comprehensive reference for all Claude Flow command-line tools and utilities.

## Table of Contents

- [System Installation](#system-installation)
- [Claude Flow Installation](#claude-flow-installation)
- [Smart Merge](#smart-merge)
- [Claude Commands](#claude-commands)
- [Exit Codes](#exit-codes)

## System Installation

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

## Claude Flow Installation

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

## Smart Merge

### claude-merge

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
```