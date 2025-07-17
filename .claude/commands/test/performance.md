---
allowed-tools: all
description: Execute performance and load tests with comprehensive benchmarking and scalability validation
intensity: ⚡⚡⚡⚡⚡
pattern: 🚀🚀🚀🚀🚀
---

# 🚀🚀🚀🚀🚀 CRITICAL PERFORMANCE TESTING: COMPREHENSIVE BENCHMARKING AND SCALABILITY! 🚀🚀🚀🚀🚀

**THIS IS NOT A SIMPLE PERFORMANCE CHECK - THIS IS A COMPREHENSIVE PERFORMANCE TESTING SYSTEM!**

When you run `/test performance`, you are REQUIRED to:

1. **EXECUTE** comprehensive performance tests and benchmarks
2. **VALIDATE** system performance under realistic load conditions
3. **IDENTIFY** performance bottlenecks and optimization opportunities
4. **USE MULTIPLE AGENTS** for parallel performance testing:
   - Spawn one agent per performance test type or system component
   - Spawn agents for different load patterns and scenarios
   - Say: "I'll spawn multiple agents to execute performance tests across all system components in parallel"
5. **ANALYZE** performance metrics and generate actionable insights
6. **OPTIMIZE** performance based on test results and recommendations

## 🎯 USE MULTIPLE AGENTS

**MANDATORY AGENT SPAWNING FOR PERFORMANCE TESTING:**
```
"I'll spawn multiple agents to handle performance testing comprehensively:
- Load Testing Agent: Execute load tests with realistic user scenarios
- Stress Testing Agent: Test system limits and breaking points
- Benchmark Agent: Run micro-benchmarks for critical functions
- Scalability Agent: Test horizontal and vertical scaling characteristics
- Memory Profiling Agent: Analyze memory usage patterns and leaks
- CPU Profiling Agent: Identify CPU bottlenecks and optimization opportunities
- Database Performance Agent: Test database query performance and optimization"
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ Skip performance testing → NO! Performance is critical for user experience!
- ❌ Test only under ideal conditions → NO! Test realistic load scenarios!
- ❌ Ignore performance regressions → NO! Track performance over time!
- ❌ "Performance is good enough" → NO! Continuously optimize!
- ❌ Skip scalability testing → NO! Validate system scaling capabilities!
- ❌ Only test happy paths → NO! Test error conditions under load!

**MANDATORY WORKFLOW:**
```
1. Performance baseline establishment → Set current performance metrics
2. IMMEDIATELY spawn agents for parallel performance testing
3. Load and stress testing → Validate system under realistic conditions
4. Benchmark execution → Test critical functions and operations
5. Scalability validation → Test scaling characteristics
6. VERIFY performance targets and optimization opportunities
```

**YOU ARE NOT DONE UNTIL:**
- ✅ ALL performance tests are executed and analyzed
- ✅ System performance under load is validated
- ✅ Performance bottlenecks are identified and addressed
- ✅ Scalability characteristics are documented
- ✅ Performance optimization recommendations are provided
- ✅ Performance monitoring is implemented

---

🛑 **MANDATORY PERFORMANCE TESTING CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current system performance characteristics
3. Verify you understand the performance testing requirements

Execute comprehensive performance testing for: $ARGUMENTS

**FORBIDDEN SHORTCUT PATTERNS:**
- "Performance testing is too complex" → NO, it's essential for quality!
- "System seems fast enough" → NO, measure and validate!
- "Load testing is optional" → NO, validate under realistic conditions!
- "Optimization can wait" → NO, optimize based on test results!
- "Scalability testing is future work" → NO, validate scaling now!

Let me ultrathink about the comprehensive performance testing architecture and execution strategy.

🚨 **REMEMBER: Performance testing prevents production issues and ensures great user experience!** 🚨

**Comprehensive Performance Testing Protocol:**

**Step 0: Performance Testing Infrastructure Setup**
- Set up performance testing environment and tools
- Configure monitoring and profiling infrastructure
- Establish performance baselines and targets
- Prepare test data and realistic scenarios
- Set up automated performance reporting

**Step 1: Performance Baseline Establishment**

**Baseline Metrics Collection:**
```typescript
interface PerformanceBaseline {
  response_times: {
    p50: number;
    p95: number;
    p99: number;
    mean: number;
    max: number;
  };
  throughput: {
    requests_per_second: number;
    transactions_per_second: number;
    concurrent_users: number;
  };
  resource_utilization: {
    cpu_usage: number;
    memory_usage: number;
    disk_io: number;
    network_io: number;
  };
  error_rates: {
    total_errors: number;
    error_percentage: number;
    error_types: Map<string, number>;
  };
  database_performance: {
    query_response_time: number;
    connection_pool_usage: number;
    slow_queries: number;
  };
}

class PerformanceBaselineEstablisher {
  async establishBaseline(system: SystemUnderTest): Promise<PerformanceBaseline> {
    console.log('📊 Establishing performance baseline...');
    
    // Warm up the system
    await this.warmUpSystem(system);
    
    // Run baseline tests
    const baselineResults = await this.runBaselineTests(system);
    
    // Collect system metrics
    const systemMetrics = await this.collectSystemMetrics(system);
    
    // Analyze results
    const baseline = this.analyzeBaseline(baselineResults, systemMetrics);
    
    // Store baseline for future comparisons
    await this.storeBaseline(baseline);
    
    return baseline;
  }
  
