//
//  VersionCheckClient.swift
//  Core
//
//  Created by Kim SungHun on 3/14/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import ComposableArchitecture

@DependencyClient
public struct VersionCheckClient: Sendable {
  public var checkForUpdate: @Sendable () async throws -> String = { "1.0.0" }
  public var isForceUpdateRequired: @Sendable (String, String) -> Bool = { _, _ in false }
}

extension VersionCheckClient: DependencyKey {
  public static var liveValue: VersionCheckClient {
    return .init(
      checkForUpdate: {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.azhy.julook"
        if let appStoreURL = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleID)") {
          let (data, _) = try await URLSession.shared.data(from: appStoreURL)
          let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
          let results = json?["results"] as? [[String: Any]] ?? []
          
          if let appInfo = results.first,
             let latestVersion = appInfo["version"] as? String {
            return latestVersion
          } else {
            throw NSError()
          }
        } else {
          throw NSError()
        }
      },
      
      isForceUpdateRequired: { currentVersion, latestVersion in
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }
        let latestComponents = latestVersion.split(separator: ".").compactMap { Int($0) }
        
        if currentComponents.count > 0 && latestComponents.count > 0 {
          if currentComponents[0] < latestComponents[0] {
            return true
          }
        }
        
        if currentComponents.count > 1 && latestComponents.count > 1 {
          if currentComponents[1] < latestComponents[1] {
            return true
          }
        }
        
        return false
      }
    )
  }
  
  public static var testValue: VersionCheckClient {
    return VersionCheckClient()
  }
}

public extension DependencyValues {
  var versionCheckClient: VersionCheckClient {
    get { self[VersionCheckClient.self] }
    set { self[VersionCheckClient.self] = newValue }
  }
}
