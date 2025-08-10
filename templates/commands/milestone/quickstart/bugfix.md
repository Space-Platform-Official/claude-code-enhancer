---
allowed-tools: all
description: Bug fix milestone template - Fast resolution with root cause analysis
---

# 🐛 Bug Fix Milestone Template

**Streamlined milestone for fixing specific issues. Fast resolution with proper analysis and prevention.**

## 🎯 What This Template Does

✅ **Creates focused bug fix milestone** with systematic investigation  
✅ **Root cause analysis included** to prevent similar issues  
✅ **Quick turnaround structure** for urgent fixes  
✅ **Built-in testing validation** to ensure fix works properly  

---

## 🚀 Quick Setup

```bash
# Create your bug fix milestone
/milestone/quickstart/bugfix "Bug description"

# Example:
/milestone/quickstart/bugfix "Users can't login after password reset"
```

**Ready to investigate!** Your bug fix pipeline includes investigation, fix, testing, and prevention.

---

## 📋 Bug Fix Structure

### **Phase 1: Investigation (Hours 1-4)**
- **Focus**: Understand the problem completely
- **Outcome**: Clear root cause identification
- **Key**: Don't fix what you don't understand

### **Phase 2: Fix Implementation (Hours 5-8)**  
- **Focus**: Implement targeted fix with minimal risk
- **Outcome**: Working fix that addresses root cause
- **Key**: Surgical fix, not broad changes

### **Phase 3: Testing & Validation (Hours 9-12)**
- **Focus**: Comprehensive testing of fix and related functionality
- **Outcome**: Validated fix that doesn't break anything else
- **Key**: Test the fix and regression test

### **Phase 4: Deploy & Monitor (Hours 13-16)**
- **Focus**: Safe deployment with monitoring
- **Outcome**: Fix deployed and confirmed working in production
- **Key**: Monitor for any side effects

---

## 🎯 Milestone Configuration (Kiro-Native Foundation)

```yaml
milestone:
  id: "bugfix-$(date +%Y%m%d-%H%M%S)"
  title: "$ARGUMENTS"
  type: "bug_fix"
  duration: "2 days"  # 16 working hours typical
  complexity: "focused_fix"
  
  # Kiro workflow (compressed timeline for bugs)
  kiro_configuration:
    enabled: true
    mode: "compressed"  # Quick phases for bugs
    visibility: "minimal"  # Minimal visibility for focused work
    auto_approval: true   # Auto-approve for fast bug fixes
    phase_weights:
      design: 25    # Investigation (shown as "Investigation")
      spec: 25      # Fix implementation (shown as "Fix Implementation")
      task: 25      # Testing and validation (shown as "Testing & Validation")
      execute: 25   # Deploy and monitor (shown as "Deploy & Monitor")
  
  # Bug fix settings
  bug_focus:
    root_cause_analysis: true
    minimal_risk_fix: true
    regression_testing: true
    monitoring_required: true
    
  # Bug fix tracking
  tracking:
    method: "issue_focused"
    reproduction_steps: true
    fix_validation: true
    deployment_monitoring: true
    
  # Phases mapped to kiro workflow
  phases:
    - name: "Investigation"
      kiro_phase: "design"
      duration: "4 hours"
      focus: "root_cause_identification"
      outcome: "clear_understanding"
      deliverables: ["reproduction_steps", "root_cause_analysis"]
      
    - name: "Fix Implementation"
      kiro_phase: "spec"
      duration: "4 hours"
      focus: "targeted_solution"
      outcome: "working_fix"
      deliverables: ["fix_code", "test_cases"]
      
    - name: "Testing & Validation"
      kiro_phase: "task"
      duration: "4 hours"
      focus: "comprehensive_testing"
      outcome: "validated_solution"
      deliverables: ["test_results", "regression_validation"]
      
    - name: "Deploy & Monitor"
      kiro_phase: "execute"
      duration: "4 hours"
      focus: "safe_deployment"
      outcome: "production_fix"
      deliverables: ["deployed_fix", "monitoring_setup"]
```

---

## 📝 Generated Bug Fix Tasks

### 🔍 **Phase 1: Investigation (Hours 1-4)**

**Reproduce the Bug**
- [ ] Set up reproduction environment
- [ ] Follow exact steps to reproduce issue
- [ ] Document reproduction steps and conditions
- **Success**: Can reliably reproduce the bug

