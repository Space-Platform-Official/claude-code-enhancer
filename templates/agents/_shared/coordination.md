---
description: Inter-agent coordination and state management system for parallel execution
---

# Agent Coordination System

Robust coordination mechanism for multi-agent communication, state sharing, and workflow synchronization.

## Coordination Architecture

```yaml
coordination_structure:
  base_directory: /tmp/claude-agents/
  session_format: "{operation}-{timestamp}/"
  
  directories:
    registry: "registry/"      # Active agent tracking
    state: "state/"            # Shared state files
    messages: "messages/"      # Inter-agent messages
    results: "results/"        # Agent output files
    locks: "locks/"           # Coordination locks
    metrics: "metrics/"       # Performance tracking
```

## Session Management

### Session Initialization

```bash
# Initialize coordination session
init_coordination_session() {
  local operation=$1
  local timestamp=$(date +%s)
  local session_id="${operation}-${timestamp}"
  local session_dir="/tmp/claude-agents/${session_id}"
  
  # Create session structure
  mkdir -p "${session_dir}"/{registry,state,messages,results,locks,metrics}
  
  # Initialize session metadata
  cat > "${session_dir}/session.json" << EOF
{
  "id": "${session_id}",
  "operation": "${operation}",
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": "active",
  "agents": [],
  "coordinator": "$(whoami)@$(hostname)"
}
EOF
  
  echo "${session_id}"
}
```

### Session Cleanup

```bash
# Clean up coordination session
cleanup_coordination_session() {
  local session_id=$1
  local session_dir="/tmp/claude-agents/${session_id}"
  
  # Mark session as completed
  jq '.status = "completed" | .ended_at = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' \
    "${session_dir}/session.json" > "${session_dir}/session.json.tmp"
  mv "${session_dir}/session.json.tmp" "${session_dir}/session.json"
  
  # Archive results
  tar -czf "${session_dir}.tar.gz" -C "/tmp/claude-agents" "${session_id}"
  
  # Schedule cleanup (keep for 1 hour for debugging)
  echo "rm -rf ${session_dir}" | at now + 1 hour 2>/dev/null || \
    (sleep 3600 && rm -rf "${session_dir}") &
}
```

## Agent Registry

### Agent Registration

```json
{
  "agent_id": "test-fixer-001",
  "type": "test-fixer",
  "status": "active",
  "registered_at": "2024-01-15T10:30:00Z",
  "capabilities": ["test_execution", "test_debugging", "coverage_analysis"],
  "assigned_tasks": ["fix-auth-tests", "validate-api-tests"],
  "resource_usage": {
    "cpu": "15%",
    "memory": "120MB",
    "threads": 2
  }
}
```

### Registry Operations

```javascript
class AgentRegistry {
  constructor(sessionDir) {
    this.registryFile = `${sessionDir}/registry/agents.json`;
    this.agents = new Map();
  }
  
  register(agent) {
    const registration = {
      id: agent.id,
      type: agent.type,
      status: 'active',
      registered_at: new Date().toISOString(),
      capabilities: agent.capabilities,
      assigned_tasks: [],
      pid: process.pid
    };
    
    this.agents.set(agent.id, registration);
    this.persist();
    
    return registration;
  }
  
  update(agentId, updates) {
    const agent = this.agents.get(agentId);
    if (agent) {
      Object.assign(agent, updates);
      agent.updated_at = new Date().toISOString();
      this.persist();
    }
  }
  
  unregister(agentId) {
    const agent = this.agents.get(agentId);
    if (agent) {
      agent.status = 'terminated';
      agent.terminated_at = new Date().toISOString();
      this.persist();
      setTimeout(() => this.agents.delete(agentId), 5000);
    }
  }
  
  getActiveAgents(type = null) {
    return Array.from(this.agents.values())
      .filter(a => a.status === 'active')
      .filter(a => !type || a.type === type);
  }
  
  persist() {
    const data = Array.from(this.agents.values());
    fs.writeFileSync(this.registryFile, JSON.stringify(data, null, 2));
  }
}
```

## State Management

### Shared State Structure

```yaml
shared_state:
  global:
    file: "state/global.json"
    content:
      operation_progress: 0-100
      phase: "discovery|analysis|execution|validation"
      errors: []
      warnings: []
      
  task_queue:
    file: "state/tasks.json"
    content:
      pending: []
      in_progress: []
      completed: []
      failed: []
      
  results_aggregation:
    file: "state/results.json"
    content:
      by_agent: {}
      by_task: {}
      summary: {}
```

### State Operations

