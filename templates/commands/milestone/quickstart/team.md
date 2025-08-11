---
allowed-tools: all
description: Team collaboration milestone template - Simple coordination without complexity
---

# 👥 Team Collaboration Milestone Template

**Simple team milestone with light coordination. No overwhelming enterprise features.**

## 🎯 What This Template Does

✅ **Creates a 2-week team milestone** with clear role coordination  
✅ **Light approval gates** - only where essential  
✅ **Simple task assignment** and progress visibility  
✅ **Team communication built-in** without complexity  

---

## 🚀 Quick Setup

```bash
# Create your team milestone
/milestone/quickstart/team "Your team project description"

# Example:
/milestone/quickstart/team "Build team messaging app"
```

**Team members join:** Each team member runs the same command to access the shared milestone.

---

## 📋 Team Milestone Structure

### **Week 1: Foundation & Planning**

**Sprint 1A: Team Alignment (Days 1-2)**
- **Focus**: Get everyone on the same page
- **Outcome**: Clear plan and task assignments
- **Coordination**: Team sync required

**Sprint 1B: Core Setup (Days 3-5)**
- **Focus**: Individual work on assigned components
- **Outcome**: Basic infrastructure in place
- **Coordination**: Daily check-ins

### **Week 2: Development & Integration**

**Sprint 2A: Feature Development (Days 6-9)**
- **Focus**: Parallel development of features
- **Outcome**: Individual features working
- **Coordination**: Integration planning

**Sprint 2B: Integration & Launch (Days 10-14)**
- **Focus**: Bringing it all together
- **Outcome**: Working team product
- **Coordination**: Final review and deployment

---

## 🎯 Milestone Configuration (Kiro-Native Foundation)

```yaml
milestone:
  id: "team-$(date +%Y%m%d-%H%M%S)"
  title: "$ARGUMENTS"
  type: "team_collaboration"
  duration: "14 days"
  complexity: "simple_team"
  
  # Kiro workflow (visible phases for team coordination)
  kiro_configuration:
    enabled: true
    mode: "semi_visible"  # Show phase names for team clarity
    visibility: "progressive"  # Reveal more as team advances
    auto_approval: false  # Light approval gates for coordination
    phase_weights:
      design: 15    # Planning and alignment (shown as "Team Alignment")
      spec: 25      # Requirements and setup (shown as "Core Setup")
      task: 20      # Feature implementation (shown as "Feature Development")
      execute: 40   # Integration and delivery (shown as "Integration & Launch")
  
  # Team coordination settings
  team:
    size: "small"  # 2-5 people
    coordination_level: "light"
    approval_gates: "essential_only"
    communication: "built_in"
    
  # Simple team tracking
  tracking:
    method: "shared_file"
    team_visibility: true
    daily_standups: false  # Optional, not required
    progress_display: "team_friendly"
    
  # Sprints mapped to kiro phases
  sprints:
    - name: "Team Alignment"
      kiro_phase: "design"
      duration: "2 days"
      coordination: "high"
      
    - name: "Core Setup"  
      kiro_phase: "spec"
      duration: "3 days"
      coordination: "medium"
      
    - name: "Feature Development"
      kiro_phase: "task"
      duration: "4 days"
      coordination: "low"
      
    - name: "Integration & Launch"
      kiro_phase: "execute"
      duration: "5 days"
      coordination: "high"
```

---

## 📝 Generated Team Tasks

### 🎯 **Sprint 1A: Team Alignment (Days 1-2)**

**Project Planning Session**
- [ ] **Team Lead**: Facilitate project planning meeting
- [ ] **Everyone**: Contribute to feature breakdown
- [ ] **Team Lead**: Document decisions and assignments
- **Success**: Clear project scope and individual assignments

**Technical Architecture**
- [ ] **Tech Lead**: Define technical approach
- [ ] **Everyone**: Review and provide input  
- [ ] **Tech Lead**: Finalize architecture decisions
- **Success**: Shared understanding of technical implementation

**Task Assignment & Setup**
- [ ] **Team Lead**: Assign tasks based on skills/interests
- [ ] **Everyone**: Accept assignments and ask questions
- [ ] **Everyone**: Set up development environment
- **Success**: Everyone knows their responsibilities

**🚦 Approval Gate**: Team lead confirms everyone is aligned before proceeding

---

### 🏗️ **Sprint 1B: Core Setup (Days 3-5)**

