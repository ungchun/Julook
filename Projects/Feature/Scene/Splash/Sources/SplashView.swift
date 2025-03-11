//
//  SplashView.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/9/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import DesignSystem

import ComposableArchitecture

public struct SplashView: View {
  let store: StoreOf<SplashCore>
  
  public init(store: StoreOf<SplashCore>) {
    self.store = store
  }
  
  private var imageFrames: [Image] {
    [
      DesignSystemAsset.Images.s1.swiftUIImage,
      DesignSystemAsset.Images.s2.swiftUIImage,
      DesignSystemAsset.Images.s3.swiftUIImage,
      DesignSystemAsset.Images.s4.swiftUIImage,
      DesignSystemAsset.Images.s5.swiftUIImage,
      DesignSystemAsset.Images.s6.swiftUIImage,
      DesignSystemAsset.Images.s7.swiftUIImage,
      DesignSystemAsset.Images.s8.swiftUIImage,
      DesignSystemAsset.Images.s9.swiftUIImage,
      DesignSystemAsset.Images.s10.swiftUIImage,
      DesignSystemAsset.Images.s11.swiftUIImage,
      DesignSystemAsset.Images.s12.swiftUIImage,
      DesignSystemAsset.Images.s13.swiftUIImage,
      DesignSystemAsset.Images.s14.swiftUIImage,
      DesignSystemAsset.Images.s15.swiftUIImage,
      DesignSystemAsset.Images.s16.swiftUIImage,
      DesignSystemAsset.Images.s17.swiftUIImage,
      DesignSystemAsset.Images.s18.swiftUIImage,
      DesignSystemAsset.Images.s19.swiftUIImage,
      DesignSystemAsset.Images.s20.swiftUIImage
    ]
  }
  
  public var body: some View {
    VStack {
      imageFrames[store.currentImageIndex]
        .resizable()
        .scaledToFit()
        .frame(width: 160)
        .aspectRatio(contentMode: .fit)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(DesignSystemAsset.Colors.darkbase.swiftUIColor)
    .ignoresSafeArea()
    .onAppear {
      store.send(.onAppear)
    }
  }
}
