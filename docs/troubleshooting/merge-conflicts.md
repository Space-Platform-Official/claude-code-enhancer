# Merge Conflicts - Claude Flow Troubleshooting

This guide helps resolve merge conflicts when using Claude Flow's smart merge functionality.

## Table of Contents

1. [Understanding Claude Flow Merging](#understanding-claude-flow-merging)
2. [Common Merge Scenarios](#common-merge-scenarios)
3. [Handling Merge Conflicts](#handling-merge-conflicts)
4. [Manual Merge Strategies](#manual-merge-strategies)
5. [Preventing Merge Issues](#preventing-merge-issues)
6. [Advanced Merge Techniques](#advanced-merge-techniques)

## Understanding Claude Flow Merging

### How Smart Merge Works

Claude Flow's smart merge process:

1. **Detection**: Identifies existing CLAUDE.md and command files
2. **Comparison**: Compares template files with existing files
3. **Decision**: Prompts user for conflict resolution
4. **Action**: Applies chosen merge strategy

### Merge Options Explained

When conflicts are detected, you'll see:
```
[WARNING] Conflict detected for: ./CLAUDE.md
Options:
  [k] Keep existing file
  [o] Overwrite with new file
  [m] Merge manually later (create .new file)
  [s] Skip this file
Choose option [k/o/m/s]:
```

**Option Details:**
- **[k] Keep**: Preserves your existing file unchanged
- **[o] Overwrite**: Replaces with template version (loses customizations)
- **[m] Manual**: Creates `.new` file for later manual merge
- **[s] Skip**: Ignores this file completely

## Common Merge Scenarios

### Scenario 1: Fresh Project with Template

**Situation**: New project, no existing Claude configuration

**Recommended Action**: Choose `[o]` overwrite for all files

```bash
# Clean installation
claude-merge /path/to/new/project
# Choose [o] for all prompts
```

### Scenario 2: Existing Project with Customizations

**Situation**: Project has customized CLAUDE.md

**Recommended Action**: Choose `[m]` for manual merge

```bash
# Preserve customizations
claude-merge
# Choose [m] for CLAUDE.md
# Choose [o] for new command files
```

### Scenario 3: Updating Templates

**Situation**: Updating to newer template versions

**Recommended Action**: Mixed strategy

```bash
# Update process
claude-merge
# [m] for CLAUDE.md (manual merge)
# [k] for customized commands
# [o] for new commands
```

### Scenario 4: Multiple Team Members

**Situation**: Different team members have different configurations

**Recommended Action**: Create team-specific merge

```bash
# Create combined configuration
claude-merge
# [m] for all conflicts
# Manually merge all .new files
# Commit agreed-upon version
```

## Handling Merge Conflicts

### Finding Conflict Files

```bash
# Find all .new files created during merge
find . -name "*.new" -type f

# List with details
find . -name "*.new" -type f -exec ls -la {} \;

# Count conflict files
find . -name "*.new" -type f | wc -l
```

### Comparing Files

```bash
# Visual diff
diff -u CLAUDE.md CLAUDE.md.new

# Side-by-side comparison
diff -y CLAUDE.md CLAUDE.md.new

# Using git diff for better visualization
git diff --no-index CLAUDE.md CLAUDE.md.new

# Three-way diff if you have the original
diff3 CLAUDE.md.original CLAUDE.md CLAUDE.md.new
```

### Quick Resolution Scripts

**Script 1: Show all differences**
```bash
#!/bin/bash
# save as show-conflicts.sh

for newfile in $(find . -name "*.new" -type f); do
    original="${newfile%.new}"
    echo "=== Conflict: $original ==="
    echo "Commands to resolve:"
    echo "  View diff:    diff -u '$original' '$newfile'"
    echo "  Replace:      mv '$newfile' '$original'"
    echo "  Keep current: rm '$newfile'"
    echo
done
```

**Script 2: Interactive resolver**
```bash
#!/bin/bash
# save as resolve-conflicts.sh

for newfile in $(find . -name "*.new" -type f); do
    original="${newfile%.new}"
    echo "=== Resolving: $original ==="
    
    # Show diff summary
    echo "Changes preview:"
    diff -u "$original" "$newfile" | head -20
    echo "..."
    
    echo "Options:"
    echo "  [v] View full diff"
    echo "  [e] Edit merged file"
    echo "  [r] Replace with new"
    echo "  [k] Keep current"
    echo "  [s] Skip"
    
    read -p "Choice: " choice
    
    case "$choice" in
        v) diff -u "$original" "$newfile" | less ;;
        e) ${EDITOR:-vim} "$original" "$newfile" ;;
        r) mv "$newfile" "$original" && echo "Replaced with new version" ;;
        k) rm "$newfile" && echo "Kept current version" ;;
        s) echo "Skipped" ;;
        *) echo "Invalid choice" ;;
    esac
    echo
done
```

## Manual Merge Strategies

### Strategy 1: Section-Based Merge

For CLAUDE.md files with distinct sections:

```bash
# Extract sections from both files
cat << 'EOF' > merge-sections.sh
#!/bin/bash

original="CLAUDE.md"
new="CLAUDE.md.new"
output="CLAUDE.md.merged"

# Start with header from new file
head -n 10 "$new" > "$output"

# Add existing project-specific configuration
echo "## Existing Project Configuration" >> "$output"
sed -n '/^## Project/,/^## Template/p' "$original" >> "$output"

# Add new template configuration
echo "## Updated Template Configuration" >> "$output"
sed -n '/^## Template/,$p' "$new" >> "$output"

echo "Merged file created: $output"
echo "Review and rename to CLAUDE.md when satisfied"
EOF

chmod +x merge-sections.sh
./merge-sections.sh
```

### Strategy 2: Cherry-Pick Merge

Select specific changes from new file:

```bash
# Create a patch of changes
diff -u CLAUDE.md CLAUDE.md.new > changes.patch

# Apply selected hunks interactively
patch -p0 --dry-run < changes.patch  # Test first
patch -p0 -i < changes.patch          # Interactive apply
```

### Strategy 3: Three-Way Merge

If you have the original template:

```bash
# Download original template
curl -o CLAUDE.md.orig https://raw.githubusercontent.com/your-org/claude-flow/main/templates/CLAUDE.md

# Three-way merge
merge CLAUDE.md CLAUDE.md.orig CLAUDE.md.new

# Or use git's merge tool
git merge-file CLAUDE.md CLAUDE.md.orig CLAUDE.md.new
```

## Preventing Merge Issues

### Best Practices

1. **Backup Before Merge**
```bash
# Always backup before merging
cp CLAUDE.md CLAUDE.md.backup-$(date +%Y%m%d)
cp -r .claude .claude.backup-$(date +%Y%m%d)
```

2. **Use Version Control**
```bash
# Commit before merge
git add CLAUDE.md .claude/
git commit -m "Pre-merge backup"

# Merge
claude-merge

# Review changes
git diff

# Commit or revert
git add .
git commit -m "Applied Claude Flow template updates"
# OR
git checkout -- .  # Revert all changes
```

3. **Document Customizations**
```markdown
<!-- CLAUDE.md -->
# Project Configuration

<!-- CUSTOM SECTION START - DO NOT MODIFY -->
## Project-Specific Rules
- Custom rule 1
- Custom rule 2
<!-- CUSTOM SECTION END -->

## Standard Template Content
...
```

### Merge Configuration File

Create `.claude-merge.conf`:
```bash
# Merge preferences
MERGE_STRATEGY="manual"  # auto, manual, skip
BACKUP_BEFORE_MERGE=true
CREATE_MERGE_REPORT=true
PRESERVE_CUSTOM_SECTIONS=true

# Files to always skip
SKIP_FILES=(
    "CLAUDE.md"  # Always handle manually
    ".claude/commands/custom-*.md"  # Skip custom commands
)

# Files to always overwrite
OVERWRITE_FILES=(
    ".claude/commands/standard-*.md"  # Update standard commands
)
```

## Advanced Merge Techniques

### Custom Merge Driver

```bash
# Create custom merge script
cat << 'EOF' > claude-custom-merge.sh
#!/bin/bash

# Custom merge logic for CLAUDE.md files
base_file="$1"
current_file="$2"
other_file="$3"
conflict_marker_size="$4"

# Extract custom sections from current
custom_sections=$(sed -n '/<!-- CUSTOM START -->/,/<!-- CUSTOM END -->/p' "$current_file")

# Use other file as base
cp "$other_file" "$current_file.tmp"

# Re-insert custom sections
# ... (implement your logic here)

# Move result into place
mv "$current_file.tmp" "$current_file"

# Return 0 for successful merge, 1 for conflicts
exit 0
EOF

chmod +x claude-custom-merge.sh
```

### Automated Merge Testing

```bash
# Test merge outcomes
cat << 'EOF' > test-merge.sh
#!/bin/bash

# Create test directory
test_dir="/tmp/claude-merge-test-$$"
mkdir -p "$test_dir"

# Copy current state
cp -r . "$test_dir/"

# Perform test merge
cd "$test_dir"
claude-merge --auto  # If supported

# Check results
echo "=== Merge Test Results ==="
find . -name "*.new" -type f | while read f; do
    echo "Conflict: $f"
done

echo "Review test results in: $test_dir"
EOF

chmod +x test-merge.sh
./test-merge.sh
```

### Merge Verification

```bash
# Verify merge completeness
cat << 'EOF' > verify-merge.sh
#!/bin/bash

echo "=== Merge Verification ==="

# Check for unresolved conflicts
conflicts=$(find . -name "*.new" -type f | wc -l)
if [ $conflicts -gt 0 ]; then
    echo "⚠ WARNING: $conflicts unresolved conflicts found"
    find . -name "*.new" -type f
else
    echo "✓ No unresolved conflicts"
fi

# Check for backup files
backups=$(find . -name "*.backup*" -type f | wc -l)
if [ $backups -gt 0 ]; then
    echo "ℹ INFO: $backups backup files found"
fi

# Verify required files exist
required_files=(
    "CLAUDE.md"
    ".claude/commands/architect.md"
    ".claude/commands/debug.md"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ Found: $file"
    else
        echo "✗ Missing: $file"
    fi
done

# Check file integrity
if [ -f "CLAUDE.md" ]; then
    lines=$(wc -l < CLAUDE.md)
    if [ $lines -lt 10 ]; then
        echo "⚠ WARNING: CLAUDE.md seems too short ($lines lines)"
    fi
fi
EOF

chmod +x verify-merge.sh
./verify-merge.sh
```

## Recovery from Failed Merges

### Rollback Procedures

```bash
# Option 1: Git rollback
git status  # Check what changed
git checkout -- CLAUDE.md  # Revert specific file
git clean -fd  # Remove untracked files

# Option 2: Backup restoration
cp CLAUDE.md.backup-20241107 CLAUDE.md
cp -r .claude.backup-20241107 .claude

# Option 3: Clean slate
rm -rf .claude CLAUDE.md
claude-install-flow  # Start fresh
```

### Merge Conflict Checklist

- [ ] All .new files resolved
- [ ] No syntax errors in merged files
- [ ] Custom configurations preserved
- [ ] New features incorporated
- [ ] Team agreements reflected
- [ ] Version control updated
- [ ] Documentation updated

## Getting Help

If merge issues persist:

1. Create merge report:
```bash
find . -name "*.new" -type f > merge-conflicts.txt
diff -u CLAUDE.md CLAUDE.md.new >> merge-conflicts.txt
```

2. Share with team or support:
   - List of conflict files
   - Diff outputs
   - Merge decisions needed
   - Custom requirements