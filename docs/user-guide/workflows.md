# Common Workflows and Use Cases

This guide demonstrates real-world workflows using Claude Flow across different project types and development scenarios.

## Quick Reference

| Scenario | Workflow | Key Commands |
|----------|----------|--------------|
| New Feature | Research → Architect → Implement | `/architect`, `/test-coverage` |
| Bug Fix | Debug → Fix → Test | `/debug`, `/review` |
| Performance | Profile → Optimize → Validate | `/optimize`, `/monitor` |
| Refactoring | Analyze → Plan → Refactor | `/refactor`, `/review` |
| API Development | Design → Implement → Document | `/api-design`, `/docs` |

## New Project Workflows

### Starting a React Application

```bash
# 1. Create and initialize project
npx create-react-app my-app
cd my-app
git init

# 2. Install Claude Flow templates
claude-install-flow
# Select: JavaScript → React

# 3. Customize for your needs
```

**Claude Conversation**:
```
You: Set up a new React app with TypeScript, testing, and our component library

Claude: I'll help you set up a new React app with TypeScript and testing. Let me start by researching the current setup and creating a plan.

[Uses /architect command to design the setup]
[Creates comprehensive plan]
[Implements with checkpoints]
```

### Building a Python API

```bash
# 1. Create project structure
mkdir python-api && cd python-api
python -m venv venv
source venv/bin/activate

# 2. Install Claude Flow
claude-install-flow
# Select: Python → None (or Django)

# 3. Initialize project
pip install fastapi uvicorn
```

**Workflow Steps**:
1. **Architecture Planning**
   ```
   You: /architect Design a REST API for user management with auth
   ```

2. **Implementation**
   ```
   You: Implement the user registration endpoint with validation
   ```

3. **Testing**
   ```
   You: /test-coverage Create comprehensive tests for the auth module
   ```

### Go Microservice Setup

```bash
# 1. Initialize Go module
mkdir user-service && cd user-service
go mod init github.com/company/user-service

# 2. Claude Flow setup
claude-install-flow
# Select: Go → None

# 3. Project structure
mkdir -p cmd/server pkg/handlers pkg/models
```

**Development Flow**:
```
You: Create a gRPC service for user management following our microservice patterns

Claude: I'll research the codebase and create a plan for implementing a gRPC user management service.

[Researches existing patterns]
[Creates architecture with /architect]
[Implements with proper error handling]
```

## Feature Development Workflows

### Complex Feature Implementation

**Scenario**: Adding real-time collaboration to an editor

**Phase 1 - Research**:
```
You: We need to add real-time collaboration to our editor. Research our current architecture.

Claude: I'll analyze the current editor architecture and identify integration points for real-time collaboration.
```

**Phase 2 - Architecture**:
```
You: /architect Design real-time collaboration with WebSockets and CRDTs

Claude: I'll create a comprehensive architecture for real-time collaboration...
[Generates ADR]
[Proposes multiple approaches]
[Creates implementation roadmap]
```

**Phase 3 - Implementation**:
```
You: Implement Phase 1 of the collaboration feature

Claude: I'll implement the WebSocket infrastructure and basic message passing...
[Implements with validation checkpoints]
```

### API Endpoint Addition

**Standard Workflow**:

1. **Design First**:
   ```
   You: /api-design Create endpoint for bulk user import with CSV
   ```

2. **Implementation**:
   ```
   You: Implement the bulk import endpoint with proper validation
   ```

3. **Testing**:
   ```
   You: Add comprehensive tests including edge cases
   ```

4. **Documentation**:
   ```
   You: /docs Update API documentation for the new endpoint
   ```

### Frontend Component Development

**React Component Workflow**:

```
You: Create a data table component with sorting, filtering, and pagination

Claude: I'll research our component patterns and create a plan for the data table component.

[Phase 1: Research existing components]
[Phase 2: Design component API]
[Phase 3: Implement with tests]
[Phase 4: Create usage documentation]
```

## Debugging Workflows

### Production Bug Investigation

**Emergency Bug Fix Flow**:

```bash
# 1. Create hotfix branch
git checkout -b hotfix/critical-user-auth-bug

# 2. Use Claude for debugging
```

