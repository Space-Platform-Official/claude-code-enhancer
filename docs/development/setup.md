# Developer Environment Setup

This guide will help you set up your development environment for contributing to Claude Flow.

## Prerequisites

- **Operating System**: macOS, Linux, or Windows with WSL
- **Shell**: Bash (version 4.0 or higher)
- **Git**: For version control
- **Text Editor**: Any editor with shell script support

## Setting Up Your Development Environment

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/claude-flow.git
cd claude-flow
```

### 2. Verify Shell Version

Claude Flow requires Bash 4.0+ for associative arrays and other modern features:

```bash
bash --version
```

On macOS, you may need to install a newer version:

```bash
# Using Homebrew
brew install bash
```

### 3. Set Up Development Mode

For development, Claude Flow can run directly from the source directory without installation:

```bash
# Make scripts executable
chmod +x install.sh
chmod +x install-claude-flow.sh
chmod +x smart-merge-claude.sh

# Run tests to verify setup
cd test
chmod +x run-tests.sh
./run-tests.sh
```

### 4. Environment Variables

Set these environment variables for development:

```bash
# Use local templates directory (add to your shell profile)
export CLAUDE_TEMPLATES_DIR="$(pwd)/templates"

# Enable debug output (optional)
export CLAUDE_DEBUG=1
```

### 5. Development Installation

For testing the installation process:

```bash
# Install to a local directory for testing
./install.sh --user

# This installs to:
# - ~/.local/bin/claude-install-flow
# - ~/.local/bin/claude-merge
# - ~/.local/share/claude-flow/
```

## Project Structure

```
claude-flow/
├── install.sh                 # System installation script
├── install-claude-flow.sh     # Template installation script
├── smart-merge-claude.sh      # Smart merger script
├── templates/                 # Template library
│   ├── CLAUDE.md             # Base configuration template
│   ├── base/                 # Base templates
│   ├── commands/             # Command templates
│   ├── languages/            # Language-specific configs
│   ├── frameworks/           # Framework-specific configs
│   └── workflows/            # Workflow templates
├── test/                     # Test suite
│   ├── run-tests.sh         # Main test runner
│   ├── mock-templates/      # Test templates
│   └── test-projects/       # Test execution directory
└── docs/                     # Documentation
    └── development/         # Developer docs (you are here)
```

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

- Edit scripts in the root directory
- Add/modify templates in `templates/`
- Update tests if needed

### 3. Test Your Changes

Always run the test suite before committing:

```bash
cd test
./run-tests.sh
```

### 4. Manual Testing

Test the scripts manually in a separate directory:

```bash
# Create a test directory
mkdir -p ~/test-claude-flow
cd ~/test-claude-flow

# Test install-claude-flow.sh
/path/to/claude-flow/install-claude-flow.sh

# Test smart-merge-claude.sh
/path/to/claude-flow/smart-merge-claude.sh
```

### 5. Debug Mode

Enable debug output for troubleshooting:

```bash
# Set debug environment variable
export CLAUDE_DEBUG=1

# Run scripts with debug output
./install-claude-flow.sh
```

## IDE Setup

### VS Code

Recommended extensions:
- **Bash IDE** - For syntax highlighting and linting
- **ShellCheck** - For shell script analysis
- **EditorConfig** - For consistent formatting

Settings (`settings.json`):
```json
{
  "files.associations": {
    "*.sh": "shellscript"
  },
  "shellcheck.enable": true,
  "shellcheck.executablePath": "shellcheck",
  "editor.tabSize": 4,
  "editor.insertSpaces": true
}
```

### Vim

Add to `.vimrc`:
```vim
" Shell script settings
autocmd FileType sh setlocal shiftwidth=4 tabstop=4 expandtab

" Enable syntax highlighting
syntax on
filetype plugin indent on
```

## Common Development Tasks

### Adding a New Language Template

1. Create directory: `templates/languages/YOUR_LANGUAGE/`
2. Add `CLAUDE.md` with language-specific guidelines
3. Update `install-claude-flow.sh` to include the new option
4. Add tests in `test/mock-templates/languages/`

### Adding a New Command Template

1. Create `templates/commands/YOUR_COMMAND.md`
2. Follow the existing command template format
3. Document the command in `templates/commands/README.md`

### Modifying Installation Logic

1. Edit `install-claude-flow.sh` for template installation
2. Edit `smart-merge-claude.sh` for merge logic
3. Update tests to cover new functionality
4. Run full test suite to ensure compatibility

## Troubleshooting Development Issues

### Scripts Not Found

```bash
# Ensure scripts are executable
chmod +x *.sh

# Check PATH for user installations
echo $PATH | grep -q "$HOME/.local/bin" || export PATH="$HOME/.local/bin:$PATH"
```

### Template Source Issues

```bash
# Verify template directory
echo $CLAUDE_TEMPLATES_DIR
ls -la templates/

# Check all possible template locations
for dir in "$CLAUDE_TEMPLATES_DIR" "$CLAUDE_TEMPLATE_SOURCE" \
           ~/.local/share/claude-flow/templates \
           /usr/local/share/claude-flow/templates \
           ./templates; do
    echo "Checking: $dir"
    [ -d "$dir" ] && echo "  Found!" || echo "  Not found"
done
```

### Test Failures

```bash
# Run tests with verbose output
cd test
bash -x ./run-tests.sh

# Run a specific test function
cd test
source run-tests.sh
test_fresh_install  # Run just this test
```

## Next Steps

- Review [Contributing Guidelines](contributing.md)
- Read about [Testing](testing.md)
- Learn about [Creating Templates](creating-templates.md)
- Explore [Code Style Guide](code-style.md)