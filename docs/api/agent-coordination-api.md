# Claude Code Enhancer Agent Coordination API

Comprehensive reference for the agent coordination system in Claude Code Enhancer, enabling parallel task execution and intelligent workload distribution.

## Table of Contents

- [Overview](#overview)
- [Agent Architecture](#agent-architecture)
- [Agent Lifecycle](#agent-lifecycle)
- [Agent Communication](#agent-communication)
- [Agent Spawning API](#agent-spawning-api)
- [Coordination Strategies](#coordination-strategies)
- [Task Distribution](#task-distribution)
- [Agent Synchronization](#agent-synchronization)
- [Resource Management](#resource-management)
- [Error Handling and Recovery](#error-handling-and-recovery)
- [Monitoring and Debugging](#monitoring-and-debugging)
- [Performance Optimization](#performance-optimization)
- [Security Considerations](#security-considerations)
- [Integration Patterns](#integration-patterns)
- [Best Practices](#best-practices)

## Overview

The Claude Code Enhancer agent coordination system enables efficient parallel execution of tasks by managing multiple intelligent agents that can work independently while coordinating their activities through a sophisticated communication and synchronization framework.

### Agent System Architecture

```
┌─────────────────────┐
│  Coordination Hub   │  ←── Central coordination and management
├─────────────────────┤
│  ┌─────┐ ┌─────┐   │
│  │ Ag1 │ │ Ag2 │   │  ←── Active agents with specific tasks
│  └─────┘ └─────┘   │
│  ┌─────┐ ┌─────┐   │
│  │ Ag3 │ │ Ag4 │   │  ←── Agent pool for dynamic scaling
│  └─────┘ └─────┘   │
├─────────────────────┤
│  Message Bus        │  ←── Inter-agent communication
├─────────────────────┤
│  Resource Manager   │  ←── Resource allocation and monitoring
├─────────────────────┤
│  Task Scheduler     │  ←── Work distribution and prioritization
└─────────────────────┘
```

### Key Capabilities

| Feature | Description | Use Cases |
|---------|-------------|-----------|
| **Parallel Execution** | Multiple agents working simultaneously | Large codebases, complex analysis |
| **Dynamic Scaling** | Agents spawned/terminated based on workload | Resource optimization |
| **Intelligent Distribution** | Smart task allocation based on agent capabilities | Specialized processing |
| **Fault Tolerance** | Automatic recovery and task reassignment | High availability |
| **Resource Awareness** | CPU, memory, and I/O monitoring | Performance optimization |

## Agent Architecture

### Agent Types

#### Primary Agent (Orchestrator)
```yaml
primary_agent:
  role: "orchestrator"
  responsibilities:
    - coordination_hub
    - task_distribution
    - result_aggregation
    - error_recovery
  capabilities:
    - spawn_agents
    - manage_lifecycle
    - monitor_resources
    - coordinate_tasks
```

#### Worker Agents (Specialized)
```yaml
worker_agents:
  file_analyzer:
    role: "analyzer"
    specialization: "file_analysis"
    capabilities: ["syntax_analysis", "dependency_scanning", "metrics_calculation"]
    resource_requirements:
      cpu: "moderate"
      memory: "low"
      io: "high"
      
  template_processor:
    role: "processor"
    specialization: "template_processing"
    capabilities: ["template_rendering", "file_generation", "validation"]
    resource_requirements:
      cpu: "high"
      memory: "moderate"
      io: "moderate"
      
  quality_checker:
    role: "validator"
    specialization: "quality_assurance"
    capabilities: ["linting", "testing", "security_scanning"]
    resource_requirements:
      cpu: "high"
      memory: "moderate"
      io: "low"
      
  git_integrator:
    role: "integrator"
    specialization: "git_operations"
    capabilities: ["commit_analysis", "branch_management", "merge_operations"]
    resource_requirements:
      cpu: "low"
      memory: "low"
      io: "moderate"
```

### Agent State Management

```javascript
// Agent state machine
const AgentStates = {
  INITIALIZING: 'initializing',
  IDLE: 'idle',
  ASSIGNED: 'assigned',
  WORKING: 'working',
  COMMUNICATING: 'communicating',
  WAITING: 'waiting',
  COMPLETING: 'completing',
  ERROR: 'error',
  TERMINATING: 'terminating'
};

const StateTransitions = {
  [AgentStates.INITIALIZING]: [AgentStates.IDLE, AgentStates.ERROR],
  [AgentStates.IDLE]: [AgentStates.ASSIGNED, AgentStates.TERMINATING],
  [AgentStates.ASSIGNED]: [AgentStates.WORKING, AgentStates.ERROR],
  [AgentStates.WORKING]: [AgentStates.COMMUNICATING, AgentStates.WAITING, AgentStates.COMPLETING, AgentStates.ERROR],
  [AgentStates.COMMUNICATING]: [AgentStates.WORKING, AgentStates.WAITING, AgentStates.ERROR],
  [AgentStates.WAITING]: [AgentStates.WORKING, AgentStates.COMPLETING, AgentStates.ERROR],
  [AgentStates.COMPLETING]: [AgentStates.IDLE, AgentStates.TERMINATING],
  [AgentStates.ERROR]: [AgentStates.IDLE, AgentStates.TERMINATING],
  [AgentStates.TERMINATING]: []
};
```

## Agent Lifecycle

### Agent Initialization

```bash
#!/bin/bash
# Agent initialization script

initialize_agent() {
    local agent_id="$1"
    local agent_type="$2"
    local config_file="$3"
    
    # Set up agent environment
    export CLAUDE_AGENT_ID="$agent_id"
    export CLAUDE_AGENT_TYPE="$agent_type"
    export CLAUDE_AGENT_CONFIG="$config_file"
    export CLAUDE_AGENT_WORKSPACE="${CLAUDE_CACHE_DIR}/agents/${agent_id}"
    
    # Create agent workspace
    mkdir -p "$CLAUDE_AGENT_WORKSPACE"
    
    # Initialize communication channels
    setup_communication_channels "$agent_id"
    
    # Load agent configuration
    load_agent_config "$config_file"
    
    # Register with coordination hub
    register_with_hub "$agent_id" "$agent_type"
    
    # Start agent main loop
    start_agent_loop
}

setup_communication_channels() {
    local agent_id="$1"
    local comm_dir="${CLAUDE_CACHE_DIR}/communication"
    
    mkdir -p "$comm_dir/incoming/$agent_id"
    mkdir -p "$comm_dir/outgoing/$agent_id"
    mkdir -p "$comm_dir/broadcast"
    
    # Create named pipes for real-time communication
    mkfifo "$comm_dir/pipes/to_$agent_id" 2>/dev/null || true
    mkfifo "$comm_dir/pipes/from_$agent_id" 2>/dev/null || true
    
    export CLAUDE_AGENT_INBOX="$comm_dir/incoming/$agent_id"
    export CLAUDE_AGENT_OUTBOX="$comm_dir/outgoing/$agent_id"
    export CLAUDE_AGENT_PIPE_IN="$comm_dir/pipes/to_$agent_id"
    export CLAUDE_AGENT_PIPE_OUT="$comm_dir/pipes/from_$agent_id"
}

load_agent_config() {
    local config_file="$1"
    
    if [[ -f "$config_file" ]]; then
        # Load YAML configuration
        eval "$(yq eval '. as $item ireduce ({}; . *+ $item)' "$config_file" | \
               yq eval '. | to_entries | .[] | "export AGENT_" + (.key | upcase) + "=\"" + (.value | tostring) + "\""')"
    fi
    
    # Set defaults
    export AGENT_TIMEOUT="${AGENT_TIMEOUT:-300}"
    export AGENT_MAX_TASKS="${AGENT_MAX_TASKS:-10}"
    export AGENT_HEARTBEAT_INTERVAL="${AGENT_HEARTBEAT_INTERVAL:-30}"
}

register_with_hub() {
    local agent_id="$1"
    local agent_type="$2"
    
    local registration_data
    registration_data=$(cat <<EOF
{
  "agent_id": "$agent_id",
  "agent_type": "$agent_type",
  "pid": $$,
  "hostname": "$(hostname)",
  "capabilities": $(get_agent_capabilities),
  "resource_limits": $(get_resource_limits),
  "startup_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "initializing"
}
EOF
    )
    
    echo "$registration_data" > "${CLAUDE_CACHE_DIR}/agents/registry/$agent_id.json"
    
    # Send registration message
    send_message "hub" "agent_registration" "$registration_data"
}

get_agent_capabilities() {
    case "$CLAUDE_AGENT_TYPE" in
        "file_analyzer")
            echo '["file_analysis", "syntax_checking", "metrics_calculation"]'
            ;;
        "template_processor")
            echo '["template_rendering", "file_generation", "validation"]'
            ;;
        "quality_checker")
            echo '["linting", "testing", "security_scanning"]'
            ;;
        "git_integrator")
            echo '["git_operations", "commit_analysis", "branch_management"]'
            ;;
        *)
            echo '["general_purpose"]'
            ;;
    esac
}

get_resource_limits() {
    cat <<EOF
{
  "max_memory": "${AGENT_MAX_MEMORY:-1G}",
  "max_cpu_percent": ${AGENT_MAX_CPU:-80},
  "max_file_handles": ${AGENT_MAX_FILES:-1000},
  "max_processes": ${AGENT_MAX_PROCESSES:-10}
}
EOF
}
```

### Agent Main Loop

```bash
#!/bin/bash
# Agent main execution loop

start_agent_loop() {
    log_agent "info" "Starting agent main loop"
    
    # Set up signal handlers
    trap 'handle_shutdown' TERM INT
    trap 'handle_heartbeat' USR1
    
    # Update status
    update_agent_status "idle"
    
    # Main loop
    while true; do
        # Check for shutdown signal
        if [[ -f "$CLAUDE_AGENT_WORKSPACE/shutdown" ]]; then
            break
        fi
        
        # Process incoming messages
        process_messages
        
        # Check for new tasks
        check_for_tasks
        
        # Send heartbeat
        send_heartbeat
        
        # Monitor resources
        monitor_resources
        
        # Brief sleep to prevent busy waiting
        sleep 1
    done
    
    # Cleanup and shutdown
    cleanup_agent
}

process_messages() {
    local message_files
    message_files=$(find "$CLAUDE_AGENT_INBOX" -name "*.json" -type f 2>/dev/null | sort)
    
    for message_file in $message_files; do
        if [[ -f "$message_file" ]]; then
            process_single_message "$message_file"
            rm -f "$message_file"
        fi
    done
}

process_single_message() {
    local message_file="$1"
    local message_type
    local message_data
    
    message_type=$(jq -r '.type' "$message_file" 2>/dev/null)
    message_data=$(jq -r '.data' "$message_file" 2>/dev/null)
    
    case "$message_type" in
        "task_assignment")
            handle_task_assignment "$message_data"
            ;;
        "coordination_request")
            handle_coordination_request "$message_data"
            ;;
        "status_request")
            handle_status_request "$message_data"
            ;;
        "shutdown")
            handle_shutdown_request "$message_data"
            ;;
        "resource_limit")
            handle_resource_limit_update "$message_data"
            ;;
        *)
            log_agent "warning" "Unknown message type: $message_type"
            ;;
    esac
}

check_for_tasks() {
    if [[ "$AGENT_STATUS" == "idle" ]]; then
        # Check task queue
        local task_queue="${CLAUDE_CACHE_DIR}/tasks/queue"
        local available_task
        
        available_task=$(find "$task_queue" -name "*.json" -type f | head -1 2>/dev/null)
        
        if [[ -n "$available_task" ]]; then
            # Claim the task
            local task_id
            task_id=$(basename "$available_task" .json)
            
            if claim_task "$task_id"; then
                execute_task "$available_task"
            fi
        fi
    fi
}

send_heartbeat() {
    local current_time
    current_time=$(date +%s)
    local last_heartbeat
    last_heartbeat=$(cat "$CLAUDE_AGENT_WORKSPACE/last_heartbeat" 2>/dev/null || echo 0)
    
    if [[ $((current_time - last_heartbeat)) -ge $AGENT_HEARTBEAT_INTERVAL ]]; then
        local heartbeat_data
        heartbeat_data=$(cat <<EOF
{
  "agent_id": "$CLAUDE_AGENT_ID",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "$AGENT_STATUS",
  "current_task": "$AGENT_CURRENT_TASK",
  "resource_usage": $(get_current_resource_usage),
  "task_count": $AGENT_TASK_COUNT
}
EOF
        )
        
        send_message "hub" "heartbeat" "$heartbeat_data"
        echo "$current_time" > "$CLAUDE_AGENT_WORKSPACE/last_heartbeat"
    fi
}

monitor_resources() {
    local memory_usage
    local cpu_usage
    local file_handles
    
    # Get current resource usage
    memory_usage=$(ps -o rss= -p $$ | awk '{print $1}')  # in KB
    cpu_usage=$(ps -o %cpu= -p $$)
    file_handles=$(lsof -p $$ 2>/dev/null | wc -l)
    
    # Check limits
    local max_memory_kb
    max_memory_kb=$(echo "$AGENT_MAX_MEMORY" | sed 's/G/*1024*1024/; s/M/*1024/; s/K//' | bc)
    
    if [[ $memory_usage -gt $max_memory_kb ]]; then
        log_agent "warning" "Memory usage ($memory_usage KB) exceeds limit ($max_memory_kb KB)"
        request_resource_adjustment "memory" "$memory_usage"
    fi
    
    if [[ $(echo "$cpu_usage > $AGENT_MAX_CPU" | bc) -eq 1 ]]; then
        log_agent "warning" "CPU usage ($cpu_usage%) exceeds limit ($AGENT_MAX_CPU%)"
        request_resource_adjustment "cpu" "$cpu_usage"
    fi
}

get_current_resource_usage() {
    local memory_usage
    local cpu_usage
    local file_handles
    
    memory_usage=$(ps -o rss= -p $$ | awk '{print $1}')
    cpu_usage=$(ps -o %cpu= -p $$)
    file_handles=$(lsof -p $$ 2>/dev/null | wc -l)
    
    cat <<EOF
{
  "memory_kb": $memory_usage,
  "cpu_percent": $cpu_usage,
  "file_handles": $file_handles,
  "uptime": $(($(date +%s) - AGENT_START_TIME))
}
EOF
}
```

## Agent Communication

### Message Passing System

```bash
#!/bin/bash
# Agent communication utilities

send_message() {
    local recipient="$1"
    local message_type="$2"
    local message_data="$3"
    local priority="${4:-normal}"
    
    local message_id
    message_id="msg_$(date +%s%N)_$$"
    
    local message
    message=$(cat <<EOF
{
  "id": "$message_id",
  "sender": "$CLAUDE_AGENT_ID",
  "recipient": "$recipient",
  "type": "$message_type",
  "priority": "$priority",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "data": $message_data
}
EOF
    )
    
    # Determine delivery method
    case "$recipient" in
        "hub")
            deliver_to_hub "$message"
            ;;
        "broadcast")
            deliver_broadcast "$message"
            ;;
        agent_*)
            deliver_to_agent "$recipient" "$message"
            ;;
        *)
            log_agent "error" "Unknown recipient: $recipient"
            return 1
            ;;
    esac
    
    log_agent "debug" "Message sent to $recipient: $message_type"
}

deliver_to_hub() {
    local message="$1"
    local hub_inbox="${CLAUDE_CACHE_DIR}/communication/hub/inbox"
    
    echo "$message" > "$hub_inbox/$(date +%s%N).json"
}

deliver_broadcast() {
    local message="$1"
    local broadcast_dir="${CLAUDE_CACHE_DIR}/communication/broadcast"
    
    echo "$message" > "$broadcast_dir/$(date +%s%N).json"
}

deliver_to_agent() {
    local recipient="$1"
    local message="$2"
    local agent_inbox="${CLAUDE_CACHE_DIR}/communication/incoming/$recipient"
    
    if [[ -d "$agent_inbox" ]]; then
        echo "$message" > "$agent_inbox/$(date +%s%N).json"
    else
        log_agent "warning" "Agent inbox not found: $recipient"
        return 1
    fi
}

# Real-time communication via named pipes
send_realtime_message() {
    local recipient="$1"
    local message="$2"
    local pipe_path="${CLAUDE_CACHE_DIR}/communication/pipes/to_$recipient"
    
    if [[ -p "$pipe_path" ]]; then
        echo "$message" > "$pipe_path" &
        local pipe_pid=$!
        
        # Timeout after 5 seconds
        sleep 5 && kill $pipe_pid 2>/dev/null &
        local timeout_pid=$!
        
        wait $pipe_pid 2>/dev/null
        local result=$?
        
        kill $timeout_pid 2>/dev/null
        return $result
    else
        log_agent "warning" "Real-time pipe not found: $recipient"
        return 1
    fi
}

# Request-response pattern
send_request() {
    local recipient="$1"
    local request_type="$2"
    local request_data="$3"
    local timeout="${4:-30}"
    
    local request_id
    request_id="req_$(date +%s%N)_$$"
    local response_file="$CLAUDE_AGENT_WORKSPACE/responses/$request_id.json"
    
    mkdir -p "$(dirname "$response_file")"
    
    # Send request with response callback
    local request_message
    request_message=$(cat <<EOF
{
  "request_id": "$request_id",
  "response_file": "$response_file",
  "timeout": $timeout,
  "request_data": $request_data
}
EOF
    )
    
    send_message "$recipient" "$request_type" "$request_message" "high"
    
    # Wait for response
    local end_time
    end_time=$(($(date +%s) + timeout))
    
    while [[ $(date +%s) -lt $end_time ]]; do
        if [[ -f "$response_file" ]]; then
            cat "$response_file"
            rm -f "$response_file"
            return 0
        fi
        sleep 1
    done
    
    log_agent "warning" "Request timeout: $request_id"
    rm -f "$response_file"
    return 1
}

send_response() {
    local request_id="$1"
    local response_file="$2"
    local response_data="$3"
    
    local response
    response=$(cat <<EOF
{
  "request_id": "$request_id",
  "responder": "$CLAUDE_AGENT_ID",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "response_data": $response_data
}
EOF
    )
    
    echo "$response" > "$response_file"
    log_agent "debug" "Response sent for request: $request_id"
}
```

### Event Broadcasting System

```bash
#!/bin/bash
# Event broadcasting and subscription system

subscribe_to_events() {
    local event_types=("$@")
    local subscription_file="$CLAUDE_AGENT_WORKSPACE/subscriptions.json"
    
    local subscriptions
    subscriptions=$(printf '%s\n' "${event_types[@]}" | jq -R . | jq -s .)
    
    echo "$subscriptions" > "$subscription_file"
    
    # Register subscriptions with hub
    local subscription_data
    subscription_data=$(cat <<EOF
{
  "agent_id": "$CLAUDE_AGENT_ID",
  "subscriptions": $subscriptions
}
EOF
    )
    
    send_message "hub" "event_subscription" "$subscription_data"
}

broadcast_event() {
    local event_type="$1"
    local event_data="$2"
    local scope="${3:-global}"
    
    local event_message
    event_message=$(cat <<EOF
{
  "event_type": "$event_type",
  "source": "$CLAUDE_AGENT_ID",
  "scope": "$scope",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "event_data": $event_data
}
EOF
    )
    
    case "$scope" in
        "global")
            send_message "broadcast" "event" "$event_message"
            ;;
        "local")
            # Send to agents in same project
            broadcast_to_local_agents "$event_message"
            ;;
        "type")
            # Send to agents of same type
            broadcast_to_agent_type "$event_message"
            ;;
    esac
}

handle_event() {
    local event_message="$1"
    local event_type
    local event_data
    local source
    
    event_type=$(echo "$event_message" | jq -r '.event_type')
    event_data=$(echo "$event_message" | jq -r '.event_data')
    source=$(echo "$event_message" | jq -r '.source')
    
    # Check if subscribed to this event type
    local subscriptions
    subscriptions=$(cat "$CLAUDE_AGENT_WORKSPACE/subscriptions.json" 2>/dev/null || echo '[]')
    
    if echo "$subscriptions" | jq -e ". | index(\"$event_type\")" >/dev/null; then
        log_agent "debug" "Processing event: $event_type from $source"
        process_event "$event_type" "$event_data" "$source"
    fi
}

process_event() {
    local event_type="$1"
    local event_data="$2"
    local source="$3"
    
    case "$event_type" in
        "task_completed")
            handle_task_completed_event "$event_data" "$source"
            ;;
        "resource_available")
            handle_resource_available_event "$event_data" "$source"
            ;;
        "agent_error")
            handle_agent_error_event "$event_data" "$source"
            ;;
        "coordination_required")
            handle_coordination_required_event "$event_data" "$source"
            ;;
        "shutdown_initiated")
            handle_shutdown_initiated_event "$event_data" "$source"
            ;;
        *)
            log_agent "warning" "Unknown event type: $event_type"
            ;;
    esac
}
```

## Agent Spawning API

### Dynamic Agent Creation

```python
#!/usr/bin/env python3
"""Agent spawning and management system."""

import json
import subprocess
import time
import os
from typing import Dict, List, Optional, Any
from dataclasses import dataclass
from enum import Enum

class AgentType(Enum):
    FILE_ANALYZER = "file_analyzer"
    TEMPLATE_PROCESSOR = "template_processor"
    QUALITY_CHECKER = "quality_checker"
    GIT_INTEGRATOR = "git_integrator"
    GENERAL_PURPOSE = "general_purpose"

@dataclass
class AgentConfig:
    agent_type: AgentType
    max_memory: str = "1G"
    max_cpu_percent: int = 80
    timeout: int = 300
    capabilities: List[str] = None
    environment: Dict[str, str] = None

@dataclass
class AgentInfo:
    agent_id: str
    agent_type: AgentType
    pid: int
    status: str
    spawn_time: float
    last_heartbeat: float
    resource_usage: Dict[str, Any]
    task_count: int

class AgentCoordinator:
    """Main agent coordination system."""
    
    def __init__(self, config_dir: str, cache_dir: str):
        self.config_dir = config_dir
        self.cache_dir = cache_dir
        self.agents: Dict[str, AgentInfo] = {}
        self.agent_counter = 0
        self.max_agents = int(os.environ.get('CLAUDE_AGENT_LIMIT', '5'))
        
        # Set up communication directories
        self.setup_communication_infrastructure()
        
    def setup_communication_infrastructure(self):
        """Set up communication directories and files."""
        comm_dirs = [
            f"{self.cache_dir}/communication/hub/inbox",
            f"{self.cache_dir}/communication/broadcast",
            f"{self.cache_dir}/communication/incoming",
            f"{self.cache_dir}/communication/outgoing",
            f"{self.cache_dir}/communication/pipes",
            f"{self.cache_dir}/agents/registry",
            f"{self.cache_dir}/tasks/queue",
            f"{self.cache_dir}/tasks/completed"
        ]
        
        for dir_path in comm_dirs:
            os.makedirs(dir_path, exist_ok=True)
    
    def spawn_agent(self, config: AgentConfig) -> Optional[str]:
        """Spawn a new agent with given configuration."""
        
        # Check agent limits
        if len(self.agents) >= self.max_agents:
            print(f"Agent limit reached ({self.max_agents})")
            return None
        
        # Generate unique agent ID
        self.agent_counter += 1
        agent_id = f"agent_{config.agent_type.value}_{self.agent_counter}_{int(time.time())}"
        
        # Create agent configuration file
        config_file = self.create_agent_config_file(agent_id, config)
        
        # Spawn agent process
        pid = self.start_agent_process(agent_id, config.agent_type.value, config_file)
        
        if pid:
            # Register agent
            agent_info = AgentInfo(
                agent_id=agent_id,
                agent_type=config.agent_type,
                pid=pid,
                status="initializing",
                spawn_time=time.time(),
                last_heartbeat=time.time(),
                resource_usage={},
                task_count=0
            )
            
            self.agents[agent_id] = agent_info
            print(f"Agent spawned: {agent_id} (PID: {pid})")
            return agent_id
        
        return None
    
    def create_agent_config_file(self, agent_id: str, config: AgentConfig) -> str:
        """Create configuration file for agent."""
        
        config_data = {
            "agent_id": agent_id,
            "agent_type": config.agent_type.value,
            "timeout": config.timeout,
            "max_memory": config.max_memory,
            "max_cpu_percent": config.max_cpu_percent,
            "capabilities": config.capabilities or self.get_default_capabilities(config.agent_type),
            "environment": config.environment or {}
        }
        
        config_file = f"{self.cache_dir}/agents/configs/{agent_id}.json"
        os.makedirs(os.path.dirname(config_file), exist_ok=True)
        
        with open(config_file, 'w') as f:
            json.dump(config_data, f, indent=2)
        
        return config_file
    
    def get_default_capabilities(self, agent_type: AgentType) -> List[str]:
        """Get default capabilities for agent type."""
        
        capabilities_map = {
            AgentType.FILE_ANALYZER: ["file_analysis", "syntax_checking", "metrics_calculation"],
            AgentType.TEMPLATE_PROCESSOR: ["template_rendering", "file_generation", "validation"],
            AgentType.QUALITY_CHECKER: ["linting", "testing", "security_scanning"],
            AgentType.GIT_INTEGRATOR: ["git_operations", "commit_analysis", "branch_management"],
            AgentType.GENERAL_PURPOSE: ["general_tasks", "file_operations", "basic_analysis"]
        }
        
        return capabilities_map.get(agent_type, ["general_tasks"])
    
    def start_agent_process(self, agent_id: str, agent_type: str, config_file: str) -> Optional[int]:
        """Start agent process."""
        
        # Agent script path
        agent_script = f"{os.path.dirname(__file__)}/agent_worker.sh"
        
        # Environment for agent
        env = os.environ.copy()
        env.update({
            'CLAUDE_AGENT_ID': agent_id,
            'CLAUDE_AGENT_TYPE': agent_type,
            'CLAUDE_AGENT_CONFIG': config_file,
            'CLAUDE_CACHE_DIR': self.cache_dir,
            'CLAUDE_CONFIG_DIR': self.config_dir
        })
        
        try:
            # Start agent process
            process = subprocess.Popen(
                ['/bin/bash', agent_script],
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                start_new_session=True
            )
            
            return process.pid
            
        except Exception as e:
            print(f"Failed to start agent process: {e}")
            return None
    
    def terminate_agent(self, agent_id: str, timeout: int = 30) -> bool:
        """Terminate an agent gracefully."""
        
        if agent_id not in self.agents:
            print(f"Agent not found: {agent_id}")
            return False
        
        agent = self.agents[agent_id]
        
        # Send shutdown signal
        shutdown_message = {
            "type": "shutdown",
            "data": {
                "timeout": timeout,
                "reason": "coordinator_request"
            }
        }
        
        self.send_message_to_agent(agent_id, shutdown_message)
        
        # Wait for graceful shutdown
        start_time = time.time()
        while time.time() - start_time < timeout:
            if not self.is_agent_alive(agent.pid):
                break
            time.sleep(1)
        
        # Force kill if still alive
        if self.is_agent_alive(agent.pid):
            try:
                os.kill(agent.pid, 9)  # SIGKILL
                print(f"Force killed agent: {agent_id}")
            except ProcessLookupError:
                pass  # Already dead
        
        # Clean up
        self.cleanup_agent(agent_id)
        del self.agents[agent_id]
        
        print(f"Agent terminated: {agent_id}")
        return True
    
    def is_agent_alive(self, pid: int) -> bool:
        """Check if agent process is still alive."""
        try:
            os.kill(pid, 0)  # Signal 0 checks if process exists
            return True
        except ProcessLookupError:
            return False
    
    def cleanup_agent(self, agent_id: str):
        """Clean up agent resources."""
        
        # Remove agent files
        agent_files = [
            f"{self.cache_dir}/agents/configs/{agent_id}.json",
            f"{self.cache_dir}/agents/registry/{agent_id}.json",
            f"{self.cache_dir}/communication/incoming/{agent_id}",
            f"{self.cache_dir}/communication/outgoing/{agent_id}",
            f"{self.cache_dir}/communication/pipes/to_{agent_id}",
            f"{self.cache_dir}/communication/pipes/from_{agent_id}"
        ]
        
        for file_path in agent_files:
            try:
                if os.path.isdir(file_path):
                    import shutil
                    shutil.rmtree(file_path)
                elif os.path.exists(file_path):
                    os.unlink(file_path)
            except OSError:
                pass  # Ignore cleanup errors
    
    def assign_task(self, task_data: Dict[str, Any], agent_type: Optional[AgentType] = None) -> Optional[str]:
        """Assign task to appropriate agent."""
        
        # Find suitable agent
        suitable_agents = self.find_suitable_agents(task_data, agent_type)
        
        if not suitable_agents:
            # Spawn new agent if needed and possible
            if len(self.agents) < self.max_agents:
                target_type = agent_type or self.determine_best_agent_type(task_data)
                config = AgentConfig(agent_type=target_type)
                agent_id = self.spawn_agent(config)
                
                if agent_id:
                    # Wait for agent to initialize
                    time.sleep(2)
                    suitable_agents = [agent_id]
            
            if not suitable_agents:
                print("No suitable agents available")
                return None
        
        # Select best agent (least loaded)
        selected_agent = self.select_best_agent(suitable_agents)
        
        # Create task assignment
        task_assignment = {
            "type": "task_assignment",
            "data": {
                "task_id": f"task_{int(time.time())}_{len(task_data)}",
                "task_data": task_data,
                "assigned_at": time.time()
            }
        }
        
        # Send task to agent
        if self.send_message_to_agent(selected_agent, task_assignment):
            self.agents[selected_agent].task_count += 1
            print(f"Task assigned to agent: {selected_agent}")
            return selected_agent
        
        return None
    
    def find_suitable_agents(self, task_data: Dict[str, Any], agent_type: Optional[AgentType] = None) -> List[str]:
        """Find agents suitable for the task."""
        
        suitable = []
        required_capabilities = task_data.get('required_capabilities', [])
        
        for agent_id, agent in self.agents.items():
            # Check agent type match
            if agent_type and agent.agent_type != agent_type:
                continue
            
            # Check if agent is available
            if agent.status not in ['idle', 'working']:
                continue
            
            # Check capabilities
            agent_config = self.get_agent_config(agent_id)
            agent_capabilities = agent_config.get('capabilities', [])
            
            if required_capabilities:
                if not all(cap in agent_capabilities for cap in required_capabilities):
                    continue
            
            suitable.append(agent_id)
        
        return suitable
    
    def determine_best_agent_type(self, task_data: Dict[str, Any]) -> AgentType:
        """Determine best agent type for task."""
        
        task_type = task_data.get('type', '')
        
        type_mapping = {
            'file_analysis': AgentType.FILE_ANALYZER,
            'template_processing': AgentType.TEMPLATE_PROCESSOR,
            'quality_check': AgentType.QUALITY_CHECKER,
            'git_operation': AgentType.GIT_INTEGRATOR
        }
        
        return type_mapping.get(task_type, AgentType.GENERAL_PURPOSE)
    
    def select_best_agent(self, agent_ids: List[str]) -> str:
        """Select best agent from candidates based on load."""
        
        if len(agent_ids) == 1:
            return agent_ids[0]
        
        # Select agent with lowest task count
        best_agent = min(agent_ids, key=lambda aid: self.agents[aid].task_count)
        return best_agent
    
    def send_message_to_agent(self, agent_id: str, message: Dict[str, Any]) -> bool:
        """Send message to specific agent."""
        
        inbox_path = f"{self.cache_dir}/communication/incoming/{agent_id}"
        
        if not os.path.exists(inbox_path):
            print(f"Agent inbox not found: {agent_id}")
            return False
        
        message_file = f"{inbox_path}/{int(time.time() * 1000000)}.json"
        
        try:
            with open(message_file, 'w') as f:
                json.dump(message, f)
            return True
        except Exception as e:
            print(f"Failed to send message to agent {agent_id}: {e}")
            return False
    
    def get_agent_config(self, agent_id: str) -> Dict[str, Any]:
        """Get agent configuration."""
        
        config_file = f"{self.cache_dir}/agents/configs/{agent_id}.json"
        
        try:
            with open(config_file, 'r') as f:
                return json.load(f)
        except Exception:
            return {}
    
    def monitor_agents(self):
        """Monitor agent health and performance."""
        
        current_time = time.time()
        dead_agents = []
        
        for agent_id, agent in self.agents.items():
            # Check if process is alive
            if not self.is_agent_alive(agent.pid):
                print(f"Agent process died: {agent_id}")
                dead_agents.append(agent_id)
                continue
            
            # Check heartbeat timeout
            if current_time - agent.last_heartbeat > 60:  # 1 minute timeout
                print(f"Agent heartbeat timeout: {agent_id}")
                dead_agents.append(agent_id)
                continue
        
        # Clean up dead agents
        for agent_id in dead_agents:
            self.cleanup_agent(agent_id)
            del self.agents[agent_id]
    
    def get_agent_status(self) -> Dict[str, Any]:
        """Get status of all agents."""
        
        status = {
            "total_agents": len(self.agents),
            "max_agents": self.max_agents,
            "agents": {}
        }
        
        for agent_id, agent in self.agents.items():
            status["agents"][agent_id] = {
                "type": agent.agent_type.value,
                "status": agent.status,
                "pid": agent.pid,
                "task_count": agent.task_count,
                "uptime": time.time() - agent.spawn_time,
                "last_heartbeat": agent.last_heartbeat
            }
        
        return status

# Example usage
def main():
    """Example agent coordination usage."""
    
    coordinator = AgentCoordinator(
        config_dir="./.claude",
        cache_dir="./.claude/cache"
    )
    
    # Spawn different types of agents
    analyzer_config = AgentConfig(
        agent_type=AgentType.FILE_ANALYZER,
        max_memory="2G",
        max_cpu_percent=70
    )
    
    quality_config = AgentConfig(
        agent_type=AgentType.QUALITY_CHECKER,
        max_memory="1G",
        max_cpu_percent=80
    )
    
    # Spawn agents
    analyzer_id = coordinator.spawn_agent(analyzer_config)
    quality_id = coordinator.spawn_agent(quality_config)
    
    # Assign tasks
    analysis_task = {
        "type": "file_analysis",
        "files": ["src/**/*.js"],
        "required_capabilities": ["file_analysis", "syntax_checking"]
    }
    
    quality_task = {
        "type": "quality_check",
        "files": ["src/**/*.js"],
        "required_capabilities": ["linting", "testing"]
    }
    
    coordinator.assign_task(analysis_task, AgentType.FILE_ANALYZER)
    coordinator.assign_task(quality_task, AgentType.QUALITY_CHECKER)
    
    # Monitor for a while
    for _ in range(30):
        coordinator.monitor_agents()
        print(f"Agent status: {coordinator.get_agent_status()}")
        time.sleep(10)
    
    # Shutdown agents
    for agent_id in list(coordinator.agents.keys()):
        coordinator.terminate_agent(agent_id)

if __name__ == "__main__":
    main()
```

## Task Distribution

### Intelligent Task Allocation

```python
#!/usr/bin/env python3
"""Intelligent task distribution system."""

import json
import time
import hashlib
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
from enum import Enum

class TaskPriority(Enum):
    LOW = 1
    NORMAL = 2
    HIGH = 3
    CRITICAL = 4

class TaskStatus(Enum):
    PENDING = "pending"
    ASSIGNED = "assigned"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"

@dataclass
class Task:
    task_id: str
    task_type: str
    priority: TaskPriority
    data: Dict[str, Any]
    dependencies: List[str]
    required_capabilities: List[str]
    estimated_duration: int
    timeout: int
    retries: int = 0
    max_retries: int = 3
    created_at: float = None
    assigned_at: float = None
    started_at: float = None
    completed_at: float = None
    assigned_agent: str = None
    status: TaskStatus = TaskStatus.PENDING
    result: Dict[str, Any] = None
    error: str = None

class TaskDistributor:
    """Intelligent task distribution system."""
    
    def __init__(self, coordinator):
        self.coordinator = coordinator
        self.task_queue: List[Task] = []
        self.active_tasks: Dict[str, Task] = {}
        self.completed_tasks: Dict[str, Task] = {}
        self.task_dependencies: Dict[str, List[str]] = {}
        
    def submit_task(self, task_data: Dict[str, Any]) -> str:
        """Submit a new task for execution."""
        
        # Generate task ID
        task_id = self.generate_task_id(task_data)
        
        # Create task object
        task = Task(
            task_id=task_id,
            task_type=task_data.get('type', 'general'),
            priority=TaskPriority(task_data.get('priority', TaskPriority.NORMAL.value)),
            data=task_data,
            dependencies=task_data.get('dependencies', []),
            required_capabilities=task_data.get('required_capabilities', []),
            estimated_duration=task_data.get('estimated_duration', 300),
            timeout=task_data.get('timeout', 600),
            max_retries=task_data.get('max_retries', 3),
            created_at=time.time()
        )
        
        # Add to queue
        self.task_queue.append(task)
        
        # Update dependencies
        for dep_id in task.dependencies:
            if dep_id not in self.task_dependencies:
                self.task_dependencies[dep_id] = []
            self.task_dependencies[dep_id].append(task_id)
        
        # Sort queue by priority
        self.sort_task_queue()
        
        print(f"Task submitted: {task_id}")
        return task_id
    
    def generate_task_id(self, task_data: Dict[str, Any]) -> str:
        """Generate unique task ID."""
        
        # Create hash from task data and timestamp
        data_str = json.dumps(task_data, sort_keys=True)
        timestamp = str(time.time())
        hash_input = f"{data_str}:{timestamp}"
        
        return f"task_{hashlib.md5(hash_input.encode()).hexdigest()[:8]}"
    
    def sort_task_queue(self):
        """Sort task queue by priority and dependencies."""
        
        self.task_queue.sort(key=lambda t: (
            -t.priority.value,  # Higher priority first
            t.created_at        # Earlier tasks first for same priority
        ))
    
    def process_task_queue(self):
        """Process tasks from the queue."""
        
        while self.task_queue:
            # Find next executable task
            executable_task = self.find_next_executable_task()
            
            if not executable_task:
                break  # No executable tasks available
            
            # Remove from queue
            self.task_queue.remove(executable_task)
            
            # Try to assign task
            if self.assign_task_to_agent(executable_task):
                self.active_tasks[executable_task.task_id] = executable_task
                executable_task.status = TaskStatus.ASSIGNED
                executable_task.assigned_at = time.time()
            else:
                # Put back in queue if no agent available
                self.task_queue.append(executable_task)
                break
    
    def find_next_executable_task(self) -> Optional[Task]:
        """Find next task that can be executed."""
        
        for task in self.task_queue:
            if self.are_dependencies_satisfied(task):
                return task
        
        return None
    
    def are_dependencies_satisfied(self, task: Task) -> bool:
        """Check if all task dependencies are satisfied."""
        
        for dep_id in task.dependencies:
            if dep_id not in self.completed_tasks:
                return False
            
            # Check if dependency completed successfully
            dep_task = self.completed_tasks[dep_id]
            if dep_task.status != TaskStatus.COMPLETED:
                return False
        
        return True
    
    def assign_task_to_agent(self, task: Task) -> bool:
        """Assign task to appropriate agent."""
        
        # Find suitable agents
        suitable_agents = self.find_suitable_agents_for_task(task)
        
        if not suitable_agents:
            # Try to spawn new agent if possible
            agent_type = self.determine_agent_type_for_task(task)
            if agent_type:
                from agent_coordination_api import AgentConfig
                config = AgentConfig(
                    agent_type=agent_type,
                    timeout=task.timeout
                )
                
                agent_id = self.coordinator.spawn_agent(config)
                if agent_id:
                    # Wait briefly for agent initialization
                    time.sleep(1)
                    suitable_agents = [agent_id]
        
        if not suitable_agents:
            return False
        
        # Select best agent
        best_agent = self.select_best_agent_for_task(suitable_agents, task)
        
        # Create task assignment message
        assignment_message = {
            "type": "task_assignment",
            "data": {
                "task_id": task.task_id,
                "task_type": task.task_type,
                "task_data": task.data,
                "timeout": task.timeout,
                "estimated_duration": task.estimated_duration,
                "priority": task.priority.value
            }
        }
        
        # Send assignment
        if self.coordinator.send_message_to_agent(best_agent, assignment_message):
            task.assigned_agent = best_agent
            print(f"Task {task.task_id} assigned to agent {best_agent}")
            return True
        
        return False
    
    def find_suitable_agents_for_task(self, task: Task) -> List[str]:
        """Find agents suitable for the task."""
        
        suitable_agents = []
        
        for agent_id, agent_info in self.coordinator.agents.items():
            # Check if agent is available
            if agent_info.status not in ['idle', 'working']:
                continue
            
            # Check capabilities
            agent_config = self.coordinator.get_agent_config(agent_id)
            agent_capabilities = agent_config.get('capabilities', [])
            
            # Check if agent has required capabilities
            if task.required_capabilities:
                if not all(cap in agent_capabilities for cap in task.required_capabilities):
                    continue
            
            # Check task count (load balancing)
            if agent_info.task_count >= 5:  # Max concurrent tasks per agent
                continue
            
            suitable_agents.append(agent_id)
        
        return suitable_agents
    
    def determine_agent_type_for_task(self, task: Task):
        """Determine best agent type for task."""
        
        from agent_coordination_api import AgentType
        
        type_mapping = {
            'file_analysis': AgentType.FILE_ANALYZER,
            'template_processing': AgentType.TEMPLATE_PROCESSOR,
            'quality_check': AgentType.QUALITY_CHECKER,
            'git_operation': AgentType.GIT_INTEGRATOR
        }
        
        return type_mapping.get(task.task_type, AgentType.GENERAL_PURPOSE)
    
    def select_best_agent_for_task(self, agent_ids: List[str], task: Task) -> str:
        """Select best agent for task based on multiple factors."""
        
        if len(agent_ids) == 1:
            return agent_ids[0]
        
        # Calculate score for each agent
        agent_scores = {}
        
        for agent_id in agent_ids:
            agent_info = self.coordinator.agents[agent_id]
            score = 0
            
            # Load factor (fewer tasks = higher score)
            score += (10 - agent_info.task_count) * 10
            
            # Capability match (better match = higher score)
            agent_config = self.coordinator.get_agent_config(agent_id)
            agent_capabilities = set(agent_config.get('capabilities', []))
            required_capabilities = set(task.required_capabilities)
            
            if required_capabilities:
                match_ratio = len(required_capabilities & agent_capabilities) / len(required_capabilities)
                score += match_ratio * 50
            
            # Resource availability (estimate based on current usage)
            resource_usage = agent_info.resource_usage
            if resource_usage:
                cpu_available = 100 - resource_usage.get('cpu_percent', 50)
                memory_factor = 100 - (resource_usage.get('memory_kb', 0) / 1024 / 1024)  # Rough estimate
                score += (cpu_available + memory_factor) / 2
            
            # Agent type preference
            if agent_info.agent_type.value == task.task_type:
                score += 25
            
            agent_scores[agent_id] = score
        
        # Return agent with highest score
        best_agent = max(agent_scores.keys(), key=lambda aid: agent_scores[aid])
        return best_agent
    
    def handle_task_completion(self, task_id: str, result: Dict[str, Any], success: bool = True):
        """Handle task completion."""
        
        if task_id not in self.active_tasks:
            print(f"Unknown task completion: {task_id}")
            return
        
        task = self.active_tasks[task_id]
        task.completed_at = time.time()
        task.result = result
        
        if success:
            task.status = TaskStatus.COMPLETED
            print(f"Task completed successfully: {task_id}")
        else:
            task.status = TaskStatus.FAILED
            task.error = result.get('error', 'Unknown error')
            print(f"Task failed: {task_id} - {task.error}")
            
            # Retry if allowed
            if task.retries < task.max_retries:
                task.retries += 1
                task.status = TaskStatus.PENDING
                task.assigned_agent = None
                task.assigned_at = None
                
                # Put back in queue
                self.task_queue.append(task)
                self.sort_task_queue()
                
                print(f"Task queued for retry ({task.retries}/{task.max_retries}): {task_id}")
                del self.active_tasks[task_id]
                return
        
        # Move to completed tasks
        self.completed_tasks[task_id] = task
        del self.active_tasks[task_id]
        
        # Update agent task count
        if task.assigned_agent and task.assigned_agent in self.coordinator.agents:
            self.coordinator.agents[task.assigned_agent].task_count -= 1
        
        # Check for dependent tasks
        if task_id in self.task_dependencies:
            print(f"Task completion may unlock dependent tasks: {self.task_dependencies[task_id]}")
            # Process queue again to handle newly available tasks
            self.process_task_queue()
    
    def handle_task_progress(self, task_id: str, progress_data: Dict[str, Any]):
        """Handle task progress update."""
        
        if task_id in self.active_tasks:
            task = self.active_tasks[task_id]
            if task.status == TaskStatus.ASSIGNED:
                task.status = TaskStatus.IN_PROGRESS
                task.started_at = time.time()
            
            # Store progress data
            if not hasattr(task, 'progress'):
                task.progress = []
            task.progress.append({
                'timestamp': time.time(),
                'data': progress_data
            })
            
            print(f"Task progress: {task_id} - {progress_data}")
    
    def cancel_task(self, task_id: str) -> bool:
        """Cancel a task."""
        
        # Check if task is in queue
        for task in self.task_queue:
            if task.task_id == task_id:
                task.status = TaskStatus.CANCELLED
                self.task_queue.remove(task)
                self.completed_tasks[task_id] = task
                print(f"Task cancelled from queue: {task_id}")
                return True
        
        # Check if task is active
        if task_id in self.active_tasks:
            task = self.active_tasks[task_id]
            
            # Send cancellation message to agent
            if task.assigned_agent:
                cancel_message = {
                    "type": "task_cancellation",
                    "data": {
                        "task_id": task_id,
                        "reason": "user_request"
                    }
                }
                
                self.coordinator.send_message_to_agent(task.assigned_agent, cancel_message)
            
            task.status = TaskStatus.CANCELLED
            task.completed_at = time.time()
            
            # Move to completed tasks
            self.completed_tasks[task_id] = task
            del self.active_tasks[task_id]
            
            # Update agent task count
            if task.assigned_agent and task.assigned_agent in self.coordinator.agents:
                self.coordinator.agents[task.assigned_agent].task_count -= 1
            
            print(f"Task cancelled: {task_id}")
            return True
        
        print(f"Task not found for cancellation: {task_id}")
        return False
    
    def get_task_status(self, task_id: str) -> Optional[Dict[str, Any]]:
        """Get status of a specific task."""
        
        # Check active tasks
        if task_id in self.active_tasks:
            task = self.active_tasks[task_id]
        # Check completed tasks
        elif task_id in self.completed_tasks:
            task = self.completed_tasks[task_id]
        # Check queue
        else:
            for queued_task in self.task_queue:
                if queued_task.task_id == task_id:
                    task = queued_task
                    break
            else:
                return None
        
        status = {
            "task_id": task.task_id,
            "task_type": task.task_type,
            "status": task.status.value,
            "priority": task.priority.value,
            "created_at": task.created_at,
            "assigned_at": task.assigned_at,
            "started_at": task.started_at,
            "completed_at": task.completed_at,
            "assigned_agent": task.assigned_agent,
            "retries": task.retries,
            "max_retries": task.max_retries
        }
        
        if task.result:
            status["result"] = task.result
        
        if task.error:
            status["error"] = task.error
        
        return status
    
    def get_queue_status(self) -> Dict[str, Any]:
        """Get status of task queue."""
        
        return {
            "queue_length": len(self.task_queue),
            "active_tasks": len(self.active_tasks),
            "completed_tasks": len(self.completed_tasks),
            "queued_tasks": [
                {
                    "task_id": task.task_id,
                    "task_type": task.task_type,
                    "priority": task.priority.value,
                    "dependencies": task.dependencies,
                    "created_at": task.created_at
                }
                for task in self.task_queue
            ],
            "active_tasks_detail": [
                {
                    "task_id": task.task_id,
                    "task_type": task.task_type,
                    "assigned_agent": task.assigned_agent,
                    "status": task.status.value,
                    "started_at": task.started_at
                }
                for task in self.active_tasks.values()
            ]
        }
    
    def cleanup_completed_tasks(self, max_age: int = 86400):
        """Clean up old completed tasks."""
        
        current_time = time.time()
        to_remove = []
        
        for task_id, task in self.completed_tasks.items():
            if task.completed_at and (current_time - task.completed_at) > max_age:
                to_remove.append(task_id)
        
        for task_id in to_remove:
            del self.completed_tasks[task_id]
            
            # Clean up dependencies
            if task_id in self.task_dependencies:
                del self.task_dependencies[task_id]
        
        if to_remove:
            print(f"Cleaned up {len(to_remove)} old completed tasks")

# Example usage
def main():
    """Example task distribution usage."""
    
    from agent_coordination_api import AgentCoordinator, AgentType, AgentConfig
    
    # Set up coordinator and distributor
    coordinator = AgentCoordinator("./.claude", "./.claude/cache")
    distributor = TaskDistributor(coordinator)
    
    # Spawn some agents
    analyzer_config = AgentConfig(agent_type=AgentType.FILE_ANALYZER)
    quality_config = AgentConfig(agent_type=AgentType.QUALITY_CHECKER)
    
    coordinator.spawn_agent(analyzer_config)
    coordinator.spawn_agent(quality_config)
    
    # Submit tasks with dependencies
    task1_id = distributor.submit_task({
        "type": "file_analysis",
        "files": ["src/**/*.js"],
        "priority": TaskPriority.HIGH.value,
        "required_capabilities": ["file_analysis"]
    })
    
    task2_id = distributor.submit_task({
        "type": "quality_check",
        "files": ["src/**/*.js"],
        "dependencies": [task1_id],  # Depends on analysis completion
        "priority": TaskPriority.NORMAL.value,
        "required_capabilities": ["linting"]
    })
    
    # Process tasks
    for _ in range(10):
        distributor.process_task_queue()
        print(f"Queue status: {distributor.get_queue_status()}")
        time.sleep(5)
    
    # Simulate task completion
    distributor.handle_task_completion(task1_id, {"analysis": "completed"}, success=True)
    
    # Check final status
    print(f"Task 1 status: {distributor.get_task_status(task1_id)}")
    print(f"Task 2 status: {distributor.get_task_status(task2_id)}")

if __name__ == "__main__":
    main()
```

## Best Practices

### Agent Design Principles

1. **Stateless Operation**
   ```bash
   # Agents should be stateless for reliability
   process_task() {
       local task_data="$1"
       
       # Load all required state from task data
       local input_files=$(echo "$task_data" | jq -r '.input_files[]')
       local output_dir=$(echo "$task_data" | jq -r '.output_dir')
       
       # Process without relying on agent state
       for file in $input_files; do
           process_file "$file" "$output_dir"
       done
   }
   ```

2. **Idempotent Tasks**
   ```bash
   # Make tasks safe to retry
   generate_report() {
       local output_file="$1"
       local temp_file="${output_file}.tmp"
       
       # Generate to temporary file first
       create_report > "$temp_file"
       
       # Atomic move to final location
       mv "$temp_file" "$output_file"
   }
   ```

3. **Resource Cleanup**
   ```python
   class Agent:
       def __init__(self):
           self.temp_files = []
           self.processes = []
       
       def cleanup(self):
           # Clean up temporary files
           for temp_file in self.temp_files:
               try:
                   os.unlink(temp_file)
               except OSError:
                   pass
           
           # Terminate background processes
           for process in self.processes:
               try:
                   process.terminate()
                   process.wait(timeout=5)
               except:
                   process.kill()
   ```

### Performance Optimization

1. **Efficient Communication**
   ```bash
   # Use batch messaging for efficiency
   send_batch_messages() {
       local recipients=("$@")
       local batch_file="${CLAUDE_AGENT_WORKSPACE}/batch_message.json"
       
       # Prepare batch message
       cat > "$batch_file" <<EOF
   {
     "type": "batch",
     "recipients": $(printf '%s\n' "${recipients[@]}" | jq -R . | jq -s .),
     "message": $1
   }
   EOF
       
       # Send to message bus
       mv "$batch_file" "${CLAUDE_CACHE_DIR}/communication/broadcast/"
   }
   ```

2. **Resource Monitoring**
   ```python
   def monitor_resources(self):
       """Efficient resource monitoring."""
       
       # Sample resources every 10 seconds instead of continuous monitoring
       if time.time() - self.last_resource_check > 10:
           self.last_resource_check = time.time()
           
           # Use efficient system calls
           with open('/proc/self/status', 'r') as f:
               for line in f:
                   if line.startswith('VmRSS:'):
                       self.memory_usage = int(line.split()[1])
                   elif line.startswith('voluntary_ctxt_switches:'):
                       self.context_switches = int(line.split()[1])
   ```

3. **Smart Task Batching**
   ```python
   def batch_similar_tasks(self, tasks: List[Task]) -> List[List[Task]]:
       """Group similar tasks for efficient processing."""
       
       # Group by task type and input similarity
       batches = {}
       
       for task in tasks:
           # Create batch key
           batch_key = (task.task_type, frozenset(task.data.get('input_files', [])))
           
           if batch_key not in batches:
               batches[batch_key] = []
           
           batches[batch_key].append(task)
       
       # Return batches that are efficient to process together
       return [batch for batch in batches.values() if len(batch) > 1]
   ```

This comprehensive Agent Coordination API documentation provides everything needed to build scalable, efficient, and reliable multi-agent systems with Claude Code Enhancer.