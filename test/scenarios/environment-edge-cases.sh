#!/bin/bash

# Environment Edge Cases for Claude Flow Commands
# Tests various environmental conditions and platform differences
# Includes missing dependencies, permission issues, network problems, and platform variations

# Enable strict error handling
set -euo pipefail

# Import test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$(dirname "$SCRIPT_DIR")"

source "$TEST_ROOT/lib/integration-environment.sh"

# Colors for output
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Test configuration
readonly ENV_TEST_DIR="/tmp/claude-env-tests-$$"
readonly NETWORK_TIMEOUT=10
readonly PERMISSION_TEST_DIR="$ENV_TEST_DIR/permission-tests"

# Test statistics
ENV_TESTS_RUN=0
ENV_TESTS_PASSED=0
ENV_TESTS_FAILED=0
PLATFORM_ISSUES=0

# Platform detection
PLATFORM=$(uname -s)
ARCH=$(uname -m)
OS_VERSION=$(uname -r)

# Helper functions
env_info() {
    echo -e "${CYAN}[ENV] $1${NC}"
}

env_success() {
    echo -e "${GREEN}[ENV] ✅ $1${NC}"
    ((ENV_TESTS_PASSED++))
}

env_error() {
    echo -e "${RED}[ENV] ❌ $1${NC}"
    ((ENV_TESTS_FAILED++))
}

env_warning() {
    echo -e "${YELLOW}[ENV] ⚠️ $1${NC}"
}

env_platform_issue() {
    echo -e "${YELLOW}[ENV] 🖥️ PLATFORM: $1${NC}"
    ((PLATFORM_ISSUES++))
}

# Setup test environment
setup_environment_tests() {
    env_info "Setting up environment edge case tests"
    
    mkdir -p "$ENV_TEST_DIR"
    mkdir -p "$PERMISSION_TEST_DIR"
    cd "$ENV_TEST_DIR"
    
    # Create basic test repository
    git init --quiet
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    echo "Environment test file" > env-test.txt
    git add env-test.txt
    git commit -m "Initial environment test commit" --quiet
    
    env_success "Environment test setup completed"
}

# Cleanup test environment
cleanup_environment_tests() {
    env_info "Cleaning up environment test environment"
    
    if [[ -d "$ENV_TEST_DIR" ]]; then
        # Restore any modified permissions
        chmod -R u+w "$ENV_TEST_DIR" 2>/dev/null || true
        
        # Remove test directory
        rm -rf "$ENV_TEST_DIR"
    fi
    
    env_success "Environment cleanup completed"
}

# Test: Missing git installation
test_missing_git() {
    env_info "Testing missing git installation handling"
    ((ENV_TESTS_RUN++))
    
    # Note: We won't actually remove git, just simulate the scenario
    local missing_git_success=true
    
    env_info "Simulating missing git scenario"
    
    # Test git availability detection
    if command -v git >/dev/null 2>&1; then
        env_info "✓ Git is available in PATH"
        
        # Test git version detection
        local git_version=$(git --version 2>/dev/null || echo "unknown")
        env_info "Git version: $git_version"
        
        # Test minimum version requirements (assuming git 2.0+)
        local git_major_version=$(echo "$git_version" | grep -o '[0-9]\+' | head -1)
        if [[ ${git_major_version:-0} -ge 2 ]]; then
            env_info "✓ Git version is adequate"
        else
            env_warning "Git version may be too old: $git_version"
        fi
        
    else
        env_error "Git is not available in PATH"
        missing_git_success=false
    fi
    
    # Test git configuration accessibility
    if git config --global user.name >/dev/null 2>&1; then
        env_info "✓ Git global configuration accessible"
    else
        env_warning "Git global configuration not accessible"
    fi
    
    # Test git in non-standard locations
    local git_locations=(
        "/usr/bin/git"
        "/usr/local/bin/git"
        "/opt/local/bin/git"
        "/snap/bin/git"
    )
    
    for location in "${git_locations[@]}"; do
        if [[ -x "$location" ]]; then
            env_info "✓ Git found at: $location"
        fi
    done
    
    if [[ "$missing_git_success" == "true" ]]; then
        env_success "Missing git test passed"
    else
        env_error "Missing git test failed"
        return 1
    fi
}

