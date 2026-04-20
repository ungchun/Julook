import XCTest

import ComposableArchitecture

@testable import Core
@testable import FeatureHome

@MainActor
final class CommentListCoreTests: XCTestCase {

  // MARK: - onAppear

  func test_onAppear_whenEmptyAndNotLoading_triggersFetchAndResolvesEmpty() async {
    let store = TestStore(initialState: CommentListCore.State()) {
      CommentListCore()
    } withDependencies: {
      $0.supabaseClient.getRecentCommentsPaginated = { _, _ in [] }
    }

    await store.send(.onAppear)
    await store.receive(\.fetchCommentedMakgeollis) {
      $0.isLoading = true
    }
    await store.receive(\.commentedMakgeollisResponse) {
      $0.isLoading = false
      $0.commentedMakgeollis = []
      $0.currentPage = 1
      $0.hasMoreData = false
    }
  }

  func test_onAppear_whenAlreadyHasComments_isNoop() async {
    var state = CommentListCore.State()
    state.commentedMakgeollis = [Self.sampleComment]
    let store = TestStore(initialState: state) { CommentListCore() }

    await store.send(.onAppear)
    // 이미 로드된 상태에서는 fetch를 재호출하지 않음 — 추가 effect 없음
  }

  // MARK: - Dismiss

  func test_dismiss_isNoop() async {
    let store = TestStore(initialState: CommentListCore.State()) { CommentListCore() }

    await store.send(.dismiss)
    // coordinator에서 처리되므로 Reducer는 .none
  }

  // MARK: - Initial fetch response

  func test_commentedMakgeollisResponseFailure_clearsLoadingAndLogsError() async {
    var state = CommentListCore.State()
    state.isLoading = true
    let store = TestStore(initialState: state) { CommentListCore() }
    let error = NSError(domain: "test", code: -1)

    await store.send(.commentedMakgeollisResponse(.failure(error))) {
      $0.isLoading = false
    }
    await store.receive(\.logError)
  }

  // MARK: - Pagination guards

  func test_loadMoreComments_whenHasMoreDataFalse_isNoop() async {
    var state = CommentListCore.State()
    state.hasMoreData = false
    let store = TestStore(initialState: state) { CommentListCore() }

    await store.send(.loadMoreComments)
    // 더 가져올 페이지가 없으면 effect 발생 없음
  }

  func test_loadMoreCommentsResponseSuccessEmpty_appendsAndAdvancesPage() async {
    var state = CommentListCore.State()
    state.isLoadingMore = true
    state.commentedMakgeollis = [Self.sampleComment]
    state.currentPage = 1
    let store = TestStore(initialState: state) { CommentListCore() }

    await store.send(.loadMoreCommentsResponse(.success([]))) {
      $0.isLoadingMore = false
      $0.currentPage = 2
      $0.hasMoreData = false
    }
  }

  // MARK: - Secondary state transitions

  func test_updateUserReaction_setsReaction() async {
    let commentId = UUID()
    let store = TestStore(initialState: CommentListCore.State()) { CommentListCore() }

    await store.send(.updateUserReaction(commentId: commentId, "like")) {
      $0.userReactions = [commentId: "like"]
    }
  }

  func test_commentItemTapped_withoutMakgeolliInfo_isNoop() async {
    let store = TestStore(initialState: CommentListCore.State()) { CommentListCore() }

    await store.send(.commentItemTapped(Self.sampleComment))
    // makgeolliInfo 가 비어있으면 moveToInformation 으로 전이하지 않음
  }

  // MARK: - Helpers

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
