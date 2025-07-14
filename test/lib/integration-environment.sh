#!/bin/bash

# Integration Environment Setup and Teardown for Claude Flow Git Testing
# Manages real git repositories, remotes, and test environments

# Enable strict error handling
set -euo pipefail

# Environment configuration
declare -A INTEGRATION_ENV
INTEGRATION_ENV[initialized]=false
INTEGRATION_ENV[test_name]=""
INTEGRATION_ENV[test_dir]=""
INTEGRATION_ENV[repo_dir]=""
INTEGRATION_ENV[remote_dir]=""
INTEGRATION_ENV[claude_config]=""

# Git configuration for tests
declare -A TEST_GIT_CONFIG
TEST_GIT_CONFIG[user.name]="Claude Test"
TEST_GIT_CONFIG[user.email]="test@claude.ai"
TEST_GIT_CONFIG[init.defaultBranch]="main"
TEST_GIT_CONFIG[commit.gpgsign]="false"

# Test repository templates
declare -A REPO_TEMPLATES
REPO_TEMPLATES[basic]="basic_repository"
REPO_TEMPLATES[monorepo]="monorepo_structure"
REPO_TEMPLATES[claude_flow]="claude_flow_enabled"

# Network simulation settings
declare -A NETWORK_SIMULATION
NETWORK_SIMULATION[enabled]=false
NETWORK_SIMULATION[latency_ms]=0
NETWORK_SIMULATION[packet_loss]=0
NETWORK_SIMULATION[bandwidth_limit]=""

# Safety guards
readonly SAFE_TEST_PREFIX="claude-test-"
readonly MAX_TEST_REPOS=10
readonly MAX_FILE_SIZE_MB=50

# Setup integration environment for a test
setup_integration_environment() {
    local test_name="$1"
    local test_dir="$2"
    
    print_debug "Setting up integration environment for: $test_name"
    
    # Validate test name for safety
    if [[ ! "$test_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Invalid test name: $test_name"
        return 1
    fi
    
    # Set environment variables
    INTEGRATION_ENV[test_name]="$test_name"
    INTEGRATION_ENV[test_dir]="$test_dir"
    INTEGRATION_ENV[repo_dir]="${test_dir}/repo"
    INTEGRATION_ENV[remote_dir]="${test_dir}/remote"
    INTEGRATION_ENV[claude_config]="${test_dir}/claude-config"
    
    # Create directory structure
    mkdir -p "${INTEGRATION_ENV[repo_dir]}"
    mkdir -p "${INTEGRATION_ENV[remote_dir]}"
    mkdir -p "${INTEGRATION_ENV[claude_config]}"
    
    # Initialize based on test requirements
    case "$test_name" in
        *feature*|*workflow*)
            setup_standard_repository
            ;;
        *monorepo*|*large*)
            setup_monorepo_structure
            ;;
        *collaboration*|*team*)
            setup_multi_user_environment
            ;;
        *)
            setup_basic_repository
            ;;
    esac
    
    INTEGRATION_ENV[initialized]=true
    return 0
}

# Clean up integration environment
cleanup_integration_environment() {
    local test_name="$1"
    local test_dir="$2"
    
    print_debug "Cleaning up integration environment for: $test_name"
    
    # Kill any remaining processes
    cleanup_test_processes "$test_name"
    
    # Remove network simulation if enabled
    if [[ "${NETWORK_SIMULATION[enabled]}" == "true" ]]; then
        remove_network_simulation
    fi
    
    # Clean up git repositories safely
    if [[ -d "$test_dir" && "$test_dir" == *"$SAFE_TEST_PREFIX"* ]]; then
        # Remove git locks if any
        find "$test_dir" -name "*.lock" -type f -delete 2>/dev/null || true
        
        # Force remove directories
        chmod -R u+w "$test_dir" 2>/dev/null || true
        rm -rf "$test_dir"
    fi
    
    # Reset environment
    INTEGRATION_ENV[initialized]=false
    return 0
}

