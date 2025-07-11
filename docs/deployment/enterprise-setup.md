# Claude Flow Enterprise Deployment Guide

## Overview

This guide covers deploying Claude Flow in enterprise environments with considerations for scale, security, compliance, and centralized management.

## Enterprise Requirements

### Prerequisites

- Active Directory / LDAP infrastructure
- Configuration management system (Ansible, Puppet, Chef)
- Centralized logging infrastructure
- Enterprise proxy configuration
- License management system
- 100+ users expected

## Architecture

### 1. Deployment Topology

```
┌─────────────────────────────────────────────────────────┐
│                   Enterprise Network                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐     ┌──────────────┐                 │
│  │ Central Repo │     │ License Mgmt │                 │
│  │   Server     │     │   Server     │                 │
│  └──────┬───────┘     └──────┬───────┘                 │
│         │                     │                          │
│  ┌──────┴──────────────┬─────┴──────┐                  │
│  │    Load Balancer    │            │                  │
│  └─────────┬───────────┘            │                  │
│            │                         │                  │
│  ┌─────────┴──────┐       ┌─────────┴──────┐          │
│  │ Deployment     │       │ Configuration  │          │
│  │ Server 1       │       │ Server         │          │
│  └────────────────┘       └────────────────┘          │
│                                                        │
│  ┌──────────────────────────────────────────┐         │
│  │           Client Workstations             │         │
│  └──────────────────────────────────────────┘         │
└────────────────────────────────────────────────────────┘
```

### 2. Component Distribution

- **Central Repository**: Internal Git server with Claude Flow
- **Configuration Server**: Manages user settings and policies
- **License Server**: Tracks and manages licenses
- **Deployment Servers**: Distribute updates and configurations

## Installation Strategy

### 1. Centralized Repository

```bash
# On central Git server
mkdir -p /srv/git/claude-flow.git
cd /srv/git/claude-flow.git
git init --bare

# Import Claude Flow
git clone --mirror https://github.com/your-org/claude-flow.git .
git remote add upstream https://github.com/your-org/claude-flow.git

# Set up update hooks
cat > hooks/post-receive << 'EOF'
#!/bin/bash
# Notify deployment system of updates
curl -X POST http://deploy-server/api/claude-flow/update
EOF
chmod +x hooks/post-receive
```

### 2. Configuration Management

#### Ansible Playbook

```yaml
---
- name: Deploy Claude Flow Enterprise
  hosts: workstations
  vars:
    claude_version: "{{ claude_flow_version | default('stable') }}"
    claude_repo: "git://git.company.com/claude-flow.git"
    
  tasks:
    - name: Create installation directory
      file:
        path: /opt/claude-flow
        state: directory
        mode: '0755'
        owner: root
        group: root
    
    - name: Clone Claude Flow
      git:
        repo: "{{ claude_repo }}"
        dest: /opt/claude-flow/core
        version: "{{ claude_version }}"
        
    - name: Deploy enterprise configuration
      template:
        src: claude-enterprise.conf.j2
        dest: /opt/claude-flow/config/enterprise.conf
        mode: '0644'
        
    - name: Configure system-wide environment
      lineinfile:
        path: /etc/environment
        line: 'CLAUDE_FLOW_HOME=/opt/claude-flow'
        
    - name: Deploy wrapper script
      copy:
        src: claude-flow-wrapper
        dest: /usr/local/bin/claude-flow
        mode: '0755'
```

#### Puppet Module

```puppet
class claude_flow (
  String $version = 'stable',
  String $install_path = '/opt/claude-flow',
  Boolean $enable_telemetry = false,
) {
  
  vcsrepo { "${install_path}/core":
    ensure   => present,
    provider => git,
    source   => 'git://git.company.com/claude-flow.git',
    revision => $version,
  }
  
  file { "${install_path}/config/enterprise.conf":
    ensure  => file,
    content => template('claude_flow/enterprise.conf.erb'),
    require => Vcsrepo["${install_path}/core"],
  }
  
  file { '/usr/local/bin/claude-flow':
    ensure => link,
    target => "${install_path}/core/bin/claude-flow",
  }
}
```

### 3. Group Policy (Windows)

```powershell
# Group Policy Administrative Template
# claude-flow.admx

<?xml version="1.0" encoding="utf-8"?>
<policyDefinitions xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xmlns="http://schemas.microsoft.com/GroupPolicy/2006/07/PolicyDefinitions">
  <policyNamespaces>
    <target prefix="claudeflow" namespace="Company.Policies.ClaudeFlow" />
  </policyNamespaces>
  <resources minRequiredRevision="1.0" />
  <categories>
    <category name="ClaudeFlow" displayName="Claude Flow Settings" />
  </categories>
  <policies>
    <policy name="InstallPath" class="Machine" displayName="Installation Path"
            key="SOFTWARE\Company\ClaudeFlow" valueName="InstallPath">
      <parentCategory ref="ClaudeFlow" />
      <supportedOn ref="SUPPORTED_WIN10" />
      <elements>
        <text id="InstallPath" valueName="InstallPath" required="true" />
      </elements>
    </policy>
  </policies>
</policyDefinitions>
```

