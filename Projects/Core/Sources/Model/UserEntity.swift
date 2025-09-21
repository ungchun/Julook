//
//  UserEntity.swift
//  Core
//
//  Created by Kim SungHun on 9/21/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

public struct UserEntity: Sendable, Equatable, Hashable {
  public let userId: UUID
  public let nickname: String
  public let profileImage: String
  public let createdAt: Date
  public let updatedAt: Date

  public init(
    userId: UUID,
    nickname: String,
    profileImage: String,
    createdAt: Date = Date(),
    updatedAt: Date = Date()
  ) {
    self.userId = userId
    self.nickname = nickname
    self.profileImage = profileImage
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

extension UserLocal {
  public func toEntity() -> UserEntity {
    return UserEntity(
      userId: self.userId,
      nickname: self.nickname,
      profileImage: self.profileImage,
      createdAt: self.createdAt,
      updatedAt: self.updatedAt
    )
  }
}