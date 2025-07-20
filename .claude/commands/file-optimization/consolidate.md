---
allowed-tools: all
description: Intelligent file consolidation with smart defaults to eliminate file proliferation while preserving functionality through merging and optimization
---

# ⚡⚡⚡ CRITICAL REQUIREMENT: FILE CONSOLIDATION EXECUTION! ⚡⚡⚡

**THIS IS NOT A SIMPLE CLEANUP TASK - THIS IS A COMPREHENSIVE FILE CONSOLIDATION AND OPTIMIZATION TASK!**

When you run `/consolidate`, you are REQUIRED to:

1. **ANALYZE** complete file structure and identify consolidation opportunities through smart grouping
2. **MERGE** related files using intelligent templating and inheritance patterns
3. **OPTIMIZE** directory hierarchies by flattening unnecessary nested structures
4. **PRESERVE** all existing functionality while reducing file proliferation by 40-60%
5. **USE MULTIPLE AGENTS** for comprehensive consolidation execution:
   - Spawn one agent for file similarity analysis and grouping identification
   - Spawn another for smart merging and template inheritance implementation
   - Spawn more agents for hierarchy optimization and reference updating
   - Say: "I'll spawn multiple agents to execute comprehensive file consolidation in parallel"

## 🎯 USE MULTIPLE AGENTS FOR CONSOLIDATION

**MANDATORY AGENT SPAWNING FOR FILE CONSOLIDATION:**
```
"I'll spawn multiple consolidation agents to handle file optimization in parallel:
- File Analysis Agent: Analyze structure and identify consolidation candidates
- Smart Merge Agent: Implement intelligent file merging with functionality preservation
- Hierarchy Optimization Agent: Flatten unnecessary nested structures and optimize navigation
- Reference Update Agent: Update all imports, links, and dependencies automatically
- Validation Agent: Ensure zero functionality loss and maintain compatibility"
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ "Just delete unused files" → NO! Smart consolidation with functionality preservation!
- ❌ "Quick merge without analysis" → NO! Intelligent analysis-driven consolidation required!
- ❌ "Skip validation of merged functionality" → NO! Comprehensive testing mandatory!
- ❌ "Ignore reference updates" → NO! All dependencies must be updated automatically!
- ❌ "Accept any functionality loss" → NO! Zero-loss consolidation requirement!
- ❌ "Manual consolidation process" → NO! Multi-agent automated consolidation required!

**MANDATORY CONSOLIDATION WORKFLOW:**
```
1. File structure analysis → Identify consolidation opportunities and grouping patterns
2. IMMEDIATELY spawn agents for parallel consolidation analysis and execution
3. Smart merging implementation → Combine related files with template inheritance
4. Hierarchy optimization → Flatten structures and improve navigation
5. Reference updating → Automatically update all dependencies and imports
6. VERIFY zero functionality loss and maintain full compatibility
```

**YOU ARE NOT DONE UNTIL:**
- ✅ Complete file structure analyzed and consolidation candidates identified
- ✅ Multi-agent consolidation execution deployed and coordinating
- ✅ Smart merging implemented with functionality preservation verified
- ✅ Directory hierarchies optimized and unnecessary nesting eliminated
- ✅ All references and dependencies updated automatically
- ✅ Zero functionality loss validated through comprehensive testing

---

🛑 **MANDATORY CONSOLIDATION VALIDATION CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Validate current file structure and identify consolidation opportunities
3. Confirm functionality preservation requirements and validation criteria

Execute comprehensive file consolidation with ZERO tolerance for functionality loss.

**FORBIDDEN CONSOLIDATION PATTERNS:**
- "Basic file deletion is enough" → NO, intelligent merging required
- "Simple hierarchy flattening works" → NO, smart optimization needed
- "Manual reference updates are fine" → NO, automated dependency management required
- "Some functionality loss is acceptable" → NO, zero-loss requirement
- "Single-agent consolidation is sufficient" → NO, multi-agent coordination required

You are consolidating files for: $ARGUMENTS

Let me execute comprehensive file consolidation with intelligent merging and optimization.

🚨 **REMEMBER: Effective consolidation requires smart merging, not simple deletion!** 🚨

**Comprehensive File Consolidation Protocol:**

## Step 0: File Structure Analysis and Consolidation Planning

**Analyze Current File Proliferation:**
```bash
# Comprehensive file structure analysis
analyze_file_structure() {
    echo "=== File Consolidation Analysis ==="
    
    # Count current file proliferation
    local total_files=$(find . -type f | wc -l)
    local docs_files=$(find . -name "*.md" | wc -l)
    local template_files=$(find . -path "*/templates/*" -type f | wc -l)
    local config_files=$(find . -name "*.yaml" -o -name "*.yml" -o -name "*.json" | wc -l)
    
    echo "Current File Count Analysis:"
    echo "Total files: $total_files"
    echo "Documentation files: $docs_files"
    echo "Template files: $template_files"
    echo "Configuration files: $config_files"
    
    # Identify consolidation opportunities
    identify_consolidation_candidates
}

