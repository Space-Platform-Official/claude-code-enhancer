# Claude Flow Security Guide

## Overview

This guide covers security best practices, configurations, and procedures for securing Claude Flow deployments in various environments.

## Security Architecture

### 1. Security Layers

```
┌─────────────────────────────────────────────────────┐
│                  Network Security                    │
│  ├── Firewalls, IDS/IPS, VPN                       │
├─────────────────────────────────────────────────────┤
│                Application Security                  │
│  ├── Authentication, Authorization, Encryption      │
├─────────────────────────────────────────────────────┤
│                   Data Security                      │
│  ├── Encryption at Rest, in Transit, Key Mgmt      │
├─────────────────────────────────────────────────────┤
│                  System Security                     │
│  ├── OS Hardening, Patch Management, Access Control │
└─────────────────────────────────────────────────────┘
```

### 2. Threat Model

```yaml
threat_model:
  assets:
    - api_keys: "AI service credentials"
    - user_data: "Commands, templates, configurations"
    - system_config: "Installation and settings"
    - audit_logs: "Activity records"
    
  threats:
    - unauthorized_access: "Credential theft, privilege escalation"
    - data_exfiltration: "Stealing sensitive information"
    - code_injection: "Malicious command execution"
    - denial_of_service: "Resource exhaustion"
    - supply_chain: "Compromised dependencies"
    
  mitigations:
    - authentication: "Multi-factor, SSO integration"
    - encryption: "TLS, file encryption"
    - access_control: "RBAC, least privilege"
    - monitoring: "Audit logs, anomaly detection"
    - validation: "Input sanitization, code signing"
```

## Authentication & Authorization

### 1. Authentication Methods

```json
{
  "authentication": {
    "methods": {
      "local": {
        "enabled": false,
        "password_policy": {
          "min_length": 12,
          "require_uppercase": true,
          "require_lowercase": true,
          "require_numbers": true,
          "require_special": true,
          "max_age_days": 90,
          "history_count": 5
        }
      },
      "ldap": {
        "enabled": true,
        "server": "ldaps://ldap.company.com:636",
        "bind_dn": "cn=claude-flow,ou=services,dc=company,dc=com",
        "search_base": "ou=users,dc=company,dc=com",
        "tls": {
          "verify": true,
          "ca_cert": "/etc/claude-flow/certs/ldap-ca.crt"
        }
      },
      "saml": {
        "enabled": true,
        "idp_metadata": "https://sso.company.com/metadata",
        "sp_entity_id": "https://claude-flow.company.com",
        "signature_algorithm": "rsa-sha256"
      },
      "oauth2": {
        "enabled": true,
        "providers": {
          "azure_ad": {
            "client_id": "${AZURE_CLIENT_ID}",
            "tenant_id": "${AZURE_TENANT_ID}",
            "redirect_uri": "https://claude-flow.company.com/auth/callback"
          }
        }
      }
    },
    "mfa": {
      "required": true,
      "methods": ["totp", "webauthn", "sms"]
    }
  }
}
```

### 2. Authorization Configuration

```python
#!/usr/bin/env python3
# rbac_config.py

from enum import Enum
from typing import List, Dict

class Permission(Enum):
    # Command permissions
    COMMAND_CREATE = "command.create"
    COMMAND_READ = "command.read"
    COMMAND_UPDATE = "command.update"
    COMMAND_DELETE = "command.delete"
    COMMAND_EXECUTE = "command.execute"
    
    # Template permissions
    TEMPLATE_CREATE = "template.create"
    TEMPLATE_READ = "template.read"
    TEMPLATE_UPDATE = "template.update"
    TEMPLATE_DELETE = "template.delete"
    
    # System permissions
    SYSTEM_CONFIG = "system.config"
    SYSTEM_UPDATE = "system.update"
    SYSTEM_AUDIT = "system.audit"
    
    # User management
    USER_CREATE = "user.create"
    USER_UPDATE = "user.update"
    USER_DELETE = "user.delete"

class Role:
    def __init__(self, name: str, permissions: List[Permission]):
        self.name = name
        self.permissions = permissions
    
    def has_permission(self, permission: Permission) -> bool:
        return permission in self.permissions

# Define roles
ROLES = {
    'admin': Role('admin', list(Permission)),  # All permissions
    
    'developer': Role('developer', [
        Permission.COMMAND_CREATE,
        Permission.COMMAND_READ,
        Permission.COMMAND_UPDATE,
        Permission.COMMAND_EXECUTE,
        Permission.TEMPLATE_CREATE,
        Permission.TEMPLATE_READ,
        Permission.TEMPLATE_UPDATE
    ]),
    
    'user': Role('user', [
        Permission.COMMAND_READ,
        Permission.COMMAND_EXECUTE,
        Permission.TEMPLATE_READ
    ]),
    
    'auditor': Role('auditor', [
        Permission.COMMAND_READ,
        Permission.TEMPLATE_READ,
        Permission.SYSTEM_AUDIT
    ])
}

class AuthorizationManager:
    def __init__(self):
        self.user_roles: Dict[str, List[str]] = {}
        self.role_mappings = self.load_role_mappings()
    
    def load_role_mappings(self):
        """Load LDAP group to role mappings"""
        return {
            'cn=claude-admins,ou=groups,dc=company,dc=com': 'admin',
            'cn=developers,ou=groups,dc=company,dc=com': 'developer',
            'cn=claude-users,ou=groups,dc=company,dc=com': 'user',
            'cn=auditors,ou=groups,dc=company,dc=com': 'auditor'
        }
    
    def authorize(self, user: str, permission: Permission) -> bool:
        """Check if user has permission"""
        user_roles = self.user_roles.get(user, [])
        
        for role_name in user_roles:
            role = ROLES.get(role_name)
            if role and role.has_permission(permission):
                return True
        
        return False
    
    def get_user_permissions(self, user: str) -> List[Permission]:
        """Get all permissions for user"""
        permissions = set()
        user_roles = self.user_roles.get(user, [])
        
        for role_name in user_roles:
            role = ROLES.get(role_name)
            if role:
                permissions.update(role.permissions)
        
        return list(permissions)

# Policy enforcement decorator
def require_permission(permission: Permission):
    def decorator(func):
        def wrapper(self, user, *args, **kwargs):
            auth_manager = AuthorizationManager()
            if not auth_manager.authorize(user, permission):
                raise PermissionError(f"User {user} lacks permission: {permission.value}")
            return func(self, user, *args, **kwargs)
        return wrapper
    return decorator

# Example usage
class CommandManager:
    @require_permission(Permission.COMMAND_CREATE)
    def create_command(self, user: str, command_data: dict):
        """Create new command - requires permission"""
        pass
    
    @require_permission(Permission.COMMAND_EXECUTE)
    def execute_command(self, user: str, command_name: str):
        """Execute command - requires permission"""
        pass
```

