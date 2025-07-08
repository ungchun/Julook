//
//  MyMakgeolliView.swift
//  FeatureMyMakgeolli
//
//  Created by Kim SungHun on 7/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

public struct MyMakgeolliView: View {
  let store: StoreOf<MyMakgeolliCore>
  
  public init(store: StoreOf<MyMakgeolliCore>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      DesignSystemAsset.Colors.darkbase.swiftUIColor
        .ignoresSafeArea()
      
      Group {
        if store.state.myMakgeollis.isEmpty {
          VStack(spacing: 20) {
            Text("찜한 막걸리가 없어요.")
              .foregroundColor(.w50)
              .font(.SF17R)
            
            DesignSystemAsset.Images.searchJulook.swiftUIImage
              .resizable()
              .scaledToFit()
              .frame(height: 140)
          }
        } else {
          VStack(spacing: 0) {
            Text("내 막걸리")
              .foregroundStyle(DesignSystemAsset.Colors.w.swiftUIColor)
              .font(.SF17B)
              .padding(.top, 12)
              .padding(.bottom, 24)
            
            GeometryReader { geometry in
              ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                          spacing: 16) {
                  ForEach(store.state.myMakgeollis, id: \.id) { makgeolli in
                    MyMakgeolliGridItem(
                      makgeolli: makgeolli,
                      imageURL: store.state.makgeolliImages[makgeolli.id]
                    )
                    .frame(width: geometry.size.width / 3 - 16)
                    .background(
                      Rectangle()
                        .fill(DesignSystemAsset.Colors.darkgray.swiftUIColor)
                        .cornerRadius(18)
                    )
                  }
                }.padding(.horizontal, 16)
                
                Spacer()
                  .frame(height: 16)
              }
            }
          }
        }
      }
    }
    .onAppear {
      store.send(.viewAppeared)
    }
  }
}

private struct MyMakgeolliGridItem: View {
  let makgeolli: MyMakgeolliEntity
  let imageURL: URL?
  
  var body: some View {
    VStack(spacing: 12) {
      if let imageURL = imageURL {
        AsyncImage(url: imageURL) { phase in
          makeImageView(for: phase)
        }
      } else {
        ProgressView()
          .frame(width: 50, height: 120)
      }
      
      Text(makgeolli.name)
        .font(.style(.SF12B))
        .foregroundColor(.white)
        .lineLimit(1)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 20)
  }
  
  @ViewBuilder
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    switch phase {
    case .empty:
      ProgressView()
        .frame(width: 50, height: 120)
    case .success(let image):
      image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 120)
        .clipped()
        .cornerRadius(12)
    case .failure:
      DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 120)
        .cornerRadius(12)
    @unknown default:
      DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 120)
        .cornerRadius(12)
    }
  }
}
