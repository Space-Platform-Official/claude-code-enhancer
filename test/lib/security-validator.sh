#!/bin/bash

# Security validation functions for Claude Flow commands
# Provides comprehensive security analysis, tool permission audits, and safety checks

# Enable strict error handling
set -euo pipefail

# Shared functions from command-validator.sh will be available when sourced by main script
# Dependencies: parse_yaml_frontmatter, validation_success, map_command_dependencies

# Security severity levels
readonly SECURITY_CRITICAL="CRITICAL"
readonly SECURITY_HIGH="HIGH"
readonly SECURITY_MEDIUM="MEDIUM"
readonly SECURITY_LOW="LOW"
readonly SECURITY_INFO="INFO"

# Security counters
SECURITY_CRITICAL_COUNT=0
SECURITY_HIGH_COUNT=0
SECURITY_MEDIUM_COUNT=0
SECURITY_LOW_COUNT=0

# Security issue reporting
security_issue() {
    local severity="$1"
    local message="$2"
    local file="${3:-}"
    local line="${4:-}"
    
    case "$severity" in
        "$SECURITY_CRITICAL")
            echo -e "${RED}🚨 CRITICAL SECURITY [${file}:${line}]: ${message}${NC}" >&2
            ((SECURITY_CRITICAL_COUNT++)) || true
            ;;
        "$SECURITY_HIGH")
            echo -e "${RED}🔴 HIGH SECURITY [${file}:${line}]: ${message}${NC}" >&2
            ((SECURITY_HIGH_COUNT++)) || true
            ;;
        "$SECURITY_MEDIUM")
            echo -e "${YELLOW}🟡 MEDIUM SECURITY [${file}:${line}]: ${message}${NC}" >&2
            ((SECURITY_MEDIUM_COUNT++)) || true
            ;;
        "$SECURITY_LOW")
            echo -e "${BLUE}🔵 LOW SECURITY [${file}:${line}]: ${message}${NC}" >&2
            ((SECURITY_LOW_COUNT++)) || true
            ;;
        *)
            echo -e "${BLUE}ℹ SECURITY INFO [${file}:${line}]: ${message}${NC}" >&2
            ;;
    esac
}

# Analyze tool permissions for security risks
analyze_tool_permissions() {
    local file="$1"
    local yaml_data
    
    validation_info "Analyzing tool permissions: $(basename "$file")"
    
    yaml_data=$(parse_yaml_frontmatter "$file")
    
    local allowed_tools=""
    while IFS='=' read -r key value; do
        if [[ "$key" == "allowed-tools" ]]; then
            allowed_tools="$value"
            break
        fi
    done <<< "$yaml_data"
    
    if [[ -z "$allowed_tools" ]]; then
        security_issue "$SECURITY_HIGH" "No tool permissions defined" "$file"
        return 1
    fi
    
    # Analyze permission levels
    case "$allowed_tools" in
        "all")
            security_issue "$SECURITY_HIGH" "Unrestricted tool access - requires justification" "$file"
            check_justification_for_all_tools "$file"
            ;;
        "none")
            validation_success "Safe: Read-only command"
            ;;
        *)
            analyze_specific_tool_permissions "$file" "$allowed_tools"
            ;;
    esac
}

# Check if commands with 'all' tools have proper justification
check_justification_for_all_tools() {
    local file="$1"
    
    # Look for security justification or warnings
    if grep -qi 'security\|caution\|danger\|warning\|critical' "$file"; then
        validation_success "Security considerations documented"
    else
        security_issue "$SECURITY_MEDIUM" "Unrestricted access without security documentation" "$file"
    fi
    
    # Check if it's in a high-risk category
    local filename
    filename="$(basename "$file" .md)"
    
    case "$filename" in
        *security*|*admin*|*root*|*privilege*)
            security_issue "$SECURITY_HIGH" "High-risk command name with unrestricted access" "$file"
            ;;
    esac
}

