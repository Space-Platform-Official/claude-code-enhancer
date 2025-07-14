# Claude Flow Directory Structure

## Overview

Claude Flow uses a well-organized directory structure that separates system files, templates, and user configurations. This document explains the complete directory layout and the purpose of each component.

## Root Directory Structure

```
claude-flow/
├── install.sh                    # System installer script
├── install-claude-flow.sh        # Template deployment script  
├── smart-merge-claude.sh         # Smart merge utility
├── README.md                     # Project documentation
├── CLAUDE.md                     # Root Claude configuration
├── templates/                    # Template library
├── docs/                         # Documentation
└── test/                         # Test suite
```

## Detailed Directory Breakdown

### Root Level Scripts

#### `install.sh`
- **Purpose**: System-level installation manager
- **Functions**:
  - Detects optimal installation location
  - Creates symbolic links to scripts
  - Sets up template directories
  - Manages PATH configuration

#### `install-claude-flow.sh`
- **Purpose**: Main template deployment tool
- **Functions**:
  - Installs claude-flow npm package
  - Deploys templates to projects
  - Handles file conflicts
  - Generates merge reports

#### `smart-merge-claude.sh`
- **Purpose**: Intelligent configuration merger
- **Functions**:
  - Merges CLAUDE.md files
  - Preserves customizations
  - Deploys command templates

### Templates Directory

```
templates/
├── CLAUDE.md                     # Base configuration template
├── README.md                     # Template documentation
├── base/                         # Base templates
│   └── CLAUDE.md                # Minimal base configuration
├── commands/                     # Claude command templates
│   ├── README.md
│   ├── api-design.md
│   ├── architect.md
│   ├── check.md                 # Legacy monolithic quality check
│   ├── create-command.md
│   ├── debug.md
│   ├── docs.md
│   ├── migrate.md
│   ├── monitor.md
│   ├── next.md
│   ├── optimize.md
│   ├── orchestrate.md
│   ├── prompt.md
│   ├── quality/                 # New orchestrated quality suite
│   │   ├── README.md
│   │   ├── format.md            # Code formatting and style
│   │   ├── cleanup.md           # Dead code and import cleanup
│   │   ├── dedupe.md            # Duplicate detection and merging
│   │   ├── verify.md            # Quality validation and compliance
│   │   └── _shared/             # Shared utilities framework
│   │       ├── utils.md         # Common utility functions
│   │       ├── safety.md        # Safety mechanisms
│   │       └── orchestration.md # Workflow coordination
│   ├── refactor.md
│   ├── review.md
│   ├── rollback.md
│   ├── security-audit.md
│   ├── test-coverage.md
│   └── upgrade.md
├── languages/                    # Language-specific templates
│   ├── go/
│   │   └── CLAUDE.md
│   ├── javascript/
│   │   ├── CLAUDE.md
│   │   └── CLAUDE_ENHANCED.md
│   ├── php/
│   │   ├── CLAUDE.md
│   │   └── CLAUDE_ENHANCED.md
│   ├── python/
│   │   └── CLAUDE.md
│   ├── rust/
│   │   └── CLAUDE.md
│   └── typescript/
│       └── CLAUDE.md
├── frameworks/                   # Framework-specific templates
│   ├── django/
│   ├── express/
│   ├── nextjs/
│   │   └── CLAUDE.md
│   └── react/
│       └── CLAUDE.md
└── workflows/                    # Workflow automation templates
    ├── ci-cd/
    │   └── github-actions.yml
    ├── documentation/
    │   └── auto-docs.md
    └── testing/
        └── test-automation.md
```

### Documentation Directory

```
docs/
├── architecture/                 # Architecture documentation
│   ├── system-overview.md
│   ├── directory-structure.md
│   ├── template-system.md
│   ├── merge-algorithm.md
│   └── design-decisions.md
├── configuration/               # Configuration guides
├── development/                 # Development guides
├── examples/                    # Usage examples
├── getting-started/             # Quick start guides
├── templates/                   # Template documentation
├── troubleshooting/             # Problem solving guides
└── user-guide/                  # User documentation
```

