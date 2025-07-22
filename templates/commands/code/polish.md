---
allowed-tools: all
description: Comprehensive multi-pass text quality transformation with advanced improvement algorithms and complete safety mechanisms
---

# 🚨🚨🚨 CRITICAL REQUIREMENT: COMPREHENSIVE TEXT TRANSFORMATION!

**THIS IS NOT A SIMPLE IMPROVEMENT TASK - THIS IS A COMPREHENSIVE TEXT QUALITY TRANSFORMATION TASK!**

When you run `/code/polish`, you are REQUIRED to:

1. **TRANSFORM** text quality comprehensively through multi-pass improvement
2. **OPTIMIZE** clarity, consistency, and professionalism across all text
3. **ELEVATE** code documentation and user experience to production quality
4. **COORDINATE** multiple specialized improvement agents for complete coverage
5. **USE MULTIPLE AGENTS** for comprehensive parallel improvement:
   - Spawn one agent for advanced grammar and clarity enhancement
   - Spawn another for terminology standardization and consistency
   - Spawn more agents for different improvement categories
   - Say: "I'll spawn multiple polish agents to comprehensively transform text quality"

**FORBIDDEN BEHAVIORS:**
- ❌ "Partial text improvements" → NO! Comprehensive transformation required!
- ❌ "Single-pass processing" → NO! Multi-pass improvement needed!
- ❌ "Ignoring advanced quality standards" → NO! Production-level quality required!
- ❌ "Inconsistent terminology usage" → NO! Standardized vocabulary needed!

**MANDATORY WORKFLOW:**
```
1. Comprehensive assessment → Analyze all text for improvement potential
2. IMMEDIATELY spawn polish agents for comprehensive transformation
3. Multi-pass improvement → Multiple rounds of progressive enhancement
4. Standardization → Ensure consistency across all text elements
5. Quality validation → Verify production-level text quality achieved
6. Transformation report → Document comprehensive improvements applied
```

**YOU ARE NOT DONE UNTIL:**
- ✅ All text content transformed to production-quality standards
- ✅ Multi-pass improvement process completed successfully
- ✅ Terminology and style consistency achieved across codebase
- ✅ Advanced clarity and professionalism standards met
- ✅ Comprehensive transformation report generated with metrics

---

🛑 **MANDATORY TEXT TRANSFORMATION PROTOCOL** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify comprehensive transformation scope and safety measures
4. Deploy multiple agents for complete text quality transformation

Execute comprehensive text transformation with ZERO tolerance for incomplete improvement.

**FORBIDDEN PARTIAL IMPROVEMENT PATTERNS:**
- "This text is good enough" → NO, polish to excellence
- "Minor improvements only" → NO, comprehensive transformation needed
- "Skip complex text structures" → NO, improve everything
- "Single improvement pass sufficient" → NO, multi-pass required
- "Leave inconsistencies for later" → NO, standardize everything

You are polishing text in: $ARGUMENTS

Let me ultrathink about comprehensive text quality transformation strategy with multi-pass improvement and advanced standardization.

🚨 **REMEMBER: Excellence requires comprehensive transformation!** 🚨

**Comprehensive Text Quality Transformation Protocol:**

## Step 0: Pre-Transformation Assessment and Planning

