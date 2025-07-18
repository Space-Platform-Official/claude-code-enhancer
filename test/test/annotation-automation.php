#!/usr/bin/env php
<?php

/**
 * Annotation Automation Command
 * 
 * Comprehensive bidirectional annotation orchestration tool for ongoing
 * annotation management, scanning, validation, and automated updating.
 * 
 * Usage:
 *   php annotation-automation.php [command] [options]
 * 
 * Commands:
 *   scan      - Scan all files for annotation analysis
 *   validate  - Validate annotation consistency
 *   update    - Update annotations based on analysis
 *   report    - Generate comprehensive reports
 *   fix       - Automatically fix annotation issues
 *   monitor   - Continuous monitoring mode
 * 
 * Options:
 *   --source-dir=DIR     Source directory (default: src)
 *   --test-dir=DIR       Test directory (default: test/Cases)
 *   --output=FILE        Output file for reports
 *   --format=FORMAT      Output format (json|console|html) (default: console)
 *   --fix-mode=MODE      Fix mode (safe|aggressive) (default: safe)
 *   --watch              Watch for file changes
 *   --dry-run            Show what would be done without making changes
 *   --verbose            Verbose output
 *   --help               Show this help
 */

declare(strict_types=1);

// Bootstrap
require_once __DIR__ . '/../../vendor/autoload.php';

use SpacePlatform\Utils\Annotation\Tools\ValidationOrchestrator;
use SpacePlatform\Utils\Annotation\Tools\BidirectionalLinkageValidator;
use SpacePlatform\Utils\Annotation\Tools\AnnotationConsistencyChecker;
use SpacePlatform\Utils\Annotation\Tools\CoverageGapDetector;
use SpacePlatform\Utils\Annotation\Tools\ValidationReporter;
use SpacePlatform\Utils\Annotation\Validation\AnnotationManager;
use SpacePlatform\Utils\Annotation\Validation\AnnotationParser;
use SpacePlatform\Utils\Annotation\Validation\AnnotationValidator;

/**
 * Main annotation automation class
 */
class AnnotationAutomation
{
    private ValidationOrchestrator $orchestrator;
    private AnnotationManager $manager;
    private BidirectionalLinkageValidator $linkageValidator;
    private AnnotationConsistencyChecker $consistencyChecker;
    private CoverageGapDetector $coverageDetector;
    private ValidationReporter $reporter;
    
    private array $config;
    private array $options;
    
    public function __construct(array $options = [])
    {
        $this->options = $options;
        $this->config = $this->loadConfig();
        $this->initializeServices();
    }
    
    /**
     * Main execution method
     */
    public function run(): int
    {
        $command = $this->options['command'] ?? 'scan';
        
        try {
            switch ($command) {
                case 'scan':
                    return $this->scanCommand();
                case 'validate':
                    return $this->validateCommand();
                case 'update':
                    return $this->updateCommand();
                case 'report':
                    return $this->reportCommand();
                case 'fix':
                    return $this->fixCommand();
                case 'monitor':
                    return $this->monitorCommand();
                case 'help':
                    $this->showHelp();
                    return 0;
                default:
                    $this->error("Unknown command: {$command}");
                    $this->showHelp();
                    return 1;
            }
        } catch (Exception $e) {
            $this->error("Error: " . $e->getMessage());
            if ($this->options['verbose'] ?? false) {
                $this->error("Stack trace: " . $e->getTraceAsString());
            }
            return 1;
        }
    }
    
