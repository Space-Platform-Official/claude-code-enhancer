---
allowed-tools: all
description: Frontend development milestone template - UI-focused with user experience emphasis
---

# 🎨 Frontend Development Milestone Template

**UI-focused milestone for React, Vue, Angular projects. User experience driven development.**

## 🎯 What This Template Does

✅ **Creates frontend-focused milestone structure** with UX best practices  
✅ **Component-driven development** approach for maintainable UI  
✅ **Built-in responsive and accessibility testing** for inclusive design  
✅ **User experience validation** throughout development process  

---

## 🚀 Quick Setup

```bash
# Create your frontend milestone
/milestone/quickstart/frontend "Your frontend project description"

# Example:
/milestone/quickstart/frontend "Shopping cart component with checkout flow"
```

**Ready to design and build!** Your frontend development pipeline includes design, testing, and UX validation.

---

## 📋 Frontend Development Structure

### **Phase 1: Design & Planning (Days 1-2)**
- **Focus**: User experience and component design
- **Outcome**: Clear UI specifications and component structure
- **Key**: Design before you code

### **Phase 2: Component Development (Days 3-6)**  
- **Focus**: Build reusable components with interactivity
- **Outcome**: Working UI components with proper state management
- **Key**: Component-driven development

### **Phase 3: Integration & Styling (Days 7-8)**
- **Focus**: Component integration and responsive design
- **Outcome**: Cohesive user interface that works on all devices
- **Key**: Responsive and accessible by default

### **Phase 4: Testing & Polish (Days 9-10)**
- **Focus**: User experience testing and final polish
- **Outcome**: Production-ready frontend with excellent UX
- **Key**: User-tested and polished

---

## 🎯 Milestone Configuration (Kiro-Native Foundation)

```yaml
milestone:
  id: "frontend-$(date +%Y%m%d-%H%M%S)"
  title: "$ARGUMENTS"
  type: "frontend_development"
  duration: "10 days"
  complexity: "ui_focused"
  
  # Kiro workflow (visual progress for UI development)
  kiro_configuration:
    enabled: true
    mode: "visual_progress"  # Show visual progress for UI
    visibility: "progressive"  # Show progress with user context
    auto_approval: false  # Manual approval for UX validation
    phase_weights:
      design: 20    # Design and planning (shown as "Design & Planning")
      spec: 35      # Component development (shown as "Component Development") 
      task: 25      # Integration and styling (shown as "Integration & Styling")
      execute: 20   # Testing and polish (shown as "Testing & Polish")
  
  # Frontend development settings
  ui_focus:
    component_driven: true
    responsive_first: true
    accessibility_required: true
    user_testing: true
    
  # Frontend-specific tracking
  tracking:
    method: "visual_progress"
    component_coverage: true
    accessibility_score: true
    performance_metrics: true
    user_feedback: true
    
  # Phases mapped to kiro workflow
  phases:
    - name: "Design & Planning"
      kiro_phase: "design"
      duration: "2 days"
      focus: "ux_and_component_design"
      deliverables: ["wireframes", "component_specs", "design_system"]
      
    - name: "Component Development"
      kiro_phase: "spec"
      duration: "4 days"
      focus: "component_implementation"
      deliverables: ["components", "state_management", "interactive_ui"]
      
    - name: "Integration & Styling"
      kiro_phase: "task"
      duration: "2 days"
      focus: "responsive_integration"
      deliverables: ["responsive_ui", "accessibility", "performance_optimized"]
      
    - name: "Testing & Polish"
      kiro_phase: "execute"
      duration: "2 days"
      focus: "ux_validation_and_polish"
      deliverables: ["user_tested_ui", "production_ready_ui"]
```

---

## 📝 Generated Frontend Tasks

### 🎨 **Phase 1: Design & Planning (Days 1-2)**

**User Experience Design**
- [ ] Create user flow diagrams
- [ ] Design wireframes for key screens
- [ ] Define user interaction patterns
- **Success**: Clear user experience documented

**Component Architecture**
- [ ] Break UI into reusable components
- [ ] Define component props and state structure
- [ ] Plan component hierarchy and data flow
- **Success**: Component architecture diagram complete

