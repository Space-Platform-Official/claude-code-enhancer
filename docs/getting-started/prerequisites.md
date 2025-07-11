# Prerequisites

Before installing Claude Flow, ensure your system meets the following requirements and has the necessary dependencies installed.

## System Requirements

### Operating Systems

Claude Flow is compatible with:
- **macOS** (10.15 Catalina or later)
- **Linux** (Ubuntu 18.04+, Debian 10+, RHEL 8+, Fedora 30+, etc.)
- **Windows** (via WSL2 - Windows Subsystem for Linux)

### Hardware Requirements

- **Minimum**: 1GB RAM, 100MB free disk space
- **Recommended**: 4GB RAM, 500MB free disk space

## Required Dependencies

### 1. Bash Shell (4.0+)

Claude Flow requires Bash 4.0 or later. Check your version:

```bash
bash --version
```

**Installation if needed:**
- **macOS**: `brew install bash`
- **Ubuntu/Debian**: `sudo apt-get install bash`
- **RHEL/Fedora**: `sudo yum install bash` or `sudo dnf install bash`

### 2. Git

Git is required for version control operations.

```bash
git --version
```

**Installation if needed:**
- **macOS**: `brew install git` or install Xcode Command Line Tools
- **Ubuntu/Debian**: `sudo apt-get install git`
- **RHEL/Fedora**: `sudo yum install git` or `sudo dnf install git`

### 3. Core Unix Utilities

The following utilities must be available:
- `mkdir`, `cp`, `rm`, `chmod`, `ln`
- `sed`, `grep`, `find`
- `cat`, `echo`, `printf`

These are typically pre-installed on Unix-like systems.

## Optional Dependencies

### Node.js and npm

While not strictly required for basic Claude Flow functionality, some features may benefit from having Node.js installed:

```bash
node --version
npm --version
```

**Installation if needed:**
- **Using Node Version Manager (recommended)**:
  ```bash
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
  nvm install node
  ```
- **macOS**: `brew install node`
- **Ubuntu/Debian**: `sudo apt-get install nodejs npm`

### Text Editors

Claude Flow works with any text editor, but integrates particularly well with:
- Visual Studio Code
- Neovim/Vim
- Emacs
- Sublime Text

## Shell Configuration

### PATH Configuration

Ensure your shell's PATH includes standard system directories:

```bash
echo $PATH
```

Should include:
- `/usr/local/bin` (for system-wide installations)
- `$HOME/.local/bin` (for user installations)

### Shell Compatibility

Claude Flow is tested with:
- **Bash** (recommended)
- **Zsh** (fully compatible)
- **Fish** (may require minor adjustments)

## Windows Specific Requirements (WSL2)

For Windows users, Claude Flow requires WSL2:

1. **Enable WSL2**:
   ```powershell
   wsl --install
   ```

2. **Install a Linux distribution** (Ubuntu recommended):
   ```powershell
   wsl --install -d Ubuntu
   ```

3. **Update packages** in WSL:
   ```bash
   sudo apt update && sudo apt upgrade
   ```

## Verification Script

Save and run this script to verify all prerequisites:

```bash
#!/bin/bash

echo "Checking Claude Flow prerequisites..."
echo "====================================="

# Check OS
echo -n "Operating System: "
uname -s

# Check Bash version
echo -n "Bash version: "
bash --version | head -n1

# Check Git
echo -n "Git: "
if command -v git >/dev/null 2>&1; then
    git --version
else
    echo "NOT INSTALLED"
fi

# Check core utilities
echo "Core utilities:"
for cmd in mkdir cp rm chmod ln sed grep find cat echo printf; do
    echo -n "  $cmd: "
    if command -v $cmd >/dev/null 2>&1; then
        echo "OK"
    else
        echo "MISSING"
    fi
done

# Check optional Node.js
echo -n "Node.js (optional): "
if command -v node >/dev/null 2>&1; then
    node --version
else
    echo "Not installed"
fi

# Check PATH
echo "PATH includes:"
echo "  User bin: $([[ ":$PATH:" == *":$HOME/.local/bin:"* ]] && echo "YES" || echo "NO")"
echo "  System bin: $([[ ":$PATH:" == *":/usr/local/bin:"* ]] && echo "YES" || echo "NO")"

echo "====================================="
echo "Prerequisites check complete!"
```

## Troubleshooting Prerequisites

### Common Issues

1. **Old Bash version on macOS**:
   - macOS ships with Bash 3.2 due to licensing
   - Install newer version: `brew install bash`

2. **Missing commands on minimal Linux**:
   - Install build essentials: `sudo apt-get install build-essential`

3. **PATH not configured**:
   - Add to `~/.bashrc` or `~/.zshrc`:
     ```bash
     export PATH="$HOME/.local/bin:$PATH"
     ```

4. **Permission issues**:
   - Ensure you have write permissions to installation directories
   - Use `--user` flag for user-only installation if lacking sudo access

## Next Steps

Once all prerequisites are satisfied, proceed to:
- [Installation Guide](installation.md) - Detailed installation instructions
- [Quick Start](quick-start.md) - Get up and running quickly