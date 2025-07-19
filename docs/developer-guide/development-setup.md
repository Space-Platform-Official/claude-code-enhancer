# Development Environment Setup

Comprehensive guide for setting up a development environment to contribute to the Claude Code Enhancer project.

## Prerequisites

### System Requirements
- **Operating System**: macOS, Linux, or Windows with WSL2
- **Shell**: Bash 4.0+ (required for associative arrays and modern features)
- **Git**: Version 2.20+ for advanced Git operations
- **Node.js**: 16+ (for JavaScript-based tools and testing)
- **Python**: 3.8+ (for Python-based tools and analysis)

### Development Tools
- **Text Editor/IDE**: VS Code, Vim, or any editor with shell script support
- **Terminal**: Modern terminal with color support
- **Git**: Advanced Git knowledge helpful for complex workflows

## Quick Setup

### 1. Clone and Basic Setup

```bash
# Clone the repository
git clone <repository-url>
cd claude-code-enhancer

# Make scripts executable
chmod +x *.sh
chmod +x .claude/commands/**/*.sh

# Set up environment variables
export CLAUDE_TEMPLATES_DIR="$(pwd)/templates"
export CLAUDE_DEBUG=1  # Enable debug output
```

### 2. Verify Installation

```bash
# Check Bash version (must be 4.0+)
bash --version

# Verify templates directory
ls -la templates/

# Run basic tests
cd test
./run-tests.sh
```

### 3. Development Mode Setup

```bash
# For development, run directly from source
./smart-merge-claude.sh --help
./install-claude-flow.sh --help

# Test installation without affecting system
./install.sh --user  # Installs to ~/.local/
```

## Detailed Setup Guide

### Shell Environment Configuration

#### Bash Version Check and Upgrade

```bash
# Check current Bash version
bash --version

# On macOS, install newer Bash via Homebrew
brew install bash

# Add to PATH if needed
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
```

#### Essential Environment Variables

```bash
# Add to your ~/.bashrc or ~/.zshrc
echo 'export CLAUDE_TEMPLATES_DIR="$HOME/dev/claude-code-enhancer/templates"' >> ~/.bashrc
echo 'export CLAUDE_DEBUG=1' >> ~/.bashrc
echo 'export CLAUDE_MERGE_BACKUP=true' >> ~/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Reload shell configuration
source ~/.bashrc
```

### Project Structure Familiarity

#### Core Directories

```
claude-code-enhancer/
├── .claude/                      # Command system core
│   ├── commands/                # Command definitions
│   │   ├── git/               # Git integration commands
│   │   ├── milestone/         # Milestone management
│   │   ├── quality/           # Quality assurance suite
│   │   └── test/              # Testing commands
│   └── settings.local.json   # Local development settings
├── docs/                        # Documentation
│   ├── developer-guide/       # This guide
│   ├── architecture/          # System architecture docs
│   └── api/                   # API reference
├── templates/                   # Template library
│   ├── base/                  # Base templates
│   ├── commands/              # Command templates
│   ├── languages/             # Language-specific configs
│   └── frameworks/            # Framework templates
├── test/                        # Test suite
│   ├── run-tests.sh           # Main test runner
│   ├── mock-templates/        # Test templates
│   └── test-projects/         # Test execution area
├── smart-merge-claude.sh       # Smart merge script
├── install-claude-flow.sh      # Template installer
└── install.sh                  # System installer
```

#### Key Files Understanding

```bash
# Core merge logic
vim smart-merge-claude.sh

# Template installation logic
vim install-claude-flow.sh

# Command system architecture
vim .claude/commands/README.md

# Quality framework
vim .claude/commands/quality/README.md
```

### Development Tools Setup

#### VS Code Configuration

```json
// .vscode/settings.json
{
  "files.associations": {
    "*.sh": "shellscript",
    "*.md": "markdown"
  },
  "shellcheck.enable": true,
  "shellcheck.executablePath": "shellcheck",
  "editor.tabSize": 4,
  "editor.insertSpaces": true,
  "files.trimTrailingWhitespace": true,
  "markdown.extension.toc.levels": "2..6",
  "claude.templates.autoDetect": true
}
```

