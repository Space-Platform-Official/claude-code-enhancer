---
allowed-tools: all
description: Continuous test execution with intelligent file watching and incremental testing for rapid feedback
intensity: ⚡⚡
pattern: 👁️👁️
---

# 👁️👁️ CRITICAL CONTINUOUS TEST EXECUTION: INTELLIGENT WATCH MODE! 👁️👁️

**THIS IS NOT A SIMPLE FILE WATCHER - THIS IS A COMPREHENSIVE CONTINUOUS TESTING SYSTEM!**

When you run `/test watch`, you are REQUIRED to:

1. **MONITOR** file changes and trigger intelligent test execution
2. **EXECUTE** only relevant tests based on code changes
3. **PROVIDE** real-time feedback and immediate test results
4. **USE MULTIPLE AGENTS** for parallel watch monitoring:
   - Spawn one agent per test type or module
   - Spawn agents for different file types and dependencies
   - Say: "I'll spawn multiple agents to monitor different aspects of the codebase for continuous testing"
5. **OPTIMIZE** test execution speed with intelligent caching
6. **MAINTAIN** test reliability and consistency during development

## 🎯 USE MULTIPLE AGENTS

**MANDATORY AGENT SPAWNING FOR CONTINUOUS TESTING:**
```
"I'll spawn multiple agents to handle continuous testing comprehensively:
- File Watch Agent: Monitor file changes and trigger appropriate tests
- Test Execution Agent: Run relevant tests based on change analysis
- Dependency Agent: Track file dependencies and impact analysis
- Cache Agent: Manage test result caching and optimization
- Feedback Agent: Provide real-time feedback and notifications
- Performance Agent: Monitor test execution speed and optimize watch mode"
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ Run all tests on every change → NO! Use intelligent test selection!
- ❌ Ignore test dependencies → NO! Run affected tests only!
- ❌ Skip test result caching → NO! Optimize with intelligent caching!
- ❌ Provide delayed feedback → NO! Real-time feedback is essential!
- ❌ Ignore file system events → NO! Monitor all relevant changes!
- ❌ "Watch mode is too slow" → NO! Optimize execution speed!

**MANDATORY WORKFLOW:**
```
1. File system monitoring → Setup intelligent file watching
2. IMMEDIATELY spawn agents for parallel watch monitoring
3. Change detection → Analyze code changes and dependencies
4. Test selection → Run only relevant tests based on changes
5. Real-time feedback → Provide immediate test results
6. VERIFY test reliability and optimization effectiveness
```

**YOU ARE NOT DONE UNTIL:**
- ✅ File watching is monitoring all relevant changes
- ✅ Test execution is optimized for speed and accuracy
- ✅ Real-time feedback is provided for all test results
- ✅ Test caching is working effectively
- ✅ Only relevant tests are executed based on changes
- ✅ Watch mode is stable and reliable

---

🛑 **MANDATORY CONTINUOUS TEST EXECUTION CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current project structure and test organization
3. Verify you understand the continuous testing requirements

Execute comprehensive continuous test execution for: $ARGUMENTS

**FORBIDDEN SHORTCUT PATTERNS:**
- "Running all tests is safer" → NO, use intelligent test selection!
- "Caching is too complex" → NO, implement smart caching!
- "File watching is resource intensive" → NO, optimize monitoring!
- "Real-time feedback is hard" → NO, provide immediate results!
- "Watch mode doesn't need optimization" → NO, optimize for speed!

Let me ultrathink about the comprehensive continuous testing architecture and watch strategy.

🚨 **REMEMBER: Fast feedback loops improve development velocity and code quality!** 🚨

**Comprehensive Continuous Test Execution Protocol:**

**Step 0: Watch Mode Architecture and Setup**
- Configure intelligent file system monitoring
- Set up test dependency mapping and impact analysis
- Initialize test result caching and optimization
- Configure real-time feedback mechanisms
- Set up performance monitoring for watch mode

**Step 1: Intelligent File System Monitoring**

**File Watch Configuration:**
```typescript
interface WatchConfig {
  watched_directories: string[];
  ignored_patterns: string[];
  file_extensions: string[];
  debounce_delay: number;
  batch_changes: boolean;
  include_dependencies: boolean;
  watch_test_files: boolean;
  watch_config_files: boolean;
}

