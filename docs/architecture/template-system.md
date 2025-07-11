# Claude Flow Template System

## Overview

The Claude Flow template system provides a flexible, hierarchical approach to managing Claude Code configurations across different programming languages, frameworks, and project types. This document explains how the template system works, its inheritance model, and customization capabilities.

## Template Architecture

### Core Concepts

1. **Base Templates**: Foundation configurations that apply to all projects
2. **Specialized Templates**: Language and framework-specific configurations
3. **Command Templates**: Reusable Claude commands for common tasks
4. **Workflow Templates**: Automation and CI/CD configurations

### Template Hierarchy

```
Base Template (CLAUDE.md)
    ├── Language Templates
    │   ├── JavaScript
    │   ├── Python
    │   ├── Go
    │   ├── Rust
    │   ├── PHP
    │   └── TypeScript
    └── Framework Templates
        ├── React
        ├── Next.js
        ├── Django
        └── Express
```

## Template Types

### 1. Base Configuration Template

**Location**: `templates/CLAUDE.md` and `templates/base/CLAUDE.md`

**Purpose**: Provides fundamental Claude guidelines applicable to all projects

**Key Elements**:
- Core development principles
- Universal best practices
- Standard workflow definitions
- Error handling protocols

**Example Structure**:
```markdown
# Development Partnership

We're building production-quality code together...

## 🚨 AUTOMATED CHECKS ARE MANDATORY

**ALL hook issues are BLOCKING...**

## CRITICAL WORKFLOW - ALWAYS FOLLOW THIS!

### Research → Plan → Implement
...
```

### 2. Language-Specific Templates

**Location**: `templates/languages/<language>/CLAUDE.md`

**Purpose**: Tailored configurations for specific programming languages

**Features**:
- Language-specific best practices
- Idiomatic code patterns
- Testing frameworks
- Build tool integration

**Available Languages**:
- **JavaScript**: Node.js patterns, npm/yarn workflows
- **TypeScript**: Type safety, compilation checks
- **Python**: PEP compliance, virtual environments
- **Go**: Module management, goroutine patterns
- **Rust**: Memory safety, cargo integration
- **PHP**: Composer workflows, PSR standards

### 3. Framework Templates

**Location**: `templates/frameworks/<framework>/CLAUDE.md`

**Purpose**: Framework-specific development patterns and practices

**Features**:
- Framework conventions
- Component patterns
- State management
- Routing configurations

**Available Frameworks**:
- **React**: Component lifecycle, hooks, state management
- **Next.js**: SSR/SSG patterns, API routes
- **Django**: MVT architecture, ORM patterns
- **Express**: Middleware patterns, routing

### 4. Command Templates

**Location**: `templates/commands/*.md`

**Purpose**: Pre-defined commands for common development tasks

**Command Categories**:

#### Architecture & Design
- `architect.md` - System design assistance
- `api-design.md` - API endpoint planning

#### Development
- `debug.md` - Debugging strategies
- `refactor.md` - Code refactoring guidance
- `optimize.md` - Performance optimization

#### Quality Assurance
- `review.md` - Code review assistance
- `test-coverage.md` - Testing strategies
- `security-audit.md` - Security analysis

#### Operations
- `monitor.md` - Monitoring setup
- `migrate.md` - Migration planning
- `rollback.md` - Rollback procedures

### 5. Workflow Templates

**Location**: `templates/workflows/`

**Purpose**: Automation and CI/CD configurations

**Types**:
- **CI/CD**: GitHub Actions, GitLab CI
- **Documentation**: Auto-generation scripts
- **Testing**: Test automation setups

## Template Selection Process

### Automatic Detection

Claude Flow attempts to detect the appropriate templates based on:

1. **File Analysis**:
   ```bash
   # Detects package.json → JavaScript/Node.js
   # Detects requirements.txt → Python
   # Detects go.mod → Go
   # Detects Cargo.toml → Rust
   ```

2. **Framework Indicators**:
   ```bash
   # React: presence of React imports
   # Next.js: next.config.js
   # Django: manage.py
   # Express: express server patterns
   ```

### Manual Selection

Users can override automatic detection:

```bash
# During installation
claude-install-flow --language=python --framework=django

# Using environment variables
export CLAUDE_LANGUAGE=typescript
export CLAUDE_FRAMEWORK=react
claude-install-flow
```

## Template Inheritance Model

