# Template System Architecture

## Overview

The Template System Architecture is a sophisticated framework for managing, inheriting, and composing templates across multiple languages, frameworks, and workflows. It provides intelligent template organization, smart inheritance patterns, and progressive disclosure mechanisms to minimize complexity while maximizing functionality.

## Architecture Philosophy

The template system is built on five core architectural principles:

1. **Template Inheritance**: Hierarchical template organization with base-to-enhanced progression
2. **Smart Composition**: Intelligent template merging and conflict resolution
3. **Progressive Disclosure**: On-demand template generation and content revelation
4. **Framework Awareness**: Template organization respecting ecosystem conventions
5. **Consolidation Mandate**: Aggressive template deduplication and file minimization

## Template Hierarchy Structure

### Hierarchical Template Organization

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Template System Architecture                      │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Base Templates              Enhanced Templates         Framework Temps  │
│  ┌─────────────────┐         ┌─────────────────┐       ┌───────────────┐ │
│  │ languages/      │  ───►   │ ENHANCED.md     │  ───► │ frameworks/   │ │
│  │ ├─ js/         │         │ versions        │       │ ├─ react/     │ │
│  │ │  └─ CLAUDE.md │         │                 │       │ ├─ nextjs/    │ │
│  │ ├─ python/     │         │ Advanced        │       │ ├─ django/    │ │
│  │ │  └─ CLAUDE.md │         │ Features        │       │ └─ express/   │ │
│  │ ├─ php/        │         │                 │       │               │ │
│  │ │  └─ CLAUDE.md │         │ Complex         │       │ Framework-    │ │
│  │ └─ go/         │         │ Workflows       │       │ specific      │ │
│  │    └─ CLAUDE.md │         │                 │       │ Extensions    │ │
│  └─────────────────┘         └─────────────────┘       └───────────────┘ │
│                                                                         │
│  Command Templates           Workflow Templates         Shared Utils    │
│  ┌─────────────────┐         ┌─────────────────┐       ┌───────────────┐ │
│  │ commands/       │         │ workflows/      │       │ base/         │ │
│  │ ├─ git/         │         │ ├─ ci-cd/       │       │ └─ CLAUDE.md  │ │
│  │ ├─ test/        │         │ ├─ testing/     │       │               │ │
│  │ ├─ quality/     │         │ └─ docs/        │       │ Core Config   │ │
│  │ └─ milestone/   │         │                 │       │ Shared Base   │ │
│  │                 │         │ Automation      │       │               │ │
│  │ Task-specific   │         │ Patterns        │       │ Universal     │ │
│  │ Commands        │         │                 │       │ Utilities     │ │
│  └─────────────────┘         └─────────────────┘       └───────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

### Template Classification System

#### 1. Base Templates (Foundation Layer)
Core language templates providing essential functionality:

```yaml
base_templates:
  structure: "languages/{language}/CLAUDE.md"
  purpose: "Essential language-specific configurations"
  constraints:
    max_templates_per_language: 2  # Base + Enhanced only
    inheritance_depth: 3  # Base → Enhanced → Framework
    
language_templates:
  javascript:
    base: "languages/javascript/CLAUDE.md"
    enhanced: "languages/javascript/CLAUDE_ENHANCED.md"
    frameworks: ["react", "nextjs", "express"]
    
  python:
    base: "languages/python/CLAUDE.md"
    enhanced: null  # Single template approach
    frameworks: ["django", "fastapi", "flask"]
    
  php:
    base: "languages/php/CLAUDE.md"
    enhanced: "languages/php/CLAUDE_ENHANCED.md"
    frameworks: ["laravel", "symfony"]
```

#### 2. Framework Templates (Specialization Layer)
Framework-specific extensions built on language bases:

```yaml
framework_templates:
  inheritance_pattern: "languages/{base} + frameworks/{framework}"
  composition_strategy: "additive_merge"
  
  react:
    base: "languages/javascript/CLAUDE.md"
    extends: "frameworks/react/CLAUDE.md"
    capabilities:
      - "Component architecture patterns"
      - "Hook-based state management"
      - "Testing with React Testing Library"
      
  nextjs:
    base: "frameworks/react/CLAUDE.md"  # Inherits from React
    extends: "frameworks/nextjs/CLAUDE.md"
    capabilities:
      - "SSR/SSG optimization"
      - "API routes integration"
      - "Performance monitoring"
```

