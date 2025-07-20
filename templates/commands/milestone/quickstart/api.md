---
allowed-tools: all
description: API development milestone template - Backend-focused with clear development flow
---

# 🔌 API Development Milestone Template

**Backend-focused milestone for APIs, microservices, and data processing. Clear development pipeline.**

## 🎯 What This Template Does

✅ **Creates API-focused milestone structure** with backend best practices  
✅ **Built-in testing gates** for reliable API development  
✅ **Clear development pipeline** from design to deployment  
✅ **Documentation-driven** approach for maintainable APIs  

---

## 🚀 Quick Setup

```bash
# Create your API milestone
/milestone/quickstart/api "Your API project description"

# Example:
/milestone/quickstart/api "User authentication microservice"
```

**Ready to code!** Your API development pipeline is set up with testing and documentation built-in.

---

## 📋 API Development Structure

### **Phase 1: API Design (Days 1-2)**
- **Focus**: Design before you code
- **Outcome**: Clear API specification and architecture
- **Key**: Get the interface right first

### **Phase 2: Core Implementation (Days 3-6)**  
- **Focus**: Build the core API functionality
- **Outcome**: Working endpoints with validation
- **Key**: Test as you build

### **Phase 3: Testing & Security (Days 7-8)**
- **Focus**: Comprehensive testing and security hardening
- **Outcome**: Production-ready, secure API
- **Key**: Quality and security gates

### **Phase 4: Documentation & Deployment (Days 9-10)**
- **Focus**: Documentation and deployment pipeline
- **Outcome**: Deployed API with complete documentation
- **Key**: Maintainable and discoverable

---

## 🎯 Milestone Configuration

```yaml
milestone:
  id: "api-$(date +%Y%m%d-%H%M%S)"
  title: "$ARGUMENTS"
  type: "api_development"
  duration: "10 days"
  complexity: "backend_focused"
  
  # API development settings
  api_focus:
    testing_first: true
    documentation_driven: true
    security_gates: true
    deployment_ready: true
    
  # Backend-specific tracking
  tracking:
    method: "test_driven"
    coverage_target: 85
    security_scans: true
    performance_benchmarks: true
    
  phases:
    - name: "API Design"
      duration: "2 days"
      focus: "specification_and_architecture"
      testing: "design_validation"
      
    - name: "Core Implementation"
      duration: "4 days"
      focus: "endpoint_development"
      testing: "unit_and_integration"
      
    - name: "Testing & Security"
      duration: "2 days"
      focus: "quality_and_security"
      testing: "comprehensive_validation"
      
    - name: "Documentation & Deployment"
      duration: "2 days"
      focus: "deployment_and_docs"
      testing: "production_readiness"
```

---

## 📝 Generated API Tasks

### 🎨 **Phase 1: API Design (Days 1-2)**

**API Specification**
- [ ] Define API endpoints and methods
- [ ] Create request/response schemas
- [ ] Design error handling strategy
- **Success**: Complete OpenAPI/Swagger specification

**Data Architecture**
- [ ] Design database schema (if needed)
- [ ] Define data validation rules
- [ ] Plan data relationships and constraints
- **Success**: Clear data model with migrations

**Authentication & Authorization**
- [ ] Choose authentication strategy (JWT, OAuth, etc.)
- [ ] Design permission/role system
- [ ] Plan security implementation
- **Success**: Security architecture documented

**Testing Strategy**
- [ ] Plan unit testing approach
- [ ] Define integration testing scenarios
- [ ] Set up testing framework and tools
- **Success**: Testing framework ready for development

---

### ⚙️ **Phase 2: Core Implementation (Days 3-6)**

**Basic API Setup**
- [ ] Set up project structure and dependencies
- [ ] Configure development environment
- [ ] Implement basic routing and middleware
- **Success**: API server runs and responds to requests

**Core Endpoints Implementation**
- [ ] Implement primary CRUD endpoints
- [ ] Add request validation and error handling
- [ ] Implement business logic and data processing
- **Success**: Main API functionality works end-to-end

**Authentication Implementation**
- [ ] Implement authentication endpoints (login, register)
- [ ] Add authorization middleware
- [ ] Integrate with authentication strategy
- **Success**: Secure endpoints require proper authentication

