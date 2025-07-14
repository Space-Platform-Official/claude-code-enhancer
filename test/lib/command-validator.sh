#!/bin/bash

# Core validation functions for Claude Flow commands
# Provides comprehensive validation of command structure, content, and references

# Enable strict error handling
set -euo pipefail

# Colors for output (will be inherited from main script)
# Using variables: GREEN, YELLOW, BLUE, RED, NC

# Validation counters
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0

# Helper functions for output
validation_error() {
    local message="${1:-}"
    local file="${2:-}"
    local line="${3:-}"
    
    if [[ -n "${file}" && -n "${line}" ]]; then
        echo -e "${RED}✗ ERROR [${file}:${line}]: ${message}${NC}" >&2
    elif [[ -n "${file}" ]]; then
        echo -e "${RED}✗ ERROR [${file}]: ${message}${NC}" >&2
    else
        echo -e "${RED}✗ ERROR: ${message}${NC}" >&2
    fi
    ((VALIDATION_ERRORS++)) || true
}

validation_warning() {
    local message="${1:-}"
    local file="${2:-}"
    local line="${3:-}"
    
    if [[ -n "${file}" && -n "${line}" ]]; then
        echo -e "${YELLOW}⚠ WARNING [${file}:${line}]: ${message}${NC}" >&2
    elif [[ -n "${file}" ]]; then
        echo -e "${YELLOW}⚠ WARNING [${file}]: ${message}${NC}" >&2
    else
        echo -e "${YELLOW}⚠ WARNING: ${message}${NC}" >&2
    fi
    ((VALIDATION_WARNINGS++)) || true
}

validation_success() {
    local message="${1:-}"
    echo -e "${GREEN}✓ ${message}${NC}"
}

validation_info() {
    local message="${1:-}"
    echo -e "${BLUE}ℹ ${message}${NC}"
}

# Extract YAML frontmatter from markdown file
extract_frontmatter() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        validation_error "File not found" "$file"
        return 1
    fi
    
    # Extract content between first pair of --- markers
    awk '/^---$/{f=!f; if(!f) exit} f && !/^---$/' "$file"
}

# Parse YAML frontmatter into key-value pairs
parse_yaml_frontmatter() {
    local file="$1"
    local frontmatter
    
    frontmatter=$(extract_frontmatter "$file")
    
    if [[ -z "$frontmatter" ]]; then
        validation_error "No YAML frontmatter found" "$file"
        return 1
    fi
    
    # Parse simple YAML (key: value pairs)
    echo "$frontmatter" | while IFS=': ' read -r key value || [[ -n "$key" ]]; do
        if [[ -n "$key" && -n "$value" ]]; then
            # Remove leading/trailing whitespace and quotes
            key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^["'"'"']//;s/["'"'"']$//')
            echo "${key}=${value}"
        fi
    done
}

# Validate YAML frontmatter structure
validate_frontmatter() {
    local file="$1"
    local yaml_data
    local required_fields=("allowed-tools" "description")
    local field_found=false
    
    validation_info "Validating frontmatter: $(basename "$file")"
    
    yaml_data=$(parse_yaml_frontmatter "$file")
    
    if [[ -z "$yaml_data" ]]; then
        validation_error "Failed to parse YAML frontmatter" "$file"
        return 1
    fi
    
    # Check required fields
    for field in "${required_fields[@]}"; do
        field_found=false
        while IFS='=' read -r key value; do
            if [[ "$key" == "$field" ]]; then
                field_found=true
                break
            fi
        done <<< "$yaml_data"
        
        if [[ "$field_found" == false ]]; then
            validation_error "Required field '$field' missing in frontmatter" "$file"
        fi
    done
    
    # Validate allowed-tools field
    validate_allowed_tools "$file" "$yaml_data"
    
    # Validate description field
    validate_description "$file" "$yaml_data"
    
    return 0
}

# Validate allowed-tools field
validate_allowed_tools() {
    local file="$1"
    local yaml_data="$2"
    local allowed_tools=""
    
    while IFS='=' read -r key value; do
        if [[ "$key" == "allowed-tools" ]]; then
            allowed_tools="$value"
            break
        fi
    done <<< "$yaml_data"
    
    if [[ -z "$allowed_tools" ]]; then
        validation_error "allowed-tools field is empty" "$file"
        return 1
    fi
    
    # Valid tool options
    local valid_tools=("all" "none" "Bash" "Read" "Write" "Edit" "MultiEdit" "Glob" "Grep" "LS" "WebFetch" "WebSearch" "TodoWrite" "NotebookRead" "NotebookEdit")
    
    case "$allowed_tools" in
        "all"|"none")
            validation_success "allowed-tools value '$allowed_tools' is valid"
            ;;
        *)
            # Check if it's a comma-separated list of valid tools
            IFS=',' read -ra tools <<< "$allowed_tools"
            for tool in "${tools[@]}"; do
                tool=$(echo "$tool" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                if [[ ! " ${valid_tools[*]} " =~ " ${tool} " ]]; then
                    validation_error "Invalid tool '$tool' in allowed-tools" "$file"
                fi
            done
            ;;
    esac
}

