---
참조:
  - docs/ui/design-system.md
  - docs/services/analytics.md
피참조:
  - AGENTS.md
검증: []
---

# UI 패턴

자주 반복되는 UI 구현 패턴.

## 이미지 로딩

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

## 로딩 상태 (Skeleton)

```swift
if store.isLoading {
  ForEach(0..<5, id: \.self) { _ in SkeletonView() }
} else {
  ForEach(store.items) { item in ItemView(item: item) }
}
```

## 리스트 아이템 탭 + 트래킹

탭 제스처에서 Analytics 먼저, 그 다음 Action 전송.

```swift
.onTapGesture {
  Amp.track(event: "item_clicked", properties: ["item_name": item.name])
  store.send(.itemTapped(item))
}
```

**왜 이 순서인가**: Action 처리 중 화면이 전환되면 분석 이벤트가 누락될 수 있다. 먼저 기록.

## 스코어 이미지 (0~5 단계)

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

자산 이름은 [design-system](./design-system.md).
