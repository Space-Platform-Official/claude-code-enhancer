# Milestone Review Command Reference

**Command**: `/milestone/review`  
**Category**: Milestone Management  
**Description**: Comprehensive kiro workflow review and approval system for milestone task deliverables with quality gates and stakeholder coordination

## Overview

The `/milestone/review` command provides sophisticated review and approval capabilities for kiro workflow deliverables within milestone tasks. This command manages the complete review lifecycle from deliverable submission through stakeholder approval with advanced workflow coordination and quality assurance.

## Usage Patterns

```bash
# Review all pending deliverables
/milestone/review

# Review specific milestone
/milestone/review MILESTONE_ID

# Review specific task deliverables
/milestone/review MILESTONE_ID TASK_ID

# Review specific phase deliverables
/milestone/review MILESTONE_ID TASK_ID --phase design

# Check pending reviews
/milestone/review --pending

# Approve specific phase
/milestone/review MILESTONE_ID TASK_ID --phase design --approve

# Reject with feedback
/milestone/review MILESTONE_ID TASK_ID --phase design --reject --feedback "Security concerns need addressing"
```

## Command Syntax

```bash
/milestone/review [milestone-id] [task-id] [options]
```

### Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `milestone-id` | Milestone identifier (optional for global review) | No |
| `task-id` | Task identifier (optional for milestone-wide review) | No |

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--phase=<name>` | Specific kiro workflow phase (design/spec/task/execute) | all |
| `--pending` | Show only pending review items | false |
| `--approve` | Approve the specified deliverables | false |
| `--reject` | Reject the specified deliverables | false |
| `--request-changes` | Request changes without rejection | false |
| `--feedback=<text>` | Provide review feedback or comments | none |
| `--comment=<text>` | Add approval comments | none |
| `--batch-mode` | Review multiple items in sequence | false |
| `--my-pending` | Show reviews assigned to current user | false |
| `--notifications=<on/off>` | Enable review notifications | on |

## Kiro Workflow Review Process

The review command manages the complete kiro workflow approval cycle:

### Kiro Workflow Phases

```bash
# Four-phase kiro workflow with review gates
Kiro Workflow: design → spec → task → execute

Phase Review Gates:
├── Design Phase Review: Architecture and API specifications
├── Spec Phase Review: Detailed implementation specifications
├── Task Phase Review: Task breakdown and acceptance criteria
└── Execute Phase Review: Implementation validation and testing

Review Requirements:
├── Each phase produces specific deliverables
├── Deliverables require stakeholder approval
├── Approval gates block phase progression
└── Feedback loops enable iterative improvement
```

### Review Workflow Coordination

```bash
# Multi-stakeholder review coordination
Review Process:
1. Task produces deliverables for current phase
2. System identifies required approvers
3. Review requests sent to stakeholders
4. Interactive review interface for validation
5. Approval/rejection/change requests processed
6. Phase progression unlocked upon approval
7. Feedback integration for continuous improvement
```

## Review Interface and Dashboard

### Pending Reviews Dashboard

```bash
PENDING KIRO WORKFLOW REVIEWS
==============================

📋 milestone-001: User Authentication System
└── task-001: Implement authentication API
    ├── 🎨 design phase: PENDING APPROVAL
    │   ├── architecture_diagram → .milestones/deliverables/task-001/design/auth-architecture.md
    │   ├── api_specification → .milestones/deliverables/task-001/design/api-spec.yaml
    │   ├── security_requirements → .milestones/deliverables/task-001/design/security-spec.md
    │   └── Approvers needed: architect, tech_lead, security_reviewer
    │   └── Status: 1 of 3 approvals received (architect ✅)
    └── ⏳ spec phase: BLOCKED (waiting for design approval)

📋 milestone-002: Database Integration
└── task-003: Database schema design
    ├── 📝 spec phase: PENDING APPROVAL
    │   ├── database_schema → .milestones/deliverables/task-003/spec/schema-design.sql
    │   ├── migration_scripts → .milestones/deliverables/task-003/spec/migrations/
    │   └── Approvers needed: database_admin, backend_lead
    │   └── Status: 0 of 2 approvals received
    └── ⏳ task phase: BLOCKED (waiting for spec approval)