### Test Directory

```
test/
├── README.md                    # Test documentation
├── run-tests.sh                 # Main test runner
├── install-claude-flow-link.sh # Test harness script
├── mock-templates/              # Mock template structure
│   ├── CLAUDE.md
│   └── templates/
│       ├── frameworks/
│       │   └── react/
│       │       └── CLAUDE.md
│       └── languages/
│           └── python/
│               └── CLAUDE.md
└── test-projects/               # Test scenarios
    ├── fresh-install/           # Clean installation test
    │   └── CLAUDE.md
    ├── idempotent-test/         # Idempotency verification
    ├── merge-test/              # Merge functionality test
    │   └── CLAUDE.md
    └── options-test/            # Option handling test
```

## Installation Locations

### System Installation (`/usr/local/`)

```
/usr/local/
├── bin/
│   ├── claude-install-flow      # Symlink to install script
│   └── claude-merge             # Symlink to merge script
└── share/
    └── claude-flow/
        └── templates/           # System template library
```

### User Installation (`~/.local/`)

```
~/.local/
├── bin/
│   ├── claude-install-flow      # Symlink to install script
│   └── claude-merge             # Symlink to merge script
└── share/
    └── claude-flow/
        └── templates/           # User template library
```

## Project Directory Structure (After Installation)

When Claude Flow is installed in a project, it creates:

```
project-root/
├── claude/                      # Claude configuration directory
│   ├── CLAUDE.md               # Main Claude configuration
│   ├── MERGE_REPORT.md         # Installation/merge report
│   └── templates/              # Project-specific templates
│       ├── commands/           # Command templates
│       ├── languages/          # Language configurations
│       ├── frameworks/         # Framework configurations
│       └── workflows/          # Workflow templates
└── .claude/                    # Hidden Claude directory
    └── commands/               # Active command set
```

## File Types and Purposes

### Configuration Files (`CLAUDE.md`)

- **Location**: Multiple levels (root, language, framework)
- **Purpose**: Define Claude's behavior and guidelines
- **Inheritance**: Templates can extend base configurations

### Command Files (`*.md` in commands/)

- **Location**: `templates/commands/` and `.claude/commands/`
- **Purpose**: Reusable command patterns for Claude
- **Usage**: Referenced during development sessions

### Workflow Files

- **Location**: `templates/workflows/`
- **Purpose**: Automation templates and CI/CD configurations
- **Format**: YAML, Markdown, or shell scripts

## Directory Search Order

Claude Flow searches for templates in this order:

1. `$CLAUDE_TEMPLATES_DIR` (if set)
2. `$CLAUDE_TEMPLATE_SOURCE` (legacy support)
3. `~/.local/share/claude-flow/templates`
4. `/usr/local/share/claude-flow/templates`
5. Local `templates/` directory (development mode)

## Best Practices

### 1. Template Organization

- Keep language-specific configs in `languages/`
- Place framework configs in `frameworks/`
- Store reusable commands in `commands/`

### 2. Custom Templates

- Create custom templates in user installation
- Override system templates locally
- Use environment variables for special locations

### 3. Project Structure

- Keep Claude configs in `claude/` directory
- Use `.claude/` for active runtime configs
- Don't commit `.new` files (conflict markers)

### 4. Version Control

- Commit `claude/CLAUDE.md` for team consistency
- Include selected templates
- Exclude temporary files and reports

## File Naming Conventions

### Templates
- `CLAUDE.md` - Standard configuration name
- `CLAUDE_ENHANCED.md` - Extended configurations
- `*.md` - Markdown for all documentation

### Scripts
- Lowercase with hyphens: `install-claude-flow.sh`
- Descriptive names indicating function
- `.sh` extension for shell scripts

### Directories
- Lowercase, no spaces
- Hyphens for multi-word names
- Logical grouping by function

This directory structure provides a clean, extensible foundation for Claude Flow while maintaining clarity and ease of navigation.