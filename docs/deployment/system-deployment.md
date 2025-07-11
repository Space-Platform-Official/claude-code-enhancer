# Claude Flow System-Wide Deployment Guide

## Overview

This guide covers deploying Claude Flow as a system-wide installation accessible to all users on a Unix-like system (macOS, Linux).

## Prerequisites

- Administrative (sudo) access
- Git installed system-wide
- Bash 4.0+ or Zsh
- At least 500MB free disk space

## System-Wide Installation

### 1. Choose Installation Location

```bash
# Recommended system location
CLAUDE_FLOW_HOME="/opt/claude-flow"

# Alternative locations
# /usr/local/claude-flow
# /var/lib/claude-flow
```

### 2. Create System Installation

```bash
# Create installation directory with proper permissions
sudo mkdir -p "$CLAUDE_FLOW_HOME"
sudo chown -R root:root "$CLAUDE_FLOW_HOME"
sudo chmod 755 "$CLAUDE_FLOW_HOME"

# Clone repository
sudo git clone https://github.com/your-org/claude-flow.git "$CLAUDE_FLOW_HOME/core"

# Set up shared data directories
sudo mkdir -p "$CLAUDE_FLOW_HOME/shared"/{templates,commands,logs}
sudo chmod 755 "$CLAUDE_FLOW_HOME/shared"
```

### 3. Configure System-Wide Access

Create system-wide command wrapper:

```bash
# Create wrapper script
sudo tee /usr/local/bin/claude-flow << 'EOF'
#!/bin/bash
export CLAUDE_FLOW_HOME="/opt/claude-flow"
export CLAUDE_FLOW_SHARED="$CLAUDE_FLOW_HOME/shared"
exec "$CLAUDE_FLOW_HOME/core/bin/claude-flow" "$@"
EOF

# Make executable
sudo chmod 755 /usr/local/bin/claude-flow
```

### 4. Environment Configuration

Add to system-wide shell configuration:

```bash
# For bash - /etc/bash.bashrc
sudo tee -a /etc/bash.bashrc << 'EOF'

# Claude Flow System Configuration
export CLAUDE_FLOW_HOME="/opt/claude-flow"
export CLAUDE_FLOW_SHARED="$CLAUDE_FLOW_HOME/shared"
export PATH="/usr/local/bin:$PATH"
EOF

# For zsh - /etc/zshenv
sudo tee -a /etc/zshenv << 'EOF'

# Claude Flow System Configuration
export CLAUDE_FLOW_HOME="/opt/claude-flow"
export CLAUDE_FLOW_SHARED="$CLAUDE_FLOW_HOME/shared"
export PATH="/usr/local/bin:$PATH"
EOF
```

### 5. Initialize Shared Resources

```bash
# Copy default templates
sudo cp -r "$CLAUDE_FLOW_HOME/core/templates/"* "$CLAUDE_FLOW_HOME/shared/templates/"

# Create shared command directory
sudo mkdir -p "$CLAUDE_FLOW_HOME/shared/commands"
sudo chmod 755 "$CLAUDE_FLOW_HOME/shared/commands"

# Set up logging
sudo mkdir -p "$CLAUDE_FLOW_HOME/shared/logs"
sudo chmod 1777 "$CLAUDE_FLOW_HOME/shared/logs"  # Sticky bit for user logs
```

## Multi-User Configuration

### 1. User Directories

Each user needs personal configuration:

```bash
# In user's home directory
mkdir -p ~/.claude/{commands,templates,config}
```

### 2. Permission Model

```bash
# System directories (read-only for users)
/opt/claude-flow/
├── core/          # 755 root:root - Core application
├── shared/        # 755 root:root - Shared resources
│   ├── templates/ # 755 root:root - System templates
│   ├── commands/  # 755 root:root - System commands
│   └── logs/      # 1777 root:root - User logs (sticky bit)

# User directories (user-writable)
~/.claude/
├── commands/      # User's custom commands
├── templates/     # User's custom templates
└── config/        # User configuration
```

### 3. User Initialization Script

Create user setup script:

