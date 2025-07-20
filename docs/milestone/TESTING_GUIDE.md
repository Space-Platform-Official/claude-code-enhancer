# 🧪 Milestone System Testing Guide

## How to Verify the Milestone Commands Work as Expected

This guide helps you validate that the Enhanced Hybrid Milestone Architecture is functioning correctly across all scales and scenarios.

### 🚨 **Quick Health Check**

Run this first to verify basic system health:

```bash
# Basic system validation
/milestone/status --health

# Hybrid architecture validation  
/milestone/status --validate-architecture

# Storage system check
/milestone/status --validate-storage
```

**Expected output**: All green checkmarks ✅

### 🧪 **Comprehensive Testing Scenarios**

#### **Test 1: Individual Developer Scenario (File Backend)**

**Goal**: Verify file-based storage and simple UI for small projects

```bash
# 1. Create a small project
/milestone/plan "Personal website project"

# 2. Check that file backend is used
/milestone/status --scale-info
# Expected: Backend: file, UI Level: simple

# 3. Verify milestone creation
ls .milestones/active/
# Expected: milestone-001.yaml (or similar)

# 4. Test basic execution
/milestone/execute

# 5. Verify progress tracking
/milestone/status
# Expected: Simple text output with progress bar
```

#### **Test 2: Team Scale Transition (Hybrid Backend)**

**Goal**: Verify automatic scaling to hybrid backend with rich UI

```bash
# 1. Create multiple milestones to trigger scaling
for i in {1..15}; do
    /milestone/plan "Team project milestone $i"
done

# 2. Check automatic backend transition
/milestone/status --scale-info
# Expected: Backend: hybrid, UI Level: rich

# 3. Verify SQLite index creation
ls .milestones/
# Expected: index.db file should exist

# 4. Test rich UI output
/milestone/status
# Expected: Rich terminal output with colors, task breakdown
```

#### **Test 3: Enterprise Scale (Database Backend)**

**Goal**: Verify database backend and dashboard UI for large projects

```bash
# 1. Simulate large scale (if possible)
# Note: May need to mock this for testing

# 2. Check enterprise features
/milestone/status --dashboard
# Expected: Web dashboard activation message

# 3. Verify database storage
ls .milestones/
# Expected: enterprise.db file should exist
```

#### **Test 4: Kiro Workflow Integration**

**Goal**: Verify design→spec→task→execute workflow phases

```bash
# 1. Create milestone with kiro workflow
/milestone/plan "API development with kiro workflow"

# 2. Enable kiro workflow
/milestone/execute --kiro-enabled

# 3. Verify phase tracking
/milestone/status milestone-001
# Expected: Kiro workflow phases shown with current phase

# 4. Test phase progression (mock approval)
# This would require manual intervention in real scenarios
```

#### **Test 5: Migration System**

**Goal**: Verify zero-downtime backend transitions

```bash
# 1. Start with file backend (< 25 milestones)
/milestone/status --scale-info

# 2. Add milestones to trigger migration
for i in {1..30}; do
    /milestone/plan "Migration test milestone $i"
done

# 3. Verify automatic migration
/milestone/status --scale-info
# Expected: Backend should have changed to hybrid

# 4. Verify data integrity
/milestone/status --validate-storage
# Expected: All milestones still accessible

# 5. Check migration logs
ls .milestones/logs/
# Expected: migration-events.jsonl with migration records
```

### 🔍 **Validation Commands Reference**

#### **System Health Checks**

```bash
# Overall system health
/milestone/status --health

# Architecture validation
/milestone/status --validate-architecture

# Storage integrity check
/milestone/status --validate-storage

# Scale detection info
/milestone/status --scale-info

# UI configuration check
/milestone/status --ui-info

# Migration system status
/milestone/status --migration-status
```

#### **Component-Specific Tests**

```bash
# Storage abstraction test
/milestone/status --test-storage

# Scale detection test
/milestone/status --test-scale-detection

# Progressive UI test
/milestone/status --test-ui-adaptation

# Migration orchestrator test
/milestone/status --test-migration

# Kiro integration test
/milestone/status --test-kiro-integration
```

### 📊 **Expected Behaviors by Scale**

