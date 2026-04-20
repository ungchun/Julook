-- makgeolli_translations: 막걸리 데이터 다국어 번역 테이블
-- 기존 makgeolli 테이블은 한국어 원본으로 유지.
-- 영어/일본어 등 추가 언어는 여기에 locale 행으로 저장.
-- 번역 대상 필드: name, brewery, awards[], ingredients[], description
-- 번역 제외: 숫자(sweetness 등), URL, bool, 이미지 파일명, timestamps

CREATE TABLE IF NOT EXISTS public.makgeolli_translations (
  makgeolli_id UUID NOT NULL REFERENCES public.makgeolli(id) ON DELETE CASCADE,
  locale TEXT NOT NULL,
  name TEXT NOT NULL,
  brewery TEXT,
  awards TEXT[],
  ingredients TEXT[],
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (makgeolli_id, locale)
);

-- locale 기반 조회(prefetch 전체 로케일 번역) 가속용
CREATE INDEX IF NOT EXISTS idx_makgeolli_translations_locale
  ON public.makgeolli_translations(locale);

-- updated_at 자동 갱신 트리거
CREATE OR REPLACE FUNCTION public.set_makgeolli_translations_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_makgeolli_translations_updated_at
  ON public.makgeolli_translations;

CREATE TRIGGER trg_makgeolli_translations_updated_at
  BEFORE UPDATE ON public.makgeolli_translations
  FOR EACH ROW
  EXECUTE FUNCTION public.set_makgeolli_translations_updated_at();

-- RLS: 읽기만 공개. 쓰기는 서비스 롤(백엔드)만.
ALTER TABLE public.makgeolli_translations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "makgeolli_translations_select_all"
  ON public.makgeolli_translations;

CREATE POLICY "makgeolli_translations_select_all"
  ON public.makgeolli_translations
  FOR SELECT
  USING (true);