```
You: /debug Users can't log in, getting 500 errors. Here's the error log: [paste log]

Claude: I'll analyze the error log and investigate the authentication issue.

[Identifies root cause]
[Proposes minimal fix]
[Adds regression test]
```

### Performance Debugging

**Slow Query Investigation**:

```
You: /debug The user dashboard is loading slowly, taking 5+ seconds

Claude: I'll investigate the performance issue in the user dashboard.

[Analyzes database queries]
[Profiles code execution]
[Identifies bottlenecks]
```

**Optimization Workflow**:

```
You: /optimize Improve the dashboard performance based on your findings

Claude: I'll optimize the dashboard performance using the identified bottlenecks.

[Implements query optimization]
[Adds caching layer]
[Validates improvements]
```

## Refactoring Workflows

### Large-Scale Refactoring

**Scenario**: Migrating from callbacks to async/await

```
You: /refactor Convert our callback-based API client to use async/await

Claude: I'll analyze the API client and create a refactoring plan to migrate from callbacks to async/await.

[Maps all callback usage]
[Creates migration strategy]
[Implements in phases]
[Maintains backward compatibility]
```

### Architecture Migration

**Monolith to Microservices**:

```
You: /architect Plan extraction of user service from monolith

Claude: I'll analyze the monolith and design the user service extraction.

[Identifies boundaries]
[Plans data migration]
[Creates transition strategy]
[Defines service contracts]
```

## Code Review Workflows

### Pre-Commit Review

```bash
# Before committing
git add .
```

```
You: /review Check my changes before I commit

Claude: I'll review your staged changes for code quality and best practices.

[Reviews code structure]
[Checks for issues]
[Suggests improvements]
[Validates against standards]
```

### PR Review Assistance

```
You: /review Review this PR for security and performance: [PR link]

Claude: I'll analyze the PR for security vulnerabilities and performance concerns.

[Security analysis]
[Performance review]
[Best practices check]
[Actionable feedback]
```

## Testing Workflows

### Test-Driven Development

**TDD Workflow**:

```
You: /test-coverage Design tests for a shopping cart class before implementation

Claude: I'll create comprehensive test cases for the shopping cart class following TDD principles.

[Defines test scenarios]
[Writes failing tests]
[Guides implementation]
[Ensures coverage]
```

### Regression Test Creation

```
You: Create regression tests for the bug we just fixed

Claude: I'll create comprehensive regression tests to prevent this bug from reoccurring.

[Analyzes bug scenario]
[Creates edge case tests]
[Adds to test suite]
[Documents test purpose]
```

## Deployment Workflows

### Continuous Deployment Setup

```
You: Set up GitHub Actions for our Node.js app with staging and production

Claude: I'll create a comprehensive CI/CD pipeline using GitHub Actions.

[Creates workflow file]
[Sets up environments]
[Adds quality gates]
[Implements rollback]
```

### Rollback Procedures

```
You: /rollback Production is broken after deploy, need immediate rollback

Claude: I'll guide you through the rollback procedure.

[Identifies rollback point]
[Executes rollback steps]
[Validates restoration]
[Creates incident report]
```

## Documentation Workflows

### API Documentation

```
You: /docs Generate OpenAPI documentation for our user service

Claude: I'll analyze the user service and generate comprehensive OpenAPI documentation.

[Scans endpoints]
[Documents schemas]
[Adds examples]
[Includes auth details]
```

### Project Documentation

```
You: Create comprehensive README for new developers

Claude: I'll create a detailed README that helps new developers get started quickly.

[Project overview]
[Setup instructions]
[Architecture guide]
[Contribution guidelines]
```

## Security Workflows

### Security Audit

```
You: /security-audit Check our authentication system for vulnerabilities

Claude: I'll perform a comprehensive security audit of the authentication system.

[Reviews auth flow]
[Checks for vulnerabilities]
[Tests edge cases]
[Provides remediation]
```

### Dependency Updates

```
You: /upgrade Review and update our dependencies for security patches

Claude: I'll analyze dependencies and create an upgrade plan for security patches.

[Scans vulnerabilities]
[Plans updates]
[Tests compatibility]
[Updates safely]
```

