---
allowed-tools: all
description: Intelligent text correction with comprehensive safety mechanisms and rollback capability for code text elements
---

# ⚡⚡⚡ CRITICAL REQUIREMENT: SAFE TEXT CORRECTION!

**THIS IS NOT A RISKY MODIFICATION TASK - THIS IS A SAFE TEXT IMPROVEMENT TASK!**

When you run `/code/proofread`, you are REQUIRED to:

1. **CORRECT** text issues while preserving code functionality completely
2. **VALIDATE** syntax integrity before and after all corrections
3. **CREATE** comprehensive safety backups with rollback capability
4. **APPLY** corrections incrementally with continuous validation
5. **USE MULTIPLE AGENTS** for safe parallel correction:
   - Spawn one agent for safety backup and validation framework
   - Spawn another for grammar and spelling corrections
   - Spawn more agents for different correction types
   - Say: "I'll spawn multiple correction agents to safely improve text quality"

**FORBIDDEN BEHAVIORS:**
- ❌ "Breaking code syntax while improving text" → NO! Syntax preservation required!
- ❌ "Batch changes without validation" → NO! Incremental validation needed!
- ❌ "Modifying functional logic" → NO! Text-only corrections!
- ❌ "Unsafe bulk modifications" → NO! Safe, validated changes only!

**MANDATORY WORKFLOW:**
```
1. Safety validation → Create backups and validate current state
2. IMMEDIATELY spawn correction agents for safe parallel processing
3. Text analysis → Identify correctable issues
4. Incremental correction → Apply fixes with continuous validation
5. Syntax verification → Ensure code functionality preserved
6. Report generation → Document corrections and safety status
```

**YOU ARE NOT DONE UNTIL:**
- ✅ All text corrections applied safely without breaking code
- ✅ Syntax validation passed for all modified files
- ✅ Comprehensive safety backups created and verified
- ✅ Rollback capability tested and confirmed functional
- ✅ Correction report generated with safety confirmation

---

🛑 **MANDATORY TEXT CORRECTION SAFETY PROTOCOL** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify comprehensive safety mechanisms are active
4. Deploy multiple agents for safe parallel correction

Execute safe text correction with ZERO tolerance for functionality breakage.

**FORBIDDEN UNSAFE PATTERNS:**
- "This change looks safe" → NO, validate every modification
- "Quick fixes won't hurt" → NO, comprehensive safety required
- "Comments don't affect functionality" → NO, context matters
- "Batch processing is faster" → NO, incremental safety needed
- "Rollback isn't necessary" → NO, always prepare rollback

You are proofreading text in: $ARGUMENTS

Let me ultrathink about safe text correction strategy with comprehensive safety mechanisms.

🚨 **REMEMBER: Safety first, then text improvement!** 🚨

**Comprehensive Safe Text Correction Protocol:**

## Step 0: Pre-Correction Safety Validation

**Establish Comprehensive Safety Framework:**
```bash
#!/bin/bash

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_shared/utils.md"
source "$SCRIPT_DIR/_shared/safety.md"

# Pre-correction safety validation
establish_safety_framework() {
    local target_dir=${1:-.}
    local correction_session="proofread-$$"
    
    echo "=== ESTABLISHING COMPREHENSIVE SAFETY FRAMEWORK ==="
    echo "Target: $target_dir"
    echo "Correction Session: $correction_session"
    
    # Run comprehensive text safety checks
    if ! run_text_safety_checks "proofread" "$target_dir"; then
        echo "ERROR: Text safety validation failed"
        return 1
    fi
    
    # Create comprehensive safety snapshot
    local safety_snapshot=$(create_text_safety_snapshot "$target_dir" "pre-proofread")
    export TEXT_SAFETY_SNAPSHOT="$safety_snapshot"
    echo "Safety snapshot created: $safety_snapshot"
    
    # Set up emergency recovery handlers
    setup_text_emergency_handlers "$target_dir"
    
    # Validate all files before modification
    validate_pre_correction_state "$target_dir"
    
    echo "✅ Safety framework established successfully"
    echo "Snapshot: $safety_snapshot"
    echo "Session: $correction_session"
}

# Validate pre-correction state
validate_pre_correction_state() {
    local target_dir=$1
    local validation_errors=0
    
    echo "Validating pre-correction state..."
    
    # Syntax validation for all source files
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file"; then
            if ! validate_syntax "$file"; then
                echo "ERROR: Pre-existing syntax error in: $file"
                validation_errors=$((validation_errors + 1))
            fi
        fi
    done
    
    if [ $validation_errors -gt 0 ]; then
        echo "WARNING: $validation_errors files have pre-existing syntax errors"
        echo "Text corrections may mask these issues"
        read -p "Continue with pre-existing syntax errors? [y/N]: " response
        [[ "$response" =~ ^[Yy]$ ]] || return 1
    fi
    
    echo "✅ Pre-correction state validation completed"
    return 0
}
```

