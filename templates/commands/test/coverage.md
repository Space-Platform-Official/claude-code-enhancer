---
allowed-tools: all
description: **EXECUTE test coverage analysis** and implement comprehensive testing for critical code paths
intensity: ⚡⚡⚡
pattern: 📊📊📊
---

# 📊📊📊 CRITICAL TEST COVERAGE EXECUTION: COMPREHENSIVE COVERAGE IMPROVEMENT! 📊📊📊

**THIS IS NOT A SIMPLE COVERAGE REPORT - THIS IS A COMPREHENSIVE COVERAGE EXECUTION SYSTEM!**

**🚨 ACTUAL TEST EXECUTION AND COVERAGE MEASUREMENT REQUIRED! 🚨**

When you run `/test coverage`, you are REQUIRED to:

1. **EXECUTE** tests to measure current coverage and identify critical gaps
2. **IMPLEMENT** comprehensive tests for all uncovered critical paths
3. **PRIORITIZE** coverage by business impact and code complexity
4. **USE MULTIPLE AGENTS** for parallel coverage improvement:
   - Spawn one agent per module or critical component
   - Spawn agents for different test types (unit, integration, edge cases)
   - Say: "I'll spawn multiple agents to improve test coverage across all critical code paths"
5. **GENERATE** detailed coverage reports with actionable recommendations
6. **ACHIEVE** coverage targets while maintaining test quality

## 🎯 USE MULTIPLE AGENTS

**MANDATORY TASK TOOL AGENT SPAWNING:**

### Coverage Analysis Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Analyze coverage</parameter>
<parameter name="prompt">You are the Coverage Analysis Agent.

Your responsibilities:
1. Run existing tests to generate coverage data
2. Analyze current coverage metrics and identify critical gaps
3. Prioritize uncovered code paths by business impact
4. Map untested functions and edge cases
5. Generate gap analysis report to .coverage/gaps.json

Provide comprehensive coverage gap analysis.</parameter>
</invoke>
</function_calls>
```

### Test Implementation Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Implement tests</parameter>
<parameter name="prompt">You are the Test Implementation Agent.

Your responsibilities:
1. Read coverage gaps from .coverage/gaps.json
2. Implement missing unit tests for uncovered functions
3. Create integration tests for system interactions
4. Add edge case tests for boundary conditions
5. Ensure all new tests pass and improve coverage

Implement high-quality tests for all critical gaps.</parameter>
</invoke>
</function_calls>
```

### Report Generation Agent:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Generate reports</parameter>
<parameter name="prompt">You are the Report Generation Agent.

Your responsibilities:
1. Aggregate coverage metrics from all test runs
2. Generate comprehensive coverage reports
3. Create actionable improvement recommendations
4. Visualize coverage trends and gaps
5. Output final report to .coverage/report.md

Deliver detailed coverage report with insights.</parameter>
</invoke>
</function_calls>
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ "85% coverage is good enough" → NO! Focus on critical path coverage quality!
- ❌ Skip complex functions → NO! Complex code needs more testing!
- ❌ Write tests just for coverage numbers → NO! Tests must be meaningful!
- ❌ Ignore error paths → NO! Error handling must be tested!
- ❌ Skip edge cases → NO! Boundary conditions are critical!
- ❌ "Coverage tools are inaccurate" → NO! Use multiple coverage metrics!

**MANDATORY WORKFLOW:**
```
1. TEST EXECUTION → Run tests to generate coverage data
2. Coverage analysis → Identify gaps and priorities from actual execution
3. IMMEDIATELY spawn agents for parallel test implementation
4. Critical path testing → Focus on high-impact code paths
5. Edge case implementation → Test boundary conditions
6. VERIFICATION EXECUTION → Re-run tests to verify coverage improvement
7. Report generation → Create actionable coverage reports
```

**YOU ARE NOT DONE UNTIL:**
- ✅ ALL critical business logic has comprehensive test coverage
- ✅ Coverage targets are achieved with meaningful tests
- ✅ Error paths and edge cases are thoroughly tested
- ✅ Coverage reports provide actionable insights
- ✅ Test quality is maintained while improving coverage
- ✅ Performance-critical paths have benchmark tests

---

🛑 **MANDATORY COVERAGE IMPROVEMENT CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current codebase and existing test coverage
3. Verify you understand the coverage improvement requirements

Execute comprehensive coverage improvement for: $ARGUMENTS

