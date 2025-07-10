# Go Development Guidelines

## Language-Specific Patterns

### Error Handling
```go
// Define custom errors
type ValidationError struct {
    Field   string
    Message string
}

func (e ValidationError) Error() string {
    return fmt.Sprintf("validation error on field %s: %s", e.Field, e.Message)
}

// Use error wrapping
if err != nil {
    return fmt.Errorf("failed to process user: %w", err)
}

// Check errors immediately
result, err := someOperation()
if err != nil {
    return nil, err
}
```

### Concurrency Patterns
```go
// Use channels for communication
func worker(jobs <-chan Job, results chan<- Result) {
    for job := range jobs {
        results <- processJob(job)
    }
}

// Context for cancellation
func fetchData(ctx context.Context) error {
    select {
    case <-ctx.Done():
        return ctx.Err()
    case data := <-dataChan:
        return processData(data)
    }
}

// Use sync.Once for initialization
var (
    instance *Service
    once     sync.Once
)

func GetService() *Service {
    once.Do(func() {
        instance = &Service{}
    })
    return instance
}
```

### Interface Design
```go
// Keep interfaces small
type Reader interface {
    Read(ctx context.Context, id string) (*Data, error)
}

type Writer interface {
    Write(ctx context.Context, data *Data) error
}

// Compose interfaces
type ReadWriter interface {
    Reader
    Writer
}

// Accept interfaces, return structs
func NewService(store Reader) *Service {
    return &Service{store: store}
}
```

### Testing Patterns
```go
// Table-driven tests
func TestValidate(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    bool
        wantErr bool
    }{
        {"valid email", "test@example.com", true, false},
        {"invalid email", "invalid", false, true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Validate(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("Validate() error = %v, wantErr %v", err, tt.wantErr)
            }
            if got != tt.want {
                t.Errorf("Validate() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

## Project Structure
```
cmd/
├── api/           # API server entry point
├── worker/        # Background worker
└── cli/           # CLI tool

internal/
├── config/        # Configuration
├── domain/        # Business logic
├── repository/    # Data access
├── service/       # Service layer
└── handler/       # HTTP handlers

pkg/
├── logger/        # Shared logging
├── middleware/    # HTTP middleware
└── utils/         # Utility functions
```

## Performance Guidelines
- Pre-allocate slices when size is known
- Use `strings.Builder` for string concatenation
- Leverage `sync.Pool` for object reuse
- Profile with `pprof` regularly

## Code Style
```go
// Use meaningful variable names
var userRepository UserRepository // Good
var ur UserRepository            // Bad

// Group imports
import (
    "context"
    "fmt"
    
    "github.com/gorilla/mux"
    
    "myproject/internal/config"
    "myproject/pkg/logger"
)

// Document exported functions
// GetUserByID retrieves a user by their unique identifier.
// It returns ErrNotFound if the user doesn't exist.
func GetUserByID(ctx context.Context, id string) (*User, error) {
    // Implementation
}
```

## Common Patterns
```go
// Options pattern for configuration
type Option func(*Config)

func WithTimeout(d time.Duration) Option {
    return func(c *Config) {
        c.Timeout = d
    }
}

// Builder pattern for complex objects
type UserBuilder struct {
    user User
}

func (b *UserBuilder) WithName(name string) *UserBuilder {
    b.user.Name = name
    return b
}

func (b *UserBuilder) Build() User {
    return b.user
}
```

## Pitfalls to Avoid
- Not checking errors
- Goroutine leaks
- Not using contexts
- Ignoring race conditions
- Improper nil handling