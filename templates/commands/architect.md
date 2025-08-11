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

Provide comprehensive domain analysis for architectural decisions.</parameter>
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

Provide comprehensive dependency analysis for the architecture.</parameter>
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

Provide pattern analysis with concrete recommendations.</parameter>
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

Deliver comprehensive risk assessment with mitigation approaches.</parameter>
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
1. Create Architecture Decision Records (ADRs) for key decisions
2. Generate system architecture diagrams and models
3. Document implementation roadmaps and phases
4. Create API specifications and interface contracts
5. Produce architecture guidelines and best practices

Provide comprehensive architecture documentation package.</parameter>
</invoke>
</function_calls>
```

## Architecture Analysis Workflow

**Phase 1: Requirements and Current State (Agents 1 & 2)**
- Domain Analysis Agent explores business requirements
- Dependency Mapping Agent analyzes existing system
- Both agents work in parallel for comprehensive understanding

**Phase 2: Solution Design (Agents 3 & 4)**
- Pattern Research Agent evaluates architectural options
- Risk Assessment Agent identifies potential issues
- Parallel analysis ensures thorough evaluation

**Phase 3: Documentation and Planning (Agent 5)**
- Documentation Agent synthesizes findings
- Creates ADRs, roadmaps, and implementation guides
- Produces actionable architecture artifacts

## Architectural Deliverables

**From Domain Analysis Agent:**
- Business capability model
- Domain entity relationships
- Requirements traceability matrix
- System context diagram

**From Dependency Mapping Agent:**
- Dependency graph visualization
- Integration points inventory
- Data flow diagrams
- Communication patterns analysis

**From Pattern Research Agent:**
- Pattern evaluation matrix
- Trade-off analysis document
- Best practices recommendations
- Implementation complexity assessment

**From Risk Assessment Agent:**
- Risk register with severity ratings
- Mitigation strategies document
- Contingency plans
- Architecture fitness functions

**From Documentation Agent:**
- Complete ADR collection
- Implementation roadmap with phases
- Architecture guidelines document
- API and interface specifications

## Success Criteria

✅ All 5 agents complete their analysis
✅ Comprehensive requirements coverage
✅ Multiple architecture options evaluated
✅ All risks identified and mitigated
✅ Complete documentation package delivered
✅ Clear implementation roadmap defined
✅ Stakeholder alignment achieved
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

**Final Commitment:**
I will now execute EVERY analysis step listed above and CREATE COMPREHENSIVE ARCHITECTURE. I will:
- ✅ Analyze requirements and constraints thoroughly
- ✅ SPAWN MULTIPLE AGENTS for complex analysis
- ✅ Evaluate multiple architectural options
- ✅ Document decisions with proper ADRs
- ✅ Create detailed implementation roadmap

I will NOT:
- ❌ Jump to implementation without design
- ❌ Skip options evaluation
- ❌ Accept first solution without analysis
- ❌ Create roadmap without proper foundation
- ❌ Skip risk assessment
- ❌ Rush through design phase

**REMEMBER: This is a DESIGN task, not an implementation task!**

The architecture is ready ONLY when every design decision is documented and justified.

**Executing comprehensive architecture analysis and design NOW...**