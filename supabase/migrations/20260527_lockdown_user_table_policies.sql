-- public.user 테이블 RLS 정책 잠금
-- 현재 SELECT/INSERT/UPDATE 모두 qual/with_check=true 로 RLS가 무력화된 상태.
-- iOS 앱은 user 테이블을 전혀 사용하지 않으므로 (검증 완료) 모든 익명/인증 정책을 제거.
-- RLS는 활성화 상태 유지 → service_role 만 접근 가능.
-- 향후 익명 인증 도입 시 auth.uid() = id 기반 정책을 새로 작성할 예정.

DROP POLICY IF EXISTS "Users can view their own profile" ON public."user";
DROP POLICY IF EXISTS "Users can insert their own profile" ON public."user";
DROP POLICY IF EXISTS "Users can update their own profile" ON public."user";
