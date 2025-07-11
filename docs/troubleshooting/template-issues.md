# Template Issues - Claude Flow Troubleshooting

This guide helps resolve issues related to Claude Flow templates, including missing templates, incorrect paths, and customization problems.

## Table of Contents

1. [Template Location Issues](#template-location-issues)
2. [Missing Templates](#missing-templates)
3. [Template Selection Problems](#template-selection-problems)
4. [Template Customization](#template-customization)
5. [Language and Framework Templates](#language-and-framework-templates)
6. [Command Templates](#command-templates)

## Template Location Issues

### Understanding Template Search Order

Claude Flow searches for templates in this order:

1. `$CLAUDE_TEMPLATE_SOURCE` (legacy environment variable)
2. `$CLAUDE_TEMPLATES_DIR` (preferred environment variable)
3. `~/.local/share/claude-flow/templates` (user installation)
4. `/usr/local/share/claude-flow/templates` (system installation)
5. Local `templates/` directory (development mode)

### Diagnosing Template Location Problems

```bash
# Check which template directory is being used
cat << 'EOF' > check-templates.sh
#!/bin/bash

echo "=== Claude Flow Template Locations ==="
echo

# Check environment variables
echo "Environment Variables:"
echo "  CLAUDE_TEMPLATE_SOURCE: ${CLAUDE_TEMPLATE_SOURCE:-not set}"
echo "  CLAUDE_TEMPLATES_DIR: ${CLAUDE_TEMPLATES_DIR:-not set}"
echo

# Check standard locations
echo "Checking standard locations:"
for dir in ~/.local/share/claude-flow/templates /usr/local/share/claude-flow/templates ./templates; do
    if [ -d "$dir" ]; then
        echo "  ✓ Found: $dir"
        echo "    - Total files: $(find "$dir" -type f | wc -l)"
        echo "    - MD files: $(find "$dir" -name "*.md" | wc -l)"
    else
        echo "  ✗ Not found: $dir"
    fi
done
echo

# Show which would be used
echo "Template directory that would be used:"
source ./install-claude-flow.sh
if source_dir="$(find_templates_dir)"; then
    echo "  $source_dir"
else
    echo "  ERROR: No valid template directory found"
fi
EOF

chmod +x check-templates.sh
./check-templates.sh
```

### Fixing Template Path Issues

**Option 1: Set Custom Template Directory**
```bash
# Temporary (current session only)
export CLAUDE_TEMPLATES_DIR="/path/to/your/templates"

# Permanent (add to shell config)
echo 'export CLAUDE_TEMPLATES_DIR="/path/to/your/templates"' >> ~/.bashrc
source ~/.bashrc
```

**Option 2: Fix Installation Paths**
```bash
# Verify installation created template directory
ls -la ~/.local/share/claude-flow/

# If missing, reinstall
./install.sh --uninstall
./install.sh --user
```

**Option 3: Use Symlinks**
```bash
# Create expected directory structure
mkdir -p ~/.local/share/claude-flow

# Link to actual templates
ln -s /path/to/actual/templates ~/.local/share/claude-flow/templates
```

## Missing Templates

### Verify Template Structure

Expected template directory structure:
```
templates/
├── CLAUDE.md              # Main configuration
├── commands/              # Command templates
│   ├── architect.md
│   ├── debug.md
│   ├── optimize.md
│   └── ...
├── languages/             # Language-specific configs
│   ├── go/
│   ├── javascript/
│   ├── python/
│   └── ...
├── frameworks/            # Framework-specific configs
│   ├── react/
│   ├── nextjs/
│   └── ...
└── workflows/             # Workflow templates
    ├── ci-cd/
    ├── testing/
    └── ...
```

### Check for Missing Templates

```bash
# Create template inventory script
cat << 'EOF' > inventory-templates.sh
#!/bin/bash

TEMPLATE_DIR="${CLAUDE_TEMPLATES_DIR:-$HOME/.local/share/claude-flow/templates}"

echo "Checking templates in: $TEMPLATE_DIR"
echo

# Expected directories
expected_dirs=("commands" "languages" "frameworks" "workflows")

for dir in "${expected_dirs[@]}"; do
    if [ -d "$TEMPLATE_DIR/$dir" ]; then
        count=$(find "$TEMPLATE_DIR/$dir" -name "*.md" | wc -l)
        echo "✓ $dir/ ($count .md files)"
    else
        echo "✗ $dir/ (MISSING)"
    fi
done

echo
echo "Expected command templates:"
expected_commands=("architect.md" "debug.md" "optimize.md" "refactor.md" "review.md" "test-coverage.md")

for cmd in "${expected_commands[@]}"; do
    if [ -f "$TEMPLATE_DIR/commands/$cmd" ]; then
        echo "  ✓ commands/$cmd"
    else
        echo "  ✗ commands/$cmd (MISSING)"
    fi
done
EOF

chmod +x inventory-templates.sh
./inventory-templates.sh
```

### Restore Missing Templates

**Option 1: Re-download from Repository**
```bash
# Clone fresh copy
git clone https://github.com/your-org/claude-flow.git /tmp/claude-flow-fresh

# Copy missing templates
cp -r /tmp/claude-flow-fresh/templates/* ~/.local/share/claude-flow/templates/

# Clean up
rm -rf /tmp/claude-flow-fresh
```

**Option 2: Selective Template Restoration**
```bash
# Download specific missing template
curl -o ~/.local/share/claude-flow/templates/commands/architect.md \
    https://raw.githubusercontent.com/your-org/claude-flow/main/templates/commands/architect.md
```

## Template Selection Problems

### Issue: Wrong Template Selected

When `claude-install-flow` selects the wrong template:

```bash
# Debug template selection
claude-install-flow --debug

# Force specific template
CLAUDE_TEMPLATE_TYPE=python claude-install-flow

# Skip interactive selection
claude-install-flow --template=javascript
```

### Issue: Template Not Available for Language/Framework

```bash
# List available templates
find ~/.local/share/claude-flow/templates -name "CLAUDE.md" -type f | sort

# Create custom template for unsupported language
mkdir -p ~/.local/share/claude-flow/templates/languages/kotlin
cp ~/.local/share/claude-flow/templates/CLAUDE.md \
   ~/.local/share/claude-flow/templates/languages/kotlin/CLAUDE.md
# Edit the file to add Kotlin-specific configuration
```

## Template Customization

### Creating Project-Specific Templates

```bash
# 1. Create local templates directory
mkdir -p ./my-project-templates

# 2. Copy base templates
cp -r ~/.local/share/claude-flow/templates/* ./my-project-templates/

# 3. Customize templates
vim ./my-project-templates/CLAUDE.md

# 4. Use custom templates
export CLAUDE_TEMPLATES_DIR="$(pwd)/my-project-templates"
claude-install-flow
```

### Modifying Global Templates

```bash
# Backup original templates
cp -r ~/.local/share/claude-flow/templates ~/.local/share/claude-flow/templates.backup

# Edit templates
vim ~/.local/share/claude-flow/templates/CLAUDE.md

# Test changes
claude-install-flow /tmp/test-project

# Revert if needed
rm -rf ~/.local/share/claude-flow/templates
mv ~/.local/share/claude-flow/templates.backup ~/.local/share/claude-flow/templates
```

### Template Variables and Placeholders

Common template variables:
- `{{PROJECT_NAME}}` - Project name
- `{{LANGUAGE}}` - Selected programming language
- `{{FRAMEWORK}}` - Selected framework
- `{{DATE}}` - Current date

Example custom template with variables:
```markdown
# {{PROJECT_NAME}} - Claude Configuration

Generated on: {{DATE}}
Language: {{LANGUAGE}}
Framework: {{FRAMEWORK}}

## Project-Specific Guidelines
...
```

## Language and Framework Templates

### Troubleshooting Language Templates

**Issue: Language template not applying**
```bash
# Check if language template exists
ls ~/.local/share/claude-flow/templates/languages/

# Verify template content
cat ~/.local/share/claude-flow/templates/languages/python/CLAUDE.md

# Force language template
claude-install-flow --language=python
```

**Issue: Multiple language templates needed**
```bash
# Create combined template
cat > ~/.local/share/claude-flow/templates/CLAUDE-multi.md << 'EOF'
# Multi-Language Project Configuration

## Python Configuration
$(cat ~/.local/share/claude-flow/templates/languages/python/CLAUDE.md)

## JavaScript Configuration
$(cat ~/.local/share/claude-flow/templates/languages/javascript/CLAUDE.md)
EOF

# Use combined template
cp ~/.local/share/claude-flow/templates/CLAUDE-multi.md ./CLAUDE.md
```

### Framework Template Issues

**Issue: Framework conflicts with language template**
```bash
# Merge framework and language templates
cat ~/.local/share/claude-flow/templates/languages/javascript/CLAUDE.md > CLAUDE-combined.md
echo "" >> CLAUDE-combined.md
cat ~/.local/share/claude-flow/templates/frameworks/react/CLAUDE.md >> CLAUDE-combined.md

# Review and deduplicate
vim CLAUDE-combined.md
```

## Command Templates

### Missing Command Templates

```bash
# List available commands
ls ~/.local/share/claude-flow/templates/commands/

# Create missing command template
cat > ~/.local/share/claude-flow/templates/commands/custom-command.md << 'EOF'
# Custom Command

## Purpose
Describe what this command does

## Usage
```
claude custom-command [options]
```

## Implementation
...
EOF
```

### Command Template Not Working

**Issue: Command not recognized**
```bash
# Verify command was copied
ls .claude/commands/

# Check command content
cat .claude/commands/architect.md

# Ensure proper permissions
chmod -R 755 .claude/
```

**Issue: Command template syntax errors**
```bash
# Validate markdown syntax
# Install markdown linter if needed
npm install -g markdownlint-cli

# Check all command templates
markdownlint .claude/commands/*.md
```

## Advanced Template Debugging

### Template Processing Debug Mode

```bash
# Enable debug logging
export CLAUDE_DEBUG=1
export CLAUDE_VERBOSE=1

# Run with debug output
claude-install-flow 2>&1 | tee template-debug.log

# Analyze debug output
grep -i "template" template-debug.log
grep -i "error" template-debug.log
```

### Template Validation Script

```bash
cat << 'EOF' > validate-templates.sh
#!/bin/bash

TEMPLATE_DIR="${1:-$HOME/.local/share/claude-flow/templates}"

echo "Validating templates in: $TEMPLATE_DIR"
echo

errors=0

# Check main CLAUDE.md
if [ ! -f "$TEMPLATE_DIR/CLAUDE.md" ]; then
    echo "✗ Missing main CLAUDE.md"
    ((errors++))
else
    echo "✓ Found main CLAUDE.md"
fi

# Check required directories
for dir in commands languages frameworks workflows; do
    if [ ! -d "$TEMPLATE_DIR/$dir" ]; then
        echo "✗ Missing directory: $dir/"
        ((errors++))
    else
        echo "✓ Found directory: $dir/"
    fi
done

# Check for empty directories
for dir in commands languages frameworks workflows; do
    if [ -d "$TEMPLATE_DIR/$dir" ]; then
        count=$(find "$TEMPLATE_DIR/$dir" -type f -name "*.md" | wc -l)
        if [ $count -eq 0 ]; then
            echo "⚠ Warning: $dir/ has no .md files"
        fi
    fi
done

echo
if [ $errors -eq 0 ]; then
    echo "✓ Template validation passed!"
else
    echo "✗ Template validation failed with $errors errors"
    exit 1
fi
EOF

chmod +x validate-templates.sh
./validate-templates.sh
```

## Getting Help

If template issues persist:

1. Run template diagnostic:
```bash
find ~/.local/share/claude-flow /usr/local/share/claude-flow -name "*.md" 2>/dev/null | head -20
```

2. Check template integrity:
```bash
md5sum ~/.local/share/claude-flow/templates/CLAUDE.md
```

3. Report issue with:
   - Output of `check-templates.sh`
   - Template directory listing
   - Error messages
   - Expected vs actual behavior