interface FileChangeEvent {
  path: string;
  type: 'created' | 'modified' | 'deleted' | 'moved';
  timestamp: number;
  size: number;
  checksum: string;
  dependencies: string[];
  affected_tests: string[];
}

class IntelligentFileWatcher {
  private watchers: Map<string, FSWatcher> = new Map();
  private changeBuffer: FileChangeEvent[] = [];
  private debounceTimer: NodeJS.Timeout | null = null;
  private dependencyMap: Map<string, string[]> = new Map();
  
  constructor(private config: WatchConfig) {
    this.setupWatchers();
    this.buildDependencyMap();
  }
  
  private setupWatchers(): void {
    console.log('👁️ Setting up intelligent file watchers...');
    
    for (const directory of this.config.watched_directories) {
      const watcher = chokidar.watch(directory, {
        ignored: this.config.ignored_patterns,
        persistent: true,
        ignoreInitial: true,
        followSymlinks: true,
        cwd: process.cwd(),
        depth: 99,
        awaitWriteFinish: {
          stabilityThreshold: 100,
          pollInterval: 100
        }
      });
      
      watcher.on('all', (eventType, path) => {
        this.handleFileChange(eventType, path);
      });
      
      this.watchers.set(directory, watcher);
    }
  }
  
  private handleFileChange(eventType: string, filePath: string): void {
    if (!this.isRelevantFile(filePath)) {
      return;
    }
    
    const changeEvent: FileChangeEvent = {
      path: filePath,
      type: eventType as any,
      timestamp: Date.now(),
      size: this.getFileSize(filePath),
      checksum: this.calculateChecksum(filePath),
      dependencies: this.getDependencies(filePath),
      affected_tests: this.getAffectedTests(filePath)
    };
    
    this.changeBuffer.push(changeEvent);
    
    // Debounce changes to avoid excessive test runs
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }
    
    this.debounceTimer = setTimeout(() => {
      this.processChangeBuffer();
    }, this.config.debounce_delay);
  }
  
  private processChangeBuffer(): void {
    if (this.changeBuffer.length === 0) return;
    
    console.log(`📝 Processing ${this.changeBuffer.length} file changes...`);
    
    // Group changes by type and impact
    const changes = this.analyzeChanges(this.changeBuffer);
    
    // Determine affected tests
    const affectedTests = this.determineAffectedTests(changes);
    
    // Trigger test execution
    this.triggerTestExecution(affectedTests, changes);
    
    // Clear buffer
    this.changeBuffer = [];
  }
  
  private analyzeChanges(changes: FileChangeEvent[]): ChangeAnalysis {
    const analysis = {
      source_files: changes.filter(c => this.isSourceFile(c.path)),
      test_files: changes.filter(c => this.isTestFile(c.path)),
      config_files: changes.filter(c => this.isConfigFile(c.path)),
      dependency_files: changes.filter(c => this.isDependencyFile(c.path)),
      impact_level: this.calculateImpactLevel(changes)
    };
    
    return analysis;
  }
  
  private determineAffectedTests(changes: ChangeAnalysis): string[] {
    const affectedTests = new Set<string>();
    
    // Add directly affected tests
    for (const change of changes.source_files) {
      const tests = this.getTestsForFile(change.path);
      tests.forEach(test => affectedTests.add(test));
    }
    
    // Add tests affected by dependencies
    for (const change of changes.source_files) {
      const dependentFiles = this.getDependentFiles(change.path);
      for (const dependentFile of dependentFiles) {
        const tests = this.getTestsForFile(dependentFile);
        tests.forEach(test => affectedTests.add(test));
      }
    }
    
    // If config files changed, run all tests
    if (changes.config_files.length > 0) {
      return this.getAllTestFiles();
    }
    
    return Array.from(affectedTests);
  }
  
  private buildDependencyMap(): void {
    console.log('🔍 Building dependency map...');
    
    const sourceFiles = this.getAllSourceFiles();
    
    for (const file of sourceFiles) {
      const dependencies = this.analyzeDependencies(file);
      this.dependencyMap.set(file, dependencies);
    }
  }
  
  private analyzeDependencies(filePath: string): string[] {
    const content = fs.readFileSync(filePath, 'utf8');
    const dependencies = [];
    
    // Parse different import/require patterns
    const importPatterns = [
      /import\s+.*\s+from\s+['"]([^'"]+)['"]/g,
      /require\s*\(\s*['"]([^'"]+)['"]\s*\)/g,
      /import\s*\(\s*['"]([^'"]+)['"]\s*\)/g,
      /#include\s+<([^>]+)>/g,
      /#include\s+"([^"]+)"/g,
      /from\s+([^\s]+)\s+import/g
    ];
    
    for (const pattern of importPatterns) {
      let match;
      while ((match = pattern.exec(content)) !== null) {
        const dependency = this.resolveDependencyPath(match[1], filePath);
        if (dependency) {
          dependencies.push(dependency);
        }
      }
    }
    
    return dependencies;
  }
}
```

**Step 2: Parallel Agent Deployment for Watch Mode**

**Agent Spawning Strategy:**
```
"I've identified multiple aspects of continuous testing that need monitoring. I'll spawn specialized agents:

1. **File System Agent**: 'Monitor file changes across all watched directories'
2. **Dependency Analysis Agent**: 'Track file dependencies and impact relationships'
3. **Test Selection Agent**: 'Determine which tests to run based on changes'
4. **Test Execution Agent**: 'Execute selected tests with optimal parallelization'
5. **Cache Management Agent**: 'Manage test result caching and optimization'
6. **Feedback Agent**: 'Provide real-time feedback and notifications'
7. **Performance Monitoring Agent**: 'Monitor watch mode performance and optimize'

Each agent will work continuously while coordinating to provide fast, accurate test feedback."
```

**Step 3: Intelligent Test Selection and Execution**

**Test Selection Engine:**
```typescript
class IntelligentTestSelector {
  private testMap: Map<string, TestInfo[]> = new Map();
  private executionHistory: TestExecutionHistory = new TestExecutionHistory();
  private cacheManager: TestCacheManager = new TestCacheManager();
  
  async selectTestsForChanges(changes: FileChangeEvent[]): Promise<TestSelection> {
    console.log('🎯 Selecting tests for changes...');
    
    const selection = {
      unit_tests: [],
      integration_tests: [],
      e2e_tests: [],
      performance_tests: [],
      execution_strategy: 'parallel',
      estimated_duration: 0
    };
    
    for (const change of changes) {
      const testInfo = await this.analyzeTestRequirements(change);
      
      // Add unit tests
      selection.unit_tests.push(...testInfo.unit_tests);
      
      // Add integration tests if needed
      if (testInfo.affects_integration) {
        selection.integration_tests.push(...testInfo.integration_tests);
      }
      
      // Add e2e tests for critical changes
      if (testInfo.is_critical_change) {
        selection.e2e_tests.push(...testInfo.e2e_tests);
      }
      
      // Add performance tests for performance-critical files
      if (testInfo.is_performance_critical) {
        selection.performance_tests.push(...testInfo.performance_tests);
      }
    }
    
    // Remove duplicates and optimize execution order
    selection.unit_tests = this.removeDuplicates(selection.unit_tests);
    selection.integration_tests = this.removeDuplicates(selection.integration_tests);
    selection.e2e_tests = this.removeDuplicates(selection.e2e_tests);
    selection.performance_tests = this.removeDuplicates(selection.performance_tests);
    
    // Estimate execution time
    selection.estimated_duration = this.estimateExecutionTime(selection);
    
    return selection;
  }
  
  private async analyzeTestRequirements(change: FileChangeEvent): Promise<TestRequirements> {
    const fileInfo = await this.analyzeFile(change.path);
    
    return {
      unit_tests: this.getUnitTestsForFile(change.path),
      integration_tests: this.getIntegrationTestsForFile(change.path),
      e2e_tests: this.getE2ETestsForFile(change.path),
      performance_tests: this.getPerformanceTestsForFile(change.path),
      affects_integration: fileInfo.has_external_dependencies,
      is_critical_change: fileInfo.is_critical_business_logic,
      is_performance_critical: fileInfo.is_performance_critical
    };
  }
  
