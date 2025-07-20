---
allowed-tools: all
description: Test-Driven Development workflow with comprehensive red-green-refactor cycle automation
intensity: ⚡⚡⚡⚡⚡
pattern: 🔄🔄🔄🔄🔄
---

# 🔄🔄🔄🔄🔄 CRITICAL TDD WORKFLOW: COMPREHENSIVE RED-GREEN-REFACTOR AUTOMATION! 🔄🔄🔄🔄🔄

**THIS IS NOT A SIMPLE TDD APPROACH - THIS IS A COMPREHENSIVE TDD WORKFLOW AUTOMATION SYSTEM!**

When you run `/test workflows/tdd`, you are REQUIRED to:

1. **IMPLEMENT** full Test-Driven Development workflow with automated red-green-refactor cycles
2. **AUTOMATE** test creation, execution, and refactoring processes
3. **VALIDATE** each TDD cycle with comprehensive quality checks
4. **USE MULTIPLE AGENTS** for parallel TDD workflow execution:
   - Spawn one agent per TDD cycle phase (red, green, refactor)
   - Spawn agents for different code modules or features
   - Say: "I'll spawn multiple agents to execute TDD workflow across all development phases in parallel"
5. **OPTIMIZE** code quality through systematic refactoring
6. **TRACK** TDD metrics and workflow effectiveness

## 🎯 USE MULTIPLE AGENTS

**MANDATORY AGENT SPAWNING FOR TDD WORKFLOW:**
```
"I'll spawn multiple agents to handle TDD workflow comprehensively:
- Red Phase Agent: Write failing tests that define requirements
- Green Phase Agent: Implement minimal code to make tests pass
- Refactor Phase Agent: Improve code quality while maintaining functionality
- Test Quality Agent: Ensure tests are well-designed and maintainable
- Coverage Agent: Validate test coverage and identify gaps
- Metrics Agent: Track TDD cycle efficiency and quality metrics
- Integration Agent: Ensure TDD workflow integrates with existing codebase"
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ Skip writing tests first → NO! Tests must come before implementation!
- ❌ Write more code than needed to pass tests → NO! Minimal implementation only!
- ❌ Skip refactoring phase → NO! Code quality improvement is mandatory!
- ❌ "TDD takes too long" → NO! TDD improves long-term velocity!
- ❌ Write tests after implementation → NO! Tests must drive development!
- ❌ Skip running tests between phases → NO! Continuous validation required!

**MANDATORY WORKFLOW:**
```
1. Red Phase → Write failing test that defines new requirement
2. IMMEDIATELY spawn agents for parallel TDD execution
3. Green Phase → Write minimal code to make test pass
4. Refactor Phase → Improve code quality while maintaining functionality
5. Integration → Ensure changes work with existing codebase
6. VERIFY TDD cycle completion and quality metrics
```

**YOU ARE NOT DONE UNTIL:**
- ✅ ALL TDD cycles are completed with red-green-refactor phases
- ✅ Tests are well-designed and maintainable
- ✅ Code quality is improved through systematic refactoring
- ✅ Test coverage meets or exceeds targets
- ✅ TDD metrics are tracked and analyzed
- ✅ Integration with existing codebase is validated

---

🛑 **MANDATORY TDD WORKFLOW CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current codebase structure and testing setup
3. Verify you understand the TDD workflow requirements

Execute comprehensive TDD workflow for: $ARGUMENTS

**FORBIDDEN SHORTCUT PATTERNS:**
- "TDD is too slow for this project" → NO, TDD improves quality and velocity!
- "Tests are obvious, skip writing them first" → NO, tests must drive development!
- "Refactoring can wait" → NO, refactoring is essential for code quality!
- "Minimal implementation is too restrictive" → NO, resist over-engineering!
- "TDD cycles are too rigid" → NO, follow the discipline for best results!

Let me ultrathink about the comprehensive TDD workflow architecture and execution strategy.

🚨 **REMEMBER: TDD improves code quality, reduces bugs, and increases developer confidence!** 🚨

**Comprehensive TDD Workflow Protocol:**

**Step 0: TDD Environment Setup**
- Configure testing framework and tools
- Set up automated test runner and file watcher
- Establish TDD metrics tracking system
- Prepare development environment for rapid iteration
- Configure continuous integration for TDD workflow

**Step 1: Red Phase - Write Failing Test**

**Red Phase Implementation:**
```bash
# TDD Red Phase Execution
execute_red_phase() {
    local feature_name=$1
    local test_file=$2
    local project_dir=${3:-.}
    
    echo "=== TDD RED PHASE: Writing Failing Test ==="
    echo "Feature: $feature_name"
    echo "Test File: $test_file"
    echo ""
    
    # Source shared utilities
    source "$(dirname "$0")/../../../shared/utils.md"
    source "$(dirname "$0")/../../../shared/runners.md"
    
    # Detect framework
    local framework=$(detect_test_framework "$project_dir")
    echo "Detected framework: $framework"
    
    # Create test file if it doesn't exist
    if [ ! -f "$test_file" ]; then
        create_test_file "$test_file" "$framework" "$feature_name"
    fi
    
    # Write failing test
    write_failing_test "$feature_name" "$test_file" "$framework"
    
    # Run test to confirm it fails
    echo "Running test to confirm failure..."
    run_test_file "$test_file" "$framework" "$project_dir"
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "❌ ERROR: Test passed when it should fail!"
        echo "Review test implementation - it must fail in red phase"
        return 1
    else
        echo "✅ Test correctly fails - Red phase complete"
        return 0
    fi
}

