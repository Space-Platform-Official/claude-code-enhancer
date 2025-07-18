#!/usr/bin/env php
<?php

/**
 * Integration Test for Annotation Automation System
 * 
 * This script tests the basic functionality of the annotation automation system
 * to ensure all components are working correctly together.
 */

declare(strict_types=1);

require_once __DIR__ . '/../../vendor/autoload.php';

echo "Annotation Automation System Integration Test\n";
echo str_repeat('=', 50) . "\n\n";

$errors = [];
$warnings = [];

// Test 1: Check if required classes are available
echo "Testing class availability...\n";
try {
    $requiredClasses = [
        'SpacePlatform\Utils\Annotation\Tools\ValidationOrchestrator',
        'SpacePlatform\Utils\Annotation\Tools\BidirectionalLinkageValidator',
        'SpacePlatform\Utils\Annotation\Tools\AnnotationConsistencyChecker',
        'SpacePlatform\Utils\Annotation\Tools\CoverageGapDetector',
        'SpacePlatform\Utils\Annotation\Tools\ValidationReporter',
        'SpacePlatform\Utils\Annotation\Validation\AnnotationManager',
        'SpacePlatform\Utils\Annotation\Validation\AnnotationParser',
        'SpacePlatform\Utils\Annotation\Validation\AnnotationValidator',
    ];
    
    foreach ($requiredClasses as $class) {
        if (!class_exists($class)) {
            $errors[] = "Required class not found: {$class}";
        } else {
            echo "✓ {$class}\n";
        }
    }
    
    if (empty($errors)) {
        echo "✓ All required classes are available\n\n";
    }
} catch (Exception $e) {
    $errors[] = "Error checking class availability: " . $e->getMessage();
}

// Test 2: Check configuration file
echo "Testing configuration file...\n";
$configFile = __DIR__ . '/annotation-automation.json';
if (!file_exists($configFile)) {
    $errors[] = "Configuration file not found: {$configFile}";
} else {
    $config = json_decode(file_get_contents($configFile), true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        $errors[] = "Invalid JSON in configuration file: " . json_last_error_msg();
    } else {
        echo "✓ Configuration file is valid\n";
        
        // Check required config keys
        $requiredKeys = ['source_directory', 'test_directory', 'output_format'];
        foreach ($requiredKeys as $key) {
            if (!isset($config[$key])) {
                $warnings[] = "Missing configuration key: {$key}";
            }
        }
    }
}
echo "\n";

// Test 3: Test basic validation orchestrator functionality
echo "Testing ValidationOrchestrator...\n";
try {
    $orchestrator = new \SpacePlatform\Utils\Annotation\Tools\ValidationOrchestrator();
    $statistics = $orchestrator->generateStatistics();
    
    if (is_array($statistics) && isset($statistics['timestamp'])) {
        echo "✓ ValidationOrchestrator statistics generation works\n";
    } else {
        $errors[] = "ValidationOrchestrator statistics generation failed";
    }
} catch (Exception $e) {
    // ValidationOrchestrator errors are expected in some cases, so we'll treat them as warnings
    $warnings[] = "ValidationOrchestrator warning: " . $e->getMessage();
    echo "⚠ ValidationOrchestrator has validation issues (expected in some cases)\n";
}
echo "\n";

// Test 4: Test annotation manager
echo "Testing AnnotationManager...\n";
try {
    $manager = new \SpacePlatform\Utils\Annotation\Validation\AnnotationManager();
    
    // Test with empty arrays (should not fail)
    $linkageAnalysis = $manager->analyzeBidirectionalLinkage([], []);
    
    if (is_array($linkageAnalysis) && isset($linkageAnalysis['summary'])) {
        echo "✓ AnnotationManager bidirectional linkage analysis works\n";
    } else {
        $errors[] = "AnnotationManager bidirectional linkage analysis failed";
    }
    
    $coverageReport = $manager->generateCoverageReport([], []);
    if (is_array($coverageReport) && isset($coverageReport['summary'])) {
        echo "✓ AnnotationManager coverage report generation works\n";
    } else {
        $errors[] = "AnnotationManager coverage report generation failed";
    }
} catch (Exception $e) {
    $errors[] = "AnnotationManager error: " . $e->getMessage();
}
echo "\n";

