//
//  Makgeolli+Localized.swift
//  Core
//
//  Created for English localization.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

extension Makgeolli {
  /// 주어진 번역을 적용한 Makgeolli를 반환.
  /// - translation이 nil이면 원본 그대로.
  /// - 번역의 개별 필드가 nil이면 원본 필드를 유지.
  public func localized(with translation: MakgeolliTranslation?) -> Makgeolli {
    guard let t = translation else { return self }
    return Makgeolli(
      id: id,
      name: t.name,
      brewery: t.brewery ?? brewery,
      website: website,
      awards: t.awards ?? awards,
      sweetness: sweetness,
      sourness: sourness,
      thickness: thickness,
      carbonation: carbonation,
      hasSweetener: hasSweetener,
      ingredients: t.ingredients ?? ingredients,
      alcoholPercentage: alcoholPercentage,
      imageName: imageName,
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }
}
