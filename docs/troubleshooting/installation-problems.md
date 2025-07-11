# Installation Problems - Claude Flow Troubleshooting

This guide helps resolve installation-specific issues with Claude Flow.

## Table of Contents

1. [Pre-Installation Checks](#pre-installation-checks)
2. [Installation Methods](#installation-methods)
3. [Platform-Specific Issues](#platform-specific-issues)
4. [Post-Installation Verification](#post-installation-verification)
5. [Rollback and Recovery](#rollback-and-recovery)

## Pre-Installation Checks

### System Requirements

Before installing, verify your system meets these requirements:

```bash
# Check bash version (4.0+ recommended)
bash --version

# Check for required commands
for cmd in git npm mkdir cp chmod; do
    command -v $cmd >/dev/null 2>&1 && echo "✓ $cmd found" || echo "✗ $cmd NOT FOUND"
done

# Check disk space
df -h ~ | grep -E "/$|/home"

# Check write permissions
touch ~/.local/test 2>/dev/null && rm ~/.local/test && echo "✓ Can write to ~/.local" || echo "✗ Cannot write to ~/.local"
```

### Clean Environment Check

```bash
# Check for existing installations
for file in ~/.local/bin/claude-* /usr/local/bin/claude-*; do
    [ -f "$file" ] && echo "Found existing: $file"
done

# Check for conflicting environment variables
env | grep -i claude

# Check for shell modifications
grep -i claude ~/.bashrc ~/.zshrc ~/.profile 2>/dev/null
```

## Installation Methods

### Method 1: Automatic Installation (Recommended)

```bash
# Auto-detect best installation type
./install.sh

# What it does:
# - Detects if you have sudo access
# - Chooses system-wide or user installation
# - Updates PATH if needed
# - Creates all necessary directories
```

### Method 2: User Installation

Best for personal use without admin rights:

```bash
# Install for current user only
./install.sh --user

# Installation locations:
# Scripts: ~/.local/bin/
# Templates: ~/.local/share/claude-flow/
```

**Troubleshooting User Installation:**

```bash
# If ~/.local/bin doesn't exist
mkdir -p ~/.local/bin

# If PATH not updated automatically
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify PATH update
echo $PATH | grep -q "$HOME/.local/bin" && echo "PATH OK" || echo "PATH needs update"
```

### Method 3: System-Wide Installation

For shared systems or when all users need access:

```bash
# Install system-wide (requires sudo)
sudo ./install.sh --system

# Installation locations:
# Scripts: /usr/local/bin/
# Templates: /usr/local/share/claude-flow/
```

**Troubleshooting System Installation:**

```bash
# If sudo not available
su -c './install.sh --system'

# If /usr/local/bin not writable
sudo mkdir -p /usr/local/bin /usr/local/share
sudo chown -R $(whoami) /usr/local/bin /usr/local/share

# Alternative: Install to /opt
sudo mkdir -p /opt/claude-flow
sudo cp -r * /opt/claude-flow/
sudo ln -s /opt/claude-flow/claude-* /usr/local/bin/
```

### Method 4: Manual Installation

When automated installation fails:

```bash
# 1. Create directories
mkdir -p ~/.local/bin ~/.local/share/claude-flow

# 2. Copy templates
cp -r templates ~/.local/share/claude-flow/

# 3. Copy and rename scripts
cp install-claude-flow.sh ~/.local/bin/claude-install-flow
cp smart-merge-claude.sh ~/.local/bin/claude-merge

# 4. Make executable
chmod +x ~/.local/bin/claude-*

# 5. Update PATH
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

## Platform-Specific Issues

### macOS

**Issue: Operation not permitted**
```bash
# On macOS Catalina+, system directories are protected
# Solution: Use user installation
./install.sh --user
```

**Issue: .DS_Store files interfering**
```bash
# Clean up before installation
find . -name ".DS_Store" -delete

# Prevent creation
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
```

**Issue: Homebrew conflicts**
```bash
# If you have Homebrew-installed tools conflicting
brew list | grep claude
brew uninstall claude-flow  # if exists

# Use Homebrew paths
./install.sh --system  # Installs to /usr/local which Homebrew uses
```

### Linux

**Issue: Different shell configurations**
```bash
# Detect shell and update correct config
if [ -n "$ZSH_VERSION" ]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
elif [ -n "$BASH_VERSION" ]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
else
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
fi
```

**Issue: SELinux preventing execution**
```bash
# Check SELinux status
getenforce

# If enforcing, add context
chcon -t bin_t ~/.local/bin/claude-*

# Or temporarily disable for installation
sudo setenforce 0
./install.sh
sudo setenforce 1
```

### Windows (WSL/Git Bash)

**Issue: Line ending problems**
```bash
# Fix line endings
dos2unix install.sh install-claude-flow.sh smart-merge-claude.sh

# Configure git to handle line endings
git config --global core.autocrlf input
```

**Issue: Path separator issues**
```bash
# Use Unix-style paths in WSL
export CLAUDE_TEMPLATES_DIR="/mnt/c/Users/$USER/claude-flow/templates"

# Convert Windows paths
winpath="C:\Users\username\claude-flow"
unixpath="/mnt/c/Users/username/claude-flow"
```

## Post-Installation Verification

### Comprehensive Installation Check

Create and run this verification script:

```bash
#!/bin/bash
# save as verify-installation.sh

echo "=== Claude Flow Installation Verification ==="
echo

# Check commands
echo "1. Checking commands availability:"
for cmd in claude-install-flow claude-merge; do
    if command -v $cmd >/dev/null 2>&1; then
        echo "  ✓ $cmd: $(which $cmd)"
    else
        echo "  ✗ $cmd: NOT FOUND"
    fi
done
echo

# Check templates
echo "2. Checking templates:"
for dir in ~/.local/share/claude-flow/templates /usr/local/share/claude-flow/templates; do
    if [ -d "$dir" ]; then
        echo "  ✓ Found templates at: $dir"
        echo "    - Files: $(find $dir -name "*.md" | wc -l)"
        break
    fi
done
echo

# Check PATH
echo "3. Checking PATH:"
echo "  Current PATH: $PATH"
if echo $PATH | grep -q "$HOME/.local/bin"; then
    echo "  ✓ User bin directory in PATH"
else
    echo "  ✗ User bin directory NOT in PATH"
fi
echo

# Test execution
echo "4. Testing execution:"
if claude-install-flow --help >/dev/null 2>&1; then
    echo "  ✓ claude-install-flow executes successfully"
else
    echo "  ✗ claude-install-flow execution failed"
fi
```

### Quick Verification Commands

```bash
# Check installation locations
ls -la ~/.local/bin/claude-* /usr/local/bin/claude-* 2>/dev/null

# Verify templates
find ~/.local/share/claude-flow /usr/local/share/claude-flow -name "*.md" 2>/dev/null | head -5

# Test commands
claude-install-flow --help
claude-merge --help

# Check environment
env | grep CLAUDE
```

## Rollback and Recovery

### Backup Before Installation

```bash
# Create backup of existing installation
if [ -d ~/.local/share/claude-flow ]; then
    cp -r ~/.local/share/claude-flow ~/.local/share/claude-flow.backup.$(date +%Y%m%d)
fi

# Backup commands
for cmd in ~/.local/bin/claude-*; do
    [ -f "$cmd" ] && cp "$cmd" "$cmd.backup.$(date +%Y%m%d)"
done
```

### Complete Uninstallation

```bash
# Use built-in uninstaller
./install.sh --uninstall

# Manual uninstallation if script fails
rm -f ~/.local/bin/claude-install-flow
rm -f ~/.local/bin/claude-merge
rm -rf ~/.local/share/claude-flow
rm -f /usr/local/bin/claude-install-flow
rm -f /usr/local/bin/claude-merge
rm -rf /usr/local/share/claude-flow

# Remove from PATH (edit your shell config)
# Remove lines containing: export PATH="$HOME/.local/bin:$PATH"
```

### Recovery from Failed Installation

```bash
# 1. Clean up partial installation
./install.sh --uninstall

# 2. Clear any cached data
rm -rf /tmp/claude*

# 3. Reset environment
unset CLAUDE_TEMPLATES_DIR
unset CLAUDE_TEMPLATE_SOURCE

# 4. Try installation with debug
bash -x ./install.sh --user 2>&1 | tee install.log

# 5. Review log for errors
grep -i error install.log
```

### Alternative Installation via Git

If the standard installation continues to fail:

```bash
# Clone to a permanent location
git clone https://github.com/your-org/claude-flow.git ~/claude-flow

# Create convenience scripts
cat > ~/bin/claude-install-flow << 'EOF'
#!/bin/bash
exec bash ~/claude-flow/install-claude-flow.sh "$@"
EOF

cat > ~/bin/claude-merge << 'EOF'
#!/bin/bash
exec bash ~/claude-flow/smart-merge-claude.sh "$@"
EOF

chmod +x ~/bin/claude-*

# Add to PATH
export PATH="$HOME/bin:$PATH"
```

## Common Installation Error Messages

### "No such file or directory"
```bash
# Usually means script location issue
pwd  # Check current directory
ls -la install.sh  # Verify script exists
bash ./install.sh  # Use explicit path
```

### "Permission denied"
```bash
# Check and fix permissions
ls -l install.sh
chmod +x install.sh
# Or run with bash directly
bash install.sh
```

### "Templates directory not found"
```bash
# Verify templates exist
ls -la templates/

# If missing, re-download
git clone https://github.com/your-org/claude-flow.git
cd claude-flow
./install.sh --user
```

### "Command not found" after installation
```bash
# Reload shell configuration
source ~/.bashrc  # or ~/.zshrc

# Or start new shell
exec $SHELL

# Or logout/login
```

## Getting Support

If installation problems persist:

1. Run diagnostic script:
```bash
bash -x ./install.sh --user 2>&1 | tee install-debug.log
```

2. Collect system information:
```bash
uname -a > system-info.txt
echo $SHELL >> system-info.txt
$SHELL --version >> system-info.txt
env | grep -E "(PATH|CLAUDE)" >> system-info.txt
```

3. Create GitHub issue with:
   - install-debug.log
   - system-info.txt
   - Steps you've tried
   - Error messages