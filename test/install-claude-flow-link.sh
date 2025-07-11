#!/bin/bash

# Simple symlink approach - create a link to the actual script
# but override the source directory to use test templates

# Enable strict error handling
set -euo pipefail

# Ensure clean exit on signals
trap 'exit $?' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Validate environment
if [[ -z "${BASH_SOURCE[0]:-}" ]]; then
    echo "ERROR: Cannot determine script location" >&2
    exit 1
fi

# Get directories (use absolute paths)
readonly TEST_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" && builtin pwd)"
readonly PARENT_DIR="$(dirname "${TEST_DIR}")"
readonly MOCK_TEMPLATES_DIR="${TEST_DIR}/mock-templates"
readonly MAIN_SCRIPT="${PARENT_DIR}/install-claude-flow.sh"

# Validate required files exist
if [[ ! -f "${MAIN_SCRIPT}" ]]; then
    echo "ERROR: Main installation script not found: ${MAIN_SCRIPT}" >&2
    exit 1
fi

if [[ ! -d "${MOCK_TEMPLATES_DIR}" ]]; then
    echo "ERROR: Mock templates directory not found: ${MOCK_TEMPLATES_DIR}" >&2
    exit 1
fi

# Validate templates exist in mock directory
if [[ ! -d "${MOCK_TEMPLATES_DIR}/templates" ]]; then
    echo "ERROR: Mock templates subdirectory not found: ${MOCK_TEMPLATES_DIR}/templates" >&2
    exit 1
fi

# Export environment variable to override template location
export CLAUDE_TEMPLATE_SOURCE="${MOCK_TEMPLATES_DIR}"

# Run the actual script with explicit bash to avoid shell environment issues
exec /bin/bash "${MAIN_SCRIPT}" "$@"