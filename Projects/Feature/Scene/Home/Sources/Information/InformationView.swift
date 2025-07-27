//
//  InformationView.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/11/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

public struct InformationView: View {
  let store: StoreOf<InformationCore>
  
  public init(store: StoreOf<InformationCore>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      DesignSystemAsset.Colors.darkbase.swiftUIColor
        .ignoresSafeArea()
      
      ScrollView {
        VStack(spacing: 0) {
          NavigationBar()
          
          MakgeolliDetailSectionView()
          
          ReactionButtonsView()
          
          AwardsView()
          
          MakgeolliDescriptionSection()
          
          MakgeolliIngredientsSection()
          
          MakgeolliInformationSection()
        }
        .padding(.horizontal, 16)
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}

private extension InformationView {
  @ViewBuilder
  func NavigationBar() -> some View {
    HStack {
      Image(systemName: store.state.isFavorite ? "heart.fill" : "heart")
        .font(.SF24B)
        .foregroundColor(store.state.isFavorite ? .red : .w25)
        .onTapGesture {
          store.send(.favoriteButtonTapped)
        }
      Spacer()
      DesignSystemAsset.Images.close.swiftUIImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 26)
        .onTapGesture {
          store.send(.dismiss)
        }
    }
    .frame(height: 40)
    .padding(.top, 4)
    .padding(.bottom, 32)
  }
}

private extension InformationView {
  @ViewBuilder
  func MakgeolliDetailSectionView() -> some View {
    ZStack {
      Circle()
        .fill(LinearGradient.lilacNeutral)
        .frame(width: 234, height: 234)
        .offset(y: -40)
      
      if let imageURL = store.state.makgeolliImage {
        AsyncImage(url: imageURL) { phase in
          switch phase {
          case .empty:
            ProgressView()
              .frame(height: 244)
          case .success(let image):
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 244)
              .clipped()
          case .failure:
            DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 244)
          @unknown default:
            DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 244)
          }
        }
      }
    }
    .padding(.bottom, 32)
    
    VStack(spacing: 4) {
      Text(store.state.makgeolli.name)
        .foregroundColor(.w)
        .font(.SF24B)
        .lineLimit(1)
      
      Text(
        "\(formatValue(store.state.makgeolli.alcoholPercentage))도 ･ \(formatValue(store.state.makgeolli.volume))ml ･ \(formatValue(store.state.makgeolli.price))원"
      )
      .foregroundColor(.w50)
      .font(.SF15R)
      .lineLimit(1)
    }
    .padding(.bottom, 16)
    
    HStack(spacing: 16) {
      VStack(spacing: 6) {
        getScoreImage(for: store.state.makgeolli.sweetness)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 44, height: 44)
        
        Text("단맛")
          .foregroundColor(.w50)
          .font(.SF12B)
      }
      
      VStack(spacing: 6) {
        getScoreImage(for: store.state.makgeolli.sourness)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 44, height: 44)
        
        Text("신맛")
          .foregroundColor(.w50)
          .font(.SF12B)
      }
      
      VStack(spacing: 6) {
        getScoreImage(for: store.state.makgeolli.thickness)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 44, height: 44)
        
        Text("걸쭉")
          .foregroundColor(.w50)
          .font(.SF12B)
      }
      
      VStack(spacing: 6) {
        getScoreImage(for: store.state.makgeolli.carbonation)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 44, height: 44)
        
        Text("탄산")
          .foregroundColor(.w50)
          .font(.SF12B)
      }
    }
    .padding(.bottom, 32)
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
  
  func formatValue<T>(_ value: T?) -> String {
    guard let value = value else { return "-" }
    return "\(value)"
  }
}

private extension InformationView {
  @ViewBuilder
  func ReactionButtonsView() -> some View {
    HStack(spacing: 12) {
      ReactionButton(
        state: store.state.dislikeButtonState,
        type: .dislike,
        text: "아쉬워요",
        action: {
          store.send(.dislikeButtonTapped)
        }
      )
      
      ReactionButton(
        state: store.state.likeButtonState,
        type: .like,
        text: "좋았어요",
        action: {
          store.send(.likeButtonTapped)
        }
      )
    }
    .padding(.bottom, 40)
  }
}

private extension InformationView {
  @ViewBuilder
  func AwardsView() -> some View {
    if let awards = store.state.makgeolli.awards, !awards.isEmpty {
      VStack(spacing: 0) {
        Group {
          if awards.count == 1 {
            SingleAwardView(award: awards[0])
          } else if awards.count == 2 {
            TwoAwardsView(awards: awards)
          } else {
            ThreeAwardsView(awards: awards)
          }
        }
        .padding(.bottom, 24)
        
        Rectangle()
          .fill(Color.w25)
          .frame(height: 1)
      }
      .padding(.bottom, 40)
    }
  }
  
