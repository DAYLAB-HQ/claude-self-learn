# Memory-First Workflow

**애매하거나 짧은 유저 요청에 바로 되묻기 전에 반드시 메모리 먼저 확인.**

유저가 이전에 저장한 선호·맥락을 다시 설명하지 않아도 되게 강제한다.

## 검색 워크플로우 (경량)

메모리 디렉토리: `~/.claude/memory/*.md`

**검색 순서** (빠른 것부터):

1. **Glob으로 파일명 스캔**
   ```
   Glob pattern: ~/.claude/memory/*.md
   ```
   또는 타입으로 필터:
   ```
   Glob: ~/.claude/memory/feedback_*.md
   Glob: ~/.claude/memory/pattern_*.md
   ```

2. **Grep으로 본문 검색** (필요 시)
   ```
   Grep: "톤" in ~/.claude/memory/
   Grep: "네이밍|이름" in ~/.claude/memory/feedback_*.md
   ```

3. **관련 파일 Read**
   - 매칭된 파일 중 가장 관련 있어 보이는 것 1-3개 Read
   - 내용 파악 후 답변 생성

## 트리거 — 이런 요청엔 반드시 메모리 먼저

### 1. 톤·문체·카피 관련
키워드: `톤`, `카피`, `문체`, `voice`, `tone`, `writing`, `스타일`, `표현`
→ `feedback_*tone*`, `feedback_*voice*`, `feedback_oss_friendly_tone.md` 등

### 2. 네이밍·제품명
키워드: `이름`, `네이밍`, `naming`, `product name`, `브랜드`
→ `feedback_intuitive_naming.md`, `project_*`

### 3. 기술 구현 (스택 언급 시)
키워드: `expo`, `nextjs`, `prisma`, `react-native`, `vercel`, `tailwind` 등
→ `pattern_*<stack>*`, `troubleshoot_*<stack>*`, `reference_*<stack>*`

### 4. 과거 작업 참조
키워드: `지난번`, `전에`, `예전에`, `어떻게 했지`, `이전에`, `before`, `last time`
→ 주제 키워드 grep → `reference_*`, `pattern_*`

### 5. 프로덕트·사업·특정 프로젝트명
키워드: 프로젝트 슬러그 또는 비즈니스 도메인 용어
→ `project_<slug>.md`, `user_*.md`

### 6. 애매한 요청 일반
한 줄짜리, 맥락 부족한 질문 → **되묻기 전** Glob `~/.claude/memory/*.md` + 키워드 Grep
- 관련 메모리 발견 → 그 맥락으로 답 시작
- 여전히 애매 → **"기억한 맥락 기반 선택지"** 제시

## 금지 행동

- ❌ 애매한 요청에 아무 확인 없이 "어떤 X 말씀이신가요?" 되묻기
- ❌ 유저가 이전에 저장한 선호를 다시 물어보기
- ❌ MEMORY_INDEX.md 찾기 (경량 모드에서는 존재하지 않음 — Glob 사용)

## 답변 시 표시

관련 메모리 Read해서 답에 반영했으면:
```
(참조: feedback_oss_friendly_tone.md)
```
또는 여러 개면:
```
(참조: feedback_oss_friendly_tone.md, pattern_github_noreply_identity_mask.md)
```

## 예시

### ❌ 나쁨
```
유저: 톤 좀 봐줘
Claude: 어떤 톤을 봐드릴까요? 카피/이메일/UI 문구 등...
```

### ✅ 좋음
```
유저: 톤 좀 봐줘
Claude: [Glob ~/.claude/memory/feedback_*tone*.md]
       [Read feedback_oss_friendly_tone.md]
       어떤 문서의 톤을 봐드릴까요? 기억하기론 공개 문서에
       친절한 앞서 안내 스타일 선호하시고 방어적 표현 피하시는데,
       그 기준으로 체크해드릴까요? 파일 경로 주세요.
       (참조: feedback_oss_friendly_tone.md)
```

## 적용 범위

- 이 rule은 `~/.claude/rules/`에 있어서 모든 세션에 자동 로드됨
- 모든 프로젝트·모든 작업에 적용
- 실행 시점: 유저 메시지 받자마자, 첫 응답 생성 전

## 퍼포먼스

- Glob 1회 + Read 1-3개 = 매 recall당 ~500~2000 토큰
- 불필요한 grep 반복 금지 (한 번 검색으로 충분할 때)
- 동일 메모리 재주제면 이미 context에 있는지 먼저 확인
