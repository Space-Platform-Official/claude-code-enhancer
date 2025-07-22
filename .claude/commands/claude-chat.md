# Claude Chat Command Template

## Description
Interactive chat session with Claude Code for development tasks, code review, and technical consultation.

## Allowed Tools
- All standard Claude Code tools
- File system access (Read, Write, Edit)
- Code execution capabilities
- Web search and fetch
- Task management

## Usage Pattern

### Basic Chat Session
```bash
claude-code chat
```

### Project-Specific Chat
```bash
claude-code chat --project /path/to/project
```

### With Context Loading
```bash
claude-code chat --load-context CLAUDE.md
```

## Command Workflow

### 1. Session Initialization
- Load project context from CLAUDE.md if available
- Scan for existing code patterns and conventions
- Initialize development environment awareness

### 2. Interactive Development
- **Research First**: Always explore codebase before implementation
- **Plan Before Code**: Create implementation plans for complex tasks
- **Validate Continuously**: Run tests and checks during development

### 3. Quality Assurance
- Mandatory linting and formatting checks
- Test execution and validation
- Build verification before completion

## Template Variables

### Project Configuration
- `PROJECT_PATH`: Target project directory
- `LANGUAGE`: Primary programming language
- `FRAMEWORK`: Framework being used (React, Django, etc.)
- `TEST_COMMAND`: Command to run tests

### Development Mode
- `COMPLEXITY_MODE`: simple | justified | complex
- `VERBOSITY_LEVEL`: minimal | standard | comprehensive
- `FILE_GENERATION`: conservative | balanced | permissive

## Example Usage

### Code Review Session
```bash
# Start chat with code review focus
claude-code chat --mode review --files "src/**/*.js"
```

### Feature Implementation
```bash
# Implementation session with testing
claude-code chat --mode implement --test-after
```

### Debugging Session
```bash
# Debug mode with enhanced logging
claude-code chat --mode debug --verbose
```

## Integration Points

### With CLAUDE.md
- Automatically loads development partnership guidelines
- Enforces complexity triage system
- Applies file creation constraints

### With Git
- Respects branch context
- Can create commits with proper formatting
- Integrates with PR workflows

### With Testing
- Runs test suites during development
- Validates code quality before completion
- Enforces 100% test success requirements

## Quality Standards

### Mandatory Checks
- [ ] All code passes linting
- [ ] Tests execute successfully
- [ ] Build completes without errors
- [ ] Documentation is updated if needed

### Output Requirements
- Concise responses (max 4 lines unless detail requested)
- Clear action items and next steps
- Proper code references with file:line format

## Security Considerations
- Never commit secrets or API keys
- Validate all external inputs
- Follow defensive security practices only
- Refuse malicious code creation or modification