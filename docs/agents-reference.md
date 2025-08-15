# 🤖 Agents Reference Documentation

> Comprehensive guide to all Claude Code specialized agents

---

## 🎯 Agent Overview

Claude Code agents are specialized AI assistants that can be spawned using the Task tool for specific development tasks. Each agent has unique capabilities and is optimized for particular workflows.

### Spawning Agents
```markdown
Use the Task tool with:
- subagent_type: "[agent-name]"
- description: "Brief task description"
- prompt: "Detailed instructions for the agent"
```

---

## 🧪 Testing Agents

### `test-orchestrator` - Adaptive Test Orchestration

#### Purpose
Orchestrates comprehensive test execution with 100% success rate requirement through intelligent retry and parallel execution.

#### Model
Claude Sonnet

#### Key Capabilities
- Parallel test suite execution
- Intelligent failure analysis and retry
- Test dependency management
- Coverage maximization strategies
- Performance optimization

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "test-orchestrator"
- description: "Orchestrate test suite"
- prompt: "Achieve 100% test pass rate for the authentication module. 
          Analyze failures, implement fixes, and retry until all tests pass."
```

#### Orchestration Strategy
```yaml
execution:
  parallel_suites: [unit, integration, e2e]
  retry_strategy: exponential_backoff
  failure_analysis: root_cause
  coverage_target: 90%
```

---

### `unit-test-master` - Unit Test Specialist

#### Purpose
Creates and optimizes unit tests with maximum parallelization and comprehensive coverage.

#### Model
Claude Sonnet

#### Key Capabilities
- Test generation from code analysis
- Mock and stub creation
- Edge case identification
- Test parallelization
- Coverage gap analysis

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "unit-test-master"
- description: "Generate unit tests"
- prompt: "Generate comprehensive unit tests for UserService class 
          with full edge case coverage and proper mocking."
```

#### Test Generation Patterns
- **AAA Pattern**: Arrange, Act, Assert
- **Given-When-Then**: BDD style tests
- **Property-based**: Generative testing
- **Parameterized**: Data-driven tests

---

### `integration-test-master` - Integration Test Specialist

#### Purpose
Manages integration testing with service orchestration and contract validation.

#### Model
Claude Sonnet

#### Key Capabilities
- Service dependency orchestration
- Database transaction testing
- API contract testing
- Message queue testing
- External service mocking

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "integration-test-master"
- description: "Test service integration"
- prompt: "Test payment service integration with Stripe API, 
          database transactions, and event publishing."
```

#### Integration Scenarios
```yaml
test_scenarios:
  - api_integration: REST, GraphQL, gRPC
  - database: Transactions, rollbacks
  - messaging: Pub/sub, queues
  - external_services: Payment, email
```

---

### `test-fixer` - Test Failure Resolution

#### Purpose
Analyzes and fixes failing tests to achieve 100% pass rate.

#### Model
Claude Sonnet

#### Key Capabilities
- Root cause analysis
- Flaky test elimination
- Test refactoring
- Assertion correction
- Environment issue resolution

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "test-fixer"
- description: "Fix failing tests"
- prompt: "Analyze and fix all 15 failing tests in the test suite. 
          Identify root causes and implement permanent fixes."
```

#### Fix Strategies
1. **Timing Issues**: Add proper waits/retries
2. **Data Dependencies**: Isolate test data
3. **Environment**: Fix configuration issues
4. **Assertions**: Correct expectations
5. **Mocking**: Fix mock behaviors

---

## 📊 Milestone Agents

### `milestone-coordinator` - Workflow Orchestration

#### Purpose
Coordinates complex milestone execution with multi-agent orchestration.

#### Model
Claude Sonnet

#### Key Capabilities
- Multi-agent coordination
- Progress tracking and reporting
- Dependency management
- Resource allocation
- Result aggregation

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "milestone-coordinator"
- description: "Coordinate milestone"
- prompt: "Coordinate the user authentication feature milestone 
          spanning design, implementation, testing, and deployment."
```

#### Coordination Pattern
```yaml
coordination:
  agents:
    - planner: Define tasks and timeline
    - executor: Implement features
    - tester: Validate implementation
    - documenter: Create documentation
  communication: shared_state_files
  aggregation: unified_progress_report
```

---

### `milestone-planner` - Strategic Planning

#### Purpose
Performs strategic milestone planning with task decomposition and timeline estimation.

#### Model
Claude Sonnet

#### Key Capabilities
- Task breakdown and sequencing
- Timeline and effort estimation
- Dependency identification
- Risk assessment
- Resource planning

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "milestone-planner"
- description: "Plan Q1 roadmap"
- prompt: "Plan Q1 product roadmap with 3 major features, 
          including task breakdown, dependencies, and timelines."
```

