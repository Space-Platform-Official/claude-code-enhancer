# Installation Guide

This guide provides detailed instructions for installing Claude Flow on your system. Claude Flow can be installed either system-wide (for all users) or for the current user only.

## Table of Contents

- [Quick Installation](#quick-installation)
- [Installation Methods](#installation-methods)
- [Platform-Specific Instructions](#platform-specific-instructions)
- [Post-Installation Setup](#post-installation-setup)
- [Verifying Installation](#verifying-installation)
- [Troubleshooting](#troubleshooting)
- [Uninstallation](#uninstallation)

## Quick Installation

For most users, the automatic installation is recommended:

```bash
# Clone the repository
git clone https://github.com/your-repo/claude-flow.git
cd claude-flow

# Run automatic installation
./install.sh
```

This will:
- Auto-detect the best installation type for your system
- Install all necessary files
- Configure your PATH if needed

## Installation Methods

### Method 1: Automatic Installation (Recommended)

The installer auto-detects whether to install system-wide or for the current user:

```bash
./install.sh
```

**How it works:**
- If run with sudo or as root → system installation
- If `/usr/local/` is writable → system installation  
- Otherwise → user installation

### Method 2: User Installation

Install Claude Flow for the current user only:

```bash
./install.sh --user
```

**Installation locations:**
- Executables: `~/.local/bin/`
- Templates: `~/.local/share/claude-flow/`

**Benefits:**
- No sudo required
- Isolated to your user account
- Easy to manage and update

### Method 3: System-Wide Installation

Install Claude Flow for all users on the system:

```bash
./install.sh --system
# Or with sudo if not root:
sudo ./install.sh --system
```

**Installation locations:**
- Executables: `/usr/local/bin/`
- Templates: `/usr/local/share/claude-flow/`

**Benefits:**
- Available to all users
- Centralized management
- No PATH configuration needed

## Platform-Specific Instructions

### macOS

1. **Install Homebrew** (if not already installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install dependencies**:
   ```bash
   brew install bash git
   ```

3. **Clone and install Claude Flow**:
   ```bash
   git clone https://github.com/your-repo/claude-flow.git
   cd claude-flow
   ./install.sh --user  # Recommended for macOS
   ```

4. **Update PATH** (if prompted):
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

### Linux (Ubuntu/Debian)

1. **Update package manager**:
   ```bash
   sudo apt update
   ```

2. **Install dependencies**:
   ```bash
   sudo apt install git bash
   ```

3. **Clone and install Claude Flow**:
   ```bash
   git clone https://github.com/your-repo/claude-flow.git
   cd claude-flow
   ./install.sh  # Auto-detect installation type
   ```

### Linux (RHEL/Fedora/CentOS)

1. **Install dependencies**:
   ```bash
   sudo dnf install git bash
   # Or for older versions:
   sudo yum install git bash
   ```

2. **Clone and install Claude Flow**:
   ```bash
   git clone https://github.com/your-repo/claude-flow.git
   cd claude-flow
   ./install.sh
   ```

### Windows (WSL2)

1. **Open WSL2 terminal** (Ubuntu recommended)

2. **Update packages**:
   ```bash
   sudo apt update && sudo apt upgrade
   ```

3. **Install dependencies**:
   ```bash
   sudo apt install git bash
   ```

4. **Clone and install Claude Flow**:
   ```bash
   git clone https://github.com/your-repo/claude-flow.git
   cd claude-flow
   ./install.sh --user  # Recommended for WSL
   ```

5. **Note**: Ensure you're working within the WSL filesystem for best performance:
   ```bash
   cd ~  # Work in Linux home directory
   ```

## Post-Installation Setup

### 1. PATH Configuration

If you chose user installation, you may need to add `~/.local/bin` to your PATH.

**For Bash** (`~/.bashrc`):
```bash
export PATH="$HOME/.local/bin:$PATH"
```

**For Zsh** (`~/.zshrc`):
```bash
export PATH="$HOME/.local/bin:$PATH"
```

**For Fish** (`~/.config/fish/config.fish`):
```fish
set -gx PATH $HOME/.local/bin $PATH
```

After adding, reload your shell configuration:
```bash
source ~/.bashrc  # or ~/.zshrc for Zsh
```

### 2. Environment Variables (Optional)

You can customize Claude Flow behavior with environment variables:

```bash
# Use custom templates directory
export CLAUDE_TEMPLATES_DIR="/path/to/custom/templates"

# Enable debug output
export CLAUDE_DEBUG=1
```

Add these to your shell configuration file to make them permanent.

### 3. Shell Completion (Optional)

For Bash completion support:
```bash
# Add to ~/.bashrc
source ~/.local/share/claude-flow/completion/claude-flow.bash
```

## Verifying Installation

### Check Installed Commands

Verify that Claude Flow commands are available:

```bash
# Check if commands exist
which claude-install-flow
which claude-merge

# Test the commands
claude-install-flow --help
claude-merge --help
```

### Verify Templates

Check that templates were installed correctly:

```bash
# For user installation
ls ~/.local/share/claude-flow/templates/

# For system installation
ls /usr/local/share/claude-flow/templates/
```

### Run Test Installation

Test Claude Flow in a temporary directory:

```bash
# Create test directory
mkdir -p /tmp/claude-test
cd /tmp/claude-test

# Run claude-install-flow
claude-install-flow

# Check results
ls -la .claude/
cat CLAUDE.md
```

## Troubleshooting

### Common Installation Issues

#### 1. Command not found after installation

**Problem**: `claude-install-flow: command not found`

**Solutions**:
- Check if installation directory is in PATH:
  ```bash
  echo $PATH | grep -E "(\.local/bin|/usr/local/bin)"
  ```
- Reload shell configuration:
  ```bash
  source ~/.bashrc  # or ~/.zshrc
  ```
- Start a new terminal session

#### 2. Permission denied errors

**Problem**: `Permission denied` during system installation

**Solutions**:
- Use sudo for system installation:
  ```bash
  sudo ./install.sh --system
  ```
- Or switch to user installation:
  ```bash
  ./install.sh --user
  ```

#### 3. Templates not found

**Problem**: `ERROR: Templates directory not found`

**Solutions**:
- Check template installation:
  ```bash
  find ~ -name "claude-flow" -type d 2>/dev/null
  ```
- Set custom template directory:
  ```bash
  export CLAUDE_TEMPLATES_DIR="/path/to/templates"
  ```

#### 4. WSL-specific issues

**Problem**: Slow performance in Windows directories

**Solution**: Work within WSL filesystem:
```bash
cd ~  # Use Linux home instead of /mnt/c/...
```

### Debug Mode

Enable debug output for troubleshooting:

```bash
# Run with debug output
CLAUDE_DEBUG=1 claude-install-flow

# Or export for session
export CLAUDE_DEBUG=1
```

### Getting Help

If you encounter issues:

1. Check the [prerequisites](prerequisites.md) are met
2. Review error messages carefully
3. Run installation with debug mode
4. Check existing [GitHub issues](https://github.com/your-repo/claude-flow/issues)
5. Create a new issue with:
   - Your OS and version
   - Complete error output
   - Steps to reproduce

## Uninstallation

To remove Claude Flow from your system:

```bash
# From the original installation directory
./install.sh --uninstall
```

This will:
- Remove all installed executables
- Delete template directories
- Clean up system or user directories

### Manual Uninstallation

If the uninstaller is not available:

**For user installation:**
```bash
rm -f ~/.local/bin/claude-install-flow
rm -f ~/.local/bin/claude-merge
rm -rf ~/.local/share/claude-flow
```

**For system installation:**
```bash
sudo rm -f /usr/local/bin/claude-install-flow
sudo rm -f /usr/local/bin/claude-merge
sudo rm -rf /usr/local/share/claude-flow
```

## Next Steps

After successful installation:
- [Quick Start Guide](quick-start.md) - Get started with your first project
- [First Project Tutorial](first-project.md) - Detailed walkthrough
- [Configuration Guide](configuration.md) - Customize Claude Flow settings