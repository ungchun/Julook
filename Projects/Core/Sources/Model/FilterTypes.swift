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
  case thick
  case sweet
  case sour
  case carbonated
  case noSweetener

  public var id: String { rawValue }

  public var description: String {
    switch self {
    case .thick: return L10n.Filter.Kind.thick
    case .sweet: return L10n.Filter.Kind.sweet
    case .sour: return L10n.Filter.Kind.sour
    case .carbonated: return L10n.Filter.Kind.carbonated
    case .noSweetener: return L10n.Filter.Kind.noSweetener
    }
  }

  public var image: Image {
    switch self {
    case .thick: return DesignSystemAsset.Images.thick.swiftUIImage
    case .sweet: return DesignSystemAsset.Images.sweet.swiftUIImage
    case .sour: return DesignSystemAsset.Images.sour.swiftUIImage
    case .carbonated: return DesignSystemAsset.Images.carbonation.swiftUIImage
    case .noSweetener: return DesignSystemAsset.Images.aspartame.swiftUIImage
    }
  }
}

public enum SortOption: String, CaseIterable, Identifiable {
  case recommended
  case highAlcohol
  case lowAlcohol

  public var id: String { rawValue }

  public var description: String {
    switch self {
    case .recommended: return L10n.Filter.Sort.recommended
    case .highAlcohol: return L10n.Filter.Sort.highAlcohol
    case .lowAlcohol: return L10n.Filter.Sort.lowAlcohol
    }
  }
}
