# SwiftData Client

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
