# Test Agent Coordination Mechanisms

## Orchestration Session Management

```bash
#!/bin/bash

# Initialize test orchestration session
init_test_session() {
  local session_id="test-orch-$(date +%s)"
  local session_dir="/tmp/test-sessions/${session_id}"
  
  mkdir -p "${session_dir}"/{agents,results,coverage,performance,logs}
  
  cat > "${session_dir}/session.json" << EOF
{
  "id": "${session_id}",
  "status": "initializing",
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "orchestrator": "test-orchestrator",
  "agents": [],
  "test_types": {
    "unit": {"discovered": 0, "executed": 0, "passed": 0, "failed": 0},
    "integration": {"discovered": 0, "executed": 0, "passed": 0, "failed": 0},
    "e2e": {"discovered": 0, "executed": 0, "passed": 0, "failed": 0}
  },
  "coordination": {
    "mode": "adaptive",
    "parallelization": "auto",
    "resource_limit": "80%"
  }
}
EOF
  
  echo "${session_id}"
}

# Register agent in session
register_test_agent() {
  local session_id=$1
  local agent_id=$2
  local agent_type=$3
  local session_file="/tmp/test-sessions/${session_id}/session.json"
  
  # Add agent to session
  jq --arg id "$agent_id" --arg type "$agent_type" \
    '.agents += [{"id": $id, "type": $type, "status": "registered", "registered_at": now | todate}]' \
    "$session_file" > "${session_file}.tmp" && mv "${session_file}.tmp" "$session_file"
    
  # Create agent workspace
  mkdir -p "/tmp/test-sessions/${session_id}/agents/${agent_id}"
  
  echo "Agent registered: ${agent_id} (${agent_type})"
}
```

## Agent Communication Protocol

```javascript
// Agent message passing system
class AgentMessageBus {
  constructor(sessionId) {
    this.sessionId = sessionId;
    this.basePath = `/tmp/test-sessions/${sessionId}/messages`;
    this.subscribers = new Map();
  }
  
  // Send message from one agent to another
  async send(fromAgent, toAgent, message) {
    const messageId = `msg-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    const messagePath = `${this.basePath}/${toAgent}/${messageId}.json`;
    
    const fullMessage = {
      id: messageId,
      from: fromAgent,
      to: toAgent,
      timestamp: new Date().toISOString(),
      type: message.type,
      data: message.data
    };
    
    await fs.writeJson(messagePath, fullMessage);
    
    // Notify subscriber if exists
    if (this.subscribers.has(toAgent)) {
      this.subscribers.get(toAgent)(fullMessage);
    }
    
    return messageId;
  }
  
  // Subscribe to messages for an agent
  subscribe(agentId, callback) {
    this.subscribers.set(agentId, callback);
    
    // Watch for new messages
    const watchPath = `${this.basePath}/${agentId}`;
    fs.watch(watchPath, (eventType, filename) => {
      if (eventType === 'rename' && filename.endsWith('.json')) {
        const messagePath = `${watchPath}/${filename}`;
        fs.readJson(messagePath).then(message => {
          callback(message);
          // Mark as read
          fs.rename(messagePath, `${messagePath}.read`);
        });
      }
    });
  }
  
  // Broadcast message to all agents
  async broadcast(fromAgent, message) {
    const agents = await this.getActiveAgents();
    const promises = agents
      .filter(agent => agent !== fromAgent)
      .map(agent => this.send(fromAgent, agent, message));
    
    return Promise.all(promises);
  }
  
  async getActiveAgents() {
    const sessionFile = `/tmp/test-sessions/${this.sessionId}/session.json`;
    const session = await fs.readJson(sessionFile);
    return session.agents.filter(a => a.status === 'active').map(a => a.id);
  }
}
```

## Test Execution Coordination

```javascript
// Coordinate test execution across agents
class TestExecutionCoordinator {
  constructor(sessionId) {
    this.sessionId = sessionId;
    this.executionPlan = null;
    this.agentAssignments = new Map();
  }
  
