---
allowed-tools: all
description: PHP annotation validation with comprehensive bidirectional linkage analysis and automated fixing
intensity: ⚡⚡⚡
pattern: 📝📝📝
---

# 📝📝📝 CRITICAL ANNOTATION VALIDATION: COMPREHENSIVE BIDIRECTIONAL LINKAGE ANALYSIS! 📝📝📝

**THIS IS NOT A SIMPLE ANNOTATION CHECK - THIS IS A COMPREHENSIVE ANNOTATION VALIDATION SYSTEM!**

When you run `/test annotation`, you are REQUIRED to:

1. **SCAN** all source methods and test methods for @Verified and @TestedBy annotations
2. **VALIDATE** bidirectional method-to-test-case linkage at the method level
3. **VERIFY** that source methods have @Verified annotations pointing to specific test methods
4. **ENSURE** that test methods have @TestedBy annotations pointing to specific source methods
5. **FIX** annotation issues automatically with safe mode validation
6. **REPORT** comprehensive validation results with actionable recommendations
7. **USE MULTIPLE AGENTS** for parallel annotation processing:
   - Spawn one agent for source file annotation scanning
   - Spawn another for test file annotation validation
   - Spawn agents for different validation types (linkage, consistency, coverage)
   - Say: "I'll spawn multiple agents to validate annotations comprehensively across all files"

**FORBIDDEN BEHAVIORS:**
- ❌ "Basic annotation check" → NO! Use comprehensive method-level bidirectional validation!
- ❌ "Class-level annotation validation" → NO! Must validate at method level!
- ❌ "Skip method-to-test-case mapping" → NO! Method-level linkage analysis required!
- ❌ "Ignore orphaned methods" → NO! All methods must have corresponding test annotations!
- ❌ "Single-threaded validation" → NO! Use parallel agent coordination!
- ❌ "Generic annotation output" → NO! Method-specific parsing and reporting!

**MANDATORY WORKFLOW:**
```
1. PHP annotation system detection → Identify annotation-automation.php
2. IMMEDIATELY spawn agents for parallel method-level validation
3. Method discovery → Find all public methods in source classes
4. Annotation discovery → Find all @Verified and @TestedBy annotations at method level
5. Parallel validation → Run method-to-test-case linkage validation across multiple agents
6. Bidirectional linkage analysis → Validate method-level consistency
7. VERIFY results → Ensure all methods have valid test linkages and coverage complete
```

**YOU ARE NOT DONE UNTIL:**
- ✅ All public methods discovered and scanned for annotations
- ✅ Method-level bidirectional linkage analyzed with gap identification
- ✅ All source methods have @Verified annotations pointing to specific test methods
- ✅ All test methods have @TestedBy annotations pointing to specific source methods
- ✅ Orphaned methods identified and reported
- ✅ Invalid method-to-test-case mappings analyzed with root cause identification
- ✅ Method-level coverage metrics collected and reported
- ✅ Actionable recommendations provided for method annotation improvements

---

🛑 **MANDATORY ANNOTATION VALIDATION PROTOCOL** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check PHP annotation system configuration
3. Verify annotation-automation.php accessibility

Execute comprehensive annotation validation with ZERO tolerance for incomplete linkage analysis.

**FORBIDDEN SHORTCUT PATTERNS:**
- "Basic annotation scan is sufficient" → NO, comprehensive validation required
- "Skip slow validation for speed" → NO, all annotations must be validated
- "Linkage reports are optional" → NO, mandatory linkage analysis
- "Manual annotation analysis is fine" → NO, automated analysis required
- "Single agent validation is faster" → NO, parallel validation mandatory

You are validating annotations for: $ARGUMENTS

Let me ultrathink about comprehensive annotation validation with parallel agent coordination.

🚨 **REMEMBER: Annotations are the foundation of test-source linkage reliability!** 🚨

**Comprehensive Annotation Validation Protocol:**

