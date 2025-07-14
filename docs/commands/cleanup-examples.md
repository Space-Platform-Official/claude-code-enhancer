# Safe Cleanup Patterns - Examples and Anti-Patterns

## Overview

This document provides concrete examples of code patterns that should be preserved vs safely cleaned during the intelligent cleanup process.

## ✅ PRESERVE: Dynamic Loading Patterns

### JavaScript/TypeScript

```javascript
// PRESERVE - Dynamic module loading
const moduleName = config.activeModule;
const module = await import(`./modules/${moduleName}`);

// PRESERVE - Conditional requires
if (process.env.USE_MOCK) {
  const MockService = require('./mocks/service');
  return new MockService();
}

// PRESERVE - Plugin architecture
plugins.forEach(pluginName => {
  const Plugin = require(`./plugins/${pluginName}`);
  app.use(new Plugin());
});

// PRESERVE - Lazy loading routes
const routes = {
  '/admin': () => import('./pages/Admin'),
  '/user': () => import('./pages/User')
};
```

### Python

```python
# PRESERVE - Dynamic imports
module_name = f"handlers.{event_type}_handler"
handler = importlib.import_module(module_name)

# PRESERVE - Plugin loading
for plugin in installed_plugins:
    mod = __import__(f'plugins.{plugin}', fromlist=[''])
    mod.initialize(app)

# PRESERVE - Conditional imports
if sys.platform == 'win32':
    from .windows_specific import WindowsHandler as Handler
else:
    from .unix_specific import UnixHandler as Handler
```

## ✅ PRESERVE: Framework Patterns

### React

```jsx
// PRESERVE - Lazy loaded components
const Dashboard = lazy(() => import('./Dashboard'));

// PRESERVE - Dynamic component rendering
const components = {
  button: Button,
  input: Input,
  select: Select
};
const Component = components[props.type];

// PRESERVE - Hook that appears unused
export function useDebounce(value, delay) {
  const [debouncedValue, setDebouncedValue] = useState(value);
  // Implementation
  return debouncedValue;
}
```

### Angular

```typescript
// PRESERVE - Injectable services
@Injectable({ providedIn: 'root' })
export class AuthService {
  // May appear unused but injected by Angular
}

// PRESERVE - Component with no direct imports
@Component({
  selector: 'app-header',
  template: '<h1>Header</h1>'
})
export class HeaderComponent { }

// PRESERVE - Guards and interceptors
@Injectable()
export class AuthGuard implements CanActivate {
  // Registered in routing module
}
```

### Vue

```vue
<!-- PRESERVE - Async components -->
<script>
export default {
  components: {
    AsyncComp: () => import('./AsyncComp.vue')
  }
}
</script>

<!-- PRESERVE - Dynamic components -->
<component :is="currentComponent" />
```

## ✅ PRESERVE: Event-Driven Code

```javascript
// PRESERVE - Event listeners
emitter.on('user:login', handleUserLogin);
bus.subscribe('data:update', refreshDisplay);

// PRESERVE - Observer pattern
class DataObserver {
  update(data) {  // Never directly called
    this.processData(data);
  }
}
subject.attach(new DataObserver());

// PRESERVE - Callback registrations
registerCallback('onError', errorHandler);
setInterval(heartbeat, 30000);
```

## ✅ PRESERVE: Test Infrastructure

```javascript
// PRESERVE - Test utilities
export const createMockUser = (overrides = {}) => ({
  id: 1,
  name: 'Test User',
  ...overrides
});

// PRESERVE - Test fixtures
export const sampleApiResponse = {
  status: 200,
  data: { message: 'Success' }
};

// PRESERVE - Test helpers
export function waitForElement(selector) {
  return new Promise(resolve => {
    const check = () => {
      const el = document.querySelector(selector);
      if (el) resolve(el);
      else setTimeout(check, 100);
    };
    check();
  });
}
```

## ✅ PRESERVE: Performance Variants

```javascript
// PRESERVE BOTH - Different use cases
function quickSort(arr) {
  // O(n log n) average, good for random data
}

function insertionSort(arr) {
  // O(n) for nearly sorted data
}

// PRESERVE - Optimized variants
function calculateDistance(p1, p2) {
  return Math.sqrt((p2.x - p1.x) ** 2 + (p2.y - p1.y) ** 2);
}

function calculateDistanceSquared(p1, p2) {
  // Faster when you don't need actual distance
  return (p2.x - p1.x) ** 2 + (p2.y - p1.y) ** 2;
}

// PRESERVE - Caching implementations
const memoizedExpensiveOp = (() => {
  const cache = new Map();
  return (input) => {
    if (cache.has(input)) return cache.get(input);
    const result = expensiveOperation(input);
    cache.set(input, result);
    return result;
  };
})();
```

