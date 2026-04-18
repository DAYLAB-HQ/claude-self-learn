# self-learn

> **Ein kleines System, das Claude Code Gelerntes merken lässt — damit die nächste Session schlauer beginnt als die letzte.**

[🇺🇸 English](../README.md) · [🇰🇷 한국어](./README.ko.md) · [🇯🇵 日本語](./README.ja.md) · [🇨🇳 中文](./README.zh.md) · **🇩🇪 Deutsch** · [🇫🇷 Français](./README.fr.md) · [🇪🇸 Español](./README.es.md) · [🇧🇷 Português](./README.pt.md) · [🇷🇺 Русский](./README.ru.md) · [🇮🇳 हिन्दी](./README.hi.md)

---

## 🌱 Was dieses Tool löst

Wenn du Claude Code regelmäßig nutzt, kommen dir diese Situationen sicher bekannt vor:

- **"Ich habe diesen Fehler gestern doch gelöst... muss ich das wirklich nochmal erklären?"**
- **"Ich habe keine Lust, den Projektkontext in jeder Session neu zu erklären."**
- **"Das ist das dritte Mal, dass ich diese Aufgabe mache. Kann Claude das nicht einfach wissen?"**
- **"Ich weiß selbst nicht, in welchen Bereichen Claude stark ist und wo er oft daneben liegt."**

Installiere diese Hooks, und Claude Code beginnt, **selbstständig zu lernen und sich zu erinnern**.

| Was Claude tut | Wann |
|---|---|
| Erkennt den Projekt-Stack → lädt relevante Memories automatisch | Session-Start |
| Sucht bei bekannten Fehlern nach früheren Lösungen | Build/Command schlägt fehl |
| Fragt "Willst du speichern, was du diese Session gelernt hast?" | Session-Ende |
| Schlägt Skill-Erstellung bei wiederholter Arbeit vor | Gleiche Aufgabe 5+ Mal |
| Verfolgt Genauigkeit pro Domain → markiert schwache Bereiche proaktiv | Build-Fehler erkannt |

**Kein Entwickler nötig, um das zu installieren.** Einfach einen Befehl ins Terminal einfügen.

---

### ⭐ Memory-First Workflow (das Kernfeature)

Eingabe: **"Check mal den Ton"** — kein weiterer Kontext.

Ohne self-learn: Claude fragt zurück "Welchen Ton? Gib mir den Text."

Mit self-learn: Claude `Glob`t `~/.claude/memory/feedback_*tone*.md`, `Read`s die Treffer und antwortet:

> "Ich erinnere mich, dass du für öffentliche Docs einen freundlichen, vorab-erklärenden Ton bevorzugst (keine defensive Formulierung). Soll ich das als Standard nehmen? Gib den Pfad/Inhalt."
> (参照: feedback_oss_friendly_tone.md)

Funktioniert für alles, zu dem du Präferenzen/Patterns/Lösungen gespeichert hast — **du musst nie "schau in die Memory" sagen**.

---

## ⚡ 30-Sekunden-Installation (einfachster Weg)

Terminal öffnen, diese eine Zeile reinkopieren:

```bash
curl -sSL https://raw.githubusercontent.com/DAYLAB-HQ/claude-self-learn/main/quickstart.sh | bash
```

Fertig. Script kümmert sich um jq, Download und Ausführung.
(Lieber den Code vorher lesen? Siehe manuelle Installation unten.)

> **Windows**: Zuerst WSL (`wsl`) oder Git Bash öffnen, dann die Zeile einfügen.

---

## 🚀 Manuelle Installation (5 Minuten, mit Code-Review)

### Schritt 1: Terminal öffnen
- **Mac**: Spotlight (⌘+Leertaste) → "Terminal" suchen → Enter
- **Linux**: Terminal-App öffnen
- **Windows**: Etwas mehr Schritte, aber machbar!
  - **Einfachster Weg**: WSL installieren (der "Linux-Modus", der in Windows eingebaut ist).
    PowerShell öffnen, `wsl --install` eingeben, PC neu starten, "Ubuntu" im Startmenü öffnen.
    Dort funktionieren die Befehle unten genauso wie auf Mac/Linux.
  - **Alternative**: Falls du [Git for Windows](https://git-scm.com/download/win) schon hast,
    öffne "Git Bash" aus dem Startmenü — die Befehle sollten dort größtenteils auch laufen.

### Schritt 2: jq installieren (einmalig)
```bash
brew install jq
```

### Schritt 3: Herunterladen + installieren (eine Zeile)
```bash
git clone https://github.com/DAYLAB-HQ/claude-self-learn.git && cd claude-self-learn && ./install.sh
```

Bei **"Proceed? [Y/n]"** einfach **Y** drücken und Enter.

### Schritt 4: Verifizieren
Neue Claude Code Session öffnen und:
```
/self-learn:stats
```

Ein Dashboard erscheint? Fertig! 🎉

---

## 🛡️ Sichere Installation

Nutzt du Claude Code bereits? **Dieser Installer lässt deine bestehende Konfiguration unangetastet.**

### Wird NIE überschrieben
- Deine Memory-Dateien (`~/.claude/memory/`)
- Deine Learning-Logs (`~/.claude/self-improvement/`)
- Deine Custom Skills, Rules oder Commands

### Vor der Installation Vorschau ansehen
```bash
./install.sh --dry-run
```

### Jederzeit sauber deinstallieren
```bash
./uninstall.sh
```

---

## 📖 Nutzung

### Am Ende der Session Gelerntes speichern
```
/self-learn
```

### Dashboard anzeigen
```
/self-learn:stats
```

### Sehen, wo Claude schwach ist
```
/self-learn:calibration
```

### Wöchentliches Audit
```
/self-learn:audit
```

Details im [englischen README](../README.md).

---

## 🙏 Was du vorher wissen solltest

Das ist ursprünglich mein persönliches Setup, jetzt öffentlich. Bitte sei nachsichtig:

- **Antworten auf Issues/PRs können dauern** — Ich schaue, wenn ich Zeit habe. Für Eiliges ist ein Fork super!
- **Breaking Changes können kommen** — Entwickelt sich mit meinem Workflow
- **Windows bitte über WSL oder Git Bash** — Kann es nicht selbst testen. Volle native Unterstützung kommt hoffentlich in einer späteren Version. Wenn etwas unter Windows bricht, bitte Screenshot in Issues teilen 🙏
- **Feature-Requests sind schwierig** — Aber wenn du was in einem Fork baust, teile es gern in den Issues! 🙌

---

## 🎁 Wer das gebaut hat

[DAYLAB](https://daylab.dev) — ein kleines Studio, das mehrere Solo-Produkte mit Claude Code ausliefert.

Wenn's dir hilft, würde ein ⭐ viel bedeuten.

## 📜 Lizenz

[MIT](../LICENSE) — frei nutzbar, auch kommerziell.
