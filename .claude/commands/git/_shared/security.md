---
description: Git security utilities and compliance checks
---

# Git Security Utilities and Compliance

Comprehensive security utilities for Git repositories, including secret detection, compliance checks, and security best practices enforcement.

## Secret Detection and Prevention

```bash
# Advanced secret detection with multiple pattern libraries
detect_secrets() {
    local scan_target=${1:-"staged"}  # staged, working, history, all
    local severity=${2:-"medium"}     # low, medium, high, critical
    local output_format=${3:-"text"}  # text, json, csv
    
    echo "🔍 Scanning for secrets ($scan_target, severity: $severity)..."
    
    local patterns_file=$(create_secret_patterns)
    local found_secrets=()
    local scan_command=""
    
    case "$scan_target" in
        "staged")
            scan_command="git diff --cached"
            ;;
        "working")
            scan_command="git diff HEAD"
            ;;
        "history")
            scan_command="git log -p --all"
            ;;
        "all")
            scan_command="git ls-files -z | xargs -0 cat"
            ;;
        *)
            echo "ERROR: Invalid scan target: $scan_target"
            return 1
            ;;
    esac
    
    # Run secret detection
    local temp_results=$(mktemp)
    $scan_command | grep -f "$patterns_file" > "$temp_results" 2>/dev/null || true
    
    # Process results based on severity
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            local secret_type=$(classify_secret "$line")
            local secret_severity=$(get_secret_severity "$secret_type")
            
            if should_report_secret "$secret_severity" "$severity"; then
                found_secrets+=("$secret_type:$line")
            fi
        fi
    done < "$temp_results"
    
    # Output results
    if [ ${#found_secrets[@]} -gt 0 ]; then
        case "$output_format" in
            "json")
                output_secrets_json "${found_secrets[@]}"
                ;;
            "csv")
                output_secrets_csv "${found_secrets[@]}"
                ;;
            *)
                output_secrets_text "${found_secrets[@]}"
                ;;
        esac
        
        rm "$temp_results" "$patterns_file"
        return 1
    else
        echo "✅ No secrets detected"
        rm "$temp_results" "$patterns_file"
        return 0
    fi
}

# Create comprehensive secret detection patterns
create_secret_patterns() {
    local patterns_file=$(mktemp)
    
    cat > "$patterns_file" << 'EOF'
# API Keys and Tokens
[Aa][Pp][Ii]_?[Kk][Ee][Yy].*['\"][0-9a-zA-Z]{32,}['\"]
[Aa][Cc][Cc][Ee][Ss][Ss]_?[Tt][Oo][Kk][Ee][Nn].*['\"][0-9a-zA-Z]{32,}['\"]
[Ss][Ee][Cc][Rr][Ee][Tt]_?[Kk][Ee][Yy].*['\"][0-9a-zA-Z]{32,}['\"]
[Bb][Ee][Aa][Rr][Ee][Rr].*['\"][A-Za-z0-9\-\._~\+\/]+=*['\"]

# AWS Credentials
AKIA[0-9A-Z]{16}
aws_access_key_id.*['\"][AKIA][0-9A-Z]{16}['\"]
aws_secret_access_key.*['\"][0-9a-zA-Z\/\+]{40}['\"]
aws_session_token.*['\"][0-9a-zA-Z\/\+]{16,}['\"]

# Google Cloud
private_key.*-----BEGIN PRIVATE KEY-----
client_secret.*['\"][0-9a-zA-Z\-\_]{24}['\"]
service_account.*['\"].*\.json['\"]

# GitHub Tokens
gh[pousr]_[0-9A-Za-z]{36}
github_pat_[0-9A-Za-z_]{82}

# Database URLs
[Pp][Oo][Ss][Tt][Gg][Rr][Ee][Ss].*://.*:.*@.*:.*/.* 
[Mm][Yy][Ss][Qq][Ll].*://.*:.*@.*:.*/.* 
[Mm][Oo][Nn][Gg][Oo][Dd][Bb].*://.*:.*@.*:.*/.* 
redis://.*:.*@.*:.*/.*

# Private Keys
-----BEGIN [A-Z]+ PRIVATE KEY-----
-----BEGIN RSA PRIVATE KEY-----
-----BEGIN DSA PRIVATE KEY-----
-----BEGIN EC PRIVATE KEY-----
-----BEGIN OPENSSH PRIVATE KEY-----

# JWT Tokens
eyJ[A-Za-z0-9\-_]+\.eyJ[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_.+/]*

# Slack Tokens
xox[bpoa]-[0-9]{12}-[0-9]{12}-[0-9a-zA-Z]{24}

# Discord Tokens
[MN][A-Za-z\d]{23}\.[\w-]{6}\.[\w-]{27}
mfa\.[\w-]{84}

# Stripe Keys
sk_live_[0-9a-zA-Z]{24}
pk_live_[0-9a-zA-Z]{24}
rk_live_[0-9a-zA-Z]{24}

# Generic Patterns
[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd].*['\"][^'\"]{8,}['\"]
[Tt][Oo][Kk][Ee][Nn].*['\"][A-Za-z0-9\-\._~\+\/]{20,}['\"]
[Cc][Rr][Ee][Dd][Ee][Nn][Tt][Ii][Aa][Ll].*['\"][^'\"]{10,}['\"]

# Email and Phone (when used as secrets)
['\"][a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}['\"].*[Pp][Aa][Ss][Ss]
['\"][+]?[1-9]\d{1,14}['\"].*[Oo][Tt][Pp]
EOF
    
    echo "$patterns_file"
}

# Classify detected secrets
classify_secret() {
    local secret_line=$1
    
    case "$secret_line" in
        *"AKIA"*) echo "aws_access_key" ;;
        *"aws_secret_access_key"*) echo "aws_secret_key" ;;
        *"-----BEGIN"*"PRIVATE KEY-----"*) echo "private_key" ;;
        *"gh[pousr]_"*) echo "github_token" ;;
        *"xox"*) echo "slack_token" ;;
        *"bearer"*|*"Bearer"*) echo "bearer_token" ;;
        *"api_key"*|*"apikey"*) echo "api_key" ;;
        *"password"*) echo "password" ;;
        *"secret"*) echo "generic_secret" ;;
        *"token"*) echo "generic_token" ;;
        *"jwt"*|*"eyJ"*) echo "jwt_token" ;;
        *) echo "unknown_secret" ;;
    esac
}

# Get severity level for secret type
get_secret_severity() {
    local secret_type=$1
    
    case "$secret_type" in
        "private_key"|"aws_secret_key"|"github_token") echo "critical" ;;
        "aws_access_key"|"api_key"|"bearer_token") echo "high" ;;
        "jwt_token"|"slack_token"|"generic_secret") echo "medium" ;;
        "password"|"generic_token") echo "low" ;;
        *) echo "low" ;;
    esac
}

# Check if secret should be reported based on severity threshold
should_report_secret() {
    local secret_severity=$1
    local threshold=$2
    
    local severity_levels=("low" "medium" "high" "critical")
    local secret_level=0
    local threshold_level=0
    
    for i in "${!severity_levels[@]}"; do
        if [[ "${severity_levels[$i]}" == "$secret_severity" ]]; then
            secret_level=$i
        fi
        if [[ "${severity_levels[$i]}" == "$threshold" ]]; then
            threshold_level=$i
        fi
    done
    
    [ $secret_level -ge $threshold_level ]
}

# Output secrets in text format
output_secrets_text() {
    local secrets=("$@")
    
    echo "🚨 SECURITY ALERT: Secrets detected!"
    echo "=================================="
    
    for secret in "${secrets[@]}"; do
        local type=$(echo "$secret" | cut -d: -f1)
        local content=$(echo "$secret" | cut -d: -f2-)
        local severity=$(get_secret_severity "$type")
        
        echo ""
        echo "Type: $type"
        echo "Severity: $severity"
        echo "Content: ${content:0:50}..."
        echo "---"
    done
    
    echo ""
    echo "⚠️  IMMEDIATE ACTION REQUIRED:"
    echo "1. Remove these secrets from your code"
    echo "2. Rotate/revoke the compromised credentials"
    echo "3. Use environment variables or secure vaults instead"
    echo "4. Consider using git-filter-branch to remove from history"
}

# Output secrets in JSON format
output_secrets_json() {
    local secrets=("$@")
    
    echo "{"
    echo "  \"alert\": \"secrets_detected\","
    echo "  \"timestamp\": \"$(date -Iseconds)\","
    echo "  \"secrets\": ["
    
    local first=true
    for secret in "${secrets[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi
        
        local type=$(echo "$secret" | cut -d: -f1)
        local content=$(echo "$secret" | cut -d: -f2-)
        local severity=$(get_secret_severity "$type")
        
        echo "    {"
        echo "      \"type\": \"$type\","
        echo "      \"severity\": \"$severity\","
        echo "      \"preview\": \"${content:0:30}...\","
        echo "      \"full_match\": \"$content\""
        echo -n "    }"
    done
    
    echo ""
    echo "  ]"
    echo "}"
}
```

