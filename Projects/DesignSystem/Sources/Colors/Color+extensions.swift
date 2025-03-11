//
//  Color+extensions.swift
//  DesignSystem
//
//  Created by Kim SungHun on 3/4/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI
import UIKit

extension Color {
  public init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")
    
    self.init(
      red: Double(red) / 255.0,
      green: Double(green) / 255.0,
      blue: Double(blue) / 255.0
    )
  }
  
  public init(hex: Int) {
    self.init(
      red: (hex >> 16) & 0xFF,
      green: (hex >> 8) & 0xFF,
      blue: hex & 0xFF
    )
  }
}

public extension Color {
  var uiColor: UIColor {
    UIColor(self)
  }
  
  static var alrert: Color {
    DesignSystemAsset.Colors.alrert.swiftUIColor
  }
  static var darkbase: Color {
    DesignSystemAsset.Colors.darkbase.swiftUIColor
  }
  static var darkgray: Color {
    DesignSystemAsset.Colors.darkgray.swiftUIColor
  }
  static var darkwindow: Color {
    DesignSystemAsset.Colors.darkwindow.swiftUIColor
  }
  static var goldenyellow: Color {
    DesignSystemAsset.Colors.goldenyellow.swiftUIColor
  }
  static var ivory: Color {
    DesignSystemAsset.Colors.ivory.swiftUIColor
  }
  static var lilac: Color {
    DesignSystemAsset.Colors.lilac.swiftUIColor
  }
  static var primary: Color {
    DesignSystemAsset.Colors.primary.swiftUIColor
  }
  static var primary2: Color {
    DesignSystemAsset.Colors.primary2.swiftUIColor
  }
  static var w: Color {
    DesignSystemAsset.Colors.w.swiftUIColor
  }
  static var w10: Color {
    DesignSystemAsset.Colors.w10.swiftUIColor
  }
  static var w25: Color {
    DesignSystemAsset.Colors.w25.swiftUIColor
  }
  static var w50: Color {
    DesignSystemAsset.Colors.w50.swiftUIColor
  }
  static var w85: Color {
    DesignSystemAsset.Colors.w85.swiftUIColor
  }
  static var warmred: Color {
    DesignSystemAsset.Colors.warmred.swiftUIColor
  }
}

public extension LinearGradient {
  static var warmNeutral: LinearGradient {
    LinearGradient(
      gradient: Gradient(colors: [
        Color(hex: 0xDBC2C2),
        Color(hex: 0xA38787)
      ]),
      startPoint: .top,
      endPoint: .bottom
    )
  }
  
  static var lilacNeutral: LinearGradient {
    LinearGradient(
      gradient: Gradient(colors: [
        Color(hex: 0x3D3D72),
        Color(hex: 0x000000)
      ]),
      startPoint: .top,
      endPoint: .bottom
    )
  }
}
