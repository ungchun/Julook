# 빌드 & 실행

## Tuist 명령어

```bash
# 의존성 설치
tuist install

# Xcode 프로젝트 생성
tuist generate

# 클린 빌드
tuist clean

# 캐시 삭제
tuist clean dependencies
```

## 환경 설정
- Supabase URL 및 Key: `Info.plist`에 정의
- Firebase 설정: `GoogleService-Info.plist` 사용
