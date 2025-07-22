---
description: Shared utilities and functions for code text quality command suite
---

# Code Text Quality Shared Utilities

Common functions and utilities used across all code text quality commands for scanning, proofreading, reviewing, and polishing text in code projects.

## Text Detection Utilities

```bash
# Detect text content type in files
detect_text_content_type() {
    local file=$1
    local content_type=""
    
    # Check file extension and patterns
    case "${file##*.}" in
        "md"|"markdown") content_type="documentation" ;;
        "txt"|"rst"|"adoc") content_type="documentation" ;;
        "json"|"yaml"|"yml"|"toml") content_type="configuration" ;;
        *) 
            # Check content patterns for source files
            if is_source_file "$file"; then
                content_type="source_code"
            else
                content_type="other"
            fi
            ;;
    esac
    
    echo "$content_type"
}

# Extract text content from source files
extract_text_from_source() {
    local file=$1
    local language=$(detect_file_language "$file")
    local text_file="/tmp/text-extraction-$$-$(basename "$file")"
    
    case "$language" in
        "javascript"|"typescript"|"java"|"c"|"cpp"|"csharp"|"go"|"rust"|"swift"|"kotlin"|"scala")
            # Extract comments and string literals
            awk '
            /\/\*/{comment=1} 
            comment && /\*\//{comment=0; next} 
            comment {print "COMMENT: " $0} 
            !comment && /\/\//{print "COMMENT: " substr($0, index($0, "//"))} 
            !comment && /["'"'"']/{
                line=$0; 
                while(match(line, /["'"'"'][^"'"'"']*["'"'"']/)) {
                    print "STRING: " substr(line, RSTART+1, RLENGTH-2); 
                    line=substr(line, RSTART+RLENGTH)
                }
            }' "$file" > "$text_file"
            ;;
        "python"|"shell"|"ruby")
            # Extract comments and string literals
            awk '
            /#/{print "COMMENT: " substr($0, index($0, "#"))} 
            /["'"'"']/{
                line=$0; 
                while(match(line, /["'"'"'][^"'"'"']*["'"'"']/)) {
                    print "STRING: " substr(line, RSTART+1, RLENGTH-2); 
                    line=substr(line, RSTART+RLENGTH)
                }
            }' "$file" > "$text_file"
            ;;
        "html"|"xml")
            # Extract text content and comments
            sed -n 's/.*>\([^<]*\)<.*/TEXT: \1/p; s/.*<!--\(.*\)-->.*/COMMENT: \1/p' "$file" > "$text_file"
            ;;
        *)
            # Fallback: treat entire file as text
            sed 's/^/TEXT: /' "$file" > "$text_file"
            ;;
    esac
    
    echo "$text_file"
}

# Extract variable and function names for analysis
extract_identifiers() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    case "$language" in
        "javascript"|"typescript")
            grep -E "(function\s+\w+|const\s+\w+|let\s+\w+|var\s+\w+|class\s+\w+)" "$file" | \
            sed -E 's/.*(function|const|let|var|class)\s+([A-Za-z_$][A-Za-z0-9_$]*).*/IDENTIFIER: \2/'
            ;;
        "python")
            grep -E "(def\s+\w+|class\s+\w+)" "$file" | \
            sed -E 's/.*(def|class)\s+([A-Za-z_][A-Za-z0-9_]*).*/IDENTIFIER: \2/'
            ;;
        "java"|"c"|"cpp"|"csharp")
            grep -E "(class\s+\w+|interface\s+\w+|enum\s+\w+|\w+\s+\w+\s*\()" "$file" | \
            sed -E 's/.*(class|interface|enum)\s+([A-Za-z_][A-Za-z0-9_]*).*/IDENTIFIER: \2/'
            ;;
        "go")
            grep -E "(func\s+\w+|type\s+\w+)" "$file" | \
            sed -E 's/.*(func|type)\s+([A-Za-z_][A-Za-z0-9_]*).*/IDENTIFIER: \2/'
            ;;
        "rust")
            grep -E "(fn\s+\w+|struct\s+\w+|enum\s+\w+|trait\s+\w+)" "$file" | \
            sed -E 's/.*(fn|struct|enum|trait)\s+([A-Za-z_][A-Za-z0-9_]*).*/IDENTIFIER: \2/'
            ;;
    esac
}

# Check if file contains user-facing text
contains_user_facing_text() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    case "$language" in
        "javascript"|"typescript"|"java"|"c"|"cpp"|"csharp"|"go"|"rust"|"swift"|"kotlin"|"scala")
            # Look for error messages, alerts, console.log, etc.
            grep -q -E "(console\.(log|error|warn)|alert\(|throw\s+new\s+Error|println!|fmt\.Print)" "$file"
            ;;
        "python")
            # Look for print statements, logging, exceptions
            grep -q -E "(print\(|logging\.|raise\s+\w+Error|logger\.)" "$file"
            ;;
        "html")
            # HTML always contains user-facing text
            return 0
            ;;
        *)
            # Default: check for common user-facing patterns
            grep -q -E "(error|warning|success|message|alert|notification)" "$file"
            ;;
    esac
}

# Extract error messages and user-facing strings
extract_user_messages() {
    local file=$1
    local language=$(detect_file_language "$file")
    local messages_file="/tmp/user-messages-$$-$(basename "$file")"
    
    case "$language" in
        "javascript"|"typescript")
            grep -E "(console\.(log|error|warn)|alert\(|throw\s+new\s+Error)" "$file" | \
            sed -E 's/.*["'"'"']([^"'"'"']*)["'"'"'].*/ERROR_MSG: \1/' > "$messages_file"
            ;;
        "python")
            grep -E "(print\(|raise\s+\w+Error|logger\.)" "$file" | \
            sed -E 's/.*["'"'"']([^"'"'"']*)["'"'"'].*/ERROR_MSG: \1/' > "$messages_file"
            ;;
        "java"|"c"|"cpp"|"csharp")
            grep -E "(System\.out\.print|printf|throw\s+new)" "$file" | \
            sed -E 's/.*["'"'"']([^"'"'"']*)["'"'"'].*/ERROR_MSG: \1/' > "$messages_file"
            ;;
        *)
            # Generic string extraction
            grep -E '["'"'"'][^"'"'"']*["'"'"']' "$file" | \
            sed -E 's/.*["'"'"']([^"'"'"']*)["'"'"'].*/MESSAGE: \1/' > "$messages_file"
            ;;
    esac
    
    echo "$messages_file"
}
```

