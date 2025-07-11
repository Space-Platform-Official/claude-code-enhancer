---
allowed-tools: all
description: API design and implementation command
---

# 🚀🚀🚀 CRITICAL REQUIREMENT: PRODUCTION-GRADE API DESIGN! 🚀🚀🚀

**THIS IS NOT A PROTOTYPE - THIS IS A PRODUCTION API TASK!**

When you run `/api-design`, you are REQUIRED to:

1. **RESEARCH** existing API patterns and industry standards
2. **DESIGN** RESTful/GraphQL endpoints following best practices
3. **GENERATE** complete OpenAPI/GraphQL schemas
4. **CREATE** SDKs and comprehensive documentation
5. **USE MULTIPLE AGENTS** for parallel development:
   - Spawn one agent for API specification design
   - Spawn another for implementation
   - Spawn more agents for SDK generation and documentation
   - Say: "I'll spawn multiple agents to handle different API aspects in parallel"
6. **DO NOT STOP** until:
   - ✅ API follows industry best practices
   - ✅ Complete OpenAPI/GraphQL specifications
   - ✅ Working implementation with validation
   - ✅ SDKs for multiple languages
   - ✅ Comprehensive documentation

**FORBIDDEN BEHAVIORS:**
- ❌ "Basic CRUD endpoints" → NO! Design thoughtful, domain-driven APIs!
- ❌ "Simple REST API" → NO! Consider GraphQL, versioning, and advanced patterns!
- ❌ "Documentation can come later" → NO! Design-first approach required!
- ❌ Ad-hoc endpoint design → NO! Consistent, well-planned API required!

**MANDATORY WORKFLOW:**
```
1. Research domain → Understand requirements and patterns
2. IMMEDIATELY spawn agents for parallel design
3. Design specification → Create comprehensive API contract
4. Implement endpoints → Build production-ready implementation
5. Generate SDKs → Create client libraries
6. REPEAT for any missing components
```

**YOU ARE NOT DONE UNTIL:**
- Complete API specification exists
- All endpoints implemented and tested
- SDKs generated for target languages
- Full documentation published
- API follows all best practices

---

🛑 **MANDATORY PRE-DESIGN CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify you understand the API requirements

Execute comprehensive API design with ZERO tolerance for shortcuts.

**FORBIDDEN EXCUSE PATTERNS:**
- "REST is simple enough" → NO, consider all API paradigms
- "We can add features later" → NO, design for extensibility now
- "Basic authentication will do" → NO, consider security comprehensively
- "Internal API doesn't need docs" → NO, all APIs need documentation
- "One endpoint per model is fine" → NO, design around use cases

Let me ultrathink about designing a world-class API for this domain.

🚨 **REMEMBER: APIs are contracts that live for years!** 🚨

**Comprehensive API Design Protocol:**

**Step 0: Requirements Analysis**
$ARGUMENTS

- Understand the domain and business requirements
- Identify all actors and their needs
- Define success criteria and constraints
- Research existing solutions and standards

**Step 1: API Paradigm Selection**
Choose the most appropriate approach:
- **REST**: For resource-oriented operations
- **GraphQL**: For flexible data fetching
- **RPC**: For action-oriented operations
- **WebSockets**: For real-time communication
- **Event Streaming**: For event-driven architectures

**Step 2: Domain Modeling**
- [ ] Identify core domain entities
- [ ] Define relationships and boundaries
- [ ] Map business operations to API operations
- [ ] Consider aggregate roots and consistency boundaries
- [ ] Design for eventual consistency where needed

**Step 3: API Design Principles**
- [ ] RESTful resource naming (nouns, not verbs)
- [ ] Consistent HTTP method usage
- [ ] Proper status code selection
- [ ] Idempotency for appropriate operations
- [ ] HATEOAS for discoverability
- [ ] Resource versioning strategy
- [ ] Pagination and filtering patterns
- [ ] Bulk operations support

**For GraphQL APIs:**
- [ ] Schema-first design approach
- [ ] Proper type definitions and relationships
- [ ] Query complexity analysis and limits
- [ ] Efficient resolver implementation
- [ ] Subscription design for real-time features
- [ ] Schema evolution and deprecation

**Step 4: Security Design**
- [ ] Authentication mechanism (JWT, OAuth, API keys)
- [ ] Authorization model (RBAC, ABAC, custom)
- [ ] Rate limiting and throttling
- [ ] Input validation and sanitization
- [ ] CORS policy definition
- [ ] HTTPS enforcement
- [ ] API key management
- [ ] Audit logging requirements

