---
allowed-tools: all
description: Database/API/Framework migration with rollback safety and comprehensive testing
---

# 🚀🚀🚀 CRITICAL REQUIREMENT: SAFE MIGRATION ONLY! 🚀🚀🚀

**THIS IS NOT A SIMPLE UPDATE TASK - THIS IS A COMPREHENSIVE MIGRATION TASK!**

When you run `/migrate`, you are REQUIRED to:

1. **ANALYZE** current system and migration requirements thoroughly
2. **PLAN** migration phases with rollback strategies at each step
3. **USE MULTIPLE AGENTS** to handle independent migration components:
   - Spawn one agent for database schema migrations
   - Spawn another for API endpoint migrations
   - Spawn more agents for different services/components
   - Say: "I'll spawn multiple agents to handle these migration phases in parallel"
4. **TEST** extensively at each migration phase
5. **DO NOT STOP** until:
   - ✅ ALL migration phases complete successfully
   - ✅ ALL tests pass in the new environment
   - ✅ Rollback procedures are verified and documented
   - ✅ Performance meets or exceeds baseline

**FORBIDDEN BEHAVIORS:**
- ❌ "Migration plan looks good" → NO! EXECUTE THE MIGRATION!
- ❌ "This should work in production" → NO! PROVE IT WORKS!
- ❌ "Rollback might be needed" → NO! HAVE ROLLBACK READY!
- ❌ Starting migration without safety nets → NO! PREPARE SAFETY FIRST!

**MANDATORY WORKFLOW:**
```
1. Analyze current state → Plan migration phases
2. IMMEDIATELY spawn agents for parallel migration components
3. Execute Phase 1 → Test → Verify rollback capability
4. Execute Phase 2 → Test → Verify rollback capability
5. REPEAT until migration is complete and validated
```

**YOU ARE NOT DONE UNTIL:**
- All migration phases are complete and tested
- Rollback procedures are documented and verified
- Performance benchmarks meet requirements
- All stakeholders can use the new system
- Zero data loss and zero downtime achieved

---

🛑 **MANDATORY MIGRATION PLANNING** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify migration scope and dependencies

Execute comprehensive migration: $ARGUMENTS

**FORBIDDEN EXCUSE PATTERNS:**
- "Migration seems too complex" → NO, break it into manageable phases
- "Current system works fine" → NO, execute the required migration
- "This might cause downtime" → NO, design zero-downtime migration
- "Rollback procedures are obvious" → NO, document and test rollbacks
- "Testing can be done later" → NO, test at every phase

Let me ultrathink about this migration to ensure zero-downtime and comprehensive safety.

🚨 **REMEMBER: Data integrity and system availability are non-negotiable!** 🚨

**Comprehensive Migration Protocol:**

**Step 0: Pre-Migration Assessment**
- Document current system state and dependencies
- Create complete backup and recovery procedures
- Establish performance baseline metrics
- Identify all integration points and external dependencies
- Map data flow and critical business processes

**Migration Assessment Checklist:**
- [ ] Current version and compatibility requirements documented
- [ ] All dependencies identified and version-checked
- [ ] Database schema and data volume analyzed
- [ ] API contracts and breaking changes catalogued
- [ ] Performance bottlenecks and optimization opportunities mapped
- [ ] Security implications and access patterns reviewed
- [ ] Monitoring and alerting systems prepared
- [ ] Rollback decision criteria defined
- [ ] Success criteria and acceptance tests outlined

**Step 1: Migration Architecture Design**
Plan migration with parallel execution capabilities:
- **Phase 1**: Infrastructure and environment preparation
- **Phase 2**: Database schema evolution with backward compatibility
- **Phase 3**: API and service layer migration
- **Phase 4**: Frontend and client application updates
- **Phase 5**: Performance optimization and cleanup

**Universal Migration Patterns:**
- Blue-Green Deployment: Run old and new systems in parallel
- Rolling Updates: Gradual replacement of system components
- Database Migration: Schema evolution with data preservation
- API Versioning: Maintain compatibility during transition
- Feature Flags: Control rollout and enable quick rollback
- Canary Releases: Test with subset of users/traffic

**Step 2: Parallel Agent Deployment**
Spawn specialized migration agents:
```
"I found multiple migration components requiring parallel execution. I'll spawn agents:
- Agent 1: Database schema migration with backward compatibility
- Agent 2: API endpoint migration and versioning strategy
- Agent 3: Service layer migration and dependency updates
- Agent 4: Frontend/client application migration
- Agent 5: Data migration and integrity verification
Let me execute these migration phases in parallel with safety checks..."
```

**Migration-Specific Safety Guidelines:**

**For Database Migrations:**
- Use additive-only schema changes initially
- Maintain backward compatibility during transition
- Implement comprehensive data validation
- Create automated rollback scripts for each migration
- Monitor query performance during and after migration
- Use connection pooling and query optimization
- Implement proper indexing strategies for new schema

**For API/Framework Migrations:**
- Maintain multiple API versions during transition
- Use adapter patterns for compatibility layers
- Implement comprehensive integration testing
- Create automated contract testing
- Monitor API response times and error rates
- Use circuit breakers for resilience
- Document all breaking changes with migration guides

**Step 3: Migration Execution Phases**

