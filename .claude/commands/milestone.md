---
allowed-tools: all
description: Comprehensive milestone planning with hybrid tracking, progress management, and resume functionality
---

# 🔍🔍🔍 CRITICAL REQUIREMENT: MILESTONE PLANNING AND TRACKING! 🔍🔍🔍

**THIS IS NOT A SIMPLE TODO TASK - THIS IS A COMPREHENSIVE MILESTONE MANAGEMENT SYSTEM!**

When you run `/milestone`, you are REQUIRED to:

1. **ANALYZE** project scope and decompose into trackable milestones with precise timeline estimates
2. **CREATE** hybrid file-based + event log tracking system for persistent state management
3. **IMPLEMENT** progress tracking with resume functionality across sessions
4. **ESTABLISH** dependency mapping and risk assessment for each milestone
5. **USE MULTIPLE AGENTS** for complex milestone decomposition:
   - Spawn one agent for timeline analysis and estimation
   - Spawn another for dependency mapping and risk assessment
   - Spawn more agents for different project domains/modules
   - Say: "I'll spawn multiple agents to analyze this milestone from different perspectives"

## 🎯 USE MULTIPLE AGENTS

**MANDATORY AGENT SPAWNING FOR MILESTONE COMPLEXITY:**
```
"I'll spawn multiple agents to handle milestone planning comprehensively:
- Planning Agent: Break down complex goals into trackable milestones
- Timeline Agent: Estimate realistic durations and dependencies
- Risk Agent: Identify potential blockers and mitigation strategies
- Progress Agent: Design tracking and resume mechanisms
- Integration Agent: Map cross-milestone dependencies and coordination"
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ Create simple linear todo lists → NO! Complex milestone hierarchies required!
- ❌ "This can be one big milestone" → NO! Decompose into manageable chunks!
- ❌ Skip dependency analysis → NO! Map all interconnections!
- ❌ Ignore timeline estimation → NO! Realistic scheduling required!
- ❌ Use only memory-based tracking → NO! Persistent state required!
- ❌ "We'll figure it out as we go" → NO! Comprehensive planning first!

**MANDATORY WORKFLOW:**
```
1. Scope analysis → Understand full project complexity
2. IMMEDIATELY spawn agents for parallel milestone decomposition
3. Create hybrid tracking system → File + event log persistence
4. Map dependencies and risks → Comprehensive interconnection analysis
5. Implement progress tracking → Resume functionality across sessions
6. VERIFY milestone completeness and tracking accuracy
```

**YOU ARE NOT DONE UNTIL:**
- ✅ ALL project scope decomposed into trackable milestones
- ✅ Hybrid tracking system implemented with persistence
- ✅ Resume functionality verified across sessions
- ✅ Dependency mapping completed with risk assessment
- ✅ Progress tracking validated with event logging
- ✅ Milestone completion criteria clearly defined

---

🛑 **MANDATORY MILESTONE PLANNING CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current project status and existing milestones
3. Verify you understand the full scope requiring milestone planning

Execute comprehensive milestone planning with ZERO tolerance for oversimplification.

**FORBIDDEN SHORTCUT PATTERNS:**
- "Let's just create a few high-level goals" → NO, detailed decomposition required
- "Simple tracking is enough" → NO, hybrid system with resume capability needed
- "We don't need dependencies" → NO, map all interconnections
- "Timeline estimation can wait" → NO, realistic scheduling is critical
- "One milestone file is sufficient" → NO, event logging system required

You are planning milestones for: $ARGUMENTS

## 🚀 **QUICK-START ALTERNATIVE AVAILABLE**

**New to milestones? Looking for something simpler?** 

If this seems overwhelming, try our quick-start templates instead:
- `/milestone/quickstart personal "Your project"`
- `/milestone/quickstart team "Your team project"`
- `/milestone/quickstart api "Your API project"`
- `/milestone/quickstart frontend "Your UI project"`
- `/milestone/quickstart bugfix "Your bug description"`

**Quick-start benefits:** Ready in 2 minutes, focused templates, easy upgrade path.

**Continue with full system:** The comprehensive planning below is powerful but complex.

---

Let me ultrathink about the comprehensive milestone architecture and tracking system.

🚨 **REMEMBER: Good milestones are SMART (Specific, Measurable, Achievable, Relevant, Time-bound)!** 🚨

**Comprehensive Milestone Planning Protocol:**

**Step 0: Project Scope Analysis**
- Understand the complete project requirements and constraints
- Identify major deliverables and success criteria
- Map stakeholders and their expectations
- Assess available resources and timeline constraints
- Review existing project structure and dependencies

**Step 1: Milestone Decomposition Strategy**
- Break complex goals into manageable milestones (2-4 week chunks)
- Define clear completion criteria for each milestone
- Identify deliverables and artifacts for each milestone
- Map skills and resources required for each milestone
- Ensure each milestone provides tangible value

**Step 2: Hybrid Tracking System Implementation**

**File-Based Persistence Structure:**
```
.milestones/
├── config/
│   ├── milestone-config.yaml    # Global settings and templates
│   └── progress-schema.json     # Data structure definitions
├── active/
│   ├── milestone-001.yaml       # Current milestone details
│   ├── milestone-002.yaml       # Next milestone planning
│   └── dependencies.yaml       # Cross-milestone relationships
├── completed/
│   ├── milestone-000.yaml       # Archived completed milestones
│   └── lessons-learned.md       # Post-completion analysis
└── logs/
    ├── progress-events.jsonl    # Event-driven progress logging
    ├── milestone-updates.jsonl  # State changes and modifications
    └── session-resume.json      # Resume points for interrupted work
