//
//  Makgeolli.swift
//  Core
//
//  Created by Kim SungHun on 3/7/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

public struct Makgeolli: Codable, Identifiable, Equatable, Sendable {
  /// 고유 식별자 (UUID)
  public let id: UUID
  /// 막걸리 이름
  public let name: String
  /// 양조장명
  public let brewery: String?
  /// 홈페이지 URL
  public let website: String?
  /// 수상 내역 목록
  public let awards: [String]?
  /// 가격
  public let price: Int?
  /// 구매 링크 URL
  public let purchaseLink: String?
  /// 단맛 정도
  public let sweetness: Int?
  /// 신맛 정도
  public let sourness: Int?
  /// 걸쭉함 정도
  public let thickness: Int?
  /// 탄산 정도
  public let carbonation: Int?
  /// 아스파탐 유무
  public let hasAspartame: Bool?
  /// 원재료 목록
  public let ingredients: [String]?
  /// 알콜 도수
  public let alcoholPercentage: Double?
  /// 용량
  public let volume: Int?
  /// 상세 설명
  public let description: String?
  /// 이미지 파일명
  public let imageName: String?
  /// 데이터 생성 시간
  public let createdAt: Date?
  /// 데이터 마지막 업데이트 시간
  public let updatedAt: Date?
  
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case brewery
    case website
    case awards
    case price
    case purchaseLink = "purchase_link"
    case sweetness
    case sourness
    case thickness
    case hasAspartame = "has_aspartame"
    case carbonation
    case ingredients
    case alcoholPercentage = "alcohol_percentage"
    case volume
    case description
    case imageName = "image_name"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
}
