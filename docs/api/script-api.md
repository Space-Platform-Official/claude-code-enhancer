# Claude Code Enhancer Script API

Comprehensive reference for integrating Claude Code Enhancer into scripts and automation workflows.

## Table of Contents

- [Overview](#overview)
- [Basic Integration](#basic-integration)
- [Command Execution API](#command-execution-api)
- [Configuration API](#configuration-api)
- [Template Management API](#template-management-api)
- [Agent Coordination API](#agent-coordination-api)
- [Quality Gates API](#quality-gates-api)
- [Git Integration API](#git-integration-api)
- [State Management API](#state-management-api)
- [Error Handling](#error-handling)
- [Batch Operations](#batch-operations)
- [CI/CD Integration](#cicd-integration)
- [Enterprise Integration](#enterprise-integration)
- [Best Practices](#best-practices)

## Overview

The Claude Code Enhancer provides multiple interfaces for script integration:

- **Shell Scripts**: Direct command invocation with comprehensive exit codes
- **Node.js Integration**: NPM package for JavaScript/TypeScript projects
- **REST API**: HTTP interface for remote integration
- **WebSocket API**: Real-time communication for interactive applications
- **CLI Wrapper**: Simplified command-line interface for common operations

### Supported Integration Methods

| Method | Use Case | Performance | Complexity |
|--------|----------|-------------|------------|
| Direct CLI | Shell scripts, CI/CD | High | Low |
| Node.js API | JavaScript apps | High | Medium |
| REST API | Remote services | Medium | Medium |
| WebSocket | Real-time apps | High | High |
| Batch API | Bulk operations | Very High | Low |

## Basic Integration

### Shell Script Integration

```bash
#!/bin/bash
# Basic Claude integration script

set -euo pipefail

# Claude configuration
export CLAUDE_CONFIG_DIR="/opt/claude/config"
export CLAUDE_LOG_LEVEL="info"
export CLAUDE_CI_MODE="true"

# Function to run Claude command with error handling
run_claude() {
    local command="$1"
    local timeout="${2:-600}"
    
    echo "Running Claude command: $command"
    
    if timeout "$timeout" claude "$command"; then
        echo "Command completed successfully"
        return 0
    else
        local exit_code=$?
        echo "Command failed with exit code: $exit_code"
        return $exit_code
    fi
}

# Function to check Claude installation
check_claude() {
    if ! command -v claude >/dev/null 2>&1; then
        echo "Error: Claude not found in PATH"
        return 1
    fi
    
    if ! claude --version >/dev/null 2>&1; then
        echo "Error: Claude installation appears corrupted"
        return 1
    fi
    
    echo "Claude installation verified"
    return 0
}

# Main execution
main() {
    # Verify installation
    check_claude || exit 1
    
    # Run architecture analysis
    run_claude "architect" 300 || exit 1
    
    # Run quality checks
    run_claude "quality/verify" 600 || exit 1
    
    # Run tests if quality passes
    run_claude "test/unit" 900 || exit 1
    
    echo "All Claude operations completed successfully"
}

# Execute main function
main "$@"
```

### Node.js Integration

```javascript
// Claude Node.js API integration
const claude = require('@claude/code-enhancer');

class ClaudeIntegration {
    constructor(options = {}) {
        this.config = {
            configDir: options.configDir || './.claude',
            timeout: options.timeout || 600000,
            logLevel: options.logLevel || 'info',
            ...options
        };
        
        this.client = new claude.Client(this.config);
    }
    
    async initialize() {
        try {
            await this.client.connect();
            console.log('Claude client connected');
            return true;
        } catch (error) {
            console.error('Failed to initialize Claude client:', error);
            return false;
        }
    }
    
    async runCommand(command, options = {}) {
        const commandOptions = {
            timeout: options.timeout || this.config.timeout,
            retries: options.retries || 3,
            ...options
        };
        
        try {
            const result = await this.client.execute(command, commandOptions);
            return {
                success: true,
                result: result,
                exitCode: 0
            };
        } catch (error) {
            return {
                success: false,
                error: error.message,
                exitCode: error.code || 1
            };
        }
    }
    
    async runArchitect(projectPath) {
        return await this.runCommand('architect', {
            workingDirectory: projectPath,
            timeout: 300000
        });
    }
    
    async runQualityGates() {
        const commands = [
            'quality/format',
            'quality/cleanup',
            'quality/verify'
        ];
        
        const results = [];
        for (const command of commands) {
            const result = await this.runCommand(command);
            results.push({ command, ...result });
            
            if (!result.success) {
                break; // Stop on first failure
            }
        }
        
        return results;
    }
    
    async close() {
        await this.client.disconnect();
        console.log('Claude client disconnected');
    }
}

// Usage example
async function main() {
    const claude = new ClaudeIntegration({
        configDir: './config/claude',
        logLevel: 'debug'
    });
    
    try {
        await claude.initialize();
        
        // Run architecture analysis
        const architectResult = await claude.runArchitect('./src');
        console.log('Architect result:', architectResult);
        
        // Run quality gates
        const qualityResults = await claude.runQualityGates();
        console.log('Quality results:', qualityResults);
        
    } finally {
        await claude.close();
    }
}

// Export for use as module
module.exports = { ClaudeIntegration, main };
```

### Python Integration

```python
#!/usr/bin/env python3
"""Claude Code Enhancer Python integration."""

import subprocess
import json
import os
import sys
from typing import Dict, List, Optional, Any
from dataclasses import dataclass
import logging

@dataclass
class CommandResult:
    """Result of a Claude command execution."""
    success: bool
    exit_code: int
    stdout: str
    stderr: str
    duration: float

class ClaudeIntegration:
    """Python wrapper for Claude Code Enhancer."""
    
    def __init__(self, 
                 config_dir: str = "./.claude",
                 log_level: str = "info",
                 timeout: int = 600):
        self.config_dir = config_dir
        self.log_level = log_level
        self.timeout = timeout
        self.logger = self._setup_logging()
        
    def _setup_logging(self) -> logging.Logger:
        """Set up logging for the integration."""
        logger = logging.getLogger('claude_integration')
        logger.setLevel(getattr(logging, self.log_level.upper()))
        
        if not logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)
        
        return logger
    
    def check_installation(self) -> bool:
        """Check if Claude is properly installed."""
        try:
            result = subprocess.run(
                ['claude', '--version'],
                capture_output=True,
                text=True,
                timeout=10
            )
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return False
    
    def run_command(self, 
                   command: str, 
                   timeout: Optional[int] = None,
                   env_vars: Optional[Dict[str, str]] = None) -> CommandResult:
        """Execute a Claude command and return the result."""
        
        timeout = timeout or self.timeout
        
        # Prepare environment
        env = os.environ.copy()
        env.update({
            'CLAUDE_CONFIG_DIR': self.config_dir,
            'CLAUDE_LOG_LEVEL': self.log_level,
            'CLAUDE_CI_MODE': 'true'
        })
        
        if env_vars:
            env.update(env_vars)
        
        # Build command
        cmd = ['claude'] + command.split()
        
        self.logger.info(f"Executing command: {' '.join(cmd)}")
        
        import time
        start_time = time.time()
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=timeout,
                env=env
            )
            
            duration = time.time() - start_time
            
            command_result = CommandResult(
                success=result.returncode == 0,
                exit_code=result.returncode,
                stdout=result.stdout,
                stderr=result.stderr,
                duration=duration
            )
            
            if command_result.success:
                self.logger.info(f"Command completed successfully in {duration:.2f}s")
            else:
                self.logger.error(f"Command failed with exit code {result.returncode}")
                self.logger.error(f"Error output: {result.stderr}")
            
            return command_result
            
        except subprocess.TimeoutExpired:
            duration = time.time() - start_time
            self.logger.error(f"Command timed out after {duration:.2f}s")
            
            return CommandResult(
                success=False,
                exit_code=124,  # Timeout exit code
                stdout="",
                stderr=f"Command timed out after {timeout} seconds",
                duration=duration
            )
        
        except Exception as e:
            duration = time.time() - start_time
            self.logger.error(f"Command execution failed: {e}")
            
            return CommandResult(
                success=False,
                exit_code=1,
                stdout="",
                stderr=str(e),
                duration=duration
            )
    
    def run_architect(self, project_path: str = ".") -> CommandResult:
        """Run architecture analysis."""
        return self.run_command(
            "architect", 
            timeout=300,
            env_vars={'CLAUDE_TARGET_DIR': project_path}
        )
    
    def run_quality_gates(self) -> List[CommandResult]:
        """Run complete quality gate pipeline."""
        commands = [
            "quality/format",
            "quality/cleanup", 
            "quality/verify"
        ]
        
        results = []
        for command in commands:
            result = self.run_command(command)
            results.append(result)
            
            if not result.success:
                self.logger.warning(f"Stopping quality pipeline at {command}")
                break
        
        return results
    
    def run_batch_commands(self, commands: List[str]) -> List[CommandResult]:
        """Run multiple commands in sequence."""
        results = []
        
        for command in commands:
            result = self.run_command(command)
            results.append(result)
            
            # Continue on failure but log it
            if not result.success:
                self.logger.warning(f"Command '{command}' failed but continuing batch")
        
        return results

# Example usage
def main():
    """Example integration workflow."""
    claude = ClaudeIntegration(
        config_dir="./config/claude",
        log_level="info"
    )
    
    # Check installation
    if not claude.check_installation():
        print("Error: Claude not properly installed")
        sys.exit(1)
    
    # Run architecture analysis
    print("Running architecture analysis...")
    arch_result = claude.run_architect()
    
    if not arch_result.success:
        print(f"Architecture analysis failed: {arch_result.stderr}")
        sys.exit(arch_result.exit_code)
    
    # Run quality gates
    print("Running quality gates...")
    quality_results = claude.run_quality_gates()
    
    # Check if all quality gates passed
    all_passed = all(result.success for result in quality_results)
    
    if all_passed:
        print("All quality gates passed!")
    else:
        failed_commands = [
            result for result in quality_results 
            if not result.success
        ]
        print(f"Quality gates failed: {len(failed_commands)} commands failed")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## Command Execution API

### Direct Command Execution

```bash
# Basic command execution
claude [GLOBAL_OPTIONS] COMMAND [COMMAND_OPTIONS] [ARGUMENTS]

# Global options
--config-dir DIR      # Configuration directory
--profile PROFILE     # Configuration profile
--timeout SECONDS     # Command timeout
--retry COUNT         # Retry attempts
--log-level LEVEL     # Logging level
--dry-run            # Preview mode
--quiet              # Suppress output
--verbose            # Verbose output
```

### Command Categories

#### Architecture Commands
```bash
# Architecture analysis and planning
claude architect                    # Full architecture analysis
claude architect --focus=database   # Focus on specific area
claude architect --output=json      # JSON output format
claude architect --depth=3          # Analysis depth
```

#### Quality Commands
```bash
# Quality assurance pipeline
claude quality/format               # Code formatting
claude quality/cleanup              # Dead code removal
claude quality/dedupe               # Duplicate detection
claude quality/verify               # Quality verification
claude quality/verify --strict      # Strict mode
```

#### Test Commands
```bash
# Testing pipeline
claude test/unit                    # Unit tests
claude test/integration             # Integration tests
claude test/e2e                     # End-to-end tests
claude test/coverage                # Coverage analysis
claude test/performance             # Performance tests
```

#### Git Commands
```bash
# Git integration
claude git/commit                   # Intelligent commits
claude git/pr                       # Pull request generation
claude git/branch --type=feature    # Branch management
claude git/status                   # Enhanced status
```

### Programmatic Command Execution

#### Bash Function Library

```bash
#!/bin/bash
# Claude function library for shell scripts

# Source this file to use Claude functions
# source /path/to/claude-functions.sh

# Global configuration
CLAUDE_DEFAULT_TIMEOUT=600
CLAUDE_DEFAULT_RETRIES=3
CLAUDE_LOG_PREFIX="[CLAUDE]"

# Utility functions
claude_log() {
    echo "$CLAUDE_LOG_PREFIX $1" >&2
}

claude_error() {
    echo "$CLAUDE_LOG_PREFIX ERROR: $1" >&2
}

claude_success() {
    echo "$CLAUDE_LOG_PREFIX SUCCESS: $1" >&2
}

# Check if Claude is available
claude_available() {
    command -v claude >/dev/null 2>&1
}

# Execute Claude command with error handling
claude_exec() {
    local command="$1"
    local timeout="${2:-$CLAUDE_DEFAULT_TIMEOUT}"
    local retries="${3:-$CLAUDE_DEFAULT_RETRIES}"
    
    if ! claude_available; then
        claude_error "Claude not found in PATH"
        return 127
    fi
    
    local attempt=1
    while [ $attempt -le $retries ]; do
        claude_log "Executing: claude $command (attempt $attempt/$retries)"
        
        if timeout "$timeout" claude $command; then
            claude_success "Command completed: $command"
            return 0
        else
            local exit_code=$?
            claude_error "Command failed with exit code $exit_code: $command"
            
            if [ $attempt -eq $retries ]; then
                return $exit_code
            fi
            
            local delay=$((attempt * 2))
            claude_log "Retrying in $delay seconds..."
            sleep $delay
            attempt=$((attempt + 1))
        fi
    done
}

# High-level command functions
claude_architect() {
    claude_exec "architect" 300 1
}

claude_quality_pipeline() {
    claude_log "Starting quality pipeline"
    
    claude_exec "quality/format" 120 2 || return $?
    claude_exec "quality/cleanup" 180 2 || return $?
    claude_exec "quality/verify" 300 1 || return $?
    
    claude_success "Quality pipeline completed"
}

claude_test_pipeline() {
    claude_log "Starting test pipeline"
    
    claude_exec "test/unit" 600 2 || return $?
    claude_exec "test/integration" 900 1 || return $?
    claude_exec "test/coverage" 300 1 || return $?
    
    claude_success "Test pipeline completed"
}

claude_full_pipeline() {
    claude_log "Starting full CI pipeline"
    
    claude_architect || return $?
    claude_quality_pipeline || return $?
    claude_test_pipeline || return $?
    
    claude_success "Full pipeline completed"
}

# Batch execution with dependency management
claude_batch() {
    local commands=("$@")
    local results=()
    
    for command in "${commands[@]}"; do
        claude_log "Batch executing: $command"
        
        if claude_exec "$command"; then
            results+=("$command:SUCCESS")
        else
            local exit_code=$?
            results+=("$command:FAILED:$exit_code")
            claude_error "Batch execution stopped due to failure"
            return $exit_code
        fi
    done
    
    claude_log "Batch execution completed successfully"
    printf '%s\n' "${results[@]}"
}

# Parallel execution (background jobs)
claude_parallel() {
    local commands=("$@")
    local pids=()
    local results=()
    
    # Start all commands in background
    for command in "${commands[@]}"; do
        (
            if claude_exec "$command"; then
                echo "$command:SUCCESS"
            else
                echo "$command:FAILED:$?"
            fi
        ) &
        pids+=($!)
    done
    
    # Wait for all to complete
    for pid in "${pids[@]}"; do
        wait $pid
    done
    
    claude_success "Parallel execution completed"
}
```

## Configuration API

### Configuration Management

```bash
# Configuration validation
claude --validate-config                    # Validate current config
claude --validate-config=/path/config.yaml  # Validate specific config
claude --show-config                        # Show effective configuration
claude --config-help                        # Configuration help

# Configuration profiles
claude --profile=development architect      # Use development profile
claude --profile=production quality/verify  # Use production profile
claude --list-profiles                      # List available profiles
```

### Programmatic Configuration

#### Shell Configuration

```bash
#!/bin/bash
# Dynamic Claude configuration

# Function to set up Claude environment
setup_claude_env() {
    local env_type="${1:-development}"
    
    case "$env_type" in
        "development")
            export CLAUDE_LOG_LEVEL="debug"
            export CLAUDE_DEV_MODE="true"
            export CLAUDE_CACHE_STRATEGY="conservative"
            export CLAUDE_AGENT_LIMIT="3"
            ;;
        "staging")
            export CLAUDE_LOG_LEVEL="info"
            export CLAUDE_AUDIT_LOG="true"
            export CLAUDE_CACHE_STRATEGY="moderate"
            export CLAUDE_AGENT_LIMIT="5"
            ;;
        "production")
            export CLAUDE_LOG_LEVEL="warn"
            export CLAUDE_SECURE_MODE="true"
            export CLAUDE_AUDIT_LOG="true"
            export CLAUDE_CACHE_STRATEGY="aggressive"
            export CLAUDE_QUALITY_STRICT="true"
            export CLAUDE_AGENT_LIMIT="8"
            ;;
        "ci")
            export CLAUDE_CI_MODE="true"
            export CLAUDE_LOG_LEVEL="error"
            export CLAUDE_TIMEOUT="300"
            export CLAUDE_AGENT_LIMIT="4"
            export CLAUDE_CACHE_STRATEGY="aggressive"
            ;;
    esac
    
    echo "Claude environment configured for: $env_type"
}

# Function to create temporary configuration
create_temp_config() {
    local config_dir="$1"
    local template="$2"
    
    mkdir -p "$config_dir"
    
    cat > "$config_dir/config.yaml" <<EOF
core:
  log_level: "${CLAUDE_LOG_LEVEL:-info}"
  cache_strategy: "${CLAUDE_CACHE_STRATEGY:-moderate}"

behavior:
  agent_limit: ${CLAUDE_AGENT_LIMIT:-5}
  timeout: ${CLAUDE_TIMEOUT:-600}

integration:
  git_integration: ${CLAUDE_GIT_INTEGRATION:-true}
  quality_gates: ${CLAUDE_QUALITY_GATES:-true}

security:
  secure_mode: ${CLAUDE_SECURE_MODE:-false}
  audit_log: ${CLAUDE_AUDIT_LOG:-false}
EOF

    echo "Configuration created at: $config_dir/config.yaml"
}

# Usage example
main() {
    local environment="${1:-development}"
    local temp_config="/tmp/claude-config-$$"
    
    # Set up environment
    setup_claude_env "$environment"
    
    # Create temporary configuration
    create_temp_config "$temp_config"
    
    # Run Claude with custom configuration
    CLAUDE_CONFIG_DIR="$temp_config" claude architect
    
    # Cleanup
    rm -rf "$temp_config"
}
```

## REST API Integration

### API Endpoints

```yaml
# Claude Code Enhancer REST API
base_url: http://localhost:8080/api/v1

endpoints:
  # Command execution
  POST /commands/execute:
    description: Execute Claude command
    payload:
      command: string
      options: object
      timeout: integer
    response:
      success: boolean
      result: object
      exit_code: integer
  
  # Configuration management
  GET /config:
    description: Get current configuration
    response:
      config: object
  
  POST /config:
    description: Update configuration
    payload:
      config: object
  
  # Agent management
  GET /agents:
    description: List active agents
    response:
      agents: array
  
  POST /agents:
    description: Spawn new agent
    payload:
      command: string
      options: object
  
  # Quality gates
  POST /quality/pipeline:
    description: Run quality pipeline
    payload:
      gates: array
      options: object
    response:
      results: array
      overall_score: number
```

### REST API Client Example

```javascript
// REST API client for Claude Code Enhancer
class ClaudeRESTClient {
    constructor(baseUrl = 'http://localhost:8080/api/v1') {
        this.baseUrl = baseUrl;
        this.timeout = 60000; // 60 seconds default
    }
    
    async executeCommand(command, options = {}) {
        const response = await fetch(`${this.baseUrl}/commands/execute`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                command,
                options,
                timeout: options.timeout || this.timeout
            })
        });
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        return await response.json();
    }
    
    async getConfiguration() {
        const response = await fetch(`${this.baseUrl}/config`);
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        return await response.json();
    }
    
    async updateConfiguration(config) {
        const response = await fetch(`${this.baseUrl}/config`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ config })
        });
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        return await response.json();
    }
    
    async runQualityPipeline(gates = ['format', 'cleanup', 'verify'], options = {}) {
        const response = await fetch(`${this.baseUrl}/quality/pipeline`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                gates,
                options
            })
        });
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        return await response.json();
    }
    
    async getAgents() {
        const response = await fetch(`${this.baseUrl}/agents`);
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        return await response.json();
    }
}

// Usage example
async function main() {
    const client = new ClaudeRESTClient();
    
    try {
        // Execute architecture command
        const architectResult = await client.executeCommand('architect', {
            timeout: 300000,
            output: 'json'
        });
        
        console.log('Architect result:', architectResult);
        
        // Run quality pipeline
        const qualityResult = await client.runQualityPipeline();
        
        console.log('Quality pipeline result:', qualityResult);
        
        // Check agents
        const agents = await client.getAgents();
        console.log('Active agents:', agents);
        
    } catch (error) {
        console.error('API error:', error.message);
    }
}
```

## CI/CD Integration

### GitHub Actions Integration

```yaml
# .github/workflows/claude-quality.yml
name: Claude Quality Gates

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  quality:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Claude Code Enhancer
      run: |
        curl -fsSL https://install.claude.ai | bash
        echo "$HOME/.local/bin" >> $GITHUB_PATH
    
    - name: Configure Claude Environment
      env:
        CLAUDE_CI_MODE: true
        CLAUDE_LOG_LEVEL: info
        CLAUDE_QUALITY_STRICT: true
        CLAUDE_TIMEOUT: 600
      run: |
        # Create configuration
        mkdir -p .claude
        cat > .claude/config.yaml <<EOF
        core:
          log_level: "$CLAUDE_LOG_LEVEL"
        behavior:
          timeout: $CLAUDE_TIMEOUT
        integration:
          ci_mode: true
          quality_gates: true
        EOF
    
    - name: Run Architecture Analysis
      run: claude architect --output=json > architecture-report.json
    
    - name: Run Quality Pipeline
      run: |
        claude quality/format --fix
        claude quality/cleanup --aggressive
        claude quality/verify --strict --report=json > quality-report.json
    
    - name: Run Tests
      run: |
        claude test/unit --coverage
        claude test/integration
    
    - name: Upload Reports
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: claude-reports
        path: |
          architecture-report.json
          quality-report.json
          coverage-report.json
    
    - name: Comment PR
      if: github.event_name == 'pull_request'
      uses: actions/github-script@v6
      with:
        script: |
          const fs = require('fs');
          
          // Read quality report
          const qualityReport = JSON.parse(fs.readFileSync('quality-report.json', 'utf8'));
          
          // Create comment
          const comment = `
          ## Claude Quality Report
          
          **Overall Score:** ${qualityReport.overall_score}%
          **Status:** ${qualityReport.passed ? '✅ PASSED' : '❌ FAILED'}
          
          ### Quality Gates
          ${Object.entries(qualityReport.gates).map(([gate, result]) => 
            `- ${result.passed ? '✅' : '❌'} ${gate}: ${result.score}%`
          ).join('\n')}
          `;
          
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: comment
          });
