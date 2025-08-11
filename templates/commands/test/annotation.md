---
allowed-tools: all
description: **ANALYZE PHP annotation coverage** with comprehensive bidirectional linkage validation using parallel agents (analysis only - no test execution)
intensity: ⚡⚡⚡
pattern: 📝📝📝
---

# 📝📝📝 CRITICAL ANNOTATION ANALYSIS: COMPREHENSIVE BIDIRECTIONAL LINKAGE VALIDATION! 📝📝📝

**THIS IS NOT TEST EXECUTION - THIS IS COMPREHENSIVE ANNOTATION COVERAGE ANALYSIS!**

**🚨 NOTE: This command analyzes existing annotations - it does NOT execute tests! 🚨**

When you run `/test annotation`, you are REQUIRED to:

1. **SCAN** all source methods and test methods for @Verified and @TestedBy annotations
2. **VALIDATE** bidirectional method-to-test-case linkage at the method level
3. **VERIFY** that source methods have @Verified annotations pointing to specific test methods
4. **ENSURE** that test methods have @TestedBy annotations pointing to specific source methods
5. **FIX** annotation issues automatically with safe mode validation
6. **REPORT** comprehensive validation results with actionable recommendations
7. **USE MULTIPLE AGENTS** for parallel annotation processing with Task tool

**FORBIDDEN BEHAVIORS:**
- ❌ "Basic annotation check" → NO! Use comprehensive method-level bidirectional validation!
- ❌ "Class-level annotation validation" → NO! Must validate at method level!
- ❌ "Skip method-to-test-case mapping" → NO! Method-level linkage analysis required!
- ❌ "Ignore orphaned methods" → NO! All methods must have corresponding test annotations!
- ❌ "Single-threaded validation" → NO! Use parallel agent coordination!
- ❌ "Generic annotation output" → NO! Method-specific parsing and reporting!
- ❌ "Bash functions instead of Task tool" → NO! Use proper Task tool agents!

**MANDATORY WORKFLOW:**
```
1. PHP annotation system detection → Identify annotation-automation.php
2. IMMEDIATELY spawn 5 agents for parallel method-level validation using Task tool
3. Method discovery → Find all public methods in source classes
4. Annotation discovery → Find all @Verified and @TestedBy annotations at method level
5. Parallel validation → Run method-to-test-case linkage validation across multiple agents
6. Bidirectional linkage analysis → Validate method-level consistency
7. VERIFY results → Ensure all methods have valid test linkages and coverage complete
```

## TASK TOOL AGENT IMPLEMENTATION

I'll spawn 5 specialized agents using Task tool for comprehensive annotation analysis:

### Test Scanner Agent

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Scan test files for annotations</parameter>
<parameter name="prompt">You are the Test Scanner Agent for PHP annotation analysis.

Your responsibilities:
1. Discover all PHP test files in the project (typically in test/, tests/, or Cases/ directories)
2. Scan each test file for @TestedBy annotations on test methods
3. Extract test method names and their corresponding @TestedBy target methods
4. Identify test files with missing @TestedBy annotations
5. Generate comprehensive test file inventory with annotation status

Implementation steps:
- Use Glob to find all PHP test files (*.php in test directories)
- Use Grep to search for @TestedBy annotations and test methods
- Parse annotation syntax: @TestedBy(method="ClassName::methodName")
- Map test methods to their target source methods
- Report orphaned test methods (tests without @TestedBy annotations)

Save your results to /tmp/test-scanner-results.json for coordination with other agents.

Focus specifically on PHP test annotation patterns and provide detailed method-level mapping.</parameter>
</invoke>
</function_calls>

### Annotation Analyzer Agent

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Analyze source file annotations</parameter>
<parameter name="prompt">You are the Annotation Analyzer Agent for PHP source files.

Your responsibilities:
1. Discover all PHP source files in the project (typically in src/, app/, or lib/ directories)
2. Scan each source file for @Verified annotations on public methods
3. Extract method signatures and their corresponding @Verified target test methods
4. Identify source methods with missing @Verified annotations
5. Validate annotation syntax and format correctness

