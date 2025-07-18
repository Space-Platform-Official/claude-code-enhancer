---
allowed-tools: all
description: PHP test structure generation with intelligent framework detection and customizable templates
intensity: ⚡⚡⚡
pattern: 🏗️🏗️🏗️
---

# 🏗️🏗️🏗️ CRITICAL REQUIREMENT: PHP TEST STRUCTURE GENERATION! 🏗️🏗️🏗️

**THIS IS NOT A SIMPLE DIRECTORY CREATION - THIS IS A COMPREHENSIVE TEST STRUCTURE GENERATION SYSTEM!**

When you run `/test structure`, you are REQUIRED to:

1. **DETECT** PHP framework and project structure automatically
2. **GENERATE** comprehensive test directory hierarchy with proper organization
3. **CREATE** framework-specific configurations and support files
4. **CONFIGURE** development tools (phpstan, phpcs, infection)
5. **INTEGRATE** with existing annotation validation system
6. **USE MULTIPLE AGENTS** for parallel structure generation:
   - Spawn one agent for directory structure creation
   - Spawn another for tool configuration generation
   - Spawn agents for framework-specific optimizations
   - Say: "I'll spawn multiple agents to generate PHP test structure comprehensively"

**FORBIDDEN BEHAVIORS:**
- ❌ "Create basic test directories" → NO! Use comprehensive structured hierarchy!
- ❌ "Skip framework detection" → NO! Framework-specific optimizations required!
- ❌ "Ignore tool configurations" → NO! Complete development tool setup required!
- ❌ "Generic PHP structure" → NO! Framework-specific templates mandatory!
- ❌ "Single-threaded generation" → NO! Use parallel agent coordination!

**MANDATORY WORKFLOW:**
```
1. Validation check → Verify PHP structure generation should proceed
2. Framework detection → Identify Laravel, Symfony, or Pure PHP with confidence scoring
3. IMMEDIATELY spawn agents for parallel structure generation (if approved)
4. Directory creation → Generate hierarchical test structure
5. Tool configuration → Create phpstan, phpcs, infection configs
6. Support files → Generate TestCase, DatabaseTestCase, bootstrap.php
7. VERIFY structure → Ensure complete and functional test environment
```

**YOU ARE NOT DONE UNTIL:**
- ✅ Complete test directory hierarchy created
- ✅ Framework-specific optimizations applied
- ✅ Tool configurations generated and functional
- ✅ Support files created with proper inheritance
- ✅ Annotation system integration verified
- ✅ Build output directories configured

---

🛑 **MANDATORY PHP STRUCTURE GENERATION PROTOCOL** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. FIRST: Execute should_generate_php_structure() validation
3. IF validation fails: Show appropriate skip message and exit gracefully
4. IF validation passes: Check current project structure and framework
5. Verify PHP environment and dependencies

Execute comprehensive test structure generation ONLY after validation approval with ZERO tolerance for incomplete setup.

**FORBIDDEN SHORTCUT PATTERNS:**
- "Basic directory creation is sufficient" → NO, comprehensive structure required
- "Skip tool configurations" → NO, complete development environment needed
- "Generic PHP setup" → NO, framework-specific optimizations required
- "Manual configuration is fine" → NO, automated generation required
- "Single agent execution is faster" → NO, parallel generation mandatory

You are generating PHP test structure for: $ARGUMENTS

Let me ultrathink about comprehensive test structure generation with framework intelligence.

🚨 **REMEMBER: Proper test structure is the foundation of maintainable PHP applications!** 🚨

**Comprehensive PHP Test Structure Generation Protocol:**

**Step 0: Framework Detection and Analysis**
- Detect PHP framework (Laravel, Symfony, Pure PHP)
- Analyze existing project structure
- Identify MVC patterns and application architecture
- Determine appropriate test organization strategy
- Verify PHP version and compatibility requirements

**Step 1: Target Directory Structure Definition**

**Complete PHP Test Structure:**
```
├── tests/                         # Test Directory
│   ├── Unit/                      # Unit Tests
│   │   ├── UnitTests/             # Controller Unit Tests
│   │   ├── Service/               # Service Layer Unit Tests
│   │   └── Model/                 # Model Unit Tests
│   ├── Integration/               # Integration Tests
│   │   ├── Database/              # Database Integration Tests
│   │   └── Api/                   # API Integration Tests
│   ├── Functional/                # Functional Tests
│   ├── Performance/               # Performance Tests
│   │   └── Benchmarks/            # Performance Benchmark Tests
│   ├── Security/                  # Security Tests
│   ├── Fixtures/                  # Test Data and Fixtures
│   │   ├── data/                  # Test Data Files
│   │   └── mocks/                 # Mock Objects
│   ├── Support/                   # Test Support Classes
│   │   ├── TestCase.php           # Base Test Case
│   │   └── DatabaseTestCase.php   # Database Test Case
│   └── bootstrap.php              # Test Bootstrap File
├── tools/                         # Development Tools
│   ├── phpstan.neon              # Static Analysis Configuration
│   ├── phpcs.xml                 # Code Style Checking
│   └── infection.json            # Mutation Testing Configuration
├── build/                         # Build Output
│   ├── coverage/                 # Code Coverage Reports
│   ├── logs/                     # Test Logs
│   └── reports/                  # Various Test Reports
```

**Step 2: Framework Detection Implementation**

