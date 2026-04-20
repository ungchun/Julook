import Foundation

import Core

import ComposableArchitecture

extension MyMakgeolliCore {
  func loadReactionDataEffect() -> Effect<Action> {
    let myMakgeolliClient = self.myMakgeolliClient
    let makgeolliReactionClient = self.makgeolliReactionClient
    let supabaseClient = self.supabaseClient
    let userId = getUserID()

    return .run { send in
      do {
        let result = try await MyMakgeolliAggregator.aggregate(
          myMakgeolliClient: myMakgeolliClient,
          reactionClient: makgeolliReactionClient,
          supabaseClient: supabaseClient,
          userId: userId
        )
        await send(.updateAllData(
          result.all,
          result.liked,
          result.disliked,
          result.favorites,
          result.comments
        ))
      } catch {
        await send(.logError(MyMakgeolliCoreError(
          code: .failToFetchReactionData,
          underlying: error
        )))
      }
    }
  }

  func loadMakgeolliImagesEffect(_ makgeollis: [MyMakgeolliEntity]) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      await withTaskGroup(of: Void.self) { group in
        for makgeolli in makgeollis {
          group.addTask {
            guard let imageName = makgeolli.imageName else { return }
            do {
              let fileName = imageName.hasSuffix(".png") ? imageName : "\(imageName).png"
              let url = try await supabaseClient.getPublicURL(Bucket.MAKGEOLLIIMAGE, fileName)
              await send(.updateMakgeolliImage(makgeolli.id, url))
            } catch {
              await send(.logError(MyMakgeolliCoreError(
                code: .failToFetchImage,
                underlying: error
              )))
            }
          }
        }
      }
    }
  }

  func fetchMakgeolliDetailEffect(_ entity: MyMakgeolliEntity) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let full = try await supabaseClient.fetchMakgeolliById(entity.id)
        await send(.fetchMakgeolliResponse(entity, .success(full)))
      } catch {
        await send(.fetchMakgeolliResponse(entity, .failure(error)))
      }
    }
  }

  func dispatchLogError(_ error: MyMakgeolliCoreError) -> Effect<Action> {
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

// MARK: - Aggregator

struct MyMakgeolliAggregated {
  let all: [MyMakgeolliEntity]
  let liked: [MyMakgeolliEntity]
  let disliked: [MyMakgeolliEntity]
  let favorites: [MyMakgeolliEntity]
  let comments: [MyMakgeolliEntity]
}

enum MyMakgeolliAggregator {
  static func aggregate(
    myMakgeolliClient: MyMakgeolliClient,
    reactionClient: MakgeolliReactionClient,
    supabaseClient: SupabaseClient,
    userId: UUID
  ) async throws -> MyMakgeolliAggregated {
    let favorites = try await myMakgeolliClient.getMyMakgeollis()
    let allReactions = try await reactionClient.getAllReactions()
    let userComments = try await supabaseClient.getUserComments(userId)

    var allMap: [UUID: MyMakgeolliEntity] = [:]
    for makgeolli in favorites { allMap[makgeolli.id] = makgeolli }

    let latestReactions = latestByMakgeolliId(allReactions)
    var likedMap: [UUID: MyMakgeolliEntity] = [:]
    var dislikedMap: [UUID: MyMakgeolliEntity] = [:]

    for (makgeolliId, reaction) in latestReactions {
      guard let reactionType = reaction.reactionType else { continue }
      let entity = try await resolveEntity(
        makgeolliId: makgeolliId,
        reaction: reaction,
        allMap: allMap,
        client: supabaseClient
      )
      guard let entity = entity else { continue }
      allMap[makgeolliId] = entity
      if reactionType == "like" { likedMap[makgeolliId] = entity }
      else if reactionType == "dislike" { dislikedMap[makgeolliId] = entity }
    }

    let commentMakgeollis = try await appendComments(
      comments: userComments, allMap: &allMap, client: supabaseClient
    )

    let sorted: ([MyMakgeolliEntity]) -> [MyMakgeolliEntity] = {
      $0.sorted { $0.updatedAt > $1.updatedAt }
    }

    return MyMakgeolliAggregated(
      all: sorted(Array(allMap.values)),
      liked: sorted(Array(likedMap.values)),
      disliked: sorted(Array(dislikedMap.values)),
      favorites: sorted(favorites),
      comments: sorted(commentMakgeollis)
    )
  }

  private static func latestByMakgeolliId(
    _ reactions: [MakgeolliReactionEntity]
  ) -> [UUID: MakgeolliReactionEntity] {
    var latest: [UUID: MakgeolliReactionEntity] = [:]
    for reaction in reactions {
      if let existing = latest[reaction.makgeolliId], reaction.updatedAt <= existing.updatedAt {
        continue
      }
      latest[reaction.makgeolliId] = reaction
    }
    return latest
  }

  private static func resolveEntity(
    makgeolliId: UUID,
    reaction: MakgeolliReactionEntity,
    allMap: [UUID: MyMakgeolliEntity],
    client: SupabaseClient
  ) async throws -> MyMakgeolliEntity? {
    if let favorite = allMap[makgeolliId] {
      return MyMakgeolliEntity(
        id: favorite.id, name: favorite.name,
        imageName: favorite.imageName, feedback: favorite.feedback,
        isFavorite: favorite.isFavorite, comment: favorite.comment,
        createdAt: reaction.createdAt, updatedAt: reaction.updatedAt
      )
    }
    do {
      guard let info = try await client.fetchMakgeolliById(makgeolliId) else { return nil }
      return MyMakgeolliEntity(
        id: info.id, name: info.name,
        imageName: info.imageName, feedback: nil,
        isFavorite: false, comment: nil,
        createdAt: reaction.createdAt, updatedAt: reaction.updatedAt
      )
    } catch {
      return nil
    }
  }

  private static func appendComments(
    comments: [UserComment],
    allMap: inout [UUID: MyMakgeolliEntity],
    client: SupabaseClient
  ) async throws -> [MyMakgeolliEntity] {
    var commentMakgeollis: [MyMakgeolliEntity] = []
    for comment in comments {
      if let existing = allMap[comment.makgeolliId] {
        commentMakgeollis.append(existing)
        continue
      }
      do {
        guard let info = try await client.fetchMakgeolliById(comment.makgeolliId) else { continue }
        let entity = MyMakgeolliEntity(
          id: info.id, name: info.name,
          imageName: info.imageName, feedback: nil,
          isFavorite: false, comment: comment.comment,
          createdAt: comment.createdAt, updatedAt: comment.updatedAt
        )
        commentMakgeollis.append(entity)
        allMap[comment.makgeolliId] = entity
      } catch {
        // 개별 조회 실패는 무시
      }
    }
    return commentMakgeollis
  }
}
