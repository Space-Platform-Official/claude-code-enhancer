#!/bin/bash

# Simple Milestone Status Dashboard
# Usage: ./milestone-status.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 MILESTONE STATUS DASHBOARD${NC}"
echo "================================="

# Check if milestone exists
if [[ ! -f ".milestones/current.yaml" ]]; then
    echo "No active milestone found."
    echo ""
    echo "To create a milestone:"
    echo "  /milestone create \"Milestone Title\" --hours 8"
    exit 0
fi

# Parse YAML (simple parsing for our structure)
MILESTONE_TITLE=$(grep "^title:" .milestones/current.yaml | sed 's/title: "//' | sed 's/"//')
MILESTONE_ID=$(grep "^milestone_id:" .milestones/current.yaml | sed 's/milestone_id: "//' | sed 's/"//')
CREATED=$(grep "^created:" .milestones/current.yaml | sed 's/created: "//' | sed 's/"//')
TARGET=$(grep "^target_completion:" .milestones/current.yaml | sed 's/target_completion: "//' | sed 's/"//')

TOTAL_TASKS=$(grep "total_tasks:" .milestones/current.yaml | sed 's/.*total_tasks: //')
COMPLETED_TASKS=$(grep "completed_tasks:" .milestones/current.yaml | sed 's/.*completed_tasks: //')
IN_PROGRESS_TASKS=$(grep "in_progress_tasks:" .milestones/current.yaml | sed 's/.*in_progress_tasks: //')
COMPLETION_PCT=$(grep "completion_percentage:" .milestones/current.yaml | sed 's/.*completion_percentage: //')
HOURS_REMAINING=$(grep "estimated_hours_remaining:" .milestones/current.yaml | sed 's/.*estimated_hours_remaining: //')

CURRENT_BRANCH=$(git branch --show-current)

echo ""
echo -e "${GREEN}📋 ${MILESTONE_TITLE}${NC}"
echo "   ID: ${MILESTONE_ID}"
echo "   Created: ${CREATED}"
echo "   Target: ${TARGET}"
echo ""

echo -e "${BLUE}📊 PROGRESS${NC}"
echo "   Tasks: ${COMPLETED_TASKS}/${TOTAL_TASKS} completed (${COMPLETION_PCT}%)"
if [[ $IN_PROGRESS_TASKS -gt 0 ]]; then
    echo "   In Progress: ${IN_PROGRESS_TASKS} tasks"
fi
echo "   Estimated Hours Remaining: ${HOURS_REMAINING}"
echo ""

# Progress bar
PROGRESS_BAR=""
PROGRESS_WIDTH=20
FILLED_WIDTH=$((COMPLETION_PCT * PROGRESS_WIDTH / 100))
for ((i=0; i<FILLED_WIDTH; i++)); do
    PROGRESS_BAR+="█"
done
for ((i=FILLED_WIDTH; i<PROGRESS_WIDTH; i++)); do
    PROGRESS_BAR+="░"
done

echo -e "${GREEN}   [${PROGRESS_BAR}] ${COMPLETION_PCT}%${NC}"
echo ""

echo -e "${BLUE}🔧 GIT STATUS${NC}"
echo "   Branch: ${CURRENT_BRANCH}"
echo "   Auto-commit: enabled"
echo ""

echo -e "${BLUE}📋 TASK BREAKDOWN${NC}"
echo "   ✅ Completed: ${COMPLETED_TASKS}"
echo "   🔄 In Progress: ${IN_PROGRESS_TASKS}"
echo "   ⏳ Pending: $((TOTAL_TASKS - COMPLETED_TASKS - IN_PROGRESS_TASKS))"
echo ""

# Show recent commits for this milestone
echo -e "${BLUE}📝 RECENT COMMITS${NC}"
git log --oneline --grep="milestone:" -5 2>/dev/null || echo "   No milestone commits yet"

echo ""
echo "💡 Next steps:"
echo "   • Complete in-progress tasks"
echo "   • Run /milestone update to sync progress"
echo "   • Use /milestone complete when finished"