---
description: Resource monitoring, allocation, and limit enforcement for multi-agent execution
---

# Agent Resource Management System

Comprehensive resource management ensuring optimal performance and system stability during multi-agent operations.

## Resource Limits Configuration

```yaml
resource_limits:
  global:
    max_concurrent_agents: 5
    max_total_memory: 2GB
    max_cpu_percent: 80
    max_disk_io: 100MB/s
    max_coordination_files: 1000
    coordination_dir_size: 500MB
    
  per_agent:
    test-fixer:
      max_memory: 500MB
      max_cpu_percent: 25
      timeout: 300s
      priority: high
      
    code-analyzer:
      max_memory: 400MB
      max_cpu_percent: 20
      timeout: 180s
      priority: medium
      
    git-operator:
      max_memory: 300MB
      max_cpu_percent: 15
      timeout: 120s
      priority: high
      
    file-processor:
      max_memory: 600MB
      max_cpu_percent: 30
      timeout: 600s
      priority: low
      
    code-quality-enforcer:
      max_memory: 400MB
      max_cpu_percent: 20
      timeout: 240s
      priority: medium
      
    orchestrator:
      max_memory: 200MB
      max_cpu_percent: 10
      timeout: 60s
      priority: critical
```

## Resource Monitoring

### System Resource Monitor

```javascript
class SystemResourceMonitor {
  constructor() {
    this.metrics = {
      cpu: [],
      memory: [],
      disk: [],
      agents: []
    };
    this.limits = this.loadLimits();
    this.alertThresholds = {
      cpu: 0.8,      // 80% of limit
      memory: 0.75,  // 75% of limit
      disk: 0.9      // 90% of limit
    };
  }
  
  async getCurrentUsage() {
    const usage = {
      cpu: await this.getCpuUsage(),
      memory: await this.getMemoryUsage(),
      disk: await this.getDiskUsage(),
      agents: await this.getAgentCount(),
      timestamp: Date.now()
    };
    
    // Store metrics for trending
    this.metrics.cpu.push(usage.cpu);
    this.metrics.memory.push(usage.memory);
    this.metrics.disk.push(usage.disk);
    
    // Keep only last 100 samples
    if (this.metrics.cpu.length > 100) {
      this.metrics.cpu.shift();
      this.metrics.memory.shift();
      this.metrics.disk.shift();
    }
    
    return usage;
  }
  
  async getCpuUsage() {
    // Platform-specific CPU usage calculation
    const command = process.platform === 'darwin' 
      ? "ps aux | awk '{sum+=$3} END {print sum}'"
      : "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'";
    
    const result = await exec(command);
    return parseFloat(result.stdout);
  }
  
  async getMemoryUsage() {
    const total = os.totalmem();
    const free = os.freemem();
    const used = total - free;
    
    return {
      total: total,
      used: used,
      free: free,
      percent: (used / total) * 100
    };
  }
  
  async getDiskUsage() {
    const tempDir = '/tmp/claude-agents';
    const command = `du -sb ${tempDir} 2>/dev/null | cut -f1`;
    
    try {
      const result = await exec(command);
      return parseInt(result.stdout);
    } catch {
      return 0;
    }
  }
  
  async getAgentCount() {
    const registryFiles = await glob('/tmp/claude-agents/*/registry/agents.json');
    let totalAgents = 0;
    
    for (const file of registryFiles) {
      try {
        const data = await fs.readFile(file, 'utf8');
        const agents = JSON.parse(data);
        totalAgents += agents.filter(a => a.status === 'active').length;
      } catch {
        // Ignore invalid files
      }
    }
    
    return totalAgents;
  }
  
  checkThresholds(usage) {
    const alerts = [];
    
    if (usage.cpu > this.limits.global.max_cpu_percent * this.alertThresholds.cpu) {
      alerts.push({
        type: 'cpu',
        severity: 'warning',
        message: `CPU usage at ${usage.cpu}% (threshold: ${this.limits.global.max_cpu_percent * this.alertThresholds.cpu}%)`
      });
    }
    
    if (usage.memory.percent > this.limits.global.max_total_memory * this.alertThresholds.memory) {
      alerts.push({
        type: 'memory',
        severity: 'warning',
        message: `Memory usage at ${usage.memory.percent}% (threshold: ${this.limits.global.max_total_memory * this.alertThresholds.memory}%)`
      });
    }
    
    if (usage.agents >= this.limits.global.max_concurrent_agents) {
      alerts.push({
        type: 'agents',
        severity: 'critical',
        message: `Agent limit reached: ${usage.agents}/${this.limits.global.max_concurrent_agents}`
      });
    }
    
    return alerts;
  }
}
```

