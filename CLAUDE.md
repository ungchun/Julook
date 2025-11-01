# Julook 프로젝트 가이드

## 프로젝트 개요

### 프로젝트 목표
Julook은 막걸리 애호가를 위한 iOS 애플리케이션으로, 막걸리 정보를 제공하고 사용자가 자신의 취향에 맞는 막걸리를 찾을 수 있도록 돕는 것을 목표로 합니다.

### 주요 기능
- **막걸리 검색 및 필터링**: 이름, 양조장으로 검색하고 특징별로 필터링
- **특징별 찾기**: 단맛, 신맛, 걸쭉함, 탄산, 무아스파탐 등으로 필터링
- **신상 막걸리**: 최근 등록된 막걸리 5개 표시
- **랜덤 추천**: 매번 앱 실행 시 랜덤으로 5개 막걸리 추천
- **오늘의 랭킹**: 좋아요 수 기준 상위 3개 막걸리 표시
- **주제로 찾기**: 수상 내역별로 막걸리 탐색
- **코멘트 시스템**: 막걸리에 대한 리뷰 작성 및 공개/비공개 설정
- **리액션 시스템**: 막걸리에 좋았어요/아쉬워요 반응 표시
- **내 막걸리**: 찜한 막걸리 관리

---

## 기술 스택

### 핵심 기술
- **언어**: Swift 6.0
- **UI 프레임워크**: SwiftUI
- **아키텍처**: TCA (The Composable Architecture) 1.11.0+
- **프로젝트 관리**: Tuist
- **로컬 데이터**: SwiftData (iCloud 동기화 지원)

### 외부 라이브러리
- **Supabase 2.25.0+**: 백엔드 서비스 (데이터베이스, 스토리지)
- **TCACoordinators 0.10.1+**: 네비게이션 관리
- **SwiftNavigation 2.6.0+**: 네비게이션 유틸리티
- **Firebase**: Analytics, Crashlytics
- **Amplitude 1.13.9+**: 사용자 행동 분석

### 개발 환경
- **최소 iOS 버전**: iOS 17.0+
- **Xcode**: 15.0+
- **Swift**: 6.0+

---

## 프로젝트 구조

### 디렉터리 구조
```
julook/
├── Projects/
│   ├── App/                    # 앱 엔트리포인트
│   │   ├── Sources/            # 앱 메인 코드
│   │   ├── Resources/          # 앱 리소스
│   │   └── Derived/            # Tuist 자동 생성 파일
│   │
│   ├── Core/                   # 공통 모듈
│   │   └── Sources/
│   │       ├── Model/          # 데이터 모델
│   │       ├── Service/        # 서비스 레이어
│   │       │   ├── Supabase/   # Supabase 클라이언트
│   │       │   ├── SwiftData/  # SwiftData 클라이언트
│   │       │   ├── Amplitude/  # 분석 클라이언트
│   │       │   ├── UserDefault/
│   │       │   ├── Bundle/
│   │       │   └── Version/
│   │       ├── Util/           # 유틸리티 (Log 등)
│   │       └── Common/         # 공통 Extensions, Error
│   │
│   ├── DesignSystem/           # UI 컴포넌트 라이브러리
│   │   ├── Sources/
│   │   │   ├── Colors/         # 색상 정의
│   │   │   ├── Fonts/          # 폰트 정의
│   │   │   ├── Images/         # 이미지 에셋
│   │   │   ├── Views/          # 공통 UI 컴포넌트
│   │   │   └── Buttons/        # 버튼 컴포넌트
│   │   └── Resources/          # 리소스 파일
│   │
│   └── Feature/                # 기능별 모듈
│       ├── Coordinator/        # 네비게이션 코디네이터
│       └── Scene/              # 화면별 모듈
│           ├── Home/           # 홈 화면
│           │   └── Sources/
│           │       ├── HomeCore.swift
│           │       ├── HomeView.swift
│           │       ├── Filter/
│           │       ├── Information/
│           │       └── CommentList/
│           ├── Search/         # 검색 화면
│           ├── MyMakgeolli/    # 내 막걸리 화면
│           ├── Tabs/           # 탭바
│           ├── Splash/         # 스플래시
│           └── Setting/        # 설정
│
├── Tuist/
│   └── Package.swift           # 외부 의존성 관리
│
└── Derived/                    # Tuist 자동 생성 파일
```

