---
name: julook-verification
description: Julook의 빌드/테스트 검증과 pre-push 차단 항목을 사전 점검하는 스킬. tuist generate + xcodebuild test 실행, main 푸시/Secrets 유출/print 사용/라인 제한/테스트 동반 여부 체크를 자동화한다. Phase 4 재검증, Phase 5 커밋 준비, 푸시 직전 점검에 반드시 이 스킬을 사용할 것.
---

# Julook Verification

Julook의 빌드·테스트·pre-push 규칙 전수 점검. 커밋/푸시 전 이 스킬로 모든 차단 항목을 사전 확인하여 실제 `git push`에서 막히지 않게 한다.

## 언제 이 스킬을 사용하는가

- Phase 4 (GREEN 재검증) — 리팩토링 후 전체 테스트 통과 확인
- Phase 5 (리뷰 & 커밋) — pre-push 항목 전수 체크
- 커밋 직전, 푸시 직전 최종 점검
- CI 실패 원인 추적 (로컬에서 동일 항목 재현)

## pre-push 차단 항목 (통과 못 하면 푸시 자체가 막힘)

| # | 항목 | 점검 방법 |
|---|------|-----------|
| 1 | main 직접 푸시 금지 | `git rev-parse --abbrev-ref HEAD` — `main`이면 중단 |
| 2 | Secrets 유출 방지 | `Secrets.xcconfig`, `.env`, `GoogleService-Info.plist` staged 여부 + `API_KEY=` 리터럴 grep |
| 3 | `print(` 직접 사용 금지 | `Projects/**/Sources/` 내 `print(` grep → `Log.debug` 로 대체 |
| 4 | 라인 제한 | 파일 400줄 / 함수 50줄 / 타입 300줄 초과 |
| 5 | 프로덕션 변경 시 테스트 동반 | `Projects/**/Sources/` or `supabase/functions/` 변경 있는데 `**/Tests/**` 변경 0건이면 차단 |
| 6 | 빌드 + 전체 테스트 통과 | `tuist generate && xcodebuild test` |

## 경고 항목 (차단은 안 하지만 기록)

| # | 항목 |
|---|------|
| 7 | 커밋 메시지 형식 (`{이모지} [{type}] {요약}`) 불일치 |
| 8 | WIP/임시 커밋 (`WIP`, `fixme`, `임시`, `asdf`) |
| 10 | SwiftLint 위반 (설치된 경우) |

## 실행 순서 (수동 점검)

### 1. 브랜치 확인
```bash
git rev-parse --abbrev-ref HEAD
# main이면 즉시 중단, feature/* 또는 develop이어야 함
```

### 2. Secrets 점검
```bash
git status --porcelain | grep -E 'Secrets\.xcconfig|\.env|GoogleService-Info\.plist'
# 결과가 있으면 diff 검토. 커밋에 포함시키지 말 것
```

### 3. print 사용 점검
```bash
# 스테이징된 파일에서 print 검색
git diff --cached --name-only | grep -E 'Projects/.+/Sources/.+\.swift$' | \
  xargs grep -n 'print(' 2>/dev/null
```
발견 시 `Log.debug/.info/.error`로 대체 (`docs/services/logging.md`).

### 4. 라인 제한 점검
```bash
# 변경 파일 중 400줄 초과 찾기
git diff --cached --name-only | grep '\.swift$' | while read f; do
  lines=$(wc -l < "$f")
  [ "$lines" -gt 400 ] && echo "$f: $lines lines"
done
```
초과 파일은 `docs/coding/style.md` 지침대로 분리.

### 5. 테스트 동반 확인
```bash
src_changed=$(git diff --cached --name-only | grep -E 'Projects/.+/Sources/|supabase/functions/' | wc -l)
tests_changed=$(git diff --cached --name-only | grep -E 'Tests/' | wc -l)
echo "Sources: $src_changed, Tests: $tests_changed"
# Sources 변경이 있는데 Tests 변경 0건이면 차단 대상
```

### 6. 빌드 + 테스트
```bash
mise exec -- tuist generate
xcodebuild test \
  -workspace Julook.xcworkspace \
  -scheme Julook \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Phase 4 (GREEN 재검증) 전용 체크

리팩토링 직후 실행. 각 리팩토링 단위마다 이 검증을 돌린다 (전체 완성 후 몰아서 하지 않음):

- [ ] `tuist generate` 성공
- [ ] `xcodebuild test` 전체 녹색
- [ ] 회귀 0건 (실패 테스트 리스트가 비어있음)
- [ ] 경계면 shape 일치 (State ↔ View, Action ↔ send 호출, Dependency ↔ DependencyKey 등록)

실패 시: 방금 리팩토링을 `git restore`로 되돌리고 Phase 3을 더 작게 쪼개 재시도.

## Phase 5 (커밋 전) 전용 체크

- [ ] 위 1~6 전수 통과
- [ ] 커밋 메시지 형식: `{이모지} [{type}] {요약}` (`docs/git/commit.md`)
- [ ] 한 커밋 = 한 사이클 (Phase 1+2+3+4를 한 커밋에)
- [ ] 리팩토링과 기능 추가는 분리 커밋 (refactor 먼저, feat 나중)

## 비상 우회 (지양)

정말 불가피할 때만 사용자 명시 승인 하에:
```bash
SKIP_ALL=1 git push            # 모든 체크 스킵
SKIP_BUILD_TESTS=1 git push    # 빌드/테스트만 스킵
```

우회 시 즉시 후속 커밋에 해결 + 커밋 메시지에 이유 명시.

**왜 지양하는가**: pre-push는 TDD 강제의 마지막 방어선. 우회가 습관이 되면 CI 실패 폭탄이 쌓인다.

## 참조 (프로젝트 문서)

- 푸시 차단 규칙: `docs/git/push-check.md`
- 커밋 규칙: `docs/git/commit.md`
- 자가 강제: `docs/tdd/enforcement.md`
- 로깅: `docs/services/logging.md`
- 스타일/라인 제한: `docs/coding/style.md`