**Database Integration**
- [ ] Set up database connections and ORM
- [ ] Implement data access layer
- [ ] Add database migrations and seeders
- **Success**: API can persist and retrieve data reliably

**Unit Testing**
- [ ] Write unit tests for business logic
- [ ] Test data validation and error handling
- [ ] Achieve target test coverage (85%+)
- **Success**: Comprehensive unit test suite passes

---

### 🔒 **Phase 3: Testing & Security (Days 7-8)**

**Integration Testing**
- [ ] Write API endpoint integration tests
- [ ] Test authentication and authorization flows
- [ ] Test error scenarios and edge cases
- **Success**: All API workflows tested end-to-end

**Performance Testing**
- [ ] Set up performance benchmarks
- [ ] Test API response times and throughput
- [ ] Identify and fix performance bottlenecks
- **Success**: API meets performance requirements

**Security Hardening**
- [ ] Implement rate limiting and throttling
- [ ] Add input sanitization and validation
- [ ] Security audit and vulnerability scan
- **Success**: Security scan passes with no critical issues

**Load Testing**
- [ ] Test API under concurrent load
- [ ] Verify database performance under load
- [ ] Test graceful degradation scenarios
- **Success**: API handles expected traffic levels

---

### 📚 **Phase 4: Documentation & Deployment (Days 9-10)**

**API Documentation**
- [ ] Generate comprehensive API documentation
- [ ] Create usage examples and tutorials
- [ ] Document authentication and error codes
- **Success**: Complete, usable API documentation

**Deployment Setup**
- [ ] Configure production environment
- [ ] Set up CI/CD pipeline
- [ ] Configure monitoring and logging
- **Success**: Automated deployment pipeline works

**Production Deployment**
- [ ] Deploy to production environment
- [ ] Verify production functionality
- [ ] Set up health checks and monitoring
- **Success**: API is live and monitored

**Post-Deployment Validation**
- [ ] Run smoke tests on production
- [ ] Monitor initial traffic and performance
- [ ] Create maintenance and troubleshooting guide
- **Success**: API is stable and maintainable

---

## 🧪 Built-in Testing Pipeline

### Test-Driven Development Flow

```bash
# Run tests continuously during development
/milestone/test --watch

# Check test coverage
/milestone/test --coverage

# Run specific test suites
/milestone/test --unit
/milestone/test --integration
/milestone/test --security
```

### Testing Gates

**Gate 1: Unit Test Coverage (85%)**
- Must pass before integration testing
- Ensures business logic is thoroughly tested
- Automated coverage reporting

**Gate 2: Integration Test Suite**
- All API endpoints tested end-to-end
- Authentication flows validated
- Error scenarios covered

**Gate 3: Security Scan**
- Automated security vulnerability scan
- Manual security review checklist
- Performance benchmarks met

### Test Output

```
=== API TESTING DASHBOARD ===

UNIT TESTS:        ✅ 156/156 passing (Coverage: 87%)
INTEGRATION TESTS: ✅ 24/24 passing
SECURITY SCAN:     ✅ No critical issues
PERFORMANCE:       ✅ All benchmarks met

ENDPOINT COVERAGE:
├── GET  /auth/login     ✅ Tested
├── POST /auth/register  ✅ Tested  
├── GET  /users          ✅ Tested
├── POST /users          ✅ Tested
└── PUT  /users/:id      ✅ Tested

API HEALTH: Excellent 🚀
READY FOR DEPLOYMENT: Yes ✅
```

---

## 📊 API Progress Tracking

### Development Metrics

```bash
# Quick API status
/milestone/status --api

# Detailed metrics
/milestone/metrics --performance --security --coverage
```

### Progress Display

```
API Development: User authentication microservice
Progress: ███████░░ 73% (Day 7 of 10)

PHASE STATUS:
✅ API Design         (100% complete)
✅ Core Implementation (100% complete)
🔄 Testing & Security  (65% complete)
⏳ Documentation & Deployment (0% complete)

API HEALTH:
✅ Endpoints: 8/8 implemented
✅ Tests: 87% coverage
🔄 Security: Scan in progress
⏳ Docs: Not started

Today's Focus: Complete security hardening
Next Up: Performance testing
```

