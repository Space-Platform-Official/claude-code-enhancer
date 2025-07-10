# JavaScript/TypeScript Development Guidelines

## Code Style and Patterns

### Array Operations
```javascript
// Filtering arrays
const activeUsers = users.filter(user => user.isActive);

// Mapping arrays
const userNames = users.map(user => user.name);

// Reducing arrays
const total = items.reduce((sum, item) => sum + item.price, 0);

// Finding elements
const admin = users.find(user => user.role === 'admin');
```

### Object Manipulation
```javascript
// Object destructuring
const { name, email } = user;

// Object spread
const updatedUser = { ...user, lastLogin: new Date() };

// Object.entries for iteration
Object.entries(config).forEach(([key, value]) => {
  console.log(`${key}: ${value}`);
});
```

### Async Operations
```javascript
// Promise-based
async function fetchUser(id) {
  try {
    const response = await fetch(`/api/users/${id}`);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw error;
  }
}

// Error handling
try {
  const result = await operation();
} catch (error) {
  handleError(error);
}
```

### HTTP Requests
```javascript
// Using fetch API
const response = await fetch('/api/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(data),
});

// Using axios
import axios from 'axios';

const { data } = await axios.post('/api/data', payload);
```

### Utility Functions
```javascript
// Debounce
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// Deep clone
function deepClone(obj) {
  return JSON.parse(JSON.stringify(obj));
}

// Format dates
function formatDate(date) {
  return new Intl.DateTimeFormat('en-US').format(date);
}
```

### TypeScript Patterns
```typescript
// Interfaces
interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user';
}

// Type guards
function isUser(obj: any): obj is User {
  return obj && typeof obj.id === 'string' && typeof obj.name === 'string';
}

// Generics
function getValue<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// Utility types
type PartialUser = Partial<User>;
type RequiredUser = Required<User>;
type ReadonlyUser = Readonly<User>;
```

### React Patterns
```jsx
// Functional components
const UserCard = ({ user }) => {
  const [expanded, setExpanded] = useState(false);
  
  useEffect(() => {
    // Side effects
  }, [user.id]);
  
  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      {expanded && <UserDetails user={user} />}
    </div>
  );
};

// Custom hooks
function useDebounce(value, delay) {
  const [debouncedValue, setDebouncedValue] = useState(value);
  
  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);
    
    return () => clearTimeout(handler);
  }, [value, delay]);
  
  return debouncedValue;
}
```

### Testing
```javascript
// Jest tests
describe('UserService', () => {
  it('should fetch user by id', async () => {
    const user = await userService.getById('123');
    expect(user).toHaveProperty('name');
    expect(user.id).toBe('123');
  });
});

// React Testing Library
import { render, screen } from '@testing-library/react';

test('renders user name', () => {
  render(<UserCard user={{ name: 'John' }} />);
  expect(screen.getByText('John')).toBeInTheDocument();
});
```

## Best Practices

1. **Use const/let instead of var**
2. **Prefer arrow functions for callbacks**
3. **Use template literals for string interpolation**
4. **Always handle Promise rejections**
5. **Use TypeScript for better type safety**
6. **Destructure objects and arrays when possible**
7. **Use optional chaining (?.) for safe property access**
8. **Implement proper error boundaries in React**
9. **Keep components small and focused**
10. **Use meaningful variable and function names**