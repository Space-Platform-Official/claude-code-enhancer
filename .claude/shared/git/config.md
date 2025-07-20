---
description: Git configuration management and team settings
---

# Git Configuration Management

Comprehensive utilities for managing Git configuration across individual and team environments.

## Core Configuration Management

```bash
# Set standardized Git configuration
setup_git_config() {
    local scope=${1:-"global"}  # global, local, or system
    
    echo "Setting up Git configuration ($scope)..."
    
    # Core settings
    git config --$scope core.autocrlf input
    git config --$scope core.safecrlf true
    git config --$scope core.filemode false
    git config --$scope core.precomposeUnicode true
    git config --$scope core.quotepath false
    
    # Push settings
    git config --$scope push.default simple
    git config --$scope push.followTags true
    git config --$scope push.autoSetupRemote true
    
    # Pull settings
    git config --$scope pull.rebase true
    git config --$scope pull.ff only
    
    # Branch settings
    git config --$scope branch.autoSetupMerge always
    git config --$scope branch.autoSetupRebase always
    
    # Merge settings
    git config --$scope merge.ff false
    git config --$scope merge.conflictstyle diff3
    
    # Rebase settings
    git config --$scope rebase.autoStash true
    git config --$scope rebase.autoSquash true
    
    echo "Git configuration setup complete"
}

# Configure user information
configure_user() {
    local name=$1
    local email=$2
    local scope=${3:-"global"}
    
    if [ -z "$name" ] || [ -z "$email" ]; then
        echo "ERROR: Name and email required"
        return 1
    fi
    
    git config --$scope user.name "$name"
    git config --$scope user.email "$email"
    
    # Set signing key if available
    if command -v gpg &> /dev/null; then
        local signing_key=$(gpg --list-secret-keys --keyid-format LONG "$email" 2>/dev/null | grep sec | head -1 | sed 's/.*\/\([A-F0-9]*\).*/\1/')
        if [ -n "$signing_key" ]; then
            git config --$scope user.signingkey "$signing_key"
            git config --$scope commit.gpgsign true
        fi
    fi
    
    echo "User configuration set: $name <$email>"
}

# Configure aliases
setup_git_aliases() {
    local scope=${1:-"global"}
    
    # Status and log aliases
    git config --$scope alias.st "status"
    git config --$scope alias.co "checkout"
    git config --$scope alias.br "branch"
    git config --$scope alias.ci "commit"
    git config --$scope alias.cp "cherry-pick"
    git config --$scope alias.unstage "reset HEAD --"
    git config --$scope alias.last "log -1 HEAD"
    git config --$scope alias.visual "!gitk"
    
    # Advanced aliases
    git config --$scope alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --$scope alias.tree "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
    git config --$scope alias.amend "commit --amend --no-edit"
    git config --$scope alias.fixup "commit --fixup"
    git config --$scope alias.squash "commit --squash"
    git config --$scope alias.wip "commit -am 'WIP'"
    git config --$scope alias.unwip "reset HEAD~1 --mixed"
    
    # Branch management
    git config --$scope alias.cleanup "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d"
    git config --$scope alias.prune-all "!git remote prune origin && git cleanup"
    
    # Diff and show
    git config --$scope alias.staged "diff --cached"
    git config --$scope alias.unstaged "diff"
    git config --$scope alias.both "diff HEAD"
    
    echo "Git aliases configured"
}
```

## Team Configuration Templates

