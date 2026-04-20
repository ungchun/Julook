import Foundation

import Core

public struct MyMakgeolliCoreError: JulookError, @unchecked Sendable {
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
    case failToFetchMyMakgeollis
    case failToFetchReactionData
    case failToFetchImage
    case failToFetchMakgeolliDetail
    case makgeolliNotFound
  }
}
