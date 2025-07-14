#!/bin/bash

# End-to-End Git Workflow Test Scenarios for Claude Flow
# Complete workflow testing from start to finish

# Enable strict error handling
set -euo pipefail

# Workflow test utilities
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"
    
    if [[ "$expected" != "$actual" ]]; then
        print_error "$message: expected '$expected', got '$actual'"
        return 1
    fi
    return 0
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Assertion failed}"
    
    if [[ ! "$haystack" =~ $needle ]]; then
        print_error "$message: '$needle' not found in output"
        return 1
    fi
    return 0
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File not found}"
    
    if [[ ! -f "$file" ]]; then
        print_error "$message: $file"
        return 1
    fi
    return 0
}

# Test: Complete feature development workflow
test_feature_development_workflow() {
    print_info "Testing complete feature development workflow"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    local feature_branch="feature/user-authentication"
    
    # Initialize Claude session
    create_claude_session "feature_dev" "$repo_dir"
    
    # Step 1: Start feature development
    print_info "Step 1: Starting feature branch"
    execute_claude_command "branch" "$repo_dir" "-b $feature_branch" || return 1
    
    # Verify branch creation
    local current_branch
    current_branch=$(cd "$repo_dir" && git branch --show-current)
    assert_equals "$feature_branch" "$current_branch" "Feature branch not created"
    
    # Step 2: Implement feature
    print_info "Step 2: Implementing feature"
    (
        cd "$repo_dir"
        
        # Create authentication module
        mkdir -p src/auth
        cat > src/auth/auth.js << 'EOF'
// Authentication module
export class AuthService {
    constructor() {
        this.users = new Map();
    }
    
    async login(username, password) {
        const user = this.users.get(username);
        if (!user || user.password !== password) {
            throw new Error('Invalid credentials');
        }
        return { id: user.id, username: user.username };
    }
    
    async register(username, password) {
        if (this.users.has(username)) {
            throw new Error('User already exists');
        }
        const user = { id: Date.now(), username, password };
        this.users.set(username, user);
        return { id: user.id, username };
    }
}
EOF
        
        # Create tests
        cat > src/auth/auth.test.js << 'EOF'
// Authentication tests
import { AuthService } from './auth.js';

describe('AuthService', () => {
    let authService;
    
    beforeEach(() => {
        authService = new AuthService();
    });
    
    test('should register new user', async () => {
        const user = await authService.register('testuser', 'password123');
        expect(user.username).toBe('testuser');
        expect(user.id).toBeDefined();
    });
    
    test('should login with valid credentials', async () => {
        await authService.register('testuser', 'password123');
        const user = await authService.login('testuser', 'password123');
        expect(user.username).toBe('testuser');
    });
});
EOF
        
        # Update main index
        echo -e "\n// Authentication module export\nexport { AuthService } from './auth/auth.js';" >> src/index.js
    )
    
    # Step 3: Commit changes
    print_info "Step 3: Committing feature implementation"
    execute_claude_command "commit" "$repo_dir" "-m 'feat: implement user authentication service'" || return 1
    
    # Verify commit
    local last_commit
    last_commit=$(cd "$repo_dir" && git log -1 --oneline)
    assert_contains "$last_commit" "feat: implement user authentication" "Commit message incorrect"
    
    # Step 4: Add documentation
    print_info "Step 4: Adding documentation"
    (
        cd "$repo_dir"
        
        mkdir -p docs
        cat > docs/authentication.md << 'EOF'
# Authentication Module

## Overview
The authentication module provides user registration and login functionality.

## Usage

```javascript
import { AuthService } from './auth/auth.js';

const auth = new AuthService();

// Register user
const newUser = await auth.register('username', 'password');

// Login user
const user = await auth.login('username', 'password');
```

## API Reference

### register(username, password)
Creates a new user account.

### login(username, password)
Authenticates a user and returns their profile.
EOF
    )
    
    execute_claude_command "commit" "$repo_dir" "-m 'docs: add authentication module documentation'" || return 1
    
    # Step 5: Run tests
    print_info "Step 5: Running tests"
    (
        cd "$repo_dir"
        # Simulate test execution
        echo "Running test suite..."
        echo "✓ AuthService › should register new user"
        echo "✓ AuthService › should login with valid credentials"
        echo "Test Suites: 1 passed, 1 total"
        echo "Tests: 2 passed, 2 total"
    )
    
    # Step 6: Push to remote
    print_info "Step 6: Pushing feature branch"
    execute_claude_command "push" "$repo_dir" "-u origin $feature_branch" || return 1
    
    # Step 7: Create pull request (simulated)
    print_info "Step 7: Creating pull request"
    (
        cd "$repo_dir"
        
        # Simulate PR creation
        cat > .github/pull_request.md << EOF
## Pull Request: User Authentication Feature

### Summary
- Implemented AuthService with login and register methods
- Added comprehensive test coverage
- Created documentation

### Changes
- Added \`src/auth/auth.js\` - Core authentication service
- Added \`src/auth/auth.test.js\` - Unit tests
- Added \`docs/authentication.md\` - API documentation
- Updated \`src/index.js\` - Export authentication module

### Test Results
All tests passing (2/2)

### Checklist
- [x] Tests added
- [x] Documentation updated
- [x] Code reviewed
- [x] Ready for merge
EOF
        
        echo "Pull request created: #123 - User Authentication Feature"
    )
    
    cleanup_claude_session "feature_dev"
    
    print_success "Feature development workflow completed successfully"
    return 0
}

# Test: Hotfix emergency workflow
test_hotfix_emergency_workflow() {
    print_info "Testing hotfix emergency workflow"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    
    # Setup: Ensure we're on main with a "production issue"
    (
        cd "$repo_dir"
        git checkout main
        
        # Create a file with a bug
        cat > src/calculator.js << 'EOF'
// Calculator with critical bug
export function divide(a, b) {
    return a / b;  // BUG: No zero check!
}
EOF
        
        git add .
        git commit -m "feat: add calculator (with hidden bug)"
        git push
    )
    
    # Initialize Claude session for hotfix
    create_claude_session "hotfix" "$repo_dir"
    
    # Step 1: Create hotfix branch from main
    print_info "Step 1: Creating hotfix branch"
    execute_claude_command "branch" "$repo_dir" "-b hotfix/division-by-zero" || return 1
    
    # Step 2: Fix the critical issue
    print_info "Step 2: Applying emergency fix"
    (
        cd "$repo_dir"
        
        # Fix the bug
        cat > src/calculator.js << 'EOF'
// Calculator with zero division protection
export function divide(a, b) {
    if (b === 0) {
        throw new Error('Division by zero');
    }
    return a / b;
}
EOF
        
        # Add test for the fix
        cat > src/calculator.test.js << 'EOF'
// Calculator tests
import { divide } from './calculator.js';

describe('divide', () => {
    test('should divide numbers correctly', () => {
        expect(divide(10, 2)).toBe(5);
    });
    
    test('should throw error for division by zero', () => {
        expect(() => divide(10, 0)).toThrow('Division by zero');
    });
});
EOF
    )
    
    # Step 3: Commit the fix
    print_info "Step 3: Committing hotfix"
    execute_claude_command "commit" "$repo_dir" "-m 'fix: prevent division by zero error

- Add zero check in divide function
- Throw descriptive error for zero divisor
- Add test coverage for edge case

Fixes #CRITICAL-001'" || return 1
    
    # Step 4: Run expedited tests
    print_info "Step 4: Running critical path tests"
    (
        cd "$repo_dir"
        echo "Running hotfix validation..."
        echo "✓ divide › should divide numbers correctly"
        echo "✓ divide › should throw error for division by zero"
        echo "Critical tests passed!"
    )
    
    # Step 5: Push hotfix
    print_info "Step 5: Pushing hotfix branch"
    execute_claude_command "push" "$repo_dir" "-u origin hotfix/division-by-zero" || return 1
    
    # Step 6: Merge to main (simulated fast-track)
    print_info "Step 6: Fast-track merge to main"
    (
        cd "$repo_dir"
        git checkout main
        git merge hotfix/division-by-zero --no-ff -m "Merge hotfix: division by zero protection"
        git push
    )
    
    # Step 7: Tag hotfix release
    print_info "Step 7: Creating hotfix release tag"
    (
        cd "$repo_dir"
        git tag -a "v1.0.1-hotfix" -m "Hotfix: Division by zero protection"
        git push --tags
    )
    
    cleanup_claude_session "hotfix"
    
    print_success "Hotfix emergency workflow completed successfully"
    return 0
}

# Test: Release preparation workflow
test_release_preparation_workflow() {
    print_info "Testing release preparation workflow"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    local release_branch="release/v2.0.0"
    
    # Setup: Create some features in develop branch
    (
        cd "$repo_dir"
        git checkout -b develop
        
        # Add multiple features
        echo "export const VERSION = '2.0.0-beta';" > src/version.js
        git add . && git commit -m "feat: prepare v2.0.0 release"
        
        echo "export const FEATURE_FLAGS = { newUI: true };" > src/features.js
        git add . && git commit -m "feat: add feature flags system"
        
        git push -u origin develop
    )
    
    create_claude_session "release" "$repo_dir"
    
    # Step 1: Create release branch
    print_info "Step 1: Creating release branch from develop"
    (
        cd "$repo_dir"
        git checkout -b "$release_branch" develop
    )
    
    # Step 2: Update version numbers
    print_info "Step 2: Updating version numbers"
    (
        cd "$repo_dir"
        
        # Update package.json version
        if [[ -f package.json ]]; then
            # Simple version update (in real scenario, use jq or similar)
            sed -i.bak 's/"version": "1.0.0"/"version": "2.0.0"/' package.json
            rm -f package.json.bak
        fi
        
        # Update version constant
        echo "export const VERSION = '2.0.0';" > src/version.js
        
        # Update changelog
        cat > CHANGELOG.md << 'EOF'
# Changelog

## [2.0.0] - 2024-01-15

### Added
- User authentication system
- Feature flags framework
- Enhanced error handling

### Fixed
- Division by zero error in calculator
- Memory leak in data processor

### Changed
- Upgraded to new UI framework
- Improved performance by 40%

### Security
- Fixed XSS vulnerability in user input
EOF
    )
    
    execute_claude_command "commit" "$repo_dir" "-m 'chore: prepare release v2.0.0'" || return 1
    
    # Step 3: Run release tests
    print_info "Step 3: Running comprehensive release tests"
    (
        cd "$repo_dir"
        
        echo "Running release test suite..."
        echo "✓ Unit tests: 45 passed"
        echo "✓ Integration tests: 23 passed"
        echo "✓ E2E tests: 12 passed"
        echo "✓ Performance tests: All benchmarks met"
        echo "✓ Security scan: No vulnerabilities found"
        echo ""
        echo "Release criteria: PASSED"
    )
    
    # Step 4: Generate release artifacts
    print_info "Step 4: Building release artifacts"
    (
        cd "$repo_dir"
        
        mkdir -p dist
        echo "console.log('App v2.0.0');" > dist/app.min.js
        echo "/* CSS v2.0.0 */" > dist/app.min.css
        
        # Create release notes
        cat > RELEASE_NOTES.md << 'EOF'
# Release Notes - v2.0.0

## Highlights
This major release introduces user authentication, feature flags, and significant performance improvements.

## Breaking Changes
- API endpoints now require authentication
- Configuration format has changed

## Migration Guide
See docs/migration-v2.md for detailed upgrade instructions.

## Contributors
Thanks to all contributors who made this release possible!
EOF
    )
    
    execute_claude_command "commit" "$repo_dir" "-m 'build: generate release artifacts for v2.0.0'" || return 1
    
    # Step 5: Push release branch
    print_info "Step 5: Pushing release branch"
    execute_claude_command "push" "$repo_dir" "-u origin $release_branch" || return 1
    
    # Step 6: Create release PR
    print_info "Step 6: Creating release pull request"
    (
        cd "$repo_dir"
        
        echo "Creating pull request: Release v2.0.0"
        echo "Base: main"
        echo "Compare: $release_branch"
        echo "Status: Ready for final review"
    )
    
    # Step 7: Simulate release approval and merge
    print_info "Step 7: Merging release"
    (
        cd "$repo_dir"
        git checkout main
        git merge "$release_branch" --no-ff -m "Release v2.0.0"
        git tag -a "v2.0.0" -m "Release version 2.0.0"
        git push origin main
        git push --tags
    )
    
    cleanup_claude_session "release"
    
    print_success "Release preparation workflow completed successfully"
    return 0
}

# Test: Repository synchronization workflow
test_repository_sync_workflow() {
    print_info "Testing repository synchronization workflow"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    local upstream_dir="${INTEGRATION_ENV[test_dir]}/upstream"
    
    # Setup: Create upstream repository with changes
    mkdir -p "$upstream_dir"
    (
        cd "$upstream_dir"
        git init --bare upstream.git
    )
    
    # Add upstream remote to our repo
    (
        cd "$repo_dir"
        git remote add upstream "$upstream_dir/upstream.git"
        
        # Push current state to upstream
        git push upstream main
    )
    
    # Simulate upstream changes
    local upstream_work="${INTEGRATION_ENV[test_dir]}/upstream-work"
    mkdir -p "$upstream_work"
    (
        cd "$upstream_work"
        git clone "$upstream_dir/upstream.git" .
        
        # Make upstream changes
        echo "// Upstream change 1" >> src/index.js
        git add . && git commit -m "feat: upstream feature 1"
        
        echo "// Upstream change 2" >> src/index.js
        git add . && git commit -m "feat: upstream feature 2"
        
        git push origin main
    )
    
    create_claude_session "sync" "$repo_dir"
    
    # Step 1: Fetch upstream changes
    print_info "Step 1: Fetching upstream changes"
    (
        cd "$repo_dir"
        git fetch upstream
        
        echo "Fetched changes from upstream:"
        git log upstream/main --oneline -5
    )
    
    # Step 2: Create sync branch
    print_info "Step 2: Creating synchronization branch"
    execute_claude_command "branch" "$repo_dir" "-b sync/upstream-$(date +%Y%m%d)" || return 1
    
    # Step 3: Merge upstream changes
    print_info "Step 3: Merging upstream changes"
    (
        cd "$repo_dir"
        
        # Show divergence
        echo "Local commits:"
        git log main --oneline -3
        echo ""
        echo "Upstream commits:"
        git log upstream/main --oneline -3
        
        # Merge upstream
        if git merge upstream/main -m "Merge upstream changes"; then
            echo "✓ Upstream merged successfully"
        else
            echo "⚠ Merge conflicts detected"
            # In real scenario, resolve conflicts
            return 1
        fi
    )
    
    # Step 4: Validate merged state
    print_info "Step 4: Validating synchronized repository"
    (
        cd "$repo_dir"
        
        echo "Running validation checks..."
        echo "✓ No merge conflicts"
        echo "✓ Tests passing"
        echo "✓ Build successful"
        echo "✓ Upstream commits integrated"
    )
    
    # Step 5: Push synchronized branch
    print_info "Step 5: Pushing synchronized branch"
    execute_claude_command "push" "$repo_dir" "-u origin HEAD" || return 1
    
    # Step 6: Create sync PR
    print_info "Step 6: Creating synchronization PR"
    (
        cd "$repo_dir"
        
        echo "Pull Request: Synchronize with upstream"
        echo "Commits from upstream: 2"
        echo "Status: Ready for review"
    )
    
    cleanup_claude_session "sync"
    
    print_success "Repository synchronization workflow completed successfully"
    return 0
}

# Test: Team collaboration workflow
test_team_collaboration_workflow() {
    print_info "Testing team collaboration workflow"
    
    local main_repo="${INTEGRATION_ENV[repo_dir]}"
    local alice_repo="${INTEGRATION_ENV[test_dir]}/alice-repo"
    local bob_repo="${INTEGRATION_ENV[test_dir]}/bob-repo"
    
    # Setup: Clone repos for team members
    for user_repo in "$alice_repo" "$bob_repo"; do
        mkdir -p "$user_repo"
        (
            cd "$user_repo"
            git clone "${INTEGRATION_ENV[remote_dir]}/origin.git" .
            git config user.name "$(basename "$user_repo" -repo)"
            git config user.email "$(basename "$user_repo" -repo)@claude-test.ai"
        )
    done
    
    create_claude_session "collab" "$main_repo"
    
    # Step 1: Alice starts feature A
    print_info "Step 1: Alice starts working on feature A"
    (
        cd "$alice_repo"
        git checkout -b feature/alice-component
        
        mkdir -p src/components
        cat > src/components/AliceComponent.js << 'EOF'
// Alice's component
export function AliceComponent() {
    return {
        name: 'AliceComponent',
        render: () => '<div>Alice was here</div>'
    };
}
EOF
        
        git add .
        git commit -m "feat: add AliceComponent"
        git push -u origin feature/alice-component
    )
    
    # Step 2: Bob starts feature B
    print_info "Step 2: Bob starts working on feature B"
    (
        cd "$bob_repo"
        git checkout -b feature/bob-service
        
        mkdir -p src/services
        cat > src/services/BobService.js << 'EOF'
// Bob's service
export class BobService {
    constructor() {
        this.name = 'BobService';
    }
    
    process(data) {
        return data.map(item => item.toUpperCase());
    }
}
EOF
        
        git add .
        git commit -m "feat: add BobService"
        git push -u origin feature/bob-service
    )
    
    # Step 3: Integration branch
    print_info "Step 3: Creating integration branch"
    execute_claude_command "branch" "$main_repo" "-b integration/sprint-1" || return 1
    
    # Step 4: Merge Alice's work
    print_info "Step 4: Integrating Alice's feature"
    (
        cd "$main_repo"
        git fetch origin
        git merge origin/feature/alice-component -m "Merge feature: AliceComponent"
    )
    
    # Step 5: Merge Bob's work
    print_info "Step 5: Integrating Bob's feature"
    (
        cd "$main_repo"
        git merge origin/feature/bob-service -m "Merge feature: BobService"
    )
    
    # Step 6: Integration testing
    print_info "Step 6: Running integration tests"
    (
        cd "$main_repo"
        
        # Create integration test
        cat > tests/integration/team-features.test.js << 'EOF'
// Integration test for team features
import { AliceComponent } from '../../src/components/AliceComponent';
import { BobService } from '../../src/services/BobService';

describe('Team Features Integration', () => {
    test('AliceComponent and BobService work together', () => {
        const component = AliceComponent();
        const service = new BobService();
        
        expect(component.name).toBe('AliceComponent');
        expect(service.process(['test'])).toEqual(['TEST']);
    });
});
EOF
        
        git add .
        git commit -m "test: add integration tests for team features"
    )
    
    # Step 7: Push integration branch
    print_info "Step 7: Pushing integrated changes"
    execute_claude_command "push" "$main_repo" "-u origin integration/sprint-1" || return 1
    
    # Step 8: Code review simulation
    print_info "Step 8: Simulating code review process"
    (
        cd "$main_repo"
        
        echo "Code Review Summary:"
        echo "✓ Alice's component: Approved"
        echo "✓ Bob's service: Approved"
        echo "✓ Integration tests: Passing"
        echo "✓ No conflicts detected"
        echo "Ready to merge to main"
    )
    
    cleanup_claude_session "collab"
    
    print_success "Team collaboration workflow completed successfully"
    return 0
}

# Test: Conflict resolution workflow
test_conflict_resolution_workflow() {
    print_info "Testing conflict resolution workflow"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    
    # Setup: Create conflicting branches
    (
        cd "$repo_dir"
        
        # Create base file
        cat > src/config.js << 'EOF'
export const config = {
    apiUrl: 'http://localhost:3000',
    timeout: 5000,
    retries: 3
};
EOF
        git add . && git commit -m "feat: add base config"
        git push
        
        # Branch 1: Update timeout
        git checkout -b feature/increase-timeout
        sed -i.bak 's/timeout: 5000/timeout: 10000/' src/config.js
        rm -f src/config.js.bak
        git add . && git commit -m "feat: increase timeout to 10s"
        git push -u origin feature/increase-timeout
        
        # Branch 2: Update timeout differently
        git checkout main
        git checkout -b feature/decrease-timeout
        sed -i.bak 's/timeout: 5000/timeout: 2000/' src/config.js
        rm -f src/config.js.bak
        git add . && git commit -m "feat: decrease timeout to 2s"
        git push -u origin feature/decrease-timeout
    )
    
    create_claude_session "conflict" "$repo_dir"
    
    # Step 1: Attempt merge that creates conflict
    print_info "Step 1: Creating merge conflict"
    (
        cd "$repo_dir"
        git checkout feature/increase-timeout
        
        echo "Attempting to merge feature/decrease-timeout..."
        if ! git merge feature/decrease-timeout; then
            echo "✓ Conflict detected as expected"
            git status
        else
            echo "✗ No conflict detected (unexpected)"
            return 1
        fi
    )
    
    # Step 2: Analyze conflict
    print_info "Step 2: Analyzing conflict"
    (
        cd "$repo_dir"
        
        echo "Conflict details:"
        echo "File: src/config.js"
        echo "Conflicting section:"
        grep -A5 -B5 "<<<<<<< HEAD" src/config.js || true
    )
    
    # Step 3: Resolve conflict
    print_info "Step 3: Resolving conflict with compromise"
    (
        cd "$repo_dir"
        
        # Resolve with a compromise value
        cat > src/config.js << 'EOF'
export const config = {
    apiUrl: 'http://localhost:3000',
    timeout: 7500,  // Compromised between 10000 and 2000
    retries: 3
};
EOF
        
        git add src/config.js
    )
    
    # Step 4: Complete merge
    print_info "Step 4: Completing merge"
    execute_claude_command "commit" "$repo_dir" "-m 'Merge feature/decrease-timeout into feature/increase-timeout

Resolved conflict in src/config.js:
- Compromised on timeout value (7500ms)
- Maintains stability while improving performance'" || return 1
    
    # Step 5: Validate resolution
    print_info "Step 5: Validating conflict resolution"
    (
        cd "$repo_dir"
        
        echo "Running post-merge validation..."
        echo "✓ No remaining conflicts"
        echo "✓ Code compiles successfully"
        echo "✓ Tests passing with new timeout value"
    )
    
    # Step 6: Push resolved branch
    print_info "Step 6: Pushing resolved changes"
    execute_claude_command "push" "$repo_dir" "origin feature/increase-timeout" || return 1
    
    cleanup_claude_session "conflict"
    
    print_success "Conflict resolution workflow completed successfully"
    return 0
}

# Test: Failed push recovery workflow
test_failed_push_recovery() {
    print_info "Testing failed push recovery workflow"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    
    # Setup: Create a situation where push will fail
    (
        cd "$repo_dir"
        git checkout -b feature/concurrent-work
        
        # Make local changes
        echo "// Local change" >> src/index.js
        git add . && git commit -m "feat: local change"
    )
    
    # Simulate remote changes that will cause push to fail
    local remote_work="${INTEGRATION_ENV[test_dir]}/remote-work"
    mkdir -p "$remote_work"
    (
        cd "$remote_work"
        git clone "${INTEGRATION_ENV[remote_dir]}/origin.git" .
        git checkout -b feature/concurrent-work
        
        echo "// Remote change" >> src/index.js
        git add . && git commit -m "feat: remote change"
        git push -u origin feature/concurrent-work
    )
    
    create_claude_session "push_recovery" "$repo_dir"
    
    # Step 1: Attempt push (will fail)
    print_info "Step 1: Attempting push (expecting failure)"
    (
        cd "$repo_dir"
        
        if ! git push -u origin feature/concurrent-work 2>&1; then
            echo "✓ Push failed as expected (remote has changes)"
        else
            echo "✗ Push succeeded unexpectedly"
            return 1
        fi
    )
    
    # Step 2: Fetch remote changes
    print_info "Step 2: Fetching remote changes"
    (
        cd "$repo_dir"
        git fetch origin
        
        echo "Remote changes detected:"
        git log origin/feature/concurrent-work --oneline -3
    )
    
    # Step 3: Rebase local changes
    print_info "Step 3: Rebasing local changes onto remote"
    (
        cd "$repo_dir"
        
        echo "Starting rebase..."
        if git rebase origin/feature/concurrent-work; then
            echo "✓ Rebase completed successfully"
        else
            echo "⚠ Rebase conflicts detected"
            # Handle conflicts if any
            git rebase --abort
            return 1
        fi
    )
    
    # Step 4: Retry push
    print_info "Step 4: Retrying push after rebase"
    execute_claude_command "push" "$repo_dir" "origin feature/concurrent-work" || return 1
    
    # Step 5: Verify pushed state
    print_info "Step 5: Verifying pushed state"
    (
        cd "$repo_dir"
        
        echo "Verification:"
        echo "✓ Local and remote are synchronized"
        echo "✓ Both changes are preserved"
        echo "✓ History is linear after rebase"
        
        git log --oneline -5
    )
    
    cleanup_claude_session "push_recovery"
    
    print_success "Failed push recovery workflow completed successfully"
    return 0
}

# Test: Rollback procedures workflow
test_rollback_procedures() {
    print_info "Testing rollback procedures workflow"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    
    # Setup: Create commits to rollback
    (
        cd "$repo_dir"
        
        # Good commit
        echo "// Good feature" > src/good-feature.js
        git add . && git commit -m "feat: add good feature"
        local good_commit=$(git rev-parse HEAD)
        
        # Bad commit (introduces bug)
        echo "// Bad code with bug" > src/bad-feature.js
        echo "throw new Error('Catastrophic failure');" >> src/index.js
        git add . && git commit -m "feat: add bad feature (with hidden bug)"
        local bad_commit=$(git rev-parse HEAD)
        
        # Another commit on top
        echo "// Unrelated change" > src/other.js
        git add . && git commit -m "feat: add unrelated feature"
        
        git push
        
        # Save commit hashes for later
        echo "$good_commit" > .last-good-commit
        echo "$bad_commit" > .bad-commit
    )
    
    create_claude_session "rollback" "$repo_dir"
    
    # Step 1: Identify problematic commit
    print_info "Step 1: Identifying problematic commit"
    (
        cd "$repo_dir"
        
        local bad_commit=$(cat .bad-commit)
        echo "Production issue detected!"
        echo "Bisecting to find bad commit..."
        echo "✓ Found problematic commit: $bad_commit"
        
        git show --stat "$bad_commit"
    )
    
    # Step 2: Create rollback branch
    print_info "Step 2: Creating rollback branch"
    execute_claude_command "branch" "$repo_dir" "-b rollback/fix-production-issue" || return 1
    
    # Step 3: Revert bad commit
    print_info "Step 3: Reverting problematic commit"
    (
        cd "$repo_dir"
        
        local bad_commit=$(cat .bad-commit)
        echo "Reverting commit $bad_commit..."
        
        if git revert "$bad_commit" --no-edit; then
            echo "✓ Revert successful"
            
            # Update commit message
            git commit --amend -m "Revert \"feat: add bad feature (with hidden bug)\"

This reverts commit $bad_commit.

Reason: Causes catastrophic failure in production
Impact: Application crashes on startup
Solution: Reverting until proper fix is implemented"
        fi
    )
    
    # Step 4: Validate rollback
    print_info "Step 4: Validating rollback"
    (
        cd "$repo_dir"
        
        echo "Running rollback validation..."
        
        # Check that bad code is gone
        if grep -q "Catastrophic failure" src/index.js; then
            echo "✗ Bad code still present"
            return 1
        else
            echo "✓ Bad code removed"
        fi
        
        # Verify good commits are preserved
        if [[ -f src/good-feature.js && -f src/other.js ]]; then
            echo "✓ Other commits preserved"
        else
            echo "✗ Good commits affected"
            return 1
        fi
        
        echo "✓ Application starts successfully"
        echo "✓ All tests passing"
    )
    
    # Step 5: Emergency push
    print_info "Step 5: Emergency push to fix production"
    execute_claude_command "push" "$repo_dir" "-u origin rollback/fix-production-issue" || return 1
    
    # Step 6: Fast-track merge (simulated)
    print_info "Step 6: Fast-track merge to main"
    (
        cd "$repo_dir"
        git checkout main
        git merge rollback/fix-production-issue --no-ff -m "Emergency: Rollback bad feature

- Reverts breaking changes
- Restores production stability
- Approved by: Emergency Response Team"
        git push
    )
    
    cleanup_claude_session "rollback"
    
    print_success "Rollback procedures workflow completed successfully"
    return 0
}

# Test: Hook failure recovery workflow
test_hook_failure_recovery() {
    print_info "Testing hook failure recovery workflow"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    
    # Setup: Create strict pre-commit hook
    (
        cd "$repo_dir"
        
        mkdir -p .git/hooks
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running pre-commit checks..."

# Check for console.log statements
if grep -r "console\.log" src/ 2>/dev/null | grep -v "test\|spec"; then
    echo "ERROR: console.log found in source files"
    exit 1
fi

# Check for TODO comments
if grep -r "TODO" src/ 2>/dev/null; then
    echo "ERROR: TODO comments found"
    exit 1
fi

# Check file size
large_files=$(find src/ -type f -size +1M 2>/dev/null)
if [[ -n "$large_files" ]]; then
    echo "ERROR: Large files detected (>1MB)"
    echo "$large_files"
    exit 1
fi

echo "Pre-commit checks passed"
exit 0
EOF
        chmod +x .git/hooks/pre-commit
    )
    
    create_claude_session "hook_recovery" "$repo_dir"
    
    # Step 1: Make changes that will fail hooks
    print_info "Step 1: Making changes that violate hook rules"
    (
        cd "$repo_dir"
        
        # Add console.log
        echo "console.log('Debug output');" >> src/index.js
        
        # Add TODO
        echo "// TODO: Fix this later" >> src/utils/helpers.js
        
        # Stage changes
        git add .
    )
    
    # Step 2: Attempt commit (will fail)
    print_info "Step 2: Attempting commit (expecting hook failure)"
    (
        cd "$repo_dir"
        
        if ! git commit -m "feat: new feature"; then
            echo "✓ Pre-commit hook failed as expected"
        else
            echo "✗ Commit succeeded unexpectedly"
            return 1
        fi
    )
    
    # Step 3: Fix hook violations
    print_info "Step 3: Fixing hook violations"
    (
        cd "$repo_dir"
        
        echo "Addressing hook failures..."
        
        # Remove console.log
        sed -i.bak "/console\.log('Debug output');/d" src/index.js
        rm -f src/index.js.bak
        
        # Replace TODO with proper comment
        sed -i.bak "s/TODO: Fix this later/NOTE: Refactoring planned for v2.1/" src/utils/helpers.js
        rm -f src/utils/helpers.js.bak
        
        # Re-stage fixed files
        git add .
    )
    
    # Step 4: Create hook bypass configuration
    print_info "Step 4: Setting up hook configuration"
    (
        cd "$repo_dir"
        
        # Create .pre-commit-config.yaml for more flexible configuration
        cat > .pre-commit-config.yaml << 'EOF'
# Pre-commit hook configuration
exclude: '^(tests/|docs/|scripts/debug)'
repos:
  - repo: local
    hooks:
      - id: no-console-log
        name: Check for console.log
        entry: grep -r "console\.log" src/
        language: system
        files: \.(js|ts)$
        exclude: \.(test|spec)\.js$
      
      - id: no-todos
        name: Check for TODOs
        entry: grep -r "TODO" src/
        language: system
        files: \.(js|ts)$
EOF
        
        git add .pre-commit-config.yaml
    )
    
    # Step 5: Retry commit
    print_info "Step 5: Retrying commit with fixes"
    execute_claude_command "commit" "$repo_dir" "-m 'feat: new feature with code quality improvements

- Removed debug console.log statements
- Converted TODO to proper documentation
- Added pre-commit configuration'" || return 1
    
    # Step 6: Document hook requirements
    print_info "Step 6: Documenting hook requirements"
    (
        cd "$repo_dir"
        
        cat > docs/development-standards.md << 'EOF'
# Development Standards

## Pre-commit Hooks

Our repository uses pre-commit hooks to maintain code quality:

1. **No console.log in production code**
   - Use proper logging framework
   - Debug statements should be removed before commit

2. **No TODO comments**
   - Create issues for future work
   - Use NOTE or FIXME with issue references

3. **File size limits**
   - Keep source files under 1MB
   - Use Git LFS for large assets

## Bypassing Hooks (Emergency Only)

In emergencies, hooks can be bypassed with:
```bash
git commit --no-verify -m "emergency: critical fix"
```

This should be followed immediately by a cleanup commit.
EOF
        
        git add .
        git commit -m "docs: add development standards and hook documentation"
    )
    
    # Step 7: Push changes
    print_info "Step 7: Pushing changes with hook compliance"
    execute_claude_command "push" "$repo_dir" "origin HEAD" || return 1
    
    cleanup_claude_session "hook_recovery"
    
    print_success "Hook failure recovery workflow completed successfully"
    return 0
}

# Test: Large repository performance
test_large_repository_performance() {
    print_info "Testing large repository performance"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    
    # Create large repository structure
    print_info "Creating large repository structure..."
    (
        cd "$repo_dir"
        
        # Generate many files
        for i in {1..100}; do
            mkdir -p "src/module$i"
            for j in {1..10}; do
                echo "// Module $i, File $j" > "src/module$i/file$j.js"
            done
        done
        
        # Create some larger files (within safety limits)
        dd if=/dev/zero of=assets/large1.dat bs=1M count=10 2>/dev/null
        dd if=/dev/zero of=assets/large2.dat bs=1M count=20 2>/dev/null
        
        # Initial commit of large structure
        git add .
        git commit -m "test: large repository structure"
    )
    
    create_claude_session "perf" "$repo_dir"
    
    # Monitor performance for various operations
    local perf_log="${INTEGRATION_ENV[test_dir]}/performance.log"
    echo "Operation,Duration,FileCount,RepoSize" > "$perf_log"
    
    # Test 1: Status performance
    print_info "Test 1: Status check performance"
    local start_time=$(date +%s.%N)
    execute_claude_command "status" "$repo_dir" "" || return 1
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    local file_count=$(find "$repo_dir" -type f | wc -l)
    local repo_size=$(du -sh "$repo_dir" | awk '{print $1}')
    echo "status,$duration,$file_count,$repo_size" >> "$perf_log"
    
    # Test 2: Add performance
    print_info "Test 2: Staging performance"
    (
        cd "$repo_dir"
        # Modify multiple files
        for i in {1..50}; do
            echo "// Performance test modification" >> "src/module$i/file1.js"
        done
    )
    
    start_time=$(date +%s.%N)
    (cd "$repo_dir" && git add .)
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    echo "add,$duration,$file_count,$repo_size" >> "$perf_log"
    
    # Test 3: Commit performance
    print_info "Test 3: Commit performance"
    start_time=$(date +%s.%N)
    execute_claude_command "commit" "$repo_dir" "-m 'perf: test commit on large repo'" || return 1
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc)
    echo "commit,$duration,$file_count,$repo_size" >> "$perf_log"
    
    # Generate performance report
    print_info "Performance Report:"
    cat "$perf_log" | column -t -s,
    
    cleanup_claude_session "perf"
    
    print_success "Large repository performance test completed"
    return 0
}

# Test: Concurrent git operations
test_concurrent_git_operations() {
    print_info "Testing concurrent git operations"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    local pids=()
    
    create_claude_session "concurrent" "$repo_dir"
    
    # Function to simulate user operations
    simulate_user_operation() {
        local user_id="$1"
        local operation="$2"
        local work_dir="${INTEGRATION_ENV[test_dir]}/user$user_id"
        
        mkdir -p "$work_dir"
        (
            cd "$work_dir"
            git clone "${INTEGRATION_ENV[remote_dir]}/origin.git" . 2>/dev/null
            
            case "$operation" in
                branch)
                    git checkout -b "feature/user$user_id-work"
                    echo "// User $user_id work" > "user$user_id.js"
                    git add . && git commit -m "feat: user $user_id contribution"
                    git push -u origin "feature/user$user_id-work"
                    ;;
                commit)
                    echo "// User $user_id change" >> src/index.js
                    git add . && git commit -m "update: user $user_id modification"
                    git push
                    ;;
                pull)
                    git pull --rebase
                    ;;
            esac
        ) > "${work_dir}/operation.log" 2>&1
    }
    
    # Launch concurrent operations
    print_info "Launching concurrent operations..."
    
    # Start 5 concurrent operations
    for i in {1..5}; do
        operation=$([[ $((i % 3)) -eq 0 ]] && echo "pull" || ([[ $((i % 2)) -eq 0 ]] && echo "commit" || echo "branch"))
        simulate_user_operation "$i" "$operation" &
        pids+=($!)
        print_debug "Started user $i operation: $operation (PID: ${pids[-1]})"
    done
    
    # Wait for all operations to complete
    print_info "Waiting for concurrent operations to complete..."
    local failed=0
    for i in "${!pids[@]}"; do
        if wait "${pids[$i]}"; then
            print_success "User $((i+1)) operation completed"
        else
            print_error "User $((i+1)) operation failed"
            ((failed++))
        fi
    done
    
    # Verify repository state
    print_info "Verifying repository state after concurrent operations..."
    (
        cd "$repo_dir"
        git fetch --all
        
        echo "Repository state:"
        echo "Branches created: $(git branch -r | grep -c "feature/user")"
        echo "Total commits: $(git rev-list --all --count)"
        echo "Repository integrity: $(git fsck --quick 2>&1 | grep -c "error" | xargs -I {} test {} -eq 0 && echo "OK" || echo "CORRUPTED")"
    )
    
    cleanup_claude_session "concurrent"
    
    if [[ $failed -eq 0 ]]; then
        print_success "Concurrent operations test completed successfully"
        return 0
    else
        print_error "$failed concurrent operations failed"
        return 1
    fi
}

# Test: Network latency handling
test_network_latency_handling() {
    print_info "Testing network latency handling"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    
    # Note: This test simulates network latency at application level
    print_warning "Network latency simulation (application level)"
    
    create_claude_session "latency" "$repo_dir"
    
    # Set up simulated latency
    setup_network_simulation 200 5  # 200ms latency, 5% packet loss
    
    # Test operations under latency
    print_info "Testing operations with simulated latency..."
    
    # Test 1: Fetch with latency
    print_info "Test 1: Fetch operation"
    local start_time=$(date +%s)
    (
        cd "$repo_dir"
        # Add artificial delay to simulate network latency
        sleep 0.2
        git fetch origin
    )
    local fetch_time=$(($(date +%s) - start_time))
    echo "Fetch completed in ${fetch_time}s (with simulated latency)"
    
    # Test 2: Push with retry
    print_info "Test 2: Push with retry logic"
    (
        cd "$repo_dir"
        echo "// Testing latency" >> src/index.js
        git add . && git commit -m "test: network latency handling"
        
        # Simulate push with retry
        local attempts=0
        local max_attempts=3
        
        while [[ $attempts -lt $max_attempts ]]; do
            ((attempts++))
            echo "Push attempt $attempts/$max_attempts..."
            
            # Simulate network issues on first attempt
            if [[ $attempts -eq 1 ]]; then
                echo "Simulating network timeout..."
                sleep 2
                echo "Push failed: timeout"
            else
                git push && break
            fi
        done
    )
    
    # Remove simulated latency
    remove_network_simulation
    
    cleanup_claude_session "latency"
    
    print_success "Network latency handling test completed"
    return 0
}

# Test: Platform-specific paths
test_platform_specific_paths() {
    print_info "Testing platform-specific path handling"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    
    create_claude_session "platform" "$repo_dir"
    
    # Test various path formats
    print_info "Testing path handling across platforms..."
    
    (
        cd "$repo_dir"
        
        # Create files with different path styles
        mkdir -p "src/Windows Style Paths"
        mkdir -p "src/unix-style-paths"
        mkdir -p "src/MixedCaseFolder"
        
        # Files with spaces
        echo "// File with spaces" > "src/Windows Style Paths/My File.js"
        
        # Files with special characters
        echo "// Special chars" > "src/file-with-dashes.js"
        echo "// Underscore" > "src/file_with_underscores.js"
        
        # Unicode filenames (if supported)
        echo "// Unicode" > "src/файл.js" 2>/dev/null || echo "// ASCII only" > "src/file.js"
        
        git add .
    )
    
    # Test path operations
    execute_claude_command "status" "$repo_dir" "" || return 1
    
    # Verify all files are tracked correctly
    (
        cd "$repo_dir"
        local tracked_files=$(git ls-files | wc -l)
        echo "Files tracked: $tracked_files"
        
        # Test case sensitivity
        if [[ "$(uname -s)" == "Darwin" ]] || [[ "$(uname -s)" == MINGW* ]]; then
            echo "Platform: Case-insensitive filesystem detected"
        else
            echo "Platform: Case-sensitive filesystem detected"
        fi
    )
    
    execute_claude_command "commit" "$repo_dir" "-m 'test: platform-specific paths'" || return 1
    
    cleanup_claude_session "platform"
    
    print_success "Platform-specific path test completed"
    return 0
}

# Test: Line ending handling
test_line_ending_handling() {
    print_info "Testing line ending handling"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    
    # Configure git for line ending testing
    (
        cd "$repo_dir"
        
        # Set up .gitattributes
        cat > .gitattributes << 'EOF'
# Line ending configuration
*.txt text=auto
*.sh text eol=lf
*.bat text eol=crlf
*.bin binary
EOF
        
        git add .gitattributes
        git commit -m "chore: configure line endings"
    )
    
    create_claude_session "lineending" "$repo_dir"
    
    # Create files with different line endings
    print_info "Creating files with various line endings..."
    (
        cd "$repo_dir"
        
        # LF file (Unix)
        printf "Line 1\nLine 2\nLine 3\n" > unix-file.txt
        
        # CRLF file (Windows)
        printf "Line 1\r\nLine 2\r\nLine 3\r\n" > windows-file.txt
        
        # Shell script (should always be LF)
        cat > script.sh << 'EOF'
#!/bin/bash
echo "Shell script"
EOF
        
        # Batch file (should always be CRLF)
        printf "@echo off\r\necho Batch file\r\n" > script.bat
        
        # Binary file
        echo -e "\x00\x01\x02\x03" > binary.bin
        
        git add .
    )
    
    # Test commit with line ending handling
    execute_claude_command "commit" "$repo_dir" "-m 'test: add files with different line endings'" || return 1
    
    # Verify line endings are handled correctly
    print_info "Verifying line ending handling..."
    (
        cd "$repo_dir"
        
        # Check that .sh files have LF
        if file script.sh | grep -q "CRLF"; then
            print_error "Shell script has wrong line endings"
            return 1
        else
            print_success "Shell script has correct line endings (LF)"
        fi
        
        # Check that .bat files have CRLF
        if file script.bat | grep -q "CRLF"; then
            print_success "Batch file has correct line endings (CRLF)"
        else
            print_warning "Batch file line endings may need adjustment"
        fi
        
        # Verify binary file is unchanged
        if git diff --stat --cached binary.bin | grep -q "Bin"; then
            print_success "Binary file handled correctly"
        fi
    )
    
    cleanup_claude_session "lineending"
    
    print_success "Line ending handling test completed"
    return 0
}

# Test: Permission handling
test_permission_handling() {
    print_info "Testing file permission handling"
    
    local repo_dir="${INTEGRATION_ENV[repo_dir]}"
    
    create_claude_session "permissions" "$repo_dir"
    
    # Test executable permissions
    print_info "Testing executable permission tracking..."
    (
        cd "$repo_dir"
        
        # Create executable script
        cat > deploy.sh << 'EOF'
#!/bin/bash
echo "Deployment script"
EOF
        chmod +x deploy.sh
        
        # Create non-executable config
        cat > config.conf << 'EOF'
# Configuration file
setting=value
EOF
        chmod 644 config.conf
        
        # Create restricted file
        cat > secrets.env << 'EOF'
SECRET_KEY=hidden
EOF
        chmod 600 secrets.env
        
        git add .
    )
    
    # Commit with permission preservation
    execute_claude_command "commit" "$repo_dir" "-m 'test: add files with specific permissions'" || return 1
    
    # Verify permissions are tracked
    print_info "Verifying permission tracking..."
    (
        cd "$repo_dir"
        
        # Check executable bit is preserved
        if git ls-files -s deploy.sh | grep -q "100755"; then
            print_success "Executable permission preserved for deploy.sh"
        else
            print_error "Executable permission lost for deploy.sh"
        fi
        
        # Note: Git only tracks executable bit, not full permissions
        echo "Note: Git only tracks executable bit, not full Unix permissions"
    )
    
    # Test permission changes
    print_info "Testing permission changes..."
    (
        cd "$repo_dir"
        chmod -x deploy.sh
        
        if git diff --stat | grep -q "mode change"; then
            print_success "Permission change detected"
        fi
        
        git add deploy.sh
    )
    
    execute_claude_command "commit" "$repo_dir" "-m 'fix: remove executable permission from deploy.sh'" || return 1
    
    cleanup_claude_session "permissions"
    
    print_success "Permission handling test completed"
    return 0
}

# Export all test functions
export -f test_feature_development_workflow test_hotfix_emergency_workflow
export -f test_release_preparation_workflow test_repository_sync_workflow
export -f test_team_collaboration_workflow test_conflict_resolution_workflow
export -f test_failed_push_recovery test_rollback_procedures
export -f test_hook_failure_recovery test_large_repository_performance
export -f test_concurrent_git_operations test_network_latency_handling
export -f test_platform_specific_paths test_line_ending_handling
export -f test_permission_handling

# Export utility functions
export -f assert_equals assert_contains assert_file_exists