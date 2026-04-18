# self-learn

> **A small system that lets Claude Code remember what it learned — so the next session starts smarter than the last.**

**🇺🇸 English** · [🇰🇷 한국어](./docs/README.ko.md) · [🇯🇵 日本語](./docs/README.ja.md) · [🇨🇳 中文](./docs/README.zh.md) · [🇩🇪 Deutsch](./docs/README.de.md) · [🇫🇷 Français](./docs/README.fr.md) · [🇪🇸 Español](./docs/README.es.md) · [🇧🇷 Português](./docs/README.pt.md) · [🇷🇺 Русский](./docs/README.ru.md) · [🇮🇳 हिन्दी](./docs/README.hi.md)

---

## 🌱 The problems this solves

If you use Claude Code regularly, these probably sound familiar:

- **"I swear I fixed this error yesterday... do I really need to explain it again?"**
- **"I'm tired of re-explaining project context every new session."**
- **"This is the third time I'm doing this same task. Can't Claude just know?"**
- **"I don't actually know which areas Claude is strong at and which it gets wrong."**

Install these hooks, and Claude Code starts **learning and remembering on its own**.

| What Claude does | When |
|---|---|
| Detects project stack → auto-loads related memories | Session starts |
| **Proactively recalls memory based on your message** — no "check memory" needed | Every vague/short user prompt |
| Searches previous solutions for familiar errors | Build/command fails |
| Asks "Want to save what you learned this session?" | Session ends |
| Proposes turning repeated work into a skill | Same task done 5+ times |
| Tracks per-domain accuracy → preemptively flags weak areas | Build errors detected |

### ⭐ Memory-First Workflow (the headline feature)

You type: **"review the tone"** — no other context.

Without self-learn: Claude asks "what tone? paste the text."

With self-learn: Claude `Glob`s `~/.claude/memory/feedback_*tone*.md`, `Read`s matches, and replies:

> "I remember you prefer a friendly, upfront tone for public docs (no defensive phrasing). Should I use that standard? Paste the path/content."
> (참조: feedback_oss_friendly_tone.md)

Works for anything you've stored opinions/patterns/solutions on — you never have to say "check memory."

**You don't need to be a developer to install this.** Just paste one command into your terminal.

---

## ⚡ 30-second install (easiest)

Open a terminal and paste this one line:

```bash
curl -sSL https://raw.githubusercontent.com/DAYLAB-HQ/claude-self-learn/main/quickstart.sh | bash
```

That's it. The script handles jq, downloads everything, runs the installer for you.
(Want to review the code first? See the manual install below.)

> **Windows:** open WSL (`wsl` command) or Git Bash first, then paste the same line.

---

## 🚀 Manual install (5 minutes, review-friendly)

