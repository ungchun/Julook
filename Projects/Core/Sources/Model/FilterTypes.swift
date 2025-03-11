//
//  FilterTypes.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/10/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import DesignSystem

public enum FilterType: String, CaseIterable, Identifiable, Sendable {
  case thick = "걸쭉한"
  case sweet = "달달한"
  case sour = "시큼한"
  case carbonated = "탄산감 많은"
  case noAspartame = "아스파탐 없는"
  
  public var id: String { rawValue }
  
  public var description: String {
    return rawValue
  }
  
  public var image: Image {
    switch self {
    case .thick: return DesignSystemAsset.Images.thick.swiftUIImage
    case .sweet: return DesignSystemAsset.Images.sweet.swiftUIImage
    case .sour: return DesignSystemAsset.Images.sour.swiftUIImage
    case .carbonated: return DesignSystemAsset.Images.carbonation.swiftUIImage
    case .noAspartame: return DesignSystemAsset.Images.aspartame.swiftUIImage
    }
  }
}

public enum SortOption: String, CaseIterable, Identifiable {
  case recommended = "추천순"
  case highAlcohol = "높은 도수순"
  case lowAlcohol = "낮은 도수순"
  
  public var id: String { rawValue }
  
  public var description: String {
    return rawValue
  }
}
