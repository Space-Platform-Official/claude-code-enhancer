# Claude-Flow Installation Script Tests

This directory contains a test suite for the `install-claude-flow.sh` script.

## Structure

```
test/
├── README.md                    # This file
├── run-tests.sh                # Main test runner
├── install-claude-flow-link.sh # Link to real script with test environment
├── mock-templates/             # Minimal mock files
│   ├── CLAUDE.md
│   ├── languages/
│   │   └── python/
│   │       └── CLAUDE.md
│   └── frameworks/
│       └── react/
│           └── CLAUDE.md
└── test-projects/             # Test execution directory (created during tests)
```

## Running Tests

```bash
cd test
chmod +x run-tests.sh
./run-tests.sh
```

## Test Scenarios

### Test 1: Fresh Installation
- Tests installing into an empty project
- Verifies all files are created correctly
- Checks merge report generation

### Test 2: Merge Conflicts
- Tests handling of existing files
- Verifies conflict resolution options:
  - `m` (merge later) creates `.new` file
  - `k` (keep) preserves existing content
- Confirms existing content is not lost

### Test 3: All Merge Options
- Tests all 4 conflict resolution options:
  - `o` (overwrite) replaces existing file
  - `s` (skip) leaves file untouched
  - `k` (keep) preserves existing
  - `m` (merge later) creates `.new` file

### Test 4: Idempotency
- Runs the script twice on the same directory
- Verifies no unnecessary changes are made
- Confirms "No changes needed" detection works

## Key Features Tested

1. **File Creation**: New files are created with correct paths
2. **Conflict Detection**: Existing files are detected
3. **User Interaction**: All merge options work correctly
4. **Content Preservation**: Existing content is not lost unless explicitly overwritten
5. **Idempotency**: Running multiple times is safe

## How It Works

The test suite uses the actual `install-claude-flow.sh` script by:
1. Setting the `CLAUDE_TEMPLATE_SOURCE` environment variable to point to test mock-templates
2. Executing the real script without modification
3. The script reads this environment variable and uses test templates instead of production ones

## Notes

- Uses the real install script to ensure tests match production behavior
- Mock templates contain minimal content for faster testing
- All tests clean up after themselves
- Tests run in sequence with automatic responses to prompts