### 3. Session Management

```python
#!/usr/bin/env python3
# session_manager.py

import secrets
import time
import json
from datetime import datetime, timedelta
from typing import Optional

class SessionManager:
    def __init__(self, redis_client=None):
        self.redis = redis_client
        self.session_timeout = 3600  # 1 hour
        self.max_sessions_per_user = 5
    
    def create_session(self, user_id: str, ip_address: str, user_agent: str) -> str:
        """Create new session for user"""
        # Check session limit
        existing_sessions = self.get_user_sessions(user_id)
        if len(existing_sessions) >= self.max_sessions_per_user:
            # Remove oldest session
            self.revoke_session(existing_sessions[0]['session_id'])
        
        # Generate secure session ID
        session_id = secrets.token_urlsafe(32)
        
        session_data = {
            'user_id': user_id,
            'session_id': session_id,
            'created_at': datetime.utcnow().isoformat(),
            'last_activity': datetime.utcnow().isoformat(),
            'ip_address': ip_address,
            'user_agent': user_agent,
            'active': True
        }
        
        # Store in Redis with expiration
        self.redis.setex(
            f"session:{session_id}",
            self.session_timeout,
            json.dumps(session_data)
        )
        
        # Add to user's session list
        self.redis.sadd(f"user_sessions:{user_id}", session_id)
        
        return session_id
    
    def validate_session(self, session_id: str) -> Optional[dict]:
        """Validate and refresh session"""
        session_data = self.redis.get(f"session:{session_id}")
        
        if not session_data:
            return None
        
        session = json.loads(session_data)
        
        # Check if session is active
        if not session.get('active'):
            return None
        
        # Update last activity
        session['last_activity'] = datetime.utcnow().isoformat()
        
        # Extend session
        self.redis.setex(
            f"session:{session_id}",
            self.session_timeout,
            json.dumps(session)
        )
        
        return session
    
    def revoke_session(self, session_id: str):
        """Revoke a session"""
        session_data = self.redis.get(f"session:{session_id}")
        if session_data:
            session = json.loads(session_data)
            user_id = session['user_id']
            
            # Mark as inactive
            session['active'] = False
            session['revoked_at'] = datetime.utcnow().isoformat()
            
            # Store for audit trail
            self.redis.setex(
                f"session:revoked:{session_id}",
                86400 * 7,  # Keep for 7 days
                json.dumps(session)
            )
            
            # Remove from active sessions
            self.redis.delete(f"session:{session_id}")
            self.redis.srem(f"user_sessions:{user_id}", session_id)
    
    def revoke_all_sessions(self, user_id: str):
        """Revoke all sessions for a user"""
        sessions = self.get_user_sessions(user_id)
        for session in sessions:
            self.revoke_session(session['session_id'])
    
    def get_user_sessions(self, user_id: str) -> list:
        """Get all active sessions for user"""
        session_ids = self.redis.smembers(f"user_sessions:{user_id}")
        sessions = []
        
        for session_id in session_ids:
            session_data = self.redis.get(f"session:{session_id}")
            if session_data:
                sessions.append(json.loads(session_data))
        
        return sorted(sessions, key=lambda x: x['created_at'])
```

## Encryption

### 1. Data Encryption

