#!/bin/bash

# Agent Sync and Cross-Check Script for Claude Code
# Manages agent templates between .claude/agents/ and templates/agents/
# Usage: ./sync-agents.sh [command] [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_AGENTS_DIR="$SCRIPT_DIR/.claude/agents"
TEMPLATE_AGENTS_DIR="$SCRIPT_DIR/templates/agents"
TEMPLATE_COMMANDS_DIR="$SCRIPT_DIR/templates/commands"
DRY_RUN=false
VERBOSE=false
NO_BACKUP=false
AUTO_YES=false

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_diff() {
    echo -e "${CYAN}[DIFF]${NC} $1"
}

print_command() {
    echo -e "${MAGENTA}[CMD]${NC} $1"
}

# Function to create backup
create_backup() {
    local file="$1"
    
    if [[ "$NO_BACKUP" == "true" ]]; then
        return 0
    fi
    
    if [[ -f "$file" ]]; then
        local backup="${file}.backup.$(date +%s)"
        cp "$file" "$backup"
        print_status "Backup created: $(basename "$backup")"
    fi
}

# Function to check if directories exist
check_directories() {
    local errors=0
    
    if [[ ! -d "$LOCAL_AGENTS_DIR" ]]; then
        print_warning "Local agents directory not found: $LOCAL_AGENTS_DIR"
        mkdir -p "$LOCAL_AGENTS_DIR"
        print_status "Created: $LOCAL_AGENTS_DIR"
    fi
    
    if [[ ! -d "$TEMPLATE_AGENTS_DIR" ]]; then
        print_warning "Template agents directory not found: $TEMPLATE_AGENTS_DIR"
        mkdir -p "$TEMPLATE_AGENTS_DIR"
        print_status "Created: $TEMPLATE_AGENTS_DIR"
    fi
    
    if [[ ! -d "$TEMPLATE_COMMANDS_DIR" ]]; then
        print_warning "Template commands directory not found: $TEMPLATE_COMMANDS_DIR"
    fi
    
    return 0
}

# Function to list all agents
list_agents() {
    local dir="$1"
    local label="$2"
    
    if [[ -d "$dir" ]]; then
        local count=$(find "$dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l)
        echo -e "\n${BLUE}=== $label ($count agents) ===${NC}"
        
        if [[ $count -gt 0 ]]; then
            find "$dir" -maxdepth 1 -name "*.md" -type f -exec basename {} \; | sort | while read -r agent; do
                echo "  • $agent"
            done
        else
            echo "  (empty)"
        fi
    fi
}

# Function to get agent fingerprint
get_agent_fingerprint() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        # Create fingerprint excluding comments and blank lines
        grep -v "^#" "$file" | grep -v "^$" | sha256sum | cut -d' ' -f1
    else
        echo "none"
    fi
}

