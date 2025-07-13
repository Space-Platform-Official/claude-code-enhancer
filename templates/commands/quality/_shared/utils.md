---
description: Shared utilities and functions for quality command suite
---

# Quality Command Shared Utilities

Common functions and utilities used across all quality commands for code formatting, cleanup, deduplication, and verification.

## File Detection Utilities

```bash
# Detect file type and language
detect_file_language() {
    local file=$1
    local extension="${file##*.}"
    
    case "$extension" in
        "js"|"jsx"|"mjs"|"cjs") echo "javascript" ;;
        "ts"|"tsx") echo "typescript" ;;
        "py"|"pyx"|"pyi") echo "python" ;;
        "rb"|"ruby") echo "ruby" ;;
        "go") echo "go" ;;
        "rs") echo "rust" ;;
        "java") echo "java" ;;
        "c"|"h") echo "c" ;;
        "cpp"|"hpp"|"cc"|"cxx") echo "cpp" ;;
        "cs") echo "csharp" ;;
        "php") echo "php" ;;
        "swift") echo "swift" ;;
        "kt"|"kts") echo "kotlin" ;;
        "scala"|"sc") echo "scala" ;;
        "css"|"scss"|"sass"|"less") echo "css" ;;
        "html"|"htm") echo "html" ;;
        "xml") echo "xml" ;;
        "json") echo "json" ;;
        "yaml"|"yml") echo "yaml" ;;
        "md"|"markdown") echo "markdown" ;;
        "sh"|"bash"|"zsh") echo "shell" ;;
        "sql") echo "sql" ;;
        "dockerfile") echo "dockerfile" ;;
        *) echo "unknown" ;;
    esac
}

# Check if file is binary
is_binary_file() {
    local file=$1
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    # Check file command first
    if command -v file >/dev/null 2>&1; then
        file "$file" | grep -q "text" && return 1
        return 0
    fi
    
    # Fallback: check for null bytes
    grep -q $'\0' "$file" 2>/dev/null
}

# Check if file is source code
is_source_file() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    [ "$language" != "unknown" ] && ! is_binary_file "$file"
}

# Get file size in bytes
get_file_size() {
    local file=$1
    if [ -f "$file" ]; then
        stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

# Find files by pattern with exclusions
find_files_filtered() {
    local directory=${1:-.}
    local pattern=${2:-"*"}
    local exclude_patterns=${3:-".git node_modules __pycache__ .pytest_cache target build dist .DS_Store"}
    
    local find_cmd="find '$directory' -type f -name '$pattern'"
    
    # Add exclusions
    for exclude in $exclude_patterns; do
        find_cmd="$find_cmd ! -path '*/$exclude/*'"
    done
    
    eval "$find_cmd" 2>/dev/null | sort
}
```

## Code Analysis Utilities

```bash
# Count lines of code (excluding comments and empty lines)
count_lines_of_code() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    case "$language" in
        "javascript"|"typescript"|"java"|"c"|"cpp"|"csharp"|"go"|"rust"|"swift"|"kotlin"|"scala")
            # C-style comments
            sed 's|//.*||g; s|/\*.*\*/||g' "$file" | sed '/^\s*$/d' | wc -l
            ;;
        "python"|"shell"|"yaml"|"ruby")
            # Hash comments
            sed 's|#.*||g' "$file" | sed '/^\s*$/d' | wc -l
            ;;
        "html"|"xml")
            # HTML comments
            sed 's|<!--.*-->||g' "$file" | sed '/^\s*$/d' | wc -l
            ;;
        "css")
            # CSS comments
            sed 's|/\*.*\*/||g' "$file" | sed '/^\s*$/d' | wc -l
            ;;
        *)
            # Fallback: just count non-empty lines
            sed '/^\s*$/d' "$file" | wc -l
            ;;
    esac
}

# Calculate code complexity (simple cyclomatic complexity)
calculate_complexity() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    case "$language" in
        "javascript"|"typescript")
            grep -c -E "(if|else|for|while|switch|case|catch|&&|\|\|)" "$file"
            ;;
        "python")
            grep -c -E "(if|elif|else|for|while|try|except|and|or|def|class)" "$file"
            ;;
        "java"|"c"|"cpp"|"csharp")
            grep -c -E "(if|else|for|while|switch|case|catch|&&|\|\||do)" "$file"
            ;;
        "go")
            grep -c -E "(if|else|for|switch|case|select|&&|\|\|)" "$file"
            ;;
        *)
            echo 0
            ;;
    esac
}

# Find duplicate code blocks
find_duplicate_blocks() {
    local file=$1
    local min_lines=${2:-5}
    
    # Simple implementation: hash consecutive lines
    awk -v min_lines="$min_lines" '
    {
        lines[NR] = $0
        for (i = NR - min_lines + 1; i <= NR; i++) {
            if (i > 0) {
                block = ""
                for (j = i; j < i + min_lines && j <= NR; j++) {
                    block = block lines[j] "\n"
                }
                if (length(block) > min_lines * 10) {
                    blocks[block] = blocks[block] ? blocks[block] "," i : i
                }
            }
        }
    }
    END {
        for (block in blocks) {
            if (split(blocks[block], positions, ",") > 1) {
                print "Duplicate block at lines: " blocks[block]
            }
        }
    }' "$file"
}
```