# Create test file with framework-specific structure
create_test_file() {
    local test_file=$1
    local framework=$2
    local feature_name=$3
    
    local test_dir=$(dirname "$test_file")
    mkdir -p "$test_dir"
    
    case "$framework" in
        "jest")
            cat > "$test_file" <<EOF
describe('$feature_name', () => {
    // Red phase: Write failing test here
    test('should implement $feature_name functionality', () => {
        // TODO: Implement test that defines requirements
        expect(true).toBe(false); // Placeholder to ensure test fails
    });
});
EOF
            ;;
        "pytest")
            cat > "$test_file" <<EOF
import pytest

class Test${feature_name//_/}:
    def test_${feature_name}_functionality(self):
        """Red phase: Write failing test here"""
        # TODO: Implement test that defines requirements
        assert False, "Placeholder to ensure test fails"
EOF
            ;;
        "go-test")
            cat > "$test_file" <<EOF
package main

import "testing"

func Test${feature_name//_/}(t *testing.T) {
    // Red phase: Write failing test here
    // TODO: Implement test that defines requirements
    t.Fatal("Placeholder to ensure test fails")
}
EOF
            ;;
        "rspec")
            cat > "$test_file" <<EOF
RSpec.describe '$feature_name' do
  # Red phase: Write failing test here
  it 'should implement $feature_name functionality' do
    # TODO: Implement test that defines requirements
    expect(true).to be false # Placeholder to ensure test fails
  end
end
EOF
            ;;
    esac
    
    echo "Created test file: $test_file"
}

# Write failing test based on requirements
write_failing_test() {
    local feature_name=$1
    local test_file=$2
    local framework=$3
    
    echo "Writing failing test for: $feature_name"
    echo "This test should define the requirements and fail initially"
    
    # Interactive test writing process
    echo "Define the test requirements:"
    echo "1. What should the function/method do?"
    echo "2. What are the expected inputs and outputs?"
    echo "3. What are the edge cases to consider?"
    echo "4. What are the error conditions?"
    
    # Generate test based on requirements
    generate_requirement_based_test "$feature_name" "$test_file" "$framework"
}

# Generate test based on defined requirements
generate_requirement_based_test() {
    local feature_name=$1
    local test_file=$2
    local framework=$3
    
    # This would be customized based on actual requirements
    echo "Generating requirement-based test for $feature_name..."
    echo "Test file: $test_file"
    echo "Framework: $framework"
    
    # Placeholder for actual test generation logic
    echo "TODO: Implement specific test generation based on requirements"
}
```

**Step 2: Green Phase - Minimal Implementation**

**Green Phase Implementation:**
```bash
# TDD Green Phase Execution
execute_green_phase() {
    local feature_name=$1
    local source_file=$2
    local test_file=$3
    local project_dir=${4:-.}
    
    echo "=== TDD GREEN PHASE: Minimal Implementation ==="
    echo "Feature: $feature_name"
    echo "Source File: $source_file"
    echo ""
    
    # Create source file if it doesn't exist
    if [ ! -f "$source_file" ]; then
        create_source_file "$source_file" "$framework" "$feature_name"
    fi
    
    # Implement minimal code to make test pass
    implement_minimal_code "$feature_name" "$source_file" "$framework"
    
    # Run test to confirm it passes
    echo "Running test to confirm implementation passes..."
    run_test_file "$test_file" "$framework" "$project_dir"
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ Test passes - Green phase complete"
        return 0
    else
        echo "❌ Test still fails - continue implementation"
        return 1
    fi
}