**FORBIDDEN SHORTCUT PATTERNS:**
- "This code is too simple to test" → NO, test all business logic!
- "Integration tests cover this" → NO, also need unit tests!
- "Coverage numbers look good" → NO, focus on coverage quality!
- "Edge cases are unlikely" → NO, test all boundary conditions!
- "Performance tests are optional" → NO, benchmark critical paths!

Let me ultrathink about the comprehensive coverage improvement architecture and strategy.

🚨 **REMEMBER: Quality coverage prevents bugs and improves maintainability!** 🚨

**Comprehensive Coverage Improvement Protocol:**

**Step 0: Coverage Baseline Analysis and Tool Setup**
- Configure coverage tools for all languages in the project
- Establish baseline coverage metrics and thresholds
- Identify critical business logic and high-risk code paths
- Set up coverage reporting and integration with CI/CD
- Define coverage quality standards and best practices

**Framework-Specific Coverage Tools:**

**JavaScript/TypeScript Coverage:**
```json
{
  "jest": {
    "collectCoverage": true,
    "coverageDirectory": "coverage",
    "coverageReporters": ["text", "lcov", "html", "json"],
    "collectCoverageFrom": [
      "src/**/*.{js,ts}",
      "!src/**/*.test.{js,ts}",
      "!src/**/*.spec.{js,ts}",
      "!src/**/*.d.ts"
    ],
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 85,
        "lines": 80,
        "statements": 80
      },
      "src/core/": {
        "branches": 90,
        "functions": 95,
        "lines": 90,
        "statements": 90
      }
    }
  }
}
```

**Python Coverage:**
```ini
[run]
source = src
omit = 
    */tests/*
    */test_*
    */conftest.py
    */migrations/*
    */venv/*
    */env/*

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    if self.debug:
    if settings.DEBUG
    raise AssertionError
    raise NotImplementedError
    if 0:
    if __name__ == .__main__.:
    class .*\bProtocol\):
    @(abc\.)?abstractmethod

[html]
directory = htmlcov

[xml]
output = coverage.xml
```

**Go Coverage:**
```bash
# Generate coverage profile
go test -coverprofile=coverage.out -covermode=atomic ./...

# Generate HTML report
go tool cover -html=coverage.out -o coverage.html

# Generate func coverage
go tool cover -func=coverage.out

# Coverage with race detection
go test -race -coverprofile=coverage.out -covermode=atomic ./...
```

**Step 1: Comprehensive Coverage Analysis**

