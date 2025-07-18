# Smart Git Commit Command Reference

**Command**: `/git/commit`  
**Category**: Git Operations  
**Description**: Smart git commit with automatic validation and conventional commit support

## Overview

The `/git/commit` command provides intelligent commit creation with automatic validation, conventional commit formatting, and comprehensive pre-commit hook compliance. It ensures every commit meets quality standards and follows established conventions.

## Usage Patterns

```bash
# Smart commit with automatic analysis
/git/commit

# Commit with specific message
/git/commit "feat(api): add user authentication endpoint"

# Commit with guided message creation
/git/commit --interactive

# Stage and commit all changes
/git/commit --all

# Amend previous commit
/git/commit --amend

# Commit with co-authors
/git/commit --co-author="Jane Doe <jane@example.com>"
```

## Command Syntax

```bash
/git/commit [message] [options]
```

### Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| `message` | Commit message (optional) | `"feat: add new feature"` |

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--interactive` | Interactive message creation | false |
| `--all` | Stage all changes before commit | false |
| `--amend` | Amend previous commit | false |
| `--dry-run` | Preview commit without executing | false |
| `--no-verify` | Skip pre-commit hooks | false |
| `--co-author=<author>` | Add co-author | none |
| `--scope=<scope>` | Specific commit scope | auto-detect |
| `--type=<type>` | Specific commit type | auto-detect |

## Conventional Commit Standards

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Commit Types

| Type | Description | Usage |
|------|-------------|-------|
| `feat` | New feature | Adding new functionality |
| `fix` | Bug fix | Fixing existing issues |
| `docs` | Documentation | Documentation changes only |
| `style` | Code style | Formatting, semicolons, etc. |
| `refactor` | Code refactoring | Neither fixes bug nor adds feature |
| `perf` | Performance | Performance improvements |
| `test` | Testing | Adding or updating tests |
| `chore` | Maintenance | Build process, tools, etc. |
| `ci` | CI/CD | CI configuration changes |
| `build` | Build system | Build system changes |
| `revert` | Revert | Reverting previous commits |

### Scope Examples

| Scope | Description | Usage |
|-------|-------------|-------|
| `api` | API changes | Backend API modifications |
| `auth` | Authentication | Auth-related changes |
| `core` | Core functionality | Core system changes |
| `ui` | User interface | Frontend UI changes |
| `deps` | Dependencies | Dependency updates |
| `config` | Configuration | Config file changes |
| `db` | Database | Database-related changes |
| `tests` | Test code | Test-specific changes |

## Intelligent Commit Process

### Phase 1: Pre-Commit Analysis

The command performs comprehensive analysis before committing:

```bash
# Status analysis
✅ Check git status and branch state
✅ Analyze staged vs unstaged changes
✅ Verify working directory state
✅ Check for merge conflicts
✅ Validate branch protection rules
```

### Phase 2: Change Analysis

Intelligent analysis of changes to determine commit characteristics:

```bash
# Change categorization
📊 File type analysis (code, docs, config, tests)
🎯 Change impact assessment (breaking, non-breaking)
📈 Change size evaluation (small, medium, large)
🔍 Pattern recognition (feature, fix, refactor)
🏷️ Scope detection from file paths
```

### Phase 3: Quality Validation

Comprehensive quality checks before commit:

```bash
# Quality validation checklist
✅ Pre-commit hooks execution
✅ Linting validation
✅ Test execution for changed files
✅ Security scan for sensitive data
✅ Code style compliance
✅ Documentation requirements
```

### Phase 4: Message Generation

Smart commit message generation based on analysis:

```bash
# Message components
🔤 Type determination from change analysis
🏷️ Scope extraction from file patterns
📝 Subject generation from change summary
📄 Body creation with change details
🔗 Footer with issue links and co-authors
```

## Workflow Examples

### Basic Smart Commit

```bash
# Automatic commit with analysis
/git/commit

# Process flow:
# 1. Analyzes staged changes
# 2. Determines commit type and scope
# 3. Generates conventional commit message
# 4. Runs quality validation
# 5. Creates commit with generated message
```

### Interactive Commit Creation

```bash
# Interactive message building
/git/commit --interactive

# Interactive process:
# 1. Shows change analysis
# 2. Prompts for commit type
# 3. Suggests scope options
# 4. Helps craft subject line
# 5. Adds body and footer if needed
```

### Comprehensive Commit with Validation

```bash
# Full validation and commit
/git/commit --all

# Process includes:
# 1. Stages all changes
# 2. Runs complete validation suite
# 3. Generates optimal commit message
# 4. Creates commit with full metadata
```

## Validation Gates

### Pre-Commit Hook Integration

The command integrates with standard pre-commit hooks:

```bash
# Hook execution order
1. 🔍 pre-commit hook (if exists)
2. 🧹 Code formatting validation
3. 🔍 Linting checks
4. 🧪 Relevant test execution
5. 🔐 Security scanning
6. 📊 Quality metrics validation
```

### Quality Checks

Comprehensive quality validation:

```bash
# Code quality validation
✅ Syntax validation
✅ Style guide compliance
✅ Import organization
✅ Dead code detection
✅ Complexity analysis
✅ Documentation coverage
```

### Security Validation

Automated security scanning:

```bash
# Security check areas
🔐 Sensitive data detection (keys, passwords, tokens)
🚫 Hardcoded credentials scan
📝 Configuration file validation
🌐 URL and endpoint security
💾 Database connection string checks
```

## Message Templates

### Auto-Generated Messages

The command generates contextual messages:

```bash
# Feature addition
feat(auth): implement JWT token validation

Add JWT token validation middleware with expiration checking
and role-based access control integration.

