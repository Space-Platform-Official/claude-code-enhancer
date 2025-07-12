---
allowed-tools: all
description: Aggressively clean up codebase by merging duplicates, removing backups, and eliminating redundant code
---

# 🔍🔍🔍 CRITICAL REQUIREMENT: SIMPLIFY AND CLEAN UP FILES! 🔍🔍🔍

**THIS IS NOT A GENTLE TIDYING TASK - THIS IS AN AGGRESSIVE CLEANUP TASK!**

When you run `/cleanup`, you are REQUIRED to:

1. **SCAN** the entire codebase for duplicate files, backups, and redundant code
2. **IDENTIFY** all Claude-created backup files (.bak, .backup, .old, timestamps)
3. **MERGE** duplicate files by consolidating their unique content
4. **REMOVE** all unnecessary backups and temporary files aggressively
5. **USE MULTIPLE AGENTS** for comprehensive cleanup:
   - Spawn one agent to scan for duplicate file patterns
   - Spawn another to identify Claude-created backups
   - Spawn more agents to analyze different directories in parallel
   - Say: "I'll spawn multiple agents to perform comprehensive cleanup analysis"
6. **DO NOT STOP** until:
   - ✅ All duplicate files are merged or removed
   - ✅ All Claude-created backups are deleted
   - ✅ All redundant code is eliminated
   - ✅ Only essential files remain in the codebase

**FORBIDDEN BEHAVIORS:**
- ❌ "This might be important, better keep it" → NO! Remove unless PROVEN essential!
- ❌ "Just rename backups instead of deleting" → NO! DELETE them permanently!
- ❌ "Only remove obvious duplicates" → NO! Deep analysis required!
- ❌ "Keep backup files just in case" → NO! Trust version control!
- ❌ Preserving files "to be safe" → NO! Be aggressive in cleanup!

**MANDATORY WORKFLOW:**
```
1. Initial scan → Identify ALL potential cleanup targets
2. IMMEDIATELY spawn agents for parallel analysis
3. Deep analysis → Verify duplicates and redundancy
4. Aggressive cleanup → DELETE and MERGE without hesitation
5. Verification → Ensure codebase still functions after cleanup
```

**YOU ARE NOT DONE UNTIL:**
- Zero backup files remain (.bak, .backup, .old, ~, .swp)
- No duplicate files with similar names exist
- All redundant code has been consolidated
- Empty directories are removed

---

🛑 **MANDATORY CLEANUP PROTOCOL** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify version control is active for safety

Execute comprehensive file cleanup and simplification.

**FORBIDDEN EXCUSE PATTERNS:**
- "It might break something" → NO, test after cleanup
- "The file looks important" → NO, analyze its actual usage
- "Better to keep backups" → NO, version control exists
- "Manual review needed" → NO, automated analysis is sufficient
- "Cleanup can wait" → NO, do it NOW

Let me ultrathink about the most aggressive cleanup strategy.

🚨 **REMEMBER: Every unnecessary file is technical debt!** 🚨

**Comprehensive Cleanup Protocol:**

**Step 0: Pre-Cleanup Safety Check**
- [ ] Verify git repository exists and is clean
- [ ] Confirm no uncommitted changes
- [ ] Create safety commit before cleanup
- [ ] Document current file count and structure

**Step 1: Multi-Agent Cleanup Scanning**
Deploy specialized agents for parallel cleanup analysis:

```
"I need to perform aggressive file cleanup. I'll spawn cleanup agents:
- Agent 1: Scan for duplicate files by name patterns
- Agent 2: Hunt for all backup file extensions
- Agent 3: Analyze code for redundant implementations
- Agent 4: Check for empty or near-empty files
- Agent 5: Identify temporary and cache files
Let me execute comprehensive cleanup scanning..."
```

**Step 2: Duplicate File Detection**
- [ ] Find files with similar names (file.js vs file.old.js)
- [ ] Compare file contents using checksums
- [ ] Identify functional duplicates with different names
- [ ] Detect test file duplicates
- [ ] Find configuration file copies

**Step 3: Backup File Elimination**
Target ALL backup patterns:
- [ ] Files ending in: .bak, .backup, .old, .orig
- [ ] Files with timestamps: file.20240112.js
- [ ] Editor backups: *~, *.swp, *.swo
- [ ] Version suffixes: *_v1, *_v2, *_old, *_new
- [ ] Copy indicators: *_copy, *_backup, *.copy

**Step 4: Redundant Code Analysis**
- [ ] Identify identical functions across files
- [ ] Find duplicate class definitions
- [ ] Detect repeated code blocks
- [ ] Locate unused imports and dependencies
- [ ] Find dead code paths

**Step 5: Merge and Consolidation Strategy**
When duplicates are found:
1. Compare all versions for unique content
2. Merge unique content into primary file
3. Update all references to point to primary
4. DELETE all secondary copies immediately
5. Verify functionality after merge

**Cleanup Execution Checklist:**
- [ ] All .bak files deleted
- [ ] All .backup files deleted
- [ ] All .old files deleted
- [ ] All editor temporary files removed
- [ ] All timestamp-suffixed files eliminated
- [ ] Duplicate implementations consolidated
- [ ] Empty directories removed
- [ ] File count significantly reduced

**Cleanup Anti-patterns (FORBIDDEN):**
- ❌ "Archive backups to backup/ folder" → NO, delete them
- ❌ "Comment out duplicate code" → NO, remove it entirely
- ❌ "Keep one backup just in case" → NO, trust git
- ❌ "Rename to .unused" → NO, delete completely
- ❌ "Move to temp/ directory" → NO, permanent removal

**Important File Preservation:**
ONLY preserve files that meet ALL criteria:
- [ ] Currently imported/required by active code
- [ ] Contains unique functionality not found elsewhere
- [ ] Part of critical path execution
- [ ] Required for build/test/deploy processes
- [ ] Explicitly documented as necessary

**Post-Cleanup Verification:**
- [ ] Run full test suite - must pass
- [ ] Build process completes successfully
- [ ] No broken imports or references
- [ ] Application starts without errors
- [ ] Core functionality remains intact

**Final Verification:**
The cleanup is complete when:
✓ Zero backup files of any type remain
✓ No duplicate files exist (by name or content)
✓ All redundant code has been removed
✓ File count reduced by at least 20%
✓ All tests pass after cleanup
✓ Codebase is significantly simpler

**Final Commitment:**
I will now execute EVERY cleanup step listed above and AGGRESSIVELY SIMPLIFY THE CODEBASE. I will:
- ✅ DELETE all backup files without hesitation
- ✅ MERGE all duplicates into single instances
- ✅ REMOVE all redundant code completely
- ✅ ELIMINATE every unnecessary file
- ✅ SPAWN MULTIPLE AGENTS for thorough analysis
- ✅ TEST everything after cleanup

I will NOT:
- ❌ Keep backups "just in case"
- ❌ Preserve files without proven necessity
- ❌ Rename instead of deleting
- ❌ Skip files that "might be important"
- ❌ Do partial or conservative cleanup
- ❌ Stop until codebase is maximally simplified

**REMEMBER: This is an AGGRESSIVE CLEANUP task, not gentle organizing!**

The cleanup is successful ONLY when maximum simplification is achieved.

**Executing aggressive file cleanup and simplification NOW...**