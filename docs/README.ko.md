# self-learn

> **Claude Code가 매 세션마다 배운 걸 스스로 기억하고 다음에 활용하게 만드는 작은 시스템**

[🇺🇸 English](../README.md) · **🇰🇷 한국어** · [🇯🇵 日本語](./README.ja.md) · [🇨🇳 中文](./README.zh.md) · [🇩🇪 Deutsch](./README.de.md) · [🇫🇷 Français](./README.fr.md) · [🇪🇸 Español](./README.es.md) · [🇧🇷 Português](./README.pt.md) · [🇷🇺 Русский](./README.ru.md) · [🇮🇳 हिन्दी](./README.hi.md)

---

## 🌱 이 도구가 풀려는 문제

Claude Code를 자주 쓰시다 보면 이런 순간이 있지 않으셨나요?

- **"어제 분명히 이 에러 해결했는데... 다시 알려줘야 해?"**
- **"프로젝트 시작할 때마다 컨텍스트 다시 설명하기 지쳐요"**
- **"이 작업 세 번째인데, 매번 처음부터 하게 되네"**
- **"Claude가 뭘 잘하고 뭘 자주 틀리는지 나도 파악이 안 돼"**

이 훅을 설치하면, Claude Code가 **스스로 배우고 기억**하기 시작합니다.

| Claude가 해주는 일 | 언제 |
|---|---|
| 프로젝트 스택 감지 → 관련 메모리 자동 로드 | 세션 시작할 때 |
| **유저 메시지 분석 → 관련 메모리 자동 참조** ("메모리 봐줘" 말 필요 X) | 애매하거나 짧은 요청마다 |
| 에러 나면 이전에 해결한 기록 찾아서 알려줌 | 빌드·명령 실패할 때 |
| "이번 세션에서 배운 거 저장할까요?" 물어봄 | 세션 종료할 때 |
| 반복 작업 감지 → 스킬로 만들까요? 제안 | 같은 작업 5번 이상 할 때 |
| 도메인별 정확도 추적 → 약한 영역 선제 고백 | 빌드 에러 감지할 때 |

### ⭐ Memory-First 워크플로우 (핵심 기능)

유저 입력: **"톤 좀 봐줘"** — 다른 맥락 없음.

self-learn 없으면: Claude가 "어떤 톤이요? 텍스트 주세요" 되물음.

self-learn 있으면: Claude가 `Glob ~/.claude/memory/feedback_*tone*.md` → 매칭 파일 `Read` → 답변:

> "기억하기론 공개 문서에 친절한 앞서 안내 스타일 선호하시는데, 그 기준으로 체크해드릴까요? 파일 경로 주세요."
> (참조: feedback_oss_friendly_tone.md)

저장해놓은 선호·패턴·해법이 있는 모든 주제에 적용 — **"메모리 확인해줘"라고 절대 말 할 필요 없음**.

**개발 경험이 없어도 쓸 수 있어요.** 터미널에 명령어 한 줄 붙여넣으시면 됩니다.

---

## ⚡ 30초 설치 (가장 쉬움)

터미널 열고 이 한 줄 복사해 붙여넣으세요:

```bash
curl -sSL https://raw.githubusercontent.com/DAYLAB-HQ/claude-self-learn/main/quickstart.sh | bash
```

끝. jq 설치부터 다운로드, 실행까지 자동.
(코드 먼저 확인하고 싶으시면 아래 수동 설치 참고.)

> **Windows**: WSL(`wsl` 명령어) 또는 Git Bash 먼저 열고 같은 줄 복붙하시면 됩니다.

---

## 🚀 수동 설치 (5분, 코드 확인하고 싶으신 분)

