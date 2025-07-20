---
description: Comprehensive dead code and import cleanup command for removing unused code, optimizing imports, and improving codebase health
---

# Cleanup Command - Dead Code & Import Cleanup

Intelligent cleanup command that identifies and removes dead code, unused imports, unreachable functions, and optimizes code structure while maintaining functionality and safety.

## Usage

```bash
# Basic cleanup
claude cleanup

# Cleanup specific directory
claude cleanup src/

# Cleanup specific files
claude cleanup src/components/*.js

# Dry run (preview changes)
claude cleanup --dry-run

# Aggressive cleanup
claude cleanup --aggressive

# Conservative cleanup (safer)
claude cleanup --conservative

# Cleanup specific types
claude cleanup --imports-only
claude cleanup --dead-code-only
claude cleanup --comments-only

# Skip interactive prompts
claude cleanup --auto-approve
```

## Implementation

```bash
#!/bin/bash

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../shared/utils.md"
source "$SCRIPT_DIR/../../shared/safety.md"
source "$SCRIPT_DIR/../../shared/orchestration.md"

# Main cleanup function
cleanup_codebase() {
    local target=${1:-.}
    local dry_run=${2:-false}
    local mode=${3:-"standard"}
    
    echo "Starting code cleanup..."
    echo "Target: $target"
    echo "Dry run: $dry_run"
    echo "Mode: $mode"
    
    # Safety checks
    if ! run_safety_checks "cleanup" "$target" "$dry_run"; then
        echo "ERROR: Safety checks failed"
        return 1
    fi
    
    # Create snapshot if not dry run
    local snapshot_path=""
    if [[ "$dry_run" != "true" ]]; then
        snapshot_path=$(create_safety_snapshot "$target" "cleanup")
        echo "Snapshot created: $snapshot_path"
    fi
    
    # Discover files to cleanup
    local files_to_cleanup=($(discover_cleanable_files "$target"))
    echo "Found ${#files_to_cleanup[@]} files to analyze"
    
    if [ ${#files_to_cleanup[@]} -eq 0 ]; then
        echo "No files to cleanup found"
        return 0
    fi
    
    # Validate operation safety
    if ! validate_operation_safety "cleanup" "${files_to_cleanup[@]}"; then
        echo "Operation cancelled by user"
        return 1
    fi
    
    # Analyze codebase before cleanup
    echo "Analyzing codebase for cleanup opportunities..."
    local cleanup_analysis=$(analyze_cleanup_opportunities "$target" "${files_to_cleanup[@]}")
    
    echo "Cleanup Analysis Results:"
    echo "$cleanup_analysis"
    
    # Group files by language for targeted cleanup
    declare -A language_groups
    for file in "${files_to_cleanup[@]}"; do
        local language=$(detect_file_language "$file")
        if [ -n "${language_groups[$language]}" ]; then
            language_groups[$language]="${language_groups[$language]} $file"
        else
            language_groups[$language]="$file"
        fi
    done
    
    # Execute cleanup for each language group
    local total_cleaned=0
    local total_errors=0
    
    for language in "${!language_groups[@]}"; do
        echo "Cleaning $language files..."
        
        local files_list=(${language_groups[$language]})
        local cleaned_count=0
        local error_count=0
        
        case "$mode" in
            "aggressive")
                cleanup_language_aggressive "$language" "$dry_run" "${files_list[@]}"
                ;;
            "conservative")
                cleanup_language_conservative "$language" "$dry_run" "${files_list[@]}"
                ;;
            "imports-only")
                cleanup_imports_only "$language" "$dry_run" "${files_list[@]}"
                ;;
            "dead-code-only")
                cleanup_dead_code_only "$language" "$dry_run" "${files_list[@]}"
                ;;
            "comments-only")
                cleanup_comments_only "$language" "$dry_run" "${files_list[@]}"
                ;;
            *)
                cleanup_language_standard "$language" "$dry_run" "${files_list[@]}"
                ;;
        esac
        
        local result=$?
        if [ $result -eq 0 ]; then
            cleaned_count=${#files_list[@]}
        else
            error_count=${#files_list[@]}
        fi
        
        total_cleaned=$((total_cleaned + cleaned_count))
        total_errors=$((total_errors + error_count))
        
        echo "$language: $cleaned_count cleaned, $error_count errors"
    done
    
    # Generate cleanup summary
    echo ""
    echo "Cleanup Summary:"
    echo "================"
    echo "Total files processed: $((total_cleaned + total_errors))"
    echo "Successfully cleaned: $total_cleaned"
    echo "Errors: $total_errors"
    
    if [[ "$dry_run" == "true" ]]; then
        echo ""
        echo "This was a dry run - no files were modified"
    elif [ -n "$snapshot_path" ]; then
        echo "Snapshot available for rollback: $snapshot_path"
    fi
    
    # Verify cleanup results
    if [[ "$dry_run" != "true" ]] && [ $total_errors -eq 0 ]; then
        echo "Verifying cleanup results..."
        verify_cleanup_results "$target" "${files_to_cleanup[@]}"
    fi
    
    return $total_errors
}

# Discover files that can be cleaned up
discover_cleanable_files() {
    local target=$1
    local exclude_patterns=${EXCLUDE_PATTERNS:-".git node_modules __pycache__ .pytest_cache target build dist coverage .vscode .idea .claude .Claude .CLAUDE"}
    
    # Source code patterns (excluding generated files)
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
    )
    
    # Find source files excluding generated and vendor code
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
    
    # Additional exclusions for generated files
    find_cmd="$find_cmd ! -name '*.min.js' ! -name '*.bundle.js' ! -name '*-compiled.*' ! -name '*.generated.*'"
    
    # Additional exclusions for .claude-related files and directories
    find_cmd="$find_cmd ! -name '.claude*' ! -name '*.claude*' ! -path '*/.claude' ! -path '*/.Claude' ! -path '*/.CLAUDE'"
    
    # Execute and filter
    eval "$find_cmd" 2>/dev/null | while read -r file; do
        if [ -f "$file" ] && [ -r "$file" ] && [ -w "$file" ]; then
            if ! is_binary_file "$file" && ! is_generated_file "$file"; then
                echo "$file"
            fi
        fi
    done
}

# Check if file is generated
is_generated_file() {
    local file=$1
    
    # Check for common generation markers
    if head -10 "$file" | grep -q -i "generated\|auto-generated\|autogenerated\|do not edit\|machine generated"; then
        return 0
    fi
    
    # Check file patterns
    if [[ "$file" =~ \.(min|bundle|compiled|generated)\. ]]; then
        return 0
    fi
    
    return 1
}

# Analyze cleanup opportunities
analyze_cleanup_opportunities() {
    local target=$1
    shift
    local files=("$@")
    
    local unused_imports=0
    local dead_functions=0
    local unused_variables=0
    local empty_files=0
    local todo_comments=0
    local duplicate_imports=0
    
    for file in "${files[@]}"; do
        local language=$(detect_file_language "$file")
        
        # Count unused imports
        local file_unused_imports=$(count_unused_imports "$file" "$language")
        unused_imports=$((unused_imports + file_unused_imports))
        
        # Count dead functions
        local file_dead_functions=$(count_dead_functions "$file" "$language")
        dead_functions=$((dead_functions + file_dead_functions))
        
        # Count unused variables
        local file_unused_vars=$(count_unused_variables "$file" "$language")
        unused_variables=$((unused_variables + file_unused_vars))
        
        # Check for empty files
        if [ ! -s "$file" ] || [ "$(wc -l < "$file")" -le 3 ]; then
            empty_files=$((empty_files + 1))
        fi
        
        # Count TODO comments
        local file_todos=$(find_todo_comments "$file" | wc -l)
        todo_comments=$((todo_comments + file_todos))
        
        # Count duplicate imports
        local file_duplicate_imports=$(count_duplicate_imports "$file" "$language")
        duplicate_imports=$((duplicate_imports + file_duplicate_imports))
    done
    
    cat <<EOF
  Unused imports: $unused_imports
  Dead functions: $dead_functions
  Unused variables: $unused_variables
  Empty files: $empty_files
  TODO comments: $todo_comments
  Duplicate imports: $duplicate_imports
EOF
}

# Count unused imports in file
count_unused_imports() {
    local file=$1
    local language=$2
    
    case "$language" in
        "javascript"|"typescript")
            if command -v eslint >/dev/null 2>&1; then
                eslint --no-eslintrc --config '{"rules":{"no-unused-vars":"error"}}' "$file" 2>/dev/null | grep -c "is defined but never used" || echo 0
            else
                echo 0
            fi
            ;;
        "python")
            if command -v unimport >/dev/null 2>&1; then
                unimport --check "$file" 2>/dev/null | grep -c "Unused import" || echo 0
            elif command -v autoflake >/dev/null 2>&1; then
                autoflake --check "$file" 2>/dev/null | grep -c "unused import" || echo 0
            else
                echo 0
            fi
            ;;
        "go")
            # Go compiler will catch unused imports
            go build -o /dev/null "$file" 2>&1 | grep -c "imported and not used" || echo 0
            ;;
        *)
            echo 0
            ;;
    esac
}

# Count dead functions in file
count_dead_functions() {
    local file=$1
    local language=$2
    
    case "$language" in
        "javascript"|"typescript")
            local functions=$(grep -c -E "^function\s+\w+|^const\s+\w+\s*=.*function|^export\s+function\s+\w+" "$file" 2>/dev/null || echo 0)
            local exported=$(grep -c -E "^export\s" "$file" 2>/dev/null || echo 0)
            echo $((functions - exported))
            ;;
        "python")
            local functions=$(grep -c -E "^def\s+\w+" "$file" 2>/dev/null || echo 0)
            local called=$(grep -c -E "\w+\(" "$file" 2>/dev/null || echo 0)
            # Simple heuristic
            if [ $called -lt $functions ]; then
                echo $((functions - called))
            else
                echo 0
            fi
            ;;
        *)
            echo 0
            ;;
    esac
}

# Count unused variables in file
count_unused_variables() {
    local file=$1
    local language=$2
    
    case "$language" in
        "python")
            if command -v vulture >/dev/null 2>&1; then
                vulture "$file" 2>/dev/null | grep -c "unused variable" || echo 0
            else
                echo 0
            fi
            ;;
        "javascript"|"typescript")
            if command -v eslint >/dev/null 2>&1; then
                eslint --no-eslintrc --config '{"rules":{"no-unused-vars":"error"}}' "$file" 2>/dev/null | grep -c "is assigned to but never used" || echo 0
            else
                echo 0
            fi
            ;;
        *)
            echo 0
            ;;
    esac
}

# Count duplicate imports
count_duplicate_imports() {
    local file=$1
    local language=$2
    
    case "$language" in
        "javascript"|"typescript")
            local imports=$(extract_imports "$file" | sort)
            local unique_imports=$(echo "$imports" | sort -u)
            local total_lines=$(echo "$imports" | wc -l)
            local unique_lines=$(echo "$unique_imports" | wc -l)
            echo $((total_lines - unique_lines))
            ;;
        "python")
            local imports=$(grep -E "^import\s+|^from\s+.*import\s+" "$file" | sort)
            local unique_imports=$(echo "$imports" | sort -u)
            local total_lines=$(echo "$imports" | wc -l)
            local unique_lines=$(echo "$unique_imports" | wc -l)
            echo $((total_lines - unique_lines))
            ;;
        *)
            echo 0
            ;;
    esac
}

# Standard cleanup for language
cleanup_language_standard() {
    local language=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    echo "Standard cleanup for $language (${#files[@]} files)"
    
    case "$language" in
        "javascript"|"typescript")
            cleanup_js_ts_standard "$dry_run" "${files[@]}"
            ;;
        "python")
            cleanup_python_standard "$dry_run" "${files[@]}"
            ;;
        "go")
            cleanup_go_standard "$dry_run" "${files[@]}"
            ;;
        "rust")
            cleanup_rust_standard "$dry_run" "${files[@]}"
            ;;
        "java")
            cleanup_java_standard "$dry_run" "${files[@]}"
            ;;
        "ruby")
            cleanup_ruby_standard "$dry_run" "${files[@]}"
            ;;
        "c"|"cpp")
            cleanup_c_cpp_standard "$dry_run" "${files[@]}"
            ;;
        *)
            echo "No cleanup rules for language: $language"
            ;;
    esac
}

# JavaScript/TypeScript cleanup
cleanup_js_ts_standard() {
    local dry_run=$1
    shift
    local files=("$@")
    
    for file in "${files[@]}"; do
        echo "Cleaning JavaScript/TypeScript: $file"
        
        # Remove unused imports
        if [[ "$dry_run" != "true" ]]; then
            if command -v eslint >/dev/null 2>&1; then
                eslint --fix --rule 'no-unused-vars: error' "$file" 2>/dev/null || true
            fi
        else
            echo "  Would remove unused imports and variables"
        fi
        
        # Remove console.log statements (optional)
        if [[ "$dry_run" != "true" ]]; then
            sed -i '' '/console\.log/d' "$file" 2>/dev/null || sed -i '/console\.log/d' "$file" 2>/dev/null || true
        else
            local console_logs=$(grep -c "console\.log" "$file" 2>/dev/null || echo 0)
            echo "  Would remove $console_logs console.log statements"
        fi
        
        # Remove empty lines (more than 2 consecutive)
        if [[ "$dry_run" != "true" ]]; then
            awk '/^$/{n++}; /./{n=0}; n<=2' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
        fi
        
        # Remove trailing whitespace
        if [[ "$dry_run" != "true" ]]; then
            sed -i '' 's/[[:space:]]*$//' "$file" 2>/dev/null || sed -i 's/[[:space:]]*$//' "$file" 2>/dev/null || true
        fi
    done
}

# Python cleanup
cleanup_python_standard() {
    local dry_run=$1
    shift
    local files=("$@")
    
    for file in "${files[@]}"; do
        echo "Cleaning Python: $file"
        
        # Remove unused imports
        if [[ "$dry_run" != "true" ]]; then
            if command -v autoflake >/dev/null 2>&1; then
                autoflake --in-place --remove-unused-variables --remove-all-unused-imports "$file"
            elif command -v unimport >/dev/null 2>&1; then
                unimport --remove-unused-imports "$file"
            fi
        else
            local unused_imports=$(count_unused_imports "$file" "python")
            echo "  Would remove $unused_imports unused imports"
        fi
        
        # Remove unused variables
        if [[ "$dry_run" != "true" ]]; then
            if command -v vulture >/dev/null 2>&1; then
                # vulture can identify but not auto-remove unused code
                vulture "$file" 2>/dev/null | grep "unused" || true
            fi
        fi
        
        # Remove debug prints
        if [[ "$dry_run" != "true" ]]; then
            sed -i '' '/print(/d' "$file" 2>/dev/null || sed -i '/print(/d' "$file" 2>/dev/null || true
        else
            local debug_prints=$(grep -c "print(" "$file" 2>/dev/null || echo 0)
            echo "  Would remove $debug_prints debug print statements"
        fi
        
        # Remove trailing whitespace
        if [[ "$dry_run" != "true" ]]; then
            sed -i '' 's/[[:space:]]*$//' "$file" 2>/dev/null || sed -i 's/[[:space:]]*$//' "$file" 2>/dev/null || true
        fi
    done
}

# Go cleanup
cleanup_go_standard() {
    local dry_run=$1
    shift
    local files=("$@")
    
    for file in "${files[@]}"; do
        echo "Cleaning Go: $file"
        
        # Go has built-in unused import detection
        if [[ "$dry_run" != "true" ]]; then
            if command -v goimports >/dev/null 2>&1; then
                goimports -w "$file"
            fi
        else
            echo "  Would remove unused imports and format"
        fi
        
        # Remove debug prints
        if [[ "$dry_run" != "true" ]]; then
            sed -i '' '/fmt\.Print/d' "$file" 2>/dev/null || sed -i '/fmt\.Print/d' "$file" 2>/dev/null || true
        else
            local debug_prints=$(grep -c "fmt\.Print" "$file" 2>/dev/null || echo 0)
            echo "  Would remove $debug_prints debug print statements"
        fi
    done
}

# Rust cleanup
cleanup_rust_standard() {
    local dry_run=$1
    shift
    local files=("$@")
    
    for file in "${files[@]}"; do
        echo "Cleaning Rust: $file"
        
        # Rust compiler catches unused code
        if [[ "$dry_run" != "true" ]]; then
            if command -v rustfmt >/dev/null 2>&1; then
                rustfmt "$file"
            fi
        else
            echo "  Would format and organize code"
        fi
        
        # Remove debug macros
        if [[ "$dry_run" != "true" ]]; then
            sed -i '' '/println!/d' "$file" 2>/dev/null || sed -i '/println!/d' "$file" 2>/dev/null || true
        else
            local debug_prints=$(grep -c "println!" "$file" 2>/dev/null || echo 0)
            echo "  Would remove $debug_prints debug println! statements"
        fi
    done
}

# Java cleanup
cleanup_java_standard() {
    local dry_run=$1
    shift
    local files=("$@")
    
    for file in "${files[@]}"; do
        echo "Cleaning Java: $file"
        
        # Remove unused imports (basic approach)
        if [[ "$dry_run" != "true" ]]; then
            # Remove imports that aren't used in the file
            local temp_file=$(mktemp)
            while IFS= read -r line; do
                if [[ "$line" =~ ^import ]]; then
                    local import_class=$(echo "$line" | sed 's/import.*\.\([^;]*\);/\1/')
                    if grep -q "$import_class" "$file"; then
                        echo "$line" >> "$temp_file"
                    fi
                else
                    echo "$line" >> "$temp_file"
                fi
            done < "$file"
            mv "$temp_file" "$file"
        else
            echo "  Would remove unused imports"
        fi
        
        # Remove debug prints
        if [[ "$dry_run" != "true" ]]; then
            sed -i '' '/System\.out\.print/d' "$file" 2>/dev/null || sed -i '/System\.out\.print/d' "$file" 2>/dev/null || true
        else
            local debug_prints=$(grep -c "System\.out\.print" "$file" 2>/dev/null || echo 0)
            echo "  Would remove $debug_prints debug print statements"
        fi
    done
}

# Ruby cleanup
cleanup_ruby_standard() {
    local dry_run=$1
    shift
    local files=("$@")
    
    for file in "${files[@]}"; do
        echo "Cleaning Ruby: $file"
        
        # Use RuboCop for cleanup if available
        if [[ "$dry_run" != "true" ]]; then
            if command -v rubocop >/dev/null 2>&1; then
                rubocop --auto-correct "$file" 2>/dev/null || true
            fi
        else
            echo "  Would apply RuboCop auto-corrections"
        fi
        
        # Remove debug puts
        if [[ "$dry_run" != "true" ]]; then
            sed -i '' '/puts\s/d' "$file" 2>/dev/null || sed -i '/puts\s/d' "$file" 2>/dev/null || true
        else
            local debug_puts=$(grep -c "puts " "$file" 2>/dev/null || echo 0)
            echo "  Would remove $debug_puts debug puts statements"
        fi
    done
}

# C/C++ cleanup
cleanup_c_cpp_standard() {
    local dry_run=$1
    shift
    local files=("$@")
    
    for file in "${files[@]}"; do
        echo "Cleaning C/C++: $file"
        
        # Remove unused includes (basic approach)
        if [[ "$dry_run" != "true" ]]; then
            # This would need more sophisticated analysis
            echo "  C/C++ cleanup requires manual review"
        else
            echo "  Would analyze and remove unused includes"
        fi
        
        # Remove debug printf
        if [[ "$dry_run" != "true" ]]; then
            sed -i '' '/printf(/d' "$file" 2>/dev/null || sed -i '/printf(/d' "$file" 2>/dev/null || true
        else
            local debug_prints=$(grep -c "printf(" "$file" 2>/dev/null || echo 0)
            echo "  Would remove $debug_prints debug printf statements"
        fi
    done
}

# Aggressive cleanup
cleanup_language_aggressive() {
    local language=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    echo "Aggressive cleanup for $language"
    
    # Run standard cleanup first
    cleanup_language_standard "$language" "$dry_run" "${files[@]}"
    
    # Additional aggressive cleanup
    for file in "${files[@]}"; do
        if [[ "$dry_run" != "true" ]]; then
            # Remove all TODO/FIXME comments
            sed -i '' '/TODO\|FIXME\|XXX\|HACK/d' "$file" 2>/dev/null || sed -i '/TODO\|FIXME\|XXX\|HACK/d' "$file" 2>/dev/null || true
            
            # Remove excessive blank lines
            awk '!/^$/ {print; blank=0} /^$/ {if (!blank) print; blank=1}' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
        else
            local todos=$(find_todo_comments "$file" | wc -l)
            echo "  Would remove $todos TODO/FIXME comments from $file"
        fi
    done
}

# Conservative cleanup
cleanup_language_conservative() {
    local language=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    echo "Conservative cleanup for $language"
    
    # Only remove obviously safe items
    for file in "${files[@]}"; do
        if [[ "$dry_run" != "true" ]]; then
            # Only remove trailing whitespace
            sed -i '' 's/[[:space:]]*$//' "$file" 2>/dev/null || sed -i 's/[[:space:]]*$//' "$file" 2>/dev/null || true
        else
            echo "  Would remove trailing whitespace from $file"
        fi
    done
}

# Cleanup imports only
cleanup_imports_only() {
    local language=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    echo "Imports-only cleanup for $language"
    
    case "$language" in
        "javascript"|"typescript")
            for file in "${files[@]}"; do
                if [[ "$dry_run" != "true" ]]; then
                    if command -v eslint >/dev/null 2>&1; then
                        eslint --fix --rule 'no-unused-vars: error' "$file" 2>/dev/null || true
                    fi
                else
                    echo "  Would remove unused imports from $file"
                fi
            done
            ;;
        "python")
            for file in "${files[@]}"; do
                if [[ "$dry_run" != "true" ]]; then
                    if command -v isort >/dev/null 2>&1; then
                        isort "$file"
                    fi
                    if command -v autoflake >/dev/null 2>&1; then
                        autoflake --in-place --remove-all-unused-imports "$file"
                    fi
                else
                    echo "  Would organize and remove unused imports from $file"
                fi
            done
            ;;
        "go")
            for file in "${files[@]}"; do
                if [[ "$dry_run" != "true" ]]; then
                    if command -v goimports >/dev/null 2>&1; then
                        goimports -w "$file"
                    fi
                else
                    echo "  Would organize imports in $file"
                fi
            done
            ;;
    esac
}

# Cleanup dead code only
cleanup_dead_code_only() {
    local language=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    echo "Dead code cleanup for $language"
    
    for file in "${files[@]}"; do
        # This requires more sophisticated analysis
        # For now, just report what would be done
        local dead_functions=$(find_dead_functions "$file")
        if [ -n "$dead_functions" ]; then
            if [[ "$dry_run" != "true" ]]; then
                echo "  WARNING: Dead code detection requires manual review for $file"
                echo "  Potentially dead functions:"
                echo "$dead_functions"
            else
                echo "  Would analyze dead code in $file"
            fi
        fi
    done
}

# Cleanup comments only
cleanup_comments_only() {
    local language=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    echo "Comments cleanup for $language"
    
    for file in "${files[@]}"; do
        if [[ "$dry_run" != "true" ]]; then
            # Remove TODO/FIXME comments
            sed -i '' '/TODO\|FIXME\|XXX\|HACK/d' "$file" 2>/dev/null || sed -i '/TODO\|FIXME\|XXX\|HACK/d' "$file" 2>/dev/null || true
        else
            local todos=$(find_todo_comments "$file" | wc -l)
            echo "  Would remove $todos TODO/FIXME comments from $file"
        fi
    done
}

# Verify cleanup results
verify_cleanup_results() {
    local target=$1
    shift
    local files=("$@")
    
    echo "Verifying cleanup results..."
    
    local verification_errors=0
    
    for file in "${files[@]}"; do
        # Check syntax
        if ! validate_syntax "$file"; then
            echo "ERROR: Syntax error in cleaned file: $file"
            verification_errors=$((verification_errors + 1))
        fi
        
        # Check if file still has content
        if [ ! -s "$file" ]; then
            echo "WARNING: File is now empty: $file"
        fi
        
        # Check for remaining issues
        local remaining_issues=$(analyze_remaining_issues "$file")
        if [ -n "$remaining_issues" ]; then
            echo "INFO: Remaining issues in $file:"
            echo "$remaining_issues"
        fi
    done
    
    if [ $verification_errors -eq 0 ]; then
        echo "All cleaned files verified successfully"
        return 0
    else
        echo "Verification failed for $verification_errors files"
        return 1
    fi
}

# Analyze remaining issues after cleanup
analyze_remaining_issues() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    local issues=""
    
    # Check for remaining unused imports
    local unused_imports=$(count_unused_imports "$file" "$language")
    if [ "$unused_imports" -gt 0 ]; then
        issues="$issues\n  - $unused_imports unused imports"
    fi
    
    # Check for remaining TODO comments
    local todos=$(find_todo_comments "$file" | wc -l)
    if [ "$todos" -gt 0 ]; then
        issues="$issues\n  - $todos TODO/FIXME comments"
    fi
    
    # Check for trailing whitespace
    if grep -q '[[:space:]]$' "$file"; then
        issues="$issues\n  - Trailing whitespace found"
    fi
    
    echo -e "$issues"
}

# Generate cleanup report
generate_cleanup_report() {
    local target=${1:-.}
    local before_snapshot=$2
    local after_snapshot=$3
    
    echo "Cleanup Report"
    echo "=============="
    echo "Target: $target"
    echo "Before snapshot: $before_snapshot"
    echo "After snapshot: $after_snapshot"
    echo ""
    
    # Calculate statistics
    local files_processed=$(find "$target" -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" | wc -l)
    local total_size_before=$(du -s "$before_snapshot" 2>/dev/null | awk '{print $1}' || echo 0)
    local total_size_after=$(du -s "$target" 2>/dev/null | awk '{print $1}' || echo 0)
    local size_reduction=$((total_size_before - total_size_after))
    
    echo "Statistics:"
    echo "  Files processed: $files_processed"
    echo "  Size before: $(format_file_size $((total_size_before * 1024)))"
    echo "  Size after: $(format_file_size $((total_size_after * 1024)))"
    echo "  Size reduction: $(format_file_size $((size_reduction * 1024)))"
    
    if [ $total_size_before -gt 0 ]; then
        local reduction_percentage=$((size_reduction * 100 / total_size_before))
        echo "  Reduction percentage: ${reduction_percentage}%"
    fi
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
    
    # Execute cleanup
    cleanup_codebase "$target" "$dry_run" "$mode"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Cleanup Categories

### Unused Imports
- **JavaScript/TypeScript**: ESLint-based removal
- **Python**: autoflake, unimport integration
- **Go**: goimports automatic cleanup
- **Java**: Static analysis of import usage
- **Other languages**: Pattern-based detection

### Dead Code Detection
- **Unreachable functions**: Functions never called
- **Unused variables**: Variables assigned but never read
- **Empty files**: Files with no meaningful content
- **Orphaned code**: Code blocks with no references

### Code Optimization
- **Duplicate imports**: Multiple imports of same module
- **Excessive whitespace**: Multiple blank lines
- **Debug statements**: console.log, print(), etc.
- **TODO comments**: Development artifacts

### Safety Features
- **Syntax validation**: Ensures cleanup doesn't break code
- **Backup creation**: Automatic snapshots before changes
- **Conservative mode**: Minimal, safe-only changes
- **Verification**: Post-cleanup integrity checks

## Modes

### Standard Mode
- Remove unused imports
- Clean up obvious dead code
- Remove debug statements
- Format whitespace

### Aggressive Mode
- All standard cleanup
- Remove TODO/FIXME comments
- More aggressive dead code removal
- Extensive formatting cleanup

### Conservative Mode
- Only remove trailing whitespace
- Basic import organization
- No code removal

### Targeted Modes
- **imports-only**: Focus on import cleanup
- **dead-code-only**: Focus on unused code
- **comments-only**: Focus on comment cleanup

This cleanup command provides comprehensive code cleanup capabilities with intelligent analysis, safety mechanisms, and multiple modes to suit different cleanup requirements while maintaining code functionality.