## License Management

### 1. License Server Setup

```python
# license_server.py
from flask import Flask, jsonify, request
import jwt
import datetime

app = Flask(__name__)

class LicenseManager:
    def __init__(self):
        self.licenses = {}
        self.max_seats = 1000
        
    def check_license(self, user_id):
        active_licenses = len([l for l in self.licenses.values() 
                              if l['active']])
        if active_licenses < self.max_seats:
            return self.issue_license(user_id)
        return None
        
    def issue_license(self, user_id):
        token = jwt.encode({
            'user_id': user_id,
            'issued': datetime.datetime.utcnow().isoformat(),
            'expires': (datetime.datetime.utcnow() + 
                       datetime.timedelta(days=365)).isoformat()
        }, 'secret', algorithm='HS256')
        
        self.licenses[user_id] = {
            'token': token,
            'active': True,
            'issued': datetime.datetime.utcnow()
        }
        return token

@app.route('/api/license/request', methods=['POST'])
def request_license():
    user_id = request.json.get('user_id')
    token = license_manager.check_license(user_id)
    if token:
        return jsonify({'token': token})
    return jsonify({'error': 'No licenses available'}), 403
```

### 2. Client Integration

```bash
# /opt/claude-flow/bin/check-license
#!/bin/bash

LICENSE_SERVER="https://license.company.com"
USER_ID="${USER}@${HOSTNAME}"
LICENSE_FILE="/opt/claude-flow/config/license.jwt"

# Check for valid license
if [ -f "$LICENSE_FILE" ]; then
    # Verify license is still valid
    if claude-flow verify-license "$LICENSE_FILE"; then
        exit 0
    fi
fi

# Request new license
response=$(curl -s -X POST "$LICENSE_SERVER/api/license/request" \
    -H "Content-Type: application/json" \
    -d "{\"user_id\": \"$USER_ID\"}")

if [ $? -eq 0 ]; then
    echo "$response" | jq -r '.token' > "$LICENSE_FILE"
    chmod 600 "$LICENSE_FILE"
    exit 0
else
    echo "Failed to obtain license"
    exit 1
fi
```

## Authentication & Authorization

### 1. LDAP Integration

```json
{
  "auth": {
    "provider": "ldap",
    "ldap": {
      "server": "ldap://ldap.company.com",
      "base_dn": "dc=company,dc=com",
      "user_dn": "uid={username},ou=users,dc=company,dc=com",
      "group_dn": "ou=groups,dc=company,dc=com",
      "required_groups": ["claude-flow-users"],
      "admin_groups": ["claude-flow-admins"]
    }
  }
}
```

### 2. SSO Integration

```yaml
# SAML configuration
saml:
  enabled: true
  idp:
    entityId: "https://sso.company.com"
    sso_url: "https://sso.company.com/saml/sso"
    x509cert: |
      -----BEGIN CERTIFICATE-----
      MIIDxTC...
      -----END CERTIFICATE-----
  sp:
    entityId: "https://claude-flow.company.com"
    acs_url: "https://claude-flow.company.com/saml/acs"
```

### 3. Role-Based Access

```json
{
  "rbac": {
    "roles": {
      "admin": {
        "permissions": ["*"]
      },
      "developer": {
        "permissions": [
          "commands.create",
          "commands.run",
          "templates.use"
        ]
      },
      "viewer": {
        "permissions": [
          "commands.list",
          "commands.view"
        ]
      }
    },
    "mappings": {
      "LDAP_GROUP_claude-admins": "admin",
      "LDAP_GROUP_developers": "developer",
      "LDAP_GROUP_users": "viewer"
    }
  }
}
```

## Compliance & Auditing

### 1. Audit Configuration

```json
{
  "audit": {
    "enabled": true,
    "level": "detailed",
    "destinations": [
      {
        "type": "syslog",
        "host": "syslog.company.com",
        "port": 514,
        "protocol": "tcp"
      },
      {
        "type": "file",
        "path": "/var/log/claude-flow/audit.log",
        "rotation": "daily",
        "retention": "90d"
      }
    ],
    "events": [
      "command.execute",
      "config.change",
      "auth.login",
      "auth.logout",
      "license.request"
    ]
  }
}
```

### 2. Compliance Reporting