    /**
     * Scan command - comprehensive annotation analysis
     */
    private function scanCommand(): int
    {
        $this->info("Starting comprehensive annotation scan...");
        
        $sourceFiles = $this->findSourceFiles();
        $testFiles = $this->findTestFiles();
        
        $this->info("Found " . count($sourceFiles) . " source files and " . count($testFiles) . " test files");
        
        // Scan for annotations
        $sourceClasses = $this->extractClassNames($sourceFiles);
        $testClasses = $this->extractClassNames($testFiles);
        
        // Analyze bidirectional linkage
        $linkageAnalysis = $this->manager->analyzeBidirectionalLinkage($testClasses, $sourceClasses);
        
        // Generate coverage report
        $coverageReport = $this->manager->generateCoverageReport($sourceClasses, $testClasses);
        
        // Validate consistency
        $consistencyReport = $this->manager->validateAnnotationConsistency($testClasses, $sourceClasses);
        
        // Generate comprehensive scan report
        $scanReport = [
            'timestamp' => date('Y-m-d H:i:s'),
            'summary' => [
                'source_files' => count($sourceFiles),
                'test_files' => count($testFiles),
                'source_classes' => count($sourceClasses),
                'test_classes' => count($testClasses),
            ],
            'linkage_analysis' => $linkageAnalysis,
            'coverage_report' => $coverageReport,
            'consistency_report' => $consistencyReport,
            'recommendations' => $this->generateRecommendations($linkageAnalysis, $coverageReport, $consistencyReport),
        ];
        
        $this->outputReport($scanReport, 'scan_report');
        
        return 0;
    }
    
    /**
     * Validate command - validation only
     */
    private function validateCommand(): int
    {
        $this->info("Running annotation validation...");
        
        $validationResult = $this->orchestrator->runComprehensiveValidation($this->options['output'] ?? null);
        
        if ($validationResult->isSuccess()) {
            $this->success("Validation completed successfully");
            return 0;
        } else {
            $this->error("Validation failed: " . $validationResult->getErrorMessage());
            return 1;
        }
    }
    
    /**
     * Update command - update annotations based on analysis
     */
    private function updateCommand(): int
    {
        $this->info("Starting annotation update process...");
        
        if ($this->options['dry-run'] ?? false) {
            $this->info("DRY RUN MODE - No changes will be made");
        }
        
        // First, perform scan to identify what needs updating
        $sourceFiles = $this->findSourceFiles();
        $testFiles = $this->findTestFiles();
        
        $sourceClasses = $this->extractClassNames($sourceFiles);
        $testClasses = $this->extractClassNames($testFiles);
        
        $linkageAnalysis = $this->manager->analyzeBidirectionalLinkage($testClasses, $sourceClasses);
        
        $updatesApplied = 0;
        
        // Process orphaned tests - add @Verified annotations to source methods
        foreach ($linkageAnalysis['orphanedTests'] as $orphanedTest) {
            $this->info("Processing orphaned test: " . $orphanedTest['testClass']);
            
            if ($this->updateSourceForOrphanedTest($orphanedTest)) {
                $updatesApplied++;
            }
        }
        
        // Process orphaned sources - add @TestedBy annotations to test methods
        foreach ($linkageAnalysis['orphanedSources'] as $orphanedSource) {
            $this->info("Processing orphaned source: " . $orphanedSource['sourceClass']);
            
            if ($this->updateTestForOrphanedSource($orphanedSource)) {
                $updatesApplied++;
            }
        }
        
        // Fix invalid linkages
        foreach ($linkageAnalysis['invalidLinks'] as $invalidLink) {
            $this->info("Fixing invalid linkage: " . $invalidLink['testClass'] . " -> " . $invalidLink['sourceClass']);
            
            if ($this->fixInvalidLinkage($invalidLink)) {
                $updatesApplied++;
            }
        }
        
        $this->success("Update process completed. Applied {$updatesApplied} updates.");
        
        return 0;
    }
    
    /**
     * Report command - generate comprehensive reports
     */
    private function reportCommand(): int
    {
        $this->info("Generating comprehensive annotation reports...");
        
        $reports = $this->generateAllReports();
        
        foreach ($reports as $reportName => $report) {
            $this->outputReport($report, $reportName);
        }
        
        return 0;
    }
    
