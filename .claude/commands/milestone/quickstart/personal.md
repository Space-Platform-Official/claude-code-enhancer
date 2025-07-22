---
allowed-tools: all
description: Personal project milestone template - Simple, focused, productive
---

# 🧑‍💻 Personal Project Milestone Template

**Simple milestone for solo developers. Get productive in 2 minutes.**

## 🎯 What This Template Does

✅ **Creates a simple 1-week milestone** with clear daily tasks  
✅ **No complex workflows** - just you and your code  
✅ **Built-in progress tracking** to stay motivated  
✅ **Clear success criteria** so you know when you're done  

---

## 🚀 Quick Setup

```bash
# Create your personal milestone
/milestone/quickstart/personal "Your project description"

# Example:
/milestone/quickstart/personal "Build a weather app with React"
```

**That's it!** Your milestone is ready. No configuration needed.

---

## 📋 Your Milestone Structure

### **Phase 1: Foundation (Days 1-2)**
- **Task**: Set up project structure and basic configuration
- **Outcome**: Working development environment
- **Time**: 2-4 hours

### **Phase 2: Core Features (Days 3-5)**  
- **Task**: Implement main functionality
- **Outcome**: Working core features
- **Time**: 6-10 hours

### **Phase 3: Polish (Day 6)**
- **Task**: Testing, styling, and refinements
- **Outcome**: Production-ready application
- **Time**: 2-4 hours

### **Phase 4: Launch (Day 7)**
- **Task**: Deploy and document
- **Outcome**: Live application with documentation
- **Time**: 1-2 hours

---

## 🎯 Milestone Configuration

```yaml
milestone:
  id: "personal-$(date +%Y%m%d-%H%M%S)"
  title: "$ARGUMENTS"
  type: "personal_project"
  duration: "7 days"
  complexity: "simple"
  
  # Simplified tracking - no enterprise features
  tracking:
    method: "file_based"
    progress_display: "simple"
    notifications: false
    
  # Personal project defaults
  defaults:
    working_hours_per_day: 2
    buffer_percentage: 25
    auto_archive: true
    
  phases:
    - name: "Foundation"
      duration: "2 days"
      tasks: ["setup", "config", "hello_world"]
      
    - name: "Core Features"
      duration: "3 days" 
      tasks: ["main_functionality", "data_handling", "user_interface"]
      
    - name: "Polish"
      duration: "1 day"
      tasks: ["testing", "styling", "optimization"]
      
    - name: "Launch"
      duration: "1 day"
      tasks: ["deployment", "documentation", "sharing"]
```

---

## 📝 Generated Tasks

### 🏗️ **Foundation Phase**

**Setup Project Structure**
- [ ] Initialize repository
- [ ] Set up development environment
- [ ] Create basic project files
- **Success**: `npm start` or equivalent works

**Basic Configuration**
- [ ] Configure build tools
- [ ] Set up linting/formatting
- [ ] Create initial component/module structure
- **Success**: Clean build with no errors

**Hello World Implementation**
- [ ] Create minimal working version
- [ ] Verify core libraries work
- [ ] Basic app renders/runs
- **Success**: Something visible/functional

---

### ⚙️ **Core Features Phase**

**Main Functionality**
- [ ] Implement primary feature
- [ ] Add core business logic
- [ ] Create main user workflow
- **Success**: Core use case works end-to-end

**Data Handling**
- [ ] Implement data storage/retrieval
- [ ] Add data validation
- [ ] Handle edge cases
- **Success**: Data flows correctly through app

**User Interface**
- [ ] Create main interface components
- [ ] Implement user interactions
- [ ] Add basic styling
- **Success**: App is usable and looks decent

---

### ✨ **Polish Phase**

**Testing**
- [ ] Add basic tests for core functionality
- [ ] Test user workflows manually
- [ ] Fix any bugs found
- **Success**: App works reliably

