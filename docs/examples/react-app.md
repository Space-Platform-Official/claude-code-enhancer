# React Application Setup with Claude Flow

This comprehensive guide shows how to set up a modern React application with Claude Flow, including TypeScript, testing, state management, and deployment.

## Prerequisites

- Node.js 18+ and npm/yarn installed
- Git initialized in your project
- Claude Flow installed globally

## Step-by-Step Setup

### 1. Create React App with TypeScript

```bash
# Create new React app with TypeScript
npx create-react-app my-react-app --template typescript
cd my-react-app

# Initialize Claude Flow
claude flow init
```

**Expected Output:**
```
🚀 Initializing Claude Flow...
✅ Created .claude directory
✅ Created CLAUDE.md with project instructions
✅ Set up git hooks for automated checks
✅ Created Makefile with common commands

Claude Flow initialized successfully!
```

### 2. Configure Development Standards

```bash
# Set up ESLint, Prettier, and additional React tools
claude flow setup react

# Or interactive:
claude flow setup
# Select: React > TypeScript + ESLint + Prettier + Jest + React Testing Library
```

**Enhanced `.eslintrc.json`:**
```json
{
  "extends": [
    "react-app",
    "react-app/jest",
    "plugin:react-hooks/recommended",
    "plugin:jsx-a11y/recommended",
    "prettier"
  ],
  "plugins": ["react-hooks", "jsx-a11y"],
  "rules": {
    "react-hooks/rules-of-hooks": "error",
    "react-hooks/exhaustive-deps": "warn",
    "no-console": ["warn", { "allow": ["warn", "error"] }],
    "prefer-const": "error",
    "no-unused-vars": ["error", { 
      "argsIgnorePattern": "^_",
      "varsIgnorePattern": "^_"
    }]
  }
}
```

**`.prettierrc`:**
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "jsxSingleQuote": false,
  "bracketSpacing": true,
  "jsxBracketSameLine": false,
  "arrowParens": "avoid",
  "endOfLine": "auto"
}
```

### 3. Install Additional Dependencies

```bash
# Install development dependencies
npm install -D @testing-library/user-event @testing-library/jest-dom
npm install -D @types/jest @types/testing-library__jest-dom
npm install -D husky lint-staged

# Install production dependencies for a todo app
npm install axios react-router-dom zustand
npm install -D @types/react-router-dom
```

### 4. Create Application Structure

```bash
# Use Claude to create structure
claude create-structure --type react

# Creates:
src/
├── components/
│   ├── common/
│   ├── features/
│   └── layout/
├── hooks/
├── services/
├── stores/
├── types/
├── utils/
└── styles/
```

### 5. Implement Core Components

**`src/types/todo.ts`:**
```typescript
export interface Todo {
  id: string;
  title: string;
  description: string;
  completed: boolean;
  priority: 'low' | 'medium' | 'high';
  createdAt: Date;
  updatedAt: Date;
  completedAt?: Date;
  tags: string[];
}

export interface TodoFilter {
  status?: 'all' | 'active' | 'completed';
  priority?: Todo['priority'];
  tags?: string[];
  searchTerm?: string;
}

export interface TodoStats {
  total: number;
  completed: number;
  active: number;
  byPriority: Record<Todo['priority'], number>;
}
```

**`src/stores/todoStore.ts` (Using Zustand):**
```typescript
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';
import { Todo, TodoFilter } from '../types/todo';

interface TodoState {
  todos: Todo[];
  filter: TodoFilter;
  addTodo: (todo: Omit<Todo, 'id' | 'createdAt' | 'updatedAt'>) => void;
  updateTodo: (id: string, updates: Partial<Todo>) => void;
  deleteTodo: (id: string) => void;
  toggleTodo: (id: string) => void;
  setFilter: (filter: TodoFilter) => void;
  getFilteredTodos: () => Todo[];
  getStats: () => {
    total: number;
    completed: number;
    active: number;
    byPriority: Record<Todo['priority'], number>;
  };
}

