---
allowed-tools: all
description: Real-time milestone status monitoring with dashboard generation, progress analytics, and cross-milestone reporting
---

# 📊📊📊 CRITICAL REQUIREMENT: MILESTONE STATUS AND MONITORING MODE ENGAGED 📊📊📊

**THIS IS NOT A PLANNING OR EXECUTION TASK - THIS IS COMPREHENSIVE STATUS MONITORING AND DASHBOARD GENERATION!**

When you run `/milestone/update`, you are REQUIRED to:

1. **MONITOR** - Generate real-time progress dashboards across all active milestones
2. **AGGREGATE** - Collect and synthesize status data from multiple milestone sources
3. **ANALYZE** - Calculate performance metrics, bottlenecks, and trend analysis
4. **SYNC** - Update session context and resolve state conflicts across milestones
5. **DETECT** - Identify cross-milestone dependencies and potential blockers
6. **REPORT** - Generate stakeholder-ready status reports with actionable insights
7. **RECOMMEND** - Provide data-driven recommendations for optimization

## 🎯 USE MULTIPLE AGENTS FOR COMPREHENSIVE STATUS ANALYSIS

**MANDATORY AGENT SPAWNING FOR STATUS MONITORING:**
```
"I'll spawn multiple monitoring agents to analyze milestone status comprehensively:
- Dashboard Generation Agent: Create real-time visual progress dashboards
- Metrics Analysis Agent: Calculate performance indicators and efficiency ratios
- Cross-Milestone Agent: Analyze dependencies and coordination across milestones
- Session Context Agent: Update context state and resolve synchronization conflicts
- Conflict Detection Agent: Identify blockers, risks, and resolution paths
- Reporting Agent: Generate stakeholder reports with actionable insights"
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ Generate static status without real-time data → NO! Live monitoring required!
- ❌ Report on single milestone in isolation → NO! Cross-milestone analysis essential!
- ❌ Skip performance metrics calculation → NO! Data-driven insights required!
- ❌ Ignore session context synchronization → NO! State consistency critical!
- ❌ Provide status without actionable recommendations → NO! Insights must be actionable!
- ❌ Skip conflict detection and resolution → NO! Proactive issue management required!

**MANDATORY STATUS WORKFLOW:**
```
1. Data collection → Gather status from all active milestone sources
2. IMMEDIATELY spawn monitoring agents for parallel status analysis
3. Generate dashboards → Create real-time visual progress representations
4. Calculate metrics → Performance indicators, efficiency, and trend analysis
5. Sync context → Update session state and resolve conflicts
6. Detect blockers → Identify cross-milestone dependencies and risks
7. VERIFY status accuracy and provide actionable recommendations
```

**YOU ARE NOT DONE UNTIL:**
- ✅ Real-time dashboards generated for all active milestones
- ✅ Performance metrics calculated with trend analysis
- ✅ Cross-milestone dependencies analyzed and visualized
- ✅ Session context synchronized and conflicts resolved
- ✅ Blockers identified with resolution recommendations
- ✅ Stakeholder reports generated with actionable insights

---

🛑 **MANDATORY STATUS MONITORING CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Load active milestone context from _shared/context.md and _shared/state.md
3. Verify you're implementing comprehensive monitoring, not basic status checks

Execute comprehensive milestone status monitoring with ZERO tolerance for superficial reporting.

**FORBIDDEN MINIMAL PATTERNS:**
- "Milestone X is 60% complete" → NO, comprehensive analytics required
- "Status looks good" → NO, data-driven insights with metrics needed
- "No blockers detected" → NO, proactive analysis across dependencies required
- "Simple progress update" → NO, dashboard generation and recommendations essential
- "Quick status check" → NO, comprehensive monitoring protocol required

You are monitoring milestones for: $ARGUMENTS

Let me ultrathink about comprehensive status monitoring architecture and analytics.

🚨 **REMEMBER: Status without insights is just data - provide actionable intelligence!** 🚨

**Comprehensive Milestone Status Monitoring Protocol:**

**Step 0: Status Data Collection and Validation**
- Aggregate status from .milestones/active/ and .milestones/logs/ directories
- Validate session context integrity and identify state conflicts
- Load cross-milestone dependency mappings and current state
- Verify data consistency across multiple milestone sources
- Map stakeholder reporting requirements and success criteria

**Step 1: Real-Time Dashboard Generation Strategy**

Generate comprehensive visual dashboards covering:
- **Overall Project Status**: Global progress across all milestones
- **Active Milestone Focus**: Detailed progress on current execution
- **Dependency Visualization**: Cross-milestone relationships and blockers
- **Performance Trends**: Historical analytics and efficiency tracking
- **Risk Assessment**: Potential issues and mitigation status

**Dashboard Components:**
```
MILESTONE STATUS DASHBOARD
==========================

