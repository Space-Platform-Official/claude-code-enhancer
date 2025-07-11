# Smart Merge Guide

The `claude-merge` tool intelligently merges Claude Flow templates with your existing project configurations, preserving customizations while adding new capabilities.

## What is Smart Merge?

Smart Merge is a sophisticated merging system that:
- Preserves your existing CLAUDE.md customizations
- Adds new template content without duplication
- Updates command libraries
- Handles conflicts gracefully
- Maintains project-specific configurations

## How It Works

### Merge Process

1. **Source Detection**
   - Checks current directory for CLAUDE.md
   - Falls back to template CLAUDE.md
   - Identifies target directory

2. **Content Analysis**
   - Parses existing configurations
   - Identifies custom sections
   - Detects template markers

3. **Intelligent Merging**
   - Preserves custom content at the top
   - Appends template content below
   - Avoids duplicate sections
   - Creates clear separation

4. **Command Updates**
   - Copies new commands to `.claude/commands/`
   - Preserves existing custom commands
   - Updates command library

## Using claude-merge

### Basic Usage

Merge in current directory:
```bash
claude-merge
```

Merge in specific directory:
```bash
claude-merge /path/to/project
```

### Common Scenarios

#### Updating Existing Project

```bash
cd my-project
claude-merge

# Output:
# [INFO] Starting smart merge process...
# [INFO] Using template from: /usr/local/share/claude-flow/templates
# [INFO] Target directory: /home/user/my-project
# [SUCCESS] Merged CLAUDE.md successfully
# [SUCCESS] Commands copied to .claude/commands/
```

#### First-Time Setup

If no CLAUDE.md exists:
```bash
claude-merge

# Creates new CLAUDE.md from template
# Sets up .claude/commands/ directory
```

#### Preserving Customizations

Your custom content is always preserved:

**Before merge** (existing CLAUDE.md):
```markdown
# My Project Rules

## Custom Guidelines
- Always use TypeScript
- Follow our style guide
- Test everything
```

**After merge**:
```markdown
# My Project Rules

## Custom Guidelines
- Always use TypeScript
- Follow our style guide
- Test everything

# ==========================================
# Claude Flow Standard Configuration
# ==========================================

# Development Partnership
[Template content follows...]
```

## Merge Strategies

### 1. Append Strategy (Default)

The default strategy that:
- Keeps all existing content
- Adds separator line
- Appends template content
- Safe for all projects

### 2. Smart Section Merge

When sections exist in both files:
- Preserves custom sections
- Merges complementary content
- Avoids duplication
- Maintains structure

### 3. Command Directory Merge

For `.claude/commands/`:
- Adds new commands
- Updates existing commands
- Preserves custom commands
- No destructive changes

## Advanced Features

### Template Source Priority

Claude-merge searches for templates in order:

1. `$CLAUDE_TEMPLATES_DIR` (if set)
2. `~/.local/share/claude-flow/templates`
3. `/usr/local/share/claude-flow/templates`
4. Local `templates/` directory

```bash
# Use custom templates
export CLAUDE_TEMPLATES_DIR=/my/custom/templates
claude-merge
```

### Selective Merging

Control what gets merged:

```bash
# Check what would be merged (dry run)
claude-merge --dry-run

# Merge only CLAUDE.md (skip commands)
claude-merge --config-only

# Merge only commands (skip CLAUDE.md)
claude-merge --commands-only
```

### Backup and Recovery

Automatic backups are created:
- `CLAUDE.md.backup` before changes
- Timestamped backups for safety

```bash
# Restore from backup
cp CLAUDE.md.backup CLAUDE.md
```

## Conflict Resolution

### Identifying Conflicts

Look for these markers:
```markdown
# <<<<<<< MANUAL MERGE NEEDED >>>>>>>
# Existing content:
[your content]
# Template content:
[template content]
# <<<<<<< END MANUAL MERGE >>>>>>>
```

### Resolving Conflicts

1. **Review both versions**
2. **Keep relevant content**
3. **Remove conflict markers**
4. **Test with Claude Code**

### Merge Examples

#### Example 1: Clean Merge

```bash
$ claude-merge
[INFO] Starting smart merge process...
[INFO] No existing CLAUDE.md found in target
[INFO] Creating new CLAUDE.md from template
[SUCCESS] CLAUDE.md created successfully
[SUCCESS] Commands directory created
```

#### Example 2: Update Merge

```bash
$ claude-merge
[INFO] Starting smart merge process...
[INFO] Found existing CLAUDE.md in target
[INFO] Creating backup: CLAUDE.md.backup
[INFO] Merging configurations...
[SUCCESS] Merged CLAUDE.md (added 127 lines)
[SUCCESS] Updated 5 commands, added 3 new commands
```

#### Example 3: Complex Merge

```bash
$ claude-merge
[INFO] Starting smart merge process...
[WARNING] Found customized sections
[INFO] Preserving custom content
[INFO] Merging template additions
[SUCCESS] Complex merge completed
[INFO] Review CLAUDE.md for any needed adjustments
```

## Best Practices

### 1. Regular Updates

```bash
# Monthly update routine
cd my-project
git add -A && git commit -m "Pre-merge checkpoint"
claude-merge
git diff CLAUDE.md  # Review changes
git add -A && git commit -m "Update Claude Flow templates"
```

### 2. Team Synchronization

```bash
# After team member updates templates
git pull
claude-merge
# Resolves any template differences
```

### 3. Custom Command Preservation

```bash
# Before merge, backup custom commands
cp -r .claude/commands .claude/commands.custom

# After merge, restore custom commands
cp .claude/commands.custom/* .claude/commands/
```

### 4. Project-Specific Sections

Structure your CLAUDE.md for clean merges:

```markdown
# Project: My Awesome App
## Project-Specific Rules
[Your content here - always preserved]

## Custom Workflows
[Your workflows - always preserved]

# ==========================================
# Claude Flow Standard Configuration
# ==========================================
[Template content - updated by merge]
```

## Troubleshooting

### Merge Seems to Skip Content

Check for duplicate sections:
```bash
# Search for duplicate headers
grep -n "^#" CLAUDE.md | sort | uniq -d
```

### Commands Not Updated

Verify command directory:
```bash
# Check permissions
ls -la .claude/commands/

# Force command update
rm -rf .claude/commands/
claude-merge
```

### Unexpected Merge Results

```bash
# Compare with backup
diff CLAUDE.md.backup CLAUDE.md

# Restore and try again
cp CLAUDE.md.backup CLAUDE.md
claude-merge --verbose
```

### Template Not Found

```bash
# Debug template search
export CLAUDE_TEMPLATE_DEBUG=1
claude-merge

# Manually specify template
export CLAUDE_TEMPLATES_DIR=/path/to/templates
claude-merge
```

## Integration with Git

### Pre-commit Hook

Add to `.git/hooks/pre-commit`:
```bash
#!/bin/bash
# Ensure CLAUDE.md is up to date
if command -v claude-merge &> /dev/null; then
    claude-merge --check || exit 1
fi
```

### Git Workflow

```bash
# Feature branch workflow
git checkout -b feature/new-capability
claude-merge  # Ensure latest templates
# ... develop feature ...
git add -A && git commit
git checkout main
git merge feature/new-capability
```

## Next Steps

- Learn about [Customization](customization.md) options
- Explore [Workflows](workflows.md) for automation
- Review [Best Practices](best-practices.md)
- Check [Using Templates](using-templates.md) for initial setup