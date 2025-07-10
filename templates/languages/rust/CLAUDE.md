# Rust Development Guidelines

## Language-Specific Patterns

### Memory Management
- Prefer borrowing over cloning
- Use `Arc<T>` for shared ownership
- Implement `Drop` for resource cleanup
- Avoid unnecessary allocations

### Error Handling
```rust
// Use Result<T, E> for recoverable errors
pub fn process_data(input: &str) -> Result<Data, ProcessError> {
    // Implementation
}

// Use custom error types
#[derive(Debug, thiserror::Error)]
pub enum ProcessError {
    #[error("Invalid input: {0}")]
    InvalidInput(String),
    #[error("Processing failed: {0}")]
    ProcessingFailed(#[from] std::io::Error),
}
```

### Concurrency Patterns
- Use `tokio` for async runtime
- Prefer channels over shared state
- Use `RwLock` for read-heavy workloads
- Implement `Send + Sync` for thread safety

### Performance Optimization
- Use `cargo bench` for benchmarking
- Profile with `flamegraph`
- Prefer iterators over loops
- Use const generics where applicable

## Project Structure
```
src/
├── lib.rs          # Library root
├── main.rs         # Binary entry point
├── config/         # Configuration modules
├── domain/         # Business logic
├── infrastructure/ # External integrations
├── api/           # HTTP/gRPC handlers
└── tests/         # Integration tests
```

## Testing Strategy
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_unit_functionality() {
        // Unit test implementation
    }

    #[tokio::test]
    async fn test_async_behavior() {
        // Async test implementation
    }
}
```

## Documentation Standards
- Document all public APIs
- Include examples in doc comments
- Use `cargo doc` to verify
- Link related items with `[`brackets`]`

## Clippy Configuration
```toml
# clippy.toml
cognitive-complexity-threshold = 30
too-many-arguments-threshold = 7
type-complexity-threshold = 250
```

## Common Pitfalls to Avoid
- Overusing `unwrap()` and `expect()`
- Creating unnecessary generic constraints
- Ignoring compiler warnings
- Not leveraging type system fully