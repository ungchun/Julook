---
참조: []
피참조:
  - AGENTS.md
  - docs/coding/errors.md
검증: []
---

# Logging

디버그 및 네트워크/에러 로깅.

## 사용

```swift
Log.debug("Debug message")
Log.network("API response", response)
Log.error(error)
Log.custom(category: "CustomCategory", "Custom message")
```

## 카테고리별 용도

| 메서드 | 언제 |
|--------|------|
| `Log.debug` | 개발 중 임시 상태 확인 |
| `Log.network` | API 요청/응답 본문 |
| `Log.error` | catch 블록에서 예외 포착 |
| `Log.custom` | 특수 목적 카테고리 분리 필요 시 |

## 금지

- `print` 직접 사용 (프로덕션에서 필터링 불가).
- 개인정보/토큰을 로그에 남기기.
- 핵심 비즈니스 흐름을 로그 메시지로 이해시키려 시도 — 그건 테스트의 역할.

**왜**: 로그는 "원인 추적" 도구. 기능이 동작했다는 증명은 테스트가 한다.
