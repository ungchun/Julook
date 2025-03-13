//
//  Font+extensions.swift
//  DesignSystem
//
//  Created by Kim SungHun on 3/5/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

extension Font {
  public static func style(_ fontStyle: JulookFont) -> Font {
    switch fontStyle {
    case .SFTitle:
      return .system(size: 28, weight: .bold)
    case .SF24B:
      return .system(size: 24, weight: .bold)
    case .SF20B:
      return .system(size: 20, weight: .bold)
    case .SF17B:
      return .system(size: 17, weight: .bold)
    case .SF17R:
      return .system(size: 17, weight: .regular)
    case .SF16R:
      return .system(size: 16, weight: .regular)
    case .SF15R:
      return .system(size: 15, weight: .regular)
    case .SF14R:
      return .system(size: 14, weight: .regular)
    case .SF12B:
      return .system(size: 12, weight: .bold)
    case .SF12R:
      return .system(size: 12, weight: .regular)
    case .SF10B:
      return .system(size: 10, weight: .bold)
    case .SF10R:
      return .system(size: 10, weight: .regular)
    }
  }
  
  public static var SFTitle: Font { style(.SFTitle) }
  public static var SF24B: Font { style(.SF24B) }
  public static var SF20B: Font { style(.SF20B) }
  public static var SF17B: Font { style(.SF17B) }
  public static var SF17R: Font { style(.SF17R) }
  public static var SF16R: Font { style(.SF16R) }
  public static var SF15R: Font { style(.SF15R) }
  public static var SF14R: Font { style(.SF14R) }
  public static var SF12B: Font { style(.SF12B) }
  public static var SF12R: Font { style(.SF12R) }
  public static var SF10B: Font { style(.SF10B) }
  public static var SF10R: Font { style(.SF10R) }
}

public enum JulookFont {
  case SFTitle
  case SF24B
  case SF20B
  case SF17B
  case SF17R
  case SF16R
  case SF15R
  case SF14R
  case SF12B
  case SF12R
  case SF10B
  case SF10R
}