### Step 1: Open a terminal
- **Mac**: Press ⌘+Space → type "Terminal" → Enter
- **Linux**: Open the Terminal app
- **Windows**: A couple of extra steps, but it's doable!
  - **Easiest**: Install WSL (Microsoft's built-in Linux-in-Windows feature).
    Open PowerShell, run `wsl --install`, restart your PC, open "Ubuntu" from the Start menu.
    Everything below runs there just like on Mac/Linux.
  - **Alternative**: If you already have [Git for Windows](https://git-scm.com/download/win), open "Git Bash" from the Start menu and the commands below will work too.

### Step 2: Install jq (one-time, skip if already installed)
Copy-paste into terminal, hit Enter:
```bash
brew install jq
```

> Got `brew: command not found`?
> Install [Homebrew](https://brew.sh) first, then run the command again.

### Step 3: Download + install (one line)
```bash
git clone https://github.com/DAYLAB-HQ/self-learn.git && cd self-learn && ./install.sh
```

The installer walks you through everything. When it asks **"Proceed? [Y/n]"**, just press **Y** and Enter.

### Step 4: Verify
Open a new Claude Code session and try:
```
/self-learn:stats
```

See a dashboard? You're done. 🎉

---

## 🛡️ Safe to install (even on your existing setup)

Already using Claude Code? **This installer won't touch your existing stuff.**

### Never overwritten
- Your memory files (`~/.claude/memory/`) — everything you've already saved stays
- Your learning logs (`~/.claude/self-improvement/`)
- Your custom skills, rules, or commands

### Preview before installing
```bash
./install.sh --dry-run
```
Shows you exactly **what would be installed where** without making any changes.

### If a file with the same name already exists
- Default: **skip** (safe, no overwrite)
- Want to update? Use `./install.sh --backup` (creates `.bak` file, then overwrites)

### settings.json is merged safely
- Automatic backup (`.bak`)
- Duplicate-hook detection — won't add hooks that already exist
- Only touches the `hooks` section, leaves everything else alone

### Clean uninstall anytime
```bash
./uninstall.sh
```
Your accumulated memory and learning logs stay intact. Use `--purge` for a full reset.

---

## 📖 Usage

### Save what you learned this session
```
/self-learn
```
Claude analyzes what you did this session and categorizes it:

- **pattern** — successful technical approaches
- **troubleshoot** — errors you solved
- **feedback** — user preferences Claude picked up on
- **skill_candidate** — repeated patterns (suggests skill creation at 5+ hits)

Each item asks **"Save this?"** — decline anything you don't want saved.

### View your dashboard
```
/self-learn:stats
```

```
📊 Self-Improvement Stats
─────────────────────────
Learnings:     42 (pattern: 15, troubleshoot: 20, feedback: 7)
Auto Skills:   3 (active: 2, unused: 1)
Last Learn:    2026-01-12
```

### See where Claude is weak
```
/self-learn:calibration
```
Shows per-domain accuracy (Next.js, Expo, Prisma, etc.). For weak domains (< 50%), Claude will **preemptively say "I'm not confident in this area"** instead of guessing.

### Weekly audit
```
/self-learn:audit
```
Auto-detects stale, duplicate, or conflicting memories. Promotes feedback that's been repeated 3+ times into a rule.

---

## 🔧 What gets installed where (full transparency)

```
~/.claude/
├── hooks/                         ← auto-triggered scripts
│   ├── session-start-preloader.sh    (session start → preload memories)
│   ├── self-learn-stop.sh            (session end → learning check)
│   ├── detect-commit.sh              (commit detected → log)
│   ├── error-auto-matcher.sh         (error → match previous solutions)
│   └── calibration-tracker.sh        (failure → domain accuracy)
│
├── skills/self-learn/             ← /self-learn command implementation
├── commands/self-learn/           ← subcommand definitions
├── rules/
│   ├── self-improvement.md           (default behavior rules)
│   └── memory-first.md               (proactive recall workflow) ⭐
├── memory/                        ← where learnings accumulate
│   └── MEMORY.md                     (index)
└── self-improvement/              ← logs & dashboard data
    ├── LEARNINGS.jsonl
    ├── SKILLS_TRACKER.json
    ├── calibration.json
    └── AUDIT_LOG.md
```

### Optional heavy index
Set `SELF_LEARN_FULL_INDEX=1` before starting a session to also generate
`~/.claude/self-improvement/MEMORY_INDEX.md` (a grouped, human-readable index
of all memories — costs ~7k tokens per session but can help Claude spot
memories across very large collections). Default mode uses Glob/Grep only
to stay lean.

---

## 💡 How this differs from other tools (e.g., Hermes)

| | self-learn | Other frameworks |
|---|---|---|
| Install | Single shell script | Python/Node dependencies |
| Customization | Edit files directly | Learn framework API |
| Size | ~700 lines | Thousands |
| Philosophy | "Personal setup, shared" | General-purpose abstraction |

self-learn is **a personal setup, not a framework.** Grab what you like, or fork and adapt it to your workflow.

---

## 🆘 Troubleshooting

### "jq: command not found"
```bash
brew install jq        # Mac
sudo apt install jq    # Linux
```

### "Permission denied: ./install.sh"
Give the script execute permission, then re-run:
```bash
chmod +x install.sh
./install.sh
```

### Installed but hooks don't seem to fire
Check if the `hooks` section landed in your settings:
```bash
cat ~/.claude/settings.json | jq .hooks
```
If it's empty or malformed, merge manually:
```bash
cat settings.sample.json
```
Paste that content into the `hooks` section of `~/.claude/settings.json`.

### A file got overwritten
If you used `--backup`, there's a `.bak` next to it:
```bash
ls ~/.claude/hooks/*.bak
# Restore:
mv ~/.claude/hooks/detect-commit.sh.bak ~/.claude/hooks/detect-commit.sh
```

### Uninstall completely
```bash
./uninstall.sh           # Remove code only, keep accumulated memories
./uninstall.sh --purge   # Remove everything, including memories (irreversible!)
```

---

## 🙏 A few things to know upfront

This started as a personal setup I decided to share. A few honest expectations:

- **Issue/PR response may be slow** — I check when I can. If you need something fast, forking is great!
- **Breaking changes may happen** — it evolves with my workflow, so review changes before updating
- **Windows needs WSL or Git Bash for now** — I can't test pure Windows myself. A native version (no WSL required) is planned for later. If something breaks on Windows, please share a screenshot in Issues 🙏
- **Feature requests are tough to accommodate** — but if you build it in a fork, please share back! Others will benefit 🙌

---

## 🎁 Who made this

[DAYLAB](https://daylab.dev) — a small studio shipping multiple solo products with Claude Code.

Originally built for personal use, now open. If it helps you, a ⭐ would mean a lot.

---

## 📜 License

[MIT](./LICENSE) — use it freely, including commercially.
