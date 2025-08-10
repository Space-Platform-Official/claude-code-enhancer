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
# Enhanced Features (Consolidated)
# PHP Development Guidelines - SpacePlatform Enhanced

## 🚀 Using SpacePlatform Utilities

This project uses SpacePlatform's powerful utility libraries. Always prefer these over native PHP functions for consistency and enhanced functionality.

## Array Handling

### ❌ Don't Use Native Arrays
```php
// Avoid this
$filtered = array_filter($users, fn($user) => $user->isActive());
$names = array_map(fn($user) => $user->getName(), $filtered);
$indexed = array_values($names);
```

### ✅ Use SpacePlatform IArray
```php
use SpacePlatform\Utils\Functional\IArray;

// Preferred approach - chainable and type-safe
$names = IArray::from($users)
    ->filter(fn($user) => $user->isActive())
    ->map(fn($user) => $user->getName())
    ->values();

// Advanced features
$statistics = IArray::from($orders)
    ->groupBy(fn($order) => $order->getStatus())
    ->map(fn($group) => [
        'count' => $group->count(),
        'total' => $group->sum(fn($order) => $order->getTotal())
    ])
    ->toArray();

// Async operations
$results = IArray::fromAsync($promises)
    ->mapAsync(fn($data) => $this->processAsync($data))
    ->waitAll();

// Type safety with generics
/** @var IArray<int, User> $users */
$adults = $users->filter(fn(User $user) => $user->getAge() >= 18);
```

## String Manipulation

### ❌ Don't Use Native String Functions
```php
// Avoid this
$slug = strtolower(str_replace(' ', '-', $title));
$truncated = substr($text, 0, 100) . '...';
```

### ✅ Use SpacePlatform Str
```php
use SpacePlatform\Utils\Str;

// Fluent string manipulation
$slug = Str::of($title)->slugify();
$truncated = Str::of($text)->truncate(100);
$masked = Str::of($email)->mask('*', 3);

// Advanced features
$parsed = Str::of($template)
    ->interpolate(['name' => $user->getName()])
    ->markdown()
    ->toString();

// Safe operations
$domain = Str::of($email)->afterLast('@')->toString(); // Never null
```

## Date/Time Handling

### ❌ Don't Use Native DateTime
```php
// Avoid this
$date = new DateTime();
$formatted = $date->format('Y-m-d');
```

### ✅ Use SpacePlatform Carbon
```php
use SpacePlatform\Utils\Carbon;

// Enhanced date handling
$date = Carbon::now();
$formatted = $date->toDateString();
$human = $date->diffForHumans(); // "2 hours ago"

// Business logic helpers
$nextBusinessDay = $date->nextBusinessDay();
$isWeekend = $date->isWeekend();
$quarter = $date->quarter();

// Timezone handling
$userTime = $date->setTimezone($user->getTimezone());
```

## Money and Currency

### ❌ Never Use Floats for Money
```php
// NEVER do this
$price = 19.99;
$total = $price * 1.08; // Tax calculation - DANGEROUS!
```

### ✅ Use SpacePlatform Money
```php
use SpacePlatform\Utils\Money;

// Safe money handling
$price = Money::USD(1999); // $19.99 stored as 1999 cents
$tax = $price->multiply(0.08);
$total = $price->add($tax);

// Currency conversion
$eur = $total->convertTo('EUR', $exchangeRate);

// Formatting
echo $total->format(); // "$21.59"
echo $total->formatForHumans(); // "21 dollars and 59 cents"
echo $total->formatForAccounting(); // "($21.59)" if negative

// Allocation (splitting money safely)
$splits = $total->allocate([1, 1, 1]); // Split equally among 3
```

## HTTP Client

### ❌ Don't Use cURL Directly
```php
// Avoid this
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
$response = curl_exec($ch);
```

### ✅ Use SpacePlatform HttpClient
```php
use SpacePlatform\HttpClient;

// Fluent HTTP requests
$response = HttpClient::get('https://api.example.com/users')
    ->withToken($authToken)
    ->withQuery(['limit' => 10])
    ->retry(3)
    ->throw() // Throw on 4xx/5xx
    ->json();

// POST with automatic JSON encoding
$user = HttpClient::post('https://api.example.com/users')
    ->withJson(['name' => 'John', 'email' => 'john@example.com'])
    ->created(); // Expects 201 status

// Concurrent requests
$responses = HttpClient::pool([
    'users' => HttpClient::get('/users'),
    'posts' => HttpClient::get('/posts'),
    'comments' => HttpClient::get('/comments')
])->waitAll();
```

## Validation

