---
name: self-learn:reindex
description: "Rebuild memory_index.json from existing memory files — speeds up session-start preloading at scale. Use when user types /self-learn:reindex, 'reindex memory', '메모리 인덱스 재생성'"
---

Base directory for this skill: ~/.claude/skills/self-learn

# /self-learn:reindex — Rebuild memory index

Scan all files in `~/.claude/memory/` and produce `~/.claude/self-improvement/memory_index.json`.
This enables O(1) fast lookup during session-start-preloader, replacing full grep scans.

## When to run this

- First-time setup (if you already had memory files before installing self-learn)
- After adding many memories manually (outside `/self-learn`)
- If `memory_index.json` gets corrupted or out of sync
- When `session-start-preloader.sh` outputs `(grep lookup — run /self-learn:reindex to speed up)`

## Implementation steps

1. **Scan files**: find every `pattern_*.md`, `troubleshoot_*.md`, `feedback_*.md`, `reference_*.md` in `~/.claude/memory/`
2. **Extract metadata** from each file's YAML frontmatter and body:
   - `name` and `description` from frontmatter
   - `type` from filename prefix (`pattern`, `troubleshoot`, `feedback`, `reference`)
   - `keywords` by detecting tech stack mentions in body:
     - Stack tokens to match: `nextjs`, `nestjs`, `expo`, `prisma`, `react-native`, `typescript`, `tailwind`, `vercel`, `docker`, `ios`, `android`, `sqlite`, `postgres`, `redis`
     - Also pull domain-specific tokens from descriptions where applicable
   - `created`: mtime of file (ISO 8601 UTC)
   - `last_accessed`: same as created on first index build
   - `hit_count`: 0 on first index build
   - `projects`: extract project names referenced in body if any, else empty

3. **Write** to `~/.claude/self-improvement/memory_index.json`:
   ```json
   {
     "version": 1,
     "updated_at": "2026-01-15T12:00:00Z",
     "files": {
       "pattern_nestjs_guard.md": {
         "description": "NestJS guard pattern for JWT auth",
         "type": "pattern",
         "keywords": ["nestjs", "auth"],
         "projects": [],
         "created": "2026-01-10T12:00:00Z",
         "last_accessed": "2026-01-15T09:00:00Z",
         "hit_count": 3
       }
     }
   }
   ```

4. **Report** to the user:
   - Total files indexed
   - Keyword coverage (e.g., "32 files tagged with nextjs")
   - Top 5 keywords by frequency
   - Any files with no keywords detected (need manual tagging)

## Preserve existing fields

If `memory_index.json` already exists:
- Keep existing `hit_count` and `last_accessed` for files still present
- Remove entries for files deleted from disk
- Add entries for new files not yet indexed
- Update `description`, `keywords` if they changed

## Size limit

If total memory files > 2,000, warn the user that grep fallback is recommended over loading the full index into memory each session.
