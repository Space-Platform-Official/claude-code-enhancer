# Session Management Command

Comprehensive session management for Claude Code development workflows. Track your work, maintain context, and create seamless handoffs with integrated memory system support.

## Usage

```bash
/session start              # Initialize a new development session
/session status            # Check current session state and progress  
/session end               # Conclude session with summary and handoff
```

## Subcommands

### 📝 `/session start` - Initialize Development Session

Begins a documented coding session with full context capture:

**What happens:**
1. Creates session timestamp and identifier
2. Captures current git branch and state
3. Prompts for session goals and objectives
4. Updates CLAUDE.md memory files (project and user)
5. Initializes progress tracking framework

**Example interaction:**
```
You: /session start

Claude: Starting new development session...

📅 Session initialized: 2024-01-15 14:30:00
🔀 Current branch: feature/user-authentication
📊 Git status: 3 modified files, 2 untracked

Please describe your session goals:
> Implement JWT authentication and user profile endpoints

Session context recorded in:
- ./CLAUDE.md (team memory)
- ~/.claude/CLAUDE.md (personal memory)

Ready to begin work on: JWT authentication implementation
```

### 📊 `/session status` - Check Session State

Reviews current session progress and context:

**What happens:**
1. Shows session duration and timeline
2. Lists files created/modified in session
3. Displays git commits made
4. Reviews completed vs pending goals
5. Shows current working context

**Example output:**
```
You: /session status

Claude: Current session status:

📅 Session started: 2024-01-15 14:30:00 (2 hours ago)
🔀 Branch: feature/user-authentication

Progress:
✅ Created auth middleware (auth.js)
✅ Implemented JWT token generation
⏳ User profile endpoints (in progress)
⏹️ Integration tests (pending)

Files modified (5):
- src/middleware/auth.js (created)
- src/routes/users.js (modified)
- src/utils/jwt.js (created)
- package.json (dependencies added)
- .env.example (new variables)

Git commits (2):
- feat: add JWT authentication middleware
- feat: implement token generation utilities

Next steps: Complete user profile CRUD operations
```

### 🏁 `/session end` - Conclude Session

Summarizes work completed and prepares handoff documentation:

**What happens:**
1. Analyzes all changes made during session
2. Reviews git commits and modifications
3. Generates comprehensive summary
4. Updates memory files with outcomes
5. Creates handoff notes for team

**Example summary:**
```
You: /session end

Claude: Concluding development session...

## Session Summary

**Duration:** 3 hours 45 minutes
**Branch:** feature/user-authentication

### ✅ Accomplishments
- Implemented complete JWT authentication system
- Created middleware for route protection
- Added user profile CRUD endpoints
- Configured environment variables
- Added bcrypt for password hashing

### 📁 Files Changed (8 files, +342 -28)
- Created: auth.js, jwt.js, userProfile.js
- Modified: users.js, server.js, package.json
- Configuration: .env.example, config.js

### 🔀 Git Activity (4 commits)
- feat: add JWT authentication middleware
- feat: implement token generation utilities  
- feat: create user profile endpoints
- chore: update dependencies and config

### ⏳ Pending Items
- Integration tests for auth endpoints
- Rate limiting for login attempts
- Password reset flow
- OAuth integration preparation

### 📝 Handoff Notes
**Architecture:** JWT stored in httpOnly cookies with 24h expiry
**Security:** Passwords hashed with bcrypt (10 rounds)
**Testing:** Manual testing completed, automated tests pending
**Next Dev:** Integration tests priority, then OAuth setup

Session summary saved to:
- ./CLAUDE.md (updated team context)
- ~/.claude/CLAUDE.md (personal session history)
```

## Implementation Details

### Memory System Integration

The session command integrates with Claude Code's native memory system:

- **Project Memory** (`./CLAUDE.md`): Team-shared context and decisions
- **User Memory** (`~/.claude/CLAUDE.md`): Personal workflow and preferences
- **Session State**: Maintained across command invocations
- **Git Integration**: Automatic branch and commit tracking

### Session Data Structure

Sessions maintain structured data for continuity:

```yaml
session:
  id: "session-2024-01-15-143000"
  started: "2024-01-15T14:30:00Z"
  branch: "feature/user-authentication"
  goals:
    - "Implement JWT authentication"
    - "Create user profile endpoints"
  progress:
    completed: ["auth middleware", "token generation"]
    in_progress: ["user profiles"]
    pending: ["integration tests"]
  files:
    created: ["auth.js", "jwt.js"]
    modified: ["users.js", "package.json"]
  commits: ["abc123", "def456"]
```

### Best Practices

1. **Start sessions** at the beginning of focused work periods
2. **Check status** periodically to maintain context awareness
3. **End sessions** before switching contexts or at day's end
4. **Use clear goals** that can be tracked and measured
5. **Include handoff notes** for team collaboration

### Important Restrictions

⚠️ **NEVER include AI-related attributions in git operations:**
- No AI mentions in commit messages
- No automated signatures or co-authorship
- No AI tool references in code comments
- Maintain professional, human-authored appearance

### Migration Note

If you previously used `/session-start` and `/session-end` commands, they have been consolidated into this single `/session` command with subcommands for better workflow management.

## Command Execution

When you run this command, I will:

1. **For `start`:** Initialize comprehensive session tracking with goals
2. **For `status`:** Provide real-time progress overview
3. **For `end`:** Generate detailed summary and handoff documentation
4. **Always:** Maintain seamless integration with Claude Code's memory system

The session system ensures continuity across your development workflow, making it easy to track progress, maintain context, and collaborate effectively with your team.