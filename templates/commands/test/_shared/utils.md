# Test Framework Utilities

This file contains shared utilities for test framework detection, file discovery, execution, and PHP structure control across all test commands.

## 🚨 **MANDATORY 100% TEST SUCCESS RATE REQUIREMENT**

**ALL test commands in this framework enforce 100% success rate. ANY test failures will block execution.**

This applies to:
- Unit tests (`/test unit`)
- Integration tests (`/test integration`)
- End-to-end tests (`/test e2e`)
- Performance tests (`/test performance`)
- All other test command variants

**No exceptions. Fix all test failures before proceeding.**

## PHP Structure Control Mechanisms

Users can control PHP-specific test structure generation through multiple mechanisms:

1. **Environment Variable**: `export CLAUDE_PHP_TESTS=false`
2. **Project files**: `.claude/no-php-tests` or `.no-php-structure`
3. **Command flags**: `--no-php` or `--skip-php-structure-check`

These controls ensure non-PHP projects aren't forced into PHP-specific test structures.

### Quick Reference

Run any test command with these flags to control PHP behavior:
```bash
# Skip all PHP-specific features
/test unit --no-php
/test integration --no-php

# Skip only PHP structure validation
/test unit --skip-php-structure-check
/test integration --skip-php-structure-check

# Show PHP control help
show_php_control_help
```

### Environment Setup
```bash
# Disable PHP features globally
export CLAUDE_PHP_TESTS=false

# Or create a project disable file
mkdir -p .claude
touch .claude/no-php-tests
```

## Framework Detection

```bash
# Core Framework Detection Functions
detect_test_framework() {
    local project_dir=${1:-.}
    local detected_frameworks=()
    
    # JavaScript/TypeScript frameworks
    if [ -f "$project_dir/package.json" ]; then
        if grep -q "jest" "$project_dir/package.json"; then
            detected_frameworks+=("jest")
        fi
        if grep -q "mocha" "$project_dir/package.json"; then
            detected_frameworks+=("mocha")
        fi
        if grep -q "jasmine" "$project_dir/package.json"; then
            detected_frameworks+=("jasmine")
        fi
        if grep -q "vitest" "$project_dir/package.json"; then
            detected_frameworks+=("vitest")
        fi
    fi
    
    # Python frameworks
    if [ -f "$project_dir/pytest.ini" ] || [ -f "$project_dir/pyproject.toml" ] || [ -f "$project_dir/setup.cfg" ]; then
        if grep -q "pytest" "$project_dir/pytest.ini" "$project_dir/pyproject.toml" "$project_dir/setup.cfg" 2>/dev/null; then
            detected_frameworks+=("pytest")
        fi
    fi
    
    # Go test
    if [ -f "$project_dir/go.mod" ]; then
        detected_frameworks+=("go-test")
    fi
    
    # Ruby frameworks
    if [ -f "$project_dir/Gemfile" ]; then
        if grep -q "rspec" "$project_dir/Gemfile"; then
            detected_frameworks+=("rspec")
        fi
        if grep -q "minitest" "$project_dir/Gemfile"; then
            detected_frameworks+=("minitest")
        fi
    fi
    
    # Java frameworks
    if [ -f "$project_dir/pom.xml" ]; then
        if grep -q "junit" "$project_dir/pom.xml"; then
            detected_frameworks+=("junit")
        fi
    fi
    
    # PHP frameworks
    if [ -f "$project_dir/composer.json" ]; then
        if grep -q "phpunit/phpunit" "$project_dir/composer.json" 2>/dev/null; then
            detected_frameworks+=("phpunit")
        fi
    fi
    
    # Print detected frameworks
    printf "%s\n" "${detected_frameworks[@]}"
}

# Get framework-specific configuration
get_framework_config() {
    local framework=$1
    local project_dir=${2:-.}
    
    case "$framework" in
        "jest")
            echo "config_file:jest.config.js test_pattern:**/*.test.js,**/*.spec.js command:npm test"
            ;;
        "pytest")
            echo "config_file:pytest.ini test_pattern:**/test_*.py,**/*_test.py command:pytest"
            ;;
        "go-test")
            echo "config_file:go.mod test_pattern:**/*_test.go command:go test ./..."
            ;;
        "rspec")
            echo "config_file:.rspec test_pattern:**/*_spec.rb command:bundle exec rspec"
            ;;
        "mocha")
            echo "config_file:mocha.opts test_pattern:**/*.test.js,**/*.spec.js command:npm test"
            ;;
        "phpunit")
            echo "config_file:phpunit.xml test_pattern:**/*Test.php command:./vendor/bin/phpunit"
            ;;
        *)
            echo "config_file: test_pattern: command:"
            return 1
            ;;
    esac
}

# Validate framework installation
validate_framework_installation() {
    local framework=$1
    local project_dir=${2:-.}
    
    case "$framework" in
        "jest")
            command -v jest >/dev/null 2>&1 || npm list jest >/dev/null 2>&1
            ;;
        "pytest")
            command -v pytest >/dev/null 2>&1 || python -m pytest --version >/dev/null 2>&1
            ;;
        "go-test")
            command -v go >/dev/null 2>&1
            ;;
        "rspec")
            command -v rspec >/dev/null 2>&1 || bundle exec rspec --version >/dev/null 2>&1
            ;;
        "mocha")
            command -v mocha >/dev/null 2>&1 || npm list mocha >/dev/null 2>&1
            ;;
        "phpunit")
            command -v phpunit >/dev/null 2>&1 || [ -f "./vendor/bin/phpunit" ]
            ;;
        *)
            return 1
            ;;
    esac
}
```

