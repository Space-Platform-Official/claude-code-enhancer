# 📚 Claude Code Documentation

> Comprehensive documentation for all Claude Code commands, agents, and workflows

## 🚀 Quick Navigation

### Core Commands
[**Core Commands Documentation →**](./core-commands.md)
- `/architect` - System architecture and design
- `/next` - Production implementation workflow
- `/milestone` - Comprehensive milestone management
- `/check` - Code quality verification
- `/scaffold` - Intelligent code generation

### Development Commands
[**Development Commands Documentation →**](./development-commands.md)
- `/test/*` - Testing suite (unit, integration, e2e, TDD)
- `/quality/*` - Code quality tools (format, dedupe, verify)
- `/optimize` - Performance optimization
- `/refactor` - Systematic code improvement
- `/security-audit` - Security vulnerability scanning

### Git Commands
[**Git Commands Documentation →**](./git-commands.md)
- `/git/commit` - Smart commit creation
- `/git/pr` - Pull request management
- `/git/branch` - Branch operations
- `/git/workflows/*` - Automated workflows (feature, hotfix, release)

### Agents Reference
[**Agents Reference Documentation →**](./agents-reference.md)
- Testing Agents (test-orchestrator, unit-test-master, integration-test-master, test-fixer)
- Milestone Agents (coordinator, planner, executor)
- Code Quality Agents (analyzer, enforcer, processor)
- Infrastructure Agents (orchestrator, git-operator, dependency-manager)

---

## 📖 Documentation Structure

Each documentation file contains:
- **Command Overview** - Purpose and key features
- **Usage Examples** - Practical code samples
- **Configuration** - Available options and settings
- **Advanced Patterns** - Complex usage scenarios
- **Troubleshooting** - Common issues and solutions

## 🎯 Common Workflows

### Feature Development
```bash
claude architect          # Design the architecture
claude milestone          # Plan the milestone
claude next              # Implement with quality gates
claude test unit         # Test the implementation
claude git commit        # Commit changes
claude git pr            # Create pull request
```

### Bug Fixing
```bash
claude understand        # Analyze the codebase
claude test workflows tdd  # Fix with test-driven development
claude check --fix       # Verify and auto-fix issues
claude git workflows hotfix  # Create hotfix
```

### Code Quality
```bash
claude quality verify    # Run all quality checks
claude quality format    # Format code
claude quality dedupe    # Remove duplicates
claude optimize         # Optimize performance
```

## 🔧 Installation

All commands and agents are distributed via `claude-merge`:

```bash
# Install all templates
claude-merge

# Templates are installed to .claude/ directory
ls .claude/commands/
ls .claude/agents/
```

## 📋 Command Categories

### Architecture & Planning
- System design and architecture analysis
- Milestone planning and tracking
- Project scaffolding

### Development & Testing
- Test-driven development
- Unit, integration, and e2e testing
- Performance testing and optimization

### Code Quality
- Formatting and linting
- Deduplication and refactoring
- Security auditing

### Version Control
- Commit management
- Pull request automation
- Branch workflows

### Agent Coordination
- Multi-agent task execution
- Parallel processing
- Result aggregation

## 🚨 Important Notes

### Quality Gates
All commands enforce strict quality standards:
- Zero-tolerance for linting errors
- Mandatory test passing
- Format compliance required
- Security checks enforced

### Hook Integration
Commands integrate with git hooks:
- Pre-commit validation
- Pre-push quality gates
- Post-edit formatting
- Automatic standards enforcement

### Multi-Agent Patterns
Many commands use parallel agent execution:
- Architecture analysis with 5 parallel agents
- Test suite parallelization
- Code analysis distribution

## 📊 Quick Reference

| Command | Purpose | Agent Support | Quality Gates |
|---------|---------|---------------|---------------|
| `/architect` | System design | 5 parallel agents | ADR generation |
| `/next` | Implementation | Research agents | All gates required |
| `/milestone` | Project tracking | Coordinator agents | Git integration |
| `/test/*` | Testing suite | Test agents | 100% pass required |
| `/quality/*` | Code quality | Enforcer agents | Zero tolerance |
| `/git/*` | Version control | Git operator | Hook validation |

## 🔍 Search Tips

To find specific documentation:
1. Use browser search (Ctrl+F) within category files
2. Check the relevant category document
3. Look for command patterns (e.g., all test commands in development-commands.md)
4. Review agent spawning examples in agents-reference.md

## 📚 Additional Resources

- [Templates Source](../templates/) - Original template files
- [CLAUDE.md](../CLAUDE.md) - Core development guidelines
- [Hooks Documentation](../templates/hooks/README.md) - Hook integration guide

---

*Documentation auto-generated from templates/*
*Last updated: 2025*