**Coverage Analysis Framework:**
```typescript
interface CoverageAnalysis {
  overall_metrics: {
    line_coverage: number;
    branch_coverage: number;
    function_coverage: number;
    statement_coverage: number;
  };
  file_coverage: FileCoverage[];
  critical_gaps: CriticalGap[];
  priority_areas: PriorityArea[];
  coverage_trends: CoverageTrend[];
}

interface FileCoverage {
  file_path: string;
  coverage_percentage: number;
  uncovered_lines: number[];
  uncovered_functions: string[];
  uncovered_branches: BranchInfo[];
  complexity_score: number;
  business_impact: 'high' | 'medium' | 'low';
  test_difficulty: 'easy' | 'medium' | 'hard';
}

interface CriticalGap {
  file_path: string;
  function_name: string;
  gap_type: 'missing_unit_test' | 'missing_integration_test' | 'missing_edge_case' | 'missing_error_path';
  business_impact: 'critical' | 'high' | 'medium' | 'low';
  complexity: number;
  estimated_effort: number;
  dependencies: string[];
}

class CoverageAnalyzer {
  async analyzeCoverage(projectPath: string): Promise<CoverageAnalysis> {
    console.log('📊 Starting comprehensive coverage analysis...');
    
    // Generate coverage data
    const coverageData = await this.generateCoverageData(projectPath);
    
    // Analyze file-level coverage
    const fileCoverage = await this.analyzeFileCoverage(coverageData);
    
    // Identify critical gaps
    const criticalGaps = await this.identifyCriticalGaps(fileCoverage);
    
    // Prioritize areas for improvement
    const priorityAreas = await this.prioritizeAreas(criticalGaps);
    
    // Analyze coverage trends
    const coverageTrends = await this.analyzeCoverageTrends(projectPath);
    
    return {
      overall_metrics: this.calculateOverallMetrics(coverageData),
      file_coverage: fileCoverage,
      critical_gaps: criticalGaps,
      priority_areas: priorityAreas,
      coverage_trends: coverageTrends
    };
  }
  
  private async generateCoverageData(projectPath: string): Promise<any> {
    const coverageCommands = {
      javascript: 'npm test -- --coverage --json',
      typescript: 'npm test -- --coverage --json',
      python: 'coverage run -m pytest && coverage json',
      go: 'go test -coverprofile=coverage.out -json ./...',
      java: 'mvn test jacoco:report',
      csharp: 'dotnet test --collect:"XPlat Code Coverage"'
    };
    
    const language = await this.detectProjectLanguage(projectPath);
    const command = coverageCommands[language];
    
    if (!command) {
      throw new Error(`Unsupported language for coverage: ${language}`);
    }
    
    return await this.executeCoverageCommand(command, projectPath);
  }
  
  private async identifyCriticalGaps(fileCoverage: FileCoverage[]): Promise<CriticalGap[]> {
    const gaps = [];
    
    for (const file of fileCoverage) {
      // Analyze uncovered functions
      for (const func of file.uncovered_functions) {
        const functionInfo = await this.analyzeFunctionComplexity(file.file_path, func);
        
        gaps.push({
          file_path: file.file_path,
          function_name: func,
          gap_type: 'missing_unit_test',
          business_impact: this.assessBusinessImpact(file.file_path, func),
          complexity: functionInfo.complexity,
          estimated_effort: this.estimateTestEffort(functionInfo),
          dependencies: functionInfo.dependencies
        });
      }
      
      // Analyze uncovered branches (error paths)
      for (const branch of file.uncovered_branches) {
        if (branch.is_error_path) {
          gaps.push({
            file_path: file.file_path,
            function_name: branch.function_name,
            gap_type: 'missing_error_path',
            business_impact: 'high',
            complexity: branch.complexity,
            estimated_effort: 2,
            dependencies: []
          });
        }
      }
    }
    
    return gaps.sort((a, b) => this.prioritizeGap(a) - this.prioritizeGap(b));
  }
  
  private assessBusinessImpact(filePath: string, functionName: string): 'critical' | 'high' | 'medium' | 'low' {
    const highImpactPatterns = [
      /payment/i,
      /auth/i,
      /security/i,
      /user/i,
      /order/i,
      /transaction/i,
      /billing/i,
      /api/i,
      /core/i,
      /critical/i
    ];
    
    const mediumImpactPatterns = [
      /validation/i,
      /service/i,
      /manager/i,
      /controller/i,
      /handler/i,
      /processor/i
    ];
    
    const fullPath = `${filePath}:${functionName}`;
    
    if (highImpactPatterns.some(pattern => pattern.test(fullPath))) {
      return 'critical';
    }
    
    if (mediumImpactPatterns.some(pattern => pattern.test(fullPath))) {
      return 'high';
    }
    
    return 'medium';
  }
}
```

**Step 2: Parallel Agent Deployment for Coverage Improvement**

**Agent Spawning Strategy:**
```
"I've identified 47 critical coverage gaps across 12 modules. I'll spawn specialized agents:

1. **Core Business Logic Agent**: 'Implement tests for authentication, payment, and user management'
2. **API Layer Agent**: 'Create tests for REST endpoints and GraphQL resolvers'
3. **Data Layer Agent**: 'Test database operations, models, and data validation'
4. **Error Handling Agent**: 'Implement tests for error paths and exception handling'
5. **Edge Case Agent**: 'Test boundary conditions, null values, and edge scenarios'
6. **Performance Agent**: 'Add benchmark tests for performance-critical functions'
7. **Integration Agent**: 'Create tests for service interactions and external APIs'
8. **Security Agent**: 'Test authentication, authorization, and security features'

Each agent will focus on their domain while coordinating to avoid test conflicts."
```

**Step 3: Critical Path Test Implementation**