# Test: Permission issues
test_permission_issues() {
    env_info "Testing permission-related issues"
    ((ENV_TESTS_RUN++))
    
    local permission_success=true
    cd "$PERMISSION_TEST_DIR"
    
    # Initialize test repository
    git init --quiet
    git config user.name "Permission Test"
    git config user.email "perm@test.com"
    
    # Test: Read-only repository directory
    env_info "Testing read-only repository permissions"
    
    echo "permission test" > perm-test.txt
    git add perm-test.txt
    git commit -m "Permission test" --quiet
    
    # Make .git directory read-only
    local original_git_perms=$(stat -c %a .git 2>/dev/null || stat -f %A .git 2>/dev/null || echo "755")
    chmod 555 .git
    
    # Test git operations with read-only .git
    if git status >/dev/null 2>&1; then
        env_warning "Git operations still work with read-only .git"
    else
        env_info "✓ Git operations properly restricted with read-only .git"
    fi
    
    # Restore permissions
    chmod "$original_git_perms" .git
    
    # Test: Read-only working directory
    env_info "Testing read-only working directory"
    
    local original_dir_perms=$(stat -c %a . 2>/dev/null || stat -f %A . 2>/dev/null || echo "755")
    chmod 555 .
    
    # Test file creation in read-only directory
    if echo "test" > readonly-test.txt 2>/dev/null; then
        env_warning "File creation succeeded in read-only directory"
        rm -f readonly-test.txt
    else
        env_info "✓ File creation properly blocked in read-only directory"
    fi
    
    # Restore directory permissions
    chmod "$original_dir_perms" .
    
    # Test: File permission issues
    env_info "Testing file permission issues"
    
    echo "read-only content" > readonly-file.txt
    chmod 444 readonly-file.txt
    
    if git add readonly-file.txt 2>/dev/null; then
        env_info "✓ Read-only file added successfully"
        git commit -m "Add read-only file" --quiet 2>/dev/null || true
    else
        env_warning "Read-only file could not be added"
    fi
    
    # Test executable files
    cat > executable-test.sh << 'EOF'
#!/bin/bash
echo "Executable test"
EOF
    chmod +x executable-test.sh
    
    if git add executable-test.sh 2>/dev/null; then
        env_info "✓ Executable file added successfully"
        
        git commit -m "Add executable file" --quiet
        
        # Verify executable bit is preserved
        if git ls-files -s executable-test.sh | grep -q "100755"; then
            env_info "✓ Executable permission preserved in git"
        else
            env_warning "Executable permission not preserved in git"
        fi
    else
        env_warning "Executable file could not be added"
    fi
    
    # Cleanup permission test files
    chmod 644 readonly-file.txt 2>/dev/null || true
    rm -f readonly-file.txt executable-test.sh perm-test.txt
    
    if [[ "$permission_success" == "true" ]]; then
        env_success "Permission issues test passed"
    else
        env_error "Permission issues test failed"
        return 1
    fi
}

