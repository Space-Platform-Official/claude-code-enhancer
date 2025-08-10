#!/bin/bash

# Claude Code Post-Edit Hook Adapter  
# Converts Claude Code JSON input to format expected by distributed PHP paradigm hooks

set -euo pipefail

# Read JSON input from Claude Code
json_input=$(cat)

# Extract file path from JSON
file_path=$(echo "$json_input" | jq -r '.tool_input.file_path // empty')

# If no file path in tool_input, try alternative locations
if [[ -z "$file_path" || "$file_path" == "null" ]]; then
    file_path=$(echo "$json_input" | jq -r '.file_path // .target_file // empty')
fi

# Log the hook execution
hook_log=".claude/logs/hooks.log"
mkdir -p "$(dirname "$hook_log")"
echo "$(date -Iseconds) [INFO] [claude-post-edit-adapter] Triggered for: $file_path" >> "$hook_log"

# Only process PHP files
if [[ "$file_path" =~ \.php$ ]]; then
    echo "$(date -Iseconds) [INFO] [claude-post-edit-adapter] Processing PHP file: $file_path" >> "$hook_log"
    
    # Execute the distributed PHP paradigm post-edit hook
    if [[ -x ".claude/hooks/php-paradigm/post-edit.sh" ]]; then
        export FILE_PATH="$file_path"
        
        # Run the post-edit hook which will auto-fix standards
        if .claude/hooks/php-paradigm/post-edit.sh "$file_path"; then
            echo "$(date -Iseconds) [INFO] [claude-post-edit-adapter] PHP paradigm auto-fixes applied to: $file_path" >> "$hook_log"
            
            # If file was modified by the hook, inform the user
            if [[ -f "$file_path" ]]; then
                echo "✅ PHP paradigm standards automatically applied to: $file_path"
            fi
        else
            echo "$(date -Iseconds) [WARN] [claude-post-edit-adapter] PHP paradigm post-edit hook failed for: $file_path" >> "$hook_log"
        fi
    else
        echo "$(date -Iseconds) [WARN] [claude-post-edit-adapter] PHP paradigm post-edit hook not found or not executable" >> "$hook_log"
    fi
else
    echo "$(date -Iseconds) [DEBUG] [claude-post-edit-adapter] Skipping non-PHP file: $file_path" >> "$hook_log"
fi

# Return success (non-blocking)
exit 0