export const useTodoStore = create<TodoState>()(
  devtools(
    persist(
      (set, get) => ({
        todos: [],
        filter: { status: 'all' },

        addTodo: todo => {
          const newTodo: Todo = {
            ...todo,
            id: Date.now().toString(),
            createdAt: new Date(),
            updatedAt: new Date(),
          };
          set(state => ({ todos: [...state.todos, newTodo] }));
        },

        updateTodo: (id, updates) => {
          set(state => ({
            todos: state.todos.map(todo =>
              todo.id === id
                ? { ...todo, ...updates, updatedAt: new Date() }
                : todo
            ),
          }));
        },

        deleteTodo: id => {
          set(state => ({
            todos: state.todos.filter(todo => todo.id !== id),
          }));
        },

        toggleTodo: id => {
          set(state => ({
            todos: state.todos.map(todo =>
              todo.id === id
                ? {
                    ...todo,
                    completed: !todo.completed,
                    completedAt: !todo.completed ? new Date() : undefined,
                    updatedAt: new Date(),
                  }
                : todo
            ),
          }));
        },

        setFilter: filter => {
          set({ filter });
        },

        getFilteredTodos: () => {
          const { todos, filter } = get();
          let filtered = [...todos];

          if (filter.status === 'active') {
            filtered = filtered.filter(todo => !todo.completed);
          } else if (filter.status === 'completed') {
            filtered = filtered.filter(todo => todo.completed);
          }

          if (filter.priority) {
            filtered = filtered.filter(todo => todo.priority === filter.priority);
          }

          if (filter.tags && filter.tags.length > 0) {
            filtered = filtered.filter(todo =>
              filter.tags!.some(tag => todo.tags.includes(tag))
            );
          }

          if (filter.searchTerm) {
            const searchLower = filter.searchTerm.toLowerCase();
            filtered = filtered.filter(
              todo =>
                todo.title.toLowerCase().includes(searchLower) ||
                todo.description.toLowerCase().includes(searchLower)
            );
          }

          return filtered.sort(
            (a, b) => b.createdAt.getTime() - a.createdAt.getTime()
          );
        },

        getStats: () => {
          const todos = get().todos;
          const completed = todos.filter(t => t.completed).length;
          const byPriority = todos.reduce(
            (acc, todo) => {
              acc[todo.priority] = (acc[todo.priority] || 0) + 1;
              return acc;
            },
            {} as Record<Todo['priority'], number>
          );

          return {
            total: todos.length,
            completed,
            active: todos.length - completed,
            byPriority,
          };
        },
      }),
      {
        name: 'todo-storage',
      }
    )
  )
);
```

**`src/components/features/TodoList/TodoList.tsx`:**
```tsx
import React from 'react';
import { useTodoStore } from '../../../stores/todoStore';
import TodoItem from './TodoItem';
import TodoFilters from './TodoFilters';
import styles from './TodoList.module.css';

const TodoList: React.FC = () => {
  const { getFilteredTodos, getStats } = useTodoStore();
  const todos = getFilteredTodos();
  const stats = getStats();

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h2>My Tasks</h2>
        <div className={styles.stats}>
          <span className={styles.stat}>
            Total: <strong>{stats.total}</strong>
          </span>
          <span className={styles.stat}>
            Active: <strong>{stats.active}</strong>
          </span>
          <span className={styles.stat}>
            Completed: <strong>{stats.completed}</strong>
          </span>
        </div>
      </div>

      <TodoFilters />

      {todos.length === 0 ? (
        <div className={styles.empty}>
          <p>No tasks found. Create your first task!</p>
        </div>
      ) : (
        <ul className={styles.list}>
          {todos.map(todo => (
            <TodoItem key={todo.id} todo={todo} />
          ))}
        </ul>
      )}
    </div>
  );
};

export default TodoList;
```

**`src/components/features/TodoList/TodoItem.tsx`:**
```tsx
import React, { useState } from 'react';
import { Todo } from '../../../types/todo';
import { useTodoStore } from '../../../stores/todoStore';
import styles from './TodoItem.module.css';

interface TodoItemProps {
  todo: Todo;
}