# Function to cross-check agents
cross_check() {
    print_status "Starting cross-check between local and template agents..."
    
    # Collect all unique agent names
    local all_agents=()
    
    # Add local agents
    if [[ -d "$LOCAL_AGENTS_DIR" ]]; then
        while IFS= read -r agent; do
            all_agents+=("$(basename "$agent")")
        done < <(find "$LOCAL_AGENTS_DIR" -maxdepth 1 -name "*.md" -type f)
    fi
    
    # Add template agents
    if [[ -d "$TEMPLATE_AGENTS_DIR" ]]; then
        while IFS= read -r agent; do
            local name="$(basename "$agent")"
            if [[ ! " ${all_agents[@]} " =~ " ${name} " ]]; then
                all_agents+=("$name")
            fi
        done < <(find "$TEMPLATE_AGENTS_DIR" -maxdepth 1 -name "*.md" -type f)
    fi
    
    # Sort agents
    IFS=$'\n' all_agents=($(sort <<<"${all_agents[*]}"))
    
    # Check each agent
    local identical=0
    local different=0
    local local_only=0
    local template_only=0
    
    echo -e "\n${BLUE}=== Agent Comparison ===${NC}"
    echo "----------------------------------------"
    
    for agent in "${all_agents[@]}"; do
        local local_file="$LOCAL_AGENTS_DIR/$agent"
        local template_file="$TEMPLATE_AGENTS_DIR/$agent"
        
        if [[ -f "$local_file" && -f "$template_file" ]]; then
            # Both exist - compare
            local local_fp=$(get_agent_fingerprint "$local_file")
            local template_fp=$(get_agent_fingerprint "$template_file")
            
            if [[ "$local_fp" == "$template_fp" ]]; then
                echo -e "${GREEN}✓${NC} $agent (identical)"
                ((identical++))
            else
                echo -e "${YELLOW}≠${NC} $agent (different content)"
                ((different++))
                
                if [[ "$VERBOSE" == "true" ]]; then
                    # Show brief diff
                    echo "    Differences:"
                    diff -u "$template_file" "$local_file" 2>/dev/null | head -10 | sed 's/^/    /' || true
                fi
            fi
        elif [[ -f "$local_file" ]]; then
            echo -e "${CYAN}←${NC} $agent (local only)"
            ((local_only++))
        else
            echo -e "${MAGENTA}→${NC} $agent (template only)"
            ((template_only++))
        fi
    done
    
    # Summary
    echo -e "\n${BLUE}=== Summary ===${NC}"
    echo "Identical agents:    $identical"
    echo "Different content:   $different"
    echo "Local only:         $local_only"
    echo "Template only:      $template_only"
    echo "Total unique:       ${#all_agents[@]}"
    
    # Check command references
    check_command_references
}

# Function to check command references to agents
check_command_references() {
    if [[ ! -d "$TEMPLATE_COMMANDS_DIR" ]]; then
        return 0
    fi
    
    echo -e "\n${BLUE}=== Agent References in Commands ===${NC}"
    
    local refs_found=0
    
    # Search for agent spawning patterns in commands
    grep -r "subagent_type.*:" "$TEMPLATE_COMMANDS_DIR" 2>/dev/null | while read -r line; do
        local file=$(echo "$line" | cut -d: -f1)
        local agent_ref=$(echo "$line" | grep -o '"[^"]*"' | tr -d '"' | head -1)
        
        if [[ -n "$agent_ref" && "$agent_ref" != "general-purpose" ]]; then
            local cmd_name=$(basename "$(dirname "$file")")/$(basename "$file")
            echo "  $cmd_name references: $agent_ref"
            ((refs_found++))
        fi
    done
    
    if [[ $refs_found -eq 0 ]]; then
        echo "  No specific agent references found (only general-purpose)"
    fi
}

# Function to sync agents from templates to local
sync_to_local() {
    print_status "Syncing agents from templates to local..."
    
    local synced=0
    local skipped=0
    
    if [[ ! -d "$TEMPLATE_AGENTS_DIR" ]]; then
        print_error "No template agents directory found"
        return 1
    fi
    
    # Process each template agent
    find "$TEMPLATE_AGENTS_DIR" -maxdepth 1 -name "*.md" -type f | while read -r template_file; do
        local agent_name=$(basename "$template_file")
        local local_file="$LOCAL_AGENTS_DIR/$agent_name"
        
        if [[ -f "$local_file" ]]; then
            # Check if different
            local local_fp=$(get_agent_fingerprint "$local_file")
            local template_fp=$(get_agent_fingerprint "$template_file")
            
            if [[ "$local_fp" != "$template_fp" ]]; then
                if [[ "$AUTO_YES" == "true" ]]; then
                    response="y"
                else
                    echo -e "\n${YELLOW}Agent '$agent_name' exists locally with different content${NC}"
                    read -p "Overwrite local version? (y/N): " response
                fi
                
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    create_backup "$local_file"
                    
                    if [[ "$DRY_RUN" == "true" ]]; then
                        print_command "cp $template_file $local_file"
                    else
                        cp "$template_file" "$local_file"
                        print_success "Updated: $agent_name"
                    fi
                    ((synced++))
                else
                    print_status "Skipped: $agent_name"
                    ((skipped++))
                fi
            else
                print_status "Already in sync: $agent_name"
                ((skipped++))
            fi
        else
            # New agent
            if [[ "$DRY_RUN" == "true" ]]; then
                print_command "cp $template_file $local_file"
            else
                cp "$template_file" "$local_file"
                print_success "Added: $agent_name"
            fi
            ((synced++))
        fi
    done
    
    print_success "Sync to local complete: $synced synced, $skipped skipped"
}