REVIEW SUMMARY:
├── Total pending reviews: 2 milestones, 2 tasks
├── Design phase reviews: 1 (partial approval)
├── Spec phase reviews: 1 (no approvals)
├── Average review time: 1.5 days
└── Overdue reviews: None
```

### Interactive Review Interface

```bash
=== KIRO WORKFLOW REVIEW: DESIGN PHASE ===
Task: Implement authentication API (task-001)
Phase: design → spec
Status: ⏳ PENDING APPROVAL (1 of 3 approvers)

📄 DELIVERABLES FOR REVIEW:
==========================================

1. Architecture Diagram (auth-architecture.md)
   Path: .milestones/deliverables/task-001/design/auth-architecture.md
   Size: 2.1 KB | Last modified: 2024-07-20 14:30
   
   # Authentication System Architecture
   
   ## Overview
   The authentication system will use JWT tokens with refresh token rotation
   for secure, stateless authentication. The system will support multiple
   authentication providers and implement OAuth 2.0 + OIDC standards.
   
   ## Components
   - Auth Service: Handles login/logout/token refresh operations
   - User Service: Manages user profiles and authorization permissions
   - Security Middleware: Validates tokens on protected routes
   - Token Store: Redis-based session and refresh token management
   
   ## Security Features
   - JWT token rotation every 15 minutes
   - Refresh token family invalidation on compromise
   - Rate limiting on authentication endpoints
   - Multi-factor authentication support
   
   ## API Endpoints
   - POST /auth/login (email/password + MFA)
   - POST /auth/logout (token invalidation)
   - POST /auth/refresh (token rotation)
   - GET /auth/me (user profile with permissions)
   - POST /auth/mfa/setup (MFA configuration)

2. API Specification (api-spec.yaml)
   Path: .milestones/deliverables/task-001/design/api-spec.yaml
   Size: 4.7 KB | Last modified: 2024-07-20 14:45
   
   openapi: 3.0.0
   info:
     title: Authentication API
     version: 1.0.0
     description: Secure authentication and authorization API
   
   paths:
     /auth/login:
       post:
         summary: User authentication with optional MFA
         security: []
         requestBody:
           required: true
           content:
             application/json:
               schema:
                 type: object
                 required: [email, password]
                 properties:
                   email:
                     type: string
                     format: email
                   password:
                     type: string
                     minLength: 8
                   mfa_code:
                     type: string
                     pattern: '^[0-9]{6}$'
         responses:
           200:
             description: Authentication successful
             content:
               application/json:
                 schema:
                   type: object
                   properties:
                     access_token:
                       type: string
                     refresh_token:
                       type: string
                     expires_in:
                       type: integer
                     user:
                       $ref: '#/components/schemas/User'

3. Security Requirements (security-spec.md)
   Path: .milestones/deliverables/task-001/design/security-spec.md
   Size: 1.8 KB | Last modified: 2024-07-20 15:00
   
   # Security Requirements Specification
   
   ## Authentication Security
   - Passwords must meet complexity requirements (8+ chars, mixed case, numbers)
   - Account lockout after 5 failed attempts (15-minute lockout period)
   - Password history enforcement (cannot reuse last 10 passwords)
   - Secure password reset with time-limited tokens
   
   ## Token Security
   - JWT tokens signed with RS256 algorithm
   - Access tokens expire after 15 minutes
   - Refresh tokens expire after 7 days
   - Token binding to client IP and user agent
   
   ## Session Management
   - Concurrent session limit (3 active sessions per user)
   - Session timeout after 30 minutes of inactivity
   - Secure session invalidation on logout
   - Cross-device session management

🔍 APPROVAL REQUIREMENTS:
========================
Required approvers: architect, tech_lead, security_reviewer
Current approvals: 
├── ✅ architect (approved 2024-07-20 16:15)
│   └── Comment: "Architecture is solid, good security considerations"
├── ⏳ tech_lead (pending)
└── ⏳ security_reviewer (pending)

Approval status: 1 of 3 required approvals
Next phase unlock: Requires all 3 approvals