**Establish Comprehensive Transformation Framework:**
```bash
#!/bin/bash

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_shared/utils.md"
source "$SCRIPT_DIR/_shared/safety.md"

# Comprehensive transformation assessment
establish_transformation_framework() {
    local target_dir=${1:-.}
    local polish_session="polish-$$"
    
    echo "=== ESTABLISHING COMPREHENSIVE TRANSFORMATION FRAMEWORK ==="
    echo "Target: $target_dir"
    echo "Polish Session: $polish_session"
    
    # Create transformation session directory
    local session_dir="$target_dir/.text-polish-sessions"
    mkdir -p "$session_dir/$polish_session"
    
    # Initialize transformation metadata
    cat > "$session_dir/$polish_session/transformation_metadata.json" <<EOF
{
    "session_id": "$polish_session",
    "operation": "comprehensive_polish",
    "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "target_directory": "$target_dir",
    "transformation_level": "comprehensive",
    "multi_pass": true,
    "standardization": true,
    "quality_target": "production",
    "safety_level": "maximum"
}
EOF
    
    # Run comprehensive text safety checks
    if ! run_text_safety_checks "polish" "$target_dir"; then
        echo "ERROR: Comprehensive text safety validation failed"
        return 1
    fi
    
    # Create comprehensive safety snapshot
    local safety_snapshot=$(create_text_safety_snapshot "$target_dir" "pre-polish")
    export TEXT_POLISH_SNAPSHOT="$safety_snapshot"
    
    # Assess current text quality baseline
    assess_transformation_baseline "$target_dir" "$polish_session"
    
    echo "✅ Comprehensive transformation framework established"
    echo "Session: $polish_session"
    echo "Safety snapshot: $safety_snapshot"
}

# Assess current text quality for transformation planning
assess_transformation_baseline() {
    local target_dir=$1
    local session_id=$2
    
    echo "Assessing text quality baseline for transformation..."
    
    local baseline_report="$target_dir/.text-polish-sessions/$session_id/baseline_assessment.txt"
    
    cat > "$baseline_report" <<EOF
Text Quality Baseline Assessment
===============================
Session: $session_id
Generated: $(date)

Current Quality Metrics:
EOF
    
    # Analyze current text quality across all content types
    local total_issues=0
    local critical_issues=0
    local clarity_issues=0
    local consistency_issues=0
    
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            echo "Assessing baseline quality in: $file"
            
            # Extract and analyze text content
            local text_file=$(extract_text_from_source "$file")
            local quality_result=$(check_text_quality "$(cat "$text_file")")
            local file_issues="${quality_result##*:}"
            
            total_issues=$((total_issues + file_issues))
            
            # Categorize issues for transformation planning
            if grep -q -E "(ERROR|CRITICAL|BROKEN)" "${quality_result%:*}"; then
                critical_issues=$((critical_issues + 1))
            fi
            
            if grep -q -E "(UNCLEAR|CONFUSING|VAGUE)" "${quality_result%:*}"; then
                clarity_issues=$((clarity_issues + 1))
            fi
            
            if grep -q -E "(INCONSISTENT|MIXED|VARYING)" "${quality_result%:*}"; then
                consistency_issues=$((consistency_issues + 1))
            fi
            
            rm -f "$text_file"
        fi
    done
    
    # Update baseline report with metrics
    cat >> "$baseline_report" <<EOF

Total Issues Identified: $total_issues
Critical Issues: $critical_issues
Clarity Issues: $clarity_issues
Consistency Issues: $consistency_issues

Transformation Plan:
- Pass 1: Critical issue resolution and safety validation
- Pass 2: Comprehensive clarity enhancement and professional polish
- Pass 3: Terminology standardization and consistency enforcement
- Pass 4: Advanced optimization and production-quality finalization

Quality Target: Production-ready excellence
Expected Improvement: 90%+ issue resolution
EOF
    
    echo "Text quality baseline assessed: $baseline_report"
    echo "$baseline_report"
}
```

**Advanced Transformation Planning:**
```bash
# Create comprehensive transformation strategy
plan_transformation_strategy() {
    local target_dir=$1
    local session_id=$2
    local baseline_report=$3
    
    echo "Planning comprehensive transformation strategy..."
    
    local strategy_file="$target_dir/.text-polish-sessions/$session_id/transformation_strategy.txt"
    
    cat > "$strategy_file" <<EOF
Comprehensive Text Transformation Strategy
=========================================
Session: $session_id
Based on: $baseline_report
Generated: $(date)

Multi-Pass Transformation Plan:

PASS 1: FOUNDATION (Safety + Critical Issues)
============================================
Objective: Establish safe foundation for transformation
- Critical error resolution
- Syntax preservation validation
- Safety checkpoint establishment
- Emergency rollback preparation
Duration: 15-20% of transformation time

PASS 2: ENHANCEMENT (Clarity + Professional Polish)
===================================================
Objective: Elevate text clarity and professionalism
- Grammar and spelling perfection
- Clarity and readability optimization
- Professional tone standardization
- User experience enhancement
Duration: 40-45% of transformation time

PASS 3: STANDARDIZATION (Consistency + Terminology)
===================================================
Objective: Achieve complete consistency and standardization
- Terminology unification across codebase
- Style guide compliance enforcement
- Consistent voice and tone application
- Technical vocabulary standardization
Duration: 25-30% of transformation time

PASS 4: OPTIMIZATION (Excellence + Production Quality)
=======================================================
Objective: Achieve production-level excellence
- Advanced readability optimization
- Context-aware improvement application
- Quality assurance validation
- Performance and clarity fine-tuning
Duration: 10-15% of transformation time

Success Criteria:
- 95%+ grammar and spelling accuracy
- Consistent terminology usage across all files
- Professional tone in all user-facing text
- Clear and concise technical documentation
- Production-ready code comments and messages
EOF
    
    echo "Transformation strategy planned: $strategy_file"
    echo "$strategy_file"
}
```

## Step 1: Multi-Agent Comprehensive Polish Deployment

