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
    return MakgeolliReactionClient(
      getReaction: { makgeolliId in
        return try await withCheckedThrowingContinuation { continuation in
          Task { @MainActor in
            do {
              let container = try await SharedModelContainer.shared.container
              let context = container.mainContext
              
              let descriptor = FetchDescriptor<MakgeolliReactionLocal>(
                predicate: #Predicate { $0.makgeolliId == makgeolliId }
              )
              
              let reactions = try context.fetch(descriptor)
              let result: MakgeolliReactionEntity? = reactions.first.map(
                MakgeolliReactionEntity.init
              )
              continuation.resume(returning: result)
            } catch {
              Log.error(MakgeolliReactionClientError(
                code: .failToGetReaction,
                underlying: error
              ))
              continuation.resume(throwing: error)
            }
          }
        }
      },
      
      getAllReactions: {
        return try await withCheckedThrowingContinuation { continuation in
          Task { @MainActor in
            do {
              let container = try await SharedModelContainer.shared.container
              let context = container.mainContext
              
              let descriptor = FetchDescriptor<MakgeolliReactionLocal>(
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
              )
              
              let reactions = try context.fetch(descriptor)
              let result = reactions.map(MakgeolliReactionEntity.init)
              continuation.resume(returning: result)
            } catch {
              Log.error(MakgeolliReactionClientError(
                code: .failToGetAllReactions,
                underlying: error
              ))
              continuation.resume(throwing: error)
            }
          }
        }
      },
      
      saveReaction: { makgeolliId, reactionType in
        return try await withCheckedThrowingContinuation { continuation in
          Task { @MainActor in
            do {
              let container = try await SharedModelContainer.shared.container
              let context = container.mainContext
              
              let descriptor = FetchDescriptor<MakgeolliReactionLocal>(
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
                let newReaction = MakgeolliReactionLocal(
                  makgeolliId: makgeolliId,
                  reactionType: reactionType
                )
                context.insert(newReaction)
              }
              
              try context.save()
              continuation.resume()
            } catch {
              Log.error(MakgeolliReactionClientError(
                code: .failToSaveReaction,
                underlying: error
              ))
              continuation.resume(throwing: error)
            }
          }
        }
      },
      
      deleteReaction: { makgeolliId in
        return try await withCheckedThrowingContinuation { continuation in
          Task { @MainActor in
            do {
              let container = try await SharedModelContainer.shared.container
              let context = container.mainContext
              
              let descriptor = FetchDescriptor<MakgeolliReactionLocal>(
                predicate: #Predicate { $0.makgeolliId == makgeolliId }
              )
              
              let reactions = try context.fetch(descriptor)
              for reaction in reactions {
                context.delete(reaction)
              }
              try context.save()
              continuation.resume()
            } catch {
              Log.error(MakgeolliReactionClientError(
                code: .failToDeleteReaction,
                underlying: error
              ))
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

public struct MakgeolliReactionClientError: JulookError, @unchecked Sendable {
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
    case failToGetReaction
    case failToGetAllReactions
    case failToSaveReaction
    case failToDeleteReaction
  }
}
