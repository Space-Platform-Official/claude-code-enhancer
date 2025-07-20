# 🎯 Milestone System User Guide

## Quick Start - How to Use Milestone Commands

The Enhanced Hybrid Milestone Architecture provides powerful project management capabilities that automatically scale from individual developers to enterprise teams.

### 🚀 **Basic Workflow**

```bash
# 1. Plan your project milestones
/milestone/plan "Build user authentication system"

# 2. Check status and progress  
/milestone/status

# 3. Execute milestone tasks
/milestone/execute

# 4. Update milestones as needed
/milestone/update milestone-001 --status in_progress

# 5. Archive completed milestones
/milestone/archive milestone-001
```

### 📋 **Available Commands**

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/milestone/plan` | Strategic milestone planning | Start of projects, breaking down complex work |
| `/milestone/execute` | Execute milestone tasks | Daily work, implementing planned milestones |
| `/milestone/review` | Review and approve kiro deliverables | Approving design/spec phases in kiro workflow |
| `/milestone/status` | Check progress and metrics | Regular check-ins, team updates |
| `/milestone/update` | Modify milestone details | Changes in scope, timeline, or progress |
| `/milestone/archive` | Archive completed work | End of milestones, project cleanup |

### 🎬 **Detailed Command Usage**

#### **1. Planning Milestones (`/milestone/plan`)**

**Purpose**: Break down complex projects into manageable milestones

```bash
# Plan a new project
/milestone/plan "Build e-commerce platform"

# Plan with specific scope
/milestone/plan "Implement user authentication with OAuth, JWT, and password reset"
```

**What it does**:
- ✅ Analyzes project scope and complexity
- ✅ Decomposes into 2-4 week milestone chunks  
- ✅ Creates milestone directory structure
- ✅ Sets up kiro workflow integration
- ✅ Initializes tracking and progress monitoring

#### **2. Executing Milestones (`/milestone/execute`)**

**Purpose**: Work on milestone tasks with structured kiro workflow

```bash
# Execute current milestone
/milestone/execute

# Execute specific milestone
/milestone/execute milestone-001

# Execute with kiro workflow phases
/milestone/execute milestone-001 --kiro-enabled
```

**What it does**:
- ✅ Follows design → spec → task → execute workflow
- ✅ Tracks progress across workflow phases
- ✅ Manages approval gates between phases
- ✅ Updates milestone progress automatically

#### **3. Reviewing Kiro Deliverables (`/milestone/review`)**

**Purpose**: Review and approve deliverables from kiro workflow phases

```bash
# Check all pending reviews
/milestone/review --pending

# Review specific task deliverables
/milestone/review milestone-001 task-001 --phase design

# Approve deliverables
/milestone/review milestone-001 task-001 --phase design --approve

# Request changes with feedback
/milestone/review milestone-001 task-001 --phase design --request-changes --feedback "Add security considerations"
```

**What it does**:
- ✅ Displays deliverable content for review
- ✅ Provides interactive approval/rejection interface  
- ✅ Manages approval gates between kiro phases
- ✅ Tracks feedback and revision history
- ✅ Unblocks phase progression after approval

**Interactive Review Process**:
```
=== KIRO WORKFLOW REVIEW: DESIGN PHASE ===
Task: Implement authentication API

📄 DELIVERABLES FOR REVIEW:
1. Architecture Diagram (auth-architecture.md)
2. API Specification (api-spec.yaml)

🎯 REVIEW OPTIONS:
a) Approve this phase
r) Reject this phase  
c) Request changes
f) Add feedback only

Your choice: a
✅ APPROVED: Design phase approved
Phase progression: design → spec unlocked
```

#### **4. Checking Status (`/milestone/status`)**

**Purpose**: Monitor progress, metrics, and overall project health

```bash
# Show all milestone status
/milestone/status

# Show specific milestone
/milestone/status milestone-001

# Show dashboard view (for large projects)
/milestone/status --dashboard
```

**What it shows**:
- ✅ Overall project progress
- ✅ Individual milestone status
- ✅ Task breakdowns and completion rates
- ✅ Risk assessments and blockers
- ✅ Team utilization (for team projects)
- ✅ Timeline adherence

#### **5. Updating Milestones (`/milestone/update`)**

**Purpose**: Modify milestone properties, tasks, or progress

```bash
# Update milestone status
/milestone/update milestone-001 --status completed

# Update milestone priority
/milestone/update milestone-001 --priority high

# Add tasks to milestone
/milestone/update milestone-001 --add-task "Implement login API"

# Update progress
/milestone/update milestone-001 --progress 75
```

#### **6. Archiving Milestones (`/milestone/archive`)**

**Purpose**: Move completed milestones to archive for cleanup

```bash
# Archive specific milestone
/milestone/archive milestone-001

# Archive all completed milestones
/milestone/archive --all-completed