# Setup basic git repository
setup_basic_repository() {
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    local remote_dir="${INTEGRATION_ENV[remote_dir]}"
    
    print_debug "Setting up basic repository"
    
    # Create bare remote repository
    (
        cd "$remote_dir"
        git init --bare origin.git
    )
    
    # Create and configure local repository
    (
        cd "$repo_dir"
        git init
        
        # Configure git
        git config user.name "${TEST_GIT_CONFIG[user.name]}"
        git config user.email "${TEST_GIT_CONFIG[user.email]}"
        git config init.defaultBranch "${TEST_GIT_CONFIG[init.defaultBranch]}"
        git config commit.gpgsign "${TEST_GIT_CONFIG[commit.gpgsign]}"
        
        # Add remote
        git remote add origin "${remote_dir}/origin.git"
        
        # Create initial files
        cat > README.md << EOF
# Test Repository

This is a test repository for Claude Flow integration testing.

## Purpose
- Test git commands
- Validate workflows
- Ensure reliability
EOF
        
        cat > .gitignore << EOF
# Test artifacts
*.log
*.tmp
.DS_Store
node_modules/
__pycache__/
*.pyc
EOF
        
        # Initial commit
        git add .
        git commit -m "Initial commit"
        git push -u origin main
    )
    
    return 0
}

# Setup standard repository with common structure
setup_standard_repository() {
    setup_basic_repository
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    
    print_debug "Setting up standard repository structure"
    
    (
        cd "$repo_dir"
        
        # Create standard directory structure
        mkdir -p src/{components,utils,services}
        mkdir -p tests/{unit,integration}
        mkdir -p docs
        mkdir -p scripts
        mkdir -p .github/workflows
        
        # Add source files
        cat > src/index.js << 'EOF'
// Main application entry point
console.log('Hello from Claude Flow test!');

export function main() {
    return 'Application started';
}
EOF
        
        cat > src/utils/helpers.js << 'EOF'
// Utility functions
export function formatDate(date) {
    return date.toISOString();
}

export function parseConfig(config) {
    return JSON.parse(config);
}
EOF
        
        # Add test files
        cat > tests/unit/helpers.test.js << 'EOF'
// Unit tests for helpers
import { formatDate, parseConfig } from '../../src/utils/helpers';

describe('helpers', () => {
    test('formatDate returns ISO string', () => {
        const date = new Date('2024-01-01');
        expect(formatDate(date)).toMatch(/^\d{4}-\d{2}-\d{2}/);
    });
});
EOF
        
        # Add package.json
        cat > package.json << 'EOF'
{
  "name": "claude-flow-test",
  "version": "1.0.0",
  "description": "Test repository for Claude Flow",
  "main": "src/index.js",
  "scripts": {
    "test": "jest",
    "lint": "eslint src/",
    "build": "echo 'Build completed'"
  },
  "devDependencies": {
    "jest": "^27.0.0",
    "eslint": "^8.0.0"
  }
}
EOF
        
        # Add Claude Flow configuration
        add_claude_flow_config
        
        # Commit structure
        git add .
        git commit -m "feat: add standard project structure"
        git push
    )
    
    return 0
}

# Setup monorepo structure
setup_monorepo_structure() {
    setup_basic_repository
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    
    print_debug "Setting up monorepo structure"
    
    (
        cd "$repo_dir"
        
        # Create monorepo structure
        mkdir -p packages/{core,web,api,shared}
        mkdir -p tools/{scripts,configs}
        
        # Root package.json
        cat > package.json << 'EOF'
{
  "name": "claude-test-monorepo",
  "private": true,
  "workspaces": [
    "packages/*"
  ],
  "scripts": {
    "test": "lerna run test",
    "build": "lerna run build",
    "lint": "lerna run lint"
  }
}
EOF
        
        # Add lerna configuration
        cat > lerna.json << 'EOF'
{
  "version": "independent",
  "npmClient": "npm",
  "packages": ["packages/*"]
}
EOF
        
        # Create package structures
        for pkg in core web api shared; do
            mkdir -p "packages/$pkg/src"
            cat > "packages/$pkg/package.json" << EOF
{
  "name": "@claude-test/$pkg",
  "version": "1.0.0",
  "main": "src/index.js"
}
EOF
            
            cat > "packages/$pkg/src/index.js" << EOF
// Package: $pkg
export default function() {
    return 'Package $pkg initialized';
}
EOF
        done
        
        # Add Claude Flow config
        add_claude_flow_config
        
        # Commit monorepo structure
        git add .
        git commit -m "feat: setup monorepo structure"
        git push
    )
    
    return 0
}

