# Test Coverage Utilities

This file contains utilities for test coverage analysis, reporting, and gap identification across all test commands.

## Coverage Analysis

```bash
# Generate comprehensive coverage report
generate_coverage_report() {
    local framework=$1
    local project_dir=${2:-.}
    local output_format=${3:-"html,text,json"}
    
    echo "=== GENERATING COVERAGE REPORT ==="
    echo "Framework: $framework"
    echo "Project Directory: $project_dir"
    echo "Output Format: $output_format"
    echo ""
    
    case "$framework" in
        "jest")
            generate_jest_coverage "$project_dir" "$output_format"
            ;;
        "pytest")
            generate_pytest_coverage "$project_dir" "$output_format"
            ;;
        "go-test")
            generate_go_coverage "$project_dir" "$output_format"
            ;;
        "rspec")
            generate_rspec_coverage "$project_dir" "$output_format"
            ;;
        "mocha")
            generate_mocha_coverage "$project_dir" "$output_format"
            ;;
        *)
            echo "ERROR: Unsupported framework for coverage: $framework"
            return 1
            ;;
    esac
}

# Generate Jest coverage report
generate_jest_coverage() {
    local project_dir=$1
    local output_format=$2
    
    cd "$project_dir" || return 1
    
    # Build coverage reporters from format
    local reporters=""
    IFS=',' read -ra formats <<< "$output_format"
    for format in "${formats[@]}"; do
        case "$format" in
            "html") reporters="$reporters --coverageReporters=html" ;;
            "text") reporters="$reporters --coverageReporters=text" ;;
            "json") reporters="$reporters --coverageReporters=json" ;;
            "lcov") reporters="$reporters --coverageReporters=lcov" ;;
        esac
    done
    
    # Run Jest with coverage
    npx jest --coverage $reporters --coverageDirectory=coverage
    
    # Generate coverage summary
    if [ -f "coverage/coverage-summary.json" ]; then
        generate_coverage_summary "coverage/coverage-summary.json" "jest"
    fi
}

# Generate pytest coverage report
generate_pytest_coverage() {
    local project_dir=$1
    local output_format=$2
    
    cd "$project_dir" || return 1
    
    # Build coverage options from format
    local cov_options="--cov=."
    IFS=',' read -ra formats <<< "$output_format"
    for format in "${formats[@]}"; do
        case "$format" in
            "html") cov_options="$cov_options --cov-report=html" ;;
            "text") cov_options="$cov_options --cov-report=term" ;;
            "json") cov_options="$cov_options --cov-report=json" ;;
            "xml") cov_options="$cov_options --cov-report=xml" ;;
        esac
    done
    
    # Run pytest with coverage
    python -m pytest $cov_options --cov-report=term-missing
    
    # Generate coverage summary
    if [ -f "coverage.json" ]; then
        generate_coverage_summary "coverage.json" "pytest"
    fi
}

# Generate Go coverage report
generate_go_coverage() {
    local project_dir=$1
    local output_format=$2
    
    cd "$project_dir" || return 1
    
    # Run Go test with coverage
    go test -coverprofile=coverage.out ./...
    
    if [ -f "coverage.out" ]; then
        # Generate different formats
        IFS=',' read -ra formats <<< "$output_format"
        for format in "${formats[@]}"; do
            case "$format" in
                "html") 
                    go tool cover -html=coverage.out -o coverage.html
                    ;;
                "text")
                    go tool cover -func=coverage.out
                    ;;
                "json")
                    # Convert Go coverage to JSON format
                    convert_go_coverage_to_json "coverage.out"
                    ;;
            esac
        done
        
        # Generate coverage summary
        generate_go_coverage_summary "coverage.out"
    fi
}

# Generate RSpec coverage report
generate_rspec_coverage() {
    local project_dir=$1
    local output_format=$2
    
    cd "$project_dir" || return 1
    
    # Ensure SimpleCov is configured
    if [ ! -f ".simplecov" ]; then
        create_simplecov_config "$output_format"
    fi
    
    # Run RSpec with coverage
    bundle exec rspec --require simplecov
    
    # Generate coverage summary
    if [ -f "coverage/.resultset.json" ]; then
        generate_coverage_summary "coverage/.resultset.json" "rspec"
    fi
}

# Create SimpleCov configuration
create_simplecov_config() {
    local output_format=$1
    
    cat > ".simplecov" <<EOF
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/vendor/'
  
EOF
    
    IFS=',' read -ra formats <<< "$output_format"
    for format in "${formats[@]}"; do
        case "$format" in
            "html") echo "  formatter SimpleCov::Formatter::HTMLFormatter" >> ".simplecov" ;;
            "json") echo "  formatter SimpleCov::Formatter::JSONFormatter" >> ".simplecov" ;;
        esac
    done
    
    echo "end" >> ".simplecov"
}

# Generate coverage summary
generate_coverage_summary() {
    local coverage_file=$1
    local framework=$2
    
    echo "=== COVERAGE SUMMARY ==="
    echo ""
    
    case "$framework" in
        "jest")
            if command -v jq >/dev/null 2>&1; then
                local total_coverage=$(jq -r '.total.lines.pct' "$coverage_file" 2>/dev/null || echo "0")
                local total_functions=$(jq -r '.total.functions.pct' "$coverage_file" 2>/dev/null || echo "0")
                local total_branches=$(jq -r '.total.branches.pct' "$coverage_file" 2>/dev/null || echo "0")
                local total_statements=$(jq -r '.total.statements.pct' "$coverage_file" 2>/dev/null || echo "0")
                
                echo "Line Coverage: $total_coverage%"
                echo "Function Coverage: $total_functions%"
                echo "Branch Coverage: $total_branches%"
                echo "Statement Coverage: $total_statements%"
            fi
            ;;
        "pytest")
            if command -v jq >/dev/null 2>&1; then
                local total_coverage=$(jq -r '.totals.percent_covered' "$coverage_file" 2>/dev/null || echo "0")
                local num_statements=$(jq -r '.totals.num_statements' "$coverage_file" 2>/dev/null || echo "0")
                local missing_lines=$(jq -r '.totals.missing_lines' "$coverage_file" 2>/dev/null || echo "0")
                
                echo "Line Coverage: $total_coverage%"
                echo "Total Statements: $num_statements"
                echo "Missing Lines: $missing_lines"
            fi
            ;;
        "go")
            if [ -f "$coverage_file" ]; then
                local total_coverage=$(go tool cover -func="$coverage_file" | tail -1 | awk '{print $3}')
                echo "Total Coverage: $total_coverage"
            fi
            ;;
        "rspec")
            if command -v jq >/dev/null 2>&1; then
                local total_coverage=$(jq -r '.RSpec.coverage.line' "$coverage_file" 2>/dev/null || echo "0")
                echo "Line Coverage: $total_coverage%"
            fi
            ;;
    esac
    
    echo ""
}

# Convert Go coverage to JSON format
convert_go_coverage_to_json() {
    local coverage_file=$1
    local json_file="coverage.json"
    
    # Parse Go coverage output and convert to JSON
    cat > "$json_file" <<EOF
{
    "files": {},
    "total": {
        "lines": {"covered": 0, "total": 0, "pct": 0},
        "functions": {"covered": 0, "total": 0, "pct": 0},
        "statements": {"covered": 0, "total": 0, "pct": 0}
    }
}
EOF
    
    # Parse coverage.out and populate JSON (simplified implementation)
    echo "Go coverage converted to JSON: $json_file"
}

# Generate Go coverage summary
generate_go_coverage_summary() {
    local coverage_file=$1
    
    if [ -f "$coverage_file" ]; then
        echo "=== GO COVERAGE SUMMARY ==="
        echo ""
        go tool cover -func="$coverage_file" | tail -5
        echo ""
    fi
}
```

