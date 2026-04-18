# self-learn

> **Um pequeno sistema que faz o Claude Code lembrar do que aprendeu — pra que a próxima sessão comece mais esperta que a anterior.**

[🇺🇸 English](../README.md) · [🇰🇷 한국어](./README.ko.md) · [🇯🇵 日本語](./README.ja.md) · [🇨🇳 中文](./README.zh.md) · [🇩🇪 Deutsch](./README.de.md) · [🇫🇷 Français](./README.fr.md) · [🇪🇸 Español](./README.es.md) · **🇧🇷 Português** · [🇷🇺 Русский](./README.ru.md) · [🇮🇳 हिन्दी](./README.hi.md)

---

## 🌱 Os problemas que isso resolve

Se você usa Claude Code com frequência, essas situações provavelmente soam familiares:

- **"Juro que resolvi esse erro ontem... preciso explicar tudo de novo?"**
- **"Cansei de re-explicar o contexto do projeto toda sessão nova."**
- **"Terceira vez que faço essa mesma tarefa. O Claude não pode só saber?"**
- **"Nem eu sei em quais áreas o Claude manda bem e em quais erra."**

Instale esses hooks e o Claude Code começa a **aprender e lembrar sozinho**.

| O que o Claude faz | Quando |
|---|---|
| Detecta a stack do projeto → carrega memórias relacionadas | Início de sessão |
| Busca soluções anteriores pra erros conhecidos | Build/comando falha |
| Pergunta "Salvar o que aprendeu nessa sessão?" | Fim de sessão |
| Sugere criar um skill pra tarefas repetidas | Mesma tarefa 5+ vezes |
| Rastreia precisão por domínio → sinaliza áreas fracas | Erros de build detectados |

**Não precisa ser dev pra instalar.** Só colar um comando no terminal.

---

### ⭐ Workflow Memory-First (a funcionalidade principal)

Entrada: **"revisa o tom"** — sem mais contexto.

Sem self-learn: Claude pergunta "qual tom? cola o texto."

Com self-learn: Claude faz `Glob` em `~/.claude/memory/feedback_*tone*.md`, `Read` dos matches e responde:

> "Lembro que pra docs públicas você prefere um tom amigável e antecipativo, sem frases defensivas. Uso esse padrão? Manda o caminho/conteúdo."
> (参照: feedback_oss_friendly_tone.md)

Funciona pra qualquer tópico onde você salvou preferências/padrões/soluções — **você nunca precisa dizer "olha na memória"**.

---

## ⚡ Instalação em 30 segundos (o mais fácil)

Abre um terminal e cola essa linha:

```bash
curl -sSL https://raw.githubusercontent.com/DAYLAB-HQ/claude-self-learn/main/quickstart.sh | bash
```

Pronto. O script cuida do jq, do download e da execução.
(Quer revisar o código antes? Veja a instalação manual abaixo.)

> **Windows**: Abre WSL (`wsl`) ou Git Bash primeiro, depois cola a linha.

---

## 🚀 Instalação manual (5 minutos, pra quem quer revisar o código)

### Passo 1: Abrir o terminal
- **Mac**: Spotlight (⌘+Espaço) → buscar "Terminal" → Enter
- **Linux**: Abrir o app Terminal
- **Windows**: Uns passos a mais, mas dá!
  - **Jeito mais fácil**: Instalar WSL (o "modo Linux" que já vem embutido no Windows).
    Abre o PowerShell, roda `wsl --install`, reinicia o PC, abre "Ubuntu" pelo menu Iniciar.
    Lá dentro os comandos abaixo funcionam igual ao Mac/Linux.
  - **Alternativa**: Se já tens [Git for Windows](https://git-scm.com/download/win) instalado,
    abre "Git Bash" pelo menu Iniciar — os comandos abaixo devem rodar por aí também.

### Passo 2: Instalar jq (só uma vez)
```bash
brew install jq
```

### Passo 3: Baixar + instalar (uma linha)
```bash
git clone https://github.com/DAYLAB-HQ/claude-self-learn.git && cd claude-self-learn && ./install.sh
```

Quando perguntar **"Proceed? [Y/n]"**, aperta **Y** e Enter.

### Passo 4: Verificar
Abre uma nova sessão do Claude Code:
```
/self-learn:stats
```

Apareceu um dashboard? Tá pronto! 🎉

---

## 🛡️ Instalação segura

Já usa Claude Code? **Esse instalador não mexe na sua configuração existente.**

### Nunca é sobrescrito
- Seus arquivos de memória (`~/.claude/memory/`)
- Seus logs de aprendizado (`~/.claude/self-improvement/`)
- Seus skills, rules e commands customizados

### Pré-visualizar antes de instalar
```bash
./install.sh --dry-run
```

### Desinstalar limpinho a qualquer hora
```bash
./uninstall.sh
```

---

## 📖 Como usar

### Salvar o aprendizado no fim de uma sessão
```
/self-learn
```

### Ver o dashboard
```
/self-learn:stats
```

### Ver onde o Claude é fraco
```
/self-learn:calibration
```

### Auditoria semanal
```
/self-learn:audit
```

Mais detalhes no [README em inglês](../README.md).

---

## 🙏 Umas coisas pra te contar antes

Isso começou como meu setup pessoal que resolvi compartilhar. Umas expectativas honestas:

- **Resposta em issues/PRs pode demorar** — dou uma olhada quando dá. Se precisar rápido, forka!
- **Pode ter breaking changes** — evolui com meu workflow
- **Windows usa WSL ou Git Bash por enquanto** — não consigo testar sozinho. Suporte nativo completo planejado pra versões futuras. Se quebrar no Windows, manda print no Issues 🙏
- **Requests de feature são difíceis** — mas se você construir num fork, compartilha nos Issues 🙌

---

## 🎁 Quem fez

[DAYLAB](https://daylab.dev) — um estúdio pequeno que entrega vários produtos solo com Claude Code.

Se te ajudou, uma ⭐ seria muito legal.

## 📜 Licença

[MIT](../LICENSE) — usa à vontade, inclusive pra fins comerciais.
