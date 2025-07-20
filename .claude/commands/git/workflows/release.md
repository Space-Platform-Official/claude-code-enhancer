---
allowed-tools: all
description: Complete release preparation and deployment workflow with quality gates
---

# Release Workflow

Comprehensive release management workflow covering planning, preparation, deployment, and post-release monitoring with automated quality gates.

**Usage:** `/git/workflows/release $ARGUMENTS`

## 🚀 PRODUCTION RELEASE PIPELINE 🚀

**Releases are promises to users - make them count!**

This workflow manages the complete release lifecycle:

1. **PLANNING** - Release scope and timeline definition
2. **PREPARATION** - Code freeze, testing, and validation
3. **STAGING** - Pre-production deployment and verification
4. **PRODUCTION** - Controlled rollout with monitoring
5. **POST-RELEASE** - Monitoring, support, and retrospective

## Release Lifecycle Overview

```
main ────○────○────○────○────○────○──── (continuous development)
          \                     /
           ○────○────○────○────○ release/v2.1.0
                      │    │
                   staging production
```

## Phase 1: Release Planning & Initialization

**Release Planning Session:**
```bash
plan_release() {
    echo "📋 RELEASE PLANNING"
    echo "==================="
    
    # Gather release information
    echo "🎯 Release Planning Session"
    read -p "📦 Release version (e.g., v2.1.0): " release_version
    read -p "📅 Target release date (YYYY-MM-DD): " target_date
    read -p "🎯 Release type (major/minor/patch/hotfix): " release_type
    read -p "👥 Release manager: " release_manager
    read -p "🏷️ Release codename (optional): " release_codename
    
    # Validate version format
    if ! echo "$release_version" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$'; then
        echo "❌ Invalid version format. Use semantic versioning (v1.2.3)"
        exit 1
    fi
    
    # Check if version already exists
    if git tag -l | grep -q "^$release_version$"; then
        echo "❌ Version $release_version already exists!"
        exit 1
    fi
    
    # Validate target date
    target_timestamp=$(date -d "$target_date" +%s 2>/dev/null) || {
        echo "❌ Invalid date format"
        exit 1
    }
    
    current_timestamp=$(date +%s)
    if [ "$target_timestamp" -le "$current_timestamp" ]; then
        echo "⚠️  Target date is in the past or today. Consider future date for proper planning."
    fi
    
    # Initialize release
    initialize_release "$release_version" "$target_date" "$release_type" "$release_manager" "$release_codename"
    
    # Create release branch
    create_release_branch "$release_version"
    
    # Set up release tracking
    setup_release_tracking "$release_version" "$target_date" "$release_type" "$release_manager"
    
    echo "✅ Release $release_version initialized successfully"
}

initialize_release() {
    local version=$1
    local target_date=$2
    local release_type=$3
    local manager=$4
    local codename=$5
    
    echo "🚀 Initializing Release: $version"
    
    # Ensure we're starting from main
    git checkout main
    git pull origin main
    
    # Generate release notes template
    generate_release_notes_template "$version" "$target_date" "$release_type" "$manager" "$codename"
    
    # Create release checklist
    create_release_checklist "$version" "$target_date" "$release_type"
    
    # Set up release configuration
    setup_release_config "$version" "$target_date" "$release_type" "$manager"
}

generate_release_notes_template() {
    local version=$1
    local target_date=$2
    local release_type=$3
    local manager=$4
    local codename=$5
    
    cat > RELEASE_NOTES.md << EOF
# Release Notes - $version
$(if [ -n "$codename" ]; then echo "## Codename: $codename"; fi)

**Release Date:** $target_date
**Release Type:** $release_type
**Release Manager:** $manager

## 🎯 Release Highlights

[Add key features and improvements here]

## ✨ New Features

### [Feature Category 1]
- [ ] **Feature 1:** Description and benefit
- [ ] **Feature 2:** Description and benefit

### [Feature Category 2]
- [ ] **Feature 3:** Description and benefit

## 🐛 Bug Fixes

- [ ] **Fix 1:** Issue description and resolution
- [ ] **Fix 2:** Issue description and resolution

## 🚀 Improvements

- [ ] **Performance:** Description of performance improvements
- [ ] **UX/UI:** User experience enhancements
- [ ] **Developer Experience:** Development workflow improvements

## 🔧 Technical Changes

### API Changes
- [ ] No breaking changes
- [ ] New endpoints added
- [ ] Deprecated endpoints (with migration guide)

### Database Changes
- [ ] Schema migrations required
- [ ] Data migrations required
- [ ] Performance optimizations

### Infrastructure
- [ ] Deployment changes required
- [ ] Configuration updates needed
- [ ] Environment variable changes

## 📋 Upgrade Instructions

### For Users
1. [Step-by-step upgrade instructions]
2. [Configuration changes required]
3. [Data backup recommendations]

### For Developers
1. [Development environment updates]
2. [Dependency updates]
3. [API changes to adapt]

## 🚨 Breaking Changes

$(if [ "$release_type" == "major" ]; then echo "### Major Version Breaking Changes"; else echo "No breaking changes in this release."; fi)

## 📊 Metrics & Performance

- **Bundle Size:** [Before] → [After]
- **Load Time:** [Before] → [After]
- **Memory Usage:** [Before] → [After]
- **Test Coverage:** [Current percentage]

## 🙏 Contributors

[List of contributors to this release]

## 📚 Documentation

- [ ] User documentation updated
- [ ] API documentation updated
- [ ] Developer guides updated
- [ ] Migration guides created

## 🔗 Links

- **Release Branch:** release/$version
- **Milestone:** [Link to project milestone]
- **Test Results:** [Link to CI/CD results]
- **Performance Tests:** [Link to performance results]

---
**Generated:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')
**Workflow:** Claude Code Release Pipeline
EOF
}

create_release_checklist() {
    local version=$1
    local target_date=$2
    local release_type=$3
    
    cat > RELEASE_CHECKLIST.md << EOF
# Release Checklist - $version

**Target Date:** $target_date
**Release Type:** $release_type

## 🚀 Pre-Release Phase

### Code Preparation
- [ ] Feature freeze implemented
- [ ] All planned features completed
- [ ] Code review complete for all changes
- [ ] No critical or high-severity bugs open
- [ ] Technical debt addressed (critical items)

### Testing & Quality Assurance
- [ ] All unit tests pass (100%)
- [ ] Integration tests pass
- [ ] End-to-end tests pass
- [ ] Performance tests completed
- [ ] Security scan completed
- [ ] Accessibility testing completed
- [ ] Cross-browser testing completed
- [ ] Mobile responsiveness verified

### Documentation
- [ ] Release notes completed
- [ ] User documentation updated
- [ ] API documentation updated
- [ ] Changelog updated
- [ ] Migration guides written (if needed)
- [ ] Installation/upgrade instructions updated

### Infrastructure & Deployment
- [ ] Staging environment updated
- [ ] Production environment prepared
- [ ] Database migrations tested
- [ ] Configuration changes documented
- [ ] Rollback procedures documented
- [ ] Monitoring and alerting configured

## 🏗️ Staging Phase

### Staging Deployment
- [ ] Release branch deployed to staging
- [ ] Database migrations executed successfully
- [ ] Configuration applied correctly
- [ ] All services started successfully
- [ ] Health checks passing

### Staging Validation
- [ ] Smoke tests completed
- [ ] User acceptance testing completed
- [ ] Performance validation completed
- [ ] Integration with external services verified
- [ ] Security validation completed
- [ ] Load testing completed

### Stakeholder Approval
- [ ] Product team approval
- [ ] Engineering team approval
- [ ] QA team approval
- [ ] Security team approval
- [ ] Operations team approval

## 🚀 Production Release

### Pre-Deployment
- [ ] Production maintenance window scheduled
- [ ] Stakeholders notified
- [ ] Support team briefed
- [ ] Rollback plan confirmed
- [ ] Monitoring dashboards prepared

### Deployment
- [ ] Production deployment executed
- [ ] Database migrations completed
- [ ] Configuration deployed
- [ ] Services restarted successfully
- [ ] Health checks passing

### Post-Deployment Validation
- [ ] Smoke tests in production
- [ ] Key functionality verified
- [ ] Performance metrics normal
- [ ] Error rates within acceptable limits
- [ ] User feedback positive

## 📊 Post-Release

### Monitoring & Support
- [ ] 24-hour monitoring completed
- [ ] Support tickets monitored
- [ ] Performance metrics analyzed
- [ ] User feedback collected
- [ ] Issue tracking updated

### Communication
- [ ] Release announcement published
- [ ] Users notified of new features
- [ ] Documentation links shared
- [ ] Team retrospective scheduled

### Follow-up
- [ ] Post-release metrics reviewed
- [ ] Action items from retrospective
- [ ] Next release planning initiated

---
**Checklist Status:** In Progress
**Last Updated:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')
EOF
}

setup_release_config() {
    local version=$1
    local target_date=$2
    local release_type=$3
    local manager=$4
    
    cat > .release_config << EOF
RELEASE_VERSION=$version
TARGET_DATE=$target_date
RELEASE_TYPE=$release_type
RELEASE_MANAGER=$manager
CREATED_DATE=$(date +%s)
STATUS=PLANNING
PHASE=PREPARATION
EOF
    
    echo "🔧 Release configuration created"
}

create_release_branch() {
    local version=$1
    
    echo "🌳 Creating Release Branch"
    echo "========================="
    
    branch_name="release/$version"
    
    # Check if branch already exists
    if git show-ref --verify --quiet refs/heads/"$branch_name"; then
        echo "⚠️  Release branch already exists, switching to it"
        git checkout "$branch_name"
        return
    fi
    
    # Create release branch from main
    git checkout -b "$branch_name" main
    
    # Add release files
    git add RELEASE_NOTES.md RELEASE_CHECKLIST.md .release_config
    
    # Initial commit
    git commit -m "release: initialize $version release branch

- Add release notes template
- Add release checklist
- Set up release configuration

Release: $version
Manager: $(git config user.name)
Created: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    
    echo "✅ Release branch '$branch_name' created"
}

setup_release_tracking() {
    local version=$1
    local target_date=$2
    local release_type=$3
    local manager=$4
    
    echo "📊 Setting Up Release Tracking"
    echo "=============================="
    
    # Create GitHub milestone if using GitHub
    if command -v gh &> /dev/null; then
        echo "Creating GitHub milestone..."
        gh api repos/:owner/:repo/milestones \
            --method POST \
            --field title="Release $version" \
            --field description="Release $version targeting $target_date" \
            --field due_on="${target_date}T23:59:59Z" \
            --field state="open" 2>/dev/null || echo "Milestone creation failed (may already exist)"
    fi
    
    # Set up release dashboard
    create_release_dashboard "$version"
    
    echo "✅ Release tracking configured"
}

create_release_dashboard() {
    local version=$1
    
    cat > RELEASE_DASHBOARD.md << EOF
# Release Dashboard - $version

**Status:** $(cat .release_config | grep STATUS= | cut -d= -f2)
**Phase:** $(cat .release_config | grep PHASE= | cut -d= -f2)
**Target Date:** $(cat .release_config | grep TARGET_DATE= | cut -d= -f2)
**Manager:** $(cat .release_config | grep RELEASE_MANAGER= | cut -d= -f2)

## 📊 Progress Overview

### Checklist Progress
- **Total Items:** $(grep -c '\- \[ \]' RELEASE_CHECKLIST.md)
- **Completed:** $(grep -c '\- \[x\]' RELEASE_CHECKLIST.md)
- **Remaining:** $(grep -c '\- \[ \]' RELEASE_CHECKLIST.md)
- **Progress:** $(($(grep -c '\- \[x\]' RELEASE_CHECKLIST.md) * 100 / $(grep -c '\- \[' RELEASE_CHECKLIST.md)))%

### Key Metrics
- **Commits Since Last Release:** $(git rev-list --count $(git describe --tags --abbrev=0)..HEAD 2>/dev/null || echo "N/A")
- **Contributors:** $(git shortlog -sn $(git describe --tags --abbrev=0)..HEAD 2>/dev/null | wc -l || echo "N/A")
- **Files Changed:** $(git diff --name-only $(git describe --tags --abbrev=0)..HEAD 2>/dev/null | wc -l || echo "N/A")

### Test Status
- **Unit Tests:** $(make test 2>/dev/null | grep -c "passed" || echo "Run tests")
- **Integration Tests:** Pending
- **E2E Tests:** Pending
- **Performance Tests:** Pending

### Quality Gates
- [ ] Code Coverage ≥ 80%
- [ ] Security Scan Clean
- [ ] Performance Regression < 5%
- [ ] No Critical Bugs Open

## 🎯 Current Focus

$(case "$(cat .release_config | grep PHASE= | cut -d= -f2)" in
  "PREPARATION") echo "Focus: Feature completion and testing";;
  "STAGING") echo "Focus: Staging validation and approvals";;
  "PRODUCTION") echo "Focus: Production deployment";;
  "POST_RELEASE") echo "Focus: Monitoring and support";;
  *) echo "Focus: Release planning";;
esac)

## 📅 Timeline

| Phase | Target | Status |
|-------|--------|--------|
| Planning | $(date -d "$(cat .release_config | grep TARGET_DATE= | cut -d= -f2) -14 days" '+%Y-%m-%d') | ✅ |
| Preparation | $(date -d "$(cat .release_config | grep TARGET_DATE= | cut -d= -f2) -7 days" '+%Y-%m-%d') | ⏳ |
| Staging | $(date -d "$(cat .release_config | grep TARGET_DATE= | cut -d= -f2) -3 days" '+%Y-%m-%d') | ⏳ |
| Production | $(cat .release_config | grep TARGET_DATE= | cut -d= -f2) | ⏳ |
| Post-Release | $(date -d "$(cat .release_config | grep TARGET_DATE= | cut -d= -f2) +1 day" '+%Y-%m-%d') | ⏳ |

## 🚨 Risks & Issues

- [ ] [Add any identified risks or blockers]

---
**Last Updated:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')
**Auto-refreshed by:** \`/git/workflows/release --dashboard\`
EOF
}
```

