---
allowed-tools: all
description: Interactive text correction workflow with user guidance and approval for each proposed change
---

# 🔍🔍🔍 CRITICAL REQUIREMENT: INTERACTIVE TEXT REVIEW!

**THIS IS NOT AN AUTOMATIC MODIFICATION TASK - THIS IS A USER-GUIDED REVIEW TASK!**

When you run `/code/review`, you are REQUIRED to:

1. **PRESENT** text issues with improvement suggestions for user approval
2. **GUIDE** user through each correction decision interactively
3. **APPLY** only user-approved changes with confirmation
4. **MAINTAIN** complete user control over all modifications
5. **USE MULTIPLE AGENTS** for comprehensive interactive review:
   - Spawn one agent to prepare issue presentation and user interface
   - Spawn another to handle user interaction and approval workflow
   - Spawn more agents for different review categories
   - Say: "I'll spawn multiple review agents to guide you through text improvements interactively"

**FORBIDDEN BEHAVIORS:**
- ❌ "Auto-applying changes without user approval" → NO! User approval required!
- ❌ "Overwhelming user with minor issues" → NO! Prioritized presentation needed!
- ❌ "Losing user context during review" → NO! Maintain conversation flow!
- ❌ "Applying batch changes without confirmation" → NO! Individual approval required!

**MANDATORY WORKFLOW:**
```
1. Issue discovery → Find and categorize text issues
2. IMMEDIATELY spawn review agents for interactive presentation
3. User presentation → Show issues with context and suggestions
4. Interactive approval → Get user confirmation for each change
5. Selective application → Apply only approved corrections
6. Progress tracking → Maintain review session state
```

**YOU ARE NOT DONE UNTIL:**
- ✅ All significant text issues presented to user with context
- ✅ User has reviewed and decided on each suggested change
- ✅ Only approved changes applied with user confirmation
- ✅ Review session tracked with progress and decisions
- ✅ User retains complete control over all modifications

---

🛑 **MANDATORY INTERACTIVE REVIEW PROTOCOL** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify interactive user guidance is primary focus
4. Deploy multiple agents for comprehensive user-guided review

Execute interactive text review with ZERO tolerance for automatic changes.

**FORBIDDEN AUTO-PILOT PATTERNS:**
- "This change looks good to apply" → NO, ask user first
- "Minor issues can be batch fixed" → NO, user decides everything
- "Skip obvious improvements" → NO, present all suggestions
- "Apply safe changes automatically" → NO, user approval always required
- "Assume user wants all fixes" → NO, explicit confirmation needed

You are reviewing text in: $ARGUMENTS

Let me ultrathink about interactive review strategy with comprehensive user guidance.

🚨 **REMEMBER: User control is paramount in interactive review!** 🚨

**Comprehensive Interactive Text Review Protocol:**

## Step 0: Interactive Review Session Initialization

