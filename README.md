# Claude Flow - Development Templates and Tools

A comprehensive toolkit for setting up Claude Code configurations and development workflows across different programming languages and frameworks.

## Overview

Claude Flow provides intelligent templates and automation scripts to streamline your development setup with Claude Code. It includes pre-configured templates for popular languages and frameworks, along with smart merging capabilities for existing projects.

## Quick Start

### Installation

Choose your preferred installation method:

```bash
# Auto-detect installation type (recommended)
./install.sh

# Install for current user only
./install.sh --user

# Install system-wide (requires sudo)
./install.sh --system
```

After installation, the tools will be available as `claude-install-flow` and `claude-merge` commands.

### Basic Usage

```bash
# Set up Claude templates in a new project
claude-install-flow

# Set up Claude templates in a specific directory
claude-install-flow /path/to/project

# Smart merge CLAUDE.md and commands in current directory
claude-merge

# Smart merge with specific target directory
claude-merge /path/to/target
```

## Script Reference

### `install.sh` - System Installation

Installs Claude Flow tools system-wide or for the current user.

**Usage:**
```bash
./install.sh [OPTIONS]
```

**Options:**
- `--user` - Install for current user only (`~/.local/`)
- `--system` - Install system-wide (`/usr/local/`)
- `--uninstall` - Remove Claude Flow tools
- `--help` - Show help message

**Installation Locations:**
- **User Install:** `~/.local/bin/` and `~/.local/share/claude-flow/`
- **System Install:** `/usr/local/bin/` and `/usr/local/share/claude-flow/`

### `claude-install-flow` - Template Installation

Sets up Claude Code templates for development projects with language and framework-specific configurations.

**Usage:**
```bash
claude-install-flow [target-directory]
```

**Features:**
- Interactive selection of programming languages and frameworks
- Smart detection of existing project structure
- Installs appropriate CLAUDE.md configuration
- Sets up `.claude/` directory with commands
- Supports idempotent operations (safe to run multiple times)

**Example:**
```bash
# Set up templates in current directory
claude-install-flow

# Set up templates in a Node.js project
claude-install-flow /path/to/my-node-app
```

### `claude-merge` - Smart Configuration Merger

Intelligently merges CLAUDE.md files and sets up Claude commands without overwriting existing configurations.

**Usage:**
```bash
claude-merge [target-directory]
```

**Features:**
- Smart merging of existing and template CLAUDE.md files
- Preserves existing project-specific configurations
- Copies command templates to `.claude/commands/`
- Creates merged configuration with clear sections
- Handles both new and existing installations

**Merge Logic:**
1. Uses CLAUDE.md from current directory if available
2. Falls back to template CLAUDE.md
3. Intelligently merges with target directory's existing CLAUDE.md
4. Avoids duplication of template content

## Template Structure

### Available Templates

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

**Workflows:**
- CI/CD (GitHub Actions)
- Testing automation
- Documentation generation

### Command Templates

The `.claude/commands/` directory includes:
- `architect.md` - System architecture planning
- `debug.md` - Debugging assistance
- `optimize.md` - Performance optimization
- `refactor.md` - Code refactoring guidance
- `review.md` - Code review assistance
- `test-coverage.md` - Testing strategies
- And more...

## Configuration

### Environment Variables

**Template Source Locations** (searched in order):
1. `$CLAUDE_TEMPLATES_DIR` - Custom template directory
2. `$CLAUDE_TEMPLATE_SOURCE` - Legacy environment variable
3. `~/.local/share/claude-flow/templates` - User installation
4. `/usr/local/share/claude-flow/templates` - System installation
5. Local `templates/` directory - Development mode

**Example:**
```bash
# Use custom templates
export CLAUDE_TEMPLATES_DIR="/path/to/my/templates"
claude-install-flow
```

## Development

### Directory Structure

```
claude-flow/
├── install.sh                 # System installation script
├── install-claude-flow.sh     # Template installation script
├── smart-merge-claude.sh      # Smart merger script
├── templates/                 # Template library
│   ├── CLAUDE.md             # Base configuration
│   ├── commands/             # Command templates
│   ├── languages/            # Language-specific configs
│   ├── frameworks/           # Framework-specific configs
│   └── workflows/            # Workflow templates
└── test/                     # Test suite
```

### Running Tests

```bash
cd test
./run-tests.sh
```

### Backup and Recovery

Installation automatically creates backups:
- `smart-merge-claude.sh.backup`
- `install-claude-flow.sh.backup`

**To revert changes:**
```bash
cp smart-merge-claude.sh.backup smart-merge-claude.sh
cp install-claude-flow.sh.backup install-claude-flow.sh
```

## Troubleshooting

### Common Issues

**Templates not found:**
```bash
# Check template locations
echo $CLAUDE_TEMPLATES_DIR
ls ~/.local/share/claude-flow/templates
ls /usr/local/share/claude-flow/templates
```

**PATH issues (user installation):**
```bash
# Add to your shell config (.bashrc, .zshrc, etc.)
export PATH="$HOME/.local/bin:$PATH"
```

**Permission errors:**
```bash
# For system installation
sudo ./install.sh --system

# For user installation (recommended)
./install.sh --user
```

### Uninstallation

```bash
# Remove all Claude Flow installations
./install.sh --uninstall

# Or manually remove
rm -f ~/.local/bin/claude-{install-flow,merge}
rm -rf ~/.local/share/claude-flow
```

## Contributing

1. Fork the repository
2. Create feature branches for changes
3. Add tests for new functionality
4. Run the test suite: `cd test && ./run-tests.sh`
5. Submit pull requests

## License

This project is licensed under the MIT License.