```

### Jenkins Pipeline Integration

```groovy
// Jenkins Pipeline for Claude Code Enhancer
pipeline {
    agent any
    
    environment {
        CLAUDE_CI_MODE = 'true'
        CLAUDE_LOG_LEVEL = 'info'
        CLAUDE_QUALITY_STRICT = 'true'
        CLAUDE_CONFIG_DIR = '.claude'
    }
    
    stages {
        stage('Setup') {
            steps {
                script {
                    // Install Claude if not available
                    sh '''
                        if ! command -v claude >/dev/null 2>&1; then
                            curl -fsSL https://install.claude.ai | bash
                            export PATH="$HOME/.local/bin:$PATH"
                        fi
                        
                        # Verify installation
                        claude --version
                    '''
                }
            }
        }
        
        stage('Configure') {
            steps {
                script {
                    // Create dynamic configuration
                    writeFile file: '.claude/config.yaml', text: """
                        core:
                          log_level: ${env.CLAUDE_LOG_LEVEL}
                        behavior:
                          timeout: 600
                          agent_limit: 4
                        integration:
                          ci_mode: true
                          quality_gates: true
                        quality:
                          strict_mode: ${env.CLAUDE_QUALITY_STRICT}
                    """
                }
            }
        }
        
        stage('Architecture Analysis') {
            steps {
                sh 'claude architect --output=json > architecture-report.json'
                
                script {
                    // Parse and publish results
                    def report = readJSON file: 'architecture-report.json'
                    currentBuild.description = "Architecture Score: ${report.score}%"
                }
            }
        }
        
        stage('Quality Gates') {
            parallel {
                stage('Format') {
                    steps {
                        sh 'claude quality/format --fix'
                    }
                }
                
                stage('Cleanup') {
                    steps {
                        sh 'claude quality/cleanup --aggressive'
                    }
                }
            }
        }
        
        stage('Quality Verification') {
            steps {
                sh 'claude quality/verify --strict --report=json > quality-report.json'
                
                script {
                    def report = readJSON file: 'quality-report.json'
                    
                    if (!report.passed) {
                        error("Quality gates failed with score: ${report.overall_score}%")
                    }
                    
                    echo "Quality gates passed with score: ${report.overall_score}%"
                }
            }
        }
        
        stage('Testing') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'claude test/unit --coverage --report=junit'
                    }
                    post {
                        always {
                            junit 'test-results/unit/*.xml'
                        }
                    }
                }
                
                stage('Integration Tests') {
                    steps {
                        sh 'claude test/integration --report=junit'
                    }
                    post {
                        always {
                            junit 'test-results/integration/*.xml'
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Archive reports
            archiveArtifacts artifacts: '*-report.json', allowEmptyArchive: true
            
            // Publish test results
            publishTestResults testResultsPattern: 'test-results/**/*.xml'
            
            // Publish coverage
            publishCoverage adapters: [
                coberturaAdapter('coverage.xml')
            ], sourceFileResolver: sourceFiles('STORE_LAST_BUILD')
        }
        
        failure {
            script {
                // Send notifications on failure
                def report = readJSON file: 'quality-report.json'
                
                emailext (
                    subject: "Claude Quality Gates Failed - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: """
                        Quality gates failed for build ${env.BUILD_NUMBER}.
                        
                        Overall Score: ${report.overall_score}%
                        
                        Failed Gates:
                        ${report.gates.findAll { !it.value.passed }.collect { 
                            "- ${it.key}: ${it.value.score}%" 
                        }.join('\n')}
                        
                        Build URL: ${env.BUILD_URL}
                    """,
                    to: "${env.CHANGE_AUTHOR_EMAIL}"
                )
            }
        }
    }
}
```

## Best Practices

### Error Handling Best Practices

1. **Always Check Exit Codes**
   ```bash
   if ! claude architect; then
       echo "Architecture analysis failed"
       exit 1
   fi
   ```

2. **Use Timeouts for Long Operations**
   ```bash
   timeout 600 claude test/e2e || {
       echo "E2E tests timed out"
       exit 124
   }
   ```

3. **Implement Retry Logic**
   ```bash
   retry_count=3
   for attempt in $(seq 1 $retry_count); do
       if claude quality/verify; then
           break
       elif [ $attempt -eq $retry_count ]; then
           exit 1
       else
           sleep $((attempt * 2))
       fi
   done
   ```

### Configuration Best Practices

1. **Environment-Specific Configuration**
   ```bash
   # Use different configurations per environment
   export CLAUDE_CONFIG_DIR="/etc/claude/${ENVIRONMENT}"
   export CLAUDE_PROFILE="${ENVIRONMENT}"
   ```

2. **Secure Credential Management**
   ```bash
   # Use environment variables for sensitive data
   export CLAUDE_LICENSE_KEY="${VAULT_CLAUDE_LICENSE}"
   export CLAUDE_CONFIG_SERVER="${VAULT_CONFIG_SERVER}"
   ```

3. **Resource Management**
   ```bash
   # Optimize for available resources
   export CLAUDE_AGENT_LIMIT="$(nproc)"
   export CLAUDE_MEMORY_LIMIT="$(free -m | awk '/^Mem:/{print int($2/1024)}')G"
   ```

### Performance Best Practices

1. **Parallel Execution**
   ```bash
   # Run independent commands in parallel
   claude architect &
   claude docs &
   wait  # Wait for all background jobs
   ```

2. **Caching Strategy**
   ```bash
   # Use aggressive caching in CI
   export CLAUDE_CACHE_STRATEGY="aggressive"
   export CLAUDE_CACHE_TTL="7200"
   ```

3. **Selective Execution**
   ```bash
   # Only run necessary commands based on changes
   if git diff --name-only HEAD~1 | grep -q "\.js$"; then
       claude quality/format
   fi
   ```

### Security Best Practices

1. **Principle of Least Privilege**
   ```bash
   export CLAUDE_ALLOWED_PATHS="/workspace:/tmp"
   export CLAUDE_EXTERNAL_TOOLS="git,npm"
   ```

2. **Audit Logging**
   ```bash
   export CLAUDE_AUDIT_LOG="true"
   export CLAUDE_LOG_FORMAT="json"
   ```

3. **Secure Mode for Production**
   ```bash
   if [ "$ENVIRONMENT" = "production" ]; then
       export CLAUDE_SECURE_MODE="true"
       export CLAUDE_SANDBOX_MODE="true"
   fi
   ```

This comprehensive Script API documentation provides detailed examples and patterns for integrating Claude Code Enhancer into various automation workflows, from simple shell scripts to sophisticated CI/CD pipelines and enterprise applications.