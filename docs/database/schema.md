---
참조: []
피참조:
  - AGENTS.md
  - docs/coding/models.md
  - docs/services/supabase.md
검증:
  - Projects/Core/Tests/MakgeolliTests.swift
  - Projects/Core/Tests/UserCommentTests.swift
  - Projects/Core/Tests/MakgeolliReactionTests.swift
---

# 데이터베이스 스키마

Supabase Postgres 테이블. Swift 모델 매핑은 [../coding/models.md](../coding/models.md).

## Makgeolli

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `id` | UUID | Primary Key |
| `name` | String | 막걸리 이름 |
| `brewery` | String? | 양조장명 |
| `website` | String? | 홈페이지 |
| `awards` | [String]? | 수상 내역 |
| `sweetness` | Int? | 단맛 (0-5) |
| `sourness` | Int? | 신맛 (0-5) |
| `thickness` | Int? | 걸쭉함 (0-5) |
| `carbonation` | Int? | 탄산 (0-5) |
| `has_aspartame` | Bool? | 아스파탐 유무 |
| `ingredients` | [String]? | 원재료 |
| `alcohol_percentage` | Double? | 알콜 도수 |
| `image_name` | String? | 이미지 파일명 |
| `created_at` | Timestamp | 생성 시간 |
| `updated_at` | Timestamp | 수정 시간 |

## User Comments

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `id` | UUID | Primary Key |
| `user_id` | UUID | 사용자 ID |
| `makgeolli_id` | UUID | 막걸리 ID |
| `comment` | String | 코멘트 내용 |
| `is_public` | Bool | 공개 여부 |
| `created_at` | Timestamp | 생성 시간 |
| `updated_at` | Timestamp | 수정 시간 |

## Makgeolli Reactions

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `id` | UUID | Primary Key |
| `user_id` | UUID | 사용자 ID |
| `makgeolli_id` | UUID | 막걸리 ID |
| `reaction_type` | String | `"like"` 또는 `"dislike"` |
| `created_at` | Timestamp | 생성 시간 |
| `updated_at` | Timestamp | 수정 시간 |

## 마이그레이션 작성 가이드

`supabase/migrations/YYYYMMDD_<snake_case>.sql`. 새 테이블/함수를 추가할 때
아래 패턴을 따라 작성한다.

### 새 테이블

```sql
CREATE TABLE IF NOT EXISTS public.foo (...);

-- RLS 활성. 없으면 PostgREST가 거부.
ALTER TABLE public.foo ENABLE ROW LEVEL SECURITY;

-- 정책 명시. iOS가 읽는 테이블은 SELECT만 USING(true) 로 공개,
-- 쓰기는 service_role 만(정책 생성하지 않음) 또는 향후 auth.uid() 기반.
CREATE POLICY "foo_select_all" ON public.foo FOR SELECT USING (true);

-- 2026-10-30부터: public 스키마의 새 테이블은 자동 노출 안 됨.
-- PostgREST에 노출하려면 명시적 GRANT 필요.
GRANT SELECT ON public.foo TO anon, authenticated;
```

**왜 GRANT를 명시하나**: 2026-05-30부터 신규 Supabase 프로젝트, 2026-10-30부터
기존 프로젝트의 새 테이블이 기본 차단된다. 미리 패턴을 들여놓아야 그날 새벽
배포에서 깨지지 않는다.

### 새 함수

```sql
CREATE OR REPLACE FUNCTION public.bar(...) RETURNS ...
LANGUAGE plpgsql
AS $$ ... $$;

-- search_path 고정. 미설정 시 search_path injection 공격에 노출.
ALTER FUNCTION public.bar(...) SET search_path = public, pg_temp;
```

pg_trgm 같은 extension 함수(`similarity()` 등)를 호출하면:

```sql
ALTER FUNCTION public.bar(...) SET search_path = public, extensions, pg_temp;
```

### 트리거에서 RLS 우회가 필요한 함수

`reaction_counts` 같이 트리거만 쓰는 테이블을 RLS로 잠그면 트리거가 깨진다.
함수를 `SECURITY DEFINER` 로 만들되 RPC 직접 호출은 차단한다.

```sql
ALTER FUNCTION public.update_counts() SECURITY DEFINER;

-- RPC 노출 차단 (트리거 발동에는 EXECUTE 권한 무관).
REVOKE EXECUTE ON FUNCTION public.update_counts() FROM PUBLIC, anon, authenticated;
```

**왜**: SECURITY DEFINER 함수는 PostgREST `/rpc/...` 로 자동 노출되어 owner
권한으로 외부 호출이 가능해진다. 트리거 전용이라면 EXECUTE 를 즉시 회수해야
Security Advisor의 `*_security_definer_function_executable` 경고를 막을 수 있다.
