//
//  SharedModelContainer.swift
//  Core
//
//  Created by Kim SungHun on 7/15/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import SwiftData

import ComposableArchitecture

public final class SharedModelContainer: @unchecked Sendable {
  public static let shared = SharedModelContainer()
  
  private var _container: ModelContainer?
  private let containerQueue = DispatchQueue(
    label: "com.azhy.julook.container", qos: .userInitiated
  )
  
  private init() {}
  
  public var container: ModelContainer {
    get async throws {
      return try await withCheckedThrowingContinuation { continuation in
        containerQueue.async {
          do {
            if let _container = self._container {
              continuation.resume(returning: _container)
              return
            }
            
            let schema = Schema([MyMakgeolliLocal.self, MakgeolliReactionLocal.self, UserLocal.self])
            let configuration = ModelConfiguration(
              schema: schema,
              isStoredInMemoryOnly: false,
              cloudKitDatabase: .automatic
            )
            
            let container = try ModelContainer(for: schema, configurations: [configuration])
            self._container = container
            continuation.resume(returning: container)
          } catch {
            continuation.resume(throwing: error)
          }
        }
      }
    }
  }
  
  public func initialize() async throws {
    _ = try await container
  }
}

extension DependencyValues {
  public var sharedModelContainer: SharedModelContainer {
    get { self[SharedModelContainer.self] }
    set { self[SharedModelContainer.self] = newValue }
  }
}

extension SharedModelContainer: DependencyKey {
  public static let liveValue: SharedModelContainer = SharedModelContainer.shared
  public static let testValue: SharedModelContainer = SharedModelContainer.shared
}
