# Test Fixtures and Data Management

This file contains utilities for test data management, fixture creation, and test environment setup across all test commands.

## Test Data Management

```bash
# Create test fixtures for different frameworks
create_test_fixtures() {
    local framework=$1
    local project_dir=${2:-.}
    local fixture_type=${3:-"basic"}
    
    echo "=== CREATING TEST FIXTURES ==="
    echo "Framework: $framework"
    echo "Project Directory: $project_dir"
    echo "Fixture Type: $fixture_type"
    echo ""
    
    case "$framework" in
        "jest")
            create_jest_fixtures "$project_dir" "$fixture_type"
            ;;
        "pytest")
            create_pytest_fixtures "$project_dir" "$fixture_type"
            ;;
        "go-test")
            create_go_fixtures "$project_dir" "$fixture_type"
            ;;
        "rspec")
            create_rspec_fixtures "$project_dir" "$fixture_type"
            ;;
        "mocha")
            create_mocha_fixtures "$project_dir" "$fixture_type"
            ;;
        *)
            echo "ERROR: Unsupported framework for fixtures: $framework"
            return 1
            ;;
    esac
}

# Create Jest test fixtures
create_jest_fixtures() {
    local project_dir=$1
    local fixture_type=$2
    
    local fixtures_dir="$project_dir/__fixtures__"
    mkdir -p "$fixtures_dir"
    
    case "$fixture_type" in
        "basic")
            create_jest_basic_fixtures "$fixtures_dir"
            ;;
        "api")
            create_jest_api_fixtures "$fixtures_dir"
            ;;
        "database")
            create_jest_database_fixtures "$fixtures_dir"
            ;;
        "ui")
            create_jest_ui_fixtures "$fixtures_dir"
            ;;
        *)
            create_jest_basic_fixtures "$fixtures_dir"
            ;;
    esac
    
    echo "Jest fixtures created in: $fixtures_dir"
}

# Create basic Jest fixtures
create_jest_basic_fixtures() {
    local fixtures_dir=$1
    
    # Sample user data
    cat > "$fixtures_dir/users.json" <<EOF
{
  "validUser": {
    "id": 1,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "age": 30,
    "active": true,
    "roles": ["user"]
  },
  "adminUser": {
    "id": 2,
    "name": "Jane Admin",
    "email": "jane.admin@example.com",
    "age": 35,
    "active": true,
    "roles": ["admin", "user"]
  },
  "inactiveUser": {
    "id": 3,
    "name": "Bob Inactive",
    "email": "bob.inactive@example.com",
    "age": 25,
    "active": false,
    "roles": ["user"]
  }
}
EOF
    
    # Sample configuration data
    cat > "$fixtures_dir/config.json" <<EOF
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "name": "test_db",
    "username": "test_user",
    "password": "test_pass"
  },
  "api": {
    "baseUrl": "https://api.example.com",
    "timeout": 5000,
    "retries": 3
  },
  "features": {
    "enableNewFeature": true,
    "maxUploadSize": 10485760,
    "allowedFileTypes": [".jpg", ".png", ".pdf"]
  }
}
EOF
    
    # Test helper functions
    cat > "$fixtures_dir/helpers.js" <<EOF
// Test helper functions for Jest
const fs = require('fs');
const path = require('path');

/**
 * Load fixture data from JSON file
 * @param {string} filename - Name of the fixture file
 * @returns {Object} Parsed fixture data
 */
function loadFixture(filename) {
  const filePath = path.join(__dirname, filename);
  const data = fs.readFileSync(filePath, 'utf8');
  return JSON.parse(data);
}

/**
 * Create a deep clone of an object
 * @param {Object} obj - Object to clone
 * @returns {Object} Cloned object
 */
function deepClone(obj) {
  return JSON.parse(JSON.stringify(obj));
}

/**
 * Generate random test data
 * @param {string} type - Type of data to generate
 * @returns {*} Generated test data
 */
function generateTestData(type) {
  const generators = {
    email: () => \`test.\${Math.random().toString(36).substr(2, 9)}@example.com\`,
    id: () => Math.floor(Math.random() * 1000000),
    name: () => \`Test User \${Math.floor(Math.random() * 1000)}\`,
    date: () => new Date().toISOString(),
    uuid: () => 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    })
  };
  
  return generators[type] ? generators[type]() : null;
}

/**
 * Create mock API response
 * @param {Object} data - Response data
 * @param {number} status - HTTP status code
 * @returns {Object} Mock response object
 */
function createMockResponse(data = {}, status = 200) {
  return {
    data,
    status,
    statusText: status === 200 ? 'OK' : 'Error',
    headers: {
      'Content-Type': 'application/json'
    }
  };
}

/**
 * Wait for a specified amount of time
 * @param {number} ms - Milliseconds to wait
 * @returns {Promise} Promise that resolves after the specified time
 */
function wait(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

module.exports = {
  loadFixture,
  deepClone,
  generateTestData,
  createMockResponse,
  wait
};
EOF
}

# Create API-specific Jest fixtures
create_jest_api_fixtures() {
    local fixtures_dir=$1
    
    # API response fixtures
    cat > "$fixtures_dir/api-responses.json" <<EOF
{
  "getUserSuccess": {
    "status": 200,
    "data": {
      "id": 1,
      "name": "John Doe",
      "email": "john.doe@example.com"
    }
  },
  "getUserError": {
    "status": 404,
    "error": {
      "code": "USER_NOT_FOUND",
      "message": "User not found"
    }
  },
  "createUserSuccess": {
    "status": 201,
    "data": {
      "id": 2,
      "name": "Jane Smith",
      "email": "jane.smith@example.com",
      "created_at": "2023-01-01T00:00:00Z"
    }
  },
  "validationError": {
    "status": 400,
    "error": {
      "code": "VALIDATION_ERROR",
      "message": "Validation failed",
      "details": [
        {
          "field": "email",
          "message": "Invalid email format"
        }
      ]
    }
  }
}
EOF
    
    # API mock helpers
    cat > "$fixtures_dir/api-mocks.js" <<EOF
// API mock helpers for Jest
const apiResponses = require('./api-responses.json');

/**
 * Create axios mock for successful API calls
 */
function createSuccessfulApiMock() {
  return jest.fn().mockImplementation((config) => {
    const { method, url } = config;
    
    if (method === 'get' && url.includes('/users/1')) {
      return Promise.resolve(apiResponses.getUserSuccess);
    }
    
    if (method === 'post' && url.includes('/users')) {
      return Promise.resolve(apiResponses.createUserSuccess);
    }
    
    return Promise.resolve({ status: 200, data: {} });
  });
}

/**
 * Create axios mock for API errors
 */
function createErrorApiMock() {
  return jest.fn().mockImplementation(() => {
    return Promise.reject(apiResponses.getUserError);
  });
}

/**
 * Create fetch mock for API calls
 */
function createFetchMock() {
  return jest.fn().mockImplementation((url, options) => {
    const method = options?.method || 'GET';
    
    if (method === 'GET' && url.includes('/users/1')) {
      return Promise.resolve({
        ok: true,
        status: 200,
        json: () => Promise.resolve(apiResponses.getUserSuccess.data)
      });
    }
    
    return Promise.resolve({
      ok: false,
      status: 404,
      json: () => Promise.resolve(apiResponses.getUserError.error)
    });
  });
}

module.exports = {
  createSuccessfulApiMock,
  createErrorApiMock,
  createFetchMock
};
EOF
}

# Create pytest fixtures
create_pytest_fixtures() {
    local project_dir=$1
    local fixture_type=$2
    
    local fixtures_dir="$project_dir/tests/fixtures"
    mkdir -p "$fixtures_dir"
    
    case "$fixture_type" in
        "basic")
            create_pytest_basic_fixtures "$fixtures_dir"
            ;;
        "database")
            create_pytest_database_fixtures "$fixtures_dir"
            ;;
        "api")
            create_pytest_api_fixtures "$fixtures_dir"
            ;;
        *)
            create_pytest_basic_fixtures "$fixtures_dir"
            ;;
    esac
    
    # Create conftest.py for shared fixtures
    create_pytest_conftest "$project_dir/tests"
    
    echo "Pytest fixtures created in: $fixtures_dir"
}

# Create basic pytest fixtures
create_pytest_basic_fixtures() {
    local fixtures_dir=$1
    
    # Sample data fixtures
    cat > "$fixtures_dir/sample_data.py" <<EOF
"""Sample data for pytest tests."""

SAMPLE_USERS = [
    {
        "id": 1,
        "name": "John Doe",
        "email": "john.doe@example.com",
        "age": 30,
        "active": True,
        "roles": ["user"]
    },
    {
        "id": 2,
        "name": "Jane Admin",
        "email": "jane.admin@example.com",
        "age": 35,
        "active": True,
        "roles": ["admin", "user"]
    },
    {
        "id": 3,
        "name": "Bob Inactive",
        "email": "bob.inactive@example.com",
        "age": 25,
        "active": False,
        "roles": ["user"]
    }
]

SAMPLE_CONFIG = {
    "database": {
        "host": "localhost",
        "port": 5432,
        "name": "test_db",
        "username": "test_user",
        "password": "test_pass"
    },
    "api": {
        "base_url": "https://api.example.com",
        "timeout": 5000,
        "retries": 3
    },
    "features": {
        "enable_new_feature": True,
        "max_upload_size": 10485760,
        "allowed_file_types": [".jpg", ".png", ".pdf"]
    }
}

SAMPLE_API_RESPONSES = {
    "get_user_success": {
        "status": 200,
        "data": {
            "id": 1,
            "name": "John Doe",
            "email": "john.doe@example.com"
        }
    },
    "get_user_error": {
        "status": 404,
        "error": {
            "code": "USER_NOT_FOUND",
            "message": "User not found"
        }
    }
}
EOF
    
    # Test utilities
    cat > "$fixtures_dir/test_utils.py" <<EOF
"""Test utilities for pytest."""
import json
import tempfile
import os
from datetime import datetime
from typing import Any, Dict
import uuid


def create_temp_file(content: str, suffix: str = ".tmp") -> str:
    """Create a temporary file with content."""
    with tempfile.NamedTemporaryFile(mode='w', suffix=suffix, delete=False) as f:
        f.write(content)
        return f.name


def create_temp_json_file(data: Dict[str, Any]) -> str:
    """Create a temporary JSON file with data."""
    content = json.dumps(data, indent=2)
    return create_temp_file(content, ".json")


def cleanup_temp_file(filepath: str) -> None:
    """Clean up a temporary file."""
    if os.path.exists(filepath):
        os.unlink(filepath)


def generate_test_data(data_type: str) -> Any:
    """Generate random test data."""
    generators = {
        "email": lambda: f"test.{uuid.uuid4().hex[:8]}@example.com",
        "id": lambda: uuid.uuid4().int & (1 << 31) - 1,  # 31-bit positive int
        "name": lambda: f"Test User {uuid.uuid4().hex[:6]}",
        "date": lambda: datetime.now().isoformat(),
        "uuid": lambda: str(uuid.uuid4())
    }
    
    if data_type in generators:
        return generators[data_type]()
    
    return None


def create_mock_response(data: Dict[str, Any] = None, status: int = 200) -> Dict[str, Any]:
    """Create a mock API response."""
    return {
        "data": data or {},
        "status": status,
        "headers": {
            "Content-Type": "application/json"
        }
    }


class MockResponse:
    """Mock HTTP response class."""
    
    def __init__(self, json_data: Dict[str, Any], status_code: int = 200):
        self.json_data = json_data
        self.status_code = status_code
        self.ok = status_code < 400
    
    def json(self):
        return self.json_data
    
    def raise_for_status(self):
        if not self.ok:
            raise Exception(f"HTTP {self.status_code}")
EOF
}

# Create pytest conftest.py
create_pytest_conftest() {
    local tests_dir=$1
    
    cat > "$tests_dir/conftest.py" <<EOF
"""Pytest configuration and shared fixtures."""
import pytest
import tempfile
import shutil
from pathlib import Path
from fixtures.sample_data import SAMPLE_USERS, SAMPLE_CONFIG
from fixtures.test_utils import create_temp_file, cleanup_temp_file


@pytest.fixture
def sample_user():
    """Provide a sample user for testing."""
    return SAMPLE_USERS[0].copy()


@pytest.fixture
def sample_users():
    """Provide sample users list for testing."""
    return [user.copy() for user in SAMPLE_USERS]


@pytest.fixture
def sample_config():
    """Provide sample configuration for testing."""
    return SAMPLE_CONFIG.copy()


@pytest.fixture
def temp_directory():
    """Create a temporary directory for testing."""
    temp_dir = tempfile.mkdtemp()
    yield Path(temp_dir)
    shutil.rmtree(temp_dir)


@pytest.fixture
def temp_file():
    """Create a temporary file for testing."""
    temp_file_path = None
    
    def _create_temp_file(content="", suffix=".tmp"):
        nonlocal temp_file_path
        temp_file_path = create_temp_file(content, suffix)
        return temp_file_path
    
    yield _create_temp_file
    
    if temp_file_path:
        cleanup_temp_file(temp_file_path)


@pytest.fixture
def mock_requests(monkeypatch):
    """Mock requests library for API testing."""
    class MockResponse:
        def __init__(self, json_data, status_code=200):
            self.json_data = json_data
            self.status_code = status_code
            self.ok = status_code < 400
        
        def json(self):
            return self.json_data
        
        def raise_for_status(self):
            if not self.ok:
                raise Exception(f"HTTP {self.status_code}")
    
    def mock_get(*args, **kwargs):
        return MockResponse({"id": 1, "name": "Test User"})
    
    def mock_post(*args, **kwargs):
        return MockResponse({"id": 2, "created": True}, 201)
    
    import requests
    monkeypatch.setattr(requests, "get", mock_get)
    monkeypatch.setattr(requests, "post", mock_post)
    
    return {"get": mock_get, "post": mock_post}


@pytest.fixture(autouse=True)
def reset_environment():
    """Reset environment variables after each test."""
    import os
    original_env = os.environ.copy()
    yield
    os.environ.clear()
    os.environ.update(original_env)


@pytest.fixture
def database_url():
    """Provide database URL for testing."""
    return "sqlite:///:memory:"


@pytest.fixture
def api_base_url():
    """Provide API base URL for testing."""
    return "https://api.test.example.com"
EOF
}

# Create Go test fixtures
create_go_fixtures() {
    local project_dir=$1
    local fixture_type=$2
    
    local fixtures_dir="$project_dir/testdata"
    mkdir -p "$fixtures_dir"
    
    case "$fixture_type" in
        "basic")
            create_go_basic_fixtures "$fixtures_dir"
            ;;
        "api")
            create_go_api_fixtures "$fixtures_dir"
            ;;
        *)
            create_go_basic_fixtures "$fixtures_dir"
            ;;
    esac
    
    # Create test helpers
    create_go_test_helpers "$project_dir"
    
    echo "Go test fixtures created in: $fixtures_dir"
}

# Create basic Go fixtures
create_go_basic_fixtures() {
    local fixtures_dir=$1
    
    # Sample JSON data
    cat > "$fixtures_dir/users.json" <<EOF
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john.doe@example.com",
    "age": 30,
    "active": true,
    "roles": ["user"]
  },
  {
    "id": 2,
    "name": "Jane Admin",
    "email": "jane.admin@example.com",
    "age": 35,
    "active": true,
    "roles": ["admin", "user"]
  }
]
EOF
    
    # Sample configuration
    cat > "$fixtures_dir/config.json" <<EOF
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "name": "test_db"
  },
  "api": {
    "baseURL": "https://api.example.com",
    "timeout": "5s"
  }
}
EOF
}

# Create Go test helpers
create_go_test_helpers() {
    local project_dir=$1
    
    cat > "$project_dir/testhelpers_test.go" <<EOF
package main

import (
    "encoding/json"
    "io/ioutil"
    "net/http"
    "net/http/httptest"
    "os"
    "path/filepath"
    "testing"
)

// TestHelper provides common testing utilities
type TestHelper struct {
    t *testing.T
}

// NewTestHelper creates a new test helper
func NewTestHelper(t *testing.T) *TestHelper {
    return &TestHelper{t: t}
}

// LoadFixture loads JSON fixture data
func (h *TestHelper) LoadFixture(filename string, v interface{}) {
    path := filepath.Join("testdata", filename)
    data, err := ioutil.ReadFile(path)
    if err != nil {
        h.t.Fatalf("Failed to load fixture %s: %v", filename, err)
    }
    
    if err := json.Unmarshal(data, v); err != nil {
        h.t.Fatalf("Failed to parse fixture %s: %v", filename, err)
    }
}

// CreateTempFile creates a temporary file with content
func (h *TestHelper) CreateTempFile(content string) string {
    tmpfile, err := ioutil.TempFile("", "test")
    if err != nil {
        h.t.Fatalf("Failed to create temp file: %v", err)
    }
    
    if _, err := tmpfile.Write([]byte(content)); err != nil {
        h.t.Fatalf("Failed to write to temp file: %v", err)
    }
    
    if err := tmpfile.Close(); err != nil {
        h.t.Fatalf("Failed to close temp file: %v", err)
    }
    
    return tmpfile.Name()
}

// CleanupTempFile removes a temporary file
func (h *TestHelper) CleanupTempFile(filename string) {
    if err := os.Remove(filename); err != nil {
        h.t.Logf("Warning: Failed to cleanup temp file %s: %v", filename, err)
    }
}

// CreateTestServer creates a test HTTP server
func (h *TestHelper) CreateTestServer(handler http.Handler) *httptest.Server {
    return httptest.NewServer(handler)
}

// AssertEqual checks if two values are equal
func (h *TestHelper) AssertEqual(got, want interface{}) {
    if got != want {
        h.t.Errorf("got %v, want %v", got, want)
    }
}

// AssertNotNil checks if value is not nil
func (h *TestHelper) AssertNotNil(v interface{}) {
    if v == nil {
        h.t.Error("expected non-nil value")
    }
}

// AssertError checks if error occurred
func (h *TestHelper) AssertError(err error) {
    if err == nil {
        h.t.Error("expected error but got nil")
    }
}

// AssertNoError checks if no error occurred
func (h *TestHelper) AssertNoError(err error) {
    if err != nil {
        h.t.Errorf("expected no error but got: %v", err)
    }
}
EOF
}

# Create RSpec fixtures
create_rspec_fixtures() {
    local project_dir=$1
    local fixture_type=$2
    
    local fixtures_dir="$project_dir/spec/fixtures"
    mkdir -p "$fixtures_dir"
    
    case "$fixture_type" in
        "basic")
            create_rspec_basic_fixtures "$fixtures_dir"
            ;;
        "api")
            create_rspec_api_fixtures "$fixtures_dir"
            ;;
        *)
            create_rspec_basic_fixtures "$fixtures_dir"
            ;;
    esac
    
    # Create spec helper
    create_rspec_spec_helper "$project_dir/spec"
    
    echo "RSpec fixtures created in: $fixtures_dir"
}

# Create basic RSpec fixtures
create_rspec_basic_fixtures() {
    local fixtures_dir=$1
    
    # Sample YAML fixtures
    cat > "$fixtures_dir/users.yml" <<EOF
valid_user:
  id: 1
  name: "John Doe"
  email: "john.doe@example.com"
  age: 30
  active: true
  roles:
    - "user"

admin_user:
  id: 2
  name: "Jane Admin"
  email: "jane.admin@example.com"
  age: 35
  active: true
  roles:
    - "admin"
    - "user"

inactive_user:
  id: 3
  name: "Bob Inactive"
  email: "bob.inactive@example.com"
  age: 25
  active: false
  roles:
    - "user"
EOF
    
    # Sample JSON fixtures
    cat > "$fixtures_dir/config.json" <<EOF
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "name": "test_db"
  },
  "api": {
    "base_url": "https://api.example.com",
    "timeout": 5000
  }
}
EOF
}

# Create RSpec spec helper
create_rspec_spec_helper() {
    local spec_dir=$1
    
    cat > "$spec_dir/spec_helper.rb" <<EOF
# RSpec configuration and helpers
require 'yaml'
require 'json'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end

# Helper methods for fixtures
module FixtureHelpers
  def load_fixture(filename)
    fixture_path = File.join(File.dirname(__FILE__), 'fixtures', filename)
    
    case File.extname(filename)
    when '.yml', '.yaml'
      YAML.load_file(fixture_path)
    when '.json'
      JSON.parse(File.read(fixture_path))
    else
      File.read(fixture_path)
    end
  end
  
  def sample_user
    load_fixture('users.yml')['valid_user']
  end
  
  def admin_user
    load_fixture('users.yml')['admin_user']
  end
  
  def sample_config
    load_fixture('config.json')
  end
  
  def create_temp_file(content, extension = '.tmp')
    require 'tempfile'
    
    temp_file = Tempfile.new(['test', extension])
    temp_file.write(content)
    temp_file.close
    temp_file.path
  end
  
  def cleanup_temp_file(path)
    File.unlink(path) if File.exist?(path)
  rescue Errno::ENOENT
    # File already deleted, ignore
  end
end

RSpec.configure do |config|
  config.include FixtureHelpers
end
EOF
}

# Manage test environment setup
setup_test_environment() {
    local framework=$1
    local project_dir=${2:-.}
    local environment=${3:-"test"}
    
    echo "=== SETTING UP TEST ENVIRONMENT ==="
    echo "Framework: $framework"
    echo "Environment: $environment"
    echo ""
    
    case "$framework" in
        "jest")
            setup_jest_environment "$project_dir" "$environment"
            ;;
        "pytest")
            setup_pytest_environment "$project_dir" "$environment"
            ;;
        "go-test")
            setup_go_environment "$project_dir" "$environment"
            ;;
        "rspec")
            setup_rspec_environment "$project_dir" "$environment"
            ;;
    esac
}

# Setup Jest test environment
setup_jest_environment() {
    local project_dir=$1
    local environment=$2
    
    # Create environment-specific configuration
    local env_file="$project_dir/.env.test"
    
    cat > "$env_file" <<EOF
# Test environment configuration
NODE_ENV=test
LOG_LEVEL=silent
DATABASE_URL=sqlite::memory:
API_BASE_URL=http://localhost:3000
CACHE_ENABLED=false
EOF
    
    # Create Jest setup file
    local setup_file="$project_dir/jest.setup.js"
    
    cat > "$setup_file" <<EOF
// Jest setup file
require('dotenv').config({ path: '.env.test' });

// Global test setup
beforeAll(() => {
  // Setup global test state
  global.testStartTime = Date.now();
});

afterAll(() => {
  // Cleanup global test state
  const duration = Date.now() - global.testStartTime;
  console.log(\`Test suite completed in \${duration}ms\`);
});

// Mock console methods in test environment
if (process.env.NODE_ENV === 'test') {
  global.console = {
    ...console,
    log: jest.fn(),
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
  };
}
EOF
    
    echo "Jest test environment configured"
}

# Setup pytest test environment
setup_pytest_environment() {
    local project_dir=$1
    local environment=$2
    
    # Create pytest configuration
    local pytest_ini="$project_dir/pytest.ini"
    
    cat > "$pytest_ini" <<EOF
[tool:pytest]
testpaths = tests
python_files = test_*.py *_test.py
python_classes = Test*
python_functions = test_*
addopts = 
    --verbose
    --tb=short
    --strict-markers
    --cov=.
    --cov-report=html
    --cov-report=term-missing
markers =
    unit: Unit tests
    integration: Integration tests
    slow: Slow running tests
    api: API tests
filterwarnings =
    ignore::DeprecationWarning
    ignore::PendingDeprecationWarning
EOF
    
    echo "Pytest test environment configured"
}

# Clean up test fixtures and temporary data
cleanup_test_fixtures() {
    local project_dir=${1:-.}
    local framework=${2:-"auto"}
    
    echo "=== CLEANING UP TEST FIXTURES ==="
    echo "Project Directory: $project_dir"
    echo ""
    
    # Framework-specific cleanup
    case "$framework" in
        "jest")
            cleanup_jest_fixtures "$project_dir"
            ;;
        "pytest")
            cleanup_pytest_fixtures "$project_dir"
            ;;
        "go-test")
            cleanup_go_fixtures "$project_dir"
            ;;
        "rspec")
            cleanup_rspec_fixtures "$project_dir"
            ;;
        "auto"|*)
            # Generic cleanup
            cleanup_generic_fixtures "$project_dir"
            ;;
    esac
    
    echo "Test fixture cleanup completed"
}

# Generic fixture cleanup
cleanup_generic_fixtures() {
    local project_dir=$1
    
    # Remove temporary test files
    find "$project_dir" -name "*.tmp" -type f -delete 2>/dev/null || true
    find "$project_dir" -name "test_*.temp" -type f -delete 2>/dev/null || true
    
    # Remove test databases
    find "$project_dir" -name "test.db" -type f -delete 2>/dev/null || true
    find "$project_dir" -name "*.test.sqlite" -type f -delete 2>/dev/null || true
    
    # Remove test logs
    find "$project_dir" -name "test*.log" -type f -delete 2>/dev/null || true
    
    # Remove coverage artifacts (keep reports)
    find "$project_dir" -name ".coverage.*" -type f -delete 2>/dev/null || true
    
    echo "Generic cleanup completed"
}

# Cleanup Jest fixtures
cleanup_jest_fixtures() {
    local project_dir=$1
    
    # Remove Jest cache
    rm -rf "$project_dir/.jest" 2>/dev/null || true
    
    # Remove temporary snapshots
    find "$project_dir" -name "__snapshots__" -type d -exec rm -rf {} + 2>/dev/null || true
    
    echo "Jest cleanup completed"
}

# Cleanup pytest fixtures
cleanup_pytest_fixtures() {
    local project_dir=$1
    
    # Remove pytest cache
    rm -rf "$project_dir/.pytest_cache" 2>/dev/null || true
    
    # Remove Python cache files
    find "$project_dir" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
    find "$project_dir" -name "*.pyc" -type f -delete 2>/dev/null || true
    
    echo "Pytest cleanup completed"
}
```