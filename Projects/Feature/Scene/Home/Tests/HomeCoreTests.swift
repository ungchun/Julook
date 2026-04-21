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

  // MARK: - Translation response

  func test_translationsResponse_success_storesByMakgeolliId() async {
    let store = TestStore(initialState: HomeCore.State()) { HomeCore() }
    let id1 = UUID()
    let id2 = UUID()
    let t1 = MakgeolliTranslation(
      makgeolliId: id1, locale: "en", name: "A",
      brewery: nil, awards: nil, ingredients: nil, description: nil
    )
    let t2 = MakgeolliTranslation(
      makgeolliId: id2, locale: "en", name: "B",
      brewery: nil, awards: nil, ingredients: nil, description: nil
    )

    await store.send(.translationsResponse(.success([t1, t2]))) {
      $0.translationsByMakgeolliId = [id1: t1, id2: t2]
    }
  }

  func test_translationsResponse_failure_emitsLogError() async {
    let store = TestStore(initialState: HomeCore.State()) { HomeCore() }
    let error = NSError(domain: "test", code: -1)

    await store.send(.translationsResponse(.failure(error)))
    await store.receive(\.logError)
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

  // MARK: - Image response success

  func test_newReleasesImageResponse_success_setsImageMap() async {
    let store = TestStore(initialState: HomeCore.State()) { HomeCore() }
    let id = UUID()
    let url = URL(string: "https://example.com/a.png")!

    await store.send(.newReleasesImageResponse(id: id, .success(url))) {
      $0.newReleasesImages[id] = url
    }
  }

  func test_randomMakgeolliImageResponse_success_setsImageMap() async {
    let store = TestStore(initialState: HomeCore.State()) { HomeCore() }
    let id = UUID()
    let url = URL(string: "https://example.com/a.png")!

    await store.send(.randomMakgeolliImageResponse(id: id, .success(url))) {
      $0.randomMakgeolliImages[id] = url
    }
  }

  func test_topLikedImageResponse_success_setsImageMap() async {
    let store = TestStore(initialState: HomeCore.State()) { HomeCore() }
    let id = UUID()
    let url = URL(string: "https://example.com/a.png")!

    await store.send(.topLikedImageResponse(id: id, .success(url))) {
      $0.topLikedImages[id] = url
    }
  }

  func test_recentCommentImageResponse_success_setsImageMap() async {
    let store = TestStore(initialState: HomeCore.State()) { HomeCore() }
    let id = UUID()
    let url = URL(string: "https://example.com/a.png")!

    await store.send(.recentCommentImageResponse(id: id, .success(url))) {
      $0.recentCommentImages[id] = url
    }
  }

  // MARK: - Favorite & reaction updates

  func test_updateTopLikedFavoriteStatus_setsMap() async {
    let store = TestStore(initialState: HomeCore.State()) { HomeCore() }
    let id = UUID()

    await store.send(.updateTopLikedFavoriteStatus(id: id, true)) {
      $0.topLikedFavoriteStatus[id] = true
    }
  }

  func test_updateRecentCommentReaction_setsMap() async {
    let store = TestStore(initialState: HomeCore.State()) { HomeCore() }
    let commentId = UUID()

    await store.send(.updateRecentCommentReaction(commentId: commentId, "like")) {
      $0.recentCommentReactions[commentId] = "like"
    }
  }

  // MARK: - Navigation actions are no-op in Reducer

  func test_moveToCommentList_isNoop() async {
    let store = TestStore(initialState: HomeCore.State()) { HomeCore() }
    await store.send(.moveToCommentList)
  }

  func test_showToast_isNoop() async {
    let store = TestStore(initialState: HomeCore.State()) { HomeCore() }
    await store.send(.showToast("msg", .error))
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
