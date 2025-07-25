# Claude Code Hooks System

This directory contains both git hooks and **automatic standards integration hooks** that work with Claude Code's native hook system to ensure code quality, security, and consistency.

## 🚀 Automatic Standards Integration (CORRECTED)

### **Setup Instructions**

1. **Copy adapter scripts to your project:**
   ```bash
   cp claude-pre-edit-adapter.sh your-project/.claude/hooks/
   cp claude-post-edit-adapter.sh your-project/.claude/hooks/
   chmod +x your-project/.claude/hooks/claude-*-adapter.sh
   ```

2. **Add hooks configuration to `settings.local.json`:**
   ```bash
   # Copy the template configuration
   cp settings-template.json your-project/.claude/settings.local.json
   
   # Or merge with existing settings.local.json
   ```

3. **Customize for your distributed standards:**
   - Edit the adapter scripts to call your specific validation/auto-fix hooks
   - Update the PHP paradigm scripts for your standards

### **How It Works**
- **PreToolUse Hook**: Validates standards before Edit/Write operations
- **PostToolUse Hook**: Auto-applies standards after Edit/Write operations  
- **Configured in**: `settings.local.json` (NOT hooks.json)
- **Permissions**: Required for hook scripts to execute

## Git Hooks

### pre-commit.sh
**Triggered**: Before each commit is finalized  
**Purpose**: Quality gate to prevent problematic commits

**Checks performed**:
- ✅ **CLAUDE.md validation**: Ensures development guidelines are present
- ✅ **Code linting**: Runs configured linter (if available)
- ✅ **Code formatting**: Applies code formatter (if available)
- ✅ **Secret detection**: Scans for potential secrets or sensitive data
- ⚠️ **Optional tests**: Runs tests if enabled via `CLAUDE_HOOKS_RUN_TESTS_PRECOMMIT=true`

**Failure behavior**: Blocks commit if critical issues found

### post-commit.sh
**Triggered**: After each successful commit  
**Purpose**: Cleanup and notification tasks

**Actions performed**:
- 🧹 **Backup cleanup**: Removes old backup files based on retention policy
- 📖 **Documentation updates**: Updates docs if source files changed
- 📊 **Statistics tracking**: Maintains commit statistics in `.claude/stats/`
- 🔔 **Notifications**: Sends webhook/Slack notifications if configured

**Failure behavior**: Non-blocking (informational only)

### pre-push.sh
**Triggered**: Before pushing commits to remote repository  
**Purpose**: Comprehensive quality gate before sharing code

**Checks performed**:
- 🔒 **Security audit**: Deep scan for secrets, large files, sensitive data
- 🧪 **Full test suite**: Runs complete test suite (if enabled)
- 🏗️ **Build verification**: Ensures code builds successfully
- 📋 **Code quality**: Comprehensive linting and standards checks
- 🛡️ **Branch protection**: Prevents direct pushes to main/master (if enabled)
- 📝 **Commit message format**: Validates conventional commit format

**Failure behavior**: Blocks push if any critical checks fail

### post-merge.sh
**Triggered**: After successful merge operations  
**Purpose**: Post-merge cleanup and synchronization

**Actions performed**:
- 📦 **Dependency updates**: Updates package dependencies if package files changed
- 🔍 **Conflict detection**: Checks for unresolved merge conflicts in CLAUDE.md
- 🧪 **Post-merge tests**: Runs tests to ensure merge didn't break anything
- 📊 **Merge tracking**: Updates merge statistics and metadata
- 🧹 **Cleanup**: Removes temporary files and cache directories
- 🔔 **Merge notifications**: Sends merge completion notifications

**Failure behavior**: Non-blocking for cleanup tasks, blocking for conflicts

## Installation

Hooks are automatically installed when you run the Claude Code merge script:

```bash
# Hooks are installed automatically during merge
./smart-merge-claude.sh /path/to/project

# Or if you have claude-merge installed
claude-merge /path/to/project
```

### Manual Installation

```bash
# Copy hooks to your project
cp -r templates/hooks/ /path/to/project/.claude/hooks/

# Make hooks executable
chmod +x /path/to/project/.claude/hooks/*.sh

# Install git hook integration
cd /path/to/project
./.claude/hooks/install-git-integration.sh
```

## Configuration

### Environment Variables

Configure hook behavior using environment variables in your shell or `.claude/config/env.sh`:

```bash
# Test execution control
CLAUDE_HOOKS_RUN_TESTS_PRECOMMIT=true    # Run tests before commit
CLAUDE_HOOKS_RUN_TESTS_PREPUSH=true      # Run tests before push
CLAUDE_HOOKS_RUN_TESTS_POSTMERGE=false   # Run tests after merge

# Build checks
CLAUDE_HOOKS_RUN_BUILD_PREPUSH=true      # Run build before push

# Branch protection
CLAUDE_HOOKS_PROTECT_MAIN=true           # Prevent direct pushes to main

# Notifications
CLAUDE_HOOKS_NOTIFICATIONS=true          # Enable notifications
CLAUDE_HOOKS_WEBHOOK_URL="https://..."   # Webhook endpoint
CLAUDE_HOOKS_SLACK_WEBHOOK="https://..." # Slack webhook

# Hook control
CLAUDE_HOOKS_PRE_COMMIT_DISABLED=false   # Disable pre-commit hook
CLAUDE_HOOKS_POST_COMMIT_DISABLED=false  # Disable post-commit hook
CLAUDE_HOOKS_PRE_PUSH_DISABLED=false     # Disable pre-push hook
CLAUDE_HOOKS_POST_MERGE_DISABLED=false   # Disable post-merge hook

# Quality commands
LINT_COMMAND="npm run lint"              # Linting command
FORMAT_COMMAND="npm run format"          # Formatting command
TEST_COMMAND="npm test"                  # Test command
BUILD_COMMAND="npm run build"            # Build command
DOCS_COMMAND="npm run docs"              # Documentation generation
```