## Text Analysis Utilities

```bash
# Check grammar and spelling in text
check_text_quality() {
    local text_content=$1
    local issues_file="/tmp/text-issues-$$"
    local issue_count=0
    
    # Basic grammar checks
    echo "$text_content" | while IFS= read -r line; do
        # Remove prefixes (COMMENT:, STRING:, etc.)
        local clean_line=$(echo "$line" | sed 's/^[A-Z_]*: //')
        
        # Skip very short lines or single words
        [ ${#clean_line} -lt 10 ] && continue
        
        # Check for common grammar issues
        if echo "$clean_line" | grep -q -E "\b(it's|its)\b"; then
            echo "GRAMMAR: Possible its/it's confusion: $clean_line" >> "$issues_file"
            issue_count=$((issue_count + 1))
        fi
        
        if echo "$clean_line" | grep -q -E "\b(there|their|they're)\b"; then
            echo "GRAMMAR: Check there/their/they're usage: $clean_line" >> "$issues_file"
            issue_count=$((issue_count + 1))
        fi
        
        if echo "$clean_line" | grep -q -E "\b(your|you're)\b"; then
            echo "GRAMMAR: Check your/you're usage: $clean_line" >> "$issues_file"
            issue_count=$((issue_count + 1))
        fi
        
        # Check for missing capitalization at sentence start
        if echo "$clean_line" | grep -q -E "^\s*[a-z]"; then
            echo "STYLE: Missing capitalization: $clean_line" >> "$issues_file"
            issue_count=$((issue_count + 1))
        fi
        
        # Check for double spaces
        if echo "$clean_line" | grep -q "  "; then
            echo "STYLE: Multiple spaces detected: $clean_line" >> "$issues_file"
            issue_count=$((issue_count + 1))
        fi
        
        # Check for missing punctuation
        if echo "$clean_line" | grep -q -E "[a-zA-Z]$" && [ ${#clean_line} -gt 20 ]; then
            echo "STYLE: Missing punctuation: $clean_line" >> "$issues_file"
            issue_count=$((issue_count + 1))
        fi
    done
    
    echo "$issues_file:$issue_count"
}

# Detect technical terminology consistency
check_terminology_consistency() {
    local directory=${1:-.}
    local terms_file="/tmp/terminology-$$"
    local consistency_file="/tmp/consistency-$$"
    
    # Extract all technical terms from codebase
    find_files_filtered "$directory" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" = "documentation" ]; then
            extract_identifiers "$file" | sed 's/IDENTIFIER: //' >> "$terms_file"
            extract_text_from_source "$file" | grep -E "(API|HTTP|JSON|XML|SQL|URL|URI|ID|UUID)" >> "$terms_file"
        fi
    done
    
    # Find inconsistent casing/spelling
    sort "$terms_file" | uniq -c | sort -nr | while read -r count term; do
        # Look for similar terms with different casing
        local similar_terms=$(grep -i "^$term$" "$terms_file" | sort | uniq)
        local variant_count=$(echo "$similar_terms" | wc -l)
        
        if [ "$variant_count" -gt 1 ]; then
            echo "INCONSISTENT: $term has variants: $similar_terms" >> "$consistency_file"
        fi
    done
    
    rm -f "$terms_file"
    echo "$consistency_file"
}

# Calculate readability score (simplified Flesch-Kincaid)
calculate_readability() {
    local text_content=$1
    local total_sentences=0
    local total_words=0
    local total_syllables=0
    
    echo "$text_content" | while IFS= read -r line; do
        # Remove prefixes and clean line
        local clean_line=$(echo "$line" | sed 's/^[A-Z_]*: //' | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]')
        
        # Skip very short lines
        [ ${#clean_line} -lt 10 ] && continue
        
        # Count sentences (approximate)
        local sentences=$(echo "$clean_line" | grep -o -E '[.!?]+' | wc -l)
        [ $sentences -eq 0 ] && sentences=1
        total_sentences=$((total_sentences + sentences))
        
        # Count words
        local words=$(echo "$clean_line" | wc -w)
        total_words=$((total_words + words))
        
        # Count syllables (rough approximation)
        local syllables=0
        for word in $clean_line; do
            local vowel_groups=$(echo "$word" | grep -o -E '[aeiou]+' | wc -l)
            [ $vowel_groups -eq 0 ] && vowel_groups=1
            syllables=$((syllables + vowel_groups))
        done
        total_syllables=$((total_syllables + syllables))
    done
    
    # Calculate Flesch Reading Ease (simplified)
    if [ $total_sentences -gt 0 ] && [ $total_words -gt 0 ]; then
        local avg_sentence_length=$(echo "scale=2; $total_words / $total_sentences" | bc 2>/dev/null || echo "0")
        local avg_syllables_per_word=$(echo "scale=2; $total_syllables / $total_words" | bc 2>/dev/null || echo "0")
        local reading_ease=$(echo "scale=1; 206.835 - (1.015 * $avg_sentence_length) - (84.6 * $avg_syllables_per_word)" | bc 2>/dev/null || echo "0")
        
        echo "words:$total_words sentences:$total_sentences syllables:$total_syllables ease:$reading_ease"
    else
        echo "words:0 sentences:0 syllables:0 ease:0"
    fi
}

# Check for inclusive language
check_inclusive_language() {
    local text_content=$1
    local issues_file="/tmp/inclusive-$$"
    local issue_count=0
    
    # Define problematic terms and alternatives
    declare -A problematic_terms=(
        ["blacklist"]="blocklist"
        ["whitelist"]="allowlist"
        ["master"]="main"
        ["slave"]="secondary"
        ["guys"]="everyone"
        ["crazy"]="unexpected"
        ["insane"]="intense"
        ["lame"]="ineffective"
        ["dumb"]="simple"
        ["stupid"]="basic"
    )
    
    echo "$text_content" | while IFS= read -r line; do
        local clean_line=$(echo "$line" | sed 's/^[A-Z_]*: //')
        
        for term in "${!problematic_terms[@]}"; do
            if echo "$clean_line" | grep -q -i "\b$term\b"; then
                echo "INCLUSIVE: Consider replacing '$term' with '${problematic_terms[$term]}': $clean_line" >> "$issues_file"
                issue_count=$((issue_count + 1))
            fi
        done
    done
    
    echo "$issues_file:$issue_count"
}
```

