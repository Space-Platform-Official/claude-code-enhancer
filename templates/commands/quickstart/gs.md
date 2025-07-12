---
allowed-tools: all
description: Quick git status with intelligent insights and workflow recommendations
---

# Quick Git Status (gs)

Fast access to enhanced git status with actionable insights and comprehensive repository intelligence.

**Usage:** `/quickstart/gs $ARGUMENTS`

## Quick Command Reference

This is a convenient alias to the full git status command:
```
/quickstart/gs  →  /git/status
```

## What You Get

🚀 **Instant Repository Intelligence:**
- Rich working tree status with context
- Branch relationships and sync status
- Commit history and patterns analysis
- File change insights and warnings
- Smart workflow recommendations
- Quick action menu for common tasks

## Arguments Support

All arguments are passed through to the full command:
```bash
/quickstart/gs --help          # Show detailed help
/quickstart/gs --verbose       # Extra detailed output
/quickstart/gs --interactive   # Enable interactive mode
```

## Perfect For

✅ **Daily Development:**
- Quick status checks before commits
- Understanding current branch state
- Getting workflow recommendations
- Checking team activity

✅ **Team Collaboration:**
- Sync status with remote branches
- Review recent team commits
- Check CI/CD integration status
- Monitor repository health

## Example Output

```
📊 Repository Intelligence Report
=================================
📅 Generated: 2024-01-15 14:30:22
🏢 Repository: my-awesome-project
🌿 Branch: feature/user-auth

🗂️  Working Tree Status:
----------------------
✅ Staged Changes (3 files):
  src/auth.js    | 12 ++++++++++--
  tests/auth.js  |  8 ++++++++
  README.md      |  2 +-

📝 Unstaged Changes (1 file):
  config.json    |  1 +

🌳 Branch Intelligence:
---------------------
📡 Tracking: origin/feature/user-auth
⬆️  Ahead by 2 commits
💡 Recommendation: Ready to push! Use: /quickstart/gp

💡 Recommended Actions:
----------------------
1. ✅ Ready to commit!
   - Commit changes: /quickstart/gc
   - Or amend previous: git commit --amend
```

## Quick Actions Available

The status command includes an interactive menu:
- **1)** Stage all changes
- **2)** Commit with message  
- **3)** Push to remote
- **4)** Pull latest changes
- **5)** Stash changes
- **6)** Create new branch
- **7)** View diff
- **8)** Run tests

## Related Quick Commands

- `/quickstart/gc` - Quick git commit
- `/quickstart/gp` - Quick git push  
- `/quickstart/gf` - Quick git feature workflow

## Full Documentation

For complete details and advanced features, see:
- `/git/status` - Full git status command
- `/git/workflows/` - Complete workflow documentation

---

**Remember:** This gives you instant insight into your repository state and smart next-step recommendations!