```bash
# Apply team configuration template
apply_team_template() {
    local template_name=$1
    local team_config_file=".gitconfig-team"
    
    case "$template_name" in
        "frontend")
            setup_frontend_team_config
            ;;
        "backend")
            setup_backend_team_config
            ;;
        "fullstack")
            setup_fullstack_team_config
            ;;
        "opensource")
            setup_opensource_team_config
            ;;
        *)
            echo "Available templates: frontend, backend, fullstack, opensource"
            return 1
            ;;
    esac
}

# Frontend team configuration
setup_frontend_team_config() {
    # Configure for frontend development
    git config --local core.autocrlf input
    git config --local diff.tool "vscode"
    git config --local merge.tool "vscode"
    
    # Frontend-specific hooks
    git config --local init.templatedir "~/.git-templates/frontend"
    
    # Configure gitattributes for frontend files
    cat > .gitattributes << 'EOF'
# Auto detect text files and perform LF normalization
* text=auto

# Frontend files
*.js text eol=lf
*.jsx text eol=lf
*.ts text eol=lf
*.tsx text eol=lf
*.css text eol=lf
*.scss text eol=lf
*.sass text eol=lf
*.less text eol=lf
*.json text eol=lf
*.html text eol=lf
*.md text eol=lf
*.yml text eol=lf
*.yaml text eol=lf

# Binary files
*.png binary
*.jpg binary
*.gif binary
*.ico binary
*.woff binary
*.woff2 binary
*.ttf binary
*.eot binary
EOF
    
    echo "Frontend team configuration applied"
}

# Backend team configuration
setup_backend_team_config() {
    # Configure for backend development
    git config --local core.autocrlf input
    git config --local diff.tool "vimdiff"
    git config --local merge.tool "vimdiff"
    
    # Backend-specific settings
    git config --local commit.template ".gitmessage"
    
    # Configure gitattributes for backend files
    cat > .gitattributes << 'EOF'
# Auto detect text files and perform LF normalization
* text=auto

# Backend files
*.py text eol=lf
*.go text eol=lf
*.rs text eol=lf
*.rb text eol=lf
*.php text eol=lf
*.java text eol=lf
*.kt text eol=lf
*.scala text eol=lf
*.sql text eol=lf
*.sh text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.toml text eol=lf
*.ini text eol=lf

# Binary files
*.so binary
*.dylib binary
*.dll binary
*.exe binary
EOF
    
    echo "Backend team configuration applied"
}

# Open source project configuration
setup_opensource_team_config() {
    # Configure for open source development
    git config --local commit.gpgsign true
    git config --local tag.gpgsign true
    git config --local push.followTags true
    
    # Create commit template for open source
    cat > .gitmessage << 'EOF'
# Title: Summary, imperative, start upper case, don't end with a period
# No more than 50 chars. #### 50 chars is here:  #

# Remember blank line between title and body.

# Body: Explain *what* and *why* (not *how*). Include task ID (Jira issue).
# Wrap at 72 chars. ################################## which is here:  #


# At the end: Include Co-authored-by for all contributors. 
# Include at least one empty line before it. Format: 
# Co-authored-by: name <user@users.noreply.github.com>
#
# How to Write a Git Commit Message:
# https://chris.beams.io/posts/git-commit/
#
# 1. Separate subject from body with a blank line
# 2. Limit the subject line to 50 characters
# 3. Capitalize the subject line
# 4. Do not end the subject line with a period
# 5. Use the imperative mood in the subject line
# 6. Wrap the body at 72 characters
# 7. Use the body to explain what and why vs. how
EOF
    
    echo "Open source team configuration applied"
}
```

## Configuration Validation