**Test Generation Framework:**
```typescript
class TestGenerator {
  async generateTestsForGaps(gaps: CriticalGap[]): Promise<GeneratedTest[]> {
    const generatedTests = [];
    
    for (const gap of gaps) {
      console.log(`🧪 Generating tests for ${gap.file_path}:${gap.function_name}`);
      
      const testCode = await this.generateTestCode(gap);
      const testFilePath = this.getTestFilePath(gap.file_path);
      
      generatedTests.push({
        test_file_path: testFilePath,
        test_code: testCode,
        gap_info: gap,
        estimated_coverage_increase: this.estimateCoverageIncrease(gap)
      });
    }
    
    return generatedTests;
  }
  
  private async generateTestCode(gap: CriticalGap): Promise<string> {
    const functionInfo = await this.analyzeFunctionSignature(gap.file_path, gap.function_name);
    
    switch (gap.gap_type) {
      case 'missing_unit_test':
        return this.generateUnitTest(functionInfo);
      case 'missing_integration_test':
        return this.generateIntegrationTest(functionInfo);
      case 'missing_edge_case':
        return this.generateEdgeCaseTest(functionInfo);
      case 'missing_error_path':
        return this.generateErrorPathTest(functionInfo);
      default:
        throw new Error(`Unknown gap type: ${gap.gap_type}`);
    }
  }
  
  private generateUnitTest(functionInfo: FunctionInfo): string {
    const testTemplate = this.getTestTemplate(functionInfo.language);
    
    return testTemplate.replace('{{FUNCTION_NAME}}', functionInfo.name)
      .replace('{{TEST_CASES}}', this.generateTestCases(functionInfo))
      .replace('{{IMPORTS}}', this.generateImports(functionInfo))
      .replace('{{SETUP}}', this.generateSetup(functionInfo))
      .replace('{{TEARDOWN}}', this.generateTeardown(functionInfo));
  }
  
  private generateTestCases(functionInfo: FunctionInfo): string {
    const testCases = [];
    
    // Happy path tests
    testCases.push(this.generateHappyPathTest(functionInfo));
    
    // Edge case tests
    testCases.push(...this.generateEdgeCaseTests(functionInfo));
    
    // Error path tests
    testCases.push(...this.generateErrorPathTests(functionInfo));
    
    // Boundary tests
    testCases.push(...this.generateBoundaryTests(functionInfo));
    
    return testCases.join('\n\n');
  }
  
  private generateHappyPathTest(functionInfo: FunctionInfo): string {
    const validInputs = this.generateValidInputs(functionInfo.parameters);
    const expectedOutput = this.generateExpectedOutput(functionInfo.return_type);
    
    return `
  test('${functionInfo.name} should handle valid inputs correctly', async () => {
    // Arrange
    ${this.generateArrangeCode(validInputs)}
    
    // Act
    const result = await ${functionInfo.name}(${validInputs.join(', ')});
    
    // Assert
    expect(result).${this.generateAssertionCode(expectedOutput)};
  });`;
  }
  
  private generateEdgeCaseTests(functionInfo: FunctionInfo): string[] {
    const edgeCases = [];
    
    // Null/undefined tests
    if (functionInfo.parameters.some(p => p.nullable)) {
      edgeCases.push(`
  test('${functionInfo.name} should handle null inputs', async () => {
    // Test null handling
    await expect(${functionInfo.name}(null)).${this.generateNullAssertionCode(functionInfo)};
  });`);
    }
    
    // Empty string/array tests
    if (functionInfo.parameters.some(p => p.type === 'string' || p.type === 'array')) {
      edgeCases.push(`
  test('${functionInfo.name} should handle empty inputs', async () => {
    // Test empty input handling
    const result = await ${functionInfo.name}('');
    expect(result).${this.generateEmptyAssertionCode(functionInfo)};
  });`);
    }
    
    // Boundary value tests
    if (functionInfo.parameters.some(p => p.type === 'number')) {
      edgeCases.push(`
  test('${functionInfo.name} should handle boundary values', async () => {
    // Test boundary values
    await expect(${functionInfo.name}(Number.MAX_VALUE)).${this.generateBoundaryAssertionCode(functionInfo)};
    await expect(${functionInfo.name}(Number.MIN_VALUE)).${this.generateBoundaryAssertionCode(functionInfo)};
  });`);
    }
    
    return edgeCases;
  }
  
  private generateErrorPathTests(functionInfo: FunctionInfo): string[] {
    const errorTests = [];
    
    // Invalid input tests
    errorTests.push(`
  test('${functionInfo.name} should handle invalid inputs', async () => {
    // Test invalid input handling
    await expect(${functionInfo.name}(${this.generateInvalidInputs(functionInfo)}))
      .rejects.toThrow('${this.generateExpectedErrorMessage(functionInfo)}');
  });`);
    
    // Permission/authorization tests
    if (functionInfo.requires_auth) {
      errorTests.push(`
  test('${functionInfo.name} should handle unauthorized access', async () => {
    // Test unauthorized access
    await expect(${functionInfo.name}(validInput, { user: null }))
      .rejects.toThrow('Unauthorized');
  });`);
    }
    
    // External dependency failure tests
    if (functionInfo.external_dependencies.length > 0) {
      errorTests.push(`
  test('${functionInfo.name} should handle external service failures', async () => {
    // Mock external service failure
    jest.spyOn(${functionInfo.external_dependencies[0]}, 'call').mockRejectedValue(new Error('Service unavailable'));
    
    await expect(${functionInfo.name}(validInput))
      .rejects.toThrow('Service unavailable');
  });`);
    }
    
    return errorTests;
  }
}
```

