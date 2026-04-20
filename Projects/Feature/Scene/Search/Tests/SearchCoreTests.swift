import XCTest

import ComposableArchitecture

@testable import Core
@testable import FeatureSearch

@MainActor
final class SearchCoreTests: XCTestCase {

  // MARK: - Sheet / alert toggles

  func test_setSearchBarFocus_setsState() async {
    let store = TestStore(initialState: SearchCore.State()) { SearchCore() }

    await store.send(.setSearchBarFocus(true)) {
      $0.isSearchBarFocused = true
    }
  }

  func test_showRequestAlert_setsState() async {
    let store = TestStore(initialState: SearchCore.State()) { SearchCore() }

    await store.send(.showRequestAlert(true)) {
      $0.isShowingRequestAlert = true
    }
  }

  func test_showClearConfirmAlert_setsState() async {
    let store = TestStore(initialState: SearchCore.State()) { SearchCore() }

    await store.send(.showClearConfirmAlert(true)) {
      $0.isShowingClearConfirmAlert = true
    }
  }

  // MARK: - Recent searches loading

  func test_recentSearchesResponse_setsList() async {
    let store = TestStore(initialState: SearchCore.State()) { SearchCore() }

    await store.send(.recentSearchesResponse(["장수", "백운", "단맛"])) {
      $0.recentSearches = ["장수", "백운", "단맛"]
    }
  }

  // MARK: - Navigation (coordinator-bound)

  func test_moveToInformation_isNoop() async {
    let store = TestStore(initialState: SearchCore.State()) { SearchCore() }
    let makgeolli = Self.sampleMakgeolli

    await store.send(.moveToInformation(makgeolli, nil))
  }

  // MARK: - Helpers

  private static let sampleMakgeolli = Makgeolli(
    id: UUID(),
    name: "테스트 막걸리",
    brewery: nil,
    website: nil,
    awards: nil,
    sweetness: nil,
    sourness: nil,
    thickness: nil,
    carbonation: nil,
    hasSweetener: nil,
    ingredients: nil,
    alcoholPercentage: nil,
    imageName: nil,
    createdAt: nil,
    updatedAt: nil
  )
}
