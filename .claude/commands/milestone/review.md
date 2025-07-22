---
allowed-tools: all
description: Review and approve kiro workflow deliverables within milestone tasks
---

# 🔍 Milestone Kiro Workflow Review & Approval System

## Critical Review Workflow for Kiro Deliverables

When milestone tasks use kiro workflow (design → spec → task → execute), each phase produces deliverables that require review and approval before proceeding to the next phase.

### 🎯 **Review Command Usage**

```bash
# Review all pending deliverables
/milestone/review

# Review specific milestone
/milestone/review milestone-001

# Review specific task deliverables
/milestone/review milestone-001 task-001

# Review specific phase deliverables
/milestone/review milestone-001 task-001 --phase design
```

### 📋 **Review Workflow Process**

#### **1. Check Pending Reviews**
```bash
/milestone/review --pending

# Example output:
PENDING KIRO WORKFLOW REVIEWS
==============================

📋 milestone-001: User Authentication System
└── task-001: Implement authentication API
    ├── 🎨 design phase: PENDING APPROVAL
    │   ├── architecture_diagram → .milestones/deliverables/task-001/design/auth-architecture.md
    │   └── api_specification → .milestones/deliverables/task-001/design/api-spec.yaml
    │   └── Approvers needed: architect, tech_lead
    └── ⏳ spec phase: BLOCKED (waiting for design approval)
```

#### **2. Review Specific Deliverables**
```bash
/milestone/review milestone-001 task-001 --phase design

# This will:
# 1. Display deliverable content for review
# 2. Show approval requirements
# 3. Provide approval/rejection interface
```

#### **3. Approve or Reject Deliverables**
```bash
# Approve specific phase
/milestone/review milestone-001 task-001 --phase design --approve

# Approve with comments
/milestone/review milestone-001 task-001 --phase design --approve --comment "Architecture looks good, proceed with implementation"

# Reject with feedback
/milestone/review milestone-001 task-001 --phase design --reject --feedback "Need to address security concerns in auth flow"

# Request changes
/milestone/review milestone-001 task-001 --phase design --request-changes --feedback "Please add rate limiting to API design"
```

### 🔄 **Review Interface Design**

When you run `/milestone/review milestone-001 task-001 --phase design`, you get:

```
=== KIRO WORKFLOW REVIEW: DESIGN PHASE ===
Task: Implement authentication API
Phase: design → spec
Status: ⏳ PENDING APPROVAL

📄 DELIVERABLES FOR REVIEW:
==========================================

1. Architecture Diagram (auth-architecture.md)
   Path: .milestones/deliverables/task-001/design/auth-architecture.md
   
   [Content displayed here with syntax highlighting]
   
   # Authentication System Architecture
   
   ## Overview
   The authentication system will use JWT tokens with refresh token rotation...
   
   ## Components
   - Auth Service: Handles login/logout/token refresh
   - User Service: Manages user profiles and permissions
   - Security Middleware: Validates tokens on protected routes
   
   ## API Endpoints
   - POST /auth/login
   - POST /auth/logout  
   - POST /auth/refresh
   - GET /auth/me

2. API Specification (api-spec.yaml)
   Path: .milestones/deliverables/task-001/design/api-spec.yaml
   
   [YAML content displayed]
   
   openapi: 3.0.0
   info:
     title: Authentication API
     version: 1.0.0
   paths:
     /auth/login:
       post:
         summary: User login
         requestBody:
           required: true
           content:
             application/json:
               schema:
                 type: object
                 properties:
                   email:
                     type: string
                   password:
                     type: string

🔍 APPROVAL REQUIREMENTS:
========================
Required approvers: architect, tech_lead
Current approvals: none
Status: ⏳ PENDING

💬 PREVIOUS FEEDBACK:
====================
[No previous feedback]

🎯 REVIEW OPTIONS:
=================
a) Approve this phase         (allows progression to spec phase)
r) Reject this phase          (blocks progression, requires rework)
c) Request changes            (feedback loop, stays in design phase)
f) Add feedback only          (comments without blocking)
v) View deliverables again    (re-display content)
q) Quit review

Your choice: _
```

### ⚡ **Interactive Review Process**

#### **Approval Actions**
```bash
# Option A: Approve
"✅ APPROVED: Design phase approved by [your-role]
Phase progression: design → spec unlocked
Next: Task will automatically proceed to spec phase"

# Option R: Reject  
"❌ REJECTED: Design phase rejected by [your-role]
Reason: [user-provided feedback]
Action required: Task author must address feedback and resubmit"

# Option C: Request Changes
"🔄 CHANGES REQUESTED: Design phase needs revision
Feedback: [user-provided feedback] 
Action required: Task author must update deliverables"
```

