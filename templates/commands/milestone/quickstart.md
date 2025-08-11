---
allowed-tools: all
description: Quick-start milestone templates for common project types with progressive complexity introduction
---

# 🚀 Milestone Quick-Start Templates

**New to milestones? Start here!** These templates hide complexity and get you productive in under 5 minutes.

## 🎯 Choose Your Project Type

| Template | Use When | Setup Time |
|----------|----------|------------|
| **personal** | Individual coding project | 2 minutes |
| **team** | Small team collaboration | 3 minutes |
| **api** | Building APIs or backend | 3 minutes |
| **frontend** | UI/React/Vue projects | 3 minutes |
| **bugfix** | Fixing bugs or issues | 1 minute |

## 🏃‍♂️ Quick Commands

```bash
# Pick your template and go!
/milestone/quickstart personal "Build my portfolio website"
/milestone/quickstart team "Team chat application"
/milestone/quickstart api "User authentication API"
/milestone/quickstart frontend "Shopping cart component"
/milestone/quickstart bugfix "Fix login timeout issue"
```

---

## 📋 Template Details

### 🧑‍💻 Personal Project Template

**Perfect for:** Solo coding projects, learning, personal apps

```bash
/milestone/quickstart personal "Your project description"
```

**What you get:**
- ✅ Simple 1-week milestone structure
- ✅ Basic task breakdown (no complexity)
- ✅ Personal progress tracking
- ✅ Clear next steps

**Example:**
```bash
/milestone/quickstart personal "Build a todo app with React"
# → Creates milestone with: Setup, Core Features, Polish, Deploy
# → Each phase is 1-3 tasks maximum
# → No approval gates or complex workflows
```

---

### 👥 Team Collaboration Template

**Perfect for:** Small teams (2-5 people), shared projects

```bash
/milestone/quickstart team "Your team project"
```

**What you get:**
- ✅ 2-week milestone with team coordination
- ✅ Simple approval points (not overwhelming)
- ✅ Task assignment structure
- ✅ Team progress visibility

**Example:**
```bash
/milestone/quickstart team "Build team messaging app"
# → Creates milestone with: Planning, Development, Testing, Launch
# → Includes simple team coordination
# → Light approval gates for key decisions
```

---

### 🔌 API Development Template

**Perfect for:** Backend APIs, microservices, data processing

```bash
/milestone/quickstart api "Your API project"
```

**What you get:**
- ✅ API-focused milestone structure
- ✅ Development → Testing → Documentation flow
- ✅ Built-in testing checkpoints
- ✅ Deployment preparation

**Example:**
```bash
/milestone/quickstart api "User authentication service"
# → Creates milestone with: API Design, Implementation, Testing, Docs
# → Focus on endpoints, validation, security
# → Clear testing and documentation gates
```

---

### 🎨 Frontend Development Template

**Perfect for:** React/Vue/Angular projects, UI components

```bash
/milestone/quickstart frontend "Your frontend project"
```

**What you get:**
- ✅ Frontend-specific milestone structure
- ✅ Design → Build → Test → Polish flow
- ✅ Component-based task breakdown
- ✅ User experience validation

**Example:**
```bash
/milestone/quickstart frontend "Shopping cart component"
# → Creates milestone with: Design, Implementation, Testing, UX Review
# → Focus on components, styling, user interaction
# → Built-in responsive and accessibility checks
```

---

### 🐛 Bug Fix Template

**Perfect for:** Fixing specific issues, hotfixes, maintenance

```bash
/milestone/quickstart bugfix "Bug description"
```

**What you get:**
- ✅ Minimal milestone for focused fixes
- ✅ Investigation → Fix → Test → Deploy
- ✅ Quick turnaround structure
- ✅ Root cause analysis

**Example:**
```bash
/milestone/quickstart bugfix "Users can't login after password reset"
# → Creates milestone with: Investigate, Fix, Test, Deploy
# → Streamlined for fast resolution
# → Includes root cause analysis step
```

---

## 🔄 After Quick-Start: What's Next?

Once your first milestone is complete, you'll get **progressive suggestions**:

### 🌟 Success! Your first milestone is done!

```
✅ Congratulations! You completed your first milestone in 2 days.

🎯 READY FOR MORE FEATURES?
  ⬆️  Upgrade to full milestone system for:
     • Advanced dependency management
     • Multi-agent coordination  
     • Enterprise dashboard
     • Kiro workflow phases

💡 NEXT STEPS:
  a) Create another quick-start milestone
  b) Try the full /milestone/plan command
  c) Learn about kiro workflow phases
  
Your choice: _
```

### 🚀 Upgrade Paths

**Option A: Stay Simple**
```bash
# Continue with quick-start templates
/milestone/quickstart team "Next feature"
```

**Option B: Add One Advanced Feature**
```bash
# Enable kiro workflow for this milestone
/milestone/upgrade --enable-kiro milestone-002
```

**Option C: Full System**
```bash
# Switch to full milestone planning
/milestone/plan "Complex multi-team project"
```

---

## 🎯 Implementation Details