# Analyze specific tool permissions
analyze_specific_tool_permissions() {
    local file="$1"
    local tools="$2"
    
    # High-risk tool combinations
    local dangerous_tools=("Bash" "Write" "Edit" "MultiEdit")
    local network_tools=("WebFetch" "WebSearch")
    local file_tools=("Write" "Edit" "MultiEdit")
    
    IFS=',' read -ra tool_list <<< "$tools"
    
    local has_dangerous=false
    local has_network=false
    local has_file_write=false
    
    for tool in "${tool_list[@]}"; do
        tool=$(echo "$tool" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        if [[ " ${dangerous_tools[*]} " =~ " ${tool} " ]]; then
            has_dangerous=true
        fi
        
        if [[ " ${network_tools[*]} " =~ " ${tool} " ]]; then
            has_network=true
        fi
        
        if [[ " ${file_tools[*]} " =~ " ${tool} " ]]; then
            has_file_write=true
        fi
        
        case "$tool" in
            "Bash")
                security_issue "$SECURITY_HIGH" "Command execution capability detected" "$file"
                ;;
            "Write"|"Edit"|"MultiEdit")
                security_issue "$SECURITY_MEDIUM" "File modification capability detected" "$file"
                ;;
            "WebFetch"|"WebSearch")
                security_issue "$SECURITY_LOW" "Network access capability detected" "$file"
                ;;
        esac
    done
    
    # Check for dangerous combinations
    if [[ "$has_dangerous" == true && "$has_network" == true ]]; then
        security_issue "$SECURITY_CRITICAL" "DANGEROUS: Combined execution and network access" "$file"
    fi
    
    if [[ "$has_file_write" == true ]]; then
        check_file_safety_measures "$file"
    fi
}

# Check for file safety measures
check_file_safety_measures() {
    local file="$1"
    
    # Look for backup/safety patterns
    if grep -qi 'backup\|rollback\|restore\|undo'; then
        validation_success "File safety measures documented"
    else
        security_issue "$SECURITY_MEDIUM" "File modification without documented safety measures" "$file"
    fi
}

# Detect dangerous operations and patterns
detect_dangerous_operations() {
    local file="$1"
    
    validation_info "Scanning for dangerous operations: $(basename "$file")"
    
    # Critical dangerous patterns
    local critical_patterns=(
        "rm -rf"
        "sudo.*rm"
        "chmod 777"
        "chown.*root"
        ">/dev/null.*2>&1.*&"
        "eval.*\$"
        "bash.*-c.*\$"
    )
    
    # High-risk patterns
    local high_risk_patterns=(
        "curl.*|.*sh"
        "wget.*|.*sh"
        "exec.*\$"
        "system.*\$"
        "\$\(.*\$"
        "`.*`"
    )
    
    # Medium-risk patterns  
    local medium_risk_patterns=(
        "password"
        "secret"
        "api[_-]?key"
        "token"
        "credential"
        "auth[_-]?header"
    )
    
    # Check critical patterns
    for pattern in "${critical_patterns[@]}"; do
        if grep -n -E "$pattern" "$file" | while IFS=':' read -r line_num line_content; do
            security_issue "$SECURITY_CRITICAL" "Dangerous operation detected: $pattern" "$file" "$line_num"
        done; then
            :
        fi
    done
    
    # Check high-risk patterns
    for pattern in "${high_risk_patterns[@]}"; do
        if grep -n -E "$pattern" "$file" | while IFS=':' read -r line_num line_content; do
            security_issue "$SECURITY_HIGH" "High-risk operation detected: $pattern" "$file" "$line_num"
        done; then
            :
        fi
    done
    
    # Check medium-risk patterns
    for pattern in "${medium_risk_patterns[@]}"; do
        if grep -n -i -E "$pattern" "$file" | while IFS=':' read -r line_num line_content; do
            security_issue "$SECURITY_MEDIUM" "Sensitive data reference detected: $pattern" "$file" "$line_num"
        done; then
            :
        fi
    done
}