**Phase 1: Infrastructure Preparation (Parallel)**
```
Agent 1: Environment setup and configuration
Agent 2: Monitoring and alerting system preparation
Agent 3: Backup and recovery system validation
Agent 4: Security and access control migration
```

**Phase 2: Database Migration (Sequential with Testing)**
```
Agent 1: Schema migration with backward compatibility
Agent 2: Data migration with integrity checks
Agent 3: Index optimization and performance tuning
Agent 4: Backup verification and rollback testing
```

**Phase 3: Service Layer Migration (Parallel)**
```
Agent 1: Core business logic migration
Agent 2: Integration layer and external API updates
Agent 3: Authentication and authorization migration
Agent 4: Caching and performance layer updates
```

**Phase 4: Client Migration (Parallel)**
```
Agent 1: Frontend application migration
Agent 2: Mobile application updates
Agent 3: Third-party integration updates
Agent 4: Documentation and user guide updates
```

**Step 4: Safety and Rollback Procedures**
For each migration phase:
- Create automated rollback scripts
- Test rollback procedures in staging environment
- Define rollback decision criteria and triggers
- Implement automated health checks and monitoring
- Prepare communication plan for stakeholders

**Rollback Safety Protocol:**
- **Immediate Rollback Triggers**: System errors, data corruption, performance degradation >20%
- **Gradual Rollback**: Feature flags to disable new functionality
- **Data Rollback**: Point-in-time recovery with minimal data loss
- **Service Rollback**: Blue-green switch or rolling deployment reversal
- **Communication**: Automated alerts and stakeholder notifications

**Step 5: Testing and Validation**
Comprehensive testing at each phase:
- Unit tests for all migrated components
- Integration tests for system interactions
- Performance tests against baseline metrics
- Security tests for access control and data protection
- End-to-end tests for critical business processes
- Load tests for production-scale validation

**Migration Testing Checklist:**
- [ ] All existing functionality works in new system
- [ ] New features function as specified
- [ ] Performance meets or exceeds baseline
- [ ] Security controls are properly implemented
- [ ] Data integrity is maintained throughout
- [ ] Rollback procedures work correctly
- [ ] Monitoring and alerting systems function
- [ ] External integrations remain functional

**Step 6: Performance and Optimization**
Post-migration optimization:
- Monitor system performance under production load
- Optimize database queries and indexing
- Tune application and infrastructure settings
- Implement caching strategies for improved performance
- Clean up deprecated code and temporary migration artifacts

**Migration Completion Criteria:**
✓ All migration phases executed successfully
✓ Zero data loss or corruption
✓ Performance meets or exceeds baseline metrics
✓ All tests pass in production environment
✓ Rollback procedures documented and verified
✓ Stakeholder acceptance criteria met
✓ Monitoring and alerting systems operational
✓ Documentation updated and distributed

**Failure Response Protocol:**
When issues arise during migration:
1. **IMMEDIATELY ASSESS** impact and severity
2. **EXECUTE ROLLBACK** if criteria are met
3. **SPAWN ADDITIONAL AGENTS** to investigate and resolve:
   ```
   "Migration phase 2 encountered data integrity issues. I'll spawn:
   - Agent 6: Investigate data corruption and repair
   - Agent 7: Validate rollback procedures and execute if needed
   - Agent 8: Review migration scripts for bugs
   - Agent 9: Implement additional safety checks
   Let me resolve these critical issues immediately..."
   ```
4. **COMMUNICATE** status to stakeholders
5. **DOCUMENT** issues and resolution steps
6. **RESUME** migration only after issues are resolved

**Parallel Migration Rules:**
- Independent components can be migrated simultaneously
- Dependent components must wait for prerequisites
- Shared resources require coordination between agents
- Regular synchronization to ensure system consistency
- Central monitoring for overall migration health

**Final Integration and Validation:**
After parallel migration phases:
1. **VERIFY** all agents completed successfully
2. **INTEGRATE** all migration components
3. **RUN** comprehensive end-to-end tests
4. **BENCHMARK** performance against baseline
5. **VALIDATE** all business processes function correctly
6. **CLEANUP** temporary migration artifacts
7. **DOCUMENT** final system state and changes

**Post-Migration Monitoring:**
- Continuous monitoring for 72 hours minimum
- Performance trend analysis
- Error rate and system health tracking
- User feedback and issue reporting
- Rollback readiness maintained for defined period

**Final Commitment:**
I will now execute COMPREHENSIVE migration with ZERO data loss and MINIMAL downtime. I will:
- ✅ Analyze current state and plan all migration phases
- ✅ SPAWN MULTIPLE AGENTS to handle parallel components
- ✅ Test extensively at each phase with rollback verification
- ✅ Keep working until ALL migration requirements are met

I will NOT:
- ❌ Just plan migration without executing it
- ❌ Skip safety measures or rollback preparation
- ❌ Accept any data loss or corruption
- ❌ Proceed without proper testing
- ❌ Stop at "mostly migrated"
- ❌ Ignore performance or availability requirements

**REMEMBER: This is a COMPLETE SYSTEM MIGRATION task, not a simple update task!**

The migration is complete ONLY when every component is successfully migrated, tested, and validated with rollback capabilities proven.

**Executing comprehensive migration with ZERO data loss and MAXIMUM safety NOW...**