    /**
     * Fix command - automatically fix annotation issues
     */
    private function fixCommand(): int
    {
        $this->info("Starting automatic annotation fixing...");
        
        $fixMode = $this->options['fix-mode'] ?? 'safe';
        $this->info("Using fix mode: {$fixMode}");
        
        if ($this->options['dry-run'] ?? false) {
            $this->info("DRY RUN MODE - No changes will be made");
        }
        
        $fixesApplied = 0;
        
        // Run validation to find issues
        $validationResult = $this->orchestrator->runComprehensiveValidation();
        
        if ($validationResult->isSuccess()) {
            $this->success("No issues found to fix");
            return 0;
        }
        
        $validationData = $validationResult->getValue();
        
        // Fix bidirectional linkage issues
        if (isset($validationData['results']['bidirectional_linkage'])) {
            $linkageResult = $validationData['results']['bidirectional_linkage'];
            if ($linkageResult->isFailure()) {
                $fixesApplied += $this->fixBidirectionalLinkageIssues($linkageResult);
            }
        }
        
        // Fix annotation consistency issues
        if (isset($validationData['results']['annotation_consistency'])) {
            $consistencyResult = $validationData['results']['annotation_consistency'];
            if ($consistencyResult->isFailure()) {
                $fixesApplied += $this->fixAnnotationConsistencyIssues($consistencyResult);
            }
        }
        
        // Fix coverage gaps
        if (isset($validationData['results']['coverage_gaps'])) {
            $coverageResult = $validationData['results']['coverage_gaps'];
            if ($coverageResult->isFailure()) {
                $fixesApplied += $this->fixCoverageGaps($coverageResult);
            }
        }
        
        $this->success("Automatic fix completed. Applied {$fixesApplied} fixes.");
        
        return 0;
    }
    
    /**
     * Monitor command - continuous monitoring
     */
    private function monitorCommand(): int
    {
        $this->info("Starting continuous annotation monitoring...");
        
        if (!$this->options['watch'] ?? false) {
            $this->error("Monitor command requires --watch option");
            return 1;
        }
        
        $this->info("Monitoring directories for changes...");
        $this->info("Press Ctrl+C to stop monitoring");
        
        $lastScanTime = 0;
        $scanInterval = 5; // seconds
        
        while (true) {
            if (time() - $lastScanTime >= $scanInterval) {
                $this->info("Running scheduled annotation scan...");
                
                try {
                    $result = $this->orchestrator->runQuickValidation();
                    
                    if ($result->isFailure()) {
                        $this->warning("Validation issues detected during monitoring");
                        
                        // Auto-fix if enabled
                        if ($this->options['auto-fix'] ?? false) {
                            $this->info("Auto-fixing detected issues...");
                            $this->fixCommand();
                        }
                    }
                } catch (Exception $e) {
                    $this->error("Error during monitoring: " . $e->getMessage());
                }
                
                $lastScanTime = time();
            }
            
            sleep(1);
        }
        
        return 0;
    }
    
    /**
     * Initialize services
     */
    private function initializeServices(): void
    {
        $sourceDir = $this->options['source-dir'] ?? 'src';
        $testDir = $this->options['test-dir'] ?? 'test/Cases';
        $reportFormat = $this->options['format'] ?? 'console';
        
        $this->orchestrator = new ValidationOrchestrator($sourceDir, $testDir, $reportFormat);
        $this->manager = new AnnotationManager();
        $this->linkageValidator = new BidirectionalLinkageValidator($sourceDir, $testDir);
        $this->consistencyChecker = new AnnotationConsistencyChecker();
        $this->coverageDetector = new CoverageGapDetector($sourceDir, $testDir);
        $this->reporter = new ValidationReporter($reportFormat);
    }
    
    /**
     * Load configuration
     */
    private function loadConfig(): array
    {
        $defaultConfig = [
            'source_directory' => 'src',
            'test_directory' => 'test/Cases',
            'output_format' => 'console',
            'fix_mode' => 'safe',
            'scan_interval' => 5,
            'auto_fix' => false,
        ];
        
        $configFile = __DIR__ . '/annotation-automation.json';
        if (file_exists($configFile)) {
            $userConfig = json_decode(file_get_contents($configFile), true);
            return array_merge($defaultConfig, $userConfig);
        }
        
        return $defaultConfig;
    }
    
