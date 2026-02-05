# 서비스

모든 서비스는 TCA Dependency로 주입된다.

## Supabase

데이터베이스 및 스토리지 접근:

```swift
@Dependency(\.supabaseClient) var supabaseClient

// 데이터 가져오기
let makgeollis = try await supabaseClient.fetchNewReleases()

// 이미지 URL 가져오기
let url = try await supabaseClient.getPublicURL(Bucket.MAKGEOLLIIMAGE, fileName)

// 검색
let results = try await supabaseClient.searchMakgeollis(query)
```

## SwiftData

로컬 데이터 저장 (iCloud 동기화):

```swift
@Dependency(\.myMakgeolliClient) var myMakgeolliClient

// 찜하기
await myMakgeolliClient.toggleFavorite(makgeolli)

// 찜 상태 확인
let isFavorite = try await myMakgeolliClient.isFavorite(id)

// 내 막걸리 가져오기
let favorites = try await myMakgeolliClient.getAllMyMakgeollis()
```

## Analytics (Amplitude)

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

## Logging

디버그 로깅:

```swift
Log.debug("Debug message")
Log.network("API response", response)
Log.error(error)
Log.custom(category: "CustomCategory", "Custom message")
```
