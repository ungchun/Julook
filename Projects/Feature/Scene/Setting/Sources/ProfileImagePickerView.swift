//
//  ProfileImagePickerView.swift
//  FeatureSetting
//
//  Created by Kim SungHun on 9/23/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

public struct ProfileImagePickerView: View {
  let store: StoreOf<ProfileImagePickerCore>
  
  public init(store: StoreOf<ProfileImagePickerCore>) {
    self.store = store
  }
  
  private let profileImages = ["p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8"]
  
  public var body: some View {
    ZStack {
      DesignSystemAsset.Colors.darkbase.swiftUIColor
        .ignoresSafeArea(.all)
      
      VStack(spacing: 0) {
        HStack {
          Spacer()
          
          Button(action: {
            store.send(.dismiss)
          }) {
            DesignSystemAsset.Images.close.swiftUIImage
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 26)
          }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        
        Spacer()
        
        VStack(spacing: 16) {
          
          HStack(spacing: 0) {
            Text("아이콘")
              .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
              .font(.SF24B)
            Text(" 변경")
              .foregroundColor(.w)
              .font(.SF24B)
          }
          .padding(.bottom, 8)
          
          HStack(spacing: 16) {
            ForEach(Array(profileImages.prefix(4)), id: \.self) { imageName in
              Button(action: {
                store.send(.profileImageSelected(imageName))
              }) {
                profileImageView(for: imageName)
                  .frame(width: 50, height: 50)
                  .opacity(store.selectedProfileImage == imageName ? 1.0 : 0.2)
              }
            }
          }
          
          HStack(spacing: 16) {
            ForEach(Array(profileImages.suffix(4)), id: \.self) { imageName in
              Button(action: {
                store.send(.profileImageSelected(imageName))
              }) {
                profileImageView(for: imageName)
                  .frame(width: 50, height: 50)
                  .opacity(store.selectedProfileImage == imageName ? 1.0 : 0.2)
              }
            }
          }
        }
        
        Spacer()
        
        Button(action: {
          if store.selectedProfileImage != store.currentUserProfileImage {
            store.send(.saveButtonTapped)
          }
        }) {
          Text("저장")
            .foregroundColor(
              store.selectedProfileImage != store.currentUserProfileImage ? .w : .w25
            )
            .font(.SF17R)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(
                  store.selectedProfileImage != store.currentUserProfileImage
                  ? DesignSystemAsset.Colors.goldenyellow.swiftUIColor : .w10
                )
            )
        }
        .disabled(store.selectedProfileImage == store.currentUserProfileImage)
        .padding(.horizontal, 32)
        .padding(.bottom, 40)
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}

private extension ProfileImagePickerView {
  func profileImageView(for imageName: String) -> some View {
    switch imageName {
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
