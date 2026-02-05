# 아키텍처

## 기술 스택

| 분류 | 기술 |
|------|------|
| 언어/UI | Swift 6.0, SwiftUI, iOS 17.0+ |
| 아키텍처 | TCA 1.11.0+, TCACoordinators 0.10.1+ |
| 백엔드 | Supabase 2.25.0+ |
| 로컬 저장 | SwiftData (iCloud 동기화) |
| 분석 | Amplitude 1.13.9+, Firebase Analytics/Crashlytics |
| 빌드 | Tuist |

## 모듈 구조

```
Projects/
├── App/                    # 앱 진입점
│   ├── Sources/            # JulookApp, AppDelegate, RootCore, RootView
│   ├── Resources/          # Assets, GoogleService-Info.plist, Secrets.xcconfig
│   └── Tests/
│
├── Core/                   # 공통 모듈
│   └── Sources/
│       ├── Model/          # Makgeolli, Award, UserComment, Reaction 등
│       ├── Service/        # Supabase, SwiftData, Amplitude, UserDefault, Version
│       ├── Common/         # JulookError, Extensions
│       └── Util/           # Log, CloudKitResetHelper
│
├── DesignSystem/           # UI 컴포넌트
│   ├── Sources/            # Colors, Fonts, Images, Views, Buttons
│   └── Resources/          # Colors.xcassets, Images.xcassets
│
└── Feature/                # 기능 모듈
    ├── Coordinator/        # MainCoordinator (네비게이션)
    └── Scene/              # 화면별 TCA 모듈
        ├── Home/           # 홈 (CommentList, Filter, Information 포함)
        ├── Search/         # 검색
        ├── MyMakgeolli/    # 찜한 막걸리
        ├── LabelScan/      # 라벨 스캔 (Gemini AI)
        ├── Tabs/           # 탭 네비게이션
        └── Splash/         # 스플래시
```

## 데이터 흐름

```
JulookApp
  └─ AppDelegate + RootCore (TCA)
      └─ MainCoordinator
          └─ Tabs
              ├─ Home ─── CommentList, Filter, Information
              ├─ Search
              ├─ MyMakgeolli
              └─ LabelScan

Service Layer (Core)
  ├─ Supabase (원격 데이터)
  ├─ SwiftData (로컬 데이터, iCloud 동기화)
  └─ Amplitude/Firebase (분석)
```

## 주요 기능

| 기능 | Scene | 설명 |
|------|-------|------|
| 홈 | Home | 신상 막걸리, 랜덤 추천, 오늘의 랭킹, 주제별 탐색 |
| 검색 | Search | 이름/양조장 검색, 특징별 필터링 |
| 찜하기 | MyMakgeolli | 찜한 막걸리 관리 (SwiftData + iCloud) |
| 라벨 스캔 | LabelScan | 막걸리 라벨 AI 분석 (Gemini 2.5 Flash) |

## Supabase Edge Functions

```
supabase/functions/
└── analyze-label/          # 라벨 이미지 분석 (Gemini AI)
    └── index.ts            # base64 이미지 → 제품명, 양조장 추출
```
