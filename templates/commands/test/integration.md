---
allowed-tools: all
description: Orchestrate integration tests with service dependency management and cross-system validation
intensity: ⚡⚡⚡⚡
pattern: 🔗🔗🔗🔗
---

# 🔗🔗🔗🔗 CRITICAL INTEGRATION TEST ORCHESTRATION: COMPREHENSIVE SYSTEM VALIDATION! 🔗🔗🔗🔗

**THIS IS NOT A SIMPLE TEST RUN - THIS IS A COMPREHENSIVE INTEGRATION TESTING SYSTEM!**

When you run `/test integration`, you are REQUIRED to:

1. **ORCHESTRATE** integration tests across multiple services and systems
2. **MANAGE** service dependencies and test environment setup
3. **VALIDATE** cross-system communication and data flow
4. **USE MULTIPLE AGENTS** for parallel integration testing:
   - Spawn one agent per service or integration point
   - Spawn agents for different integration types (API, database, message queue)
   - Say: "I'll spawn multiple agents to orchestrate integration tests across all system boundaries"
5. **COORDINATE** test execution sequence and dependency management
6. **VERIFY** system behavior under realistic conditions

## 🎯 USE MULTIPLE AGENTS

**MANDATORY AGENT SPAWNING FOR INTEGRATION TEST ORCHESTRATION:**
```
"I'll spawn multiple agents to handle integration testing comprehensively:
- Service Orchestration Agent: Manage service startup and dependency coordination
- API Integration Agent: Test REST/GraphQL APIs and service communication
- Database Integration Agent: Validate data persistence and consistency
- Message Queue Agent: Test async communication and event processing
- Environment Agent: Setup and teardown test environments
- Monitoring Agent: Track integration test health and performance"
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ Run integration tests without proper service setup → NO! Environment is critical!
- ❌ "Unit tests cover this" → NO! Integration tests verify system behavior!
- ❌ Skip database/external service tests → NO! Test real integrations!
- ❌ Ignore test data management → NO! Proper test data is essential!
- ❌ Run tests against production systems → NO! Use dedicated test environments!
- ❌ "Mock everything" → NO! Test real service interactions!

**MANDATORY WORKFLOW:**
```
1. Environment setup → Start services and dependencies
2. IMMEDIATELY spawn agents for parallel integration testing
3. Service dependency validation → Verify all services are ready
4. Execute integration tests → Run cross-system validation
5. Data consistency verification → Check data integrity
6. VERIFY system behavior under load and failure scenarios
```

**YOU ARE NOT DONE UNTIL:**
- ✅ ALL integration tests are passing
- ✅ Service dependencies are properly managed
- ✅ Cross-system communication is validated
- ✅ Data consistency is verified
- ✅ Error handling and recovery is tested
- ✅ Performance under realistic load is acceptable

---

🛑 **MANDATORY INTEGRATION TEST ORCHESTRATION CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current system architecture and service dependencies
3. Verify you understand the integration testing requirements

Execute comprehensive integration test orchestration for: $ARGUMENTS

**FORBIDDEN SHORTCUT PATTERNS:**
- "Integration tests are too complex" → NO, they're essential for system quality
- "Services are already tested individually" → NO, test interactions
- "Database tests are optional" → NO, data consistency is critical
- "Test environments are hard to setup" → NO, automate the setup
- "Mocking is easier than real services" → NO, test real integrations

Let me ultrathink about the comprehensive integration testing architecture and orchestration strategy.

🚨 **REMEMBER: Integration tests verify that your system works as a whole!** 🚨

**Comprehensive Integration Test Orchestration Protocol:**

**Step 0: System Architecture Analysis**
- Map all service dependencies and integration points
- Identify external systems and third-party services
- Analyze data flow and communication patterns
- Document API contracts and message formats
- Assess service startup order and dependencies

**Step 1: Test Environment Infrastructure**

**Service Dependency Management:**
```yaml
integration_test_environment:
  services:
    database:
      type: postgresql
      version: "14"
      setup_script: "scripts/setup-test-db.sql"
      cleanup_script: "scripts/cleanup-test-db.sql"
      
    redis:
      type: redis
      version: "7"
      configuration: "config/redis-test.conf"
      
    message_queue:
      type: rabbitmq
      version: "3.11"
      exchanges: ["orders", "notifications", "payments"]
      
    external_services:
      payment_gateway:
        type: mock
        endpoint: "http://localhost:8080/mock-payment"
        
      email_service:
        type: mock
        endpoint: "http://localhost:8081/mock-email"
        
  startup_sequence:
    - database
    - redis
    - message_queue
    - external_service_mocks
    - application_services
