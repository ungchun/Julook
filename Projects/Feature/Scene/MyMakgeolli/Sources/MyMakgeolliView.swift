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
      
      VStack(spacing: 0) {
        HeaderView()
        FilterTabsView()
        
        Group {
          if store.state.isLoading {
            VStack(spacing: 20) {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            }
            .frame(maxHeight: .infinity)
          } else if store.state.myMakgeollis.isEmpty {
            VStack(spacing: 20) {
              Text("비어있어요")
                .foregroundColor(.w50)
                .font(.SF17R)
              
              DesignSystemAsset.Images.searchJulook.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(height: 140)
            }
            .frame(maxHeight: .infinity)
          } else {
            VStack(spacing: 0) {
              GeometryReader { geometry in
                ScrollView {
                  LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
                            spacing: 16) {
                    ForEach(store.state.myMakgeollis, id: \.id) { makgeolli in
                      MyMakgeolliGridItem(
                        makgeolli: makgeolli,
                        imageURL: store.state.makgeolliImages[makgeolli.id],
                        reactionType: getReactionType(for: makgeolli, state: store.state)
                      )
                      .frame(width: (geometry.size.width - 32 - 32) / 3)
                      .background(
                        Rectangle()
                          .fill(DesignSystemAsset.Colors.darkgray.swiftUIColor)
                          .cornerRadius(18)
                      )
                      .onTapGesture {
                        store.send(.myMakgeolliItemTapped(makgeolli))
                      }
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
    }
    .onAppear {
      store.send(.viewAppeared)
    }
  }
}

private extension MyMakgeolliView {
  @ViewBuilder
  func HeaderView() -> some View {
    ZStack {
      Text("내 막걸리")
        .font(.SF17B)
        .foregroundColor(.w)
      
      HStack {
#if DEBUG
        Button("초기화") {
          Task {
            do {
              try await CloudKitResetHelper.resetAllData()
              store.send(.loadReactionData)
            } catch {
              print("초기화 실패: \(error)")
            }
          }
        }
        .padding(.horizontal, 32)
        .foregroundColor(.red)
        .font(.SF12R)
#endif
        
        Spacer()
      }
    }
    .frame(height: 44)
  }
  
  @ViewBuilder
  func FilterTabsView() -> some View {
    GeometryReader { geometry in
      HStack(spacing: 0) {
        ForEach(MyMakgeolliFilterTab.allCases, id: \.self) { tab in
          VStack(spacing: 0) {
            Spacer()
            
            Text(tab.rawValue)
              .font(.SF15R)
              .foregroundColor(store.state.selectedTab == tab ? .w : .w50)
              .onTapGesture {
                store.send(.tabSelected(tab))
              }
            
            Spacer()
            
            Rectangle()
              .fill(store.state.selectedTab == tab ? .primary2 : Color.clear)
              .frame(height: 3)
              .animation(.easeInOut(duration: 0.2), value: store.state.selectedTab)
          }
          .frame(width: geometry.size.width / 4)
        }
      }
    }
    .frame(height: 44)
    .padding(.bottom, 16)
  }
  
  private func getReactionType(
    for makgeolli: MyMakgeolliEntity,
    state: MyMakgeolliCore.State
  ) -> String? {
    switch state.selectedTab {
    case .like:
      return state.likedMakgeollis.contains(where: { $0.id == makgeolli.id }) ? "like" : nil
    case .dislike:
      return state.dislikedMakgeollis.contains(where: { $0.id == makgeolli.id }) ? "dislike" : nil
    case .all:
      if state.likedMakgeollis.contains(where: { $0.id == makgeolli.id }) {
        return "like"
      } else if state.dislikedMakgeollis.contains(where: { $0.id == makgeolli.id }) {
        return "dislike"
      } else {
        return nil
      }
    case .favorite:
      if state.likedMakgeollis.contains(where: { $0.id == makgeolli.id }) {
        return "like"
      } else if state.dislikedMakgeollis.contains(where: { $0.id == makgeolli.id }) {
        return "dislike"
      } else {
        return nil
      }
    }
  }
}

private final class ImageCache: @unchecked Sendable {
  static let shared = ImageCache()
  private var cache: [String: UIImage] = [:]
  private let queue = DispatchQueue(label: "ImageCache", attributes: .concurrent)
  
  func getImage(for url: String) -> UIImage? {
    queue.sync {
      return cache[url]
    }
  }
  
  func setImage(_ image: UIImage, for url: String) {
    queue.async(flags: .barrier) {
      self.cache[url] = image
    }
  }
}

private struct MyMakgeolliGridItem: View {
  @State private var loadedImage: UIImage?
  @State private var isLoading = false
  
  let makgeolli: MyMakgeolliEntity
  let imageURL: URL?
  let reactionType: String?
  
  var body: some View {
    VStack(spacing: 12) {
      Group {
        if let loadedImage = loadedImage {
          Image(uiImage: loadedImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 120)
            .clipped()
            .cornerRadius(12)
        } else {
          DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 120)
            .cornerRadius(12)
            .opacity(isLoading ? 0.5 : 1.0)
        }
      }
      .onAppear {
        if let imageURL = imageURL, loadedImage == nil {
          if let cachedImage = ImageCache.shared.getImage(for: imageURL.absoluteString) {
            loadedImage = cachedImage
          } else {
            loadImage(from: imageURL)
          }
        }
      }
      .onChange(of: imageURL) { _, newURL in
        if let newURL = newURL, loadedImage == nil {
          if let cachedImage = ImageCache.shared.getImage(for: newURL.absoluteString) {
            loadedImage = cachedImage
          } else {
            loadImage(from: newURL)
          }
        }
      }
      
      Text(makgeolli.name)
        .font(.style(.SF12B))
        .foregroundColor(.white)
        .lineLimit(1)
        .multilineTextAlignment(.center)
      
      HStack(spacing: 12) {
        Group {
          if reactionType == "like" {
            DesignSystemAsset.Images.circleLike.swiftUIImage
              .resizable()
          } else if reactionType == "dislike" {
            DesignSystemAsset.Images.circleDislike.swiftUIImage
              .resizable()
          } else {
            DesignSystemAsset.Images.circleNone.swiftUIImage
              .resizable()
          }
        }
        .frame(width: 16, height: 16)
        
        Group {
          if makgeolli.isFavorite {
            DesignSystemAsset.Images.heartFill.swiftUIImage
              .resizable()
          } else {
            DesignSystemAsset.Images.heartNone.swiftUIImage
              .resizable()
          }
        }
        .frame(width: 16, height: 16)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 20)
  }
  
  private func loadImage(from url: URL) {
    guard !isLoading else { return }
    
    isLoading = true
    
    Task {
      do {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: data) {
          ImageCache.shared.setImage(uiImage, for: url.absoluteString)
          await MainActor.run {
            self.loadedImage = uiImage
            self.isLoading = false
          }
        } else {
          await MainActor.run {
            self.isLoading = false
          }
        }
      } catch {
        await MainActor.run {
          self.isLoading = false
        }
      }
    }
  }
  
  @ViewBuilder
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    switch phase {
    case .empty:
      DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 120)
        .cornerRadius(12)
    case .success(let image):
      image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 120)
        .clipped()
        .cornerRadius(12)
    case .failure(_):
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
