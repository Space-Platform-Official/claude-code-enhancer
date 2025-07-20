# Milestone Status Command Reference

**Command**: `/milestone/status`  
**Category**: Milestone Management  
**Description**: Comprehensive milestone status checking with visual progress tracking, real-time analytics, and project health assessment

## Overview

The `/milestone/status` command provides advanced milestone status monitoring with sophisticated multi-agent coordination, real-time progress dashboards, and comprehensive health assessment. This command transforms milestone data into actionable insights with advanced visualization and trend analysis.

## Usage Patterns

```bash
# Check status of all milestones
/milestone/status

# Check specific milestone status
/milestone/status MILESTONE_ID

# Status with detailed analytics
/milestone/status --analytics=detailed

# Real-time monitoring dashboard
/milestone/status --dashboard

# Cross-milestone dependency view
/milestone/status --dependencies

# Performance metrics and trends
/milestone/status --metrics

# Status with health assessment
/milestone/status --health-check
```

## Command Syntax

```bash
/milestone/status [milestone-id] [options]
```

### Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `milestone-id` | Specific milestone identifier (optional) | No |

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--analytics=<level>` | Analysis depth (basic/detailed/comprehensive) | detailed |
| `--dashboard` | Generate interactive progress dashboard | false |
| `--dependencies` | Show cross-milestone dependency analysis | false |
| `--metrics` | Include performance metrics and trends | true |
| `--health-check` | Comprehensive project health assessment | true |
| `--format=<type>` | Output format (dashboard/json/table) | dashboard |
| `--refresh=<seconds>` | Auto-refresh interval for monitoring | disabled |
| `--notifications` | Enable status change notifications | false |

## Multi-Agent Status Analysis

The status command deploys sophisticated multi-agent coordination for comprehensive milestone analysis:

### Agent Spawning Strategy

```bash
"I'll spawn multiple monitoring agents to analyze milestone status comprehensively:
- Discovery Agent: Scan and inventory all milestone files and directory structure
- Parser Agent: Extract milestone data, progress metrics, and completion status
- Calculator Agent: Compute accurate progress percentages and timeline analysis
- Visualizer Agent: Generate interactive dashboards, charts, and progress bars
- Health Agent: Assess project health, risks, and critical path status
- Reporter Agent: Create actionable insights and recommendations"
```

### Agent Coordination Patterns

1. **Data Collection and Analysis**
   - Agent 1: Milestone discovery and file parsing
   - Agent 2: Progress calculation and metrics analysis
   - Agent 3: Dependency mapping and critical path analysis

2. **Visualization and Reporting**
   - Agent 4: Dashboard generation and visual progress displays
   - Agent 5: Health assessment and risk identification
   - Agent 6: Trend analysis and predictive insights

## Status Analysis Architecture

### Phase 1: Milestone Discovery and Inventory

```bash
# Comprehensive milestone scanning
✅ Scan .milestones/ directory structure for all files
✅ Inventory active, completed, and planned milestones
✅ Validate file formats and data integrity
✅ Check for milestone configuration and tracking schemas
✅ Identify missing or corrupted milestone data
✅ Load cross-milestone dependency mappings
```

### Phase 2: Data Parsing and Metrics Calculation

```bash
# Advanced progress analysis
📋 Extract milestone data and progress metrics
🎯 Calculate accurate completion percentages
⚡ Analyze timeline status and variance
🔄 Compute task-level progress and dependencies
📊 Generate performance indicators and trends
🤖 Assess resource utilization and capacity
```

### Phase 3: Visual Dashboard Generation

```bash
# Interactive status visualization
📊 Real-time progress dashboards with charts
⏱️ Timeline visualization with critical path
🎯 Task completion matrices and heat maps
📈 Performance trend analysis and projections
🔔 Risk assessment with visual indicators
📋 Stakeholder-ready status summaries
```

### Phase 4: Health Assessment and Insights

```bash
# Comprehensive project health analysis
🚫 Blocker identification and impact assessment
⏰ Timeline risk analysis with mitigation strategies
🛠️ Resource constraint identification
📋 Quality gate status and compliance checking
💡 Actionable recommendations and next steps
🎯 Strategic insights for optimization
```

## Status Dashboard Formats

### Interactive Progress Dashboard

```bash
MILESTONE STATUS DASHBOARD
==========================

📊 OVERALL PROJECT HEALTH: 67% Complete | 🟢 ON TRACK

PROJECT PROGRESS OVERVIEW:
┌─────────────────────────────────────────────────────────────────────────┐
│ GLOBAL PROGRESS    [████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] 67% │
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
```

### Detailed Milestone Status

```bash
MILESTONE DETAIL: M05 - Integration Testing Framework
=====================================================