  private async runBaselineTests(system: SystemUnderTest): Promise<TestResult[]> {
    const tests = [
      {
        name: 'Single User Load',
        users: 1,
        duration: 300, // 5 minutes
        ramp_up: 30,
        scenarios: await this.getBaselineScenarios()
      },
      {
        name: 'Light Load',
        users: 10,
        duration: 300,
        ramp_up: 60,
        scenarios: await this.getBaselineScenarios()
      },
      {
        name: 'Normal Load',
        users: 50,
        duration: 600,
        ramp_up: 120,
        scenarios: await this.getBaselineScenarios()
      }
    ];
    
    const results = [];
    
    for (const test of tests) {
      console.log(`⚡ Running baseline test: ${test.name}`);
      
      const result = await this.executeLoadTest(test);
      results.push(result);
      
      // Wait between tests
      await this.sleep(30000);
    }
    
    return results;
  }
  
  private async getBaselineScenarios(): Promise<LoadTestScenario[]> {
    return [
      {
        name: 'User Login',
        weight: 20,
        steps: [
          { action: 'POST', url: '/api/auth/login', data: '{{user_credentials}}' },
          { action: 'GET', url: '/api/user/profile' }
        ]
      },
      {
        name: 'Browse Products',
        weight: 40,
        steps: [
          { action: 'GET', url: '/api/products' },
          { action: 'GET', url: '/api/products/{{product_id}}' },
          { action: 'GET', url: '/api/products/{{product_id}}/reviews' }
        ]
      },
      {
        name: 'Add to Cart',
        weight: 30,
        steps: [
          { action: 'POST', url: '/api/cart/add', data: '{{cart_item}}' },
          { action: 'GET', url: '/api/cart' }
        ]
      },
      {
        name: 'Checkout',
        weight: 10,
        steps: [
          { action: 'POST', url: '/api/checkout', data: '{{checkout_data}}' },
          { action: 'GET', url: '/api/orders/{{order_id}}' }
        ]
      }
    ];
  }
}
```

**Step 2: Parallel Agent Deployment for Performance Testing**

**Agent Spawning Strategy:**
```
"I've identified comprehensive performance testing requirements. I'll spawn specialized agents:

1. **Load Testing Agent**: 'Execute realistic load tests with multiple user scenarios'
2. **Stress Testing Agent**: 'Test system limits and breaking points under extreme load'
3. **Benchmark Agent**: 'Run micro-benchmarks for critical functions and operations'
4. **Scalability Agent**: 'Test horizontal and vertical scaling characteristics'
5. **Memory Profiling Agent**: 'Analyze memory usage patterns and detect leaks'
6. **CPU Profiling Agent**: 'Identify CPU bottlenecks and optimization opportunities'
7. **Database Performance Agent**: 'Test database performance and query optimization'
8. **Network Performance Agent**: 'Test network latency and bandwidth requirements'
9. **Endurance Agent**: 'Test system stability over extended periods'

Each agent will execute specialized performance tests while coordinating to provide comprehensive performance analysis."
```

**Step 3: Load Testing Implementation**

**Load Testing Framework:**
```typescript
class LoadTestExecutor {
  async executeLoadTests(scenarios: LoadTestScenario[]): Promise<LoadTestResults> {
    console.log('🚀 Executing load tests...');
    
    const testSuites = [
      {
        name: 'Normal Load Test',
        users: 100,
        duration: 600, // 10 minutes
        ramp_up: 120,
        scenarios: scenarios
      },
      {
        name: 'Peak Load Test',
        users: 500,
        duration: 300, // 5 minutes
        ramp_up: 60,
        scenarios: scenarios
      },
      {
        name: 'Spike Test',
        users: 1000,
        duration: 180, // 3 minutes
        ramp_up: 30,
        scenarios: scenarios
      },
      {
        name: 'Volume Test',
        users: 200,
        duration: 3600, // 1 hour
        ramp_up: 300,
        scenarios: scenarios
      }
    ];
    
    const results = [];
    
    for (const suite of testSuites) {
      console.log(`⚡ Running load test suite: ${suite.name}`);
      
      // Prepare test environment
      await this.prepareTestEnvironment(suite);
      
      // Execute load test
      const result = await this.executeLoadTestSuite(suite);
      
      // Collect metrics
      const metrics = await this.collectLoadTestMetrics(suite);
      
      // Analyze results
      const analysis = await this.analyzeLoadTestResults(result, metrics);
      
      results.push({
        suite_name: suite.name,
        configuration: suite,
        raw_results: result,
        metrics: metrics,
        analysis: analysis
      });
      
      // Cool down between tests
      await this.coolDownSystem(120000); // 2 minutes
    }
    
    return this.compileLoadTestResults(results);
  }
  