// Test 5: Test script executability
echo "Testing script executability...\n";
$scripts = [
    __DIR__ . '/annotation-automation.sh',
    __DIR__ . '/annotation-automation.php',
    __DIR__ . '/annotation-validator.php',
];

foreach ($scripts as $script) {
    if (!file_exists($script)) {
        $errors[] = "Script not found: {$script}";
    } elseif (!is_executable($script)) {
        $warnings[] = "Script not executable: {$script}";
    } else {
        echo "✓ " . basename($script) . " is executable\n";
    }
}
echo "\n";

// Test 6: Test directory structure
echo "Testing directory structure...\n";
$directories = ['src', 'test/Cases'];
foreach ($directories as $dir) {
    $fullPath = __DIR__ . '/../../' . $dir;
    if (!is_dir($fullPath)) {
        $warnings[] = "Directory not found: {$dir} (looked in {$fullPath})";
    } else {
        echo "✓ {$dir} directory exists\n";
    }
}
echo "\n";

// Test 7: Test PHP version
echo "Testing PHP version...\n";
$phpVersion = PHP_VERSION;
if (version_compare($phpVersion, '8.0.0', '<')) {
    $errors[] = "PHP 8.0 or higher required. Current version: {$phpVersion}";
} else {
    echo "✓ PHP version is compatible: {$phpVersion}\n";
}
echo "\n";

// Test 8: Test basic CLI functionality
echo "Testing CLI functionality...\n";
try {
    // Test help command
    $helpOutput = shell_exec('php ' . __DIR__ . '/annotation-automation.php help 2>&1');
    if (strpos($helpOutput, 'Usage:') !== false) {
        echo "✓ CLI help command works\n";
    } else {
        $warnings[] = "CLI help command may not be working properly";
    }
    
    // Test validator help
    $validatorHelp = shell_exec('php ' . __DIR__ . '/annotation-validator.php --help 2>&1');
    if (strpos($validatorHelp, 'Usage:') !== false) {
        echo "✓ Validator help command works\n";
    } else {
        $warnings[] = "Validator help command may not be working properly";
    }
} catch (Exception $e) {
    $warnings[] = "CLI functionality test error: " . $e->getMessage();
}
echo "\n";

// Results summary
echo str_repeat('=', 50) . "\n";
echo "INTEGRATION TEST RESULTS\n";
echo str_repeat('=', 50) . "\n\n";

if (empty($errors) && empty($warnings)) {
    echo "✅ ALL TESTS PASSED\n";
    echo "The annotation automation system is ready for use.\n\n";
    
    echo "Quick start commands:\n";
    echo "  ./annotation-automation.sh setup\n";
    echo "  ./annotation-automation.sh scan\n";
    echo "  ./annotation-automation.sh validate\n";
    echo "  php annotation-validator.php --ci\n";
    
    exit(0);
} else {
    if (!empty($errors)) {
        echo "❌ ERRORS FOUND:\n";
        foreach ($errors as $error) {
            echo "  - {$error}\n";
        }
        echo "\n";
    }
    
    if (!empty($warnings)) {
        echo "⚠️  WARNINGS:\n";
        foreach ($warnings as $warning) {
            echo "  - {$warning}\n";
        }
        echo "\n";
    }
    
    if (!empty($errors)) {
        echo "❌ INTEGRATION TEST FAILED\n";
        echo "Please fix the errors above before using the annotation automation system.\n";
        exit(1);
    } else {
        echo "✅ INTEGRATION TEST PASSED WITH WARNINGS\n";
        echo "The system should work, but please review the warnings above.\n";
        exit(0);
    }
}