//
//  UserComment.swift
//  Core
//
//  Created by Kim SungHun on 8/10/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

public struct UserComment: Codable, Sendable, Equatable, Hashable {
  public let id: UUID
  public let userId: UUID
  public let makgeolliId: UUID
  public let comment: String
  public let isPublic: Bool
  public let createdAt: Date
  public let updatedAt: Date
  
  public init(
    id: UUID,
    userId: UUID,
    makgeolliId: UUID,
    comment: String,
    isPublic: Bool,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.userId = userId
    self.makgeolliId = makgeolliId
    self.comment = comment
    self.isPublic = isPublic
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

extension UserComment {
  enum CodingKeys: String, CodingKey {
    case id
    case userId = "user_id"
    case makgeolliId = "makgeolli_id"
    case comment
    case isPublic = "is_public"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
}