## Multi-Language Workflows

### Full-Stack Feature

**Frontend (React) + Backend (Python)**:

```
You: Implement user profile feature with React frontend and Python API

Claude: I'll implement the full-stack user profile feature. Let me plan this across both codebases.

[Designs API contract]
[Implements backend first]
[Creates frontend components]
[Integrates and tests]
```

### Microservice Communication

**Go Service + Node.js Service**:

```
You: Set up gRPC communication between user service (Go) and notification service (Node.js)

Claude: I'll implement gRPC communication between the two services.

[Defines protobuf schemas]
[Implements Go server]
[Creates Node.js client]
[Adds error handling]
```

## Migration Workflows

### Framework Migration

**Migrating from Express to Fastify**:

```
You: /migrate Plan migration from Express to Fastify

Claude: I'll create a comprehensive migration plan from Express to Fastify.

[Analyzes differences]
[Creates migration strategy]
[Implements adapter pattern]
[Migrates incrementally]
```

### Database Migration

```
You: Migrate from MongoDB to PostgreSQL for our user data

Claude: I'll plan and implement the database migration from MongoDB to PostgreSQL.

[Maps data models]
[Creates migration scripts]
[Implements dual-write]
[Validates data integrity]
```

## Optimization Workflows

### Performance Optimization

```
You: /optimize Our API response time is slow, optimize the product search

Claude: I'll analyze and optimize the product search performance.

[Profiles current performance]
[Identifies bottlenecks]
[Implements optimizations]
[Measures improvements]
```

### Bundle Size Optimization

```
You: /optimize Reduce our React app bundle size, currently at 2MB

Claude: I'll analyze and optimize the React application bundle size.

[Analyzes bundle composition]
[Identifies large dependencies]
[Implements code splitting]
[Lazy loads components]
```

## Team Collaboration Workflows

### Onboarding New Developer

```
You: Create onboarding tasks for a new backend developer joining next week

Claude: I'll create a comprehensive onboarding plan for the new backend developer.

[Environment setup guide]
[Codebase tour tasks]
[First PR assignment]
[Learning resources]
```

### Knowledge Transfer

```
You: Document the payment processing module for team handoff

Claude: I'll create detailed documentation for the payment processing module handoff.

[Architecture overview]
[Code walkthrough]
[Integration points]
[Maintenance guide]
```

## Emergency Workflows

### Production Incident

```
You: /monitor Production CPU is spiking, help diagnose

Claude: I'll help diagnose the CPU spike in production.

[Analyzes symptoms]
[Checks recent changes]
[Identifies causes]
[Provides fixes]
```

### Data Recovery

```
You: Accidentally deleted user data, need recovery plan

Claude: I'll help create a data recovery plan.

[Assesses damage]
[Checks backups]
[Plans recovery]
[Prevents future issues]
```

## Best Practices for Workflows

### 1. Always Start with Research
- Let Claude understand context
- Identify existing patterns
- Avoid reinventing wheels

### 2. Use Appropriate Commands
- Match command to task type
- Combine commands effectively
- Don't force wrong commands

### 3. Validate at Checkpoints
- After each major step
- Before moving to next phase
- Especially before deployment

### 4. Document Decisions
- Why approaches were chosen
- What alternatives were considered
- How to maintain/extend

### 5. Learn from Each Workflow
- What worked well?
- What could improve?
- Update team practices

## Workflow Templates

Create reusable workflow templates:

`.claude/workflows/feature-development.md`:
```markdown
# Feature Development Workflow

1. Research existing code: 30 min
2. Architecture design: 1 hour
3. Implementation plan: 30 min
4. Core implementation: 2-4 hours
5. Testing: 1-2 hours
6. Documentation: 30 min
7. Code review: 30 min

Total: 6-10 hours per feature
```

## Next Steps

- Review [Best Practices](best-practices.md) for optimization
- Explore [Customization](customization.md) for your workflows
- Check [Using Templates](using-templates.md) for setup
- Learn [Smart Merge](smart-merge.md) for updates