```python
#!/usr/bin/env python3
# generate_compliance_report.py

import json
import datetime
from collections import defaultdict

def generate_compliance_report(audit_log_path):
    report = {
        'generated': datetime.datetime.utcnow().isoformat(),
        'period': 'last_30_days',
        'summary': defaultdict(int),
        'users': defaultdict(lambda: defaultdict(int)),
        'commands': defaultdict(int)
    }
    
    with open(audit_log_path) as f:
        for line in f:
            try:
                event = json.loads(line)
                report['summary'][event['type']] += 1
                report['users'][event['user']][event['type']] += 1
                if event['type'] == 'command.execute':
                    report['commands'][event['command']] += 1
            except:
                continue
    
    return report

if __name__ == '__main__':
    report = generate_compliance_report('/var/log/claude-flow/audit.log')
    print(json.dumps(report, indent=2))
```

## Monitoring & Metrics

### 1. Prometheus Integration

```yaml
# prometheus-claude-flow.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'claude-flow'
    static_configs:
      - targets: ['localhost:9090']
    metric_relabel_configs:
      - source_labels: [__name__]
        regex: 'claude_flow_.*'
        action: keep
```

### 2. Metrics Exporter

```python
# claude_flow_exporter.py
from prometheus_client import Counter, Histogram, Gauge, start_http_server
import time

# Metrics
command_executions = Counter('claude_flow_command_executions_total', 
                           'Total command executions', 
                           ['command', 'user'])
command_duration = Histogram('claude_flow_command_duration_seconds',
                           'Command execution duration',
                           ['command'])
active_users = Gauge('claude_flow_active_users',
                    'Number of active users')
license_usage = Gauge('claude_flow_license_usage',
                     'License seats in use')

def collect_metrics():
    # Collect metrics from Claude Flow
    pass

if __name__ == '__main__':
    start_http_server(9090)
    while True:
        collect_metrics()
        time.sleep(15)
```

## Network & Proxy Configuration

### 1. Proxy Settings

```bash
# /opt/claude-flow/config/proxy.conf
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="http://proxy.company.com:8080"
export NO_PROXY="localhost,127.0.0.1,.company.com"

# PAC file support
export AUTO_PROXY="http://proxy.company.com/proxy.pac"
```

### 2. Certificate Management

```bash
# Install corporate CA certificates
cp /etc/pki/ca-trust/source/anchors/company-ca.crt \
   /opt/claude-flow/certs/

# Update certificate bundle
cat /etc/pki/tls/certs/ca-bundle.crt \
    /opt/claude-flow/certs/company-ca.crt > \
    /opt/claude-flow/certs/combined-ca-bundle.crt

export SSL_CERT_FILE="/opt/claude-flow/certs/combined-ca-bundle.crt"
```

## High Availability

### 1. Load Balancer Configuration

```nginx
# nginx.conf
upstream claude_flow_backend {
    least_conn;
    server backend1.company.com:8080 weight=5;
    server backend2.company.com:8080 weight=5;
    server backend3.company.com:8080 backup;
}

server {
    listen 443 ssl;
    server_name claude-flow.company.com;
    
    ssl_certificate /etc/nginx/ssl/claude-flow.crt;
    ssl_certificate_key /etc/nginx/ssl/claude-flow.key;
    
    location / {
        proxy_pass http://claude_flow_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 2. Database Clustering

```yaml
# PostgreSQL cluster for shared state
postgresql:
  cluster:
    enabled: true
    nodes:
      - host: db1.company.com
        role: primary
      - host: db2.company.com
        role: standby
      - host: db3.company.com
        role: standby
    replication:
      type: streaming
      sync_mode: synchronous
```

## Disaster Recovery

### 1. Backup Strategy

```bash
#!/bin/bash
# /opt/claude-flow/scripts/backup.sh

BACKUP_DIR="/backup/claude-flow"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup configuration
tar -czf "$BACKUP_DIR/config-$TIMESTAMP.tar.gz" \
    /opt/claude-flow/config \
    /opt/claude-flow/shared

# Backup database
pg_dump -h db.company.com claude_flow > \
    "$BACKUP_DIR/database-$TIMESTAMP.sql"

