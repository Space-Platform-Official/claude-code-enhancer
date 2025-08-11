---
allowed-tools: all
description: Strategic milestone planning with scope analysis, timeline estimation, and project decomposition for complex development initiatives
---

# 🔍🔍🔍 CRITICAL REQUIREMENT: MILESTONE PLANNING PHASE! 🔍🔍🔍

**THIS IS NOT IMPLEMENTATION - THIS IS STRATEGIC MILESTONE PLANNING!**

When you run `/milestone/plan`, you are REQUIRED to:

1. **ANALYZE** complete project scope and complexity assessment
2. **DECOMPOSE** project into strategic milestone chunks (2-4 week durations)
3. **ESTIMATE** realistic timelines with dependency mapping
4. **CREATE** milestone directory structure and initial configuration
5. **USE MULTIPLE AGENTS** for comprehensive planning analysis:
   - Spawn one agent for scope analysis and requirements gathering
   - Spawn another for timeline estimation and dependency mapping
   - Spawn more agents for risk assessment and mitigation planning
   - Say: "I'll spawn multiple agents to analyze this project from different planning perspectives"

## 🎯 USE MULTIPLE AGENTS

**MANDATORY TASK TOOL AGENT SPAWNING:**

### Scope Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Analyze project scope</parameter>
<parameter name="prompt">You are the Scope Agent for milestone planning.

Your responsibilities:
1. Analyze project requirements and objectives
2. Identify major functional areas and components
3. Assess technical complexity and dependencies
4. Map stakeholder needs and constraints
5. Generate scope analysis to .milestones/planning/scope.json

Provide comprehensive project scope assessment for planning.</parameter>
</invoke>
</function_calls>
```

### Timeline Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Estimate timelines</parameter>
<parameter name="prompt">You are the Timeline Agent for milestone planning.

Your responsibilities:
1. Read scope analysis from .milestones/planning/scope.json
2. Estimate realistic durations for each component
3. Identify dependencies and sequencing requirements
4. Create critical path analysis
5. Generate timeline plan to .milestones/planning/timeline.json

Create realistic timeline with 2-4 week milestone chunks.</parameter>
</invoke>
</function_calls>
```

### Risk Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Assess risks</parameter>
<parameter name="prompt">You are the Risk Agent for milestone planning.

Your responsibilities:
1. Identify technical risks and uncertainties
2. Assess resource and dependency risks
3. Evaluate timeline and scope risks
4. Propose mitigation strategies for each risk
5. Generate risk assessment to .milestones/planning/risks.json

Provide comprehensive risk analysis with mitigation plans.</parameter>
</invoke>
</function_calls>
```

### Structure Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Design structure</parameter>
<parameter name="prompt">You are the Structure Agent for milestone planning.

Your responsibilities:
1. Design milestone directory structure
2. Create milestone YAML templates
3. Setup tracking and reporting infrastructure
4. Define milestone categories and tags
5. Generate structure to .milestones/planning/structure.md

Create organized framework for milestone management.</parameter>
</invoke>
</function_calls>
```

### Decomposition Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Decompose goals</parameter>
<parameter name="prompt">You are the Decomposition Agent for milestone planning.

Your responsibilities:
1. Read all planning data from other agents
2. Break down project into 2-4 week milestones
3. Define clear objectives for each milestone
4. Assign tasks with kiro workflow phases
5. Generate milestone definitions to .milestones/planning/milestones/

Create actionable milestone breakdown with clear deliverables.</parameter>
</invoke>
</function_calls>
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ Create implementation tasks → NO! Strategic planning only!
- ❌ "Let's start coding first" → NO! Planning before implementation!
- ❌ Skip scope analysis → NO! Full understanding required!
- ❌ Use arbitrary timeline estimates → NO! Research-based planning!
- ❌ Ignore project dependencies → NO! Map all interconnections!
- ❌ "We'll figure it out later" → NO! Comprehensive planning first!

**MANDATORY WORKFLOW:**
```
1. Project scope analysis → Understand full complexity and requirements
2. IMMEDIATELY spawn agents for parallel planning analysis
3. Strategic milestone decomposition → Break into 2-4 week chunks
4. Timeline estimation with dependencies → Research-based scheduling
5. Create milestone directory structure → Persistent planning framework
6. VERIFY planning completeness and feasibility
```

