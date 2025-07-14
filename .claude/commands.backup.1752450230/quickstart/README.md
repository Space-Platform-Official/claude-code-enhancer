# Quickstart Git Commands

Convenient shortcuts for frequently used git operations with full safety and intelligence features.

## Available Commands

### Core Git Operations

| Command | Alias To | Description |
|---------|----------|-------------|
| `/quickstart/gs` | `/git/status` | Quick git status with intelligent insights |
| `/quickstart/gc` | `/git/commit` | Quick git commit with smart validation |
| `/quickstart/gp` | `/git/push` | Quick git push with safety checks |
| `/quickstart/gf` | `/git/workflows/feature` | Quick git feature workflow |

## Quick Reference

### Daily Development Flow
```bash
# Check current status
/quickstart/gs

# Make changes, then commit
/quickstart/gc "feat: add new feature"

# Push safely
/quickstart/gp

# Or use complete feature workflow
/quickstart/gf init    # Start new feature
/quickstart/gf dev     # Development iterations  
/quickstart/gf review  # Prepare for review
/quickstart/gf merge   # Integrate feature
```

### Command Details

#### `/quickstart/gs` - Git Status
- **Purpose:** Instant repository intelligence and workflow recommendations
- **Features:** Branch status, file changes, team activity, quick actions
- **Best For:** Understanding current state before any git operation

#### `/quickstart/gc` - Git Commit  
- **Purpose:** Smart commits with validation and conventional formatting
- **Features:** Pre-commit hooks, branch protection, quality gates
- **Best For:** Creating clean, validated commits that tell a story

#### `/quickstart/gp` - Git Push
- **Purpose:** Safe pushes with comprehensive protection
- **Features:** Branch protection, quality validation, CI/CD integration
- **Best For:** Sharing code safely without breaking team workflows

#### `/quickstart/gf` - Git Feature
- **Purpose:** End-to-end feature development lifecycle
- **Features:** Planning, development, review, integration phases
- **Best For:** Managing complete features from start to production

## Benefits of Using Quickstart Commands

✅ **Speed** - Memorable shortcuts for common operations  
✅ **Safety** - All full command protections included  
✅ **Consistency** - Same arguments and options supported  
✅ **Intelligence** - Smart recommendations and insights  
✅ **Quality** - Built-in validation and best practices  

## Arguments Support

All quickstart commands support the same arguments as their full counterparts:

```bash
# Status with options
/quickstart/gs --verbose --interactive

# Commit with message
/quickstart/gc "fix(auth): resolve login timeout"

# Push with specific options
/quickstart/gp --force-with-lease origin feature-branch

# Feature workflow phases
/quickstart/gf init
/quickstart/gf dev  
/quickstart/gf review
/quickstart/gf merge
```

## When to Use Full Commands

While quickstart aliases are perfect for daily use, consider the full commands for:

- **Learning** - Understanding all available features
- **Advanced Options** - Complex scenarios requiring detailed configuration
- **Documentation** - Referencing complete feature sets
- **Troubleshooting** - Accessing detailed error handling

## Integration with Other Commands

Quickstart commands work seamlessly with other Claude Code commands:

```bash
# Check before committing
/quickstart/gs
/check                    # Run full codebase validation
/quickstart/gc "feat: implement feature after validation"

# Feature development with testing
/quickstart/gf dev
/test-coverage           # Check test coverage
/quickstart/gc "test: improve coverage for auth module"

# Review preparation
/quickstart/gf review
/security-audit         # Run security scan
/docs                   # Update documentation
```

## Tips for Maximum Productivity

1. **Start with Status** - Always run `/quickstart/gs` first
2. **Small Commits** - Use `/quickstart/gc` frequently with focused changes
3. **Safe Pushing** - Let `/quickstart/gp` validate before pushing
4. **Feature Workflow** - Use `/quickstart/gf` for complete feature lifecycle

## Full Documentation

Each quickstart command links to its full documentation:

- [Git Status](/git/status.md) - Complete status analysis features
- [Git Commit](/git/commit.md) - Advanced commit strategies  
- [Git Push](/git/push.md) - Comprehensive push safety features
- [Feature Workflow](/git/workflows/feature.md) - Complete feature lifecycle

---

**Remember:** These shortcuts give you the full power of Claude Code's git intelligence in memorable, fast commands!