---
allowed-tools: all
description: Project-wide text analysis and issue detection for code comments, documentation, variable names, and error messages
---

# 🔍🔍🔍 CRITICAL REQUIREMENT: COMPREHENSIVE TEXT ANALYSIS!

**THIS IS NOT A MODIFICATION TASK - THIS IS A COMPREHENSIVE TEXT ANALYSIS TASK!**

When you run `/code/scan`, you are REQUIRED to:

1. **ANALYZE** all text content in codebase (comments, docs, strings, identifiers)
2. **DETECT** grammar, spelling, clarity, and consistency issues
3. **CATEGORIZE** issues by severity and impact on code functionality
4. **GENERATE** comprehensive report with actionable insights
5. **USE MULTIPLE AGENTS** for thorough analysis:
   - Spawn one agent to scan code comments and documentation
   - Spawn another to analyze variable and function names
   - Spawn more agents for different text content types
   - Say: "I'll spawn multiple analysis agents to scan text comprehensively"

**FORBIDDEN BEHAVIORS:**
- ❌ "Surface-level text scanning" → NO! Deep analysis required!
- ❌ "Ignoring code context" → NO! Context-aware text analysis!
- ❌ "Missing text in string literals" → NO! Scan all text content!
- ❌ "Generic issue reporting" → NO! Specific, actionable findings!

**MANDATORY WORKFLOW:**
```
1. Text content discovery → Find all text in codebase
2. IMMEDIATELY spawn analysis agents for parallel processing
3. Issue detection → Identify grammar, spelling, clarity problems
4. Severity classification → Categorize by impact and urgency
5. Report generation → Create comprehensive analysis report
6. VERIFY completeness → Ensure all text content analyzed
```

**YOU ARE NOT DONE UNTIL:**
- ✅ All text content in codebase has been analyzed
- ✅ Issues categorized by type and severity level
- ✅ Comprehensive report generated with actionable insights
- ✅ Zero text content missed or overlooked
- ✅ Context-aware analysis completed for all findings

---

🛑 **MANDATORY TEXT ANALYSIS PROTOCOL** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify you're performing analysis, not modification
4. Deploy multiple agents for comprehensive coverage

Execute comprehensive text analysis with ZERO tolerance for incomplete scanning.

**FORBIDDEN SHORTCUT PATTERNS:**
- "This text looks fine" → NO, analyze systematically
- "Comments aren't that important" → NO, all text matters
- "Variable names are functional" → NO, check clarity too
- "Only scan obvious files" → NO, comprehensive coverage required
- "Quick scan is sufficient" → NO, thorough analysis needed

You are analyzing text in: $ARGUMENTS

Let me ultrathink about comprehensive text analysis strategy and multi-agent deployment.

🚨 **REMEMBER: Thorough analysis prevents quality issues!** 🚨

**Comprehensive Text Analysis Protocol:**

## Step 0: Text Content Discovery and Classification

**Discover All Text Content Types:**
```bash
#!/bin/bash

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../shared/utils.md"
source "$SCRIPT_DIR/../../shared/safety.md"

# Text content discovery function
discover_text_content() {
    local target_dir=${1:-.}
    local discovery_file="/tmp/text-discovery-$$"
    
    echo "=== TEXT CONTENT DISCOVERY ==="
    echo "Target: $target_dir"
    echo "Discovery file: $discovery_file"
    
    # Initialize discovery log
    cat > "$discovery_file" <<EOF
Text Content Discovery Report
============================
Started: $(date)
Target Directory: $target_dir
Discovery Session ID: $$

Content Categories Found:
EOF
    
    # Find all text-containing files
    local total_files=0
    local source_files=0
    local doc_files=0
    local config_files=0
    
    find_files_filtered "$target_dir" "*" | while read -r file; do
        total_files=$((total_files + 1))
        
        local content_type=$(detect_text_content_type "$file")
        case "$content_type" in
            "source_code")
                source_files=$((source_files + 1))
                echo "SOURCE: $file" >> "$discovery_file"
                ;;
            "documentation")
                doc_files=$((doc_files + 1))
                echo "DOCUMENTATION: $file" >> "$discovery_file"
                ;;
            "configuration")
                config_files=$((config_files + 1))
                echo "CONFIGURATION: $file" >> "$discovery_file"
                ;;
        esac
    done
    
    # Log summary
    cat >> "$discovery_file" <<EOF

Discovery Summary:
-----------------
Total Files Scanned: $total_files
Source Code Files: $source_files
Documentation Files: $doc_files
Configuration Files: $config_files

EOF
    
    echo "Text content discovery completed"
    echo "Files found: $total_files total, $source_files source, $doc_files docs, $config_files config"
    echo "$discovery_file"
}
```