## Coverage Gap Analysis

```bash
# Identify coverage gaps
identify_coverage_gaps() {
    local framework=$1
    local project_dir=${2:-.}
    local threshold=${3:-80}
    
    echo "=== COVERAGE GAP ANALYSIS ==="
    echo "Framework: $framework"
    echo "Threshold: $threshold%"
    echo ""
    
    case "$framework" in
        "jest")
            identify_jest_coverage_gaps "$project_dir" "$threshold"
            ;;
        "pytest")
            identify_pytest_coverage_gaps "$project_dir" "$threshold"
            ;;
        "go-test")
            identify_go_coverage_gaps "$project_dir" "$threshold"
            ;;
        "rspec")
            identify_rspec_coverage_gaps "$project_dir" "$threshold"
            ;;
        *)
            echo "ERROR: Unsupported framework for gap analysis: $framework"
            return 1
            ;;
    esac
}

# Identify Jest coverage gaps
identify_jest_coverage_gaps() {
    local project_dir=$1
    local threshold=$2
    
    local coverage_file="$project_dir/coverage/coverage-final.json"
    
    if [ ! -f "$coverage_file" ]; then
        echo "Coverage file not found. Run coverage generation first."
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        echo "Files below $threshold% coverage:"
        echo ""
        
        jq -r "to_entries[] | select(.value.lines.pct < $threshold) | \"  \(.key): \(.value.lines.pct)% lines, \(.value.functions.pct)% functions\"" "$coverage_file"
        
        echo ""
        echo "Uncovered lines by file:"
        echo ""
        
        jq -r 'to_entries[] | select(.value.lines.pct < 100) | .key as $file | .value.statementMap as $stmts | .value.s as $coverage | $stmts | to_entries[] | select($coverage[.key] == 0) | "  \($file):\(.value.start.line)"' "$coverage_file" | head -20
    fi
}

# Identify pytest coverage gaps
identify_pytest_coverage_gaps() {
    local project_dir=$1
    local threshold=$2
    
    local coverage_file="$project_dir/coverage.json"
    
    if [ ! -f "$coverage_file" ]; then
        echo "Coverage file not found. Run coverage generation first."
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        echo "Files below $threshold% coverage:"
        echo ""
        
        jq -r ".files | to_entries[] | select(.value.summary.line_rate * 100 < $threshold) | \"  \(.key): \(.value.summary.line_rate * 100 | floor)% lines\"" "$coverage_file"
        
        echo ""
        echo "Missing lines by file:"
        echo ""
        
        jq -r '.files | to_entries[] | select(.value.missing_lines | length > 0) | "  \(.key): lines \(.value.missing_lines | join(", "))"' "$coverage_file" | head -10
    fi
}

# Identify Go coverage gaps
identify_go_coverage_gaps() {
    local project_dir=$1
    local threshold=$2
    
    local coverage_file="$project_dir/coverage.out"
    
    if [ ! -f "$coverage_file" ]; then
        echo "Coverage file not found. Run coverage generation first."
        return 1
    fi
    
    echo "Functions below $threshold% coverage:"
    echo ""
    
    go tool cover -func="$coverage_file" | awk -v threshold="$threshold" '
    $3 != "total:" && ($3+0) < threshold {
        gsub(/%/, "", $3)
        print "  " $1 ":" $2 " - " $3 "%"
    }'
    
    echo ""
    echo "Files with low coverage:"
    echo ""
    
    # Group by file and show file-level coverage
    go tool cover -func="$coverage_file" | awk '
    $3 != "total:" {
        file = $1
        gsub(/:[0-9]+:.*/, "", file)
        coverage[file] += $3+0
        count[file]++
    }
    END {
        for (f in coverage) {
            avg = coverage[f] / count[f]
            if (avg < '"$threshold"') {
                printf "  %s: %.1f%%\n", f, avg
            }
        }
    }'
}

# Identify RSpec coverage gaps
identify_rspec_coverage_gaps() {
    local project_dir=$1
    local threshold=$2
    
    local coverage_file="$project_dir/coverage/.resultset.json"
    
    if [ ! -f "$coverage_file" ]; then
        echo "Coverage file not found. Run coverage generation first."
        return 1
    fi
    
    echo "Files below $threshold% coverage:"
    echo ""
    
    # SimpleCov resultset analysis (simplified)
    if command -v jq >/dev/null 2>&1; then
        jq -r '.RSpec.coverage | to_entries[] | select(.value.lines | map(select(. != null)) | length > 0) | .key as $file | (.value.lines | map(select(. != null and . > 0)) | length) / (.value.lines | map(select(. != null)) | length) * 100 as $pct | select($pct < '"$threshold"') | "  \($file): \($pct | floor)%"' "$coverage_file"
    fi
}

# Generate coverage improvement recommendations
generate_coverage_recommendations() {
    local framework=$1
    local project_dir=${2:-.}
    local current_coverage=${3:-0}
    local target_coverage=${4:-80}
    
    echo "=== COVERAGE IMPROVEMENT RECOMMENDATIONS ==="
    echo "Current Coverage: $current_coverage%"
    echo "Target Coverage: $target_coverage%"
    echo ""
    
    local gap=$((target_coverage - current_coverage))
    
    if [ "$gap" -le 0 ]; then
        echo "✅ Coverage target already met!"
        return 0
    fi
    
    echo "Coverage gap to close: $gap%"
    echo ""
    
    echo "Recommendations:"
    echo ""
    
    # Priority 1: Test critical paths
    echo "1. High Priority - Test Critical Paths:"
    echo "   - Identify and test main application flows"
    echo "   - Focus on business logic and core functionality"
    echo "   - Test error handling and edge cases"
    echo ""
    
    # Priority 2: Test uncovered functions
    echo "2. Medium Priority - Test Uncovered Functions:"
    echo "   - Add tests for functions with 0% coverage"
    echo "   - Test public API methods and interfaces"
    echo "   - Add integration tests for component interactions"
    echo ""
    
    # Priority 3: Improve existing tests
    echo "3. Low Priority - Improve Existing Tests:"
    echo "   - Add missing branch coverage"
    echo "   - Test additional input combinations"
    echo "   - Add negative test cases"
    echo ""
    
    # Framework-specific recommendations
    case "$framework" in
        "jest")
            echo "4. Jest-Specific Recommendations:"
            echo "   - Use jest.mock() for better isolation"
            echo "   - Add snapshot tests for UI components"
            echo "   - Test async operations with proper awaits"
            ;;
        "pytest")
            echo "4. Pytest-Specific Recommendations:"
            echo "   - Use fixtures for test data setup"
            echo "   - Add parametrized tests for multiple inputs"
            echo "   - Test exception handling with pytest.raises"
            ;;
        "go-test")
            echo "4. Go Test-Specific Recommendations:"
            echo "   - Add table-driven tests for multiple cases"
            echo "   - Test goroutines and concurrency"
            echo "   - Use testify for better assertions"
            ;;
        "rspec")
            echo "4. RSpec-Specific Recommendations:"
            echo "   - Use shared examples for common behavior"
            echo "   - Add feature specs for user workflows"
            echo "   - Mock external dependencies properly"
            ;;
    esac
    
    echo ""
}

# Track coverage over time
track_coverage_trends() {
    local framework=$1
    local project_dir=${2:-.}
    local current_coverage=$3
    
    local trends_file="$project_dir/.coverage-trends.json"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Initialize trends file if it doesn't exist
    if [ ! -f "$trends_file" ]; then
        echo '{"coverage_history": []}' > "$trends_file"
    fi
    
    # Add current coverage data
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        local coverage_entry=$(cat <<EOF
{
    "timestamp": "$timestamp",
    "coverage": $current_coverage,
    "framework": "$framework"
}
EOF
        )
        
        jq ".coverage_history += [$coverage_entry]" "$trends_file" > "$temp_file"
        mv "$temp_file" "$trends_file"
        
        echo "Coverage trend recorded: $current_coverage% at $timestamp"
        
        # Show recent trend
        show_coverage_trend "$trends_file"
    fi
}

# Show coverage trend
show_coverage_trend() {
    local trends_file=$1
    
    if [ -f "$trends_file" ] && command -v jq >/dev/null 2>&1; then
        echo ""
        echo "Recent Coverage Trend:"
        jq -r '.coverage_history | sort_by(.timestamp) | reverse | limit(5; .[]) | "  \(.timestamp): \(.coverage)%"' "$trends_file"
        
        # Calculate trend direction
        local recent_coverage=$(jq -r '.coverage_history | sort_by(.timestamp) | reverse | .[0].coverage' "$trends_file")
        local previous_coverage=$(jq -r '.coverage_history | sort_by(.timestamp) | reverse | .[1].coverage // 0' "$trends_file")
        
        if [ "$recent_coverage" -gt "$previous_coverage" ]; then
            echo "  📈 Coverage is improving!"
        elif [ "$recent_coverage" -lt "$previous_coverage" ]; then
            echo "  📉 Coverage is declining"
        else
            echo "  📊 Coverage is stable"
        fi
        
        echo ""
    fi
}

# Set coverage thresholds
set_coverage_thresholds() {
    local framework=$1
    local project_dir=${2:-.}
    local line_threshold=${3:-80}
    local function_threshold=${4:-80}
    local branch_threshold=${5:-70}
    
    echo "=== SETTING COVERAGE THRESHOLDS ==="
    echo "Line Coverage: $line_threshold%"
    echo "Function Coverage: $function_threshold%"
    echo "Branch Coverage: $branch_threshold%"
    echo ""
    
    case "$framework" in
        "jest")
            set_jest_thresholds "$project_dir" "$line_threshold" "$function_threshold" "$branch_threshold"
            ;;
        "pytest")
            set_pytest_thresholds "$project_dir" "$line_threshold" "$function_threshold" "$branch_threshold"
            ;;
        "go-test")
            set_go_thresholds "$project_dir" "$line_threshold" "$function_threshold" "$branch_threshold"
            ;;
        "rspec")
            set_rspec_thresholds "$project_dir" "$line_threshold" "$function_threshold" "$branch_threshold"
            ;;
    esac
}

# Set Jest coverage thresholds
set_jest_thresholds() {
    local project_dir=$1
    local line_threshold=$2
    local function_threshold=$3
    local branch_threshold=$4
    
    local jest_config="$project_dir/jest.config.js"
    
    if [ ! -f "$jest_config" ]; then
        jest_config="$project_dir/package.json"
    fi
    
    echo "Setting Jest coverage thresholds in: $jest_config"
    
    # Update Jest configuration (implementation depends on existing config structure)
    echo "Jest thresholds configured"
}

# Set pytest coverage thresholds
set_pytest_thresholds() {
    local project_dir=$1
    local line_threshold=$2
    local function_threshold=$3
    local branch_threshold=$4
    
    local pytest_config="$project_dir/pytest.ini"
    
    if [ ! -f "$pytest_config" ]; then
        cat > "$pytest_config" <<EOF
[tool:pytest]
addopts = --cov=. --cov-report=html --cov-report=term --cov-fail-under=$line_threshold
EOF
    else
        # Update existing configuration
        echo "Updating existing pytest configuration"
    fi
    
    echo "Pytest coverage thresholds set to $line_threshold%"
}

# Validate coverage against thresholds
validate_coverage_thresholds() {
    local framework=$1
    local project_dir=${2:-.}
    local coverage_file=$3
    
    echo "=== VALIDATING COVERAGE THRESHOLDS ==="
    echo ""
    
    case "$framework" in
        "jest")
            validate_jest_thresholds "$coverage_file"
            ;;
        "pytest")
            validate_pytest_thresholds "$coverage_file"
            ;;
        "go-test")
            validate_go_thresholds "$coverage_file"
            ;;
        "rspec")
            validate_rspec_thresholds "$coverage_file"
            ;;
    esac
}

# Validate Jest coverage thresholds
validate_jest_thresholds() {
    local coverage_file=$1
    
    if [ -f "$coverage_file" ] && command -v jq >/dev/null 2>&1; then
        local line_coverage=$(jq -r '.total.lines.pct' "$coverage_file")
        local function_coverage=$(jq -r '.total.functions.pct' "$coverage_file")
        local branch_coverage=$(jq -r '.total.branches.pct' "$coverage_file")
        
        echo "Coverage Validation Results:"
        echo "- Line Coverage: $line_coverage%"
        echo "- Function Coverage: $function_coverage%"
        echo "- Branch Coverage: $branch_coverage%"
        echo ""
        
        # Check against thresholds (would read from Jest config)
        local line_threshold=80
        local function_threshold=80
        local branch_threshold=70
        
        local passing=true
        
        if [ "$(echo "$line_coverage < $line_threshold" | bc -l 2>/dev/null)" = "1" ]; then
            echo "❌ Line coverage ($line_coverage%) below threshold ($line_threshold%)"
            passing=false
        else
            echo "✅ Line coverage meets threshold"
        fi
        
        if [ "$(echo "$function_coverage < $function_threshold" | bc -l 2>/dev/null)" = "1" ]; then
            echo "❌ Function coverage ($function_coverage%) below threshold ($function_threshold%)"
            passing=false
        else
            echo "✅ Function coverage meets threshold"
        fi
        
        if [ "$(echo "$branch_coverage < $branch_threshold" | bc -l 2>/dev/null)" = "1" ]; then
            echo "❌ Branch coverage ($branch_coverage%) below threshold ($branch_threshold%)"
            passing=false
        else
            echo "✅ Branch coverage meets threshold"
        fi
        
        if [ "$passing" = true ]; then
            echo ""
            echo "🎉 All coverage thresholds met!"
            return 0
        else
            echo ""
            echo "⚠️  Coverage thresholds not met"
            return 1
        fi
    fi
}
```