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
          
          RandomMakgeolliView(store: store)
          
          TodaysRankingView(store: store)
          
          NewReleasesView(store: store)
          
          MakgeolliTopicView(store: store)
          
          RecentCommentsView(store: store)
        }
      }
    }
    .onAppear { store.send(.onAppear) }
  }
}

// MARK: - HeaderView

private struct HeaderView: View {
  @State private var isPresentingSettings = false
  
  fileprivate init() {}
  
  fileprivate var body: some View {
    HStack {
      Text("모아보기")
        .foregroundColor(.w)
        .font(.SFTitle)
      
      Spacer()
      
      Image(systemName: "gearshape.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 24, height: 24)
        .foregroundColor(.w50)
        .onTapGesture {
          Amp.track(event: "settings_icon_clicked")
          isPresentingSettings = true
        }
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 10)
    .padding(.top, 20)
    .sheet(isPresented: $isPresentingSettings) {
      SettingsSheetView()
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

// MARK: - TodaysRankingView

private struct TodaysRankingView: View {
  let store: StoreOf<HomeCore>
  
  fileprivate init(store: StoreOf<HomeCore>) {
    self.store = store
  }
  
  fileprivate var body: some View {
    VStack(spacing: 20) {
      HStack(alignment: .center, spacing: 8) {
        Text("인기 막걸리")
          .foregroundColor(.w)
          .font(.SF20B)
        Spacer()
      }
      
      VStack(alignment: .leading, spacing: 0) {
        ForEach(Array(store.topLikedMakgeollis.enumerated()), id: \.element.id) {
          idx, makgeolli in
          HStack(alignment: .center, spacing: 16) {
            Text("\(idx+1)")
              .foregroundColor(.w)
              .font(.SF24B)
            
            Group {
              if let imageUrl = store.topLikedImages[makgeolli.id] {
                AsyncImage(url: imageUrl) { phase in
                  makeImageView(for: phase)
                }
              } else {
                ProgressView()
                  .frame(width: 30, height: 60)
              }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
              Rectangle()
                .fill(DesignSystemAsset.Colors.darkgray.swiftUIColor)
                .cornerRadius(12)
            )
            
            VStack(alignment: .leading, spacing: 8) {
              Text(makgeolli.name)
                .foregroundColor(.w)
                .font(.SF12R)
                .lineLimit(1)
              
              HStack(spacing: 6) {
                VStack(spacing: 6) {
                  getScoreImage(for: makgeolli.sweetness)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                  
                  Text("단맛")
                    .foregroundColor(.w50)
                    .font(.SF10B)
                }
                
                VStack(spacing: 6) {
                  getScoreImage(for: makgeolli.sourness)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                  
                  Text("신맛")
                    .foregroundColor(.w50)
                    .font(.SF10B)
                }
                
                VStack(spacing: 6) {
                  getScoreImage(for: makgeolli.thickness)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                  
                  Text("걸쭉")
                    .foregroundColor(.w50)
                    .font(.SF10B)
                }
                
                VStack(spacing: 6) {
                  getScoreImage(for: makgeolli.carbonation)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                  
                  Text("탄산")
                    .foregroundColor(.w50)
                    .font(.SF10B)
                }
              }
            }
            .layoutPriority(1)
            
            Spacer()
            
            Image(systemName: (
              store.topLikedFavoriteStatus[makgeolli.id] ?? false
            ) ? "heart.fill" : "heart")
            .font(.SF24B)
            .foregroundColor(
              (store.topLikedFavoriteStatus[makgeolli.id] ?? false) ? .red : .w25
            )
            .frame(width: 24, height: 24)
            .onTapGesture {
              store.send(.topLikedFavoriteButtonTapped(makgeolli))
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
            Amp.track(event: "top_liked_clicked", properties: [
              "ranking": idx + 1,
              "makgeolli_name": makgeolli.name
            ])
            store.send(.topLikedItemTapped(makgeolli))
          }
          
          if idx != 2 {
            Divider()
              .padding(.vertical, 12)
          }
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 20)
  }
}

private extension TodaysRankingView {
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    switch phase {
    case .empty:
      return AnyView(
        ProgressView()
          .frame(width: 30, height: 60)
      )
    case .success(let image):
      return AnyView(
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
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
      .frame(width: 30, height: 60)
  }
  
  func getScoreImage(for score: Int?) -> Image {
    guard let score = score else {
      return DesignSystemAsset.Images.nillScore.swiftUIImage
    }
    
    switch score {
    case 0:
      return DesignSystemAsset.Images._0Score.swiftUIImage
    case 1:
      return DesignSystemAsset.Images._1Score.swiftUIImage
    case 2:
      return DesignSystemAsset.Images._2Score.swiftUIImage
    case 3:
      return DesignSystemAsset.Images._3Score.swiftUIImage
    case 4:
      return DesignSystemAsset.Images._4Score.swiftUIImage
    case 5:
      return DesignSystemAsset.Images._5Score.swiftUIImage
    default:
      return DesignSystemAsset.Images.nillScore.swiftUIImage
    }
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

// MARK: - RandomMakgeolliView

private struct RandomMakgeolliView: View {
  let store: StoreOf<HomeCore>
  
  fileprivate init(store: StoreOf<HomeCore>) {
    self.store = store
  }
  
  fileprivate var body: some View {
    VStack(spacing: 20) {
      HStack(alignment: .center, spacing: 8) {
        Text("이 막걸리는 어때요?")
          .foregroundColor(.w)
          .font(.SF20B)
        Spacer()
      }
      .padding(.horizontal, 16)
      
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 16) {
          if store.isLoadingRandomMakgeollis {
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
            ForEach(
              Array(store.randomMakgeollis.enumerated()), id: \.element.id
            ) { idx, makgeolli in
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.darkgray)
                .frame(width: 104, height: 240)
                .overlay {
                  VStack(spacing: 12) {
                    if let imageUrl = store.randomMakgeolliImages[makgeolli.id] {
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
                  Amp.track(event: "random_makgeolli_clicked")
                  store.send(.randomMakgeolliItemTapped(makgeolli))
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

private extension RandomMakgeolliView {
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

private extension RandomMakgeolliView {
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

// MARK: - RecentCommentsView

private struct RecentCommentsView: View {
  let store: StoreOf<HomeCore>
  
  fileprivate init(store: StoreOf<HomeCore>) {
    self.store = store
  }
  
  fileprivate var body: some View {
    VStack(spacing: 20) {
      HStack(alignment: .center, spacing: 8) {
        Text("코멘트가 달렸어요")
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
        Amp.track(event: "comment_list_header_clicked")
        store.send(.moveToCommentList)
      }
      .padding(.horizontal, 16)
      
      if store.isLoadingRecentComments {
        VStack(spacing: 12) {
          ForEach(0..<4, id: \.self) { _ in
            HStack(spacing: 16) {
              RoundedRectangle(cornerRadius: 12)
                .fill(Color.darkgray)
                .frame(width: 60, height: 60)
              
              VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                  .fill(Color.darkgray)
                  .frame(height: 16)
                
                RoundedRectangle(cornerRadius: 4)
                  .fill(Color.darkgray)
                  .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 4)
                  .fill(Color.darkgray)
                  .frame(width: 80, height: 12)
              }
              
              Spacer()
            }
            .padding(.horizontal, 16)
          }
        }
      } else {
        VStack(alignment: .leading, spacing: 0) {
          ForEach(Array(store.recentComments.enumerated()), id: \.element.id) { idx, comment in
            if let makgeolli = store.recentCommentMakgeollis[comment.makgeolliId] {
              RecentCommentItemView(
                comment: comment,
                makgeolli: makgeolli,
                imageUrl: store.recentCommentImages[makgeolli.id],
                reactionType: store.recentCommentReactions[comment.id],
                isLast: idx == store.recentComments.count - 1,
                onTap: {
                  Amp.track(event: "recent_comment_clicked", properties: [
                    "makgeolli_name": makgeolli.name
                  ])
                  store.send(.recentCommentItemTapped(comment))
                }
              )
              .equatable()
            }
          }
        }
        .padding(.horizontal, 16)
      }
    }
    .padding(.bottom, 20)
  }
}

private extension RecentCommentsView {
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    switch phase {
    case .empty:
      return AnyView(
        ProgressView()
          .frame(width: 30, height: 60)
      )
    case .success(let image):
      return AnyView(
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
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
      .frame(width: 30, height: 60)
  }
  
  func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 M월 d일"
    return formatter.string(from: date)
  }
}

private struct RecentCommentItemView: View, Equatable {
  let comment: UserComment
  let makgeolli: Makgeolli
  let imageUrl: URL?
  let reactionType: String?
  let isLast: Bool
  let onTap: () -> Void
  
  nonisolated static func == (lhs: RecentCommentItemView, rhs: RecentCommentItemView) -> Bool {
    lhs.comment.id == rhs.comment.id &&
    lhs.makgeolli.id == rhs.makgeolli.id &&
    lhs.imageUrl?.absoluteString == rhs.imageUrl?.absoluteString &&
    lhs.reactionType == rhs.reactionType &&
    lhs.isLast == rhs.isLast
  }
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .top, spacing: 16) {
        RecentCommentImageView(imageUrl: imageUrl)
          .padding(.vertical, 12)
          .padding(.horizontal, 16)
          .background(
            Rectangle()
              .fill(DesignSystemAsset.Colors.darkgray.swiftUIColor)
              .cornerRadius(12)
          )
        
        VStack(alignment: .leading, spacing: 4) {
          HStack(spacing: 8) {
            Text(makgeolli.name)
              .foregroundColor(.w)
              .font(.SF14R)
              .lineLimit(1)
            
            Group {
              if let reactionType = reactionType {
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
              } else {
                DesignSystemAsset.Images.circleNone.swiftUIImage
                  .resizable()
              }
            }
            .frame(width: 12, height: 12)
          }
          
          Text(comment.comment)
            .foregroundColor(.w85)
            .font(.SF14R)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
          
          Spacer()
          
          Text(formatDate(comment.createdAt))
            .foregroundColor(.w50)
            .font(.SF12R)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .contentShape(Rectangle())
      .onTapGesture {
        onTap()
      }
      
      if !isLast {
        Divider()
          .padding(.vertical, 12)
      }
    }
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 M월 d일"
    return formatter.string(from: date)
  }
}

private struct RecentCommentImageView: View {
  let imageUrl: URL?
  
  @State private var loadedImage: UIImage?
  @State private var isLoading = false
  @State private var hasFailed = false
  
  var body: some View {
    Group {
      if let loadedImage = loadedImage {
        Image(uiImage: loadedImage)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
      } else if hasFailed {
        defaultMakgeolliImage()
      } else {
        ProgressView()
          .frame(width: 30, height: 60)
      }
    }
    .task(id: imageUrl?.absoluteString) {
      guard let imageUrl = imageUrl, loadedImage == nil, !isLoading else { return }
      
      isLoading = true
      hasFailed = false
      
      do {
        let (data, _) = try await URLSession.shared.data(from: imageUrl)
        if let image = UIImage(data: data) {
          loadedImage = image
        } else {
          hasFailed = true
        }
      } catch {
        hasFailed = true
      }
      
      isLoading = false
    }
  }
  
  private func defaultMakgeolliImage() -> some View {
    DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 30, height: 60)
  }
}

private struct SettingsSheetView: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.openURL) var openURL
  
  var body: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(Color.w10)
        .frame(width: 36, height: 5)
        .padding(.top, 8)
        .padding(.bottom, 20)
      
      SettingRowView(title: "문의하기", showArrow: true) {
        Amp.track(event: "settings_inquiry_clicked")
        if let url = URL(string: "mailto:leedool3003@gmail.com") {
          openURL(url)
        }
      }
      
      Divider()
        .background(Color.w25)
        .padding(.horizontal, 16)
      
      SettingRowView(title: "리뷰 남기기", showArrow: true) {
        Amp.track(event: "settings_review_clicked")
        let reviewURL = "https://apps.apple.com/app/id6743315707?action=write-review"
        if let url = URL(string: reviewURL) {
          UIApplication.shared.open(url)
        }
      }
      
      Divider()
        .background(Color.w25)
        .padding(.horizontal, 16)
      
      SettingRowView(title: "이용약관", showArrow: true) {
        Amp.track(event: "settings_terms_clicked")
        if let url = URL(
          string: "https://yawner.notion.site/1c792ec2705581ec8b98d5b25d5d94ab?source=copy_link"
        ) {
          openURL(url)
        }
      }
      
      Divider()
        .background(Color.w25)
        .padding(.horizontal, 16)
      
      SettingRowView(title: "개인정보처리방침", showArrow: true) {
        Amp.track(event: "settings_privacy_clicked")
        if let url = URL(
          string: "https://yawner.notion.site/1c792ec270558160a0f0c57392e4d1de?source=copy_link"
        ) {
          openURL(url)
        }
      }
      
      Divider()
        .background(Color.w25)
        .padding(.horizontal, 16)
      
      HStack {
        Text("버전 정보")
          .foregroundColor(.w)
          .font(.SF17R)
        
        Spacer()
        
        Text(appVersion)
          .foregroundColor(.w85)
          .font(.SF12B)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 16)
      
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(DesignSystemAsset.Colors.darkbase.swiftUIColor)
  }
  
  private var appVersion: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    return version
  }
}

private extension SettingsSheetView {
  struct SettingRowView: View {
    let title: String
    let showArrow: Bool
    let action: () -> Void
    
    var body: some View {
      Button(action: action) {
        HStack {
          Text(title)
            .foregroundColor(.w)
            .font(.SF17R)
          
          Spacer()
          
          if showArrow {
            Image(systemName: "chevron.right")
              .foregroundColor(.w)
              .font(.system(size: 20, weight: .bold))
          }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
}
