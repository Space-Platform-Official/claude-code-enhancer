# Architecture Design Command Reference

**Command**: `/architect`  
**Category**: Core Development  
**Description**: System design and architecture analysis with ADR generation and implementation roadmaps

## Overview

The `/architect` command provides comprehensive system design and architecture analysis with sophisticated multi-agent coordination for evaluating architectural options, generating Architecture Decision Records (ADRs), and creating detailed implementation roadmaps. This command ensures thoughtful design before implementation.

## Usage Patterns

```bash
# Comprehensive architecture analysis
/architect "user authentication system"

# Architecture for specific component
/architect "payment processing module"

# System redesign and modernization
/architect "microservices migration strategy"

# Performance architecture optimization
/architect "high-throughput data pipeline"

# Security architecture review
/architect "secure API gateway design"

# Multi-tenant architecture design
/architect "SaaS platform architecture"
```

## Command Syntax

```bash
/architect "<system-description>" [options]
```

### Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `system-description` | Description of system to architect | Yes |

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--scope=<level>` | Architecture scope (component/service/system) | system |
| `--constraints=<list>` | Specific constraints to consider | detect |
| `--patterns=<list>` | Preferred architectural patterns | analyze |
| `--format=<type>` | Output format (adr/roadmap/analysis) | comprehensive |
| `--agents=N` | Number of analysis agents | 6 |
| `--depth=<level>` | Analysis depth (high/medium/low) | high |
| `--technology=<stack>` | Technology stack focus | detect |
| `--timeline=<duration>` | Implementation timeline constraint | flexible |

## Multi-Agent Architecture Analysis

The architect command deploys sophisticated multi-agent coordination for comprehensive analysis:

### Agent Spawning Strategy

```bash
"I'll spawn multiple agents to analyze this architecture from different perspectives:
- Current State Analysis Agent: Map existing architecture and technical debt
- Requirements Analysis Agent: Gather constraints and non-functional requirements
- Pattern Research Agent: Research industry patterns and best practices
- Options Evaluation Agent: Generate and compare architectural alternatives
- Risk Assessment Agent: Analyze risks, trade-offs, and complexity factors
- Implementation Planning Agent: Create detailed roadmaps and ADRs"
```

### Agent Coordination Patterns

1. **Analysis Phase Coordination**
   - Agent 1: Current architecture mapping and assessment
   - Agent 2: Requirements gathering and constraint analysis
   - Agent 3: Industry research and pattern analysis

2. **Design Phase Coordination**
   - Agent 4: Architecture option generation and modeling
   - Agent 5: Trade-off analysis and risk assessment
   - Agent 6: Documentation and roadmap generation

## Architecture Analysis Protocol

### Phase 1: Requirements and Constraints Analysis

```bash
# Comprehensive requirements gathering
📋 Functional Requirements Analysis
- Core system capabilities and features
- User interaction patterns and workflows
- Data processing and storage requirements
- Integration and API requirements

📊 Non-Functional Requirements Analysis  
- Performance and scalability requirements
- Reliability and availability constraints
- Security and compliance requirements
- Maintainability and extensibility needs

🔒 Constraint Identification
- Technical constraints (legacy systems, technology stack)
- Business constraints (budget, timeline, resources)
- Regulatory constraints (compliance, data protection)
- Organizational constraints (team size, expertise)
```

### Phase 2: Current State Assessment

```bash
# Existing architecture analysis
🏗️ System Architecture Mapping
- Component identification and boundaries
- Data flow and communication patterns
- Technology stack and dependencies
- Deployment and infrastructure setup

📈 Technical Debt Assessment
- Code quality and maintainability issues
- Performance bottlenecks and inefficiencies
- Security vulnerabilities and weaknesses
- Scalability limitations and constraints

💡 Pain Point Identification
- Development productivity blockers
- Operational complexity and maintenance burden
- User experience and performance issues
- Integration and extensibility challenges
```

### Phase 3: Architecture Options Generation

```bash
# Multiple architecture option evaluation
🎯 Option A: [Primary Approach]
- Architecture pattern and design principles
- Technology stack and component selection
- Pros: Benefits and advantages
- Cons: Limitations and trade-offs
- Complexity: Implementation and maintenance effort

🎯 Option B: [Alternative Approach]
- Different architectural patterns or technologies
- Alternative design decisions and trade-offs
- Comparative analysis with Option A
- Risk assessment and mitigation strategies

🎯 Option C: [Hybrid/Innovative Approach]
- Creative combination of patterns
- Emerging technology integration
- Future-proofing considerations
- Innovation vs. risk balance
```

### Phase 4: Decision Documentation and Roadmapping

```bash
# Architecture Decision Records (ADRs) and Implementation Planning
📋 ADR Generation for Key Decisions
- Decision context and constraints
- Options considered and evaluation criteria
- Decision rationale and justification
- Consequences and trade-offs