  async executeSelectedTests(selection: TestSelection): Promise<TestExecutionResult> {
    console.log(`🏃 Executing ${this.countTotalTests(selection)} tests...`);
    
    const startTime = Date.now();
    const results = {
      unit_results: [],
      integration_results: [],
      e2e_results: [],
      performance_results: [],
      overall_success: true,
      execution_time: 0
    };
    
    // Execute tests in parallel where possible
    const promises = [];
    
    if (selection.unit_tests.length > 0) {
      promises.push(this.executeUnitTests(selection.unit_tests));
    }
    
    if (selection.integration_tests.length > 0) {
      promises.push(this.executeIntegrationTests(selection.integration_tests));
    }
    
    if (selection.e2e_tests.length > 0) {
      promises.push(this.executeE2ETests(selection.e2e_tests));
    }
    
    if (selection.performance_tests.length > 0) {
      promises.push(this.executePerformanceTests(selection.performance_tests));
    }
    
    const executionResults = await Promise.all(promises);
    
    // Compile results
    results.unit_results = executionResults[0] || [];
    results.integration_results = executionResults[1] || [];
    results.e2e_results = executionResults[2] || [];
    results.performance_results = executionResults[3] || [];
    
    results.overall_success = executionResults.every(result => 
      result.every(test => test.success)
    );
    
    results.execution_time = Date.now() - startTime;
    
    // Cache results for future runs
    await this.cacheManager.cacheResults(selection, results);
    
    return results;
  }
  
  private async executeUnitTests(tests: string[]): Promise<TestResult[]> {
    const results = [];
    
    // Group tests by framework for batch execution
    const testsByFramework = this.groupTestsByFramework(tests);
    
    for (const [framework, frameworkTests] of testsByFramework) {
      const frameworkResults = await this.executeTestsWithFramework(framework, frameworkTests);
      results.push(...frameworkResults);
    }
    
    return results;
  }
  
  private async executeTestsWithFramework(framework: string, tests: string[]): Promise<TestResult[]> {
    console.log(`🧪 Executing ${tests.length} ${framework} tests...`);
    
    const command = this.buildTestCommand(framework, tests);
    const result = await this.executeCommand(command);
    
    return this.parseTestResults(result, framework);
  }
  
  private buildTestCommand(framework: string, tests: string[]): string {
    const commands = {
      jest: `npx jest ${tests.join(' ')} --passWithNoTests`,
      mocha: `npx mocha ${tests.join(' ')}`,
      pytest: `pytest ${tests.join(' ')} -v`,
      go: `go test ${tests.join(' ')} -v`,
      rspec: `rspec ${tests.join(' ')}`,
      phpunit: `phpunit ${tests.join(' ')}`
    };
    
    return commands[framework] || `${framework} ${tests.join(' ')}`;
  }
}
```

**Step 4: Advanced Test Result Caching**

**Test Cache Management:**
```typescript
class TestCacheManager {
  private cache: Map<string, CachedTestResult> = new Map();
  private checksumCache: Map<string, string> = new Map();
  private dependencyCache: Map<string, string[]> = new Map();
  
  async getCachedResults(tests: string[], fileChanges: FileChangeEvent[]): Promise<CachedTestResult[]> {
    const cachedResults = [];
    
    for (const test of tests) {
      const cacheKey = this.generateCacheKey(test, fileChanges);
      const cachedResult = this.cache.get(cacheKey);
      
      if (cachedResult && await this.isCacheValid(cachedResult, fileChanges)) {
        console.log(`📋 Using cached result for ${test}`);
        cachedResults.push(cachedResult);
      }
    }
    
    return cachedResults;
  }
  
  async cacheResults(selection: TestSelection, results: TestExecutionResult): Promise<void> {
    const timestamp = Date.now();
    
    // Cache unit test results
    for (const result of results.unit_results) {
      const cacheKey = this.generateCacheKey(result.test_name, []);
      
      this.cache.set(cacheKey, {
        test_name: result.test_name,
        result: result,
        timestamp: timestamp,
        file_checksums: await this.getFileChecksums(result.affected_files),
        dependency_checksums: await this.getDependencyChecksums(result.affected_files)
      });
    }
    
    // Cache integration test results
    for (const result of results.integration_results) {
      const cacheKey = this.generateCacheKey(result.test_name, []);
      
      this.cache.set(cacheKey, {
        test_name: result.test_name,
        result: result,
        timestamp: timestamp,
        file_checksums: await this.getFileChecksums(result.affected_files),
        dependency_checksums: await this.getDependencyChecksums(result.affected_files)
      });
    }
    
    // Cleanup old cache entries
    await this.cleanupOldCacheEntries();
  }
  
