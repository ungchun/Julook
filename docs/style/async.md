# 비동기 처리

TCA의 Effect를 사용하여 비동기 작업 처리:

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