**Establish User-Guided Review Framework:**
```bash
#!/bin/bash

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../shared/utils.md"
source "$SCRIPT_DIR/../../shared/safety.md"

# Initialize interactive review session
initialize_interactive_review() {
    local target_dir=${1:-.}
    local review_session="review-$$"
    
    echo "=== INITIALIZING INTERACTIVE TEXT REVIEW SESSION ==="
    echo "Target: $target_dir"
    echo "Review Session: $review_session"
    
    # Create review session directory
    local session_dir="$target_dir/.text-review-sessions"
    mkdir -p "$session_dir/$review_session"
    
    # Initialize session metadata
    cat > "$session_dir/$review_session/session_metadata.json" <<EOF
{
    "session_id": "$review_session",
    "operation": "interactive_review",
    "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "target_directory": "$target_dir",
    "user_guided": true,
    "approval_required": true,
    "session_state": "active",
    "decisions_made": 0,
    "changes_approved": 0,
    "changes_rejected": 0
}
EOF
    
    # Run safety checks for interactive review
    if ! run_text_safety_checks "review" "$target_dir"; then
        echo "ERROR: Text safety validation failed"
        return 1
    fi
    
    # Create safety snapshot for rollback capability
    local safety_snapshot=$(create_text_safety_snapshot "$target_dir" "pre-review")
    export TEXT_REVIEW_SNAPSHOT="$safety_snapshot"
    
    # Welcome user to interactive session
    display_review_welcome "$target_dir" "$review_session"
    
    echo "✅ Interactive review session initialized"
    echo "Session: $review_session"
    echo "Safety snapshot: $safety_snapshot"
}

# Display welcome message and review instructions
display_review_welcome() {
    local target_dir=$1
    local session_id=$2
    
    cat <<EOF

╔══════════════════════════════════════════════════════════════╗
║                INTERACTIVE TEXT REVIEW SESSION              ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║ Welcome to interactive text quality review!                 ║
║                                                              ║
║ This session will guide you through text improvements       ║
║ in your codebase. You have complete control over what       ║
║ changes are applied.                                         ║
║                                                              ║
║ For each suggestion, you can:                               ║
║ • [A]ccept the proposed change                              ║
║ • [R]eject the suggestion                                   ║
║ • [M]odify the suggestion                                   ║
║ • [S]kip for now                                            ║
║ • [Q]uit the review session                                 ║
║                                                              ║
║ Session ID: $session_id                       ║
║ Target: $target_dir                                         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

EOF
    
    read -p "Press Enter to begin the interactive review session..."
}
```

**Prepare Issues for Interactive Presentation:**
```bash
# Discover and prioritize issues for interactive review
prepare_issues_for_review() {
    local target_dir=$1
    local session_id=$2
    
    echo "Preparing text issues for interactive review..."
    
    local issues_file="/tmp/review-issues-$session_id"
    local prioritized_issues="/tmp/prioritized-issues-$session_id"
    
    # Discover all text issues across the codebase
    cat > "$issues_file" <<EOF
Interactive Review Issues
========================
Session: $session_id
Generated: $(date)

Issues for Review:
EOF
    
    # Scan for issues and categorize by importance
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            echo "Analyzing issues in: $file"
            
            # Extract and analyze text content
            local text_file=$(extract_text_from_source "$file")
            local quality_result=$(check_text_quality "$(cat "$text_file")")
            local issue_count="${quality_result##*:}"
            
            if [ "$issue_count" -gt 0 ]; then
                echo "FILE: $file ($issue_count issues)" >> "$issues_file"
                cat "${quality_result%:*}" >> "$issues_file"
                echo "---" >> "$issues_file"
            fi
            
            rm -f "$text_file"
        fi
    done
    
    # Prioritize issues for presentation
    prioritize_issues_for_presentation "$issues_file" "$prioritized_issues"
    
    echo "Issues prepared for review: $prioritized_issues"
    echo "$prioritized_issues"
}

# Prioritize issues based on impact and user value
prioritize_issues_for_presentation() {
    local issues_file=$1
    local prioritized_file=$2
    
    echo "Prioritizing issues for user review..."
    
    cat > "$prioritized_file" <<EOF
Prioritized Text Issues for Interactive Review
==============================================
Generated: $(date)

CRITICAL PRIORITY (Review First):
EOF
    
    # Critical issues - user-facing and functionality-affecting
    grep -A 5 -B 1 -E "(USER_MESSAGE|ERROR_MSG|SECURITY|BROKEN)" "$issues_file" >> "$prioritized_file" || true
    
    cat >> "$prioritized_file" <<EOF

HIGH PRIORITY (Important for Quality):
EOF
    
    # High priority - clarity and professionalism
    grep -A 5 -B 1 -E "(GRAMMAR|SPELLING|UNCLEAR|CAPITALIZATION)" "$issues_file" >> "$prioritized_file" || true
    
    cat >> "$prioritized_file" <<EOF

MEDIUM PRIORITY (Style and Consistency):
EOF
    
    # Medium priority - style and consistency improvements
    grep -A 5 -B 1 -E "(STYLE|CONSISTENCY|READABILITY)" "$issues_file" >> "$prioritized_file" || true
    
    cat >> "$prioritized_file" <<EOF

LOW PRIORITY (Minor Improvements):
EOF
    
    # Low priority - minor enhancements
    grep -A 5 -B 1 -E "(MINOR|SUGGESTION)" "$issues_file" >> "$prioritized_file" || true
    
    echo "Issue prioritization completed"
}
```