const TodoItem: React.FC<TodoItemProps> = ({ todo }) => {
  const { toggleTodo, deleteTodo, updateTodo } = useTodoStore();
  const [isEditing, setIsEditing] = useState(false);
  const [editTitle, setEditTitle] = useState(todo.title);

  const handleSave = () => {
    if (editTitle.trim()) {
      updateTodo(todo.id, { title: editTitle.trim() });
      setIsEditing(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleSave();
    } else if (e.key === 'Escape') {
      setEditTitle(todo.title);
      setIsEditing(false);
    }
  };

  const priorityClass = styles[`priority-${todo.priority}`];
  const completedClass = todo.completed ? styles.completed : '';

  return (
    <li className={`${styles.item} ${completedClass} ${priorityClass}`}>
      <input
        type="checkbox"
        checked={todo.completed}
        onChange={() => toggleTodo(todo.id)}
        className={styles.checkbox}
        aria-label={`Mark ${todo.title} as ${
          todo.completed ? 'incomplete' : 'complete'
        }`}
      />

      {isEditing ? (
        <input
          type="text"
          value={editTitle}
          onChange={e => setEditTitle(e.target.value)}
          onBlur={handleSave}
          onKeyDown={handleKeyPress}
          className={styles.editInput}
          autoFocus
        />
      ) : (
        <div className={styles.content} onClick={() => setIsEditing(true)}>
          <h3 className={styles.title}>{todo.title}</h3>
          {todo.description && (
            <p className={styles.description}>{todo.description}</p>
          )}
          <div className={styles.meta}>
            <span className={styles.priority}>{todo.priority}</span>
            {todo.tags.map(tag => (
              <span key={tag} className={styles.tag}>
                {tag}
              </span>
            ))}
          </div>
        </div>
      )}

      <button
        onClick={() => deleteTodo(todo.id)}
        className={styles.deleteButton}
        aria-label={`Delete ${todo.title}`}
      >
        Delete
      </button>
    </li>
  );
};

export default TodoItem;
```

### 6. Add Comprehensive Tests

**`src/components/features/TodoList/__tests__/TodoList.test.tsx`:**
```tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import TodoList from '../TodoList';
import { useTodoStore } from '../../../../stores/todoStore';

// Mock the store
jest.mock('../../../../stores/todoStore');

describe('TodoList', () => {
  const mockGetFilteredTodos = jest.fn();
  const mockGetStats = jest.fn();

  beforeEach(() => {
    (useTodoStore as unknown as jest.Mock).mockReturnValue({
      getFilteredTodos: mockGetFilteredTodos,
      getStats: mockGetStats,
    });

    mockGetStats.mockReturnValue({
      total: 0,
      active: 0,
      completed: 0,
      byPriority: { low: 0, medium: 0, high: 0 },
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('renders empty state when no todos', () => {
    mockGetFilteredTodos.mockReturnValue([]);

    render(<TodoList />);

    expect(
      screen.getByText('No tasks found. Create your first task!')
    ).toBeInTheDocument();
  });

  it('renders todo items when todos exist', () => {
    const mockTodos = [
      {
        id: '1',
        title: 'Test Todo 1',
        description: 'Description 1',
        completed: false,
        priority: 'medium',
        tags: ['work'],
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        id: '2',
        title: 'Test Todo 2',
        description: 'Description 2',
        completed: true,
        priority: 'high',
        tags: ['personal'],
        createdAt: new Date(),
        updatedAt: new Date(),
        completedAt: new Date(),
      },
    ];

    mockGetFilteredTodos.mockReturnValue(mockTodos);
    mockGetStats.mockReturnValue({
      total: 2,
      active: 1,
      completed: 1,
      byPriority: { low: 0, medium: 1, high: 1 },
    });

    render(<TodoList />);

    expect(screen.getByText('Test Todo 1')).toBeInTheDocument();
    expect(screen.getByText('Test Todo 2')).toBeInTheDocument();
    expect(screen.getByText('Total: 2')).toBeInTheDocument();
    expect(screen.getByText('Active: 1')).toBeInTheDocument();
    expect(screen.getByText('Completed: 1')).toBeInTheDocument();
  });

  it('displays correct stats', () => {
    mockGetFilteredTodos.mockReturnValue([]);
    mockGetStats.mockReturnValue({
      total: 10,
      active: 7,
      completed: 3,
      byPriority: { low: 2, medium: 5, high: 3 },
    });

    render(<TodoList />);

    expect(screen.getByText('10').closest('.stat')).toHaveTextContent(
      'Total: 10'
    );
    expect(screen.getByText('7').closest('.stat')).toHaveTextContent(
      'Active: 7'
    );
    expect(screen.getByText('3').closest('.stat')).toHaveTextContent(
      'Completed: 3'
    );
  });
});
```

**`src/hooks/__tests__/useDebounce.test.ts`:**
```typescript
import { renderHook, act } from '@testing-library/react';
import { useDebounce } from '../useDebounce';

jest.useFakeTimers();

describe('useDebounce', () => {
  it('returns initial value immediately', () => {
    const { result } = renderHook(() => useDebounce('initial', 500));
    expect(result.current).toBe('initial');
  });

  it('debounces value changes', () => {
    const { result, rerender } = renderHook(
      ({ value, delay }) => useDebounce(value, delay),
      {
        initialProps: { value: 'initial', delay: 500 },
      }
    );

    expect(result.current).toBe('initial');

    // Change value
    rerender({ value: 'changed', delay: 500 });
    expect(result.current).toBe('initial'); // Still initial

    // Fast-forward time
    act(() => {
      jest.advanceTimersByTime(499);
    });
    expect(result.current).toBe('initial'); // Still initial

    act(() => {
      jest.advanceTimersByTime(1);
    });
    expect(result.current).toBe('changed'); // Now changed
  });

  it('cancels previous timeout on rapid changes', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, 500),
      {
        initialProps: { value: 'initial' },
      }
    );

    rerender({ value: 'change1' });
    act(() => {
      jest.advanceTimersByTime(300);
    });

    rerender({ value: 'change2' });
    act(() => {
      jest.advanceTimersByTime(300);
    });

    expect(result.current).toBe('initial'); // Still initial

    act(() => {
      jest.advanceTimersByTime(200);
    });
    expect(result.current).toBe('change2'); // Latest change
  });
});
```

### 7. Configure Git Hooks

Claude Flow sets up hooks automatically. Verify with:

```bash
# Stage and commit
git add .
git commit -m "Initial React setup"
```

**Pre-commit output:**
```
🔍 Running pre-commit checks...
✅ ESLint: No issues found
✅ TypeScript: No type errors
✅ Prettier: All files formatted
✅ Tests: All tests passing (12/12)

Commit successful!
```

### 8. Add Scripts to package.json

```json
{
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "test:coverage": "react-scripts test --coverage --watchAll=false",
    "eject": "react-scripts eject",
    "lint": "eslint src --ext .ts,.tsx",
    "lint:fix": "eslint src --ext .ts,.tsx --fix",
    "format": "prettier --write \"src/**/*.{ts,tsx,css,json}\"",
    "format:check": "prettier --check \"src/**/*.{ts,tsx,css,json}\"",
    "typecheck": "tsc --noEmit",
    "validate": "npm run typecheck && npm run lint && npm run format:check && npm run test:coverage",
    "storybook": "start-storybook -p 6006",
    "build-storybook": "build-storybook"
  }
}
```

### 9. Set Up Component Documentation with Storybook

```bash
# Install Storybook
npx storybook@latest init

# Create stories
claude create stories
```

**Example `src/components/common/Button/Button.stories.tsx`:**
```tsx
import type { Meta, StoryObj } from '@storybook/react';
import Button from './Button';

const meta = {
  title: 'Common/Button',
  component: Button,
  parameters: {
    layout: 'centered',
  },
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'danger'],
    },
    size: {
      control: 'select',
      options: ['small', 'medium', 'large'],
    },
  },
} satisfies Meta<typeof Button>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Primary: Story = {
  args: {
    children: 'Primary Button',
    variant: 'primary',
  },
};