#### 3. Command Templates (Functionality Layer)
Reusable command patterns for development workflows:

```yaml
command_templates:
  organization: "hierarchical_with_shared"
  deduplication: "aggressive"
  
  template_families:
    git:
      shared: "commands/git/_shared/"
      commands: ["commit", "pr", "branch", "status"]
      utilities: ["config", "hooks", "security"]
      
    test:
      shared: "commands/test/_shared/"
      commands: ["unit", "integration", "e2e", "performance"]
      utilities: ["runners", "coverage", "fixtures"]
      
    quality:
      shared: "commands/quality/_shared/"
      commands: ["verify", "format", "cleanup", "dedupe"]
      utilities: ["safety", "utils"]
```

## Template Inheritance Engine

### Base-to-Enhanced Inheritance

```bash
# Template inheritance resolution engine
resolve_template_inheritance() {
    local target_language=$1
    local target_framework=${2:-""}
    local enhancement_level=${3:-"base"}
    
    echo "🧬 Resolving template inheritance for: $target_language"
    
    local inheritance_chain=()
    
    # Step 1: Base language template
    local base_template="languages/$target_language/CLAUDE.md"
    if [ -f "templates/$base_template" ]; then
        inheritance_chain+=("$base_template")
        echo "  ✅ Base template: $base_template"
    else
        echo "  ❌ Base template not found: $base_template"
        return 1
    fi
    
    # Step 2: Enhanced template (if requested and exists)
    if [ "$enhancement_level" = "enhanced" ]; then
        local enhanced_template="languages/$target_language/CLAUDE_ENHANCED.md"
        if [ -f "templates/$enhanced_template" ]; then
            inheritance_chain+=("$enhanced_template")
            echo "  ✅ Enhanced template: $enhanced_template"
        fi
    fi
    
    # Step 3: Framework template (if specified)
    if [ -n "$target_framework" ]; then
        local framework_template="frameworks/$target_framework/CLAUDE.md"
        if [ -f "templates/$framework_template" ]; then
            inheritance_chain+=("$framework_template")
            echo "  ✅ Framework template: $framework_template"
        fi
    fi
    
    # Step 4: Generate inheritance metadata
    create_inheritance_metadata "${inheritance_chain[@]}"
    
    echo "  🔗 Inheritance chain: ${inheritance_chain[*]}"
    return 0
}

# Create inheritance metadata for template composition
create_inheritance_metadata() {
    local templates=("$@")
    local metadata_file=".claude/template_inheritance.yaml"
    
    cat > "$metadata_file" << EOF
inheritance:
  resolved_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  chain: [$(printf '"%s",' "${templates[@]}" | sed 's/,$//')]
  composition_strategy: "smart_merge"
  
template_sources:
EOF
    
    for template in "${templates[@]}"; do
        cat >> "$metadata_file" << EOF
  - path: "$template"
    checksum: "$(md5sum "templates/$template" | cut -d' ' -f1)"
    size: $(stat -c%s "templates/$template")
EOF
    done
}
```

### Smart Template Composition

