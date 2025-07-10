# TypeScript Development Guidelines

## Language-Specific Patterns

### Type Safety
```typescript
// Use strict type definitions
interface UserData {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

// Prefer type guards
function isUserData(data: unknown): data is UserData {
  return (
    typeof data === 'object' &&
    data !== null &&
    'id' in data &&
    'name' in data
  );
}

// Use branded types for validation
type Email = string & { __brand: 'Email' };
```

### Error Handling
```typescript
// Define error classes
class ApplicationError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500
  ) {
    super(message);
    this.name = 'ApplicationError';
  }
}

// Use Result pattern
type Result<T, E = Error> = 
  | { ok: true; value: T }
  | { ok: false; error: E };
```

### Async Patterns
```typescript
// Prefer async/await over promises
async function fetchUser(id: string): Promise<User> {
  try {
    const response = await api.get(`/users/${id}`);
    return response.data;
  } catch (error) {
    throw new ApplicationError('User not found', 'USER_NOT_FOUND', 404);
  }
}

// Use Promise.all for parallel operations
const [users, posts] = await Promise.all([
  fetchUsers(),
  fetchPosts()
]);
```

### State Management
```typescript
// Use immutable updates
const updateUser = (state: State, updates: Partial<User>): State => ({
  ...state,
  user: {
    ...state.user,
    ...updates
  }
});

// Leverage discriminated unions
type Action =
  | { type: 'FETCH_START' }
  | { type: 'FETCH_SUCCESS'; payload: Data }
  | { type: 'FETCH_ERROR'; error: Error };
```

## Project Structure
```
src/
├── types/          # Type definitions
├── utils/          # Utility functions
├── services/       # Business logic
├── api/           # API routes/handlers
├── models/        # Data models
├── middleware/    # Express/Koa middleware
├── config/        # Configuration
└── __tests__/     # Test files
```

## Testing Strategy
```typescript
// Jest configuration
describe('UserService', () => {
  let service: UserService;
  
  beforeEach(() => {
    service = new UserService();
  });

  it('should fetch user by id', async () => {
    const user = await service.getById('123');
    expect(user).toMatchObject({
      id: '123',
      name: expect.any(String)
    });
  });
});
```

## ESLint Configuration
```json
{
  "extends": [
    "@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking"
  ],
  "rules": {
    "@typescript-eslint/explicit-function-return-type": "error",
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/strict-boolean-expressions": "error"
  }
}
```

## Performance Considerations
- Use `const` assertions for literals
- Leverage tree shaking
- Implement lazy loading
- Use Web Workers for CPU-intensive tasks

## Common Pitfalls to Avoid
- Using `any` type
- Ignoring null/undefined checks
- Mutating objects directly
- Not handling promise rejections