  private async isCacheValid(cachedResult: CachedTestResult, fileChanges: FileChangeEvent[]): Promise<boolean> {
    // Check if any affected files have changed
    for (const change of fileChanges) {
      const currentChecksum = this.calculateChecksum(change.path);
      const cachedChecksum = cachedResult.file_checksums.get(change.path);
      
      if (cachedChecksum && currentChecksum !== cachedChecksum) {
        return false;
      }
    }
    
    // Check if dependencies have changed
    const currentDependencyChecksums = await this.getDependencyChecksums(
      Array.from(cachedResult.file_checksums.keys())
    );
    
    for (const [file, currentChecksum] of currentDependencyChecksums) {
      const cachedChecksum = cachedResult.dependency_checksums.get(file);
      
      if (cachedChecksum && currentChecksum !== cachedChecksum) {
        return false;
      }
    }
    
    // Check cache age
    const cacheAge = Date.now() - cachedResult.timestamp;
    const maxCacheAge = 30 * 60 * 1000; // 30 minutes
    
    return cacheAge < maxCacheAge;
  }
  
  private generateCacheKey(testName: string, fileChanges: FileChangeEvent[]): string {
    const changePaths = fileChanges.map(c => c.path).sort();
    return `${testName}:${changePaths.join(':')}`;
  }
  
  private async getFileChecksums(files: string[]): Promise<Map<string, string>> {
    const checksums = new Map<string, string>();
    
    for (const file of files) {
      const checksum = this.calculateChecksum(file);
      checksums.set(file, checksum);
    }
    
    return checksums;
  }
  
  private calculateChecksum(filePath: string): string {
    if (!fs.existsSync(filePath)) {
      return '';
    }
    
    const content = fs.readFileSync(filePath);
    return crypto.createHash('md5').update(content).digest('hex');
  }
}
```

**Step 5: Real-Time Feedback and Notifications**

**Feedback Management System:**
```typescript
class RealTimeFeedbackManager {
  private notificationChannels: NotificationChannel[] = [];
  private feedbackHistory: FeedbackEvent[] = [];
  private currentStatus: WatchStatus = 'idle';
  
  constructor() {
    this.setupNotificationChannels();
  }
  
  private setupNotificationChannels(): void {
    // Terminal notification
    this.notificationChannels.push(new TerminalNotification());
    
    // Desktop notification
    this.notificationChannels.push(new DesktopNotification());
    
    // IDE notification (if supported)
    this.notificationChannels.push(new IDENotification());
    
    // Slack notification (if configured)
    if (process.env.SLACK_WEBHOOK_URL) {
      this.notificationChannels.push(new SlackNotification());
    }
  }
  
  async notifyFileChange(changes: FileChangeEvent[]): Promise<void> {
    const message = this.formatFileChangeMessage(changes);
    
    await this.sendNotification({
      type: 'file_change',
      message: message,
      severity: 'info',
      timestamp: Date.now()
    });
  }
  
  async notifyTestStart(selection: TestSelection): Promise<void> {
    const testCount = this.countTotalTests(selection);
    
    await this.sendNotification({
      type: 'test_start',
      message: `🏃 Running ${testCount} tests...`,
      severity: 'info',
      timestamp: Date.now()
    });
    
    this.currentStatus = 'running';
  }
  
  async notifyTestResults(results: TestExecutionResult): Promise<void> {
    const message = this.formatTestResultsMessage(results);
    const severity = results.overall_success ? 'success' : 'error';
    
    await this.sendNotification({
      type: 'test_results',
      message: message,
      severity: severity,
      timestamp: Date.now(),
      details: results
    });
    
    this.currentStatus = results.overall_success ? 'success' : 'failed';
  }
  
  async notifyTestFailure(failure: TestFailure): Promise<void> {
    const message = this.formatTestFailureMessage(failure);
    
    await this.sendNotification({
      type: 'test_failure',
      message: message,
      severity: 'error',
      timestamp: Date.now(),
      details: failure
    });
  }
  
  private async sendNotification(notification: Notification): Promise<void> {
    // Store in history
    this.feedbackHistory.push(notification);
    
    // Send to all channels
    const promises = this.notificationChannels.map(channel => 
      channel.send(notification).catch(error => {
        console.error(`Failed to send notification via ${channel.name}:`, error);
      })
    );
    
    await Promise.all(promises);
  }
  
  private formatFileChangeMessage(changes: FileChangeEvent[]): string {
    const changeCount = changes.length;
    const files = changes.map(c => path.basename(c.path)).join(', ');
    
    return `📝 ${changeCount} file${changeCount > 1 ? 's' : ''} changed: ${files}`;
  }
  
