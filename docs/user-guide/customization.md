# Customization Guide

This guide shows you how to customize Claude Flow to match your specific needs, team standards, and project requirements.

## Customization Levels

### 1. Project-Level Customization
Modify configurations for a single project

### 2. User-Level Customization
Personal preferences across all projects

### 3. Team-Level Customization
Shared standards for your organization

### 4. System-Level Customization
Enterprise-wide configurations

## Customizing CLAUDE.md

### Structure Your Configuration

Create well-organized sections:

```markdown
# Project: E-Commerce Platform

## Project Standards
<!-- Your project-specific rules -->

## Architecture Decisions
<!-- Your architectural guidelines -->

## Team Conventions
<!-- Your team agreements -->

# ==========================================
# Claude Flow Standard Configuration
# ==========================================
<!-- Template content below -->
```

### Add Project-Specific Rules

```markdown
## Project Standards

### Code Style
- Use 2-space indentation (not 4)
- Prefer functional components over classes
- Always use TypeScript interfaces

### Naming Conventions
- Components: PascalCase (UserProfile)
- Utilities: camelCase (formatDate)
- Constants: UPPER_SNAKE_CASE (API_KEY)
- Files: kebab-case (user-profile.tsx)

### Git Workflow
- Branch naming: feature/JIRA-123-description
- Commit format: "type(scope): message"
- Always squash merge to main
```

### Define Custom Workflows

```markdown
## Development Workflow

### Feature Development
1. Create branch from latest main
2. Write tests first (TDD)
3. Implement feature
4. Run quality checks: `npm run validate`
5. Create PR with template
6. Await two approvals

### Code Review Process
- Security review for auth changes
- Performance review for data operations
- Accessibility review for UI changes
```

## Creating Custom Commands

### Command Structure

Create new commands in `.claude/commands/`:

```markdown
---
allowed-tools: all
description: Your command description
---

# Command Title

Command-specific instructions...
```

### Example: Custom Deploy Command

`.claude/commands/deploy.md`:
```markdown
---
allowed-tools: bash, read, edit
description: Deploy application to staging or production
---

# Deployment Command

When running /deploy, follow these steps:

1. **Pre-deployment Checks**
   - Run full test suite
   - Check for uncommitted changes
   - Verify environment variables
   - Validate build artifacts

2. **Deployment Process**
   - Build production bundle
   - Run database migrations
   - Deploy to target environment
   - Verify deployment health

3. **Post-deployment**
   - Run smoke tests
   - Check monitoring dashboards
   - Update deployment log
   - Notify team channel

CRITICAL: Never deploy on Fridays!
```

### Example: Domain-Specific Command

`.claude/commands/api-endpoint.md`:
```markdown
---
allowed-tools: all
description: Create new REST API endpoint with our standards
---

# API Endpoint Creator

When creating a new API endpoint:

1. **Define OpenAPI Spec First**
   ```yaml
   /api/v1/resource:
     post:
       summary: Create resource
       requestBody:
         required: true
         content:
           application/json:
             schema:
               $ref: '#/components/schemas/Resource'
   ```

2. **Implement Controller**
   - Input validation with Joi/Zod
   - Error handling middleware
   - Rate limiting
   - Authentication check
   - Audit logging

3. **Add Tests**
   - Unit tests for validation
   - Integration tests for flow
   - Load tests for performance
   - Security tests for auth

4. **Update Documentation**
   - API docs
   - Postman collection
   - Client SDK
```

## Template Customization

### Creating Custom Templates

1. **Set up template directory**:
   ```bash
   mkdir -p ~/claude-templates
   cp -r /usr/local/share/claude-flow/templates/* ~/claude-templates/
   ```

2. **Customize base template**:
   ```bash
   edit ~/claude-templates/CLAUDE.md
   ```

3. **Add company standards**:
   ```markdown
   # ACME Corp Development Standards
   
   ## Compliance Requirements
   - HIPAA compliant code only
   - No PII in logs
   - Encryption at rest required
   
   ## Technology Stack
   - Node.js 20 LTS
   - PostgreSQL 15
   - Redis for caching
   - Kubernetes deployment
   ```

4. **Use custom templates**:
   ```bash
   export CLAUDE_TEMPLATES_DIR=~/claude-templates
   claude-install-flow
   ```

### Language-Specific Customization

Enhance language templates:

`~/claude-templates/languages/python/CLAUDE.md`:
```markdown
## Python Standards (ACME Corp)

### Virtual Environments
- Always use poetry for dependencies
- Python 3.11+ required
- Lock file must be committed

### Type Hints
- Required for all functions
- Use mypy in strict mode
- No Any types without comment

### Testing
- Minimum 90% coverage
- Use pytest exclusively
- Fixtures over setUp/tearDown
```

### Framework Customization

Add framework-specific rules:

`~/claude-templates/frameworks/react/CLAUDE.md`:
```markdown
## React Standards (ACME Corp)

### State Management
- Zustand for global state
- React Query for server state
- No Redux in new code

### Component Patterns
- Composition over inheritance
- Custom hooks for logic
- Styled-components for CSS

### Performance
- Memo only when measured
- Lazy load all routes
- Virtual lists for 50+ items
```

## Workflow Automation

