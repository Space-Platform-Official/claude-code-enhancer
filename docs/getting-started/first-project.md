# Your First Project with Claude Flow

This tutorial walks you through setting up your first project with Claude Flow, from initial setup to using AI-assisted development workflows.

## Overview

In this tutorial, you'll:
- Set up a new web application project
- Configure Claude Flow for your technology stack
- Use Claude commands for development tasks
- Learn best practices for AI-assisted coding

**Time required**: 15-20 minutes

## Prerequisites

Before starting, ensure you have:
- Claude Flow installed ([Installation Guide](installation.md))
- Git installed
- A code editor (VS Code recommended)
- Basic command line familiarity

## Project Setup

### Step 1: Create Project Directory

Let's create a simple task management application:

```bash
# Create and enter project directory
mkdir task-manager
cd task-manager

# Initialize git repository
git init

# Create initial project structure
mkdir src tests docs
touch README.md .gitignore
```

### Step 2: Install Claude Flow

Now let's add Claude Flow to our project:

```bash
# Run Claude Flow installer
claude-install-flow
```

You'll see an interactive menu:

```
=== Claude Flow Template Installer ===

Select your primary language:
1) JavaScript/TypeScript
2) Python
3) Go
4) Rust
5) PHP
6) Multiple/Other

Enter choice [1-6]: 1
```

**Select 1** for JavaScript/TypeScript.

Next, you'll be asked about frameworks:

```
Select framework (optional):
1) React
2) Next.js
3) Express.js
4) None/Other

Enter choice [1-4]: 3
```

