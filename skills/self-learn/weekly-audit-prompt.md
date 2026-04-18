# Weekly Memory Audit (automated)

Perform the following tasks in order and record the results in `~/.claude/self-improvement/AUDIT_LOG.md`.

## 1. Memory Health Check

Scan all of `~/.claude/memory/`:

### Stale check
- Verify that file paths / function names referenced by `pattern_*.md` and `troubleshoot_*.md` still exist
- If not, tag [STALE]

### Conflict check
- Check if two memories contradict each other (e.g., A says "use X", B says "don't use X")
- Tag conflicts as [CONFLICT]

### Duplicate check
- Find the same content saved under different filenames
- Tag duplicates as [DUPLICATE]

## 1.5. 3-Strike Rule (promote feedback encoding strength)

**Principle**: When the same kind of feedback repeats 3+ times, **promote it to a stronger encoding**.

```
1x: feedback_*.md memory (current state — weak enforcement)
2x: feedback_*.md (repeat detected → warning signal)
3x: ⚡ Promote to a rule in ~/.claude/rules/*.md (auto-loaded)
5x: ⚡⚡ Enforce via a Hook (PreToolUse/PostToolUse block/validate)
```

### Inspection procedure

1. Scan all of `~/.claude/memory/feedback_*.md`
2. **Semantic clustering** — group by filename prefix + description + body keywords:
   - Example: `feedback_check_existing_before_setup`, `feedback_check_memory_first`, `feedback_proactive_unimplemented_scan` → "preflight check" cluster
   - Example: `feedback_design_mockup_*`, `feedback_follow_design_mockup` → "design accuracy" cluster
3. Count cluster member size
4. Threshold comparison:
   - **3+ members**: Recommend writing a unified rule in `~/.claude/rules/` → tag [PROMOTE-TO-RULE]
   - **5+ members**: Evaluate if hook automation is possible → tag [PROMOTE-TO-HOOK]
   - **Already ruled**: Mark the feedback memory as `[REDUNDANT]` (rule is SSOT, memory is cleanup candidate)

### Hook promotion feasibility

For [PROMOTE-TO-HOOK] candidates, recommend a hook if any of these apply:
- Deterministic verification possible (regex, file existence, command output parsing)
- Clear block condition (e.g., "prevent committing sensitive files")
- Auto-fix via PostToolUse post-processing

If none apply, recommend [PROMOTE-TO-RULE] only.

### Output format

```markdown
## 3-Strike Rule check results

### Promote to rule (3+ accumulated)
- Cluster "mandatory preflight check" — 3 memories:
  - feedback_check_existing_before_setup.md
  - feedback_check_memory_first.md
  - feedback_proactive_unimplemented_scan.md
  → Recommended unified rule: ~/.claude/rules/preflight-checks.md

### Promote to hook (5+ accumulated)
- Cluster "prevent committing sensitive files" — 5 memories:
  - feedback_*.md (list)
  → Recommended hook: PreToolUse(Bash) → inspect git commit → block .env pattern

### Already ruled — memory cleanup candidates [REDUNDANT]
- feedback_*.md → already covered in ~/.claude/rules/X.md
```

## 2. Skill Tracker Update

Check `~/.claude/self-improvement/SKILLS_TRACKER.json`:
- List auto-generated skills with `usage_count=0` and older than 30 days
- Tag [UNUSED]

## 3. LEARNINGS.jsonl Stats

- Total learnings, distribution by category, distribution by project
- New learnings in the last 7 days

## 4. Record Results

Append to `~/.claude/self-improvement/AUDIT_LOG.md` in this format:

```markdown
## Audit results — {date}

- Total memories: N
- Stale: N (list)
- Conflict: N (list)
- Duplicate: N (list)
- **3-Strike Rule**:
  - PROMOTE-TO-RULE candidates: N clusters (list)
  - PROMOTE-TO-HOOK candidates: N clusters (list)
  - REDUNDANT: N memories (list)
- Unused skills: N (list)
- Weekly new learnings: N
- Recommended actions: (if any)
```

If issues are found, include specific fix proposals, but **do not auto-fix** — only record them so the next interactive session can propose them to the user.

## Anti-patterns (never do)

- Auto-applying cluster thresholds to automatically generate rules/hooks — always requires user approval
- Saving the 5th identical feedback as yet another memory (= system design failure)
- Clustering by filename prefix alone without semantic similarity check (false positive risk)
