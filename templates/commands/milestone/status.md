---
allowed-tools: all
description: Comprehensive milestone status checking with visual progress tracking and project health assessment
---

# 🔍🔍🔍 CRITICAL REQUIREMENT: MILESTONE STATUS ASSESSMENT AND VISUALIZATION! 🔍🔍🔍

**THIS IS NOT A MILESTONE PLANNING TASK - THIS IS A COMPREHENSIVE STATUS ANALYSIS AND VISUALIZATION SYSTEM!**

When you run `/milestone/status`, you are REQUIRED to:

1. **DISCOVER** all existing milestone files and analyze their current completion status
2. **ANALYZE** milestone progress data and calculate accurate completion percentages
3. **VISUALIZE** milestone status through interactive text-based dashboards and progress charts
4. **ASSESS** project health with risk indicators and critical path analysis
5. **USE MULTIPLE AGENTS** for comprehensive status analysis:
   - Spawn one agent to discover and inventory all milestone files
   - Spawn another to parse milestone data and calculate progress metrics
   - Spawn more agents for visualization generation and health assessment
   - Say: "I'll spawn multiple agents to analyze milestone status from different perspectives"

**FORBIDDEN BEHAVIORS:**
- ❌ "Modify milestone files during analysis" → NO! Read-only status checking required!
- ❌ "Skip visualization when data exists" → NO! Visual dashboards are mandatory!
- ❌ "Ignore dependency relationships" → NO! Map milestone interconnections!
- ❌ "Simple text output is sufficient" → NO! Rich progress visualization required!
- ❌ "Create new milestones during status check" → NO! Analysis only, no creation!

**MANDATORY WORKFLOW:**
```
1. Discovery phase → Scan .milestones/ directories and inventory all files
2. IMMEDIATELY spawn agents for parallel analysis and visualization
3. Data parsing → Extract progress, completion, and status information
4. Progress calculation → Determine accurate completion percentages
5. Visualization generation → Create interactive dashboards and charts
6. VERIFY status accuracy and provide actionable insights
```

**YOU ARE NOT DONE UNTIL:**
- ✅ All milestone files discovered and parsed successfully
- ✅ Progress calculations completed for all milestones with accurate percentages
- ✅ Visual dashboard generated showing current status and trends
- ✅ Critical path analysis provided with risk assessment
- ✅ Actionable insights and recommendations clearly presented
- ✅ Next steps and project health summary delivered

---

🛑 **MANDATORY MILESTONE STATUS CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current .milestones/ directory structure and file existence
3. Verify milestone tracking system is properly configured

Execute comprehensive milestone status analysis with ZERO tolerance for incomplete visualization.

**FORBIDDEN SHORTCUT PATTERNS:**
- "Basic progress percentages are enough" → NO, comprehensive dashboard required
- "Simple milestone listing is sufficient" → NO, rich visualization mandatory
- "Skip dependency analysis" → NO, critical path mapping required
- "Text-only output works fine" → NO, visual progress bars and charts needed
- "One-time snapshot is adequate" → NO, trend analysis and health assessment required

You are analyzing milestone status for: $ARGUMENTS

Let me ultrathink about comprehensive milestone status visualization and health assessment architecture.

🚨 **REMEMBER: Great status dashboards provide immediate insights and actionable intelligence!** 🚨

**Comprehensive Milestone Status Analysis Protocol:**

**Step 0: Milestone Discovery and Inventory**
- Scan `.milestones/` directory structure for all milestone files
- Inventory active, completed, and planned milestone files
- Check for milestone configuration files and tracking schemas
- Validate file formats and data integrity
- Identify any missing or corrupted milestone data

**Step 1: Multi-Agent Status Analysis Strategy**

**Agent Spawning Strategy for Comprehensive Analysis:**
```
"I'll spawn multiple agents to handle milestone status analysis comprehensively:
- Discovery Agent: Scan and inventory all milestone files and directory structure
- Parser Agent: Extract milestone data, progress metrics, and completion status
- Calculator Agent: Compute accurate progress percentages and timeline analysis
- Visualizer Agent: Generate interactive dashboards, charts, and progress bars
- Health Agent: Assess project health, risks, and critical path status
- Reporter Agent: Create actionable insights and recommendations"
```

**Step 2: Milestone Data Parsing and Extraction**

**Data Extraction Requirements:**
```yaml
milestone_data_extraction:
  basic_info:
    - milestone_id
    - title
    - description
    - priority
    - category
    - status
    
  progress_metrics:
    - progress_percentage
    - tasks_completed
    - tasks_in_progress
    - tasks_pending
    - time_spent
    - time_estimated
    
  timeline_data:
    - start_date
    - due_date
    - estimated_completion
    - actual_completion
    - timeline_variance
    
  dependency_analysis:
    - prerequisite_milestones
    - dependent_milestones
    - critical_path_status
    - shared_resources
    
  health_indicators:
    - blockers_count
    - risk_level
    - team_capacity
    - resource_constraints
```