```bash
# Intelligent template merging with conflict resolution
compose_templates_intelligently() {
    local inheritance_chain=("$@")
    local composed_file=".claude/CLAUDE_COMPOSED.md"
    
    echo "🔀 Composing templates with smart merging..."
    
    # Initialize with base template
    local base_template="${inheritance_chain[0]}"
    cp "templates/$base_template" "$composed_file"
    
    # Apply each subsequent template
    for i in $(seq 1 $((${#inheritance_chain[@]} - 1))); do
        local current_template="${inheritance_chain[$i]}"
        echo "  🔀 Merging: $current_template"
        
        merge_template_content "$composed_file" "templates/$current_template"
    done
    
    # Optimize composed template
    optimize_composed_template "$composed_file"
    
    echo "  ✅ Template composition complete: $composed_file"
}

# Merge template content with intelligent conflict resolution
merge_template_content() {
    local target_file=$1
    local source_file=$2
    local temp_file=$(mktemp)
    
    # Extract sections from both files
    extract_template_sections "$target_file" "target"
    extract_template_sections "$source_file" "source"
    
    # Merge sections intelligently
    merge_sections_with_strategy "target_sections.yaml" "source_sections.yaml" > "$temp_file"
    
    # Replace target with merged content
    mv "$temp_file" "$target_file"
    
    # Cleanup temporary files
    rm -f target_sections.yaml source_sections.yaml
}

# Extract template sections for intelligent merging
extract_template_sections() {
    local template_file=$1
    local prefix=$2
    local sections_file="${prefix}_sections.yaml"
    
    # Parse template into logical sections
    python3 << EOF
import re
import yaml

with open('$template_file', 'r') as f:
    content = f.read()

# Extract major sections
sections = {}

# Development Partnership section
dev_match = re.search(r'# Development Partnership(.*?)(?=^# |\Z)', content, re.MULTILINE | re.DOTALL)
if dev_match:
    sections['development_partnership'] = dev_match.group(1).strip()

# Complexity Triage section
complexity_match = re.search(r'# .*COMPLEXITY TRIAGE SYSTEM(.*?)(?=^# |\Z)', content, re.MULTILINE | re.DOTALL)
if complexity_match:
    sections['complexity_triage'] = complexity_match.group(1).strip()

# File Creation section
file_match = re.search(r'# .*FILE CREATION CONSTRAINTS(.*?)(?=^# |\Z)', content, re.MULTILINE | re.DOTALL)
if file_match:
    sections['file_creation'] = file_match.group(1).strip()

# Workflow section
workflow_match = re.search(r'# CRITICAL WORKFLOW(.*?)(?=^# |\Z)', content, re.MULTILINE | re.DOTALL)
if workflow_match:
    sections['workflow'] = workflow_match.group(1).strip()

with open('$sections_file', 'w') as f:
    yaml.dump(sections, f, default_flow_style=False)
EOF
}
```

### Template Parameterization System

```bash
# Template parameterization for dynamic content generation
parameterize_template() {
    local template_file=$1
    local parameters_file=$2
    local output_file=$3
    
    echo "⚙️ Parameterizing template: $template_file"
    
    # Load parameters
    local parameters=$(cat "$parameters_file")
    
    # Apply parameter substitution
    envsubst < "$template_file" > "$output_file.tmp"
    
    # Apply advanced templating logic
    apply_advanced_templating "$output_file.tmp" "$parameters" "$output_file"
    
    rm -f "$output_file.tmp"
    
    echo "  ✅ Template parameterized: $output_file"
}

# Advanced templating with conditional sections
apply_advanced_templating() {
    local template_file=$1
    local parameters=$2
    local output_file=$3
    
    python3 << EOF
import json
import re

# Load parameters
params = json.loads('$parameters')

with open('$template_file', 'r') as f:
    content = f.read()

# Process conditional sections
# Pattern: {{#if variable}}content{{/if}}
def process_conditionals(text):
    pattern = r'\{\{#if\s+(\w+)\}\}(.*?)\{\{/if\}\}'
    
    def replace_conditional(match):
        var_name = match.group(1)
        content = match.group(2)
        
        if var_name in params and params[var_name]:
            return content
        else:
            return ''
    
    return re.sub(pattern, replace_conditional, text, flags=re.DOTALL)

# Process loops
# Pattern: {{#each items}}content{{/each}}
def process_loops(text):
    pattern = r'\{\{#each\s+(\w+)\}\}(.*?)\{\{/each\}\}'
    
    def replace_loop(match):
        var_name = match.group(1)
        content = match.group(2)
        
        if var_name in params and isinstance(params[var_name], list):
            result = ''
            for item in params[var_name]:
                item_content = content.replace('{{this}}', str(item))
                result += item_content
            return result
        else:
            return ''
    
    return re.sub(pattern, replace_loop, text, flags=re.DOTALL)

# Apply transformations
content = process_conditionals(content)
content = process_loops(content)

# Variable substitution
for key, value in params.items():
    content = content.replace(f'{{{{{key}}}}}', str(value))

with open('$output_file', 'w') as f:
    f.write(content)
EOF
}
```

