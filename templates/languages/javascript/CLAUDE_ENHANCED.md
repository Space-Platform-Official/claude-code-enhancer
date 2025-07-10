# JavaScript/TypeScript Development with Space Platform

## Using @space-platform Packages

### Array Operations with @space-platform/utils
```javascript
import { IArray } from '@space-platform/utils';

// ✅ Use Space Platform IArray instead of native array methods
const activeUsers = IArray.from(users)
  .filter(user => user.isActive)
  .map(user => ({ ...user, displayName: user.name.toUpperCase() }))
  .sortBy('createdAt')
  .toArray();

// ✅ Chain multiple operations efficiently
const report = IArray.from(transactions)
  .groupBy('category')
  .mapValues(group => ({
    count: group.length,
    total: IArray.from(group).sum('amount'),
    average: IArray.from(group).average('amount')
  }))
  .toObject();

// ✅ Advanced array operations
const uniqueEmails = IArray.from(users)
  .map(user => user.email)
  .unique()
  .toArray();

const usersByRole = IArray.from(users)
  .groupBy('role')
  .toObject();
```

### HTTP Requests with @space-platform/api
```javascript
import { SpaceAPI } from '@space-platform/api';

// ✅ Use Space Platform API client instead of fetch/axios
const api = new SpaceAPI({
  baseURL: process.env.API_URL,
  timeout: 30000,
});

// Automatic retry and error handling
const user = await api.get('/users/:id', { 
  params: { id: userId },
  retry: 3,
  cache: '5m'
});

// Batch requests
const [users, roles, permissions] = await api.batch([
  { method: 'GET', url: '/users' },
  { method: 'GET', url: '/roles' },
  { method: 'GET', url: '/permissions' }
]);

// Type-safe requests with TypeScript
interface User {
  id: string;
  name: string;
  email: string;
}

const typedUser = await api.get<User>('/users/:id', { 
  params: { id: userId } 
});
```

### Form Handling with @space-platform/forms
```javascript
import { SpaceForm, validators } from '@space-platform/forms';

// ✅ Use Space Platform form utilities
const userForm = new SpaceForm({
  fields: {
    email: {
      validators: [validators.required(), validators.email()],
      transform: value => value.toLowerCase().trim()
    },
    age: {
      validators: [validators.required(), validators.min(18), validators.max(100)],
      type: 'number'
    }
  }
});

// Validate and get errors
const errors = await userForm.validate(formData);
if (!errors) {
  const cleanData = userForm.getData();
  await api.post('/users', cleanData);
}
```

### State Management with @space-platform/state
```javascript
import { SpaceStore } from '@space-platform/state';

// ✅ Use Space Platform state management
const userStore = new SpaceStore({
  state: {
    users: [],
    loading: false,
    error: null
  },
  actions: {
    async fetchUsers() {
      this.setState({ loading: true, error: null });
      try {
        const users = await api.get('/users');
        this.setState({ users, loading: false });
      } catch (error) {
        this.setState({ error: error.message, loading: false });
      }
    }
  },
  getters: {
    activeUsers: (state) => state.users.filter(u => u.isActive),
    userCount: (state) => state.users.length
  }
});

// React integration
import { useSpaceStore } from '@space-platform/state/react';

function UserList() {
  const { users, loading, fetchUsers } = useSpaceStore(userStore);
  
  useEffect(() => {
    fetchUsers();
  }, []);
  
  if (loading) return <SpaceLoader />;
  return <UserGrid users={users} />;
}
```

### Utilities with @space-platform/common
```javascript
import { 
  debounce, 
  throttle, 
  deepClone, 
  deepMerge,
  formatDate,
  formatCurrency,
  sanitizeHTML
} from '@space-platform/common';

// ✅ Use Space Platform utilities instead of custom implementations
const search = debounce(async (query) => {
  const results = await api.get('/search', { params: { q: query } });
  setSearchResults(results);
}, 300);

const handleScroll = throttle(() => {
  updateScrollPosition();
}, 100);

// Date formatting with locale support
const formatted = formatDate(new Date(), {
  format: 'long',
  locale: 'en-US',
  timezone: 'America/New_York'
});

// Safe HTML rendering
const safeContent = sanitizeHTML(userContent, {
  allowedTags: ['p', 'b', 'i', 'em', 'strong']
});
```

