//
//  MakgeolliReactionClient.swift
//  Core
//
//  Created by Kim SungHun on 7/13/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import SwiftData

import ComposableArchitecture

@DependencyClient
public struct MakgeolliReactionClient: Sendable {
  public var getReaction: @Sendable (UUID) async throws -> MakgeolliReactionEntity?
  public var getAllReactions: @Sendable () async throws -> [MakgeolliReactionEntity]
  public var saveReaction: @Sendable (UUID, String?) async throws -> Void
  public var deleteReaction: @Sendable (UUID) async throws -> Void
}

extension MakgeolliReactionClient: DependencyKey {
  public static var liveValue: MakgeolliReactionClient {
    let containerRef = LockIsolated<ModelContainer?>(nil)
    
    return MakgeolliReactionClient(
      getReaction: { makgeolliId in
        return try await withCheckedThrowingContinuation { continuation in
          Task { @MainActor in
            do {
              let container = try getOrCreateContainer(containerRef)
              let context = container.mainContext
              
              let descriptor = FetchDescriptor<MakgeolliReaction>(
                predicate: #Predicate { $0.makgeolliId == makgeolliId }
              )
              
              let reactions = try context.fetch(descriptor)
              let result: MakgeolliReactionEntity? = reactions.first.map(
                MakgeolliReactionEntity.init
              )
              continuation.resume(returning: result)
            } catch {
              // TODO: ERROR
              continuation.resume(throwing: error)
            }
          }
        }
      },
      
      getAllReactions: {
        return try await withCheckedThrowingContinuation { continuation in
          Task { @MainActor in
            do {
              let container = try getOrCreateContainer(containerRef)
              let context = container.mainContext
              
              let descriptor = FetchDescriptor<MakgeolliReaction>(
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
              )
              
              let reactions = try context.fetch(descriptor)
              let result = reactions.map(MakgeolliReactionEntity.init)
              continuation.resume(returning: result)
            } catch {
              continuation.resume(throwing: error)
            }
          }
        }
      },
      
      saveReaction: { makgeolliId, reactionType in
        return try await withCheckedThrowingContinuation { continuation in
          Task { @MainActor in
            do {
              let container = try getOrCreateContainer(containerRef)
              let context = container.mainContext
              
              let descriptor = FetchDescriptor<MakgeolliReaction>(
                predicate: #Predicate { $0.makgeolliId == makgeolliId }
              )
              
              let existingReactions = try context.fetch(descriptor)
              
              if let existingReaction = existingReactions.first {
                if let reactionType = reactionType {
                  existingReaction.reactionType = reactionType
                  existingReaction.updatedAt = Date()
                } else {
                  context.delete(existingReaction)
                }
              } else if let reactionType = reactionType {
                let newReaction = MakgeolliReaction(
                  makgeolliId: makgeolliId,
                  reactionType: reactionType
                )
                context.insert(newReaction)
              }
              
              try context.save()
              continuation.resume()
            } catch {
              // TODO: ERROR
              continuation.resume(throwing: error)
            }
          }
        }
      },
      
      deleteReaction: { makgeolliId in
        return try await withCheckedThrowingContinuation { continuation in
          Task { @MainActor in
            do {
              let container = try getOrCreateContainer(containerRef)
              let context = container.mainContext
              
              let descriptor = FetchDescriptor<MakgeolliReaction>(
                predicate: #Predicate { $0.makgeolliId == makgeolliId }
              )
              
              let reactions = try context.fetch(descriptor)
              for reaction in reactions {
                context.delete(reaction)
              }
              try context.save()
              continuation.resume()
            } catch {
              // TODO: ERROR
              continuation.resume(throwing: error)
            }
          }
        }
      }
    )
  }
  
  public static let testValue = MakgeolliReactionClient(
    getReaction: { _ in nil },
    getAllReactions: { [] },
    saveReaction: { _, _ in },
    deleteReaction: { _ in }
  )
}

extension DependencyValues {
  public var makgeolliReactionClient: MakgeolliReactionClient {
    get { self[MakgeolliReactionClient.self] }
    set { self[MakgeolliReactionClient.self] = newValue }
  }
}

@MainActor
private func getOrCreateContainer(
  _ containerRef: LockIsolated<ModelContainer?>
) throws -> ModelContainer {
  if let container = containerRef.value {
    return container
  }
  
  let schema = Schema([MyMakgeolli.self, MakgeolliReaction.self])
  let configuration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    cloudKitDatabase: .automatic
  )
  
  let container = try ModelContainer(for: schema, configurations: [configuration])
  containerRef.setValue(container)
  return container
}
