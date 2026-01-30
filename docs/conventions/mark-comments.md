# MARK 주석

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
