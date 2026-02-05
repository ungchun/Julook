# 문제 해결

## Tuist 프로젝트 생성 실패

```bash
tuist clean
tuist install
tuist generate
```

의존성 캐시 삭제가 필요한 경우:

```bash
tuist clean dependencies
```

## SwiftData 동기화 이슈

1. iCloud 로그인 확인
2. CloudKit 권한 확인
3. 앱 재시작

## Supabase 연결 실패

1. 네트워크 연결 확인
2. API 키 확인 (`Info.plist`)
3. Supabase 서비스 상태 확인