# Function to sync agents from local to templates (development mode)
sync_to_templates() {
    print_status "Syncing agents from local to templates (development mode)..."
    
    local synced=0
    local skipped=0
    
    if [[ ! -d "$LOCAL_AGENTS_DIR" ]]; then
        print_error "No local agents directory found"
        return 1
    fi
    
    # Process each local agent
    find "$LOCAL_AGENTS_DIR" -maxdepth 1 -name "*.md" -type f | while read -r local_file; do
        local agent_name=$(basename "$local_file")
        local template_file="$TEMPLATE_AGENTS_DIR/$agent_name"
        
        if [[ -f "$template_file" ]]; then
            # Check if different
            local local_fp=$(get_agent_fingerprint "$local_file")
            local template_fp=$(get_agent_fingerprint "$template_file")
            
            if [[ "$local_fp" != "$template_fp" ]]; then
                if [[ "$AUTO_YES" == "true" ]]; then
                    response="y"
                else
                    echo -e "\n${YELLOW}Agent '$agent_name' exists in templates with different content${NC}"
                    read -p "Overwrite template version? (y/N): " response
                fi
                
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    create_backup "$template_file"
                    
                    if [[ "$DRY_RUN" == "true" ]]; then
                        print_command "cp $local_file $template_file"
                    else
                        cp "$local_file" "$template_file"
                        print_success "Updated template: $agent_name"
                    fi
                    ((synced++))
                else
                    print_status "Skipped: $agent_name"
                    ((skipped++))
                fi
            else
                print_status "Already in sync: $agent_name"
                ((skipped++))
            fi
        else
            # New agent for templates
            if [[ "$DRY_RUN" == "true" ]]; then
                print_command "cp $local_file $template_file"
            else
                cp "$local_file" "$template_file"
                print_success "Added to templates: $agent_name"
            fi
            ((synced++))
        fi
    done
    
    print_success "Sync to templates complete: $synced synced, $skipped skipped"
}

# Function to show diff for specific agent
show_diff() {
    local agent_name="$1"
    
    if [[ -z "$agent_name" ]]; then
        print_error "Agent name required for diff"
        return 1
    fi
    
    local local_file="$LOCAL_AGENTS_DIR/$agent_name"
    local template_file="$TEMPLATE_AGENTS_DIR/$agent_name"
    
    if [[ ! -f "$local_file" && ! -f "$template_file" ]]; then
        print_error "Agent '$agent_name' not found in either location"
        return 1
    fi
    
    echo -e "\n${BLUE}=== Diff for $agent_name ===${NC}"
    
    if [[ ! -f "$local_file" ]]; then
        print_warning "Agent only exists in templates"
        echo "--- Template content ---"
        head -20 "$template_file"
    elif [[ ! -f "$template_file" ]]; then
        print_warning "Agent only exists locally"
        echo "--- Local content ---"
        head -20 "$local_file"
    else
        # Both exist - show diff
        if command -v colordiff >/dev/null 2>&1; then
            colordiff -u "$template_file" "$local_file" || true
        else
            diff -u "$template_file" "$local_file" || true
        fi
    fi
}