**Step 0: PHP Annotation System Detection**
- Detect annotation-automation.php system in /test/test/
- Validate PHP environment and dependencies
- Check annotation-automation.json configuration
- Verify annotation infrastructure accessibility
- Setup annotation validation environment

**Step 1: Annotation Discovery and Categorization**

**PHP Annotation Detection:**
```bash
# Detect PHP annotation system
detect_php_annotations() {
    local project_dir=${1:-.}
    local annotation_script="$project_dir/test/test/annotation-automation.php"
    
    if [ -f "$annotation_script" ]; then
        echo "system:php script:$annotation_script config:$project_dir/test/test/annotation-automation.json"
    else
        echo "ERROR: PHP annotation system not found"
        return 1
    fi
}

# Get annotation configuration
get_annotation_config() {
    local project_dir=${1:-.}
    local config_file="$project_dir/test/test/annotation-automation.json"
    
    if [ -f "$config_file" ]; then
        echo "config_file:$config_file"
        echo "source_dir:$(php -r "echo json_decode(file_get_contents('$config_file'), true)['source_directory'] ?? 'src';")"
        echo "test_dir:$(php -r "echo json_decode(file_get_contents('$config_file'), true)['test_directory'] ?? 'test/Cases';")"
    else
        echo "config_file: source_dir:src test_dir:test/Cases"
    fi
}

# Discover annotation files
find_annotation_files() {
    local project_dir=${1:-.}
    local annotation_config=$(get_annotation_config "$project_dir")
    local source_dir=$(echo "$annotation_config" | grep "source_dir:" | cut -d: -f2)
    local test_dir=$(echo "$annotation_config" | grep "test_dir:" | cut -d: -f2)
    
    echo "=== Annotation File Discovery ==="
    echo "Source directory: $source_dir"
    echo "Test directory: $test_dir"
    echo ""
    
    # Find PHP files with annotations
    local source_files=$(find "$project_dir/$source_dir" -name "*.php" -type f 2>/dev/null | head -20)
    local test_files=$(find "$project_dir/$test_dir" -name "*.php" -type f 2>/dev/null | head -20)
    
    echo "Source files found: $(echo "$source_files" | wc -l)"
    echo "Test files found: $(echo "$test_files" | wc -l)"
    
    echo "$source_files"
    echo "$test_files"
}
```

**Step 2: Multi-Agent Annotation Validation Strategy**

**Agent Spawning Strategy for Method-Level Annotation Validation:**
```
"I'll spawn multiple agents to validate method-level annotations comprehensively:
- Source Method Agent: Analyze source methods for @Verified annotations linking to test methods
- Test Method Agent: Analyze test methods for @TestedBy annotations linking to source methods
- Linkage Agent: Validate bidirectional method-to-test-case linkage
- Coverage Agent: Identify methods without corresponding test annotations
- Fix Agent: Automatically add missing method-level annotations with safe mode
- Report Agent: Generate comprehensive method-level validation reports and metrics"
```

**Method-Level Annotation Patterns:**

**Source Method Annotation Example:**
```php
class UserService {
    /**
     * @Verified(by="UserServiceTest::testCreateUser")
     * @param array $userData
     * @return User
     */
    public function createUser(array $userData): User {
        // Implementation
    }
    
    /**
     * @Verified(by="UserServiceTest::testUpdateUser")
     * @param int $userId
     * @param array $updates
     * @return User
     */
    public function updateUser(int $userId, array $updates): User {
        // Implementation
    }
}
```

**Test Method Annotation Example:**
```php
class UserServiceTest extends TestCase {
    /**
     * @TestedBy(method="UserService::createUser")
     * @covers UserService::createUser
     */
    public function testCreateUser(): void {
        // Test implementation
    }
    
    /**
     * @TestedBy(method="UserService::updateUser")
     * @covers UserService::updateUser
     */
    public function testUpdateUser(): void {
        // Test implementation
    }
}
```

**Step 3: Parallel Annotation Validation**