**Step 4: Advanced Coverage Metrics and Analysis**

**Coverage Quality Assessment:**
```typescript
class CoverageQualityAssessor {
  async assessCoverageQuality(coverageData: any): Promise<CoverageQualityReport> {
    console.log('🔍 Assessing coverage quality...');
    
    const qualityMetrics = {
      test_effectiveness: await this.measureTestEffectiveness(coverageData),
      mutation_testing_score: await this.runMutationTesting(coverageData),
      branch_coverage_quality: await this.analyzeBranchCoverage(coverageData),
      assertion_quality: await this.analyzeAssertionQuality(coverageData),
      test_maintainability: await this.assessTestMaintainability(coverageData)
    };
    
    return {
      overall_quality_score: this.calculateOverallQualityScore(qualityMetrics),
      quality_metrics: qualityMetrics,
      improvement_recommendations: this.generateQualityRecommendations(qualityMetrics),
      coverage_gaps: await this.identifyQualityGaps(qualityMetrics)
    };
  }
  
  private async measureTestEffectiveness(coverageData: any): Promise<number> {
    // Measure how well tests catch bugs
    const testFiles = await this.findTestFiles(coverageData.project_path);
    let effectivenessScore = 0;
    
    for (const testFile of testFiles) {
      const testAnalysis = await this.analyzeTestFile(testFile);
      
      // Check for meaningful assertions
      const assertionQuality = this.assessAssertions(testAnalysis.assertions);
      
      // Check for comprehensive test scenarios
      const scenarioCoverage = this.assessScenarioCoverage(testAnalysis.test_cases);
      
      // Check for proper mocking
      const mockingQuality = this.assessMockingQuality(testAnalysis.mocks);
      
      effectivenessScore += (assertionQuality + scenarioCoverage + mockingQuality) / 3;
    }
    
    return effectivenessScore / testFiles.length;
  }
  
  private async runMutationTesting(coverageData: any): Promise<number> {
    // Use mutation testing to assess test quality
    const mutationTools = {
      javascript: 'stryker',
      typescript: 'stryker',
      python: 'mutmut',
      java: 'pitest',
      csharp: 'stryker-net'
    };
    
    const language = await this.detectLanguage(coverageData.project_path);
    const mutationTool = mutationTools[language];
    
    if (!mutationTool) {
      console.log(`⚠️  Mutation testing not available for ${language}`);
      return 0;
    }
    
    try {
      const mutationResult = await this.executeMutationTesting(mutationTool, coverageData.project_path);
      return mutationResult.mutation_score;
    } catch (error) {
      console.log(`⚠️  Mutation testing failed: ${error.message}`);
      return 0;
    }
  }
  
  private async analyzeBranchCoverage(coverageData: any): Promise<BranchCoverageAnalysis> {
    const branchAnalysis = {
      total_branches: 0,
      covered_branches: 0,
      uncovered_error_paths: 0,
      uncovered_edge_cases: 0,
      critical_uncovered_branches: []
    };
    
    for (const file of coverageData.files) {
      const ast = await this.parseFileAST(file.path);
      const branches = this.extractBranches(ast);
      
      branchAnalysis.total_branches += branches.length;
      
      for (const branch of branches) {
        if (this.isBranchCovered(branch, file.coverage)) {
          branchAnalysis.covered_branches++;
        } else {
          if (branch.is_error_path) {
            branchAnalysis.uncovered_error_paths++;
          }
          
          if (branch.is_edge_case) {
            branchAnalysis.uncovered_edge_cases++;
          }
          
          if (branch.is_critical) {
            branchAnalysis.critical_uncovered_branches.push(branch);
          }
        }
      }
    }
    
    return branchAnalysis;
  }
}
```

**Step 5: Performance Benchmarking for Critical Paths**

**Performance Test Generation:**
```typescript
class PerformanceBenchmarkGenerator {
  async generatePerformanceTests(criticalPaths: CriticalPath[]): Promise<PerformanceTest[]> {
    const performanceTests = [];
    
    for (const path of criticalPaths) {
      console.log(`⚡ Generating performance tests for ${path.function_name}`);
      
      const benchmarkTest = await this.generateBenchmarkTest(path);
      const loadTest = await this.generateLoadTest(path);
      const memoryTest = await this.generateMemoryTest(path);
      
      performanceTests.push({
        function_name: path.function_name,
        benchmark_test: benchmarkTest,
        load_test: loadTest,
        memory_test: memoryTest,
        performance_targets: this.definePerformanceTargets(path)
      });
    }
    
    return performanceTests;
  }
  
  private async generateBenchmarkTest(path: CriticalPath): Promise<string> {
    const language = path.language;
    
    switch (language) {
      case 'javascript':
      case 'typescript':
        return `
