-- Function search_path injection 방어
-- Supabase Security Advisor: function_search_path_mutable (8건) 대응.
-- search_path를 함수에 잠가서 호출자가 임의 스키마를 우선 탐색하도록 만드는 공격을 차단.
-- pg_temp는 마지막에 두어 임시 객체 hijacking도 방지.
-- 함수 본문은 그대로 두고 ALTER FUNCTION ... SET 으로 search_path만 잠금.

ALTER FUNCTION public.log_search_failure(text, uuid, double precision, text)
  SET search_path = public, pg_temp;

ALTER FUNCTION public.search_makgeolli_flexible(text)
  SET search_path = public, pg_temp;

ALTER FUNCTION public.search_makgeolli_fuzzy(text)
  SET search_path = public, pg_temp;

ALTER FUNCTION public.search_similar_makgeolli(vector, double precision, integer)
  SET search_path = public, pg_temp;

ALTER FUNCTION public.set_makgeolli_translations_updated_at()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_modified_column()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_reaction_counts()
  SET search_path = public, pg_temp;

ALTER FUNCTION public.update_updated_at_column()
  SET search_path = public, pg_temp;