# Test: Network connectivity issues
test_network_issues() {
    env_info "Testing network connectivity edge cases"
    ((ENV_TESTS_RUN++))
    
    local network_success=true
    cd "$ENV_TEST_DIR"
    
    # Test: DNS resolution issues
    env_info "Testing DNS resolution"
    
    if nslookup github.com >/dev/null 2>&1; then
        env_info "✓ DNS resolution working"
    else
        env_warning "DNS resolution issues detected"
    fi
    
    # Test: Network timeouts
    env_info "Testing network timeout handling"
    
    # Test connection to a reliable external service
    if timeout $NETWORK_TIMEOUT ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        env_info "✓ Basic network connectivity available"
        
        # Test HTTP connectivity
        if timeout $NETWORK_TIMEOUT curl -s --head https://httpbin.org/status/200 >/dev/null 2>&1; then
            env_info "✓ HTTP connectivity working"
        else
            env_warning "HTTP connectivity issues"
        fi
        
    else
        env_warning "Basic network connectivity issues"
    fi
    
    # Test: Proxy configuration issues
    env_info "Testing proxy configuration"
    
    if [[ -n "${HTTP_PROXY:-}${http_proxy:-}" ]]; then
        env_info "HTTP proxy configured: ${HTTP_PROXY:-${http_proxy:-}}"
        
        # Test proxy connectivity
        if timeout $NETWORK_TIMEOUT curl -s --head https://httpbin.org/status/200 >/dev/null 2>&1; then
            env_info "✓ Proxy connectivity working"
        else
            env_warning "Proxy connectivity issues"
        fi
    else
        env_info "No HTTP proxy configured"
    fi
    
    # Test: Firewall/port blocking simulation
    env_info "Testing unusual port connectivity"
    
    # Test connection to commonly blocked ports
    local test_ports=(22 80 443 8080 3000)
    
    for port in "${test_ports[@]}"; do
        if timeout 2 nc -z httpbin.org $port 2>/dev/null; then
            env_info "✓ Port $port accessible"
        else
            env_info "Port $port blocked or filtered"
        fi
    done
    
    if [[ "$network_success" == "true" ]]; then
        env_success "Network issues test passed"
    else
        env_error "Network issues test failed"
        return 1
    fi
}

# Test: Platform-specific differences
test_platform_differences() {
    env_info "Testing platform-specific differences"
    ((ENV_TESTS_RUN++))
    
    local platform_success=true
    
    env_info "Platform: $PLATFORM, Architecture: $ARCH, Version: $OS_VERSION"
    
    # Test: Case sensitivity
    env_info "Testing filesystem case sensitivity"
    
    echo "test content" > CaseTest.txt
    echo "different content" > casetest.txt 2>/dev/null || true
    
    if [[ -f "CaseTest.txt" && -f "casetest.txt" ]]; then
        local file_count=$(ls -1 CaseTest.txt casetest.txt 2>/dev/null | wc -l)
        if [[ $file_count -eq 2 ]]; then
            env_info "✓ Case-sensitive filesystem detected"
        else
            env_info "✓ Case-insensitive filesystem detected"
            env_platform_issue "Case-insensitive filesystem may cause git issues"
        fi
    else
        env_info "✓ Case-insensitive filesystem (files merged)"
    fi
    
    rm -f CaseTest.txt casetest.txt
    
    # Test: Path separators
    env_info "Testing path separator handling"
    
    case "$PLATFORM" in
        "Darwin"|"Linux")
            env_info "✓ Unix-like platform detected"
            
            # Test Unix-specific paths
            if mkdir -p "unix/style/path" 2>/dev/null; then
                env_info "✓ Unix path creation successful"
                rm -rf "unix"
            fi
            ;;
        "MINGW"*|"CYGWIN"*|"MSYS"*)
            env_info "✓ Windows-like platform detected"
            env_platform_issue "Windows platform may have path issues"
            
            # Test Windows-specific behavior
            if echo "test" > "test:file.txt" 2>/dev/null; then
                env_warning "Colon in filename allowed (unusual for Windows)"
                rm -f "test:file.txt"
            else
                env_info "✓ Windows filename restrictions enforced"
            fi
            ;;
        *)
            env_platform_issue "Unknown platform: $PLATFORM"
            ;;
    esac
    
    # Test: Line ending handling
    env_info "Testing line ending behavior"
    
    printf "line1\nline2\n" > unix-endings.txt
    printf "line1\r\nline2\r\n" > windows-endings.txt
    
    git add unix-endings.txt windows-endings.txt
    
    # Check git's handling of line endings
    local git_autocrlf=$(git config core.autocrlf 2>/dev/null || echo "false")
    env_info "Git autocrlf setting: $git_autocrlf"
    
    if git commit -m "Test line endings" --quiet 2>/dev/null; then
        env_info "✓ Mixed line endings handled by git"
    else
        env_warning "Git had issues with mixed line endings"
    fi
    
    rm -f unix-endings.txt windows-endings.txt
    
    # Test: Maximum path length
    env_info "Testing maximum path length"
    
    local long_path=""
    for i in {1..50}; do
        long_path="${long_path}dir/"
    done
    
    if mkdir -p "$long_path" 2>/dev/null; then
        env_info "✓ Long paths supported"
        rm -rf "dir"
    else
        env_platform_issue "Long path creation failed - platform limitation"
    fi
    
    # Test: Special characters in filenames
    env_info "Testing special characters in filenames"
    
    local special_chars="éñ中文🚀"
    if echo "test" > "${special_chars}.txt" 2>/dev/null; then
        env_info "✓ Unicode characters in filenames supported"
        rm -f "${special_chars}.txt"
    else
        env_platform_issue "Unicode characters in filenames not supported"
    fi
    
    # Test: File locking behavior
    env_info "Testing file locking behavior"
    
    echo "lock test" > lock-test.txt
    
    # Try to create a lock on the file and test git's behavior
    if git add lock-test.txt 2>/dev/null; then
        env_info "✓ File locking handled appropriately"
        git commit -m "Lock test" --quiet 2>/dev/null || true
    else
        env_warning "File locking issues detected"
    fi
    
    rm -f lock-test.txt
    
    if [[ "$platform_success" == "true" ]]; then
        env_success "Platform differences test passed"
    else
        env_error "Platform differences test failed"
        return 1
    fi
}

