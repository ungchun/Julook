# Phase 게이트 상세

각 Phase의 진입 조건, 작업 내역, 완료 조건을 `docs/tdd/phases.md`와 `docs/tdd/cycle.md`를 기반으로 정리.

## Phase 0: 요구사항 확정

**진입 조건**: 사용자 요청이 있음.

**작업**:
1. 요청을 "X 조건에서 Y 결과"로 검증 가능한 형태로 변환
2. 영향 Scene/Reducer 식별 (`Home`, `Search`, `MyMakgeolli`, `LabelScan`, `Tabs`, `Splash`)
3. State 전이 설계 (기존 값 → 새 값)
4. Action 명세 (이름 + 페이로드 타입)
5. 필요한 `@Dependency` 식별

**완료 조건**:
- "이 동작을 증명할 테스트 이름"이 한 문장으로 써진다
- 예: `test_whenOnAppearCalled_shouldFetchNewReleases`
- 불명확하면 사용자에게 되물음 (추측 금지)

**산출물**: `_workspace/00_requirements.md`

## Phase 1: RED — 실패 테스트

**진입 조건**: Phase 0 산출물 존재 + 테스트 이름 확정.

**작업**:
1. `Projects/**/Sources/**` 건드리지 않고 테스트만 작성
2. TestStore 기반 (`docs/testing/tca-test.md` 형식)
3. Dependency 치환 필수 (`withDependencies`)
4. 해피 패스 + 실패 경로 둘 다
5. Tests 타깃이 없으면 먼저 타깃 신설 (`docs/testing/writing.md`)

**실패 확인**:
- `tuist generate && xcodebuild test` 실행
- 새 테스트만 실패 (기존은 영향 없음)
- 처음부터 통과하면 잘못된 테스트 — 재작성

**완료 조건**: 실패 로그에 새 테스트 이름 + 예상/실제 diff가 보임.

**산출물**: `_workspace/01_red_tests.md` (실패 로그 인용 포함)

## Phase 2: GREEN — 최소 구현

**진입 조건**: Phase 1 실패 로그 존재.

**작업**:
1. **처음으로** `Projects/**/Sources/**` 수정
2. Phase 1 실패 테스트를 통과시키는 최소 코드
3. 일반화 금지 ("다음에 쓸지도 모르니" 추상화 X)
4. TCA 컨벤션 준수 (`@Reducer`, `@Dependency`, `Effect.run`)
5. 전체 테스트 실행 → 녹색 확인

**흔한 함정**:
- "깔끔하게 쓰고 싶어서" 리팩토링 겸하기 → Phase 3에서 분리
- View에 비즈니스 로직 → Reducer로
- `print()` 사용 → `Log.debug`
- 싱글턴 직접 호출 → `@Dependency`

**완료 조건**: 전체 테스트 green.

**산출물**: `_workspace/02_green_diff.md`

## Phase 3: REFACTOR — 주변 설계 개선

**진입 조건**: Phase 2 green.

**작업** (작은 단위로 분리):
1. 이번 변경 주변의 중복 추출
2. 이름 개선
3. View 분리 (MARK 섹션)
4. 하위 Reducer로 컴포지션 (`Scope`)
5. 각 리팩토링 직후 Phase 4 재검증

**금지**:
- 기능 변경 (동작이 달라지면 Phase 1~2 다시)
- 테스트 추가/삭제
- 큰 단위 변경 (한 번에 여러 개)

**완료 조건**: 더 고칠 것이 없다고 판단될 때까지 Phase 3→4 왕복.

**산출물**: `_workspace/03_refactor_diff.md`

## Phase 4: GREEN 재검증

**진입 조건**: Phase 3의 각 리팩토링 단위 직후.

**작업**:
1. `tuist generate`
2. `xcodebuild test` 전체 실행
3. 경계면 shape 일치 검증 (State↔View, Action↔send, Dependency↔Key 등록)

**실패 시**:
- 방금 리팩토링 `git restore`로 되돌림
- Phase 3을 더 작게 쪼개 재시도
- 반복 실패 시 tdd-orchestrator가 사용자에게 보고

**완료 조건**: 전체 green + 회귀 0건.

**산출물**: `_workspace/04_verification.md`

## Phase 5: 리뷰 & 커밋

**진입 조건**: Phase 3~4 왕복 완료 ("더 고칠 것 없음" 판단).

**작업**:
1. `git diff --cached` 최종 검토
2. pre-push 차단 항목 전수 사전 체크:
   - 브랜치 ≠ main
   - Secrets 변경 없음 + `API_KEY=` 리터럴 없음
   - `print(` 없음
   - 파일 400줄 / 함수 50줄 / 타입 300줄 이내
   - Sources 변경이 있으면 Tests 변경도 있음
   - 빌드 + 전체 테스트 통과
3. 커밋 메시지: `{이모지} [{type}] {한 줄 요약}`
4. 한 커밋 = 한 사이클 (Phase 1+2+3+4를 한 커밋에)

**산출물**: `_workspace/05_review.md`

## 사이클 크기 경보

**한 사이클이 10분을 넘기면 사이클이 너무 크다는 신호**. 대응:
1. tdd-orchestrator가 중단 지시
2. Phase 0으로 돌아가 요구사항을 더 작게 쪼갬
3. 예: "정렬 기능 전체" → "정렬 기준 enum 추가" + "기준에 따른 정렬 로직" + "UI 연결"

**왜**: 긴 사이클은 TDD의 "빨간 피드백 루프"를 무력화. 실패-통과 간격이 길면 디버깅 비용이 폭증.

## Phase 건너뛰기 금지

어떤 Phase도 건너뛸 수 없다. "이건 간단하니까 테스트 없이" 식 예외는 `docs/tdd/enforcement.md` 위반이며 pre-push에서 차단됨.

예외 가능 범위(테스트 없이 수정 허용):
- 리소스 (`.xcassets`, `Localizable.strings`)
- 설정 (`.xcconfig`, `Info.plist`) — 단, 동작이 바뀌면 통합 테스트 필요
- 문서 (`.md`)
- 순수 타이포/주석

이 외에는 모두 Phase 0~5 사이클 적용.
