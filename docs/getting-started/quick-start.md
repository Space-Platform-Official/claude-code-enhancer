# Quick Start Guide

Get up and running with Claude Flow in just a few minutes. This guide covers the essential commands and workflows.

## Installation Summary

If you haven't installed Claude Flow yet:

```bash
git clone https://github.com/your-repo/claude-flow.git
cd claude-flow
./install.sh
```

## Basic Commands

Claude Flow provides two main commands:

### 1. `claude-install-flow` - Set up Claude templates

```bash
# Install in current directory
claude-install-flow

# Install in specific directory
claude-install-flow /path/to/project
```

### 2. `claude-merge` - Smart merge configurations

```bash
# Merge in current directory
claude-merge

# Merge in specific directory
claude-merge /path/to/project
```

## Quick Start Workflows

### Workflow 1: New Project Setup

Setting up Claude Flow for a brand new project:

```bash
# 1. Create your project directory
mkdir my-awesome-project
cd my-awesome-project

# 2. Initialize git (optional but recommended)
git init

# 3. Install Claude Flow templates
claude-install-flow

# 4. Select your language/framework when prompted
# Example: Select "1" for JavaScript/TypeScript

# 5. Verify installation
ls -la .claude/
cat CLAUDE.md
```

**Result**: Your project now has:
- `CLAUDE.md` - AI assistant configuration
- `.claude/commands/` - Specialized command templates
- Language-specific best practices

### Workflow 2: Add to Existing Project

Adding Claude Flow to an existing project:

```bash
# 1. Navigate to your project
cd /path/to/existing-project

# 2. Run smart merge (preserves existing configs)
claude-merge

# 3. Review the merged configuration
cat CLAUDE.md

# 4. Check new commands
ls .claude/commands/
```

**Result**: Your existing project configurations are preserved while gaining Claude Flow features.

### Workflow 3: Team Project Setup

Setting up Claude Flow for team collaboration:

```bash
# 1. Clone team repository
git clone https://github.com/team/project.git
cd project

# 2. Install Claude Flow
claude-install-flow

# 3. Commit Claude configuration
git add CLAUDE.md .claude/
git commit -m "Add Claude Flow configuration"
git push
```

**Team members can then**:
```bash
git pull
# Claude configuration is now shared!
```

## Example Use Cases

### JavaScript/TypeScript Project

```bash
# Create new React project
npx create-react-app my-app
cd my-app

# Add Claude Flow
claude-install-flow

# When prompted, select:
# Language: JavaScript/TypeScript
# Framework: React

# Start using Claude commands
cat .claude/commands/debug.md      # Debugging help
cat .claude/commands/optimize.md   # Performance tips
```

### Python Project

```bash
# Create new Python project
mkdir python-api
cd python-api
python -m venv venv

# Add Claude Flow
claude-install-flow

# Select: Language: Python
# Framework: FastAPI (or Django, Flask, etc.)

# Review Python-specific configuration
cat CLAUDE.md
```

### Multi-Language Project

```bash
# For projects with multiple languages
claude-install-flow

# Select: Multiple/Other
# This installs generic templates suitable for any project
```

## Understanding the Structure

After installation, your project will have:

```
your-project/
├── CLAUDE.md                 # Main AI configuration
├── .claude/
│   └── commands/            # Command templates
│       ├── architect.md     # Architecture planning
│       ├── debug.md         # Debugging assistance
│       ├── optimize.md      # Performance optimization
│       ├── refactor.md      # Code refactoring
│       ├── review.md        # Code review
│       └── test-coverage.md # Testing strategies
└── [your project files]
```

## Using Claude Commands

The `.claude/commands/` directory contains specialized prompts:

### Architecture Planning
```bash
# When starting a new feature
cat .claude/commands/architect.md
# Copy content to Claude to get architecture advice
```

### Debugging Help
```bash
# When stuck on a bug
cat .claude/commands/debug.md
# Use with Claude to debug systematically
```

### Code Review
```bash
# Before committing code
cat .claude/commands/review.md
# Get AI-powered code review suggestions
```

## Quick Tips

### 1. Check Available Templates

See what templates are available:
```bash
ls ~/.local/share/claude-flow/templates/languages/
ls ~/.local/share/claude-flow/templates/frameworks/
```

### 2. Update Existing Configuration

Re-run to update or change configuration:
```bash
claude-install-flow
# Select new options to update
```

### 3. Merge with Custom Settings

If you have custom CLAUDE.md settings:
```bash
# Your custom settings are preserved with smart merge
claude-merge
```

### 4. Environment Variables

Customize behavior:
```bash
# Use custom templates
export CLAUDE_TEMPLATES_DIR="/my/custom/templates"
claude-install-flow
```

## Common Patterns

### Pattern 1: Feature Development

```bash
# 1. Plan architecture
cat .claude/commands/architect.md > feature-plan.md
# Edit feature-plan.md with your requirements

# 2. Implement with AI assistance
# Use CLAUDE.md configuration for context

# 3. Review and optimize
cat .claude/commands/review.md
cat .claude/commands/optimize.md
```

### Pattern 2: Debugging Session

```bash
# 1. Describe the bug
cat .claude/commands/debug.md > bug-report.md
# Add specific error details

# 2. Get systematic debugging help
# Follow the debugging framework
```

### Pattern 3: Code Refactoring

```bash
# 1. Identify refactoring needs
cat .claude/commands/refactor.md

# 2. Plan refactoring approach
# 3. Execute with AI guidance
```

## Verification Checklist

After setup, verify:

- [ ] `CLAUDE.md` exists and contains your configuration
- [ ] `.claude/commands/` directory has command templates  
- [ ] Commands are accessible: `which claude-install-flow`
- [ ] Templates match your project type
- [ ] Git ignores are set up correctly (if using Git)

## Next Steps

Now that you're up and running:

1. **Explore Commands**: Browse `.claude/commands/` for all available AI prompts
2. **Customize**: Edit `CLAUDE.md` to add project-specific context
3. **Learn More**: 
   - [First Project Tutorial](first-project.md) - Detailed walkthrough
   - [Configuration Guide](configuration.md) - Advanced settings
   - [Command Templates](../commands/README.md) - Full command reference

## Getting Help

- Run with `--help` flag: `claude-install-flow --help`
- Enable debug mode: `CLAUDE_DEBUG=1 claude-install-flow`
- Check the [troubleshooting guide](installation.md#troubleshooting)