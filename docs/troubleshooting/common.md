---
참조:
  - docs/services/swiftdata.md
  - docs/services/supabase.md
피참조:
  - AGENTS.md
검증: []
---

# 자주 발생하는 이슈

## Tuist 프로젝트 생성 실패

```bash
tuist clean
tuist install
tuist generate
```

의존성 캐시 삭제가 필요하면:

```bash
tuist clean dependencies
```

## SwiftData / iCloud 동기화 이슈

1. 기기 iCloud 로그인 확인
2. 앱 설정에서 iCloud (CloudKit) 권한 확인
3. 앱 재시작
4. `CloudKitResetHelper` (in `Core/Util/`) 유틸로 리셋 고려

## Supabase 연결 실패

1. 네트워크 확인
2. `Projects/App/Resources/Secrets.xcconfig`의 API 키 확인
3. Supabase 대시보드에서 서비스 상태 확인
4. RLS 정책이 해당 쿼리를 허용하는지 확인

## 테스트가 빌드되지 않음

1. 테스트 타깃이 `Project.swift`에 등록되었는지 확인 ([../testing/writing.md](../testing/writing.md))
2. `tuist generate` 재실행
3. `@testable import`로 대상 모듈 접근 가능한지 확인

## 이슈가 여기 없으면

해결 후 이 문서에 추가한다. 다음 사람(또는 다음 세션)이 같은 벽에 부딪히지 않도록.
