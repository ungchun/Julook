//
//  SettingView.swift
//  FeatureHome
//
//  Created by Kim SungHun on 9/21/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import DesignSystem
import Core

import ComposableArchitecture

public struct SettingView: View {
  let store: StoreOf<SettingCore>
  
  public init(store: StoreOf<SettingCore>) {
    self.store = store
  }
  
  private var appVersion: String {
    guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
      return "1.0.0"
    }
    return version
  }
  
  public var body: some View {
    ZStack(alignment: .top) {
      Color.darkgray
        .ignoresSafeArea(edges: .top)
        .frame(height: 300)
        .overlay(
          VStack(spacing: 16) {
            Spacer()
            
            if store.isLoadingUser {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
              let profileImage = store.user?.profileImage ?? "p\(Int.random(in: 1...8))"
              let nickname = store.user?.nickname ?? ""

              VStack(spacing: 24) {
                Button(action: {
                  store.send(.profileImageTapped)
                }) {
                  profileImageView(for: profileImage)
                    .frame(width: 70, height: 70)
                }

                Text(nickname.isEmpty ? "닉네임을 설정해주세요" : nickname)
                  .foregroundColor(nickname.isEmpty ? .w85 : .w)
                  .font(nickname.isEmpty ? .SF17B : .SF20B)

                Button(action: {
                  store.send(.nicknameChangeTapped)
                }) {
                  Text("닉네임 변경")
                    .foregroundColor(.w85)
                    .font(.SF17R)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                      RoundedRectangle(cornerRadius: 12)
                        .fill(Color.w10)
                    )
                }
                .padding(.horizontal, 44)
              }
            }
            
            Spacer()
              .frame(height: 20)
          }
        )
      
      VStack(spacing: 0) {
        Color.clear
          .frame(height: 300)
        
        Spacer()
          .frame(height: 24)
        
        ScrollView(.vertical, showsIndicators: false) {
          VStack(spacing: 0) {
            MenuItemView(title: "문의하기", hasArrow: true, showDivider: true) {
              store.send(.contactTapped)
            }
            MenuItemView(title: "리뷰 남기기", hasArrow: true, showDivider: true) {
              store.send(.reviewTapped)
            }
            MenuItemView(title: "이용약관", hasArrow: true, showDivider: true) {
              store.send(.termsTapped)
            }
            MenuItemView(title: "개인정보처리방침", hasArrow: true, showDivider: true) {
              store.send(.privacyTapped)
            }
            MenuItemView(
              title: "버전 정보", hasArrow: false, rightText: appVersion, showDivider: false
            )
          }
        }
        .background(DesignSystemAsset.Colors.darkbase.swiftUIColor)
      }
    }
    .background(DesignSystemAsset.Colors.darkbase.swiftUIColor)
    .onAppear {
      store.send(.onAppear)
    }
  }
}

private extension SettingView {
  func profileImageView(for imageName: String) -> some View {
    let profileImageName = imageName.isEmpty ? "p1" : imageName
    
    switch profileImageName {
    case "p1": return AnyView(
      DesignSystemAsset.Images.p1.swiftUIImage.resizable().aspectRatio(contentMode: .fit)
    )
    case "p2": return AnyView(
      DesignSystemAsset.Images.p2.swiftUIImage.resizable().aspectRatio(contentMode: .fit)
    )
    case "p3": return AnyView(
      DesignSystemAsset.Images.p3.swiftUIImage.resizable().aspectRatio(contentMode: .fit)
    )
    case "p4": return AnyView(
      DesignSystemAsset.Images.p4.swiftUIImage.resizable().aspectRatio(contentMode: .fit)
    )
    case "p5": return AnyView(
      DesignSystemAsset.Images.p5.swiftUIImage.resizable().aspectRatio(contentMode: .fit)
    )
    case "p6": return AnyView(
      DesignSystemAsset.Images.p6.swiftUIImage.resizable().aspectRatio(contentMode: .fit)
    )
    case "p7": return AnyView(
      DesignSystemAsset.Images.p7.swiftUIImage.resizable().aspectRatio(contentMode: .fit)
    )
    case "p8": return AnyView(
      DesignSystemAsset.Images.p8.swiftUIImage.resizable().aspectRatio(contentMode: .fit)
    )
    default: return AnyView(
      DesignSystemAsset.Images.p1.swiftUIImage.resizable().aspectRatio(contentMode: .fit)
    )
    }
  }
}

private struct MenuItemView: View {
  let title: String
  let hasArrow: Bool
  let rightText: String?
  let showDivider: Bool
  let action: (() -> Void)?
  
  init(
    title: String,
    hasArrow: Bool,
    rightText: String? = nil,
    showDivider: Bool = true,
    action: (() -> Void)? = nil
  ) {
    self.title = title
    self.hasArrow = hasArrow
    self.rightText = rightText
    self.showDivider = showDivider
    self.action = action
  }
  
  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Text(title)
          .foregroundColor(.w)
          .font(.SF17R)
        
        Spacer()
        
        if let rightText = rightText {
          Text(rightText)
            .foregroundColor(.w)
            .font(.SF12B)
        }
        
        if hasArrow {
          DesignSystemAsset.Images.arrowRight.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 16)
            .foregroundColor(.w)
        }
      }
      
      if showDivider {
        Divider()
          .padding(.vertical, 16)
      }
    }
    .padding(.horizontal, 16)
    .background(
      Rectangle()
        .fill(DesignSystemAsset.Colors.darkbase.swiftUIColor)
    )
    .contentShape(Rectangle())
    .onTapGesture {
      action?()
    }
  }
}
