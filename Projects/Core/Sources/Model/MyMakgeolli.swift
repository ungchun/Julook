//
//  MyMakgeolli.swift
//  Core
//
//  Created by Kim SungHun on 7/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import SwiftData

@Model
public class MyMakgeolli {
  public var id: UUID = UUID()
  public var name: String = ""
  public var imageName: String?
  public var feedback: String?
  public var isFavorite: Bool = false
  public var comment: String?
  public var createdAt: Date = Date()
  public var updatedAt: Date = Date()
  
  public init(
    id: UUID = UUID(),
    name: String,
    imageName: String? = nil,
    feedback: String? = nil,
    isFavorite: Bool = false,
    comment: String? = nil
  ) {
    self.id = id
    self.name = name
    self.imageName = imageName
    self.feedback = feedback
    self.isFavorite = isFavorite
    self.comment = comment
    self.createdAt = Date()
    self.updatedAt = Date()
  }
  
  public func updateFavoriteStatus(_ isFavorite: Bool) {
    self.isFavorite = isFavorite
    self.updatedAt = Date()
  }
  
  public func updateFeedback(_ feedback: String?) {
    self.feedback = feedback
    self.updatedAt = Date()
  }
  
  public func updateComment(_ comment: String?) {
    self.comment = comment
    self.updatedAt = Date()
  }
}