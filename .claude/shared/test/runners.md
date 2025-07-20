# Test Runner Orchestration

This file contains utilities for agent orchestration, parallel execution, and result aggregation across all test commands.

## Agent Orchestration

```bash
# Initialize test runner coordination
initialize_test_coordination() {
    local test_session_id=$1
    local available_agents=${2:-4}
    local coordination_file="/tmp/test-coordination-$test_session_id"
    
    cat > "$coordination_file" <<EOF
{
    "session_id": "$test_session_id",
    "available_agents": $available_agents,
    "active_agents": 0,
    "test_queue": [],
    "completed_tests": [],
    "failed_tests": [],
    "agent_assignments": {},
    "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "status": "initialized"
}
EOF
    
    export TEST_COORDINATION_FILE="$coordination_file"
    echo "$coordination_file"
}

# Assign test to agent
assign_test_to_agent() {
    local agent_id=$1
    local test_file=$2
    local coordination_file=${TEST_COORDINATION_FILE:-}
    
    if [ -z "$coordination_file" ] || [ ! -f "$coordination_file" ]; then
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq ".agent_assignments[\"$agent_id\"] = \"$test_file\" | .active_agents += 1" "$coordination_file" > "$temp_file"
        mv "$temp_file" "$coordination_file"
        echo "Assigned $test_file to agent $agent_id"
    fi
}

# Report test completion
report_test_completion() {
    local agent_id=$1
    local test_file=$2
    local result=$3
    local coordination_file=${TEST_COORDINATION_FILE:-}
    
    if [ -z "$coordination_file" ] || [ ! -f "$coordination_file" ]; then
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        if [ "$result" = "success" ]; then
            jq ".completed_tests += [\"$test_file\"] | .agent_assignments[\"$agent_id\"] = null | .active_agents -= 1" "$coordination_file" > "$temp_file"
        else
            jq ".failed_tests += [\"$test_file\"] | .agent_assignments[\"$agent_id\"] = null | .active_agents -= 1" "$coordination_file" > "$temp_file"
        fi
        mv "$temp_file" "$coordination_file"
    fi
}

# Get next test from queue
get_next_test() {
    local coordination_file=${TEST_COORDINATION_FILE:-}
    
    if [ -z "$coordination_file" ] || [ ! -f "$coordination_file" ]; then
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        local next_test=$(jq -r '.test_queue[0] // empty' "$coordination_file")
        if [ -n "$next_test" ]; then
            local temp_file=$(mktemp)
            jq '.test_queue = .test_queue[1:]' "$coordination_file" > "$temp_file"
            mv "$temp_file" "$coordination_file"
            echo "$next_test"
        fi
    fi
}

# Populate test queue
populate_test_queue() {
    local project_dir=${1:-.}
    local framework=${2:-"auto"}
    local coordination_file=${TEST_COORDINATION_FILE:-}
    
    if [ -z "$coordination_file" ] || [ ! -f "$coordination_file" ]; then
        return 1
    fi
    
    local test_files=$(find_test_files "$project_dir" "$framework")
    
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        local test_array="[]"
        
        while IFS= read -r test_file; do
            if [ -f "$test_file" ]; then
                test_array=$(echo "$test_array" | jq ". + [\"$test_file\"]")
            fi
        done <<< "$test_files"
        
        jq ".test_queue = $test_array" "$coordination_file" > "$temp_file"
        mv "$temp_file" "$coordination_file"
    fi
}
```

## Parallel Execution

