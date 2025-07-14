---
allowed-tools: all
description: Microservice architecture decomposition with critical safety measures and distributed system patterns
---

# 🚨🚨🚨 CRITICAL REQUIREMENT: SAFE MICROSERVICE DECOMPOSITION! 🚨🚨🚨

**THIS IS NOT A CASUAL SPLITTING TASK - THIS IS A CRITICAL DISTRIBUTED ARCHITECTURE TASK!**

When you run `/service-split`, you are REQUIRED to:

1. **ANALYZE** monolithic boundaries, data dependencies, and service contracts
2. **DESIGN** comprehensive microservice architecture with safety measures
3. **USE MULTIPLE AGENTS** to decompose different domains in parallel:
   - Spawn one agent to extract user management services
   - Spawn another to decompose business logic domains
   - Spawn more agents for data and infrastructure services
   - Say: "I'll spawn multiple agents to decompose these service domains in parallel"
4. **IMPLEMENT** service boundaries with proper isolation and communication
5. **DO NOT STOP** until:
   - ✅ ALL service boundaries are properly defined and implemented
   - ✅ ALL distributed system patterns are correctly applied
   - ✅ Data consistency and transaction boundaries are preserved
   - ✅ Service communication is resilient and observable

**FORBIDDEN BEHAVIORS:**
- ❌ "This could be a separate service" → NO! CREATE THE SERVICE PROPERLY!
- ❌ "Microservices would improve scalability" → NO! IMPLEMENT THE DECOMPOSITION!
- ❌ "These modules are loosely coupled" → NO! EXTRACT THEM AS SERVICES!
- ❌ Splitting without data consistency analysis → NO! ANALYZE TRANSACTIONS FIRST!

**MANDATORY WORKFLOW:**
```
1. Analyze service boundaries → Identify decomposition opportunities
2. IMMEDIATELY spawn agents to decompose different domains
3. Implement proper service isolation and communication
4. Ensure data consistency and transaction integrity
5. REPEAT until optimal microservice architecture is achieved
```

**YOU ARE NOT DONE UNTIL:**
- All identified service domains are properly extracted
- Service communication patterns are resilient and observable
- Data consistency mechanisms are correctly implemented
- All distributed system concerns are addressed
- Service deployment and monitoring are fully operational

---

🛑 **MANDATORY MICROSERVICE ANALYSIS** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify service decomposition scope and critical dependencies

Execute systematic microservice decomposition with: $ARGUMENTS

**FORBIDDEN DECOMPOSITION PATTERNS:**
- "Split by file structure" → NO, decompose by business domains
- "Create service for every module" → NO, identify proper service boundaries
- "Microservices solve all problems" → NO, address distributed system complexity
- "Database per service is always right" → NO, analyze data consistency requirements
- "Network calls are not a big deal" → NO, design for network failures and latency

Let me ultrathink about the systematic microservice decomposition approach for this monolithic system.

🚨 **REMEMBER: Distributed systems are fundamentally more complex - safety is paramount!** 🚨

**Microservice Decomposition Protocol:**

**Step 0: Monolith Analysis and Safety Assessment**
- Map all business domains and their interactions
- Identify transaction boundaries and data consistency requirements
- Analyze current deployment and operational complexity
- Document all cross-cutting concerns and shared dependencies
- Establish rollback procedures for failed decomposition

**Step 1: Service Boundary Identification**
- **Analyze** business capabilities and domain boundaries
- **Identify** data ownership and transaction boundaries
- **Map** team organization and Conway's Law implications
- **Evaluate** performance and scalability requirements per domain
- **Assess** operational complexity and monitoring requirements

**Service Boundary Detection Criteria:**
- [ ] Clear business domain with distinct responsibilities
- [ ] Well-defined data ownership without excessive sharing
- [ ] Independent scaling and performance requirements
- [ ] Minimal cross-domain transaction dependencies
- [ ] Team ownership alignment and expertise boundaries
- [ ] Distinct operational and deployment requirements
- [ ] Clear API contracts and service level agreements
- [ ] Independent technology stack optimization opportunities

**Step 2: Distributed Architecture Design**
Plan microservice extraction with critical safety measures:
- **Phase 1**: Extract stateless services with minimal dependencies
- **Phase 2**: Decompose core business domains with careful data migration
- **Phase 3**: Split shared services and infrastructure components
- **Phase 4**: Optimize service communication and performance

**Microservice Architecture Patterns:**
- **Domain-Driven Design**: Align services with business domains
- **Database per Service**: Ensure data ownership and isolation
- **Event-Driven Architecture**: Implement asynchronous communication
- **API Gateway Pattern**: Centralize cross-cutting concerns
- **Circuit Breaker Pattern**: Handle cascade failures gracefully
- **Saga Pattern**: Manage distributed transactions
- **Service Mesh**: Handle service-to-service communication

