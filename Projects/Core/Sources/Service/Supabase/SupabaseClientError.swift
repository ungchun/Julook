import Foundation

public struct SupabaseClientError: JulookError, @unchecked Sendable {
  public var userInfo: [String: Any]
  public var code: Code
  public var underlying: Error?

  public init(
    userInfo: [String: Any] = [:],
    code: Code,
    underlying: Error? = nil
  ) {
    self.userInfo = userInfo
    self.code = code
    self.underlying = underlying
  }

  public enum Code: Int, Sendable {
    case clientNotInitialized
    case failToFetch
    case failToGetPublicURL
    case failToSaveRequest
    case failToSaveReaction
    case failToDeleteReaction
    case failToSaveUserComment
    case failToDeleteUserComment
    case failToAnalyzeLabel
    case unknownError
  }
}
