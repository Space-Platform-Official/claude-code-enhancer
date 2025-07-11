# Common Issues - Claude Flow Troubleshooting Guide

This guide covers the most common issues users encounter with Claude Flow and their solutions.

## Table of Contents

1. [Script Execution Errors](#script-execution-errors)
2. [File Permission Issues](#file-permission-issues)
3. [Shell Environment Problems](#shell-environment-problems)
4. [Template Not Found Errors](#template-not-found-errors)
5. [Merge Conflicts](#merge-conflicts)
6. [Command Not Found](#command-not-found)
7. [NPM Installation Issues](#npm-installation-issues)

## Script Execution Errors

### Issue: "bad interpreter: No such file or directory"

**Symptoms:**
```bash
-bash: ./install.sh: /bin/bash^M: bad interpreter: No such file or directory
```

**Cause:** DOS/Windows line endings in the script files.

**Solution:**
```bash
# Convert line endings
dos2unix install.sh install-claude-flow.sh smart-merge-claude.sh

# Alternative if dos2unix is not available
sed -i 's/\r$//' install.sh install-claude-flow.sh smart-merge-claude.sh
```

### Issue: "syntax error near unexpected token"

**Symptoms:**
```bash
./install.sh: line 5: syntax error near unexpected token `$'{\r''
```

**Cause:** Corrupted script or incorrect shell being used.

**Solution:**
```bash
# Explicitly use bash
/bin/bash install.sh

# Check script integrity
file install.sh  # Should show "Bourne-Again shell script"
```

## File Permission Issues

### Issue: "Permission denied" when running scripts

**Symptoms:**
```bash
bash: ./install.sh: Permission denied
```

**Solution:**
```bash
# Make scripts executable
chmod +x install.sh install-claude-flow.sh smart-merge-claude.sh

# Verify permissions
ls -la *.sh
```

### Issue: Cannot write to installation directory

**Symptoms:**
```bash
[ERROR] Failed to create directory: /usr/local/bin
```

**Solutions:**

1. **Use user installation (recommended):**
```bash
./install.sh --user
```

2. **Use sudo for system installation:**
```bash
sudo ./install.sh --system
```

3. **Fix npm permissions for global packages:**
```bash
# Create npm global directory for user
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

## Shell Environment Problems

### Issue: Version managers interfering with script execution

**Symptoms:**
```bash
[ERROR] Shell environment issue detected
[WARNING] Detected gvm (Go Version Manager) in shell environment
```

**Cause:** Version managers (gvm, nvm, rvm) override shell built-ins.

**Solutions:**

1. **Run with clean shell:**
```bash
/bin/bash --noprofile --norc install.sh
```

2. **Temporarily disable version managers:**
```bash
# For gvm
unset -f cd

# For nvm
nvm deactivate

# Then run the script
./install.sh
```

3. **Use explicit paths:**
```bash
/usr/bin/env bash install.sh
```

### Issue: PATH not updated after user installation

**Symptoms:**
```bash
claude-install-flow: command not found
```

**Solution:**
```bash
# Add to PATH (choose based on your shell)
# For bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# For zsh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# For fish
set -U fish_user_paths $HOME/.local/bin $fish_user_paths

# Verify PATH
echo $PATH | grep -q "$HOME/.local/bin" && echo "PATH updated" || echo "PATH not updated"
```

## Template Not Found Errors

### Issue: "No valid templates directory found"

**Symptoms:**
```bash
[ERROR] No valid templates directory found. Searched:
  1. $CLAUDE_TEMPLATES_DIR: not set
  2. ~/.local/share/claude-flow/templates
  3. /usr/local/share/claude-flow/templates
  4. ./templates
```

**Solutions:**

1. **Verify installation:**
```bash
# Check if templates were installed
ls ~/.local/share/claude-flow/templates
ls /usr/local/share/claude-flow/templates
```

2. **Set custom templates directory:**
```bash
export CLAUDE_TEMPLATES_DIR="/path/to/your/templates"
claude-install-flow
```

3. **Reinstall Claude Flow:**
```bash
./install.sh --uninstall
./install.sh --user  # or --system
```

### Issue: Specific template missing

**Symptoms:**
```bash
[WARNING] No command templates found in /path/to/templates/commands
```

**Solution:**
```bash
# Check template structure
find $(dirname $(which claude-install-flow))/../share/claude-flow -type f -name "*.md"

# Clone latest templates
git clone https://github.com/your-org/claude-flow.git /tmp/claude-flow
cp -r /tmp/claude-flow/templates/* ~/.local/share/claude-flow/templates/
```

## Merge Conflicts

### Issue: Files already exist during merge

**Symptoms:**
```
[WARNING] Conflict detected for: ./CLAUDE.md
Options:
  [k] Keep existing file
  [o] Overwrite with new file
  [m] Merge manually later (create .new file)
  [s] Skip this file
```

**Best Practices:**

1. **For first-time setup:** Choose `[o]` to overwrite with template
2. **For existing projects:** Choose `[m]` to create .new file and merge manually
3. **For minor updates:** Choose `[k]` to keep existing configuration

**Manual merge process:**
```bash
# Find all .new files
find . -name "*.new" -type f

# Compare and merge
diff CLAUDE.md CLAUDE.md.new
# Manually edit CLAUDE.md to incorporate changes
rm CLAUDE.md.new  # After merging
```

## Command Not Found

### Issue: claude-install-flow or claude-merge not found

**Symptoms:**
```bash
claude-install-flow: command not found
```

**Diagnostic Steps:**

1. **Check installation:**
```bash
# User installation
ls -la ~/.local/bin/claude-*

# System installation
ls -la /usr/local/bin/claude-*
```

2. **Verify PATH:**
```bash
echo $PATH
which claude-install-flow
```

3. **Check symlinks:**
```bash
# If commands exist but don't work
file ~/.local/bin/claude-install-flow
# Should show: symbolic link or shell script
```

**Solutions:**
```bash
# Reinstall
./install.sh --uninstall
./install.sh --user

# Manual PATH fix
export PATH="$HOME/.local/bin:$PATH"

# Create aliases as workaround
alias claude-install-flow='bash ~/.local/share/claude-flow/install-claude-flow.sh'
alias claude-merge='bash ~/.local/share/claude-flow/smart-merge-claude.sh'
```

## NPM Installation Issues

### Issue: npm install -g claude-flow fails

**Symptoms:**
```bash
npm ERR! code EACCES
npm ERR! syscall access
npm ERR! path /usr/local/lib/node_modules
```

**Solutions:**

1. **Use npm prefix for user:**
```bash
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH
npm install -g claude-flow
```

2. **Fix npm permissions:**
```bash
# Option 1: Change npm's default directory
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'

# Option 2: Use npx instead
npx claude-flow
```

3. **Use node version manager:**
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install node
npm install -g claude-flow
```

### Issue: Node.js not installed

**Symptoms:**
```bash
[ERROR] npm is not installed. Please install Node.js and npm first.
```

**Solution:**
```bash
# macOS with Homebrew
brew install node

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

## General Debugging Tips

### Enable Debug Mode

```bash
# Run scripts with debug output
bash -x install.sh
bash -x claude-install-flow

# Set debug environment variable
export CLAUDE_DEBUG=1
```

### Check System Requirements

```bash
# Verify bash version (4.0+ recommended)
bash --version

# Check available disk space
df -h ~/.local/share

# Verify git installation
git --version
```

### Clean Installation

If all else fails, perform a clean installation:

```bash
# 1. Backup existing configuration
cp -r ~/.local/share/claude-flow ~/.local/share/claude-flow.backup

# 2. Uninstall completely
./install.sh --uninstall
rm -rf ~/.local/share/claude-flow
rm -f ~/.local/bin/claude-*

# 3. Clean install
./install.sh --user

# 4. Verify installation
claude-install-flow --help
```

## Getting Help

If you continue to experience issues:

1. Check the [FAQ](faq.md) for additional solutions
2. Review [debugging techniques](debugging.md)
3. Search existing GitHub issues
4. Create a new issue with:
   - Error messages
   - System information: `uname -a`
   - Shell version: `$SHELL --version`
   - Installation method used
   - Steps to reproduce