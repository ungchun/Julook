# 아키텍처

## 디렉토리 구조
```
Projects/
├── App/                    # 앱 엔트리포인트
│   ├── Sources/
│   ├── Resources/
│   └── Derived/
│
├── Core/                   # 공통 모듈
│   └── Sources/
│       ├── Model/
│       ├── Service/        # Supabase, SwiftData, Amplitude 등
│       ├── Util/
│       └── Common/
│
├── DesignSystem/           # UI 컴포넌트
│   ├── Sources/            # Colors, Fonts, Images, Views, Buttons
│   └── Resources/
│
└── Feature/                # 기능별 모듈
    ├── Coordinator/        # 네비게이션 코디네이터
    └── Scene/              # Home, Search, MyMakgeolli, Tabs, Splash, Setting
```

## 모듈 역할
- **App**: 앱 진입점, AppDelegate, RootView
- **Core**: 모든 모듈 공통 모델, 서비스, 유틸리티
- **DesignSystem**: 재사용 UI 컴포넌트, 색상, 폰트
- **Feature**: 화면/기능별 독립 모듈
