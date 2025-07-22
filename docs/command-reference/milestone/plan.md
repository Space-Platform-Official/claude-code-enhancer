# Milestone Plan Command Reference

**Command**: `/milestone/plan`  
**Category**: Milestone Management  
**Description**: Strategic milestone planning with scope analysis, timeline estimation, and project decomposition for complex development initiatives

## Overview

The `/milestone/plan` command provides comprehensive milestone planning capabilities with advanced scope analysis, dependency mapping, and timeline estimation. This command transforms project requirements into strategic milestone roadmaps with sophisticated multi-agent coordination for thorough planning analysis.

## Usage Patterns

```bash
# Create new milestone plan with project analysis
/milestone/plan "Project Name"

# Plan with specific methodology
/milestone/plan "Project Name" --methodology=agile

# Plan with team size considerations
/milestone/plan "Project Name" --team-size=5

# Plan with timeline constraints
/milestone/plan "Project Name" --deadline=2024-12-31

# Plan with risk assessment
/milestone/plan "Project Name" --risk-analysis=comprehensive

# Plan with dependency mapping
/milestone/plan "Project Name" --map-dependencies
```

## Command Syntax

```bash
/milestone/plan <project-name> [options]
```

### Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `project-name` | Name or description of the project to plan | Yes |

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--methodology=<type>` | Planning methodology (agile/waterfall/hybrid) | agile |
| `--team-size=N` | Number of team members available | 3 |
| `--deadline=<date>` | Target completion date | auto-calculate |
| `--risk-analysis=<level>` | Risk assessment depth (basic/comprehensive) | comprehensive |
| `--map-dependencies` | Enable dependency mapping | true |
| `--buffer-percentage=N` | Timeline buffer allocation | 25 |
| `--milestone-duration=N` | Target milestone duration (weeks) | 2-4 |
| `--enable-kiro` | Enable kiro workflow for tasks | false |

## Multi-Agent Planning Coordination

The plan command deploys sophisticated multi-agent coordination for comprehensive project analysis:

### Agent Spawning Strategy

```bash
"I'll spawn multiple planning agents to analyze this project comprehensively:
- Scope Analysis Agent: Analyze requirements and project complexity
- Timeline Estimation Agent: Research historical data and estimate realistic durations
- Risk Assessment Agent: Identify potential blockers and create mitigation strategies
- Dependency Mapping Agent: Map technical, team, and business dependencies
- Template Generation Agent: Create project-specific templates and configurations"
```

### Agent Coordination Patterns

1. **Scope Analysis and Decomposition**
   - Agent 1: Requirements analysis and functional decomposition
   - Agent 2: Technical architecture and complexity assessment
   - Agent 3: Resource requirement and skill gap analysis

2. **Timeline and Risk Assessment**
   - Agent 4: Historical data research and estimation modeling
   - Agent 5: Risk identification and mitigation planning
   - Agent 6: Dependency mapping and critical path analysis

## Planning Process Architecture

### Phase 1: Project Scope Analysis

```bash
# Comprehensive scope analysis
✅ Functional requirements analysis and decomposition
✅ Technical constraints and architecture assessment
✅ Resource availability and skill gap identification
✅ Stakeholder expectations and success criteria
✅ Integration complexity and external dependencies
✅ Quality requirements and compliance considerations
```

### Phase 2: Strategic Milestone Decomposition

```bash
# Strategic milestone breakdown
📋 Business value-driven milestone boundaries
🎯 Logical dependency grouping and sequencing
⚡ 2-4 week milestone duration optimization
🔄 Clear completion criteria and acceptance thresholds
📊 Risk-balanced scope distribution
🤖 Resource allocation and capacity planning
```

### Phase 3: Timeline Estimation and Dependencies

```bash
# Research-based estimation process
📈 Historical velocity data analysis
⏱️ Technology complexity factor application
🔍 Team experience level adjustments
📋 Integration overhead calculation
🔔 Buffer allocation for unexpected challenges
📈 Confidence interval and variance analysis
```

### Phase 4: Risk Assessment and Mitigation

```bash
# Comprehensive risk planning
🚫 Technical risk identification and scoring
⏰ Timeline risk assessment and buffering
🛠️ Resource risk and mitigation strategies
🌐 External dependency risk planning
📋 Quality and compliance risk management
🎯 Stakeholder and communication risk mitigation
```

## Planning Strategies

### Agile Planning Strategy

```bash
# Iterative value delivery approach
Strategy: Agile
Benefits:
- Early value delivery through prioritized milestones
- Flexible scope adjustment based on feedback
- Regular stakeholder engagement and validation
- Risk reduction through incremental delivery