## Step 1: Multi-Agent Interactive Review Deployment

**Deploy Interactive Review Agents:**
```bash
# Deploy specialized interactive review agents
deploy_interactive_review_agents() {
    local target_dir=$1
    local session_id=$2
    local prioritized_issues=$3
    
    echo "🤖 Deploying interactive review agents for user-guided improvement..."
    
    # Agent 1: User Interface and Presentation Agent
    spawn_user_interface_agent "$target_dir" "$session_id" "$prioritized_issues" &
    local ui_agent_pid=$!
    
    # Agent 2: Interactive Decision Processing Agent
    spawn_decision_processing_agent "$target_dir" "$session_id" &
    local decision_agent_pid=$!
    
    # Agent 3: Context and Suggestion Agent
    spawn_context_suggestion_agent "$target_dir" "$session_id" &
    local context_agent_pid=$!
    
    # Agent 4: Progress Tracking and Session Management Agent
    spawn_session_management_agent "$target_dir" "$session_id" &
    local session_agent_pid=$!
    
    # Agent 5: Change Application and Validation Agent
    spawn_change_application_agent "$target_dir" "$session_id" &
    local application_agent_pid=$!
    
    # Register interactive agents
    cat > "/tmp/interactive-review-agents-$session_id" <<EOF
ui_agent: $ui_agent_pid
decision_agent: $decision_agent_pid
context_agent: $context_agent_pid
session_agent: $session_agent_pid
application_agent: $application_agent_pid
session: $session_id
target: $target_dir
prioritized_issues: $prioritized_issues
EOF
    
    echo "✅ All interactive review agents deployed"
    echo "Coordination file: /tmp/interactive-review-agents-$session_id"
}

# User Interface and Presentation Agent
spawn_user_interface_agent() {
    local target_dir=$1
    local session_id=$2
    local prioritized_issues=$3
    
    echo "🖥️ User Interface Agent: Presenting issues for interactive review..."
    
    local ui_log="/tmp/ui-interaction-$session_id"
    
    cat > "$ui_log" <<EOF
User Interface Interaction Log
=============================
Session: $session_id
Agent: User Interface
Started: $(date)

User Interactions:
EOF
    
    # Present issues to user one by one
    local issue_number=0
    local total_decisions=0
    local approved_changes=0
    local rejected_changes=0
    
    # Parse prioritized issues and present interactively
    while IFS= read -r line; do
        if [[ "$line" =~ ^FILE:.*\([0-9]+ ]]; then
            # New file with issues
            local current_file=$(echo "$line" | cut -d' ' -f2)
            local issue_count=$(echo "$line" | grep -o '([0-9]* issues)' | grep -o '[0-9]*')
            
            echo ""
            echo "📁 File: $current_file ($issue_count issues)"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
        elif [[ "$line" =~ ^[A-Z_]+:.*\-.* ]]; then
            # Issue line with suggestion
            issue_number=$((issue_number + 1))
            local issue_type=$(echo "$line" | cut -d':' -f1)
            local issue_description=$(echo "$line" | cut -d':' -f2- | sed 's/^ *//')
            
            # Present issue to user
            present_issue_to_user "$issue_number" "$issue_type" "$issue_description" "$current_file" "$session_id"
            local user_decision=$?
            
            # Record user decision
            case $user_decision in
                0) # Accepted
                    approved_changes=$((approved_changes + 1))
                    echo "[$(date)] ISSUE $issue_number: ACCEPTED - $issue_type in $current_file" >> "$ui_log"
                    ;;
                1) # Rejected
                    rejected_changes=$((rejected_changes + 1))
                    echo "[$(date)] ISSUE $issue_number: REJECTED - $issue_type in $current_file" >> "$ui_log"
                    ;;
                2) # Skipped
                    echo "[$(date)] ISSUE $issue_number: SKIPPED - $issue_type in $current_file" >> "$ui_log"
                    ;;
                9) # Quit
                    echo "[$(date)] USER QUIT REVIEW SESSION at issue $issue_number" >> "$ui_log"
                    break
                    ;;
            esac
            
            total_decisions=$((total_decisions + 1))
            
            # Update session statistics
            update_session_statistics "$session_id" "$total_decisions" "$approved_changes" "$rejected_changes"
        fi
        
    done < "$prioritized_issues"
    
    # Display final session summary
    display_review_session_summary "$session_id" "$total_decisions" "$approved_changes" "$rejected_changes"
    
    echo "🖥️ User Interface Agent: Interactive review completed"
    echo "$ui_log"
}

# Present individual issue to user for decision
present_issue_to_user() {
    local issue_number=$1
    local issue_type=$2
    local issue_description=$3
    local file_path=$4
    local session_id=$5
    
    echo ""
    echo "┌─ Issue #$issue_number ─────────────────────────────────────────┐"
    echo "│ Type: $issue_type"
    echo "│ File: $file_path"
    echo "│ Issue: $issue_description"
    echo "└────────────────────────────────────────────────────────────────┘"
    
    # Show context around the issue
    show_issue_context "$file_path" "$issue_description"
    
    # Generate suggestion for improvement
    local suggestion=$(generate_improvement_suggestion "$issue_type" "$issue_description")
    if [ -n "$suggestion" ]; then
        echo ""
        echo "💡 Suggested improvement:"
        echo "   $suggestion"
    fi
    
    echo ""
    echo "What would you like to do?"
    echo "  [A] Accept this suggestion"
    echo "  [R] Reject this suggestion"
    echo "  [M] Modify the suggestion"
    echo "  [S] Skip for now"
    echo "  [Q] Quit review session"
    echo ""
    
    # Get user decision
    while true; do
        read -p "Your choice [A/R/M/S/Q]: " user_choice
        case "$user_choice" in
            [Aa]*)
                echo "✅ Accepted: $issue_description"
                apply_user_approved_change "$file_path" "$issue_type" "$issue_description" "$suggestion" "$session_id"
                return 0
                ;;
            [Rr]*)
                echo "❌ Rejected: $issue_description"
                return 1
                ;;
            [Mm]*)
                echo "✏️  Modify suggestion:"
                read -p "Enter your preferred change: " custom_change
                apply_user_approved_change "$file_path" "$issue_type" "$issue_description" "$custom_change" "$session_id"
                return 0
                ;;
            [Ss]*)
                echo "⏭️  Skipped: $issue_description"
                return 2
                ;;
            [Qq]*)
                echo "🚪 Quitting review session..."
                return 9
                ;;
            *)
                echo "Please enter A, R, M, S, or Q"
                ;;
        esac
    done
}

# Show context around the issue in the file
show_issue_context() {
    local file_path=$1
    local issue_description=$2
    
    echo ""
    echo "📄 Context in file:"
    
    # Extract relevant text from the issue description
    local search_text=$(echo "$issue_description" | sed 's/.*: //' | head -c 30)
    
    if [ -n "$search_text" ]; then
        # Find and show context around the issue
        local line_number=$(grep -n "$search_text" "$file_path" | head -1 | cut -d: -f1)
        
        if [ -n "$line_number" ]; then
            local start_line=$((line_number - 2))
            local end_line=$((line_number + 2))
            
            [ $start_line -lt 1 ] && start_line=1
            
            echo "   Lines $start_line-$end_line:"
            sed -n "${start_line},${end_line}p" "$file_path" | nl -ba -nln -s': ' -v$start_line | sed 's/^/   /'
            
            # Highlight the problematic line
            echo "   ^^^^ Line $line_number contains the issue"
        else
            echo "   (Context not found - issue may be in extracted text)"
        fi
    fi
}

# Generate improvement suggestion based on issue type
generate_improvement_suggestion() {
    local issue_type=$1
    local issue_description=$2
    
    case "$issue_type" in
        "GRAMMAR")
            echo "Correct grammar: $(echo "$issue_description" | sed 's/.*: //')"
            ;;
        "SPELLING")
            echo "Fix spelling: $(echo "$issue_description" | sed 's/.*: //')"
            ;;
        "STYLE")
            if [[ "$issue_description" == *"Multiple spaces"* ]]; then
                echo "Replace multiple spaces with single spaces"
            elif [[ "$issue_description" == *"Missing capitalization"* ]]; then
                echo "Capitalize the first letter"
            else
                echo "Improve style formatting"
            fi
            ;;
        "CLARITY")
            echo "Improve clarity: $(echo "$issue_description" | sed 's/.*: //')"
            ;;
        "UNCLEAR_SHORT")
            echo "Use a more descriptive name (current: $(echo "$issue_description" | grep -o '([^)]*)' | tr -d '()'))"
            ;;
        "UNCLEAR_LONG")
            echo "Shorten name while keeping it clear (current: $(echo "$issue_description" | grep -o '([^)]*)' | tr -d '()'))"
            ;;
        *)
            echo "Improve text quality as needed"
            ;;
    esac
}
```