**Repository & Infrastructure**
- [ ] **DevOps Person**: Set up shared repository
- [ ] **DevOps Person**: Configure CI/CD basics
- [ ] **Everyone**: Clone and verify local setup
- **Success**: Everyone can contribute to shared codebase

**Core Components (Parallel Work)**
- [ ] **Backend Dev**: Set up API foundation
- [ ] **Frontend Dev**: Set up UI foundation  
- [ ] **Tester**: Set up testing framework
- **Success**: Basic infrastructure for each area

**Integration Preparation**
- [ ] **Everyone**: Create basic "hello world" in their area
- [ ] **Tech Lead**: Verify integration points work
- [ ] **Team**: Brief status sync
- **Success**: Components can communicate

**Daily Check-ins**: Quick 10-minute syncs (optional but recommended)

---

### ⚙️ **Sprint 2A: Feature Development (Days 6-9)**

**Individual Feature Work**
- [ ] **Person A**: Implement assigned feature A
- [ ] **Person B**: Implement assigned feature B
- [ ] **Person C**: Implement assigned feature C
- **Success**: Each feature works independently

**Cross-Team Coordination**
- [ ] **Everyone**: Update team on blockers/dependencies
- [ ] **Tech Lead**: Resolve integration conflicts
- [ ] **Everyone**: Help teammates when possible
- **Success**: No major blockers preventing progress

**Testing & Documentation**
- [ ] **Everyone**: Test their own features
- [ ] **Tester**: Create integration test plan
- [ ] **Everyone**: Document their components
- **Success**: Features are tested and documented

**Minimal Coordination**: Focus on individual productivity

---

### 🚀 **Sprint 2B: Integration & Launch (Days 10-14)**

**Feature Integration**
- [ ] **Tech Lead**: Coordinate feature merging
- [ ] **Everyone**: Support integration testing
- [ ] **Team**: Resolve integration issues together
- **Success**: All features work together

**Quality Assurance**
- [ ] **Tester**: Run full test suite
- [ ] **Everyone**: User acceptance testing
- [ ] **Team**: Fix critical bugs together
- **Success**: Product meets quality standards

**Launch Preparation**
- [ ] **DevOps Person**: Prepare deployment
- [ ] **Team Lead**: Final review and signoff
- [ ] **Everyone**: Prepare launch materials
- **Success**: Ready for production deployment

**🚦 Approval Gate**: Team reviews final product before launch

---

## 👥 Team Coordination Features

### Simple Task Assignment

```bash
# Assign task to team member
/milestone/assign "Setup API foundation" @john

# Check your assignments
/milestone/mytasks

# See team progress
/milestone/status --team
```

### Light Approval Gates

**Gate 1: Project Alignment**
- **Required**: Team lead approval
- **Purpose**: Ensure everyone understands the plan
- **Time**: 30 minutes max

**Gate 2: Launch Readiness**
- **Required**: Team consensus
- **Purpose**: Quality check before deployment
- **Time**: 1 hour max

### Team Progress Display

```
Team Project: Build team messaging app
Overall Progress: ████████░ 78% (Day 11 of 14)

SPRINT STATUS:
✅ Team Alignment     (100% complete)
✅ Core Setup        (100% complete)
✅ Feature Development (100% complete)
🔄 Integration & Launch (67% complete)

TEAM PROGRESS:
👤 John (Backend):     ████████░ 89%
👤 Sarah (Frontend):   ███████░░ 75%  
👤 Mike (Testing):     ██████░░░ 67%

NEXT UP: Integration testing and deployment prep
BLOCKERS: None 🎉
```

---

## 🤝 Team Communication

### Built-in Team Updates

```bash
# Quick team update
/milestone/update --team "Finished user authentication, starting on chat features"

# Check team updates
/milestone/status --updates

# Flag blocker for team
/milestone/blocker "Need help with database schema"
```

### Simple Daily Sync (Optional)

```
=== DAILY TEAM SYNC ===
Date: Day 8 of 14

YESTERDAY:
👤 John: Completed user login API
👤 Sarah: Built message UI components
👤 Mike: Set up automated testing

TODAY:
👤 John: Working on chat room API
👤 Sarah: Implementing real-time messaging
👤 Mike: Testing user workflows

BLOCKERS:
👤 Sarah: Need API endpoint for message history
   → John will have this ready by lunch

TEAM ENERGY: High 🚀
ON TRACK: Yes ✅
```