## Phase 2: Release Preparation & Validation

**Feature Freeze & Code Stabilization:**
```bash
implement_feature_freeze() {
    echo "🧊 IMPLEMENTING FEATURE FREEZE"
    echo "=============================="
    
    source .release_config
    
    echo "Release: $RELEASE_VERSION"
    echo "Target: $TARGET_DATE"
    echo ""
    
    # Update status
    sed -i.bak 's/STATUS=PLANNING/STATUS=FEATURE_FREEZE/' .release_config
    sed -i.bak 's/PHASE=PREPARATION/PHASE=STABILIZATION/' .release_config
    rm -f .release_config.bak
    
    # Protect release branch
    protect_release_branch
    
    # Sync with main one final time
    final_main_sync
    
    # Run comprehensive validation
    comprehensive_validation
    
    # Update documentation
    finalize_release_documentation
    
    echo "✅ Feature freeze implemented"
    echo "🎯 Focus now shifts to testing and stabilization"
}

protect_release_branch() {
    echo "🛡️  Protecting Release Branch"
    echo "============================"
    
    current_branch=$(get_current_branch)
    
    # Set up branch protection using GitHub CLI if available
    if command -v gh &> /dev/null; then
        echo "Setting up GitHub branch protection..."
        gh api repos/:owner/:repo/branches/"$current_branch"/protection \
            --method PUT \
            --field required_status_checks='{"strict":true,"contexts":["ci/tests","ci/security-scan"]}' \
            --field enforce_admins=true \
            --field required_pull_request_reviews='{"required_approving_review_count":2,"dismiss_stale_reviews":true}' \
            --field restrictions=null 2>/dev/null || echo "Branch protection setup failed (insufficient permissions)"
    fi
    
    # Create local protection hook
    cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
current_branch=$(git branch --show-current)

if [[ "$current_branch" == release/* ]]; then
    echo "🛡️  Release branch protection active"
    echo "Direct pushes to release branch require explicit confirmation"
    read -p "Push to protected release branch? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        echo "Push cancelled"
        exit 1
    fi
fi
EOF
    chmod +x .git/hooks/pre-push
    
    echo "✅ Release branch protection enabled"
}

final_main_sync() {
    echo "🔄 Final Sync with Main"
    echo "======================"
    
    current_branch=$(get_current_branch)
    
    # Fetch latest main
    git fetch origin main
    
    # Check for new commits in main
    new_commits=$(git rev-list --count "$current_branch"..origin/main)
    
    if [ "$new_commits" -gt 0 ]; then
        echo "⚠️  Warning: $new_commits new commits in main since release branch creation"
        echo ""
        echo "New commits:"
        git log --oneline "$current_branch"..origin/main
        echo ""
        
        read -p "Merge latest main into release? (y/n): " merge_main
        if [[ "$merge_main" == "y" ]]; then
            # Merge main into release
            git merge origin/main --no-ff -m "release: merge latest main into $RELEASE_VERSION

Final sync before feature freeze.
Commits merged: $new_commits

This merge brings the release branch up to date with the latest main branch changes."
            
            echo "✅ Main merged into release branch"
        else
            echo "⚠️  Release branch not updated with latest main"
        fi
    else
        echo "✅ Release branch is up to date with main"
    fi
}

comprehensive_validation() {
    echo "🔍 COMPREHENSIVE VALIDATION"
    echo "==========================="
    
    # Create validation report
    validation_report="validation-report-$(date +%Y%m%d-%H%M%S).md"
    
    cat > "$validation_report" << EOF
# Validation Report - $RELEASE_VERSION

**Generated:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')
**Release:** $RELEASE_VERSION
**Branch:** $(get_current_branch)

## Test Results

EOF
    
    # Run test suite
    run_comprehensive_tests "$validation_report"
    
    # Security scan
    run_security_scan "$validation_report"
    
    # Performance validation
    run_performance_tests "$validation_report"
    
    # Quality metrics
    analyze_code_quality "$validation_report"
    
    # Dependency check
    check_dependencies "$validation_report"
    
    # Generate summary
    generate_validation_summary "$validation_report"
    
    echo "📊 Validation report: $validation_report"
}

run_comprehensive_tests() {
    local report_file=$1
    
    echo "🧪 Running Comprehensive Tests"
    echo "=============================="
    
    cat >> "$report_file" << EOF

### Unit Tests
EOF
    
    # Run unit tests
    if command -v make &> /dev/null && grep -q "test:" Makefile; then
        if make test; then
            echo "✅ Unit tests passed"
            echo "**Status:** ✅ PASSED" >> "$report_file"
        else
            echo "❌ Unit tests failed"
            echo "**Status:** ❌ FAILED" >> "$report_file"
        fi
    elif [ -f package.json ]; then
        if npm test; then
            echo "✅ Unit tests passed"
            echo "**Status:** ✅ PASSED" >> "$report_file"
        else
            echo "❌ Unit tests failed"
            echo "**Status:** ❌ FAILED" >> "$report_file"
        fi
    fi
    
    # Integration tests
    cat >> "$report_file" << EOF

### Integration Tests
EOF
    
    if [ -f docker-compose.test.yml ]; then
        if docker-compose -f docker-compose.test.yml run integration-tests; then
            echo "✅ Integration tests passed"
            echo "**Status:** ✅ PASSED" >> "$report_file"
        else
            echo "❌ Integration tests failed"
            echo "**Status:** ❌ FAILED" >> "$report_file"
        fi
    else
        echo "ℹ️  No integration tests configured"
        echo "**Status:** ⚠️ NOT CONFIGURED" >> "$report_file"
    fi
    
    # E2E tests
    cat >> "$report_file" << EOF

### End-to-End Tests
EOF
    
    if [ -f cypress.json ] || [ -f cypress.config.js ]; then
        if npx cypress run; then
            echo "✅ E2E tests passed"
            echo "**Status:** ✅ PASSED" >> "$report_file"
        else
            echo "❌ E2E tests failed"
            echo "**Status:** ❌ FAILED" >> "$report_file"
        fi
    else
        echo "ℹ️  No E2E tests configured"
        echo "**Status:** ⚠️ NOT CONFIGURED" >> "$report_file"
    fi
}

run_security_scan() {
    local report_file=$1
    
    echo "🔒 Running Security Scan"
    echo "======================="
    
    cat >> "$report_file" << EOF

## Security Analysis

### Dependency Vulnerabilities
EOF
    
    # Check for known vulnerabilities
    if [ -f package.json ]; then
        if npm audit --audit-level=high; then
            echo "✅ No high-severity vulnerabilities"
            echo "**Status:** ✅ CLEAN" >> "$report_file"
        else
            echo "❌ High-severity vulnerabilities found"
            echo "**Status:** ❌ VULNERABILITIES FOUND" >> "$report_file"
        fi
    fi
    
    # Code security scan
    cat >> "$report_file" << EOF

### Code Security
EOF
    
    if command -v bandit &> /dev/null; then
        if bandit -r . -f json > security-report.json; then
            echo "✅ Security scan clean"
            echo "**Status:** ✅ CLEAN" >> "$report_file"
        else
            echo "❌ Security issues found"
            echo "**Status:** ❌ ISSUES FOUND" >> "$report_file"
        fi
    elif command -v semgrep &> /dev/null; then
        if semgrep --config=auto .; then
            echo "✅ Security scan clean"
            echo "**Status:** ✅ CLEAN" >> "$report_file"
        else
            echo "❌ Security issues found"
            echo "**Status:** ❌ ISSUES FOUND" >> "$report_file"
        fi
    else
        echo "ℹ️  No security scanner configured"
        echo "**Status:** ⚠️ NOT CONFIGURED" >> "$report_file"
    fi
}

run_performance_tests() {
    local report_file=$1
    
    echo "⚡ Running Performance Tests"
    echo "==========================="
    
    cat >> "$report_file" << EOF

## Performance Analysis

### Load Testing
EOF
    
    # Basic performance check
    if command -v ab &> /dev/null; then
        echo "Running Apache Bench test..."
        if ab -n 100 -c 10 http://localhost:3000/ > perf-test.log 2>&1; then
            avg_time=$(grep "Time per request" perf-test.log | head -1 | awk '{print $4}')
            echo "✅ Performance test completed - Avg: ${avg_time}ms"
            echo "**Average Response Time:** ${avg_time}ms" >> "$report_file"
            echo "**Status:** ✅ COMPLETED" >> "$report_file"
        else
            echo "❌ Performance test failed"
            echo "**Status:** ❌ FAILED" >> "$report_file"
        fi
    else
        echo "ℹ️  No performance testing tool available"
        echo "**Status:** ⚠️ NOT CONFIGURED" >> "$report_file"
    fi
}

analyze_code_quality() {
    local report_file=$1
    
    echo "📊 Analyzing Code Quality"
    echo "========================"
    
    cat >> "$report_file" << EOF

## Code Quality Metrics

### Code Coverage
EOF
    
    # Code coverage analysis
    if [ -f package.json ] && npm list --depth=0 nyc &>/dev/null; then
        coverage=$(npm run coverage 2>/dev/null | grep "All files" | awk '{print $10}' | tr -d '%')
        if [ -n "$coverage" ]; then
            echo "Code coverage: ${coverage}%"
            echo "**Coverage:** ${coverage}%" >> "$report_file"
            
            if [ "$coverage" -ge 80 ]; then
                echo "**Status:** ✅ GOOD" >> "$report_file"
            else
                echo "**Status:** ⚠️ BELOW THRESHOLD" >> "$report_file"
            fi
        fi
    fi
    
    # Linting check
    cat >> "$report_file" << EOF

### Code Linting
EOF
    
    if run_linters; then
        echo "✅ Linting passed"
        echo "**Status:** ✅ PASSED" >> "$report_file"
    else
        echo "❌ Linting issues found"
        echo "**Status:** ❌ ISSUES FOUND" >> "$report_file"
    fi
}

check_dependencies() {
    local report_file=$1
    
    echo "📦 Checking Dependencies"
    echo "======================="
    
    cat >> "$report_file" << EOF

## Dependency Analysis

### Outdated Packages
EOF
    
    if [ -f package.json ]; then
        outdated_count=$(npm outdated --json 2>/dev/null | jq 'length' 2>/dev/null || echo 0)
        echo "Outdated packages: $outdated_count"
        echo "**Outdated Packages:** $outdated_count" >> "$report_file"
        
        if [ "$outdated_count" -eq 0 ]; then
            echo "**Status:** ✅ UP TO DATE" >> "$report_file"
        else
            echo "**Status:** ⚠️ UPDATES AVAILABLE" >> "$report_file"
        fi
    fi
}

generate_validation_summary() {
    local report_file=$1
    
    cat >> "$report_file" << EOF

## Summary

### Overall Status
EOF
    
    # Count passed/failed tests
    passed_count=$(grep -c "✅ PASSED\|✅ CLEAN\|✅ GOOD\|✅ COMPLETED" "$report_file")
    failed_count=$(grep -c "❌ FAILED\|❌ ISSUES FOUND\|❌ VULNERABILITIES FOUND" "$report_file")
    warning_count=$(grep -c "⚠️" "$report_file")
    
    total_checks=$((passed_count + failed_count + warning_count))
    
    if [ "$failed_count" -eq 0 ]; then
        overall_status="✅ READY FOR RELEASE"
    elif [ "$failed_count" -le 2 ]; then
        overall_status="⚠️ REQUIRES ATTENTION"
    else
        overall_status="❌ NOT READY"
    fi
    
    cat >> "$report_file" << EOF

**Overall Status:** $overall_status

**Statistics:**
- ✅ Passed: $passed_count
- ❌ Failed: $failed_count  
- ⚠️ Warnings: $warning_count
- **Total Checks:** $total_checks

### Recommendations

$(if [ "$failed_count" -eq 0 ]; then
    echo "All validation checks passed. Release is ready to proceed to staging."
elif [ "$failed_count" -le 2 ]; then
    echo "Minor issues detected. Review and resolve before staging deployment."
else
    echo "Critical issues detected. Release should not proceed until all issues are resolved."
fi)

---
**Validation completed at:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')
EOF
    
    echo ""
    echo "📊 VALIDATION SUMMARY"
    echo "===================="
    echo "Overall Status: $overall_status"
    echo "Passed: $passed_count | Failed: $failed_count | Warnings: $warning_count"
    
    if [ "$failed_count" -gt 0 ]; then
        echo ""
        echo "❌ Critical issues must be resolved before proceeding"
        return 1
    fi
    
    return 0
}

finalize_release_documentation() {
    echo "📚 Finalizing Release Documentation"
    echo "=================================="
    
    # Update release notes with actual changes
    update_release_notes
    
    # Generate changelog
    generate_changelog
    
    # Update version files
    update_version_files
    
    # Commit documentation updates
    commit_documentation_updates
}

update_release_notes() {
    echo "📝 Updating Release Notes"
    
    # Extract features and fixes from commits
    last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    
    if [ -n "$last_tag" ]; then
        # Get commits since last tag
        features=$(git log "$last_tag"..HEAD --oneline | grep "feat:" | sed 's/.*feat[:(]/- /' | sed 's/)//')
        fixes=$(git log "$last_tag"..HEAD --oneline | grep "fix:" | sed 's/.*fix[:(]/- /' | sed 's/)//')
        
        # Update release notes
        if [ -n "$features" ]; then
            sed -i.bak "/## ✨ New Features/,/## 🐛 Bug Fixes/{
                /## ✨ New Features/!{
                    /## 🐛 Bug Fixes/!d
                }
            }" RELEASE_NOTES.md
            
            sed -i.bak "/## ✨ New Features/a\\
$features\\
" RELEASE_NOTES.md
        fi
        
        if [ -n "$fixes" ]; then
            sed -i.bak "/## 🐛 Bug Fixes/,/## 🚀 Improvements/{
                /## 🐛 Bug Fixes/!{
                    /## 🚀 Improvements/!d
                }
            }" RELEASE_NOTES.md
            
            sed -i.bak "/## 🐛 Bug Fixes/a\\
$fixes\\
" RELEASE_NOTES.md
        fi
        
        rm -f RELEASE_NOTES.md.bak
    fi
    
    echo "✅ Release notes updated"
}

generate_changelog() {
    echo "📋 Generating Changelog"
    
    # Create or update CHANGELOG.md
    if [ ! -f CHANGELOG.md ]; then
        echo "# Changelog" > CHANGELOG.md
        echo "" >> CHANGELOG.md
        echo "All notable changes to this project will be documented in this file." >> CHANGELOG.md
        echo "" >> CHANGELOG.md
    fi
    
    # Add new release section
    temp_file=$(mktemp)
    
    cat > "$temp_file" << EOF
# Changelog

## [$RELEASE_VERSION] - $(date '+%Y-%m-%d')

$(grep -A 100 "## 🎯 Release Highlights" RELEASE_NOTES.md | grep -B 100 "## 📋 Upgrade Instructions" | head -n -1 | tail -n +2)

EOF
    
    # Append existing changelog
    if [ -f CHANGELOG.md ]; then
        tail -n +2 CHANGELOG.md >> "$temp_file"
    fi
    
    mv "$temp_file" CHANGELOG.md
    
    echo "✅ Changelog generated"
}

update_version_files() {
    echo "🔢 Updating Version Files"
    
    version_number=$(echo "$RELEASE_VERSION" | sed 's/^v//')
    
    # Update package.json if it exists
    if [ -f package.json ]; then
        jq ".version = \"$version_number\"" package.json > package.json.tmp
        mv package.json.tmp package.json
        echo "✅ package.json version updated"
    fi
    
    # Update version.py if it exists
    if [ -f version.py ]; then
        sed -i.bak "s/__version__ = .*/__version__ = \"$version_number\"/" version.py
        rm -f version.py.bak
        echo "✅ version.py updated"
    fi
    
    # Update Cargo.toml if it exists
    if [ -f Cargo.toml ]; then
        sed -i.bak "s/version = \".*\"/version = \"$version_number\"/" Cargo.toml
        rm -f Cargo.toml.bak
        echo "✅ Cargo.toml version updated"
    fi
}

commit_documentation_updates() {
    echo "💾 Committing Documentation Updates"
    
    # Add all documentation changes
    git add RELEASE_NOTES.md CHANGELOG.md RELEASE_CHECKLIST.md
    
    # Add version files if they exist
    [ -f package.json ] && git add package.json
    [ -f version.py ] && git add version.py
    [ -f Cargo.toml ] && git add Cargo.toml
    
    # Commit changes
    git commit -m "docs: finalize $RELEASE_VERSION documentation

- Update release notes with actual features and fixes
- Generate comprehensive changelog
- Update version numbers in package files
- Complete release checklist items

Release: $RELEASE_VERSION
Status: Documentation Complete"
    
    echo "✅ Documentation updates committed"
}
```