```python
#!/usr/bin/env python3
# encryption_manager.py

import os
import base64
import json
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives.ciphers.aead import ChaCha20Poly1305

class EncryptionManager:
    def __init__(self, master_key_path='/etc/claude-flow/master.key'):
        self.master_key = self.load_or_generate_master_key(master_key_path)
        self.fernet = Fernet(self.master_key)
    
    def load_or_generate_master_key(self, key_path):
        """Load or generate master encryption key"""
        if os.path.exists(key_path):
            with open(key_path, 'rb') as f:
                return f.read()
        else:
            # Generate new key
            key = Fernet.generate_key()
            
            # Secure file permissions
            os.makedirs(os.path.dirname(key_path), exist_ok=True)
            
            # Write with restrictive permissions
            with os.open(key_path, os.O_CREAT | os.O_WRONLY, 0o600) as fd:
                os.write(fd, key)
            
            return key
    
    def encrypt_file(self, file_path: str):
        """Encrypt file in place"""
        with open(file_path, 'rb') as f:
            data = f.read()
        
        encrypted = self.fernet.encrypt(data)
        
        # Write encrypted data
        with open(f"{file_path}.enc", 'wb') as f:
            f.write(encrypted)
        
        # Securely delete original
        self.secure_delete(file_path)
        
        return f"{file_path}.enc"
    
    def decrypt_file(self, encrypted_path: str) -> bytes:
        """Decrypt file and return contents"""
        with open(encrypted_path, 'rb') as f:
            encrypted_data = f.read()
        
        return self.fernet.decrypt(encrypted_data)
    
    def encrypt_api_key(self, api_key: str) -> str:
        """Encrypt API key for storage"""
        encrypted = self.fernet.encrypt(api_key.encode())
        return base64.urlsafe_b64encode(encrypted).decode()
    
    def decrypt_api_key(self, encrypted_key: str) -> str:
        """Decrypt API key for use"""
        encrypted = base64.urlsafe_b64decode(encrypted_key.encode())
        return self.fernet.decrypt(encrypted).decode()
    
    def secure_delete(self, file_path: str):
        """Securely overwrite and delete file"""
        if not os.path.exists(file_path):
            return
        
        filesize = os.path.getsize(file_path)
        
        with open(file_path, 'rb+') as f:
            # Overwrite with random data 3 times
            for _ in range(3):
                f.seek(0)
                f.write(os.urandom(filesize))
                f.flush()
                os.fsync(f.fileno())
        
        os.remove(file_path)
    
    def encrypt_config(self, config_dict: dict) -> str:
        """Encrypt configuration dictionary"""
        json_str = json.dumps(config_dict)
        encrypted = self.fernet.encrypt(json_str.encode())
        return base64.urlsafe_b64encode(encrypted).decode()
    
    def decrypt_config(self, encrypted_config: str) -> dict:
        """Decrypt configuration dictionary"""
        encrypted = base64.urlsafe_b64decode(encrypted_config.encode())
        json_str = self.fernet.decrypt(encrypted).decode()
        return json.loads(json_str)

class KeyRotationManager:
    def __init__(self, encryption_manager: EncryptionManager):
        self.encryption_manager = encryption_manager
        self.rotation_period_days = 90
    
    def rotate_master_key(self):
        """Rotate master encryption key"""
        # Generate new key
        new_key = Fernet.generate_key()
        new_fernet = Fernet(new_key)
        
        # Re-encrypt all encrypted data
        encrypted_files = self.find_encrypted_files()
        
        for file_path in encrypted_files:
            # Decrypt with old key
            data = self.encryption_manager.decrypt_file(file_path)
            
            # Encrypt with new key
            encrypted = new_fernet.encrypt(data)
            
            with open(file_path, 'wb') as f:
                f.write(encrypted)
        
        # Update master key
        self.encryption_manager.master_key = new_key
        self.encryption_manager.fernet = new_fernet
        
        # Save new key
        with os.open('/etc/claude-flow/master.key', os.O_WRONLY | os.O_TRUNC, 0o600) as fd:
            os.write(fd, new_key)
        
        # Log rotation
        self.log_key_rotation()
    
    def find_encrypted_files(self) -> list:
        """Find all encrypted files"""
        encrypted_files = []
        
        search_paths = [
            '/opt/claude-flow/config',
            '/home/*/.claude/config'
        ]
        
        for path_pattern in search_paths:
            import glob
            for file_path in glob.glob(f"{path_pattern}/**/*.enc", recursive=True):
                encrypted_files.append(file_path)
        
        return encrypted_files
```

### 2. TLS Configuration

```nginx
# nginx-tls.conf
server {
    listen 443 ssl http2;
    server_name claude-flow.company.com;
    
    # TLS certificates
    ssl_certificate /etc/nginx/ssl/claude-flow.crt;
    ssl_certificate_key /etc/nginx/ssl/claude-flow.key;
    
    # TLS configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    
    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/nginx/ssl/ca-bundle.crt;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Certificate pinning
    add_header Public-Key-Pins 'pin-sha256="base64+primary=="; pin-sha256="base64+backup=="; max-age=5184000; includeSubDomains' always;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. Certificate Management

```bash
#!/bin/bash
# cert_manager.sh

CERT_DIR="/etc/claude-flow/certs"
DAYS_WARNING=30

check_certificate_expiry() {
    local cert_file=$1
    local cert_name=$(basename "$cert_file" .crt)
    
    if [ ! -f "$cert_file" ]; then
        echo "Certificate not found: $cert_file"
        return 1
    fi
    
    # Get expiry date
    expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate | cut -d= -f2)
    expiry_epoch=$(date -d "$expiry_date" +%s)
    current_epoch=$(date +%s)
    days_until_expiry=$(( (expiry_epoch - current_epoch) / 86400 ))
    
    echo "Certificate: $cert_name"
    echo "Expires: $expiry_date"
    echo "Days until expiry: $days_until_expiry"
    
    if [ $days_until_expiry -lt 0 ]; then
        echo "STATUS: EXPIRED"
        return 2
    elif [ $days_until_expiry -lt $DAYS_WARNING ]; then
        echo "STATUS: EXPIRING SOON"
        return 3
    else
        echo "STATUS: OK"
        return 0
    fi
}

renew_certificate() {
    local domain=$1
    
    echo "Renewing certificate for: $domain"
    
    # Using Let's Encrypt
    certbot certonly \
        --nginx \
        --non-interactive \
        --agree-tos \
        --email security@company.com \
        --domains "$domain" \
        --deploy-hook "/usr/local/bin/claude-flow-cert-deploy.sh"
}

