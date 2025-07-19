# Template Development Guide

Comprehensive guide for creating, modifying, and maintaining templates in the Claude Code Enhancer system.

## Template System Overview

### Architecture Philosophy

The Claude Code Enhancer template system is built on **intelligent inheritance and composition** principles:

1. **Hierarchical Inheritance**: Templates inherit from base templates up through specific implementations
2. **Smart Composition**: Multiple templates can be composed to create comprehensive configurations
3. **Progressive Enhancement**: Templates support different complexity levels
4. **Framework Awareness**: Templates adapt to specific development frameworks and patterns

### Template Hierarchy

```
Templates Architecture
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Base Templates                                │
│                    (Core development principles)                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌───────────────────────┐       ┌───────────────────────┐       │
│  │   Language Templates    │       │  Framework Templates   │       │
│  │ (Language-specific     │       │ (Framework-specific    │       │
│  │  patterns & tools)     │       │  patterns & workflows) │       │
│  │                        │       │                        │       │
│  │ • JavaScript/TypeScript │       │ • React/Vue/Angular     │       │
│  │ • Python              │       │ • Django/Flask         │       │
│  │ • Go/Rust/Java        │       │ • Express/Fastify      │       │
│  │ • C/C++/C#            │       │ • Spring/Laravel       │       │
│  └───────────────────────┘       └───────────────────────┘       │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │                     Command Templates                             │ │
│  │                (Workflow and automation patterns)                │ │
│  │                                                                   │ │
│  │ • Quality Suite (format, cleanup, dedupe, verify)             │ │
│  │ • Git Integration (branch, commit, pr, workflows)              │ │
│  │ • Milestone Management (plan, execute, status, archive)        │ │
│  │ • Testing Workflows (unit, integration, e2e, coverage)         │ │
│  └───────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Template Types and Structure

### Base Templates

**Purpose**: Provide core development principles and patterns applicable across all projects.

**Location**: `templates/base/CLAUDE.md`

**Content Structure**:
```markdown
# Base Development Template

Core development principles and patterns for Claude Code Enhancer projects.

## Development Philosophy

### Research → Plan → Implement
[Core workflow patterns]

### Progressive Complexity Enforcement
[Complexity triage system]

### Safety-First Development
[Safety mechanisms and validation]

## Code Quality Standards

### Coding Conventions
[Language-agnostic coding standards]

### Documentation Requirements
[Documentation standards and patterns]

### Testing Strategies
[Testing approaches and requirements]

## Project Organization

### Directory Structure
[Common project structure patterns]

### Configuration Management
[Configuration file organization]

### Build and Deployment
[Build system patterns]
```

### Language Templates

**Purpose**: Provide language-specific development patterns, tools, and best practices.

**Location**: `templates/languages/{LANGUAGE}/CLAUDE.md`

**Inheritance**: Extends base templates with language-specific content.

#### Example: Python Template Structure

```markdown
# Python Development with Claude

Python-specific development guidelines building on core Claude principles.

## Development Environment

### Prerequisites
```bash
# Python version requirements
python --version  # 3.8+
pip --version

# Essential tools
pip install black isort flake8 mypy pytest
```

### Virtual Environment Setup
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt
```

## Project Structure

```
python-project/
├── src/
│   ├── __init__.py
│   ├── main.py
│   └── utils/
├── tests/
│   ├── __init__.py
│   ├── test_main.py
│   └── conftest.py
├── docs/
├── requirements.txt
├── setup.py
├── pyproject.toml
└── .gitignore
```

## Coding Standards

### Style Guidelines
- Follow PEP 8 style guide
- Use Black for automatic formatting
- Use isort for import organization
- Maximum line length: 88 characters

### Type Hints
```python
# Use type hints for all function signatures
def process_data(data: List[Dict[str, Any]]) -> DataFrame:
    """Process raw data into DataFrame format."""
    return pd.DataFrame(data)
```

### Error Handling
```python
# Use specific exception types
try:
    result = risky_operation()
except SpecificError as e:
    logger.error(f"Operation failed: {e}")
    raise ProcessingError(f"Failed to process data: {e}") from e
```

## Quality Assurance

### Linting and Formatting
```bash
# Format code
black src/ tests/
isort src/ tests/

