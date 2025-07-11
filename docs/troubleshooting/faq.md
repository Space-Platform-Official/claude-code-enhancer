# Frequently Asked Questions - Claude Flow

This FAQ addresses common questions about Claude Flow installation, usage, and troubleshooting.

## Table of Contents

1. [General Questions](#general-questions)
2. [Installation Questions](#installation-questions)
3. [Usage Questions](#usage-questions)
4. [Template Questions](#template-questions)
5. [Troubleshooting Questions](#troubleshooting-questions)
6. [Advanced Questions](#advanced-questions)

## General Questions

### What is Claude Flow?

Claude Flow is a comprehensive toolkit for setting up Claude Code configurations and development workflows. It provides:
- Pre-configured templates for multiple languages and frameworks
- Smart merging capabilities for existing projects
- Command templates for common development tasks
- Automated setup and installation scripts

### What are the system requirements?

**Minimum Requirements:**
- Bash 4.0 or higher
- Git
- Node.js and npm (for claude-flow package)
- Unix-like environment (Linux, macOS, WSL)

**Recommended:**
- 100MB free disk space
- Write access to ~/.local or /usr/local
- Terminal with color support

### Is Claude Flow free to use?

Yes, Claude Flow is open-source and free to use under the MIT License.

### How does Claude Flow differ from claude-flow npm package?

- **Claude Flow** (this toolkit): Bash-based template system for Claude Code configuration
- **claude-flow npm package**: Node.js package that may provide additional functionality
- They can work together but serve different purposes

## Installation Questions

### Should I use system or user installation?

**User Installation (Recommended)**
- Use when: Personal machine, no admin access, testing
- Location: ~/.local/bin and ~/.local/share
- Command: `./install.sh --user`

**System Installation**
- Use when: Shared server, multiple users need access
- Location: /usr/local/bin and /usr/local/share
- Command: `sudo ./install.sh --system`

### How do I update Claude Flow?

```bash
# Option 1: Pull latest and reinstall
git pull origin main
./install.sh --uninstall
./install.sh --user  # or --system

# Option 2: Update in place
git pull origin main
# Templates are automatically updated
```

### Can I install Claude Flow without Git?

Yes, download the release archive:
```bash
# Download release
wget https://github.com/your-org/claude-flow/archive/main.zip
unzip main.zip
cd claude-flow-main
./install.sh --user
```

### How do I uninstall Claude Flow completely?

```bash
# Automated uninstall
./install.sh --uninstall

# Manual uninstall if script not available
rm -f ~/.local/bin/claude-install-flow
rm -f ~/.local/bin/claude-merge
rm -rf ~/.local/share/claude-flow
rm -f /usr/local/bin/claude-install-flow
rm -f /usr/local/bin/claude-merge
rm -rf /usr/local/share/claude-flow
```

## Usage Questions

### How do I use Claude Flow with an existing project?

```bash
# Navigate to your project
cd /path/to/your/project

# Run smart merge
claude-merge

# Choose merge strategy for conflicts:
# - [k] to keep your existing configuration
# - [m] to create .new files for manual merge
# - [o] to overwrite (not recommended for existing projects)
```

### Can I use custom templates?

Yes, several ways:

**Method 1: Environment Variable**
```bash
export CLAUDE_TEMPLATES_DIR="/path/to/custom/templates"
claude-install-flow
```

**Method 2: Local Templates**
```bash
mkdir -p ./my-templates
cp -r ~/.local/share/claude-flow/templates/* ./my-templates/
# Customize templates
vim ./my-templates/CLAUDE.md
# Use them
CLAUDE_TEMPLATES_DIR="./my-templates" claude-install-flow
```

### How do I select specific language/framework templates?

Currently, template selection is interactive. Future versions may support:
```bash
# Planned features (not yet implemented)
claude-install-flow --language=python --framework=django
claude-install-flow --template=react-typescript
```

### Can I use Claude Flow in CI/CD pipelines?

Yes, with non-interactive mode:
```bash
# Set up for CI/CD
export CLAUDE_NONINTERACTIVE=1
export CLAUDE_MERGE_STRATEGY="keep"  # or "overwrite"
claude-install-flow
```

## Template Questions

### What templates are included?

**Languages:**
- JavaScript/TypeScript
- Python
- Go
- Rust
- PHP

**Frameworks:**
- React
- Next.js
- Django
- Express.js

**Commands:**
- architect.md - System architecture planning
- debug.md - Debugging assistance
- optimize.md - Performance optimization
- refactor.md - Code refactoring
- review.md - Code review
- test-coverage.md - Testing strategies

### How do I add a new language template?

```bash
# Create language directory
mkdir -p ~/.local/share/claude-flow/templates/languages/ruby

# Create CLAUDE.md for the language
cat > ~/.local/share/claude-flow/templates/languages/ruby/CLAUDE.md << 'EOF'
# Ruby Development with Claude

## Language-Specific Guidelines
- Follow Ruby style guide
- Use RuboCop for linting
- Prefer symbols over strings for hash keys
# ... add more Ruby-specific rules
EOF
```

### Can templates include project-specific files?

Yes, templates can include any files:
```bash
# Example template structure
templates/languages/python/
├── CLAUDE.md
├── .claude/
│   └── commands/
│       └── python-specific.md
├── .gitignore
├── requirements.txt
└── setup.py
```

### How do I share templates with my team?

**Option 1: Git Repository**
```bash
# Create team templates repo
git init team-claude-templates
cp -r ~/.local/share/claude-flow/templates/* team-claude-templates/
git add .
git commit -m "Initial team templates"
git remote add origin https://github.com/team/claude-templates
git push -u origin main

# Team members use:
export CLAUDE_TEMPLATES_DIR="/path/to/team-claude-templates"
```

**Option 2: Shared Network Drive**
```bash
# Copy to shared location
cp -r ~/.local/share/claude-flow/templates /shared/team/claude-templates

# Team members:
export CLAUDE_TEMPLATES_DIR="/shared/team/claude-templates"
```

## Troubleshooting Questions

### Why do I get "command not found" after installation?

The PATH hasn't been updated. Solutions:

```bash
# 1. Reload shell configuration
source ~/.bashrc  # or ~/.zshrc

# 2. Start new shell
exec $SHELL

# 3. Manually add to PATH
export PATH="$HOME/.local/bin:$PATH"
```

### How do I debug installation issues?

```bash
# Enable debug mode
bash -x ./install.sh --user 2>&1 | tee install-debug.log

# Check specific issues
grep -i error install-debug.log
grep -i warning install-debug.log

# Verify installation
ls -la ~/.local/bin/claude-*
ls -la ~/.local/share/claude-flow/
```

### What if templates are not found?

Check template search order:
```bash
# Show what's being searched
echo "CLAUDE_TEMPLATE_SOURCE: ${CLAUDE_TEMPLATE_SOURCE:-not set}"
echo "CLAUDE_TEMPLATES_DIR: ${CLAUDE_TEMPLATES_DIR:-not set}"

# Check standard locations
for dir in ~/.local/share/claude-flow/templates /usr/local/share/claude-flow/templates; do
    [ -d "$dir" ] && echo "Found: $dir" || echo "Missing: $dir"
done
```

### How do I handle merge conflicts?

See [Merge Conflicts Guide](merge-conflicts.md) for detailed information.

Quick answer:
- `[k]` - Keep your version (safe for existing projects)
- `[m]` - Create .new file for manual merge (recommended)
- `[o]` - Overwrite with template (only for new projects)
- `[s]` - Skip file entirely

## Advanced Questions

### Can I use Claude Flow with Docker?

Yes, example Dockerfile:
```dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y bash git
COPY . /claude-flow
WORKDIR /claude-flow
RUN ./install.sh --system
# Templates now available system-wide
```

### How do I integrate with VS Code?

Add to VS Code settings.json:
```json
{
  "terminal.integrated.env.linux": {
    "CLAUDE_TEMPLATES_DIR": "${env:HOME}/.local/share/claude-flow/templates"
  },
  "terminal.integrated.env.osx": {
    "CLAUDE_TEMPLATES_DIR": "${env:HOME}/.local/share/claude-flow/templates"
  }
}
```

### Can I automate template updates?

```bash
# Create update script
cat > ~/bin/update-claude-flow << 'EOF'
#!/bin/bash
cd ~/claude-flow
git pull origin main
./install.sh --user
echo "Claude Flow updated successfully"
EOF

chmod +x ~/bin/update-claude-flow

# Add to cron for weekly updates
(crontab -l ; echo "0 0 * * 0 ~/bin/update-claude-flow") | crontab -
```

### How do I contribute to Claude Flow?

1. Fork the repository
2. Create feature branch
3. Add your templates/features
4. Run tests: `cd test && ./run-tests.sh`
5. Submit pull request

### Can I use environment-specific configurations?

Yes, use environment detection:
```bash
# In your CLAUDE.md or scripts
if [[ "$CLAUDE_ENV" == "production" ]]; then
    # Production-specific settings
elif [[ "$CLAUDE_ENV" == "development" ]]; then
    # Development-specific settings
fi
```

### How do I report bugs or request features?

1. Check existing issues on GitHub
2. Create new issue with:
   - Clear description
   - Steps to reproduce
   - System information
   - Expected vs actual behavior
   - Error messages/logs

### Where can I get more help?

1. Read the comprehensive guides:
   - [Common Issues](common-issues.md)
   - [Installation Problems](installation-problems.md)
   - [Template Issues](template-issues.md)
   - [Merge Conflicts](merge-conflicts.md)
   - [Debugging Guide](debugging.md)

2. Check GitHub discussions and issues

3. Contact support with:
   - Debug logs
   - System information
   - Specific error messages