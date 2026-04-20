---
참조:
  - docs/coding/tca.md
피참조:
  - AGENTS.md
  - docs/architecture/data-flow.md
검증: []
---

# SwiftData (로컬 저장)

찜한 막걸리 등 로컬 데이터를 저장하며 **iCloud로 자동 동기화**된다.

## 사용

```swift
@Dependency(\.myMakgeolliClient) var myMakgeolliClient

// 찜하기 토글
await myMakgeolliClient.toggleFavorite(makgeolli)

// 찜 상태 확인
let isFavorite = try await myMakgeolliClient.isFavorite(id)

// 내 막걸리 전체
let favorites = try await myMakgeolliClient.getAllMyMakgeollis()
```

## iCloud 동기화

- iCloud 로그인 상태 필요.
- CloudKit 권한 필요.
- 첫 동기화는 수 초 걸릴 수 있음.

동기화 문제는 [../troubleshooting/common.md](../troubleshooting/common.md).

## 테스트에서 치환

```swift
withDependencies: {
  $0.myMakgeolliClient.isFavorite = { _ in true }
}
```

## 주의

- SwiftData 모델 (`@Model`)은 main actor 바인딩되므로 Reducer에서 직접 쓰지 않고 Client 레이어를 통해 접근한다.
- 스키마 변경 시 migration 필요 — iCloud 유저 데이터 손실 위험. 반드시 [Phase 1 테스트](../tdd/phases.md)로 마이그레이션 경로 검증.