```

**Docker Compose Integration Testing:**
```yaml
version: '3.8'
services:
  test-database:
    image: postgres:14
    environment:
      POSTGRES_DB: test_db
      POSTGRES_USER: test_user
      POSTGRES_PASSWORD: test_pass
    ports:
      - "5432:5432"
    volumes:
      - ./test-data:/docker-entrypoint-initdb.d
      
  test-redis:
    image: redis:7
    ports:
      - "6379:6379"
      
  test-app:
    build: .
    depends_on:
      - test-database
      - test-redis
    environment:
      DATABASE_URL: postgres://test_user:test_pass@test-database:5432/test_db
      REDIS_URL: redis://test-redis:6379
      TEST_MODE: "true"
    ports:
      - "8000:8000"
```

**Step 2: Service Health and Readiness Validation**

**Service Health Monitoring:**
```typescript
interface ServiceHealthCheck {
  service_name: string;
  endpoint: string;
  expected_status: number;
  timeout: number;
  retry_count: number;
  dependencies: string[];
}

const validateServiceHealth = async (checks: ServiceHealthCheck[]): Promise<boolean> => {
  const results = await Promise.all(
    checks.map(async (check) => {
      let attempts = 0;
      while (attempts < check.retry_count) {
        try {
          const response = await fetch(check.endpoint, {
            timeout: check.timeout
          });
          
          if (response.status === check.expected_status) {
            console.log(`✅ ${check.service_name} is healthy`);
            return true;
          }
        } catch (error) {
          console.log(`⚠️  ${check.service_name} health check failed: ${error.message}`);
        }
        
        attempts++;
        await sleep(1000 * attempts); // Exponential backoff
      }
      
      console.log(`❌ ${check.service_name} failed health checks`);
      return false;
    })
  );
  
  return results.every(result => result);
};
```

**Database Readiness Validation:**
```typescript
const validateDatabaseReadiness = async (connectionString: string): Promise<boolean> => {
  try {
    const client = new Client(connectionString);
    await client.connect();
    
    // Test basic operations
    await client.query('SELECT 1');
    await client.query('SELECT COUNT(*) FROM pg_tables');
    
    await client.end();
    return true;
  } catch (error) {
    console.log(`Database readiness check failed: ${error.message}`);
    return false;
  }
};
```

**Step 3: Parallel Agent Deployment for Integration Testing**

**Agent Spawning Strategy:**
```
"I've identified 6 major integration points in the system. I'll spawn specialized agents:

1. **API Integration Agent**: 'Test REST API endpoints and GraphQL resolvers'
2. **Database Integration Agent**: 'Validate database operations and data consistency'
3. **Message Queue Agent**: 'Test async messaging and event processing'
4. **External Service Agent**: 'Test third-party service integrations'
5. **Authentication Agent**: 'Validate user authentication and authorization flows'
6. **File Storage Agent**: 'Test file upload, storage, and retrieval operations'
7. **Monitoring Agent**: 'Monitor system health and performance during tests'