Planning Approach:
- User story mapping and epic decomposition
- Sprint-aligned milestone boundaries
- Continuous planning and adaptation
- Stakeholder feedback integration loops
```

### Waterfall Planning Strategy

```bash
# Sequential phase-based approach
Strategy: Waterfall
Benefits:
- Comprehensive upfront planning and documentation
- Clear phase gates and milestone dependencies
- Predictable timeline and resource allocation
- Detailed risk assessment and mitigation

Planning Approach:
- Complete requirements analysis before design
- Sequential milestone dependencies
- Detailed documentation and approval gates
- Comprehensive testing and validation phases
```

### Hybrid Planning Strategy

```bash
# Balanced iterative and sequential approach
Strategy: Hybrid
Benefits:
- Strategic planning with tactical flexibility
- Phase-based structure with iterative delivery
- Risk-balanced milestone sequencing
- Stakeholder engagement at key decision points

Planning Approach:
- Strategic milestone planning with agile execution
- Phase gates for critical decisions
- Iterative development within milestone boundaries
- Continuous risk assessment and adaptation
```

## Project Decomposition Framework

### Milestone Boundary Definition

```bash
# Strategic milestone boundaries
🎯 Business Value Alignment: Each milestone delivers standalone value
📦 Logical Scope Grouping: Related functionality bundled appropriately
⚡ Optimal Duration: 2-4 week execution windows for manageable complexity
🔗 Dependency Management: Clear prerequisites and handoff points
📊 Risk Distribution: Balanced risk allocation across milestones
```

### Task Breakdown Structure

```bash
# Hierarchical task decomposition
Milestone Level: Strategic business objectives (2-4 weeks)
├── Epic Level: Major feature areas (3-7 days)
│   ├── Story Level: User-facing functionality (1-2 days)
│   │   ├── Task Level: Technical implementation (2-8 hours)
│   │   └── Subtask Level: Specific work items (1-4 hours)
```

## Timeline Estimation Models

### Research-Based Estimation

```bash
# Historical data-driven estimation
Estimation Factors:
- Historical velocity for similar projects
- Team experience with technology stack
- Complexity multipliers for new technologies
- Integration overhead with existing systems
- Testing and quality assurance requirements
- Buffer allocation for unknown challenges (20-30%)
```

### Three-Point Estimation

```bash
# Uncertainty-aware estimation approach
For each milestone component:
- Optimistic Estimate: Best-case scenario
- Most Likely Estimate: Expected duration
- Pessimistic Estimate: Worst-case scenario

Calculated Duration = (Optimistic + 4×Most Likely + Pessimistic) / 6
Confidence Interval = (Pessimistic - Optimistic) / 6
```

### Complexity Factor Matrix

```bash
# Technology and team complexity adjustments
Technology Complexity:
- Familiar tech stack: 1.0x baseline
- Some new technology: 1.3x multiplier
- Mostly new technology: 1.8x multiplier
- Cutting-edge technology: 2.5x multiplier

Team Experience:
- Expert team: 0.8x efficiency
- Experienced team: 1.0x baseline
- Mixed experience: 1.3x multiplier
- Inexperienced team: 2.0x multiplier
```

## Dependency Management

### Dependency Mapping Framework

```bash
# Comprehensive dependency analysis
Technical Dependencies:
- External APIs and service integrations
- Infrastructure and deployment requirements
- Third-party libraries and licensing
- Database schema and migration needs

Team Dependencies:
- Skill development and training requirements
- Resource allocation and availability
- Cross-team coordination and handoffs
- Knowledge transfer and documentation

Business Dependencies:
- Stakeholder approvals and decision points
- External vendor deliverables and timelines
- Regulatory compliance and certification
- Market timing and competitive constraints
```

### Critical Path Analysis

```bash
# Dependency sequencing and optimization
Critical Path Identification:
├── Blocking Dependencies: Must complete before dependent work
├── Enabling Dependencies: Required for optimal execution
├── Parallel Opportunities: Work that can proceed independently
└── Optional Dependencies: Nice-to-have but not blocking

