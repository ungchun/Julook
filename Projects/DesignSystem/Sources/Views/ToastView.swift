//
//  ToastView.swift
//  DesignSystem
//
//  Created by Kim SungHun on 7/13/25.
//

import SwiftUI

public struct ToastView: View {
  let message: String
  let type: ToastType
  
  @Binding var isShowing: Bool
  
  public init(
    message: String,
    type: ToastType = .error,
    isShowing: Binding<Bool>
  ) {
    self.message = message
    self.type = type
    self._isShowing = isShowing
  }
  
  public var body: some View {
    VStack {
      if isShowing {
        HStack(spacing: 12) {
          type.icon
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(type.iconColor)
          
          Text(message)
            .font(.style(.SF14R))
            .foregroundColor(type.textColor)
            .multilineTextAlignment(.leading)
          
          Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(type.backgroundColor)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
              isShowing = false
            }
          }
        }
      }
      
      Spacer()
    }
  }
}

public enum ToastType: String {
  case success = "success"
  case error = "error"
  case warning = "warning"
  case info = "info"
  
  var icon: Image {
    switch self {
    case .success:
      return Image(systemName: "checkmark.circle.fill")
    case .error:
      return Image(systemName: "xmark.circle.fill")
    case .warning:
      return Image(systemName: "exclamationmark.triangle.fill")
    case .info:
      return Image(systemName: "info.circle.fill")
    }
  }
  
  var backgroundColor: Color {
    switch self {
    case .success:
      return Color.green.opacity(0.9)
    case .error:
      return DesignSystemAsset.Colors.warmred.swiftUIColor.opacity(0.9)
    case .warning:
      return DesignSystemAsset.Colors.goldenyellow.swiftUIColor.opacity(0.9)
    case .info:
      return DesignSystemAsset.Colors.primary.swiftUIColor.opacity(0.9)
    }
  }
  
  var iconColor: Color {
    return .white
  }
  
  var textColor: Color {
    return .white
  }
}

public extension View {
  func toast(
    message: String,
    type: ToastType = .error,
    isShowing: Binding<Bool>
  ) -> some View {
    self.overlay(
      ToastView(message: message, type: type, isShowing: isShowing)
        .animation(.easeInOut(duration: 0.3), value: isShowing.wrappedValue),
      alignment: .top
    )
  }
}
