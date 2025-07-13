# Quality Usage Guide: Practical Implementation and Best Practices

## Overview

This comprehensive guide provides practical examples, workflow recommendations, and troubleshooting guidance for effectively using the orchestrated quality command suite. Whether you're migrating from the monolithic check approach or implementing quality workflows for the first time, this guide will help you maximize the benefits of the new architecture.

## Quick Start: From Monolithic to Orchestrated

### Migration from `check.md`

If you're familiar with the old monolithic `claude check` command, here's how to transition to the new orchestrated approach:

```bash
# OLD: Monolithic approach
claude check                    # Everything or nothing

# NEW: Orchestrated approach - Choose your workflow
claude quality                  # Complete workflow (equivalent to old check)
claude format                   # Just formatting
claude verify                   # Just verification  
claude cleanup                  # Just cleanup
claude dedupe                   # Just deduplication

# NEW: Intelligent composition
claude format && claude verify  # Format then verify
claude quality --workflow=fast  # Quick essential checks
claude quality --selective      # Interactive command selection
```

### Understanding the New Command Structure

```yaml
Command Hierarchy:
├── claude quality             # Orchestrated workflows
│   ├── --workflow=standard    # Default comprehensive workflow
│   ├── --workflow=fast        # Quick essential checks
│   ├── --workflow=thorough    # Complete analysis
│   └── --selective            # Interactive selection
├── claude format              # Code formatting only
├── claude cleanup             # Dead code removal only
├── claude dedupe              # Duplicate detection only
└── claude verify              # Quality verification only
```

## Individual Command Usage

### Format Command: Code Formatting and Style

The format command specializes in code formatting, import organization, and style consistency.

#### Basic Usage Examples

```bash
# Format all files in current directory
claude format

# Format specific files or directories
claude format src/
claude format src/components/Header.tsx
claude format *.js

# Dry run to preview changes
claude format --dry-run
claude format --dry-run --verbose  # Show detailed changes

# Format with specific formatters
claude format --formatter=prettier
claude format --formatter=eslint,prettier
claude format --formatter=black,isort  # Python
```

#### Advanced Formatting Options

```bash
# Comprehensive formatting with multiple passes
claude format --comprehensive
# - First pass: Basic syntax formatting
# - Second pass: Import organization
# - Third pass: Comment alignment
# - Fourth pass: Final validation

# Language-specific formatting
claude format --language=javascript --config=.prettierrc
claude format --language=python --line-length=88
claude format --language=go --gofmt-style=tab

# Import organization
claude format --organize-imports
claude format --remove-unused-imports
claude format --group-imports  # Group by type (stdlib, third-party, local)
```

#### Project-Specific Formatting

```bash
# Frontend JavaScript/TypeScript projects
claude format \
  --formatter=prettier,eslint \
  --organize-imports \
  --jsx-indent=2 \
  --trailing-comma=es5

# Python projects
claude format \
  --formatter=black,isort \
  --line-length=88 \
  --import-sorting=natural \
  --remove-unused-imports

# Go projects  
claude format \
  --formatter=gofmt,goimports \
  --simplify-code \
  --organize-imports \
  --remove-unused-vars

# Multi-language projects
claude format \
  --auto-detect-language \
  --respect-gitignore \
  --config-discovery=auto
```

### Cleanup Command: Dead Code and Import Management

The cleanup command intelligently removes unused code, imports, and variables while preserving functionality.

#### Basic Cleanup Operations

```bash
# Standard cleanup (conservative by default)
claude cleanup

# Preview cleanup changes
claude cleanup --dry-run
claude cleanup --dry-run --detailed  # Show reasoning for each change

# Aggressive cleanup (removes more items)
claude cleanup --aggressive
claude cleanup --aggressive --backup  # Create backup first

# Conservative cleanup (high confidence only)
claude cleanup --conservative
claude cleanup --conservative --threshold=95  # 95% confidence required
```

#### Targeted Cleanup Operations

```bash
# Specific cleanup types
claude cleanup --imports-only           # Only unused imports
claude cleanup --dead-code-only        # Only unused functions/classes
claude cleanup --variables-only        # Only unused variables
claude cleanup --debug-statements      # Only debug/console statements

# File type specific cleanup
claude cleanup --python-only
claude cleanup --javascript-only
claude cleanup --exclude="*.test.js"

# Scope-limited cleanup
claude cleanup src/components/         # Specific directory
claude cleanup --max-changes=10        # Limit number of changes
claude cleanup --file-size-limit=1MB   # Skip large files
```

