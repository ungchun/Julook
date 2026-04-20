---
참조:
  - docs/database/schema.md
피참조:
  - AGENTS.md
  - docs/coding/tca.md
  - docs/workflow/feature.md
검증:
  - Projects/Core/Tests/MakgeolliTests.swift
  - Projects/Core/Tests/AwardTests.swift
  - Projects/Core/Tests/UserCommentTests.swift
  - Projects/Core/Tests/MakgeolliReactionTests.swift
  - Projects/Core/Tests/MyMakgeolliEntityTests.swift
---

# 데이터 모델

## 프로토콜 준수

모든 모델은 `Codable, Identifiable, Equatable, Sendable`을 준수한다.

```swift
public struct Makgeolli: Codable, Identifiable, Equatable, Sendable {
  public let id: UUID
  public let name: String
  public let brewery: String?
}
```

**왜**:
- `Codable`: Supabase JSON ↔ Swift 변환.
- `Identifiable`: SwiftUI ForEach 식별.
- `Equatable`: TCA State 비교에 필수 (불필요한 재렌더 방지).
- `Sendable`: Swift 6 동시성 안전성.

## 필드는 `let`

모든 필드는 기본 `let`. `var`는 예외적 (TCA State 내부 변경 값 등).

**왜**: 모델은 "값". 공유 변경을 방지하면 데이터 레이스 / 의도치 않은 상태 변화를 차단할 수 있다.

## CodingKeys 매핑

DB `snake_case` → Swift `camelCase`.

```swift
enum CodingKeys: String, CodingKey {
  case id
  case name
  case hasAspartame = "has_aspartame"
  case alcoholPercentage = "alcohol_percentage"
}
```

Supabase 컬럼명 전체는 [../database/schema.md](../database/schema.md).

## 파일 네이밍

| 종류 | 패턴 | 예시 |
|------|------|------|
| Reducer | `{Feature}Core.swift` | `HomeCore.swift` |
| View | `{Feature}View.swift` | `HomeView.swift` |
| Model | `{ModelName}.swift` | `Makgeolli.swift` |

Model은 `Projects/Core/Sources/Model/` 아래에.
