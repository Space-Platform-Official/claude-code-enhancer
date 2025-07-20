# Claude Code Project Initialization Template

## Description
Initialize Claude Code integration in existing projects with proper configuration, development guidelines, and workflow setup.

## Allowed Tools
- File system operations (Read, Write, Edit)
- Git integration
- Package manager detection
- Template processing
- Environment setup

## Usage Patterns

### Basic Project Initialization
```bash
claude-code init
```

### Language-Specific Setup
```bash
claude-code init --language javascript --framework react
claude-code init --language python --framework django
claude-code init --language go --framework gin
```

### With Custom Templates
```bash
claude-code init --template ./custom-claude-template
```

## Initialization Workflow

### 1. Project Detection
- Detect existing project structure and languages
- Identify package managers (npm, pip, cargo, etc.)
- Scan for existing configuration files
- Check git repository status

### 2. Configuration Generation
- Create or update CLAUDE.md with development guidelines
- Generate .claude-config.yml for project-specific settings
- Set up hooks for automated quality checks
- Configure language-specific linting and formatting

### 3. Template Integration
- Copy appropriate language/framework templates
- Customize templates based on project structure
- Integrate with existing build systems
- Set up CI/CD integration if requested

## Generated Files

### Core Configuration Files
```
.claude-config.yml          # Main configuration
CLAUDE.md                   # Development guidelines
.claude/                    # Claude-specific directory
├── hooks/                  # Git hooks integration
├── templates/              # Custom templates
└── scripts/               # Automation scripts
```

### Language-Specific Files
```
# JavaScript/TypeScript
.claude/
├── eslint-claude.config.js
├── prettier-claude.config.js
└── jest-claude.config.js

# Python
.claude/
├── pylint-claude.rc
├── black-claude.toml
└── pytest-claude.ini

# Go
.claude/
├── golangci-claude.yml
└── gofmt-claude.sh
```

## Configuration Templates

### .claude-config.yml
```yaml
# Claude Code Project Configuration
project:
  name: "{{PROJECT_NAME}}"
  language: "{{PRIMARY_LANGUAGE}}"
  framework: "{{FRAMEWORK}}"
  
claude:
  complexity_mode: "simple"
  verbosity_level: "minimal"
  file_generation: "conservative"
  
quality:
  lint_command: "{{LINT_COMMAND}}"
  test_command: "{{TEST_COMMAND}}"
  build_command: "{{BUILD_COMMAND}}"
  format_command: "{{FORMAT_COMMAND}}"
  
hooks:
  pre_commit: true
  post_edit: true
  pre_push: false
  
api:
  timeout: 300
  retry_attempts: 3
  model: "claude-sonnet-4"
```

### CLAUDE.md Template
```markdown
# Development Partnership for {{PROJECT_NAME}}

## Project Context
- **Language**: {{PRIMARY_LANGUAGE}}
- **Framework**: {{FRAMEWORK}}
- **Package Manager**: {{PACKAGE_MANAGER}}
- **Test Framework**: {{TEST_FRAMEWORK}}

## Development Workflow
1. Research → Plan → Implement
2. Mandatory quality checks before commits
3. Zero tolerance for failing tests
4. Complexity triage for all features

## Quality Standards
- Lint Command: `{{LINT_COMMAND}}`
- Test Command: `{{TEST_COMMAND}}`
- Build Command: `{{BUILD_COMMAND}}`

## File Organization
- Maximum 5 new files per feature
- Consolidate related functionality
- Follow existing project conventions
```

## Language-Specific Initialization

### JavaScript/TypeScript Projects
```bash
# Auto-detect and configure
claude-code init --auto-detect

# Creates:
# - ESLint integration with Claude rules
# - Prettier configuration
# - Jest/Vitest test setup
# - Package.json scripts integration
```

### Python Projects
```bash
# Python-specific setup
claude-code init --language python

# Creates:
# - Black formatting configuration
# - Pylint rules aligned with Claude guidelines
# - Pytest configuration
# - Pre-commit hooks for quality
```

