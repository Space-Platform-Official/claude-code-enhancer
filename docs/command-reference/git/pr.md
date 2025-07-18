# Pull Request Command Reference

**Command**: `/git/pr`  
**Category**: Git Operations  
**Description**: Comprehensive pull request management with intelligent workflow automation and quality gates

## Overview

The `/git/pr` command provides intelligent pull request management with comprehensive quality validation, automated workflow coordination, and multi-agent orchestration. This command ensures production-ready pull requests through systematic validation and collaboration features.

## Usage Patterns

```bash
# Create new pull request with intelligent analysis
/git/pr create

# Review existing pull request with quality insights
/git/pr review [pr-number]

# Safely merge PR with validation gates
/git/pr merge [pr-number]

# Check PR status and next actions
/git/pr status

# Update PR with latest changes
/git/pr update

# Close PR with proper cleanup
/git/pr close [pr-number]
```

## Command Syntax

```bash
/git/pr <action> [options] [arguments]
```

### Actions

| Action | Description | Usage |
|--------|-------------|--------|
| `create` | Create new pull request with analysis | `/git/pr create [--draft] [--base=branch]` |
| `review` | Review PR with quality insights | `/git/pr review [pr-number] [--interactive]` |
| `merge` | Safe merge with validation | `/git/pr merge [pr-number] [--strategy=squash|merge|rebase]` |
| `status` | Check PR status and recommendations | `/git/pr status [--all]` |
| `update` | Update PR with latest changes | `/git/pr update [--sync-base] [--regenerate-description]` |
| `close` | Close PR with cleanup | `/git/pr close [pr-number] [--delete-branch]` |

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--draft` | Create as draft PR | false |
| `--base=<branch>` | Target base branch | main |
| `--strategy=<type>` | Merge strategy (squash/merge/rebase) | squash |
| `--interactive` | Interactive review mode | false |
| `--all` | Show all PRs in status | false |
| `--sync-base` | Sync with base branch during update | true |
| `--regenerate-description` | Regenerate PR description | false |
| `--delete-branch` | Delete branch after close/merge | true |

## Multi-Agent Coordination

The PR command leverages multi-agent spawning for parallel operations:

### Agent Spawning Strategy

```bash
"I'll spawn multiple agents to manage PR operations comprehensively:
- Analysis Agent: Analyze PR changes and impact assessment
- Quality Agent: Run quality checks and validation gates
- CI/CD Agent: Monitor continuous integration status
- Review Agent: Manage review process and collaboration
- Documentation Agent: Generate and maintain PR templates"
```

### Agent Coordination Patterns

1. **Comprehensive PR Creation**
   - Agent 1: PR Analysis & Quality Checks
   - Agent 2: CI/CD Integration & Status Monitoring
   - Agent 3: Review Management & Collaboration
   - Agent 4: Documentation & Template Generation

2. **Quality-Focused Review**
   - Agent 1: Code Quality Review
   - Agent 2: Security Review
   - Agent 3: Performance Review
   - Agent 4: Documentation Review

3. **Safe Merge Validation**
   - Agent 1: Pre-merge validation
   - Agent 2: Conflict detection and resolution
   - Agent 3: Quality gate enforcement
   - Agent 4: Post-merge cleanup

## Workflow Examples

### Create Pull Request

```bash
# Basic PR creation with quality validation
/git/pr create

# Create draft PR for work in progress
/git/pr create --draft

# Create PR targeting specific branch
/git/pr create --base=develop
```

**Process Flow**:
1. Validates PR readiness (tests, linting, no sensitive data)
2. Analyzes branch changes and impact
3. Generates intelligent PR template
4. Creates PR with automated labeling and reviewer assignment
5. Sets up PR automation and monitoring

### Review Pull Request

```bash
# Review current branch's PR
/git/pr review

# Review specific PR interactively
/git/pr review 123 --interactive

# Quick review status check
/git/pr review 123
```

**Review Features**:
- Comprehensive change analysis
- Quality check automation
- Interactive review process
- Comment management
- Approval/change request workflow

### Merge Pull Request

```bash
# Safe merge with default strategy
/git/pr merge

# Merge with specific strategy
/git/pr merge --strategy=rebase

# Merge specific PR
/git/pr merge 123 --strategy=squash
```

**Safety Validations**:
- PR approval status check
- CI/CD status validation
- Merge conflict detection
- Branch protection compliance
- Post-merge cleanup

## Quality Gates

### Pre-Creation Validation

The command enforces strict quality gates before PR creation:

```bash
# Quality validation checklist
✅ Tests must pass
✅ Linting issues resolved
✅ No sensitive data detected
✅ Commit messages validated
✅ Branch is properly synced
```

### Review Quality Checks

Automated quality analysis during review:

```bash
# Quality assessment areas
📊 Change statistics and complexity
🎯 Change pattern identification  
🔍 Code quality metrics
🔐 Security scanning
⚡ Performance impact analysis
```

### Merge Safety Checks

Comprehensive validation before merge:

```bash
# Merge validation gates
✅ PR approval requirements met
✅ CI/CD checks passing
✅ No merge conflicts
✅ Branch protection compliance
✅ Quality thresholds satisfied
```

## Integration Support

### Platform Integration

**GitHub Integration**:
```bash
# Requires GitHub CLI (gh)
gh auth login
gh config set pr.automerge false
gh config set pr.discussions true
```

**GitLab Integration**:
```bash
# Requires GitLab CLI (glab)
glab auth login
glab config set mr.automerge false
```

### CI/CD Integration

The command integrates with various CI/CD systems:

- **GitHub Actions**: Automatic status monitoring
- **GitLab CI**: Pipeline status integration
- **Jenkins**: Build status integration
- **Custom CI**: Webhook-based integration

## Template Generation

### Intelligent PR Templates

The command generates comprehensive PR templates:

```markdown
## Summary
[Auto-generated change summary based on commits]