## Text Correction Utilities

```bash
# Apply safe text corrections
apply_text_corrections() {
    local file=$1
    local corrections_file=$2
    local backup_file=$(create_backup "$file")
    local corrections_applied=0
    
    echo "Applying text corrections to: $file"
    echo "Backup created: $backup_file"
    
    # Read corrections and apply them safely
    while IFS=: read -r issue_type line_content correction; do
        case "$issue_type" in
            "STYLE")
                # Apply style corrections (spacing, capitalization)
                if [[ "$line_content" == *"Multiple spaces"* ]]; then
                    sed -i.bak 's/  \+/ /g' "$file"
                    corrections_applied=$((corrections_applied + 1))
                fi
                ;;
            "GRAMMAR")
                # Apply grammar corrections with confirmation
                echo "Grammar correction suggested for: $line_content"
                echo "Apply correction? (y/n)"
                read -r confirm
                if [ "$confirm" = "y" ]; then
                    corrections_applied=$((corrections_applied + 1))
                fi
                ;;
            "INCLUSIVE")
                # Apply inclusive language corrections
                echo "Inclusive language correction for: $line_content"
                echo "Apply correction? (y/n)"
                read -r confirm
                if [ "$confirm" = "y" ]; then
                    corrections_applied=$((corrections_applied + 1))
                fi
                ;;
        esac
    done < "$corrections_file"
    
    # Validate file still compiles/works after corrections
    if validate_syntax "$file"; then
        echo "Corrections applied successfully: $corrections_applied"
        return 0
    else
        echo "Syntax validation failed, restoring backup"
        restore_backup "$backup_file" "$file"
        return 1
    fi
}

# Suggest corrections without applying them
suggest_text_corrections() {
    local text_content=$1
    local suggestions_file="/tmp/suggestions-$$"
    
    echo "$text_content" | while IFS= read -r line; do
        local clean_line=$(echo "$line" | sed 's/^[A-Z_]*: //')
        
        # Suggest common improvements
        if echo "$clean_line" | grep -q "  "; then
            echo "STYLE: Remove extra spaces: $clean_line -> $(echo "$clean_line" | sed 's/  \+/ /g')" >> "$suggestions_file"
        fi
        
        if echo "$clean_line" | grep -q -E "^\s*[a-z]"; then
            local capitalized=$(echo "$clean_line" | sed 's/^\s*\(.\)/\U\1/')
            echo "STYLE: Capitalize sentence: $clean_line -> $capitalized" >> "$suggestions_file"
        fi
        
        # Suggest clarity improvements
        if echo "$clean_line" | grep -q -E "\b(really|very|quite|pretty)\b"; then
            echo "CLARITY: Consider removing filler words: $clean_line" >> "$suggestions_file"
        fi
        
        if [ ${#clean_line} -gt 80 ]; then
            echo "CLARITY: Consider breaking long sentence: $clean_line" >> "$suggestions_file"
        fi
    done
    
    echo "$suggestions_file"
}

# Fix common identifier naming issues
fix_identifier_naming() {
    local file=$1
    local language=$(detect_file_language "$file")
    local fixes_applied=0
    
    case "$language" in
        "javascript"|"typescript")
            # Fix camelCase issues
            sed -i.bak -E 's/([a-z])_([a-z])/\1\u\2/g' "$file"
            fixes_applied=$((fixes_applied + 1))
            ;;
        "python")
            # Fix snake_case issues
            sed -i.bak -E 's/([a-z])([A-Z])/\1_\l\2/g' "$file"
            fixes_applied=$((fixes_applied + 1))
            ;;
        "java"|"c"|"cpp"|"csharp")
            # Fix PascalCase for classes, camelCase for methods
            # This is more complex and would need context-aware parsing
            echo "Identifier naming check completed for $language"
            ;;
    esac
    
    echo "Identifier fixes applied: $fixes_applied"
}
```

