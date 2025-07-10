# React Framework Guidelines

## Component Patterns

### Functional Components with Hooks
```tsx
import React, { useState, useEffect, useMemo, useCallback } from 'react';

interface UserProfileProps {
  userId: string;
  onUpdate?: (user: User) => void;
}

export const UserProfile: React.FC<UserProfileProps> = ({ userId, onUpdate }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetchUser(userId)
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [userId]);

  const handleUpdate = useCallback(async (updates: Partial<User>) => {
    if (!user) return;
    
    const updated = await updateUser(user.id, updates);
    setUser(updated);
    onUpdate?.(updated);
  }, [user, onUpdate]);

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!user) return <NotFound />;

  return <ProfileView user={user} onUpdate={handleUpdate} />;
};
```

### Custom Hooks
```tsx
// useDebounce.ts
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}

// useLocalStorage.ts
export function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T | ((val: T) => T)) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(`Error loading ${key} from localStorage:`, error);
      return initialValue;
    }
  });

  const setValue = useCallback((value: T | ((val: T) => T)) => {
    try {
      setStoredValue(prevValue => {
        const valueToStore = value instanceof Function ? value(prevValue) : value;
        window.localStorage.setItem(key, JSON.stringify(valueToStore));
        return valueToStore;
      });
    } catch (error) {
      console.error(`Error saving ${key} to localStorage:`, error);
    }
  }, [key]);

  return [storedValue, setValue];
}
```

### Context and State Management
```tsx
// AuthContext.tsx
interface AuthContextType {
  user: User | null;
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => void;
  loading: boolean;
}

const AuthContext = React.createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check for existing session
    checkSession()
      .then(setUser)
      .catch(() => setUser(null))
      .finally(() => setLoading(false));
  }, []);

  const login = useCallback(async (credentials: LoginCredentials) => {
    const user = await authenticate(credentials);
    setUser(user);
  }, []);

  const logout = useCallback(() => {
    clearSession();
    setUser(null);
  }, []);

  return (
    <AuthContext.Provider value={{ user, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
```

### Performance Optimization
```tsx
// Memoization
const ExpensiveComponent = React.memo(({ data, onAction }) => {
  const processedData = useMemo(() => 
    expensiveProcessing(data), [data]
  );

  const handleClick = useCallback((item) => {
    onAction(item.id);
  }, [onAction]);

  return (
    <div>
      {processedData.map(item => (
        <Item key={item.id} {...item} onClick={handleClick} />
      ))}
    </div>
  );
});

// Code splitting
const HeavyFeature = lazy(() => import('./features/HeavyFeature'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <HeavyFeature />
    </Suspense>
  );
}
```

## Testing Patterns

### Component Testing
```tsx
// UserProfile.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserProfile } from './UserProfile';

describe('UserProfile', () => {
  it('displays user information', async () => {
    const mockUser = { id: '1', name: 'John Doe', email: 'john@example.com' };
    jest.spyOn(api, 'fetchUser').mockResolvedValue(mockUser);

    render(<UserProfile userId="1" />);

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('john@example.com')).toBeInTheDocument();
    });
  });

  it('handles update action', async () => {
    const onUpdate = jest.fn();
    render(<UserProfile userId="1" onUpdate={onUpdate} />);

    const updateButton = await screen.findByRole('button', { name: /update/i });
    await userEvent.click(updateButton);

    await waitFor(() => {
      expect(onUpdate).toHaveBeenCalledWith(expect.objectContaining({
        id: '1'
      }));
    });
  });
});
```

### Hook Testing
```tsx
// useAuth.test.tsx
import { renderHook, act } from '@testing-library/react';
import { AuthProvider, useAuth } from './AuthContext';

describe('useAuth', () => {
  const wrapper = ({ children }) => <AuthProvider>{children}</AuthProvider>;

  it('provides authentication methods', async () => {
    const { result } = renderHook(() => useAuth(), { wrapper });

    expect(result.current.user).toBeNull();
    expect(result.current.loading).toBe(true);

    await act(async () => {
      await result.current.login({ email: 'test@example.com', password: 'password' });
    });

    expect(result.current.user).toEqual(expect.objectContaining({
      email: 'test@example.com'
    }));
  });
});
```

## Project Structure
```
src/
├── components/          # Reusable UI components
│   ├── common/         # Generic components
│   ├── forms/          # Form components
│   └── layout/         # Layout components
├── features/           # Feature-specific modules
│   ├── auth/          # Authentication feature
│   ├── users/         # User management
│   └── dashboard/     # Dashboard feature
├── hooks/             # Custom React hooks
├── services/          # API and external services
├── contexts/          # React contexts
├── utils/             # Utility functions
├── types/             # TypeScript type definitions
└── styles/            # Global styles and themes
```

## Best Practices

### State Management
- Keep state as local as possible
- Lift state only when necessary
- Use context for cross-cutting concerns
- Consider state machines for complex flows

### Component Design
- Single responsibility principle
- Composition over inheritance
- Props interface documentation
- Sensible prop defaults

### Performance
- Virtualize long lists
- Lazy load routes and components
- Optimize re-renders with memo
- Profile with React DevTools

### Accessibility
- Semantic HTML elements
- ARIA labels where needed
- Keyboard navigation support
- Screen reader testing