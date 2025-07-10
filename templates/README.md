# Claude-Flow Template System

## Overview

Templates in Claude-Flow provide intelligent, context-aware instructions for different languages, frameworks, and projects. The system now supports **package-aware templates** that automatically adapt to use your team's preferred libraries and utilities.

## Template Types

### 1. Language Templates
Basic language-specific guidelines and patterns.
- `languages/php/CLAUDE.md` - Generic PHP best practices
- `languages/typescript/CLAUDE.md` - TypeScript patterns
- `languages/python/CLAUDE.md` - Python conventions
- `languages/go/CLAUDE.md` - Go idioms
- `languages/rust/CLAUDE.md` - Rust safety patterns

### 2. Enhanced Templates (Package-Aware)
Advanced templates that use your specific packages.
- `languages/php/CLAUDE_ENHANCED.md` - Uses SpacePlatform utilities
- Automatically generated based on detected packages
- Customized per project

### 3. Framework Templates
Framework-specific patterns and conventions.
- `frameworks/react/CLAUDE.md`
- `frameworks/nextjs/CLAUDE.md`
- `frameworks/express/CLAUDE.md`
- `frameworks/django/CLAUDE.md`

### 4. Workflow Templates
Automation for common development workflows.
- `workflows/ci-cd/`
- `workflows/testing/`
- `workflows/documentation/`

### 5. Command Templates
Pre-defined command templates for common development tasks.
- `command/check.md` - Code quality verification and error fixing
- `command/next.md` - Production-quality implementation workflow
- `command/prompt.md` - Prompt synthesizer for enhanced workflows

## Package-Aware Templates

### What Are They?
Templates that automatically adapt to use your company's libraries instead of generic solutions.

### Example Transformation
**Before (Generic):**
```php
$filtered = array_filter($users, fn($u) => $u->isActive());
```

**After (Package-Aware):**
```php
$filtered = IArray::from($users)->filter(fn($u) => $u->isActive());
```

### Configuration
Create `.claude/package-preferences.json`:
```json
{
  "php": {
    "array_handling": {
      "preferred": "spaceplatform/utils",
      "class": "SpacePlatform\\Utils\\Functional\\IArray"
    }
  }
}
```

### Benefits
- ✅ Consistent use of company utilities
- ✅ Automatic best practice enforcement
- ✅ Reduced onboarding time
- ✅ Type-safe operations
- ✅ Better performance

## How Templates Work

1. **Project Analysis**
   - Detect language and framework
   - Scan for installed packages
   - Check for custom utilities

2. **Template Selection**
   - Choose base language template
   - Apply framework overlays
   - Enhance with package preferences

3. **Customization**
   - Replace generic patterns
   - Add package-specific examples
   - Include migration helpers

4. **Generation**
   - Create project-specific CLAUDE.md
   - Generate custom modes
   - Set up workflows

## Using Templates

### Quick Start
```bash
# Enhance project with automatic detection
enhance-project

# Force specific template
enhance-project --template php --packages spaceplatform
```

### Manual Template Application
```bash
# Apply a specific template
claude-flow apply-template languages/php/CLAUDE_ENHANCED.md
```

### Creating Custom Templates
1. Copy an existing template
2. Modify for your needs
3. Save in `.claude/templates/`
4. Reference in configuration

## Template Variables

Templates support variable substitution:
- `{{PROJECT_NAME}}` - Current project name
- `{{PRIMARY_LANGUAGE}}` - Detected primary language
- `{{FRAMEWORK}}` - Detected framework
- `{{PACKAGES}}` - List of detected packages
- `{{DATE}}` - Current date

## Best Practices

1. **Keep Templates Focused**
   - One concept per section
   - Clear examples
   - Actionable guidelines

2. **Use Package Detection**
   - Let the system detect packages
   - Configure preferences
   - Provide fallbacks

3. **Version Control**
   - Track template changes
   - Document modifications
   - Share with team

4. **Regular Updates**
   - Review quarterly
   - Add new patterns
   - Remove outdated practices

## Advanced Features

### Conditional Templates
```yaml
conditions:
  - when: "laravel >= 9.0"
    apply: "templates/laravel9.md"
  - when: "has_package('spaceplatform/utils')"
    apply: "templates/enhanced.md"
```

### Template Inheritance
```yaml
extends: "languages/php/CLAUDE.md"
overrides:
  array_handling: "Use IArray"
  string_manipulation: "Use Str"
```

### Dynamic Sections
```markdown
{{#if HAS_SPACEPLATFORM}}
## Using SpacePlatform Utilities
...specific instructions...
{{/if}}
```

## Contributing Templates

1. Create template in appropriate directory
2. Add package detection rules
3. Include examples
4. Test on sample project
5. Submit PR with documentation

## See Also

- [Package-Aware Templates Deep Dive](../PACKAGE_AWARE_TEMPLATES.md)
- [Configuring Package Preferences](../CONFIGURING_PACKAGE_PREFERENCES.md)
- [Template Creation Guide](../TEMPLATE_GUIDE.md)