**PHP Annotation System Execution:**
```bash
# Execute annotation validation with PHP system
execute_annotation_validation() {
    local mode=$1
    local project_dir=${2:-.}
    local format=${3:-"console"}
    local annotation_script="$project_dir/test/test/annotation-automation.php"
    
    if [ ! -f "$annotation_script" ]; then
        echo "ERROR: PHP annotation system not found at $annotation_script"
        return 1
    fi
    
    case "$mode" in
        "scan")
            # Comprehensive annotation scanning
            php "$annotation_script" scan --format="$format" --verbose
            ;;
        "validate")
            # Bidirectional validation
            php "$annotation_script" validate --format="$format" --verbose
            ;;
        "fix")
            # Safe mode fixes
            php "$annotation_script" fix --fix-mode=safe --dry-run
            echo "=== Dry Run Complete - Review Changes Above ==="
            echo "Run with --execute to apply changes"
            ;;
        "report")
            # Comprehensive reporting
            php "$annotation_script" report --format="$format"
            ;;
        "monitor")
            # Continuous monitoring
            php "$annotation_script" monitor --watch
            ;;
        *)
            echo "ERROR: Invalid annotation mode: $mode"
            return 1
            ;;
    esac
}

# Execute annotation validation using shell wrapper
execute_annotation_shell() {
    local mode=$1
    local project_dir=${2:-.}
    local format=${3:-"console"}
    local annotation_shell="$project_dir/test/test/annotation-automation.sh"
    
    if [ ! -f "$annotation_shell" ]; then
        echo "ERROR: Annotation shell script not found at $annotation_shell"
        return 1
    fi
    
    case "$mode" in
        "scan")
            "$annotation_shell" scan --format="$format"
            ;;
        "validate")
            "$annotation_shell" validate --verbose
            ;;
        "fix")
            "$annotation_shell" fix --fix-mode=safe --dry-run
            ;;
        "report")
            "$annotation_shell" report --format="$format"
            ;;
        "monitor")
            "$annotation_shell" monitor --watch
            ;;
        *)
            echo "ERROR: Invalid annotation mode: $mode"
            return 1
            ;;
    esac
}

# Monitor annotation validation progress
monitor_annotation_progress() {
    local total_files=$1
    local completed_files=0
    
    while [ $completed_files -lt $total_files ]; do
        echo "Progress: $completed_files/$total_files files validated"
        sleep 1
        completed_files=$((completed_files + 1))
    done
}
```

**Step 4: Bidirectional Linkage Analysis**