## Language-Specific Tools Detection

```bash
# Detect available formatters for a language
detect_formatters() {
    local language=$1
    local formatters=""
    
    case "$language" in
        "javascript"|"typescript")
            command -v prettier >/dev/null 2>&1 && formatters="$formatters prettier"
            command -v eslint >/dev/null 2>&1 && formatters="$formatters eslint"
            command -v biome >/dev/null 2>&1 && formatters="$formatters biome"
            ;;
        "python")
            command -v black >/dev/null 2>&1 && formatters="$formatters black"
            command -v autopep8 >/dev/null 2>&1 && formatters="$formatters autopep8"
            command -v yapf >/dev/null 2>&1 && formatters="$formatters yapf"
            command -v isort >/dev/null 2>&1 && formatters="$formatters isort"
            ;;
        "go")
            command -v gofmt >/dev/null 2>&1 && formatters="$formatters gofmt"
            command -v goimports >/dev/null 2>&1 && formatters="$formatters goimports"
            ;;
        "rust")
            command -v rustfmt >/dev/null 2>&1 && formatters="$formatters rustfmt"
            ;;
        "java")
            command -v google-java-format >/dev/null 2>&1 && formatters="$formatters google-java-format"
            ;;
        "ruby")
            command -v rubocop >/dev/null 2>&1 && formatters="$formatters rubocop"
            ;;
        "c"|"cpp")
            command -v clang-format >/dev/null 2>&1 && formatters="$formatters clang-format"
            ;;
        "csharp")
            command -v dotnet >/dev/null 2>&1 && formatters="$formatters dotnet-format"
            ;;
    esac
    
    echo "$formatters"
}

# Detect available linters for a language
detect_linters() {
    local language=$1
    local linters=""
    
    case "$language" in
        "javascript"|"typescript")
            command -v eslint >/dev/null 2>&1 && linters="$linters eslint"
            command -v jshint >/dev/null 2>&1 && linters="$linters jshint"
            command -v tsc >/dev/null 2>&1 && [ "$language" = "typescript" ] && linters="$linters tsc"
            ;;
        "python")
            command -v flake8 >/dev/null 2>&1 && linters="$linters flake8"
            command -v pylint >/dev/null 2>&1 && linters="$linters pylint"
            command -v mypy >/dev/null 2>&1 && linters="$linters mypy"
            command -v bandit >/dev/null 2>&1 && linters="$linters bandit"
            ;;
        "go")
            command -v golint >/dev/null 2>&1 && linters="$linters golint"
            command -v staticcheck >/dev/null 2>&1 && linters="$linters staticcheck"
            command -v gosec >/dev/null 2>&1 && linters="$linters gosec"
            ;;
        "rust")
            command -v clippy >/dev/null 2>&1 && linters="$linters clippy"
            ;;
        "ruby")
            command -v rubocop >/dev/null 2>&1 && linters="$linters rubocop"
            ;;
        "shell")
            command -v shellcheck >/dev/null 2>&1 && linters="$linters shellcheck"
            ;;
    esac
    
    echo "$linters"
}

# Check for project configuration files
find_config_files() {
    local directory=${1:-.}
    local language=$2
    
    case "$language" in
        "javascript"|"typescript")
            find "$directory" -maxdepth 2 -name ".eslintrc*" -o -name "eslint.config.*" -o -name ".prettierrc*" -o -name "prettier.config.*" -o -name "biome.json"
            ;;
        "python")
            find "$directory" -maxdepth 2 -name "pyproject.toml" -o -name "setup.cfg" -o -name ".flake8" -o -name "tox.ini" -o -name "mypy.ini"
            ;;
        "go")
            find "$directory" -maxdepth 2 -name "go.mod" -o -name ".golangci.yml" -o -name "golangci.yaml"
            ;;
        "rust")
            find "$directory" -maxdepth 2 -name "Cargo.toml" -o -name "rustfmt.toml" -o -name ".rustfmt.toml"
            ;;
        "ruby")
            find "$directory" -maxdepth 2 -name ".rubocop.yml" -o -name "Gemfile"
            ;;
        *)
            find "$directory" -maxdepth 2 -name ".editorconfig"
            ;;
    esac
}
```

## Import Analysis Utilities