# Setup multi-user environment for collaboration testing
setup_multi_user_environment() {
    setup_standard_repository
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    local test_dir="${INTEGRATION_ENV[test_dir]}"
    
    print_debug "Setting up multi-user environment"
    
    # Create additional user repositories
    local users=("alice" "bob")
    for user in "${users[@]}"; do
        local user_repo="${test_dir}/repo-$user"
        mkdir -p "$user_repo"
        
        (
            cd "$user_repo"
            git clone "${INTEGRATION_ENV[remote_dir]}/origin.git" .
            
            # Configure user
            git config user.name "Test $user"
            git config user.email "$user@claude-test.ai"
            
            # Create user branch
            git checkout -b "feature/$user-work"
            
            # Make user-specific changes
            echo "// Changes by $user" >> "src/index.js"
            git add .
            git commit -m "feat: $user's contribution"
            git push -u origin "feature/$user-work"
        )
    done
    
    return 0
}

# Add Claude Flow configuration to repository
add_claude_flow_config() {
    # Add CLAUDE.md
    cat > CLAUDE.md << 'EOF'
# Claude Flow Test Configuration

This repository is configured for Claude Flow testing.

## Git Workflow Rules
- Feature branches must start with `feature/`
- Direct commits to main are blocked
- All commits must pass pre-commit hooks
- Commits require descriptive messages

## Testing Requirements
- All tests must pass before commit
- Linting errors block commits
- Security scans are mandatory
EOF
    
    # Add pre-commit hooks
    mkdir -p .git/hooks
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook for testing

echo "Running pre-commit checks..."

# Check for large files
large_files=$(find . -type f -size +50M 2>/dev/null)
if [[ -n "$large_files" ]]; then
    echo "Error: Large files detected (>50MB):"
    echo "$large_files"
    exit 1
fi

# Simulate linting
if grep -r "TODO" src/ 2>/dev/null; then
    echo "Warning: TODO comments found"
fi

echo "Pre-commit checks passed"
exit 0
EOF
    chmod +x .git/hooks/pre-commit
}

# Create test files with specific characteristics
create_test_files() {
    local type="$1"
    local location="${2:-.}"
    
    case "$type" in
        large)
            # Create large file (but within safety limits)
            dd if=/dev/zero of="${location}/large-file.bin" bs=1M count=40 2>/dev/null
            ;;
        binary)
            # Create binary file
            echo -e "\x00\x01\x02\x03" > "${location}/binary.dat"
            ;;
        sensitive)
            # Create file with sensitive-looking content
            cat > "${location}/config.env" << 'EOF'
DATABASE_PASSWORD=test123
API_KEY=sk-1234567890abcdef
SECRET_TOKEN=super_secret_value
EOF
            ;;
        conflict)
            # Create file designed to cause conflicts
            cat > "${location}/conflict.txt" << 'EOF'
Line 1: This line will remain unchanged
Line 2: This line will be modified differently
Line 3: This line will cause a conflict
Line 4: This line will remain unchanged
EOF
            ;;
    esac
}

# Simulate network conditions (with safety guards)
setup_network_simulation() {
    local latency="${1:-0}"
    local packet_loss="${2:-0}"
    
    # Only enable in non-CI environments with explicit permission
    if [[ "$CI_MODE" == "true" ]] || [[ -z "${ALLOW_NETWORK_SIMULATION:-}" ]]; then
        print_warning "Network simulation disabled in CI or without permission"
        return 0
    fi
    
    print_info "Setting up network simulation (latency: ${latency}ms, loss: ${packet_loss}%)"
    
    NETWORK_SIMULATION[enabled]=true
    NETWORK_SIMULATION[latency_ms]=$latency
    NETWORK_SIMULATION[packet_loss]=$packet_loss
    
    # Platform-specific network simulation
    if [[ "$(uname -s)" == "Darwin" ]]; then
        # macOS: Use dnctl/pfctl for network simulation
        # This requires sudo, so we'll skip in most cases
        print_warning "Network simulation on macOS requires sudo privileges"
    elif [[ "$(uname -s)" == "Linux" ]]; then
        # Linux: Use tc (traffic control) for local testing only
        # This also requires elevated privileges
        print_warning "Network simulation on Linux requires elevated privileges"
    fi
    
    # For safety, we'll use application-level delays instead
    export GIT_TEST_LATENCY_MS=$latency
    export GIT_TEST_PACKET_LOSS=$packet_loss
    
    return 0
}