Resource Optimization:
├── Parallel Workstream Identification
├── Resource Leveling and Allocation
├── Bottleneck Identification and Mitigation
└── Timeline Optimization Opportunities
```

## Risk Assessment Framework

### Risk Identification Matrix

```bash
# Systematic risk identification
Technical Risks:
- Technology complexity and learning curve
- Integration challenges and compatibility
- Performance and scalability requirements
- Security and compliance considerations

Project Risks:
- Timeline pressure and scope creep
- Resource availability and skill gaps
- Stakeholder alignment and communication
- External dependency delays and changes

Business Risks:
- Market changes and competitive pressure
- Budget constraints and approval delays
- Regulatory changes and compliance
- Stakeholder priority shifts
```

### Risk Scoring and Prioritization

```yaml
risk_assessment:
  probability_scale: # 1-5 scale
    1: "Very Low (0-10%)"
    2: "Low (10-30%)"
    3: "Medium (30-50%)"
    4: "High (50-80%)"
    5: "Very High (80-100%)"
    
  impact_scale: # 1-5 scale
    1: "Minimal (<1 week delay)"
    2: "Low (1-2 weeks delay)"
    3: "Medium (3-4 weeks delay)"
    4: "High (1-2 months delay)"
    5: "Critical (>2 months delay)"
    
  risk_score: probability × impact
  priority_threshold: score >= 9 (immediate attention)
```

## Template Generation

### Project-Specific Templates

```yaml
# Generated milestone template
milestone_template:
  metadata:
    project_type: "${PROJECT_TYPE}"
    methodology: "${METHODOLOGY}"
    team_size: ${TEAM_SIZE}
    complexity_level: "${COMPLEXITY}"
    
  structure:
    objectives:
      primary_goal: "Clear business objective"
      success_criteria: ["Measurable outcome 1", "Measurable outcome 2"]
      business_value: "Tangible value proposition"
      
    scope:
      included: ["Feature A", "Component B", "Integration C"]
      excluded: ["Future enhancement", "Out-of-scope item"]
      assumptions: ["Dependency available", "Resource allocated"]
      
    timeline:
      estimated_duration: "${DURATION} weeks"
      critical_path: ["Blocking task 1", "Blocking task 2"]
      buffer_percentage: "${BUFFER}%"
      confidence_level: "${CONFIDENCE}%"
```

### Estimation Model Configuration

```yaml
# Project-specific estimation parameters
estimation_config:
  base_multipliers:
    technology_complexity: ${TECH_MULTIPLIER}
    team_experience: ${TEAM_MULTIPLIER}
    integration_overhead: ${INTEGRATION_MULTIPLIER}
    
  buffer_allocations:
    technical_risks: "${TECH_BUFFER}%"
    resource_risks: "${RESOURCE_BUFFER}%"
    external_dependencies: "${EXTERNAL_BUFFER}%"
    
  quality_gates:
    code_review_overhead: "${REVIEW_OVERHEAD}%"
    testing_allocation: "${TESTING_PERCENT}%"
    documentation_time: "${DOCS_PERCENT}%"
```

## Directory Structure Generation

### Planning Workspace Creation

```bash
# Generated project planning structure
.milestones/
├── config/
│   ├── project-config.yaml         # Project-specific settings
│   ├── milestone-template.yaml     # Customized milestone template
│   ├── estimation-model.yaml       # Project estimation parameters
│   └── risk-register.yaml          # Risk assessment and mitigation
├── planning/
│   ├── scope-analysis.md           # Detailed scope breakdown
│   ├── timeline-estimation.md      # Estimation methodology and data
│   ├── dependency-mapping.md       # Dependency analysis and critical path
│   └── stakeholder-requirements.md # Requirements traceability matrix
├── templates/
│   ├── task-template.yaml          # Standard task structure
│   ├── progress-tracking.yaml      # Progress measurement template
│   └── review-criteria.yaml        # Quality and acceptance criteria
└── active/
    └── README.md                   # Ready for milestone creation
```

## Quality Validation

### Planning Completeness Checklist

```bash
# Comprehensive planning validation
✅ Project Scope Analysis:
  - Functional requirements decomposed and documented
  - Technical architecture and constraints identified
  - Resource requirements and skill gaps assessed
  - Success criteria and acceptance thresholds defined

✅ Milestone Decomposition:
  - Strategic boundaries align with business value
  - 2-4 week duration targets maintained
  - Clear dependencies and handoff points identified
  - Risk distribution balanced across milestones

