# TCA 패턴

모든 화면은 TCA 패턴을 따릅니다:

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