describe('${path.function_name} Performance', () => {
  test('should execute within performance targets', async () => {
    const iterations = 1000;
    const start = performance.now();
    
    for (let i = 0; i < iterations; i++) {
      await ${path.function_name}(${this.generateBenchmarkInputs(path)});
    }
    
    const end = performance.now();
    const averageTime = (end - start) / iterations;
    
    expect(averageTime).toBeLessThan(${path.performance_targets.max_execution_time});
  });
  
  test('should handle concurrent executions', async () => {
    const concurrentCalls = 10;
    const start = performance.now();
    
    const promises = Array.from({ length: concurrentCalls }, () => 
      ${path.function_name}(${this.generateBenchmarkInputs(path)})
    );
    
    await Promise.all(promises);
    
    const end = performance.now();
    const totalTime = end - start;
    
    expect(totalTime).toBeLessThan(${path.performance_targets.max_concurrent_time});
  });
});`;
        
      case 'go':
        return `
func Benchmark${path.function_name}(b *testing.B) {
    input := ${this.generateGoInputs(path)}
    
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        ${path.function_name}(input)
    }
}

func Benchmark${path.function_name}Parallel(b *testing.B) {
    input := ${this.generateGoInputs(path)}
    
    b.ResetTimer()
    b.RunParallel(func(pb *testing.PB) {
        for pb.Next() {
            ${path.function_name}(input)
        }
    })
}`;
        
      case 'python':
        return `
import pytest
import time
from memory_profiler import profile

class TestPerformance${path.function_name}:
    def test_execution_time(self):
        """Test execution time within targets"""
        iterations = 1000
        start_time = time.time()
        
        for _ in range(iterations):
            ${path.function_name}(${this.generatePythonInputs(path)})
        
        end_time = time.time()
        average_time = (end_time - start_time) / iterations
        
        assert average_time < ${path.performance_targets.max_execution_time}
    
    @profile
    def test_memory_usage(self):
        """Test memory usage within targets"""
        result = ${path.function_name}(${this.generatePythonInputs(path)})
        # Memory profile will be generated automatically
        
    def test_concurrent_execution(self):
        """Test concurrent execution performance"""
        import concurrent.futures
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            futures = [
                executor.submit(${path.function_name}, ${this.generatePythonInputs(path)})
                for _ in range(10)
            ]
            
            start_time = time.time()
            results = [future.result() for future in futures]
            end_time = time.time()
            
            assert end_time - start_time < ${path.performance_targets.max_concurrent_time}
`;
      
      default:
        throw new Error(`Unsupported language for performance testing: ${language}`);
    }
  }
}
```

**Step 6: Coverage Report Generation and Visualization**

