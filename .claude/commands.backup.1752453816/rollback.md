---
allowed-tools: all
description: Create comprehensive rollback plans and execute safe rollback procedures
---

# 🚨 CRITICAL ROLLBACK PROCEDURE EXECUTION 🚨

**THIS IS NOT A PLANNING TASK - THIS IS A ROLLBACK IMPLEMENTATION TASK!**

When you run `/rollback`, you are REQUIRED to:

1. **CREATE** comprehensive rollback plans and procedures
2. **IMPLEMENT SAFE ROLLBACK MECHANISMS** with data protection
3. **USE MULTIPLE AGENTS** to handle rollback complexity:
   - Spawn one agent for data migration reversals
   - Spawn another for application rollback procedures
   - Spawn agents for different services/components
   - Say: "I'll spawn multiple agents to execute safe rollback procedures in parallel"
4. **DO NOT STOP** until:
   - ✅ Complete rollback plan is documented and tested
   - ✅ Data migration reversals are safe and verified
   - ✅ Application rollback is tested in staging
   - ✅ Verification procedures are in place

**FORBIDDEN BEHAVIORS:**
- ❌ "Just revert the git commits" → NO! Need comprehensive data safety!
- ❌ "The rollback looks straightforward" → NO! Test it thoroughly!
- ❌ "Data migrations can't be reversed" → NO! Create safe procedures!
- ❌ Stopping after basic planning → NO! IMPLEMENT AND TEST!

**MANDATORY WORKFLOW:**
```
1. Analyze current state → Identify rollback scope
2. IMMEDIATELY spawn agents to create rollback procedures
3. Test rollback in staging → Validate all procedures
4. Document verification steps
5. REPEAT until rollback is completely safe and tested
```

**YOU ARE NOT DONE UNTIL:**
- Complete rollback procedures are documented
- Data rollback is tested and verified safe
- Application rollback works in staging environment
- All verification steps are automated or documented

---

🛑 **MANDATORY PRE-ROLLBACK CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Understand the scope and risks of rollback

Execute comprehensive rollback procedure for: $ARGUMENTS

**FORBIDDEN EXCUSE PATTERNS:**
- "Rollbacks are risky, let's move forward" → NO, create safe procedures
- "The data can't be rolled back" → NO, find a safe way
- "It's too complex to rollback" → NO, break it down systematically
- "We'll handle rollback manually if needed" → NO, automate it
- "Forward fixes are easier" → NO, prepare proper rollback anyway

Let me ultrathink about creating comprehensive, safe rollback procedures with zero data loss risk.

🚨 **REMEMBER: Data safety is paramount - never risk data corruption!** 🚨

**Safe Rollback Procedure Protocol:**

**Step 0: Rollback Scope Analysis**
- Identify all components affected by the change
- Map data dependencies and migration sequences
- Analyze configuration changes and feature flags
- Document current production state as baseline

**Step 1: Risk Assessment**
- Identify irreversible operations (data deletions, schema changes)
- Map external service integrations affected
- Assess downtime requirements and business impact
- Identify rollback complexity and dependencies

**Step 2: Data Safety Planning**
Run comprehensive data analysis:
- Create database backups before any rollback
- Design migration reversal scripts with validation
- Plan for data consistency checks
- Prepare data reconciliation procedures

**Critical Safety Requirements:**
- ZERO data loss during rollback procedures
- Maintain referential integrity at all times
- Preserve user data and transaction history
- Validate data consistency before and after
- Create audit trail of all rollback operations
- Test rollback procedures in staging first

**For Database Rollbacks specifically:**
- Create point-in-time recovery options
- Design reversible migration scripts
- Test schema downgrades thoroughly
- Validate foreign key constraints
- Preserve data relationships
- Plan for large dataset handling

**Step 3: Agent Spawning for Rollback Implementation**
When rollback procedures need implementation, spawn agents strategically:
```
"I need to create comprehensive rollback procedures for this deployment. I'll spawn agents to handle different aspects:
- Agent 1: Database migration reversal scripts and testing
- Agent 2: Application configuration rollback procedures
- Agent 3: External service integration rollback
- Agent 4: Feature flag and A/B test rollback
- Agent 5: Monitoring and verification automation
Let me tackle all of these rollback components in parallel..."
```

