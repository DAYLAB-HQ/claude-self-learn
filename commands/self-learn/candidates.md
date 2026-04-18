---
name: self-learn:candidates
description: "View skill candidates + manual promote/dismiss. Use when user types /self-learn:candidates, 'candidates', 'skill candidates', '스킬 후보', '후보 목록'"
argument-hint: "[promote|dismiss|add] [candidate-id]"
---

Base directory for this skill: ~/.claude/skills/self-learn

Read ~/.claude/skills/self-learn/SKILL.md and execute the `/self-learn:candidates` command.

Implementation:
1. Read `~/.claude/self-improvement/SKILLS_TRACKER.json`
2. Display candidates table (ID, hits, status, projects)
3. If argument is "promote <id>": create skill from candidate, move to auto_generated_skills
4. If argument is "dismiss <id>": set status to "dismissed"
5. If argument is "add <title>": create new candidate with hit_count: 1

$ARGUMENTS