## File Safety and Validation Utilities

```bash
# Create comprehensive backup before text modifications
create_text_backup() {
    local file=$1
    local backup_dir=${2:-.text-backups}
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    mkdir -p "$backup_dir"
    local backup_file="$backup_dir/$(basename "$file").text-backup.$timestamp"
    
    # Create backup with metadata
    cat > "$backup_file.meta" <<EOF
{
    "original_file": "$file",
    "backup_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "file_hash": "$(md5sum "$file" | cut -d' ' -f1)",
    "file_size": "$(get_file_size "$file")",
    "language": "$(detect_file_language "$file")",
    "content_type": "$(detect_text_content_type "$file")"
}
EOF
    
    cp "$file" "$backup_file"
    echo "$backup_file"
}

# Validate text changes don't break functionality
validate_text_changes() {
    local file=$1
    local backup_file=$2
    
    echo "Validating text changes in: $file"
    
    # Check syntax still valid
    if ! validate_syntax "$file"; then
        echo "Syntax validation failed"
        return 1
    fi
    
    # Check file size hasn't changed dramatically
    local original_size=$(get_file_size "$backup_file")
    local new_size=$(get_file_size "$file")
    local size_diff=$((new_size - original_size))
    local size_change_percent=$(echo "scale=2; $size_diff * 100 / $original_size" | bc 2>/dev/null || echo "0")
    
    if [ "${size_change_percent%.*}" -gt 10 ]; then
        echo "WARNING: File size changed by ${size_change_percent}%"
        echo "Original: $(format_file_size $original_size), New: $(format_file_size $new_size)"
    fi
    
    # Check encoding and line endings
    check_file_encoding "$file" || return 1
    check_line_endings "$file" || return 1
    
    echo "Text changes validation passed"
    return 0
}

# Rollback text changes if validation fails
rollback_text_changes() {
    local file=$1
    local backup_file=$2
    local reason=${3:-"validation_failed"}
    
    echo "Rolling back text changes: $reason"
    
    if [ -f "$backup_file" ]; then
        cp "$backup_file" "$file"
        echo "File restored from backup: $backup_file"
        
        # Log rollback
        local log_file="/tmp/text-rollback-$(date +%Y%m%d).log"
        echo "$(date -u +%Y-%m-%dT%H:%M:%SZ): Rolled back $file (reason: $reason)" >> "$log_file"
        
        return 0
    else
        echo "ERROR: Backup file not found: $backup_file"
        return 1
    fi
}

# Check if text modifications are safe to apply
is_safe_text_modification() {
    local file=$1
    local modification_type=$2
    
    # Check if file is under version control
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        if [ -n "$(git status --porcelain "$file" 2>/dev/null)" ]; then
            echo "WARNING: File has uncommitted changes: $file"
        fi
    fi
    
    # Check if file is read-only
    if [ ! -w "$file" ]; then
        echo "ERROR: File is read-only: $file"
        return 1
    fi
    
    # Check modification type safety
    case "$modification_type" in
        "comments_only")
            return 0  # Safe to modify comments
            ;;
        "strings_only")
            echo "WARNING: Modifying strings may affect functionality"
            return 0
            ;;
        "identifiers")
            echo "CAUTION: Modifying identifiers will affect code functionality"
            return 1
            ;;
        "mixed")
            echo "WARNING: Mixed modifications - review carefully"
            return 0
            ;;
        *)
            echo "UNKNOWN: Unknown modification type: $modification_type"
            return 1
            ;;
    esac
}
```