export const Secondary: Story = {
  args: {
    children: 'Secondary Button',
    variant: 'secondary',
  },
};

export const Large: Story = {
  args: {
    children: 'Large Button',
    size: 'large',
  },
};

export const WithEmoji: Story = {
  args: {
    children: '🚀 Launch',
    variant: 'primary',
  },
};
```

### 10. Deploy Configuration

**Create `netlify.toml` for Netlify:**
```toml
[build]
  command = "npm run build"
  publish = "build"

[build.environment]
  CI = "true"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    X-XSS-Protection = "1; mode=block"
```

**Create `.github/workflows/deploy.yml`:**
```yaml
name: Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Use Node.js 18
        uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run validation
        run: npm run validate
      
      - name: Build application
        run: npm run build
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-files
          path: build/

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: build-files
          path: build/
      
      - name: Deploy to Netlify
        uses: nwtgck/actions-netlify@v2.0
        with:
          publish-dir: './build'
          production-branch: main
          github-token: ${{ secrets.GITHUB_TOKEN }}
          deploy-message: "Deploy from GitHub Actions"
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

## Working with Claude

### Adding Features

```bash
# Add a new feature component
claude add component "TaskCalendarView with month view and drag-drop"

# Add state management
claude add store "calendar events with CRUD operations"

# Add API integration
claude add service "todo API with error handling and retry logic"
```

