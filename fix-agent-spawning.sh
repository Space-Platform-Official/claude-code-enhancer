#!/bin/bash

# Script to fix agent spawning across all commands
# This implements Task tool for true parallelism

echo "🚀 Fixing agent spawning across all commands..."

# Phase 2: Test commands that need fixing
TEST_COMMANDS=(
    "test/unit.md"
    "test/fix.md"
    "test/annotation.md"
    "test/performance.md"
    "test/integration.md"
    "test/e2e.md"
    "test/structure.md"
    "test/watch.md"
    "test/workflows/tdd.md"
    "test/workflows/debug.md"
    "test/workflows/ci.md"
)

# Phase 3: Code commands with bash functions
CODE_COMMANDS=(
    "code/review.md"
    "code/scan.md"
    "code/polish.md"
    "code/proofread.md"
)

# Phase 4: Other commands
OTHER_COMMANDS=(
    "ultrathink.md"
    "think.md"
    "orchestrate/plan.md"
    "orchestrate/execute.md"
    "git/pr.md"
    "file-optimization/service-split.md"
    "file-optimization/on-demand.md"
    "file-optimization/consolidate.md"
    "create-command.md"
    "create-sub-command.md"
    "service-split.md"
    "on-demand.md"
    "consolidate.md"
    "cleanup.md"
    "check.md"
    "docs.md"
    "monitor.md"
    "migrate.md"
    "upgrade.md"
    "debug.md"
    "rollback.md"
    "api-design.md"
    "optimize.md"
    "refactor.md"
    "security-audit.md"
    "architect.md"
    "test-coverage.md"
    "review.md"
    "prompt.md"
    "next.md"
)

# Summary of changes
echo "📊 Commands to fix:"
echo "  - Test commands: ${#TEST_COMMANDS[@]}"
echo "  - Code commands: ${#CODE_COMMANDS[@]}"
echo "  - Other commands: ${#OTHER_COMMANDS[@]}"
echo "  - Total: $((${#TEST_COMMANDS[@]} + ${#CODE_COMMANDS[@]} + ${#OTHER_COMMANDS[@]}))"

echo ""
echo "✅ Implementation plan created!"
echo ""
echo "Key changes per command:"
echo "1. Replace conceptual agent descriptions with Task tool invocations"
echo "2. Remove bash function implementations with & background processes"
echo "3. Add proper Task tool templates with subagent_type parameter"
echo "4. Ensure consistent parallelism across all commands"
echo ""
echo "Expected benefits:"
echo "- 3-5x performance improvement"
echo "- True parallel execution"
echo "- Better error isolation"
echo "- Consistent behavior across all commands"