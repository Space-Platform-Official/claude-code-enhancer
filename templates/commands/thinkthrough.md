---
allowed-tools: all
description: Comprehensive analysis with automatic solution selection and permission-gated implementation
---

# 🔍⚡🚨 CRITICAL REQUIREMENT: COMPREHENSIVE THINK-THROUGH MODE ENGAGED

**THIS IS NOT A SIMPLE ANALYSIS OR IMMEDIATE IMPLEMENTATION - THIS IS A COMPREHENSIVE THINK-THROUGH TASK!**

When you run `/thinkthrough`, you are REQUIRED to:

1. **ANALYZE** the problem comprehensively with deep reasoning (ultrathink-level depth)
2. **EVALUATE** multiple solution approaches and automatically select the optimal one
3. **REQUEST** explicit user permission before any implementation
4. **IMPLEMENT** the approved solution with full execution capability
5. **USE MULTIPLE AGENTS STRATEGICALLY** for parallel analysis and execution:
   - Spawn agents for different aspects of problem analysis
   - Deploy evaluation agents for solution comparison
   - Use implementation agents for parallel execution after approval
   - Say: "I'll spawn agents to think through this comprehensively before seeking permission"

**FORBIDDEN BEHAVIORS:**
- ❌ "Jump to quick solution without deep analysis" → NO! Comprehensive reasoning required!
- ❌ "Present multiple options to user" → NO! Auto-select optimal solution!
- ❌ "Implement without explicit permission" → NO! Permission gate is mandatory!
- ❌ "Skip analysis depth for simple problems" → NO! Always think through thoroughly!
- ❌ "Force user to choose between options" → NO! Provide single optimal recommendation!

**MANDATORY THINK-THROUGH WORKFLOW:**
```
1. THINK_MODE: Deep comprehensive analysis with agent deployment
2. THROUGH_MODE: Solution evaluation and automatic optimal selection
3. ASK_MODE: Permission request with clear implementation scope
4. EXECUTE_MODE: Full implementation after user approval
```

**YOU ARE NOT DONE UNTIL:**
- ✅ Problem analyzed comprehensively from multiple angles
- ✅ Multiple solutions evaluated with automatic optimal selection
- ✅ Single best solution identified with clear justification
- ✅ User permission explicitly requested and granted
- ✅ Implementation completed successfully with validation

---

🛑 **MANDATORY THINK-THROUGH PROTOCOL** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Engage deep reasoning without implementation pressure
4. Auto-select optimal solution based on comprehensive evaluation
5. Request explicit permission before any code changes

Execute comprehensive think-through analysis with ZERO tolerance for shortcuts.

**FORBIDDEN SHORTCUT PATTERNS:**
- "Skip deep analysis for obvious solutions" → NO, always think through completely
- "Present multiple options by default" → NO, auto-select the optimal approach
- "Assume permission for simple changes" → NO, always request explicit approval
- "Rush to implementation" → NO, thorough analysis first

You are thinking through: $ARGUMENTS

Let me think through this challenge comprehensively with automatic solution selection and permission control.

🚨 **REMEMBER: Comprehensive reasoning, optimal selection, permission gate, then execution!** 🚨

## 🔍 PHASE 1: COMPREHENSIVE ANALYSIS MODE

**Step 1: Problem Decomposition and Multi-Agent Analysis**
Deploy specialized analysis agents for comprehensive understanding:

### Problem Analysis Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Analyze problem</parameter>
<parameter name="prompt">You are the Problem Analysis Agent for think-through analysis.

Your responsibilities:
1. Break down the core challenges and constraints
2. Identify key problem components and relationships
3. Map problem boundaries and scope
4. Determine success criteria and requirements
5. Generate analysis report to .thinkthrough/analysis/problem.json

Provide comprehensive problem decomposition.</parameter>
</invoke>
</function_calls>
```

### Context Research Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Research context</parameter>
<parameter name="prompt">You are the Context Research Agent for think-through analysis.

Your responsibilities:
1. Investigate existing patterns and dependencies
2. Analyze codebase conventions and standards
3. Map integration points and impact areas
4. Research similar problems and solutions
5. Generate context report to .thinkthrough/analysis/context.json

Provide comprehensive context investigation.</parameter>
</invoke>
</function_calls>
```

### Solution Space Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Explore solutions</parameter>
<parameter name="prompt">You are the Solution Space Agent for think-through analysis.