**Step 5: Data Contract Design**
- [ ] Request/response schemas
- [ ] Error response formats
- [ ] Consistent field naming conventions
- [ ] Date/time format standardization
- [ ] Internationalization support
- [ ] Pagination metadata structure
- [ ] Filtering and sorting parameters

**Step 6: API Specification Creation**
Generate complete specifications:

**For REST APIs (OpenAPI 3.0+):**
- [ ] Complete OpenAPI specification
- [ ] All endpoints documented
- [ ] Request/response examples
- [ ] Error scenarios covered
- [ ] Security schemes defined
- [ ] Server and environment configs

**For GraphQL APIs:**
- [ ] Complete GraphQL schema
- [ ] Type definitions and resolvers
- [ ] Query/mutation documentation
- [ ] Subscription specifications
- [ ] Schema introspection enabled

**Step 7: Implementation Standards**
- [ ] Consistent error handling
- [ ] Proper logging and monitoring
- [ ] Performance optimization
- [ ] Caching strategies
- [ ] Database query optimization
- [ ] Connection pooling
- [ ] Graceful degradation

**For Go Implementation:**
- [ ] Clean architecture patterns
- [ ] Proper context propagation
- [ ] Structured error responses
- [ ] Middleware for cross-cutting concerns
- [ ] Proper JSON serialization
- [ ] Request validation
- [ ] Database transaction management

**Step 8: Testing Strategy**
- [ ] Unit tests for business logic
- [ ] Integration tests for endpoints
- [ ] Contract testing for API compliance
- [ ] Load testing for performance
- [ ] Security testing for vulnerabilities
- [ ] Mock server for client development

**Step 9: SDK Generation**
Create client libraries for:
- [ ] JavaScript/TypeScript
- [ ] Python
- [ ] Go
- [ ] Java
- [ ] C#/.NET
- [ ] Others as needed

SDK Requirements:
- [ ] Auto-generated from specifications
- [ ] Type-safe client interfaces
- [ ] Error handling patterns
- [ ] Authentication handling
- [ ] Retry mechanisms
- [ ] Documentation and examples

**Step 10: Documentation Strategy**
- [ ] API reference documentation
- [ ] Getting started guides
- [ ] Authentication guides
- [ ] Code examples in multiple languages
- [ ] Postman/Insomnia collections
- [ ] Interactive API explorer
- [ ] Migration guides for versions
- [ ] Rate limiting documentation

**Parallel Development Strategy:**
When implementing the API, spawn multiple agents:
1. **Specification Agent**: Create OpenAPI/GraphQL schemas
2. **Implementation Agent**: Build server-side endpoints
3. **SDK Agent**: Generate client libraries
4. **Documentation Agent**: Create comprehensive docs
5. **Testing Agent**: Implement all test categories

**API Quality Checklist:**
- [ ] All endpoints follow RESTful conventions
- [ ] Consistent error response format
- [ ] Proper HTTP status codes used
- [ ] Authentication/authorization implemented
- [ ] Rate limiting configured
- [ ] Input validation on all endpoints
- [ ] Comprehensive test coverage
- [ ] Performance benchmarks established
- [ ] Security audit completed
- [ ] Documentation is complete and accurate

**Versioning Strategy:**
- [ ] Semantic versioning for breaking changes
- [ ] Backward compatibility maintenance
- [ ] Deprecation timeline planning
- [ ] Migration path documentation
- [ ] Version negotiation mechanism

**Monitoring and Observability:**
- [ ] Request/response logging
- [ ] Performance metrics collection
- [ ] Error rate monitoring
- [ ] Usage analytics
- [ ] Health check endpoints
- [ ] Distributed tracing support

**Final Verification:**
The API is ready when:
✓ Complete specification generated
✓ All endpoints implemented and tested
✓ SDKs available for target languages
✓ Comprehensive documentation published
✓ Security measures implemented
✓ Performance benchmarks met
✓ Error handling comprehensive
✓ Monitoring and logging configured

**Final Commitment:**
I will now execute EVERY API design step listed above and create a production-grade API. I will:
- ✅ Research domain and requirements thoroughly
- ✅ SPAWN MULTIPLE AGENTS for parallel development
- ✅ Design comprehensive API specifications
- ✅ Implement robust server endpoints
- ✅ Generate client SDKs
- ✅ Create complete documentation

I will NOT:
- ❌ Design basic CRUD APIs
- ❌ Skip security considerations
- ❌ Ignore performance requirements
- ❌ Create APIs without proper documentation
- ❌ Implement without comprehensive testing
- ❌ Stop at "minimum viable" APIs

**REMEMBER: This is a PRODUCTION API task, not a prototype!**

The API is complete ONLY when it meets all enterprise-grade requirements.

**Executing comprehensive API design and implementation NOW...**