# Lint code
flake8 src/ tests/
mypy src/
```

### Testing
```bash
# Run tests
pytest tests/ -v

# Coverage
pytest --cov=src tests/

# Performance testing
pytest tests/performance/ --benchmark
```

### Security
```bash
# Security scanning
bandit -r src/
safety check
```

## Dependencies Management

### Requirements Files
```bash
# requirements.txt - Production dependencies
requests>=2.25.0
pandas>=1.3.0

# requirements-dev.txt - Development dependencies
pytest>=6.0.0
black>=21.0.0
flake8>=3.9.0
mypy>=0.812
```

### Setup Configuration
```python
# setup.py
from setuptools import setup, find_packages

setup(
    name="project-name",
    version="0.1.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[
        "requests>=2.25.0",
        "pandas>=1.3.0",
    ],
    extras_require={
        "dev": [
            "pytest>=6.0.0",
            "black>=21.0.0",
            "flake8>=3.9.0",
            "mypy>=0.812",
        ]
    },
)
```

## Performance Optimization

### Profiling
```python
# Built-in profiling
import cProfile
cProfile.run('main_function()')

# Line-by-line profiling
# pip install line_profiler
@profile
def optimized_function():
    # Function implementation
    pass
```

### Memory Management
```python
# Use generators for large datasets
def process_large_dataset(filename):
    with open(filename) as f:
        for line in f:
            yield process_line(line)

# Use __slots__ for memory-efficient classes
class DataRecord:
    __slots__ = ['id', 'name', 'value']
    
    def __init__(self, id: int, name: str, value: float):
        self.id = id
        self.name = name
        self.value = value
```
```

### Framework Templates

**Purpose**: Provide framework-specific patterns, configurations, and workflows.

**Location**: `templates/frameworks/{FRAMEWORK}/CLAUDE.md`

**Inheritance**: Extends language templates with framework-specific content.

#### Example: React Template Structure

```markdown
# React Development with Claude

React-specific development patterns building on JavaScript/TypeScript foundations.

## Project Setup

### Create React App with TypeScript
```bash
# Create new React project
npx create-react-app my-app --template typescript
cd my-app

# Install additional dependencies
npm install @types/node @types/react @types/react-dom
npm install --save-dev eslint-plugin-react-hooks
```

### Enhanced Project Structure
```
react-project/
├── public/
│   ├── index.html
│   └── favicon.ico
├── src/
│   ├── components/
│   │   ├── common/
│   │   └── pages/
│   ├── hooks/
│   ├── services/
│   ├── utils/
│   ├── types/
│   ├── styles/
│   ├── App.tsx
│   └── index.tsx
├── tests/
│   └── __mocks__/
├── package.json
├── tsconfig.json
└── .eslintrc.js
```

## Component Development Patterns

### Functional Components with Hooks
```typescript
import React, { useState, useEffect } from 'react';

interface UserProfileProps {
  userId: string;
}

const UserProfile: React.FC<UserProfileProps> = ({ userId }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const fetchUser = async () => {
      try {
        const userData = await userService.getUser(userId);
        setUser(userData);
      } catch (error) {
        console.error('Failed to fetch user:', error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchUser();
  }, [userId]);
  
  if (loading) return <LoadingSpinner />;
  if (!user) return <ErrorMessage message="User not found" />;
  
  return (
    <div className="user-profile">
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
};

export default UserProfile;
```

### Custom Hooks
```typescript
// hooks/useApi.ts
import { useState, useEffect } from 'react';

interface UseApiResult<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
}

function useApi<T>(url: string): UseApiResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await fetch(url);
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const result = await response.json();
        setData(result);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    };
    
    fetchData();
  }, [url]);
  
  return { data, loading, error };
}

export default useApi;
```

## State Management

### Context API for Global State
```typescript
// contexts/AppContext.tsx
import React, { createContext, useContext, useReducer } from 'react';

interface AppState {
  user: User | null;
  theme: 'light' | 'dark';
}

type AppAction = 
  | { type: 'SET_USER'; payload: User }
  | { type: 'SET_THEME'; payload: 'light' | 'dark' };

