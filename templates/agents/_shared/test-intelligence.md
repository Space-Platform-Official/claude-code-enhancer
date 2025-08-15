# Shared Test Intelligence Components

## Framework Detection Engine

```javascript
// Comprehensive framework detection
function detectTestFramework(fileContent, filePath) {
  // JavaScript/TypeScript frameworks
  if (fileContent.includes('describe(') || fileContent.includes('it(')) {
    if (fileContent.includes('jest.') || fileContent.includes('@jest/')) return 'jest';
    if (fileContent.includes('vitest') || filePath.includes('.vitest.')) return 'vitest';
    if (fileContent.includes('mocha')) return 'mocha';
    if (fileContent.includes('jasmine')) return 'jasmine';
    return 'jest'; // Default for describe/it pattern
  }
  
  // Python frameworks
  if (fileContent.includes('def test_') || fileContent.includes('class Test')) {
    if (fileContent.includes('pytest') || fileContent.includes('@pytest')) return 'pytest';
    if (fileContent.includes('unittest')) return 'unittest';
    return 'pytest'; // Default for Python
  }
  
  // Go
  if (fileContent.includes('func Test') && fileContent.includes('testing.T')) {
    return 'go-test';
  }
  
  // Ruby
  if (fileContent.includes('RSpec.describe') || fileContent.includes('describe do')) {
    return 'rspec';
  }
  if (fileContent.includes('class Test') && fileContent.includes('< Minitest')) {
    return 'minitest';
  }
  
  // Java
  if (fileContent.includes('@Test') && fileContent.includes('org.junit')) {
    return 'junit';
  }
  
  // PHP
  if (fileContent.includes('class Test') && fileContent.includes('PHPUnit')) {
    return 'phpunit';
  }
  
  // Rust
  if (fileContent.includes('#[test]') || fileContent.includes('#[cfg(test)]')) {
    return 'rust-test';
  }
  
  return 'unknown';
}
```

## Test Type Categorization

```javascript
// Intelligent test type detection
function categorizeTest(fileContent, filePath) {
  const indicators = {
    unit: {
      patterns: [
        /mock/i,
        /stub/i,
        /spy/i,
        /fake/i,
        /\.unit\./,
        /\/unit\//,
        /isolat/i
      ],
      antiPatterns: [
        /integration/i,
        /e2e/i,
        /database/i,
        /api/i,
        /http/i,
        /socket/i
      ]
    },
    integration: {
      patterns: [
        /integration/i,
        /\.integration\./,
        /\/integration\//,
        /database/i,
        /api/i,
        /service/i,
        /http/i,
        /grpc/i,
        /graphql/i
      ],
      antiPatterns: [
        /mock\(/i,
        /\.unit\./,
        /\/unit\//
      ]
    },
    e2e: {
      patterns: [
        /e2e/i,
        /end-to-end/i,
        /browser/i,
        /selenium/i,
        /cypress/i,
        /playwright/i,
        /puppeteer/i
      ],
      antiPatterns: []
    }
  };
  
  let scores = {
    unit: 0,
    integration: 0,
    e2e: 0
  };
  
  // Calculate scores based on patterns
  for (const [type, config] of Object.entries(indicators)) {
    for (const pattern of config.patterns) {
      if (pattern.test(fileContent) || pattern.test(filePath)) {
        scores[type] += 2;
      }
    }
    for (const antiPattern of config.antiPatterns) {
      if (antiPattern.test(fileContent) || antiPattern.test(filePath)) {
        scores[type] -= 1;
      }
    }
  }
  
  // Determine primary type
  const maxScore = Math.max(...Object.values(scores));
  if (maxScore <= 0) return 'unknown';
  
  for (const [type, score] of Object.entries(scores)) {
    if (score === maxScore) return type;
  }
  
  return 'unknown';
}
```

## Failure Pattern Analysis

