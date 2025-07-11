---
allowed-tools: all
description: Comprehensive security vulnerability scanning and hardening workflow
---

# 🔒🔒🔒 CRITICAL SECURITY REQUIREMENT: IDENTIFY AND FIX ALL VULNERABILITIES! 🔒🔒🔒

**THIS IS NOT A REPORTING TASK - THIS IS A SECURITY HARDENING TASK!**

When you run `/security-audit`, you are REQUIRED to:

1. **IDENTIFY** all security vulnerabilities, misconfigurations, and risks
2. **FIX EVERY SINGLE ONE** - not just report them!
3. **USE MULTIPLE AGENTS** to tackle security domains in parallel:
   - Spawn one agent for OWASP Top 10 analysis
   - Spawn another for dependency vulnerability scanning
   - Spawn more agents for specific attack vectors
   - Say: "I'll spawn multiple security agents to audit all attack surfaces in parallel"
4. **DO NOT STOP** until:
   - ✅ ALL critical and high vulnerabilities are patched
   - ✅ Security configurations are hardened
   - ✅ Authentication and authorization are bulletproof
   - ✅ EVERYTHING passes security validation

**FORBIDDEN BEHAVIORS:**
- ❌ "Here are the vulnerabilities I found" → NO! PATCH THEM!
- ❌ "The scanner reports these issues" → NO! RESOLVE THEM!
- ❌ "This could be exploited by..." → NO! PREVENT THE EXPLOITATION!
- ❌ Stopping after listing vulnerabilities → NO! KEEP WORKING!

**MANDATORY WORKFLOW:**
```
1. Run security scans → Find vulnerabilities
2. IMMEDIATELY spawn agents to fix ALL critical/high issues
3. Re-run scans → Find remaining issues
4. Fix those too
5. REPEAT until EVERYTHING is secure
```

**YOU ARE NOT DONE UNTIL:**
- All critical and high vulnerabilities are resolved
- All security misconfigurations are fixed
- All dependencies are updated to secure versions
- Everything shows secure/passing status

---

🛑 **MANDATORY SECURITY ASSESSMENT** 🛑

Execute comprehensive security analysis with security target: $ARGUMENTS

🚨 **REMEMBER: Security vulnerabilities can lead to data breaches and system compromise!** 🚨

**Universal Security Audit Protocol:**

**Step 0: Security Baseline Assessment**
- Run OWASP ZAP or similar security scanner if available
- Check for common security configuration files (.htaccess, security.txt, etc.)
- Analyze current security posture and threat model

**Step 1: OWASP Top 10 Analysis**
Systematically check for each OWASP Top 10 vulnerability:

1. **A01 Broken Access Control**
   - Verify authorization checks on all protected resources
   - Test for privilege escalation vulnerabilities
   - Check for missing function-level access controls
   - Validate direct object reference protections

2. **A02 Cryptographic Failures**
   - Audit all cryptographic implementations
   - Verify strong encryption algorithms (AES-256, RSA-2048+)
   - Check for hardcoded secrets and weak random number generation
   - Validate certificate configurations and TLS settings

3. **A03 Injection Attacks**
   - SQL injection prevention (parameterized queries)
   - NoSQL injection protection
   - Command injection safeguards
   - LDAP and XML injection prevention

4. **A04 Insecure Design**
   - Review authentication and session management
   - Validate business logic security
   - Check for security design flaws
   - Assess threat modeling coverage

5. **A05 Security Misconfiguration**
   - Audit security headers (CSP, HSTS, X-Frame-Options)
   - Check for default credentials
   - Validate error handling (no sensitive data exposure)
   - Review server/framework configurations

6. **A06 Vulnerable Components**
   - Scan dependencies for known CVEs
   - Update outdated libraries and frameworks
   - Remove unused dependencies
   - Monitor security advisories

7. **A07 Authentication Failures**
   - Test password policies and complexity
   - Verify account lockout mechanisms
   - Check for brute force protections
   - Validate multi-factor authentication

8. **A08 Software Integrity Failures**
   - Verify digital signatures and checksums
   - Check for supply chain security
   - Validate auto-update mechanisms
   - Review CI/CD pipeline security

9. **A09 Logging Failures**
   - Ensure comprehensive security logging
   - Validate log integrity and monitoring
   - Check for sensitive data in logs
   - Test incident response capabilities

10. **A10 Server-Side Request Forgery**
    - Test for SSRF vulnerabilities
    - Validate URL filtering and whitelisting
    - Check network segmentation
    - Verify input validation for URLs

**Step 2: Dependency Vulnerability Scanning**
Run comprehensive dependency checks:
- `npm audit` for Node.js projects
- `pip-audit` for Python projects
- `govulncheck` for Go projects
- `bundle audit` for Ruby projects
- Manual CVE database checks for critical components