#### Advanced Cleanup Configuration

```bash
# Custom cleanup rules
claude cleanup --config=.claude/cleanup-config.yaml

# Example cleanup-config.yaml:
preservation_rules:
  always_keep:
    - pattern: "test_*"        # Test helper functions
    - pattern: "@preserve"     # Marked with preserve comment
    - pattern: "mock_*"        # Mock functions
    - annotation: "# noqa"     # Explicitly marked
  
  context_aware:
    - dynamic_imports: preserve    # require(`./modules/${name}`)
    - event_handlers: preserve     # addEventListener callbacks
    - framework_lifecycle: preserve # React lifecycle methods

confidence_thresholds:
  imports: 85          # 85% confidence for import removal
  functions: 90        # 90% confidence for function removal  
  variables: 95        # 95% confidence for variable removal
  classes: 98          # 98% confidence for class removal
```

### Dedupe Command: Duplicate Detection and Merging

The dedupe command finds and intelligently handles code duplication at multiple levels.

#### Basic Duplicate Detection

```bash
# Find all duplicates
claude dedupe

# Interactive mode for guided decisions
claude dedupe --interactive
# Shows each duplicate with options:
# [M]erge [K]eep both [S]kip [D]etails [Q]uit

# Analysis only (no changes)
claude dedupe --analysis-only
claude dedupe --report=duplicates-report.html

# Set similarity threshold
claude dedupe --threshold=75    # 75% similarity required
claude dedupe --threshold=90    # 90% similarity required (stricter)
```

#### Advanced Duplicate Analysis

```bash
# Different analysis levels
claude dedupe --level=exact         # Only exact duplicates
claude dedupe --level=structural    # AST-based comparison
claude dedupe --level=semantic      # Behavioral similarity
claude dedupe --level=all          # All analysis types

# Specific duplicate types
claude dedupe --functions-only      # Only duplicate functions
claude dedupe --blocks-only        # Only code blocks
claude dedupe --files-only         # Only duplicate files
claude dedupe --imports-only       # Only duplicate imports

# Context-aware deduplication
claude dedupe --preserve-tests      # Keep test duplicates
claude dedupe --preserve-configs    # Keep configuration duplicates
claude dedupe --preserve-examples   # Keep example code duplicates
```

#### Safe Merging Strategies

```bash
# Automatic merging (high confidence only)
claude dedupe --auto-merge --confidence=95

# Manual review for each merge
claude dedupe --manual-review
# For each duplicate group:
# 1. Shows similarity analysis
# 2. Displays merge preview
# 3. Requests user decision
# 4. Applies merge with backup

# Batch processing similar duplicates
claude dedupe --batch-similar
# Groups similar duplicates and applies same decision to all

# Custom merge strategies
claude dedupe --merge-strategy=performance  # Keep fastest version
claude dedupe --merge-strategy=newest      # Keep most recent version
claude dedupe --merge-strategy=tested      # Keep version with tests
```

### Verify Command: Quality Validation and Compliance

The verify command provides comprehensive quality checking and compliance validation.

#### Basic Verification

```bash
# Standard verification
claude verify

# Quick syntax-only check
claude verify --quick
claude verify --syntax-only

# Comprehensive verification
claude verify --comprehensive
claude verify --all-checks

# Specific verification types
claude verify --security-only      # Security vulnerabilities
claude verify --style-only        # Code style compliance
claude verify --performance-only  # Performance issues
```

#### Detailed Quality Reports

```bash
# Generate detailed reports
claude verify --report=detailed
claude verify --report=summary
claude verify --report=metrics

# Multiple output formats
claude verify --format=text        # Console output
claude verify --format=json       # Machine readable
claude verify --format=html       # Rich web report
claude verify --format=junit      # CI/CD integration

# Custom report options
claude verify \
  --report=comprehensive \
  --format=html \
  --output=quality-report.html \
  --include-metrics \
  --include-trends
```

#### CI/CD Integration Verification

```bash
# Fail-fast mode for CI pipelines
claude verify --fail-fast          # Stop on first error
claude verify --fail-on-warnings   # Treat warnings as errors
claude verify --exit-code=issues   # Non-zero exit on any issues

# Incremental verification (only changed files)
claude verify --incremental
claude verify --since=HEAD~1       # Changes since last commit
claude verify --changed-files      # Only git modified files

# Performance optimized for CI
claude verify \
  --parallel \
  --cache-enabled \
  --quick-feedback \
  --essential-only
```