```

**Event Log System:**
```typescript
interface MilestoneEvent {
  timestamp: string;
  event_type: 'milestone_created' | 'progress_updated' | 'dependency_added' | 'risk_identified' | 'milestone_completed';
  milestone_id: string;
  details: {
    progress_percentage?: number;
    tasks_completed?: string[];
    blockers_encountered?: string[];
    time_spent?: number;
    notes?: string;
  };
  session_id: string;
  user_context?: string;
}
```

**Step 3: Progress Tracking and Resume Functionality**

**Session Management:**
- Track work sessions with unique identifiers
- Log interruption points and context
- Enable seamless resume with full state restoration
- Maintain progress continuity across different work environments

**Progress Metrics:**
```yaml
milestone_progress:
  id: "milestone-001"
  title: "User Authentication System"
  status: "in_progress"
  progress_percentage: 67
  estimated_completion: "2024-07-20"
  actual_start_date: "2024-07-01"
  
  tasks:
    completed:
      - "Database schema design"
      - "JWT implementation"
      - "Login endpoint"
    in_progress:
      - "Password reset flow"
    pending:
      - "Email verification"
      - "OAuth integration"
      - "Security testing"
  
  metrics:
    time_estimated: "80 hours"
    time_spent: "54 hours"
    efficiency_ratio: 1.125
    blockers_count: 2
    
  last_session:
    session_id: "session-20240713-001"
    context: "Working on password reset email templates"
    next_steps: ["Complete email template", "Test reset flow", "Add rate limiting"]
```

**Step 4: Dependency Mapping and Risk Assessment**

**Dependency Analysis:**
```yaml
dependencies:
  milestone-001:
    depends_on: []
    enables: ["milestone-002", "milestone-005"]
    shared_resources: ["database", "email-service"]
    critical_path: true
    
  milestone-002:
    depends_on: ["milestone-001"]
    enables: ["milestone-003"]
    shared_resources: ["user-service"]
    critical_path: false
    
risk_matrix:
  high_risk:
    - id: "external-api-dependency"
      milestone: "milestone-003"
      description: "Third-party payment API may change"
      probability: 0.3
      impact: "high"
      mitigation: "Implement adapter pattern with fallback options"
      
  medium_risk:
    - id: "team-capacity"
      milestone: "milestone-002"
      description: "Key developer may be unavailable"
      probability: 0.2
      impact: "medium"
      mitigation: "Cross-train team members, document key processes"
```

**Step 5: Multi-Agent Milestone Execution**

**Agent Spawning Strategy for Large Projects:**
```
"I'll spawn specialized agents to handle different aspects of milestone planning:

1. **Decomposition Agent**: 'Analyze the project scope and break it into logical milestones'
2. **Timeline Agent**: 'Estimate realistic durations based on complexity and dependencies'
3. **Risk Agent**: 'Identify potential blockers and create mitigation strategies'
4. **Tracking Agent**: 'Design the hybrid file+event system for progress management'
5. **Integration Agent**: 'Map dependencies and coordinate cross-milestone requirements'

Each agent will report back with detailed analysis for comprehensive milestone planning."
```

**Step 6: Milestone Templates and Standards**

**Milestone Definition Template:**
```yaml
id: "milestone-XXX"
title: "Descriptive Milestone Name"
description: "Clear description of what this milestone accomplishes"
priority: "high|medium|low"
category: "feature|infrastructure|testing|documentation"

timeline:
  estimated_start: "YYYY-MM-DD"
  estimated_end: "YYYY-MM-DD"
  estimated_hours: 0
  buffer_percentage: 20

success_criteria:
  - "Specific measurable outcome 1"
  - "Specific measurable outcome 2"
  - "Specific measurable outcome 3"

deliverables:
  - name: "Deliverable 1"
    type: "code|documentation|test|deployment"
    acceptance_criteria: ["Criteria 1", "Criteria 2"]

dependencies:
  requires: ["milestone-001", "milestone-003"]
  enables: ["milestone-005"]
  external: ["third-party-approval", "design-assets"]

