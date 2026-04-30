---
name: julook-aso
description: Julook(주룩) iOS 앱의 App Store Connect ASO 메타데이터(앱 이름·부제목·키워드 100자)를 수정/업데이트하는 전용 스킬. 사용자 자연어로 "키워드 바꿔줘", "ASO 업데이트", "키워드 수정", "App Store 키워드", "주룩 키워드", "ASO 분석", "키워드 새로 짜자", "키워드 100자", "AppFollow 데이터 정리" 같은 요청이 오면 반드시 이 스킬을 호출한다. 코드/TDD와 무관하므로 julook(TDD 오케스트레이터) 스킬과는 분리. 현재 키워드 상태(state.md)와 변경 이력(history.md)을 자동으로 읽고, AppFollow 실측 데이터 + 웹 검색을 결합해 100자 한도 안에서 근거 있는 새 키워드 문자열을 제안한다.
---

# Julook ASO — 키워드/메타데이터 업데이트 스킬

App Store Connect의 **앱 이름 / 부제목 / 키워드 100자 필드**를 데이터 근거로 갱신하는 작업 전용. 코드 변경 없음.

---

## 🔴 ASO 절대 규칙 (전부 준수)

1. **키워드 필드는 100자 한도** (쉼표 포함, 띄어쓰기 X)
2. **앱 이름·부제목에 들어간 단어는 키워드 필드에서 제외** — Apple이 인덱스를 합쳐 처리하므로 중복은 슬롯 낭비
3. **한글/영문은 별도 슬롯** — Apple은 자동 변환 안 해줌 (예: vivino + 비비노)
4. **단수/복수, 어순은 자동 조합** — `막걸리추천` 한 단어로 "추천 막걸리"도 매칭됨
5. **데이터 없이 추측으로 키워드 제거 금지** — 반드시 AppFollow Top impressions / Top downloads / Missing 탭 결과 확인 후 결정
6. **키워드 변경 후 최소 2~4주 관찰** 후 재조정. 너무 일찍 빼지 말 것.

---

## Step 1 — 현재 상태 읽기

먼저 다음 두 파일을 **반드시** 읽어 현재 메타데이터와 이력을 파악한다.

- `state.md` — 현재 적용 중인 앱 이름·부제목·키워드 100자
- `history.md` — 모든 과거 변경 이력 (날짜, 변경값, 사유, 데이터)

읽지 않고 작업 시작 금지. 컨텍스트 없이 키워드 짜면 과거 실패 패턴 반복함.

---

## Step 2 — 입력 분류

사용자 의도를 다음 3가지로 구분.

| 의도 | 트리거 | 다음 단계 |
|------|--------|-----------|
| **A. 데이터 기반 갱신** | "AppFollow 데이터 봐서 키워드 다시 짜자", "이번 달 노출 보고 갱신" | Step 3-A 실측 데이터 입력 받기 |
| **B. 즉흥 변경** | "이 단어 빼줘", "이거 추가해줘" | 그 변경이 1번 규칙(100자) / 2번 규칙(앱이름 중복) 위배인지 검사 → OK면 Step 5 |
| **C. 처음부터 다시** | "키워드 새로 짜자", "리셋" | Step 3-A부터 풀 코스 |

---

## Step 3-A — 실측 데이터 수집

사용자에게 다음 중 가능한 만큼 요청 (전부 없으면 references/playbook.md의 "데이터 없을 때" 섹션 참조):

1. **AppFollow Top impressions** 스크린샷 또는 텍스트 (키워드 + % 점유율)
2. **AppFollow Top downloads** 스크린샷 또는 텍스트
3. **AppFollow Missing keywords (Top 50)** 스크린샷 또는 텍스트
4. (선택) App Store Connect → App Analytics → Sources → Search 데이터

데이터를 받으면 다음 형식으로 요약:

```
### 실측 데이터 (YYYY-MM-DD ~ YYYY-MM-DD)
- Top impressions: XX% 키햐, ...
- Top downloads: XX% 키햐, ...
- Missing (Top 50): ...
```

---

## Step 3-B — 보조 리서치 (필요 시)

다음 경우 웹 검색으로 보강:
- 새로운 경쟁 주류 앱 등장 여부 (`references/competitors.md`에 없는 앱이 Missing에 보일 때)
- 트렌드 키워드 변화 (예: 신규 술 카테고리 등장 — 논알콜, 막걸리 칵테일 등)
- 검색 쿼리 예시: `"한국 주류 앱 순위 [현재년도]"`, `"막걸리 트렌드 [현재년도]"`, `"홈술 혼술 검색 [현재년도]"`