```bash
sudo tee /usr/local/bin/claude-flow-init-user << 'EOF'
#!/bin/bash
# Initialize Claude Flow for current user

CLAUDE_USER_DIR="$HOME/.claude"

# Create user directories
mkdir -p "$CLAUDE_USER_DIR"/{commands,templates,config}

# Copy user templates if not exist
if [ ! -f "$CLAUDE_USER_DIR/config/settings.json" ]; then
    cp /opt/claude-flow/core/config/default-settings.json \
       "$CLAUDE_USER_DIR/config/settings.json"
fi

echo "Claude Flow initialized for user: $USER"
echo "User directory: $CLAUDE_USER_DIR"
EOF

sudo chmod 755 /usr/local/bin/claude-flow-init-user
```

## Service Management

### 1. SystemD Service (Optional)

For background services or scheduled tasks:

```ini
# /etc/systemd/system/claude-flow-updater.service
[Unit]
Description=Claude Flow Update Service
After=network.target

[Service]
Type=oneshot
ExecStart=/opt/claude-flow/core/bin/update-check
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### 2. Cron Jobs

Set up automatic updates:

```bash
# /etc/cron.d/claude-flow
# Check for updates weekly
0 2 * * 0 root /opt/claude-flow/core/bin/update-check >> /opt/claude-flow/shared/logs/updates.log 2>&1

# Clean old logs monthly
0 3 1 * * root find /opt/claude-flow/shared/logs -name "*.log" -mtime +30 -delete
```

## Network Deployment

### 1. Centralized Installation

For network-mounted installations:

```bash
# NFS mount example
# /etc/fstab
nfs-server:/opt/claude-flow /opt/claude-flow nfs defaults,ro 0 0
```

### 2. Configuration Management

Use configuration management tools:

```yaml
# Ansible playbook example
---
- name: Deploy Claude Flow
  hosts: all
  become: yes
  tasks:
    - name: Install Claude Flow
      git:
        repo: https://github.com/your-org/claude-flow.git
        dest: /opt/claude-flow/core
        version: stable
    
    - name: Set permissions
      file:
        path: /opt/claude-flow
        owner: root
        group: root
        mode: '0755'
        recurse: yes
```

## Validation

### 1. Installation Check

```bash
# Verify installation
claude-flow --version

# Check system paths
which claude-flow
echo $CLAUDE_FLOW_HOME

# Test as different user
sudo -u testuser claude-flow list
```

### 2. Health Check Script

```bash
sudo tee /usr/local/bin/claude-flow-health << 'EOF'
#!/bin/bash
echo "Claude Flow Health Check"
echo "======================="
echo "Installation: $CLAUDE_FLOW_HOME"
echo "Version: $(claude-flow --version)"
echo "Users with access: $(ls -la /home/*/.claude 2>/dev/null | grep -c claude)"
echo "Shared templates: $(ls -1 $CLAUDE_FLOW_HOME/shared/templates | wc -l)"
echo "System commands: $(ls -1 $CLAUDE_FLOW_HOME/shared/commands | wc -l)"
EOF

sudo chmod 755 /usr/local/bin/claude-flow-health
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   # Fix permissions
   sudo chmod -R 755 /opt/claude-flow
   sudo chmod 1777 /opt/claude-flow/shared/logs
   ```

2. **Command Not Found**
   ```bash
   # Verify PATH
   echo $PATH | grep -q "/usr/local/bin" || export PATH="/usr/local/bin:$PATH"
   ```

3. **User Can't Access Shared Resources**
   ```bash
   # Check user initialization
   claude-flow-init-user
   ```

## Maintenance

### Regular Tasks

1. **Weekly**: Check for updates
2. **Monthly**: Clean logs, verify permissions
3. **Quarterly**: Review user access, audit commands

### Monitoring

```bash
# Monitor usage
tail -f /opt/claude-flow/shared/logs/access.log

# Check disk usage
du -sh /opt/claude-flow/
```

## Security Considerations

1. **Restricted Directories**: Keep core files read-only
2. **Audit Logging**: Enable command logging
3. **Regular Updates**: Apply security patches promptly
4. **Access Control**: Use system groups for access management

## Next Steps

- See `user-deployment.md` for individual user setup
- See `enterprise-setup.md` for large-scale deployments
- See `security.md` for detailed security configuration