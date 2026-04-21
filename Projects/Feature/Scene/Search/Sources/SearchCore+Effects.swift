import Foundation

import Core

import ComposableArchitecture

extension SearchCore {
  func searchMakgeollisEffect(query: String) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        let makgeollis = try await supabaseClient.searchMakgeollis(query)
        await send(.searchResponse(.success(makgeollis)))
      } catch {
        await send(.searchResponse(.failure(error)))
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

  func persistRecentSearchesEffect(_ searches: [String]) -> Effect<Action> {
    let userDefaultsClient = self.userDefaultsClient
    return .run { _ in
      userDefaultsClient.set(.recentSearches, searches)
    }
  }

  func removeRecentSearchesEffect() -> Effect<Action> {
    let userDefaultsClient = self.userDefaultsClient
    return .run { _ in
      userDefaultsClient.removeObject(.recentSearches)
    }
  }

  func loadRecentSearchesEffect() -> Effect<Action> {
    let userDefaultsClient = self.userDefaultsClient
    return .run { send in
      do {
        let searches = try userDefaultsClient.stringArray(.recentSearches)
        await send(.recentSearchesResponse(searches))
      } catch {
        await send(.recentSearchesResponse([]))
      }
    }
  }

  func requestRegisterMakgeolliEffect(searchText: String) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        try await supabaseClient.requestRegisterMakgeolli(searchText)
        await send(.showRequestAlert(true))
      } catch {
        await send(.showRequestAlert(true))
      }
    }
  }

  func dispatchLogError(_ error: SearchCoreError) -> Effect<Action> {
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

  func getErrorMessage(for code: SearchCoreError.Code) -> String {
    switch code {
    case .failToSearch:
      return L10n.Search.Error.searchFailed
    case .failToFetchImage:
      return L10n.Common.Error.imageLoadFailed
    }
  }
}