Each agent will run integration tests in parallel while coordinating shared resources."
```

**Step 4: API Integration Testing**

**REST API Integration Tests:**
```typescript
interface APIIntegrationTest {
  name: string;
  method: 'GET' | 'POST' | 'PUT' | 'DELETE';
  endpoint: string;
  headers?: Record<string, string>;
  body?: any;
  expected_status: number;
  expected_response?: any;
  setup?: () => Promise<void>;
  cleanup?: () => Promise<void>;
  dependencies?: string[];
}

const executeAPIIntegrationTests = async (tests: APIIntegrationTest[]) => {
  const results = [];
  
  for (const test of tests) {
    console.log(`🔍 Running API integration test: ${test.name}`);
    
    try {
      // Setup test data
      if (test.setup) {
        await test.setup();
      }
      
      // Execute API call
      const response = await fetch(test.endpoint, {
        method: test.method,
        headers: test.headers || {},
        body: test.body ? JSON.stringify(test.body) : undefined
      });
      
      // Validate response
      const isStatusValid = response.status === test.expected_status;
      const responseData = await response.json();
      
      let isResponseValid = true;
      if (test.expected_response) {
        isResponseValid = deepEqual(responseData, test.expected_response);
      }
      
      const success = isStatusValid && isResponseValid;
      
      results.push({
        test_name: test.name,
        success: success,
        actual_status: response.status,
        expected_status: test.expected_status,
        response_data: responseData,
        error: success ? null : 'Status or response validation failed'
      });
      
      console.log(`${success ? '✅' : '❌'} ${test.name}`);
      
    } catch (error) {
      results.push({
        test_name: test.name,
        success: false,
        error: error.message
      });
      
      console.log(`❌ ${test.name}: ${error.message}`);
    } finally {
      // Cleanup test data
      if (test.cleanup) {
        await test.cleanup();
      }
    }
  }
  
  return results;
};
```

**GraphQL Integration Testing:**
```typescript
const executeGraphQLIntegrationTests = async (tests: GraphQLIntegrationTest[]) => {
  const client = new GraphQLClient(process.env.GRAPHQL_ENDPOINT);
  
  for (const test of tests) {
    try {
      const result = await client.request(test.query, test.variables);
      
      // Validate response structure and data
      const isValid = validateGraphQLResponse(result, test.expected_response);
      
      console.log(`${isValid ? '✅' : '❌'} GraphQL test: ${test.name}`);
      
    } catch (error) {
      console.log(`❌ GraphQL test ${test.name}: ${error.message}`);
    }
  }
};
```

**Step 5: Database Integration Testing**

**Database Integration Test Framework:**
```typescript
interface DatabaseIntegrationTest {
  name: string;
  setup_queries: string[];
  test_query: string;
  expected_result: any;
  cleanup_queries: string[];
  transaction_test: boolean;
}