# Remove network simulation
remove_network_simulation() {
    if [[ "${NETWORK_SIMULATION[enabled]}" != "true" ]]; then
        return 0
    fi
    
    print_debug "Removing network simulation"
    
    # Clear environment variables
    unset GIT_TEST_LATENCY_MS
    unset GIT_TEST_PACKET_LOSS
    
    NETWORK_SIMULATION[enabled]=false
    return 0
}

# Monitor resource usage during test
monitor_test_resources() {
    local test_name="$1"
    local pid="${2:-$$}"
    local log_file="${INTEGRATION_ENV[test_dir]}/resource-usage.log"
    
    (
        echo "Timestamp,CPU%,Memory(KB),Files" > "$log_file"
        
        while kill -0 "$pid" 2>/dev/null; do
            local timestamp=$(date +%s)
            local cpu_usage=$(ps -p "$pid" -o %cpu= 2>/dev/null || echo "0")
            local mem_usage=$(ps -p "$pid" -o rss= 2>/dev/null || echo "0")
            local open_files=$(lsof -p "$pid" 2>/dev/null | wc -l || echo "0")
            
            echo "$timestamp,$cpu_usage,$mem_usage,$open_files" >> "$log_file"
            sleep 1
        done
    ) &
    
    echo $!
}

# Clean up test processes
cleanup_test_processes() {
    local test_name="$1"
    
    # Find and kill any processes related to this test
    local test_pids=$(ps aux | grep "$SAFE_TEST_PREFIX$test_name" | grep -v grep | awk '{print $2}')
    
    if [[ -n "$test_pids" ]]; then
        print_debug "Cleaning up test processes: $test_pids"
        echo "$test_pids" | xargs kill -TERM 2>/dev/null || true
        sleep 1
        echo "$test_pids" | xargs kill -KILL 2>/dev/null || true
    fi
}

# Create git repository snapshot
create_repository_snapshot() {
    local repo_dir="$1"
    local snapshot_name="$2"
    local snapshot_dir="${INTEGRATION_ENV[test_dir]}/snapshots"
    
    mkdir -p "$snapshot_dir"
    
    # Create snapshot using git bundle
    (
        cd "$repo_dir"
        git bundle create "${snapshot_dir}/${snapshot_name}.bundle" --all
        
        # Save repository state
        cat > "${snapshot_dir}/${snapshot_name}.state" << EOF
Branch: $(git branch --show-current)
Last Commit: $(git log -1 --oneline)
Status: $(git status --porcelain | wc -l) changes
Remotes: $(git remote -v | head -1)
EOF
    )
}

# Restore git repository from snapshot
restore_repository_snapshot() {
    local repo_dir="$1"
    local snapshot_name="$2"
    local snapshot_dir="${INTEGRATION_ENV[test_dir]}/snapshots"
    local bundle_file="${snapshot_dir}/${snapshot_name}.bundle"
    
    if [[ ! -f "$bundle_file" ]]; then
        print_error "Snapshot not found: $snapshot_name"
        return 1
    fi
    
    # Clean and restore
    rm -rf "$repo_dir"
    mkdir -p "$repo_dir"
    
    (
        cd "$repo_dir"
        git init
        git pull "$bundle_file"
    )
}

# Validate repository state
validate_repository_state() {
    local repo_dir="${1:-${INTEGRATION_ENV[repo_dir]}}"
    local expected_branch="${2:-main}"
    
    if [[ ! -d "$repo_dir/.git" ]]; then
        print_error "Not a git repository: $repo_dir"
        return 1
    fi
    
    (
        cd "$repo_dir"
        
        # Check repository health
        if ! git fsck --full 2>/dev/null; then
            print_error "Repository corruption detected"
            return 1
        fi
        
        # Check current branch
        local current_branch=$(git branch --show-current)
        if [[ "$current_branch" != "$expected_branch" ]]; then
            print_warning "Unexpected branch: $current_branch (expected: $expected_branch)"
        fi
        
        # Check for uncommitted changes
        if [[ -n "$(git status --porcelain)" ]]; then
            print_warning "Uncommitted changes detected"
        fi
        
        return 0
    )
}

# Export functions for use in tests
export -f setup_integration_environment cleanup_integration_environment
export -f setup_basic_repository setup_standard_repository setup_monorepo_structure
export -f setup_multi_user_environment add_claude_flow_config create_test_files
export -f setup_network_simulation remove_network_simulation
export -f monitor_test_resources cleanup_test_processes
export -f create_repository_snapshot restore_repository_snapshot
export -f validate_repository_state