```bash
# Extract imports from file
extract_imports() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    case "$language" in
        "javascript"|"typescript")
            grep -E "^import\s+.*from\s+['\"].*['\"]|^const\s+.*=\s+require\(|^import\s*\(" "$file"
            ;;
        "python")
            grep -E "^import\s+|^from\s+.*import\s+" "$file"
            ;;
        "go")
            awk '/^import\s*\(/{flag=1; next} /^\)/{flag=0} flag && /^\s*"/ {print}' "$file"
            grep -E '^import\s+".*"' "$file"
            ;;
        "java")
            grep -E "^import\s+.*;" "$file"
            ;;
        "rust")
            grep -E "^use\s+.*;" "$file"
            ;;
        "ruby")
            grep -E "^require\s+|^require_relative\s+|^load\s+" "$file"
            ;;
        "c"|"cpp")
            grep -E "^#include\s+[<\"].*[>\"]" "$file"
            ;;
        "csharp")
            grep -E "^using\s+.*;" "$file"
            ;;
    esac
}

# Find unused imports
find_unused_imports() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    case "$language" in
        "python")
            if command -v unimport >/dev/null 2>&1; then
                unimport --check "$file"
            elif command -v autoflake >/dev/null 2>&1; then
                autoflake --check-diff --remove-unused-variables "$file"
            fi
            ;;
        "javascript"|"typescript")
            if command -v eslint >/dev/null 2>&1; then
                eslint --no-eslintrc --config '{"rules":{"no-unused-vars":"error"}}' "$file" 2>/dev/null | grep "is defined but never used"
            fi
            ;;
        "go")
            go list -f '{{range .Imports}}{{.}} {{end}}' 2>/dev/null
            ;;
    esac
}

# Organize imports
organize_imports() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    case "$language" in
        "python")
            if command -v isort >/dev/null 2>&1; then
                isort "$file"
            fi
            ;;
        "go")
            if command -v goimports >/dev/null 2>&1; then
                goimports -w "$file"
            fi
            ;;
        "javascript"|"typescript")
            if command -v eslint >/dev/null 2>&1; then
                eslint --fix "$file" 2>/dev/null
            fi
            ;;
    esac
}
```

## Dead Code Detection Utilities

```bash
# Find dead functions
find_dead_functions() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    case "$language" in
        "javascript"|"typescript")
            # Extract function names
            local functions=$(grep -E "function\s+\w+|const\s+\w+\s*=|let\s+\w+\s*=|var\s+\w+\s*=" "$file" | \
                sed -E 's/.*function\s+([^(]+).*/\1/; s/.*const\s+([^=\s]+).*/\1/; s/.*let\s+([^=\s]+).*/\1/; s/.*var\s+([^=\s]+).*/\1/')
            
            # Check if functions are called
            for func in $functions; do
                if ! grep -q "$func(" "$file"; then
                    echo "Potentially dead function: $func"
                fi
            done
            ;;
        "python")
            # Extract function definitions
            local functions=$(grep -E "^def\s+\w+" "$file" | sed -E 's/^def\s+([^(]+).*/\1/')
            
            # Check if functions are called
            for func in $functions; do
                if ! grep -q "$func(" "$file"; then
                    echo "Potentially dead function: $func"
                fi
            done
            ;;
    esac
}

# Find unused variables
find_unused_variables() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    case "$language" in
        "python")
            if command -v vulture >/dev/null 2>&1; then
                vulture "$file"
            elif command -v pyflakes >/dev/null 2>&1; then
                pyflakes "$file" | grep "is assigned to but never used"
            fi
            ;;
        "javascript"|"typescript")
            if command -v eslint >/dev/null 2>&1; then
                eslint --no-eslintrc --config '{"rules":{"no-unused-vars":"error"}}' "$file" 2>/dev/null
            fi
            ;;
    esac
}

# Find TODO/FIXME comments
find_todo_comments() {
    local file=$1
    grep -n -E "(TODO|FIXME|XXX|HACK|BUG):" "$file"
}
```

## Progress and Reporting Utilities

```bash
# Calculate file metrics
calculate_file_metrics() {
    local file=$1
    
    local total_lines=$(wc -l < "$file")
    local code_lines=$(count_lines_of_code "$file")
    local complexity=$(calculate_complexity "$file")
    local file_size=$(get_file_size "$file")
    
    echo "total_lines:$total_lines code_lines:$code_lines complexity:$complexity size:$file_size"
}

# Generate progress bar
format_progress_bar() {
    local percentage=$1
    local width=${2:-20}
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))
    
    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done
    
    echo "[$bar] ${percentage}%"
}

# Format file size
format_file_size() {
    local size=$1
    
    if [ "$size" -lt 1024 ]; then
        echo "${size}B"
    elif [ "$size" -lt 1048576 ]; then
        echo "$((size / 1024))KB"
    elif [ "$size" -lt 1073741824 ]; then
        echo "$((size / 1048576))MB"
    else
        echo "$((size / 1073741824))GB"
    fi
}

# Generate summary report
generate_summary_report() {
    local directory=${1:-.}
    local total_files=0
    local total_lines=0
    local total_size=0
    
    while IFS= read -r file; do
        if is_source_file "$file"; then
            total_files=$((total_files + 1))
            total_lines=$((total_lines + $(wc -l < "$file")))
            total_size=$((total_size + $(get_file_size "$file")))
        fi
    done < <(find_files_filtered "$directory")
    
    echo "Summary Report:"
    echo "  Files: $total_files"
    echo "  Lines: $total_lines"
    echo "  Size: $(format_file_size $total_size)"
}
```