const executeDatabaseIntegrationTests = async (tests: DatabaseIntegrationTest[]) => {
  const client = new Client(process.env.DATABASE_URL);
  await client.connect();
  
  for (const test of tests) {
    console.log(`🗄️  Running database integration test: ${test.name}`);
    
    try {
      // Begin transaction for test isolation
      if (test.transaction_test) {
        await client.query('BEGIN');
      }
      
      // Setup test data
      for (const setupQuery of test.setup_queries) {
        await client.query(setupQuery);
      }
      
      // Execute test query
      const result = await client.query(test.test_query);
      
      // Validate result
      const isValid = validateDatabaseResult(result, test.expected_result);
      
      console.log(`${isValid ? '✅' : '❌'} ${test.name}`);
      
      // Cleanup
      if (test.transaction_test) {
        await client.query('ROLLBACK');
      } else {
        for (const cleanupQuery of test.cleanup_queries) {
          await client.query(cleanupQuery);
        }
      }
      
    } catch (error) {
      console.log(`❌ Database test ${test.name}: ${error.message}`);
      
      if (test.transaction_test) {
        await client.query('ROLLBACK');
      }
    }
  }
  
  await client.end();
};
```

**Data Consistency Validation:**
```typescript
const validateDataConsistency = async () => {
  const checks = [
    {
      name: 'User-Order Consistency',
      query: `
        SELECT u.id, u.email, COUNT(o.id) as order_count
        FROM users u
        LEFT JOIN orders o ON u.id = o.user_id
        WHERE u.deleted_at IS NULL
        GROUP BY u.id, u.email
        HAVING COUNT(o.id) != (
          SELECT COUNT(*) FROM orders WHERE user_id = u.id AND deleted_at IS NULL
        )
      `,
      expected_empty: true
    },
    {
      name: 'Order-Payment Consistency',
      query: `
        SELECT o.id, o.status, p.status as payment_status
        FROM orders o
        JOIN payments p ON o.id = p.order_id
        WHERE o.status = 'paid' AND p.status != 'completed'
      `,
      expected_empty: true
    }
  ];
  
  for (const check of checks) {
    const result = await client.query(check.query);
    const isConsistent = check.expected_empty ? result.rows.length === 0 : true;
    
    console.log(`${isConsistent ? '✅' : '❌'} ${check.name}`);
    
    if (!isConsistent) {
      console.log('Inconsistent data found:', result.rows);
    }
  }
};
```

**Step 6: Message Queue Integration Testing**

**Message Queue Test Framework:**
```typescript
interface MessageQueueTest {
  name: string;
  exchange: string;
  routing_key: string;
  message: any;
  expected_consumers: string[];
  timeout: number;
  validation: (consumedMessages: any[]) => boolean;
}

const executeMessageQueueTests = async (tests: MessageQueueTest[]) => {
  const connection = await amqp.connect(process.env.RABBITMQ_URL);
  const channel = await connection.createChannel();
  
  for (const test of tests) {
    console.log(`📬 Running message queue test: ${test.name}`);
    
    try {
      // Setup message consumers
      const consumedMessages = [];
      const consumerPromises = test.expected_consumers.map(async (consumerQueue) => {
        return new Promise((resolve) => {
          channel.consume(consumerQueue, (msg) => {
            if (msg) {
              consumedMessages.push({
                queue: consumerQueue,
                content: JSON.parse(msg.content.toString()),
                timestamp: new Date()
              });
              channel.ack(msg);
            }
          });
          
          setTimeout(resolve, test.timeout);
        });
      });
      
      // Publish test message
      await channel.publish(
        test.exchange,
        test.routing_key,
        Buffer.from(JSON.stringify(test.message))
      );
      
      // Wait for consumers to process
      await Promise.all(consumerPromises);
      
      // Validate consumed messages
      const isValid = test.validation(consumedMessages);
      
      console.log(`${isValid ? '✅' : '❌'} ${test.name}`);
      
    } catch (error) {
      console.log(`❌ Message queue test ${test.name}: ${error.message}`);
    }
  }
  
  await connection.close();
};
```

**Step 7: External Service Integration Testing**

**External Service Mock Setup:**
```typescript
interface ExternalServiceMock {
  service_name: string;
  base_url: string;
  endpoints: MockEndpoint[];
  authentication?: {
    type: 'api_key' | 'oauth' | 'basic';
    credentials: any;
  };
}

interface MockEndpoint {
  path: string;
  method: string;
  response: any;
  status: number;
  delay?: number;
  failure_rate?: number;
}

