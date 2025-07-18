# Code Format Command Reference

**Command**: `/quality/format`  
**Category**: Quality Assurance  
**Description**: Comprehensive code formatting and style command for multiple languages and frameworks

## Overview

The `/quality/format` command provides intelligent code formatting that automatically detects languages, applies appropriate formatters, and maintains consistent style across your codebase. It supports project-specific configurations and multi-language codebases with parallel processing.

## Usage Patterns

```bash
# Format entire codebase
/quality/format

# Format specific directory
/quality/format src/

# Format specific files
/quality/format src/components/*.js

# Preview changes without applying
/quality/format --dry-run

# Format with specific formatters
/quality/format --formatter=prettier,eslint

# Comprehensive formatting with multiple passes
/quality/format --comprehensive

# Format and organize imports
/quality/format --organize-imports

# Fix common style issues
/quality/format --fix-style
```

## Command Syntax

```bash
/quality/format [target] [options]
```

### Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| `target` | Files/directories to format | `src/`, `*.js`, `file.py` |

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--dry-run` | Preview changes without applying | false |
| `--verbose` | Detailed output and logging | false |
| `--comprehensive` | Multiple formatting passes | false |
| `--organize-imports` | Organize and sort imports | false |
| `--fix-style` | Fix common style issues | false |
| `--formatter=<list>` | Specific formatters to use | auto-detect |
| `--config=<file>` | Custom configuration file | auto-detect |
| `--parallel` | Enable parallel processing | true |
| `--agents=N` | Number of parallel agents | 4 |
| `--backup` | Create backup before formatting | true |
| `--check` | Only check formatting, don't apply | false |

## Multi-Language Support

### Supported Languages and Formatters

| Language | Primary Formatter | Secondary Tools | Configuration |
|----------|------------------|-----------------|---------------|
| **JavaScript/TypeScript** | Prettier | ESLint, dprint | `.prettierrc`, `eslint.config.js` |
| **Python** | Black | isort, autopep8 | `pyproject.toml`, `.isort.cfg` |
| **Go** | gofmt | goimports, gofumpt | `.gofmt`, `go.mod` |
| **Rust** | rustfmt | clippy | `rustfmt.toml`, `Cargo.toml` |
| **PHP** | PHP-CS-Fixer | PHP_CodeSniffer | `.php-cs-fixer.dist.php` |
| **Java** | google-java-format | checkstyle | `checkstyle.xml` |
| **C/C++** | clang-format | uncrustify | `.clang-format` |
| **CSS/SCSS** | Prettier | stylelint | `.stylelintrc` |
| **HTML** | Prettier | htmlhint | `.prettierrc` |
| **JSON** | jq | jsonlint | built-in |
| **YAML** | yq | yamllint | `.yamllint` |
| **Markdown** | Prettier | markdownlint | `.markdownlint.json` |

### Framework-Specific Formatting

**React/Next.js**:
```bash
# React component formatting
- JSX/TSX syntax support
- React hooks formatting
- Component prop organization
- Import sorting with React patterns
```

**Vue.js**:
```bash
# Vue component formatting
- Vue SFC (Single File Component) support
- Template, script, style sections
- Vue-specific ESLint rules
- Composition API formatting
```

**Angular**:
```bash
# Angular project formatting
- TypeScript decorators
- Angular-specific ESLint rules
- Template formatting
- Service and component patterns
```

## Intelligent Formatting Process

### Phase 1: Discovery and Analysis

```bash
# File discovery and categorization
📁 Scan target directories recursively
🔍 Identify file types and languages
📊 Analyze codebase structure
⚙️ Detect existing configurations
🎯 Group files by formatter requirements
```

### Phase 2: Configuration Detection

```bash
# Configuration file detection
📄 .prettierrc, .prettierrc.json, prettier.config.js
📄 .eslintrc.json, eslint.config.js, .eslintrc.yml
📄 pyproject.toml, setup.cfg, .isort.cfg
📄 rustfmt.toml, .rustfmt.toml
📄 .php-cs-fixer.dist.php, .php_cs
📄 .clang-format, .clang-tidy
```

### Phase 3: Safety Validation

```bash
# Safety checks before formatting
✅ Git status validation (clean working directory recommended)
✅ Backup creation for safety
✅ File permission checks
✅ Large file handling
✅ Binary file exclusion
```

### Phase 4: Parallel Formatting Execution

```bash
# Multi-agent formatting coordination
Agent 1: JavaScript/TypeScript files
Agent 2: Python files  
Agent 3: CSS/SCSS/HTML files
Agent 4: Configuration and documentation files
```

## Formatter Configurations

### JavaScript/TypeScript (Prettier + ESLint)

```json
// .prettierrc
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false
}