### 모듈 설명
- **App**: 앱 진입점, AppDelegate, RootView
- **Core**: 모든 모듈에서 공통으로 사용하는 모델, 서비스, 유틸리티
- **DesignSystem**: 재사용 가능한 UI 컴포넌트, 색상, 폰트 정의
- **Feature**: 각 화면/기능별로 독립적인 모듈로 구성

---

## 코딩 컨벤션

### TCA 패턴
모든 화면은 TCA 패턴을 따릅니다:

```swift
@Reducer
public struct HomeCore {
  @ObservableState
  public struct State: Equatable {
    // 상태 정의
    public var isLoading: Bool = false
    public var items: [Item] = []
  }

  public enum Action {
    // 액션 정의
    case onAppear
    case itemTapped(Item)
    case fetchResponse(TaskResult<[Item]>)
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        // 로직 구현
        return .none
      }
    }
  }
}
```

### 파일 네이밍
- **Core 파일**: `{Feature}Core.swift` (예: `HomeCore.swift`)
- **View 파일**: `{Feature}View.swift` (예: `HomeView.swift`)
- **모델 파일**: `{ModelName}.swift` (예: `Makgeolli.swift`)

### 데이터 모델 규칙
모든 모델은 다음 프로토콜을 준수합니다:

```swift
public struct Makgeolli: Codable, Identifiable, Equatable, Sendable {
  public let id: UUID
  public let name: String
  // ...

  // DB의 snake_case를 Swift의 camelCase로 매핑
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case hasAspartame = "has_aspartame"
    case alcoholPercentage = "alcohol_percentage"
  }
}
```

### 접근 제어
- **public**: 모듈 간 공유되는 타입/메서드
- **fileprivate**: 같은 파일 내에서만 접근
- **private**: 같은 scope 내에서만 접근

### MARK 주석 사용
파일 내 섹션을 명확히 구분합니다:

```swift
// MARK: - HeaderView

private struct HeaderView: View {
  // ...
}

// MARK: - NewReleasesView

private struct NewReleasesView: View {
  // ...
}

// MARK: - Extensions

private extension NewReleasesView {
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    // ...
  }
}
```

---

## 코딩 스타일

### 주석
- 주석은 **한국어**로 작성
- 복잡한 로직에는 설명 주석 추가
- 모델 프로퍼티에는 문서화 주석 사용

```swift
/// 막걸리 이름
public let name: String
/// 단맛 정도 (0-5)
public let sweetness: Int?
```

### Extension 활용
View의 헬퍼 메서드는 extension으로 분리:

```swift
private extension HomeView {
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    // ...
  }

  func getScoreImage(for score: Int?) -> Image {
    // ...
  }
}
```

### 비동기 처리
TCA의 Effect를 사용하여 비동기 작업 처리:

```swift
case .fetchData:
  let supabaseClient = self.supabaseClient
  return .run { send in
    do {
      let data = try await supabaseClient.fetchData()
      await send(.fetchResponse(.success(data)))
    } catch {
      await send(.fetchResponse(.failure(error)))
    }
  }
```

### 에러 처리
커스텀 에러 타입 사용:

```swift
public struct HomeCoreError: JulookError, @unchecked Sendable {
  public var userInfo: [String: Any] = [:]
  public var code: Code
  public var underlying: Error?

  public enum Code: Int, Sendable {
    case failToFetchData
    case failToFetchImage
  }
}
```

---

## 주요 서비스

### Supabase Client
데이터베이스 및 스토리지 접근:

```swift
@Dependency(\.supabaseClient) var supabaseClient

// 데이터 가져오기
let makgeollis = try await supabaseClient.fetchNewReleases()

// 이미지 URL 가져오기
let url = try await supabaseClient.getPublicURL(Bucket.MAKGEOLLIIMAGE, fileName)

// 검색
let results = try await supabaseClient.searchMakgeollis(query)
```

### SwiftData Client
로컬 데이터 저장 (iCloud 동기화):

