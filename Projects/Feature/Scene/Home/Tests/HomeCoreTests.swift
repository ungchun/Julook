import XCTest

import ComposableArchitecture

@testable import Core
@testable import FeatureHome

@MainActor
final class HomeCoreTests: XCTestCase {

  // MARK: - Navigation (coordinator-bound)

  func test_filterButtonTapped_emitsMoveToFilter() async {
    let store = TestStore(initialState: HomeCore.State()) {
      HomeCore()
    }

    await store.send(.filterButtonTapped)
    await store.receive(\.moveToFilter)
  }

  func test_filterItemTapped_emitsMoveToFilterWithSelection() async {
    let store = TestStore(initialState: HomeCore.State()) {
      HomeCore()
    }

    await store.send(.filterItemTapped(.sweet))
    await store.receive(\.moveToFilterWithSelection)
  }

  func test_topicItemTapped_emitsMoveToFilterWithTopic() async {
    let award = Award(id: UUID(), name: "2024 대한민국 주류대상", year: 2024, type: "korea_award")
    let store = TestStore(initialState: HomeCore.State()) {
      HomeCore()
    }

    await store.send(.topicItemTapped(award))
    await store.receive(\.moveToFilterWithTopic)
  }

  func test_newReleaseItemTapped_emitsMoveToInformation() async {
    let store = TestStore(initialState: HomeCore.State()) {
      HomeCore()
    }

    await store.send(.newReleaseItemTapped(Self.sampleMakgeolli))
    await store.receive(\.moveToInformation)
  }

  func test_randomMakgeolliItemTapped_emitsMoveToInformation() async {
    let store = TestStore(initialState: HomeCore.State()) {
      HomeCore()
    }

    await store.send(.randomMakgeolliItemTapped(Self.sampleMakgeolli))
    await store.receive(\.moveToInformation)
  }

  func test_topLikedItemTapped_emitsMoveToInformation() async {
    let store = TestStore(initialState: HomeCore.State()) {
      HomeCore()
    }

    await store.send(.topLikedItemTapped(Self.sampleMakgeolli))
    await store.receive(\.moveToInformation)
  }

  // MARK: - onAppear idempotency

  func test_onAppear_whenAlreadyInitialized_isNoop() async {
    var state = HomeCore.State()
    state.isInitialized = true

    let store = TestStore(initialState: state) {
      HomeCore()
    }

    await store.send(.onAppear)
    // 추가 effect 없음 — 초기화 완료 상태에서 onAppear는 no-op
  }

  // MARK: - Failure paths

  func test_newReleasesResponseFailure_clearsLoadingAndLogsError() async {
    var state = HomeCore.State()
    state.isLoadingNewReleases = true
    let store = TestStore(initialState: state) { HomeCore() }
    let error = NSError(domain: "test", code: -1)

    await store.send(.newReleasesResponse(.failure(error))) {
      $0.isLoadingNewReleases = false
    }
    await store.receive(\.logError)
  }

  func test_awardsResponseFailure_clearsLoadingAndLogsError() async {
    var state = HomeCore.State()
    state.isLoadingAwards = true
    let store = TestStore(initialState: state) { HomeCore() }
    let error = NSError(domain: "test", code: -1)

    await store.send(.awardsResponse(.failure(error))) {
      $0.isLoadingAwards = false
    }
    await store.receive(\.logError)
  }

  func test_newReleasesResponseSuccessEmpty_clearsLoading() async {
    var state = HomeCore.State()
    state.isLoadingNewReleases = true
    let store = TestStore(initialState: state) { HomeCore() }

    await store.send(.newReleasesResponse(.success([]))) {
      $0.isLoadingNewReleases = false
      $0.newReleases = []
    }
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
