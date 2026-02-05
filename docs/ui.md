# UI

## 디자인 시스템

### 색상

```swift
DesignSystemAsset.Colors.darkbase.swiftUIColor
DesignSystemAsset.Colors.primary.swiftUIColor
DesignSystemAsset.Colors.darkgray.swiftUIColor
```

### 폰트

```swift
.font(.SFTitle)
.font(.SF20B)
.font(.SF14R)
.font(.SF12B)
.font(.SF10B)
```

### 이미지

```swift
DesignSystemAsset.Images.homeTab.swiftUIImage
DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
DesignSystemAsset.Images.arrowRight.swiftUIImage
```

## UI 패턴

### 이미지 로딩

```swift
if let imageUrl = store.images[item.id] {
  AsyncImage(url: imageUrl) { phase in
    makeImageView(for: phase)
  }
} else {
  ProgressView()
}

private func makeImageView(for phase: AsyncImagePhase) -> some View {
  switch phase {
  case .empty: AnyView(ProgressView())
  case .success(let image): AnyView(image.resizable().aspectRatio(contentMode: .fit))
  case .failure: AnyView(defaultImage())
  @unknown default: AnyView(defaultImage())
  }
}
```

### 로딩 상태

```swift
if store.isLoading {
  ForEach(0..<5, id: \.self) { _ in SkeletonView() }
} else {
  ForEach(store.items) { item in ItemView(item: item) }
}
```

### 리스트 아이템 탭

```swift
.onTapGesture {
  Amp.track(event: "item_clicked", properties: ["item_name": item.name])
  store.send(.itemTapped(item))
}
```

### 스코어 이미지

0-5 단계 값을 이미지로 표시:

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
