---
name: tca-reducer-design
description: TCA Reducer의 State/Action/Effect를 설계하고 구현하는 스킬. 새 Reducer 작성, 기존 Reducer에 Action 추가, Effect 정의, Dependency 주입, Scope 컴포지션 등 Julook의 모든 TCA 코드 작업에 반드시 사용할 것. `@Reducer`, `@ObservableState`, `@Dependency`, `Scope`, `TestStore` 관련 질문과 구현 모두 이 스킬로 처리한다.
---

# TCA Reducer Design

Julook에서 모든 화면은 TCA(The Composable Architecture) 패턴을 따른다. 이 스킬은 State/Action/Effect 설계와 구현의 원칙을 담는다.

## 언제 이 스킬을 사용하는가

- 신규 Reducer 작성
- 기존 Reducer에 Action/State 추가
- Effect(비동기) 정의
- 하위 Reducer 컴포지션 (`Scope`)
- 의존성(`@Dependency`) 식별 및 주입
- 모델 설계 (`State` 내부 필드의 타입/기본값)

## Reducer 기본 형태

```swift
import ComposableArchitecture

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

  @Dependency(\.supabaseClient) var supabaseClient

  public init() {}

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isLoading = true
        return .run { send in
          await send(.fetchResponse(TaskResult { try await supabaseClient.fetchNewReleases() }))
        }

      case .itemTapped:
        return .none

      case let .fetchResponse(.success(items)):
        state.isLoading = false
        state.items = items
        return .none

      case .fetchResponse(.failure):
        state.isLoading = false
        return .none
      }
    }
  }
}
```

## 핵심 규칙 (왜 그런지 포함)

### 1. State의 필드는 두 부류

- **불변 데이터**: 도메인 모델은 `let` 필드만 가진다 (`docs/coding/models.md`).
- **화면 상태**: State 내부 `var` 필드는 화면 전이를 위해 허용.

**왜**: 도메인 모델에 `var`를 허용하면 Reducer 밖에서 변경될 가능성이 생기고, TCA의 단일 변경 지점 원칙이 깨진다.

### 2. Action은 "사용자가 본 이벤트" + "시스템 응답"

- 사용자 이벤트: `.onAppear`, `.{name}Tapped`, `.{name}TextChanged`
- 시스템 응답: `.{name}Response(TaskResult<T>)`

**왜**: Action 이름이 UI/시스템 관점에서 읽히면 TestStore 시나리오가 "사용자가 X 하고 Y 응답이 오면..."의 자연어로 그대로 옮겨진다.

### 3. Effect는 `.run` 만 사용, Task에서 직접 State 금지

```swift
// GOOD
return .run { [client = self.supabaseClient] send in
  do {
    let data = try await client.fetchData()
    await send(.fetchResponse(.success(data)))
  } catch {
    await send(.fetchResponse(.failure(error)))
  }
}

// BAD — Task 안에서 state 직접 변경
return .run { send in
  state.items = await client.fetchData() // ❌ state 캡처 금지
}
```

**왜**: `state`는 Reducer의 `Reduce` 클로저 안에서만 변경 가능해야 한다. Effect에서 State를 만지면 TestStore가 전이를 추적할 수 없다.

### 4. 의존성은 반드시 `@Dependency`로 주입

```swift
// GOOD
@Dependency(\.supabaseClient) var supabaseClient
@Dependency(\.myMakgeolliClient) var myMakgeolliClient
@Dependency(\.swiftDataClient) var swiftDataClient

// BAD
let client = SupabaseClient.shared // ❌ TestStore에서 치환 불가
```

**왜**: TestStore에서 `withDependencies { $0.supabaseClient.fetchNewReleases = { mockData } }`로 치환해야 Reducer 로직만 독립 검증 가능. 싱글턴 직접 호출은 테스트를 불가능하게 만든다.

### 5. 하위 Reducer 컴포지션은 `Scope`

```swift
public var body: some Reducer<State, Action> {
  Scope(state: \.filter, action: \.filter) { FilterCore() }
  Scope(state: \.commentList, action: \.commentList) { CommentListCore() }
  Reduce { state, action in
    switch action {
    case .filter(.applyTapped):
      return .run { ... }
    case .commentList:
      return .none
    // ...
    }
  }
}
```

**왜**: 하위 Reducer가 자기 도메인만 책임지면 테스트와 재사용이 쉬워진다. `State`에 하위 State를 embed하고 Action에 `case filter(FilterCore.Action)` 형태로 감싼다.

## 새 Scene 추가 체크리스트

1. `Projects/Feature/Scene/{Name}/Sources/{Name}Core.swift` — Reducer
2. `Projects/Feature/Scene/{Name}/Sources/{Name}View.swift` — View
3. `Projects/Feature/Scene/{Name}/Project.swift` — 타깃 등록 (또는 상위 `Scene/Project.swift`)
4. `Projects/Feature/Scene/{Name}/Tests/{Name}CoreTests.swift` — 테스트 타깃
5. `MainCoordinator` — 라우트 추가
6. `tuist generate` 실행

## Action 이름 안티패턴

| BAD | GOOD | 이유 |
|-----|------|------|
| `.setItems([Item])` | `.fetchResponse(TaskResult<[Item]>)` | State setter 스타일은 외부에서 State를 조작하는 안티패턴 |
| `.load` | `.onAppear` / `.refreshTapped` | "언제 트리거되는가"가 드러나야 함 |
| `.success` / `.failure` | `.fetchResponse(TaskResult<T>)` | 어떤 작업의 응답인지 알 수 없음 |
| `.update` | `.{field}Changed({value})` | 무엇이 바뀌었는지 드러나야 함 |

## State Equatable 조건

- 모든 필드가 `Equatable` — 커스텀 모델도 `Equatable` 채택.
- 참조 타입(class) 피하기. struct + `let` 조합.
- `Date`, `UUID`, enum은 기본 Equatable.

**왜**: `TestStore`가 State 전이를 검증하려면 Equatable이 필수. 또 SwiftUI가 `@ObservableState`로 diff를 계산할 때도 Equatable에 의존.

## 에러 핸들링

상세: `docs/coding/errors.md`

- `TaskResult<T>` 래핑으로 실패 경로 명시.
- `JulookError` enum으로 도메인 에러 통일.
- View에서는 `state.errorMessage` 같은 필드로 메시지 노출, Reducer에서 Log.

## 참조 (프로젝트 문서)

- 전체 TCA 가이드: `docs/coding/tca.md`
- 모델 규칙: `docs/coding/models.md`
- 에러 처리: `docs/coding/errors.md`
- 스타일: `docs/coding/style.md`
- 데이터 흐름: `docs/architecture/data-flow.md`