Implementation steps:
- Use Glob to find all PHP source files (*.php in source directories)
- Use Grep to search for @Verified annotations and public methods
- Parse annotation syntax: @Verified(by="TestClass::testMethodName")
- Map source methods to their corresponding test methods
- Report orphaned source methods (methods without @Verified annotations)
- Validate bidirectional linkage consistency

Save your results to /tmp/annotation-analyzer-results.json for coordination with other agents.

Focus on method-level annotation analysis and bidirectional validation.</parameter>
</invoke>
</function_calls>

### Annotation Generator Agent

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Generate missing annotations</parameter>
<parameter name="prompt">You are the Annotation Generator Agent for PHP annotation completion.

Your responsibilities:
1. Read results from Test Scanner Agent and Annotation Analyzer Agent
2. Identify missing @Verified annotations on source methods
3. Identify missing @TestedBy annotations on test methods
4. Generate properly formatted annotation suggestions
5. Create annotation patches for automatic application

Implementation steps:
- Load /tmp/test-scanner-results.json and /tmp/annotation-analyzer-results.json
- Cross-reference source methods with test methods
- Generate @Verified annotations for source methods pointing to existing test methods
- Generate @TestedBy annotations for test methods pointing to source methods
- Create diff patches for annotation additions
- Validate annotation syntax and formatting

Save your results to /tmp/annotation-generator-results.json with patch files.

Focus on creating syntactically correct and logically consistent annotations.</parameter>
</invoke>
</function_calls>

### Validation Agent

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Validate annotation consistency</parameter>
<parameter name="prompt">You are the Validation Agent for PHP annotation consistency checking.

Your responsibilities:
1. Read results from all other annotation agents
2. Validate bidirectional linkage between @Verified and @TestedBy annotations
3. Check for broken links (annotations pointing to non-existent methods)
4. Identify inconsistencies between source and test annotations
5. Generate comprehensive validation report with issues and recommendations

Implementation steps:
- Load all agent result files from /tmp/
- Cross-validate method linkages in both directions
- Check that every @Verified(by="TestClass::testMethod") has corresponding @TestedBy(method="SourceClass::sourceMethod")
- Identify orphaned annotations (pointing to non-existent methods)
- Calculate coverage metrics (percentage of methods with annotations)
- Generate actionable fix recommendations

Save your results to /tmp/validation-results.json with detailed issue analysis.

Focus on comprehensive consistency checking and actionable reporting.</parameter>
</invoke>
</function_calls>

### Documentation Agent

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Update annotation documentation</parameter>
<parameter name="prompt">You are the Documentation Agent for PHP annotation reporting.

Your responsibilities:
1. Read results from all other annotation agents
2. Generate comprehensive annotation coverage report
3. Create method-level annotation statistics and metrics
4. Document annotation best practices and patterns found
5. Generate actionable improvement recommendations

Implementation steps:
- Load all agent result files from /tmp/
- Compile comprehensive annotation coverage statistics
- Generate method-level coverage report with gaps identified
- Create visual representation of annotation linkages
- Document common annotation patterns and anti-patterns found
- Generate prioritized list of annotation improvements
- Create summary report with before/after metrics

Save your results to /tmp/documentation-results.json and generate final report.

Focus on clear, actionable reporting with specific improvement guidance.</parameter>
</invoke>
</function_calls>

---

🛑 **MANDATORY ANNOTATION VALIDATION PROTOCOL** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check PHP annotation system configuration
3. Verify annotation-automation.php accessibility
4. **SPAWN ALL 5 AGENTS IMMEDIATELY** using Task tool for parallel processing

Execute comprehensive annotation validation with ZERO tolerance for incomplete linkage analysis.

**FORBIDDEN SHORTCUT PATTERNS:**
- "Basic annotation scan is sufficient" → NO, comprehensive validation required
- "Skip slow validation for speed" → NO, all annotations must be validated
- "Linkage reports are optional" → NO, mandatory linkage analysis
- "Manual annotation analysis is fine" → NO, automated analysis required
- "Single agent validation is faster" → NO, parallel validation mandatory
- "Bash functions instead of Task tool" → NO, use proper Task tool agents