  private async executeLoadTestSuite(suite: LoadTestSuite): Promise<LoadTestResult> {
    const testRunner = new LoadTestRunner(suite);
    
    // Start monitoring
    const monitoring = await this.startMonitoring(suite);
    
    // Execute test
    const startTime = Date.now();
    const result = await testRunner.execute();
    const endTime = Date.now();
    
    // Stop monitoring
    const monitoringData = await this.stopMonitoring(monitoring);
    
    return {
      suite_name: suite.name,
      start_time: startTime,
      end_time: endTime,
      duration: endTime - startTime,
      test_results: result,
      monitoring_data: monitoringData,
      success: result.error_rate < 0.01 // Less than 1% error rate
    };
  }
  
  private async analyzeLoadTestResults(
    result: LoadTestResult, 
    metrics: SystemMetrics
  ): Promise<LoadTestAnalysis> {
    return {
      performance_summary: {
        avg_response_time: this.calculateAverageResponseTime(result),
        p95_response_time: this.calculateP95ResponseTime(result),
        p99_response_time: this.calculateP99ResponseTime(result),
        throughput: this.calculateThroughput(result),
        error_rate: this.calculateErrorRate(result),
        concurrent_users: result.max_concurrent_users
      },
      bottlenecks: this.identifyBottlenecks(result, metrics),
      scalability_assessment: this.assessScalability(result, metrics),
      optimization_recommendations: this.generateOptimizationRecommendations(result, metrics),
      performance_trends: this.analyzeTrends(result),
      sla_compliance: this.checkSLACompliance(result)
    };
  }
  
  private identifyBottlenecks(
    result: LoadTestResult, 
    metrics: SystemMetrics
  ): PerformanceBottleneck[] {
    const bottlenecks = [];
    
    // CPU bottlenecks
    if (metrics.cpu_usage > 80) {
      bottlenecks.push({
        type: 'CPU',
        severity: 'high',
        description: `CPU usage reached ${metrics.cpu_usage}%`,
        impact: 'Response time degradation',
        recommendations: [
          'Optimize CPU-intensive operations',
          'Implement caching',
          'Consider horizontal scaling'
        ]
      });
    }
    
    // Memory bottlenecks
    if (metrics.memory_usage > 85) {
      bottlenecks.push({
        type: 'Memory',
        severity: 'high',
        description: `Memory usage reached ${metrics.memory_usage}%`,
        impact: 'Risk of out-of-memory errors',
        recommendations: [
          'Optimize memory usage',
          'Implement memory pooling',
          'Fix memory leaks'
        ]
      });
    }
    
    // Database bottlenecks
    if (metrics.database_response_time > 500) {
      bottlenecks.push({
        type: 'Database',
        severity: 'medium',
        description: `Database response time: ${metrics.database_response_time}ms`,
        impact: 'Overall response time increase',
        recommendations: [
          'Optimize database queries',
          'Add database indexes',
          'Implement query caching'
        ]
      });
    }
    
    // Network bottlenecks
    if (metrics.network_latency > 100) {
      bottlenecks.push({
        type: 'Network',
        severity: 'medium',
        description: `Network latency: ${metrics.network_latency}ms`,
        impact: 'Increased response times',
        recommendations: [
          'Optimize network calls',
          'Implement connection pooling',
          'Use CDN for static assets'
        ]
      });
    }
    
    return bottlenecks;
  }
}
```

**Step 4: Stress Testing Implementation**

**Stress Testing Framework:**
```typescript
class StressTestExecutor {
  async executeStressTests(system: SystemUnderTest): Promise<StressTestResults> {
    console.log('💪 Executing stress tests...');
    
    const stressTests = [
      {
        name: 'CPU Stress Test',
        type: 'cpu',
        duration: 300,
        intensity: 'high',
        metrics: ['cpu_usage', 'response_time', 'throughput']
      },
      {
        name: 'Memory Stress Test',
        type: 'memory',
        duration: 600,
        intensity: 'high',
        metrics: ['memory_usage', 'gc_frequency', 'response_time']
      },
      {
        name: 'Concurrent User Stress Test',
        type: 'concurrency',
        duration: 300,
        intensity: 'extreme',
        metrics: ['response_time', 'error_rate', 'throughput']
      },
      {
        name: 'Database Stress Test',
        type: 'database',
        duration: 600,
        intensity: 'high',
        metrics: ['db_response_time', 'connection_pool', 'query_performance']
      },
      {
        name: 'Network Stress Test',
        type: 'network',
        duration: 300,
        intensity: 'high',
        metrics: ['network_latency', 'bandwidth_usage', 'connection_errors']
      }
    ];
    
    const results = [];
    
    for (const test of stressTests) {
      console.log(`💪 Running stress test: ${test.name}`);
      
      const result = await this.executeStressTest(test);
      results.push(result);
      
      // Recovery time between tests
      await this.allowSystemRecovery(180000); // 3 minutes
    }
    
    return this.compileStressTestResults(results);
  }
  
  private async executeStressTest(test: StressTest): Promise<StressTestResult> {
    const executor = this.getStressTestExecutor(test.type);
    
    // Start monitoring
    const monitoring = await this.startStressMonitoring(test);
    
    // Execute stress test
    const startTime = Date.now();
    const result = await executor.execute(test);
    const endTime = Date.now();
    
    // Stop monitoring
    const monitoringData = await this.stopMonitoring(monitoring);
    
    // Analyze breaking points
    const breakingPoints = await this.analyzeBreakingPoints(result, monitoringData);
    
    // Analyze recovery characteristics
    const recoveryAnalysis = await this.analyzeRecovery(result, monitoringData);
    
    return {
      test_name: test.name,
      test_type: test.type,
      duration: endTime - startTime,
      max_load_achieved: result.max_load,
      breaking_points: breakingPoints,
      recovery_analysis: recoveryAnalysis,
      performance_degradation: this.analyzePerformanceDegradation(result),
      system_limits: this.identifySystemLimits(result, monitoringData),
      stability_assessment: this.assessStability(result, monitoringData)
    };
  }
  
