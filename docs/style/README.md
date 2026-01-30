# 코딩 스타일

## 세부 문서
- [비동기 처리](./async.md) - TCA Effect 패턴
- [에러 처리](./error-handling.md) - 커스텀 에러 타입

## 주석
- 주석은 **한국어**로 작성
- 모델 프로퍼티에는 문서화 주석 사용

```swift
/// 막걸리 이름
public let name: String
/// 단맛 정도 (0-5)
public let sweetness: Int?
```

## Extension 활용
View의 헬퍼 메서드는 extension으로 분리:

```swift
private extension HomeView {
  func makeImageView(for phase: AsyncImagePhase) -> some View { ... }
  func getScoreImage(for score: Int?) -> Image { ... }
}
```