```json
// .vscode/extensions.json
{
  "recommendations": [
    "timonwong.shellcheck",
    "foxundermoon.shell-format",
    "yzhang.markdown-all-in-one",
    "editorconfig.editorconfig"
  ]
}
```

#### Vim Configuration

```vim
" Add to ~/.vimrc
" Shell script settings
autocmd FileType sh setlocal shiftwidth=4 tabstop=4 expandtab
autocmd FileType sh setlocal foldmethod=indent

" Markdown settings
autocmd FileType markdown setlocal wrap linebreak

" Enable syntax highlighting
syntax on
filetype plugin indent on

" Show line numbers
set number
set relativenumber
```

### Testing Environment

#### Test Suite Setup

```bash
# Navigate to test directory
cd test

# Make test runner executable
chmod +x run-tests.sh

# Run full test suite
./run-tests.sh

# Run specific test categories
source run-tests.sh
test_fresh_install
test_merge_conflicts
test_idempotency
```

#### Test Debugging

```bash
# Enable detailed test output
export CLAUDE_DEBUG=1
export CLAUDE_VERBOSE=1

# Run tests with bash debugging
bash -x ./run-tests.sh

# Run individual test functions
source run-tests.sh
test_function_name
```

### Git Configuration

#### Development Git Hooks

```bash
# Set up pre-commit hook for quality checks
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
set -e

# Run tests before commit
cd test && ./run-tests.sh

# Check shell scripts with shellcheck
find . -name "*.sh" -not -path "./test/*" | xargs shellcheck
EOF

chmod +x .git/hooks/pre-commit
```

#### Git Aliases for Development

```bash
# Add useful aliases
git config alias.st status
git config alias.co checkout
git config alias.br branch
git config alias.lg "log --oneline --graph --decorate"
git config alias.test "!cd test && ./run-tests.sh"
```

## Development Workflow

### Daily Development Setup

```bash
# Start development session
cd claude-code-enhancer
export CLAUDE_TEMPLATES_DIR="$(pwd)/templates"
export CLAUDE_DEBUG=1

# Update from main branch
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name

# Verify everything works
cd test && ./run-tests.sh
```

### Code Quality Setup

#### ShellCheck Integration

```bash
# Install ShellCheck
# macOS
brew install shellcheck

# Ubuntu/Debian
sudo apt-get install shellcheck

# Check all shell scripts
find . -name "*.sh" | xargs shellcheck
```

#### Formatting Standards

```bash
# Install shfmt for consistent formatting
go install mvdan.cc/sh/v3/cmd/shfmt@latest

# Format all shell scripts
find . -name "*.sh" | xargs shfmt -w -i 4
```

### Debugging Environment

#### Debug Mode Configuration

```bash
# Enable comprehensive debugging
export CLAUDE_DEBUG=1
export CLAUDE_VERBOSE=1
export CLAUDE_TRACE=1

# Enable Bash debugging for scripts
export BASH_XTRACEFD=2
set -x
```

#### Logging Setup

```bash
# Create debug log directory
mkdir -p logs

# Run scripts with logging
./smart-merge-claude.sh 2>&1 | tee logs/merge-debug.log
./install-claude-flow.sh 2>&1 | tee logs/install-debug.log
```

## Advanced Development Setup

### Multi-Agent Development Environment

#### Agent Coordination Testing

```bash
# Set up agent testing environment
export CLAUDE_AGENT_DEBUG=1
export CLAUDE_AGENT_PARALLEL=4

# Test agent coordination
./.claude/commands/milestone/execute.md --test-mode
```

#### State Management Testing

```bash
# Set up state debugging
export CLAUDE_STATE_DEBUG=1
export CLAUDE_STATE_DIR="./test-state"

# Test state persistence
mkdir -p test-state
# Run state-dependent operations
```

### Performance Development Environment

#### Profiling Setup

```bash
# Install profiling tools
npm install -g clinic
pip install py-spy

# Profile script execution
time ./smart-merge-claude.sh

# Memory usage tracking
/usr/bin/time -v ./install-claude-flow.sh
```

#### Benchmarking Environment

```bash
# Set up benchmark directory
mkdir -p benchmarks

# Create test projects of various sizes
for size in small medium large; do
    mkdir -p "benchmarks/project-$size"
    # Generate test files based on size
done
```

### Security Development Environment

#### Security Testing Setup

