---
참조:
  - docs/tdd/cycle.md
피참조:
  - AGENTS.md
  - docs/tdd/enforcement.md
  - docs/workflow/feature.md
  - docs/workflow/refactor.md
  - docs/workflow/bugfix.md
검증:
  - Projects/Core/Tests/
  - Projects/Feature/Scene/Home/Tests/
---

# Phase 0 ~ 5 게이트

한 작업 단위를 6개 Phase로 쪼갠다. **순서대로만** 진행한다. Phase를 건너뛰고 프로덕션 코드에 손대면 안 된다.

## Phase 0: 요구사항 확정

- 무엇을 만들/고칠지 한두 문장으로 정의.
- 검증 가능한 형태로 변환: "X 조건에서 Y 결과".
- 불명확하면 사용자에게 먼저 묻는다. 추측 금지.

**완료 조건**: "이 동작을 증명할 테스트 이름"이 머릿속에서 써진다.

## Phase 1: RED — 실패 테스트

- Phase 0 동작을 검증하는 테스트 추가.
- 전체 테스트 실행 → **새 테스트만** 실패 확인.
- 기존 테스트가 함께 실패하면 환경 문제/격리 깨짐. 먼저 해결.

**완료 조건**: 실패 로그에 새 테스트 이름이 보인다.

## Phase 2: GREEN — 최소 구현

- **처음으로** 프로덕션 코드에 손대는 단계.
- 가장 단순한 방법으로 통과시킨다. 일반화는 Phase 3에서.
- 전체 테스트 green 확인.

**완료 조건**: 전체 테스트 green.

## Phase 3: REFACTOR

- 이번 변경과 주변 코드를 정리.
- 기능 변경 금지. 이름/구조/중복만.
- 각 리팩토링마다 Phase 4로 내려가 재검증.

**완료 조건**: 더 고칠 것이 없다고 판단될 때.

## Phase 4: GREEN — 재검증

- 전체 테스트 재실행.
- 하나라도 깨지면 방금 리팩토링을 되돌리고 Phase 3을 더 작게 쪼개 다시.

## Phase 5: 리뷰 & 커밋

- 변경 파일 diff 확인.
- 커밋 메시지 규칙: [../git/commit.md](../git/commit.md).
- **한 커밋 = 한 사이클**이 이상적. 여러 사이클을 섞지 않는다.

## 진입 전 체크리스트

- [ ] Phase 0 동작 정의가 한 문장으로 말해지는가?
- [ ] 관련 테스트 타깃이 존재하는가? 없으면 먼저 생성 ([../testing/writing.md](../testing/writing.md))
- [ ] 이 작업이 어떤 워크플로인가? ([feature](../workflow/feature.md) / [refactor](../workflow/refactor.md) / [bugfix](../workflow/bugfix.md))