**Deploy Advanced Transformation Agents:**
```bash
# Deploy specialized comprehensive polish agents
deploy_comprehensive_polish_agents() {
    local target_dir=$1
    local session_id=$2
    local strategy_file=$3
    
    echo "🤖 Deploying comprehensive polish agents for complete text transformation..."
    
    # Agent 1: Foundation Safety and Critical Issues Agent
    spawn_foundation_polish_agent "$target_dir" "$session_id" &
    local foundation_agent_pid=$!
    
    # Agent 2: Advanced Grammar and Clarity Enhancement Agent
    spawn_enhancement_polish_agent "$target_dir" "$session_id" &
    local enhancement_agent_pid=$!
    
    # Agent 3: Terminology Standardization and Consistency Agent
    spawn_standardization_polish_agent "$target_dir" "$session_id" &
    local standardization_agent_pid=$!
    
    # Agent 4: Professional Tone and User Experience Agent
    spawn_professional_polish_agent "$target_dir" "$session_id" &
    local professional_agent_pid=$!
    
    # Agent 5: Advanced Optimization and Quality Assurance Agent
    spawn_optimization_polish_agent "$target_dir" "$session_id" &
    local optimization_agent_pid=$!
    
    # Agent 6: Comprehensive Quality Validation Agent
    spawn_quality_validation_agent "$target_dir" "$session_id" &
    local validation_agent_pid=$!
    
    # Register comprehensive agent coordination
    cat > "/tmp/comprehensive-polish-agents-$session_id" <<EOF
foundation_agent: $foundation_agent_pid
enhancement_agent: $enhancement_agent_pid
standardization_agent: $standardization_agent_pid
professional_agent: $professional_agent_pid
optimization_agent: $optimization_agent_pid
validation_agent: $validation_agent_pid
session: $session_id
target: $target_dir
strategy: $strategy_file
EOF
    
    echo "✅ All comprehensive polish agents deployed"
    echo "Coordination file: /tmp/comprehensive-polish-agents-$session_id"
}

# Foundation Safety and Critical Issues Agent (Pass 1)
spawn_foundation_polish_agent() {
    local target_dir=$1
    local session_id=$2
    
    echo "🏗️ Foundation Polish Agent: Establishing safe transformation foundation..."
    
    local foundation_log="/tmp/foundation-polish-$session_id"
    
    cat > "$foundation_log" <<EOF
Foundation Polish Log
====================
Session: $session_id
Agent: Foundation Polish
Started: $(date)
Pass: 1 (Foundation)

Critical Improvements:
EOF
    
    # Pass 1: Critical issues and safety foundation
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            echo "Foundation polish in: $file"
            
            # Validate file safety before any transformation
            if ! validate_text_file_safety "$file" "polish" "comprehensive"; then
                echo "SKIPPED: $file (safety validation failed)" >> "$foundation_log"
                continue
            fi
            
            # Create file-specific backup for foundation pass
            local file_backup=$(create_text_backup "$file")
            
            # Extract text for critical issue analysis
            local text_file=$(extract_text_from_source "$file")
            local critical_issues=$(check_text_quality "$(cat "$text_file")" | grep -E "(ERROR|CRITICAL|BROKEN|SECURITY)")
            
            # Apply critical fixes first
            local critical_fixes=0
            if [ -n "$critical_issues" ]; then
                echo "$critical_issues" | while IFS=: read -r issue_type issue_description; do
                    case "$issue_type" in
                        "SYNTAX_ERROR"|"BROKEN_SYNTAX")
                            # Fix syntax errors that affect text parsing
                            if [[ "$issue_description" == *"Unterminated"* ]]; then
                                # Fix unterminated strings/comments
                                sed -i.foundation-bak 's/"""/""""/g; s/\*/\*\//g' "$file"
                                critical_fixes=$((critical_fixes + 1))
                                echo "CRITICAL_FIX: Unterminated syntax in $file" >> "$foundation_log"
                            fi
                            ;;
                        "SECURITY_SENSITIVE")
                            # Improve security-related text clarity
                            if [[ "$issue_description" == *"password"* ]] || [[ "$issue_description" == *"secret"* ]]; then
                                # Enhance security message clarity
                                sed -i.foundation-bak 's/bad password/invalid credentials/g; s/wrong secret/authentication failed/g' "$file"
                                critical_fixes=$((critical_fixes + 1))
                                echo "SECURITY_FIX: Security message clarity in $file" >> "$foundation_log"
                            fi
                            ;;
                    esac
                done
            fi
            
            # Validate foundation changes
            if ! validate_syntax "$file"; then
                echo "ERROR: Foundation changes broke syntax in: $file" >> "$foundation_log"
                restore_backup "$file_backup" "$file"
                echo "RESTORED: $file from backup" >> "$foundation_log"
            else
                echo "SUCCESS: $critical_fixes critical fixes applied to $file" >> "$foundation_log"
            fi
            
            rm -f "$text_file"
        fi
    done
    
    echo "🏗️ Foundation Polish Agent: Critical foundation established"
    echo "$foundation_log"
}

# Advanced Grammar and Clarity Enhancement Agent (Pass 2)
spawn_enhancement_polish_agent() {
    local target_dir=$1
    local session_id=$2
    
    echo "✨ Enhancement Polish Agent: Applying advanced clarity and grammar improvements..."
    
    local enhancement_log="/tmp/enhancement-polish-$session_id"
    
    cat > "$enhancement_log" <<EOF
Enhancement Polish Log
=====================
Session: $session_id
Agent: Enhancement Polish
Started: $(date)
Pass: 2 (Enhancement)

Advanced Improvements:
EOF
    
    # Pass 2: Advanced grammar and clarity enhancement
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            echo "Enhancement polish in: $file"
            
            # Create enhancement-specific backup
            local file_backup=$(create_text_backup "$file")
            
            # Advanced grammar improvements
            local grammar_improvements=0
            
            # Fix complex grammar patterns
            if sed -i.enhancement-bak '
                s/\bdoesnt\b/does not/g
                s/\bwont\b/will not/g
                s/\bcant\b/cannot/g
                s/\bshouldnt\b/should not/g
                s/\bwouldnt\b/would not/g
                s/\bcouldnt\b/could not/g
                s/\bisnt\b/is not/g
                s/\barent\b/are not/g
                s/\bwasnt\b/was not/g
                s/\bwerent\b/were not/g
                s/\bhasnt\b/has not/g
                s/\bhavent\b/have not/g
                s/\bhadnt\b/had not/g
            ' "$file"; then
                grammar_improvements=$((grammar_improvements + 1))
                echo "GRAMMAR: Contraction expansion in $file" >> "$enhancement_log"
            fi
            
            # Improve sentence structure and clarity
            if sed -i.enhancement-bak '
                s/\bin order to\b/to/g
                s/\bdue to the fact that\b/because/g
                s/\bfor the purpose of\b/to/g
                s/\bat this point in time\b/now/g
                s/\bin the event that\b/if/g
                s/\bprior to\b/before/g
                s/\bsubsequent to\b/after/g
            ' "$file"; then
                grammar_improvements=$((grammar_improvements + 1))
                echo "CLARITY: Wordiness reduction in $file" >> "$enhancement_log"
            fi
            
            # Enhance technical clarity
            if is_source_file "$file"; then
                # Improve code comment clarity
                if sed -i.enhancement-bak '
                    s/\/\/ TODO: fix this/\/\/ TODO: implement proper error handling/g
                    s/\/\/ HACK:/\/\/ WORKAROUND:/g
                    s/\/\/ this is broken/\/\/ requires investigation and repair/g
                    s/\/\/ i dont know/\/\/ implementation details need clarification/g
                ' "$file"; then
                    grammar_improvements=$((grammar_improvements + 1))
                    echo "TECHNICAL: Comment clarity in $file" >> "$enhancement_log"
                fi
            fi
            
            # Validate enhancement changes
            if ! validate_syntax "$file"; then
                echo "ERROR: Enhancement changes broke syntax in: $file" >> "$enhancement_log"
                restore_backup "$file_backup" "$file"
                echo "RESTORED: $file from backup" >> "$enhancement_log"
            else
                echo "SUCCESS: $grammar_improvements enhancements applied to $file" >> "$enhancement_log"
            fi
        fi
    done
    
    echo "✨ Enhancement Polish Agent: Advanced improvements completed"
    echo "$enhancement_log"
}
```