## Template Consolidation System

### Aggressive Deduplication

```bash
# Aggressive template deduplication engine
deduplicate_templates_aggressively() {
    local template_dir="templates"
    local dedup_report=".claude/deduplication_report.yaml"
    
    echo "🔄 Starting aggressive template deduplication..."
    
    # Find duplicate content across templates
    find_duplicate_template_content "$template_dir"
    
    # Extract common patterns
    extract_common_patterns "$template_dir"
    
    # Create consolidated templates
    create_consolidated_templates "$template_dir"
    
    # Generate deduplication report
    generate_deduplication_report > "$dedup_report"
    
    echo "✅ Template deduplication complete. Report: $dedup_report"
}

# Find duplicate content across templates
find_duplicate_template_content() {
    local template_dir=$1
    local duplicates_file=".claude/template_duplicates.json"
    
    echo "  🔍 Scanning for duplicate content..."
    
    python3 << EOF
import os
import hashlib
import json
from collections import defaultdict

duplicates = defaultdict(list)
content_hashes = {}

for root, dirs, files in os.walk('$template_dir'):
    for file in files:
        if file.endswith('.md'):
            filepath = os.path.join(root, file)
            
            with open(filepath, 'r') as f:
                content = f.read()
            
            # Hash content sections separately
            sections = content.split('# ')
            for i, section in enumerate(sections):
                if len(section.strip()) > 100:  # Only significant sections
                    section_hash = hashlib.md5(section.encode()).hexdigest()
                    
                    if section_hash in content_hashes:
                        duplicates[section_hash].append({
                            'file': filepath,
                            'section': i,
                            'content_preview': section[:100]
                        })
                    else:
                        content_hashes[section_hash] = {
                            'file': filepath,
                            'section': i,
                            'content_preview': section[:100]
                        }

# Only keep actual duplicates
actual_duplicates = {k: v for k, v in duplicates.items() if len(v) > 0}

with open('$duplicates_file', 'w') as f:
    json.dump(actual_duplicates, f, indent=2)

print(f"  Found {len(actual_duplicates)} duplicate content sections")
EOF
}

# Extract common patterns for consolidation
extract_common_patterns() {
    local template_dir=$1
    local patterns_file=".claude/common_patterns.yaml"
    
    echo "  🧩 Extracting common patterns..."
    
    # Find frequently repeated patterns
    python3 << EOF
import os
import re
import yaml
from collections import Counter

patterns = Counter()

for root, dirs, files in os.walk('$template_dir'):
    for file in files:
        if file.endswith('.md'):
            filepath = os.path.join(root, file)
            
            with open(filepath, 'r') as f:
                content = f.read()
            
            # Extract common markdown patterns
            headers = re.findall(r'^#+\s+(.+)$', content, re.MULTILINE)
            for header in headers:
                patterns[f"header:{header}"] += 1
            
            # Extract code blocks
            code_blocks = re.findall(r'```(\w+)?\n(.*?)\n```', content, re.DOTALL)
            for lang, code in code_blocks:
                if len(code.strip()) > 50:
                    patterns[f"code_block:{lang}"] += 1
            
            # Extract list patterns
            lists = re.findall(r'^[\s]*[-*+]\s+(.+)$', content, re.MULTILINE)
            for item in lists:
                if 'claude' in item.lower() or 'template' in item.lower():
                    patterns[f"list_item:{item[:30]}"] += 1

# Filter patterns that appear in multiple files
common_patterns = {pattern: count for pattern, count in patterns.items() if count >= 3}

with open('$patterns_file', 'w') as f:
    yaml.dump({'common_patterns': common_patterns}, f)

print(f"  Extracted {len(common_patterns)} common patterns")
EOF
}
```

### Template Consolidation Strategies