### Agent Resource Tracker

```javascript
class AgentResourceTracker {
  constructor(agentId, type) {
    this.agentId = agentId;
    this.type = type;
    this.startTime = Date.now();
    this.metrics = [];
    this.limits = this.getAgentLimits(type);
  }
  
  getAgentLimits(type) {
    const limits = {
      'test-fixer': { memory: 500 * 1024 * 1024, cpu: 25, timeout: 300000 },
      'code-analyzer': { memory: 400 * 1024 * 1024, cpu: 20, timeout: 180000 },
      'git-operator': { memory: 300 * 1024 * 1024, cpu: 15, timeout: 120000 },
      'file-processor': { memory: 600 * 1024 * 1024, cpu: 30, timeout: 600000 },
      'code-quality-enforcer': { memory: 400 * 1024 * 1024, cpu: 20, timeout: 240000 },
      'orchestrator': { memory: 200 * 1024 * 1024, cpu: 10, timeout: 60000 }
    };
    
    return limits[type] || limits['code-analyzer'];
  }
  
  async track() {
    const metric = {
      timestamp: Date.now(),
      memory: process.memoryUsage(),
      cpu: await this.getCpuUsage(),
      duration: Date.now() - this.startTime
    };
    
    this.metrics.push(metric);
    
    // Check limits
    const violations = this.checkViolations(metric);
    if (violations.length > 0) {
      await this.handleViolations(violations);
    }
    
    return metric;
  }
  
  checkViolations(metric) {
    const violations = [];
    
    if (metric.memory.heapUsed > this.limits.memory) {
      violations.push({
        type: 'memory',
        current: metric.memory.heapUsed,
        limit: this.limits.memory
      });
    }
    
    if (metric.cpu > this.limits.cpu) {
      violations.push({
        type: 'cpu',
        current: metric.cpu,
        limit: this.limits.cpu
      });
    }
    
    if (metric.duration > this.limits.timeout) {
      violations.push({
        type: 'timeout',
        current: metric.duration,
        limit: this.limits.timeout
      });
    }
    
    return violations;
  }
  
  async handleViolations(violations) {
    for (const violation of violations) {
      console.error(`Resource violation for ${this.agentId}:`, violation);
      
      switch (violation.type) {
        case 'memory':
          // Try garbage collection
          if (global.gc) {
            global.gc();
          }
          break;
          
        case 'cpu':
          // Throttle processing
          await this.throttle();
          break;
          
        case 'timeout':
          // Terminate agent
          await this.terminate();
          break;
      }
    }
  }
  
  async throttle() {
    // Implement CPU throttling
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  
  async terminate() {
    console.error(`Terminating agent ${this.agentId} due to timeout`);
    process.exit(1);
  }
}
```

## Resource Allocation

### Agent Spawning Controller

