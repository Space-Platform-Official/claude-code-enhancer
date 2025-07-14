#!/bin/bash

# Test Reporter Library for Claude Flow Git Command Testing Framework
# Provides comprehensive test result reporting, metrics tracking, and output formatting
# Supports multiple output formats: console, JSON, JUnit XML, TAP

# Enable strict error handling
set -euo pipefail

# Colors (inherit from parent or set defaults)
: "${GREEN:=\033[0;32m}"
: "${YELLOW:=\033[1;33m}"
: "${BLUE:=\033[0;34m}"
: "${RED:=\033[0;31m}"
: "${CYAN:=\033[0;36m}"
: "${MAGENTA:=\033[0;35m}"
: "${NC:=\033[0m}"

# Report configuration
REPORT_TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_HOSTNAME=$(hostname -s 2>/dev/null || echo "unknown")
REPORT_USER=$(whoami 2>/dev/null || echo "unknown")

# Test metrics storage - using simple variables for macOS compatibility
TEST_METRICS_STORAGE=""
TEST_TIMINGS_STORAGE=""
TEST_ERRORS_STORAGE=""
TEST_WARNINGS_STORAGE=""
PERFORMANCE_BASELINES_STORAGE=""

# Report utilities
format_duration() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local remaining_seconds=$((seconds % 60))
    
    if [[ $hours -gt 0 ]]; then
        printf "%dh %dm %ds" $hours $minutes $remaining_seconds
    elif [[ $minutes -gt 0 ]]; then
        printf "%dm %ds" $minutes $remaining_seconds
    else
        printf "%ds" $remaining_seconds
    fi
}

format_percentage() {
    local numerator=$1
    local denominator=$2
    
    if [[ $denominator -eq 0 ]]; then
        echo "N/A"
    else
        local percentage=$((numerator * 100 / denominator))
        echo "${percentage}%"
    fi
}

format_bytes() {
    local bytes=$1
    
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$((bytes / 1024))KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$((bytes / 1048576))MB"
    else
        echo "$((bytes / 1073741824))GB"
    fi
}

# Metric collection functions
record_test_metric() {
    local metric_name="$1"
    local metric_value="$2"
    
    TEST_METRICS_STORAGE="${TEST_METRICS_STORAGE}${metric_name}=${metric_value};"
}

record_test_timing() {
    local test_name="$1"
    local duration="$2"
    
    TEST_TIMINGS_STORAGE="${TEST_TIMINGS_STORAGE}${test_name}=${duration};"
}

record_test_error() {
    local test_name="$1"
    local error_message="$2"
    
    TEST_ERRORS_STORAGE="${TEST_ERRORS_STORAGE}${test_name}=${error_message};"
}

record_test_warning() {
    local test_name="$1"
    local warning_message="$2"
    
    TEST_WARNINGS_STORAGE="${TEST_WARNINGS_STORAGE}${test_name}=${warning_message};"
}

# Performance tracking (simplified for compatibility)
load_performance_baselines() {
    local baseline_file="${CACHE_DIR:-/tmp}/performance-baselines.txt"
    
    if [[ -f "$baseline_file" ]]; then
        PERFORMANCE_BASELINES_STORAGE=$(cat "$baseline_file")
    fi
}

save_performance_baselines() {
    local baseline_file="${CACHE_DIR:-/tmp}/performance-baselines.txt"
    
    echo "$TEST_TIMINGS_STORAGE" > "$baseline_file"
}

check_performance_regression() {
    local test_name="$1"
    local current_duration="$2"
    
    # Simple check - in a real implementation would parse storage strings
    return 0
}

# Console report generation (simplified for compatibility)
generate_console_report() {
    local title="${1:-Test Report}"
    
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}${title}${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    
    # System information
    echo -e "\n${CYAN}System Information${NC}"
    echo -e "├─ Timestamp: $(date)"
    echo -e "├─ Hostname: $REPORT_HOSTNAME"
    echo -e "├─ User: $REPORT_USER"
    echo -e "└─ Platform: $(uname -s) $(uname -r)"
    
    # Basic test summary (values would be passed as parameters)
    echo -e "\n${CYAN}Test Summary${NC}"
    echo -e "├─ Total Tests: ${TOTAL_TESTS:-0}"
    echo -e "├─ ${GREEN}Passed: ${PASSED_TESTS:-0}${NC}"
    echo -e "├─ ${RED}Failed: ${FAILED_TESTS:-0}${NC}"
    echo -e "└─ ${YELLOW}Skipped: ${SKIPPED_TESTS:-0}${NC}"
    
    # Basic performance info
    if [[ -n "${TOTAL_DURATION:-}" ]]; then
        echo -e "\n${CYAN}Performance Metrics${NC}"
        echo -e "└─ Total Duration: $(format_duration ${TOTAL_DURATION:-0})"
    fi
}