### Go Projects
```bash
# Go-specific setup
claude-code init --language go

# Creates:
# - golangci-lint configuration
# - gofmt integration
# - Go modules awareness
# - Build and test scripts
```

## Hook Integration

### Pre-Commit Hook Template
```bash
#!/bin/bash
# .claude/hooks/pre-commit.sh

set -e

echo "🔍 Running Claude Code quality checks..."

# Load project configuration
source .claude/config/env.sh

# Run linting
if [ -n "$LINT_COMMAND" ]; then
  echo "📝 Running linter..."
  $LINT_COMMAND
fi

# Run tests
if [ -n "$TEST_COMMAND" ]; then
  echo "🧪 Running tests..."
  $TEST_COMMAND
fi

# Format code
if [ -n "$FORMAT_COMMAND" ]; then
  echo "🎨 Formatting code..."
  $FORMAT_COMMAND
fi

echo "✅ All quality checks passed!"
```

### Post-Edit Hook Template
```bash
#!/bin/bash
# .claude/hooks/post-edit.sh

# Auto-format on save
if command -v "$FORMAT_COMMAND" &> /dev/null; then
  $FORMAT_COMMAND "$1"
fi

# Run quick syntax check
if command -v "$LINT_COMMAND" &> /dev/null; then
  $LINT_COMMAND --quick "$1"
fi
```

## CI/CD Integration

### GitHub Actions Template
```yaml
# .github/workflows/claude-code.yml
name: Claude Code Quality

on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Claude Code
        run: |
          # Install Claude Code
          curl -sSL https://claude.ai/install | bash
          claude-code init --ci-mode
          
      - name: Run Quality Checks
        run: |
          claude-code check --fail-fast
          
      - name: Code Review
        if: github.event_name == 'pull_request'
        run: |
          claude-code api \
            --mode review \
            --pr-number ${{ github.event.number }} \
            --comment-on-pr
```

## Customization Options

### Template Variables
- `{{PROJECT_NAME}}`: Detected project name
- `{{PRIMARY_LANGUAGE}}`: Main programming language
- `{{FRAMEWORK}}`: Detected framework
- `{{PACKAGE_MANAGER}}`: npm, pip, cargo, etc.
- `{{TEST_FRAMEWORK}}`: jest, pytest, go test, etc.
- `{{LINT_COMMAND}}`: Language-specific linter
- `{{TEST_COMMAND}}`: Test execution command
- `{{BUILD_COMMAND}}`: Build command
- `{{FORMAT_COMMAND}}`: Code formatter

### Override Configuration
```bash
# Custom configuration override
claude-code init \
  --complexity-mode justified \
  --verbosity-level standard \
  --file-generation balanced \
  --custom-template ./templates/enterprise
```

## Validation and Testing

### Post-Initialization Checks
```bash
# Validate setup
claude-code validate

# Test integration
claude-code test-setup

# Dry-run quality checks
claude-code check --dry-run
```

### Integration Testing
- Verify all configured commands execute successfully
- Test hook integration with sample commits
- Validate CI/CD pipeline configuration
- Check template variable substitution

## Migration from Existing Tools

### From Standard Linters
- Import existing configuration files
- Merge with Claude-specific rules
- Maintain backward compatibility
- Gradual migration path

### From Other AI Tools
- Import conversation history if possible
- Migrate custom prompts and templates
- Preserve existing quality standards
- Smooth transition workflow

## Best Practices

### Setup Guidelines
1. **Start Small**: Begin with basic configuration
2. **Gradual Integration**: Add features incrementally
3. **Team Alignment**: Ensure all team members understand setup
4. **Documentation**: Keep CLAUDE.md updated with project changes
5. **Regular Updates**: Keep Claude Code configuration current

### Maintenance
- Regular review of generated configurations
- Update templates based on project evolution
- Monitor hook performance and effectiveness
- Gather team feedback on workflow efficiency