## 🗑️ SAFE TO CLEAN: High Confidence

### Commented Code (Old)

```javascript
// SAFE TO CLEAN - Old commented code with no context
// function oldImplementation() {
//   return data.map(x => x * 2);
// }

// SAFE TO CLEAN - Obvious debugging remnants
console.log('HERE 1');
console.log('data:', data);
// console.log('TODO: remove this');
```

### Empty Files

```javascript
// SAFE TO CLEAN - Empty file with no exports
// empty-module.js (completely empty or only comments)

// SAFE TO CLEAN - Stub with no implementation
export class EmptyClass {
  // No properties or methods
}
```

### Obvious Dead Code

```javascript
// SAFE TO CLEAN - Unreachable code
function process() {
  return result;
  console.log('This never runs');  // Dead code
}

// SAFE TO CLEAN - Always false condition
if (false) {
  doSomething();  // Never executes
}

// SAFE TO CLEAN - Unused variable in function scope
function calculate(value) {
  const unused = 42;  // Never referenced
  return value * 2;
}
```

## ⚠️ REQUIRES ANALYSIS: Medium Confidence

### Seemingly Unused Exports

```javascript
// ANALYZE CAREFULLY - May be public API
export function calculateTax(amount, rate) {
  return amount * rate;
}

// ANALYZE CAREFULLY - May be dynamically imported
export class DataProcessor {
  process(data) {
    return transform(data);
  }
}
```

### Similar Functions

```javascript
// ANALYZE BEHAVIOR - May have subtle differences
function formatDate(date) {
  return date.toLocaleDateString();
}

function formatDateISO(date) {
  return date.toISOString().split('T')[0];
}
```

## 🚨 DANGER: Never Auto-Clean

### Reflection Patterns

```javascript
// NEVER CLEAN - Dynamic method calls
const method = obj[methodName];
if (typeof method === 'function') {
  method.call(obj, args);
}

// NEVER CLEAN - Property-based component selection
const Component = componentMap[props.componentType];
return <Component {...props} />;
```

### Side Effects on Import

```javascript
// NEVER CLEAN - Registers on import
import './polyfills';  // Adds polyfills
import './styles.css'; // Loads styles
import './config';     // Sets up configuration

// NEVER CLEAN - Module with side effects
// database.js
const db = new Database();
db.connect();  // Side effect
export default db;
```

### Framework Magic

```javascript
// NEVER CLEAN - Decorators
@observer
@inject('store')
class MyComponent extends React.Component { }

// NEVER CLEAN - Module registration
angular.module('app').service('MyService', MyService);

// NEVER CLEAN - Vue plugins
Vue.use(VueRouter);
```

## Configuration Examples

### Project-Specific Rules

```yaml
# .cleanup-config.yaml
custom_rules:
  # Preserve all calculator functions (business logic)
  - pattern: "*Calculator"
    confidence_modifier: -0.8
    reason: "Core business logic"
    
  # Preserve all database migrations
  - pattern: "migrations/*.js"
    confidence_modifier: -1.0
    reason: "Database migrations must never be deleted"
    
  # More aggressive on deprecated directory
  - path: "src/deprecated/*"
    confidence_modifier: +0.3
    reason: "Scheduled for removal in v2.0"
    
  # Preserve feature flags
  - pattern: "feature_*"
    confidence_modifier: -0.7
    reason: "Feature flag implementations"
```

### Safe Cleanup Commands

```bash
# Analyze only - no changes
cleanup --analyze --report

# Dry run - preview changes
cleanup --dry-run --verbose

# Conservative cleanup - high confidence only
cleanup --mode=conservative --confidence=0.90

# Interactive mode - review each item
cleanup --interactive --save-decisions

# Specific directory with custom config
cleanup src/utils --config=.cleanup-config.yaml
```

## Best Practices

1. **Start with Analysis**
   ```bash
   cleanup --analyze > cleanup-report.md
   ```

2. **Review Patterns**
   - Check for framework-specific patterns
   - Identify dynamic loading in your codebase
   - Document custom preservation rules

3. **Incremental Cleanup**
   - Clean one module at a time
   - Run tests between cleanups
   - Commit each cleanup separately

4. **Team Collaboration**
   - Share cleanup configurations
   - Review cleanup reports together
   - Document why code was preserved

5. **Continuous Improvement**
   - Track false positives
   - Adjust confidence scores
   - Update preservation patterns

Remember: **When in doubt, preserve the code!**