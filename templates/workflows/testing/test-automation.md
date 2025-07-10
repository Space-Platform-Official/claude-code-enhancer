# Test Automation Workflow

## Overview
This workflow template provides comprehensive testing strategies across different languages and frameworks.

## Test Categories

### 1. Unit Tests
Fast, isolated tests for individual components.

```yaml
# Example configuration
unit_tests:
  coverage_threshold: 80
  parallel: true
  fail_fast: false
```

### 2. Integration Tests
Tests for component interactions.

```yaml
integration_tests:
  database: true
  external_services: mocked
  timeout: 300s
```

### 3. End-to-End Tests
Full user journey validation.

```yaml
e2e_tests:
  browsers: [chrome, firefox, safari]
  viewport_sizes: [[1920, 1080], [375, 667]]
  retry_failed: 2
```

## Language-Specific Templates

### Rust Testing
```rust
// tests/integration_test.rs
use tokio::test;

#[test]
async fn test_api_endpoint() {
    let app = create_test_app().await;
    let response = app.get("/api/health").await;
    assert_eq!(response.status(), 200);
}
```

### TypeScript Testing
```typescript
// __tests__/api.test.ts
import { createTestServer } from '../test-utils';

describe('API Endpoints', () => {
  let server: TestServer;
  
  beforeAll(async () => {
    server = await createTestServer();
  });
  
  afterAll(async () => {
    await server.close();
  });
  
  it('should return user data', async () => {
    const response = await server.get('/api/users/123');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('id', '123');
  });
});
```

### Go Testing
```go
// api_test.go
func TestAPIEndpoint(t *testing.T) {
    router := setupTestRouter()
    
    t.Run("GET /api/health", func(t *testing.T) {
        req := httptest.NewRequest("GET", "/api/health", nil)
        w := httptest.NewRecorder()
        router.ServeHTTP(w, req)
        
        assert.Equal(t, http.StatusOK, w.Code)
    })
}
```

### Python Testing
```python
# test_api.py
import pytest
from fastapi.testclient import TestClient

@pytest.fixture
def client():
    from main import app
    return TestClient(app)

def test_health_endpoint(client):
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}
```

## Test Data Management

### Fixtures
```yaml
fixtures:
  users:
    - id: "test-user-1"
      name: "Test User"
      email: "test@example.com"
  
  products:
    - id: "test-product-1"
      name: "Test Product"
      price: 99.99
```

### Mocking Strategy
```yaml
mocks:
  external_apis:
    - service: payment_gateway
      responses:
        success: { status: "approved", transaction_id: "mock-123" }
        failure: { status: "declined", reason: "insufficient_funds" }
  
  databases:
    - type: redis
      data:
        "session:123": { user_id: "test-user-1", expires: 3600 }
```

## Continuous Testing

### Watch Mode Configuration
```json
{
  "watch": {
    "patterns": ["src/**/*.{ts,js}", "tests/**/*.{ts,js}"],
    "ignore": ["node_modules", "dist"],
    "delay": 100
  }
}
```

### Parallel Execution
```yaml
parallel:
  max_workers: 4
  distribution: "round-robin"
  isolation: "process"
```

## Performance Testing

### Load Testing Template
```yaml
load_test:
  scenarios:
    - name: "Normal Load"
      users: 100
      duration: "5m"
      ramp_up: "30s"
    
    - name: "Peak Load"
      users: 1000
      duration: "10m"
      ramp_up: "2m"
  
  thresholds:
    response_time_p95: 500ms
    error_rate: 0.01
    throughput: 1000
```

## Test Reports

### Coverage Reports
```yaml
coverage:
  formats: [html, lcov, json]
  output_dir: coverage/
  exclude_patterns:
    - "**/*.test.*"
    - "**/test_*.py"
    - "**/__tests__/**"
```

### Test Results Format
```yaml
reports:
  junit:
    enabled: true
    path: "test-results/junit.xml"
  
  allure:
    enabled: true
    path: "allure-results/"
  
  custom:
    format: "json"
    include_logs: true
    include_screenshots: true
```