const AppContext = createContext<{
  state: AppState;
  dispatch: React.Dispatch<AppAction>;
} | undefined>(undefined);

function appReducer(state: AppState, action: AppAction): AppState {
  switch (action.type) {
    case 'SET_USER':
      return { ...state, user: action.payload };
    case 'SET_THEME':
      return { ...state, theme: action.payload };
    default:
      return state;
  }
}

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(appReducer, {
    user: null,
    theme: 'light'
  });
  
  return (
    <AppContext.Provider value={{ state, dispatch }}>
      {children}
    </AppContext.Provider>
  );
};

export const useAppContext = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useAppContext must be used within AppProvider');
  }
  return context;
};
```

## Testing Strategies

### Component Testing with React Testing Library
```typescript
// tests/UserProfile.test.tsx
import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import UserProfile from '../components/UserProfile';
import * as userService from '../services/userService';

// Mock the service
jest.mock('../services/userService');
const mockUserService = userService as jest.Mocked<typeof userService>;

describe('UserProfile', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });
  
  it('renders loading state initially', () => {
    mockUserService.getUser.mockImplementation(() => new Promise(() => {}));
    
    render(<UserProfile userId="123" />);
    
    expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
  });
  
  it('renders user data when loaded', async () => {
    const mockUser = { id: '123', name: 'John Doe', email: 'john@example.com' };
    mockUserService.getUser.mockResolvedValue(mockUser);
    
    render(<UserProfile userId="123" />);
    
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('john@example.com')).toBeInTheDocument();
    });
  });
  
  it('handles error state', async () => {
    mockUserService.getUser.mockRejectedValue(new Error('User not found'));
    
    render(<UserProfile userId="123" />);
    
    await waitFor(() => {
      expect(screen.getByText('User not found')).toBeInTheDocument();
    });
  });
});
```

### Hook Testing
```typescript
// tests/useApi.test.ts
import { renderHook, waitFor } from '@testing-library/react';
import useApi from '../hooks/useApi';

// Mock fetch
global.fetch = jest.fn();
const mockFetch = fetch as jest.MockedFunction<typeof fetch>;

describe('useApi', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });
  
  it('fetches data successfully', async () => {
    const mockData = { id: 1, name: 'Test' };
    mockFetch.mockResolvedValue({
      ok: true,
      json: async () => mockData,
    } as Response);
    
    const { result } = renderHook(() => useApi<typeof mockData>('/api/test'));
    
    expect(result.current.loading).toBe(true);
    expect(result.current.data).toBe(null);
    
    await waitFor(() => {
      expect(result.current.loading).toBe(false);
      expect(result.current.data).toEqual(mockData);
      expect(result.current.error).toBe(null);
    });
  });
});
```
```

### Command Templates

**Purpose**: Provide workflow automation and development command patterns.

**Location**: `templates/commands/{COMMAND_CATEGORY}/{COMMAND}.md`

**Structure**: Command templates follow a specific format for integration with the command system.

#### Command Template Format

