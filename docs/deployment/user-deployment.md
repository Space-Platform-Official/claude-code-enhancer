# Claude Flow User Deployment Guide

## Overview

This guide covers deploying Claude Flow for individual users without system-wide installation privileges.

## Prerequisites

- User account with home directory access
- Git installed
- Bash 4.0+ or Zsh
- At least 100MB free disk space in home directory

## User Installation

### 1. Quick Install

```bash
# One-line installer
curl -sSL https://get.claude-flow.io | bash

# Or manual installation
git clone https://github.com/your-org/claude-flow.git ~/.claude-flow
~/.claude-flow/install.sh --user
```

### 2. Manual Installation

```bash
# Create installation directory
CLAUDE_HOME="$HOME/.claude-flow"
mkdir -p "$CLAUDE_HOME"

# Clone repository
git clone https://github.com/your-org/claude-flow.git "$CLAUDE_HOME"

# Create user directories
mkdir -p "$HOME/.claude"/{commands,templates,config,cache}
```

### 3. Shell Configuration

Add to your shell configuration file:

#### Bash (~/.bashrc)

```bash
# Claude Flow User Configuration
export CLAUDE_FLOW_HOME="$HOME/.claude-flow"
export CLAUDE_USER_DIR="$HOME/.claude"
export PATH="$CLAUDE_FLOW_HOME/bin:$PATH"

# Optional: Aliases
alias cf="claude-flow"
alias cfl="claude-flow list"
alias cfr="claude-flow run"

# Auto-completion
if [ -f "$CLAUDE_FLOW_HOME/completions/claude-flow.bash" ]; then
    source "$CLAUDE_FLOW_HOME/completions/claude-flow.bash"
fi
```

#### Zsh (~/.zshrc)

```bash
# Claude Flow User Configuration
export CLAUDE_FLOW_HOME="$HOME/.claude-flow"
export CLAUDE_USER_DIR="$HOME/.claude"
export PATH="$CLAUDE_FLOW_HOME/bin:$PATH"

# Optional: Aliases
alias cf="claude-flow"
alias cfl="claude-flow list"
alias cfr="claude-flow run"

# Auto-completion
if [ -f "$CLAUDE_FLOW_HOME/completions/claude-flow.zsh" ]; then
    source "$CLAUDE_FLOW_HOME/completions/claude-flow.zsh"
fi
```

### 4. Initial Configuration

```bash
# Initialize user configuration
claude-flow init

# This creates:
# - ~/.claude/config/settings.json
# - ~/.claude/config/preferences.json
# - ~/.claude/templates/ (with defaults)
# - ~/.claude/commands/ (empty)
```

## User Directory Structure

```
~/.claude-flow/           # Application installation
├── bin/                  # Executables
├── lib/                  # Core libraries
├── templates/            # Default templates
└── docs/                 # Documentation

~/.claude/                # User data and configuration
├── commands/             # User's custom commands
├── templates/            # User's custom templates
├── config/              # User configuration
│   ├── settings.json    # Main settings
│   ├── preferences.json # UI preferences
│   └── api-keys.json    # API credentials (encrypted)
├── cache/               # Temporary cache
└── logs/                # User activity logs
```

## Configuration

### 1. Basic Settings

Edit `~/.claude/config/settings.json`:

```json
{
  "user": {
    "name": "Your Name",
    "email": "your.email@example.com"
  },
  "editor": {
    "command": "vim",
    "args": ["-n"]
  },
  "display": {
    "theme": "auto",
    "color": true,
    "icons": true
  },
  "behavior": {
    "confirmDestructive": true,
    "autoUpdate": true,
    "telemetry": false
  }
}
```

### 2. API Configuration

```bash
# Set up API keys securely
claude-flow config set-api-key

# Or manually edit ~/.claude/config/api-keys.json
{
  "openai": {
    "key": "sk-...",
    "encrypted": true
  },
  "anthropic": {
    "key": "sk-ant-...",
    "encrypted": true
  }
}
```

### 3. Custom Templates

Add personal templates:

```bash
# Copy and modify existing template
cp ~/.claude-flow/templates/basic.md ~/.claude/templates/my-template.md

# Edit template
$EDITOR ~/.claude/templates/my-template.md

# Use custom template
claude-flow new --template my-template
```

## Portable Installation

### 1. USB/Portable Drive Setup

```bash
# Install to portable drive
PORTABLE_DIR="/Volumes/USB/claude-flow"
git clone https://github.com/your-org/claude-flow.git "$PORTABLE_DIR"

# Create portable launcher
cat > "$PORTABLE_DIR/claude-portable.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CLAUDE_FLOW_HOME="$SCRIPT_DIR"
export CLAUDE_USER_DIR="$SCRIPT_DIR/userdata"
export PATH="$CLAUDE_FLOW_HOME/bin:$PATH"

# Create user directories if needed
mkdir -p "$CLAUDE_USER_DIR"/{commands,templates,config,cache}

# Run Claude Flow
exec "$CLAUDE_FLOW_HOME/bin/claude-flow" "$@"
EOF

chmod +x "$PORTABLE_DIR/claude-portable.sh"
```

