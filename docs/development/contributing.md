# Contributing to Claude Flow

Thank you for your interest in contributing to Claude Flow! This guide will help you get started with contributing to the project.

## Code of Conduct

By participating in this project, you agree to:
- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive feedback
- Respect differing viewpoints and experiences

## Getting Started

1. **Fork the Repository**
   ```bash
   # Fork via GitHub UI, then clone your fork
   git clone https://github.com/YOUR_USERNAME/claude-flow.git
   cd claude-flow
   ```

2. **Set Up Development Environment**
   - Follow the [Development Setup Guide](setup.md)
   - Run tests to ensure everything works

3. **Find an Issue**
   - Check [open issues](https://github.com/your-org/claude-flow/issues)
   - Look for issues labeled `good first issue` or `help wanted`
   - Comment on the issue to claim it

## Development Process

### 1. Create a Feature Branch

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create a new feature branch
git checkout -b feature/issue-123-description
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `test/` - Test improvements
- `refactor/` - Code refactoring

### 2. Make Your Changes

Follow these guidelines:
- Write clear, self-documenting code
- Add comments for complex logic
- Update documentation as needed
- Add tests for new functionality
- Follow the [Code Style Guide](code-style.md)

### 3. Commit Your Changes

Write clear commit messages:

```bash
# Good commit messages
git commit -m "Add Python template for Flask framework"
git commit -m "Fix merge conflict detection in smart-merge-claude.sh"
git commit -m "Update installation docs with Windows WSL instructions"

# Bad commit messages (avoid these)
git commit -m "Fixed stuff"
git commit -m "WIP"
git commit -m "misc changes"
```

Commit message format:
```
<type>: <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test changes
- `refactor`: Code refactoring
- `chore`: Maintenance tasks

### 4. Test Your Changes

Always run tests before submitting:

```bash
# Run all tests
cd test
./run-tests.sh

# Test installation scripts
./install.sh --user
~/.local/bin/claude-install-flow --help

# Test in a clean environment
mkdir ~/test-project
cd ~/test-project
claude-install-flow
```

### 5. Update Documentation

If your changes affect user-facing functionality:
- Update relevant documentation in `docs/`
- Update `README.md` if needed
- Add examples if applicable

### 6. Submit a Pull Request

1. **Push your branch**
   ```bash
   git push origin feature/issue-123-description
   ```

2. **Create Pull Request**
   - Go to your fork on GitHub
   - Click "New Pull Request"
   - Select your feature branch
   - Fill out the PR template

3. **PR Description Template**
   ```markdown
   ## Summary
   Brief description of changes

   ## Related Issue
   Fixes #123

   ## Changes Made
   - Added X functionality
   - Fixed Y bug
   - Updated Z documentation

   ## Testing
   - [ ] All tests pass
   - [ ] Manual testing completed
   - [ ] Documentation updated

   ## Screenshots (if applicable)
   Add screenshots for UI changes
   ```

## Types of Contributions

### 1. New Language/Framework Templates

To add support for a new language or framework:

```bash
# For a new language
mkdir -p templates/languages/YOUR_LANGUAGE
cat > templates/languages/YOUR_LANGUAGE/CLAUDE.md << 'EOF'
# YOUR_LANGUAGE Development with Claude

## Language-Specific Guidelines
...
EOF

# For a new framework
mkdir -p templates/frameworks/YOUR_FRAMEWORK
cat > templates/frameworks/YOUR_FRAMEWORK/CLAUDE.md << 'EOF'
# YOUR_FRAMEWORK Development with Claude

## Framework-Specific Guidelines
...
EOF
```

Update `install-claude-flow.sh` to include your template in the selection menu.

### 2. New Command Templates

Create helpful command templates:

```bash
cat > templates/commands/your-command.md << 'EOF'
# Your Command Name

## Purpose
What this command helps with

## Usage
How to use this command effectively

## Examples
Specific examples
EOF
```

### 3. Bug Fixes

When fixing bugs:
1. Add a test that reproduces the bug
2. Fix the bug
3. Ensure the test now passes
4. Check for similar issues elsewhere

### 4. Documentation

Documentation improvements are always welcome:
- Fix typos and grammar
- Add examples
- Clarify confusing sections
- Add troubleshooting tips

### 5. Test Improvements

Enhance the test suite:
- Add edge case tests
- Improve test coverage
- Add integration tests
- Speed up test execution

## Pull Request Guidelines

### PR Checklist

Before submitting your PR, ensure:

- [ ] Code follows project style guidelines
- [ ] All tests pass (`cd test && ./run-tests.sh`)
- [ ] New features have tests
- [ ] Documentation is updated
- [ ] Commit messages are clear
- [ ] PR description is complete

### Review Process

1. **Automated Checks**
   - Tests must pass
   - No merge conflicts

2. **Code Review**
   - At least one maintainer review
   - Address all feedback
   - Keep discussions constructive

3. **Merge**
   - Maintainer merges when approved
   - Branch is automatically deleted

## Release Process

Claude Flow follows semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

Releases are created by maintainers when significant changes accumulate.

## Getting Help

If you need help:

1. **Documentation**: Check existing docs first
2. **Issues**: Search existing issues
3. **Discussions**: Start a GitHub discussion
4. **Community**: Join our community chat

## Recognition

Contributors are recognized in:
- Release notes
- Contributors file
- Project documentation

Thank you for contributing to Claude Flow!