```markdown
---
description: Brief description of the command
allowed-tools: [list, of, allowed, tools]
complexity: simple|medium|complex
category: command_category
version: 1.0.0
requires: [list, of, required, dependencies]
---

# Command Name

Detailed description of the command purpose and functionality.

## Purpose

Clear explanation of when and why to use this command.

## Prerequisites

- List of required tools or dependencies
- Environment setup requirements
- Permission requirements

## Usage

```bash
claude command-name [options] [arguments]
```

### Options

- `--option1`: Description of option 1
- `--option2`: Description of option 2
- `--help`: Show help information

### Examples

#### Basic Usage
```bash
claude command-name
```

#### Advanced Usage
```bash
claude command-name --option1 value --option2
```

## Implementation

### Pre-execution Validation

```bash
# Validate prerequisites
validate_prerequisites() {
    # Check required tools
    command -v required_tool >/dev/null 2>&1 || {
        echo "Error: required_tool is required but not installed."
        exit 1
    }
    
    # Check permissions
    check_file_permissions
    
    # Validate environment
    validate_environment
}
```

### Core Implementation

```bash
# Main command logic
execute_command() {
    local option1="$1"
    local option2="$2"
    
    # Safety checks
    create_backup
    
    # Main execution
    perform_operation "$option1" "$option2"
    
    # Verification
    verify_operation_success
}
```

### Post-execution Cleanup

```bash
# Cleanup and verification
cleanup_command() {
    # Clean temporary files
    cleanup_temp_files
    
    # Verify system integrity
    verify_system_integrity
    
    # Log operation
    log_operation_completion
}
```

## Safety Considerations

- Backup requirements before execution
- Risk assessment and user confirmation
- Rollback procedures for failure scenarios
- Integrity verification after completion

## Error Handling

### Common Error Scenarios

1. **Missing Dependencies**
   - Detection: Check for required tools/files
   - Recovery: Provide installation instructions

2. **Permission Issues**
   - Detection: Test file/directory permissions
   - Recovery: Guide user to fix permissions

3. **Operation Failures**
   - Detection: Monitor operation return codes
   - Recovery: Execute rollback procedures

### Error Recovery

```bash
handle_error() {
    local error_code="$1"
    local error_message="$2"
    
    case "$error_code" in
        "PERMISSION_DENIED")
            echo "Error: Insufficient permissions"
            echo "Solution: Run with appropriate permissions"
            ;;
        "MISSING_DEPENDENCY")
            echo "Error: Missing required dependency"
            echo "Solution: Install $error_message"
            ;;
        *)
            echo "Unexpected error: $error_message"
            execute_rollback
            ;;
    esac
}
```

## Integration

### Shared Utilities

```bash
# Source shared utilities
source _shared/utils.md
source _shared/safety.md

# Use shared functions
use_shared_utility "function_name"
```

### Agent Coordination

```bash
# Spawn coordination agents if needed
if [[ "$COMPLEXITY" == "complex" ]]; then
    spawn_progress_monitor
    spawn_integrity_validator
fi
```

## Testing

### Unit Tests

```bash
test_command_validation() {
    # Test validation logic
    assert_command_fails "invalid_input"
    assert_command_succeeds "valid_input"
}

test_command_execution() {
    # Test core functionality
    setup_test_environment
    execute_command "test_params"
    verify_expected_results
    cleanup_test_environment
}
```

### Integration Tests

```bash
test_command_integration() {
    # Test with real environment
    create_test_project
    run_command_workflow
    verify_end_to_end_results
}
```

## Performance Considerations

- Execution time expectations
- Resource usage patterns
- Optimization opportunities
- Parallel execution capabilities

## Documentation

### User Documentation

- Clear usage examples
- Common use cases
- Troubleshooting guide
- Performance tips

### Developer Documentation

- Implementation details
- Extension points
- Customization options
- Testing strategies
```

## Template Creation Process

### Research Phase

Before creating any template, follow the **Research → Plan → Implement** workflow:

1. **Analyze Existing Patterns**
   ```bash
   # Study similar templates
   find templates/ -name "*.md" | xargs grep -l "similar_pattern"
   
   # Review community standards
   research_language_conventions "target_language"
   
   # Identify common use cases
   analyze_user_workflows "target_domain"
   ```

2. **Assess Complexity Level**
   - 🟢 **Simple**: Single language/framework, existing patterns
   - 🟡 **Medium**: New patterns, multiple integrations
   - 🔴 **Complex**: New architecture, system-wide impact

3. **Plan Template Structure**
   ```markdown
   # Template Planning Document
   
   ## Target Audience
   - Primary users and use cases
   - Skill level requirements
   - Integration needs
   
   ## Content Structure
   - Sections and subsections
   - Code examples and patterns
   - Integration points
   
   ## Inheritance Strategy
   - Base templates to extend
   - Framework-specific additions
   - Customization points
   ```

### Implementation Phase

#### Step 1: Create Directory Structure

```bash
# For language templates
mkdir -p templates/languages/{LANGUAGE}

# For framework templates
mkdir -p templates/frameworks/{FRAMEWORK}

# For command templates
mkdir -p templates/commands/{CATEGORY}
```

#### Step 2: Implement Base Content

```bash
# Start with template header
cat > templates/languages/newlang/CLAUDE.md << 'EOF'
# NewLang Development with Claude

NewLang-specific development guidelines building on core Claude principles.

## Development Environment

### Prerequisites

```bash
# Installation commands
```

### Project Setup

```bash
# Project initialization
```

[Continue with template content]
EOF
```