  // Create optimized execution plan
  async createExecutionPlan(testFiles) {
    const categorized = {
      unit: [],
      integration: [],
      e2e: []
    };
    
    // Categorize tests
    for (const file of testFiles) {
      const content = await fs.readFile(file, 'utf-8');
      const type = categorizeTest(content, file);
      if (categorized[type]) {
        categorized[type].push(file);
      }
    }
    
    // Create execution batches
    const plan = {
      phases: [],
      parallelization: {},
      dependencies: {}
    };
    
    // Phase 1: Unit tests (maximum parallelization)
    if (categorized.unit.length > 0) {
      plan.phases.push({
        id: 'unit-tests',
        type: 'unit',
        files: categorized.unit,
        parallelization: 'maximum',
        agents: Math.min(5, Math.ceil(categorized.unit.length / 10))
      });
    }
    
    // Phase 2: Integration tests (controlled parallelization)
    if (categorized.integration.length > 0) {
      plan.phases.push({
        id: 'integration-tests',
        type: 'integration',
        files: categorized.integration,
        parallelization: 'controlled',
        agents: Math.min(3, Math.ceil(categorized.integration.length / 5)),
        dependencies: ['unit-tests']
      });
    }
    
    // Phase 3: E2E tests (sequential or limited parallel)
    if (categorized.e2e.length > 0) {
      plan.phases.push({
        id: 'e2e-tests',
        type: 'e2e',
        files: categorized.e2e,
        parallelization: 'sequential',
        agents: 1,
        dependencies: ['integration-tests']
      });
    }
    
    this.executionPlan = plan;
    return plan;
  }
  
  // Assign work to agents
  async assignWork(phase, agents) {
    const assignments = [];
    const filesPerAgent = Math.ceil(phase.files.length / agents.length);
    
    for (let i = 0; i < agents.length; i++) {
      const start = i * filesPerAgent;
      const end = Math.min(start + filesPerAgent, phase.files.length);
      const assignedFiles = phase.files.slice(start, end);
      
      if (assignedFiles.length > 0) {
        assignments.push({
          agent: agents[i],
          files: assignedFiles,
          phase: phase.id,
          type: phase.type
        });
        
        this.agentAssignments.set(agents[i].id, assignedFiles);
      }
    }
    
    return assignments;
  }
  
  // Monitor execution progress
  async monitorProgress() {
    const progressFile = `/tmp/test-sessions/${this.sessionId}/progress.json`;
    const progress = {
      phases: {},
      overall: {
        total: 0,
        completed: 0,
        passed: 0,
        failed: 0
      }
    };
    
    for (const phase of this.executionPlan.phases) {
      progress.phases[phase.id] = {
        total: phase.files.length,
        completed: 0,
        passed: 0,
        failed: 0,
        inProgress: 0
      };
    }
    
    // Update progress periodically
    const updateInterval = setInterval(async () => {
      // Read agent results
      const resultsDir = `/tmp/test-sessions/${this.sessionId}/results`;
      const resultFiles = await fs.readdir(resultsDir);
      
      for (const file of resultFiles) {
        const result = await fs.readJson(`${resultsDir}/${file}`);
        const phaseId = result.phase;
        
        if (progress.phases[phaseId]) {
          progress.phases[phaseId].completed = result.completed || 0;
          progress.phases[phaseId].passed = result.passed || 0;
          progress.phases[phaseId].failed = result.failed || 0;
        }
      }
      
      // Calculate overall progress
      progress.overall.total = Object.values(progress.phases)
        .reduce((sum, p) => sum + p.total, 0);
      progress.overall.completed = Object.values(progress.phases)
        .reduce((sum, p) => sum + p.completed, 0);
      progress.overall.passed = Object.values(progress.phases)
        .reduce((sum, p) => sum + p.passed, 0);
      progress.overall.failed = Object.values(progress.phases)
        .reduce((sum, p) => sum + p.failed, 0);
      
      await fs.writeJson(progressFile, progress);
      
      // Stop monitoring when complete
      if (progress.overall.completed === progress.overall.total) {
        clearInterval(updateInterval);
      }
    }, 1000);
  }
}
```

## Resource Management

```javascript
// Manage resources across test agents
class TestResourceManager {
  constructor(resourceLimit = 0.8) {
    this.resourceLimit = resourceLimit; // Use max 80% of system resources
    this.allocations = new Map();
    this.systemResources = this.getSystemResources();
  }
  
  getSystemResources() {
    const cpus = os.cpus().length;
    const memory = os.totalmem();
    
    return {
      cpus: Math.floor(cpus * this.resourceLimit),
      memory: Math.floor(memory * this.resourceLimit),
      availableCpus: Math.floor(cpus * this.resourceLimit),
      availableMemory: Math.floor(memory * this.resourceLimit)
    };
  }
  
  // Allocate resources to an agent
  allocate(agentId, requirements) {
    const { cpus = 1, memory = 512 * 1024 * 1024 } = requirements;
    
    if (this.canAllocate(cpus, memory)) {
      this.allocations.set(agentId, { cpus, memory });
      this.systemResources.availableCpus -= cpus;
      this.systemResources.availableMemory -= memory;
      
      return {
        success: true,
        allocated: { cpus, memory }
      };
    }
    
    return {
      success: false,
      reason: 'Insufficient resources',
      available: {
        cpus: this.systemResources.availableCpus,
        memory: this.systemResources.availableMemory
      }
    };
  }
  
  // Release resources from an agent
  release(agentId) {
    const allocation = this.allocations.get(agentId);
    if (allocation) {
      this.systemResources.availableCpus += allocation.cpus;
      this.systemResources.availableMemory += allocation.memory;
      this.allocations.delete(agentId);
    }
  }
  
  // Check if resources are available
  canAllocate(cpus, memory) {
    return (
      this.systemResources.availableCpus >= cpus &&
      this.systemResources.availableMemory >= memory
    );
  }
  
  // Get optimal worker count for test type
  getOptimalWorkers(testType, fileCount) {
    const configs = {
      unit: {
        filesPerWorker: 10,
        maxWorkers: Math.floor(this.systemResources.cpus * 0.5),
        memoryPerWorker: 256 * 1024 * 1024
      },
      integration: {
        filesPerWorker: 5,
        maxWorkers: Math.floor(this.systemResources.cpus * 0.3),
        memoryPerWorker: 512 * 1024 * 1024
      },
      e2e: {
        filesPerWorker: 2,
        maxWorkers: 2,
        memoryPerWorker: 1024 * 1024 * 1024
      }
    };
    
    const config = configs[testType] || configs.unit;
    const idealWorkers = Math.ceil(fileCount / config.filesPerWorker);
    const maxByMemory = Math.floor(
      this.systemResources.availableMemory / config.memoryPerWorker
    );
    
    return Math.min(idealWorkers, config.maxWorkers, maxByMemory);
  }
}
```

## State Synchronization

```bash
#!/bin/bash

# Synchronize state across test agents
sync_test_state() {
  local session_id=$1
  local state_file="/tmp/test-sessions/${session_id}/state.json"
  
  # Lock file for atomic updates
  local lock_file="${state_file}.lock"
  
  # Acquire lock
  exec 200>"$lock_file"
  flock 200
  
  # Read current state
  if [ -f "$state_file" ]; then
    local current_state=$(cat "$state_file")
  else
    local current_state='{}'
  fi
  
  # Update state (passed as stdin)
  local new_state=$(jq -s '.[0] * .[1]' <(echo "$current_state") -)
  
  # Write updated state
  echo "$new_state" > "$state_file"
  
  # Release lock
  flock -u 200
  
  echo "$new_state"
}

# Update agent status
update_agent_status() {
  local session_id=$1
  local agent_id=$2
  local status=$3
  
  local session_file="/tmp/test-sessions/${session_id}/session.json"
  
  jq --arg id "$agent_id" --arg status "$status" \
    '(.agents[] | select(.id == $id) | .status) = $status' \
    "$session_file" > "${session_file}.tmp" && mv "${session_file}.tmp" "$session_file"
}

# Aggregate test results
aggregate_test_results() {
  local session_id=$1
  local results_dir="/tmp/test-sessions/${session_id}/results"
  local aggregate_file="/tmp/test-sessions/${session_id}/aggregate.json"
  
  # Initialize aggregate
  echo '{
    "unit": {"total": 0, "passed": 0, "failed": 0, "skipped": 0},
    "integration": {"total": 0, "passed": 0, "failed": 0, "skipped": 0},
    "e2e": {"total": 0, "passed": 0, "failed": 0, "skipped": 0},
    "overall": {"total": 0, "passed": 0, "failed": 0, "skipped": 0}
  }' > "$aggregate_file"
  
  # Process each result file
  for result_file in "$results_dir"/*.json; do
    if [ -f "$result_file" ]; then
      # Merge results
      jq -s '
        .[0] as $agg | .[1] as $res |
        $agg | .[$res.type].total += $res.total |
        .[$res.type].passed += $res.passed |
        .[$res.type].failed += $res.failed |
        .[$res.type].skipped += $res.skipped |
        .overall.total += $res.total |
        .overall.passed += $res.passed |
        .overall.failed += $res.failed |
        .overall.skipped += $res.skipped
      ' "$aggregate_file" "$result_file" > "${aggregate_file}.tmp"
      mv "${aggregate_file}.tmp" "$aggregate_file"
    fi
  done
  
  cat "$aggregate_file"
}
```

## Failure Recovery

```javascript
// Handle agent failures and recovery
class TestFailureRecovery {
  constructor(sessionId) {
    this.sessionId = sessionId;
    this.failedAgents = new Set();
    this.retryAttempts = new Map();
    this.maxRetries = 3;
  }
  
  // Handle agent failure
  async handleAgentFailure(agentId, error) {
    console.error(`Agent ${agentId} failed:`, error);
    
    this.failedAgents.add(agentId);
    const attempts = (this.retryAttempts.get(agentId) || 0) + 1;
    this.retryAttempts.set(agentId, attempts);
    
    if (attempts < this.maxRetries) {
      // Attempt recovery
      return this.recoverAgent(agentId);
    } else {
      // Reassign work to other agents
      return this.reassignWork(agentId);
    }
  }
  
  // Recover failed agent
  async recoverAgent(agentId) {
    console.log(`Attempting to recover agent ${agentId}`);
    
    // Get agent's assigned work
    const sessionFile = `/tmp/test-sessions/${this.sessionId}/session.json`;
    const session = await fs.readJson(sessionFile);
    const agent = session.agents.find(a => a.id === agentId);
    
    if (!agent) {
      throw new Error(`Agent ${agentId} not found in session`);
    }
    
    // Restart agent with same configuration
    const recoveryConfig = {
      id: `${agentId}-recovered-${Date.now()}`,
      type: agent.type,
      originalId: agentId,
      attempt: this.retryAttempts.get(agentId)
    };
    
    // Spawn replacement agent
    await this.spawnReplacementAgent(recoveryConfig);
    
    return recoveryConfig.id;
  }
  
  // Reassign work from failed agent
  async reassignWork(agentId) {
    console.log(`Reassigning work from failed agent ${agentId}`);
    
    // Get unfinished work
    const workFile = `/tmp/test-sessions/${this.sessionId}/agents/${agentId}/assigned.json`;
    const assignedWork = await fs.readJson(workFile);
    const progressFile = `/tmp/test-sessions/${this.sessionId}/agents/${agentId}/progress.json`;
    const progress = await fs.readJson(progressFile).catch(() => ({ completed: [] }));
    
    const remainingWork = assignedWork.files.filter(
      file => !progress.completed.includes(file)
    );
    
    if (remainingWork.length === 0) {
      console.log('No remaining work to reassign');
      return;
    }
    
    // Find available agents
    const sessionFile = `/tmp/test-sessions/${this.sessionId}/session.json`;
    const session = await fs.readJson(sessionFile);
    const availableAgents = session.agents.filter(
      a => a.status === 'active' && !this.failedAgents.has(a.id)
    );
    
    if (availableAgents.length === 0) {
      throw new Error('No available agents to reassign work');
    }
    
    // Distribute remaining work
    const filesPerAgent = Math.ceil(remainingWork.length / availableAgents.length);
    
    for (let i = 0; i < availableAgents.length; i++) {
      const start = i * filesPerAgent;
      const end = Math.min(start + filesPerAgent, remainingWork.length);
      const files = remainingWork.slice(start, end);
      
      if (files.length > 0) {
        await this.assignFilesToAgent(availableAgents[i].id, files);
      }
    }
  }
  
  async spawnReplacementAgent(config) {
    // Implementation would spawn actual agent via Task tool
    console.log(`Spawning replacement agent: ${config.id}`);
  }
  
  async assignFilesToAgent(agentId, files) {
    const workFile = `/tmp/test-sessions/${this.sessionId}/agents/${agentId}/additional.json`;
    await fs.writeJson(workFile, { files, timestamp: Date.now() });
  }
}
```

## Reporting Aggregation

```javascript
// Generate comprehensive test report
class TestReportAggregator {
  constructor(sessionId) {
    this.sessionId = sessionId;
  }
  
  async generateReport() {
    const report = {
      summary: await this.getSummary(),
      byType: await this.getResultsByType(),
      coverage: await this.getCoverage(),
      performance: await this.getPerformance(),
      failures: await this.getFailures(),
      recommendations: await this.getRecommendations()
    };
    
    return this.formatReport(report);
  }
  
  async getSummary() {
    const aggregateFile = `/tmp/test-sessions/${this.sessionId}/aggregate.json`;
    const aggregate = await fs.readJson(aggregateFile);
    
    return {
      total: aggregate.overall.total,
      passed: aggregate.overall.passed,
      failed: aggregate.overall.failed,
      skipped: aggregate.overall.skipped,
      successRate: (aggregate.overall.passed / aggregate.overall.total * 100).toFixed(2) + '%'
    };
  }
  
  async getResultsByType() {
    const aggregateFile = `/tmp/test-sessions/${this.sessionId}/aggregate.json`;
    const aggregate = await fs.readJson(aggregateFile);
    
    return {
      unit: aggregate.unit,
      integration: aggregate.integration,
      e2e: aggregate.e2e
    };
  }
  
  async getCoverage() {
    const coverageFiles = await fs.readdir(`/tmp/test-sessions/${this.sessionId}/coverage`);
    let combined = {
      lines: { total: 0, covered: 0 },
      branches: { total: 0, covered: 0 },
      functions: { total: 0, covered: 0 },
      statements: { total: 0, covered: 0 }
    };
    
    for (const file of coverageFiles) {
      const coverage = await fs.readJson(
        `/tmp/test-sessions/${this.sessionId}/coverage/${file}`
      );
      
      // Combine coverage data
      Object.keys(combined).forEach(key => {
        combined[key].total += coverage[key].total || 0;
        combined[key].covered += coverage[key].covered || 0;
      });
    }
    
    // Calculate percentages
    Object.keys(combined).forEach(key => {
      combined[key].percentage = 
        combined[key].total > 0 
          ? (combined[key].covered / combined[key].total * 100).toFixed(2) + '%'
          : '0%';
    });
    
    return combined;
  }
  
  async getPerformance() {
    const performanceFile = `/tmp/test-sessions/${this.sessionId}/performance/summary.json`;
    return fs.readJson(performanceFile).catch(() => ({
      totalDuration: 0,
      averageTestDuration: 0,
      parallelizationEfficiency: 0
    }));
  }
  
  async getFailures() {
    const failuresDir = `/tmp/test-sessions/${this.sessionId}/failures`;
    const failures = [];
    
    const failureFiles = await fs.readdir(failuresDir).catch(() => []);
    for (const file of failureFiles) {
      const failure = await fs.readJson(`${failuresDir}/${file}`);
      failures.push(failure);
    }
    
    return failures;
  }
  
  async getRecommendations() {
    const recommendations = [];
    const summary = await this.getSummary();
    const coverage = await this.getCoverage();
    const performance = await this.getPerformance();
    
    // Success rate recommendations
    if (parseFloat(summary.successRate) < 100) {
      recommendations.push(
        `Test success rate is ${summary.successRate}. Review and fix failing tests.`
      );
    }
    
    // Coverage recommendations
    if (parseFloat(coverage.lines.percentage) < 80) {
      recommendations.push(
        `Line coverage is ${coverage.lines.percentage}. Consider adding more tests.`
      );
    }
    
    // Performance recommendations
    if (performance.parallelizationEfficiency < 50) {
      recommendations.push(
        'Low parallelization efficiency. Consider optimizing test isolation.'
      );
    }
    
    return recommendations;
  }
  
  formatReport(report) {
    return `
TEST ORCHESTRATION REPORT
========================

SUMMARY
-------
Total Tests: ${report.summary.total}
Passed: ${report.summary.passed}
Failed: ${report.summary.failed}
Skipped: ${report.summary.skipped}
Success Rate: ${report.summary.successRate}

BY TEST TYPE
-----------
Unit Tests:
  Total: ${report.byType.unit.total}
  Passed: ${report.byType.unit.passed}
  Failed: ${report.byType.unit.failed}

Integration Tests:
  Total: ${report.byType.integration.total}
  Passed: ${report.byType.integration.passed}
  Failed: ${report.byType.integration.failed}

E2E Tests:
  Total: ${report.byType.e2e.total}
  Passed: ${report.byType.e2e.passed}
  Failed: ${report.byType.e2e.failed}

COVERAGE
--------
Line Coverage: ${report.coverage.lines.percentage}
Branch Coverage: ${report.coverage.branches.percentage}
Function Coverage: ${report.coverage.functions.percentage}
Statement Coverage: ${report.coverage.statements.percentage}

PERFORMANCE
----------
Total Duration: ${report.performance.totalDuration}ms
Average Test Duration: ${report.performance.averageTestDuration}ms
Parallelization Efficiency: ${report.performance.parallelizationEfficiency}%

${report.failures.length > 0 ? `
FAILURES
--------
${report.failures.map(f => `- ${f.test}: ${f.error}`).join('\n')}
` : ''}

RECOMMENDATIONS
--------------
${report.recommendations.map(r => `- ${r}`).join('\n')}
    `;
  }
}
```