```bash
# Validate Git configuration
validate_git_config() {
    local scope=${1:-"all"}
    local errors=0
    
    echo "=== Git Configuration Validation ==="
    
    # Check core settings
    echo "Checking core settings..."
    if [ "$(git config core.autocrlf)" != "input" ]; then
        echo "WARNING: core.autocrlf should be 'input'"
        ((errors++))
    fi
    
    if [ "$(git config core.safecrlf)" != "true" ]; then
        echo "WARNING: core.safecrlf should be 'true'"
        ((errors++))
    fi
    
    # Check user settings
    echo "Checking user settings..."
    if [ -z "$(git config user.name)" ]; then
        echo "ERROR: user.name not configured"
        ((errors++))
    fi
    
    if [ -z "$(git config user.email)" ]; then
        echo "ERROR: user.email not configured"
        ((errors++))
    fi
    
    # Check email format
    local email=$(git config user.email)
    if [ -n "$email" ] && ! echo "$email" | grep -qE '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'; then
        echo "ERROR: Invalid email format: $email"
        ((errors++))
    fi
    
    # Check push settings
    echo "Checking push settings..."
    if [ "$(git config push.default)" != "simple" ]; then
        echo "WARNING: push.default should be 'simple'"
        ((errors++))
    fi
    
    # Check pull settings
    echo "Checking pull settings..."
    if [ "$(git config pull.rebase)" != "true" ]; then
        echo "WARNING: pull.rebase should be 'true'"
        ((errors++))
    fi
    
    if [ $errors -eq 0 ]; then
        echo "✅ Git configuration is valid"
    else
        echo "❌ Found $errors configuration issues"
    fi
    
    return $errors
}

# Generate configuration report
generate_config_report() {
    local output_file=${1:-"git-config-report.txt"}
    
    {
        echo "=== Git Configuration Report ==="
        echo "Generated: $(date)"
        echo "Repository: $(pwd)"
        echo ""
        
        echo "=== User Configuration ==="
        echo "Name: $(git config user.name)"
        echo "Email: $(git config user.email)"
        echo "Signing Key: $(git config user.signingkey || echo 'Not configured')"
        echo ""
        
        echo "=== Core Configuration ==="
        echo "autocrlf: $(git config core.autocrlf)"
        echo "safecrlf: $(git config core.safecrlf)"
        echo "filemode: $(git config core.filemode)"
        echo "editor: $(git config core.editor || echo 'Default')"
        echo ""
        
        echo "=== Remote Configuration ==="
        git remote -v
        echo ""
        
        echo "=== Branch Configuration ==="
        git config --get-regexp '^branch\.' || echo "No branch-specific configuration"
        echo ""
        
        echo "=== Alias Configuration ==="
        git config --get-regexp '^alias\.' || echo "No aliases configured"
        echo ""
        
        echo "=== Hook Configuration ==="
        ls -la .git/hooks/ 2>/dev/null || echo "No custom hooks found"
    } > "$output_file"
    
    echo "Configuration report saved to: $output_file"
}
```

## Configuration Migration