```bash
# Create consolidated templates from duplicates
create_consolidated_templates() {
    local template_dir=$1
    
    echo "  🏗️ Creating consolidated templates..."
    
    # Create base consolidated template
    create_base_consolidated_template "$template_dir"
    
    # Create language-specific consolidated templates
    create_language_consolidated_templates "$template_dir"
    
    # Create framework-specific consolidated templates
    create_framework_consolidated_templates "$template_dir"
}

# Create base consolidated template with common elements
create_base_consolidated_template() {
    local template_dir=$1
    local base_consolidated="$template_dir/base/CLAUDE_CONSOLIDATED.md"
    
    mkdir -p "$(dirname "$base_consolidated")"
    
    cat > "$base_consolidated" << 'EOF'
# Claude Code Enhanced Template (Consolidated Base)

## Universal Development Partnership

This consolidated template provides the foundational Claude Code configuration that applies across all languages and frameworks.

### Core Principles

1. **Complexity Triage**: Mandatory complexity classification before implementation
2. **Quality Gates**: Zero-tolerance failure handling
3. **Multi-Agent Coordination**: Sophisticated parallel execution
4. **Progressive Disclosure**: On-demand content generation
5. **State Management**: Session persistence and recovery

### Complexity Triage System

{{#include:complexity_triage_system}}

### Quality Framework

{{#include:quality_framework}}

### Multi-Agent Patterns

{{#include:multi_agent_patterns}}

### File Creation Constraints

{{#include:file_creation_constraints}}

### Integration Framework

{{#include:integration_framework}}

EOF
    
    echo "    ✅ Base consolidated template created"
}

# Create language-specific consolidated templates
create_language_consolidated_templates() {
    local template_dir=$1
    
    echo "    🔀 Creating language consolidations..."
    
    # JavaScript/TypeScript consolidation
    create_js_consolidated_template "$template_dir"
    
    # Python consolidation
    create_python_consolidated_template "$template_dir"
    
    # PHP consolidation
    create_php_consolidated_template "$template_dir"
}

# JavaScript/TypeScript consolidated template
create_js_consolidated_template() {
    local template_dir=$1
    local js_consolidated="$template_dir/languages/javascript/CLAUDE_CONSOLIDATED.md"
    
    mkdir -p "$(dirname "$js_consolidated")"
    
    cat > "$js_consolidated" << 'EOF'
# JavaScript/TypeScript Claude Code Template (Consolidated)

{{#extends:base/CLAUDE_CONSOLIDATED.md}}

## JavaScript-Specific Configuration

### Package Management
- NPM/Yarn dependency handling
- Lock file management
- Security vulnerability scanning

### Testing Framework Integration
- Jest/Vitest configuration
- React Testing Library integration
- E2E testing with Playwright/Cypress

### Build System Integration
- Webpack/Vite configuration
- Bundle optimization
- Development server coordination

### Framework-Specific Extensions

{{#if:react}}
#### React Framework
- Component architecture patterns
- Hook-based state management
- Performance optimization
{{/if}}

{{#if:nextjs}}
#### Next.js Framework
- SSR/SSG optimization
- API routes integration
- Performance monitoring
{{/if}}

{{#if:express}}
#### Express Framework
- API endpoint management
- Middleware coordination
- Database integration
{{/if}}

EOF
    
    echo "      ✅ JavaScript consolidated template created"
}
```

## Progressive Disclosure Engine

### On-Demand Content Generation