# Archive with backup
/milestone/archive milestone-001 --backup
```

### 🔄 **System Intelligence - What Happens Automatically**

The hybrid architecture provides intelligent capabilities without user intervention:

#### **🏗️ Automatic Scaling**
- **1-25 milestones**: File storage, simple CLI interface
- **25-100 milestones**: Hybrid storage with SQLite index, rich terminal UI
- **100+ milestones**: Database storage, web dashboard interface

#### **🎨 Progressive UI Adaptation**
- **Individual developers**: Simple text output
- **Small teams**: Rich terminal with colors, progress bars
- **Enterprise teams**: Web dashboard with charts and metrics

#### **🔄 Zero-Downtime Migrations**
- Storage backend automatically upgrades based on scale
- Full backup and rollback capabilities
- No user intervention required

### 🎯 **Use Cases by Project Scale**

#### **👤 Individual Developer (1-10 milestones)**
```bash
# Simple personal project workflow
/milestone/plan "Build personal blog"
/milestone/status                    # Shows simple text output
/milestone/execute                   # Basic task execution
```

#### **👥 Small Team (10-50 milestones)**
```bash
# Team project workflow  
/milestone/plan "Build team collaboration tool"
/milestone/status                    # Shows rich terminal UI
/milestone/execute --kiro-enabled    # Structured workflow with approvals

# Review workflow for team approvals
/milestone/review --pending          # Check what needs review
/milestone/review milestone-001 task-001 --phase design --approve
/milestone/status --team-view        # Team utilization metrics
```

#### **🏢 Enterprise Team (50+ milestones)**
```bash
# Enterprise project workflow
/milestone/plan "Build enterprise CRM system"
/milestone/status --dashboard        # Web dashboard automatically activated
/milestone/execute --enterprise      # Full enterprise features
/milestone/status --executive        # Executive-level reporting
```

### 📊 **Understanding System Output**

#### **Simple Output (Individual)**
```
Milestone: User Authentication
Status: in_progress
Progress: 67%
Progress: ████████░ 67%
```

#### **Rich Output (Team)**  
```
=== MILESTONE STATUS ===
User Authentication System
Status: 🔄 in_progress
Priority: 🔥 high

TASK BREAKDOWN:
├── Total Tasks: 8
├── ✅ Completed: 5
├── 🔄 In Progress: 2
└── ⏳ Pending: 1

KIRO WORKFLOW STATUS:
📋 Implement OAuth (Current: spec)
   Phases: ✅ design → 🔄 spec → ⚪ task → ⚪ execute
```

#### **Dashboard Output (Enterprise)**
```
EXECUTIVE DASHBOARD
==================
PROJECT: Enterprise CRM System
OVERALL PROGRESS: 34%
STATUS: on_track

KEY METRICS:
├── Estimated Effort: 2400h
├── Actual Effort: 1100h  
├── Efficiency Ratio: 1.15
└── On-Track Status: On Track

RISK ASSESSMENT:
├── 🔴 High Risk: 2 items
├── 🟡 Medium Risk: 5 items
└── 🟢 Low Risk: 12 items
```

### 🔄 **Complete Kiro Review Workflow Example**

Here's a complete example showing how the review process works with kiro workflows:

```bash
# 1. Developer creates milestone with kiro workflow
/milestone/plan "User authentication system" --enable-kiro

# 2. Developer starts execution
/milestone/execute milestone-001
# → System creates design deliverables
# → Pauses at design approval gate
# → Notifies required approvers

# 3. Check pending reviews (as reviewer)
/milestone/review --pending
# → Shows: design phase pending approval for task-001

# 4. Review design deliverables
/milestone/review milestone-001 task-001 --phase design
# → Displays architecture diagram and API specification
# → Interactive review interface appears

# 5. Approve or provide feedback
/milestone/review milestone-001 task-001 --phase design --approve --comment "Architecture looks good"
# → Design phase approved
# → System automatically progresses to spec phase

# 6. Continue execution
/milestone/execute milestone-001
# → Creates spec deliverables
# → Pauses at spec approval gate

# 7. Review spec phase
/milestone/review milestone-001 task-001 --phase spec
# → Review technical specifications and test plans

# 8. Request changes if needed
/milestone/review milestone-001 task-001 --phase spec --request-changes --feedback "Add security test cases"

# 9. Developer updates and resubmits
# → Updates deliverables based on feedback
# → System automatically marks for re-review

# 10. Re-review and approve
/milestone/review milestone-001 task-001 --phase spec --approve
# → Spec phase approved
# → Progression to task and execute phases unlocked

# 11. Complete execution
/milestone/execute milestone-001
# → Completes remaining phases
# → Milestone marked as complete
```

### 🛠️ **Troubleshooting Common Issues**

#### **Issue**: "Milestone not found"
```bash
# Check if milestone exists
/milestone/status  # Lists all milestones

# List archived milestones
/milestone/archive --list
```

#### **Issue**: "Storage backend error"
```bash
# Check system health
/milestone/status --health

# Force storage validation
/milestone/status --validate-storage
```

#### **Issue**: "UI not adapting to scale"
```bash
# Force UI refresh
/milestone/status --refresh-ui

# Check scale detection
/milestone/status --scale-info
```

### 🎓 **Best Practices**

1. **Start with Planning**: Always begin with `/milestone/plan` for structured approach
2. **Regular Status Checks**: Use `/milestone/status` for daily/weekly check-ins
3. **Use Kiro Workflow**: Enable `--kiro-enabled` for complex tasks requiring approval
4. **Archive Completed Work**: Regular cleanup with `/milestone/archive`
5. **Let the System Scale**: Trust the automatic scaling - don't force configurations

### 🔗 **Integration Points**

- **Git Integration**: Automatic branch management and commit tracking
- **CI/CD**: Milestone progress triggers for automated pipelines
- **Team Tools**: Export capabilities for Jira, Slack, etc.
- **Reporting**: Executive dashboards and progress reports

This guide provides the foundation for using the milestone system effectively across any project scale!