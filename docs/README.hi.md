# self-learn

> **एक छोटा सिस्टम जो Claude Code को याद रखने की क्षमता देता है — ताकि अगली session पिछली से ज़्यादा समझदार शुरू हो।**

[🇺🇸 English](../README.md) · [🇰🇷 한국어](./README.ko.md) · [🇯🇵 日本語](./README.ja.md) · [🇨🇳 中文](./README.zh.md) · [🇩🇪 Deutsch](./README.de.md) · [🇫🇷 Français](./README.fr.md) · [🇪🇸 Español](./README.es.md) · [🇧🇷 Português](./README.pt.md) · [🇷🇺 Русский](./README.ru.md) · **🇮🇳 हिन्दी**

---

## 🌱 यह क्या problems solve करता है

अगर आप Claude Code रोज़ इस्तेमाल करते हैं, ये situations जानी-पहचानी लगेंगी:

- **"मैंने कल ही ये error fix किया था... क्या फिर से समझाना होगा?"**
- **"हर नई session में project context दोहराते-दोहराते थक गया।"**
- **"ये तीसरी बार है यही task कर रहा हूँ। Claude खुद से क्यों नहीं जानता?"**
- **"मुझे खुद नहीं पता Claude किस area में अच्छा है और कहाँ गलत होता है।"**

ये hooks install करें, और Claude Code **खुद से सीखना और याद रखना** शुरू कर देगा।

| Claude क्या करता है | कब |
|---|---|
| Project stack detect करता है → related memories auto-load | Session शुरू होने पर |
| Familiar errors के पिछले solutions खोजता है | Build/command fail होने पर |
| "इस session में जो सीखा उसे save करें?" पूछता है | Session end होने पर |
| Repeated work के लिए skill बनाने का suggestion देता है | एक ही task 5+ बार |
| Domain-wise accuracy track करता है → weak areas पहले बताता है | Build errors detect होने पर |

**Install करने के लिए developer होने की ज़रूरत नहीं।** बस terminal में एक command paste करें।

---

### ⭐ Memory-First Workflow (मुख्य feature)

Input: **"tone check कर दो"** — कोई और context नहीं।

self-learn के बिना: Claude पूछता है "कौन सा tone? text दो।"

self-learn के साथ: Claude `~/.claude/memory/feedback_*tone*.md` पर `Glob` → matches `Read` → जवाब:

> "याद है — public docs के लिए आप friendly, पहले से बताने वाला tone पसंद करते हैं, defensive phrasing avoid करते हैं। इसी standard पर check करूँ? path/content दें।"
> (参照: feedback_oss_friendly_tone.md)

हर उस topic के लिए काम करता है जहाँ आपने preferences/patterns/solutions save किए हैं — **आपको कभी "memory check करो" कहने की ज़रूरत नहीं**।

---

## ⚡ 30 सेकंड में Install (सबसे आसान)

Terminal खोलें, ये एक line paste करें:

```bash
curl -sSL https://raw.githubusercontent.com/DAYLAB-HQ/claude-self-learn/main/quickstart.sh | bash
```

बस। Script jq install से download और run तक सब खुद करता है।
(पहले code देखना चाहते हैं? नीचे manual install देखें।)

> **Windows**: पहले WSL (`wsl` command) या Git Bash खोलें, फिर line paste करें।

---

## 🚀 Manual Install (5 मिनट, code review करने वालों के लिए)

### Step 1: Terminal खोलें
- **Mac**: Spotlight (⌘+Space) → "Terminal" search → Enter
- **Linux**: Terminal app खोलें
- **Windows**: थोड़े extra steps हैं, लेकिन हो सकता है!
  - **सबसे आसान**: WSL install करें (Windows में built-in "Linux mode" feature)।
    PowerShell खोलें, `wsl --install` चलाएं, PC restart करें, Start menu से "Ubuntu" खोलें।
    उसके अंदर नीचे के commands Mac/Linux की तरह ही चलते हैं।
  - **दूसरा तरीका**: अगर आपके पास पहले से [Git for Windows](https://git-scm.com/download/win) है,
    Start menu से "Git Bash" खोलें — नीचे के commands ज़्यादातर वहीं चलते हैं।

### Step 2: jq Install करें (एक बार)
```bash
brew install jq
```

### Step 3: Download + Install (एक line)
```bash
git clone https://github.com/DAYLAB-HQ/claude-self-learn.git && cd claude-self-learn && ./install.sh
```

**"Proceed? [Y/n]"** पूछने पर **Y** दबाकर Enter।

### Step 4: Verify
Claude Code की नई session में:
```
/self-learn:stats
```

Dashboard दिखे तो install हो गया! 🎉

---

## 🛡️ Safe Install

पहले से Claude Code use कर रहे हैं? **ये installer आपकी existing config को नहीं छुएगा।**

### कभी overwrite नहीं होता
- आपकी memory files (`~/.claude/memory/`)
- आपकी learning logs (`~/.claude/self-improvement/`)
- आपके custom skills, rules, commands

### Install से पहले preview
```bash
./install.sh --dry-run
```

### कभी भी clean uninstall
```bash
./uninstall.sh
```

---

## 📖 Usage

### Session end पर जो सीखा save करें
```
/self-learn
```

### Dashboard देखें
```
/self-learn:stats
```

### देखें Claude कहाँ weak है
```
/self-learn:calibration
```

### Weekly audit
```
/self-learn:audit
```

Details के लिए [English README](../README.md) देखें।

---

## 🙏 पहले से बताना चाहता हूँ

ये मेरा personal setup था जो share करने का सोचा। कुछ honest expectations:

- **Issues/PRs का response slow हो सकता है** — time मिलने पर देखता हूँ। Urgent हो तो fork करें!
- **Breaking changes हो सकते हैं** — मेरे workflow के साथ evolve होता है
- **Windows अभी WSL या Git Bash से use करें** — खुद test नहीं कर पाया। पूरी native support बाद के version में। Windows पर कुछ टूटे तो Issues में screenshot share करें 🙏
- **Feature requests accommodate करना मुश्किल है** — पर fork में बनाकर Issues में share करें 🙌

---

## 🎁 बनाने वाला

[DAYLAB](https://daylab.dev) — Claude Code से multiple solo products ship करने वाला एक छोटा studio।

काम आए तो एक ⭐ से बहुत खुशी होगी।

## 📜 License

[MIT](../LICENSE) — freely use करें, commercial भी OK है।
