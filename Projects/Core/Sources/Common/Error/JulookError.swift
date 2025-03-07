//
//  JulookError.swift
//  Core
//
//  Created by Kim SungHun on 3/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

public protocol JulookError: Error, CustomNSError, Sendable {
  var code: Code { get }
  var userInfo: [String: Any] { get }
  var underlying: Error? { get }
  
  associatedtype Code: RawRepresentable,
                       Sendable where Code.RawValue == Int
}

extension JulookError {
  public var errorDomain: String { "\(Self.self)" }
  public var errorCode: Int { self.code.rawValue }
  public var errorUserInfo: [String: Any] {
    var userInfo: [String: Any] = self.userInfo
    userInfo["identifier"] = String(reflecting: code)
    userInfo[NSUnderlyingErrorKey] = underlying
    return userInfo
  }
}