Overall Progress: [████████░░] 78% (12 of 15 milestones completed)
Current Sprint: M-013 "Integration Testing" (Progress: 45%, Due: 2024-07-20)

ACTIVE MILESTONES:
├── M-013: Integration Testing    [████░░░░░] 45% (On track, 3 days remaining)
├── M-014: Performance Optimization [██░░░░░░░] 25% (At risk, dependency delay)
└── M-015: Deployment Preparation   [░░░░░░░░░]  0% (Pending M-014 completion)

CRITICAL PATH STATUS:
✅ Auth (M-001) → ✅ Database (M-002) → ✅ API (M-003) → 🟡 Testing (M-013) → ⏳ Deploy (M-015)

PERFORMANCE METRICS:
- Average milestone duration: 12.3 days (Target: 14 days) ✅
- Completion rate: 96.2% on-time delivery ✅  
- Efficiency ratio: 1.08 (8% over estimated effort) ⚠️
- Blocker resolution time: 2.1 days average ✅

RISK ALERTS:
🔴 HIGH: M-014 dependency on external API changes (Impact: 2 milestones)
🟡 MED: Resource allocation conflict between M-013 and M-014
🟢 LOW: Documentation updates pending for completed milestones

RECOMMENDATIONS:
→ Immediate: Escalate external API dependency for M-014
→ This week: Reallocate testing resources to accelerate M-013
→ Next sprint: Parallel workstream planning for M-015 preparation
```

**Step 2: Performance Metrics and Analytics Implementation**

**Key Performance Indicators (KPIs):**
- **Completion Rate**: Percentage of milestones delivered on time
- **Efficiency Ratio**: Actual vs estimated effort across milestones
- **Velocity Trending**: Milestone completion rate over time periods
- **Blocker Impact**: Average resolution time and cascade effects
- **Resource Utilization**: Team capacity and allocation efficiency
- **Quality Metrics**: Defect rates and rework requirements

**Metrics Calculation Functions:**
```typescript
interface MilestoneMetrics {
  completion_rate: number;        // On-time delivery percentage
  efficiency_ratio: number;       // Actual/estimated effort ratio
  velocity_trend: number[];       // Completion velocity over time
  blocker_impact: {
    average_resolution_days: number;
    cascading_delays: number;
    prevention_rate: number;
  };
  resource_metrics: {
    utilization_percentage: number;
    allocation_conflicts: number;
    cross_training_coverage: number;
  };
  quality_indicators: {
    rework_percentage: number;
    stakeholder_satisfaction: number;
    technical_debt_ratio: number;
  };
}
```

**Step 3: Cross-Milestone Dependency Analysis**

**Dependency Status Tracking:**
```yaml
dependency_matrix:
  milestone-013:
    depends_on: ["milestone-011", "milestone-012"]
    dependency_status: "satisfied"
    blocks: ["milestone-015"]
    blocker_risk: "low"
    
  milestone-014:
    depends_on: ["external-api-v2", "milestone-013"]
    dependency_status: "at_risk"  # external-api-v2 delayed
    blocks: ["milestone-015", "milestone-016"]
    blocker_risk: "high"
    impact_assessment: "cascading delay to 2 downstream milestones"
    
  milestone-015:
    depends_on: ["milestone-013", "milestone-014"]
    dependency_status: "waiting"
    blocks: ["milestone-016", "milestone-017"]
    blocker_risk: "medium"
    parallel_work_opportunities: ["documentation", "deployment-scripts"]