## Repository Security Audit

```bash
# Comprehensive security audit
security_audit() {
    local audit_type=${1:-"full"}  # quick, standard, full, compliance
    local output_file=${2:-"security-audit.json"}
    
    echo "🔒 Starting security audit ($audit_type)..."
    
    local audit_results=$(mktemp)
    local timestamp=$(date -Iseconds)
    
    {
        echo "{"
        echo "  \"audit_type\": \"$audit_type\","
        echo "  \"timestamp\": \"$timestamp\","
        echo "  \"repository\": \"$(pwd)\","
        echo "  \"results\": {"
    } > "$audit_results"
    
    # Secret scanning
    echo "    \"secret_scan\": " >> "$audit_results"
    audit_secrets_json >> "$audit_results"
    echo "," >> "$audit_results"
    
    # Permission audit
    echo "    \"permissions\": " >> "$audit_results"
    audit_permissions_json >> "$audit_results"
    echo "," >> "$audit_results"
    
    # Branch protection audit
    echo "    \"branch_protection\": " >> "$audit_results"
    audit_branch_protection_json >> "$audit_results"
    echo "," >> "$audit_results"
    
    # Configuration security
    echo "    \"git_config\": " >> "$audit_results"
    audit_git_config_security_json >> "$audit_results"
    
    if [[ "$audit_type" == "full" || "$audit_type" == "compliance" ]]; then
        echo "," >> "$audit_results"
        
        # History analysis
        echo "    \"history_analysis\": " >> "$audit_results"
        audit_commit_history_json >> "$audit_results"
        echo "," >> "$audit_results"
        
        # Dependency audit
        echo "    \"dependencies\": " >> "$audit_results"
        audit_dependencies_json >> "$audit_results"
    fi
    
    if [ "$audit_type" == "compliance" ]; then
        echo "," >> "$audit_results"
        
        # Compliance checks
        echo "    \"compliance\": " >> "$audit_results"
        audit_compliance_json >> "$audit_results"
    fi
    
    {
        echo "  },"
        echo "  \"summary\": " 
        generate_audit_summary_json
        echo "}"
    } >> "$audit_results"
    
    cp "$audit_results" "$output_file"
    rm "$audit_results"
    
    echo "✅ Security audit complete: $output_file"
    
    # Display summary
    display_audit_summary "$output_file"
}

# Audit secrets and return JSON
audit_secrets_json() {
    local temp_secrets=$(mktemp)
    
    # Scan different areas
    local staged_secrets=$(detect_secrets "staged" "low" "json" 2>/dev/null || echo '{"secrets":[]}')
    local history_secrets=$(detect_secrets "history" "medium" "json" 2>/dev/null || echo '{"secrets":[]}')
    
    echo "{"
    echo "  \"staged_changes\": $staged_secrets,"
    echo "  \"commit_history\": $history_secrets,"
    echo "  \"scan_timestamp\": \"$(date -Iseconds)\""
    echo "}"
}

# Audit file permissions
audit_permissions_json() {
    echo "{"
    echo "  \"executable_files\": ["
    
    local first=true
    git ls-files | while read -r file; do
        if [ -f "$file" ] && [ -x "$file" ]; then
            if [ "$first" = true ]; then
                first=false
            else
                echo ","
            fi
            echo "    \"$file\""
        fi
    done
    
    echo "  ],"
    echo "  \"world_writable\": ["
    
    first=true
    git ls-files | while read -r file; do
        if [ -f "$file" ] && [ -w "$file" ]; then
            local perms=$(stat -c%a "$file" 2>/dev/null || stat -f%Lp "$file" 2>/dev/null)
            if [[ "$perms" =~ .*[2367]$ ]]; then
                if [ "$first" = true ]; then
                    first=false
                else
                    echo ","
                fi
                echo "    {\"file\": \"$file\", \"permissions\": \"$perms\"}"
            fi
        fi
    done
    
    echo "  ]"
    echo "}"
}

# Audit branch protection settings
audit_branch_protection_json() {
    echo "{"
    echo "  \"protected_branches\": ["
    
    if command -v gh &> /dev/null; then
        # Use GitHub CLI if available
        local branches=$(gh api repos/:owner/:repo/branches --jq '.[].name' 2>/dev/null || echo "")
        local first=true
        
        for branch in $branches; do
            local protection=$(gh api "repos/:owner/:repo/branches/$branch/protection" 2>/dev/null || echo "{}")
            
            if [ "$first" = true ]; then
                first=false
            else
                echo ","
            fi
            
            echo "    {"
            echo "      \"name\": \"$branch\","
            echo "      \"protection\": $protection"
            echo "    }"
        done
    fi
    
    echo "  ],"
    echo "  \"local_protection\": {"
    echo "    \"receive_deny_current_branch\": \"$(git config receive.denyCurrentBranch || echo 'not_set')\","
    echo "    \"receive_deny_non_fast_forwards\": \"$(git config receive.denyNonFastForwards || echo 'not_set')\""
    echo "  }"
    echo "}"
}

# Audit Git configuration for security issues
audit_git_config_security_json() {
    echo "{"
    echo "  \"security_settings\": {"
    echo "    \"transfer_fsck_objects\": \"$(git config transfer.fsckObjects || echo 'false')\","
    echo "    \"receive_fsck_objects\": \"$(git config receive.fsckObjects || echo 'false')\","
    echo "    \"fetch_fsck_objects\": \"$(git config fetch.fsckObjects || echo 'false')\""
    echo "  },"
    echo "  \"signing\": {"
    echo "    \"commit_gpg_sign\": \"$(git config commit.gpgsign || echo 'false')\","
    echo "    \"tag_gpg_sign\": \"$(git config tag.gpgsign || echo 'false')\","
    echo "    \"user_signing_key\": \"$(git config user.signingkey || echo 'not_set')\""
    echo "  },"
    echo "  \"credentials\": {"
    echo "    \"credential_helper\": \"$(git config credential.helper || echo 'not_set')\","
    echo "    \"credential_use_http_path\": \"$(git config credential.useHttpPath || echo 'false')\""
    echo "  }"
    echo "}"
}

# Audit commit history for security issues
audit_commit_history_json() {
    local large_files=()
    local suspicious_commits=()
    local unsigned_commits=()
    
    # Find large files in history
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            large_files+=("$line")
        fi
    done < <(git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | awk '/^blob/ {if($3 > 10485760) print $4 " (" $3/1048576 "MB)"}')
    
    # Find commits with suspicious patterns
    while IFS= read -r commit; do
        if [ -n "$commit" ]; then
            local message=$(git log -1 --format=%s "$commit")
            if echo "$message" | grep -iE "(password|secret|key|token|credential)" >/dev/null; then
                suspicious_commits+=("{\"commit\": \"$commit\", \"message\": \"$message\"}")
            fi
        fi
    done < <(git rev-list --all)
    
    # Find unsigned commits (if signing is enabled)
    if [ "$(git config commit.gpgsign)" == "true" ]; then
        while IFS= read -r commit; do
            if [ -n "$commit" ]; then
                if ! git verify-commit "$commit" >/dev/null 2>&1; then
                    unsigned_commits+=("$commit")
                fi
            fi
        done < <(git rev-list --all | head -100)  # Check last 100 commits
    fi
    
    echo "{"
    echo "  \"large_files_in_history\": ["
    printf '%s\n' "${large_files[@]}" | sed 's/.*/"&"/' | paste -sd ',' || true
    echo "  ],"
    echo "  \"suspicious_commits\": ["
    printf '%s\n' "${suspicious_commits[@]}" | paste -sd ',' || true
    echo "  ],"
    echo "  \"unsigned_commits\": ["
    printf '%s\n' "${unsigned_commits[@]}" | sed 's/.*/"&"/' | paste -sd ',' || true
    echo "  ]"
    echo "}"
}

# Audit dependencies for security vulnerabilities
audit_dependencies_json() {
    echo "{"
    
    # Node.js dependencies
    if [ -f "package.json" ]; then
        echo "  \"npm\": {"
        if command -v npm &> /dev/null; then
            local npm_audit=$(npm audit --json 2>/dev/null || echo '{"vulnerabilities":{}}')
            echo "    \"audit_result\": $npm_audit"
        else
            echo "    \"audit_result\": {\"error\": \"npm not available\"}"
        fi
        echo "  },"
    fi
    
    # Python dependencies
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "  \"python\": {"
        if command -v pip &> /dev/null; then
            local safety_check=$(safety check --json 2>/dev/null || echo '[]')
            echo "    \"safety_check\": $safety_check"
        else
            echo "    \"safety_check\": {\"error\": \"pip/safety not available\"}"
        fi
        echo "  },"
    fi
    
    # Remove trailing comma and close
    echo "  \"scan_completed\": true"
    echo "}"
}
```