# Validate input sanitization patterns
validate_input_sanitization() {
    local file="$1"
    
    validation_info "Checking input sanitization: $(basename "$file")"
    
    # Look for user input handling
    if grep -q '\$[0-9]\|\$@\|\$\*\|\${\|\$(' "$file"; then
        # Check for sanitization patterns
        if grep -q 'validate\|sanitize\|escape\|quote' "$file"; then
            validation_success "Input sanitization patterns found"
        else
            security_issue "$SECURITY_HIGH" "User input handling without sanitization" "$file"
        fi
    fi
    
    # Check for command injection vulnerabilities
    if grep -q 'eval\|exec\|system' "$file"; then
        security_issue "$SECURITY_CRITICAL" "Command injection risk detected" "$file"
    fi
    
    # Check for path traversal risks
    if grep -q '\.\./\|\.\.\\\|%2e%2e' "$file"; then
        security_issue "$SECURITY_HIGH" "Path traversal pattern detected" "$file"
    fi
}

# Analyze privilege escalation risks
analyze_privilege_escalation() {
    local file="$1"
    
    validation_info "Analyzing privilege escalation risks: $(basename "$file")"
    
    # Check for privilege escalation commands
    local priv_commands=("sudo" "su" "chroot" "setuid" "setgid" "pkexec")
    
    for cmd in "${priv_commands[@]}"; do
        if grep -q "\\b$cmd\\b" "$file"; then
            security_issue "$SECURITY_CRITICAL" "Privilege escalation command detected: $cmd" "$file"
        fi
    done
    
    # Check for file permission modifications
    if grep -q 'chmod.*[u+s]\|chmod.*[g+s]' "$file"; then
        security_issue "$SECURITY_HIGH" "SUID/SGID permission modification detected" "$file"
    fi
}

# Check for secure coding practices
validate_secure_coding_practices() {
    local file="$1"
    
    validation_info "Validating secure coding practices: $(basename "$file")"
    
    # Check for error handling
    if ! grep -q 'set -e\|set -euo\|trap\|error\|fail' "$file"; then
        security_issue "$SECURITY_MEDIUM" "Limited error handling detected" "$file"
    fi
    
    # Check for temporary file handling
    if grep -q '/tmp/\|mktemp' "$file"; then
        if grep -q 'mktemp\|umask\|secure' "$file"; then
            validation_success "Secure temporary file handling"
        else
            security_issue "$SECURITY_MEDIUM" "Insecure temporary file usage" "$file"
        fi
    fi
    
    # Check for logging sensitive data
    if grep -q 'echo.*password\|echo.*secret\|echo.*key\|echo.*token' "$file"; then
        security_issue "$SECURITY_HIGH" "Potential sensitive data logging" "$file"
    fi
}

# Analyze command dependencies for security
analyze_dependency_security() {
    local file="$1"
    local commands_dir="$2"
    
    validation_info "Analyzing dependency security: $(basename "$file")"
    
    # Get dependencies
    local deps
    mapfile -t deps < <(map_command_dependencies "$file")
    
    for dep in "${deps[@]}"; do
        if [[ -n "$dep" ]]; then
            local dep_path="${commands_dir}/${dep}"
            if [[ -f "$dep_path" ]]; then
                # Check if dependency has high privileges
                local dep_yaml
                dep_yaml=$(parse_yaml_frontmatter "$dep_path" 2>/dev/null || echo "")
                
                if echo "$dep_yaml" | grep -q "allowed-tools=all"; then
                    security_issue "$SECURITY_MEDIUM" "Depends on high-privilege command: $dep" "$file"
                fi
            fi
        fi
    done
}

# Check for security best practices compliance
validate_security_best_practices() {
    local file="$1"
    
    validation_info "Validating security best practices: $(basename "$file")"
    
    # Check for security documentation
    if ! grep -qi 'security\|safety\|caution\|warning\|risk'; then
        security_issue "$SECURITY_LOW" "No security considerations documented" "$file"
    fi
    
    # Check for proper quoting in shell commands
    if grep -q '\$\w\+[[:space:]]\|\${\w\+}[[:space:]]' "$file"; then
        if ! grep -q '".*\$.*"' "$file"; then
            security_issue "$SECURITY_MEDIUM" "Unquoted variable usage in shell commands" "$file"
        fi
    fi
    
    # Check for hardcoded secrets
    local secret_patterns=("password=\|secret=\|key=\|token=" "api_key\|api-key" "bearer.*[a-zA-Z0-9]{20,}")
    
    for pattern in "${secret_patterns[@]}"; do
        if grep -i -q "$pattern" "$file"; then
            security_issue "$SECURITY_CRITICAL" "Potential hardcoded secret detected" "$file"
        fi
    done
}