```javascript
class AgentSpawnController {
  constructor() {
    this.monitor = new SystemResourceMonitor();
    this.activeAgents = new Map();
    this.queue = [];
    this.maxConcurrent = 5;
  }
  
  async canSpawnAgent(type) {
    const usage = await this.monitor.getCurrentUsage();
    const agentLimits = this.getAgentRequirements(type);
    
    // Check global limits
    if (this.activeAgents.size >= this.maxConcurrent) {
      return { allowed: false, reason: 'max_agents_reached' };
    }
    
    // Check CPU availability
    if (usage.cpu + agentLimits.cpu > 80) {
      return { allowed: false, reason: 'insufficient_cpu' };
    }
    
    // Check memory availability
    const requiredMemory = agentLimits.memory;
    if (usage.memory.free < requiredMemory) {
      return { allowed: false, reason: 'insufficient_memory' };
    }
    
    return { allowed: true };
  }
  
  async spawnAgent(type, config) {
    const canSpawn = await this.canSpawnAgent(type);
    
    if (!canSpawn.allowed) {
      // Queue the agent request
      this.queue.push({ type, config, timestamp: Date.now() });
      console.log(`Agent spawn queued: ${canSpawn.reason}`);
      return null;
    }
    
    // Spawn the agent
    const agentId = `${type}-${Date.now()}`;
    const agent = {
      id: agentId,
      type: type,
      config: config,
      startTime: Date.now(),
      tracker: new AgentResourceTracker(agentId, type)
    };
    
    this.activeAgents.set(agentId, agent);
    
    // Start resource tracking
    this.startTracking(agent);
    
    return agentId;
  }
  
  startTracking(agent) {
    const interval = setInterval(async () => {
      if (!this.activeAgents.has(agent.id)) {
        clearInterval(interval);
        return;
      }
      
      await agent.tracker.track();
    }, 5000); // Track every 5 seconds
    
    agent.trackingInterval = interval;
  }
  
  async terminateAgent(agentId) {
    const agent = this.activeAgents.get(agentId);
    
    if (agent) {
      // Stop tracking
      if (agent.trackingInterval) {
        clearInterval(agent.trackingInterval);
      }
      
      // Remove from active agents
      this.activeAgents.delete(agentId);
      
      // Process queue if any
      await this.processQueue();
    }
  }
  
  async processQueue() {
    if (this.queue.length === 0) return;
    
    // Sort queue by priority and timestamp
    this.queue.sort((a, b) => {
      const priorityA = this.getAgentPriority(a.type);
      const priorityB = this.getAgentPriority(b.type);
      
      if (priorityA !== priorityB) {
        return priorityB - priorityA; // Higher priority first
      }
      
      return a.timestamp - b.timestamp; // Older first
    });
    
    // Try to spawn queued agents
    const processed = [];
    for (const request of this.queue) {
      const canSpawn = await this.canSpawnAgent(request.type);
      
      if (canSpawn.allowed) {
        await this.spawnAgent(request.type, request.config);
        processed.push(request);
      } else {
        break; // Stop if we can't spawn anymore
      }
    }
    
    // Remove processed requests
    this.queue = this.queue.filter(r => !processed.includes(r));
  }
  
  getAgentPriority(type) {
    const priorities = {
      'orchestrator': 5,     // Critical
      'test-fixer': 4,       // High
      'git-operator': 4,     // High
      'code-analyzer': 3,    // Medium
      'code-quality-enforcer': 3, // Medium
      'file-processor': 2    // Low
    };
    
    return priorities[type] || 1;
  }
  
  getAgentRequirements(type) {
    const requirements = {
      'test-fixer': { memory: 500 * 1024 * 1024, cpu: 25 },
      'code-analyzer': { memory: 400 * 1024 * 1024, cpu: 20 },
      'git-operator': { memory: 300 * 1024 * 1024, cpu: 15 },
      'file-processor': { memory: 600 * 1024 * 1024, cpu: 30 },
      'code-quality-enforcer': { memory: 400 * 1024 * 1024, cpu: 20 },
      'orchestrator': { memory: 200 * 1024 * 1024, cpu: 10 }
    };
    
    return requirements[type] || requirements['code-analyzer'];
  }
}
```

## Performance Optimization

### Resource Pooling

```javascript
class ResourcePool {
  constructor() {
    this.pools = {
      connections: new ConnectionPool(),
      workers: new WorkerPool(),
      buffers: new BufferPool()
    };
  }
  
  async acquire(type, config) {
    const pool = this.pools[type];
    
    if (!pool) {
      throw new Error(`Unknown resource type: ${type}`);
    }
    
    return await pool.acquire(config);
  }
  
  release(type, resource) {
    const pool = this.pools[type];
    
    if (pool) {
      pool.release(resource);
    }
  }
}

class ConnectionPool {
  constructor() {
    this.connections = [];
    this.available = [];
    this.maxSize = 10;
  }
  
  async acquire(config) {
    // Return available connection or create new
    if (this.available.length > 0) {
      return this.available.pop();
    }
    
    if (this.connections.length < this.maxSize) {
      const conn = await this.createConnection(config);
      this.connections.push(conn);
      return conn;
    }
    
    // Wait for available connection
    return await this.waitForConnection();
  }
  
  release(connection) {
    if (connection && this.connections.includes(connection)) {
      this.available.push(connection);
    }
  }
}
```

### Adaptive Throttling

```javascript
class AdaptiveThrottler {
  constructor() {
    this.baseDelay = 10;  // Base delay in ms
    this.maxDelay = 1000; // Max delay in ms
    this.currentDelay = this.baseDelay;
    this.monitor = new SystemResourceMonitor();
  }
  
  async throttle() {
    const usage = await this.monitor.getCurrentUsage();
    
    // Calculate throttle factor based on resource usage
    const cpuFactor = usage.cpu / 100;
    const memoryFactor = usage.memory.percent / 100;
    const loadFactor = Math.max(cpuFactor, memoryFactor);
    
    // Exponential backoff based on load
    this.currentDelay = Math.min(
      this.baseDelay * Math.pow(2, loadFactor * 10),
      this.maxDelay
    );
    
    await new Promise(resolve => setTimeout(resolve, this.currentDelay));
    
    return this.currentDelay;
  }
  
  reset() {
    this.currentDelay = this.baseDelay;
  }
}
```

## Cleanup and Recovery

### Resource Cleanup