## Phase 3: Staging Deployment & Validation

**Staging Environment Preparation:**
```bash
deploy_to_staging() {
    echo "🏗️ STAGING DEPLOYMENT"
    echo "===================="
    
    source .release_config
    
    # Update status
    sed -i.bak 's/PHASE=STABILIZATION/PHASE=STAGING/' .release_config
    rm -f .release_config.bak
    
    # Pre-staging validation
    pre_staging_validation
    
    # Deploy to staging
    execute_staging_deployment
    
    # Post-deployment validation
    validate_staging_deployment
    
    # Run acceptance tests
    run_staging_acceptance_tests
    
    # Gather stakeholder approvals
    collect_stakeholder_approvals
}

pre_staging_validation() {
    echo "🔍 Pre-Staging Validation"
    echo "========================="
    
    current_branch=$(get_current_branch)
    
    # Ensure we're on release branch
    if [[ "$current_branch" != release/* ]]; then
        echo "❌ Not on release branch!"
        exit 1
    fi
    
    # Check validation report exists
    validation_report=$(ls validation-report-*.md 2>/dev/null | head -1)
    if [ -z "$validation_report" ]; then
        echo "❌ No validation report found. Run comprehensive validation first."
        exit 1
    fi
    
    # Check if validation passed
    if ! grep -q "✅ READY FOR RELEASE" "$validation_report"; then
        echo "❌ Validation not passed. Resolve issues before staging."
        exit 1
    fi
    
    # Check branch is clean
    if ! is_repo_clean; then
        echo "❌ Working directory not clean. Commit changes first."
        exit 1
    fi
    
    # Final confirmation
    echo ""
    echo "🚨 STAGING DEPLOYMENT CONFIRMATION"
    echo "=================================="
    echo "Release: $RELEASE_VERSION"
    echo "Branch: $current_branch"
    echo "Validation: Passed"
    echo ""
    
    read -p "Deploy to staging environment? (yes/no): " deploy_confirm
    if [[ "$deploy_confirm" != "yes" ]]; then
        echo "Staging deployment cancelled"
        exit 1
    fi
    
    echo "✅ Pre-staging validation complete"
}

execute_staging_deployment() {
    echo "🚀 Executing Staging Deployment"
    echo "==============================="
    
    # Create deployment tag
    staging_tag="staging-$RELEASE_VERSION-$(date +%Y%m%d-%H%M%S)"
    git tag -a "$staging_tag" -m "Staging deployment for $RELEASE_VERSION"
    git push origin "$staging_tag"
    
    # Deploy using configured method
    if [ -f docker-compose.staging.yml ]; then
        deploy_docker_staging
    elif [ -f .github/workflows/deploy-staging.yml ]; then
        deploy_github_actions_staging
    elif [ -f deploy/staging.sh ]; then
        deploy_script_staging
    else
        deploy_manual_staging
    fi
    
    echo "✅ Staging deployment executed"
}

deploy_docker_staging() {
    echo "🐳 Docker Staging Deployment"
    
    # Build staging image
    docker build -t "$RELEASE_VERSION-staging" .
    
    # Deploy to staging
    docker-compose -f docker-compose.staging.yml up -d
    
    # Wait for services to be ready
    echo "⏳ Waiting for services to start..."
    sleep 30
    
    # Health check
    if curl -sf http://staging.example.com/health; then
        echo "✅ Staging services healthy"
    else
        echo "❌ Staging health check failed"
        exit 1
    fi
}

deploy_github_actions_staging() {
    echo "🤖 GitHub Actions Staging Deployment"
    
    # Trigger staging workflow
    if command -v gh &> /dev/null; then
        gh workflow run deploy-staging.yml --ref "$(get_current_branch)"
        
        # Wait for workflow to complete
        echo "⏳ Waiting for staging deployment workflow..."
        sleep 60
        
        # Check workflow status
        workflow_status=$(gh run list --workflow=deploy-staging.yml --limit=1 --json status -q '.[0].status')
        if [[ "$workflow_status" == "completed" ]]; then
            echo "✅ GitHub Actions staging deployment completed"
        else
            echo "❌ GitHub Actions staging deployment failed"
            exit 1
        fi
    else
        echo "❌ GitHub CLI not available for automated deployment"
        exit 1
    fi
}

deploy_script_staging() {
    echo "📜 Script-based Staging Deployment"
    
    # Execute staging deployment script
    if bash deploy/staging.sh "$RELEASE_VERSION"; then
        echo "✅ Staging deployment script completed"
    else
        echo "❌ Staging deployment script failed"
        exit 1
    fi
}

deploy_manual_staging() {
    echo "👤 Manual Staging Deployment"
    echo "============================"
    echo ""
    echo "Automated staging deployment not configured."
    echo "Please deploy manually to staging environment:"
    echo ""
    echo "1. Build application with version: $RELEASE_VERSION"
    echo "2. Deploy to staging environment"
    echo "3. Run database migrations if needed"
    echo "4. Start/restart services"
    echo "5. Verify health checks"
    echo ""
    
    read -p "Manual deployment completed successfully? (yes/no): " manual_success
    if [[ "$manual_success" != "yes" ]]; then
        echo "❌ Staging deployment failed"
        exit 1
    fi
    
    echo "✅ Manual staging deployment completed"
}

validate_staging_deployment() {
    echo "🔍 Validating Staging Deployment"
    echo "==============================="
    
    # Health checks
    run_staging_health_checks
    
    # Smoke tests
    run_staging_smoke_tests
    
    # Database validation
    validate_staging_database
    
    # Configuration validation
    validate_staging_configuration
    
    # Performance baseline
    establish_staging_performance_baseline
}

run_staging_health_checks() {
    echo "🏥 Staging Health Checks"
    echo "======================="
    
    staging_urls=(
        "http://staging.example.com/health"
        "http://staging.example.com/api/health"
        "http://staging.example.com/status"
    )
    
    for url in "${staging_urls[@]}"; do
        if curl -sf --max-time 10 "$url" &>/dev/null; then
            echo "✅ $url - Healthy"
        else
            echo "❌ $url - Failed"
        fi
    done
}

run_staging_smoke_tests() {
    echo "💨 Staging Smoke Tests"
    echo "====================="
    
    # Basic functionality tests
    smoke_tests=(
        "User login functionality"
        "Core API endpoints"
        "Database connectivity"
        "File upload/download"
        "Email notifications"
    )
    
    echo "Run the following smoke tests manually:"
    for test in "${smoke_tests[@]}"; do
        echo "- [ ] $test"
    done
    
    echo ""
    read -p "All smoke tests passed? (yes/no): " smoke_passed
    if [[ "$smoke_passed" != "yes" ]]; then
        echo "❌ Smoke tests failed"
        exit 1
    fi
    
    echo "✅ Staging smoke tests completed"
}

validate_staging_database() {
    echo "🗄️ Database Validation"
    echo "====================="
    
    # Check database connectivity
    if command -v psql &> /dev/null; then
        if psql -h staging-db.example.com -c "SELECT 1" &>/dev/null; then
            echo "✅ Database connectivity verified"
        else
            echo "❌ Database connection failed"
            exit 1
        fi
    fi
    
    # Check migrations
    echo "ℹ️  Verify database migrations are applied correctly"
    read -p "Database migrations verified? (yes/no): " migrations_ok
    if [[ "$migrations_ok" != "yes" ]]; then
        echo "❌ Database migrations not verified"
        exit 1
    fi
    
    echo "✅ Database validation completed"
}

validate_staging_configuration() {
    echo "⚙️ Configuration Validation"
    echo "=========================="
    
    echo "Verify staging configuration:"
    echo "- Environment variables set correctly"
    echo "- Feature flags configured"
    echo "- External service connections"
    echo "- SSL certificates valid"
    echo ""
    
    read -p "Configuration validated? (yes/no): " config_ok
    if [[ "$config_ok" != "yes" ]]; then
        echo "❌ Configuration validation failed"
        exit 1
    fi
    
    echo "✅ Configuration validation completed"
}

establish_staging_performance_baseline() {
    echo "⚡ Performance Baseline"
    echo "====================="
    
    # Run performance tests if available
    if command -v ab &> /dev/null; then
        echo "Running performance baseline test..."
        ab -n 100 -c 10 http://staging.example.com/ > staging-perf-baseline.log 2>&1
        
        avg_time=$(grep "Time per request" staging-perf-baseline.log | head -1 | awk '{print $4}')
        echo "✅ Performance baseline: ${avg_time}ms average response time"
    else
        echo "ℹ️  Manual performance validation required"
        read -p "Performance is acceptable? (yes/no): " perf_ok
        if [[ "$perf_ok" != "yes" ]]; then
            echo "❌ Performance validation failed"
            exit 1
        fi
    fi
    
    echo "✅ Performance baseline established"
}

run_staging_acceptance_tests() {
    echo "✅ STAGING ACCEPTANCE TESTS"
    echo "==========================="
    
    # User Acceptance Testing
    echo "👥 User Acceptance Testing"
    echo "========================="
    echo ""
    echo "Coordinate with stakeholders to run acceptance tests:"
    echo "- Product team feature validation"
    echo "- QA team comprehensive testing"
    echo "- UX team usability validation"
    echo "- Business stakeholder approval"
    echo ""
    
    # Automated E2E tests
    if [ -f cypress.json ] || [ -f cypress.config.js ]; then
        echo "🤖 Running automated E2E tests against staging..."
        CYPRESS_BASE_URL=http://staging.example.com npx cypress run
    fi
    
    echo ""
    read -p "All acceptance tests passed? (yes/no): " acceptance_passed
    if [[ "$acceptance_passed" != "yes" ]]; then
        echo "❌ Acceptance tests failed"
        echo "Address issues before proceeding to production"
        exit 1
    fi
    
    echo "✅ Staging acceptance tests completed"
}

collect_stakeholder_approvals() {
    echo "👥 STAKEHOLDER APPROVALS"
    echo "======================="
    
    # Create approval checklist
    cat > STAGING_APPROVALS.md << EOF
# Staging Approval Checklist - $RELEASE_VERSION

**Staging Environment:** http://staging.example.com
**Deployed:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')
**Release Manager:** $RELEASE_MANAGER

## Required Approvals

### Technical Approvals
- [ ] **Engineering Lead:** Code review and technical validation
- [ ] **QA Lead:** Testing completion and quality validation
- [ ] **DevOps/SRE:** Infrastructure and deployment validation
- [ ] **Security Team:** Security review and vulnerability assessment

### Business Approvals  
- [ ] **Product Manager:** Feature validation and acceptance
- [ ] **UX/Design Lead:** User experience and interface validation
- [ ] **Business Stakeholder:** Business requirements validation
- [ ] **Customer Success:** Customer impact assessment

### Compliance Approvals (if applicable)
- [ ] **Legal Review:** Terms, privacy, compliance validation
- [ ] **Data Protection:** GDPR, data handling validation
- [ ] **Accessibility:** WCAG compliance validation

## Approval Comments

### Engineering Lead
**Approved by:** [Name]
**Date:** [Date]
**Comments:** [Comments]

### QA Lead  
**Approved by:** [Name]
**Date:** [Date]
**Comments:** [Comments]

### Product Manager
**Approved by:** [Name]
**Date:** [Date]
**Comments:** [Comments]

### Additional Comments
[Any additional stakeholder feedback]

---
**All approvals required before production deployment**
EOF
    
    echo "📋 Staging approval checklist created: STAGING_APPROVALS.md"
    echo ""
    echo "Send staging environment details to stakeholders:"
    echo "- URL: http://staging.example.com"
    echo "- Credentials: [Provide test credentials]"
    echo "- Test scenarios: [Link to test cases]"
    echo ""
    
    read -p "Notify stakeholders for approval? (yes/no): " notify_stakeholders
    if [[ "$notify_stakeholders" == "yes" ]]; then
        echo "📧 Stakeholder notification should be sent"
        # Integration with notification systems would go here
    fi
    
    echo "✅ Stakeholder approval process initiated"
}
```

