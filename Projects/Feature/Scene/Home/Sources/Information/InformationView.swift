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
          
          MyCommentSection()
          
          AwardsView()
          
          MakgeolliDescriptionSection()
          
          MakgeolliEvaluationAndCommentsSection()
          
          MakgeolliIngredientsSection()
          
          MakgeolliInformationSection()
        }
        .padding(.horizontal, 16)
      }
    }
    .accentColor(DesignSystemAsset.Colors.primary.swiftUIColor)
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
  
  func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 M월 d일"
    return formatter.string(from: date)
  }
  
  func formatShortDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M월 d일"
    return formatter.string(from: date)
  }
  
  func getUserReaction(for userId: UUID) -> String? {
    return store.state.userReactions[userId]
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
    .padding(.bottom, 20)
  }
  
  @ViewBuilder
  func MyCommentSection() -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("내 코멘트")
          .foregroundColor(.w85)
          .font(.SF12B)
        
        Spacer()
        
        if let userComment = store.state.userComment {
          Text(userComment.isPublic ? "전체공개" : "비공개")
            .foregroundColor(.w50)
            .font(.SF12R)
        }
      }
      
      if let userComment = store.state.userComment {
        VStack(alignment: .leading, spacing: 12) {
          Text(userComment.comment)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.w85)
            .font(.SF14R)
            .padding(16)
            .background(Color.w10)
            .cornerRadius(8)
          
          HStack {
            Text(formatDate(userComment.updatedAt))
              .foregroundColor(.w50)
              .font(.SF12R)
            
            Spacer()
            
            Text("수정")
              .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
              .font(.SF14R)
              .onTapGesture {
                store.send(.commentSectionTapped)
              }
          }
        }
      } else {
        Button(action: {
          store.send(.commentSectionTapped)
        }) {
          HStack {
            Text("터치해서 코멘트를 남겨보세요!")
              .foregroundColor(.w85)
              .font(.SF14R)
          }
          .frame(maxWidth: .infinity)
          .padding(16)
          .background(Color.w10)
          .cornerRadius(12)
        }
      }
    }
    .sheet(isPresented: .init(
      get: { store.state.isShowingCommentSheet },
      set: { store.send(.showCommentSheet($0)) }
    )) {
      CommentSheetView(store: store)
    }
    .confirmationDialog("", isPresented: .init(
      get: { store.state.isShowingEditActionSheet },
      set: { store.send(.showEditActionSheet($0)) }
    )) {
      Button("수정하기") {
        store.send(.showCommentSheet(true))
      }
      Button("삭제하기", role: .destructive) {
        store.send(.showDeleteAlert(true))
      }
      Button("취소하기", role: .cancel) { }
    }
    .alert("코멘트 삭제", isPresented: .init(
      get: { store.state.isShowingDeleteAlert },
      set: { store.send(.showDeleteAlert($0)) }
    )) {
      Button("취소", role: .cancel) {
        store.send(.showDeleteAlert(false))
      }
      Button("삭제하기", role: .destructive) {
        store.send(.confirmDelete)
      }
    } message: {
      Text("코멘트를 삭제하시겠어요?")
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
  func MakgeolliEvaluationAndCommentsSection() -> some View {
    VStack(alignment: .leading, spacing: 20) {
      HStack {
        Text("평가 및 코멘트")
          .foregroundColor(.w)
          .font(.SF20B)
        Spacer()
      }
      
      if let reactionCounts = store.state.reactionCounts {
        let likeCount = reactionCounts.likeCount
        let dislikeCount = reactionCounts.dislikeCount
        let totalCount = likeCount + dislikeCount
        
        let likePercentage = totalCount > 0 ? Double(likeCount) / Double(totalCount) * 100 : 0
        let dislikePercentage = totalCount > 0 ? Double(dislikeCount) / Double(totalCount) * 100 : 0
        
        VStack(spacing: 4) {
          HStack {
            Text("\(String(format: "%.0f", likePercentage))%")
              .foregroundColor(.w85)
              .font(.SF14R)
            
            Spacer()
            
            GeometryReader { geometry in
              ZStack {
                RoundedRectangle(cornerRadius: 4)
                  .fill(Color.w10)
                  .frame(width: geometry.size.width, height: 5)
                
                RoundedRectangle(cornerRadius: 4)
                  .fill(LinearGradient(
                    gradient: Gradient(stops: [
                      .init(color: DesignSystemAsset.Colors.goldenyellow.swiftUIColor,
                            location: 0),
                      .init(color: DesignSystemAsset.Colors.goldenyellow.swiftUIColor,
                            location: CGFloat(likePercentage / 100)),
                      .init(color: DesignSystemAsset.Colors.lilac.swiftUIColor,
                            location: CGFloat(likePercentage / 100)),
                      .init(color: DesignSystemAsset.Colors.lilac.swiftUIColor,
                            location: 1)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                  ))
                  .frame(width: geometry.size.width, height: 5)
              }
            }
            .frame(height: 5)
            
            Spacer()
            
            Text("\(String(format: "%.0f", dislikePercentage))%")
              .foregroundColor(.w85)
              .font(.SF14R)
          }
          
          HStack {
            Text("좋았어요 (\(likeCount))")
              .foregroundColor(.w50)
              .font(.SF14R)
            
            Spacer()
            
            Text("아쉬워요 (\(dislikeCount))")
              .foregroundColor(.w50)
              .font(.SF14R)
          }
        }
      } else {
        VStack(spacing: 4) {
          HStack {
            Text("- %")
              .foregroundColor(.w)
              .font(.SF14R)
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
              .fill(Color.w10)
              .frame(height: 5)
            
            Spacer()
            
            Text("- %")
              .foregroundColor(.w)
              .font(.SF14R)
          }
        }
      }
      
      if !store.state.publicComments.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          LazyHStack(spacing: 12) {
            ForEach(Array(store.state.publicComments.prefix(5)), id: \.id) { comment in
              VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                  Group {
                    if let userReaction = getUserReaction(for: comment.userId) {
                      if userReaction == "like" {
                        DesignSystemAsset.Images.circleLike.swiftUIImage
                          .resizable()
                      } else if userReaction == "dislike" {
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
                  .frame(width: 10, height: 10)
                  
                  Spacer()
                }
                
                Text(comment.comment)
                  .foregroundColor(.w85)
                  .font(.SF14R)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .lineLimit(nil)
                
                Spacer()
                
                Text(formatShortDate(comment.createdAt))
                  .foregroundColor(.w50)
                  .font(.SF12R)
              }
              .frame(width: 120, height: 120)
              .padding(12)
              .background(Color.darkgray)
              .cornerRadius(12)
            }
          }
        }
      } else {
        VStack(alignment: .center, spacing: 8) {
          Text("공개된 코멘트가 없어요.")
            .foregroundColor(.w50)
            .font(.SF12R)
            .frame(maxWidth: .infinity)
        }
        .frame(width: 120, height: 120)
        .padding(12)
        .background(Color.darkgray)
        .cornerRadius(12)
      }
    }
    .padding(.bottom, 40)
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

private struct CommentSheetView: View {
  let store: StoreOf<InformationCore>
  
  @State private var commentText: String = ""
  @State private var isPublic: Bool = true
  
  @FocusState private var isTextEditorFocused: Bool
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Button("취소") {
          store.send(.showCommentSheet(false))
        }
        .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
        .font(.SF17R)
        
        Spacer()
        
        Text(store.state.userComment != nil ? "코멘트 수정" : "코멘트 남기기")
          .foregroundColor(.w)
          .font(.SF17B)
        
        Spacer()
        
        Button("저장") {
          store.send(.saveComment(commentText, isPublic))
        }
        .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
        .font(.SF17R)
        .disabled(commentText.isEmpty)
      }
      .padding(16)
      
      Divider()
        .padding(.bottom, 16)
      
      TextField("막걸리에 대한 생각을 자유롭게 적어주세요.", text: $commentText, axis: .vertical)
        .foregroundColor(.w85)
        .font(.SF14R)
        .focused($isTextEditorFocused)
        .lineLimit(10...15)
        .onChange(of: commentText) { _, newValue in
          if newValue.count > 200 {
            commentText = String(newValue.prefix(200))
          }
        }
        .padding(.horizontal, 16)
      
      Divider()
        .padding(.vertical, 16)
      
      HStack(spacing: 8) {
        Spacer()
        
        Text("비공개")
          .foregroundColor(.w50)
          .font(.SF14R)
        
        Button(action: {
          isPublic.toggle()
        }) {
          Image(systemName: !isPublic ? "checkmark.circle.fill" : "circle")
            .foregroundColor(!isPublic ? DesignSystemAsset.Colors.primary.swiftUIColor : .w50)
        }
      }
      .padding(.horizontal, 16)
      
      Spacer()
    }
    .background(DesignSystemAsset.Colors.darkbase.swiftUIColor)
    .onAppear {
      if let userComment = store.state.userComment {
        commentText = userComment.comment
        isPublic = userComment.isPublic
      }
    }
  }
}
