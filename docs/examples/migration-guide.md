# Migrating Existing Projects to Claude Flow

This comprehensive guide helps you migrate existing projects to Claude Flow, preserving your current setup while adding powerful automation and quality checks.

## Overview

Migration to Claude Flow is designed to be:
- **Non-destructive**: Preserves existing configurations
- **Incremental**: Adopt features gradually
- **Flexible**: Works with any project structure
- **Smart**: Detects and integrates with existing tools

## Pre-Migration Checklist

Before starting migration:

```bash
# 1. Backup your project
git add .
git commit -m "Backup before Claude Flow migration"
git tag pre-claude-flow

# 2. Ensure clean working directory
git status

# 3. Create migration branch
git checkout -b feature/claude-flow-migration
```

## Migration Strategies

### Strategy 1: Automated Migration (Recommended)

```bash
# Run automated migration
claude flow migrate

# This will:
# 1. Detect existing tools and configurations
# 2. Create .claude directory
# 3. Merge with existing configs
# 4. Set up git hooks and quality workflows
# 5. Generate migration report
```

### Strategy 2: Manual Step-by-Step

```bash
# Initialize Claude Flow without overwriting
claude flow init --preserve-existing

# Review and merge configurations manually
claude flow migrate --dry-run
```

## JavaScript/TypeScript Project Migration

### Before Migration

Typical existing project:
```
my-js-project/
├── src/
├── tests/
├── .eslintrc.js
├── .prettierrc
├── jest.config.js
├── package.json
└── README.md
```

### Migration Steps

#### 1. Initialize Claude Flow

```bash
# Analyze existing setup
claude flow analyze

# Output:
# ✓ Detected: ESLint configuration
# ✓ Detected: Prettier configuration
# ✓ Detected: Jest testing framework
# ⚠ Missing: Git hooks
# ⚠ Missing: Unified Makefile
# ℹ Recommendation: Add TypeScript support

# Initialize with existing tool detection
claude flow init --detect-existing
```

#### 2. Merge ESLint Configuration

**Existing `.eslintrc.js`:**
```javascript
module.exports = {
  extends: ['eslint:recommended'],
  rules: {
    'no-console': 'warn',
    'semi': ['error', 'always']
  }
};
```

**Claude Flow Enhanced `.eslintrc.js`:**
```javascript
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:prettier/recommended' // Added by Claude Flow
  ],
  plugins: [
    'prettier' // Added for ESLint-Prettier integration
  ],
  rules: {
    'no-console': 'warn',
    'semi': ['error', 'always'],
    // Claude Flow recommended rules
    'no-unused-vars': ['error', { 'argsIgnorePattern': '^_' }],
    'prefer-const': 'error',
    'no-var': 'error',
    'object-shorthand': 'warn',
    'arrow-body-style': ['warn', 'as-needed']
  },
  env: {
    node: true,
    es2021: true,
    jest: true // Added for test files
  }
};
```

#### 3. Update package.json Scripts

**Before:**
```json
{
  "scripts": {
    "test": "jest",
    "lint": "eslint src",
    "start": "node src/index.js"
  }
}
```

**After Claude Flow Migration:**
```json
{
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint src tests",
    "lint:fix": "eslint src tests --fix",
    "format": "prettier --write \"**/*.{js,json,md}\"",
    "format:check": "prettier --check \"**/*.{js,json,md}\"",
    "typecheck": "tsc --noEmit",
    "validate": "npm run lint && npm run format:check && npm test",
    "prepare": "husky install"
  }
}
```

#### 4. Add Git Hooks

```bash
# Install husky and lint-staged
npm install -D husky lint-staged

# Set up git hooks
npx husky install
npx husky add .husky/pre-commit "npx lint-staged"
npx husky add .husky/pre-push "npm run validate"
```

**Add to package.json:**
```json
{
  "lint-staged": {
    "*.js": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md}": [
      "prettier --write"
    ]
  }
}
```

## Python Project Migration

### Before Migration

```
my-python-project/
├── src/
├── tests/
├── requirements.txt
├── setup.py
├── .flake8
└── README.md
```

### Migration Steps

#### 1. Convert to Modern Python Setup

```bash
# Create pyproject.toml from existing setup
claude flow migrate-python

# This converts:
# - requirements.txt → pyproject.toml dependencies
# - setup.py → pyproject.toml metadata
# - .flake8 → pyproject.toml configuration
```

**Generated `pyproject.toml`:**
```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-python-project"
version = "0.1.0"
description = "Migrated from setup.py"
dependencies = [
    # Migrated from requirements.txt
    "requests>=2.28.0",
    "pandas>=1.5.0",
    "sqlalchemy>=2.0.0"
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "flake8>=6.0.0",
    "mypy>=1.0.0",
    "isort>=5.0.0"
]

[tool.black]
line-length = 88
target-version = ['py38']

[tool.isort]
profile = "black"
line_length = 88

[tool.flake8]
# Migrated from .flake8
max-line-length = 88
extend-ignore = ["E203", "W503"]
exclude = [".git", "__pycache__", "build", "dist"]
```

#### 2. Update Test Configuration

```bash
# Add pytest configuration
claude add pytest-config
```

**Added to `pyproject.toml`:**
```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
python_classes = "Test*"
python_functions = "test_*"
addopts = "-v --cov=src --cov-report=html --cov-report=term"
```

#### 3. Create Unified Commands

```bash
# Generate Makefile
claude create makefile --python
```

**Generated `Makefile`:**
```makefile
.PHONY: help install test lint format clean

help:
	@echo "Available commands:"
	@echo "  make install    - Install dependencies"
	@echo "  make test      - Run tests"
	@echo "  make lint      - Run linting"
	@echo "  make format    - Format code"
	@echo "  make all       - Run all checks"

install:
	pip install -e ".[dev]"

test:
	pytest

lint:
	flake8 src tests
	mypy src
	isort --check-only src tests

format:
	black src tests
	isort src tests

all: format lint test
```

