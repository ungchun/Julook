# Analytics (Amplitude)

사용자 행동 추적:

```swift
// 이벤트 추적
Amp.track(event: "filter_type_clicked", properties: [
  "filter_type": filterType.description
])

// 화면 조회 추적
Amp.track(event: "screen_viewed", properties: [
  "screen_name": "Home"
])
```
