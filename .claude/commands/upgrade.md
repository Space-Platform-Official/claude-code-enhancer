---
allowed-tools: all
description: Systematically upgrade dependencies with comprehensive risk assessment and regression testing
---

# ⬆️⬆️⬆️ CRITICAL REQUIREMENT: ANALYZE BREAKING CHANGES! ⬆️⬆️⬆️

**THIS IS NOT A BLIND UPDATE TASK - THIS IS A RISK-ASSESSED MIGRATION TASK!**

When you run `/upgrade`, you are REQUIRED to:

1. **ANALYZE BREAKING CHANGES** - Review changelogs and migration guides thoroughly
2. **CREATE RISK ASSESSMENT** - Categorize changes by impact and complexity  
3. **DEVELOP UPGRADE PLAN** - Systematic approach with rollback strategies
4. **USE MULTIPLE AGENTS** to handle different package upgrades in parallel:
   - Spawn one agent for major version upgrades
   - Spawn another for security patches
   - Spawn more agents for different dependency categories
   - Say: "I'll spawn multiple agents to handle different package upgrades in parallel"
5. **TEST COMPREHENSIVELY** - Run full regression test suite after each upgrade
6. **VALIDATE FUNCTIONALITY** - Ensure all features work exactly as before
7. **DOCUMENT CHANGES** - Record upgrade rationale and potential impacts

**FORBIDDEN BEHAVIORS:**
- ❌ "Let me update everything to latest" → NO! ASSESS IMPACT FIRST!
- ❌ "Dependencies look outdated" → NO! ANALYZE BREAKING CHANGES!
- ❌ "This should be a simple update" → NO! PLAN SYSTEMATICALLY!
- ❌ Upgrading without testing → NO! VALIDATE EVERYTHING!

**MANDATORY WORKFLOW:**
```
1. Audit → Identify outdated dependencies and security issues
2. IMMEDIATELY spawn agents for different upgrade categories  
3. Analyze → Review breaking changes and migration requirements
4. Plan → Create systematic upgrade strategy with risk assessment
5. Upgrade → Implement changes incrementally with testing
6. REPEAT until all dependencies are current and secure
```

**YOU ARE NOT DONE UNTIL:**
- All security vulnerabilities resolved
- Breaking changes properly addressed
- Full regression test suite passes
- All functionality verified working

---

🛑 **MANDATORY DEPENDENCY UPGRADE PROTOCOL** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify you're analyzing impact, not blindly updating

Execute systematic dependency upgrade for: $ARGUMENTS

**FORBIDDEN UPGRADE PATTERNS:**
- "Latest version should work fine" → NO, check breaking changes first
- "Security updates are always safe" → NO, test thoroughly after applying
- "Minor version bumps can't break anything" → NO, analyze changelog first  
- "The build passes so it's fine" → NO, run comprehensive tests
- "Dependencies automatically update" → NO, control upgrade process manually

Let me ultrathink about the systematic dependency upgrade strategy for this project.

🚨 **REMEMBER: Dependency upgrades can introduce subtle bugs - Test everything!** 🚨

**Dependency Upgrade Protocol:**

**Step 0: Dependency Audit and Risk Assessment**
- Run dependency vulnerability scanners (npm audit, go mod audit, etc.)
- Identify outdated packages and their current vs latest versions
- Categorize dependencies: security-critical, major version changes, minor updates
- Document current dependency tree and potential conflict areas

**Step 1: Breaking Change Analysis**
- Review CHANGELOG.md and migration guides for each major upgrade
- Identify API changes, deprecated features, and removed functionality
- Check for compatibility issues between upgraded dependencies
- Assess impact on existing codebase and third-party integrations

**Step 2: Systematic Upgrade Strategy**
Plan upgrades in order of risk and dependency:
- Critical security patches first (immediate priority)
- Major version upgrades requiring code changes (planned approach)
- Minor version updates and patch releases (lower risk batch)
- Development dependencies and tooling updates (separate from production deps)

**Upgrade Quality Requirements:**
- EVERY upgrade must include comprehensive testing
- EVERY major version change must include migration planning
- ZERO functionality regressions - behavior must remain identical
- Breaking changes must be explicitly addressed with code modifications
- Security patches applied within defined SLA timeframes

**For specific ecosystems:**

**Go projects:**
- Use go mod tidy to clean up unused dependencies
- Run go mod audit or govulncheck for security scanning
- Check for module compatibility and replace directives
- Test with go test -race to catch concurrency issues
- Verify build reproducibility with consistent module versions

**Node.js/npm projects:**
- Use npm audit or yarn audit for vulnerability scanning
- Check package-lock.json or yarn.lock for dependency conflicts
- Test with npm ci for clean installation verification
- Run comprehensive test suites including integration tests
- Verify production bundle size hasn't significantly increased

