---
allowed-tools: all
description: System design and architecture analysis with ADR generation and implementation roadmaps
---

🚨 **ARCHITECTURAL COMMAND - DESIGN BEFORE CODE!** 🚨

**THIS IS NOT AN IMPLEMENTATION TASK - THIS IS A DESIGN TASK!**

When you run `/architect`, you are REQUIRED to:

1. **ANALYZE** requirements and constraints thoroughly
2. **PROPOSE** multiple architecture options with trade-offs
3. **CREATE** ADRs (Architecture Decision Records) for decisions
4. **GENERATE** detailed implementation roadmaps
5. **USE 5 PARALLEL AGENTS** for comprehensive architecture analysis:
   - Domain Analysis Agent: Analyze business domain and requirements
   - Dependency Mapping Agent: Map system dependencies and integrations
   - Pattern Research Agent: Research and evaluate architectural patterns
   - Risk Assessment Agent: Identify architectural risks and mitigations
   - Documentation Agent: Generate ADRs and implementation roadmaps
   - Say: "I'll spawn 5 specialized agents to analyze this architecture comprehensively"

**FORBIDDEN BEHAVIORS:**
- ❌ "Let me start implementing" → NO! DESIGN FIRST!
- ❌ "I'll just add this feature" → NO! ANALYZE IMPACT!
- ❌ "The current approach is fine" → NO! EVALUATE OPTIONS!
- ❌ Jumping to code without design → NO! ARCHITECTURE FIRST!

**MANDATORY WORKFLOW:**
```
1. Requirements gathering → Understand constraints
2. Current state analysis → Map existing architecture
3. Options evaluation → Compare multiple approaches
4. Decision documentation → Create ADRs
5. Roadmap generation → Plan implementation phases
```

---

🛑 **MANDATORY ARCHITECTURE ANALYSIS** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify you're focusing on design, not implementation

Execute comprehensive architecture analysis with ZERO tolerance for rushing to code.

**FORBIDDEN SHORTCUT PATTERNS:**
- "This is straightforward" → NO, analyze complexity
- "We can figure this out as we build" → NO, design first
- "The existing pattern works" → NO, evaluate alternatives
- "Let's prototype and see" → NO, proper design first
- "Manual sequential analysis" → NO, use 5-agent parallel pattern

Let me think deeply about this architectural challenge with comprehensive parallel analysis.

🚨 **REMEMBER: Architecture defines system success - analyze thoroughly!** 🚨

## 🎯 USE 5 PARALLEL AGENTS FOR ARCHITECTURE

**MANDATORY 5-AGENT ARCHITECTURE ANALYSIS:**

### Agent 1: Domain Analysis Agent
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Analyze domain requirements</parameter>
<parameter name="prompt">You are the Domain Analysis Agent for architecture design.

Your responsibilities:
1. Analyze business requirements and constraints
2. Identify key domain entities and relationships
3. Map functional and non-functional requirements
4. Define system boundaries and interfaces
5. Document domain-driven design opportunities
6. Coordinate with other agents through shared state files

Provide comprehensive domain analysis for architectural decisions.
Save results to /tmp/domain-analysis-{{TIMESTAMP}}.json for coordination.</parameter>
</invoke>
</function_calls>
```

### Agent 2: Dependency Mapping Agent
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Map system dependencies</parameter>
<parameter name="prompt">You are the Dependency Mapping Agent for architecture design.

Your responsibilities:
1. Map all internal and external dependencies
2. Analyze integration points and APIs
3. Identify circular dependencies and coupling issues
4. Evaluate data flow and communication patterns
5. Document dependency risks and mitigation strategies
6. Coordinate with other agents through shared state files

Provide comprehensive dependency analysis for the architecture.
Save dependency mapping to /tmp/dependency-analysis-{{TIMESTAMP}}.json for coordination.</parameter>
</invoke>
</function_calls>
```

### Agent 3: Pattern Research Agent
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Research architectural patterns</parameter>
<parameter name="prompt">You are the Pattern Research Agent for architecture design.

Your responsibilities:
1. Research applicable architectural patterns (microservices, monolith, serverless, etc.)
2. Evaluate design patterns for specific components
3. Analyze industry best practices and case studies
4. Compare pattern trade-offs and implementation complexity
5. Recommend optimal patterns for the requirements
6. Coordinate with other agents through shared state files