## Phase 4: Production Deployment

**Production Release Execution:**
```bash
deploy_to_production() {
    echo "🚀 PRODUCTION DEPLOYMENT"
    echo "======================="
    
    source .release_config
    
    # Update status
    sed -i.bak 's/PHASE=STAGING/PHASE=PRODUCTION/' .release_config
    rm -f .release_config.bak
    
    # Pre-production validation
    pre_production_validation
    
    # Production deployment
    execute_production_deployment
    
    # Post-deployment monitoring
    post_deployment_monitoring
    
    # Release announcement
    announce_release
}

pre_production_validation() {
    echo "🔍 PRE-PRODUCTION VALIDATION"
    echo "============================"
    
    # Check stakeholder approvals
    if [ ! -f STAGING_APPROVALS.md ]; then
        echo "❌ No staging approvals found"
        exit 1
    fi
    
    # Verify all approvals are complete
    approval_count=$(grep -c '\- \[x\]' STAGING_APPROVALS.md)
    total_approvals=$(grep -c '\- \[' STAGING_APPROVALS.md)
    
    if [ "$approval_count" -lt "$total_approvals" ]; then
        echo "❌ Not all stakeholder approvals complete ($approval_count/$total_approvals)"
        echo "Complete all approvals before production deployment"
        exit 1
    fi
    
    # Final staging validation
    echo "🏗️ Final staging validation..."
    if ! curl -sf http://staging.example.com/health &>/dev/null; then
        echo "❌ Staging environment not healthy"
        exit 1
    fi
    
    # Production readiness checklist
    production_readiness_check
    
    # Final confirmation
    production_deployment_confirmation
}

production_readiness_check() {
    echo "✅ PRODUCTION READINESS CHECK"
    echo "============================="
    
    readiness_items=(
        "Database backup completed"
        "Rollback plan documented and tested"
        "Monitoring and alerting configured"
        "Support team briefed"
        "Customer communication prepared"
        "Post-deployment verification plan ready"
        "Emergency contacts available"
        "Maintenance window scheduled (if needed)"
    )
    
    echo "Verify production readiness:"
    for item in "${readiness_items[@]}"; do
        echo "- [ ] $item"
    done
    
    echo ""
    read -p "All readiness items verified? (yes/no): " readiness_ok
    if [[ "$readiness_ok" != "yes" ]]; then
        echo "❌ Production readiness check failed"
        exit 1
    fi
    
    echo "✅ Production readiness verified"
}

production_deployment_confirmation() {
    echo ""
    echo "🚨 FINAL PRODUCTION DEPLOYMENT CONFIRMATION"
    echo "==========================================="
    echo ""
    echo "You are about to deploy to PRODUCTION:"
    echo ""
    echo "Release: $RELEASE_VERSION"
    echo "Target Date: $TARGET_DATE"
    echo "Manager: $RELEASE_MANAGER"
    echo "Environment: PRODUCTION"
    echo ""
    echo "This action will affect live users and systems."
    echo ""
    
    read -p "Type 'DEPLOY TO PRODUCTION' to confirm: " final_confirm
    if [[ "$final_confirm" != "DEPLOY TO PRODUCTION" ]]; then
        echo "Production deployment cancelled"
        exit 1
    fi
    
    echo "✅ Production deployment confirmed"
}

execute_production_deployment() {
    echo "🎯 EXECUTING PRODUCTION DEPLOYMENT"
    echo "=================================="
    
    # Create production backup
    create_production_backup
    
    # Tag release
    tag_production_release
    
    # Deploy to production
    perform_production_deployment
    
    # Verify deployment
    verify_production_deployment
}

create_production_backup() {
    echo "💾 Creating Production Backup"
    echo "============================="
    
    # Tag current production state
    backup_tag="backup-pre-$RELEASE_VERSION-$(date +%Y%m%d-%H%M%S)"
    
    if git show-ref --verify --quiet refs/heads/production; then
        git tag "$backup_tag" production
    else
        git tag "$backup_tag" main
    fi
    
    git push origin "$backup_tag"
    
    echo "✅ Production backup created: $backup_tag"
    
    # Database backup (if applicable)
    echo "ℹ️  Ensure database backup is completed before proceeding"
    read -p "Database backup confirmed? (yes/no): " db_backup_ok
    if [[ "$db_backup_ok" != "yes" ]]; then
        echo "❌ Database backup not confirmed"
        exit 1
    fi
}

tag_production_release() {
    echo "🏷️ Tagging Production Release"
    echo "============================"
    
    current_branch=$(get_current_branch)
    
    # Create annotated release tag
    git tag -a "$RELEASE_VERSION" -m "Release $RELEASE_VERSION

$(head -20 RELEASE_NOTES.md | tail -n +3)

Release Manager: $RELEASE_MANAGER
Release Date: $(date -u '+%Y-%m-%d')
Branch: $current_branch

This tag marks the official $RELEASE_VERSION release."
    
    # Push tag
    git push origin "$RELEASE_VERSION"
    
    echo "✅ Release tagged: $RELEASE_VERSION"
}

perform_production_deployment() {
    echo "🚀 Performing Production Deployment"
    echo "==================================="
    
    # Merge to production branch (or main)
    if git show-ref --verify --quiet refs/heads/production; then
        target_branch="production"
    else
        target_branch="main"
    fi
    
    current_branch=$(get_current_branch)
    
    # Merge release to production
    git checkout "$target_branch"
    git pull origin "$target_branch"
    git merge --no-ff "$current_branch" -m "Production deployment: $RELEASE_VERSION

Release: $RELEASE_VERSION
Release Manager: $RELEASE_MANAGER
Deployment Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')

This merge deploys $RELEASE_VERSION to production environment.

Backup Reference: $(git tag -l "backup-pre-$RELEASE_VERSION-*" | head -1)
Rollback Command: git reset --hard [backup-reference]"
    
    # Push to production
    git push origin "$target_branch"
    
    # Deploy using configured method
    if [ -f .github/workflows/deploy-production.yml ]; then
        deploy_github_actions_production
    elif [ -f deploy/production.sh ]; then
        deploy_script_production
    else
        deploy_manual_production
    fi
    
    echo "✅ Production deployment completed"
}

deploy_github_actions_production() {
    echo "🤖 GitHub Actions Production Deployment"
    
    if command -v gh &> /dev/null; then
        gh workflow run deploy-production.yml --ref production
        
        echo "⏳ Waiting for production deployment workflow..."
        sleep 120
        
        workflow_status=$(gh run list --workflow=deploy-production.yml --limit=1 --json status -q '.[0].status')
        if [[ "$workflow_status" == "completed" ]]; then
            echo "✅ Production deployment workflow completed"
        else
            echo "❌ Production deployment workflow failed"
            exit 1
        fi
    fi
}

deploy_script_production() {
    echo "📜 Script-based Production Deployment"
    
    if bash deploy/production.sh "$RELEASE_VERSION"; then
        echo "✅ Production deployment script completed"
    else
        echo "❌ Production deployment script failed"
        exit 1
    fi
}

deploy_manual_production() {
    echo "👤 Manual Production Deployment"
    echo "==============================="
    echo ""
    echo "Execute manual production deployment:"
    echo "1. Deploy $RELEASE_VERSION to production"
    echo "2. Run database migrations"
    echo "3. Update configuration"
    echo "4. Restart services"
    echo "5. Verify health checks"
    echo ""
    
    read -p "Manual production deployment completed? (yes/no): " manual_success
    if [[ "$manual_success" != "yes" ]]; then
        echo "❌ Production deployment failed"
        exit 1
    fi
}

verify_production_deployment() {
    echo "🔍 VERIFYING PRODUCTION DEPLOYMENT"
    echo "=================================="
    
    # Health checks
    production_health_checks
    
    # Smoke tests
    production_smoke_tests
    
    # Performance validation
    production_performance_check
    
    # User functionality verification
    production_functionality_verification
}

production_health_checks() {
    echo "🏥 Production Health Checks"
    echo "=========================="
    
    production_urls=(
        "https://example.com/health"
        "https://api.example.com/health"
        "https://example.com/status"
    )
    
    for url in "${production_urls[@]}"; do
        if curl -sf --max-time 10 "$url" &>/dev/null; then
            echo "✅ $url - Healthy"
        else
            echo "❌ $url - Failed"
            echo "🚨 PRODUCTION HEALTH CHECK FAILED!"
            echo "Consider immediate rollback"
            exit 1
        fi
    done
    
    echo "✅ All production health checks passed"
}

production_smoke_tests() {
    echo "💨 Production Smoke Tests"
    echo "========================"
    
    echo "Execute critical production smoke tests:"
    echo "- User login/authentication"
    echo "- Core business functionality"
    echo "- Payment processing (if applicable)"
    echo "- Data integrity"
    echo "- External integrations"
    echo ""
    
    read -p "All production smoke tests passed? (yes/no): " prod_smoke_ok
    if [[ "$prod_smoke_ok" != "yes" ]]; then
        echo "❌ Production smoke tests failed"
        echo "🚨 CONSIDER IMMEDIATE ROLLBACK"
        exit 1
    fi
    
    echo "✅ Production smoke tests completed"
}

production_performance_check() {
    echo "⚡ Production Performance Check"
    echo "=============================="
    
    if command -v ab &> /dev/null; then
        echo "Running production performance check..."
        ab -n 50 -c 5 https://example.com/ > prod-perf-check.log 2>&1
        
        avg_time=$(grep "Time per request" prod-perf-check.log | head -1 | awk '{print $4}')
        echo "Production response time: ${avg_time}ms"
        
        # Compare with staging baseline
        if [ -f staging-perf-baseline.log ]; then
            staging_time=$(grep "Time per request" staging-perf-baseline.log | head -1 | awk '{print $4}')
            echo "Staging baseline: ${staging_time}ms"
            
            # Performance regression check (within 20%)
            performance_ratio=$(echo "scale=2; $avg_time / $staging_time" | bc)
            if (( $(echo "$performance_ratio > 1.2" | bc -l) )); then
                echo "⚠️ Performance regression detected (${performance_ratio}x slower)"
            else
                echo "✅ Performance within acceptable range"
            fi
        fi
    else
        echo "ℹ️ Manual performance validation required"
        read -p "Production performance acceptable? (yes/no): " perf_ok
        if [[ "$perf_ok" != "yes" ]]; then
            echo "❌ Performance validation failed"
            exit 1
        fi
    fi
}

production_functionality_verification() {
    echo "🎯 Production Functionality Verification"
    echo "======================================="
    
    echo "Verify key functionality is working in production:"
    echo "- User registration/login"
    echo "- Core features released in this version"
    echo "- Data synchronization"
    echo "- Email/notification systems"
    echo "- Third-party integrations"
    echo ""
    
    read -p "All key functionality verified? (yes/no): " func_ok
    if [[ "$func_ok" != "yes" ]]; then
        echo "❌ Functionality verification failed"
        echo "🚨 CONSIDER ROLLBACK OR HOTFIX"
        exit 1
    fi
    
    echo "✅ Production functionality verified"
}

post_deployment_monitoring() {
    echo "📊 POST-DEPLOYMENT MONITORING"
    echo "============================="
    
    # Update status
    sed -i.bak 's/PHASE=PRODUCTION/PHASE=POST_RELEASE/' .release_config
    rm -f .release_config.bak
    
    # Start monitoring period
    start_monitoring_period
    
    # Monitor key metrics
    monitor_production_metrics
    
    # Track user feedback
    monitor_user_feedback
    
    # Generate deployment report
    generate_deployment_report
}

start_monitoring_period() {
    echo "⏰ Starting 24-hour monitoring period"
    echo "====================================="
    
    echo "🕐 Monitoring started at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    echo ""
    echo "Monitor the following for 24 hours:"
    echo "- Error rates and exceptions"
    echo "- Performance metrics"
    echo "- User activity and engagement"
    echo "- Support ticket volume"
    echo "- Business metrics"
    echo ""
    
    # Create monitoring checklist
    cat > POST_DEPLOYMENT_MONITORING.md << EOF
# Post-Deployment Monitoring - $RELEASE_VERSION

**Deployment Time:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')
**Monitoring Period:** 24 hours
**Release Manager:** $RELEASE_MANAGER

## Monitoring Checklist

### Immediate (First Hour)
- [ ] **0-15 min:** Error rate monitoring
- [ ] **15-30 min:** Performance baseline check
- [ ] **30-45 min:** User activity verification
- [ ] **45-60 min:** Support ticket review

### Short-term (First 6 Hours)
- [ ] **Hour 2:** Business metrics check
- [ ] **Hour 3:** External integration status
- [ ] **Hour 4:** Database performance review
- [ ] **Hour 5:** User feedback collection
- [ ] **Hour 6:** Complete system health review

### Extended (24 Hours)
- [ ] **Hour 12:** Mid-point comprehensive review
- [ ] **Hour 18:** User engagement analysis
- [ ] **Hour 24:** Final monitoring report

## Key Metrics Dashboard

### Error Rates
- Current: [To be updated]
- Baseline: [Previous release baseline]
- Threshold: <2% increase

### Performance
- Response Time: [To be updated]
- Throughput: [To be updated]
- Resource Usage: [To be updated]

### Business Metrics
- User Registrations: [To be updated]
- Transaction Volume: [To be updated]
- Active Users: [To be updated]

## Issues Detected
[None yet - update as issues are identified]

## Actions Taken
[None yet - update as actions are taken]

---
**Monitoring Status:** IN PROGRESS
**Last Updated:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')
EOF
    
    echo "📋 Monitoring checklist created: POST_DEPLOYMENT_MONITORING.md"
}

monitor_production_metrics() {
    echo "📈 Monitoring Production Metrics"
    echo "==============================="
    
    # Basic monitoring for first hour
    for i in {1..4}; do
        echo ""
        echo "🕐 Monitoring check $i/4 ($(date '+%H:%M'))..."
        
        # Error rate check
        if [ -f /var/log/application.log ]; then
            current_errors=$(tail -1000 /var/log/application.log | grep "$(date '+%Y-%m-%d %H:')" | grep -c -i "error\|exception")
            echo "  Errors in last hour: $current_errors"
        fi
        
        # Health check
        if curl -sf https://example.com/health &>/dev/null; then
            echo "  ✅ Health check: OK"
        else
            echo "  ❌ Health check: FAILED"
            echo "🚨 PRODUCTION HEALTH ISSUE DETECTED!"
            break
        fi
        
        # Performance check
        response_time=$(curl -o /dev/null -s -w '%{time_total}' https://example.com/)
        echo "  Response time: ${response_time}s"
        
        # Wait 15 minutes between checks
        if [ $i -lt 4 ]; then
            echo "  ⏳ Next check in 15 minutes..."
            sleep 900
        fi
    done
    
    echo "✅ Initial monitoring period completed"
}

monitor_user_feedback() {
    echo "👥 Monitoring User Feedback"
    echo "=========================="
    
    echo "Monitor user feedback channels:"
    echo "- Support tickets/helpdesk"
    echo "- Social media mentions"
    echo "- App store reviews"
    echo "- User forums/community"
    echo "- Direct user feedback"
    echo ""
    
    echo "Set up alerts for:"
    echo "- Sudden increase in support tickets"
    echo "- Negative sentiment spikes"
    echo "- Feature-specific complaints"
    echo "- Performance-related feedback"
    echo ""
    
    read -p "User feedback monitoring configured? (yes/no): " feedback_ok
    if [[ "$feedback_ok" == "yes" ]]; then
        echo "✅ User feedback monitoring active"
    else
        echo "⚠️ Configure user feedback monitoring"
    fi
}

generate_deployment_report() {
    echo "📋 Generating Deployment Report"
    echo "==============================="
    
    cat > "deployment-report-$RELEASE_VERSION.md" << EOF
# Deployment Report - $RELEASE_VERSION

**Deployment Date:** $(date -u '+%Y-%m-%d')
**Release Manager:** $RELEASE_MANAGER
**Deployment Duration:** [Calculate from logs]

## Deployment Summary

### Timeline
- **Planning Started:** $(date -d "@$(cat .release_config | grep CREATED_DATE= | cut -d= -f2)" '+%Y-%m-%d %H:%M')
- **Feature Freeze:** [Date from release config]
- **Staging Deployed:** [Date from logs]
- **Production Deployed:** $(date -u '+%Y-%m-%d %H:%M')

### Release Highlights
$(grep -A 10 "## 🎯 Release Highlights" RELEASE_NOTES.md | tail -n +2 | head -n -1)

### Deployment Statistics
- **Commits:** $(git rev-list --count $(git describe --tags --abbrev=0 HEAD~1)..HEAD)
- **Files Changed:** $(git diff --name-only $(git describe --tags --abbrev=0 HEAD~1)..HEAD | wc -l)
- **Contributors:** $(git shortlog -sn $(git describe --tags --abbrev=0 HEAD~1)..HEAD | wc -l)

### Quality Metrics
- **Tests Passed:** ✅ All
- **Security Scan:** ✅ Clean
- **Performance:** ✅ Within baseline
- **Stakeholder Approvals:** ✅ Complete

## Deployment Process

### Pre-deployment
- [x] Validation completed
- [x] Stakeholder approvals obtained
- [x] Production backup created
- [x] Rollback plan prepared

### Deployment Execution
- [x] Release tagged: $RELEASE_VERSION
- [x] Production deployment successful
- [x] Health checks passed
- [x] Smoke tests completed

### Post-deployment
- [x] Monitoring initiated
- [x] Performance verified
- [x] User feedback tracking started

## Issues Encountered

### During Deployment
[None reported - update if issues occurred]

### Post-deployment
[Monitor for 24 hours and update]

## Success Metrics

### Technical
- **Deployment Success:** ✅ 100%
- **Zero Downtime:** ✅ Achieved
- **Rollback Required:** ❌ No
- **Performance Impact:** ✅ Minimal

### Business
- **User Impact:** Positive
- **Feature Adoption:** [To be measured]
- **Error Rate:** [Within baseline]

## Lessons Learned

### What Went Well
- Comprehensive validation process
- Smooth stakeholder approval process
- Automated deployment pipeline
- Effective monitoring setup

### Areas for Improvement
[To be identified during retrospective]

## Next Steps

### Immediate (24 hours)
- [ ] Continue monitoring key metrics
- [ ] Address any emerging issues
- [ ] Collect user feedback
- [ ] Update documentation

### Short-term (1 week)
- [ ] Analyze adoption metrics
- [ ] Gather detailed user feedback
- [ ] Plan next release cycle
- [ ] Conduct retrospective

### Long-term (1 month)
- [ ] Review release success metrics
- [ ] Implement process improvements
- [ ] Plan feature evolution

---
**Report Status:** INITIAL
**Next Update:** 24 hours post-deployment
**Generated By:** Claude Code Release Workflow
EOF
    
    echo "📊 Deployment report generated: deployment-report-$RELEASE_VERSION.md"
}

announce_release() {
    echo "📢 RELEASE ANNOUNCEMENT"
    echo "======================"
    
    # Generate release announcement
    generate_release_announcement
    
    # Notify stakeholders
    notify_stakeholders
    
    # Update documentation
    update_public_documentation
    
    # Social media/blog post (if applicable)
    prepare_marketing_materials
}

generate_release_announcement() {
    echo "📝 Generating Release Announcement"
    
    cat > "release-announcement-$RELEASE_VERSION.md" << EOF
# 🚀 Release Announcement: $RELEASE_VERSION

We're excited to announce the release of $RELEASE_VERSION! This release brings exciting new features, improvements, and bug fixes to enhance your experience.

## 🎉 What's New

$(grep -A 20 "## ✨ New Features" RELEASE_NOTES.md | tail -n +2 | head -15)

## 🚀 Improvements

$(grep -A 10 "## 🚀 Improvements" RELEASE_NOTES.md | tail -n +2 | head -8)

## 🐛 Bug Fixes

$(grep -A 10 "## 🐛 Bug Fixes" RELEASE_NOTES.md | tail -n +2 | head -8)

## 📈 Performance & Reliability

This release includes significant performance improvements and reliability enhancements:
- Faster load times
- Improved stability
- Enhanced security measures
- Better error handling

## 🚀 Getting Started

### For New Users
1. [Sign up for an account](https://example.com/signup)
2. [Follow our quick start guide](https://docs.example.com/quick-start)
3. [Join our community](https://community.example.com)

### For Existing Users
Your account will automatically receive all the new features and improvements. No action required!

### For Developers
- [Check out our updated API documentation](https://api.example.com/docs)
- [View the migration guide](https://docs.example.com/migration/$RELEASE_VERSION)
- [Download the latest SDK](https://github.com/example/sdk/releases)

## 🙏 Thank You

This release wouldn't be possible without our amazing community of users, contributors, and team members. Special thanks to:

$(git shortlog -sn $(git describe --tags --abbrev=0 HEAD~1)..HEAD | head -10 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*/- /')

## 📚 Resources

- **Full Release Notes:** [View detailed release notes](RELEASE_NOTES.md)
- **Documentation:** [Updated documentation](https://docs.example.com)
- **Support:** [Contact our support team](https://support.example.com)
- **Community:** [Join the discussion](https://community.example.com)

## 📅 What's Next

We're already working on the next release! Here's what you can expect:
- [Upcoming feature 1]
- [Upcoming feature 2]
- [Upcoming improvement 1]

Stay tuned for more updates!

---
**Released:** $(date '+%B %d, %Y')
**Version:** $RELEASE_VERSION
**Release Manager:** $RELEASE_MANAGER
EOF
    
    echo "✅ Release announcement generated"
}

notify_stakeholders() {
    echo "📧 Notifying Stakeholders"
    echo "========================"
    
    echo "Send notifications to:"
    echo "- Internal team members"
    echo "- Key customers/users"
    echo "- Partner organizations"
    echo "- Support team"
    echo "- Sales team"
    echo ""
    
    read -p "Send stakeholder notifications? (yes/no): " send_notifications
    if [[ "$send_notifications" == "yes" ]]; then
        echo "📧 Stakeholder notifications should be sent"
        echo "Include: release-announcement-$RELEASE_VERSION.md"
    fi
}

update_public_documentation() {
    echo "📚 Updating Public Documentation"
    echo "==============================="
    
    echo "Update the following documentation:"
    echo "- Website changelog"
    echo "- API documentation"
    echo "- User guides"
    echo "- Developer documentation"
    echo "- FAQ updates"
    echo ""
    
    read -p "Documentation updates scheduled? (yes/no): " docs_scheduled
    if [[ "$docs_scheduled" == "yes" ]]; then
        echo "✅ Documentation updates scheduled"
    fi
}

prepare_marketing_materials() {
    echo "📱 Preparing Marketing Materials"
    echo "==============================="
    
    echo "Consider preparing:"
    echo "- Blog post announcement"
    echo "- Social media posts"
    echo "- Newsletter content"
    echo "- Press release (for major releases)"
    echo "- Video demo/walkthrough"
    echo ""
    
    read -p "Marketing materials needed? (yes/no): " marketing_needed
    if [[ "$marketing_needed" == "yes" ]]; then
        echo "📢 Marketing materials should be prepared"
        echo "Coordinate with marketing team"
    fi
}
```

