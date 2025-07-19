# Contributing Guidelines

Comprehensive guide for contributing to the Claude Code Enhancer project, covering code contributions, documentation, templates, and community standards.

## Getting Started

### Before You Contribute

1. **Read the Documentation**
   - [Development Setup](./development-setup.md) - Set up your environment
   - [Architecture Overview](./architecture-overview.md) - Understand the system
   - [Quality Standards](./quality-standards.md) - Learn our standards

2. **Understand Our Philosophy**
   - **Research → Plan → Implement**: Always follow this sequence
   - **Progressive Complexity Enforcement**: Mandatory complexity triage
   - **Safety-First**: Zero-tolerance for breaking changes
   - **Agent-First**: Leverage multi-agent coordination patterns

3. **Set Up Development Environment**
   ```bash
   git clone <repository>
   cd claude-code-enhancer
   chmod +x *.sh
   export CLAUDE_TEMPLATES_DIR="$(pwd)/templates"
   cd test && ./run-tests.sh
   ```

## Contribution Process

### 1. Issue Creation and Discussion

#### Before Opening an Issue
- Search existing issues for similar problems
- Check documentation for existing solutions
- Verify the issue exists in the latest version

#### Issue Types

**Bug Reports**
```markdown
**Bug Description**: Clear description of the issue
**Environment**: OS, Bash version, Git version
**Reproduction Steps**: Minimal steps to reproduce
**Expected Behavior**: What should happen
**Actual Behavior**: What actually happens
**Logs**: Relevant error messages and debug output
```

**Feature Requests**
```markdown
**Feature Description**: Clear description of proposed feature
**Use Case**: Why this feature is needed
**Complexity Assessment**: Simple/Medium/Complex classification
**Implementation Ideas**: Initial thoughts on implementation
**Alternatives Considered**: Other approaches evaluated
```

**Template Requests**
```markdown
**Language/Framework**: Target language or framework
**Template Type**: Base template, command, or workflow
**Requirements**: Specific needs and patterns
**Examples**: Sample code or configurations
**Community Impact**: Who would benefit
```

### 2. Development Workflow

#### Branch Strategy

```bash
# Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/your-feature-name

# For bug fixes
git checkout -b fix/issue-description

# For documentation
git checkout -b docs/documentation-topic

# For templates
git checkout -b template/language-or-framework
```

#### Development Process

**Step 1: Research Phase**
```bash
# Explore existing patterns
find .claude/commands -name "*.md" | head -10 | xargs grep -l "pattern-you-need"

# Understand template structure
ls -la templates/languages/
ls -la templates/frameworks/

# Study similar implementations
grep -r "similar-functionality" .
```

**Step 2: Planning Phase**
```bash
# Document your plan
vim IMPLEMENTATION_PLAN.md

# Content should include:
# - Problem analysis
# - Complexity assessment (Simple/Medium/Complex)
# - Implementation approach
# - Testing strategy
# - Documentation updates needed
```

**Step 3: Implementation Phase**
```bash
# Make changes following established patterns
# Run tests frequently
cd test && ./run-tests.sh

# Check code quality
shellcheck *.sh
find . -name "*.sh" | xargs shellcheck
```

### 3. Code Standards

#### Shell Script Standards

**File Structure**
```bash
#!/bin/bash
# Brief description of the script
# Usage: script-name.sh [options]

set -e  # Exit on error

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERSION="1.0.0"

# Variables
local_var=""
global_var=""

# Functions (alphabetical order)
function_name() {
    local param1="$1"
    local param2="$2"
    
    # Implementation
}

# Main execution
main() {
    # Implementation
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

**Coding Conventions**
```bash
# Use 4-space indentation
if [[ condition ]]; then
    command
fi

# Quote variables
local file_path="$1"
echo "Processing: $file_path"

# Use readonly for constants
readonly CONFIG_FILE=".claude-config"

# Use local for function variables
function process_file() {
    local input_file="$1"
    local output_file="$2"
}

# Handle errors gracefully
if ! command_that_might_fail; then
    echo "Error: Command failed" >&2
    return 1
fi
```

#### Documentation Standards

**Markdown Structure**
```markdown
# Title (H1 - One per document)

Brief description of the content.

## Major Section (H2)

Section content with clear explanations.

### Subsection (H3)

Detailed information with examples.

#### Sub-subsection (H4 - Use sparingly)

Specific implementation details.
```

**Code Blocks**
```markdown
```bash
# Always specify language
command --option value
```

```json
{
  "key": "value"
}
```