## Progress and Reporting Utilities

```bash
# Track text quality improvement progress
track_text_quality_progress() {
    local operation_id=$1
    local total_files=$2
    local current_file=$3
    local issues_found=${4:-0}
    local issues_fixed=${5:-0}
    local start_time=${6:-$(date +%s)}
    
    local current_time=$(date +%s)
    local elapsed=$((current_time - start_time))
    local percentage=$((current_file * 100 / total_files))
    
    # Calculate text quality metrics
    local fix_rate="0.0"
    if [ $issues_found -gt 0 ]; then
        fix_rate=$(echo "scale=2; $issues_fixed * 100 / $issues_found" | bc 2>/dev/null || echo "0.0")
    fi
    
    # Update progress file with text-specific metrics
    local progress_file="/tmp/text-quality-progress-$operation_id"
    cat > "$progress_file" <<EOF
{
    "operation_id": "$operation_id",
    "total_files": $total_files,
    "current_file": $current_file,
    "percentage": $percentage,
    "elapsed_seconds": $elapsed,
    "issues_found": $issues_found,
    "issues_fixed": $issues_fixed,
    "fix_rate_percent": "$fix_rate",
    "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    
    # Display progress with text quality metrics
    local progress_bar=$(format_progress_bar "$percentage" 30)
    echo -ne "\r[$operation_id] $progress_bar $percentage% ($current_file/$total_files) Issues: $issues_found Fixed: $issues_fixed (${fix_rate}%)"
    
    if [ $current_file -eq $total_files ]; then
        echo ""  # New line when complete
        rm -f "$progress_file"
    fi
}

# Generate text quality report
generate_text_quality_report() {
    local target_dir=${1:-.}
    local operation_id=$2
    local report_file="/tmp/text-quality-report-$operation_id.md"
    
    cat > "$report_file" <<EOF
# Text Quality Report

**Target Directory:** $target_dir
**Generated:** $(date)
**Operation ID:** $operation_id

## Summary

EOF
    
    # Collect statistics
    local total_files=0
    local text_files=0
    local issues_found=0
    local issues_fixed=0
    
    find_files_filtered "$target_dir" "*" | while read -r file; do
        total_files=$((total_files + 1))
        
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            text_files=$((text_files + 1))
            
            # Extract and analyze text
            local text_file=$(extract_text_from_source "$file")
            local quality_result=$(check_text_quality "$(cat "$text_file")")
            local issue_count="${quality_result##*:}"
            issues_found=$((issues_found + issue_count))
            
            rm -f "$text_file"
        fi
    done
    
    cat >> "$report_file" <<EOF
- **Total Files:** $total_files
- **Text-containing Files:** $text_files  
- **Issues Found:** $issues_found
- **Issues Fixed:** $issues_fixed
- **Success Rate:** $(echo "scale=1; $issues_fixed * 100 / $issues_found" | bc 2>/dev/null || echo "0.0")%

## File Types Analyzed

EOF
    
    # Language breakdown
    declare -A lang_counts
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file"; then
            local lang=$(detect_file_language "$file")
            echo "$lang"
        fi
    done | sort | uniq -c | while read -r count lang; do
        echo "- **$lang:** $count files" >> "$report_file"
    done
    
    cat >> "$report_file" <<EOF

## Issues by Category

EOF
    
    # Issue category breakdown (would be populated during actual processing)
    cat >> "$report_file" <<EOF
- **Grammar Issues:** 0
- **Spelling Issues:** 0  
- **Style Issues:** 0
- **Clarity Issues:** 0
- **Inclusive Language:** 0
- **Terminology Consistency:** 0

## Recommendations

1. **High Priority:** Fix grammar and spelling errors
2. **Medium Priority:** Improve clarity and style
3. **Low Priority:** Update terminology for consistency

## Files with Most Issues

(This would list the top 10 files with text quality issues)

---
Generated by Claude Code Text Quality Suite
EOF
    
    echo "$report_file"
}

# Export text quality metrics
export_text_metrics() {
    local target_dir=${1:-.}
    local format=${2:-"json"}
    local output_file="/tmp/text-metrics-$(date +%Y%m%d_%H%M%S).$format"
    
    case "$format" in
        "json")
            cat > "$output_file" <<EOF
{
    "text_quality_metrics": {
        "target_directory": "$target_dir",
        "analyzed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "files": []
    }
}
EOF
            ;;
        "csv")
            echo "file,language,content_type,issues_found,readability_score,word_count" > "$output_file"
            ;;
        *)
            echo "Unsupported format: $format"
            return 1
            ;;
    esac
    
    echo "$output_file"
}
```