## Validation Utilities

```bash
# Validate file syntax
validate_syntax() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    case "$language" in
        "javascript")
            node -c "$file" 2>/dev/null
            ;;
        "python")
            python -m py_compile "$file" 2>/dev/null
            ;;
        "json")
            jq empty "$file" 2>/dev/null
            ;;
        "yaml")
            if command -v yamllint >/dev/null 2>&1; then
                yamllint "$file" >/dev/null 2>&1
            elif command -v yq >/dev/null 2>&1; then
                yq eval . "$file" >/dev/null 2>&1
            fi
            ;;
        "go")
            go fmt "$file" >/dev/null 2>&1
            ;;
        "rust")
            rustc --parse-only "$file" >/dev/null 2>&1
            ;;
        *)
            return 0  # Unknown language, assume valid
            ;;
    esac
}

# Check file encoding
check_file_encoding() {
    local file=$1
    
    if command -v file >/dev/null 2>&1; then
        local encoding=$(file -b --mime-encoding "$file")
        if [ "$encoding" != "utf-8" ] && [ "$encoding" != "us-ascii" ]; then
            echo "Non-UTF8 encoding detected: $encoding"
            return 1
        fi
    fi
    
    return 0
}

# Check line endings
check_line_endings() {
    local file=$1
    
    if grep -q $'\r' "$file"; then
        echo "Windows line endings detected"
        return 1
    fi
    
    return 0
}
```

## Backup and Recovery Utilities

```bash
# Create backup before modification
create_backup() {
    local file=$1
    local backup_dir=${2:-.backups}
    
    mkdir -p "$backup_dir"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/$(basename "$file").${timestamp}.bak"
    
    cp "$file" "$backup_file"
    echo "$backup_file"
}

# Restore from backup
restore_backup() {
    local backup_file=$1
    local original_file=$2
    
    if [ -f "$backup_file" ]; then
        cp "$backup_file" "$original_file"
        return 0
    fi
    
    return 1
}

# Clean old backups
clean_old_backups() {
    local backup_dir=${1:-.backups}
    local days=${2:-7}
    
    find "$backup_dir" -name "*.bak" -mtime +$days -delete 2>/dev/null
}
```

## Cross-Command Coordination Utilities