Provide pattern analysis with concrete recommendations.
Save pattern research to /tmp/pattern-analysis-{{TIMESTAMP}}.json for coordination.</parameter>
</invoke>
</function_calls>
```

### Agent 4: Risk Assessment Agent
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Assess architectural risks</parameter>
<parameter name="prompt">You are the Risk Assessment Agent for architecture design.

Your responsibilities:
1. Identify technical risks in the proposed architecture
2. Assess scalability and performance risks
3. Evaluate security and compliance risks
4. Analyze maintainability and evolution risks
5. Provide risk mitigation strategies and contingency plans
6. Coordinate with other agents through shared state files

Deliver comprehensive risk assessment with mitigation approaches.
Save risk assessment to /tmp/risk-analysis-{{TIMESTAMP}}.json for coordination.</parameter>
</invoke>
</function_calls>
```

### Agent 5: Documentation Agent
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Generate architecture documentation</parameter>
<parameter name="prompt">You are the Documentation Agent for architecture design.

Your responsibilities:
1. Aggregate results from all parallel architecture agents
2. Create Architecture Decision Records (ADRs) from agent analyses
3. Generate system architecture diagrams and models
4. Document implementation roadmaps and phases
5. Create API specifications and interface contracts
6. Produce architecture guidelines and best practices

Read coordination files:
- /tmp/domain-analysis-{{TIMESTAMP}}.json
- /tmp/dependency-analysis-{{TIMESTAMP}}.json
- /tmp/pattern-analysis-{{TIMESTAMP}}.json
- /tmp/risk-analysis-{{TIMESTAMP}}.json

