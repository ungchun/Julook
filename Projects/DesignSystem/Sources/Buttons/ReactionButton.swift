//
//  ReactionButton.swift
//  SharedComponents
//
//  Created by Kim SungHun on 7/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

public enum ReactionButtonState {
  case disabled
  case active
}

public enum ReactionType {
  case like
  case dislike
  
  var iconName: String {
    switch self {
    case .like:
      return "hand.thumbsup.fill"
    case .dislike:
      return "hand.thumbsdown.fill"
    }
  }
}

public struct ReactionButton: View {
  let state: ReactionButtonState
  let type: ReactionType
  let text: String
  let action: () -> Void
  
  public init(
    state: ReactionButtonState,
    type: ReactionType,
    text: String,
    action: @escaping () -> Void
  ) {
    self.state = state
    self.type = type
    self.text = text
    self.action = action
  }
  
  private var backgroundColor: Color {
    switch state {
    case .disabled:
      return DesignSystemAsset.Colors.w10.swiftUIColor
    case .active:
      switch type {
      case .like:
        return DesignSystemAsset.Colors.goldenyellow.swiftUIColor
      case .dislike:
        return DesignSystemAsset.Colors.lilac.swiftUIColor
      }
    }
  }
  
  private var foregroundColor: Color {
    switch state {
    case .disabled:
      return DesignSystemAsset.Colors.w85.swiftUIColor
    case .active:
      return DesignSystemAsset.Colors.w.swiftUIColor
    }
  }
  
  public var body: some View {
    Button(action: action) {
      HStack(spacing: 4) {
        Image(systemName: type.iconName)
          .font(.SF17R)
        
        Text(text)
          .font(.SF17R)
      }
      .foregroundColor(foregroundColor)
      .frame(maxWidth: .infinity)
      .frame(height: 50)
      .background(backgroundColor)
      .cornerRadius(12)
    }
  }
}
