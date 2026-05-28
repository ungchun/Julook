//
//  MakgeolliTranslation.swift
//  Core
//
//  Created for English localization.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

public struct MakgeolliTranslation: Codable, Equatable, Hashable, Sendable {
  /// 대상 막걸리 ID (FK)
  public let makgeolliId: UUID
  /// Locale 코드 (예: "en")
  public let locale: String
  /// 번역된 이름
  public let name: String
  /// 번역된 양조장명 (nil이면 원본 사용)
  public let brewery: String?
  /// 번역된 수상 내역 (nil이면 원본 사용)
  public let awards: [String]?
  /// 번역된 원재료 (nil이면 원본 사용)
  public let ingredients: [String]?
  /// 번역된 설명 (nil이면 원본 사용)
  public let description: String?

  public init(
    makgeolliId: UUID,
    locale: String,
    name: String,
    brewery: String?,
    awards: [String]?,
    ingredients: [String]?,
    description: String?
  ) {
    self.makgeolliId = makgeolliId
    self.locale = locale
    self.name = name
    self.brewery = brewery
    self.awards = awards
    self.ingredients = ingredients
    self.description = description
  }

  enum CodingKeys: String, CodingKey {
    case makgeolliId = "makgeolli_id"
    case locale
    case name
    case brewery
    case awards
    case ingredients
    case description
  }
}
