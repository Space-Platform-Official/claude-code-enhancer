# Command Templates

This directory contains pre-defined command templates that provide structured workflows for common development tasks. These templates are designed to be used with the claude-flow system to ensure consistent, high-quality development practices.

## Available Commands

### Core Development Commands

#### check.md
**Purpose**: Comprehensive code quality verification and error fixing protocol
**Usage**: Use when you need to verify code quality, run tests, and ensure production readiness
**Key Features**:
- Mandatory error fixing (not just reporting)
- Multi-agent spawning for parallel issue resolution
- Zero-tolerance linting requirements
- Comprehensive test verification
- Build success validation

#### next.md
**Purpose**: Production-quality implementation workflow with strict standards
**Usage**: Use when implementing new features or making code changes
**Key Features**:
- Research-first approach
- Code evolution rules
- Language-specific requirements
- Production-ready implementation standards
- Comprehensive testing requirements

#### prompt.md
**Purpose**: Prompt synthesizer that combines templates with user arguments
**Usage**: Use to create enhanced prompts for complex development tasks
**Key Features**:
- Complete prompt generation
- Synthesis rules for combining templates
- Enhancement guidelines
- Structured prompt formatting


## How to Use

### In Claude-Flow CLI
```bash
# Apply core development command templates
claude-flow apply-template command/check.md
claude-flow apply-template command/next.md --project myapp
claude-flow apply-template command/prompt.md --enhance
```

### Direct Usage
Simply reference the command files in your claude-flow configuration or copy their content for use in your development workflow.

## Template Structure

Each command template includes:
- **allowed-tools**: Specifies which tools are available
- **description**: Brief description of the command purpose
- **detailed instructions**: Step-by-step workflow guidance
- **requirements**: Specific requirements and standards
- **examples**: Practical usage examples

## Best Practices

1. **Use commands sequentially**: Start with `check.md` to verify quality, then use `next.md` for implementation
2. **Adapt to your project**: Modify templates as needed for your specific requirements
3. **Document changes**: Keep track of any customizations you make
4. **Share with team**: Ensure all team members understand the command workflows

## Contributing

When adding new command templates:
1. Follow the existing format and structure
2. Include clear usage instructions
3. Provide practical examples
4. Test with real projects
5. Update this README

## Recently Added: CCPlugins Integration

The following high-value commands from [CCPlugins](https://github.com/brennercruvinel/CCPlugins) have been integrated:

### 🌟 Developer Experience
- **explain-like-senior.md** - Get senior developer perspective on code
- **predict-issues.md** - Proactive issue identification before they occur
- **understand.md** - Deep codebase comprehension and analysis

### 🚀 Workflow Automation
- **scaffold.md** - Intelligent pattern-based code generation
- **session-start.md** - Initialize development sessions with context
- **session-end.md** - Clean session termination and state preservation
- **todos-to-issues.md** - Convert TODOs to GitHub issues automatically
- **create-todos.md** - Initialize task tracking system

### 🔧 Code Maintenance
- **cleanproject.md** - Remove debug artifacts and temporary files
- **fix-imports.md** - Automated import optimization and cleanup

## Source

These command templates are sourced from:
- [Veraticus/nix-config](https://github.com/Veraticus/nix-config) - Original battle-tested workflows
- [CCPlugins](https://github.com/brennercruvinel/CCPlugins) - Professional command framework additions