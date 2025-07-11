# Creating Templates for Claude Flow

This guide explains how to create new templates for languages, frameworks, and workflows in Claude Flow.

## Template System Overview

Claude Flow uses a hierarchical template system:

```
templates/
├── CLAUDE.md              # Base template (always copied)
├── README.md              # Template documentation
├── base/                  # Base configurations
│   └── CLAUDE.md         # Generic project template
├── languages/            # Language-specific templates
│   ├── python/
│   ├── javascript/
│   └── go/
├── frameworks/           # Framework-specific templates
│   ├── react/
│   ├── django/
│   └── nextjs/
├── workflows/            # Workflow templates
│   ├── ci-cd/
│   └── testing/
└── commands/             # Command templates
    ├── README.md
    └── *.md              # Individual commands
```

## Creating Language Templates

### 1. Directory Structure

Create a new language directory:

```bash
mkdir -p templates/languages/YOUR_LANGUAGE
```

### 2. Main CLAUDE.md File

Create `templates/languages/YOUR_LANGUAGE/CLAUDE.md`:

```markdown
# YOUR_LANGUAGE Development with Claude

## Language Overview
Brief description of the language and its use cases.

## Development Guidelines

### Code Style
- Indentation: [spaces/tabs, size]
- Naming conventions: [camelCase/snake_case/PascalCase]
- Line length: [recommended maximum]
- Comments: [style guide]

### Best Practices
- [Practice 1]
- [Practice 2]
- [Practice 3]

### Common Patterns
```your-language
// Example of common pattern
```

### Anti-Patterns to Avoid
- [Anti-pattern 1]: Why and what to do instead
- [Anti-pattern 2]: Alternative approach

## Language-Specific Features

### [Feature 1]
Explanation and examples

### [Feature 2]
Explanation and examples

## Testing Approach
- Unit testing framework: [framework name]
- Test file naming: [convention]
- Test structure: [describe/it, test functions, etc.]

## Performance Considerations
- Memory management: [GC, manual, etc.]
- Compilation: [interpreted/compiled/JIT]
- Optimization tips: [specific to language]

## Tooling

### Essential Tools
- **Package Manager**: [tool name]
- **Linter**: [tool name]
- **Formatter**: [tool name]
- **Build Tool**: [tool name]

### Recommended Extensions
- IDE/Editor plugins
- Debugging tools
- Profiling tools

## Common Libraries
- **Web Framework**: [library name]
- **Testing**: [library name]
- **Database**: [library name]
- **Utilities**: [library name]

## Error Handling
```your-language
// Example of proper error handling
```

## Security Considerations
- Input validation
- Common vulnerabilities
- Security best practices

## Claude Integration Tips
- How to effectively describe problems
- Code review requests format
- Debugging assistance patterns
```

### 3. Additional Template Files

Add any language-specific configuration files:

```bash
# Example for Python
templates/languages/python/
├── CLAUDE.md
├── .gitignore         # Python-specific ignores
├── requirements.txt   # Dependency template
└── pyproject.toml    # Modern Python config
```

### 4. Update Installation Script

Edit `install-claude-flow.sh` to include your language:

```bash
# Find the language selection section
case "$choice" in
    1) echo "JavaScript" ;;
    2) echo "Python" ;;
    3) echo "Go" ;;
    4) echo "YOUR_LANGUAGE" ;;  # Add your language
    # ...
esac
```

## Creating Framework Templates

### 1. Framework Template Structure

```bash
mkdir -p templates/frameworks/YOUR_FRAMEWORK
```

### 2. Framework CLAUDE.md

Create `templates/frameworks/YOUR_FRAMEWORK/CLAUDE.md`:

```markdown
# YOUR_FRAMEWORK Development with Claude

## Framework Overview
What the framework does and when to use it.

## Project Structure
```
your-project/
├── src/
│   ├── components/    # Explanation
│   ├── services/      # Explanation
│   └── utils/         # Explanation
├── tests/
├── config/
└── public/
```

## Core Concepts

### [Concept 1]
Explanation with code example

### [Concept 2]
Explanation with code example

## Development Workflow

### Setup
```bash
# Installation commands
# Initial setup
```

### Development Server
```bash
# How to run dev server
```

### Building for Production
```bash
# Build commands
```

## Component Patterns

### Basic Component
```your-language
// Example component structure
```

### Advanced Patterns
- Pattern 1: Use case and example
- Pattern 2: Use case and example

## State Management
How the framework handles state

## Routing
How routing works in this framework

## Testing Strategy

### Unit Tests
```your-language
// Example test
```

### Integration Tests
Approach and tools

### E2E Tests
Recommended tools and patterns

## Performance Optimization
- Bundle size optimization
- Runtime performance
- Caching strategies

## Common Pitfalls
1. **Pitfall**: Description
   **Solution**: How to avoid

2. **Pitfall**: Description
   **Solution**: How to avoid

## Best Practices
- File organization
- Code splitting
- Error boundaries
- Accessibility

## Deployment
- Recommended platforms
- Environment configuration
- CI/CD setup

## Debugging Tips
- Developer tools usage
- Common error messages
- Debugging techniques

## Resources
- Official documentation
- Community resources
- Tutorial recommendations
```