검색 결과로 `references/competitors.md` 또는 `references/keyword-pool.md`를 업데이트할지 사용자에게 물어본다.

---

## Step 4 — 키워드 100자 제안

`references/playbook.md`의 슬롯 우선순위 + `references/keyword-pool.md`의 카테고리별 풀 + `references/competitors.md`의 경쟁 앱 리스트를 결합해 다음 형식으로 제안.

```
## 권장안 (메인) — XX자
키워드 문자열: `...`

| 묶음 | 키워드 | 근거 |
|------|--------|------|
| 밥줄 | ... | ... |
| 경쟁 앱 차용 | ... | ... |
| 주종 long-tail | ... | ... |
| 소비 상황 | ... | ... |
| 추천형 | ... | ... |

## 대안 (보수적) — XX자
...

## 대안 (공격적) — XX자
...
```

**글자 수는 직접 계산해 명시**한다. (한글 1자, 영문 1자, 쉼표 1자로 카운트)

---

## Step 5 — 적용 및 이력 기록

사용자가 "이걸로 가자" / "OK" 같이 승인하면:

### 5-1. App Store Connect 적용 가이드 출력

```
1. App Store Connect → My Apps → 주룩 → iOS App
2. 편집 가능한 버전 클릭
3. Keywords 칸 비우고 아래 복붙:
   [최종 문자열]
4. Save → Submit for Review (메타데이터만 변경이라 빌드 재업로드 X)
```

### 5-2. state.md 업데이트

`state.md`의 "현재 적용 중" 섹션을 새 값으로 덮어쓰기.

### 5-3. history.md에 새 엔트리 추가

`history.md` 맨 아래에 다음 형식으로 추가:

```markdown
## YYYY-MM-DD

**앱 이름**: ...
**부제목**: ...
**키워드 (XX자)**: `...`

**변경 사유**:
- ...

**참조 데이터**:
- Top impressions: ...
- Top downloads: ...
- Missing: ...

**다음 검토 예정**: YYYY-MM-DD (2~4주 후)
```

### 5-4. 다음 검토 자동 제안

응답 끝에 한 줄로:
> 2~4주 후 AppFollow 데이터 다시 받아서 가지치기 사이클 한 번 더 돌리는 걸 추천합니다.

(`/schedule`로 자동 리마인더 거는 건 사용자가 원할 때만)

---

## 트러블슈팅

### "AppFollow Trial 만료"
무료에서도 가능한 영역:
- App Store Connect → App Analytics → Sources → Search (가장 정확)
- AppFollow 무료: Top Charts, Featured Apps, Conversion Benchmark
- App Store에서 시드 키워드 직접 검색 → 자동완성으로 Apple recommendations 대체
- Mobile Action / Sensorier 무료 티어

### "데이터가 적어서 판단 어려움"
- 보수안 채택 (검증 약한 키워드 줄이고 슬롯 일부 비움)
- 최소 4주 데이터 모은 뒤 재시도
- 부제목에 핵심 키워드 1~2개 추가하는 안전한 방향 우선 추천

### "키워드 빼고 싶은데 데이터로는 효자"
실측 다운로드 일으키는 키워드는 절대 빼지 말 것 (예: 키햐). 빼야 한다면 일단 보조 키워드 강화 → 신규 키워드가 다운로드 일으키는지 확인 후 → 그제야 교체.

---

## 참조 문서

- `references/playbook.md` — ASO 100자 슬롯 우선순위, 검증된 인사이트, 데이터 없을 때 의사결정
- `references/competitors.md` — 한국 주류 앱 경쟁사 리스트 (계속 추가/갱신)
- `references/keyword-pool.md` — 카테고리별 키워드 후보 풀

---

## 입력/출력 예시

### 입력
> "AppFollow Top impressions / downloads / Missing 데이터 다 받았어. 키워드 다시 짜줘."

### 출력
1. state.md / history.md 자동 읽기
2. 데이터 요약 테이블
3. (필요 시) 웹 검색으로 새 경쟁 앱 확인
4. 메인안 / 보수안 / 공격안 3개 키워드 문자열 + 근거 표
5. 사용자 승인 시 → App Store Connect 적용 가이드 + state.md / history.md 갱신