# JSON report generation (simplified for compatibility)
generate_json_report() {
    local output_file="${1:-${RESULTS_DIR:-/tmp}/test-report-${REPORT_TIMESTAMP}.json}"
    
    {
        echo "{"
        echo "  \"metadata\": {"
        echo "    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
        echo "    \"hostname\": \"$REPORT_HOSTNAME\","
        echo "    \"user\": \"$REPORT_USER\","
        echo "    \"platform\": \"$(uname -s)\","
        echo "    \"platform_version\": \"$(uname -r)\""
        echo "  },"
        echo "  \"summary\": {"
        echo "    \"total\": ${TOTAL_TESTS:-0},"
        echo "    \"passed\": ${PASSED_TESTS:-0},"
        echo "    \"failed\": ${FAILED_TESTS:-0},"
        echo "    \"skipped\": ${SKIPPED_TESTS:-0}"
        echo "  }"
        echo "}"
    } > "$output_file"
    
    echo -e "${GREEN}JSON report saved to: $output_file${NC}"
}

# JUnit XML report generation
generate_junit_xml_report() {
    local output_file="${1:-${RESULTS_DIR:-/tmp}/junit-report-${REPORT_TIMESTAMP}.xml}"
    local test_suite_name="${2:-Claude Flow Git Tests}"
    
    {
        echo '<?xml version="1.0" encoding="UTF-8"?>'
        echo '<testsuites>'
        
        local total="${TEST_METRICS[total_tests]:-0}"
        local failures="${TEST_METRICS[failed_tests]:-0}"
        local skipped="${TEST_METRICS[skipped_tests]:-0}"
        local total_time=0
        
        # Calculate total time
        for duration in "${TEST_TIMINGS[@]}"; do
            ((total_time += duration))
        done
        
        echo "  <testsuite name=\"$test_suite_name\" tests=\"$total\" failures=\"$failures\" skipped=\"$skipped\" time=\"$total_time\" timestamp=\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\" hostname=\"$REPORT_HOSTNAME\">"
        
        # Generate test cases
        local test_id=1
        for test_name in "${!TEST_TIMINGS[@]}"; do
            local duration="${TEST_TIMINGS[$test_name]}"
            echo "    <testcase id=\"$test_id\" name=\"$test_name\" time=\"$duration\">"
            
            # Add failure if test has errors
            if [[ -n "${TEST_ERRORS[$test_name]:-}" ]]; then
                IFS='|' read -ra error_array <<< "${TEST_ERRORS[$test_name]}"
                echo "      <failure message=\"Test failed\" type=\"TestFailure\">"
                for error in "${error_array[@]}"; do
                    echo "        $error"
                done
                echo "      </failure>"
            fi
            
            # Add system output for warnings
            if [[ -n "${TEST_WARNINGS[$test_name]:-}" ]]; then
                echo "      <system-out>"
                IFS='|' read -ra warning_array <<< "${TEST_WARNINGS[$test_name]}"
                for warning in "${warning_array[@]}"; do
                    echo "        WARNING: $warning"
                done
                echo "      </system-out>"
            fi
            
            echo "    </testcase>"
            ((test_id++))
        done
        
        # Add system properties
        echo "    <properties>"
        echo "      <property name=\"platform\" value=\"$(uname -s)\"/>"
        echo "      <property name=\"user\" value=\"$REPORT_USER\"/>"
        echo "    </properties>"
        
        echo "  </testsuite>"
        echo '</testsuites>'
    } > "$output_file"
    
    echo -e "${GREEN}JUnit XML report saved to: $output_file${NC}"
}

# TAP report generation
generate_tap_report() {
    local output_file="${1:-${RESULTS_DIR:-/tmp}/tap-report-${REPORT_TIMESTAMP}.tap}"
    
    {
        local total="${TEST_METRICS[total_tests]:-0}"
        echo "TAP version 13"
        echo "1..$total"
        
        local test_num=1
        for test_name in "${!TEST_TIMINGS[@]}"; do
            if [[ -n "${TEST_ERRORS[$test_name]:-}" ]]; then
                echo "not ok $test_num - $test_name"
                IFS='|' read -ra error_array <<< "${TEST_ERRORS[$test_name]}"
                for error in "${error_array[@]}"; do
                    echo "  ---"
                    echo "  message: $error"
                    echo "  severity: fail"
                    echo "  ..."
                done
            else
                echo "ok $test_num - $test_name"
            fi
            
            # Add diagnostics for warnings
            if [[ -n "${TEST_WARNINGS[$test_name]:-}" ]]; then
                IFS='|' read -ra warning_array <<< "${TEST_WARNINGS[$test_name]}"
                for warning in "${warning_array[@]}"; do
                    echo "  # WARNING: $warning"
                done
            fi
            
            ((test_num++))
        done
        
        # Summary
        echo "# Summary"
        echo "# Total: $total"
        echo "# Passed: ${TEST_METRICS[passed_tests]:-0}"
        echo "# Failed: ${TEST_METRICS[failed_tests]:-0}"
        echo "# Skipped: ${TEST_METRICS[skipped_tests]:-0}"
    } > "$output_file"
    
    echo -e "${GREEN}TAP report saved to: $output_file${NC}"
}