**Framework Detection Logic:**
```bash
# Detect PHP framework with confidence scoring
detect_php_framework() {
    local project_dir=${1:-.}
    
    echo "=== PHP Framework Detection ==="
    echo ""
    
    # Laravel detection with confidence scoring
    if [ -f "$project_dir/artisan" ] && [ -f "$project_dir/composer.json" ]; then
        if grep -q "laravel/framework" "$project_dir/composer.json"; then
            echo "✅ Laravel framework detected (HIGH confidence)"
            echo "framework:laravel:high"
            return 0
        fi
    fi
    
    # Symfony detection with confidence scoring
    if [ -f "$project_dir/bin/console" ] && [ -f "$project_dir/composer.json" ]; then
        if grep -q "symfony/framework" "$project_dir/composer.json"; then
            echo "✅ Symfony framework detected (HIGH confidence)"
            echo "framework:symfony:high"
            return 0
        fi
    fi
    
    # Pure PHP detection with confidence scoring
    if [ -f "$project_dir/composer.json" ]; then
        # Check for PHP-specific indicators
        if grep -q "phpunit/phpunit\|psr/\|php\"\:" "$project_dir/composer.json"; then
            echo "✅ Pure PHP project detected (MEDIUM confidence)"
            echo "framework:php:medium"
            return 0
        else
            echo "⚠️  Composer.json found but low PHP confidence"
            echo "framework:unknown:low"
            return 1
        fi
    fi
    
    echo "⚠️  No PHP framework detected"
    echo "framework:none:none"
    return 1
}

# Check if PHP structure generation should proceed
should_generate_php_structure() {
    local project_dir=${1:-.}
    
    echo "=== PHP Structure Generation Validation ==="
    echo ""
    
    # Check user opt-out via environment variable
    if [ "$CLAUDE_PHP_TESTS" = "false" ]; then
        echo "❌ PHP test structure skipped: CLAUDE_PHP_TESTS=false"
        return 1
    fi
    
    # Check user opt-out via project file
    if [ -f "$project_dir/.claude/no-php-tests" ]; then
        echo "❌ PHP test structure skipped: .claude/no-php-tests file exists"
        echo "   Remove this file to enable PHP structure generation"
        return 1
    fi
    
    # Detect framework with confidence
    local framework_result=$(detect_php_framework "$project_dir")
    local framework=$(echo "$framework_result" | grep "framework:" | cut -d: -f2)
    local confidence=$(echo "$framework_result" | grep "framework:" | cut -d: -f3)
    
    # Skip if no framework detected or low confidence
    if [ "$framework" = "none" ] || [ "$framework" = "unknown" ]; then
        echo "❌ PHP test structure skipped: No PHP framework detected"
        echo "   This appears to be a non-PHP project"
        echo "   Use CLAUDE_PHP_TESTS=true to force PHP structure generation"
        return 1
    fi
    
    if [ "$confidence" = "low" ]; then
        echo "❌ PHP test structure skipped: Low confidence PHP detection"
        echo "   Framework: $framework (confidence: $confidence)"
        echo "   Use CLAUDE_PHP_TESTS=true to force PHP structure generation"
        return 1
    fi
    
    # Check for conflicting test structures
    if check_conflicting_test_structure "$project_dir"; then
        echo "❌ PHP test structure skipped: Conflicting test structure detected"
        echo "   Run with --force to overwrite existing structure"
        return 1
    fi
    
    echo "✅ PHP test structure generation approved"
    echo "   Framework: $framework (confidence: $confidence)"
    return 0
}

# Check for conflicting test structures
check_conflicting_test_structure() {
    local project_dir=${1:-.}
    
    # Check for existing test directories with different structure
    if [ -d "$project_dir/test" ] && [ ! -d "$project_dir/tests" ]; then
        echo "⚠️  Found existing 'test' directory (singular)"
        echo "   PHP convention uses 'tests' (plural)"
        return 0
    fi
    
    if [ -d "$project_dir/tests" ]; then
        # Check if it's already a PHP structure
        if [ -f "$project_dir/tests/bootstrap.php" ] || [ -d "$project_dir/tests/Unit" ]; then
            echo "ℹ️  Existing PHP test structure found"
            return 1  # Not conflicting, it's PHP
        fi
        
        # Check for non-PHP test structures
        if [ -d "$project_dir/tests/__tests__" ] || [ -f "$project_dir/tests/jest.config.js" ]; then
            echo "⚠️  Found JavaScript/Jest test structure"
            return 0  # Conflicting
        fi
        
        if [ -d "$project_dir/tests/spec" ] || [ -f "$project_dir/tests/karma.conf.js" ]; then
            echo "⚠️  Found Angular/Karma test structure"
            return 0  # Conflicting
        fi
    fi
    
    return 1  # No conflicts detected
}

# Provide user feedback when PHP structure is skipped
show_php_structure_skip_message() {
    local reason=${1:-"unknown"}
    
    echo ""
    echo "🔄 Alternative Test Structure Options:"
    echo ""
    
    case "$reason" in
        "no-framework")
            echo "   • For JavaScript projects: Use '/test structure js'"
            echo "   • For Python projects: Use '/test structure py'"
            echo "   • For generic projects: Use '/test structure generic'"
            ;;
        "low-confidence")
            echo "   • To force PHP structure: Set CLAUDE_PHP_TESTS=true"
            echo "   • For other languages: Use '/test structure [language]'"
            echo "   • For generic structure: Use '/test structure generic'"
            ;;
        "opt-out")
            echo "   • To re-enable PHP structure: Remove .claude/no-php-tests"
            echo "   • Or set CLAUDE_PHP_TESTS=true to override"
            ;;
        "conflict")
            echo "   • To overwrite: Use '/test structure --force'"
            echo "   • To merge: Manually resolve conflicts first"
            echo "   • To keep existing: No action needed"
            ;;
    esac
    
    echo ""
    echo "📚 For more information: '/help test structure'"
}

# Get framework-specific configuration
get_php_framework_config() {
    local framework=$1
    local project_dir=${2:-.}
    
    case "$framework" in
        "laravel")
            echo "namespace:Tests test_base:TestCase database_base:RefreshDatabase phpunit_config:phpunit.xml"
            ;;
        "symfony")
            echo "namespace:App\\Tests test_base:WebTestCase database_base:KernelTestCase phpunit_config:phpunit.xml.dist"
            ;;
        "php")
            echo "namespace:Tests test_base:PHPUnit\\Framework\\TestCase database_base:DatabaseTestCase phpunit_config:phpunit.xml"
            ;;
        *)
            echo "namespace:Tests test_base:TestCase database_base:DatabaseTestCase phpunit_config:phpunit.xml"
            ;;
    esac
}
```

