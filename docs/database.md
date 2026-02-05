# 데이터베이스 스키마

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
| `reaction_type` | String | "like" 또는 "dislike" |
| `created_at` | Timestamp | 생성 시간 |
| `updated_at` | Timestamp | 수정 시간 |