# Markdown report generation
generate_markdown_report() {
    local output_file="${1:-${RESULTS_DIR:-/tmp}/test-report-${REPORT_TIMESTAMP}.md}"
    local title="${2:-Claude Flow Git Command Test Report}"
    
    {
        echo "# $title"
        echo ""
        echo "Generated: $(date)"
        echo ""
        
        # Summary table
        echo "## Summary"
        echo ""
        echo "| Metric | Value |"
        echo "|--------|-------|"
        echo "| Total Tests | ${TEST_METRICS[total_tests]:-0} |"
        echo "| ✅ Passed | ${TEST_METRICS[passed_tests]:-0} |"
        echo "| ❌ Failed | ${TEST_METRICS[failed_tests]:-0} |"
        echo "| ⏭️ Skipped | ${TEST_METRICS[skipped_tests]:-0} |"
        
        local total_duration=0
        for duration in "${TEST_TIMINGS[@]}"; do
            ((total_duration += duration))
        done
        echo "| Total Duration | $(format_duration $total_duration) |"
        echo ""
        
        # Performance details
        if [[ ${#TEST_TIMINGS[@]} -gt 0 ]]; then
            echo "## Performance"
            echo ""
            echo "| Test | Duration |"
            echo "|------|----------|"
            
            # Sort by duration
            for test in $(for t in "${!TEST_TIMINGS[@]}"; do echo "$t:${TEST_TIMINGS[$t]}"; done | sort -t: -k2 -rn | cut -d: -f1); do
                echo "| $test | $(format_duration ${TEST_TIMINGS[$test]}) |"
            done
            echo ""
        fi
        
        # Failures
        if [[ ${#TEST_ERRORS[@]} -gt 0 ]]; then
            echo "## Failures"
            echo ""
            
            for test in "${!TEST_ERRORS[@]}"; do
                echo "### $test"
                echo ""
                IFS='|' read -ra error_array <<< "${TEST_ERRORS[$test]}"
                for error in "${error_array[@]}"; do
                    echo "- $error"
                done
                echo ""
            done
        fi
        
        # Warnings
        if [[ ${#TEST_WARNINGS[@]} -gt 0 ]]; then
            echo "## Warnings"
            echo ""
            
            for test in "${!TEST_WARNINGS[@]}"; do
                echo "### $test"
                echo ""
                IFS='|' read -ra warning_array <<< "${TEST_WARNINGS[$test]}"
                for warning in "${warning_array[@]}"; do
                    echo "- ⚠️ $warning"
                done
                echo ""
            done
        fi
        
        # System info
        echo "## Environment"
        echo ""
        echo "- **Hostname:** $REPORT_HOSTNAME"
        echo "- **User:** $REPORT_USER"
        echo "- **Platform:** $(uname -s) $(uname -r)"
        echo "- **Date:** $(date)"
    } > "$output_file"
    
    echo -e "${GREEN}Markdown report saved to: $output_file${NC}"
}

# Summary statistics (simplified)
calculate_test_statistics() {
    local total="${TOTAL_TESTS:-0}"
    local passed="${PASSED_TESTS:-0}"
    local failed="${FAILED_TESTS:-0}"
    local skipped="${SKIPPED_TESTS:-0}"
    
    # Basic validation
    if [[ $total -gt 0 ]]; then
        PASS_RATE=$(format_percentage $passed $total)
        FAIL_RATE=$(format_percentage $failed $total)
        SKIP_RATE=$(format_percentage $skipped $total)
    fi
}

# Export functions for use by other scripts
export -f format_duration
export -f format_percentage
export -f format_bytes
export -f record_test_metric
export -f record_test_timing
export -f record_test_error
export -f record_test_warning
export -f generate_console_report
export -f generate_json_report
export -f generate_junit_xml_report
export -f generate_tap_report
export -f generate_markdown_report
export -f calculate_test_statistics
export -f check_performance_regression