### 3. Framework-Specific Files

Add configuration templates:

```bash
# Example for React
templates/frameworks/react/
├── CLAUDE.md
├── .eslintrc.json
├── tsconfig.json
└── jest.config.js
```

## Creating Command Templates

### 1. Command Structure

Create `templates/commands/YOUR_COMMAND.md`:

```markdown
# YOUR_COMMAND

## Purpose
What this command helps accomplish

## When to Use
- Scenario 1
- Scenario 2
- Scenario 3

## Command Format
```
@YOUR_COMMAND [parameters]
```

## Parameters
- **param1**: Description (required/optional)
- **param2**: Description (required/optional)

## Examples

### Example 1: Basic Usage
```
@YOUR_COMMAND basic parameter
```

Expected outcome and explanation

### Example 2: Advanced Usage
```
@YOUR_COMMAND --flag complex parameter
```

Expected outcome and explanation

## Best Practices
1. How to write effective prompts
2. What information to include
3. Common mistakes to avoid

## Sample Interactions

### Scenario: [Common Use Case]
**User**: @YOUR_COMMAND help me with X

**Claude**: [Example response showing the command in action]

## Related Commands
- `@related_command1` - When to use instead
- `@related_command2` - Complementary command

## Tips
- Tip 1 for maximum effectiveness
- Tip 2 for better results
- Tip 3 for troubleshooting
```

### 2. Update Command Index

Add your command to `templates/commands/README.md`:

```markdown
## Available Commands

### Development Commands
- **@YOUR_COMMAND** - Brief description
```

## Creating Workflow Templates

### 1. Workflow Structure

```bash
mkdir -p templates/workflows/YOUR_WORKFLOW
```

### 2. Workflow Files

Create workflow-specific files:

```yaml
# templates/workflows/ci-cd/github-actions.yml
name: YOUR_WORKFLOW

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      # Workflow steps
```

### 3. Workflow Documentation

Create `templates/workflows/YOUR_WORKFLOW/README.md`:

```markdown
# YOUR_WORKFLOW

## Overview
What this workflow accomplishes

## Prerequisites
- Requirement 1
- Requirement 2

## Setup Instructions
1. Step 1
2. Step 2

## Configuration
Explain configuration options

## Customization
How to adapt for different needs

## Troubleshooting
Common issues and solutions
```

## Template Best Practices

### 1. Keep Templates Generic

Use placeholders for project-specific values:

```markdown
# Project: {{PROJECT_NAME}}
Repository: {{REPO_URL}}
```

### 2. Provide Clear Examples

Always include code examples:

```markdown
### Good Practice
```language
// Clear example with explanation
```

### Bad Practice
```language
// What not to do and why
```
```

### 3. Include Essential Information

Every template should have:
- Overview/purpose
- Setup instructions  
- Best practices
- Common patterns
- Troubleshooting

### 4. Consider Different Skill Levels

Write for both beginners and experts:

```markdown
## Quick Start (Beginners)
Simple steps to get started

## Advanced Configuration
For experienced developers
```

### 5. Maintain Consistency

Follow the same structure across templates:
1. Overview
2. Guidelines
3. Examples
4. Best Practices
5. Troubleshooting

## Testing Your Templates

### 1. Manual Testing

```bash
# Test your template installation
cd /tmp/test-project
/path/to/install-claude-flow.sh

# Select your new template
# Verify files are copied correctly
```

### 2. Add Automated Tests

Create test in `test/mock-templates/`:

```bash
# Minimal version for testing
mkdir -p test/mock-templates/languages/YOUR_LANGUAGE
echo "# Mock YOUR_LANGUAGE" > test/mock-templates/languages/YOUR_LANGUAGE/CLAUDE.md
```

### 3. Integration Testing

Test the complete workflow:

```bash
# Install your template
# Create a sample project
# Verify Claude can work with it effectively
```

## Template Maintenance

### Regular Updates

- Review templates quarterly
- Update for new language/framework versions
- Incorporate user feedback
- Add new best practices

### Version Compatibility

Consider version differences:

```markdown
## Version-Specific Notes

### v2.x
- Feature available in v2+
- Different syntax in v2

### v3.x  
- Breaking change in v3
- Migration guide
```

### Community Contributions

Encourage improvements:

```markdown
## Contributing to This Template

Found an issue or improvement? Please:
1. Open an issue
2. Submit a PR
3. Share your experience
```

## Publishing Your Template

### 1. Documentation

Update main documentation:
- Add to README.md template list
- Create user guide docs
- Add examples

### 2. Announcement

Share your template:
- Project changelog
- Community forums
- Social media

### 3. Gather Feedback

- Monitor issues
- Collect user experiences
- Iterate based on feedback