```bash
# Execute tests in parallel with agent coordination
execute_tests_parallel() {
    local project_dir=${1:-.}
    local framework=${2:-"auto"}
    local max_agents=${3:-4}
    local test_timeout=${4:-300}
    
    local session_id="test-session-$$"
    local coordination_file=$(initialize_test_coordination "$session_id" "$max_agents")
    
    # Populate test queue
    populate_test_queue "$project_dir" "$framework"
    
    # Start agent processes
    local agent_pids=()
    for ((i=1; i<=max_agents; i++)); do
        start_test_agent "$i" "$framework" "$project_dir" "$test_timeout" &
        agent_pids+=($!)
    done
    
    # Monitor agents
    monitor_test_agents "${agent_pids[@]}"
    
    # Wait for completion
    wait_for_test_completion "$coordination_file"
    
    # Generate results
    generate_parallel_test_results "$coordination_file"
}

# Start individual test agent
start_test_agent() {
    local agent_id=$1
    local framework=$2
    local project_dir=$3
    local test_timeout=$4
    
    echo "Starting test agent $agent_id"
    
    while true; do
        local test_file=$(get_next_test)
        if [ -z "$test_file" ]; then
            echo "Agent $agent_id: No more tests in queue"
            break
        fi
        
        echo "Agent $agent_id: Running $test_file"
        assign_test_to_agent "$agent_id" "$test_file"
        
        # Run test with timeout
        local result_file="/tmp/test-result-$agent_id-$$"
        if timeout "$test_timeout" run_test_file "$test_file" "$framework" "$project_dir" > "$result_file" 2>&1; then
            report_test_completion "$agent_id" "$test_file" "success"
            echo "Agent $agent_id: PASSED $test_file"
        else
            report_test_completion "$agent_id" "$test_file" "failure"
            echo "Agent $agent_id: FAILED $test_file"
        fi
        
        # Store detailed results
        store_test_result "$agent_id" "$test_file" "$result_file"
        rm -f "$result_file"
    done
    
    echo "Agent $agent_id: Finished"
}

# Monitor test agents
monitor_test_agents() {
    local agent_pids=("$@")
    
    while true; do
        local running_agents=0
        for pid in "${agent_pids[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                running_agents=$((running_agents + 1))
            fi
        done
        
        if [ $running_agents -eq 0 ]; then
            break
        fi
        
        echo "Active agents: $running_agents"
        sleep 2
    done
}

# Wait for all tests to complete
wait_for_test_completion() {
    local coordination_file=$1
    local timeout=${2:-1800}  # 30 minutes
    local elapsed=0
    
    while [ $elapsed -lt $timeout ]; do
        if command -v jq >/dev/null 2>&1; then
            local queue_size=$(jq -r '.test_queue | length' "$coordination_file")
            local active_agents=$(jq -r '.active_agents' "$coordination_file")
            
            if [ "$queue_size" -eq 0 ] && [ "$active_agents" -eq 0 ]; then
                echo "All tests completed"
                return 0
            fi
            
            echo "Queue: $queue_size tests, Active: $active_agents agents"
        fi
        
        sleep 5
        elapsed=$((elapsed + 5))
    done
    
    echo "Test execution timeout reached"
    return 1
}
```

## Result Aggregation

```bash
# Store individual test result
store_test_result() {
    local agent_id=$1
    local test_file=$2
    local result_file=$3
    
    local results_dir="/tmp/test-results-$$"
    mkdir -p "$results_dir"
    
    local sanitized_test=$(echo "$test_file" | tr '/' '_' | tr '.' '_')
    local stored_result="$results_dir/agent-$agent_id-$sanitized_test.result"
    
    cat > "$stored_result" <<EOF
{
    "agent_id": "$agent_id",
    "test_file": "$test_file",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "output": $(cat "$result_file" | jq -Rs .)
}
EOF
}

# Aggregate all test results
aggregate_test_results() {
    local results_dir="/tmp/test-results-$$"
    local coordination_file=${TEST_COORDINATION_FILE:-}
    
    if [ ! -d "$results_dir" ]; then
        echo "ERROR: Results directory not found"
        return 1
    fi
    
    local aggregated_results="/tmp/aggregated-results-$$.json"
    
    if command -v jq >/dev/null 2>&1; then
        # Start with coordination data
        cp "$coordination_file" "$aggregated_results"
        
        # Add individual test results
        local test_results="[]"
        for result_file in "$results_dir"/*.result; do
            if [ -f "$result_file" ]; then
                local result_data=$(cat "$result_file")
                test_results=$(echo "$test_results" | jq ". + [$result_data]")
            fi
        done
        
        # Merge with coordination data
        jq ".test_results = $test_results" "$aggregated_results" > "$aggregated_results.tmp"
        mv "$aggregated_results.tmp" "$aggregated_results"
        
        echo "$aggregated_results"
    fi
}

# Generate parallel test results summary
generate_parallel_test_results() {
    local coordination_file=$1
    
    if [ ! -f "$coordination_file" ]; then
        echo "ERROR: Coordination file not found"
        return 1
    fi
    
    local results_file=$(aggregate_test_results)
    
    if command -v jq >/dev/null 2>&1; then
        local total_tests=$(jq -r '.completed_tests | length' "$coordination_file")
        local failed_tests=$(jq -r '.failed_tests | length' "$coordination_file")
        local passed_tests=$((total_tests - failed_tests))
        local start_time=$(jq -r '.started_at' "$coordination_file")
        local end_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        
        echo "=== Parallel Test Execution Results ==="
        echo "Total Tests: $total_tests"
        echo "Passed: $passed_tests"
        echo "Failed: $failed_tests"
        echo "Success Rate: $(echo "scale=2; $passed_tests * 100 / $total_tests" | bc 2>/dev/null || echo "0")%"
        echo "Start Time: $start_time"
        echo "End Time: $end_time"
        echo "Duration: $(calculate_duration "$start_time" "$end_time")"
        
        if [ $failed_tests -gt 0 ]; then
            echo ""
            echo "Failed Tests:"
            jq -r '.failed_tests[]' "$coordination_file" | while read -r failed_test; do
                echo "  - $failed_test"
            done
        fi
    fi
}
```