```yaml
key: value
list:
  - item1
  - item2
```
```

**Examples and Templates**
```markdown
### Example Usage

```bash
# Basic usage
claude command --option

# Advanced usage with explanation
claude command --advanced-option value  # This does X
```

### Template Example

```yaml
# .claude-config.yaml
configuration:
  setting: value
  list:
    - item1
    - item2
```
```

### 4. Testing Requirements

#### Test Coverage Requirements

**All Contributions Must Include:**
- Unit tests for new functionality
- Integration tests for command workflows
- Edge case tests for error conditions
- Documentation tests for examples

**Test Categories**
```bash
# Function-level tests
test_function_name() {
    print_test "Test: Function Description"
    
    # Setup
    local input="test-input"
    
    # Execute
    local result=$(function_name "$input")
    
    # Verify
    if [[ "$result" == "expected-output" ]]; then
        print_success "Function works correctly"
    else
        print_error "Expected 'expected-output', got '$result'"
        return 1
    fi
}

# Integration tests
test_command_workflow() {
    print_test "Test: Complete Command Workflow"
    
    # Setup test environment
    mkdir -p test-projects/integration
    cd test-projects/integration
    
    # Execute workflow
    echo "y" | ../../command.sh
    
    # Verify results
    check_files_created
    check_configuration_applied
    
    cd ../..
}

# Error condition tests
test_error_handling() {
    print_test "Test: Error Handling"
    
    # Create error condition
    chmod 000 test-file
    
    # Should fail gracefully
    if command_that_should_fail 2>/dev/null; then
        print_error "Command should have failed"
        return 1
    else
        print_success "Error handled correctly"
    fi
    
    # Cleanup
    chmod 644 test-file
}
```

#### Test Execution

```bash
# Run all tests
cd test && ./run-tests.sh

# Run specific test category
source test/run-tests.sh
test_fresh_install
test_merge_conflicts

# Debug test failures
export CLAUDE_DEBUG=1
bash -x test/run-tests.sh
```

### 5. Pull Request Process

#### Pre-Submission Checklist

- [ ] **Code Quality**
  - [ ] All tests pass (`cd test && ./run-tests.sh`)
  - [ ] Shell scripts pass shellcheck (`find . -name "*.sh" | xargs shellcheck`)
  - [ ] No trailing whitespace or formatting issues
  - [ ] Code follows established patterns

- [ ] **Documentation**
  - [ ] All new features documented
  - [ ] Examples provided and tested
  - [ ] README updated if needed
  - [ ] Inline comments for complex logic

- [ ] **Testing**
  - [ ] New functionality has tests
  - [ ] Edge cases covered
  - [ ] Error conditions tested
  - [ ] Integration tests updated

- [ ] **Compatibility**
  - [ ] Backwards compatible
  - [ ] Works on supported platforms
  - [ ] No breaking changes (or properly documented)
  - [ ] Dependencies documented

#### Pull Request Template

```markdown
## Description

Brief description of changes and motivation.

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Template addition/modification

## Complexity Assessment

- [ ] Simple (single file changes, existing patterns)
- [ ] Medium (multiple file coordination, new patterns)
- [ ] Complex (architectural changes, system-wide impact)

## Testing

- [ ] Tests pass locally
- [ ] New tests added for new functionality
- [ ] Edge cases covered
- [ ] Documentation examples tested

## Changes Made

- List specific changes
- Include any configuration changes
- Note any new dependencies

## Breaking Changes

- List any breaking changes
- Provide migration instructions
- Document compatibility impact

## Additional Notes

- Any special testing instructions
- Performance implications
- Security considerations
```

#### Review Process

**Code Review Checklist for Reviewers:**

- [ ] **Architecture**
  - [ ] Follows established patterns
  - [ ] Appropriate complexity level
  - [ ] No over-engineering
  - [ ] Maintains system consistency

- [ ] **Code Quality**
  - [ ] Clear, readable code
  - [ ] Proper error handling
  - [ ] Security considerations addressed
  - [ ] Performance implications considered

- [ ] **Testing**
  - [ ] Adequate test coverage
  - [ ] Tests actually test the functionality
  - [ ] Edge cases covered
  - [ ] Error conditions tested

- [ ] **Documentation**
  - [ ] Clear and accurate
  - [ ] Examples work as documented
  - [ ] Follows documentation standards
  - [ ] Updates existing docs if needed

## Specific Contribution Types

### Template Contributions

#### Language Templates

**Structure Requirements**
```
templates/languages/LANGUAGE_NAME/
├── CLAUDE.md                    # Main configuration
├── CLAUDE_ENHANCED.md          # Enhanced version (optional)
└── README.md                   # Language-specific documentation
```

**Template Content Standards**
```markdown
# LANGUAGE_NAME Development with Claude