**Linkage Analysis Tools:**
```bash
# Validate method-level bidirectional linkage
validate_method_annotation_linkage() {
    local project_dir=${1:-.}
    local annotation_script="$project_dir/test/test/annotation-automation.php"
    
    echo "=== Method-Level Bidirectional Linkage Analysis ==="
    echo ""
    
    # Run method-level linkage validation
    php "$annotation_script" validate --format=json > /tmp/annotation-results.json
    
    # Parse method-level results
    if [ -f "/tmp/annotation-results.json" ]; then
        echo "Method-level linkage validation results:"
        php -r "
        \$results = json_decode(file_get_contents('/tmp/annotation-results.json'), true);
        if (isset(\$results['method_linkage_analysis'])) {
            \$linkage = \$results['method_linkage_analysis'];
            echo 'Total Source Methods: ' . (\$linkage['summary']['totalSourceMethods'] ?? 0) . PHP_EOL;
            echo 'Methods with @Verified: ' . (\$linkage['summary']['methodsWithVerified'] ?? 0) . PHP_EOL;
            echo 'Total Test Methods: ' . (\$linkage['summary']['totalTestMethods'] ?? 0) . PHP_EOL;
            echo 'Methods with @TestedBy: ' . (\$linkage['summary']['methodsWithTestedBy'] ?? 0) . PHP_EOL;
            echo 'Valid Method Links: ' . (\$linkage['summary']['validMethodLinks'] ?? 0) . PHP_EOL;
            echo 'Invalid Method Links: ' . (\$linkage['summary']['invalidMethodLinks'] ?? 0) . PHP_EOL;
            echo 'Orphaned Source Methods: ' . (\$linkage['summary']['orphanedSourceMethods'] ?? 0) . PHP_EOL;
            echo 'Orphaned Test Methods: ' . (\$linkage['summary']['orphanedTestMethods'] ?? 0) . PHP_EOL;
        }
        "
    fi
}

# Discover all public methods in source classes
discover_source_methods() {
    local project_dir=${1:-.}
    local annotation_config=$(get_annotation_config "$project_dir")
    local source_dir=$(echo "$annotation_config" | grep "source_dir:" | cut -d: -f2)
    
    echo "=== Source Method Discovery ==="
    echo ""
    
    # Find all public methods in PHP source files
    find "$project_dir/$source_dir" -name "*.php" -type f | while read -r file; do
        echo "Scanning: $file"
        # Extract public methods using PHP parsing
        php -r "
        \$content = file_get_contents('$file');
        if (preg_match_all('/public\s+function\s+(\w+)\s*\(/', \$content, \$matches)) {
            foreach (\$matches[1] as \$method) {
                echo '  Method: ' . \$method . PHP_EOL;
                // Check for @Verified annotation
                if (preg_match('/@Verified\s*\(\s*by\s*=\s*[\"\'](.*?)[\"\']\s*\)/', \$content, \$verifiedMatch)) {
                    echo '    @Verified: ' . \$verifiedMatch[1] . PHP_EOL;
                } else {
                    echo '    @Verified: MISSING' . PHP_EOL;
                }
            }
        }
        "
    done
}

# Discover all test methods in test classes
discover_test_methods() {
    local project_dir=${1:-.}
    local annotation_config=$(get_annotation_config "$project_dir")
    local test_dir=$(echo "$annotation_config" | grep "test_dir:" | cut -d: -f2)
    
    echo "=== Test Method Discovery ==="
    echo ""
    
    # Find all test methods in PHP test files
    find "$project_dir/$test_dir" -name "*.php" -type f | while read -r file; do
        echo "Scanning: $file"
        # Extract test methods using PHP parsing
        php -r "
        \$content = file_get_contents('$file');
        if (preg_match_all('/public\s+function\s+(test\w+)\s*\(/', \$content, \$matches)) {
            foreach (\$matches[1] as \$method) {
                echo '  Test Method: ' . \$method . PHP_EOL;
                // Check for @TestedBy annotation
                if (preg_match('/@TestedBy\s*\(\s*method\s*=\s*[\"\'](.*?)[\"\']\s*\)/', \$content, \$testedByMatch)) {
                    echo '    @TestedBy: ' . \$testedByMatch[1] . PHP_EOL;
                } else {
                    echo '    @TestedBy: MISSING' . PHP_EOL;
                }
            }
        }
        "
    done
}

# Identify annotation gaps
identify_annotation_gaps() {
    local project_dir=${1:-.}
    local annotation_script="$project_dir/test/test/annotation-automation.php"
    
    echo "=== Annotation Coverage Gap Analysis ==="
    echo ""
    
    # Run coverage analysis
    php "$annotation_script" scan --format=json > /tmp/annotation-coverage.json
    
    # Parse coverage gaps
    if [ -f "/tmp/annotation-coverage.json" ]; then
        echo "Coverage gap analysis:"
        php -r "
        \$results = json_decode(file_get_contents('/tmp/annotation-coverage.json'), true);
        if (isset(\$results['coverage_gaps'])) {
            \$gaps = \$results['coverage_gaps'];
            echo 'Files without annotations: ' . count(\$gaps['missing_annotations'] ?? []) . PHP_EOL;
            echo 'Broken linkages: ' . count(\$gaps['broken_linkages'] ?? []) . PHP_EOL;
            echo 'Orphaned files: ' . count(\$gaps['orphaned_files'] ?? []) . PHP_EOL;
        }
        "
    fi
}
```

**Step 5: Annotation Quality Validation**

