//
//  Log.swift
//  Core
//
//  Created by Kim SungHun on 3/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import OSLog

public struct Log {
  enum Level {
    /// 디버깅 로그
    case debug
    /// 네트워크 로그
    case network
    /// 오류 로그
    case error
    case custom(categoryName: String)
    
    fileprivate var categoryString: String {
      switch self {
      case .debug:
        return "🐛 DEBUG"
      case .network:
        return "🔵 NETWORK"
      case .error:
        return "🔴 ERROR"
      case .custom(let categoryName):
        return "🟢 CUSTOM \(categoryName)"
      }
    }
    
    fileprivate var osLog: OSLog {
      switch self {
      case .debug:
        return OSLog.debug
      case .network:
        return OSLog.network
      case .error:
        return OSLog.error
      case .custom:
        return OSLog.debug
      }
    }
    
    fileprivate var osLogType: OSLogType {
      switch self {
      case .debug:
        return .debug
      case .network:
        return .default
      case .error:
        return .error
      case .custom:
        return .debug
      }
    }
  }
  
  static func log(
    _ message: Any,
    _ arguments: [Any],
    level: Level,
    file: StaticString,
    function: StaticString,
    line: Int
  ) {
#if DEBUG
    let extraMessage: String = arguments.map({ String(describing: $0) }).joined(separator: " \n")
    let logger = Logger(subsystem: OSLog.bundleId, category: level.categoryString)
    let logMessage = """
    \(level.categoryString) \n \(file) \(line) \(function)
    \n \(message) \n \(extraMessage) \t\t
    """
    switch level {
    case .debug,
        .custom:
      logger.debug("\(logMessage, privacy: .public)")
    case .network:
      logger.log("\(logMessage, privacy: .public)")
    case .error:
      logger.error("\(logMessage, privacy: .public)")
    }
#endif
  }
}

public extension Log {
  static func debug(
    _ message: Any,
    _ arguments: Any...,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line
  ) {
    log(message, arguments, level: .debug, file: file, function: function, line: line)
  }
  
  /**
   # network
   - Note : 네트워크 문제 해결에 필수적인 정보
   */
  static func network(
    _ message: Any,
    _ arguments: Any...,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line
  ) {
    log(message, arguments, level: .debug, file: file, function: function, line: line)
  }
  
  /**
   # error
   - Note : 코드 실행 중 나타난 에러
   */
  static func error(
    _ error: Error,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line
  ) {
    log("Error 👇", [error], level: .error, file: file, function: function, line: line)
  }
  
  /**
   # custom
   - Note : 커스텀 디버깅 로그
   */
  static func custom(
    category: String,
    _ message: Any,
    _ arguments: Any...,
    file: StaticString = #file,
    function: StaticString = #function,
    line: Int = #line
  ) {
    log(message, arguments, level: .custom(categoryName: category),
        file: file, function: function, line: line)
  }
}

extension OSLog {
  static let bundleId = Bundle.main.bundleIdentifier!
  static let debug = OSLog(subsystem: bundleId, category: "Debug")
  static let network = OSLog(subsystem: bundleId, category: "Network")
  static let error = OSLog(subsystem: bundleId, category: "Error")
}