```

**Step 4: Session Context Synchronization**

**Context Update Protocol:**
- Load current session state from .milestones/sessions/ directory
- Validate context consistency across multiple active sessions
- Detect and resolve state conflicts between concurrent operations
- Update progress snapshots and session checkpoints
- Maintain cross-session milestone state continuity

**Session State Management:**
```yaml
session_sync:
  active_sessions:
    - session_id: "session-20240713-001"
      milestone_focus: "milestone-013"
      last_checkpoint: "2024-07-13T14:30:00Z"
      conflicts: []
      
  context_conflicts:
    - conflict_type: "progress_percentage_mismatch"
      milestone_id: "milestone-013"
      session_1_value: 45
      session_2_value: 50
      resolution: "use_latest_validated_checkpoint"
      
  sync_resolution:
    strategy: "last_writer_wins_with_validation"
    validation_required: true
    backup_checkpoints: true
```

**Step 5: Conflict Detection and Resolution Strategy**

**Multi-Agent Conflict Analysis:**
- Resource allocation conflicts across milestones
- Timeline conflicts and scheduling optimization
- Dependency conflicts and resolution paths
- Technical integration conflicts between milestone deliverables
- Stakeholder expectation conflicts and communication needs

**Conflict Resolution Framework:**
```yaml
conflict_resolution:
  resource_conflicts:
    detection: "agent-based resource utilization analysis"
    resolution: ["reallocation", "timeline-adjustment", "scope-negotiation"]
    
  timeline_conflicts:
    detection: "critical path analysis with buffer validation"
    resolution: ["parallel-workstreams", "dependency-acceleration", "scope-reduction"]
    
  technical_conflicts:
    detection: "integration point analysis and compatibility checking"
    resolution: ["architecture-adjustment", "interface-standardization", "integration-testing"]
```

**Step 6: Stakeholder Reporting and Communication**

**Report Generation Types:**
- **Executive Summary**: High-level progress and key decisions needed
- **Technical Status**: Detailed progress with technical blockers and solutions
- **Resource Reports**: Team utilization and capacity planning insights
- **Risk Assessment**: Current risks with mitigation strategies and timeline impact

**Communication Templates:**
```markdown
## Executive Status Report - Week of [DATE]

### 🎯 Overall Progress
- **Project Completion**: 78% (12 of 15 milestones complete)
- **Current Focus**: Integration testing and performance optimization
- **Timeline Status**: On track for planned delivery date

### ⚠️ Key Decisions Needed
1. **External API Dependency**: Require stakeholder intervention for M-014
2. **Resource Allocation**: Approve temporary reallocation for testing acceleration

### 📈 Performance Highlights
- **Delivery Excellence**: 96.2% on-time milestone completion
- **Efficiency**: 8% over effort estimates (within acceptable range)
- **Quality**: Zero critical defects in completed milestones

### 🚨 Risks and Mitigation
- **HIGH**: External API changes affecting 2 milestones → Escalation meeting scheduled
- **MEDIUM**: Resource conflicts → Temporary reallocation plan prepared

### 📋 Next Week Priorities
1. Complete integration testing (M-013)
2. Resolve external API dependency (M-014)
3. Begin deployment preparation parallel workstream (M-015)
```

**Step 7: Actionable Insights and Recommendations Engine**

**Recommendation Categories:**
- **Immediate Actions**: Urgent issues requiring immediate attention
- **Optimization Opportunities**: Efficiency improvements and process optimization
- **Risk Mitigation**: Proactive measures to prevent future blockers
- **Strategic Adjustments**: Long-term planning and scope optimization

**Insights Generation Algorithm:**
```typescript
interface ActionableInsight {
  category: "immediate" | "optimization" | "risk_mitigation" | "strategic";
  priority: "critical" | "high" | "medium" | "low";
  title: string;
  description: string;
  impact_assessment: {
    timeline_impact_days: number;
    resource_impact: number;
    risk_reduction_percentage: number;
  };
  implementation_steps: string[];
  success_metrics: string[];
}
```

**Step 8: Multi-Agent Status Coordination**

**Agent Spawning Strategy for Comprehensive Analysis:**
```
"I'll coordinate multiple monitoring agents for complete status analysis:

Primary Status Agent: Overall milestone status aggregation and dashboard generation
├── Metrics Agent: Performance calculation and trend analysis
├── Dependency Agent: Cross-milestone relationship analysis and conflict detection
├── Context Agent: Session state synchronization and conflict resolution
├── Risk Agent: Proactive blocker detection and mitigation planning
└── Reporting Agent: Stakeholder communication and insight generation

Each agent will contribute specialized analysis while maintaining consistency through shared state management and validation protocols."
```

**Agent Communication Protocol:**
- Real-time status data sharing between agents
- Conflict detection and escalation mechanisms
- Validation checkpoints for data consistency
- Coordinated insight generation and recommendation synthesis

**Step 9: Continuous Monitoring and Alert System**

**Real-Time Monitoring Capabilities:**
- Progress velocity tracking with trend analysis
- Blocker emergence detection and early warning systems
- Resource utilization monitoring with capacity alerts
- Dependency status monitoring with cascade impact analysis
- Quality metrics tracking with threshold alerting

**Alert Thresholds and Escalation:**
```yaml
monitoring_thresholds:
  progress_velocity:
    warning: "20% below target velocity for 2 consecutive days"
    critical: "30% below target velocity or milestone at risk"
    
  blocker_duration:
    warning: "blocker unresolved for 24 hours"
    critical: "blocker unresolved for 48 hours with cascade impact"
    
  resource_utilization:
    warning: "over 90% utilization across critical resources"
    critical: "resource conflicts causing milestone delays"
```

**Final Status Monitoring Validation:**

**Quality Checklist for Status Updates:**
- [ ] Real-time data accurately collected from all milestone sources
- [ ] Performance metrics calculated with historical trend analysis
- [ ] Cross-milestone dependencies analyzed and visualized
- [ ] Session context synchronized with conflicts resolved
- [ ] Blockers identified with specific resolution recommendations
- [ ] Stakeholder reports generated with actionable insights
- [ ] Risk assessment completed with mitigation strategies
- [ ] Resource allocation analysis with optimization recommendations

**Agent Coordination Quality Assurance:**
- [ ] All monitoring agents deployed and reporting status
- [ ] Data consistency validated across agent reports
- [ ] Insight synthesis completed with recommendation prioritization
- [ ] Conflict resolution protocols executed successfully
- [ ] Stakeholder communication prepared and delivered

**Monitoring Coverage Verification:**
- [ ] All active milestones included in status analysis
- [ ] All dependencies tracked and status validated
- [ ] All sessions synchronized with context consistency
- [ ] All risks identified with mitigation planning
- [ ] All insights actionable with clear implementation paths

**Final Commitment:**
- **I will**: Generate comprehensive real-time milestone status dashboards
- **I will**: Calculate performance metrics with actionable insights
- **I will**: Analyze cross-milestone dependencies and resolve conflicts
- **I will**: Spawn multiple agents for parallel comprehensive analysis
- **I will NOT**: Provide superficial status without analytics
- **I will NOT**: Skip cross-milestone dependency analysis
- **I will NOT**: Generate reports without actionable recommendations

**REMEMBER:**
This is MILESTONE STATUS MONITORING mode - comprehensive analytics, real-time dashboards, and actionable intelligence. The goal is to provide stakeholders with complete visibility and data-driven recommendations for optimal milestone execution.

Executing comprehensive milestone status monitoring protocol with full analytics coverage...