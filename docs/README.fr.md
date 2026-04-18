# self-learn

> **Un petit système qui permet à Claude Code de se souvenir de ce qu'il a appris — pour que la session suivante commence plus intelligente que la précédente.**

[🇺🇸 English](../README.md) · [🇰🇷 한국어](./README.ko.md) · [🇯🇵 日本語](./README.ja.md) · [🇨🇳 中文](./README.zh.md) · [🇩🇪 Deutsch](./README.de.md) · **🇫🇷 Français** · [🇪🇸 Español](./README.es.md) · [🇧🇷 Português](./README.pt.md) · [🇷🇺 Русский](./README.ru.md) · [🇮🇳 हिन्दी](./README.hi.md)

---

## 🌱 Les problèmes que ça résout

Si vous utilisez Claude Code régulièrement, ces situations vous parlent probablement :

- **« J'ai juré avoir résolu cette erreur hier... dois-je vraiment tout réexpliquer ? »**
- **« J'en ai marre de ré-expliquer le contexte du projet à chaque nouvelle session. »**
- **« C'est la troisième fois que je fais la même tâche. Claude ne peut pas juste le savoir ? »**
- **« Je ne sais même pas dans quels domaines Claude est fort et lesquels il se trompe. »**

Installez ces hooks, et Claude Code commence à **apprendre et se souvenir tout seul**.

| Ce que Claude fait | Quand |
|---|---|
| Détecte la stack du projet → charge les mémoires liées | Début de session |
| Cherche des solutions précédentes pour erreurs connues | Échec de build/commande |
| Demande « Sauvegarder ce que vous avez appris cette session ? » | Fin de session |
| Propose de créer un skill pour le travail répété | Même tâche faite 5+ fois |
| Suit la précision par domaine → signale les zones faibles | Erreurs de build détectées |

**Pas besoin d'être développeur pour installer.** Collez juste une commande dans le terminal.

---

### ⭐ Workflow Memory-First (la fonctionnalité phare)

Entrée : **« check le ton »** — aucun autre contexte.

Sans self-learn : Claude demande « quel ton ? donne le texte. »

Avec self-learn : Claude fait un `Glob` sur `~/.claude/memory/feedback_*tone*.md`, `Read` les matches et répond :

> « Je me souviens que tu préfères un ton chaleureux et préventif pour les docs publiques (pas de formulation défensive). Je pars là-dessus ? Colle le chemin/contenu. »
> (参照: feedback_oss_friendly_tone.md)

Fonctionne pour tout sujet sur lequel tu as stocké des préférences/patterns/solutions — **tu n'as jamais à dire "vérifie la mémoire"**.

---

## ⚡ Installation en 30 secondes (le plus simple)

Ouvrez un terminal, collez cette seule ligne :

```bash
curl -sSL https://raw.githubusercontent.com/DAYLAB-HQ/claude-self-learn/main/quickstart.sh | bash
```

Voilà. Le script gère jq, le téléchargement et l'exécution tout seul.
(Vous voulez lire le code avant ? Voir l'installation manuelle ci-dessous.)

> **Windows** : Ouvrez d'abord WSL (`wsl`) ou Git Bash, puis collez la ligne.

---

## 🚀 Installation manuelle (5 minutes, pour relire le code)

### Étape 1 : Ouvrir un terminal
- **Mac**: Spotlight (⌘+Espace) → chercher "Terminal" → Entrée
- **Linux**: Ouvrir l'application Terminal
- **Windows** : Quelques étapes en plus, mais c'est faisable !
  - **Le plus simple** : Installer WSL (le "mode Linux" intégré à Windows).
    Ouvrez PowerShell, tapez `wsl --install`, redémarrez, lancez "Ubuntu" depuis le menu Démarrer.
    Dedans, les commandes ci-dessous fonctionnent comme sur Mac/Linux.
  - **Alternative** : Si vous avez déjà [Git for Windows](https://git-scm.com/download/win),
    ouvrez "Git Bash" depuis le menu Démarrer — les commandes ci-dessous devraient marcher.

### Étape 2 : Installer jq (une seule fois)
```bash
brew install jq
```

### Étape 3 : Télécharger + installer (une ligne)
```bash
git clone https://github.com/DAYLAB-HQ/claude-self-learn.git && cd claude-self-learn && ./install.sh
```

Quand il demande **"Proceed? [Y/n]"**, appuyez **Y** et Entrée.

### Étape 4 : Vérifier
Ouvrir une nouvelle session Claude Code :
```
/self-learn:stats
```

Un dashboard apparaît ? C'est bon ! 🎉

---

## 🛡️ Installation sans risque

Vous utilisez déjà Claude Code ? **Cet installateur ne touchera pas à votre configuration existante.**

### Jamais écrasé
- Vos fichiers mémoire (`~/.claude/memory/`)
- Vos logs d'apprentissage (`~/.claude/self-improvement/`)
- Vos skills, rules et commands personnalisés

### Prévisualiser avant d'installer
```bash
./install.sh --dry-run
```

### Désinstallation propre à tout moment
```bash
./uninstall.sh
```

---

## 📖 Utilisation

### Sauvegarder ce qu'on a appris en fin de session
```
/self-learn
```

### Voir le dashboard
```
/self-learn:stats
```

### Voir où Claude est faible
```
/self-learn:calibration
```

### Audit hebdomadaire
```
/self-learn:audit
```

Détails dans le [README en anglais](../README.md).

---

## 🙏 Quelques précisions honnêtes

C'est à l'origine mon setup perso que j'ai décidé de partager. Quelques attentes honnêtes :

- **Les réponses aux issues/PR peuvent être lentes** — je regarde quand je peux. Pour de l'urgent, forker est top !
- **Des changements cassants peuvent arriver** — ça évolue avec mon workflow
- **Windows passe par WSL ou Git Bash pour l'instant** — je ne peux pas le tester moi-même. Support natif prévu pour une version ultérieure. Si ça casse sur Windows, partagez une capture d'écran en Issues 🙏
- **Les demandes de fonctionnalités sont difficiles à accommoder** — mais si vous le construisez dans un fork, partagez ! D'autres en profiteront 🙌

---

## 🎁 Qui a fait ça

[DAYLAB](https://daylab.dev) — un petit studio qui livre plusieurs produits solo avec Claude Code.

Si ça vous aide, une ⭐ serait appréciée.

## 📜 Licence

[MIT](../LICENSE) — utilisable librement, y compris commercialement.
