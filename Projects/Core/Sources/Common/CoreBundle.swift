import Foundation

/// Core.framework 번들을 명시적으로 참조하기 위한 marker 타입.
/// SwiftGen이 생성한 `BundleToken`은 private 이라 테스트/외부에서 번들
/// 접근이 필요할 때 이 타입을 사용한다.
public enum CoreBundle {
  public static let bundle: Bundle = Bundle(for: Marker.self)

  private final class Marker {}
}