**Annotation Quality Metrics:**
```bash
# Validate annotation quality
validate_annotation_quality() {
    local project_dir=${1:-.}
    local annotation_script="$project_dir/test/test/annotation-automation.php"
    local quality_issues=0
    
    echo "=== Annotation Quality Validation ==="
    echo ""
    
    # Run quality validation
    php "$annotation_script" validate --format=json > /tmp/annotation-quality.json
    
    # Parse quality metrics
    if [ -f "/tmp/annotation-quality.json" ]; then
        echo "Quality validation results:"
        php -r "
        \$results = json_decode(file_get_contents('/tmp/annotation-quality.json'), true);
        if (isset(\$results['quality_metrics'])) {
            \$quality = \$results['quality_metrics'];
            echo 'Total annotations: ' . (\$quality['total_annotations'] ?? 0) . PHP_EOL;
            echo 'Valid annotations: ' . (\$quality['valid_annotations'] ?? 0) . PHP_EOL;
            echo 'Invalid annotations: ' . (\$quality['invalid_annotations'] ?? 0) . PHP_EOL;
            echo 'Coverage percentage: ' . (\$quality['coverage_percentage'] ?? 0) . '%' . PHP_EOL;
        }
        "
    fi
}

# Generate annotation quality report
generate_annotation_report() {
    local project_dir=${1:-.}
    local format=${2:-"console"}
    local annotation_script="$project_dir/test/test/annotation-automation.php"
    
    echo "=== Annotation Quality Report ==="
    echo "Project Directory: $project_dir"
    echo "Report Format: $format"
    echo ""
    
    # Generate comprehensive report
    php "$annotation_script" report --format="$format"
    
    # Additional metrics
    echo ""
    echo "=== Additional Metrics ==="
    validate_annotation_linkage "$project_dir"
    identify_annotation_gaps "$project_dir"
    validate_annotation_quality "$project_dir"
}
```

**Step 6: Automated Annotation Fixing**

**Annotation Fixing Tools:**
```bash
# Fix annotation issues automatically
fix_annotation_issues() {
    local project_dir=${1:-.}
    local fix_mode=${2:-"safe"}
    local dry_run=${3:-"true"}
    local annotation_script="$project_dir/test/test/annotation-automation.php"
    
    echo "=== Automated Annotation Fixing ==="
    echo "Fix Mode: $fix_mode"
    echo "Dry Run: $dry_run"
    echo ""
    
    if [ "$dry_run" = "true" ]; then
        echo "Running dry run - no changes will be made"
        php "$annotation_script" fix --fix-mode="$fix_mode" --dry-run
    else
        echo "Applying annotation fixes"
        php "$annotation_script" fix --fix-mode="$fix_mode"
    fi
}

# Generate fix summary
generate_fix_summary() {
    local project_dir=${1:-.}
    local annotation_script="$project_dir/test/test/annotation-automation.php"
    
    echo "=== Fix Summary ==="
    echo ""
    
    # Get fix recommendations
    php "$annotation_script" fix --fix-mode=safe --dry-run --format=json > /tmp/annotation-fixes.json
    
    if [ -f "/tmp/annotation-fixes.json" ]; then
        echo "Fix recommendations:"
        php -r "
        \$results = json_decode(file_get_contents('/tmp/annotation-fixes.json'), true);
        if (isset(\$results['fix_recommendations'])) {
            \$fixes = \$results['fix_recommendations'];
            echo 'Total fixes available: ' . count(\$fixes) . PHP_EOL;
            foreach (\$fixes as \$fix) {
                echo '- ' . (\$fix['description'] ?? 'Unknown fix') . PHP_EOL;
            }
        }
        "
    fi
}
```

**Step 7: Continuous Annotation Monitoring**