  private async analyzeBreakingPoints(
    result: any, 
    monitoring: MonitoringData
  ): Promise<BreakingPoint[]> {
    const breakingPoints = [];
    
    // CPU breaking point
    const cpuBreakingPoint = this.findCpuBreakingPoint(monitoring.cpu_timeline);
    if (cpuBreakingPoint) {
      breakingPoints.push({
        type: 'CPU',
        threshold: cpuBreakingPoint.threshold,
        load_at_breaking_point: cpuBreakingPoint.load,
        symptoms: cpuBreakingPoint.symptoms,
        recovery_time: cpuBreakingPoint.recovery_time
      });
    }
    
    // Memory breaking point
    const memoryBreakingPoint = this.findMemoryBreakingPoint(monitoring.memory_timeline);
    if (memoryBreakingPoint) {
      breakingPoints.push({
        type: 'Memory',
        threshold: memoryBreakingPoint.threshold,
        load_at_breaking_point: memoryBreakingPoint.load,
        symptoms: memoryBreakingPoint.symptoms,
        recovery_time: memoryBreakingPoint.recovery_time
      });
    }
    
    // Response time breaking point
    const responseTimeBreakingPoint = this.findResponseTimeBreakingPoint(result.response_times);
    if (responseTimeBreakingPoint) {
      breakingPoints.push({
        type: 'Response Time',
        threshold: responseTimeBreakingPoint.threshold,
        load_at_breaking_point: responseTimeBreakingPoint.load,
        symptoms: responseTimeBreakingPoint.symptoms,
        recovery_time: responseTimeBreakingPoint.recovery_time
      });
    }
    
    return breakingPoints;
  }
  
  private getStressTestExecutor(type: string): StressTestExecutor {
    const executors = {
      cpu: new CpuStressExecutor(),
      memory: new MemoryStressExecutor(),
      concurrency: new ConcurrencyStressExecutor(),
      database: new DatabaseStressExecutor(),
      network: new NetworkStressExecutor()
    };
    
    return executors[type] || new GenericStressExecutor();
  }
}
```

**Step 5: Benchmark Testing Implementation**

**Benchmark Testing Framework:**
```typescript
class BenchmarkTestExecutor {
  async executeBenchmarkTests(criticalFunctions: CriticalFunction[]): Promise<BenchmarkResults> {
    console.log('🏃 Executing benchmark tests...');
    
    const benchmarkSuites = [
      {
        name: 'Micro-benchmarks',
        type: 'micro',
        functions: criticalFunctions.filter(f => f.complexity === 'low'),
        iterations: 100000,
        warmup_iterations: 10000
      },
      {
        name: 'Component-benchmarks',
        type: 'component',
        functions: criticalFunctions.filter(f => f.complexity === 'medium'),
        iterations: 10000,
        warmup_iterations: 1000
      },
      {
        name: 'System-benchmarks',
        type: 'system',
        functions: criticalFunctions.filter(f => f.complexity === 'high'),
        iterations: 1000,
        warmup_iterations: 100
      }
    ];
    
    const results = [];
    
    for (const suite of benchmarkSuites) {
      console.log(`🏃 Running benchmark suite: ${suite.name}`);
      
      const suiteResults = await this.executeBenchmarkSuite(suite);
      results.push(suiteResults);
    }
    
    return this.compileBenchmarkResults(results);
  }
  
  private async executeBenchmarkSuite(suite: BenchmarkSuite): Promise<BenchmarkSuiteResult> {
    const functionResults = [];
    
    for (const func of suite.functions) {
      console.log(`⚡ Benchmarking function: ${func.name}`);
      
      const result = await this.benchmarkFunction(func, suite);
      functionResults.push(result);
    }
    
    return {
      suite_name: suite.name,
      suite_type: suite.type,
      function_results: functionResults,
      summary: this.summarizeBenchmarkSuite(functionResults),
      performance_insights: this.generatePerformanceInsights(functionResults)
    };
  }
  