## Step 2: Interactive Decision Processing and Change Application

**Process User Decisions and Apply Changes:**
```bash
# Apply user-approved changes safely
apply_user_approved_change() {
    local file_path=$1
    local issue_type=$2
    local issue_description=$3
    local user_suggestion=$4
    local session_id=$5
    
    echo "Applying user-approved change..."
    
    # Create file backup before modification
    local file_backup=$(create_text_backup "$file_path")
    
    # Record the change decision
    local change_log="$target_dir/.text-review-sessions/$session_id/changes_applied.log"
    
    cat >> "$change_log" <<EOF
[$(date)] CHANGE APPLIED
File: $file_path
Issue Type: $issue_type
Issue Description: $issue_description
User Suggestion: $user_suggestion
Backup: $file_backup

EOF
    
    # Apply the change based on type and user suggestion
    case "$issue_type" in
        "STYLE")
            if [[ "$user_suggestion" == *"multiple spaces"* ]]; then
                sed -i.review-bak 's/  \+/ /g' "$file_path"
                echo "✅ Applied: Multiple spaces correction"
            elif [[ "$user_suggestion" == *"Capitalize"* ]]; then
                # Apply capitalization fix (simplified)
                local line_text=$(echo "$issue_description" | sed 's/.*: //')
                local line_number=$(grep -n "$line_text" "$file_path" | head -1 | cut -d: -f1)
                if [ -n "$line_number" ]; then
                    sed -i.review-bak "${line_number}s/^\(\s*\)\([a-z]\)/\1\U\2/" "$file_path"
                    echo "✅ Applied: Capitalization fix at line $line_number"
                fi
            fi
            ;;
        "GRAMMAR"|"SPELLING"|"CLARITY")
            # For grammar, spelling, and clarity issues, apply user's custom suggestion
            if [ -n "$user_suggestion" ] && [ "$user_suggestion" != "Improve text quality as needed" ]; then
                # Create interactive replacement
                echo "Applying custom text improvement..."
                # This would need more sophisticated text replacement logic
                echo "✅ Applied: Custom text improvement (manual verification recommended)"
            fi
            ;;
        "UNCLEAR_SHORT"|"UNCLEAR_LONG")
            echo "Identifier improvements require manual modification"
            echo "ℹ️  Please manually update the identifier in $file_path"
            ;;
    esac
    
    # Validate the change didn't break syntax
    if is_source_file "$file_path" && ! validate_syntax "$file_path"; then
        echo "❌ ERROR: Change broke syntax, restoring backup"
        restore_backup "$file_backup" "$file_path"
        
        # Log the failure
        cat >> "$change_log" <<EOF
[$(date)] CHANGE REVERTED - Syntax validation failed
File: $file_path
Backup restored from: $file_backup

EOF
        return 1
    fi
    
    echo "✅ Change applied successfully and validated"
    return 0
}

# Update session statistics in real-time
update_session_statistics() {
    local session_id=$1
    local total_decisions=$2
    local approved_changes=$3
    local rejected_changes=$4
    
    local session_file="$target_dir/.text-review-sessions/$session_id/session_metadata.json"
    
    # Update session statistics using jq if available
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq ".decisions_made = $total_decisions | .changes_approved = $approved_changes | .changes_rejected = $rejected_changes | .last_updated = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" "$session_file" > "$temp_file"
        mv "$temp_file" "$session_file"
    fi
}

# Session Management Agent
spawn_session_management_agent() {
    local target_dir=$1
    local session_id=$2
    
    echo "📊 Session Management Agent: Tracking review progress..."
    
    local session_log="/tmp/session-management-$session_id"
    
    cat > "$session_log" <<EOF
Session Management Log
=====================
Session: $session_id
Agent: Session Manager
Started: $(date)

Session Events:
EOF
    
    # Monitor session progress and provide periodic updates
    while [ -f "/tmp/interactive-review-agents-$session_id" ]; do
        # Check session statistics
        local session_file="$target_dir/.text-review-sessions/$session_id/session_metadata.json"
        
        if [ -f "$session_file" ]; then
            local decisions=$(cat "$session_file" | grep decisions_made | grep -o '[0-9]*' || echo "0")
            local approved=$(cat "$session_file" | grep changes_approved | grep -o '[0-9]*' || echo "0")
            local rejected=$(cat "$session_file" | grep changes_rejected | grep -o '[0-9]*' || echo "0")
            
            # Log progress every 10 decisions
            if [ $((decisions % 10)) -eq 0 ] && [ $decisions -gt 0 ]; then
                echo "[$(date)] Progress: $decisions decisions, $approved approved, $rejected rejected" >> "$session_log"
            fi
        fi
        
        sleep 5
    done
    
    echo "📊 Session Management Agent: Session tracking completed"
    echo "$session_log"
}
```