```javascript
class SharedState {
  constructor(sessionDir) {
    this.stateDir = `${sessionDir}/state`;
    this.locks = new Map();
  }
  
  async read(key) {
    const file = `${this.stateDir}/${key}.json`;
    
    try {
      const data = await fs.readFile(file, 'utf8');
      return JSON.parse(data);
    } catch (error) {
      return null;
    }
  }
  
  async write(key, value) {
    const file = `${this.stateDir}/${key}.json`;
    const lockFile = `${this.stateDir}/.${key}.lock`;
    
    // Acquire lock
    await this.acquireLock(lockFile);
    
    try {
      // Write atomically
      const tempFile = `${file}.tmp`;
      await fs.writeFile(tempFile, JSON.stringify(value, null, 2));
      await fs.rename(tempFile, file);
    } finally {
      // Release lock
      await this.releaseLock(lockFile);
    }
  }
  
  async update(key, updater) {
    const current = await this.read(key) || {};
    const updated = updater(current);
    await this.write(key, updated);
    return updated;
  }
  
  async acquireLock(lockFile, timeout = 5000) {
    const startTime = Date.now();
    
    while (Date.now() - startTime < timeout) {
      try {
        await fs.writeFile(lockFile, process.pid.toString(), { flag: 'wx' });
        this.locks.set(lockFile, true);
        return;
      } catch (error) {
        // Lock exists, wait and retry
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    }
    
    throw new Error(`Failed to acquire lock: ${lockFile}`);
  }
  
  async releaseLock(lockFile) {
    if (this.locks.has(lockFile)) {
      await fs.unlink(lockFile).catch(() => {});
      this.locks.delete(lockFile);
    }
  }
}
```

## Message Passing

### Message Format

```json
{
  "id": "msg-123456",
  "from": "agent-001",
  "to": "agent-002",
  "type": "task_assignment",
  "timestamp": "2024-01-15T10:30:00Z",
  "payload": {
    "task_id": "analyze-tests",
    "priority": "high",
    "data": {}
  },
  "requires_ack": true
}
```

### Message Queue Implementation

```javascript
class MessageQueue {
  constructor(sessionDir) {
    this.messageDir = `${sessionDir}/messages`;
    this.queues = new Map();
  }
  
  async send(message) {
    const queueFile = `${this.messageDir}/${message.to}.json`;
    
    // Read existing queue
    let queue = [];
    try {
      const data = await fs.readFile(queueFile, 'utf8');
      queue = JSON.parse(data);
    } catch (error) {
      // Queue doesn't exist yet
    }
    
    // Add message
    queue.push({
      ...message,
      id: `msg-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      timestamp: new Date().toISOString()
    });
    
    // Write queue
    await fs.writeFile(queueFile, JSON.stringify(queue, null, 2));
    
    return message.id;
  }
  
  async receive(agentId, timeout = 100) {
    const queueFile = `${this.messageDir}/${agentId}.json`;
    
    try {
      const data = await fs.readFile(queueFile, 'utf8');
      const queue = JSON.parse(data);
      
      if (queue.length > 0) {
        const message = queue.shift();
        
        // Update queue
        await fs.writeFile(queueFile, JSON.stringify(queue, null, 2));
        
        // Send acknowledgment if required
        if (message.requires_ack) {
          await this.acknowledge(message);
        }
        
        return message;
      }
    } catch (error) {
      // No messages
    }
    
    return null;
  }
  
  async broadcast(message) {
    const agents = await this.getActiveAgents();
    
    for (const agent of agents) {
      if (agent.id !== message.from) {
        await this.send({
          ...message,
          to: agent.id
        });
      }
    }
  }
}
```

## Task Coordination

### Task Distribution

```yaml
task_distribution_strategies:
  round_robin:
    description: "Distribute tasks evenly across agents"
    implementation: "Cycle through available agents"
    
  load_balanced:
    description: "Assign based on agent load"
    implementation: "Track agent workload and assign to least loaded"
    
  capability_based:
    description: "Match tasks to agent capabilities"
    implementation: "Route based on required capabilities"
    
  priority_queue:
    description: "Process high-priority tasks first"
    implementation: "Maintain priority queue with preemption"
```

### Task Lifecycle

```javascript
class TaskCoordinator {
  constructor(sessionDir) {
    this.state = new SharedState(sessionDir);
    this.registry = new AgentRegistry(sessionDir);
  }
  
  async assignTask(task) {
    // Find suitable agent
    const agents = this.registry.getActiveAgents(task.agentType);
    const agent = this.selectAgent(agents, task);
    
    if (!agent) {
      // Queue task for later
      await this.queueTask(task);
      return null;
    }
    
    // Assign to agent
    task.assigned_to = agent.id;
    task.assigned_at = new Date().toISOString();
    task.status = 'assigned';
    
    // Update state
    await this.state.update('tasks', tasks => {
      tasks.in_progress.push(task);
      return tasks;
    });
    
    // Send to agent
    await this.messageQueue.send({
      from: 'coordinator',
      to: agent.id,
      type: 'task_assignment',
      payload: task
    });
    
    return agent.id;
  }
  
