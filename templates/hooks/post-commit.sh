#!/bin/bash
# Claude Code Post-Commit Hook
# Performs cleanup and notifications after successful commits

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[HOOK]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[HOOK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[HOOK]${NC} $1"
}

print_error() {
    echo -e "${RED}[HOOK]${NC} $1"
}

# Get project root and commit info
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
COMMIT_HASH="$(git rev-parse HEAD)"
COMMIT_MSG="$(git log -1 --pretty=%B)"

cd "$PROJECT_ROOT"

# Load project configuration if it exists
if [[ -f ".claude/config/env.sh" ]]; then
    source ".claude/config/env.sh"
fi

print_status "Post-commit cleanup and notifications..."

# Clean up old backups
cleanup_old_backups() {
    local backup_retention="${CLAUDE_MERGE_BACKUP_RETENTION:-24}"
    local cleaned_count=0
    local cleaned_enhanced=0
    local cleaned_editor=0
    local cleaned_rollback=0
    
    # Clean backups in .claude/backups directory
    if [[ -d ".claude/backups" ]]; then
        # Find and clean old backup files with various patterns
        while IFS= read -r backup_file; do
            if [[ -f "$backup_file" ]]; then
                # Calculate age more robustly for different systems
                local file_age_hours=0
                if command -v stat >/dev/null 2>&1; then
                    # macOS and BSD stat
                    local file_mtime=$(stat -f %m "$backup_file" 2>/dev/null || stat -c %Y "$backup_file" 2>/dev/null || echo 0)
                    file_age_hours=$(( ($(date +%s) - file_mtime) / 3600 ))
                fi
                
                # Enhanced packages get cleaned immediately
                if [[ "$backup_file" == *"_ENHANCED.md" ]]; then
                    rm -f "$backup_file"
                    ((cleaned_enhanced++))
                    ((cleaned_count++))
                # Pre-rollback files with timestamp check
                elif [[ "$backup_file" == *".pre-rollback."* ]]; then
                    if [[ $file_age_hours -gt $backup_retention ]]; then
                        rm -f "$backup_file"
                        ((cleaned_rollback++))
                        ((cleaned_count++))
                    fi
                # Editor backup files
                elif [[ "$backup_file" =~ \.(orig|bak)$ ]] || [[ "$backup_file" == *"~" ]]; then
                    if [[ $file_age_hours -gt $backup_retention ]]; then
                        rm -f "$backup_file"
                        ((cleaned_editor++))
                        ((cleaned_count++))
                    fi
                # Standard backup files with timestamps
                elif [[ $file_age_hours -gt $backup_retention ]]; then
                    rm -f "$backup_file"
                    ((cleaned_count++))
                fi
            fi
        done < <(find ".claude/backups" -type f \( \
            -name "*.backup.*" -o \
            -name "*.pre-rollback.*" -o \
            -name "*_ENHANCED.md" -o \
            -name "*.orig" -o \
            -name "*.bak" -o \
            -name "*~" \
            \) 2>/dev/null)
    fi
    
    # Also clean backup files in project root (outside .claude/backups)
    # Be more careful here - only clean files that match strict backup patterns
    while IFS= read -r backup_file; do
        if [[ -f "$backup_file" ]]; then
            local file_age_hours=0
            if command -v stat >/dev/null 2>&1; then
                local file_mtime=$(stat -f %m "$backup_file" 2>/dev/null || stat -c %Y "$backup_file" 2>/dev/null || echo 0)
                file_age_hours=$(( ($(date +%s) - file_mtime) / 3600 ))
            fi
            
            # Enhanced packages get cleaned immediately
            if [[ "$backup_file" == *"_ENHANCED.md" ]]; then
                rm -f "$backup_file"
                ((cleaned_enhanced++))
                ((cleaned_count++))
            # Other backups respect retention period
            elif [[ $file_age_hours -gt $backup_retention ]]; then
                rm -f "$backup_file"
                ((cleaned_count++))
            fi
        fi
    done < <(find . -maxdepth 3 -type f \( \
        -name "*.backup.[0-9]*" -o \
        -name "*.pre-rollback.[0-9]*" -o \
        -name "*_ENHANCED.md" \
        \) -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./.claude/backups/*" 2>/dev/null)
    
    # Report what was cleaned
    if [[ $cleaned_count -gt 0 ]]; then
        local details=""
        [[ $cleaned_enhanced -gt 0 ]] && details="${details}$cleaned_enhanced enhanced packages, "
        [[ $cleaned_rollback -gt 0 ]] && details="${details}$cleaned_rollback rollback backups, "
        [[ $cleaned_editor -gt 0 ]] && details="${details}$cleaned_editor editor backups, "
        
        if [[ -n "$details" ]]; then
            # Remove trailing comma and space
            details="${details%, }"
            print_status "Cleaned $cleaned_count backup files ($details)"
        else
            print_status "Cleaned $cleaned_count old backup files"
        fi
    fi
}

# Update documentation if needed
update_documentation() {
    local changed_files=$(git diff-tree --no-commit-id --name-only -r HEAD)
    local docs_updated=false
    
    # Check if any source files changed and docs might need updating
    if echo "$changed_files" | grep -q -E '\.(js|ts|py|php|go|rs|java|cpp|c)$'; then
        if [[ -n "$DOCS_COMMAND" ]] && command -v ${DOCS_COMMAND%% *} >/dev/null 2>&1; then
            print_status "Source files changed, updating documentation..."
            if $DOCS_COMMAND >/dev/null 2>&1; then
                docs_updated=true
                print_success "Documentation updated"
            else
                print_warning "Documentation update failed"
            fi
        fi
    fi
    
    return 0
}

# Send notifications if configured
send_notifications() {
    local commit_short=$(echo "$COMMIT_HASH" | cut -c1-8)
    local commit_subject=$(echo "$COMMIT_MSG" | head -n1)
    
    # Webhook notification
    if [[ -n "$CLAUDE_HOOKS_WEBHOOK_URL" ]]; then
        local payload=$(cat <<EOF
{
    "project": "$(basename "$PROJECT_ROOT")",
    "commit": "$commit_short",
    "message": "$commit_subject",
    "author": "$(git log -1 --pretty=%an)",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
)
        
        if command -v curl >/dev/null 2>&1; then
            curl -X POST "$CLAUDE_HOOKS_WEBHOOK_URL" \
                -H "Content-Type: application/json" \
                -d "$payload" \
                >/dev/null 2>&1 || true
            print_status "Webhook notification sent"
        fi
    fi
    
    # Slack notification
    if [[ -n "$CLAUDE_HOOKS_SLACK_WEBHOOK" ]]; then
        local slack_payload=$(cat <<EOF
{
    "text": "New commit in $(basename "$PROJECT_ROOT"): $commit_subject ($commit_short)"
}
EOF
)
        
        if command -v curl >/dev/null 2>&1; then
            curl -X POST "$CLAUDE_HOOKS_SLACK_WEBHOOK" \
                -H "Content-Type: application/json" \
                -d "$slack_payload" \
                >/dev/null 2>&1 || true
            print_status "Slack notification sent"
        fi
    fi
}

# Update commit statistics
update_stats() {
    local stats_file=".claude/stats/commits.json"
    
    if [[ ! -d ".claude/stats" ]]; then
        mkdir -p ".claude/stats"
    fi
    
    # Simple commit counter
    local commit_count=1
    if [[ -f "$stats_file" ]]; then
        commit_count=$(grep -o '"total_commits":[0-9]*' "$stats_file" 2>/dev/null | cut -d: -f2)
        commit_count=$((commit_count + 1))
    fi
    
    cat > "$stats_file" << EOF
{
    "total_commits": $commit_count,
    "last_commit": "$COMMIT_HASH",
    "last_commit_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "project": "$(basename "$PROJECT_ROOT")"
}
EOF
    
    print_status "Commit statistics updated ($commit_count total commits)"
}

# Main execution
main() {
    # Only run if not disabled
    if [[ "${CLAUDE_HOOKS_POST_COMMIT_DISABLED:-false}" == "true" ]]; then
        print_status "Post-commit hooks disabled"
        return 0
    fi
    
    # Clean up old backups
    cleanup_old_backups
    
    # Update documentation if needed
    update_documentation
    
    # Update commit statistics
    update_stats
    
    # Send notifications if configured
    if [[ "${CLAUDE_HOOKS_NOTIFICATIONS:-false}" == "true" ]]; then
        send_notifications
    fi
    
    print_success "Post-commit processing completed"
    
    # Show helpful information
    print_status "Commit: $(echo "$COMMIT_HASH" | cut -c1-8)"
    print_status "Files changed: $(git diff-tree --no-commit-id --name-only -r HEAD | wc -l | xargs)"
    
    return 0
}

# Run main function
main "$@"