  @ViewBuilder
  func SingleAwardView(award: String) -> some View {
    let awardComponents = parseAward(award)
    HStack {
      AwardContentView(
        year: awardComponents.year,
        competition: awardComponents.competition,
        prize: awardComponents.prize
      )
      Spacer()
    }
  }
  
  @ViewBuilder
  func TwoAwardsView(awards: [String]) -> some View {
    HStack(spacing: 12) {
      ForEach(0..<2) { index in
        let awardComponents = parseAward(awards[index])
        HStack(spacing: 0) {
          if index == 1 {
            Rectangle()
              .fill(Color.w25)
              .frame(width: 1, height: 58)
              .padding(.trailing, 16)
          }
          AwardContentView(
            year: awardComponents.year,
            competition: awardComponents.competition,
            prize: awardComponents.prize
          )
        }
        Spacer()
      }
    }
  }
  
  @ViewBuilder
  func ThreeAwardsView(awards: [String]) -> some View {
    HStack(spacing: 12) {
      ForEach(0..<3) { index in
        let awardComponents = parseAward(awards[index])
        HStack(spacing: 0) {
          if index == 1 || index == 2 {
            Rectangle()
              .fill(Color.w25)
              .frame(width: 1, height: 58)
              .padding(.trailing, 16)
          }
          AwardContentView(
            year: awardComponents.year,
            competition: awardComponents.competition,
            prize: awardComponents.prize
          )
        }
        Spacer()
      }
    }
  }
  
  @ViewBuilder
  func AwardContentView(year: String, competition: String, prize: String) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(year)
        .foregroundColor(.w50)
        .font(.SF12R)
      
      Text(competition)
        .foregroundColor(.w50)
        .font(.SF12R)
      
      Text(prize)
        .foregroundColor(.w)
        .font(.SF17R)
        .padding(.top, 4)
    }
  }
  
  private func parseAward(_ award: String) -> (
    year: String, competition: String, prize: String
  ) {
    let components = award.components(separatedBy: " ")
    if components.count >= 3 {
      let year = components[0]
      let prize = components.last ?? ""
      let competition = components.dropFirst().dropLast().joined(separator: " ")
      
      return (year, competition, prize)
    } else if components.count == 2 {
      return (components[0], "", components[1])
    } else {
      return ("", "", components[0])
    }
  }
}

private extension InformationView {
  @ViewBuilder
  func MakgeolliDescriptionSection() -> some View {
    if let description = store.makgeolli.description {
      HStack {
        VStack(alignment: .leading, spacing: 20) {
          Text("소개")
            .font(.SF20B)
          
          Text(description)
            .font(.SF14R)
        }
        Spacer()
      }
      .padding(.bottom, 40)
    }
  }
}

private extension InformationView {
  @ViewBuilder
  func MakgeolliIngredientsSection() -> some View {
    if let ingredients = store.makgeolli.ingredients {
      HStack {
        VStack(alignment: .leading, spacing: 0) {
          Text("원재료")
            .foregroundColor(.w)
            .font(.SF20B)
            .padding(.bottom, 20)
          
          Text(ingredients.joined(separator: ", "))
            .foregroundColor(.w85)
            .font(.SF14R)
            .multilineTextAlignment(.leading)
            .padding(.bottom, 16)
          
          Text("정보출처: 식품안전나라")
            .foregroundColor(.w25)
            .font(.SF12B)
        }
        Spacer()
      }
      .padding(.bottom, 40)
    }
  }
}

private extension InformationView {
  @ViewBuilder
  func MakgeolliInformationSection() -> some View {
    if store.makgeolli.brewery != nil ||
        store.makgeolli.website != nil ||
        store.makgeolli.purchaseLink != nil {
      VStack(alignment: .leading, spacing: 0) {
        Text("정보")
          .foregroundColor(.w)
          .font(.SF20B)
          .padding(.bottom, 20)
        
        if let brewery = store.makgeolli.brewery {
          HStack {
            Text("양조장")
              .foregroundColor(.w85)
              .font(.SF14R)
            Spacer()
            if let website = store.makgeolli.website {
              Text(brewery)
                .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
                .font(.SF14R)
                .onTapGesture {
                  if let url = URL(string: website) {
                    UIApplication.shared.open(url)
                  }
                }
            } else {
              Text(brewery)
                .foregroundColor(.w)
                .font(.SF14R)
            }
          }
        }
        
        Divider()
          .padding(.vertical, 12)
        
        if let purchaseLink = store.makgeolli.purchaseLink {
          HStack {
            Text("판매링크")
              .foregroundColor(.w85)
              .font(.SF14R)
            Spacer()
            Text("공식몰")
              .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
              .font(.SF14R)
              .onTapGesture {
                if let url = URL(string: purchaseLink) {
                  UIApplication.shared.open(url)
                }
              }
          }
        }
      }
      .padding(.bottom, 40)
    }
  }
}