### Composition Strategy

Templates are composed in layers:

```
1. Base Template (Foundation)
   ↓
2. Language Template (Language-specific rules)
   ↓
3. Framework Template (Framework patterns)
   ↓
4. Project Customizations (Local overrides)
```

### Merge Behavior

When multiple templates apply:

1. **Non-Conflicting Content**: All content is preserved
2. **Conflicting Sections**: Later templates override earlier ones
3. **Custom Sections**: Always preserved during merges

### Example Composition

For a React TypeScript project:

```markdown
# Merged CLAUDE.md

<!-- From Base Template -->
# Development Partnership
We're building production-quality code together...

<!-- From TypeScript Template -->
## TypeScript Guidelines
- Strict type checking enabled
- No implicit any
- Interface over type aliases

<!-- From React Template -->
## React Best Practices
- Functional components with hooks
- Proper dependency arrays
- Component composition patterns

<!-- Project Customizations -->
## Project-Specific Rules
- Custom ESLint configuration
- Team coding standards
```

## Template Customization

### Creating Custom Templates

1. **Language Template**:
   ```bash
   mkdir -p ~/.local/share/claude-flow/templates/languages/kotlin
   cat > ~/.local/share/claude-flow/templates/languages/kotlin/CLAUDE.md << EOF
   # Kotlin Development Guidelines
   
   ## Coroutines
   - Use structured concurrency
   - Proper scope management
   EOF
   ```

2. **Framework Template**:
   ```bash
   mkdir -p ~/.local/share/claude-flow/templates/frameworks/spring
   # Add Spring Boot specific guidelines
   ```

3. **Command Template**:
   ```bash
   cat > ~/.local/share/claude-flow/templates/commands/custom-lint.md << EOF
   # Custom Linting Command
   
   Run comprehensive linting with project-specific rules...
   EOF
   ```

### Override Mechanisms

1. **Environment Variables**:
   ```bash
   export CLAUDE_TEMPLATES_DIR=/custom/templates
   ```

2. **Project-Level Overrides**:
   ```
   project/
   ├── .claude/
   │   └── templates/    # Project-specific templates
   └── claude/
       └── CLAUDE.md     # Merged configuration
   ```

3. **User-Level Overrides**:
   ```
   ~/.local/share/claude-flow/templates/
   # Takes precedence over system templates
   ```

## Template Variables

### Supported Variables

Templates can include variables for dynamic content:

- `${PROJECT_NAME}` - Current project name
- `${LANGUAGE}` - Selected programming language
- `${FRAMEWORK}` - Selected framework
- `${DATE}` - Current date
- `${USER}` - Current username

### Usage Example

```markdown
# ${PROJECT_NAME} Development Guidelines

Generated on ${DATE} for ${USER}

This ${LANGUAGE} project uses ${FRAMEWORK}...
```

## Best Practices

### 1. Template Design

- **Modularity**: Keep templates focused on specific concerns
- **Clarity**: Use clear, actionable language
- **Examples**: Include code examples where helpful
- **Versioning**: Document template compatibility

### 2. Template Maintenance

- **Regular Updates**: Keep templates current with best practices
- **Testing**: Verify templates work across different scenarios
- **Documentation**: Document custom templates thoroughly
- **Backwards Compatibility**: Preserve existing functionality

### 3. Template Distribution

- **Sharing**: Use Git repositories for team templates
- **Packaging**: Create template bundles for specific use cases
- **Validation**: Test templates before distribution

## Advanced Features

### 1. Conditional Sections

Templates can include conditional content:

```markdown
<!-- IF: typescript -->
## TypeScript Configuration
Enable strict mode...
<!-- ENDIF -->
```

### 2. Template Includes

Reference other templates:

```markdown
<!-- INCLUDE: ../base/error-handling.md -->
```

### 3. Dynamic Commands

Generate commands based on project context:

```markdown
<!-- COMMAND: analyze-dependencies -->
Analyze ${LANGUAGE} dependencies in ${PROJECT_NAME}...
<!-- END COMMAND -->
```

## Template Validation

### Syntax Validation

Claude Flow validates templates for:
- Proper markdown structure
- Valid variable references
- Correct conditional syntax

### Content Validation

Ensures templates contain:
- Required sections
- Proper command formatting
- Valid file references

This template system provides the flexibility to support diverse development environments while maintaining consistency and best practices across projects.