**Step 3: Multi-Agent Structure Generation**

**Agent Spawning Strategy for PHP Structure Generation:**
```
"I'll spawn multiple agents to generate PHP test structure comprehensively:
- Directory Creation Agent: Create hierarchical test directory structure
- Framework Optimization Agent: Apply framework-specific configurations and patterns
- Tool Configuration Agent: Generate phpstan, phpcs, infection configurations
- Support File Agent: Create TestCase classes and bootstrap files
- Integration Agent: Connect with existing annotation validation system
- Validation Agent: Verify structure completeness and functionality"
```

**Step 4: Directory Structure Creation**

**Directory Creation Implementation:**
```bash
# Create comprehensive test directory structure
create_php_test_structure() {
    local project_dir=${1:-.}
    local framework=${2:-"php"}
    
    echo "🏗️  Creating comprehensive PHP test structure for $framework"
    echo ""
    
    # Create main test directories
    mkdir -p "$project_dir/tests/Unit/Controller"
    mkdir -p "$project_dir/tests/Unit/Service"
    mkdir -p "$project_dir/tests/Unit/Model"
    mkdir -p "$project_dir/tests/Integration/Database"
    mkdir -p "$project_dir/tests/Integration/Api"
    mkdir -p "$project_dir/tests/Functional"
    mkdir -p "$project_dir/tests/Performance/Benchmarks"
    mkdir -p "$project_dir/tests/Security"
    mkdir -p "$project_dir/tests/Fixtures/data"
    mkdir -p "$project_dir/tests/Fixtures/mocks"
    mkdir -p "$project_dir/tests/Support"
    
    # Create tool directories
    mkdir -p "$project_dir/tools"
    
    # Create build directories
    mkdir -p "$project_dir/build/coverage"
    mkdir -p "$project_dir/build/logs"
    mkdir -p "$project_dir/build/reports"
    
    echo "✅ Directory structure created successfully"
    
    # Log structure creation
    log_structure_creation "$framework" "$project_dir"
}

# Log structure creation for tracking
log_structure_creation() {
    local framework=$1
    local project_dir=$2
    
    echo "=== PHP Test Structure Creation Log ==="
    echo "Framework: $framework"
    echo "Project Directory: $project_dir"
    echo "Created at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "Structure: Comprehensive PHP test hierarchy with $framework optimizations"
    echo ""
}
```

**Step 5: Framework-Specific Optimizations**

**Laravel Framework Optimizations:**
```bash
generate_laravel_test_structure() {
    local project_dir=${1:-.}
    
    echo "🎯 Applying Laravel-specific optimizations"
    
    # Laravel-specific directories
    mkdir -p "$project_dir/tests/Feature"
    mkdir -p "$project_dir/tests/Unit/Http/Controllers"
    mkdir -p "$project_dir/tests/Unit/Http/Middleware"
    mkdir -p "$project_dir/tests/Unit/Http/Requests"
    mkdir -p "$project_dir/tests/Unit/Models"
    mkdir -p "$project_dir/tests/Unit/Services"
    mkdir -p "$project_dir/tests/Unit/Repositories"
    mkdir -p "$project_dir/tests/Unit/Jobs"
    mkdir -p "$project_dir/tests/Unit/Notifications"
    mkdir -p "$project_dir/tests/Unit/Listeners"
    mkdir -p "$project_dir/tests/Integration/Console"
    mkdir -p "$project_dir/tests/Integration/Broadcasting"
    mkdir -p "$project_dir/tests/Integration/Mail"
    mkdir -p "$project_dir/tests/Unit/Policies"
    mkdir -p "$project_dir/tests/Unit/Rules"
    
    # Laravel-specific support files
    create_laravel_test_case "$project_dir"
    create_laravel_database_test_case "$project_dir"
    create_laravel_bootstrap "$project_dir"
    create_laravel_helpers "$project_dir"
    
    echo "✅ Laravel optimizations applied"
}

create_laravel_test_case() {
    local project_dir=$1
    
    cat > "$project_dir/tests/Support/TestCase.php" << 'EOF'
<?php

namespace Tests\Support;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;

abstract class TestCase extends BaseTestCase
{
    use CreatesApplication, RefreshDatabase;
    
    /**
     * Setup the test environment.
     */
    protected function setUp(): void
    {
        parent::setUp();
        
        // Set testing environment
        $this->app->make('config')->set('app.env', 'testing');
        
        // Common Laravel test setup
        $this->artisan('config:clear');
        $this->artisan('cache:clear');
    }
    
    /**
     * Clean up after test.
     */
    protected function tearDown(): void
    {
        // Add common test cleanup here
        
        parent::tearDown();
    }
    
    /**
     * Create authenticated user for testing.
     */
    protected function actingAsUser($user = null, $guard = null)
    {
        $user = $user ?: factory(User::class)->create();
        return $this->actingAs($user, $guard);
    }
}
EOF
}

create_laravel_database_test_case() {
    local project_dir=$1
    
    cat > "$project_dir/tests/Support/DatabaseTestCase.php" << 'EOF'
<?php

namespace Tests\Support;

use Illuminate\Foundation\Testing\DatabaseMigrations;
use Illuminate\Foundation\Testing\DatabaseTransactions;

abstract class DatabaseTestCase extends TestCase
{
    use DatabaseMigrations, DatabaseTransactions;
    
    /**
     * Setup database for testing.
     */
    protected function setUp(): void
    {
        parent::setUp();
        
        // Run migrations
        $this->artisan('migrate:fresh');
        
        // Seed test data if needed
        $this->seed();
    }
    
    /**
     * Seed test database.
     */
    protected function seed()
    {
        // Override in child classes for specific seeding
    }
}
EOF
}

create_laravel_helpers() {
    local project_dir=$1
    
    cat > "$project_dir/tests/Support/helpers.php" << 'EOF'
<?php

if (!function_exists('create_test_user')) {
    /**
     * Create a test user.
     */
    function create_test_user(array $attributes = [])
    {
        return factory(App\Models\User::class)->create($attributes);
    }
}

if (!function_exists('mock_external_api')) {
    /**
     * Mock external API responses.
     */
    function mock_external_api($service, $response)
    {
        Http::fake([
            $service => Http::response($response, 200)
        ]);
    }
}

if (!function_exists('assert_dispatched_job')) {
    /**
     * Assert a job was dispatched.
     */
    function assert_dispatched_job($job, $callback = null)
    {
        Queue::assertPushed($job, $callback);
    }
}
EOF
}
```