### 1단계: 터미널 열기
- **Mac**: Spotlight(⌘+스페이스)에서 "터미널" 검색 → Enter
- **Linux**: 터미널 앱 실행
- **Windows**: 조금 번거롭지만 가능해요!
  - **가장 쉬운 방법**: WSL 설치 (Windows에 내장된 "리눅스 모드" 기능).
    PowerShell 실행 → `wsl --install` 입력 → PC 재시작 → 시작 메뉴에서 "Ubuntu" 실행.
    그 안에서 아래 명령어들이 Mac/Linux처럼 그대로 작동합니다.
  - **또 다른 방법**: 이미 [Git for Windows](https://git-scm.com/download/win)가 설치돼 있으면,
    시작 메뉴에서 "Git Bash" 열면 아래 명령어들이 대부분 그대로 돌아갑니다.

### 2단계: jq 설치 (한 번만 하시면 됩니다)
터미널에 복사해서 붙여넣고 Enter:
```bash
brew install jq
```

> `brew: command not found` 메시지가 나오시면?
> [Homebrew](https://brew.sh) 먼저 설치하시고 위 명령어 다시 실행해주세요.

### 3단계: 다운로드 + 설치 (한 줄)
```bash
git clone https://github.com/DAYLAB-HQ/self-learn.git && cd self-learn && ./install.sh
```

설치 스크립트가 친절하게 안내해드릴 거예요. 중간에 **"진행하시겠습니까? [Y/n]"** 나오면 **Y** 누르고 Enter.

### 4단계: 설치됐는지 확인
Claude Code 새 세션 열고:
```
/self-learn:stats
```

대시보드가 뜨면 설치 완료! 🎉

---

## 🛡️ 안전하게 설치됩니다

이미 Claude Code를 사용 중이셔도 **기존 설정은 건드리지 않아요**.

### 절대 덮어쓰지 않는 것
- 기존 메모리 파일 (`~/.claude/memory/`) — 그동안 쌓아오신 기록 전부 그대로
- 기존 학습 로그 (`~/.claude/self-improvement/`)
- 기존 커스텀 스킬·룰·커맨드

### 설치 전에 미리 확인하실 수 있어요
```bash
./install.sh --dry-run
```
실제로 설치하지 않고 **뭐가 어디 설치될지**만 미리 보여드립니다.

### 기존에 같은 이름 파일이 있으면
- 기본: 안전하게 **스킵** (건드리지 않음)
- 업데이트하고 싶으시면: `./install.sh --backup` (`.bak` 백업 만들고 덮어쓰기)

### settings.json도 안전하게 병합
- 백업 자동 생성 (`.bak`)
- 중복 훅 감지 — 이미 있는 건 추가하지 않음
- hooks 섹션만 병합, 다른 설정은 그대로

### 언제든 깨끗하게 제거할 수 있어요
```bash
./uninstall.sh
```
그동안 쌓인 메모리·학습 로그는 보존합니다. 완전 초기화 원하시면 `--purge`.

---

## 📖 사용법

### 세션 끝날 때 배운 거 저장하기
```
/self-learn
```
이번 세션에서 하신 작업을 Claude가 자동으로 분류해 드립니다:

- **pattern** — 성공한 기술 접근법
- **troubleshoot** — 해결한 에러
- **feedback** — 새로 알게 된 유저 선호
- **skill_candidate** — 반복 패턴 (5회 이상이면 스킬화 제안)

각 항목마다 **"저장할까요?"** 물어봐요. 원하지 않으시면 거절 가능합니다.

### 현황 대시보드 보기
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

### Claude가 어떤 영역에 약한지 확인
```
/self-learn:calibration
```
도메인별(Next.js, Expo, Prisma 등) 정확도가 보여요. 약한 영역(50% 미만)에서는 Claude가 **"이 부분은 확실하지 않습니다"** 라고 선제적으로 알려드립니다.

### 주간 감사 (가볍게 정리하기)
```
/self-learn:audit
```
오래된 메모리·중복·모순 자동 감지. 3번 이상 반복된 피드백은 rule로 승격 제안.

---

## 🔧 뭐가 어디에 설치되는지 (투명하게 공개)

```
~/.claude/
├── hooks/                         ← 자동 실행되는 스크립트
│   ├── session-start-preloader.sh    (세션 시작 → 메모리 프리로드)
│   ├── self-learn-stop.sh            (세션 종료 → 학습 체크)
│   ├── detect-commit.sh              (커밋 감지 → 로그)
│   ├── error-auto-matcher.sh         (에러 → 이전 해법 매칭)
│   └── calibration-tracker.sh        (실패 → 도메인 정확도)
│
├── skills/self-learn/             ← /self-learn 명령어 구현
├── commands/self-learn/           ← 서브커맨드 정의
├── rules/self-improvement.md      ← 기본 동작 규칙
├── memory/                        ← 배운 것들이 쌓이는 곳
│   └── MEMORY.md                     (인덱스)
└── self-improvement/              ← 학습 로그·대시보드 데이터
    ├── LEARNINGS.jsonl
    ├── SKILLS_TRACKER.json
    ├── calibration.json
    └── AUDIT_LOG.md
```

---

## 💡 다른 도구와 차이

| | self-learn | 다른 프레임워크 (Hermes 등) |
|---|---|---|
| 설치 | 쉘 스크립트 하나 | Python/Node 의존성 |
| 커스텀 | 파일 직접 편집 | 프레임워크 API 학습 필요 |
| 무게 | ~700줄 | 수천 줄 |
| 철학 | "개인 셋업 공유" | 범용 추상화 |

self-learn은 **프레임워크가 아니라 개인 셋업입니다.** 마음에 드는 부분만 가져다 쓰시거나, fork해서 본인 스타일대로 수정하시는 걸 추천드려요.

---

## 🆘 자주 겪는 문제

### "jq: command not found"
```bash
brew install jq        # Mac
sudo apt install jq    # Linux
```

### "Permission denied: ./install.sh"
실행 권한 부여 후 재실행:
```bash
chmod +x install.sh
./install.sh
```

### 설치는 됐는데 훅이 동작을 안 해요
`~/.claude/settings.json`에 hooks 섹션이 제대로 들어갔는지 확인해보세요:
```bash
cat ~/.claude/settings.json | jq .hooks
```
비어 있거나 이상하면 수동 병합:
```bash
cat settings.sample.json
```
이 내용을 `~/.claude/settings.json`의 `hooks` 섹션에 붙여넣으시면 됩니다.

### 파일이 덮어써진 것 같아요
`--backup` 옵션을 썼다면 `.bak` 파일이 있을 거예요:
```bash
ls ~/.claude/hooks/*.bak
# 복구:
mv ~/.claude/hooks/detect-commit.sh.bak ~/.claude/hooks/detect-commit.sh
```

### 완전히 제거하고 싶어요
```bash
./uninstall.sh           # 코드만 제거, 쌓인 메모리는 보존
./uninstall.sh --purge   # 메모리·학습 로그까지 전부 제거 (복구 불가)
```

---

## 🙏 미리 안내드리고 싶은 것

제가 혼자 쓰려고 만든 걸 공개한 거라 몇 가지 양해 부탁드려요:

- **이슈/PR 응답이 느릴 수 있어요** — 시간 날 때 확인합니다. 급하시면 fork 권장드려요!
- **Breaking change 있을 수 있어요** — 개인 워크플로우 따라 변경되니 업데이트 전에 변경 내역 확인 부탁드립니다
- **Windows는 WSL이나 Git Bash 거쳐서 써주세요** — 직접 테스트 못 해봐서 완전 native 지원은 나중 버전에서 생각 중이에요. 혹시 Windows에서 안 되는 게 있으면 Issues에 스크린샷 공유해주세요 🙏
- **커스텀 기능 요청은 어려울 수 있어요** — 대신 fork해서 만드시면 Issues에 공유해주세요. 다른 분들께도 도움 되니까요 🙌

---

## 🎁 만든 사람

[DAYLAB](https://daylab.dev) — Claude Code로 1인 다수 프로덕트를 만드는 스튜디오.

원래 혼자 쓰려고 만든 거 공개합니다. 쓰시다가 좋으시면 스타 ⭐ 하나 남겨주시면 감사하겠습니다!

---

## 📜 라이선스

[MIT](./LICENSE) — 자유롭게 가져다 쓰세요. 상업적 이용도 OK입니다.