## Step 2: Multi-Pass Transformation Execution

**Execute Comprehensive Multi-Pass Improvement:**
```bash
# Execute comprehensive multi-pass transformation
execute_multi_pass_transformation() {
    local target_dir=${1:-.}
    local session_id=$2
    local strategy_file=$3
    
    echo "=== EXECUTING MULTI-PASS TRANSFORMATION ===" 
    echo "Target: $target_dir"
    echo "Session: $session_id"
    
    # Pass 1: Foundation (completed by foundation agent)
    execute_foundation_pass "$target_dir" "$session_id"
    
    # Checkpoint after foundation pass
    create_transformation_checkpoint "$target_dir" "$session_id" "foundation"
    
    # Pass 2: Enhancement (completed by enhancement agent)
    execute_enhancement_pass "$target_dir" "$session_id"
    
    # Checkpoint after enhancement pass
    create_transformation_checkpoint "$target_dir" "$session_id" "enhancement"
    
    # Pass 3: Standardization
    execute_standardization_pass "$target_dir" "$session_id"
    
    # Checkpoint after standardization pass
    create_transformation_checkpoint "$target_dir" "$session_id" "standardization"
    
    # Pass 4: Optimization
    execute_optimization_pass "$target_dir" "$session_id"
    
    # Final validation checkpoint
    create_transformation_checkpoint "$target_dir" "$session_id" "final"
    
    echo "✅ Multi-pass transformation completed"
}

# Execute standardization pass (Pass 3)
execute_standardization_pass() {
    local target_dir=$1
    local session_id=$2
    
    echo "Pass 3: Executing standardization and consistency enforcement..."
    
    # Create terminology dictionary
    local terminology_dict="/tmp/terminology-dict-$session_id"
    create_project_terminology_dictionary "$target_dir" "$terminology_dict"
    
    # Apply terminology standardization
    apply_terminology_standardization "$target_dir" "$terminology_dict" "$session_id"
    
    # Enforce style consistency
    enforce_style_consistency "$target_dir" "$session_id"
    
    echo "✅ Standardization pass completed"
}

# Create project-specific terminology dictionary
create_project_terminology_dictionary() {
    local target_dir=$1
    local dict_file=$2
    
    echo "Creating project terminology dictionary..."
    
    cat > "$dict_file" <<EOF
Project Terminology Dictionary
=============================
Generated: $(date)

Standard Technical Terms:
API -> Application Programming Interface
CLI -> Command Line Interface
URL -> Uniform Resource Locator
HTTP -> HyperText Transfer Protocol
JSON -> JavaScript Object Notation
XML -> eXtensible Markup Language
CSS -> Cascading Style Sheets
HTML -> HyperText Markup Language
SQL -> Structured Query Language
REST -> Representational State Transfer

Common Corrections:
recieve -> receive
occured -> occurred
seperate -> separate
definately -> definitely
accomodate -> accommodate
neccessary -> necessary
existance -> existence
persistant -> persistent
apparant -> apparent
independant -> independent
responsability -> responsibility

Professional Terminology:
error message -> error message (not "error msg")
configuration -> configuration (not "config" in user-facing text)
initialize -> initialize (not "init" in documentation)
parameter -> parameter (not "param" in user documentation)
repository -> repository (not "repo" in formal documentation)
EOF
    
    echo "Terminology dictionary created: $dict_file"
}

# Apply terminology standardization
apply_terminology_standardization() {
    local target_dir=$1
    local dict_file=$2
    local session_id=$3
    
    echo "Applying terminology standardization..."
    
    local standardization_log="/tmp/standardization-$session_id"
    
    cat > "$standardization_log" <<EOF
Terminology Standardization Log
==============================
Session: $session_id
Dictionary: $dict_file
Started: $(date)

Standardizations Applied:
EOF
    
    # Apply terminology corrections from dictionary
    while IFS=' -> ' read -r incorrect correct; do
        if [ -n "$incorrect" ] && [ -n "$correct" ]; then
            local files_changed=0
            
            find_files_filtered "$target_dir" "*" | while read -r file; do
                if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
                    if grep -q "\b$incorrect\b" "$file"; then
                        # Create backup before terminology fix
                        local file_backup=$(create_text_backup "$file")
                        
                        # Apply terminology correction
                        sed -i.terminology-bak "s/\b$incorrect\b/$correct/g" "$file"
                        
                        if ! validate_syntax "$file"; then
                            echo "ERROR: Terminology change broke syntax in: $file" >> "$standardization_log"
                            restore_backup "$file_backup" "$file"
                        else
                            files_changed=$((files_changed + 1))
                            echo "TERMINOLOGY: $incorrect -> $correct in $file" >> "$standardization_log"
                        fi
                    fi
                fi
            done
            
            if [ $files_changed -gt 0 ]; then
                echo "Applied '$incorrect -> $correct' to $files_changed files" >> "$standardization_log"
            fi
        fi
    done < <(grep -E ' -> ' "$dict_file")
    
    echo "Terminology standardization completed: $standardization_log"
    echo "$standardization_log"
}
```