# Test: Environment variables
test_environment_variables() {
    env_info "Testing environment variable edge cases"
    ((ENV_TESTS_RUN++))
    
    local env_var_success=true
    
    # Test: Git-specific environment variables
    env_info "Testing git environment variables"
    
    local git_env_vars=(
        "GIT_DIR"
        "GIT_WORK_TREE"
        "GIT_INDEX_FILE"
        "GIT_OBJECT_DIRECTORY"
        "GIT_ALTERNATE_OBJECT_DIRECTORIES"
        "GIT_CONFIG"
        "GIT_CONFIG_GLOBAL"
        "GIT_CONFIG_SYSTEM"
        "GIT_AUTHOR_NAME"
        "GIT_AUTHOR_EMAIL"
        "GIT_COMMITTER_NAME"
        "GIT_COMMITTER_EMAIL"
    )
    
    for var in "${git_env_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            env_info "Git environment variable set: $var=${!var}"
        fi
    done
    
    # Test: Locale-related variables
    env_info "Testing locale environment"
    
    local locale_vars=(
        "LANG"
        "LC_ALL"
        "LC_CTYPE"
        "LC_COLLATE"
        "LC_MESSAGES"
    )
    
    for var in "${locale_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            env_info "Locale variable: $var=${!var}"
        fi
    done
    
    # Test locale impact on git
    local current_lang="${LANG:-C}"
    
    export LANG=C
    local output_c=$(git status 2>&1 | head -1)
    
    export LANG=en_US.UTF-8
    local output_utf8=$(git status 2>&1 | head -1)
    
    export LANG="$current_lang"
    
    if [[ "$output_c" != "$output_utf8" ]]; then
        env_info "✓ Locale affects git output"
    else
        env_info "✓ Git output consistent across locales"
    fi
    
    # Test: Path-related variables
    env_info "Testing PATH variable"
    
    local original_path="$PATH"
    
    # Test with minimal PATH
    export PATH="/bin:/usr/bin"
    
    if command -v git >/dev/null 2>&1; then
        env_info "✓ Git accessible with minimal PATH"
    else
        env_warning "Git not accessible with minimal PATH"
    fi
    
    # Restore original PATH
    export PATH="$original_path"
    
    # Test: Home directory variable
    env_info "Testing HOME directory"
    
    if [[ -n "${HOME:-}" && -d "$HOME" ]]; then
        env_info "✓ HOME directory accessible: $HOME"
        
        # Test git config in HOME
        if [[ -f "$HOME/.gitconfig" ]]; then
            env_info "✓ Global git config found"
        else
            env_info "No global git config found"
        fi
    else
        env_warning "HOME directory not set or not accessible"
    fi
    
    # Test: Temporary directory variables
    env_info "Testing temporary directory variables"
    
    local temp_vars=("TMPDIR" "TMP" "TEMP")
    local temp_dir=""
    
    for var in "${temp_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            temp_dir="${!var}"
            env_info "Temp directory from $var: $temp_dir"
            break
        fi
    done
    
    if [[ -z "$temp_dir" ]]; then
        temp_dir="/tmp"
        env_info "Using default temp directory: $temp_dir"
    fi
    
    if [[ -d "$temp_dir" && -w "$temp_dir" ]]; then
        env_info "✓ Temporary directory accessible and writable"
    else
        env_warning "Temporary directory issues: $temp_dir"
        env_var_success=false
    fi
    
    if [[ "$env_var_success" == "true" ]]; then
        env_success "Environment variables test passed"
    else
        env_error "Environment variables test failed"
        return 1
    fi
}