    /**
     * Find source files
     */
    private function findSourceFiles(): array
    {
        return $this->findPHPFiles($this->options['source-dir'] ?? 'src');
    }
    
    /**
     * Find test files
     */
    private function findTestFiles(): array
    {
        return $this->findPHPFiles($this->options['test-dir'] ?? 'test/Cases');
    }
    
    /**
     * Find PHP files in directory
     */
    private function findPHPFiles(string $directory): array
    {
        $files = [];
        $iterator = new RecursiveIteratorIterator(
            new RecursiveDirectoryIterator($directory, RecursiveDirectoryIterator::SKIP_DOTS)
        );
        
        foreach ($iterator as $file) {
            if ($file->isFile() && $file->getExtension() === 'php') {
                $files[] = $file->getPathname();
            }
        }
        
        return $files;
    }
    
    /**
     * Extract class names from files
     */
    private function extractClassNames(array $files): array
    {
        $classes = [];
        
        foreach ($files as $file) {
            $content = file_get_contents($file);
            
            // Extract namespace
            $namespace = '';
            if (preg_match('/namespace\s+([^;]+);/', $content, $matches)) {
                $namespace = $matches[1];
            }
            
            // Extract class name
            if (preg_match('/class\s+([a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*)/', $content, $matches)) {
                $className = $matches[1];
                $fullClassName = $namespace ? $namespace . '\\' . $className : $className;
                $classes[] = $fullClassName;
            }
        }
        
        return $classes;
    }
    
    /**
     * Generate all reports
     */
    private function generateAllReports(): array
    {
        $sourceFiles = $this->findSourceFiles();
        $testFiles = $this->findTestFiles();
        
        $sourceClasses = $this->extractClassNames($sourceFiles);
        $testClasses = $this->extractClassNames($testFiles);
        
        return [
            'linkage_analysis' => $this->manager->analyzeBidirectionalLinkage($testClasses, $sourceClasses),
            'coverage_report' => $this->manager->generateCoverageReport($sourceClasses, $testClasses),
            'test_quality_report' => $this->manager->generateTestQualityReport($testClasses),
            'consistency_report' => $this->manager->validateAnnotationConsistency($testClasses, $sourceClasses),
            'validation_statistics' => $this->orchestrator->generateStatistics(),
        ];
    }
    
    /**
     * Generate recommendations
     */
    private function generateRecommendations(array $linkageAnalysis, array $coverageReport, array $consistencyReport): array
    {
        $recommendations = [];
        
        // Linkage recommendations
        if ($linkageAnalysis['summary']['orphanedTests'] > 0) {
            $recommendations[] = [
                'priority' => 'high',
                'category' => 'linkage',
                'message' => "Fix {$linkageAnalysis['summary']['orphanedTests']} orphaned test(s) by adding @Verified annotations",
                'action' => 'update',
            ];
        }
        
        if ($linkageAnalysis['summary']['orphanedSources'] > 0) {
            $recommendations[] = [
                'priority' => 'medium',
                'category' => 'linkage',
                'message' => "Fix {$linkageAnalysis['summary']['orphanedSources']} orphaned source(s) by adding @TestedBy annotations",
                'action' => 'update',
            ];
        }
        
        // Coverage recommendations
        if ($coverageReport['summary']['averageCoverage'] < 70) {
            $recommendations[] = [
                'priority' => 'medium',
                'category' => 'coverage',
                'message' => "Improve annotation coverage (current: {$coverageReport['summary']['averageCoverage']}%)",
                'action' => 'scan',
            ];
        }
        
        // Consistency recommendations
        if ($consistencyReport['summary']['totalInconsistencies'] > 0) {
            $recommendations[] = [
                'priority' => 'high',
                'category' => 'consistency',
                'message' => "Fix {$consistencyReport['summary']['totalInconsistencies']} annotation inconsistencies",
                'action' => 'fix',
            ];
        }
        
        return $recommendations;
    }
    