#### **File Backend (1-25 milestones)**
- ✅ Simple text output
- ✅ YAML files in .milestones/active/
- ✅ No database files
- ✅ Fast operations
- ✅ Minimal memory usage

#### **Hybrid Backend (25-100 milestones)**
- ✅ Rich terminal output with colors
- ✅ SQLite index.db file created
- ✅ YAML files + database indexing
- ✅ Enhanced progress displays
- ✅ Task breakdown visualization

#### **Database Backend (100+ milestones)**
- ✅ Web dashboard activation
- ✅ enterprise.db file created
- ✅ Executive-level reporting
- ✅ Real-time metrics
- ✅ Enterprise features enabled

### 🚨 **Troubleshooting Test Failures**

#### **Storage Backend Issues**

```bash
# Problem: Backend not scaling automatically
/milestone/status --scale-info
/milestone/status --force-scale-detection

# Problem: Storage corruption
/milestone/status --validate-storage --repair

# Problem: Migration failures
/milestone/status --migration-status
/milestone/archive --rollback-migration <migration-id>
```

#### **UI Adaptation Issues**

```bash
# Problem: UI not adapting to scale
/milestone/status --ui-info
/milestone/status --refresh-ui

# Problem: Dashboard not activating
/milestone/status --force-dashboard

# Problem: Colors not showing
/milestone/status --test-colors
```

#### **Kiro Workflow Issues**

```bash
# Problem: Kiro phases not progressing
/milestone/status --test-kiro-integration
/milestone/execute --debug-kiro

# Problem: Approval gates not working
/milestone/status --test-approvals
```

### 🧪 **Automated Test Scenarios**

For more comprehensive testing, run the built-in test suite:

```bash
# Run comprehensive validation
/milestone/status --run-validation-suite

# Test all scaling scenarios
/milestone/status --test-scaling-scenarios

# Test migration pathways
/milestone/status --test-migration-paths

# Performance benchmarks
/milestone/status --benchmark-performance

# Integration test suite
/milestone/status --integration-tests
```

### 📋 **Test Checklist**

Use this checklist to verify full system functionality:

- [ ] **Basic Functionality**
  - [ ] Can create milestones with `/milestone/plan`
  - [ ] Can view status with `/milestone/status`
  - [ ] Can execute tasks with `/milestone/execute`
  - [ ] Can update milestones with `/milestone/update`
  - [ ] Can archive with `/milestone/archive`

- [ ] **Storage Scaling**
  - [ ] File backend works for small projects (< 25 milestones)
  - [ ] Automatic transition to hybrid backend (25-100 milestones)
  - [ ] Database backend activation (100+ milestones)
  - [ ] Data integrity maintained across transitions

- [ ] **UI Adaptation**
  - [ ] Simple output for individual developers
  - [ ] Rich terminal output for teams
  - [ ] Web dashboard for enterprise scale
  - [ ] Colors and formatting work correctly

- [ ] **Kiro Integration**
  - [ ] Design phase can be initiated
  - [ ] Spec phase follows design approval
  - [ ] Task phase generates implementation plan
  - [ ] Execute phase completes with deliverables

- [ ] **Migration System**
  - [ ] Automatic migration triggers work
  - [ ] Zero-downtime transitions complete successfully
  - [ ] Backup and rollback capabilities function
  - [ ] Data integrity preserved during migrations

- [ ] **Error Handling**
  - [ ] Graceful degradation when components fail
  - [ ] Clear error messages for user issues
  - [ ] Recovery mechanisms work
  - [ ] System remains stable under load

### ⚡ **Performance Benchmarks**

Expected performance targets:

- **File operations**: < 100ms for read/write
- **Hybrid operations**: < 500ms for complex queries
- **Database operations**: < 1s for large dataset operations
- **UI rendering**: < 200ms for status displays
- **Migration time**: < 5 minutes for 100 milestones

### 🔄 **Continuous Validation**

Set up ongoing validation:

```bash
# Daily health check
/milestone/status --daily-health-check

# Weekly comprehensive validation  
/milestone/status --weekly-validation

# Performance monitoring
/milestone/status --monitor-performance

# Alert on issues
/milestone/status --enable-alerts
```

This testing guide ensures your milestone system operates reliably across all scales and scenarios!