```bash
# Coordinate execution between multiple quality commands
coordinate_quality_commands() {
    local commands=("$@")
    local coordination_file="/tmp/quality-coordination-$$"
    
    echo "Coordinating quality commands: ${commands[*]}"
    
    # Initialize coordination state
    cat > "$coordination_file" <<EOF
{
    "session_id": "$$",
    "commands": [$(printf '"%s",' "${commands[@]}" | sed 's/,$//')],
    "status": "initializing",
    "shared_data": {},
    "locks": [],
    "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    
    export QUALITY_COORDINATION_FILE="$coordination_file"
    echo "$coordination_file"
}

# Share data between commands
share_command_data() {
    local key=$1
    local value=$2
    local coordination_file=${QUALITY_COORDINATION_FILE:-}
    
    if [ -z "$coordination_file" ] || [ ! -f "$coordination_file" ]; then
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq ".shared_data[\"$key\"] = \"$value\"" "$coordination_file" > "$temp_file"
        mv "$temp_file" "$coordination_file"
    fi
}

# Get shared data from other commands
get_shared_data() {
    local key=$1
    local coordination_file=${QUALITY_COORDINATION_FILE:-}
    
    if [ -z "$coordination_file" ] || [ ! -f "$coordination_file" ]; then
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        jq -r ".shared_data[\"$key\"] // empty" "$coordination_file"
    fi
}

# Lock resource for exclusive access
lock_resource() {
    local resource=$1
    local coordination_file=${QUALITY_COORDINATION_FILE:-}
    local timeout=${2:-30}
    
    if [ -z "$coordination_file" ] || [ ! -f "$coordination_file" ]; then
        return 1
    fi
    
    local attempts=0
    while [ $attempts -lt $timeout ]; do
        if command -v jq >/dev/null 2>&1; then
            local locks=$(jq -r ".locks[]? // empty" "$coordination_file" | grep "^$resource:" || true)
            if [ -z "$locks" ]; then
                # Resource available, lock it
                local temp_file=$(mktemp)
                jq ".locks += [\"$resource:$$:$(date +%s)\"]" "$coordination_file" > "$temp_file"
                mv "$temp_file" "$coordination_file"
                return 0
            fi
        fi
        
        sleep 1
        attempts=$((attempts + 1))
    done
    
    echo "Failed to lock resource: $resource (timeout after ${timeout}s)"
    return 1
}

# Unlock resource
unlock_resource() {
    local resource=$1
    local coordination_file=${QUALITY_COORDINATION_FILE:-}
    
    if [ -z "$coordination_file" ] || [ ! -f "$coordination_file" ]; then
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq ".locks = [.locks[]? | select(startswith(\"$resource:$$:\") | not)]" "$coordination_file" > "$temp_file"
        mv "$temp_file" "$coordination_file"
    fi
}

# Check if another command is processing a file
is_file_locked() {
    local file=$1
    local coordination_file=${QUALITY_COORDINATION_FILE:-}
    
    if [ -z "$coordination_file" ] || [ ! -f "$coordination_file" ]; then
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        local locks=$(jq -r ".locks[]? // empty" "$coordination_file" | grep ":$file:" || true)
        [ -n "$locks" ]
    fi
}

# Wait for file to be available
wait_for_file_unlock() {
    local file=$1
    local timeout=${2:-60}
    local coordination_file=${QUALITY_COORDINATION_FILE:-}
    
    if [ -z "$coordination_file" ] || [ ! -f "$coordination_file" ]; then
        return 0  # No coordination, assume available
    fi
    
    local attempts=0
    while [ $attempts -lt $timeout ]; do
        if ! is_file_locked "$file"; then
            return 0
        fi
        
        echo "Waiting for file to be unlocked: $file"
        sleep 1
        attempts=$((attempts + 1))
    done
    
    echo "Timeout waiting for file unlock: $file"
    return 1
}

# Cleanup coordination resources
cleanup_coordination() {
    local coordination_file=${QUALITY_COORDINATION_FILE:-}
    
    if [ -n "$coordination_file" ] && [ -f "$coordination_file" ]; then
        # Remove our locks
        if command -v jq >/dev/null 2>&1; then
            local temp_file=$(mktemp)
            jq ".locks = [.locks[]? | select(contains(\":$$:\") | not)]" "$coordination_file" > "$temp_file"
            mv "$temp_file" "$coordination_file"
        fi
        
        # Clean up if no locks remain
        if command -v jq >/dev/null 2>&1; then
            local remaining_locks=$(jq -r ".locks | length" "$coordination_file" 2>/dev/null || echo "0")
            if [ "$remaining_locks" = "0" ]; then
                rm -f "$coordination_file"
            fi
        fi
    fi
}
```

## Enhanced Error Handling Utilities