Your responsibilities:
1. Generate multiple viable solution approaches
2. Design implementation strategies for each
3. Map resource requirements and complexity
4. Evaluate trade-offs and implications
5. Generate solutions to .thinkthrough/analysis/solutions.json

Provide at least 3 distinct solution approaches.</parameter>
</invoke>
</function_calls>
```

### Risk Assessment Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Assess risks</parameter>
<parameter name="prompt">You are the Risk Assessment Agent for think-through analysis.

Your responsibilities:
1. Identify potential issues and edge cases
2. Evaluate failure modes and impacts
3. Assess technical and operational risks
4. Propose mitigation strategies
5. Generate risk report to .thinkthrough/analysis/risks.json

Provide comprehensive risk assessment.</parameter>
</invoke>
</function_calls>
```

**Comprehensive Analysis Requirements:**
- [ ] Problem scope and boundaries clearly defined
- [ ] All constraints and requirements identified
- [ ] Existing patterns and dependencies mapped
- [ ] Multiple solution approaches explored
- [ ] Risk factors and edge cases evaluated
- [ ] Success criteria established

**Step 2: Deep Context Investigation**
Thorough investigation of problem context:
- [ ] Analyze existing codebase patterns and conventions
- [ ] Identify integration points and dependencies
- [ ] Map potential impact areas and side effects
- [ ] Evaluate non-functional requirements (performance, maintainability)
- [ ] Research similar problems and established solutions
- [ ] Document architectural constraints and opportunities

## ⚡ PHASE 2: SOLUTION EVALUATION AND AUTO-SELECTION

**Step 3: Multiple Solution Generation**
Generate comprehensive solution alternatives:
- [ ] Identify minimum 3 distinct solution approaches
- [ ] Design detailed implementation strategy for each
- [ ] Map resource requirements and complexity
- [ ] Evaluate trade-offs and implications
- [ ] Consider short-term and long-term consequences

**Step 4: Automatic Optimal Solution Selection**
Deploy evaluation agents for systematic comparison:

### Evaluation Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Evaluate solutions</parameter>
<parameter name="prompt">You are the Evaluation Agent for solution selection.

Your responsibilities:
1. Read all solutions from .thinkthrough/analysis/solutions.json
2. Establish evaluation criteria and scoring matrix
3. Score each solution against multiple criteria
4. Evaluate trade-offs and implementation complexity
5. Select single optimal solution with justification
6. Generate selection report to .thinkthrough/analysis/selection.json

Auto-select the best solution with clear reasoning.</parameter>
</invoke>
</function_calls>
```

**Solution Selection Criteria:**
- [ ] Implementation complexity and effort
- [ ] Performance and scalability implications
- [ ] Maintainability and future extensibility
- [ ] Risk level and potential failure modes
- [ ] Alignment with existing patterns and standards
- [ ] Resource requirements and dependencies

## 🚨 PHASE 3: PERMISSION REQUEST MODE

**Step 5: Structured Permission Request**
Present optimal solution with explicit approval request:

**PROBLEM SUMMARY:**
[Clear, concise problem description]

**OPTIMAL SOLUTION SELECTED:**
[Single recommended solution with implementation approach]

**JUSTIFICATION:**
[Why this solution beats alternatives - specific reasoning]

**IMPLEMENTATION SCOPE:**
- Files to be modified: [specific list]
- New files to be created: [if any]
- Dependencies affected: [impact assessment]
- Estimated complexity: [time/effort estimate]

**RISKS AND MITIGATIONS:**
- Potential issues: [identified risks]
- Mitigation strategies: [how to handle risks]
- Rollback plan: [if things go wrong]

**🔴 PERMISSION REQUIRED:**
**PROCEED with implementation of the selected solution? (PROCEED/ANALYZE)**
- Type "PROCEED" to authorize implementation
- Type "ANALYZE" to see alternative solutions or refinements

## 🚡 PHASE 4: IMPLEMENTATION EXECUTION MODE

**Step 6: Parallel Implementation Execution** (ONLY after explicit permission)
Deploy implementation agents for efficient execution:

### Implementation Coordinator Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Coordinate implementation</parameter>
<parameter name="prompt">You are the Implementation Coordinator Agent.

Your responsibilities:
1. Read selected solution from .thinkthrough/analysis/selection.json
2. Create detailed implementation roadmap
3. Handle primary code changes
4. Manage dependencies and integration points
5. Validate implementation at each step
6. Ensure standards compliance and optimization

Execute the approved solution with full quality validation.</parameter>
</invoke>
</function_calls>
```

