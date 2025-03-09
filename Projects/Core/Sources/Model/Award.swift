//
//  Award.swift
//  Core
//
//  Created by Kim SungHun on 3/8/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

public struct Award: Codable, Identifiable, Equatable, Sendable {
  public let id: UUID
  public let name: String
  public let year: Int
  public let type: String
  
  public init(
    id: UUID,
    name: String,
    year: Int,
    type: String
  ) {
    self.id = id
    self.name = name
    self.year = year
    self.type = type
  }
}