💬 REVIEW HISTORY:
==================
2024-07-20 16:15 - architect approved
  ✅ "Architecture is solid, good security considerations. 
      OAuth 2.0 implementation follows best practices."

2024-07-20 14:30 - deliverables submitted for review
  📝 Initial submission by development team

🎯 REVIEW OPTIONS:
=================
a) Approve this phase         (add your approval to allow progression)
r) Reject this phase          (block progression, require rework)
c) Request changes            (feedback for improvement, stay in phase)
f) Add feedback only          (comments without approval decision)
v) View deliverables again    (re-display content for detailed review)
d) Download deliverables      (save files for offline review)
h) View review history        (see all previous feedback and decisions)
q) Quit review

Your choice: _
```

## Review Actions and Workflow

### Approval Actions

```bash
# Approval with positive feedback
Choice: a (Approve)
Comment: "Excellent architecture design. Security considerations are comprehensive and well-documented."

Result:
✅ APPROVED: Design phase approved by tech_lead
├── Approval timestamp: 2024-07-20 16:45:00Z
├── Comment recorded: "Excellent architecture design..."
├── Approval status: 2 of 3 required approvals
└── Next: Waiting for security_reviewer approval

# Rejection with specific feedback
Choice: r (Reject)
Feedback: "Authentication flow lacks consideration for passwordless authentication. Please add support for WebAuthn/FIDO2."

Result:
❌ REJECTED: Design phase rejected by security_reviewer
├── Rejection timestamp: 2024-07-20 17:00:00Z
├── Feedback recorded: "Authentication flow lacks consideration..."
├── Status: Review process reset, rework required
└── Action required: Development team must address feedback and resubmit
```

### Change Request Workflow

```bash
# Request changes without full rejection
Choice: c (Request Changes)
Feedback: "Please add rate limiting specifications to the API design and include session management details in the architecture."

Result:
🔄 CHANGES REQUESTED: Design phase needs revision
├── Request timestamp: 2024-07-20 16:30:00Z
├── Feedback provided: "Please add rate limiting specifications..."
├── Status: Iterative improvement cycle initiated
├── Action required: Development team updates deliverables
└── Re-review: Automatic re-review notification sent

# Development team addresses feedback
Updated deliverables:
├── api-spec.yaml: Added rate limiting headers and documentation
├── auth-architecture.md: Expanded session management section
├── security-spec.md: Added rate limiting policy details
└── Notification sent: "Deliverables updated, ready for re-review"
```

## Review Status Tracking

### Individual Phase Review Status

```yaml
design_phase_review:
  status: "in_review"           # pending, in_review, approved, rejected, changes_requested
  deliverables:
    - name: "architecture_diagram"
      path: ".milestones/deliverables/task-001/design/auth-architecture.md"
      checksum: "a1b2c3d4e5f6"
      last_modified: "2024-07-20T14:30:00Z"
    - name: "api_specification"
      path: ".milestones/deliverables/task-001/design/api-spec.yaml"
      checksum: "f6e5d4c3b2a1"
      last_modified: "2024-07-20T14:45:00Z"
      
  review_requirements:
    approvers_required: ["architect", "tech_lead", "security_reviewer"]
    minimum_approvals: 3
    approval_threshold: "unanimous"
    
  review_history:
    - reviewer: "architect"
      action: "approved"
      timestamp: "2024-07-20T16:15:00Z"
      comment: "Architecture is solid, good security considerations"
    - reviewer: "tech_lead"
      action: "approved"
      timestamp: "2024-07-20T16:45:00Z"
      comment: "Excellent architecture design. Security considerations comprehensive"
    - reviewer: "security_reviewer"
      action: "request_changes"
      timestamp: "2024-07-20T16:30:00Z"
      feedback: "Please add rate limiting specifications to API design"
      
  current_status:
    approvals_received: ["architect", "tech_lead"]
    changes_requested_by: ["security_reviewer"]
    approval_percentage: 67
    overall_status: "changes_requested"
