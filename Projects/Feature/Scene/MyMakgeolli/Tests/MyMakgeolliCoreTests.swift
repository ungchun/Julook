import XCTest

import ComposableArchitecture

@testable import Core
@testable import FeatureMyMakgeolli

@MainActor
final class MyMakgeolliCoreTests: XCTestCase {

  // MARK: - Tab selection

  func test_tabSelected_updatesState() async {
    let store = TestStore(initialState: MyMakgeolliCore.State()) { MyMakgeolliCore() }

    await store.send(.tabSelected(.like)) {
      $0.selectedTab = .like
    }
  }

  func test_myMakgeollis_computedReturnsSelectedTabList() {
    var state = MyMakgeolliCore.State()
    let entity = MyMakgeolliEntity(
      id: UUID(), name: "A",
      imageName: nil, feedback: nil,
      isFavorite: true, comment: nil,
      createdAt: Date(), updatedAt: Date()
    )
    state.favoriteMakgeollis = [entity]
    state.selectedTab = .favorite

    XCTAssertEqual(state.myMakgeollis.map(\.id), [entity.id])

    state.selectedTab = .all
    XCTAssertTrue(state.myMakgeollis.isEmpty)
  }

  // MARK: - Image update

  func test_updateMakgeolliImage_setsMap() async {
    let store = TestStore(initialState: MyMakgeolliCore.State()) { MyMakgeolliCore() }
    let id = UUID()
    let url = URL(string: "https://example.com/a.png")!

    await store.send(.updateMakgeolliImage(id, url)) {
      $0.makgeolliImages[id] = url
    }
  }

  // MARK: - viewAppeared idempotency

  func test_viewAppeared_whenAlreadyInitialized_isNoop() async {
    var initial = MyMakgeolliCore.State()
    initial.isInitialized = true
    let store = TestStore(initialState: initial) { MyMakgeolliCore() }

    await store.send(.viewAppeared)
  }

  // MARK: - Navigation

  func test_moveToInformation_isNoop() async {
    let store = TestStore(initialState: MyMakgeolliCore.State()) { MyMakgeolliCore() }
    await store.send(.moveToInformation(Self.sampleMakgeolli, nil))
  }

  // MARK: - Helpers

  private static let sampleMakgeolli = Makgeolli(
    id: UUID(),
    name: "테스트",
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