```javascript
// Common test failure patterns and fixes
const failurePatterns = {
  // Async/Promise issues
  'UnhandledPromiseRejectionWarning': {
    category: 'async',
    fix: 'Add proper async/await or .catch() handler',
    example: 'test("name", async () => { await promise; })'
  },
  
  'Timeout - Async callback was not invoked': {
    category: 'async',
    fix: 'Ensure async operations complete or increase timeout',
    example: 'test("name", async () => { ... }, 10000)'
  },
  
  // Mock issues
  'Cannot spy on a property that is not a function': {
    category: 'mock',
    fix: 'Ensure you are spying on a function, not a property',
    example: 'jest.spyOn(object, "methodName")'
  },
  
  'mockReturnValue is not a function': {
    category: 'mock',
    fix: 'Ensure mock is created properly before setting return value',
    example: 'const mock = jest.fn(); mock.mockReturnValue(value);'
  },
  
  // Assertion issues
  'Expected .* Received .*': {
    category: 'assertion',
    fix: 'Update expected value or fix implementation',
    pattern: /Expected (.*) Received (.*)/
  },
  
  'Cannot read prop.* of undefined': {
    category: 'null-reference',
    fix: 'Add null checks or ensure object initialization',
    pattern: /Cannot read prop.* '(.*)' of undefined/
  },
  
  // Database/Integration issues
  'Connection refused': {
    category: 'integration',
    fix: 'Ensure service is running and accessible',
    services: ['database', 'redis', 'api']
  },
  
  'ECONNREFUSED': {
    category: 'integration',
    fix: 'Service not available at specified host:port',
    pattern: /ECONNREFUSED (.*):(\d+)/
  }
};

function analyzeFailure(errorMessage) {
  for (const [key, config] of Object.entries(failurePatterns)) {
    if (config.pattern) {
      if (config.pattern.test(errorMessage)) {
        return config;
      }
    } else if (errorMessage.includes(key)) {
      return config;
    }
  }
  return { category: 'unknown', fix: 'Manual investigation required' };
}
```

## Coverage Analysis Engine

```javascript
// Intelligent coverage analysis
function analyzeCoverage(coverageData) {
  const analysis = {
    overall: {
      line: coverageData.lines.pct,
      branch: coverageData.branches.pct,
      function: coverageData.functions.pct,
      statement: coverageData.statements.pct
    },
    gaps: [],
    recommendations: []
  };
  
  // Identify coverage gaps
  for (const [file, data] of Object.entries(coverageData.files)) {
    if (data.lines.pct < 80) {
      analysis.gaps.push({
        file,
        type: 'low-line-coverage',
        current: data.lines.pct,
        uncovered: data.lines.uncovered
      });
    }
    
    if (data.branches.pct < 70) {
      analysis.gaps.push({
        file,
        type: 'low-branch-coverage',
        current: data.branches.pct,
        uncovered: data.branches.uncovered
      });
    }
  }
  
  // Generate recommendations
  if (analysis.overall.branch < analysis.overall.line - 10) {
    analysis.recommendations.push(
      'Branch coverage significantly lower than line coverage. Add tests for conditional logic.'
    );
  }
  
  if (analysis.overall.function < 90) {
    analysis.recommendations.push(
      'Function coverage below 90%. Ensure all exported functions are tested.'
    );
  }
  
  // Identify critical uncovered files
  const criticalPatterns = [/index\.(js|ts)$/, /main\.(js|ts)$/, /app\.(js|ts)$/];
  for (const [file, data] of Object.entries(coverageData.files)) {
    if (criticalPatterns.some(p => p.test(file)) && data.lines.pct < 50) {
      analysis.recommendations.push(
        `Critical file ${file} has low coverage (${data.lines.pct}%). Priority fix needed.`
      );
    }
  }
  
  return analysis;
}
```

## Performance Monitoring