```

### Cross-Phase Dependency Tracking

```yaml
# Phase progression blocked by approval gates
kiro_workflow_status:
  design:
    status: "changes_requested"     # 🔄 Iterative improvement
    blocking_next_phase: true
    approval_gate: "partial"
    
  spec:
    status: "blocked"               # 🚫 Cannot start until design approved
    blocked_reason: "waiting_for_design_approval"
    dependency_status: "unsatisfied"
    
  task:
    status: "blocked"               # 🚫 Cannot start until spec approved
    blocked_reason: "waiting_for_spec_approval"
    dependency_chain: ["design", "spec"]
    
  execute:
    status: "blocked"               # 🚫 Cannot start until task approved
    blocked_reason: "waiting_for_task_approval"
    dependency_chain: ["design", "spec", "task"]
```

## Review Analytics and Metrics

### Review Performance Dashboard

```bash
REVIEW PERFORMANCE ANALYTICS
============================

📊 REVIEW CYCLE METRICS:
├── Average review time: 1.8 days
├── Approval rate: 87% (first submission)
├── Change request rate: 25%
├── Rejection rate: 3%
└── Re-review cycle time: 0.8 days

🎯 REVIEWER PERFORMANCE:
├── architect: 0.5 days avg, 95% approval rate
├── tech_lead: 1.2 days avg, 90% approval rate
├── security_reviewer: 2.1 days avg, 75% approval rate
├── database_admin: 0.8 days avg, 88% approval rate
└── Overall response time: Within SLA (2 days)

📈 TREND ANALYSIS (Last 30 days):
├── Review volume: 45 reviews completed
├── Quality improvement: 15% fewer change requests
├── Response time: 20% faster than previous month
├── Stakeholder satisfaction: 4.2/5.0 rating
└── Process efficiency: 92% within target timeframes

🔄 FEEDBACK QUALITY METRICS:
├── Actionable feedback: 94% (specific and implementable)
├── Feedback implementation rate: 98%
├── Review conflict resolution: 2 escalations (resolved)
└── Process improvement suggestions: 8 implemented
```

### Bottleneck Analysis

```bash
REVIEW BOTTLENECK IDENTIFICATION
================================

🚫 CURRENT BOTTLENECKS:
├── security_reviewer availability (2.1 day avg response)
│   ├── Impact: 35% of reviews delayed
│   ├── Recommendation: Cross-train additional security reviewers
│   └── Mitigation: Parallel review for non-security components
│
├── Complex design reviews (3.2 day avg for complex items)
│   ├── Impact: 20% of milestone delays
│   ├── Recommendation: Early design consultation sessions
│   └── Mitigation: Pre-review design validation workshops

⚡ OPTIMIZATION OPPORTUNITIES:
├── Parallel review workflows for independent components
├── Template-based deliverable validation
├── Automated security scanning integration
├── Real-time collaboration tools for review sessions
└── Stakeholder notification optimization

📊 RESOURCE ALLOCATION INSIGHTS:
├── Peak review periods: Sprint boundaries (weeks 2, 4)
├── Review capacity planning: Need 2x capacity during peaks
├── Reviewer workload balancing: Distribute across team members
└── Cross-training priority: Security and architecture review skills
```

## Batch Review Operations

### Multi-Item Review Processing

```bash
# Batch review for milestone efficiency
/milestone/review milestone-001 --batch-mode

Batch Review Session: milestone-001
===================================

Items for review: 3 tasks, 4 phases
Total deliverables: 12 files

REVIEW QUEUE:
├── 1. task-001 design phase (3 deliverables) → Priority: High
├── 2. task-002 spec phase (2 deliverables) → Priority: Medium  
├── 3. task-003 design phase (4 deliverables) → Priority: High
└── 4. task-001 spec phase (3 deliverables) → Priority: Low

Batch processing options:
a) Review all items sequentially
s) Skip to specific item
p) Process by priority order
f) Filter by deliverable type
q) Quit batch mode

Choice: p (Process by priority)

Processing high priority items first...
```

### Approval Workflow Automation

```bash
# Automated approval for standard cases
Approval Rule Engine:
├── Auto-approve: Documentation updates (low risk)
├── Fast-track: Template-based deliverables (expedited review)
├── Escalation: Security-critical changes (additional reviewers)
├── Parallel: Independent component reviews (concurrent processing)
└── Priority: Critical path items (immediate attention)

