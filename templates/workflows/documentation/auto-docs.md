# Automated Documentation Workflow

## Overview
This workflow automatically generates and maintains project documentation across different languages and frameworks.

## Documentation Types

### 1. API Documentation
Automatically generated from code annotations and OpenAPI specs.

```yaml
api_docs:
  generator: openapi
  output_formats: [html, markdown, postman]
  include_examples: true
  versioning: true
```

### 2. Code Documentation
Extracted from inline comments and docstrings.

```yaml
code_docs:
  extractors:
    rust: rustdoc
    typescript: typedoc
    go: godoc
    python: sphinx
  
  output_dir: docs/api
  include_private: false
  include_tests: false
```

### 3. Architecture Documentation
Generated from code structure and dependencies.

```yaml
architecture_docs:
  diagrams:
    - type: component
      format: mermaid
      auto_update: true
    
    - type: sequence
      format: plantuml
      scenarios: [auth_flow, payment_flow]
  
  dependency_graph: true
  metrics: true
```

## Language-Specific Templates

### Rust Documentation
```rust
/// # User Service
/// 
/// Handles user authentication and profile management.
/// 
/// ## Example
/// 
/// ```rust
/// let service = UserService::new(db_pool);
/// let user = service.authenticate("user@example.com", "password").await?;
/// ```
/// 
/// ## Errors
/// 
/// Returns `AuthError` if authentication fails.
pub struct UserService {
    // Implementation
}
```

### TypeScript Documentation
```typescript
/**
 * User authentication service
 * @module services/auth
 */

/**
 * Authenticates a user with email and password
 * @param {string} email - User's email address
 * @param {string} password - User's password
 * @returns {Promise<User>} Authenticated user object
 * @throws {AuthenticationError} If credentials are invalid
 * 
 * @example
 * ```typescript
 * const user = await authService.authenticate('user@example.com', 'password');
 * console.log(user.id);
 * ```
 */
export async function authenticate(email: string, password: string): Promise<User> {
  // Implementation
}
```

### Go Documentation
```go
// Package auth provides user authentication functionality.
//
// The auth package handles user login, token generation, and session management.
// It supports multiple authentication methods including email/password and OAuth.
//
// Example usage:
//
//	service := auth.NewService(db)
//	user, err := service.Authenticate(ctx, "user@example.com", "password")
//	if err != nil {
//	    log.Fatal(err)
//	}
package auth

// Authenticate validates user credentials and returns an authenticated user.
// It returns ErrInvalidCredentials if the email/password combination is incorrect.
func (s *Service) Authenticate(ctx context.Context, email, password string) (*User, error) {
    // Implementation
}
```

### Python Documentation
```python
"""
User authentication module.

This module provides functionality for user authentication,
session management, and access control.

Example:
    >>> from auth import AuthService
    >>> service = AuthService()
    >>> user = await service.authenticate('user@example.com', 'password')
    >>> print(user.id)
"""

class AuthService:
    """Handles user authentication and session management.
    
    Attributes:
        session_timeout (int): Session timeout in seconds.
        max_attempts (int): Maximum login attempts before lockout.
    
    Example:
        >>> service = AuthService(session_timeout=3600)
        >>> user = await service.authenticate(email, password)
    """
    
    async def authenticate(self, email: str, password: str) -> User:
        """Authenticate a user with email and password.
        
        Args:
            email: User's email address.
            password: User's password.
        
        Returns:
            User: Authenticated user object.
        
        Raises:
            AuthenticationError: If credentials are invalid.
            AccountLockedException: If account is locked.
        
        Example:
            >>> user = await service.authenticate('test@example.com', 'pass123')
            >>> print(f"Welcome {user.name}")
        """
        # Implementation
```

## Documentation Generation Scripts

### Generate All Docs
```bash
#!/bin/bash
# generate-docs.sh

# API Documentation
echo "Generating API documentation..."
case "$LANGUAGE" in
  rust)
    cargo doc --no-deps --document-private-items
    ;;
  typescript)
    npx typedoc --out docs/api src
    ;;
  go)
    go doc -all > docs/api.txt
    godoc -http=:6060 &
    ;;
  python)
    sphinx-build -b html docs/source docs/build
    ;;
esac

# Generate diagrams
echo "Generating architecture diagrams..."
python scripts/generate_diagrams.py

# Update README
echo "Updating README..."
python scripts/update_readme.py
```

## Documentation Templates

### README Template
```markdown
# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

## Features
{{FEATURES_LIST}}

## Quick Start
```bash
{{QUICK_START_COMMANDS}}
```

## Documentation
- [API Reference](./docs/api/index.html)
- [Architecture Guide](./docs/architecture.md)
- [Contributing Guide](./CONTRIBUTING.md)

## Examples
{{EXAMPLES_SECTION}}

## License
{{LICENSE_INFO}}
```

### API Endpoint Template
```markdown
## {{METHOD}} {{ENDPOINT}}

{{DESCRIPTION}}

### Request
```json
{{REQUEST_EXAMPLE}}
```

### Response
```json
{{RESPONSE_EXAMPLE}}
```

### Error Codes
{{ERROR_CODES_TABLE}}
```

## Automation Configuration

### Pre-commit Hook
```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: update-docs
        name: Update documentation
        entry: ./scripts/update-docs.sh
        language: script
        files: \.(rs|ts|go|py)$
```

### CI Integration
```yaml
# .github/workflows/docs.yml
name: Documentation
on:
  push:
    branches: [main]
    paths:
      - 'src/**'
      - 'docs/**'

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Generate docs
        run: make docs
      
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs/build
```