#### **Feedback Loop Process**
```bash
# When changes are requested:
1. Task author receives notification
2. Author updates deliverables in place
3. System tracks revision history
4. Review process reinitiates automatically
5. Previous feedback is preserved and displayed
```

### 📊 **Review Status Tracking**

#### **Individual Phase Status**
```yaml
design:
  status: "in_review"           # pending, in_review, approved, rejected, changes_requested
  review_history:
    - reviewer: "architect"
      action: "approved"
      timestamp: "2024-07-20T11:45:00Z"
      comment: "Architecture is solid"
    - reviewer: "tech_lead"
      action: "request_changes"
      timestamp: "2024-07-20T12:15:00Z"
      feedback: "Add rate limiting considerations"
  approvals_received: ["architect"]
  approvals_required: ["architect", "tech_lead"]
  approval_status: "partial"    # none, partial, complete
```

#### **Cross-Phase Blocking**
```yaml
# Phases are blocked until predecessors are approved
task_phases:
  design: 
    status: "approved"          # ✅ Can proceed
    approval_gate: "passed"
  spec:
    status: "in_progress"       # ⚡ Currently active
    approval_gate: "pending"   
  task:
    status: "blocked"           # 🚫 Blocked until spec approved
    blocked_reason: "waiting_for_spec_approval"
  execute:
    status: "blocked"           # 🚫 Blocked until task approved
    blocked_reason: "waiting_for_task_approval"
```

### 🔔 **Notification & Alert System**

```bash
# Check pending reviews assigned to you
/milestone/review --my-pending

# Get notified of review requests
/milestone/review --notifications on

# Review reminders
/milestone/review --reminders daily

# Stakeholder alerts
/milestone/review --alerts --when "phase_rejected,changes_requested"
```

### 🎛️ **Advanced Review Features**

#### **Batch Review Operations**
```bash
# Review all pending items for a milestone
/milestone/review milestone-001 --batch-mode

# Approve multiple phases at once
/milestone/review milestone-001 --approve-all --phases "design,spec"

# Mass feedback across multiple tasks
/milestone/review milestone-001 --feedback-all "Please add security considerations"
```

#### **Review Analytics**
```bash
# Review cycle time analysis
/milestone/review --analytics

# Approval bottleneck identification
/milestone/review --bottlenecks

# Review quality metrics
/milestone/review --quality-metrics
```

### 📋 **Review Best Practices**

#### **For Reviewers:**
1. **Timely Reviews** - Review within 24 hours of request
2. **Constructive Feedback** - Provide specific, actionable feedback
3. **Clear Decisions** - Use approve/reject decisively, avoid perpetual "changes requested"
4. **Documentation** - Leave clear comments explaining decisions

#### **For Task Authors:**
1. **Quality Deliverables** - Ensure deliverables are complete before requesting review
2. **Address Feedback** - Respond to feedback promptly and thoroughly  
3. **Update Notification** - Notify reviewers when deliverables are updated
4. **Version Control** - Maintain clear revision history

### 🔄 **Integration with Milestone Execution**

The review system seamlessly integrates with milestone execution:

```bash
# Normal execution with review gates
/milestone/execute milestone-001

# This will:
# 1. Execute kiro workflow phases
# 2. Pause at approval gates
# 3. Notify required reviewers
# 4. Wait for approvals before proceeding
# 5. Continue execution after approval
# 6. Handle rejection/feedback loops automatically
```

### 🎯 **Example Complete Review Workflow**

```bash
# 1. Developer creates milestone with kiro workflow
/milestone/plan "User authentication system" --enable-kiro

# 2. Developer starts execution
/milestone/execute milestone-001
# → Creates design deliverables
# → Pauses at design approval gate
# → Notifies architect and tech_lead

# 3. Architect reviews design
/milestone/review milestone-001 task-001 --phase design
# → Views architecture diagram and API spec
# → Chooses to approve: "a"
# → Provides comment: "Architecture looks good"

# 4. Tech Lead reviews design  
/milestone/review milestone-001 task-001 --phase design
# → Views same deliverables
# → Requests changes: "c"
# → Provides feedback: "Add rate limiting to API design"

# 5. Developer addresses feedback
# → Updates API specification with rate limiting
# → Deliverables automatically marked for re-review

# 6. Tech Lead reviews updated design
/milestone/review milestone-001 task-001 --phase design
# → Views updated deliverables
# → Approves: "a"
# → Design phase now fully approved

# 7. System automatically progresses to spec phase
# → Milestone execution continues
# → Spec deliverables are created
# → Spec approval gate activated
```

This comprehensive review system ensures that kiro workflow deliverables are properly validated before phase progression while maintaining a smooth user experience.