# Validate description field
validate_description() {
    local file="$1"
    local yaml_data="$2"
    local description=""
    
    while IFS='=' read -r key value; do
        if [[ "$key" == "description" ]]; then
            description="$value"
            break
        fi
    done <<< "$yaml_data"
    
    if [[ -z "$description" ]]; then
        validation_error "description field is empty" "$file"
        return 1
    fi
    
    # Validate description length
    local desc_length=${#description}
    if [[ $desc_length -lt 10 ]]; then
        validation_error "Description too short (${desc_length} chars, minimum 10)" "$file"
    elif [[ $desc_length -gt 200 ]]; then
        validation_error "Description too long (${desc_length} chars, maximum 200)" "$file"
    fi
    
    # Check description starts with capital letter
    if [[ ! "$description" =~ ^[A-Z] ]]; then
        validation_warning "Description should start with capital letter" "$file"
    fi
    
    # Check description doesn't end with period
    if [[ "$description" =~ \.$ ]]; then
        validation_warning "Description should not end with period" "$file"
    fi
    
    # Check for sensitive information in description
    if [[ "$description" =~ [Pp]assword|[Ss]ecret|[Kk]ey|[Tt]oken ]]; then
        validation_error "Description contains sensitive keywords" "$file"
    fi
}

# Validate command references and cross-references
validate_command_references() {
    local file="$1"
    local commands_dir="$2"
    
    validation_info "Validating command references: $(basename "$file")"
    
    # Find relative path references (../file.md, ./file.md, path/file.md)
    grep -n -E '\.\./[a-zA-Z0-9/_-]+\.md|\.\/[a-zA-Z0-9/_-]+\.md|[a-zA-Z0-9/_-]+/[a-zA-Z0-9/_-]+\.md' "$file" | while IFS=':' read -r line_num reference_line; do
        # Extract the file path
        local ref_path
        ref_path=$(echo "$reference_line" | grep -oE '\.\./[a-zA-Z0-9/_-]+\.md|\.\/[a-zA-Z0-9/_-]+\.md|[a-zA-Z0-9/_-]+/[a-zA-Z0-9/_-]+\.md' | head -1)
        
        if [[ -n "$ref_path" ]]; then
            # Resolve relative path
            local file_dir
            file_dir="$(dirname "$file")"
            local resolved_path
            resolved_path="$(cd "$file_dir" && realpath "$ref_path" 2>/dev/null || echo "$file_dir/$ref_path")"
            
            if [[ ! -f "$resolved_path" ]]; then
                validation_error "Referenced file does not exist: $ref_path" "$file" "$line_num"
            else
                validation_success "Valid reference: $ref_path"
            fi
        fi
    done
}

# Validate usage patterns and consistency
validate_usage_patterns() {
    local file="$1"
    
    validation_info "Validating usage patterns: $(basename "$file")"
    
    # Check for usage line
    if ! grep -q '^\*\*Usage:\*\*' "$file"; then
        validation_warning "No usage pattern found" "$file"
    fi
    
    # Check for command name consistency
    local filename
    filename="$(basename "$file" .md)"
    
    # Look for usage patterns that should match filename
    local usage_line
    usage_line=$(grep '^\*\*Usage:\*\*' "$file" | head -1)
    
    if [[ -n "$usage_line" && ! "$usage_line" =~ $filename ]]; then
        validation_warning "Usage pattern may not match filename" "$file"
    fi
    
    # Check for required sections
    local required_sections=("# " "## " "**Usage:**")
    for section in "${required_sections[@]}"; do
        if ! grep -q "^${section}" "$file"; then
            validation_warning "Missing section starting with '$section'" "$file"
        fi
    done
}

# Validate documentation completeness
validate_documentation_completeness() {
    local file="$1"
    
    validation_info "Validating documentation completeness: $(basename "$file")"
    
    # Check for code examples
    if ! grep -q '```' "$file"; then
        validation_warning "No code examples found" "$file"
    fi
    
    # Check for proper markdown structure
    local h1_count
    h1_count=$(grep -c '^# ' "$file" || echo "0")
    
    if [[ $h1_count -eq 0 ]]; then
        validation_error "No H1 heading found" "$file"
    elif [[ $h1_count -gt 1 ]]; then
        validation_warning "Multiple H1 headings found ($h1_count)" "$file"
    fi
    
    # Check for summary or conclusion
    if ! grep -qi 'summary\|conclusion\|remember' "$file"; then
        validation_warning "No summary or conclusion section found" "$file"
    fi
    
    # Validate markdown link syntax
    grep -n '\[.*\](' "$file" | while IFS=':' read -r line_num link_line; do
        if [[ "$link_line" =~ \[.*\]\([[:space:]]*\) ]]; then
            validation_error "Empty link found" "$file" "$line_num"
        fi
    done
}

# Check for best practice compliance
validate_best_practices() {
    local file="$1"
    
    validation_info "Validating best practices: $(basename "$file")"
    
    # Check for proper emoji usage (should be minimal and consistent)
    local emoji_count
    emoji_count=$(grep -o '[🚨✅❌⚠️📋🔍]' "$file" | wc -l || echo "0")
    
    if [[ $emoji_count -gt 10 ]]; then
        validation_warning "Excessive emoji usage ($emoji_count found)" "$file"
    fi
    
    # Check for consistent formatting
    if grep -q 'TODO\|FIXME\|XXX' "$file"; then
        validation_warning "TODO/FIXME comments found in production command" "$file"
    fi
    
    # Check for proper command structure
    if ! grep -q '^When you run ' "$file"; then
        validation_warning "Missing standard command introduction pattern" "$file"
    fi
    
    # Check for security considerations
    if grep -qi 'password\|secret\|key\|token' "$file" && ! grep -qi 'security\|caution\|warning'; then
        validation_warning "Mentions sensitive data without security warnings" "$file"
    fi
}

# Map command dependencies
map_command_dependencies() {
    local file="$1"
    local deps=()
    
    # Find references to other commands
    while IFS= read -r ref; do
        if [[ -n "$ref" ]]; then
            deps+=("$ref")
        fi
    done < <(grep -o '[a-zA-Z0-9/_-]*\.md' "$file" | sort -u)
    
    if [[ ${#deps[@]} -gt 0 ]]; then
        validation_info "Dependencies for $(basename "$file"): ${deps[*]}"
    fi
    
    printf '%s\n' "${deps[@]}"
}

# Detect circular dependencies
detect_circular_dependencies() {
    local commands_dir="$1"
    local -A dependency_map
    local -a all_files
    
    validation_info "Checking for circular dependencies"
    
    # Build dependency map
    while IFS= read -r -d '' file; do
        all_files+=("$file")
        local basename_file
        basename_file="$(basename "$file")"
        local deps
        mapfile -t deps < <(map_command_dependencies "$file")
        dependency_map["$basename_file"]="${deps[*]}"
    done < <(find "$commands_dir" -name "*.md" -print0)
    
    # Simple cycle detection (would need more sophisticated algorithm for complex cycles)
    for file in "${all_files[@]}"; do
        local basename_file
        basename_file="$(basename "$file")"
        local deps
        read -ra deps <<< "${dependency_map[$basename_file]}"
        
        for dep in "${deps[@]}"; do
            if [[ -n "$dep" ]]; then
                local dep_deps
                read -ra dep_deps <<< "${dependency_map[$dep]}"
                for dep_dep in "${dep_deps[@]}"; do
                    if [[ "$dep_dep" == "$basename_file" ]]; then
                        validation_error "Circular dependency detected: $basename_file -> $dep -> $dep_dep"
                    fi
                done
            fi
        done
    done
}

# Main validation function for a single file
validate_command_file() {
    local file="$1"
    local commands_dir="$2"
    
    if [[ ! -f "$file" ]]; then
        validation_error "File not found" "$file"
        return 1
    fi
    
    echo -e "\n${BLUE}=== Validating: $(basename "$file") ===${NC}"
    
    # Run all validation checks
    validate_frontmatter "$file"
    validate_command_references "$file" "$commands_dir"
    validate_usage_patterns "$file"
    validate_documentation_completeness "$file"
    validate_best_practices "$file"
    
    return 0
}

# Validate all commands in directory
validate_all_commands() {
    local commands_dir="$1"
    local total_files=0
    
    if [[ ! -d "$commands_dir" ]]; then
        validation_error "Commands directory not found: $commands_dir"
        return 1
    fi
    
    validation_info "Starting validation of all commands in: $commands_dir"
    
    # Validate individual files
    while IFS= read -r -d '' file; do
        ((total_files++)) || true
        validate_command_file "$file" "$commands_dir"
    done < <(find "$commands_dir" -name "*.md" -print0)
    
    # Check for circular dependencies
    detect_circular_dependencies "$commands_dir"
    
    # Summary
    echo -e "\n${BLUE}=== Validation Summary ===${NC}"
    validation_info "Total files validated: $total_files"
    
    if [[ $VALIDATION_ERRORS -eq 0 && $VALIDATION_WARNINGS -eq 0 ]]; then
        validation_success "All validations passed!"
        return 0
    else
        echo -e "${RED}Errors: $VALIDATION_ERRORS${NC}"
        echo -e "${YELLOW}Warnings: $VALIDATION_WARNINGS${NC}"
        return 1
    fi
}

# Export functions for use in other scripts
export -f validation_error validation_warning validation_success validation_info
export -f extract_frontmatter parse_yaml_frontmatter validate_frontmatter
export -f validate_command_references validate_usage_patterns
export -f validate_documentation_completeness validate_best_practices
export -f map_command_dependencies detect_circular_dependencies
export -f validate_command_file validate_all_commands