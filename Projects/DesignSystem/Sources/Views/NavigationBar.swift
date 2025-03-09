//
//  NavigationBar.swift
//  DesignSystem
//
//  Created by Kim SungHun on 3/9/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

struct BackButton: View {
  @Environment(\.dismiss) private var dismiss
  var color: Color = DesignSystemAsset.Colors.primary.swiftUIColor
  var body: some View {
    Button {
      dismiss()
    } label: {
      DesignSystemAsset.Images.arrowLeft.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 17)
        .foregroundColor(color)
        .contentShape(Rectangle())
    }
  }
}

struct NavigationBarModifier: ViewModifier {
  let backButtonColor: Color
  let title: String?
  let titleColor: Color
  
  init(backButtonColor: Color = DesignSystemAsset.Colors.primary.swiftUIColor,
       title: String? = nil,
       titleColor: Color = .white) {
    self.backButtonColor = backButtonColor
    self.title = title
    self.titleColor = titleColor
  }
  
  func body(content: Content) -> some View {
    content
      .navigationBarBackButtonHidden(true)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          BackButton(color: backButtonColor)
        }
        if let title = title {
          ToolbarItem(placement: .principal) {
            Text(title)
              .font(.SF17B)
              .foregroundColor(titleColor)
          }
        }
      }
  }
}

public extension View {
  func addNavigationBar(
    color: Color = DesignSystemAsset.Colors.primary.swiftUIColor,
    title: String? = nil,
    titleColor: Color = .white
  ) -> some View {
    modifier(NavigationBarModifier(
      backButtonColor: color,
      title: title,
      titleColor: titleColor
    ))
  }
}
