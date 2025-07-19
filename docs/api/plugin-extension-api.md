# Claude Code Enhancer Plugin/Extension API

Comprehensive reference for creating custom plugins and extensions for Claude Code Enhancer.

## Table of Contents

- [Overview](#overview)
- [Plugin Architecture](#plugin-architecture)
- [Plugin Types](#plugin-types)
- [Plugin Development](#plugin-development)
- [Command Extensions](#command-extensions)
- [Template Extensions](#template-extensions)
- [Quality Gate Extensions](#quality-gate-extensions)
- [Integration Extensions](#integration-extensions)
- [Plugin Configuration](#plugin-configuration)
- [Plugin Lifecycle](#plugin-lifecycle)
- [Plugin Distribution](#plugin-distribution)
- [Plugin Security](#plugin-security)
- [Testing Plugins](#testing-plugins)
- [Best Practices](#best-practices)

## Overview

The Claude Code Enhancer plugin system provides a powerful extensibility framework that allows developers to create custom commands, quality gates, templates, and integrations while maintaining system stability and security.

### Plugin System Architecture

```
┌─────────────────────────────────────────────┐
│             Plugin Manager                  │
├─────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐          │
│  │   Command   │  │  Template   │          │
│  │  Plugins    │  │  Plugins    │          │
│  └─────────────┘  └─────────────┘          │
│  ┌─────────────┐  ┌─────────────┐          │
│  │   Quality   │  │ Integration │          │
│  │   Plugins   │  │   Plugins   │          │
│  └─────────────┘  └─────────────┘          │
├─────────────────────────────────────────────┤
│              Security Layer                 │
├─────────────────────────────────────────────┤
│             Claude Core Engine              │
└─────────────────────────────────────────────┘
```

### Key Features

| Feature | Description | Benefits |
|---------|-------------|----------|
| **Hot Loading** | Plugins loaded dynamically without restart | Seamless development workflow |
| **Sandboxing** | Isolated execution environment | Security and stability |
| **Dependency Management** | Automatic plugin dependency resolution | Simplified installation |
| **Versioning** | Semantic versioning and compatibility checks | Reliable updates |
| **Configuration** | Flexible plugin configuration system | Customizable behavior |

## Plugin Architecture

### Plugin Structure

```
my-plugin/
├── plugin.yaml                 # Plugin manifest
├── src/
│   ├── commands/               # Custom commands
│   │   ├── my-command.md
│   │   └── my-command.sh
│   ├── templates/              # Custom templates
│   │   ├── template.yaml
│   │   └── files/
│   ├── quality/                # Quality gates
│   │   ├── my-gate.js
│   │   └── config.yaml
│   └── integrations/           # External integrations
│       ├── my-service.py
│       └── config.json
├── tests/                      # Plugin tests
│   ├── commands/
│   ├── templates/
│   └── integration/
├── docs/                       # Documentation
│   ├── README.md
│   ├── API.md
│   └── examples/
├── scripts/                    # Installation/setup scripts
│   ├── install.sh
│   ├── uninstall.sh
│   └── setup.py
└── package.json               # Node.js dependencies (if needed)
```

### Plugin Manifest

```yaml
# plugin.yaml
plugin:
  name: "My Awesome Plugin"
  id: "my-awesome-plugin"
  version: "1.2.0"
  description: "Enhanced functionality for Claude Code Enhancer"
  
  # Author information
  author:
    name: "John Developer"
    email: "john@example.com"
    url: "https://github.com/john/my-awesome-plugin"
    
  # Compatibility requirements
  compatibility:
    claude_version: ">=1.0.0"
    platforms: ["linux", "darwin", "windows"]
    languages: ["javascript", "python", "bash"]
    
  # Plugin dependencies
  dependencies:
    plugins:
      - id: "base-quality-plugin"
        version: ">=1.0.0"
        optional: false
    packages:
      node:
        - name: "eslint"
          version: "^8.0.0"
        - name: "prettier"
          version: "^2.0.0"
      python:
        - name: "black"
          version: ">=22.0.0"
        - name: "flake8"
          version: ">=4.0.0"
      system:
        - name: "git"
          version: ">=2.20.0"
          
  # Plugin capabilities
  provides:
    commands:
      - name: "my-command"
        description: "Custom command implementation"
        category: "development"
      - name: "advanced-analysis"
        description: "Advanced code analysis"
        category: "quality"
        
    templates:
      - name: "react-advanced"
        type: "framework"
        description: "Advanced React application template"
        
    quality_gates:
      - name: "advanced-security"
        description: "Advanced security scanning"
        phase: "verify"
        
    integrations:
      - name: "external-service"
        type: "api"
        description: "External service integration"
        
  # Configuration schema
  configuration:
    type: "object"
    properties:
      api_key:
        type: "string"
        description: "API key for external service"
        sensitive: true
      timeout:
        type: "integer"
        default: 30
        minimum: 5
        maximum: 300
      features:
        type: "array"
        items:
          type: "string"
        default: ["analysis", "reporting"]
        
  # Security permissions
  permissions:
    file_system:
      read: ["src/**", "tests/**", "docs/**"]
      write: ["reports/**", "cache/**"]
    network:
      hosts: ["api.example.com", "*.github.com"]
      ports: [80, 443]
    commands:
      allowed: ["git", "npm", "node", "python"]
      
  # Plugin lifecycle hooks
  lifecycle:
    install:
      script: "scripts/install.sh"
      timeout: 300
    activate:
      script: "scripts/setup.py"
      timeout: 60
    update:
      script: "scripts/update.sh"
      timeout: 180
    deactivate:
      script: "scripts/cleanup.sh"
      timeout: 30
    uninstall:
      script: "scripts/uninstall.sh"
      timeout: 120
      
  # Testing configuration
  testing:
    test_command: "npm test"
    coverage_threshold: 80
    test_timeout: 300
    
  # Documentation
  documentation:
    readme: "docs/README.md"
    api_reference: "docs/API.md"
    examples: "docs/examples/"
    changelog: "CHANGELOG.md"
    
  # Distribution
  distribution:
    registry: "npm"
    package_name: "@myorg/claude-awesome-plugin"
    repository: "https://github.com/myorg/claude-awesome-plugin"
    homepage: "https://myorg.github.io/claude-awesome-plugin"
    
  # License
  license: "MIT"
  keywords: ["claude", "code-enhancer", "development", "quality"]
```

## Plugin Types

### Command Plugins

Command plugins extend Claude with new functionality through custom commands.

#### Basic Command Plugin

```bash
#!/bin/bash
# src/commands/my-command.sh

# Command metadata
# COMMAND_NAME: my-command
# COMMAND_DESCRIPTION: Custom command for enhanced functionality
# COMMAND_VERSION: 1.0.0
# COMMAND_AUTHOR: John Developer

set -euo pipefail

# Source Claude utilities
source "${CLAUDE_PLUGIN_UTILS}/common.sh"

# Plugin configuration
PLUGIN_CONFIG="${CLAUDE_PLUGIN_CONFIG}/my-awesome-plugin.json"

main() {
    plugin_log "info" "Starting my-command execution"
    
    # Load plugin configuration
    local config
    config=$(load_plugin_config) || {
        plugin_error "Failed to load plugin configuration"
        return 1
    }
    
    # Parse command arguments
    local action="${1:-analyze}"
    local target="${2:-.}"
    
    case "$action" in
        "analyze")
            perform_analysis "$target" "$config"
            ;;
        "report")
            generate_report "$target" "$config"
            ;;
        "cleanup")
            cleanup_artifacts "$target"
            ;;
        *)
            show_usage
            return 1
            ;;
    esac
    
    plugin_log "info" "my-command execution completed"
}

load_plugin_config() {
    if [[ -f "$PLUGIN_CONFIG" ]]; then
        jq '.' "$PLUGIN_CONFIG"
    else
        # Return default configuration
        cat <<EOF
{
  "timeout": 30,
  "features": ["analysis", "reporting"],
  "output_format": "json"
}
EOF
    fi
}

perform_analysis() {
    local target="$1"
    local config="$2"
    
    plugin_log "info" "Performing analysis on: $target"
    
    # Get configuration values
    local timeout
    timeout=$(echo "$config" | jq -r '.timeout // 30')
    local features
    features=$(echo "$config" | jq -r '.features[]' | tr '\n' ' ')
    
    # Perform custom analysis
    local results_file="${CLAUDE_CACHE_DIR}/plugins/my-awesome-plugin/results.json"
    mkdir -p "$(dirname "$results_file")"
    
    # Example analysis logic
    {
        echo "{"
        echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
        echo "  \"target\": \"$target\","
        echo "  \"features\": $(echo "$features" | jq -R . | jq -s .),"
        echo "  \"analysis\": {"
        
        # File count analysis
        local file_count
        file_count=$(find "$target" -type f | wc -l)
        echo "    \"file_count\": $file_count,"
        
        # Code complexity (example)
        local complexity_score
        complexity_score=$(calculate_complexity "$target")
        echo "    \"complexity_score\": $complexity_score,"
        
        # Custom metrics
        echo "    \"custom_metrics\": $(calculate_custom_metrics "$target")"
        
        echo "  }"
        echo "}"
    } > "$results_file"
    
    plugin_log "info" "Analysis results saved to: $results_file"
    
    # Emit plugin event
    emit_plugin_event "analysis_completed" "{\"target\": \"$target\", \"results_file\": \"$results_file\"}"
}

calculate_complexity() {
    local target="$1"
    local total_lines
    local complex_files
    
    # Simple complexity calculation
    total_lines=$(find "$target" -name "*.js" -o -name "*.ts" -o -name "*.py" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo 0)
    complex_files=$(find "$target" -name "*.js" -o -name "*.ts" | xargs grep -l "function\|class\|if\|for\|while" 2>/dev/null | wc -l || echo 0)
    
    # Basic complexity score
    local score
    score=$(( (total_lines / 100) + (complex_files * 2) ))
    echo "$score"
}

calculate_custom_metrics() {
    local target="$1"
    
    # Calculate custom metrics
    local test_coverage
    test_coverage=$(calculate_test_coverage "$target")
    
    local dependency_count
    dependency_count=$(count_dependencies "$target")
    
    cat <<EOF
{
  "test_coverage": $test_coverage,
  "dependency_count": $dependency_count,
  "last_modified": "$(stat -c %Y "$target" 2>/dev/null || echo 0)"
}
EOF
}

calculate_test_coverage() {
    local target="$1"
    
    # Simple test coverage calculation
    local src_files
    local test_files
    
    src_files=$(find "$target" -name "*.js" -not -path "*/test*" -not -name "*.test.*" | wc -l)
    test_files=$(find "$target" -name "*.test.*" -o -path "*/test*" -name "*.js" | wc -l)
    
    if [[ $src_files -gt 0 ]]; then
        echo $(( (test_files * 100) / src_files ))
    else
        echo 0
    fi
}

count_dependencies() {
    local target="$1"
    
    # Count dependencies from package.json
    if [[ -f "$target/package.json" ]]; then
        jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys | length' "$target/package.json" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

generate_report() {
    local target="$1"
    local config="$2"
    
    plugin_log "info" "Generating report for: $target"
    
    local results_file="${CLAUDE_CACHE_DIR}/plugins/my-awesome-plugin/results.json"
    local report_file="${CLAUDE_CACHE_DIR}/plugins/my-awesome-plugin/report.html"
    
    if [[ ! -f "$results_file" ]]; then
        plugin_error "No analysis results found. Run analysis first."
        return 1
    fi
    
    # Generate HTML report
    cat > "$report_file" <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>My Awesome Plugin Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .metric { background: #f5f5f5; padding: 10px; margin: 10px 0; }
        .score { font-size: 24px; font-weight: bold; color: #333; }
    </style>
</head>
<body>
    <h1>Analysis Report</h1>
    <h2>Target: $target</h2>
    
    <div class="metric">
        <h3>File Count</h3>
        <div class="score">$(jq -r '.analysis.file_count' "$results_file")</div>
    </div>
    
    <div class="metric">
        <h3>Complexity Score</h3>
        <div class="score">$(jq -r '.analysis.complexity_score' "$results_file")</div>
    </div>
    
    <div class="metric">
        <h3>Test Coverage</h3>
        <div class="score">$(jq -r '.analysis.custom_metrics.test_coverage' "$results_file")%</div>
    </div>
    
    <div class="metric">
        <h3>Dependencies</h3>
        <div class="score">$(jq -r '.analysis.custom_metrics.dependency_count' "$results_file")</div>
    </div>
    
    <p><em>Generated at: $(date)</em></p>
</body>
</html>
EOF
    
    plugin_log "info" "Report generated: $report_file"
    
    # Open report if in interactive mode
    if [[ "${CLAUDE_CI_MODE:-false}" != "true" ]]; then
        open_file "$report_file"
    fi
}

cleanup_artifacts() {
    local target="$1"
    
    plugin_log "info" "Cleaning up plugin artifacts"
    
    local plugin_cache="${CLAUDE_CACHE_DIR}/plugins/my-awesome-plugin"
    
    if [[ -d "$plugin_cache" ]]; then
        rm -rf "$plugin_cache"
        plugin_log "info" "Plugin cache cleaned: $plugin_cache"
    fi
}

show_usage() {
    cat <<EOF
Usage: claude my-command [ACTION] [TARGET]

Actions:
  analyze   Perform analysis on target (default)
  report    Generate HTML report from analysis
  cleanup   Clean up plugin artifacts

Arguments:
  TARGET    Target directory or file (default: current directory)

Examples:
  claude my-command analyze ./src
  claude my-command report ./src
  claude my-command cleanup

EOF
}

# Plugin utilities
plugin_log() {
    local level="$1"
    local message="$2"
    echo "[$(date +%H:%M:%S)] [MY-PLUGIN] [$level] $message" >&2
}

plugin_error() {
    plugin_log "ERROR" "$1"
}

emit_plugin_event() {
    local event_type="$1"
    local event_data="$2"
    
    local event_file="${CLAUDE_CACHE_DIR}/events/plugin_$(date +%s%N).json"
    mkdir -p "$(dirname "$event_file")"
    
    cat > "$event_file" <<EOF
{
  "plugin": "my-awesome-plugin",
  "event_type": "$event_type",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "data": $event_data
}
EOF
}

open_file() {
    local file="$1"
    
    case "$(uname)" in
        "Darwin")
            open "$file"
            ;;
        "Linux")
            xdg-open "$file" 2>/dev/null || echo "Report available at: $file"
            ;;
        *)
            echo "Report available at: $file"
            ;;
    esac
}

# Execute main function
main "$@"
```

#### Command Documentation

```markdown
# src/commands/my-command.md

# My Command

Enhanced analysis and reporting functionality for Claude Code Enhancer.

## Description

The `my-command` plugin provides advanced code analysis capabilities with detailed reporting and custom metrics calculation.

## Usage

```bash
claude my-command [action] [target]
```

## Actions

### analyze (default)
Performs comprehensive analysis on the target directory or file.

```bash
claude my-command analyze ./src
claude my-command ./src  # analyze is default
```

### report
Generates an HTML report from previous analysis results.

```bash
claude my-command report ./src
```

### cleanup
Cleans up plugin artifacts and cache files.

```bash
claude my-command cleanup
```

## Configuration

The plugin can be configured through `.claude/plugins/my-awesome-plugin.json`:

```json
{
  "timeout": 60,
  "features": ["analysis", "reporting", "metrics"],
  "output_format": "json",
  "api_key": "your-api-key-here"
}
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `timeout` | integer | 30 | Analysis timeout in seconds |
| `features` | array | ["analysis", "reporting"] | Enabled features |
| `output_format` | string | "json" | Output format (json, xml, yaml) |
| `api_key` | string | null | API key for external services |

## Examples

### Basic Analysis
```bash
claude my-command analyze
```

### Analysis with Report Generation
```bash
claude my-command analyze ./src
claude my-command report ./src
```

### Configuration Setup
```bash
# Create plugin configuration
mkdir -p .claude/plugins
cat > .claude/plugins/my-awesome-plugin.json <<EOF
{
  "timeout": 120,
  "features": ["analysis", "reporting", "advanced-metrics"],
  "output_format": "json"
}
EOF

# Run analysis with custom configuration
claude my-command analyze
```

## Output

### Analysis Results
The analysis generates a JSON file with comprehensive metrics:

```json
{
  "timestamp": "2024-07-18T10:30:00Z",
  "target": "./src",
  "features": ["analysis", "reporting"],
  "analysis": {
    "file_count": 25,
    "complexity_score": 145,
    "custom_metrics": {
      "test_coverage": 78,
      "dependency_count": 15,
      "last_modified": 1721304600
    }
  }
}
```

### HTML Report
The report command generates a visual HTML report with:
- File count and structure analysis
- Code complexity metrics
- Test coverage statistics
- Dependency analysis
- Trend analysis (if available)

## Integration

### Event Emission
The plugin emits events that can be consumed by other plugins or hooks:

```json
{
  "plugin": "my-awesome-plugin",
  "event_type": "analysis_completed",
  "timestamp": "2024-07-18T10:30:00Z",
  "data": {
    "target": "./src",
    "results_file": "/path/to/results.json"
  }
}
```

### Hook Integration
The plugin integrates with Claude's hook system:

```bash
# Pre-command hook
if plugin_is_installed "my-awesome-plugin"; then
    claude my-command analyze --quick
fi
```

## Troubleshooting

### Common Issues

**Analysis fails with timeout error**
- Increase timeout in plugin configuration
- Check file permissions in target directory
- Verify required dependencies are installed

**Report generation fails**
- Ensure analysis has been run first
- Check write permissions in cache directory
- Verify template files are accessible

**Plugin not found**
- Verify plugin is properly installed
- Check plugin registry: `claude plugin list`
- Reinstall plugin: `claude plugin install my-awesome-plugin`

### Debug Mode
Enable debug logging for troubleshooting:

```bash
CLAUDE_DEBUG_PLUGINS=true claude my-command analyze
```

## API Reference

### Plugin Events
- `analysis_started`: Emitted when analysis begins
- `analysis_completed`: Emitted when analysis finishes
- `report_generated`: Emitted when report is created
- `error_occurred`: Emitted on errors

### Plugin Configuration API
```bash
# Get configuration value
plugin_config_get "timeout"

# Set configuration value
plugin_config_set "timeout" 60

# Validate configuration
plugin_config_validate
```

### Utility Functions
```bash
# Logging
plugin_log "level" "message"
plugin_error "error message"

# Events
emit_plugin_event "event_type" "event_data"

# File operations
plugin_read_file "path"
plugin_write_file "path" "content"
```
```

### Advanced Command Plugin

```python
#!/usr/bin/env python3
"""Advanced Python-based command plugin."""

import json
import os
import sys
import time
import argparse
from pathlib import Path
from typing import Dict, List, Any, Optional

class MyAdvancedCommand:
    """Advanced command implementation."""
    
    def __init__(self):
        self.plugin_id = "my-awesome-plugin"
        self.cache_dir = Path(os.environ.get('CLAUDE_CACHE_DIR', './.claude/cache'))
        self.config_dir = Path(os.environ.get('CLAUDE_CONFIG_DIR', './.claude'))
        self.plugin_cache = self.cache_dir / 'plugins' / self.plugin_id
        self.plugin_config_file = self.config_dir / 'plugins' / f'{self.plugin_id}.json'
        
        # Ensure directories exist
        self.plugin_cache.mkdir(parents=True, exist_ok=True)
        self.plugin_config_file.parent.mkdir(parents=True, exist_ok=True)
        
        # Load configuration
        self.config = self.load_config()
        
    def load_config(self) -> Dict[str, Any]:
        """Load plugin configuration."""
        
        default_config = {
            "timeout": 30,
            "features": ["analysis", "reporting"],
            "output_format": "json",
            "api_key": None,
            "advanced_metrics": True,
            "cache_results": True,
            "parallel_processing": True
        }
        
        if self.plugin_config_file.exists():
            try:
                with open(self.plugin_config_file) as f:
                    user_config = json.load(f)
                default_config.update(user_config)
            except Exception as e:
                self.log("warning", f"Failed to load config: {e}")
        
        return default_config
    
    def log(self, level: str, message: str):
        """Plugin logging."""
        timestamp = time.strftime("%H:%M:%S")
        print(f"[{timestamp}] [MY-ADVANCED-PLUGIN] [{level.upper()}] {message}", file=sys.stderr)
    
    def emit_event(self, event_type: str, event_data: Dict[str, Any]):
        """Emit plugin event."""
        
        event_file = self.cache_dir / 'events' / f'plugin_{int(time.time() * 1000000)}.json'
        event_file.parent.mkdir(parents=True, exist_ok=True)
        
        event = {
            "plugin": self.plugin_id,
            "event_type": event_type,
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "data": event_data
        }
        
        with open(event_file, 'w') as f:
            json.dump(event, f, indent=2)
    
    def analyze(self, target: str, options: Dict[str, Any] = None) -> Dict[str, Any]:
        """Perform advanced analysis."""
        
        self.log("info", f"Starting advanced analysis on: {target}")
        self.emit_event("analysis_started", {"target": target, "options": options})
        
        target_path = Path(target)
        if not target_path.exists():
            raise ValueError(f"Target path does not exist: {target}")
        
        # Initialize analysis result
        analysis_result = {
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "target": str(target_path.absolute()),
            "plugin_version": "1.2.0",
            "options": options or {},
            "analysis": {}
        }
        
        # Perform different types of analysis
        if "file_structure" in self.config["features"]:
            analysis_result["analysis"]["file_structure"] = self.analyze_file_structure(target_path)
        
        if "code_quality" in self.config["features"]:
            analysis_result["analysis"]["code_quality"] = self.analyze_code_quality(target_path)
        
        if "dependencies" in self.config["features"]:
            analysis_result["analysis"]["dependencies"] = self.analyze_dependencies(target_path)
        
        if "security" in self.config["features"]:
            analysis_result["analysis"]["security"] = self.analyze_security(target_path)
        
        if self.config.get("advanced_metrics", False):
            analysis_result["analysis"]["advanced_metrics"] = self.calculate_advanced_metrics(target_path)
        
        # Save results
        if self.config.get("cache_results", True):
            results_file = self.plugin_cache / f"analysis_{int(time.time())}.json"
            with open(results_file, 'w') as f:
                json.dump(analysis_result, f, indent=2)
            analysis_result["results_file"] = str(results_file)
        
        self.log("info", "Advanced analysis completed")
        self.emit_event("analysis_completed", {
            "target": target,
            "results_file": analysis_result.get("results_file"),
            "metrics_count": len(analysis_result["analysis"])
        })
        
        return analysis_result
    
    def analyze_file_structure(self, target_path: Path) -> Dict[str, Any]:
        """Analyze file structure."""
        
        structure = {
            "total_files": 0,
            "total_directories": 0,
            "file_types": {},
            "largest_files": [],
            "directory_depth": 0
        }
        
        if target_path.is_file():
            structure["total_files"] = 1
            file_ext = target_path.suffix.lower()
            structure["file_types"][file_ext] = 1
            structure["largest_files"] = [{
                "path": str(target_path),
                "size": target_path.stat().st_size
            }]
        else:
            # Analyze directory structure
            for root, dirs, files in os.walk(target_path):
                root_path = Path(root)
                
                # Update directory count
                structure["total_directories"] += len(dirs)
                
                # Update file count and types
                for file in files:
                    file_path = root_path / file
                    structure["total_files"] += 1
                    
                    file_ext = file_path.suffix.lower()
                    structure["file_types"][file_ext] = structure["file_types"].get(file_ext, 0) + 1
                    
                    # Track largest files
                    try:
                        file_size = file_path.stat().st_size
                        structure["largest_files"].append({
                            "path": str(file_path.relative_to(target_path)),
                            "size": file_size
                        })
                    except OSError:
                        pass
                
                # Calculate directory depth
                depth = len(root_path.relative_to(target_path).parts)
                structure["directory_depth"] = max(structure["directory_depth"], depth)
            
            # Keep only top 10 largest files
            structure["largest_files"] = sorted(
                structure["largest_files"],
                key=lambda x: x["size"],
                reverse=True
            )[:10]
        
        return structure
    
    def analyze_code_quality(self, target_path: Path) -> Dict[str, Any]:
        """Analyze code quality."""
        
        quality = {
            "lines_of_code": 0,
            "complexity_score": 0,
            "test_coverage": 0,
            "issues": []
        }
        
        # Count lines of code
        code_extensions = {'.py', '.js', '.ts', '.jsx', '.tsx', '.java', '.cpp', '.c', '.go', '.rs'}
        code_files = []
        
        if target_path.is_file() and target_path.suffix in code_extensions:
            code_files = [target_path]
        else:
            for ext in code_extensions:
                code_files.extend(target_path.rglob(f'*{ext}'))
        
        for code_file in code_files:
            try:
                with open(code_file, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                    quality["lines_of_code"] += len([line for line in lines if line.strip()])
                    
                    # Simple complexity calculation
                    complexity_keywords = ['if', 'for', 'while', 'switch', 'case', 'catch', 'function', 'class']
                    for line in lines:
                        for keyword in complexity_keywords:
                            if keyword in line:
                                quality["complexity_score"] += 1
                                
            except Exception as e:
                quality["issues"].append({
                    "file": str(code_file),
                    "type": "read_error",
                    "message": str(e)
                })
        
        # Estimate test coverage
        test_files = []
        for pattern in ['*test*', '*spec*', 'test_*', '*_test.*']:
            test_files.extend(target_path.rglob(pattern))
        
        if quality["lines_of_code"] > 0:
            test_lines = sum(
                len(open(tf, 'r').readlines()) for tf in test_files
                if tf.suffix in code_extensions and tf.exists()
            )
            quality["test_coverage"] = min(100, (test_lines / quality["lines_of_code"]) * 100)
        
        return quality
    
    def analyze_dependencies(self, target_path: Path) -> Dict[str, Any]:
        """Analyze dependencies."""
        
        dependencies = {
            "package_managers": [],
            "dependencies": {},
            "vulnerabilities": [],
            "outdated": []
        }
        
        # Check for package.json (Node.js)
        package_json = target_path / "package.json"
        if package_json.exists():
            dependencies["package_managers"].append("npm")
            try:
                with open(package_json) as f:
                    package_data = json.load(f)
                    deps = package_data.get("dependencies", {})
                    dev_deps = package_data.get("devDependencies", {})
                    dependencies["dependencies"]["npm"] = {
                        "production": len(deps),
                        "development": len(dev_deps),
                        "total": len(deps) + len(dev_deps)
                    }
            except Exception as e:
                dependencies["issues"] = dependencies.get("issues", [])
                dependencies["issues"].append(f"Failed to parse package.json: {e}")
        
        # Check for requirements.txt (Python)
        requirements_txt = target_path / "requirements.txt"
        if requirements_txt.exists():
            dependencies["package_managers"].append("pip")
            try:
                with open(requirements_txt) as f:
                    lines = f.readlines()
                    pip_deps = [line.strip() for line in lines if line.strip() and not line.startswith('#')]
                    dependencies["dependencies"]["pip"] = {
                        "total": len(pip_deps)
                    }
            except Exception as e:
                dependencies["issues"] = dependencies.get("issues", [])
                dependencies["issues"].append(f"Failed to parse requirements.txt: {e}")
        
        # Check for Cargo.toml (Rust)
        cargo_toml = target_path / "Cargo.toml"
        if cargo_toml.exists():
            dependencies["package_managers"].append("cargo")
            # Would parse TOML here in a real implementation
        
        return dependencies
    
    def analyze_security(self, target_path: Path) -> Dict[str, Any]:
        """Analyze security aspects."""
        
        security = {
            "issues": [],
            "risk_level": "low",
            "recommendations": []
        }
        
        # Check for common security issues
        security_patterns = {
            "hardcoded_secrets": [
                r'password\s*=\s*["\'][^"\']+["\']',
                r'api_key\s*=\s*["\'][^"\']+["\']',
                r'secret\s*=\s*["\'][^"\']+["\']'
            ],
            "sql_injection": [
                r'SELECT\s+.*\s+FROM\s+.*\s+WHERE\s+.*\+',
                r'INSERT\s+INTO\s+.*\s+VALUES\s+.*\+'
            ],
            "xss_vulnerability": [
                r'innerHTML\s*=\s*.*\+',
                r'document\.write\s*\(.*\+',
            ]
        }
        
        code_files = []
        code_extensions = {'.py', '.js', '.ts', '.jsx', '.tsx', '.java', '.php', '.rb'}
        
        if target_path.is_file() and target_path.suffix in code_extensions:
            code_files = [target_path]
        else:
            for ext in code_extensions:
                code_files.extend(target_path.rglob(f'*{ext}'))
        
        import re
        
        for code_file in code_files:
            try:
                with open(code_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                    for issue_type, patterns in security_patterns.items():
                        for pattern in patterns:
                            matches = re.finditer(pattern, content, re.IGNORECASE)
                            for match in matches:
                                line_num = content[:match.start()].count('\n') + 1
                                security["issues"].append({
                                    "file": str(code_file.relative_to(target_path)),
                                    "line": line_num,
                                    "type": issue_type,
                                    "match": match.group(),
                                    "severity": "medium"
                                })
                                
            except Exception:
                pass  # Skip files that can't be read
        
        # Determine risk level
        issue_count = len(security["issues"])
        if issue_count == 0:
            security["risk_level"] = "low"
        elif issue_count <= 5:
            security["risk_level"] = "medium"
        else:
            security["risk_level"] = "high"
        
        # Add recommendations
        if security["issues"]:
            security["recommendations"].extend([
                "Review and remove hardcoded secrets",
                "Implement proper input validation",
                "Use parameterized queries to prevent SQL injection",
                "Sanitize user input to prevent XSS attacks"
            ])
        
        return security
    
    def calculate_advanced_metrics(self, target_path: Path) -> Dict[str, Any]:
        """Calculate advanced metrics."""
        
        metrics = {
            "maintainability_index": 0,
            "technical_debt_ratio": 0,
            "code_duplication": 0,
            "cognitive_complexity": 0
        }
        
        # This would implement more sophisticated metrics calculation
        # For now, using simplified versions
        
        # Maintainability index (simplified)
        code_files = list(target_path.rglob('*.py')) + list(target_path.rglob('*.js'))
        if code_files:
            total_lines = 0
            total_complexity = 0
            
            for code_file in code_files:
                try:
                    with open(code_file, 'r') as f:
                        lines = f.readlines()
                        total_lines += len(lines)
                        
                        # Simple complexity calculation
                        complexity = sum(1 for line in lines if any(
                            keyword in line for keyword in ['if', 'for', 'while', 'function', 'class']
                        ))
                        total_complexity += complexity
                except Exception:
                    pass
            
            if total_lines > 0:
                avg_complexity = total_complexity / len(code_files)
                metrics["maintainability_index"] = max(0, 100 - avg_complexity * 2)
                metrics["cognitive_complexity"] = avg_complexity
        
        return metrics
    
    def generate_report(self, analysis_result: Dict[str, Any], format: str = "html") -> str:
        """Generate report from analysis results."""
        
        self.log("info", "Generating advanced report")
        
        if format == "html":
            return self.generate_html_report(analysis_result)
        elif format == "json":
            return self.generate_json_report(analysis_result)
        elif format == "markdown":
            return self.generate_markdown_report(analysis_result)
        else:
            raise ValueError(f"Unsupported report format: {format}")
    
    def generate_html_report(self, analysis_result: Dict[str, Any]) -> str:
        """Generate HTML report."""
        
        report_file = self.plugin_cache / f"report_{int(time.time())}.html"
        
        html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Advanced Analysis Report</title>
    <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }}
        .container {{ max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }}
        .header {{ border-bottom: 2px solid #e9ecef; padding-bottom: 20px; margin-bottom: 30px; }}
        .metric-grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 20px 0; }}
        .metric-card {{ background: #f8f9fa; padding: 20px; border-radius: 6px; border-left: 4px solid #007bff; }}
        .metric-value {{ font-size: 2em; font-weight: bold; color: #495057; }}
        .metric-label {{ color: #6c757d; margin-top: 5px; }}
        .section {{ margin: 30px 0; }}
        .issue {{ background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 4px; padding: 10px; margin: 5px 0; }}
        .issue.high {{ background: #f8d7da; border-color: #f5c6cb; }}
        .issue.medium {{ background: #fff3cd; border-color: #ffeaa7; }}
        .issue.low {{ background: #d1ecf1; border-color: #bee5eb; }}
        table {{ width: 100%; border-collapse: collapse; margin: 15px 0; }}
        th, td {{ padding: 12px; text-align: left; border-bottom: 1px solid #dee2e6; }}
        th {{ background-color: #f8f9fa; font-weight: 600; }}
        .progress {{ background: #e9ecef; border-radius: 4px; height: 20px; overflow: hidden; }}
        .progress-bar {{ background: #28a745; height: 100%; transition: width 0.3s ease; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Advanced Analysis Report</h1>
            <p><strong>Target:</strong> {analysis_result['target']}</p>
            <p><strong>Generated:</strong> {analysis_result['timestamp']}</p>
        </div>
"""
        
        # Add file structure metrics
        if "file_structure" in analysis_result["analysis"]:
            fs = analysis_result["analysis"]["file_structure"]
            html_content += f"""
        <div class="section">
            <h2>File Structure</h2>
            <div class="metric-grid">
                <div class="metric-card">
                    <div class="metric-value">{fs['total_files']}</div>
                    <div class="metric-label">Total Files</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">{fs['total_directories']}</div>
                    <div class="metric-label">Directories</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">{fs['directory_depth']}</div>
                    <div class="metric-label">Max Depth</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">{len(fs['file_types'])}</div>
                    <div class="metric-label">File Types</div>
                </div>
            </div>
        </div>
"""
        
        # Add code quality metrics
        if "code_quality" in analysis_result["analysis"]:
            cq = analysis_result["analysis"]["code_quality"]
            coverage_percent = int(cq.get('test_coverage', 0))
            html_content += f"""
        <div class="section">
            <h2>Code Quality</h2>
            <div class="metric-grid">
                <div class="metric-card">
                    <div class="metric-value">{cq['lines_of_code']:,}</div>
                    <div class="metric-label">Lines of Code</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">{cq['complexity_score']}</div>
                    <div class="metric-label">Complexity Score</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">{coverage_percent}%</div>
                    <div class="metric-label">Test Coverage</div>
                    <div class="progress">
                        <div class="progress-bar" style="width: {coverage_percent}%"></div>
                    </div>
                </div>
            </div>
        </div>
"""
        
        # Add security analysis
        if "security" in analysis_result["analysis"]:
            sec = analysis_result["analysis"]["security"]
            risk_colors = {"low": "#28a745", "medium": "#ffc107", "high": "#dc3545"}
            html_content += f"""
        <div class="section">
            <h2>Security Analysis</h2>
            <div class="metric-card" style="border-left-color: {risk_colors.get(sec['risk_level'], '#6c757d')}">
                <div class="metric-value" style="color: {risk_colors.get(sec['risk_level'], '#6c757d')}">{sec['risk_level'].upper()}</div>
                <div class="metric-label">Risk Level ({len(sec['issues'])} issues found)</div>
            </div>
"""
            
            if sec["issues"]:
                html_content += "<h3>Security Issues</h3>"
                for issue in sec["issues"][:10]:  # Show first 10 issues
                    html_content += f"""
            <div class="issue {issue.get('severity', 'medium')}">
                <strong>{issue['type'].replace('_', ' ').title()}</strong> in {issue['file']} (line {issue['line']})
            </div>
"""
            html_content += "</div>"
        
        html_content += """
        <div class="section">
            <p><em>Report generated by My Awesome Plugin v1.2.0</em></p>
        </div>
    </div>
</body>
</html>
"""
        
        with open(report_file, 'w') as f:
            f.write(html_content)
        
        self.log("info", f"HTML report generated: {report_file}")
        return str(report_file)
    
    def generate_json_report(self, analysis_result: Dict[str, Any]) -> str:
        """Generate JSON report."""
        
        report_file = self.plugin_cache / f"report_{int(time.time())}.json"
        
        with open(report_file, 'w') as f:
            json.dump(analysis_result, f, indent=2)
        
        self.log("info", f"JSON report generated: {report_file}")
        return str(report_file)
    
    def generate_markdown_report(self, analysis_result: Dict[str, Any]) -> str:
        """Generate Markdown report."""
        
        report_file = self.plugin_cache / f"report_{int(time.time())}.md"
        
        md_content = f"""# Advanced Analysis Report

**Target:** {analysis_result['target']}  
**Generated:** {analysis_result['timestamp']}

## Summary

"""
        
        # Add file structure section
        if "file_structure" in analysis_result["analysis"]:
            fs = analysis_result["analysis"]["file_structure"]
            md_content += f"""## File Structure

- **Total Files:** {fs['total_files']:,}
- **Directories:** {fs['total_directories']:,}
- **Max Depth:** {fs['directory_depth']}
- **File Types:** {len(fs['file_types'])}

### File Type Distribution

"""
            for ext, count in sorted(fs['file_types'].items(), key=lambda x: x[1], reverse=True)[:10]:
                md_content += f"- `{ext or 'no extension'}`: {count} files\n"
        
        # Add code quality section
        if "code_quality" in analysis_result["analysis"]:
            cq = analysis_result["analysis"]["code_quality"]
            md_content += f"""
## Code Quality

- **Lines of Code:** {cq['lines_of_code']:,}
- **Complexity Score:** {cq['complexity_score']}
- **Test Coverage:** {cq.get('test_coverage', 0):.1f}%
"""
        
        # Add security section
        if "security" in analysis_result["analysis"]:
            sec = analysis_result["analysis"]["security"]
            md_content += f"""
## Security Analysis

- **Risk Level:** {sec['risk_level'].upper()}
- **Issues Found:** {len(sec['issues'])}

"""
            if sec["issues"]:
                md_content += "### Security Issues\n\n"
                for issue in sec["issues"][:10]:
                    md_content += f"- **{issue['type'].replace('_', ' ').title()}** in `{issue['file']}` (line {issue['line']})\n"
        
        md_content += f"""
---

*Report generated by My Awesome Plugin v1.2.0*
"""
        
        with open(report_file, 'w') as f:
            f.write(md_content)
        
        self.log("info", f"Markdown report generated: {report_file}")
        return str(report_file)

def main():
    """Main command entry point."""
    
    parser = argparse.ArgumentParser(description="Advanced analysis and reporting")
    parser.add_argument("action", choices=["analyze", "report", "cleanup"], 
                       default="analyze", nargs="?", help="Action to perform")
    parser.add_argument("target", default=".", nargs="?", help="Target directory or file")
    parser.add_argument("--format", choices=["html", "json", "markdown"], 
                       default="html", help="Report format")
    parser.add_argument("--features", nargs="+", 
                       choices=["file_structure", "code_quality", "dependencies", "security"],
                       help="Analysis features to enable")
    
    args = parser.parse_args()
    
    try:
        command = MyAdvancedCommand()
        
        if args.action == "analyze":
            options = {}
            if args.features:
                command.config["features"] = args.features
                options["features"] = args.features
            
            result = command.analyze(args.target, options)
            print(json.dumps(result, indent=2))
            
        elif args.action == "report":
            # Load latest analysis result
            analysis_files = list(command.plugin_cache.glob("analysis_*.json"))
            if not analysis_files:
                print("No analysis results found. Run analysis first.", file=sys.stderr)
                sys.exit(1)
            
            latest_file = max(analysis_files, key=lambda f: f.stat().st_mtime)
            with open(latest_file) as f:
                analysis_result = json.load(f)
            
            report_file = command.generate_report(analysis_result, args.format)
            print(f"Report generated: {report_file}")
            
        elif args.action == "cleanup":
            if command.plugin_cache.exists():
                import shutil
                shutil.rmtree(command.plugin_cache)
                command.plugin_cache.mkdir(parents=True, exist_ok=True)
                print("Plugin cache cleaned")
            
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## Quality Gate Extensions

Quality gate plugins extend Claude's quality assurance capabilities.

### Quality Gate Plugin

```javascript
#!/usr/bin/env node
/**
 * Advanced Security Quality Gate Plugin
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

class SecurityQualityGate {
    constructor() {
        this.pluginId = 'advanced-security-gate';
        this.cacheDir = process.env.CLAUDE_CACHE_DIR || './.claude/cache';
        this.configDir = process.env.CLAUDE_CONFIG_DIR || './.claude';
        this.pluginCache = path.join(this.cacheDir, 'plugins', this.pluginId);
        this.configFile = path.join(this.configDir, 'plugins', `${this.pluginId}.json`);
        
        // Ensure directories exist
        this.ensureDirectories();
        
        // Load configuration
        this.config = this.loadConfig();
    }
    
    ensureDirectories() {
        const dirs = [this.pluginCache, path.dirname(this.configFile)];
        dirs.forEach(dir => {
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }
        });
    }
    
    loadConfig() {
        const defaultConfig = {
            enabled_checks: [
                'dependency_vulnerabilities',
                'secret_detection',
                'code_injection',
                'xss_vulnerabilities',
                'insecure_crypto'
            ],
            severity_threshold: 'medium',
            fail_on_findings: true,
            report_format: 'json',
            external_tools: {
                snyk: { enabled: false, token: null },
                semgrep: { enabled: true, config: 'auto' },
                bandit: { enabled: true }
            }
        };
        
        if (fs.existsSync(this.configFile)) {
            try {
                const userConfig = JSON.parse(fs.readFileSync(this.configFile, 'utf8'));
                return { ...defaultConfig, ...userConfig };
            } catch (error) {
                this.log('warning', `Failed to load config: ${error.message}`);
            }
        }
        
        return defaultConfig;
    }
    
    log(level, message) {
        const timestamp = new Date().toTimeString().split(' ')[0];
        console.error(`[${timestamp}] [SECURITY-GATE] [${level.toUpperCase()}] ${message}`);
    }
    
    async execute(target, options = {}) {
        this.log('info', `Starting security quality gate for: ${target}`);
        
        const startTime = Date.now();
        const results = {
            timestamp: new Date().toISOString(),
            target: path.resolve(target),
            plugin_version: '1.0.0',
            gate_results: {},
            overall_status: 'passed',
            execution_time: 0,
            findings_summary: {
                critical: 0,
                high: 0,
                medium: 0,
                low: 0,
                info: 0
            }
        };
        
        try {
            // Run enabled security checks
            for (const check of this.config.enabled_checks) {
                this.log('info', `Running check: ${check}`);
                
                const checkResult = await this.runSecurityCheck(check, target);
                results.gate_results[check] = checkResult;
                
                // Update findings summary
                if (checkResult.findings) {
                    checkResult.findings.forEach(finding => {
                        const severity = finding.severity || 'info';
                        results.findings_summary[severity]++;
                    });
                }
                
                // Check if this check failed
                if (checkResult.status === 'failed') {
                    results.overall_status = 'failed';
                }
            }
            
            // Determine overall status based on severity threshold
            const failureConditions = this.checkFailureConditions(results);
            if (failureConditions.shouldFail) {
                results.overall_status = 'failed';
                results.failure_reason = failureConditions.reason;
            }
            
        } catch (error) {
            this.log('error', `Security gate execution failed: ${error.message}`);
            results.overall_status = 'error';
            results.error = error.message;
        }
        
        results.execution_time = Date.now() - startTime;
        
        // Save results
        const resultsFile = path.join(this.pluginCache, `security-gate-${Date.now()}.json`);
        fs.writeFileSync(resultsFile, JSON.stringify(results, null, 2));
        results.results_file = resultsFile;
        
        // Generate report
        if (this.config.report_format) {
            const reportFile = await this.generateReport(results);
            results.report_file = reportFile;
        }
        
        this.log('info', `Security gate completed: ${results.overall_status}`);
        
        // Emit events
        this.emitEvent('security_gate_completed', {
            target,
            status: results.overall_status,
            findings_count: Object.values(results.findings_summary).reduce((a, b) => a + b, 0),
            results_file: resultsFile
        });
        
        return results;
    }
    
    async runSecurityCheck(checkType, target) {
        const result = {
            check_type: checkType,
            status: 'passed',
            findings: [],
            execution_time: 0,
            tool_info: {}
        };
        
        const startTime = Date.now();
        
        try {
            switch (checkType) {
                case 'dependency_vulnerabilities':
                    await this.checkDependencyVulnerabilities(target, result);
                    break;
                    
                case 'secret_detection':
                    await this.detectSecrets(target, result);
                    break;
                    
                case 'code_injection':
                    await this.checkCodeInjection(target, result);
                    break;
                    
                case 'xss_vulnerabilities':
                    await this.checkXSSVulnerabilities(target, result);
                    break;
                    
                case 'insecure_crypto':
                    await this.checkInsecureCrypto(target, result);
                    break;
                    
                default:
                    result.status = 'skipped';
                    result.message = `Unknown check type: ${checkType}`;
            }
            
        } catch (error) {
            result.status = 'error';
            result.error = error.message;
            this.log('error', `Check ${checkType} failed: ${error.message}`);
        }
        
        result.execution_time = Date.now() - startTime;
        
        // Determine status based on findings
        if (result.findings.length > 0 && result.status === 'passed') {
            const highSeverityFindings = result.findings.filter(f => 
                ['critical', 'high'].includes(f.severity)
            );
            
            if (highSeverityFindings.length > 0) {
                result.status = 'failed';
            }
        }
        
        return result;
    }
    
    async checkDependencyVulnerabilities(target, result) {
        const packageJsonPath = path.join(target, 'package.json');
        const requirementsPath = path.join(target, 'requirements.txt');
        
        // Check Node.js dependencies
        if (fs.existsSync(packageJsonPath)) {
            try {
                // Use npm audit if available
                const auditOutput = execSync('npm audit --json --audit-level=info', {
                    cwd: target,
                    encoding: 'utf8',
                    timeout: 30000
                });
                
                const auditData = JSON.parse(auditOutput);
                
                if (auditData.vulnerabilities) {
                    Object.entries(auditData.vulnerabilities).forEach(([pkg, vuln]) => {
                        result.findings.push({
                            type: 'dependency_vulnerability',
                            severity: this.mapNpmSeverity(vuln.severity),
                            package: pkg,
                            current_version: vuln.via[0]?.range || 'unknown',
                            vulnerable_versions: vuln.range,
                            description: vuln.via[0]?.title || 'Vulnerability detected',
                            cwe: vuln.via[0]?.cwe || [],
                            cvss: vuln.via[0]?.cvss || null,
                            file: 'package.json'
                        });
                    });
                }
                
                result.tool_info.npm_audit = {
                    version: this.getNpmAuditVersion(),
                    vulnerabilities_found: Object.keys(auditData.vulnerabilities || {}).length
                };
                
            } catch (error) {
                result.findings.push({
                    type: 'tool_error',
                    severity: 'info',
                    description: `npm audit failed: ${error.message}`,
                    file: 'package.json'
                });
            }
        }
        
        // Check Python dependencies with safety (if available)
        if (fs.existsSync(requirementsPath)) {
            try {
                const safetyOutput = execSync('safety check --json', {
                    cwd: target,
                    encoding: 'utf8',
                    timeout: 30000
                });
                
                const safetyData = JSON.parse(safetyOutput);
                
                safetyData.forEach(vuln => {
                    result.findings.push({
                        type: 'dependency_vulnerability',
                        severity: 'high', // Safety doesn't provide severity, assume high
                        package: vuln.package,
                        current_version: vuln.installed_version,
                        vulnerable_versions: vuln.spec,
                        description: vuln.advisory,
                        cve: vuln.id,
                        file: 'requirements.txt'
                    });
                });
                
            } catch (error) {
                // Safety might not be installed, skip silently
                this.log('debug', `Safety check skipped: ${error.message}`);
            }
        }
    }
    
    async detectSecrets(target, result) {
        const secretPatterns = [
            {
                name: 'AWS Access Key',
                pattern: /AKIA[0-9A-Z]{16}/g,
                severity: 'critical'
            },
            {
                name: 'Private Key',
                pattern: /-----BEGIN[A-Z ]+PRIVATE KEY-----/g,
                severity: 'critical'
            },
            {
                name: 'Generic API Key',
                pattern: /(?:api[_-]?key|apikey|access[_-]?key)["\s]*[:=]["\s]*([a-zA-Z0-9_-]{16,})/gi,
                severity: 'high'
            },
            {
                name: 'Password in Code',
                pattern: /(?:password|passwd|pwd)["\s]*[:=]["\s]*["']([^"']{8,})["']/gi,
                severity: 'high'
            },
            {
                name: 'Database URL',
                pattern: /(?:mongodb|mysql|postgres|redis):\/\/[^\s"']+/gi,
                severity: 'medium'
            }
        ];
        
        const codeFiles = this.findCodeFiles(target);
        
        for (const filePath of codeFiles) {
            try {
                const content = fs.readFileSync(filePath, 'utf8');
                const lines = content.split('\n');
                
                secretPatterns.forEach(pattern => {
                    let match;
                    while ((match = pattern.pattern.exec(content)) !== null) {
                        const lineNumber = content.substring(0, match.index).split('\n').length;
                        
                        result.findings.push({
                            type: 'secret_detected',
                            severity: pattern.severity,
                            secret_type: pattern.name,
                            file: path.relative(target, filePath),
                            line: lineNumber,
                            column: match.index - content.lastIndexOf('\n', match.index),
                            matched_text: match[0].substring(0, 50) + '...',
                            description: `Potential ${pattern.name} detected in source code`
                        });
                    }
                });
                
            } catch (error) {
                this.log('debug', `Could not scan file ${filePath}: ${error.message}`);
            }
        }
    }
    
    async checkCodeInjection(target, result) {
        const injectionPatterns = [
            {
                name: 'SQL Injection',
                pattern: /(?:SELECT|INSERT|UPDATE|DELETE)[\s\w]*(?:FROM|INTO|SET|WHERE)[\s\w]*["']\s*\+/gi,
                severity: 'high',
                description: 'Potential SQL injection vulnerability'
            },
            {
                name: 'Command Injection',
                pattern: /(?:exec|system|eval|spawn|child_process)[\s(]*["']\s*\+/gi,
                severity: 'critical',
                description: 'Potential command injection vulnerability'
            },
            {
                name: 'Code Injection',
                pattern: /eval\s*\(\s*["']\s*\+/gi,
                severity: 'critical',
                description: 'Potential code injection vulnerability'
            }
        ];
        
        const codeFiles = this.findCodeFiles(target);
        
        for (const filePath of codeFiles) {
            try {
                const content = fs.readFileSync(filePath, 'utf8');
                
                injectionPatterns.forEach(pattern => {
                    let match;
                    while ((match = pattern.pattern.exec(content)) !== null) {
                        const lineNumber = content.substring(0, match.index).split('\n').length;
                        
                        result.findings.push({
                            type: 'code_injection',
                            severity: pattern.severity,
                            injection_type: pattern.name,
                            file: path.relative(target, filePath),
                            line: lineNumber,
                            matched_text: match[0],
                            description: pattern.description
                        });
                    }
                });
                
            } catch (error) {
                this.log('debug', `Could not scan file ${filePath}: ${error.message}`);
            }
        }
    }
    
    async checkXSSVulnerabilities(target, result) {
        const xssPatterns = [
            {
                name: 'innerHTML Assignment',
                pattern: /\.innerHTML\s*=\s*[^"'][^;]*\+/gi,
                severity: 'high'
            },
            {
                name: 'document.write',
                pattern: /document\.write\s*\([^)]*\+[^)]*\)/gi,
                severity: 'high'
            },
            {
                name: 'Unsafe jQuery HTML',
                pattern: /\$\([^)]*\)\.html\s*\([^)]*\+[^)]*\)/gi,
                severity: 'medium'
            }
        ];
        
        const webFiles = this.findWebFiles(target);
        
        for (const filePath of webFiles) {
            try {
                const content = fs.readFileSync(filePath, 'utf8');
                
                xssPatterns.forEach(pattern => {
                    let match;
                    while ((match = pattern.pattern.exec(content)) !== null) {
                        const lineNumber = content.substring(0, match.index).split('\n').length;
                        
                        result.findings.push({
                            type: 'xss_vulnerability',
                            severity: pattern.severity,
                            xss_type: pattern.name,
                            file: path.relative(target, filePath),
                            line: lineNumber,
                            matched_text: match[0],
                            description: `Potential XSS vulnerability: ${pattern.name}`
                        });
                    }
                });
                
            } catch (error) {
                this.log('debug', `Could not scan file ${filePath}: ${error.message}`);
            }
        }
    }
    
    async checkInsecureCrypto(target, result) {
        const cryptoPatterns = [
            {
                name: 'MD5 Usage',
                pattern: /md5\s*\(/gi,
                severity: 'medium',
                description: 'MD5 is cryptographically broken'
            },
            {
                name: 'SHA1 Usage',
                pattern: /sha1\s*\(/gi,
                severity: 'medium',
                description: 'SHA1 is cryptographically weak'
            },
            {
                name: 'Hardcoded Encryption Key',
                pattern: /(?:encrypt|decrypt|cipher)[^{]*[{(][^})]*(["'][\w+/=]{16,}["'])/gi,
                severity: 'high',
                description: 'Hardcoded encryption key detected'
            },
            {
                name: 'Weak Random',
                pattern: /Math\.random\s*\(\s*\)/gi,
                severity: 'low',
                description: 'Math.random() is not cryptographically secure'
            }
        ];
        
        const codeFiles = this.findCodeFiles(target);
        
        for (const filePath of codeFiles) {
            try {
                const content = fs.readFileSync(filePath, 'utf8');
                
                cryptoPatterns.forEach(pattern => {
                    let match;
                    while ((match = pattern.pattern.exec(content)) !== null) {
                        const lineNumber = content.substring(0, match.index).split('\n').length;
                        
                        result.findings.push({
                            type: 'insecure_crypto',
                            severity: pattern.severity,
                            crypto_issue: pattern.name,
                            file: path.relative(target, filePath),
                            line: lineNumber,
                            matched_text: match[0],
                            description: pattern.description
                        });
                    }
                });
                
            } catch (error) {
                this.log('debug', `Could not scan file ${filePath}: ${error.message}`);
            }
        }
    }
    
    findCodeFiles(target) {
        const codeExtensions = ['.js', '.ts', '.jsx', '.tsx', '.py', '.java', '.php', '.rb', '.go', '.rs', '.cpp', '.c'];
        return this.findFilesByExtensions(target, codeExtensions);
    }
    
    findWebFiles(target) {
        const webExtensions = ['.js', '.ts', '.jsx', '.tsx', '.html', '.htm', '.vue'];
        return this.findFilesByExtensions(target, webExtensions);
    }
    
    findFilesByExtensions(target, extensions) {
        const files = [];
        
        const walk = (dir) => {
            try {
                const entries = fs.readdirSync(dir, { withFileTypes: true });
                
                for (const entry of entries) {
                    const fullPath = path.join(dir, entry.name);
                    
                    if (entry.isDirectory()) {
                        // Skip common non-source directories
                        if (!['node_modules', '.git', 'dist', 'build', '__pycache__'].includes(entry.name)) {
                            walk(fullPath);
                        }
                    } else if (entry.isFile()) {
                        const ext = path.extname(entry.name);
                        if (extensions.includes(ext)) {
                            files.push(fullPath);
                        }
                    }
                }
            } catch (error) {
                this.log('debug', `Could not read directory ${dir}: ${error.message}`);
            }
        };
        
        if (fs.statSync(target).isDirectory()) {
            walk(target);
        } else {
            const ext = path.extname(target);
            if (extensions.includes(ext)) {
                files.push(target);
            }
        }
        
        return files;
    }
    
    checkFailureConditions(results) {
        const { findings_summary } = results;
        const threshold = this.config.severity_threshold;
        
        if (!this.config.fail_on_findings) {
            return { shouldFail: false };
        }
        
        let shouldFail = false;
        let reason = '';
        
        switch (threshold) {
            case 'critical':
                if (findings_summary.critical > 0) {
                    shouldFail = true;
                    reason = `${findings_summary.critical} critical security findings`;
                }
                break;
                
            case 'high':
                if (findings_summary.critical > 0 || findings_summary.high > 0) {
                    shouldFail = true;
                    reason = `${findings_summary.critical + findings_summary.high} high+ severity findings`;
                }
                break;
                
            case 'medium':
                if (findings_summary.critical > 0 || findings_summary.high > 0 || findings_summary.medium > 0) {
                    shouldFail = true;
                    reason = `${findings_summary.critical + findings_summary.high + findings_summary.medium} medium+ severity findings`;
                }
                break;
                
            case 'low':
                const totalFindings = Object.values(findings_summary).reduce((a, b) => a + b, 0) - findings_summary.info;
                if (totalFindings > 0) {
                    shouldFail = true;
                    reason = `${totalFindings} security findings`;
                }
                break;
        }
        
        return { shouldFail, reason };
    }
    
    mapNpmSeverity(npmSeverity) {
        const mapping = {
            'critical': 'critical',
            'high': 'high',
            'moderate': 'medium',
            'low': 'low',
            'info': 'info'
        };
        
        return mapping[npmSeverity] || 'info';
    }
    
    getNpmAuditVersion() {
        try {
            const output = execSync('npm --version', { encoding: 'utf8' });
            return output.trim();
        } catch (error) {
            return 'unknown';
        }
    }
    
    async generateReport(results) {
        const reportFile = path.join(this.pluginCache, `security-report-${Date.now()}.${this.config.report_format}`);
        
        if (this.config.report_format === 'json') {
            fs.writeFileSync(reportFile, JSON.stringify(results, null, 2));
        } else if (this.config.report_format === 'html') {
            const htmlContent = this.generateHtmlReport(results);
            fs.writeFileSync(reportFile, htmlContent);
        }
        
        this.log('info', `Security report generated: ${reportFile}`);
        return reportFile;
    }
    
    generateHtmlReport(results) {
        const { findings_summary, gate_results } = results;
        const totalFindings = Object.values(findings_summary).reduce((a, b) => a + b, 0);
        
        return `
<!DOCTYPE html>
<html>
<head>
    <title>Security Analysis Report</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; }
        .header { border-bottom: 2px solid #dee2e6; padding-bottom: 20px; margin-bottom: 30px; }
        .status { padding: 10px; border-radius: 4px; font-weight: bold; }
        .status.passed { background: #d4edda; color: #155724; }
        .status.failed { background: #f8d7da; color: #721c24; }
        .summary { display: grid; grid-template-columns: repeat(5, 1fr); gap: 15px; margin: 20px 0; }
        .metric { text-align: center; padding: 15px; border-radius: 6px; background: #f8f9fa; }
        .metric.critical { background: #f8d7da; }
        .metric.high { background: #fff3cd; }
        .finding { background: #f8f9fa; margin: 10px 0; padding: 15px; border-radius: 4px; border-left: 4px solid #007bff; }
        .finding.critical { border-left-color: #dc3545; }
        .finding.high { border-left-color: #fd7e14; }
        .finding.medium { border-left-color: #ffc107; }
        .finding.low { border-left-color: #28a745; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Security Analysis Report</h1>
        <p><strong>Target:</strong> ${results.target}</p>
        <p><strong>Generated:</strong> ${results.timestamp}</p>
        <div class="status ${results.overall_status}">
            Overall Status: ${results.overall_status.toUpperCase()}
        </div>
    </div>
    
    <h2>Findings Summary</h2>
    <div class="summary">
        <div class="metric critical">
            <div style="font-size: 2em;">${findings_summary.critical}</div>
            <div>Critical</div>
        </div>
        <div class="metric high">
            <div style="font-size: 2em;">${findings_summary.high}</div>
            <div>High</div>
        </div>
        <div class="metric">
            <div style="font-size: 2em;">${findings_summary.medium}</div>
            <div>Medium</div>
        </div>
        <div class="metric">
            <div style="font-size: 2em;">${findings_summary.low}</div>
            <div>Low</div>
        </div>
        <div class="metric">
            <div style="font-size: 2em;">${totalFindings}</div>
            <div>Total</div>
        </div>
    </div>
    
    <h2>Security Findings</h2>
    ${Object.values(gate_results).map(gate => 
        gate.findings.map(finding => `
        <div class="finding ${finding.severity}">
            <h4>${finding.type.replace(/_/g, ' ').toUpperCase()}</h4>
            <p><strong>Severity:</strong> ${finding.severity}</p>
            <p><strong>File:</strong> ${finding.file} ${finding.line ? `(line ${finding.line})` : ''}</p>
            <p><strong>Description:</strong> ${finding.description}</p>
            ${finding.matched_text ? `<p><strong>Code:</strong> <code>${finding.matched_text}</code></p>` : ''}
        </div>
        `).join('')
    ).join('')}
    
    <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #dee2e6; color: #6c757d;">
        <p><em>Report generated by Advanced Security Gate v1.0.0</em></p>
        <p><em>Execution time: ${results.execution_time}ms</em></p>
    </div>
</body>
</html>
        `;
    }
    
    emitEvent(eventType, eventData) {
        const eventFile = path.join(this.cacheDir, 'events', `security_${Date.now()}.json`);
        const eventDir = path.dirname(eventFile);
        
        if (!fs.existsSync(eventDir)) {
            fs.mkdirSync(eventDir, { recursive: true });
        }
        
        const event = {
            plugin: this.pluginId,
            event_type: eventType,
            timestamp: new Date().toISOString(),
            data: eventData
        };
        
        fs.writeFileSync(eventFile, JSON.stringify(event, null, 2));
    }
}

// Main execution
async function main() {
    const target = process.argv[2] || '.';
    const options = {};
    
    const gate = new SecurityQualityGate();
    
    try {
        const results = await gate.execute(target, options);
        
        // Output results
        console.log(JSON.stringify(results, null, 2));
        
        // Exit with appropriate code
        if (results.overall_status === 'failed') {
            process.exit(1);
        } else if (results.overall_status === 'error') {
            process.exit(2);
        }
        
    } catch (error) {
        console.error(`Security gate error: ${error.message}`);
        process.exit(2);
    }
}

if (require.main === module) {
    main();
}

module.exports = SecurityQualityGate;
```

## Best Practices

### Plugin Development Guidelines

1. **Security First**
   ```javascript
   // Always validate inputs
   function validateInput(input) {
       if (typeof input !== 'string') {
           throw new Error('Invalid input type');
       }
       
       // Sanitize paths
       const normalizedPath = path.normalize(input);
       if (normalizedPath.includes('..')) {
           throw new Error('Path traversal not allowed');
       }
       
       return normalizedPath;
   }
   ```

2. **Error Handling**
   ```python
   def robust_operation(file_path):
       try:
           with open(file_path, 'r') as f:
               return f.read()
       except FileNotFoundError:
           logger.warning(f"File not found: {file_path}")
           return None
       except PermissionError:
           logger.error(f"Permission denied: {file_path}")
           return None
       except Exception as e:
           logger.error(f"Unexpected error reading {file_path}: {e}")
           return None
   ```

3. **Resource Management**
   ```bash
   # Always clean up resources
   cleanup_plugin_resources() {
       local temp_files=($(find "$PLUGIN_TEMP_DIR" -name "*.tmp" 2>/dev/null))
       
       for temp_file in "${temp_files[@]}"; do
           rm -f "$temp_file"
       done
       
       # Kill background processes
       if [[ -n "$PLUGIN_BACKGROUND_PIDS" ]]; then
           kill $PLUGIN_BACKGROUND_PIDS 2>/dev/null || true
       fi
   }
   
   # Set up cleanup trap
   trap cleanup_plugin_resources EXIT
   ```

4. **Configuration Management**
   ```yaml
   # Use proper configuration validation
   plugin:
     configuration:
       type: "object"
       required: ["api_key"]
       properties:
         api_key:
           type: "string"
           minLength: 10
           pattern: "^[a-zA-Z0-9_-]+$"
         timeout:
           type: "integer"
           minimum: 1
           maximum: 3600
           default: 30
   ```

### Performance Guidelines

1. **Efficient File Processing**
   ```python
   def process_files_efficiently(file_paths):
       """Process files with proper batching and memory management."""
       
       batch_size = 10
       results = []
       
       for i in range(0, len(file_paths), batch_size):
           batch = file_paths[i:i + batch_size]
           
           # Process batch
           batch_results = []
           for file_path in batch:
               try:
                   result = process_single_file(file_path)
                   batch_results.append(result)
               except Exception as e:
                   logger.warning(f"Failed to process {file_path}: {e}")
           
           results.extend(batch_results)
           
           # Yield control to prevent blocking
           time.sleep(0.001)
       
       return results
   ```

2. **Caching Strategy**
   ```javascript
   class PluginCache {
       constructor(cacheDir, ttl = 3600) {
           this.cacheDir = cacheDir;
           this.ttl = ttl;
           this.memoryCache = new Map();
       }
       
       get(key) {
           // Check memory cache first
           if (this.memoryCache.has(key)) {
               const { data, timestamp } = this.memoryCache.get(key);
               if (Date.now() - timestamp < this.ttl * 1000) {
                   return data;
               }
               this.memoryCache.delete(key);
           }
           
           // Check disk cache
           const cacheFile = path.join(this.cacheDir, `${key}.json`);
           if (fs.existsSync(cacheFile)) {
               const stat = fs.statSync(cacheFile);
               if (Date.now() - stat.mtime.getTime() < this.ttl * 1000) {
                   const data = JSON.parse(fs.readFileSync(cacheFile, 'utf8'));
                   this.memoryCache.set(key, { data, timestamp: Date.now() });
                   return data;
               }
           }
           
           return null;
       }
       
       set(key, data) {
           // Store in memory cache
           this.memoryCache.set(key, { data, timestamp: Date.now() });
           
           // Store in disk cache
           const cacheFile = path.join(this.cacheDir, `${key}.json`);
           fs.writeFileSync(cacheFile, JSON.stringify(data, null, 2));
       }
   }
   ```

This comprehensive Plugin/Extension API documentation provides everything needed to create powerful, secure, and efficient plugins for Claude Code Enhancer, extending its capabilities while maintaining system stability and performance.