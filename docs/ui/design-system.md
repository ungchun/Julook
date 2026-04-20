---
참조: []
피참조:
  - AGENTS.md
  - docs/ui/patterns.md
검증:
  - Projects/DesignSystem/Tests/DesignSystemAssetTests.swift
---

# 디자인 시스템

`Projects/DesignSystem/`에 색/폰트/이미지 자산이 통합되어 있다. View 코드는 직접 리터럴 색/폰트를 쓰지 말고 반드시 이 자산을 통해 참조한다.

## 색상

```swift
DesignSystemAsset.Colors.darkbase.swiftUIColor
DesignSystemAsset.Colors.primary.swiftUIColor
DesignSystemAsset.Colors.darkgray.swiftUIColor
```

## 폰트

```swift
.font(.SFTitle)
.font(.SF20B)
.font(.SF14R)
.font(.SF12B)
.font(.SF10B)
```

명명: `SF{size}{weight}` — `B` = Bold, `R` = Regular.

## 이미지

```swift
DesignSystemAsset.Images.homeTab.swiftUIImage
DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
DesignSystemAsset.Images.arrowRight.swiftUIImage
```

## 왜 자산 통합인가

- 다크모드/테마 변경 시 한 곳에서 통제.
- 디자인 토큰 변경이 코드 전체로 전파.
- 직접 `Color(.red)` / `Font.system(...)` 사용 금지.

UI 반복 패턴은 [patterns](./patterns.md).
