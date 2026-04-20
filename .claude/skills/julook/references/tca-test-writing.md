---
name: tca-test-writing
description: TCA TestStore 기반 Reducer 테스트를 작성하는 스킬. 실패 테스트(RED) 작성, State 전이 검증, Effect 수신, Dependency 치환, TestClock으로 비동기 타이밍 제어를 다룬다. Julook에서 Reducer 로직을 테스트하거나 "실패 테스트 먼저"(TDD Phase 1) 작업을 할 때 반드시 사용할 것. XCTest/TestStore/withDependencies/TestClock 관련 작업 모두 이 스킬로 처리한다.
---

# TCA Test Writing

Julook의 모든 Reducer는 TCA TestStore로 독립 검증한다. 이 스킬은 실패 테스트 작성(Phase 1 RED)과 TestStore 사용법을 담는다.

## 언제 이 스킬을 사용하는가

- TDD Phase 1 (RED) — 프로덕션 코드 건드리기 전에 실패 테스트 쓸 때
- Reducer의 Action 흐름 / State 전이 검증
- Dependency 치환으로 실제 네트워크/DB 없이 테스트
- 비동기 Effect의 타이밍 제어 (`TestClock`)
- 기존 Reducer에 테스트 소급 추가 (건드리는 파일만)

## 핵심 원칙 (왜 그런지 포함)

### 1. 프로덕션 코드 건드리기 전에 먼저 쓴다

Phase 1의 정의. `Projects/**/Sources/**` 를 수정하기 **전에** `Tests/` 에 실패 테스트를 커밋 가능한 상태로 만든다.

**왜**: 실패하는 것을 눈으로 본 테스트만이 "무언가 잡는다"는 근거를 가진다.

### 2. 처음부터 통과하는 테스트는 잘못된 테스트다

```swift
// BAD — 이미 통과하는 assertion
func test_initialStateIsEmpty() {
  let state = HomeCore.State()
  XCTAssertTrue(state.items.isEmpty) // 기본값이 [] 이므로 항상 통과
}
```

**왜**: 이런 테스트는 프로덕션 코드가 잘못돼도 실패하지 않는다. TDD의 근거가 없다. 재작성해서 실제로 실패하게 만든다.

### 3. State 전이는 명시적으로 선언한다

```swift
await store.send(.onAppear) {
  $0.isLoading = true  // 이 라인이 없으면 TestStore가 실패
}
```

**왜**: 의도하지 않은 State 변화를 강제로 드러내기 위함. "내가 바뀔 거라고 생각한 것만" 바뀌었는지 검증.

### 4. 모든 Effect를 `.receive`로 소비한다

```swift
await store.send(.onAppear) { $0.isLoading = true }
await store.receive(.fetchResponse(.success(mockData))) {
  $0.isLoading = false
  $0.items = mockData
}
```

남은 Effect가 있으면 TestStore가 실패. **왜**: 버려진 Effect는 실제 앱에서 예상 못한 상태 변경을 일으킬 수 있다.

### 5. Dependency 치환 필수

```swift
let store = TestStore(initialState: HomeCore.State()) {
  HomeCore()
} withDependencies: {
  $0.supabaseClient.fetchNewReleases = { mockData }
  $0.continuousClock = TestClock()
}
```

**왜**: 실제 Supabase/SwiftData를 건드리면 테스트가 느려지고 불안정해진다. 또 네트워크 응답에 의존한 테스트는 오프라인에서 실패.

### 6. 실패 경로도 테스트한다

```swift
$0.supabaseClient.fetchNewReleases = { throw TestError.mock }

await store.send(.onAppear) { $0.isLoading = true }
await store.receive(.fetchResponse(.failure(TestError.mock))) {
  $0.isLoading = false
}
```

**왜**: 해피 패스만 쓰면 에러 처리 로직이 검증되지 않는다. 실제 유저가 겪는 경로의 절반은 실패. 특히 Julook의 네트워크/OCR/라벨스캔 기능은 실패 경로가 많다.

## 테스트 파일 네이밍

| 대상 | 파일 |
|------|------|
| Reducer | `{Feature}CoreTests.swift` |
| Client (의존성) | `{Name}ClientTests.swift` |
| Model | `{ModelName}Tests.swift` |

## 메서드 네이밍

`test_when{상황}_should{기대결과}` 형식.

```swift
func test_whenOnAppearCalled_shouldSetIsLoadingTrue() { ... }
func test_whenFetchFails_shouldSetIsLoadingFalseAndLogError() { ... }
func test_whenItemTapped_shouldNavigateToDetail() { ... }
```

**왜**: 실패 로그에 의도가 그대로 드러난다. `test_home_1`, `test_fetch` 같은 이름은 실패 시 "뭘 검증하려 했지?" 추적 비용이 크다.

## TestClock으로 비동기 타이밍

```swift
let clock = TestClock()
let store = TestStore(...) {
  $0.continuousClock = clock
}

await store.send(.startTimer)
await clock.advance(by: .seconds(1))
await store.receive(.tick)
```

**왜**: 실제 `Task.sleep`을 쓰면 테스트가 1초 기다린다 → N개 테스트에서 N초 낭비 + 타이밍 불안정.

## Tests 타깃 신설 (현 프로젝트 상태)

Core / DesignSystem / Feature/Scene/* 에는 Tests 타깃이 없다. 추가 절차:

1. `Projects/{Module}/Tests/` 디렉터리 생성
2. `Project.swift`의 `targets` 배열에 `.target(name: "{Module}Tests", product: .unitTests, dependencies: [.target(name: "{Module}")])` 추가
3. `tuist generate`
4. 첫 테스트는 실패 테스트 그 자체 (placeholder `XCTAssertTrue(true)` 쓰지 않는다)

상세: `docs/testing/writing.md`.

## 실패 확인 방법

```bash
tuist generate
xcodebuild test \
  -workspace Julook.xcworkspace \
  -scheme {ModuleTests} \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

실패 로그에 **새 테스트 이름**과 **예상값/실제값 diff**가 드러나야 Phase 1 완료.

## 교차 검증

Phase 4 이후 새 세션에서 테스트 파일만 읽고 의도 재추론. 누락된 경계 사례가 있으면 Phase 1부터 다시. 상세: `docs/testing/verification.md`.

## 안티패턴

| BAD | 왜 나쁜가 |
|-----|-----------|
| `XCTAssertTrue(true)` | 무의미한 placeholder — 실제 검증 0 |
| Reducer 안 private 함수 단위 테스트 | TCA는 Reducer 단위로 검증. 내부는 implementation detail |
| 실제 Supabase 호출 | 느리고 불안정. mock 필수 |
| `Task.sleep(for: .seconds(1))` | TestClock 사용 |
| State만 직접 생성해 비교 | TestStore를 거치지 않으면 Action 흐름이 검증되지 않음 |

## 참조 (프로젝트 문서)

- 테스트 작성법: `docs/testing/writing.md`
- TestStore 상세: `docs/testing/tca-test.md`
- 교차 검증: `docs/testing/verification.md`
- TCA 패턴: `docs/coding/tca.md`