```swift
@Dependency(\.myMakgeolliClient) var myMakgeolliClient

// 찜하기
await myMakgeolliClient.toggleFavorite(makgeolli)

// 찜 상태 확인
let isFavorite = try await myMakgeolliClient.isFavorite(id)

// 내 막걸리 가져오기
let favorites = try await myMakgeolliClient.getAllMyMakgeollis()
```

### Analytics
사용자 행동 추적 (Amplitude):

```swift
// 이벤트 추적
Amp.track(event: "filter_type_clicked", properties: [
  "filter_type": filterType.description
])

// 화면 조회 추적
Amp.track(event: "screen_viewed", properties: [
  "screen_name": "Home"
])
```

### Logging
디버그 로깅:

```swift
// 일반 디버그 로그
Log.debug("Debug message")

// 네트워크 로그
Log.network("API response", response)

// 에러 로그
Log.error(error)

// 커스텀 로그
Log.custom(category: "CustomCategory", "Custom message")
```

---

## 데이터베이스 스키마

### Makgeolli 테이블
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

### User Comments 테이블
- `id`: UUID (Primary Key)
- `user_id`: UUID
- `makgeolli_id`: UUID
- `comment`: String
- `is_public`: Bool
- `created_at`: Timestamp
- `updated_at`: Timestamp

### Makgeolli Reactions 테이블
- `id`: UUID (Primary Key)
- `user_id`: UUID
- `makgeolli_id`: UUID
- `reaction_type`: String ("like" | "dislike")
- `created_at`: Timestamp
- `updated_at`: Timestamp

---

## UI/UX 가이드

### 색상 사용
DesignSystem에 정의된 색상 사용:

```swift
DesignSystemAsset.Colors.darkbase.swiftUIColor
DesignSystemAsset.Colors.primary.swiftUIColor
DesignSystemAsset.Colors.darkgray.swiftUIColor
```

### 폰트 사용
DesignSystem에 정의된 폰트 사용:

```swift
.font(.SFTitle)
.font(.SF20B)
.font(.SF14R)
.font(.SF12B)
.font(.SF10B)
```

### 이미지 사용
DesignSystem의 이미지 에셋 사용:

```swift
DesignSystemAsset.Images.homeTab.swiftUIImage
DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
DesignSystemAsset.Images.arrowRight.swiftUIImage
```

### 스코어/차트 이미지 매핑
0-5 단계의 값을 이미지로 표시:

```swift
private func getScoreImage(for score: Int?) -> Image {
  guard let score = score else {
    return DesignSystemAsset.Images.nillScore.swiftUIImage
  }

  switch score {
  case 0: return DesignSystemAsset.Images._0Score.swiftUIImage
  case 1: return DesignSystemAsset.Images._1Score.swiftUIImage
  case 2: return DesignSystemAsset.Images._2Score.swiftUIImage
  case 3: return DesignSystemAsset.Images._3Score.swiftUIImage
  case 4: return DesignSystemAsset.Images._4Score.swiftUIImage
  case 5: return DesignSystemAsset.Images._5Score.swiftUIImage
  default: return DesignSystemAsset.Images.nillScore.swiftUIImage
  }
}
```

---

## 자주 사용하는 패턴

### 이미지 로딩
AsyncImage를 사용한 비동기 이미지 로딩:

```swift
if let imageUrl = store.images[item.id] {
  AsyncImage(url: imageUrl) { phase in
    makeImageView(for: phase)
  }
} else {
  ProgressView()
}

// Helper
private func makeImageView(for phase: AsyncImagePhase) -> some View {
  switch phase {
  case .empty:
    return AnyView(ProgressView())
  case .success(let image):
    return AnyView(image.resizable().aspectRatio(contentMode: .fit))
  case .failure:
    return AnyView(defaultImage())
  @unknown default:
    return AnyView(defaultImage())
  }
}
```

### 리스트 아이템 탭 처리
```swift
.onTapGesture {
  Amp.track(event: "item_clicked", properties: [
    "item_name": item.name
  ])
  store.send(.itemTapped(item))
}
```

