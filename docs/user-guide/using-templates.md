# Using Claude Code Enhancer Templates

This comprehensive guide explains how to effectively use Claude Code Enhancer templates to set up, configure, and optimize your development projects with intelligent command systems, quality tools, and workflow automation.

## 📋 Table of Contents

- [Understanding Templates](#understanding-templates)
- [Template Architecture](#template-architecture)
- [Installation Methods](#installation-methods)
- [Template Categories](#template-categories)
- [Quality System Integration](#quality-system-integration)
- [Command Templates](#command-templates)
- [Customization and Extension](#customization-and-extension)
- [Multi-Language Support](#multi-language-support)
- [Best Practices](#best-practices)
- [Advanced Usage](#advanced-usage)

## Understanding Templates

Claude Code Enhancer templates are sophisticated, pre-configured sets of files, commands, and configurations designed to optimize development workflows for specific languages, frameworks, and project types. Each template provides:

- **Intelligent Command Library**: Pre-built commands for quality, testing, git workflows, and project management
- **Quality System Integration**: Automated code formatting, cleanup, verification, and deduplication tools
- **Language-Specific Optimizations**: Tailored configurations for optimal development experience
- **Workflow Automation**: Milestone management, multi-agent coordination, and CI/CD integration
- **Safety Mechanisms**: Backup systems, rollback capabilities, and validation frameworks

## Template Architecture

Claude Code Enhancer uses a sophisticated hierarchical template system that provides maximum flexibility while maintaining consistency:

### Template Directory Structure

```
templates/
├── CLAUDE.md                    # Master base configuration
├── base/                        # Core foundational templates
│   └── CLAUDE.md               # Minimal base setup
├── languages/                   # Language-specific configurations
│   ├── javascript/
│   │   ├── CLAUDE.md           # JavaScript best practices
│   │   └── CLAUDE_ENHANCED.md  # Advanced JavaScript features
│   ├── python/                 # Python ecosystem
│   ├── go/                     # Go language support
│   ├── rust/                   # Rust development
│   └── php/                    # PHP modern practices
├── frameworks/                  # Framework-specific extensions
│   ├── react/                  # React component patterns
│   ├── nextjs/                 # Next.js optimizations
│   ├── django/                 # Django web framework
│   └── express/                # Express.js server patterns
├── commands/                    # Comprehensive command library
│   ├── quality/                # Code quality suite
│   │   ├── format.md           # Code formatting
│   │   ├── cleanup.md          # Dead code removal
│   │   ├── dedupe.md           # Duplicate detection
│   │   └── verify.md           # Quality verification
│   ├── git/                    # Git workflow automation
│   │   ├── commit.md           # Smart commit process
│   │   ├── pr.md               # Pull request creation
│   │   └── workflows/          # Git workflow patterns
│   ├── test/                   # Testing framework
│   │   ├── unit.md             # Unit testing
│   │   ├── integration.md      # Integration testing
│   │   ├── coverage.md         # Coverage analysis
│   │   └── workflows/          # Test workflows
│   ├── milestone/              # Project management
│   │   ├── plan.md             # Milestone planning
│   │   ├── execute.md          # Execution tracking
│   │   └── status.md           # Progress monitoring
│   └── quickstart/             # Quick commands (gs, gc, gp, gf)
└── workflows/                   # Automation templates
    ├── ci-cd/                  # Continuous integration
    ├── documentation/          # Auto-documentation
    └── testing/                # Test automation
```

### Template Inheritance Hierarchy

Templates follow an inheritance model for maximum reusability:

1. **Base Template** (`base/CLAUDE.md`): Core Claude Code configuration
2. **Language Template** (`languages/*/CLAUDE.md`): Language-specific patterns and tools
3. **Framework Template** (`frameworks/*/CLAUDE.md`): Framework-specific conventions
4. **Enhanced Variants** (`*_ENHANCED.md`): Advanced features and optimizations

### Smart Merging System

The template system uses intelligent merging to combine configurations:

- **Content Preservation**: Existing project configuration is never overwritten
- **Section-Based Merging**: Templates merge at logical section boundaries
- **Conflict Resolution**: Interactive resolution for conflicting configurations
- **Backup Creation**: Automatic backups before any changes

## Installation Methods

### Basic Installation

To install templates in your current directory:

```bash
claude-install-flow
```

To install in a specific directory:

```bash
claude-install-flow /path/to/project
```

### Interactive Selection

When you run `claude-install-flow`, you'll be prompted to:

1. **Select a programming language**:
   ```
   Select programming language:
   1) JavaScript   4) Rust
   2) Python       5) PHP
   3) Go           6) TypeScript
   ```

2. **Select a framework** (if applicable):
   ```
   Select framework:
   1) None (just JavaScript)
   2) React
   3) Express
   4) Next.js
   ```

3. **Confirm installation**:
   ```
   Will install: JavaScript + React templates
   Target directory: /path/to/project
   Continue? (y/n)
   ```

## Template Categories

### Language Templates

Each language template includes:

#### JavaScript/TypeScript
- Modern ES6+ patterns and conventions
- NPM/Yarn package management guidance
- Testing with Jest/Mocha patterns
- ESLint and Prettier configurations
- Node.js best practices

#### Python
- PEP 8 compliance and style guide
- Virtual environment management
- Testing with pytest patterns
- Type hints and mypy integration
- Package management with pip/poetry

#### Go
- Go modules and workspace setup
- Testing and benchmarking patterns
- Error handling conventions
- Concurrency best practices
- Standard library preferences

#### Rust
- Cargo workspace management
- Memory safety patterns
- Error handling with Result/Option
- Testing and documentation
- Clippy and rustfmt integration

#### PHP
- PSR standards compliance
- Composer dependency management
- Testing with PHPUnit
- Modern PHP 8+ features
- Security best practices

### Framework Templates

Framework templates build upon language templates:

#### React
- Component architecture patterns
- State management guidance
- Hook usage best practices
- Testing with React Testing Library
- Performance optimization tips

#### Next.js
- App Router vs Pages Router patterns
- Server Components best practices
- API route conventions
- Static generation vs SSR guidance
- Deployment optimization

#### Django
- MVT architecture patterns
- Model design best practices
- View and template organization
- Django REST framework integration
- Security and authentication

#### Express.js
- Middleware patterns
- Route organization
- Error handling middleware
- Authentication strategies
- API design conventions

## Quality System Integration

Claude Code Enhancer templates include a comprehensive quality management system that works seamlessly across all supported languages and frameworks:

### Quality Command Suite

Every template installation includes the modular quality command suite:

#### **Format Command** (`claude format`)
- **Multi-language Formatters**: Automatic detection and configuration of language-specific formatters
- **Tool Integration**: Prettier, ESLint, Black, rustfmt, gofmt, and more
- **Import Organization**: Intelligent import sorting and cleanup
- **Configuration Discovery**: Automatic detection of existing formatter configurations

**Example Usage**:
```bash
# Format all files in project
claude format

# Format specific directory
claude format src/

# Preview changes without applying
claude format --dry-run

# Comprehensive multi-pass formatting
claude format --comprehensive
```

#### **Cleanup Command** (`claude cleanup`)
- **Dead Code Detection**: Identify and remove unused functions, variables, and imports
- **Import Optimization**: Remove unused imports and organize remaining ones
- **Comment Cleanup**: Handle TODO/FIXME comments and debug statements
- **Safety Mechanisms**: Conservative mode with backup creation

**Example Usage**:
```bash
# Standard cleanup
claude cleanup

# Aggressive cleanup (more thorough)
claude cleanup --aggressive

# Conservative cleanup (safer)
claude cleanup --conservative

# Only clean imports
claude cleanup --imports-only
```

#### **Dedupe Command** (`claude dedupe`)
- **Advanced Detection**: Function-level, block-level, and import-level duplicate detection
- **Similarity Analysis**: Configurable similarity thresholds for smart matching
- **Interactive Review**: Manual review mode for guided decisions
- **Intelligent Merging**: Automatic merging of similar code blocks

**Example Usage**:
```bash
# Find and resolve duplicates
claude dedupe

# Interactive mode for manual review
claude dedupe --interactive

# Set custom similarity threshold
claude dedupe --threshold=85

# Focus on specific duplicate types
claude dedupe --functions-only
```

#### **Verify Command** (`claude verify`)
- **Comprehensive Validation**: Syntax checking, security scanning, quality metrics
- **Multi-format Reporting**: Text, JSON, HTML output formats
- **Security Focus**: Vulnerability scanning and security best practices validation
- **Integration Testing**: Tool configuration validation and integration checks

**Example Usage**:
```bash
# Standard verification
claude verify

# Comprehensive quality assessment
claude verify --comprehensive

# Security-focused verification
claude verify --security-focus

# Quick syntax-only check
claude verify --quick
```

### Quality Workflow Integration

Templates configure automatic quality integration:

```json
// .claude-config.json (automatically created)
{
  "quality": {
    "auto_format_on_save": true,
    "verify_before_commit": true,
    "cleanup_aggressiveness": "conservative",
    "dedupe_threshold": 80,
    "format_tools": {
      "javascript": ["prettier", "eslint"],
      "python": ["black", "isort", "flake8"],
      "go": ["gofmt", "goimports"]
    }
  }
}
```

## Command Templates

Templates provide a comprehensive command library for common development tasks:

### Git Integration Commands

**Commit Command** (`claude commit`)
- Smart commit process with automatic quality checks
- Conventional commit message formatting
- Pre-commit quality verification
- Automatic staging of quality fixes

**Pull Request Command** (`claude pr`)
- Automated PR creation with quality reports
- Template-based PR descriptions
- Integration with GitHub, GitLab, and other platforms
- Quality gate enforcement

**Status Command** (`claude status`)
- Enhanced git status with quality information
- Pending quality issues identification
- Commit readiness assessment

### Testing Framework Commands

**Unit Testing** (`claude test unit`)
- Language-specific test runner integration
- Parallel test execution
- Coverage reporting and analysis
- Test failure debugging assistance

**Integration Testing** (`claude test integration`)
- Cross-module integration testing
- Database and external service mocking
- End-to-end workflow validation

**Coverage Analysis** (`claude test coverage`)
- Comprehensive coverage reporting
- Coverage threshold enforcement
- Uncovered code identification
- Coverage trend analysis

### Project Management Commands

**Milestone Planning** (`claude milestone plan`)
- Interactive milestone creation
- Requirement gathering and documentation
- Timeline estimation and dependency mapping
- Success criteria definition

**Milestone Execution** (`claude milestone execute`)
- Progress tracking and monitoring
- Blocker identification and resolution
- Automated progress reporting
- Quality gate enforcement

**Status Monitoring** (`claude milestone status`)
- Real-time progress dashboards
- Team coordination and communication
- Risk assessment and mitigation

### Quick Commands

For rapid development workflows:

- **`claude gs`**: Enhanced git status
- **`claude gc "message"`**: Quick quality commit
- **`claude gp`**: Push with verification
- **`claude gf`**: Format and commit

## Multi-Language Support

Claude Code Enhancer templates provide sophisticated multi-language project support:

### Language Detection and Configuration

**Automatic Detection**:
```bash
# Template installer detects project structure
$ claude-install-flow
Detected languages: JavaScript (React), Python (Django)
Suggested template: Multi-language with React + Django
```

**Manual Multi-Language Setup**:
```bash
# Install base template
claude-install-flow --multi-language

# Add language-specific sections manually
# Edit CLAUDE.md to include configurations for each language
```

### Cross-Language Quality Tools

**Universal Quality Commands**:
- `claude format` works across all languages in a project
- `claude verify` validates all supported file types
- `claude cleanup` handles language-specific cleanup rules
- `claude test` runs appropriate test suites for each language

**Language-Specific Configurations**:
```json
{
  "multi_language": {
    "primary_language": "javascript",
    "secondary_languages": ["python", "go"],
    "shared_quality_standards": true,
    "language_specific_rules": {
      "javascript": {
        "formatters": ["prettier", "eslint"],
        "test_framework": "jest"
      },
      "python": {
        "formatters": ["black", "isort"],
        "test_framework": "pytest"
      }
    }
  }
}
```

## What Gets Installed

### 1. CLAUDE.md File

The main configuration file that:
- Defines development workflows
- Establishes quality standards
- Configures Claude's behavior
- Sets project-specific guidelines

Example structure:
```markdown
# Development Partnership

## Project-Specific Configuration
[Your existing content preserved here]

## Claude Flow Standard Configuration
[Template content merged here]
```

### 2. Command Directory

`.claude/commands/` containing:
- `architect.md` - System design assistance
- `debug.md` - Debugging strategies
- `optimize.md` - Performance optimization
- `refactor.md` - Code refactoring
- `review.md` - Code review
- `test-coverage.md` - Testing guidance
- And 10+ more specialized commands

### 3. Language/Framework Enhancements

Additional configurations specific to your selection:
- Language idioms and patterns
- Framework conventions
- Tool-specific integrations
- Best practices enforcement

## Customization and Extension

### Using Custom Templates

Set a custom template directory:

```bash
export CLAUDE_TEMPLATES_DIR="/path/to/custom/templates"
claude-install-flow
```

### Extending Templates

1. **Copy base templates**:
   ```bash
   cp -r /usr/local/share/claude-flow/templates ~/my-templates
   ```

2. **Modify as needed**:
   - Edit CLAUDE.md files
   - Add new commands
   - Customize workflows

3. **Use custom templates**:
   ```bash
   export CLAUDE_TEMPLATES_DIR=~/my-templates
   claude-install-flow
   ```

### Advanced Template Development

**Creating Custom Language Support**:

1. **Create Language Directory**:
   ```bash
   mkdir -p ~/my-templates/languages/kotlin
   cd ~/my-templates/languages/kotlin
   ```

2. **Define Language Template**:
   ```markdown
   # CLAUDE.md
   # Kotlin Development Guidelines
   
   ## Build System Integration
   # Gradle/Maven specific configurations
   
   ## Testing Framework
   # JUnit 5, MockK, and Kotest patterns
   
   ## Quality Tools
   # ktlint, detekt integration
   ```

3. **Add Command Customizations**:
   ```bash
   # Copy base commands and customize
   cp -r ~/my-templates/commands/quality ~/my-templates/languages/kotlin/commands
   # Edit quality commands for Kotlin-specific tools
   ```

**Framework Template Creation**:

1. **Inherit from Language Template**:
   ```markdown
   # frameworks/spring-boot/CLAUDE.md
   # Inherits from: languages/kotlin/CLAUDE.md
   
   ## Spring Boot Patterns
   # Controller, Service, Repository patterns
   
   ## Configuration Management
   # application.yml best practices
   
   ## Testing
   # @SpringBootTest, @WebMvcTest patterns
   ```

2. **Add Framework-Specific Commands**:
   ```bash
   # Add Spring Boot specific commands
   mkdir -p frameworks/spring-boot/commands
   # Create spring-specific quality, testing, and deployment commands
   ```

### Template Versioning and Distribution

**Version Management**:
```bash
# Template versioning
git tag v1.2.0
git push origin v1.2.0

# Template distribution
export CLAUDE_TEMPLATE_VERSION=v1.2.0
claude-install-flow --template-version=$CLAUDE_TEMPLATE_VERSION
```

**Team Template Sharing**:
```bash
# Shared team templates repository
git clone https://github.com/your-team/claude-templates.git
export CLAUDE_TEMPLATES_DIR=/path/to/claude-templates
claude-install-flow
```

## Advanced Usage

### Enterprise Template Management

**Centralized Template Repository**:
```bash
# Enterprise template server
export CLAUDE_TEMPLATE_SERVER="https://templates.company.com"
export CLAUDE_TEMPLATE_AUTH="Bearer $COMPANY_TOKEN"
claude-install-flow --enterprise
```

**Policy Enforcement**:
```json
// enterprise-policy.json
{
  "required_templates": ["security", "compliance"],
  "forbidden_templates": ["experimental"],
  "quality_gates": {
    "minimum_coverage": 80,
    "security_scan": "required",
    "code_review": "mandatory"
  },
  "approval_workflow": {
    "template_changes": "security-team",
    "new_templates": "architecture-committee"
  }
}
```

### Template Performance Optimization

**Large Codebase Templates**:
```json
// .claude-template-config.json
{
  "performance": {
    "lazy_loading": true,
    "command_caching": true,
    "parallel_operations": true,
    "memory_optimization": true
  },
  "large_codebase": {
    "chunked_processing": true,
    "incremental_analysis": true,
    "background_operations": true
  }
}
```

**Template Precompilation**:
```bash
# Precompile templates for faster installation
claude-template-compile --input=templates/ --output=compiled/
export CLAUDE_COMPILED_TEMPLATES=/path/to/compiled
```

### Integration with External Tools

**CI/CD Pipeline Integration**:
```yaml
# .github/workflows/template-validation.yml
name: Template Quality
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Claude Code Enhancer
        run: curl -sSL https://install.claude.ai | bash
      - name: Validate templates
        run: |
          claude-install-flow --validate-only
          claude verify --comprehensive
          claude test unit --all-templates
```

**IDE Extension Integration**:
```json
// vscode-settings.json
{
  "claude.templates.autoUpdate": true,
  "claude.templates.source": "enterprise",
  "claude.quality.realTime": true,
  "claude.commands.shortcuts": {
    "ctrl+shift+f": "claude format",
    "ctrl+shift+v": "claude verify",
    "ctrl+shift+t": "claude test unit"
  }
}
```

### Template Analytics and Monitoring

**Usage Analytics**:
```bash
# Enable template usage tracking
export CLAUDE_ANALYTICS=true
export CLAUDE_ANALYTICS_ENDPOINT="https://analytics.company.com"

# Generate usage reports
claude-template-analytics --report=monthly --format=json
```

**Quality Metrics Tracking**:
```bash
# Track quality improvements from template usage
claude verify --metrics --baseline=pre-template
claude verify --metrics --comparison=post-template
claude analytics --quality-impact --timeframe=30days
```

## Common Scenarios

### New Project Setup

```bash
# Create new project
mkdir my-new-app
cd my-new-app

# Initialize git
git init

# Install Claude Flow templates
claude-install-flow

# Select: JavaScript -> React
# Templates installed!

# Start developing
npm init -y
npm install react react-dom
```

### Existing Project Enhancement

```bash
# Navigate to existing project
cd my-existing-project

# Check current structure
ls -la

# Install templates (smart merge)
claude-install-flow

# Select appropriate language/framework
# Existing configurations preserved!
```

### Multi-Language Projects

For projects with multiple languages:

1. Install base templates first
2. Manually merge language-specific sections
3. Use commands that work across languages

```bash
# Install base Python templates
claude-install-flow
# Select: Python -> None

# Manually add JavaScript sections
# Edit CLAUDE.md to include both languages
```

## Verification

After installation, verify:

1. **Check CLAUDE.md**:
   ```bash
   cat CLAUDE.md
   ```

2. **List commands**:
   ```bash
   ls .claude/commands/
   ```

3. **Test with Claude Code**:
   - Open project in Claude Code
   - Try a command like `/review`
   - Verify enhanced capabilities

## Troubleshooting

### Templates Not Found

```bash
# Check environment
echo $CLAUDE_TEMPLATES_DIR

# List possible locations
ls ~/.local/share/claude-flow/templates
ls /usr/local/share/claude-flow/templates
```

### Wrong Template Selected

```bash
# Remove installed files
rm CLAUDE.md
rm -rf .claude/

# Re-run installation
claude-install-flow
```

### Merge Conflicts

If manual merge is needed:

1. Backup existing file:
   ```bash
   cp CLAUDE.md CLAUDE.md.backup
   ```

2. Use smart merge:
   ```bash
   claude-merge
   ```

3. Manually resolve any conflicts

## Best Practices

1. **Choose the Right Template**
   - Select the primary language/framework
   - Don't over-specify if not needed

2. **Customize After Installation**
   - Add project-specific rules
   - Create custom commands
   - Adjust workflows

3. **Keep Templates Updated**
   - Periodically run `claude-merge`
   - Review new commands
   - Adopt improved patterns

4. **Version Control**
   - Commit CLAUDE.md and .claude/
   - Track customizations
   - Share with team

## Next Steps

- Learn about [Smart Merge](smart-merge.md) for updates
- Explore [Customization](customization.md) options
- Review [Workflows](workflows.md) for your tech stack
- Check [Best Practices](best-practices.md) for tips