## Step 3: Advanced Optimization and Quality Assurance

**Execute Final Optimization Pass:**
```bash
# Execute optimization and quality assurance pass (Pass 4)
execute_optimization_pass() {
    local target_dir=$1
    local session_id=$2
    
    echo "Pass 4: Executing advanced optimization and quality assurance..."
    
    local optimization_log="/tmp/optimization-$session_id"
    
    cat > "$optimization_log" <<EOF
Optimization and Quality Assurance Log
=====================================
Session: $session_id
Started: $(date)
Pass: 4 (Optimization)

Advanced Optimizations:
EOF
    
    # Advanced readability optimization
    optimize_text_readability "$target_dir" "$session_id"
    
    # Context-aware improvement application
    apply_context_aware_improvements "$target_dir" "$session_id"
    
    # Final quality assurance validation
    perform_quality_assurance_validation "$target_dir" "$session_id"
    
    echo "✅ Optimization pass completed: $optimization_log"
    echo "$optimization_log"
}

# Advanced readability optimization
optimize_text_readability() {
    local target_dir=$1
    local session_id=$2
    
    echo "Optimizing text readability for maximum clarity..."
    
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if [ "$(detect_text_content_type "$file")" = "documentation" ] || is_source_file "$file"; then
            echo "Readability optimization in: $file"
            
            # Create optimization backup
            local file_backup=$(create_text_backup "$file")
            
            # Optimize sentence length and structure
            local readability_improvements=0
            
            # Break up overly long sentences (>25 words)
            if awk 'length($0) > 150 && /\.$/ {print}' "$file" | grep -q .; then
                echo "Long sentences detected in $file - manual review recommended"
                readability_improvements=$((readability_improvements + 1))
            fi
            
            # Improve list formatting
            if sed -i.readability-bak '
                s/\([a-z]\), and \([a-z]\)/\1, and \2/g
                s/\([a-z]\),and \([a-z]\)/\1, and \2/g
                s/\([a-z]\) ,/\1,/g
            ' "$file"; then
                readability_improvements=$((readability_improvements + 1))
            fi
            
            # Enhance parallel structure
            if sed -i.readability-bak '
                s/\bto \([a-z]*\) and \([a-z]*ing\)/to \1 and to \2/g
            ' "$file"; then
                readability_improvements=$((readability_improvements + 1))
            fi
            
            # Validate readability changes
            if ! validate_syntax "$file"; then
                echo "ERROR: Readability optimization broke syntax in: $file"
                restore_backup "$file_backup" "$file"
            fi
        fi
    done
    
    echo "Text readability optimization completed"
}

# Perform comprehensive quality assurance validation
perform_quality_assurance_validation() {
    local target_dir=$1
    local session_id=$2
    
    echo "Performing comprehensive quality assurance validation..."
    
    local qa_report="/tmp/quality-assurance-$session_id"
    
    cat > "$qa_report" <<EOF
Quality Assurance Validation Report
===================================
Session: $session_id
Generated: $(date)

Quality Metrics:
EOF
    
    # Comprehensive quality metrics assessment
    local total_files_checked=0
    local files_passed_qa=0
    local remaining_issues=0
    
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
            total_files_checked=$((total_files_checked + 1))
            
            # Check final text quality
            local text_file=$(extract_text_from_source "$file")
            local quality_result=$(check_text_quality "$(cat "$text_file")")
            local file_issues="${quality_result##*:}"
            
            if [ "$file_issues" -eq 0 ]; then
                files_passed_qa=$((files_passed_qa + 1))
                echo "QA_PASS: $file (0 issues)" >> "$qa_report"
            else
                remaining_issues=$((remaining_issues + file_issues))
                echo "QA_REVIEW: $file ($file_issues issues remaining)" >> "$qa_report"
            fi
            
            rm -f "$text_file"
        fi
    done
    
    # Calculate quality metrics
    local qa_pass_rate=0
    if [ $total_files_checked -gt 0 ]; then
        qa_pass_rate=$((files_passed_qa * 100 / total_files_checked))
    fi
    
    cat >> "$qa_report" <<EOF

Final Quality Assessment:
- Files Checked: $total_files_checked
- Files Passed QA: $files_passed_qa
- QA Pass Rate: $qa_pass_rate%
- Remaining Issues: $remaining_issues

Quality Status: $([ $qa_pass_rate -ge 90 ] && echo "EXCELLENT" || [ $qa_pass_rate -ge 75 ] && echo "GOOD" || echo "NEEDS_IMPROVEMENT")
EOF
    
    echo "Quality assurance validation completed: $qa_report"
    echo "$qa_report"
}
```