### Template Architecture

**Core Principle: Hide Complexity, Show Value (with Kiro-Native Foundation)**

Each quick-start template:
- ✅ **Uses kiro workflow internally** (mandatory 4-phase structure)
- ✅ **Auto-manages phases** for simplicity
- ✅ **Shows** immediate value and clear progress
- ✅ **Provides** progressive kiro revelation as users advance
- ✅ **Maintains** full system compatibility

### Progressive Disclosure Strategy

```yaml
complexity_levels:
  level_0_quickstart:
    features: [basic_tasks, simple_progress, clear_outcomes]
    kiro_mode: "auto_managed"  # Kiro active but auto-progressed
    hidden: [kiro_details, approval_gates, deliverables, dependencies]
    display: "simple_progress_bar"
    
  level_1_enhanced:
    features: [phase_names, basic_deliverables]
    kiro_mode: "semi_visible"  # Show phase names
    hidden: [approval_workflow, advanced_dependencies]
    display: "phase_progress"
    
  level_2_full:
    features: [all_milestone_features]
    kiro_mode: "fully_visible"  # Complete kiro visualization
    hidden: []
    display: "kiro_dashboard"
```

### Auto-Configuration with Kiro-Native

Each template automatically:
- ✅ **Creates kiro workflow structure** (4 phases mandatory)
- ✅ **Auto-progresses phases** (no manual transitions)
- ✅ **Sets smart kiro defaults** (auto-approval for quickstart)
- ✅ **Generates simple deliverables** (template-specific)
- ✅ **Configures progressive revelation** (kiro details unlock over time)
- ✅ **Provides clear next steps** after each phase

### Upgrade Integration

Templates seamlessly upgrade to full system:
- ✅ **Zero data loss** during upgrade
- ✅ **Backward compatibility** maintained
- ✅ **Optional feature activation** as needed
- ✅ **Gradual complexity introduction**

---

## 🚨 Quick-Start Command Implementation with Kiro-Native

### Kiro Integration for Quickstart

```bash
# Initialize kiro-native for quickstart templates
initialize_quickstart_kiro() {
    local template_type=$1
    local milestone_id=$2
    
    # Source kiro-native components
    source "templates/commands/milestone/_shared/kiro-native.md"
    
    # Set quickstart-specific kiro configuration
    export KIRO_POLICY_MODE="mandatory"
    export KIRO_ENFORCEMENT_LEVEL="flexible"  # Allow auto-progression
    export KIRO_VISUALIZATION_MODE="progressive"  # Start simple, reveal gradually
    
    # Configure auto-approval for quickstart
    export KIRO_DESIGN_APPROVAL=false
    export KIRO_SPEC_APPROVAL=false
    export KIRO_TASK_APPROVAL=false
    export KIRO_EXECUTE_APPROVAL=false
    
    # Initialize kiro system
    initialize_kiro_native
    
    # Apply quickstart simplifications
    configure_quickstart_kiro_mode "$template_type"
}

# Configure kiro mode based on template
configure_quickstart_kiro_mode() {
    local template_type=$1
    
    case "$template_type" in
        "personal")
            # Solo projects: fully automated phases
            export KIRO_AUTO_PROGRESS=true
            export KIRO_SHOW_PHASES=false
            ;;
        "team")
            # Team projects: show phase names
            export KIRO_AUTO_PROGRESS=true
            export KIRO_SHOW_PHASES=true
            ;;
        "api"|"frontend")
            # Technical projects: show deliverables
            export KIRO_AUTO_PROGRESS=false
            export KIRO_SHOW_PHASES=true
            export KIRO_SHOW_DELIVERABLES=true
            ;;
        "bugfix")
            # Quick fixes: compressed phases
            export KIRO_AUTO_PROGRESS=true
            export KIRO_COMPRESSED_PHASES=true
            ;;
    esac
}
```

## 🚨 Quick-Start Command Implementation

### Template Structure
```
templates/commands/milestone/quickstart/
├── personal.md          # Personal project template
├── team.md             # Team collaboration template  
├── api.md              # API development template
├── frontend.md         # Frontend development template
├── bugfix.md           # Bug fix template
└── _shared/
    ├── simple-config.md    # Simplified configuration
    ├── progress-simple.md  # Basic progress tracking
    └── upgrade-paths.md    # Progressive enhancement
```

### Command Integration
```bash
# Main milestone command detects quickstart
/milestone/quickstart <template> "<description>" 

# Internally routes to:
source "templates/commands/milestone/quickstart/<template>.md"
apply_template_with_progressive_ui "<description>"
```

### Success Metrics
After implementing quick-start templates:
- ✅ **70% complexity reduction** for new users
- ✅ **Sub-5-minute** first milestone creation
- ✅ **Clear upgrade path** to advanced features
- ✅ **Zero feature loss** for existing users

---

**Remember:** Quick-start templates are your on-ramp to the full milestone system. Start simple, grow as needed!

You are creating quick-start templates for: $ARGUMENTS

Let me create the specific template based on your project type and provide immediate value with minimal complexity.