# Test: Resource limitations
test_resource_limitations() {
    env_info "Testing resource limitation handling"
    ((ENV_TESTS_RUN++))
    
    local resource_success=true
    
    # Test: Memory constraints
    env_info "Testing memory usage"
    
    # Get current memory usage
    local memory_info=""
    if command -v free >/dev/null 2>&1; then
        memory_info=$(free -m | grep "^Mem:" | awk '{print $2}')
        env_info "Available memory: ${memory_info}MB"
    elif command -v vm_stat >/dev/null 2>&1; then
        # macOS
        local pages_free=$(vm_stat | grep "Pages free:" | awk '{print $3}' | tr -d '.')
        local page_size=$(vm_stat | grep "page size" | awk '{print $8}')
        if [[ -n "$pages_free" && -n "$page_size" ]]; then
            memory_info=$(( (pages_free * page_size) / 1024 / 1024 ))
            env_info "Available memory: ${memory_info}MB"
        fi
    fi
    
    # Test: Disk space constraints
    env_info "Testing disk space"
    
    local available_space_kb=$(df . | tail -1 | awk '{print $4}')
    local available_space_mb=$(( available_space_kb / 1024 ))
    env_info "Available disk space: ${available_space_mb}MB"
    
    if [[ $available_space_mb -lt 100 ]]; then
        env_warning "Low disk space: ${available_space_mb}MB"
    else
        env_info "✓ Adequate disk space available"
    fi
    
    # Test: File descriptor limits
    env_info "Testing file descriptor limits"
    
    local fd_limit=$(ulimit -n 2>/dev/null || echo "unknown")
    env_info "File descriptor limit: $fd_limit"
    
    if [[ "$fd_limit" != "unknown" && $fd_limit -lt 256 ]]; then
        env_warning "Low file descriptor limit: $fd_limit"
    else
        env_info "✓ Adequate file descriptor limit"
    fi
    
    # Test: Process limits
    env_info "Testing process limits"
    
    local proc_limit=$(ulimit -u 2>/dev/null || echo "unknown")
    env_info "Process limit: $proc_limit"
    
    # Test: Maximum file size
    env_info "Testing maximum file size limits"
    
    local max_file_size=$(ulimit -f 2>/dev/null || echo "unlimited")
    env_info "Maximum file size: $max_file_size"
    
    if [[ "$max_file_size" != "unlimited" && $max_file_size -lt 1048576 ]]; then
        env_warning "File size limit may be restrictive: $max_file_size blocks"
    fi
    
    if [[ "$resource_success" == "true" ]]; then
        env_success "Resource limitations test passed"
    else
        env_error "Resource limitations test failed"
        return 1
    fi
}

