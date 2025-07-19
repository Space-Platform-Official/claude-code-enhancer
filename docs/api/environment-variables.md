# Claude Code Enhancer Environment Variables

Comprehensive reference for all environment variables used by Claude Code Enhancer components.

## Table of Contents

- [Core Configuration](#core-configuration)
- [Behavior Control](#behavior-control)
- [Integration Settings](#integration-settings)
- [Development Mode](#development-mode)
- [Performance Tuning](#performance-tuning)
- [Security Settings](#security-settings)
- [Debugging and Logging](#debugging-and-logging)
- [Template System](#template-system)
- [Agent Coordination](#agent-coordination)
- [Quality Gates](#quality-gates)
- [Git Integration](#git-integration)
- [Hook System](#hook-system)
- [Enterprise Configuration](#enterprise-configuration)

## Core Configuration

### CLAUDE_TEMPLATES_DIR
- **Type**: String (path)  
- **Default**: `~/.local/share/claude-flow/templates` or `/usr/local/share/claude-flow/templates`
- **Description**: Primary directory containing Claude templates
- **Usage**: Template resolution, command discovery
- **Example**: `CLAUDE_TEMPLATES_DIR=/opt/claude/templates`
- **Validation**: Must be readable directory with valid template structure

### CLAUDE_TEMPLATE_SOURCE
- **Type**: String (path)
- **Default**: None
- **Description**: Override source directory for templates during installation
- **Usage**: Template installation, custom template sources
- **Example**: `CLAUDE_TEMPLATE_SOURCE=/custom/templates`
- **Priority**: Highest priority in template resolution chain

### CLAUDE_CONFIG_DIR
- **Type**: String (path)
- **Default**: `~/.config/claude-flow/`
- **Description**: Primary configuration directory location
- **Usage**: User configuration, profiles, cache settings
- **Example**: `CLAUDE_CONFIG_DIR=/opt/claude/config`
- **Structure**: Contains `config.yaml`, `profiles/`, `cache/`

### CLAUDE_CACHE_DIR
- **Type**: String (path)
- **Default**: `~/.cache/claude-flow/`
- **Description**: Cache directory for temporary files and optimization data
- **Usage**: Template caching, analysis results, command history
- **Example**: `CLAUDE_CACHE_DIR=/tmp/claude-cache`
- **Cleanup**: Automatically cleaned based on retention policies

### CLAUDE_LOG_LEVEL
- **Type**: String (enum)
- **Default**: `info`
- **Values**: `debug`, `info`, `warn`, `error`, `silent`
- **Description**: Logging verbosity level
- **Usage**: Controls output detail level across all components
- **Example**: `CLAUDE_LOG_LEVEL=debug`
- **Impact**: Affects performance in debug mode

### CLAUDE_LOG_FILE
- **Type**: String (path)
- **Default**: `$CLAUDE_CACHE_DIR/claude.log`
- **Description**: Log file location for persistent logging
- **Usage**: Debugging, audit trails, error analysis
- **Example**: `CLAUDE_LOG_FILE=/var/log/claude/claude.log`
- **Rotation**: Supports log rotation with size and date limits

## Behavior Control

### CLAUDE_AGENT_LIMIT
- **Type**: Integer
- **Default**: `5`
- **Range**: `1-20`
- **Description**: Maximum number of concurrent agents
- **Usage**: Resource management, performance optimization
- **Example**: `CLAUDE_AGENT_LIMIT=3`
- **Impact**: Higher values increase parallelism but consume more resources

### CLAUDE_TIMEOUT
- **Type**: Integer (seconds)
- **Default**: `600`
- **Range**: `30-3600`
- **Description**: Default timeout for command execution
- **Usage**: Prevents hung operations, resource management
- **Example**: `CLAUDE_TIMEOUT=300`
- **Override**: Can be overridden per command with `--timeout`

### CLAUDE_RETRY_COUNT
- **Type**: Integer
- **Default**: `3`
- **Range**: `0-10`
- **Description**: Number of retries for failed operations
- **Usage**: Network operations, transient failure handling
- **Example**: `CLAUDE_RETRY_COUNT=5`
- **Strategy**: Supports exponential backoff with `CLAUDE_RETRY_STRATEGY`

### CLAUDE_RETRY_STRATEGY
- **Type**: String (enum)
- **Default**: `linear`
- **Values**: `linear`, `exponential`, `fixed`
- **Description**: Retry delay calculation strategy
- **Usage**: Fine-tuning retry behavior for different scenarios
- **Example**: `CLAUDE_RETRY_STRATEGY=exponential`
- **Parameters**: Works with `CLAUDE_RETRY_DELAY` and `CLAUDE_RETRY_MAX_DELAY`

### CLAUDE_RETRY_DELAY
- **Type**: Integer (seconds)
- **Default**: `2`
- **Range**: `1-60`
- **Description**: Base delay between retries
- **Usage**: Controls retry timing
- **Example**: `CLAUDE_RETRY_DELAY=5`
- **Calculation**: Base for exponential/linear strategies

### CLAUDE_MERGE_BACKUP
- **Type**: Boolean
- **Default**: `true`
- **Description**: Whether to create backup files during merge operations
- **Usage**: Safety mechanism for template merging
- **Example**: `CLAUDE_MERGE_BACKUP=false`
- **Recommendation**: Keep enabled for production systems

### CLAUDE_MERGE_BACKUP_RETENTION
- **Type**: Integer (hours)
- **Default**: `24`
- **Range**: `1-168` (1 week)
- **Description**: How long to keep backup files in hours
- **Usage**: Storage management, compliance requirements
- **Example**: `CLAUDE_MERGE_BACKUP_RETENTION=48`
- **Cleanup**: Automatic cleanup based on file timestamps

### CLAUDE_MERGE_BACKUP_GRACE
- **Type**: Integer (hours)
- **Default**: `0`
- **Range**: `0-24`
- **Description**: Grace period before removing successful merge backups
- **Usage**: Additional safety buffer for recent operations
- **Example**: `CLAUDE_MERGE_BACKUP_GRACE=2`
- **Purpose**: Allows verification before automatic cleanup

## Integration Settings

### CLAUDE_GIT_INTEGRATION
- **Type**: Boolean
- **Default**: `true`
- **Description**: Enable/disable Git integration features
- **Usage**: Git hooks, commit analysis, branch management
- **Example**: `CLAUDE_GIT_INTEGRATION=false`
- **Impact**: Disables git/* commands and related features

### CLAUDE_QUALITY_GATES
- **Type**: Boolean
- **Default**: `true`
- **Description**: Enable/disable quality gate enforcement
- **Usage**: Pre-commit hooks, quality verification
- **Example**: `CLAUDE_QUALITY_GATES=false`
- **Recommendation**: Keep enabled for code quality

### CLAUDE_HOOK_SYSTEM
- **Type**: Boolean
- **Default**: `true`
- **Description**: Enable/disable hook system
- **Usage**: Pre/post command hooks, custom extensions
- **Example**: `CLAUDE_HOOK_SYSTEM=false`
- **Impact**: Disables all hook execution

### CLAUDE_EXTERNAL_TOOLS
- **Type**: String (comma-separated)
- **Default**: `auto`
- **Description**: Control external tool integration
- **Usage**: Specify allowed external tools
- **Example**: `CLAUDE_EXTERNAL_TOOLS=git,npm,docker`
- **Security**: Restricts external command execution

### CLAUDE_CI_MODE
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable CI/CD optimized behavior
- **Usage**: Non-interactive mode, streamlined output
- **Example**: `CLAUDE_CI_MODE=true`
- **Changes**: Disables prompts, enables batch mode

## Development Mode

### CLAUDE_DEV_MODE
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable development mode features
- **Usage**: Enhanced debugging, development tools
- **Example**: `CLAUDE_DEV_MODE=true`
- **Features**: Extended logging, debug commands, profiling

### CLAUDE_DEBUG_AGENTS
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable agent debugging and tracing
- **Usage**: Agent coordination debugging
- **Example**: `CLAUDE_DEBUG_AGENTS=true`
- **Output**: Detailed agent communication logs

### CLAUDE_VERBOSE_OUTPUT
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable verbose output for all operations
- **Usage**: Troubleshooting, detailed operation logs
- **Example**: `CLAUDE_VERBOSE_OUTPUT=true`
- **Impact**: Significantly increases output volume

### CLAUDE_PROFILE_COMMANDS
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable command execution profiling
- **Usage**: Performance analysis, optimization
- **Example**: `CLAUDE_PROFILE_COMMANDS=true`
- **Output**: Timing and resource usage statistics

### CLAUDE_TRACE_EXECUTION
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable detailed execution tracing
- **Usage**: Deep debugging, execution flow analysis
- **Example**: `CLAUDE_TRACE_EXECUTION=true`
- **Warning**: Generates large amounts of debug data

## Performance Tuning

### CLAUDE_CACHE_STRATEGY
- **Type**: String (enum)
- **Default**: `moderate`
- **Values**: `aggressive`, `moderate`, `conservative`, `disabled`
- **Description**: Caching strategy for performance optimization
- **Usage**: Balance between speed and resource usage
- **Example**: `CLAUDE_CACHE_STRATEGY=aggressive`
- **Impact**: Affects memory usage and startup time

### CLAUDE_CACHE_TTL
- **Type**: Integer (seconds)
- **Default**: `3600`
- **Range**: `300-86400`
- **Description**: Cache time-to-live for cached items
- **Usage**: Controls cache freshness vs. performance
- **Example**: `CLAUDE_CACHE_TTL=1800`
- **Balance**: Lower values ensure freshness, higher improve performance

### CLAUDE_PARALLEL_LIMIT
- **Type**: Integer
- **Default**: `auto`
- **Range**: `1-32`
- **Description**: Maximum parallel operations (auto-detects CPU cores)
- **Usage**: Resource management, performance tuning
- **Example**: `CLAUDE_PARALLEL_LIMIT=8`
- **Detection**: `auto` uses `nproc` or CPU core count

### CLAUDE_MEMORY_LIMIT
- **Type**: String (size)
- **Default**: `1G`
- **Format**: Number + unit (K, M, G)
- **Description**: Memory limit for Claude operations
- **Usage**: Resource control, preventing OOM
- **Example**: `CLAUDE_MEMORY_LIMIT=2G`
- **Enforcement**: Soft limit with warnings

### CLAUDE_DISK_CACHE_SIZE
- **Type**: String (size)
- **Default**: `100M`
- **Format**: Number + unit (K, M, G)
- **Description**: Maximum disk cache size
- **Usage**: Storage management
- **Example**: `CLAUDE_DISK_CACHE_SIZE=500M`
- **Cleanup**: LRU eviction when limit reached

## Security Settings

### CLAUDE_SECURE_MODE
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable enhanced security restrictions
- **Usage**: High-security environments
- **Example**: `CLAUDE_SECURE_MODE=true`
- **Impact**: Restricts file operations, external commands

### CLAUDE_ALLOWED_PATHS
- **Type**: String (colon-separated paths)
- **Default**: `auto`
- **Description**: Restrict file operations to specified paths
- **Usage**: Sandbox mode, security boundaries
- **Example**: `CLAUDE_ALLOWED_PATHS=/home/user/projects:/tmp`
- **Auto**: Uses project directory and standard temp locations

### CLAUDE_SANDBOX_MODE
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable sandbox execution mode
- **Usage**: Isolated execution, security testing
- **Example**: `CLAUDE_SANDBOX_MODE=true`
- **Restrictions**: No network, limited file access

### CLAUDE_AUDIT_LOG
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable comprehensive audit logging
- **Usage**: Compliance, security monitoring
- **Example**: `CLAUDE_AUDIT_LOG=true`
- **Format**: Structured JSON logs with timestamps

### CLAUDE_AUDIT_DIR
- **Type**: String (path)
- **Default**: `$CLAUDE_LOG_DIR/audit`
- **Description**: Directory for audit log files
- **Usage**: Centralized audit log storage
- **Example**: `CLAUDE_AUDIT_DIR=/var/log/claude/audit`
- **Rotation**: Daily rotation with configurable retention

## Debugging and Logging

### CLAUDE_DEBUG_FILTER
- **Type**: String (comma-separated)
- **Default**: `all`
- **Description**: Filter debug output by component
- **Usage**: Focused debugging
- **Example**: `CLAUDE_DEBUG_FILTER=agents,templates,git`
- **Components**: `agents`, `templates`, `git`, `quality`, `hooks`

### CLAUDE_LOG_FORMAT
- **Type**: String (enum)
- **Default**: `text`
- **Values**: `text`, `json`, `structured`
- **Description**: Log output format
- **Usage**: Integration with log aggregation systems
- **Example**: `CLAUDE_LOG_FORMAT=json`
- **JSON**: Machine-readable structured logs

### CLAUDE_LOG_COLORS
- **Type**: Boolean
- **Default**: `auto`
- **Description**: Enable colored log output
- **Usage**: Improved readability in terminals
- **Example**: `CLAUDE_LOG_COLORS=false`
- **Auto**: Detects TTY and color support

### CLAUDE_ERROR_CONTEXT
- **Type**: Integer (lines)
- **Default**: `5`
- **Range**: `0-20`
- **Description**: Lines of context to include with errors
- **Usage**: Enhanced error diagnostics
- **Example**: `CLAUDE_ERROR_CONTEXT=10`
- **Impact**: Larger values provide more context but increase log size

## Template System

### CLAUDE_TEMPLATE_CACHE
- **Type**: Boolean
- **Default**: `true`
- **Description**: Enable template caching for performance
- **Usage**: Faster template resolution and processing
- **Example**: `CLAUDE_TEMPLATE_CACHE=false`
- **Impact**: Disabling may slow template operations

### CLAUDE_TEMPLATE_VALIDATION
- **Type**: String (enum)
- **Default**: `strict`
- **Values**: `strict`, `lenient`, `disabled`
- **Description**: Template validation level
- **Usage**: Quality control for custom templates
- **Example**: `CLAUDE_TEMPLATE_VALIDATION=lenient`
- **Strict**: Full validation with schema checking

### CLAUDE_TEMPLATE_INHERITANCE
- **Type**: Boolean
- **Default**: `true`
- **Description**: Enable template inheritance features
- **Usage**: Advanced template composition
- **Example**: `CLAUDE_TEMPLATE_INHERITANCE=false`
- **Features**: Base templates, overrides, composition

### CLAUDE_CUSTOM_TEMPLATES
- **Type**: String (colon-separated paths)
- **Default**: None
- **Description**: Additional template search paths
- **Usage**: Custom template locations
- **Example**: `CLAUDE_CUSTOM_TEMPLATES=/opt/templates:/home/user/templates`
- **Priority**: Searched after standard locations

## Agent Coordination

### CLAUDE_AGENT_STRATEGY
- **Type**: String (enum)
- **Default**: `adaptive`
- **Values**: `sequential`, `parallel`, `adaptive`, `custom`
- **Description**: Agent execution strategy
- **Usage**: Optimize for different workload types
- **Example**: `CLAUDE_AGENT_STRATEGY=parallel`
- **Adaptive**: Automatically chooses based on workload

### CLAUDE_AGENT_TIMEOUT
- **Type**: Integer (seconds)
- **Default**: `300`
- **Range**: `30-1800`
- **Description**: Individual agent timeout
- **Usage**: Prevent stuck agents
- **Example**: `CLAUDE_AGENT_TIMEOUT=600`
- **Escalation**: Automatic cleanup after timeout

### CLAUDE_AGENT_COMMUNICATION
- **Type**: String (enum)
- **Default**: `files`
- **Values**: `files`, `memory`, `hybrid`
- **Description**: Agent communication mechanism
- **Usage**: Performance vs. reliability trade-offs
- **Example**: `CLAUDE_AGENT_COMMUNICATION=memory`
- **Files**: Most reliable, slower
- **Memory**: Fastest, less reliable
- **Hybrid**: Balanced approach

### CLAUDE_AGENT_CHECKPOINT
- **Type**: Boolean
- **Default**: `true`
- **Description**: Enable agent checkpointing for recovery
- **Usage**: Fault tolerance, resume capability
- **Example**: `CLAUDE_AGENT_CHECKPOINT=false`
- **Storage**: Checkpoint data stored in cache directory

## Quality Gates

### CLAUDE_QUALITY_STRICT
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable strict quality enforcement
- **Usage**: Zero-tolerance quality policy
- **Example**: `CLAUDE_QUALITY_STRICT=true`
- **Impact**: Any quality violation blocks operation

### CLAUDE_QUALITY_TOOLS
- **Type**: String (comma-separated)
- **Default**: `auto`
- **Description**: Specify quality tools to use
- **Usage**: Control which tools are executed
- **Example**: `CLAUDE_QUALITY_TOOLS=eslint,prettier,jest`
- **Auto**: Detects available tools automatically

### CLAUDE_QUALITY_CONFIG
- **Type**: String (path)
- **Default**: `.claude/quality.yaml`
- **Description**: Custom quality configuration file
- **Usage**: Project-specific quality rules
- **Example**: `CLAUDE_QUALITY_CONFIG=./config/quality.yaml`
- **Format**: YAML configuration file

### CLAUDE_QUALITY_THRESHOLD
- **Type**: Integer (percentage)
- **Default**: `80`
- **Range**: `0-100`
- **Description**: Quality score threshold for passing
- **Usage**: Define minimum acceptable quality level
- **Example**: `CLAUDE_QUALITY_THRESHOLD=90`
- **Calculation**: Based on weighted quality metrics

## Git Integration

### CLAUDE_GIT_HOOKS
- **Type**: Boolean
- **Default**: `true`
- **Description**: Enable automatic Git hook installation
- **Usage**: Integrate quality gates with Git workflow
- **Example**: `CLAUDE_GIT_HOOKS=false`
- **Hooks**: pre-commit, post-commit, pre-push

### CLAUDE_GIT_BRANCH_PROTECTION
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable branch protection features
- **Usage**: Prevent direct commits to protected branches
- **Example**: `CLAUDE_GIT_BRANCH_PROTECTION=true`
- **Default Protected**: `main`, `master`, `develop`

### CLAUDE_GIT_COMMIT_TEMPLATE
- **Type**: String (path)
- **Default**: `.claude/git/commit-template.txt`
- **Description**: Default commit message template
- **Usage**: Standardize commit message format
- **Example**: `CLAUDE_GIT_COMMIT_TEMPLATE=./templates/commit.txt`
- **Variables**: Supports template variables

### CLAUDE_GIT_AUTO_STAGE
- **Type**: Boolean
- **Default**: `false`
- **Description**: Automatically stage quality-fixed files
- **Usage**: Streamline quality gate workflow
- **Example**: `CLAUDE_GIT_AUTO_STAGE=true`
- **Safety**: Only stages files modified by quality tools

## Hook System

### CLAUDE_HOOKS_ENABLED
- **Type**: Boolean
- **Default**: `true`
- **Description**: Master switch for all hook execution
- **Usage**: Globally enable/disable hooks
- **Example**: `CLAUDE_HOOKS_ENABLED=false`
- **Override**: Individual hooks can still be disabled

### CLAUDE_HOOKS_DIR
- **Type**: String (path)
- **Default**: `.claude/hooks`
- **Description**: Directory containing hook scripts
- **Usage**: Custom hook location
- **Example**: `CLAUDE_HOOKS_DIR=./scripts/claude-hooks`
- **Structure**: Organized by hook type (pre/, post/, error/)

### CLAUDE_HOOKS_TIMEOUT
- **Type**: Integer (seconds)
- **Default**: `60`
- **Range**: `5-300`
- **Description**: Timeout for individual hook execution
- **Usage**: Prevent hung hooks
- **Example**: `CLAUDE_HOOKS_TIMEOUT=120`
- **Escalation**: Hooks killed after timeout

### CLAUDE_HOOKS_PARALLEL
- **Type**: Boolean
- **Default**: `false`
- **Description**: Allow parallel hook execution where safe
- **Usage**: Performance optimization
- **Example**: `CLAUDE_HOOKS_PARALLEL=true`
- **Safety**: Only applies to independent hooks

## Enterprise Configuration

### CLAUDE_ENTERPRISE_MODE
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable enterprise features and restrictions
- **Usage**: Corporate environments, compliance
- **Example**: `CLAUDE_ENTERPRISE_MODE=true`
- **Features**: Enhanced audit, centralized config, SSO

### CLAUDE_CONFIG_SERVER
- **Type**: String (URL)
- **Default**: None
- **Description**: Centralized configuration server URL
- **Usage**: Enterprise configuration management
- **Example**: `CLAUDE_CONFIG_SERVER=https://config.company.com/claude`
- **Protocol**: HTTPS required for security

### CLAUDE_TELEMETRY
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable usage telemetry collection
- **Usage**: Usage analytics, performance monitoring
- **Example**: `CLAUDE_TELEMETRY=true`
- **Privacy**: No sensitive data collected

### CLAUDE_LICENSE_KEY
- **Type**: String
- **Default**: None
- **Description**: Enterprise license key
- **Usage**: Unlock enterprise features
- **Example**: `CLAUDE_LICENSE_KEY=ent_1234567890abcdef`
- **Security**: Should be stored securely

### CLAUDE_COMPLIANCE_MODE
- **Type**: String (enum)
- **Default**: `standard`
- **Values**: `standard`, `sox`, `hipaa`, `pci`, `custom`
- **Description**: Compliance framework to follow
- **Usage**: Regulatory compliance requirements
- **Example**: `CLAUDE_COMPLIANCE_MODE=sox`
- **Impact**: Enforces additional audit and security requirements

## Environment Variable Validation

### Validation Rules

The Claude Code Enhancer validates environment variables at startup:

#### Path Variables
- Must be absolute paths or relative to working directory
- Directories must exist and be accessible
- Files must be readable (for input) or writable (for output)
- Size limits enforced for cache directories

#### Numeric Variables
- Range validation for all numeric parameters
- Type validation (integer vs. float)
- Unit parsing for size-based variables (K, M, G suffixes)
- Auto-detection fallbacks where applicable

#### Boolean Variables
- Accepts: `true`, `false`, `1`, `0`, `yes`, `no`, `on`, `off`
- Case-insensitive parsing
- Invalid values default to `false` with warning

#### Enum Variables
- Strict validation against allowed values
- Case-insensitive matching where appropriate
- Helpful error messages with valid options
- Auto-completion suggestions for typos

### Configuration Precedence

Environment variables follow this precedence order (highest to lowest):

1. **Command-line flags**: `--config-dir=/path`
2. **Environment variables**: `CLAUDE_CONFIG_DIR=/path`
3. **Project configuration**: `.claude/config.yaml`
4. **User configuration**: `~/.config/claude-flow/config.yaml`
5. **System configuration**: `/etc/claude-flow/config.yaml`
6. **Built-in defaults**: Hardcoded fallback values

### Dynamic Configuration

Some variables support runtime modification:

```bash
# Change log level during execution
claude --log-level=debug architect

# Override agent limit for specific command
claude --agent-limit=10 milestone/execute

# Temporary cache strategy change
claude --cache-strategy=disabled quality/verify
```

## Configuration Management

### Configuration Files

Environment variables can also be set via configuration files:

```yaml
# ~/.config/claude-flow/config.yaml
core:
  templates_dir: "/opt/claude/templates"
  cache_dir: "/var/cache/claude-flow"
  log_level: "info"

behavior:
  agent_limit: 5
  timeout: 600
  retry_count: 3

integration:
  git_integration: true
  quality_gates: true
  hook_system: true

development:
  dev_mode: false
  debug_agents: false
  verbose_output: false

performance:
  cache_strategy: "moderate"
  parallel_limit: "auto"
  memory_limit: "1G"

security:
  secure_mode: false
  audit_log: false
  sandbox_mode: false
```

### Profile-Based Configuration

Use configuration profiles for different environments:

```bash
# Use development profile
claude --profile=development architect

# Use production profile
claude --profile=production quality/verify

# Use custom profile file
claude --profile=./custom-profile.yaml refactor
```

Profile files override base configuration:

```yaml
# profiles/development.yaml
core:
  log_level: "debug"

development:
  dev_mode: true
  debug_agents: true
  verbose_output: true

behavior:
  retry_count: 1  # Fail fast in development
```

### Environment Inheritance

Configuration inherits from parent environments:

```bash
# Base environment
export CLAUDE_LOG_LEVEL=info
export CLAUDE_CACHE_STRATEGY=moderate

# Development overrides
if [[ "$ENVIRONMENT" == "development" ]]; then
    export CLAUDE_LOG_LEVEL=debug
    export CLAUDE_DEV_MODE=true
fi

# Production overrides
if [[ "$ENVIRONMENT" == "production" ]]; then
    export CLAUDE_SECURE_MODE=true
    export CLAUDE_AUDIT_LOG=true
fi
```

## Usage Examples

### Development Environment
```bash
# Development configuration
export CLAUDE_DEV_MODE=true
export CLAUDE_VERBOSE_OUTPUT=true
export CLAUDE_DEBUG_AGENTS=true
export CLAUDE_TEMPLATE_SOURCE="./dev-templates"
export CLAUDE_MERGE_BACKUP=true
export CLAUDE_MERGE_BACKUP_RETENTION=48
export CLAUDE_CACHE_STRATEGY=conservative

# Enhanced debugging
export CLAUDE_LOG_LEVEL=debug
export CLAUDE_DEBUG_FILTER=agents,templates
export CLAUDE_PROFILE_COMMANDS=true

# Run claude commands
claude-install-flow
claude architect
```

### Production Environment
```bash
# Production configuration
export CLAUDE_TEMPLATES_DIR="/opt/claude/production-templates"
export CLAUDE_CONFIG_DIR="/etc/claude-flow"
export CLAUDE_CACHE_DIR="/var/cache/claude-flow"
export CLAUDE_LOG_FILE="/var/log/claude/claude.log"

# Performance optimization
export CLAUDE_CACHE_STRATEGY=aggressive
export CLAUDE_AGENT_LIMIT=8
export CLAUDE_PARALLEL_LIMIT=16
export CLAUDE_MEMORY_LIMIT=4G

# Security and audit
export CLAUDE_SECURE_MODE=true
export CLAUDE_AUDIT_LOG=true
export CLAUDE_AUDIT_DIR="/var/log/claude/audit"

# Quality enforcement
export CLAUDE_QUALITY_STRICT=true
export CLAUDE_QUALITY_THRESHOLD=90

# Deploy to production directory
claude-install-flow /var/www/app
```

### CI/CD Pipeline
```bash
# CI/CD configuration
export CLAUDE_CI_MODE=true
export CLAUDE_MERGE_BACKUP=false
export CLAUDE_VERBOSE_OUTPUT=false
export CLAUDE_LOG_LEVEL=warn

# Performance for CI
export CLAUDE_CACHE_STRATEGY=aggressive
export CLAUDE_AGENT_LIMIT=4
export CLAUDE_TIMEOUT=300

# Quality gates
export CLAUDE_QUALITY_GATES=true
export CLAUDE_QUALITY_STRICT=true
export CLAUDE_GIT_HOOKS=false

# Use CI-specific templates
export CLAUDE_TEMPLATE_SOURCE="./ci-templates"

# Install and verify
claude-install-flow "${BUILD_DIR}"
claude quality/verify --ci-mode
```

### Enterprise Environment
```bash
# Enterprise configuration
export CLAUDE_ENTERPRISE_MODE=true
export CLAUDE_LICENSE_KEY="${CLAUDE_ENTERPRISE_LICENSE}"
export CLAUDE_CONFIG_SERVER="https://config.company.com/claude"
export CLAUDE_COMPLIANCE_MODE=sox

# Centralized settings
export CLAUDE_TEMPLATES_DIR="/enterprise/claude/templates"
export CLAUDE_AUDIT_LOG=true
export CLAUDE_TELEMETRY=true

# Security restrictions
export CLAUDE_SECURE_MODE=true
export CLAUDE_ALLOWED_PATHS="/workspace:/tmp"
export CLAUDE_EXTERNAL_TOOLS="git,npm"

# Quality enforcement
export CLAUDE_QUALITY_STRICT=true
export CLAUDE_QUALITY_THRESHOLD=95

# Run with enterprise features
claude architect --enterprise
```

### High-Security Environment
```bash
# Maximum security configuration
export CLAUDE_SECURE_MODE=true
export CLAUDE_SANDBOX_MODE=true
export CLAUDE_ALLOWED_PATHS="/secure/workspace"
export CLAUDE_EXTERNAL_TOOLS=""

# Comprehensive audit
export CLAUDE_AUDIT_LOG=true
export CLAUDE_LOG_LEVEL=info
export CLAUDE_LOG_FORMAT=json

# Restricted features
export CLAUDE_GIT_INTEGRATION=false
export CLAUDE_HOOK_SYSTEM=false
export CLAUDE_AGENT_LIMIT=1

# No caching for security
export CLAUDE_CACHE_STRATEGY=disabled
export CLAUDE_TEMPLATE_CACHE=false

# Run in secure mode
claude architect --secure
```

## Best Practices

### Environment-Specific Configuration

**Development Environment:**
```bash
# Enhanced debugging and safety
export CLAUDE_DEV_MODE=true
export CLAUDE_VERBOSE_OUTPUT=true
export CLAUDE_MERGE_BACKUP=true
export CLAUDE_MERGE_BACKUP_RETENTION=48
export CLAUDE_LOG_LEVEL=debug
export CLAUDE_CACHE_STRATEGY=conservative
```

**Staging Environment:**
```bash
# Production-like with some debugging
export CLAUDE_LOG_LEVEL=info
export CLAUDE_AUDIT_LOG=true
export CLAUDE_QUALITY_STRICT=true
export CLAUDE_CACHE_STRATEGY=moderate
export CLAUDE_MERGE_BACKUP_RETENTION=24
```

**Production Environment:**
```bash
# Optimized and secure
export CLAUDE_CACHE_STRATEGY=aggressive
export CLAUDE_SECURE_MODE=true
export CLAUDE_AUDIT_LOG=true
export CLAUDE_LOG_LEVEL=warn
export CLAUDE_QUALITY_STRICT=true
export CLAUDE_MERGE_BACKUP_RETENTION=12
```

**CI/CD Environment:**
```bash
# Fast and automated
export CLAUDE_CI_MODE=true
export CLAUDE_MERGE_BACKUP=false
export CLAUDE_CACHE_STRATEGY=aggressive
export CLAUDE_LOG_LEVEL=error
export CLAUDE_TIMEOUT=300
```

### Security Considerations

1. **Principle of Least Privilege:**
   - Use `CLAUDE_ALLOWED_PATHS` to restrict file access
   - Limit `CLAUDE_EXTERNAL_TOOLS` to necessary tools only
   - Enable `CLAUDE_SECURE_MODE` in production

2. **Audit and Monitoring:**
   - Enable `CLAUDE_AUDIT_LOG` for compliance
   - Use structured logging with `CLAUDE_LOG_FORMAT=json`
   - Monitor log files for security events

3. **Credential Management:**
   - Store `CLAUDE_LICENSE_KEY` in secure credential store
   - Use environment-specific service accounts
   - Rotate credentials regularly

4. **Network Security:**
   - Use HTTPS for `CLAUDE_CONFIG_SERVER`
   - Validate SSL certificates
   - Consider network restrictions for external tools

### Performance Optimization

1. **Resource Management:**
   ```bash
   # Optimize for available resources
   export CLAUDE_AGENT_LIMIT=$(nproc)
   export CLAUDE_PARALLEL_LIMIT=$(($(nproc) * 2))
   export CLAUDE_MEMORY_LIMIT="$(awk '/MemTotal/ {print int($2/1024/1024)}' /proc/meminfo)G"
   ```

2. **Caching Strategy:**
   ```bash
   # Development: Conservative caching
   export CLAUDE_CACHE_STRATEGY=conservative
   export CLAUDE_CACHE_TTL=1800
   
   # Production: Aggressive caching
   export CLAUDE_CACHE_STRATEGY=aggressive
   export CLAUDE_CACHE_TTL=7200
   ```

3. **I/O Optimization:**
   ```bash
   # Use fast storage for cache
   export CLAUDE_CACHE_DIR="/tmp/claude-cache"
   
   # Limit disk cache size
   export CLAUDE_DISK_CACHE_SIZE="500M"
   ```

### Troubleshooting Configuration

1. **Validation Issues:**
   ```bash
   # Check configuration
   claude --validate-config
   
   # Show effective configuration
   claude --show-config
   
   # Test specific variable
   claude --test-var=CLAUDE_TEMPLATES_DIR
   ```

2. **Debug Configuration Loading:**
   ```bash
   # Trace configuration loading
   export CLAUDE_DEBUG_CONFIG=true
   claude architect
   ```

3. **Override for Testing:**
   ```bash
   # Temporary override for testing
   CLAUDE_LOG_LEVEL=debug claude --dry-run architect
   ```

## Troubleshooting

### Common Configuration Issues

**Environment Variable Not Recognized:**
```bash
# Check if variable is set
echo $CLAUDE_TEMPLATES_DIR

# Verify variable name (case-sensitive)
env | grep CLAUDE_

# Check for typos in variable names
claude --validate-config
```

**Invalid Path Configuration:**
```bash
# Verify path exists and is accessible
ls -la $CLAUDE_TEMPLATES_DIR
ls -la $CLAUDE_CONFIG_DIR

# Check permissions
test -r $CLAUDE_TEMPLATES_DIR && echo "Readable" || echo "Not readable"
test -w $CLAUDE_CACHE_DIR && echo "Writable" || echo "Not writable"
```

**Resource Limit Issues:**
```bash
# Check memory usage
free -h

# Verify agent limits
echo "Agent limit: $CLAUDE_AGENT_LIMIT"
echo "CPU cores: $(nproc)"

# Monitor resource usage
claude --monitor-resources architect
```

**Template Resolution Problems:**
```bash
# Debug template search path
export CLAUDE_DEBUG_TEMPLATES=true
claude architect

# Check template hierarchy
claude --show-templates

# Validate specific template
claude --validate-template=architect
```

**Performance Issues:**
```bash
# Profile command execution
export CLAUDE_PROFILE_COMMANDS=true
claude architect

# Check cache effectiveness
claude --cache-stats

# Monitor agent coordination
export CLAUDE_DEBUG_AGENTS=true
claude milestone/execute
```

### Configuration Validation

```bash
# Comprehensive configuration check
claude --doctor

# Validate specific configuration file
claude --validate-config=/path/to/config.yaml

# Check environment variable conflicts
claude --check-conflicts

# Show effective configuration
claude --show-effective-config
```

### Debug Environment

```bash
# Complete debug environment
export CLAUDE_DEBUG_CONFIG=true
export CLAUDE_DEBUG_TEMPLATES=true
export CLAUDE_DEBUG_AGENTS=true
export CLAUDE_TRACE_EXECUTION=true
export CLAUDE_LOG_LEVEL=debug
export CLAUDE_VERBOSE_OUTPUT=true

# Run with maximum debugging
claude architect 2>&1 | tee debug.log
```

This document provides a comprehensive reference for configuring Claude Code Enhancer through environment variables. Use these settings to customize behavior for your specific environment and requirements.

For additional configuration options, see:
- [Configuration Files Reference](./configuration-files.md)
- [CLI Reference](./cli-reference.md)
- [Integration APIs](./integration-apis.md)