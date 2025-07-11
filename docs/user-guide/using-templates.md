# Using Claude Flow Templates

This guide explains how to effectively use Claude Flow templates to set up and configure your development projects.

## Understanding Templates

Claude Flow templates are pre-configured sets of files and configurations designed to optimize Claude Code for specific languages, frameworks, and workflows.

### Template Structure

```
templates/
├── CLAUDE.md              # Base configuration
├── base/                  # Core templates
├── languages/             # Language-specific configs
│   ├── javascript/
│   ├── python/
│   ├── go/
│   ├── rust/
│   └── php/
├── frameworks/            # Framework-specific configs
│   ├── react/
│   ├── nextjs/
│   ├── django/
│   └── express/
├── commands/              # Claude command library
└── workflows/             # Process automation
```

## Installing Templates

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

## Template Types

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

## Template Customization

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