Language-specific development guidelines and best practices.

## Development Environment

### Prerequisites
- Language version requirements
- Essential tools and dependencies
- IDE/editor recommendations

### Project Structure
```
project/
├── src/
├── tests/
├── docs/
└── config/
```

## Coding Standards

### Style Guidelines
- Formatting conventions
- Naming conventions
- Documentation requirements

### Quality Checks
- Linting tools and configuration
- Testing frameworks and patterns
- Build and deployment processes

## Best Practices

### Performance
- Language-specific optimization techniques
- Profiling and benchmarking
- Memory management considerations

### Security
- Common security pitfalls
- Security scanning tools
- Secure coding practices
```

#### Framework Templates

**Structure Requirements**
```
templates/frameworks/FRAMEWORK_NAME/
├── CLAUDE.md                    # Main configuration
└── README.md                   # Framework-specific documentation
```

**Content Standards**
```markdown
# FRAMEWORK_NAME Development with Claude

Framework-specific development patterns and best practices.

## Setup and Configuration

### Installation
```bash
# Framework installation commands
npm install framework-name
# or equivalent for other package managers
```

### Project Initialization
```bash
# Project creation commands
framework-cli create project-name
```

## Development Patterns

### Project Structure
- Framework-specific directory layout
- Configuration file organization
- Asset management

### Common Tasks
- Development server setup
- Build processes
- Testing strategies
- Deployment procedures

## Integration Guidelines

### Third-party Libraries
- Recommended packages
- Integration patterns
- Configuration management

### Development Tools
- IDE plugins and extensions
- Debugging tools
- Performance monitoring
```

### Command Contributions

#### Command Structure

```markdown
---
description: Brief description of the command
allowed-tools: [list, of, allowed, tools]
complexity: simple|medium|complex
---

# Command Name

Detailed description of what this command does.

## Purpose

Clear explanation of when and why to use this command.

## Usage

```bash
claude command-name [options]
```

## Options

- `--option1`: Description of option 1
- `--option2`: Description of option 2

## Examples

### Basic Usage
```bash
claude command-name
```

### Advanced Usage
```bash
claude command-name --option1 value --option2
```

## Implementation

[Detailed implementation steps]

## Safety Considerations

- Backup requirements
- Risk assessment
- Rollback procedures

## Error Handling

- Common error conditions
- Troubleshooting steps
- Recovery procedures
```

#### Shared Utilities Integration

```markdown
## Shared Utilities Usage

### Safety Framework
```bash
# Pre-operation validation
source _shared/safety.md
validate_git_status
create_backup

# Operation implementation
# ...

# Post-operation verification
verify_integrity
cleanup_backup
```

### Utility Functions
```bash
# File detection and analysis
source _shared/utils.md
detect_project_language
analyze_code_complexity
track_progress

# Error handling
handle_error "Error message" "recovery_function"
```
```

### Documentation Contributions

#### Documentation Standards

**Structure Requirements**
- Clear hierarchy (max 4 levels)
- Progressive disclosure
- Practical examples
- Cross-references

**Content Standards**
- Start with purpose and scope
- Provide quick start section
- Include comprehensive examples
- End with troubleshooting

**Example Structure**
```markdown
# Title

Brief description and scope.

## Quick Start

Minimal example to get started.

## Detailed Guide

### Section 1
Detailed explanation with examples.

### Section 2
Advanced topics and patterns.

## Reference

### Configuration Options
Complete reference of all options.

### API Reference
Detailed API documentation.

## Troubleshooting

Common issues and solutions.

## See Also

References to related documentation.
```

## Quality Assurance

### Automated Quality Checks

**Pre-commit Hooks**
```bash
#!/bin/bash
# .git/hooks/pre-commit

set -e

# Run tests
cd test && ./run-tests.sh

# Check shell scripts
find . -name "*.sh" -not -path "./test/*" | xargs shellcheck

# Check markdown formatting
markdownlint docs/

# Check for common issues
grep -r "TODO\|FIXME\|XXX" . --exclude-dir=.git || true
```

**Continuous Integration**
```yaml
# .github/workflows/quality.yml
name: Quality Checks
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Run Tests
        run: |
          cd test
          chmod +x run-tests.sh
          ./run-tests.sh
      
      - name: ShellCheck
        run: |
          find . -name "*.sh" | xargs shellcheck
      
      - name: Markdown Lint
        run: |
          markdownlint docs/