```bash
# Backup current configuration
backup_git_config() {
    local backup_dir=${1:-"$HOME/.git-config-backup"}
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$backup_dir/gitconfig_$timestamp.bak"
    
    mkdir -p "$backup_dir"
    
    # Backup global config
    if [ -f "$HOME/.gitconfig" ]; then
        cp "$HOME/.gitconfig" "$backup_file"
        echo "Global config backed up to: $backup_file"
    fi
    
    # Backup local config if in a repo
    if [ -f ".git/config" ]; then
        cp ".git/config" "$backup_dir/local_gitconfig_$timestamp.bak"
        echo "Local config backed up to: $backup_dir/local_gitconfig_$timestamp.bak"
    fi
    
    # Create restore script
    cat > "$backup_dir/restore_$timestamp.sh" << EOF
#!/bin/bash
# Restore Git configuration from backup
echo "Restoring Git configuration from $timestamp..."
if [ -f "$backup_file" ]; then
    cp "$backup_file" "\$HOME/.gitconfig"
    echo "Global config restored"
fi
if [ -f "$backup_dir/local_gitconfig_$timestamp.bak" ]; then
    cp "$backup_dir/local_gitconfig_$timestamp.bak" ".git/config"
    echo "Local config restored"
fi
EOF
    
    chmod +x "$backup_dir/restore_$timestamp.sh"
    echo "Restore script created: $backup_dir/restore_$timestamp.sh"
}

# Migrate configuration from another environment
migrate_git_config() {
    local source_config=$1
    local target_scope=${2:-"global"}
    
    if [ ! -f "$source_config" ]; then
        echo "ERROR: Source config file not found: $source_config"
        return 1
    fi
    
    echo "Migrating configuration from: $source_config"
    
    # Parse and apply configuration
    while IFS= read -r line; do
        if [[ "$line" =~ ^\[.*\]$ ]]; then
            # Section header - skip
            continue
        elif [[ "$line" =~ ^[[:space:]]*([^=]+)=[[:space:]]*(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Clean up key and value
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs)
            
            # Apply configuration
            git config --$target_scope "$key" "$value"
            echo "Set: $key = $value"
        fi
    done < "$source_config"
    
    echo "Configuration migration complete"
}

# Sync configuration across team
sync_team_config() {
    local config_repo_url=$1
    local config_branch=${2:-"main"}
    local temp_dir="/tmp/git-team-config"
    
    if [ -z "$config_repo_url" ]; then
        echo "ERROR: Configuration repository URL required"
        return 1
    fi
    
    echo "Syncing team configuration from: $config_repo_url"
    
    # Clone or update config repository
    if [ -d "$temp_dir" ]; then
        cd "$temp_dir" && git pull origin "$config_branch"
    else
        git clone -b "$config_branch" "$config_repo_url" "$temp_dir"
    fi
    
    cd "$temp_dir"
    
    # Apply team configuration
    if [ -f "gitconfig-global" ]; then
        migrate_git_config "gitconfig-global" "global"
    fi
    
    if [ -f "gitconfig-local" ]; then
        cd - && migrate_git_config "$temp_dir/gitconfig-local" "local"
    fi
    
    # Copy git templates if available
    if [ -d "git-templates" ]; then
        cp -r "git-templates" "$HOME/.git-templates"
        echo "Git templates updated"
    fi
    
    echo "Team configuration sync complete"
}
```

## Environment-Specific Configuration

```bash
# Configure for development environment
configure_development_env() {
    local env_type=${1:-"local"}
    
    case "$env_type" in
        "local")
            configure_local_development
            ;;
        "docker")
            configure_docker_development
            ;;
        "ci")
            configure_ci_environment
            ;;
        "production")
            configure_production_environment
            ;;
        *)
            echo "Available environments: local, docker, ci, production"
            return 1
            ;;
    esac
}

# Local development configuration
configure_local_development() {
    # Enable helpful settings for local development
    git config --local advice.statusHints true
    git config --local advice.commitBeforeMerge true
    git config --local advice.detachedHead true
    
    # Configure for interactive use
    git config --local color.ui auto
    git config --local color.status auto
    git config --local color.branch auto
    git config --local color.interactive auto
    git config --local color.diff auto
    
    # Enable rerere for conflict resolution
    git config --local rerere.enabled true
    
    echo "Local development environment configured"
}

# Docker development configuration
configure_docker_development() {
    # Configure for containerized development
    git config --local core.filemode false
    git config --local core.autocrlf input
    
    # Disable interactive features
    git config --local advice.statusHints false
    git config --local color.ui false
    
    echo "Docker development environment configured"
}

# CI environment configuration
configure_ci_environment() {
    # Configure for CI/CD pipelines
    git config --local user.name "CI Bot"
    git config --local user.email "ci@example.com"
    
    # Disable interactive features
    git config --local advice.statusHints false
    git config --local color.ui false
    git config --local core.askpass ""
    
    # Configure for automated operations
    git config --local push.default simple
    git config --local pull.rebase false
    
    echo "CI environment configured"
}

# Production environment configuration
configure_production_environment() {
    # Strict configuration for production
    git config --local receive.denyCurrentBranch refuse
    git config --local receive.denyDeleteCurrent warn
    git config --local receive.denyNonFastForwards true
    
    # Security settings
    git config --local transfer.fsckObjects true
    git config --local receive.fsckObjects true
    git config --local fetch.fsckObjects true
    
    echo "Production environment configured"
}
```

## Troubleshooting and Maintenance