# Function for automatic bidirectional sync
auto_sync() {
    print_status "Starting automatic bidirectional sync..."
    
    local synced_to_local=0
    local synced_to_templates=0
    local conflicts=0
    local already_synced=0
    
    # Collect all unique agent names
    local all_agents=()
    
    # Add local agents
    if [[ -d "$LOCAL_AGENTS_DIR" ]]; then
        while IFS= read -r agent; do
            all_agents+=("$(basename "$agent")")
        done < <(find "$LOCAL_AGENTS_DIR" -maxdepth 1 -name "*.md" -type f)
    fi
    
    # Add template agents
    if [[ -d "$TEMPLATE_AGENTS_DIR" ]]; then
        while IFS= read -r agent; do
            local name="$(basename "$agent")"
            if [[ ! " ${all_agents[@]} " =~ " ${name} " ]]; then
                all_agents+=("$name")
            fi
        done < <(find "$TEMPLATE_AGENTS_DIR" -maxdepth 1 -name "*.md" -type f)
    fi
    
    # Sort agents
    IFS=$'\n' all_agents=($(sort <<<"${all_agents[*]}"))
    
    echo -e "\n${BLUE}=== Automatic Sync Analysis ===${NC}"
    echo "----------------------------------------"
    
    # Process each agent
    for agent in "${all_agents[@]}"; do
        local local_file="$LOCAL_AGENTS_DIR/$agent"
        local template_file="$TEMPLATE_AGENTS_DIR/$agent"
        
        if [[ -f "$local_file" && -f "$template_file" ]]; then
            # Both exist - check if identical
            local local_fp=$(get_agent_fingerprint "$local_file")
            local template_fp=$(get_agent_fingerprint "$template_file")
            
            if [[ "$local_fp" == "$template_fp" ]]; then
                echo -e "${GREEN}✓${NC} $agent (already in sync)"
                ((already_synced++))
            else
                echo -e "${YELLOW}⚠${NC} $agent (conflict - different content in both locations)"
                ((conflicts++))
                if [[ "$VERBOSE" == "true" ]]; then
                    echo "    Run './sync-agents.sh diff $agent' to see differences"
                fi
            fi
        elif [[ -f "$local_file" ]]; then
            # Only in local - sync to templates
            echo -e "${MAGENTA}→${NC} $agent (syncing local → templates)"
            
            if [[ "$DRY_RUN" == "true" ]]; then
                print_command "cp $local_file $template_file"
            else
                cp "$local_file" "$template_file"
                print_success "  Synced to templates: $agent"
            fi
            ((synced_to_templates++))
            
        else
            # Only in templates - sync to local
            echo -e "${CYAN}←${NC} $agent (syncing templates → local)"
            
            if [[ "$DRY_RUN" == "true" ]]; then
                print_command "cp $template_file $local_file"
            else
                cp "$template_file" "$local_file"
                print_success "  Synced to local: $agent"
            fi
            ((synced_to_local++))
        fi
    done
    
    # Summary
    echo -e "\n${BLUE}=== Sync Summary ===${NC}"
    echo "Already in sync:        $already_synced"
    echo "Synced to local:        $synced_to_local"
    echo "Synced to templates:    $synced_to_templates"
    echo "Conflicts (not synced): $conflicts"
    echo "Total agents:           ${#all_agents[@]}"
    
    if [[ $conflicts -gt 0 ]]; then
        echo -e "\n${YELLOW}[WARNING]${NC} $conflicts agent(s) have conflicts and were not synced."
        echo "To resolve conflicts, use one of these commands:"
        echo "  $0 sync        # Force sync from templates to local"
        echo "  $0 sync-dev    # Force sync from local to templates"
        echo "  $0 diff <agent># View differences for specific agent"
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "\n${BLUE}[INFO]${NC} DRY RUN - No actual changes were made"
    else
        print_success "Automatic sync completed successfully!"
    fi
}