  private async benchmarkFunction(
    func: CriticalFunction, 
    suite: BenchmarkSuite
  ): Promise<BenchmarkResult> {
    const measurements = [];
    
    // Warmup phase
    console.log(`🔥 Warming up ${func.name}...`);
    for (let i = 0; i < suite.warmup_iterations; i++) {
      await this.executeFunction(func);
    }
    
    // Measurement phase
    console.log(`📊 Measuring ${func.name}...`);
    for (let i = 0; i < suite.iterations; i++) {
      const startTime = process.hrtime.bigint();
      const startMemory = process.memoryUsage();
      
      await this.executeFunction(func);
      
      const endTime = process.hrtime.bigint();
      const endMemory = process.memoryUsage();
      
      measurements.push({
        execution_time: Number(endTime - startTime) / 1000000, // Convert to milliseconds
        memory_delta: endMemory.heapUsed - startMemory.heapUsed,
        cpu_time: this.measureCpuTime(func)
      });
    }
    
    // Analyze measurements
    const analysis = this.analyzeBenchmarkMeasurements(measurements);
    
    return {
      function_name: func.name,
      function_type: func.type,
      iterations: suite.iterations,
      measurements: measurements,
      analysis: analysis,
      performance_metrics: {
        min_time: Math.min(...measurements.map(m => m.execution_time)),
        max_time: Math.max(...measurements.map(m => m.execution_time)),
        mean_time: this.calculateMean(measurements.map(m => m.execution_time)),
        median_time: this.calculateMedian(measurements.map(m => m.execution_time)),
        p95_time: this.calculatePercentile(measurements.map(m => m.execution_time), 95),
        p99_time: this.calculatePercentile(measurements.map(m => m.execution_time), 99),
        standard_deviation: this.calculateStandardDeviation(measurements.map(m => m.execution_time)),
        throughput: suite.iterations / (analysis.total_time / 1000) // ops/second
      }
    };
  }
  
  private analyzeBenchmarkMeasurements(measurements: Measurement[]): BenchmarkAnalysis {
    const executionTimes = measurements.map(m => m.execution_time);
    const memoryUsages = measurements.map(m => m.memory_delta);
    
    return {
      total_time: executionTimes.reduce((a, b) => a + b, 0),
      time_consistency: this.calculateConsistency(executionTimes),
      memory_consistency: this.calculateConsistency(memoryUsages),
      performance_stability: this.assessPerformanceStability(measurements),
      outliers: this.identifyOutliers(measurements),
      performance_trend: this.analyzePerformanceTrend(measurements),
      optimization_opportunities: this.identifyOptimizationOpportunities(measurements)
    };
  }
  
  private identifyOptimizationOpportunities(measurements: Measurement[]): OptimizationOpportunity[] {
    const opportunities = [];
    
    // High variance indicates optimization potential
    const timeVariance = this.calculateVariance(measurements.map(m => m.execution_time));
    if (timeVariance > 0.2) {
      opportunities.push({
        type: 'Performance Consistency',
        description: 'High variance in execution times',
        impact: 'medium',
        recommendation: 'Investigate and optimize inconsistent performance'
      });
    }
    
    // High memory usage indicates memory optimization potential
    const avgMemoryUsage = this.calculateMean(measurements.map(m => m.memory_delta));
    if (avgMemoryUsage > 1000000) { // 1MB
      opportunities.push({
        type: 'Memory Optimization',
        description: 'High memory usage per operation',
        impact: 'high',
        recommendation: 'Optimize memory allocation and reduce object creation'
      });
    }
    
    // Slow operations indicate algorithmic optimization potential
    const avgExecutionTime = this.calculateMean(measurements.map(m => m.execution_time));
    if (avgExecutionTime > 100) { // 100ms
      opportunities.push({
        type: 'Algorithmic Optimization',
        description: 'Slow operation execution',
        impact: 'high',
        recommendation: 'Review algorithm efficiency and data structures'
      });
    }
    
    return opportunities;
  }
}
```

**Step 6: Scalability Testing Implementation**

**Scalability Testing Framework:**
```typescript
class ScalabilityTestExecutor {
  async executeScalabilityTests(system: SystemUnderTest): Promise<ScalabilityResults> {
    console.log('📈 Executing scalability tests...');
    
    const scalabilityTests = [
      {
        name: 'Horizontal Scalability',
        type: 'horizontal',
        configurations: [
          { instances: 1, load: 100 },
          { instances: 2, load: 200 },
          { instances: 4, load: 400 },
          { instances: 8, load: 800 }
        ]
      },
      {
        name: 'Vertical Scalability',
        type: 'vertical',
        configurations: [
          { cpu: 1, memory: '1GB', load: 100 },
          { cpu: 2, memory: '2GB', load: 200 },
          { cpu: 4, memory: '4GB', load: 400 },
          { cpu: 8, memory: '8GB', load: 800 }
        ]
      },
      {
        name: 'Database Scalability',
        type: 'database',
        configurations: [
          { connections: 10, load: 50 },
          { connections: 50, load: 250 },
          { connections: 100, load: 500 },
          { connections: 200, load: 1000 }
        ]
      }
    ];
    
    const results = [];
    
    for (const test of scalabilityTests) {
      console.log(`📈 Running scalability test: ${test.name}`);
      
      const result = await this.executeScalabilityTest(test);
      results.push(result);
    }
    
    return this.compileScalabilityResults(results);
  }
  
  private async executeScalabilityTest(test: ScalabilityTest): Promise<ScalabilityTestResult> {
    const configurationResults = [];
    
    for (const config of test.configurations) {
      console.log(`⚙️  Testing configuration: ${JSON.stringify(config)}`);
      
      // Apply configuration
      await this.applyConfiguration(config, test.type);
      
      // Wait for system to stabilize
      await this.waitForStabilization(60000); // 1 minute
      
      // Execute load test
      const loadResult = await this.executeLoadTest({
        users: config.load,
        duration: 300, // 5 minutes
        ramp_up: 60
      });
      
      // Collect metrics
      const metrics = await this.collectScalabilityMetrics(config);
      
      configurationResults.push({
        configuration: config,
        load_result: loadResult,
        metrics: metrics,
        efficiency: this.calculateScalingEfficiency(config, loadResult, metrics)
      });
    }
    
    return {
      test_name: test.name,
      test_type: test.type,
      configuration_results: configurationResults,
      scaling_analysis: this.analyzeScalingCharacteristics(configurationResults),
      bottlenecks: this.identifyScalingBottlenecks(configurationResults),
      recommendations: this.generateScalingRecommendations(configurationResults)
    };
  }
  
