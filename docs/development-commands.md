# 🛠️ Development Commands Documentation

> Comprehensive testing, quality, and development workflow commands

---

## 🧪 Testing Commands

### `/test/unit` - Unit Testing

#### Overview
Execute focused unit testing with comprehensive coverage validation for isolated components.

#### Usage
```bash
claude test unit              # Run all unit tests
claude test unit src/auth     # Test specific directory
claude test unit --watch      # Watch mode
claude test unit --coverage   # With coverage report
```

#### Key Features
- Isolated component testing
- Mock dependency management
- Parallel test execution
- Coverage threshold enforcement

#### Configuration
```yaml
coverage:
  threshold: 80%
  exclude: ["*.spec.ts", "*.test.js"]
parallelization: true
mock_strategy: "auto"
```

---

### `/test/integration` - Integration Testing

#### Overview
Validate component interactions and external service integrations with realistic scenarios.

#### Usage
```bash
claude test integration                    # Run all integration tests
claude test integration --env staging      # Test against staging
claude test integration --services db,api  # Specific services
```

#### Key Features
- Database transaction testing
- API endpoint validation
- Service communication verification
- Test data management

#### Configuration
```yaml
test_databases:
  postgres: "test_db"
  redis: "test_cache"
external_mocks:
  stripe: "mock_server"
  sendgrid: "stub"
```

---

### `/test/e2e` - End-to-End Testing

#### Overview
Complete user workflow validation across the entire application stack.

#### Usage
```bash
claude test e2e                    # Run all E2E tests
claude test e2e --browser chrome   # Specific browser
claude test e2e --headless        # Headless mode
claude test e2e --parallel 4      # Parallel execution
```

#### Key Features
- Browser automation (Playwright/Cypress)
- User journey testing
- Cross-browser validation
- Visual regression testing

#### Example Workflows
```javascript
// User registration flow
- Navigate to signup
- Fill form with valid data
- Submit and verify email
- Complete onboarding
- Verify dashboard access
```

---

### `/test/performance` - Performance Testing

#### Overview
Load testing and performance validation under various stress conditions.

#### Usage
```bash
claude test performance              # Default load test
claude test performance --load 1000  # 1000 concurrent users
claude test performance --duration 5m # 5-minute stress test
```

#### Key Features
- Load simulation with K6/JMeter
- Stress testing patterns
- Performance benchmarking
- Resource monitoring

#### Performance Thresholds
```yaml
thresholds:
  response_time_p95: 500ms
  error_rate: < 1%
  throughput: > 1000 req/s
```

---

### `/test/workflows/tdd` - Test-Driven Development

#### Overview
Implements Red-Green-Refactor workflow for feature development.

#### Usage
```bash
claude test workflows tdd "user authentication"
# Creates failing tests → Implements solution → Refactors
```

#### TDD Cycle
1. **Red Phase**: Write failing tests first
2. **Green Phase**: Minimal implementation to pass
3. **Refactor Phase**: Improve code quality
4. **Repeat**: Continue until feature complete

#### Example
```bash
# Automatic workflow:
1. Generate test: "should authenticate valid user"
2. Test fails (red)
3. Implement authentication logic
4. Test passes (green)
5. Refactor for clarity
6. All tests still pass
```

---

### `/test/workflows/ci` - CI/CD Testing

#### Overview
Automated testing integration for continuous integration pipelines.

#### Usage
```yaml
# GitHub Actions example
- uses: claude-code/test-ci@v1
  with:
    command: 'test workflows ci'
    parallel: true
    fail-fast: false
```

#### Pipeline Stages
- **Pre-commit**: Linting, formatting
- **Pull Request**: Unit + integration tests
- **Main Branch**: Full test suite
- **Deploy**: E2E + performance tests

---

### `/test/watch` - Test Watching

#### Overview
Continuous test execution during development with intelligent file watching.

#### Usage
```bash
claude test watch              # Watch all files
claude test watch --related    # Only test related files
claude test watch --notify     # Desktop notifications
```

#### Watch Patterns
```yaml
patterns:
  source: ["src/**/*.ts", "src/**/*.js"]
  test: ["**/*.test.ts", "**/*.spec.js"]
related_only: true
debounce: 500ms
```

---

## 🎨 Quality Commands

### `/quality/format` - Code Formatting

#### Overview
Automated code formatting across all languages with style guide enforcement.

#### Usage
```bash
claude quality format          # Format all files
claude quality format --check  # Check without modifying
claude quality format src/     # Format specific directory
```

