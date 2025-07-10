# PHP Development Guidelines

## Language-Specific Patterns

### PHP Version
- Target PHP 8.1+ for modern features
- Use type declarations everywhere possible
- Leverage null safety operators

### Code Style
- Follow PSR-12 coding standard
- Use PHP-CS-Fixer for automatic formatting
- Prefer strict types: `declare(strict_types=1);`

### Error Handling
```php
// Use exceptions for exceptional cases
throw new InvalidArgumentException('Invalid input');

// Use null/false for expected failures
return $result ?: null;
```

### Common Patterns
- Use dependency injection over static calls
- Prefer composition over inheritance
- Implement interfaces for contracts
- Use value objects for domain concepts

### Testing
- PHPUnit for unit tests
- Mockery for mocking
- Test data builders for complex objects
- Aim for 80%+ code coverage

### Performance
- Use opcache in production
- Implement lazy loading where appropriate
- Cache expensive computations
- Profile with Blackfire or XHProf

### Security
- Always validate user input
- Use prepared statements for queries
- Escape output based on context
- Never trust $_REQUEST data
- Use password_hash() for passwords

### Package Management
- Use Composer for dependencies
- Lock versions in composer.lock
- Regular security audits with `composer audit`
- Prefer stable releases

### Modern PHP Features
- Use enums for fixed sets of values
- Leverage attributes for metadata
- Constructor property promotion
- Match expressions over switch
- Named arguments for clarity

## Project Structure
```
src/
├── Controller/
├── Service/
├── Repository/
├── Entity/
├── ValueObject/
└── Exception/
```

## Common Tasks

### Working with Arrays
```php
// Use array functions effectively
$filtered = array_filter($items, fn($item) => $item->isActive());
$mapped = array_map(fn($item) => $item->getName(), $items);

// Type-safe collections
/** @var array<int, User> $users */
```

### Database Interactions
- Use query builders or ORMs
- Always parameterize queries
- Transaction management for data integrity

### HTTP Handling
- PSR-7 for HTTP messages
- Middleware pattern for cross-cutting concerns
- Proper status codes and headers