#### Step 3: Add Inheritance Support

```markdown
<!-- Include base template content -->
{{> base/CLAUDE.md}}

<!-- Language-specific content -->
## Language-Specific Patterns

[Language-specific content]
```

#### Step 4: Implement Parameterization

```markdown
# {{PROJECT_NAME}} Development

Project: {{PROJECT_NAME}}
Language: {{LANGUAGE}}
Framework: {{FRAMEWORK}}
Version: {{VERSION}}

## Project Structure

```
{{PROJECT_NAME}}/
├── src/
└── {{MAIN_FILE}}
```
```

### Validation and Testing

#### Template Validation

```bash
# Validate template syntax
validate_template_syntax "templates/languages/newlang/CLAUDE.md"

# Test template resolution
test_template_inheritance "newlang"

# Verify parameterization
test_template_parameters "newlang" "test_project"
```

#### Integration Testing

```bash
# Test with installation system
echo "y" | ./install-claude-flow.sh --language newlang

# Verify template application
verify_template_applied "newlang"

# Test customization
test_template_customization "newlang"
```

## Template Customization

### Parameterization System

Templates support dynamic content through parameter substitution:

#### Parameter Types

1. **Project Parameters**
   - `{{PROJECT_NAME}}`: Project name
   - `{{PROJECT_DESCRIPTION}}`: Project description
   - `{{PROJECT_VERSION}}`: Project version
   - `{{PROJECT_AUTHOR}}`: Project author

2. **Environment Parameters**
   - `{{LANGUAGE}}`: Programming language
   - `{{FRAMEWORK}}`: Development framework
   - `{{PACKAGE_MANAGER}}`: Package manager (npm, pip, cargo, etc.)
   - `{{BUILD_TOOL}}`: Build tool (webpack, vite, maven, etc.)

3. **Path Parameters**
   - `{{SRC_DIR}}`: Source directory path
   - `{{TEST_DIR}}`: Test directory path
   - `{{DOC_DIR}}`: Documentation directory path
   - `{{BUILD_DIR}}`: Build output directory

#### Parameter Usage

```markdown
# {{PROJECT_NAME}} Development Guide

Welcome to the {{PROJECT_NAME}} project using {{LANGUAGE}} and {{FRAMEWORK}}.

## Project Structure

```
{{PROJECT_NAME}}/
├── {{SRC_DIR}}/
│   └── main.{{FILE_EXTENSION}}
├── {{TEST_DIR}}/
└── {{DOC_DIR}}/
```

## Getting Started

```bash
# Install dependencies
{{PACKAGE_MANAGER}} install

# Run development server
{{PACKAGE_MANAGER}} run dev

# Build for production
{{BUILD_TOOL}} build
```
```

### Conditional Sections

Templates support conditional content based on project characteristics:

#### Conditional Syntax

```markdown
<!-- If TypeScript is enabled -->
{{#if TYPESCRIPT}}
## TypeScript Configuration

```json
{
  "compilerOptions": {
    "target": "es2020",
    "module": "esnext",
    "strict": true
  }
}
```
{{/if}}

<!-- Framework-specific sections -->
{{#if_eq FRAMEWORK "react"}}
## React-Specific Setup

```bash
npm install react react-dom @types/react @types/react-dom
```
{{/if_eq}}

{{#if_eq FRAMEWORK "vue"}}
## Vue-Specific Setup

```bash
npm install vue @vue/cli
```
{{/if_eq}}

<!-- Testing framework selection -->
{{#case TESTING_FRAMEWORK}}
  {{#when "jest"}}
  ## Jest Testing Setup
  
  ```bash
  npm install --save-dev jest @types/jest
  ```
  {{/when}}
  
  {{#when "vitest"}}
  ## Vitest Testing Setup
  
  ```bash
  npm install --save-dev vitest
  ```
  {{/when}}
{{/case}}
```

### Template Composition

Complex templates can be composed from multiple sources:

#### Composition Patterns