**Symfony Framework Optimizations:**
```bash
generate_symfony_test_structure() {
    local project_dir=${1:-.}
    
    echo "🎯 Applying Symfony-specific optimizations"
    
    # Symfony-specific directories
    mkdir -p "$project_dir/tests/Unit/Controller"
    mkdir -p "$project_dir/tests/Unit/Service"
    mkdir -p "$project_dir/tests/Unit/Entity"
    mkdir -p "$project_dir/tests/Unit/Repository"
    mkdir -p "$project_dir/tests/Unit/Form"
    mkdir -p "$project_dir/tests/Unit/EventSubscriber"
    mkdir -p "$project_dir/tests/Unit/Command"
    mkdir -p "$project_dir/tests/Unit/Security"
    mkdir -p "$project_dir/tests/Unit/Validator"
    mkdir -p "$project_dir/tests/Integration/Controller"
    mkdir -p "$project_dir/tests/Integration/Repository"
    mkdir -p "$project_dir/tests/Integration/Command"
    mkdir -p "$project_dir/tests/Integration/Messenger"
    mkdir -p "$project_dir/tests/Functional/Controller"
    mkdir -p "$project_dir/tests/Functional/Form"
    
    # Symfony-specific support files
    create_symfony_test_case "$project_dir"
    create_symfony_database_test_case "$project_dir"
    create_symfony_bootstrap "$project_dir"
    create_symfony_helpers "$project_dir"
    
    echo "✅ Symfony optimizations applied"
}

create_symfony_test_case() {
    local project_dir=$1
    
    cat > "$project_dir/tests/Support/TestCase.php" << 'EOF'
<?php

namespace App\Tests\Support;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Symfony\Bundle\FrameworkBundle\KernelBrowser;

abstract class TestCase extends WebTestCase
{
    protected KernelBrowser $client;
    
    /**
     * Setup the test environment.
     */
    protected function setUp(): void
    {
        parent::setUp();
        
        $this->client = static::createClient();
        
        // Set test environment
        $_ENV['APP_ENV'] = 'test';
        
        // Boot the kernel for testing
        self::bootKernel();
    }
    
    /**
     * Clean up after test.
     */
    protected function tearDown(): void
    {
        parent::tearDown();
        
        // Clean up after tests
        $this->client = null;
    }
    
    /**
     * Get container service.
     */
    protected function getService(string $serviceId)
    {
        return self::getContainer()->get($serviceId);
    }
    
    /**
     * Create authenticated user for testing.
     */
    protected function loginUser($user = null): void
    {
        if ($user === null) {
            $user = $this->createTestUser();
        }
        
        $this->client->loginUser($user);
    }
    
    /**
     * Create test user.
     */
    protected function createTestUser(): object
    {
        // Override in child classes with actual User entity creation
        throw new \LogicException('createTestUser must be implemented in child class');
    }
}
EOF
}

create_symfony_database_test_case() {
    local project_dir=$1
    
    cat > "$project_dir/tests/Support/DatabaseTestCase.php" << 'EOF'
<?php

namespace App\Tests\Support;

use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;

abstract class DatabaseTestCase extends KernelTestCase
{
    protected EntityManagerInterface $entityManager;
    
    /**
     * Setup database for testing.
     */
    protected function setUp(): void
    {
        parent::setUp();
        
        self::bootKernel();
        
        $this->entityManager = self::getContainer()
            ->get('doctrine')
            ->getManager();
        
        // Begin transaction for each test
        $this->entityManager->beginTransaction();
    }
    
    /**
     * Clean up after test.
     */
    protected function tearDown(): void
    {
        parent::tearDown();
        
        // Rollback transaction to clean up
        if ($this->entityManager->getConnection()->isTransactionActive()) {
            $this->entityManager->rollback();
        }
        
        $this->entityManager->close();
        $this->entityManager = null;
    }
    
    /**
     * Persist and flush entity.
     */
    protected function persistAndFlush($entity): void
    {
        $this->entityManager->persist($entity);
        $this->entityManager->flush();
    }
}
EOF
}

create_symfony_helpers() {
    local project_dir=$1
    
    cat > "$project_dir/tests/Support/helpers.php" << 'EOF'
<?php

if (!function_exists('create_test_entity')) {
    /**
     * Create test entity with factory.
     */
    function create_test_entity(string $entityClass, array $data = []): object
    {
        // Basic entity creation - customize based on your factory system
        $entity = new $entityClass();
        
        foreach ($data as $property => $value) {
            $setter = 'set' . ucfirst($property);
            if (method_exists($entity, $setter)) {
                $entity->$setter($value);
            }
        }
        
        return $entity;
    }
}

if (!function_exists('mock_symfony_service')) {
    /**
     * Mock Symfony service for testing.
     */
    function mock_symfony_service(string $serviceId, $mock): void
    {
        $container = \Symfony\Component\DependencyInjection\ContainerBuilder();
        $container->set($serviceId, $mock);
    }
}

if (!function_exists('assert_response_status')) {
    /**
     * Assert HTTP response status.
     */
    function assert_response_status(\Symfony\Bundle\FrameworkBundle\KernelBrowser $client, int $expectedStatus): void
    {
        $actualStatus = $client->getResponse()->getStatusCode();
        if ($actualStatus !== $expectedStatus) {
            throw new \PHPUnit\Framework\AssertionFailedError(
                "Expected status code {$expectedStatus}, got {$actualStatus}"
            );
        }
    }
}
EOF
}
```

