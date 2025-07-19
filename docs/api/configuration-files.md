# Claude Code Enhancer Configuration Files

Comprehensive reference for all configuration files used by Claude Code Enhancer.

## Table of Contents

- [Overview](#overview)
- [CLAUDE.md Format](#claudemd-format)
- [Configuration Hierarchy](#configuration-hierarchy)
- [YAML Configuration Files](#yaml-configuration-files)
- [Profile Configuration](#profile-configuration)
- [Template Configuration](#template-configuration)
- [Command Configuration](#command-configuration)
- [Quality Configuration](#quality-configuration)
- [Git Integration Configuration](#git-integration-configuration)
- [Hook Configuration](#hook-configuration)
- [Enterprise Configuration](#enterprise-configuration)
- [Configuration Validation](#configuration-validation)
- [Examples](#examples)

## Overview

Claude Code Enhancer uses a hierarchical configuration system with multiple file formats and precedence levels:

### Configuration File Types

| File | Format | Purpose | Scope |
|------|--------|---------|-------|
| `CLAUDE.md` | Markdown | Main project configuration | Project |
| `config.yaml` | YAML | Core system configuration | System/User/Project |
| `profiles/*.yaml` | YAML | Environment-specific configs | Profile |
| `quality.yaml` | YAML | Quality gate configuration | Quality |
| `templates.yaml` | YAML | Template system configuration | Templates |
| `hooks.yaml` | YAML | Hook system configuration | Hooks |
| `commands/*.yaml` | YAML | Individual command configs | Commands |

### Configuration Precedence

1. **Command-line flags** (highest priority)
2. **Environment variables**
3. **Project configuration** (`.claude/config.yaml`)
4. **User configuration** (`~/.config/claude-flow/config.yaml`)
5. **System configuration** (`/etc/claude-flow/config.yaml`)
6. **Built-in defaults** (lowest priority)

## CLAUDE.md Format

The `CLAUDE.md` file is the primary project configuration using an enhanced Markdown format.

### Basic Structure

```markdown
# Project Configuration

Brief description of your project and its Claude configuration.

## Development Partnership

Describe how Claude should work with your team and project.

## Complexity Triage System

Define complexity management rules and thresholds.

## File Creation Constraints

Specify file creation policies and limitations.

## Quality Gates Configuration

Define quality standards and enforcement rules.

## Custom Project Rules

Add any project-specific rules and guidelines.

# ========== CLAUDE FLOW TEMPLATE ==========
# Auto-updated: 2024-07-18 10:30:15

# Base template content (automatically managed)
# This section is updated by Claude Code Enhancer
```

### Enhanced CLAUDE.md Format

```markdown
---
# YAML Front Matter (optional)
claude:
  version: "1.0"
  project_type: "web_application"
  languages: ["javascript", "typescript"]
  frameworks: ["react", "nextjs"]
  
config:
  complexity_level: "strict"
  quality_threshold: 90
  agent_limit: 5
  
profiles:
  default: "development"
  production: "production"
  
integrations:
  git: true
  ci_cd: true
  quality_gates: true
---

# {{ project_name | default: "Project" }} Configuration

{{ project_description | default: "Claude Code Enhancer configuration for this project." }}

## Development Partnership

We're building {{ project_type | default: "production-quality code" }} together. Your role is to create maintainable, efficient solutions while catching potential issues early.

### Team Preferences
- **Code Style**: {{ code_style | default: "ESLint + Prettier" }}
- **Testing Strategy**: {{ testing_strategy | default: "Unit + Integration" }}
- **Documentation Level**: {{ documentation_level | default: "Comprehensive" }}

## Complexity Triage System

**Complexity Level**: {{ config.complexity_level | default: "standard" }}
**Quality Threshold**: {{ config.quality_threshold | default: 80 }}%

### Classification Rules
Before implementing ANY solution, categorize the problem:

#### 🟢 SIMPLE (Default Response)
- Single file changes
- Existing patterns can be reused
- Time estimate: < 30 minutes

#### 🟡 MEDIUM (Requires Justification)  
- Multiple file coordination needed
- New patterns within existing architecture
- Time estimate: 30 minutes - 2 hours

#### 🔴 COMPLEX (Requires Approval)
- Architectural changes
- System-wide impact (3+ modules)
- Time estimate: > 2 hours

## File Creation Constraints

**Maximum new files per feature**: {{ constraints.max_files | default: 5 }}
**Documentation style**: {{ constraints.docs_style | default: "consolidated" }}

### Hierarchy
1. Edit existing files first
2. Consolidate related content
3. Create new files only as last resort

## Quality Gates Configuration

### Required Gates
{% for gate in quality.required_gates | default: ["format", "cleanup", "verify"] %}
- **{{ gate }}**: {{ quality.gates[gate].description | default: "Quality check" }}
{% endfor %}

### Thresholds
- **Code Coverage**: {{ quality.thresholds.coverage | default: 80 }}%
- **Complexity Score**: {{ quality.thresholds.complexity | default: 10 }}
- **Security Score**: {{ quality.thresholds.security | default: 80 }}%

## Project-Specific Rules

{% if project_rules %}
{% for rule in project_rules %}
### {{ rule.title }}
{{ rule.description }}

{% if rule.examples %}
**Examples:**
{% for example in rule.examples %}
- {{ example }}
{% endfor %}
{% endif %}
{% endfor %}
{% endif %}

## Command Shortcuts

{% if shortcuts %}
{% for shortcut in shortcuts %}
- **{{ shortcut.name }}**: `{{ shortcut.command }}`
  {{ shortcut.description }}
{% endfor %}
{% endif %}

# ========== CLAUDE FLOW TEMPLATE ==========
# Auto-updated: {{ current_timestamp }}
# Template Version: {{ template_version }}
# Configuration Hash: {{ config_hash }}

{{ template_content }}
```

### Template Variables

CLAUDE.md supports template variables for dynamic content:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{ project_name }}` | Project name | "My Web App" |
| `{{ project_type }}` | Project type | "web_application" |
| `{{ languages }}` | Programming languages | ["javascript", "python"] |
| `{{ frameworks }}` | Frameworks used | ["react", "express"] |
| `{{ current_timestamp }}` | Current timestamp | "2024-07-18 10:30:15" |
| `{{ config_hash }}` | Configuration checksum | "a1b2c3d4..." |

### Conditional Sections

```markdown
{% if config.git_integration %}
## Git Integration

Automatic git integration is enabled.

{% if config.git_hooks %}
### Git Hooks
- Pre-commit: Quality checks
- Pre-push: Full test suite
{% endif %}
{% endif %}

{% if frameworks contains "react" %}
## React Configuration

React-specific development guidelines:
- Use functional components
- Implement proper hooks
- Follow component lifecycle patterns
{% endif %}
```

## Configuration Hierarchy

### System Configuration (`/etc/claude-flow/config.yaml`)

```yaml
# System-wide Claude Code Enhancer configuration
system:
  version: "1.0"
  installation_type: "system"
  data_dir: "/usr/local/share/claude-flow"
  
defaults:
  log_level: "info"
  timeout: 600
  agent_limit: 5
  cache_strategy: "moderate"
  
security:
  secure_mode: false
  allowed_paths: []
  external_tools: "auto"
  
enterprise:
  license_key: "${CLAUDE_LICENSE_KEY}"
  config_server: "${CLAUDE_CONFIG_SERVER}"
  telemetry: false
  
templates:
  system_templates: "/usr/local/share/claude-flow/templates"
  auto_update: true
  validation: "strict"
```

### User Configuration (`~/.config/claude-flow/config.yaml`)

```yaml
# User-specific Claude configuration
user:
  name: "{{ USER }}"
  email: "{{ GIT_USER_EMAIL }}"
  preferences:
    editor: "vscode"
    shell: "zsh"
    
defaults:
  log_level: "debug"
  dev_mode: true
  verbose_output: true
  
paths:
  config_dir: "~/.config/claude-flow"
  cache_dir: "~/.cache/claude-flow"
  templates_dir: "~/.local/share/claude-flow/templates"
  
profiles:
  default: "development"
  work: "enterprise"
  personal: "standard"
  
integrations:
  git:
    auto_hooks: true
    commit_template: true
  
  editor:
    vscode:
      extensions: ["claude-code-enhancer"]
      tasks: true
      
quality:
  strict_mode: false
  auto_fix: true
  parallel_checks: true
```

### Project Configuration (`.claude/config.yaml`)

```yaml
# Project-specific configuration
project:
  name: "My Application"
  type: "web_application"
  version: "1.0.0"
  
  languages: ["javascript", "typescript"]
  frameworks: ["react", "nextjs", "express"]
  
  structure:
    src_dir: "src"
    test_dir: "tests"
    docs_dir: "docs"
    config_dir: ".claude"

behavior:
  complexity_level: "strict"
  agent_limit: 8
  timeout: 900
  parallel_commands: true
  
quality:
  strict_mode: true
  threshold: 90
  required_gates: ["format", "cleanup", "verify", "test"]
  
  gates:
    format:
      tools: ["prettier", "eslint"]
      auto_fix: true
    cleanup:
      aggressive: true
      remove_unused: true
    verify:
      security_scan: true
      dependency_audit: true
    test:
      coverage_threshold: 85
      require_all_pass: true

git:
  hooks:
    pre_commit: ["quality/format", "quality/verify"]
    pre_push: ["test/unit", "test/integration"]
  
  branch_protection:
    enabled: true
    protected_branches: ["main", "develop"]

templates:
  customizations:
    - path: "src/components"
      template: "react-component"
    - path: "src/pages"
      template: "nextjs-page"

hooks:
  enabled: true
  directories: [".claude/hooks", "scripts/claude"]
  
commands:
  shortcuts:
    build: "npm run build"
    test: "npm test"
    lint: "npm run lint"
```

## YAML Configuration Files

### Core Configuration Schema

```yaml
# Complete configuration schema
core:
  log_level: string         # debug|info|warn|error|silent
  cache_strategy: string    # aggressive|moderate|conservative|disabled
  templates_dir: string     # Path to templates directory
  config_dir: string        # Configuration directory path
  data_dir: string          # Data directory path

behavior:
  agent_limit: integer      # Maximum concurrent agents (1-20)
  timeout: integer          # Default timeout in seconds (30-3600)
  retry_count: integer      # Retry attempts (0-10)
  retry_strategy: string    # linear|exponential|fixed
  parallel_commands: boolean # Allow parallel command execution

integration:
  git_integration: boolean  # Enable Git integration
  quality_gates: boolean    # Enable quality gates
  hook_system: boolean      # Enable hook system
  ci_mode: boolean          # CI/CD optimized behavior
  external_tools: string   # auto|comma-separated list

development:
  dev_mode: boolean         # Enable development features
  debug_agents: boolean     # Enable agent debugging
  verbose_output: boolean   # Enable verbose output
  profile_commands: boolean # Enable command profiling
  trace_execution: boolean  # Enable execution tracing

performance:
  cache_ttl: integer        # Cache TTL in seconds
  parallel_limit: integer   # Max parallel operations
  memory_limit: string      # Memory limit (e.g., "1G")
  disk_cache_size: string   # Disk cache size (e.g., "100M")

security:
  secure_mode: boolean      # Enhanced security restrictions
  sandbox_mode: boolean     # Sandbox execution
  allowed_paths: array      # Allowed file operation paths
  external_tools: array     # Allowed external tools
  audit_log: boolean        # Enable audit logging

templates:
  validation: string        # strict|lenient|disabled
  inheritance: boolean      # Template inheritance support
  cache: boolean           # Template caching
  custom_paths: array      # Additional template search paths

agents:
  strategy: string         # sequential|parallel|adaptive|custom
  timeout: integer         # Individual agent timeout
  communication: string    # files|memory|hybrid
  checkpoint: boolean      # Enable checkpointing

quality:
  strict_mode: boolean     # Strict quality enforcement
  threshold: integer       # Quality threshold percentage
  tools: array            # Quality tools to use
  config_file: string     # Custom quality config file

git:
  hooks: boolean           # Auto-install git hooks
  branch_protection: boolean # Branch protection features
  commit_template: string  # Commit message template
  auto_stage: boolean      # Auto-stage quality fixes

hooks:
  enabled: boolean         # Master hook switch
  directories: array       # Hook script directories
  timeout: integer         # Hook execution timeout
  parallel: boolean        # Parallel hook execution

enterprise:
  mode: boolean           # Enterprise mode
  license_key: string     # Enterprise license
  config_server: string   # Configuration server URL
  telemetry: boolean      # Usage telemetry
  compliance_mode: string # Compliance framework
```

## Profile Configuration

Profiles allow environment-specific configuration overrides.

### Profile Directory Structure

```
.claude/
├── config.yaml                 # Base configuration
└── profiles/
    ├── development.yaml         # Development overrides
    ├── staging.yaml            # Staging overrides
    ├── production.yaml         # Production overrides
    ├── ci.yaml                 # CI/CD overrides
    └── enterprise.yaml         # Enterprise overrides
```

### Profile Configuration Examples

#### Development Profile (`profiles/development.yaml`)

```yaml
# Development environment configuration
core:
  log_level: "debug"

development:
  dev_mode: true
  debug_agents: true
  verbose_output: true

behavior:
  agent_limit: 3
  retry_count: 1  # Fail fast in development

quality:
  strict_mode: false
  threshold: 70
  auto_fix: true

git:
  hooks: true
  auto_stage: true

performance:
  cache_strategy: "conservative"
  cache_ttl: 1800

templates:
  validation: "lenient"
```

#### Production Profile (`profiles/production.yaml`)

```yaml
# Production environment configuration
core:
  log_level: "warn"

behavior:
  agent_limit: 8
  timeout: 300  # Shorter timeout for production

security:
  secure_mode: true
  audit_log: true
  sandbox_mode: true

quality:
  strict_mode: true
  threshold: 95
  auto_fix: false  # Manual review required

performance:
  cache_strategy: "aggressive"
  cache_ttl: 7200
  memory_limit: "4G"

enterprise:
  mode: true
  telemetry: true
  compliance_mode: "sox"

git:
  branch_protection: true
  hooks: false  # Managed by CI/CD
```

#### CI/CD Profile (`profiles/ci.yaml`)

```yaml
# CI/CD environment configuration
integration:
  ci_mode: true

core:
  log_level: "error"

behavior:
  agent_limit: 4
  timeout: 600
  parallel_commands: true

quality:
  strict_mode: true
  threshold: 85
  required_gates: ["format", "verify", "test"]

performance:
  cache_strategy: "aggressive"
  parallel_limit: 8

git:
  hooks: false
  auto_stage: false

# Disable interactive features
development:
  dev_mode: false
  verbose_output: false
```

## Template Configuration

### Template Configuration File (`templates.yaml`)

```yaml
# Template system configuration
templates:
  version: "1.0"
  
  # Template sources
  sources:
    - type: "local"
      path: "./templates"
      priority: 1
    - type: "git"
      url: "https://github.com/company/claude-templates.git"
      branch: "main"
      priority: 2
    - type: "npm"
      package: "@company/claude-templates"
      priority: 3
  
  # Template categories
  categories:
    languages:
      javascript:
        templates: ["base", "enhanced"]
        default: "enhanced"
      typescript:
        templates: ["base", "strict"]
        default: "strict"
      python:
        templates: ["base", "scientific"]
        default: "base"
    
    frameworks:
      react:
        requires: ["javascript", "typescript"]
        templates: ["basic", "advanced"]
      nextjs:
        requires: ["react"]
        templates: ["app-router", "pages-router"]
      express:
        requires: ["javascript", "typescript"]
        templates: ["basic", "enterprise"]
  
  # Template inheritance
  inheritance:
    enabled: true
    order: ["base", "language", "framework", "project"]
    
  # Template validation
  validation:
    enabled: true
    schema_file: ".claude/schemas/template.json"
    strict_mode: true
    
  # Template caching
  cache:
    enabled: true
    ttl: 3600
    size_limit: "50M"
    
  # Custom template mappings
  mappings:
    "web-app": ["javascript", "react", "nextjs"]
    "api-server": ["typescript", "express"]
    "ml-project": ["python", "scientific"]
```

### Template Metadata (`template.yaml`)

Each template directory should contain a `template.yaml` file:

```yaml
# Template metadata
template:
  name: "React TypeScript Component"
  version: "1.0.0"
  description: "Advanced React component template with TypeScript"
  
  # Template requirements
  requires:
    languages: ["typescript"]
    frameworks: ["react"]
    min_claude_version: "1.0.0"
  
  # Template parameters
  parameters:
    component_name:
      type: "string"
      required: true
      description: "Name of the React component"
      pattern: "^[A-Z][a-zA-Z0-9]*$"
    
    use_hooks:
      type: "boolean"
      default: true
      description: "Use React hooks"
    
    style_type:
      type: "enum"
      values: ["css", "scss", "styled-components"]
      default: "scss"
      description: "Styling approach"
  
  # File generation rules
  files:
    - src: "Component.tsx.template"
      dest: "src/components/{{ component_name }}/{{ component_name }}.tsx"
      condition: "always"
    
    - src: "Component.test.tsx.template"
      dest: "src/components/{{ component_name }}/{{ component_name }}.test.tsx"
      condition: "test_enabled"
    
    - src: "styles.scss.template"
      dest: "src/components/{{ component_name }}/{{ component_name }}.scss"
      condition: "style_type === 'scss'"
  
  # Post-generation hooks
  hooks:
    post_generate:
      - command: "npm run format"
        condition: "format_enabled"
      - command: "npm run lint"
        condition: "lint_enabled"
```

## Command Configuration

Individual commands can have their own configuration files.

### Command Configuration Structure

```
.claude/commands/
├── architect/
│   ├── architect.md
│   └── config.yaml
├── quality/
│   ├── format.md
│   ├── verify.md
│   └── config.yaml
└── test/
    ├── unit.md
    ├── integration.md
    └── config.yaml
```

### Command Configuration Example (`commands/quality/config.yaml`)

```yaml
# Quality commands configuration
quality:
  # Global quality settings
  strict_mode: true
  parallel_execution: true
  fail_fast: false
  
  # Tool configurations
  tools:
    prettier:
      enabled: true
      config_file: ".prettierrc"
      ignore_file: ".prettierignore"
      
    eslint:
      enabled: true
      config_file: ".eslintrc.js"
      ignore_file: ".eslintignore"
      fix_mode: true
      
    stylelint:
      enabled: true
      config_file: ".stylelintrc"
      
  # Gate-specific settings
  gates:
    format:
      timeout: 120
      auto_fix: true
      tools: ["prettier", "eslint"]
      
    cleanup:
      timeout: 180
      aggressive: false
      remove_unused_imports: true
      remove_dead_code: true
      
    verify:
      timeout: 300
      security_scan: true
      dependency_audit: true
      license_check: true
      
  # Thresholds
  thresholds:
    code_coverage: 80
    complexity_score: 10
    duplication_ratio: 5
    security_score: 85
    
  # Reporting
  reports:
    format: "json"
    output_dir: ".claude/reports"
    include_metrics: true
    
  # Integration settings
  integration:
    git_hooks: true
    ci_mode: true
    editor_integration: true
```

## Quality Configuration

### Quality Configuration File (`.claude/quality.yaml`)

```yaml
# Comprehensive quality configuration
quality:
  version: "1.0"
  
  # Quality levels
  levels:
    lenient:
      code_coverage: 60
      complexity_score: 15
      duplication_ratio: 10
      security_score: 70
      
    standard:
      code_coverage: 80
      complexity_score: 10
      duplication_ratio: 5
      security_score: 80
      
    strict:
      code_coverage: 90
      complexity_score: 8
      duplication_ratio: 3
      security_score: 90
      
    enterprise:
      code_coverage: 95
      complexity_score: 6
      duplication_ratio: 2
      security_score: 95
  
  # Current quality level
  current_level: "standard"
  
  # Gate configurations
  gates:
    format:
      enabled: true
      weight: 1.0
      required: true
      auto_fix: true
      tools:
        - name: "prettier"
          config: ".prettierrc"
          languages: ["javascript", "typescript", "json", "css"]
        - name: "black"
          config: "pyproject.toml"
          languages: ["python"]
        - name: "gofmt"
          languages: ["go"]
          
    cleanup:
      enabled: true
      weight: 1.0
      required: true
      auto_fix: true
      options:
        remove_unused_imports: true
        remove_dead_code: true
        remove_empty_files: true
        consolidate_imports: true
        
    dedupe:
      enabled: true
      weight: 0.8
      required: false
      auto_fix: false
      options:
        similarity_threshold: 0.85
        min_lines: 10
        exclude_patterns: ["test/**", "*.test.*"]
        
    verify:
      enabled: true
      weight: 2.0
      required: true
      auto_fix: false
      checks:
        - name: "security_scan"
          tool: "semgrep"
          config: ".semgrep.yml"
        - name: "dependency_audit"
          tool: "npm audit"
        - name: "license_check"
          tool: "license-checker"
        - name: "vulnerability_scan"
          tool: "snyk"
          
  # Tool configurations
  tools:
    eslint:
      config_file: ".eslintrc.js"
      ignore_file: ".eslintignore"
      rules:
        max_complexity: 10
        max_depth: 4
        max_statements: 20
        
    sonarqube:
      server_url: "${SONAR_HOST_URL}"
      token: "${SONAR_TOKEN}"
      project_key: "${PROJECT_KEY}"
      
    codecov:
      token: "${CODECOV_TOKEN}"
      threshold: 80
      
  # Reporting configuration
  reporting:
    formats: ["json", "xml", "html"]
    output_directory: ".claude/reports/quality"
    include_trends: true
    
    metrics:
      - code_coverage
      - complexity_metrics
      - duplication_analysis
      - security_findings
      - dependency_vulnerabilities
      
  # Integration settings
  integrations:
    git:
      pre_commit_gates: ["format", "cleanup"]
      pre_push_gates: ["verify"]
      
    ci_cd:
      required_gates: ["format", "cleanup", "verify"]
      fail_on_quality_drop: true
      
    ide:
      real_time_checking: true
      auto_fix_on_save: true
```

## Git Integration Configuration

### Git Integration File (`.claude/git.yaml`)

```yaml
# Git integration configuration
git:
  version: "1.0"
  
  # Hook configuration
  hooks:
    enabled: true
    install_automatically: true
    
    pre_commit:
      enabled: true
      commands:
        - "quality/format --fix"
        - "quality/cleanup"
        - "quality/verify --fast"
      timeout: 300
      parallel: true
      
    pre_push:
      enabled: true
      commands:
        - "test/unit"
        - "quality/verify --comprehensive"
      timeout: 600
      fail_fast: true
      
    post_commit:
      enabled: false
      commands:
        - "milestone/status --update"
        
    commit_msg:
      enabled: true
      template: ".claude/git/commit-template.txt"
      validation:
        - "conventional_commits"
        - "max_length: 72"
        - "require_issue_reference"
  
  # Branch protection
  branch_protection:
    enabled: true
    protected_branches:
      - name: "main"
        rules:
          require_review: true
          require_status_checks: true
          required_checks: ["quality/verify", "test/unit"]
          dismiss_stale_reviews: true
          
      - name: "develop"
        rules:
          require_review: false
          require_status_checks: true
          required_checks: ["quality/format"]
  
  # Commit configuration
  commit:
    template_file: ".claude/git/commit-template.txt"
    auto_stage_fixes: true
    require_signed_commits: false
    
    conventional_commits:
      enabled: true
      types: ["feat", "fix", "docs", "style", "refactor", "test", "chore"]
      scopes: ["ui", "api", "db", "auth", "config"]
      
  # Workflow automation
  workflows:
    feature_branch:
      naming_pattern: "feature/{issue-number}-{description}"
      auto_create_pr: true
      auto_assign_reviewers: true
      
    hotfix_branch:
      naming_pattern: "hotfix/{version}-{description}"
      auto_create_pr: true
      merge_to_main: true
      
    release_branch:
      naming_pattern: "release/{version}"
      auto_tag: true
      auto_deploy: false
```

## Hook Configuration

### Hook Configuration File (`.claude/hooks.yaml`)

```yaml
# Hook system configuration
hooks:
  version: "1.0"
  
  # Global hook settings
  global:
    enabled: true
    timeout: 60
    parallel_execution: false
    continue_on_error: false
    
  # Hook directories
  directories:
    - path: ".claude/hooks"
      priority: 1
    - path: "scripts/claude-hooks"
      priority: 2
    - path: "~/.config/claude-flow/hooks"
      priority: 3
      
  # Hook types configuration
  types:
    pre_command:
      enabled: true
      timeout: 30
      parallel: true
      
    post_command:
      enabled: true
      timeout: 60
      parallel: false
      
    error_command:
      enabled: true
      timeout: 30
      parallel: false
      
    pre_edit:
      enabled: true
      timeout: 10
      parallel: true
      
    post_edit:
      enabled: true
      timeout: 20
      parallel: false
      
  # Command-specific hook configuration
  commands:
    architect:
      pre_command:
        - script: "validate-project-structure.sh"
          timeout: 15
        - script: "backup-config.sh"
          timeout: 10
          
      post_command:
        - script: "update-documentation.sh"
          timeout: 30
          
    "quality/*":
      pre_command:
        - script: "quality-pre-check.sh"
          
      post_command:
        - script: "quality-report.sh"
        - script: "update-metrics.sh"
          
    "git/*":
      pre_command:
        - script: "git-status-check.sh"
          
  # Environment variables for hooks
  environment:
    CLAUDE_HOOK_LOG_LEVEL: "info"
    CLAUDE_HOOK_TIMEOUT: "60"
    PROJECT_ROOT: "${PWD}"
    
  # Hook development settings
  development:
    debug_mode: false
    verbose_output: false
    dry_run: false
```

## Enterprise Configuration

### Enterprise Configuration File (`.claude/enterprise.yaml`)

```yaml
# Enterprise configuration
enterprise:
  version: "1.0"
  
  # License and authentication
  licensing:
    license_key: "${CLAUDE_LICENSE_KEY}"
    license_server: "https://license.claude.ai/api/v1"
    auto_renewal: true
    
  authentication:
    method: "oauth2"  # oauth2|saml|ldap
    provider: "okta"
    
    oauth2:
      client_id: "${OAUTH_CLIENT_ID}"
      client_secret: "${OAUTH_CLIENT_SECRET}"
      auth_url: "https://company.okta.com/oauth2/v1/authorize"
      token_url: "https://company.okta.com/oauth2/v1/token"
      
  # Centralized configuration
  configuration:
    server_url: "https://config.company.com/claude"
    api_key: "${CONFIG_SERVER_API_KEY}"
    sync_interval: 3600  # 1 hour
    auto_sync: true
    
  # Compliance and governance
  compliance:
    framework: "sox"  # sox|hipaa|pci|iso27001|custom
    audit_retention: "7y"
    data_classification: "confidential"
    
    policies:
      - name: "code_review_required"
        scope: ["main", "develop"]
        enforcement: "strict"
        
      - name: "security_scan_required"
        scope: ["all"]
        enforcement: "strict"
        
      - name: "documentation_required"
        scope: ["public_api"]
        enforcement: "warn"
        
  # Security settings
  security:
    encryption:
      at_rest: true
      in_transit: true
      algorithm: "AES-256-GCM"
      
    access_control:
      role_based: true
      multi_factor_required: true
      session_timeout: 3600
      
    audit_logging:
      enabled: true
      level: "comprehensive"
      retention: "7y"
      format: "json"
      destination: "siem"
      
  # Data governance
  data:
    retention_policies:
      logs: "90d"
      metrics: "2y"
      configurations: "indefinite"
      
    privacy:
      data_minimization: true
      anonymization: true
      consent_required: false
      
    backup:
      enabled: true
      frequency: "daily"
      retention: "30d"
      encryption: true
      
  # Integration with enterprise tools
  integrations:
    siem:
      enabled: true
      endpoint: "https://siem.company.com/api/events"
      api_key: "${SIEM_API_KEY}"
      
    monitoring:
      enabled: true
      provider: "datadog"
      api_key: "${DATADOG_API_KEY}"
      
    secret_management:
      enabled: true
      provider: "vault"
      endpoint: "https://vault.company.com"
      
  # Support and maintenance
  support:
    level: "enterprise"
    contact: "claude-support@company.com"
    escalation_path: ["team_lead", "engineering_manager", "cto"]
    
  maintenance:
    auto_updates: false
    maintenance_window: "02:00-04:00 UTC"
    notification_email: "devops@company.com"
```

## Configuration Validation

### Validation Schema

Claude Code Enhancer validates all configuration files against JSON schemas.

### Schema Definition (`.claude/schemas/config.json`)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Claude Code Enhancer Configuration",
  "type": "object",
  "properties": {
    "core": {
      "type": "object",
      "properties": {
        "log_level": {
          "type": "string",
          "enum": ["debug", "info", "warn", "error", "silent"]
        },
        "cache_strategy": {
          "type": "string",
          "enum": ["aggressive", "moderate", "conservative", "disabled"]
        },
        "templates_dir": {
          "type": "string",
          "pattern": "^(/|\\./|~/)"
        }
      }
    },
    "behavior": {
      "type": "object",
      "properties": {
        "agent_limit": {
          "type": "integer",
          "minimum": 1,
          "maximum": 20
        },
        "timeout": {
          "type": "integer",
          "minimum": 30,
          "maximum": 3600
        }
      }
    }
  },
  "required": ["core", "behavior"]
}
```

### Validation Commands

```bash
# Validate configuration files
claude --validate-config
claude --validate-config=.claude/config.yaml
claude --validate-config=.claude/profiles/production.yaml

# Validate against specific schema
claude --validate-config=config.yaml --schema=.claude/schemas/config.json

# Show configuration validation errors
claude --validate-config --verbose

# Fix configuration issues automatically
claude --validate-config --fix
```

## Examples

### Complete Project Configuration

This example shows a comprehensive configuration setup for a modern web application.

#### Project Structure
```
my-web-app/
├── .claude/
│   ├── config.yaml
│   ├── quality.yaml
│   ├── git.yaml
│   ├── hooks.yaml
│   ├── profiles/
│   │   ├── development.yaml
│   │   ├── staging.yaml
│   │   └── production.yaml
│   └── commands/
│       └── custom/
│           └── deploy.yaml
├── CLAUDE.md
└── src/
```

#### Main Configuration (`.claude/config.yaml`)
```yaml
project:
  name: "My Web Application"
  type: "web_application"
  version: "2.1.0"
  languages: ["typescript", "javascript"]
  frameworks: ["react", "nextjs", "express"]

core:
  log_level: "info"
  cache_strategy: "moderate"

behavior:
  agent_limit: 6
  timeout: 800
  parallel_commands: true
  complexity_level: "strict"

quality:
  strict_mode: true
  threshold: 90
  auto_fix: true

git:
  hooks: true
  branch_protection: true
  auto_stage: true

templates:
  validation: "strict"
  inheritance: true
  custom_paths: ["./templates", "../shared-templates"]

profiles:
  default: "development"
```

This comprehensive configuration system provides flexible, hierarchical configuration management suitable for projects of any size, from simple scripts to enterprise applications.