## Test File Discovery

```bash
# Find all test files using framework-specific patterns
find_test_files() {
    local project_dir=${1:-.}
    local framework=${2:-"auto"}
    local exclude_patterns=${3:-"node_modules __pycache__ .git target build dist .claude"}
    
    if [ "$framework" = "auto" ]; then
        framework=$(detect_test_framework "$project_dir" | head -1)
    fi
    
    local config=$(get_framework_config "$framework" "$project_dir")
    local test_pattern=$(echo "$config" | sed 's/.*test_pattern:\([^ ]*\).*/\1/')
    
    # Convert pattern to find command
    local find_cmd="find '$project_dir' -type f"
    
    # Add test pattern matching
    IFS=',' read -ra patterns <<< "$test_pattern"
    if [ ${#patterns[@]} -gt 0 ]; then
        find_cmd="$find_cmd \("
        for i in "${!patterns[@]}"; do
            pattern=${patterns[$i]}
            if [ $i -gt 0 ]; then
                find_cmd="$find_cmd -o"
            fi
            find_cmd="$find_cmd -name '${pattern#**/}'"
        done
        find_cmd="$find_cmd \)"
    fi
    
    # Add exclusions
    for exclude in $exclude_patterns; do
        find_cmd="$find_cmd ! -path '*/$exclude/*'"
    done
    
    eval "$find_cmd" 2>/dev/null | sort
}

# Get test file statistics
get_test_file_stats() {
    local project_dir=${1:-.}
    local framework=${2:-"auto"}
    
    local test_files=$(find_test_files "$project_dir" "$framework")
    local total_tests=$(echo "$test_files" | wc -l)
    local total_size=0
    
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            total_size=$((total_size + size))
        fi
    done <<< "$test_files"
    
    echo "total_files:$total_tests total_size:$total_size"
}

# Find orphaned test files (tests without corresponding source files)
find_orphaned_tests() {
    local project_dir=${1:-.}
    local framework=${2:-"auto"}
    
    local test_files=$(find_test_files "$project_dir" "$framework")
    local orphaned_tests=()
    
    while IFS= read -r test_file; do
        if [ -f "$test_file" ]; then
            # Try to find corresponding source file
            local source_file=$(infer_source_file "$test_file" "$framework")
            if [ -n "$source_file" ] && [ ! -f "$source_file" ]; then
                orphaned_tests+=("$test_file")
            fi
        fi
    done <<< "$test_files"
    
    printf "%s\n" "${orphaned_tests[@]}"
}

# Infer source file from test file path
infer_source_file() {
    local test_file=$1
    local framework=$2
    
    case "$framework" in
        "jest"|"mocha")
            echo "$test_file" | sed 's/\.test\.js$/.js/' | sed 's/\.spec\.js$/.js/' | sed 's/\/test\//\/src\//' | sed 's/\/tests\//\/src\//'
            ;;
        "pytest")
            echo "$test_file" | sed 's/^test_//' | sed 's/_test\.py$/.py/' | sed 's/\/test\//\/src\//' | sed 's/\/tests\//\/src\//'
            ;;
        "go-test")
            echo "$test_file" | sed 's/_test\.go$/.go/'
            ;;
        "rspec")
            echo "$test_file" | sed 's/_spec\.rb$/.rb/' | sed 's/\/spec\//\/lib\//' | sed 's/\/specs\//\/lib\//'
            ;;
        *)
            echo ""
            ;;
    esac
}
```