**Step 3: Progress Calculation and Metrics**

**Progress Calculation Algorithm:**
```typescript
interface MilestoneProgress {
  milestone_id: string;
  completion_percentage: number;
  task_completion_ratio: number;
  time_efficiency: number;
  quality_score: number;
  risk_factor: number;
  
  breakdown: {
    completed_tasks: number;
    in_progress_tasks: number;
    pending_tasks: number;
    blocked_tasks: number;
    total_tasks: number;
  };
  
  timeline_status: {
    days_elapsed: number;
    days_remaining: number;
    schedule_variance: number;
    projected_completion: string;
  };
}
```

**Step 4: Visual Dashboard Generation**

**Interactive Status Dashboard Format:**
```
MILESTONE STATUS DASHBOARD
==========================

📊 OVERALL PROJECT HEALTH: 67% Complete | 🟢 ON TRACK

MILESTONE COMPLETION OVERVIEW:
┌─────────────────────────────────────────────────────────────────────────┐
│ PROJECT PROGRESS                                            67% │████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
└─────────────────────────────────────────────────────────────────────────┘

MILESTONE STATUS MATRIX:
┌─────┬────────────────────────────────────┬──────────────────────────┬────────────┬──────────┐
│ ID  │ MILESTONE                          │ PROGRESS                 │ STATUS     │ DUE DATE │
├─────┼────────────────────────────────────┼──────────────────────────┼────────────┼──────────┤
│ M01 │ User Authentication System         │ ████████████████████████ │ ✅ DONE    │ 07-15    │
│ M02 │ Database Schema & Migration        │ ████████████████████████ │ ✅ DONE    │ 07-18    │
│ M03 │ Core API Endpoints                 │ ████████████████████████ │ ✅ DONE    │ 07-22    │
│ M04 │ User Interface Components          │ ████████████████████████ │ ✅ DONE    │ 07-25    │
│ M05 │ Integration Testing Framework      │ ████████████████████░░░░ │ 🟡 ACTIVE  │ 07-28    │
│ M06 │ Performance Optimization           │ ████████░░░░░░░░░░░░░░░░ │ 🟡 ACTIVE  │ 08-02    │
│ M07 │ Deployment Pipeline                │ ░░░░░░░░░░░░░░░░░░░░░░░░ │ ⏳ PENDING │ 08-05    │
│ M08 │ Documentation & Training           │ ░░░░░░░░░░░░░░░░░░░░░░░░ │ ⏳ PENDING │ 08-08    │
└─────┴────────────────────────────────────┴──────────────────────────┴────────────┴──────────┘

CRITICAL PATH ANALYSIS:
🔥 CRITICAL PATH: M01 → M02 → M03 → M05 → M07 → M08
├── ✅ Authentication (M01) → Complete
├── ✅ Database (M02) → Complete  
├── ✅ API (M03) → Complete
├── 🟡 Testing (M05) → 78% complete, ON TRACK
├── ⚠️  Deployment (M07) → Blocked by M05, RISK: Infrastructure dependency
└── ⏳ Documentation (M08) → Waiting, RISK: Team capacity constraints

HEALTH INDICATORS:
┌─────────────────────────────────────────────────────────────────────────┐
│ 🟢 VELOCITY: 1.2 milestones/week (Above target)                        │
│ 🟡 TIMELINE: 2 days ahead of schedule (Buffer available)               │
│ 🔴 RISKS: 2 high-risk blockers identified (Mitigation required)        │
│ 🟢 QUALITY: 95% task completion rate (Excellent)                       │
│ 🟡 CAPACITY: 85% team utilization (Near maximum)                       │
└─────────────────────────────────────────────────────────────────────────┘

RISK ASSESSMENT:
🔴 HIGH RISK:
   • M07: Infrastructure team dependency may cause delays
   • M05: CI/CD pipeline complexity higher than estimated
   
🟡 MEDIUM RISK:
   • M06: Performance targets may require architecture changes
   • M08: Documentation scope creep from stakeholder requests

RECENT ACTIVITY:
• 2024-07-16 09:30: Completed API endpoint testing (M03)
• 2024-07-16 08:15: Started integration test suite (M05)
• 2024-07-15 16:45: Resolved authentication token issues (M01)

NEXT ACTIONS:
1. 🎯 IMMEDIATE: Complete integration testing framework (M05)
2. 🔧 THIS WEEK: Begin infrastructure setup for deployment (M07)
3. ⚠️  URGENT: Resolve CI/CD pipeline complexity in M05
4. 📋 PLANNING: Schedule infrastructure team coordination meeting
```

**Step 5: Trend Analysis and Health Assessment**

