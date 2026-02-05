# 코딩

## TCA 패턴

모든 화면은 TCA(The Composable Architecture) 패턴을 따른다.

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

### 비동기 처리

TCA Effect를 사용한다.

```swift
case .fetchData:
  let supabaseClient = self.supabaseClient
  return .run { send in
    do {
      let data = try await supabaseClient.fetchData()
      await send(.fetchResponse(.success(data)))
    } catch {
      await send(.fetchResponse(.failure(error)))
    }
  }
```

## 데이터 모델

모든 모델은 `Codable, Identifiable, Equatable, Sendable`을 준수한다.

```swift
public struct Makgeolli: Codable, Identifiable, Equatable, Sendable {
  public let id: UUID
  public let name: String

  // DB snake_case → Swift camelCase 매핑
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case hasAspartame = "has_aspartame"
    case alcoholPercentage = "alcohol_percentage"
  }
}
```

## 에러 처리

커스텀 에러 타입을 사용한다.

```swift
public struct HomeCoreError: JulookError, @unchecked Sendable {
  public var userInfo: [String: Any] = [:]
  public var code: Code
  public var underlying: Error?

  public enum Code: Int, Sendable {
    case failToFetchData
    case failToFetchImage
  }
}
```

## 파일 네이밍

| 종류 | 패턴 | 예시 |
|------|------|------|
| Reducer | `{Feature}Core.swift` | `HomeCore.swift` |
| View | `{Feature}View.swift` | `HomeView.swift` |
| Model | `{ModelName}.swift` | `Makgeolli.swift` |

## 접근 제어

- `public`: 모듈 간 공유
- `fileprivate`: 같은 파일 내
- `private`: 같은 scope 내

## MARK 주석

파일 내 섹션을 구분한다.

```swift
// MARK: - HeaderView

private struct HeaderView: View {
  // ...
}

// MARK: - Extensions

private extension NewReleasesView {
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    // ...
  }
}
```

## Extension 활용

View의 헬퍼 메서드는 extension으로 분리한다.

```swift
private extension HomeView {
  func makeImageView(for phase: AsyncImagePhase) -> some View { ... }
  func getScoreImage(for score: Int?) -> Image { ... }
}
```
