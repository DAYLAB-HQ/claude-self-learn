---
name: self-learn
description: Accumulate technical patterns learned during sessions and manage auto-generated skills — self-improvement commands for Claude Code
triggers:
  - /self-learn
  - /self-learn:scan
  - /self-learn:audit
  - /self-learn:stats
---

# self-learn — Claude Code Self-Improvement Engine

> **Scope**: Technical/implementation-level learning only — code patterns, debugging solutions, tool usage, user technical preferences.
> Product/business learning (channel performance, pricing conversions, marketing patterns) is out of scope — consider a separate system or portfolio docs for that.

> **Companion rule**: See `~/.claude/rules/memory-first.md` for the proactive recall workflow. That rule teaches Claude to Glob/Read memories automatically on every vague user prompt — so stored preferences and solutions surface without being asked for.

## Commands

### `/self-learn` (default)
Scan the current session, extract what was learned, and save it.

**Execution steps:**
1. Summarize session work (git diff + conversation context)
2. Classify into four categories:
   - **pattern**: Successful technical approaches → `~/.claude/memory/pattern_*.md`
   - **troubleshoot**: Resolved errors/bugs → `~/.claude/memory/troubleshoot_*.md`
   - **feedback**: User preferences/corrections → `~/.claude/memory/feedback_*.md`
   - **skill_candidate**: Repeated patterns → propose skill extraction
3. Show each item to the user and get approve/reject/edit
4. Save approved items:
   - Create/update memory files
   - Append to `~/.claude/self-improvement/LEARNINGS.jsonl`
   - Update `~/.claude/self-improvement/SKILLS_TRACKER.json`
5. Check conflicts with existing memory → propose updates if conflicts found
6. **Reference guide update detection**:
   - If the session used a new external service CLI/API pattern:
     → Check if a reference memory exists for that service
     → If not, propose creating one
   - **General principle**: Ask "If this task happens again, is there a guide to reference?"
     If not, propose creating one. Unlike technical patterns (`pattern_*`), guides (`reference_*`)
     should contain **step-by-step recipes**.

**LEARNINGS.jsonl format:**
```jsonl
{"ts":"2026-01-12T14:00:00Z","project":"my-app","category":"pattern","title":"NestJS guard pattern","memory_file":"pattern_nestjs_guard.md","verified":true}
{"ts":"2026-01-12T14:00:00Z","project":"my-app","category":"troubleshoot","title":"Expo SDK build error","memory_file":"troubleshoot_expo_sdk_build.md","verified":true}
```

7. **Update `memory_index.json`** — every save/update/delete of a memory file MUST keep the index in sync:
   - On new memory: add entry with `description`, `type`, `keywords`, `created`, `last_accessed` (=created), `hit_count` (=0), `projects`
   - On memory update: refresh `description` and `keywords`, bump `last_accessed`, increment `hit_count`
   - On memory delete: remove entry
   - On memory read/reference during the session: bump `last_accessed` and `hit_count`

   Keywords extraction: detect tech stacks and domain tokens in body (nextjs, nestjs, expo, prisma, react-native, typescript, tailwind, vercel, docker, ios, android, sqlite, postgres, redis, etc.). If none detected, leave empty — the file is still grep-able as fallback.

   The index enables O(1) session-start preload for large memory collections. Without it, grep-based fallback still works but scales poorly past ~500 files.

### `/self-learn:scan`
List detected learning candidates without saving them (preview only).

**Execution steps:**
1. Analyze current session's work patterns
2. Output candidates by category
3. Prompt: "Run `/self-learn` to save them"

### `/self-learn:audit`
Health check for existing memory and skills.

**Execution steps:**
1. Scan all of `~/.claude/memory/`
2. Check for:
   - **Stale**: Memory references files/functions that no longer exist
   - **Conflict**: Two memories contradict each other (e.g., A says "use X", B says "don't use X")
   - **Duplicate**: Same content saved under different filenames
   - **Unused skills**: `usage_count=0` and older than 30 days