```javascript
// Test execution performance tracking
class TestPerformanceMonitor {
  constructor() {
    this.metrics = {
      tests: [],
      suites: {},
      overall: {
        startTime: Date.now(),
        endTime: null,
        totalTests: 0,
        parallelization: 1
      }
    };
  }
  
  recordTest(name, duration, status) {
    this.metrics.tests.push({
      name,
      duration,
      status,
      timestamp: Date.now()
    });
    
    this.metrics.totalTests++;
  }
  
  recordSuite(name, stats) {
    this.metrics.suites[name] = {
      duration: stats.duration,
      tests: stats.tests,
      passed: stats.passed,
      failed: stats.failed,
      skipped: stats.skipped
    };
  }
  
  analyzePerformance() {
    const sortedTests = [...this.metrics.tests].sort((a, b) => b.duration - a.duration);
    const totalDuration = this.metrics.endTime - this.metrics.overall.startTime;
    
    return {
      totalDuration,
      averageTestDuration: totalDuration / this.metrics.totalTests,
      slowestTests: sortedTests.slice(0, 10),
      testDistribution: {
        fast: this.metrics.tests.filter(t => t.duration < 10).length,
        normal: this.metrics.tests.filter(t => t.duration >= 10 && t.duration < 100).length,
        slow: this.metrics.tests.filter(t => t.duration >= 100 && t.duration < 1000).length,
        verySlow: this.metrics.tests.filter(t => t.duration >= 1000).length
      },
      parallelizationEfficiency: this.calculateParallelizationEfficiency(),
      recommendations: this.generatePerformanceRecommendations()
    };
  }
  
  calculateParallelizationEfficiency() {
    const sequentialTime = this.metrics.tests.reduce((sum, t) => sum + t.duration, 0);
    const actualTime = this.metrics.endTime - this.metrics.overall.startTime;
    return Math.min(100, (sequentialTime / actualTime) * 100);
  }
  
  generatePerformanceRecommendations() {
    const recommendations = [];
    const analysis = this.analyzePerformance();
    
    if (analysis.testDistribution.verySlow > 0) {
      recommendations.push(
        `${analysis.testDistribution.verySlow} tests take >1 second. Consider optimization or moving to integration tests.`
      );
    }
    
    if (analysis.parallelizationEfficiency < 50) {
      recommendations.push(
        'Low parallelization efficiency. Consider increasing worker count or improving test isolation.'
      );
    }
    
    if (analysis.averageTestDuration > 100) {
      recommendations.push(
        'High average test duration. Review test design and consider mocking external dependencies.'
      );
    }
    
    return recommendations;
  }
}
```

## Test Coordination Protocol

```javascript
// Coordination between test agents
const TestCoordination = {
  // Session management
  createSession(orchestratorId) {
    const sessionId = `test-session-${Date.now()}`;
    return {
      id: sessionId,
      orchestrator: orchestratorId,
      agents: [],
      status: 'initializing',
      startTime: Date.now(),
      results: {}
    };
  },
  
  // Agent registration
  registerAgent(session, agentId, type) {
    session.agents.push({
      id: agentId,
      type,
      status: 'registered',
      registeredAt: Date.now()
    });
  },
  
  // Result aggregation
  aggregateResults(session) {
    const results = {
      unit: {},
      integration: {},
      e2e: {},
      overall: {
        passed: 0,
        failed: 0,
        skipped: 0,
        duration: 0
      }
    };
    
    for (const [agentId, agentResults] of Object.entries(session.results)) {
      const agent = session.agents.find(a => a.id === agentId);
      if (agent) {
        results[agent.type] = agentResults;
        results.overall.passed += agentResults.passed || 0;
        results.overall.failed += agentResults.failed || 0;
        results.overall.skipped += agentResults.skipped || 0;
        results.overall.duration += agentResults.duration || 0;
      }
    }
    
    return results;
  },
  
  // Coordination file paths
  paths: {
    session: (id) => `/tmp/test-session-${id}.json`,
    results: (id) => `/tmp/test-results-${id}.json`,
    coverage: (id) => `/tmp/test-coverage-${id}.json`,
    performance: (id) => `/tmp/test-performance-${id}.json`
  }
};
```

## Command Execution Utilities

```bash
#!/bin/bash

# Framework-specific test execution commands
get_test_command() {
  local framework=$1
  local test_type=$2
  local parallel=$3
  
  case $framework in
    jest)
      echo "npx jest --maxWorkers=${parallel:-50%} --coverage"
      ;;
    vitest)
      echo "npx vitest run --threads --coverage"
      ;;
    pytest)
      echo "python -m pytest -n ${parallel:-auto} --cov"
      ;;
    go-test)
      echo "go test -v -cover -parallel ${parallel:-4} ./..."
      ;;
    rspec)
      echo "bundle exec rspec --format progress"
      ;;
    phpunit)
      echo "vendor/bin/phpunit --coverage-text"
      ;;
    *)
      echo "npm test"
      ;;
  esac
}

# Service health check
check_service_health() {
  local service_url=$1
  local max_retries=${2:-30}
  local retry_delay=${3:-2}
  
  for i in $(seq 1 $max_retries); do
    if curl -sf "${service_url}/health" > /dev/null 2>&1; then
      echo "Service healthy: $service_url"
      return 0
    fi
    echo "Waiting for service: $service_url (attempt $i/$max_retries)"
    sleep $retry_delay
  done
  
  echo "Service failed to become healthy: $service_url"
  return 1
}

# Test result parsing
parse_test_results() {
  local framework=$1
  local output=$2
  
  case $framework in
    jest|vitest)
      echo "$output" | grep -E "Tests:.*passed" | sed 's/.*Tests: //'
      ;;
    pytest)
      echo "$output" | grep -E "passed|failed" | tail -1
      ;;
    go-test)
      echo "$output" | grep -E "PASS|FAIL" | wc -l
      ;;
    *)
      echo "$output"
      ;;
  esac
}
```