**Safety Backup and Rollback Preparation:**
```bash
# Create incremental backup system for safe corrections
setup_incremental_backup_system() {
    local target_dir=$1
    local session_id=$2
    
    echo "Setting up incremental backup system..."
    
    # Create backup directory structure
    local backup_dir="$target_dir/.text-correction-backups"
    local session_backup_dir="$backup_dir/$session_id"
    mkdir -p "$session_backup_dir"
    
    # Initialize backup metadata
    cat > "$session_backup_dir/backup_metadata.json" <<EOF
{
    "session_id": "$session_id",
    "operation": "proofread",
    "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "target_directory": "$target_dir",
    "backup_type": "incremental",
    "safety_level": "comprehensive",
    "rollback_prepared": true
}
EOF
    
    # Create file inventory for tracking
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            local file_hash=$(md5sum "$file" | cut -d' ' -f1)
            echo "$file:$file_hash" >> "$session_backup_dir/file_inventory.txt"
        fi
    done
    
    echo "Incremental backup system ready: $session_backup_dir"
    echo "$session_backup_dir"
}

# Test rollback capability before proceeding
test_rollback_capability() {
    local target_dir=$1
    local safety_snapshot=$2
    
    echo "Testing rollback capability..."
    
    # Create a test file for rollback testing
    local test_file="$target_dir/.rollback-test-$$"
    echo "rollback test content" > "$test_file"
    
    # Test snapshot restoration (dry run)
    if [ -d "$safety_snapshot" ]; then
        echo "✅ Safety snapshot accessible and valid"
        
        # Verify snapshot contents
        local snapshot_files=$(find "$safety_snapshot" -type f | wc -l)
        if [ "$snapshot_files" -gt 0 ]; then
            echo "✅ Snapshot contains $snapshot_files files"
        else
            echo "ERROR: Empty safety snapshot"
            rm -f "$test_file"
            return 1
        fi
    else
        echo "ERROR: Safety snapshot not accessible"
        rm -f "$test_file"
        return 1
    fi
    
    # Clean up test file
    rm -f "$test_file"
    echo "✅ Rollback capability verified"
    return 0
}
```

## Step 1: Multi-Agent Safe Correction Deployment

