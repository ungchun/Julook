//
//  Award.swift
//  Core
//
//  Created by Kim SungHun on 3/8/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

public struct Award: Codable, Identifiable, Equatable, Hashable, Sendable {
  public let id: UUID
  public let name: String
  public let nameEn: String?
  public let year: Int
  public let type: String

  public init(
    id: UUID,
    name: String,
    nameEn: String? = nil,
    year: Int,
    type: String
  ) {
    self.id = id
    self.name = name
    self.nameEn = nameEn
    self.year = year
    self.type = type
  }

  private enum CodingKeys: String, CodingKey {
    case id
    case name
    case nameEn = "name_en"
    case year
    case type
  }

  /// locale 에 맞는 표시용 이름 반환. `.en` + `nameEn` 있으면 영어, 아니면 `name` 폴백.
  public func localizedName(for locale: SupportedLocale) -> String {
    switch locale {
    case .en:
      return nameEn ?? name
    case .ko:
      return name
    }
  }
}