**Design System Planning**
- [ ] Define color palette and typography
- [ ] Create spacing and layout system
- [ ] Plan responsive breakpoints
- **Success**: Design system guidelines documented

**Accessibility Planning**
- [ ] Plan keyboard navigation patterns
- [ ] Define ARIA labels and roles
- [ ] Consider screen reader experience
- **Success**: Accessibility requirements documented

---

### ⚙️ **Phase 2: Component Development (Days 3-6)**

**Core Components Implementation**
- [ ] Build basic UI components (buttons, inputs, cards)
- [ ] Implement component styling and themes
- [ ] Add component documentation and examples
- **Success**: Reusable component library functional

**Interactive Components**
- [ ] Implement stateful components with user interactions
- [ ] Add form handling and validation
- [ ] Create dynamic UI components (modals, dropdowns)
- **Success**: All interactive elements work smoothly

**State Management**
- [ ] Set up state management solution (Redux, Zustand, etc.)
- [ ] Implement application state structure
- [ ] Connect components to global state
- **Success**: State flows correctly through application

**Component Testing**
- [ ] Write unit tests for component logic
- [ ] Add component integration tests
- [ ] Test component accessibility features
- **Success**: Components are thoroughly tested

---

### 🎯 **Phase 3: Integration & Styling (Days 7-8)**

**Component Integration**
- [ ] Integrate components into complete views
- [ ] Implement navigation and routing
- [ ] Connect to data sources (APIs, mock data)
- **Success**: Complete user workflows functional

**Responsive Design**
- [ ] Implement responsive layouts for all screen sizes
- [ ] Test on mobile, tablet, and desktop devices
- [ ] Optimize touch interactions for mobile
- **Success**: UI works perfectly on all devices

**Accessibility Implementation**
- [ ] Add proper ARIA labels and roles
- [ ] Implement keyboard navigation
- [ ] Test with screen reader
- **Success**: Accessibility audit passes

**Performance Optimization**
- [ ] Optimize bundle size and loading performance
- [ ] Implement lazy loading for heavy components
- [ ] Add performance monitoring
- **Success**: Performance benchmarks met

---

### ✨ **Phase 4: Testing & Polish (Days 9-10)**

**User Experience Testing**
- [ ] Conduct user testing sessions
- [ ] Test user workflows end-to-end
- [ ] Gather feedback on usability
- **Success**: User feedback incorporated and positive

**Cross-Browser Testing**
- [ ] Test on Chrome, Firefox, Safari, Edge
- [ ] Fix browser-specific issues
- [ ] Verify consistent behavior across browsers
- **Success**: Consistent experience across all browsers

**Visual Polish**
- [ ] Refine animations and transitions
- [ ] Perfect spacing, typography, and visual hierarchy
- [ ] Add micro-interactions and delightful details
- **Success**: UI feels polished and professional

**Production Preparation**
- [ ] Optimize build process and deployment
- [ ] Set up error tracking and analytics
- [ ] Create deployment documentation
- **Success**: Ready for production deployment

---

## 🎨 Component-Driven Development

### Component Library Structure

```bash
# Preview your components
/milestone/preview --components

# Test components in isolation
/milestone/test --component Button

# Generate component documentation
/milestone/docs --components
```

### Component Development Flow

```
COMPONENT WORKFLOW:
Design → Build → Test → Document → Integrate

1. Design component interface (props, behavior)
2. Build component with styling
3. Test component functionality and accessibility
4. Document component usage and examples
5. Integrate into larger UI patterns
```

### Component Progress Tracking

```
Frontend Development: Shopping cart component with checkout flow
Progress: ██████░░░ 67% (Day 7 of 10)

COMPONENT STATUS:
✅ Button           (Complete + Tested)
✅ Input            (Complete + Tested)
✅ Card             (Complete + Tested)
🔄 ShoppingCart     (In Progress)
⏳ CheckoutForm     (Not Started)
⏳ PaymentForm      (Not Started)

INTEGRATION STATUS:
✅ Component Library (100% complete)
🔄 Cart Page        (75% complete)  
⏳ Checkout Flow    (0% complete)

TODAY'S FOCUS: Complete shopping cart component
NEXT UP: Start checkout form integration
```