## Compliance and Policy Enforcement

```bash
# Check compliance with security policies
audit_compliance_json() {
    echo "{"
    echo "  \"policies\": {"
    
    # GDPR compliance checks
    echo "    \"gdpr\": {"
    echo "      \"personal_data_detected\": $(check_personal_data_compliance),"
    echo "      \"data_retention_policy\": \"$(check_data_retention_policy)\""
    echo "    },"
    
    # SOX compliance
    echo "    \"sox\": {"
    echo "      \"change_tracking\": $(check_change_tracking_compliance),"
    echo "      \"segregation_of_duties\": $(check_segregation_compliance)"
    echo "    },"
    
    # HIPAA compliance (if applicable)
    echo "    \"hipaa\": {"
    echo "      \"phi_detected\": $(check_phi_compliance),"
    echo "      \"encryption_required\": $(check_encryption_compliance)"
    echo "    },"
    
    # ISO 27001 compliance
    echo "    \"iso27001\": {"
    echo "      \"access_control\": $(check_access_control_compliance),"
    echo "      \"incident_response\": $(check_incident_response_compliance)"
    echo "    }"
    
    echo "  }"
    echo "}"
}

# Check for personal data (GDPR compliance)
check_personal_data_compliance() {
    local personal_data_patterns=(
        "[0-9]{3}-[0-9]{2}-[0-9]{4}"  # SSN
        "[0-9]{4}[[:space:]]?[0-9]{4}[[:space:]]?[0-9]{4}[[:space:]]?[0-9]{4}"  # Credit card
        "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"  # Email addresses
        "[\+]?[1-9]\d{1,14}"  # Phone numbers
    )
    
    local found=false
    for pattern in "${personal_data_patterns[@]}"; do
        if git ls-files -z | xargs -0 grep -lE "$pattern" >/dev/null 2>&1; then
            found=true
            break
        fi
    done
    
    echo "$found"
}

# Check data retention policy compliance
check_data_retention_policy() {
    # Check if there's a data retention policy file
    if [ -f "DATA_RETENTION_POLICY.md" ] || [ -f "docs/data-retention.md" ]; then
        echo "documented"
    elif git log --grep="retention" --grep="purge" --grep="cleanup" >/dev/null 2>&1; then
        echo "partial"
    else
        echo "missing"
    fi
}

# Check change tracking compliance (SOX)
check_change_tracking_compliance() {
    # Verify that all commits are signed and tracked
    local total_commits=$(git rev-list --count HEAD)
    local signed_commits=0
    
    if [ "$(git config commit.gpgsign)" == "true" ]; then
        signed_commits=$(git rev-list --all | while read commit; do
            if git verify-commit "$commit" >/dev/null 2>&1; then
                echo 1
            fi
        done | wc -l)
        
        local compliance_ratio=$(echo "scale=2; $signed_commits / $total_commits" | bc)
        echo "{\"ratio\": $compliance_ratio, \"total\": $total_commits, \"signed\": $signed_commits}"
    else
        echo "{\"ratio\": 0, \"total\": $total_commits, \"signed\": 0}"
    fi
}

# Check segregation of duties compliance
check_segregation_compliance() {
    # Check if the same person who authored also reviewed/merged
    local violations=0
    local total_merges=0
    
    git log --merges --format="%H %an %cn" | while read commit author committer; do
        ((total_merges++))
        if [ "$author" == "$committer" ]; then
            ((violations++))
        fi
    done
    
    echo "{\"violations\": $violations, \"total_merges\": $total_merges}"
}

# Check for PHI (Protected Health Information)
check_phi_compliance() {
    local phi_patterns=(
        "MRN[[:space:]]*:?[[:space:]]*[0-9]+"  # Medical Record Number
        "DOB[[:space:]]*:?[[:space:]]*[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}"  # Date of Birth
        "SSN[[:space:]]*:?[[:space:]]*[0-9]{3}-[0-9]{2}-[0-9]{4}"  # Social Security Number
    )
    
    local found=false
    for pattern in "${phi_patterns[@]}"; do
        if git ls-files -z | xargs -0 grep -lE "$pattern" >/dev/null 2>&1; then
            found=true
            break
        fi
    done
    
    echo "$found"
}

# Check encryption compliance
check_encryption_compliance() {
    # Check for encryption-related files and configurations
    local encryption_indicators=(
        ".env.encrypted"
        "secrets.yaml.enc"
        "ansible-vault"
        "gpg"
        "ssl"
        "tls"
    )
    
    local has_encryption=false
    for indicator in "${encryption_indicators[@]}"; do
        if git ls-files | grep -i "$indicator" >/dev/null 2>&1; then
            has_encryption=true
            break
        fi
    done
    
    echo "$has_encryption"
}

# Check access control compliance
check_access_control_compliance() {
    # Check for proper access control mechanisms
    local access_control_files=(
        ".github/CODEOWNERS"
        "RBAC.md"
        "ACCESS_CONTROL.md"
        "auth/"
        "authorization/"
    )
    
    local score=0
    for file in "${access_control_files[@]}"; do
        if [ -f "$file" ] || [ -d "$file" ]; then
            ((score++))
        fi
    done
    
    echo "{\"score\": $score, \"max_score\": ${#access_control_files[@]}}"
}

# Check incident response compliance
check_incident_response_compliance() {
    # Check for incident response procedures
    local incident_files=(
        "INCIDENT_RESPONSE.md"
        "SECURITY.md"
        ".github/SECURITY.md"
        "docs/security/"
    )
    
    local has_procedures=false
    for file in "${incident_files[@]}"; do
        if [ -f "$file" ] || [ -d "$file" ]; then
            has_procedures=true
            break
        fi
    done
    
    echo "$has_procedures"
}

# Enforce security policies
enforce_security_policies() {
    local policy_file=${1:-".git/security-policies.json"}
    local enforcement_mode=${2:-"warn"}  # warn, block, audit
    
    if [ ! -f "$policy_file" ]; then
        create_default_security_policies "$policy_file"
    fi
    
    echo "🔒 Enforcing security policies ($enforcement_mode mode)..."
    
    local violations=()
    
    # Load policies
    local require_signed_commits=$(jq -r '.commit_signing.required' "$policy_file" 2>/dev/null || echo "false")
    local max_file_size=$(jq -r '.file_size.max_bytes' "$policy_file" 2>/dev/null || echo "10485760")
    local block_secrets=$(jq -r '.secrets.block_commit' "$policy_file" 2>/dev/null || echo "true")
    
    # Check commit signing policy
    if [ "$require_signed_commits" == "true" ] && [ "$(git config commit.gpgsign)" != "true" ]; then
        violations+=("Commit signing required but not enabled")
    fi
    
    # Check file size policy
    local large_files=$(git diff --cached --name-only | while read file; do
        if [ -f "$file" ]; then
            local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
            if [ "$size" -gt "$max_file_size" ]; then
                echo "$file ($size bytes)"
            fi
        fi
    done)
    
    if [ -n "$large_files" ]; then
        violations+=("Large files detected: $large_files")
    fi
    
    # Check secrets policy
    if [ "$block_secrets" == "true" ]; then
        if ! detect_secrets "staged" "low" "text" >/dev/null 2>&1; then
            violations+=("Secrets detected in staged changes")
        fi
    fi
    
    # Handle violations based on enforcement mode
    if [ ${#violations[@]} -gt 0 ]; then
        case "$enforcement_mode" in
            "block")
                echo "❌ POLICY VIOLATIONS DETECTED - BLOCKING COMMIT:"
                printf '%s\n' "${violations[@]}"
                return 1
                ;;
            "warn")
                echo "⚠️  POLICY VIOLATIONS DETECTED - WARNING:"
                printf '%s\n' "${violations[@]}"
                return 0
                ;;
            "audit")
                echo "📋 POLICY VIOLATIONS LOGGED:"
                printf '%s\n' "${violations[@]}" >> .git/policy-violations.log
                return 0
                ;;
        esac
    else
        echo "✅ All security policies satisfied"
        return 0
    fi
}

# Create default security policies
create_default_security_policies() {
    local policy_file=$1
    
    cat > "$policy_file" << 'EOF'
{
  "version": "1.0",
  "policies": {
    "commit_signing": {
      "required": true,
      "enforcement": "warn"
    },
    "secrets": {
      "block_commit": true,
      "scan_history": true,
      "severity_threshold": "medium"
    },
    "file_size": {
      "max_bytes": 10485760,
      "block_large_files": true
    },
    "branch_protection": {
      "protected_branches": ["main", "master", "develop"],
      "require_pr_reviews": true,
      "dismiss_stale_reviews": true
    },
    "compliance": {
      "gdpr": {
        "enabled": false,
        "scan_personal_data": true
      },
      "sox": {
        "enabled": false,
        "require_change_tracking": true
      },
      "hipaa": {
        "enabled": false,
        "block_phi": true
      }
    }
  }
}
EOF
    
    echo "Default security policies created: $policy_file"
}
```