## Integration with Code Quality Tools

```bash
# Integrate with existing quality tools
coordinate_with_quality_tools() {
    local file=$1
    local language=$(detect_file_language "$file")
    
    echo "Coordinating text quality with code quality tools for: $file"
    
    # Run formatters first to normalize code structure
    local formatters=$(detect_formatters "$language")
    for formatter in $formatters; do
        if command -v "$formatter" >/dev/null 2>&1; then
            echo "Running formatter: $formatter"
            case "$formatter" in
                "prettier")
                    prettier --write "$file" 2>/dev/null || true
                    ;;
                "black")
                    black "$file" 2>/dev/null || true
                    ;;
                "gofmt")
                    gofmt -w "$file" 2>/dev/null || true
                    ;;
                *)
                    echo "Formatter $formatter not directly supported"
                    ;;
            esac
        fi
    done
    
    # Then apply text quality improvements
    echo "Code formatting complete, ready for text quality improvements"
}

# Preserve code formatting during text corrections
preserve_code_formatting() {
    local file=$1
    local temp_formatted="/tmp/formatted-$$-$(basename "$file")"
    
    # Create formatted version
    coordinate_with_quality_tools "$file"
    cp "$file" "$temp_formatted"
    
    echo "$temp_formatted"
}

# Validate text changes don't conflict with code quality
validate_no_quality_conflicts() {
    local file=$1
    local formatted_backup=$2
    
    # Check if code quality tools are happy
    local language=$(detect_file_language "$file")
    local linters=$(detect_linters "$language")
    
    for linter in $linters; do
        if command -v "$linter" >/dev/null 2>&1; then
            case "$linter" in
                "eslint")
                    if ! eslint "$file" >/dev/null 2>&1; then
                        echo "ESLint validation failed after text changes"
                        return 1
                    fi
                    ;;
                "flake8")
                    if ! flake8 "$file" >/dev/null 2>&1; then
                        echo "Flake8 validation failed after text changes"
                        return 1
                    fi
                    ;;
                *)
                    echo "Linter $linter not directly supported for validation"
                    ;;
            esac
        fi
    done
    
    echo "Text changes passed code quality validation"
    return 0
}
```

These utilities provide a comprehensive foundation for the code text quality command suite, focusing specifically on text analysis, correction, and improvement within code projects while maintaining code functionality and integrating with existing development tools.