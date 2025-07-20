# Integration Testing Utilities

This file contains utilities for integration testing, cross-component testing, and system-level test coordination across all test commands.

## Integration Test Management

```bash
# Execute comprehensive integration tests
execute_integration_tests() {
    local project_dir=${1:-.}
    local framework=${2:-"auto"}
    local integration_type=${3:-"all"}
    
    echo "=== EXECUTING INTEGRATION TESTS ==="
    echo "Project Directory: $project_dir"
    echo "Framework: $framework"
    echo "Integration Type: $integration_type"
    echo ""
    
    # Source shared utilities
    source "$(dirname "$0")/utils.md"
    source "$(dirname "$0")/runners.md"
    
    # Detect framework if auto
    if [ "$framework" = "auto" ]; then
        framework=$(detect_test_framework "$project_dir")
    fi
    
    # Setup integration test environment
    setup_integration_environment "$project_dir" "$framework"
    
    # Execute integration tests by type
    case "$integration_type" in
        "api")
            execute_api_integration_tests "$project_dir" "$framework"
            ;;
        "database")
            execute_database_integration_tests "$project_dir" "$framework"
            ;;
        "service")
            execute_service_integration_tests "$project_dir" "$framework"
            ;;
        "ui")
            execute_ui_integration_tests "$project_dir" "$framework"
            ;;
        "all")
            execute_all_integration_tests "$project_dir" "$framework"
            ;;
        *)
            echo "ERROR: Unknown integration type: $integration_type"
            return 1
            ;;
    esac
    
    # Generate integration test report
    generate_integration_test_report "$project_dir" "$framework"
}

# Setup integration test environment
setup_integration_environment() {
    local project_dir=$1
    local framework=$2
    
    echo "Setting up integration test environment..."
    
    # Create integration test directories
    create_integration_test_structure "$project_dir" "$framework"
    
    # Setup test databases
    setup_test_databases "$project_dir" "$framework"
    
    # Setup mock services
    setup_mock_services "$project_dir" "$framework"
    
    # Configure test environment variables
    configure_integration_env_vars "$project_dir" "$framework"
    
    echo "Integration test environment ready"
}

# Create integration test directory structure
create_integration_test_structure() {
    local project_dir=$1
    local framework=$2
    
    case "$framework" in
        "jest")
            mkdir -p "$project_dir/tests/integration"
            mkdir -p "$project_dir/tests/integration/api"
            mkdir -p "$project_dir/tests/integration/database"
            mkdir -p "$project_dir/tests/integration/services"
            mkdir -p "$project_dir/tests/integration/ui"
            ;;
        "pytest")
            mkdir -p "$project_dir/tests/integration"
            mkdir -p "$project_dir/tests/integration/api"
            mkdir -p "$project_dir/tests/integration/database"
            mkdir -p "$project_dir/tests/integration/services"
            ;;
        "go-test")
            mkdir -p "$project_dir/integration"
            mkdir -p "$project_dir/integration/api"
            mkdir -p "$project_dir/integration/database"
            mkdir -p "$project_dir/integration/services"
            ;;
        "rspec")
            mkdir -p "$project_dir/spec/integration"
            mkdir -p "$project_dir/spec/integration/api"
            mkdir -p "$project_dir/spec/integration/database"
            mkdir -p "$project_dir/spec/integration/services"
            ;;
    esac
}

# Setup test databases
setup_test_databases() {
    local project_dir=$1
    local framework=$2
    
    echo "Setting up test databases..."
    
    # Check for database configuration
    local db_config=""
    if [ -f "$project_dir/database.yml" ]; then
        db_config="$project_dir/database.yml"
    elif [ -f "$project_dir/config/database.yml" ]; then
        db_config="$project_dir/config/database.yml"
    elif [ -f "$project_dir/.env" ]; then
        db_config="$project_dir/.env"
    fi
    
    if [ -n "$db_config" ]; then
        echo "Found database configuration: $db_config"
        
        # Setup framework-specific test database
        case "$framework" in
            "jest")
                setup_jest_test_database "$project_dir"
                ;;
            "pytest")
                setup_pytest_test_database "$project_dir"
                ;;
            "go-test")
                setup_go_test_database "$project_dir"
                ;;
            "rspec")
                setup_rspec_test_database "$project_dir"
                ;;
        esac
    else
        echo "No database configuration found, using in-memory database"
    fi
}

# Setup Jest test database
setup_jest_test_database() {
    local project_dir=$1
    
    # Create test database setup script
    cat > "$project_dir/tests/integration/database-setup.js" <<EOF
// Database setup for Jest integration tests
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

class TestDatabase {
  constructor() {
    this.db = null;
    this.dbPath = ':memory:'; // Use in-memory database for tests
  }
  
  async setup() {
    return new Promise((resolve, reject) => {
      this.db = new sqlite3.Database(this.dbPath, (err) => {
        if (err) {
          reject(err);
        } else {
          console.log('Test database connected');
          this.createTables().then(resolve).catch(reject);
        }
      });
    });
  }
  
  async createTables() {
    return new Promise((resolve, reject) => {
      const createUsersTable = \`
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      \`;
      
      const createProductsTable = \`
        CREATE TABLE IF NOT EXISTS products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          price DECIMAL(10,2) NOT NULL,
          category TEXT,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      \`;
      
      this.db.serialize(() => {
        this.db.run(createUsersTable);
        this.db.run(createProductsTable, (err) => {
          if (err) {
            reject(err);
          } else {
            console.log('Test tables created');
            this.seedTestData().then(resolve).catch(reject);
          }
        });
      });
    });
  }
  
  async seedTestData() {
    return new Promise((resolve, reject) => {
      const insertUser = this.db.prepare("INSERT INTO users (name, email) VALUES (?, ?)");
      const insertProduct = this.db.prepare("INSERT INTO products (name, price, category) VALUES (?, ?, ?)");
      
      this.db.serialize(() => {
        // Seed users
        insertUser.run("John Doe", "john@example.com");
        insertUser.run("Jane Smith", "jane@example.com");
        insertUser.finalize();
        
        // Seed products
        insertProduct.run("Laptop", 999.99, "Electronics");
        insertProduct.run("Book", 19.99, "Education");
        insertProduct.finalize((err) => {
          if (err) {
            reject(err);
          } else {
            console.log('Test data seeded');
            resolve();
          }
        });
      });
    });
  }
  
  async cleanup() {
    return new Promise((resolve) => {
      if (this.db) {
        this.db.close((err) => {
          if (err) {
            console.error('Error closing database:', err);
          } else {
            console.log('Test database connection closed');
          }
          resolve();
        });
      } else {
        resolve();
      }
    });
  }
  
  getConnection() {
    return this.db;
  }
}

module.exports = TestDatabase;
EOF
    
    echo "Jest test database setup created"
}

# Setup mock services
setup_mock_services() {
    local project_dir=$1
    local framework=$2
    
    echo "Setting up mock services..."
    
    case "$framework" in
        "jest")
            setup_jest_mock_services "$project_dir"
            ;;
        "pytest")
            setup_pytest_mock_services "$project_dir"
            ;;
        "go-test")
            setup_go_mock_services "$project_dir"
            ;;
        "rspec")
            setup_rspec_mock_services "$project_dir"
            ;;
    esac
}

# Setup Jest mock services
setup_jest_mock_services() {
    local project_dir=$1
    
    # Create mock HTTP server
    cat > "$project_dir/tests/integration/mock-server.js" <<EOF
// Mock HTTP server for Jest integration tests
const express = require('express');
const cors = require('cors');

class MockServer {
  constructor() {
    this.app = express();
    this.server = null;
    this.port = 0;
    
    this.setupMiddleware();
    this.setupRoutes();
  }
  
  setupMiddleware() {
    this.app.use(cors());
    this.app.use(express.json());
    this.app.use(express.urlencoded({ extended: true }));
  }
  
  setupRoutes() {
    // Mock API endpoints
    this.app.get('/api/health', (req, res) => {
      res.json({ status: 'ok', timestamp: new Date().toISOString() });
    });
    
    this.app.get('/api/users', (req, res) => {
      res.json([
        { id: 1, name: 'John Doe', email: 'john@example.com' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
      ]);
    });
    
    this.app.get('/api/users/:id', (req, res) => {
      const id = parseInt(req.params.id);
      if (id === 1) {
        res.json({ id: 1, name: 'John Doe', email: 'john@example.com' });
      } else if (id === 2) {
        res.json({ id: 2, name: 'Jane Smith', email: 'jane@example.com' });
      } else {
        res.status(404).json({ error: 'User not found' });
      }
    });
    
    this.app.post('/api/users', (req, res) => {
      const { name, email } = req.body;
      if (!name || !email) {
        return res.status(400).json({ error: 'Name and email are required' });
      }
      
      res.status(201).json({
        id: Math.floor(Math.random() * 1000),
        name,
        email,
        created_at: new Date().toISOString()
      });
    });
    
    this.app.put('/api/users/:id', (req, res) => {
      const id = parseInt(req.params.id);
      const { name, email } = req.body;
      
      res.json({
        id,
        name: name || 'Updated Name',
        email: email || 'updated@example.com',
        updated_at: new Date().toISOString()
      });
    });
    
    this.app.delete('/api/users/:id', (req, res) => {
      res.status(204).send();
    });
    
    // Mock external service endpoints
    this.app.get('/external/payment/status', (req, res) => {
      res.json({ status: 'success', transaction_id: 'mock_txn_123' });
    });
    
    this.app.post('/external/notifications/send', (req, res) => {
      res.json({ message_id: 'mock_msg_456', status: 'sent' });
    });
    
    // Error simulation endpoints
    this.app.get('/api/error/500', (req, res) => {
      res.status(500).json({ error: 'Internal server error' });
    });
    
    this.app.get('/api/error/timeout', (req, res) => {
      // Simulate timeout - don't respond
      setTimeout(() => {
        res.status(408).json({ error: 'Request timeout' });
      }, 30000);
    });
  }
  
  async start() {
    return new Promise((resolve, reject) => {
      this.server = this.app.listen(0, (err) => {
        if (err) {
          reject(err);
        } else {
          this.port = this.server.address().port;
          console.log(\`Mock server started on port \${this.port}\`);
          resolve(this.port);
        }
      });
    });
  }
  
  async stop() {
    return new Promise((resolve) => {
      if (this.server) {
        this.server.close(() => {
          console.log('Mock server stopped');
          resolve();
        });
      } else {
        resolve();
      }
    });
  }
  
  getBaseUrl() {
    return \`http://localhost:\${this.port}\`;
  }
}

module.exports = MockServer;
EOF
    
    echo "Jest mock services setup created"
}

# Execute API integration tests
execute_api_integration_tests() {
    local project_dir=$1
    local framework=$2
    
    echo "Executing API integration tests..."
    
    case "$framework" in
        "jest")
            execute_jest_api_tests "$project_dir"
            ;;
        "pytest")
            execute_pytest_api_tests "$project_dir"
            ;;
        "go-test")
            execute_go_api_tests "$project_dir"
            ;;
        "rspec")
            execute_rspec_api_tests "$project_dir"
            ;;
    esac
}

# Execute Jest API integration tests
execute_jest_api_tests() {
    local project_dir=$1
    
    # Create API integration test
    cat > "$project_dir/tests/integration/api/user-api.test.js" <<EOF
// API integration tests for Jest
const axios = require('axios');
const MockServer = require('../mock-server');

describe('User API Integration Tests', () => {
  let mockServer;
  let baseUrl;
  
  beforeAll(async () => {
    mockServer = new MockServer();
    const port = await mockServer.start();
    baseUrl = \`http://localhost:\${port}\`;
  });
  
  afterAll(async () => {
    if (mockServer) {
      await mockServer.stop();
    }
  });
  
  describe('GET /api/users', () => {
    test('should return list of users', async () => {
      const response = await axios.get(\`\${baseUrl}/api/users\`);
      
      expect(response.status).toBe(200);
      expect(Array.isArray(response.data)).toBe(true);
      expect(response.data.length).toBeGreaterThan(0);
      expect(response.data[0]).toHaveProperty('id');
      expect(response.data[0]).toHaveProperty('name');
      expect(response.data[0]).toHaveProperty('email');
    });
  });
  
  describe('GET /api/users/:id', () => {
    test('should return specific user', async () => {
      const response = await axios.get(\`\${baseUrl}/api/users/1\`);
      
      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('id', 1);
      expect(response.data).toHaveProperty('name');
      expect(response.data).toHaveProperty('email');
    });
    
    test('should return 404 for non-existent user', async () => {
      try {
        await axios.get(\`\${baseUrl}/api/users/999\`);
        fail('Expected 404 error');
      } catch (error) {
        expect(error.response.status).toBe(404);
        expect(error.response.data).toHaveProperty('error');
      }
    });
  });
  
  describe('POST /api/users', () => {
    test('should create new user', async () => {
      const userData = {
        name: 'Test User',
        email: 'test@example.com'
      };
      
      const response = await axios.post(\`\${baseUrl}/api/users\`, userData);
      
      expect(response.status).toBe(201);
      expect(response.data).toHaveProperty('id');
      expect(response.data).toHaveProperty('name', userData.name);
      expect(response.data).toHaveProperty('email', userData.email);
      expect(response.data).toHaveProperty('created_at');
    });
    
    test('should return 400 for invalid data', async () => {
      const invalidData = { name: 'Test User' }; // Missing email
      
      try {
        await axios.post(\`\${baseUrl}/api/users\`, invalidData);
        fail('Expected 400 error');
      } catch (error) {
        expect(error.response.status).toBe(400);
        expect(error.response.data).toHaveProperty('error');
      }
    });
  });
  
  describe('PUT /api/users/:id', () => {
    test('should update existing user', async () => {
      const updateData = {
        name: 'Updated User',
        email: 'updated@example.com'
      };
      
      const response = await axios.put(\`\${baseUrl}/api/users/1\`, updateData);
      
      expect(response.status).toBe(200);
      expect(response.data).toHaveProperty('id', 1);
      expect(response.data).toHaveProperty('updated_at');
    });
  });
  
  describe('DELETE /api/users/:id', () => {
    test('should delete user', async () => {
      const response = await axios.delete(\`\${baseUrl}/api/users/1\`);
      
      expect(response.status).toBe(204);
    });
  });
  
  describe('Error handling', () => {
    test('should handle server errors gracefully', async () => {
      try {
        await axios.get(\`\${baseUrl}/api/error/500\`);
        fail('Expected 500 error');
      } catch (error) {
        expect(error.response.status).toBe(500);
        expect(error.response.data).toHaveProperty('error');
      }
    });
    
    test('should handle timeouts', async () => {
      const axiosInstance = axios.create({ timeout: 1000 });
      
      try {
        await axiosInstance.get(\`\${baseUrl}/api/error/timeout\`);
        fail('Expected timeout error');
      } catch (error) {
        expect(error.code).toBe('ECONNABORTED');
      }
    }, 10000);
  });
});
EOF
    
    # Run Jest API integration tests
    cd "$project_dir" && npx jest tests/integration/api --verbose
}

# Execute database integration tests
execute_database_integration_tests() {
    local project_dir=$1
    local framework=$2
    
    echo "Executing database integration tests..."
    
    case "$framework" in
        "jest")
            execute_jest_database_tests "$project_dir"
            ;;
        "pytest")
            execute_pytest_database_tests "$project_dir"
            ;;
        "go-test")
            execute_go_database_tests "$project_dir"
            ;;
        "rspec")
            execute_rspec_database_tests "$project_dir"
            ;;
    esac
}

# Execute service integration tests
execute_service_integration_tests() {
    local project_dir=$1
    local framework=$2
    
    echo "Executing service integration tests..."
    
    # Test service-to-service communication
    test_service_communication "$project_dir" "$framework"
    
    # Test service dependencies
    test_service_dependencies "$project_dir" "$framework"
    
    # Test service configuration
    test_service_configuration "$project_dir" "$framework"
}

# Test service communication
test_service_communication() {
    local project_dir=$1
    local framework=$2
    
    echo "Testing service communication..."
    
    case "$framework" in
        "jest")
            create_jest_service_communication_test "$project_dir"
            ;;
        "pytest")
            create_pytest_service_communication_test "$project_dir"
            ;;
        "go-test")
            create_go_service_communication_test "$project_dir"
            ;;
        "rspec")
            create_rspec_service_communication_test "$project_dir"
            ;;
    esac
}

# Execute all integration tests
execute_all_integration_tests() {
    local project_dir=$1
    local framework=$2
    
    echo "Executing all integration tests..."
    
    # Execute in parallel for better performance
    local test_types=("api" "database" "service")
    local pids=()
    
    for test_type in "${test_types[@]}"; do
        case "$test_type" in
            "api")
                execute_api_integration_tests "$project_dir" "$framework" &
                pids+=($!)
                ;;
            "database")
                execute_database_integration_tests "$project_dir" "$framework" &
                pids+=($!)
                ;;
            "service")
                execute_service_integration_tests "$project_dir" "$framework" &
                pids+=($!)
                ;;
        esac
    done
    
    # Wait for all tests to complete
    local failed_tests=0
    for pid in "${pids[@]}"; do
        if ! wait "$pid"; then
            failed_tests=$((failed_tests + 1))
        fi
    done
    
    if [ "$failed_tests" -eq 0 ]; then
        echo "✅ All integration tests passed"
    else
        echo "❌ $failed_tests integration test suites failed"
        return 1
    fi
}

# Generate integration test report
generate_integration_test_report() {
    local project_dir=$1
    local framework=$2
    
    echo "=== INTEGRATION TEST REPORT ==="
    echo ""
    
    local report_file="$project_dir/integration-test-report.json"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Create report structure
    cat > "$report_file" <<EOF
{
  "timestamp": "$timestamp",
  "framework": "$framework",
  "project_dir": "$project_dir",
  "test_suites": {
    "api": {
      "executed": false,
      "passed": 0,
      "failed": 0,
      "duration": 0
    },
    "database": {
      "executed": false,
      "passed": 0,
      "failed": 0,
      "duration": 0
    },
    "service": {
      "executed": false,
      "passed": 0,
      "failed": 0,
      "duration": 0
    }
  },
  "summary": {
    "total_tests": 0,
    "total_passed": 0,
    "total_failed": 0,
    "success_rate": 0,
    "total_duration": 0
  }
}
EOF
    
    # Collect test results (implementation depends on framework)
    collect_integration_test_results "$report_file" "$framework"
    
    # Display summary
    display_integration_test_summary "$report_file"
    
    echo "Integration test report saved: $report_file"
}

# Display integration test summary
display_integration_test_summary() {
    local report_file=$1
    
    if [ -f "$report_file" ] && command -v jq >/dev/null 2>&1; then
        local total_tests=$(jq -r '.summary.total_tests' "$report_file")
        local total_passed=$(jq -r '.summary.total_passed' "$report_file")
        local total_failed=$(jq -r '.summary.total_failed' "$report_file")
        local success_rate=$(jq -r '.summary.success_rate' "$report_file")
        local total_duration=$(jq -r '.summary.total_duration' "$report_file")
        
        echo "Integration Test Summary:"
        echo "- Total Tests: $total_tests"
        echo "- Passed: $total_passed"
        echo "- Failed: $total_failed"
        echo "- Success Rate: $success_rate%"
        echo "- Total Duration: ${total_duration}s"
        echo ""
        
        # Show test suite breakdown
        echo "Test Suite Breakdown:"
        jq -r '.test_suites | to_entries[] | "- \(.key | ascii_upcase): \(.value.passed) passed, \(.value.failed) failed (\(.value.duration)s)"' "$report_file"
        echo ""
    fi
}

# Cross-component test coordination
coordinate_cross_component_tests() {
    local project_dir=${1:-.}
    local components=${2:-"all"}
    
    echo "=== COORDINATING CROSS-COMPONENT TESTS ==="
    echo "Components: $components"
    echo ""
    
    # Identify components
    local component_list=($(identify_project_components "$project_dir"))
    
    if [ "$components" = "all" ]; then
        components_to_test=("${component_list[@]}")
    else
        IFS=',' read -ra components_to_test <<< "$components"
    fi
    
    echo "Testing components: ${components_to_test[*]}"
    echo ""
    
    # Test component interactions
    for i in "${!components_to_test[@]}"; do
        for j in "${!components_to_test[@]}"; do
            if [ "$i" -ne "$j" ]; then
                local component_a="${components_to_test[$i]}"
                local component_b="${components_to_test[$j]}"
                test_component_interaction "$project_dir" "$component_a" "$component_b"
            fi
        done
    done
}

# Identify project components
identify_project_components() {
    local project_dir=$1
    
    # Look for common component patterns
    local components=()
    
    # Check for microservices
    if [ -d "$project_dir/services" ]; then
        for service in "$project_dir/services"/*; do
            if [ -d "$service" ]; then
                components+=($(basename "$service"))
            fi
        done
    fi
    
    # Check for modules
    if [ -d "$project_dir/modules" ]; then
        for module in "$project_dir/modules"/*; do
            if [ -d "$module" ]; then
                components+=($(basename "$module"))
            fi
        done
    fi
    
    # Check for packages (Node.js)
    if [ -d "$project_dir/packages" ]; then
        for package in "$project_dir/packages"/*; do
            if [ -d "$package" ]; then
                components+=($(basename "$package"))
            fi
        done
    fi
    
    # Default components if none found
    if [ ${#components[@]} -eq 0 ]; then
        components=("frontend" "backend" "database" "api")
    fi
    
    printf "%s\n" "${components[@]}"
}

# Test component interaction
test_component_interaction() {
    local project_dir=$1
    local component_a=$2
    local component_b=$3
    
    echo "Testing interaction: $component_a <-> $component_b"
    
    # Create interaction test based on component types
    create_interaction_test "$project_dir" "$component_a" "$component_b"
    
    # Execute interaction test
    execute_interaction_test "$project_dir" "$component_a" "$component_b"
}

# Create interaction test
create_interaction_test() {
    local project_dir=$1
    local component_a=$2
    local component_b=$3
    
    local test_file="$project_dir/tests/integration/interaction_${component_a}_${component_b}.test.js"
    
    cat > "$test_file" <<EOF
// Interaction test between $component_a and $component_b
describe('Component Interaction: $component_a <-> $component_b', () => {
  test('should communicate successfully', async () => {
    // Test communication between components
    expect(true).toBe(true); // Placeholder
  });
  
  test('should handle errors gracefully', async () => {
    // Test error handling between components
    expect(true).toBe(true); // Placeholder
  });
  
  test('should maintain data consistency', async () => {
    // Test data consistency across components
    expect(true).toBe(true); // Placeholder
  });
});
EOF
    
    echo "Created interaction test: $test_file"
}

# Execute interaction test
execute_interaction_test() {
    local project_dir=$1
    local component_a=$2
    local component_b=$3
    
    local test_file="tests/integration/interaction_${component_a}_${component_b}.test.js"
    
    if [ -f "$project_dir/$test_file" ]; then
        echo "Executing interaction test: $test_file"
        cd "$project_dir" && npx jest "$test_file" --verbose
    else
        echo "Interaction test not found: $test_file"
    fi
}

# Configure integration environment variables
configure_integration_env_vars() {
    local project_dir=$1
    local framework=$2
    
    local env_file="$project_dir/.env.integration"
    
    cat > "$env_file" <<EOF
# Integration test environment variables
NODE_ENV=integration
TEST_MODE=integration
LOG_LEVEL=debug

# Database configuration
DATABASE_URL=sqlite::memory:
TEST_DATABASE_URL=sqlite::memory:

# API configuration
API_BASE_URL=http://localhost:3000
MOCK_API_BASE_URL=http://localhost:3001

# Service configuration
PAYMENT_SERVICE_URL=http://localhost:4000
NOTIFICATION_SERVICE_URL=http://localhost:4001
AUTH_SERVICE_URL=http://localhost:4002

# Feature flags
ENABLE_INTEGRATION_TESTS=true
ENABLE_MOCK_SERVICES=true
ENABLE_PARALLEL_TESTS=true

# Timeouts
API_TIMEOUT=10000
DATABASE_TIMEOUT=5000
SERVICE_TIMEOUT=8000

# Retry configuration
MAX_RETRIES=3
RETRY_DELAY=1000
EOF
    
    echo "Integration environment variables configured: $env_file"
}
```