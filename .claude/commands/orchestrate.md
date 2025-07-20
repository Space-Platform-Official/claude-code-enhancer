---
allowed-tools: all
description: Smart orchestration dispatcher with automatic mode detection for planning vs execution workflows
---

# 🎯 Orchestrate Command - Smart Dispatcher

**DUAL-MODE ORCHESTRATION WITH INTELLIGENT ROUTING**

The orchestrate command now supports dual-mode operation to solve the planning-loop issue:

## Mode Detection

This command automatically detects your intent and routes to the appropriate mode:

### Planning Mode - `/orchestrate/plan`
**Triggered by:**
- Arguments containing: `plan`, `analyze`, `design`, `strategy`, `architecture`
- No existing orchestration session found
- Explicit `--plan` flag

**Purpose:** Strategic orchestration planning with workflow decomposition

### Execution Mode - `/orchestrate/execute` 
**Triggered by:**
- Arguments containing: `execute`, `run`, `implement`, `coordinate`, `start`
- Existing orchestration session found in planned state
- Explicit `--execute` flag

**Purpose:** Active multi-agent coordination and workflow execution

### Legacy Mode (Fallback)
**Triggered by:**
- Generic arguments that don't match planning or execution patterns
- `--legacy` flag for backward compatibility

## Smart Routing Logic

```bash
# Analyze arguments for mode detection
ARGUMENTS="$*"

# Check for explicit mode flags
if [[ "$ARGUMENTS" =~ --plan ]]; then
    exec /orchestrate/plan "${ARGUMENTS//--plan/}"
elif [[ "$ARGUMENTS" =~ --execute ]]; then
    exec /orchestrate/execute "${ARGUMENTS//--execute/}"
elif [[ "$ARGUMENTS" =~ --legacy ]]; then
    echo "🔄 Routing to legacy orchestrate mode..."
    # Continue with legacy implementation below
else
    # Intelligent mode detection
    if [[ "$ARGUMENTS" =~ (plan|analyze|design|strategy|architecture) ]]; then
        echo "🔍 Detected planning intent - routing to /orchestrate/plan"
        exec /orchestrate/plan "$ARGUMENTS"
    elif [[ "$ARGUMENTS" =~ (execute|run|implement|coordinate|start) ]]; then
        echo "⚡ Detected execution intent - routing to /orchestrate/execute"
        exec /orchestrate/execute "$ARGUMENTS"
    elif [ -f ".orchestration/sessions/current.txt" ] && [ -n "$(cat .orchestration/sessions/current.txt)" ]; then
        echo "📋 Found existing orchestration session - routing to execution"
        exec /orchestrate/execute "$ARGUMENTS"
    else
        echo "🔍 No clear intent detected - defaulting to planning mode"
        echo "💡 Use '/orchestrate/plan' or '/orchestrate/execute' for explicit mode selection"
        exec /orchestrate/plan "$ARGUMENTS"
    fi
fi
```

---

# 🔄 Legacy Orchestrate Implementation

**LEGACY MODE: Original orchestration behavior (planning-prone)**

*This implementation is preserved for backward compatibility but may exhibit planning loops.*

## Task Analysis and Decomposition

$ARGUMENTS

## Orchestration Strategy

### 1. Task Breakdown
First, I'll analyze the provided tasks/plans and decompose them into independent work units that can be executed in parallel:

- Identify dependencies between tasks
- Group related tasks that share context
- Determine optimal parallelization strategy
- Estimate complexity and resource requirements for each sub-task

### 2. Agent Spawning Pattern

Based on the task analysis, I'll spawn specialized agents using these patterns:

#### Pattern A: File-Based Parallelization
When tasks involve multiple files, spawn one agent per file or file group:
```
Agent 1: Handle authentication module (auth.ts, auth.test.ts)
Agent 2: Handle database layer (db/*.ts)
Agent 3: Handle API endpoints (api/*.ts)
```

#### Pattern B: Feature-Based Distribution
For feature implementation, spawn agents for different aspects:
```
Agent 1: Research existing patterns and dependencies
Agent 2: Implement core functionality
Agent 3: Write comprehensive tests
Agent 4: Update documentation and types
```

#### Pattern C: Layer-Based Separation
For full-stack tasks, spawn agents per layer:
```
Agent 1: Frontend components and UI
Agent 2: Backend API and business logic
Agent 3: Database schema and migrations
Agent 4: Testing and integration
```

### 3. Coordination Protocol

#### Phase 1: Reconnaissance (Parallel)
All agents perform initial analysis and report findings:
- Agent reports on current state of assigned area
- Identify existing patterns and conventions
- Note dependencies and potential conflicts
- Estimate effort and complexity

#### Phase 2: Implementation (Parallel)
Based on reconnaissance, spawn implementation agents:
- Agents execute their assigned tasks
- Regular check-ins and progress updates
- Coordination through shared context files
- Conflict resolution and integration planning

#### Phase 3: Integration (Sequential)
Agents coordinate for final integration:
- Review all agent outputs for consistency
- Handle any conflicts or integration issues
- Run final tests and validation
- Create consolidated documentation

## Implementation Process

### Step 1: Initial Analysis
I'll analyze the task and create a detailed execution plan with agent assignments.

### Step 2: Agent Coordination Setup
- Create shared workspace for agent communication
- Set up progress tracking and status updates
- Establish conflict resolution protocols

### Step 3: Multi-Agent Execution
I'll spawn the required agents and monitor their progress, providing coordination and guidance as needed.

### Step 4: Integration and Validation
Finally, I'll integrate all agent outputs, resolve conflicts, and ensure the overall solution meets requirements.

---

## Migration Guide

**Moving from Legacy to Dual-Mode:**

1. **For Planning Tasks:**
   ```bash
   # Old way (may loop)
   /orchestrate "analyze and plan the user authentication system"
   
   # New way (explicit)
   /orchestrate/plan "analyze and plan the user authentication system"
   ```

2. **For Execution Tasks:**
   ```bash
   # Old way (may plan instead of execute)
   /orchestrate "implement the user authentication system"
   
   # New way (explicit)
   /orchestrate/execute "implement the user authentication system"
   ```

3. **Auto-Detection:**
   ```bash
   # These will automatically route to planning
   /orchestrate "design the authentication architecture"
   /orchestrate "analyze requirements for user system"
   
   # These will automatically route to execution
   /orchestrate "implement the planned authentication system"
   /orchestrate "execute the user system workflow"
   ```

## Benefits of Dual-Mode

✅ **Eliminates planning loops** - Clear separation prevents infinite planning cycles
✅ **Preserves functionality** - Legacy mode maintains backward compatibility  
✅ **Intelligent routing** - Smart detection reduces user friction
✅ **Session continuity** - Execution mode can resume planned orchestrations
✅ **Clear boundaries** - Users know exactly what mode they're in

---

**Choose your mode:**
- `Use /orchestrate/plan for strategic analysis and workflow design`
- `Use /orchestrate/execute for active multi-agent coordination`
- `Use /orchestrate --legacy for original behavior (may exhibit loops)`