📊 PROGRESS: 78% Complete (12 of 15 tasks)
⏰ TIMELINE: On track, 3 days remaining
🎯 STATUS: Active execution with good progress

TASK BREAKDOWN:
├── ✅ Test Framework Setup (100%)
├── ✅ Unit Test Migration (100%)
├── ✅ API Test Suite (100%)
├── 🟡 Integration Test Cases (85%)
├── 🟡 Performance Test Setup (60%)
├── ⏳ End-to-End Test Automation (0%)
└── ⏳ Test Documentation (0%)

DEPENDENCIES:
├── ✅ API Endpoints (M03) → Satisfied
├── ⚠️  CI/CD Pipeline → Partially available
└── ⏳ Test Environment → In preparation

RISK ASSESSMENT:
🔴 HIGH: CI/CD pipeline complexity higher than estimated
🟡 MED: Test environment deployment may delay final tasks

RECENT ACTIVITY:
• 2024-07-19 14:30: Completed API test suite validation
• 2024-07-19 11:15: Performance test framework configured
• 2024-07-19 09:45: Integration test cases 85% complete

NEXT STEPS:
1. 🎯 Complete integration test case coverage
2. 🔧 Resolve CI/CD pipeline configuration issues
3. 📋 Begin end-to-end test automation setup
```

## Performance Metrics and Analytics

### Key Performance Indicators

```bash
# Comprehensive performance metrics
Project Performance Dashboard:
├── Completion Rate: 96.2% on-time delivery
├── Velocity: 1.2 milestones/week (Target: 1.0)
├── Efficiency Ratio: 0.92 (Actual vs Estimated)
├── Quality Score: 95% first-time success rate
├── Resource Utilization: 85% average capacity
└── Risk Resolution: 2.1 days average

Trend Analysis (Last 4 weeks):
├── Velocity Trend: ↗️ Increasing (+15%)
├── Quality Trend: ↗️ Improving (+8%)
├── Efficiency Trend: → Stable
├── Risk Trend: ↘️ Decreasing (-20%)
└── Capacity Trend: ↗️ Increasing (+10%)
```

### Historical Performance Tracking

```yaml
performance_metrics:
  velocity_tracking:
    current_velocity: 1.2  # milestones per week
    target_velocity: 1.0
    trend: "increasing"
    efficiency_score: 0.92
    
  timeline_health:
    schedule_variance: "+2 days ahead"
    critical_path_status: "on_track"
    buffer_remaining: "15%"
    projected_completion: "2024-08-06"
    
  quality_indicators:
    task_completion_rate: 0.95
    milestone_success_rate: 1.0
    defect_rate: 0.02
    rework_percentage: 0.08
    
  resource_metrics:
    team_utilization: 0.85
    capacity_trends: "stable"
    skill_gap_impact: "minimal"
    cross_training_coverage: 0.75
```

## Cross-Milestone Dependency Analysis

### Dependency Visualization

```bash
DEPENDENCY MAP ANALYSIS
=======================

MILESTONE DEPENDENCY MATRIX:
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┐
│     │ M01 │ M02 │ M03 │ M04 │ M05 │ M06 │ M07 │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│ M01 │  -  │  ✅  │  ✅  │  ✅  │  ✅  │  ❌  │  ❌  │
│ M02 │  ⬅️  │  -  │  ✅  │  ❌  │  ✅  │  ❌  │  ❌  │
│ M03 │  ⬅️  │  ⬅️  │  -  │  ✅  │  ✅  │  ✅  │  ❌  │
│ M04 │  ⬅️  │  ❌  │  ❌  │  -  │  ✅  │  ✅  │  ❌  │
│ M05 │  ⬅️  │  ⬅️  │  ⬅️  │  ❌  │  -  │  ❌  │  ✅  │
│ M06 │  ❌  │  ❌  │  ⬅️  │  ⬅️  │  ❌  │  -  │  ✅  │
│ M07 │  ❌  │  ❌  │  ❌  │  ❌  │  ⬅️  │  ⬅️  │  -  │
└─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘

Legend: ✅ Dependency Satisfied | ⬅️ Depends On | ❌ No Dependency

BLOCKING ANALYSIS:
🚫 M05 blocks M07 (deployment pipeline setup)
🚫 M06 blocks M07 (performance requirements for production)
⚠️  M07 has 2 dependencies - highest risk for delays