Provide comprehensive architecture documentation package.
Save final ADRs to /tmp/architecture-adrs-{{TIMESTAMP}}.json</parameter>
</invoke>
</function_calls>
```

## Architecture Analysis Workflow with Task Tool Coordination

**Phase 1: Requirements and Current State (Agents 1 & 2)**
- Domain Analysis Agent explores business requirements → saves to /tmp/domain-analysis-{timestamp}.json
- Dependency Mapping Agent analyzes existing system → saves to /tmp/dependency-analysis-{timestamp}.json
- Both agents work in parallel for comprehensive understanding

**Phase 2: Solution Design (Agents 3 & 4)**
- Pattern Research Agent evaluates architectural options → saves to /tmp/pattern-analysis-{timestamp}.json
- Risk Assessment Agent identifies potential issues → saves to /tmp/risk-analysis-{timestamp}.json
- Parallel analysis ensures thorough evaluation

**Phase 3: Documentation and Planning (Agent 5)**
- Documentation Agent aggregates all agent results from /tmp coordination files
- Creates ADRs, roadmaps, and implementation guides from consolidated analysis
- Produces actionable architecture artifacts → saves to /tmp/architecture-adrs-{timestamp}.json

**Coordination Pattern:**
```markdown
1. **Launch Phase**: Spawn all 5 agents with Task tool simultaneously
2. **Monitoring Phase**: Each agent writes to /tmp/agent-{type}-{timestamp}.json
3. **Aggregation Phase**: Documentation Agent reads all coordination files
4. **Validation Phase**: Verify all agents completed successfully before final ADR generation
5. **Reporting Phase**: Generate unified architecture documentation and roadmaps
```

## Architectural Deliverables with Coordination Files

**From Domain Analysis Agent → /tmp/domain-analysis-{timestamp}.json:**
- Business capability model
- Domain entity relationships  
- Requirements traceability matrix
- System context diagram

**From Dependency Mapping Agent → /tmp/dependency-analysis-{timestamp}.json:**
- Dependency graph visualization
- Integration points inventory
- Data flow diagrams
- Communication patterns analysis

**From Pattern Research Agent → /tmp/pattern-analysis-{timestamp}.json:**
- Pattern evaluation matrix
- Trade-off analysis document
- Best practices recommendations
- Implementation complexity assessment

**From Risk Assessment Agent → /tmp/risk-analysis-{timestamp}.json:**
- Risk register with severity ratings
- Mitigation strategies document
- Contingency plans
- Architecture fitness functions

**From Documentation Agent → /tmp/architecture-adrs-{timestamp}.json:**
- Complete ADR collection (aggregated from all agents)
- Implementation roadmap with phases
- Architecture guidelines document  
- API and interface specifications
- Consolidated recommendations and next steps

## Success Criteria with Coordination Validation

✅ All 5 agents complete their analysis and generate coordination files
✅ All /tmp coordination files successfully created and validated
✅ Comprehensive requirements coverage documented in domain-analysis file
✅ Multiple architecture options evaluated in pattern-analysis file
✅ All risks identified and mitigated in risk-analysis file
✅ Complete documentation package delivered in architecture-adrs file
✅ Clear implementation roadmap defined with consolidated recommendations
✅ Stakeholder alignment achieved through comprehensive ADR documentation

## Architecture Coordination File Structure

**State File Format for All Architecture Agents:**
```json
{
  "agent_type": "domain-analysis|dependency-mapping|pattern-research|risk-assessment|documentation",
  "timestamp": "2024-01-01T12:00:00Z",
  "status": "completed|in_progress|failed",
  "architecture_context": "$ARGUMENTS",
  "analysis_results": {
    "key_findings": [],
    "recommendations": [],
    "trade_offs": [],
    "concerns": [],
    "next_steps": []
  },
  "deliverables": {
    "documents": [],
    "diagrams": [],
    "models": [],
    "specifications": []
  },
  "coordination_data": {
    "dependencies_on_other_agents": [],
    "inputs_for_other_agents": [],
    "validation_checkpoints": []
  },
  "errors": [],
  "completion_confidence": 0.95
}
```

## Architecture Agent Error Handling

**Fallback Strategy for Agent Failures:**
1. **Single Agent Failure**: Other agents continue, Documentation Agent notes gaps
2. **Multiple Agent Failures**: Retry with simplified analysis scope
3. **Documentation Agent Failure**: Manual ADR compilation from available coordination files
4. **Complete Coordination Failure**: Fall back to sequential analysis with progress tracking
- "This doesn't need architecture" → NO, everything needs design

You are architecting: $ARGUMENTS

Let me ultrathink about the architecture and design patterns for this system.

🚨 **REMEMBER: Design decisions have long-term consequences!** 🚨

**Comprehensive Architecture Analysis Protocol:**

**Step 0: Requirements and Constraints Analysis**
- Gather functional and non-functional requirements
- Identify scalability, performance, and reliability constraints
- Map security, compliance, and integration requirements
- Document existing technical debt and limitations

**Step 1: Current State Assessment**
- Map existing system architecture and components
- Identify current design patterns and principles
- Analyze technical stack and dependencies
- Document data flow and system boundaries
- Assess current pain points and bottlenecks

**Step 2: Architecture Options Evaluation**
Generate and compare multiple architectural approaches:
- **Option A**: [Describe approach, pros, cons, complexity]
- **Option B**: [Alternative approach with trade-offs]
- **Option C**: [Third option considering different constraints]

For each option, analyze:
- Scalability characteristics
- Performance implications
- Development complexity
- Operational overhead
- Security considerations
- Cost implications
- Team expertise requirements

**Step 3: Technology Stack Analysis**
- Database selection (RDBMS vs NoSQL vs hybrid)
- Communication patterns (REST vs GraphQL vs event-driven)
- Caching strategies (in-memory vs distributed vs CDN)
- Deployment architecture (monolith vs microservices vs serverless)
- Data processing (batch vs streaming vs real-time)

**Step 4: Cross-Cutting Concerns Design**
- Security architecture (authentication, authorization, encryption)
- Observability strategy (logging, metrics, tracing, alerting)
- Error handling and resilience patterns
- Configuration management
- CI/CD pipeline integration
- Data privacy and compliance

**Architecture Quality Checklist:**
- [ ] Separation of concerns with clear boundaries
- [ ] Scalability both horizontal and vertical
- [ ] Fault tolerance and graceful degradation
- [ ] Security by design principles
- [ ] Testability at all levels
- [ ] Maintainability and evolvability
- [ ] Performance optimization opportunities
- [ ] Operational simplicity

**Decision Documentation Requirements:**
For each significant architectural decision, create ADR with:
- **Context**: What forces are at play?
- **Decision**: What was decided?
- **Rationale**: Why this option over alternatives?
- **Consequences**: What are the trade-offs?
- **Alternatives Considered**: What else was evaluated?

**Domain-Driven Design Considerations:**
- [ ] Bounded contexts clearly defined
- [ ] Domain entities and aggregates identified
- [ ] Business rules encapsulated appropriately
- [ ] Integration patterns between contexts
- [ ] Event storming outcomes incorporated

**Data Architecture Design:**
- [ ] Data models and relationships mapped
- [ ] Data flow and transformation points
- [ ] Consistency and transaction boundaries
- [ ] Data partitioning and sharding strategy
- [ ] Backup and disaster recovery plans
- [ ] Data privacy and retention policies

**Integration Architecture:**
- [ ] External system dependencies mapped
- [ ] API design patterns chosen
- [ ] Message broker and event patterns
- [ ] Rate limiting and circuit breaker patterns
- [ ] Versioning and backward compatibility
- [ ] Service discovery and configuration

**Implementation Roadmap Generation:**
Create phased implementation plan:

**Phase 1 - Foundation** (Weeks 1-2):
- Core infrastructure setup
- Basic services and data layer
- Authentication and authorization
- Development and testing environments

**Phase 2 - Core Features** (Weeks 3-6):
- Primary business logic implementation
- Essential integrations
- Basic UI/UX components
- Initial testing suite

**Phase 3 - Advanced Features** (Weeks 7-10):
- Advanced functionality
- Performance optimizations
- Comprehensive monitoring
- Security hardening

**Phase 4 - Production Readiness** (Weeks 11-12):
- Load testing and optimization
- Documentation completion
- Deployment automation
- Go-live preparation

**Agent Spawning Strategy:**
When architecture is complex, spawn specialized agents:
1. **Domain Analysis Agent** - "I'll spawn an agent to analyze the domain model and business rules"
2. **Technology Research Agent** - "Another agent will research optimal technology choices"
3. **Integration Analysis Agent** - "A third agent will map integration patterns and requirements"
4. **Security Architecture Agent** - "I'll have an agent focus specifically on security design"

**Risk Assessment and Mitigation:**
- Technical risks and mitigation strategies
- Organizational and team capability risks
- Third-party dependency risks
- Scalability and performance risks
- Security and compliance risks

**Success Metrics Definition:**
- Performance benchmarks and SLAs
- Scalability targets and load expectations
- Availability and reliability requirements
- Security compliance checkpoints
- Developer productivity metrics

**Final Architecture Documentation:**
The architecture is complete when:
✓ All requirements mapped to design decisions
✓ Multiple options evaluated with clear rationale
✓ ADRs created for all significant decisions
✓ Implementation roadmap with realistic timelines
✓ Risk assessment and mitigation strategies
✓ Success metrics and monitoring approach
✓ Team alignment on chosen architecture

**Final Commitment with Task Tool Coordination:**
I will now execute EVERY analysis step with proper Task tool parallel execution and CREATE COMPREHENSIVE ARCHITECTURE. I will:
- ✅ Analyze requirements and constraints thoroughly using Domain Analysis Agent
- ✅ SPAWN 5 PARALLEL AGENTS using Task tool for comprehensive analysis
- ✅ Coordinate agents through /tmp state files for systematic data sharing
- ✅ Evaluate multiple architectural options through Pattern Research Agent
- ✅ Document decisions with proper ADRs through Documentation Agent aggregation
- ✅ Create detailed implementation roadmap from consolidated agent results

I will NOT:
- ❌ Jump to implementation without design
- ❌ Skip parallel agent coordination and use sequential analysis
- ❌ Accept first solution without comprehensive agent evaluation
- ❌ Create roadmap without proper foundation from all agent inputs
- ❌ Skip risk assessment through dedicated Risk Assessment Agent
- ❌ Rush through design phase without proper agent coordination

**REMEMBER: This is a DESIGN task with PARALLEL AGENT EXECUTION, not sequential implementation!**

The architecture is ready ONLY when:
✓ All 5 agents complete successfully with coordination files generated
✓ Every design decision is documented and justified through agent collaboration  
✓ ADRs are consolidated from all agent analyses through proper coordination
✓ Implementation roadmap reflects inputs from all specialized agents

**Executing comprehensive architecture analysis with 5-agent Task tool coordination NOW...**