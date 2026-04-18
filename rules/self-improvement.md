# Self-Improvement

> **Scope**: Technical/implementation-level learning only.
> Product/business learning (channels, pricing, kill reasons, marketing patterns)
> is out of scope — consider a separate system or portfolio documentation for that.

> **Companion rule**: `memory-first.md` (same directory) defines the proactive
> recall workflow — on every vague/short user prompt, Claude must Glob/Grep/Read
> relevant memories *before* asking the user for clarification. This rule handles
> storage/maintenance; `memory-first.md` handles retrieval/usage.

## What this system handles

| Area | This system |
|---|---|
| **Build/implementation patterns** | `~/.claude/memory/pattern_*.md` |
| **Debugging solutions** | `~/.claude/memory/troubleshoot_*.md` |
| **Code structure decisions** | `~/.claude/memory/pattern_*.md` |
| **User technical preferences** | `~/.claude/memory/feedback_*.md` |
| **Automatic skill extraction** | `~/.claude/skills/` |

**Principle**: "how" (technical) = self-improvement. "what/why" (business) = separate system.

## 1. Automatic Skill Extraction

When any of the following are detected, propose **automatic skill file creation**:

### Triggers (any one)
- The same **technical** work pattern repeats **2+ times in the current session** (e.g., "add API endpoint", "create new page", "add i18n key")
- The same pattern repeats **2+ times across different projects** (cross-session — via LEARNINGS.jsonl analysis)
- The user gives repeat signals like "I'll probably do this often", "Doing this again", "Every time..."
- **3+ troubleshoot memories** accumulated in the same category (repeatedly solving the same problem)
- Current work matches an existing candidate in `SKILLS_TRACKER.json` → increment `hit_count`

### Candidate system (persists across sessions)
- Skill candidates are stored in the `candidates` array of `SKILLS_TRACKER.json` and **accumulate across sessions**
- On `/self-learn`, match current work against existing candidates → on match, `hit_count += 1`
- New patterns register with `hit_count: 1`
- When `hit_count ≥ 5`: `status: "ready"` → propose skill creation to the user
- Use `/self-learn:candidates` to view candidates and manually promote/reject

### Skill creation procedure
1. Ask the user "Create this pattern as a skill?"
2. On approval, create `~/.claude/skills/{skill-name}/SKILL.md`
3. Skill content: trigger conditions, execution steps, checklist, caveats
4. Check for duplicates with existing skills — if one exists, propose updating it instead

### Skill file structure
```markdown
---
name: {skill-name}
description: {one-line description}
auto_generated: true
created: {date}
usage_count: 0
---

## Trigger
{When to use this skill}

## Steps
1. ...
2. ...

## Checklist
- [ ] ...

## Caveats
- ...
```

## 2. Success Pattern Memory (Procedural Memory)

**Record not just failures (troubleshoot) but also technical success patterns.**

### Triggers
- Completed a complex implementation/debugging cleanly
- User gave positive feedback like "nice", "perfect", "let's go with this"
- Made a non-obvious **technical** decision that the user approved without edits

### Storage location
- Global memory: `~/.claude/memory/pattern_{keyword}.md`
- Project memory: For project-specific technical patterns, use project memory

### Content format
```markdown
---
name: {pattern name}
description: {one-line description}
type: feedback
---

{What was done}

**Why:** {Why this approach worked}
**How to apply:** {How to apply this in similar situations next time}
```

## 3. Session-End Self-Evaluation

**Hook-triggered automatically** — `~/.claude/hooks/self-learn-stop.sh` runs on the Stop event and injects a checklist via additionalContext. Even if the user doesn't explicitly end the session, this fires whenever Claude stops responding.

### Self-evaluation items (internal check, not forced output)
1. Did I learn anything **new and technical** this session? → if yes, save to memory
2. Were there **repeated implementation patterns**? → if yes, propose skill extraction
3. Did I find an existing memory that's **incorrect**? → if yes, update it
4. Did I detect a new **user technical preference**? → if yes, save to feedback memory

### Output rules
- If there's something to save, propose it in one line: "Save N things you learned this session?"
- If nothing, say nothing. Do not force reports.
- If the user declines, don't save.

## 4. Skill Usage Counter

Every time an auto-generated skill is used, increment `usage_count` by 1. Skills used 3+ times are considered validated. For skills with `usage_count=0` and older than 30 days, propose deletion.

## 5. Infrastructure

### State files
- `~/.claude/self-improvement/LEARNINGS.jsonl` — append-only learning event log
- `~/.claude/self-improvement/SKILLS_TRACKER.json` — auto-generated skill metadata
- `~/.claude/self-improvement/calibration.json` — per-domain correct/wrong tracking
- `~/.claude/self-improvement/AUDIT_LOG.md` — weekly audit results

### Hooks (settings.json)
- **SessionStart** → `~/.claude/hooks/session-start-preloader.sh` — detect project stack + preload related memories
- **Stop** → `~/.claude/hooks/self-learn-stop.sh` — session-end self-check reminder
- **PostToolUse(Bash)** → `~/.claude/hooks/detect-commit.sh` — detect git commit → log to LEARNINGS.jsonl
- **PostToolUse(Bash)** → `~/.claude/hooks/error-auto-matcher.sh` — detect errors → search troubleshoot memory
- **PostToolUse(Bash)** → `~/.claude/hooks/calibration-tracker.sh` — on failure, record per-domain wrong

### Weekly audit
- Prompt: `~/.claude/skills/self-learn/weekly-audit-prompt.md`
- Results: `~/.claude/self-improvement/AUDIT_LOG.md`
- Run: `/self-learn:audit` or session-level cron

### Skill commands
- `/self-learn` — manual learning extraction (scan session → classify → user approves → save)
- `/self-learn:scan` — list candidates only (don't save)
- `/self-learn:audit` — memory/skill health check
- `/self-learn:stats` — accumulation dashboard
- `/self-learn:calibration` — per-domain accuracy dashboard
- `/self-learn:candidates` — skill candidate viewer

## 6. Calibration-Based Behavior Rules

Read `~/.claude/self-improvement/calibration.json` at session start and adjust behavior based on per-domain accuracy.

### Accuracy-based behavior

| Accuracy | Behavior |
|---|---|
| **80%+** | Answer confidently. Implement immediately. WebSearch unnecessary. |
| **50–79%** | "This should work, let me verify" + WebSearch to confirm before implementing. |
| **Below 50%** | "I'm not confident in this area" **preemptive disclosure** + **MUST WebSearch first** + get user confirmation before writing code. |
| **No data** (new domain) | Apply 50–79% rule (neutral). |

### Recording rules

- **Auto wrong recording**: Hooks estimate the domain from stderr on build/command failure → `wrong +1`
- **Manual correct recording**: On `/self-learn`, classify successful technical work by domain → `correct +1`
- **User correction = wrong**: If user says "no not that", "wrong" → `wrong +1` on relevant domain
- **Noise filtering**: Simple typos, environment issues (port conflicts, etc.) are not included in calibration. Only record when my knowledge/judgment was actually wrong.

### Accuracy calculation
```
accuracy = correct / (correct + wrong)
```
- Requires at least 5 events to be meaningful. Under 5, treat as "insufficient data" and use neutral behavior.
- If no events for 30+ days, gradually regress accuracy toward neutral (0.7) — so old mistakes don't permanently damage confidence.