### 로딩 상태 표시
```swift
if store.isLoading {
  ForEach(0..<5, id: \.self) { idx in
    SkeletonView()
  }
} else {
  ForEach(store.items) { item in
    ItemView(item: item)
  }
}
```

---

## 버전 관리

### iOS 버전 분기
```swift
if #available(iOS 15.0, *) {
  let appearance = UITabBarAppearance()
  appearance.configureWithTransparentBackground()
  UITabBar.appearance().standardAppearance = appearance
} else {
  UITabBar.appearance().backgroundColor = .clear
}
```

### Deprecated API 처리
- 가능한 한 최신 API 사용
- 구버전 지원이 필요한 경우 `#available` 사용

---

## 테스트

### 테스트 디렉터리
- `Projects/App/Tests/`: 앱 레벨 테스트

### TCA 테스트
```swift
@Test
func testFetchData() async {
  let store = TestStore(initialState: HomeCore.State()) {
    HomeCore()
  }

  await store.send(.fetchData) {
    $0.isLoading = true
  }

  await store.receive(.fetchResponse(.success(mockData))) {
    $0.isLoading = false
    $0.items = mockData
  }
}
```

---

## 빌드 및 실행

### Tuist 명령어
```bash
# 의존성 설치
tuist install

# Xcode 프로젝트 생성
tuist generate

# 클린 빌드
tuist clean

# 캐시 삭제
tuist clean dependencies
```

### 환경 설정
- Supabase URL 및 Key는 `Info.plist`에 정의
- Firebase 설정은 `GoogleService-Info.plist` 사용

---

## AI 작업 가이드라인

### 응답 언어
⚠️ **중요**: 모든 응답은 한글로 작성해야 합니다.
- 사용자와의 모든 커뮤니케이션은 한글로 진행합니다
- 코드 설명, 변경사항 요약, 질문 등 모든 텍스트 응답은 한글로 작성합니다
- 코드 내 주석도 한글로 작성합니다
- 단, 코드 자체(변수명, 함수명 등)는 영어를 사용합니다

### 빌드 및 테스트
⚠️ **중요**: 코드 수정 후 빌드를 실행하지 마세요.
- 빌드는 사용자가 직접 수행합니다
- 코드 작성 완료 후 빌드 명령을 실행하지 않습니다
- xcodebuild 또는 관련 빌드 도구를 사용하지 않습니다
- 사용자가 명시적으로 요청할 때만 빌드 관련 작업을 수행합니다

### 작업 순서
1. 요구사항 분석
2. 필요한 파일 읽기 및 분석
3. 코드 작성 및 수정
4. 변경사항 요약 및 설명
5. ❌ 빌드 실행 (하지 않음)

---

## 주의사항

### 보안
- API 키는 절대 코드에 하드코딩하지 않음
- 민감한 정보는 Keychain 사용
- 사용자 ID는 UUID로 관리하며 Keychain에 저장

### 성능
- 이미지는 비동기로 로드
- 대용량 리스트는 LazyVStack/LazyHStack 사용
- 불필요한 상태 업데이트 방지

### 접근성
- VoiceOver 지원 고려
- 색상 대비 확인
- 동적 타입 지원

---

## 문제 해결

### 자주 발생하는 이슈

**Tuist 프로젝트 생성 실패**
```bash
tuist clean
tuist install
tuist generate
```

**SwiftData 동기화 이슈**
- iCloud 로그인 확인
- CloudKit 권한 확인
- 앱 재시작

**Supabase 연결 실패**
- 네트워크 연결 확인
- API 키 확인
- Supabase 서비스 상태 확인

---

## 기타

### 커밋 메시지 컨벤션
```
✨ [feat] 새로운 기능 추가
🐛 [fix] 버그 수정
♻️ [refactor] 리팩토링
📝 [docs] 문서 수정
🎨 [style] UI/스타일 변경
🚀 [deploy] 배포
```

### 브랜치 전략
- `main`: 프로덕션 브랜치
- `develop`: 개발 브랜치
- `feature/*`: 기능 개발 브랜치
- `hotfix/*`: 긴급 수정 브랜치

---

**Last Updated**: 2025-11-01
**Project Version**: 1.8.4
