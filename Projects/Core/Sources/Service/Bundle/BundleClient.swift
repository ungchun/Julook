//
//  BundleClient.swift
//  Core
//
//  Created by Kim SungHun on 3/14/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import ComposableArchitecture

@DependencyClient
public struct BundleClient: Sendable {
  public var getValue: @Sendable (_ key: String) throws -> Any
  public var getCurrentVersion: @Sendable () throws -> String = { "0.0.0" }
  public var getBundleID: @Sendable () throws -> String = { "com.azhy.julook" }
}

extension BundleClient: DependencyKey {
  public static var liveValue: BundleClient {
    return .init(
      getValue: { key in
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) else {
          throw BundleClientError(code: .noValueForKey)
        }
        return value
      },
      getCurrentVersion: {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String else {
          throw BundleClientError(code: .noCurrentVersion)
        }
        return version
      },
      getBundleID: {
        guard let dictionary = Bundle.main.infoDictionary,
              let bundleID = dictionary["CFBundleIdentifier"] as? String else {
          throw BundleClientError(code: .noBundleID)
        }
        return bundleID
      }
    )
  }
  
  public static var testValue: BundleClient {
    return BundleClient()
  }
}

public extension DependencyValues {
  var bundleClient: BundleClient {
    get { self[BundleClient.self] }
    set { self[BundleClient.self] = newValue }
  }
}

public struct BundleClientError: Error, @unchecked Sendable {
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
  
  public enum Code: Int {
    case noValueForKey
    case noCurrentVersion
    case noBundleID
  }
}
