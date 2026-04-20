import XCTest

import ComposableArchitecture

@testable import Core
@testable import FeatureHome

@MainActor
final class InformationCoreTests: XCTestCase {

  // MARK: - Sheet toggles

  func test_showCommentSheet_setsTrue() async {
    let store = makeStore()

    await store.send(.showCommentSheet(true)) {
      $0.isShowingCommentSheet = true
    }
  }

  func test_showEditActionSheet_setsTrue() async {
    let store = makeStore()

    await store.send(.showEditActionSheet(true)) {
      $0.isShowingEditActionSheet = true
    }
  }

  func test_showDeleteAlert_setsTrue() async {
    let store = makeStore()

    await store.send(.showDeleteAlert(true)) {
      $0.isShowingDeleteAlert = true
    }
  }

  func test_showCommentsSheet_setsTrue() async {
    let store = makeStore()

    await store.send(.showCommentsSheet(true)) {
      $0.isShowingCommentsSheet = true
    }
  }

  // MARK: - Dismiss

  func test_dismiss_isNoop() async {
    let store = makeStore()

    await store.send(.dismiss)
    // coordinator에서 처리되므로 Reducer는 .none
  }

  // MARK: - Favorite status

  func test_updateFavoriteStatus_toTrue_emitsChanged() async {
    let store = makeStore()

    await store.send(.updateFavoriteStatus(true)) {
      $0.isFavorite = true
    }
    await store.receive(\.favoriteStatusChanged)
  }

  func test_updateFavoriteStatus_sameValue_doesNotEmitChanged() async {
    // 기본값 isFavorite == false 에서 false 전달 → 변화 없음, effect 없음
    let store = makeStore()

    await store.send(.updateFavoriteStatus(false))
  }

  // MARK: - Public comments

  func test_updatePublicComments_setsListAndLoadsReactions() async {
    let comment = Self.sampleComment
    let store = TestStore(
      initialState: InformationCore.State(
        makgeolli: Self.sampleMakgeolli,
        makgeolliImage: nil
      )
    ) {
      InformationCore()
    } withDependencies: {
      $0.supabaseClient.getUserReaction = { _, _ in "like" }
    }

    await store.send(.updatePublicComments([comment])) {
      $0.publicComments = [comment]
    }
    await store.receive(\.loadUserReactions)
    await store.receive(\.updateUserReactions) {
      $0.userReactions = [comment.userId: "like"]
    }
  }

  // MARK: - Helpers

  private func makeStore() -> TestStoreOf<InformationCore> {
    TestStore(
      initialState: InformationCore.State(
        makgeolli: Self.sampleMakgeolli,
        makgeolliImage: nil
      )
    ) {
      InformationCore()
    }
  }

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

  private static let sampleComment = UserComment(
    id: UUID(),
    userId: UUID(),
    makgeolliId: UUID(),
    comment: "맛있어요",
    isPublic: true,
    createdAt: Date(),
    updatedAt: Date()
  )
}
