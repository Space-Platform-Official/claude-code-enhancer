<?php

/**
 * Annotation Validator Integration Script
 * 
 * Provides integration with existing validation tools and CI/CD pipelines
 * for annotation consistency checking and reporting.
 */

declare(strict_types=1);

require_once __DIR__ . '/../../vendor/autoload.php';

use SpacePlatform\Utils\Annotation\Tools\ValidationOrchestrator;
use SpacePlatform\Utils\Annotation\Validation\AnnotationManager;

/**
 * Annotation validator integration class
 */
class AnnotationValidatorIntegration
{
    private ValidationOrchestrator $orchestrator;
    private AnnotationManager $manager;
    private array $config;
    
    public function __construct(array $config = [])
    {
        $this->config = array_merge($this->getDefaultConfig(), $config);
        $this->orchestrator = new ValidationOrchestrator(
            $this->config['source_directory'],
            $this->config['test_directory'],
            $this->config['output_format']
        );
        $this->manager = new AnnotationManager();
    }
    
    /**
     * Validate for CI/CD integration
     */
    public function validateForCI(): array
    {
        $result = $this->orchestrator->runComprehensiveValidation();
        
        $ciResult = [
            'success' => $result->isSuccess(),
            'exit_code' => $result->isSuccess() ? 0 : 1,
            'timestamp' => date('c'),
            'config' => $this->config,
        ];
        
        if ($result->isSuccess()) {
            $ciResult['message'] = 'All annotation validations passed';
            $ciResult['data'] = $result->getValue();
        } else {
            $ciResult['message'] = 'Annotation validation failed: ' . $result->getErrorMessage();
            $ciResult['errors'] = $result->getValue();
        }
        
        return $ciResult;
    }
    
    /**
     * Validate specific files (for git hooks)
     */
    public function validateFiles(array $files): array
    {
        $result = $this->orchestrator->validateFiles($files);
        
        return [
            'success' => $result->isSuccess(),
            'exit_code' => $result->isSuccess() ? 0 : 1,
            'files_validated' => count($files),
            'timestamp' => date('c'),
            'message' => $result->isSuccess() 
                ? 'All files passed annotation validation'
                : 'File validation failed: ' . $result->getErrorMessage(),
            'data' => $result->getValue(),
        ];
    }
    
    /**
     * Generate validation report for external tools
     */
    public function generateExternalReport(string $format = 'json'): string
    {
        $result = $this->orchestrator->runComprehensiveValidation();
        $statistics = $this->orchestrator->generateStatistics();
        
        $report = [
            'tool' => 'annotation-validator',
            'version' => '1.0.0',
            'timestamp' => date('c'),
            'success' => $result->isSuccess(),
            'statistics' => $statistics,
            'validation_result' => $result->getValue(),
        ];
        
        switch ($format) {
            case 'junit':
                return $this->generateJUnitXML($report);
            case 'sarif':
                return $this->generateSARIF($report);
            case 'checkstyle':
                return $this->generateCheckstyleXML($report);
            default:
                return json_encode($report, JSON_PRETTY_PRINT);
        }
    }
    
    /**
     * Quick validation for pre-commit hooks
     */
    public function quickValidation(): bool
    {
        $result = $this->orchestrator->runQuickValidation();
        return $result->isSuccess();
    }
    
    /**
     * Get validation metrics
     */
    public function getMetrics(): array
    {
        $statistics = $this->orchestrator->generateStatistics();
        $result = $this->orchestrator->runComprehensiveValidation();
        
        return [
            'coverage_metrics' => $statistics['coverage_statistics'] ?? [],
            'file_counts' => $statistics['file_counts'] ?? [],
            'validation_success' => $result->isSuccess(),
            'validation_details' => $result->getValue(),
        ];
    }
    
    /**
     * Generate JUnit XML format
     */
    private function generateJUnitXML(array $report): string
    {
        $xml = new DOMDocument('1.0', 'UTF-8');
        $xml->formatOutput = true;
        
        $testsuite = $xml->createElement('testsuite');
        $testsuite->setAttribute('name', 'annotation-validation');
        $testsuite->setAttribute('tests', '1');
        $testsuite->setAttribute('failures', $report['success'] ? '0' : '1');
        $testsuite->setAttribute('time', '0');
        
        $testcase = $xml->createElement('testcase');
        $testcase->setAttribute('name', 'annotation-consistency');
        $testcase->setAttribute('classname', 'AnnotationValidator');
        
        if (!$report['success']) {
            $failure = $xml->createElement('failure');
            $failure->setAttribute('message', 'Annotation validation failed');
            $failure->textContent = json_encode($report['validation_result'], JSON_PRETTY_PRINT);
            $testcase->appendChild($failure);
        }
        
        $testsuite->appendChild($testcase);
        $xml->appendChild($testsuite);
        
        return $xml->saveXML();
    }
    
