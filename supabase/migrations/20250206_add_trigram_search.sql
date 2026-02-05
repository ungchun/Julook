-- pg_trgm 확장 활성화 (오타 허용 검색)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- search_makgeolli_flexible 함수 업데이트 (trigram 유사도 추가)
CREATE OR REPLACE FUNCTION public.search_makgeolli_flexible(search_query text)
 RETURNS SETOF makgeolli
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT *
  FROM makgeolli
  WHERE
    -- 기존: 원본 검색어로 검색
    name ILIKE '%' || search_query || '%'
    OR brewery ILIKE '%' || search_query || '%'
    -- 기존: 공백 제거 후 검색
    OR REPLACE(name, ' ', '') ILIKE '%' || REPLACE(search_query, ' ', '') || '%'
    OR REPLACE(brewery, ' ', '') ILIKE '%' || REPLACE(search_query, ' ', '') || '%'
    -- 신규: trigram 유사도 검색 (오타 허용)
    OR similarity(name, search_query) > 0.3
    OR similarity(REPLACE(name, ' ', ''), REPLACE(search_query, ' ', '')) > 0.3
  ORDER BY
    -- 정확한 이름 매칭 우선
    CASE
      WHEN name ILIKE search_query THEN 0
      WHEN REPLACE(name, ' ', '') ILIKE REPLACE(search_query, ' ', '') THEN 1
      WHEN name ILIKE '%' || search_query || '%' THEN 2
      WHEN similarity(name, search_query) > 0.5 THEN 3
      WHEN similarity(name, search_query) > 0.3 THEN 4
      ELSE 5
    END,
    similarity(name, search_query) DESC,
    name;
END;
$function$;