You are validating annotations for: $ARGUMENTS

Let me ultrathink about comprehensive annotation validation with parallel agent coordination.

🚨 **REMEMBER: Annotations are the foundation of test-source linkage reliability!** 🚨

**YOU ARE NOT DONE UNTIL:**
- ✅ All 5 agents have been spawned using Task tool and completed their analysis
- ✅ All public methods discovered and scanned for annotations
- ✅ Method-level bidirectional linkage analyzed with gap identification
- ✅ All source methods have @Verified annotations pointing to specific test methods
- ✅ All test methods have @TestedBy annotations pointing to specific source methods
- ✅ Orphaned methods identified and reported
- ✅ Invalid method-to-test-case mappings analyzed with root cause identification
- ✅ Method-level coverage metrics collected and reported
- ✅ Actionable recommendations provided for method annotation improvements

**Method-Level Annotation Patterns:**

**Source Method Annotation Example:**
```php
class UserService {
    /**
     * @Verified(by="UserServiceTest::testCreateUser")
     * @param array $userData
     * @return User
     */
    public function createUser(array $userData): User {
        // Implementation
    }
}
```

**Test Method Annotation Example:**
```php
class UserServiceTest extends TestCase {
    /**
     * @TestedBy(method="UserService::createUser")
     * @covers UserService::createUser
     */
    public function testCreateUser(): void {
        // Test implementation
    }
}
```

**Anti-Patterns to Avoid:**
- ❌ Running validation without method-level bidirectional linkage analysis (incomplete validation)
- ❌ Validating at class level instead of method level (insufficient granularity)
- ❌ Ignoring orphaned methods without corresponding test annotations (quality compromise)
- ❌ Single-threaded validation without parallelization (performance issue)
- ❌ Generic validation without method-specific PHP optimization (suboptimal)
- ❌ Skipping method-level coverage analysis or quality metrics (missed insights)
- ❌ No automated method annotation fixing or actionable recommendations (missed improvements)
- ❌ Using bash functions instead of Task tool agents (not real parallelism)

**Final Verification:**
Before completing method-level annotation validation:
- Have I spawned all 5 agents using Task tool for true parallel processing?
- Have I discovered and scanned all public source methods for @Verified annotations?
- Have I discovered and scanned all test methods for @TestedBy annotations?
- Are method-to-test-case linkage reports generated with gap analysis?
- Have I identified and reported all orphaned methods without corresponding annotations?
- Are method-level fix recommendations provided with safe mode options?
- Do I have comprehensive monitoring setup for continuous method-level validation?

**Final Commitment:**
- **I will**: Use Task tool for all 5 agent spawning operations with proper parallel execution
- **I will**: Validate all method-level annotations with comprehensive bidirectional linkage analysis
- **I will**: Discover and scan all public source methods for @Verified annotations
- **I will**: Discover and scan all test methods for @TestedBy annotations
- **I will**: Use parallel agents for optimal method-level validation performance
- **I will**: Provide detailed method-to-test-case gap analysis and actionable recommendations
- **I will**: Validate method annotation quality and suggest improvements
- **I will**: Generate comprehensive method-level reports with monitoring capabilities
- **I will NOT**: Skip method-level linkage analysis or quality validation
- **I will NOT**: Ignore orphaned methods or broken method-to-test-case linkages
- **I will NOT**: Use single-threaded validation without parallelization
- **I will NOT**: Use bash functions instead of proper Task tool agents
- **I will NOT**: Provide generic reports without method-specific actionable insights

**REMEMBER:**
This is METHOD-LEVEL ANNOTATION VALIDATION mode - comprehensive method-level annotation analysis with bidirectional linkage validation, quality metrics, and automated fixing using 5 parallel Task tool agents. The goal is to ensure every source method has a corresponding @Verified annotation pointing to a specific test method, and every test method has a corresponding @TestedBy annotation pointing to a specific source method.

Executing comprehensive annotation validation protocol with parallel agent coordination...