```bash
# Enhanced error handling with context and recovery suggestions
handle_quality_error() {
    local error_code=$1
    local error_message=$2
    local file_path=${3:-""}
    local operation=${4:-"unknown"}
    local context=${5:-""}
    
    echo "ERROR: Quality operation failed"
    echo "  Code: $error_code"
    echo "  Message: $error_message"
    echo "  File: $file_path"
    echo "  Operation: $operation"
    echo "  Context: $context"
    
    # Generate recovery suggestions
    suggest_error_recovery "$error_code" "$operation" "$file_path"
    
    # Log detailed error information
    log_quality_error "$error_code" "$error_message" "$file_path" "$operation" "$context"
    
    return "$error_code"
}

# Suggest recovery actions based on error type
suggest_error_recovery() {
    local error_code=$1
    local operation=$2
    local file_path=$3
    
    echo ""
    echo "Recovery Suggestions:"
    
    case "$error_code" in
        1)  # General error
            echo "  - Check file permissions and accessibility"
            echo "  - Verify file is not corrupted or binary"
            echo "  - Try running with --verbose for more details"
            ;;
        2)  # Syntax error
            echo "  - Fix syntax errors in the file manually"
            echo "  - Run with --dry-run to see what changes would be made"
            echo "  - Use language-specific syntax checkers"
            ;;
        3)  # Permission error
            echo "  - Ensure write permissions to target files/directories"
            echo "  - Check if files are read-only or locked by other processes"
            echo "  - Run with appropriate user permissions"
            ;;
        4)  # Tool missing
            echo "  - Install required formatting/linting tools"
            echo "  - Check tool availability with 'which <tool-name>'"
            echo "  - Update PATH environment variable if needed"
            ;;
        5)  # Configuration error
            echo "  - Check configuration files for syntax errors"
            echo "  - Verify tool-specific configuration is valid"
            echo "  - Try with default configuration"
            ;;
        *)
            echo "  - Check logs for more detailed error information"
            echo "  - Try running operation again with fresh environment"
            echo "  - Consider creating a backup and reverting changes"
            ;;
    esac
    
    if [ -n "$file_path" ] && [ -f "$file_path" ]; then
        echo "  - For file '$file_path':"
        echo "    - Check file encoding and line endings"
        echo "    - Verify file is valid $(detect_file_language "$file_path") code"
        echo "    - Consider excluding this file temporarily"
    fi
}

# Enhanced error logging with structured data
log_quality_error() {
    local error_code=$1
    local error_message=$2
    local file_path=$3
    local operation=$4
    local context=$5
    
    local log_dir="${TMPDIR:-/tmp}/quality-logs"
    mkdir -p "$log_dir"
    
    local log_file="$log_dir/quality-error-$(date +%Y%m%d).log"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Structured log entry
    cat >> "$log_file" <<EOF
[$timestamp] ERROR
  Code: $error_code
  Message: $error_message
  File: $file_path
  Operation: $operation
  Context: $context
  PID: $$
  User: $(whoami)
  PWD: $(pwd)
  Environment: $(env | grep -E '^(QUALITY|PATH)=' | head -5)
---
EOF
    
    # Also create JSON log for machine processing
    if command -v jq >/dev/null 2>&1; then
        local json_log="$log_dir/quality-error-$(date +%Y%m%d).json"
        local json_entry=$(cat <<EOF
{
  "timestamp": "$timestamp",
  "level": "ERROR",
  "error_code": $error_code,
  "message": "$error_message",
  "file_path": "$file_path",
  "operation": "$operation",
  "context": "$context",
  "process_id": $$,
  "user": "$(whoami)",
  "working_directory": "$(pwd)"
}
EOF
)
        echo "$json_entry" >> "$json_log"
    fi
}

# Retry mechanism with exponential backoff
retry_with_backoff() {
    local max_attempts=${1:-3}
    local base_delay=${2:-1}
    local max_delay=${3:-30}
    shift 3
    local command=("$@")
    
    local attempt=1
    local delay=$base_delay
    
    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt/$max_attempts: ${command[*]}"
        
        if "${command[@]}"; then
            echo "Command succeeded on attempt $attempt"
            return 0
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            echo "Command failed after $max_attempts attempts"
            return 1
        fi
        
        echo "Command failed, retrying in ${delay}s..."
        sleep "$delay"
        
        # Exponential backoff with jitter
        delay=$((delay * 2))
        if [ $delay -gt $max_delay ]; then
            delay=$max_delay
        fi
        
        # Add jitter (±20% of delay)
        local jitter=$((delay / 5))
        local random_jitter=$((RANDOM % (jitter * 2 + 1) - jitter))
        delay=$((delay + random_jitter))
        
        attempt=$((attempt + 1))
    done
}

# Circuit breaker pattern for failing operations
circuit_breaker() {
    local operation_id=$1
    local failure_threshold=${2:-5}
    local timeout_seconds=${3:-300}  # 5 minutes
    shift 3
    local command=("$@")
    
    local state_file="/tmp/circuit-breaker-$operation_id"
    local current_time=$(date +%s)
    
    # Check circuit breaker state
    if [ -f "$state_file" ]; then
        local state_data=$(cat "$state_file")
        local failures=$(echo "$state_data" | cut -d: -f1)
        local last_failure=$(echo "$state_data" | cut -d: -f2)
        local state=$(echo "$state_data" | cut -d: -f3)
        
        if [ "$state" = "OPEN" ]; then
            local time_since_failure=$((current_time - last_failure))
            if [ $time_since_failure -lt $timeout_seconds ]; then
                echo "Circuit breaker OPEN for operation: $operation_id"
                echo "Retry in $((timeout_seconds - time_since_failure)) seconds"
                return 2
            else
                echo "Circuit breaker transitioning to HALF-OPEN"
                echo "0:$current_time:HALF-OPEN" > "$state_file"
            fi
        fi
    else
        echo "0:0:CLOSED" > "$state_file"
    fi
    
    # Execute command
    if "${command[@]}"; then
        echo "0:0:CLOSED" > "$state_file"
        return 0
    else
        # Record failure
        local state_data=$(cat "$state_file" 2>/dev/null || echo "0:0:CLOSED")
        local failures=$(echo "$state_data" | cut -d: -f1)
        failures=$((failures + 1))
        
        if [ $failures -ge $failure_threshold ]; then
            echo "$failures:$current_time:OPEN" > "$state_file"
            echo "Circuit breaker OPEN due to $failures failures"
        else
            echo "$failures:$current_time:CLOSED" > "$state_file"
        fi
        
        return 1
    fi
}
```

## Enhanced Progress Tracking and Reporting

