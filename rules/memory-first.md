# Memory-First Workflow

**Before replying to a vague or short user request, check memory first.**

This keeps the user from having to repeat context they already stored.

## Retrieval workflow (lean)

Memory directory: `~/.claude/memory/*.md`

**Lookup order** (fastest first):

1. **Glob for filenames**
   ```
   Glob pattern: ~/.claude/memory/*.md
   ```
   Or filter by type:
   ```
   Glob: ~/.claude/memory/feedback_*.md
   Glob: ~/.claude/memory/pattern_*.md
   ```

2. **Grep the body** (when filenames alone aren't enough)
   ```
   Grep: "tone" in ~/.claude/memory/
   Grep: "naming|name" in ~/.claude/memory/feedback_*.md
   ```

3. **Read the relevant files**
   - Read 1–3 of the strongest matches
   - Incorporate their content into the reply

## Triggers — when you MUST check memory first

### 1. Tone / voice / writing style
Keywords: `tone`, `voice`, `writing`, `style`, `copy`, `wording`
→ `feedback_*tone*`, `feedback_*voice*`, etc.

### 2. Naming / product names
Keywords: `name`, `naming`, `product name`, `brand`
→ `feedback_*naming*`, `project_*`

### 3. Technical implementation (stack mentioned)
Keywords: `expo`, `nextjs`, `prisma`, `react-native`, `vercel`, `tailwind`, etc.
→ `pattern_*<stack>*`, `troubleshoot_*<stack>*`, `reference_*<stack>*`

### 4. Past work reference
Keywords: `last time`, `before`, `previously`, `how did I`, `remember when`
→ Grep the topic keyword → `reference_*`, `pattern_*`

### 5. Specific product / project names
Keywords: project slugs or business-specific domain terms
→ `project_<slug>.md`, `user_*.md`

### 6. Any vague request
Single-line or context-light prompts — **before asking for clarification**,
Glob `~/.claude/memory/*.md` + Grep the likely keyword.
- If something relevant turns up, start the reply from that context.
- If it's still ambiguous after checking, ask a clarifying question that
  is **grounded in the memory you found** (e.g. "I see three tone memories —
  OSS / social / UX writing — which one is this for?").

## Forbidden behavior

- ❌ Replying to a vague request with "What do you mean by X?" with no memory check
- ❌ Re-asking the user for a preference they already stored
- ❌ Looking for `MEMORY_INDEX.md` (lean mode doesn't generate it — use Glob)

## Showing your sources

When you used a memory to shape the reply, add a source footer:
```
(source: feedback_oss_friendly_tone.md)
```
Or for multiple:
```
(sources: feedback_oss_friendly_tone.md, pattern_github_noreply_identity_mask.md)
```

## Example

### ❌ Not good
```
User: Can you review the tone?
Claude: Sure — which tone do you want me to review? Paste the text.
```

### ✅ Good
```
User: Can you review the tone?
Claude: [Glob ~/.claude/memory/feedback_*tone*.md]
        [Read feedback_oss_friendly_tone.md]
        I remember you prefer a warm, upfront tone for public docs
        (no defensive phrasing). Is this for a public-facing doc,
        or something else (sales copy, social post, etc.)?
        Paste the path/content and I'll check it against that standard.
        (source: feedback_oss_friendly_tone.md)
```

## Scope

- This rule lives in `~/.claude/rules/` so it loads for every session.
- Applies to all projects and all tasks.
- Activates the moment a user message arrives, before the first reply tokens.

## Performance note

- One Glob + 1–3 Reads per recall = roughly 500–2000 tokens.
- Don't repeat the same search — if a memory is already in the conversation
  context, reuse it instead of re-reading.
