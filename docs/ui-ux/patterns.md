# UI 패턴

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

## 리스트 아이템 탭

```swift
.onTapGesture {
  Amp.track(event: "item_clicked", properties: ["item_name": item.name])
  store.send(.itemTapped(item))
}
```

## 로딩 상태

```swift
if store.isLoading {
  ForEach(0..<5, id: \.self) { _ in SkeletonView() }
} else {
  ForEach(store.items) { item in ItemView(item: item) }
}
```