**Content Type Classification:**
- [ ] Source code files (comments, string literals, identifiers)
- [ ] Documentation files (markdown, rst, txt, adoc)
- [ ] Configuration files (json, yaml, toml with text values)
- [ ] Script files (shell, python, etc with text content)
- [ ] Template files (html, jsx, vue with text content)
- [ ] Test files (test descriptions and error messages)

## Step 1: Multi-Agent Text Analysis Deployment

**Deploy Specialized Analysis Agents:**
```bash
# Multi-agent text analysis coordination
deploy_text_analysis_agents() {
    local target_dir=$1
    local discovery_file=$2
    local analysis_session="text-analysis-$$"
    
    echo "🤖 Deploying text analysis agents for comprehensive scanning..."
    
    # Agent 1: Code Comments and Documentation Analyzer
    spawn_comment_analysis_agent "$target_dir" "$analysis_session" &
    local comment_agent_pid=$!
    
    # Agent 2: Variable and Function Name Analyzer  
    spawn_identifier_analysis_agent "$target_dir" "$analysis_session" &
    local identifier_agent_pid=$!
    
    # Agent 3: String Literals and Error Message Analyzer
    spawn_string_analysis_agent "$target_dir" "$analysis_session" &
    local string_agent_pid=$!
    
    # Agent 4: Documentation and README Analyzer
    spawn_documentation_analysis_agent "$target_dir" "$analysis_session" &
    local doc_agent_pid=$!
    
    # Agent 5: Configuration and Metadata Analyzer
    spawn_config_analysis_agent "$target_dir" "$analysis_session" &
    local config_agent_pid=$!
    
    # Register agent PIDs for coordination
    cat > "/tmp/text-analysis-agents-$$" <<EOF
comment_agent: $comment_agent_pid
identifier_agent: $identifier_agent_pid
string_agent: $string_agent_pid
documentation_agent: $doc_agent_pid
config_agent: $config_agent_pid
session: $analysis_session
target: $target_dir
EOF
    
    echo "✅ All text analysis agents deployed"
    echo "Session: $analysis_session"
    echo "Coordination file: /tmp/text-analysis-agents-$$"
}

# Code Comments and Documentation Analysis Agent
spawn_comment_analysis_agent() {
    local target_dir=$1
    local session_id=$2
    
    echo "📝 Comment Analysis Agent: Starting comprehensive comment scanning..."
    
    local comment_report="/tmp/comment-analysis-$session_id"
    
    # Initialize comment analysis report
    cat > "$comment_report" <<EOF
Comment Analysis Report
======================
Session: $session_id
Agent: Comment Analyzer
Started: $(date)

Issues Found:
EOF
    
    # Analyze comments in all source files
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file"; then
            echo "Analyzing comments in: $file"
            
            # Extract text content from source file
            local text_file=$(extract_text_from_source "$file")
            
            # Check for comment-specific issues
            grep "^COMMENT:" "$text_file" | while IFS=': ' read -r prefix comment_text; do
                # Grammar and spelling analysis
                local issues=$(check_text_quality "$comment_text")
                local issue_count="${issues##*:}"
                
                if [ "$issue_count" -gt 0 ]; then
                    echo "COMMENT_ISSUE: $file - $comment_text" >> "$comment_report"
                    cat "${issues%:*}" >> "$comment_report"
                fi
                
                # Check for unclear or unhelpful comments
                if echo "$comment_text" | grep -q -E "\b(TODO|FIXME|XXX|HACK)\b"; then
                    echo "ACTION_NEEDED: $file - $comment_text" >> "$comment_report"
                fi
            done
            
            rm -f "$text_file"
        fi
    done
    
    echo "📝 Comment Analysis Agent: Completed scanning"
    echo "$comment_report"
}

# Variable and Function Name Analysis Agent
spawn_identifier_analysis_agent() {
    local target_dir=$1
    local session_id=$2
    
    echo "🏷️ Identifier Analysis Agent: Starting identifier clarity analysis..."
    
    local identifier_report="/tmp/identifier-analysis-$session_id"
    
    cat > "$identifier_report" <<EOF
Identifier Analysis Report
=========================
Session: $session_id
Agent: Identifier Analyzer
Started: $(date)

Clarity Issues:
EOF
    
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file"; then
            echo "Analyzing identifiers in: $file"
            
            # Extract identifiers
            extract_identifiers "$file" | while IFS=': ' read -r prefix identifier; do
                # Check identifier clarity
                local length=${#identifier}
                
                # Too short identifiers (except common cases)
                if [ "$length" -lt 3 ] && ! echo "$identifier" | grep -q -E "^(id|i|j|k|x|y|z|ok|no)$"; then
                    echo "UNCLEAR_SHORT: $file - $identifier (too short: $length chars)" >> "$identifier_report"
                fi
                
                # Too long identifiers
                if [ "$length" -gt 50 ]; then
                    echo "UNCLEAR_LONG: $file - $identifier (too long: $length chars)" >> "$identifier_report"
                fi
                
                # Check for unclear abbreviations
                if echo "$identifier" | grep -q -E "[bcdfghjklmnpqrstvwxz]{3,}"; then
                    echo "UNCLEAR_ABBREV: $file - $identifier (difficult abbreviation)" >> "$identifier_report"
                fi
                
                # Check for spelling in identifiers
                local words=$(echo "$identifier" | sed 's/[A-Z]/ &/g' | sed 's/_/ /g' | tr '[:upper:]' '[:lower:]')
                for word in $words; do
                    if [ ${#word} -gt 3 ] && ! grep -q "^$word$" /usr/share/dict/words 2>/dev/null; then
                        echo "SPELLING_SUSPECT: $file - $identifier (word: $word)" >> "$identifier_report"
                    fi
                done
            done
        fi
    done
    
    echo "🏷️ Identifier Analysis Agent: Completed scanning"
    echo "$identifier_report"
}

# String Literals and Error Message Analysis Agent
spawn_string_analysis_agent() {
    local target_dir=$1
    local session_id=$2
    
    echo "💬 String Analysis Agent: Starting string literal analysis..."
    
    local string_report="/tmp/string-analysis-$session_id"
    
    cat > "$string_report" <<EOF
String Literal Analysis Report
=============================
Session: $session_id
Agent: String Analyzer
Started: $(date)

User-Facing Text Issues:
EOF
    
    find_files_filtered "$target_dir" "*" | while read -r file; do
        if is_source_file "$file" && contains_user_facing_text "$file"; then
            echo "Analyzing user-facing strings in: $file"
            
            # Extract user messages
            local messages_file=$(extract_user_messages "$file")
            
            # Analyze each message
            while IFS=': ' read -r prefix message_text; do
                # Check message quality
                local quality_result=$(check_text_quality "$message_text")
                local issue_count="${quality_result##*:}"
                
                if [ "$issue_count" -gt 0 ]; then
                    echo "USER_MESSAGE_ISSUE: $file - $message_text" >> "$string_report"
                    cat "${quality_result%:*}" >> "$string_report"
                fi
                
                # Check for technical jargon in user messages
                if echo "$message_text" | grep -q -E "\b(null|undefined|NaN|bool|int|str|obj)\b"; then
                    echo "TECHNICAL_JARGON: $file - $message_text" >> "$string_report"
                fi
                
                # Check for missing capitalization in error messages
                if echo "$message_text" | grep -q -E "^[a-z]"; then
                    echo "CAPITALIZATION: $file - $message_text (should start with capital)" >> "$string_report"
                fi
                
            done < "$messages_file"
            
            rm -f "$messages_file"
        fi
    done
    
    echo "💬 String Analysis Agent: Completed scanning"
    echo "$string_report"
}
```

