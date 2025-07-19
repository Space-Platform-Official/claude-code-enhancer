# Claude Code Enhancer Template API

Comprehensive reference for creating, customizing, and distributing Claude Code Enhancer templates.

## Table of Contents

- [Overview](#overview)
- [Template Structure](#template-structure)
- [Template Syntax](#template-syntax)
- [Template Inheritance](#template-inheritance)
- [Template Variables](#template-variables)
- [Template Functions](#template-functions)
- [Template Validation](#template-validation)
- [Template Distribution](#template-distribution)
- [Custom Templates](#custom-templates)
- [Template Testing](#template-testing)
- [Template Marketplace](#template-marketplace)
- [Migration Guide](#migration-guide)
- [Best Practices](#best-practices)

## Overview

The Claude Code Enhancer template system provides a powerful and flexible way to standardize development workflows across projects and teams. Templates define project structure, configuration, and automation rules.

### Template Types

| Type | Purpose | Scope | Examples |
|------|---------|-------|----------|
| **Base Templates** | Foundation configuration | Core system | CLAUDE.md base |
| **Language Templates** | Language-specific rules | Programming language | JavaScript, Python, Go |
| **Framework Templates** | Framework conventions | Development framework | React, Express, Django |
| **Command Templates** | Automation workflows | Command definition | quality/verify, git/commit |
| **Project Templates** | Complete project setup | Project initialization | web-app, api-service |

### Template Hierarchy

```
templates/
├── base/                    # Foundation templates
│   └── CLAUDE.md
├── languages/              # Language-specific templates
│   ├── javascript/
│   ├── typescript/
│   ├── python/
│   └── go/
├── frameworks/             # Framework templates
│   ├── react/
│   ├── nextjs/
│   ├── express/
│   └── django/
├── commands/               # Command templates
│   ├── quality/
│   ├── git/
│   └── test/
└── projects/              # Complete project templates
    ├── web-application/
    ├── api-service/
    └── microservice/
```

## Template Structure

### Basic Template Directory

```
template-name/
├── template.yaml           # Template metadata
├── CLAUDE.md              # Main configuration template
├── config.yaml            # System configuration
├── files/                 # Template files
│   ├── src/
│   │   └── index.js.template
│   ├── package.json.template
│   └── README.md.template
├── hooks/                 # Template-specific hooks
│   ├── pre-generate.sh
│   └── post-generate.sh
└── tests/                 # Template tests
    └── template.test.js
```

### Template Metadata (`template.yaml`)

```yaml
# Template metadata and configuration
template:
  name: "React TypeScript Application"
  version: "2.1.0"
  description: "Modern React application with TypeScript and best practices"
  
  # Template classification
  type: "framework"        # base|language|framework|command|project
  category: "react"
  tags: ["react", "typescript", "web", "frontend"]
  
  # Compatibility requirements
  requires:
    claude_version: ">=1.0.0"
    languages: ["typescript", "javascript"]
    frameworks: ["react"]
    
  # Template inheritance
  extends: 
    - "languages/typescript"
    - "base/web-application"
    
  # Template parameters
  parameters:
    app_name:
      type: "string"
      required: true
      description: "Application name"
      pattern: "^[a-z][a-z0-9-]*$"
      
    use_router:
      type: "boolean"
      default: true
      description: "Include React Router"
      
    ui_framework:
      type: "enum"
      values: ["material-ui", "chakra-ui", "tailwind", "styled-components"]
      default: "material-ui"
      description: "UI framework to use"
      
    testing_framework:
      type: "enum"
      values: ["jest", "vitest", "playwright"]
      default: "jest"
      description: "Testing framework"
      
  # File generation rules
  files:
    - src: "package.json.template"
      dest: "package.json"
      condition: "always"
      
    - src: "src/App.tsx.template"
      dest: "src/App.tsx"
      condition: "always"
      
    - src: "src/Router.tsx.template"
      dest: "src/Router.tsx"
      condition: "use_router === true"
      
    - src: "src/components/{{ component_name }}.tsx.template"
      dest: "src/components/{{ component_name }}.tsx"
      condition: "components"
      multiple: true
      
  # Directory creation
  directories:
    - "src/components"
    - "src/hooks"
    - "src/utils"
    - "public"
    - "tests"
    
  # Post-generation hooks
  hooks:
    post_generate:
      - command: "npm install"
        condition: "install_dependencies === true"
      - command: "npm run format"
        condition: "auto_format === true"
      - command: "git init"
        condition: "init_git === true"
        
  # Template-specific configuration
  config:
    auto_format: true
    install_dependencies: true
    init_git: false
    
  # Documentation
  documentation:
    readme: "README.md"
    changelog: "CHANGELOG.md"
    examples: "examples/"
    
  # Author and licensing
  author:
    name: "Claude Code Enhancer Team"
    email: "templates@claude.ai"
    
  license: "MIT"
  repository: "https://github.com/claude-ai/templates"
```

## Template Syntax

### Template Engine

Claude Code Enhancer uses a Jinja2-inspired template engine with extensions for code generation.

### Basic Syntax

```jinja2
{# This is a comment #}

{# Variable substitution #}
{{ variable_name }}
{{ object.property }}
{{ array[0] }}

{# Conditional blocks #}
{% if condition %}
  Content when true
{% elif other_condition %}
  Content when other_condition is true
{% else %}
  Content when false
{% endif %}

{# Loops #}
{% for item in items %}
  {{ item.name }}: {{ item.value }}
{% endfor %}

{# Include other templates #}
{% include "common/header.template" %}

{# Extend base templates #}
{% extends "base/component.template" %}

{# Define blocks #}
{% block content %}
  Block content here
{% endblock %}
```

### Advanced Template Features

#### Filters

```jinja2
{# String filters #}
{{ app_name | title }}               # MyApp
{{ app_name | upper }}               # MYAPP  
{{ app_name | lower }}               # myapp
{{ app_name | slug }}                # my-app
{{ app_name | camel_case }}          # myApp
{{ app_name | pascal_case }}         # MyApp
{{ app_name | snake_case }}          # my_app

{# List filters #}
{{ languages | join(", ") }}         # "javascript, typescript"
{{ dependencies | sort }}            # Sorted array
{{ dependencies | unique }}          # Remove duplicates

{# Conditional filters #}
{{ value | default("fallback") }}    # Use fallback if value is empty
{{ path | absolute }}                # Convert to absolute path
{{ url | safe }}                     # Mark as safe HTML
```

#### Functions

```jinja2
{# File system functions #}
{{ file_exists("package.json") }}    # true/false
{{ dir_exists("src") }}              # true/false
{{ read_file("config.json") }}       # File contents

{# Template functions #}
{{ render_template("component.tsx", {"name": "Button"}) }}
{{ include_if_exists("optional.template") }}

{# Utility functions #}
{{ current_date() }}                 # 2024-07-18
{{ current_timestamp() }}            # 1721318400
{{ uuid() }}                         # Generate UUID
{{ random_string(8) }}               # Random string

{# Project analysis functions #}
{{ detect_language() }}              # Detected primary language
{{ detect_framework() }}             # Detected framework
{{ get_dependencies() }}             # List of dependencies
```

### Template File Examples

#### Package.json Template

```json
{
  "name": "{{ app_name }}",
  "version": "{{ version | default('1.0.0') }}",
  "description": "{{ description | default('Claude-generated application') }}",
  "main": "{{ entry_point | default('index.js') }}",
  "scripts": {
    {% if use_typescript %}
    "build": "tsc",
    "dev": "ts-node src/index.ts",
    {% else %}
    "dev": "node src/index.js",
    {% endif %}
    "test": "{{ testing_framework }} {% if testing_framework == 'jest' %}--coverage{% endif %}",
    "lint": "eslint {% if use_typescript %}--ext .ts,.tsx{% else %}--ext .js,.jsx{% endif %} src/",
    "format": "prettier --write src/"
  },
  "dependencies": {
    {% for dep in dependencies %}
    "{{ dep.name }}": "{{ dep.version }}"{% if not loop.last %},{% endif %}
    {% endfor %}
  },
  "devDependencies": {
    {% for dep in dev_dependencies %}
    "{{ dep.name }}": "{{ dep.version }}"{% if not loop.last %},{% endif %}
    {% endfor %}
  }
}
```

#### React Component Template

```tsx
{# src/components/Component.tsx.template #}
{% if use_typescript %}
import React{% if use_hooks %}, { useState, useEffect }{% endif %} from 'react';
{% if ui_framework == 'material-ui' %}
import { Box, Typography } from '@mui/material';
{% elif ui_framework == 'chakra-ui' %}
import { Box, Text } from '@chakra-ui/react';
{% endif %}

interface {{ component_name }}Props {
  title?: string;
  {% for prop in component_props %}
  {{ prop.name }}{% if not prop.required %}?{% endif %}: {{ prop.type }};
  {% endfor %}
}

const {{ component_name }}: React.FC<{{ component_name }}Props> = ({
  title = "{{ component_name }}",
  {% for prop in component_props %}
  {{ prop.name }}{% if prop.default %} = {{ prop.default }}{% endif %},
  {% endfor %}
}) => {
  {% if use_hooks %}
  const [state, setState] = useState(null);
  
  useEffect(() => {
    // Component lifecycle logic
  }, []);
  {% endif %}

  return (
    {% if ui_framework == 'material-ui' %}
    <Box>
      <Typography variant="h6">{title}</Typography>
      {/* Component content */}
    </Box>
    {% elif ui_framework == 'chakra-ui' %}
    <Box>
      <Text fontSize="lg">{title}</Text>
      {/* Component content */}
    </Box>
    {% else %}
    <div className="{{ component_name | lower }}">
      <h3>{title}</h3>
      {/* Component content */}
    </div>
    {% endif %}
  );
};

export default {{ component_name }};
{% else %}
import React from 'react';

const {{ component_name }} = ({ title = "{{ component_name }}" }) => {
  return (
    <div className="{{ component_name | lower }}">
      <h3>{title}</h3>
      {/* Component content */}
    </div>
  );
};

export default {{ component_name }};
{% endif %}
```

## Template Inheritance

### Base Template System

Templates can inherit from other templates to promote reuse and consistency.

#### Base Template (`templates/base/web-application/template.yaml`)

```yaml
template:
  name: "Web Application Base"
  type: "base"
  
  parameters:
    app_name:
      type: "string"
      required: true
    
    description:
      type: "string"
      default: "Web application"
      
    author:
      type: "string"
      default: "Developer"
      
  files:
    - src: "README.md.template"
      dest: "README.md"
    - src: ".gitignore.template"
      dest: ".gitignore"
    - src: "LICENSE.template"
      dest: "LICENSE"
```

#### Child Template (`templates/frameworks/react/template.yaml`)

```yaml
template:
  name: "React Application"
  type: "framework"
  
  # Inherit from base template
  extends: ["base/web-application"]
  
  parameters:
    # Additional parameters
    use_router:
      type: "boolean"
      default: true
      
    ui_framework:
      type: "enum"
      values: ["material-ui", "chakra-ui", "tailwind"]
      default: "material-ui"
  
  files:
    # Additional files
    - src: "package.json.template"
      dest: "package.json"
    - src: "src/App.tsx.template"
      dest: "src/App.tsx"
```

### Template Composition

```yaml
# Complex template composition
template:
  name: "Full Stack React Application"
  
  extends:
    - "base/web-application"         # Base structure
    - "languages/typescript"         # TypeScript configuration
    - "frameworks/react"             # React setup
    - "frameworks/express"           # Backend API
    
  # Override specific configurations
  override:
    parameters:
      use_typescript: true
      backend_framework: "express"
      database: "postgresql"
```

## Template Variables

### Built-in Variables

```jinja2
{# Project context #}
{{ project.name }}              # Project name
{{ project.type }}              # Project type
{{ project.version }}           # Project version
{{ project.root }}              # Project root directory

{# Environment context #}
{{ env.user }}                  # Current user
{{ env.home }}                  # Home directory
{{ env.cwd }}                   # Current working directory
{{ env.os }}                    # Operating system

{# Claude context #}
{{ claude.version }}            # Claude version
{{ claude.config_dir }}         # Configuration directory
{{ claude.templates_dir }}      # Templates directory

{# Date/time context #}
{{ now.date }}                  # Current date (YYYY-MM-DD)
{{ now.time }}                  # Current time (HH:MM:SS)
{{ now.timestamp }}             # Unix timestamp
{{ now.iso }}                   # ISO 8601 timestamp

{# Git context (if available) #}
{{ git.branch }}                # Current branch
{{ git.commit }}                # Current commit hash
{{ git.author }}                # Git author name
{{ git.email }}                 # Git author email
```

### Custom Variables

Templates can define and use custom variables:

```yaml
# In template.yaml
parameters:
  custom_config:
    type: "object"
    properties:
      api_endpoint:
        type: "string"
        default: "http://localhost:3000"
      timeout:
        type: "integer"
        default: 5000
```

```jinja2
{# In template files #}
const API_ENDPOINT = "{{ custom_config.api_endpoint }}";
const TIMEOUT = {{ custom_config.timeout }};
```

## Template Functions

### Custom Template Functions

Templates can define custom functions for complex logic:

```python
# functions.py (in template directory)
def generate_component_props(component_type):
    """Generate component properties based on type."""
    base_props = ["className", "children"]
    
    if component_type == "form":
        return base_props + ["onSubmit", "validation"]
    elif component_type == "button":
        return base_props + ["onClick", "disabled", "variant"]
    else:
        return base_props

def calculate_dependencies(frameworks, features):
    """Calculate required dependencies."""
    deps = []
    
    if "react" in frameworks:
        deps.append({"name": "react", "version": "^18.0.0"})
        deps.append({"name": "react-dom", "version": "^18.0.0"})
        
    if "typescript" in features:
        deps.extend([
            {"name": "@types/react", "version": "^18.0.0"},
            {"name": "typescript", "version": "^5.0.0"}
        ])
        
    return deps
```

```jinja2
{# Using custom functions in templates #}
{% set props = generate_component_props(component_type) %}
{% for prop in props %}
  {{ prop }}: any;
{% endfor %}

{% set deps = calculate_dependencies(frameworks, features) %}
"dependencies": {
  {% for dep in deps %}
  "{{ dep.name }}": "{{ dep.version }}"{% if not loop.last %},{% endif %}
  {% endfor %}
}
```

## Template Validation

### Schema Validation

Templates are validated against JSON schemas to ensure consistency and correctness.

#### Template Schema (`schemas/template.json`)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Claude Template Schema",
  "type": "object",
  "required": ["template"],
  "properties": {
    "template": {
      "type": "object",
      "required": ["name", "version", "type"],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1
        },
        "version": {
          "type": "string",
          "pattern": "^\\d+\\.\\d+\\.\\d+$"
        },
        "type": {
          "type": "string",
          "enum": ["base", "language", "framework", "command", "project"]
        },
        "parameters": {
          "type": "object",
          "patternProperties": {
            "^[a-z][a-z0-9_]*$": {
              "type": "object",
              "required": ["type"],
              "properties": {
                "type": {
                  "type": "string",
                  "enum": ["string", "integer", "boolean", "array", "object", "enum"]
                },
                "required": {
                  "type": "boolean",
                  "default": false
                },
                "default": {},
                "description": {
                  "type": "string"
                }
              }
            }
          }
        }
      }
    }
  }
}
```

### Validation Commands

```bash
# Validate template structure
claude template validate ./my-template/

# Validate specific template file
claude template validate template.yaml

# Validate template against schema
claude template validate --schema=template.json

# Test template generation
claude template test ./my-template/ --parameters=test-params.json

# Lint template files
claude template lint ./my-template/
```

## Template Distribution

### Template Packaging

Templates can be packaged and distributed through multiple channels:

#### NPM Package

```json
{
  "name": "@company/claude-react-template",
  "version": "1.0.0",
  "description": "React application template for Claude Code Enhancer",
  "main": "template.yaml",
  "files": [
    "template.yaml",
    "files/",
    "hooks/",
    "schemas/"
  ],
  "keywords": ["claude", "template", "react"],
  "claude": {
    "template": true,
    "type": "framework",
    "category": "react"
  }
}
```

#### Git Repository

```yaml
# .claude-template
template_repository:
  name: "Company React Templates"
  version: "2.1.0"
  templates:
    - name: "react-basic"
      path: "templates/react-basic"
    - name: "react-advanced"
      path: "templates/react-advanced"
  
  install_url: "https://github.com/company/claude-templates.git"
  documentation: "https://docs.company.com/claude-templates"
```

### Template Registry

```bash
# Publish template to registry
claude template publish ./my-template/

# Install template from registry
claude template install @company/react-template

# List available templates
claude template list --registry

# Search templates
claude template search react

# Update template
claude template update @company/react-template

# Remove template
claude template remove @company/react-template
```

## Custom Templates

### Creating Custom Templates

#### Step 1: Initialize Template

```bash
# Create new template
claude template create my-custom-template --type=framework

# Initialize from existing project
claude template init --from-project=./my-react-app
```

#### Step 2: Define Template Structure

```yaml
# template.yaml
template:
  name: "Custom React Template"
  version: "1.0.0"
  type: "framework"
  
  parameters:
    app_name:
      type: "string"
      required: true
    
    features:
      type: "array"
      items:
        type: "string"
        enum: ["routing", "state-management", "testing", "styling"]
      default: ["routing", "testing"]
```

#### Step 3: Create Template Files

```jinja2
{# files/package.json.template #}
{
  "name": "{{ app_name }}",
  "version": "1.0.0",
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
    {% if "routing" in features %},
    "react-router-dom": "^6.0.0"
    {% endif %}
    {% if "state-management" in features %},
    "redux": "^4.0.0",
    "@reduxjs/toolkit": "^1.0.0"
    {% endif %}
  }
}
```

#### Step 4: Add Hooks

```bash
#!/bin/bash
# hooks/post-generate.sh

echo "Setting up project..."

# Install dependencies
npm install

# Initialize git repository
git init

# Create initial commit
git add .
git commit -m "Initial commit from Claude template"

echo "Project setup complete!"
```

### Template Development Workflow

```bash
# 1. Create and develop template
claude template create my-template
cd my-template
# ... develop template files ...

# 2. Test template locally
claude template test . --parameters='{"app_name": "test-app"}'

# 3. Validate template
claude template validate .

# 4. Generate documentation
claude template docs .

# 5. Package template
claude template package .

# 6. Publish template
claude template publish .
```

## Template Testing

### Test Configuration

```yaml
# tests/template.test.yaml
tests:
  - name: "Basic Generation"
    parameters:
      app_name: "test-app"
      use_typescript: true
    
    assertions:
      - file_exists: "package.json"
      - file_exists: "src/App.tsx"
      - file_contains: 
          file: "package.json"
          content: '"typescript"'
      - valid_json: "package.json"
      
  - name: "Without TypeScript"
    parameters:
      app_name: "js-app"
      use_typescript: false
    
    assertions:
      - file_exists: "src/App.js"
      - file_not_exists: "tsconfig.json"
      
  - name: "With Router"
    parameters:
      app_name: "router-app"
      use_router: true
    
    assertions:
      - file_exists: "src/Router.tsx"
      - file_contains:
          file: "package.json"
          content: '"react-router-dom"'
```

### Test Execution

```bash
# Run all template tests
claude template test ./my-template/

# Run specific test
claude template test ./my-template/ --test="Basic Generation"

# Run tests with coverage
claude template test ./my-template/ --coverage

# Generate test report
claude template test ./my-template/ --report=json > test-report.json
```

## Best Practices

### Template Design Principles

1. **Modularity**: Create small, focused templates that can be composed
2. **Flexibility**: Use parameters to customize template behavior
3. **Consistency**: Follow naming conventions and structure patterns
4. **Documentation**: Provide clear documentation and examples
5. **Testing**: Include comprehensive tests for all template variations

### Template Organization

```
templates/
├── _shared/                 # Shared template components
│   ├── gitignore/
│   ├── license/
│   └── readme/
├── base/                   # Foundation templates
├── languages/              # Language-specific templates
├── frameworks/             # Framework templates
├── commands/               # Command templates
└── projects/               # Complete project templates
```

### Parameter Design

```yaml
# Good parameter design
parameters:
  # Use clear, descriptive names
  database_type:
    type: "enum"
    values: ["postgresql", "mysql", "mongodb"]
    default: "postgresql"
    description: "Database system to use"
  
  # Provide sensible defaults
  port:
    type: "integer"
    default: 3000
    minimum: 1000
    maximum: 65535
  
  # Use validation patterns
  service_name:
    type: "string"
    pattern: "^[a-z][a-z0-9-]*$"
    description: "Service name (lowercase, hyphens allowed)"
```

### Template Maintenance

1. **Version Management**: Use semantic versioning for templates
2. **Backward Compatibility**: Maintain compatibility when possible
3. **Deprecation Policy**: Provide migration paths for deprecated features
4. **Regular Updates**: Keep dependencies and practices current
5. **Community Feedback**: Incorporate user feedback and contributions

This comprehensive Template API documentation provides everything needed to create, customize, and distribute powerful templates for the Claude Code Enhancer system.