const setupExternalServiceMocks = async (mocks: ExternalServiceMock[]) => {
  for (const mock of mocks) {
    console.log(`🔧 Setting up mock for ${mock.service_name}`);
    
    // Setup mock server endpoints
    const mockServer = express();
    
    mock.endpoints.forEach(endpoint => {
      mockServer[endpoint.method.toLowerCase()](endpoint.path, (req, res) => {
        // Simulate network delay
        setTimeout(() => {
          // Simulate failure rate
          if (endpoint.failure_rate && Math.random() < endpoint.failure_rate) {
            res.status(500).json({ error: 'Simulated service failure' });
            return;
          }
          
          res.status(endpoint.status).json(endpoint.response);
        }, endpoint.delay || 0);
      });
    });
    
    mockServer.listen(getMockPort(mock.service_name));
  }
};
```

**Third-Party Service Integration Tests:**
```typescript
const executeExternalServiceTests = async (tests: ExternalServiceTest[]) => {
  for (const test of tests) {
    console.log(`🌐 Running external service test: ${test.name}`);
    
    try {
      // Setup test conditions
      if (test.setup) {
        await test.setup();
      }
      
      // Execute service call through application
      const result = await test.execute();
      
      // Validate integration behavior
      const isValid = test.validate(result);
      
      console.log(`${isValid ? '✅' : '❌'} ${test.name}`);
      
    } catch (error) {
      console.log(`❌ External service test ${test.name}: ${error.message}`);
    }
  }
};
```

**Step 8: End-to-End Workflow Testing**

**Complete User Journey Testing:**
```typescript
interface WorkflowTest {
  name: string;
  steps: WorkflowStep[];
  expected_final_state: any;
  rollback_steps?: WorkflowStep[];
}

interface WorkflowStep {
  name: string;
  action: () => Promise<any>;
  validation: (result: any) => boolean;
  depends_on?: string[];
}

const executeWorkflowTests = async (tests: WorkflowTest[]) => {
  for (const test of tests) {
    console.log(`🔄 Running workflow test: ${test.name}`);
    
    try {
      const stepResults = {};
      
      for (const step of test.steps) {
        console.log(`  📝 Executing step: ${step.name}`);
        
        // Check dependencies
        if (step.depends_on) {
          const dependenciesMet = step.depends_on.every(dep => 
            stepResults[dep] && stepResults[dep].success
          );
          
          if (!dependenciesMet) {
            throw new Error(`Dependencies not met for step: ${step.name}`);
          }
        }
        
        // Execute step
        const result = await step.action();
        const isValid = step.validation(result);
        
        stepResults[step.name] = {
          success: isValid,
          result: result
        };
        
        console.log(`    ${isValid ? '✅' : '❌'} ${step.name}`);
        
        if (!isValid) {
          throw new Error(`Step validation failed: ${step.name}`);
        }
      }
      
      // Validate final state
      const finalStateValid = validateFinalState(test.expected_final_state);
      
      console.log(`${finalStateValid ? '✅' : '❌'} Workflow: ${test.name}`);
      
    } catch (error) {
      console.log(`❌ Workflow test ${test.name}: ${error.message}`);
      
      // Execute rollback if defined
      if (test.rollback_steps) {
        console.log('  🔄 Executing rollback steps...');
        for (const rollbackStep of test.rollback_steps) {
          try {
            await rollbackStep.action();
          } catch (rollbackError) {
            console.log(`⚠️  Rollback step failed: ${rollbackError.message}`);
          }
        }
      }
    }
  }
};
```

**Step 9: Performance and Load Testing**

**Integration Performance Testing:**
```typescript
interface PerformanceTest {
  name: string;
  concurrent_users: number;
  test_duration: number;
  endpoints: PerformanceEndpoint[];
  success_criteria: {
    max_response_time: number;
    min_throughput: number;
    max_error_rate: number;
  };
}