---

## 🎉 Team Success Celebration

When your team completes the milestone:

```
🎉 TEAM SUCCESS! 🎉

"Build team messaging app" completed in 13 days!

👥 TEAM STATS:
✅ Tasks Completed: 24/24
⏱️  Total Team Time: 156 hours
🤝 Collaboration Score: Excellent
🚀 Team Momentum: Very High

🏆 INDIVIDUAL CONTRIBUTIONS:
👤 John: 8 tasks, Backend excellence
👤 Sarah: 9 tasks, Frontend innovation  
👤 Mike: 7 tasks, Quality champion

🌟 WHAT'S NEXT FOR YOUR TEAM?
  a) Start another team project
  b) Try advanced milestone features
  c) Celebrate your success! 🍕

Team choice: _
```

---

## 🔄 Upgrade Options

### Stay Simple
```bash
# Create another team project
/milestone/quickstart/team "Team expense tracker app"
```

### Add Advanced Features
```bash
# Enable advanced team features
/milestone/upgrade --enable-enterprise milestone-002
```

### Full Milestone System
```bash
# Access all advanced features
/milestone/plan "Complex multi-team enterprise project"
```

---

## 💡 Team Collaboration Tips

### 🎯 **Effective Coordination**
- Keep approval gates minimal and fast
- Focus on outcomes, not process
- Celebrate individual contributions

### 💬 **Communication**
- Use built-in updates for transparency
- Flag blockers immediately
- Help teammates when you can

### ⚡ **Productivity**
- Parallel work whenever possible
- Minimize coordination overhead
- Trust your team members

### 🎉 **Team Culture**
- Celebrate small wins together
- Share knowledge and learnings
- Support each other through challenges

---

## 🚨 Implementation

This template automatically:
- ✅ **Creates shared milestone tracking** accessible to all team members
- ✅ **Sets up light coordination** without overwhelming process
- ✅ **Enables task assignment** and progress visibility
- ✅ **Provides team communication** built into milestone system
- ✅ **Includes minimal approval gates** only where essential

**Generated Milestone Structure:**
```
.milestones/
├── team-$(timestamp)/
│   ├── milestone.yaml          # Team milestone definition
│   ├── assignments.yaml        # Task assignments by person
│   ├── team-progress.yaml      # Shared progress tracking
│   ├── communication.md        # Team updates and blockers
│   └── celebration.md          # Team success celebration
```

**Team Access (Kiro-Native):**
```bash
# Each team member accesses the same kiro-native milestone
get_team_milestone() {
    local milestone_id="$1"
    
    # Source kiro-native components
    source "templates/commands/milestone/_shared/kiro-native.md"
    source "templates/commands/milestone/_shared/kiro-visualizer.md"
    
    # Initialize kiro with team-visible phases
    export KIRO_POLICY_MODE="mandatory"
    export KIRO_AUTO_PROGRESS=false  # Manual progression for coordination
    export KIRO_SHOW_PHASES=true     # Show phase names to team
    export KIRO_SHOW_DELIVERABLES=false  # Hide deliverables initially
    initialize_kiro_native
    
    # Load shared milestone state
    load_team_milestone_state "$milestone_id"
    
    # Show personalized kiro-aware view for this team member
    display_team_member_kiro_view "$USER" "$milestone_id"
    
    # Enable team coordination features with kiro tracking
    enable_team_features
    track_kiro_phase_progression "$milestone_id"
}

# Create team milestone with kiro workflow
create_team_milestone() {
    local project_description="$1"
    local milestone_id="team-$(date +%Y%m%d-%H%M%S)"
    
    # Initialize kiro-native for team
    initialize_team_kiro
    
    # Create kiro tasks with team assignments
    create_kiro_native_task "$milestone_id" "Project planning and alignment"
    create_kiro_native_task "$milestone_id" "Core infrastructure setup"
    create_kiro_native_task "$milestone_id" "Feature development"
    create_kiro_native_task "$milestone_id" "Integration and launch"
    
    # Distribute tasks across team members
    distribute_team_tasks "$milestone_id"
    
    echo "✅ Team milestone ready with kiro workflow!"
    echo "📊 Phases visible for team coordination"
}
```

---

**Your team is ready to build something amazing together! Focus on collaboration, not complexity.**