**Step 3: Parallel Agent Deployment for Decomposition**
Spawn specialized microservice agents:
```
"I identified multiple service domains requiring decomposition. I'll spawn agents to tackle these systematically:
- Agent 1: Extract user management and authentication services
- Agent 2: Decompose core business logic into domain services
- Agent 3: Split data access layers and implement database per service
- Agent 4: Create infrastructure and shared utility services
- Agent 5: Implement service communication and observability patterns
Let me decompose all service domains in parallel while maintaining system integrity..."
```

**Critical Distributed System Concerns:**

**Data Consistency and Transactions:**
- Implement eventual consistency patterns where appropriate
- Design compensating transactions for distributed operations
- Use saga patterns for complex business transactions
- Implement proper data synchronization mechanisms
- Handle partial failures and data inconsistency scenarios

**Service Communication Patterns:**
- Design resilient API contracts with versioning
- Implement circuit breakers and retry mechanisms
- Use asynchronous messaging for loose coupling
- Handle network partitions and service unavailability
- Implement proper timeout and bulkhead patterns

**Observability and Monitoring:**
- Implement distributed tracing across service boundaries
- Create comprehensive health checks and metrics
- Design centralized logging with correlation IDs
- Monitor service dependencies and cascade failures
- Implement alerting for distributed system anomalies

**Step 4: Implementation Safety Measures**
Critical safety protocols during decomposition:
- Implement feature flags for gradual service extraction
- Use strangler fig pattern for safe migration
- Maintain backward compatibility during transition
- Implement comprehensive integration testing
- Create rollback procedures for each decomposition step

**Data Migration and Consistency Protocol:**
- Analyze all data dependencies before service extraction
- Implement dual-write patterns for safe data migration
- Use event sourcing for audit trails and data synchronization
- Design proper data ownership boundaries
- Handle referential integrity across service boundaries

**Step 5: Microservice Quality Verification**
Continuous validation during decomposition:
- ZERO data loss or corruption during extraction
- Service isolation properly implemented and tested
- Communication patterns resilient to failures
- Performance requirements met with distributed architecture
- Operational complexity manageable and well-documented

**Microservice Decomposition Completion Criteria:**
✓ All identified service domains properly extracted and isolated
✓ Service communication patterns resilient and well-tested
✓ Data consistency mechanisms correctly implemented
✓ Distributed system patterns applied appropriately
✓ Service deployment and monitoring fully operational
✓ Performance requirements met or exceeded
✓ Operational procedures documented and validated
✓ Team ownership and responsibilities clearly defined

**Failure Response Protocol for Distributed Systems:**
When issues arise during microservice decomposition:
1. **IMMEDIATELY HALT** problematic service extraction
2. **SPAWN EMERGENCY AGENTS** to investigate and stabilize:
   ```
   "Service decomposition agent 2 caused data consistency issues. I'll spawn:
   - Agent 6: Investigate and resolve data inconsistency
   - Agent 7: Implement compensating transactions
   - Agent 8: Validate service communication resilience
   - Agent 9: Review and strengthen monitoring and alerting
   Let me resolve these critical issues before continuing decomposition..."
   ```
3. **ACTIVATE ROLLBACK** procedures if system integrity is compromised
4. **MAINTAIN SYSTEM AVAILABILITY** - never compromise user-facing functionality
5. **CONDUCT POST-INCIDENT** analysis and strengthen decomposition approach

**Parallel Decomposition Rules:**
- Agents work on independent service domains to minimize conflicts
- Clear API contracts defined upfront for inter-service communication
- Shared data migration strategies coordinated centrally
- Regular integration testing to ensure service compatibility
- Central monitoring of system health during decomposition

**Final Integration and Validation:**
After parallel service decomposition:
1. **VERIFY** all agents completed service extraction successfully
2. **VALIDATE** end-to-end functionality across service boundaries
3. **TEST** failure scenarios and recovery procedures
4. **MEASURE** performance and latency across distributed system
5. **CONFIRM** operational procedures and monitoring effectiveness
6. **DOCUMENT** service architecture and operational runbooks

**Final Commitment:**
I will now execute SYSTEMATIC microservice decomposition and IMPLEMENT ALL DISTRIBUTED SYSTEM PATTERNS. I will:
- ✅ Analyze all service boundaries and distributed system requirements
- ✅ SPAWN MULTIPLE AGENTS to decompose service domains in parallel
- ✅ Implement proper isolation, communication, and consistency patterns
- ✅ Keep working until distributed architecture is fully operational

I will NOT:
- ❌ Just identify service boundaries without implementing them
- ❌ Split services without addressing distributed system complexity
- ❌ Skip data consistency and transaction analysis
- ❌ Leave any distributed system concerns unaddressed
- ❌ Stop at "mostly decomposed"
- ❌ Compromise on system reliability or data integrity

**REMEMBER: This is a CRITICAL DISTRIBUTED ARCHITECTURE task with significant operational complexity!**

The system is properly decomposed ONLY when every distributed system concern is addressed and the microservice architecture is fully operational and resilient.

**Executing comprehensive microservice decomposition and IMPLEMENTING ALL DISTRIBUTED PATTERNS NOW...**