## Flaky Test Detection

```javascript
// Detect and handle flaky tests
class FlakyTestDetector {
  constructor(threshold = 3) {
    this.threshold = threshold;
    this.history = {};
  }
  
  recordResult(testName, passed) {
    if (!this.history[testName]) {
      this.history[testName] = [];
    }
    
    this.history[testName].push({
      passed,
      timestamp: Date.now()
    });
    
    // Keep only recent results
    if (this.history[testName].length > 10) {
      this.history[testName].shift();
    }
  }
  
  isFlaky(testName) {
    const results = this.history[testName];
    if (!results || results.length < this.threshold) {
      return false;
    }
    
    // Check for inconsistent results
    const passed = results.filter(r => r.passed).length;
    const failed = results.filter(r => !r.passed).length;
    
    return passed > 0 && failed > 0;
  }
  
  analyzeFlakiness() {
    const flakyTests = [];
    
    for (const [testName, results] of Object.entries(this.history)) {
      if (this.isFlaky(testName)) {
        const passRate = results.filter(r => r.passed).length / results.length;
        flakyTests.push({
          name: testName,
          passRate,
          attempts: results.length,
          lastResult: results[results.length - 1].passed
        });
      }
    }
    
    return flakyTests.sort((a, b) => a.passRate - b.passRate);
  }
  
  suggestFixes(testName) {
    const patterns = [
      { issue: 'timing', fix: 'Add explicit waits or increase timeouts' },
      { issue: 'async', fix: 'Ensure proper async/await usage' },
      { issue: 'state', fix: 'Add proper setup/teardown to isolate test state' },
      { issue: 'mock', fix: 'Reset mocks between test runs' },
      { issue: 'random', fix: 'Use fixed seeds for random data' },
      { issue: 'network', fix: 'Mock external service calls' },
      { issue: 'concurrency', fix: 'Add proper synchronization' }
    ];
    
    // Analyze test content to suggest specific fixes
    // This would need access to test source code
    return patterns.map(p => p.fix);
  }
}
```

## Test Quality Metrics

```javascript
// Comprehensive test quality assessment
function assessTestQuality(testFile) {
  const metrics = {
    readability: 0,
    maintainability: 0,
    coverage: 0,
    isolation: 0,
    performance: 0,
    overall: 0
  };
  
  // Readability checks
  if (testFile.includes('describe(') && testFile.includes('it(')) metrics.readability += 25;
  if (testFile.match(/it\(['"`]should/g)) metrics.readability += 25;
  if (testFile.length < 500) metrics.readability += 25;
  if (!testFile.includes('TODO') && !testFile.includes('FIXME')) metrics.readability += 25;
  
  // Maintainability checks
  if (testFile.includes('beforeEach') || testFile.includes('afterEach')) metrics.maintainability += 33;
  if (!testFile.match(/it\.only|describe\.only/)) metrics.maintainability += 33;
  if (testFile.match(/\.[A-Z]\w+\(/g).length < 10) metrics.maintainability += 34;
  
  // Isolation checks
  if (!testFile.includes('../../')) metrics.isolation += 50;
  if (testFile.includes('mock') || testFile.includes('stub')) metrics.isolation += 50;
  
  // Calculate overall
  metrics.overall = (
    metrics.readability * 0.2 +
    metrics.maintainability * 0.3 +
    metrics.coverage * 0.2 +
    metrics.isolation * 0.2 +
    metrics.performance * 0.1
  );
  
  return metrics;
}
```