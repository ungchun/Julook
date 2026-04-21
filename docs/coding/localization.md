---
참조:
  - docs/coding/style.md
  - docs/git/push-check.md
피참조:
  - CLAUDE.md
  - docs/git/push-check.md
검증:
  - scripts/check-hardcoded-korean.sh
  - scripts/tests/check_hardcoded_korean_test.sh
---

# 로컬라이제이션 규약 (Localization)

UI 표시 문자열은 전부 `Localizable.strings` → SwiftGen `L10n.*` 접근. Swift 소스의 문자열 리터럴에 한글이 박히면 **pre-push가 차단**한다. 왜: 번역 추가가 단순 `.strings` 수정으로 끝나야 하며, 소스 코드 수정이 동반되면 회귀가 누적된다.

## 키 네이밍 계층: `scene.section.element`

소문자 camelCase + 점(`.`) 구분. SwiftGen이 `.` 를 중첩 enum으로 변환하므로 계층이 그대로 타입이 된다.

| `.strings` 키 | Swift 접근 |
|---|---|
| `home.information.comment.edit` | `L10n.Home.Information.Comment.edit` |
| `home.list.empty.title` | `L10n.Home.List.Empty.title` |
| `search.results.emptyMessage` | `L10n.Search.Results.emptyMessage` |
| `common.button.confirm` | `L10n.Common.Button.confirm` |

**원칙**:
- **scene**: 상위 기능 단위 (`home`, `search`, `myMakgeolli`, `common`).
- **section**: scene 내부 영역 (`information`, `list`, `results`).
- **element**: 실제 텍스트 역할 (`title`, `description`, `confirm`).
- 공통 문자열은 `common.*` 로 올린다. 단, scene 특화 의미가 있으면 중복 정의 허용.

## 플레이스홀더 규약

iOS `String(format:)` 자리표시자만 사용. SwiftGen이 타입-세이프 함수로 생성한다.

- `%@` — 문자열 (`String`)
- `%lld` — 64비트 정수 (`Int`)
- `%.1f` — 소수점 1자리 실수 (`Double`)

순서 바뀌는 번역을 대비해 위치 인자(`%1$@`, `%2$lld`) 쓰는 걸 권장.

예: `"home.information.comment.count" = "댓글 %lld개";` → `L10n.Home.Information.Comment.count(3)`.

## ko / en 키 집합 동기화

- `Projects/Core/Resources/{ko,en}.lproj/Localizable.strings` 는 **키 집합이 1:1 동일**해야 한다. 한쪽에만 있는 키 금지.
- 영어 번역이 아직 없으면 en 파일에 **한글 원문을 그대로** 두되 키는 추가한다 (TODO로 추적).
- 새 키 추가는 ko/en 두 파일 모두에 동시 커밋.

## enum rawValue 한글 금지

UI 분기용 enum 의 `rawValue` 에 한글 쓰지 말 것. 대신 영문 식별자 + `displayName` computed property 를 둔다. 왜: `rawValue` 는 저장/네트워크 직렬화 경로에 섞이기 쉽고, 한글이 들어가면 DB·로그·URL 에서 인코딩 사고가 난다.

```swift
enum Mood: String {
    case sweet
    case sour
    case bitter

    var displayName: String {
        switch self {
        case .sweet:  return L10n.Common.Mood.sweet
        case .sour:   return L10n.Common.Mood.sour
        case .bitter: return L10n.Common.Mood.bitter
        }
    }
}
```

## `// swiftgen-ignore` 마커 (엄격)

**허용되는 유일한 용도**: 배포에 영향 없는 개발자 로그. 사용자 UI에는 절대 노출되지 않아야 한다.

```swift
Log.debug("디버그: 요청 시작 \(requestID)") // swiftgen-ignore
```

위반: View/Text/Button/Alert/Label 등 UI 컴포넌트 인자에 이 마커를 붙이는 것은 리뷰 시 반려.

## 검증

- 로컬 체크: `./scripts/check-hardcoded-korean.sh Projects` (0이어야 green).
- pre-push 훅이 자동으로 돌린다. [push-check.md](../git/push-check.md#한글-리터럴-0건) 참조.
- 테스트: `./scripts/tests/check_hardcoded_korean_test.sh`.