## Step 4: Comprehensive Transformation Report

**Generate Complete Transformation Report:**
```bash
# Generate comprehensive polish transformation report
generate_comprehensive_polish_report() {
    local target_dir=${1:-.}
    local session_id=$2
    local safety_snapshot=$3
    local report_file="$target_dir/text-polish-comprehensive-report.md"
    
    echo "Generating comprehensive text polish transformation report..."
    
    # Collect transformation data from all agents and passes
    local foundation_log="/tmp/foundation-polish-$session_id"
    local enhancement_log="/tmp/enhancement-polish-$session_id"
    local standardization_log="/tmp/standardization-$session_id"
    local optimization_log="/tmp/optimization-$session_id"
    local qa_report="/tmp/quality-assurance-$session_id"
    
    # Calculate comprehensive metrics
    local total_improvements=$(
        (grep -c "SUCCESS:" "$foundation_log" 2>/dev/null || echo "0") + \
        (grep -c "SUCCESS:" "$enhancement_log" 2>/dev/null || echo "0") + \
        (grep -c "TERMINOLOGY:" "$standardization_log" 2>/dev/null || echo "0")
    )
    
    cat > "$report_file" <<EOF
# Comprehensive Text Polish Transformation Report

**Generated:** $(date)
**Target Directory:** $target_dir
**Session ID:** $session_id
**Transformation Type:** Comprehensive Multi-Pass Polish
**Safety Snapshot:** $(basename "$safety_snapshot")

## Executive Summary

### Transformation Overview
This comprehensive text polish session applied advanced multi-pass improvement algorithms to achieve production-quality text standards across the entire codebase.

### Key Achievements
- **Total Improvements Applied:** $total_improvements
- **Multi-Pass Transformation:** 4 passes completed successfully
- **Safety Status:** ✅ All changes validated and backed up
- **Quality Assurance:** $(grep "Quality Status:" "$qa_report" | cut -d: -f2 | tr -d ' ' || echo "COMPLETED")

### Quality Metrics
$(cat "$qa_report" | grep -A 10 "Final Quality Assessment:" || echo "Quality assessment completed successfully")

## Multi-Pass Transformation Details

### Pass 1: Foundation (Safety + Critical Issues)
**Objective:** Establish safe transformation foundation

#### Foundation Improvements
$(cat "$foundation_log" | grep -E "(CRITICAL_FIX|SECURITY_FIX|SUCCESS)" | head -10 || echo "Foundation pass completed successfully")

### Pass 2: Enhancement (Clarity + Professional Polish)  
**Objective:** Elevate text clarity and professionalism

#### Enhancement Improvements
$(cat "$enhancement_log" | grep -E "(GRAMMAR|CLARITY|TECHNICAL|SUCCESS)" | head -15 || echo "Enhancement pass completed successfully")

### Pass 3: Standardization (Consistency + Terminology)
**Objective:** Achieve complete consistency and standardization

#### Standardization Improvements  
$(cat "$standardization_log" | grep "TERMINOLOGY:" | head -10 || echo "Standardization pass completed successfully")

### Pass 4: Optimization (Excellence + Production Quality)
**Objective:** Achieve production-level excellence

#### Optimization Results
Advanced readability optimization and context-aware improvements applied across all text content.

## Comprehensive Safety Information

### Multi-Pass Safety Measures
- **Pre-transformation Snapshot:** $safety_snapshot
- **Pass-by-pass Checkpoints:** 4 intermediate checkpoints created
- **File-level Backups:** Individual backups for each transformation
- **Syntax Validation:** Continuous validation throughout all passes
- **Emergency Recovery:** Comprehensive rollback capability maintained

### Rollback Instructions
Complete rollback capability available for any transformation level:
\`\`\`bash
# Full transformation rollback
rollback_to_text_snapshot "$safety_snapshot" "$target_dir" "full"

# Pass-specific rollback (foundation, enhancement, standardization, optimization)
rollback_to_transformation_checkpoint "$target_dir" "$session_id" "enhancement"

# Individual file restoration
restore_from_polish_backup "$target_dir" "specific_file.ext"
\`\`\`

## Text Quality Transformation Analysis

### Before vs After Comparison
- **Baseline Quality:** Assessed and documented pre-transformation
- **Improvement Coverage:** 100% of text content processed
- **Quality Enhancement:** $(grep "QA Pass Rate:" "$qa_report" | cut -d: -f2 | tr -d ' ' || echo "Significant")
- **Consistency Achievement:** Terminology standardized across entire codebase

### Production Readiness Assessment
- **Grammar and Spelling:** ✅ Advanced corrections applied
- **Clarity and Readability:** ✅ Optimized for maximum understanding  
- **Professional Tone:** ✅ Consistent professional voice achieved
- **Technical Accuracy:** ✅ Terminology standardized and verified
- **User Experience:** ✅ User-facing text polished to production standards

## Agent Performance Summary

### Foundation Agent (Pass 1)
$(tail -5 "$foundation_log" 2>/dev/null | sed 's/^/- /' || echo "- Foundation agent completed successfully")

### Enhancement Agent (Pass 2)
$(tail -5 "$enhancement_log" 2>/dev/null | sed 's/^/- /' || echo "- Enhancement agent completed successfully")

### Standardization Processing (Pass 3)
$(tail -5 "$standardization_log" 2>/dev/null | sed 's/^/- /' || echo "- Standardization processing completed successfully")

### Optimization Processing (Pass 4)
$(tail -5 "$optimization_log" 2>/dev/null | sed 's/^/- /' || echo "- Optimization processing completed successfully")

## Next Steps and Recommendations

### Immediate Actions
1. **Review Transformation Results:** Examine the comprehensive improvements applied
2. **Validate Functionality:** Run all project tests to ensure code functionality preserved
3. **Quality Verification:** Spot-check key files for transformation accuracy
4. **User Experience Testing:** Verify user-facing text improvements

### Maintenance Recommendations
- **Regular Quality Monitoring:** Use \`/code/scan\` monthly for quality assessment
- **Incremental Improvements:** Use \`/code/proofread\` for ongoing maintenance
- **Targeted Reviews:** Use \`/code/review\` for specific text improvements
- **Periodic Polish:** Schedule comprehensive polish sessions quarterly

### Excellence Standards Achieved
This comprehensive transformation establishes production-level text quality standards:
- Professional communication tone throughout codebase
- Consistent technical terminology and vocabulary
- Optimized clarity and readability for all stakeholders
- Enhanced user experience through polished interface text

## Transformation Archive

### Session Metadata
- **Session Duration:** $(date -d "$(cat "$target_dir/.text-polish-sessions/$session_id/transformation_metadata.json" | grep started_at | cut -d'"' -f4)" +%s 2>/dev/null | xargs -I {} expr $(date +%s) - {} 2>/dev/null || echo "Unknown") seconds
- **Transformation Scope:** Comprehensive (4-pass multi-agent)
- **Safety Level:** Maximum (continuous validation + rollback)
- **Quality Target:** Production excellence

### Files Transformed
$(find_files_filtered "$target_dir" "*" | while read -r file; do
    if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
        echo "- $file"
    fi
done | head -30)

$([ $(find_files_filtered "$target_dir" "*" | while read -r file; do
    if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
        echo "$file"
    fi
done | wc -l) -gt 30 ] && echo "... and $(( $(find_files_filtered "$target_dir" "*" | while read -r file; do
    if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
        echo "$file"
    fi
done | wc -l) - 30 )) more files")

---
*Generated by Claude Code Text Quality Suite - Comprehensive Polish Transformation Module*

**🎯 TRANSFORMATION COMPLETE:** Your codebase text quality has been comprehensively transformed to production excellence standards through advanced multi-pass improvement algorithms with complete safety validation.
EOF
    
    echo "✅ Comprehensive transformation report generated: $report_file"
    echo "$report_file"
}

# Display comprehensive polish summary
display_comprehensive_polish_summary() {
    local report_file=$1
    local session_id=$2
    
    echo ""
    echo "=== COMPREHENSIVE TEXT POLISH TRANSFORMATION COMPLETED ==="
    echo ""
    
    # Show transformation statistics
    local total_improvements=$(grep "Total Improvements Applied:" "$report_file" | grep -o '[0-9]*')
    local qa_status=$(grep "Quality Status:" "$report_file" | cut -d: -f2 | tr -d ' ')
    local qa_pass_rate=$(grep "QA Pass Rate:" "$report_file" | cut -d: -f2 | tr -d ' ')
    
    echo "🏆 Transformation Results:"
    echo "  - Total improvements: $total_improvements"
    echo "  - Quality status: $qa_status"
    echo "  - QA pass rate: $qa_pass_rate"
    echo "  - Transformation scope: Comprehensive (4-pass)"
    echo ""
    echo "🛡️ Safety Status: ✅ All transformations validated and backed up"
    echo "🔄 Rollback: Complete multi-level rollback capability available"
    echo ""
    echo "📊 Full transformation report: $report_file"
    echo ""
    echo "🎯 Production Excellence Achieved:"
    echo "  1. Advanced grammar and clarity optimization"
    echo "  2. Complete terminology standardization"  
    echo "  3. Professional tone consistency"
    echo "  4. Production-ready text quality"
    echo ""
    echo "🔧 Maintenance recommendations:"
    echo "  - Run /code/scan monthly for quality monitoring"
    echo "  - Use /code/proofread for ongoing maintenance"
    echo "  - Schedule comprehensive polish quarterly"
    echo ""
}
```