## Workflow Recommendations

### Development Workflows

#### Daily Development Workflow

```bash
# Morning routine: Check project health
claude verify --quick               # Quick health check
claude format --dry-run            # Preview needed formatting

# During development: Fast feedback
claude format src/components/Header.tsx  # Format current file
claude verify --file=Header.tsx --quick  # Quick check current file

# Before commit: Ensure quality
claude format                       # Format all changed files
claude verify --incremental        # Verify changes
claude cleanup --conservative      # Safe cleanup only
```

#### Feature Development Workflow

```bash
# Start of feature: Baseline quality
claude verify --comprehensive > feature-baseline.txt

# During feature development:
claude format --incremental        # Format as you go
claude verify --quick --watch      # Continuous verification

# End of feature: Complete quality check
claude quality --workflow=feature-complete
# Equivalent to:
# 1. claude format --comprehensive
# 2. claude cleanup --conservative
# 3. claude dedupe --analysis-only
# 4. claude verify --comprehensive
```

#### Code Review Preparation

```bash
# Pre-review quality preparation
claude quality --workflow=review-prep
# Optimized workflow:
# 1. Format all files consistently
# 2. Remove obvious dead code
# 3. Generate quality report
# 4. Create improvement suggestions

# Generate review artifacts
claude verify --report=review --format=html
claude dedupe --analysis-only --report=duplicates.md
claude cleanup --dry-run --report=cleanup-opportunities.md
```

### Team Collaboration Workflows

#### Onboarding New Team Members

```bash
# Setup quality standards for new developer
claude quality --setup-team-standards
# Creates:
# - .claude/team-config.yaml (shared configuration)
# - .git/hooks/pre-commit (quality hooks)
# - docs/quality-standards.md (team guidelines)

# Initial project quality assessment
claude verify --comprehensive --report=onboarding-report.html
# Provides complete project quality overview for new team members
```

#### Team Quality Sync

```bash
# Weekly team quality review
claude quality --team-report --since=7days
# Generates:
# - Quality trend analysis
# - Team adherence metrics
# - Improvement opportunities
# - Technical debt summary

# Quarterly quality planning
claude quality --planning-report --comprehensive
# Provides:
# - Long-term quality trends
# - Investment recommendations
# - Tool and process improvements
# - Training needs assessment
```

### Project-Specific Workflows

#### Frontend React/Vue Projects

```bash
# React-specific quality workflow
claude quality --preset=react
# Optimized for React projects:
# - JSX formatting with prettier
# - ESLint with React rules
# - Component import organization
# - Unused prop detection
# - Performance anti-pattern detection

# Component-focused cleanup
claude cleanup \
  --preserve-components \
  --unused-props \
  --unused-state \
  --lifecycle-methods

# React-specific verification
claude verify \
  --react-hooks \
  --accessibility \
  --performance \
  --bundle-size
```

#### Backend API Projects

```bash
# API-specific quality workflow
claude quality --preset=api
# Optimized for API projects:
# - Route handler formatting
# - Database query optimization
# - Security vulnerability scanning
# - API documentation validation

# Backend cleanup focus
claude cleanup \
  --preserve-handlers \
  --unused-middleware \
  --unused-routes \
  --database-connections

# API security verification
claude verify \
  --security-comprehensive \
  --sql-injection \
  --authentication \
  --authorization \
  --input-validation
```

#### Library/Package Development

```bash
# Library-specific workflow
claude quality --preset=library
# Optimized for library development:
# - Public API consistency
# - Documentation completeness
# - Export optimization
# - Backwards compatibility

# Library-focused verification
claude verify \
  --api-breaking-changes \
  --documentation-coverage \
  --export-consistency \
  --semver-compliance
```

## Troubleshooting Common Issues

### Format Command Issues

#### Issue: Conflicting Formatters
```bash
# Problem: Multiple formatters with conflicting rules
Error: prettier and eslint have conflicting rules for indentation

# Solution 1: Use compatible configuration
claude format --formatter=prettier --eslint-integration

# Solution 2: Sequential formatting with conflict resolution
claude format --formatter=prettier --resolve-conflicts
claude format --formatter=eslint --fix-only

# Solution 3: Custom configuration priority
claude format --config-priority=prettier,.eslintrc,default
```