# Generate security summary report
generate_security_summary() {
    local total_issues
    total_issues=$((SECURITY_CRITICAL_COUNT + SECURITY_HIGH_COUNT + SECURITY_MEDIUM_COUNT + SECURITY_LOW_COUNT))
    
    echo -e "\n${BLUE}=== Security Validation Summary ===${NC}"
    echo -e "${RED}🚨 Critical Issues: $SECURITY_CRITICAL_COUNT${NC}"
    echo -e "${RED}🔴 High Issues: $SECURITY_HIGH_COUNT${NC}"
    echo -e "${YELLOW}🟡 Medium Issues: $SECURITY_MEDIUM_COUNT${NC}"
    echo -e "${BLUE}🔵 Low Issues: $SECURITY_LOW_COUNT${NC}"
    echo -e "Total Security Issues: $total_issues"
    
    # Determine overall security status
    if [[ $SECURITY_CRITICAL_COUNT -gt 0 ]]; then
        echo -e "${RED}🚨 SECURITY STATUS: CRITICAL - IMMEDIATE ACTION REQUIRED${NC}"
        return 2
    elif [[ $SECURITY_HIGH_COUNT -gt 0 ]]; then
        echo -e "${RED}🔴 SECURITY STATUS: HIGH RISK - REVIEW REQUIRED${NC}"
        return 1
    elif [[ $SECURITY_MEDIUM_COUNT -gt 0 ]]; then
        echo -e "${YELLOW}🟡 SECURITY STATUS: MEDIUM RISK - IMPROVEMENTS RECOMMENDED${NC}"
        return 0
    elif [[ $SECURITY_LOW_COUNT -gt 0 ]]; then
        echo -e "${BLUE}🔵 SECURITY STATUS: LOW RISK - MINOR IMPROVEMENTS SUGGESTED${NC}"
        return 0
    else
        echo -e "${GREEN}✅ SECURITY STATUS: SECURE${NC}"
        return 0
    fi
}

# Main security validation function for a single file
validate_file_security() {
    local file="$1"
    local commands_dir="$2"
    
    if [[ ! -f "$file" ]]; then
        security_issue "$SECURITY_HIGH" "File not found" "$file"
        return 1
    fi
    
    echo -e "\n${BLUE}=== Security Analysis: $(basename "$file") ===${NC}"
    
    # Run all security checks
    analyze_tool_permissions "$file"
    detect_dangerous_operations "$file"
    validate_input_sanitization "$file"
    analyze_privilege_escalation "$file"
    validate_secure_coding_practices "$file"
    analyze_dependency_security "$file" "$commands_dir"
    validate_security_best_practices "$file"
    
    return 0
}

# Validate security for all commands
validate_all_command_security() {
    local commands_dir="$1"
    local total_files=0
    
    if [[ ! -d "$commands_dir" ]]; then
        security_issue "$SECURITY_CRITICAL" "Commands directory not found: $commands_dir"
        return 1
    fi
    
    validation_info "Starting security validation of all commands in: $commands_dir"
    
    # Reset counters
    SECURITY_CRITICAL_COUNT=0
    SECURITY_HIGH_COUNT=0
    SECURITY_MEDIUM_COUNT=0
    SECURITY_LOW_COUNT=0
    
    # Validate individual files
    while IFS= read -r -d '' file; do
        ((total_files++)) || true
        validate_file_security "$file" "$commands_dir"
    done < <(find "$commands_dir" -name "*.md" -print0)
    
    # Generate summary
    validation_info "Total files analyzed: $total_files"
    generate_security_summary
}

# Export security functions
export -f security_issue analyze_tool_permissions detect_dangerous_operations
export -f validate_input_sanitization analyze_privilege_escalation
export -f validate_secure_coding_practices validate_security_best_practices
export -f validate_file_security validate_all_command_security
export -f generate_security_summary