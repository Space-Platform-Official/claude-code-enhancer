---
allowed-tools: all
description: End-to-end pull request workflow with comprehensive lifecycle management
---

# Pull Request Workflow

Complete pull request lifecycle management from creation through merge with automated quality gates and team collaboration.

**Usage:** `/git/workflows/pr $ARGUMENTS`

## 🎯 PR Workflow Overview

This workflow provides comprehensive pull request management with:

- **Automated validation** and quality gates
- **Intelligent content generation** for PR descriptions
- **Review process coordination** with stakeholder management
- **CI/CD integration** monitoring and validation
- **Safe merge execution** with cleanup automation
- **Team collaboration** features and notifications

## 🔄 Complete PR Lifecycle

### Phase 1: Preparation and Validation

**Repository Readiness Assessment:**
```bash
# Comprehensive pre-PR validation
validate_pr_workflow() {
    echo "🔍 Phase 1: Validating PR workflow readiness..."
    
    # Load PR utilities
    source templates/commands/git/../../shared/pr-utils.md
    
    # Repository state validation
    if ! validate_pr_readiness; then
        echo "❌ Repository not ready for PR workflow"
        exit 1
    fi
    
    # Quality gate validation
    if ! run_quality_gates; then
        echo "❌ Quality gates failing"
        exit 1
    fi
    
    # Platform integration check
    setup_platform_integration
    
    echo "✅ Phase 1 complete - Repository ready for PR workflow"
}
```

### Phase 2: Content Generation and PR Creation

**Intelligent PR Creation:**
```bash
# Generate and create PR with comprehensive content
create_pr_workflow() {
    echo "🚀 Phase 2: Creating PR with intelligent content..."
    
    # Generate PR content
    local pr_title=$(generate_pr_title)
    local pr_body=$(generate_pr_description)
    
    echo "📝 Generated PR content:"
    echo "Title: $pr_title"
    
    # Create PR on platform
    if create_pr_universal "$pr_title" "$pr_body"; then
        echo "✅ PR created successfully"
        echo "✅ Phase 2 complete - PR created with automation"
    else
        echo "❌ Failed to create PR"
        exit 1
    fi
}
```

### Phase 3: Review Process Management

**Review Coordination:**
```bash
# Manage review process with stakeholder coordination
manage_review_workflow() {
    echo "👥 Phase 3: Managing review process..."
    
    # Track review status
    track_review_progress
    
    echo "✅ Phase 3 complete - Review process managed"
}

# Track review progress
track_review_progress() {
    local platform=$(detect_git_platform)
    
    case "$platform" in
        "github")
            track_github_reviews
            ;;
        "gitlab")
            echo "💡 GitLab review tracking available"
            ;;
        *)
            echo "💡 Manual review tracking required"
            ;;
    esac
}

# Track GitHub review progress
track_github_reviews() {
    if ! command -v gh &> /dev/null; then
        return 1
    fi
    
    echo "📊 GitHub Review Status:"
    local reviews=$(gh pr view --json reviews,reviewRequests)
    
    if [ -n "$reviews" ]; then
        # Show requested reviews
        echo "$reviews" | jq -r '.reviewRequests[]? | "  Requested: \(.login)"'
        
        # Show completed reviews
        echo "$reviews" | jq -r '.reviews[]? | "  \(.author.login): \(.state)"'
    fi
}
```

## 🎛️ Workflow Commands

### Main Workflow Execution
```bash
# Execute complete PR workflow
case "${1:-help}" in
    "create")
        validate_pr_workflow
        create_pr_workflow
        ;;
    "review")
        manage_review_workflow
        ;;
    "status")
        show_pr_workflow_status
        ;;
    "help"|*)
        show_workflow_help
        ;;
esac
```

### Workflow Status Dashboard
```bash
# Show comprehensive workflow status
show_pr_workflow_status() {
    echo "📊 PR Workflow Status Dashboard"
    echo "==============================="
    
    # Current PR status
    show_current_pr_status
    
    # Review progress
    show_review_progress
}

# Show current PR status
show_current_pr_status() {
    echo "🎯 Current PR Status:"
    echo "-------------------"
    
    if check_pr_status; then
        echo "✅ PR is active and healthy"
    else
        echo "❌ PR issues detected"
    fi
}
```

## 📚 Workflow Documentation

### Usage Examples
```bash
# Create new PR with full workflow
/git/workflows/pr create

# Monitor existing PR
/git/workflows/pr status

# Show workflow help
/git/workflows/pr help
```

### Best Practices
1. **Always validate** before starting workflow
2. **Use automation** for repetitive tasks
3. **Monitor continuously** during review process
4. **Communicate clearly** with stakeholders

## 📋 Workflow Summary

This PR workflow provides:

- ✅ **Comprehensive validation** with quality gates
- ✅ **Automated content generation** for PR descriptions
- ✅ **Review process coordination** with stakeholder management
- ✅ **Status monitoring** with actionable insights

The workflow ensures high-quality pull requests with minimal manual intervention while maintaining full control and transparency throughout the process.