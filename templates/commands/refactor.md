---
allowed-tools: all
description: Large-scale code refactoring with safety measures and systematic analysis
---

# 🔧🔧🔧 CRITICAL REQUIREMENT: SAFE REFACTORING ONLY! 🔧🔧🔧

**THIS IS NOT A CASUAL RESTRUCTURING TASK - THIS IS A SYSTEMATIC REFACTORING TASK!**

When you run `/refactor`, you are REQUIRED to:

1. **ANALYZE** code smells, patterns, and architecture issues
2. **PLAN** a comprehensive refactoring strategy with safety measures
3. **USE MULTIPLE AGENTS** to refactor modules in parallel:
   - Spawn one agent to refactor data models
   - Spawn another to refactor business logic
   - Spawn more agents for different modules/layers
   - Say: "I'll spawn multiple agents to refactor these components in parallel"
4. **MAINTAIN** backward compatibility throughout the process
5. **DO NOT STOP** until:
   - ✅ ALL refactoring is complete and tested
   - ✅ ALL tests pass with the new structure
   - ✅ Code quality metrics are improved
   - ✅ NO breaking changes are introduced

**FORBIDDEN BEHAVIORS:**
- ❌ "The code could be improved by..." → NO! IMPROVE IT!
- ❌ "These patterns are problematic" → NO! FIX THE PATTERNS!
- ❌ "This needs refactoring" → NO! DO THE REFACTORING!
- ❌ Making breaking changes without migration paths → NO! PRESERVE COMPATIBILITY!

**MANDATORY WORKFLOW:**
```
1. Analyze codebase → Identify refactoring opportunities
2. IMMEDIATELY spawn agents to refactor different modules
3. Ensure backward compatibility at each step
4. Run tests continuously during refactoring
5. REPEAT until all code smells are eliminated
```

**YOU ARE NOT DONE UNTIL:**
- All identified code smells are eliminated
- Code follows consistent patterns throughout
- All tests pass with improved coverage
- Performance is maintained or improved
- Documentation reflects the new structure

---

🛑 **MANDATORY REFACTORING ANALYSIS** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify refactoring scope and dependencies

Execute systematic refactoring with: $ARGUMENTS

**FORBIDDEN EXCUSE PATTERNS:**
- "This refactoring is too risky" → NO, make it safe with proper testing
- "The current code works fine" → NO, working code can still be improved
- "This would be a breaking change" → NO, design migration paths
- "It's good enough as-is" → NO, eliminate all code smells
- "The refactoring is too complex" → NO, break it into manageable steps

Let me ultrathink about refactoring this codebase to eliminate code smells and improve maintainability.

🚨 **REMEMBER: Safety and backward compatibility are paramount!** 🚨

**Systematic Refactoring Protocol:**

**Step 0: Pre-Refactoring Safety**
- Create comprehensive test coverage for existing functionality
- Document current behavior and contracts
- Identify all external dependencies and integration points
- Backup critical configuration and data

**Step 1: Code Smell Analysis**
- **Identify** duplicated code patterns across modules
- **Analyze** overly complex functions and classes
- **Find** inappropriate intimacy between modules
- **Locate** feature envy and misplaced responsibilities
- **Detect** large classes/functions that violate SRP
- **Review** inconsistent naming and patterns

**Code Smell Detection Checklist:**
- [ ] Functions longer than 20-30 lines
- [ ] Classes with more than 7-10 methods
- [ ] Deeply nested conditional logic (>3 levels)
- [ ] Duplicated code blocks (>5 lines repeated)
- [ ] Long parameter lists (>4 parameters)
- [ ] God objects controlling too much behavior
- [ ] Tight coupling between unrelated modules
- [ ] Inconsistent error handling patterns
- [ ] Magic numbers and hardcoded strings
- [ ] Commented-out code blocks

**Step 2: Refactoring Strategy Planning**
Plan refactoring phases with parallel execution:
- **Phase 1**: Extract methods and eliminate duplication
- **Phase 2**: Apply design patterns appropriately
- **Phase 3**: Improve separation of concerns
- **Phase 4**: Optimize performance and memory usage

**Universal Refactoring Patterns:**
- Extract Method: Break down large functions
- Extract Class: Separate responsibilities
- Move Method: Place methods in appropriate classes
- Replace Magic Numbers: Use named constants
- Introduce Parameter Object: Group related parameters
- Replace Conditional with Polymorphism: Eliminate complex conditionals
- Remove Dead Code: Delete unused methods and classes

