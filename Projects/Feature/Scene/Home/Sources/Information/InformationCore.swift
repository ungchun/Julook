import Foundation

import Core
import DesignSystem

import ComposableArchitecture

@Reducer
public struct InformationCore: Sendable {
  @ObservableState
  public struct State: Equatable {
    public var makgeolli: Makgeolli
    public var makgeolliImage: URL?
    public var likeButtonState: ReactionButtonState = .active
    public var dislikeButtonState: ReactionButtonState = .active
    public var isFavorite: Bool = false
    public var currentReaction: String? = nil
    public var reactionCounts: MakgeolliReactionCount? = nil
    public var userComment: UserComment? = nil
    public var isShowingCommentSheet: Bool = false
    public var isShowingEditActionSheet: Bool = false
    public var isShowingDeleteAlert: Bool = false
    public var isShowingCommentsSheet: Bool = false
    public var publicComments: [UserComment] = []
    public var userReactions: [UUID: String] = [:]

    public init(makgeolli: Makgeolli, makgeolliImage: URL? = nil) {
      self.makgeolli = makgeolli
      self.makgeolliImage = makgeolliImage
    }
  }

  public enum Action {
    case onAppear

    case dismiss
    case likeButtonTapped
    case dislikeButtonTapped
    case favoriteButtonTapped
    case updateFavoriteStatus(Bool)
    case favoriteStatusChanged

    case loadReaction
    case updateReaction(String?)
    case updateReactionState(String?)
    case reactionSaved
    case reactionStatusChanged

    case loadReactionCounts
    case updateReactionCounts(MakgeolliReactionCount?)

    case commentSectionTapped
    case showCommentSheet(Bool)
    case showEditActionSheet(Bool)
    case showDeleteAlert(Bool)
    case showCommentsSheet(Bool)
    case confirmDelete
    case loadUserComment
    case updateUserComment(UserComment?)
    case saveComment(String, Bool)
    case commentSaved
    case deleteComment
    case commentDeleted

    case loadPublicComments
    case updatePublicComments([UserComment])
    case loadUserReactions([UUID])
    case updateUserReactions([UUID: String])

    case requestAppReviewIfNeeded

    case logError(InformationCoreError)
    case showToast(String, ToastType)
  }

  public init() { }

  @Dependency(\.myMakgeolliClient) var myMakgeolliClient
  @Dependency(\.makgeolliReactionClient) var makgeolliReactionClient
  @Dependency(\.supabaseClient) var supabaseClient
  @Dependency(\.userDefaultsClient) var userDefaultsClient

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return handleOnAppear(state)

      case .dismiss:
        return .none

      case .likeButtonTapped:
        let newReaction = state.currentReaction == "like" ? nil : "like"
        Amp.track(event: "like_button_clicked", properties: [
          "makgeolli_name": state.makgeolli.name,
          "reaction_type": newReaction ?? "removed"
        ])
        return .send(.updateReaction(newReaction))

      case .dislikeButtonTapped:
        let newReaction = state.currentReaction == "dislike" ? nil : "dislike"
        Amp.track(event: "dislike_button_clicked", properties: [
          "makgeolli_name": state.makgeolli.name,
          "reaction_type": newReaction ?? "removed"
        ])
        return .send(.updateReaction(newReaction))

      case .favoriteButtonTapped:
        return handleFavoriteButtonTapped(state)

      case let .updateFavoriteStatus(isFavorite):
        let previousStatus = state.isFavorite
        state.isFavorite = isFavorite
        return previousStatus != isFavorite ? .send(.favoriteStatusChanged) : .none

      case .favoriteStatusChanged:
        return .none

      case .loadReaction:
        return loadReactionEffect(makgeolliId: state.makgeolli.id)

      case let .updateReaction(reactionType):
        applyReactionState(&state, reactionType: reactionType)
        return saveReactionEffect(
          makgeolliId: state.makgeolli.id, reactionType: reactionType
        )

      case let .updateReactionState(reactionType):
        applyReactionState(&state, reactionType: reactionType)
        return .none

      case .reactionSaved:
        return .merge(
          .send(.reactionStatusChanged),
          .send(.requestAppReviewIfNeeded)
        )

      case .reactionStatusChanged:
        return .none

      case .loadReactionCounts:
        return loadReactionCountsEffect(makgeolliId: state.makgeolli.id)

      case let .updateReactionCounts(reactionCounts):
        state.reactionCounts = reactionCounts
        return .none

      case .commentSectionTapped:
        Amp.track(event: "comment_section_tapped", properties: [
          "makgeolli_name": state.makgeolli.name
        ])
        return state.userComment != nil
          ? .send(.showEditActionSheet(true))
          : .send(.showCommentSheet(true))

      case let .showCommentSheet(isShowing):
        state.isShowingCommentSheet = isShowing
        return .none

      case let .showEditActionSheet(isShowing):
        state.isShowingEditActionSheet = isShowing
        return .none

      case let .showDeleteAlert(isShowing):
        state.isShowingDeleteAlert = isShowing
        return .none

      case let .showCommentsSheet(isShowing):
        state.isShowingCommentsSheet = isShowing
        return .none

      case .confirmDelete:
        return .send(.deleteComment)

      case .loadUserComment:
        return loadUserCommentEffect(makgeolliId: state.makgeolli.id)

      case let .updateUserComment(userComment):
        state.userComment = userComment
        return .none

      case let .saveComment(comment, isPublic):
        Amp.track(event: "comment_saved", properties: [
          "makgeolli_name": state.makgeolli.name,
          "is_public": isPublic
        ])
        return saveCommentEffect(
          makgeolliId: state.makgeolli.id, comment: comment, isPublic: isPublic
        )

      case .commentSaved:
        return commentSavedEffect()

      case .deleteComment:
        Amp.track(event: "comment_deleted", properties: [
          "makgeolli_name": state.makgeolli.name
        ])
        return deleteCommentEffect(makgeolliId: state.makgeolli.id)

      case .commentDeleted:
        return commentDeletedEffect()

      case .loadPublicComments:
        return loadPublicCommentsEffect(makgeolliId: state.makgeolli.id)

      case let .updatePublicComments(publicComments):
        state.publicComments = publicComments
        return .send(.loadUserReactions(publicComments.map { $0.userId }))

      case let .loadUserReactions(userIds):
        return loadUserReactionsEffect(
          userIds: userIds, makgeolliId: state.makgeolli.id
        )

      case let .updateUserReactions(userReactions):
        state.userReactions = userReactions
        return .none

      case .requestAppReviewIfNeeded:
        return requestAppReviewEffect()

      case let .logError(error):
        return dispatchLogError(error)

      case .showToast:
        return .none
      }
    }
  }
}
