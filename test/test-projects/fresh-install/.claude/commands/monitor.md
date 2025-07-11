---
allowed-tools: all
description: Implement comprehensive observability with structured logging, metrics, tracing, and alerting
---

🚨 **OBSERVABILITY COMMAND - VISIBILITY INTO EVERYTHING!** 🚨

**THIS IS NOT A BASIC LOGGING TASK - THIS IS COMPREHENSIVE OBSERVABILITY!**

When you run `/monitor`, you are REQUIRED to:

1. **IMPLEMENT** structured logging systematically across all components
2. **ADD** metrics collection for all critical operations
3. **SET UP** distributed tracing for request flows
4. **CREATE** dashboards and alerts for operational awareness
5. **USE MULTIPLE AGENTS** for different observability aspects:
   - Spawn one agent to implement structured logging
   - Spawn another to add metrics collection
   - Spawn more agents for tracing and alerting
   - Say: "I'll spawn multiple agents to implement observability across all system layers"

**FORBIDDEN BEHAVIORS:**
- ❌ "Added some console.log statements" → NO! STRUCTURED LOGGING!
- ❌ "Basic error logging is enough" → NO! COMPREHENSIVE OBSERVABILITY!
- ❌ "We can add monitoring later" → NO! OBSERVABILITY FIRST!
- ❌ Simple print debugging → NO! PROPER INSTRUMENTATION!

**MANDATORY WORKFLOW:**
```
1. Audit current observability → Identify gaps
2. Design observability strategy → Plan implementation
3. Implement structured logging → Add context everywhere
4. Add metrics collection → Track all operations
5. Set up distributed tracing → Follow request flows
6. Create dashboards and alerts → Enable proactive monitoring
```

---

🛑 **MANDATORY OBSERVABILITY ASSESSMENT** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify you're implementing comprehensive observability, not just basic logging

Execute comprehensive observability implementation with ZERO tolerance for minimal logging.

**FORBIDDEN MINIMAL PATTERNS:**
- "Just log errors" → NO, log operations and context
- "Basic health checks are enough" → NO, detailed metrics required
- "We don't need tracing" → NO, request tracing is essential
- "Simple alerting works" → NO, intelligent alerting needed
- "Logs are sufficient" → NO, metrics and tracing also required

You are implementing observability for: $ARGUMENTS

Let me ultrathink about implementing comprehensive observability across all system layers.

🚨 **REMEMBER: You can't fix what you can't see!** 🚨

**Comprehensive Observability Implementation Protocol:**

**Step 0: Current State Assessment**
- Audit existing logging, metrics, and monitoring
- Identify observability gaps and blind spots
- Map critical business operations and user journeys
- Document current alerting and incident response

**Step 1: Observability Strategy Design**
Design comprehensive observability strategy covering:
- **Logging Strategy**: Structured logging with consistent formats
- **Metrics Strategy**: Business and technical metrics collection
- **Tracing Strategy**: Request flow visibility across services
- **Alerting Strategy**: Proactive issue detection and notification

**Step 2: Structured Logging Implementation**
Implement systematic structured logging:

**Universal Logging Requirements:**
- JSON structured format for all log entries
- Consistent log levels (TRACE, DEBUG, INFO, WARN, ERROR, FATAL)
- Correlation IDs for request tracking
- Contextual information (user ID, session ID, operation ID)
- Standardized field names across all services
- No sensitive data in logs (PII, passwords, tokens)

**Logging Instrumentation Points:**
- [ ] Application startup and shutdown
- [ ] All HTTP requests (method, path, status, duration)
- [ ] Database operations (queries, transactions, performance)
- [ ] External API calls (endpoint, status, latency)
- [ ] Authentication and authorization events
- [ ] Business logic operations and decisions
- [ ] Error conditions with full context
- [ ] Background job execution
- [ ] Cache operations (hits, misses, evictions)
- [ ] File system operations

**Go Logging Implementation:**
```go
// Use structured logging with consistent fields
logger.Info("Processing user request",
    zap.String("operation", "user.create"),
    zap.String("user_id", userID),
    zap.String("correlation_id", correlationID),
    zap.Duration("duration", time.Since(start)),
    zap.Any("metadata", requestMetadata),
)
```

**Step 3: Metrics Collection Implementation**
Implement comprehensive metrics using Prometheus-style approach:

**Business Metrics:**
- [ ] User registration and activation rates
- [ ] Feature usage and adoption metrics
- [ ] Business transaction volumes and values
- [ ] User engagement and retention metrics
- [ ] Error rates by business operation
- [ ] Conversion funnel metrics

**Technical Metrics:**
- [ ] HTTP request rates, latencies, and status codes
- [ ] Database connection pool usage and query performance
- [ ] Memory usage, GC pauses, and CPU utilization
- [ ] Cache hit ratios and performance
- [ ] Queue lengths and processing times
- [ ] External API latencies and error rates
- [ ] Disk usage and I/O operations

**Metrics Implementation Patterns:**
```go
// Counter for events
userRegistrations := prometheus.NewCounterVec(
    prometheus.CounterOpts{
        Name: "user_registrations_total",
        Help: "Total number of user registrations",
    },
    []string{"source", "status"},
)

// Histogram for durations
requestDuration := prometheus.NewHistogramVec(
    prometheus.HistogramOpts{
        Name: "http_request_duration_seconds",
        Help: "HTTP request duration in seconds",
        Buckets: prometheus.DefBuckets,
    },
    []string{"method", "endpoint", "status"},
)
```

**Step 4: Distributed Tracing Setup**
Implement request tracing across service boundaries:

**Tracing Requirements:**
- [ ] Trace context propagation across all services
- [ ] Span creation for all significant operations
- [ ] Custom attributes for business context
- [ ] Error recording and exception tracking
- [ ] Database query tracing
- [ ] External service call tracing
- [ ] Async operation correlation