```bash
# Advanced progress tracking with ETA and throughput
track_operation_progress() {
    local operation_id=$1
    local total_items=$2
    local current_item=$3
    local start_time=${4:-$(date +%s)}
    
    local current_time=$(date +%s)
    local elapsed=$((current_time - start_time))
    local percentage=$((current_item * 100 / total_items))
    
    # Calculate ETA
    local eta="unknown"
    local throughput="0.0"
    if [ $elapsed -gt 0 ] && [ $current_item -gt 0 ]; then
        local rate=$(echo "scale=2; $current_item / $elapsed" | bc 2>/dev/null || echo "0")
        throughput="$rate"
        
        if [ "$(echo "$rate > 0" | bc 2>/dev/null || echo "0")" = "1" ]; then
            local remaining_items=$((total_items - current_item))
            local eta_seconds=$(echo "scale=0; $remaining_items / $rate" | bc 2>/dev/null || echo "0")
            eta=$(format_duration "$eta_seconds")
        fi
    fi
    
    # Update progress file
    local progress_file="/tmp/quality-progress-$operation_id"
    cat > "$progress_file" <<EOF
{
    "operation_id": "$operation_id",
    "total_items": $total_items,
    "current_item": $current_item,
    "percentage": $percentage,
    "elapsed_seconds": $elapsed,
    "eta": "$eta",
    "throughput": "$throughput",
    "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    
    # Display progress
    local progress_bar=$(format_progress_bar "$percentage" 30)
    echo -ne "\r[$operation_id] $progress_bar $percentage% ($current_item/$total_items) ETA: $eta"
    
    if [ $current_item -eq $total_items ]; then
        echo ""  # New line when complete
        rm -f "$progress_file"
    fi
}

# Real-time operation monitoring
monitor_operation() {
    local operation_id=$1
    local monitor_interval=${2:-2}
    
    echo "Monitoring operation: $operation_id"
    
    local progress_file="/tmp/quality-progress-$operation_id"
    while [ -f "$progress_file" ]; do
        if command -v jq >/dev/null 2>&1; then
            local data=$(cat "$progress_file" 2>/dev/null)
            if [ -n "$data" ]; then
                local percentage=$(echo "$data" | jq -r '.percentage // 0')
                local current=$(echo "$data" | jq -r '.current_item // 0')
                local total=$(echo "$data" | jq -r '.total_items // 0')
                local eta=$(echo "$data" | jq -r '.eta // "unknown"')
                local throughput=$(echo "$data" | jq -r '.throughput // "0.0"')
                
                echo "Progress: $percentage% ($current/$total) | ETA: $eta | Rate: $throughput items/s"
            fi
        fi
        
        sleep "$monitor_interval"
    done
    
    echo "Operation $operation_id completed"
}

# Format duration in human-readable form
format_duration() {
    local seconds=$1
    
    if [ "$seconds" -lt 60 ]; then
        echo "${seconds}s"
    elif [ "$seconds" -lt 3600 ]; then
        local minutes=$((seconds / 60))
        local secs=$((seconds % 60))
        echo "${minutes}m ${secs}s"
    else
        local hours=$((seconds / 3600))
        local minutes=$(((seconds % 3600) / 60))
        local secs=$((seconds % 60))
        echo "${hours}h ${minutes}m ${secs}s"
    fi
}

# Comprehensive operation statistics
generate_operation_stats() {
    local operation_id=$1
    local start_time=$2
    local end_time=${3:-$(date +%s)}
    local files_processed=${4:-0}
    local files_modified=${5:-0}
    local errors_count=${6:-0}
    
    local total_duration=$((end_time - start_time))
    local throughput="0.0"
    
    if [ $total_duration -gt 0 ] && [ $files_processed -gt 0 ]; then
        throughput=$(echo "scale=2; $files_processed / $total_duration" | bc 2>/dev/null || echo "0.0")
    fi
    
    cat <<EOF
Operation Statistics: $operation_id
=====================================
Duration: $(format_duration $total_duration)
Files Processed: $files_processed
Files Modified: $files_modified
Errors: $errors_count
Success Rate: $(echo "scale=1; ($files_processed - $errors_count) * 100 / $files_processed" | bc 2>/dev/null || echo "0.0")%
Throughput: $throughput files/second
Average Time per File: $(echo "scale=3; $total_duration / $files_processed" | bc 2>/dev/null || echo "0.000")s
EOF
}

# Quality metrics dashboard
display_quality_metrics() {
    local target_dir=${1:-.}
    
    echo "Quality Metrics Dashboard"
    echo "========================"
    echo "Target: $target_dir"
    echo "Generated: $(date)"
    echo ""
    
    # File statistics
    local total_files=$(find_files_filtered "$target_dir" "*" | wc -l)
    local source_files=$(find_files_filtered "$target_dir" "*" | while read -r f; do is_source_file "$f" && echo "$f"; done | wc -l)
    local total_size=$(find_files_filtered "$target_dir" "*" | while read -r f; do get_file_size "$f"; done | awk '{sum+=$1} END {print sum+0}')
    
    echo "File Overview:"
    echo "  Total files: $total_files"
    echo "  Source files: $source_files"
    echo "  Total size: $(format_file_size $total_size)"
    echo ""
    
    # Language breakdown
    echo "Language Breakdown:"
    declare -A lang_counts
    declare -A lang_sizes
    
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file"; then
            local lang=$(detect_file_language "$file")
            local size=$(get_file_size "$file")
            echo "$lang:$size"
        fi
    done | sort | uniq -c | while read -r count lang_size; do
        local lang=${lang_size%:*}
        local size=${lang_size#*:}
        echo "  $lang: $count files ($(format_file_size $size))"
    done
    
    echo ""
    
    # Quality indicators
    echo "Quality Indicators:"
    local syntax_errors=0
    local encoding_issues=0
    local large_files=0
    
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file"; then
            validate_syntax "$file" || syntax_errors=$((syntax_errors + 1))
            check_file_encoding "$file" || encoding_issues=$((encoding_issues + 1))
            [ "$(get_file_size "$file")" -gt 51200 ] && large_files=$((large_files + 1))  # >50KB
        fi
    done
    
    echo "  Syntax errors: $syntax_errors"
    echo "  Encoding issues: $encoding_issues"
    echo "  Large files (>50KB): $large_files"
}
```