# Function to clean old backups
clean_backups() {
    local retention_hours="${AGENT_SYNC_BACKUP_RETENTION:-24}"
    
    print_status "Cleaning backups older than ${retention_hours} hours..."
    
    local cleaned=0
    
    # Clean in both directories
    for dir in "$LOCAL_AGENTS_DIR" "$TEMPLATE_AGENTS_DIR"; do
        if [[ -d "$dir" ]]; then
            find "$dir" -name "*.backup.*" -type f | while read -r backup; do
                local timestamp=$(echo "$backup" | sed 's/.*\.backup\.//')
                if [[ "$timestamp" =~ ^[0-9]+$ ]]; then
                    local current_time=$(date +%s)
                    local age_hours=$(( (current_time - timestamp) / 3600 ))
                    
                    if [[ $age_hours -gt $retention_hours ]]; then
                        rm -f "$backup"
                        print_status "Removed old backup: $(basename "$backup")"
                        ((cleaned++))
                    fi
                fi
            done
        fi
    done
    
    print_success "Cleaned $cleaned old backup files"
}

# Function to show usage
show_usage() {
    cat << EOF
Agent Sync and Cross-Check Script for Claude Code

Usage: $0 [command] [options]

Commands:
    auto-sync, a       Automatic bidirectional sync (default)
    check, c           Cross-check agents between directories  
    sync, s            Sync agents from templates to local
    sync-dev, sd       Sync agents from local to templates (development)
    list, l            List all agents in both directories
    diff, d <agent>    Show detailed diff for specific agent
    clean              Clean old backup files
    help, h            Show this help message

Options:
    --dry-run, -n      Show what would be done without making changes
    --verbose, -v      Show detailed output including diffs
    --no-backup        Don't create backup files
    --yes, -y          Automatic yes to prompts
    --help, -h         Show help message

Examples:
    $0                          # Automatic bidirectional sync
    $0 --dry-run                # Preview auto-sync changes
    $0 check                    # Cross-check agents only
    $0 check --verbose          # Cross-check with detailed diffs
    $0 sync                     # Force sync from templates to local
    $0 sync-dev                 # Force sync from local to templates
    $0 diff test-fixer.md       # Show diff for specific agent
    $0 clean                    # Clean old backups

Environment Variables:
    AGENT_SYNC_BACKUP_RETENTION   Hours to keep backups (default: 24)

Directory Structure:
    Local agents:     $LOCAL_AGENTS_DIR
    Template agents:  $TEMPLATE_AGENTS_DIR
    Commands:         $TEMPLATE_COMMANDS_DIR

EOF
}

# Parse command line arguments
COMMAND=""
AGENT_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        auto-sync|a)
            COMMAND="auto-sync"
            shift
            ;;
        check|c)
            COMMAND="check"
            shift
            ;;
        sync|s)
            COMMAND="sync"
            shift
            ;;
        sync-dev|sd)
            COMMAND="sync-dev"
            shift
            ;;
        list|l)
            COMMAND="list"
            shift
            ;;
        diff|d)
            COMMAND="diff"
            shift
            AGENT_NAME="$1"
            shift
            ;;
        clean)
            COMMAND="clean"
            shift
            ;;
        help|h)
            show_usage
            exit 0
            ;;
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --no-backup)
            NO_BACKUP=true
            shift
            ;;
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Default command is auto-sync
if [[ -z "$COMMAND" ]]; then
    COMMAND="auto-sync"
fi

# Main execution
main() {
    # Always check directories first
    check_directories
    
    case "$COMMAND" in
        auto-sync)
            if [[ "$DRY_RUN" == "true" ]]; then
                print_status "DRY RUN MODE - No changes will be made"
            fi
            auto_sync
            ;;
        check)
            cross_check
            ;;
        sync)
            if [[ "$DRY_RUN" == "true" ]]; then
                print_status "DRY RUN MODE - No changes will be made"
            fi
            sync_to_local
            ;;
        sync-dev)
            if [[ "$DRY_RUN" == "true" ]]; then
                print_status "DRY RUN MODE - No changes will be made"
            fi
            sync_to_templates
            ;;
        list)
            list_agents "$LOCAL_AGENTS_DIR" "Local Agents"
            list_agents "$TEMPLATE_AGENTS_DIR" "Template Agents"
            ;;
        diff)
            show_diff "$AGENT_NAME"
            ;;
        clean)
            clean_backups
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main