**Step 3: Authentication & Authorization Audit**
Verify security controls:
- [ ] Strong password requirements enforced
- [ ] Multi-factor authentication implemented
- [ ] Session management is secure (timeouts, regeneration)
- [ ] Authorization checks on all endpoints
- [ ] No privilege escalation vulnerabilities
- [ ] JWT tokens properly validated and secured

**Step 4: Input Validation & Output Encoding**
Check data handling security:
- [ ] All user inputs are validated and sanitized
- [ ] Output encoding prevents XSS attacks
- [ ] File upload restrictions and validation
- [ ] Size limits prevent DoS attacks
- [ ] SQL/NoSQL queries use parameterization

**Step 5: Security Configuration Audit**
Validate hardening measures:
- [ ] Security headers properly configured
- [ ] HTTPS enforced everywhere (HSTS)
- [ ] Cookie security flags set
- [ ] CORS policies restrictive and appropriate
- [ ] Error messages don't leak sensitive information
- [ ] Debug mode disabled in production

**Step 6: Network Security Analysis**
Check network-level protections:
- [ ] TLS configuration is strong (TLS 1.2+)
- [ ] Certificate validation is strict
- [ ] Network timeouts configured appropriately
- [ ] Rate limiting implemented
- [ ] Firewall rules are restrictive

**Language-Specific Security Requirements:**

**For ALL languages:**
- Use security-focused linters (semgrep, CodeQL)
- Follow OWASP coding guidelines
- Implement security unit tests
- Use static analysis security testing (SAST)

**For Go specifically:**
- Use `gosec` security scanner
- Avoid `fmt.Sprintf` for SQL queries - use parameterized queries
- Use `crypto/rand` not `math/rand` for cryptographic operations
- Validate all external inputs with proper type checking
- Use context.Context for request cancellation and timeouts
- Implement proper error handling without information disclosure

**For JavaScript/Node.js:**
- Use ESLint security plugins
- Implement helmet.js for security headers
- Use bcrypt for password hashing
- Validate with joi/yup schemas
- Use CSRF protection
- Implement rate limiting with express-rate-limit

**For Python:**
- Use bandit security scanner
- Implement proper password hashing with bcrypt/argon2
- Use parameterized queries with SQLAlchemy
- Validate inputs with marshmallow/pydantic
- Use secure session management
- Implement CSRF protection

**Step 7: Specialized Security Agents**
When vulnerabilities are found, IMMEDIATELY spawn specialized agents:

```
"I found 12 security issues across different attack vectors. I'll spawn security agents:
- Agent 1: Fix authentication and session management vulnerabilities
- Agent 2: Patch injection vulnerabilities and implement input validation
- Agent 3: Update vulnerable dependencies and fix CVEs
- Agent 4: Implement missing security headers and configurations
- Agent 5: Fix authorization and access control issues
Let me tackle all of these security issues in parallel..."
```

**Critical Vulnerability Response Protocol:**
1. **CRITICAL (CVSS 9.0+)**: Fix immediately, no exceptions
2. **HIGH (CVSS 7.0-8.9)**: Fix before proceeding with other tasks
3. **MEDIUM (CVSS 4.0-6.9)**: Fix during current session
4. **LOW (CVSS 0.1-3.9)**: Document and schedule for next security review

**Security Testing Requirements:**
- [ ] Penetration testing scenarios executed
- [ ] Security unit tests cover all auth/authz paths
- [ ] Input fuzzing tests for all external interfaces
- [ ] Error handling tests don't leak sensitive data
- [ ] Performance tests under attack simulation

**Final Security Verification:**
The system is security-ready when:
✓ All OWASP Top 10 vulnerabilities addressed
✓ All critical and high CVEs patched
✓ Security scanners show zero critical/high issues
✓ Authentication and authorization thoroughly tested
✓ Input validation and output encoding complete
✓ Security configurations hardened
✓ Security monitoring and logging implemented

**Final Security Commitment:**
I will now execute EVERY security check listed above and FIX ALL VULNERABILITIES. I will:
- ✅ Run comprehensive security scans to identify all vulnerabilities
- ✅ SPAWN MULTIPLE SECURITY AGENTS to fix issues in parallel
- ✅ Keep working until ALL critical and high vulnerabilities are resolved
- ✅ Not stop until all security checks show passing status

I will NOT:
- ❌ Just report vulnerabilities without fixing them
- ❌ Skip any security checks
- ❌ Rationalize away security issues
- ❌ Declare "secure enough"
- ❌ Stop at "mostly secure"
- ❌ Stop working while ANY critical/high vulnerabilities remain

**REMEMBER: This is a SECURITY HARDENING task, not a vulnerability assessment!**

The system is secure ONLY when every single security check shows ✅ GREEN.

**Executing comprehensive security audit and FIXING ALL VULNERABILITIES NOW...**