### Project Configuration

Create `.claude/config/env.sh` in your project:

```bash
#!/bin/bash
# Claude Code project configuration

# Quality commands
export LINT_COMMAND="eslint src/"
export FORMAT_COMMAND="prettier --write src/"
export TEST_COMMAND="jest"
export BUILD_COMMAND="npm run build"

# Hook behavior
export CLAUDE_HOOKS_RUN_TESTS_PRECOMMIT=false
export CLAUDE_HOOKS_RUN_TESTS_PREPUSH=true
export CLAUDE_HOOKS_PROTECT_MAIN=true

# Backup settings
export CLAUDE_MERGE_BACKUP_RETENTION=48  # Keep backups for 48 hours
```

## Integration with Different Languages/Frameworks

### JavaScript/TypeScript
```bash
LINT_COMMAND="eslint src/ --ext .js,.ts,.tsx"
FORMAT_COMMAND="prettier --write src/"
TEST_COMMAND="jest"
BUILD_COMMAND="npm run build"
```

### Python
```bash
LINT_COMMAND="flake8 src/"
FORMAT_COMMAND="black src/"
TEST_COMMAND="pytest"
BUILD_COMMAND="python setup.py build"
```

### Go
```bash
LINT_COMMAND="golangci-lint run"
FORMAT_COMMAND="gofmt -w ."
TEST_COMMAND="go test ./..."
BUILD_COMMAND="go build ./..."
```

### Rust
```bash
LINT_COMMAND="cargo clippy"
FORMAT_COMMAND="cargo fmt"
TEST_COMMAND="cargo test"
BUILD_COMMAND="cargo build"
```

### PHP
```bash
LINT_COMMAND="phpcs src/"
FORMAT_COMMAND="phpcbf src/"
TEST_COMMAND="phpunit"
BUILD_COMMAND="composer install --no-dev"
```

## Bypassing Hooks

### Temporary Bypass
```bash
# Skip all hooks for a single commit
git commit --no-verify

# Skip all hooks for a single push
git push --no-verify
```

### Permanent Disable
```bash
# Disable specific hooks
export CLAUDE_HOOKS_PRE_COMMIT_DISABLED=true
export CLAUDE_HOOKS_PRE_PUSH_DISABLED=true

# Or remove git hook integration
rm .git/hooks/pre-commit .git/hooks/pre-push
```

## Troubleshooting

### Hook Not Running
1. Check if git hooks are executable: `ls -la .git/hooks/`
2. Verify hook integration: `cat .git/hooks/pre-commit`
3. Check if hooks are disabled via environment variables

### Permission Issues
```bash
# Make hooks executable
chmod +x .claude/hooks/*.sh

# Fix git hook permissions
chmod +x .git/hooks/*
```

### Command Not Found Errors
```bash
# Verify commands are available
which eslint  # or your linter
which jest    # or your test runner

# Update PATH if needed
export PATH="./node_modules/.bin:$PATH"
```

### Performance Issues
```bash
# Disable expensive checks for large repositories
export CLAUDE_HOOKS_RUN_TESTS_PRECOMMIT=false
export CLAUDE_HOOKS_RUN_BUILD_PREPUSH=false

# Reduce backup retention
export CLAUDE_MERGE_BACKUP_RETENTION=24
```

### Debug Mode
```bash
# Enable verbose logging
export CLAUDE_HOOKS_DEBUG=true

# Check hook logs
tail -f .claude/logs/hooks.log
```

## Security Considerations

### Secret Detection
Hooks automatically scan for:
- API keys and tokens
- Password patterns
- Private key files
- Environment files (.env, .key, .pem)

### Safe Practices
- Never commit actual secrets to test hook functionality
- Use environment variables for sensitive configuration
- Regularly review hook logs for security alerts
- Keep hooks updated to latest templates

## Customization

### Adding Custom Checks
1. Copy an existing hook as a template
2. Add your custom logic in the appropriate section
3. Test thoroughly before deploying
4. Document any new environment variables

### Integration with External Tools
- **CI/CD**: Hooks work alongside GitHub Actions, Jenkins, etc.
- **Code Quality**: Integrates with SonarQube, CodeClimate, etc.
- **Security**: Works with Snyk, SAST tools, etc.
- **Monitoring**: Sends data to observability platforms

## Best Practices

1. **Start Simple**: Enable basic hooks first, add complexity gradually
2. **Test Hooks**: Verify hooks work correctly before team adoption
3. **Document Configuration**: Keep team informed about enabled checks
4. **Performance**: Monitor hook execution time, optimize as needed
5. **Consistency**: Use same configuration across team projects
6. **Backup Strategy**: Configure appropriate backup retention
7. **Gradual Rollout**: Enable strict checks gradually for existing projects

## Support

For issues with Claude Code hooks:
1. Check this documentation
2. Review environment variable configuration
3. Examine hook logs in `.claude/logs/`
4. Test with minimal configuration first
5. Verify all required commands are available