#### Language Support
| Language | Formatter | Config File |
|----------|-----------|-------------|
| JavaScript/TypeScript | Prettier | .prettierrc |
| Python | Black | pyproject.toml |
| Go | gofmt | Built-in |
| Rust | rustfmt | rustfmt.toml |

---

### `/quality/dedupe` - Code Deduplication

#### Overview
Identify and eliminate duplicate code patterns with intelligent refactoring.

#### Usage
```bash
claude quality dedupe                  # Find all duplicates
claude quality dedupe --threshold 80   # 80% similarity threshold
claude quality dedupe --fix            # Auto-refactor duplicates
```

#### Detection Patterns
- Duplicate functions
- Similar code blocks
- Repeated patterns
- Copy-paste violations

#### Refactoring Actions
```markdown
Found: 3 duplicate implementations of "validateEmail"
Action: Extract to shared utility
Location: src/utils/validators.ts
```

---

### `/quality/verify` - Comprehensive Verification

#### Overview
Multi-layer validation for code quality, security, and standards compliance.

#### Usage
```bash
claude quality verify                 # Standard verification
claude quality verify --comprehensive # Full analysis
claude quality verify --security-only # Security focus
claude quality verify --format=json   # JSON output
```

#### Verification Layers
1. **Syntax Validation** - Parse errors, compilation
2. **Linting** - Style violations, best practices
3. **Type Checking** - Type safety, contracts
4. **Security Scanning** - Vulnerabilities, secrets
5. **Complexity Analysis** - Cyclomatic complexity
6. **Documentation** - Missing docs, outdated comments

#### Tool Integration
```yaml
javascript:
  - eslint
  - typescript
  - prettier
  - npm audit
python:
  - flake8
  - mypy
  - bandit
  - safety
```

---

## ⚡ Optimization Commands

### `/optimize` - Performance Optimization

#### Overview
Profile-driven performance optimization with systematic benchmarking.

#### Mandatory Workflow
```bash
1. Profile first (mandatory)
2. Identify bottlenecks
3. Spawn optimization agents
4. Implement improvements
5. Benchmark results
6. Verify behavior unchanged
```

#### Usage
```bash
claude optimize              # Full optimization workflow
claude optimize --profile    # Generate profiling data
claude optimize --benchmark  # Run benchmarks only
```

#### Optimization Areas
- **Algorithm Complexity** - O(n²) → O(n log n)
- **Memory Allocation** - Reduce allocations
- **Database Queries** - N+1 query elimination
- **Caching** - Strategic cache implementation
- **Parallelization** - Concurrent processing

#### Requirements
- Minimum 10% performance improvement
- No functionality changes
- Profiling evidence required
- Benchmark validation

---

### `/refactor` - Code Refactoring

#### Overview
Large-scale refactoring with safety measures and backward compatibility.

#### Usage
```bash
claude refactor              # Comprehensive refactoring
claude refactor --pattern singleton-to-di  # Specific pattern
claude refactor --safe       # Extra safety checks
```

#### Code Smell Detection
| Smell | Threshold | Action |
|-------|-----------|--------|
| Long functions | >20-30 lines | Extract methods |
| Large classes | >7-10 methods | Split responsibilities |
| Deep nesting | >3 levels | Early returns |
| Magic numbers | Any | Extract constants |
| Duplicate code | >10 lines | Extract shared |

#### Refactoring Patterns
- Extract Method/Class
- Move Method/Field
- Replace Magic Numbers
- Introduce Parameter Object
- Replace Conditional with Polymorphism

---

### `/security-audit` - Security Hardening

#### Overview
Comprehensive vulnerability scanning with automatic remediation.

#### Usage
```bash
claude security-audit         # Full security audit
claude security-audit --fix   # Auto-fix vulnerabilities
claude security-audit --owasp # OWASP Top 10 focus
```

#### OWASP Top 10 Coverage
1. **Broken Access Control** - Permission validation
2. **Cryptographic Failures** - Encryption audit
3. **Injection** - SQL, NoSQL, Command injection
4. **Insecure Design** - Architecture review
5. **Security Misconfiguration** - Config hardening
6. **Vulnerable Components** - Dependency scanning
7. **Authentication Failures** - Auth hardening
8. **Data Integrity** - Validation checks
9. **Security Logging** - Audit trails
10. **SSRF** - Request validation

#### Security Tools
```yaml
scanning:
  - semgrep
  - bandit (Python)
  - gosec (Go)
  - npm audit (Node.js)
dependencies:
  - snyk
  - dependabot
  - safety
```

---

## 📚 Documentation & Operations