### Performance Optimization

```bash
# Analyze and optimize bundle
claude optimize bundle

# Add lazy loading
claude add lazy-loading

# Implement virtualization
claude add virtualization "for todo list over 100 items"
```

## Project Structure

Final structure:
```
my-react-app/
├── .claude/
├── .github/
│   └── workflows/
├── .storybook/
├── public/
├── src/
│   ├── components/
│   │   ├── common/
│   │   │   ├── Button/
│   │   │   ├── Input/
│   │   │   └── Modal/
│   │   ├── features/
│   │   │   ├── TodoList/
│   │   │   ├── TodoForm/
│   │   │   └── TodoFilters/
│   │   └── layout/
│   │       ├── Header/
│   │       ├── Footer/
│   │       └── Layout/
│   ├── hooks/
│   ├── pages/
│   ├── services/
│   ├── stores/
│   ├── styles/
│   ├── types/
│   ├── utils/
│   ├── App.tsx
│   ├── index.tsx
│   └── setupTests.ts
├── .eslintrc.json
├── .prettierrc
├── CLAUDE.md
├── netlify.toml
├── package.json
├── tsconfig.json
└── README.md
```

## Common Commands

```bash
# Development
npm start                # Start dev server
npm test                # Run tests in watch mode
npm run storybook       # Start Storybook

# Quality checks
npm run lint            # Check for linting errors
npm run lint:fix        # Fix linting errors
npm run format          # Format code
npm run typecheck       # Check TypeScript types
npm run validate        # Run all checks

# Build and deploy
npm run build           # Create production build
npm run analyze         # Analyze bundle size

# Claude commands
claude validate         # Run all validations
claude add component    # Add new component
claude fix typescript   # Fix type errors
claude optimize         # Optimize performance
```

## Best Practices

1. **Component Structure**: Keep components small and focused
2. **State Management**: Use Zustand for global state, React state for local
3. **Testing**: Write tests for all components and hooks
4. **Performance**: Use React.memo, useMemo, and useCallback appropriately
5. **Accessibility**: Always include ARIA labels and keyboard navigation
6. **Type Safety**: Leverage TypeScript strictly

## Troubleshooting

### TypeScript Errors
```bash
# Check specific file
npx tsc --noEmit src/components/MyComponent.tsx

# Use Claude to fix
claude fix typescript
```

### Test Failures
```bash
# Run specific test
npm test -- TodoList.test.tsx

# Debug test
npm test -- --no-coverage --verbose
```

### Build Issues
```bash
# Clear cache and rebuild
rm -rf node_modules build
npm install
npm run build

# Check for build warnings
CI=true npm run build
```

## Next Steps

- Explore [CI/CD setup](./ci-cd-setup.md) for automated deployments
- Learn about [multi-language projects](./multi-language.md)
- Read the [migration guide](./migration-guide.md) for existing React apps