**Gather Information**
- [ ] Collect error logs and stack traces
- [ ] Check recent code changes and deployments
- [ ] Identify affected user segments and frequency
- **Success**: Complete picture of bug impact and timing

**Root Cause Analysis**
- [ ] Trace through code to identify root cause
- [ ] Understand why the bug wasn't caught earlier
- [ ] Identify related areas that might be affected
- **Success**: Clear understanding of root cause

**Impact Assessment**
- [ ] Determine severity and urgency of fix needed
- [ ] Identify workarounds for immediate relief
- [ ] Assess risk of potential fixes
- **Success**: Clear fix strategy and timeline

---

### 🔧 **Phase 2: Fix Implementation (Hours 5-8)**

**Design the Fix**
- [ ] Plan minimal change that addresses root cause
- [ ] Consider alternative approaches and trade-offs
- [ ] Design fix to be easily testable and reversible
- **Success**: Clear implementation plan

**Implement the Fix**
- [ ] Write the minimal code change to fix the issue
- [ ] Add logging/monitoring for the fixed area
- [ ] Ensure fix handles edge cases properly
- **Success**: Code fix complete and ready for testing

**Create Test Cases**
- [ ] Write specific test for the bug scenario
- [ ] Add tests for related edge cases
- [ ] Ensure fix doesn't break existing functionality
- **Success**: Comprehensive test coverage for fix

**Code Review & Validation**
- [ ] Review fix with another developer
- [ ] Validate fix logic and approach
- [ ] Confirm minimal impact and risk
- **Success**: Fix reviewed and approved

---

### 🧪 **Phase 3: Testing & Validation (Hours 9-12)**

**Unit Testing**
- [ ] Run new tests to verify fix works
- [ ] Run existing unit tests to check for regressions
- [ ] Add any missing test coverage
- **Success**: All unit tests pass

**Integration Testing**
- [ ] Test fix in realistic environment
- [ ] Test user workflows affected by the bug
- [ ] Verify fix works with real data and conditions
- **Success**: Fix works end-to-end

**Regression Testing**
- [ ] Run full test suite to check for side effects
- [ ] Test related functionality manually
- [ ] Verify no new issues introduced
- **Success**: No regressions detected

**Performance Testing**
- [ ] Verify fix doesn't impact performance
- [ ] Test under load if applicable
- [ ] Monitor resource usage
- **Success**: Performance impact acceptable

---

### 🚀 **Phase 4: Deploy & Monitor (Hours 13-16)**

**Deployment Preparation**
- [ ] Prepare deployment plan with rollback strategy
- [ ] Set up monitoring for the fixed area
- [ ] Prepare communication for affected users
- **Success**: Ready for safe deployment

**Production Deployment**
- [ ] Deploy fix to production environment
- [ ] Verify deployment was successful
- [ ] Run smoke tests on production
- **Success**: Fix deployed and basic functionality verified

**Post-Deployment Monitoring**
- [ ] Monitor error rates and user reports
- [ ] Check that original bug is resolved
- [ ] Watch for any unexpected side effects
- **Success**: Fix working in production with no new issues

**Documentation & Prevention**
- [ ] Document the bug, cause, and fix
- [ ] Update processes to prevent similar issues
- [ ] Share learnings with team
- **Success**: Knowledge captured and process improved

---

## 🔍 Bug Investigation Tools

### Reproduction Environment

```bash
# Set up bug reproduction
/milestone/reproduce --setup

# Follow reproduction steps
/milestone/reproduce --execute

# Document findings
/milestone/reproduce --document
```

### Root Cause Analysis

```bash
# Analyze error logs
/milestone/analyze --logs

# Trace code execution
/milestone/analyze --trace

# Check recent changes
/milestone/analyze --changes
```

### Investigation Output

```
=== BUG INVESTIGATION REPORT ===

BUG: Users can't login after password reset
SEVERITY: High (affects 15% of password reset attempts)
FREQUENCY: Started 3 days ago, increasing

REPRODUCTION STEPS:
1. User requests password reset
2. User receives email and clicks reset link
3. User enters new password
4. User attempts to login with new password
5. Login fails with "Invalid credentials" error

ROOT CAUSE ANALYSIS:
├── Issue: Password hash not updated in database
├── Location: auth/resetPassword.js line 47
├── Cause: Transaction rollback bug in password update
├── Introduced: Deploy from 3 days ago (commit abc123)
└── Impact: 127 users affected, 15% of reset attempts

AFFECTED AREAS:
├── Primary: Password reset flow
├── Secondary: Login validation
└── Related: Session management (no impact detected)

FIX STRATEGY:
├── Approach: Fix transaction handling in password update
├── Risk: Low (surgical change to specific function)
├── Timeline: 4 hours for fix + testing
└── Rollback: Easy (revert single commit)
```

