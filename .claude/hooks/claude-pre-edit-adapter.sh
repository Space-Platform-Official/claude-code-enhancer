#!/bin/bash

# Claude Code Pre-Edit Hook Adapter
# Converts Claude Code JSON input to format expected by distributed PHP paradigm hooks

set -euo pipefail

# Read JSON input from Claude Code
json_input=$(cat)

# Extract file path from JSON
file_path=$(echo "$json_input" | jq -r '.tool_input.file_path // empty')

# If no file path in tool_input, this might be a different tool type
if [[ -z "$file_path" || "$file_path" == "null" ]]; then
    # Try alternative locations for file path
    file_path=$(echo "$json_input" | jq -r '.file_path // .target_file // empty')
fi

# Log the hook execution
hook_log=".claude/logs/hooks.log"
mkdir -p "$(dirname "$hook_log")"
echo "$(date -Iseconds) [INFO] [claude-pre-edit-adapter] Triggered for: $file_path" >> "$hook_log"

# Only process PHP files
if [[ "$file_path" =~ \.php$ ]]; then
    echo "$(date -Iseconds) [INFO] [claude-pre-edit-adapter] Processing PHP file: $file_path" >> "$hook_log"
    
    # Execute the distributed PHP paradigm pre-edit hook
    if [[ -x ".claude/hooks/php-paradigm/pre-edit.sh" ]]; then
        export FILE_PATH="$file_path"
        .claude/hooks/php-paradigm/pre-edit.sh "$file_path" || true
    else
        echo "$(date -Iseconds) [WARN] [claude-pre-edit-adapter] PHP paradigm pre-edit hook not found or not executable" >> "$hook_log"
    fi
else
    echo "$(date -Iseconds) [DEBUG] [claude-pre-edit-adapter] Skipping non-PHP file: $file_path" >> "$hook_log"
fi

# Return success (non-blocking)
exit 0