**Select 3** for Express.js (we're building a backend API).

### Step 3: Explore Generated Files

Claude Flow has created several files. Let's examine them:

```bash
# View the structure
ls -la
```

You should see:
```
.
├── .claude/
│   └── commands/
├── .gitignore
├── CLAUDE.md
├── README.md
├── docs/
├── src/
└── tests/
```

Let's look at the main configuration:

```bash
# View Claude configuration
cat CLAUDE.md
```

This file contains:
- Project context and goals
- Technology stack details
- Coding standards
- AI interaction guidelines

### Step 4: Initialize Node.js Project

Since we selected JavaScript/TypeScript:

```bash
# Initialize package.json
npm init -y

# Install Express and basic dependencies
npm install express cors dotenv
npm install -D @types/node @types/express typescript nodemon jest

# Create TypeScript config
npx tsc --init
```

## Using Claude Commands

### Understanding Command Templates

The `.claude/commands/` directory contains AI prompt templates:

```bash
# List available commands
ls .claude/commands/
```

You'll see:
- `architect.md` - System design assistance
- `debug.md` - Debugging help
- `optimize.md` - Performance optimization
- `refactor.md` - Code refactoring
- `review.md` - Code review
- `test-coverage.md` - Testing strategies

### Practical Example 1: Architecture Planning

Let's design our task manager architecture:

```bash
# Read the architect command
cat .claude/commands/architect.md
```

**Using with Claude**:
1. Copy the architect.md content
2. Add your specific requirements:
   ```
   I need to design a REST API for a task management system with:
   - User authentication
   - CRUD operations for tasks
   - Task categories and priorities
   - Due date tracking
   ```
3. Claude will provide a detailed architecture plan

**Sample Architecture Output**:
```typescript
// src/app.ts - Main application file
import express from 'express';
import cors from 'cors';
import { router as authRouter } from './routes/auth';
import { router as taskRouter } from './routes/tasks';

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRouter);
app.use('/api/tasks', taskRouter);

// Error handling middleware
app.use(errorHandler);

export default app;
```

### Practical Example 2: Implementation

Create the basic Express server:

```bash
# Create main application file
mkdir -p src/routes src/models src/middleware
touch src/app.ts src/server.ts
```

Edit `src/server.ts`:
```typescript
import app from './app';
import dotenv from 'dotenv';

dotenv.config();

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Practical Example 3: Debugging

When you encounter an error, use the debug command:

```bash
# Read debug command template
cat .claude/commands/debug.md
```

**Example debugging session**:
1. Copy debug.md content
2. Add your error:
   ```
   Error: Cannot find module './routes/auth'
   at Function.Module._resolveFilename
   ```
3. Claude will help you systematically debug

### Practical Example 4: Adding Tests

Use the test-coverage command for testing guidance:

```bash
# Create test file
mkdir -p tests
touch tests/app.test.ts

# Get testing guidance
cat .claude/commands/test-coverage.md
```

**Sample test file**:
```typescript
// tests/app.test.ts
import request from 'supertest';
import app from '../src/app';

describe('Task API', () => {
  test('GET /api/tasks returns task list', async () => {
    const response = await request(app)
      .get('/api/tasks')
      .expect(200);
    
    expect(Array.isArray(response.body)).toBe(true);
  });
});
```

## Development Workflow

### 1. Feature Development Cycle

When adding a new feature:

```bash
# Step 1: Plan with architect command
cat .claude/commands/architect.md
# Describe your feature requirements

# Step 2: Implement with AI assistance
# Use CLAUDE.md context for consistent coding

# Step 3: Review with review command
cat .claude/commands/review.md
# Get code quality feedback

# Step 4: Optimize if needed
cat .claude/commands/optimize.md
```

### 2. Debugging Workflow

When debugging issues:

```bash
# Step 1: Structured debugging
cat .claude/commands/debug.md

# Step 2: Add specific error context
# Include error messages, stack traces

# Step 3: Follow systematic debugging steps
# Claude will guide you through isolation and resolution
```

### 3. Refactoring Workflow

For code improvements:

```bash
# Step 1: Identify refactoring needs
cat .claude/commands/refactor.md

# Step 2: Plan refactoring approach
# Consider impact and testing needs

# Step 3: Execute with AI guidance
# Maintain functionality while improving structure
```

## Best Practices

### 1. Keep CLAUDE.md Updated

As your project evolves, update CLAUDE.md:

```markdown
## Recent Changes
- Added WebSocket support for real-time updates
- Implemented Redis caching layer
- Migrated to PostgreSQL from SQLite
```

### 2. Create Custom Commands

Add project-specific commands:

```bash
# Create custom command
touch .claude/commands/deploy.md
```

Edit `.claude/commands/deploy.md`:
```markdown
# Deployment Assistance

Help me deploy this task manager application:

## Current Setup
- Node.js/Express API
- PostgreSQL database
- Frontend React app

## Deployment Needs
1. Environment configuration
2. Database migration strategy
3. CI/CD pipeline setup
4. Monitoring and logging

## Constraints
- Budget: Minimal
- Expected traffic: 1000 users/day
- Region: US-East
```

### 3. Version Control Integration

Commit your Claude configuration:

```bash
# Add Claude files to git
git add CLAUDE.md .claude/
git commit -m "Add Claude Flow configuration"

# Team members can now pull and use same config
```

### 4. Continuous Improvement

Regularly review and update:
- Command templates based on project needs
- CLAUDE.md with new patterns and decisions
- Documentation with AI-assisted insights

## Complete Project Structure

By the end of this tutorial, your project structure should look like:

```
task-manager/
├── .claude/
│   └── commands/
│       ├── architect.md
│       ├── debug.md
│       ├── deploy.md (custom)
│       ├── optimize.md
│       ├── refactor.md
│       ├── review.md
│       └── test-coverage.md
├── .git/
├── .gitignore
├── CLAUDE.md
├── README.md
├── docs/
├── node_modules/
├── package.json
├── package-lock.json
├── src/
│   ├── app.ts
│   ├── server.ts
│   ├── middleware/
│   ├── models/
│   └── routes/
├── tests/
│   └── app.test.ts
├── tsconfig.json
└── .env
```

## Next Steps

Congratulations! You've successfully:
- ✅ Set up a project with Claude Flow
- ✅ Configured for your technology stack
- ✅ Used Claude commands for development
- ✅ Learned the AI-assisted workflow

### Continue Learning

1. **Explore More Commands**: Try each command in `.claude/commands/`
2. **Customize Configuration**: Tailor CLAUDE.md to your specific needs
3. **Create Templates**: Build custom commands for repeated tasks
4. **Share Knowledge**: Document patterns that work well

### Recommended Reading

- [Configuration Guide](configuration.md) - Advanced configuration options
- [Command Reference](../commands/README.md) - Detailed command documentation
- [Best Practices](../guides/best-practices.md) - Tips for effective AI collaboration

## Troubleshooting

### Common Issues

**Issue**: Commands not providing relevant help
- **Solution**: Update CLAUDE.md with more project context

**Issue**: Inconsistent code suggestions
- **Solution**: Define clear coding standards in CLAUDE.md

**Issue**: Generic responses from AI
- **Solution**: Use specific command templates and provide detailed context

### Getting Help

- Enable debug mode: `CLAUDE_DEBUG=1 claude-install-flow`
- Check [GitHub issues](https://github.com/your-repo/claude-flow/issues)
- Join the community discussions

## Summary

You've learned how to:
- Set up Claude Flow in a new project
- Use command templates for common tasks
- Integrate AI assistance into your workflow
- Maintain and customize your configuration

Claude Flow is now ready to enhance your development productivity!