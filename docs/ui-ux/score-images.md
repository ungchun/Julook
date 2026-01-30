# 스코어 이미지 매핑

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