## React Project Migration

### Existing Create React App

```bash
# In existing React project
cd my-react-app

# Add Claude Flow
claude flow init --framework react --preserve-existing
```

### Migration Report

```
Claude Flow Migration Report
===========================

Detected Setup:
✓ React 18.2.0
✓ TypeScript 4.9.5
✓ ESLint (react-app config)
✓ Jest + React Testing Library
⚠ No Prettier configuration
⚠ No git hooks
⚠ No Storybook

Recommended Actions:
1. Add Prettier for code formatting
2. Set up Husky for git hooks
3. Add Storybook for component documentation
4. Enhance ESLint rules

Conflicts Found:
- ESLint: Will merge with existing rules
- Scripts: Will add new scripts without overwriting

Proceed with migration? (y/n)
```

### Apply Enhancements

```bash
# Add missing tools
claude add prettier --integrate-eslint
claude add storybook
claude add husky

# Update TypeScript config
claude enhance tsconfig
```

**Enhanced `tsconfig.json`:**
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "allowSyntheticDefaultImports": true,
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@utils/*": ["./src/utils/*"]
    }
  },
  "include": ["src"],
  "exclude": ["node_modules", "build", "dist"]
}
```

## Multi-Language Project Migration

### Existing Monorepo Structure

```
my-monorepo/
├── packages/
│   ├── frontend/      # React app
│   ├── backend/       # Node.js API
│   └── shared/        # Shared types
├── lerna.json
└── package.json
```

### Migration Approach

```bash
# Initialize at root level
claude flow init --monorepo

# Migrate each package
cd packages/frontend
claude flow migrate --type react

cd ../backend
claude flow migrate --type node

cd ../shared
claude flow migrate --type library
```

### Unified Configuration

**Root `.claude/config.yml`:**
```yaml
project:
  type: monorepo
  packages:
    - path: packages/frontend
      type: react
      commands:
        test: npm test
        build: npm run build
    - path: packages/backend
      type: node
      commands:
        test: npm test
        start: npm start
    - path: packages/shared
      type: library
      commands:
        build: npm run build

ci:
  parallel: true
  cache:
    - node_modules
    - packages/*/node_modules

hooks:
  pre-commit:
    - lint-staged
  pre-push:
    - npm run validate:all

commands:
  validate:all:
    script: |
      npm run lint --workspaces
      npm run test --workspaces
      npm run build --workspaces
```

## Handling Common Migration Issues

### 1. Conflicting ESLint Rules

```javascript
// .claude/merge-eslint.js
module.exports = {
  // Preserve your rules
  rules: {
    ...existingRules,
    // Claude Flow recommendations (can be overridden)
    ...claudeFlowRules
  }
};
```

### 2. Custom Build Scripts

```json
{
  "scripts": {
    // Keep your custom scripts
    "build:custom": "your-custom-build-script",
    // Add Claude Flow scripts
    "build": "npm run build:custom && npm run validate"
  }
}
```

### 3. Legacy Dependencies

```bash
# Check for outdated dependencies
claude check dependencies

# Output:
# ⚠ eslint@6.8.0 → 8.45.0 (major update)
# ⚠ jest@24.9.0 → 29.6.0 (major update)
# ℹ Consider updating gradually

# Update safely
claude update dependencies --safe
```

### 4. Git History Preservation

```bash
# Create migration commits
git add .claude
git commit -m "Add Claude Flow configuration"

git add package.json
git commit -m "Update scripts for Claude Flow"

git add .husky
git commit -m "Add git hooks via Husky"

# Keep history clean
git rebase -i HEAD~3  # Squash if desired
```

## Rollback Plan

If you need to rollback:

```bash
# 1. Remove Claude Flow files
rm -rf .claude .husky

# 2. Restore original configs
git checkout pre-claude-flow -- package.json .eslintrc.js

# 3. Uninstall Claude Flow dependencies
npm uninstall husky lint-staged

# 4. Remove git hooks
rm -rf .git/hooks/*
```

## Verification Steps

After migration:

```bash
# 1. Run all validations
npm run validate

# 2. Test git hooks
git add .
git commit -m "Test commit"

# 3. Run quality checks
claude quality --comprehensive

# 4. Test individual quality commands
claude format --dry-run
claude verify --quick
claude cleanup --conservative

# 5. Check integration
claude doctor

# Output:
# Claude Flow Health Check
# ========================
# ✓ Git hooks installed
# ✓ Quality workflows configured
# ✓ Linting configured
# ✓ Tests passing
# ✓ Build successful
# ✓ All systems operational!
```

## Migration Timeline

Typical migration timeline:

1. **Day 1**: Initial setup and configuration merge
2. **Day 2-3**: Test and fix any issues
3. **Day 4-5**: Team training and documentation
4. **Week 2**: Full adoption and optimization

## Best Practices

1. **Gradual Adoption**
   - Start with non-breaking changes
   - Add features incrementally
   - Get team buy-in at each step

2. **Preserve Working Configs**
   - Back up existing configurations
   - Test thoroughly before committing
   - Keep rollback options available

3. **Team Communication**
   - Document changes clearly
   - Provide training on new commands
   - Share benefits and improvements

4. **Monitor Impact**
   - Track build times
   - Monitor code quality metrics
   - Gather team feedback

## Next Steps

- Review [CI/CD setup](./ci-cd-setup.md) for automated pipelines
- Explore [multi-language examples](./multi-language.md)
- Check [JavaScript](./javascript-project.md) or [Python](./python-project.md) specific guides