**Health Assessment Metrics:**
```yaml
project_health:
  overall_score: 8.2/10
  
  velocity_analysis:
    current_velocity: 1.2  # milestones per week
    target_velocity: 1.0
    trend: "increasing"
    efficiency_score: 0.95
    
  timeline_health:
    schedule_variance: "+2 days"
    critical_path_status: "on_track"
    buffer_remaining: "15%"
    projected_completion: "2024-08-06"
    
  risk_profile:
    high_risk_items: 2
    medium_risk_items: 2
    low_risk_items: 1
    overall_risk_score: 6.5/10
    
  quality_indicators:
    task_completion_rate: 0.95
    milestone_success_rate: 1.0
    defect_rate: 0.02
    rework_percentage: 0.08
```

**Step 6: Actionable Insights and Recommendations**

**Intelligence Generation:**
```
STRATEGIC INSIGHTS:
┌─────────────────────────────────────────────────────────────────────────┐
│ 🎯 FOCUS AREAS                                                         │
│ • Accelerate M05 testing to maintain critical path                     │
│ • Proactively address M07 infrastructure dependencies                  │
│ • Allocate additional resources to M06 performance optimization        │
│                                                                         │
│ 📈 POSITIVE TRENDS                                                     │
│ • Consistently ahead of schedule (2 days buffer)                       │
│ • High task completion rate (95%)                                      │
│ • Excellent milestone delivery track record                            │
│                                                                         │
│ ⚠️  ATTENTION REQUIRED                                                  │
│ • Infrastructure team coordination needed for M07                      │
│ • CI/CD complexity in M05 needs immediate attention                    │
│ • Team capacity nearing maximum (85% utilization)                      │
└─────────────────────────────────────────────────────────────────────────┘
```

**Step 7: Multi-Agent Coordination for Complex Projects**

**Agent Coordination Strategy:**
```
"For comprehensive milestone status analysis, I'll coordinate multiple specialized agents:

Status Analysis Agent: Primary coordinator for overall status assessment
├── File Discovery Agent: Scan .milestones/ structure and inventory files
├── Data Parser Agent: Extract milestone data and progress metrics
├── Progress Calculator Agent: Compute completion percentages and timelines
├── Visualization Agent: Generate dashboards, charts, and progress displays
├── Health Assessment Agent: Analyze risks, blockers, and project health
├── Trend Analysis Agent: Track velocity, efficiency, and projection trends
└── Intelligence Agent: Generate actionable insights and recommendations

Each agent will work in parallel while maintaining data consistency and comprehensive coverage."
```

**Step 8: Resume-Aware Status Tracking**

**Session Context for Status Checks:**
```typescript
interface StatusSession {
  session_id: string;
  timestamp: string;
  analysis_scope: string[];
  
  snapshot: {
    total_milestones: number;
    completed_milestones: number;
    active_milestones: number;
    pending_milestones: number;
    overall_progress: number;
  };
  
  trends: {
    velocity_trend: "increasing" | "stable" | "decreasing";
    timeline_trend: "ahead" | "on_track" | "behind";
    quality_trend: "improving" | "stable" | "declining";
  };
  
  recommendations: string[];
  risk_alerts: string[];
  next_checkpoints: string[];
}
```

**Milestone Status Quality Checklist:**
- [ ] All milestone files discovered and parsed successfully
- [ ] Progress calculations accurate with proper task weighting
- [ ] Visual dashboard renders correctly with all status indicators
- [ ] Critical path analysis identifies dependencies accurately
- [ ] Risk assessment covers all potential blockers
- [ ] Health indicators provide actionable intelligence
- [ ] Trend analysis shows meaningful patterns
- [ ] Recommendations are specific and actionable

**Anti-Patterns to Avoid:**
- ❌ Parsing milestone files without error handling (corrupted data breaks analysis)
- ❌ Static progress percentages without trend analysis (no predictive value)
- ❌ Text-only output without visual elements (poor user experience)
- ❌ Ignoring milestone dependencies (inaccurate critical path)
- ❌ Single-point-in-time analysis (no historical context)
- ❌ Generic recommendations without project context (not actionable)

**Final Verification:**
Before completing milestone status analysis:
- Have I discovered and parsed all milestone files?
- Are progress calculations accurate and comprehensive?
- Does the visual dashboard provide immediate insights?
- Is the critical path analysis complete and accurate?
- Are risk assessments thorough with mitigation strategies?
- Do recommendations provide actionable next steps?

**Final Commitment:**
- **I will**: Discover and analyze all milestone files comprehensively
- **I will**: Generate accurate progress calculations with visual dashboards
- **I will**: Provide critical path analysis with risk assessment
- **I will**: Use multiple agents for thorough status analysis
- **I will**: Create actionable insights and recommendations
- **I will NOT**: Modify milestone files during status analysis
- **I will NOT**: Skip visualization components or progress charts
- **I will NOT**: Ignore dependency relationships or critical path
- **I will NOT**: Provide generic insights without project context

**REMEMBER:**
This is MILESTONE STATUS ANALYSIS mode - comprehensive discovery, accurate progress calculation, rich visualization, and actionable intelligence. The goal is to provide immediate visibility into project health and enable informed decision-making.

Executing comprehensive milestone status analysis protocol for project visibility and health assessment...