## Changes Made
[List of commits with descriptions]

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [x] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass (if applicable)
- [ ] Manual testing completed

## Quality Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Tests added/updated and passing
- [ ] Documentation updated
- [ ] No new security vulnerabilities
- [ ] Performance impact assessed
- [ ] Breaking changes documented
```

## Error Handling

### Common Error Scenarios

1. **PR Creation Failures**
   ```bash
   # Tests failing
   ❌ Tests failing - fix before creating PR
   
   # Linting issues
   ❌ Linting issues - fix before creating PR
   
   # Sensitive data detected
   ❌ Sensitive data detected - remove before creating PR
   ```

2. **Merge Failures**
   ```bash
   # PR not approved
   ⚠️ PR not approved yet - waiting for review
   
   # CI checks failed
   ❌ CI checks failed: [specific checks]
   
   # Merge conflicts
   ❌ PR has conflicts - resolve before merging
   ```

### Recovery Procedures

Each error includes specific recovery instructions:

```bash
# Example recovery for failing tests
echo "Fix failing tests and run:"
echo "  npm test  # or framework-specific command"
echo "  /git/pr update"
```

## Best Practices

### PR Creation Best Practices

1. **Quality First**: Always run quality checks before PR creation
2. **Meaningful Descriptions**: Use generated templates as starting point
3. **Proper Sizing**: Keep PRs focused and reviewable
4. **Clear Context**: Include ticket references and background

### Review Best Practices

1. **Thorough Analysis**: Use automated quality insights
2. **Constructive Feedback**: Focus on code improvement
3. **Timely Reviews**: Respond to review requests promptly
4. **Security Focus**: Always consider security implications

### Merge Best Practices

1. **Strategy Selection**: Choose appropriate merge strategy
2. **Final Validation**: Always validate before merge
3. **Clean History**: Prefer squash for feature branches
4. **Proper Cleanup**: Delete merged branches promptly

## Troubleshooting

### Common Issues

**GitHub CLI Not Authenticated**:
```bash
# Solution
gh auth login
gh auth status
```

**Branch Not Pushed**:
```bash
# Automatic resolution
# Command will push branch automatically
git push -u origin feature-branch
```

**Merge Conflicts**:
```bash
# Guided resolution
git rebase main
# Resolve conflicts
git add .
git rebase --continue
```

### Debug Mode

Enable verbose output for troubleshooting:

```bash
/git/pr create --verbose --debug
```

## Advanced Usage

### Custom Workflows

**Feature Branch Workflow**:
```bash
# Complete feature workflow
git checkout -b feature/new-feature
# ... make changes ...
/git/pr create --base=develop
/git/pr review --interactive
/git/pr merge --strategy=squash
```

**Hotfix Workflow**:
```bash
# Emergency hotfix workflow
git checkout -b hotfix/critical-fix
# ... make fixes ...
/git/pr create --base=main
/git/pr merge --strategy=merge  # preserve history
```

### Integration with Other Commands

**Quality Pipeline**:
```bash
# Complete quality pipeline
/quality/format
/quality/verify
/test/unit
/git/pr create
```

**Review and Merge Pipeline**:
```bash
# Review workflow
/git/pr review --interactive
/test/integration
/git/pr merge
```

## Performance Considerations

### Optimization Tips

1. **Parallel Execution**: Command uses multi-agent coordination for performance
2. **Incremental Analysis**: Only analyzes changed files
3. **Caching**: Leverages Git and platform caching
4. **Smart Defaults**: Optimized default configurations

### Resource Usage

- **Memory**: Moderate usage for change analysis
- **Network**: Depends on repository size and CI integration
- **CPU**: Parallel processing reduces overall time
- **Disk**: Temporary files for analysis and templates

## Security Considerations

### Sensitive Data Protection

The command automatically scans for:
- API keys and tokens
- Passwords and secrets
- Configuration files with sensitive data
- Database connection strings

### Access Control

Respects platform-specific access controls:
- Branch protection rules
- Required reviewers
- Status check requirements
- Merge restrictions

## Related Commands

- **[/git/commit](commit.md)** - Smart commit creation
- **[/git/branch](branch.md)** - Branch management
- **[/git/status](status.md)** - Enhanced Git status
- **[/quality/verify](../quality/verify.md)** - Quality verification
- **[/test/unit](../test/unit.md)** - Unit testing

---

*The `/git/pr` command provides comprehensive pull request management with intelligent automation, quality gates, and multi-agent coordination for production-ready workflows.*