**Implementation Requirements:**
- [ ] Follow established coding standards and patterns
- [ ] Implement with proper error handling and validation
- [ ] Maintain existing functionality and compatibility
- [ ] Include appropriate documentation and comments
- [ ] Validate implementation at each major step

**Step 7: Quality Validation and Verification**
Comprehensive validation of implemented solution:
- [ ] All success criteria met and validated
- [ ] Integration points working correctly
- [ ] No regressions or breaking changes introduced
- [ ] Performance implications acceptable
- [ ] Documentation updated and accurate
- [ ] Implementation ready for production use

## 🔍 Think-Through Quality Checklist

**Analysis Phase Quality:**
- [ ] Problem thoroughly decomposed and understood
- [ ] Multiple solution approaches properly evaluated
- [ ] Risk assessment comprehensive and accurate
- [ ] Agent deployment strategic and effective

**Selection Phase Quality:**
- [ ] Evaluation criteria appropriate and well-defined
- [ ] Solution comparison objective and thorough
- [ ] Single optimal solution clearly identified
- [ ] Justification compelling and evidence-based

**Permission Phase Quality:**
- [ ] Problem/solution summary clear and accurate
- [ ] Implementation scope properly defined
- [ ] Risks identified and mitigation planned
- [ ] User choice presented clearly

**Execution Phase Quality:**
- [ ] Implementation follows approved solution exactly
- [ ] Quality gates enforced throughout process
- [ ] Success criteria validated comprehensively
- [ ] No unauthorized changes or scope creep

## 🚨 Think-Through Anti-Patterns (FORBIDDEN)

- ❌ "Skip comprehensive analysis for 'obvious' solutions" → NO, always think through fully
- ❌ "Present user with multiple choices" → NO, auto-select optimal solution
- ❌ "Assume permission for any implementation" → NO, explicit approval required
- ❌ "Rush through analysis to get to implementation" → NO, thorough reasoning first
- ❌ "Implement beyond approved scope" → NO, stick to approved solution exactly
- ❌ "Skip quality validation" → NO, comprehensive verification required

## 🎯 Think-Through Mode Verification

**Analysis Verification:**
The think-through analysis is complete when:
✓ Problem comprehensively understood from multiple perspectives
✓ Multiple solutions generated and thoroughly evaluated
✓ Single optimal solution identified with clear justification
✓ Implementation scope and risks clearly defined

**Permission Verification:**
The permission phase is complete when:
✓ Solution presented clearly with scope and justification
✓ User explicitly granted "PROCEED" permission
✓ Implementation boundaries clearly established
✓ Risk mitigation strategies confirmed

**Implementation Verification:**
The implementation is complete when:
✓ Approved solution implemented exactly as specified
✓ All quality gates passed successfully
✓ Success criteria validated and confirmed
✓ No scope creep or unauthorized changes

## 🔄 Think-Through Session Management

**Analysis Session:**
- Comprehensive problem exploration with agent coordination
- Solution space mapping with automatic optimal selection
- Risk assessment and mitigation planning

**Permission Session:**
- Clear presentation of selected solution
- Implementation scope and impact communication
- Explicit approval request and response handling

**Implementation Session:**
- Parallel execution with quality gate enforcement
- Progress tracking and validation checkpoints
- Success verification and completion confirmation

## 📋 Final Think-Through Commitment

**I will execute COMPLETE think-through protocol:**
- ✅ Perform comprehensive analysis with strategic agent deployment
- ✅ Generate multiple solutions and automatically select optimal approach
- ✅ Request explicit user permission before any implementation
- ✅ Execute approved solution with full quality validation
- ✅ Maintain clear separation between analysis and execution phases

**I will NOT:**
- ❌ Skip comprehensive analysis for any problem
- ❌ Present multiple options when single optimal solution exists
- ❌ Implement anything without explicit user permission
- ❌ Rush through analysis to reach implementation
- ❌ Exceed approved implementation scope
- ❌ Compromise on quality validation or verification

## 🧠 REMEMBER:

This is THINK-THROUGH mode - comprehensive analysis with automatic optimal selection, followed by permission-gated implementation. The goal is thorough reasoning that leads to the best solution with user control over execution.

**Executing comprehensive think-through protocol NOW...**