  private formatTestResultsMessage(results: TestExecutionResult): string {
    const totalTests = this.countTotalResults(results);
    const passedTests = this.countPassedResults(results);
    const failedTests = totalTests - passedTests;
    
    if (results.overall_success) {
      return `✅ All ${totalTests} tests passed (${results.execution_time}ms)`;
    } else {
      return `❌ ${failedTests} of ${totalTests} tests failed (${results.execution_time}ms)`;
    }
  }
  
  private formatTestFailureMessage(failure: TestFailure): string {
    return `❌ ${failure.test_name} failed: ${failure.error_message}`;
  }
}

class TerminalNotification implements NotificationChannel {
  name = 'terminal';
  
  async send(notification: Notification): Promise<void> {
    const timestamp = new Date(notification.timestamp).toLocaleTimeString();
    const prefix = this.getSeverityPrefix(notification.severity);
    
    console.log(`[${timestamp}] ${prefix} ${notification.message}`);
    
    if (notification.details && notification.type === 'test_failure') {
      console.log(`  ${notification.details.stack_trace}`);
    }
  }
  
  private getSeverityPrefix(severity: string): string {
    const prefixes = {
      info: 'ℹ️',
      success: '✅',
      warning: '⚠️',
      error: '❌'
    };
    
    return prefixes[severity] || 'ℹ️';
  }
}

class DesktopNotification implements NotificationChannel {
  name = 'desktop';
  
  async send(notification: Notification): Promise<void> {
    if (notification.type === 'test_results') {
      const title = notification.severity === 'success' ? 'Tests Passed' : 'Tests Failed';
      
      this.showDesktopNotification(title, notification.message);
    }
  }
  
  private showDesktopNotification(title: string, message: string): void {
    // Use node-notifier or similar library
    const notifier = require('node-notifier');
    
    notifier.notify({
      title: title,
      message: message,
      sound: true,
      wait: true
    });
  }
}
```

**Step 6: Watch Mode Performance Optimization**

**Performance Monitoring and Optimization:**
```typescript
class WatchModePerformanceOptimizer {
  private metrics: PerformanceMetrics = {
    file_change_detection_time: [],
    test_selection_time: [],
    test_execution_time: [],
    cache_hit_rate: 0,
    memory_usage: []
  };
  
  async optimizeWatchMode(): Promise<OptimizationResult> {
    console.log('⚡ Optimizing watch mode performance...');
    
    // Analyze current performance
    const analysis = await this.analyzePerformance();
    
    // Apply optimizations
    const optimizations = await this.applyOptimizations(analysis);
    
    // Verify improvements
    const verification = await this.verifyOptimizations(optimizations);
    
    return {
      optimizations_applied: optimizations,
      performance_improvement: verification.improvement,
      recommendations: verification.recommendations
    };
  }
  
  private async analyzePerformance(): Promise<PerformanceAnalysis> {
    return {
      average_change_detection_time: this.calculateAverage(this.metrics.file_change_detection_time),
      average_test_selection_time: this.calculateAverage(this.metrics.test_selection_time),
      average_test_execution_time: this.calculateAverage(this.metrics.test_execution_time),
      cache_effectiveness: this.metrics.cache_hit_rate,
      memory_usage_trend: this.analyzeMemoryTrend(),
      bottlenecks: this.identifyBottlenecks()
    };
  }
  
  private async applyOptimizations(analysis: PerformanceAnalysis): Promise<Optimization[]> {
    const optimizations = [];
    
    // File watching optimization
    if (analysis.average_change_detection_time > 100) {
      optimizations.push(await this.optimizeFileWatching());
    }
    
    // Test selection optimization
    if (analysis.average_test_selection_time > 500) {
      optimizations.push(await this.optimizeTestSelection());
    }
    
    // Test execution optimization
    if (analysis.average_test_execution_time > 5000) {
      optimizations.push(await this.optimizeTestExecution());
    }
    
    // Cache optimization
    if (analysis.cache_effectiveness < 0.3) {
      optimizations.push(await this.optimizeCaching());
    }
    
    // Memory optimization
    if (analysis.memory_usage_trend === 'increasing') {
      optimizations.push(await this.optimizeMemoryUsage());
    }
    
    return optimizations;
  }
  
