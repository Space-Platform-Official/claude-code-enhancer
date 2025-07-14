#!/bin/bash

# Security Edge Cases for Claude Flow Commands
# Tests various security vulnerabilities, attack vectors, and safety mechanisms
# Includes command injection, privilege escalation, credential exposure, and tool permission audits

# Enable strict error handling
set -euo pipefail

# Import test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$(dirname "$SCRIPT_DIR")"

source "$TEST_ROOT/lib/integration-environment.sh"
source "$TEST_ROOT/lib/security-validator.sh"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m'

# Test configuration
readonly SECURITY_TEST_DIR="/tmp/claude-security-tests-$$"
readonly ATTACK_PATTERNS_FILE="$SECURITY_TEST_DIR/attack-patterns.txt"
readonly CREDENTIAL_PATTERNS_FILE="$SECURITY_TEST_DIR/credential-patterns.txt"

# Security test statistics
SECURITY_TESTS_RUN=0
SECURITY_TESTS_PASSED=0
SECURITY_TESTS_FAILED=0
CRITICAL_VULNERABILITIES=0
HIGH_VULNERABILITIES=0
MEDIUM_VULNERABILITIES=0

# Helper functions
security_info() {
    echo -e "${CYAN}[SECURITY] $1${NC}"
}

security_success() {
    echo -e "${GREEN}[SECURITY] ✅ $1${NC}"
    ((SECURITY_TESTS_PASSED++))
}

security_error() {
    echo -e "${RED}[SECURITY] ❌ $1${NC}"
    ((SECURITY_TESTS_FAILED++))
}

security_warning() {
    echo -e "${YELLOW}[SECURITY] ⚠️ $1${NC}"
}

security_critical() {
    echo -e "${RED}[SECURITY] 🚨 CRITICAL: $1${NC}"
    ((CRITICAL_VULNERABILITIES++))
}

security_high() {
    echo -e "${MAGENTA}[SECURITY] 🔴 HIGH: $1${NC}"
    ((HIGH_VULNERABILITIES++))
}

security_medium() {
    echo -e "${YELLOW}[SECURITY] 🟡 MEDIUM: $1${NC}"
    ((MEDIUM_VULNERABILITIES++))
}

# Setup security test environment
setup_security_tests() {
    security_info "Setting up security edge case tests"
    
    mkdir -p "$SECURITY_TEST_DIR"
    cd "$SECURITY_TEST_DIR"
    
    # Create test repository
    git init --quiet
    git config user.name "Security Test"
    git config user.email "security@test.com"
    
    echo "Security test file" > security-test.txt
    git add security-test.txt
    git commit -m "Initial security test commit" --quiet
    
    # Create attack pattern databases
    create_attack_patterns_db
    create_credential_patterns_db
    
    security_success "Security test environment created"
}

# Cleanup security test environment
cleanup_security_tests() {
    security_info "Cleaning up security test environment"
    
    if [[ -d "$SECURITY_TEST_DIR" ]]; then
        # Remove any potentially dangerous files
        find "$SECURITY_TEST_DIR" -type f -name "*.sh" -exec chmod -x {} \; 2>/dev/null || true
        
        # Clean up
        chmod -R u+w "$SECURITY_TEST_DIR" 2>/dev/null || true
        rm -rf "$SECURITY_TEST_DIR"
    fi
    
    security_success "Security cleanup completed"
}

# Create database of attack patterns
create_attack_patterns_db() {
    cat > "$ATTACK_PATTERNS_FILE" << 'EOF'
# Command injection patterns
$(whoami)
`whoami`
; whoami
&& whoami
|| whoami
| whoami

# Shell metacharacters
; echo "injected"
&& echo "injected"
| echo "injected"
` echo "injected" `
$( echo "injected" )

# Path traversal
../../../etc/passwd
..\\..\\..\\windows\\system32
%2e%2e%2f%2e%2e%2f%2e%2e%2f

# Environment variable injection
$HOME/malicious
${HOME}/malicious
$PATH:malicious

# Script injection
<script>alert('xss')</script>
javascript:alert('xss')

# Dangerous git operations
--upload-pack
--receive-pack
--upload-archive
--no-verify

# File system attacks
/dev/null
/proc/self/environ
/sys/kernel/security

# Network exfiltration attempts
http://evil.com/exfil?data=
https://attacker.com/steal/
ftp://malicious.org/upload/

# Process manipulation
kill -9
pkill -f
killall

# Privilege escalation
sudo -s
su -
setuid
setgid

# Data destruction
rm -rf
rmdir
del /f /s /q
format
mkfs
EOF
}