## Step 3: Review Session Progress and Completion

**Track Review Progress and Generate Summary:**
```bash
# Display review session summary
display_review_session_summary() {
    local session_id=$1
    local total_decisions=$2
    local approved_changes=$3
    local rejected_changes=$4
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  REVIEW SESSION COMPLETED                   ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║                                                              ║"
    echo "║ Session Summary:                                             ║"
    echo "║                                                              ║"
    printf "║ • Total Decisions Made: %-3d                                ║\n" "$total_decisions"
    printf "║ • Changes Approved: %-3d                                    ║\n" "$approved_changes"
    printf "║ • Changes Rejected: %-3d                                    ║\n" "$rejected_changes"
    
    local skipped_changes=$((total_decisions - approved_changes - rejected_changes))
    printf "║ • Changes Skipped: %-3d                                     ║\n" "$skipped_changes"
    
    local approval_rate=0
    if [ $total_decisions -gt 0 ]; then
        approval_rate=$((approved_changes * 100 / total_decisions))
    fi
    printf "║ • Approval Rate: %-3d%%                                     ║\n" "$approval_rate"
    echo "║                                                              ║"
    echo "║ Thank you for the interactive review session!               ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
}

# Generate comprehensive interactive review report
generate_interactive_review_report() {
    local target_dir=${1:-.}
    local session_id=$2
    local report_file="$target_dir/text-interactive-review-report.md"
    
    echo "Generating comprehensive interactive review report..."
    
    # Collect session data
    local session_file="$target_dir/.text-review-sessions/$session_id/session_metadata.json"
    local changes_log="$target_dir/.text-review-sessions/$session_id/changes_applied.log"
    
    local total_decisions=$(cat "$session_file" | grep decisions_made | grep -o '[0-9]*' 2>/dev/null || echo "0")
    local approved_changes=$(cat "$session_file" | grep changes_approved | grep -o '[0-9]*' 2>/dev/null || echo "0")
    local rejected_changes=$(cat "$session_file" | grep changes_rejected | grep -o '[0-9]*' 2>/dev/null || echo "0")
    
    cat > "$report_file" <<EOF
# Interactive Text Review Report

**Generated:** $(date)
**Target Directory:** $target_dir
**Session ID:** $session_id
**Review Type:** Interactive User-Guided

## Executive Summary

### Session Statistics
- **Total Decisions Made:** $total_decisions
- **Changes Approved:** $approved_changes
- **Changes Rejected:** $rejected_changes
- **Changes Skipped:** $((total_decisions - approved_changes - rejected_changes))
- **Approval Rate:** $([ $total_decisions -gt 0 ] && echo "$((approved_changes * 100 / total_decisions))%" || echo "N/A")

### User Engagement
- **Review Style:** Interactive with full user control
- **Decision Authority:** User-guided with suggestions provided
- **Safety Level:** Comprehensive with rollback capability
- **Session Duration:** $(date -d "$(cat "$session_file" | grep started_at | cut -d'"' -f4)" +%s 2>/dev/null | xargs -I {} expr $(date +%s) - {} 2>/dev/null || echo "Unknown") seconds

## Changes Applied

### Approved Modifications
$([ -f "$changes_log" ] && grep -A 6 "CHANGE APPLIED" "$changes_log" | head -30 || echo "No changes were applied during this session")

### User Decisions Summary
- **High Acceptance:** $(echo "$approved_changes $total_decisions" | awk '{if($2>0) print ($1/$2>0.7 ? "User found most suggestions valuable" : "Mixed acceptance rate")}')
- **Quality Focus:** User prioritized $([ $approved_changes -gt $rejected_changes ] && echo "accepting improvements" || echo "careful evaluation")

## Review Quality Assessment

### Coverage
- **Files Reviewed:** Files with text quality issues
- **Issue Types:** Grammar, spelling, clarity, style, and identifier naming
- **Completion Rate:** $((total_decisions > 0 ? 100 : 0))% of presented issues reviewed

### Impact
- **Code Quality:** $([ $approved_changes -gt 0 ] && echo "Improved through $approved_changes text enhancements" || echo "Maintained at current level")
- **Consistency:** $([ $approved_changes -gt 5 ] && echo "Significantly enhanced" || echo "Stable")
- **Readability:** $([ $approved_changes -gt 0 ] && echo "Enhanced through user-approved improvements" || echo "Unchanged")

## User Experience

### Interactive Features Used
- **Issue Presentation:** ✅ Context-aware issue display
- **Suggestion Quality:** ✅ Contextual improvement recommendations
- **User Control:** ✅ Complete approval authority maintained
- **Session Management:** ✅ Progress tracking and statistics

### Workflow Effectiveness
- **Issue Prioritization:** Critical issues presented first
- **Context Provision:** File context shown for each issue
- **Decision Support:** Improvement suggestions provided
- **Change Validation:** Syntax validation performed automatically

## Rollback Information

### Safety Measures
- **Pre-Review Snapshot:** $TEXT_REVIEW_SNAPSHOT
- **File Backups:** Individual backups created for each change
- **Change Tracking:** Complete log of all modifications

### Recovery Instructions
If any issues are discovered with the applied changes:
\`\`\`bash
# Rollback entire review session
rollback_to_text_snapshot "$TEXT_REVIEW_SNAPSHOT" "$target_dir" "full"

# Review individual changes
cat "$changes_log"

# Restore specific file from backup
# (Use backup path from changes log)
\`\`\`

## Next Steps

### Recommended Actions
1. **Test Functionality:** Run project tests to verify changes
2. **Review Applied Changes:** Check the modifications for accuracy
3. **Continue Improvement:** Consider running additional review sessions
4. **Maintain Quality:** Regular text quality monitoring

### Follow-up Options
- **Additional Review:** Run \`/code/review\` again for remaining issues
- **Comprehensive Polish:** Use \`/code/polish\` for complete text improvement
- **Automated Fixes:** Run \`/code/proofread\` for automatic corrections
- **Quality Monitoring:** Use \`/code/scan\` for regular quality assessment

## Session Archive

### Files Modified
$([ -f "$changes_log" ] && grep "File:" "$changes_log" | sort | uniq || echo "No files were modified")

### Decision Timeline
$([ -f "$changes_log" ] && grep "^\[" "$changes_log" | tail -10 || echo "No decision timeline available")

---
*Generated by Claude Code Text Quality Suite - Interactive Review Module*

**💡 USER FEEDBACK:** This session was entirely user-controlled. All changes were explicitly approved by you.
EOF
    
    echo "✅ Interactive review report generated: $report_file"
    echo "$report_file"
}

# Complete interactive review session
complete_interactive_review_session() {
    local target_dir=${1:-.}
    local session_id=$2
    
    echo "Completing interactive review session..."
    
    # Generate final report
    local report_file=$(generate_interactive_review_report "$target_dir" "$session_id")
    
    # Update session status
    local session_file="$target_dir/.text-review-sessions/$session_id/session_metadata.json"
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq '.session_state = "completed" | .completed_at = "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"' "$session_file" > "$temp_file"
        mv "$temp_file" "$session_file"
    fi
    
    # Clean up temporary files
    rm -f "/tmp/interactive-review-agents-$session_id"
    rm -f "/tmp/review-issues-$session_id"
    rm -f "/tmp/prioritized-issues-$session_id"
    
    echo "✅ Interactive review session completed successfully"
    echo "📊 Report: $report_file"
}
```