## Phase 5: Post-Release Activities

**Release Retrospective & Cleanup:**
```bash
complete_release_cycle() {
    echo "🎯 COMPLETING RELEASE CYCLE"
    echo "==========================="
    
    source .release_config
    
    # Final monitoring check
    final_monitoring_review
    
    # Cleanup release artifacts
    cleanup_release_artifacts
    
    # Schedule retrospective
    schedule_release_retrospective
    
    # Close release milestone
    close_release_milestone
    
    # Prepare next release
    prepare_next_release
    
    # Final status update
    finalize_release_status
}

final_monitoring_review() {
    echo "📊 Final Monitoring Review"
    echo "=========================="
    
    echo "24-hour monitoring period complete"
    echo "Reviewing final metrics and status..."
    
    # Update monitoring report
    cat >> POST_DEPLOYMENT_MONITORING.md << EOF

## Final 24-Hour Summary

**Monitoring Completed:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')

### Overall Status
- **Release Stability:** ✅ Stable
- **Performance Impact:** ✅ Minimal
- **User Feedback:** ✅ Positive
- **Business Metrics:** ✅ Trending positive

### Key Findings
- Error rates remained within normal range
- Performance metrics stable
- No critical issues reported
- User adoption proceeding as expected

### Actions Taken
[List any issues addressed during monitoring period]

### Recommendations
- Continue standard monitoring
- No immediate action required
- Proceed with normal operations

---
**Final Status:** ✅ SUCCESSFUL RELEASE
**Monitoring Period:** COMPLETE
EOF
    
    echo "✅ Final monitoring review completed"
}

cleanup_release_artifacts() {
    echo "🧹 Cleaning Up Release Artifacts"
    echo "==============================="
    
    current_branch=$(get_current_branch)
    
    # Archive release branch
    if [[ "$current_branch" == release/* ]]; then
        echo "📦 Archiving release branch..."
        
        # Create archive tag
        archive_tag="archive/$(echo $current_branch | tr '/' '-')"
        git tag "$archive_tag" "$current_branch"
        git push origin "$archive_tag"
        
        # Switch to main
        git checkout main
        git pull origin main
        
        # Delete release branch
        git branch -d "$current_branch"
        git push origin --delete "$current_branch"
        
        echo "✅ Release branch archived: $archive_tag"
    fi
    
    # Archive release documentation
    release_archive_dir="releases/$RELEASE_VERSION"
    mkdir -p "$release_archive_dir"
    
    # Move release files to archive
    for file in RELEASE_NOTES.md RELEASE_CHECKLIST.md STAGING_APPROVALS.md POST_DEPLOYMENT_MONITORING.md; do
        if [ -f "$file" ]; then
            mv "$file" "$release_archive_dir/"
        fi
    done
    
    # Move reports to archive
    mv validation-report-*.md "$release_archive_dir/" 2>/dev/null || true
    mv deployment-report-*.md "$release_archive_dir/" 2>/dev/null || true
    mv release-announcement-*.md "$release_archive_dir/" 2>/dev/null || true
    
    # Create archive summary
    cat > "$release_archive_dir/README.md" << EOF
# Release Archive: $RELEASE_VERSION

**Release Date:** $TARGET_DATE
**Release Manager:** $RELEASE_MANAGER
**Archive Date:** $(date -u '+%Y-%m-%d')

## Contents

- **RELEASE_NOTES.md** - Complete release notes
- **RELEASE_CHECKLIST.md** - Release checklist with completion status
- **STAGING_APPROVALS.md** - Stakeholder approval record
- **POST_DEPLOYMENT_MONITORING.md** - Post-deployment monitoring results
- **validation-report-*.md** - Pre-release validation results
- **deployment-report-*.md** - Deployment execution report
- **release-announcement-*.md** - Public release announcement

## Release Summary

- **Status:** ✅ Successfully Deployed
- **Timeline:** $(echo $(($(date +%s) - $(cat .release_config | grep CREATED_DATE= | cut -d= -f2))) | awk '{print int($1/86400)}') days from planning to completion
- **Issues:** [None reported / List any issues]
- **Lessons Learned:** [Key takeaways from retrospective]

## Quick Access

- **Release Tag:** $RELEASE_VERSION
- **Archive Tag:** $archive_tag
- **Production Branch:** production (or main)

---
**Archived by:** Claude Code Release Workflow
EOF
    
    # Commit archive
    git add releases/
    git commit -m "archive: complete $RELEASE_VERSION release documentation

All release artifacts and documentation have been archived
for future reference and compliance purposes.

Release: $RELEASE_VERSION
Status: Successfully completed
Archive: releases/$RELEASE_VERSION"
    
    git push origin main
    
    # Cleanup temporary files
    rm -f .release_config
    rm -f staging-perf-baseline.log
    rm -f prod-perf-check.log
    rm -f security-report.json
    rm -f perf-test.log
    
    echo "✅ Release artifacts cleaned up and archived"
}

schedule_release_retrospective() {
    echo "📅 Scheduling Release Retrospective"
    echo "=================================="
    
    cat > "retrospective-$RELEASE_VERSION.md" << EOF
# Release Retrospective - $RELEASE_VERSION

**Release:** $RELEASE_VERSION
**Release Manager:** $RELEASE_MANAGER
**Retrospective Date:** [To be scheduled within 1 week]

## Participants

**Required Attendees:**
- Release Manager: $RELEASE_MANAGER
- Engineering Lead
- QA Lead
- Product Manager
- DevOps/SRE Lead

**Optional Attendees:**
- UX/Design Lead
- Business Stakeholders
- Customer Success

## Agenda (60 minutes)

### 1. Release Overview (10 minutes)
- Timeline review
- Key metrics summary
- Overall success assessment

### 2. What Went Well (15 minutes)
- Process improvements that worked
- Tools and automation successes
- Team collaboration highlights
- Quality achievements

### 3. What Didn't Go Well (15 minutes)
- Process gaps or inefficiencies
- Technical challenges faced
- Communication issues
- Timeline or scope problems

### 4. Action Items (15 minutes)
- Process improvements to implement
- Tools or automation to add/improve
- Documentation updates needed
- Training or skill development needs

### 5. Next Release Planning (5 minutes)
- Key dates for next release
- Process changes to implement
- Resource allocation considerations

## Pre-Retrospective Data

### Timeline Analysis
- **Planning Duration:** [Calculate from release config]
- **Development Duration:** [Calculate from feature freeze to staging]
- **Staging Duration:** [Calculate staging to production timeline]
- **Total Release Cycle:** [Calculate total duration]

### Quality Metrics
- **Bugs Found in Production:** [Count from monitoring]
- **Rollback Required:** No
- **Performance Impact:** Minimal
- **User Satisfaction:** [From feedback monitoring]

### Process Metrics
- **Checklist Completion:** 100%
- **Stakeholder Approval Time:** [Calculate from logs]
- **Deployment Success Rate:** 100%
- **Monitoring Alert Count:** [From monitoring period]

## Discussion Topics

### Process Questions
1. Was the release timeline realistic and achievable?
2. Were quality gates effective in catching issues?
3. Did stakeholder approval process work smoothly?
4. Was documentation adequate throughout the process?

### Technical Questions
1. Were there any surprising technical challenges?
2. Did automated testing catch all relevant issues?
3. Was the deployment process smooth and reliable?
4. Were monitoring and alerting sufficient?

### Collaboration Questions
1. Was communication effective across teams?
2. Were roles and responsibilities clear?
3. Did we have the right people involved at the right times?
4. How can we improve cross-team collaboration?

## Action Items Template

| Item | Owner | Priority | Due Date | Status |
|------|--------|----------|----------|--------|
| [Action item description] | [Name] | High/Med/Low | [Date] | Open |

## Retrospective Notes

[To be filled during retrospective meeting]

### What Went Well
- [Item 1]
- [Item 2]

### Areas for Improvement
- [Item 1]
- [Item 2]

### Decisions Made
- [Decision 1]
- [Decision 2]

### Action Items
- [Action 1]
- [Action 2]

---
**Created:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')
**Status:** Scheduled
EOF
    
    echo "📋 Retrospective template created: retrospective-$RELEASE_VERSION.md"
    echo ""
    echo "Schedule retrospective meeting within 1 week with all stakeholders"
    
    read -p "Schedule retrospective meeting? (yes/no): " schedule_retro
    if [[ "$schedule_retro" == "yes" ]]; then
        echo "📅 Retrospective meeting should be scheduled"
        echo "Include: retrospective-$RELEASE_VERSION.md"
    fi
}

close_release_milestone() {
    echo "🏁 Closing Release Milestone"
    echo "==========================="
    
    # Close GitHub milestone if using GitHub
    if command -v gh &> /dev/null; then
        echo "Closing GitHub milestone for $RELEASE_VERSION..."
        gh api repos/:owner/:repo/milestones \
            --jq ".[] | select(.title == \"Release $RELEASE_VERSION\") | .number" | \
        while read milestone_number; do
            gh api repos/:owner/:repo/milestones/"$milestone_number" \
                --method PATCH \
                --field state="closed" 2>/dev/null || echo "Milestone closure failed"
        done
    fi
    
    echo "✅ Release milestone closed"
}

prepare_next_release() {
    echo "🔮 Preparing Next Release"
    echo "========================"
    
    # Calculate next version
    current_version=$(echo "$RELEASE_VERSION" | sed 's/^v//')
    IFS='.' read -ra VERSION_PARTS <<< "$current_version"
    
    major=${VERSION_PARTS[0]}
    minor=${VERSION_PARTS[1]}
    patch=${VERSION_PARTS[2]}
    
    # Suggest next versions
    echo "Current version: $RELEASE_VERSION"
    echo ""
    echo "Suggested next versions:"
    echo "1. Patch: v$major.$minor.$((patch + 1)) (bug fixes only)"
    echo "2. Minor: v$major.$((minor + 1)).0 (new features)"
    echo "3. Major: v$((major + 1)).0.0 (breaking changes)"
    echo ""
    
    read -p "Plan next release version? (1/2/3/skip): " next_version_choice
    
    case $next_version_choice in
        1) next_version="v$major.$minor.$((patch + 1))" ;;
        2) next_version="v$major.$((minor + 1)).0" ;;
        3) next_version="v$((major + 1)).0.0" ;;
        *) 
            echo "Next release planning skipped"
            return
            ;;
    esac
    
    echo "Next release: $next_version"
    
    # Create next release planning document
    cat > "next-release-planning.md" << EOF
# Next Release Planning: $next_version

**Previous Release:** $RELEASE_VERSION
**Planning Started:** $(date -u '+%Y-%m-%d')
**Proposed Release:** $next_version

## Preliminary Planning

### Release Type
$(case $next_version_choice in
    1) echo "**Patch Release** - Bug fixes and minor improvements";;
    2) echo "**Minor Release** - New features and enhancements";;
    3) echo "**Major Release** - Significant changes and breaking changes";;
esac)

### Target Timeline
- **Planning Phase:** [Define timeline]
- **Development Phase:** [Define timeline]
- **Testing Phase:** [Define timeline]
- **Release Date:** [Target date]

### Preliminary Scope

#### Must-Have Features
- [ ] [Feature/fix 1]
- [ ] [Feature/fix 2]

#### Nice-to-Have Features
- [ ] [Enhancement 1]
- [ ] [Enhancement 2]

#### Technical Debt
- [ ] [Debt item 1]
- [ ] [Debt item 2]

### Lessons from $RELEASE_VERSION

#### Process Improvements to Implement
- [Improvement from retrospective]
- [Improvement from retrospective]

#### Tools/Automation Enhancements
- [Enhancement 1]
- [Enhancement 2]

### Resource Planning

#### Team Capacity
- Development: [Available capacity]
- QA: [Available capacity]
- DevOps: [Available capacity]
- Design: [Available capacity]

#### External Dependencies
- [Dependency 1]
- [Dependency 2]

### Risk Assessment

#### Technical Risks
- [Risk 1 and mitigation]
- [Risk 2 and mitigation]

#### Schedule Risks
- [Risk 1 and mitigation]
- [Risk 2 and mitigation]

## Next Steps

1. [ ] Conduct requirements gathering
2. [ ] Create detailed project plan
3. [ ] Assign team members
4. [ ] Set up project tracking
5. [ ] Schedule kickoff meeting

---
**Status:** Draft
**Owner:** [To be assigned]
**Next Review:** [Schedule review meeting]
EOF
    
    echo "📋 Next release planning document created: next-release-planning.md"
    
    # Commit planning document
    git add next-release-planning.md
    git commit -m "plan: initialize $next_version release planning

Start planning for next release cycle based on lessons
learned from $RELEASE_VERSION release.

Previous Release: $RELEASE_VERSION
Next Release: $next_version
Status: Initial planning"
    
    git push origin main
    
    echo "✅ Next release planning initiated"
}

finalize_release_status() {
    echo "✅ FINALIZING RELEASE STATUS"
    echo "============================"
    
    echo "🎉 RELEASE $RELEASE_VERSION COMPLETED SUCCESSFULLY!"
    echo ""
    echo "📊 Final Summary:"
    echo "- Release: $RELEASE_VERSION"
    echo "- Manager: $RELEASE_MANAGER"
    echo "- Status: ✅ Complete"
    echo "- Duration: $(echo $(($(date +%s) - $(cat .release_config 2>/dev/null | grep CREATED_DATE= | cut -d= -f2 2>/dev/null || echo $(date +%s)))) | awk '{print int($1/86400)}') days"
    echo "- Quality: ✅ All gates passed"
    echo "- Deployment: ✅ Successful"
    echo "- Monitoring: ✅ Stable"
    echo ""
    echo "🎯 Achievements:"
    echo "- Zero downtime deployment"
    echo "- All quality gates passed"
    echo "- Stakeholder approval obtained"
    echo "- Comprehensive monitoring completed"
    echo "- Documentation archived"
    echo ""
    echo "📚 Artifacts Created:"
    echo "- Release tag: $RELEASE_VERSION"
    echo "- Archive directory: releases/$RELEASE_VERSION"
    echo "- Deployment report: releases/$RELEASE_VERSION/deployment-report-$RELEASE_VERSION.md"
    echo "- Retrospective template: retrospective-$RELEASE_VERSION.md"
    echo ""
    echo "🔄 Next Steps:"
    echo "- Conduct retrospective meeting"
    echo "- Implement process improvements"
    echo "- Plan next release cycle"
    echo "- Continue monitoring user feedback"
    echo ""
    echo "🙏 Thank you for following the release workflow!"
    echo "The release process ensures quality, reliability, and team collaboration."
}
```

