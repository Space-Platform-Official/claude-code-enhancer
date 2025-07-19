# Command Workflows and Development Patterns

This comprehensive guide demonstrates real-world workflows using Claude Code Enhancer across different project types and development scenarios. Learn how to leverage the command system, quality tools, and multi-agent coordination for efficient development.

## 📋 Table of Contents

- [Quick Reference](#quick-reference)
- [Core Workflow Patterns](#core-workflow-patterns)
- [Quality Workflows](#quality-workflows)
- [Git Integration Workflows](#git-integration-workflows)
- [Testing Workflows](#testing-workflows)
- [Milestone Management](#milestone-management)
- [Multi-Agent Coordination](#multi-agent-coordination)
- [Project Lifecycle Workflows](#project-lifecycle-workflows)
- [Emergency Response Workflows](#emergency-response-workflows)
- [Team Collaboration Patterns](#team-collaboration-patterns)

## Quick Reference

| Scenario | Workflow | Key Commands |
|----------|----------|--------------|
| **Code Quality** | Format → Cleanup → Verify | `claude format`, `claude cleanup`, `claude verify` |
| **Git Workflow** | Status → Commit → Push → PR | `claude status`, `claude commit`, `claude pr` |
| **Testing** | Unit → Integration → Coverage | `claude test unit`, `claude test integration`, `claude test coverage` |
| **Feature Development** | Research → Architect → Implement → Test | `claude architect`, `claude test unit` |
| **Bug Investigation** | Debug → Fix → Test → Verify | `claude debug`, `claude verify` |
| **Performance** | Profile → Optimize → Monitor | `claude optimize`, `claude monitor` |
| **Milestone Planning** | Plan → Execute → Status → Archive | `claude milestone plan`, `claude milestone execute` |
| **Project Setup** | Install → Configure → Verify | `claude-install-flow`, `claude verify` |

## Core Workflow Patterns

### The Standard Development Cycle

Every development task should follow this proven pattern:

```bash
# 1. Quality Check (Start Clean)
claude format && claude verify --quick

# 2. Work on Feature/Fix
# ... your development work ...

# 3. Quality Assurance (Before Commit)
claude format && claude cleanup && claude verify

# 4. Commit and Push
claude commit "feat: implement user authentication"
claude push

# 5. Create Pull Request (if needed)
claude pr "Add user authentication system"
```

### The Research → Plan → Implement Pattern

For complex features, always follow this three-phase approach:

**Phase 1: Research** (Understanding)
```bash
# Understand current codebase
claude architect --analyze-existing

# Research best practices for your task
# Use claude to explore patterns and approaches
```

**Phase 2: Plan** (Architecture)
```bash
# Create implementation plan
claude architect --design-feature "user authentication"

# Plan testing strategy
claude test coverage --plan
```

**Phase 3: Implement** (Execution)
```bash
# Implement in iterations with quality checks
claude format && claude verify  # Before starting
# ... implement ...
claude format && claude cleanup  # During development
# ... test ...
claude verify --comprehensive   # Before completion
```

## Quality Workflows

### Daily Quality Maintenance

**Morning Routine** (Start of day):
```bash
# Check project health
claude verify --quick

# Update and format any changes
claude format

# Check for any issues to address
claude cleanup --dry-run
```

**Development Cycle** (During work):
```bash
# Before making changes
claude format

# After implementing a feature
claude cleanup
claude verify

# Before committing
claude format && claude cleanup && claude verify
```

**End of Day** (Before leaving):
```bash
# Comprehensive quality check
claude verify --comprehensive

# Check for any duplicates introduced
claude dedupe --dry-run

# Ensure everything is committed
claude status
```

### Code Quality Deep Dive

**Weekly Quality Audit**:
```bash
# Comprehensive quality assessment
claude verify --comprehensive --report=detailed

# Find and resolve duplicates
claude dedupe --interactive --threshold=75

# Deep cleanup of dead code
claude cleanup --aggressive

# Generate quality metrics
claude verify --metrics --output=quality-report.json
```

**Pre-Release Quality Check**:
```bash
# Security-focused verification
claude verify --security-focus

# Comprehensive formatting with all tools
claude format --comprehensive

# Aggressive cleanup for production
claude cleanup --aggressive

# Final verification
claude verify --comprehensive --fail-fast
```

### Quality Tool Configuration

**Project-Specific Quality Setup**:
```json
// .claude-config.json
{
  "quality": {
    "auto_format_on_save": true,
    "verify_before_commit": true,
    "cleanup_aggressiveness": "conservative",
    "dedupe_threshold": 80,
    "format_tools": {
      "javascript": ["prettier", "eslint"],
      "python": ["black", "isort", "flake8"],
      "go": ["gofmt", "goimports"]
    }
  }
}
```

## Git Integration Workflows

### Standard Git Workflow with Quality

**Feature Branch Workflow**:
```bash
# 1. Create feature branch
git checkout -b feature/user-authentication

# 2. Set up quality baseline
claude format && claude verify

# 3. Implement feature with quality checks
# ... development work ...
claude format && claude cleanup

# 4. Comprehensive testing
claude test unit && claude test integration

# 5. Quality verification
claude verify --comprehensive

# 6. Commit with quality assurance
claude commit "feat: implement user authentication system"

# 7. Push and create PR
claude push
claude pr "Add user authentication with JWT and role-based access"
```

**Hotfix Workflow**:
```bash
# 1. Create hotfix branch
git checkout -b hotfix/critical-auth-bug

# 2. Quick quality check
claude verify --quick

# 3. Implement fix
# ... fix the bug ...

# 4. Quality verification
claude format && claude verify

# 5. Test the fix
claude test unit --focus=auth

# 6. Emergency commit and deploy
claude commit "fix: resolve critical authentication vulnerability"
claude push --verify
```

### Advanced Git Integration

**Automated Quality Hooks**:
```bash
# Pre-commit hook (add to .git/hooks/pre-commit)
#!/bin/bash
if ! claude verify --quick --exit-code; then
  echo "Quality checks failed. Run 'claude format && claude verify' to fix."
  exit 1
fi
```

**Pull Request Quality Reports**:
```bash
# Generate quality report for PR
claude verify --format=markdown > QUALITY_REPORT.md

# Add to PR description
claude pr "Feature implementation" --include-quality-report
```

## Testing Workflows

### Test-Driven Development (TDD)

**TDD Cycle with Claude**:
```bash
# 1. Write failing tests first
claude test unit --create-template UserAuthTest

# 2. Run tests (should fail)
claude test unit --watch

# 3. Implement minimal code to pass
# ... implement ...

# 4. Run tests (should pass)
claude test unit

# 5. Refactor with confidence
claude format && claude cleanup

# 6. Verify all tests still pass
claude test unit && claude test integration
```

### Comprehensive Testing Strategy

**Multi-Level Testing**:
```bash
# Unit tests (fast feedback)
claude test unit --parallel

# Integration tests (module interaction)
claude test integration --coverage

# End-to-end tests (full workflow)
claude test e2e --headless

# Performance tests (load and speed)
claude test performance --benchmark
```

**Coverage-Driven Testing**:
```bash
# Generate coverage report
claude test coverage --report=html

# Identify untested code
claude test coverage --missing

# Add tests for uncovered areas
claude test unit --focus=uncovered

# Verify improved coverage
claude test coverage --verify-threshold=80
```

### Test Maintenance

**Test Quality Assurance**:
```bash
# Find duplicate test logic
claude dedupe --focus=tests

# Clean up test imports and utilities
claude cleanup --tests-only

# Verify test code quality
claude verify --tests-focus

# Fix failing tests
claude test fix --interactive
```

## Milestone Management

### Project Planning with Milestones

**Create New Milestone**:
```bash
# Plan milestone with requirements gathering
claude milestone plan "Q4 User Management Features"

# Define success criteria and deliverables
claude milestone plan --interactive --add-requirements

# Set timeline and dependencies
claude milestone plan --timeline=8weeks --dependencies
```

**Execute Milestone**:
```bash
# Start milestone execution
claude milestone execute

# Track daily progress
claude milestone status --daily

# Handle blockers and issues
claude milestone execute --resolve-blockers

# Update milestone progress
claude milestone update --progress=60 --notes="Auth completed, working on permissions"
```

**Milestone Monitoring**:
```bash
# Check milestone health
claude milestone status --comprehensive

# Generate progress reports
claude milestone status --report=detailed --format=markdown

# Review and adjust timeline
claude milestone update --extend-deadline=1week --reason="Additional security requirements"
```

### Milestone Quality Gates

**Quality Checkpoints**:
```bash
# Quality gate before milestone completion
claude verify --comprehensive --milestone-gate

# Performance verification
claude test performance --milestone-baseline

# Security audit
claude verify --security-focus --milestone-critical

# Documentation completeness
claude docs --verify-completeness --milestone
```

## Multi-Agent Coordination

### Spawning Agents for Parallel Work

**Complex Feature Implementation**:
```bash
# Primary agent coordinates overall implementation
# Agent 1: Backend API development
# Agent 2: Frontend component implementation  
# Agent 3: Testing and quality assurance
# Agent 4: Documentation and examples

# Example coordination:
# "I'll spawn agents to tackle different aspects of the user authentication feature"
# "Agent 1 will handle the JWT backend implementation"
# "Agent 2 will create the React authentication components"
# "Agent 3 will develop comprehensive test suites"
# "Agent 4 will create usage documentation and examples"
```

**Parallel Quality Operations**:
```bash
# When safe, quality operations can run in parallel:
# Agent 1: claude verify (read-only analysis)
# Agent 2: claude dedupe --dry-run (read-only duplicate detection)
# Main: Wait for analysis, then apply changes sequentially
# Agent 3: claude format (after analysis complete)
# Agent 4: claude cleanup (after formatting complete)
```

### Agent Coordination Patterns

**Research and Implementation**:
```
Primary: "I need to implement a complex payment processing system"

Coordination Strategy:
- Agent 1: Research existing payment integrations in codebase
- Agent 2: Research industry best practices and security requirements
- Agent 3: Analyze current architecture for integration points
- Primary: Synthesize findings and create implementation plan
- Agent 4: Implement core payment logic
- Agent 5: Implement security and error handling
- Agent 6: Create comprehensive tests
```

**Large Codebase Analysis**:
```
Task: "Analyze this 500+ file codebase for security vulnerabilities"

Agent Distribution:
- Agent 1: Scan authentication and authorization code
- Agent 2: Review data access and validation layers
- Agent 3: Analyze external integrations and APIs
- Agent 4: Check configuration and environment handling
- Agent 5: Review error handling and logging
- Primary: Consolidate findings and prioritize fixes
```

## Project Lifecycle Workflows

### New Project Setup

**Starting a React Application**:
```bash
# 1. Create and initialize project
npx create-react-app my-app --template typescript
cd my-app
git init

# 2. Install Claude Code Enhancer templates
claude-install-flow
# Select: JavaScript → React → TypeScript → Testing

# 3. Set up quality baseline
claude format && claude verify

# 4. Create first milestone
claude milestone plan "Initial Setup and Core Components"

# 5. Verify everything works
claude test unit && claude verify --comprehensive
```

**Building a Python API**:
```bash
# 1. Create project structure
mkdir python-api && cd python-api
python -m venv venv
source venv/bin/activate

# 2. Install Claude Code Enhancer templates
claude-install-flow
# Select: Python → FastAPI/Django → Testing → Documentation

# 3. Set up project dependencies
pip install fastapi uvicorn pytest

# 4. Quality baseline
claude format && claude verify

# 5. Plan API architecture
claude milestone plan "Core API Development"

# 6. Implement with quality checks
# ... development work ...
claude format && claude cleanup && claude verify
```

**Building a Go Microservice**:
```bash
# 1. Initialize Go module
mkdir user-service && cd user-service
go mod init github.com/company/user-service

# 2. Claude Code Enhancer setup
claude-install-flow
# Select: Go → Standard Library → gRPC → Testing

# 3. Create project structure
mkdir -p cmd/server pkg/handlers pkg/models

# 4. Quality verification
claude format && claude verify

# 5. Plan service architecture
claude milestone plan "User Service MVP"
```

## Emergency Response Workflows

### Production Incident Response

**Critical Bug Fix Pipeline**:
```bash
# 1. Create emergency branch
git checkout -b hotfix/critical-production-issue

# 2. Quick triage
claude verify --quick --focus=critical

# 3. Implement minimal fix
# ... emergency fix ...

# 4. Fast quality check
claude format && claude verify --critical-only

# 5. Emergency testing
claude test unit --focus=affected-module

# 6. Deploy pipeline
claude commit "fix: resolve critical production issue"
claude push --emergency
```

**System Outage Response**:
```bash
# 1. Immediate assessment
claude monitor --production --alert=critical

# 2. Rollback if needed
claude rollback --to-last-stable

# 3. Root cause analysis
claude debug --production-logs --analyze

# 4. Implement fix
# ... fix implementation ...

# 5. Gradual rollout
claude deploy --canary --monitor
```

### Data Recovery Procedures

**Accidental Data Loss**:
```bash
# 1. Stop further damage
claude monitor --stop-operations

# 2. Assess backup situation
claude backup --list --recent

# 3. Plan recovery
claude recovery --plan --assess-impact

# 4. Execute recovery
claude recovery --execute --verify-integrity

# 5. Validate restoration
claude verify --data-integrity --comprehensive
```

## Team Collaboration Patterns

### Onboarding New Developers

**New Team Member Setup**:
```bash
# 1. Environment setup
claude-install-flow --team-config

# 2. Codebase introduction
claude docs --generate-overview --for-newcomer

# 3. Practice workflows
claude milestone plan "Onboarding: First Feature Implementation"

# 4. Quality training
claude verify --learning-mode --explain-issues
```

### Code Review Integration

**PR Review Workflow**:
```bash
# 1. Generate quality report for PR
claude verify --pr-report --comprehensive

# 2. Check for common issues
claude review --checklist --team-standards

# 3. Verify testing coverage
claude test coverage --pr-diff

# 4. Security review
claude verify --security-focus --pr-critical
```

### Knowledge Sharing

**Documentation Generation**:
```bash
# 1. Generate project overview
claude docs --generate-architecture-overview

# 2. Create onboarding guides
claude docs --onboarding-workflow

# 3. Document team practices
claude docs --team-workflows --best-practices

# 4. Maintain decision records
claude docs --adr --update-decisions
```

## Advanced Configuration and Customization

### Team-Wide Standards

**Shared Quality Configuration**:
```json
// .claude-team-config.json (shared across team)
{
  "team": {
    "name": "Backend Team",
    "standards": {
      "quality_gate": "comprehensive",
      "test_coverage_minimum": 80,
      "security_scan_required": true,
      "code_review_required": true
    },
    "workflows": {
      "default_branch_workflow": "feature-branch-with-quality",
      "hotfix_workflow": "emergency-fast-track",
      "release_workflow": "comprehensive-quality-gate"
    },
    "tools": {
      "formatters": {
        "javascript": ["prettier", "eslint"],
        "python": ["black", "isort", "flake8"],
        "go": ["gofmt", "goimports", "golangci-lint"]
      },
      "required_tools": ["security-scanner", "dependency-checker"]
    }
  }
}
```

### Environment-Specific Workflows

**Development Environment**:
```bash
export CLAUDE_ENV=development
export CLAUDE_QUALITY_MODE=interactive
export CLAUDE_TEST_MODE=watch
claude verify --quick --non-blocking
```

**CI/CD Environment**:
```bash
export CLAUDE_ENV=ci
export CLAUDE_QUALITY_MODE=strict
export CLAUDE_FAIL_FAST=true
claude verify --comprehensive --fail-fast --format=junit
```

**Production Environment**:
```bash
export CLAUDE_ENV=production
export CLAUDE_QUALITY_MODE=critical
export CLAUDE_SECURITY_FOCUS=true
claude verify --security-focus --comprehensive --audit-trail
```

## Performance and Scale Workflows

### Large Codebase Optimization

**Handling 1000+ File Projects**:
```bash
# 1. Parallel processing optimization
export CLAUDE_MAX_PARALLEL=8
export CLAUDE_CACHE_SIZE=1GB
export CLAUDE_STREAMING_MODE=true

# 2. Targeted operations
claude verify --incremental --changed-files-only
claude format --batch-size=100 --parallel
claude cleanup --conservative --exclude-large-files

# 3. Progress monitoring
claude monitor --progress --eta --resource-usage
```

### CI/CD Performance Tuning

**Fast Feedback Loops**:
```bash
# Quick quality gate (< 2 minutes)
claude verify --quick --changed-files --fail-fast

# Parallel test execution
claude test unit --parallel --max-workers=4

# Incremental verification
claude verify --incremental --cache-previous-results
```

### Complex Feature Implementation

**Multi-Phase Feature Development**:
```bash
# Phase 1: Research and Planning
claude architect --research-existing-patterns
claude milestone plan "Real-time Collaboration Feature"

# Phase 2: Foundation Development
claude format && claude verify  # Start clean
# ... implement core infrastructure ...
claude test unit --focus=core
claude verify --comprehensive

# Phase 3: Feature Implementation
# ... implement feature logic ...
claude format && claude cleanup
claude test integration --new-feature
claude verify --security-focus

# Phase 4: Integration and Testing
claude test e2e --collaboration-scenarios
claude test performance --websocket-load
claude verify --comprehensive

# Phase 5: Documentation and Deployment
claude docs --feature-documentation
claude milestone execute --final-review
```

### API Development Workflow

**RESTful API Implementation**:
```bash
# 1. Design API contract
claude architect --api-design "user management endpoints"

# 2. Implement with TDD
claude test unit --api-contract-tests
# ... implement endpoints ...
claude test integration --api-tests

# 3. Security and validation
claude verify --security-focus --api-endpoints
claude test security --api-penetration

# 4. Documentation
claude docs --api-documentation --openapi
claude test e2e --api-workflows
```

## Best Practices Summary

### Workflow Principles

1. **Quality First**: Always start and end with quality checks
2. **Incremental Progress**: Use milestones to track and validate progress
3. **Safety Nets**: Use git integration and backup systems
4. **Parallel Efficiency**: Leverage multi-agent coordination for complex tasks
5. **Continuous Feedback**: Use testing and verification at every step

### Common Patterns

**The Golden Workflow** (Most Used):
```bash
claude format && claude verify --quick    # Start clean
# ... development work ...
claude format && claude cleanup           # Clean as you go
claude test unit                          # Verify functionality
claude verify --comprehensive             # Final quality check
claude commit "feat: description"         # Commit with quality
claude push && claude pr "title"          # Share with team
```

**The Emergency Workflow** (Production Issues):
```bash
claude verify --quick --critical-only     # Quick triage
# ... minimal fix ...
claude format && claude verify --critical # Fast validation
claude test unit --affected-only          # Targeted testing
claude commit "fix: critical issue"       # Emergency commit
claude push --emergency                   # Fast deployment
```

**The Research Workflow** (Complex Features):
```bash
claude architect --research-existing      # Understand current state
claude milestone plan "feature-name"      # Plan implementation
# ... iterative development with quality checks ...
claude milestone status                   # Track progress
claude milestone execute --final-review   # Complete milestone
```

### Integration Tips

**IDE Integration**:
- Set up format-on-save with Claude
- Use watch mode for continuous feedback
- Integrate quality checks into editor workflow

**CI/CD Integration**:
- Add quality gates to build pipeline
- Use parallel execution for speed
- Generate quality reports for pull requests

**Team Integration**:
- Share quality configurations
- Establish team workflow standards
- Use milestone tracking for project coordination

## Next Steps

### Learning Path

**Beginner** (First Week):
1. Master the golden workflow pattern
2. Set up project with `claude-install-flow`
3. Practice quality commands daily
4. Learn basic git integration

**Intermediate** (First Month):
1. Customize quality configurations
2. Set up CI/CD integration
3. Use milestone management
4. Practice emergency workflows

**Advanced** (Ongoing):
1. Master multi-agent coordination
2. Create custom workflow templates
3. Optimize for large codebases
4. Lead team adoption and training

### Resources and References

- **[Getting Started Guide](getting-started.md)** - Initial setup and basic usage
- **[Template Guide](using-templates.md)** - Understanding and customizing templates
- **[Quality System Documentation](../commands/quality-system-architecture.md)** - Deep dive into quality tools
- **[Best Practices](best-practices.md)** - Professional tips and advanced techniques
- **[Troubleshooting](../troubleshooting/)** - Common issues and solutions

### Quick Commands Reference

**Daily Commands**:
```bash
claude format                    # Format code
claude verify                    # Check quality
claude test unit                 # Run tests
claude status                    # Git status
claude commit "message"          # Quality commit
```

**Weekly Commands**:
```bash
claude cleanup --aggressive      # Deep cleanup
claude dedupe --interactive      # Find duplicates
claude verify --comprehensive    # Full audit
claude milestone status          # Track progress
```

**Project Commands**:
```bash
claude-install-flow             # Set up new project
claude milestone plan           # Plan project phase
claude test coverage            # Check test coverage
claude docs --generate          # Update documentation
```

---

This comprehensive workflows guide provides the foundation for efficient development using Claude Code Enhancer. Each workflow is designed to maintain high quality while maximizing development velocity through intelligent automation and coordination.