```

### Manual Quality Review

**Code Review Focus Areas**

1. **Architecture Alignment**
   - Follows established patterns
   - Appropriate complexity level
   - Maintains system consistency

2. **Safety and Reliability**
   - Proper error handling
   - Backup and recovery mechanisms
   - Input validation and sanitization

3. **Performance Considerations**
   - Efficient algorithms and data structures
   - Minimal resource usage
   - Scalability implications

4. **Security Implications**
   - Input validation
   - File system security
   - Permission handling

5. **Maintainability**
   - Clear, readable code
   - Comprehensive documentation
   - Adequate test coverage

## Community Guidelines

### Communication Standards

**Issue Discussions**
- Be respectful and constructive
- Provide specific, actionable feedback
- Focus on technical merits
- Help others learn and improve

**Code Reviews**
- Review code, not the person
- Explain reasoning behind suggestions
- Acknowledge good practices
- Offer alternatives when pointing out issues

**Documentation Feedback**
- Point out unclear explanations
- Suggest improvements to examples
- Verify that instructions work
- Highlight missing information

### Recognition and Attribution

**Contributor Recognition**
- All contributors acknowledged in releases
- Significant contributions highlighted
- Learning opportunities provided
- Community building encouraged

**Attribution Standards**
- Credit original authors appropriately
- Maintain license compatibility
- Document external dependencies
- Respect intellectual property

## Getting Help

### Before Asking for Help

1. **Search Documentation**
   - Check existing documentation thoroughly
   - Search for similar issues or questions
   - Review troubleshooting guides

2. **Try Debugging**
   - Enable debug mode (`CLAUDE_DEBUG=1`)
   - Check logs and error messages
   - Isolate the problem

3. **Check Environment**
   - Verify development setup
   - Test with clean environment
   - Check version compatibility

### How to Ask for Help

**Provide Context**
```markdown
**Environment**: OS, Bash version, Git version
**Operation**: What you were trying to do
**Expected**: What you expected to happen
**Actual**: What actually happened
**Steps**: Minimal reproduction steps
**Logs**: Relevant error messages
```

**Example Help Request**
```markdown
I'm trying to add a new language template for Kotlin, but the template detection isn't working.

**Environment**: macOS 12.6, Bash 5.1, Git 2.37
**Operation**: Adding Kotlin template in templates/languages/kotlin/
**Expected**: Template should be detected and offered during installation
**Actual**: Template not found, falls back to generic template
**Steps**:
1. Created templates/languages/kotlin/CLAUDE.md
2. Ran ./install-claude-flow.sh
3. Selected option for language detection
**Logs**: "Language template not found" in debug output
```

### Learning Resources

**Architecture Understanding**
- [Architecture Overview](./architecture-overview.md)
- [System Design Documentation](../architecture/)
- [API Reference](../api/)

**Development Skills**
- [Shell Scripting Best Practices](https://google.github.io/styleguide/shellguide.html)
- [Bash Advanced Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Git Workflow Guides](https://www.atlassian.com/git/tutorials)

## Conclusion

Contributing to the Claude Code Enhancer project is an opportunity to:

- **Learn Advanced Patterns**: Multi-agent coordination, progressive complexity enforcement
- **Practice Quality Engineering**: Comprehensive testing, safety-first development
- **Build Developer Tools**: Create tools that improve development workflows
- **Join a Community**: Connect with developers focused on quality and efficiency

### Next Steps for New Contributors

1. **Start Small**: Begin with documentation improvements or simple bug fixes
2. **Learn Patterns**: Study existing code to understand established patterns
3. **Ask Questions**: Engage with the community when you need guidance
4. **Share Knowledge**: Help others learn as you gain experience
5. **Build Features**: Gradually work toward larger contributions

### Contribution Impact

Your contributions help:
- **Improve Developer Experience**: Better tools for development teams
- **Advance Best Practices**: Promote quality-first development approaches
- **Build Community**: Create a collaborative environment for learning
- **Enable Innovation**: Provide foundation for advanced development workflows

---

**Next**: [Architecture Overview](./architecture-overview.md) - Understand the system design

**See Also**:
- [Quality Standards](./quality-standards.md) - Code quality requirements
- [Testing Guidelines](./testing-guidelines.md) - Comprehensive testing approach
- [Security Guidelines](./security-guidelines.md) - Security best practices