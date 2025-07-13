---
allowed-tools: all
description: Quick git feature workflow from planning to production merge
---

# Quick Git Feature (gf)

Fast access to complete feature branch workflow with planning, development, review, and integration phases.

**Usage:** `/quickstart/gf $ARGUMENTS`

## Quick Command Reference

This is a convenient alias to the full feature workflow command:
```
/quickstart/gf  →  /git/workflows/feature
```

## What You Get

🚀 **Complete Feature Lifecycle:**
- Interactive feature planning and setup
- Structured development iterations  
- Code review preparation and handling
- Safe integration and cleanup
- Team collaboration support
- Quality gates at every phase

## Arguments Support

All arguments are passed through to the full command:
```bash
/quickstart/gf init                 # Initialize new feature
/quickstart/gf dev                  # Development iteration
/quickstart/gf review              # Prepare for review
/quickstart/gf merge               # Merge to main
/quickstart/gf --help              # Show detailed help
```

## Feature Phases

### 1. Planning & Setup
```bash
/quickstart/gf init

# Interactive setup:
📋 Ticket ID (e.g., JIRA-123): PROJ-456
📝 Feature description (kebab-case): user-authentication
👤 Assigned developer(s): john@company.com
🎯 Target milestone/sprint: Sprint 23

✅ Feature branch 'feature/PROJ-456-user-authentication' created
```

### 2. Development Iterations
```bash
/quickstart/gf dev

# Development cycle:
🔄 Syncing with main branch...
💻 Development time!
🔍 Running quality checkpoint...
✅ Quality checkpoint complete
📤 Push changes for team visibility? (y/n): y
```

### 3. Code Review Preparation
```bash
/quickstart/gf review

# Review preparation:
🔍 Running final quality checks...
✅ Tests passed (coverage: 87%)
✅ Linting passed
✅ Documentation updated
✅ Security scan passed
📝 Pull request created: https://github.com/user/repo/pull/123
```

### 4. Integration & Merge
```bash
/quickstart/gf merge

# Merge process:
🔍 Final pre-merge validation...
✅ CI checks passed
✅ No merge conflicts
🎯 Merging feature to main...
🧹 Post-merge cleanup completed
🎉 Feature successfully integrated!
```

## Smart Features

🧠 **Intelligent Assistance:**

**Automatic Documentation:**
- Feature planning templates
- Acceptance criteria tracking
- Technical requirements checklist
- Testing strategy documentation

**Quality Integration:**
- Pre-commit hooks setup
- Commit message templates
- Code coverage monitoring
- Security scanning

**Team Collaboration:**
- Multi-developer support
- Shared branch management
- PR creation and management
- Review feedback handling

## Feature Documentation

Automatically creates `FEATURE.md`:
```markdown
# Feature: User Authentication

**Ticket:** PROJ-456
**Status:** In Development  
**Assignees:** john@company.com
**Milestone:** Sprint 23

## Acceptance Criteria
- [ ] User can register with email
- [ ] User can login securely
- [ ] Password reset functionality

## Progress: 60% (3/5 criteria completed)
```

## Development Workflow

```
main ──○──○──○──○──○──○── (production ready)
        \              /
         ○──○──○──○──○── feature/PROJ-456-user-auth
              │     │
           review  updates
```

## Quality Gates

Each phase includes validation:

**Planning Phase:**
- Branch naming validation
- Feature documentation setup
- Development environment configuration

**Development Phase:**
- Regular main sync
- Continuous testing
- Code quality checks
- Progress tracking

**Review Phase:**
- Comprehensive test coverage
- Documentation updates
- Security validation
- Feature completion verification

**Integration Phase:**
- Final validation
- Merge strategy selection
- Complete cleanup

## Error Recovery

Built-in handling for:
- **Merge Conflicts** - Step-by-step resolution
- **Failed CI Checks** - Detailed troubleshooting
- **Large Features** - Automatic breakdown suggestions

## Collaboration Support

👥 **Multi-Developer Features:**
```bash
/quickstart/gf collaborate

# Sets up:
- Shared development branch
- Branch protection rules
- Collaboration guidelines
- Sub-branch strategies
```

## Integration Options

**Merge Strategies:**
1. **Squash Merge** (recommended) - Clean history
2. **Merge Commit** - Preserve feature history  
3. **Rebase Merge** - Linear history

**Feature Flags:**
```bash
/quickstart/gf flags

# Configures:
- Gradual rollout strategy
- A/B testing setup
- Quick rollback capability
- Usage documentation
```

## Example Complete Workflow

```bash
# 1. Start new feature
/quickstart/gf init
# → Creates feature/PROJ-456-user-auth

# 2. Development cycles (repeat as needed)
/quickstart/gf dev
# → Code, test, commit, push

# 3. Prepare for review
/quickstart/gf review  
# → Validates quality, creates PR

# 4. Handle review feedback
/quickstart/gf feedback
# → Address comments, update PR

# 5. Merge when approved
/quickstart/gf merge
# → Squash merge, cleanup, celebrate!
```

## Benefits

✅ **Structured Process:**
- Consistent feature development
- Quality gates at every step
- Complete documentation
- Team alignment

✅ **Automation:**
- Reduced manual errors
- Faster iteration cycles
- Integrated tooling
- Smart recommendations

✅ **Collaboration:**
- Clear communication
- Review workflows
- Team coordination
- Knowledge sharing

## Related Quick Commands

- `/quickstart/gs` - Check current status
- `/quickstart/gc` - Commit during development
- `/quickstart/gp` - Push feature updates

## Integration Benefits

- **Project Management** - Ticket tracking integration
- **CI/CD** - Automated testing and deployment
- **Code Quality** - Continuous validation
- **Team Workflow** - Standardized processes

## Full Documentation

For complete details and advanced features, see:
- `/git/workflows/feature` - Full feature workflow
- `/git/` - Complete git command suite
- `/git/_shared/` - Shared utilities and standards

---

**Remember:** Great features are built through disciplined process, not just good code!