# Backup user data
rsync -av /home/*/.claude/ "$BACKUP_DIR/userdata-$TIMESTAMP/"

# Rotate old backups
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete
```

### 2. Recovery Procedures

```bash
#!/bin/bash
# /opt/claude-flow/scripts/restore.sh

BACKUP_DATE=$1
BACKUP_DIR="/backup/claude-flow"

# Restore configuration
tar -xzf "$BACKUP_DIR/config-$BACKUP_DATE.tar.gz" -C /

# Restore database
psql -h db.company.com claude_flow < \
    "$BACKUP_DIR/database-$BACKUP_DATE.sql"

# Restore user data
rsync -av "$BACKUP_DIR/userdata-$BACKUP_DATE/" /home/
```

## Security Hardening

### 1. SELinux Policy

```bash
# claude-flow.te
module claude-flow 1.0;

require {
    type user_t;
    type claude_flow_t;
    type claude_flow_config_t;
}

# Allow claude-flow to read config
allow claude_flow_t claude_flow_config_t:file read;

# Allow users to execute claude-flow
allow user_t claude_flow_t:file execute;
```

### 2. AppArmor Profile

```bash
# /etc/apparmor.d/opt.claude-flow
#include <tunables/global>

/opt/claude-flow/bin/claude-flow {
  #include <abstractions/base>
  
  /opt/claude-flow/bin/claude-flow r,
  /opt/claude-flow/lib/** r,
  /opt/claude-flow/config/** r,
  
  /home/*/.claude/** rw,
  /tmp/claude-flow-* rw,
  
  network inet stream,
  network inet6 stream,
}
```

## Performance Tuning

### 1. Caching Configuration

```json
{
  "cache": {
    "type": "redis",
    "redis": {
      "cluster": [
        "redis1.company.com:6379",
        "redis2.company.com:6379",
        "redis3.company.com:6379"
      ],
      "password": "${REDIS_PASSWORD}",
      "db": 0,
      "ttl": 3600
    }
  }
}
```

### 2. Resource Limits

```bash
# /etc/systemd/system/claude-flow.slice
[Slice]
CPUQuota=50%
MemoryMax=2G
TasksMax=100
```

## Migration Strategy

### 1. Phased Rollout

```yaml
# rollout-plan.yml
phases:
  - name: "Pilot"
    groups: ["early-adopters"]
    duration: "2 weeks"
    success_criteria:
      - error_rate: "< 1%"
      - user_satisfaction: "> 80%"
      
  - name: "Department Rollout"
    groups: ["engineering", "qa"]
    duration: "4 weeks"
    
  - name: "Company Wide"
    groups: ["all"]
    duration: "ongoing"
```

### 2. Training Program

```markdown
## Claude Flow Enterprise Training

### Administrator Track
- Installation and configuration
- User management
- Troubleshooting
- Security policies

### Developer Track
- Basic usage
- Creating custom commands
- Integration with IDEs
- Best practices

### End User Track
- Getting started
- Common workflows
- Getting help
```

## Support Structure

### 1. Internal Support

```yaml
support:
  tiers:
    - level: 1
      team: "Help Desk"
      scope: "Basic usage, password resets"
      
    - level: 2
      team: "IT Operations"
      scope: "Installation, configuration issues"
      
    - level: 3
      team: "Engineering"
      scope: "Bugs, feature requests"
```

### 2. Documentation Portal

```nginx
# Internal docs site
server {
    server_name docs.claude-flow.company.com;
    root /var/www/claude-flow-docs;
    
    location / {
        index index.html;
    }
    
    location /api {
        proxy_pass http://localhost:8080;
    }
}
```

## Maintenance Windows

```yaml
maintenance:
  schedule:
    regular:
      day: "Sunday"
      time: "02:00-04:00 UTC"
      frequency: "monthly"
    
    emergency:
      notification: "2 hours minimum"
      approval: "Change Advisory Board"
  
  procedures:
    pre_maintenance:
      - "Notify users 48 hours in advance"
      - "Backup all configurations"
      - "Test rollback procedures"
    
    post_maintenance:
      - "Verify all services"
      - "Run smoke tests"
      - "Monitor for 24 hours"
```

## Cost Management

```python
# cost_calculator.py
def calculate_claude_flow_cost(users, usage_hours_per_month):
    base_license_cost = 50  # per user per year
    infrastructure_cost = 10000  # annual
    support_cost = users * 10  # per user per year
    
    total_annual_cost = (
        (users * base_license_cost) +
        infrastructure_cost +
        support_cost
    )
    
    return {
        'total_annual': total_annual_cost,
        'per_user_monthly': total_annual_cost / users / 12,
        'breakdown': {
            'licenses': users * base_license_cost,
            'infrastructure': infrastructure_cost,
            'support': support_cost
        }
    }
```

## Success Metrics

```sql
-- Monthly usage report
SELECT 
    DATE_TRUNC('month', timestamp) as month,
    COUNT(DISTINCT user_id) as active_users,
    COUNT(*) as total_commands,
    AVG(execution_time) as avg_execution_time,
    SUM(CASE WHEN status = 'error' THEN 1 ELSE 0 END)::float / 
        COUNT(*) as error_rate
FROM claude_flow_events
WHERE event_type = 'command_execution'
GROUP BY DATE_TRUNC('month', timestamp)
ORDER BY month DESC;
```

## Next Steps

- Review security.md for detailed security configurations
- See updates.md for update procedures
- Consult backup-recovery.md for disaster recovery planning
- Contact enterprise support for custom requirements