  private analyzeScalingCharacteristics(results: ConfigurationResult[]): ScalingAnalysis {
    const analysis = {
      linear_scaling: this.assessLinearScaling(results),
      scaling_efficiency: this.calculateOverallScalingEfficiency(results),
      optimal_configuration: this.identifyOptimalConfiguration(results),
      scaling_limits: this.identifyScalingLimits(results),
      cost_effectiveness: this.analyzeCostEffectiveness(results)
    };
    
    return analysis;
  }
  
  private assessLinearScaling(results: ConfigurationResult[]): LinearScalingAssessment {
    const throughputs = results.map(r => r.load_result.throughput);
    const resources = results.map(r => this.calculateResourceUnit(r.configuration));
    
    // Calculate correlation coefficient
    const correlation = this.calculateCorrelation(resources, throughputs);
    
    return {
      correlation_coefficient: correlation,
      is_linear: correlation > 0.8,
      scaling_factor: this.calculateScalingFactor(resources, throughputs),
      deviations: this.identifyScalingDeviations(resources, throughputs)
    };
  }
  
  private identifyScalingBottlenecks(results: ConfigurationResult[]): ScalingBottleneck[] {
    const bottlenecks = [];
    
    // Identify configuration where scaling efficiency drops
    for (let i = 1; i < results.length; i++) {
      const prev = results[i - 1];
      const curr = results[i];
      
      const efficiencyDrop = prev.efficiency - curr.efficiency;
      
      if (efficiencyDrop > 0.2) { // 20% efficiency drop
        bottlenecks.push({
          type: 'Scaling Efficiency Drop',
          configuration: curr.configuration,
          description: `Efficiency dropped from ${prev.efficiency.toFixed(2)} to ${curr.efficiency.toFixed(2)}`,
          impact: 'high',
          likely_causes: this.identifyLikelyCauses(prev, curr)
        });
      }
    }
    
    // Identify resource-specific bottlenecks
    const resourceBottlenecks = this.identifyResourceBottlenecks(results);
    bottlenecks.push(...resourceBottlenecks);
    
    return bottlenecks;
  }
}
```

**Step 7: Memory and CPU Profiling**

**Profiling Framework:**
```typescript
class PerformanceProfiler {
  async executeProfilingTests(system: SystemUnderTest): Promise<ProfilingResults> {
    console.log('🔍 Executing profiling tests...');
    
    const profilingTests = [
      {
        name: 'Memory Profiling',
        type: 'memory',
        duration: 600, // 10 minutes
        scenarios: ['normal_load', 'peak_load', 'stress_load']
      },
      {
        name: 'CPU Profiling',
        type: 'cpu',
        duration: 300, // 5 minutes
        scenarios: ['normal_load', 'peak_load', 'stress_load']
      },
      {
        name: 'I/O Profiling',
        type: 'io',
        duration: 600, // 10 minutes
        scenarios: ['normal_load', 'peak_load', 'stress_load']
      }
    ];
    
    const results = [];
    
    for (const test of profilingTests) {
      console.log(`🔍 Running profiling test: ${test.name}`);
      
      const result = await this.executeProfilingTest(test);
      results.push(result);
    }
    
    return this.compileProfilingResults(results);
  }
  
  private async executeProfilingTest(test: ProfilingTest): Promise<ProfilingTestResult> {
    const scenarioResults = [];
    
    for (const scenario of test.scenarios) {
      console.log(`📊 Profiling scenario: ${scenario}`);
      
      const profiler = this.getProfiler(test.type);
      
      // Start profiling
      await profiler.start();
      
      // Execute scenario
      await this.executeScenario(scenario, test.duration);
      
      // Stop profiling and collect data
      const profilingData = await profiler.stop();
      
      // Analyze profiling data
      const analysis = await this.analyzeProfilingData(profilingData, test.type);
      
      scenarioResults.push({
        scenario: scenario,
        profiling_data: profilingData,
        analysis: analysis
      });
    }
    
    return {
      test_name: test.name,
      test_type: test.type,
      scenario_results: scenarioResults,
      overall_analysis: this.analyzeOverallProfiling(scenarioResults),
      optimization_opportunities: this.identifyOptimizationOpportunities(scenarioResults)
    };
  }
  
  private async analyzeProfilingData(data: ProfilingData, type: string): Promise<ProfilingAnalysis> {
    switch (type) {
      case 'memory':
        return this.analyzeMemoryProfiling(data);
      case 'cpu':
        return this.analyzeCpuProfiling(data);
      case 'io':
        return this.analyzeIoProfiling(data);
      default:
        throw new Error(`Unknown profiling type: ${type}`);
    }
  }
  