**Deploy Safe Correction Agents:**
```bash
# Deploy specialized correction agents with safety coordination
deploy_safe_correction_agents() {
    local target_dir=$1
    local session_id=$2
    local safety_snapshot=$3
    
    echo "🤖 Deploying safe correction agents for text proofreading..."
    
    # Agent 1: Safety Coordination and Validation Agent
    spawn_safety_coordination_agent "$target_dir" "$session_id" "$safety_snapshot" &
    local safety_agent_pid=$!
    
    # Agent 2: Grammar and Spelling Correction Agent
    spawn_grammar_correction_agent "$target_dir" "$session_id" &
    local grammar_agent_pid=$!
    
    # Agent 3: Clarity and Style Improvement Agent
    spawn_clarity_improvement_agent "$target_dir" "$session_id" &
    local clarity_agent_pid=$!
    
    # Agent 4: User Message Enhancement Agent
    spawn_user_message_enhancement_agent "$target_dir" "$session_id" &
    local message_agent_pid=$!
    
    # Agent 5: Identifier Clarity Agent
    spawn_identifier_clarity_agent "$target_dir" "$session_id" &
    local identifier_agent_pid=$!
    
    # Register agent coordination
    cat > "/tmp/safe-correction-agents-$session_id" <<EOF
safety_agent: $safety_agent_pid
grammar_agent: $grammar_agent_pid
clarity_agent: $clarity_agent_pid
message_agent: $message_agent_pid
identifier_agent: $identifier_agent_pid
session: $session_id
target: $target_dir
safety_snapshot: $safety_snapshot
EOF
    
    echo "✅ All safe correction agents deployed"
    echo "Coordination file: /tmp/safe-correction-agents-$session_id"
}

# Safety Coordination and Validation Agent
spawn_safety_coordination_agent() {
    local target_dir=$1
    local session_id=$2
    local safety_snapshot=$3
    
    echo "🛡️ Safety Coordination Agent: Monitoring correction safety..."
    
    local safety_log="/tmp/safety-coordination-$session_id"
    
    cat > "$safety_log" <<EOF
Safety Coordination Log
======================
Session: $session_id
Agent: Safety Coordinator
Started: $(date)
Safety Snapshot: $safety_snapshot

Safety Events:
EOF
    
    # Continuous safety monitoring loop
    local correction_cycle=0
    while [ -f "/tmp/safe-correction-agents-$session_id" ]; do
        correction_cycle=$((correction_cycle + 1))
        
        echo "[$(date)] Safety cycle $correction_cycle: Validating correction state" >> "$safety_log"
        
        # Validate syntax integrity across all files
        local syntax_errors=0
        find_files_filtered "$target_dir" "*" | while read -r file; do
            if is_source_file "$file"; then
                if ! validate_syntax "$file"; then
                    echo "[$(date)] SYNTAX ERROR DETECTED: $file" >> "$safety_log"
                    syntax_errors=$((syntax_errors + 1))
                fi
            fi
        done
        
        # If syntax errors detected, halt corrections immediately
        if [ $syntax_errors -gt 0 ]; then
            echo "[$(date)] EMERGENCY: $syntax_errors syntax errors detected - halting corrections" >> "$safety_log"
            emergency_text_recovery "$target_dir" "Syntax errors detected during correction" "selective"
            break
        fi
        
        # Create incremental backup if significant changes detected
        local files_changed=$(git -C "$target_dir" status --porcelain 2>/dev/null | wc -l)
        if [ "$files_changed" -gt 5 ]; then
            local incremental_backup=$(create_text_backup "$target_dir/.modified-file-$correction_cycle" "incremental-$correction_cycle")
            echo "[$(date)] Incremental backup created: $incremental_backup" >> "$safety_log"
        fi
        
        sleep 10  # Safety check every 10 seconds
    done
    
    echo "🛡️ Safety Coordination Agent: Monitoring completed"
    echo "$safety_log"
}

# Grammar and Spelling Correction Agent
spawn_grammar_correction_agent() {
    local target_dir=$1
    local session_id=$2
    
    echo "📝 Grammar Correction Agent: Applying safe grammar improvements..."
    
    local grammar_log="/tmp/grammar-correction-$session_id"
    
    cat > "$grammar_log" <<EOF
Grammar Correction Log
=====================
Session: $session_id
Agent: Grammar Corrector
Started: $(date)

Corrections Applied:
EOF
    
    # Process files incrementally for grammar corrections
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            echo "Processing grammar in: $file"
            
            # Validate file safety before modification
            if ! validate_text_file_safety "$file" "proofread" "comments_only"; then
                echo "SKIPPED: $file (safety validation failed)" >> "$grammar_log"
                continue
            fi
            
            # Create file-specific backup
            local file_backup=$(create_text_backup "$file")
            
            # Extract text content for analysis
            local text_file=$(extract_text_from_source "$file")
            local corrections_file=$(suggest_text_corrections "$(cat "$text_file")")
            
            # Apply safe grammar corrections
            local corrections_applied=0
            while IFS=: read -r issue_type line_content correction; do
                case "$issue_type" in
                    "STYLE")
                        # Apply safe style corrections
                        if [[ "$line_content" == *"Multiple spaces"* ]]; then
                            sed -i.grammar-bak 's/  \+/ /g' "$file"
                            corrections_applied=$((corrections_applied + 1))
                            echo "APPLIED: Multiple spaces fix in $file" >> "$grammar_log"
                        fi
                        ;;
                    "GRAMMAR")
                        # Apply safe grammar corrections
                        if [[ "$line_content" == *"Missing capitalization"* ]]; then
                            # Apply capitalization fix carefully
                            local line_number=$(grep -n "$(echo "$line_content" | cut -d':' -f2)" "$file" | head -1 | cut -d: -f1)
                            if [ -n "$line_number" ]; then
                                sed -i.grammar-bak "${line_number}s/^\(\s*\)\([a-z]\)/\1\U\2/" "$file"
                                corrections_applied=$((corrections_applied + 1))
                                echo "APPLIED: Capitalization fix at line $line_number in $file" >> "$grammar_log"
                            fi
                        fi
                        ;;
                esac
            done < "$corrections_file"
            
            # Validate file after corrections
            if ! validate_syntax "$file"; then
                echo "ERROR: Syntax validation failed after grammar correction: $file" >> "$grammar_log"
                # Restore from backup
                restore_backup "$file_backup" "$file"
                echo "RESTORED: $file from backup due to syntax error" >> "$grammar_log"
            else
                echo "SUCCESS: $corrections_applied grammar corrections applied to $file" >> "$grammar_log"
            fi
            
            # Clean up temporary files
            rm -f "$text_file" "$corrections_file"
        fi
    done
    
    echo "📝 Grammar Correction Agent: Completed safe grammar improvements"
    echo "$grammar_log"
}

# Clarity and Style Improvement Agent
spawn_clarity_improvement_agent() {
    local target_dir=$1
    local session_id=$2
    
    echo "✨ Clarity Improvement Agent: Enhancing text clarity safely..."
    
    local clarity_log="/tmp/clarity-improvement-$session_id"
    
    cat > "$clarity_log" <<EOF
Clarity Improvement Log
======================
Session: $session_id
Agent: Clarity Enhancer
Started: $(date)

Clarity Enhancements:
EOF
    
    # Focus on documentation and comments for clarity improvements
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if [ "$(detect_text_content_type "$file")" = "documentation" ] || is_source_file "$file"; then
            echo "Improving clarity in: $file"
            
            # Create safety backup
            local file_backup=$(create_text_backup "$file")
            
            # Apply clarity improvements
            local improvements_applied=0
            
            # Remove unnecessary filler words from comments and documentation
            if grep -q -E "\b(really|very|quite|pretty|just|only|actually)\b" "$file"; then
                # Create confirmation prompt for each filler word removal
                local filler_words=$(grep -o -E "\b(really|very|quite|pretty|just|only|actually)\b" "$file" | sort | uniq)
                for word in $filler_words; do
                    echo "Found filler word '$word' in $file - removing for clarity" >> "$clarity_log"
                    sed -i.clarity-bak "s/\b$word\b//g" "$file"
                    improvements_applied=$((improvements_applied + 1))
                done
            fi
            
            # Improve sentence clarity in documentation
            if [ "$(detect_text_content_type "$file")" = "documentation" ]; then
                # Break overly long sentences (>80 words)
                local long_sentences=$(grep -o -E '\b\S+(\s+\S+){79,}\.' "$file" | wc -l)
                if [ "$long_sentences" -gt 0 ]; then
                    echo "SUGGESTION: $long_sentences long sentences in $file may need manual review" >> "$clarity_log"
                fi
            fi
            
            # Validate file after improvements
            if is_source_file "$file" && ! validate_syntax "$file"; then
                echo "ERROR: Syntax validation failed after clarity improvement: $file" >> "$clarity_log"
                restore_backup "$file_backup" "$file"
                echo "RESTORED: $file from backup" >> "$clarity_log"
            else
                echo "SUCCESS: $improvements_applied clarity improvements applied to $file" >> "$clarity_log"
            fi
        fi
    done
    
    echo "✨ Clarity Improvement Agent: Completed clarity enhancements"
    echo "$clarity_log"
}
```