## Execution Utilities

```bash
# Execute test command with proper environment setup
execute_test_command() {
    local framework=$1
    local project_dir=${2:-.}
    local test_args=${3:-""}
    local timeout=${4:-300}
    
    local config=$(get_framework_config "$framework" "$project_dir")
    local base_command=$(echo "$config" | sed 's/.*command:\([^ ]*\).*/\1/')
    
    # Setup environment
    cd "$project_dir" || return 1
    
    # Execute with timeout
    timeout "$timeout" $base_command $test_args
}

# Run specific test file
run_test_file() {
    local test_file=$1
    local framework=${2:-"auto"}
    local project_dir=${3:-.}
    
    if [ "$framework" = "auto" ]; then
        framework=$(detect_test_framework "$project_dir" | head -1)
    fi
    
    case "$framework" in
        "jest")
            npx jest "$test_file"
            ;;
        "pytest")
            python -m pytest "$test_file"
            ;;
        "go-test")
            go test "$(dirname "$test_file")"
            ;;
        "rspec")
            bundle exec rspec "$test_file"
            ;;
        "mocha")
            npx mocha "$test_file"
            ;;
        "phpunit")
            ./vendor/bin/phpunit "$test_file" 2>/dev/null || phpunit "$test_file"
            ;;
        *)
            echo "ERROR: Unsupported framework: $framework"
            return 1
            ;;
    esac
}

# Parse test results
parse_test_results() {
    local framework=$1
    local output_file=$2
    
    case "$framework" in
        "jest")
            grep -E "(PASS|FAIL|Tests:|Suites:)" "$output_file" | tail -5
            ;;
        "pytest")
            grep -E "(PASSED|FAILED|ERROR|passed|failed|error)" "$output_file" | tail -10
            ;;
        "go-test")
            grep -E "(PASS|FAIL|ok|FAIL)" "$output_file"
            ;;
        "rspec")
            grep -E "([0-9]+ examples?|[0-9]+ failures?|[0-9]+ pending)" "$output_file"
            ;;
        "phpunit")
            grep -E "(OK \([0-9]+ tests?|FAILURES!|Tests: [0-9]+)" "$output_file"
            ;;
        *)
            cat "$output_file"
            ;;
    esac
}
```

## PHP Framework and Structure Support