#### Issue: Large File Formatting Timeout
```bash
# Problem: Formatting hangs on very large files
Warning: Timeout formatting large-file.js (10MB)

# Solution 1: Increase timeout
claude format --timeout=300 large-file.js

# Solution 2: Skip large files
claude format --max-file-size=5MB

# Solution 3: Chunk processing
claude format --chunk-size=1MB large-file.js
```

#### Issue: Formatter Not Found
```bash
# Problem: Required formatter not installed
Error: prettier not found in PATH

# Solution 1: Install missing formatter
npm install -g prettier
# or
pip install black

# Solution 2: Use alternative formatter
claude format --formatter=alternative --fallback-enabled

# Solution 3: Skip missing formatters
claude format --ignore-missing-formatters
```

### Cleanup Command Issues

#### Issue: False Positive Dead Code Detection
```bash
# Problem: Cleanup wants to remove code that's actually used
Warning: Function 'dynamicHandler' appears unused but may be called dynamically

# Solution 1: Add preservation marker
# @preserve - Called dynamically via event system
function dynamicHandler() { ... }

# Solution 2: Configuration exception
claude cleanup --preserve-pattern="*Handler" --preserve-dynamic

# Solution 3: Interactive mode for review
claude cleanup --interactive --conservative
```

#### Issue: Overly Aggressive Cleanup
```bash
# Problem: Cleanup removes too much code
Error: Cleanup removed 50 functions, breaking build

# Solution 1: Use conservative mode
claude cleanup --conservative --confidence=95

# Solution 2: Gradual cleanup approach
claude cleanup --max-changes=5 --review-each

# Solution 3: Rollback and adjust
claude cleanup --rollback
claude cleanup --dry-run --detailed  # Review before applying
```

#### Issue: Cleanup Breaks Tests
```bash
# Problem: Tests fail after cleanup
Error: 15 tests failing after cleanup operation

# Solution 1: Automatic rollback on test failure
claude cleanup --test-on-complete --rollback-on-failure

# Solution 2: Test-aware cleanup
claude cleanup --preserve-test-utilities --preserve-mocks

# Solution 3: Manual recovery
claude cleanup --rollback --to-snapshot=pre-cleanup
```

### Dedupe Command Issues

#### Issue: Incorrect Duplicate Detection
```bash
# Problem: Functions with similar structure but different purposes detected as duplicates
Warning: Functions 'validateUser' and 'validateProduct' detected as 85% similar

# Solution 1: Semantic analysis mode
claude dedupe --semantic-analysis --business-logic-aware

# Solution 2: Increase similarity threshold
claude dedupe --threshold=95  # More strict matching

# Solution 3: Manual review mode
claude dedupe --manual-review --show-context
```

#### Issue: Merge Conflicts During Deduplication
```bash
# Problem: Automatic merge creates conflicts
Error: Merge conflict in dependency resolution

# Solution 1: Conservative merging only
claude dedupe --conservative-merge --no-auto-merge

# Solution 2: Preview merges before applying
claude dedupe --preview-merge --interactive

# Solution 3: Handle conflicts manually
claude dedupe --merge-strategy=manual --preserve-on-conflict
```

### Verify Command Issues

#### Issue: Too Many False Positive Warnings
```bash
# Problem: Verification reports many irrelevant warnings
Warning: 127 style violations detected

# Solution 1: Adjust verification strictness
claude verify --level=essential --ignore-style-minor

# Solution 2: Custom verification profile
claude verify --profile=team-standards --ignore-legacy

# Solution 3: Graduated verification approach
claude verify --quick          # Start with major issues only
claude verify --standard       # Add medium priority issues
claude verify --comprehensive  # Include all issues
```

#### Issue: Performance Problems with Large Codebases
```bash
# Problem: Verification takes too long on large projects
Status: Analyzing 50,000 files... (still running after 10 minutes)

# Solution 1: Incremental verification
claude verify --incremental --changed-files-only

# Solution 2: Parallel processing
claude verify --parallel --max-workers=8

# Solution 3: Selective verification
claude verify --essential-only --skip-non-critical
```

### General Workflow Issues