## Emergency Procedures

**Release Rollback:**
```bash
emergency_release_rollback() {
    echo "🚨 EMERGENCY RELEASE ROLLBACK"
    echo "============================="
    
    echo "⚠️  CRITICAL: This will rollback the entire release!"
    read -p "Type 'ROLLBACK RELEASE' to confirm: " rollback_confirm
    
    if [[ "$rollback_confirm" != "ROLLBACK RELEASE" ]]; then
        echo "Rollback cancelled"
        exit 1
    fi
    
    # Find backup tag
    backup_tag=$(git tag -l "backup-pre-$RELEASE_VERSION-*" | head -1)
    
    if [ -z "$backup_tag" ]; then
        echo "❌ No backup tag found for $RELEASE_VERSION"
        echo "Manual rollback required"
        exit 1
    fi
    
    echo "Rolling back to: $backup_tag"
    
    # Rollback production
    if git show-ref --verify --quiet refs/heads/production; then
        target_branch="production"
    else
        target_branch="main"
    fi
    
    git checkout "$target_branch"
    git reset --hard "$backup_tag"
    git push --force-with-lease origin "$target_branch"
    
    # Tag the rollback
    rollback_tag="rollback-$RELEASE_VERSION-$(date +%Y%m%d-%H%M%S)"
    git tag -a "$rollback_tag" -m "Emergency rollback of $RELEASE_VERSION"
    git push origin "$rollback_tag"
    
    echo "✅ Emergency rollback completed"
    echo "🏷️  Rollback tag: $rollback_tag"
    echo "🔍 Investigate release issues before redeployment"
}
```

## Best Practices Summary

1. **Comprehensive Planning**
   - Clear requirements and scope
   - Realistic timelines
   - Stakeholder alignment

2. **Quality at Every Stage**
   - Automated testing and validation
   - Multiple approval gates
   - Performance monitoring

3. **Risk Management**
   - Thorough backup procedures
   - Detailed rollback plans
   - Comprehensive monitoring

4. **Team Collaboration**
   - Clear communication channels
   - Defined roles and responsibilities
   - Regular status updates

## Workflow Summary

The release workflow ensures:
- ✅ Comprehensive release planning and documentation
- ✅ Quality gates at every phase of the release
- ✅ Stakeholder involvement and approval processes
- ✅ Safe deployment with backup and rollback procedures
- ✅ Thorough post-release monitoring and support
- ✅ Continuous improvement through retrospectives

Remember: **Successful releases are built on process, not luck!**