```bash
# Detect PHP framework
detect_php_framework() {
    local project_dir=${1:-.}
    
    # Laravel detection
    if [ -f "$project_dir/artisan" ] && [ -f "$project_dir/composer.json" ]; then
        if grep -q "laravel/framework" "$project_dir/composer.json" 2>/dev/null; then
            echo "framework:laravel"
            return 0
        fi
    fi
    
    # Symfony detection
    if [ -f "$project_dir/bin/console" ] && [ -f "$project_dir/composer.json" ]; then
        if grep -q "symfony/framework-bundle\|symfony/console" "$project_dir/composer.json" 2>/dev/null; then
            echo "framework:symfony"
            return 0
        fi
    fi
    
    # Pure PHP detection (composer.json exists but no specific framework)
    if [ -f "$project_dir/composer.json" ]; then
        echo "framework:php"
        return 0
    fi
    
    # No PHP framework detected
    return 1
}

# Check if PHP structure generation is disabled
is_php_structure_disabled() {
    local project_dir=${1:-.}
    
    # Check environment variable
    if [ "${CLAUDE_PHP_TESTS:-}" = "false" ]; then
        return 0
    fi
    
    # Check for .claude/no-php-tests file
    if [ -f "$project_dir/.claude/no-php-tests" ]; then
        return 0
    fi
    
    # Check for project-specific disable file
    if [ -f "$project_dir/.no-php-structure" ]; then
        return 0
    fi
    
    # PHP structure generation is enabled
    return 1
}

# Parse command line arguments for PHP-specific flags
parse_php_test_flags() {
    local args="$*"
    local php_disabled=false
    local skip_structure_check=false
    
    # Check for --no-php flag
    if echo "$args" | grep -q -- "--no-php"; then
        php_disabled=true
    fi
    
    # Check for --skip-php-structure-check flag
    if echo "$args" | grep -q -- "--skip-php-structure-check"; then
        skip_structure_check=true
    fi
    
    echo "php_disabled:$php_disabled skip_structure_check:$skip_structure_check"
}

# Display PHP control mechanisms information
show_php_control_help() {
    echo ""
    echo "=== PHP Structure Control Mechanisms ==="
    echo ""
    echo "To disable PHP-specific test structure generation and validation:"
    echo ""
    echo "1. Environment Variable:"
    echo "   export CLAUDE_PHP_TESTS=false"
    echo ""
    echo "2. Project-level disable file:"
    echo "   touch .claude/no-php-tests"
    echo "   # OR"
    echo "   touch .no-php-structure"
    echo ""
    echo "3. Command-line flags:"
    echo "   --no-php                     Skip all PHP-specific behaviors"
    echo "   --skip-php-structure-check   Skip PHP structure validation only"
    echo ""
    echo "4. Alternative test structures for non-PHP projects:"
    echo "   - Use standard test/ directory structure"
    echo "   - Framework-specific patterns (Jest, pytest, Go test, etc.)"
    echo "   - Custom test organization based on project needs"
    echo ""
}

# Get PHP-aware messaging based on opt-out status
get_php_status_message() {
    local project_dir=${1:-.}
    local command_args=${2:-""}
    
    # Parse command flags
    local flags=$(parse_php_test_flags "$command_args")
    local php_disabled_flag=$(echo "$flags" | sed 's/.*php_disabled:\([^ ]*\).*/\1/')
    local skip_structure_flag=$(echo "$flags" | sed 's/.*skip_structure_check:\([^ ]*\).*/\1/')
    
    # Check if PHP is disabled via any method
    if [ "$php_disabled_flag" = "true" ] || is_php_structure_disabled "$project_dir"; then
        echo "PHP structure generation: DISABLED"
        if [ "$php_disabled_flag" = "true" ]; then
            echo "Reason: --no-php flag specified"
        elif [ "${CLAUDE_PHP_TESTS:-}" = "false" ]; then
            echo "Reason: CLAUDE_PHP_TESTS=false environment variable"
        elif [ -f "$project_dir/.claude/no-php-tests" ]; then
            echo "Reason: .claude/no-php-tests file found"
        elif [ -f "$project_dir/.no-php-structure" ]; then
            echo "Reason: .no-php-structure file found"
        fi
        return 0
    fi
    
    # Check if only structure check is skipped
    if [ "$skip_structure_flag" = "true" ]; then
        echo "PHP structure validation: SKIPPED (--skip-php-structure-check flag)"
        return 0
    fi
    
    # PHP features are enabled
    if detect_php_framework "$project_dir" >/dev/null 2>&1; then
        local framework=$(detect_php_framework "$project_dir" | cut -d: -f2)
        echo "PHP structure generation: ENABLED (detected: $framework)"
    else
        echo "PHP structure generation: ENABLED (no PHP framework detected)"
    fi
    
    return 0
}

## 🚨 **100% TEST SUCCESS RATE VALIDATION UTILITIES**

# Validate test execution success rate - MUST be 100%
validate_test_success_rate() {
    local exit_code=$1
    local test_type=${2:-"tests"}
    local framework=${3:-"unknown"}
    
    if [ $exit_code -ne 0 ]; then
        echo ""
        echo "🚨🚨🚨 **$test_type EXECUTION BLOCKED** 🚨🚨🚨"
        echo "❌ TEST SUCCESS RATE: LESS THAN 100%"
        echo "❌ EXIT CODE: $exit_code (NON-ZERO = FAILURE)"
        echo "❌ FRAMEWORK: $framework"
        echo ""
        echo "🛑 **EXECUTION HALTED - ALL TEST FAILURES MUST BE FIXED BEFORE PROCEEDING**"
        echo ""
        echo "Required Actions:"
        echo "1. Fix all failing $test_type"
        echo "2. Ensure 100% test success rate"
        echo "3. Re-run test execution"
        echo ""
        echo "🚨 **NO FURTHER STEPS UNTIL 100% SUCCESS RATE ACHIEVED**"
        return $exit_code
    fi
    
    echo ""
    echo "✅✅✅ **100% $test_type SUCCESS ACHIEVED** ✅✅✅"
    echo "✅ All $test_type passed successfully"
    echo "✅ Framework: $framework"
    echo "✅ Proceeding with next steps"
    echo ""
    
    return 0
}

# Block execution if test failures detected
block_on_test_failures() {
    local exit_code=$1
    local test_type=${2:-"tests"}
    local additional_context=${3:-""}
    
    if [ $exit_code -ne 0 ]; then
        echo ""
        echo "🛑🛑🛑 **CRITICAL FAILURE: $test_type MUST ACHIEVE 100% SUCCESS** 🛑🛑🛑"
        echo ""
        echo "FAILURE DETAILS:"
        echo "- Test Type: $test_type"
        echo "- Exit Code: $exit_code"
        echo "- Success Rate: LESS THAN 100% (UNACCEPTABLE)"
        if [ -n "$additional_context" ]; then
            echo "- Context: $additional_context"
        fi
        echo ""
        echo "MANDATORY REQUIREMENTS:"
        echo "- ALL tests must pass (100% success rate)"
        echo "- NO failing tests are acceptable"
        echo "- Fix ALL failures before proceeding"
        echo ""
        echo "🚨 **EXECUTION PERMANENTLY BLOCKED UNTIL 100% SUCCESS ACHIEVED** 🚨"
        exit $exit_code
    fi
}

# Check if any test file has recent failures
check_for_recent_test_failures() {
    local project_dir=${1:-.}
    local framework=${2:-"auto"}
    
    # Look for common test failure indicators
    local failure_indicators=(
        "test-results.xml"
        "junit.xml"
        "coverage/lcov-report/index.html"
        ".nyc_output"
        "pytest_cache"
        "target/surefire-reports"
    )
    
    local recent_failures=0
    
    for indicator in "${failure_indicators[@]}"; do
        if [ -f "$project_dir/$indicator" ] || [ -d "$project_dir/$indicator" ]; then
            # Check if file/directory was modified recently (within last hour)
            if [ $(find "$project_dir/$indicator" -mmin -60 2>/dev/null | wc -l) -gt 0 ]; then
                echo "⚠️ Recent test activity detected: $indicator"
                ((recent_failures++))
            fi
        fi
    done
    
    if [ $recent_failures -gt 0 ]; then
        echo ""
        echo "🚨 WARNING: Recent test execution artifacts found"
        echo "   Ensure all tests are currently passing at 100% before proceeding"
        echo "   Run tests manually to verify current status"
        echo ""
    fi
    
    return $recent_failures
}

# Enforce 100% success rate across all test types
enforce_100_percent_success() {
    echo ""
    echo "🚨 **CRITICAL ENFORCEMENT: 100% TEST SUCCESS RATE MANDATORY** 🚨"
    echo ""
    echo "ENFORCEMENT POLICY:"
    echo "- Unit Tests: 100% success rate required"
    echo "- Integration Tests: 100% success rate required"
    echo "- End-to-End Tests: 100% success rate required"
    echo "- Performance Tests: 100% success rate required"
    echo "- ALL Test Types: 100% success rate required"
    echo ""
    echo "NO EXCEPTIONS. NO PARTIAL SUCCESS. NO 'GOOD ENOUGH'."
    echo ""
    echo "✅ FIX ALL FAILURES BEFORE PROCEEDING ✅"
    echo ""
}

# Display test success rate requirements
show_test_success_requirements() {
    echo ""
    echo "=== 100% TEST SUCCESS RATE REQUIREMENTS ==="
    echo ""
    echo "MANDATORY POLICY:"
    echo "• ALL tests must pass (100% success rate)"
    echo "• Zero tolerance for test failures"
    echo "• Execution blocked on any test failure"
    echo "• Fix failures before proceeding"
    echo ""
    echo "APPLIES TO:"
    echo "• Unit tests (/test unit)"
    echo "• Integration tests (/test integration)"
    echo "• End-to-end tests (/test e2e)"
    echo "• Performance tests (/test performance)"
    echo "• All test command variants"
    echo ""
    echo "FAILURE HANDLING:"
    echo "• Immediate execution halt on failure"
    echo "• Clear error messages with fix instructions"
    echo "• No coverage analysis until 100% success"
    echo "• No deployment until 100% success"
    echo ""
    echo "📋 Remember: Quality is non-negotiable."
    echo ""
}

# Detect PHP annotation system
detect_php_annotations() {
    local project_dir=${1:-.}
    local annotation_script="$project_dir/test/test/annotation-automation.php"
    local annotation_shell="$project_dir/test/test/annotation-automation.sh"
    
    if [ -f "$annotation_script" ]; then
        echo "system:php script:$annotation_script shell:$annotation_shell"
        return 0
    else
        echo "ERROR: PHP annotation system not found"
        return 1
    fi
}

# Get annotation system configuration
get_annotation_system_config() {
    local project_dir=${1:-.}
    local config_file="$project_dir/test/test/annotation-automation.json"
    
    if [ -f "$config_file" ]; then
        echo "config_file:$config_file"
        if command -v php >/dev/null 2>&1; then
            echo "source_dir:$(php -r "echo json_decode(file_get_contents('$config_file'), true)['source_directory'] ?? 'src';" 2>/dev/null || echo 'src')"
            echo "test_dir:$(php -r "echo json_decode(file_get_contents('$config_file'), true)['test_directory'] ?? 'test/Cases';" 2>/dev/null || echo 'test/Cases')"
        else
            echo "source_dir:src test_dir:test/Cases"
        fi
    else
        echo "config_file: source_dir:src test_dir:test/Cases"
    fi
}

# Validate annotation system installation
validate_annotation_system() {
    local project_dir=${1:-.}
    local annotation_script="$project_dir/test/test/annotation-automation.php"
    local annotation_shell="$project_dir/test/test/annotation-automation.sh"
    
    # Check PHP availability
    if ! command -v php >/dev/null 2>&1; then
        echo "ERROR: PHP not found"
        return 1
    fi
    
    # Check annotation scripts
    if [ ! -f "$annotation_script" ]; then
        echo "ERROR: Annotation PHP script not found at $annotation_script"
        return 1
    fi
    
    if [ ! -f "$annotation_shell" ]; then
        echo "WARNING: Annotation shell script not found at $annotation_shell"
    fi
    
    # Check script permissions
    if [ ! -x "$annotation_script" ]; then
        echo "WARNING: Annotation PHP script not executable"
    fi
    
    if [ -f "$annotation_shell" ] && [ ! -x "$annotation_shell" ]; then
        echo "WARNING: Annotation shell script not executable"
    fi
    
    echo "✅ PHP annotation system validated"
    return 0
}

# Execute annotation command
execute_annotation_command() {
    local command=$1
    local project_dir=${2:-.}
    local format=${3:-"console"}
    local annotation_script="$project_dir/test/test/annotation-automation.php"
    local annotation_shell="$project_dir/test/test/annotation-automation.sh"
    
    # Validate system first
    if ! validate_annotation_system "$project_dir"; then
        return 1
    fi
    
    # Prefer shell script if available and executable
    if [ -f "$annotation_shell" ] && [ -x "$annotation_shell" ]; then
        "$annotation_shell" "$command" --format="$format"
    elif [ -f "$annotation_script" ]; then
        php "$annotation_script" "$command" --format="$format"
    else
        echo "ERROR: No annotation execution method available"
        return 1
    fi
}
```

