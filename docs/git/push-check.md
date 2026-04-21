---
참조:
  - docs/tdd/enforcement.md
  - docs/coding/style.md
  - docs/services/logging.md
  - docs/git/commit.md
피참조:
  - AGENTS.md
  - docs/coding/style.md
  - docs/git/commit.md
검증:
  - scripts/pre-push.sh
---

# 푸시 차단 규칙 (pre-push)

**푸시는 모든 차단 항목을 통과해야 실행된다.** 실제 체크는 [`scripts/pre-push.sh`](../../scripts/pre-push.sh).

## 설치 (1회)

```bash
./scripts/install-hooks.sh
```

`git config core.hooksPath scripts/git-hooks`를 설정 + 실행 권한 부여.

## 차단 항목 (통과 못 하면 푸시 자체가 막힘)

| # | 항목 | 근거 |
|---|------|------|
| 1 | **main 직접 푸시 금지** | PR 기반 협업 강제 |
| 2 | **Secrets 유출 방지** | `Secrets.xcconfig`, `.env`, `GoogleService-Info.plist` 파일 변경 + `API_KEY=<긴 리터럴>` 패턴 감지 |
| 3 | **`print(` 직접 사용 금지** | [../services/logging.md](../services/logging.md) — `Log.debug` 등으로 |
| 4 | **라인 제한 위반** | 파일 400줄 초과 차단 (함수 50 / 타입 300 초과는 경고). [../coding/style.md](../coding/style.md) |
| 5 | **프로덕션 코드 변경 시 테스트 동반** | `Projects/**/Sources/**` or `supabase/functions/` 변경 있는데 `**/Tests/**` 변경 0건 → 차단. [../tdd/enforcement.md](../tdd/enforcement.md) |
| 6 | **빌드 성공 + 전체 테스트 통과** | `tuist generate` + `xcodebuild test` |

## 차단 항목 (계속)

| # | 항목 | 판정 기준 |
|---|------|----------|
| 7 | 커밋 메시지 형식 | [../git/commit.md](./commit.md) 형식 (`{이모지} [{type}] ...`) 불일치 |
| 8 | WIP/임시 커밋 금지 | `WIP`, `fixme`, `임시`, `asdf` 등 메시지 감지 |
| 10 | SwiftLint error 수준 | `.swiftlint.yml` 임계값 error 에 해당하는 위반 (warning은 통과) |
| 11 | 한글 리터럴 0건 | [아래 섹션](#한글-리터럴-0건) 참조 |

> 이전에는 경고 수준이었으나 차단으로 승격됨 (2026-04-21).

### 한글 리터럴 0건

Swift 소스의 주석이 아닌 문자열 리터럴에 한글이 포함되면 푸시 차단. UI 문자열은 전부 `L10n.*` (SwiftGen) 경유. 근거: [../coding/localization.md](../coding/localization.md).

```bash
./scripts/check-hardcoded-korean.sh Projects
```

- 탐지 시 stderr 에 `파일:라인:내용` 출력 + exit 1.
- 제외: `**/Generated/**`, `**/Tests/**`, `**/.build/**`, `scripts/fixtures/**`.
- 디버그 로그 전용 탈출구: 같은 라인에 `// swiftgen-ignore` 마커.
- 의존성: `ripgrep` (`brew install ripgrep`).

## 비상 우회

정말 불가피할 때만:

```bash
SKIP_ALL=1 git push             # 모든 체크 스킵
SKIP_BUILD_TESTS=1 git push     # 빌드/테스트만 스킵 (나머지 검증)
```

우회 사용 시 **즉시 사후 조치** (다음 커밋에 해결 + 커밋 메시지에 이유 명시).

## 왜 이 방식인가

- **CI에만 맡기면 피드백이 늦다**: 푸시 → CI 실패 → 복구 사이클이 10~15분. pre-push는 수 분 내에 막아준다.
- **문서 규약이 실제로 지켜지는지 기계가 검증**: "지켜달라"는 문장은 쉽게 무력화됨. 차단이 현실을 강제한다.
- **TDD 강제의 마지막 방어선**: [enforcement.md](../tdd/enforcement.md)의 자가 점검이 뚫리면 pre-push가 잡는다.

## 위반 대응 순서

1. 에러 메시지 읽기 (어느 항목이 막았는지 명시됨)
2. 파일/줄 번호로 이동 → 문제 수정
3. 다시 `git push`
4. 반복 위반이면 `feedback` 메모리에 패턴 기록하여 재발 방지