**Pure PHP Optimizations:**
```bash
generate_php_test_structure() {
    local project_dir=${1:-.}
    
    echo "🎯 Applying Pure PHP optimizations"
    
    # Pure PHP additional directories
    mkdir -p "$project_dir/tests/Unit/Classes"
    mkdir -p "$project_dir/tests/Unit/Traits"
    mkdir -p "$project_dir/tests/Unit/Interfaces"
    mkdir -p "$project_dir/tests/Unit/Exceptions"
    mkdir -p "$project_dir/tests/Unit/Utilities"
    mkdir -p "$project_dir/tests/Integration/FileSystem"
    mkdir -p "$project_dir/tests/Integration/Network"
    mkdir -p "$project_dir/tests/Integration/Configuration"
    
    # Pure PHP-specific support files
    create_php_test_case "$project_dir"
    create_php_database_test_case "$project_dir"
    create_php_bootstrap "$project_dir"
    create_php_helpers "$project_dir"
    
    echo "✅ Pure PHP optimizations applied"
}

create_php_test_case() {
    local project_dir=$1
    
    cat > "$project_dir/tests/Support/TestCase.php" << 'EOF'
<?php

namespace Tests\Support;

use PHPUnit\Framework\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    /**
     * Setup the test environment.
     */
    protected function setUp(): void
    {
        parent::setUp();
        
        // Set error reporting for tests
        error_reporting(E_ALL);
        ini_set('display_errors', '1');
        
        // Set timezone
        date_default_timezone_set('UTC');
        
        // Add common test setup here
        $this->setUpTestEnvironment();
    }
    
    /**
     * Clean up after test.
     */
    protected function tearDown(): void
    {
        // Clean up test environment
        $this->tearDownTestEnvironment();
        
        parent::tearDown();
    }
    
    /**
     * Setup test environment.
     */
    protected function setUpTestEnvironment(): void
    {
        // Override in child classes for specific setup
    }
    
    /**
     * Tear down test environment.
     */
    protected function tearDownTestEnvironment(): void
    {
        // Override in child classes for specific cleanup
    }
    
    /**
     * Create mock object with fluent interface.
     */
    protected function createMockWithMethods(string $className, array $methods = []): object
    {
        $mock = $this->createMock($className);
        
        foreach ($methods as $method => $returnValue) {
            $mock->method($method)->willReturn($returnValue);
        }
        
        return $mock;
    }
    
    /**
     * Assert array structure matches expected.
     */
    protected function assertArrayStructure(array $expected, array $actual): void
    {
        foreach ($expected as $key => $value) {
            $this->assertArrayHasKey($key, $actual, "Missing key: {$key}");
            
            if (is_array($value)) {
                $this->assertIsArray($actual[$key], "Value for key {$key} should be array");
                $this->assertArrayStructure($value, $actual[$key]);
            }
        }
    }
}
EOF
}

create_php_database_test_case() {
    local project_dir=$1
    
    cat > "$project_dir/tests/Support/DatabaseTestCase.php" << 'EOF'
<?php

namespace Tests\Support;

use PDO;
use PDOException;

abstract class DatabaseTestCase extends TestCase
{
    protected PDO $pdo;
    protected array $tables = [];
    
    /**
     * Setup database for testing.
     */
    protected function setUp(): void
    {
        parent::setUp();
        
        $this->setupDatabase();
        $this->createTables();
        $this->seedTestData();
    }
    
    /**
     * Clean up after test.
     */
    protected function tearDown(): void
    {
        $this->cleanupDatabase();
        
        parent::tearDown();
    }
    
    /**
     * Setup test database connection.
     */
    protected function setupDatabase(): void
    {
        try {
            $this->pdo = new PDO('sqlite::memory:');
            $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            $this->markTestSkipped('Database not available: ' . $e->getMessage());
        }
    }
    
    /**
     * Create test tables.
     */
    protected function createTables(): void
    {
        // Override in child classes to create specific tables
    }
    
    /**
     * Seed test data.
     */
    protected function seedTestData(): void
    {
        // Override in child classes for specific seeding
    }
    
    /**
     * Clean up database.
     */
    protected function cleanupDatabase(): void
    {
        foreach (array_reverse($this->tables) as $table) {
            $this->pdo->exec("DROP TABLE IF EXISTS {$table}");
        }
        
        $this->pdo = null;
    }
    
    /**
     * Execute SQL and return results.
     */
    protected function executeQuery(string $sql, array $params = []): array
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }
    
    /**
     * Insert test data.
     */
    protected function insertTestData(string $table, array $data): int
    {
        $columns = implode(', ', array_keys($data));
        $placeholders = ':' . implode(', :', array_keys($data));
        
        $sql = "INSERT INTO {$table} ({$columns}) VALUES ({$placeholders})";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($data);
        
        return (int) $this->pdo->lastInsertId();
    }
}
EOF
}

create_php_helpers() {
    local project_dir=$1
    
    cat > "$project_dir/tests/Support/helpers.php" << 'EOF'
<?php

if (!function_exists('create_temporary_file')) {
    /**
     * Create temporary file for testing.
     */
    function create_temporary_file(string $content = '', string $extension = 'txt'): string
    {
        $tempFile = tempnam(sys_get_temp_dir(), 'test_') . '.' . $extension;
        file_put_contents($tempFile, $content);
        
        // Register for cleanup
        register_shutdown_function(function() use ($tempFile) {
            if (file_exists($tempFile)) {
                unlink($tempFile);
            }
        });
        
        return $tempFile;
    }
}

if (!function_exists('create_temporary_directory')) {
    /**
     * Create temporary directory for testing.
     */
    function create_temporary_directory(string $prefix = 'test_'): string
    {
        $tempDir = sys_get_temp_dir() . DIRECTORY_SEPARATOR . $prefix . uniqid();
        mkdir($tempDir, 0777, true);
        
        // Register for cleanup
        register_shutdown_function(function() use ($tempDir) {
            if (is_dir($tempDir)) {
                $files = new RecursiveIteratorIterator(
                    new RecursiveDirectoryIterator($tempDir, RecursiveDirectoryIterator::SKIP_DOTS),
                    RecursiveIteratorIterator::CHILD_FIRST
                );
                
                foreach ($files as $file) {
                    $file->isDir() ? rmdir($file) : unlink($file);
                }
                
                rmdir($tempDir);
            }
        });
        
        return $tempDir;
    }
}

if (!function_exists('assert_string_contains_all')) {
    /**
     * Assert string contains all given substrings.
     */
    function assert_string_contains_all(string $haystack, array $needles): void
    {
        foreach ($needles as $needle) {
            if (strpos($haystack, $needle) === false) {
                throw new \PHPUnit\Framework\AssertionFailedError(
                    "String does not contain: {$needle}"
                );
            }
        }
    }
}

if (!function_exists('mock_global_function')) {
    /**
     * Mock global function for testing.
     */
    function mock_global_function(string $functionName, $returnValue): void
    {
        if (!function_exists($functionName . '_original')) {
            // Create backup of original function if it exists
            if (function_exists($functionName)) {
                eval("function {$functionName}_original() { return call_user_func_array('{$functionName}', func_get_args()); }");
            }
        }
        
        // Create mock function
        eval("function {$functionName}() use (\$returnValue) { return \$returnValue; }");
    }
}
EOF
}
```