  private async optimizeFileWatching(): Promise<Optimization> {
    console.log('🔍 Optimizing file watching...');
    
    // Reduce watched directories
    const optimizedDirectories = await this.optimizeWatchedDirectories();
    
    // Improve ignore patterns
    const optimizedIgnorePatterns = await this.optimizeIgnorePatterns();
    
    // Optimize debounce settings
    const optimizedDebounce = await this.optimizeDebounceSettings();
    
    return {
      type: 'file_watching',
      description: 'Optimized file watching configuration',
      changes: {
        watched_directories: optimizedDirectories,
        ignore_patterns: optimizedIgnorePatterns,
        debounce_settings: optimizedDebounce
      },
      estimated_improvement: '30-50% faster change detection'
    };
  }
  
  private async optimizeTestSelection(): Promise<Optimization> {
    console.log('🎯 Optimizing test selection...');
    
    // Build better dependency maps
    const optimizedDependencyMap = await this.buildOptimizedDependencyMap();
    
    // Improve test impact analysis
    const optimizedImpactAnalysis = await this.optimizeImpactAnalysis();
    
    // Cache selection results
    const selectionCache = await this.implementSelectionCache();
    
    return {
      type: 'test_selection',
      description: 'Optimized test selection algorithm',
      changes: {
        dependency_map: optimizedDependencyMap,
        impact_analysis: optimizedImpactAnalysis,
        selection_cache: selectionCache
      },
      estimated_improvement: '50-70% faster test selection'
    };
  }
  
  private async optimizeTestExecution(): Promise<Optimization> {
    console.log('🏃 Optimizing test execution...');
    
    // Improve parallelization
    const optimizedParallelization = await this.optimizeParallelization();
    
    // Optimize test grouping
    const optimizedGrouping = await this.optimizeTestGrouping();
    
    // Improve resource allocation
    const optimizedResourceAllocation = await this.optimizeResourceAllocation();
    
    return {
      type: 'test_execution',
      description: 'Optimized test execution strategy',
      changes: {
        parallelization: optimizedParallelization,
        test_grouping: optimizedGrouping,
        resource_allocation: optimizedResourceAllocation
      },
      estimated_improvement: '40-60% faster test execution'
    };
  }
  
  private async optimizeCaching(): Promise<Optimization> {
    console.log('📋 Optimizing caching strategy...');
    
    // Improve cache key generation
    const optimizedCacheKeys = await this.optimizeCacheKeys();
    
    // Enhance cache validation
    const optimizedValidation = await this.optimizeCacheValidation();
    
    // Implement cache preloading
    const cachePreloading = await this.implementCachePreloading();
    
    return {
      type: 'caching',
      description: 'Optimized caching strategy',
      changes: {
        cache_keys: optimizedCacheKeys,
        cache_validation: optimizedValidation,
        cache_preloading: cachePreloading
      },
      estimated_improvement: '60-80% cache hit rate improvement'
    };
  }
}
```

**Step 7: Watch Mode Configuration and Customization**

**Watch Configuration Management:**
```typescript
interface WatchConfiguration {
  file_patterns: {
    include: string[];
    exclude: string[];
    extensions: string[];
  };
  test_selection: {
    strategy: 'all' | 'affected' | 'smart';
    include_integration: boolean;
    include_e2e: boolean;
    parallel_execution: boolean;
  };
  performance: {
    debounce_delay: number;
    max_parallel_tests: number;
    cache_enabled: boolean;
    cache_duration: number;
  };
  notifications: {
    desktop: boolean;
    terminal: boolean;
    slack: boolean;
    email: boolean;
  };
  advanced: {
    dependency_tracking: boolean;
    impact_analysis: boolean;
    performance_monitoring: boolean;
    auto_optimization: boolean;
  };
}

class WatchConfigurationManager {
  private config: WatchConfiguration;
  
  constructor(configPath?: string) {
    this.loadConfiguration(configPath);
  }
  
  private loadConfiguration(configPath?: string): void {
    const defaultConfig = this.getDefaultConfiguration();
    
    if (configPath && fs.existsSync(configPath)) {
      const userConfig = this.loadUserConfiguration(configPath);
      this.config = this.mergeConfigurations(defaultConfig, userConfig);
    } else {
      this.config = defaultConfig;
    }
  }
  