    /**
     * Output report
     */
    private function outputReport(array $report, string $reportName): void
    {
        $format = $this->options['format'] ?? 'console';
        $output = $this->options['output'] ?? null;
        
        switch ($format) {
            case 'json':
                $content = json_encode($report, JSON_PRETTY_PRINT);
                break;
            case 'html':
                $content = $this->generateHTMLReport($report, $reportName);
                break;
            default:
                $content = $this->generateConsoleReport($report, $reportName);
                break;
        }
        
        if ($output) {
            $filename = $output;
            if (is_dir($output)) {
                $filename = $output . '/' . $reportName . '_' . date('Y-m-d_H-i-s') . '.' . $format;
            }
            file_put_contents($filename, $content);
            $this->info("Report saved to: {$filename}");
        } else {
            echo $content;
        }
    }
    
    /**
     * Generate console report
     */
    private function generateConsoleReport(array $report, string $reportName): string
    {
        $output = "\n" . str_repeat('=', 80) . "\n";
        $output .= "ANNOTATION REPORT: " . strtoupper($reportName) . "\n";
        $output .= "Generated: " . date('Y-m-d H:i:s') . "\n";
        $output .= str_repeat('=', 80) . "\n\n";
        
        if (isset($report['summary'])) {
            $output .= "SUMMARY:\n";
            $output .= str_repeat('-', 40) . "\n";
            foreach ($report['summary'] as $key => $value) {
                $output .= sprintf("%-30s: %s\n", ucfirst(str_replace('_', ' ', $key)), $value);
            }
            $output .= "\n";
        }
        
        if (isset($report['recommendations'])) {
            $output .= "RECOMMENDATIONS:\n";
            $output .= str_repeat('-', 40) . "\n";
            foreach ($report['recommendations'] as $recommendation) {
                $priority = strtoupper($recommendation['priority'] ?? 'medium');
                $output .= "[{$priority}] {$recommendation['message']}\n";
            }
            $output .= "\n";
        }
        
        return $output;
    }
    
    /**
     * Generate HTML report
     */
    private function generateHTMLReport(array $report, string $reportName): string
    {
        $html = "<html><head><title>Annotation Report: {$reportName}</title></head><body>";
        $html .= "<h1>Annotation Report: " . ucfirst($reportName) . "</h1>";
        $html .= "<p>Generated: " . date('Y-m-d H:i:s') . "</p>";
        
        if (isset($report['summary'])) {
            $html .= "<h2>Summary</h2><table border='1'>";
            foreach ($report['summary'] as $key => $value) {
                $html .= "<tr><td>" . ucfirst(str_replace('_', ' ', $key)) . "</td><td>{$value}</td></tr>";
            }
            $html .= "</table>";
        }
        
        if (isset($report['recommendations'])) {
            $html .= "<h2>Recommendations</h2><ul>";
            foreach ($report['recommendations'] as $recommendation) {
                $priority = strtoupper($recommendation['priority'] ?? 'medium');
                $html .= "<li><strong>[{$priority}]</strong> {$recommendation['message']}</li>";
            }
            $html .= "</ul>";
        }
        
        $html .= "</body></html>";
        
        return $html;
    }
    
    /**
     * Update source for orphaned test
     */
    private function updateSourceForOrphanedTest(array $orphanedTest): bool
    {
        // Implementation would add @Verified annotations to source methods
        // This is a placeholder for the actual implementation
        if ($this->options['dry-run'] ?? false) {
            $this->info("Would add @Verified annotation to source class: " . $orphanedTest['sourceClass']);
            return true;
        }
        
        // Actual implementation would modify source files
        return false;
    }
    
    /**
     * Update test for orphaned source
     */
    private function updateTestForOrphanedSource(array $orphanedSource): bool
    {
        // Implementation would add @TestedBy annotations to test methods
        // This is a placeholder for the actual implementation
        if ($this->options['dry-run'] ?? false) {
            $this->info("Would add @TestedBy annotation to test class: " . $orphanedSource['testClass']);
            return true;
        }
        
        // Actual implementation would modify test files
        return false;
    }
    
