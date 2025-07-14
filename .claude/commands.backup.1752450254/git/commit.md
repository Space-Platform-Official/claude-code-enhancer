---
allowed-tools: all
description: Smart git commit with automatic validation and conventional commit support
---

# Smart Git Commit Command

Execute intelligent git commits with automatic validation, conventional commit formatting, and pre-commit hook compliance.

**Usage:** `/git/commit $ARGUMENTS`

## 🚨 MANDATORY COMMIT WORKFLOW 🚨

**NEVER commit without proper validation!**

When you run `/git/commit`, you MUST:

1. **VALIDATE** - Check all changes before committing
2. **FORMAT** - Use conventional commit format
3. **VERIFY** - Ensure all hooks pass
4. **FIX** - Address any issues BEFORE committing

## Commit Message Standards

**Conventional Commit Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding missing tests
- `chore`: Changes to build process or auxiliary tools
- `ci`: CI configuration changes
- `build`: Changes affecting build system
- `revert`: Reverts a previous commit

**Scope Examples:**
- `api`: API-related changes
- `auth`: Authentication changes
- `core`: Core functionality
- `deps`: Dependency updates
- `config`: Configuration changes

## Intelligent Commit Process

**Step 1: Pre-Commit Analysis**
```bash
# Check current status
git status

# Review staged changes
git diff --cached

# Check for unstaged changes
git diff

# Verify branch status
git branch --show-current
```

**Step 2: Smart Staging**
- Analyze which files belong together
- Group related changes
- Split unrelated changes into separate commits
- Use `git add -p` for partial staging when needed

**Step 3: Validation Checks**
```bash
# Run pre-commit hooks manually
if [ -f .git/hooks/pre-commit ]; then
    .git/hooks/pre-commit
fi

# Run linters
make lint || npm run lint || cargo clippy

# Run tests for changed files
make test || npm test || cargo test

# Check for sensitive data
git diff --cached | grep -E "(password|secret|key|token)" -i
```

**Step 4: Generate Commit Message**

Analyze the changes and generate an appropriate commit message:

1. **Determine type** based on changes:
   - New files/features → `feat`
   - Bug fixes → `fix`
   - Refactoring → `refactor`

2. **Identify scope** from file paths:
   - `src/api/*` → `api`
   - `tests/*` → `test`
   - `docs/*` → `docs`

3. **Write descriptive subject**:
   - Start with verb (add, update, fix, remove)
   - Keep under 50 characters
   - No period at the end

4. **Add body if needed**:
   - Explain WHY, not WHAT
   - Reference issues/tickets
   - Include breaking changes

**Step 5: Atomic Commits**

If changes are too large or unrelated:
```bash
# Split into multiple commits
git reset HEAD~1
git add <related-files-1>
git commit -m "feat(module1): add feature X"
git add <related-files-2>
git commit -m "fix(module2): resolve issue Y"
```

## Safety Checks

**Before EVERY commit:**

1. **Branch Protection**
   ```bash
   # Prevent commits to main/master
   current_branch=$(git branch --show-current)
   if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
       echo "ERROR: Direct commits to $current_branch are not allowed!"
       echo "Create a feature branch first: git checkout -b feature/your-feature"
       exit 1
   fi
   ```

2. **Large File Detection**
   ```bash
   # Check for files over 100MB
   git diff --cached --name-only | while read file; do
       if [ -f "$file" ]; then
           size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
           if [ "$size" -gt 104857600 ]; then
               echo "ERROR: $file is over 100MB!"
               echo "Consider using Git LFS or excluding this file"
               exit 1
           fi
       fi
   done
   ```

3. **Merge Conflict Markers**
   ```bash
   # Check for unresolved conflicts
   if git diff --cached | grep -E "^(\+|-)(<<<<<<<|=======|>>>>>>>)" ; then
       echo "ERROR: Merge conflict markers detected!"
       echo "Resolve all conflicts before committing"
       exit 1
   fi
   ```

4. **TODO/FIXME Check**
   ```bash
   # Warn about TODOs in staged files
   todo_count=$(git diff --cached | grep -E "^\+" | grep -E "(TODO|FIXME|XXX)" | wc -l)
   if [ "$todo_count" -gt 0 ]; then
       echo "WARNING: Found $todo_count TODO/FIXME comments in staged changes"
       echo "Consider addressing these before committing"
   fi
   ```

## Advanced Features

**Interactive Commit Building:**
```bash
# Review changes file by file
git add -i

# Stage specific hunks
git add -p

# Edit hunks before staging
git add -e
```

**Commit Templates:**
```bash
# Use project-specific template
if [ -f .gitmessage ]; then
    git commit --template=.gitmessage
fi
```

**Automatic Issue Linking:**
```bash
# Extract issue number from branch name
branch=$(git branch --show-current)
issue=$(echo "$branch" | grep -oE '[0-9]+' | head -1)
if [ -n "$issue" ]; then
    # Append "Closes #123" to commit message
    echo -e "\n\nCloses #$issue"
fi
```

## Error Recovery

**If commit fails due to hooks:**

1. **Identify the issue**
   ```bash
   # Run hooks manually to see detailed output
   .git/hooks/pre-commit
   ```

2. **Fix the issues**
   - Address linting errors
   - Fix failing tests
   - Remove sensitive data

3. **Retry with same message**
   ```bash
   # Reuse previous commit message
   git commit -c ORIG_HEAD
   ```

**If you need to amend:**
```bash
# Add more changes to last commit
git add <files>
git commit --amend

# Change only the message
git commit --amend -m "new message"
```

## Best Practices

1. **One logical change per commit**
   - Don't mix features and fixes
   - Keep commits focused and atomic

2. **Write for your future self**
   - Explain WHY, not WHAT
   - Include context and reasoning

3. **Test before committing**
   - Run the code
   - Verify the feature works
   - Check for regressions

4. **Review before pushing**
   ```bash
   # Review your commits
   git log --oneline -5
   git show HEAD
   ```

## Integration with CI/CD

**Commit message triggers:**
- `[skip ci]` - Skip CI pipeline
- `[urgent]` - Trigger priority build
- `[deploy]` - Auto-deploy after tests

**Semantic versioning:**
- `feat:` → Minor version bump
- `fix:` → Patch version bump
- `BREAKING CHANGE:` → Major version bump

## Summary

The smart commit command ensures:
- ✅ All changes are validated
- ✅ Commit messages follow standards
- ✅ No accidental commits to protected branches
- ✅ Pre-commit hooks always pass
- ✅ Sensitive data is never committed
- ✅ Commits are atomic and logical

Remember: **A good commit tells a story. Make it worth reading!**