const executePerformanceTests = async (tests: PerformanceTest[]) => {
  for (const test of tests) {
    console.log(`⚡ Running performance test: ${test.name}`);
    
    const metrics = {
      total_requests: 0,
      successful_requests: 0,
      failed_requests: 0,
      response_times: [],
      start_time: Date.now()
    };
    
    // Create concurrent user simulation
    const userPromises = Array.from({ length: test.concurrent_users }, 
      () => simulateUserLoad(test.endpoints, test.test_duration, metrics)
    );
    
    await Promise.all(userPromises);
    
    // Analyze performance metrics
    const results = analyzePerformanceMetrics(metrics, test.success_criteria);
    
    console.log(`${results.passed ? '✅' : '❌'} Performance test: ${test.name}`);
    console.log(`  Response time: ${results.avg_response_time}ms`);
    console.log(`  Throughput: ${results.throughput} req/s`);
    console.log(`  Error rate: ${results.error_rate}%`);
  }
};
```

**Step 10: Integration Test Reporting**

**Comprehensive Test Report Generation:**
```typescript
interface IntegrationTestReport {
  summary: {
    total_tests: number;
    passed: number;
    failed: number;
    duration: number;
    environment: string;
  };
  service_health: ServiceHealthReport[];
  api_tests: APITestResult[];
  database_tests: DatabaseTestResult[];
  message_queue_tests: MessageQueueTestResult[];
  external_service_tests: ExternalServiceTestResult[];
  workflow_tests: WorkflowTestResult[];
  performance_tests: PerformanceTestResult[];
  recommendations: string[];
}

const generateIntegrationTestReport = (results: any): IntegrationTestReport => {
  return {
    summary: compileSummary(results),
    service_health: compileServiceHealth(results),
    api_tests: compileAPIResults(results),
    database_tests: compileDatabaseResults(results),
    message_queue_tests: compileMessageQueueResults(results),
    external_service_tests: compileExternalServiceResults(results),
    workflow_tests: compileWorkflowResults(results),
    performance_tests: compilePerformanceResults(results),
    recommendations: generateRecommendations(results)
  };
};
```

**Integration Test Quality Checklist:**
- [ ] All integration tests are passing
- [ ] Service dependencies are properly managed
- [ ] API endpoints are thoroughly tested
- [ ] Database operations are validated
- [ ] Message queue communication is tested
- [ ] External service integrations are verified
- [ ] Complete user workflows are tested
- [ ] Performance under load is acceptable
- [ ] Error handling and recovery is tested
- [ ] Test environments are properly isolated

**Agent Coordination for Complex Systems:**
```
"For comprehensive integration testing, I'll coordinate multiple specialized agents:

Primary Integration Agent: Overall test orchestration and coordination
├── Environment Agent: Service startup and dependency management
├── API Agent: REST/GraphQL endpoint testing
├── Database Agent: Data persistence and consistency validation
├── Message Queue Agent: Async communication testing
├── External Service Agent: Third-party integration testing
├── Workflow Agent: End-to-end user journey testing
├── Performance Agent: Load and stress testing
└── Report Agent: Comprehensive test reporting and analysis

Each agent will coordinate with others to ensure proper test isolation and comprehensive coverage."
```

**Anti-Patterns to Avoid:**
- ❌ Testing against production systems (data corruption risk)
- ❌ Ignoring service startup order (test environment failures)
- ❌ Poor test data management (test interference)
- ❌ Mocking critical integrations (missing real-world issues)
- ❌ Sequential test execution (slow feedback loops)
- ❌ Incomplete error scenario testing (production failures)

**Final Verification:**
Before completing integration test orchestration:
- Are all integration tests passing successfully?
- Are service dependencies properly managed?
- Is cross-system communication validated?
- Are performance requirements met?
- Are error scenarios thoroughly tested?
- Are test environments properly isolated?

**Final Commitment:**
- **I will**: Orchestrate comprehensive integration tests with proper service management
- **I will**: Use multiple agents for parallel integration testing
- **I will**: Validate all system integrations and data consistency
- **I will**: Test performance and error scenarios thoroughly
- **I will NOT**: Skip complex integration scenarios
- **I will NOT**: Test against production systems
- **I will NOT**: Ignore service dependency management

**REMEMBER:**
This is INTEGRATION TEST ORCHESTRATION mode - comprehensive cross-system validation, proper service management, and thorough integration testing. The goal is to ensure all system components work together correctly.

Executing comprehensive integration test orchestration protocol for complete system validation...