**Comprehensive Coverage Reporting:**
```typescript
class CoverageReporter {
  async generateComprehensiveReport(analysis: CoverageAnalysis): Promise<CoverageReport> {
    console.log('📊 Generating comprehensive coverage report...');
    
    const report = {
      executive_summary: this.generateExecutiveSummary(analysis),
      detailed_metrics: this.generateDetailedMetrics(analysis),
      critical_gaps: this.formatCriticalGaps(analysis.critical_gaps),
      priority_recommendations: this.generatePriorityRecommendations(analysis),
      coverage_trends: this.formatCoverageTrends(analysis.coverage_trends),
      quality_assessment: await this.assessCoverageQuality(analysis),
      actionable_items: this.generateActionableItems(analysis)
    };
    
    // Generate different report formats
    await this.generateHTMLReport(report);
    await this.generateMarkdownReport(report);
    await this.generateJSONReport(report);
    await this.generateSlackReport(report);
    
    return report;
  }
  
  private generateExecutiveSummary(analysis: CoverageAnalysis): ExecutiveSummary {
    const criticalGaps = analysis.critical_gaps.filter(gap => gap.business_impact === 'critical');
    const highPriorityGaps = analysis.critical_gaps.filter(gap => gap.business_impact === 'high');
    
    return {
      overall_coverage: analysis.overall_metrics.line_coverage,
      critical_coverage_status: criticalGaps.length === 0 ? 'GOOD' : 'NEEDS_ATTENTION',
      high_priority_gaps: highPriorityGaps.length,
      estimated_effort: this.calculateTotalEffort(analysis.critical_gaps),
      key_recommendations: this.getTopRecommendations(analysis, 5),
      coverage_trend: this.getCoverageTrend(analysis.coverage_trends)
    };
  }
  
  private generateDetailedMetrics(analysis: CoverageAnalysis): DetailedMetrics {
    return {
      coverage_by_module: this.calculateModuleCoverage(analysis.file_coverage),
      coverage_by_complexity: this.calculateComplexityCoverage(analysis.file_coverage),
      coverage_by_business_impact: this.calculateBusinessImpactCoverage(analysis.file_coverage),
      test_type_distribution: this.calculateTestTypeDistribution(analysis),
      coverage_debt: this.calculateCoverageDebt(analysis.critical_gaps)
    };
  }
  
  private generateActionableItems(analysis: CoverageAnalysis): ActionableItem[] {
    const items = [];
    
    // High-impact, low-effort items
    const quickWins = analysis.critical_gaps.filter(gap => 
      gap.business_impact === 'high' && gap.estimated_effort <= 2
    );
    
    for (const gap of quickWins) {
      items.push({
        priority: 'HIGH',
        type: 'QUICK_WIN',
        title: `Add tests for ${gap.function_name}`,
        description: `Critical function with ${gap.business_impact} business impact`,
        estimated_effort: gap.estimated_effort,
        file_path: gap.file_path,
        acceptance_criteria: this.generateAcceptanceCriteria(gap)
      });
    }
    
    // Critical coverage gaps
    const criticalGaps = analysis.critical_gaps.filter(gap => 
      gap.business_impact === 'critical'
    );
    
    for (const gap of criticalGaps) {
      items.push({
        priority: 'CRITICAL',
        type: 'COVERAGE_GAP',
        title: `Critical coverage gap: ${gap.function_name}`,
        description: `Critical business logic without adequate test coverage`,
        estimated_effort: gap.estimated_effort,
        file_path: gap.file_path,
        acceptance_criteria: this.generateAcceptanceCriteria(gap)
      });
    }
    
    return items.sort((a, b) => this.prioritizeItem(a) - this.prioritizeItem(b));
  }
  
  private async generateHTMLReport(report: CoverageReport): Promise<void> {
    const htmlTemplate = `