### 2. Cloud Sync Setup

Sync configuration across devices:

```bash
# Using symbolic links with cloud storage
mv ~/.claude ~/Dropbox/claude-flow-config
ln -s ~/Dropbox/claude-flow-config ~/.claude

# Or using git for config
cd ~/.claude
git init
git add config templates commands
git commit -m "Initial config"
git remote add origin git@github.com:username/claude-flow-config.git
git push -u origin main
```

## Integration

### 1. Editor Integration

#### VS Code

```json
// .vscode/settings.json
{
  "terminal.integrated.env.osx": {
    "CLAUDE_FLOW_HOME": "${env:HOME}/.claude-flow"
  },
  "terminal.integrated.env.linux": {
    "CLAUDE_FLOW_HOME": "${env:HOME}/.claude-flow"
  }
}
```

#### Vim

```vim
" ~/.vimrc
" Claude Flow integration
command! ClaudeNew :!claude-flow new %
command! ClaudeRun :!claude-flow run %
```

### 2. Git Integration

```bash
# Git aliases for Claude Flow
git config --global alias.claude '!claude-flow git'
git config --global alias.cf-commit '!claude-flow git commit'
```

## Updates

### 1. Manual Update

```bash
cd ~/.claude-flow
git pull origin main
./install.sh --user --update
```

### 2. Auto-Update

Enable in settings:

```json
{
  "behavior": {
    "autoUpdate": true,
    "updateChannel": "stable"
  }
}
```

### 3. Update Script

```bash
# Create update script
cat > ~/bin/update-claude-flow << 'EOF'
#!/bin/bash
echo "Updating Claude Flow..."
cd ~/.claude-flow
git fetch origin
git checkout main
git pull origin main
echo "Update complete!"
claude-flow --version
EOF

chmod +x ~/bin/update-claude-flow
```

## Backup

### 1. Backup Script

```bash
#!/bin/bash
# ~/.claude/backup.sh

BACKUP_DIR="$HOME/backups/claude-flow"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/claude-backup-$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

# Backup user data
tar -czf "$BACKUP_FILE" \
    -C "$HOME" \
    .claude/commands \
    .claude/templates \
    .claude/config \
    --exclude=.claude/cache \
    --exclude=.claude/logs

echo "Backup created: $BACKUP_FILE"

# Keep only last 10 backups
ls -t "$BACKUP_DIR"/claude-backup-*.tar.gz | tail -n +11 | xargs -r rm
```

### 2. Restore

```bash
# Restore from backup
tar -xzf ~/backups/claude-flow/claude-backup-20240115_120000.tar.gz -C "$HOME"
```

## Troubleshooting

### Common Issues

1. **Command not found**
   ```bash
   # Check PATH
   echo $PATH | grep -q claude-flow || export PATH="$HOME/.claude-flow/bin:$PATH"
   
   # Reload shell config
   source ~/.bashrc  # or ~/.zshrc
   ```

2. **Permission issues**
   ```bash
   # Fix permissions
   chmod -R 755 ~/.claude-flow
   chmod -R 700 ~/.claude/config  # Secure config
   ```

3. **Missing dependencies**
   ```bash
   # Check dependencies
   ~/.claude-flow/bin/check-deps
   ```

## Migration

### From Other Tools

```bash
# Import from existing tools
claude-flow import --from copilot ~/.copilot
claude-flow import --from cursor ~/.cursor
```

### Between Machines

```bash
# Export configuration
claude-flow export --output ~/claude-config.tar.gz

# Import on new machine
claude-flow import --input ~/claude-config.tar.gz
```

## Advanced Configuration

### 1. Environment Variables

```bash
# Override default locations
export CLAUDE_FLOW_HOME="/custom/path"
export CLAUDE_USER_DIR="/custom/user/path"
export CLAUDE_CACHE_DIR="/tmp/claude-cache"
export CLAUDE_LOG_LEVEL="debug"
```

### 2. Hooks

Create custom hooks:

```bash
# ~/.claude/hooks/pre-command.sh
#!/bin/bash
# Run before any command
echo "Running command: $1"

# ~/.claude/hooks/post-command.sh
#!/bin/bash
# Run after any command
echo "Command completed with status: $?"
```

## Performance Optimization

### 1. Cache Configuration

```json
{
  "cache": {
    "enabled": true,
    "maxSize": "500MB",
    "ttl": "7d",
    "location": "~/.claude/cache"
  }
}
```

### 2. Disable Features

For slower systems:

```json
{
  "performance": {
    "animations": false,
    "syntax_highlighting": false,
    "auto_complete": false
  }
}
```

## Security

### 1. Secure API Keys

```bash
# Encrypt API keys
claude-flow config encrypt-keys

# Use system keychain (macOS)
claude-flow config --use-keychain
```

### 2. Restricted Mode

```bash
# Run in restricted mode
export CLAUDE_RESTRICTED=1
claude-flow run --safe
```

## Next Steps

- Explore available commands: `claude-flow list`
- Create your first command: `claude-flow new my-command`
- Read system deployment guide for shared installations
- Check security guide for best practices