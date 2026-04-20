---
참조:
  - docs/tdd/cycle.md
  - docs/tdd/phases.md
피참조:
  - AGENTS.md
검증: []
---

# 자가 강제 규칙

## 핵심 한 줄

**실패하는 테스트 없이 프로덕션 코드 수정 금지.**

"프로덕션 코드" = `Projects/**/Sources/**` 와 `supabase/functions/**`. 테스트/문서/리소스/설정은 제외.

## 실행 전 자가 점검

`Edit` 또는 `Write`로 프로덕션 코드 파일을 수정하기 **직전에** 스스로에게 묻는다:

1. 이 변경이 실패시키고 있는 테스트가 **지금 이 순간에** 있는가?
2. 없다면 즉시 Phase 1로 돌아가 테스트부터 쓴다.
3. 있다면 "어느 테스트인지" 한 문장으로 답할 수 있어야 한다.

답이 막히면 작업을 멈추고 사용자에게 보고한다:

> "Phase 1 테스트 없이 Phase 2로 진입하려 했습니다. 무엇을 검증하는 테스트를 먼저 쓸까요?"

## 기존 테스트 부재 정책 (현재 프로젝트)

현 상태: `Projects/App/Tests/JulookTests.swift` 하나 (placeholder). TCA TestStore 테스트 0개.

이 상태에서의 규칙 (**"건드린 파일만"** 의무):

- **건드리는 파일에는 최소 1개의 의미 있는 테스트**를 함께 추가한다 (경계/실패 사례 하나).
- 기존 코드 전체를 소급해서 덮지 않는다. 이번 범위만.
- 테스트 타깃이 없는 모듈 (Core / Feature / DesignSystem)은 [../testing/writing.md](../testing/writing.md) 참고해 타깃부터 생성.

## 예외

테스트 없이 수정 가능:

- 리소스 파일 (`.xcassets`, `Localizable.strings`)
- 설정 (`.xcconfig`, `Info.plist`) — 단, 동작이 바뀌면 통합 테스트 필요
- 문서 (`.md`)
- 순수 타이포/주석

의심스러우면 테스트를 쓴다.

## 위반이 잡혔을 때

사용자가 "왜 테스트 없이 고쳤냐" 지적 시:
1. 변명하지 말고 상황 인정.
2. 되돌릴지 (`git restore`) 지금 테스트 추가할지 사용자에게 물어봄.
3. 재발 방지를 위해 `feedback` 메모리에 기록.

## 자동화된 방어선

- **pre-push 훅 (현재 운영)**: [../git/push-check.md](../git/push-check.md) — 프로덕션 변경인데 `Tests/` 변경 0건이면 푸시 자체가 막힌다.
- **`.claude/settings.json` + `PreToolUse` 훅 (TODO)**: `Edit`/`Write` 단계에서 실패 테스트 존재 여부 사전 검증.
- **교차 검증 슬래시 커맨드 (TODO)**: [../testing/verification.md](../testing/verification.md)의 절차를 `/verify-tests`로 자동화.
- **문서 "컴파일" (TODO)**: 각 문서 `검증:` 필드를 실제 테스트 경로와 연결하고 CI에서 참조 무결성 검사.
