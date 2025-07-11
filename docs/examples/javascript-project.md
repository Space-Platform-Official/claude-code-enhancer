# JavaScript/Node.js Project Setup with Claude Flow

This guide walks you through setting up a complete Node.js project with Claude Flow, including development standards, testing, and CI/CD.

## Prerequisites

- Node.js 18+ installed
- Git initialized in your project
- Claude Flow installed globally

## Step-by-Step Setup

### 1. Initialize Your Project

```bash
# Create project directory
mkdir my-node-app
cd my-node-app

# Initialize git and npm
git init
npm init -y

# Install Claude Flow
claude flow init
```

**Expected Output:**
```
🚀 Initializing Claude Flow...
✅ Created .claude directory
✅ Created CLAUDE.md with project instructions
✅ Set up git hooks for automated checks
✅ Created Makefile with common commands

Claude Flow initialized successfully!
```

### 2. Configure JavaScript Standards

```bash
# Set up ESLint and Prettier
claude flow setup eslint prettier

# Or use the interactive setup
claude flow setup
# Select: JavaScript/TypeScript > ESLint + Prettier
```

**Generated `.eslintrc.json`:**
```json
{
  "env": {
    "node": true,
    "es2021": true,
    "jest": true
  },
  "extends": [
    "eslint:recommended",
    "prettier"
  ],
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "rules": {
    "no-console": "warn",
    "no-unused-vars": ["error", { "argsIgnorePattern": "^_" }]
  }
}
```

**Generated `.prettierrc`:**
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2
}
```

### 3. Set Up Testing Framework

```bash
# Install Jest
claude flow setup jest

# This will:
# - Install jest and related packages
# - Create jest.config.js
# - Add test scripts to package.json
# - Create example test file
```

**Generated `jest.config.js`:**
```javascript
module.exports = {
  testEnvironment: 'node',
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/**/*.test.js',
    '!src/index.js'
  ],
  testMatch: [
    '**/__tests__/**/*.js',
    '**/?(*.)+(spec|test).js'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};
```

### 4. Create Project Structure

```bash
# Use Claude to create standard project structure
claude create-structure

# Or manually create:
mkdir -p src tests docs
touch src/index.js src/app.js
touch tests/app.test.js
touch README.md
```

**Example `src/app.js`:**
```javascript
class TodoService {
  constructor() {
    this.todos = [];
  }

  addTodo(title, description = '') {
    if (!title || typeof title !== 'string') {
      throw new Error('Title is required and must be a string');
    }

    const todo = {
      id: Date.now().toString(),
      title: title.trim(),
      description: description.trim(),
      completed: false,
      createdAt: new Date()
    };

    this.todos.push(todo);
    return todo;
  }

  getTodos() {
    return [...this.todos];
  }

  completeTodo(id) {
    const todo = this.todos.find(t => t.id === id);
    if (!todo) {
      throw new Error(`Todo with id ${id} not found`);
    }
    todo.completed = true;
    todo.completedAt = new Date();
    return todo;
  }
}

module.exports = TodoService;
```

**Example `tests/app.test.js`:**
```javascript
const TodoService = require('../src/app');

describe('TodoService', () => {
  let todoService;

  beforeEach(() => {
    todoService = new TodoService();
  });

  describe('addTodo', () => {
    it('should add a todo with title and description', () => {
      const todo = todoService.addTodo('Buy groceries', 'Milk, eggs, bread');
      
      expect(todo).toMatchObject({
        title: 'Buy groceries',
        description: 'Milk, eggs, bread',
        completed: false
      });
      expect(todo.id).toBeDefined();
      expect(todo.createdAt).toBeInstanceOf(Date);
    });

    it('should throw error if title is missing', () => {
      expect(() => todoService.addTodo()).toThrow('Title is required');
      expect(() => todoService.addTodo('')).toThrow('Title is required');
    });
  });

  describe('completeTodo', () => {
    it('should mark todo as completed', () => {
      const todo = todoService.addTodo('Test todo');
      const completed = todoService.completeTodo(todo.id);
      
      expect(completed.completed).toBe(true);
      expect(completed.completedAt).toBeInstanceOf(Date);
    });
  });
});
```

### 5. Configure Git Hooks

```bash
# Claude Flow automatically sets up git hooks
# Verify they're working:
git add .
git commit -m "Initial commit"
```

**What happens during commit:**
```
🔍 Running pre-commit checks...
✅ ESLint: No issues found
✅ Prettier: All files formatted
✅ Tests: All tests passing (3/3)

Commit successful!
```

### 6. Add Scripts to package.json

Claude Flow automatically adds these scripts:

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
    "validate": "npm run lint && npm run format:check && npm test"
  }
}
```

### 7. Working with Claude

Now you can use Claude commands effectively:

```bash
# Ask Claude to add a new feature
claude add feature "Add todo filtering by status"

# Claude will:
# 1. Research existing code structure
# 2. Create a plan
# 3. Implement with tests
# 4. Ensure all checks pass
```

**Example Claude session:**
```
You: Add todo filtering by status

Claude: Let me research the codebase and create a plan before implementing.

*Researches existing TodoService implementation*

Plan:
1. Add filterByStatus method to TodoService
2. Support filtering by 'all', 'completed', 'pending'
3. Add comprehensive tests
4. Update documentation

*Implements the feature with tests*
*Runs validation checks*

✅ Implementation complete! All checks passing.
```

### 8. CI/CD Integration

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [18.x, 20.x]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run validation
      run: npm run validate
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info
```

## Complete Project Structure

After setup, your project structure should look like:

```
my-node-app/
├── .claude/
│   ├── commands/
│   └── hooks/
├── .github/
│   └── workflows/
│       └── ci.yml
├── src/
│   ├── index.js
│   └── app.js
├── tests/
│   └── app.test.js
├── .eslintrc.json
├── .prettierrc
├── .gitignore
├── CLAUDE.md
├── jest.config.js
├── Makefile
├── package.json
└── README.md
```

## Common Commands

```bash
# Development
npm run dev           # Start with auto-reload
npm test             # Run tests
npm run test:watch   # Run tests in watch mode

# Code quality
npm run lint         # Check for linting errors
npm run lint:fix     # Fix linting errors
npm run format       # Format all files

# Claude Flow
claude validate      # Run all checks
claude add feature   # Add new feature with Claude
claude refactor      # Refactor with Claude's help

# Git workflow
git add .
git commit -m "msg"  # Triggers automatic validation
```

## Tips for Success

1. **Always use Claude Flow commands** instead of manual implementation
2. **Commit frequently** - git hooks ensure quality at each commit
3. **Write tests first** - Claude can generate tests from descriptions
4. **Use the validate command** before pushing changes
5. **Leverage Claude's planning** - don't skip the research phase

## Troubleshooting

### ESLint errors on commit
```bash
# Fix automatically
npm run lint:fix

# Or use Claude
claude fix lint
```

### Test failures
```bash
# Run tests with details
npm test -- --verbose

# Use Claude to fix
claude fix tests
```

### Formatting issues
```bash
# Format all files
npm run format

# Check what needs formatting
npm run format:check
```

## Next Steps

- Explore [React app setup](./react-app.md) for frontend projects
- Learn about [CI/CD integration](./ci-cd-setup.md)
- Read the [migration guide](./migration-guide.md) for existing projects