PARALLEL OPPORTUNITIES:
🔄 M04 and M05 can continue in parallel
🔄 M06 can start once M03 and M04 complete
🔄 Documentation (M08) can begin in parallel with M07
```

### Critical Path Assessment

```yaml
critical_path_analysis:
  primary_path: ["M01", "M02", "M03", "M05", "M07", "M08"]
  path_duration: 42  # days
  buffer_time: 6     # days
  risk_factor: 0.75  # medium risk
  
  bottlenecks:
    - milestone_id: "M05"
      reason: "Complex integration testing requirements"
      impact: "Blocks deployment preparation"
      mitigation: "Parallel test environment setup"
      
    - milestone_id: "M07"
      reason: "Multiple dependency convergence"
      impact: "Final delivery timeline"
      mitigation: "Early infrastructure coordination"
      
  optimization_opportunities:
    - parallel_workstreams: ["M04+M05", "M06+M07_prep"]
    - early_starts: ["M08_planning", "M07_infrastructure"]
    - resource_reallocation: ["Testing specialists to M05"]
```

## Health Assessment and Risk Analysis

### Project Health Scoring

```bash
PROJECT HEALTH ASSESSMENT
=========================

OVERALL HEALTH SCORE: 8.2/10 🟢 EXCELLENT

Health Component Breakdown:
├── 🟢 Timeline Health: 9.0/10
│   ├── Schedule adherence: Ahead by 2 days
│   ├── Milestone delivery: 100% on-time record
│   └── Buffer utilization: 15% remaining
│
├── 🟡 Resource Health: 7.5/10
│   ├── Team utilization: 85% (near optimal)
│   ├── Skill coverage: 90% requirements met
│   └── Capacity planning: Some constraints identified
│
├── 🟢 Quality Health: 9.5/10
│   ├── Deliverable quality: 95% first-time acceptance
│   ├── Technical debt: Minimal accumulation
│   └── Stakeholder satisfaction: 9/10 average
│
├── 🟡 Risk Health: 7.0/10
│   ├── Active risks: 4 identified (2 high, 2 medium)
│   ├── Mitigation coverage: 100% of risks addressed
│   └── Risk trend: Decreasing over time
│
└── 🟢 Delivery Health: 8.5/10
    ├── Scope stability: No major changes
    ├── Dependency status: 85% satisfied
    └── Stakeholder engagement: High participation
```

### Risk Assessment Dashboard

```bash
RISK ASSESSMENT SUMMARY
=======================

🔴 HIGH PRIORITY RISKS (2):
├── R001: CI/CD Pipeline Complexity
│   ├── Impact: 2-week potential delay
│   ├── Probability: 60%
│   ├── Mitigation: DevOps specialist engagement
│   └── Status: 🟡 In progress
│
└── R002: Infrastructure Dependency
    ├── Impact: 1-week potential delay
    ├── Probability: 40%
    ├── Mitigation: Early coordination meetings
    └── Status: 🟢 Mitigated

🟡 MEDIUM PRIORITY RISKS (2):
├── R003: Team Capacity Constraints
│   ├── Impact: Quality vs timeline trade-off
│   ├── Probability: 50%
│   ├── Mitigation: Resource reallocation plan
│   └── Status: 🟡 Monitoring
│
└── R004: Third-party API Changes
    ├── Impact: Integration rework required
    ├── Probability: 30%
    ├── Mitigation: Adapter pattern implementation
    └── Status: 🟢 Prepared

RISK TREND ANALYSIS:
├── Week 1: 6 risks identified
├── Week 2: 5 risks (1 resolved)
├── Week 3: 4 risks (1 mitigated)
└── Week 4: 4 risks (stable)

PROACTIVE MONITORING:
🔍 Daily risk assessment reviews
📊 Automated risk threshold alerts
🎯 Stakeholder risk communication
📋 Mitigation strategy execution tracking
```

## Real-Time Monitoring and Alerts

### Continuous Status Updates

```bash
# Real-time monitoring capabilities
Status Monitoring Features:
├── Live progress tracking with 15-minute updates
├── Automated blocker detection and escalation
├── Resource utilization monitoring with alerts
├── Timeline deviation alerts with impact analysis
├── Quality gate validation with immediate feedback
└── Stakeholder notification system

Alert Thresholds:
├── Progress velocity: 20% below target for 2 days
├── Blocker duration: Unresolved for 24 hours
├── Resource utilization: Over 90% for critical roles
├── Timeline risk: Milestone at risk of missing deadline
└── Quality issues: Failed quality gates or rework
```

### Notification System

```yaml
notification_config:
  channels:
    email: ["stakeholders", "project-managers"]
    slack: ["development-team", "qa-team"]
    dashboard: ["real-time-updates"]
    
  trigger_conditions:
    milestone_completion: "immediate"
    blocker_detected: "within 1 hour"
    timeline_risk: "daily summary"
    quality_issues: "immediate"
    resource_conflicts: "within 4 hours"
    
  escalation_rules:
    high_priority: "immediate notification + escalation"
    medium_priority: "4-hour notification window"
    low_priority: "daily digest format"
