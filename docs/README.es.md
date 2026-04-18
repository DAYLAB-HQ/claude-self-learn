# self-learn

> **Un pequeño sistema que hace que Claude Code recuerde lo aprendido — para que la próxima sesión empiece más inteligente que la anterior.**

[🇺🇸 English](../README.md) · [🇰🇷 한국어](./README.ko.md) · [🇯🇵 日本語](./README.ja.md) · [🇨🇳 中文](./README.zh.md) · [🇩🇪 Deutsch](./README.de.md) · [🇫🇷 Français](./README.fr.md) · **🇪🇸 Español** · [🇧🇷 Português](./README.pt.md) · [🇷🇺 Русский](./README.ru.md) · [🇮🇳 हिन्दी](./README.hi.md)

---

## 🌱 Los problemas que esto resuelve

Si usas Claude Code regularmente, probablemente te suene:

- **"Juro que arreglé este error ayer... ¿tengo que volver a explicarlo?"**
- **"Estoy cansado de re-explicar el contexto del proyecto cada sesión nueva."**
- **"Es la tercera vez que hago esta misma tarea. ¿Claude no puede saberlo?"**
- **"Ni yo sé en qué áreas Claude es bueno y en cuáles se equivoca."**

Instala estos hooks y Claude Code empieza a **aprender y recordar por sí solo**.

| Lo que Claude hace | Cuándo |
|---|---|
| Detecta el stack del proyecto → carga memorias relacionadas | Al iniciar sesión |
| Busca soluciones previas para errores conocidos | Build/comando falla |
| Pregunta "¿Guardar lo que aprendiste esta sesión?" | Al cerrar sesión |
| Propone crear un skill para tareas repetidas | Misma tarea 5+ veces |
| Rastrea precisión por dominio → marca áreas débiles preventivamente | Errores de build detectados |

**No necesitas ser desarrollador para instalar esto.** Solo pega un comando en la terminal.

---

### ⭐ Workflow Memory-First (la característica estrella)

Entrada: **"revisa el tono"** — sin más contexto.

Sin self-learn: Claude pregunta "¿qué tono? pega el texto."

Con self-learn: Claude hace `Glob` en `~/.claude/memory/feedback_*tone*.md`, `Read` los matches y responde:

> "Recuerdo que para docs públicas prefieres un tono cálido y anticipatorio, evitando frases defensivas. ¿Lo uso como estándar? Pasa la ruta/contenido."
> (参照: feedback_oss_friendly_tone.md)

Funciona para todo tema donde hayas guardado preferencias/patrones/soluciones — **nunca tienes que decir "revisa la memoria"**.

---

## ⚡ Instalación en 30 segundos (la más fácil)

Abre una terminal y pega esta única línea:

```bash
curl -sSL https://raw.githubusercontent.com/DAYLAB-HQ/claude-self-learn/main/quickstart.sh | bash
```

Listo. El script se encarga de jq, la descarga y la ejecución.
(¿Prefieres revisar el código primero? Ve la instalación manual abajo.)

> **Windows**: Abre WSL (`wsl`) o Git Bash primero, luego pega la línea.

---

## 🚀 Instalación manual (5 minutos, para revisar el código)

### Paso 1: Abrir terminal
- **Mac**: Spotlight (⌘+Espacio) → buscar "Terminal" → Enter
- **Linux**: Abrir la app Terminal
- **Windows**: Unos pasos más, ¡pero se puede!
  - **Lo más fácil**: Instalar WSL (el "modo Linux" que viene dentro de Windows).
    Abre PowerShell, ejecuta `wsl --install`, reinicia el PC, abre "Ubuntu" desde el menú Inicio.
    Ahí los comandos de abajo funcionan igual que en Mac/Linux.
  - **Alternativa**: Si ya tienes [Git for Windows](https://git-scm.com/download/win),
    abre "Git Bash" desde el menú Inicio — los comandos de abajo deberían funcionar.

### Paso 2: Instalar jq (una sola vez)
```bash
brew install jq
```

### Paso 3: Descargar + instalar (una línea)
```bash
git clone https://github.com/DAYLAB-HQ/claude-self-learn.git && cd claude-self-learn && ./install.sh
```

Cuando pregunte **"Proceed? [Y/n]"**, presiona **Y** y Enter.

### Paso 4: Verificar
Abre una nueva sesión de Claude Code:
```
/self-learn:stats
```

¿Aparece un dashboard? ¡Listo! 🎉

---

## 🛡️ Instalación segura

¿Ya usas Claude Code? **Este instalador no tocará tu configuración existente.**

### Nunca se sobrescribe
- Tus archivos de memoria (`~/.claude/memory/`)
- Tus logs de aprendizaje (`~/.claude/self-improvement/`)
- Tus skills, rules y commands personalizados

### Previsualizar antes de instalar
```bash
./install.sh --dry-run
```

### Desinstalación limpia en cualquier momento
```bash
./uninstall.sh
```

---

## 📖 Uso

### Guardar lo aprendido al final de sesión
```
/self-learn
```

### Ver el dashboard
```
/self-learn:stats
```

### Ver dónde Claude es débil
```
/self-learn:calibration
```

### Auditoría semanal
```
/self-learn:audit
```

Más detalles en el [README en inglés](../README.md).

---

## 🙏 Algunas cosas que te quiero contar de antemano

Esto empezó como mi setup personal que decidí compartir. Algunas expectativas honestas:

- **Las respuestas a issues/PRs pueden ser lentas** — reviso cuando puedo. Para algo urgente, ¡forkearlo es genial!
- **Puede haber cambios incompatibles** — evoluciona con mi workflow
- **Windows va por WSL o Git Bash por ahora** — no puedo probarlo yo mismo. Soporte nativo completo planeado para versiones futuras. Si algo falla en Windows, comparte captura en Issues 🙏
- **Las solicitudes de features son difíciles** — pero si lo construyes en un fork, compártelo en Issues 🙌

---

## 🎁 Quién lo hizo

[DAYLAB](https://daylab.dev) — un pequeño estudio que lanza varios productos en solitario con Claude Code.

Si te ayuda, una ⭐ sería genial.

## 📜 Licencia

[MIT](../LICENSE) — úsalo libremente, incluido uso comercial.
