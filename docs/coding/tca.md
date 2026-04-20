---
참조: []
피참조:
  - AGENTS.md
  - docs/workflow/feature.md
  - docs/architecture/data-flow.md
검증: []
---

# TCA 패턴

모든 화면은 TCA(The Composable Architecture) 패턴을 따른다.

## Reducer 기본 형태

```swift
@Reducer
public struct HomeCore {
  @ObservableState
  public struct State: Equatable {
    public var isLoading: Bool = false
    public var items: [Item] = []
  }

  public enum Action {
    case onAppear
    case itemTapped(Item)
    case fetchResponse(TaskResult<[Item]>)
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none
      }
    }
  }
}
```

## 비동기 처리

TCA Effect만 사용. Task에서 바로 View 상태를 만지면 안 된다.

```swift
case .fetchData:
  return .run { [client = self.supabaseClient] send in
    do {
      let data = try await client.fetchData()
      await send(.fetchResponse(.success(data)))
    } catch {
      await send(.fetchResponse(.failure(error)))
    }
  }
```

## 의존성 주입

서비스는 **반드시** `@Dependency`로 주입한다.

```swift
@Dependency(\.supabaseClient) var supabaseClient
@Dependency(\.myMakgeolliClient) var myMakgeolliClient
```

**왜**: TestStore에서 의존성을 치환해 Reducer 로직만 독립적으로 테스트하기 위해. 싱글턴 직접 호출은 테스트를 불가능하게 만든다 ([../testing/tca-test.md](../testing/tca-test.md)).

## 하위 Reducer 컴포지션

```swift
public var body: some Reducer<State, Action> {
  Scope(state: \.filter, action: \.filter) { FilterCore() }
  Reduce { state, action in ... }
}
```

## 참조

- [models](./models.md) — State/Action에 들어가는 모델
- [errors](./errors.md) — Effect 실패 처리
- [style](./style.md) — MARK, Extension, 네이밍