**OpenTelemetry Implementation:**
```go
// Start span with context
ctx, span := tracer.Start(ctx, "user.authenticate",
    trace.WithAttributes(
        attribute.String("user.id", userID),
        attribute.String("auth.method", "oauth"),
    ),
)
defer span.End()

// Add events and set status
span.AddEvent("validation.complete")
if err != nil {
    span.RecordError(err)
    span.SetStatus(codes.Error, err.Error())
}
```

**Step 5: Health Checks and Readiness Probes**
Implement comprehensive health monitoring:

**Health Check Types:**
- [ ] Liveness probes (basic service health)
- [ ] Readiness probes (dependency health)
- [ ] Deep health checks (business logic validation)
- [ ] Dependency health (database, cache, external APIs)
- [ ] Resource health (disk space, memory, connections)

**Health Check Implementation:**
```go
// Comprehensive health check
type HealthChecker struct {
    db     Database
    cache  Cache
    apis   []ExternalAPI
}

func (h *HealthChecker) Check(ctx context.Context) HealthStatus {
    status := HealthStatus{Healthy: true, Details: make(map[string]interface{})}
    
    // Check database
    if err := h.db.Ping(ctx); err != nil {
        status.Healthy = false
        status.Details["database"] = map[string]interface{}{
            "status": "unhealthy",
            "error": err.Error(),
        }
    }
    
    // Check other dependencies...
    return status
}
```

**Step 6: Alerting and Notification Setup**
Create intelligent alerting rules:

**Alert Categories:**
- [ ] **Critical**: Service down, data loss, security breach
- [ ] **Warning**: High latency, elevated error rates, resource exhaustion
- [ ] **Info**: Deployment events, configuration changes

**Alerting Rules Examples:**
- HTTP 5xx error rate > 1% for 5 minutes
- Average response time > 2 seconds for 10 minutes
- Database connection pool utilization > 80%
- Memory usage > 85% for 15 minutes
- Failed authentication attempts > 100/minute
- Queue processing lag > 1 hour

**Step 7: Dashboard Creation**
Build operational dashboards:

**Dashboard Categories:**
- [ ] **Business Dashboard**: KPIs, user metrics, revenue impact
- [ ] **Operations Dashboard**: Service health, performance, errors
- [ ] **Infrastructure Dashboard**: Resource usage, capacity planning
- [ ] **Security Dashboard**: Authentication, authorization, threat detection

**Dashboard Requirements:**
- Real-time data with appropriate refresh rates
- Time range selection and zoom capabilities
- Drill-down capability from high-level to detailed views
- Alert integration and acknowledgment
- Mobile-responsive design for on-call engineers

**Step 8: Log Aggregation and Analysis**
Set up centralized logging:

**Log Management Requirements:**
- [ ] Centralized log collection from all services
- [ ] Log retention policies and archival
- [ ] Full-text search and filtering capabilities
- [ ] Log-based alerting rules
- [ ] Correlation with metrics and traces
- [ ] Automated log analysis and anomaly detection

**Step 9: Observability Testing**
Validate observability implementation:

**Testing Requirements:**
- [ ] Verify all log statements produce expected output
- [ ] Test metric collection under various conditions
- [ ] Validate trace propagation across service calls
- [ ] Test alert firing and notification delivery
- [ ] Load test observability system performance
- [ ] Chaos engineering to test monitoring during failures

**Agent Spawning Strategy:**
For comprehensive observability implementation:
1. **Logging Agent** - "I'll spawn an agent to implement structured logging across all modules"
2. **Metrics Agent** - "Another agent will add comprehensive metrics collection"
3. **Tracing Agent** - "A third agent will implement distributed tracing"
4. **Alerting Agent** - "I'll have an agent set up intelligent alerting and dashboards"

**Performance Considerations:**
- [ ] Minimal performance impact from instrumentation
- [ ] Asynchronous logging to avoid blocking operations
- [ ] Sampling strategies for high-volume traces
- [ ] Efficient metric aggregation and collection
- [ ] Resource limits for observability data storage

**Security and Privacy:**
- [ ] No sensitive data in logs or metrics
- [ ] Secure transmission of observability data
- [ ] Access controls for monitoring dashboards
- [ ] Audit logging for monitoring system access
- [ ] Data retention compliance

**Final Observability Validation:**
The observability implementation is complete when:
✓ Structured logging implemented across ALL components
✓ Comprehensive metrics collection for business and technical operations
✓ Distributed tracing covers all request flows
✓ Health checks validate all dependencies
✓ Intelligent alerting rules prevent issues
✓ Operational dashboards provide complete visibility
✓ Performance impact is minimal and acceptable
✓ Security and privacy requirements are met

**Final Commitment:**
I will now execute EVERY observability step listed above and IMPLEMENT COMPREHENSIVE MONITORING. I will:
- ✅ Audit current state and design comprehensive strategy
- ✅ SPAWN MULTIPLE AGENTS for different observability aspects
- ✅ Implement structured logging systematically
- ✅ Add comprehensive metrics collection
- ✅ Set up distributed tracing
- ✅ Create intelligent alerting and dashboards

I will NOT:
- ❌ Implement basic logging and call it monitoring
- ❌ Skip metrics or tracing implementation
- ❌ Create alerts without proper testing
- ❌ Accept performance degradation from instrumentation
- ❌ Compromise on security or privacy
- ❌ Stop before comprehensive validation

**REMEMBER: This is COMPREHENSIVE OBSERVABILITY, not basic logging!**

The observability is ready ONLY when every system component has full visibility.

**Executing comprehensive observability implementation NOW...**