## Step 2: Comprehensive Issue Detection and Analysis

**Text Quality Issue Detection:**
```bash
# Comprehensive text quality scanning
perform_comprehensive_text_scan() {
    local target_dir=${1:-.}
    local scan_session="scan-$$"
    
    echo "=== COMPREHENSIVE TEXT QUALITY SCAN ==="
    echo "Target: $target_dir"
    echo "Session: $scan_session"
    
    # Run text safety checks
    if ! run_text_safety_checks "scan" "$target_dir"; then
        echo "ERROR: Text safety checks failed"
        return 1
    fi
    
    # Discover all text content
    local discovery_file=$(discover_text_content "$target_dir")
    
    # Deploy analysis agents
    deploy_text_analysis_agents "$target_dir" "$discovery_file"
    
    # Wait for all agents to complete
    wait_for_analysis_completion "$scan_session"
    
    # Aggregate analysis results
    aggregate_analysis_results "$scan_session" "$target_dir"
    
    # Generate comprehensive report
    generate_text_scan_report "$scan_session" "$target_dir"
    
    echo "✅ Comprehensive text scan completed"
}

# Wait for all analysis agents to complete
wait_for_analysis_completion() {
    local session_id=$1
    local agent_file="/tmp/text-analysis-agents-$$"
    
    echo "Waiting for analysis agents to complete..."
    
    if [ -f "$agent_file" ]; then
        # Wait for all agent processes
        local comment_pid=$(grep "comment_agent:" "$agent_file" | cut -d' ' -f2)
        local identifier_pid=$(grep "identifier_agent:" "$agent_file" | cut -d' ' -f2)
        local string_pid=$(grep "string_agent:" "$agent_file" | cut -d' ' -f2)
        local doc_pid=$(grep "documentation_agent:" "$agent_file" | cut -d' ' -f2)
        local config_pid=$(grep "config_agent:" "$agent_file" | cut -d' ' -f2)
        
        wait $comment_pid $identifier_pid $string_pid $doc_pid $config_pid
        echo "✅ All analysis agents completed"
    fi
}

# Aggregate analysis results from all agents
aggregate_analysis_results() {
    local session_id=$1
    local target_dir=$2
    local aggregated_report="/tmp/aggregated-analysis-$session_id"
    
    echo "Aggregating analysis results..."
    
    cat > "$aggregated_report" <<EOF
Aggregated Text Analysis Results
===============================
Session: $session_id
Target: $target_dir
Aggregated: $(date)

EOF
    
    # Combine results from all agent reports
    local report_files=(
        "/tmp/comment-analysis-$session_id"
        "/tmp/identifier-analysis-$session_id"
        "/tmp/string-analysis-$session_id"
        "/tmp/documentation-analysis-$session_id"
        "/tmp/config-analysis-$session_id"
    )
    
    for report_file in "${report_files[@]}"; do
        if [ -f "$report_file" ]; then
            echo "=== $(basename "$report_file") ===" >> "$aggregated_report"
            cat "$report_file" >> "$aggregated_report"
            echo "" >> "$aggregated_report"
        fi
    done
    
    echo "Results aggregated: $aggregated_report"
    echo "$aggregated_report"
}
```