## Cross-platform Compatibility

```bash
# Get platform-specific test command
get_platform_test_command() {
    local framework=$1
    local platform=$(uname -s)
    
    case "$platform" in
        "Darwin")  # macOS
            case "$framework" in
                "jest") echo "npm test -- --detectOpenHandles" ;;
                "pytest") echo "python -m pytest --tb=short" ;;
                *) echo "$(get_framework_config "$framework" | sed 's/.*command:\([^ ]*\).*/\1/')" ;;
            esac
            ;;
        "Linux")
            case "$framework" in
                "jest") echo "npm test -- --forceExit" ;;
                "pytest") echo "python -m pytest --tb=line" ;;
                *) echo "$(get_framework_config "$framework" | sed 's/.*command:\([^ ]*\).*/\1/')" ;;
            esac
            ;;
        "MINGW"*|"MSYS"*|"CYGWIN"*)  # Windows
            case "$framework" in
                "jest") echo "npm.cmd test" ;;
                "pytest") echo "python.exe -m pytest" ;;
                *) echo "$(get_framework_config "$framework" | sed 's/.*command:\([^ ]*\).*/\1/')" ;;
            esac
            ;;
        *)
            echo "$(get_framework_config "$framework" | sed 's/.*command:\([^ ]*\).*/\1/')"
            ;;
    esac
}

# Setup platform-specific environment
setup_test_environment() {
    local framework=$1
    local project_dir=${2:-.}
    local platform=$(uname -s)
    
    case "$platform" in
        "Darwin")
            export FORCE_COLOR=1
            export NODE_OPTIONS="--max-old-space-size=4096"
            ;;
        "Linux")
            export FORCE_COLOR=1
            export PYTHONPATH="$project_dir:$PYTHONPATH"
            ;;
        "MINGW"*|"MSYS"*|"CYGWIN"*)
            export FORCE_COLOR=0
            export PYTHONPATH="$project_dir;$PYTHONPATH"
            ;;
    esac
    
    # Framework-specific setup
    case "$framework" in
        "jest")
            export NODE_ENV=test
            ;;
        "pytest")
            export PYTHONDONTWRITEBYTECODE=1
            ;;
        "go-test")
            export CGO_ENABLED=1
            ;;
    esac
}
```