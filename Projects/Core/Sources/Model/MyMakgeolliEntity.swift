//
//  MyMakgeolliData.swift
//  Core
//
//  Created by Kim SungHun on 7/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

public struct MyMakgeolliEntity: Sendable, Equatable, Hashable {
  public let id: UUID
  public let name: String
  public let imageName: String?
  public let feedback: String?
  public let isFavorite: Bool
  public let comment: String?
  public let createdAt: Date
  public let updatedAt: Date
  
  public init(
    id: UUID,
    name: String,
    imageName: String? = nil,
    feedback: String? = nil,
    isFavorite: Bool = false,
    comment: String? = nil,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.name = name
    self.imageName = imageName
    self.feedback = feedback
    self.isFavorite = isFavorite
    self.comment = comment
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

extension MyMakgeolli {
  public func toEntity() -> MyMakgeolliEntity {
    return MyMakgeolliEntity(
      id: self.id,
      name: self.name,
      imageName: self.imageName,
      feedback: self.feedback,
      isFavorite: self.isFavorite,
      comment: self.comment,
      createdAt: self.createdAt,
      updatedAt: self.updatedAt
    )
  }
}