#### Planning Output
```markdown
## Milestone Plan
### Phase 1: Foundation (Week 1-2)
- Task 1.1: Database schema
- Task 1.2: API structure
Dependencies: None

### Phase 2: Core Features (Week 3-6)
- Task 2.1: User authentication
- Task 2.2: Authorization
Dependencies: Phase 1 complete
```

---

### `milestone-executor` - Milestone Execution

#### Purpose
Executes milestone tasks with progress tracking and blocker resolution.

#### Model
Claude Sonnet

#### Key Capabilities
- Task execution management
- Real-time progress tracking
- Blocker identification
- Quality validation
- Completion verification

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "milestone-executor"
- description: "Execute milestone"
- prompt: "Execute database migration milestone tasks including 
          schema updates, data migration, and validation."
```

#### Execution Tracking
```yaml
execution:
  progress_tracking: real_time
  validation: continuous
  blocker_handling: escalation
  completion_criteria: all_tasks_done
```

---

## 🔍 Code Quality Agents

### `code-analyzer` - Code Analysis & Metrics

#### Purpose
Performs comprehensive code analysis with pattern detection and metrics generation.

#### Model
Claude Sonnet

#### Key Capabilities
- Design pattern detection
- Complexity analysis
- Code smell identification
- Dependency analysis
- Metrics generation

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "code-analyzer"
- description: "Analyze codebase"
- prompt: "Analyze the codebase for refactoring opportunities, 
          focusing on complexity, duplication, and patterns."
```

#### Analysis Metrics
```yaml
metrics:
  complexity:
    - cyclomatic: < 10
    - cognitive: < 15
  duplication:
    - threshold: 10 lines
    - similarity: 80%
  patterns:
    - design: singleton, factory, observer
    - anti: god class, spaghetti code
```

---

### `code-quality-enforcer` - Standards Enforcement

#### Purpose
Enforces coding standards and consistency across the codebase.

#### Model
Claude Sonnet

#### Key Capabilities
- Style guide enforcement
- Convention validation
- Documentation requirements
- Naming consistency
- Import organization

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "code-quality-enforcer"
- description: "Enforce standards"
- prompt: "Enforce TypeScript strict mode and ESLint rules 
          across the entire codebase with auto-fixing."
```

#### Enforcement Areas
- **Formatting**: Prettier, Black, gofmt
- **Linting**: ESLint, Pylint, golint
- **Types**: TypeScript strict, Python types
- **Documentation**: JSDoc, docstrings
- **Structure**: File organization, imports

---

### `quality-enforcer` - Comprehensive Quality Gates

#### Purpose
Enforces all quality gates with zero-tolerance for violations.

#### Model
Claude Sonnet

#### Key Capabilities
- Multi-tool quality checks
- Zero-tolerance enforcement
- Report generation
- CI/CD integration
- Automated fixing

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "quality-enforcer"
- description: "Enforce quality gates"
- prompt: "Ensure all quality gates pass before deployment including 
          tests, linting, security, and performance."
```

#### Quality Pipeline
```yaml
gates:
  - formatting: required
  - linting: zero_errors
  - testing: 100%_pass
  - coverage: > 80%
  - security: no_vulnerabilities
  - performance: meets_thresholds
```

---

## 🏗️ Infrastructure Agents

### `orchestrator` - Master Coordination

#### Purpose
Master orchestrator for complex multi-agent workflows.

#### Model
Claude Opus (highest capability)

#### Key Capabilities
- Complex workflow design
- Multi-agent spawning
- Result synthesis
- Resource optimization
- Failure recovery

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "orchestrator"
- description: "Orchestrate feature"
- prompt: "Orchestrate complete user management feature including 
          design, implementation, testing, and deployment."
```

#### Orchestration Patterns
```yaml
patterns:
  parallel_execution:
    - design_agents: 3
    - implementation_agents: 5
    - test_agents: 4
  sequential_phases:
    - planning
    - execution
    - validation
  result_aggregation:
    - synthesis
    - conflict_resolution
```

---

### `git-operator` - Git Operations

#### Purpose
Handles complex git operations and conflict resolution.

#### Model
Claude Sonnet

#### Key Capabilities
- Branch management
- Merge conflict resolution
- Commit optimization
- History rewriting
- Workflow automation

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "git-operator"
- description: "Resolve conflicts"
- prompt: "Resolve merge conflicts between feature branches and 
          clean up git history before merging to main."
```

#### Git Operations
- **Conflict Resolution**: Semantic understanding
- **History Cleanup**: Squash, rebase, amend
- **Branch Strategy**: GitFlow, GitHub Flow
- **Automation**: Hooks, workflows

---

### `dependency-manager` - Dependency Management