```bash
# Cleanup orphaned resources
cleanup_orphaned_resources() {
  local max_age=3600  # 1 hour in seconds
  
  echo "Cleaning up orphaned agent resources..."
  
  # Find and remove old coordination directories
  find /tmp/claude-agents -type d -name "*-*" -mmin +60 -exec rm -rf {} \; 2>/dev/null
  
  # Kill orphaned agent processes
  ps aux | grep -E "claude-agent|test-fixer|code-analyzer" | \
    awk '{print $2}' | while read pid; do
    
    # Check if process is orphaned (no parent coordination)
    if ! find /tmp/claude-agents -name "agents.json" -exec grep -l "\"pid\": $pid" {} \; | head -1; then
      echo "Killing orphaned process: $pid"
      kill -TERM $pid 2>/dev/null
    fi
  done
  
  # Clean up lock files
  find /tmp/claude-agents -name "*.lock" -mmin +5 -delete 2>/dev/null
  
  echo "Cleanup completed"
}
```

### Recovery Mechanisms

```javascript
class ResourceRecovery {
  constructor() {
    this.monitor = new SystemResourceMonitor();
    this.controller = new AgentSpawnController();
  }
  
  async recoverFromOverload() {
    console.log('System overload detected, initiating recovery...');
    
    // Step 1: Stop spawning new agents
    this.controller.maxConcurrent = 0;
    
    // Step 2: Terminate low-priority agents
    const agents = Array.from(this.controller.activeAgents.values());
    const lowPriority = agents
      .filter(a => this.controller.getAgentPriority(a.type) <= 2)
      .sort((a, b) => b.startTime - a.startTime); // Newest first
    
    for (const agent of lowPriority.slice(0, 2)) {
      await this.controller.terminateAgent(agent.id);
      console.log(`Terminated low-priority agent: ${agent.id}`);
    }
    
    // Step 3: Force garbage collection
    if (global.gc) {
      global.gc();
    }
    
    // Step 4: Wait for resources to stabilize
    await new Promise(resolve => setTimeout(resolve, 5000));
    
    // Step 5: Gradually restore capacity
    this.controller.maxConcurrent = 3;
    
    console.log('Recovery completed');
  }
  
  async handleResourceViolation(violation) {
    switch (violation.type) {
      case 'memory':
        await this.handleMemoryViolation(violation);
        break;
      case 'cpu':
        await this.handleCpuViolation(violation);
        break;
      case 'disk':
        await this.handleDiskViolation(violation);
        break;
    }
  }
  
  async handleMemoryViolation(violation) {
    // Free memory by clearing caches and terminating agents
    console.log('Memory violation detected, freeing resources...');
    
    // Clear caches
    if (global.clearCaches) {
      global.clearCaches();
    }
    
    // Terminate oldest agent
    const agents = Array.from(this.controller.activeAgents.values());
    if (agents.length > 0) {
      const oldest = agents.sort((a, b) => a.startTime - b.startTime)[0];
      await this.controller.terminateAgent(oldest.id);
    }
  }
}
```

## Monitoring Dashboard

### Resource Status Report

```javascript
function generateResourceReport(monitor, controller) {
  const usage = monitor.getCurrentUsage();
  const agents = Array.from(controller.activeAgents.values());
  
  return {
    timestamp: new Date().toISOString(),
    system: {
      cpu: `${usage.cpu.toFixed(1)}%`,
      memory: `${(usage.memory.percent).toFixed(1)}%`,
      disk: `${(usage.disk / 1024 / 1024).toFixed(1)}MB`,
      agents: usage.agents
    },
    agents: agents.map(a => ({
      id: a.id,
      type: a.type,
      uptime: `${((Date.now() - a.startTime) / 1000).toFixed(0)}s`,
      memory: `${(a.tracker.metrics.slice(-1)[0]?.memory.heapUsed / 1024 / 1024).toFixed(1)}MB`,
      cpu: `${a.tracker.metrics.slice(-1)[0]?.cpu.toFixed(1)}%`
    })),
    queue: controller.queue.length,
    alerts: monitor.checkThresholds(usage)
  };
}
```

## Quality Gates

**Resource Management Setup:**
- [ ] Limits configured appropriately
- [ ] Monitoring initialized
- [ ] Spawn controller ready
- [ ] Recovery mechanisms in place

**During Execution:**
- [ ] Resources within limits
- [ ] Agents tracked properly
- [ ] Queue processed efficiently
- [ ] Violations handled

**Cleanup:**
- [ ] Resources released
- [ ] Orphaned processes terminated
- [ ] Temporary files cleaned
- [ ] Metrics recorded

The resource management system ensures efficient agent execution while preventing system overload through intelligent monitoring, allocation, and recovery mechanisms.