---

## 🧪 Testing & Validation Pipeline

### Automated Testing

```bash
# Run bug-specific tests
/milestone/test --bug-fix

# Check for regressions
/milestone/test --regression

# Validate fix in staging
/milestone/test --staging
```

### Manual Validation

```bash
# Test the specific bug scenario
/milestone/validate --bug-scenario

# Test related workflows
/milestone/validate --related-workflows

# User acceptance testing
/milestone/validate --user-acceptance
```

### Testing Results

```
=== BUG FIX VALIDATION ===

BUG SCENARIO TESTING:
✅ Password reset now works correctly
✅ Users can login after reset
✅ New password is properly saved
✅ Password history validation works

REGRESSION TESTING:
✅ Normal login flow unaffected
✅ Other password operations work
✅ User registration unaffected
✅ Session management unchanged

PERFORMANCE IMPACT:
✅ Password reset time: +0.1s (acceptable)
✅ Login time: No impact
✅ Database queries: No increase

USER VALIDATION:
✅ 5 affected users tested fix successfully
✅ 0 reports of new issues
✅ User satisfaction: Restored
```

---

## 📊 Bug Fix Progress Tracking

### Real-time Status

```bash
# Quick bug fix status
/milestone/status --bugfix

# Detailed investigation progress
/milestone/status --investigation

# Testing and deployment status
/milestone/status --deployment
```

### Progress Display

```
Bug Fix: Users can't login after password reset
Progress: ███████░░ 78% (Hour 13 of 16)

PHASE STATUS:
✅ Investigation      (100% complete - Root cause: transaction rollback)
✅ Fix Implementation (100% complete - Fixed transaction handling)
✅ Testing & Validation (100% complete - All tests pass)
🔄 Deploy & Monitor   (50% complete - Deployed, monitoring in progress)

BUG STATUS:
✅ Reproduced: Yes (100% reliable reproduction)
✅ Root Cause: Transaction rollback in password update
✅ Fix: Transaction handling corrected
✅ Tested: All scenarios pass
🔄 Deployed: Production deployment complete
⏳ Monitoring: 2 hours of monitoring remaining

IMPACT:
📈 Users Affected: 127 (before fix)
📉 Error Rate: 15% → 0% (after fix)
⏱️ Resolution Time: 13 hours (target: 16 hours)
```

---

## 🎯 Post-Fix Analysis

### Prevention Measures

```bash
# Generate prevention report
/milestone/prevention --analyze

# Update processes based on learnings
/milestone/prevention --improve

# Share learnings with team
/milestone/prevention --share
```

### Lessons Learned

```
=== POST-FIX ANALYSIS & PREVENTION ===

WHAT WE LEARNED:
├── Root Cause: Database transaction not properly committed
├── Detection Gap: Missing integration test for password reset
├── Response Time: 13 hours from report to fix
└── Communication: Users notified proactively

PREVENTION MEASURES:
├── Added integration test for complete password reset flow
├── Enhanced transaction monitoring in authentication services
├── Updated deployment checklist to include auth flow testing
└── Added automated alert for authentication error spikes

PROCESS IMPROVEMENTS:
├── Bug triage response time: Target reduced from 4h to 2h
├── Testing requirements: Integration tests now required for auth changes
├── Monitoring: Enhanced error tracking for authentication flows
└── Documentation: Added troubleshooting guide for auth issues

TEAM LEARNINGS:
├── Always test complete user workflows, not just individual functions
├── Database transactions need explicit testing with rollback scenarios
├── Authentication changes require extra scrutiny and testing
└── User communication during fixes builds trust and understanding
```

---

## 🎉 Bug Fix Success Celebration

When your bug is fixed:

```
🎉 BUG FIXED SUCCESSFULLY! 🎉

"Users can't login after password reset" is resolved!

🐛 BUG RESOLUTION STATS:
✅ Resolution Time: 13 hours (Target: 16 hours)
✅ Root Cause: Database transaction rollback
✅ Fix: Transaction handling corrected
✅ Testing: All scenarios validated
✅ Deployment: Successful with monitoring

📊 IMPACT METRICS:
   Before Fix: 15% failure rate (127 users affected)
   After Fix: 0% failure rate (all users working)
   User Satisfaction: Fully restored

🔬 INVESTIGATION QUALITY:
✅ Root cause properly identified
✅ Minimal risk fix implemented
✅ Comprehensive testing completed
✅ No regressions introduced

🛡️ PREVENTION MEASURES:
✅ Integration test added for password reset flow
✅ Enhanced monitoring for authentication errors
✅ Process improvements documented
✅ Team knowledge shared

🌟 WHAT'S NEXT?
  a) Monitor for 24 hours to ensure stability
  b) Apply learnings to prevent similar issues
  c) Document best practices for the team

Your choice: _
```

---

## 🔄 Related Actions

### Monitor Fix
```bash
# Continue monitoring the fix
/milestone/monitor --extended --alerts
```

### Apply Learnings
```bash
# Review and improve processes
/milestone/improve --process --from-fix milestone-xxx
```

### Handle Another Bug
```bash
# Create another bug fix milestone
/milestone/quickstart/bugfix "Another bug description"
```

---

## 💡 Bug Fix Best Practices

### 🔍 **Investigation First**
- Always understand before you fix
- Reproduce reliably before attempting fix
- Identify root cause, not just symptoms

### 🎯 **Minimal Risk Fixes**
- Make the smallest change that fixes the issue
- Test thoroughly, including edge cases
- Have a clear rollback plan

### 🧪 **Test Everything**
- Test the specific bug scenario
- Run regression tests
- Validate in production-like environment

### 📚 **Learn and Improve**
- Document what you learned
- Update processes to prevent recurrence
- Share knowledge with the team

---

## 🚨 Implementation

This template automatically:
- ✅ **Creates investigation-driven workflow** with systematic root cause analysis
- ✅ **Sets up minimal risk fix approach** with surgical code changes
- ✅ **Provides comprehensive testing pipeline** including regression testing
- ✅ **Includes deployment monitoring** with rollback capabilities
- ✅ **Generates prevention measures** to avoid similar issues

**Generated Milestone Structure:**
```
.milestones/
├── bugfix-$(timestamp)/
│   ├── milestone.yaml           # Bug fix milestone definition
│   ├── investigation-report.md  # Root cause analysis and findings
│   ├── reproduction-steps.md    # How to reproduce the bug
│   ├── fix-implementation.md    # Details of the fix applied
│   ├── testing-results.md       # Test results and validation
│   ├── deployment-log.md        # Deployment and monitoring log
│   └── prevention-plan.md       # Measures to prevent recurrence
```

**Bug Fix Workflow:**
```bash
# Investigation-driven bug fix (kiro-native)
fix_bug_milestone() {
    local bug_description="$1"
    
    # Initialize kiro with compressed timeline for bugs
    export KIRO_POLICY_MODE="mandatory"
    export KIRO_AUTO_PROGRESS=true   # Auto-approve for fast fixes
    export KIRO_SHOW_PHASES=false    # Minimal visibility for focused work
    export KIRO_COMPRESSED_MODE=true # Quick phases for urgent fixes
    initialize_kiro_native
    
    # Initialize bug fix milestone
    initialize_bugfix_milestone "$bug_description"
    
    # Create kiro tasks with bug-focused deliverables
    create_kiro_native_task "$milestone_id" "Bug investigation and root cause"
    set_task_deliverables "$milestone_id" 1 "reproduction_steps" "root_cause_analysis"
    
    create_kiro_native_task "$milestone_id" "Fix implementation and testing"
    set_task_deliverables "$milestone_id" 2 "fix_code" "test_cases"
    
    create_kiro_native_task "$milestone_id" "Testing and regression validation"
    set_task_deliverables "$milestone_id" 3 "test_results" "regression_validation"
    
    create_kiro_native_task "$milestone_id" "Deployment and monitoring"
    set_task_deliverables "$milestone_id" 4 "deployed_fix" "monitoring_setup"
    
    # Set up investigation tools with kiro tracking
    setup_bug_investigation
    
    # Enable testing and validation
    enable_fix_validation
    
    # Configure deployment monitoring
    setup_deployment_monitoring
    
    echo "✅ Bug fix milestone ready with kiro workflow!"
    echo "⚡ Compressed timeline for fast resolution"
    echo "🔍 Auto-approval for focused bug fixing"
}
```

---

**Your bug fix is systematic and thorough! Focus on understanding, minimal risk, and prevention.**