## Load Balancing

```bash
# Load balancer for test distribution
balance_test_load() {
    local test_files=("$@")
    local agent_count=${#test_files[@]}
    
    # Sort tests by estimated execution time (file size as proxy)
    local sorted_tests=()
    for test_file in "${test_files[@]}"; do
        local size=$(stat -f%z "$test_file" 2>/dev/null || stat -c%s "$test_file" 2>/dev/null || echo 0)
        sorted_tests+=("$size:$test_file")
    done
    
    # Sort by size (descending)
    IFS=$'\n' sorted_tests=($(sort -rn <<< "${sorted_tests[*]}"))
    
    # Distribute tests to agents using round-robin
    local agent_assignments=()
    for ((i=0; i<agent_count; i++)); do
        agent_assignments+=("")
    done
    
    local current_agent=0
    for test_entry in "${sorted_tests[@]}"; do
        local test_file="${test_entry#*:}"
        agent_assignments[$current_agent]="${agent_assignments[$current_agent]}$test_file\n"
        current_agent=$(((current_agent + 1) % agent_count))
    done
    
    # Output agent assignments
    for ((i=0; i<agent_count; i++)); do
        echo "Agent $((i+1)):"
        echo -e "${agent_assignments[$i]}" | grep -v '^$'
        echo ""
    done
}

# Agent health monitoring
monitor_agent_health() {
    local agent_id=$1
    local coordination_file=${TEST_COORDINATION_FILE:-}
    
    if [ -z "$coordination_file" ] || [ ! -f "$coordination_file" ]; then
        return 1
    fi
    
    while true; do
        # Check if agent is still active
        if command -v jq >/dev/null 2>&1; then
            local current_test=$(jq -r ".agent_assignments[\"$agent_id\"] // empty" "$coordination_file")
            local last_update=$(jq -r ".agent_health[\"$agent_id\"].last_update // empty" "$coordination_file")
            
            if [ -n "$current_test" ]; then
                # Update health status
                local temp_file=$(mktemp)
                local current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
                jq ".agent_health[\"$agent_id\"] = {\"status\": \"active\", \"current_test\": \"$current_test\", \"last_update\": \"$current_time\"}" "$coordination_file" > "$temp_file"
                mv "$temp_file" "$coordination_file"
            fi
        fi
        
        sleep 10
    done
}

# Cleanup coordination resources
cleanup_test_coordination() {
    local coordination_file=${TEST_COORDINATION_FILE:-}
    
    if [ -n "$coordination_file" ] && [ -f "$coordination_file" ]; then
        # Generate final report
        generate_parallel_test_results "$coordination_file"
        
        # Cleanup temporary files
        rm -f "$coordination_file"
        rm -rf "/tmp/test-results-$$"
        
        echo "Test coordination cleanup completed"
    fi
}
```