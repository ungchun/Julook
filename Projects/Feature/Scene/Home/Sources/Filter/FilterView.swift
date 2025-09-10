//
//  FilterView.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/9/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import DesignSystem
import Core

import ComposableArchitecture

public struct FilterView: View {
  @Bindable var store: StoreOf<FilterCore>
  
  public init(store: StoreOf<FilterCore>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      DesignSystemAsset.Colors.darkbase.swiftUIColor
        .ignoresSafeArea()
      
      VStack {
        if !store.isTopicMode {
          FilterOptionsView(store: store)
        }
        
        ScrollViewReader { proxy in
          
          ScrollView {
            Color.clear
              .frame(height: 1)
              .id("SCROLL_TOP")
            
            SortOptionsView(store: store)
            
            MakgeolliGridView(store: store)
          }
          .onChange(of: store.scrollToTop) { _, newValue in
            if newValue {
              proxy.scrollTo("SCROLL_TOP", anchor: .top)
              store.send(.resetScroll)
            }
          }
        }
      }
    }
    .accentColor(DesignSystemAsset.Colors.primary.swiftUIColor)
    .addNavigationBar(
      title: store.isTopicMode
      ? store.topicTitle : "특징으로 찾기"
    )
    .onAppear { store.send(.onAppear) }
  }
}

private struct FilterOptionsView: View {
  let store: StoreOf<FilterCore>
  
  fileprivate init(store: StoreOf<FilterCore>) {
    self.store = store
  }
  
  fileprivate var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(Array(FilterType.allCases.enumerated()), id: \.element) { index, option in
          Button {
            Amp.track(event: "filter_type_clicked", properties: [
              "filter_type": option.description
            ])
            store.send(.toggleFilterTapped(option))
          } label: {
            Text(option.description)
              .foregroundColor(.w)
              .font(.SF15R)
          }
          .cornerRadius(10)
          .buttonStyle(.borderedProminent)
          .tint(store.selectedFilters.contains(option) ? Color.lilac : Color.w10)
          .padding(.leading, index == 0 ? 16 : 0)
        }
      }
    }
    .padding(.vertical, 10)
  }
}

private struct SortOptionsView: View {
  let store: StoreOf<FilterCore>
  
  fileprivate init(store: StoreOf<FilterCore>) {
    self.store = store
  }
  
  fileprivate var body: some View {
    VStack {
      HStack {
        HStack(spacing: 4) {
          Text("어떤 순서로 정렬되나요")
            .foregroundColor(.w50)
            .font(.SF12R)
          
          Image(systemName: "questionmark.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 12, height: 12)
            .foregroundColor(.w50)
        }
        .onTapGesture {
          store.send(.toggleSortInfoAlertTapped)
        }
        .alert("추천순으로 정렬", isPresented: Binding(
          get: { store.showSortInfoAlert },
          set: { if !$0 { store.send(.toggleSortInfoAlertTapped) } }
        )) {
          Button("확인", role: .cancel) {
            store.send(.toggleSortInfoAlertTapped)
          }
        } message: {
          Text("최근에 나온 막걸리일수록 리스트 상단에 정렬돼요.")
        }
        
        Spacer()
        
        Menu {
          Picker("", selection: Binding(
            get: { self.store.selectedSort },
            set: { option in
              Amp.track(event: "sort_option_selected", properties: [
                "sort_option": option.description
              ])
              self.store.send(.selectSort(option))
              self.store.send(.applySorting)
            }
          )) {
            ForEach(SortOption.allCases) { option in
              Text(option.description)
                .foregroundColor(.white)
                .font(.SF14R)
                .tag(option)
            }
          }
          .labelsHidden()
        } label: {
          HStack(spacing: 4) {
            Group {
              Text(self.store.selectedSort.description)
              Image(systemName: "chevron.up.chevron.down")
            }
            .font(.SF12B)
            .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
    }
  }
}

private struct MakgeolliGridView: View {
  let store: StoreOf<FilterCore>
  
  fileprivate init(store: StoreOf<FilterCore>) {
    self.store = store
  }
  
  fileprivate var body: some View {
    LazyVStack {
      LazyVGrid(
        columns: [
          GridItem(.flexible(), spacing: 16),
          GridItem(.flexible())
        ],
        spacing: 16
      ) {
        ForEach(Array(store.makgeollis.enumerated()), id: \.offset) { index, makgeolli in
          MakgeolliCardView(makgeolli: makgeolli, imageURL: store.makgeolliImages[makgeolli.id])
            .id(makgeolli.id.uuidString + String(index))
        }
      }
      .padding(.horizontal, 16)
      
      if store.hasMoreData {
        LoadMoreView(isLoading: store.isLoadingMakgeollis)
          .onAppear {
            if !store.isLoadingMakgeollis {
              store.send(.loadMoreMakgeollis)
            }
          }
      }
    }
  }
}

private extension MakgeolliGridView {
  @ViewBuilder
  func MakgeolliCardView(makgeolli: Makgeolli, imageURL: URL?) -> some View {
    VStack(spacing: 16) {
      if let imageURL = imageURL {
        AsyncImage(url: imageURL) { phase in
          switch phase {
          case .empty:
            ProgressView()
              .frame(height: 150)
          case .success(let image):
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 150)
              .clipped()
          case .failure:
            DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 150)
          @unknown default:
            DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 150)
          }
        }
      } else {
        Rectangle()
          .fill(Color.darkgray)
          .frame(height: 150)
          .overlay(
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: .w))
          )
      }
      
      VStack(spacing: 2) {
        Text(makgeolli.name)
          .foregroundColor(.w)
          .font(.SF12R)
          .lineLimit(1)
        
        if let brewery = makgeolli.brewery {
          Text("\(brewery) ･ \(formatValue(makgeolli.alcoholPercentage))도")
          .foregroundColor(.w50)
          .font(.SF10R)
          .lineLimit(1)
        } else {
          Text("\(formatValue(makgeolli.alcoholPercentage))도")
          .foregroundColor(.w50)
          .font(.SF10R)
          .lineLimit(1)
        }
      }
      
      HStack(spacing: 6) {
        VStack(spacing: 4) {
          getScoreImage(for: makgeolli.sweetness)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
          
          Text("단맛")
            .foregroundColor(.w50)
            .font(.SF10B)
        }
        
        VStack(spacing: 4) {
          getScoreImage(for: makgeolli.sourness)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
          
          Text("신맛")
            .foregroundColor(.w50)
            .font(.SF10B)
        }
        
        VStack(spacing: 4) {
          getScoreImage(for: makgeolli.thickness)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
          
          Text("걸쭉")
            .foregroundColor(.w50)
            .font(.SF10B)
        }
        
        VStack(spacing: 4) {
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
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 12)
    .padding(.bottom, 28)
    .padding(.top, 32)
    .background(Color.darkgray)
    .cornerRadius(20)
    .onTapGesture {
      store.send(.moveToInformation(makgeolli, imageURL))
    }
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

private extension MakgeolliGridView {
  @ViewBuilder
  func LoadMoreView(isLoading: Bool) -> some View {
    HStack {
      Spacer()
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .w))
      Spacer()
    }
    .frame(height: 50)
  }
}
