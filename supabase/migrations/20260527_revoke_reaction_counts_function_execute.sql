-- update_reaction_counts() RPC 노출 차단
-- 직전 마이그레이션에서 SECURITY DEFINER 로 변경한 결과,
-- anon / authenticated 가 /rest/v1/rpc/update_reaction_counts 로 직접 호출 가능해짐.
-- 본 함수는 트리거 전용이며 직접 호출은 의도된 사용처가 아니므로 EXECUTE 권한 회수.
-- 트리거 발동에는 EXECUTE 권한 무관(owner 권한으로 실행)이므로 정상 동작 유지.

REVOKE EXECUTE ON FUNCTION public.update_reaction_counts() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.update_reaction_counts() FROM anon;
REVOKE EXECUTE ON FUNCTION public.update_reaction_counts() FROM authenticated;