## Configuration Management Utilities

```bash
# Load and validate quality configuration
load_quality_config() {
    local target_dir=${1:-.}
    local config_file="$target_dir/.quality-config.json"
    local default_config=$(get_default_quality_config)
    
    if [ -f "$config_file" ]; then
        echo "Loading configuration from: $config_file"
        
        # Validate configuration file
        if command -v jq >/dev/null 2>&1; then
            if ! jq empty "$config_file" 2>/dev/null; then
                echo "WARNING: Invalid JSON in configuration file, using defaults"
                echo "$default_config"
                return 1
            fi
            
            # Merge with defaults
            echo "$default_config" | jq ". + $(cat "$config_file")"
        else
            cat "$config_file"
        fi
    else
        echo "No configuration file found, using defaults"
        echo "$default_config"
    fi
}

# Get default quality configuration
get_default_quality_config() {
    cat <<'EOF'
{
    "version": "1.0",
    "default_workflow": "standard",
    "parallel_execution": true,
    "create_snapshots": true,
    "auto_cleanup": true,
    "max_file_size": 10485760,
    "excluded_patterns": [".git", "node_modules", "__pycache__", "target", "build", "dist"],
    "formatters": {
        "javascript": ["prettier", "eslint"],
        "typescript": ["prettier", "eslint"],
        "python": ["black", "isort"],
        "go": ["gofmt", "goimports"],
        "rust": ["rustfmt"],
        "java": ["google-java-format"],
        "ruby": ["rubocop"],
        "c": ["clang-format"],
        "cpp": ["clang-format"]
    },
    "quality_thresholds": {
        "similarity_threshold": 75,
        "complexity_limit": 10,
        "max_file_lines": 500,
        "max_function_lines": 50
    },
    "safety": {
        "require_git": false,
        "require_clean_git": false,
        "backup_before_operations": true,
        "verify_after_operations": true
    }
}
EOF
}

# Validate configuration values
validate_quality_config() {
    local config_json=$1
    local errors=()
    
    echo "Validating quality configuration..."
    
    if command -v jq >/dev/null 2>&1; then
        # Check required fields
        local required_fields=("version" "formatters" "quality_thresholds")
        for field in "${required_fields[@]}"; do
            if ! echo "$config_json" | jq -e ".$field" >/dev/null 2>&1; then
                errors+=("Missing required field: $field")
            fi
        done
        
        # Validate threshold values
        local similarity=$(echo "$config_json" | jq -r '.quality_thresholds.similarity_threshold // 75')
        if [ "$similarity" -lt 0 ] || [ "$similarity" -gt 100 ]; then
            errors+=("similarity_threshold must be between 0 and 100")
        fi
        
        local complexity=$(echo "$config_json" | jq -r '.quality_thresholds.complexity_limit // 10')
        if [ "$complexity" -lt 1 ]; then
            errors+=("complexity_limit must be positive")
        fi
        
        # Validate file size
        local max_size=$(echo "$config_json" | jq -r '.max_file_size // 10485760')
        if [ "$max_size" -lt 1024 ]; then
            errors+=("max_file_size must be at least 1024 bytes")
        fi
    fi
    
    if [ ${#errors[@]} -gt 0 ]; then
        echo "Configuration validation errors:"
        for error in "${errors[@]}"; do
            echo "  - $error"
        done
        return 1
    fi
    
    echo "Configuration validation passed"
    return 0
}

# Save quality configuration
save_quality_config() {
    local target_dir=${1:-.}
    local config_json=$2
    local config_file="$target_dir/.quality-config.json"
    
    if validate_quality_config "$config_json"; then
        echo "Saving configuration to: $config_file"
        echo "$config_json" | jq '.' > "$config_file"
        echo "Configuration saved successfully"
        return 0
    else
        echo "Configuration validation failed, not saving"
        return 1
    fi
}
```

These utilities provide a comprehensive foundation for the quality command suite, ensuring consistency and reusability across all quality operations including formatting, cleanup, deduplication, and verification. The enhancements include cross-command coordination, advanced error handling with recovery suggestions, enhanced progress tracking with ETA calculations, and robust configuration management.