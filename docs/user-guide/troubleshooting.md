# Troubleshooting Guide

A comprehensive troubleshooting guide for Claude Code Enhancer, covering common issues, solutions, and advanced debugging techniques.

## 📋 Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Installation Issues](#installation-issues)
- [Template Problems](#template-problems)
- [Command Execution Issues](#command-execution-issues)
- [Quality System Problems](#quality-system-problems)
- [Git Integration Issues](#git-integration-issues)
- [Performance Problems](#performance-problems)
- [Configuration Issues](#configuration-issues)
- [Multi-Agent Coordination Problems](#multi-agent-coordination-problems)
- [Advanced Debugging](#advanced-debugging)
- [Recovery Procedures](#recovery-procedures)

## Quick Diagnostics

### Health Check Commands

Run these commands to quickly identify common issues:

```bash
# System health check
which claude-install-flow claude-merge

# Template access verification
ls ~/.local/share/claude-code-enhancer/templates 2>/dev/null || \
ls /usr/local/share/claude-code-enhancer/templates 2>/dev/null

# Basic functionality test
cd /tmp && mkdir test-project && cd test-project
claude-install-flow --help

# Quality system test
echo "console.log('test');" > test.js
claude format --dry-run 2>&1
```

### Environment Check

```bash
# Check environment variables
echo "PATH: $PATH"
echo "CLAUDE_TEMPLATES_DIR: $CLAUDE_TEMPLATES_DIR"
echo "CLAUDE_DEBUG: $CLAUDE_DEBUG"

# Check system requirements
bash --version
git --version
```

## Installation Issues

### Commands Not Found

**Problem**: `claude-install-flow` or `claude-merge` not found after installation

**Solutions**:

1. **Check PATH** (most common issue):
   ```bash
   # For user installation
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   
   # For zsh users
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

2. **Verify installation location**:
   ```bash
   # User installation check
   ls -la ~/.local/bin/claude*
   
   # System installation check
   ls -la /usr/local/bin/claude*
   ```

3. **Reinstall if necessary**:
   ```bash
   # Clean reinstall
   ./install.sh --uninstall
   ./install.sh --user
   ```

### Permission Errors

**Problem**: Permission denied during installation or execution

**Solutions**:

1. **For user installation** (recommended):
   ```bash
   ./install.sh --user
   # No sudo required
   ```

2. **For system installation**:
   ```bash
   sudo ./install.sh --system
   ```

3. **Fix existing permissions**:
   ```bash
   # Fix user installation permissions
   chmod +x ~/.local/bin/claude*
   
   # Fix template directory permissions
   chmod -R u+rwX ~/.local/share/claude-code-enhancer/
   ```

### Installation Script Failures

**Problem**: Installation script fails or hangs

**Solutions**:

1. **Run with debug output**:
   ```bash
   bash -x ./install.sh --user
   ```

2. **Check disk space**:
   ```bash
   df -h ~/.local
   df -h /usr/local
   ```

3. **Manual installation fallback**:
   ```bash
   # Create directories
   mkdir -p ~/.local/bin ~/.local/share/claude-code-enhancer
   
   # Copy scripts manually
   cp install-claude-flow.sh ~/.local/bin/claude-install-flow
   cp smart-merge-claude.sh ~/.local/bin/claude-merge
   chmod +x ~/.local/bin/claude*
   
   # Copy templates
   cp -r templates ~/.local/share/claude-code-enhancer/
   ```

## Template Problems

### Templates Not Found

**Problem**: "Templates directory not found" error

**Solutions**:

1. **Check template locations** (in order of precedence):
   ```bash
   # Custom template directory
   echo $CLAUDE_TEMPLATES_DIR
   ls -la "$CLAUDE_TEMPLATES_DIR" 2>/dev/null
   
   # User installation
   ls -la ~/.local/share/claude-code-enhancer/templates 2>/dev/null
   
   # System installation
   ls -la /usr/local/share/claude-code-enhancer/templates 2>/dev/null
   
   # Local development
   ls -la ./templates 2>/dev/null
   ```

2. **Reinstall templates**:
   ```bash
   ./install.sh --user
   # Or for system-wide
   sudo ./install.sh --system
   ```

3. **Set custom template directory**:
   ```bash
   export CLAUDE_TEMPLATES_DIR="/path/to/your/templates"
   claude-install-flow
   ```

### Template Selection Issues

**Problem**: Wrong template selected or template selection fails

**Solutions**:

1. **Reset and retry selection**:
   ```bash
   # Remove any partial installation
   rm -f CLAUDE.md
   rm -rf .claude/
   
   # Start fresh
   claude-install-flow
   ```

2. **Manual template selection**:
   ```bash
   # Copy specific template manually
   cp ~/.local/share/claude-code-enhancer/templates/languages/javascript/CLAUDE.md .
   cp -r ~/.local/share/claude-code-enhancer/templates/commands .claude/
   ```

3. **Debug template detection**:
   ```bash
   # Run with debug output
   CLAUDE_DEBUG=1 claude-install-flow
   ```

### Template Merge Conflicts

**Problem**: Smart merge fails or produces conflicts

**Solutions**:

1. **Backup and manual resolution**:
   ```bash
   # Create backup
   cp CLAUDE.md CLAUDE.md.backup
   
   # Try smart merge
   claude-merge
   
   # If conflicts, manually edit CLAUDE.md
   # Restore backup if needed: cp CLAUDE.md.backup CLAUDE.md
   ```

2. **Force clean installation**:
   ```bash
   # Move existing file
   mv CLAUDE.md CLAUDE.md.old
   
   # Fresh installation
   claude-install-flow
   
   # Manually merge old content
   ```

## Command Execution Issues

### Quality Commands Failing

**Problem**: `claude format`, `claude verify`, etc. not working

**Solutions**:

1. **Check command installation**:
   ```bash
   # Verify command templates exist
   ls -la .claude/commands/quality/
   ls -la .claude/commands/git/
   ls -la .claude/commands/test/
   ```

2. **Reinstall command templates**:
   ```bash
   # Remove existing commands
   rm -rf .claude/commands/
   
   # Reinstall templates
   claude-install-flow
   ```

3. **Check tool dependencies**:
   ```bash
   # JavaScript/TypeScript
   which prettier eslint tsc
   npm list -g prettier eslint typescript
   
   # Python
   which black flake8 mypy pytest
   pip list | grep -E "(black|flake8|mypy|pytest)"
   
   # Go
   which gofmt goimports
   go version
   ```

### Command Not Recognized

**Problem**: Specific claude commands not found (e.g., `claude format` not found)

**Solutions**:

1. **Check if using Claude Code CLI vs. templates**:
   ```bash
   # These are template-based commands that work within Claude Code
   # They require .claude/commands/ directory structure
   ls .claude/commands/quality/format.md
   ls .claude/commands/git/commit.md
   ```

2. **Verify project setup**:
   ```bash
   # Must be in a project with Claude Code Enhancer templates
   ls CLAUDE.md .claude/commands/
   ```

3. **Template command usage**:
   ```bash
   # Commands are meant to be referenced in Claude Code conversations
   # Not as standalone CLI commands
   # Use: "claude format" in your Claude Code conversation
   # Not: Direct execution from terminal
   ```

## Quality System Problems

### Formatting Issues

**Problem**: Code formatting fails or produces unexpected results

**Solutions**:

1. **Check formatter installation**:
   ```bash
   # JavaScript/TypeScript
   npm list prettier eslint
   
   # Python
   pip show black isort
   
   # Go
   which gofmt goimports
   ```

2. **Verify configuration files**:
   ```bash
   # Check for existing configurations that might conflict
   ls .prettierrc .eslintrc* pyproject.toml setup.cfg
   ```

3. **Test formatting manually**:
   ```bash
   # Test formatters directly
   prettier --version
   prettier --check src/
   
   black --version
   black --check --diff .
   ```

### Verification Failures

**Problem**: `claude verify` reports issues or fails to run

**Solutions**:

1. **Run in debug mode**:
   ```bash
   CLAUDE_DEBUG=1 claude verify
   ```

2. **Check specific verification tools**:
   ```bash
   # Syntax checking
   node -c script.js  # JavaScript
   python -m py_compile script.py  # Python
   go build -o /dev/null .  # Go
   
   # Linting
   eslint src/
   flake8 .
   golangci-lint run
   ```

3. **Incremental verification**:
   ```bash
   # Verify specific files only
   claude verify --files="src/specific-file.js"
   
   # Skip problematic checks
   claude verify --skip-security --skip-style
   ```

### Cleanup Issues

**Problem**: Code cleanup removes too much or too little

**Solutions**:

1. **Use conservative mode**:
   ```bash
   claude cleanup --conservative --dry-run
   ```

2. **Backup before cleanup**:
   ```bash
   # Automatic backup (default)
   claude cleanup  # Creates .claude-backup/
   
   # Manual backup
   git add -A && git commit -m "Before cleanup"
   claude cleanup
   ```

3. **Selective cleanup**:
   ```bash
   # Only clean imports
   claude cleanup --imports-only
   
   # Only remove dead code
   claude cleanup --dead-code-only
   
   # Exclude specific patterns
   claude cleanup --exclude="*.generated.js,*_pb.py"
   ```

## Git Integration Issues

### Commit Command Problems

**Problem**: `claude commit` fails or doesn't include quality checks

**Solutions**:

1. **Check git status**:
   ```bash
   git status
   git config --list | grep user
   ```

2. **Verify quality integration**:
   ```bash
   # Test quality commands first
   claude format --dry-run
   claude verify --quick
   ```

3. **Manual commit workflow**:
   ```bash
   # If automated commit fails
   claude format && claude verify
   git add -A
   git commit -m "Your commit message"
   ```

### Pull Request Creation Issues

**Problem**: `claude pr` fails to create pull request

**Solutions**:

1. **Check git remote configuration**:
   ```bash
   git remote -v
   git branch -a
   ```

2. **Verify GitHub CLI (if using GitHub)**:
   ```bash
   gh --version
   gh auth status
   gh repo view
   ```

3. **Manual PR creation**:
   ```bash
   # Push branch first
   git push -u origin feature-branch
   
   # Create PR manually via web interface
   # Or use gh CLI directly
   gh pr create --title "Title" --body "Description"
   ```

## Performance Problems

### Slow Command Execution

**Problem**: Commands take too long to execute

**Solutions**:

1. **Enable parallel processing**:
   ```bash
   export CLAUDE_MAX_PARALLEL=4
   export CLAUDE_CACHE_ENABLED=true
   ```

2. **Use incremental operations**:
   ```bash
   # Only process changed files
   claude format --incremental
   claude verify --changed-files-only
   ```

3. **Exclude large directories**:
   ```bash
   # Add to .claude-ignore or .gitignore
   echo "node_modules/" >> .claude-ignore
   echo "target/" >> .claude-ignore
   echo "__pycache__/" >> .claude-ignore
   ```

### Memory Issues

**Problem**: Commands fail with out-of-memory errors

**Solutions**:

1. **Process in batches**:
   ```bash
   export CLAUDE_BATCH_SIZE=50
   export CLAUDE_MEMORY_LIMIT=1GB
   ```

2. **Use streaming mode**:
   ```bash
   export CLAUDE_STREAMING_MODE=true
   claude verify --streaming
   ```

3. **Exclude large files**:
   ```bash
   # Set file size limits
   export CLAUDE_MAX_FILE_SIZE=10MB
   claude verify --exclude-large-files
   ```

## Configuration Issues

### Environment Variables Not Working

**Problem**: Claude environment variables not taking effect

**Solutions**:

1. **Check variable export**:
   ```bash
   # Ensure variables are exported
   export CLAUDE_DEBUG=1
   export CLAUDE_TEMPLATES_DIR="/custom/path"
   
   # Verify they're set
   env | grep CLAUDE
   ```

2. **Add to shell profile**:
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   echo 'export CLAUDE_DEBUG=1' >> ~/.bashrc
   source ~/.bashrc
   ```

### Configuration File Issues

**Problem**: `.claude-config.json` not working correctly

**Solutions**:

1. **Validate JSON syntax**:
   ```bash
   # Check for syntax errors
   python -m json.tool .claude-config.json
   # Or
   jq . .claude-config.json
   ```

2. **Check configuration hierarchy**:
   ```bash
   # Configuration is loaded in this order:
   # 1. .claude-config.json (project)
   # 2. ~/.claude-config.json (user)
   # 3. Environment variables
   # 4. Defaults
   ```

3. **Reset configuration**:
   ```bash
   # Backup and reset
   mv .claude-config.json .claude-config.json.backup
   # Regenerate with defaults
   claude-install-flow --reset-config
   ```

## Multi-Agent Coordination Problems

### Agent Spawning Issues

**Problem**: Multi-agent coordination not working or agents not spawning

**Solutions**:

1. **Check system resources**:
   ```bash
   # Monitor system resources
   top
   free -h
   ps aux | grep claude
   ```

2. **Reduce agent count**:
   ```bash
   export CLAUDE_MAX_AGENTS=2
   export CLAUDE_AGENT_TIMEOUT=300
   ```

3. **Sequential fallback**:
   ```bash
   # Disable multi-agent mode
   export CLAUDE_SINGLE_AGENT_MODE=true
   claude verify --no-parallel
   ```

### Agent Communication Problems

**Problem**: Agents not coordinating properly or producing conflicts

**Solutions**:

1. **Enable agent debugging**:
   ```bash
   export CLAUDE_AGENT_DEBUG=1
   export CLAUDE_AGENT_LOG_LEVEL=verbose
   ```

2. **Use coordination locks**:
   ```bash
   # Ensure proper locking
   export CLAUDE_COORDINATION_LOCKS=true
   rm -f .claude-lock*  # Clear stale locks
   ```

3. **Restart coordination**:
   ```bash
   # Kill any running agents
   pkill -f claude-agent
   
   # Clear coordination state
   rm -rf .claude-coordination/
   ```

## Advanced Debugging

### Enable Debug Mode

```bash
# Global debug mode
export CLAUDE_DEBUG=1
export CLAUDE_VERBOSE=1

# Component-specific debugging
export CLAUDE_QUALITY_DEBUG=1
export CLAUDE_GIT_DEBUG=1
export CLAUDE_TEMPLATE_DEBUG=1
export CLAUDE_AGENT_DEBUG=1
```

### Logging and Tracing

```bash
# Enable comprehensive logging
export CLAUDE_LOG_FILE="claude-debug.log"
export CLAUDE_LOG_LEVEL="trace"

# Trace execution
export CLAUDE_TRACE=1
claude verify --trace-execution
```

### System Information Collection

```bash
# Collect diagnostic information
cat > claude-diagnostics.sh << 'EOF'
#!/bin/bash
echo "=== Claude Code Enhancer Diagnostics ==="
echo "Date: $(date)"
echo "System: $(uname -a)"
echo "Shell: $SHELL"
echo "PATH: $PATH"
echo ""

echo "=== Claude Installation ==="
which claude-install-flow claude-merge
ls -la ~/.local/bin/claude* 2>/dev/null
ls -la /usr/local/bin/claude* 2>/dev/null
echo ""

echo "=== Templates ==="
echo "CLAUDE_TEMPLATES_DIR: $CLAUDE_TEMPLATES_DIR"
ls -la ~/.local/share/claude-code-enhancer/templates 2>/dev/null
echo ""

echo "=== Project State ==="
pwd
ls -la CLAUDE.md .claude/ 2>/dev/null
echo ""

echo "=== Tool Dependencies ==="
which git node npm python pip go
git --version 2>/dev/null
node --version 2>/dev/null
python --version 2>/dev/null
go version 2>/dev/null
echo ""

echo "=== Environment Variables ==="
env | grep CLAUDE
EOF

chmod +x claude-diagnostics.sh
./claude-diagnostics.sh
```

## Recovery Procedures

### Complete Reset

```bash
# 1. Backup current state
mkdir claude-backup
cp -r CLAUDE.md .claude/ claude-backup/ 2>/dev/null

# 2. Clean installation
rm -f CLAUDE.md
rm -rf .claude/

# 3. Uninstall and reinstall
./install.sh --uninstall
./install.sh --user

# 4. Fresh template installation
claude-install-flow

# 5. Restore custom configurations if needed
# Review claude-backup/ and selectively restore
```

### Emergency Rollback

```bash
# If claude commands break your project
# 1. Check for automatic backups
ls -la .claude-backup*/

# 2. Restore from backup
cp .claude-backup/latest/* .

# 3. Or restore from git
git status
git checkout -- .
git clean -fd

# 4. Or restore from specific commit
git log --oneline
git reset --hard <commit-hash>
```

### Minimal Working Setup

```bash
# Create minimal working configuration
cat > CLAUDE.md << 'EOF'
# Development Partnership

## Project Configuration
- Language: [Your language]
- Framework: [Your framework]

## Quality Standards
- Format code before committing
- Verify quality with tests
- Follow language conventions

## Workflow
1. Format code: claude format
2. Verify quality: claude verify
3. Run tests: claude test unit
4. Commit: claude commit "message"
EOF

# Create minimal command structure
mkdir -p .claude/commands/quality
cat > .claude/commands/quality/format.md << 'EOF'
# Format Command

Format code using appropriate tools for the project language.

## Usage
Run formatting tools and organize imports.
EOF
```

## Getting Help

### Support Resources

1. **Documentation**: Review the complete documentation in `/docs`
2. **Examples**: Check `/docs/examples` for working examples
3. **Community**: Join discussions on GitHub
4. **Issues**: Report bugs and request features on GitHub Issues

### Diagnostic Information to Include

When seeking help, include:

1. **System Information**:
   ```bash
   ./claude-diagnostics.sh > diagnostics.txt
   ```

2. **Error Messages**: Copy the complete error output
3. **Steps to Reproduce**: Exact commands that cause the issue
4. **Project Context**: Language, framework, project size
5. **Configuration**: Contents of `.claude-config.json` (remove sensitive data)

### Common Support Scenarios

**"Nothing works after installation"**:
- Run diagnostics script
- Check PATH configuration
- Verify template installation

**"Commands fail randomly"**:
- Enable debug mode
- Check system resources
- Review log files

**"Quality tools produce wrong results"**:
- Test tools individually
- Check configuration files
- Verify tool versions

---

This troubleshooting guide covers the most common issues with Claude Code Enhancer. For issues not covered here, please refer to the [GitHub Issues](https://github.com/your-org/claude-code-enhancer/issues) page or create a new issue with diagnostic information.