**Styling & UX**
- [ ] Improve visual design
- [ ] Enhance user experience
- [ ] Add responsive behavior
- **Success**: App looks professional

**Optimization**
- [ ] Clean up code
- [ ] Optimize performance
- [ ] Add error handling
- **Success**: Code is clean and robust

---

### 🚀 **Launch Phase**

**Deployment**
- [ ] Deploy to hosting platform
- [ ] Set up production environment
- [ ] Verify live version works
- **Success**: App is accessible online

**Documentation**
- [ ] Write basic README
- [ ] Document key features
- [ ] Add usage instructions
- **Success**: Others can understand and use your app

**Sharing**
- [ ] Share with friends/community
- [ ] Create demo/screenshots
- [ ] Gather initial feedback
- **Success**: Project is public and getting feedback

---

## 📊 Progress Tracking

### Simple Daily Check-ins

```bash
# Quick status check
/milestone/status

# Mark tasks complete as you go
/milestone/update --complete "setup project structure"

# See your progress
/milestone/status --simple
```

### Progress Display

```
Personal Project: Build a weather app with React
Progress: ████████░ 67% (Day 5 of 7)

✅ Foundation    (100% complete)
✅ Core Features (100% complete) 
🔄 Polish       (67% complete)
⏳ Launch       (0% complete)

Today's Focus: Testing and styling
Next Up: Add responsive design
```

---

## 🎉 Success Celebration

When you complete your milestone:

```
🎉 CONGRATULATIONS! 🎉

You completed "Build a weather app with React" in 6 days!

📊 YOUR STATS:
✅ Tasks Completed: 12/12
⏱️  Total Time: 14 hours
🚀 Success Rate: 100%
📈 Momentum: High

🌟 WHAT'S NEXT?
  a) Start another personal project
  b) Try a team collaboration milestone
  c) Learn advanced milestone features

Your choice: _
```

---

## 🔄 Upgrade Options

### Stay Simple
```bash
# Create another personal project
/milestone/quickstart/personal "Build a blog with Next.js"
```

### Add Team Features
```bash
# Try collaboration features
/milestone/quickstart/team "Family expense tracker"
```

### Full Milestone System
```bash
# Access all advanced features
/milestone/plan "Complex web application"
```

---

## 💡 Personal Project Tips

### 🎯 **Keep It Simple**
- Focus on one main feature
- Add nice-to-haves later
- Ship early, iterate fast

### ⏰ **Time Management**
- Work in 25-minute focused sessions
- Take breaks every 2 hours
- Track your daily progress

### 🔄 **Stay Motivated**
- Celebrate small wins
- Share progress with others
- Keep the end goal visible

### 📚 **Learn As You Go**
- Don't try to learn everything upfront
- Google problems as they come up
- Save interesting resources for later

---

## 🚨 Implementation

This template automatically:
- ✅ **Creates simple file-based tracking** (no database complexity)
- ✅ **Sets realistic time estimates** for solo developers
- ✅ **Provides clear daily focus** to maintain momentum
- ✅ **Includes built-in celebration** to maintain motivation
- ✅ **Offers upgrade paths** when ready for more features

**Generated Milestone Structure:**
```
.milestones/
├── personal-$(timestamp)/
│   ├── milestone.yaml           # Simple milestone definition
│   ├── tasks.md                # Daily task breakdown
│   ├── progress.txt            # Simple progress tracking
│   └── celebration.md          # Success celebration when done
```

**Command Integration:**
```bash
# This template creates a milestone using simplified config
create_personal_milestone() {
    local project_description="$1"
    
    # Create simplified milestone structure
    initialize_simple_milestone "personal" "$project_description"
    
    # Set personal project defaults
    configure_personal_settings
    
    # Generate phase-based tasks
    generate_personal_tasks "$project_description"
    
    # Setup simple progress tracking
    enable_simple_tracking
    
    echo "✅ Personal milestone ready! Start with: /milestone/execute"
}
```

---

**You're ready to build something awesome! Focus on progress, not perfection.**