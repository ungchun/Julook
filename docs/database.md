# 데이터베이스 스키마

## Makgeolli 테이블
- `id`: UUID (Primary Key)
- `name`: String (막걸리 이름)
- `brewery`: String? (양조장명)
- `website`: String? (홈페이지)
- `awards`: [String]? (수상 내역)
- `sweetness`: Int? (단맛 0-5)
- `sourness`: Int? (신맛 0-5)
- `thickness`: Int? (걸쭉함 0-5)
- `carbonation`: Int? (탄산 0-5)
- `has_aspartame`: Bool? (아스파탐 유무)
- `ingredients`: [String]? (원재료)
- `alcohol_percentage`: Double? (알콜 도수)
- `image_name`: String? (이미지 파일명)
- `created_at`: Timestamp
- `updated_at`: Timestamp

## User Comments 테이블
- `id`: UUID (Primary Key)
- `user_id`: UUID
- `makgeolli_id`: UUID
- `comment`: String
- `is_public`: Bool
- `created_at`: Timestamp
- `updated_at`: Timestamp

## Makgeolli Reactions 테이블
- `id`: UUID (Primary Key)
- `user_id`: UUID
- `makgeolli_id`: UUID
- `reaction_type`: String ("like" | "dislike")
- `created_at`: Timestamp
- `updated_at`: Timestamp