Review Efficiency Features:
├── Template validation: Automatic format and completeness checking
├── Incremental review: Review only changed sections
├── Collaborative annotation: Real-time comment and suggestion system
├── Decision trees: Guided review processes for complex items
└── Integration hooks: Automated testing and validation integration
```

## Quality Assurance and Compliance

### Review Quality Standards

```yaml
quality_standards:
  deliverable_completeness:
    required_sections: ["overview", "implementation", "testing", "documentation"]
    format_validation: "automated_check"
    content_depth: "detailed_specification_required"
    
  approval_criteria:
    technical_accuracy: "verified_by_domain_expert"
    security_compliance: "security_team_validation"
    architectural_alignment: "architecture_team_approval"
    business_value: "stakeholder_confirmation"
    
  feedback_quality:
    specificity: "actionable_recommendations_required"
    timeliness: "48_hour_response_target"
    constructiveness: "improvement_focused_tone"
    completeness: "all_concerns_addressed"
```

### Compliance and Audit Trail

```bash
REVIEW AUDIT TRAIL
==================

📋 COMPLIANCE TRACKING:
├── SOX compliance: All financial system reviews audited
├── Security compliance: OWASP guidelines enforced
├── Quality standards: ISO 9001 review processes
└── Regulatory compliance: Industry-specific requirements

🔍 AUDIT TRAIL FEATURES:
├── Complete review history with timestamps
├── Reviewer identity verification and digital signatures
├── Deliverable version control and change tracking
├── Decision rationale documentation
├── Escalation and override tracking
└── Compliance checklist completion verification

📊 AUDIT REPORTING:
├── Monthly compliance reports
├── Reviewer certification tracking
├── Process adherence metrics
├── Quality standard compliance rates
└── Continuous improvement recommendations
```

## Integration with Milestone Execution

### Review-Driven Execution Flow

```bash
# Seamless integration with milestone execution
Execution Integration:
├── Automatic review gate activation during kiro workflow
├── Execution pause at approval gates
├── Stakeholder notification and coordination
├── Review feedback integration into development cycle
├── Quality gate validation before phase progression
└── Continuous improvement loop integration

Review-Informed Execution:
├── Resource allocation based on review feedback
├── Timeline adjustment for review cycles
├── Quality improvement implementation
├── Risk mitigation based on review insights
└── Process optimization from review analytics
```

## Related Commands

- **[/milestone/plan](plan.md)** - Strategic milestone planning with review gate definition
- **[/milestone/execute](execute.md)** - Execute milestones with integrated review processes
- **[/milestone/status](status.md)** - Monitor review status and approval progress
- **[/milestone/update](update.md)** - Update milestone scope including review requirements

## Best Practices

### Review Excellence

1. **Timely Reviews**: Complete reviews within 48-hour target window
2. **Constructive Feedback**: Provide specific, actionable improvement suggestions
3. **Quality Focus**: Ensure deliverables meet defined standards before approval
4. **Stakeholder Coordination**: Maintain clear communication throughout review cycle
5. **Continuous Improvement**: Learn from review patterns to improve processes

### Reviewer Best Practices

1. **Preparation**: Review context and requirements before starting
2. **Thoroughness**: Check completeness, accuracy, and compliance
3. **Clarity**: Provide clear, specific feedback with examples
4. **Timeliness**: Respond within established timeframes
5. **Collaboration**: Engage in constructive dialogue with development teams

### Process Optimization

1. **Review Planning**: Include review time in milestone planning
2. **Stakeholder Availability**: Ensure reviewer availability aligns with schedules
3. **Parallel Processing**: Optimize review workflows for efficiency
4. **Quality Gates**: Implement appropriate approval thresholds
5. **Feedback Integration**: Establish clear processes for addressing review feedback

---

*The `/milestone/review` command provides comprehensive kiro workflow review and approval capabilities with advanced stakeholder coordination, quality assurance, and process optimization for reliable milestone delivery.*