🗺️ Implementation Roadmap Creation
- Phase-based implementation strategy
- Dependency mapping and sequencing
- Resource allocation and timeline
- Risk mitigation and contingency planning
```

## Architecture Decision Records (ADRs)

### ADR Template Structure

```markdown
# ADR-001: [Decision Title]

## Status
[Proposed | Accepted | Deprecated | Superseded]

## Context
[Describe the architectural challenge and constraints]

## Decision
[State the architectural decision and rationale]

## Consequences
[Document the positive and negative consequences]

## Options Considered
[List alternative options with brief analysis]

## Implementation Notes
[Technical implementation details and considerations]
```

### ADR Categories

| Category | Focus | Examples |
|----------|-------|----------|
| **Technology Stack** | Platform and framework decisions | Database selection, language choice |
| **Architecture Patterns** | Design pattern adoption | Microservices, event-driven, layered |
| **Data Management** | Data storage and processing | Database design, caching strategy |
| **Security Architecture** | Security design decisions | Authentication, authorization, encryption |
| **Integration Strategy** | System integration approaches | API design, messaging patterns |
| **Deployment Architecture** | Infrastructure and deployment | Cloud strategy, containerization |

## Architecture Pattern Analysis

### Supported Architecture Patterns

| Pattern | Use Cases | Benefits | Trade-offs |
|---------|-----------|----------|------------|
| **Monolithic** | Simple applications, rapid prototyping | Easy deployment, development simplicity | Scalability limitations, technology lock-in |
| **Microservices** | Large-scale, team autonomy | Independent scaling, technology diversity | Complexity, distributed system challenges |
| **Serverless** | Event-driven, variable workloads | Cost efficiency, automatic scaling | Vendor lock-in, cold start latency |
| **Event-Driven** | Real-time processing, loose coupling | Scalability, fault tolerance | Complexity, eventual consistency |
| **Layered** | Enterprise applications, clear separation | Maintainability, testability | Performance overhead, coupling |
| **Hexagonal** | Domain-driven design, testability | Clean architecture, flexibility | Learning curve, initial complexity |

### Pattern Selection Criteria

```bash
# Architecture pattern evaluation matrix
📊 Scalability Requirements
- Horizontal vs. vertical scaling needs
- Performance and throughput requirements
- Geographic distribution requirements

👥 Team and Organizational Factors
- Team size and expertise
- Development velocity requirements
- Deployment and operation capabilities

🔧 Technical Constraints
- Existing technology investments
- Integration requirements
- Performance and latency constraints

💰 Business Constraints
- Budget and resource limitations
- Time-to-market requirements
- Risk tolerance and compliance needs
```

## Technology Stack Analysis

### Stack Evaluation Framework

```bash
# Technology selection criteria
🎯 Technical Fit
- Requirements alignment
- Performance characteristics
- Scalability and reliability
- Security and compliance

👥 Team Capability
- Existing expertise and experience
- Learning curve and training needs
- Available resources and support
- Development productivity impact

🌍 Ecosystem Maturity
- Community size and activity
- Documentation and resources
- Third-party library availability
- Long-term viability and support

💼 Business Alignment
- Cost and licensing considerations
- Strategic technology direction
- Integration with existing systems
- Risk and vendor dependencies
```

### Technology Recommendation Matrix

| Component | Option A | Option B | Option C | Recommendation |
|-----------|----------|----------|----------|----------------|
| **Backend** | Node.js + Express | Python + Django | Java + Spring | [Justified choice] |
| **Frontend** | React + TypeScript | Vue.js + JavaScript | Angular + TypeScript | [Justified choice] |
| **Database** | PostgreSQL | MongoDB | MySQL | [Justified choice] |
| **Cache** | Redis | Memcached | In-memory | [Justified choice] |
| **Message Queue** | RabbitMQ | Apache Kafka | Amazon SQS | [Justified choice] |
| **Deployment** | Docker + Kubernetes | AWS ECS | Traditional VMs | [Justified choice] |

## Risk Assessment and Mitigation

### Architecture Risk Analysis

```bash
# Comprehensive risk assessment
⚠️ Technical Risks
- Technology maturity and stability
- Performance and scalability challenges
- Security vulnerabilities and threats
- Integration complexity and dependencies

📈 Business Risks
- Implementation timeline and budget
- Team capability and resource constraints
- Market and competitive pressures
- Regulatory and compliance requirements

🔄 Operational Risks
- Deployment and maintenance complexity
- Monitoring and troubleshooting challenges
- Disaster recovery and business continuity
- Vendor dependencies and lock-in
```

### Risk Mitigation Strategies

```bash
# Risk mitigation planning
🛡️ Technical Mitigation
- Proof-of-concept development
- Gradual migration strategies
- Backup and fallback options
- Performance testing and validation

📋 Process Mitigation
- Phased implementation approach
- Regular review and adjustment points
- Team training and skill development
- External expertise and consulting