    /**
     * Generate SARIF format
     */
    private function generateSARIF(array $report): string
    {
        $sarif = [
            'version' => '2.1.0',
            'runs' => [
                [
                    'tool' => [
                        'driver' => [
                            'name' => 'annotation-validator',
                            'version' => '1.0.0',
                        ],
                    ],
                    'results' => [],
                ],
            ],
        ];
        
        if (!$report['success']) {
            $sarif['runs'][0]['results'][] = [
                'ruleId' => 'annotation-consistency',
                'message' => [
                    'text' => 'Annotation validation failed',
                ],
                'level' => 'error',
                'locations' => [
                    [
                        'physicalLocation' => [
                            'artifactLocation' => [
                                'uri' => 'annotations',
                            ],
                        ],
                    ],
                ],
            ];
        }
        
        return json_encode($sarif, JSON_PRETTY_PRINT);
    }
    
    /**
     * Generate Checkstyle XML format
     */
    private function generateCheckstyleXML(array $report): string
    {
        $xml = new DOMDocument('1.0', 'UTF-8');
        $xml->formatOutput = true;
        
        $checkstyle = $xml->createElement('checkstyle');
        $checkstyle->setAttribute('version', '1.0.0');
        
        $file = $xml->createElement('file');
        $file->setAttribute('name', 'annotations');
        
        if (!$report['success']) {
            $error = $xml->createElement('error');
            $error->setAttribute('line', '1');
            $error->setAttribute('severity', 'error');
            $error->setAttribute('message', 'Annotation validation failed');
            $error->setAttribute('source', 'annotation-validator');
            $file->appendChild($error);
        }
        
        $checkstyle->appendChild($file);
        $xml->appendChild($checkstyle);
        
        return $xml->saveXML();
    }
    
    /**
     * Get default configuration
     */
    private function getDefaultConfig(): array
    {
        return [
            'source_directory' => 'src',
            'test_directory' => 'test/Cases',
            'output_format' => 'console',
            'strict_mode' => false,
        ];
    }
}

// CLI interface
if (php_sapi_name() === 'cli') {
    $options = getopt('', [
        'ci',
        'files:',
        'format:',
        'quick',
        'metrics',
        'help',
    ]);
    
    if (isset($options['help'])) {
        echo "Annotation Validator Integration\n\n";
        echo "Usage: php annotation-validator.php [options]\n\n";
        echo "Options:\n";
        echo "  --ci             Run CI/CD validation\n";
        echo "  --files=FILES    Validate specific files (comma-separated)\n";
        echo "  --format=FORMAT  Output format (json|junit|sarif|checkstyle)\n";
        echo "  --quick          Quick validation only\n";
        echo "  --metrics        Get validation metrics\n";
        echo "  --help           Show this help\n\n";
        exit(0);
    }
    
    $validator = new AnnotationValidatorIntegration();
    
    try {
        if (isset($options['ci'])) {
            $result = $validator->validateForCI();
            echo json_encode($result, JSON_PRETTY_PRINT) . "\n";
            exit($result['exit_code']);
        }
        
        if (isset($options['files'])) {
            $files = explode(',', $options['files']);
            $result = $validator->validateFiles($files);
            echo json_encode($result, JSON_PRETTY_PRINT) . "\n";
            exit($result['exit_code']);
        }
        
        if (isset($options['quick'])) {
            $success = $validator->quickValidation();
            echo json_encode(['success' => $success]) . "\n";
            exit($success ? 0 : 1);
        }
        
        if (isset($options['metrics'])) {
            $metrics = $validator->getMetrics();
            echo json_encode($metrics, JSON_PRETTY_PRINT) . "\n";
            exit(0);
        }
        
        // Default: generate report
        $format = $options['format'] ?? 'json';
        $report = $validator->generateExternalReport($format);
        echo $report . "\n";
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'error' => $e->getMessage(),
            'exit_code' => 1,
        ], JSON_PRETTY_PRINT) . "\n";
        exit(1);
    }
}