```

## Advanced Analytics

### Predictive Analysis

```bash
PREDICTIVE ANALYTICS DASHBOARD
==============================

COMPLETION FORECASTING:
├── Current trajectory: August 6, 2024
├── Optimistic scenario: August 3, 2024 (95% confidence)
├── Pessimistic scenario: August 12, 2024 (95% confidence)
├── Most likely outcome: August 6, 2024 (80% confidence)
└── Risk factors: CI/CD complexity, resource constraints

VELOCITY PREDICTIONS:
├── Next milestone (M06): 12 days (estimated 14 days)
├── Following milestone (M07): 16 days (estimated 15 days)
├── Final milestone (M08): 8 days (estimated 10 days)
└── Confidence level: High (based on historical performance)

RESOURCE OPTIMIZATION INSIGHTS:
├── Peak utilization period: Weeks 6-7 (M05 + M06 overlap)
├── Resource reallocation opportunity: Week 8 (M07 prep)
├── Skill development window: Weeks 9-10 (post-delivery)
└── Capacity planning: 2 additional developers for optimal flow
```

### Trend Analysis

```typescript
interface StatusTrends {
  velocity_trends: {
    current_period: number;
    historical_average: number;
    trend_direction: "increasing" | "stable" | "decreasing";
    confidence_level: number;
  };
  
  quality_trends: {
    defect_rate_trend: number;
    first_time_quality: number;
    rework_percentage: number;
    improvement_trajectory: string;
  };
  
  efficiency_trends: {
    actual_vs_estimated: number;
    resource_utilization: number;
    process_efficiency: number;
    optimization_opportunities: string[];
  };
}
```

## Integration with Execution

### Status-Driven Execution

```bash
# Status monitoring integrated with execution
Execution Integration:
├── Real-time status updates during milestone execution
├── Automatic blocker detection and escalation
├── Resource reallocation based on status insights
├── Timeline adjustment recommendations
├── Quality gate integration with status reporting
└── Stakeholder communication automation

Status-Informed Decisions:
├── Parallel workstream optimization
├── Resource allocation adjustments
├── Timeline buffer utilization
├── Risk mitigation activation
└── Scope adjustment recommendations
```

## Workflow Examples

### Comprehensive Status Check

```bash
# Complete project status analysis
/milestone/status --analytics=comprehensive --dashboard

# Process flow:
# 1. Discover and inventory all milestone files
# 2. Spawn agents for parallel status analysis
# 3. Generate interactive progress dashboards
# 4. Calculate performance metrics and trends
# 5. Assess project health and identify risks
# 6. Provide actionable insights and recommendations
```

### Real-Time Monitoring Setup

```bash
# Continuous monitoring with alerts
/milestone/status --refresh=300 --notifications

# Monitoring features:
# 1. Auto-refresh status every 5 minutes
# 2. Real-time progress tracking
# 3. Automated alert generation
# 4. Stakeholder notification system
# 5. Trend analysis and predictions
```

### Cross-Milestone Analysis

```bash
# Multi-milestone dependency analysis
/milestone/status --dependencies --metrics

# Analysis includes:
# 1. Cross-milestone dependency mapping
# 2. Critical path identification
# 3. Bottleneck analysis and optimization
# 4. Resource conflict detection
# 5. Timeline optimization opportunities
```

## Related Commands

- **[/milestone/plan](plan.md)** - Strategic milestone planning and preparation
- **[/milestone/execute](execute.md)** - Active milestone execution with coordination
- **[/milestone/update](update.md)** - Modify milestone scope and timelines
- **[/milestone/archive](archive.md)** - Complete and archive finished milestones

## Best Practices

### Status Monitoring Excellence

1. **Regular Monitoring**: Check status daily for active milestones
2. **Proactive Analysis**: Use trend analysis for early issue detection
3. **Stakeholder Communication**: Share status dashboards regularly
4. **Risk Awareness**: Monitor and address risks proactively
5. **Data-Driven Decisions**: Use metrics for optimization opportunities

### Dashboard Utilization

1. **Visual Clarity**: Use appropriate visualization for different audiences
2. **Actionable Insights**: Focus on metrics that drive decisions
3. **Real-Time Updates**: Ensure status information is current and accurate
4. **Trend Analysis**: Monitor patterns for predictive insights
5. **Integration**: Connect status monitoring with execution processes

---

*The `/milestone/status` command provides comprehensive milestone monitoring with real-time dashboards, advanced analytics, and actionable insights for optimal project visibility and control.*