# Create source file with minimal structure
create_source_file() {
    local source_file=$1
    local framework=$2
    local feature_name=$3
    
    local source_dir=$(dirname "$source_file")
    mkdir -p "$source_dir"
    
    case "$framework" in
        "jest")
            cat > "$source_file" <<EOF
// Green phase: Minimal implementation for $feature_name
function ${feature_name}() {
    // TODO: Implement minimal code to make test pass
    throw new Error('Not implemented');
}

module.exports = { ${feature_name} };
EOF
            ;;
        "pytest")
            cat > "$source_file" <<EOF
# Green phase: Minimal implementation for $feature_name
def ${feature_name}():
    """TODO: Implement minimal code to make test pass"""
    raise NotImplementedError("Not implemented")
EOF
            ;;
        "go-test")
            cat > "$source_file" <<EOF
package main

// Green phase: Minimal implementation for $feature_name
func ${feature_name//_/}() error {
    // TODO: Implement minimal code to make test pass
    return fmt.Errorf("not implemented")
}
EOF
            ;;
        "rspec")
            cat > "$source_file" <<EOF
# Green phase: Minimal implementation for $feature_name
def ${feature_name}
  # TODO: Implement minimal code to make test pass
  raise NotImplementedError, "Not implemented"
end
EOF
            ;;
    esac
    
    echo "Created source file: $source_file"
}

# Implement minimal code to make test pass
implement_minimal_code() {
    local feature_name=$1
    local source_file=$2
    local framework=$3
    
    echo "Implementing minimal code for: $feature_name"
    echo "Principle: Write only enough code to make the test pass"
    
    # Interactive implementation process
    echo "Implementation guidelines:"
    echo "1. Write the simplest code that makes the test pass"
    echo "2. Don't add functionality not covered by tests"
    echo "3. Don't optimize prematurely"
    echo "4. Focus on making the test pass, not on perfect design"
    
    # Generate minimal implementation
    generate_minimal_implementation "$feature_name" "$source_file" "$framework"
}

# Generate minimal implementation
generate_minimal_implementation() {
    local feature_name=$1
    local source_file=$2
    local framework=$3
    
    echo "Generating minimal implementation for $feature_name..."
    echo "Source file: $source_file"
    echo "Framework: $framework"
    
    # Placeholder for actual implementation logic
    echo "TODO: Implement specific minimal code based on failing test"
}
```

**Step 3: Refactor Phase - Code Quality Improvement**

**Refactor Phase Implementation:**
```bash
# TDD Refactor Phase Execution
execute_refactor_phase() {
    local feature_name=$1
    local source_file=$2
    local test_file=$3
    local project_dir=${4:-.}
    
    echo "=== TDD REFACTOR PHASE: Code Quality Improvement ==="
    echo "Feature: $feature_name"
    echo "Source File: $source_file"
    echo ""
    
    # Backup current implementation
    backup_current_implementation "$source_file"
    
    # Analyze code for refactoring opportunities
    analyze_refactoring_opportunities "$source_file" "$framework"
    
    # Apply refactoring improvements
    apply_refactoring_improvements "$source_file" "$framework"
    
    # Run all tests to ensure refactoring doesn't break functionality
    echo "Running all tests to verify refactoring..."
    run_all_tests "$project_dir" "$framework"
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ All tests pass - Refactor phase complete"
        cleanup_backup "$source_file"
        return 0
    else
        echo "❌ Tests failed after refactoring - reverting changes"
        restore_backup "$source_file"
        return 1
    fi
}

# Backup current implementation before refactoring
backup_current_implementation() {
    local source_file=$1
    local backup_file="${source_file}.tdd-backup"
    
    cp "$source_file" "$backup_file"
    echo "Backed up current implementation to: $backup_file"
}