## Security Monitoring and Alerting

```bash
# Set up security monitoring
setup_security_monitoring() {
    local webhook_url=$1
    local monitoring_level=${2:-"standard"}
    
    echo "🔍 Setting up security monitoring ($monitoring_level level)..."
    
    # Create monitoring configuration
    cat > .git/security-monitor.conf << EOF
# Security monitoring configuration
WEBHOOK_URL="$webhook_url"
MONITORING_LEVEL="$monitoring_level"
ALERT_THRESHOLD="medium"
SCAN_INTERVAL="3600"  # 1 hour
RETENTION_DAYS="30"
EOF
    
    # Create monitoring script
    cat > .git/hooks/security-monitor.sh << 'EOF'
#!/bin/bash
# Security monitoring script

source .git/security-monitor.conf

log_security_event() {
    local event_type=$1
    local severity=$2
    local details=$3
    local timestamp=$(date -Iseconds)
    
    local log_entry="{\"timestamp\":\"$timestamp\",\"type\":\"$event_type\",\"severity\":\"$severity\",\"details\":\"$details\"}"
    
    echo "$log_entry" >> .git/security-events.log
    
    # Send alert if webhook is configured
    if [ -n "$WEBHOOK_URL" ] && [[ "$severity" =~ ^(high|critical)$ ]]; then
        send_security_alert "$event_type" "$severity" "$details"
    fi
}

send_security_alert() {
    local event_type=$1
    local severity=$2
    local details=$3
    local repo=$(basename "$(git rev-parse --show-toplevel)")
    
    local payload=$(cat << EOL
{
    "text": "🚨 Security Alert: $event_type",
    "attachments": [
        {
            "color": "danger",
            "fields": [
                {"title": "Repository", "value": "$repo", "short": true},
                {"title": "Severity", "value": "$severity", "short": true},
                {"title": "Details", "value": "$details", "short": false}
            ]
        }
    ]
}
EOL
)
    
    curl -X POST -H 'Content-type: application/json' \
         --data "$payload" \
         "$WEBHOOK_URL" >/dev/null 2>&1 || true
}

# Main monitoring function
monitor_security() {
    # Check for new secrets
    if ! detect_secrets "working" "medium" "text" >/dev/null 2>&1; then
        log_security_event "secrets_detected" "high" "Secrets found in working directory"
    fi
    
    # Check for suspicious file changes
    local large_changes=$(git diff --name-only | wc -l)
    if [ "$large_changes" -gt 50 ]; then
        log_security_event "large_changeset" "medium" "$large_changes files modified"
    fi
    
    # Check for unusual commit patterns
    local recent_commits=$(git log --since="1 hour ago" --oneline | wc -l)
    if [ "$recent_commits" -gt 10 ]; then
        log_security_event "high_commit_frequency" "medium" "$recent_commits commits in last hour"
    fi
}

# Run monitoring if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    monitor_security
fi
EOF
    
    chmod +x .git/hooks/security-monitor.sh
    
    # Set up cron job for periodic monitoring
    if command -v crontab &> /dev/null; then
        (crontab -l 2>/dev/null; echo "0 * * * * cd $(pwd) && .git/hooks/security-monitor.sh") | crontab -
        echo "✅ Hourly security monitoring scheduled"
    fi
    
    echo "✅ Security monitoring setup complete"
}

# Generate security report
generate_security_report() {
    local output_format=${1:-"html"}
    local output_file=${2:-"security-report"}
    
    case "$output_format" in
        "html")
            generate_security_report_html "$output_file.html"
            ;;
        "json")
            generate_security_report_json "$output_file.json"
            ;;
        "pdf")
            generate_security_report_pdf "$output_file.pdf"
            ;;
        *)
            echo "Supported formats: html, json, pdf"
            return 1
            ;;
    esac
}

# Generate HTML security report
generate_security_report_html() {
    local output_file=$1
    
    cat > "$output_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Git Security Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #f4f4f4; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; }
        .critical { color: #d32f2f; }
        .high { color: #f57c00; }
        .medium { color: #fbc02d; }
        .low { color: #388e3c; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Git Security Report</h1>
        <p>Generated: $(date)</p>
        <p>Repository: $(pwd)</p>
    </div>
EOF
    
    # Add audit results
    security_audit "full" "/tmp/audit-results.json" >/dev/null 2>&1
    
    # Convert JSON to HTML sections
    if [ -f "/tmp/audit-results.json" ]; then
        echo "    <div class=\"section\">" >> "$output_file"
        echo "        <h2>Audit Summary</h2>" >> "$output_file"
        
        # Extract and format key findings
        local secret_count=$(jq '.results.secret_scan.staged_changes.secrets | length' /tmp/audit-results.json 2>/dev/null || echo "0")
        local compliance_score=$(jq '.summary.compliance_score' /tmp/audit-results.json 2>/dev/null || echo "N/A")
        
        cat >> "$output_file" << EOF
        <table>
            <tr><th>Metric</th><th>Value</th><th>Status</th></tr>
            <tr><td>Secrets Detected</td><td>$secret_count</td><td class="$([ "$secret_count" -gt 0 ] && echo "critical" || echo "low")">$([ "$secret_count" -gt 0 ] && echo "CRITICAL" || echo "PASS")</td></tr>
            <tr><td>Compliance Score</td><td>$compliance_score</td><td class="medium">REVIEW</td></tr>
        </table>
EOF
        
        echo "    </div>" >> "$output_file"
        rm -f /tmp/audit-results.json
    fi
    
    cat >> "$output_file" << 'EOF'
    
    <div class="section">
        <h2>Recommendations</h2>
        <ul>
            <li>Enable commit signing for all commits</li>
            <li>Set up branch protection rules</li>
            <li>Regular secret scanning</li>
            <li>Implement security policies</li>
            <li>Enable security monitoring</li>
        </ul>
    </div>
</body>
</html>
EOF
    
    echo "HTML security report generated: $output_file"
}

# Clean up security artifacts
cleanup_security_artifacts() {
    local retention_days=${1:-30}
    
    echo "🧹 Cleaning up security artifacts older than $retention_days days..."
    
    # Clean up log files
    if [ -f ".git/security-events.log" ]; then
        local cutoff_date=$(date -d "$retention_days days ago" +%Y-%m-%d 2>/dev/null || date -v -${retention_days}d +%Y-%m-%d 2>/dev/null)
        if [ -n "$cutoff_date" ]; then
            grep -v "$cutoff_date" .git/security-events.log > .git/security-events.log.tmp 2>/dev/null || true
            mv .git/security-events.log.tmp .git/security-events.log 2>/dev/null || true
        fi
    fi
    
    # Clean up temporary files
    find .git -name "security-*.tmp" -mtime +$retention_days -delete 2>/dev/null || true
    find .git -name "audit-*.json" -mtime +$retention_days -delete 2>/dev/null || true
    
    # Clean up old reports
    find . -name "security-report-*.html" -mtime +$retention_days -delete 2>/dev/null || true
    find . -name "security-audit-*.json" -mtime +$retention_days -delete 2>/dev/null || true
    
    echo "✅ Security artifacts cleanup complete"
}
```

This comprehensive Git security utility provides enterprise-grade security features including secret detection, compliance auditing, policy enforcement, and security monitoring for Git repositories.