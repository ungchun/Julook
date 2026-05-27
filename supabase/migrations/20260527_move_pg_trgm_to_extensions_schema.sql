-- pg_trgm extension을 public → extensions 스키마로 이동
-- Supabase Security Advisor: extension_in_public 대응.
-- public 스키마 권한과 extension 객체 분리, 표준 권장 패턴 준수.
--
-- 의존 코드: search_makgeolli_flexible 함수가 similarity() 를 4회 사용.
-- 이동 후에도 함수가 similarity 를 resolve 할 수 있도록 search_path 에
-- extensions 추가. 단일 트랜잭션으로 적용되므로 중간 상태가 외부 노출되지 않음.
--
-- 인덱스 영향: 없음 (gin_trgm_ops / gist_trgm_ops 사용 인덱스 0개 확인).

ALTER EXTENSION pg_trgm SET SCHEMA extensions;

ALTER FUNCTION public.search_makgeolli_flexible(text)
  SET search_path = public, extensions, pg_temp;
