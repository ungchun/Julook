# 코딩 컨벤션

## 세부 문서
- [TCA 패턴](./tca-pattern.md) - Reducer, State, Action 구조
- [데이터 모델](./data-models.md) - 모델 프로토콜, CodingKeys
- [MARK 주석](./mark-comments.md) - 섹션 구분 규칙

## 파일 네이밍
- Core 파일: `{Feature}Core.swift`
- View 파일: `{Feature}View.swift`
- 모델 파일: `{ModelName}.swift`

## 접근 제어
- `public`: 모듈 간 공유되는 타입/메서드
- `fileprivate`: 같은 파일 내에서만
- `private`: 같은 scope 내에서만