🔍 Monitoring and Detection
- Early warning systems and metrics
- Regular architecture reviews
- Continuous monitoring and alerting
- Performance and security auditing
```

## Implementation Roadmap Generation

### Phased Implementation Strategy

```bash
# Strategic implementation phases
🚀 Phase 1: Foundation (Weeks 1-4)
- Core infrastructure setup
- Basic architecture implementation
- Development environment configuration
- Initial security and monitoring setup

🏗️ Phase 2: Core Development (Weeks 5-12)
- Primary functionality implementation
- API development and integration
- Database design and implementation
- Testing framework establishment

🔧 Phase 3: Integration and Enhancement (Weeks 13-20)
- Third-party service integration
- Performance optimization
- Security hardening and compliance
- Advanced feature development

🎯 Phase 4: Production Readiness (Weeks 21-24)
- Production deployment preparation
- Monitoring and alerting setup
- Documentation and training
- Go-live preparation and validation
```

### Dependency Mapping

```bash
# Implementation dependency analysis
📊 Critical Path Identification
- Sequential dependencies and blockers
- Parallel development opportunities
- Resource allocation optimization
- Timeline impact analysis

🔗 Component Dependencies
- Technical dependencies between components
- Team coordination requirements
- External service dependencies
- Infrastructure and tooling prerequisites
```

## Quality Assurance and Validation

### Architecture Quality Metrics

```bash
# Quality assessment criteria
📏 Design Quality
- Cohesion and coupling metrics
- Complexity and maintainability scores
- Documentation completeness
- Standards and best practice adherence

🎯 Implementation Quality
- Code quality and consistency
- Test coverage and reliability
- Performance and efficiency
- Security and compliance validation

📈 Operational Quality
- Monitoring and observability
- Deployment and rollback capabilities
- Scalability and reliability
- Maintenance and support readiness
```

### Validation Checkpoints

```bash
# Architecture validation gates
✅ Design Review Checkpoint
- Architecture decision validation
- Stakeholder approval and sign-off
- Risk assessment and mitigation review
- Resource and timeline validation

✅ Implementation Review Checkpoint
- Code quality and standards compliance
- Testing and validation results
- Performance and security validation
- Documentation and training readiness

✅ Production Readiness Checkpoint
- Deployment and operational readiness
- Monitoring and alerting validation
- Business continuity and disaster recovery
- Go-live criteria and success metrics
```

## Workflow Examples

### Complete Architecture Analysis

```bash
# Comprehensive system architecture design
/architect "e-commerce platform with microservices"

# Process flow:
# 1. Multi-agent requirement and constraint analysis
# 2. Current state assessment and technical debt evaluation
# 3. Architecture option generation and comparison
# 4. Risk assessment and mitigation planning
# 5. ADR generation for key decisions
# 6. Implementation roadmap creation
```

### Component-Level Architecture

```bash
# Focused component design
/architect "user authentication service" --scope=component

# Component-focused process:
# 1. Component requirement analysis
# 2. Interface and integration design
# 3. Technology stack selection
# 4. Security and performance considerations
# 5. Implementation strategy
```

### Migration Architecture Planning

```bash
# Legacy system modernization
/architect "monolith to microservices migration" --timeline=6months

# Migration-focused process:
# 1. Legacy system analysis and decomposition
# 2. Migration strategy and phasing
# 3. Risk assessment and mitigation
# 4. Parallel development and deployment
# 5. Validation and rollback planning
```

## Related Commands

- **[/milestone/plan](../milestone/plan.md)** - Convert architecture to milestone planning
- **[/debug](debug.md)** - Architecture debugging and analysis
- **[/optimize](optimize.md)** - Performance architecture optimization
- **[/refactor](refactor.md)** - Architecture-driven refactoring
- **[/review](review.md)** - Architecture review and validation

## Best Practices

### Architecture Excellence

1. **Design Before Code**: Always complete architectural design before implementation
2. **Multiple Options**: Evaluate at least 3 architectural approaches
3. **Document Decisions**: Create comprehensive ADRs for all major decisions
4. **Risk Assessment**: Thoroughly analyze risks and mitigation strategies
5. **Stakeholder Alignment**: Ensure architecture aligns with business objectives

### Multi-Agent Coordination

1. **Perspective Diversity**: Use agents for different architectural viewpoints
2. **Parallel Analysis**: Coordinate simultaneous evaluation of different aspects
3. **Expertise Simulation**: Assign agents specialized architectural domains
4. **Cross-Validation**: Use agents to validate each other's analyses
5. **Comprehensive Coverage**: Ensure all architectural dimensions are covered

### Implementation Planning

1. **Phased Approach**: Break implementation into manageable phases
2. **Dependency Management**: Clear identification and management of dependencies
3. **Risk Mitigation**: Proactive risk identification and mitigation planning
4. **Quality Gates**: Establish clear validation checkpoints
5. **Continuous Review**: Regular architecture review and adjustment

---

*The `/architect` command provides comprehensive system design and architecture analysis with multi-agent coordination for thorough evaluation, decision documentation, and implementation planning.*