# Analyze code for refactoring opportunities
analyze_refactoring_opportunities() {
    local source_file=$1
    local framework=$2
    
    echo "Analyzing refactoring opportunities in: $source_file"
    
    # Check for common refactoring patterns
    check_code_duplication "$source_file"
    check_function_complexity "$source_file"
    check_naming_conventions "$source_file"
    check_code_structure "$source_file"
    
    echo "Refactoring opportunities identified"
}

# Apply refactoring improvements
apply_refactoring_improvements() {
    local source_file=$1
    local framework=$2
    
    echo "Applying refactoring improvements to: $source_file"
    
    # Apply common refactoring patterns
    extract_methods "$source_file"
    improve_variable_names "$source_file"
    eliminate_code_duplication "$source_file"
    improve_code_structure "$source_file"
    
    echo "Refactoring improvements applied"
}

# Check for code duplication
check_code_duplication() {
    local source_file=$1
    
    echo "Checking for code duplication in: $source_file"
    # Implementation would analyze for duplicate code patterns
}

# Check function complexity
check_function_complexity() {
    local source_file=$1
    
    echo "Checking function complexity in: $source_file"
    # Implementation would analyze cyclomatic complexity
}

# Extract methods to improve readability
extract_methods() {
    local source_file=$1
    
    echo "Extracting methods to improve readability"
    # Implementation would identify and extract reusable methods
}

# Improve variable names for clarity
improve_variable_names() {
    local source_file=$1
    
    echo "Improving variable names for clarity"
    # Implementation would suggest better variable names
}

# Run all tests to verify refactoring
run_all_tests() {
    local project_dir=$1
    local framework=$2
    
    echo "Running all tests to verify refactoring..."
    execute_test_command "$framework" "$project_dir"
}

# Restore backup if refactoring fails
restore_backup() {
    local source_file=$1
    local backup_file="${source_file}.tdd-backup"
    
    if [ -f "$backup_file" ]; then
        mv "$backup_file" "$source_file"
        echo "Restored backup implementation"
    fi
}

# Cleanup backup after successful refactoring
cleanup_backup() {
    local source_file=$1
    local backup_file="${source_file}.tdd-backup"
    
    if [ -f "$backup_file" ]; then
        rm "$backup_file"
        echo "Cleaned up backup file"
    fi
}
```

**Step 4: Complete TDD Cycle Execution**

**Full TDD Cycle Implementation:**
```bash
# Execute complete TDD cycle
execute_tdd_cycle() {
    local feature_name=$1
    local test_file=$2
    local source_file=$3
    local project_dir=${4:-.}
    
    echo "=== EXECUTING COMPLETE TDD CYCLE ==="
    echo "Feature: $feature_name"
    echo "Test File: $test_file"
    echo "Source File: $source_file"
    echo ""
    
    # Source shared utilities
    source "$(dirname "$0")/../../../shared/utils.md"
    source "$(dirname "$0")/../../../shared/runners.md"
    
    # Detect framework
    local framework=$(detect_test_framework "$project_dir")
    
    # Initialize TDD cycle tracking
    local cycle_start_time=$(date +%s)
    local cycle_id="tdd-cycle-$(date +%Y%m%d-%H%M%S)"
    
    # Phase 1: Red - Write failing test
    echo "Starting Red Phase..."
    if execute_red_phase "$feature_name" "$test_file" "$project_dir"; then
        echo "✅ Red Phase Complete"
    else
        echo "❌ Red Phase Failed"
        return 1
    fi
    
    # Phase 2: Green - Minimal implementation
    echo "Starting Green Phase..."
    if execute_green_phase "$feature_name" "$source_file" "$test_file" "$project_dir"; then
        echo "✅ Green Phase Complete"
    else
        echo "❌ Green Phase Failed"
        return 1
    fi
    
    # Phase 3: Refactor - Code quality improvement
    echo "Starting Refactor Phase..."
    if execute_refactor_phase "$feature_name" "$source_file" "$test_file" "$project_dir"; then
        echo "✅ Refactor Phase Complete"
    else
        echo "❌ Refactor Phase Failed"
        return 1
    fi
    
    # Calculate cycle metrics
    local cycle_end_time=$(date +%s)
    local cycle_duration=$((cycle_end_time - cycle_start_time))
    
    # Record TDD cycle completion
    record_tdd_cycle_completion "$cycle_id" "$feature_name" "$cycle_duration"
    
    echo "🎉 TDD Cycle Complete!"
    echo "Feature: $feature_name"
    echo "Duration: ${cycle_duration}s"
    echo "Cycle ID: $cycle_id"
}

