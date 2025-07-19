# Getting Started with Claude Code Enhancer

A comprehensive step-by-step guide to setting up and using the Claude Code Enhancer toolkit for your development projects.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [First Project Setup](#first-project-setup)
- [Basic Usage](#basic-usage)
- [Command Quick Reference](#command-quick-reference)
- [Next Steps](#next-steps)

## Overview

Claude Code Enhancer is a comprehensive toolkit that provides:

- **Smart Templates**: Pre-configured Claude Code templates for multiple languages and frameworks
- **Intelligent Commands**: Production-ready command suite for development workflows
- **Quality Assurance**: Comprehensive code quality tools (format, cleanup, dedupe, verify)
- **Multi-Agent Coordination**: Advanced agent spawning and workflow orchestration
- **Git Integration**: Seamless version control integration with PR and commit tools
- **Testing Framework**: Complete testing infrastructure and automation
- **Milestone Management**: Project planning and execution tracking

## Prerequisites

### System Requirements

- **Operating System**: macOS, Linux, or Windows (WSL)
- **Shell**: Bash 4.0+ (macOS/Linux) or WSL with Bash (Windows)
- **Git**: Version 2.0 or higher
- **Disk Space**: Minimum 50MB for templates and tools

### Development Tools (Optional but Recommended)

Based on your project languages, install relevant tools:

**JavaScript/TypeScript**:
```bash
# Node.js and npm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install --lts

# Essential tools
npm install -g prettier eslint typescript
```

**Python**:
```bash
# Python package managers
pip install black flake8 mypy pytest isort

# Or with conda
conda install black flake8 mypy pytest
```

**Go**:
```bash
# Go tools (usually included with Go installation)
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

## Installation

### Quick Installation (Recommended)

```bash
# Clone the repository
git clone https://github.com/your-org/claude-code-enhancer.git
cd claude-code-enhancer

# Auto-detect and install
./install.sh
```

### Installation Options

#### Option 1: User Installation (Recommended)
Installs to `~/.local/` (no sudo required):

```bash
./install.sh --user
```

**Installed Commands**:
- `claude-install-flow` → `~/.local/bin/`
- `claude-merge` → `~/.local/bin/`
- Templates → `~/.local/share/claude-code-enhancer/`

#### Option 2: System-wide Installation
Installs to `/usr/local/` (requires sudo):

```bash
./install.sh --system
```

#### Option 3: Development Installation
For contributors and advanced users:

```bash
# Use local templates directory
export CLAUDE_TEMPLATES_DIR="$(pwd)/templates"
# Commands will use local templates
```

### Verify Installation

```bash
# Check commands are available
which claude-install-flow
which claude-merge

# Verify template access
claude-install-flow --help
```

### Add to PATH (User Installation)

If commands aren't found, add to your shell profile:

```bash
# For bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# For zsh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## First Project Setup

### Scenario 1: New Project

```bash
# Create new project directory
mkdir my-awesome-project
cd my-awesome-project

# Initialize git repository
git init

# Set up Claude Code templates
claude-install-flow

# Follow interactive prompts to select:
# - Programming language (JavaScript, Python, Go, etc.)
# - Framework (React, Next.js, Django, etc.)
# - Additional features (testing, CI/CD, etc.)
```

**What Gets Created**:
```
my-awesome-project/
├── CLAUDE.md              # Main Claude configuration
├── .claude/               # Command directory
│   └── commands/          # Available commands
│       ├── git/           # Git workflow commands
│       ├── quality/       # Code quality tools
│       ├── test/          # Testing commands
│       └── milestone/     # Project management
└── .gitignore            # Appropriate for selected language
```

### Scenario 2: Existing Project

```bash
# Navigate to existing project
cd /path/to/existing/project

# Smart merge with existing configuration
claude-merge

# This will:
# 1. Detect your project type
# 2. Preserve existing CLAUDE.md settings
# 3. Add new commands and capabilities
# 4. Create backups of original files
```

### Scenario 3: Specific Directory Setup

```bash
# Set up templates in specific directory
claude-install-flow /path/to/target/project

# Or merge into specific directory
claude-merge /path/to/target/project
```

## Basic Usage

### Essential Commands

#### 1. Quality Workflow
The most common workflow for maintaining code quality:

```bash
# Format code consistently
claude format

# Clean up dead code and imports
claude cleanup

# Find and resolve duplicates
claude dedupe

# Verify overall code quality
claude verify

# Or run complete quality workflow
claude format && claude cleanup && claude verify
```

#### 2. Git Workflow
Streamlined git operations with quality checks:

```bash
# Smart commit with quality verification
claude commit "feat: add user authentication"

# Create pull request with quality report
claude pr "Add user authentication feature"

# Check git status and recommendations
claude status
```

#### 3. Testing
Comprehensive testing workflows:

```bash
# Run unit tests
claude test unit

# Run with coverage
claude test coverage

# Run all tests (unit, integration, e2e)
claude test all

# Fix failing tests
claude test fix
```

#### 4. Project Management
Track progress with milestones:

```bash
# Plan new milestone
claude milestone plan "User Authentication Sprint"

# Execute current milestone
claude milestone execute

# Check milestone status
claude milestone status
```

### Command Structure

All commands follow this pattern:
```bash
claude [category] [command] [options]
```

**Categories**:
- `quality/` - Code quality tools (format, cleanup, dedupe, verify)
- `git/` - Git workflow automation
- `test/` - Testing framework
- `milestone/` - Project management
- `quickstart/` - Common shortcuts (gs, gc, gp, gf)

### Interactive vs. Automated Usage

#### Interactive Mode (Default)
Commands prompt for user decisions:
```bash
claude cleanup  # Will ask before removing code
claude dedupe   # Will show duplicates for review
```

#### Automated Mode (CI/CD)
Non-interactive with safe defaults:
```bash
claude format --non-interactive
claude verify --fail-fast
claude cleanup --conservative
```

## Command Quick Reference

### Quality Commands
```bash
# Code formatting
claude format                    # Format all files
claude format src/              # Format specific directory
claude format --dry-run         # Preview changes
claude format --comprehensive   # Multi-pass formatting

# Code cleanup
claude cleanup                  # Standard cleanup
claude cleanup --aggressive     # More thorough cleanup
claude cleanup --imports-only   # Only clean imports
claude cleanup --dry-run        # Preview cleanup

# Duplicate detection
claude dedupe                   # Find duplicates
claude dedupe --interactive     # Manual review mode
claude dedupe --threshold=80    # Set similarity threshold

# Quality verification
claude verify                   # Standard verification
claude verify --comprehensive   # Thorough analysis
claude verify --quick           # Fast syntax check
claude verify --security-only   # Security focus
```

### Git Commands
```bash
# Status and information
claude status                   # Enhanced git status
claude branch                   # Branch management

# Commit workflow
claude commit "message"         # Smart commit with checks
claude push                     # Push with verification

# Pull request workflow
claude pr "title"              # Create PR with quality report
claude pr --draft              # Create draft PR
```

### Testing Commands
```bash
# Run tests
claude test unit               # Unit tests only
claude test integration        # Integration tests
claude test e2e               # End-to-end tests
claude test all               # All test suites

# Test utilities
claude test coverage          # Generate coverage report
claude test fix              # Fix failing tests
claude test watch            # Watch mode for development
```

### Quick Commands
```bash
# Common shortcuts
claude gs                     # Git status
claude gc "message"          # Git commit
claude gp                    # Git push
claude gf                    # Git format (format + commit)
```

## Configuration Examples

### Language-Specific Setup

#### JavaScript/TypeScript Project
```bash
claude-install-flow
# Select: JavaScript > React > Testing > CI/CD

# Results in optimized setup for:
# - ESLint + Prettier formatting
# - Jest + React Testing Library
# - GitHub Actions CI/CD
# - TypeScript support
```

#### Python Project
```bash
claude-install-flow
# Select: Python > Django > Testing > Documentation

# Results in optimized setup for:
# - Black + isort formatting
# - pytest + coverage
# - Sphinx documentation
# - Django-specific commands
```

#### Go Project
```bash
claude-install-flow
# Select: Go > Standard Library > Testing > Benchmarking

# Results in optimized setup for:
# - gofmt + goimports
# - Go test + benchmark tools
# - Module management
# - Performance optimization
```

### Multi-Language Project
```bash
claude-install-flow
# Select: Multi-language > Frontend + Backend

# Creates unified setup for:
# - Multiple language support
# - Coordinated quality workflows
# - Cross-platform CI/CD
# - Integrated testing strategies
```

## Environment Configuration

### Environment Variables

```bash
# Template customization
export CLAUDE_TEMPLATES_DIR="/custom/templates"

# Quality tool configuration
export QUALITY_DEBUG=1              # Enable debug output
export QUALITY_AUTO_BACKUP=true     # Auto-create backups
export QUALITY_PARALLEL=4           # Parallel processing threads

# Git integration
export CLAUDE_GIT_AUTO_STAGE=true   # Auto-stage quality fixes
export CLAUDE_PR_TEMPLATE="custom"  # Use custom PR template
```

### Project-Specific Configuration

Create `.claude-config.json` in your project root:

```json
{
  "default_workflow": "comprehensive",
  "quality": {
    "auto_format": true,
    "verify_on_commit": true,
    "cleanup_aggressiveness": "conservative"
  },
  "git": {
    "auto_stage_fixes": true,
    "require_quality_checks": true
  },
  "testing": {
    "auto_coverage": true,
    "parallel_tests": true,
    "watch_mode": "smart"
  }
}
```

## Troubleshooting Quick Fixes

### Common Issues

**Commands not found**:
```bash
# Check installation
echo $PATH | grep -o '[^:]*\.local/bin[^:]*'

# Reinstall if needed
./install.sh --user
source ~/.bashrc  # or ~/.zshrc
```

**Templates not found**:
```bash
# Check template locations
ls ~/.local/share/claude-code-enhancer/templates
ls /usr/local/share/claude-code-enhancer/templates

# Or use custom templates
export CLAUDE_TEMPLATES_DIR="/path/to/custom/templates"
```

**Permission errors**:
```bash
# For user installation (recommended)
./install.sh --user

# For system installation
sudo ./install.sh --system
```

**Quality tools missing**:
```bash
# JavaScript/TypeScript
npm install -g prettier eslint

# Python
pip install black flake8 mypy

# Go (usually included)
go install golang.org/x/tools/cmd/goimports@latest
```

### Getting Help

```bash
# Command help
claude-install-flow --help
claude-merge --help

# Specific command help
claude verify --help
claude format --help

# Debug mode
export CLAUDE_DEBUG=1
claude verify  # Will show detailed debug information
```

## Next Steps

### Beginner Path
1. **Complete Setup**: Ensure all quality tools are installed for your languages
2. **Practice Workflows**: Try the basic quality workflow on a test project
3. **Explore Commands**: Use `claude [command] --help` to learn options
4. **Read Workflows Guide**: See [workflows.md](workflows.md) for common patterns

### Intermediate Path
1. **Customize Configuration**: Set up `.claude-config.json` for your preferences
2. **Integrate with IDE**: Set up editor integration for real-time feedback
3. **CI/CD Integration**: Add quality checks to your continuous integration
4. **Team Standards**: Establish shared quality standards and workflows

### Advanced Path
1. **Multi-Agent Features**: Learn about agent coordination for complex tasks
2. **Custom Commands**: Create project-specific command templates
3. **Template Development**: Build custom templates for your technology stack
4. **Enterprise Features**: Implement organization-wide quality standards

### Learning Resources

- **[Command Workflows](workflows.md)** - Common development patterns and workflows
- **[Template Guide](using-templates.md)** - Understanding and customizing templates
- **[Quality System](../architecture/quality-system-architecture.md)** - Deep dive into quality tools
- **[Best Practices](best-practices.md)** - Professional tips and recommendations
- **[Troubleshooting](../troubleshooting/)** - Detailed problem-solving guides

### Community and Support

- **Documentation**: Complete guides in the `/docs` directory
- **Examples**: Real-world examples in `/docs/examples`
- **Issues**: Report problems and request features on GitHub
- **Discussions**: Join community discussions for tips and best practices

---

## Summary

You've successfully set up Claude Code Enhancer! Here's what you can do now:

1. **Start with Quality**: Run `claude format && claude verify` on your code
2. **Explore Commands**: Try `claude test unit` and `claude status`
3. **Read Workflows**: Check out common development patterns
4. **Customize Setup**: Add project-specific configuration as needed

The toolkit adapts to your development style and grows with your expertise. Start simple and gradually explore advanced features as you become more comfortable with the system.

**Quick Win**: Run `claude format && claude verify` on your current project to see immediate quality improvements!