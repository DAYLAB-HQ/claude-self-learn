# self-learn

> **让 Claude Code 记住每次会话学到的东西,下一次会话更聪明的小工具**

[🇺🇸 English](../README.md) · [🇰🇷 한국어](./README.ko.md) · [🇯🇵 日本語](./README.ja.md) · **🇨🇳 中文** · [🇩🇪 Deutsch](./README.de.md) · [🇫🇷 Français](./README.fr.md) · [🇪🇸 Español](./README.es.md) · [🇧🇷 Português](./README.pt.md) · [🇷🇺 Русский](./README.ru.md) · [🇮🇳 हिन्दी](./README.hi.md)

---

## 🌱 这个工具解决什么问题

经常使用 Claude Code 的人,这些场景应该很熟悉:

- **"昨天明明解决过这个错误...难道又要重新讲一遍?"**
- **"每次开新会话都要重新说明项目背景,太累了"**
- **"同一个任务第三次做了,Claude 每次都从头开始"**
- **"Claude 在哪些领域擅长,在哪些容易出错,我自己都搞不清楚"**

安装这套 hooks,Claude Code 就开始 **自己学习、自己记忆**。

| Claude 会做什么 | 什么时候 |
|---|---|
| 识别项目技术栈 → 自动加载相关记忆 | 会话开始时 |
| 出错时自动匹配历史解决方案 | 构建/命令失败时 |
| 询问"要保存这次会话学到的吗?" | 会话结束时 |
| 检测到重复任务 → 建议做成 skill | 同一任务做了 5 次以上 |
| 按领域追踪准确率 → 弱项提前坦白 | 检测到构建错误时 |

**不是开发者也能用。** 在终端里复制粘贴一行命令即可。

---

### ⭐ Memory-First 工作流 (核心功能)

输入: **"看一下 tone"** — 没有其他上下文。

没有 self-learn: Claude 反问 "什么 tone? 请给文本"。

有 self-learn: Claude 用 `Glob` 搜 `~/.claude/memory/feedback_*tone*.md` → `Read` 匹配文件 → 回复:

> "我记得你公开文档偏好友好的前置引导语调,避免防御性表达。要用这个标准检查吗? 请提供文件路径。"
> (参考: feedback_oss_friendly_tone.md)

对你存储过偏好/模式/方案的所有话题都有效 — **你永远不用说"查一下 memory"**。

---

## ⚡ 30秒安装 (最简单)

打开终端,粘贴这一行:

```bash
curl -sSL https://raw.githubusercontent.com/DAYLAB-HQ/claude-self-learn/main/quickstart.sh | bash
```

就这样。jq 安装、下载、运行全自动。
(想先看代码?看下面的手动安装。)

> **Windows**: 先打开 WSL (`wsl` 命令) 或 Git Bash,再粘贴这一行。

---

## 🚀 手动安装 (5 分钟,适合想看代码的人)

### Step 1: 打开终端
- **Mac**: Spotlight (⌘+Space) 搜索 "Terminal" → 回车
- **Linux**: 打开终端应用
- **Windows**: 多几步但也能用!
  - **最简单**: 装 WSL (Windows 自带的"Linux 模式")。
    打开 PowerShell,输入 `wsl --install`,重启电脑,从开始菜单打开"Ubuntu"。
    在里面运行下面的命令,跟 Mac/Linux 一样。
  - **另一种办法**: 如果已经装了 [Git for Windows](https://git-scm.com/download/win),
    从开始菜单打开 "Git Bash",下面的命令大部分都能用。

### Step 2: 安装 jq (只需一次)
```bash
brew install jq
```

### Step 3: 下载 + 安装 (一行)
```bash
git clone https://github.com/DAYLAB-HQ/claude-self-learn.git && cd claude-self-learn && ./install.sh
```

出现 **"Proceed? [Y/n]"** 时按 **Y** 回车。

### Step 4: 验证
新建一个 Claude Code 会话,试试:
```
/self-learn:stats
```

看到 dashboard 就安装成功了 🎉

---

## 🛡️ 安全无损安装

已经在用 Claude Code? **这个安装器绝不会影响你现有的配置。**

### 永远不会覆盖
- 已有的记忆文件 (`~/.claude/memory/`)
- 已有的学习日志 (`~/.claude/self-improvement/`)
- 已有的自定义 skills、rules、commands

### 安装前预览
```bash
./install.sh --dry-run
```

### 随时干净卸载
```bash
./uninstall.sh
```

---

## 📖 使用方法

### 会话结束时保存学到的东西
```
/self-learn
```

### 查看仪表盘
```
/self-learn:stats
```

### 查看各领域准确率
```
/self-learn:calibration
```

### 每周审计
```
/self-learn:audit
```

更多详情请查看 [英文版 README](../README.md)。

---

## 🙏 提前说明几件事

这本来是自己用的工具,分享出来,请理解:

- **Issue/PR 响应可能会慢** — 有空才能看,急着要的话推荐 fork
- **可能会有破坏性更新** — 随我个人工作流演进
- **Windows 请通过 WSL 或 Git Bash 使用** — 我自己没法测试,完全原生支持等后续版本。遇到问题请在 Issues 发截图 🙏
- **功能请求可能无法满足** — 不过如果你 fork 自己做了,欢迎到 Issues 分享 🙌

---

## 🎁 作者

[DAYLAB](https://daylab.dev) — 用 Claude Code 做多款 solo 产品的小工作室。

如果对你有帮助,欢迎点 ⭐!

## 📜 许可证

[MIT](../LICENSE) — 免费使用,商用也行。
