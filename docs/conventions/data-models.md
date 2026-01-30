# 데이터 모델 규칙

모든 모델은 `Codable, Identifiable, Equatable, Sendable`을 준수합니다:

```swift
public struct Makgeolli: Codable, Identifiable, Equatable, Sendable {
  public let id: UUID
  public let name: String

  // DB의 snake_case → Swift camelCase 매핑
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case hasAspartame = "has_aspartame"
    case alcoholPercentage = "alcohol_percentage"
  }
}
```
