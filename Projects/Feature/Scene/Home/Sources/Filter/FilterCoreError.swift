import Foundation

import Core

public struct FilterCoreError: JulookError, @unchecked Sendable {
  public var userInfo: [String: Any] = [:]
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
    case failToFetchMakgeollis
    case failToFetchImage
  }
}