3. If issues found, propose fixes/deletions (user approval required)
4. Update `SKILLS_TRACKER.json`

### `/self-learn:stats`
Accumulation dashboard.

**Output:**
```
📊 Self-Improvement Stats
─────────────────────────
Learnings:     42 (pattern: 15, troubleshoot: 20, feedback: 7)
Auto Skills:   3 (active: 2, unused: 1)
Last Learn:    2026-01-12
Last Audit:    2026-01-10
Memory Files:  28 (global) + 5 (project)

Top Categories:
  Next.js      ████████░░ 8
  NestJS       ██████░░░░ 6
  Expo         █████░░░░░ 5
```

## Skill Candidate System (persists across sessions)

Skill candidates are stored in the `candidates` array of `SKILLS_TRACKER.json` and **accumulate across sessions**.

### Candidate lifecycle

```
detected → candidate (hit_count accumulates) → ready (hit_count ≥ 5) → user approves → skill created
                                                                      → user rejects  → dismissed
```

### Registration triggers (any one)

- Same technical task repeated **2+ times across different projects**
- User signals like "I'll probably do this often", "Doing this again"
- **3+ troubleshoot memories** in the same category
- On `/self-learn`, pattern analysis of LEARNINGS.jsonl detects a match

### Accumulation rules

1. On `/self-learn`, match current session work against existing candidates
2. If matched: `hit_count += 1`, update `last_seen`, add memory to `evidence`
3. If new pattern: register as new candidate with `hit_count: 1`
4. When `hit_count ≥ 5`: `status: "ready"` → prompt user "Want to make this a skill?"

### SKILLS_TRACKER.json candidate schema

```json
{
  "candidates": [
    {
      "id": "kebab-case-id",
      "title": "Skill candidate title",
      "description": "One-line description",
      "evidence": ["related_memory_file.md", "..."],
      "hit_count": 3,
      "first_seen": "2026-01-07",
      "last_seen": "2026-01-14",
      "status": "candidate | ready | dismissed | already_skill",
      "projects": ["project1", "project2"]
    }
  ]
}
```

### `/self-learn:candidates`
View candidates + manual promote/reject.

**Output:**
```
🔧 Skill Candidates
─────────────────────────
ID                          Hits  Status     Projects
────────────────────────────────────────────────────
html-mockup-pipeline          5   ★ ready    app1, app2, app3
external-service-setup        4   candidate  app1, app4
```

**Manual operations:**
- "Create html-mockup-pipeline as a skill" → generate skill
- "Reject external-service-setup" → status: "dismissed"
- "Add new candidate: XYZ" → manual candidate registration

### `/self-learn:calibration`
Per-domain accuracy dashboard + manual adjustment of calibration.json.

**Output:**
```
🎯 Calibration Dashboard
─────────────────────────
Domain        Correct  Wrong  Accuracy  Confidence
─────────────────────────────────────────────────
nestjs            12      1    92.3%    ██████████ HIGH
tailwind          10      0   100.0%    ██████████ HIGH
nextjs            15      3    83.3%    █████████░ HIGH
prisma             8      2    80.0%    █████████░ HIGH
typescript         6      2    75.0%    ████████░░ MED
expo               4      5    44.4%    █████░░░░░ LOW ⚠️
ios_native         1      3    25.0%    ███░░░░░░░ LOW ⚠️

Total events: 67 | Last updated: 2026-01-12
```

**Manual adjustments:**
- User says "Reset expo accuracy" → reset correct/wrong for that domain
- User says "That was my mistake, remove from calibration" → most recent wrong -1

## Classification guidelines

| Signal | Category | Storage location |
|---|---|---|
| "This API pattern was clean" | technical pattern | `~/.claude/memory/pattern_*.md` |
| "Solved this build error" | technical troubleshoot | `~/.claude/memory/troubleshoot_*.md` |
| "Don't do it this way" (code) | technical feedback | `~/.claude/memory/feedback_*.md` |
| Product ops, marketing, conversions | out of scope | Use a separate system |