<!DOCTYPE html>
<html>
<head>
    <title>Coverage Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .summary { background: #f5f5f5; padding: 20px; border-radius: 5px; }
        .metric { display: inline-block; margin: 10px; padding: 10px; background: white; border-radius: 3px; }
        .critical { color: #d32f2f; }
        .high { color: #f57c00; }
        .medium { color: #1976d2; }
        .low { color: #388e3c; }
        .chart { margin: 20px 0; }
        .gap-item { margin: 10px 0; padding: 10px; border-left: 4px solid #ddd; }
        .gap-critical { border-left-color: #d32f2f; }
        .gap-high { border-left-color: #f57c00; }
    </style>
</head>
<body>
    <h1>Test Coverage Report</h1>
    
    <div class="summary">
        <h2>Executive Summary</h2>
        <div class="metric">
            <strong>Overall Coverage:</strong> ${report.executive_summary.overall_coverage}%
        </div>
        <div class="metric">
            <strong>Critical Status:</strong> ${report.executive_summary.critical_coverage_status}
        </div>
        <div class="metric">
            <strong>High Priority Gaps:</strong> ${report.executive_summary.high_priority_gaps}
        </div>
        <div class="metric">
            <strong>Estimated Effort:</strong> ${report.executive_summary.estimated_effort} hours
        </div>
    </div>
    
    <div class="detailed-metrics">
        <h2>Detailed Metrics</h2>
        ${this.generateMetricsHTML(report.detailed_metrics)}
    </div>
    
    <div class="critical-gaps">
        <h2>Critical Coverage Gaps</h2>
        ${this.generateGapsHTML(report.critical_gaps)}
    </div>
    
    <div class="actionable-items">
        <h2>Actionable Items</h2>
        ${this.generateActionableItemsHTML(report.actionable_items)}
    </div>
    
    <div class="chart">
        <h2>Coverage Visualization</h2>
        <canvas id="coverageChart"></canvas>
    </div>
    
    <script>
        ${this.generateChartScript(report)}
    </script>
</body>
</html>`;
    
    await fs.writeFile('coverage-report.html', htmlTemplate);
    console.log('📊 HTML coverage report generated: coverage-report.html');
  }
}
```

**Step 7: Automated Test Implementation**

**Test Implementation Engine:**
```typescript
class TestImplementationEngine {
  async implementMissingTests(gaps: CriticalGap[]): Promise<TestImplementationResult[]> {
    console.log('🔧 Implementing missing tests...');
    
    const results = [];
    
    for (const gap of gaps) {
      try {
        console.log(`📝 Implementing test for ${gap.file_path}:${gap.function_name}`);
        
        // Generate test code
        const testCode = await this.generateTestCode(gap);
        
        // Determine test file location
        const testFilePath = this.getTestFilePath(gap.file_path);
        
        // Write or update test file
        await this.writeTestFile(testFilePath, testCode, gap);
        
        // Validate test implementation
        const validation = await this.validateTestImplementation(testFilePath, gap);
        
        results.push({
          gap: gap,
          test_file_path: testFilePath,
          implementation_status: validation.is_valid ? 'SUCCESS' : 'FAILED',
          coverage_improvement: validation.coverage_improvement,
          issues: validation.issues
        });
        
        console.log(`✅ Test implemented for ${gap.function_name}`);
        
      } catch (error) {
        results.push({
          gap: gap,
          test_file_path: null,
          implementation_status: 'ERROR',
          error: error.message
        });
        
        console.log(`❌ Failed to implement test for ${gap.function_name}: ${error.message}`);
      }
    }
    
    return results;
  }
  
  private async validateTestImplementation(testFilePath: string, gap: CriticalGap): Promise<TestValidation> {
    // Run the new test
    const testResult = await this.runTest(testFilePath);
    
    // Measure coverage improvement
    const coverageImprovement = await this.measureCoverageImprovement(gap.file_path, testFilePath);
    
    // Validate test quality
    const qualityCheck = await this.validateTestQuality(testFilePath);
    
    return {
      is_valid: testResult.passed && qualityCheck.is_high_quality,
      coverage_improvement: coverageImprovement,
      issues: [
        ...testResult.issues,
        ...qualityCheck.issues
      ]
    };
  }
}
```

**Coverage Improvement Quality Checklist:**
- [ ] Critical business logic has comprehensive test coverage
- [ ] Coverage targets are achieved with meaningful tests
- [ ] Error paths and edge cases are thoroughly tested
- [ ] Performance-critical paths have benchmark tests
- [ ] Test quality is maintained while improving coverage
- [ ] Coverage reports provide actionable insights
- [ ] Test implementation is automated and repeatable
- [ ] Coverage trends show continuous improvement

**Agent Coordination for Large Codebases:**
```
"For comprehensive coverage improvement, I'll coordinate multiple specialized agents:

Primary Coverage Agent: Overall coverage analysis and coordination
├── Analysis Agent: Analyze current coverage and identify gaps
├── Unit Test Agent: Implement missing unit tests
├── Integration Test Agent: Create integration tests for system interactions
├── Edge Case Agent: Test boundary conditions and error scenarios
├── Performance Agent: Add performance benchmarks for critical paths
├── Quality Agent: Ensure test quality and effectiveness
└── Report Agent: Generate comprehensive coverage reports and metrics

Each agent will focus on their domain while coordinating to achieve comprehensive coverage improvement."
```

**Anti-Patterns to Avoid:**
- ❌ Writing tests just for coverage numbers (meaningless tests)
- ❌ Ignoring complex or difficult-to-test code (coverage gaps)
- ❌ Focusing only on line coverage (missing branch coverage)
- ❌ Skipping error paths and edge cases (poor test quality)
- ❌ Not measuring test effectiveness (low-quality coverage)
- ❌ Ignoring performance testing for critical paths (performance regressions)

**Final Verification:**
Before completing coverage improvement:
- Are all critical business logic paths tested?
- Are coverage targets achieved with meaningful tests?
- Are error scenarios and edge cases covered?
- Are performance-critical paths benchmarked?
- Are coverage reports actionable and comprehensive?
- Is test quality maintained while improving coverage?

**Final Commitment:**
- **I will**: Analyze coverage comprehensively and identify all critical gaps
- **I will**: Use multiple agents to implement missing tests in parallel
- **I will**: Focus on test quality, not just coverage numbers
- **I will**: Generate comprehensive, actionable coverage reports
- **I will NOT**: Write meaningless tests just for coverage
- **I will NOT**: Skip complex or difficult-to-test code
- **I will NOT**: Ignore error paths and edge cases

**REMEMBER:**
This is COVERAGE IMPROVEMENT mode - comprehensive coverage analysis, meaningful test implementation, and quality assurance. The goal is to achieve high-quality coverage that prevents bugs and improves maintainability.

Executing comprehensive coverage improvement protocol for thorough code validation...