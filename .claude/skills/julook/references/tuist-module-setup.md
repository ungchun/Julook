---
name: tuist-module-setup
description: Julook의 Tuist 프로젝트에 새 Scene/모듈/테스트 타깃을 추가하는 스킬. Project.swift 수정, 디렉터리 생성, tuist generate 실행, MainCoordinator 라우트 등록까지 모든 Tuist 관련 작업을 처리한다. 새 기능 Scene 추가, Tests 타깃 신설, 모듈 분리/의존성 추가 시 반드시 이 스킬을 사용할 것.
---

# Tuist Module Setup

Julook은 Tuist + mise로 빌드된다. 이 스킬은 새 Scene/모듈/테스트 타깃 추가 절차를 담는다.

## 언제 이 스킬을 사용하는가

- 새 Scene 추가 (예: `Projects/Feature/Scene/NewFeature`)
- 기존 모듈에 Tests 타깃 신설 (Core / DesignSystem / Feature/Scene/*)
- 모듈 간 의존성 추가/변경
- `tuist generate` 후 Xcode 프로젝트 재생성

## 모듈 트리

```
Projects/
├── App/                    앱 진입점
├── Core/                   공통 (Model, Service, Common, Util)
├── DesignSystem/           UI 컴포넌트
└── Feature/
    ├── Coordinator/        MainCoordinator
    └── Scene/              화면별 TCA 모듈
        ├── Home/
        ├── Search/
        ├── MyMakgeolli/
        ├── LabelScan/
        ├── Tabs/
        └── Splash/
```

## 의존성 방향

```
App → Feature/Coordinator → Feature/Scene/* → Core, DesignSystem
                                              ↖ DesignSystem → Core (없음, 독립)
```

**왜 이 방향인가**: Scene 간 상호 의존 금지. 공통 로직은 Core, 공통 UI는 DesignSystem으로 내린다. 순환 의존 방지.

## 새 Scene 추가 절차

### 1. 디렉터리 생성

```
Projects/Feature/Scene/{Name}/
├── Sources/
│   ├── {Name}Core.swift     # Reducer
│   └── {Name}View.swift     # View
└── Tests/
    └── {Name}CoreTests.swift  # TestStore
```

### 2. Project.swift 확인

Scene별 개별 `Project.swift`가 있는지, 상위 `Projects/Feature/Scene/Project.swift`가 타깃을 모두 담는지 확인한다. 기존 Scene의 패턴을 따른다.

### 3. 타깃 추가 예시

```swift
.target(
    name: "{Name}",
    destinations: .iOS,
    product: .framework,
    bundleId: "com.julook.feature.scene.{name}",
    deploymentTargets: .iOS("17.0"),
    sources: ["Scene/{Name}/Sources/**"],
    dependencies: [
        .project(target: "Core", path: "../../Core"),
        .project(target: "DesignSystem", path: "../../DesignSystem"),
        .external(name: "ComposableArchitecture"),
    ]
),
.target(
    name: "{Name}Tests",
    destinations: .iOS,
    product: .unitTests,
    bundleId: "com.julook.feature.scene.{name}.tests",
    deploymentTargets: .iOS("17.0"),
    sources: ["Scene/{Name}/Tests/**"],
    dependencies: [
        .target(name: "{Name}"),
    ]
),
```

### 4. MainCoordinator에 route 추가

`Projects/Feature/Coordinator/Sources/MainCoordinator.swift`의 라우트 enum과 switch에 새 Scene 진입점을 등록한다.

### 5. `tuist generate` 실행

```bash
mise exec -- tuist generate
```

또는 `tuist` 가 PATH에 있으면 `tuist generate`.

### 6. Xcode 재오픈

`Julook.xcworkspace` 재오픈하여 새 타깃이 보이는지 확인.

## Tests 타깃 신설 (기존 모듈)

현재 Tests 타깃이 없는 모듈:

| 모듈 | 현황 |
|------|------|
| App | placeholder 1개 (`JulookTests.swift`) |
| Core | 없음 |
| DesignSystem | 없음 |
| Feature/Scene/* | 전부 없음 |

추가 절차:

1. `Projects/{Module}/Tests/` 생성
2. `Project.swift`에 `.target(name: "{Module}Tests", product: .unitTests, ...)` 추가
3. `tuist generate`
4. 첫 테스트는 **실패하는 실제 테스트**로 작성 (placeholder 금지)

## 의존성 추가 시 주의

- `.external(name: "...")` — Package.swift 의 SPM 의존성
- `.project(target: "...", path: "...")` — 로컬 모듈 의존
- `.target(name: "...")` — 같은 프로젝트 내 타깃

순환 의존이 생기면 `tuist generate` 가 실패한다. Scene 간 직접 의존이 필요하면 Core/DesignSystem으로 공통부 추출.

## 흔한 실패

| 증상 | 원인 | 대응 |
|------|------|------|
| `tuist generate` 실패, "circular dependency" | Scene 간 직접 의존 | 공통부를 Core로 이동 |
| 새 타깃이 Xcode에 안 보임 | `tuist generate` 미실행 | mise 경로 확인 후 재실행 |
| 테스트 타깃이 프로덕션 모듈을 import 못함 | `dependencies`에 `.target(name: "{Module}")` 누락 | Project.swift 수정 후 재생성 |
| `@testable import` 실패 | 프로덕션 타깃이 `product: .framework`인데 dynamic/static 설정 이슈 | 기존 타깃 설정 그대로 복제 |

## 참조 (프로젝트 문서)

- 모듈 구조: `docs/architecture/structure.md`
- 새 기능 워크플로우: `docs/workflow/feature.md`
- 테스트 작성법: `docs/testing/writing.md`