**YOU ARE NOT DONE UNTIL:**
- ✅ Complete project scope analyzed and documented
- ✅ Strategic milestones defined with clear boundaries
- ✅ Timeline estimates completed with dependency mapping
- ✅ Risk assessment finished with mitigation strategies
- ✅ Milestone directory structure created with templates
- ✅ Project-specific milestone configuration generated

---

🛑 **MANDATORY MILESTONE PLANNING CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check project requirements and existing documentation  
3. Verify you understand scope requiring strategic planning

Execute comprehensive milestone planning with ZERO tolerance for implementation shortcuts.

**FORBIDDEN SHORTCUT PATTERNS:**
- "Let's create basic milestones" → NO, strategic decomposition required
- "We can plan as we go" → NO, comprehensive planning first
- "Simple timeline is enough" → NO, dependency-aware scheduling needed
- "One milestone template fits all" → NO, project-specific templates required
- "Skip risk assessment for now" → NO, mitigation planning is critical

You are planning milestones for: $ARGUMENTS

Let me ultrathink about the strategic milestone architecture and planning framework.

🚨 **REMEMBER: Strategic planning prevents costly pivots and rework!** 🚨

**Comprehensive Milestone Planning Protocol:**

**Step 0: Project Scope Analysis**
- Analyze complete project requirements and success criteria
- Map functional and non-functional requirements comprehensively
- Identify technical constraints and technology dependencies
- Assess team capabilities and resource availability
- Document stakeholder expectations and delivery deadlines
- Review existing codebase and architectural constraints

**Step 1: Strategic Milestone Decomposition**
- Break complex project into logical milestone boundaries
- Ensure each milestone delivers standalone business value
- Define clear completion criteria and acceptance thresholds
- Map milestone interdependencies and critical path elements
- Validate milestone scope fits 2-4 week execution windows
- Identify milestone-specific success metrics and KPIs

**Step 2: Timeline Estimation and Dependency Mapping**

**Research-Based Estimation Process:**
```
Estimation factors to analyze:
- Historical velocity data from similar projects
- Team experience levels with required technologies
- Complexity multipliers for new/unknown technologies
- Integration complexity with existing systems
- Testing and quality assurance time requirements
- Buffer allocation for unexpected challenges (20-30%)
```

**Dependency Analysis Framework:**
```yaml
dependency_mapping:
  technical_dependencies:
    - external_apis: ["payment-gateway", "auth-service"]
    - infrastructure: ["database-migration", "deployment-pipeline"]
    - third_party: ["design-assets", "content-creation"]
  
  team_dependencies:
    - skill_development: ["react-training", "security-certification"]
    - resource_allocation: ["designer-availability", "devops-support"]
    - review_processes: ["architecture-review", "security-audit"]
  
  business_dependencies:
    - approvals: ["budget-approval", "compliance-review"]
    - external_deliverables: ["client-feedback", "vendor-integration"]
    - regulatory: ["privacy-assessment", "accessibility-compliance"]
```

**Step 3: Milestone Directory Structure Creation**

**Generate Project-Specific Structure:**
```
.milestones/
├── config/
│   ├── milestone-config.yaml     # Project-specific configuration
│   ├── dependencies.yaml         # Cross-milestone dependencies
│   ├── timeline-estimates.yaml   # Scheduling and duration data
│   └── risk-register.yaml        # Risk assessment and mitigation
├── planning/
│   ├── scope-analysis.md          # Detailed project scope breakdown
│   ├── decomposition-strategy.md  # Milestone breakdown rationale
│   ├── timeline-estimation.md     # Estimation methodology and data
│   └── stakeholder-requirements.md # Requirements traceability
├── templates/
│   ├── milestone-template.yaml    # Standard milestone structure
│   ├── task-template.yaml         # Task definition template
│   └── progress-tracking.yaml     # Progress measurement template
└── active/
    ├── milestone-001.yaml         # Ready for implementation
    ├── milestone-002.yaml         # Planned next milestone
    └── dependencies.yaml          # Active dependency tracking
```

