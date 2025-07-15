//
//  MakgeolliReactionSupabase.swift
//  Core
//
//  Created by Kim SungHun on 7/15/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

/// Supabase makgeolli_reactions 테이블과 매핑되는 모델
public struct MakgeolliReactionSupabase: Codable, Sendable, Equatable {
  public let id: UUID
  public let userId: UUID
  public let makgeolliId: UUID
  public let reactionType: String
  public let createdAt: Date
  public let updatedAt: Date
  
  enum CodingKeys: String, CodingKey {
    case id
    case userId = "user_id"
    case makgeolliId = "makgeolli_id"
    case reactionType = "reaction_type"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
  
  public init(
    id: UUID = UUID(),
    userId: UUID,
    makgeolliId: UUID,
    reactionType: String,
    createdAt: Date = Date(),
    updatedAt: Date = Date()
  ) {
    self.id = id
    self.userId = userId
    self.makgeolliId = makgeolliId
    self.reactionType = reactionType
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

/// Supabase makgeolli_reaction_counts 테이블과 매핑되는 모델
public struct MakgeolliReactionCount: Codable, Sendable, Equatable {
  public let id: UUID
  public let makgeolliId: UUID
  public let likeCount: Int
  public let dislikeCount: Int
  public let createdAt: Date
  public let updatedAt: Date
  
  enum CodingKeys: String, CodingKey {
    case id
    case makgeolliId = "makgeolli_id"
    case likeCount = "like_count"
    case dislikeCount = "dislike_count"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
  
  public init(
    id: UUID = UUID(),
    makgeolliId: UUID,
    likeCount: Int = 0,
    dislikeCount: Int = 0,
    createdAt: Date = Date(),
    updatedAt: Date = Date()
  ) {
    self.id = id
    self.makgeolliId = makgeolliId
    self.likeCount = likeCount
    self.dislikeCount = dislikeCount
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
