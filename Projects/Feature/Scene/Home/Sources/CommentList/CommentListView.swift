//
//  CommentListView.swift
//  FeatureHome
//
//  Created by Kim SungHun on 8/17/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import DesignSystem
import Core

import ComposableArchitecture

public struct CommentListView: View {
  let store: StoreOf<CommentListCore>
  
  public init(store: StoreOf<CommentListCore>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      DesignSystemAsset.Colors.darkbase.swiftUIColor
        .ignoresSafeArea()
      
      VStack(spacing: 0) {
        if store.isLoading {
          LoadingView()
        } else {
          CommentListContentView()
        }
      }
      .padding(.vertical, 16)
    }
    .addNavigationBar(
      title: "코멘트가 달렸어요"
    )
    .onAppear { store.send(.onAppear) }
  }
}

private extension CommentListView {
  @ViewBuilder
  func LoadingView() -> some View {
    VStack(spacing: 12) {
      ForEach(0..<5, id: \.self) { _ in
        HStack(spacing: 16) {
          RoundedRectangle(cornerRadius: 12)
            .fill(DesignSystemAsset.Colors.darkgray.swiftUIColor)
            .frame(width: 80, height: 80)
          
          VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
              .fill(DesignSystemAsset.Colors.darkgray.swiftUIColor)
              .frame(height: 16)
            
            RoundedRectangle(cornerRadius: 4)
              .fill(DesignSystemAsset.Colors.darkgray.swiftUIColor)
              .frame(height: 12)
            
            RoundedRectangle(cornerRadius: 4)
              .fill(DesignSystemAsset.Colors.darkgray.swiftUIColor)
              .frame(width: 80, height: 12)
          }
          
          Spacer()
        }
        .padding(.horizontal, 16)
        
        Divider()
          .padding(.vertical, 12)
      }
    }
    .frame(maxHeight: .infinity, alignment: .top)
  }
  
  @ViewBuilder
  func EmptyView() -> some View {
    VStack(spacing: 20) {
      Text("아직 코멘트가 없어요")
        .foregroundColor(.w50)
        .font(.SF17R)
      
      DesignSystemAsset.Images.searchJulook.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(height: 140)
    }
    .frame(maxHeight: .infinity)
  }
  
  @ViewBuilder
  func LoadingMoreView() -> some View {
    HStack(spacing: 8) {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .w))
        .scaleEffect(0.8)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
  }
  
  @ViewBuilder
  func CommentListContentView() -> some View {
    ScrollView(showsIndicators: false) {
      LazyVStack(spacing: 0) {
        ForEach(Array(store.commentedMakgeollis.enumerated()), id: \.element.id) { idx, comment in
          if let makgeolli = store.makgeolliInfo[comment.makgeolliId] {
            CommentListItem(
              comment: comment,
              makgeolli: makgeolli,
              imageURL: store.makgeolliImages[makgeolli.id],
              reactionType: store.userReactions[comment.id]
            )
            .onTapGesture {
              Amp.track(event: "comment_list_item_clicked", properties: [
                "makgeolli_name": makgeolli.name
              ])
              store.send(.commentItemTapped(comment))
            }
            .onAppear {
              if idx == store.commentedMakgeollis.count - 3 && store.hasMoreData && !store.isLoadingMore {
                store.send(.loadMoreComments)
              }
            }
            
            if idx != store.commentedMakgeollis.count - 1 {
              Divider()
                .padding(.vertical, 12)
            }
          }
        }
        
        if store.isLoadingMore {
          LoadingMoreView()
            .padding(.top, 20)
        }
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 20)
    }
  }
}

private struct CommentListItem: View {
  let comment: UserComment
  let makgeolli: Makgeolli
  let imageURL: URL?
  let reactionType: String?
  
  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      Group {
        if let imageURL = imageURL {
          AsyncImage(url: imageURL) { phase in
            makeImageView(for: phase)
          }
        } else {
          ProgressView()
            .frame(width: 40, height: 80)
        }
      }
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
          
          Spacer()
        }
        
        Text(comment.comment)
          .foregroundColor(.w85)
          .font(.SF14R)
          .lineLimit(nil)
          .multilineTextAlignment(.leading)
          .padding(.top, 4)
        
        Spacer()
        
        Text(formatDate(comment.createdAt))
          .foregroundColor(.w50)
          .font(.SF12R)
      }
    }
    .contentShape(Rectangle())
  }
}

private extension CommentListItem {
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    switch phase {
    case .empty:
      return AnyView(
        ProgressView()
          .frame(width: 40, height: 80)
      )
    case .success(let image):
      return AnyView(
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 40, height: 80)
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
      .frame(width: 40, height: 80)
  }
  
  func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 M월 d일"
    return formatter.string(from: date)
  }
}
