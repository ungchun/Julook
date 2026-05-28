import XCTest

import ComposableArchitecture
import TCACoordinators

@testable import Core
@testable import MainCoordinator

@MainActor
final class MainCoordinatorCoreTests: XCTestCase {

  func test_initialRoute_isTabsOnly() {
    let state = MainCoordinatorCore.State(
      routes: [.root(.tabs(.init()), withNavigation: true)]
    )

    XCTAssertEqual(state.routes.count, 1)
    if case .tabs = state.routes.first?.screen { } else {
      XCTFail("Root route should be .tabs")
    }
  }

  // MARK: - MainScreen equatable

  func test_mainScreen_equatable_tabsInstancesAreEqual() {
    let a = MainScreen.State.tabs(.init())
    let b = MainScreen.State.tabs(.init())
    XCTAssertEqual(a, b)
  }

  func test_mainScreen_equatable_differentKindsNotEqual() {
    let tabs = MainScreen.State.tabs(.init())
    let filter = MainScreen.State.filter(.init())
    XCTAssertNotEqual(tabs, filter)
  }
}