  private getDefaultConfiguration(): WatchConfiguration {
    return {
      file_patterns: {
        include: ['src/**/*', 'lib/**/*', 'app/**/*'],
        exclude: ['node_modules/**/*', 'dist/**/*', 'build/**/*', 'coverage/**/*'],
        extensions: ['.js', '.ts', '.jsx', '.tsx', '.py', '.go', '.java', '.cs', '.php', '.rb']
      },
      test_selection: {
        strategy: 'smart',
        include_integration: true,
        include_e2e: false,
        parallel_execution: true
      },
      performance: {
        debounce_delay: 300,
        max_parallel_tests: 4,
        cache_enabled: true,
        cache_duration: 1800000 // 30 minutes
      },
      notifications: {
        desktop: true,
        terminal: true,
        slack: false,
        email: false
      },
      advanced: {
        dependency_tracking: true,
        impact_analysis: true,
        performance_monitoring: true,
        auto_optimization: true
      }
    };
  }
  
  async validateConfiguration(): Promise<ValidationResult> {
    const validation = {
      is_valid: true,
      issues: [],
      warnings: []
    };
    
    // Validate file patterns
    const patternValidation = await this.validateFilePatterns();
    validation.issues.push(...patternValidation.issues);
    validation.warnings.push(...patternValidation.warnings);
    
    // Validate test selection
    const selectionValidation = await this.validateTestSelection();
    validation.issues.push(...selectionValidation.issues);
    validation.warnings.push(...selectionValidation.warnings);
    
    // Validate performance settings
    const performanceValidation = await this.validatePerformanceSettings();
    validation.issues.push(...performanceValidation.issues);
    validation.warnings.push(...performanceValidation.warnings);
    
    validation.is_valid = validation.issues.length === 0;
    
    return validation;
  }
  
  async optimizeConfiguration(): Promise<WatchConfiguration> {
    console.log('⚙️  Optimizing watch configuration...');
    
    const optimizedConfig = { ...this.config };
    
    // Optimize file patterns based on project structure
    optimizedConfig.file_patterns = await this.optimizeFilePatterns();
    
    // Optimize performance settings based on system capabilities
    optimizedConfig.performance = await this.optimizePerformanceSettings();
    
    // Optimize test selection based on test suite characteristics
    optimizedConfig.test_selection = await this.optimizeTestSelection();
    
    return optimizedConfig;
  }
}
```

**Continuous Test Execution Quality Checklist:**
- [ ] File watching is monitoring all relevant changes
- [ ] Test selection is intelligent and optimized
- [ ] Test execution is fast and parallel
- [ ] Real-time feedback is provided for all results
- [ ] Test caching is working effectively
- [ ] Performance is optimized for speed
- [ ] Configuration is validated and optimal
- [ ] Watch mode is stable and reliable

**Agent Coordination for Watch Mode:**
```
"For comprehensive continuous testing, I'll coordinate multiple specialized agents:

Primary Watch Agent: Overall watch mode coordination and management
├── File System Agent: Monitor file changes and trigger events
├── Dependency Agent: Track file dependencies and impact analysis
├── Test Selection Agent: Determine which tests to run intelligently
├── Test Execution Agent: Execute selected tests with optimal parallelization
├── Cache Agent: Manage test result caching and optimization
├── Feedback Agent: Provide real-time notifications and feedback
└── Performance Agent: Monitor and optimize watch mode performance

Each agent will work continuously while coordinating to provide the fastest possible feedback loop."
```

**Anti-Patterns to Avoid:**
- ❌ Running all tests on every change (slow feedback)
- ❌ Ignoring test dependencies (missing affected tests)
- ❌ No test result caching (redundant execution)
- ❌ Poor file watching patterns (excessive monitoring)
- ❌ Sequential test execution (slow feedback)
- ❌ No performance optimization (resource waste)

**Final Verification:**
Before completing continuous test execution:
- Is file watching monitoring all relevant changes?
- Are only relevant tests being executed?
- Is test caching working effectively?
- Is real-time feedback being provided?
- Is performance optimized for speed?
- Is watch mode stable and reliable?

**Final Commitment:**
- **I will**: Set up intelligent file watching with optimized patterns
- **I will**: Use multiple agents for parallel watch monitoring
- **I will**: Implement smart test selection based on changes
- **I will**: Provide real-time feedback and notifications
- **I will NOT**: Run all tests on every change
- **I will NOT**: Ignore test caching and optimization
- **I will NOT**: Provide delayed or poor feedback

**REMEMBER:**
This is CONTINUOUS TEST EXECUTION mode - intelligent file watching, smart test selection, and real-time feedback. The goal is to provide the fastest possible feedback loop while maintaining test accuracy and reliability.

Executing comprehensive continuous test execution protocol for optimal development velocity...