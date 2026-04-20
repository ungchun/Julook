import Foundation

import Core

public struct InformationCoreError: JulookError, @unchecked Sendable {
  public var userInfo: [String: Any] = [:]
  public var code: Code
  public var underlying: Error?

  public init(
    code: Code,
    underlying: Error? = nil
  ) {
    self.code = code
    self.underlying = underlying
  }

  public enum Code: Int, Sendable {
    case failToCheckFavoriteStatus
    case failToUpdateFavoriteStatus
    case failToLoadReaction
    case failToSaveReaction
    case failToLoadReactionCounts
    case failToLoadUserComment
    case failToSaveUserComment
    case failToDeleteUserComment
    case failToLoadPublicComments
  }
}