**Step 6: Tool Configuration Generation**

**PHPStan Configuration:**
```bash
generate_phpstan_config() {
    local project_dir=${1:-.}
    local framework=${2:-"php"}
    
    echo "🔍 Generating PHPStan configuration for $framework"
    
    cat > "$project_dir/tools/phpstan.neon" << EOF
parameters:
    level: 8
    paths:
        - ../src
        - ../tests
    excludePaths:
        - ../tests/Fixtures
        - ../build
    ignoreErrors:
        - '#Call to an undefined method#'
    checkMissingIterableValueType: false
    checkGenericClassInNonGenericObjectType: false
    reportUnmatchedIgnoredErrors: false
    
includes:
    - vendor/phpstan/phpstan/conf/bleedingEdge.neon
EOF

    echo "✅ PHPStan configuration generated"
}

generate_phpcs_config() {
    local project_dir=${1:-.}
    local framework=${2:-"php"}
    
    echo "📏 Generating PHP_CodeSniffer configuration for $framework"
    
    cat > "$project_dir/tools/phpcs.xml" << EOF
<?xml version="1.0"?>
<ruleset name="Project Coding Standard">
    <description>Coding standard for the project</description>
    
    <!-- Files to check -->
    <file>../src</file>
    <file>../tests</file>
    
    <!-- Exclude patterns -->
    <exclude-pattern>../tests/Fixtures</exclude-pattern>
    <exclude-pattern>../build</exclude-pattern>
    <exclude-pattern>../vendor</exclude-pattern>
    
    <!-- Use PSR-12 as base -->
    <rule ref="PSR12"/>
    
    <!-- Additional rules -->
    <rule ref="Generic.Arrays.DisallowLongArraySyntax"/>
    <rule ref="Generic.Formatting.SpaceAfterCast"/>
    <rule ref="Generic.Functions.CallTimePassByReference"/>
    <rule ref="Generic.NamingConventions.UpperCaseConstantName"/>
    <rule ref="Generic.PHP.LowerCaseKeyword"/>
    <rule ref="Squiz.Scope.MemberVarScope"/>
    
    <!-- Show progress -->
    <arg name="progress"/>
    
    <!-- Use colors -->
    <arg name="colors"/>
    
    <!-- Show sniff codes -->
    <arg value="s"/>
</ruleset>
EOF

    echo "✅ PHP_CodeSniffer configuration generated"
}

generate_infection_config() {
    local project_dir=${1:-.}
    local framework=${2:-"php"}
    
    echo "🦠 Generating Infection mutation testing configuration for $framework"
    
    cat > "$project_dir/tools/infection.json" << EOF
{
    "source": {
        "directories": [
            "../src"
        ]
    },
    "logs": {
        "text": "../build/logs/infection.log",
        "summary": "../build/logs/infection-summary.log",
        "json": "../build/logs/infection.json",
        "html": "../build/reports/infection.html"
    },
    "tmpDir": "../build/infection",
    "php": {
        "configTimeout": 30
    },
    "minMsi": 80,
    "minCoveredMsi": 85,
    "mutators": {
        "@default": true,
        "@function_signature": false,
        "TrueValue": {
            "ignore": [
                "Tests\\\\*"
            ]
        }
    },
    "testFramework": "phpunit",
    "bootstrap": "../tests/bootstrap.php"
}
EOF

    echo "✅ Infection configuration generated"
}
```

**Step 7: Bootstrap and Support File Generation**

