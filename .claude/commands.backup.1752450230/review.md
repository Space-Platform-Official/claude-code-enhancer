---
allowed-tools: all
description: Comprehensive code review command
---

# 🔍🔍🔍 CRITICAL REQUIREMENT: COMPREHENSIVE CODE REVIEW! 🔍🔍🔍

**THIS IS NOT A SUPERFICIAL SCAN - THIS IS A THOROUGH REVIEW TASK!**

When you run `/review`, you are REQUIRED to:

1. **ANALYZE** all changes against team standards comprehensively
2. **EVALUATE** performance, security, and quality thoroughly
3. **VERIFY** test coverage for all changes
4. **PROVIDE** actionable improvement suggestions
5. **USE MULTIPLE AGENTS** for parallel review:
   - Spawn one agent for performance analysis
   - Spawn another for security audit
   - Spawn more agents for different modules/files
   - Say: "I'll spawn multiple agents to review different aspects in parallel"
6. **DO NOT STOP** until:
   - ✅ ALL code meets quality standards
   - ✅ ALL security vulnerabilities addressed
   - ✅ ALL performance issues identified
   - ✅ COMPLETE review documentation provided

**FORBIDDEN BEHAVIORS:**
- ❌ "Code looks good overall" → NO! Deep dive into details!
- ❌ "No obvious issues" → NO! Find the non-obvious ones!
- ❌ "Tests seem adequate" → NO! Verify coverage and quality!
- ❌ Surface-level review → NO! Comprehensive analysis required!

**MANDATORY WORKFLOW:**
```
1. Analyze changes → Identify all modifications
2. IMMEDIATELY spawn agents for parallel review
3. Deep dive into each area → Find all issues
4. Consolidate findings → Create actionable report
5. REPEAT for any missed areas
```

**YOU ARE NOT DONE UNTIL:**
- All code paths have been analyzed
- All security implications assessed
- All performance impacts evaluated
- All test coverage verified
- Complete review report generated

---

🛑 **MANDATORY PRE-REVIEW CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify you understand the scope of changes

Execute comprehensive code review with ZERO tolerance for shortcuts.

**FORBIDDEN EXCUSE PATTERNS:**
- "This looks fine at first glance" → NO, deep analysis required
- "Most of the code is straightforward" → NO, review ALL code
- "The tests should catch issues" → NO, review the tests too
- "It follows existing patterns" → NO, verify those patterns are correct
- "The author is experienced" → NO, everyone's code needs review

Let me ultrathink about performing a comprehensive review of these changes.

🚨 **REMEMBER: Every line matters for code quality!** 🚨

**Comprehensive Code Review Protocol:**

**Step 0: Change Analysis**
$ARGUMENTS

- Understand the scope and nature of all changes
- Identify affected systems and dependencies
- Review commit messages and PR descriptions
- Check for any breaking changes or migrations

**Step 1: Architecture Review**
- Evaluate design decisions and patterns used
- Check for adherence to SOLID principles
- Verify proper separation of concerns
- Assess maintainability and extensibility
- Review API design and interface contracts

**Step 2: Security Analysis**
- [ ] Input validation on all external data
- [ ] SQL injection prevention (prepared statements)
- [ ] XSS prevention in web interfaces
- [ ] Authentication and authorization checks
- [ ] Secrets management (no hardcoded credentials)
- [ ] Rate limiting and DoS protection
- [ ] Data sanitization and encoding
- [ ] Privilege escalation prevention
- [ ] HTTPS enforcement where applicable
- [ ] Dependency vulnerability scan

**Step 3: Performance Evaluation**
- [ ] Algorithm complexity analysis
- [ ] Database query optimization
- [ ] Memory usage patterns
- [ ] CPU-intensive operations review
- [ ] Network I/O efficiency
- [ ] Caching strategy evaluation
- [ ] Concurrency and thread safety
- [ ] Resource leak prevention
- [ ] Scalability considerations

**For Go Code Specifically:**
- [ ] No interface{} or any{} usage
- [ ] Proper error handling and wrapping
- [ ] Goroutine lifecycle management
- [ ] Channel usage patterns
- [ ] Context propagation
- [ ] Race condition prevention
- [ ] Memory allocation patterns
- [ ] GC pressure considerations

**Step 4: Code Quality Assessment**
- [ ] Readability and maintainability
- [ ] Naming conventions and clarity
- [ ] Function/method size and complexity
- [ ] Code duplication analysis
- [ ] Comment quality and necessity
- [ ] Error handling completeness
- [ ] Logging and observability
- [ ] Configuration management
- [ ] Documentation completeness

**Step 5: Test Coverage Verification**
- [ ] Unit test completeness for business logic
- [ ] Integration test coverage
- [ ] Edge case handling in tests
- [ ] Error path testing
- [ ] Mock usage appropriateness
- [ ] Test data management
- [ ] Test performance and flakiness
- [ ] End-to-end test coverage
- [ ] Load/stress test considerations

**Step 6: Dependencies and Integration**
- [ ] New dependency justification
- [ ] Version compatibility checks
- [ ] License compliance
- [ ] Security vulnerability in dependencies
- [ ] Breaking changes in updates
- [ ] Integration point validation
- [ ] API contract compliance
- [ ] Backward compatibility preservation

**Parallel Review Strategy:**
When conducting the review, spawn multiple agents:
1. **Security Agent**: Focus on security implications and vulnerabilities
2. **Performance Agent**: Analyze performance characteristics and bottlenecks
3. **Testing Agent**: Evaluate test coverage and quality
4. **Architecture Agent**: Review design patterns and code organization
5. **Documentation Agent**: Assess documentation and code clarity

**Review Report Structure:**

**Critical Issues (Must Fix):**
- Security vulnerabilities
- Performance bottlenecks
- Breaking changes
- Test coverage gaps

**Important Issues (Should Fix):**
- Code quality improvements
- Architecture concerns
- Documentation gaps
- Minor performance optimizations

**Suggestions (Nice to Have):**
- Refactoring opportunities
- Additional tests
- Code style improvements
- Future considerations

**Actionable Recommendations:**
For each issue identified, provide:
- Clear description of the problem
- Why it matters (impact)
- Specific fix recommendations
- Code examples where helpful
- Priority level (Critical/Important/Suggestion)

**Final Verification:**
The review is complete when:
✓ All code changes thoroughly analyzed
✓ Security implications fully assessed
✓ Performance impact evaluated
✓ Test coverage verified and documented
✓ All findings documented with actionable recommendations
✓ Priority levels assigned to all issues
✓ No stone left unturned

**Final Commitment:**
I will now execute EVERY review step listed above and provide comprehensive analysis. I will:
- ✅ Analyze every line of changed code
- ✅ SPAWN MULTIPLE AGENTS for parallel review aspects
- ✅ Identify all security, performance, and quality issues
- ✅ Provide detailed, actionable recommendations
- ✅ Create a complete review report

I will NOT:
- ❌ Perform superficial review
- ❌ Skip any review categories
- ❌ Accept "good enough" code
- ❌ Miss security or performance issues
- ❌ Provide vague feedback
- ❌ Leave any aspect unreviewed

**REMEMBER: This is a COMPREHENSIVE REVIEW task, not a quick scan!**

The review is complete ONLY when every aspect shows thorough analysis.

**Executing comprehensive code review NOW...**