```bash
# Progressive disclosure system for template content
implement_progressive_disclosure() {
    local template_file=$1
    local user_context=$2
    local disclosure_level=${3:-"basic"}
    
    echo "📋 Implementing progressive disclosure for: $template_file"
    
    # Analyze user context for relevant content
    local relevant_sections=$(analyze_user_context "$user_context")
    
    # Generate initial view (80/20 rule)
    generate_initial_view "$template_file" "$relevant_sections" > "${template_file%.md}_INITIAL.md"
    
    # Create expansion points
    create_expansion_points "$template_file" "$disclosure_level"
    
    # Generate on-demand content generators
    create_content_generators "$template_file" "$relevant_sections"
    
    echo "  ✅ Progressive disclosure implemented"
}

# Analyze user context to determine relevant content
analyze_user_context() {
    local context=$1
    
    python3 << EOF
import json

context = json.loads('$context')
relevant_sections = []

# Analyze project structure
if 'package.json' in context.get('files', []):
    relevant_sections.extend(['javascript', 'npm', 'testing_jest'])

if 'requirements.txt' in context.get('files', []) or 'pyproject.toml' in context.get('files', []):
    relevant_sections.extend(['python', 'pip', 'testing_pytest'])

if 'composer.json' in context.get('files', []):
    relevant_sections.extend(['php', 'composer', 'testing_phpunit'])

# Analyze complexity indicators
if context.get('file_count', 0) > 100:
    relevant_sections.extend(['complexity_management', 'large_project_patterns'])

if 'test' in context.get('directories', []):
    relevant_sections.extend(['testing_framework', 'quality_gates'])

print(' '.join(relevant_sections))
EOF
}

# Create expansion points for on-demand content
create_expansion_points() {
    local template_file=$1
    local disclosure_level=$2
    local expansion_file="${template_file%.md}_EXPANSIONS.yaml"
    
    cat > "$expansion_file" << EOF
expansions:
  basic_to_intermediate:
    triggers:
      - "User requests advanced features"
      - "Project complexity increases"
    content:
      - "Advanced multi-agent patterns"
      - "Complex quality gates"
      - "Framework-specific optimizations"
  
  intermediate_to_advanced:
    triggers:
      - "User explicitly requests complex features"
      - "Performance critical scenarios"
    content:
      - "Performance optimization patterns"
      - "Custom agent development"
      - "Advanced integration patterns"
  
  contextual_expansions:
    testing_focus:
      content: "Comprehensive testing framework integration"
    git_workflow:
      content: "Advanced Git workflow automation"
    deployment_focus:
      content: "CI/CD pipeline integration patterns"

disclosure_strategy: "progressive"
default_level: "$disclosure_level"
EOF
}
```

### Dynamic Content Generation

```bash
# Generate content dynamically based on user actions
generate_dynamic_content() {
    local content_request=$1
    local user_context=$2
    local template_base=$3
    
    echo "🔧 Generating dynamic content: $content_request"
    
    case "$content_request" in
        "advanced_testing")
            generate_advanced_testing_content "$user_context" "$template_base"
            ;;
        "performance_optimization")
            generate_performance_content "$user_context" "$template_base"
            ;;
        "custom_agents")
            generate_custom_agent_content "$user_context" "$template_base"
            ;;
        "integration_patterns")
            generate_integration_content "$user_context" "$template_base"
            ;;
        *)
            echo "  ⚠️ Unknown content request: $content_request"
            return 1
            ;;
    esac
}

# Generate advanced testing content dynamically
generate_advanced_testing_content() {
    local context=$1
    local base_template=$2
    local output_file="${base_template%.md}_TESTING_ADVANCED.md"
    
    cat > "$output_file" << EOF
# Advanced Testing Framework Integration

## Multi-Framework Testing Coordination

### Parallel Test Execution
\`\`\`bash
# Execute multiple test suites in parallel
run_parallel_test_suites() {
    local frameworks=(\$@)
    local pids=()
    
    for framework in "\${frameworks[@]}"; do
        execute_framework_tests "\$framework" &
        pids+=(\$!)
    done
    
    # Wait for all tests and validate 100% success
    for pid in "\${pids[@]}"; do
        wait \$pid
        if [ \$? -ne 0 ]; then
            echo "❌ Test suite failed - 100% success rate required"
            return 1
        fi
    done
    
    echo "✅ All test suites passed - 100% success achieved"
}
\`\`\`

### Advanced Test Coverage Analysis
- Cross-framework coverage aggregation
- Performance benchmark integration
- Security testing coordination
- Integration test orchestration

### Quality Gates Integration
- Pre-commit test validation
- CI/CD pipeline integration
- Automated performance regression detection
- Security vulnerability scanning

EOF
    
    echo "  ✅ Advanced testing content generated: $output_file"
}
```

## Template Quality Assurance

### Template Validation System