identify_consolidation_candidates() {
    echo "🔍 Identifying consolidation opportunities..."
    
    # Find similar files for merging
    find_similar_files "*.md" "documentation"
    find_similar_files "*.yaml" "configuration"
    find_similar_templates
    find_redundant_hierarchies
    
    echo "✅ Consolidation analysis complete"
}
```

**Smart Grouping Strategy:**
```yaml
consolidation_groups:
  documentation:
    - similar_content_threshold: 0.7
    - structure_similarity: 0.8
    - merge_strategy: "template_inheritance"
    
  templates:
    - functional_similarity: 0.85
    - pattern_matching: "ast_analysis"
    - merge_strategy: "smart_templating"
    
  configurations:
    - schema_compatibility: true
    - value_overlap: 0.6
    - merge_strategy: "hierarchical_defaults"
```

## Step 1: Multi-Agent Consolidation Deployment

**Deploy Consolidation Agents:**
```bash
deploy_consolidation_agents() {
    local project_path=$1
    
    echo "🤖 Deploying file consolidation agents for: $project_path"
    
    # File Analysis Agent
    register_agent "file-analyzer" "file_analysis" "$project_path"
    spawn_file_analysis_agent "$project_path" &
    
    # Smart Merge Agent
    register_agent "smart-merger" "smart_merge" "$project_path"
    spawn_smart_merge_agent "$project_path" &
    
    # Hierarchy Optimization Agent
    register_agent "hierarchy-optimizer" "hierarchy_optimization" "$project_path"
    spawn_hierarchy_optimization_agent "$project_path" &
    
    # Reference Update Agent
    register_agent "reference-updater" "reference_update" "$project_path"
    spawn_reference_update_agent "$project_path" &
    
    # Validation Agent
    register_agent "consolidation-validator" "consolidation_validation" "$project_path"
    spawn_consolidation_validation_agent "$project_path" &
    
    echo "✅ All consolidation agents deployed"
}
```

## Step 2: Smart File Merging Implementation

**Smart Merge Agent:**
```bash
spawn_smart_merge_agent() {
    local project_path=$1
    
    echo "🔧 Smart Merge Agent: Starting intelligent file consolidation"
    
    # Get consolidation candidates
    local merge_groups=$(get_consolidation_groups "$project_path")
    
    for group in $merge_groups; do
        echo "📋 Processing merge group: $group"
        
        # Analyze group compatibility
        analyze_merge_compatibility "$group"
        
        # Create master template with inheritance
        create_master_template "$group"
        
        # Merge related files intelligently
        execute_smart_merge "$group"
        
        # Validate merged functionality
        validate_merge_result "$group"
        
        echo "✅ Group $group consolidated successfully"
    done
    
    echo "✅ Smart Merge Agent: All groups processed"
}

create_master_template() {
    local group=$1
    
    echo "🏗️ Creating master template for group: $group"
    
    # Extract common patterns
    local common_patterns=$(extract_common_patterns "$group")
    local variable_sections=$(identify_variable_sections "$group")
    
    # Generate template with inheritance
    cat > "templates/consolidated/$group-master.md" << EOF
---
# Master template for $group - Auto-generated by consolidation
template_type: "consolidated_master"
inherits_from: ["base-template"]
variable_sections: [$variable_sections]
---

# $(capitalize_group_name "$group") - Consolidated Template

$common_patterns

<!-- Dynamic sections based on inheritance -->
{% for section in variable_sections %}
{{ section.content }}
{% endfor %}

<!-- Original templates consolidated: -->
<!-- $(list_original_templates "$group") -->
EOF
    
    echo "✅ Master template created: templates/consolidated/$group-master.md"
}
```

## Step 3: Hierarchy Optimization and Structure Flattening

**Hierarchy Optimization Agent:**
```bash
spawn_hierarchy_optimization_agent() {
    local project_path=$1
    
    echo "📊 Hierarchy Optimization Agent: Flattening unnecessary structures"
    
    # Analyze current hierarchy depth
    local max_depth=$(find "$project_path" -type d | awk -F/ '{print NF}' | sort -n | tail -1)
    echo "Current maximum directory depth: $max_depth"
    
    # Identify optimization opportunities
    identify_unnecessary_nesting "$project_path"
    
    # Execute hierarchy optimization
    optimize_directory_structure "$project_path"
    
    # Update navigation and discovery
    update_navigation_structure "$project_path"
    
    echo "✅ Hierarchy Optimization Agent: Structure optimization complete"
}

