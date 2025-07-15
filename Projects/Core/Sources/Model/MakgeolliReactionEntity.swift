//
//  MakgeolliReactionEntity.swift
//  Core
//
//  Created by Kim SungHun on 7/13/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import SwiftData

public struct MakgeolliReactionEntity: Sendable, Equatable {
  public let id: UUID
  public let makgeolliId: UUID
  public let reactionType: String?
  public let createdAt: Date
  public let updatedAt: Date
  
  public init(
    id: UUID,
    makgeolliId: UUID,
    reactionType: String?,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.makgeolliId = makgeolliId
    self.reactionType = reactionType
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

public extension MakgeolliReactionEntity {
  init(from model: MakgeolliReaction) {
    self.id = model.id
    self.makgeolliId = model.makgeolliId
    self.reactionType = model.reactionType
    self.createdAt = model.createdAt
    self.updatedAt = model.updatedAt
  }
}
