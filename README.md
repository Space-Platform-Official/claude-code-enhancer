# Claude Flow - Development Templates and Tools

A comprehensive toolkit for setting up Claude Code configurations and development workflows across different programming languages and frameworks.

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
- [Features](#features)
- [Supported Languages & Frameworks](#supported-languages--frameworks)
- [Community & Support](#community--support)
- [Contributing](#contributing)
- [License](#license)

## Overview

Claude Flow provides intelligent templates and automation scripts to streamline your development setup with Claude Code. It includes pre-configured templates for popular languages and frameworks, along with smart merging capabilities for existing projects.

### 🚀 Key Features

- **Smart Templates**: Pre-configured Claude Code templates for multiple languages and frameworks
- **Intelligent Merging**: Safely merge Claude configurations with existing projects
- **Zero Dependencies**: Pure bash implementation for maximum compatibility
- **Cross-Platform**: Works on macOS, Linux, and Windows (WSL)
- **Extensible**: Easy to create custom templates and commands
- **Non-Destructive**: Always preserves your existing configurations

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

## Documentation

### 📚 Complete Documentation Hub

Our comprehensive documentation covers every aspect of Claude Flow:

#### 🚀 Getting Started
- **[Prerequisites](docs/getting-started/prerequisites.md)** - System requirements and dependencies
- **[Installation Guide](docs/getting-started/installation.md)** - Detailed installation for all platforms
- **[Quick Start](docs/getting-started/quick-start.md)** - Get up and running in minutes
- **[First Project Tutorial](docs/getting-started/first-project.md)** - Build your first Claude Flow project
- **[Configuration](docs/getting-started/configuration.md)** - Initial setup and customization

#### 📖 User Guide
- **[Overview](docs/user-guide/overview.md)** - Features and capabilities
- **[Using Templates](docs/user-guide/using-templates.md)** - Language and framework templates
- **[Smart Merge](docs/user-guide/smart-merge.md)** - Intelligent configuration merging
- **[Customization](docs/user-guide/customization.md)** - Tailoring Claude Flow to your needs
- **[Best Practices](docs/user-guide/best-practices.md)** - Professional tips and patterns
- **[Workflows](docs/user-guide/workflows.md)** - Common development workflows

#### 🛠️ API & CLI Reference
- **[CLI Reference](docs/api/cli-reference.md)** - Complete command documentation
- **[Script API](docs/api/script-api.md)** - Shell script function reference
- **[Environment Variables](docs/api/environment-variables.md)** - Configuration options
- **[Exit Codes](docs/api/exit-codes.md)** - Error handling reference
- **[Options & Flags](docs/api/options-flags.md)** - Command-line parameters

#### 🏗️ Architecture
- **[System Overview](docs/architecture/system-overview.md)** - High-level architecture
- **[Directory Structure](docs/architecture/directory-structure.md)** - Project organization
- **[Template System](docs/architecture/template-system.md)** - Template engine design
- **[Merge Algorithm](docs/architecture/merge-algorithm.md)** - Smart merge implementation
- **[Design Decisions](docs/architecture/design-decisions.md)** - Architectural rationale

#### 💻 Development
- **[Setup Guide](docs/development/setup.md)** - Developer environment setup
- **[Contributing](docs/development/contributing.md)** - How to contribute
- **[Testing](docs/development/testing.md)** - Test suite and strategies
- **[Creating Templates](docs/development/creating-templates.md)** - Build custom templates
- **[Extending Claude Flow](docs/development/extending-claude-flow.md)** - Add new features
- **[Code Style](docs/development/code-style.md)** - Coding standards

#### 🚢 Deployment & Operations
- **[System Deployment](docs/deployment/system-deployment.md)** - Enterprise installation
- **[User Deployment](docs/deployment/user-deployment.md)** - Individual setup
- **[Enterprise Setup](docs/deployment/enterprise-setup.md)** - Large-scale deployment
- **[Updates](docs/deployment/updates.md)** - Upgrade procedures
- **[Backup & Recovery](docs/deployment/backup-recovery.md)** - Data protection
- **[Security](docs/deployment/security.md)** - Security best practices

#### 🔧 Troubleshooting
- **[Common Issues](docs/troubleshooting/common-issues.md)** - Frequent problems and solutions
- **[Installation Problems](docs/troubleshooting/installation-problems.md)** - Setup troubleshooting
- **[Template Issues](docs/troubleshooting/template-issues.md)** - Template-related problems
- **[Merge Conflicts](docs/troubleshooting/merge-conflicts.md)** - Resolving merge issues
- **[FAQ](docs/troubleshooting/faq.md)** - Frequently asked questions
- **[Debugging](docs/troubleshooting/debugging.md)** - Advanced debugging techniques

#### 📝 Examples & Tutorials
- **[JavaScript Project](docs/examples/javascript-project.md)** - Node.js setup example
- **[Python Project](docs/examples/python-project.md)** - Python development guide
- **[React Application](docs/examples/react-app.md)** - React with TypeScript
- **[Multi-Language Project](docs/examples/multi-language.md)** - Full-stack example
- **[CI/CD Setup](docs/examples/ci-cd-setup.md)** - Continuous integration
- **[Migration Guide](docs/examples/migration-guide.md)** - Migrating existing projects

### 🎯 Quick Links by User Type

#### For New Users
1. Start with [Prerequisites](docs/getting-started/prerequisites.md)
2. Follow the [Installation Guide](docs/getting-started/installation.md)
3. Try the [First Project Tutorial](docs/getting-started/first-project.md)

#### For Existing Projects
1. Read the [Migration Guide](docs/examples/migration-guide.md)
2. Learn about [Smart Merge](docs/user-guide/smart-merge.md)
3. Check [Best Practices](docs/user-guide/best-practices.md)

#### For Contributors
1. Set up with [Developer Setup](docs/development/setup.md)
2. Read [Contributing Guidelines](docs/development/contributing.md)
3. Explore [Creating Templates](docs/development/creating-templates.md)

#### For Enterprise Users
1. Review [Enterprise Setup](docs/deployment/enterprise-setup.md)
2. Plan with [System Deployment](docs/deployment/system-deployment.md)
3. Implement [Security Best Practices](docs/deployment/security.md)

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

## Features

### 🎯 Core Capabilities

- **Intelligent Template System**: Automatically detects your project type and suggests appropriate templates
- **Safe Merge Operations**: Never overwrites your existing configurations without explicit confirmation
- **Command Library**: Pre-built Claude commands for common development tasks
- **Multi-Platform Support**: Native support for macOS, Linux, and Windows (WSL)
- **Zero External Dependencies**: Pure bash implementation ensures maximum compatibility
- **Extensible Architecture**: Easy to add custom templates and commands

## Supported Languages & Frameworks

### 🔤 Programming Languages

| Language | Features | Template Location |
|----------|----------|-------------------|
| **JavaScript/TypeScript** | ESLint, Prettier, Jest, Node.js best practices | `templates/languages/javascript/` |
| **Python** | Black, Flake8, MyPy, Pytest, virtual environments | `templates/languages/python/` |
| **Go** | Go modules, testing, benchmarking, linting | `templates/languages/go/` |
| **Rust** | Cargo, Clippy, rustfmt, testing patterns | `templates/languages/rust/` |
| **PHP** | PSR standards, Composer, PHPUnit, static analysis | `templates/languages/php/` |

### 🚀 Frameworks

| Framework | Features | Template Location |
|-----------|----------|-------------------|
| **React** | TypeScript, hooks, testing, state management | `templates/frameworks/react/` |
| **Next.js** | SSR/SSG, API routes, optimizations | `templates/frameworks/nextjs/` |
| **Django** | Models, views, testing, migrations | `templates/frameworks/django/` |
| **Express.js** | Middleware, routing, error handling | `templates/frameworks/express/` |

### 📋 Claude Commands

The `.claude/commands/` directory includes powerful development commands:

| Command | Purpose | Use Case |
|---------|---------|----------|
| `architect.md` | System architecture planning | Design new features or systems |
| `debug.md` | Debugging assistance | Troubleshoot complex issues |
| `optimize.md` | Performance optimization | Improve code efficiency |
| `refactor.md` | Code refactoring guidance | Clean up technical debt |
| `review.md` | Code review assistance | Ensure code quality |
| `test-coverage.md` | Testing strategies | Improve test coverage |
| `security-audit.md` | Security analysis | Find vulnerabilities |
| `migrate.md` | Migration planning | Update dependencies or frameworks |
| `monitor.md` | Monitoring setup | Add observability |
| `api-design.md` | API design assistance | Create consistent APIs |

### 🔧 Workflow Templates

- **CI/CD**: GitHub Actions, GitLab CI, Jenkins configurations
- **Testing**: Automated testing setups for various frameworks
- **Documentation**: Auto-documentation generation tools

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

## Community & Support

### 🤝 Getting Help

- **Documentation**: Start with our [comprehensive documentation](docs/)
- **Issues**: Report bugs or request features on [GitHub Issues](https://github.com/your-repo/claude-flow/issues)
- **Discussions**: Join community discussions on [GitHub Discussions](https://github.com/your-repo/claude-flow/discussions)
- **Examples**: Check out the [examples directory](docs/examples/) for practical use cases

### 💡 Resources

- [First Project Tutorial](docs/getting-started/first-project.md) - Step-by-step guide
- [FAQ](docs/troubleshooting/faq.md) - Answers to common questions
- [Troubleshooting Guide](docs/troubleshooting/) - Solutions to common problems
- [Best Practices](docs/user-guide/best-practices.md) - Professional tips

## Contributing

We welcome contributions! Please see our [Contributing Guide](docs/development/contributing.md) for details.

### Quick Start for Contributors

1. Fork the repository
2. Set up your development environment: [Developer Setup](docs/development/setup.md)
3. Create feature branches for changes
4. Add tests for new functionality
5. Run the test suite: `cd test && ./run-tests.sh`
6. Submit pull requests

### Ways to Contribute

- 📝 **Documentation**: Help improve our docs
- 🐛 **Bug Reports**: Report issues you encounter
- ✨ **Features**: Suggest or implement new features
- 🔧 **Templates**: Create templates for new languages/frameworks
- 🧪 **Testing**: Improve test coverage
- 🌐 **Translations**: Help translate documentation

## License

This project is licensed under the MIT License.