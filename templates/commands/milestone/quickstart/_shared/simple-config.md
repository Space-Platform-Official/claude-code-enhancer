# Simple Configuration for Quick-Start Templates

## Simplified Milestone Configuration

Quick-start templates use minimal configuration to reduce complexity for new users.

### Core Principles

- **Auto-configuration**: Smart defaults eliminate configuration decisions
- **Hidden complexity**: Advanced features available but not visible initially
- **Progressive enhancement**: Easy upgrade path to full system
- **Zero setup**: Templates work immediately without configuration

### Simple Configuration Schema

```yaml
# Minimal quick-start configuration
quickstart_config:
  template_type: "personal|team|api|frontend|bugfix"
  complexity_level: "simple"
  auto_configuration: true
  hidden_features:
    - kiro_workflow
    - hybrid_storage
    - advanced_dependencies
    - enterprise_features
    - risk_assessment
    - multi_agent_coordination
    
  visible_features:
    - basic_tasks
    - simple_progress
    - clear_outcomes
    - upgrade_prompts
    
  storage:
    backend: "file"  # Always file-based for simplicity
    location: ".milestones/quickstart/"
    auto_cleanup: true
    
  ui:
    display_mode: "simple"
    progress_style: "percentage_bar"
    complexity_hints: false
    advanced_options: false
```

### Template-Specific Defaults

```yaml
# Personal project defaults
personal_defaults:
  duration: "7 days"
  working_hours_per_day: 2
  buffer_percentage: 25
  phases: 4
  max_tasks_per_phase: 3
  
# Team collaboration defaults  
team_defaults:
  duration: "14 days"
  team_size: "2-5"
  coordination_level: "light"
  approval_gates: "essential_only"
  daily_standups: false
  
# API development defaults
api_defaults:
  duration: "10 days"
  testing_first: true
  documentation_required: true
  security_gates: true
  coverage_target: 85
  
# Frontend development defaults
frontend_defaults:
  duration: "10 days"
  component_driven: true
  responsive_required: true
  accessibility_required: true
  user_testing: true
  
# Bug fix defaults
bugfix_defaults:
  duration: "2 days"
  root_cause_analysis: true
  minimal_risk_approach: true
  regression_testing: true
  monitoring_required: true
```

### Auto-Configuration Functions

```bash
# Apply template-specific configuration
apply_quickstart_config() {
    local template_type="$1"
    local description="$2"
    
    case "$template_type" in
        "personal")
            apply_personal_defaults "$description"
            ;;
        "team")
            apply_team_defaults "$description"
            ;;
        "api")
            apply_api_defaults "$description"
            ;;
        "frontend")
            apply_frontend_defaults "$description"
            ;;
        "bugfix")
            apply_bugfix_defaults "$description"
            ;;
    esac
    
    # Common quick-start settings
    set_simple_storage
    set_simple_ui
    hide_advanced_features
    enable_upgrade_prompts
}

# Personal project configuration
apply_personal_defaults() {
    local description="$1"
    
    cat > .milestones/quickstart/config.yaml << EOF
milestone:
  type: "personal_project"
  title: "$description"
  duration: "7 days"
  complexity: "simple"
  
phases:
  foundation:
    name: "Foundation"
    duration: "2 days"
    focus: "setup_and_basic_structure"
    
  core:
    name: "Core Features"
    duration: "3 days"
    focus: "main_functionality"
    
  polish:
    name: "Polish"
    duration: "1 day"
    focus: "testing_and_refinement"
    
  launch:
    name: "Launch"
    duration: "1 day"
    focus: "deployment_and_documentation"

tracking:
  method: "simple_file"
  progress_display: "percentage_with_phases"
  daily_goals: true
  celebration: true
EOF
}

# Team collaboration configuration
apply_team_defaults() {
    local description="$1"
    
    cat > .milestones/quickstart/config.yaml << EOF
milestone:
  type: "team_collaboration"
  title: "$description"
  duration: "14 days"
  complexity: "simple_team"
  
team:
  coordination_level: "light"
  approval_gates: "minimal"
  size: "small"
  
sprints:
  alignment:
    name: "Team Alignment"
    duration: "2 days"
    coordination: "high"
    
  setup:
    name: "Core Setup"
    duration: "3 days"
    coordination: "medium"
    
  development:
    name: "Feature Development"
    duration: "4 days"
    coordination: "low"
    
  integration:
    name: "Integration & Launch"
    duration: "5 days"
    coordination: "high"

tracking:
  method: "shared_file"
  team_visibility: true
  assignment_tracking: true
  light_coordination: true
EOF
}
```

### Upgrade Configuration

```yaml
# Progressive upgrade paths
upgrade_paths:
  from_quickstart_to_enhanced:
    features_to_enable:
      - kiro_workflow
      - advanced_dependencies
      - team_coordination
    configuration_changes:
      - storage_backend: "hybrid"
      - ui_mode: "rich"
      - complexity_level: "enhanced"
      
  from_quickstart_to_full:
    features_to_enable:
      - all_milestone_features
    configuration_changes:
      - storage_backend: "database"
      - ui_mode: "enterprise"
      - complexity_level: "full"
      
# Upgrade detection and prompts
upgrade_triggers:
  milestone_count: 5  # Suggest upgrade after 5 quick-start milestones
  success_rate: 80   # Suggest upgrade if user has 80%+ success rate
  feature_requests: 3 # Suggest upgrade if user asks about advanced features 3 times
```

### Implementation Functions

```bash
# Initialize simple configuration
initialize_simple_config() {
    local template_type="$1"
    local description="$2"
    
    # Create quickstart directory
    mkdir -p .milestones/quickstart
    
    # Apply template-specific configuration
    apply_quickstart_config "$template_type" "$description"
    
    # Set up simple tracking
    initialize_simple_tracking
    
    # Hide advanced features
    configure_simple_ui
    
    echo "✅ Simple configuration applied for $template_type template"
}

# Simple tracking setup
initialize_simple_tracking() {
    cat > .milestones/quickstart/progress.yaml << EOF
progress:
  current_phase: 1
  overall_percentage: 0
  phases_completed: 0
  total_phases: 4
  
  phase_progress:
    foundation: 0
    core: 0
    polish: 0
    launch: 0
    
  daily_tracking:
    enabled: true
    current_day: 1
    
  celebration:
    enabled: true
    milestones_completed: 0
EOF
}

# Configure simple UI
configure_simple_ui() {
    cat > .milestones/quickstart/ui-config.yaml << EOF
ui:
  display_mode: "simple"
  show_advanced_options: false
  show_complex_metrics: false
  show_enterprise_features: false
  
  progress_display:
    style: "progress_bar"
    show_percentages: true
    show_time_estimates: true
    show_phase_breakdown: true
    
  upgrade_prompts:
    enabled: true
    frequency: "completion"
    style: "friendly"
EOF
}
```

This configuration system ensures quick-start templates are immediately usable with smart defaults while maintaining clear upgrade paths to the full milestone system.