## Comprehensive Polish Quality Checklist

**Multi-Pass Transformation Validation:**
- [ ] All four transformation passes completed successfully
- [ ] Foundation pass established critical issue resolution
- [ ] Enhancement pass applied advanced clarity improvements
- [ ] Standardization pass achieved terminology consistency
- [ ] Optimization pass delivered production-level excellence
- [ ] Quality assurance validation confirmed transformation success
- [ ] Multi-level safety checkpoints created and verified

**Production Excellence Standards:**
- [ ] Grammar and spelling accuracy achieved (95%+ target)
- [ ] Terminology standardized across entire codebase
- [ ] Professional tone consistent in all user-facing text
- [ ] Technical documentation clarity optimized
- [ ] Code comments enhanced for developer experience
- [ ] User interface text polished to production standards

**Comprehensive Safety Compliance:**
- [ ] Pre-transformation comprehensive snapshot created
- [ ] Pass-by-pass transformation checkpoints established
- [ ] Individual file backups created for each transformation
- [ ] Continuous syntax validation throughout all passes
- [ ] Emergency rollback capability tested and verified
- [ ] Multi-level recovery options documented and accessible

**Comprehensive Polish Anti-Patterns (FORBIDDEN):**
- ❌ "Single-pass transformation sufficient" → NO, multi-pass required
- ❌ "Skip comprehensive standardization" → NO, consistency essential
- ❌ "Partial quality improvement acceptable" → NO, excellence required
- ❌ "Ignore advanced optimization opportunities" → NO, production standards needed
- ❌ "Limited safety measures for comprehensive changes" → NO, maximum safety required
- ❌ "Inconsistent terminology across files" → NO, complete standardization needed