```bash
# Install security scanning tools
pip install bandit safety
npm install -g audit-ci

# Run security checks
bandit -r .
safety check
```

#### Permission Testing

```bash
# Test with restricted permissions
chmod 444 test-file.txt
./smart-merge-claude.sh  # Should handle gracefully

# Test with limited disk space
# (Use Docker or VM for safe testing)
```

## IDE-Specific Setup

### VS Code Advanced Configuration

#### Task Configuration

```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run Tests",
      "type": "shell",
      "command": "cd test && ./run-tests.sh",
      "group": "test",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "panel": "new"
      }
    },
    {
      "label": "ShellCheck All",
      "type": "shell",
      "command": "find . -name '*.sh' | xargs shellcheck",
      "group": "build"
    }
  ]
}
```

#### Debug Configuration

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Shell Script",
      "type": "bashdb",
      "request": "launch",
      "program": "${file}",
      "cwd": "${workspaceFolder}",
      "args": []
    }
  ]
}
```

### IntelliJ/WebStorm Setup

```yaml
# .idea/runConfigurations/Run_Tests.xml
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Run Tests" type="ShConfigurationType">
    <option name="SCRIPT_TEXT" value="cd test && ./run-tests.sh" />
    <option name="INDEPENDENT_SCRIPT_PATH" value="true" />
    <option name="SCRIPT_PATH" value="" />
    <option name="SCRIPT_OPTIONS" value="" />
    <option name="INDEPENDENT_SCRIPT_WORKING_DIRECTORY" value="true" />
    <option name="SCRIPT_WORKING_DIRECTORY" value="$PROJECT_DIR$" />
  </configuration>
</component>
```

## Troubleshooting Development Setup

### Common Issues

#### Bash Version Problems

```bash
# Check Bash version
bash --version

# If version < 4.0, install newer version
# macOS
brew install bash
echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
chsh -s /usr/local/bin/bash

# Linux
sudo apt-get update && sudo apt-get install bash
```

#### Permission Issues

```bash
# Fix script permissions
find . -name "*.sh" -exec chmod +x {} \;

# Check directory permissions
ls -la

# Fix ownership if needed
sudo chown -R $USER:$USER .
```

#### Environment Variable Issues

```bash
# Debug environment
env | grep CLAUDE
echo $CLAUDE_TEMPLATES_DIR

# Reset environment
unset CLAUDE_DEBUG CLAUDE_VERBOSE
source ~/.bashrc
```

#### Path Issues

```bash
# Check PATH
echo $PATH

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Make permanent
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

### Development Environment Validation

#### Complete Setup Check

```bash
#!/bin/bash
# development-check.sh

echo "=== Claude Code Enhancer Development Environment Check ==="

# Check Bash version
echo "Bash version: $(bash --version | head -1)"
if [[ ${BASH_VERSION%%.*} -lt 4 ]]; then
    echo "WARNING: Bash 4.0+ required"
fi

# Check Git
echo "Git version: $(git --version)"

# Check environment variables
echo "CLAUDE_TEMPLATES_DIR: $CLAUDE_TEMPLATES_DIR"
echo "CLAUDE_DEBUG: $CLAUDE_DEBUG"

# Check scripts
echo "Scripts executable:"
ls -la *.sh | grep -E '^-rwx'

# Check templates
echo "Templates directory:"
ls -la templates/ | head -5

# Run basic test
echo "Running basic test..."
cd test && timeout 30 ./run-tests.sh
echo "Setup check complete!"
```

## Next Steps

After completing the development setup:

1. **Read Architecture**: [Architecture Overview](./architecture-overview.md)
2. **Understand Patterns**: Review existing commands in `.claude/commands/`
3. **Study Templates**: Explore `templates/` directory structure
4. **Run Tests**: Ensure all tests pass before making changes
5. **Start Contributing**: Follow [Contributing Guidelines](./contributing-guidelines.md)

---

**Next**: [Contributing Guidelines](./contributing-guidelines.md) - Learn how to contribute effectively

**See Also**:
- [Testing Guidelines](./testing-guidelines.md) - Comprehensive testing strategies
- [Debugging Guide](./debugging-guide.md) - Advanced debugging techniques
- [Performance Optimization](./performance-optimization.md) - Optimization best practices