✅ Timeline Estimation:
  - Historical data research completed
  - Complexity factors applied appropriately
  - Buffer allocation based on risk assessment
  - Confidence intervals and variance calculated

✅ Risk Assessment:
  - Technical, project, and business risks identified
  - Risk scoring and prioritization completed
  - Mitigation strategies defined for high-priority risks
  - Monitoring and escalation procedures established
```

## Error Handling and Validation

### Common Planning Issues

1. **Insufficient Scope Analysis**
   ```bash
   ❌ Scope unclear: Requirements need further decomposition
   
   # Resolution strategies
   → Conduct stakeholder interviews
   → Create user story mapping sessions
   → Develop prototype for validation
   ```

2. **Unrealistic Timeline Estimates**
   ```bash
   ❌ Timeline too aggressive: Estimates don't include buffers
   
   # Resolution strategies
   → Apply complexity multipliers
   → Add appropriate buffer percentages
   → Validate against historical data
   ```

3. **Missing Dependency Analysis**
   ```bash
   ❌ Dependencies unidentified: Critical path incomplete
   
   # Resolution strategies
   → Conduct dependency mapping workshop
   → Review external integration points
   → Validate resource availability
   ```

## Workflow Examples

### Standard Project Planning

```bash
# Complete project planning workflow
/milestone/plan "E-commerce Platform Upgrade"

# Process flow:
# 1. Analyze project scope and requirements
# 2. Spawn agents for parallel planning analysis
# 3. Decompose into strategic milestones
# 4. Estimate timelines with dependency mapping
# 5. Assess risks and create mitigation strategies
# 6. Generate project-specific templates and structure
```

### Agile Project Planning

```bash
# Agile methodology with iterative planning
/milestone/plan "Mobile App Development" --methodology=agile --team-size=6

# Agile-specific features:
# 1. User story mapping and epic decomposition
# 2. Sprint-aligned milestone boundaries
# 3. Stakeholder feedback integration points
# 4. Continuous planning and adaptation capabilities
```

### Complex Integration Planning

```bash
# High-risk integration project
/milestone/plan "Legacy System Migration" --risk-analysis=comprehensive --buffer-percentage=35

# Integration-focused planning:
# 1. Detailed dependency mapping
# 2. Integration complexity assessment
# 3. Phased migration strategy
# 4. Rollback and contingency planning
```

## Performance Optimization

### Planning Efficiency

```bash
# Optimized planning process
⚡ Parallel agent coordination for faster analysis
🎯 Template reuse and customization
💾 Historical data integration for accurate estimation
🔄 Automated dependency detection
📊 Risk assessment automation where possible
```

### Quality Assurance

```bash
# Planning quality validation
🧠 Multi-agent cross-validation of estimates
⚙️ Historical accuracy tracking and improvement
💽 Stakeholder feedback integration
🌐 Best practice application and verification
🔋 Continuous improvement based on outcomes
```

## Related Commands

- **[/milestone/execute](execute.md)** - Execute planned milestones with coordination
- **[/milestone/status](status.md)** - Monitor milestone progress and health
- **[/milestone/update](update.md)** - Modify milestone scope and timelines
- **[/milestone/archive](archive.md)** - Complete and archive finished milestones

## Best Practices

### Planning Excellence

1. **Comprehensive Analysis**: Invest time in thorough scope and requirement analysis
2. **Research-Based Estimation**: Use historical data and complexity factors
3. **Risk-Aware Planning**: Identify and mitigate risks proactively
4. **Stakeholder Alignment**: Ensure clear communication and expectation setting
5. **Flexible Framework**: Plan for adaptation and continuous improvement

### Multi-Agent Coordination

1. **Parallel Analysis**: Leverage multiple agents for comprehensive coverage
2. **Cross-Validation**: Use agent coordination for estimate validation
3. **Specialized Expertise**: Deploy agents with specific domain knowledge
4. **Synthesis Integration**: Combine agent insights for holistic planning
5. **Quality Assurance**: Implement multi-agent review and validation

### Continuous Improvement

1. **Template Evolution**: Update templates based on project outcomes
2. **Estimation Accuracy**: Track and improve estimation models
3. **Risk Learning**: Build risk library from actual project experience
4. **Process Refinement**: Continuously improve planning methodology
5. **Knowledge Sharing**: Capture and share planning insights across projects

---

*The `/milestone/plan` command provides comprehensive project planning with strategic milestone decomposition, research-based estimation, and sophisticated risk assessment for successful project delivery.*