**Bootstrap File Generation:**
```bash
generate_test_bootstrap() {
    local project_dir=${1:-.}
    local framework=${2:-"php"}
    
    echo "🚀 Generating test bootstrap file for $framework"
    
    case "$framework" in
        "laravel")
            create_laravel_bootstrap "$project_dir"
            ;;
        "symfony")
            create_symfony_bootstrap "$project_dir"
            ;;
        "php")
            create_php_bootstrap "$project_dir"
            ;;
    esac
    
    echo "✅ Test bootstrap generated"
}

create_php_bootstrap() {
    local project_dir=$1
    
    cat > "$project_dir/tests/bootstrap.php" << 'EOF'
<?php

declare(strict_types=1);

// Set timezone
date_default_timezone_set('UTC');

// Set error reporting
error_reporting(E_ALL);
ini_set('display_errors', '1');

// Load Composer autoloader
require_once dirname(__DIR__) . '/vendor/autoload.php';

// Set test environment variables
$_ENV['APP_ENV'] = 'testing';
$_ENV['DB_CONNECTION'] = 'sqlite';
$_ENV['DB_DATABASE'] = ':memory:';

// Initialize test database if needed
if (class_exists('PDO')) {
    try {
        $pdo = new PDO('sqlite::memory:');
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        // Store PDO instance for tests
        $GLOBALS['test_pdo'] = $pdo;
    } catch (PDOException $e) {
        // Continue without database if not available
    }
}

// Set up test-specific constants
define('TEST_ROOT', __DIR__);
define('FIXTURES_PATH', TEST_ROOT . '/Fixtures');
define('DATA_PATH', FIXTURES_PATH . '/data');
define('MOCKS_PATH', FIXTURES_PATH . '/mocks');

// Include helper functions
if (file_exists(__DIR__ . '/Support/helpers.php')) {
    require_once __DIR__ . '/Support/helpers.php';
}

echo "Test environment initialized successfully\n";
EOF
}
```

**Step 8: Integration with Annotation System**

**Annotation Integration:**
```bash
integrate_annotation_system() {
    local project_dir=${1:-.}
    local framework=${2:-"php"}
    
    echo "🔗 Integrating with annotation validation system"
    
    # Check if annotation system exists
    if [ -f "$project_dir/test/test/annotation-automation.php" ]; then
        echo "✅ Found existing annotation system, integrating structure"
        
        # Update annotation configuration for new structure
        update_annotation_config_for_structure "$project_dir" "$framework"
    else
        echo "ℹ️  No annotation system found, structure ready for future integration"
    fi
    
    # Create annotation-ready test examples
    create_annotation_ready_examples "$project_dir" "$framework"
}

create_annotation_ready_examples() {
    local project_dir=$1
    local framework=$2
    
    # Create example test with annotations
    cat > "$project_dir/tests/Unit/Controller/ExampleControllerTest.php" << 'EOF'
<?php

namespace Tests\Unit\Controller;

use Tests\Support\TestCase;

class ExampleControllerTest extends TestCase
{
    /**
     * @TestedBy(method="App\Http\Controllers\ExampleController::index")
     * @covers \App\Http\Controllers\ExampleController::index
     */
    public function testIndex(): void
    {
        // Test implementation
        $this->assertTrue(true);
    }
    
    /**
     * @TestedBy(method="App\Http\Controllers\ExampleController::store")
     * @covers \App\Http\Controllers\ExampleController::store
     */
    public function testStore(): void
    {
        // Test implementation
        $this->assertTrue(true);
    }
}
EOF

    echo "✅ Annotation-ready examples created"
}
```

**Step 9: Main Execution Flow with Validation**