  async completeTask(taskId, results) {
    await this.state.update('tasks', tasks => {
      const task = tasks.in_progress.find(t => t.id === taskId);
      if (task) {
        task.status = 'completed';
        task.completed_at = new Date().toISOString();
        task.results = results;
        
        tasks.in_progress = tasks.in_progress.filter(t => t.id !== taskId);
        tasks.completed.push(task);
      }
      return tasks;
    });
    
    // Update progress
    await this.updateProgress();
  }
  
  async updateProgress() {
    const tasks = await this.state.read('tasks');
    const total = tasks.pending.length + tasks.in_progress.length + 
                  tasks.completed.length + tasks.failed.length;
    const completed = tasks.completed.length;
    
    const progress = total > 0 ? Math.round((completed / total) * 100) : 0;
    
    await this.state.update('global', global => {
      global.operation_progress = progress;
      return global;
    });
  }
}
```

## Result Aggregation

### Result Collection

```javascript
class ResultAggregator {
  constructor(sessionDir) {
    this.resultsDir = `${sessionDir}/results`;
    this.state = new SharedState(sessionDir);
  }
  
  async collectResults() {
    const results = {
      by_agent: {},
      by_task: {},
      summary: {
        total_tasks: 0,
        completed_tasks: 0,
        failed_tasks: 0,
        total_time: 0,
        agents_used: 0
      }
    };
    
    // Read all result files
    const files = await fs.readdir(this.resultsDir);
    
    for (const file of files) {
      if (file.endsWith('.json')) {
        const data = await fs.readFile(`${this.resultsDir}/${file}`, 'utf8');
        const agentResults = JSON.parse(data);
        
        // Aggregate by agent
        const agentId = file.replace('.json', '');
        results.by_agent[agentId] = agentResults;
        
        // Aggregate by task
        for (const task of agentResults.tasks) {
          results.by_task[task.id] = task;
        }
        
        // Update summary
        results.summary.total_tasks += agentResults.tasks.length;
        results.summary.completed_tasks += agentResults.tasks
          .filter(t => t.status === 'completed').length;
        results.summary.failed_tasks += agentResults.tasks
          .filter(t => t.status === 'failed').length;
        results.summary.total_time += agentResults.execution_time;
      }
    }
    
    results.summary.agents_used = Object.keys(results.by_agent).length;
    
    return results;
  }
  
  async generateReport() {
    const results = await this.collectResults();
    const session = await this.state.read('session');
    
    const report = {
      session: session,
      results: results,
      performance: {
        throughput: results.summary.total_tasks / results.summary.total_time,
        success_rate: results.summary.completed_tasks / results.summary.total_tasks,
        average_time: results.summary.total_time / results.summary.total_tasks
      },
      timestamp: new Date().toISOString()
    };
    
    await fs.writeFile(
      `${this.resultsDir}/final-report.json`,
      JSON.stringify(report, null, 2)
    );
    
    return report;
  }
}
```

## Monitoring and Health Checks

### Agent Health Monitoring

```bash
# Monitor agent health
monitor_agent_health() {
  local session_dir=$1
  local registry_file="${session_dir}/registry/agents.json"
  
  while [ -f "${session_dir}/session.json" ]; do
    # Check each registered agent
    jq -r '.[] | select(.status == "active") | .id + ":" + (.pid | tostring)' \
      "${registry_file}" | while IFS=: read -r agent_id pid; do
      
      # Check if process is still running
      if ! kill -0 "${pid}" 2>/dev/null; then
        echo "Agent ${agent_id} (PID ${pid}) is not responding"
        
        # Mark as failed
        jq --arg id "${agent_id}" \
          '(.[] | select(.id == $id) | .status) = "failed"' \
          "${registry_file}" > "${registry_file}.tmp"
        mv "${registry_file}.tmp" "${registry_file}"
      fi
    done
    
    sleep 5
  done
}
```

## Coordination Patterns

### Pattern Examples

```yaml
coordination_patterns:
  map_reduce:
    map_phase:
      - Distribute work across agents
      - Each agent processes subset
      - Results written to agent-specific files
    reduce_phase:
      - Aggregator collects all results
      - Combines into final output
      
  pipeline:
    stages:
      - stage_1: discovery_agents
      - stage_2: analysis_agents
      - stage_3: transformation_agents
      - stage_4: validation_agents
    coordination:
      - Each stage waits for previous
      - Results passed through state files
      
  scatter_gather:
    scatter:
      - Broadcast task to all agents
      - Each agent works independently
    gather:
      - Collect results as they complete
      - First valid result wins
```

## Quality Gates

**Coordination Setup:**
- [ ] Session initialized properly
- [ ] Directory structure created
- [ ] Agent registry active
- [ ] Message queues ready

**During Execution:**
- [ ] Agents registered correctly
- [ ] State synchronized
- [ ] Messages delivered
- [ ] Progress tracked

**Cleanup:**
- [ ] Results collected
- [ ] Report generated
- [ ] Session archived
- [ ] Resources released

The coordination system ensures reliable multi-agent execution with robust state management, message passing, and result aggregation capabilities.