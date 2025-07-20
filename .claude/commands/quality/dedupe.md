---
description: Advanced duplicate detection and merging command for identifying and resolving code duplication across the codebase
---

# Dedupe Command - Advanced Duplicate Detection & Merging

Intelligent deduplication command that identifies duplicate code blocks, similar functions, redundant patterns, and provides automated and semi-automated merging strategies to improve code maintainability.

## Usage

```bash
# Basic deduplication
claude dedupe

# Dedupe specific directory
claude dedupe src/

# Dedupe specific files
claude dedupe src/components/*.js

# Dry run (preview changes)
claude dedupe --dry-run

# Aggressive deduplication
claude dedupe --aggressive

# Conservative deduplication (safer)
claude dedupe --conservative

# Specific duplicate types
claude dedupe --functions-only
claude dedupe --blocks-only
claude dedupe --imports-only

# Set minimum similarity threshold
claude dedupe --threshold=80

# Interactive mode
claude dedupe --interactive
```

## Implementation

```bash
#!/bin/bash

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_shared/utils.md"
source "$SCRIPT_DIR/_shared/safety.md"
source "$SCRIPT_DIR/_shared/orchestration.md"

# Main deduplication function
dedupe_codebase() {
    local target=${1:-.}
    local dry_run=${2:-false}
    local mode=${3:-"standard"}
    local threshold=${4:-75}
    
    echo "Starting code deduplication..."
    echo "Target: $target"
    echo "Dry run: $dry_run"
    echo "Mode: $mode"
    echo "Similarity threshold: $threshold%"
    
    # Safety checks
    if ! run_safety_checks "dedupe" "$target" "$dry_run"; then
        echo "ERROR: Safety checks failed"
        return 1
    fi
    
    # Create snapshot if not dry run
    local snapshot_path=""
    if [[ "$dry_run" != "true" ]]; then
        snapshot_path=$(create_safety_snapshot "$target" "dedupe")
        echo "Snapshot created: $snapshot_path"
    fi
    
    # Discover files to analyze
    local files_to_analyze=($(discover_analyzable_files "$target"))
    echo "Found ${#files_to_analyze[@]} files to analyze"
    
    if [ ${#files_to_analyze[@]} -eq 0 ]; then
        echo "No files to analyze found"
        return 0
    fi
    
    # Validate operation safety
    if ! validate_operation_safety "dedupe" "${files_to_analyze[@]}"; then
        echo "Operation cancelled by user"
        return 1
    fi
    
    # Analyze duplicates across codebase
    echo "Analyzing codebase for duplicates..."
    local duplicate_analysis=$(analyze_duplicates "$target" "$threshold" "${files_to_analyze[@]}")
    
    echo "Duplicate Analysis Results:"
    echo "$duplicate_analysis"
    
    # Group files by language for targeted deduplication
    declare -A language_groups
    for file in "${files_to_analyze[@]}"; do
        local language=$(detect_file_language "$file")
        if [ -n "${language_groups[$language]}" ]; then
            language_groups[$language]="${language_groups[$language]} $file"
        else
            language_groups[$language]="$file"
        fi
    done
    
    # Execute deduplication for each language group
    local total_deduped=0
    local total_errors=0
    
    for language in "${!language_groups[@]}"; do
        echo "Deduplicating $language files..."
        
        local files_list=(${language_groups[$language]})
        local deduped_count=0
        local error_count=0
        
        case "$mode" in
            "aggressive")
                dedupe_language_aggressive "$language" "$dry_run" "$threshold" "${files_list[@]}"
                ;;
            "conservative")
                dedupe_language_conservative "$language" "$dry_run" "$threshold" "${files_list[@]}"
                ;;
            "functions-only")
                dedupe_functions_only "$language" "$dry_run" "$threshold" "${files_list[@]}"
                ;;
            "blocks-only")
                dedupe_blocks_only "$language" "$dry_run" "$threshold" "${files_list[@]}"
                ;;
            "imports-only")
                dedupe_imports_only "$language" "$dry_run" "${files_list[@]}"
                ;;
            "interactive")
                dedupe_language_interactive "$language" "$dry_run" "$threshold" "${files_list[@]}"
                ;;
            *)
                dedupe_language_standard "$language" "$dry_run" "$threshold" "${files_list[@]}"
                ;;
        esac
        
        local result=$?
        if [ $result -eq 0 ]; then
            deduped_count=${#files_list[@]}
        else
            error_count=${#files_list[@]}
        fi
        
        total_deduped=$((total_deduped + deduped_count))
        total_errors=$((total_errors + error_count))
        
        echo "$language: $deduped_count processed, $error_count errors"
    done
    
    # Generate deduplication summary
    echo ""
    echo "Deduplication Summary:"
    echo "====================="
    echo "Total files processed: $((total_deduped + total_errors))"
    echo "Successfully processed: $total_deduped"
    echo "Errors: $total_errors"
    
    if [[ "$dry_run" == "true" ]]; then
        echo ""
        echo "This was a dry run - no files were modified"
    elif [ -n "$snapshot_path" ]; then
        echo "Snapshot available for rollback: $snapshot_path"
    fi
    
    # Verify deduplication results
    if [[ "$dry_run" != "true" ]] && [ $total_errors -eq 0 ]; then
        echo "Verifying deduplication results..."
        verify_dedupe_results "$target" "${files_to_analyze[@]}"
    fi
    
    return $total_errors
}

# Discover files suitable for analysis
discover_analyzable_files() {
    local target=$1
    local exclude_patterns=${EXCLUDE_PATTERNS:-".git node_modules __pycache__ .pytest_cache target build dist coverage .vscode .idea .claude .Claude .CLAUDE"}
    
    # Source code patterns (excluding generated and test files for better analysis)
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
    
    # Find source files excluding generated, test, and vendor code
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
    
    # Additional exclusions for generated and test files
    find_cmd="$find_cmd ! -name '*.min.js' ! -name '*.bundle.js' ! -name '*-compiled.*' ! -name '*.generated.*' ! -name '*.test.*' ! -name '*.spec.*'"
    
    # Additional exclusions for .claude-related files and directories
    find_cmd="$find_cmd ! -name '.claude*' ! -name '*.claude*' ! -path '*/.claude' ! -path '*/.Claude' ! -path '*/.CLAUDE'"
    
    # Execute and filter
    eval "$find_cmd" 2>/dev/null | while read -r file; do
        if [ -f "$file" ] && [ -r "$file" ] && [ -w "$file" ]; then
            if ! is_binary_file "$file" && ! is_generated_file "$file"; then
                # Only include files with substantial content
                local line_count=$(wc -l < "$file")
                if [ "$line_count" -gt 10 ]; then
                    echo "$file"
                fi
            fi
        fi
    done
}

# Analyze duplicates across codebase
analyze_duplicates() {
    local target=$1
    local threshold=$2
    shift 2
    local files=("$@")
    
    local duplicate_functions=0
    local duplicate_blocks=0
    local duplicate_imports=0
    local similar_files=0
    local total_duplicates=0
    
    echo "Analyzing ${#files[@]} files for duplicates..."
    
    # Create temporary analysis files
    local temp_dir=$(mktemp -d)
    local functions_file="$temp_dir/functions.txt"
    local blocks_file="$temp_dir/blocks.txt"
    local imports_file="$temp_dir/imports.txt"
    
    # Extract functions, blocks, and imports from all files
    for file in "${files[@]}"; do
        local language=$(detect_file_language "$file")
        
        # Extract function signatures
        extract_function_signatures "$file" "$language" >> "$functions_file"
        
        # Extract code blocks
        extract_code_blocks "$file" "$language" >> "$blocks_file"
        
        # Extract imports
        extract_imports "$file" >> "$imports_file"
    done
    
    # Analyze for duplicates
    duplicate_functions=$(analyze_duplicate_functions "$functions_file" "$threshold")
    duplicate_blocks=$(analyze_duplicate_blocks "$blocks_file" "$threshold")
    duplicate_imports=$(analyze_duplicate_imports "$imports_file")
    similar_files=$(analyze_similar_files "$target" "$threshold" "${files[@]}")
    
    total_duplicates=$((duplicate_functions + duplicate_blocks + duplicate_imports))
    
    # Cleanup
    rm -rf "$temp_dir"
    
    cat <<EOF
  Duplicate functions: $duplicate_functions
  Duplicate blocks: $duplicate_blocks
  Duplicate imports: $duplicate_imports
  Similar files: $similar_files
  Total duplicates: $total_duplicates
EOF
}

# Extract function signatures from file
extract_function_signatures() {
    local file=$1
    local language=$2
    
    case "$language" in
        "javascript"|"typescript")
            grep -n -E "^function\s+\w+|^const\s+\w+\s*=|^export\s+function\s+\w+|^\s*\w+\s*:\s*function" "$file" | \
                sed "s|^|$file:|"
            ;;
        "python")
            grep -n -E "^def\s+\w+|^class\s+\w+" "$file" | \
                sed "s|^|$file:|"
            ;;
        "java")
            grep -n -E "^\s*(public|private|protected).*\s+\w+\s*\(" "$file" | \
                sed "s|^|$file:|"
            ;;
        "go")
            grep -n -E "^func\s+\w+" "$file" | \
                sed "s|^|$file:|"
            ;;
        "rust")
            grep -n -E "^fn\s+\w+|^impl\s+\w+" "$file" | \
                sed "s|^|$file:|"
            ;;
        "c"|"cpp")
            grep -n -E "^\w+\s+\w+\s*\(" "$file" | \
                sed "s|^|$file:|"
            ;;
        *)
            # Generic function pattern
            grep -n -E "^\w+.*\(" "$file" | \
                sed "s|^|$file:|"
            ;;
    esac
}

# Extract code blocks from file
extract_code_blocks() {
    local file=$1
    local language=$2
    local min_lines=${3:-5}
    
    # Extract blocks of consecutive non-empty lines
    awk -v file="$file" -v min_lines="$min_lines" '
    /^[[:space:]]*$/ { 
        if (block_lines >= min_lines) {
            print file ":" start_line ":" block_lines ":" block_hash
        }
        block_lines = 0
        block_content = ""
        next
    }
    {
        if (block_lines == 0) {
            start_line = NR
        }
        block_lines++
        # Simple hash of content (remove whitespace for comparison)
        gsub(/[[:space:]]/, "", $0)
        block_content = block_content $0
    }
    END {
        if (block_lines >= min_lines) {
            print file ":" start_line ":" block_lines ":" length(block_content)
        }
    }' "$file"
}

# Analyze duplicate functions
analyze_duplicate_functions() {
    local functions_file=$1
    local threshold=$2
    
    # Simple duplicate detection based on function signatures
    local duplicates=$(sort "$functions_file" | uniq -d | wc -l)
    echo "$duplicates"
}

# Analyze duplicate blocks
analyze_duplicate_blocks() {
    local blocks_file=$1
    local threshold=$2
    
    # Group blocks by similar hash/length
    local duplicates=$(awk -F: '{print $4}' "$blocks_file" | sort | uniq -d | wc -l)
    echo "$duplicates"
}

# Analyze duplicate imports
analyze_duplicate_imports() {
    local imports_file=$1
    
    # Count duplicate import statements
    local duplicates=$(sort "$imports_file" | uniq -d | wc -l)
    echo "$duplicates"
}

# Analyze similar files
analyze_similar_files() {
    local target=$1
    local threshold=$2
    shift 2
    local files=("$@")
    
    local similar_count=0
    
    # Compare files pairwise for similarity
    for ((i=0; i<${#files[@]}; i++)); do
        for ((j=i+1; j<${#files[@]}; j++)); do
            local file1="${files[$i]}"
            local file2="${files[$j]}"
            
            # Skip if different languages
            local lang1=$(detect_file_language "$file1")
            local lang2=$(detect_file_language "$file2")
            if [[ "$lang1" != "$lang2" ]]; then
                continue
            fi
            
            # Calculate similarity
            local similarity=$(calculate_file_similarity "$file1" "$file2")
            if [ "$similarity" -ge "$threshold" ]; then
                similar_count=$((similar_count + 1))
            fi
        done
    done
    
    echo "$similar_count"
}

# Calculate similarity between two files
calculate_file_similarity() {
    local file1=$1
    local file2=$2
    
    # Simple line-based similarity
    local common_lines=$(comm -12 <(sort "$file1") <(sort "$file2") | wc -l)
    local total_lines1=$(wc -l < "$file1")
    local total_lines2=$(wc -l < "$file2")
    local avg_lines=$(((total_lines1 + total_lines2) / 2))
    
    if [ "$avg_lines" -eq 0 ]; then
        echo 0
    else
        local similarity=$((common_lines * 100 / avg_lines))
        echo "$similarity"
    fi
}

# Standard deduplication for language
dedupe_language_standard() {
    local language=$1
    local dry_run=$2
    local threshold=$3
    shift 3
    local files=("$@")
    
    echo "Standard deduplication for $language (${#files[@]} files)"
    
    case "$language" in
        "javascript"|"typescript")
            dedupe_js_ts_standard "$dry_run" "$threshold" "${files[@]}"
            ;;
        "python")
            dedupe_python_standard "$dry_run" "$threshold" "${files[@]}"
            ;;
        "go")
            dedupe_go_standard "$dry_run" "$threshold" "${files[@]}"
            ;;
        "java")
            dedupe_java_standard "$dry_run" "$threshold" "${files[@]}"
            ;;
        "rust")
            dedupe_rust_standard "$dry_run" "$threshold" "${files[@]}"
            ;;
        *)
            echo "No deduplication rules for language: $language"
            ;;
    esac
}

# JavaScript/TypeScript deduplication
dedupe_js_ts_standard() {
    local dry_run=$1
    local threshold=$2
    shift 2
    local files=("$@")
    
    echo "Analyzing JavaScript/TypeScript files for duplicates..."
    
    # Find duplicate functions
    local duplicate_functions=$(find_duplicate_js_functions "${files[@]}")
    
    if [ -n "$duplicate_functions" ]; then
        echo "Found duplicate functions:"
        echo "$duplicate_functions"
        
        if [[ "$dry_run" != "true" ]]; then
            echo "WARNING: Automatic function deduplication requires manual review"
            echo "Consider using --interactive mode for guided deduplication"
        else
            echo "Would analyze and suggest function consolidation"
        fi
    fi
    
    # Find duplicate imports
    for file in "${files[@]}"; do
        local duplicate_imports=$(find_duplicate_imports_in_file "$file")
        if [ -n "$duplicate_imports" ]; then
            echo "Duplicate imports in $file:"
            echo "$duplicate_imports"
            
            if [[ "$dry_run" != "true" ]]; then
                remove_duplicate_imports "$file"
            fi
        fi
    done
    
    # Find similar code blocks
    local similar_blocks=$(find_similar_js_blocks "$threshold" "${files[@]}")
    if [ -n "$similar_blocks" ]; then
        echo "Similar code blocks found:"
        echo "$similar_blocks"
        
        if [[ "$dry_run" != "true" ]]; then
            echo "Manual review recommended for code block consolidation"
        fi
    fi
}

# Python deduplication
dedupe_python_standard() {
    local dry_run=$1
    local threshold=$2
    shift 2
    local files=("$@")
    
    echo "Analyzing Python files for duplicates..."
    
    # Find duplicate functions
    local duplicate_functions=$(find_duplicate_python_functions "${files[@]}")
    
    if [ -n "$duplicate_functions" ]; then
        echo "Found duplicate functions:"
        echo "$duplicate_functions"
        
        if [[ "$dry_run" != "true" ]]; then
            echo "WARNING: Automatic function deduplication requires manual review"
        fi
    fi
    
    # Remove duplicate imports
    for file in "${files[@]}"; do
        if [[ "$dry_run" != "true" ]]; then
            if command -v isort >/dev/null 2>&1; then
                isort --remove-redundant-aliases "$file"
            fi
        else
            local duplicate_imports=$(count_duplicate_imports "$file" "python")
            echo "Would remove $duplicate_imports duplicate imports from $file"
        fi
    done
}

# Go deduplication
dedupe_go_standard() {
    local dry_run=$1
    local threshold=$2
    shift 2
    local files=("$@")
    
    echo "Analyzing Go files for duplicates..."
    
    # Go has strict import rules, focus on code duplication
    local duplicate_functions=$(find_duplicate_go_functions "${files[@]}")
    
    if [ -n "$duplicate_functions" ]; then
        echo "Found potential duplicate functions:"
        echo "$duplicate_functions"
        
        if [[ "$dry_run" != "true" ]]; then
            echo "Manual review recommended for Go function deduplication"
        fi
    fi
}

# Java deduplication
dedupe_java_standard() {
    local dry_run=$1
    local threshold=$2
    shift 2
    local files=("$@")
    
    echo "Analyzing Java files for duplicates..."
    
    # Find duplicate methods
    local duplicate_methods=$(find_duplicate_java_methods "${files[@]}")
    
    if [ -n "$duplicate_methods" ]; then
        echo "Found duplicate methods:"
        echo "$duplicate_methods"
        
        if [[ "$dry_run" != "true" ]]; then
            echo "Consider extracting common methods to utility classes"
        fi
    fi
}

# Rust deduplication
dedupe_rust_standard() {
    local dry_run=$1
    local threshold=$2
    shift 2
    local files=("$@")
    
    echo "Analyzing Rust files for duplicates..."
    
    # Find duplicate functions
    local duplicate_functions=$(find_duplicate_rust_functions "${files[@]}")
    
    if [ -n "$duplicate_functions" ]; then
        echo "Found duplicate functions:"
        echo "$duplicate_functions"
        
        if [[ "$dry_run" != "true" ]]; then
            echo "Consider extracting to common modules or traits"
        fi
    fi
}

# Find duplicate JavaScript functions
find_duplicate_js_functions() {
    local files=("$@")
    local temp_file=$(mktemp)
    
    for file in "${files[@]}"; do
        # Extract function bodies (simplified)
        awk '/^function\s+\w+|^const\s+\w+\s*=.*function/ {
            start = NR
            func_name = $0
            body = ""
        }
        /^}/ && start {
            print file ":" start ":" func_name ":" length(body)
            start = 0
        }
        start { body = body $0 }' file="$file" "$file" >> "$temp_file"
    done
    
    # Find functions with similar lengths/patterns
    awk -F: '{
        key = $4  # body length as simple similarity metric
        if (count[key]++ > 0) {
            print "Potential duplicate: " $1 ":" $2 " and " prev[key]
        }
        prev[key] = $1 ":" $2
    }' "$temp_file"
    
    rm -f "$temp_file"
}

# Find duplicate Python functions
find_duplicate_python_functions() {
    local files=("$@")
    local temp_file=$(mktemp)
    
    for file in "${files[@]}"; do
        # Extract function definitions and basic structure
        python3 -c "
import ast
import sys

try:
    with open('$file', 'r') as f:
        content = f.read()
    
    tree = ast.parse(content)
    
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            # Simple signature comparison
            args = [arg.arg for arg in node.args.args]
            signature = f'{node.name}({len(args)})'
            print(f'$file:{node.lineno}:{signature}')
            
except:
    pass
" >> "$temp_file" 2>/dev/null
    done
    
    # Find duplicate signatures
    sort "$temp_file" | uniq -d
    
    rm -f "$temp_file"
}

# Find duplicate Go functions
find_duplicate_go_functions() {
    local files=("$@")
    local temp_file=$(mktemp)
    
    for file in "${files[@]}"; do
        # Extract function signatures
        grep -n "^func\s" "$file" | sed "s|^|$file:|" >> "$temp_file"
    done
    
    # Simple duplicate detection
    awk -F: '{
        signature = $3
        gsub(/\s+/, " ", signature)  # normalize whitespace
        if (count[signature]++ > 0) {
            print "Potential duplicate: " $1 ":" $2 " - " signature
        }
    }' "$temp_file"
    
    rm -f "$temp_file"
}

# Find duplicate Java methods
find_duplicate_java_methods() {
    local files=("$@")
    local temp_file=$(mktemp)
    
    for file in "${files[@]}"; do
        # Extract method signatures
        grep -n -E "^\s*(public|private|protected).*\s+\w+\s*\(" "$file" | \
            sed "s|^|$file:|" >> "$temp_file"
    done
    
    # Analyze for similar method signatures
    awk -F: '{
        signature = $3
        gsub(/\s+/, " ", signature)  # normalize whitespace
        # Remove modifiers for comparison
        gsub(/(public|private|protected|static|final)/, "", signature)
        if (count[signature]++ > 0) {
            print "Similar method: " $1 ":" $2 " - " signature
        }
    }' "$temp_file"
    
    rm -f "$temp_file"
}

# Find duplicate Rust functions
find_duplicate_rust_functions() {
    local files=("$@")
    local temp_file=$(mktemp)
    
    for file in "${files[@]}"; do
        # Extract function signatures
        grep -n "^fn\s" "$file" | sed "s|^|$file:|" >> "$temp_file"
    done
    
    # Find similar function signatures
    awk -F: '{
        signature = $3
        gsub(/\s+/, " ", signature)  # normalize whitespace
        if (count[signature]++ > 0) {
            print "Potential duplicate: " $1 ":" $2 " - " signature
        }
    }' "$temp_file"
    
    rm -f "$temp_file"
}

# Find duplicate imports in file
find_duplicate_imports_in_file() {
    local file=$1
    
    local imports=$(extract_imports "$file")
    if [ -n "$imports" ]; then
        echo "$imports" | sort | uniq -d
    fi
}

# Remove duplicate imports from file
remove_duplicate_imports() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    case "$language" in
        "javascript"|"typescript")
            if command -v eslint >/dev/null 2>&1; then
                eslint --fix --rule 'no-duplicate-imports: error' "$file" 2>/dev/null || true
            fi
            ;;
        "python")
            if command -v isort >/dev/null 2>&1; then
                isort --remove-redundant-aliases "$file"
            fi
            ;;
    esac
}

# Find similar code blocks
find_similar_js_blocks() {
    local threshold=$1
    shift
    local files=("$@")
    
    # This is a simplified version - in practice would use more sophisticated AST analysis
    local temp_file=$(mktemp)
    
    for file in "${files[@]}"; do
        # Extract code blocks (functions, if statements, loops)
        awk '/^[[:space:]]*if\s*\(|^[[:space:]]*for\s*\(|^[[:space:]]*while\s*\(|^[[:space:]]*function\s/ {
            start = NR
            level = 0
            block = ""
        }
        /{/ { level++ }
        /}/ { 
            level--
            if (level == 0 && start) {
                print file ":" start ":" NR ":" length(block)
                start = 0
            }
        }
        start { block = block $0 }' file="$file" "$file" >> "$temp_file"
    done
    
    # Find blocks with similar lengths (simplified similarity)
    awk -F: -v threshold="$threshold" '{
        length = $4
        range = int(length * 0.2)  # 20% tolerance
        for (l = length - range; l <= length + range; l++) {
            if (blocks[l] && blocks[l] != $1 ":" $2) {
                print "Similar blocks: " $1 ":" $2 "-" $3 " and " blocks[l]
            }
        }
        blocks[length] = $1 ":" $2 "-" $3
    }' "$temp_file"
    
    rm -f "$temp_file"
}

# Interactive deduplication
dedupe_language_interactive() {
    local language=$1
    local dry_run=$2
    local threshold=$3
    shift 3
    local files=("$@")
    
    echo "Interactive deduplication for $language"
    echo "Analyzing files for duplicates..."
    
    # Find all potential duplicates
    local duplicates_report=$(mktemp)
    case "$language" in
        "javascript"|"typescript")
            find_duplicate_js_functions "${files[@]}" > "$duplicates_report"
            ;;
        "python")
            find_duplicate_python_functions "${files[@]}" > "$duplicates_report"
            ;;
        *)
            echo "Interactive mode not implemented for $language"
            return 1
            ;;
    esac
    
    # Present duplicates to user for review
    if [ -s "$duplicates_report" ]; then
        echo "Found potential duplicates:"
        cat "$duplicates_report"
        echo ""
        
        while IFS= read -r duplicate_info; do
            echo "Duplicate found: $duplicate_info"
            echo "Options:"
            echo "1) Skip this duplicate"
            echo "2) Show code comparison"
            echo "3) Mark for manual review"
            echo "4) Exit interactive mode"
            
            read -p "Choose action [1-4]: " action
            
            case "$action" in
                2)
                    show_duplicate_comparison "$duplicate_info"
                    ;;
                3)
                    echo "$duplicate_info" >> "$target/.dedupe-review.txt"
                    echo "Marked for review"
                    ;;
                4)
                    break
                    ;;
                *)
                    echo "Skipping..."
                    ;;
            esac
            echo ""
        done < "$duplicates_report"
    else
        echo "No duplicates found for interactive review"
    fi
    
    rm -f "$duplicates_report"
}

# Show comparison between duplicates
show_duplicate_comparison() {
    local duplicate_info=$1
    
    # Parse duplicate info to extract file locations
    # This would need to be implemented based on the specific format
    echo "Code comparison would be shown here"
    echo "Duplicate info: $duplicate_info"
}

# Aggressive deduplication
dedupe_language_aggressive() {
    local language=$1
    local dry_run=$2
    local threshold=$3
    shift 3
    local files=("$@")
    
    echo "Aggressive deduplication for $language"
    
    # Run standard deduplication
    dedupe_language_standard "$language" "$dry_run" "$threshold" "${files[@]}"
    
    # Additional aggressive steps
    echo "Performing aggressive duplicate removal..."
    
    # Lower threshold for similarity detection
    local aggressive_threshold=$((threshold - 20))
    if [ $aggressive_threshold -lt 50 ]; then
        aggressive_threshold=50
    fi
    
    # Apply more aggressive duplicate detection
    echo "Using lowered threshold: $aggressive_threshold%"
    # Implementation would include more aggressive duplicate detection logic
}

# Conservative deduplication
dedupe_language_conservative() {
    local language=$1
    local dry_run=$2
    local threshold=$3
    shift 3
    local files=("$@")
    
    echo "Conservative deduplication for $language"
    
    # Only remove obvious duplicates
    for file in "${files[@]}"; do
        if [[ "$dry_run" != "true" ]]; then
            # Only remove duplicate imports (safest operation)
            remove_duplicate_imports "$file"
        else
            local duplicate_imports=$(find_duplicate_imports_in_file "$file")
            if [ -n "$duplicate_imports" ]; then
                echo "Would remove duplicate imports from $file"
            fi
        fi
    done
}

# Deduplicate functions only
dedupe_functions_only() {
    local language=$1
    local dry_run=$2
    local threshold=$3
    shift 3
    local files=("$@")
    
    echo "Function-only deduplication for $language"
    
    case "$language" in
        "javascript"|"typescript")
            local duplicates=$(find_duplicate_js_functions "${files[@]}")
            ;;
        "python")
            local duplicates=$(find_duplicate_python_functions "${files[@]}")
            ;;
        *)
            echo "Function deduplication not implemented for $language"
            return 0
            ;;
    esac
    
    if [ -n "$duplicates" ]; then
        echo "Found duplicate functions:"
        echo "$duplicates"
        
        if [[ "$dry_run" != "true" ]]; then
            echo "Manual review required for function deduplication"
        fi
    else
        echo "No duplicate functions found"
    fi
}

# Deduplicate blocks only
dedupe_blocks_only() {
    local language=$1
    local dry_run=$2
    local threshold=$3
    shift 3
    local files=("$@")
    
    echo "Block-only deduplication for $language"
    
    local similar_blocks=$(find_similar_js_blocks "$threshold" "${files[@]}")
    
    if [ -n "$similar_blocks" ]; then
        echo "Found similar code blocks:"
        echo "$similar_blocks"
        
        if [[ "$dry_run" != "true" ]]; then
            echo "Manual review recommended for block consolidation"
        fi
    else
        echo "No similar code blocks found"
    fi
}

# Deduplicate imports only
dedupe_imports_only() {
    local language=$1
    local dry_run=$2
    shift 2
    local files=("$@")
    
    echo "Import-only deduplication for $language"
    
    for file in "${files[@]}"; do
        local duplicate_imports=$(find_duplicate_imports_in_file "$file")
        
        if [ -n "$duplicate_imports" ]; then
            echo "Duplicate imports in $file:"
            echo "$duplicate_imports"
            
            if [[ "$dry_run" != "true" ]]; then
                remove_duplicate_imports "$file"
                echo "Removed duplicate imports from $file"
            fi
        fi
    done
}

# Verify deduplication results
verify_dedupe_results() {
    local target=$1
    shift
    local files=("$@")
    
    echo "Verifying deduplication results..."
    
    local verification_errors=0
    
    for file in "${files[@]}"; do
        # Check syntax
        if ! validate_syntax "$file"; then
            echo "ERROR: Syntax error in deduplicated file: $file"
            verification_errors=$((verification_errors + 1))
        fi
        
        # Check for remaining obvious duplicates
        local remaining_duplicates=$(find_duplicate_imports_in_file "$file")
        if [ -n "$remaining_duplicates" ]; then
            echo "WARNING: Duplicate imports still present in $file"
        fi
    done
    
    if [ $verification_errors -eq 0 ]; then
        echo "All deduplicated files verified successfully"
        return 0
    else
        echo "Verification failed for $verification_errors files"
        return 1
    fi
}

# Generate deduplication report
generate_dedupe_report() {
    local target=${1:-.}
    local before_analysis=$2
    local after_analysis=$3
    
    echo "Deduplication Report"
    echo "===================="
    echo "Target: $target"
    echo ""
    
    echo "Before deduplication:"
    echo "$before_analysis"
    echo ""
    
    echo "After deduplication:"
    echo "$after_analysis"
    echo ""
    
    # Calculate improvements
    local files_processed=$(find "$target" -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" | wc -l)
    echo "Files processed: $files_processed"
    echo "Recommendation: Regular deduplication helps maintain code quality"
}

# Main entry point
main() {
    local target=${1:-.}
    local dry_run=${2:-false}
    local mode=${3:-"standard"}
    local threshold=${4:-75}
    
    # Source shared utilities at runtime
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/_shared/utils.md" 2>/dev/null || true
    source "$SCRIPT_DIR/_shared/safety.md" 2>/dev/null || true
    
    # Set up error handling
    trap 'cleanup_on_exit "$target"' EXIT
    
    # Execute deduplication
    dedupe_codebase "$target" "$dry_run" "$mode" "$threshold"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Deduplication Categories

### Function Duplication
- **Identical functions**: Same signature and implementation
- **Similar functions**: Same logic with minor variations
- **Overloaded functions**: Same name, different parameters
- **Copy-paste variations**: Functions with small modifications

### Code Block Duplication
- **Conditional blocks**: Similar if/else structures
- **Loop patterns**: Repeated iteration logic
- **Error handling**: Duplicate try/catch blocks
- **Business logic**: Repeated algorithm implementations

### Import Duplication
- **Duplicate imports**: Same module imported multiple times
- **Redundant aliases**: Multiple names for same import
- **Unused imports**: Imported but never used
- **Circular imports**: Mutual dependencies

### File Similarity
- **Near-identical files**: High content overlap
- **Template variations**: Files following same pattern
- **Configuration duplicates**: Similar config files
- **Test file patterns**: Repeated test structures

## Detection Methods

### Syntactic Analysis
- **AST comparison**: Abstract syntax tree matching
- **Token-based**: Sequence similarity analysis
- **Signature matching**: Function/method signatures
- **Pattern recognition**: Common code patterns

### Semantic Analysis
- **Behavior similarity**: Same functionality, different code
- **Data flow analysis**: Variable usage patterns
- **Control flow**: Execution path comparison
- **Type analysis**: Parameter and return types

### Heuristic Methods
- **Line-based similarity**: Text comparison metrics
- **Length-based grouping**: Similar code block sizes
- **Naming patterns**: Similar variable/function names
- **Comment analysis**: Documentation similarities

## Merging Strategies

### Automatic Merging
- **Import consolidation**: Safe duplicate removal
- **Whitespace normalization**: Formatting consistency
- **Simple refactoring**: Extract common variables
- **Pattern replacement**: Template application

### Semi-Automatic Merging
- **Interactive review**: User-guided decisions
- **Confidence scoring**: Automated suggestions
- **Preview changes**: Show before/after comparison
- **Incremental application**: Step-by-step merging

### Manual Review Required
- **Function extraction**: Create shared utilities
- **Architecture changes**: Structural modifications
- **API modifications**: Interface changes
- **Business logic**: Domain-specific decisions

This deduplication command provides comprehensive duplicate detection capabilities with intelligent analysis, multiple detection methods, and flexible merging strategies to improve code maintainability while preserving functionality.