# Certificate deployment hook
deploy_certificate() {
    local domain=$1
    local cert_path="/etc/letsencrypt/live/$domain"
    
    # Copy certificates
    cp "$cert_path/fullchain.pem" "$CERT_DIR/$domain.crt"
    cp "$cert_path/privkey.pem" "$CERT_DIR/$domain.key"
    
    # Set permissions
    chmod 644 "$CERT_DIR/$domain.crt"
    chmod 600 "$CERT_DIR/$domain.key"
    chown claude-flow:claude-flow "$CERT_DIR"/*
    
    # Reload services
    systemctl reload nginx
    systemctl reload claude-flow
}

# Check all certificates
echo "=== Certificate Status Check ==="
for cert in "$CERT_DIR"/*.crt; do
    check_certificate_expiry "$cert"
    echo "---"
done

# Auto-renewal cron job
cat > /etc/cron.d/claude-flow-certs << EOF
# Check certificates daily
0 2 * * * root /opt/claude-flow/scripts/cert_manager.sh check
# Attempt renewal weekly
0 3 * * 0 root certbot renew --quiet --deploy-hook /usr/local/bin/claude-flow-cert-deploy.sh
EOF
```

## Access Control

### 1. File System Permissions

```bash
#!/bin/bash
# set_permissions.sh

# System directories
chmod 755 /opt/claude-flow
chmod 755 /opt/claude-flow/bin
chmod 644 /opt/claude-flow/bin/*
chmod 755 /opt/claude-flow/bin/claude-flow

# Configuration (restricted)
chmod 750 /opt/claude-flow/config
chmod 640 /opt/claude-flow/config/*
chmod 600 /opt/claude-flow/config/api-keys.json

# Shared resources
chmod 755 /opt/claude-flow/shared
chmod 755 /opt/claude-flow/shared/templates
chmod 644 /opt/claude-flow/shared/templates/*

# Logs (write for service, read for auditors)
chmod 750 /var/log/claude-flow
chmod 640 /var/log/claude-flow/*.log

# User directories
find /home -name ".claude" -type d -exec chmod 700 {} \;
find /home -path "*/.claude/config" -type d -exec chmod 700 {} \;
find /home -path "*/.claude/config/*" -type f -exec chmod 600 {} \;

# Set ownership
chown -R root:claude-flow /opt/claude-flow
chown -R claude-flow:claude-flow /var/log/claude-flow

# SELinux contexts (if enabled)
if command -v semanage &> /dev/null; then
    semanage fcontext -a -t claude_flow_exec_t '/opt/claude-flow/bin(/.*)?'
    semanage fcontext -a -t claude_flow_config_t '/opt/claude-flow/config(/.*)?'
    semanage fcontext -a -t claude_flow_log_t '/var/log/claude-flow(/.*)?'
    restorecon -Rv /opt/claude-flow /var/log/claude-flow
fi
```

### 2. Network Security

```yaml
# firewall-rules.yml
firewall_rules:
  ingress:
    - name: "HTTPS"
      port: 443
      protocol: tcp
      source: "0.0.0.0/0"
      
    - name: "SSH (restricted)"
      port: 22
      protocol: tcp
      source: "10.0.0.0/8"  # Internal only
      
    - name: "Monitoring"
      port: 9090
      protocol: tcp
      source: "10.1.2.0/24"  # Monitoring subnet
      
  egress:
    - name: "AI APIs"
      port: 443
      protocol: tcp
      destination: "api.openai.com"
      
    - name: "Updates"
      port: 443
      protocol: tcp
      destination: "github.com"
      
    - name: "LDAP"
      port: 636
      protocol: tcp
      destination: "ldap.company.com"
      
  deny_all_else: true
```

### 3. Container Security

```dockerfile
# Dockerfile.secure
FROM alpine:3.18

# Non-root user
RUN addgroup -g 1000 claude && \
    adduser -u 1000 -G claude -s /bin/sh -D claude

# Install dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    git \
    && rm -rf /var/cache/apk/*

# Copy application
COPY --chown=claude:claude . /app

# Set up environment
WORKDIR /app
USER claude

# Security scanning
RUN pip install --user safety bandit
RUN safety check
RUN bandit -r . -f json -o /tmp/bandit-report.json

# Read-only root filesystem
RUN chmod -R a-w /app

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python3 /app/healthcheck.py || exit 1

# Run as non-root
ENTRYPOINT ["python3", "/app/claude-flow.py"]

# Security labels
LABEL security.scan="passed" \
      security.user="non-root" \
      security.readonly="true"
```

## Audit & Compliance

### 1. Audit Logging

```python
#!/usr/bin/env python3
# audit_logger.py

import json
import time
import hashlib
from datetime import datetime
from typing import Any, Dict
import syslog

class AuditLogger:
    def __init__(self, log_file='/var/log/claude-flow/audit.log'):
        self.log_file = log_file
        self.syslog_enabled = True
        
        # Initialize syslog
        if self.syslog_enabled:
            syslog.openlog("claude-flow", syslog.LOG_PID, syslog.LOG_LOCAL0)
    
    def log_event(self, event_type: str, user: str, details: Dict[str, Any]):
        """Log security event"""
        event = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            'user': user,
            'details': details,
            'session_id': details.get('session_id'),
            'ip_address': details.get('ip_address'),
            'user_agent': details.get('user_agent'),
            'hash': None  # Will be calculated
        }
        
        # Calculate event hash for integrity
        event_str = json.dumps(event, sort_keys=True)
        event['hash'] = hashlib.sha256(event_str.encode()).hexdigest()
        
        # Write to file
        with open(self.log_file, 'a') as f:
            f.write(json.dumps(event) + '\n')
        
        # Send to syslog
        if self.syslog_enabled:
            severity = self.get_severity(event_type)
            syslog.syslog(severity, json.dumps(event))
        
        # Real-time alerting for critical events
        if self.is_critical_event(event_type):
            self.send_alert(event)
    
    def get_severity(self, event_type: str) -> int:
        """Map event type to syslog severity"""
        severity_map = {
            'auth.failed': syslog.LOG_WARNING,
            'auth.success': syslog.LOG_INFO,
            'permission.denied': syslog.LOG_WARNING,
            'config.changed': syslog.LOG_NOTICE,
            'command.executed': syslog.LOG_INFO,
            'security.violation': syslog.LOG_CRIT,
            'data.accessed': syslog.LOG_INFO,
            'data.modified': syslog.LOG_NOTICE,
            'system.error': syslog.LOG_ERR
        }
        return severity_map.get(event_type, syslog.LOG_INFO)
    
    def is_critical_event(self, event_type: str) -> bool:
        """Check if event requires immediate alerting"""
        critical_events = [
            'security.violation',
            'auth.brute_force',
            'privilege.escalation',
            'data.exfiltration',
            'config.unauthorized_change'
        ]
        return event_type in critical_events
    
    def send_alert(self, event: dict):
        """Send real-time security alert"""
        # Implementation depends on alerting system
        # Could be email, Slack, PagerDuty, etc.
        pass

class ComplianceReporter:
    def __init__(self, audit_log_path='/var/log/claude-flow/audit.log'):
        self.audit_log_path = audit_log_path
    
    def generate_compliance_report(self, start_date, end_date, compliance_framework='SOC2'):
        """Generate compliance report for specified period"""
        events = self.load_events(start_date, end_date)
        
        report = {
            'framework': compliance_framework,
            'period': {
                'start': start_date.isoformat(),
                'end': end_date.isoformat()
            },
            'summary': self.generate_summary(events),
            'controls': self.evaluate_controls(events, compliance_framework),
            'incidents': self.identify_incidents(events),
            'recommendations': self.generate_recommendations(events)
        }
        
        return report
    
    def evaluate_controls(self, events, framework):
        """Evaluate compliance controls"""
        if framework == 'SOC2':
            return self.evaluate_soc2_controls(events)
        elif framework == 'ISO27001':
            return self.evaluate_iso27001_controls(events)
        elif framework == 'HIPAA':
            return self.evaluate_hipaa_controls(events)
        else:
            raise ValueError(f"Unknown framework: {framework}")
    
    def evaluate_soc2_controls(self, events):
        """Evaluate SOC2 controls"""
        controls = {
            'CC6.1': {  # Logical and Physical Access Controls
                'description': 'Logical access security software, infrastructure, and architectures',
                'status': 'implemented',
                'evidence': []
            },
            'CC6.2': {  # User Registration and Authorization
                'description': 'Prior to issuing system credentials and granting system access',
                'status': 'implemented',
                'evidence': []
            },
            'CC6.3': {  # User Authentication
                'description': 'The entity authorizes, modifies, or removes access',
                'status': 'implemented',
                'evidence': []
            },
            'CC7.2': {  # System Monitoring
                'description': 'The entity monitors system components',
                'status': 'implemented',
                'evidence': []
            }
        }
        
        # Evaluate based on events
        for event in events:
            if event['event_type'].startswith('auth.'):
                controls['CC6.3']['evidence'].append(event)
            elif event['event_type'].startswith('permission.'):
                controls['CC6.2']['evidence'].append(event)
            elif event['event_type'] == 'system.monitoring':
                controls['CC7.2']['evidence'].append(event)
        
        return controls
```

### 2. Security Scanning

```bash
#!/bin/bash
# security_scan.sh

SCAN_DIR="/opt/claude-flow"
REPORT_DIR="/var/log/claude-flow/security-scans"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$REPORT_DIR"

echo "=== Claude Flow Security Scan ==="
echo "Timestamp: $(date)"
echo "Scan directory: $SCAN_DIR"

# 1. Dependency scanning
echo -e "\n[1/5] Scanning dependencies..."
if command -v safety &> /dev/null; then
    safety check --json > "$REPORT_DIR/safety-$TIMESTAMP.json"
    echo "Safety scan complete"
fi

# 2. Static code analysis
echo -e "\n[2/5] Running static analysis..."
if command -v bandit &> /dev/null; then
    bandit -r "$SCAN_DIR" -f json -o "$REPORT_DIR/bandit-$TIMESTAMP.json"
    echo "Bandit scan complete"
fi

# 3. Vulnerability scanning
echo -e "\n[3/5] Scanning for vulnerabilities..."
if command -v trivy &> /dev/null; then
    trivy fs --security-checks vuln,config "$SCAN_DIR" \
        --format json \
        --output "$REPORT_DIR/trivy-$TIMESTAMP.json"
    echo "Trivy scan complete"
fi

# 4. Configuration audit
echo -e "\n[4/5] Auditing configuration..."
python3 << EOF
import json
import os

issues = []

# Check file permissions
sensitive_files = [
    '/opt/claude-flow/config/api-keys.json',
    '/etc/claude-flow/master.key'
]

for file_path in sensitive_files:
    if os.path.exists(file_path):
        stat = os.stat(file_path)
        if stat.st_mode & 0o077:
            issues.append({
                'type': 'permission',
                'file': file_path,
                'issue': 'File has excessive permissions'
            })

# Check for hardcoded secrets
import re
secret_patterns = [
    r'api[_-]?key\s*=\s*["\'][^"\']+["\']',
    r'password\s*=\s*["\'][^"\']+["\']',
    r'secret\s*=\s*["\'][^"\']+["\']'
]

for root, dirs, files in os.walk('$SCAN_DIR'):
    for file in files:
        if file.endswith(('.py', '.json', '.conf')):
            file_path = os.path.join(root, file)
            try:
                with open(file_path, 'r') as f:
                    content = f.read()
                    for pattern in secret_patterns:
                        if re.search(pattern, content, re.IGNORECASE):
                            issues.append({
                                'type': 'secret',
                                'file': file_path,
                                'issue': 'Potential hardcoded secret'
                            })
            except:
                pass

with open('$REPORT_DIR/config-audit-$TIMESTAMP.json', 'w') as f:
    json.dump(issues, f, indent=2)

print(f"Found {len(issues)} configuration issues")
EOF

# 5. Network security check
echo -e "\n[5/5] Checking network security..."
ss -tlnp | grep -E ':(22|443|8080|9090)' > "$REPORT_DIR/listening-ports-$TIMESTAMP.txt"

# Generate summary report
echo -e "\n=== Security Scan Summary ==="
python3 << EOF
import json
import glob

report_files = glob.glob('$REPORT_DIR/*-$TIMESTAMP.*')
total_issues = 0

for report_file in report_files:
    if report_file.endswith('.json'):
        try:
            with open(report_file) as f:
                data = json.load(f)
                if isinstance(data, list):
                    issues = len(data)
                elif isinstance(data, dict) and 'vulnerabilities' in data:
                    issues = len(data['vulnerabilities'])
                else:
                    issues = 0
                total_issues += issues
                print(f"{report_file}: {issues} issues")
        except:
            pass

print(f"\nTotal issues found: {total_issues}")

# Create summary
summary = {
    'scan_date': '$TIMESTAMP',
    'total_issues': total_issues,
    'reports': report_files
}

with open('$REPORT_DIR/summary-$TIMESTAMP.json', 'w') as f:
    json.dump(summary, f, indent=2)
EOF

echo -e "\nScan complete. Reports saved to: $REPORT_DIR"

# Alert on critical findings
if [ -f "$REPORT_DIR/summary-$TIMESTAMP.json" ]; then
    CRITICAL_COUNT=$(jq '.total_issues' "$REPORT_DIR/summary-$TIMESTAMP.json")
    if [ "$CRITICAL_COUNT" -gt 0 ]; then
        echo "ALERT: Security scan found $CRITICAL_COUNT issues!"
        # Send notification
    fi
fi
```

### 3. Compliance Automation

```python
#!/usr/bin/env python3
# compliance_automation.py

import schedule
import time
from datetime import datetime, timedelta

class ComplianceAutomation:
    def __init__(self):
        self.configure_scheduled_tasks()
    
    def configure_scheduled_tasks(self):
        """Configure automated compliance tasks"""
        
        # Daily tasks
        schedule.every().day.at("02:00").do(self.daily_security_scan)
        schedule.every().day.at("03:00").do(self.backup_audit_logs)
        schedule.every().day.at("04:00").do(self.check_certificate_expiry)
        
        # Weekly tasks
        schedule.every().monday.at("05:00").do(self.weekly_access_review)
        schedule.every().wednesday.at("05:00").do(self.vulnerability_assessment)
        
        # Monthly tasks
        schedule.every().month.do(self.monthly_compliance_report)
        schedule.every().month.do(self.password_policy_audit)
        
        # Quarterly tasks
        schedule.every(3).months.do(self.security_training_reminder)
        schedule.every(3).months.do(self.disaster_recovery_test)
    
    def daily_security_scan(self):
        """Run daily security scans"""
        print(f"[{datetime.now()}] Running daily security scan...")
        
        # Run security scanning script
        import subprocess
        result = subprocess.run(['/opt/claude-flow/scripts/security_scan.sh'], 
                              capture_output=True)
        
        if result.returncode != 0:
            self.send_alert("Daily security scan failed", result.stderr.decode())
    
    def weekly_access_review(self):
        """Review user access and permissions"""
        print(f"[{datetime.now()}] Running weekly access review...")
        
        # Query user permissions
        inactive_users = self.find_inactive_users(days=90)
        excessive_permissions = self.find_excessive_permissions()
        
        if inactive_users or excessive_permissions:
            report = {
                'date': datetime.now().isoformat(),
                'inactive_users': inactive_users,
                'excessive_permissions': excessive_permissions
            }
            
            self.send_access_review_report(report)
    
    def monthly_compliance_report(self):
        """Generate monthly compliance report"""
        print(f"[{datetime.now()}] Generating monthly compliance report...")
        
        end_date = datetime.now()
        start_date = end_date - timedelta(days=30)
        
        reporter = ComplianceReporter()
        report = reporter.generate_compliance_report(start_date, end_date)
        
        # Save report
        report_path = f"/var/log/claude-flow/compliance/monthly-{end_date.strftime('%Y%m')}.json"
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        # Send to stakeholders
        self.send_compliance_report(report)
    
    def run(self):
        """Run compliance automation"""
        print("Starting compliance automation...")
        
        while True:
            schedule.run_pending()
            time.sleep(60)  # Check every minute

if __name__ == '__main__':
    automation = ComplianceAutomation()
    automation.run()
```

## Incident Response

### 1. Incident Response Plan

```yaml
# incident_response_plan.yml
incident_response:
  team:
    incident_commander: "security-lead@company.com"
    technical_lead: "tech-lead@company.com"
    communications: "pr@company.com"
    legal: "legal@company.com"
    
  severity_levels:
    critical:
      description: "Data breach, system compromise, ransomware"
      response_time: "15 minutes"
      escalation: "immediate"
      
    high:
      description: "Attempted breach, suspicious activity"
      response_time: "1 hour"
      escalation: "2 hours"
      
    medium:
      description: "Policy violation, failed authentication spike"
      response_time: "4 hours"
      escalation: "24 hours"
      
    low:
      description: "Minor policy violation, false positive"
      response_time: "24 hours"
      escalation: "48 hours"
      
  procedures:
    detection:
      - Monitor security alerts
      - Analyze audit logs
      - User reports
      
    containment:
      - Isolate affected systems
      - Disable compromised accounts
      - Block malicious IPs
      
    eradication:
      - Remove malware
      - Patch vulnerabilities
      - Reset credentials
      
    recovery:
      - Restore from backups
      - Verify system integrity
      - Resume normal operations
      
    lessons_learned:
      - Document timeline
      - Identify root cause
      - Update procedures
```

### 2. Automated Response

```python
#!/usr/bin/env python3
# incident_response.py

import json
import subprocess
from datetime import datetime
from enum import Enum

class IncidentSeverity(Enum):
    CRITICAL = "critical"
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"

class IncidentResponder:
    def __init__(self):
        self.response_actions = {
            'brute_force_attack': self.respond_to_brute_force,
            'data_exfiltration': self.respond_to_data_exfiltration,
            'privilege_escalation': self.respond_to_privilege_escalation,
            'malware_detected': self.respond_to_malware,
            'unauthorized_access': self.respond_to_unauthorized_access
        }
    
    def detect_incident(self, event):
        """Detect potential security incident from event"""
        
        # Brute force detection
        if event['event_type'] == 'auth.failed':
            if self.is_brute_force(event['user'], event['ip_address']):
                return 'brute_force_attack', IncidentSeverity.HIGH
        
        # Data exfiltration detection
        if event['event_type'] == 'data.accessed':
            if self.is_excessive_data_access(event):
                return 'data_exfiltration', IncidentSeverity.CRITICAL
        
        # Privilege escalation detection
        if event['event_type'] == 'permission.elevated':
            if not self.is_authorized_elevation(event):
                return 'privilege_escalation', IncidentSeverity.CRITICAL
        
        return None, None
    
    def respond_to_incident(self, incident_type, severity, event):
        """Orchestrate incident response"""
        
        incident_id = self.create_incident_record(incident_type, severity, event)
        
        # Execute immediate response
        if incident_type in self.response_actions:
            self.response_actions[incident_type](event, incident_id)
        
        # Notify incident response team
        self.notify_team(incident_id, incident_type, severity)
        
        # Create forensic snapshot
        if severity in [IncidentSeverity.CRITICAL, IncidentSeverity.HIGH]:
            self.create_forensic_snapshot(incident_id)
        
        return incident_id
    
    def respond_to_brute_force(self, event, incident_id):
        """Respond to brute force attack"""
        ip_address = event['ip_address']
        user = event['user']
        
        # Block IP address
        subprocess.run([
            'iptables', '-A', 'INPUT', 
            '-s', ip_address, '-j', 'DROP'
        ])
        
        # Disable user account
        subprocess.run([
            'usermod', '-L', user
        ])
        
        # Invalidate all sessions
        session_manager = SessionManager()
        session_manager.revoke_all_sessions(user)
        
        self.log_response(incident_id, [
            f"Blocked IP: {ip_address}",
            f"Disabled account: {user}",
            "Revoked all user sessions"
        ])
    
    def respond_to_data_exfiltration(self, event, incident_id):
        """Respond to data exfiltration attempt"""
        user = event['user']
        
        # Immediate containment
        # 1. Revoke user access
        self.revoke_user_access(user)
        
        # 2. Kill active processes
        subprocess.run([
            'pkill', '-u', user
        ])
        
        # 3. Preserve evidence
        self.preserve_user_data(user, incident_id)
        
        # 4. Network isolation
        self.isolate_user_network(user)
        
        self.log_response(incident_id, [
            f"Revoked access for user: {user}",
            "Terminated user processes",
            "Preserved forensic evidence",
            "Isolated user from network"
        ])
    
    def create_forensic_snapshot(self, incident_id):
        """Create forensic snapshot for investigation"""
        snapshot_dir = f"/var/log/claude-flow/incidents/{incident_id}/forensics"
        subprocess.run(['mkdir', '-p', snapshot_dir])
        
        # Capture system state
        commands = [
            ('ps auxf', 'processes.txt'),
            ('netstat -tulpn', 'network.txt'),
            ('last -50', 'logins.txt'),
            ('journalctl -n 1000', 'system-logs.txt'),
            ('iptables -L -n -v', 'firewall.txt')
        ]
        
        for cmd, output_file in commands:
            with open(f"{snapshot_dir}/{output_file}", 'w') as f:
                subprocess.run(cmd.split(), stdout=f)
        
        # Create memory dump if possible
        if os.path.exists('/proc/kcore'):
            subprocess.run([
                'dd', 'if=/proc/kcore', 
                f'of={snapshot_dir}/memory.dump',
                'bs=1M', 'count=100'
            ])
        
        # Package forensic data
        subprocess.run([
            'tar', '-czf', 
            f"{snapshot_dir}.tar.gz",
            snapshot_dir
        ])
        
        return f"{snapshot_dir}.tar.gz"
```

## Security Hardening

### 1. System Hardening Script

```bash
#!/bin/bash
# harden_system.sh

echo "=== Claude Flow Security Hardening ==="

# 1. Kernel parameters
echo "Configuring kernel parameters..."
cat >> /etc/sysctl.d/99-claude-flow-security.conf << EOF
# Network security
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1

# File system security
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
kernel.randomize_va_space = 2
kernel.exec-shield = 1

# Process security
kernel.yama.ptrace_scope = 1
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
EOF

sysctl -p /etc/sysctl.d/99-claude-flow-security.conf

# 2. Disable unnecessary services
echo "Disabling unnecessary services..."
for service in telnet.socket tftp.socket rsh.socket rlogin.socket rexec.socket; do
    systemctl disable $service 2>/dev/null
    systemctl stop $service 2>/dev/null
done

# 3. Configure auditd
echo "Configuring audit daemon..."
cat >> /etc/audit/rules.d/claude-flow.rules << EOF
# Claude Flow audit rules
-w /opt/claude-flow/config/ -p wa -k claude_config
-w /etc/claude-flow/ -p wa -k claude_system_config
-w /var/log/claude-flow/ -p wa -k claude_logs

# Monitor command execution
-a always,exit -F arch=b64 -S execve -F path=/opt/claude-flow/bin/claude-flow -k claude_exec

# Monitor authentication
-w /var/log/auth.log -p wa -k auth_log
-w /etc/passwd -p wa -k passwd_changes
-w /etc/shadow -p wa -k shadow_changes
EOF

systemctl restart auditd

# 4. Configure fail2ban
echo "Setting up fail2ban..."
cat > /etc/fail2ban/jail.d/claude-flow.conf << EOF
[claude-flow]
enabled = true
port = 443
filter = claude-flow
logpath = /var/log/claude-flow/auth.log
maxretry = 5
bantime = 3600
findtime = 600
EOF

cat > /etc/fail2ban/filter.d/claude-flow.conf << EOF
[Definition]
failregex = Authentication failed for user .* from <HOST>
            Invalid session token from <HOST>
            Permission denied for .* from <HOST>
ignoreregex =
EOF

systemctl restart fail2ban

# 5. Configure AppArmor/SELinux
if command -v aa-status &> /dev/null; then
    echo "Configuring AppArmor..."
    cp /opt/claude-flow/security/apparmor/* /etc/apparmor.d/
    apparmor_parser -r /etc/apparmor.d/opt.claude-flow
elif command -v getenforce &> /dev/null; then
    echo "Configuring SELinux..."
    semodule -i /opt/claude-flow/security/selinux/claude-flow.pp
fi

# 6. Set up file integrity monitoring
echo "Configuring file integrity monitoring..."
if command -v aide &> /dev/null; then
    cat >> /etc/aide/aide.conf << EOF

# Claude Flow monitoring
/opt/claude-flow/bin Binlib
/opt/claude-flow/config ConfFiles
/etc/claude-flow ConfFiles
EOF
    
    # Initialize AIDE database
    aide --init
    mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
fi

# 7. Harden SSH (if used for management)
echo "Hardening SSH configuration..."
sed -i 's/^#*PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PermitEmptyPasswords .*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i 's/^#*Protocol .*/Protocol 2/' /etc/ssh/sshd_config

systemctl restart sshd

echo "Security hardening complete!"
```

### 2. Security Checklist

```markdown
# Claude Flow Security Checklist

## Initial Deployment
- [ ] Change all default passwords
- [ ] Generate new encryption keys
- [ ] Configure firewall rules
- [ ] Enable audit logging
- [ ] Set up intrusion detection
- [ ] Configure backup encryption
- [ ] Review file permissions
- [ ] Disable unnecessary services
- [ ] Configure TLS certificates
- [ ] Set up monitoring alerts

## Daily Security Tasks
- [ ] Review security alerts
- [ ] Check failed login attempts
- [ ] Monitor system resources
- [ ] Verify backup completion
- [ ] Review audit logs

## Weekly Security Tasks
- [ ] Run vulnerability scans
- [ ] Review user access
- [ ] Check for updates
- [ ] Test backup restoration
- [ ] Review firewall logs

## Monthly Security Tasks
- [ ] Comprehensive security audit
- [ ] Update security documentation
- [ ] Review and rotate credentials
- [ ] Compliance reporting
- [ ] Security training

## Quarterly Security Tasks
- [ ] Penetration testing
- [ ] Disaster recovery drill
- [ ] Policy review and update
- [ ] Third-party security assessment
- [ ] Certificate renewal check
```

## Security Training

### 1. Security Awareness Program

```markdown
# Claude Flow Security Training Program

## Module 1: Security Fundamentals
- Understanding the threat landscape
- Common attack vectors
- Security principles (least privilege, defense in depth)
- Importance of security in AI/ML systems

## Module 2: Authentication & Access Control
- Strong password practices
- Multi-factor authentication setup
- Understanding role-based access
- Session security

## Module 3: Data Protection
- Encryption basics
- Handling sensitive data
- API key management
- Secure file storage

## Module 4: Secure Usage
- Safe command execution
- Avoiding injection attacks
- Recognizing phishing attempts
- Reporting security incidents

## Module 5: Compliance & Auditing
- Understanding audit logs
- Compliance requirements
- Privacy considerations
- Documentation requirements

## Hands-On Labs
1. Setting up MFA
2. Encrypting sensitive files
3. Reviewing audit logs
4. Incident response simulation
5. Security scanning tools
```

### 2. Security Best Practices Guide

```markdown
# Claude Flow Security Best Practices

## For Administrators

### 1. Access Management
- Use centralized authentication (LDAP/SSO)
- Enforce MFA for all administrative accounts
- Regular access reviews (monthly)
- Immediate revocation for departing users

### 2. System Security
- Keep systems patched and updated
- Use configuration management
- Monitor system logs continuously
- Regular security scans

### 3. Data Protection
- Encrypt all sensitive data
- Use secure key management
- Regular backup verification
- Secure deletion procedures

## For Users

### 1. Authentication
- Use strong, unique passwords
- Enable MFA on your account
- Never share credentials
- Report suspicious activities

### 2. Safe Usage
- Verify commands before execution
- Don't store secrets in commands
- Use encrypted storage for API keys
- Follow data classification policies

### 3. Incident Response
- Know how to report incidents
- Preserve evidence
- Don't attempt to fix security issues yourself
- Follow incident response procedures

## For Developers

### 1. Secure Development
- Follow secure coding practices
- Validate all inputs
- Use parameterized queries
- Implement proper error handling

### 2. Security Testing
- Include security tests in CI/CD
- Regular dependency scanning
- Code review for security
- Penetration testing

### 3. Security by Design
- Threat modeling
- Principle of least privilege
- Defense in depth
- Secure defaults
```

## Next Steps

- Implement security controls progressively
- Regular security assessments
- Continuous monitoring and improvement
- Stay updated on security threats
- Regular training and awareness