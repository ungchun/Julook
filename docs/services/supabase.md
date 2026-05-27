---
참조:
  - docs/database/schema.md
  - docs/coding/tca.md
피참조:
  - AGENTS.md
  - docs/architecture/data-flow.md
검증:
  - Projects/Core/Tests/SupabaseClientErrorTests.swift
  - Projects/Core/Tests/LabelAnalysisResultTests.swift
---

# Supabase

데이터베이스 및 스토리지 접근. TCA Dependency로 주입.

## 사용

```swift
@Dependency(\.supabaseClient) var supabaseClient

let makgeollis = try await supabaseClient.fetchNewReleases()
let url = try await supabaseClient.getPublicURL(Bucket.MAKGEOLLIIMAGE, fileName)
let results = try await supabaseClient.searchMakgeollis(query)
```

## 테스트에서 치환

```swift
let store = TestStore(initialState: HomeCore.State()) {
  HomeCore()
} withDependencies: {
  $0.supabaseClient.fetchNewReleases = { [mockMakgeolli] }
}
```

**왜 Dependency 주입인가**: 실제 네트워크 없이 Reducer 로직을 검증하려면 치환 가능해야 한다 ([../testing/tca-test.md](../testing/tca-test.md)).

## 스키마 참조

컬럼/타입은 [../database/schema.md](../database/schema.md).

새 테이블/함수/트리거를 추가할 때는 같은 문서의 [마이그레이션 작성 가이드](../database/schema.md#마이그레이션-작성-가이드)를 따른다. RLS / 정책 / GRANT / search_path / SECURITY DEFINER 패턴이 정리되어 있다.

## Edge Functions

- `supabase/functions/analyze-label/`: base64 이미지 → Gemini 2.5 Flash → 제품명/양조장 추출.
