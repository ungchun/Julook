import Foundation

import Core

import ComposableArchitecture

extension FilterCore {
  func fetchMakgeollisEffect(
    pageSize: Int, selectedFilters: Set<FilterType>
  ) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let makgeollis = try await supabaseClient.fetchFilteredMakgeollis(
          pageSize, 0, selectedFilters
        )
        await send(.makgeollisResponse(.success(makgeollis), false))
      } catch {
        await send(.makgeollisResponse(.failure(error), false))
      }
    }
  }

  func fetchMakgeollisByTopicEffect(
    topicTitle: String, pageSize: Int
  ) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let makgeollis = try await supabaseClient.fetchMakgeollisByAward(
          topicTitle, pageSize, 0
        )
        await send(.makgeollisResponse(.success(makgeollis), false))
      } catch {
        await send(.makgeollisResponse(.failure(error), false))
      }
    }
  }

  func loadMoreMakgeollisEffect(
    isTopicMode: Bool,
    topicTitle: String,
    pageSize: Int,
    offset: Int,
    selectedFilters: Set<FilterType>
  ) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let makgeollis: [Makgeolli]
        if isTopicMode {
          makgeollis = try await supabaseClient.fetchMakgeollisByAward(
            topicTitle, pageSize, offset
          )
        } else {
          makgeollis = try await supabaseClient.fetchFilteredMakgeollis(
            pageSize, offset, selectedFilters
          )
        }
        await send(.makgeollisResponse(.success(makgeollis), true))
      } catch {
        await send(.makgeollisResponse(.failure(error), true))
      }
    }
  }

  func fetchMakgeolliImageEffect(makgeolli: Makgeolli) -> Effect<Action> {
    guard let imageName = makgeolli.imageName else { return .none }
    let supabaseClient = self.supabaseClient
    let id = makgeolli.id
    return .run { send in
      do {
        let fileName = imageName.hasSuffix(".png") ? imageName : "\(imageName).png"
        let url = try await supabaseClient.getPublicURL(Bucket.MAKGEOLLIIMAGE, fileName)
        await send(.makgeolliImageResponse(id: id, .success(url)))
      } catch {
        await send(.makgeolliImageResponse(id: id, .failure(error)))
      }
    }
  }

  func removeDuplicates(from makgeollis: [Makgeolli]) -> [Makgeolli] {
    var uniqueIds = Set<UUID>()
    var result: [Makgeolli] = []
    for makgeolli in makgeollis {
      if !uniqueIds.contains(makgeolli.id) {
        uniqueIds.insert(makgeolli.id)
        result.append(makgeolli)
      }
    }
    return result
  }

  func applySort(_ makgeollis: inout [Makgeolli], sort: SortOption) {
    switch sort {
    case .recommended:
      makgeollis.sort { (a, b) -> Bool in
        guard let aDate = a.createdAt, let bDate = b.createdAt else {
          return a.id.uuidString > b.id.uuidString
        }
        return aDate > bDate
      }
    case .highAlcohol:
      makgeollis.sort { (a, b) -> Bool in
        let aAlcohol = a.alcoholPercentage ?? 0
        let bAlcohol = b.alcoholPercentage ?? 0
        return aAlcohol > bAlcohol
      }
    case .lowAlcohol:
      makgeollis.sort { (a, b) -> Bool in
        let aAlcohol = a.alcoholPercentage ?? 0
        let bAlcohol = b.alcoholPercentage ?? 0
        return aAlcohol < bAlcohol
      }
    }
  }
}
