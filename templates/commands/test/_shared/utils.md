# Test Framework Utilities

This file contains shared utilities for test framework detection, file discovery, and execution across all test commands.

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
        *)
            cat "$output_file"
            ;;
    esac
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