**Monitoring Tools:**
```bash
# Monitor annotations continuously
monitor_annotations() {
    local project_dir=${1:-.}
    local auto_fix=${2:-"false"}
    local annotation_script="$project_dir/test/test/annotation-automation.php"
    
    echo "=== Continuous Annotation Monitoring ==="
    echo "Auto-fix enabled: $auto_fix"
    echo ""
    
    if [ "$auto_fix" = "true" ]; then
        php "$annotation_script" monitor --watch --auto-fix
    else
        php "$annotation_script" monitor --watch
    fi
}

# Setup annotation monitoring
setup_annotation_monitoring() {
    local project_dir=${1:-.}
    local annotation_shell="$project_dir/test/test/annotation-automation.sh"
    
    echo "=== Setting Up Annotation Monitoring ==="
    echo ""
    
    # Check monitoring requirements
    if command -v fswatch >/dev/null 2>&1; then
        echo "✅ fswatch available for file monitoring"
    elif command -v inotifywait >/dev/null 2>&1; then
        echo "✅ inotifywait available for file monitoring"
    else
        echo "⚠️  No file monitoring tool found. Install fswatch (Mac) or inotify-tools (Linux)"
    fi
    
    # Setup monitoring
    if [ -f "$annotation_shell" ]; then
        "$annotation_shell" setup
    else
        echo "ERROR: Annotation shell script not found"
        return 1
    fi
}
```

**Method-Level Annotation Validation Quality Checklist:**
- [ ] PHP annotation system detected and configured
- [ ] All public source methods discovered and scanned
- [ ] All test methods discovered and scanned
- [ ] @Verified annotations validated on source methods
- [ ] @TestedBy annotations validated on test methods
- [ ] Method-to-test-case bidirectional linkage validated
- [ ] Orphaned methods (without corresponding annotations) identified
- [ ] Method-level coverage analysis completed with recommendations
- [ ] Automated method annotation fixes identified and reviewed
- [ ] Monitoring setup configured for continuous method-level validation
- [ ] Comprehensive method-level reports generated with actionable insights

**Anti-Patterns to Avoid:**
- ❌ Running validation without method-level bidirectional linkage analysis (incomplete validation)
- ❌ Validating at class level instead of method level (insufficient granularity)
- ❌ Ignoring orphaned methods without corresponding test annotations (quality compromise)
- ❌ Single-threaded validation without parallelization (performance issue)
- ❌ Generic validation without method-specific PHP optimization (suboptimal)
- ❌ Skipping method-level coverage analysis or quality metrics (missed insights)
- ❌ No automated method annotation fixing or actionable recommendations (missed improvements)

**Final Verification:**
Before completing method-level annotation validation:
- Have I discovered and scanned all public source methods for @Verified annotations?
- Have I discovered and scanned all test methods for @TestedBy annotations?
- Are method-to-test-case linkage reports generated with gap analysis?
- Have I identified and reported all orphaned methods without corresponding annotations?
- Are method-level fix recommendations provided with safe mode options?
- Do I have comprehensive monitoring setup for continuous method-level validation?

**Final Commitment:**
- **I will**: Validate all method-level annotations with comprehensive bidirectional linkage analysis
- **I will**: Discover and scan all public source methods for @Verified annotations
- **I will**: Discover and scan all test methods for @TestedBy annotations
- **I will**: Use parallel agents for optimal method-level validation performance
- **I will**: Provide detailed method-to-test-case gap analysis and actionable recommendations
- **I will**: Validate method annotation quality and suggest improvements
- **I will**: Generate comprehensive method-level reports with monitoring capabilities
- **I will NOT**: Skip method-level linkage analysis or quality validation
- **I will NOT**: Ignore orphaned methods or broken method-to-test-case linkages
- **I will NOT**: Use single-threaded validation without parallelization
- **I will NOT**: Provide generic reports without method-specific actionable insights

**REMEMBER:**
This is METHOD-LEVEL ANNOTATION VALIDATION mode - comprehensive method-level annotation analysis with bidirectional linkage validation, quality metrics, and automated fixing. The goal is to ensure every source method has a corresponding @Verified annotation pointing to a specific test method, and every test method has a corresponding @TestedBy annotation pointing to a specific source method.

Executing comprehensive annotation validation protocol with parallel agent coordination...