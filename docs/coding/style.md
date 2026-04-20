---
참조: []
피참조:
  - AGENTS.md
  - docs/workflow/feature.md
  - docs/coding/tca.md
  - docs/git/push-check.md
검증:
  - .swiftlint.yml
  - scripts/pre-push.sh
---

# 스타일 가이드

## 길이 제한

| 대상 | 제한 | 예외 |
|------|------|------|
| 함수/메서드 | **50줄** | SwiftUI `body` — 대신 subview 또는 extension 헬퍼로 추출 |
| struct / class / enum | **300줄** | Reducer — State/Action이 커지면 `Scope`로 하위 Reducer 분리 |
| 파일 | **400줄** | 자동 생성 파일 (`DesignSystemAsset.swift` 등) |

**왜 이 수치인가**:
- **50줄**: 한 화면 스크롤 안에 들어오는 크기. 머릿속에 통째로 들고 다닐 수 있는 한계.
- **300줄**: 그 이상이면 관심사가 둘 이상으로 쪼개졌다는 신호 — 타입 분할 시점.
- **400줄**: MARK 구획이 아니라 **파일 분리**로 해결해야 할 크기.

**위반 대응**:
- 우선 추출 (Extract Function / Extract Type) 시도.
- 정당한 이유가 있으면 그 이유를 파일 상단 주석에 남긴다 (`// 길이 제한 예외: ...`).
- 푸시 단계에서 자동 차단됨 — [../git/push-check.md](../git/push-check.md).

## 접근 제어

- `public`: 모듈 간 공유
- `fileprivate`: 같은 파일 내 타입 사이
- `private`: 같은 scope 내

기본은 가장 좁은 범위. 필요할 때만 넓힌다.

## MARK 주석

파일 내 섹션 구분.

```swift
// MARK: - HeaderView

private struct HeaderView: View {
  // ...
}

// MARK: - Extensions

private extension NewReleasesView {
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    // ...
  }
}
```

**왜**: Xcode jump bar에서 내비게이션. 한 파일이 커지면 MARK로 구역을 나눠 가독성 유지.

## Extension으로 헬퍼 분리

View의 헬퍼 메서드는 `private extension`으로.

```swift
private extension HomeView {
  func makeImageView(for phase: AsyncImagePhase) -> some View { ... }
  func getScoreImage(for score: Int?) -> Image { ... }
}
```

**왜**: body가 선언형으로 읽히게 유지. 계산 로직은 extension으로 밀어낸다.

## 네이밍

- 타입: `UpperCamelCase`
- 함수/변수: `lowerCamelCase`
- Action case: 사용자 의도 기반 (`itemTapped`, `filterApplied`) — 기계 동작 이름(`didClickButton`)이 아니라 **무슨 일이 일어났는지**.

## 주석

기본적으로 **달지 않는다**. 이름이 잘 지어졌다면 코드가 곧 설명.

달아야 하는 경우:
- 왜 이 이상한 구현인가 (우회/워크어라운드)
- 드러나지 않은 제약 (`// Supabase RLS가 이 쿼리를 요구함`)
- 미래에 놀랄 동작 (`// 500ms 지연은 애니메이션 끝나기를 기다림`)

"무엇을 하는지"는 쓰지 않는다.
