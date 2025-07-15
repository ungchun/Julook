//
//  MakgeolliReaction.swift
//  Core
//
//  Created by Kim SungHun on 7/13/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import CloudKit
import SwiftData

@Model
public class MakgeolliReaction {
  public var id: UUID = UUID()
  public var makgeolliId: UUID = UUID()
  public var reactionType: String?
  public var createdAt: Date = Date()
  public var updatedAt: Date = Date()
  
  public init(
    id: UUID = UUID(),
    makgeolliId: UUID,
    reactionType: String? = nil
  ) {
    self.id = id
    self.makgeolliId = makgeolliId
    self.reactionType = reactionType
    self.createdAt = Date()
    self.updatedAt = Date()
  }
}

public enum ReactionType: String, CaseIterable {
  case like = "like"
  case dislike = "dislike"
  
  public var displayName: String {
    switch self {
    case .like:
      return "좋았어요"
    case .dislike:
      return "아쉬워요"
    }
  }
}