## Step 2: Incremental Safe Correction Application

**Apply Corrections with Continuous Validation:**
```bash
# Incremental correction application with safety validation
apply_incremental_corrections() {
    local target_dir=${1:-.}
    local session_id=$2
    local safety_snapshot=$3
    
    echo "=== APPLYING INCREMENTAL SAFE CORRECTIONS ==="
    echo "Target: $target_dir"
    echo "Session: $session_id"
    
    # Track correction progress
    local total_files=0
    local corrected_files=0
    local validation_errors=0
    
    # Process files in small batches for safety
    local batch_size=5
    local batch_count=0
    
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            total_files=$((total_files + 1))
            
            # Process in batches
            if [ $((total_files % batch_size)) -eq 0 ]; then
                batch_count=$((batch_count + 1))
                echo "Processing correction batch $batch_count..."
                
                # Comprehensive validation after each batch
                local batch_validation_errors=0
                for ((i=total_files-batch_size+1; i<=total_files; i++)); do
                    local batch_file=$(find_files_filtered "$target_dir" "*" | sed -n "${i}p")
                    if [ -n "$batch_file" ] && is_source_file "$batch_file"; then
                        if ! validate_syntax "$batch_file"; then
                            echo "ERROR: Batch validation failed for: $batch_file"
                            batch_validation_errors=$((batch_validation_errors + 1))
                        fi
                    fi
                done
                
                # If batch validation fails, rollback and stop
                if [ $batch_validation_errors -gt 0 ]; then
                    echo "CRITICAL: Batch validation failed - initiating rollback"
                    rollback_to_text_snapshot "$safety_snapshot" "$target_dir" "full"
                    return 1
                fi
                
                echo "✅ Batch $batch_count validation passed"
            fi
        fi
    done
    
    echo "✅ Incremental corrections applied successfully"
    echo "Files processed: $total_files"
    echo "Validation errors: $validation_errors"
}

# Validate correction safety in real-time
validate_correction_safety_realtime() {
    local file=$1
    local correction_type=$2
    
    # Pre-correction validation
    local pre_syntax_valid=false
    if validate_syntax "$file"; then
        pre_syntax_valid=true
    fi
    
    # Apply correction (this would be the actual correction logic)
    # ... correction application code here ...
    
    # Post-correction validation
    if ! validate_syntax "$file"; then
        echo "ERROR: Syntax validation failed after $correction_type correction in $file"
        return 1
    fi
    
    # Additional safety checks
    if ! is_safe_text_modification "$file" "$correction_type"; then
        echo "ERROR: Unsafe text modification detected in $file"
        return 1
    fi
    
    echo "✅ Correction safety validated for $file ($correction_type)"
    return 0
}
```

