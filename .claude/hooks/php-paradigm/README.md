# PHP Paradigm Integration for Claude Code

This directory contains the PHP coding paradigm integration for Claude Code projects.

## Setup Instructions

### 1. Link Your PHP Paradigm Standards

```bash
# Option A: Environment variable (recommended)
export PHP_PARADIGM_PATH="/path/to/your/php-paradigm-standards"

# Option B: Create symbolic link
ln -s /path/to/your/php-paradigm-standards ./php-paradigm-source
```

### 2. Verify Hook Configuration

The `.claude/hooks.yaml` file should already be configured to use these hooks. Check that it contains:

```yaml
types:
  pre_edit:
    script: "./.php-paradigm/hooks/pre-edit.sh"
  post_edit:
    script: "./.php-paradigm/hooks/post-edit.sh"
```

### 3. Test the Integration

Create a test PHP file to verify the hooks work:

```bash
echo '<?php
class TestClass {
    const TEST_CONSTANT = "value";
}' > test-file.php
```

When Claude Code edits this file, it should:
- **Pre-edit**: Warn about missing `declare(strict_types=1)`
- **Post-edit**: Automatically add `declare(strict_types=1)`

## Hook Behavior

### Pre-Edit Hook (`.php-paradigm/hooks/pre-edit.sh`)

**Validates before Claude Code makes changes:**

- ✅ **PHP Files**: Checks for `declare(strict_types=1)` and typed constants
- ✅ **Test Files**: Validates test group hierarchy compliance
- ✅ **Config Files**: Ensures ConfigProvider pattern usage
- ⚠️ **Non-blocking**: Shows warnings but allows Claude to proceed

### Post-Edit Hook (`.php-paradigm/hooks/post-edit.sh`)

**Auto-fixes after Claude Code makes changes:**

- 🔧 **Auto-adds**: `declare(strict_types=1)` to PHP files
- 🔧 **Auto-adds**: Basic test groups to test files
- 🔧 **Runs**: PHP-CS-Fixer if available
- 🔧 **Applies**: PHP paradigm auto-fixer if available

## Customization

### Environment Variables

- `PHP_PARADIGM_PATH`: Path to your PHP paradigm standards directory
- `CLAUDE_HOOKS_LOG_LEVEL`: Set to `debug` for verbose logging

### Configuration Override

You can override hook behavior in `.claude/hooks.yaml`:

```yaml
php_paradigm:
  quality_gates:
    block_on_missing_strict_types: true  # Make pre-edit blocking
  auto_fix:
    enabled: false  # Disable auto-fixes
```

## Standards Enforced

### 🚨 PHP Type Safety (MANDATORY)
- **Strict types**: `declare(strict_types=1)` in all PHP files
- **Typed constants**: All constants must have explicit type declarations
- **Value objects**: Domain concepts use value objects, not primitives

### 🚨 Testing Standards (MANDATORY)
- **Group hierarchy**: Tests must inherit groups from directory structure
- **Naming conventions**: Consistent test class and method naming
- **Coverage requirements**: All public methods must be tested

### 🚨 Architecture Patterns (MANDATORY)
- **ConfigProvider pattern**: Use instead of annotations for library components
- **Immutable operations**: All updates via `with*` methods
- **Monads**: Maybe/Either patterns for safe operations

## Troubleshooting

### Hook Not Running
1. Check if `.claude/hooks.yaml` exists and is properly configured
2. Verify hook scripts are executable: `ls -la .php-paradigm/hooks/`
3. Check logs: `tail -f .claude/logs/hooks.log`

### Permission Issues
```bash
chmod +x .php-paradigm/hooks/*.sh
```

### Missing PHP Paradigm Standards
Update the path in your environment or `.claude/hooks.yaml`:
```bash
export PHP_PARADIGM_PATH="/correct/path/to/php-paradigm-standards"
```

## Integration with Existing Projects

For existing projects, the hooks will:

1. **Gradually enforce standards** without breaking existing code
2. **Auto-fix common issues** like missing strict types
3. **Warn about violations** that require manual attention
4. **Work alongside existing tools** like PHPStan and PHP-CS-Fixer

## Logs and Reporting

- **Hook logs**: `.claude/logs/hooks.log`
- **Compliance reports**: `.claude/reports/standards-compliance.json`
- **Real-time feedback**: Displayed in Claude Code output

## Examples

### Successful Auto-Fix
```
✅ AUTO-FIXED: Added declare(strict_types=1) to src/Entity/User.php
🔧 PHP paradigm auto-fixes applied to src/Entity/User.php
```

### Manual Fix Required
```
⚠️ MANUAL FIX NEEDED: Add type declarations to constants in src/Config/Database.php
   Example: const MY_CONSTANT: string = 'value';
```

### Validation Warning
```
❌ PHP PARADIGM VIOLATION: Missing test groups in tests/Unit/EntityTest.php
   Required by PHP paradigm testing standards
   Example: #[Group('unit-test')] #[Group('entity-test')]
```

## Supported PHP Paradigm Standards

This integration works with any PHP coding paradigm that includes:

- **Type Safety**: Strict type declarations and typed constants
- **Testing Standards**: Organized test structure with group hierarchy
- **Architecture Patterns**: ConfigProvider, immutable operations, monads
- **Documentation**: Bidirectional annotation and progressive complexity
- **Quality Gates**: Automated validation and compliance checking

The template is designed to be generic and work with various PHP coding paradigm implementations.