# Record TDD cycle completion metrics
record_tdd_cycle_completion() {
    local cycle_id=$1
    local feature_name=$2
    local duration=$3
    
    local metrics_file="/tmp/tdd-metrics-$$.json"
    
    if [ ! -f "$metrics_file" ]; then
        echo '{"cycles": []}' > "$metrics_file"
    fi
    
    # Add cycle data
    if command -v jq >/dev/null 2>&1; then
        local cycle_data=$(cat <<EOF
{
    "cycle_id": "$cycle_id",
    "feature_name": "$feature_name",
    "duration": $duration,
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "phases": {
        "red": "completed",
        "green": "completed",
        "refactor": "completed"
    }
}
EOF
        )
        
        local temp_file=$(mktemp)
        jq ".cycles += [$cycle_data]" "$metrics_file" > "$temp_file"
        mv "$temp_file" "$metrics_file"
    fi
    
    echo "Recorded TDD cycle metrics: $cycle_id"
}

# Generate TDD workflow summary
generate_tdd_summary() {
    local project_dir=${1:-.}
    local metrics_file="/tmp/tdd-metrics-$$.json"
    
    echo "=== TDD Workflow Summary ==="
    echo ""
    
    if [ -f "$metrics_file" ] && command -v jq >/dev/null 2>&1; then
        local total_cycles=$(jq '.cycles | length' "$metrics_file")
        local avg_duration=$(jq '.cycles | map(.duration) | add / length' "$metrics_file")
        
        echo "Total TDD Cycles: $total_cycles"
        echo "Average Cycle Duration: ${avg_duration}s"
        echo ""
        
        echo "Recent Cycles:"
        jq -r '.cycles | sort_by(.timestamp) | reverse | limit(5; .[]) | "- \(.feature_name): \(.duration)s (\(.timestamp))"' "$metrics_file"
    fi
    
    echo ""
    echo "TDD Workflow Benefits:"
    echo "- Improved code quality through systematic testing"
    echo "- Better requirement understanding through test-first approach"
    echo "- Reduced bugs through comprehensive test coverage"
    echo "- Enhanced code maintainability through refactoring"
    echo "- Increased developer confidence in code changes"
}
```

**TDD Quality Checklist:**
- [ ] Red phase: Failing test written that defines requirements
- [ ] Green phase: Minimal implementation makes test pass
- [ ] Refactor phase: Code quality improved while maintaining functionality
- [ ] All tests pass after each phase
- [ ] TDD cycle metrics tracked and analyzed
- [ ] Code quality improvements documented

**Anti-Patterns to Avoid:**
- ❌ Writing implementation before tests (violates TDD principle)
- ❌ Over-engineering in green phase (should be minimal)
- ❌ Skipping refactoring phase (code quality suffers)
- ❌ Writing multiple tests before implementation (one test at a time)
- ❌ Not running tests between phases (breaks feedback loop)
- ❌ Refactoring without test safety net (risk of breaking functionality)

**Final Verification:**
Before completing TDD workflow:
- Have I followed the red-green-refactor cycle correctly?
- Are all tests passing and providing good coverage?
- Has code quality been improved through systematic refactoring?
- Are TDD metrics being tracked for continuous improvement?
- Do I have actionable insights for future TDD cycles?

**Final Commitment:**
- **I will**: Follow the red-green-refactor cycle discipline
- **I will**: Write tests first that define requirements clearly
- **I will**: Implement minimal code to make tests pass
- **I will**: Refactor systematically to improve code quality
- **I will**: Track TDD metrics for continuous improvement
- **I will NOT**: Skip phases or take shortcuts in the TDD process
- **I will NOT**: Write implementation before tests
- **I will NOT**: Over-engineer in the green phase
- **I will NOT**: Skip refactoring due to time pressure

**REMEMBER:**
This is TDD WORKFLOW mode - disciplined test-driven development with systematic red-green-refactor cycles. The goal is to improve code quality, reduce bugs, and increase developer confidence through comprehensive testing and continuous refactoring.

Executing comprehensive TDD workflow with red-green-refactor automation...