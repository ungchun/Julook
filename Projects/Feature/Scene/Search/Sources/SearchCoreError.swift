import Foundation

public struct SearchCoreError: Error, Equatable, @unchecked Sendable {
  public var code: Code
  public var underlying: Error?

  public init(code: Code, underlying: Error? = nil) {
    self.code = code
    self.underlying = underlying
  }

  public static func == (lhs: SearchCoreError, rhs: SearchCoreError) -> Bool {
    lhs.code == rhs.code
  }

  public enum Code: Int, Equatable {
    case failToSearch
    case failToFetchImage
  }
}