```bash
# Diagnose configuration issues
diagnose_config_issues() {
    echo "=== Git Configuration Diagnosis ==="
    
    # Check for common issues
    echo "Checking for common configuration issues..."
    
    # Line ending issues
    if [ "$(git config core.autocrlf)" == "true" ] && [[ "$OSTYPE" == "linux"* || "$OSTYPE" == "darwin"* ]]; then
        echo "⚠️  WARNING: core.autocrlf=true on Unix system - should be 'input'"
    fi
    
    # Email privacy
    local email=$(git config user.email)
    if [[ "$email" == *"@users.noreply.github.com" ]]; then
        echo "✅ Using GitHub no-reply email for privacy"
    elif [[ "$email" == *"example.com" ]]; then
        echo "⚠️  WARNING: Using example.com email - update to real email"
    fi
    
    # GPG signing
    if [ "$(git config commit.gpgsign)" == "true" ]; then
        if ! command -v gpg &> /dev/null; then
            echo "❌ ERROR: GPG signing enabled but GPG not installed"
        elif [ -z "$(git config user.signingkey)" ]; then
            echo "❌ ERROR: GPG signing enabled but no signing key configured"
        else
            echo "✅ GPG signing properly configured"
        fi
    fi
    
    # Check for conflicting configs
    echo ""
    echo "Checking for configuration conflicts..."
    
    # Check system vs global vs local precedence
    local system_editor=$(git config --system core.editor 2>/dev/null)
    local global_editor=$(git config --global core.editor 2>/dev/null)
    local local_editor=$(git config --local core.editor 2>/dev/null)
    
    if [ -n "$system_editor" ] && [ -n "$global_editor" ] && [ "$system_editor" != "$global_editor" ]; then
        echo "⚠️  INFO: System and global editors differ (using global: $global_editor)"
    fi
    
    echo "Diagnosis complete"
}

# Clean up configuration
cleanup_git_config() {
    local scope=${1:-"local"}
    
    echo "Cleaning up Git configuration ($scope)..."
    
    # Remove deprecated settings
    git config --$scope --unset color.grep 2>/dev/null || true
    git config --$scope --unset color.showbranch 2>/dev/null || true
    
    # Remove empty sections
    if [ "$scope" == "global" ] && [ -f "$HOME/.gitconfig" ]; then
        # Remove empty sections from global config
        sed -i.bak '/^\[.*\]$/N;/^\[.*\]\s*$/d' "$HOME/.gitconfig"
    fi
    
    echo "Configuration cleanup complete"
}

# Reset configuration to defaults
reset_git_config() {
    local scope=${1:-"local"}
    local confirm=${2:-"prompt"}
    
    if [ "$confirm" == "prompt" ]; then
        echo "This will reset all Git configuration for scope: $scope"
        read -p "Are you sure? [y/N]: " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Reset cancelled"
            return 0
        fi
    fi
    
    case "$scope" in
        "global")
            if [ -f "$HOME/.gitconfig" ]; then
                backup_git_config
                rm "$HOME/.gitconfig"
                echo "Global Git configuration reset"
            fi
            ;;
        "local")
            if [ -f ".git/config" ]; then
                cp ".git/config" ".git/config.bak"
                git config --local --remove-section user 2>/dev/null || true
                git config --local --remove-section core 2>/dev/null || true
                git config --local --remove-section alias 2>/dev/null || true
                echo "Local Git configuration reset"
            fi
            ;;
        "system")
            echo "System configuration reset requires administrator privileges"
            sudo git config --system --remove-section user 2>/dev/null || true
            sudo git config --system --remove-section core 2>/dev/null || true
            echo "System Git configuration reset"
            ;;
        *)
            echo "Invalid scope: $scope (use global, local, or system)"
            return 1
            ;;
    esac
}
```

This configuration management utility provides comprehensive tools for setting up, validating, and maintaining Git configurations across different environments and team settings.