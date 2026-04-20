import Foundation
import UIKit
import StoreKit

import Core

import ComposableArchitecture

extension InformationCore {
  func handleOnAppear(_ state: State) -> Effect<Action> {
    Amp.track(event: "makgeolli_detail_viewed", properties: [
      "makgeolli_name": state.makgeolli.name
    ])
    let myMakgeolliClient = self.myMakgeolliClient
    let makgeolli = state.makgeolli

    return .merge(
      .run { send in
        do {
          let isFavorite = try await myMakgeolliClient.isFavorite(makgeolli.id)
          await send(.updateFavoriteStatus(isFavorite))
        } catch {
          await send(.updateFavoriteStatus(false))
          await send(.logError(InformationCoreError(
            code: .failToCheckFavoriteStatus,
            underlying: error
          )))
        }
      },
      .send(.loadReaction),
      .send(.loadReactionCounts),
      .send(.loadUserComment),
      .send(.loadPublicComments)
    )
  }

  func handleFavoriteButtonTapped(_ state: State) -> Effect<Action> {
    let newFavoriteStatus = !state.isFavorite
    Amp.track(event: "favorite_button_clicked", properties: [
      "makgeolli_name": state.makgeolli.name,
      "favorite_status": newFavoriteStatus ? "added" : "removed"
    ])

    let myMakgeolliClient = self.myMakgeolliClient
    let makgeolli = state.makgeolli
    return .run { send in
      await myMakgeolliClient.toggleFavorite(makgeolli)
      do {
        let isFavorite = try await myMakgeolliClient.isFavorite(makgeolli.id)
        await send(.updateFavoriteStatus(isFavorite))
      } catch {
        await send(.logError(InformationCoreError(
          code: .failToUpdateFavoriteStatus,
          underlying: error
        )))
      }
    }
  }

  func loadReactionEffect(makgeolliId: UUID) -> Effect<Action> {
    let client = makgeolliReactionClient
    return .run { send in
      do {
        let reaction = try await client.getReaction(makgeolliId)
        await send(.updateReactionState(reaction?.reactionType))
      } catch {
        await send(.logError(InformationCoreError(
          code: .failToLoadReaction,
          underlying: error
        )))
      }
    }
  }

  func saveReactionEffect(
    makgeolliId: UUID, reactionType: String?
  ) -> Effect<Action> {
    let client = makgeolliReactionClient
    let supabaseClient = self.supabaseClient
    let userId = getUserID()
    return .run { send in
      do {
        try await client.saveReaction(makgeolliId, reactionType)
        if let reactionType = reactionType {
          try await supabaseClient.saveReaction(userId, makgeolliId, reactionType)
        } else {
          try await supabaseClient.deleteReaction(userId, makgeolliId)
        }
        await send(.reactionSaved)
        await send(.loadReactionCounts)
      } catch {
        await send(.logError(InformationCoreError(
          code: .failToSaveReaction,
          underlying: error
        )))
      }
    }
  }

  func loadReactionCountsEffect(makgeolliId: UUID) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let counts = try await supabaseClient.getReactionCounts(makgeolliId)
        await send(.updateReactionCounts(counts))
      } catch {
        await send(.logError(InformationCoreError(
          code: .failToLoadReactionCounts,
          underlying: error
        )))
      }
    }
  }

  func loadUserCommentEffect(makgeolliId: UUID) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    let userId = getUserID()
    return .run { send in
      do {
        let userComment = try await supabaseClient.getUserComment(userId, makgeolliId)
        await send(.updateUserComment(userComment))
      } catch {
        await send(.logError(InformationCoreError(
          code: .failToLoadUserComment,
          underlying: error
        )))
      }
    }
  }

  func saveCommentEffect(
    makgeolliId: UUID, comment: String, isPublic: Bool
  ) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    let userId = getUserID()
    return .run { send in
      do {
        try await supabaseClient.saveUserComment(userId, makgeolliId, comment, isPublic)
        await send(.commentSaved)
      } catch {
        await send(.logError(InformationCoreError(
          code: .failToSaveUserComment,
          underlying: error
        )))
      }
    }
  }

  func deleteCommentEffect(makgeolliId: UUID) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    let userId = getUserID()
    return .run { send in
      do {
        try await supabaseClient.deleteUserComment(userId, makgeolliId)
        await send(.commentDeleted)
      } catch {
        await send(.logError(InformationCoreError(
          code: .failToDeleteUserComment,
          underlying: error
        )))
      }
    }
  }

  func loadPublicCommentsEffect(makgeolliId: UUID) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let publicComments = try await supabaseClient.getPublicComments(makgeolliId)
        await send(.updatePublicComments(publicComments))
      } catch {
        await send(.logError(InformationCoreError(
          code: .failToLoadPublicComments,
          underlying: error
        )))
      }
    }
  }

  func loadUserReactionsEffect(
    userIds: [UUID], makgeolliId: UUID
  ) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      var reactions: [UUID: String] = [:]
      for userId in userIds {
        do {
          if let reactionType = try await supabaseClient.getUserReaction(userId, makgeolliId) {
            reactions[userId] = reactionType
          }
        } catch {
          // 개별 유저 조회 실패는 무시 — 전체 반영 시도
        }
      }
      await send(.updateUserReactions(reactions))
    }
  }

  func commentSavedEffect() -> Effect<Action> {
    .merge(
      .send(.loadUserComment),
      .send(.loadPublicComments),
      .send(.showCommentSheet(false)),
      .send(.showEditActionSheet(false)),
      .send(.requestAppReviewIfNeeded),
      .run { _ in
        await MainActor.run {
          NotificationCenter.default.post(name: .myMakgeolliDataChanged, object: nil)
        }
        try await Task.sleep(for: .milliseconds(500))
        await MainActor.run {
          NotificationCenter.default.post(name: .recentCommentsChanged, object: nil)
        }
      }
    )
  }

  func commentDeletedEffect() -> Effect<Action> {
    .merge(
      .send(.loadUserComment),
      .send(.loadPublicComments),
      .send(.showDeleteAlert(false)),
      .send(.showEditActionSheet(false)),
      .run { _ in
        await MainActor.run {
          NotificationCenter.default.post(name: .myMakgeolliDataChanged, object: nil)
          NotificationCenter.default.post(name: .recentCommentsChanged, object: nil)
        }
      }
    )
  }

  func requestAppReviewEffect() -> Effect<Action> {
    let hasRequested = (try? userDefaultsClient.bool(.hasRequestedAppReview)) ?? false
    guard !hasRequested else { return .none }

    let userDefaultsClient = self.userDefaultsClient
    return .run { _ in
      await MainActor.run {
        let currentCount = (try? userDefaultsClient.integer(.interactionCount)) ?? 0
        let newCount = currentCount + 1
        userDefaultsClient.set(.interactionCount, newCount)

        if newCount >= 10 {
          userDefaultsClient.set(.hasRequestedAppReview, true)
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
              SKStoreReviewController.requestReview(in: scene)
            }
          }
        }
      }
    }
  }

  func dispatchLogError(_ error: InformationCoreError) -> Effect<Action> {
    let message = getErrorMessage(for: error.code)
    return .merge(
      .run { _ in Log.error(error) },
      .run { _ in
        NotificationCenter.default.post(
          name: .showToast,
          object: nil,
          userInfo: ["message": message, "type": "error"]
        )
      }
    )
  }
}
