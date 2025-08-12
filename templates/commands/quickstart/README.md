# Git Commands Quick Reference

Essential git operations with full safety and intelligence features. Use the full command paths for access to all Claude Code git functionality.

## Available Git Commands

### Core Git Operations

| Command | Description |
|---------|-------------|
| `/git/status` | Intelligent git status with insights and recommendations |
| `/git/commit` | Smart git commit with validation and conventional formatting |
| `/git/push` | Safe git push with comprehensive protection |
| `/git/workflows/feature` | Complete git feature workflow lifecycle |

## Quick Reference

### Daily Development Flow
```bash
# Check current status
/git/status

# Make changes, then commit
/git/commit "feat: add new feature"

# Push safely
/git/push

# Or use complete feature workflow
/git/workflows/feature init    # Start new feature
/git/workflows/feature dev     # Development iterations  
/git/workflows/feature review  # Prepare for review
/git/workflows/feature merge   # Integrate feature
```

### Command Details

#### `/git/status` - Git Status
- **Purpose:** Instant repository intelligence and workflow recommendations
- **Features:** Branch status, file changes, team activity, quick actions
- **Best For:** Understanding current state before any git operation

#### `/git/commit` - Git Commit  
- **Purpose:** Smart commits with validation and conventional formatting
- **Features:** Pre-commit hooks, branch protection, quality gates
- **Best For:** Creating clean, validated commits that tell a story

#### `/git/push` - Git Push
- **Purpose:** Safe pushes with comprehensive protection
- **Features:** Branch protection, quality validation, CI/CD integration
- **Best For:** Sharing code safely without breaking team workflows

#### `/git/workflows/feature` - Git Feature
- **Purpose:** End-to-end feature development lifecycle
- **Features:** Planning, development, review, integration phases
- **Best For:** Managing complete features from start to production

## Benefits of Using Git Commands

✅ **Speed** - Direct access to git operations  
✅ **Safety** - Comprehensive protection and validation included  
✅ **Consistency** - Full arguments and options supported  
✅ **Intelligence** - Smart recommendations and insights  
✅ **Quality** - Built-in validation and best practices  

## Arguments Support

All git commands support comprehensive arguments and options:

```bash
# Status with options
/git/status --verbose --interactive

# Commit with message
/git/commit "fix(auth): resolve login timeout"

# Push with specific options
/git/push --force-with-lease origin feature-branch

# Feature workflow phases
/git/workflows/feature init
/git/workflows/feature dev  
/git/workflows/feature review
/git/workflows/feature merge
```

## Advanced Usage

These git commands provide comprehensive functionality for professional development workflows:

- **Learning** - Understanding all available git features and patterns
- **Advanced Options** - Complex scenarios requiring detailed configuration
- **Documentation** - Referencing complete feature sets and capabilities
- **Troubleshooting** - Accessing detailed error handling and diagnostics

## Integration with Other Commands

Git commands work seamlessly with other Claude Code commands:

```bash
# Check before committing
/git/status
/check                    # Run full codebase validation
/git/commit "feat: implement feature after validation"

# Feature development with testing
/git/workflows/feature dev
/test-coverage           # Check test coverage
/git/commit "test: improve coverage for auth module"

# Review preparation
/git/workflows/feature review
/security-audit         # Run security scan
/docs                   # Update documentation
```

## Tips for Maximum Productivity

1. **Start with Status** - Always run `/git/status` first
2. **Small Commits** - Use `/git/commit` frequently with focused changes
3. **Safe Pushing** - Let `/git/push` validate before pushing
4. **Feature Workflow** - Use `/git/workflows/feature` for complete feature lifecycle

## Full Documentation

Access complete documentation for each git command:

- [Git Status](/git/status.md) - Complete status analysis features
- [Git Commit](/git/commit.md) - Advanced commit strategies  
- [Git Push](/git/push.md) - Comprehensive push safety features
- [Feature Workflow](/git/workflows/feature.md) - Complete feature lifecycle

---

**Remember:** These commands give you the full power of Claude Code's git intelligence with comprehensive safety and validation!