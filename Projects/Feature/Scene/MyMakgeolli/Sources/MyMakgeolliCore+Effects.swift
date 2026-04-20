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
        let favoriteMakgeollis = try await myMakgeolliClient.getMyMakgeollis()
        let allReactions = try await makgeolliReactionClient.getAllReactions()
        let userComments = try await supabaseClient.getUserComments(userId)

        var allMakgeollisMap: [UUID: MyMakgeolliEntity] = [:]
        for makgeolli in favoriteMakgeollis {
          allMakgeollisMap[makgeolli.id] = makgeolli
        }

        // 각 막걸리의 가장 최신 reaction만 사용
        var latestReactions: [UUID: MakgeolliReactionEntity] = [:]
        for reaction in allReactions {
          if let existing = latestReactions[reaction.makgeolliId] {
            if reaction.updatedAt > existing.updatedAt {
              latestReactions[reaction.makgeolliId] = reaction
            }
          } else {
            latestReactions[reaction.makgeolliId] = reaction
          }
        }

        var likedMap: [UUID: MyMakgeolliEntity] = [:]
        var dislikedMap: [UUID: MyMakgeolliEntity] = [:]

        for (makgeolliId, reaction) in latestReactions {
          guard let reactionType = reaction.reactionType else { continue }

          if let favorite = allMakgeollisMap[makgeolliId] {
            let updated = MyMakgeolliEntity(
              id: favorite.id,
              name: favorite.name,
              imageName: favorite.imageName,
              feedback: favorite.feedback,
              isFavorite: favorite.isFavorite,
              comment: favorite.comment,
              createdAt: reaction.createdAt,
              updatedAt: reaction.updatedAt
            )
            allMakgeollisMap[makgeolliId] = updated

            if reactionType == "like" {
              likedMap[makgeolliId] = updated
            } else if reactionType == "dislike" {
              dislikedMap[makgeolliId] = updated
            }
          } else {
            do {
              if let info = try await supabaseClient.fetchMakgeolliById(makgeolliId) {
                let entity = MyMakgeolliEntity(
                  id: info.id,
                  name: info.name,
                  imageName: info.imageName,
                  feedback: nil,
                  isFavorite: false,
                  comment: nil,
                  createdAt: reaction.createdAt,
                  updatedAt: reaction.updatedAt
                )
                allMakgeollisMap[makgeolliId] = entity

                if reactionType == "like" {
                  likedMap[makgeolliId] = entity
                } else if reactionType == "dislike" {
                  dislikedMap[makgeolliId] = entity
                }
              }
            } catch {
              // 개별 조회 실패는 무시하고 계속
            }
          }
        }

        var commentMakgeollis: [MyMakgeolliEntity] = []
        for comment in userComments {
          if let existing = allMakgeollisMap[comment.makgeolliId] {
            commentMakgeollis.append(existing)
          } else {
            do {
              if let info = try await supabaseClient.fetchMakgeolliById(comment.makgeolliId) {
                let entity = MyMakgeolliEntity(
                  id: info.id,
                  name: info.name,
                  imageName: info.imageName,
                  feedback: nil,
                  isFavorite: false,
                  comment: comment.comment,
                  createdAt: comment.createdAt,
                  updatedAt: comment.updatedAt
                )
                commentMakgeollis.append(entity)
                allMakgeollisMap[comment.makgeolliId] = entity
              }
            } catch {
              // 개별 조회 실패는 무시
            }
          }
        }

        let sorted: ([MyMakgeolliEntity]) -> [MyMakgeolliEntity] = { $0.sorted { $0.updatedAt > $1.updatedAt } }

        await send(.updateAllData(
          sorted(Array(allMakgeollisMap.values)),
          sorted(Array(likedMap.values)),
          sorted(Array(dislikedMap.values)),
          sorted(favoriteMakgeollis),
          sorted(commentMakgeollis)
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