---

## 📱 Responsive & Accessibility Features

### Responsive Testing

```bash
# Test responsive design
/milestone/test --responsive

# Preview on different screen sizes
/milestone/preview --mobile --tablet --desktop

# Generate responsive report
/milestone/report --responsive
```

### Accessibility Validation

```bash
# Run accessibility audit
/milestone/test --accessibility

# Check keyboard navigation
/milestone/test --keyboard

# Screen reader testing
/milestone/test --screen-reader
```

### Device Testing Output

```
=== RESPONSIVE & ACCESSIBILITY TESTING ===

RESPONSIVE DESIGN:
├── Mobile (320-768px):    ✅ Excellent
├── Tablet (768-1024px):   ✅ Excellent  
├── Desktop (1024px+):     ✅ Excellent
└── Large Desktop (1440px+): ✅ Excellent

ACCESSIBILITY SCORE: 98/100
├── Keyboard Navigation:   ✅ Full support
├── Screen Reader:         ✅ Excellent
├── Color Contrast:        ✅ WCAG AA compliant
├── Focus Management:      ✅ Clear focus indicators
└── ARIA Implementation:   ✅ Proper labels and roles

PERFORMANCE:
├── First Paint:          ✅ 0.8s (Target: <1s)
├── Largest Content:      ✅ 1.2s (Target: <2s)
├── Interactive:          ✅ 1.5s (Target: <3s)
└── Bundle Size:          ✅ 245KB (Target: <500KB)

BROWSER COMPATIBILITY:
├── Chrome:               ✅ Perfect
├── Firefox:              ✅ Perfect
├── Safari:               ✅ Perfect
└── Edge:                 ✅ Perfect
```

---

## 🎯 User Experience Validation

### Built-in User Testing

```bash
# Set up user testing session
/milestone/user-test --setup

# Collect user feedback
/milestone/user-test --feedback

# Analyze user behavior
/milestone/user-test --analyze
```

### UX Metrics Tracking

```bash
# Track user interactions
/milestone/metrics --interactions

# Measure task completion rates
/milestone/metrics --tasks

# Monitor user satisfaction
/milestone/metrics --satisfaction
```

### User Testing Results

```
=== USER EXPERIENCE VALIDATION ===

USER TESTING SESSION: 5 participants, 20 minutes each

TASK COMPLETION RATES:
├── Add item to cart:     100% (Average: 12s)
├── Update quantities:    100% (Average: 8s)
├── Proceed to checkout:  100% (Average: 5s)
├── Complete purchase:    80% (Average: 45s)
└── Overall workflow:     95% success rate

USER SATISFACTION: 4.6/5
├── Ease of use:         4.8/5 
├── Visual design:       4.7/5
├── Performance:         4.5/5
└── Mobile experience:   4.4/5

KEY FEEDBACK:
👍 "The interface is intuitive and clean"
👍 "Shopping cart updates feel instant"
⚠️  "Checkout form could be shorter"
⚠️  "Payment options need better labels"

IMPROVEMENTS IDENTIFIED:
1. Streamline checkout form (reduce fields)
2. Improve payment option clarity
3. Add progress indicator for checkout
```

---

## 🎉 Frontend Success Celebration

When your frontend is complete:

```
🎉 FRONTEND DEPLOYMENT SUCCESS! 🎉

"Shopping cart component with checkout flow" is live!

🎨 UI STATS:
✅ Components: 12 built and tested
📱 Responsive: Works on all devices
♿ Accessibility: 98/100 score
⚡ Performance: All metrics in green
👥 User Testing: 95% task completion rate

🧩 COMPONENT LIBRARY:
   Button, Input, Card, Modal
   ShoppingCart, CheckoutForm
   PaymentForm, SuccessPage
   LoadingSpinner, ErrorBoundary
   Navigation, Footer

📊 PERFORMANCE METRICS:
   🚀 First Paint: 0.8s
   📦 Bundle Size: 245KB
   📱 Mobile Score: 96/100
   ♿ Accessibility: 98/100

🌟 USER FEEDBACK:
   "Interface is intuitive and clean" - User A
   "Shopping experience feels smooth" - User B
   "Works great on mobile" - User C

🎯 WHAT'S NEXT?
  a) Build another frontend component
  b) Add advanced UI features
  c) Integrate with backend API

Your choice: _
```