// eslint.config.js
export default [
  {
    rules: {
      "indent": ["error", 2],
      "quotes": ["error", "single"],
      "semi": ["error", "always"]
    }
  }
];
```

### Python (Black + isort)

```toml
# pyproject.toml
[tool.black]
line-length = 100
target-version = ['py38']
include = '\.pyi?$'

[tool.isort]
profile = "black"
multi_line_output = 3
line_length = 100
```

### Go (gofmt + goimports)

```bash
# Go formatting commands
gofmt -w -s .           # Standard formatting
goimports -w .          # Import organization
gofumpt -w .           # Stricter formatting
```

### Rust (rustfmt)

```toml
# rustfmt.toml
max_width = 100
hard_tabs = false
tab_spaces = 4
newline_style = "Unix"
use_small_heuristics = "Default"
```

## Multi-Agent Coordination

### Agent Spawning Strategy

```bash
"I'll spawn multiple agents to format code efficiently across languages:
- Language-Specific Agents: Each agent handles specific file types
- Configuration Agent: Manages formatter configurations and validation
- Quality Agent: Ensures formatting meets style standards
- Reporting Agent: Collects results and generates comprehensive reports"
```

### Coordination Patterns

1. **Language-Based Coordination**
   - Agent 1: Frontend files (JS/TS/CSS/HTML)
   - Agent 2: Backend files (Python/Go/Rust/PHP)
   - Agent 3: Configuration files (JSON/YAML/TOML)
   - Agent 4: Documentation files (Markdown/plain text)

2. **Performance-Optimized Coordination**
   - Agent 1: Small files (< 1KB) batch processing
   - Agent 2: Medium files (1KB-100KB) individual processing
   - Agent 3: Large files (> 100KB) careful processing
   - Agent 4: Special files (generated code, vendor files)

## Advanced Features

### Import Organization

Intelligent import sorting and organization:

```bash
# JavaScript/TypeScript import organization
1. External libraries (react, lodash, etc.)
2. Internal modules (@/components, @/utils)
3. Relative imports (./component, ../utils)
4. Type-only imports (separated)

# Python import organization  
1. Standard library imports
2. Third-party library imports
3. Local application imports
4. Relative imports
```

### Style Issue Detection and Fixing

```bash
# Common style issues automatically fixed
🔧 Inconsistent indentation
🔧 Mixed tabs and spaces
🔧 Trailing whitespace
🔧 Missing final newlines
🔧 Inconsistent line endings
🔧 Unused imports
🔧 Duplicate imports
🔧 Import order violations
```

### Multi-Pass Formatting

Comprehensive formatting with multiple passes:

```bash
# Pass 1: Syntax and structure
- Basic syntax formatting
- Indentation correction
- Bracket and brace alignment

# Pass 2: Style and conventions
- Naming convention enforcement
- Comment formatting
- Spacing optimization