resources:
  team_members: ["developer-1", "designer-1"]
  skills_required: ["react", "database-design", "testing"]
  tools_needed: ["figma", "database-client"]

risks:
  - description: "Risk description"
    probability: 0.2
    impact: "high|medium|low"
    mitigation: "Mitigation strategy"

tasks:
  - id: "task-001"
    title: "Task description"
    estimated_hours: 8
    status: "pending|in_progress|completed"
    assigned_to: "team-member"
    dependencies: ["task-002"]
```

**Step 7: Resume and Session Management**

**Session Resume Protocol:**
```typescript
interface ResumePoint {
  session_id: string;
  timestamp: string;
  active_milestone: string;
  current_task: string;
  context: {
    working_directory: string;
    open_files: string[];
    current_branch: string;
    uncommitted_changes: boolean;
    notes: string;
    next_steps: string[];
  };
  progress_snapshot: {
    completed_tasks: string[];
    in_progress_tasks: string[];
    time_spent_today: number;
    blockers: string[];
  };
}
```

**Resume Functionality:**
- Automatic context capture on session interruption
- Smart resumption with full context restoration
- Progress continuity across different work environments
- Intelligent next-step suggestions based on session history

**Step 8: Progress Visualization and Reporting**

**Progress Dashboard (Text-based):**
```
MILESTONE PROGRESS DASHBOARD
============================

Overall Project: 34% Complete (5 of 15 milestones completed)
Current Sprint: Milestone-006 "API Integration" (78% complete)

ACTIVE MILESTONES:
├── Milestone-006: API Integration        [████████░] 78% (Due: 2024-07-20)
├── Milestone-007: UI Components          [██░░░░░░░] 23% (Due: 2024-07-25)
└── Milestone-008: Testing Framework      [░░░░░░░░░]  0% (Due: 2024-08-01)

CRITICAL PATH STATUS:
✅ Authentication (M-001) → ✅ Database (M-002) → 🟡 API (M-006) → ⏳ Integration (M-009)

RISK ALERTS:
🔴 HIGH: External API changes may impact M-006 (Mitigation: Adapter pattern)
🟡 MED:  Team capacity constraints for M-007 (Mitigation: Resource reallocation)

RECENT ACTIVITY:
- 2024-07-13 14:30: Completed OAuth implementation (M-006)
- 2024-07-13 12:15: Started rate limiting implementation (M-006)
- 2024-07-13 10:00: Resolved API versioning blocker (M-006)
```

**Milestone Quality Checklist:**
- [ ] Each milestone is 2-4 weeks in duration
- [ ] Clear, measurable success criteria defined
- [ ] Dependencies mapped and validated
- [ ] Risk assessment completed with mitigation strategies
- [ ] Resource requirements identified and confirmed
- [ ] Tasks broken down to 1-2 day granularity
- [ ] Integration points with other milestones documented
- [ ] Rollback plan exists for critical milestones

**Agent Coordination for Complex Projects:**
```
"For large-scale milestone planning, I'll coordinate multiple agents:

Primary Planning Agent: Overall milestone architecture and coordination
├── Domain Agent 1: Frontend milestone decomposition
├── Domain Agent 2: Backend milestone decomposition  
├── Domain Agent 3: Infrastructure milestone planning
├── Integration Agent: Cross-domain milestone coordination
└── Quality Agent: Milestone validation and optimization

Each agent will work in parallel while maintaining consistency through shared state management."
```

**Anti-Patterns to Avoid:**
- ❌ Creating milestones longer than 4 weeks (too complex to track)
- ❌ Milestones without clear completion criteria (unmeasurable)
- ❌ Ignoring dependencies between milestones (creates bottlenecks)
- ❌ No buffer time for unexpected challenges (unrealistic planning)
- ❌ Milestones that don't deliver standalone value (poor decomposition)
- ❌ Tracking only in memory without persistence (lost context)

**Final Verification:**
Before completing milestone planning:
- Have I decomposed the project into manageable milestones?
- Are dependencies clearly mapped and realistic?
- Is the tracking system persistent and resumable?
- Are risk assessments comprehensive with mitigation plans?
- Can progress be measured and visualized effectively?
- Are completion criteria specific and measurable?

**Final Commitment:**
- **I will**: Create comprehensive milestone decomposition with hybrid tracking
- **I will**: Implement persistent state management with resume functionality
- **I will**: Map all dependencies and assess risks thoroughly
- **I will**: Use multiple agents for complex milestone analysis
- **I will NOT**: Create oversimplified linear task lists
- **I will NOT**: Skip dependency mapping or risk assessment
- **I will NOT**: Implement tracking without persistence capabilities

**REMEMBER:**
This is MILESTONE PLANNING mode - comprehensive decomposition, persistent tracking, and resume-capable progress management. The goal is to create a robust system that survives interruptions and provides clear visibility into complex project progress.

Executing comprehensive milestone planning protocol for detailed project management...