## Step 3: Issue Severity Classification and Prioritization

**Classify Issues by Impact and Urgency:**
```bash
# Classify and prioritize text quality issues
classify_text_issues() {
    local aggregated_report=$1
    local classified_report="/tmp/classified-issues-$$"
    
    echo "Classifying text quality issues by severity..."
    
    # Initialize classification report
    cat > "$classified_report" <<EOF
Text Quality Issue Classification
================================
Generated: $(date)
Source Report: $aggregated_report

CRITICAL ISSUES (Fix immediately):
EOF
    
    # Critical issues - affect functionality or user experience
    grep -E "(SYNTAX_ERROR|BROKEN_LINK|SECURITY_SENSITIVE|USER_MESSAGE_ISSUE)" "$aggregated_report" >> "$classified_report" || true
    
    cat >> "$classified_report" <<EOF

HIGH PRIORITY (Fix soon):
EOF
    
    # High priority - clarity and professionalism issues
    grep -E "(UNCLEAR_|GRAMMAR|SPELLING|CAPITALIZATION|TECHNICAL_JARGON)" "$aggregated_report" >> "$classified_report" || true
    
    cat >> "$classified_report" <<EOF

MEDIUM PRIORITY (Fix when convenient):
EOF
    
    # Medium priority - consistency and style issues
    grep -E "(INCONSISTENT|STYLE|READABILITY|ACTION_NEEDED)" "$aggregated_report" >> "$classified_report" || true
    
    cat >> "$classified_report" <<EOF

LOW PRIORITY (Nice to have):
EOF
    
    # Low priority - minor improvements
    grep -E "(MINOR|SUGGESTION|ENHANCEMENT)" "$aggregated_report" >> "$classified_report" || true
    
    echo "Issue classification completed: $classified_report"
    echo "$classified_report"
}

# Generate issue statistics and metrics
generate_issue_statistics() {
    local classified_report=$1
    local stats_file="/tmp/issue-stats-$$"
    
    echo "Generating text quality statistics..."
    
    local critical_count=$(grep -c "CRITICAL ISSUES" -A 1000 "$classified_report" | grep -c -E "(SYNTAX_ERROR|BROKEN_LINK|SECURITY_SENSITIVE|USER_MESSAGE_ISSUE)" || echo "0")
    local high_count=$(grep -c -E "(UNCLEAR_|GRAMMAR|SPELLING|CAPITALIZATION|TECHNICAL_JARGON)" "$classified_report" || echo "0")
    local medium_count=$(grep -c -E "(INCONSISTENT|STYLE|READABILITY|ACTION_NEEDED)" "$classified_report" || echo "0")
    local low_count=$(grep -c -E "(MINOR|SUGGESTION|ENHANCEMENT)" "$classified_report" || echo "0")
    local total_issues=$((critical_count + high_count + medium_count + low_count))
    
    cat > "$stats_file" <<EOF
Text Quality Statistics
======================
Generated: $(date)

Issue Summary:
- Critical Issues: $critical_count
- High Priority: $high_count  
- Medium Priority: $medium_count
- Low Priority: $low_count
- Total Issues: $total_issues

Severity Distribution:
- Critical: $(echo "scale=1; $critical_count * 100 / $total_issues" | bc 2>/dev/null || echo "0.0")%
- High: $(echo "scale=1; $high_count * 100 / $total_issues" | bc 2>/dev/null || echo "0.0")%
- Medium: $(echo "scale=1; $medium_count * 100 / $total_issues" | bc 2>/dev/null || echo "0.0")%
- Low: $(echo "scale=1; $low_count * 100 / $total_issues" | bc 2>/dev/null || echo "0.0")%

Recommended Action:
EOF
    
    if [ "$critical_count" -gt 0 ]; then
        echo "IMMEDIATE: Address $critical_count critical issues first" >> "$stats_file"
    elif [ "$high_count" -gt 10 ]; then
        echo "URGENT: High volume of high-priority issues ($high_count)" >> "$stats_file"
    elif [ "$total_issues" -gt 50 ]; then
        echo "PLANNED: Schedule text quality improvement session" >> "$stats_file"
    else
        echo "MAINTENANCE: Regular text quality is good" >> "$stats_file"
    fi
    
    echo "$stats_file"
}
```

