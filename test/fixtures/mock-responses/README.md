# Mock Git Response Fixtures

This directory contains mock responses for various git commands used in the Phase 2 mock execution testing framework.

## File Structure

- `git-status-*.txt` - Various git status command outputs
- `git-commit-*.txt` - Git commit command responses  
- `git-push-*.txt` - Git push command responses
- `git-branch-*.txt` - Git branch command outputs

## Usage

These fixtures are used by the mock environment to simulate realistic git command responses without actually executing git commands. They help test:

1. Normal workflow scenarios
2. Error conditions
3. Edge cases
4. Security validations

## Adding New Fixtures

When adding new mock responses:

1. Use descriptive filenames that indicate the command and scenario
2. Include realistic output that matches actual git behavior
3. Cover both success and failure cases
4. Document any special conditions or assumptions