### Validation with @space-platform/validators
```javascript
import { Schema } from '@space-platform/validators';

// ✅ Use Space Platform schema validation
const userSchema = new Schema({
  email: {
    type: 'email',
    required: true,
    unique: async (value) => {
      const exists = await api.get('/users/check-email', { params: { email: value } });
      return !exists;
    }
  },
  password: {
    type: 'string',
    required: true,
    minLength: 8,
    pattern: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
    message: 'Password must contain uppercase, lowercase, and number'
  },
  age: {
    type: 'number',
    min: 18,
    max: 120
  }
});

const validation = await userSchema.validate(userData);
if (!validation.valid) {
  console.error(validation.errors);
}
```

### Logging with @space-platform/logger
```javascript
import { Logger } from '@space-platform/logger';

// ✅ Use Space Platform structured logging
const logger = new Logger({
  service: 'user-service',
  environment: process.env.NODE_ENV
});

// Structured logging with context
logger.info('User action', {
  userId: user.id,
  action: 'login',
  metadata: { ip: request.ip, userAgent: request.headers['user-agent'] }
});

// Error logging with stack traces
try {
  await riskyOperation();
} catch (error) {
  logger.error('Operation failed', {
    error,
    context: { userId, operation: 'riskyOperation' }
  });
}
```

### React Components with @space-platform/ui
```jsx
import { 
  SpaceButton,
  SpaceCard,
  SpaceModal,
  SpaceTable,
  SpaceForm,
  SpaceToast
} from '@space-platform/ui';

// ✅ Use Space Platform UI components
function UserDashboard() {
  const { showToast } = SpaceToast.useToast();
  
  return (
    <SpaceCard>
      <SpaceTable
        data={users}
        columns={[
          { key: 'name', label: 'Name', sortable: true },
          { key: 'email', label: 'Email' },
          { key: 'role', label: 'Role', filterable: true }
        ]}
        onRowClick={(user) => {
          showToast({ message: `Selected ${user.name}`, type: 'info' });
        }}
      />
      
      <SpaceButton 
        variant="primary" 
        onClick={handleAddUser}
        loading={isLoading}
      >
        Add User
      </SpaceButton>
    </SpaceCard>
  );
}
```

### Testing with @space-platform/testing
```javascript
import { SpaceTest, mockAPI } from '@space-platform/testing';

// ✅ Use Space Platform testing utilities
describe('UserService', () => {
  const test = new SpaceTest();
  
  beforeEach(() => {
    test.mockAPI('/users', { data: mockUsers });
  });
  
  it('should fetch users with proper error handling', async () => {
    test.mockAPIError('/users', { status: 500 });
    
    const result = await userService.getUsers();
    
    expect(result).toEqual({ error: 'Failed to fetch users' });
    expect(test.logger.errors).toHaveLength(1);
  });
});
```

## Migration Guide

### From Native Arrays to IArray
```javascript
// ❌ Before
const names = users
  .filter(u => u.active)
  .map(u => u.name)
  .sort();

// ✅ After
const names = IArray.from(users)
  .filter(u => u.active)
  .map(u => u.name)
  .sort()
  .toArray();
```

### From Axios to SpaceAPI
```javascript
// ❌ Before
const { data } = await axios.get(`/api/users/${id}`);

// ✅ After
const data = await api.get('/users/:id', { params: { id } });
```

### From Lodash to Space Platform Utils
```javascript
// ❌ Before
import _ from 'lodash';
const grouped = _.groupBy(items, 'category');

// ✅ After
const grouped = IArray.from(items).groupBy('category').toObject();
```

## Configuration

### Package Detection
Space Platform packages are automatically detected from:
- `package.json` dependencies
- `yarn.lock` or `package-lock.json`
- `node_modules/@space-platform/*`

### Custom Preferences
Create `.claude/package-preferences.json`:
```json
{
  "javascript": {
    "preferred": {
      "arrays": "@space-platform/utils",
      "http": "@space-platform/api",
      "forms": "@space-platform/forms",
      "validation": "@space-platform/validators"
    },
    "forbidden": ["lodash", "underscore", "axios"],
    "migrations": {
      "lodash": "@space-platform/utils",
      "axios": "@space-platform/api"
    }
  }
}
```