---

## 🔄 Upgrade Options

### Build More Components
```bash
# Create related frontend component
/milestone/quickstart/frontend "User profile dashboard"
```

### Add Advanced Features
```bash
# Enable advanced frontend features
/milestone/upgrade --enable-animations --enable-pwa milestone-002
```

### Full Application Development
```bash
# Plan complete frontend application
/milestone/plan "Full e-commerce web application"
```

---

## 💡 Frontend Development Tips

### 🎨 **Design First**
- Always start with user experience design
- Think mobile-first, scale up to desktop
- Plan for accessibility from the beginning

### 🧩 **Component-Driven**
- Build reusable components
- Test components in isolation
- Document component APIs and examples

### 📱 **Responsive & Accessible**
- Test on real devices regularly
- Use semantic HTML and ARIA labels
- Ensure keyboard navigation works everywhere

### 👥 **User-Centered**
- Test with real users early and often
- Measure actual user behavior
- Iterate based on user feedback

---

## 🚨 Implementation

This template automatically:
- ✅ **Creates component-driven development workflow** with isolation testing
- ✅ **Sets up responsive design testing** across all device sizes
- ✅ **Includes accessibility validation** with WCAG compliance checking
- ✅ **Provides user testing framework** for UX validation
- ✅ **Generates component documentation** automatically from code

**Generated Milestone Structure:**
```
.milestones/
├── frontend-$(timestamp)/
│   ├── milestone.yaml          # Frontend milestone definition
│   ├── component-specs.md      # Component architecture and design
│   ├── design-system.md        # Colors, typography, spacing guidelines
│   ├── accessibility-plan.md   # Accessibility requirements and testing
│   ├── user-testing/           # User testing results and feedback
│   └── component-docs/         # Generated component documentation
```

**Frontend Development Workflow:**
```bash
# Component-driven frontend development (kiro-native)
develop_frontend_milestone() {
    local frontend_description="$1"
    
    # Initialize kiro with visual progress for UI
    export KIRO_POLICY_MODE="mandatory"
    export KIRO_AUTO_PROGRESS=false  # Manual for UX validation gates
    export KIRO_SHOW_PHASES=true     # Show progressive UI phases
    export KIRO_VISUAL_MODE=true     # Visual progress for UI development
    initialize_kiro_native
    
    # Initialize frontend-focused milestone
    initialize_frontend_milestone "$frontend_description"
    
    # Create kiro tasks with UI-focused deliverables
    create_kiro_native_task "$milestone_id" "Design and component planning"
    set_task_deliverables "$milestone_id" 1 "wireframes" "component_specs" "design_system"
    
    create_kiro_native_task "$milestone_id" "Component development and state"
    set_task_deliverables "$milestone_id" 2 "components" "state_management" "interactive_ui"
    
    create_kiro_native_task "$milestone_id" "Integration and responsive styling"
    set_task_deliverables "$milestone_id" 3 "responsive_ui" "accessibility" "performance_optimized"
    
    create_kiro_native_task "$milestone_id" "Testing and UX polish"
    set_task_deliverables "$milestone_id" 4 "user_tested_ui" "production_ready_ui"
    
    # Set up component development framework with kiro tracking
    setup_component_development
    
    # Enable responsive testing
    enable_responsive_testing
    
    # Configure accessibility validation
    setup_accessibility_testing
    
    # Set up user testing framework
    configure_user_testing
    
    echo "✅ Frontend milestone ready with kiro workflow!"
    echo "🎨 Visual progress tracking for UI development"
    echo "👥 UX validation gates via kiro approvals"
}
```

---

**Your frontend is ready to delight users! Focus on great user experience, accessibility, and performance.**