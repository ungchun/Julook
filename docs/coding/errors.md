---
참조: []
피참조:
  - AGENTS.md
  - docs/coding/tca.md
검증:
  - Projects/Core/Tests/SupabaseClientErrorTests.swift
---

# 에러 처리

## 커스텀 에러 타입

기능별로 `JulookError`를 준수하는 에러 타입을 정의한다.

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

**왜 커스텀 타입인가**:
- 에러 경로별로 구분 가능 (Analytics/Crashlytics에 코드 값으로 필터링).
- `underlying`에 원본 에러를 보존 → 디버깅 시 체인 추적.
- `userInfo`로 부가 컨텍스트 (어느 막걸리 id에서 터졌는지 등).

## Effect에서의 실패 처리

```swift
case .fetchData:
  return .run { send in
    do {
      let data = try await client.fetchData()
      await send(.fetchResponse(.success(data)))
    } catch {
      await send(.fetchResponse(.failure(error)))
    }
  }

case .fetchResponse(.failure(let error)):
  Log.error(error)
  state.isLoading = false
  return .none
```

`.failure` 액션의 Reducer 처리에서:
1. 로깅 ([../services/logging.md](../services/logging.md))
2. 필요 시 Analytics 이벤트 ([../services/analytics.md](../services/analytics.md))
3. UI 상태 복구

## 금지

- `try?`로 에러를 삼키고 `nil` 넘기기 (원인 유실).
- `fatalError`/`preconditionFailure`를 사용자 경로에서 사용.
- 에러를 `print`로만 처리 (프로덕션에서 사라짐).
