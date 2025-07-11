# Configuration Guide

This guide covers all configuration options for Claude Flow, from basic setup to advanced customization.

## Table of Contents

- [Configuration Overview](#configuration-overview)
- [Environment Variables](#environment-variables)
- [CLAUDE.md Configuration](#claudemd-configuration)
- [Command Customization](#command-customization)
- [Template Management](#template-management)
- [Advanced Configuration](#advanced-configuration)
- [Team Configuration](#team-configuration)

## Configuration Overview

Claude Flow can be configured at multiple levels:

1. **System Level**: Environment variables and installation paths
2. **Project Level**: CLAUDE.md and .claude/commands/
3. **User Level**: Personal preferences and custom templates

## Environment Variables

### Core Variables

#### `CLAUDE_TEMPLATES_DIR`
Specifies custom template directory location.

```bash
# Use custom templates
export CLAUDE_TEMPLATES_DIR="/path/to/my/templates"

# Example: Team shared templates
export CLAUDE_TEMPLATES_DIR="/shared/team/claude-templates"
```

#### `CLAUDE_DEBUG`
Enables verbose debug output.

```bash
# Enable debug mode
export CLAUDE_DEBUG=1

# Run with debug output
claude-install-flow
```

#### `CLAUDE_MERGE_STRATEGY`
Controls how files are merged.

```bash
# Options: smart (default), append, replace
export CLAUDE_MERGE_STRATEGY="smart"
```

### Setting Environment Variables

#### Temporary (current session)
```bash
export CLAUDE_TEMPLATES_DIR="/my/templates"
claude-install-flow
```

#### Permanent (all sessions)

**Bash** (~/.bashrc):
```bash
echo 'export CLAUDE_TEMPLATES_DIR="/my/templates"' >> ~/.bashrc
source ~/.bashrc
```

**Zsh** (~/.zshrc):
```bash
echo 'export CLAUDE_TEMPLATES_DIR="/my/templates"' >> ~/.zshrc
source ~/.zshrc
```

**Fish** (~/.config/fish/config.fish):
```fish
echo 'set -gx CLAUDE_TEMPLATES_DIR "/my/templates"' >> ~/.config/fish/config.fish
```

## CLAUDE.md Configuration

The `CLAUDE.md` file is the heart of your project's AI configuration.

### Basic Structure

```markdown
# Project Name

Brief project description and purpose.

## Technology Stack
- Language: TypeScript
- Framework: Express.js
- Database: PostgreSQL
- Testing: Jest

## Project Structure
```
src/
├── controllers/
├── models/
├── routes/
└── utils/
```

## Development Guidelines

### Code Style
- Use TypeScript strict mode
- Follow ESLint configuration
- Prefer functional programming patterns

### Architecture Patterns
- RESTful API design
- Repository pattern for data access
- Middleware for cross-cutting concerns

## AI Assistant Context
- Focus on performance and scalability
- Prioritize code maintainability
- Suggest testing for all new features
```

### Advanced Sections

#### Custom Instructions

Add specific instructions for AI behavior:

```markdown
## AI Behavior Instructions

### Response Style
- Be concise but thorough
- Provide code examples for complex concepts
- Always consider edge cases

### Code Generation Rules
- Include error handling in all functions
- Add JSDoc comments for public APIs
- Use descriptive variable names

### Review Focus Areas
- Security vulnerabilities
- Performance bottlenecks
- Code duplication
```

#### Project-Specific Context

Include domain knowledge:

```markdown
## Domain Context

### Business Rules
- Users can only edit their own tasks
- Tasks must have a due date
- Completed tasks archive after 30 days

### Technical Constraints
- API response time < 200ms
- Support 10,000 concurrent users
- PostgreSQL version 14+
```

#### Integration Points

Document external services:

```markdown
## External Integrations

### Services
- Auth0 for authentication
- SendGrid for email notifications
- Stripe for payments
- AWS S3 for file storage

### API Conventions
- Use OAuth 2.0 for auth
- Implement rate limiting
- Version APIs with /v1/ prefix
```

### Dynamic Configuration

Use template variables for flexibility:

```markdown
## Configuration Variables

PROJECT_NAME: {{PROJECT_NAME}}
API_VERSION: {{API_VERSION}}
DATABASE_TYPE: {{DATABASE_TYPE}}

<!-- These can be replaced during installation -->
```

## Command Customization

### Creating Custom Commands

Add project-specific commands to `.claude/commands/`:

```bash
# Create deployment command
touch .claude/commands/deploy.md
```

Example custom command:

```markdown
# Deployment Assistant

Help me deploy the {{PROJECT_NAME}} application.

## Current Infrastructure
- Platform: {{DEPLOY_PLATFORM}}
- Environment: {{ENVIRONMENT}}
- Database: {{DATABASE_TYPE}}

## Deployment Checklist
1. Run tests
2. Build application
3. Database migrations
4. Environment variables
5. Health checks

## Specific Requirements
- Zero-downtime deployment
- Rollback capability
- Monitoring setup
```

### Command Templates

Create reusable command templates:

```bash
# Security audit command
cat > .claude/commands/security-audit.md << 'EOF'
# Security Audit

Perform a security audit on the codebase.

## Areas to Check
1. Authentication & Authorization
2. Input validation
3. SQL injection vulnerabilities
4. XSS protection
5. Dependency vulnerabilities
6. Secrets management
7. API rate limiting

## Tools to Suggest
- npm audit
- OWASP dependency check
- ESLint security plugin

## Output Format
Provide findings in order of severity:
- Critical
- High
- Medium
- Low
EOF
```

### Command Organization

Structure commands by category:

```
.claude/commands/
├── development/
│   ├── architect.md
│   ├── implement.md
│   └── refactor.md
├── quality/
│   ├── review.md
│   ├── test.md
│   └── optimize.md
├── operations/
│   ├── deploy.md
│   ├── monitor.md
│   └── troubleshoot.md
└── security/
    ├── audit.md
    └── patch.md
```

## Template Management

### Custom Template Directory Structure

Create your own template library:

```
my-templates/
├── CLAUDE.md
├── commands/
├── languages/
│   ├── python/
│   │   ├── CLAUDE.md
│   │   └── commands/
│   └── javascript/
│       ├── CLAUDE.md
│       └── commands/
└── frameworks/
    ├── django/
    └── react/
```

### Template Inheritance

Use base templates with overrides:

```bash
# Base template
cat > my-templates/CLAUDE.md << 'EOF'
# Base Configuration

## Common Standards
- Use semantic versioning
- Write comprehensive tests
- Document all APIs

<!-- Project specific sections below -->
EOF

# Language-specific addition
cat > my-templates/languages/python/CLAUDE.md << 'EOF'
{{BASE_TEMPLATE}}

## Python Specific
- Use Python 3.9+
- Follow PEP 8
- Type hints required
EOF
```

### Template Variables

Define replaceable variables:

```markdown
## Project: {{PROJECT_NAME}}
- Repository: {{REPO_URL}}
- Lead: {{TECH_LEAD}}
- Started: {{START_DATE}}
```

Replace during installation:

```bash
# Custom installation script
sed -i "s/{{PROJECT_NAME}}/My App/g" CLAUDE.md
sed -i "s/{{REPO_URL}}/https:\/\/github.com\/myorg\/myapp/g" CLAUDE.md
```

## Advanced Configuration

### Multi-Environment Setup

Configure for different environments:

```markdown
## Environment Configuration

### Development
- Database: SQLite
- Debug: Enabled
- API URL: http://localhost:3000

### Staging
- Database: PostgreSQL
- Debug: Limited
- API URL: https://staging.example.com

### Production
- Database: PostgreSQL cluster
- Debug: Disabled
- API URL: https://api.example.com
```

### Language-Specific Options

#### JavaScript/TypeScript

```markdown
## JavaScript Configuration

### Build Tools
- Bundler: Webpack 5
- Transpiler: Babel 7
- Package Manager: npm 8

### TypeScript Settings
{
  "strict": true,
  "target": "ES2020",
  "module": "commonjs",
  "esModuleInterop": true
}
```

#### Python

```markdown
## Python Configuration

### Virtual Environment
- Tool: venv
- Location: ./venv
- Activation: source venv/bin/activate

### Dependencies
- Management: pip + requirements.txt
- Development: requirements-dev.txt
- Production: requirements-prod.txt
```

### Integration Configuration

#### CI/CD Integration

```markdown
## CI/CD Configuration

### GitHub Actions
- Trigger: Push to main, PR
- Tests: On all PRs
- Deploy: On main merge

### Pipeline Stages
1. Lint
2. Test
3. Build
4. Security Scan
5. Deploy
```

#### IDE Integration

```markdown
## IDE Configuration

### VS Code
- Extensions: ESLint, Prettier, GitLens
- Settings: .vscode/settings.json
- Tasks: .vscode/tasks.json

### Settings Sync
{
  "editor.formatOnSave": true,
  "eslint.autoFixOnSave": true
}
```

## Team Configuration

### Shared Configuration

Set up team-wide standards:

```bash
# Create team template repository
git init claude-team-templates
cd claude-team-templates

# Add team standards
cat > CLAUDE.md << 'EOF'
# Team Development Standards

## Code Review Process
- All code requires review
- Tests required for features
- Documentation for APIs

## Git Workflow
- Branch naming: feature/*, bugfix/*
- Commit style: Conventional Commits
- PR template required
EOF

# Share with team
git add .
git commit -m "Add team Claude standards"
git remote add origin https://github.com/team/claude-templates
git push -u origin main
```

### Team Installation

```bash
# Team members clone templates
git clone https://github.com/team/claude-templates ~/team-templates

# Use team templates
export CLAUDE_TEMPLATES_DIR="$HOME/team-templates"
claude-install-flow
```

### Configuration Governance

Establish configuration standards:

```markdown
## Configuration Governance

### Change Process
1. Propose changes via PR
2. Team review required
3. Test in sample project
4. Document changes
5. Notify team

### Review Checklist
- [ ] Backwards compatible
- [ ] Documentation updated
- [ ] Examples provided
- [ ] Team notified
```

## Configuration Best Practices

### 1. Start Simple

Begin with basic configuration:
```markdown
# My Project

Simple web API using Node.js and Express.

## Quick Context
- REST API
- PostgreSQL database
- JWT authentication
```

### 2. Evolve Gradually

Add sections as needed:
- Architecture decisions
- Performance requirements
- Security considerations
- Deployment procedures

### 3. Keep It Maintainable

- Use clear section headers
- Include examples
- Document decisions
- Regular reviews

### 4. Version Control

Track configuration changes:
```bash
git add CLAUDE.md .claude/
git commit -m "Update AI configuration for v2.0"
git tag config-v2.0
```

## Troubleshooting Configuration

### Common Issues

#### Templates Not Found
```bash
# Check template search path
echo $CLAUDE_TEMPLATES_DIR

# Verify templates exist
ls -la ~/.local/share/claude-flow/templates/
```

#### Merge Conflicts
```bash
# Use append strategy for conflicts
CLAUDE_MERGE_STRATEGY=append claude-merge

# Or manually merge
cp CLAUDE.md CLAUDE.md.backup
claude-merge
diff CLAUDE.md.backup CLAUDE.md
```

#### Command Not Working
```bash
# Verify command file
cat .claude/commands/mycmd.md

# Check syntax and formatting
# Ensure markdown is valid
```

### Debug Mode

Enable detailed logging:
```bash
# Maximum verbosity
CLAUDE_DEBUG=1 claude-install-flow 2>&1 | tee debug.log

# Review debug output
grep ERROR debug.log
grep WARNING debug.log
```

## Summary

Effective Claude Flow configuration:
- ✅ Uses environment variables for flexibility
- ✅ Maintains comprehensive CLAUDE.md
- ✅ Creates project-specific commands
- ✅ Leverages templates for consistency
- ✅ Evolves with project needs

Remember: Configuration is a living document that should grow and adapt with your project!