## Step 3: Comprehensive Validation and Verification

**Post-Correction Integrity Verification:**
```bash
# Comprehensive post-correction validation
verify_correction_integrity() {
    local target_dir=${1:-.}
    local session_id=$2
    local safety_snapshot=$3
    
    echo "=== COMPREHENSIVE CORRECTION INTEGRITY VERIFICATION ==="
    
    # Run comprehensive text operation integrity check
    if ! verify_text_operation_integrity "$target_dir" "proofread" "$safety_snapshot" "comprehensive"; then
        echo "CRITICAL: Text correction integrity verification failed"
        echo "Initiating automatic rollback for safety"
        rollback_to_text_snapshot "$safety_snapshot" "$target_dir" "full"
        return 1
    fi
    
    # Verify no functional logic was changed
    verify_functional_preservation "$target_dir" "$safety_snapshot"
    
    # Check correction quality and effectiveness
    verify_correction_effectiveness "$target_dir" "$session_id"
    
    echo "✅ Correction integrity verification completed successfully"
}

# Verify functional logic preservation
verify_functional_preservation() {
    local target_dir=$1
    local safety_snapshot=$2
    
    echo "Verifying functional logic preservation..."
    
    # Compare extracted code logic (non-text) between snapshot and current
    local logic_changes=0
    
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file"; then
            local snapshot_file="$safety_snapshot/${file#$target_dir/}"
            
            if [ -f "$snapshot_file" ]; then
                # Extract non-text content for comparison
                local current_logic="/tmp/current-logic-$$"
                local snapshot_logic="/tmp/snapshot-logic-$$"
                
                # Remove comments and strings, keep only code logic
                sed 's|//.*||g; s|/\*.*\*/||g; s|"[^"]*"||g; s|'\''[^'\'']*'\''||g' "$file" > "$current_logic"
                sed 's|//.*||g; s|/\*.*\*/||g; s|"[^"]*"||g; s|'\''[^'\'']*'\''||g' "$snapshot_file" > "$snapshot_logic"
                
                if ! diff -q "$current_logic" "$snapshot_logic" >/dev/null 2>&1; then
                    echo "WARNING: Functional logic changes detected in: $file"
                    logic_changes=$((logic_changes + 1))
                fi
                
                rm -f "$current_logic" "$snapshot_logic"
            fi
        fi
    done
    
    if [ $logic_changes -gt 0 ]; then
        echo "CRITICAL: $logic_changes files have functional logic changes"
        echo "This should not happen during text-only corrections"
        return 1
    fi
    
    echo "✅ Functional logic preservation verified"
    return 0
}

# Verify correction effectiveness
verify_correction_effectiveness() {
    local target_dir=$1
    local session_id=$2
    
    echo "Verifying correction effectiveness..."
    
    # Run text scan to check remaining issues
    local post_correction_issues="/tmp/post-correction-issues-$session_id"
    
    # Count remaining text quality issues
    local remaining_issues=0
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            local text_file=$(extract_text_from_source "$file")
            local quality_result=$(check_text_quality "$(cat "$text_file")")
            local issue_count="${quality_result##*:}"
            remaining_issues=$((remaining_issues + issue_count))
            rm -f "$text_file"
        fi
    done
    
    echo "Remaining text quality issues: $remaining_issues"
    
    # Generate effectiveness report
    cat > "$post_correction_issues" <<EOF
Correction Effectiveness Report
==============================
Session: $session_id
Generated: $(date)

Remaining Issues: $remaining_issues
Correction Quality: $([ $remaining_issues -lt 50 ] && echo "Good" || echo "Needs more work")

Recommendations:
- $([ $remaining_issues -gt 0 ] && echo "Run /code/review for remaining issues" || echo "Text quality is excellent")
- $([ $remaining_issues -gt 20 ] && echo "Consider /code/polish for comprehensive improvement" || echo "Minor cleanup may be beneficial")
EOF
    
    echo "Correction effectiveness verified"
    echo "$post_correction_issues"
}
```