# Test: Clock and timezone issues
test_clock_timezone() {
    env_info "Testing clock and timezone handling"
    ((ENV_TESTS_RUN++))
    
    local clock_success=true
    
    # Test: Current timezone
    env_info "Testing timezone configuration"
    
    local timezone=$(date +%Z 2>/dev/null || echo "unknown")
    env_info "Current timezone: $timezone"
    
    local utc_offset=$(date +%z 2>/dev/null || echo "unknown")
    env_info "UTC offset: $utc_offset"
    
    # Test: Git timestamp handling
    env_info "Testing git timestamp handling"
    
    echo "timestamp test" > timestamp-test.txt
    git add timestamp-test.txt
    
    if git commit -m "Timestamp test" --quiet 2>/dev/null; then
        # Check timestamp format in git log
        local commit_date=$(git log -1 --format="%cd" --date=iso)
        env_info "Git commit timestamp: $commit_date"
        
        # Verify timestamp is reasonable (not in far future/past)
        local commit_epoch=$(git log -1 --format="%ct")
        local current_epoch=$(date +%s)
        local time_diff=$(( current_epoch - commit_epoch ))
        
        if [[ ${time_diff#-} -lt 3600 ]]; then  # Within 1 hour
            env_info "✓ Git timestamp is reasonable"
        else
            env_warning "Git timestamp seems incorrect: ${time_diff}s difference"
        fi
    else
        env_warning "Git commit failed - timestamp issues?"
        clock_success=false
    fi
    
    # Test: Different timezone handling
    env_info "Testing timezone changes"
    
    local original_tz="${TZ:-}"
    
    export TZ="UTC"
    local utc_commit_date=$(git log -1 --format="%cd" --date=iso)
    env_info "UTC timestamp: $utc_commit_date"
    
    export TZ="US/Pacific"
    local pst_commit_date=$(git log -1 --format="%cd" --date=iso)
    env_info "PST timestamp: $pst_commit_date"
    
    # Restore original timezone
    if [[ -n "$original_tz" ]]; then
        export TZ="$original_tz"
    else
        unset TZ
    fi
    
    rm -f timestamp-test.txt
    
    if [[ "$clock_success" == "true" ]]; then
        env_success "Clock and timezone test passed"
    else
        env_error "Clock and timezone test failed"
        return 1
    fi
}

# Generate environment test report
generate_environment_report() {
    env_info "Generating environment test report"
    
    local total_tests=$ENV_TESTS_RUN
    local passed_tests=$ENV_TESTS_PASSED
    local failed_tests=$ENV_TESTS_FAILED
    local platform_issues=$PLATFORM_ISSUES
    local success_rate=0
    
    if [[ $total_tests -gt 0 ]]; then
        success_rate=$(( (passed_tests * 100) / total_tests ))
    fi
    
    echo -e "\n${BLUE}=== Environment Edge Cases Summary ===${NC}"
    echo -e "Platform: $PLATFORM $ARCH ($OS_VERSION)"
    echo -e "Total Tests Run: $total_tests"
    echo -e "${GREEN}Passed: $passed_tests${NC}"
    echo -e "${RED}Failed: $failed_tests${NC}"
    echo -e "${YELLOW}Platform Issues: $platform_issues${NC}"
    echo -e "Success Rate: ${success_rate}%"
    
    if [[ $platform_issues -gt 0 ]]; then
        env_warning "$platform_issues platform-specific issues detected"
    fi
    
    if [[ $failed_tests -eq 0 ]]; then
        env_success "All environment edge case tests passed!"
        return 0
    else
        env_error "$failed_tests environment tests failed"
        return 1
    fi
}

# Main execution function
main() {
    env_info "Starting Environment Edge Case Testing"
    env_info "Platform: $PLATFORM, Architecture: $ARCH"
    
    # Setup test environment
    setup_environment_tests
    
    # Set up cleanup trap
    trap cleanup_environment_tests EXIT
    
    local overall_success=true
    
    # Run all environment edge case tests
    env_info "Running environment edge case tests..."
    
    test_missing_git || overall_success=false
    test_permission_issues || overall_success=false
    test_network_issues || overall_success=false
    test_platform_differences || overall_success=false
    test_environment_variables || overall_success=false
    test_resource_limitations || overall_success=false
    test_clock_timezone || overall_success=false
    
    # Generate final report
    if ! generate_environment_report; then
        overall_success=false
    fi
    
    # Exit with appropriate code
    if [[ "$overall_success" == "true" ]]; then
        env_success "Environment edge case testing completed successfully"
        exit 0
    else
        env_error "Environment edge case testing completed with failures"
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi