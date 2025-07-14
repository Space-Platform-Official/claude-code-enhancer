---
allowed-tools: all
description: Profile, analyze, and implement performance optimizations with systematic benchmarking
---

# 🚀🚀🚀 CRITICAL REQUIREMENT: BENCHMARK EVERYTHING! 🚀🚀🚀

**THIS IS NOT A GUESSING TASK - THIS IS A SCIENTIFIC MEASUREMENT TASK!**

When you run `/optimize`, you are REQUIRED to:

1. **PROFILE FIRST** - Measure before optimizing anything
2. **IDENTIFY BOTTLENECKS** - Find actual performance issues, not perceived ones
3. **BENCHMARK BASELINE** - Establish concrete performance metrics
4. **USE MULTIPLE AGENTS** to optimize different areas in parallel:
   - Spawn one agent for CPU-bound optimizations
   - Spawn another for memory/allocation improvements
   - Spawn more agents for I/O and database optimizations
   - Say: "I'll spawn multiple agents to optimize different performance areas in parallel"
5. **IMPLEMENT SYSTEMATICALLY** - Fix one bottleneck at a time with measurement
6. **VERIFY IMPROVEMENTS** - Prove optimizations with before/after benchmarks
7. **ENSURE FUNCTIONALITY** - Guarantee zero behavior changes

**FORBIDDEN BEHAVIORS:**
- ❌ "This should be faster" → NO! MEASURE IT!
- ❌ "Let me optimize this obvious issue" → NO! PROFILE FIRST!
- ❌ "Performance looks good" → NO! SHOW BENCHMARKS!
- ❌ Optimizing without measuring → NO! DATA-DRIVEN ONLY!

**MANDATORY WORKFLOW:**
```
1. Profile → Find actual bottlenecks
2. IMMEDIATELY spawn agents to optimize different areas
3. Benchmark → Measure each optimization
4. Verify → Ensure functionality intact
5. REPEAT until performance targets met
```

**YOU ARE NOT DONE UNTIL:**
- All bottlenecks identified and addressed
- Before/after benchmarks prove improvements
- All tests pass with zero behavior changes
- Performance targets documented and achieved

---

🛑 **MANDATORY PERFORMANCE PROTOCOL** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify you're measuring actual performance, not guessing

Execute comprehensive performance optimization for: $ARGUMENTS

**FORBIDDEN OPTIMIZATION PATTERNS:**
- "This looks slow" → NO, measure it first
- "Let me add caching everywhere" → NO, profile to find what needs caching
- "More goroutines will make it faster" → NO, measure concurrency bottlenecks first
- "Database queries are obviously the issue" → NO, profile to confirm
- "Memory usage seems high" → NO, use profiling tools to quantify

Let me ultrathink about the systematic performance optimization approach for this system.

🚨 **REMEMBER: Premature optimization is the root of all evil - Profile first!** 🚨

**Performance Optimization Protocol:**

**Step 0: Performance Baseline Establishment**
- Run performance profiling tools (pprof for Go, profiling for other languages)
- Establish baseline metrics: CPU usage, memory allocation, latency, throughput
- Identify current performance characteristics and bottlenecks
- Document baseline with concrete numbers and measurements

**Step 1: Bottleneck Analysis**
- Use CPU profiling to identify hot paths and expensive functions
- Use memory profiling to find allocation patterns and leaks
- Use benchmarking tools to measure critical path performance
- Analyze I/O patterns, database queries, and network usage

**Step 2: Systematic Optimization Strategy**
Run targeted optimizations based on profiling data:
- For CPU bottlenecks: Algorithm improvements, reduce computational complexity
- For memory issues: Reduce allocations, improve garbage collection patterns
- For I/O bottlenecks: Batching, connection pooling, async operations
- For database issues: Query optimization, indexing, connection management

**Performance Requirements:**
- EVERY optimization must be preceded by profiling
- EVERY change must include before/after benchmarks
- ZERO functional changes - behavior must remain identical
- Performance improvements must be measurable and significant (>10% improvement minimum)

**For Go projects specifically:**
- Use go tool pprof for CPU and memory profiling
- Run benchmarks with go test -bench for performance-critical functions
- Check for goroutine leaks and race conditions
- Optimize allocation patterns to reduce GC pressure
- Use sync.Pool for frequently allocated objects
- Implement proper context cancellation for timeouts
- Avoid unnecessary interface{} conversions in hot paths