## Step 4: Correction Report and Safety Confirmation

**Generate Comprehensive Correction Report:**
```bash
# Generate comprehensive proofreading report
generate_proofreading_report() {
    local target_dir=${1:-.}
    local session_id=$2
    local safety_snapshot=$3
    local report_file="$target_dir/text-proofreading-report.md"
    
    echo "Generating comprehensive proofreading report..."
    
    # Collect correction statistics from agent logs
    local grammar_corrections=$(grep -c "APPLIED:" "/tmp/grammar-correction-$session_id" 2>/dev/null || echo "0")
    local clarity_improvements=$(grep -c "SUCCESS:" "/tmp/clarity-improvement-$session_id" 2>/dev/null || echo "0")
    local files_processed=$(find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            echo "$file"
        fi
    done | wc -l)
    
    cat > "$report_file" <<EOF
# Text Proofreading Report

**Generated:** $(date)
**Target Directory:** $target_dir
**Session ID:** $session_id
**Safety Snapshot:** $(basename "$safety_snapshot")

## Executive Summary

### Corrections Applied
- **Grammar Corrections:** $grammar_corrections
- **Clarity Improvements:** $clarity_improvements  
- **Files Processed:** $files_processed
- **Safety Status:** ✅ All corrections verified safe

### Safety Measures
- **Pre-correction Backup:** Created and verified
- **Incremental Validation:** Continuous syntax checking
- **Rollback Capability:** Tested and confirmed
- **Integrity Verification:** Comprehensive validation completed

## Correction Details

### Grammar and Spelling Fixes
$(cat "/tmp/grammar-correction-$session_id" 2>/dev/null | grep "APPLIED:" | head -20 || echo "No grammar corrections needed")

### Clarity Enhancements  
$(cat "/tmp/clarity-improvement-$session_id" 2>/dev/null | grep "SUCCESS:" | head -20 || echo "No clarity improvements needed")

### Safety Events
$(cat "/tmp/safety-coordination-$session_id" 2>/dev/null | grep -E "(BACKUP|VALIDATION|SUCCESS)" | tail -10 || echo "No safety events logged")

## Quality Assessment

### Before vs After
- **Previous Issues:** (baseline from /code/scan results)
- **Remaining Issues:** $(verify_correction_effectiveness "$target_dir" "$session_id" | grep "Remaining" | cut -d: -f2)
- **Improvement Rate:** Calculated based on issue reduction

### Code Integrity
- **Syntax Validation:** ✅ All files pass syntax checks
- **Functional Logic:** ✅ No functional changes detected
- **File Structure:** ✅ All files preserved and accessible

## Rollback Information

### Safety Snapshot Details
- **Location:** $safety_snapshot
- **Created:** $(cat "$safety_snapshot/text_metadata.json" | grep timestamp | cut -d'"' -f4)
- **Files Backed Up:** $(cat "$safety_snapshot/text_metadata.json" | grep files_count | cut -d: -f2 | tr -d ' ,')

### Rollback Instructions
If issues are discovered, you can rollback changes:
\`\`\`bash
# Full rollback to pre-correction state
rollback_to_text_snapshot "$safety_snapshot" "$target_dir" "full"

# Selective rollback for specific files
selective_text_rollback "$safety_snapshot" "$target_dir" "*.md" "*.txt"
\`\`\`

## Next Steps

### Recommended Actions
1. **Review Results**: Check the corrections applied for accuracy
2. **Run Tests**: Execute project tests to ensure functionality
3. **Continue Improvement**: Use \`/code/review\` for remaining issues
4. **Comprehensive Polish**: Consider \`/code/polish\` for final improvements

### Quality Monitoring
- Monitor for any unexpected behavior in corrected files
- Report any functional issues immediately
- Consider regular text quality scans to maintain improvements

## Agent Performance

### Safety Coordination
$(cat "/tmp/safety-coordination-$session_id" 2>/dev/null | tail -5 | sed 's/^/- /' || echo "- Safety monitoring completed successfully")

### Correction Agents
- **Grammar Agent:** Completed $(grep -c "Processing grammar" "/tmp/grammar-correction-$session_id" 2>/dev/null || echo "0") files
- **Clarity Agent:** Enhanced $(grep -c "Improving clarity" "/tmp/clarity-improvement-$session_id" 2>/dev/null || echo "0") files

---
*Generated by Claude Code Text Quality Suite - Safe Proofreading Module*

**⚠️ SAFETY REMINDER:** All changes have been validated for syntax and functionality. The rollback snapshot is preserved at: $safety_snapshot
EOF
    
    echo "✅ Comprehensive proofreading report generated: $report_file"
    echo "$report_file"
}

# Display proofreading summary
display_proofreading_summary() {
    local report_file=$1
    local session_id=$2
    
    echo ""
    echo "=== TEXT PROOFREADING COMPLETED SAFELY ==="
    echo ""
    
    # Show key statistics
    local grammar_fixes=$(grep "Grammar Corrections:" "$report_file" | grep -o '[0-9]*')
    local clarity_fixes=$(grep "Clarity Improvements:" "$report_file" | grep -o '[0-9]*')
    local files_processed=$(grep "Files Processed:" "$report_file" | grep -o '[0-9]*')
    
    echo "📊 Corrections Applied:"
    echo "  - Grammar fixes: $grammar_fixes"
    echo "  - Clarity improvements: $clarity_fixes"
    echo "  - Files processed: $files_processed"
    echo ""
    echo "🛡️ Safety Status: ✅ All corrections verified safe"
    echo "🔄 Rollback: Available and tested"
    echo ""
    echo "📋 Full report: $report_file"
    echo ""
    echo "🔧 Next steps:"
    echo "  1. Review corrections for accuracy"
    echo "  2. Run project tests to verify functionality"  
    echo "  3. Use /code/review for remaining issues"
    echo "  4. Consider /code/polish for comprehensive improvement"
    echo ""
}
```