### Custom CI/CD Integration

`.claude/commands/ci-setup.md`:
```markdown
---
allowed-tools: all
description: Set up CI/CD pipeline
---

# CI/CD Pipeline Setup

Create GitHub Actions workflow with:

1. **Test Job**
   - Matrix testing (Node 18, 20)
   - Parallel test execution
   - Coverage reporting

2. **Build Job**
   - Docker multi-stage build
   - Asset optimization
   - Source maps generation

3. **Deploy Job**
   - Environment approval
   - Blue-green deployment
   - Rollback capability
```

### Pre-commit Hooks

`.claude/hooks/pre-commit.sh`:
```bash
#!/bin/bash
# Claude Flow pre-commit hook

echo "Running Claude Flow checks..."

# Format check
npm run format:check || {
    echo "Format issues found. Run: npm run format"
    exit 1
}

# Lint check
npm run lint || {
    echo "Linting failed"
    exit 1
}

# Type check
npm run type-check || {
    echo "Type errors found"
    exit 1
}

echo "Claude Flow checks passed!"
```

## Environment Variables

### Configure Claude Flow Behavior

```bash
# ~/.bashrc or ~/.zshrc

# Custom template location
export CLAUDE_TEMPLATES_DIR="$HOME/company-templates"

# Default language preference
export CLAUDE_DEFAULT_LANGUAGE="typescript"

# Default framework
export CLAUDE_DEFAULT_FRAMEWORK="nextjs"

# Enable verbose output
export CLAUDE_VERBOSE=1

# Custom merge strategy
export CLAUDE_MERGE_STRATEGY="smart"
```

### Project-Specific Variables

`.env.claude`:
```bash
# Project-specific Claude settings
CLAUDE_PROJECT_TYPE="microservice"
CLAUDE_TESTING_FRAMEWORK="vitest"
CLAUDE_API_STYLE="graphql"
CLAUDE_DEPLOYMENT_TARGET="vercel"
```

## Team Standardization

### Shared Configuration Repository

1. **Create team repository**:
   ```bash
   git init claude-team-config
   cd claude-team-config
   
   # Add templates
   cp -r /usr/local/share/claude-flow/templates/* .
   
   # Customize for team
   edit CLAUDE.md
   edit commands/*.md
   
   git add -A
   git commit -m "Initial team configuration"
   git push
   ```

2. **Team installation script**:
   ```bash
   #!/bin/bash
   # install-team-claude.sh
   
   # Clone team config
   git clone https://github.com/team/claude-config ~/.claude-team
   
   # Set environment
   echo 'export CLAUDE_TEMPLATES_DIR="$HOME/.claude-team"' >> ~/.bashrc
   
   # Install Claude Flow
   curl -fsSL https://example.com/install.sh | bash
   ```

### Enforcement Strategies

1. **Git Hooks**:
   ```bash
   # .git/hooks/pre-push
   #!/bin/bash
   
   # Ensure CLAUDE.md exists
   if [ ! -f "CLAUDE.md" ]; then
       echo "Error: CLAUDE.md required"
       echo "Run: claude-install-flow"
       exit 1
   fi
   ```

2. **CI Validation**:
   ```yaml
   # .github/workflows/claude-check.yml
   name: Claude Flow Validation
   on: [push, pull_request]
   
   jobs:
     validate:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - name: Check Claude Flow
           run: |
             test -f CLAUDE.md || exit 1
             test -d .claude/commands || exit 1
   ```

## Advanced Customization

### Dynamic Commands

Create context-aware commands:

`.claude/commands/context-aware.md`:
```markdown
---
allowed-tools: all
description: Adapts based on project context
---

# Context-Aware Command

First, detect project type:
- Check for package.json → Node.js
- Check for requirements.txt → Python
- Check for go.mod → Go

Then apply appropriate patterns...
```

### Command Aliases

`.claude/aliases.json`:
```json
{
  "qa": "test-coverage",
  "perf": "optimize",
  "sec": "security-audit",
  "ship": "deploy",
  "wtf": "debug"
}
```

### Custom Validators

`.claude/validators/custom-check.js`:
```javascript
// Custom validation script
module.exports = {
  validate: (projectPath) => {
    // Check for required files
    const required = ['README.md', 'LICENSE', '.env.example'];
    const missing = required.filter(f => !fs.existsSync(f));
    
    if (missing.length > 0) {
      throw new Error(`Missing files: ${missing.join(', ')}`);
    }
    
    return true;
  }
};
```

## Best Practices

### 1. Start Simple
- Begin with basic customizations
- Add complexity gradually
- Test each change

### 2. Document Everything
- Explain why rules exist
- Provide examples
- Link to resources

### 3. Version Control
- Track all customizations
- Use semantic versioning
- Maintain changelog

### 4. Regular Reviews
- Audit custom commands quarterly
- Update for new patterns
- Remove obsolete rules

### 5. Team Alignment
- Discuss major changes
- Provide migration guides
- Train on new features

## Next Steps

- Explore [Workflows](workflows.md) for automation ideas
- Review [Best Practices](best-practices.md) for optimization
- Check [Using Templates](using-templates.md) for basics
- Learn [Smart Merge](smart-merge.md) for updates