# Create database of credential patterns
create_credential_patterns_db() {
    cat > "$CREDENTIAL_PATTERNS_FILE" << 'EOF'
# API Keys
api_key=sk-1234567890abcdef
apikey=AIzaSyDaGmWKa4JsXZ
api-key=ghp_1234567890123456789012345678901234567890

# Passwords
password=secret123
passwd=admin123
pwd=12345

# Tokens
token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
access_token=ya29.a0ARrdaM-1234567890
auth_token=xoxb-MOCK-TOKEN-FAKE-abcdefghijklmnopqrstuvwx

# Database credentials
db_password=dbsecret123
database_url=postgresql://user:pass@host:5432/db
mysql_password=mysqlsecret

# SSH Keys
-----BEGIN RSA PRIVATE KEY-----
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ
-----BEGIN OPENSSH PRIVATE KEY-----

# Cloud credentials
AWS_SECRET_ACCESS_KEY=abcdefghijklmnopqrstuvwxyz123456789012345
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
AZURE_CLIENT_SECRET=abcdef123456

# Generic secrets
secret=topsecret123
SECRET_KEY=supersecretkey
private_key=privatekey123

# Common credential files
.env
.secrets
credentials.json
config.ini
settings.py
EOF
}

# Test: Command injection prevention
test_command_injection_prevention() {
    security_info "Testing command injection prevention"
    ((SECURITY_TESTS_RUN++))
    
    local injection_success=true
    
    security_info "Loading attack patterns for injection testing"
    
    while IFS= read -r pattern; do
        # Skip comments and empty lines
        [[ "$pattern" =~ ^#.*$ ]] && continue
        [[ -z "$pattern" ]] && continue
        
        security_info "Testing injection pattern: ${pattern:0:40}..."
        
        # Monitor system state before test
        local pre_processes=$(ps aux | wc -l)
        local pre_network_connections=$(netstat -an 2>/dev/null | wc -l || echo "0")
        
        # Test pattern as commit message (safe context)
        echo "injection test content" > injection-test.txt
        git add injection-test.txt
        
        # Attempt injection via commit message
        if timeout 5 git commit -m "$pattern" --quiet 2>/dev/null; then
            security_info "Pattern accepted as commit message: ${pattern:0:20}..."
            
            # Check for signs of command execution
            local post_processes=$(ps aux | wc -l)
            local post_network_connections=$(netstat -an 2>/dev/null | wc -l || echo "0")
            
            # Allow for some variance in process counts
            local process_diff=$((post_processes - pre_processes))
            local network_diff=$((post_network_connections - pre_network_connections))
            
            if [[ $process_diff -gt 5 ]] || [[ $network_diff -gt 5 ]]; then
                security_critical "Potential command execution detected with pattern: $pattern"
                injection_success=false
            else
                security_info "✓ Pattern contained safely in commit message"
            fi
        else
            security_info "✓ Injection pattern rejected appropriately"
        fi
        
        # Test pattern as filename (if safe to create)
        local safe_filename="test-$(echo "$pattern" | tr -cd '[:alnum:]').txt"
        if [[ ${#safe_filename} -gt 4 && ${#safe_filename} -lt 50 ]]; then
            echo "test content" > "$safe_filename" 2>/dev/null || true
            
            if [[ -f "$safe_filename" ]]; then
                if git add "$safe_filename" 2>/dev/null; then
                    security_info "✓ Safe filename variant handled"
                    git commit -m "Add safe filename test" --quiet 2>/dev/null || true
                fi
                rm -f "$safe_filename"
            fi
        fi
        
        # Cleanup
        rm -f injection-test.txt 2>/dev/null || true
        
    done < "$ATTACK_PATTERNS_FILE"
    
    if [[ "$injection_success" == "true" ]]; then
        security_success "Command injection prevention test passed"
    else
        security_error "Command injection prevention test failed"
        return 1
    fi
}

# Test: Credential exposure detection
test_credential_exposure() {
    security_info "Testing credential exposure detection"
    ((SECURITY_TESTS_RUN++))
    
    local credential_success=true
    
    security_info "Testing credential pattern detection"
    
    while IFS= read -r pattern; do
        # Skip comments and empty lines
        [[ "$pattern" =~ ^#.*$ ]] && continue
        [[ -z "$pattern" ]] && continue
        
        security_info "Testing credential pattern: ${pattern:0:30}..."
        
        # Create file with credential-like content
        echo "$pattern" > credential-test.txt
        
        # Test if git adds file with credentials
        if git add credential-test.txt 2>/dev/null; then
            security_warning "Potential credential added to git: ${pattern:0:20}..."
            
            # Check if any hooks or validation catch it
            if git commit -m "Test credential detection" --quiet 2>/dev/null; then
                security_medium "Credential pattern committed successfully: ${pattern:0:20}..."
                
                # Check if the credential is visible in git log
                if git log --oneline -1 | grep -q "credential"; then
                    security_info "✓ Credential context visible in log"
                fi
            else
                security_info "✓ Credential commit blocked (likely by hooks)"
            fi
        else
            security_info "✓ Credential file rejected by git"
        fi
        
        # Test credential in commit message
        echo "safe content" > safe-test.txt
        git add safe-test.txt 2>/dev/null || true
        
        if git commit -m "$pattern" --quiet 2>/dev/null; then
            security_medium "Credential in commit message: ${pattern:0:20}..."
            
            # Check if credential is searchable in git log
            if git log --grep="$pattern" --oneline | head -1 | grep -q "$pattern"; then
                security_medium "Credential searchable in git history"
            fi
        else
            security_info "✓ Credential in commit message rejected"
        fi
        
        # Cleanup
        rm -f credential-test.txt safe-test.txt 2>/dev/null || true
        
    done < "$CREDENTIAL_PATTERNS_FILE"
    
    # Test: Environment variable exposure
    security_info "Testing environment variable exposure"
    
    local sensitive_env_vars=(
        "PASSWORD"
        "SECRET"
        "API_KEY"
        "TOKEN"
        "CREDENTIAL"
    )
    
    for var in "${sensitive_env_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            security_warning "Sensitive environment variable detected: $var"
            
            # Check if it could leak into git
            if git config --list | grep -i "$var" >/dev/null 2>&1; then
                security_high "Sensitive variable in git config: $var"
                credential_success=false
            fi
        fi
    done
    
    if [[ "$credential_success" == "true" ]]; then
        security_success "Credential exposure test passed"
    else
        security_error "Credential exposure test failed"
        return 1
    fi
}

# Test: Tool permission auditing
test_tool_permissions() {
    security_info "Testing tool permission auditing"
    ((SECURITY_TESTS_RUN++))
    
    local permission_success=true
    
    # Test: Command template permission analysis
    security_info "Analyzing command template permissions"
    
    local templates_dir="$TEST_ROOT/../templates/commands"
    
    if [[ -d "$templates_dir" ]]; then
        local critical_commands=0
        local high_risk_commands=0
        
        while IFS= read -r -d '' template_file; do
            local template_name=$(basename "$template_file" .md)
            
            security_info "Analyzing template: $template_name"
            
            # Check allowed-tools field
            local allowed_tools=""
            if [[ -f "$template_file" ]]; then
                allowed_tools=$(grep -E "^allowed-tools:" "$template_file" | cut -d: -f2- | tr -d ' ' || echo "")
            fi
            
            if [[ -z "$allowed_tools" ]]; then
                security_medium "No tool permissions defined in: $template_name"
                continue
            fi
            
            case "$allowed_tools" in
                "all")
                    security_high "Unrestricted tool access in: $template_name"
                    ((high_risk_commands++))
                    
                    # Check for security justification
                    if grep -qi 'security\|caution\|danger\|warning' "$template_file"; then
                        security_info "✓ Security considerations documented"
                    else
                        security_high "No security documentation for unrestricted access: $template_name"
                    fi
                    ;;
                "none")
                    security_info "✓ Read-only template: $template_name"
                    ;;
                *"Bash"*)
                    security_high "Command execution capability in: $template_name"
                    ((critical_commands++))
                    
                    # Check for dangerous patterns in content
                    if grep -q 'rm\s*-rf\|sudo\|su\s' "$template_file"; then
                        security_critical "Dangerous command patterns in: $template_name"
                        permission_success=false
                    fi
                    ;;
                *"Write"*|*"Edit"*|*"MultiEdit"*)
                    security_medium "File modification capability in: $template_name"
                    
                    # Check for backup mentions
                    if grep -qi 'backup\|rollback\|restore' "$template_file"; then
                        security_info "✓ Backup considerations mentioned"
                    else
                        security_medium "No backup strategy mentioned: $template_name"
                    fi
                    ;;
                *)
                    # Parse comma-separated tool list
                    security_info "Custom tool permissions in: $template_name"
                    ;;
            esac
            
        done < <(find "$templates_dir" -name "*.md" -print0 2>/dev/null)
        
        security_info "Permission audit summary:"
        security_info "Critical commands (with Bash): $critical_commands"
        security_info "High-risk commands (all tools): $high_risk_commands"
        
    else
        security_warning "Templates directory not found: $templates_dir"
    fi
    
    # Test: Current git repository permissions
    security_info "Checking current repository permissions"
    
    # Check .git directory permissions
    if [[ -d ".git" ]]; then
        local git_perms=$(stat -c %a .git 2>/dev/null || stat -f %A .git 2>/dev/null || echo "unknown")
        security_info "Git directory permissions: $git_perms"
        
        if [[ "$git_perms" =~ ^[0-7][0-7][0-7]$ ]]; then
            local owner_perms=${git_perms:0:1}
            local group_perms=${git_perms:1:1}
            local other_perms=${git_perms:2:1}
            
            if [[ $other_perms -gt 0 ]]; then
                security_medium "Git directory readable by others: $git_perms"
            else
                security_info "✓ Git directory properly protected"
            fi
        fi
    fi
    
    # Check for sensitive files in repository
    security_info "Scanning for sensitive files"
    
    local sensitive_patterns=(
        "*.key"
        "*.pem"
        "*.p12"
        "*.pfx"
        "*password*"
        "*secret*"
        "*credential*"
        ".env"
        "config.json"
        "settings.py"
    )
    
    for pattern in "${sensitive_patterns[@]}"; do
        local found_files=$(find . -name "$pattern" -type f 2>/dev/null || true)
        if [[ -n "$found_files" ]]; then
            security_warning "Potentially sensitive files found:"
            echo "$found_files" | while read -r file; do
                security_warning "  - $file"
                
                # Check if file is tracked by git
                if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
                    security_high "Sensitive file tracked by git: $file"
                    permission_success=false
                fi
            done
        fi
    done
    
    if [[ "$permission_success" == "true" ]]; then
        security_success "Tool permission audit passed"
    else
        security_error "Tool permission audit failed"
        return 1
    fi
}

# Test: Privilege escalation prevention
test_privilege_escalation() {
    security_info "Testing privilege escalation prevention"
    ((SECURITY_TESTS_RUN++))
    
    local privilege_success=true
    
    # Test: Dangerous command detection
    security_info "Testing dangerous command detection"
    
    local dangerous_commands=(
        "sudo rm -rf /"
        "su - root"
        "chmod 777 /"
        "chown root:root"
        "setuid(0)"
        "setgid(0)"
        "exec('/bin/sh')"
        "system('rm -rf /')"
    )
    
    for cmd in "${dangerous_commands[@]}"; do
        security_info "Testing dangerous command: ${cmd:0:20}..."
        
        # Test as commit message
        echo "privilege test" > privilege-test.txt
        git add privilege-test.txt
        
        if git commit -m "$cmd" --quiet 2>/dev/null; then
            security_warning "Dangerous command accepted in commit: ${cmd:0:20}..."
            
            # Check if command is searchable
            if git log --grep="$cmd" --oneline | head -1 >/dev/null 2>&1; then
                security_medium "Dangerous command searchable in history"
            fi
        else
            security_info "✓ Dangerous command rejected"
        fi
        
        rm -f privilege-test.txt
    done
    
    # Test: File permission manipulation
    security_info "Testing file permission manipulation"
    
    echo "permission test content" > perm-test.txt
    
    # Test setting dangerous permissions
    if chmod 777 perm-test.txt 2>/dev/null; then
        security_warning "Successfully set 777 permissions on test file"
        
        if git add perm-test.txt 2>/dev/null; then
            security_info "✓ Git handled 777 permissions"
            git commit -m "Permission test" --quiet 2>/dev/null || true
        fi
        
        # Restore safe permissions
        chmod 644 perm-test.txt
    fi
    
    # Test SUID/SGID attempts
    if chmod u+s perm-test.txt 2>/dev/null; then
        security_high "Successfully set SUID bit on test file"
        privilege_success=false
        chmod -s perm-test.txt
    else
        security_info "✓ SUID bit setting prevented"
    fi
    
    rm -f perm-test.txt
    
    # Test: Environment manipulation
    security_info "Testing environment manipulation"
    
    local original_path="$PATH"
    
    # Test PATH manipulation
    export PATH="/tmp:$PATH"
    
    if command -v git >/dev/null 2>&1; then
        local git_location=$(which git)
        if [[ "$git_location" =~ ^/tmp/ ]]; then
            security_critical "Git resolved to /tmp - potential hijacking"
            privilege_success=false
        else
            security_info "✓ Git not hijacked by PATH manipulation"
        fi
    fi
    
    # Restore original PATH
    export PATH="$original_path"
    
    if [[ "$privilege_success" == "true" ]]; then
        security_success "Privilege escalation prevention test passed"
    else
        security_error "Privilege escalation prevention test failed"
        return 1
    fi
}

# Test: Data exfiltration prevention
test_data_exfiltration() {
    security_info "Testing data exfiltration prevention"
    ((SECURITY_TESTS_RUN++))
    
    local exfiltration_success=true
    
    # Test: Network connection monitoring
    security_info "Testing network connection patterns"
    
    local suspicious_urls=(
        "http://evil.com/exfil"
        "https://attacker.org/steal"
        "ftp://malicious.net/upload"
        "//malicious.com/share"
    )
    
    for url in "${suspicious_urls[@]}"; do
        security_info "Testing suspicious URL: ${url:0:30}..."
        
        # Test URL in commit message
        echo "network test" > network-test.txt
        git add network-test.txt
        
        if git commit -m "Connect to $url" --quiet 2>/dev/null; then
            security_medium "Suspicious URL in commit: ${url:0:30}..."
            
            # Check if URL is in git history
            if git log --grep="$url" --oneline >/dev/null 2>&1; then
                security_medium "Suspicious URL searchable in history"
            fi
        else
            security_info "✓ Suspicious URL rejected"
        fi
        
        rm -f network-test.txt
    done
    
    # Test: Large file monitoring
    security_info "Testing large file handling"
    
    # Create a moderately large file (within safety limits)
    dd if=/dev/zero of=large-test.bin bs=1M count=5 2>/dev/null
    
    if git add large-test.bin 2>/dev/null; then
        security_info "Large file added to git"
        
        # Check file size limits
        local file_size=$(stat -c%s large-test.bin 2>/dev/null || stat -f%z large-test.bin 2>/dev/null || echo "0")
        local file_size_mb=$(( file_size / 1024 / 1024 ))
        
        if [[ $file_size_mb -gt 10 ]]; then
            security_medium "Large file ($file_size_mb MB) added to repository"
        else
            security_info "✓ File size within reasonable limits"
        fi
        
        git commit -m "Add large file test" --quiet 2>/dev/null || true
    else
        security_info "✓ Large file rejected by git"
    fi
    
    rm -f large-test.bin
    
    # Test: Sensitive data patterns
    security_info "Testing sensitive data patterns"
    
    local sensitive_data=(
        "Social Security Number: 123-45-6789"
        "Credit Card: 4111-1111-1111-1111"
        "Phone: (555) 123-4567"
        "Email: user@private.com"
    )
    
    for data in "${sensitive_data[@]}"; do
        echo "$data" > sensitive-data.txt
        
        if git add sensitive-data.txt 2>/dev/null; then
            security_medium "Potentially sensitive data added: ${data:0:20}..."
            git commit -m "Sensitive data test" --quiet 2>/dev/null || true
        else
            security_info "✓ Sensitive data rejected"
        fi
        
        rm -f sensitive-data.txt
    done
    
    if [[ "$exfiltration_success" == "true" ]]; then
        security_success "Data exfiltration prevention test passed"
    else
        security_error "Data exfiltration prevention test failed"
        return 1
    fi
}

# Test: Input sanitization bypass attempts
test_input_sanitization_bypass() {
    security_info "Testing input sanitization bypass attempts"
    ((SECURITY_TESTS_RUN++))
    
    local sanitization_success=true
    
    # Test: Encoding bypass attempts
    security_info "Testing encoding bypass attempts"
    
    local encoded_attacks=(
        "%2e%2e%2f"  # ../
        "%3c%73%63%72%69%70%74%3e"  # <script>
        "\\x2e\\x2e\\x2f"  # ../
        "\\u002e\\u002e\\u002f"  # ../
    )
    
    for attack in "${encoded_attacks[@]}"; do
        security_info "Testing encoded attack: $attack"
        
        echo "encoding test" > encoding-test.txt
        git add encoding-test.txt
        
        if git commit -m "$attack" --quiet 2>/dev/null; then
            security_medium "Encoded attack accepted: $attack"
            
            # Check if it's decoded in the log
            local stored_message=$(git log -1 --pretty=format:"%s")
            if [[ "$stored_message" != "$attack" ]]; then
                security_high "Encoded attack may have been decoded: $attack"
                sanitization_success=false
            fi
        else
            security_info "✓ Encoded attack rejected"
        fi
        
        rm -f encoding-test.txt
    done
    
    # Test: Unicode bypass attempts
    security_info "Testing Unicode bypass attempts"
    
    local unicode_attacks=(
        "．．／"  # Fullwidth ../
        "..／"   # Mixed width ../
        "‥∕"    # Alternative dots/slash
    )
    
    for attack in "${unicode_attacks[@]}"; do
        security_info "Testing Unicode attack: $attack"
        
        echo "unicode test" > unicode-test.txt
        git add unicode-test.txt
        
        if git commit -m "$attack" --quiet 2>/dev/null; then
            security_medium "Unicode attack accepted: $attack"
            
            # Check normalization
            local stored_message=$(git log -1 --pretty=format:"%s")
            if [[ "$stored_message" =~ \.\. ]]; then
                security_high "Unicode attack normalized to dangerous pattern"
                sanitization_success=false
            fi
        else
            security_info "✓ Unicode attack rejected"
        fi
        
        rm -f unicode-test.txt
    done
    
    if [[ "$sanitization_success" == "true" ]]; then
        security_success "Input sanitization bypass test passed"
    else
        security_error "Input sanitization bypass test failed"
        return 1
    fi
}

# Generate security test report
generate_security_report() {
    security_info "Generating security test report"
    
    local total_tests=$SECURITY_TESTS_RUN
    local passed_tests=$SECURITY_TESTS_PASSED
    local failed_tests=$SECURITY_TESTS_FAILED
    local critical_vulns=$CRITICAL_VULNERABILITIES
    local high_vulns=$HIGH_VULNERABILITIES
    local medium_vulns=$MEDIUM_VULNERABILITIES
    local success_rate=0
    
    if [[ $total_tests -gt 0 ]]; then
        success_rate=$(( (passed_tests * 100) / total_tests ))
    fi
    
    echo -e "\n${BLUE}=== Security Edge Cases Summary ===${NC}"
    echo -e "Total Tests Run: $total_tests"
    echo -e "${GREEN}Passed: $passed_tests${NC}"
    echo -e "${RED}Failed: $failed_tests${NC}"
    echo -e ""
    echo -e "${RED}🚨 Critical Vulnerabilities: $critical_vulns${NC}"
    echo -e "${MAGENTA}🔴 High Vulnerabilities: $high_vulns${NC}"
    echo -e "${YELLOW}🟡 Medium Vulnerabilities: $medium_vulns${NC}"
    echo -e "Success Rate: ${success_rate}%"
    
    # Determine security status
    if [[ $critical_vulns -gt 0 ]]; then
        security_critical "IMMEDIATE ACTION REQUIRED - Critical vulnerabilities found"
        return 2
    elif [[ $high_vulns -gt 0 ]]; then
        security_high "High-risk vulnerabilities require attention"
        return 1
    elif [[ $failed_tests -gt 0 ]]; then
        security_error "Security tests failed"
        return 1
    else
        security_success "All security edge case tests passed!"
        return 0
    fi
}

# Main execution function
main() {
    security_info "Starting Security Edge Case Testing"
    security_warning "This test suite will attempt to identify security vulnerabilities"
    
    # Setup test environment
    setup_security_tests
    
    # Set up cleanup trap
    trap cleanup_security_tests EXIT
    
    local overall_success=true
    
    # Run all security edge case tests
    security_info "Running security edge case tests..."
    
    test_command_injection_prevention || overall_success=false
    test_credential_exposure || overall_success=false
    test_tool_permissions || overall_success=false
    test_privilege_escalation || overall_success=false
    test_data_exfiltration || overall_success=false
    test_input_sanitization_bypass || overall_success=false
    
    # Generate final report
    local report_exit_code=0
    generate_security_report || report_exit_code=$?
    
    if [[ $report_exit_code -eq 2 ]]; then
        security_error "CRITICAL SECURITY VULNERABILITIES DETECTED"
        exit 2
    elif [[ $report_exit_code -ne 0 ]] || [[ "$overall_success" != "true" ]]; then
        security_error "Security edge case testing completed with failures"
        exit 1
    else
        security_success "Security edge case testing completed successfully"
        exit 0
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi