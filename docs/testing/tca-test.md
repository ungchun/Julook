---
참조:
  - docs/coding/tca.md
  - docs/services/supabase.md
피참조:
  - AGENTS.md
  - docs/workflow/feature.md
  - docs/testing/writing.md
검증:
  - Projects/App/Tests/JulookTests.swift
---

# TCA TestStore

Reducer의 Action 흐름과 State 전이를 **독립적으로** 검증.

## 기본 형태

```swift
@Test
func testFetchData() async {
  let store = TestStore(initialState: HomeCore.State()) {
    HomeCore()
  } withDependencies: {
    $0.supabaseClient.fetchNewReleases = { mockData }
  }

  await store.send(.onAppear) {
    $0.isLoading = true
  }

  await store.receive(.fetchResponse(.success(mockData))) {
    $0.isLoading = false
    $0.items = mockData
  }
}
```

## 핵심 원칙

1. **State 전이를 명시적으로 작성**: `$0.isLoading = true` 를 안 쓰면 TestStore가 실패.
   - **왜**: 의도하지 않은 상태 변화를 강제로 드러낸다.
2. **모든 Effect를 받는다**: `.receive`로 기대 액션을 모두 소비. 남은 Effect가 있으면 테스트 실패.
3. **Dependency는 반드시 치환**: 실제 네트워크/DB를 건드리지 않는다.

## 실패 경로도 테스트한다

```swift
$0.supabaseClient.fetchNewReleases = { throw TestError.mock }

await store.send(.onAppear) { $0.isLoading = true }
await store.receive(.fetchResponse(.failure(TestError.mock))) {
  $0.isLoading = false
}
```

**왜 실패도 테스트하는가**: 해피 패스만 테스트하면 에러 처리 로직은 검증되지 않는다. 실제 유저가 겪는 경로의 절반은 실패.

## 비동기 Effect 타이밍

```swift
let clock = TestClock()
let store = TestStore(...) {
  $0.continuousClock = clock
}

await store.send(.startTimer)
await clock.advance(by: .seconds(1))
await store.receive(.tick)
```

`TestClock`으로 시간을 제어. 실제 `Task.sleep`을 쓰면 테스트가 느려지고 불안정해진다.

## 참조

- [writing](./writing.md) — 테스트 파일/메서드 네이밍
- [verification](./verification.md) — 작성된 테스트의 재검증
