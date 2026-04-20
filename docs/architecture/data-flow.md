---
참조:
  - docs/architecture/structure.md
피참조:
  - AGENTS.md
검증: []
---

# 데이터 흐름

## 화면 계층

```
JulookApp
  └─ AppDelegate + RootCore (TCA)
      └─ MainCoordinator
          └─ Tabs
              ├─ Home ─── CommentList, Filter, Information
              ├─ Search
              ├─ MyMakgeolli
              └─ LabelScan
```

- 최상위: `JulookApp` (SwiftUI App), `AppDelegate` (Firebase 등 초기화)
- 루트 Reducer: `RootCore` (`Projects/App/Sources/`)
- 네비게이션: `MainCoordinator` (TCACoordinators) → `Tabs` → 각 Scene

## 서비스 레이어

```
Core/Sources/Service
  ├─ Supabase       원격 데이터 (읽기/쓰기, 이미지 URL)
  ├─ SwiftData      로컬 데이터 (iCloud 동기화, 찜 목록)
  └─ Amplitude      분석 이벤트
```

모두 **TCA Dependency**로 Reducer에 주입. 직접 싱글턴 호출 금지 — 이유는 [../coding/tca.md](../coding/tca.md).

세부:
- [../services/supabase.md](../services/supabase.md)
- [../services/swiftdata.md](../services/swiftdata.md)
- [../services/analytics.md](../services/analytics.md)
- [../services/logging.md](../services/logging.md)

## 전형적 흐름 (예: Home 신상 막걸리)

1. `HomeView.onAppear` → `store.send(.onAppear)`
2. `HomeCore` reducer: `state.isLoading = true`, `.run { send in ... }` Effect
3. Effect 내부: `@Dependency(\.supabaseClient).fetchNewReleases()` 호출
4. 응답 → `.fetchNewReleasesResponse(.success(...))` 액션 보냄
5. reducer: `state.isLoading = false`, `state.items = ...`
6. View가 State 변경을 관찰 → 재렌더

이 흐름의 각 단계가 **테스트 가능**하도록 Effect를 `@Dependency`로 주입한다 ([../testing/tca-test.md](../testing/tca-test.md)).