1. **Inheritance Composition**
   ```markdown
   <!-- Inherit from base template -->
   {{> base/CLAUDE.md}}
   
   <!-- Inherit from language template -->
   {{> languages/{{LANGUAGE}}/CLAUDE.md}}
   
   <!-- Add framework-specific content -->
   ## {{FRAMEWORK}} Integration
   [Framework-specific content]
   ```

2. **Mixin Composition**
   ```markdown
   <!-- Include testing patterns -->
   {{> mixins/testing.md}}
   
   <!-- Include CI/CD patterns -->
   {{> mixins/cicd.md}}
   
   <!-- Include security patterns -->
   {{> mixins/security.md}}
   ```

3. **Modular Composition**
   ```markdown
   <!-- Core development patterns -->
   {{> modules/development.md}}
   
   <!-- Quality assurance module -->
   {{> modules/quality.md}}
   
   <!-- Deployment module -->
   {{> modules/deployment.md}}
   ```

## Advanced Template Features

### Smart Content Generation

Templates can include logic for intelligent content generation:

#### File Structure Generation

```markdown
## Recommended Project Structure

```
{{PROJECT_NAME}}/
{{#each DIRECTORIES}}
├── {{this}}/
{{#if (eq this "src")}}
│   {{#each SRC_SUBDIRS}}
│   ├── {{this}}/
│   {{/each}}
{{/if}}
{{/each}}
└── README.md
```
```

#### Configuration File Generation

```markdown
## Configuration Files

{{#if (includes TOOLS "eslint")}}
### ESLint Configuration

```json
{
  "extends": ["eslint:recommended"{{#if TYPESCRIPT}}, "@typescript-eslint/recommended"{{/if}}],
  "env": {
    "node": true,
    "browser": {{BROWSER}}
  }
}
```
{{/if}}

{{#if (includes TOOLS "prettier")}}
### Prettier Configuration

```json
{
  "semi": {{SEMICOLONS}},
  "singleQuote": {{SINGLE_QUOTES}},
  "tabWidth": {{TAB_WIDTH}}
}
```
{{/if}}
```

### Template Validation

Templates include validation logic to ensure consistency:

#### Validation Rules

```markdown
<!-- Validate required sections -->
{{#validate "required_sections"}}
- Development Environment
- Project Structure
- Quality Assurance
- Testing Strategy
{{/validate}}

<!-- Validate parameter completeness -->
{{#validate "parameters"}}
{{#unless PROJECT_NAME}}
{{error "PROJECT_NAME is required"}}
{{/unless}}
{{#unless LANGUAGE}}
{{error "LANGUAGE is required"}}
{{/unless}}
{{/validate}}

<!-- Validate consistency -->
{{#validate "consistency"}}
{{#if (and TYPESCRIPT (eq LANGUAGE "python"))}}
{{error "TypeScript cannot be used with Python"}}
{{/if}}
{{/validate}}
```

## Template Management

### Version Control

Templates follow semantic versioning and change management:

#### Template Versioning

```yaml
# template-metadata.yml
name: "react-typescript"
version: "2.1.0"
description: "React with TypeScript development template"
author: "Claude Code Enhancer Team"
compatibility:
  claude_version: ">=1.5.0"
  node_version: ">=16.0.0"
dependencies:
  - "base@1.0.0"
  - "javascript@2.0.0"
  - "react@1.8.0"
changelog:
  - version: "2.1.0"
    changes:
      - "Added Vite support"
      - "Updated ESLint configuration"
      - "Enhanced TypeScript settings"
  - version: "2.0.0"
    changes:
      - "Breaking: Updated to React 18"
      - "Added Suspense patterns"
      - "Improved testing setup"
```

#### Migration Support

```bash
# Template migration script
migrate_template() {
    local from_version="$1"
    local to_version="$2"
    local template_name="$3"
    
    case "$from_version" in
        "1.*")
            migrate_v1_to_v2 "$template_name"
            ;&  # Fall through
        "2.0.*")
            migrate_v2_0_to_v2_1 "$template_name"
            ;;
    esac
    
    update_template_version "$template_name" "$to_version"
}
```

### Template Distribution

Templates can be distributed and shared across teams:

#### Template Packages

```bash
# Package template for distribution
package_template() {
    local template_name="$1"
    local output_dir="$2"
    
    # Create package structure
    mkdir -p "$output_dir/$template_name"
    
    # Copy template files
    cp -r "templates/$template_name/" "$output_dir/$template_name/"
    
    # Generate metadata
    generate_template_metadata "$template_name" > "$output_dir/$template_name/metadata.yml"
    
    # Create package archive
    tar -czf "$output_dir/$template_name.tar.gz" -C "$output_dir" "$template_name"
}

# Install template package
install_template_package() {
    local package_file="$1"
    local install_dir="templates/"
    
    # Extract package
    tar -xzf "$package_file" -C "$install_dir"
    
    # Validate package
    validate_template_package "$install_dir/$(basename "$package_file" .tar.gz)"
    
    # Register template
    register_template "$(basename "$package_file" .tar.gz)"
}
```

## Testing Templates

### Template Testing Framework

```bash
# Template test suite
test_template() {
    local template_name="$1"
    local test_project="test-$template_name-$(date +%s)"
    
    # Create test environment
    mkdir -p "test-projects/$test_project"
    cd "test-projects/$test_project"
    
    # Apply template
    apply_template "$template_name" "test-config.yml"
    
    # Run template tests
    test_template_structure "$template_name"
    test_template_functionality "$template_name"
    test_template_customization "$template_name"
    
    # Cleanup
    cd ../..
    rm -rf "test-projects/$test_project"
}

test_template_structure() {
    local template_name="$1"
    
    # Verify required files exist
    assert_file_exists "CLAUDE.md"
    assert_directory_exists ".claude/commands"
    
    # Verify template content
    assert_file_contains "CLAUDE.md" "$template_name"
    
    # Verify parameter substitution
    assert_file_contains "CLAUDE.md" "test-project"  # PROJECT_NAME
}

test_template_functionality() {
    local template_name="$1"
    
    # Test basic commands work
    assert_command_succeeds "claude --help"
    assert_command_succeeds "claude quality verify --quick"
    
    # Test template-specific functionality
    case "$template_name" in
        "javascript")
            assert_command_succeeds "npm install"
            assert_command_succeeds "npm test"
            ;;
        "python")
            assert_command_succeeds "pip install -r requirements.txt"
            assert_command_succeeds "pytest"
            ;;
    esac
}
```

### Continuous Template Testing

```yaml
# .github/workflows/template-tests.yml
name: Template Tests

on:
  push:
    paths:
      - 'templates/**'
  pull_request:
    paths:
      - 'templates/**'

jobs:
  test-templates:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        template:
          - javascript
          - typescript
          - python
          - react
          - nextjs
          - django
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Test Template ${{ matrix.template }}
        run: |
          cd test
          ./test-template.sh ${{ matrix.template }}
      
      - name: Upload Test Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: template-test-results-${{ matrix.template }}
          path: test/reports/
```

## Best Practices

### Template Design Principles

1. **Progressive Enhancement**: Start with basics, add complexity gradually
2. **Framework Agnostic**: Core patterns should work across frameworks
3. **Customizable**: Provide clear customization points
4. **Validated**: Include validation and error checking
5. **Documented**: Clear examples and explanations
6. **Tested**: Comprehensive test coverage
7. **Maintainable**: Regular updates and community feedback

### Content Guidelines

1. **Clear Structure**: Logical organization with consistent headings
2. **Practical Examples**: Real-world code samples and use cases
3. **Error Handling**: Common problems and solutions
4. **Performance**: Optimization tips and best practices
5. **Security**: Security considerations and safe patterns
6. **Accessibility**: Inclusive design and development practices

### Maintenance Standards

1. **Regular Updates**: Keep templates current with ecosystem changes
2. **Community Feedback**: Incorporate user suggestions and improvements
3. **Compatibility**: Maintain backwards compatibility when possible
4. **Documentation**: Keep documentation in sync with code
5. **Testing**: Continuous testing and validation
6. **Deprecation**: Clear migration paths for deprecated features

---

**Next**: [Command Development](./command-development.md) - Learn to build new commands

**See Also**:
- [Architecture Overview](./architecture-overview.md) - System design principles
- [Contributing Guidelines](./contributing-guidelines.md) - Contribution process
- [Quality Standards](./quality-standards.md) - Code quality requirements