## Step 4: Comprehensive Report Generation

**Generate Actionable Text Quality Report:**
```bash
# Generate comprehensive text scan report
generate_text_scan_report() {
    local session_id=$1
    local target_dir=$2
    local report_file="$target_dir/text-quality-scan-report.md"
    
    echo "Generating comprehensive text quality scan report..."
    
    # Get aggregated results and classification
    local aggregated_report="/tmp/aggregated-analysis-$session_id"
    local classified_report=$(classify_text_issues "$aggregated_report")
    local stats_file=$(generate_issue_statistics "$classified_report")
    
    # Generate markdown report
    cat > "$report_file" <<EOF
# Text Quality Scan Report

**Generated:** $(date)
**Target Directory:** $target_dir
**Scan Session:** $session_id

## Executive Summary

$(cat "$stats_file")

## Critical Issues (Fix Immediately)

$(grep -A 1000 "CRITICAL ISSUES" "$classified_report" | grep -E "^(SYNTAX_ERROR|BROKEN_LINK|SECURITY_SENSITIVE|USER_MESSAGE_ISSUE)" | head -20)

## High Priority Issues

$(grep -A 1000 "HIGH PRIORITY" "$classified_report" | grep -E "^(UNCLEAR_|GRAMMAR|SPELLING|CAPITALIZATION|TECHNICAL_JARGON)" | head -20)

## Medium Priority Issues

$(grep -A 1000 "MEDIUM PRIORITY" "$classified_report" | grep -E "^(INCONSISTENT|STYLE|READABILITY|ACTION_NEEDED)" | head -20)

## Recommendations

### Immediate Actions
1. **Fix Critical Issues**: Address all critical issues that affect functionality
2. **Review User Messages**: Improve grammar and clarity in user-facing text
3. **Standardize Terminology**: Ensure consistent technical vocabulary

### Next Steps
1. Run \`/code/proofread\` to apply automatic corrections
2. Use \`/code/review\` for interactive issue resolution
3. Execute \`/code/polish\` for comprehensive text improvement

### Tools and Resources
- Grammar checking: Built-in text analysis
- Spelling verification: Integrated dictionary checks
- Style guidelines: Project-specific conventions
- Terminology: Consistent technical vocabulary

## Detailed Analysis Results

$(cat "$aggregated_report")

## File Coverage

### Files Analyzed
$(find_files_filtered "$target_dir" "*" | while read -r file; do
    if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
        echo "- $file"
    fi
done | head -50)

$([ $(find_files_filtered "$target_dir" "*" | while read -r file; do
    if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
        echo "$file"
    fi
done | wc -l) -gt 50 ] && echo "... and $(( $(find_files_filtered "$target_dir" "*" | while read -r file; do
    if is_source_file "$file" || [ "$(detect_text_content_type "$file")" != "other" ]; then
        echo "$file"
    fi
done | wc -l) - 50 )) more files")

### File Type Distribution
- Source Code: $(find_files_filtered "$target_dir" "*" | while read -r file; do is_source_file "$file" && echo "$file"; done | wc -l) files
- Documentation: $(find_files_filtered "$target_dir" "*" | while read -r file; do [ "$(detect_text_content_type "$file")" = "documentation" ] && echo "$file"; done | wc -l) files
- Configuration: $(find_files_filtered "$target_dir" "*" | while read -r file; do [ "$(detect_text_content_type "$file")" = "configuration" ] && echo "$file"; done | wc -l) files

---
*Generated by Claude Code Text Quality Suite*
EOF
    
    echo "✅ Comprehensive text quality report generated: $report_file"
    echo "$report_file"
}

# Display scan summary to user
display_scan_summary() {
    local report_file=$1
    local stats_file=$2
    
    echo ""
    echo "=== TEXT QUALITY SCAN COMPLETED ==="
    echo ""
    
    # Show key statistics
    if [ -f "$stats_file" ]; then
        grep -A 20 "Issue Summary:" "$stats_file"
        echo ""
        grep -A 5 "Recommended Action:" "$stats_file"
    fi
    
    echo ""
    echo "📊 Full report saved to: $report_file"
    echo ""
    echo "🔧 Next steps:"
    echo "  1. Review critical issues first"
    echo "  2. Run /code/proofread for automatic fixes"
    echo "  3. Use /code/review for interactive corrections"
    echo "  4. Execute /code/polish for comprehensive improvement"
    echo ""
}
```

