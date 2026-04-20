import XCTest

import ComposableArchitecture

@testable import FeatureSplash

@MainActor
final class SplashCoreTests: XCTestCase {

  // MARK: - Image index cycling

  func test_updateImageIndex_incrementsFromZero() async {
    let store = TestStore(initialState: SplashCore.State()) { SplashCore() }

    await store.send(.updateImageIndex) {
      $0.currentImageIndex = 1
    }
  }

  func test_updateImageIndex_wrapsAround20() async {
    var state = SplashCore.State()
    state.currentImageIndex = 19
    let store = TestStore(initialState: state) { SplashCore() }

    await store.send(.updateImageIndex) {
      $0.currentImageIndex = 0
    }
  }

  func test_timerTick_emitsUpdateImageIndex() async {
    let store = TestStore(initialState: SplashCore.State()) { SplashCore() }

    await store.send(.timerTick)
    await store.receive(\.updateImageIndex) {
      $0.currentImageIndex = 1
    }
  }

  // MARK: - Initial state

  func test_defaultState_hasZeroIndex_andNotAnimating() {
    let state = SplashCore.State()

    XCTAssertEqual(state.currentImageIndex, 0)
    XCTAssertFalse(state.isAnimating)
  }
}
