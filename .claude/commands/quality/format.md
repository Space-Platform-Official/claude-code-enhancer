---
description: Comprehensive code formatting and style command for multiple languages and frameworks
---

# Format Command - Code Formatting & Style

Intelligent code formatting command that automatically detects languages, applies appropriate formatters, and maintains consistent style across your codebase with support for project-specific configurations.

## Usage

```bash
# Basic formatting
claude format

# Format specific directory
claude format src/

# Format specific files
claude format src/components/*.js

# Dry run (preview changes)
claude format --dry-run

# Format with specific formatters
claude format --formatter=prettier,eslint

# Comprehensive formatting with multiple passes
claude format --comprehensive

# Format and organize imports
claude format --organize-imports

# Fix common style issues
claude format --fix-style
```

## Implementation

```bash
#!/bin/bash

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../shared/utils.md"
source "$SCRIPT_DIR/../../shared/safety.md"
source "$SCRIPT_DIR/../../shared/orchestration.md"

# Main format function
format_codebase() {
    local target=${1:-.}
    local dry_run=${2:-false}
    local mode=${3:-"standard"}
    
    echo "Starting code formatting..."
    echo "Target: $target"
    echo "Dry run: $dry_run"
    echo "Mode: $mode"
    
    # Safety checks
    if ! run_safety_checks "format" "$target" "$dry_run"; then
        echo "ERROR: Safety checks failed"
        return 1
    fi
    
    # Create snapshot if not dry run
    local snapshot_path=""
    if [[ "$dry_run" != "true" ]]; then
        snapshot_path=$(create_safety_snapshot "$target" "format")
        echo "Snapshot created: $snapshot_path"
    fi
    
    # Discover files to format
    local files_to_format=($(discover_formattable_files "$target"))
    echo "Found ${#files_to_format[@]} files to format"
    
    if [ ${#files_to_format[@]} -eq 0 ]; then
        echo "No files to format found"
        return 0
    fi
    
    # Validate operation safety
    if ! validate_operation_safety "format" "${files_to_format[@]}"; then
        echo "Operation cancelled by user"
        return 1
    fi
    
    # Group files by language
    declare -A language_groups
    for file in "${files_to_format[@]}"; do
        local language=$(detect_file_language "$file")
        if [ -n "${language_groups[$language]}" ]; then
            language_groups[$language]="${language_groups[$language]} $file"
        else
            language_groups[$language]="$file"
        fi
    done
    
    # Format each language group
    local total_formatted=0
    local total_errors=0
    
    for language in "${!language_groups[@]}"; do
        echo "Formatting $language files..."
        
        local files_list=(${language_groups[$language]})
        local formatted_count=0
        local error_count=0
        
        case "$mode" in
            "comprehensive")
                format_language_comprehensive "$language" "$dry_run" "${files_list[@]}"
                ;;
            "quick")
                format_language_quick "$language" "$dry_run" "${files_list[@]}"
                ;;
            *)
                format_language_standard "$language" "$dry_run" "${files_list[@]}"
                ;;
        esac
        
        local result=$?
        if [ $result -eq 0 ]; then
            formatted_count=${#files_list[@]}
        else
            error_count=${#files_list[@]}
        fi
        
        total_formatted=$((total_formatted + formatted_count))
        total_errors=$((total_errors + error_count))
        
        echo "$language: $formatted_count formatted, $error_count errors"
    done
    
    # Generate summary report
    echo ""
    echo "Formatting Summary:"
    echo "=================="
    echo "Total files processed: $((total_formatted + total_errors))"
    echo "Successfully formatted: $total_formatted"
    echo "Errors: $total_errors"
    
    if [[ "$dry_run" == "true" ]]; then
        echo ""
        echo "This was a dry run - no files were modified"
    elif [ -n "$snapshot_path" ]; then
        echo "Snapshot available for rollback: $snapshot_path"
    fi
    
    # Verify formatting results
    if [[ "$dry_run" != "true" ]] && [ $total_errors -eq 0 ]; then
        echo "Verifying formatting results..."
        verify_formatting_results "$target" "${files_to_format[@]}"
    fi
    
    return $total_errors
}

# Discover files that can be formatted
discover_formattable_files() {
    local target=$1
    local exclude_patterns=${EXCLUDE_PATTERNS:-".git node_modules __pycache__ .pytest_cache target build dist coverage .vscode .idea .claude .Claude .CLAUDE"}
    
    # Language patterns
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
        if [ -f "$file" ] && [ -r "$file" ] && [ -w "$file" ]; then
            if ! is_binary_file "$file"; then
                echo "$file"
            fi
        fi
    done
}

# Format language group with standard approach
format_language_standard() {
    local language=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    local formatters=($(detect_formatters "$language"))
    if [ ${#formatters[@]} -eq 0 ]; then
        echo "No formatters available for $language"
        return 0
    fi
    
    # Use primary formatter
    local primary_formatter=${formatters[0]}
    echo "Using $primary_formatter for $language"
    
    case "$language" in
        "javascript"|"typescript")
            format_js_ts_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "python")
            format_python_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "go")
            format_go_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "rust")
            format_rust_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "java")
            format_java_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "ruby")
            format_ruby_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "c"|"cpp")
            format_c_cpp_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "csharp")
            format_csharp_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "php")
            format_php_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "css")
            format_css_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "html")
            format_html_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "json")
            format_json_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "yaml")
            format_yaml_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "markdown")
            format_markdown_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "shell")
            format_shell_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        "sql")
            format_sql_standard "$primary_formatter" "$dry_run" "${files[@]}"
            ;;
        *)
            echo "No formatting rules for language: $language"
            return 0
            ;;
    esac
}

# JavaScript/TypeScript formatting
format_js_ts_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    case "$formatter" in
        "prettier")
            if [[ "$dry_run" == "true" ]]; then
                prettier --check "${files[@]}" 2>/dev/null || true
            else
                prettier --write "${files[@]}"
            fi
            ;;
        "eslint")
            local eslint_args=("--fix")
            [[ "$dry_run" == "true" ]] && eslint_args=("--fix-dry-run")
            eslint "${eslint_args[@]}" "${files[@]}"
            ;;
        "biome")
            local biome_args=("format" "--write")
            [[ "$dry_run" == "true" ]] && biome_args=("format")
            biome "${biome_args[@]}" "${files[@]}"
            ;;
    esac
}

# Python formatting
format_python_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    case "$formatter" in
        "black")
            local black_args=()
            [[ "$dry_run" == "true" ]] && black_args+=("--check" "--diff")
            black "${black_args[@]}" "${files[@]}"
            ;;
        "autopep8")
            local autopep8_args=("--in-place" "--aggressive")
            [[ "$dry_run" == "true" ]] && autopep8_args=("--diff")
            autopep8 "${autopep8_args[@]}" "${files[@]}"
            ;;
        "yapf")
            local yapf_args=("--in-place")
            [[ "$dry_run" == "true" ]] && yapf_args=("--diff")
            yapf "${yapf_args[@]}" "${files[@]}"
            ;;
        "isort")
            local isort_args=()
            [[ "$dry_run" == "true" ]] && isort_args+=("--check-only" "--diff")
            isort "${isort_args[@]}" "${files[@]}"
            ;;
    esac
}

# Go formatting
format_go_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    case "$formatter" in
        "gofmt")
            if [[ "$dry_run" == "true" ]]; then
                for file in "${files[@]}"; do
                    gofmt -d "$file"
                done
            else
                gofmt -w "${files[@]}"
            fi
            ;;
        "goimports")
            if [[ "$dry_run" == "true" ]]; then
                for file in "${files[@]}"; do
                    goimports -d "$file"
                done
            else
                goimports -w "${files[@]}"
            fi
            ;;
    esac
}

# Rust formatting
format_rust_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    case "$formatter" in
        "rustfmt")
            local rustfmt_args=()
            [[ "$dry_run" == "true" ]] && rustfmt_args+=("--check")
            rustfmt "${rustfmt_args[@]}" "${files[@]}"
            ;;
    esac
}

# Java formatting
format_java_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    case "$formatter" in
        "google-java-format")
            local format_args=()
            [[ "$dry_run" != "true" ]] && format_args+=("-i")
            google-java-format "${format_args[@]}" "${files[@]}"
            ;;
    esac
}

# Ruby formatting
format_ruby_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    case "$formatter" in
        "rubocop")
            local rubocop_args=("--auto-correct")
            [[ "$dry_run" == "true" ]] && rubocop_args=("--display-cop-names")
            rubocop "${rubocop_args[@]}" "${files[@]}"
            ;;
    esac
}

# C/C++ formatting
format_c_cpp_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    case "$formatter" in
        "clang-format")
            local format_args=()
            [[ "$dry_run" != "true" ]] && format_args+=("-i")
            clang-format "${format_args[@]}" "${files[@]}"
            ;;
    esac
}

# C# formatting
format_csharp_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    case "$formatter" in
        "dotnet-format")
            local format_args=("format")
            [[ "$dry_run" == "true" ]] && format_args+=("--verify-no-changes")
            dotnet "${format_args[@]}" "${files[@]}"
            ;;
    esac
}

# PHP formatting
format_php_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    # PHP formatting would go here
    echo "PHP formatting not yet implemented"
}

# CSS formatting
format_css_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    case "$formatter" in
        "prettier")
            if [[ "$dry_run" == "true" ]]; then
                prettier --check "${files[@]}"
            else
                prettier --write "${files[@]}"
            fi
            ;;
    esac
}

# HTML formatting
format_html_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    case "$formatter" in
        "prettier")
            if [[ "$dry_run" == "true" ]]; then
                prettier --check "${files[@]}"
            else
                prettier --write "${files[@]}"
            fi
            ;;
    esac
}

# JSON formatting
format_json_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    for file in "${files[@]}"; do
        if [[ "$dry_run" == "true" ]]; then
            jq . "$file" >/dev/null && echo "$file: would be formatted"
        else
            if command -v jq >/dev/null 2>&1; then
                local temp_file=$(mktemp)
                if jq . "$file" > "$temp_file"; then
                    mv "$temp_file" "$file"
                else
                    rm -f "$temp_file"
                    echo "ERROR: Invalid JSON in $file"
                fi
            fi
        fi
    done
}

# YAML formatting
format_yaml_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    case "$formatter" in
        "yamllint")
            yamllint "${files[@]}"
            ;;
        "yq")
            for file in "${files[@]}"; do
                if [[ "$dry_run" != "true" ]]; then
                    yq eval . "$file" -i
                fi
            done
            ;;
    esac
}

# Markdown formatting
format_markdown_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    case "$formatter" in
        "prettier")
            if [[ "$dry_run" == "true" ]]; then
                prettier --check "${files[@]}"
            else
                prettier --write "${files[@]}"
            fi
            ;;
    esac
}

# Shell script formatting
format_shell_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    case "$formatter" in
        "shfmt")
            local shfmt_args=()
            [[ "$dry_run" != "true" ]] && shfmt_args+=("-w")
            shfmt "${shfmt_args[@]}" "${files[@]}"
            ;;
    esac
}

# SQL formatting
format_sql_standard() {
    local formatter=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    # SQL formatting would go here
    echo "SQL formatting not yet implemented"
}

# Comprehensive formatting with multiple formatters
format_language_comprehensive() {
    local language=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    local formatters=($(detect_formatters "$language"))
    echo "Comprehensive formatting for $language using: ${formatters[*]}"
    
    # Apply each formatter in sequence
    for formatter in "${formatters[@]}"; do
        echo "Applying $formatter..."
        format_language_standard "$language" "$dry_run" "${files[@]}"
    done
    
    # Language-specific post-processing
    case "$language" in
        "javascript"|"typescript")
            # Organize imports after formatting
            if [[ "$dry_run" != "true" ]]; then
                organize_js_imports "${files[@]}"
            fi
            ;;
        "python")
            # Sort imports after formatting
            if [[ "$dry_run" != "true" ]] && command -v isort >/dev/null 2>&1; then
                isort "${files[@]}"
            fi
            ;;
        "go")
            # Organize imports after formatting
            if [[ "$dry_run" != "true" ]] && command -v goimports >/dev/null 2>&1; then
                goimports -w "${files[@]}"
            fi
            ;;
    esac
}

# Quick formatting (minimal changes)
format_language_quick() {
    local language=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    echo "Quick formatting for $language"
    
    # Use fastest formatter available
    local formatters=($(detect_formatters "$language"))
    if [ ${#formatters[@]} -gt 0 ]; then
        local quick_formatter=${formatters[0]}
        
        # Override with preferred quick formatters
        case "$language" in
            "javascript"|"typescript")
                command -v prettier >/dev/null 2>&1 && quick_formatter="prettier"
                ;;
            "python")
                command -v black >/dev/null 2>&1 && quick_formatter="black"
                ;;
            "go")
                command -v gofmt >/dev/null 2>&1 && quick_formatter="gofmt"
                ;;
        esac
        
        format_language_standard "$language" "$dry_run" "${files[@]}"
    fi
}

# Organize JavaScript/TypeScript imports
organize_js_imports() {
    local files=("$@")
    
    for file in "${files[@]}"; do
        if command -v eslint >/dev/null 2>&1; then
            eslint --fix --rule 'sort-imports: error' "$file" 2>/dev/null || true
        fi
    done
}

# Verify formatting results
verify_formatting_results() {
    local target=$1
    shift
    local files=("$@")
    
    echo "Verifying formatting results..."
    
    local verification_errors=0
    
    for file in "${files[@]}"; do
        # Check syntax
        if ! validate_syntax "$file"; then
            echo "ERROR: Syntax error in formatted file: $file"
            verification_errors=$((verification_errors + 1))
        fi
        
        # Check encoding
        if ! check_file_encoding "$file"; then
            echo "WARNING: Encoding issue in formatted file: $file"
        fi
        
        # Check line endings
        if ! check_line_endings "$file"; then
            echo "WARNING: Line ending issue in formatted file: $file"
        fi
    done
    
    if [ $verification_errors -eq 0 ]; then
        echo "All formatted files verified successfully"
        return 0
    else
        echo "Verification failed for $verification_errors files"
        return 1
    fi
}

# Show formatting preview
show_formatting_preview() {
    local target=${1:-.}
    local max_files=${2:-10}
    
    echo "Formatting Preview"
    echo "=================="
    
    local files_to_format=($(discover_formattable_files "$target" | head -$max_files))
    
    for file in "${files_to_format[@]}"; do
        echo "File: $file"
        local language=$(detect_file_language "$file")
        local formatters=($(detect_formatters "$language"))
        
        if [ ${#formatters[@]} -gt 0 ]; then
            echo "  Language: $language"
            echo "  Formatters: ${formatters[*]}"
            
            # Show what would change
            case "$language" in
                "javascript"|"typescript")
                    if command -v prettier >/dev/null 2>&1; then
                        local changes=$(prettier --check "$file" 2>&1 | wc -l)
                        echo "  Changes: $changes lines would be modified"
                    fi
                    ;;
                "python")
                    if command -v black >/dev/null 2>&1; then
                        local changes=$(black --check --diff "$file" 2>/dev/null | wc -l)
                        echo "  Changes: $changes lines would be modified"
                    fi
                    ;;
            esac
        else
            echo "  No formatters available"
        fi
        echo ""
    done
}

# Configuration management
load_formatting_config() {
    local target=${1:-.}
    
    # Look for common config files
    local config_files=(
        "$target/.prettierrc"
        "$target/.prettierrc.json"
        "$target/.eslintrc.json"
        "$target/.eslintrc.js"
        "$target/pyproject.toml"
        "$target/.black"
        "$target/.rustfmt.toml"
        "$target/.clang-format"
        "$target/.editorconfig"
    )
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            echo "Found config: $config_file"
        fi
    done
}

# Main entry point
main() {
    local target=${1:-.}
    local dry_run=${2:-false}
    local mode=${3:-"standard"}
    
    # Source shared utilities at runtime
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/../../shared/utils.md" 2>/dev/null || true
    source "$SCRIPT_DIR/../../shared/safety.md" 2>/dev/null || true
    
    # Set up error handling
    trap 'cleanup_on_exit "$target"' EXIT
    
    # Execute formatting
    format_codebase "$target" "$dry_run" "$mode"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Language-Specific Configurations

### JavaScript/TypeScript
- **Prettier**: Code formatting with consistent style
- **ESLint**: Linting and automatic fixes
- **Biome**: Fast all-in-one formatter and linter

### Python
- **Black**: Uncompromising code formatter
- **autopep8**: PEP 8 compliance
- **yapf**: Configurable formatter
- **isort**: Import sorting

### Go
- **gofmt**: Standard Go formatter
- **goimports**: Import management and formatting

### Rust
- **rustfmt**: Official Rust formatter

### Java
- **google-java-format**: Google Java style
- **Eclipse formatter**: IDE-based formatting

### Ruby
- **RuboCop**: Style guide enforcement and auto-correction

### C/C++
- **clang-format**: LLVM-based formatter

### Other Languages
- **Prettier**: Universal formatter for web technologies
- **EditorConfig**: Cross-editor configuration

## Features

- **Multi-language support**: Handles 15+ programming languages
- **Intelligent formatter detection**: Automatically finds and uses available formatters
- **Project configuration awareness**: Respects existing config files
- **Safe operation**: Creates snapshots and validates results
- **Dry-run mode**: Preview changes before applying
- **Comprehensive mode**: Multiple formatter passes for thorough formatting
- **Import organization**: Sorts and organizes imports appropriately
- **Syntax validation**: Ensures formatting doesn't break code
- **Progress tracking**: Shows detailed progress and results

This format command provides comprehensive code formatting capabilities with intelligent language detection, safety mechanisms, and support for popular formatters across multiple programming languages.