import Foundation

import Core

public struct HomeCoreError: JulookError, @unchecked Sendable {
  public var userInfo: [String: Any] = [:]
  public var code: Code
  public var underlying: Error?

  public enum Code: Int, Sendable {
    case failToSupabaseClientInitialized
    case failToFetchNewReleases
    case failToFetchRandomMakgeollis
    case failToGetImageUrl
    case failToFetchImage
    case failToFetchAwards
    case failToFetchTopLiked
    case failToUpdateFavoriteStatus
    case failToFetchRecentComments
    case failToFetchTranslations
  }
}