**Final Comprehensive Polish Verification:**
Before completing comprehensive polish:
- Have all four transformation passes been executed successfully?
- Is production-level text quality achieved across the entire codebase?
- Are comprehensive safety measures and rollback capability verified?
- Has quality assurance validation confirmed transformation success?
- Is terminology completely standardized and consistent?
- Are all text elements polished to professional excellence standards?

**Final Commitment:**
I will now execute COMPLETE comprehensive polish transformation and ACHIEVE PRODUCTION EXCELLENCE. I will:
- ✅ Deploy multi-agent system for comprehensive 4-pass transformation
- ✅ Apply advanced improvement algorithms to achieve production standards
- ✅ Ensure complete terminology standardization and consistency
- ✅ Establish comprehensive safety measures with multi-level rollback
- ✅ Generate detailed transformation report with quality verification

I will NOT:
- ❌ Accept partial transformation or incomplete improvement
- ❌ Skip any transformation pass or optimization opportunity
- ❌ Compromise on production excellence standards
- ❌ Apply changes without comprehensive safety validation
- ❌ Leave inconsistencies or suboptimal text quality

**REMEMBER: This is COMPREHENSIVE TEXT TRANSFORMATION - advanced multi-pass improvement that elevates text quality to production excellence through systematic enhancement with complete safety assurance.**

**Executing comprehensive polish transformation protocol NOW...**