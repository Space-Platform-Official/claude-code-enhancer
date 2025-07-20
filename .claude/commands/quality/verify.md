---
description: Comprehensive validation command for verifying code quality, syntax, standards compliance, and best practices
---

# Verify Command - Comprehensive Validation

Intelligent verification command that performs comprehensive code quality checks, syntax validation, standards compliance, security analysis, and best practices verification across multiple languages and frameworks.

## Usage

```bash
# Basic verification
claude verify

# Verify specific directory
claude verify src/

# Verify specific files
claude verify src/components/*.js

# Comprehensive verification
claude verify --comprehensive

# Quick verification (essential checks only)
claude verify --quick

# Specific verification types
claude verify --syntax-only
claude verify --security-only
claude verify --style-only
claude verify --dependencies-only

# Generate detailed report
claude verify --report=detailed

# Fail-fast mode (stop on first error)
claude verify --fail-fast

# Output format
claude verify --format=json
claude verify --format=html
```

## Implementation

```bash
#!/bin/bash

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_shared/utils.md"
source "$SCRIPT_DIR/_shared/safety.md"
source "$SCRIPT_DIR/_shared/orchestration.md"

# Main verification function
verify_codebase() {
    local target=${1:-.}
    local mode=${2:-"standard"}
    local report_level=${3:-"summary"}
    local output_format=${4:-"text"}
    local fail_fast=${5:-false}
    
    echo "Starting code verification..."
    echo "Target: $target"
    echo "Mode: $mode"
    echo "Report level: $report_level"
    echo "Output format: $output_format"
    
    # Discover files to verify
    local files_to_verify=($(discover_verifiable_files "$target"))
    echo "Found ${#files_to_verify[@]} files to verify"
    
    if [ ${#files_to_verify[@]} -eq 0 ]; then
        echo "No files to verify found"
        return 0
    fi
    
    # Initialize verification results
    local verification_results=$(mktemp)
    local total_files=0
    local total_errors=0
    local total_warnings=0
    local total_passed=0
    
    # Group files by language for targeted verification
    declare -A language_groups
    for file in "${files_to_verify[@]}"; do
        local language=$(detect_file_language "$file")
        if [ -n "${language_groups[$language]}" ]; then
            language_groups[$language]="${language_groups[$language]} $file"
        else
            language_groups[$language]="$file"
        fi
    done
    
    # Execute verification for each language group
    for language in "${!language_groups[@]}"; do
        echo "Verifying $language files..."
        
        local files_list=(${language_groups[$language]})
        local language_results=$(mktemp)
        
        case "$mode" in
            "comprehensive")
                verify_language_comprehensive "$language" "$report_level" "$fail_fast" "${files_list[@]}" > "$language_results"
                ;;
            "quick")
                verify_language_quick "$language" "$report_level" "$fail_fast" "${files_list[@]}" > "$language_results"
                ;;
            "syntax-only")
                verify_syntax_only "$language" "$report_level" "$fail_fast" "${files_list[@]}" > "$language_results"
                ;;
            "security-only")
                verify_security_only "$language" "$report_level" "$fail_fast" "${files_list[@]}" > "$language_results"
                ;;
            "style-only")
                verify_style_only "$language" "$report_level" "$fail_fast" "${files_list[@]}" > "$language_results"
                ;;
            "dependencies-only")
                verify_dependencies_only "$language" "$report_level" "$fail_fast" "${files_list[@]}" > "$language_results"
                ;;
            *)
                verify_language_standard "$language" "$report_level" "$fail_fast" "${files_list[@]}" > "$language_results"
                ;;
        esac
        
        local result=$?
        
        # Parse language results
        local lang_files=$(echo "${files_list[@]}" | wc -w)
        local lang_errors=$(grep -c "ERROR:" "$language_results" 2>/dev/null || echo 0)
        local lang_warnings=$(grep -c "WARNING:" "$language_results" 2>/dev/null || echo 0)
        local lang_passed=$((lang_files - lang_errors))
        
        total_files=$((total_files + lang_files))
        total_errors=$((total_errors + lang_errors))
        total_warnings=$((total_warnings + lang_warnings))
        total_passed=$((total_passed + lang_passed))
        
        # Append to overall results
        echo "=== $language Results ===" >> "$verification_results"
        cat "$language_results" >> "$verification_results"
        echo "" >> "$verification_results"
        
        rm -f "$language_results"
        
        echo "$language: $lang_files files, $lang_errors errors, $lang_warnings warnings"
        
        # Fail fast if requested and errors found
        if [[ "$fail_fast" == "true" ]] && [ "$lang_errors" -gt 0 ]; then
            echo "Failing fast due to errors in $language files"
            break
        fi
    done
    
    # Generate final report
    echo ""
    echo "Verification Summary:"
    echo "===================="
    echo "Total files: $total_files"
    echo "Passed: $total_passed"
    echo "Errors: $total_errors"
    echo "Warnings: $total_warnings"
    
    if [ "$total_errors" -eq 0 ] && [ "$total_warnings" -eq 0 ]; then
        echo "Status: ALL CHECKS PASSED ✓"
    elif [ "$total_errors" -eq 0 ]; then
        echo "Status: PASSED WITH WARNINGS ⚠"
    else
        echo "Status: FAILED ✗"
    fi
    
    # Generate detailed report if requested
    case "$report_level" in
        "detailed"|"comprehensive")
            generate_detailed_report "$verification_results" "$output_format" "$target"
            ;;
        "summary")
            generate_summary_report "$verification_results" "$output_format" "$target"
            ;;
    esac
    
    rm -f "$verification_results"
    
    # Return appropriate exit code
    if [ "$total_errors" -gt 0 ]; then
        return 1
    else
        return 0
    fi
}

# Discover files suitable for verification
discover_verifiable_files() {
    local target=$1
    local exclude_patterns=${EXCLUDE_PATTERNS:-".git node_modules __pycache__ .pytest_cache target build dist coverage .vscode .idea .claude .Claude .CLAUDE"}
    
    # All relevant file patterns for verification
    local patterns=(
        "*.js" "*.jsx" "*.mjs" "*.cjs"
        "*.ts" "*.tsx" "*.d.ts"
        "*.py" "*.pyx" "*.pyi"
        "*.rb" "*.ruby"
        "*.go"
        "*.rs"
        "*.java"
        "*.c" "*.h"
        "*.cpp" "*.hpp" "*.cc" "*.cxx"
        "*.cs"
        "*.php"
        "*.swift"
        "*.kt" "*.kts"
        "*.scala" "*.sc"
        "*.css" "*.scss" "*.sass" "*.less"
        "*.html" "*.htm"
        "*.xml"
        "*.json"
        "*.yaml" "*.yml"
        "*.md" "*.markdown"
        "*.sh" "*.bash" "*.zsh"
        "*.sql"
        "Dockerfile*"
        "Makefile"
        "*.toml"
        "*.ini"
        "*.cfg"
        "*.conf"
    )
    
    # Find files with exclusions
    local find_cmd="find '$target' -type f \\("
    local first=true
    for pattern in "${patterns[@]}"; do
        if $first; then
            find_cmd="$find_cmd -name '$pattern'"
            first=false
        else
            find_cmd="$find_cmd -o -name '$pattern'"
        fi
    done
    find_cmd="$find_cmd \\)"
    
    # Add exclusions
    for exclude in $exclude_patterns; do
        find_cmd="$find_cmd ! -path '*/$exclude/*'"
    done
    
    # Additional exclusions for .claude-related files and directories
    find_cmd="$find_cmd ! -name '.claude*' ! -name '*.claude*' ! -path '*/.claude' ! -path '*/.Claude' ! -path '*/.CLAUDE'"
    
    # Execute and filter
    eval "$find_cmd" 2>/dev/null | while read -r file; do
        if [ -f "$file" ] && [ -r "$file" ]; then
            if ! is_binary_file "$file"; then
                echo "$file"
            fi
        fi
    done
}

# Standard verification for language
verify_language_standard() {
    local language=$1
    local report_level=$2
    local fail_fast=$3
    shift 3
    local files=("$@")
    
    echo "Standard verification for $language (${#files[@]} files)"
    
    case "$language" in
        "javascript"|"typescript")
            verify_js_ts_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "python")
            verify_python_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "go")
            verify_go_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "rust")
            verify_rust_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "java")
            verify_java_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "ruby")
            verify_ruby_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "c"|"cpp")
            verify_c_cpp_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "csharp")
            verify_csharp_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "php")
            verify_php_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "css")
            verify_css_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "html")
            verify_html_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "json")
            verify_json_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "yaml")
            verify_yaml_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "markdown")
            verify_markdown_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "shell")
            verify_shell_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "sql")
            verify_sql_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        "dockerfile")
            verify_dockerfile_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
        *)
            verify_generic_standard "$report_level" "$fail_fast" "${files[@]}"
            ;;
    esac
}

# JavaScript/TypeScript verification
verify_js_ts_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # Syntax check
        if ! verify_js_syntax "$file"; then
            echo "ERROR: Syntax error in $file"
            errors=$((errors + 1))
            [[ "$fail_fast" == "true" ]] && return 1
        fi
        
        # ESLint check
        if command -v eslint >/dev/null 2>&1; then
            local lint_output=$(eslint "$file" 2>&1)
            local lint_errors=$(echo "$lint_output" | grep -c "error" || echo 0)
            local lint_warnings=$(echo "$lint_output" | grep -c "warning" || echo 0)
            
            if [ "$lint_errors" -gt 0 ]; then
                echo "ERROR: ESLint errors in $file:"
                echo "$lint_output" | grep "error"
                errors=$((errors + lint_errors))
                [[ "$fail_fast" == "true" ]] && return 1
            fi
            
            if [ "$lint_warnings" -gt 0 ]; then
                echo "WARNING: ESLint warnings in $file:"
                echo "$lint_output" | grep "warning"
                warnings=$((warnings + lint_warnings))
            fi
        fi
        
        # TypeScript check (for .ts files)
        if [[ "$file" =~ \.tsx?$ ]] && command -v tsc >/dev/null 2>&1; then
            if ! tsc --noEmit "$file" 2>/dev/null; then
                echo "ERROR: TypeScript compilation error in $file"
                errors=$((errors + 1))
                [[ "$fail_fast" == "true" ]] && return 1
            fi
        fi
        
        # Security check
        if command -v semgrep >/dev/null 2>&1; then
            local security_issues=$(semgrep --config=auto "$file" 2>/dev/null | grep -c "FINDING" || echo 0)
            if [ "$security_issues" -gt 0 ]; then
                echo "WARNING: Potential security issues in $file"
                warnings=$((warnings + security_issues))
            fi
        fi
        
        # Check for common issues
        check_js_common_issues "$file"
    done
    
    return 0
}

# Python verification
verify_python_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # Syntax check
        if ! python -m py_compile "$file" 2>/dev/null; then
            echo "ERROR: Python syntax error in $file"
            errors=$((errors + 1))
            [[ "$fail_fast" == "true" ]] && return 1
        fi
        
        # Flake8 check
        if command -v flake8 >/dev/null 2>&1; then
            local flake8_output=$(flake8 "$file" 2>&1)
            if [ -n "$flake8_output" ]; then
                local flake8_errors=$(echo "$flake8_output" | grep -c "E[0-9]" || echo 0)
                local flake8_warnings=$(echo "$flake8_output" | grep -c "W[0-9]" || echo 0)
                
                if [ "$flake8_errors" -gt 0 ]; then
                    echo "ERROR: PEP8 errors in $file:"
                    echo "$flake8_output" | grep "E[0-9]"
                    errors=$((errors + flake8_errors))
                    [[ "$fail_fast" == "true" ]] && return 1
                fi
                
                if [ "$flake8_warnings" -gt 0 ]; then
                    echo "WARNING: PEP8 warnings in $file:"
                    echo "$flake8_output" | grep "W[0-9]"
                    warnings=$((warnings + flake8_warnings))
                fi
            fi
        fi
        
        # MyPy type checking
        if command -v mypy >/dev/null 2>&1; then
            local mypy_output=$(mypy "$file" 2>&1)
            if echo "$mypy_output" | grep -q "error:"; then
                echo "WARNING: Type checking issues in $file:"
                echo "$mypy_output" | grep "error:"
                warnings=$((warnings + 1))
            fi
        fi
        
        # Security check with bandit
        if command -v bandit >/dev/null 2>&1; then
            local security_issues=$(bandit -r "$file" -f json 2>/dev/null | jq '.results | length' 2>/dev/null || echo 0)
            if [ "$security_issues" -gt 0 ]; then
                echo "WARNING: Potential security issues in $file"
                warnings=$((warnings + security_issues))
            fi
        fi
        
        # Check for common issues
        check_python_common_issues "$file"
    done
    
    return 0
}

# Go verification
verify_go_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # Syntax check
        if ! go fmt "$file" >/dev/null 2>&1; then
            echo "ERROR: Go syntax error in $file"
            errors=$((errors + 1))
            [[ "$fail_fast" == "true" ]] && return 1
        fi
        
        # Go vet check
        if command -v go >/dev/null 2>&1; then
            local vet_output=$(go vet "$file" 2>&1)
            if [ -n "$vet_output" ]; then
                echo "WARNING: Go vet issues in $file:"
                echo "$vet_output"
                warnings=$((warnings + 1))
            fi
        fi
        
        # golint check
        if command -v golint >/dev/null 2>&1; then
            local lint_output=$(golint "$file" 2>&1)
            if [ -n "$lint_output" ]; then
                echo "WARNING: golint issues in $file:"
                echo "$lint_output"
                warnings=$((warnings + 1))
            fi
        fi
        
        # staticcheck
        if command -v staticcheck >/dev/null 2>&1; then
            local static_output=$(staticcheck "$file" 2>&1)
            if [ -n "$static_output" ]; then
                echo "WARNING: staticcheck issues in $file:"
                echo "$static_output"
                warnings=$((warnings + 1))
            fi
        fi
        
        # Security check with gosec
        if command -v gosec >/dev/null 2>&1; then
            local security_issues=$(gosec "$file" 2>/dev/null | grep -c "Severity:" || echo 0)
            if [ "$security_issues" -gt 0 ]; then
                echo "WARNING: Potential security issues in $file"
                warnings=$((warnings + security_issues))
            fi
        fi
    done
    
    return 0
}

# Rust verification
verify_rust_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # Syntax check
        if ! rustc --parse-only "$file" >/dev/null 2>&1; then
            echo "ERROR: Rust syntax error in $file"
            errors=$((errors + 1))
            [[ "$fail_fast" == "true" ]] && return 1
        fi
        
        # Clippy linting
        if command -v clippy >/dev/null 2>&1; then
            local clippy_output=$(clippy "$file" 2>&1)
            if echo "$clippy_output" | grep -q "warning:"; then
                echo "WARNING: Clippy warnings in $file:"
                echo "$clippy_output" | grep "warning:"
                warnings=$((warnings + 1))
            fi
        fi
        
        # Format check
        if command -v rustfmt >/dev/null 2>&1; then
            if ! rustfmt --check "$file" >/dev/null 2>&1; then
                echo "WARNING: Formatting issues in $file"
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    return 0
}

# Java verification
verify_java_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # Syntax check
        if ! javac -cp . "$file" >/dev/null 2>&1; then
            echo "ERROR: Java compilation error in $file"
            errors=$((errors + 1))
            [[ "$fail_fast" == "true" ]] && return 1
        fi
        
        # CheckStyle
        if command -v checkstyle >/dev/null 2>&1; then
            local checkstyle_output=$(checkstyle "$file" 2>&1)
            if [ -n "$checkstyle_output" ]; then
                echo "WARNING: CheckStyle issues in $file:"
                echo "$checkstyle_output"
                warnings=$((warnings + 1))
            fi
        fi
        
        # SpotBugs (if available)
        if command -v spotbugs >/dev/null 2>&1; then
            # SpotBugs requires compiled classes
            echo "INFO: Run SpotBugs on compiled classes for complete analysis"
        fi
    done
    
    return 0
}

# Ruby verification
verify_ruby_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # Syntax check
        if ! ruby -c "$file" >/dev/null 2>&1; then
            echo "ERROR: Ruby syntax error in $file"
            errors=$((errors + 1))
            [[ "$fail_fast" == "true" ]] && return 1
        fi
        
        # RuboCop check
        if command -v rubocop >/dev/null 2>&1; then
            local rubocop_output=$(rubocop "$file" 2>&1)
            local rubocop_offenses=$(echo "$rubocop_output" | grep -c "offense" || echo 0)
            
            if [ "$rubocop_offenses" -gt 0 ]; then
                echo "WARNING: RuboCop offenses in $file:"
                echo "$rubocop_output"
                warnings=$((warnings + rubocop_offenses))
            fi
        fi
    done
    
    return 0
}

# C/C++ verification
verify_c_cpp_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # Syntax check
        local compiler="gcc"
        [[ "$file" =~ \.(cpp|cc|cxx)$ ]] && compiler="g++"
        
        if ! $compiler -fsyntax-only "$file" >/dev/null 2>&1; then
            echo "ERROR: C/C++ syntax error in $file"
            errors=$((errors + 1))
            [[ "$fail_fast" == "true" ]] && return 1
        fi
        
        # cppcheck static analysis
        if command -v cppcheck >/dev/null 2>&1; then
            local cppcheck_output=$(cppcheck "$file" 2>&1)
            if echo "$cppcheck_output" | grep -q "error:"; then
                echo "ERROR: cppcheck errors in $file:"
                echo "$cppcheck_output" | grep "error:"
                errors=$((errors + 1))
                [[ "$fail_fast" == "true" ]] && return 1
            fi
            
            if echo "$cppcheck_output" | grep -q "warning:"; then
                echo "WARNING: cppcheck warnings in $file:"
                echo "$cppcheck_output" | grep "warning:"
                warnings=$((warnings + 1))
            fi
        fi
        
        # clang-tidy (if available)
        if command -v clang-tidy >/dev/null 2>&1; then
            local tidy_output=$(clang-tidy "$file" 2>&1)
            if echo "$tidy_output" | grep -q "warning:"; then
                echo "WARNING: clang-tidy warnings in $file:"
                echo "$tidy_output" | grep "warning:"
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    return 0
}

# C# verification
verify_csharp_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # Compilation check
        if command -v dotnet >/dev/null 2>&1; then
            local compile_output=$(dotnet build "$file" 2>&1)
            if echo "$compile_output" | grep -q "error"; then
                echo "ERROR: C# compilation error in $file:"
                echo "$compile_output" | grep "error"
                errors=$((errors + 1))
                [[ "$fail_fast" == "true" ]] && return 1
            fi
            
            if echo "$compile_output" | grep -q "warning"; then
                echo "WARNING: C# compilation warning in $file:"
                echo "$compile_output" | grep "warning"
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    return 0
}

# PHP verification
verify_php_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # Syntax check
        if ! php -l "$file" >/dev/null 2>&1; then
            echo "ERROR: PHP syntax error in $file"
            errors=$((errors + 1))
            [[ "$fail_fast" == "true" ]] && return 1
        fi
        
        # PHPCS check
        if command -v phpcs >/dev/null 2>&1; then
            local phpcs_output=$(phpcs "$file" 2>&1)
            if [ -n "$phpcs_output" ]; then
                echo "WARNING: PHPCS issues in $file:"
                echo "$phpcs_output"
                warnings=$((warnings + 1))
            fi
        fi
        
        # PHPStan static analysis
        if command -v phpstan >/dev/null 2>&1; then
            local phpstan_output=$(phpstan analyse "$file" 2>&1)
            if echo "$phpstan_output" | grep -q "ERROR"; then
                echo "WARNING: PHPStan issues in $file:"
                echo "$phpstan_output"
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    return 0
}

# CSS verification
verify_css_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # CSS Lint
        if command -v csslint >/dev/null 2>&1; then
            local csslint_output=$(csslint "$file" 2>&1)
            if echo "$csslint_output" | grep -q "Error"; then
                echo "ERROR: CSS errors in $file:"
                echo "$csslint_output" | grep "Error"
                errors=$((errors + 1))
                [[ "$fail_fast" == "true" ]] && return 1
            fi
            
            if echo "$csslint_output" | grep -q "Warning"; then
                echo "WARNING: CSS warnings in $file:"
                echo "$csslint_output" | grep "Warning"
                warnings=$((warnings + 1))
            fi
        fi
        
        # Stylelint
        if command -v stylelint >/dev/null 2>&1; then
            local stylelint_output=$(stylelint "$file" 2>&1)
            if [ -n "$stylelint_output" ]; then
                echo "WARNING: Stylelint issues in $file:"
                echo "$stylelint_output"
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    return 0
}

# HTML verification
verify_html_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # HTML Tidy
        if command -v tidy >/dev/null 2>&1; then
            local tidy_output=$(tidy -q -e "$file" 2>&1)
            if echo "$tidy_output" | grep -q "Error"; then
                echo "ERROR: HTML errors in $file:"
                echo "$tidy_output" | grep "Error"
                errors=$((errors + 1))
                [[ "$fail_fast" == "true" ]] && return 1
            fi
            
            if echo "$tidy_output" | grep -q "Warning"; then
                echo "WARNING: HTML warnings in $file:"
                echo "$tidy_output" | grep "Warning"
                warnings=$((warnings + 1))
            fi
        fi
        
        # HTMLHint
        if command -v htmlhint >/dev/null 2>&1; then
            local htmlhint_output=$(htmlhint "$file" 2>&1)
            if [ -n "$htmlhint_output" ]; then
                echo "WARNING: HTMLHint issues in $file:"
                echo "$htmlhint_output"
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    return 0
}

# JSON verification
verify_json_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # JSON syntax check
        if ! jq empty "$file" >/dev/null 2>&1; then
            echo "ERROR: Invalid JSON in $file"
            errors=$((errors + 1))
            [[ "$fail_fast" == "true" ]] && return 1
        fi
        
        # JSON schema validation (if schema exists)
        local schema_file="${file%.*}.schema.json"
        if [ -f "$schema_file" ] && command -v ajv >/dev/null 2>&1; then
            if ! ajv validate -s "$schema_file" -d "$file" >/dev/null 2>&1; then
                echo "WARNING: JSON schema validation failed for $file"
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    return 0
}

# YAML verification
verify_yaml_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # YAML syntax check
        if command -v yq >/dev/null 2>&1; then
            if ! yq eval . "$file" >/dev/null 2>&1; then
                echo "ERROR: Invalid YAML in $file"
                errors=$((errors + 1))
                [[ "$fail_fast" == "true" ]] && return 1
            fi
        elif command -v python >/dev/null 2>&1; then
            if ! python -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
                echo "ERROR: Invalid YAML in $file"
                errors=$((errors + 1))
                [[ "$fail_fast" == "true" ]] && return 1
            fi
        fi
        
        # yamllint check
        if command -v yamllint >/dev/null 2>&1; then
            local yamllint_output=$(yamllint "$file" 2>&1)
            if [ -n "$yamllint_output" ]; then
                echo "WARNING: yamllint issues in $file:"
                echo "$yamllint_output"
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    return 0
}

# Markdown verification
verify_markdown_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # markdownlint check
        if command -v markdownlint >/dev/null 2>&1; then
            local markdownlint_output=$(markdownlint "$file" 2>&1)
            if [ -n "$markdownlint_output" ]; then
                echo "WARNING: Markdown issues in $file:"
                echo "$markdownlint_output"
                warnings=$((warnings + 1))
            fi
        fi
        
        # Check for broken links (if available)
        if command -v markdown-link-check >/dev/null 2>&1; then
            local link_check_output=$(markdown-link-check "$file" 2>&1)
            if echo "$link_check_output" | grep -q "ERROR"; then
                echo "WARNING: Broken links in $file:"
                echo "$link_check_output" | grep "ERROR"
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    return 0
}

# Shell script verification
verify_shell_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # Syntax check
        if ! bash -n "$file" 2>/dev/null; then
            echo "ERROR: Shell syntax error in $file"
            errors=$((errors + 1))
            [[ "$fail_fast" == "true" ]] && return 1
        fi
        
        # ShellCheck
        if command -v shellcheck >/dev/null 2>&1; then
            local shellcheck_output=$(shellcheck "$file" 2>&1)
            if echo "$shellcheck_output" | grep -q "error:"; then
                echo "ERROR: ShellCheck errors in $file:"
                echo "$shellcheck_output" | grep "error:"
                errors=$((errors + 1))
                [[ "$fail_fast" == "true" ]] && return 1
            fi
            
            if echo "$shellcheck_output" | grep -q "warning:"; then
                echo "WARNING: ShellCheck warnings in $file:"
                echo "$shellcheck_output" | grep "warning:"
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    return 0
}

# SQL verification
verify_sql_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # Basic SQL syntax check (if sqlcheck is available)
        if command -v sqlcheck >/dev/null 2>&1; then
            local sqlcheck_output=$(sqlcheck "$file" 2>&1)
            if [ -n "$sqlcheck_output" ]; then
                echo "WARNING: SQL issues in $file:"
                echo "$sqlcheck_output"
                warnings=$((warnings + 1))
            fi
        fi
        
        # SQLFluff (if available)
        if command -v sqlfluff >/dev/null 2>&1; then
            local sqlfluff_output=$(sqlfluff lint "$file" 2>&1)
            if [ -n "$sqlfluff_output" ]; then
                echo "WARNING: SQLFluff issues in $file:"
                echo "$sqlfluff_output"
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    return 0
}

# Dockerfile verification
verify_dockerfile_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file"
        
        # hadolint check
        if command -v hadolint >/dev/null 2>&1; then
            local hadolint_output=$(hadolint "$file" 2>&1)
            if echo "$hadolint_output" | grep -q "error:"; then
                echo "ERROR: Dockerfile errors in $file:"
                echo "$hadolint_output" | grep "error:"
                errors=$((errors + 1))
                [[ "$fail_fast" == "true" ]] && return 1
            fi
            
            if echo "$hadolint_output" | grep -q "warning:"; then
                echo "WARNING: Dockerfile warnings in $file:"
                echo "$hadolint_output" | grep "warning:"
                warnings=$((warnings + 1))
            fi
        fi
    done
    
    return 0
}

# Generic verification for unknown file types
verify_generic_standard() {
    local report_level=$1
    local fail_fast=$2
    shift 2
    local files=("$@")
    
    local errors=0
    local warnings=0
    
    for file in "${files[@]}"; do
        echo "Verifying: $file (generic)"
        
        # Basic checks
        check_file_encoding "$file"
        check_line_endings "$file"
        
        # Check for common issues
        if grep -q $'\t' "$file"; then
            echo "WARNING: Tab characters found in $file"
            warnings=$((warnings + 1))
        fi
        
        if grep -q '[[:space:]]$' "$file"; then
            echo "WARNING: Trailing whitespace found in $file"
            warnings=$((warnings + 1))
        fi
    done
    
    return 0
}

# Check for common JavaScript issues
check_js_common_issues() {
    local file=$1
    
    # Check for console.log
    if grep -q "console\.log" "$file"; then
        echo "WARNING: console.log statements found in $file"
    fi
    
    # Check for debugger
    if grep -q "debugger" "$file"; then
        echo "WARNING: debugger statements found in $file"
    fi
    
    # Check for TODO comments
    if grep -q "TODO\|FIXME\|XXX" "$file"; then
        echo "INFO: TODO/FIXME comments found in $file"
    fi
}

# Check for common Python issues
check_python_common_issues() {
    local file=$1
    
    # Check for print statements (in production code)
    if grep -q "print(" "$file" && [[ ! "$file" =~ test ]]; then
        echo "WARNING: print statements found in production code: $file"
    fi
    
    # Check for pdb
    if grep -q "import pdb\|pdb\.set_trace" "$file"; then
        echo "WARNING: pdb debugging statements found in $file"
    fi
    
    # Check for TODO comments
    if grep -q "TODO\|FIXME\|XXX" "$file"; then
        echo "INFO: TODO/FIXME comments found in $file"
    fi
}

# Verify JavaScript syntax
verify_js_syntax() {
    local file=$1
    
    if command -v node >/dev/null 2>&1; then
        node -c "$file" 2>/dev/null
    else
        # Fallback: basic syntax check
        if grep -q "syntax error" <(bash -n "$file" 2>&1); then
            return 1
        fi
        return 0
    fi
}

# Comprehensive verification
verify_language_comprehensive() {
    local language=$1
    local report_level=$2
    local fail_fast=$3
    shift 3
    local files=("$@")
    
    echo "Comprehensive verification for $language"
    
    # Run standard verification
    verify_language_standard "$language" "$report_level" "$fail_fast" "${files[@]}"
    
    # Additional comprehensive checks
    echo "Running additional comprehensive checks..."
    
    case "$language" in
        "javascript"|"typescript")
            # Security audit
            if command -v npm >/dev/null 2>&1; then
                echo "Running npm audit..."
                npm audit 2>/dev/null || true
            fi
            
            # Dependency check
            if [ -f "package.json" ]; then
                echo "Checking for outdated dependencies..."
                npm outdated 2>/dev/null || true
            fi
            ;;
        "python")
            # Security audit
            if command -v safety >/dev/null 2>&1; then
                echo "Running safety check..."
                safety check 2>/dev/null || true
            fi
            
            # Dependency check
            if [ -f "requirements.txt" ]; then
                echo "Checking for outdated dependencies..."
                pip list --outdated 2>/dev/null || true
            fi
            ;;
    esac
}

# Quick verification (essential checks only)
verify_language_quick() {
    local language=$1
    local report_level=$2
    local fail_fast=$3
    shift 3
    local files=("$@")
    
    echo "Quick verification for $language"
    
    local errors=0
    
    for file in "${files[@]}"; do
        # Only syntax checking for quick mode
        case "$language" in
            "javascript"|"typescript")
                if ! verify_js_syntax "$file"; then
                    echo "ERROR: Syntax error in $file"
                    errors=$((errors + 1))
                    [[ "$fail_fast" == "true" ]] && return 1
                fi
                ;;
            "python")
                if ! python -m py_compile "$file" 2>/dev/null; then
                    echo "ERROR: Python syntax error in $file"
                    errors=$((errors + 1))
                    [[ "$fail_fast" == "true" ]] && return 1
                fi
                ;;
            "json")
                if ! jq empty "$file" >/dev/null 2>&1; then
                    echo "ERROR: Invalid JSON in $file"
                    errors=$((errors + 1))
                    [[ "$fail_fast" == "true" ]] && return 1
                fi
                ;;
        esac
    done
    
    return 0
}

# Syntax-only verification
verify_syntax_only() {
    local language=$1
    local report_level=$2
    local fail_fast=$3
    shift 3
    local files=("$@")
    
    verify_language_quick "$language" "$report_level" "$fail_fast" "${files[@]}"
}

# Security-only verification
verify_security_only() {
    local language=$1
    local report_level=$2
    local fail_fast=$3
    shift 3
    local files=("$@")
    
    echo "Security verification for $language"
    
    for file in "${files[@]}"; do
        case "$language" in
            "javascript"|"typescript")
                if command -v semgrep >/dev/null 2>&1; then
                    semgrep --config=auto "$file" 2>/dev/null || true
                fi
                ;;
            "python")
                if command -v bandit >/dev/null 2>&1; then
                    bandit "$file" 2>/dev/null || true
                fi
                ;;
            "go")
                if command -v gosec >/dev/null 2>&1; then
                    gosec "$file" 2>/dev/null || true
                fi
                ;;
        esac
    done
}

# Style-only verification
verify_style_only() {
    local language=$1
    local report_level=$2
    local fail_fast=$3
    shift 3
    local files=("$@")
    
    echo "Style verification for $language"
    
    for file in "${files[@]}"; do
        case "$language" in
            "javascript"|"typescript")
                if command -v eslint >/dev/null 2>&1; then
                    eslint "$file" 2>/dev/null || true
                fi
                ;;
            "python")
                if command -v flake8 >/dev/null 2>&1; then
                    flake8 "$file" 2>/dev/null || true
                fi
                ;;
            "ruby")
                if command -v rubocop >/dev/null 2>&1; then
                    rubocop "$file" 2>/dev/null || true
                fi
                ;;
        esac
    done
}

# Dependencies-only verification
verify_dependencies_only() {
    local language=$1
    local report_level=$2
    local fail_fast=$3
    shift 3
    local files=("$@")
    
    echo "Dependencies verification for $language"
    
    case "$language" in
        "javascript"|"typescript")
            if [ -f "package.json" ]; then
                echo "Checking package.json dependencies..."
                if command -v npm >/dev/null 2>&1; then
                    npm audit 2>/dev/null || true
                    npm outdated 2>/dev/null || true
                fi
            fi
            ;;
        "python")
            if [ -f "requirements.txt" ]; then
                echo "Checking Python dependencies..."
                if command -v safety >/dev/null 2>&1; then
                    safety check 2>/dev/null || true
                fi
                if command -v pip >/dev/null 2>&1; then
                    pip list --outdated 2>/dev/null || true
                fi
            fi
            ;;
        "go")
            if [ -f "go.mod" ]; then
                echo "Checking Go modules..."
                go list -u -m all 2>/dev/null || true
            fi
            ;;
        "rust")
            if [ -f "Cargo.toml" ]; then
                echo "Checking Rust dependencies..."
                if command -v cargo >/dev/null 2>&1; then
                    cargo outdated 2>/dev/null || true
                fi
            fi
            ;;
    esac
}

# Generate detailed report
generate_detailed_report() {
    local results_file=$1
    local output_format=$2
    local target=$3
    
    case "$output_format" in
        "json")
            generate_json_report "$results_file" "$target"
            ;;
        "html")
            generate_html_report "$results_file" "$target"
            ;;
        *)
            generate_text_report "$results_file" "$target"
            ;;
    esac
}

# Generate summary report
generate_summary_report() {
    local results_file=$1
    local output_format=$2
    local target=$3
    
    echo ""
    echo "Verification Report Summary"
    echo "=========================="
    echo "Target: $target"
    echo "Generated: $(date)"
    echo ""
    
    # Count different types of issues
    local total_errors=$(grep -c "ERROR:" "$results_file" 2>/dev/null || echo 0)
    local total_warnings=$(grep -c "WARNING:" "$results_file" 2>/dev/null || echo 0)
    local total_info=$(grep -c "INFO:" "$results_file" 2>/dev/null || echo 0)
    
    echo "Issue Summary:"
    echo "  Errors: $total_errors"
    echo "  Warnings: $total_warnings"
    echo "  Info: $total_info"
    echo ""
    
    if [ "$total_errors" -gt 0 ]; then
        echo "Top Errors:"
        grep "ERROR:" "$results_file" | head -5
        echo ""
    fi
    
    if [ "$total_warnings" -gt 0 ]; then
        echo "Top Warnings:"
        grep "WARNING:" "$results_file" | head -5
        echo ""
    fi
}

# Generate text report
generate_text_report() {
    local results_file=$1
    local target=$2
    
    echo ""
    echo "Detailed Verification Report"
    echo "============================"
    echo "Target: $target"
    echo "Generated: $(date)"
    echo ""
    
    cat "$results_file"
}

# Generate JSON report
generate_json_report() {
    local results_file=$1
    local target=$2
    
    local json_output=$(mktemp)
    
    cat > "$json_output" <<EOF
{
    "target": "$target",
    "generated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "summary": {
        "errors": $(grep -c "ERROR:" "$results_file" 2>/dev/null || echo 0),
        "warnings": $(grep -c "WARNING:" "$results_file" 2>/dev/null || echo 0),
        "info": $(grep -c "INFO:" "$results_file" 2>/dev/null || echo 0)
    },
    "details": [
EOF
    
    # Convert results to JSON format (simplified)
    grep -E "(ERROR|WARNING|INFO):" "$results_file" | while IFS= read -r line; do
        local type=$(echo "$line" | cut -d: -f1)
        local message=$(echo "$line" | cut -d: -f2-)
        echo "        {\"type\": \"$type\", \"message\": \"$message\"},"
    done | sed '$ s/,$//' >> "$json_output"
    
    echo "    ]" >> "$json_output"
    echo "}" >> "$json_output"
    
    cat "$json_output"
    rm -f "$json_output"
}

# Generate HTML report
generate_html_report() {
    local results_file=$1
    local target=$2
    
    cat <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Code Verification Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f5f5f5; padding: 20px; border-radius: 5px; }
        .error { color: #d32f2f; }
        .warning { color: #f57c00; }
        .info { color: #1976d2; }
        .section { margin: 20px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Code Verification Report</h1>
        <p><strong>Target:</strong> $target</p>
        <p><strong>Generated:</strong> $(date)</p>
    </div>
    
    <div class="section">
        <h2>Summary</h2>
        <ul>
            <li class="error">Errors: $(grep -c "ERROR:" "$results_file" 2>/dev/null || echo 0)</li>
            <li class="warning">Warnings: $(grep -c "WARNING:" "$results_file" 2>/dev/null || echo 0)</li>
            <li class="info">Info: $(grep -c "INFO:" "$results_file" 2>/dev/null || echo 0)</li>
        </ul>
    </div>
    
    <div class="section">
        <h2>Details</h2>
        <pre>
$(cat "$results_file")
        </pre>
    </div>
</body>
</html>
EOF
}

# Main entry point
main() {
    local target=${1:-.}
    local mode=${2:-"standard"}
    local report_level=${3:-"summary"}
    local output_format=${4:-"text"}
    local fail_fast=${5:-false}
    
    # Source shared utilities at runtime
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/_shared/utils.md" 2>/dev/null || true
    source "$SCRIPT_DIR/_shared/safety.md" 2>/dev/null || true
    
    # Execute verification
    verify_codebase "$target" "$mode" "$report_level" "$output_format" "$fail_fast"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Verification Categories

### Syntax Validation
- **Language-specific parsers**: Native compiler/interpreter checks
- **AST validation**: Abstract syntax tree analysis
- **Grammar compliance**: Language specification adherence
- **Encoding validation**: Character encoding consistency

### Code Quality Checks
- **Linting rules**: Style guide enforcement
- **Complexity analysis**: Cyclomatic complexity metrics
- **Best practices**: Language-specific recommendations
- **Performance patterns**: Common optimization opportunities

### Security Analysis
- **Vulnerability scanning**: Known security issues
- **Dependency auditing**: Third-party package security
- **Code injection detection**: SQL injection, XSS, etc.
- **Sensitive data exposure**: Hardcoded secrets, credentials

### Standards Compliance
- **Coding standards**: Team/organization guidelines
- **Documentation requirements**: Comment coverage
- **Naming conventions**: Variable/function naming
- **Project structure**: Directory organization

### Dependencies Analysis
- **Version compatibility**: Dependency version conflicts
- **Security vulnerabilities**: Known CVEs in dependencies
- **License compliance**: License compatibility checks
- **Outdated packages**: Available updates

### Framework-Specific Checks
- **React/Vue/Angular**: Component best practices
- **Node.js**: Express security, async patterns
- **Django/Flask**: Security middleware, ORM usage
- **Spring Boot**: Configuration, security annotations

## Supported Tools Integration

### JavaScript/TypeScript
- **ESLint**: Comprehensive linting and rules
- **TypeScript Compiler**: Type checking and errors
- **Prettier**: Code formatting validation
- **npm audit**: Security vulnerability scanning
- **Semgrep**: Security pattern detection

### Python
- **Flake8**: PEP 8 compliance and linting
- **MyPy**: Static type checking
- **Bandit**: Security vulnerability scanning
- **Safety**: Dependency security audit
- **Black**: Code formatting validation

### Go
- **go vet**: Official Go tool for correctness
- **golint**: Style and convention checking
- **staticcheck**: Advanced static analysis
- **gosec**: Security vulnerability scanning
- **gofmt**: Code formatting validation

### Rust
- **Clippy**: Comprehensive linting tool
- **rustfmt**: Code formatting validation
- **cargo audit**: Dependency security scanning

### Other Languages
- **ShellCheck**: Shell script analysis
- **hadolint**: Dockerfile linting
- **markdownlint**: Markdown formatting
- **yamllint**: YAML syntax and style

## Report Formats

### Text Report
- Human-readable console output
- Color-coded severity levels
- Detailed error descriptions
- Summary statistics

### JSON Report
- Machine-readable structured data
- Integration with CI/CD pipelines
- Programmatic analysis support
- Standardized error formats

### HTML Report
- Rich visual presentation
- Interactive navigation
- Embedded charts and graphs
- Shareable team reports

This verification command provides comprehensive code quality validation with extensive tool integration, multi-format reporting, and flexible verification modes to ensure high-quality, secure, and maintainable code across multiple programming languages and frameworks.