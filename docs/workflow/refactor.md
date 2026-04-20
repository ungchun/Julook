---
참조:
  - docs/tdd/cycle.md
  - docs/tdd/phases.md
  - docs/testing/writing.md
피참조:
  - AGENTS.md
검증:
  - Projects/Feature/Scene/Home/Tests/HomeCoreTests.swift
  - Projects/Feature/Scene/Home/Tests/InformationCoreTests.swift
---

# 리팩토링

**기능을 바꾸지 않는 변경.** 테스트가 "안 바뀜"을 증명한다.

## 진입 조건

- [ ] 리팩토링 대상 범위의 테스트가 있는가?
- [ ] 없다면 먼저 "현재 동작을 고정하는" 테스트 (characterization test) 추가. 이것이 이번 Phase 1.

테스트 없는 코드를 바로 리팩토링하면 의도치 않은 동작 변경을 감지할 수 없다.

## 사이클

1. **커버리지 확보**: 현재 동작을 잡는 테스트 추가 → 전체 green 확인.
2. **Refactor**: 한 번에 한 가지 변경.
3. **GREEN**: 전체 테스트 재실행. 깨지면 즉시 되돌림.
4. 1~3 반복.

## 허용되는 변경

- 이름 변경 (Xcode `Refactor → Rename` 사용 권장)
- 메서드 추출/인라인
- 타입 이동 (파일/모듈 간)
- 중복 제거
- 접근 제어자 축소 (`public` → `fileprivate` 등)

## 허용되지 않는 변경

- 동작 변경 (조건 분기 추가/삭제)
- API 의미 변경 (파라미터 순서 교체는 OK지만 새 파라미터 추가는 feature)
- 새 의존성 주입

둘이 섞이면 커밋을 분리한다: 먼저 리팩토링 커밋, 그 위에 feature 커밋.

## 커밋

`♻️ [refactor] ...` ([../git/commit.md](../git/commit.md))