#### Purpose
Manages dependencies with security updates and compatibility checking.

#### Model
Claude Sonnet

#### Key Capabilities
- Version management
- Security vulnerability patching
- Compatibility analysis
- Lock file management
- Update automation

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "dependency-manager"
- description: "Update dependencies"
- prompt: "Update all dependencies to latest secure versions 
          while maintaining compatibility."
```

#### Update Strategy
```yaml
priorities:
  1: security_patches
  2: bug_fixes
  3: minor_updates
  4: major_updates
validation:
  - compatibility_check
  - test_suite
  - build_verification
```

---

### `api-integration-tester` - API Testing

#### Purpose
Comprehensive API testing and integration validation.

#### Model
Claude Sonnet

#### Key Capabilities
- Endpoint testing
- Contract validation
- Performance testing
- Mock server setup
- Documentation validation

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "api-integration-tester"
- description: "Test APIs"
- prompt: "Test all REST API endpoints for the user service 
          including authentication, validation, and performance."
```

#### API Test Coverage
```yaml
test_types:
  functional:
    - CRUD operations
    - Authentication
    - Authorization
  non_functional:
    - Performance
    - Rate limiting
    - Error handling
  contract:
    - Request validation
    - Response format
    - Status codes
```

---

### `file-processor` - Bulk File Operations

#### Purpose
Handles bulk file operations and transformations.

#### Model
Claude Sonnet

#### Key Capabilities
- Batch file processing
- Format conversion
- Content transformation
- Pattern application
- Migration automation

#### Usage Example
```markdown
Task tool parameters:
- subagent_type: "file-processor"
- description: "Convert files"
- prompt: "Convert all JavaScript files to TypeScript with 
          proper type definitions and strict mode."
```

#### Processing Capabilities
- **Conversions**: JS→TS, CSS→SCSS, JSON→YAML
- **Refactoring**: Apply patterns, rename
- **Migration**: Update syntax, dependencies
- **Optimization**: Minification, bundling

---

## 🎨 Agent Coordination Patterns

### 5-Agent Parallel Pattern
Used by architect and check commands:
```yaml
pattern: parallel_analysis
agents:
  - domain_analysis
  - dependency_mapping
  - pattern_research
  - risk_assessment
  - documentation
coordination: shared_state_files
aggregation: unified_report
```

### Sequential Pipeline Pattern
Used by milestone workflows:
```yaml
pattern: sequential_pipeline
phases:
  1: planning_agent
  2: implementation_agents (parallel)
  3: testing_agents (parallel)
  4: validation_agent
handoff: phase_results
```

### Hierarchical Pattern
Used by orchestrator:
```yaml
pattern: hierarchical
levels:
  master: orchestrator
  coordinators: [milestone, test, quality]
  workers: [specific_task_agents]
communication: event_driven
```

---

## 💡 Best Practices

### Agent Selection
1. **Match agent to task** - Use specialized agents for specific domains
2. **Consider model tier** - Opus for complex orchestration, Sonnet for specialized tasks
3. **Parallel when possible** - Spawn multiple agents for independent tasks
4. **Chain for workflows** - Sequential agents for dependent operations

### Prompt Engineering
1. **Be specific** - Clear, detailed instructions
2. **Define success** - Explicit completion criteria
3. **Provide context** - Include relevant information
4. **Set constraints** - Time, resource, quality limits

### Coordination
1. **Shared state** - Use files for agent communication
2. **Clear handoffs** - Define input/output contracts
3. **Error handling** - Plan for agent failures
4. **Result validation** - Verify agent outputs

---

## 🚨 Troubleshooting

### Common Issues

#### Agent Spawn Failure
```markdown
Error: Agent spawn failed
Solution: Check subagent_type spelling and availability
```

#### Agent Timeout
```markdown
Error: Agent execution timeout
Solution: Break task into smaller subtasks
```

#### Coordination Issues
```markdown
Error: Agents not communicating
Solution: Verify shared state file paths
```

#### Resource Limits
```markdown
Error: Too many concurrent agents
Solution: Use sequential execution or batching
```

---

## 📊 Agent Performance Metrics

### Efficiency Metrics
| Agent Type | Avg Time | Success Rate | Parallelizable |
|------------|----------|--------------|----------------|
| Testing | 2-5 min | 95% | Yes |
| Milestone | 5-10 min | 90% | Partial |
| Quality | 3-7 min | 98% | Yes |
| Infrastructure | 2-8 min | 92% | Yes |

### Optimization Tips
1. **Batch similar tasks** - Group related operations
2. **Pre-process data** - Prepare inputs before spawning
3. **Cache results** - Reuse agent outputs when possible
4. **Monitor performance** - Track execution times

---

*Documentation generated from templates/agents/*