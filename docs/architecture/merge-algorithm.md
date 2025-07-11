# Claude Flow Smart Merge Algorithm

## Overview

The smart merge algorithm is a key innovation in Claude Flow that enables intelligent combination of template configurations with existing project-specific Claude settings. This document details how the merge algorithm works, its decision-making process, and conflict resolution strategies.

## Algorithm Objectives

1. **Preserve Customizations**: Never lose project-specific configurations
2. **Avoid Duplication**: Prevent redundant content in merged files
3. **Maintain Structure**: Keep configurations organized and readable
4. **Enable Updates**: Allow template updates without losing customizations
5. **Provide Transparency**: Clear reporting of merge decisions

## Core Algorithm Flow

### High-Level Process

```
Input: Source Template + Target File
    ↓
1. Content Analysis
    ↓
2. Structural Parsing
    ↓
3. Conflict Detection
    ↓
4. Resolution Strategy
    ↓
5. Content Generation
    ↓
Output: Merged Configuration
```

### Detailed Algorithm Steps

```bash
function smart_merge(source, target) {
    if (!target.exists()) {
        return copy(source → target)
    }
    
    if (source.content == target.content) {
        return no_action_needed()
    }
    
    sections_source = parse_sections(source)
    sections_target = parse_sections(target)
    
    merged = create_merged_structure()
    
    // Add unique target content first
    for section in sections_target {
        if (!is_template_content(section)) {
            merged.add(section)
        }
    }
    
    // Add template content
    merged.add_template_marker()
    merged.add(sections_source)
    
    return merged
}
```

## Content Analysis

### Section Detection

The algorithm identifies content sections using:

1. **Markdown Headers**: `#`, `##`, `###` levels
2. **Comment Markers**: `<!-- -->` for metadata
3. **Code Blocks**: Triple backticks
4. **List Structures**: Bullet points and numbered lists

### Content Classification

Each section is classified as:

```
Template Content:
├── Standard Headers (e.g., "Development Partnership")
├── Common Sections (e.g., "AUTOMATED CHECKS")
└── Template Markers

Custom Content:
├── Project-Specific Rules
├── Team Guidelines
└── Local Configurations
```

## Merge Strategies

### 1. File-Level Merge

For complete file merging (`smart-merge-claude.sh`):

```bash
merge_claude_md() {
    # Step 1: Check file existence
    if [[ ! -f "$target_file" ]]; then
        # Simple copy for new files
        cp "$source_file" "$target_file"
        return
    fi
    
    # Step 2: Create merged structure
    {
        echo "# Merged CLAUDE.md Configuration"
        echo "<!-- Auto-merged on $(date) -->"
        
        # Step 3: Add existing custom content
        extract_custom_content "$target_file"
        
        # Step 4: Add template content
        echo "## Template Configuration"
        cat "$source_file"
    } > merged_file
}
```

### 2. Interactive Merge

For file conflicts (`install-claude-flow.sh`):

```bash
merge_file() {
    if files_differ(source, target); then
        show_options([
            "k: Keep existing",
            "o: Overwrite",
            "m: Merge later (.new)",
            "s: Skip"
        ])
        
        case $choice in
            k) keep_existing();;
            o) overwrite_file();;
            m) create_new_file();;
            s) skip_file();;
        esac
    fi
}
```

### 3. Content Deduplication

The algorithm prevents duplicate content:

```bash
extract_custom_content() {
    # Remove known template headers
    content=$(grep -v "^# Development Partnership" "$file")
    content=$(grep -v "^We're building production-quality" <<< "$content")
    
    # Remove template sections
    content=$(sed '/^## 🚨 AUTOMATED CHECKS/,$d' <<< "$content")
    
    echo "$content"
}
```

## Conflict Resolution

### Conflict Types

1. **Identical Files**: No action needed
2. **New vs Existing**: User choice required
3. **Modified Sections**: Smart merge attempted
4. **Incompatible Changes**: Manual resolution

### Resolution Strategies

#### 1. Automatic Resolution

When possible, conflicts are resolved automatically:

```bash
# Scenario: Adding new section to existing file
if section_not_exists(target, new_section); then
    append_section(target, new_section)
fi
```

#### 2. User-Guided Resolution

For ambiguous cases:

```
Conflict detected for: ./claude/CLAUDE.md
Options:
  [k] Keep existing file
  [o] Overwrite with new file  
  [m] Merge manually later (create .new file)
  [s] Skip this file
```

#### 3. Deferred Resolution

Creates `.new` files for manual merge:

```bash
# Creates: CLAUDE.md.new
cp "$source_file" "${target_file}.new"
echo "Review ${target_file}.new and merge manually"
```

## Advanced Merge Features

### 1. Section-Level Merging

```bash
merge_sections() {
    local -A source_sections target_sections
    
    # Parse sections by header
    parse_by_headers source_sections "$source"
    parse_by_headers target_sections "$target"
    
    # Merge non-conflicting sections
    for section in "${!source_sections[@]}"; do
        if [[ -z "${target_sections[$section]}" ]]; then
            # Add new section
            merged_sections[$section]="${source_sections[$section]}"
        elif [[ "${source_sections[$section]}" != "${target_sections[$section]}" ]]; then
            # Mark conflict
            conflicts+=("$section")
        fi
    done
}
```

### 2. Intelligent Content Matching

The algorithm uses pattern matching to identify similar content:

```bash
is_similar_content() {
    local content1="$1"
    local content2="$2"
    
    # Normalize whitespace
    norm1=$(echo "$content1" | tr -s ' \n')
    norm2=$(echo "$content2" | tr -s ' \n')
    
    # Calculate similarity
    similarity=$(compare_strings "$norm1" "$norm2")
    
    [[ $similarity -gt 80 ]]  # 80% threshold
}
```

### 3. Template Variable Preservation

Preserves variable substitutions:

```bash
preserve_variables() {
    # Detect variables like ${PROJECT_NAME}
    variables=$(grep -o '\${[^}]*}' "$file")
    
    # Ensure variables remain in merged content
    for var in $variables; do
        verify_variable_preserved "$var" "$merged"
    done
}
```

## Merge Report Generation

### Report Structure

```markdown
# Claude-Flow Merge Report

Date: 2024-01-15 10:30:00

## Summary
This report summarizes the merge operation performed by install-claude-flow.sh

### Source Directory
/usr/local/share/claude-flow/templates

### Target Directory
./claude

### Files Processed
- Main CLAUDE.md template
- Language-specific templates (3 files)
- Framework-specific templates (2 files)
- Command templates (18 files)

### Conflicts Resolved
- CLAUDE.md: Created .new file for manual merge
- languages/python/CLAUDE.md: Kept existing

### Manual Actions Required
Check for any .new files created during the merge process.

```bash
find ./claude -name "*.new" -type f
```
```

## Performance Optimization

### 1. Efficient File Comparison

```bash
# Use cmp for binary comparison (fast)
if ! cmp -s "$source" "$target"; then
    # Files differ, proceed with merge
fi
```

### 2. Streaming Processing

For large files:

```bash
# Process line by line to avoid memory issues
while IFS= read -r line; do
    process_line "$line"
done < "$large_file"
```

### 3. Parallel Processing

When merging multiple files:

```bash
# Process independent files in parallel
for file in "${files[@]}"; do
    merge_file "$file" &
done
wait  # Wait for all background jobs
```

## Error Handling

### Common Error Scenarios

1. **Permission Denied**:
   ```bash
   if [[ ! -w "$target_dir" ]]; then
       error "No write permission for $target_dir"
   fi
   ```

2. **Disk Space**:
   ```bash
   check_disk_space() {
       available=$(df "$target_dir" | awk 'NR==2 {print $4}')
       [[ $available -lt $MIN_SPACE ]] && error "Insufficient disk space"
   }
   ```

3. **Corrupted Files**:
   ```bash
   validate_file() {
       # Check file integrity
       [[ -f "$file" ]] || return 1
       [[ -s "$file" ]] || return 1
       file "$file" | grep -q "text" || return 1
   }
   ```

## Best Practices

### 1. Merge Safety

- Always create backups before merging
- Validate merged content before replacing
- Provide rollback mechanisms

### 2. User Communication

- Clear progress indicators
- Detailed conflict explanations
- Actionable error messages

### 3. Testing

- Unit tests for merge functions
- Integration tests with real templates
- Edge case validation

## Future Enhancements

### 1. Three-Way Merge

Implement git-style three-way merge:
```
Common Ancestor + Source + Target → Merged Result
```

### 2. Semantic Merging

Understanding content meaning:
- Merge based on functionality
- Intelligent section ordering
- Context-aware decisions

### 3. Merge Profiles

Customizable merge strategies:
- Conservative: Preserve everything
- Aggressive: Favor templates
- Interactive: Always ask user

This smart merge algorithm ensures that Claude Flow can safely and intelligently combine configurations while respecting user customizations and maintaining file integrity.