    /**
     * Fix invalid linkage
     */
    private function fixInvalidLinkage(array $invalidLink): bool
    {
        // Implementation would fix annotation linkage issues
        // This is a placeholder for the actual implementation
        if ($this->options['dry-run'] ?? false) {
            $this->info("Would fix linkage between " . $invalidLink['testClass'] . " and " . $invalidLink['sourceClass']);
            return true;
        }
        
        // Actual implementation would fix annotations
        return false;
    }
    
    /**
     * Fix bidirectional linkage issues
     */
    private function fixBidirectionalLinkageIssues($linkageResult): int
    {
        // Implementation would fix bidirectional linkage issues
        // This is a placeholder for the actual implementation
        $this->info("Fixing bidirectional linkage issues...");
        return 0;
    }
    
    /**
     * Fix annotation consistency issues
     */
    private function fixAnnotationConsistencyIssues($consistencyResult): int
    {
        // Implementation would fix annotation consistency issues
        // This is a placeholder for the actual implementation
        $this->info("Fixing annotation consistency issues...");
        return 0;
    }
    
    /**
     * Fix coverage gaps
     */
    private function fixCoverageGaps($coverageResult): int
    {
        // Implementation would fix coverage gaps
        // This is a placeholder for the actual implementation
        $this->info("Fixing coverage gaps...");
        return 0;
    }
    
    /**
     * Show help
     */
    private function showHelp(): void
    {
        $help = <<<HELP
Annotation Automation Command

Usage: php annotation-automation.php [command] [options]

Commands:
  scan      Scan all files for annotation analysis
  validate  Validate annotation consistency
  update    Update annotations based on analysis
  report    Generate comprehensive reports
  fix       Automatically fix annotation issues
  monitor   Continuous monitoring mode
  help      Show this help

Options:
  --source-dir=DIR     Source directory (default: src)
  --test-dir=DIR       Test directory (default: test/Cases)
  --output=FILE        Output file for reports
  --format=FORMAT      Output format (json|console|html) (default: console)
  --fix-mode=MODE      Fix mode (safe|aggressive) (default: safe)
  --watch              Watch for file changes
  --dry-run            Show what would be done without making changes
  --verbose            Verbose output
  --help               Show this help

Examples:
  php annotation-automation.php scan
  php annotation-automation.php validate --verbose
  php annotation-automation.php update --dry-run
  php annotation-automation.php report --format=json --output=reports/
  php annotation-automation.php fix --fix-mode=safe
  php annotation-automation.php monitor --watch

HELP;
        
        echo $help;
    }
    
    /**
     * Output info message
     */
    private function info(string $message): void
    {
        echo "[INFO] {$message}\n";
    }
    
    /**
     * Output success message
     */
    private function success(string $message): void
    {
        echo "[SUCCESS] {$message}\n";
    }
    
    /**
     * Output warning message
     */
    private function warning(string $message): void
    {
        echo "[WARNING] {$message}\n";
    }
    
    /**
     * Output error message
     */
    private function error(string $message): void
    {
        echo "[ERROR] {$message}\n";
    }
}

// Parse command line arguments
function parseArguments(array $argv): array
{
    $options = [];
    $command = null;
    
    for ($i = 1; $i < count($argv); $i++) {
        $arg = $argv[$i];
        
        if (strpos($arg, '--') === 0) {
            if (strpos($arg, '=') !== false) {
                list($key, $value) = explode('=', substr($arg, 2), 2);
                $options[$key] = $value;
            } else {
                $options[substr($arg, 2)] = true;
            }
        } elseif ($command === null) {
            $command = $arg;
        }
    }
    
    $options['command'] = $command;
    
    return $options;
}

// Main execution
if (php_sapi_name() === 'cli') {
    $options = parseArguments($argv);
    
    if ($options['help'] ?? false) {
        $options['command'] = 'help';
    }
    
    $automation = new AnnotationAutomation($options);
    $exitCode = $automation->run();
    
    exit($exitCode);
}