**Step 4: Risk Assessment and Mitigation Planning**

**Comprehensive Risk Analysis:**
```yaml
risk_categories:
  technical_risks:
    - complexity_underestimation:
        probability: 0.4
        impact: "high"
        mitigation: "Add 30% buffer, prototype critical components"
    - integration_challenges:
        probability: 0.3
        impact: "medium"
        mitigation: "Early integration testing, API contracts"
  
  resource_risks:
    - team_availability:
        probability: 0.2
        impact: "high"
        mitigation: "Cross-training, knowledge documentation"
    - skill_gaps:
        probability: 0.3
        impact: "medium"
        mitigation: "Training allocation, expert consultation"
  
  external_risks:
    - dependency_delays:
        probability: 0.3
        impact: "high"
        mitigation: "Alternative solutions, early coordination"
    - requirement_changes:
        probability: 0.4
        impact: "medium"
        mitigation: "Change control process, stakeholder alignment"
```

**Step 5: Project-Specific Template Generation**

**Milestone Template Customization:**
```yaml
# Generated based on project type and requirements
milestone_template:
  metadata:
    project_type: "${PROJECT_TYPE}"  # frontend, backend, fullstack, mobile
    methodology: "${METHODOLOGY}"    # agile, waterfall, hybrid
    team_size: "${TEAM_SIZE}"
    
  structure:
    objectives:
      - primary_goal: "Clear business objective"
      - success_criteria: ["Measurable outcome 1", "Measurable outcome 2"]
      - business_value: "Tangible value delivered"
    
    scope:
      included: ["Feature A", "Component B", "Integration C"]
      excluded: ["Future enhancement", "Nice-to-have feature"]
      assumptions: ["Dependency available", "Resource allocated"]
    
    # KIRO WORKFLOW CONFIGURATION (MANDATORY)
    kiro_configuration:
      enabled: true
      policy: "mandatory"  # All tasks must use kiro workflow
      enforcement: "strict"  # No exceptions allowed
      default_phases: ["design", "spec", "task", "execute"]
      phase_weights:
        design: 15
        spec: 25
        task: 20
        execute: 40
      approval_gates:
        design_to_spec:
          required: true
          approvers: ["tech_lead", "architect"]
          criteria: ["architecture_approved", "api_design_validated"]
        spec_to_task:
          required: true
          approvers: ["tech_lead", "product_owner"]
          criteria: ["specification_complete", "test_plan_approved"]
        task_to_execute:
          required: false
          approvers: []
        execute_completion:
          required: false
          approvers: []
    
    timeline:
      estimated_duration: "${DURATION_WEEKS} weeks"
      critical_path_items: ["Blocking task 1", "Blocking task 2"]
      buffer_percentage: "${BUFFER_PERCENT}%"
      phase_distribution:  # Time allocation per kiro phase
        design_percentage: 15
        spec_percentage: 25
        task_percentage: 20
        execute_percentage: 40
      
    dependencies:
      prerequisite_milestones: []
      external_dependencies: []
      shared_resources: []
      phase_dependencies:  # Kiro phase-level dependencies
        design_requires: ["requirements_complete", "stakeholder_alignment"]
        spec_requires: ["design_approval", "technical_review"]
        task_requires: ["spec_approval", "resource_allocation"]
        execute_requires: ["task_breakdown", "environment_ready"]
```

**Step 6: Implementation Pattern**

**Complete Execution Flow:**

```markdown
When user runs `/milestone/plan [project-description]`, follow this EXACT pattern:

1. **Setup Infrastructure:**
   - Create .milestones/planning/ directory
   - Initialize planning workspace

2. **Spawn All 5 Agents Using Task Tool:**
   
   I'll now spawn 5 specialized agents for comprehensive planning:
   
   [Use Task tool with Scope Agent template above]
   [Use Task tool with Timeline Agent template above]
   [Use Task tool with Risk Agent template above]
   [Use Task tool with Structure Agent template above]
   [Use Task tool with Decomposition Agent template above]

3. **Monitor Coordination:**
   - Scope analysis completes first
   - Other agents use scope data
   - Decomposition agent aggregates all planning

4. **Present Results:**
   - Display milestone breakdown
   - Show timeline and dependencies
   - Present risk mitigation strategies
```