  private analyzeMemoryProfiling(data: ProfilingData): MemoryProfilingAnalysis {
    return {
      heap_usage: {
        min: Math.min(...data.heap_timeline),
        max: Math.max(...data.heap_timeline),
        average: this.calculateMean(data.heap_timeline),
        growth_rate: this.calculateGrowthRate(data.heap_timeline)
      },
      memory_leaks: this.detectMemoryLeaks(data),
      garbage_collection: {
        frequency: data.gc_events.length,
        average_duration: this.calculateMean(data.gc_events.map(e => e.duration)),
        total_pause_time: data.gc_events.reduce((sum, e) => sum + e.duration, 0)
      },
      allocation_patterns: this.analyzeAllocationPatterns(data),
      hotspots: this.identifyMemoryHotspots(data)
    };
  }
  
  private analyzeCpuProfiling(data: ProfilingData): CpuProfilingAnalysis {
    return {
      cpu_usage: {
        min: Math.min(...data.cpu_timeline),
        max: Math.max(...data.cpu_timeline),
        average: this.calculateMean(data.cpu_timeline),
        variance: this.calculateVariance(data.cpu_timeline)
      },
      hotspots: this.identifyCpuHotspots(data),
      call_graph: this.analyzeCallGraph(data),
      function_performance: this.analyzeFunctionPerformance(data),
      bottlenecks: this.identifyCpuBottlenecks(data)
    };
  }
  
  private detectMemoryLeaks(data: ProfilingData): MemoryLeak[] {
    const leaks = [];
    
    // Analyze heap growth patterns
    const heapGrowth = this.analyzeHeapGrowth(data.heap_timeline);
    
    if (heapGrowth.is_consistently_growing) {
      leaks.push({
        type: 'Heap Growth',
        severity: 'high',
        description: 'Consistent heap growth detected',
        growth_rate: heapGrowth.rate,
        suspected_causes: this.identifyLeakCauses(data)
      });
    }
    
    // Analyze object retention
    const retentionAnalysis = this.analyzeObjectRetention(data);
    
    if (retentionAnalysis.has_retention_issues) {
      leaks.push({
        type: 'Object Retention',
        severity: 'medium',
        description: 'Objects not being garbage collected',
        retained_objects: retentionAnalysis.retained_objects,
        suspected_causes: retentionAnalysis.suspected_causes
      });
    }
    
    return leaks;
  }
  
  private identifyCpuHotspots(data: ProfilingData): CpuHotspot[] {
    const hotspots = [];
    
    // Analyze function call frequency and duration
    const functionStats = this.analyzeFunctionStats(data.call_traces);
    
    for (const [functionName, stats] of functionStats) {
      if (stats.total_time > 1000 || stats.call_count > 10000) {
        hotspots.push({
          function_name: functionName,
          total_time: stats.total_time,
          call_count: stats.call_count,
          average_time: stats.total_time / stats.call_count,
          percentage_of_total: (stats.total_time / data.total_execution_time) * 100,
          optimization_potential: this.assessOptimizationPotential(stats)
        });
      }
    }
    
    return hotspots.sort((a, b) => b.percentage_of_total - a.percentage_of_total);
  }
}
```

**Step 8: Performance Optimization Recommendations**

**Optimization Recommendation Engine:**
```typescript
class PerformanceOptimizationEngine {
  async generateOptimizationRecommendations(
    testResults: PerformanceTestResults
  ): Promise<OptimizationRecommendations> {
    console.log('🔧 Generating optimization recommendations...');
    
    const recommendations = {
      high_priority: [],
      medium_priority: [],
      low_priority: [],
      quick_wins: [],
      long_term: []
    };
    
    // Analyze load test results
    const loadOptimizations = this.analyzeLoadTestOptimizations(testResults.load_tests);
    
    // Analyze stress test results
    const stressOptimizations = this.analyzeStressTestOptimizations(testResults.stress_tests);
    
    // Analyze benchmark results
    const benchmarkOptimizations = this.analyzeBenchmarkOptimizations(testResults.benchmarks);
    
    // Analyze profiling results
    const profilingOptimizations = this.analyzeProfilingOptimizations(testResults.profiling);
    
    // Combine and prioritize recommendations
    const allOptimizations = [
      ...loadOptimizations,
      ...stressOptimizations,
      ...benchmarkOptimizations,
      ...profilingOptimizations
    ];
    
    // Prioritize recommendations
    this.prioritizeRecommendations(allOptimizations, recommendations);
    
    // Generate implementation plans
    recommendations.implementation_plans = this.generateImplementationPlans(recommendations);
    
    return recommendations;
  }
  
