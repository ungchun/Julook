---
참조: []
피참조:
  - AGENTS.md
  - docs/architecture/data-flow.md
  - docs/coding/errors.md
검증: []
---

# Analytics (Amplitude)

사용자 행동 추적.

## 이벤트 추적

```swift
Amp.track(event: "filter_type_clicked", properties: [
  "filter_type": filterType.description
])
```

## 화면 조회

```swift
Amp.track(event: "screen_viewed", properties: [
  "screen_name": "Home"
])
```

## 이벤트 네이밍 규칙

- `snake_case`
- 사용자 의도 단어 사용: `item_clicked` (O), `did_tap_cell` (X)
- 화면 이벤트는 `screen_viewed` + `screen_name` 프로퍼티로 통일

**왜 규칙을 강제하는가**: 대시보드에서 이벤트 필터링 시 일관성 필요. 다른 네이밍 스타일이 섞이면 집계가 깨진다.

## 무엇을 추적할지

- 사용자의 **선택/행동** (탭, 필터 적용, 스크롤 종료)
- 에러 발생 지점 (Crashlytics와 별도로 "의도한 실패 경로")
- 기능 노출 (어느 섹션이 실제로 보였는지)

## 무엇을 추적하지 말지

- 개인정보/식별자 (GDPR)
- 매 프레임/매 스크롤 같은 고빈도 이벤트