## Text Scanning Quality Checklist

**Comprehensive Scanning Validation:**
- [ ] All source code files analyzed for comments and text
- [ ] Documentation files thoroughly scanned
- [ ] Variable and function names checked for clarity
- [ ] User-facing strings and error messages validated
- [ ] Configuration files with text content reviewed
- [ ] Issues classified by severity and impact
- [ ] Actionable report generated with recommendations
- [ ] Zero text content overlooked or missed

**Agent Coordination Verification:**
- [ ] Comment analysis agent completed successfully
- [ ] Identifier analysis agent finished scanning
- [ ] String analysis agent processed all literals
- [ ] Documentation analysis agent covered all docs
- [ ] Configuration analysis agent checked all configs
- [ ] Results properly aggregated and classified

**Report Quality Standards:**
- [ ] Critical issues clearly identified and prioritized
- [ ] High-priority issues documented with context
- [ ] Medium and low priority issues cataloged
- [ ] Statistics and metrics provided for overview
- [ ] Next steps and recommendations included
- [ ] File coverage comprehensive and complete

**Text Scanning Anti-Patterns (FORBIDDEN):**
- ❌ "Skip files that look unimportant" → NO, scan everything
- ❌ "Only surface-level text checking" → NO, deep analysis required
- ❌ "Ignore context and code relationships" → NO, context matters
- ❌ "Generic issue categorization" → NO, specific classification needed
- ❌ "Incomplete agent coordination" → NO, all agents must complete
- ❌ "Missing text in complex files" → NO, comprehensive coverage required

**Final Scanning Verification:**
Before completing text scan:
- Have all text content types been analyzed comprehensively?
- Are issues properly classified by severity and impact?
- Does the report provide clear, actionable insights?
- Have all analysis agents completed successfully?
- Is the scan coverage complete across the entire codebase?
- Are recommendations specific and implementable?

**Final Commitment:**
I will now execute COMPLETE text scanning protocol and GENERATE COMPREHENSIVE ANALYSIS. I will:
- ✅ Deploy multiple agents for thorough text analysis
- ✅ Scan all text content types without exception
- ✅ Classify issues by severity and provide actionable insights
- ✅ Generate comprehensive report with clear recommendations
- ✅ Ensure zero text content is missed or overlooked

I will NOT:
- ❌ Skip any text content or file types
- ❌ Provide generic or unclear issue reports
- ❌ Miss context-dependent text quality problems
- ❌ Generate incomplete or superficial analysis
- ❌ Leave users without clear next steps

**REMEMBER: This is COMPREHENSIVE TEXT ANALYSIS - thorough scanning that provides actionable insights for text quality improvement across the entire codebase.**

**Executing comprehensive text scanning protocol NOW...**