optimize_directory_structure() {
    local project_path=$1
    
    echo "🚀 Optimizing directory structure..."
    
    # Find deep nesting that can be flattened
    find "$project_path" -type d -mindepth 4 | while read deep_dir; do
        if is_unnecessary_nesting "$deep_dir"; then
            flatten_directory_structure "$deep_dir"
        fi
    done
    
    # Consolidate single-child directories
    find "$project_path" -type d | while read dir; do
        if is_single_child_directory "$dir"; then
            consolidate_single_child "$dir"
        fi
    done
    
    # Update relative paths in all files
    update_relative_paths "$project_path"
    
    echo "✅ Directory structure optimized"
}
```

## Step 4: Reference and Dependency Management

**Reference Update Agent:**
```bash
spawn_reference_update_agent() {
    local project_path=$1
    
    echo "🔗 Reference Update Agent: Updating all dependencies and imports"
    
    # Build reference map of all changes
    build_reference_map "$project_path"
    
    # Update import statements
    update_import_statements "$project_path"
    
    # Update file links and references
    update_file_references "$project_path"
    
    # Update configuration paths
    update_configuration_paths "$project_path"
    
    # Verify all references are valid
    verify_reference_integrity "$project_path"
    
    echo "✅ Reference Update Agent: All dependencies updated"
}

update_import_statements() {
    local project_path=$1
    
    echo "📝 Updating import statements..."
    
    # Update markdown links
    find "$project_path" -name "*.md" -exec sed -i.bak -f reference_updates.sed {} \;
    
    # Update YAML references
    find "$project_path" -name "*.yaml" -exec update_yaml_references {} \;
    
    # Update script includes
    find "$project_path" -name "*.sh" -exec update_script_includes {} \;
    
    echo "✅ Import statements updated"
}
```

## Step 5: Functionality Preservation Validation

**Consolidation Validation Agent:**
```bash
spawn_consolidation_validation_agent() {
    local project_path=$1
    
    echo "🔍 Consolidation Validation Agent: Ensuring zero functionality loss"
    
    # Test all consolidated templates
    validate_template_functionality "$project_path"
    
    # Verify configuration compatibility
    validate_configuration_integrity "$project_path"
    
    # Test reference resolution
    validate_reference_resolution "$project_path"
    
    # Run comprehensive functionality tests
    run_consolidation_tests "$project_path"
    
    # Generate consolidation report
    generate_consolidation_report "$project_path"
    
    echo "✅ Consolidation Validation Agent: All functionality preserved"
}

run_consolidation_tests() {
    local project_path=$1
    
    echo "🧪 Running comprehensive consolidation tests..."
    
    # Test template generation
    test_template_generation "$project_path"
    
    # Test command execution
    test_command_execution "$project_path"
    
    # Test configuration loading
    test_configuration_loading "$project_path"
    
    # Test reference resolution
    test_reference_resolution "$project_path"
    
    # Performance regression testing
    test_performance_impact "$project_path"
    
    echo "✅ All consolidation tests passed"
}
```

## Step 6: Consolidation Quality Checklist

**File Consolidation Validation:**
- [ ] Complete file structure analyzed and optimization opportunities identified
- [ ] Smart merging implemented with template inheritance and functionality preservation
- [ ] Directory hierarchies optimized and unnecessary nesting eliminated
- [ ] All references and dependencies updated automatically and verified
- [ ] Zero functionality loss validated through comprehensive testing
- [ ] Performance impact measured and optimized
- [ ] Navigation and discoverability improved post-consolidation
- [ ] Consolidation report generated with metrics and recommendations

**Agent Coordination Checklist:**
- [ ] File analysis proceeding with comprehensive structure evaluation
- [ ] Smart merging executing with intelligent template consolidation
- [ ] Hierarchy optimization flattening structures without breaking functionality
- [ ] Reference updates maintaining all dependencies and imports correctly
- [ ] Validation ensuring zero functionality loss throughout process

**Consolidation Success Metrics:**
- [ ] 40-60% reduction in total file count achieved
- [ ] Directory depth reduced by at least 2 levels
- [ ] All original functionality preserved and validated
- [ ] Reference integrity maintained across all consolidated files
- [ ] Performance improved or maintained post-consolidation

**Anti-Patterns to Avoid:**
- ❌ Simple file deletion without intelligent merging
- ❌ Missing reference updates leading to broken dependencies
- ❌ Ignoring functionality validation during consolidation
- ❌ Accepting any level of functionality loss
- ❌ Manual consolidation without multi-agent coordination
- ❌ No validation of consolidated template effectiveness

**Final Verification:**
Before completing file consolidation:
- Have all file groups been intelligently analyzed and merged?
- Are directory hierarchies optimized for navigation and discovery?
- Have all references been updated and validated for correctness?
- Has functionality preservation been comprehensively tested?
- Are performance impacts measured and within acceptable bounds?
- Does the consolidation report show achieved optimization targets?

**Final Consolidation Commitment:**
- **I will**: Execute comprehensive file consolidation with intelligent merging and optimization
- **I will**: Implement multi-agent coordination for parallel consolidation processing
- **I will**: Maintain zero functionality loss through comprehensive validation
- **I will**: Update all references and dependencies automatically
- **I will NOT**: Accept simple deletion without smart consolidation
- **I will NOT**: Skip validation of merged functionality
- **I will NOT**: Ignore reference integrity or dependency management

**REMEMBER:**
This is FILE CONSOLIDATION mode - intelligent merging, optimization, and functionality preservation. The goal is to achieve significant file reduction while maintaining complete functionality through smart consolidation strategies.

Executing comprehensive file consolidation protocol for optimal structure and functionality...