- Add TokenValidator class with expiration logic
- Integrate with existing auth middleware
- Add comprehensive test coverage
- Update API documentation

Closes #123

# Bug fix
fix(api): resolve user profile update race condition

Fix race condition in user profile updates that occurred when
multiple requests modified the same user simultaneously.

- Add optimistic locking to user model
- Implement retry logic for conflicting updates
- Add integration tests for concurrent updates
- Update error handling documentation

Fixes #456
```

### Custom Message Validation

Validates custom messages against standards:

```bash
# Message validation rules
✅ Starts with valid commit type
✅ Includes scope if applicable
✅ Subject line under 50 characters
✅ Body lines under 72 characters
✅ Proper footer format
✅ Issue reference format
```

## Error Handling and Recovery

### Common Error Scenarios

1. **Pre-commit Hook Failures**
   ```bash
   ❌ Pre-commit hook failed: linting errors
   
   # Automatic recovery
   → Running auto-fix for common issues
   → Re-executing validation
   → Providing manual fix instructions
   ```

2. **Sensitive Data Detection**
   ```bash
   ❌ Sensitive data detected in staged changes
   
   # Security response
   → Blocking commit execution
   → Highlighting problematic lines
   → Suggesting remediation steps
   → Offering to unstage sensitive files
   ```

3. **Test Failures**
   ```bash
   ❌ Tests failing for changed files
   
   # Test failure handling
   → Identifying failing tests
   → Running focused test execution
   → Providing failure analysis
   → Suggesting fix approaches
   ```

### Recovery Procedures

Each error includes specific recovery guidance:

```bash
# Example: Linting errors
echo "Linting errors found. Options:"
echo "1. Auto-fix: /quality/format --fix"
echo "2. Manual fix: Check specific linting errors"
echo "3. Skip validation: /git/commit --no-verify (not recommended)"
```

## Integration Features

### Issue Tracking Integration

Automatic issue reference detection:

```bash
# Supported patterns
- Closes #123
- Fixes #456
- Resolves #789
- References #101112

# Branch-based detection
feature/ABC-123-add-auth → Automatically adds "Refs ABC-123"
bugfix/fix-login-issue → Suggests issue reference
```

### Co-Author Support

Multiple author attribution:

```bash
# Single co-author
/git/commit --co-author="Jane Doe <jane@example.com>"

# Multiple co-authors
/git/commit --co-author="Jane Doe <jane@example.com>" \
            --co-author="Bob Smith <bob@example.com>"

# Auto-detection from pair programming
# Detects recent committers and suggests co-authors
```

### Branch Integration

Smart branch-aware commits:

```bash
# Feature branch commits
feature/user-auth → Suggests "feat(auth)" type
bugfix/fix-login → Suggests "fix(auth)" type
docs/update-readme → Suggests "docs" type

# Automatic scope detection from branch patterns
feature/api/user-endpoints → Scope: "api"
bugfix/ui/button-styling → Scope: "ui"
```

## Performance Optimizations

### Efficient Validation

Optimized validation process:

```bash
# Smart validation
🔍 Only run relevant tests for changed files
⚡ Parallel execution of validation checks
💾 Cache validation results
🎯 Incremental linting checks
📊 Skip expensive checks for trivial changes
```

### Background Processing

Non-blocking operations:

```bash
# Parallel execution
- Main thread: User interaction and critical validation
- Background: Security scanning and documentation checks
- Async: Remote repository status checks
- Cached: Previous validation results reuse
```

## Advanced Features

### Commit Message Templates

Custom templates for different scenarios:

```bash
# Feature template
feat($scope): $subject

$body

- Feature implementation details
- Integration points
- Testing approach

$footer

# Bugfix template  
fix($scope): $subject

$body

- Root cause analysis
- Fix implementation
- Regression prevention
- Testing verification

$footer
```

### Smart Amending

Intelligent commit amending:

```bash
# Smart amend suggestions
/git/commit --amend

# Analysis includes:
- Whether amend is safe (not pushed)
- Impact on commit history
- Co-author preservation
- Message improvement suggestions
```

### Batch Operations

Multiple related commits:

```bash
# Related change detection
# Suggests splitting large changes into logical commits
# Groups related files automatically
# Maintains proper commit sequence
```

## Best Practices

### Commit Hygiene

1. **Atomic Commits**: One logical change per commit
2. **Clear Messages**: Descriptive and conventional format
3. **Quality Gates**: Always validate before committing
4. **Security First**: Never commit sensitive data

### Message Guidelines

1. **Imperative Mood**: "Add feature" not "Added feature"
2. **Concise Subjects**: Under 50 characters
3. **Detailed Bodies**: Explain why, not what
4. **Reference Issues**: Link to tracking systems

### Validation Standards

1. **Always Validate**: Don't skip quality checks
2. **Fix Issues**: Address problems before committing
3. **Test Changes**: Ensure tests pass
4. **Review Diffs**: Understand what you're committing

## Related Commands

- **[/git/pr](pr.md)** - Pull request management
- **[/git/branch](branch.md)** - Branch management
- **[/git/status](status.md)** - Enhanced Git status
- **[/quality/format](../quality/format.md)** - Code formatting
- **[/test/unit](../test/unit.md)** - Unit testing

## Troubleshooting

### Common Issues

**Hook Failures**:
```bash
# Check hook permissions
ls -la .git/hooks/
chmod +x .git/hooks/pre-commit
```

**Message Format Errors**:
```bash
# Use interactive mode for guidance
/git/commit --interactive
```

**Large Change Sets**:
```bash
# Split into logical commits
git add -p  # Partial staging
/git/commit  # Multiple commits
```

---

*The `/git/commit` command ensures every commit meets quality standards through intelligent analysis, conventional formatting, and comprehensive validation.*