**Step 3: Benchmark-Driven Development**
Write comprehensive benchmarks:
- Benchmark critical paths and hot functions
- Test with realistic data volumes and usage patterns
- Include comparative benchmarks showing before/after results
- Test under load conditions that match production usage
- Document performance characteristics and expected behavior

**Optimization Quality Checklist:**
- [ ] Baseline performance metrics documented with numbers
- [ ] Profiling data analyzed to identify actual bottlenecks
- [ ] CPU hot paths identified and optimized
- [ ] Memory allocation patterns improved
- [ ] I/O and database performance optimized
- [ ] Before/after benchmarks show measurable improvement
- [ ] All functionality tests pass - zero behavior changes
- [ ] Performance tests added to prevent regressions

**Code Performance Verification:**
- [ ] No premature optimizations without profiling evidence
- [ ] No micro-optimizations without macro impact measurement
- [ ] No complexity increases without significant performance gains
- [ ] Optimizations focused on actual bottlenecks from profiling
- [ ] Performance improvements sustainable under realistic load
- [ ] Memory usage patterns improved (lower allocation rate)
- [ ] CPU usage patterns improved (reduced hot path execution time)

**Security and Reliability Audit:**
- [ ] Performance optimizations maintain security properties
- [ ] Error handling remains robust after optimizations
- [ ] Timeout and cancellation behavior preserved
- [ ] Resource cleanup still functions properly
- [ ] No new race conditions introduced
- [ ] Graceful degradation under load maintained

**Performance Monitoring Setup:**
- [ ] Key performance metrics identified and monitored
- [ ] Benchmarks integrated into CI pipeline
- [ ] Performance regression detection configured
- [ ] Production performance monitoring instrumented
- [ ] Alert thresholds defined for performance degradation
- [ ] Regular performance review process established

**Failure Response Protocol:**
When performance issues are found:
1. **IMMEDIATELY SPAWN AGENTS** to optimize different areas in parallel:
   ```
   "Profiling revealed 3 major bottlenecks: CPU-intensive algorithm in service A, 
   memory leaks in component B, and database N+1 queries in module C. 
   I'll spawn agents to optimize these areas:
   - Agent 1: Optimize algorithm complexity in service A
   - Agent 2: Fix memory allocation patterns in component B  
   - Agent 3: Implement query batching for module C
   Let me tackle all performance issues in parallel..."
   ```
2. **OPTIMIZE SYSTEMATICALLY** - Address bottlenecks based on profiling evidence
3. **BENCHMARK** - Measure every optimization with concrete numbers
4. **VERIFY** - Ensure all functionality remains intact after optimizations
5. **REPEAT** - Continue optimizing until performance targets are met
6. **NO GUESSING** - Every optimization decision backed by measurement data
7. **ESCALATE** - Only ask for help if blocked after attempting evidence-based fixes

**Final Performance Verification:**
The optimization is complete when:
✓ Profiling data shows identified bottlenecks resolved
✓ Benchmarks demonstrate measurable performance improvement (>10%)
✓ ALL functionality tests pass with zero behavior changes
✓ Performance tests prevent future regressions
✓ System performs within acceptable parameters under realistic load
✓ Documentation includes performance characteristics and optimization rationale

**Final Commitment:**
I will now execute EVERY optimization step listed above and MEASURE ALL IMPROVEMENTS. I will:
- ✅ Profile first to identify actual bottlenecks
- ✅ SPAWN MULTIPLE AGENTS to optimize different areas in parallel
- ✅ Benchmark every optimization with before/after measurements
- ✅ Ensure zero functional changes while maximizing performance
- ✅ Not stop until all performance targets are achieved

I will NOT:
- ❌ Optimize without profiling evidence
- ❌ Guess at performance issues
- ❌ Skip benchmarking any changes
- ❌ Change functionality while optimizing
- ❌ Stop at "feels faster"
- ❌ Make micro-optimizations without macro impact

**REMEMBER: This is a MEASUREMENT and OPTIMIZATION task, not a guessing task!**

The optimization is complete ONLY when every metric shows measurable improvement.

**Executing systematic performance optimization with comprehensive profiling NOW...**