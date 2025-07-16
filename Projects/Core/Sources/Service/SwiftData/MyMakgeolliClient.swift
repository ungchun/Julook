//
//  MyMakgeolliClient.swift
//  Core
//
//  Created by Kim SungHun on 7/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import SwiftData

import ComposableArchitecture

@DependencyClient
public struct MyMakgeolliClient: Sendable {
  public var initialize: @Sendable () async throws -> Void
  
  public var toggleFavorite: @Sendable (Makgeolli) async -> Void
  public var isFavorite: @Sendable (UUID) async throws -> Bool
  public var getMyMakgeollis: @Sendable () async throws -> [MyMakgeolliEntity]
  public var checkCloudKitStatus: @Sendable () async throws -> Bool
}

extension MyMakgeolliClient: DependencyKey {
  public static var liveValue: MyMakgeolliClient {
    return MyMakgeolliClient(
      initialize: {
        try await SharedModelContainer.shared.initialize()
      },
      
      toggleFavorite: { makgeolli in
        let container: ModelContainer
        do {
          container = try await SharedModelContainer.shared.container
        } catch {
          return
        }
        
        await MainActor.run {
          let context = container.mainContext
          
          let descriptor = FetchDescriptor<MyMakgeolliLocal>(
            predicate: #Predicate { $0.id == makgeolli.id }
          )
          
          do {
            let existingFavorites = try context.fetch(descriptor)
            
            if let existing = existingFavorites.first {
              existing.updateFavoriteStatus(!existing.isFavorite)
              if existing.imageName == nil && makgeolli.imageName != nil {
                existing.imageName = makgeolli.imageName
              }
            } else {
              let newFavorite = MyMakgeolliLocal(
                id: makgeolli.id,
                name: makgeolli.name,
                imageName: makgeolli.imageName,
                isFavorite: true
              )
              context.insert(newFavorite)
            }
            
            try context.save()
          } catch {
            Log.error(MyMakgeolliClientError(
              code: .failToToggleFavorite,
              underlying: error
            ))
          }
        }
        
        try? await Task.sleep(nanoseconds: 100_000_000)
      },
      
      isFavorite: { makgeolliId in
        let container: ModelContainer
        do {
          container = try await SharedModelContainer.shared.container
        } catch {
          return false
        }
        
        return await MainActor.run {
          let context = container.mainContext
          
          let descriptor = FetchDescriptor<MyMakgeolliLocal>(
            predicate: #Predicate { $0.id == makgeolliId && $0.isFavorite == true }
          )
          
          do {
            let favorites = try context.fetch(descriptor)
            return !favorites.isEmpty
          } catch {
            Log.error(MyMakgeolliClientError(
              code: .failToCheckFavoriteStatus,
              underlying: error
            ))
            return false
          }
        }
      },
      
      getMyMakgeollis: {
        let container: ModelContainer
        do {
          container = try await SharedModelContainer.shared.container
        } catch {
          return []
        }
        
        return await MainActor.run {
          let context = container.mainContext
          
          let descriptor = FetchDescriptor<MyMakgeolliLocal>(
            predicate: #Predicate { $0.isFavorite == true },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
          )
          
          do {
            let favorites = try context.fetch(descriptor)
            return favorites.map { $0.toEntity() }
          } catch {
            Log.error(MyMakgeolliClientError(
              code: .failToFetchMyMakgeollis,
              underlying: error
            ))
            return []
          }
        }
      },
      
      checkCloudKitStatus: {
        let container: ModelContainer
        do {
          container = try await SharedModelContainer.shared.container
        } catch {
          return false
        }
        
        return await MainActor.run {
          let context = container.mainContext
          do {
            let descriptor = FetchDescriptor<MyMakgeolliLocal>()
            let _ = try context.fetchCount(descriptor)
            return true
          } catch {
            return false
          }
        }
      }
    )
  }
}

public extension DependencyValues {
  var myMakgeolliClient: MyMakgeolliClient {
    get { self[MyMakgeolliClient.self] }
    set { self[MyMakgeolliClient.self] = newValue }
  }
}

public struct MyMakgeolliClientError: JulookError, @unchecked Sendable {
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
    case failToInitializeContainer
    case containerNotInitialized
    case failToToggleFavorite
    case failToCheckFavoriteStatus
    case failToFetchMyMakgeollis
  }
}
