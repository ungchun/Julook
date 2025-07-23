//
//  HomeRootView.swift
//  Packages
//
//  Created by Kim SungHun on 1/5/25.
//

import SwiftUI

import DesignSystem
import Core

import ComposableArchitecture

public struct HomeView: View {
  let store: StoreOf<HomeCore>
  
  public init(store: StoreOf<HomeCore>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      DesignSystemAsset.Colors.darkbase.swiftUIColor
        .ignoresSafeArea()
      
      ScrollView(showsIndicators: false) {
        VStack(spacing: 20) {
          HeaderView()
          
          MakgeolliFilterView(store: store)
          
          NewReleasesView(store: store)
          
          MakgeolliTopicView(store: store)
        }
      }
    }
    .onAppear { store.send(.onAppear) }
  }
}

// MARK: - HeaderView

private struct HeaderView: View {
  private let randomProfileIndex: Int
  
  fileprivate init() {
    self.randomProfileIndex = Int.random(in: 1...8)
  }
  
  fileprivate var body: some View {
    HStack {
      Text("모아보기")
        .foregroundColor(.w)
        .font(.SFTitle)
      
      Spacer()
      
      randomProfileImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 30, height: 30)
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 10)
    .padding(.top, 20)
  }
  
  private var randomProfileImage: Image {
    switch randomProfileIndex {
    case 1: return DesignSystemAsset.Images.p1.swiftUIImage
    case 2: return DesignSystemAsset.Images.p2.swiftUIImage
    case 3: return DesignSystemAsset.Images.p3.swiftUIImage
    case 4: return DesignSystemAsset.Images.p4.swiftUIImage
    case 5: return DesignSystemAsset.Images.p5.swiftUIImage
    case 6: return DesignSystemAsset.Images.p6.swiftUIImage
    case 7: return DesignSystemAsset.Images.p7.swiftUIImage
    case 8: return DesignSystemAsset.Images.p8.swiftUIImage
    default: return DesignSystemAsset.Images.p1.swiftUIImage
    }
  }
}

private struct MakgeolliFilterView: View {
  let store: StoreOf<HomeCore>
  
  fileprivate init(store: StoreOf<HomeCore>) {
    self.store = store
  }
  
  fileprivate var body: some View {
    VStack(spacing: 20) {
      HStack(alignment: .center, spacing: 8) {
        Text("특징으로 찾기")
          .foregroundColor(.w)
          .font(.SF20B)
        
        DesignSystemAsset.Images.arrowRight.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(height: 16)
          .foregroundColor(.w)
        
        Spacer()
      }
      .onTapGesture {
        Amp.track(event: "feature_filter_clicked")
        store.send(.filterButtonTapped)
      }
      .padding(.horizontal, 16)
      
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
          ForEach(FilterType.allCases) { filterType in
            VStack(spacing: 8) {
              filterType.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .background(Circle().fill(Color.darkgray))
                .clipShape(Circle())
              
              Text(filterType.description)
                .foregroundColor(.w85)
                .font(.SF12B)
            }
            .onTapGesture {
              Amp.track(event: "filter_type_clicked", properties: [
                "filter_type": filterType.description
              ])
              store.send(.filterItemTapped(filterType))
            }
          }
        }
        .padding(.horizontal, 16)
      }
    }
    .padding(.bottom, 20)
  }
}

// MARK: - NewReleasesView

private struct NewReleasesView: View {
  let store: StoreOf<HomeCore>
  
  fileprivate init(store: StoreOf<HomeCore>) {
    self.store = store
  }
  
