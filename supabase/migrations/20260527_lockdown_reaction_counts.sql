-- makgeolli_reaction_counts 직접 변조 차단 + 트리거 권한 모델 변경
-- 정상 흐름: iOS는 READ만, INSERT/UPDATE/DELETE는 update_reaction_counts() 트리거가
-- makgeolli_reactions 변경을 감지해 자동 수행.
-- 변경 전: 트리거가 호출자(anon) 권한으로 reaction_counts 갱신 → ALL 정책 필요 → 외부 직접 변조도 허용됨.
-- 변경 후: 트리거를 SECURITY DEFINER로 만들어 owner 권한으로 RLS bypass → 정책은 SELECT만 유지.

-- 1. 트리거 함수 권한 모드 변경 (owner 권한으로 실행)
ALTER FUNCTION public.update_reaction_counts() SECURITY DEFINER;

-- 2. 기존 ALL 정책 제거
DROP POLICY IF EXISTS "Enable all access for anon and authenticated users"
  ON public.makgeolli_reaction_counts;

-- 3. SELECT만 허용 (READ 전용 노출)
CREATE POLICY "Enable read access for anon and authenticated"
  ON public.makgeolli_reaction_counts
  FOR SELECT
  USING (true);