**Python projects:**
- Use pip-audit or safety for security vulnerability scanning
- Check requirements.txt or Pipfile for version constraints
- Test in clean virtual environment to catch missing dependencies
- Run full test suite including compatibility tests
- Verify package compatibility matrix for major upgrades

**Step 3: Incremental Upgrade Execution**
Implement upgrades systematically:
- Start with security patches and critical vulnerabilities
- Upgrade dependencies one category at a time
- Test thoroughly after each upgrade batch
- Rollback immediately if issues detected
- Document any code changes required for compatibility

**Breaking Change Migration Checklist:**
- [ ] All breaking changes identified from changelogs
- [ ] Migration guides reviewed and followed
- [ ] Deprecated API usage updated to current standards
- [ ] Function signatures and return types verified
- [ ] Configuration file formats updated if needed
- [ ] Build scripts and tooling configurations updated
- [ ] Third-party integrations tested for compatibility

**Security and Stability Verification:**
- [ ] All known security vulnerabilities patched
- [ ] No new security issues introduced by upgrades
- [ ] Dependency conflicts resolved properly
- [ ] Build reproducibility maintained
- [ ] Production deployment process tested
- [ ] Rollback procedures documented and tested
- [ ] Performance impact assessed and acceptable

**Comprehensive Testing Requirements:**
- [ ] Unit tests pass for all upgraded components
- [ ] Integration tests verify cross-component compatibility
- [ ] End-to-end tests validate full application workflows
- [ ] Performance tests show no significant degradation
- [ ] Security tests confirm vulnerability remediation
- [ ] Compatibility tests with external services/APIs
- [ ] Load tests verify system stability under production conditions

**Upgrade Documentation and Monitoring:**
- [ ] Upgrade rationale documented with business justification
- [ ] Breaking changes and mitigation strategies recorded
- [ ] Version compatibility matrix updated
- [ ] Rollback procedures tested and documented
- [ ] Monitoring configured for post-upgrade issues
- [ ] Team notified of changes affecting their work areas
- [ ] Production deployment plan includes gradual rollout strategy

**Failure Response Protocol:**
When upgrade issues are found:
1. **IMMEDIATELY SPAWN AGENTS** to handle different upgrade categories in parallel:
   ```
   "Dependency audit revealed 12 outdated packages: 3 with security vulnerabilities,
   4 major version upgrades with breaking changes, and 5 minor updates.
   I'll spawn agents to handle these systematically:
   - Agent 1: Apply critical security patches for packages A, B, C
   - Agent 2: Plan and execute major version upgrades for packages D, E, F, G
   - Agent 3: Handle minor version updates for packages H, I, J, K, L
   Let me tackle these upgrade categories in parallel..."
   ```
2. **ANALYZE SYSTEMATICALLY** - Review breaking changes and plan migration approach
3. **TEST THOROUGHLY** - Run comprehensive test suite after each upgrade
4. **ROLLBACK IF NEEDED** - Immediately revert problematic upgrades
5. **REPEAT** - Continue upgrading until all dependencies are current and secure
6. **NO SHORTCUTS** - Every upgrade decision backed by analysis and testing
7. **ESCALATE** - Only ask for help if blocked after attempting systematic migration

**Final Upgrade Verification:**
The upgrade is complete when:
✓ All security vulnerabilities resolved with patches applied
✓ All major version upgrades completed with breaking changes addressed
✓ ALL test suites pass with zero functionality regressions
✓ Performance benchmarks show no significant degradation
✓ Production deployment tested with rollback procedures verified
✓ Documentation updated with upgrade details and compatibility notes

**Final Commitment:**
I will now execute EVERY upgrade step listed above and VALIDATE ALL CHANGES. I will:
- ✅ Audit dependencies to identify security issues and outdated packages
- ✅ SPAWN MULTIPLE AGENTS to handle different upgrade categories in parallel
- ✅ Analyze breaking changes and plan migration systematically
- ✅ Test comprehensively after every upgrade to ensure functionality
- ✅ Not stop until all dependencies are secure and current

I will NOT:
- ❌ Upgrade dependencies without impact analysis
- ❌ Skip testing after applying updates
- ❌ Ignore breaking changes or migration guides
- ❌ Apply upgrades without rollback planning
- ❌ Stop at "builds successfully"
- ❌ Rush through security patches without testing

**REMEMBER: This is a SYSTEMATIC MIGRATION task, not a bulk update task!**

The upgrade is complete ONLY when every dependency is secure, current, and fully tested.

**Executing systematic dependency upgrade with comprehensive risk assessment NOW...**