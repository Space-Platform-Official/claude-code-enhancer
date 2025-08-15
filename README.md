# Claude Code Enhancer

> **Intelligent Development Toolkit with Multi-Agent Coordination**

Transform your development workflow with sophisticated automation, intelligent quality assurance, and multi-agent coordination powered by Claude AI.

[![CI Status](https://github.com/user/claude-code-enhancer/workflows/CI/badge.svg)](https://github.com/user/claude-code-enhancer/actions)
[![Quality Gate](https://sonarcloud.io/api/project_badges/measure?project=claude-code-enhancer&metric=alert_status)](https://sonarcloud.io/dashboard?id=claude-code-enhancer)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=claude-code-enhancer&metric=security_rating)](https://sonarcloud.io/dashboard?id=claude-code-enhancer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

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

Claude Code Enhancer is a production-ready development intelligence platform that transforms software development through:

- **🤖 Multi-Agent Coordination**: Sophisticated parallel processing with specialized AI agents
- **🏗️ Safety-First Architecture**: Multi-layer validation with zero-tolerance quality enforcement  
- **📚 Intelligent Templates**: Smart template inheritance with conflict-free composition
- **⚡ Quality Automation**: Comprehensive code quality, testing, and security workflows
- **🔗 Universal Integration**: Seamless Git, CI/CD, and development tool integration
- **📊 Enterprise Ready**: Scalable for teams with compliance, monitoring, and governance

### 🚀 Key Differentiators

- **100% Success Rate Requirement**: All quality gates must pass - no exceptions
- **Progressive Complexity Enforcement**: Automatic over-engineering prevention 
- **Agent Specialization**: Domain-specific AI agents for optimal results
- **State-Driven Recovery**: Full interruption recovery with session persistence
- **Zero File Proliferation**: Intelligent consolidation prevents project bloat
- **Claude Code Integration**: Native hook system for seamless tool integration
- **86 Specialized Commands**: Comprehensive command library for all development phases

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

After installation, the tools will be available for enhancing your Claude Code setup.

## Post-Installation Usage

### What Gets Installed

When you run `./install.sh`, the following components are installed:

**Commands Created:**
- `claude-merge` - Smart configuration merger and command installer
- Additional tools for project enhancement

**Installation Locations:**
- **User Install (`--user`)**: Commands in `~/.local/bin/`, templates in `~/.local/share/claude-code-enhancer/`
- **System Install (`--system`)**: Commands in `/usr/local/bin/`, templates in `/usr/local/share/claude-code-enhancer/`

### Using claude-merge

The `claude-merge` command is your primary tool for setting up and maintaining Claude Code configurations in any project.

**Basic Usage:**
```bash
# Navigate to your project directory
cd /path/to/your/project

# Run claude-merge to install/update Claude Code configuration
claude-merge

# Or specify a target directory
claude-merge /path/to/target/project
```

**What claude-merge Does:**
1. **Merges CLAUDE.md**: Intelligently merges template configuration with existing project settings
2. **Installs Commands**: Deploys 86+ development commands to `.claude/commands/`
3. **Sets Up Hooks**: Configures pre/post edit hooks for quality enforcement
4. **Updates Settings**: Merges settings.json for tool permissions and configurations
5. **Creates Backups**: Automatically backs up existing configurations before changes

### Example Workflow

```bash
# 1. Install the Claude Code Enhancer system
./install.sh --user

# 2. Navigate to your existing project
cd ~/projects/my-app

# 3. Run claude-merge to enhance your project
claude-merge

# 4. Verify installation
ls -la .claude/          # Check commands and hooks
cat CLAUDE.md           # View merged configuration

# 5. Start using enhanced Claude Code features
# Your project now has access to all commands and automated quality gates
```


## 📖 Documentation

### 🎯 **Quick Start**
- [**User Guide**](./docs/USER-GUIDE.md#getting-started) - Complete user documentation
- [**Quick Start**](./docs/USER-GUIDE.md#quick-start) - Get up and running in minutes
- [**Installation**](./docs/USER-GUIDE.md#installation) - Detailed setup instructions

### 👥 **User Guides**
- [**Core Features**](./docs/USER-GUIDE.md#core-features) - System overview and capabilities
- [**Workflows & Best Practices**](./docs/USER-GUIDE.md#workflows--best-practices) - Development patterns
- [**Template System**](./docs/USER-GUIDE.md#using-templates) - Language and framework templates
- [**Examples & Use Cases**](./docs/USER-GUIDE.md#examples--use-cases) - Real-world scenarios
- [**Troubleshooting**](./docs/USER-GUIDE.md#troubleshooting) - Common issues and solutions

### 📋 **Command Reference**
- [**Command Reference**](./docs/DEVELOPER-GUIDE.md#command-reference) - Complete command catalog
- [**Development Guides**](./docs/DEVELOPER-GUIDE.md#development-guides) - Template and command development
- [**Quality Standards**](./docs/DEVELOPER-GUIDE.md#quality--standards) - Testing and quality guidelines
- [**Advanced Development**](./docs/DEVELOPER-GUIDE.md#advanced-development) - Performance and debugging
- [**Milestone System**](./docs/USER-GUIDE.md#milestone-system) - Project planning and execution

### 🏗️ **Architecture**
- [**System Overview**](./docs/ARCHITECTURE.md#system-overview) - High-level design and components
- [**Core Systems**](./docs/ARCHITECTURE.md#core-systems) - Multi-agent, command, and template systems
- [**Safety & Validation**](./docs/ARCHITECTURE.md#safety--validation) - Quality enforcement framework
- [**Integration Layer**](./docs/ARCHITECTURE.md#integration-layer) - Tool ecosystem integration
- [**Advanced Architecture**](./docs/ARCHITECTURE.md#advanced-architecture) - Performance and scalability

### 🔧 **Developer Resources**
- [**Developer Guide**](./docs/DEVELOPER-GUIDE.md) - Complete development documentation
- [**Contributing**](./docs/DEVELOPER-GUIDE.md#development-setup) - Setup and contribution guidelines
- [**Creating Commands**](./docs/DEVELOPER-GUIDE.md#command-development) - Build custom commands and extensions
- [**Template Development**](./docs/DEVELOPER-GUIDE.md#template-development) - Create and customize templates
- [**Testing Guidelines**](./docs/DEVELOPER-GUIDE.md#testing-guidelines) - Testing strategies and requirements

### 📚 **Examples & Tutorials**
- [**Example Projects**](./docs/USER-GUIDE.md#examples--use-cases) - Complete project examples and tutorials
- [**JavaScript Projects**](./docs/USER-GUIDE.md#javascript-projects) - Node.js, React, testing workflows
- [**Python Projects**](./docs/USER-GUIDE.md#python-projects) - Django, Flask, data science patterns  
- [**Multi-Language Setup**](./docs/USER-GUIDE.md#multi-language-projects) - Go, Rust, PHP enterprise patterns
- [**CI/CD Integration**](./docs/USER-GUIDE.md#cicd-integration) - Production deployment pipelines
- [**Real-World Scenarios**](./docs/USER-GUIDE.md#real-world-scenarios) - Enterprise patterns and migration

### 🔌 **API Reference**
- [**Command Reference**](./docs/DEVELOPER-GUIDE.md#command-reference) - Complete CLI documentation
- [**Configuration**](./docs/USER-GUIDE.md#configuration-guide) - Environment variables and settings
- [**Development Guides**](./docs/DEVELOPER-GUIDE.md#development-guides) - Plugin and extension development
- [**Integration Architecture**](./docs/ARCHITECTURE.md#integration-layer) - Git, CI/CD, and tool integrations
- [**Template System**](./docs/ARCHITECTURE.md#core-systems) - Template architecture and APIs

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

Installs Claude Code Enhancer tools system-wide or for the current user.

**Usage:**
```bash
./install.sh [OPTIONS]
```

**Options:**
- `--user` - Install for current user only (`~/.local/`)
- `--system` - Install system-wide (`/usr/local/`)
- `--uninstall` - Remove Claude Code Enhancer tools
- `--help` - Show help message

**Installation Locations:**
- **User Install:** `~/.local/bin/` and `~/.local/share/claude-code-enhancer/`
- **System Install:** `/usr/local/bin/` and `/usr/local/share/claude-code-enhancer/`

### `claude-merge` - Smart Configuration Merger

Intelligently merges Claude Code configurations and installs development commands in your project.

**Usage:**
```bash
claude-merge [target-directory]
```

**Features:**
- **Smart CLAUDE.md Merging**: Preserves your custom content while updating template sections
- **Command Installation**: Deploys 86+ specialized commands to `.claude/commands/`
- **Hook Integration**: Sets up pre/post edit hooks for quality enforcement
- **Settings Management**: Intelligently merges JSON configurations
- **Automatic Backups**: Creates timestamped backups before any changes
- **Self-Updating**: Automatically updates itself when newer versions are available

**Smart Merge Process:**
1. **Preserves Custom Content**: Your project-specific configurations remain untouched
2. **Updates Template Section**: Marked template content is updated to latest version
3. **Installs Commands**: Copies all command templates to `.claude/commands/`
4. **Relocates Shared Utilities**: Organizes shared code to `.claude/shared/`
5. **Configures Hooks**: Sets up quality enforcement hooks

**Example:**
```bash
# Enhance current project
claude-merge

# Enhance specific project
claude-merge ~/projects/my-app

# What happens:
# ✓ CLAUDE.md merged with preservation of custom content
# ✓ 86+ commands installed to .claude/commands/
# ✓ Hooks configured in .claude/hooks/
# ✓ Settings merged in .claude/settings.local.json
# ✓ Backups created as *.backup.[timestamp]
```

**Safety Features:**
- **Atomic Operations**: All changes are atomic with rollback capability
- **Content Fingerprinting**: Skips unnecessary updates via SHA256 validation
- **Marker Integrity**: Validates merge markers to prevent corruption
- **Automatic Cleanup**: Removes old backups (configurable retention)
- **Lock Files**: Prevents concurrent merge operations

### `claude-pre-edit-adapter.sh` - Pre-Edit Hook Adapter

Validates and prepares files before Claude Code makes edits.

**Usage:**
```bash
.claude/hooks/claude-pre-edit-adapter.sh <file-path>
```

**Features:**
- Pre-validation of file changes
- Language-specific checks (PHP PSR standards)
- Error prevention before modifications
- Integration with Claude Code's edit tools

### `claude-post-edit-adapter.sh` - Post-Edit Hook Adapter

Processes and validates files after Claude Code makes edits.

**Usage:**
```bash
.claude/hooks/claude-post-edit-adapter.sh <file-path>
```

**Features:**
- Automatic code formatting
- Post-edit validation
- Language-specific processing (PHP paradigm enforcement)
- Quality gate enforcement

## 🔗 Claude Code Integration

Claude Code Enhancer seamlessly integrates with Claude Code's advanced development tools through intelligent hook adapters:

### **Hook System Architecture**
- **🔄 Pre-Edit Validation**: Automatic validation before file modifications
- **✅ Post-Edit Processing**: Smart formatting and quality enforcement after edits
- **🔧 PHP Paradigm Integration**: Automatic PSR standards enforcement for PHP files
- **⚙️ Settings Template**: Configurable permissions and tool access control

### **Hook Adapters**
```bash
# Pre-edit adapter - Validates changes before applying
.claude/hooks/claude-pre-edit-adapter.sh

# Post-edit adapter - Formats and validates after changes
.claude/hooks/claude-post-edit-adapter.sh

# PHP-specific paradigm enforcement
.claude/hooks/php-paradigm/pre-edit.sh
.claude/hooks/php-paradigm/post-edit.sh
```

### **Automatic Quality Enforcement**
- **Zero-tolerance validation**: All edits must pass quality gates
- **Language-specific formatting**: Automatic code style enforcement
- **Error prevention**: Pre-validation catches issues before they occur
- **Seamless integration**: Works transparently with Claude Code tools

## 🤖 Multi-Agent Coordination

Claude Code Enhancer's breakthrough innovation is its sophisticated multi-agent AI system:

### **Specialized Agent Types**
- **🏗️ Task Execution Agents**: Parallel command processing and optimization
- **📊 Progress Monitoring Agents**: Real-time tracking and performance analysis
- **🔗 Git Integration Agents**: Smart merge conflict resolution and workflow automation
- **🛡️ Quality Gate Agents**: Comprehensive validation and compliance checking
- **🔒 Security Agents**: Vulnerability detection and remediation
- **⚡ Performance Agents**: Load testing and optimization recommendations

### **Agent Coordination Patterns**
```bash
# Example: Comprehensive project setup with agent coordination
"I'll spawn multiple agents to set up your project comprehensively:
- Setup Agent: Project structure and configuration
- Template Agent: Smart template selection and application  
- Quality Agent: Code style and validation setup
- Integration Agent: Git, CI/CD, and tool configuration
- Documentation Agent: README and documentation generation"
```

### **Intelligent Orchestration**
- **Dynamic Agent Spawning**: Context-aware agent deployment based on task complexity
- **Resource Management**: Optimal CPU and memory allocation across agents
- **Error Recovery**: Autonomous error detection and recovery with rollback capabilities
- **State Synchronization**: Coordinated state management across distributed agents

## 🏗️ Architecture Highlights

### **Safety-First Design**
- **🔒 Zero-Tolerance Quality**: 100% success rate requirement with no exceptions
- **📋 Progressive Complexity Triage**: Mandatory categorization (🟢 Simple/🟡 Medium/🔴 Complex)
- **🛡️ Multi-Layer Validation**: Pre-operation checks, execution monitoring, post-validation
- **💾 State Recovery**: Full session persistence with checkpoint/resume capability

### **Intelligent Template System**  
- **📚 Hierarchical Inheritance**: Base → Enhanced → Framework → Custom
- **🧩 Smart Composition**: Conflict-free merging with intelligent resolution
- **🔄 Progressive Disclosure**: On-demand content generation and feature revelation
- **⚙️ Framework Detection**: Automatic optimization for detected frameworks

### **Enterprise-Grade Features**
- **👥 Team Collaboration**: Shared standards, centralized configuration, role-based access
- **📊 Compliance & Governance**: Audit trails, security scanning, compliance reporting
- **⚡ Performance Optimization**: Large codebase handling, intelligent caching, resource management
- **🔗 Universal Integration**: Git, CI/CD, IDE, testing framework seamless integration

## 🎯 Key Features

### **Quality Assurance Suite**
- **🎨 Multi-Language Formatting**: Universal code style with framework detection
- **🧹 Intelligent Cleanup**: Dead code removal, import optimization, dependency analysis
- **🔍 Advanced Deduplication**: Smart duplicate detection with context-aware merging
- **✅ Comprehensive Verification**: Multi-layer quality validation with detailed reporting
- **🔗 Claude Code Integration**: Seamless hook system for edit validation and processing

### **Testing Framework**
- **⚡ Parallel Test Execution**: Multi-agent test coordination for optimal performance
- **📊 Coverage Analysis**: Comprehensive coverage reporting with gap identification
- **🔧 Framework Integration**: Jest, pytest, Go test, RSpec with intelligent configuration
- **🚀 Performance Testing**: Load testing, benchmarking, and optimization recommendations

### **Git Integration**
- **🔀 Smart PR Management**: Automated PR creation with quality gate enforcement
- **💾 Intelligent Commits**: Semantic commit messages with validation
- **🌿 Branch Management**: Feature branch workflows with smart conflict resolution
- **🔒 Security Integration**: Commit signing, security scanning, compliance checks

### **Milestone Management**
- **📋 Intelligent Planning**: AI-powered milestone decomposition and task breakdown
- **📊 Progress Tracking**: Real-time progress monitoring with automated reporting
- **🔄 Resume Capability**: Interruption-tolerant execution with state persistence
- **📈 Performance Analytics**: Velocity tracking, bottleneck identification, optimization suggestions

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

The `.claude/commands/` directory includes **86 comprehensive development commands** organized by category:

**Core Development Commands:**
| Command | Purpose | Use Case |
|---------|---------|----------|
| `architect.md` | System architecture planning | Design new features or systems |
| `debug.md` | Debugging assistance | Troubleshoot complex issues |
| `optimize.md` | Performance optimization | Improve code efficiency |
| `refactor.md` | Code refactoring guidance | Clean up technical debt |
| `review.md` | Code review assistance | Ensure code quality |

**Testing & Quality Commands:**
| Command | Purpose | Use Case |
|---------|---------|----------|
| `test/*.md` | Comprehensive testing suite | Unit, integration, coverage testing |
| `quality/*.md` | Code quality enforcement | Formatting, linting, validation |
| `security-audit.md` | Security analysis | Find vulnerabilities |

**Workflow & Integration Commands:**
| Command | Purpose | Use Case |
|---------|---------|----------|
| `git/*.md` | Git workflow automation | Commits, PRs, branch management |
| `milestone/*.md` | Project planning | Sprint planning, task tracking |
| `api-design.md` | API design assistance | Create consistent APIs |
| `migrate.md` | Migration planning | Update dependencies or frameworks |
| `monitor.md` | Monitoring setup | Add observability |

**Complete command library includes 86 specialized commands across all development phases**

### 🔧 Workflow Templates

- **CI/CD**: GitHub Actions, GitLab CI, Jenkins configurations
- **Testing**: Automated testing setups for various frameworks
- **Documentation**: Auto-documentation generation tools

## Smart Merge Features

### Intelligent CLAUDE.md Merging

The `claude-merge` command uses a sophisticated marker-based system to separate and preserve your custom content:

```markdown
# Your custom project rules and guidelines
# This content is ALWAYS preserved

# ========== CLAUDE FLOW TEMPLATE ==========
# Auto-updated: 2025-08-02 20:04:37
# Template content (automatically updated)
```

**Key Benefits:**
- **Never Loses Custom Content**: Your project-specific rules are always preserved
- **Automatic Updates**: Template sections update to latest best practices
- **Conflict-Free**: Marker system prevents merge conflicts
- **Version Tracking**: Timestamps show when templates were last updated

### Command Installation System

When `claude-merge` runs, it installs a comprehensive command library:

**Command Structure:**
```
.claude/
├── commands/          # 86+ specialized development commands
│   ├── git/          # Git workflow automation
│   ├── test/         # Testing strategies
│   ├── quality/      # Code quality tools
│   ├── milestone/    # Project planning
│   └── ...           # Many more categories
├── shared/           # Centralized shared utilities
│   ├── git/          # Git-specific utilities
│   ├── test/         # Testing utilities
│   └── quality/      # Quality check utilities
└── hooks/            # Quality enforcement hooks
```

**Shared Utility Organization:**
- Eliminates duplication across commands
- Centralizes common functionality
- Automatically updates references
- Maintains clean separation of concerns

### Safety and Validation

**Backup System:**
- Creates timestamped backups: `filename.backup.1234567890`
- Configurable retention (default: 24 hours)
- Automatic cleanup of old backups
- Preserves last 5 backups minimum

**Validation Layers:**
1. **Pre-Merge Validation**: Checks file integrity and markers
2. **Content Fingerprinting**: SHA256 validation prevents unnecessary updates
3. **Atomic Operations**: All-or-nothing changes with rollback capability
4. **Post-Merge Verification**: Validates successful installation

**Environment Controls:**
```bash
# Customize merge behavior
export CLAUDE_MERGE_BACKUP=false              # Disable backups (not recommended)
export CLAUDE_MERGE_BACKUP_RETENTION=48       # Keep backups for 48 hours
export CLAUDE_MERGE_AUTO_UPDATE=false         # Disable auto-update of claude-merge
```

## Configuration

### Environment Variables

**Template Source Locations** (searched in order):
1. `$CLAUDE_TEMPLATES_DIR` - Custom template directory
2. `$CLAUDE_TEMPLATE_SOURCE` - Legacy environment variable
3. `~/.local/share/claude-code-enhancer/templates` - User installation
4. `/usr/local/share/claude-code-enhancer/templates` - System installation
5. Local `templates/` directory - Development mode

**Example:**
```bash
# Use custom templates
export CLAUDE_TEMPLATES_DIR="/path/to/my/templates"
```

### Settings Configuration

**Hook System Settings** (`.claude/hooks/settings-template.json`):

The settings template configures Claude Code's permissions and tool access:

```json
{
  "permissions": {
    "bash": {
      "allowed_patterns": [
        "chmod:*",
        "git add:*",
        "git commit:*",
        "./test:*",
        "npm run:*"
      ]
    },
    "edit": {
      "pre_hook": ".claude/hooks/claude-pre-edit-adapter.sh",
      "post_hook": ".claude/hooks/claude-post-edit-adapter.sh"
    }
  },
  "hooks": {
    "enabled": true,
    "language_specific": {
      "php": {
        "pre_edit": ".claude/hooks/php-paradigm/pre-edit.sh",
        "post_edit": ".claude/hooks/php-paradigm/post-edit.sh"
      }
    }
  }
}
```

**Configuration Features:**
- **Permission Control**: Define allowed bash command patterns
- **Hook Integration**: Configure pre/post edit hooks
- **Language-Specific Rules**: Apply paradigm-specific processing
- **Tool Access Management**: Control Claude Code's tool permissions

## Development

### Directory Structure

```
claude-code-enhancer/
├── install.sh                 # System installation script
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

Installation automatically creates backups of modified files for easy recovery if needed.

## Troubleshooting

### Common Issues

**Templates not found:**
```bash
# Check template locations
echo $CLAUDE_TEMPLATES_DIR
ls ~/.local/share/claude-code-enhancer/templates
ls /usr/local/share/claude-code-enhancer/templates
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
# Remove all Claude Code Enhancer installations
./install.sh --uninstall

# Or manually remove
rm -rf ~/.local/share/claude-code-enhancer
rm -rf /usr/local/share/claude-code-enhancer
```

## Community & Support

### 🤝 Getting Help

- **Documentation**: Start with our [comprehensive documentation](docs/)
- **Issues**: Report bugs or request features on [GitHub Issues](https://github.com/Space-Platform-Official/claude-code-enhancer/issues)
- **Discussions**: Join community discussions on [GitHub Discussions](https://github.com/Space-Platform-Official/claude-code-enhancer/discussions)
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