  fileprivate var body: some View {
    VStack(spacing: 20) {
      HStack(alignment: .center, spacing: 8) {
        Text("새로 나왔어요")
          .foregroundColor(.w)
          .font(.SF20B)
        Spacer()
      }
      .padding(.horizontal, 16)
      
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 16) {
          if store.isLoadingNewReleases {
            ForEach(0..<5, id: \.self) { idx in
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.darkgray)
                .frame(width: 104, height: 240)
                .overlay(alignment: .center) {
                  ProgressView()
                    .frame(width: 50, height: 114)
                    .progressViewStyle(CircularProgressViewStyle(tint: .w))
                }
                .padding(.leading, idx == 0 ? 16 : 0)
            }
          } else {
            ForEach(Array(store.newReleases.enumerated()), id: \.element.id) { idx, makgeolli in
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.darkgray)
                .frame(width: 104, height: 240)
                .overlay {
                  VStack(spacing: 12) {
                    if let imageUrl = store.newReleasesImages[makgeolli.id] {
                      AsyncImage(url: imageUrl) { phase in
                        makeImageView(for: phase)
                      }
                    } else {
                      ProgressView()
                        .frame(width: 50, height: 114)
                    }
                    
                    Text(makgeolli.name)
                      .foregroundColor(.w)
                      .font(.SF12R)
                      .lineLimit(1)
                    
                    VStack(spacing: 0) {
                      Spacer()
                      HStack(alignment: .bottom, spacing: 4) {
                        VStack(spacing: 4) {
                          getChartImage(for: makgeolli.sweetness)
                          Text("단")
                            .foregroundColor(.w50)
                            .font(.SF10B)
                        }
                        
                        VStack(spacing: 4) {
                          getChartImage(for: makgeolli.sourness)
                          Text("신")
                            .foregroundColor(.w50)
                            .font(.SF10B)
                        }
                        
                        VStack(spacing: 4) {
                          getChartImage(for: makgeolli.thickness)
                          Text("걸")
                            .foregroundColor(.w50)
                            .font(.SF10B)
                        }
                        
                        VStack(spacing: 4) {
                          getChartImage(for: makgeolli.carbonation)
                          Text("탄")
                            .foregroundColor(.w50)
                            .font(.SF10B)
                        }
                      }
                    }
                  }
                  .padding(20)
                }
                .onTapGesture {
                  Amp.track(event: "new_release_clicked")
                  store.send(.newReleaseItemTapped(makgeolli))
                }
                .padding(.leading, idx == 0 ? 16 : 0)
            }
          }
        }
        .padding(.trailing, 16)
      }
    }
    .padding(.bottom, 20)
  }
}

private extension NewReleasesView {
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    switch phase {
    case .empty:
      return AnyView(
        ProgressView()
          .frame(width: 50, height: 114)
      )
    case .success(let image):
      return AnyView(
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 50, height: 114)
      )
    case .failure:
      return AnyView(defaultMakgeolliImage())
      
    @unknown default:
      return AnyView(defaultMakgeolliImage())
    }
  }
  
  func defaultMakgeolliImage() -> some View {
    DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 50, height: 114)
  }
}

private extension NewReleasesView {
  func getChartImage(for value: Int?) -> Image {
    guard let value = value else {
      return DesignSystemAsset.Images.nillChart.swiftUIImage
    }
    
    switch value {
    case 0:
      return DesignSystemAsset.Images._0Chart.swiftUIImage
    case 1:
      return DesignSystemAsset.Images._1Chart.swiftUIImage
    case 2:
      return DesignSystemAsset.Images._2Chart.swiftUIImage
    case 3:
      return DesignSystemAsset.Images._3Chart.swiftUIImage
    case 4:
      return DesignSystemAsset.Images._4Chart.swiftUIImage
    case 5:
      return DesignSystemAsset.Images._5Chart.swiftUIImage
    default:
      return DesignSystemAsset.Images.nillChart.swiftUIImage
    }
  }
}

// MARK: - MakgeolliTopicView

private struct MakgeolliTopicView: View {
  let store: StoreOf<HomeCore>
  
  fileprivate init(store: StoreOf<HomeCore>) {
    self.store = store
  }
  
  fileprivate var body: some View {
    VStack(spacing: 20) {
      HStack(alignment: .center, spacing: 8) {
        Text("주제로 찾기")
          .foregroundColor(.w)
          .font(.SF20B)
        Spacer()
      }
      .padding(.horizontal, 16)
      
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 16) {
          if store.isLoadingAwards {
            ForEach(0..<3, id: \.self) { idx in
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.darkgray)
                .frame(width: 160, height: 100)
                .overlay {
                  ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .w))
                }
                .padding(.leading, idx == 0 ? 16 : 0)
            }
          } else {
            ForEach(Array(store.awards.enumerated()), id: \.element.id) { idx, award in
              // TODO: set award enum
              if award.type == "korea_award" {
                RoundedRectangle(cornerRadius: 16)
                  .fill(LinearGradient.warmNeutral)
                  .frame(width: 160, height: 100)
                  .overlay {
                    HStack {
                      VStack {
                        Spacer()
                        let components = award.name.components(separatedBy: " ")
                        VStack(alignment: .leading, spacing: 0) {
                          ForEach(components, id: \.self) { component in
                            Text(component)
                              .foregroundColor(.w)
                              .font(.SF12B)
                          }
                        }
                        .padding(.bottom, 16)
                      }
                      Spacer()
                      VStack {
                        DesignSystemAsset.Images.koreaAwardsLogo.swiftUIImage
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(height: 48)
                          .padding(.top, 16)
                        Spacer()
                      }
                    }
                    .padding(.horizontal, 16)
                  }
                  .padding(.leading, idx == 0 ? 16 : 0)
                  .onTapGesture {
                    Amp.track(event: "topic_clicked", properties: [
                      "topic_name": award.name
                    ])
                    store.send(.topicItemTapped(award))
                  }
              }
            }
          }
        }
      }
    }
    .padding(.bottom, 20)
  }
}
