---
참조:
  - docs/tdd/cycle.md
  - docs/tdd/enforcement.md
  - docs/testing/tca-test.md
피참조:
  - AGENTS.md
  - docs/workflow/feature.md
  - docs/workflow/refactor.md
  - docs/workflow/bugfix.md
검증:
  - Projects/App/Tests/JulookTests.swift
---

# 테스트 작성법

## 현 상태 (2026-04-20)

- `Projects/App/Tests/JulookTests.swift`: placeholder 1개 (`2+2 == 4`).
- Core / Feature / DesignSystem: **Tests 타깃 없음**.

TDD 작업을 시작하려면 먼저 타깃을 만든다.

## 테스트 타깃 신설

1. `Projects/{Module}/Tests/` 디렉터리 생성.
2. `Project.swift`의 `targets` 배열에 `.target(name: "{Module}Tests", product: .unitTests, ...)` 추가.
3. `tuist generate` 실행.
4. 첫 테스트는 "모듈이 import되는지" 수준의 최소 테스트로 컴파일 확인.

```swift
import XCTest
@testable import Core

final class CoreImportTests: XCTestCase {
  func test_canImportCore() {
    XCTAssertTrue(true)
  }
}
```

이 첫 테스트는 추후 의미 있는 테스트로 **교체**한다. 남겨두지 않는다.

## 테스트 파일 네이밍

| 대상 | 파일 |
|------|------|
| Reducer | `{Feature}CoreTests.swift` |
| Client | `{Name}ClientTests.swift` |
| Model | `{ModelName}Tests.swift` |

## 메서드 네이밍

`test_{상황}_{기대결과}` 형식.

```swift
func test_whenOnAppearCalled_shouldSetIsLoadingTrue() { ... }
func test_whenFetchFails_shouldLogError() { ... }
```

**왜**: 실패 로그에 의도가 그대로 드러난다. 디버깅 속도가 달라진다.

## Phase 1 (RED) 실패 테스트의 조건

- 프로덕션 코드를 **건드리지 않고** 먼저 쓴다.
- 실제로 실패함을 눈으로 확인한다. 처음부터 통과하면 의미 없다.
- 실패 메시지만 봐도 "무엇을 검증하려 했는지" 읽힌다.

## TCA 테스트 구체 작성

TestStore 사용법은 [tca-test](./tca-test.md).

## 교차 검증

작성한 테스트가 정말 옳은지는 [verification](./verification.md) 절차로 확인한다.