### `/docs` - Documentation Generation

#### Overview
Create comprehensive project documentation with organized structure.

#### Usage
```bash
claude docs              # Generate all documentation
claude docs --api        # API documentation only
claude docs --guides     # User guides only
```

#### Documentation Structure
```
docs/
├── getting-started/
│   ├── installation.md
│   └── quickstart.md
├── user-guide/
│   ├── features.md
│   └── tutorials.md
├── api/
│   ├── reference.md
│   └── examples.md
├── architecture/
│   ├── overview.md
│   └── decisions.md
└── deployment/
    ├── production.md
    └── scaling.md
```

---

### `/monitor` - Observability Implementation

#### Overview
Implement comprehensive monitoring with logging, metrics, and tracing.

#### Usage
```bash
claude monitor              # Full observability setup
claude monitor --logging    # Structured logging only
claude monitor --metrics    # Metrics collection only
claude monitor --tracing    # Distributed tracing only
```

#### Observability Stack
```yaml
logging:
  format: JSON
  fields: [timestamp, level, message, context]
  correlation: request_id
metrics:
  collector: Prometheus
  types: [counters, gauges, histograms]
tracing:
  implementation: OpenTelemetry
  sampling: 0.1
```

---

### `/migrate` - Migration Management

#### Overview
Safe migration execution for databases, APIs, and frameworks.

#### Usage
```bash
claude migrate              # Execute migration plan
claude migrate --rollback   # Rollback procedures
claude migrate --dry-run    # Simulation mode
```

#### Migration Phases
1. **Pre-migration** - Backups, validation
2. **Schema Migration** - Database structure
3. **Data Migration** - Content transfer
4. **Service Migration** - API updates
5. **Post-migration** - Verification, cleanup

#### Safety Measures
- Blue-green deployment
- Feature flags
- Rollback procedures
- Zero-downtime approach

---

### `/upgrade` - Dependency Management

#### Overview
Systematic dependency upgrades with risk assessment and testing.

#### Usage
```bash
claude upgrade              # Upgrade all dependencies
claude upgrade --security   # Security patches only
claude upgrade --major      # Major version upgrades
```

#### Upgrade Process
1. **Audit** - Current dependency analysis
2. **Risk Assessment** - Breaking change evaluation
3. **Planning** - Upgrade sequence determination
4. **Execution** - Incremental upgrades
5. **Testing** - Regression validation
6. **Rollback** - Contingency procedures

---

### `/api-design` - API Development

#### Overview
Production-grade API design with specifications and SDK generation.

#### Usage
```bash
claude api-design              # Complete API design
claude api-design --rest       # RESTful API
claude api-design --graphql    # GraphQL schema
claude api-design --sdk        # Generate client SDKs
```

#### API Standards
- **REST**: OpenAPI 3.0 specification
- **GraphQL**: Schema-first design
- **Authentication**: OAuth2, JWT, API keys
- **Versioning**: URL, header, or content negotiation
- **Documentation**: Interactive API explorer

---

## 🔧 Utility Commands

### `/fix-imports` - Import Resolution

#### Overview
Fix broken imports after file moves or renames with session intelligence.

#### Usage
```bash
claude fix-imports           # Fix all broken imports
claude fix-imports src/      # Focus on directory
claude fix-imports resume    # Continue previous session
```

#### Detection & Resolution
- Module resolution failures
- Circular dependencies
- Missing exports
- Path recalculation
- Symbol search

---

### `/create-todos` - TODO Management

#### Overview
Analyze recent operations and create contextual TODO comments.

#### Usage
```bash
claude create-todos    # Create TODOs from session
```

#### TODO Patterns
```javascript
// TODO: [Security] Fix SQL injection vulnerability - HIGH priority
// TODO: [Performance] Optimize database query - reduces load by 40%
// TODO: [Refactor] Extract duplicate logic to shared utility
```

---

## 💡 Best Practices

### Testing Strategy
1. **Unit tests** for business logic (80% coverage)
2. **Integration tests** for service boundaries
3. **E2E tests** for critical user paths
4. **Performance tests** before major releases

### Quality Gates
```yaml
pre-commit:
  - format
  - lint
  - unit tests
pull-request:
  - all tests
  - security scan
  - coverage check
deployment:
  - e2e tests
  - performance tests
  - security audit
```

### Optimization Workflow
1. Always profile before optimizing
2. Set measurable performance goals
3. Benchmark before and after changes
4. Ensure behavior remains identical
5. Document optimization decisions

---

*Documentation generated from templates/commands/*