#### Issue: Commands Interfering with Each Other
```bash
# Problem: Format undoes cleanup changes
Warning: Format operation modified files that cleanup just processed

# Solution 1: Use orchestrated workflow
claude quality --workflow=coordinated
# Ensures proper command ordering and coordination

# Solution 2: Sequential execution with validation
claude format --validate-before
claude cleanup --respect-formatting
claude verify --final-check

# Solution 3: Isolated execution
claude format --isolated
claude cleanup --isolated --after-format
```

#### Issue: Inconsistent Results Across Team
```bash
# Problem: Different team members get different quality results
Error: Quality checks pass locally but fail in CI

# Solution 1: Shared team configuration
claude quality --setup-team-config --version-control=git
# Creates shared .claude/team-config.yaml

# Solution 2: Environment normalization
claude quality --normalize-environment --docker-mode

# Solution 3: CI/CD configuration sync
claude quality --ci-config-export > .github/workflows/quality.yml
```

## Recovery Procedures

### Emergency Recovery

#### Complete Operation Rollback
```bash
# List available recovery points
claude quality --list-snapshots

# Rollback to specific snapshot
claude quality --rollback-to=2024-01-15T10:30:00Z

# Emergency rollback to last known good state
claude quality --emergency-rollback

# Verify rollback success
claude verify --post-rollback-check
```

#### Partial Recovery
```bash
# Rollback specific files only
claude quality --rollback-files="src/components/*.tsx"

# Rollback specific command effects
claude format --rollback          # Undo formatting changes
claude cleanup --rollback         # Undo cleanup changes
claude dedupe --rollback          # Undo deduplication changes

# Selective recovery with verification
claude quality --selective-rollback --verify-integrity
```

#### Recovery Validation
```bash
# Comprehensive recovery verification
claude verify --post-recovery --comprehensive

# Test suite execution after recovery
claude quality --test-after-recovery --full-suite

# Build verification after recovery
claude quality --build-after-recovery --clean-build
```

### Prevention and Monitoring

#### Quality Monitoring Setup
```bash
# Setup continuous quality monitoring
claude quality --monitor-setup --watch-files --alert-on-degradation

# Quality metrics tracking
claude quality --metrics-setup --trend-analysis --team-dashboard

# Automated quality reports
claude quality --report-schedule=daily --email-team --metrics-tracking
```

#### Proactive Issue Prevention
```bash
# Pre-commit quality validation
claude quality --setup-pre-commit --fail-fast --essential-only

# Real-time quality feedback
claude quality --watch-mode --live-feedback --fix-on-save

# Quality gate enforcement
claude quality --setup-quality-gates --block-on-issues --require-approval
```

## Best Practices for Team Adoption

### Gradual Migration Strategy

#### Phase 1: Individual Commands (Week 1-2)
```bash
# Start with formatting only
claude format --team-introduction
# Team learns new formatting workflow

# Add verification gradually
claude verify --quick --learning-mode
# Team gets familiar with quality reports

# Introduce cleanup conservatively
claude cleanup --conservative --preview-only
# Team reviews cleanup suggestions without applying
```

#### Phase 2: Workflow Integration (Week 3-4)
```bash
# Introduce basic workflows
claude quality --workflow=development
# Team uses coordinated command execution

# Setup shared configuration
claude quality --setup-team-standards --gradual-adoption
# Establish shared quality standards

# Begin CI integration
claude quality --ci-integration --non-blocking
# Add quality checks to CI without failing builds
```

#### Phase 3: Full Adoption (Week 5+)
```bash
# Complete workflow adoption
claude quality --workflow=comprehensive --team-ready

# Enforce quality gates
claude quality --quality-gates=strict --team-compliant

# Advanced features adoption
claude dedupe --team-training --advanced-features
claude quality --optimization --team-performance
```

### Team Training and Documentation

#### Training Workflow
```bash
# Generate team training materials
claude quality --training-materials --team-specific

# Interactive training mode
claude quality --training-mode --guided-practice

# Team certification
claude quality --team-certification --skill-validation
```

#### Documentation Generation
```bash
# Generate team-specific documentation
claude quality --doc-generation --team-workflow

# Create troubleshooting guides
claude quality --troubleshooting-guide --team-issues

# Workflow reference cards
claude quality --reference-cards --quick-help
```

This comprehensive usage guide provides the practical knowledge needed to effectively implement and maintain the orchestrated quality system. By following these recommendations and troubleshooting procedures, teams can successfully migrate from monolithic quality checking to a sophisticated, efficient, and reliable quality management workflow.