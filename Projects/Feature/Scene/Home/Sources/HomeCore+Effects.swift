import Foundation

import Core

import ComposableArchitecture

extension HomeCore {
  func handleOnAppear(_ state: inout State) -> Effect<Action> {
    if state.isInitialized { return .none }
    state.isInitialized = true

    let loading = state.isLoadingNewReleases
      || state.isLoadingRandomMakgeollis
      || state.isLoadingAwards
      || state.isLoadingTopLiked
      || state.isLoadingRecentComments
    guard !loading else { return .none }

    return .merge(
      .send(.fetchNewReleases),
      .send(.fetchRandomMakgeollis),
      .send(.fetchAwards),
      .send(.fetchTopLikedMakgeollis),
      .send(.fetchRecentComments),
      .run { send in
        for await _ in NotificationCenter.default.notifications(
          named: .recentCommentsChanged
        ) {
          await send(.recentCommentsChangedNotification)
        }
      }
    )
  }

  func handleToggleTopLikedFavorite(makgeolli: Makgeolli) -> Effect<Action> {
    Amp.track(event: "top_liked_favorite_clicked", properties: [
      "makgeolli_name": makgeolli.name,
      "favorite_status": "toggle"
    ])
    let myMakgeolliClient = self.myMakgeolliClient
    return .run { send in
      await myMakgeolliClient.toggleFavorite(makgeolli)
      do {
        let isFavorite = try await myMakgeolliClient.isFavorite(makgeolli.id)
        await send(.updateTopLikedFavoriteStatus(id: makgeolli.id, isFavorite))
      } catch {
        await send(.logError(HomeCoreError(
          code: .failToUpdateFavoriteStatus,
          underlying: error
        )))
      }
    }
  }

  func fetchNewReleasesEffect() -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let makgeollis = try await supabaseClient.fetchNewReleases()
        await send(.newReleasesResponse(.success(makgeollis)))
      } catch {
        await send(.newReleasesResponse(.failure(error)))
      }
    }
  }

  func fetchRandomMakgeollisEffect() -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let makgeollis = try await supabaseClient.fetchRandomMakgeollis()
        await send(.randomMakgeollisResponse(.success(makgeollis)))
      } catch {
        await send(.randomMakgeollisResponse(.failure(error)))
      }
    }
  }

  func fetchAwardsEffect() -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let awards = try await supabaseClient.fetchAwards()
        await send(.awardsResponse(.success(awards)))
      } catch {
        await send(.awardsResponse(.failure(error)))
      }
    }
  }

  func fetchTopLikedMakgeollisEffect() -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let makgeollis = try await supabaseClient.fetchTopLikedMakgeollis()
        await send(.topLikedMakgeollisResponse(.success(makgeollis)))
      } catch {
        await send(.topLikedMakgeollisResponse(.failure(error)))
      }
    }
  }

  func fetchRecentCommentsEffect() -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let comments = try await supabaseClient.getRecentComments()
        await send(.recentCommentsResponse(.success(comments)))
      } catch {
        await send(.recentCommentsResponse(.failure(error)))
      }
    }
  }

  func fetchImageEffect(
    makgeolli: Makgeolli,
    responseAction: @escaping @Sendable (UUID, TaskResult<URL>) -> Action
  ) -> Effect<Action> {
    guard let imageName = makgeolli.imageName else {
      return .none
    }
    let supabaseClient = self.supabaseClient
    let id = makgeolli.id
    return .run { send in
      do {
        let fileName = imageName.hasSuffix(".png") ? imageName : "\(imageName).png"
        let url = try await supabaseClient.getPublicURL(Bucket.MAKGEOLLIIMAGE, fileName)
        await send(responseAction(id, .success(url)))
      } catch {
        await send(responseAction(id, .failure(error)))
      }
    }
  }

  func loadTopLikedFavoriteStatusEffect(makgeolli: Makgeolli) -> Effect<Action> {
    let myMakgeolliClient = self.myMakgeolliClient
    let id = makgeolli.id
    return .run { send in
      do {
        let isFavorite = try await myMakgeolliClient.isFavorite(id)
        await send(.updateTopLikedFavoriteStatus(id: id, isFavorite))
      } catch {
        await send(.updateTopLikedFavoriteStatus(id: id, false))
      }
    }
  }

  func fetchRecentCommentMakgeolliEffect(comment: UserComment) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let makgeolli = try await supabaseClient.fetchMakgeolliById(comment.makgeolliId)
        await send(.recentCommentMakgeolliResponse(comment, .success(makgeolli)))
      } catch {
        await send(.recentCommentMakgeolliResponse(comment, .failure(error)))
      }
    }
  }

  func loadRecentCommentReactionEffect(comment: UserComment) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let reactionType = try await supabaseClient.getUserReaction(
          comment.userId, comment.makgeolliId
        )
        await send(.updateRecentCommentReaction(commentId: comment.id, reactionType))
      } catch {
        await send(.updateRecentCommentReaction(commentId: comment.id, nil))
      }
    }
  }

  func logErrorEffect(code: HomeCoreError.Code, error: Error) -> Effect<Action> {
    .send(.logError(HomeCoreError(code: code, underlying: error)))
  }

  func dispatchLogError(_ error: HomeCoreError) -> Effect<Action> {
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