**Step 3: Parallel Agent Deployment**
Spawn specialized refactoring agents:
```
"I found multiple refactoring opportunities. I'll spawn agents to tackle these systematically:
- Agent 1: Extract methods and eliminate duplication in core business logic
- Agent 2: Refactor data access layer and improve separation
- Agent 3: Apply design patterns to reduce coupling
- Agent 4: Optimize performance bottlenecks and memory usage
Let me refactor all of these in parallel while maintaining safety..."
```

**Language-Specific Refactoring Guidelines:**

**For Go projects specifically:**
- Extract interfaces from concrete types to improve testability
- Replace interface{} with concrete types or proper interfaces
- Eliminate god structs by applying Single Responsibility Principle
- Use composition over inheritance patterns
- Implement proper context propagation
- Refactor error handling to be consistent and informative
- Apply table-driven test patterns for complex logic
- Use channels for clean goroutine coordination

**For all languages:**
- Follow SOLID principles consistently
- Apply appropriate design patterns (Strategy, Factory, Observer)
- Improve naming to be self-documenting
- Reduce cyclomatic complexity through decomposition
- Implement consistent error handling strategies
- Optimize imports and dependencies

**Step 4: Safety Measures**
During refactoring execution:
- Run tests after EVERY significant change
- Maintain API compatibility with deprecation warnings
- Use feature flags for gradual rollouts
- Keep detailed change logs
- Verify performance benchmarks remain stable

**Backward Compatibility Protocol:**
- Create adapter patterns for changed interfaces
- Provide migration guides for breaking changes
- Use semantic versioning appropriately
- Deprecate old APIs before removing them
- Maintain legacy endpoints during transition periods

**Step 5: Quality Verification**
Continuous validation during refactoring:
- ZERO test failures throughout the process
- Code coverage maintained or improved
- Performance benchmarks remain stable
- Linting violations eliminated progressively
- Documentation updated to reflect changes

**Refactoring Completion Criteria:**
✓ All identified code smells eliminated
✓ Consistent patterns applied throughout codebase
✓ SOLID principles followed where applicable
✓ Improved separation of concerns
✓ Reduced coupling between modules
✓ Enhanced testability and maintainability
✓ All tests pass with improved coverage
✓ Performance maintained or improved
✓ Documentation updated and accurate

**Failure Response Protocol:**
When issues arise during refactoring:
1. **IMMEDIATELY ROLLBACK** problematic changes
2. **SPAWN ADDITIONAL AGENTS** to investigate and fix:
   ```
   "Refactoring agent 2 encountered test failures. I'll spawn:
   - Agent 5: Investigate and fix failing tests
   - Agent 6: Review integration points for compatibility
   - Agent 7: Validate performance impact
   Let me resolve these issues before continuing..."
   ```
3. **RE-EVALUATE** refactoring approach if needed
4. **MAINTAIN SAFETY** - never leave code in broken state
5. **DOCUMENT ISSUES** - track what went wrong and why

**Parallel Refactoring Rules:**
- Agents work on independent modules to avoid conflicts
- Clear ownership boundaries for each agent
- Shared interfaces defined upfront for integration
- Regular synchronization to ensure compatibility
- Central coordination for complex cross-module changes

**Final Integration:**
After parallel refactoring:
1. **VERIFY** all agents completed successfully
2. **INTEGRATE** changes and resolve any conflicts
3. **RUN** comprehensive test suite
4. **BENCHMARK** performance to ensure no regressions
5. **VALIDATE** end-to-end functionality
6. **UPDATE** documentation and examples

**Final Commitment:**
I will now execute SYSTEMATIC refactoring and ELIMINATE ALL CODE SMELLS. I will:
- ✅ Analyze all code smells and architectural issues
- ✅ SPAWN MULTIPLE AGENTS to refactor modules in parallel
- ✅ Maintain backward compatibility throughout
- ✅ Keep working until ALL improvements are complete

I will NOT:
- ❌ Just identify issues without fixing them
- ❌ Make breaking changes without migration paths
- ❌ Skip safety measures or testing
- ❌ Leave any code smells unaddressed
- ❌ Stop at "mostly improved"
- ❌ Compromise on code quality standards

**REMEMBER: This is a SYSTEMATIC IMPROVEMENT task, not a cosmetic change task!**

The code is refactored ONLY when every single code smell is eliminated and quality is measurably improved.

**Executing comprehensive refactoring and ELIMINATING ALL CODE SMELLS NOW...**