  private analyzeLoadTestOptimizations(loadTests: LoadTestResults): Optimization[] {
    const optimizations = [];
    
    // Response time optimizations
    if (loadTests.average_response_time > 1000) {
      optimizations.push({
        type: 'Response Time',
        priority: 'high',
        description: 'Response time exceeds acceptable threshold',
        current_value: loadTests.average_response_time,
        target_value: 500,
        impact: 'high',
        effort: 'medium',
        techniques: [
          'Implement caching strategy',
          'Optimize database queries',
          'Use CDN for static assets',
          'Implement connection pooling'
        ]
      });
    }
    
    // Throughput optimizations
    if (loadTests.throughput < 1000) {
      optimizations.push({
        type: 'Throughput',
        priority: 'medium',
        description: 'Throughput below expected capacity',
        current_value: loadTests.throughput,
        target_value: 2000,
        impact: 'medium',
        effort: 'high',
        techniques: [
          'Implement horizontal scaling',
          'Optimize thread pool configuration',
          'Use asynchronous processing',
          'Implement load balancing'
        ]
      });
    }
    
    // Error rate optimizations
    if (loadTests.error_rate > 0.01) {
      optimizations.push({
        type: 'Error Rate',
        priority: 'high',
        description: 'Error rate exceeds acceptable threshold',
        current_value: loadTests.error_rate,
        target_value: 0.001,
        impact: 'high',
        effort: 'low',
        techniques: [
          'Implement proper error handling',
          'Add input validation',
          'Improve exception handling',
          'Add circuit breakers'
        ]
      });
    }
    
    return optimizations;
  }
  
  private generateImplementationPlans(recommendations: any): ImplementationPlan[] {
    const plans = [];
    
    // Quick wins implementation plan
    if (recommendations.quick_wins.length > 0) {
      plans.push({
        name: 'Quick Wins Implementation',
        duration: '1-2 weeks',
        optimizations: recommendations.quick_wins,
        steps: [
          'Implement caching for frequently accessed data',
          'Add database indexes for slow queries',
          'Optimize image sizes and formats',
          'Enable gzip compression'
        ],
        expected_impact: '20-30% performance improvement',
        resources_required: '1 developer'
      });
    }
    
    // High priority implementation plan
    if (recommendations.high_priority.length > 0) {
      plans.push({
        name: 'High Priority Optimizations',
        duration: '1-2 months',
        optimizations: recommendations.high_priority,
        steps: [
          'Implement horizontal scaling infrastructure',
          'Optimize critical algorithms',
          'Implement advanced caching strategies',
          'Optimize database schema and queries'
        ],
        expected_impact: '50-70% performance improvement',
        resources_required: '2-3 developers'
      });
    }
    
    // Long term implementation plan
    if (recommendations.long_term.length > 0) {
      plans.push({
        name: 'Long Term Performance Strategy',
        duration: '3-6 months',
        optimizations: recommendations.long_term,
        steps: [
          'Implement microservices architecture',
          'Migrate to more efficient technologies',
          'Implement advanced monitoring and alerting',
          'Optimize entire technology stack'
        ],
        expected_impact: '100-200% performance improvement',
        resources_required: '5-8 developers'
      });
    }
    
    return plans;
  }
}
```

**Performance Testing Quality Checklist:**
- [ ] Performance baselines are established and documented
- [ ] Load tests validate system under realistic conditions
- [ ] Stress tests identify system limits and breaking points
- [ ] Benchmarks measure critical function performance
- [ ] Scalability tests validate horizontal and vertical scaling
- [ ] Profiling identifies memory and CPU bottlenecks
- [ ] Optimization recommendations are prioritized and actionable
- [ ] Performance monitoring is implemented for continuous tracking

**Agent Coordination for Performance Testing:**
```
"For comprehensive performance testing, I'll coordinate multiple specialized agents:

Primary Performance Agent: Overall performance testing coordination
├── Load Testing Agent: Execute realistic load scenarios
├── Stress Testing Agent: Test system limits and breaking points
├── Benchmark Agent: Measure critical function performance
├── Scalability Agent: Test scaling characteristics
├── Memory Profiling Agent: Analyze memory usage and leaks
├── CPU Profiling Agent: Identify CPU bottlenecks
├── Database Performance Agent: Test database performance
├── Network Performance Agent: Test network characteristics
└── Optimization Agent: Generate actionable optimization recommendations

Each agent will execute specialized tests while coordinating to provide comprehensive performance analysis."
```

**Anti-Patterns to Avoid:**
- ❌ Testing only under ideal conditions (unrealistic scenarios)
- ❌ Ignoring performance regressions (degrading user experience)
- ❌ Not testing scalability characteristics (scaling failures)
- ❌ Skipping profiling and optimization (missing opportunities)
- ❌ No performance monitoring (blind to issues)
- ❌ Accepting "good enough" performance (competitive disadvantage)

**Final Verification:**
Before completing performance testing:
- Are all performance tests executed and analyzed?
- Are system limits and scalability characteristics documented?
- Are performance bottlenecks identified and prioritized?
- Are optimization recommendations actionable and prioritized?
- Is performance monitoring implemented?
- Are performance targets met or improvement plans created?

**Final Commitment:**
- **I will**: Execute comprehensive performance tests across all system components
- **I will**: Use multiple agents for parallel performance testing
- **I will**: Identify and prioritize performance bottlenecks
- **I will**: Generate actionable optimization recommendations
- **I will NOT**: Skip performance testing or accept poor performance
- **I will NOT**: Test only under ideal conditions
- **I will NOT**: Ignore scalability or monitoring requirements

**REMEMBER:**
This is PERFORMANCE TESTING mode - comprehensive benchmarking, load testing, and optimization. The goal is to ensure excellent system performance, scalability, and user experience under all conditions.

Executing comprehensive performance testing protocol for optimal system performance...