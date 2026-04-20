# Julook

막걸리 정보 iOS 앱 (Swift 6.0 + SwiftUI + TCA).

## 🔴 최우선 규칙: TDD Cycle

**단 한 줄의 프로덕션 코드도 실패하는 테스트 없이 수정/추가 금지.**

모든 작업은 `red → green → refactor → green` 사이클을 따른다. Phase 0~5 게이트를 건너뛰면 안 된다.

- 사이클 정의: [docs/tdd/cycle.md](./docs/tdd/cycle.md)
- Phase 게이트: [docs/tdd/phases.md](./docs/tdd/phases.md)
- 자가 강제 및 위반 대응: [docs/tdd/enforcement.md](./docs/tdd/enforcement.md)

## 작업 유형별 진입점

작업을 시작하기 전 아래 중 하나를 먼저 열고 따른다.

| 유형 | 문서 |
|------|------|
| 새 기능 추가 | [docs/workflow/feature.md](./docs/workflow/feature.md) |
| 리팩토링 | [docs/workflow/refactor.md](./docs/workflow/refactor.md) |
| 버그 수정 | [docs/workflow/bugfix.md](./docs/workflow/bugfix.md) |

## 영역별 참조 문서

필요할 때만 해당 문서를 타고 들어간다 (상위 문서는 링크 + 요약만 포함).

- **아키텍처**: [structure](./docs/architecture/structure.md), [data-flow](./docs/architecture/data-flow.md)
- **코딩 규칙**: [tca](./docs/coding/tca.md), [models](./docs/coding/models.md), [errors](./docs/coding/errors.md), [style](./docs/coding/style.md)
- **서비스**: [supabase](./docs/services/supabase.md), [swiftdata](./docs/services/swiftdata.md), [analytics](./docs/services/analytics.md), [logging](./docs/services/logging.md)
- **UI**: [design-system](./docs/ui/design-system.md), [patterns](./docs/ui/patterns.md)
- **데이터베이스**: [schema](./docs/database/schema.md)
- **테스트**: [writing](./docs/testing/writing.md), [tca-test](./docs/testing/tca-test.md), [verification](./docs/testing/verification.md)
- **Git**: [commit](./docs/git/commit.md), [push-check](./docs/git/push-check.md) 🚫 (pre-push 차단 규칙)
- **문제 해결**: [common](./docs/troubleshooting/common.md)

## 문서 규약

- 모든 `.md`는 상단에 YAML frontmatter를 갖는다: `참조:` (내가 의존하는 문서), `피참조:` (나를 의존하는 문서), `검증:` (이 문서 규칙이 깨졌는지 확인할 테스트/소스 경로).
- 한 문서 150줄 이내. 초과하면 하위 문서로 분해.
- 규칙을 적을 때 "왜"를 함께 적는다. 엣지케이스 판단 근거가 필요하기 때문.
- 문서는 모듈처럼 의존 관계를 명시해 Claude가 필요한 것만 타고 들어갈 수 있게 한다.
