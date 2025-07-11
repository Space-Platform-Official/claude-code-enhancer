# Claude Flow Troubleshooting Documentation

Welcome to the comprehensive troubleshooting guide for Claude Flow. This documentation helps you resolve issues quickly and effectively.

## Quick Navigation

### 🔧 [Common Issues](common-issues.md)
The most frequently encountered problems and their solutions:
- Script execution errors
- File permission issues  
- Shell environment problems
- Template not found errors
- Command not found issues
- NPM installation problems

### 📦 [Installation Problems](installation-problems.md)
Everything related to installing Claude Flow:
- Pre-installation checks
- Installation methods (user vs system)
- Platform-specific issues (macOS, Linux, Windows/WSL)
- Post-installation verification
- Rollback and recovery procedures

### 📄 [Template Issues](template-issues.md)
Problems with Claude Flow templates:
- Template location issues
- Missing templates
- Template selection problems
- Template customization
- Language and framework templates
- Command template troubleshooting

### 🔀 [Merge Conflicts](merge-conflicts.md)
Handling merge conflicts and file integration:
- Understanding smart merge
- Common merge scenarios
- Conflict resolution strategies
- Manual merge techniques
- Preventing merge issues
- Advanced merge tools

### ❓ [Frequently Asked Questions](faq.md)
Quick answers to common questions:
- General questions about Claude Flow
- Installation questions
- Usage questions
- Template questions
- Advanced configuration
- Contributing and support

### 🐛 [Debugging Guide](debugging.md)
Advanced debugging techniques:
- Debug mode and logging
- Diagnostic scripts
- System analysis tools
- Script debugging techniques
- Network and permission debugging
- Creating debug reports

## Quick Troubleshooting Steps

### 1. Installation Not Working?

```bash
# Quick diagnostic
bash -x ./install.sh --user 2>&1 | tee install-debug.log

# Check for common issues
./install.sh --help
```

See [Installation Problems](installation-problems.md) for detailed solutions.

### 2. Commands Not Found?

```bash
# Check PATH
echo $PATH | grep -q "$HOME/.local/bin" || echo "PATH issue detected"

# Quick fix
export PATH="$HOME/.local/bin:$PATH"
source ~/.bashrc
```

See [Common Issues](common-issues.md#command-not-found) for more solutions.

### 3. Templates Missing?

```bash
# Check template locations
ls ~/.local/share/claude-flow/templates
ls /usr/local/share/claude-flow/templates

# Set custom location
export CLAUDE_TEMPLATES_DIR="/path/to/templates"
```

See [Template Issues](template-issues.md) for comprehensive template troubleshooting.

### 4. Merge Conflicts?

When you see:
```
[WARNING] Conflict detected for: ./CLAUDE.md
Options: [k/o/m/s]
```

- Choose `[m]` for manual merge (recommended)
- Choose `[k]` to keep existing
- See [Merge Conflicts](merge-conflicts.md) for detailed strategies

## Emergency Recovery

If Claude Flow is completely broken:

```bash
# 1. Complete uninstall
./install.sh --uninstall

# 2. Clean up remnants
rm -rf ~/.local/share/claude-flow
rm -f ~/.local/bin/claude-*

# 3. Fresh install
git pull origin main
./install.sh --user

# 4. Verify
claude-install-flow --help
```

## Diagnostic Tools

### Quick System Check

```bash
# Download and run diagnostic script
curl -O https://raw.githubusercontent.com/your-org/claude-flow/main/tools/diagnose.sh
bash diagnose.sh
```

### Generate Debug Report

```bash
# Create comprehensive debug report
cat << 'EOF' > debug-report.sh
#!/bin/bash
{
    echo "=== System Info ==="
    uname -a
    echo "=== Claude Flow Info ==="
    which claude-install-flow
    ls -la ~/.local/share/claude-flow/
    echo "=== Environment ==="
    env | grep CLAUDE
} > claude-debug-$(date +%Y%m%d).txt
EOF
bash debug-report.sh
```

## Getting Help

### Before Asking for Help

1. **Check existing documentation** - Your answer might already be here
2. **Search GitHub issues** - Someone might have had the same problem
3. **Try debugging steps** - Use the [Debugging Guide](debugging.md)
4. **Collect information** - Run diagnostic scripts

### When Asking for Help

Include:
- **System information**: `uname -a`
- **Error messages**: Complete error output
- **Steps to reproduce**: Exact commands you ran
- **What you've tried**: Solutions attempted
- **Debug report**: Output from diagnostic scripts

### Support Channels

1. **GitHub Issues**: For bugs and feature requests
2. **Discussions**: For general questions and help
3. **Documentation**: Always check here first
4. **Community**: Join our Discord/Slack for real-time help

## Contributing to Documentation

Found an issue or have a solution? Help improve these docs:

1. Fork the repository
2. Add your troubleshooting solution
3. Submit a pull request

Your contributions help everyone in the Claude Flow community!

---

Remember: Most issues have simple solutions. Start with the [Common Issues](common-issues.md) guide, and work your way through more specific guides as needed. When in doubt, the [Debugging Guide](debugging.md) provides comprehensive tools for diagnosing any problem.