**Step 7: Multi-Agent Planning Execution with Kiro Integration**

**Agent Spawning Strategy for Kiro-Native Planning:**
```
"I'll coordinate specialized planning agents for kiro-integrated milestone planning:

1. **Scope Analysis Agent**: 'Analyze requirements and map to kiro phases (Design/Spec/Task/Execute)'
2. **Timeline Estimation Agent**: 'Calculate phase durations using kiro weight distribution'
3. **Risk Assessment Agent**: 'Identify phase-specific risks and approval bottlenecks'
4. **Dependency Mapping Agent**: 'Map inter-phase dependencies and approval workflows'
5. **Template Generation Agent**: 'Create kiro-native templates with phase deliverables'
6. **Kiro Compliance Agent**: 'Ensure all tasks follow mandatory kiro workflow standard'

Each agent will ensure kiro workflow compliance from planning inception."
```

**🚀 KIRO-NATIVE PLANNING ENFORCEMENT**

```bash
# Initialize kiro-native system during planning
source "templates/commands/milestone/_shared/kiro-native.md"
initialize_kiro_native

# Enforce kiro compliance for all new milestones
KIRO_POLICY_MODE="mandatory"
KIRO_ENFORCEMENT_LEVEL="strict"
```

**Kiro-Enhanced Planning Quality Checklist:**
- [ ] Project scope analyzed and mapped to kiro phases
- [ ] All tasks created with mandatory kiro workflow structure
- [ ] Phase-specific deliverables defined for each task
- [ ] Approval gates configured for Design→Spec and Spec→Task transitions
- [ ] Timeline estimates distributed across kiro phases (15% Design, 25% Spec, 20% Task, 40% Execute)
- [ ] Dependencies mapped at phase level, not just task level
- [ ] Risk assessment includes phase-specific risks and approval delays
- [ ] Deliverable templates generated for each kiro phase
- [ ] Visualization dashboard configured for kiro workflow tracking
- [ ] Compliance validation ensures 100% kiro adoption

**Kiro-Aware Planning Anti-Patterns:**
- ❌ Creating tasks without kiro workflow structure
- ❌ Skipping phase-specific deliverable definition
- ❌ Ignoring approval gate configuration
- ❌ Using flat task lists instead of phased workflows
- ❌ Estimating at task level instead of phase level
- ❌ Creating implementation tasks during planning phase
- ❌ Estimating timelines without kiro phase distribution
- ❌ Ignoring phase-level dependencies and constraints
- ❌ Using generic templates without kiro phase customization
- ❌ Skipping phase-specific risk assessment
- ❌ Planning milestones longer than 4 weeks (too complex)
- ❌ Creating milestones without clear phase-based value delivery

**Kiro-Native Planning Verification:**
Before completing milestone planning:
- Have I enabled mandatory kiro workflow for all tasks?
- Are all tasks structured with 4-phase kiro workflow?
- Have I defined phase-specific deliverables for each task?
- Are approval gates configured for critical phase transitions?
- Are timeline estimates distributed across kiro phases (15/25/20/40)?
- Have I mapped dependencies at both task and phase levels?
- Are phase-specific risks identified with mitigation strategies?
- Is the kiro visualization dashboard configured?
- Do templates include phase-specific deliverable generation?
- Have I validated 100% kiro compliance across the milestone?

**Final Commitment:**
- **I will**: Execute comprehensive scope analysis before decomposition
- **I will**: Create strategic milestones with clear business value
- **I will**: Use research-based timeline estimation methodology
- **I will**: Map dependencies across all domains comprehensively
- **I will**: Generate project-specific templates and configurations
- **I will NOT**: Create implementation tasks during planning
- **I will NOT**: Use arbitrary timeline estimates
- **I will NOT**: Skip risk assessment or dependency mapping

**REMEMBER:**
This is MILESTONE PLANNING mode - strategic analysis, decomposition, and preparation for execution. The goal is to create a comprehensive roadmap that enables successful project delivery through well-planned milestone execution.

Executing strategic milestone planning protocol for project success...