# Pass 3: Advanced optimizations
- Import organization
- Code structure improvements
- Performance optimizations
```

## Quality Validation

### Formatting Quality Metrics

```bash
# Quality assessment areas
📏 Consistent indentation (tabs vs spaces)
📐 Line length compliance
🎨 Consistent style patterns
📝 Proper comment formatting
🔤 Naming convention adherence
📋 Import organization quality
```

### Validation Reports

```bash
# Formatting validation results
✅ Files formatted successfully: 142
⚠️  Files with warnings: 3
❌ Files with errors: 0
📊 Total changes applied: 347
⏱️  Total formatting time: 2.3s
```

## Error Handling

### Common Error Scenarios

1. **Syntax Errors**
   ```bash
   ❌ Syntax error in file.js: Unexpected token
   
   # Resolution
   → Fix syntax errors before formatting
   → Use --skip-errors to continue with other files
   → Check file encoding and special characters
   ```

2. **Configuration Conflicts**
   ```bash
   ❌ Conflicting configuration: .prettierrc vs package.json
   
   # Resolution
   → Consolidate configurations
   → Use --config to specify primary config
   → Resolve conflicting rules
   ```

3. **Large File Handling**
   ```bash
   ⚠️  Large file detected (>10MB): data.json
   
   # Handling
   → Skip large files by default
   → Use --force-large to format anyway
   → Consider splitting large files
   ```

### Recovery Procedures

Automatic recovery and fallback strategies:

```bash
# Recovery mechanisms
1. Skip problematic files and continue
2. Fall back to basic formatters
3. Create detailed error reports
4. Suggest manual intervention steps
5. Preserve original files as backup
```

## Performance Optimization

### Execution Performance

```bash
# Performance optimizations
⚡ Parallel processing across multiple agents
🔄 Incremental formatting (only changed files)
💾 Formatter result caching
🎯 Smart file filtering
📊 Resource usage monitoring
```

### Resource Management

```bash
# Resource usage optimization
🧠 Memory-efficient file processing
⚙️  CPU-aware parallel execution
💽 Disk I/O optimization
🌐 Network resource management (for remote configs)
```

## Integration Features

### Editor Integration

```bash
# Editor integration support
📝 VS Code: Format on save integration
🧠 JetBrains: Code style synchronization
⚡ Vim/Neovim: Formatter plugin compatibility
📋 Sublime Text: Build system integration
```

### CI/CD Integration

```bash
# CI/CD pipeline integration
🔍 Format checking in CI
📊 Formatting diff reports
✅ Automated formatting PRs
📈 Code quality metrics
```

### Git Integration

```bash
# Git workflow integration
🪝 Pre-commit hook integration
📋 Staged file formatting
🔄 Automatic commit formatting
📊 Format diff analysis
```

## Workflow Examples

### Basic Codebase Formatting

```bash
# Complete codebase formatting
/quality/format

# Process flow:
# 1. Discover all formattable files
# 2. Detect languages and configurations
# 3. Create safety snapshots
# 4. Spawn agents for parallel formatting
# 5. Apply formatting with validation
# 6. Generate comprehensive report
```

### Pre-Commit Formatting

```bash
# Format staged files before commit
/quality/format --staged

# Integration with Git workflow:
# 1. Identify staged files
# 2. Apply relevant formatting
# 3. Stage formatted changes
# 4. Validate formatting quality
# 5. Report formatting results
```

### Comprehensive Style Fix

```bash
# Complete style overhaul
/quality/format --comprehensive --organize-imports --fix-style

# Enhanced process:
# 1. Multiple formatting passes
# 2. Import organization
# 3. Style issue detection and fixing
# 4. Quality validation
# 5. Detailed improvement report
```

## Related Commands

- **[/quality/cleanup](cleanup.md)** - Codebase cleanup and optimization
- **[/quality/verify](verify.md)** - Quality verification and validation
- **[/quality/dedupe](dedupe.md)** - Duplicate code detection and removal
- **[/git/commit](../git/commit.md)** - Smart commit with formatting
- **[/test/unit](../test/unit.md)** - Unit testing after formatting

## Best Practices

### Formatting Excellence

1. **Consistent Configuration**: Use project-wide formatting rules
2. **Incremental Formatting**: Format regularly, not just before release
3. **Team Standards**: Establish and enforce team formatting standards
4. **Automated Integration**: Use pre-commit hooks and CI checks
5. **Regular Updates**: Keep formatters and configurations updated

### Performance Best Practices

1. **Parallel Processing**: Leverage multi-agent coordination
2. **Incremental Updates**: Format only changed files when possible
3. **Smart Exclusions**: Exclude generated files and vendor code
4. **Resource Monitoring**: Monitor and optimize resource usage
5. **Caching Strategy**: Use formatter caching effectively

### Quality Assurance

1. **Preview Changes**: Always use --dry-run for major changes
2. **Backup Strategy**: Maintain backups before large formatting operations
3. **Validation Checks**: Verify formatting results
4. **Error Handling**: Address formatting errors promptly
5. **Continuous Improvement**: Regular formatting quality assessment

---

*The `/quality/format` command provides comprehensive code formatting with multi-language support, intelligent configuration detection, and parallel processing for consistent code style across your entire codebase.*