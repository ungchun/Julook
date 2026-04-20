---
참조:
  - docs/tdd/cycle.md
  - docs/tdd/phases.md
  - docs/architecture/structure.md
  - docs/coding/tca.md
  - docs/testing/writing.md
  - docs/testing/tca-test.md
피참조:
  - AGENTS.md
검증: []
---

# 새 기능 개발

## 진입 전 확인

- [ ] 어느 Scene(모듈)에 속하는가? ([../architecture/structure.md](../architecture/structure.md))
- [ ] 신규 Reducer인가, 기존 Reducer에 Action 추가인가?
- [ ] 의존성 주입이 필요한가? (supabase, swiftData 등 → [../services/](../services/))

## 사이클

[Phase 0~5](../tdd/phases.md)를 그대로 따른다.

### 핵심 체크포인트

- **Phase 0**: 동작을 State 전이로 치환. "`.xxxTapped` 액션이 오면 State가 A→B로 간다."
- **Phase 1**: TestStore로 실패 테스트 먼저 ([../testing/tca-test.md](../testing/tca-test.md)).
- **Phase 2**: Reducer `case` 한 줄부터. View는 State 읽기만.
- **Phase 3**: View 분리 (Extension, MARK 주석 → [../coding/style.md](../coding/style.md)).

## 새 Scene을 추가할 때

1. `Projects/Feature/Scene/{Name}/Sources/` 디렉터리 생성
2. `{Name}Core.swift`, `{Name}View.swift`
3. `Projects/Feature/Scene/{Name}/Tests/` 생성 + Tuist 타깃 등록 ([../testing/writing.md](../testing/writing.md))
4. `MainCoordinator`에 route 추가
5. 첫 테스트: 빈 State의 `onAppear`가 아무 Effect도 내지 않는지부터

## 자주 하는 실수

- View에 비즈니스 로직 → Reducer로 옮긴다.
- 직접 싱글턴 호출 (`SupabaseClient.shared` 등) → `@Dependency`로 주입 ([../coding/tca.md](../coding/tca.md)).
- 모델에 mutable 필드 → 모든 모델은 `let` ([../coding/models.md](../coding/models.md)).

## 커밋

`✨ [feat] ...` ([../git/commit.md](../git/commit.md))