### ❌ Don't Write Custom Validation
```php
// Avoid this
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    throw new Exception('Invalid email');
}
```

### ✅ Use SpacePlatform Validator
```php
use SpacePlatform\Validator;

// Fluent validation
$validator = Validator::make($request->all(), [
    'email' => 'required|email|unique:users',
    'age' => 'required|integer|min:18',
    'password' => 'required|min:8|confirmed'
]);

if ($validator->fails()) {
    return response()->errors($validator->errors());
}

// Custom validation rules
Validator::extend('phone', function ($value) {
    return Str::of($value)->match('/^\+?[1-9]\d{1,14}$/');
});

// Validation with transformations
$validated = Validator::make($data, [
    'email' => 'required|email|lowercase',
    'name' => 'required|string|trim|titlecase'
])->validated();
```

## Event System

### ✅ Use SpacePlatform Events
```php
use SpacePlatform\Events\Event;
use SpacePlatform\Events\Listener;

// Dispatch events
Event::dispatch(new UserRegistered($user));

// Async events
Event::dispatchAsync(new SendWelcomeEmail($user));

// Event listeners with auto-discovery
#[Listener(UserRegistered::class)]
class SendNotification
{
    public function handle(UserRegistered $event): void
    {
        // Handle event
    }
}

// Event sourcing support
Event::store(new OrderPlaced($order));
$events = Event::replay(OrderPlaced::class, $orderId);
```

## Repository Pattern

### ✅ Use SpacePlatform Repository
```php
use SpacePlatform\Patterns\Repository;

class UserRepository extends Repository
{
    protected string $model = User::class;
    
    public function findActive(): IArray
    {
        return $this->query()
            ->where('active', true)
            ->get()
            ->toIArray();
    }
    
    public function findByEmail(string $email): ?User
    {
        return $this->query()
            ->where('email', $email)
            ->first();
    }
}

// Usage
$users = $userRepository->findActive()
    ->filter(fn($user) => $user->hasVerifiedEmail())
    ->sortBy('created_at');
```

## Service Pattern

### ✅ Use SpacePlatform Service
```php
use SpacePlatform\Patterns\Service;
use SpacePlatform\Patterns\Result;

class CreateUserService extends Service
{
    public function execute(array $data): Result
    {
        return $this->transaction(function () use ($data) {
            // Validation
            $validated = Validator::make($data, [
                'email' => 'required|email|unique:users',
                'password' => 'required|min:8'
            ])->validated();
            
            // Create user
            $user = User::create([
                'email' => $validated['email'],
                'password' => Hash::make($validated['password'])
            ]);
            
            // Dispatch events
            Event::dispatch(new UserCreated($user));
            
            return Result::success($user);
        });
    }
}

// Usage
$result = $createUserService->execute($request->all());

if ($result->failed()) {
    return response()->error($result->error());
}

$user = $result->data();
```

## Testing Utilities

### ✅ Use SpacePlatform Testing Helpers
```php
use SpacePlatform\Testing\TestCase;
use SpacePlatform\Testing\Faker;

class UserTest extends TestCase
{
    public function test_user_creation(): void
    {
        // Enhanced faker
        $data = Faker::make([
            'email' => 'email|unique:users',
            'name' => 'name',
            'age' => 'integer:18,65',
            'avatar' => 'image_url'
        ]);
        
        // API testing helpers
        $this->postJson('/api/users', $data)
            ->assertCreated()
            ->assertJsonStructure(['id', 'email', 'name']);
        
        // Database assertions
        $this->assertDatabaseHas('users', [
            'email' => $data['email']
        ]);
        
        // Event assertions
        Event::assertDispatched(UserCreated::class);
    }
}
```

## Configuration

### Project Setup
```json
// composer.json
{
    "require": {
        "spaceplatform/utils": "^3.2",
        "spaceplatform/patterns": "^2.0",
        "spaceplatform/testing": "^1.5"
    }
}
```

### IDE Support
```php
// _ide_helper.php is auto-generated for full IDE support
// Run: php artisan spaceplatform:ide-helper
```

## Migration Guide

### From Native PHP to SpacePlatform
```php
// Before
$names = array_map(function($user) {
    return $user->getName();
}, array_filter($users, function($user) {
    return $user->isActive();
}));

// After
$names = IArray::from($users)
    ->filter(fn($user) => $user->isActive())
    ->map(fn($user) => $user->getName())
    ->values();
```

### Benefits
- ✅ Chainable operations
- ✅ Type safety
- ✅ Better performance
- ✅ Consistent API
- ✅ Additional features

Remember: Always check if SpacePlatform has a utility before writing custom code!