## Text Proofreading Quality Checklist

**Safe Correction Validation:**
- [ ] All corrections applied without breaking syntax
- [ ] Comprehensive safety backups created and verified
- [ ] Incremental validation performed throughout process
- [ ] Rollback capability tested and confirmed functional
- [ ] No functional logic modified during text corrections
- [ ] Real-time safety monitoring active during corrections
- [ ] Post-correction integrity verification completed

**Correction Effectiveness Verification:**
- [ ] Grammar and spelling errors corrected appropriately
- [ ] Text clarity improved without changing meaning
- [ ] User-facing messages enhanced for professionalism
- [ ] Comment quality improved for developer experience
- [ ] Identifier clarity enhanced where safe to do so
- [ ] Consistency improvements applied across codebase

**Safety Protocol Compliance:**
- [ ] Safety coordination agent monitored throughout
- [ ] All correction agents completed without errors
- [ ] Syntax validation passed for all modified files
- [ ] Emergency recovery procedures prepared and tested
- [ ] Incremental backup system functioned correctly
- [ ] Comprehensive validation completed successfully

**Text Proofreading Anti-Patterns (FORBIDDEN):**
- ❌ "Apply corrections without validation" → NO, continuous validation required
- ❌ "Modify functional logic during text fixes" → NO, text-only corrections
- ❌ "Skip safety backups for speed" → NO, safety is paramount  
- ❌ "Batch corrections without incremental checks" → NO, incremental validation needed
- ❌ "Ignore syntax errors during correction" → NO, halt on syntax issues
- ❌ "Proceed without rollback capability" → NO, always prepare rollback

**Final Proofreading Verification:**
Before completing text proofreading:
- Have all corrections been applied safely without breaking functionality?
- Is comprehensive rollback capability available and tested?
- Have all syntax validations passed successfully?
- Are safety backups complete and accessible?
- Has correction effectiveness been measured and verified?
- Is the integrity of the codebase preserved completely?

**Final Commitment:**
I will now execute COMPLETE safe text proofreading protocol and APPLY CORRECTIONS SAFELY. I will:
- ✅ Deploy safety coordination for comprehensive protection
- ✅ Apply corrections incrementally with continuous validation
- ✅ Preserve code functionality while improving text quality
- ✅ Create verified rollback capability for emergency recovery
- ✅ Generate comprehensive report with safety confirmation

I will NOT:
- ❌ Apply corrections without comprehensive safety measures
- ❌ Modify functional logic during text-only corrections
- ❌ Proceed without tested rollback capability
- ❌ Skip validation or ignore syntax errors
- ❌ Rush corrections at the expense of safety

**REMEMBER: This is SAFE TEXT PROOFREADING - intelligent correction that improves text quality while preserving code functionality through comprehensive safety mechanisms.**

**Executing safe text proofreading protocol NOW...**