**Rollback Component Requirements:**
- [ ] Database schema rollback scripts tested and validated
- [ ] Data migration reversal procedures documented
- [ ] Application configuration rollback automated
- [ ] External service integration rollback planned
- [ ] Feature flag rollback procedures ready
- [ ] Cache invalidation and cleanup automated
- [ ] Load balancer and routing rollback ready

**Database Rollback Best Practices:**
- [ ] Create pre-rollback database snapshots
- [ ] Write and test migration DOWN scripts
- [ ] Validate rollback with production-like data
- [ ] Plan for zero-downtime rollback when possible
- [ ] Document data reconciliation procedures
- [ ] Test rollback performance with large datasets
- [ ] Prepare for partial rollback scenarios

**Application Rollback Guidelines:**
- Create staged rollback procedures (blue-green deployment)
- Plan for configuration rollback sequences
- Document service dependency rollback order
- Prepare for API version rollback scenarios
- Test rollback with real user sessions
- Validate external integrations after rollback

**Rollback Verification Strategy:**
Create comprehensive verification for:
1. **Data Integrity** (all data relationships preserved)
2. **Functional Verification** (all features work correctly)
3. **Performance Validation** (no performance degradation)
4. **Integration Testing** (external services work)
5. **User Experience** (no broken user flows)

**Failure Response Protocol:**
When rollback risks are identified:
1. **IMMEDIATELY SPAWN AGENTS** to address risks in parallel
2. **IMPLEMENT SAFETY MEASURES** - Add validation and checks
3. **TEST THOROUGHLY** - Validate in staging environment
4. **DOCUMENT EVERYTHING** - Create runbooks and procedures
5. **NO SHORTCUTS** - Don't skip safety validations
6. **ESCALATE SAFELY** - If rollback is too risky, document why

**Agent Task Distribution Patterns:**

**Pattern A: Component-Based Rollback**
```
Agent 1: Frontend application rollback (code, assets, configs)
Agent 2: Backend API rollback (services, middleware, routing)
Agent 3: Database rollback (schema, data, migrations)
Agent 4: Infrastructure rollback (containers, configs, secrets)
```

**Pattern B: Risk-Based Distribution**
```
Agent 1: High-risk data operations (irreversible changes)
Agent 2: Medium-risk application changes (configs, features)
Agent 3: Low-risk presentation changes (UI, styling)
Agent 4: Verification and validation automation
```

**Pattern C: Service-Based Rollback**
```
Agent 1: User service rollback (auth, profiles, sessions)
Agent 2: Order service rollback (processing, fulfillment)
Agent 3: Payment service rollback (transactions, billing)
Agent 4: Notification service rollback (emails, alerts)
```

**Rollback Testing Checklist:**
- [ ] Rollback procedures tested in staging environment
- [ ] Data migration reversals validated with test data
- [ ] Performance impact of rollback measured
- [ ] User experience validated post-rollback
- [ ] External integrations tested after rollback
- [ ] Monitoring and alerting works correctly
- [ ] Rollback timing and downtime measured
- [ ] Recovery procedures documented and tested

**Emergency Rollback Procedures:**
- Document fast rollback for critical issues
- Create automated rollback triggers and alerts
- Prepare communication templates for stakeholders
- Plan for partial rollback scenarios
- Document decision criteria for emergency rollback
- Test emergency procedures regularly

**Final Rollback Verification:**
The rollback procedures are complete when:
✓ All rollback scripts are tested and validated
✓ Data safety is guaranteed with backups and validation
✓ Staging environment rollback test passes completely
✓ Verification procedures are automated or documented
✓ Emergency rollback procedures are ready
✓ All stakeholders understand rollback impact

**Final Commitment:**
I will now create and implement comprehensive rollback procedures and TEST EVERYTHING. I will:
- ✅ Analyze rollback scope and create detailed procedures
- ✅ SPAWN MULTIPLE AGENTS to implement rollback components
- ✅ Keep working until rollback is completely tested and safe
- ✅ Not stop until all verification procedures are in place

I will NOT:
- ❌ Just document rollback steps without testing them
- ❌ Skip data safety validations
- ❌ Accept "probably works" rollback procedures
- ❌ Stop at partial rollback implementation
- ❌ Ignore complex data migration reversals
- ❌ Stop working while ANY rollback risks remain

**REMEMBER: This is a ROLLBACK IMPLEMENTATION task, not a documentation task!**

The rollback is ready ONLY when all procedures are tested, validated, and guaranteed safe for production use.

**Executing comprehensive rollback procedure creation and TESTING ALL PROCEDURES NOW...**