```bash
# Comprehensive template validation
validate_template_quality() {
    local template_file=$1
    local validation_report="${template_file%.md}_VALIDATION.yaml"
    
    echo "🔍 Validating template quality: $template_file"
    
    local validation_results=()
    
    # Validation 1: Structure consistency
    if validate_template_structure "$template_file"; then
        validation_results+=("structure:passed")
    else
        validation_results+=("structure:failed")
    fi
    
    # Validation 2: Content completeness
    if validate_content_completeness "$template_file"; then
        validation_results+=("completeness:passed")
    else
        validation_results+=("completeness:failed")
    fi
    
    # Validation 3: Inheritance compatibility
    if validate_inheritance_compatibility "$template_file"; then
        validation_results+=("inheritance:passed")
    else
        validation_results+=("inheritance:failed")
    fi
    
    # Validation 4: Quality standards compliance
    if validate_quality_standards "$template_file"; then
        validation_results+=("quality:passed")
    else
        validation_results+=("quality:failed")
    fi
    
    # Generate validation report
    generate_validation_report "$template_file" "${validation_results[@]}" > "$validation_report"
    
    # Overall validation result
    local failed_validations=$(printf '%s\n' "${validation_results[@]}" | grep -c "failed")
    
    if [ "$failed_validations" -eq 0 ]; then
        echo "  ✅ Template validation passed"
        return 0
    else
        echo "  ❌ Template validation failed ($failed_validations issues)"
        return 1
    fi
}

# Validate template structure consistency
validate_template_structure() {
    local template_file=$1
    
    # Check required sections
    local required_sections=(
        "Development Partnership"
        "COMPLEXITY TRIAGE SYSTEM"
        "FILE CREATION CONSTRAINTS"
        "CRITICAL WORKFLOW"
    )
    
    for section in "${required_sections[@]}"; do
        if ! grep -q "# .*$section" "$template_file"; then
            echo "    ❌ Missing required section: $section"
            return 1
        fi
    done
    
    return 0
}
```

### Template Performance Optimization

```bash
# Optimize template performance and size
optimize_template_performance() {
    local template_file=$1
    local optimized_file="${template_file%.md}_OPTIMIZED.md"
    
    echo "⚡ Optimizing template performance: $template_file"
    
    # Remove redundant content
    remove_redundant_content "$template_file" > "$optimized_file.tmp"
    
    # Compress verbose sections
    compress_verbose_sections "$optimized_file.tmp" > "$optimized_file.tmp2"
    
    # Optimize for loading speed
    optimize_loading_speed "$optimized_file.tmp2" > "$optimized_file"
    
    # Cleanup temporary files
    rm -f "$optimized_file.tmp" "$optimized_file.tmp2"
    
    # Calculate optimization metrics
    local original_size=$(stat -c%s "$template_file")
    local optimized_size=$(stat -c%s "$optimized_file")
    local size_reduction=$((100 - (optimized_size * 100 / original_size)))
    
    echo "  📊 Size reduction: ${size_reduction}% (${original_size} → ${optimized_size} bytes)"
    echo "  ✅ Template optimized: $optimized_file"
}
```

## Best Practices

### Template Design Principles

1. **Inheritance over Duplication**: Use template inheritance to reduce redundancy
2. **Progressive Disclosure**: Show essential content first, expand on demand
3. **Framework Awareness**: Respect ecosystem conventions and patterns
4. **Consolidation First**: Combine similar templates before creating new ones
5. **Quality Validation**: Validate all templates against quality standards

### Composition Strategies

1. **Smart Merging**: Intelligently merge templates with conflict resolution
2. **Parameterization**: Use parameters for dynamic content generation
3. **Conditional Sections**: Include/exclude content based on context
4. **Modular Components**: Create reusable template components
5. **Lazy Loading**: Generate content only when needed

### Performance Optimization

1. **Template Caching**: Cache composed templates for reuse
2. **Content Compression**: Optimize template size and loading speed
3. **Lazy Evaluation**: Generate expensive content on demand
4. **Dependency Optimization**: Minimize template dependencies
5. **Progressive Enhancement**: Start simple and enhance based on usage

This template system architecture provides the Claude Code Enhancer with sophisticated template management capabilities, ensuring efficient, maintainable, and flexible template organization while minimizing complexity and maximizing functionality through intelligent inheritance and composition patterns.