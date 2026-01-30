# Supabase Client

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
