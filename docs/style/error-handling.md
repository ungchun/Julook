# 에러 처리

커스텀 에러 타입 사용:

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
