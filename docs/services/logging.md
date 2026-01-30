# Logging

디버그 로깅:

```swift
// 일반 디버그 로그
Log.debug("Debug message")

// 네트워크 로그
Log.network("API response", response)

// 에러 로그
Log.error(error)

// 커스텀 로그
Log.custom(category: "CustomCategory", "Custom message")
```