---

## 🚀 API-Specific Features

### Automatic Documentation Generation

```bash
# Generate API docs from code
/milestone/docs --generate

# Preview documentation
/milestone/docs --preview

# Deploy docs with API
/milestone/docs --deploy
```

### Built-in API Testing

```bash
# Interactive API testing
/milestone/test --interactive

# Generate test data
/milestone/test --seed-data

# Stress test endpoints
/milestone/test --load
```

### Security Automation

```bash
# Run security scan
/milestone/security --scan

# Check for vulnerabilities
/milestone/security --audit

# Generate security report
/milestone/security --report
```

---

## 🎉 API Success Celebration

When your API is complete:

```
🎉 API DEPLOYMENT SUCCESS! 🎉

"User authentication microservice" is live!

🔌 API STATS:
✅ Endpoints: 8 implemented and tested
🧪 Test Coverage: 89% (156 tests passing)
🔒 Security Score: A+ (No vulnerabilities)
⚡ Performance: All benchmarks exceeded
📚 Documentation: Complete with examples

🌐 API ENDPOINTS:
   POST /auth/login
   POST /auth/register  
   GET  /auth/profile
   PUT  /auth/profile
   GET  /users
   POST /users
   PUT  /users/:id
   DELETE /users/:id

🔗 Resources:
   📖 API Docs: https://api.yourapp.com/docs
   🧪 Test Suite: 156 tests, 89% coverage
   📊 Monitoring: https://monitor.yourapp.com

🌟 WHAT'S NEXT?
  a) Build another microservice
  b) Add advanced API features
  c) Create frontend integration

Your choice: _
```

---

## 🔄 Upgrade Options

### Build More APIs
```bash
# Create related microservice
/milestone/quickstart/api "User profile management service"
```

### Add Advanced Features
```bash
# Enable advanced API features
/milestone/upgrade --enable-graphql --enable-websockets milestone-002
```

### Full System Integration
```bash
# Plan complex microservices architecture
/milestone/plan "Microservices ecosystem with API gateway"
```

---

## 💡 API Development Tips

### 🎯 **Design First**
- Always start with API specification
- Think about the developer experience
- Plan for versioning from day one

### 🧪 **Test Continuously**
- Write tests as you implement features
- Aim for high test coverage (85%+)
- Test both success and error scenarios

### 🔒 **Security by Default**
- Implement authentication early
- Validate all inputs thoroughly
- Regular security scans and audits

### 📚 **Document Everything**
- Keep documentation in sync with code
- Provide clear examples and tutorials
- Make it easy for others to use your API

---

## 🚨 Implementation

This template automatically:
- ✅ **Creates test-driven development workflow** with continuous testing
- ✅ **Sets up API-specific quality gates** for coverage, security, performance
- ✅ **Generates API documentation** automatically from code and specifications
- ✅ **Provides deployment pipeline** with monitoring and health checks
- ✅ **Includes security scanning** and vulnerability assessment

**Generated Milestone Structure:**
```
.milestones/
├── api-$(timestamp)/
│   ├── milestone.yaml          # API milestone definition
│   ├── api-spec.yaml           # OpenAPI specification
│   ├── testing-strategy.md     # Testing approach and coverage
│   ├── security-checklist.md   # Security requirements and scans
│   ├── deployment-guide.md     # Deployment and monitoring setup
│   └── api-docs/               # Generated API documentation
```

**API Development Workflow:**
```bash
# Test-driven API development
develop_api_milestone() {
    local api_description="$1"
    
    # Initialize API-focused milestone
    initialize_api_milestone "$api_description"
    
    # Set up testing framework
    setup_api_testing_framework
    
    # Enable continuous testing
    enable_test_driven_development
    
    # Configure security scanning
    setup_security_automation
    
    # Set up documentation generation
    configure_api_docs_generation
    
    echo "✅ API milestone ready! Start with: /milestone/execute"
}
```

---

**Your API is ready to power amazing applications! Focus on reliability, security, and great developer experience.**