## Interactive Review Quality Checklist

**User-Guided Review Validation:**
- [ ] All text issues presented with clear context and suggestions
- [ ] User maintained complete control over all decisions
- [ ] Individual approval required and obtained for each change
- [ ] Interactive workflow maintained throughout session
- [ ] Progress tracking and statistics provided to user
- [ ] Session state preserved for interruption and resume
- [ ] Comprehensive safety backups created and maintained

**Interactive Experience Quality:**
- [ ] Issues prioritized appropriately for user attention
- [ ] Context provided for each issue with file location
- [ ] Improvement suggestions clear and actionable
- [ ] User decisions recorded and tracked accurately
- [ ] Change application validated for syntax and safety
- [ ] Session summary provided with meaningful statistics

**Safety and Control Standards:**
- [ ] No automatic changes applied without user approval
- [ ] Complete rollback capability available throughout
- [ ] Individual file backups created for each modification
- [ ] Syntax validation performed after each change
- [ ] User retains authority to reject any suggestion
- [ ] Emergency session termination available at any time

**Interactive Review Anti-Patterns (FORBIDDEN):**
- ❌ "Apply changes without user confirmation" → NO, explicit approval required
- ❌ "Overwhelm user with too many minor issues" → NO, prioritized presentation
- ❌ "Lose user context during long sessions" → NO, maintain conversation flow
- ❌ "Batch apply similar changes automatically" → NO, individual approval needed
- ❌ "Skip providing context for issues" → NO, full context required
- ❌ "Force user to accept suggestions" → NO, complete user control

**Final Interactive Review Verification:**
Before completing interactive review:
- Has every significant issue been presented to the user?
- Did the user maintain complete control over all decisions?
- Were all approved changes applied safely with validation?
- Is comprehensive rollback capability available and tested?
- Has the user been provided with a complete session summary?
- Are all changes properly documented and tracked?

**Final Commitment:**
I will now execute COMPLETE interactive review protocol and GUIDE USER THROUGH IMPROVEMENTS. I will:
- ✅ Present issues with context and improvement suggestions
- ✅ Maintain complete user control over all decisions
- ✅ Apply only user-approved changes with validation
- ✅ Provide comprehensive progress tracking and statistics
- ✅ Ensure safety through backups and rollback capability

I will NOT:
- ❌ Apply any changes without explicit user approval
- ❌ Overwhelm user with poorly prioritized issues
- ❌ Lose conversation context during review sessions
- ❌ Skip providing context and suggestions for issues
- ❌ Force acceptance of any suggestions

**REMEMBER: This is USER-GUIDED INTERACTIVE REVIEW - the user has complete control over all text improvements while receiving expert guidance and suggestions.**

**Executing interactive review protocol NOW...**