**Complete PHP Structure Generation Implementation:**
```bash
# Main execution function with validation
execute_php_structure_generation() {
    local project_dir=${1:-.}
    local force_flag=${2:-""}
    
    echo "🚀 Starting PHP Test Structure Generation"
    echo "Project Directory: $project_dir"
    echo ""
    
    # Step 1: Validate if PHP structure should be generated
    if ! should_generate_php_structure "$project_dir"; then
        local skip_reason="unknown"
        
        # Determine skip reason for appropriate messaging
        if [ "$CLAUDE_PHP_TESTS" = "false" ] || [ -f "$project_dir/.claude/no-php-tests" ]; then
            skip_reason="opt-out"
        elif [ -d "$project_dir/tests" ] && check_conflicting_test_structure "$project_dir"; then
            skip_reason="conflict"
        else
            local framework_result=$(detect_php_framework "$project_dir")
            local framework=$(echo "$framework_result" | grep "framework:" | cut -d: -f2)
            local confidence=$(echo "$framework_result" | grep "framework:" | cut -d: -f3)
            
            if [ "$framework" = "none" ] || [ "$framework" = "unknown" ]; then
                skip_reason="no-framework"
            elif [ "$confidence" = "low" ]; then
                skip_reason="low-confidence"
            fi
        fi
        
        show_php_structure_skip_message "$skip_reason"
        return 0  # Exit gracefully, not an error
    fi
    
    # Step 2: Get framework information for approved generation
    local framework_result=$(detect_php_framework "$project_dir")
    local framework=$(echo "$framework_result" | grep "framework:" | cut -d: -f2)
    local confidence=$(echo "$framework_result" | grep "framework:" | cut -d: -f3)
    
    echo "🎯 Proceeding with PHP structure generation"
    echo "   Framework: $framework"
    echo "   Confidence: $confidence"
    echo ""
    
    # Step 3: Multi-agent coordination for comprehensive generation
    echo "I'll spawn multiple agents to generate PHP test structure comprehensively:"
    echo "- Directory Creation Agent: Create hierarchical test directory structure"
    echo "- Framework Optimization Agent: Apply framework-specific configurations and patterns"
    echo "- Tool Configuration Agent: Generate phpstan, phpcs, infection configurations"
    echo "- Support File Agent: Create TestCase classes and bootstrap files"
    echo "- Integration Agent: Connect with existing annotation validation system"
    echo "- Validation Agent: Verify structure completeness and functionality"
    echo ""
    
    # Step 4: Execute comprehensive structure generation
    create_php_test_structure "$project_dir" "$framework"
    
    # Step 5: Apply framework-specific optimizations
    case "$framework" in
        "laravel")
            generate_laravel_test_structure "$project_dir"
            ;;
        "symfony")
            generate_symfony_test_structure "$project_dir"
            ;;
        "php")
            generate_php_test_structure "$project_dir"
            ;;
    esac
    
    # Step 6: Generate tool configurations
    generate_phpstan_config "$project_dir" "$framework"
    generate_phpcs_config "$project_dir" "$framework"
    generate_infection_config "$project_dir" "$framework"
    
    # Step 7: Generate bootstrap and support files
    generate_test_bootstrap "$project_dir" "$framework"
    
    # Step 8: Integrate with annotation system
    integrate_annotation_system "$project_dir" "$framework"
    
    # Step 9: Final verification
    verify_php_structure_completeness "$project_dir" "$framework"
    
    echo ""
    echo "🎉 PHP test structure generation completed successfully!"
    echo "   Framework: $framework"
    echo "   Structure: Comprehensive with all optimizations applied"
    echo "   Tools: phpstan, phpcs, infection configured"
    echo "   Support: TestCase classes and bootstrap ready"
    echo ""
}

# Verify structure completeness
verify_php_structure_completeness() {
    local project_dir=${1:-.}
    local framework=${2:-"php"}
    
    echo "🔍 Verifying PHP test structure completeness"
    
    local missing_items=()
    
    # Check essential directories
    [ ! -d "$project_dir/tests/Unit" ] && missing_items+=("tests/Unit directory")
    [ ! -d "$project_dir/tests/Integration" ] && missing_items+=("tests/Integration directory")
    [ ! -d "$project_dir/tests/Support" ] && missing_items+=("tests/Support directory")
    [ ! -d "$project_dir/tools" ] && missing_items+=("tools directory")
    [ ! -d "$project_dir/build" ] && missing_items+=("build directory")
    
    # Check essential files
    [ ! -f "$project_dir/tests/bootstrap.php" ] && missing_items+=("tests/bootstrap.php")
    [ ! -f "$project_dir/tests/Support/TestCase.php" ] && missing_items+=("TestCase.php")
    [ ! -f "$project_dir/tools/phpstan.neon" ] && missing_items+=("phpstan.neon")
    [ ! -f "$project_dir/tools/phpcs.xml" ] && missing_items+=("phpcs.xml")
    
    if [ ${#missing_items[@]} -eq 0 ]; then
        echo "✅ Structure verification passed - all components present"
        return 0
    else
        echo "❌ Structure verification failed - missing components:"
        for item in "${missing_items[@]}"; do
            echo "   • $item"
        done
        return 1
    fi
}

# Handle force override for PHP structure generation
handle_force_php_structure() {
    local project_dir=${1:-.}
    
    echo "⚠️  Force flag detected - overriding validation checks"
    echo "   This will generate PHP structure regardless of detection results"
    echo ""
    
    # Override environment variable temporarily
    export CLAUDE_PHP_TESTS="true"
    
    # Execute with force
    execute_php_structure_generation "$project_dir" "--force"
}
```

**PHP Test Structure Quality Checklist:**
- [ ] Complete directory hierarchy created
- [ ] Framework-specific optimizations applied
- [ ] Tool configurations generated (phpstan, phpcs, infection)
- [ ] Support files created with proper inheritance
- [ ] Bootstrap file configured for test environment
- [ ] Annotation system integration verified
- [ ] Build output directories configured
- [ ] Directory structure logged and documented

**Anti-Patterns to Avoid:**
- ❌ Creating incomplete directory structure (missing critical directories)
- ❌ Ignoring framework-specific optimizations (generic setup)
- ❌ Skipping tool configuration generation (incomplete development environment)
- ❌ Missing support files or bootstrap configuration (broken test environment)
- ❌ No integration with existing annotation system (lost functionality)
- ❌ Generic PHP setup without framework detection (suboptimal structure)

**Final Verification:**
Before completing PHP test structure generation:
- Have I created the complete directory hierarchy as specified?
- Are framework-specific optimizations properly applied?
- Are all tool configurations generated and functional?
- Are support files created with proper inheritance structure?
- Is the annotation system properly integrated?
- Are build directories configured for reports and coverage?

**Final Commitment:**
- **I will**: FIRST validate if PHP structure generation is appropriate using should_generate_php_structure()
- **I will**: Respect user opt-out mechanisms (CLAUDE_PHP_TESTS=false, .claude/no-php-tests)
- **I will**: Only generate PHP structure when framework confidence is MEDIUM or HIGH
- **I will**: Provide clear feedback when PHP structure is skipped with alternative suggestions
- **I will**: Generate complete PHP test structure with framework detection ONLY when validated
- **I will**: Apply framework-specific optimizations and configurations for approved projects
- **I will**: Create comprehensive tool configurations for development
- **I will**: Generate proper support files and bootstrap configuration
- **I will**: Integrate with existing annotation validation system
- **I will NOT**: Generate PHP structure without validation approval
- **I will NOT**: Override user opt-out preferences without explicit force flag
- **I will NOT**: Create PHP structure for non-PHP or low-confidence projects
- **I will NOT**: Create incomplete or generic directory structure
- **I will NOT**: Skip framework detection and optimization

**REMEMBER:**
This is OPTIONAL PHP TEST STRUCTURE GENERATION mode - intelligent validation FIRST, then comprehensive directory creation with framework intelligence, tool configuration, and annotation integration. The goal is to create appropriate test structures that only apply PHP generation when contextually relevant and user-approved.

**Key Behaviors:**
- ✅ Validate before generating (respects opt-outs and confidence scoring)
- ✅ Graceful skipping with helpful alternative suggestions
- ✅ Comprehensive PHP structure ONLY for confirmed PHP projects
- ✅ Backwards compatibility for legitimate PHP projects

Executing smart PHP test structure generation protocol with validation-first approach...